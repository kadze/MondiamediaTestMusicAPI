//
//  MusicItem.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 08.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import UIKit

enum MusicItemType: String, Codable {
    case song
    case album
}

final class MusicItem {
    let title: String
    let artist: String
    let type: MusicItemType
    let tinyImageURLAddress: String
    let largeImageURLAddress: String
    
    var tinyImage: UIImage? {
        didSet {
            if let handler = tinyImageSetHandler {
                handler(tinyImage)
            }
        }
    }
    
    var largeImage: UIImage? {
        didSet {
            if let handler = largeImageSetHandler {
                handler(largeImage)
            }
        }
    }
    
    var tinyImageSetHandler: ((UIImage?) -> ())?
    var largeImageSetHandler: ((UIImage?) -> ())?
    
    init(title: String, type: MusicItemType, artist: String, tinyImageURLAddress: String, largeImageURLAddress: String) {
        self.title = title
        self.artist = artist
        self.type = type
        self.tinyImageURLAddress = tinyImageURLAddress
        self.largeImageURLAddress = largeImageURLAddress
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.type = try container.decode(MusicItemType.self, forKey: .type)
        
        let artist = try container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
        let artistName = try artist.decode(String.self, forKey: .name)
        self.artist = artistName
        
        let cover = try container.nestedContainer(keyedBy: CoverKeys.self, forKey: .cover)
        let large = try cover.decode(String.self, forKey: .largeImageURLAddress)
        let tiny = try cover.decode(String.self, forKey: .tinyImageURLAddress)
        largeImageURLAddress = large
        tinyImageURLAddress = tiny
    }
}

//MARK: - Codable

extension MusicItem: Model {
    enum CodingKeys: String, CodingKey {
        case title
        case artist = "mainArtist"
        case type
        case cover
    }
    
    enum ArtistKeys: String, CodingKey {
        case name
    }
    
    enum CoverKeys: String, CodingKey {
        case tinyImageURLAddress = "tiny"
        case largeImageURLAddress = "large"
    }
    
    struct Cover: Codable {
        let tiny: String
        let large: String
    }
}

//MARK: - Network

extension MusicItem {
    
    static func itemsFromAPI(with filter: String, completion:(([MusicItem]) -> ())?) {
        let requestHeaders = ["Content-Type" : "application/x-www-form-urlencoded",
                              "Accept" : "application/json",
                              "X-MM-GATEWAY-KEY" : "Ge6c853cf-5593-a196-efdb-e3fd7b881eca"]
        
        let tokenRequest = Request(path: NetworkConstants.accessTokenPath, method: .post, headers: requestHeaders)
        Network.shared.send(tokenRequest) { (result: Result<AccessToken, Error>) in
            switch result {
            case .success(let token):
                let tokenValue = token.accessToken
                print(tokenValue) //remove this row
                let itemsRequest = musicItemsRequest(with: tokenValue,
                                                     headers: requestHeaders,
                                                     filter: filter)
                
                Network.shared.sendToRetreiveData(itemsRequest) { (result: Result<Data, Error>) in
                    switch result {
                    case .success(let data):
                        print("data")
                        do {
                            //dispath here !!
                            let itemsArray = try JSONDecoder().decode([MusicItem].self, from: data)
                            print(itemsArray)
                            if let completion = completion {
                                completion(itemsArray)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func musicItemsRequest(with token: String, headers: [String : String], filter: String) -> Request {
        var requestHeaders = headers
        requestHeaders["Authorization"] = "Bearer \(token)"
        
        var components = URLComponents()
        components.scheme = NetworkConstants.scheme
        components.host = NetworkConstants.host
        components.path = NetworkConstants.resultsPath
        
        //query items
        let query = URLQueryItem(name: "query", value: filter)
        let includeArtists = URLQueryItem(name: "includeArtists", value: "true")
        let limit = URLQueryItem(name: "limit", value: "20")
        let filterByStreamingOnly = URLQueryItem(name: "filterByStreamingOnly", value: "false")
        
        components.queryItems = [query, includeArtists, limit, filterByStreamingOnly]
        
        return Request(urlComponents: components, method: .get, headers: requestHeaders)
    }
    
    func loadTinyImage() {
        DispatchQueue.global().async { [weak self] in
            if let urlString = self?.tinyImageURLAddress,
                let url = URL(string: "\(NetworkConstants.scheme):\(urlString)")
            {
                let data = try? Data(contentsOf: url)
                if let imageData = data,
                    let image = UIImage(data: imageData)
                {
                    DispatchQueue.main.async {
                        self?.tinyImage = image
                    }
                }
            }
        }
    }
    
    func loadLargeImage() {
        DispatchQueue.global().async { [weak self] in
            if let urlString = self?.largeImageURLAddress,
                let url = URL(string: "\(NetworkConstants.scheme):\(urlString)")
            {
                let data = try? Data(contentsOf: url)
                if let imageData = data,
                    let image = UIImage(data: imageData)
                {
                    DispatchQueue.main.async {
                        self?.largeImage = image
                    }
                }
            }
        }
    }
}

/* items responce example
 [
   {
     "id": 3085575,
     "type": "song",
     "title": "High Flying Bird",
     "publishingDate": "2008-08-26T00:00:00Z",
     "duration": 252,
     "mainArtist": {
       "id": 2620,
       "name": "Elton John"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3085558,
       "title": "Temptation: Music From The Showtime Series Californication (International Version)"
     },
     "volumeNumber": 1,
     "trackNumber": 17,
     "genres": [
       "Pop"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBAMB9500010",
       "roviId": "MT0001549557",
       "roviTrackId": "MT0001549557"
     },
     "adfunded": false,
     "streamable": false,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3085558.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3085558.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3085558.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3085558.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3085558.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3085558.{suffix}"
     }
   },
   {
     "id": 3085929,
     "type": "song",
     "title": "If I Had Eyes",
     "publishingDate": "2011-10-25T00:00:00Z",
     "duration": 240,
     "mainArtist": {
       "id": 2835,
       "name": "Jack Johnson"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3085928,
       "title": "If I Had Eyes"
     },
     "volumeNumber": 1,
     "trackNumber": 1,
     "genres": [
       "Alternative"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "USUM70763258",
       "roviId": "MT0009074505",
       "roviTrackId": "MT0009074505"
     },
     "adfunded": true,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3085928.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3085928.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3085928.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3085928.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3085928.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3085928.{suffix}"
     }
   },
   {
     "id": 3085930,
     "type": "song",
     "title": "Let It Be Sung (Album Version)",
     "publishingDate": "2012-04-22T00:00:00Z",
     "duration": 249,
     "mainArtist": {
       "id": 2835,
       "name": "Jack Johnson"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3085928,
       "title": "If I Had Eyes"
     },
     "volumeNumber": 1,
     "trackNumber": 2,
     "genres": [
       "Alternative"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "USUM70612641",
       "roviId": "MT0009291926",
       "roviTrackId": "MT0009291926"
     },
     "adfunded": true,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3085928.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3085928.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3085928.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3085928.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3085928.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3085928.{suffix}"
     }
   },
   {
     "id": 3102475,
     "type": "song",
     "title": "O Tzonis O Bogias (Johnny The Dogcatcher) (2002 Digital Remaster)",
     "publishingDate": "2007-11-19T00:00:00Z",
     "duration": 140,
     "mainArtist": {
       "id": 531150,
       "name": "Giorgos Romanos"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3102473,
       "title": "Mithologia"
     },
     "volumeNumber": 1,
     "trackNumber": 8,
     "genres": [
       "Pop"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GRE010200072",
       "roviId": "MT0019682658",
       "roviTrackId": "MT0019682658"
     },
     "adfunded": true,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3102473.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3102473.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3102473.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3102473.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3102473.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3102473.{suffix}"
     }
   },
   {
     "id": 3103450,
     "type": "song",
     "title": "Sullivan: 21. He yields! He yields!",
     "publishingDate": "2003-06-23T00:00:00Z",
     "duration": 157,
     "mainArtist": {
       "id": 29817,
       "name": "John Reed"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3103449,
       "title": "Gilbert & Sullivan: Ruddigore"
     },
     "volumeNumber": 2,
     "trackNumber": 7,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBF076241123"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3103449.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3103449.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3103449.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3103449.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3103449.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3103449.{suffix}"
     }
   },
   {
     "id": 3103452,
     "type": "song",
     "title": "Sullivan: 16. I once was as meek as a newborn lamb",
     "publishingDate": "2003-06-23T00:00:00Z",
     "duration": 147,
     "mainArtist": {
       "id": 29817,
       "name": "John Reed"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3103449,
       "title": "Gilbert & Sullivan: Ruddigore"
     },
     "volumeNumber": 2,
     "trackNumber": 2,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBF076241118"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3103449.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3103449.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3103449.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3103449.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3103449.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3103449.{suffix}"
     }
   },
   {
     "id": 3103462,
     "type": "song",
     "title": "Sullivan: 19. Painted emblems of a race",
     "publishingDate": "2003-06-23T00:00:00Z",
     "duration": 265,
     "mainArtist": {
       "id": 29817,
       "name": "John Reed"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3103449,
       "title": "Gilbert & Sullivan: Ruddigore"
     },
     "volumeNumber": 2,
     "trackNumber": 5,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBF076241121"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3103449.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3103449.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3103449.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3103449.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3103449.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3103449.{suffix}"
     }
   },
   {
     "id": 3107721,
     "type": "song",
     "title": "Phillips: Selections from McGuffey's Reader - 2. John Alden and Priscilla",
     "publishingDate": "2004-11-16T00:00:00Z",
     "duration": 364,
     "mainArtist": {
       "id": 364384,
       "name": "Eastman-Rochester Orchestra"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3107684,
       "title": "Howard Hanson conducts American Masterworks"
     },
     "volumeNumber": 5,
     "trackNumber": 18,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "NLA505601154"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3107684.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3107684.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3107684.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3107684.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3107684.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3107684.{suffix}"
     }
   },
   {
     "id": 3107776,
     "type": "song",
     "title": "Ives: 3 Places in New England - 3. From \"The Housatonic at Stockbridge\" by Robert Underwood Johnson",
     "publishingDate": "2004-11-16T00:00:00Z",
     "duration": 232,
     "mainArtist": {
       "id": 364384,
       "name": "Eastman-Rochester Orchestra"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3107684,
       "title": "Howard Hanson conducts American Masterworks"
     },
     "volumeNumber": 2,
     "trackNumber": 3,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "NLA505700831"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3107684.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3107684.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3107684.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3107684.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3107684.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3107684.{suffix}"
     }
   },
   {
     "id": 3138408,
     "type": "song",
     "title": "Puccini: Turandot / Act 1 - \"Gira la cote!\"",
     "publishingDate": "2014-11-18T00:00:00Z",
     "duration": 422,
     "mainArtist": {
       "id": 337493,
       "name": "The John Alldis Choir"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3138393,
       "title": "Puccini: Turandot - Highlights"
     },
     "volumeNumber": 1,
     "trackNumber": 2,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBF077230803"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3138393.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3138393.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3138393.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3138393.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3138393.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3138393.{suffix}"
     }
   },
   {
     "id": 3140836,
     "type": "song",
     "title": "Britten: A Midsummer Night's Dream, Op.64 / Act 3 - \"Now, fair Hippolyta\"",
     "publishingDate": "2003-11-04T00:00:00Z",
     "duration": 444,
     "mainArtist": {
       "id": 125944,
       "name": "John Shirley-Quirk"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3140835,
       "title": "Britten: A Midsummer Night's Dream"
     },
     "volumeNumber": 2,
     "trackNumber": 10,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBF076640430"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3140835.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3140835.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3140835.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3140835.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3140835.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3140835.{suffix}"
     }
   },
   {
     "id": 3140875,
     "type": "song",
     "title": "Britten: A Midsummer Night's Dream, Op.64 / Act 3 - \"Come, your Bergomask\"",
     "publishingDate": "2003-11-04T00:00:00Z",
     "duration": 166,
     "mainArtist": {
       "id": 125944,
       "name": "John Shirley-Quirk"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3140835,
       "title": "Britten: A Midsummer Night's Dream"
     },
     "volumeNumber": 2,
     "trackNumber": 20,
     "genres": [
       "Classic"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "GBF076640440"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3140835.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3140835.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3140835.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3140835.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3140835.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3140835.{suffix}"
     }
   },
   {
     "id": 3152890,
     "type": "song",
     "title": "Johnny Soldaat",
     "publishingDate": "2007-11-30T00:00:00Z",
     "duration": 222,
     "mainArtist": {
       "id": 4264,
       "name": "Rob De Nijs"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3152833,
       "title": "Rob 100"
     },
     "volumeNumber": 3,
     "trackNumber": 1,
     "genres": [
       "Pop"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "NLA270200265",
       "roviId": "MT0018840339",
       "roviTrackId": "MT0018840339"
     },
     "adfunded": true,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3152833.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3152833.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3152833.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3152833.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3152833.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3152833.{suffix}"
     }
   },
   {
     "id": 3181829,
     "type": "song",
     "title": "Nearer My God To Thee",
     "publishingDate": "2007-05-11T00:00:00Z",
     "duration": 55,
     "mainArtist": {
       "id": 781851,
       "name": "John Dykes"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3181855,
       "title": "Ghosts Of The Abyss"
     },
     "volumeNumber": 1,
     "trackNumber": 26,
     "genres": [
       "Pop",
       "Soundtrack"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "USHR10722960",
       "roviId": "MT0043213286",
       "roviTrackId": "MT0043213286"
     },
     "adfunded": true,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3181855.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3181855.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3181855.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3181855.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3181855.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3181855.{suffix}"
     }
   },
   {
     "id": 3181842,
     "type": "song",
     "title": "Eternal Father, Strong To Save",
     "publishingDate": "2007-05-11T00:00:00Z",
     "duration": 182,
     "mainArtist": {
       "id": 781851,
       "name": "John Dykes"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3181855,
       "title": "Ghosts Of The Abyss"
     },
     "volumeNumber": 1,
     "trackNumber": 28,
     "genres": [
       "Pop",
       "Soundtrack"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "USHR10722961",
       "roviId": "MT0043213288",
       "roviTrackId": "MT0043213288"
     },
     "adfunded": true,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3181855.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3181855.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3181855.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3181855.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3181855.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3181855.{suffix}"
     }
   },
   {
     "id": 3208073,
     "type": "song",
     "title": "Ollie Mention",
     "publishingDate": "1970-01-01T00:00:00Z",
     "duration": 458,
     "mainArtist": {
       "id": 191129,
       "name": "John Abercrombie"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3208078,
       "title": "Animato"
     },
     "volumeNumber": 1,
     "trackNumber": 8,
     "genres": [
       "Jazz"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "DEB338941108"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3208078.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3208078.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3208078.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3208078.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3208078.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3208078.{suffix}"
     }
   },
   {
     "id": 3208075,
     "type": "song",
     "title": "For Hope Of Hope",
     "publishingDate": "1970-01-01T00:00:00Z",
     "duration": 532,
     "mainArtist": {
       "id": 191129,
       "name": "John Abercrombie"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3208078,
       "title": "Animato"
     },
     "volumeNumber": 1,
     "trackNumber": 6,
     "genres": [
       "Jazz"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "DEB338941106"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3208078.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3208078.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3208078.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3208078.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3208078.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3208078.{suffix}"
     }
   },
   {
     "id": 3208076,
     "type": "song",
     "title": "Right Now",
     "publishingDate": "1970-01-01T00:00:00Z",
     "duration": 449,
     "mainArtist": {
       "id": 191129,
       "name": "John Abercrombie"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3208078,
       "title": "Animato"
     },
     "volumeNumber": 1,
     "trackNumber": 1,
     "genres": [
       "Jazz"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "DEB338941101"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3208078.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3208078.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3208078.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3208078.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3208078.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3208078.{suffix}"
     }
   },
   {
     "id": 3235260,
     "type": "song",
     "title": "Back-Woods Song",
     "publishingDate": "1970-01-01T00:00:00Z",
     "duration": 471,
     "mainArtist": {
       "id": 191129,
       "name": "John Abercrombie"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3235264,
       "title": "Gateway"
     },
     "volumeNumber": 1,
     "trackNumber": 1,
     "genres": [
       "Jazz"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "DEB337506101",
       "roviId": "MT0007384129",
       "roviTrackId": "MT0007384129"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3235264.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3235264.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3235264.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3235264.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3235264.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3235264.{suffix}"
     }
   },
   {
     "id": 3235262,
     "type": "song",
     "title": "Sorcery I",
     "publishingDate": "1970-01-01T00:00:00Z",
     "duration": 656,
     "mainArtist": {
       "id": 191129,
       "name": "John Abercrombie"
     },
     "statistics": {
       "popularity": 0,
       "estimatedRecentCount": 0,
       "estimatedTotalCount": 0
     },
     "release": {
       "id": 3235264,
       "title": "Gateway"
     },
     "volumeNumber": 1,
     "trackNumber": 6,
     "genres": [
       "Jazz"
     ],
     "additionalArtists": [
     ],
     "idBag": {
       "isrc": "DEB337506106",
       "roviId": "MT0007518967",
       "roviTrackId": "MT0007518967"
     },
     "adfunded": false,
     "streamable": true,
     "bundleOnly": false,
     "cover": {
       "tiny": "//staging-placebo.mondiamedia.com/api/fetch/image/article/57x57/3235264.jpg",
       "small": "//staging-placebo.mondiamedia.com/api/fetch/image/article/150x150/3235264.jpg",
       "medium": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3235264.jpg",
       "large": "//staging-placebo.mondiamedia.com/api/fetch/image/article/600x600/3235264.jpg",
       "default": "//staging-placebo.mondiamedia.com/api/fetch/image/article/300x300/3235264.jpg",
       "template": "//staging-placebo.mondiamedia.com/api/fetch/image/article/{width}x{height}/3235264.{suffix}"
     }
   }
 ]
 */
