//
//import 'package:oauth2/oauth2.dart' as oauth2;
//import 'dart:io';
//
//class DbxAuthorizer {
//
//  prepare() async {
//    var client = await oauth2.resourceOwnerPasswordGrant(
//      authorizationEndpoint, 'parkinson.disease.dailyslide@gmail.com', 'lucjanssens',
//      identifier: 'qz04prmyoz0yk4v', secret: 'uu0xtszhfodfema');
//
//    // Once you have the client, you can use it just like any other HTTP client.
//    var result = await client.read("http://blablabla/api/users/me/");
//
//    // Once we're done with the client, save the credentials file. This will allow
//    // us to re-use the credentials and avoid storing the username and password
//    // directly.
//    new File("~/.myapp/credentials.json")
//      .writeAsString(client.credentials.toJson());
//  }
//
//  authorize() async {
//    // This URL is an endpoint that's provided by the authorization server. It's
//    // usually included in the server's documentation of its OAuth2 API.
//    final authorizationEndpoint =
//        Uri.parse("http://api.dropbox.com/1/oauth2/authorization");
//
//    // The OAuth2 specification expects a client's identifier and secret
//    // to be sent when using the client credentials grant.
//    //
//    // Because the client credentials grant is not inherently associated with a user,
//    // it is up to the server in question whether the returned token allows limited
//    // API access.
//    //
//    // Either way, you must provide both a client identifier and a client secret:
//    final identifier = "qz04prmyoz0yk4v";
//    final secret = "uu0xtszhfodfema";
//
//    // Calling the top-level `clientCredentialsGrant` function will return a
//    // [Client] instead.
//    var client = await oauth2.clientCredentialsGrant(
//        authorizationEndpoint, identifier, secret);
//
//    // With an authenticated client, you can make requests, and the `Bearer` token
//    // returned by the server during the client credentials grant will be attached
//    // to any request you make.
//    var response =
//        await client.read("https://api.dropbox.com/api/some_resource.json");
//
//    // You can save the client's credentials, which consists of an access token, and
//    // potentially a refresh token and expiry date, to a file. This way, subsequent runs
//    // do not need to reauthenticate, and you can avoid saving the client identifier and
//    // secret.
//    await credentialsFile.writeAsString(client.credentials.toJson());
//  }
//}
