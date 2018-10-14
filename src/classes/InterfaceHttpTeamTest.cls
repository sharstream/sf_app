@isTest
private class InterfaceHttpTeamTest {

  @isTest static void testGetHttpTeams() {
    // Create the mock response based on a static resource

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('getTeamResource');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    // Associate the callout with a mock response
    Test.setMock(HttpCalloutMock.class, mock);
    // Call method to test
    HttpResponse result = InterfaceHttpTeam.performAction('GET', 'teams');
    // Verify mock response is not null
    System.assertNotEquals(null, result, 'The callout returned a null response');
    // Verify status code
    System.assertEquals(200, result.getStatusCode(), 'The status code is not 200');
    // Verify content type
    System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected');
    // Verify the array contains 32 items
    Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(result.getBody());
    List<Object> teams = (List<Object>)results.get('Items');
    System.assertEquals(32, teams.size(), 'The array should only contain 32 items.');
  }
}