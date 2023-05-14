import Result "mo:base/Result";


 module{
   public type StudentProfile = {
    name: Text;
    team: Text;
    graduate: Bool;
  };
  //declare TestResult type
  public type TestResult = Result.Result<(), TestError>;
  // declare TestError variant type
  public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
  };
 


  }
