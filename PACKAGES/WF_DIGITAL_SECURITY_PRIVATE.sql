--------------------------------------------------------
--  DDL for Package WF_DIGITAL_SECURITY_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIGITAL_SECURITY_PRIVATE" AUTHID CURRENT_USER AS
/* $Header: WFDSPVTS.pls 120.1 2005/07/02 03:13:36 appldev ship $ */
-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------

        STAT_ERROR		CONSTANT NUMBER :=  -1;
	STAT_REQUESTED 		CONSTANT NUMBER := 100;
	STAT_SIGNED 		CONSTANT NUMBER := 200;
	STAT_VERIFIED 		CONSTANT NUMBER := 300;
	STAT_AUTHORIZED 	CONSTANT NUMBER := 400;
	STAT_VAL_ATTEMPTED 	CONSTANT NUMBER := 500;
	STAT_VALIDATED 		CONSTANT NUMBER := 600;
	STAT_REQUEST_FAILED	CONSTANT NUMBER := -100;
	STAT_SIGN_FAILED	CONSTANT NUMBER := -200;
	STAT_SIGN_CANCELLED	CONSTANT NUMBER := -201;
	STAT_VERIFY_FAILED	CONSTANT NUMBER := -300;
	STAT_AUTHORIZE_FAILED	CONSTANT NUMBER := -400;
	STAT_VALIDATE_FAILED 	CONSTANT NUMBER := -600;



-----------------------------------------------------------------------------
-- Type declaration
-----------------------------------------------------------------------------
TYPE objid_tab_type IS TABLE OF varchar2(20) INDEX BY BINARY_INTEGER;


-----------------------------------------------------------------------------
-- Routines
-----------------------------------------------------------------------------


--
-- Procedure
--   Create_Signature_Entry
--
-- Purpose
--   Creates a new row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Create_Signature_Entry(
	P_SIG_ID NUMBER,
	P_SIG_OBJ_TYPE VARCHAR2,
	P_SIG_OBJ_ID Varchar2,
	P_PLAINTEXT CLOB,
	P_REQUESTED_SIGNER_TYPE Varchar2,
        P_REQUESTED_SIGNER_ID Varchar2,
        P_Sig_Flavor Varchar2,
        P_Sig_Policy Varchar2,
	P_STATUS NUMBER,
      P_returncode out nocopy number);

--
-- Function
--   Update_Signed_Sig
--
-- Purpose
--   Updates a row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Signed_Sig(
	P_SIG_ID NUMBER,
	P_SIGNATURE CLOB,
	P_STATUS NUMBER,
	P_returncode out nocopy number);

--
-- Procedure
--   Update_Verified_Sig
--
-- Purpose
--   Updates a row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Verified_Sig(
	P_SIG_ID NUMBER,
	P_CERT_ID NUMBER,
	P_STATUS NUMBER,
	P_returncode out nocopy number);

--
-- Procedure
--   Update_Validated_Sig
--
-- Purpose
--   Updates a row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Validated_Sig(
	P_SIG_ID NUMBER,
	P_STATUS NUMBER,
	P_returncode out nocopy number);

--
-- Procedure
--   Update_Sig_Error
--
-- Purpose
--   Creates a new row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Sig_Error(
	P_SIG_ID NUMBER,
	P_STATUS NUMBER,
        P_ERRBUF VARCHAR2,
	P_returncode out nocopy number);

--
-- Function
--  PSIG_Cert_To_ID
--
-- Purpose
--  Registers a PSIG cert if it isn't already there.
--
-- Returns: cert ID or -1 if not successful.
--
--

Function PSIG_Cert_To_ID(
        P_USER VARCHAR2) return number;

--
-- Procedure
--  Get_Requested_Signer
--
-- Purpose
--   Gets Requested Signer info for a sig.
--
-- Returns: -1 (for ID) if not successful.
--
--

Procedure Get_Requested_Signer( P_SIGNATURE_ID in Number,
				P_reqSignerType out nocopy Varchar2,
				P_reqSignerID out nocopy Varchar2);

--
-- Procedure
--   Authorize_Signature
--
-- Purpose
--   Determines if actual signer is authorized to sign for requested
-- signer.  E.g. Does the user have the desired responsibility. Updates
-- the WF_DIG_SIGS table.
--
-- Returns: .
--   Outcome = either "AUTHORIZED" or "FAILED".
--
--

Procedure Authorize_Signature(P_SIGNATURE_ID In Number,
			     P_OUTCOME out nocopy Varchar2);


--
-- Procedure
--  Get_SPI_Info
--
-- Purpose
--   Gets SPI info for a sig ID.
--
-- Returns: nulls if not successful.
--
--

Procedure Get_SPI_Info( P_SIGNATURE_ID in Number,
			P_Flavor out nocopy Varchar2,
			P_BSR out nocopy Varchar2,
			P_Verifier out nocopy Varchar2,
			P_Validator out nocopy Varchar2,
			P_CertMapper out nocopy Varchar2,
			P_Validator_Store out nocopy Varchar2,
			P_Validation_Mode out nocopy Varchar2,
			P_Signature_Format out nocopy Varchar2,
			P_Signature_Mode out nocopy Varchar2);
--
-- Procedure
--  Get_SPI_Info
--
-- Purpose
--   Gets SPI info for a Flavor.
--
-- Returns: nulls if not successful.
--
--

Procedure Get_SPI_Info( P_Flavor In Varchar2,
			P_BSR out nocopy Varchar2,
			P_Verifier out nocopy Varchar2,
			P_Validator out nocopy Varchar2,
			P_CertMapper out nocopy Varchar2,
                        P_Validator_Store out nocopy Varchar2,
                        P_Validation_Mode out nocopy Varchar2,
                        P_Signature_Format out nocopy Varchar2,
                        P_Signature_Mode out nocopy Varchar2);

--
-- Function
--   Get_Next_Sig_ID
--
-- Purpose
--   Yanks an ID off of the sequence WF_DIG_SIGS_S
--
-- Parameters
--
-- Returns: -1 if not successful.
--
--

Function Get_Next_Sig_ID return number;

--
--Bug No#3062359
--Function
--   Upload_Certificate
--
-- Purpose
--   Upload the given certificate data to the table
--
--Returns : ID or -1 if not successful
--
Function Upload_X509_Certificate(
				  p_cert clob,
				  p_cert_type varchar2,
  				  p_parent_cert_id number,
				  p_owner_id varchar2,
				  p_owner_domain varchar2,
				  p_valid varchar2,
				  p_sot_flag varchar2,
				  p_intermediate_flag varchar2,
				  p_fingerprint varchar2,
				  p_expire date,
				  p_security_group_id varchar2,
				  p_subjectdn varchar2,
				  p_issuer varchar2,
				  p_crl_url varchar2
				  )
                                return number;

--
--Bug No#3062359
-- Function
--   X509_ID_To_Cert
--
-- Purpose
--   get a certificate from the given id
--
-- Returns: certificate if certificate exists for the id
--
--
Function X509_ID_To_Cert(p_cert_id number)return CLOB;

--Bug No#3062359
-- Function
--   X509_Cert_To_ID
--
-- Purpose
--   get the id of the certificate of given fingerprint and certificate data
--
-- Returns: id if certificate of given fingerprint and certificate matches
--
Function X509_Cert_To_ID(
                         p_certificate clob,
			 p_fingerprint varchar2)
                         return number;

-- Function
--   Store_CRL
--
-- Purpose
--   Stores the given CRL into WF_Dig_Crls. If the CRL already exists
--   then the crl_id of the existing CRL is returned. Otherwise, the new
--   CRL is stored and the CRL_ID is returned
--
-- Returns CRL_ID
--

Function Store_CRL (P_validation_Mode In Number,
                    P_Issuer In Varchar2,
                    P_Toi In Date,
                    P_Ton In Date,
                    P_CRL In CLOB) return number;

--
-- Procedure
--   GetVerifyData
--
-- Purpose
--  Finds plaintext, Signature for a given Sig ID
--

Procedure GetVerifyData (SigID NUMBER,
			 PText out nocopy Clob,
			 Sig out nocopy Clob);

--
-- Procedure
--   Purge_Signature_By_Sig_ID
--
-- Purpose
--  Removes Signature for a given Signature ID
--

Procedure Purge_Signature_By_Sig_ID(SigID NUMBER);


--
-- Procedure
--   Purge_Signature_By_Obj_ID
--
-- Purpose
--  Removes Signature for a given Object ID
--

Procedure Purge_Signature_By_Obj_ID(Obj_Type varchar2, Obj_ID varchar2);

--
-- Procedure
--   Purge_Signature_By_Obj_ID
--
-- Purpose
--  Removes Signature for a given set of object ids
--

Procedure Purge_Signature_By_Obj_ID(Obj_Type varchar2,
				    Obj_IDs objid_tab_type);

END WF_Digital_Security_Private;

 

/
