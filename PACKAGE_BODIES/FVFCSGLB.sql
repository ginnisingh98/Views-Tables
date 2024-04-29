--------------------------------------------------------
--  DDL for Package Body FVFCSGLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FVFCSGLB" as
--$Header: FVFCSGLB.pls 115.4 2002/03/06 14:14:19 pkm ship   $
Procedure Main 	(errbuf out varchar2,
		    		retcode out varchar2) IS
v_count		number;
v_message		Varchar2(255);
v_errbuf		Varchar2(255);
v_retcode		Varchar2(255);
v_sgl_inserted	number :=0;
begin

	FVFCSGL1.MAIN(v_errbuf,v_retcode);
		IF v_retcode = -1 THEN
			v_message := v_errbuf;
			v_retcode := 1;
			retcode  := v_retcode;
			errbuf := v_message;
			ROLLBACK;
			return;
		ELSE
		null;
		END IF;
	FVFCSGL2.MAIN(v_errbuf,v_retcode);
		IF v_retcode = -1 THEN
			v_message := v_errbuf;
			v_retcode := 1;
			retcode  := v_retcode;
			errbuf := v_message;
			ROLLBACK;
			return;
		ELSE
			select count(*)
			into v_sgl_inserted
			from fv_facts_ussgl_accounts;

			v_message := v_sgl_inserted||' - '||'US SGL Accounts Succesfully Created';
			errbuf := v_message;
		END IF;

Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := 1;
END;
End;

/
