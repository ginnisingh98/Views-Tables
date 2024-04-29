--------------------------------------------------------
--  DDL for Package Body EDR_SECURITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_SECURITY_UTIL" AS
/*  $Header: EDRSECWB.pls 120.1.12000000.1 2007/01/18 05:55:23 appldev ship $ */

PROCEDURE add_drop_policy (ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2,
                           ACTION IN VARCHAR2)
IS
  l_prod_schema varchar2(30);
  l_status varchar2(10);
  l_industry varchar2(10);
BEGIN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Parameter: '||ACTION);
  if (ACTION = 'ADD') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Adding security on the eRecords');

    --Bug 4440223: Start
    IF NOT FND_INSTALLATION.GET_APP_INFO('EDR', l_status, l_industry, l_prod_schema)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_RLS.ADD_POLICY('EDR', 'EDR_PSIG_DOCUMENTS', 'EDR_DOCUMENTS_VIEW',
    --    'APPS', 'EDR_POLICY_FUNCTION_PKG.PSIG_VIEW', 'SELECT');
    DBMS_RLS.ADD_POLICY
    (l_prod_schema,                       --object schema
     'EDR_PSIG_DOCUMENTS',                --object name
     'EDR_DOCUMENTS_VIEW',                --policy name
      null,                               --function schema
     'EDR_POLICY_FUNCTION_PKG.PSIG_VIEW', --policy function
     'SELECT');                           --statement types

    --DBMS_RLS.ADD_POLICY('EDR', 'EDR_PSIG_DOCUMENTS', 'EDR_DOCUMENTS_MODIFY',
    --    'APPS', 'EDR_POLICY_FUNCTION_PKG.PSIG_MODIFY', 'INSERT, UPDATE');
    DBMS_RLS.ADD_POLICY
    (l_prod_schema,                         --object schema
     'EDR_PSIG_DOCUMENTS',                  --object name
     'EDR_DOCUMENTS_MODIFY',                --policy name
     null,                                  --function schema
     'EDR_POLICY_FUNCTION_PKG.PSIG_MODIFY', --policy function
     'INSERT, UPDATE');                     --statement types

    --DBMS_RLS.ADD_POLICY('EDR', 'EDR_PSIG_DOCUMENTS', 'EDR_DOCUMENTS_DELETE',
    --    'APPS', 'EDR_POLICY_FUNCTION_PKG.PSIG_DELETE', 'DELETE');
    DBMS_RLS.ADD_POLICY
    (l_prod_schema,                         --object schema
     'EDR_PSIG_DOCUMENTS',                  --object name
     'EDR_DOCUMENTS_DELETE',                --policy name
     null,                                  --function schema
     'EDR_POLICY_FUNCTION_PKG.PSIG_DELETE', --policy function
     'DELETE');                             --statement types
    --Bug 4440223: End

  elsif (ACTION = 'DROP') then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Dropping security on the eRecords');
    DBMS_RLS.DROP_POLICY('EDR', 'EDR_PSIG_DOCUMENTS', 'EDR_DOCUMENTS_VIEW');
    DBMS_RLS.DROP_POLICY('EDR', 'EDR_PSIG_DOCUMENTS', 'EDR_DOCUMENTS_MODIFY');
    DBMS_RLS.DROP_POLICY('EDR', 'EDR_PSIG_DOCUMENTS', 'EDR_DOCUMENTS_DELETE');
  end if;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Modification of security on eRecords sucessfully completed');
END add_drop_policy;

--Bug 3187777: Start
--This function would strip the occurence of { } and \ from a string making sure
--that all escaping done for Oracle Text has been removed

FUNCTION STRIP_SPECIAL_CHAR(qry varchar2)
return varchar2
is
  nqry varchar2(100); -- normalized query word
begin
  nqry := replace(qry, '}}', '}');
  nqry := replace(nqry, '\\', '\');
  nqry := ltrim(nqry, '{');
  nqry := rtrim(nqry, '}');
  return nqry;
end STRIP_SPECIAL_CHAR;
--Bug 3187777: End

end edr_security_util;

/
