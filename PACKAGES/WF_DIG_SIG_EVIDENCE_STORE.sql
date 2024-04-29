--------------------------------------------------------
--  DDL for Package WF_DIG_SIG_EVIDENCE_STORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIG_SIG_EVIDENCE_STORE" AUTHID CURRENT_USER AS
/* $Header: WFDSEVSS.pls 115.5 2003/01/13 04:09:23 vshanmug ship $ */

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
	SigObjID   VARCHAR2) return number;

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

Function GetCertID(SigID NUMBER) return number;

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

Function GetSigFlavor(SigID NUMBER) return Varchar2;

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

Function GetSigPolicy(SigID NUMBER) return Varchar2;

--
-- Procedure
--   GetSignature
--
-- Purpose
--  Finds Signature for a given Sig ID
--

Procedure GetSignature(SigID NUMBER, Sig out nocopy Clob);

--
-- Procedure
--   GetSigObjectInfo
--
-- Purpose
--  Finds Object Info for a given Sig ID
--

Procedure GetSigObjectInfo(SigID NUMBER, ObjType out nocopy Varchar2,
				ObjID out nocopy varchar2, ObjText out nocopy CLOB);

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
				Estack out nocopy Varchar2);

--
-- Procedure
--   GetReqSignerInfo
--
-- Purpose
--  Finds Requested Signer Info for a given Sig ID
--

Procedure GetReqSignerInfo(SigID NUMBER, SignerType out nocopy Varchar2,
				SignerID out nocopy varchar2);

--
-- Procedure
--   GetActualSignerInfo
--
-- Purpose
--  Finds Actual Signer Info for a given Sig ID
--

Procedure GetActualSignerInfo(SigID NUMBER, SignerType out nocopy Varchar2,
				SignerID out nocopy varchar2);

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

Function GetCertType(CertID NUMBER) return Varchar2;


END WF_Dig_Sig_Evidence_Store;

 

/
