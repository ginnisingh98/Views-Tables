--------------------------------------------------------
--  DDL for Package Body RLM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_DRT_PKG" AS
/* $Header: RLMDRTPB.pls 120.0.12010000.3 2018/04/04 13:06:42 sunilku noship $*/

 l_package varchar2(33) DEFAULT 'RLM_DRT_PKG. ';

--
--- Implement log writer
--
  PROCEDURE write_log
    (message       IN         varchar2
	,stage	   IN	        varchar2) IS
  BEGIN

	if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
      	fnd_log.string(fnd_log.level_procedure,message,stage);
	end if;
  END write_log;

--
--- Procedure: RLM_TCA_DRC
--- For a given TCA Party, procedure subject it to pass the validation representing applicable constraint.
--- If the Party comes out of validation process successfully, then it can be MASKed otherwise error will be raised.
---

  PROCEDURE RLM_TCA_DRC
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'RLM_TCA_DRC';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);
  BEGIN

    -- .....
    write_log ('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');
    --
    ---- Check DRC rule# 1
    --
    BEGIN
	    --
		--- Check whether Open Schedule Header exists for the customer
		--
        l_count :=0;

        SELECT  1 into l_count
        FROM    rlm_schedule_headers_all rsh
        WHERE   rsh.process_status <> 5
        AND     schedule_source = 'MANUAL'
        AND     rsh.customer_id in
                 (select acc.cust_account_id from hz_parties hp, hz_cust_accounts acc
                 where hp.party_id = p_person_id and acc.party_id = hp.party_id and hp.party_type = 'PERSON')
        AND     rownum = 1;

		--
		--- If RLM schedule header is Open, then Customer person is referenced. Should not delete. Raise error.
		--
		if l_count > 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'RLM_DRC_CST_OP_SCH_EXISTS'
			  ,msgaplid => 662
			  ,result_tbl => result_tbl);
		end if;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL;

    END;
    --

    write_log ('Leaving:'|| l_proc,'30');
    -- .....


    ---- Check DRC rule# 2
    --
    BEGIN
	    --
		--- Check whether Interface Header exists for the customer
		--
        l_count :=0;

        SELECT  1 into l_count
        FROM    rlm_interface_headers_all rih
        WHERE   schedule_source = 'MANUAL'
        AND     rih.customer_id in
                 (select acc.cust_account_id from hz_parties hp, hz_cust_accounts acc
                 where hp.party_id = p_person_id and acc.party_id = hp.party_id and hp.party_type = 'PERSON')
        AND     rownum = 1;

		--
		--- If RLM Interface header, then Customer person is referenced. Should not delete. Raise error.
		--
		if l_count > 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'RLM_DRC_CST_SCH_INT_EXISTS'
			  ,msgaplid => 662
			  ,result_tbl => result_tbl);
		end if;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL;

    END;
    --

    write_log ('Leaving:'|| l_proc,'40');
    -- .....



  END RLM_TCA_DRC;
  -- .....

END RLM_DRT_PKG;


/
