--------------------------------------------------------
--  DDL for Package Body PER_ISETUP_MIGRATOR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ISETUP_MIGRATOR_UTIL" as
/* $Header: perisetmigutil.pkb 115.4 2004/07/28 05:56 balchand noship $ */

PROCEDURE apps_initialise IS
l_rowcount NUMBER;
	 CURSOR csr_row IS
              select 1
	      from fnd_Sessions
              where session_id = userenv('sessionid') and to_char(effective_date,'DD-MM-YYYY') = to_char(sysdate,'DD-MM-YYYY');

begin

  --select count(*) into number_of_columns from all_tab_columns where table_name like 'FND_SESSIONS' ;
  OPEN  csr_row;
  FETCH csr_row INTO l_rowcount;

  if csr_row%notfound  then
   insert into fnd_sessions(session_id,effective_date) values (userenv('sessionid'),sysdate);
  end if;

  CLOSE CSR_ROW;

exception
when others then
  hr_utility.trace(substr(SQLERRM,1,100));
  raise;
end apps_initialise;


END per_isetup_migrator_util;


/
