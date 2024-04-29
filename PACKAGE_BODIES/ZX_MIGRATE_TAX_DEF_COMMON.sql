--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_TAX_DEF_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_TAX_DEF_COMMON" AS
/* $Header: zxstaxdefmigb.pls 120.44.12010000.4 2009/03/24 18:23:22 ssohal ship $ */

-- ****** GLOBAL VARIABLES ******
l_min_start_date      DATE;
l_ap_min_start_date   DATE;
l_ar_min_start_date   DATE;
l_ap_count            NUMBER;
l_ar_count            NUMBER;
L_MULTI_ORG_FLAG      FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
L_ORG_ID	      NUMBER(15);

-- ****** PROCEDURES ******
PROCEDURE update_tax_status  ;
PROCEDURE load_results_for_ap (p_tax_id   NUMBER) AS
BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    effective_from,
    effective_to,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
)
SELECT
      codes.tax_id                   tax_code_id,
      codes.org_id                   org_id,
      codes.name                     tax_code,
      'INPUT'                        tax_class,
      case when codes.tax_type = 'USE'
      then
      Zx_Migrate_Util.GET_TAX_REGIME(
                      codes.tax_type,
                      codes.org_id)
      else
      Zx_Migrate_Util.Get_Country(codes.Org_Id)||'-Tax'
      end           tax_regime_code,
      Nvl(CASE WHEN codes.global_attribute_category
                IN ('JE.CZ.APXTADTC.TAX_ORIGIN','JE.HU.APXTADTC.TAX_ORIGIN','JE.PL.APXTADTC.TAX_ORIGIN','JE.CH.APXTADTC.TAX_INFO'
                    )
                THEN
                    CASE WHEN lengthb (codes.global_attribute1) > 30
                    THEN
                        rtrim(substrb(CODES.GLOBAL_ATTRIBUTE1,1,24))||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_TAXES_B_S')
                    ELSE
                        CODES.GLOBAL_ATTRIBUTE1
                    END
                END
           ,
                CASE WHEN codes.tax_type ='USE'
                     THEN
                    RTRIM(substrb(Zx_Migrate_Util.GET_TAX(
                     codes.name,
                     codes.tax_type),1,30))
                     ELSE
                        CASE WHEN
			  Zx_Migrate_Util.GET_TAX(
                               codes.name,
                               codes.tax_type) <> codes.tax_type
			    THEN
			    CASE WHEN
                               Lengthb(Zx_Migrate_Util.GET_TAX(
                               codes.name,
                               codes.tax_type)||'-'||codes.tax_type) > 30
                               THEN
                                  rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                                                                codes.name,
                                                                codes.tax_type)||'-'||codes.tax_type,1,30))
                               ELSE
                                   Zx_Migrate_Util.GET_TAX(
                                                          codes.name,
                                                          codes.tax_type)||'-'||codes.tax_type
                               END
			    ELSE
			     rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                               codes.name,
                               codes.tax_type),1,30))
                            END

                    END
           )                          tax,
      DECODE(codes.global_attribute_category,
            'JA.TW.APXTADTC.TAX_CODES',
             nvl(codes.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      NULL                               recovery_type_code, --Bug Fix 5028009
      'N'                                frozen,
      zx_migrate_util.get_country(codes.org_id)  country_code,
      codes.start_date                   effective_from,
      codes.inactive_date                effective_to,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login
FROM  ap_tax_codes_all codes,
      financials_system_params_all fsp
WHERE codes.tax_type NOT IN ('AWT','TAX_GROUP','OFFSET')
AND   codes.org_id  = fsp.org_id
-- Sync process
AND   codes.tax_id  = nvl(p_tax_id,codes.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,codes.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );
ELSE

INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    effective_from,
    effective_to,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
)
SELECT
      codes.tax_id                   tax_code_id,
      codes.org_id                   org_id,
      codes.name                     tax_code,
      'INPUT'                        tax_class,
      case when codes.tax_type = 'USE'
      then
      Zx_Migrate_Util.GET_TAX_REGIME(
                      codes.tax_type,
                      codes.org_id)
      else
      Zx_Migrate_Util.Get_Country(codes.Org_Id)||'-Tax'
      end           tax_regime_code,
           Nvl(CASE WHEN codes.global_attribute_category
                IN ('JE.CZ.APXTADTC.TAX_ORIGIN','JE.HU.APXTADTC.TAX_ORIGIN','JE.PL.APXTADTC.TAX_ORIGIN','JE.CH.APXTADTC.TAX_INFO'
                    )
                THEN
                    CASE WHEN lengthb (codes.global_attribute1) > 30
                    THEN
                        rtrim(substrb(CODES.GLOBAL_ATTRIBUTE1,1,24))||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_TAXES_B_S')
                    ELSE
                        CODES.GLOBAL_ATTRIBUTE1
                    END
                END
           ,
                CASE WHEN codes.tax_type ='USE'
                     THEN
                     rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                     codes.name,
                     codes.tax_type),1,30))
                     ELSE
                        CASE WHEN
			  Zx_Migrate_Util.GET_TAX(
                               codes.name,
                               codes.tax_type) <> codes.tax_type
			    THEN
			    CASE WHEN
                               lengthb(Zx_Migrate_Util.GET_TAX(
                               codes.name,
                               codes.tax_type)||'-'||codes.tax_type) > 30
                               THEN
                                  rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                                                                codes.name,
                                                                codes.tax_type)||'-'||codes.tax_type,1,30))
                               ELSE
                                   Zx_Migrate_Util.GET_TAX(
                                                          codes.name,
                                                          codes.tax_type)||'-'||codes.tax_type
                               END
			    ELSE
			     rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                               codes.name,
                               codes.tax_type),1,30))
                            END

                    END
           )                          tax,
      DECODE(codes.global_attribute_category,
            'JA.TW.APXTADTC.TAX_CODES',
             nvl(codes.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      NULL                               recovery_type_code, --Bug Fix 5028009
      'N'                                frozen,
      zx_migrate_util.get_country(codes.org_id)  country_code,
      codes.start_date                   effective_from,
      codes.inactive_date                effective_to,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login
FROM  ap_tax_codes_all codes,
      financials_system_params_all fsp
WHERE codes.tax_type NOT IN ('AWT','TAX_GROUP','OFFSET')
AND   codes.org_id  = fsp.org_id
AND   codes.org_id  = l_org_id
-- Sync process
AND   codes.tax_id  = nvl(p_tax_id,codes.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,codes.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );

END IF;
/*Insert rows for assigned offset tax codes into zx_update_criteria_results*/

IF L_MULTI_ORG_FLAG = 'Y'
THEN
INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    effective_from,
    effective_to,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
)
SELECT
      DISTINCT                        -->Bug 5868851
      offset.tax_id                   tax_code_id,
      offset.org_id                   org_id,
      offset.name                     tax_code,
      'INPUT'                        tax_class,
      case when codes.tax_type = 'USE'
      then
      Zx_Migrate_Util.GET_TAX_REGIME(
                      codes.tax_type,
                      codes.org_id)
      else
      Zx_Migrate_Util.Get_Country(codes.Org_Id)||'-Tax'
      end           tax_regime_code,
     NVL(CASE WHEN offset.global_attribute_category
                IN ('JE.CZ.APXTADTC.TAX_ORIGIN','JE.HU.APXTADTC.TAX_ORIGIN','JE.PL.APXTADTC.TAX_ORIGIN','JE.CH.APXTADTC.TAX_INFO'
                    )
                THEN
                    CASE WHEN lengthb (offset.global_attribute1) > 24
                    THEN
                        rtrim(substrb(offset.GLOBAL_ATTRIBUTE1,1,24))||'-OFFST'
                    ELSE
                        offset.GLOBAL_ATTRIBUTE1||'-OFFST'
                    END
                END,
      CASE WHEN
          Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type)
            <> offset.tax_type
	    THEN CASE WHEN LENGTHB(Zx_Migrate_Util.GET_TAX(
                                           offset.name,
                                           offset.tax_type)
                             ||'-OFFSET-'||offset.tax_type) > 30 THEN
                RTRIM(SUBSTRB(
                    Zx_Migrate_Util.GET_TAX(
                             offset.name,
                             offset.tax_type)
                    ||'-OFFSET-'||offset.tax_type,1,30))
           ELSE
            Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type)
            ||'-OFFSET-'||offset.tax_type
           END
	  ELSE
          rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type),1,24))
           ||'-OFFST'
       END	  )tax,
      DECODE(offset.global_attribute_category,
            'JA.TW.APXTADTC.TAX_CODES',
             nvl(offset.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      NULL                               recovery_type_code, --Bug Fix 5028009
      'N'                                frozen,
      zx_migrate_util.get_country(offset.org_id)  country_code,
      offset.start_date                   effective_from,
      offset.inactive_date                effective_to,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login
FROM  ap_tax_codes_all codes,
      ap_tax_codes_all offset,
      financials_system_params_all fsp
WHERE offset.tax_type = 'OFFSET'
AND   offset.tax_id = codes.offset_tax_code_id
AND   codes.offset_tax_code_id IS NOT NULL
AND   codes.org_id  = fsp.org_id
-- Sync process
AND   codes.tax_id  = nvl(p_tax_id,codes.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,offset.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );
ELSE


INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    effective_from,
    effective_to,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
)
SELECT
      DISTINCT                        -->Bug 5868851
      offset.tax_id                   tax_code_id,
      offset.org_id                   org_id,
      offset.name                     tax_code,
      'INPUT'                        tax_class,
      case when codes.tax_type = 'USE'
      then
      Zx_Migrate_Util.GET_TAX_REGIME(
                      codes.tax_type,
                      codes.org_id)
      else
      Zx_Migrate_Util.Get_Country(codes.Org_Id)||'-Tax'
      end           tax_regime_code,
     NVL(CASE WHEN offset.global_attribute_category
                IN ('JE.CZ.APXTADTC.TAX_ORIGIN','JE.HU.APXTADTC.TAX_ORIGIN','JE.PL.APXTADTC.TAX_ORIGIN','JE.CH.APXTADTC.TAX_INFO'
                    )
                THEN
                    CASE WHEN lengthb (offset.global_attribute1) > 24
                    THEN
                        rtrim(substrb(offset.GLOBAL_ATTRIBUTE1,1,24))||'-OFFST'
                    ELSE
                        offset.GLOBAL_ATTRIBUTE1||'-OFFST'
                    END
                END,
      CASE WHEN
          Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type)
            <> offset.tax_type
	    THEN CASE WHEN LENGTHB(
                     Zx_Migrate_Util.GET_TAX(
                              offset.name,
                              offset.tax_type)
                     ||'-OFFSET-'||offset.tax_type) > 30 THEN
                RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                              offset.name,
                              offset.tax_type)
                     ||'-OFFSET-'||offset.tax_type,1,30))
          ELSE
             Zx_Migrate_Util.GET_TAX(
                              offset.name,
                              offset.tax_type)
                     ||'-OFFSET-'||offset.tax_type
          END
	  ELSE
          rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type),1,24))
           ||'-OFFST'
       END	)  tax,
      DECODE(offset.global_attribute_category,
            'JA.TW.APXTADTC.TAX_CODES',
             nvl(offset.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      NULL                               recovery_type_code, --Bug Fix 5028009
      'N'                                frozen,
      zx_migrate_util.get_country(offset.org_id)  country_code,
      offset.start_date                   effective_from,
      offset.inactive_date                effective_to,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login
FROM  ap_tax_codes_all codes,
      ap_tax_codes_all offset,
      financials_system_params_all fsp
WHERE offset.tax_type = 'OFFSET'
AND   offset.tax_id = codes.offset_tax_code_id
AND   codes.offset_tax_code_id IS NOT NULL
AND   codes.org_id  = fsp.org_id
AND   codes.org_id  = l_org_id
-- Sync process
AND   codes.tax_id  = nvl(p_tax_id,codes.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,offset.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );

END IF;

/*Insert rows for un-assigned offset tax codes into zx_update_criteria_results*/
IF L_MULTI_ORG_FLAG = 'Y'
THEN
INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    effective_from,
    effective_to,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
)
SELECT
      offset.tax_id                   tax_code_id,
      offset.org_id                   org_id,
      offset.name                     tax_code,
      'INPUT'                         tax_class,
      Zx_Migrate_Util.Get_Country(Offset.Org_Id)||'-Tax'   tax_regime_code,
     NVL(CASE WHEN offset.global_attribute_category
                IN ('JE.CZ.APXTADTC.TAX_ORIGIN','JE.HU.APXTADTC.TAX_ORIGIN','JE.PL.APXTADTC.TAX_ORIGIN','JE.CH.APXTADTC.TAX_INFO'
                    )
                THEN
                    CASE WHEN lengthb (offset.global_attribute1) > 30
                    THEN
                        rtrim(substrb(offset.GLOBAL_ATTRIBUTE1,1,24))
                    ELSE
                        offset.GLOBAL_ATTRIBUTE1
                    END
                END,
          rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type),1,24))
          ) ||'-OFFST'                 tax,
      DECODE(offset.global_attribute_category,
            'JA.TW.APXTADTC.TAX_CODES',
             nvl(offset.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      NULL                               recovery_type_code, --Bug Fix 5028009
      'N'                                frozen,
      zx_migrate_util.get_country(offset.org_id)  country_code,
      offset.start_date                   effective_from,
      offset.inactive_date                effective_to,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login
FROM
      ap_tax_codes_all offset,
      financials_system_params_all fsp
WHERE offset.tax_type = 'OFFSET'
AND  offset.org_id  = fsp.org_id
AND  not exists (select 1 from ap_tax_codes_all  where
                 offset_tax_code_id = offset.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,offset.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );
ELSE
INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    effective_from,
    effective_to,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
)
SELECT
      offset.tax_id                   tax_code_id,
      offset.org_id                   org_id,
      offset.name                     tax_code,
      'INPUT'                         tax_class,
      Zx_Migrate_Util.Get_Country(Offset.Org_Id)||'-Tax'  tax_regime_code,
          NVL(CASE WHEN offset.global_attribute_category
                IN ('JE.CZ.APXTADTC.TAX_ORIGIN','JE.HU.APXTADTC.TAX_ORIGIN','JE.PL.APXTADTC.TAX_ORIGIN','JE.CH.APXTADTC.TAX_INFO'
                    )
                THEN
                    CASE WHEN lengthb (offset.global_attribute1) > 30
                    THEN
                        rtrim(substrb(offset.GLOBAL_ATTRIBUTE1,1,24))
                    ELSE
                        offset.GLOBAL_ATTRIBUTE1
                    END
                END,
          rtrim(substrb(Zx_Migrate_Util.GET_TAX(
                     offset.name,
                     offset.tax_type),1,24))
          ) ||'-OFFST'                 tax,
      DECODE(offset.global_attribute_category,
            'JA.TW.APXTADTC.TAX_CODES',
             nvl(offset.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      NULL                               recovery_type_code, --Bug Fix 5028009
      'N'                                frozen,
      zx_migrate_util.get_country(offset.org_id)  country_code,
      offset.start_date                   effective_from,
      offset.inactive_date                effective_to,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login
FROM
      ap_tax_codes_all offset,
      financials_system_params_all fsp
WHERE offset.tax_type = 'OFFSET'
AND  offset.org_id  = fsp.org_id
AND  offset.org_id = l_org_id
AND  not exists (select 1 from ap_tax_codes_all  where
                 offset_tax_code_id = offset.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,offset.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );


END IF;
END load_results_for_ap;

PROCEDURE load_results_for_ar (p_tax_id   NUMBER) AS
BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN
  INSERT
  INTO zx_update_criteria_results
  (
       tax_code_id,
       org_id,
       tax_code,
       tax_class,
       tax_regime_code,
       tax,
       tax_status_code,
       recovery_type_code,
       frozen,
       country_code,
       effective_from,
       effective_to,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
  )
  SELECT
   	  codes.vat_tax_id               tax_code_id,
          codes.org_id                   org_id,
	  codes.tax_code                 tax_code,
          'OUTPUT'                       tax_class,
          -- Bug 4688151 : Populate LTE Tax Regimes
      CASE WHEN asp.global_attribute_category IN ('JL.AR.ARXSYSPA.SYS_PARAMETERS',
                                                      'JL.BR.ARXSYSPA.Additional Info',
                                                      'JL.CO.ARXSYSPA.SYS_PARAMETERS') THEN
            asp.global_attribute13 || '-' || codes.tax_type
          ELSE
	   CASE WHEN codes.tax_type <> 'SALES_TAX' then
	  	      Zx_Migrate_Util.Get_Country(Codes.Org_Id)||'-Tax'
	   ELSE

	               Zx_Migrate_Util.GET_TAX_REGIME(
	  		  codes.tax_type,
	  		  codes.org_id)
            END
          END      tax_regime_code,
          -- YK:02/09/2005:Needs substrb
   	      NVL(CASE WHEN  codes.global_attribute_category IN ('JE.CZ.ARXSUVAT.TAX_ORIGIN',
		                                                 'JE.HU.ARXSUVAT.TAX_ORIGIN',
                                                                 'JE.PL.ARXSUVAT.TAX_ORIGIN')
                   THEN
                         CASE WHEN LENGTHB(codes.global_attribute1) > 30 THEN
                            RTRIM(SUBSTRB(codes.global_attribute1,1,24))
                         ELSE codes.global_attribute1
                         END
                   WHEN  codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                             'JL.BR.ARXSUVAT.Tax Information',
                                                             'JL.CO.ARXSUVAT.AR_VAT_TAX')
                   THEN (select tax_category
                         from   jl_zz_ar_tx_categ_all
                         where  TO_CHAR(tax_category_id) = codes.global_attribute1
                         and    org_id = codes.org_id)
               ELSE
                   NULL
               END,
	       CASE WHEN codes.tax_type = Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)
               THEN
               RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type),1,30))
               ELSE
	                CASE WHEN LENGTHB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type) > 30
                                   THEN
				         RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type,1,30))
				   ELSE
				         Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type
                                   END
                END

	       )              tax,
         DECODE(codes.global_attribute_category,
                'JA.TW.ARXSUVAT.VAT_TAX', nvl(codes.global_attribute1,'STANDARD'),
                DECODE(codes.tax_class,
                       'O', 'STANDARD',
                       'I', 'STANDARD-AR-INPUT',
                       'STANDARD'))                     tax_status_code,
	NULL                               recovery_type_code,
        'N'                                frozen,
        zx_migrate_util.get_country(codes.org_id)  country_code,
	codes.start_date                   effective_from,
	codes.end_date                     effective_to,
        fnd_global.user_id                 created_by,
        sysdate                            creation_date,
        fnd_global.user_id                 last_updated_by,
        sysdate                            last_updated_date,
        fnd_global.conc_login_id           last_update_login
  FROM  ar_vat_tax_all_b          codes,
        ar_system_parameters_all  asp
  WHERE codes.tax_type not in ('TAX_GROUP', 'LOCATION')
  AND   asp.org_id = codes.org_id
  -- Eliminate Tax Vendor Tax Codes
  -- Bug 4880975 : Vendor tax codes other than tax type location
  --               should also be loaded into results table.
  -- AND   asp.tax_database_view_set not in ('_A', '_V')
  -- Eliminate LTE tax codes
  -- Bug 4688151 : Do not eliminate LTE tax codes
  -- For LTE Tax Codes regime name should come from JL tax category
  -- AND  (codes.global_attribute_category is null OR
  --       codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
  --            			        'JL.BR.ARXSUVAT.AR_VAT_TAX',
  --					        'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  -- Eliminate tax_type = 'LOCATION'
  --Added following conditions for Sync process
  AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)
  --Rerunability
  AND  NOT EXISTS (SELECT 1
                   FROM   zx_update_criteria_results  zucr
		   WHERE  zucr.tax_code_id =  nvl(p_tax_id,codes.vat_tax_id)
                   AND    zucr.tax_class = 'OUTPUT'
		  );
ELSE
  INSERT
  INTO zx_update_criteria_results
  (
       tax_code_id,
       org_id,
       tax_code,
       tax_class,
       tax_regime_code,
       tax,
       tax_status_code,
       recovery_type_code,
       frozen,
       country_code,
       effective_from,
       effective_to,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
  )
  SELECT
   	  codes.vat_tax_id               tax_code_id,
          codes.org_id                   org_id,
	  codes.tax_code                 tax_code,
          'OUTPUT'                       tax_class,
          -- Bug 4688151 : Populate LTE Tax Regimes
      CASE WHEN asp.global_attribute_category IN ('JL.AR.ARXSYSPA.SYS_PARAMETERS',
                                                      'JL.BR.ARXSYSPA.Additional Info',
                                                      'JL.CO.ARXSYSPA.SYS_PARAMETERS') THEN
            asp.global_attribute13 || '-' || codes.tax_type
          ELSE
	   CASE WHEN codes.tax_type  <> 'SALES_TAX' then
	  	      Zx_Migrate_Util.Get_Country(Codes.Org_Id)||'-Tax'
	   ELSE

	               Zx_Migrate_Util.GET_TAX_REGIME(
	  		  codes.tax_type,
	  		  codes.org_id)
            END
          END      tax_regime_code,
          -- YK:02/09/2005:Needs substrb
   	      NVL(CASE WHEN  codes.global_attribute_category IN ('JE.CZ.ARXSUVAT.TAX_ORIGIN',
		                                                     'JE.HU.ARXSUVAT.TAX_ORIGIN',
                                                             'JE.PL.ARXSUVAT.TAX_ORIGIN')
                   THEN  CASE WHEN LENGTHB(codes.global_attribute1) > 30 THEN
                           RTRIM(SUBSTRB(codes.global_attribute1,1,24))
                         ELSE codes.global_attribute1
                         END
                   WHEN  codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                             'JL.BR.ARXSUVAT.Tax Information',
                                                             'JL.CO.ARXSUVAT.AR_VAT_TAX')
                   THEN (select tax_category
                         from   jl_zz_ar_tx_categ_all
                         where  TO_CHAR(tax_category_id) = codes.global_attribute1
                         and    org_id = codes.org_id)
               ELSE
                   NULL
               END,
 	       CASE WHEN codes.tax_type = Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)
               THEN
               RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type),1,30))
               ELSE
	                CASE WHEN LENGTHB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type) > 30
                                   THEN
				         RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type,1,30))
				   ELSE
				         Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type
                                   END

                END)              tax,
         DECODE(codes.global_attribute_category,
                'JA.TW.ARXSUVAT.VAT_TAX', nvl(codes.global_attribute1,'STANDARD'),
                DECODE(codes.tax_class,
                       'O', 'STANDARD',
                       'I', 'STANDARD-AR-INPUT',
                       'STANDARD'))                     tax_status_code,
	NULL                               recovery_type_code,
        'N'                                frozen,
        zx_migrate_util.get_country(codes.org_id)  country_code,
	codes.start_date                   effective_from,
	codes.end_date                     effective_to,
        fnd_global.user_id                 created_by,
        sysdate                            creation_date,
        fnd_global.user_id                 last_updated_by,
        sysdate                            last_updated_date,
        fnd_global.conc_login_id           last_update_login
  FROM  ar_vat_tax_all_b          codes,
        ar_system_parameters_all  asp
  WHERE codes.tax_type not in ('TAX_GROUP', 'LOCATION')
  AND   asp.org_id = codes.org_id
  AND   asp.org_id = l_org_id
  -- Eliminate Tax Vendor Tax Codes
  -- Bug 4880975 : Vendor tax codes other than tax type location
  --               should also be loaded into results table.
  -- AND   asp.tax_database_view_set not in ('_A', '_V')
  -- Eliminate LTE tax codes
  -- Bug 4688151 : Do not eliminate LTE tax codes
  -- For LTE Tax Codes regime name should come from JL tax category
  -- AND  (codes.global_attribute_category is null OR
  --       codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
  --            			        'JL.BR.ARXSUVAT.AR_VAT_TAX',
  --					        'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  -- Eliminate tax_type = 'LOCATION'
  --Added following conditions for Sync process
  AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)
  --Rerunability
  AND  NOT EXISTS (SELECT 1
                   FROM   zx_update_criteria_results  zucr
		   WHERE  zucr.tax_code_id =  nvl(p_tax_id,codes.vat_tax_id)
                   AND    zucr.tax_class = 'OUTPUT'
		  );

END IF;

update_tax_status;

END load_results_for_ar;

/*===========================================================================+
 | PROCEDURE
 | load_tax_comp_results_for_ar
 |
 | DESCRIPTION
 | 1. Populates data into zx_update_criteria_results table based on AR data in
 |    zx_tax_relations_t .
 |
 | ASSUMPTION:
 | Since only AR related tax codes  get migrated into zx_tax_priorities_t we do
 | not have a load_tax_results_for_ap  procedure.
 |
 |
 |
 | MODIFICATION HISTORY
 |   04/22/2005   Arnab Sengupta
 |
 +==========================================================================*/

PROCEDURE load_tax_comp_results_for_ar (p_tax_id   NUMBER) AS
BEGIN

/*Include this call to populate zx_tax_priorities_t before loading the results table
  Bug 5691957 */
BEGIN
	zx_tcm_compound_pkg.main;
EXCEPTION WHEN OTHERS THEN
	NULL;
END;

IF L_MULTI_ORG_FLAG = 'Y'
THEN
  INSERT
  INTO zx_update_criteria_results
  (
       tax_code_id,
       org_id,
       tax_code,
       tax_class,
       tax_regime_code,
       tax,
       tax_precedence,
       regime_precedence,
       tax_status_code,
       recovery_type_code,
       frozen,
       country_code,
       effective_from,
       effective_to,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
  )
  SELECT
   	  codes.vat_tax_id               tax_code_id,
          codes.org_id                   org_id,
          codes.tax_code                 tax_code,
          'OUTPUT'                       tax_class,
	   CASE WHEN codes.tax_type = 'VAT' then
	  	      Zx_Migrate_Util.Get_Country(Codes.Org_Id)||'-Tax'
	   ELSE

	               Zx_Migrate_Util.GET_TAX_REGIME(
	  		  codes.tax_type,
	  		  codes.org_id)
            END
                                                 tax_regime_code,
	   NVL(CASE WHEN codes.global_attribute_category IN ('JE.CZ.ARXSUVAT.TAX_ORIGIN',
		                                                  'JE.HU.ARXSUVAT.TAX_ORIGIN',
                                                          'JE.PL.ARXSUVAT.TAX_ORIGIN')
                THEN CASE WHEN LENGTHB(codes.global_attribute1) > 30 THEN
                            RTRIM(SUBSTRB(codes.global_attribute1,1,24))
                     ELSE codes.global_attribute1
                     END
                WHEN codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                         'JL.BR.ARXSUVAT.Tax Information',
                                                         'JL.CO.ARXSUVAT.AR_VAT_TAX')
                THEN (select tax_category
                      from   jl_zz_ar_tx_categ_all
                      where  TO_CHAR(tax_category_id) = codes.global_attribute1
                      and    org_id = codes.org_id)
                ELSE
                   NULL
                END,
	       CASE WHEN codes.tax_type = Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)
                THEN
                RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type),1,30))
                ELSE
	                CASE WHEN LENGTHB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type) > 30
                                   THEN
				         RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type,1,30))
				    ELSE
				         Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type
                                   END
                END
	       )              tax,
         --zxpt.tax_code                         tax,
         zxpt.tax_precedence                     tax_precedence,
	 zxpt.regime_precedence                  regime_precedence,
         DECODE(codes.global_attribute_category,
                'JA.TW.ARXSUVAT.VAT_TAX', nvl(codes.global_attribute1,'STANDARD'),
                DECODE(codes.tax_class,
                       'O', 'STANDARD',
                       'I', 'STANDARD-AR-INPUT',
                       'STANDARD'))                     tax_status_code,
	NULL                               recovery_type_code,
        'N'                                frozen,
        zx_migrate_util.get_country(codes.org_id)  country_code,
	codes.start_date                   effective_from,
	codes.end_date                     effective_to,
        fnd_global.user_id                 created_by,
        sysdate                            creation_date,
        fnd_global.user_id                 last_updated_by,
        sysdate                            last_updated_date,
        fnd_global.conc_login_id           last_update_login
  FROM  ar_vat_tax_all_b          codes,
        ar_system_parameters_all  asp,
	zx_tax_priorities_t       zxpt

  WHERE
       asp.org_id = codes.org_id
 AND   codes.vat_tax_id  = zxpt.tax_id
  -- Eliminate Tax Vendor Tax Codes
  AND   asp.tax_database_view_set = 'O'
  -- Eliminate LTE tax codes
  AND  (codes.global_attribute_category is null OR
        codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
   	 				        'JL.BR.ARXSUVAT.AR_VAT_TAX',
  					        'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  -- Eliminate tax_type = 'LOCATION'
  AND  codes.tax_type <> 'LOCATION'
  --Added following conditions for Sync process
  AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)
  --Rerunability
  AND  NOT EXISTS (SELECT 1
                   FROM   zx_update_criteria_results  zucr
		   WHERE  zucr.tax_code_id =  nvl(p_tax_id,codes.vat_tax_id)
                   AND    zucr.tax_class = 'OUTPUT'
		  );
  ELSE

    INSERT
  INTO zx_update_criteria_results
  (
       tax_code_id,
       org_id,
       tax_code,
       tax_class,
       tax_regime_code,
       tax,
       tax_precedence,
       regime_precedence,
       tax_status_code,
       recovery_type_code,
       frozen,
       country_code,
       effective_from,
       effective_to,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login
  )
  SELECT
   	  codes.vat_tax_id               tax_code_id,
          codes.org_id                   org_id,
          codes.tax_code                 tax_code,
          'OUTPUT'                       tax_class,
	   CASE WHEN codes.tax_type = 'VAT' then
	  	      Zx_Migrate_Util.Get_Country(Codes.Org_Id)||'-Tax'
	   ELSE

	               Zx_Migrate_Util.GET_TAX_REGIME(
	  		  codes.tax_type,
	  		  codes.org_id)
            END
                                                 tax_regime_code,
	   NVL(CASE WHEN codes.global_attribute_category IN ('JE.CZ.ARXSUVAT.TAX_ORIGIN',
		                                                  'JE.HU.ARXSUVAT.TAX_ORIGIN',
                                                          'JE.PL.ARXSUVAT.TAX_ORIGIN')
                THEN CASE WHEN LENGTHB(codes.global_attribute1) > 30 THEN
                            RTRIM(SUBSTRB(codes.global_attribute1,1,24))
                     ELSE codes.global_attribute1
                     END
                WHEN codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                         'JL.BR.ARXSUVAT.Tax Information',
                                                         'JL.CO.ARXSUVAT.AR_VAT_TAX')
                THEN (select tax_category
                      from   jl_zz_ar_tx_categ_all
                      where  TO_CHAR(tax_category_id) = codes.global_attribute1
                      and    org_id = codes.org_id)
                ELSE
                   NULL
                END,
	       CASE WHEN codes.tax_type = Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)
                THEN
                RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type),1,30))
                ELSE
	                CASE WHEN LENGTHB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type) > 30
                                   THEN
				         RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type,1,30))
				    ELSE
				         Zx_Migrate_Util.GET_TAX(
                   			 codes.tax_code,
			                 codes.tax_type)||'-'||codes.tax_type
                                   END
                END
	       )              tax,
         --zxpt.tax_code                         tax,
         zxpt.tax_precedence                     tax_precedence,
	 zxpt.regime_precedence                  regime_precedence,
         DECODE(codes.global_attribute_category,
                'JA.TW.ARXSUVAT.VAT_TAX', nvl(codes.global_attribute1,'STANDARD'),
                DECODE(codes.tax_class,
                       'O', 'STANDARD',
                       'I', 'STANDARD-AR-INPUT',
                       'STANDARD'))                     tax_status_code,
	NULL                               recovery_type_code,
        'N'                                frozen,
        zx_migrate_util.get_country(codes.org_id)  country_code,
	codes.start_date                   effective_from,
	codes.end_date                     effective_to,
        fnd_global.user_id                 created_by,
        sysdate                            creation_date,
        fnd_global.user_id                 last_updated_by,
        sysdate                            last_updated_date,
        fnd_global.conc_login_id           last_update_login
  FROM  ar_vat_tax_all_b          codes,
        ar_system_parameters_all  asp,
	zx_tax_priorities_t       zxpt

  WHERE
       asp.org_id = codes.org_id
 AND   codes.org_id = l_org_id
 AND   codes.vat_tax_id  = zxpt.tax_id
  -- Eliminate Tax Vendor Tax Codes
  AND   asp.tax_database_view_set = 'O'
  -- Eliminate LTE tax codes
  AND  (codes.global_attribute_category is null OR
        codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
   	 				        'JL.BR.ARXSUVAT.AR_VAT_TAX',
  					        'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  -- Eliminate tax_type = 'LOCATION'
  AND  codes.tax_type <> 'LOCATION'
  --Added following conditions for Sync process
  AND  codes.vat_tax_id  = nvl(p_tax_id, codes.vat_tax_id)
  --Rerunability
  AND  NOT EXISTS (SELECT 1
                   FROM   zx_update_criteria_results  zucr
		   WHERE  zucr.tax_code_id =  nvl(p_tax_id,codes.vat_tax_id)
                   AND    zucr.tax_class = 'OUTPUT'
		  );
  END IF;
END load_tax_comp_results_for_ar;


/*===========================================================================+
 | PROCEDURE
 | load_results_for_intercomp_ap
 |
 | DESCRIPTION
 | Populates data into zx_update_criteria_results table for AP Tax Codes
 | that is used in intercompany transaction.
 |
 | MTL_INTERCOMPANY_PARAMTERS table stores information about two OUs that
 | are used for intercompany transactions. The customer related information is
 | used by the shipping organization (SHIP_ORGANIZATION_ID) for AR invoicing
 | purposes. The supplier related information is used by the selling organization
 | (SELL_ORGANIZATION_ID) for AP invoicing purposes.
 |
 | Tax Regime Code derived from AP Tax Code (used to create AP invoice) is
 | overriden by that of AR Tax Code (used to create AR invoice).
 |
 | Set zx_criteria_results.intercompany_flag to 'Y' for AP Tax Codes/AR Tax Codes
 | that are used for intercompany transactions.
 |
 |
 | MODIFICATION HISTORY
 |   04/29/2005   Yoshimichi Konishi  Created
 |
 +==========================================================================*/
PROCEDURE load_results_for_intercomp_ap (p_tax_id   NUMBER) AS
BEGIN
INSERT
INTO zx_update_criteria_results
(
    tax_code_id,
    org_id,
    tax_code,
    tax_class,
    tax_regime_code,
    tax,
    tax_status_code,
    recovery_type_code,
    frozen,
    country_code,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    effective_from,
    effective_to,
    intercompany_flag
)
SELECT
      DISTINCT
      ap_codes.tax_id                   tax_code_id,
      ap_codes.org_id                   org_id,
      ap_codes.name                     tax_code,
      'INPUT'                           tax_class,
      Zx_Migrate_Util.GET_TAX_REGIME(
                      ap_codes.tax_type,
                      ap_codes.org_id)   tax_regime_code,
	    DECODE(ap_codes.global_attribute_category,
		  'JE.CZ.ARXSUVAT.TAX_ORIGIN',
        CASE WHEN LENGTHB(ap_codes.global_attribute1) > 30 THEN
             RTRIM(SUBSTRB(ap_codes.global_attribute1,1,24))
             ELSE ap_codes.global_attribute1 END,
      'JE.HU.ARXSUVAT.TAX_ORIGIN',
        CASE WHEN LENGTHB(ap_codes.global_attribute1) > 30 THEN
             RTRIM(SUBSTRB(ap_codes.global_attribute1,1,24))
             ELSE ap_codes.global_attribute1 END,
		  'JE.PL.ARXSUVAT.TAX_ORIGIN',
        CASE WHEN LENGTHB(ap_codes.global_attribute1) > 30 THEN
             RTRIM(SUBSTRB(ap_codes.global_attribute1,1,24))
             ELSE ap_codes.global_attribute1 END,
		   RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
			               ap_codes.name,
			               ap_codes.tax_type),1,30))
	 	 ) 	 	 tax,
      DECODE(ap_codes.global_attribute_category,
            'JA.TW.ARXSUVAT.VAT_TAX',
             nvl(ap_codes.global_attribute1,'STANDARD'),
            'STANDARD')                  tax_status_code,
      'STANDARD'                         recovery_type_code,
      'N'                                frozen,
      zx_migrate_util.get_country(ap_codes.org_id)  country_code,
      fnd_global.user_id                 created_by,
      sysdate                            creation_date,
      fnd_global.user_id                 last_updated_by,
      sysdate                            last_updated_date,
      fnd_global.conc_login_id           last_update_login,
      ap_codes.start_date                effective_from,
      ap_codes.inactive_date             effective_to,
      'Y'                                intercompany_flag
FROM  ap_tax_codes_all              ap_codes,
      ar_vat_tax_all_b              ar_codes,
      financials_system_params_all  fsp,
      mtl_intercompany_parameters   intcomp
WHERE ap_codes.tax_type NOT IN ('AWT','TAX_GROUP')
AND   decode(l_multi_org_flag,'N',l_org_id,ap_codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,fsp.org_id)
AND   decode(l_multi_org_flag,'N',l_org_id,ap_codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,intcomp.sell_organization_id)
AND   decode(l_multi_org_flag,'N',l_org_id,ar_codes.org_id) =  decode(l_multi_org_flag,'N',l_org_id,intcomp.ship_organization_id)
AND   ap_codes.name = ar_codes.tax_code
AND   intcomp.flow_type = 2 -- Bug 4697235 : Specify flow_type=2 which is procurement
-- Sync process
AND   ap_codes.tax_id  = nvl(p_tax_id,ap_codes.tax_id)
-- Rerunability
AND   NOT EXISTS (SELECT 1
                  FROM   zx_update_criteria_results  zucr
                  WHERE  zucr.tax_code_id =  nvl(p_tax_id,ap_codes.tax_id)
                  AND    zucr.tax_class = 'INPUT'
                 );

END load_results_for_intercomp_ap;




/*===========================================================================+
 | PROCEDURE
 | load_results_for_intercomp_ar
 |
 | DESCRIPTION
 | Populates data into zx_update_criteria_results table for AR Tax Codes
 | that is used in intercompany transaction.
 |
 | MTL_INTERCOMPANY_PARAMTERS table stores information about two OUs that
 | are used for intercompany transactions. The customer related information is
 | used by the shipping organization (SHIP_ORGANIZATION_ID) for AR invoicing
 | purposes. The supplier related information is used by the selling organization
 | (SELL_ORGANIZATION_ID) for AP invoicing purposes.
 |
 | Tax Regime Code derived from AP Tax Code (used to create AP invoice) is
 | overriden by that of AR Tax Code (used to create AR invoice).
 |
 | Set zx_criteria_results.intercompany_flag to 'Y' for AP Tax Codes/AR Tax Codes
 | that are used for intercompany transactions.
 |
 |
 | MODIFICATION HISTORY
 |   04/29/2005   Yoshimichi Konishi  Created
 |
 +==========================================================================*/
PROCEDURE load_results_for_intercomp_ar (p_tax_id   NUMBER) AS
BEGIN

  INSERT
  INTO zx_update_criteria_results
  (
       tax_code_id,
       org_id,
       tax_code,
       tax_class,
       tax_regime_code,
       tax,
       tax_status_code,
       recovery_type_code,
       frozen,
       country_code,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       effective_from,
       effective_to,
       intercompany_flag
  )
  SELECT
	DISTINCT
   	  ar_codes.vat_tax_id               tax_code_id,
          decode(l_multi_org_flag,'N',l_org_id,ar_codes.org_id)                 org_id,
	  ar_codes.tax_code                 tax_code,
          'OUTPUT'                          tax_class,
          Zx_Migrate_Util.GET_TAX_REGIME(
	  		  ar_codes.tax_type,
	  		  decode(l_multi_org_flag,'N',l_org_id,ar_codes.org_id))      tax_regime_code,
          -- YK:02/09/2005:Needs substrb
           NVL(CASE WHEN  ar_codes.global_attribute_category IN ('JE.CZ.ARXSUVAT.TAX_ORIGIN',
		                                                         'JE.HU.ARXSUVAT.TAX_ORIGIN',
                                                                 'JE.PL.ARXSUVAT.TAX_ORIGIN')
                   THEN  CASE WHEN ar_codes.global_attribute1 > 30 THEN
                           RTRIM(SUBSTRB(ar_codes.global_attribute1,1,24))
                         ELSE ar_codes.global_attribute1
                         END
                   WHEN  ar_codes.global_attribute_category IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
                                                                'JL.BR.ARXSUVAT.Tax Information',
                                                                'JL.CO.ARXSUVAT.AR_VAT_TAX')
                   THEN (select tax_category
                         from   jl_zz_ar_tx_categ_all
                         where  TO_CHAR(tax_category_id) = ar_codes.global_attribute1
                         and    org_id = ar_codes.org_id)
               ELSE
                   NULL
               END,
               RTRIM(SUBSTRB(Zx_Migrate_Util.GET_TAX(
                   			 ar_codes.tax_code,
			                 ar_codes.tax_type),1,30)))                     tax,
         DECODE(ar_codes.global_attribute_category,
                'JA.TW.ARXSUVAT.VAT_TAX', nvl(ar_codes.global_attribute1,'STANDARD'),
                DECODE(ar_codes.tax_class,
                       'O', 'STANDARD',
                       'I', 'STANDARD-AR-INPUT',
                       'STANDARD'))                     tax_status_code,
	NULL                               recovery_type_code,
        'N'                                frozen,
        zx_migrate_util.get_country(decode(l_multi_org_flag,'N',l_org_id,ar_codes.org_id))  country_code,
        fnd_global.user_id                 created_by,
        sysdate                            creation_date,
        fnd_global.user_id                 last_updated_by,
        sysdate                            last_updated_date,
        fnd_global.conc_login_id           last_update_login,
        ar_codes.start_date                effective_from,
        ar_codes.end_date                  effective_to,
        'Y'                                intercompany_flag
  FROM  ar_vat_tax_all_b             ar_codes,
        ap_tax_codes_all             ap_codes,
        ar_system_parameters_all     asp,
        mtl_intercompany_parameters  intcomp
  WHERE ar_codes.tax_type <> 'TAX_GROUP'
  AND   decode(l_multi_org_flag,'N',l_org_id,asp.org_id) = decode(l_multi_org_flag,'N',l_org_id,ar_codes.org_id)
  AND   decode(l_multi_org_flag,'N',l_org_id,ap_codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,intcomp.sell_organization_id)
  AND   decode(l_multi_org_flag,'N',l_org_id,ar_codes.org_id) = decode(l_multi_org_flag,'N',l_org_id,intcomp.ship_organization_id)
  AND   ap_codes.name = ar_codes.tax_code
  AND   intcomp.flow_type = 2 -- Bug 4697235 : Specify flow_type=2 which is for procurement
  -- Eliminate Tax Vendor Tax Codes
  AND   asp.tax_database_view_set   =  'O'
  -- Eliminate LTE tax codes
  -- Bug 4688151 : Do not eliminate LTE tax codes
  -- AND  (ar_codes.global_attribute_category is null OR
  --       ar_codes.global_attribute_category NOT IN ('JL.AR.ARXSUVAT.AR_VAT_TAX',
  --	 				        'JL.BR.ARXSUVAT.AR_VAT_TAX',
  --					        'JL.CO.ARXSUVAT.AR_VAT_TAX'))
  -- Eliminate tax_type = 'LOCATION'
  AND  ar_codes.tax_type <> 'LOCATION'
  --Added following conditions for Sync process
  AND  ar_codes.vat_tax_id  = nvl(p_tax_id, ar_codes.vat_tax_id)
  --Rerunability
  AND  NOT EXISTS (SELECT 1
                   FROM   zx_update_criteria_results  zucr
		   WHERE  zucr.tax_code_id =  nvl(p_tax_id,ar_codes.vat_tax_id)
                   AND    zucr.tax_class = 'OUTPUT'
		  );
END load_results_for_intercomp_ar;


/*===========================================================================+
 | PROCEDURE
 | load_regimes
 |
 | DESCRIPTION
 | 1. Populates data into zx_regimes_b table based on data in
 |    zx_update_criteria_results table for normal tax codes.
 | 2. Populates data into zx_regimes_b for Brazilian IPI
 | 3. Populates data into zx_regimes_b for Brazilian ISS
 | 4. Populates data into zx_regimes_b for GTE US Sales Tax Regimes
 | 5. Populates data into zx_regimes_b for Tax Vendor Regimes
 | 6. Populates data into zx_regimes_tl
 |
 |
 | NOTES
 | 1. Select distinct of tax_regime_code and country_code. Update Criteria UI
 |    makes sure that this combination is unique.
 | 2. Tax Regime Code for unassigned offset tax codes handling. It is County
 |    Code '-' OFFSET by default. User could override it through Criteria UI.
 |
 | MODIFICATION HISTORY
 |   02/15/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE load_regimes AS
  -- ****** TYPES ******
  TYPE denorm_tbl_type IS TABLE OF zx_migrate_tax_def_common.loc_str_rec_type INDEX BY BINARY_INTEGER;

  -- ****** VARIABLES ******
  null_loc_str_rec           loc_str_rec_type;
  denorm_tbl                 denorm_tbl_type;
  denorm_err_tbl             denorm_tbl_type;
  cnt                        PLS_INTEGER;
  i                          PLS_INTEGER;
  d                          PLS_INTEGER;
  k                          PLS_INTEGER;
  l_temp_id_flex_num         NUMBER;       --fnd_id_flex_segments.id_flex_num%TYPE
  l_temp_seg_num             NUMBER(15);   --fnd_id_flex_segments.segment_num%TYPE
  l_temp_seg_att_type        VARCHAR2(30); --fnd_segment_attribute_values.segment_attribute_type%TYPE
  l_temp_tax_currency_code   VARCHAR2(15); --ar_system_parameters_all.tax_currency_code%TYPE
  l_temp_tax_precision       NUMBER(1);    --ar_system_parameters_all.tax_precision%TYPE
  l_temp_tax_mau             NUMBER;       --ar_system_parameters_all.tax_minimum_accountable_unit%TYPE
  l_temp_country_code        VARCHAR2(60); --ar_system_parameters_all.default_country%TYPE
  l_temp_rounding_rule_code  VARCHAR2(30); --ar_system_parameters_all.tax_rounding_rule%TYPE
  l_temp_tax_invoice_print   VARCHAR2(30); --ar_system_parameters_all.tax_invoice_print%TYPE
  l_temp_allow_rounding_override   VARCHAR2(30); --ar_system_parameters_all.tax_rounding_allow_override%TYPE
  l_temp_org_id              NUMBER(15);    --ar_system_parameters_all.org_id%TYPE
  l_tax_regime_name          VARCHAR2(80);  --zx_regimes_tl.tax_regime_name%TYPE
  l_tax_regime_code          VARCHAR2(30);  --zx_regimes_b.tax_regime_code%TYPE


  -- ****** CURSORS ******
  CURSOR loc_str_cur IS
  SELECT  DISTINCT
          segment.id_flex_num                id_flex_num,
          asp.default_country                default_country,
          segment.segment_num                seg_num,
          qual.segment_attribute_type        seg_att_type,
          decode(l_multi_org_flag,'N',l_org_id,asp.org_id)  org_id,
          NVL(asp.tax_currency_code, gsob.currency_code)
                                             tax_currency_code,
          asp.tax_precision                  tax_precision,
          asp.tax_minimum_accountable_unit   tax_mau,
          asp.tax_rounding_rule              rounding_rule_code,
          asp.tax_rounding_allow_override    allow_rounding_override
  FROM    fnd_id_flex_structures         str,
          fnd_id_flex_segments           segment,
	  fnd_segment_attribute_values   qual,
	  ar_system_parameters_all       asp,
	  ar_vat_tax_all_b               avt,
          gl_sets_of_books               gsob
  WHERE   str.id_flex_code = 'RLOC'
  AND     str.application_id = 222
  AND     str.application_id = segment.application_id
  AND     str.id_flex_num = segment.id_flex_num
  AND     str.id_flex_code = segment.id_flex_code
  AND     segment.application_id = 222
  AND     segment.id_flex_code = 'RLOC'
  AND     segment.application_id= qual.application_id
  AND     segment.id_flex_code = qual.id_flex_code
  AND     segment.id_flex_num = qual.id_flex_num
  AND     segment.application_column_name = qual.application_column_name
  AND     segment.enabled_flag = 'Y'
  AND     qual.attribute_value = 'Y'
  AND     qual.segment_attribute_type NOT IN ('EXEMPT_LEVEL', 'TAX_ACCOUNT')
  AND     asp.location_structure_id = str.id_flex_num
  AND     decode(l_multi_org_flag,'N',l_org_id,asp.org_id) = decode(l_multi_org_flag,'N',l_org_id,avt.org_id)
  AND     avt.tax_type = 'LOCATION'
  AND     asp.tax_database_view_set IN ('O', '_V', '_A')  -- Bug 4880905
  AND     asp.set_of_books_id = gsob.set_of_books_id
  ORDER   BY 1,2,3,4,5;

BEGIN
/*--------------------------------------------------------------------------
 |
 |  Populating zx_regimes_b from zx_update_criteria_results
 |
 +---------------------------------------------------------------------------*/

INSERT INTO ZX_REGIMES_B
(
	TAX_REGIME_CODE                        ,
	PARENT_REGIME_CODE                     ,
	REGIME_PRECEDENCE		       ,
	HAS_SUB_REGIME_FLAG                    ,
	COUNTRY_OR_GROUP_CODE                  ,
	COUNTRY_CODE                           ,
	GEOGRAPHY_TYPE                         ,
	EFFECTIVE_FROM                         ,
	EFFECTIVE_TO                           ,
	EXCHANGE_RATE_TYPE                     ,
	TAX_CURRENCY_CODE                      ,
	THRSHLD_GROUPING_LVL_CODE              ,
	ROUNDING_RULE_CODE                     ,
	TAX_PRECISION                          ,
	MINIMUM_ACCOUNTABLE_UNIT               ,
	TAX_STATUS_RULE_FLAG                   ,
	DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
	APPLICABILITY_RULE_FLAG                ,
	PLACE_OF_SUPPLY_RULE_FLAG              ,
	TAX_CALC_RULE_FLAG                     ,
	TAXABLE_BASIS_THRSHLD_FLAG             ,
	TAX_RATE_THRSHLD_FLAG                  ,
	TAX_AMT_THRSHLD_FLAG                   ,
	TAX_RATE_RULE_FLAG                     ,
	TAXABLE_BASIS_RULE_FLAG                ,
	DEF_INCLUSIVE_TAX_FLAG                 ,
	HAS_OTHER_JURISDICTIONS_FLAG           ,
	ALLOW_ROUNDING_OVERRIDE_FLAG           ,
	ALLOW_EXEMPTIONS_FLAG                  ,
	ALLOW_EXCEPTIONS_FLAG                  ,
	ALLOW_RECOVERABILITY_FLAG              ,
	--RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
	AUTO_PRVN_FLAG                         ,
	HAS_TAX_DET_DATE_RULE_FLAG             ,
	HAS_EXCH_RATE_DATE_RULE_FLAG           ,
	HAS_TAX_POINT_DATE_RULE_FLAG           ,
	USE_LEGAL_MSG_FLAG                     ,
	REGN_NUM_SAME_AS_LE_FLAG               ,
	DEF_REC_SETTLEMENT_OPTION_CODE         ,
	RECORD_TYPE_CODE                       ,
	ATTRIBUTE1                             ,
	ATTRIBUTE2                             ,
	ATTRIBUTE3                             ,
	ATTRIBUTE4                             ,
	ATTRIBUTE5                             ,
	ATTRIBUTE6                             ,
	ATTRIBUTE7                             ,
	ATTRIBUTE8                             ,
	ATTRIBUTE9                             ,
	ATTRIBUTE10                            ,
	ATTRIBUTE11                            ,
	ATTRIBUTE12                            ,
	ATTRIBUTE13                            ,
	ATTRIBUTE14                            ,
	ATTRIBUTE15                            ,
	ATTRIBUTE_CATEGORY                     ,
	DEF_REGISTR_PARTY_TYPE_CODE            ,
	REGISTRATION_TYPE_RULE_FLAG            ,
	TAX_INCLUSIVE_OVERRIDE_FLAG            ,
	CROSS_REGIME_COMPOUNDING_FLAG          ,
	TAX_REGIME_ID                          ,
	GEOGRAPHY_ID                           ,
	THRSHLD_CHK_TMPLT_CODE                 ,
	PERIOD_SET_NAME                        ,
	REP_TAX_AUTHORITY_ID                   ,
	COLL_TAX_AUTHORITY_ID                  ,
 	CREATED_BY              	       ,
	CREATION_DATE                          ,
	LAST_UPDATED_BY                        ,
	LAST_UPDATE_DATE                       ,
	LAST_UPDATE_LOGIN                      ,
	REQUEST_ID                             ,
	PROGRAM_APPLICATION_ID                 ,
	PROGRAM_ID                             ,
	PROGRAM_LOGIN_ID  		       ,
	OBJECT_VERSION_NUMBER
)
SELECT
	L_TAX_REGIME_CODE                      ,
	NULL                                   ,--PARENT_REGIME_CODE
        L_REGIME_PRECEDENCE		       ,--REGIME_ PRECEDENCE
       'N'                                     ,--HAS_SUB_REGIME_FLAG
	'COUNTRY'                              ,--COUNTRY_OR_GROUP_CODE
        L_COUNTRY_CODE 			       ,--COUNTRY_CODE
	NULL                                   ,--GEOGRAPHY_TYPE
	l_min_start_date                       ,--EFFECTIVE_FROM
	NULL                                   ,--EFFECTIVE_TO
	NULL                                   ,--EXCHANGE_RATE_TYPE
	NULL                                   ,--TAX_CURRENCY_CODE
	NULL                                   ,--THRSHLD_GROUPING_LVL_CODE
	NULL                                   ,--ROUNDING_RULE_CODE
	NULL                                   ,--TAX_PRECISION
	NULL                                   ,--MINIMUM_ACCOUNTABLE_UNIT
	'N'                                    ,--TAX_STATUS_RULE_FLAG
	'SHIP_FROM'                            ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
       'N'                                     ,--APPLICABILITY_RULE_FLAG
       'N'                                     ,--PLACE_OF_SUPPLY_RULE_FLAG
       'N'                                     ,--TAX_CALC_RULE_FLAG
       'N'                                     ,--TAXABLE_BASIS_THRSHLD_FLAG
       'N'                                     ,--TAX_RATE_THRSHLD_FLAG
       'N'                                     ,--TAX_AMT_THRSHLD_FLAG
       'N'                                     ,--TAX_RATE_RULE_FLAG
       'N'                                     ,--TAXABLE_BASIS_RULE_FLAG
       'N'                                     ,--DEF_INCLUSIVE_TAX_FLAG
       'N'                                     ,--HAS_OTHER_JURISDICTIONS_FLAG
       'N'                                     ,--ALLOW_ROUNDING_OVERRIDE_FLAG
       'N'                                     ,--ALLOW_EXEMPTIONS_FLAG  Bug 4204464 Bug 5204559
       'N'                                     ,--ALLOW_EXCEPTIONS_FLAG  Bug 4204464 Bug 5204559
       'N'                                     ,--ALLOW_RECOVERABILITY_FLAG
       -- 'N'                                  ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
       'N'                                     ,--AUTO_PRVN_FLAG
       'N'                                     ,--HAS_TAX_DET_DATE_RULE_FLAG
       'N'                                     ,--HAS_EXCH_RATE_DATE_RULE_FLAG
       'N'                                     ,--HAS_TAX_POINT_DATE_RULE_FLAG
       'N'                                     ,--USE_LEGAL_MSG_FLAG
       'N'                                     ,--REGN_NUM_SAME_AS_LE_FLAG
        NULL                                   ,--DEF_REC_SETTLE_OPTION_CODE
	'MIGRATED'                             ,--RECORD_TYPE_CODE
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	'SHIP_FROM_PARTY'                      ,--DEF_REGISTR_PARTY_TYPE_CODE
	'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
	'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG
        DECODE(L_REGIME_PRECEDENCE,NULL,'N','Y') ,--CROSS_REGIME_COMPOUNDING_FLAG
	ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
	NULL                                   ,--GEOGRAPHY_ID
	NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
	NULL                                   ,--PERIOD_SET_NAME
	NULL                                   ,--REP_TAX_AUTHORITY_ID
	NULL                                   ,--COLL_TAX_AUTHORITY_ID
        fnd_global.user_id                     ,
	SYSDATE                                ,
	fnd_global.user_id                     ,
	SYSDATE                                ,
	fnd_global.conc_login_id               ,
	fnd_global.conc_request_id             ,--Request Id
	fnd_global.prog_appl_id                ,--Program Application ID
	fnd_global.conc_program_id             ,--Program Id
	fnd_global.conc_login_id               ,--Program Login ID
	1
FROM
(
   SELECT  DISTINCT
           zucr.tax_regime_code   l_tax_regime_code,
           zucr.country_code      l_country_code,
	   zucr.regime_precedence l_regime_precedence
   FROM    zx_update_criteria_results zucr
   WHERE   NOT EXISTS (SELECT 1
                       FROM   zx_regimes_b zrb
                       WHERE  zrb.tax_regime_code = zucr.tax_regime_code
                       )

);


IF zx_migrate_util.is_installed('AP') = 'Y' THEN
/*------------------------------------------------------------------------------------
 |
 |  For Brazilian Regimes : BR-IPI when BR-ICMS Regime exists
 |
 |  YK:02/15/2005: The following sql in P2P tax def migration code is splitted into
 |                 two to avoid dynamic sql call to fetch sequence.
 |
 +-------------------------------------------------------------------------------------*/
INSERT INTO
ZX_REGIMES_B
(
	TAX_REGIME_CODE                        ,
	PARENT_REGIME_CODE                     ,
	HAS_SUB_REGIME_FLAG                    ,
	COUNTRY_OR_GROUP_CODE                  ,
	COUNTRY_CODE                           ,
	GEOGRAPHY_TYPE                         ,
	EFFECTIVE_FROM                         ,
	EFFECTIVE_TO                           ,
	EXCHANGE_RATE_TYPE                     ,
	TAX_CURRENCY_CODE                      ,
	THRSHLD_GROUPING_LVL_CODE              ,
	ROUNDING_RULE_CODE                     ,
	TAX_PRECISION                          ,
	MINIMUM_ACCOUNTABLE_UNIT               ,
	TAX_STATUS_RULE_FLAG                   ,
	DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
	APPLICABILITY_RULE_FLAG                ,
	PLACE_OF_SUPPLY_RULE_FLAG              ,
	TAX_CALC_RULE_FLAG                     ,
	TAXABLE_BASIS_THRSHLD_FLAG             ,
	TAX_RATE_THRSHLD_FLAG                  ,
	TAX_AMT_THRSHLD_FLAG                   ,
	TAX_RATE_RULE_FLAG                     ,
	TAXABLE_BASIS_RULE_FLAG                ,
	DEF_INCLUSIVE_TAX_FLAG                 ,
	HAS_OTHER_JURISDICTIONS_FLAG           ,
	ALLOW_ROUNDING_OVERRIDE_FLAG           ,
	ALLOW_EXEMPTIONS_FLAG                  ,
	ALLOW_EXCEPTIONS_FLAG                  ,
	ALLOW_RECOVERABILITY_FLAG              ,
	-- RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
	AUTO_PRVN_FLAG                         ,
	HAS_TAX_DET_DATE_RULE_FLAG             ,
	HAS_EXCH_RATE_DATE_RULE_FLAG           ,
	HAS_TAX_POINT_DATE_RULE_FLAG           ,
	USE_LEGAL_MSG_FLAG                     ,
	REGN_NUM_SAME_AS_LE_FLAG               ,
	DEF_REC_SETTLEMENT_OPTION_CODE         ,
	RECORD_TYPE_CODE                       ,
	ATTRIBUTE1                             ,
	ATTRIBUTE2                             ,
	ATTRIBUTE3                             ,
	ATTRIBUTE4                             ,
	ATTRIBUTE5                             ,
	ATTRIBUTE6                             ,
	ATTRIBUTE7                             ,
	ATTRIBUTE8                             ,
	ATTRIBUTE9                             ,
	ATTRIBUTE10                            ,
	ATTRIBUTE11                            ,
	ATTRIBUTE12                            ,
	ATTRIBUTE13                            ,
	ATTRIBUTE14                            ,
	ATTRIBUTE15                            ,
	ATTRIBUTE_CATEGORY                     ,
	DEF_REGISTR_PARTY_TYPE_CODE            ,
	REGISTRATION_TYPE_RULE_FLAG            ,
	TAX_INCLUSIVE_OVERRIDE_FLAG            ,
	REGIME_PRECEDENCE                      ,
	CROSS_REGIME_COMPOUNDING_FLAG          ,
	TAX_REGIME_ID                          ,
	GEOGRAPHY_ID                           ,
	THRSHLD_CHK_TMPLT_CODE                 ,
	PERIOD_SET_NAME                        ,
	REP_TAX_AUTHORITY_ID                   ,
	COLL_TAX_AUTHORITY_ID                  ,
 	CREATED_BY              	       ,
	CREATION_DATE                          ,
	LAST_UPDATED_BY                        ,
	LAST_UPDATE_DATE                       ,
	LAST_UPDATE_LOGIN                      ,
	REQUEST_ID                             ,
	PROGRAM_APPLICATION_ID                 ,
	PROGRAM_ID                             ,
	PROGRAM_LOGIN_ID		       ,
	OBJECT_VERSION_NUMBER
)
SELECT
       'BR-IPI'                                ,--TAX_REGIME_CODE
	NULL                                   ,--PARENT_REGIME_CODE
        'N'                                    ,--HAS_SUB_REGIME_FLAG
	'COUNTRY'                              ,--COUNTRY_OR_GROUP_CODE
	'BR'                                   ,--COUNTRY_CODE
	NULL                                   ,--GEOGRAPHY_TYPE
	l_min_start_date                       ,--EFFECTIVE_FROM
	NULL                                   ,--EFFECTIVE_TO
	NULL                                   ,--EXCHANGE_RATE_TYPE
	NULL                                   ,--TAX_CURRENCY_CODE
	NULL                                   ,--THRSHLD_GROUPING_LVL_CODE
	NULL                                   ,--ROUNDING_RULE_CODE
	NULL                                   ,--TAX_PRECISION
	NULL                                   ,--MINIMUM_ACCOUNTABLE_UNIT
	'N'                                    ,--TAX_STATUS_RULE_FLAG
	'SHIP_FROM'                            ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
        'N'                                    ,--APPLICABILITY_RULE_FLAG
	'N'                                    ,--PLACE_OF_SUPPLY_RULE_FLAG
	'N'                                    ,--TAX_CALC_RULE_FLAG
	'N'                                    ,--TAXABLE_BASIS_THRSHLD_FLAG
	'N'                                    ,--TAX_RATE_THRSHLD_FLAG
	'N'                                    ,--TAX_AMT_THRSHLD_FLAG
	'N'                                    ,--TAX_RATE_RULE_FLAG
	'N'                                    ,--TAXABLE_BASIS_RULE_FLAG
	'N'                                    ,--DEF_INCLUSIVE_TAX_FLAG
	'N'                                    ,--HAS_OTHER_JURISDICTIONS_FLAG
	'N'                                    ,--ALLOW_ROUNDING_OVERRIDE_FLAG
	'Y'                                    ,--ALLOW_EXEMPTIONS_FLAG
	'Y'                                    ,--ALLOW_EXCEPTIONS_FLAG
	'N'                                    ,--ALLOW_RECOVERABILITY_FLAG
	-- 'N'                                    ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
	'N'                                    ,--AUTO_PRVN_FLAG
	'N'                                    ,--HAS_TAX_DET_DATE_RULE_FLAG
	'N'                                    ,--HAS_EXCH_RATE_DATE_RULE_FLAG
	'N'                                    ,--HAS_TAX_POINT_DATE_RULE_FLAG
	'N'                                    ,--USE_LEGAL_MSG_FLAG
	'N'                                    ,--REGN_NUM_SAME_AS_LE_FLAG
	NULL                                   ,--DEF_REC_SETTLEMENT_OPTION_CODE
	'MIGRATED'                             ,--RECORD_TYPE_CODE
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	'SHIP_FROM_PARTY'                      ,--DEF_REGISTR_PARTY_TYPE_CODE
	'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
	'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG
	NULL                                   ,--REGIME_PRECEDENCE
	'N'                                    ,--CROSS_REGIME_COMPOUNDING_FLAG
	ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
	NULL                                   ,--GEOGRAPHY_ID
	NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
	NULL                                   ,--PERIOD_SET_NAME
	NULL                                   ,--REP_TAX_AUTHORITY_ID
	NULL                                   ,--COLL_TAX_AUTHORITY_ID
        fnd_global.user_id                     ,
	SYSDATE                                ,
	fnd_global.user_id                     ,
	SYSDATE                                ,
	fnd_global.conc_login_id               ,
	fnd_global.conc_request_id             ,--Request Id
	fnd_global.prog_appl_id                ,--Program Application ID
	fnd_global.conc_program_id             ,--Program Id
	fnd_global.conc_login_id               ,--Program Login ID
	1
FROM    zx_regimes_b
WHERE   tax_regime_code = 'BR-ICMS'
AND     country_code    = 'BR'
AND     NOT EXISTS (SELECT 1
                    FROM   zx_regimes_b
                    WHERE  tax_regime_code = 'BR-IPI');

/*--------------------------------------------------------------------------
 |
 |  For Brazilian Regimes : BR-ISS when BR-IPI Regime exists
 |
 |  YK:02/15/2005: The following sql in P2P tax def migration code is splitted into
 |                 two to avoid dynamic sql call to fetch sequence.
 |
 +---------------------------------------------------------------------------*/
INSERT INTO
ZX_REGIMES_B
(
	TAX_REGIME_CODE                        ,
	PARENT_REGIME_CODE                     ,
	HAS_SUB_REGIME_FLAG                    ,
	COUNTRY_OR_GROUP_CODE                  ,
	COUNTRY_CODE                           ,
	GEOGRAPHY_TYPE                         ,
	EFFECTIVE_FROM                         ,
	EFFECTIVE_TO                           ,
	EXCHANGE_RATE_TYPE                     ,
	TAX_CURRENCY_CODE                      ,
	THRSHLD_GROUPING_LVL_CODE              ,
	ROUNDING_RULE_CODE                     ,
	TAX_PRECISION                          ,
	MINIMUM_ACCOUNTABLE_UNIT               ,
	TAX_STATUS_RULE_FLAG                   ,
	DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
	APPLICABILITY_RULE_FLAG                ,
	PLACE_OF_SUPPLY_RULE_FLAG              ,
	TAX_CALC_RULE_FLAG                     ,
	TAXABLE_BASIS_THRSHLD_FLAG             ,
	TAX_RATE_THRSHLD_FLAG                  ,
	TAX_AMT_THRSHLD_FLAG                   ,
	TAX_RATE_RULE_FLAG                     ,
	TAXABLE_BASIS_RULE_FLAG                ,
	DEF_INCLUSIVE_TAX_FLAG                 ,
	HAS_OTHER_JURISDICTIONS_FLAG           ,
	ALLOW_ROUNDING_OVERRIDE_FLAG           ,
	ALLOW_EXEMPTIONS_FLAG                  ,
	ALLOW_EXCEPTIONS_FLAG                  ,
	ALLOW_RECOVERABILITY_FLAG              ,
	-- RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
	AUTO_PRVN_FLAG                         ,
	HAS_TAX_DET_DATE_RULE_FLAG             ,
	HAS_EXCH_RATE_DATE_RULE_FLAG           ,
	HAS_TAX_POINT_DATE_RULE_FLAG           ,
	USE_LEGAL_MSG_FLAG                     ,
	REGN_NUM_SAME_AS_LE_FLAG               ,
	DEF_REC_SETTLEMENT_OPTION_CODE         ,
	RECORD_TYPE_CODE                       ,
	ATTRIBUTE1                             ,
	ATTRIBUTE2                             ,
	ATTRIBUTE3                             ,
	ATTRIBUTE4                             ,
	ATTRIBUTE5                             ,
	ATTRIBUTE6                             ,
	ATTRIBUTE7                             ,
	ATTRIBUTE8                             ,
	ATTRIBUTE9                             ,
	ATTRIBUTE10                            ,
	ATTRIBUTE11                            ,
	ATTRIBUTE12                            ,
	ATTRIBUTE13                            ,
	ATTRIBUTE14                            ,
	ATTRIBUTE15                            ,
	ATTRIBUTE_CATEGORY                     ,
	DEF_REGISTR_PARTY_TYPE_CODE            ,
	REGISTRATION_TYPE_RULE_FLAG            ,
	TAX_INCLUSIVE_OVERRIDE_FLAG            ,
	REGIME_PRECEDENCE                      ,
	CROSS_REGIME_COMPOUNDING_FLAG          ,
	TAX_REGIME_ID                          ,
	GEOGRAPHY_ID                           ,
	THRSHLD_CHK_TMPLT_CODE                 ,
	PERIOD_SET_NAME                        ,
	REP_TAX_AUTHORITY_ID                   ,
	COLL_TAX_AUTHORITY_ID                  ,
 	CREATED_BY              	       ,
	CREATION_DATE                          ,
	LAST_UPDATED_BY                        ,
	LAST_UPDATE_DATE                       ,
	LAST_UPDATE_LOGIN                      ,
	REQUEST_ID                             ,
	PROGRAM_APPLICATION_ID                 ,
	PROGRAM_ID                             ,
	PROGRAM_LOGIN_ID		       ,
	OBJECT_VERSION_NUMBER
)
SELECT
       'BR-ISS'                                ,--TAX_REGIME_CODE
	NULL                                   ,--PARENT_REGIME_CODE
        'N'                                    ,--HAS_SUB_REGIME_FLAG
	'COUNTRY'                              ,--COUNTRY_OR_GROUP_CODE
	'BR'                                   ,--COUNTRY_CODE
	NULL                                   ,--GEOGRAPHY_TYPE
	l_min_start_date                       ,--EFFECTIVE_FROM
	NULL                                   ,--EFFECTIVE_TO
	NULL                                   ,--EXCHANGE_RATE_TYPE
	NULL                                   ,--TAX_CURRENCY_CODE
	NULL                                   ,--THRSHLD_GROUPING_LVL_CODE
	NULL                                   ,--ROUNDING_RULE_CODE
	NULL                                   ,--TAX_PRECISION
	NULL                                   ,--MINIMUM_ACCOUNTABLE_UNIT
	'N'                                    ,--TAX_STATUS_RULE_FLAG
	'SHIP_FROM'                            ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
        'N'                                    ,--APPLICABILITY_RULE_FLAG
	'N'                                    ,--PLACE_OF_SUPPLY_RULE_FLAG
	'N'                                    ,--TAX_CALC_RULE_FLAG
	'N'                                    ,--TAXABLE_BASIS_THRSHLD_FLAG
	'N'                                    ,--TAX_RATE_THRSHLD_FLAG
	'N'                                    ,--TAX_AMT_THRSHLD_FLAG
	'N'                                    ,--TAX_RATE_RULE_FLAG
	'N'                                    ,--TAXABLE_BASIS_RULE_FLAG
	'N'                                    ,--DEF_INCLUSIVE_TAX_FLAG
	'N'                                    ,--HAS_OTHER_JURISDICTIONS_FLAG
	'N'                                    ,--ALLOW_ROUNDING_OVERRIDE_FLAG
	'Y'                                    ,--ALLOW_EXEMPTIONS_FLAG
	'Y'                                    ,--ALLOW_EXCEPTIONS_FLAG
	'N'                                    ,--ALLOW_RECOVERABILITY_FLAG
	-- 'N'                                    ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
	'N'                                    ,--AUTO_PRVN_FLAG
	'N'                                    ,--HAS_TAX_DET_DATE_RULE_FLAG
	'N'                                    ,--HAS_EXCH_RATE_DATE_RULE_FLAG
	'N'                                    ,--HAS_TAX_POINT_DATE_RULE_FLAG
	'N'                                    ,--USE_LEGAL_MSG_FLAG
	'N'                                    ,--REGN_NUM_SAME_AS_LE_FLAG
	NULL                                   ,--DEF_REC_SETTLEMENT_OPTION_CODE
	'MIGRATED'                             ,--RECORD_TYPE_CODE
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	NULL       ,
	'SHIP_FROM_PARTY'                      ,--DEF_REGISTR_PARTY_TYPE_CODE
	'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
	'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG
	NULL                                   ,--REGIME_PRECEDENCE
	'N'                                    ,--CROSS_REGIME_COMPOUNDING_FLAG
	ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
	NULL                                   ,--GEOGRAPHY_ID
	NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
	NULL                                   ,--PERIOD_SET_NAME
	NULL                                   ,--REP_TAX_AUTHORITY_ID
	NULL                                   ,--COLL_TAX_AUTHORITY_ID
        fnd_global.user_id                     ,
	SYSDATE                                ,
	fnd_global.user_id                     ,
	SYSDATE                                ,
	fnd_global.conc_login_id               ,
	fnd_global.conc_request_id             ,--Request Id
	fnd_global.prog_appl_id                ,--Program Application ID
	fnd_global.conc_program_id             ,--Program Id
	fnd_global.conc_login_id               ,--Program Login ID
	1
FROM    zx_regimes_b
WHERE   tax_regime_code = 'BR-IPI'
AND     country_code    = 'BR'
AND     NOT EXISTS (SELECT 1
                    FROM   zx_regimes_b
                    WHERE  tax_regime_code = 'BR-ISS');

END IF;

IF zx_migrate_util.is_installed('AR') = 'Y' THEN
/*-------------------------------------------------------------------------
 |
 |  For GTE US Sales Tax Regimes
 |  It also inserts zx_regimes_tl.
 |
 |  Regime Code :
 |  1. Country Code || '-SALES-TAX-' || location structure id
 |
 |  Regime Name :
 |  1.  Country Code || '-SALES-TAX-' || Qualifier1 ||'-'|| Qualifier2..
 |
 +--------------------------------------------------------------------------*/
-- ****** Building PL/SQL Table ******
  i := 1;
  d := 1;
  FOR loc_str_cur_rec IN loc_str_cur LOOP
    IF loc_str_cur%ROWCOUNT = 1 THEN
      loc_str_rec.country_code      := loc_str_cur_rec.default_country;
      loc_str_rec.id_flex_num       := loc_str_cur_rec.id_flex_num;
      loc_str_rec.seg_att_type1     := loc_str_cur_rec.seg_att_type;
      loc_str_rec.tax_currency_code := loc_str_cur_rec.tax_currency_code;
      loc_str_rec.tax_precision     := loc_str_cur_rec.tax_precision;
      loc_str_rec.tax_mau           := loc_str_cur_rec.tax_mau;
      loc_str_rec.rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
      loc_str_rec.allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
      loc_str_rec.org_id            := loc_str_cur_rec.org_id;

      l_temp_id_flex_num            := loc_str_cur_rec.id_flex_num;
      l_temp_country_code           := loc_str_cur_rec.default_country;
      l_temp_org_id                 := loc_str_cur_rec.org_id;
      l_temp_seg_num                := loc_str_cur_rec.seg_num;
      l_temp_seg_att_type           := loc_str_cur_rec.seg_att_type;
      l_temp_tax_currency_code      := loc_str_cur_rec.tax_currency_code;
      l_temp_tax_precision          := loc_str_cur_rec.tax_precision;
      l_temp_tax_mau                := loc_str_cur_rec.tax_mau;
      l_temp_rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
      l_temp_allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
      l_temp_org_id                  := loc_str_cur_rec.org_id;

      cnt := 1; --Counter for seg_att_type
    ELSE
      IF l_temp_id_flex_num = loc_str_cur_rec.id_flex_num AND
         l_temp_country_code = loc_str_cur_rec.default_country THEN
        IF l_temp_seg_num <> loc_str_cur_rec.seg_num THEN
	  cnt := cnt + 1;
	  IF cnt = 2 THEN
	    loc_str_rec.seg_att_type2 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 3 THEN
	    loc_str_rec.seg_att_type3 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 4 THEN
	    loc_str_rec.seg_att_type4 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 5 THEN
	    loc_str_rec.seg_att_type5 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 6 THEN
	    loc_str_rec.seg_att_type6 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 7 THEN
	    loc_str_rec.seg_att_type7 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 8 THEN
	    loc_str_rec.seg_att_type8 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 9 THEN
	    loc_str_rec.seg_att_type9 := loc_str_cur_rec.seg_att_type;
	  ELSIF cnt = 10 THEN
	    loc_str_rec.seg_att_type10 := loc_str_cur_rec.seg_att_type;
	  END IF;
        ELSIF l_temp_seg_num = loc_str_cur_rec.seg_num THEN
          IF l_temp_org_id <> loc_str_cur_rec.org_id THEN
            -- ORGANIZATION MERGE HAPPEND --
            loc_str_rec := null_loc_str_rec;
            loc_str_rec.country_code      := loc_str_cur_rec.default_country;
            loc_str_rec.id_flex_num       := loc_str_cur_rec.id_flex_num;
            loc_str_rec.tax_currency_code := loc_str_cur_rec.tax_currency_code;
            loc_str_rec.tax_precision     := loc_str_cur_rec.tax_precision;
            loc_str_rec.tax_mau           := loc_str_cur_rec.tax_mau;
            loc_str_rec.rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
            loc_str_rec.allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
            loc_str_rec.org_id            := loc_str_cur_rec.org_id;
            --loc_str_rec.tax_account_id    := loc_str_cur_rec.tax_account_id;
            denorm_err_tbl(d) := loc_str_rec;
            d := d + 1;
          END IF;
        END IF;
      ELSE
        denorm_tbl(i) := loc_str_rec;
        loc_str_rec := null_loc_str_rec;
        i := i + 1;

        loc_str_rec.country_code      := loc_str_cur_rec.default_country;
        loc_str_rec.id_flex_num       := loc_str_cur_rec.id_flex_num;
        loc_str_rec.seg_att_type1     := loc_str_cur_rec.seg_att_type;
        loc_str_rec.tax_currency_code := loc_str_cur_rec.tax_currency_code;
        loc_str_rec.tax_precision     := loc_str_cur_rec.tax_precision;
        loc_str_rec.tax_mau           := loc_str_cur_rec.tax_mau;
        loc_str_rec.rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
        loc_str_rec.allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
        loc_str_rec.org_id            := loc_str_cur_rec.org_id;

        l_temp_id_flex_num            := loc_str_cur_rec.id_flex_num;
        l_temp_country_code           := loc_str_cur_rec.default_country;
        l_temp_org_id                 := loc_str_cur_rec.org_id;
        l_temp_seg_num                := loc_str_cur_rec.seg_num;
        l_temp_seg_att_type           := loc_str_cur_rec.seg_att_type;
        l_temp_tax_currency_code      := loc_str_cur_rec.tax_currency_code;
        l_temp_tax_precision          := loc_str_cur_rec.tax_precision;
        l_temp_tax_mau                := loc_str_cur_rec.tax_mau;
        l_temp_rounding_rule_code      := loc_str_cur_rec.rounding_rule_code;
        l_temp_allow_rounding_override := loc_str_cur_rec.allow_rounding_override;
        l_temp_org_id                  := loc_str_cur_rec.org_id;
        cnt := 1;
      END IF;
    END IF;
  END LOOP;
  denorm_tbl(i) := loc_str_rec;

-- ****** DEBUG ******
FOR k in 1..denorm_tbl.count LOOP
  arp_util_tax.debug('***');
  arp_util_tax.debug('Country Code: '|| denorm_tbl(k).country_code);
  arp_util_tax.debug('ID Flex Num : '|| denorm_tbl(k).id_flex_num);
  arp_util_tax.debug('Attr1       : '|| denorm_tbl(k).seg_att_type1);
  arp_util_tax.debug('Attr2       : '|| denorm_tbl(k).seg_att_type2);
  arp_util_tax.debug('Attr3       : '|| denorm_tbl(k).seg_att_type3);
  arp_util_tax.debug('Attr4       : '|| denorm_tbl(k).seg_att_type4);
  arp_util_tax.debug('Attr5       : '|| denorm_tbl(k).seg_att_type5);
  arp_util_tax.debug('Attr6       : '|| denorm_tbl(k).seg_att_type6);
  arp_util_tax.debug('Attr7       : '|| denorm_tbl(k).seg_att_type7);
  arp_util_tax.debug('Attr8       : '|| denorm_tbl(k).seg_att_type8);
  arp_util_tax.debug('Attr9       : '|| denorm_tbl(k).seg_att_type9);
  arp_util_tax.debug('Attr10      : '|| denorm_tbl(k).seg_att_type10);
  arp_util_tax.debug('Currency    : '|| denorm_tbl(k).tax_currency_code);
  arp_util_tax.debug('Precision   : '|| denorm_tbl(k).tax_precision);
  arp_util_tax.debug('MAU         : '|| denorm_tbl(k).tax_mau);
  arp_util_tax.debug('Rounding    : '|| denorm_tbl(k).rounding_rule_code);
  arp_util_tax.debug('Rounding Ovr: '|| denorm_tbl(k).allow_rounding_override);
  arp_util_tax.debug('Org ID      : '|| denorm_tbl(k).org_id);
END LOOP;
arp_util_tax.debug('   ');
IF denorm_err_tbl.count > 0 THEN
  arp_util_tax.debug('*** ORGANZATION MERGED RECORDS ***');
  FOR k in 1..denorm_err_tbl.count LOOP
    arp_util_tax.debug(denorm_err_tbl(k).country_code);
    arp_util_tax.debug(denorm_err_tbl(k).id_flex_num);
    arp_util_tax.debug(denorm_err_tbl(k).tax_currency_code);
    arp_util_tax.debug(denorm_err_tbl(k).tax_precision);
    arp_util_tax.debug(denorm_err_tbl(k).tax_mau);
    arp_util_tax.debug(denorm_err_tbl(k).rounding_rule_code);
    arp_util_tax.debug(denorm_err_tbl(k).allow_rounding_override);
    arp_util_tax.debug(denorm_err_tbl(k).org_id);
    --arp_util_tax.debug(denorm_tbl(k).tax_account_id);
  END LOOP;
ELSE
  arp_util_tax.debug('*** NO ORGANZATION MERGED RECORDS ***');
END IF;
-- ****** DEBUG ******




-- ****** Insert into zx_regimes_b/tl ******
  FOR k in 1..denorm_tbl.count LOOP
   if denorm_tbl(k).country_code is not null
   then
    l_tax_regime_name := denorm_tbl(k).country_code || '-SALES-TAX' ||
                         '-' || denorm_tbl(k).seg_att_type1 ||
                         '-' || denorm_tbl(k).seg_att_type2 ||
                         '-' || denorm_tbl(k).seg_att_type3 ||
                         '-' || denorm_tbl(k).seg_att_type4 ||
                         '-' || denorm_tbl(k).seg_att_type5 ||
                         '-' || denorm_tbl(k).seg_att_type6 ||
                         '-' || denorm_tbl(k).seg_att_type7 ||
                         '-' || denorm_tbl(k).seg_att_type8 ||
                         '-' || denorm_tbl(k).seg_att_type9 ||
                         '-' || denorm_tbl(k).seg_att_type10;
    l_tax_regime_name := RTRIM(l_tax_regime_name, '-');
    l_tax_regime_code := denorm_tbl(k).country_code || '-SALES-TAX-' || denorm_tbl(k).id_flex_num;

    INSERT ALL
    WHEN (NOT EXISTS (SELECT 1
                      FROM   ZX_REGIMES_B
                      WHERE  TAX_REGIME_CODE = l_tax_regime_code
                     )
         ) THEN
    INTO ZX_REGIMES_B
    (
	  TAX_REGIME_CODE                        ,
          PARENT_REGIME_CODE                     ,
	  HAS_SUB_REGIME_FLAG                    ,
	  COUNTRY_OR_GROUP_CODE                  ,
	  COUNTRY_CODE                           ,
	  GEOGRAPHY_TYPE                         ,
	  EFFECTIVE_FROM                         ,
	  EFFECTIVE_TO                           ,
	  EXCHANGE_RATE_TYPE                     ,
	  TAX_CURRENCY_CODE                      ,
	  THRSHLD_GROUPING_LVL_CODE              ,
	  ROUNDING_RULE_CODE                     ,
	  TAX_PRECISION                          ,
	  MINIMUM_ACCOUNTABLE_UNIT               ,
	  TAX_STATUS_RULE_FLAG                   ,
	  DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
	  APPLICABILITY_RULE_FLAG                ,
	  PLACE_OF_SUPPLY_RULE_FLAG              ,
	  TAX_CALC_RULE_FLAG                     ,
	  TAXABLE_BASIS_THRSHLD_FLAG             ,
	  TAX_RATE_THRSHLD_FLAG                  ,
	  TAX_AMT_THRSHLD_FLAG                   ,
	  TAX_RATE_RULE_FLAG                     ,
	  TAXABLE_BASIS_RULE_FLAG                ,
	  DEF_INCLUSIVE_TAX_FLAG                 ,
	  HAS_OTHER_JURISDICTIONS_FLAG           ,
	  ALLOW_ROUNDING_OVERRIDE_FLAG           ,
	  ALLOW_EXEMPTIONS_FLAG                  ,
	  ALLOW_EXCEPTIONS_FLAG                  ,
	  ALLOW_RECOVERABILITY_FLAG              ,
	  -- RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
	  AUTO_PRVN_FLAG                         ,
	  HAS_TAX_DET_DATE_RULE_FLAG             ,
	  HAS_EXCH_RATE_DATE_RULE_FLAG           ,
	  HAS_TAX_POINT_DATE_RULE_FLAG           ,
	  USE_LEGAL_MSG_FLAG                     ,
	  REGN_NUM_SAME_AS_LE_FLAG               ,
	  DEF_REC_SETTLEMENT_OPTION_CODE         ,
	  RECORD_TYPE_CODE                       ,
	  ATTRIBUTE1                             ,
	  ATTRIBUTE2                             ,
	  ATTRIBUTE3                             ,
	  ATTRIBUTE4                             ,
	  ATTRIBUTE5                             ,
	  ATTRIBUTE6                             ,
	  ATTRIBUTE7                             ,
	  ATTRIBUTE8                             ,
	  ATTRIBUTE9                             ,
	  ATTRIBUTE10                            ,
	  ATTRIBUTE11                            ,
	  ATTRIBUTE12                            ,
	  ATTRIBUTE13                            ,
	  ATTRIBUTE14                            ,
	  ATTRIBUTE15                            ,
	  ATTRIBUTE_CATEGORY                     ,
	  DEF_REGISTR_PARTY_TYPE_CODE            ,
	  REGISTRATION_TYPE_RULE_FLAG            ,
	  TAX_INCLUSIVE_OVERRIDE_FLAG            ,
	  REGIME_PRECEDENCE                      ,
	  CROSS_REGIME_COMPOUNDING_FLAG          ,
	  TAX_REGIME_ID                          ,
	  GEOGRAPHY_ID                           ,
	  THRSHLD_CHK_TMPLT_CODE                 ,
	  PERIOD_SET_NAME                        ,
	  REP_TAX_AUTHORITY_ID                   ,
	  COLL_TAX_AUTHORITY_ID                  ,
	  CREATED_BY              	       ,
	  CREATION_DATE                          ,
	  LAST_UPDATED_BY                        ,
	  LAST_UPDATE_DATE                       ,
	  LAST_UPDATE_LOGIN                      ,
	  REQUEST_ID                             ,
	  PROGRAM_APPLICATION_ID                 ,
	  PROGRAM_ID                             ,
	  PROGRAM_LOGIN_ID          		,
	  OBJECT_VERSION_NUMBER
    )
    VALUES
    (
         l_tax_regime_code                       , --TAX_REGIME_CODE
         NULL                                    ,--PARENT_REGIME_CODE
	 'N'                                     ,--HAS_SUB_REGIME_FLAG
	 'COUNTRY'                               ,--COUNTRY_OR_GROUP_CODE
	 denorm_tbl(k).country_code              ,--COUNTRY_CODE
	 NULL                                    ,--GEOGRAPHY_TYPE
	 l_min_start_date                          ,--EFFECTIVE_FROM
	 NULL                                    ,--EFFECTIVE_TO
	 NULL                                    ,--EXCHANGE_RATE_TYPE
	 NULL                                    ,--TAX_CURRENCY_CODE   ***** ATTENTION
	 NULL                                    ,--THRSHLD_GROUPING_LVL_CODE
	 NULL                                    ,--ROUNDING_RULE_CODE
	 NULL                                    ,--TAX_PRECISION   ***** ATTENTION
	 NULL                                    ,--MINIMUM_ACCOUNTABLE_UNIT
	 'N'                                     ,--TAX_STATUS_RULE_FLAG
	  'SHIP_TO'                              ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
	 'N'                                     ,--APPLICABILITY_RULE_FLAG
	 'N'                                     ,--PLACE_OF_SUPPLY_RULE_FLAG
	 'N'                                     ,--TAX_CALC_RULE_FLAG
	 'N'                                     ,--TAXABLE_BASIS_THRSHLD_FLAG
	 'N'                                     ,--TAX_RATE_THRSHLD_FLAG
	 'N'                                     ,--TAX_AMT_THRSHLD_FLAG
	 'N'                                     ,--TAX_RATE_RULE_FLAG
	 'N'                                     ,--TAXABLE_BASIS_RULE_FLAG
	 'N'                                     ,--DEF_INCLUSIVE_TAX_FLAG
	 'Y'                                     ,--HAS_OTHER_JURISDICTIONS_FLAG : 4610550
	 'N'                                     ,--ALLOW_ROUNDING_OVERRIDE_FLAG
	 'Y'                                     ,--ALLOW_EXEMPTIONS_FLAG
	 'Y'                                     ,--ALLOW_EXCEPTIONS_FLAG
	 'N'                                     ,--ALLOW_RECOVERABILITY_FLAG
	 -- 'N'                                     ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
	 'N'                                     ,--AUTO_PRVN_FLAG
	 'N'                                     ,--HAS_TAX_DET_DATE_RULE_FLAG
	 'N'                                     ,--HAS_EXCH_RATE_DATE_RULE_FLAG
	 'N'                                     ,--HAS_TAX_POINT_DATE_RULE_FLAG
	 'N'                                     ,--USE_LEGAL_MSG_FLAG
	 'N'                                     ,--REGN_NUM_SAME_AS_LE_FLAG
	 'N'                                     ,--DEF_REC_SETTLE_OPTION_CODE
	 'MIGRATED'                             ,--RECORD_TYPE_CODE
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 'SHIP_TO_SITE'                         ,--DEF_REGISTR_PARTY_TYPE_CODE
	 'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
	 'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG /** Set it to Y. Need P2P Change. **/
	 NULL                                   ,--REGIME_PRECEDENCE  /** Can be updated for compounding migration **/
	 'N'                                     ,--CROSS_REGIME_COMPOUNDING_FLAG
	 ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
	 NULL                                   ,--GEOGRAPHY_ID
	 NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
	 NULL                                   ,--PERIOD_SET_NAME
	 NULL                                   ,--REP_TAX_AUTHORITY_ID
	 NULL                                   ,--COLL_TAX_AUTHORITY_ID
	 fnd_global.user_id                     ,
	 SYSDATE                                ,
	 fnd_global.user_id                     ,
	 SYSDATE                                ,
	 fnd_global.conc_login_id               ,
	 fnd_global.conc_request_id             ,--Request Id
	 fnd_global.prog_appl_id                ,--Program Application ID
	 fnd_global.conc_program_id             ,--Program Id
	 fnd_global.conc_login_id               ,--Program Login ID
	 1
    )
    WHEN (NOT EXISTS (SELECT 1
                      FROM   ZX_REGIMES_B
                      WHERE  TAX_REGIME_CODE = l_tax_regime_code
                     )
         ) THEN
    -- Need to insert _TL table for current language as l_tax_regime_name is
    -- derived using the following logic :
    -- Country Code '-SALES-TAX-' Seg Att1 '-' Seg Att2 '-' ...
    INTO ZX_REGIMES_TL
    (
       LANGUAGE                    ,
       SOURCE_LANG                 ,
       TAX_REGIME_NAME             ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN           ,
       TAX_REGIME_ID
    )
    VALUES
    (
       userenv('LANG'),
       userenv('LANG'),
	CASE WHEN l_tax_regime_name = UPPER(l_tax_regime_name)
	THEN    Initcap(l_tax_regime_name)
	ELSE
	     l_tax_regime_name
	END,
       SYSDATE,
       fnd_global.user_id       ,
       SYSDATE                  ,
       fnd_global.user_id       ,
       fnd_global.conc_login_id ,
       ZX_REGIMES_B_S.NEXTVAL
    )
    SELECT 1 FROM DUAL;
    END IF;
  END LOOP;


/*-------------------------------------------------------------------------
 |
 |  For Tax Vendor Regimes
 |
 |  Regime Code :
 |    1. 'US-SALES-TAX-TAXWARE' if TAXWARE is installed in one of the OUs.
 |    2. 'US-SALES-TAX-VERTEX' if VERTEX is installed in one of the OUs.
 |
 +--------------------------------------------------------------------------*/
 /*
  INSERT ALL
  INTO zx_regimes_b
  (
	  TAX_REGIME_CODE                        ,
          PARENT_REGIME_CODE                     ,
	  HAS_SUB_REGIME_FLAG                    ,
	  COUNTRY_OR_GROUP_CODE                  ,
	  COUNTRY_CODE                           ,
	  GEOGRAPHY_TYPE                         ,
	  EFFECTIVE_FROM                         ,
	  EFFECTIVE_TO                           ,
	  EXCHANGE_RATE_TYPE                     ,
	  TAX_CURRENCY_CODE                      ,
	  THRSHLD_GROUPING_LVL_CODE              ,
	  ROUNDING_RULE_CODE                     ,
	  TAX_PRECISION                          ,
	  MINIMUM_ACCOUNTABLE_UNIT               ,
	  TAX_STATUS_RULE_FLAG                   ,
	  DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
	  APPLICABILITY_RULE_FLAG                ,
	  PLACE_OF_SUPPLY_RULE_FLAG              ,
	  TAX_CALC_RULE_FLAG                     ,
	  TAXABLE_BASIS_THRSHLD_FLAG             ,
	  TAX_RATE_THRSHLD_FLAG                  ,
	  TAX_AMT_THRSHLD_FLAG                   ,
	  TAX_RATE_RULE_FLAG                     ,
	  TAXABLE_BASIS_RULE_FLAG                ,
	  DEF_INCLUSIVE_TAX_FLAG                 ,
	  HAS_OTHER_JURISDICTIONS_FLAG           ,
	  ALLOW_ROUNDING_OVERRIDE_FLAG           ,
	  ALLOW_EXEMPTIONS_FLAG                  ,
	  ALLOW_EXCEPTIONS_FLAG                  ,
	  ALLOW_RECOVERABILITY_FLAG              ,
	  -- RECOVERABILITY_OVERRIDE_FLAG           , Bug 3766372
	  AUTO_PRVN_FLAG                         ,
	  HAS_TAX_DET_DATE_RULE_FLAG             ,
	  HAS_EXCH_RATE_DATE_RULE_FLAG           ,
	  HAS_TAX_POINT_DATE_RULE_FLAG           ,
	  USE_LEGAL_MSG_FLAG                     ,
	  REGN_NUM_SAME_AS_LE_FLAG               ,
	  DEF_REC_SETTLEMENT_OPTION_CODE         ,
	  RECORD_TYPE_CODE                       ,
	  ATTRIBUTE1                             ,
	  ATTRIBUTE2                             ,
	  ATTRIBUTE3                             ,
	  ATTRIBUTE4                             ,
	  ATTRIBUTE5                             ,
	  ATTRIBUTE6                             ,
	  ATTRIBUTE7                             ,
	  ATTRIBUTE8                             ,
	  ATTRIBUTE9                             ,
	  ATTRIBUTE10                            ,
	  ATTRIBUTE11                            ,
	  ATTRIBUTE12                            ,
	  ATTRIBUTE13                            ,
	  ATTRIBUTE14                            ,
	  ATTRIBUTE15                            ,
	  ATTRIBUTE_CATEGORY                     ,
	  DEF_REGISTR_PARTY_TYPE_CODE            ,
	  REGISTRATION_TYPE_RULE_FLAG            ,
	  TAX_INCLUSIVE_OVERRIDE_FLAG            ,
	  REGIME_PRECEDENCE                      ,
	  CROSS_REGIME_COMPOUNDING_FLAG          ,
	  TAX_REGIME_ID                          ,
	  GEOGRAPHY_ID                           ,
	  THRSHLD_CHK_TMPLT_CODE                 ,
	  PERIOD_SET_NAME                        ,
	  REP_TAX_AUTHORITY_ID                   ,
	  COLL_TAX_AUTHORITY_ID                  ,
	  CREATED_BY              	       ,
	  CREATION_DATE                          ,
	  LAST_UPDATED_BY                        ,
	  LAST_UPDATE_DATE                       ,
	  LAST_UPDATE_LOGIN                      ,
	  REQUEST_ID                             ,
	  PROGRAM_APPLICATION_ID                 ,
	  PROGRAM_ID                             ,
	  PROGRAM_LOGIN_ID         		 ,
	  OBJECT_VERSION_NUMBER
  )
  VALUES
  (
         l_tax_regime_code                       , --TAX_REGIME_CODE
         NULL                                    ,--PARENT_REGIME_CODE
	 'N'                                     ,--HAS_SUB_REGIME_FLAG
	 'COUNTRY'                               ,--COUNTRY_OR_GROUP_CODE
	 'US'                                    ,--COUNTRY_CODE
	 NULL                                    ,--GEOGRAPHY_TYPE
	 l_min_start_date                        ,--EFFECTIVE_FROM
	 NULL                                    ,--EFFECTIVE_TO
	 NULL                                    ,--EXCHANGE_RATE_TYPE
	 NULL                                    ,--TAX_CURRENCY_CODE   ***** ATTENTION
	 NULL                                    ,--THRSHLD_GROUPING_LVL_CODE
	 NULL                                    ,--ROUNDING_RULE_CODE
	 NULL                                    ,--TAX_PRECISION   ***** ATTENTION
	 NULL                                    ,--MINIMUM_ACCOUNTABLE_UNIT
	 'N'                                     ,--TAX_STATUS_RULE_FLAG
	  'SHIP_TO'                              ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
	 'N'                                     ,--APPLICABILITY_RULE_FLAG
	 'N'                                     ,--PLACE_OF_SUPPLY_RULE_FLAG
	 'N'                                     ,--TAX_CALC_RULE_FLAG
	 'N'                                     ,--TAXABLE_BASIS_THRSHLD_FLAG
	 'N'                                     ,--TAX_RATE_THRSHLD_FLAG
	 'N'                                     ,--TAX_AMT_THRSHLD_FLAG
	 'N'                                     ,--TAX_RATE_RULE_FLAG
	 'N'                                     ,--TAXABLE_BASIS_RULE_FLAG
	 'N'                                     ,--DEF_INCLUSIVE_TAX_FLAG
	 'N'                                     ,--HAS_OTHER_JURISDICTIONS_FLAG
	 'N'                                     ,--ALLOW_ROUNDING_OVERRIDE_FLAG
	 'Y'                                     ,--ALLOW_EXEMPTIONS_FLAG
	 'Y'                                     ,--ALLOW_EXCEPTIONS_FLAG
	 'N'                                     ,--ALLOW_RECOVERABILITY_FLAG
	 -- 'N'                                     ,--RECOVERABILITY_OVERRIDE_FLAG : Bug 3766372
	 'N'                                     ,--AUTO_PRVN_FLAG
	 'N'                                     ,--HAS_TAX_DET_DATE_RULE_FLAG
	 'N'                                     ,--HAS_EXCH_RATE_DATE_RULE_FLAG
	 'N'                                     ,--HAS_TAX_POINT_DATE_RULE_FLAG
	 'N'                                     ,--USE_LEGAL_MSG_FLAG
	 'N'                                     ,--REGN_NUM_SAME_AS_LE_FLAG
	 'N'                                     ,--DEF_REC_SETTLE_OPTION_CODE
	 'MIGRATED'                              ,--RECORD_TYPE_CODE
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 NULL       ,
	 'SHIP_TO_SITE'                         ,--DEF_REGISTR_PARTY_TYPE_CODE
	 'N'                                    ,--REGISTRATION_TYPE_RULE_FLAG
	 'Y'                                    ,--TAX_INCLUSIVE_OVERRIDE_FLAG
	 NULL                                   ,--REGIME_PRECEDENCE
	 'N'                                     ,--CROSS_REGIME_COMPOUNDING_FLAG
	 ZX_REGIMES_B_S.NEXTVAL                 ,--TAX_REGIME_ID
	 NULL                                   ,--GEOGRAPHY_ID
	 NULL                                   ,--THRSHLD_CHK_TMPLT_CODE
	 NULL                                   ,--PERIOD_SET_NAME
	 NULL                                   ,--REP_TAX_AUTHORITY_ID
	 NULL                                   ,--COLL_TAX_AUTHORITY_ID
	 fnd_global.user_id                     ,
	 SYSDATE                                ,
	 fnd_global.user_id                     ,
	 SYSDATE                                ,
	 fnd_global.conc_login_id               ,
	 fnd_global.conc_request_id             ,--Request Id
	 fnd_global.prog_appl_id                ,--Program Application ID
	 fnd_global.conc_program_id             ,--Program Id
	 fnd_global.conc_login_id               ,--Program Login ID
	 1
    )
    SELECT distinct
           CASE
           WHEN asp.tax_database_view_set = '_A' THEN
             'US-SALES-TAX-TAXWARE'
           WHEN asp.tax_database_view_set = '_V' THEN
             'US-SALES-TAX-VERTEX'
           END                          l_tax_regime_code
    FROM   ar_system_parameters_all  asp
    WHERE  asp.tax_database_view_set IN ('_A', '_V')
    AND    asp.default_country = 'US'
    AND    NOT EXISTS (SELECT 1
                       FROM   zx_regimes_b
                       WHERE  tax_regime_code IN ('US-SALES-TAX-TAXWARE', 'US-SALES-TAX-VERTEX')
                      );
  */

END IF;


/*-------------------------------------------------------------------------
 |
 |  Populates data into zx_regimes_tl table
 |
 +--------------------------------------------------------------------------*/
  -- Bug 4688151 : LTE Tax Codes will derive tax_regime_name from
  IF L_MULTI_ORG_FLAG = 'Y'
  THEN

  INSERT INTO ZX_REGIMES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_REGIME_NAME             ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_REGIME_ID

  )
  SELECT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      CASE WHEN decode(d.global_attribute_category,
               'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
               'JL.BR.ARXSYSPA.Additional Info', d.meaning,
               'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
                B.TAX_REGIME_CODE)
		=
		UPPER(decode(d.global_attribute_category,
               'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
               'JL.BR.ARXSYSPA.Additional Info', d.meaning,
               'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
                B.TAX_REGIME_CODE))
      THEN
                Initcap(decode(d.global_attribute_category,
               'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
               'JL.BR.ARXSYSPA.Additional Info', d.meaning,
               'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
                B.TAX_REGIME_CODE))
      ELSE
               decode(d.global_attribute_category,
               'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
               'JL.BR.ARXSYSPA.Additional Info', d.meaning,
               'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
                B.TAX_REGIME_CODE)
      END	 	       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_REGIME_ID
  FROM
      FND_LANGUAGES  L,
      ZX_REGIMES_B   B,
      (select rates.tax_regime_code             tax_regime_code,
              lkups.meaning                     meaning,
              params.global_attribute_category  global_attribute_category
       from   zx_rates_b                rates,
              ar_vat_tax_all_b          codes,
              ar_system_parameters_all  params,
              fnd_lookups               lkups
       where  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
       AND    codes.org_id = params.org_id
       and    params.global_attribute13 = lkups.lookup_code
       and    params.global_attribute_category in ('JL.AR.ARXSYSPA.SYS_PARAMETERS',
                                                   'JL.BR.ARXSYSPA.Additional Info',
                                                   'JL.CO.ARXSYSPA.SYS_PARAMETERS')
       and    lkups.lookup_type = 'JLZZ_AR_TX_RULE_SET'
       group  by rates.tax_regime_code,
                 lkups.meaning,
                 params.global_attribute_category
      )  D
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  --
  AND  b.tax_regime_code = d.tax_regime_code (+)
  AND  not exists
       (select NULL
       from ZX_REGIMES_TL T
       where T.TAX_REGIME_ID =  B.TAX_REGIME_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);
 ELSE

   INSERT INTO ZX_REGIMES_TL
  (
   LANGUAGE                    ,
   SOURCE_LANG                 ,
   TAX_REGIME_NAME             ,
   CREATION_DATE               ,
   CREATED_BY                  ,
   LAST_UPDATE_DATE            ,
   LAST_UPDATED_BY             ,
   LAST_UPDATE_LOGIN           ,
   TAX_REGIME_ID

  )
  SELECT
      L.LANGUAGE_CODE          ,
      userenv('LANG')          ,
      case when
             decode(d.global_attribute_category,
             'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             'JL.BR.ARXSYSPA.Additional Info', d.meaning,
             'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             B.TAX_REGIME_CODE)
	     =
	     UPPER(decode(d.global_attribute_category,
             'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             'JL.BR.ARXSYSPA.Additional Info', d.meaning,
             'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             B.TAX_REGIME_CODE))
      then
             Initcap(decode(d.global_attribute_category,
             'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             'JL.BR.ARXSYSPA.Additional Info', d.meaning,
             'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             B.TAX_REGIME_CODE))
      else
              decode(d.global_attribute_category,
             'JL.AR.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             'JL.BR.ARXSYSPA.Additional Info', d.meaning,
             'JL.CO.ARXSYSPA.SYS_PARAMETERS',  d.meaning,
             B.TAX_REGIME_CODE)
      end     	               ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      SYSDATE                  ,
      fnd_global.user_id       ,
      fnd_global.conc_login_id ,
      B.TAX_REGIME_ID
  FROM
      FND_LANGUAGES  L,
      ZX_REGIMES_B   B,
      (select rates.tax_regime_code             tax_regime_code,
              lkups.meaning                     meaning,
              params.global_attribute_category  global_attribute_category
       from   zx_rates_b                rates,
              ar_vat_tax_all_b          codes,
              ar_system_parameters_all  params,
              fnd_lookups               lkups
       where  codes.vat_tax_id = nvl(rates.source_id, rates.tax_rate_id)
       AND    codes.org_id = params.org_id
       AND    codes.org_id = l_org_id
       and    params.global_attribute13 = lkups.lookup_code
       and    params.global_attribute_category in ('JL.AR.ARXSYSPA.SYS_PARAMETERS',
                                                   'JL.BR.ARXSYSPA.Additional Info',
                                                   'JL.CO.ARXSYSPA.SYS_PARAMETERS')
       and    lkups.lookup_type = 'JLZZ_AR_TX_RULE_SET'
       group  by rates.tax_regime_code,
                 lkups.meaning,
                 params.global_attribute_category
      )  D
  WHERE
      L.INSTALLED_FLAG in ('I', 'B')
  AND B.RECORD_TYPE_CODE = 'MIGRATED'
  --
  AND  b.tax_regime_code = d.tax_regime_code (+)
  AND  not exists
       (select NULL
       from ZX_REGIMES_TL T
       where T.TAX_REGIME_ID =  B.TAX_REGIME_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);


 END IF;

END load_regimes;


PROCEDURE update_tax_status  AS
BEGIN
BEGIN
	FOR cursor_rec IN
	(
	SELECT tax_regime_code,tax,tax_status_code,org_id ,tax_code,effective_from FROM zx_update_criteria_results WHERE tax_class = 'INPUT'
	INTERSECT
	SELECT tax_regime_code,tax,tax_status_code,org_id ,tax_code,effective_from FROM zx_update_criteria_results WHERE tax_class = 'OUTPUT'
	AND tax_status_code <> 'STANDARD-AR-INPUT')
		LOOP
		UPDATE zx_update_criteria_results SET tax_status_code = 'STANDARD-INPUT' WHERE tax_regime_code = cursor_rec.tax_regime_code AND tax = cursor_rec.tax AND
		tax_status_code = cursor_rec.tax_status_code AND org_id = cursor_rec.org_id AND tax_class = 'INPUT';

		UPDATE zx_update_criteria_results SET tax_status_code = 'STANDARD-OUTPUT' WHERE tax_regime_code = cursor_rec.tax_regime_code AND tax = cursor_rec.tax AND
		tax_status_code = cursor_rec.tax_status_code AND org_id = cursor_rec.org_id AND tax_class = 'OUTPUT';

		END LOOP;
EXCEPTION WHEN OTHERS THEN
NULL;
END;

END;



-- ****** CONSTRUCTOR ******
BEGIN
-- ****** Determine min(start_date) ******
BEGIN
  SELECT min(start_date)
  INTO   l_ap_min_start_date
  FROM   ap_tax_codes_all;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_ap_min_start_date := sysdate;
END;

BEGIN
  SELECT min(start_date)
  INTO   l_ar_min_start_date
  FROM   ar_vat_tax_all_b;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_ar_min_start_date := sysdate;
END;

BEGIN
  SELECT count(*)
  INTO   l_ap_count
  FROM   ap_tax_codes_all;
END;

BEGIN
  SELECT count(*)
  INTO   l_ar_count
  FROM   ar_vat_tax_all_b;
END;

IF l_ap_count = 0 THEN
  l_ap_min_start_date := sysdate;
ELSIF l_ar_count = 0 THEN
  l_ar_min_start_date := sysdate;
END IF;

IF l_ap_min_start_date >= l_ar_min_start_date THEN
  l_min_start_date := l_ar_min_start_date;
ELSE
  l_min_start_date := l_ap_min_start_date;
END IF;

BEGIN
   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
    FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN

          FND_PROFILE.GET('ORG_ID',L_ORG_ID);

                 IF L_ORG_ID IS NULL THEN
                   arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
                 END IF;
    ELSE
         L_ORG_ID := NULL;
    END IF;


EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in Common Migrate Tax Definition  Constructor : '||sqlerrm);

END;

END;

/
