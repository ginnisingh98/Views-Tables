--------------------------------------------------------
--  DDL for Package Body EGO_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DRT_PKG" AS
/* $Header: EGODRTPB.pls 120.0.12010000.5 2018/04/24 11:41:53 ksuleman noship $ */

l_package varchar2(33) DEFAULT 'EGO_DRT_PKG.';
--
--- Implement log writer
--
PROCEDURE write_log
  (message IN varchar2
   ,stage IN varchar2) IS
BEGIN
  if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
    fnd_log.string(fnd_log.level_procedure,message,stage);
  end if;
END write_log;

---
--- Procedure: EGO_TCA_DRC
--- For a given TCA Party, procedure subject it to pass through number of validation representing applicable constraints.
--- If the Party comes out of validation process successfully, then it can be deleted otherwise error will be raised.
---
PROCEDURE EGO_TCA_DRC
  (person_id IN varchar2
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'EGO_TCA_DRC';
  p_person_id number(20);
  l_count number;
BEGIN
  write_log ('Entering:'|| l_proc,'10');
  p_person_id := person_id;
  write_log ('p_person_id: '|| p_person_id,'20');

  BEGIN
    write_log ('starting check for EGO_ITEM_PEOPLE_INTF: '|| p_person_id,'20');

    l_count := 0;
    SELECT 1
	  INTO l_count
      FROM EGO_ITEM_PEOPLE_INTF
     WHERE GRANTEE_PARTY_ID = p_person_id
       AND ROWNUM = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'TCA'
		,status => 'E'
		,msgcode => 'EGO_DRC_IPPL_INTF_EXSITS'
		,msgaplid => 431
		,result_tbl => result_tbl
	  );
	end if;
  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      write_log ('p_person_id not exists in EGO_ITEM_PEOPLE_INTF','20');

    WHEN OTHERS THEN
      write_log ('In exceptions block EGO_ITEM_PEOPLE_INTF - when others : SQLCODE: ' || SUBSTR(SQLERRM, 1, 100),'20');
  END;

END EGO_TCA_DRC;

END EGO_DRT_PKG;

/
