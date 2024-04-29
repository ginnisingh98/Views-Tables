--------------------------------------------------------
--  DDL for Package Body FVFCATTB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCATTB" as
-- $Header: FVFCATTB.pls 115.5 2002/03/06 14:12:04 pkm ship      $
Procedure Main 	(errbuf out varchar2,
		retcode out varchar2,
		p_yes_no in varchar2) is
v_count			number;
v_message		Varchar2(500);
v_errbuf		Varchar2(255);
v_retcode		Varchar2(255);
v_attr_inserted		number :=0;
v_codes_inserted	number :=0;
v_accts_inserted  	number :=0;
begin

	FVFCATT1.MAIN(v_errbuf,v_retcode);
		IF v_retcode = -1 THEN
			v_message := v_errbuf;
			v_retcode := 1;
			retcode := v_retcode;
			errbuf := v_message;
			ROLLBACK;
			return;
		ELSE
		null;
		--	v_message := substr(v_errbuf,1,80);
		END IF;
	FVFCATT2.MAIN(v_errbuf,v_retcode);
		IF v_retcode = -1 THEN
			v_message := v_errbuf;
			v_retcode := 1;
			retcode := v_retcode;
			errbuf := v_message;
			ROLLBACK;
			return;
		ELSE
			select count(*)
			into v_attr_inserted
			from fv_facts_attributes;

		END IF;

	FVFCRT7B.MAIN(v_errbuf,v_retcode);
		IF v_retcode = -1 THEN
			v_message := v_errbuf;
			v_retcode := 1;
			retcode := v_retcode;
			errbuf := v_message;
			ROLLBACK;
			return;
		ELSE
			select count(*)
			into v_codes_inserted
			from fv_facts_rt7_codes;

			select count(*)
			into v_accts_inserted
			from fv_facts_rt7_accounts;

			v_message :='FACTS attributes  successfully created';
			if p_yes_no = 'N' then
				v_message := v_message||'-'||'FACTS II requires US SGL compliance if the
				natural account segment has been expanded to accomodate Agency specific
				requirements, designate a parent account that is 4-digit US SGL Account';
				retcode := 1;
			end if;
END IF;
errbuf := v_message;

COMMIT;
Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := 1;
END;
End;

/
