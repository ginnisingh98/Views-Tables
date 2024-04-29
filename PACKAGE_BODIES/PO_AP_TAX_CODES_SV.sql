--------------------------------------------------------
--  DDL for Package Body PO_AP_TAX_CODES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_TAX_CODES_SV" AS
/* $Header: POXPITXB.pls 120.2 2005/09/14 05:02:18 pchintal noship $ */

/*================================================================

  FUNCTION NAME: 	val_tax_name()

==================================================================*/
 FUNCTION val_tax_name(x_tax_name IN VARCHAR2) RETURN BOOLEAN
 IS

   l_progress    varchar2(3) := null;
   l_temp varchar2(1);
 BEGIN
    l_temp:='N';
    l_progress := '010';


    Select 'Y' into l_temp from  dual where exists
     (SELECT  MEANING, LOOKUP_CODE TAX_CLASSIFICATION_CODE
     FROM    FND_LOOKUPS
     WHERE   LOOKUP_TYPE =  'ZX_INPUT_CLASSIFICATIONS'
             AND     NVL(START_DATE_ACTIVE, SYSDATE) <= SYSDATE
             AND     NVL(END_DATE_ACTIVE, SYSDATE)  >= SYSDATE
             AND     ENABLED_FLAG = 'Y'
             AND  LOOKUP_CODE = x_tax_name
     UNION
     SELECT   MEANING, LOOKUP_CODE TAX_CLASSIFICATION_CODE
     FROM    FND_LOOKUPS
     WHERE   LOOKUP_TYPE = 'ZX_WEB_EXP_TAX_CLASSIFICATIONS'
             AND     ENABLED_FLAG = 'Y'
             AND     SYSDATE BETWEEN START_DATE_ACTIVE and
             NVL(END_DATE_ACTIVE,SYSDATE)
             AND  LOOKUP_CODE= x_tax_name);

    /* SELECT count(*)
     INTO x_temp
     FROM ap_tax_codes
    WHERE name = x_tax_name; */

   IF l_temp = 'Y'  THEN
      RETURN TRUE;  /*  success */
   ELSE
      RETURN FALSE; /* failure */
   END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
   WHEN others THEN
        po_message_s.sql_error('val_tax_name', l_progress, sqlcode);
        raise;
 END val_tax_name;

END PO_AP_TAX_CODES_SV;

/
