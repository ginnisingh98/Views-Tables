--------------------------------------------------------
--  DDL for Package Body WF_DIGITAL_SECURITY_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIGITAL_SECURITY_PRIVATE" AS
/* $Header: WFDSPVTB.pls 120.2 2005/09/01 09:13:04 mputhiya ship $ */
-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------

/*      Bug 3110339: Remove constants from body
        STAT_ERROR              CONSTANT NUMBER :=  -1;
        STAT_REQUESTED          CONSTANT NUMBER := 100;
        STAT_SIGNED             CONSTANT NUMBER := 200;
        STAT_VERIFIED           CONSTANT NUMBER := 300;
        STAT_AUTHORIZED         CONSTANT NUMBER := 400;
        STAT_VAL_ATTEMPTED      CONSTANT NUMBER := 500;
        STAT_VALIDATED          CONSTANT NUMBER := 600;
        STAT_REQUEST_FAILED     CONSTANT NUMBER := -100;
        STAT_SIGN_FAILED        CONSTANT NUMBER := -200;
        STAT_SIGN_CANCELLED     CONSTANT NUMBER := -201;
        STAT_VERIFY_FAILED      CONSTANT NUMBER := -300;
        STAT_AUTHORIZE_FAILED   CONSTANT NUMBER := -400;
        STAT_VALIDATE_FAILED    CONSTANT NUMBER := -600;
*/

-----------------------------------------------------------------------------
-- Routines
-------------------------------------------------------------------------------
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
	P_returncode out nocopy number) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  begin
    insert into WF_DIG_SIGS
    (SIG_ID, SIG_OBJ_TYPE, SIG_OBJ_ID, PLAINTEXT,
	Requested_Signer_Type, Requested_Signer_ID,
        Sig_Flavor, Sig_Policy,
	STATUS, CREATION_DATE)
    select
    P_SIG_ID, P_SIG_OBJ_TYPE, P_SIG_OBJ_ID, P_PLAINTEXT,
	P_Requested_Signer_Type, P_Requested_Signer_ID,
        P_Sig_Flavor, P_Sig_Policy,
	P_STATUS, sysdate from dual;

    commit;

    P_returncode := 0;
  exception when others then P_returncode := -1;
    rollback;
  end;

--
-- Procedure
--   Update_Signed_Sig
--
-- Purpose
--   Updates row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Signed_Sig(
	P_SIG_ID NUMBER,
	P_SIGNATURE CLOB,
	P_STATUS NUMBER,
	P_Returncode out nocopy number) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  begin
    UPDATE WF_DIG_SIGS
    SET SIGNATURE = P_SIGNATURE,
        STATUS = P_STATUS,
        SIGNED_DATE = sysdate
    where SIG_ID = P_SIG_ID;

    commit;

    P_returncode := 0;
  exception when others then P_returncode := -1;
    rollback;
  end;

--
-- Procedure
--   Update_Verified_Sig
--
-- Purpose
--   Updates row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Verified_Sig(
	P_SIG_ID NUMBER,
	P_CERT_ID NUMBER,
	P_STATUS NUMBER,
	P_Returncode out nocopy number) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  begin
    UPDATE WF_DIG_SIGS
    SET CERT_ID = P_CERT_ID,
        STATUS = P_STATUS,
        VERIFIED_DATE = sysdate
    where SIG_ID = P_SIG_ID;

    commit;

    P_returncode := 0;
  exception when others then P_returncode := -1;
    rollback;
  end;

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
	P_Returncode out nocopy number) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  begin
    UPDATE WF_DIG_SIGS
    SET STATUS = P_STATUS,
        Last_Validation_Attempt = sysdate,
        Validated_complete_date = Decode(P_STATUS,
		WF_DIGITAL_SECURITY_PRIVATE.STAT_VALIDATED, sysdate, null)
    where SIG_ID = P_SIG_ID;

    commit;

    P_returncode := 0;
  exception when others then P_returncode := -1;
    rollback;
  end;

--
-- Procedure
--   Update_Sig_Error
--
-- Purpose
--   Updates a row in WF_DIG_SIGS
--
-- Returns: 0 for success; -1 if not successful.
--
--

Procedure Update_Sig_Error(
	P_SIG_ID NUMBER,
	P_STATUS NUMBER,
        P_ERRBUF VARCHAR2,
	P_Returncode out nocopy number) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  begin
    UPDATE WF_DIG_SIGS
    SET STATUS = P_STATUS,
        ERRBUF = to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || ': ' || P_ERRBUF,
        ERRSTACK = DECODE(ERRSTACK, NULL, ERRBUF,
			  	ERRBUF || WF_CORE.NEWLINE || ERRSTACK)
    where SIG_ID = P_SIG_ID;

    commit;

    P_returncode := 0;
  exception when others then P_returncode := -1;
    rollback;
  end;

--
-- Function
--  PSIG_Cert_to_ID
--
-- Purpose
--  Registers a PSIG cert if it isn't already there.
--
-- Returns: cert ID or -1 if not successful.
--
--

Function PSIG_Cert_To_ID(P_USER VARCHAR2) return number is

  PRAGMA AUTONOMOUS_TRANSACTION;

  MyCert_ID Number;

  begin
    begin
      select cert_id
      into mycert_id
      from wf_dig_certs
      where cert_type = 'PSIG'
      and fingerprint = P_User;
    exception
      when no_data_found then mycert_id := -1;
      when others then raise;
    end;

    if (mycert_id = -1) then

      insert into wf_dig_certs (cert,cert_id,cert_type,parent_cert_id,
      		owner_id, owner_domain, valid, sot_flag, intermediate_flag,
		fingerprint, expire)
	(select P_User, wf_dig_certs_s.nextval,'PSIG', wf_dig_certs_s.currval,
		U.User_ID, 'U', 'Y', 'Y', 'N', P_User, null
	   from fnd_user U
	  where user_name = P_User
	    and not exists
             (select cert_id
              from wf_dig_certs
      	      where cert_type = 'PSIG'
      		and fingerprint = P_User)
	);

      select cert_id
        into mycert_id
        from wf_dig_certs
       where cert_type = 'PSIG'
         and fingerprint = P_User;
    end if;

    commit;

    return MyCert_ID;

  exception when others then
    rollback;
    return -1;
  end;

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
                                P_reqSignerID out nocopy Varchar2) is

begin
   Select Requested_Signer_Type, Requested_Signer_ID
   into P_reqSignerType, P_reqSignerID
   From WF_Dig_Sigs
   Where P_Signature_ID = Sig_ID;
Exception
   when others then
	P_reqSignerType := ' ';
	P_reqSignerID := '-1';
End;

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
                             P_OUTCOME out nocopy Varchar2) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  MyStatus number := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZED;
  kount number := -1;
  act_cert_id number;
  act_type varchar2(30);
  act_id varchar2(320);
  act_emp_id varchar2(320);
  req_type varchar2(30);
  req_id varchar2(320);
  sig_date date;

  sec_grp_id number;
  resp_app_id number;
  resp_id number;
  str_buf varchar2(30);
  idx number;

  begin
    /* get info from sig table */
    Select Cert_ID, Requested_Signer_Type, Requested_Signer_ID, Signed_Date
      into act_cert_id, req_type, req_id, sig_date
      From WF_Dig_Sigs S
     where SIG_ID = P_SIGNATURE_ID;

    /* get info from cert table */
    Select Owner_domain, Owner_ID
      into act_type, act_id
      From WF_Dig_Certs
     where Cert_ID = act_cert_id;

    /* messy code to determine authorization. */
    if (req_type = 'W') then
      if (act_type = 'U') then
        Select EMPLOYEE_ID
          into act_emp_id
          from fnd_user
         where USER_ID = act_id;

        Select count(*)
          into kount
          From WF_User_Roles R
         where R.USER_ORIG_SYSTEM in ('FND_USR', 'PER')
           and R.USER_ORIG_SYSTEM_ID = to_number(
		decode(R.User_Orig_System, 'PER', act_emp_id,
				           'FND_USR', act_id,
						      '-999'))
           and R.ROLE_NAME = req_id;

        if (kount > 0) then
          mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZED;
        else
          mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED;
        end if;
      else
        mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED;
      end if;
    elsif (req_type = 'U') then
      if ((act_type = 'U') and (act_id = req_id)) then
        mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZED;
      else
        mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED;
      end if;
    elsif (req_type = 'R') then
      if (act_type = 'U') then
        /* Breakdown Req_id into secgrpid,respappid,respid */
        idx := instr(req_id,':');
        sec_grp_id := to_number(substr(req_id, 1, idx - 1));
        str_buf := substr(req_id, idx + 1);
        idx := instr(str_buf, ':');
        resp_app_id := to_number(substr(str_buf, 1, idx - 1));
        resp_id := to_number(substr(str_buf, idx + 1));

        Select count(*)
          into kount
          From Fnd_User_Resp_Groups R
         where R.USER_ID = resp_id
           and R.RESPONSIBILITY_APPLICATION_ID = resp_app_id
           and R.SECURITY_GROUP_ID = sec_grp_id
           and R.Responsibility_ID = to_number(req_id)
           and NVL(R.Start_date, sig_date) <= sig_date
           and NVL(R.End_date, sig_date) >= sig_date;

        if (kount > 0) then
          mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZED;
        else
          mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED;
        end if;
      else
        mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED;
      end if;
    else
      mystatus := WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED;
    end if;

    /* update the table */
    UPDATE WF_DIG_SIGS
    SET STATUS = MyStatus
    where SIG_ID = P_SIGNATURE_ID;

    /* let calling code know what happened */
    if (MyStatus = WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZED) then
      P_Outcome := 'AUTHORIZED';
    else
      P_Outcome := 'FAILED';
    end if;

    commit;

  exception when others then P_Outcome := 'FAILED';

    UPDATE WF_DIG_SIGS
    SET STATUS = WF_DIGITAL_SECURITY_PRIVATE.STAT_AUTHORIZE_FAILED
    where SIG_ID = P_SIGNATURE_ID;
    commit;
  end;

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
                        P_Signature_Mode out nocopy Varchar2) is
begin
   Select Sig_Flavor
   into P_Flavor
   From WF_Dig_Sigs
   Where P_Signature_ID = Sig_ID;

   Get_SPI_Info(P_Flavor, P_BSR, P_Verifier, P_Validator, P_CertMapper,
        P_Validator_Store, P_Validation_Mode,
	P_Signature_Format, P_Signature_Mode);

Exception
   when others then
	P_Flavor := null;
	P_BSR := null;
	P_Verifier := null;
	P_Validator := null;
	P_CertMapper := null;
        P_Validator_Store := null;
        P_Validation_Mode := null;
        P_Signature_Format := null;
        P_Signature_Mode := null;
End;

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
                        P_Signature_Mode out nocopy Varchar2) is
begin
   Select BSR_SPI, Verify_SPI, Validate_SPI, Cert_Mapper, Validator_Store,
	Validation_Mode, Signature_Format, Signature_Mode
   into P_BSR, P_Verifier, P_Validator, P_CertMapper, P_Validator_Store,
	P_Validation_Mode, P_Signature_Format, P_Signature_Mode
   From WF_Dig_Sig_SPI_Flavors
   Where P_Flavor = Flavor;

Exception
   when others then
	P_BSR := null;
	P_Verifier := null;
	P_Validator := null;
	P_CertMapper := null;
        P_Validator_Store := null;
        P_Validation_Mode := null;
        P_Signature_Format := null;
        P_Signature_Mode := null;
End;


--
-- Function
--   Get_Next_Sig_ID
--
-- Purpose
--   Yanks an ID off of the sequence WF_DIG_SIGS_S
--
-- Returns: ID or -1 if not successful.
--
--

Function Get_Next_Sig_ID return number is
  PRAGMA AUTONOMOUS_TRANSACTION;

  nextID number := -1;

  begin
   begin
    SELECT WF_DIG_SIGS_S.nextval
	into nextID
      from dual;
    exception when others then null;
   end;

   return nextID;

  end;

-- Procedure
--   UPDATE_CRL_URL
--
-- Purpose
--   update the crl url of the ca. if the same url is found then no updates
--   are made
--
--
Procedure UPDATE_CRL_URL(p_ca_name varchar2,p_crl_url varchar2) as

        v_ca_name varchar2(255);
        v_crl_url varchar2(255);
BEGIN

  --if the crl url is not null then do the operations
  if(p_crl_url is not null) then
  --check whether the corresponding CA name and CA_URL exists
        SELECT ca_name, ca_url
          INTO v_ca_name, v_crl_url
          FROM wf_dig_cas
         WHERE ca_name = p_ca_name
           and ca_url = p_crl_url;
END if;

--if url exists do nothing. else insert an entry
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   INSERT INTO wf_dig_cas (ca_name,ca_url)
   VALUES(p_ca_name,p_crl_url);
   commit;
end;

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
                                return number
                                as

      seqVal number;
      v_fingerprint varchar2(100);
      existing_certid number;
      v_user_id varchar2(255);
      existing_userid varchar2(255);

      BEGIN

        --If the owner_id is 'CA' then set the user_id as CA itself since
        --this is a CA certificate and may not contain the corresponding user

        if (p_owner_id = 'CA') then
	      v_user_id := p_issuer;
	      UPDATE_CRL_URL(p_issuer,p_crl_url);
	else
          -- get the user_id corresponding to the fnd_user. If the user_name
          -- does not exist, then it throws a no_data_found exception, which
          -- is captured and -2 is returned
          select user_id into v_user_id
            from fnd_user
           where user_name = p_owner_id;
        end if;

        -- check whether the certificate exists
	existing_certid := X509_Cert_To_ID(P_CERT,P_FINGERPRINT);

        -- if certificate already exists then check whether the certificate
        -- is associated with the same user .if it is , then return back the
	-- existing cert_id else return -1
	if (existing_certid <> -1) then
   	        SELECT owner_id
                  INTO existing_userid
	 	  FROM wf_dig_certs
		 WHERE cert_id = existing_certid;

          if (existing_userid = v_user_id) then
  	     return existing_certid;
	  else
             return -1;
          end if;
        end if;

        --get the next value from the sequence for the cert_id
        SELECT wf_dig_certs_s.nextval
	  INTO seqVal
          FROM DUAL;

        --insert the certificate into the table
	insert into WF_DIG_CERTS(CERT, CERT_ID, CERT_TYPE, PARENT_CERT_ID,
                  OWNER_ID, OWNER_DOMAIN, VALID, SOT_FLAG,
                  INTERMEDIATE_FLAG, FINGERPRINT, EXPIRE,
                  SECURITY_GROUP_ID, SUBJECTDN)
           values( p_cert, seqVal, p_cert_type, p_parent_cert_id,
                  v_user_id, p_owner_domain, p_valid, p_sot_flag,
                  p_intermediate_flag, p_fingerprint, p_expire,
                  p_security_group_id, p_subjectdn);
        return seqVal;

      exception
	when NO_DATA_FOUND then
		return -2;
	when others then
        raise;

      END;

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
Function X509_ID_To_Cert(
                         p_cert_id number)
                         return CLOB
                         as
      v_certificate CLOB;
      begin

            select
            CERT into v_certificate
            from
            WF_DIG_CERTS
            where CERT_TYPE='X509' and CERT_ID=p_cert_id;

            return v_certificate;

      end;
--
--Bug No#3062359
-- Function
--   X509_Cert_To_ID
--
-- Purpose
--   Gets the ID of the certificate of given fingerprint and certificate data
--
-- Returns:
--   ID if matching certificate found, -1 otherwise
--
Function X509_Cert_To_ID(P_Certificate clob, P_Fingerprint varchar2)
                         return number as

   --cursor for getting all the certificates with the given fingerprint
   cursor cert_cursor is
       select CERT_ID, CERT
         from WF_DIG_CERTS
        where CERT_TYPE = 'X509'
          and FINGERPRINT = P_Fingerprint;

   V_Certificate CLOB;
   V_Cert_ID Number;
   I Number;

Begin
   open cert_cursor;

   --loop until matching certificate found or the cursor is exhausted
   loop
      fetch cert_cursor into V_Cert_ID, V_Certificate;
      exit when Cert_Cursor%NOTFOUND;

      -- Compare the obtained certificate with the given certificate
      I := DBMS_LOB.Compare(V_Certificate, P_Certificate);

      --if comparison is success return the certificate id
      if (i = 0) then
          return V_Cert_ID;
      end if;
   end loop;

   close cert_cursor;

   --if no certificate found return -1
   return -1;
end;

-- Function
--   Store_CRL
--
-- Purpose
--   Stores the given CRL into WF_Dig_Crls. If the CRL already exists
--   then the crl_id of the existing CRL is returned. Otherwise, the new
--   CRL is stored and the CRL_ID is returned
--
-- Returns
--   CRL_ID
--

Function Store_CRL (P_validation_Mode In Number,
                    P_Issuer In Varchar2,
                    P_Toi In Date,
                    P_Ton In Date,
                    P_CRL In CLOB) return number AS

   /* Cursor for getting the values from CRL table */
   CURSOR CRL_Cursor IS
      SELECT CRL_ID, CRL_Data
        FROM WF_Dig_CRLS
       WHERE Issue_Date = P_Toi
         and Issuer = P_Issuer
         and Next_Issue_Date = P_Ton;

   V_SeqVal Number;
   V_CRL Clob;
   V_CRLID Number;

BEGIN

   open crl_cursor;
         loop
            /* get the crlid and crl value, exit when no value found. */
            fetch crl_cursor into v_crlid,v_crl;
            exit when crl_cursor%NOTFOUND;

            /* compare the value of the input crl and crl obtained from table
               if they are the same return the existing CRL_ID */
            if (dbms_lob.compare(V_CRL, P_CRL) = 0) then
                return V_CRLID;
            end if;
         end loop;
   close crl_cursor;

   /* No match found: Get the next sequence number */
   SELECT WF_DIG_SIGS_S.nextval into v_seqVal from dual;

   /* insert the data into the table */
   Insert Into WF_DIG_CRLS
        (CRL_ID, ISSUE_DATE, CRL_DATA, ISSUER, NEXT_ISSUE_DATE)
   Values (V_SeqVal, P_Toi, P_Crl, P_Issuer, P_Ton);

   Return V_SeqVal;

EXCEPTION
   when others then
        raise;
end;

--
-- Procedure
--   GetVerifyData
--
-- Purpose
--  Finds plaintext, Signature for a given Sig ID
--

Procedure GetVerifyData (SigID NUMBER,
                         PText out nocopy Clob,
                         Sig out nocopy Clob) is

begin
  Select Plaintext, Signature
    into PText, Sig
    from wf_dig_sigs
   where Sig_Id = SigID;

exception
  when others then
      Sig := Null;
      PText := Null;
end;

--
-- Procedure
--   Purge_Signature_By_Sig_ID
--
-- Purpose
--  Removes Signature for a given Signature ID
--

Procedure Purge_Signature_By_Sig_ID(SigID NUMBER) is

begin
  delete from wf_dig_sigs
   where Sig_ID = SigID;
end;

--
-- Procedure
--   Purge_Signature_By_Obj_ID
--
-- Purpose
--  Removes Signature for a given Object ID
--

Procedure Purge_Signature_By_Obj_ID(Obj_Type varchar2, Obj_ID varchar2) is

begin
  delete from wf_dig_sigs
   where SIG_OBJ_TYPE = Obj_Type
     and SIG_OBJ_ID =Obj_ID;
end;

--
-- Procedure
--   Purge_Signature_By_Obj_ID
--
-- Purpose
--  Removes Signature for a given set of object ids
--

Procedure Purge_Signature_By_Obj_ID(Obj_Type varchar2,
				    Obj_IDs objid_tab_type) is

  begin
    IF (Obj_IDs.count >0) then
	FORALL j IN Obj_IDs.FIRST..Obj_IDs.LAST
	   delete from wf_dig_sigs
            where SIG_OBJ_TYPE = Obj_Type
                and SIG_OBJ_ID =Obj_IDs(j);
     END IF;
   end;


END WF_Digital_Security_Private;

/
