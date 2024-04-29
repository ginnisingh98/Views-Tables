--------------------------------------------------------
--  DDL for Package JAI_AR_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_TRX_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_trx.pls 120.6.12010000.2 2010/01/27 09:19:38 erma ship $ */

/*
--------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.1 jai_ar_trx -Object is Modified to refer to New DB Entity names in
             place of Old DB Entity Names as required for CASE COMPLAINCE.

23-06-2005   Version 116.2
             Ramananda for bug#4468353 due to ebtax uptake by AR

28/12/2005   4892111 Hjujjuru, File Version 120.3

              Modified the Hard Coded value of the tax 'Localization' to 'LOCALIZATION'
              in all its occurences

05-Jul-2006  Aiyer for the bug 5369250, Version  120.5
             Issue:-
               The concurrent failes with the following error :-
               "FDPSTP failed due to ORA-01861: literal does not match format string ORA-06512: at line 1 "

             Reason:-
               The procedure update_excise_invoice_no has two parameters p_start_date and p_end_date which are of type date , however the concurrent program
               passes it in the canonical format and hence the failure.

             Fix:-
              Modified the procedure update_excise_invoice_no.
              Changed the datatype of p_start_date and p_end_date from date to varchar2 as this parameter.
              Also added the new parameters ld_start_date and ld_end_date. The values in p_start_date and p_end_date would be converted to date format and
              stored in these local variables

             Dependency due to this fix:-
              None

-----------------------------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------
| Added by Ramananda for bug#4468353 due to ebtax uptake by AR, start   |
|                                                                       |
| The following objects references the cursors created in the  object   |
|  1. jai_ar_match_tax.plb                                              |
|  2. jai_ar_rcta_t7.sql                                                |
|  3. jai_ar_trx.plb                                                    |
|  4. jai_jar_tl_t1.sql                                                 |
|  5. jai_jar_tl_t2.sql                                                 |
|  6. JAINARTX.fmb                                                      |
------------------------------------------------------------------------*/
--Get the Tax_regime_Code
CURSOR c_tax_regime_code_cur(p_org_id IN NUMBER) IS
SELECT Zx_Migrate_Util.GET_TAX_REGIME(
                          'SALES_TAX',
                          p_org_id)
FROM dual ;

--Get the party_tax_profile_id
CURSOR c_party_tax_profile_id_cur(p_org_id IN NUMBER) IS
SELECT party_tax_profile_id
FROM  zx_party_tax_profile zptp
WHERE party_id = p_org_id
and party_type_code = 'OU';

--Get the tax_rate_id
CURSOR c_tax_rate_id_cur (cp_tax_regime_code zx_rates_b.tax_regime_code%type, cp_party_tax_profile_id  zx_party_tax_profile.party_tax_profile_id%type) IS
SELECT tax_rate_id
FROM zx_rates_b zrb
WHERE zrb.tax                 = 'LOCALIZATION' -- 'Localization' , Harshita for Bug 4907217
AND   zrb.tax_regime_code     =  cp_tax_regime_code
AND   zrb.tax_status_code     = 'STANDARD'
AND   zrb.active_flag         = 'Y'
AND   zrb.content_owner_id    =  cp_party_tax_profile_id
AND   trunc(sysdate) between trunc(zrb.effective_from) and trunc(nvl(zrb.effective_to, sysdate)) ;

--Get the max(tax_rate_id)
CURSOR c_max_tax_rate_id_cur (cp_tax_regime_code zx_rates_b.tax_regime_code%type) IS
SELECT max(tax_rate_id)
FROM zx_rates_b zrb
WHERE zrb.tax                 = 'LOCALIZATION' -- 'Localization' , Harshita for Bug 4907217
AND   zrb.tax_regime_code     =  cp_tax_regime_code
AND   zrb.tax_status_code     = 'STANDARD'
AND   zrb.active_flag         = 'Y'
AND   trunc(sysdate) between trunc(zrb.effective_from) and trunc(nvl(zrb.effective_to, sysdate)) ;

/*------------------------------------------------------------------------------------
|    Above code is Added by Ramananda for bug#4468353 due to ebtax uptake by AR, end |
-------------------------------------------------------------------------------------*/

procedure update_excise_invoice_no(
                                    retcode OUT NOCOPY  varchar2,
                                    errbuf OUT NOCOPY   varchar2,
                                    p_org_id            number, 	   /* Bug 5096787. Added by Lakshmi Gopalsami  Added following two parameters. */
                                    p_start_date        VARCHAR2, /* modified by aiyer for the bug 5369250 */
                                    p_end_date          VARCHAR2      DEFAULT NULL,
                                    p_customer_trx_id number
                                  );

procedure validate_invoice( p_customer_trx_id IN  RA_CUST_TRX_LINE_GL_DIST_ALL.CUSTOMER_TRX_ID%TYPE ,
                            p_trx_number      IN  RA_CUSTOMER_TRX_ALL.TRX_NUMBER%TYPE               , /* should not be used in a where clause as this is not unique */
                            p_error_flag      OUT NOCOPY VARCHAR2                                          ,
                            p_error_message   OUT NOCOPY VARCHAR2
                            );


--==========================================================================
--  PROCEDURE NAME:
--    update_reference                        Public
--
--  DESCRIPTION:
--    This procedure is written that update the reference field in AR
--  transaction workbench when the AR invoice has been created manually
--
--  ER NAME/BUG#
--    VAT/Excise Number shown in AR transaction workbench
--    Bug 9303168
--
--  PARAMETERS:
--      In:  pn_customer_trx_id            Indicates the customer trx id
--
--  DESIGN REFERENCES:
--       TD named "VAT Invoice Number on AR Invoice Technical Design.doc" has been
--     referenced in the section 6.1
--
--  CALL FROM
--       The concurrent program "India - Excise/VAT Number in Transactions Workbench"
--
--  CHANGE HISTORY:
--  25-Jan-2010     BO Li          Created by Bo Li

--==========================================================================
 PROCEDURE update_reference
 ( retcode           OUT NOCOPY VARCHAR2
 , errbuf            OUT NOCOPY VARCHAR2
 , pn_customer_trx_id NUMBER);
END jai_ar_trx_pkg;

/
