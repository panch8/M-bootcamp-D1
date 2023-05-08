import Float "mo:base/Float";

actor {
 stable var counter: Float = 0;
  
  public func add(x : Float) : async Float{
    counter += x;
    return counter;
  };

  public func sub(x: Float): async Float{
    counter -= x;
    return counter;
  };

  public func mul(x : Float): async Float {
    counter *= x;
    return counter;
  };

  public func div(x : Float) : async ?Float {
    if (x == 0) {return null}
    else counter /= x;
    return ?counter;
     

  };

  public func reset () : async Float{
    counter := 0;
    return counter;
  };

  public query func see() : async Float {
    return counter;
  };

  public func power(x : Float) : async Float {
     counter **= x;
     return counter
    
  };

  public func sqrt() : async Float {
    return Float.sqrt(counter);
  };

  public func floor() : async Float {
    return Float.floor(counter);
  };

};
