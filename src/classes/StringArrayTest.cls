public with sharing class StringArrayTest {

  public static String[] generateStringArray(Integer n){
    String[] result = new List<String>();

    for(Integer i=0; i<n; i++) {
      result.add('Test '+i);
    }

    if (!result.isEmpty()) {
       return result;
    }
    return null;
  }
}