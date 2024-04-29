--------------------------------------------------------
--  DDL for Package Body WF_DIG_SIG_EVIDENCE_STORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIG_SIG_EVIDENCE_STORE" AS
/* $Header: WFDSEVSB.pls 115.5 2003/01/13 04:09:36 vshanmug ship $ */

--
-- Function
--   GetMostRecentSigID
--
-- Purpose
--  Finds most recently created Sig_ID for a given object Type/ID
--  (e.g. WF_NTF 1234).
--
-- Returns: SIG_ID for success; -1 if not successful.
--
--

Function GetMostRecentSigID(
	SigObjType VARCHAR2,
	SigObjID   Varchar2) return number is

 /* cursor to get most recent activity */
 cursor cursig(ObjType varchar2, ObjID number) is
  Select SIG_ID
    from wf_dig_sigs
    where Sig_Obj_Type = ObjType
      and Sig_Obj_ID = ObjID
      order by sig_id desc;

 retval number;

begin
     /* Get the most recent signature for object */
     open cursig(SigObjType, SigObjID);
     fetch cursig into retval;
     close cursig;

     return retval;

exception
  when others then return -1;
end;


--
-- Function
--   GetCertID
--
-- Purpose
--  Finds Cert_ID for a given Sig ID
--
-- Returns: Cert_ID for success; -1 if not successful.
--
--

Function GetCertID(SigID NUMBER) return number is

retval number;

begin
  Select nvl(Cert_ID,-1)
    into retval
    from wf_dig_sigs
   where Sig_Id = SigID;

  return retval;
exception
  when others then return -1;
end;

--
-- Function
--   GetSigFlavor
--
-- Purpose
--  Finds SigFlavor for a given Sig ID
--
-- Returns: SigFlavor for success; null if not successful.
--
--

Function GetSigFlavor(SigID NUMBER) return Varchar2 is

retval varchar2(30);

begin
  Select Sig_Flavor
    into retval
    from wf_dig_sigs
   where Sig_Id = SigID;

  return retval;
exception
  when others then return null;
end;

--
-- Function
--   GetSigPolicy
--
-- Purpose
--  Finds SigPolicy for a given Sig ID
--
-- Returns: SigPolicy for success; null if not successful.
--
--

Function GetSigPolicy(SigID NUMBER) return Varchar2 is

retval varchar2(30);

begin
  Select Sig_Policy
    into retval
    from wf_dig_sigs
   where Sig_Id = SigID;

  return retval;
exception
  when others then return null;
end;


--
-- Procedure
--   GetSignature
--
-- Purpose
--  Finds Signature for a given Sig ID
--

Procedure GetSignature(SigID NUMBER, Sig out nocopy Clob) is

begin
  Select Signature
    into Sig
    from wf_dig_sigs
   where Sig_Id = SigID;

exception
  when others then Sig := null;
end;


--
-- Procedure
--   GetSigObjectInfo
--
-- Purpose
--  Finds Object Info for a given Sig ID
--

Procedure GetSigObjectInfo(SigID NUMBER, ObjType out nocopy Varchar2,
				ObjID out nocopy varchar2, ObjText out nocopy CLOB) is

begin
  Select Sig_Obj_Type, Sig_Obj_ID, Plaintext
    into ObjType, ObjID, ObjText
    from wf_dig_sigs
   where Sig_Id = SigID;

exception
  when others then
	ObjType := null;
	ObjID := '-1';
	ObjText := null;
end;



--
-- Procedure
--   GetSigStatusInfo
--
-- Purpose
--  Finds Status Info for a given Sig ID
--

Procedure GetSigStatusInfo(SigID NUMBER, SigStatus out nocopy Number,
				CreationDate out nocopy Date,
				SignedDate out nocopy Date,
				VerifiedDate out nocopy Date,
				LastAttValDate out nocopy Date,
				ValidatedDate out nocopy Date,
				Ebuf out nocopy Varchar2,
				Estack out nocopy Varchar2) is

begin
  Select Status, Creation_Date, Signed_Date, Verified_Date,
	Last_Validation_Attempt, Validated_Complete_Date, Errbuf, ErrStack
    into SigStatus, CreationDate, SignedDate, VerifiedDate,
	LastAttValDate, ValidatedDate, Ebuf, Estack
    from wf_dig_sigs
   where Sig_Id = SigID;

exception
  when others then
  	SigStatus := -1;
	CreationDate := null;
	SignedDate := null;
	VerifiedDate := null;
	LastAttValDate := null;
	ValidatedDate := null;
	Ebuf := null;
 	Estack  := null;
end;


--
-- Procedure
--   GetReqSignerInfo
--
-- Purpose
--  Finds Requested Signer Info for a given Sig ID
--

Procedure GetReqSignerInfo(SigID NUMBER, SignerType out nocopy Varchar2,
				SignerID out nocopy varchar2) is


begin
  Select Requested_Signer_Type, Requested_Signer_ID
    into SignerType, SignerID
    from wf_dig_sigs
   where Sig_Id = SigID;

exception
  when others then
	SignerType := null;
	SignerID := '-1';
end;


--
-- Procedure
--   GetActualSignerInfo
--
-- Purpose
--  Finds Actual Signer Info for a given Sig ID
--

Procedure GetActualSignerInfo(SigID NUMBER, SignerType out nocopy Varchar2,
				SignerID out nocopy varchar2) is


begin
  Select c.Owner_domain, c.Owner_ID
    into SignerType, SignerID
    from wf_dig_sigs S, wf_dig_certs C
   where S.Sig_Id = SigID
     and S.cert_id = C.cert_id;

exception
  when others then
	SignerType := null;
	SignerID := '-1';
end;


--
-- Function
--   GetCertType
--
-- Purpose
--  Finds Cert_Type for a given Cert ID
--
-- Returns: CertType for success; null if not successful.
--
--

Function GetCertType(CertID NUMBER) return Varchar2 is

retval varchar2(30);

begin
  Select Cert_Type
    into retval
    from wf_dig_certs
   where Cert_Id = CertID;

  return retval;
exception
  when others then return null;
end;



END WF_Dig_Sig_Evidence_Store;

/
