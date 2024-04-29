--------------------------------------------------------
--  DDL for Package Body IGI_CHECK_VERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CHECK_VERSION" AS
-- $Header: igicverb.pls 115.10 2004/05/12 09:36:49 rgopalan ship $
/*===========================================================================+
 | FUNCTION                                                                  |
 |   IGI_CHECK_VER                                                           |
 | DESCRIPTION                                                               |
 |   This will populate the IGI_INST_VERSION table. It will be run during    |
 |   the autoupgrade process                                                 |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Public                                                             |
 |                                                                           |
 | PARAMETERS                                                                |
 |   NONE                                                                    |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE IGI_CHECK_VER is
-- DECLARE
   rowCnt number := 0;
   l_igi_opsfi_inst VARCHAR(1);
   l_igi_prev_ver VARCHAR(2);
   l_igi_igi_inst VARCHAR(1);

   -- Added for Bug 3431843
   l_schema            fnd_oracle_userid.oracle_username%TYPE;
   l_prod_status       fnd_product_installations.status%TYPE;
   l_industry          fnd_product_installations.industry%TYPE;
   l_igo               VARCHAR2(3);
   l_igi               VARCHAR2(3);

 BEGIN
-- Check IF previous installation of OPSFI

   l_igo := 'IGO';

   SELECT COUNT(1)
   INTO rowCnt
   FROM dba_users
   WHERE username = l_igo;

   IF (rowCnt > 0)
   THEN
     l_igi_opsfi_inst := 'Y';
--     DBMS_OUTPUT.PUT_LINE ('opsfi has previously been installed');
   ELSE
     l_igi_opsfi_inst := 'N';
--     DBMS_OUTPUT.PUT_LINE ('opsfi does not exist in this environment');
     RETURN;
   END IF;

-- Check for version (12, 31 or 33) installed
-- Bug 3431843 AKataria get ownername from fnd_installation
    IF NOT fnd_installation.get_app_info (application_short_name => 'IGL',
                        status                  => l_prod_status,
                        industry                => l_industry,
                        oracle_schema           => l_schema)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   rowCnt := 0;

   SELECT COUNT(1)
   INTO rowCnt
   FROM all_objects
   WHERE object_name = 'JE_UK_GCC_INST_OPTIONS_ALL'
   AND owner = l_schema; -- Bug 3431843 hkaniven

-- Bug 3431843 AKataria get ownername from fnd_installation
   IF NOT fnd_installation.get_app_info (application_short_name => 'IGI',
                        status                  => l_prod_status,
                        industry                => l_industry,
                        oracle_schema           => l_schema)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF (rowCnt > 0)
   THEN
       l_igi_prev_ver := NULL;
-- 31 or 33 version is now detected in script igi33syn.sql
       EXECUTE IMMEDIATE 'create synonym '||l_schema||'.opsfV31_33 for '||l_schema||'.igi_inst_version';
       EXECUTE IMMEDIATE 'create synonym '||l_schema||'.opsfV12_31_33 for '||l_schema||'.igi_inst_version';
   ELSE
     l_igi_prev_ver := '12';
       EXECUTE IMMEDIATE 'create synonym '||l_schema||'.opsfV12 for '||l_schema||'.igi_inst_version';
       EXECUTE IMMEDIATE 'create synonym '||l_schema||'.opsfV12_31_33 for '||l_schema||'.igi_inst_version';
   END IF;

--   DBMS_OUTPUT.PUT_LINE ('version found = '|| l_igi_prev_ver);

-- Check for the existance of the 11.5 environment

   rowCnt := 0;
   l_igi := 'IGI';

   SELECT COUNT(1)
   INTO rowCnt
   FROM dba_users
   WHERE username = l_igi;

   IF (rowCnt > 0)
   THEN
     l_igi_igi_inst := 'Y';
--     DBMS_OUTPUT.PUT_LINE ('IGI exists in this environment');
   ELSE
     l_igi_igi_inst := 'N';
--     DBMS_OUTPUT.PUT_LINE ('IGI does not exist in this environment');
   END IF;

-- Insert version into table
   insert INTO igi_inst_version
     (
     igi_opsfi_inst,
     igi_prev_ver,
     igi_igi_inst
     )
   values
     (
     l_igi_opsfi_inst,
     l_igi_prev_ver,
     l_igi_igi_inst
     );

  commit;
exception when others THEN
--DBMS_OUTPUT.PUT_LINE ('FAIL '|| SQLERRM);
    rollback;
  END IGI_CHECK_VER;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   IGI_CHECK_UPG                                                           |
 | DESCRIPTION                                                               |
 |   This will check the IGI_INST_VERSION table. It will RETURN the          |
 |   previous OPSF version used                                              |
 |                                                                           |
 | SCOPE                                                                     |
 |     -- Public                                                             |
 |                                                                           |
 | ARGUMENTS  : IN: VARCHAR(3) - '107', '110' or 'ALL'                       |
 |                                                                           |
 |              OUT:  None                                                   |
 |                                                                           |
 | RETURNS    : VARCHAR2 - '12', '31', '33' or a combination of these        |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

  FUNCTION igi_check_upg(coreVer IN VARCHAR2) RETURN VARCHAR2 is
 -- DECLARE
    l_igi_prev_ver VARCHAR2(2);
  BEGIN
    SELECT IGI_PREV_VER
    INTO l_igi_prev_ver
    FROM IGI_INST_VERSION;


--  DBMS_OUTPUT.PUT_LINE('this is version ' || l_igi_prev_ver);
  RETURN l_igi_prev_ver;

/* -- THIS CAN BE USED FOR TESTING!!!
  IF (coreVer = '107' AND l_igi_prev_ver = '12')
  THEN
     RETURN l_igi_prev_ver;
  ELSIF (coreVer = '110')
  THEN
    IF (l_igi_prev_ver = '31' OR l_igi_prev_ver = '33')
    THEN
      RETURN l_igi_prev_ver;
    ELSE
--      DBMS_OUTPUT.PUT_LINE('Unknown version in table');
      RETURN '??';
    END IF;
  ELSIF (coreVer = 'ALL')
  THEN
    IF (l_igi_prev_ver = '12' OR l_igi_prev_ver = '31' OR l_igi_prev_ver = '33')
    THEN
      RETURN l_igi_prev_ver;
    ELSE
--      DBMS_OUTPUT.PUT_LINE('Unknown version in table');
      RETURN '??';
    END IF;
  ELSE
--    DBMS_OUTPUT.PUT_LINE('Unknown argument passed!');
    RETURN '!!';
  END IF;
*/

  END igi_check_upg;
END;

/
