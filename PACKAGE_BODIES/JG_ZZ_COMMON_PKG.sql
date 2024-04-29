--------------------------------------------------------
--  DDL for Package Body JG_ZZ_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_COMMON_PKG" AS
/* $Header: jgzzvatcmnb.pls 120.11.12010000.8 2010/02/23 13:03:12 pakumare ship $
*************************************************************************************
 | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
 |                       All rights reserved.                           |
*************************************************************************************


 PROGRAM NAME
  JGZZ_COMMON_PKB.pls

 DESCRIPTION
  Script to create package body for the common packn

 HISTORY
 =======

 VERSION     DATE          AUTHOR(S)             DESCRIPTION
 -------   -----------   ---------------       -------------------------------------
 DRAFT 1A    31-Jan-2006   Manish Upadhyay       Initial draft version
 DRAFT 1B    21-Feb-2006   Manish Upadhyay       Modified as per the Review comments
 120.2       26-APR-2006   Brathod               Bug: 5188902, Changed X_taxpayer_id from Number to Varchar2
 120.3       31-May-2006   Vijay                 modified the code to rectify issues observed during UT of extracts
                                                 Also added the debug code
 120.4       31-May-2006   Rukmani Basker        Added procedure to get configurable
						 setup for an reporting entity
						 get_entities_configuration_dtl
 120.5       27-Jun-2006   Suresh.Pasupunuri     Added X_ENTITY_IDENTIFIER new parameter
					         to get_entities_configuration_dtl funct
 120.6	     08-Aug-2006   Suresh.Pasupunuri     Commented the API call get_period_status in the procedure
						 tax_registration. Handling this API call in each extract separately
 120.7       09-Sep-2006   Suresh.Pasupunuri     Introduced a new cursor"lc_get_le_id" in function "funct_curr_legal
						 " for getting the legal entity id. This is because the existing
						 cursor-"lc_funct_curr_legal" will returns the legal entity id
						 information only if the data is available for reporting,
						 which is incorrect.
 120.8       30-Mar-2007   Ashanka Das           Modified to Logic to retrieve the Contact Information like Contact name and Contact
						 Phone number to be displayed on all report headers.
						 Modified the logic for Bug 5616752 and 5566343.
 120.9       30-Mar-2007   Ashanka Das           Re-Modified the Logic so that even if there is no Contact, then also the
 						 Company Info should be populated. Only Contact and telephone will be blank if there is no
						 Contact info, other data in the headers will be populated normally
 120.10      25-Jul-2008   Varun Kejriwal        Modified the code in the function funct_curr_legal in the cursor
                                                 lc_funct_curr_legal. Here the currency is no more fetched from
                                                 jg_zz_vat_trx_details. First it is verified for what the
                                                 Selection process was run. If for LE(Legal Entity) then from
                                                 jgzzvattrxdetails else if LEDGER then from gl_ledgers for bug 7287545
 120.13      09-Jan-2009   Varun Kejriwal        Added a function get_amt_tot which takes invoice_id and ledger_id as parameters
                                                 and based on the type of the reporting entity ( LE/ Primary Ledger/ Secondary Ledger ),
                                                 it returns the appropriate invoice_amount.
 120.18      23-Feb-2009   Suresh                 Bug 9381398:
 	                                                  Modified the get_amt_tot function logic. Earlier the invoice amount
 	                                                  logic was based on xla distribution links. But due to some limitation
 	                                                  while accessing the amounts information for upgrade transactions
 	                                                  changed the logic to fetch the amounts from xla ae lines.
 	                                                  Refer bug 9386590 for more details on upgrade transanctions issue
 	                                                  with xla distribution links.
*********************************************************************************** */


gv_debug_flag constant boolean := false;

PROCEDURE  funct_curr_legal(x_func_curr_code      OUT    NOCOPY  VARCHAR2
                           ,x_rep_entity_name     OUT    NOCOPY  VARCHAR2
                           ,x_legal_entity_id     OUT    NOCOPY  NUMBER
                           ,x_taxpayer_id         OUT    NOCOPY  VARCHAR2
                           ,pn_vat_rep_entity_id   IN            NUMBER
                           ,pv_period_name         IN            VARCHAR2     DEFAULT NULL
                           ,pn_period_year         IN            NUMBER       DEFAULT NULL)
-- +==================================================================================+
-- | Name                : funct_curr_legal                                           |
-- | Description         : funct_curr_legal procedure.                                |
-- |                       This procedure is used to fetch Functional_currency_code,  |
-- |                       rep_context_entity_name,rep_entity_id.                     |
-- | Parameters          :                                                            |
-- | x_func_curr_code    : Return Functional_currency_code                            |
-- | x_rep_entity_name   : Return rep_context_entity_name                             |
-- | x_legal_entity_id   : Return Legal Entity Id                                     |
-- | x_taxpayer_id       : Tax Payer Id                                               |
-- | pn_vat_rep_entity_id: Vat Reporting Entity Id                                    |
-- | pv_period_name      : Period Name                                                |
-- | pn_period_year      : Period Year                                                |
-- +==================================================================================+
IS
  CURSOR lc_funct_curr_legal IS
   SELECT DECODE(JZVRE.entity_level_code,'LEDGER',GL.currency_code,nvl(JZVTD.functional_currency_code,      jzvtd.trx_currency_code))
        ,JZVTD.rep_context_entity_name
        ,JZVTD.rep_entity_id
        ,JZVTD.taxpayer_id
  FROM   jg_zz_vat_trx_details          JZVTD
        ,jg_zz_vat_rep_status           JZVRS
        ,jg_zz_vat_rep_entities         JZVRE
        ,gl_ledgers                     GL
  WHERE  JZVTD.reporting_status_id    = JZVRS.reporting_status_id
  AND    JZVRS.vat_reporting_entity_id= pn_vat_rep_entity_id
  AND   (JZVRS.tax_calendar_period    = pv_period_name
          OR     JZVRS.tax_calendar_year      = pn_period_year)
  AND    JZVRE.vat_reporting_entity_id= JZVRS.vat_reporting_entity_id
  and    DECODE(JZVRE.entity_level_code,'LEDGER',JZVRE.ledger_id,1)=DECODE(entity_level_code,'LEDGER',GL.ledger_id,1)
  AND    rownum                       = 1;

  CURSOR lc_get_le_id IS
    SELECT  cfgd.legal_entity_id
    FROM   jg_zz_vat_rep_entities cfg
          ,jg_zz_vat_rep_entities cfgd
    WHERE  cfg.vat_reporting_entity_id = pn_vat_rep_entity_id
    AND    (
             ( cfg.entity_type_code  = 'ACCOUNTING'
               and cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id
             )
             or
            ( cfg.entity_type_code  = 'LEGAL'
               and cfg.vat_reporting_entity_id = cfgd.vat_reporting_entity_id
            ));

BEGIN

  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log, 'Start CMN.funct_curr_legal. pn_vat_rep_entity_id:'||pn_vat_rep_entity_id
      ||', pv_period_name:'||pv_period_name||', pn_period_year:'||pn_period_year);
  end if;

  IF lc_funct_curr_legal%ISOPEN THEN
      CLOSE lc_funct_curr_legal;
  END IF;
  OPEN lc_funct_curr_legal;
  FETCH lc_funct_curr_legal INTO x_func_curr_code
                                ,x_rep_entity_name
                                ,x_legal_entity_id
                                ,x_taxpayer_id;

  CLOSE lc_funct_curr_legal;

  IF lc_get_le_id%ISOPEN THEN
	CLOSE lc_get_le_id;
  END IF;

  OPEN lc_get_le_id;
  FETCH lc_get_le_id INTO x_legal_entity_id;
  CLOSE lc_get_le_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG,' No Header Information found in JG table. '|| SUBSTR(SQLERRM,1,200));
WHEN OTHERS THEN
  RAISE;
END funct_curr_legal;

PROCEDURE  tax_registration(x_tax_registration    OUT     NOCOPY   VARCHAR2
                           ,x_period_start_date   OUT     NOCOPY   DATE
                           ,x_period_end_date     OUT     NOCOPY   DATE
                           ,x_status              OUT     NOCOPY   VARCHAR2
                           ,pn_vat_rep_entity_id   IN              NUMBER
                           ,pv_period_name         IN              VARCHAR2     DEFAULT NULL
                           ,pn_period_year         IN              NUMBER       DEFAULT NULL
                           ,pv_source              IN              VARCHAR2)
-- +==================================================================================+
-- | Name                 : funct_curr_legal                                         |
-- | Description          : funct_curr_legal procedure.                              |
-- |                        This procedure is used to fetch tax_registration_number, |
-- |                        period_start_date,period_end_date,status.                |
-- | Parameters           :                                                          |
-- | x_tax_registration   : Return tax_registration_number                           |
-- | x_period_start_date  : Return period_start_date                                 |
-- | x_period_end_date    : Return period_end_date                                   |
-- | x_status             : Status (P=Preliminary, F=Final)                          |
-- | pn_vat_rep_entity_id : Vat Reporting Entity Id                                  |
-- | pv_period_name       : Period Name                                              |
-- | pn_period_year       : Period Year                                              |
-- | pv_source            : Possible values for Source are -> AP, AR, GL, ALL        |
-- +==================================================================================+
IS
  CURSOR lc_tax_registration IS
  SELECT JZVRS.tax_registration_number
        ,min(JZVRS.period_start_date)
        ,max(JZVRS.period_end_date)
  FROM   jg_zz_vat_rep_status           JZVRS
  WHERE  JZVRS.vat_reporting_entity_id= pn_vat_rep_entity_id
  AND   (JZVRS.tax_calendar_period    = pv_period_name
  OR     JZVRS.tax_calendar_year      = pn_period_year)
  group by JZVRS.tax_registration_number;

BEGIN

  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log, 'Start CMN.tax_registration. pn_vat_rep_entity_id:'||pn_vat_rep_entity_id
      ||', pv_period_name:'||pv_period_name||', pn_period_year:'||pn_period_year||', pv_source:'||pv_source);
  end if;

  IF lc_tax_registration%ISOPEN THEN
      CLOSE lc_tax_registration;
  END IF;
  OPEN lc_tax_registration;

  FETCH lc_tax_registration INTO x_tax_registration
                                ,x_period_start_date
                                ,x_period_end_date;
  CLOSE lc_tax_registration;

   x_status := NULL;

   /*x_status := jg_zz_vat_rep_utility.get_period_status(pn_vat_rep_entity_id
                                                     ,pv_period_name
                                                     ,pv_source); */

  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log, 'End CMN.tax_registration. x_tax_registration:'||x_tax_registration
      ||', x_period_start_date:'||x_period_start_date||', x_period_end_date:'||x_period_end_date);
  end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'No TRN Period Details found in JG table.'||SUBSTR(SQLERRM,1,200));
WHEN OTHERS THEN
   RAISE;
END tax_registration;

PROCEDURE company_detail(x_company_name         OUT      NOCOPY    VARCHAR2
                        ,x_registration_number  OUT      NOCOPY    VARCHAR2
                        ,x_country              OUT      NOCOPY    VARCHAR2
                        ,x_address1             OUT      NOCOPY    VARCHAR2
                        ,x_address2             OUT      NOCOPY    VARCHAR2
                        ,x_address3             OUT      NOCOPY    VARCHAR2
                        ,x_address4             OUT      NOCOPY    VARCHAR2
                        ,x_city                 OUT      NOCOPY    VARCHAR2
                        ,x_postal_code          OUT      NOCOPY    VARCHAR2
                        ,x_contact              OUT      NOCOPY    VARCHAR2
                        ,x_phone_number         OUT      NOCOPY    VARCHAR2
                        ,x_province             OUT      NOCOPY    VARCHAR2
                        ,x_comm_number          OUT      NOCOPY    VARCHAR2
                        ,x_vat_reg_num          OUT      NOCOPY    VARCHAR2
                        ,pn_legal_entity_id     IN      NUMBER
                        ,p_vat_reporting_entity_id IN    NUMBER
                        )

-- +===================================================================================+
-- | Name                  : company_detail                                            |
-- | Description           : company_detail procedure.                                 |
-- |                         This procedure is used to fetch                           |
-- |                         Company Name                                              |
-- |                        ,Registration Number                                       |
-- |                        ,Country                                                   |
-- |                        ,Address1                                                  |
-- |                        ,Address2                                                  |
-- |                        ,Address3                                                  |
-- |                        ,Address4                                                  |
-- |                        ,City                                                      |
-- |                        ,Postal Code                                               |
-- |                        ,Contact                                                   |
-- |                        ,Phone Number                                              |
-- | Parameters            :                                                           |
-- | x_company_name        : Company Name                                              |
-- | x_registration_number : Registration Number                                       |
-- | x_country             : Country                                                   |
-- | x_address1            : Address1                                                  |
-- | x_address2            : Address2                                                  |
-- | x_address3            : Address3                                                  |
-- | x_address4            : Address4                                                  |
-- | x_city                : City                                                      |
-- | x_postal_code         : Postal Code                                               |
-- | x_contact             : Contact Person                                            |
-- | x_phone_number        : Phone Number                                              |
-- | pn_legal_entity_id    : Legal Entity Identifier or Operating Unit identifier      |
-- +===================================================================================+

IS

CURSOR lc_company_detail IS
  SELECT  XR.registered_name
           ,XR.registration_number
           ,FT.territory_short_name
           ,HL.address_line_1
           ,HL.address_line_2
           ,HL.address_line_3
           ,null address4
           ,HL.town_or_city
           ,HL.postal_code
           --,HP.party_name This now retreived in the second cursor
           ,hp.party_id
            -- Adding code for the GLOB006-ER
           ,HL.region_1
    FROM    xle_registrations       XR
           ,xle_entity_profiles     XEP
           ,hr_locations_all        HL
           ,hz_parties              HP
           ,fnd_territories_vl      FT
    WHERE   XR.source_id          =  XEP.legal_entity_id
    AND     XR.source_table       = 'XLE_ENTITY_PROFILES'
    AND     XEP.legal_entity_id   =  pn_legal_entity_id
    AND     XR.location_id        =  HL.location_id
    AND     HL.country            =  FT.TERRITORY_CODE
    AND     XEP.party_id          =  HP.party_id
    and     xr.identifying_flag   = 'Y';



/*CURSOR lc_contact_phone(cp_party_id in number) IS
  SELECT  HCP.phone_number
    FROM    hz_contact_points       HCP
    WHERE   HCP.owner_table_id = cp_party_id
    AND     HCP.owner_table_name  = 'HZ_PARTIES'
    AND     HCP.primary_flag      = 'Y'
    AND     HCP.contact_point_type= 'PHONE'
    AND     HCP.status            = 'A';*/
/*
Commented the above code. The Logic to get the Contact Information
has been modified and the below cursor has been added for same.
Now both the contact name and Contact phone no is being retreived from same table.
*/
CURSOR lc_contact_phone(cp_party_id in number) IS
  SELECT  per.party_name
          ,per.primary_phone_number
    		FROM    HZ_PARTIES              HP
           		,HZ_RELATIONSHIPS        REL
           		,HZ_PARTIES              PER
    			WHERE   HP.PARTY_ID  =  cp_party_id
				AND    	rel.object_id          = HP.PARTY_ID
				AND    	rel.subject_id         = per.party_id
				AND     rel.relationship_code = 'CONTACT_OF'
				AND    	rel.relationship_type = 'CONTACT'
				AND    	rel.directional_flag  = 'F'
				AND    	rel.subject_table_name = 'HZ_PARTIES'
				AND    	rel.subject_type       = 'PERSON'
				AND    	rel.object_table_name  = 'HZ_PARTIES'
				AND    	Trunc(Nvl(rel.end_date, SYSDATE)) > TRUNC(SYSDATE);

/* Added for GLOBE-006 ER*/
CURSOR lc_commercial_num IS
select nvl(xler.registration_number,'') commercial_number
from XLE_REGISTRATIONS xler, XLE_JURISDICTIONS_B xlej, xle_entity_profiles xlee
where xlej.JURISDICTION_ID= xler.JURISDICTION_ID
and xlej.LEGISLATIVE_CAT_CODE = 'COMMERCIAL_LAW'
AND xler.source_id = xlee.LEGAL_ENTITY_ID
AND xler.source_TABLE = 'XLE_ENTITY_PROFILES'
and xlee.legal_entity_id = pn_legal_entity_id;

ln_party_id     HZ_PARTIES.party_id%TYPE;

BEGIN

  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log, 'Start CMN.company_detail. pn_legal_entity_id:'||pn_legal_entity_id);
  end if;

-- Added for GLOB-006
  IF p_vat_reporting_entity_id is null THEN -- NONEMEAVAT REPORT
   BEGIN
   SELECT zptp.REP_REGISTRATION_NUMBER
     INTO x_vat_reg_num
     FROM ZX_PARTY_TAX_PROFILE zptp
          ,XLE_ETB_PROFILES xetbp
    WHERE zptp.PARTY_TYPE_CODE = 'LEGAL_ESTABLISHMENT'
      AND xetbp.party_id=zptp.party_id
      AND xetbp.MAIN_ESTABLISHMENT_FLAG = 'Y'
      AND xetbp.LEGAL_ENTITY_ID = pn_legal_entity_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'No VAT registration_number found. '||SUBSTR(SQLERRM,1,200));
    WHEN OTHERS THEN
     RAISE;
    END;
  ELSE  -- EMEAVAT REPORT
   BEGIN
   SELECT cfgd.TAX_REGISTRATION_NUMBER
     INTO x_vat_reg_num
     FROM jg_zz_vat_rep_entities cfg
         ,jg_zz_vat_rep_entities cfgd
    WHERE cfg.vat_reporting_entity_id = p_vat_reporting_entity_id
     AND ( ( cfg.entity_type_code = 'ACCOUNTING'
     AND cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id
         )
     OR
        ( cfg.entity_type_code = 'LEGAL'
          AND cfg.vat_reporting_entity_id = cfgd.vat_reporting_entity_id
        )
        );
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'No VAT registration_number found. '||SUBSTR(SQLERRM,1,200));
    WHEN OTHERS THEN
     RAISE;
    END;
  END IF;
  -- END HERE for GLOB-006

  IF lc_company_detail%ISOPEN THEN
      CLOSE lc_company_detail;
  END IF;
  OPEN  lc_company_detail;
  FETCH lc_company_detail INTO x_company_name
                              ,x_registration_number
                              ,x_country
                              ,x_address1
                              ,x_address2
                              ,x_address3
                              ,x_address4
                              ,x_city
                              ,x_postal_code
                              --,x_contact
                              ,ln_party_id
                              ,x_province;  -- Added for GLOB-006

  CLOSE lc_company_detail;

  IF lc_contact_phone%ISOPEN THEN
      CLOSE lc_contact_phone;
  END IF;

  OPEN  lc_contact_phone(ln_party_id);
  FETCH lc_contact_phone INTO x_contact,x_phone_number;
  CLOSE lc_contact_phone;

  OPEN  lc_commercial_num;
  FETCH lc_commercial_num INTO x_comm_number;
  CLOSE lc_commercial_num;


  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log, 'Start CMN.company_detail. x_company_name:'||x_company_name||', ln_party_id:'||ln_party_id||', x_registration_number:'||x_registration_number);
  end if;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'No LE Company Information found. '||SUBSTR(SQLERRM,1,200));
  WHEN OTHERS THEN
    RAISE;
END company_detail;

PROCEDURE  get_entities_configuration_dtl(x_calendar_name OUT  NOCOPY  VARCHAR2
                          ,x_enable_register_flag      OUT   NOCOPY    VARCHAR2
                          ,x_enable_report_seq_flag    OUT   NOCOPY    VARCHAR2
                          ,x_enable_alloc_flag         OUT   NOCOPY    VARCHAR2
                          ,x_enable_annual_alloc_flag  OUT   NOCOPY    VARCHAR2
                          ,x_threshold_amt             OUT   NOCOPY    VARCHAR2
			  ,x_entity_identifier	       OUT   NOCOPY    VARCHAR2
                          ,p_vat_rep_entity_id         IN             NUMBER)
-- +===========================================================================+
-- | Name                 : get_entities_configuration_dtl                    |
-- | Description          : get_entities_configuration_dtl procedure.         |
-- |                        This procedure is used to fetch configurable setup|
-- |                        details for LEGAL/ACCOUNTING vat reporting entity.|
-- | Input Parameters     :                                                   |
-- | p_vat_rep_entity_id : Vat Reporting Entity Id                            |
-- +===========================================================================+
IS
  CURSOR lc_get_entities_config_details IS
    SELECT  legal_rep_entity.TAX_CALENDAR_NAME,
        legal_rep_entity.ENABLE_REGISTERS_FLAG,
        legal_rep_entity.ENABLE_REPORT_SEQUENCE_FLAG,
        legal_rep_entity.ENABLE_ALLOCATIONS_FLAG,
        legal_rep_entity.ENABLE_ANNUAL_ALLOCATION_FLAG,
        legal_rep_entity.THRESHOLD_AMOUNT,
	actg_rep_entity.ENTITY_IDENTIFIER
    FROM    JG_ZZ_VAT_REP_ENTITIES actg_rep_entity,
            JG_ZZ_VAT_REP_ENTITIES legal_rep_entity
    WHERE   actg_rep_entity.vat_reporting_entity_id  = p_vat_rep_entity_id
            AND nvl(actg_rep_entity.mapping_vat_rep_entity_id,
                actg_rep_entity.vat_reporting_entity_id)
                                   = legal_rep_entity.vat_reporting_entity_id;

BEGIN

  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log,
    'Start CMN.get_entities_configuration_dtl. pn_vat_rep_entity_id:'
     ||p_vat_rep_entity_id
      );
  end if;

  IF lc_get_entities_config_details%ISOPEN THEN
      CLOSE lc_get_entities_config_details;
  END IF;
  OPEN lc_get_entities_config_details;

  FETCH lc_get_entities_config_details INTO x_calendar_name
                                            ,x_enable_register_flag
                                            ,x_enable_report_seq_flag
                                            ,x_enable_alloc_flag
                                            ,x_enable_annual_alloc_flag
                                            ,x_threshold_amt
					    ,x_entity_identifier;
  CLOSE lc_get_entities_config_details;

  if gv_debug_flag then
    fnd_file.put_line(fnd_file.log, 'End CMN.get_entities_configuration_dtl. x_calendar_name:'||x_calendar_name
      ||', x_enable_register_flag:'||x_enable_register_flag||', x_enable_report_seq_flag:'||x_enable_report_seq_flag
      ||', x_enable_alloc_flag:'||x_enable_alloc_flag||', x_enable_annual_alloc_flag:'||x_enable_annual_alloc_flag
      ||', x_threshold_amt:'|| x_threshold_amt);
  end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'This VAT reporting entity does not exists.'||SUBSTR(SQLERRM,1,200));
WHEN OTHERS THEN
   RAISE;
END get_entities_configuration_dtl;

FUNCTION get_legal_entity_country_code(p_legal_entity_id  IN  NUMBER) RETURN VARCHAR2 IS
l_country_code varchar2(10);
BEGIN

    SELECT HL.country
    INTO   l_country_code
    FROM    xle_registrations       XR
           ,xle_entity_profiles     XEP
           ,hr_locations_all        HL
    WHERE   XR.source_id          =  XEP.legal_entity_id
    AND     XR.source_table       = 'XLE_ENTITY_PROFILES'
    AND     XEP.legal_entity_id   =  p_legal_entity_id
    AND     XR.location_id        =  HL.location_id
    AND     xr.identifying_flag   = 'Y';

RETURN l_country_code;

EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception in getting country code'||SUBSTR(SQLERRM,1,200));
RETURN  NULL;
END get_legal_entity_country_code;

FUNCTION get_amt_tot (
                 pn_invoice_id NUMBER,
                 pn_ledger_id NUMBER,
                 pn_precision NUMBER
                 )
  RETURN NUMBER IS
  l_amt                       NUMBER;

BEGIN

IF ( pn_ledger_id = -1 )
THEN
select nvl(base_amount,invoice_amount) into l_amt
from ap_invoices_all
where invoice_id = pn_invoice_id;

ELSE

SELECT   SUM (ROUND (NVL (xal.accounted_cr, 0), pn_precision))
       - SUM (ROUND (NVL (xal.accounted_dr, 0), pn_precision))
into l_amt
  FROM xla_transaction_entities xte,
       xla_events xe,
       xla_ae_headers xah,
       xla_ae_lines xal
 WHERE xte.entity_id = xe.entity_id
   AND xe.application_id = 200
   AND xah.event_id = xe.event_id
   AND xah.application_id = 200
   AND xte.application_id = 200
   AND xah.ledger_id = pn_ledger_id
   AND NVL (xe.budgetary_control_flag, 'N') = 'N'
   AND xe.event_status_code = 'P'
   and xe.process_status_code = 'P'
   AND xal.ae_header_id = xah.ae_header_id
   AND xal.accounting_class_code = 'LIABILITY'
   AND xte.entity_code = 'AP_INVOICES'
   AND NVL (xte.source_id_int_1, -99) = pn_invoice_id;

END IF;
RETURN l_amt;

EXCEPTION
    WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception in getting invoice_amount'||SUBSTR(SQLERRM,1,200));
    Return NULL;

END get_amt_tot;

END JG_ZZ_COMMON_PKG;

/
