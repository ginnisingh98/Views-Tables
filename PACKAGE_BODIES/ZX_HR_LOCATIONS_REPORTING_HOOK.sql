--------------------------------------------------------
--  DDL for Package Body ZX_HR_LOCATIONS_REPORTING_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_HR_LOCATIONS_REPORTING_HOOK" AS
/* $Header: zxlocreportingb.pls 120.4 2006/10/26 11:28:22 asengupt ship $*/


/*
** PROCEDURE : CREATE_KR_BIZ_LOCATION
**
** HISTORY   :
**   23-NOV-2005  Yoshimichi Konishi  Created.
**
** WHAT IT DOES :
** If an HR location code being created exists in eBTax reporting code table
** then eBTax synch hook does nothing.
** If the HR location code being created does not exist in eBTax reporting code,
** the synch hook will create a corresponding Reporting Code.
**
*/

PROCEDURE create_kr_biz_location (p_location_code IN VARCHAR2,
                                  p_style         IN VARCHAR2,
                                  p_country       IN VARCHAR2)
IS
   TYPE num15_tbl_type IS TABLE OF NUMBER(15);
  l_rowid               VARCHAR2(4000);
  l_reporting_code_id   NUMBER(15);
  l_reporting_type_id   num15_tbl_type;
  l_cnt_reporting_code  PLS_INTEGER;

BEGIN

  IF p_location_code IS NOT NULL
     AND
     (p_style IN ('KR', 'KR_GBL') OR (p_country = 'KR'))
  THEN

    l_cnt_reporting_code := 0;

    SELECT count(reporting_code_char_value)
    INTO   l_cnt_reporting_code
    FROM   zx_reporting_codes_b
    WHERE  reporting_code_char_value = p_location_code;

    IF l_cnt_reporting_code = 0 THEN
      SELECT reporting_type_id
      BULK COLLECT INTO   l_reporting_type_id
      FROM   zx_reporting_types_b
      WHERE  reporting_type_code = 'KR_BUSINESS_LOCATIONS';

    IF l_reporting_type_id IS NOT NULL
    THEN
      FOR i in Nvl(l_reporting_type_id.first,1)..Nvl(l_reporting_type_id.last,0) LOOP
        SELECT zx_reporting_codes_b_s.nextval
        INTO   l_reporting_code_id
        FROM   dual;


        ZX_REPORTING_CODES_PKG.INSERT_ROW (
        X_ROWID                        => l_rowid                      ,
        X_REPORTING_CODE_ID            => l_reporting_code_id          ,
        X_REPORTING_CODE_CHAR_VALUE    => p_location_code              ,
        X_REPORTING_CODE_NUM_VALUE     => NULL                         ,
        X_REPORTING_CODE_DATE_VALUE    => NULL                         ,
        X_REPORTING_TYPE_ID            => l_reporting_type_id(i)       ,
        X_EXCEPTION_CODE               => NULL                         ,
        X_EFFECTIVE_FROM               => sysdate                      ,
        X_EFFECTIVE_TO                 => NULL                         ,
        X_RECORD_TYPE_CODE             => 'USER_DEFINED'               ,
        X_REQUEST_ID                   => fnd_global.conc_request_id   ,
        X_PROGRAM_LOGIN_ID             => fnd_global.conc_login_id     ,
        X_REPORTING_CODE_NAME          => p_location_code              ,
        X_CREATION_DATE                => sysdate                      ,
        X_CREATED_BY                   => fnd_global.user_id           ,
        X_LAST_UPDATE_DATE             => sysdate                      ,
        X_LAST_UPDATED_BY              => fnd_global.user_id           ,
        X_LAST_UPDATE_LOGIN            => fnd_global.user_id           ,
        X_PROGRAM_APPLICATION_ID       => fnd_global.prog_appl_id      ,
        X_PROGRAM_ID                   => fnd_global.conc_program_id   ,
        X_OBJECT_VERSION_NUMBER        => 1);
      END LOOP;
     END IF;
    END IF;
  END IF;
END create_kr_biz_location;


/*
** PROCEDURE : UPDATE_KR_BIZ_LOCATION
**
** HISTORY   :
**   23-NOV-2005  Yoshimichi Konishi  Created.
**
** WHAT IT DOES :
** eBTax reporting codes created from HR location through synchronization hook
** call is used by user when user associates reporting codes with eBTax tax rate
** codes. Therefore when user updates HR location code, eBTax synch program will
** check if there is an associated tax rate code exists for the location being
** updated. If there is an associated tax rate code, eBTax hook shows user an
** error message and it will not allow user to update location_code. User needs
** to create a new location in this situation.
**
** [ CASE 1 ]
** When user updates location_code with a new code that does not exist in eBTax
** reporting code table and the former location_code being updated is not
** associated with tax rate code, eBTax synch hook creates a new reporting code
** and deletes the Reporting Code of the former Location Code
**
** i.e.
** LOC_A  -> LOC_B
** LOC_A is not associated with rates.
** LOC_B does not exist in reporting code
**
**
** [ CASE 2 ]
** When user updates location_code with the new code which does not exist in
** eBTax reporting code table and the location_code being updated is associated
** with tax rate code, eBTax synch hook shows user an error message and user
** will not be able to update location_code.
**
** i.e.
** LOC_A  -> LOC_B
** LOC_A is associated with rates.
** LOC_B does not exist in reporting code
**
** [ CASE 3]
** When user updates location_code with a code that already exists in eBTax
** reporting code table and the former location_code being updated is not
** associated with tax rate code, eBTax synch hook deletes former location_code
** being updated.
**
** i.e.
** LOC_A  -> LOC_B
** LOC_A is not associated with rates.
** LOC_B exists in reporting code
**
**
** [ CASE 4 ]
** When user updates location_code with a code that already exists in eBTax
** reporting code table and the former location_code being updated is associated
** with tax rate code, eBTax synch hook shows users an error message and user
** will not be able to update location_code.
**
** i.e.
** LOC_A  -> LOC_B
** LOC_A is associated with rates.
** LOC_B exists in reporting code
**
*/
PROCEDURE update_kr_biz_location (p_location_code   IN VARCHAR2,
                                  p_location_code_o IN VARCHAR2,
                                  p_country         IN VARCHAR2,
                                  p_location_id     IN NUMBER)
IS
  TYPE num15_tbl_type IS TABLE OF NUMBER(15);

  l_reporting_code_id_tbl  num15_tbl_type;
  l_rowid                  VARCHAR2(4000);
  l_reporting_code_id      NUMBER(15);
  l_reporting_type_id      num15_tbl_type;
  l_cnt_assoc_rep_codes    PLS_INTEGER;
  l_cnt_rep_codes          PLS_INTEGER;
  l_address_style          VARCHAR2(7);

BEGIN


  SELECT style
  INTO   l_address_style
  FROM   hr_locations_all
  WHERE  location_id = p_location_id;

  IF p_location_code IS NOT NULL
     AND (p_country = 'KR' OR l_address_style IN ('KR', 'KR_GLB'))
     AND p_location_code <> p_location_code_o
  THEN

    l_cnt_rep_codes := 0;

    SELECT reporting_type_id
    BULK COLLECT INTO   l_reporting_type_id
    FROM   zx_reporting_types_b
    WHERE  reporting_type_code = 'KR_BUSINESS_LOCATIONS';

 IF l_reporting_type_id is not null
 then
    FOR k in Nvl(l_reporting_type_id.first,1)..Nvl(l_reporting_type_id.last,0) LOOP

    SELECT count(reporting_code_char_value)
    INTO   l_cnt_rep_codes
    FROM   zx_reporting_codes_b
    WHERE  reporting_code_char_value = p_location_code
    AND    reporting_type_id = l_reporting_type_id(k);

    IF l_cnt_rep_codes = 0 THEN
      l_cnt_assoc_rep_codes := 0;
      -- Is reporting code associated with tax rate code?
      SELECT count(reporting_code_char_value)
      INTO   l_cnt_assoc_rep_codes
      FROM   zx_report_codes_assoc
      WHERE  reporting_code_char_value = p_location_code_o
      AND    reporting_type_id = l_reporting_type_id(k);

      IF l_cnt_assoc_rep_codes = 0 THEN
        -- CASE 1 : Insert and delete
        SELECT zx_reporting_codes_b_s.nextval
        INTO   l_reporting_code_id
        FROM   dual;

        ZX_REPORTING_CODES_PKG.INSERT_ROW (
        X_ROWID                        => l_rowid                      ,
        X_REPORTING_CODE_ID            => l_reporting_code_id          ,
        X_REPORTING_CODE_CHAR_VALUE    => p_location_code              ,
        X_REPORTING_CODE_NUM_VALUE     => NULL                         ,
        X_REPORTING_CODE_DATE_VALUE    => NULL                         ,
        X_REPORTING_TYPE_ID            => l_reporting_type_id(k)          ,
        X_EXCEPTION_CODE               => NULL                         ,
        X_EFFECTIVE_FROM               => sysdate                      ,
        X_EFFECTIVE_TO                 => NULL                         ,
        X_RECORD_TYPE_CODE             => 'USER_DEFINED'               ,
        X_REQUEST_ID                   => fnd_global.conc_request_id   ,
        X_PROGRAM_LOGIN_ID             => fnd_global.conc_login_id     ,
        X_REPORTING_CODE_NAME          => p_location_code              ,
        X_CREATION_DATE                => sysdate                      ,
        X_CREATED_BY                   => fnd_global.user_id           ,
        X_LAST_UPDATE_DATE             => sysdate                      ,
        X_LAST_UPDATED_BY              => fnd_global.user_id           ,
        X_LAST_UPDATE_LOGIN            => fnd_global.user_id           ,
        X_PROGRAM_APPLICATION_ID       => fnd_global.prog_appl_id      ,
        X_PROGRAM_ID                   => fnd_global.conc_program_id   ,
        X_OBJECT_VERSION_NUMBER        => 1);

        SELECT reporting_code_id
        BULK COLLECT INTO
               l_reporting_code_id_tbl
        FROM   zx_reporting_codes_b
        WHERE  reporting_code_char_value = p_location_code_o  --NOTE
        AND    reporting_type_id = l_reporting_type_id(k);

        FORALL i IN 1..l_reporting_code_id_tbl.count
          DELETE FROM zx_reporting_codes_tl
          WHERE  reporting_code_id = l_reporting_code_id_tbl(i);

        FORALL j IN 1..l_reporting_code_id_tbl.count
          DELETE FROM zx_reporting_codes_b
          WHERE  reporting_code_id = l_reporting_code_id_tbl(j);
      ELSE
        -- CASE 2 : Raise an error
        fnd_message.set_name('ZX', 'ZX_HR_KR_LOC_UPD_NOT_ALLOWED');
        app_exception.raise_exception;
      END IF;
    ELSE
      l_cnt_assoc_rep_codes := 0;
      -- Is reporting code associated with tax rate code?
      SELECT count(reporting_code_char_value)
      INTO   l_cnt_assoc_rep_codes
      FROM   zx_report_codes_assoc
      WHERE  reporting_code_char_value = p_location_code_o
      AND    reporting_type_id = l_reporting_type_id(k);

      IF l_cnt_assoc_rep_codes = 0 THEN
        -- CASE 3 : Delete old reporting_code
        SELECT reporting_code_id
        BULK COLLECT INTO
               l_reporting_code_id_tbl
        FROM   zx_reporting_codes_b
        WHERE  reporting_code_char_value = p_location_code_o
        AND    reporting_type_id = l_reporting_type_id(k);

        FORALL i IN 1..l_reporting_code_id_tbl.count
          DELETE FROM zx_reporting_codes_tl
          WHERE  reporting_code_id = l_reporting_code_id_tbl(i);

        FORALL j IN 1..l_reporting_code_id_tbl.count
          DELETE FROM zx_reporting_codes_b
          WHERE  reporting_code_id = l_reporting_code_id_tbl(j);
      ELSE
        -- CASE 4 : Raise an error
        fnd_message.set_name('ZX', 'ZX_HR_KR_LOC_UPD_NOT_ALLOWED');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
   END IF;
  END IF;


END update_kr_biz_location;


/*
** PROCEDURE : DELETE_KR_BIZ_LOCATION
**
** HISTORY   :
**   23-NOV-2005  Yoshimichi Konishi  Created.
**
** WHAT IT DOES :
** Same as updating location_code, eBTax synch hook will check if the location
** being deleted is associated with eBTax tax rate codes. If it is associated
** then eBTax synch hook does not allow user to delete the location. If it is
** not associated, the hook will delete the corresponding Reporting Code.
**
*/
PROCEDURE delete_kr_biz_location (p_location_code_o IN VARCHAR2,
                                  p_style_o         IN VARCHAR2,
                                  p_country_o       IN VARCHAR2)
IS
  TYPE num15_tbl_type IS TABLE OF NUMBER(15);

  l_reporting_code_id_tbl  num15_tbl_type;
  l_cnt_assoc_rep_codes    PLS_INTEGER;

BEGIN
  IF p_location_code_o IS NOT NULL
     AND
     (p_style_o IN ('KR', 'KR_GBL') OR (p_country_o = 'KR'))
  THEN
    -- Is reporting code associated with tax rate code?
    SELECT count(reporting_code_char_value)
    INTO   l_cnt_assoc_rep_codes
    FROM   zx_report_codes_assoc
    WHERE  reporting_code_char_value = p_location_code_o
    AND    reporting_type_id in (SELECT reporting_type_id
                                FROM   zx_reporting_types_b
                                WHERE  reporting_type_code = 'KR_BUSINESS_LOCATIONS');

    IF l_cnt_assoc_rep_codes = 0 THEN
      SELECT reporting_code_id
      BULK COLLECT INTO
             l_reporting_code_id_tbl
      FROM  zx_reporting_codes_b
      WHERE reporting_code_char_value = p_location_code_o;
    IF l_reporting_code_id_tbl IS NOT NULL
    THEN
      FORALL i IN 1..l_reporting_code_id_tbl.count
        DELETE FROM zx_reporting_codes_tl
        WHERE  reporting_code_id = l_reporting_code_id_tbl(i);

      FORALL j IN 1..l_reporting_code_id_tbl.count
        DELETE FROM zx_reporting_codes_b
        WHERE  reporting_code_id = l_reporting_code_id_tbl(j);
    ELSE
       fnd_message.set_name('ZX', 'ZX_HR_KR_LOC_DEL_NOT_ALLOWED');
       app_exception.raise_exception;
    END IF;
   END IF;
  END IF;
END delete_kr_biz_location;

END zx_hr_locations_reporting_hook;

/
