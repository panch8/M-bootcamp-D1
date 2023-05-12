import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Order "mo:base/Order";



actor studentWall {

  //define types
   type Principal = Principal.Principal;
   type Hash = Nat32;

  public type Content ={
    #Text: Text;
    #Image: Blob;
    #Videp: Blob;
  };

  public type Message = {
    vote : Int;
    content : Content;
    creator : Principal;
  };
  // define variables
  
  var counterId: Nat = 0;

  
  let wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, Hash.hash);



  // add a new message
  //writeMessage fn public 

  public shared ({ caller })func writeMessage(c: Content): async Nat {
    let messageToPost: Message = {
      vote = 0;
      content = c;
      creator = caller;
    };
    var messageId: Nat = counterId;

    wall.put(messageId, messageToPost);
    counterId += 1;
      return messageId;
  }; 
  

  // getMessage fn public query  ==> Result
  public query func getMessage(messageId : Nat): async Result.Result<Message, Text>{
    let s: Nat = wall.size();
    let m: ?Message = wall.get(messageId);
      switch(m){
      case(null) #err("Invalid message Id");
      case(?value) #ok(value);
      }
  };



  //updateMessage public fn
  public shared ({ caller }) func updateMessage(messageId: Nat, c: Content): async Result.Result<(),Text>{
    let messageToModify: ?Message = wall.get(messageId);
  
      switch(messageToModify){
        case(?value){
          if(Principal.equal(value.creator, caller)) {
          let messageToUpdate: Message = {
          vote = value.vote;
          content = c;
          creator = value.creator;
            };
            wall.put(messageId,messageToUpdate);
            return #ok ();
            }else #err ("Not creator");};
        case(null)#err("not valid Id");
      };
   

  };
  //deleteMessage public fn
    public shared ({ caller }) func deleteMessage(messageId: Nat): async Result.Result<(),Text>{
      let s:Nat = wall.size();
      if(messageId < s){
        wall.delete(messageId);
        return #ok();
      }else #err("Not a valid IIIID")
    };
  //upVote

    public func upVote(messageId: Nat): async Result.Result<(),Text>{
      let s: Nat = wall.size();
      let messageToModify: ?Message = wall.get(messageId);
      switch(messageToModify){
        case(?value){
          let messageToPost: Message = {
          vote = value.vote + 1;
          content = value.content;
          creator = value.creator;
        };
        ignore wall.replace(messageId, messageToPost);
        return #ok();
        };
        case(null) #err("invalid ID")
        }
      
    };

  //downVote
    public func downVote(messageId: Nat): async Result.Result<(),Text>{
      let s: Nat = wall.size();
      let messageToModify: ?Message = wall.get(messageId);
      switch(messageToModify){
        case(?value){
        let messageToPost: Message = {
          vote = value.vote -1;
          content = value.content;
          creator = value.creator;
        };
        ignore wall.replace(messageId, messageToPost);
        return #ok();};
        case(null)#err("Invaaa ID");
        }
     
    };

  //getAllMessages query
  public query func getAllMessages(): async [Message]{
    let s: Nat = wall.size();
    let buffer = Buffer.Buffer<Message>(s);
    for(msg in wall.vals()) buffer.add(msg);
    Buffer.toArray(buffer);
  };

  //getAllMessagesRanked query p'ubli

  public query func getAllMessagesRanked(): async [Message]{
    let s: Nat = wall.size();
    let buffer = Buffer.Buffer<Message>(s);
    type Order = Order.Order;
    
    for( msg in wall.vals()) buffer.add(msg);
    buffer.sort(func(x:Message,y:Message):Order{
      if(x.vote > y.vote)return #less;
      if(x.vote == y.vote){return #equal;} 
      else return #greater;
      });
    Buffer.toArray(buffer);
  }

  };