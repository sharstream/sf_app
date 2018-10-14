public with sharing class InterfaceHttpTeam {

  protected Integer code;
  protected String status;
  protected String body;
  protected Map<String, String> responseHeaders;

  public InterfaceHttpTeam(Integer code, String status, String body, Map<String, String> responseHeaders) {
    this.code = code;
    this.status = status;
    this.body = body;
    this.responseHeaders = responseHeaders;
  }

  public HTTPResponse respond(HTTPRequest req) {

    HttpResponse res = new HttpResponse();
    for (String key : this.responseHeaders.keySet()) {
        res.setHeader(key, this.responseHeaders.get(key));
    }
    res.setBody(this.body);
    res.setStatusCode(this.code);
    res.setStatus(this.status);
    return res;
  }

  public static HttpResponse performAction(String method, String webCall) {

    String endPoint = 'https://yougoal.herokuapp.com/api/teamsGet/';
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    endPoint = endPoint + webCall;
    System.debug('Endpoint: ' + endPoint);
    request.setEndpoint(endPoint);
    request.setMethod(method);
    HttpResponse response = http.send(request);
    System.debug(response.getBody());

    //If the request is successful, parse the JSON response
    if (response.getStatusCode() == 200) {
      // Desirializes the JSON string into collections of primitives data types
      // Map<String, Object>[] results = (Map<String, Object>[])JSON.deserializeUntyped(response.getBody());
      List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
      //Cast the values in the 'teams' key as a list

      // List<Object> teams = (List<Object>)results.get('Items');
      System.debug('Received the following teams:');

      List<Team__c> teamsInserted = new List<Team__c>();

      for(Object result : results) {
        Map<String, Object> team = (Map<String, Object>) result;
        Team__c currentTeam = new Team__c();
        currentTeam.Name = (String)team.get('name');
        // currentTeam.Id = (String)team.get('_id');
        teamsInserted.add(currentTeam);
      }

      if (!teamsInserted.isEmpty()) {
        for (Team__c team : teamsInserted) {
          System.debug(team);
        }

        insert teamsInserted;
      }
    }

    return response;
  }

  public static HttpResponse makePostRatingPlayer() {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    //Getting a rating from specific player
    request.setEndpoint('https://yougoal.herokuapp.com/api/teamsGet/ratingPlayer/394');
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setBody('{"ratingPlayer":4}');
    HttpResponse response = http.send(request);
    //Parse the JSON response
    if (response.getStatusCode() !=201) {
       System.debug('The status code returned was not expected:' + response.getStatusCode() + '' + response.getStatus());
    }
    else {
      System.debug(response.getBody());
    }

    return response;
  }
}