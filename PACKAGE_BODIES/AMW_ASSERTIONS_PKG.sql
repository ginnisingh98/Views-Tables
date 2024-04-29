--------------------------------------------------------
--  DDL for Package Body AMW_ASSERTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ASSERTIONS_PKG" as
/* $Header: amwtastb.pls 120.0 2005/05/31 19:51:29 appldev noship $ */

-- ===============================================================
-- Function name
--          ACCT_ASSERTIONS_PRESENT
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Assertion
-- ===============================================================
FUNCTION ACCT_ASSERTIONS_PRESENT (
    p_natural_account_id  IN         NUMBER,
    p_assertion_code      IN         VARCHAR2
) RETURN VARCHAR2
IS
n     number;
BEGIN
   select count(*)
   into n
   from amw_account_assertions
   where natural_account_id = p_natural_account_id
   and   assertion_code = p_assertion_code;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   ACCT_ASSERTIONS_PRESENT;


-- ===============================================================
-- Function name
--          ACCT_ASSERTIONS_PRESENT_MEAN
-- Purpose
-- 		    return translated meaning (Yes/No) to indicate the
--          selected(associated) Compliance Environment
-- ===============================================================
FUNCTION ACCT_ASSERTIONS_PRESENT_MEAN (
    p_natural_account_id  IN         NUMBER,
    p_assertion_code      IN         VARCHAR2
) RETURN VARCHAR2
IS
n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   select count(*)
   into n
   from amw_account_assertions
   where natural_account_id = p_natural_account_id
   and   assertion_code = p_assertion_code;

   select meaning
   into yes
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='Y';

   select meaning
   into no
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='N';

   if n > 0 then
       ---return 'Y';
       return yes;
   else
       ---return 'N';
       return no;
   end if;
END   ACCT_ASSERTIONS_PRESENT_MEAN;


-- ===============================================================
-- Procedure name
--          PROCESS_ACCT_ASSERTION_ASSOCS
-- Purpose
-- 		    Update the Account Assertion associations depending
--          on the specified p_select_flag .
-- ===============================================================
PROCEDURE PROCESS_ACCT_ASSERTION_ASSOCS (
                   p_select_flag         IN         VARCHAR2,
                   p_natural_account_id  IN         NUMBER,
                   p_assertion_code      IN         VARCHAR2
)
IS
      l_creation_date         date;
      l_created_by            number;
      l_last_update_date      date;
      l_last_updated_by       number;
      l_last_update_login     number;
      l_account_assertion_id  number;
      l_object_version_number number;

BEGIN
      delete from amw_account_assertions
      where natural_account_id = p_natural_account_id
	  and   assertion_code = p_assertion_code;

      if (p_select_flag = 'Y') then

          l_creation_date := SYSDATE;
          l_created_by := FND_GLOBAL.USER_ID;
          l_last_update_date := SYSDATE;
          l_last_updated_by := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.USER_ID;
          l_object_version_number := 1;

          select amw_account_assertion_s.nextval into l_account_assertion_id from dual;

          insert into amw_account_assertions (account_assertion_id,
                                              natural_account_id,
                                              assertion_code,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login,
                                              object_version_number)
          values (l_account_assertion_id,
                  p_natural_account_id,
                  p_assertion_code,
                  l_creation_date,
                  l_created_by,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_object_version_number);

       end if;
  EXCEPTION
  WHEN OTHERS THEN
    null;

END PROCESS_ACCT_ASSERTION_ASSOCS;

-- ----------------------------------------------------------------------
END AMW_ASSERTIONS_PKG;


/
