
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Type "types";
import Ic "ic";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";








//part 1 Storing the studemts information

//student schema

actor Verifier {
  type TestResult = Type.TestResult;
  type TestError = Type.TestError;
  type StudentProfile = Type.StudentProfile;

  stable var studentProfileEntries : [(Principal, StudentProfile)] = [];
  let iter = studentProfileEntries.vals();
  
  let studentProfileStore = HashMap.fromIter<Principal, StudentProfile> (iter,studentProfileEntries.size(),Principal.equal, Principal.hash);

  system func preupgrade(){
    studentProfileEntries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade(){
    studentProfileEntries := [];
  };

  public shared ({ caller }) func addMyProfile(profile : StudentProfile): async Result.Result<(),Text>{
    switch(Principal.isAnonymous(caller)){
      case(true)#err("Cannot register with anonymous ID");
      case(false){
        studentProfileStore.put(caller, profile);
        #ok();
      };
    };
  };

  // public shared ({ caller }) func addFran(): async Result.Result<(),Text>{
  //   switch(true){
  //     case(false)#err("Not an admin");
  //     case(true){
  //       let franProfile: StudentProfile = {
  //         name = "Fran - Panch";
  //         team = "Koalas";
  //         graduate = false;
  //       };
  //       studentProfileStore.put(Principal.fromText("acvcd-vgg3o-qftqn-7apsp-hm3gc-j5qza-u7kcz-2q6jn-3a5hu-iucqw-tae"), franProfile);
  //       #ok();

  //     };
  //   };nm
  // };

  public query func seeAProfile(principal: Principal): async Result.Result<StudentProfile, Text>{
    switch(studentProfileStore.get(principal)){
      case(null)#err("Not a valid Student id");
      case(?profile)#ok(profile);
    };
  };  
  
  public shared ({ caller }) func updateMyProfile(updatedProfile: StudentProfile): async Result.Result<(), Text>{
    switch(studentProfileStore.get(caller)){
      case(null)#err("Student not registered yet");
      case(?profileToModify){
        studentProfileStore.put(caller, updatedProfile);
        #ok();
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile(): async Result.Result<(), Text>{
    switch(studentProfileStore.get(caller)) {
      case(null)#err("cannot delete something that doesn't exist, caller id not registered");
      case(?profileToDelete){
        studentProfileStore.delete(caller);
        #ok();
      };
    };
  };
////////////////////////////////END first part//////////////////////////



public func test(canisterId: Principal): async TestResult{
  let calculatorInterface = actor(Principal.toText(canisterId)): actor {
    reset: shared () -> async Int;
    add: shared (x:Int) -> async Int;
    sub: shared (x:Int) -> async Int;
  };

  try{
    let a: Int = await calculatorInterface.reset();
    if(a != 0){return #err(#UnexpectedValue("returned value Not 0 when reset"));};

    let b: Int = await calculatorInterface.add(10);
    if(b != 10){return #err(#UnexpectedValue("reseted counter +10 should be 10"));};

    let c: Int = await calculatorInterface.sub(10);
    if(c != 0){return #err(#UnexpectedValue("10 - 10 >not 0"))};
    
    #ok();
    

  }
  catch(e){#err(#UnexpectedError("something gor wrong"))};

};



/////////////////////////// Part 3 /////////////////////////////
func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

public type CanisterId = Ic.CanisterId;
public type CanisterSettings = Ic.CanisterSettings;
public type ManagementCanister = Ic.ManagementCanister;

 public func verifyOwnership(canisterId: Principal, principalId: Principal): async Bool{
  
  let manager: ManagementCanister = actor("aaaaa-aa");

try{
  let status = await manager.canister_status({canister_id = canisterId});
  let settings: CanisterSettings = status.settings;
  let controllers: [Principal] = settings.controllers;
  return true;
  
  }
  catch(e){
    let messageError = Error.message(e);
    let controllers2 = parseControllersFromCanisterStatusErrorIfCallerNotController(messageError);
    
    switch(Array.find<Principal>(controllers2, func x = x == principalId)) {
      case(null) {false  };
      case(control) {true};
    };
  

    };
 };

/////////////////// part 4 ////// ///// 


public func verifyWork(canisterId:Principal, principalId: Principal): async Result.Result<(),Text>{
  
  try{
    let isOwnerOfCanister: Bool = await verifyOwnership(canisterId, principalId);
    switch(isOwnerOfCanister) {
     case(false) {#err("you are not the owner of this canister")  };
     case(true ) {
      let isAproved=  await test(canisterId);
      switch(isAproved) {
        case(#err(Error)) {#err("feature not verified")  };
        case(#ok()) {
          let profileToModify: ?StudentProfile = studentProfileStore.get(principalId);
          switch(profileToModify) {
            case(null) {#err("submitted principal id not registered in the school")  };
            case(?profile) {
             let newProfile: StudentProfile = {
              name = profile.name;
              team = profile.team;
              graduate = true;
              };
              studentProfileStore.put(principalId, newProfile);
              #ok();
             };
          };
         };
      };
     };
    };}
  catch(e){#err("smth bad go wrong")};

};


}