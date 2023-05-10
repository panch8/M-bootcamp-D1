
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Array "mo:base/Array";




  actor {
//  type Result = {
//   #ok: (Homework, ());
//   #err: Text
//  };
 type Time = Int;
 type Pattern = Text.Pattern;
 type Homework = {
  title: Text;
  description:Text;
  dueDate: Time.Time;
  completed: Bool;
 };

  var homeworkDiary = Buffer.Buffer<Homework>(2);

  public func addHomework(h: Homework): async Nat{ 
    homeworkDiary.add(h: Homework);
    var i= homeworkDiary.size();
    return i-1;
  };

  public func getHomework(hId: Nat): async Result.Result<Homework, Text>{
  
    var hW: ?Homework = homeworkDiary.getOpt(hId);
    switch(hW) {
      case(?Homework) return #ok Homework; 
      case(null) {#err "Incorrect homework Id not reachable"  };
    };

  };

  public func updateHomework (hId: Nat, hW: Homework): async Result.Result<(), Text> {
      let s: Nat = homeworkDiary.size();
      if(hId < s){
        homeworkDiary.put(hId, hW);
        return #ok ()}
        else { return #err ("Not valid")};
 
  };

  public func markAsCompleted (hId: Nat): async Result.Result<(),Text>{
       let s: Nat = homeworkDiary.size();
      if(hId < s){
        let hToUpdate: Homework = homeworkDiary.get(hId);
        let hToPut = { 
          completed = true; 
          description = hToUpdate.description; 
          title = hToUpdate.title; 
          dueDate = hToUpdate.dueDate 
          };
        homeworkDiary.put(hId, hToPut);
        return #ok ()}
        else { return #err ("Not valid IIIIID")};
  };

  public func deleteHomework(hId: Nat): async Result.Result<(), Text>{
    let s: Nat = homeworkDiary.size();
    if(hId < s){
      let deleted: Homework = homeworkDiary.remove(hId);
      return #ok ()
    }
    else #err("No deletion bad ID");
  };

  public query func getAllHomework(): async [Homework]{
    Buffer.toArray(homeworkDiary);
  };
 
  public query func getPendingHomework(): async [Homework]{
    let homeworkDiaryArr =  Buffer.toArray(homeworkDiary); 
     
     func _checkIncomplete(el: Homework):Bool{
      
        switch(el.completed){ 
          case(false) true ;
          case(true) false;
         };
        
      };

    let incompleteArr = Array.filter<Homework>(homeworkDiaryArr, _checkIncomplete);
    
    incompleteArr;
};
  public query func searchHomework(searchTerm:Text): async [Homework]{
    let homeworkDiaryArr =  Buffer.toArray(homeworkDiary);
    func _checkSearchTermTit(x: Homework):Bool{
    let p: Pattern = #text (searchTerm);
      switch(Text.contains(x.title, p)){
        case(false)Text.contains(x.description, p);
        case(true)true;
        } 
      };
      Array.filter<Homework>(homeworkDiaryArr,_checkSearchTermTit);
    };
  };