import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Nat32 "mo:base/Nat32";

import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Account "account";
import Float "mo:base/Float";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Subaccount "account";
import Option "mo:base/Option";
import Iter "mo:base/Iter";




actor motoCoin {

  type Account = Account.Account;


  var ledger = TrieMap.TrieMap<Account, Nat>(Account.equal, Account.hash);
  var coin ={
    name: Text = "MotoCoin";
    symbol: Text = "MOC";
    totalSupply: Nat = 1_000_000 ;
  };

  // public func createAccount(principal: Principal): async Account {
  //   let account: Account = {
  //     owner = principal; 
  //   }
  // };
      // Returns the name of the token 
    // name : shared query () -> async Text;
  public query func name(): async Text {
    coin.name;
  };  

    // Returns the symbol of the token 
    // symbol : shared query () -> async Text;
  public query func symbol(): async Text {
    coin.symbol;
  };
    // Returns the the total number of tokens on all accounts
    // totalSupply : shared query () -> async Nat;

  public query func totalSupply(): async Nat {
    coin.totalSupply;
  };

  public query func getAllBalances(): async [Nat]{
    Iter.toArray(ledger.vals());
  };
    // Returns the balance of the account
    // balanceOf : shared query (account : Account) -> async (Nat);
  public query func balanceOf(account: Account): async Nat{
    let balance: ?Nat = ledger.get(account);
    switch(balance) {
      case(null) 0;
      case(?value)value;
    };
  };  

    // Transfer tokens to another account
    // transfer : shared (from: Account, to : Account, amount : Nat) -> async Result.Result<(), Text>;

  public shared ({ caller }) func transfer(from: Account, to : Account, amount: Nat): async Result.Result<(), Text>{
    if (Account.accountBelongsToPrincipal(from, caller)){
      var balanceFrom: ?Nat = ledger.get(from);
      var balanceTo: ?Nat = ledger.get(to);
      switch(balanceFrom) {
        case(null) throw Error.reject("Account not initialized. not exist.");
        case(?value) {
          if(value < amount) throw Error.reject("Not sufficient Balance")
          else {
            //quitar amount de from
            switch(ledger.replace(from,(value - amount))){
              case(null)throw Error.reject("Not an existing key:'from'");
              case(?val) ignore val;
            };
          };
        };
      };
      switch(balanceTo){
        case(null){ledger.put(to, amount)};
        case(?value){ledger.put(to,(value + amount) )}
      };

      #ok;

    }
    else {#err("Not your account")};


  };
    // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
    // airdrop : shared () -> async Result.Result<(),Text>;
      let studentCanister : actor {
        getAllStudentsPrincipal : shared () -> async [Principal];
      } = actor("rww3b-zqaaa-aaaam-abioa-cai") ;
   
  // func _getAllStudents(): async [Principal]{
  // };
 
  public shared func airdrop(): async Result.Result<(), Text>{

    try{
       let allStudents: [Principal] = await studentCanister.getAllStudentsPrincipal();
     
      for(p in allStudents.vals()){
      
        let account: Account ={
          owner = p;
          subaccount = null;
        };
        let currentBalance = Option.get(ledger.get(account),0);
        ledger.put(account, (currentBalance + 100));
      };
      #ok();
    }catch(e){#err("smth go wrong")};
  };
};