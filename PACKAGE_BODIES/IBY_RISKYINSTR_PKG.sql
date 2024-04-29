--------------------------------------------------------
--  DDL for Package Body IBY_RISKYINSTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_RISKYINSTR_PKG" as
/*$Header: ibyrkinb.pls 120.1.12010000.2 2008/07/29 05:52:22 sugottum ship $*/


procedure delete_allRiskyInstr
is
begin
   delete from iby_irf_risky_instr;
commit;
end;

 /*
  ** Procedure: add_RiskyInstr
  ** Purpose: Appends/Adds the vector of RiskyInstr into the table. For
  ** each risky instrument, if it matches (payeeid,instrtype,and numbers)
  ** then does nothing, else adds it to table
  */
procedure add_RiskyInstr (i_count in integer,
			  i_riskyinstr in RiskyInstr_Table,
			  o_results out nocopy Result_Table)
is
  i int;
  l_payeeid varchar2(80);
  l_instrtype varchar2(80);
  l_payeecount int;
  l_instypecount int;
  l_riskinscount int;
  lx_cc_number iby_creditcard.ccnumber%TYPE;
  lx_return_status VARCHAR2(1);
  lx_msg_count     NUMBER;
  lx_msg_data      VARCHAR2(200);
  l_cc_hash1  iby_irf_risky_instr.cc_number_hash1%TYPE;
  l_cc_hash2  iby_irf_risky_instr.cc_number_hash2%TYPE;
  l_cc_number iby_creditcard.ccnumber%TYPE;
  l_account_no_hash1  iby_irf_risky_instr.acct_number_hash1%TYPE;
  l_account_no_hash2  iby_irf_risky_instr.acct_number_hash2%TYPE;
begin
       -- initialize the values.
       i := 1;
	--dbms_output.put_line('at beginning');

       -- loop through the list of ranges passed and update
       -- the database.
       while ( i <= i_count ) loop
	 -- extract the values fromt the database.
         l_payeeid   := i_riskyinstr(i).PayeeID;
         l_instrtype := i_riskyinstr(i).InstrType;

         SELECT COUNT(-1) INTO l_payeecount
            FROM iby_payee
	   WHERE payeeid = l_payeeid;

       	 SELECT COUNT(-1) INTO l_instypecount
            FROM fnd_lookups
	   WHERE lookup_type = 'IBY_INSTRUMENT_TYPES'
              and lookup_code = l_instrtype;

         IF ( l_payeecount <> 1 ) THEN
           o_results(i).success := 0;
           o_results(i).errmsg := 'IBY_204260';
         ELSIF (l_instypecount <> 1) then
  	   o_results(i).success := 0;
           o_results(i).errmsg := 'IBY_204261';
	 ELSIF (l_instrtype = 'CREDITCARD' and
                (i_riskyinstr(i).CreditCard_Num is null or
		i_riskyinstr(i).CreditCard_Num = '' )) then
	   o_results(i).success := 0;
           o_results(i).errmsg := 'IBY_204262';
	ELSIF (l_instrtype = 'BANKACCOUNT' and
                (i_riskyinstr(i).Routing_Num is null or
		 i_riskyinstr(i).Routing_Num = '' or
		 i_riskyinstr(i).Account_Num is null or
		  i_riskyinstr(i).Account_Num = '')) then
	   o_results(i).success := 0;
           o_results(i).errmsg := 'IBY_204263';
	 ELSE
	   IF ( l_instrtype = 'CREDITCARD' ) then
              -- Added for bug# 7228388
              -- Strip the symbols
              IBY_CC_VALIDATE.StripCC
              (1.0, FND_API.G_FALSE, i_riskyinstr(i).CreditCard_Num,
              IBY_CC_VALIDATE.c_FillerChars,
              lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number);
              -- Get hash values of the credit number
              l_cc_hash1 := iby_security_pkg.get_hash
                            (lx_cc_number,FND_API.G_FALSE);
              l_cc_hash2 := iby_security_pkg.get_hash
                            (lx_cc_number,FND_API.G_TRUE);
                SELECT COUNT(-1) INTO l_riskinscount
                FROM iby_irf_risky_instr
                WHERE payeeid = l_payeeid
                  and instrtype = l_instrtype
                  and cc_number_hash1 = l_cc_hash1
                  and cc_number_hash2 = l_cc_hash2;
                IF ( l_riskinscount = 0 )  then
                -- Included hash1 and hash2 values as part of bug#7228388
                 insert into iby_irf_risky_instr
                       (payeeid, instrtype,
                        creditcard_no, object_version_number,
                        last_update_date, last_updated_by,
                        creation_date, created_by, cc_number_hash1,
                        cc_number_hash2)
                  values ( l_payeeid, l_instrtype,
                        null,
                        1, sysdate, fnd_global.user_id,
                        sysdate, fnd_global.user_id, l_cc_hash1, l_cc_hash2);
                  o_results(i).success := 1;
                  if ( SQL%ROWCOUNT = 0 ) then
                  -- raise application error for the range it has failed.
                     o_results(i).success := 0;
                    o_results(i).errmsg := 'IBY_204264';
                  end if;
                ELSE
                     o_results(i).success := 0;
                     o_results(i).errmsg := 'IBY_204265';
                END IF;


	   ELSIF ( l_instrtype = 'BANKACCOUNT') then
               -- Get the hash values of the account number
                l_account_no_hash1 := iby_security_pkg.get_hash
                                  (i_riskyinstr(i).Account_Num,FND_API.G_FALSE);
                l_account_no_hash2 := iby_security_pkg.get_hash
                                  (i_riskyinstr(i).Account_Num,FND_API.G_TRUE);
	        SELECT COUNT(-1) INTO l_riskinscount
            	FROM iby_irf_risky_instr
	   	WHERE payeeid = l_payeeid
		  and instrtype = l_instrtype
                  and routing_no = i_riskyinstr(i).Routing_Num
		  and acct_number_hash1 = l_account_no_hash1
                  and acct_number_hash2 = l_account_no_hash2;

		IF ( l_riskinscount = 0 )  then
		 insert into iby_irf_risky_instr
	               (payeeid, instrtype, routing_no,
			account_no, object_version_number,
                	last_update_date, last_updated_by,
			creation_date, created_by,acct_number_hash1,
                        acct_number_hash2)
            	  values ( l_payeeid, l_instrtype,
			i_riskyinstr(i).Routing_Num,
			null,
                	1, sysdate, fnd_global.user_id,
			sysdate, fnd_global.user_id,l_account_no_hash1,
                        l_account_no_hash2);
  	          o_results(i).success := 1;
		  if ( SQL%ROWCOUNT = 0 ) then
                  -- raise application error for the range it has failed.
                     o_results(i).success := 0;
                     o_results(i).errmsg := 'IBY_204264';
            	  end if;
		ELSE
	     	     o_results(i).success := 0;
                     o_results(i).errmsg := 'IBY_204265';
                END IF;
	   END IF;
	END IF;
	i := i +1;
     end loop;
commit;
end;

 /*
  ** Procedure: delete_RiskyInstr
  ** Purpose: Delete the vector of RiskyInstr into the table. For
  ** each risky instrument, if it matches (payeeid,instrtype,and numbers)
  ** then delete the entry from table, else does nothing
  */
procedure delete_RiskyInstr (i_count in integer,
			     i_riskyinstr in RiskyInstr_Table,
			     o_results out nocopy Result_Table)
is
  i int;
  l_payeeid varchar2(80);
  l_instrtype varchar2(80);
  l_payeecount int;
  l_instypecount int;
  l_riskinscount int;
  lx_cc_number iby_creditcard.ccnumber%TYPE;
  lx_return_status VARCHAR2(1);
  lx_msg_count     NUMBER;
  lx_msg_data      VARCHAR2(200);
  l_cc_hash1  iby_irf_risky_instr.cc_number_hash1%TYPE;
  l_cc_hash2  iby_irf_risky_instr.cc_number_hash2%TYPE;
  l_cc_number iby_creditcard.ccnumber%TYPE;
  l_account_no_hash1  iby_irf_risky_instr.acct_number_hash1%TYPE;
  l_account_no_hash2  iby_irf_risky_instr.acct_number_hash2%TYPE;
begin
       -- initialize the values.
       i := 1;

       -- loop through the list of ranges passed and update
       -- the database.
       while ( i <= i_count ) loop
	 -- extract the values from the database.
         l_payeeid   := i_riskyinstr(i).PayeeID;
         l_instrtype := i_riskyinstr(i).InstrType;

         SELECT COUNT(-1) INTO l_payeecount
            FROM iby_payee
	   WHERE payeeid = l_payeeid;

       	 SELECT COUNT(-1) INTO l_instypecount
            FROM fnd_lookups
	   WHERE lookup_type = 'IBY_INSTRUMENT_TYPES'
              and lookup_code = l_instrtype;

         IF (l_payeecount <> 1) then
           o_results(i).success := 0;
           o_results(i).errmsg := 'IBY_204260';
         ELSIF (l_instypecount <> 1) then
  	   o_results(i).success := 0;
           o_results(i).errmsg := 'IBY_204261';
	 ELSE
	   IF (l_instrtype = 'CREDITCARD') then
              -- Included hash1 and hash2 values as part of bug#7228388
              -- Strip symbols from the credit card, if any
              IBY_CC_VALIDATE.StripCC
              (1.0, FND_API.G_FALSE, i_riskyinstr(i).CreditCard_Num,
              IBY_CC_VALIDATE.c_FillerChars,
              lx_return_status, lx_msg_count, lx_msg_data, lx_cc_number);
              -- Get hash values of the credit number
              l_cc_hash1 := iby_security_pkg.get_hash
                            (lx_cc_number,FND_API.G_FALSE);
              l_cc_hash2 := iby_security_pkg.get_hash
                            (lx_cc_number,FND_API.G_TRUE);
		Delete FROM iby_irf_risky_instr
	           WHERE payeeid = l_payeeid
		    and instrtype = l_instrtype
	            and cc_number_hash1 = l_cc_hash1
                    and cc_number_hash2 = l_cc_hash2;
  	          o_results(i).success := 1;
 		  if ( SQL%NOTFOUND ) then
                    o_results(i).success := 0;
                    o_results(i).errmsg := 'IBY_204266';
            	  end if;
	   ELSIF ( l_instrtype = 'BANKACCOUNT' ) then
                -- Included hash1 and hash2 values as part of bug#7228187
                -- Get hash values of the account number
                l_account_no_hash1 := iby_security_pkg.get_hash
                                (i_riskyinstr(i).Account_Num,FND_API.G_FALSE);
                l_account_no_hash2 := iby_security_pkg.get_hash
                                (i_riskyinstr(i).Account_Num,FND_API.G_TRUE);
		Delete FROM iby_irf_risky_instr
	   	WHERE payeeid = l_payeeid
		  and instrtype = l_instrtype
                  and routing_no = i_riskyinstr(i).Routing_Num
		  and acct_number_hash1 = l_account_no_hash1
                  and acct_number_hash2 = l_account_no_hash2;
  	          o_results(i).success := 1;
		  if ( SQL%NOTFOUND ) then
                     o_results(i).success := 0;
                     o_results(i).errmsg := 'IBY_204266';
             	  end if;
	    END IF;
	  END IF;
     i:= i+1;
     end loop;
commit;
end;

end iby_riskyinstr_pkg;

/
