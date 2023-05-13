
import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";



module {

    public type Subaccount = Blob;
    public type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
  };
    
    func _getDefaultSubaccount() : Subaccount {
        Blob.fromArrayMut(Array.init(32, 0 : Nat8));
    };

    public func equal(a: Account, b:Account): Bool {
    if(a.owner == b.owner and a.subaccount == b.subaccount)true
    else false;
    };

    public func hash(a: Account): Hash.Hash {
        let aSubaccount : Subaccount = Option.get<Subaccount>(a.subaccount, _getDefaultSubaccount());
        let hashSum = Nat.add(Nat32.toNat(Principal.hash(a.owner)),(Nat32.toNat(Blob.hash(aSubaccount))));
        Nat32.fromNat(hashSum % 2**32 -1);
     };

     public func accountBelongsToPrincipal(account: Account, principal: Principal): Bool {
        Principal.equal(account.owner, principal);
     }
};