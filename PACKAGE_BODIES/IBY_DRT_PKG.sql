--------------------------------------------------------
--  DDL for Package Body IBY_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DRT_PKG" AS
/* $Header: ibydrtpkb.pls 120.0.12010000.3 2018/07/30 09:27:52 earao noship $ */
  l_package varchar2(33) DEFAULT 'IBY_DRT_PKG. ';
  --
  --- Implement log writer
  --
  PROCEDURE write_log
    (message       IN         varchar2
	,stage		 IN					varchar2) IS
  BEGIN

				if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
					fnd_log.string(fnd_log.level_procedure,message,stage);
				end if;
  END write_log;
  --
  --- Implement helper procedure add record corresponding to an error/warning/error
  --
/*  PROCEDURE add_to_results
    (person_id       IN         number
	,entity_type	 IN			varchar2
	,status 		 IN			varchar2
	,msgcode		 IN			varchar2
	,msgaplid		 IN			number
    ,result_tbl    	 IN OUT NOCOPY ap_drt_pkg.result_tbl_type) IS
	n number(15);
  begin
	n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
	--hr_utility.set_message(msgaplid,msgcode);
    result_tbl(n).msgaplid := msgaplid;
  end add_to_results;
*/
  --
  --- Implement Core AP specific DRC for TCA entity type
  --
  PROCEDURE iby_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'iby_tca_drc';
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
		--- Check if the party has debit authorization attachments
		--
      l_count := 0;
	begin
      select 1 into l_count
	  from fnd_Attached_documents
	  where ENTITY_NAME = 'MandateAttachmentEntity'
	  and PK1_VALUE in (select debit_authorization_id from
	  iby_debit_authorizations where DEBTOR_PARTY_ID in (select party_id from hz_parties where party_id=p_person_id)
	  );
	 EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count :=0;
      END;


      if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'IBY_DA_ATTCH_EXISTS'
			  ,msgaplid => 673
			  ,result_tbl => result_tbl);
      end if;


    END;
    --

  END iby_tca_drc;
END iby_drt_pkg;

/
