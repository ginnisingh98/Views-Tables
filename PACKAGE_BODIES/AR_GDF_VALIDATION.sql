--------------------------------------------------------
--  DDL for Package Body AR_GDF_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GDF_VALIDATION" AS
/* $Header: ARXGDVHB.pls 120.6.12010000.2 2008/11/20 07:21:04 npanchak ship $ */

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_gdf_valid                                                         |
 |                                                                         |
 | PUBLIC VARIABLES                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for global descriptive flex field validation   |
 |    during autoinvoice run.                                              |
 |                                                                         |
 |    The global descriptive flex field validation package                 |
 |    JG_ZZ_AUTO_INVOICE is installed only when JG is installed.           |
 |                                                                         |
 | ARGUMENTS                                                               |
 |    request_id        request_id of the autoinvoice run                  |
 |                                                                         |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |    ar_gdf_validation.is_gdf_valid(99999)                                |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    28-Aug-97  Srinivasan Jandyala   Created.                            |
 |    08-JAN-03  Bhushan Dhotkar     Bug 2446618 : Replaced the sys_context|
 |                                   ('JG','JGZZ_PRODUCT_CODE') with       |
 |                                   variable g_jgzz_product_code to avoid |
 |                                    multiple execution                   |
 +-------------------------------------------------------------------------*/

g_jgzz_product_code VARCHAR2(100);
l_org_id NUMBER := arp_global.sysparam.org_id;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION is_gdf_valid(request_id IN NUMBER)

	RETURN NUMBER IS

 /*-------------------------------+
  |  Global variable declarations |
  +-------------------------------*/

   TRUE  CONSTANT NUMBER  := 1;
   FALSE CONSTANT NUMBER  := 0;
   cr    CONSTANT char(1) := '
';

   return_value NUMBER := 0;
   is_there NUMBER := 0;
   lcursor  NUMBER;
   lignore  NUMBER;
   sqlstmt  VARCHAR2(254);

BEGIN

   arp_standard.enable_debug;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_valid: ' || cr || 'Global Descr Flex Field Validation begin: ' ||
                    to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   /* Check if JG_ZZ_AUTO_INVOICE package is installed */
   /* If JG_ZZ_AUTO_INVOICE is not installed, always return 1 */

/* ---------------------------------------------------------------------------
-- The following SQL will always return 1 because all the Globalization
-- packages are now installed even if any Globalizations are not active
-- We now use Application Context to verify if any Gloablizations are active
--
--   SELECT  distinct 1
--   INTO    is_there
--   FROM    all_source
--   WHERE   name = 'JL_ZZ_AUTO_INVOICE'
--   AND     type = 'PACKAGE BODY';
----------------------------------------------------------------------------*/
--  Bug 2446618

   IF g_jgzz_product_code IS NOT NULL THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('is_gdf_valid: ' || cr || 'Package: JG_ZZ_AUTO_INVOICE is installed.');
      END IF;

      /* JG_ZZ_AUTO_INVOICE package is installed, so OK to call it */

      BEGIN

          lcursor := dbms_sql.open_cursor;
          sqlstmt :=
'BEGIN :return_value:=JG_ZZ_AUTO_INVOICE.validate_gdff(:request_id);
END;';

          dbms_sql.parse(lcursor, sqlstmt, dbms_sql.native);
          dbms_sql.bind_variable(lcursor, ':request_id', request_id);
          dbms_sql.bind_variable(lcursor, ':return_value', return_value);

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('is_gdf_valid: ' || cr||'Executing Statement:'||cr||cr||sqlstmt);
          END IF;

          lignore := dbms_sql.execute(lcursor);
          dbms_sql.variable_value (lcursor, ':return_value', return_value);
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('is_gdf_valid: ' || 'Return value from JG_ZZ_AUTO_INVOICE.validate_gdff(): ' || return_value);
          END IF;
          dbms_sql.close_cursor(lcursor);

      EXCEPTION
	  WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('is_gdf_valid: ' || cr|| 'Exception calling JG_ZZ_AUTO_INVOICE.validate_gdff()');
	     arp_standard.debug('is_gdf_valid: ' || SQLERRM);
	  END IF;

          IF dbms_sql.is_open(lcursor)
          THEN
               dbms_sql.close_cursor(lcursor);
          END IF;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('is_gdf_valid: ' || cr || 'Global Descr Flex Field Validation end: ' || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
          END IF;

	  return(FALSE);
      END;

   ELSE

   -- Always return 1 if JG is not installed

      return_value := 1 ;

   END IF ;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_valid: ' || cr || 'Global Descr Flex Field Validation end: ' ||
                    to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   /* Always return TRUE if JG is not installed */

   return(return_value);

EXCEPTION

    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(cr|| 'Exception in AR_GDF_VALIDATION.is_gdf_valid()');
            arp_standard.debug('is_gdf_valid: ' || SQLERRM);
            arp_standard.debug('is_gdf_valid: ' || cr || 'Global Descr Flex Field Validation end: ' || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
         END IF;
         return(FALSE);

END is_gdf_valid;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_gdf_postbatch_valid                                               |
 |                                                                         |
 | PUBLIC VARIABLES                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for global descriptive flex field validation   |
 |    during postbatch run.                                                |
 |                                                                         |
 |    The global descriptive flex field validation package                 |
 |    JL_ZZ_POSTBATCH is installed only when JL is installed.              |
 |                                                                         |
 | ARGUMENTS                                                               |
 |    batch_id   IN NUMBER                                                 |
 |    cash_receipt_id IN NUMBER                                            |
 |                                                                         |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |    ar_gdf_validation.is_gdf_postbatch_valid(99999,99999)                |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    31-Aug-98  Nilesh Acharya             Created.                       |
 |    12-Aug-02  Ramakant Alat              Calling JL code based on       |
 |                                          context setting                |
 +-------------------------------------------------------------------------*/

FUNCTION is_gdf_postbatch_valid(batch_id IN NUMBER,
                                cash_receipt_id IN NUMBER)

RETURN NUMBER IS

 /*-------------------------------+
  |  Global variable declarations |
  +-------------------------------*/

   TRUE  CONSTANT NUMBER  := 1;
   FALSE CONSTANT NUMBER  := 0;
   cr    CONSTANT char(1) := '
';

   is_there NUMBER := 0;
   lcursor  NUMBER;
   lignore  NUMBER;
   sqlstmt  VARCHAR2(254);


BEGIN

   --arp_standard.enable_debug;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'Global Descr Flex Field Validation begin: ' ||
                            to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
      arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'batch_id= ' || batch_id ||
                            'cash_receipt_id= ' || cash_receipt_id);
   END IF;

   /* Check if JL_ZZ_POSTBATCH package is installed */
   /* If JL_ZZ_POSTBATCH is not installed, handle it in the exception */
   /***
   SELECT  distinct 1
   INTO    is_there
   FROM    all_source
   WHERE   name = 'JL_ZZ_POSTBATCH'
   AND     type = 'PACKAGE BODY';

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'Package: JL_ZZ_POSTBATCH is installed.');
   END IF;
   ***/

   /* JL_ZZ_POSTBATCH package is installed, so OK to call it */

   IF g_jgzz_product_code = 'JL' THEN

      BEGIN
	     JL_ZZ_POSTBATCH.populate_gdfs(p_cash_receipt_id=>cash_receipt_id,
		                               p_batch_id=>batch_id);

      EXCEPTION
          when OTHERS then
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('is_gdf_postbatch_valid: ' || cr|| 'Exception calling JL_ZZ_POSTBATCH.populate_gdfs()');
              arp_standard.debug('is_gdf_postbatch_valid: ' || SQLERRM(SQLCODE));
              arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
           END IF;

           return(FALSE);
      END;
    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'Global Descr Flex Field Validation end: ' ||
                    to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
    END IF;


    return(TRUE);

   EXCEPTION

        WHEN NO_DATA_FOUND THEN
            /* Always return TRUE if JL is not installed */
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('is_gdf_postbatch_valid: ' || 'Not running Global Validation, JL_ZZ_POSTBATCH NOT installed.');
               arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;
            return(TRUE);

        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(cr|| 'Exception in AR_GDF_VALIDATION.is_gdf_postbatch_valid()');
               arp_standard.debug('is_gdf_postbatch_valid: ' || SQLERRM);
               arp_standard.debug('is_gdf_postbatch_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;
            return(FALSE);

END is_gdf_postbatch_valid;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_gdf_taxid_valid                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for taxid and global flexfields validation     |
 |    for Globalizations.                                                  |
 |                                                                         |
 |    This package may exist as a stub, however for future implementation  |
 |    this has been integrated as a hook.                                  |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   request_id        IN NUMBER                                           |
 |   org_id            IN NUMBER                                           |
 |   sob               IN NUMBER                                           |
 |   user_id           IN NUMBER                                           |
 |   application_id    IN NUMBER                                           |
 |   language_id       IN NUMBER                                           |
 |   program_id        IN NUMBER                                           |
 |   prog_appl_id      IN NUMBER                                           |
 |   last_update_login IN NUMBER                                           |
 |                                                                         |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    09-Sep-98  Vikram Ahluwalia           Created.                       |
 |    14-Dec-98  Josie Gazmen-Dabir         Bug 776476:  replaced reference|
 |                                          to package JG_TAXID_VAL_PKG    |
 |                                          to use JG_GLOBE_FLEX_VAL for   |
 |					    customer interface.            |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION is_gdf_taxid_valid(request_id        IN NUMBER,
                            org_id            IN NUMBER,
                            sob               IN NUMBER,
                            user_id           IN NUMBER,
                            application_id    IN NUMBER,
                            language_id       IN NUMBER,
                            program_id        IN NUMBER,
                            prog_appl_id      IN NUMBER,
                            last_update_login IN NUMBER )
RETURN NUMBER IS

 /*-------------------------------+
  |  Global variable declarations |
  +-------------------------------*/

   TRUE  CONSTANT NUMBER  := 1;
   FALSE CONSTANT NUMBER  := 0;
   cr    CONSTANT char(1) := '
';

   is_there NUMBER := 0;
   lcursor  NUMBER;
   lignore  NUMBER;
   sqlstmt  VARCHAR2(254);

   /*Bug 3544086*/
   l_user_schema	VARCHAR2(30) := USER;

BEGIN

   --arp_standard.enable_debug;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_taxid_valid: ' || cr || 'Global Descr Flex Field Validation begin: ' ||
                            to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   /* Check if JG_GLOBE_FLEX_VAL package is installed */
   /* If JG_GLOBE_FLEX_VAL is not installed, handle it in the exception */

   SELECT  distinct 1
   INTO    is_there
   FROM    all_source
   WHERE   name = 'JG_GLOBE_FLEX_VAL'
   AND     type = 'PACKAGE BODY'
   AND     owner = l_user_schema;   /*Bug 3544086*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_taxid_valid: ' || cr || 'Package: JG_GLOBE_FLEX_VAL is installed.');
   END IF;

   /* JG_GLOBE_FLEX_VAL package is installed, so OK to call it */

   BEGIN

       lcursor := dbms_sql.open_cursor;
       sqlstmt :=
'BEGIN JG_GLOBE_FLEX_VAL.ar_cust_interface('|| request_id         || ','
                                           || org_id             || ','
                                           || sob                || ','
                                           || user_id            || ','
                                           || application_id     || ','
                                           || language_id        || ','
                                           || program_id         || ','
                                           || prog_appl_id       || ','
                                           || last_update_login  || '); END;';

       dbms_sql.parse(lcursor, sqlstmt, dbms_sql.native);

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('is_gdf_taxid_valid: ' || cr||'Executing Statement:'||cr||cr||sqlstmt);
       END IF;

       lignore := dbms_sql.execute(lcursor);

       dbms_sql.close_cursor(lcursor);

       EXCEPTION
           when OTHERS then
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('is_gdf_taxid_valid: ' || cr|| 'Exception calling JG_GLOBE_FLEX_VAL.ar_cust_interface()');
              arp_standard.debug('is_gdf_taxid_valid: ' || SQLERRM);
           END IF;

           IF dbms_sql.is_open(lcursor)
           THEN
                dbms_sql.close_cursor(lcursor);
           END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('is_gdf_taxid_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;

           return(FALSE);
   END;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_gdf_taxid_valid: ' || cr || 'Global Descr Flex Field Validation end: ' ||
                    to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   return(TRUE);

   EXCEPTION

        WHEN NO_DATA_FOUND THEN
            /* Always return TRUE if JG is not installed */
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('is_gdf_taxid_valid: ' || 'Not running Global Validation, JG_GLOBE_FLEX_VAL NOT installed.');
               arp_standard.debug('is_gdf_taxid_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;
            return(TRUE);

        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(cr|| 'Exception in AR_GDF_VALIDATION.is_gdf_taxid_valid()');
               arp_standard.debug('is_gdf_taxid_valid: ' || SQLERRM);
               arp_standard.debug('is_gdf_taxid_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;
            return(FALSE);

END is_gdf_taxid_valid;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_cust_imp_valid                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for taxid and global flexfields validation     |
 |    for Globalizations.                                                  |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   request_id        IN NUMBER                                           |
 |   org_id            IN NUMBER                                           |
 |   sob               IN NUMBER                                           |
 |   user_id           IN NUMBER                                           |
 |   application_id    IN NUMBER                                           |
 |   language_id       IN NUMBER                                           |
 |   program_id        IN NUMBER                                           |
 |   prog_appl_id      IN NUMBER                                           |
 |   last_update_login IN NUMBER                                           |
 |   int_table_name    IN VARCHAR2                                                                       |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    10-MAR-00  Chirag Mehta               Created.                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION is_cust_imp_valid(request_id        IN NUMBER,
                            org_id            IN NUMBER,
                            sob               IN NUMBER,
                            user_id           IN NUMBER,
                            application_id    IN NUMBER,
                            language_id       IN NUMBER,
                            program_id        IN NUMBER,
                            prog_appl_id      IN NUMBER,
                            last_update_login IN NUMBER,
                            int_table_name    IN VARCHAR2)
RETURN NUMBER IS

 /*-------------------------------+
  |  Global variable declarations |
  +-------------------------------*/

   TRUE  CONSTANT NUMBER  := 1;
   FALSE CONSTANT NUMBER  := 0;
   cr    CONSTANT char(1) := '
';

   is_there NUMBER := 0;
   lcursor  NUMBER;
   lignore  NUMBER;
   sqlstmt  VARCHAR2(254);

   /*Bug 3544086*/
   l_user_schema	VARCHAR2(30) := USER;

BEGIN

   --arp_standard.enable_debug;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_cust_imp_valid: ' || cr || 'Global Descr Flex Field Validation begin: ' ||
                            to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   /* Check if JG_GLOBE_FLEX_VAL package is installed */
   /* If JG_GLOBE_FLEX_VAL is not installed, handle it in the exception */

   SELECT  distinct 1
   INTO    is_there
   FROM    all_source
   WHERE   name = 'JG_GLOBE_FLEX_VAL'
   AND     type = 'PACKAGE BODY'
   AND     owner = l_user_schema;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_cust_imp_valid: ' || cr || 'Package: JG_GLOBE_FLEX_VAL is installed.');
   END IF;

   /* JG_GLOBE_FLEX_VAL package is installed, so OK to call it */

   BEGIN

       lcursor := dbms_sql.open_cursor;

if org_id is null then

if(int_table_name='CUSTOMER') then

       sqlstmt :=
'BEGIN JG_GLOBE_FLEX_VAL.ar_cust_interface('|| request_id         || ','
                                           || 'NULL'              || ','
                                           || sob                || ','
                                           || user_id            || ','
                                           || application_id     || ','
                                           || language_id        || ','
                                           || program_id         || ','
                                           || prog_appl_id       || ','
                                           || last_update_login  || ','
                                           ||'''CUSTOMER'''||'); END;';

elsif(int_table_name='PROFILE') then

       sqlstmt :=
'BEGIN JG_GLOBE_FLEX_VAL.ar_cust_interface('|| request_id         || ','
                                           || 'NULL'              || ','
                                           || sob                || ','
                                           || user_id            || ','
                                           || application_id     || ','
                                           || language_id        || ','
                                           || program_id         || ','
                                           || prog_appl_id       || ','
                                           || last_update_login  || ','
                                           ||'''PROFILE'''||'); END;';

end if;
else

if(int_table_name='CUSTOMER') then

       sqlstmt :=
'BEGIN JG_GLOBE_FLEX_VAL.ar_cust_interface('|| request_id         || ','
                                           || org_id             || ','
                                           || sob                || ','
                                           || user_id            || ','
                                           || application_id     || ','
                                           || language_id        || ','
                                           || program_id         || ','
                                           || prog_appl_id       || ','
                                           || last_update_login  || ','
                                           ||'''CUSTOMER'''||'); END;';

elsif(int_table_name='PROFILE') then

       sqlstmt :=
'BEGIN JG_GLOBE_FLEX_VAL.ar_cust_interface('|| request_id         || ','
                                           || org_id             || ','
                                           || sob                || ','
                                           || user_id            || ','
                                           || application_id     || ','
                                           || language_id        || ','
                                           || program_id         || ','
                                           || prog_appl_id       || ','
                                           || last_update_login  || ','
                                           ||'''PROFILE'''||'); END;';

end if;
end if;
       dbms_sql.parse(lcursor, sqlstmt, dbms_sql.native);

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('is_cust_imp_valid: ' || cr||'Executing Statement:'||cr||cr||sqlstmt);
       END IF;

       lignore := dbms_sql.execute(lcursor);

       dbms_sql.close_cursor(lcursor);

       EXCEPTION
           when OTHERS then
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('is_cust_imp_valid: ' || cr|| 'Exception calling JG_GLOBE_FLEX_VAL.ar_cust_interface()');
              arp_standard.debug('is_cust_imp_valid: ' || SQLERRM);
           END IF;

           IF dbms_sql.is_open(lcursor)
           THEN
                dbms_sql.close_cursor(lcursor);
           END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('is_cust_imp_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;

           return(FALSE);
   END;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('is_cust_imp_valid: ' || cr || 'Global Descr Flex Field Validation end: ' ||
                    to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   return(TRUE);

   EXCEPTION

        WHEN NO_DATA_FOUND THEN
            /* Always return TRUE if JG is not installed */
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('is_cust_imp_valid: ' || 'Not running Global Validation, JG_GLOBE_FLEX_VAL NOT installed.');
               arp_standard.debug('is_cust_imp_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;
            return(TRUE);

        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(cr|| 'Exception in AR_GDF_VALIDATION.is_cust_imp_valid()');
               arp_standard.debug('is_cust_imp_valid: ' || SQLERRM);
               arp_standard.debug('is_cust_imp_valid: ' || cr || 'Global Descr Flex Field Validation end: '
                                  || to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
            END IF;
            return(FALSE);

END is_cust_imp_valid;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |    copy_gdf_attributes                                                  |
 |                                                                         |
 | PUBLIC VARIABLES                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for copying global descriptive flex fields to  |
 |    to JG Tables from Autoinvoice and Copy Transactions.                 |
 |                                                                         |
 |    The global descriptive flex field copy package                       |
 |    JL_BR_SPED_PKG is installed only when JG is installed.               |
 |                                                                         |
 | ARGUMENTS                                                               |
 |    p_request_id        Request Id of Autoinvoice/Copy Transactions.     |
 |    p_called_from       Module Name of Autoinvoice/Copy Transactions.    |
 |                                                                         |
 | RETURNS                                                                 |
 |    None                                                                 |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |    ar_gdf_validation.copy_gdf_attributes(99999,'RAXTRX')                |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    26-Aug-08  Vijay Pusuluri   Created.                                 |
 +-------------------------------------------------------------------------*/

PROCEDURE copy_gdf_attributes(p_request_id IN NUMBER,
	p_called_from IN VARCHAR2) IS

 /*-------------------------------+
  |  Global variable declarations |
  +-------------------------------*/
   lcursor  NUMBER;
   lignore  NUMBER;
   sqlstmt  VARCHAR2(254);
   l_error  VARCHAR2(1000);
   l_return_value NUMBER;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ar_gdf_validation.copy_gdf_attributes()+');
   END IF;

   /* Check if JL_BR_SPED_PKG package is installed. */

  /* IF is_jg_installed IS NOT NULL THEN*/
    g_jgzz_product_code := FND_PROFILE.value('JGZZ_PRODUCT_CODE');
   IF g_jgzz_product_code IS NOT NULL THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('copy_gdf_attributes: Package: JL_BR_SPED_PKG is installed.');
      END IF;

      /* JL_BR_SPED_PKG package is installed, so OK to call the package. */

      BEGIN

          lcursor := dbms_sql.open_cursor;
          sqlstmt :=
		'BEGIN :l_return_value := JL_BR_SPED_PKG.copy_gdf_attributes(:p_request_id, :p_called_from);
		 END;';

          dbms_sql.parse(lcursor, sqlstmt, dbms_sql.native);
	  dbms_sql.bind_variable(lcursor, ':p_request_id', p_request_id);
          dbms_sql.bind_variable(lcursor, ':p_called_from', p_called_from);
	  dbms_sql.bind_variable(lcursor, ':l_return_value', l_return_value);

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('copy_gdf_attributes: Executing Statement: '||sqlstmt);
          END IF;

          lignore := dbms_sql.execute(lcursor);
          dbms_sql.close_cursor(lcursor);

      EXCEPTION
	  WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('copy_gdf_attributes: Exception calling BEGIN JL_BR_SPED_PKG.copy_gdf_attributes.');
	     arp_standard.debug('copy_gdf_attributes: ' || SQLERRM);
	     l_error := SQLERRM;
	     arp_standard.debug('ar_gdf_validation.copy_gdf_attributes()-');
	  END IF;
          IF dbms_sql.is_open(lcursor)
          THEN
               dbms_sql.close_cursor(lcursor);
          END IF;
      END;

   END IF ;

   IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug('ar_gdf_validation.copy_gdf_attributes()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
	     arp_standard.debug('copy_gdf_attributes: Exception calling BEGIN JL_BR_SPED_PKG.copy_gdf_attributes.');
	     arp_standard.debug('copy_gdf_attributes: ' || SQLERRM);
	     arp_standard.debug('ar_gdf_validation.copy_gdf_attributes()-');
         END IF;
END copy_gdf_attributes;


/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |  insert_global_table                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is module for insertion of address related 			   |
 |    records in globalization tables   				   |
 |    for Globalizations.                                                  |
 |									   |
 | ARGUMENTS                                                               |
 |   p_address_id      IN NUMBER                                           |
 |   p_contributor_class_code IN VARCHAR2                                  |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    11-JUNE-00  Chirag Mehta               Created.                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/



PROCEDURE insert_global_table(p_address_id             IN NUMBER,
                              p_contributor_class_code IN VARCHAR2) IS
BEGIN

/* Call Globalization's procedue */

JL_ZZ_AR_TX_LIB_PKG.populate_cus_cls_details(p_address_id,p_contributor_class_code);

END insert_global_table;

FUNCTION is_jg_installed RETURN VARCHAR2 IS
 BEGIN
         return FND_PROFILE.value('JGZZ_PRODUCT_CODE');
 END is_jg_installed;

BEGIN

 /* g_jgzz_product_code:= sys_context('JG','JGZZ_PRODUCT_CODE'); */

     g_jgzz_product_code := JG_ZZ_SHARED_PKG.GET_PRODUCT(l_org_id);


END AR_GDF_VALIDATION;

/
