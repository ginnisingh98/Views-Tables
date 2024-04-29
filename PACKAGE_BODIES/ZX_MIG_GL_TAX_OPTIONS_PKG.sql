--------------------------------------------------------
--  DDL for Package Body ZX_MIG_GL_TAX_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIG_GL_TAX_OPTIONS_PKG" AS
/* $Header: zxmiggltaxoptb.pls 120.9.12010000.1 2008/07/28 13:34:19 appldev ship $ */

PG_DEBUG CONSTANT VARCHAR(1) default
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE zx_mig_gl_tax_options_header(P_Ledger_Id                          IN NUMBER,
 				       P_Org_id                             IN NUMBER);

PROCEDURE zx_mig_gl_tax_options_nt(P_Ledger_Id                          IN NUMBER,
 				   P_Org_id                             IN NUMBER,
 				   P_Account_Segment_Value              IN VARCHAR2 );

PROCEDURE zx_mig_gl_tax_options_ap(P_Ledger_Id                          IN NUMBER,
 				   P_Org_id                             IN NUMBER,
 				   P_Account_Segment_Value              IN VARCHAR2 );

PROCEDURE zx_mig_gl_tax_options_ar(P_Ledger_Id                          IN NUMBER,
 				   P_Org_id                             IN NUMBER,
 				   P_Account_Segment_Value              IN VARCHAR2 );


L_MULTI_ORG_FLAG   FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
L_ORG_ID	      NUMBER(15);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    zx_sync_gl_tax_options                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine is a wrapper for synchroniztion of GL TAX OPTIONS SETUP. |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        Public Procedure                                                   |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-Mar-05  Vamshi/Vinit        Created.                               |
 |                                                                           |
 +==========================================================================*/


PROCEDURE zx_sync_gl_tax_options( P_Ledger_Id                          IN NUMBER,
 				  P_Org_id                             IN NUMBER,
                                  P_Account_Segment_Value              IN VARCHAR2,
                                  P_Tax_Type_Code                      IN VARCHAR2) is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_sync_gl_tax_options(+)');
    END IF;

    if(P_Account_Segment_Value is NULL and p_tax_type_code is NULL ) then
       zx_mig_gl_tax_options_header(P_Ledger_Id,P_Org_id);
    elsif(P_Tax_Type_Code='N') then
       zx_mig_gl_tax_options_nt(P_Ledger_Id,P_Org_id,P_Account_Segment_Value);
    else
      if(P_Tax_Type_Code='I' or P_Tax_Type_Code='B') then
       zx_mig_gl_tax_options_ap(P_Ledger_Id,P_Org_id,P_Account_Segment_Value);
      end if;
      if(P_Tax_Type_Code='O' or P_Tax_Type_Code='B') then
       zx_mig_gl_tax_options_ar(P_Ledger_Id,P_Org_id,P_Account_Segment_Value);
      end if;
    end if;

    IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('zx_sync_gl_tax_options(-)');
    END IF;
 EXCEPTION
          WHEN OTHERS THEN
              IF PG_DEBUG = 'Y' THEN
               arp_util_tax.debug('EXCEPTION: zx_sync_gl_tax_options ');
               arp_util_tax.debug(sqlerrm);
               arp_util_tax.debug('zx_sync_gl_tax_options(-)');
              END IF;
              app_exception.raise_exception;
 End zx_sync_gl_tax_options;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    zx_mig_gl_tax_options                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine is a wrapper for migration of GL TAX OPTIONS SETUP.      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        Public Procedure                                                   |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-Feb-05  Vamshi/Vinit        Created.                               |
 |                                                                           |
 +==========================================================================*/


PROCEDURE zx_mig_gl_tax_options is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options(+)');
    END IF;

    zx_mig_gl_tax_options_header(NULL,NULL);

    zx_mig_gl_tax_options_nt(NULL,NULL,NULL);

    IF ZX_MIGRATE_UTIL.IS_INSTALLED('AP') = 'Y' THEN
       zx_mig_gl_tax_options_ap(NULL,NULL,NULL);
    END IF;

    IF ZX_MIGRATE_UTIL.IS_INSTALLED('AR') = 'Y' THEN
       zx_mig_gl_tax_options_ar(NULL,NULL,NULL);
    END IF;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options(-)');
    END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: zx_mig_gl_tax_options ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('zx_mig_gl_tax_options(-)');
             END IF;
             app_exception.raise_exception;
END zx_mig_gl_tax_options;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    zx_mig_gl_tax_options_header                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine migrates GL TAX OPTIONS SETUP Header Information.        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        zx_mig_gl_tax_options                                              |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Mar-05  Vamshi/Vinit        Created.                               |
 |                                                                           |
 +==========================================================================*/


PROCEDURE zx_mig_gl_tax_options_header(P_Ledger_Id number,P_Org_id number) is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_header(+)');
    END IF;

    Insert ALL
    Into zx_account_rates_tmp
    (
         LEDGER_ID                      ,
         CONTENT_OWNER_ID               ,
         ACCOUNT_SEGMENT_VALUE          ,
         TAX_PRECISION                  ,
         CALCULATION_LEVEL_CODE         ,
         ALLOW_RATE_OVERRIDE_FLAG       ,
         TAX_MAU                        ,
         TAX_CURRENCY_CODE              ,
         TAX_CLASS                      ,
         TAX_REGIME_CODE                ,
         TAX                            ,
         TAX_STATUS_CODE                ,
         TAX_RATE_CODE                  ,
         ROUNDING_RULE_CODE             ,
         AMT_INCL_TAX_FLAG              ,
         RECORD_TYPE_CODE               ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_DATE               ,
         LAST_UPDATE_LOGIN              ,
         ATTRIBUTE_CATEGORY             ,
         ATTRIBUTE1                     ,
         ATTRIBUTE2                     ,
         ATTRIBUTE3                     ,
         ATTRIBUTE4                     ,
         ATTRIBUTE5                     ,
         ATTRIBUTE6                     ,
         ATTRIBUTE7                     ,
         ATTRIBUTE8                     ,
         ATTRIBUTE9                     ,
         ATTRIBUTE10                    ,
         ATTRIBUTE11                    ,
         ATTRIBUTE12                    ,
         ATTRIBUTE13                    ,
         ATTRIBUTE14                    ,
         ATTRIBUTE15                    ,
         ALLOW_ROUNDING_OVERRIDE_FLAG)
    Values
    (
         LEDGER_ID                      ,
         CONTENT_OWNER_ID               ,
         ACCOUNT_SEGMENT_VALUE          ,
         TAX_PRECISION                  ,
         CALCULATION_LEVEL_CODE         ,
         ALLOW_RATE_OVERRIDE_FLAG       ,
         TAX_MAU                        ,
         TAX_CURRENCY_CODE              ,
         TAX_CLASS                      ,
         TAX_REGIME_CODE                ,
         TAX                            ,
         TAX_STATUS_CODE                ,
         TAX_RATE_CODE                  ,
         ROUNDING_RULE_CODE             ,
         AMT_INCL_TAX_FLAG              ,
         RECORD_TYPE_CODE               ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_DATE               ,
         LAST_UPDATE_LOGIN              ,
         ATTRIBUTE_CATEGORY             ,
         ATTRIBUTE1                     ,
         ATTRIBUTE2                     ,
         ATTRIBUTE3                     ,
         ATTRIBUTE4                     ,
         ATTRIBUTE5                     ,
         ATTRIBUTE6                     ,
         ATTRIBUTE7                     ,
         ATTRIBUTE8                     ,
         ATTRIBUTE9                     ,
         ATTRIBUTE10                    ,
         ATTRIBUTE11                    ,
         ATTRIBUTE12                    ,
         ATTRIBUTE13                    ,
         ATTRIBUTE14                    ,
         ATTRIBUTE15                    ,
         ALLOW_ROUNDING_OVERRIDE_FLAG)
    Select
        opt.ledger_id                 LEDGER_ID,
        ptp.PARTY_TAX_PROFILE_ID      CONTENT_OWNER_ID,
        NULL                          ACCOUNT_SEGMENT_VALUE ,
        opt.TAX_PRECISION             TAX_PRECISION,
        opt.CALCULATION_LEVEL_CODE    CALCULATION_LEVEL_CODE,
        NULL                          ALLOW_RATE_OVERRIDE_FLAG ,
        opt.TAX_MAU                   TAX_MAU,
        opt.TAX_CURRENCY_CODE         TAX_CURRENCY_CODE,
        NULL                          TAX_CLASS,
        NULL                          TAX_REGIME_CODE,
        NULL			      TAX,
        NULL			      TAX_STATUS_CODE,
        NULL                          TAX_RATE_CODE,
        opt.INPUT_ROUNDING_RULE_CODE  ROUNDING_RULE_CODE,
        opt.INPUT_AMT_INCL_TAX_FLAG   AMT_INCL_TAX_FLAG,
        'MIGRATED'                    RECORD_TYPE_CODE,
        SYSDATE                       CREATION_DATE,
        fnd_global.user_id            CREATED_BY,
        fnd_global.user_id            LAST_UPDATED_BY,
        SYSDATE                       LAST_UPDATE_DATE,
        fnd_global.conc_login_id      LAST_UPDATE_LOGIN,
        NULL                          ATTRIBUTE_CATEGORY,
        NULL                          ATTRIBUTE1,
        NULL                          ATTRIBUTE2,
        NULL                          ATTRIBUTE3,
        NULL                          ATTRIBUTE4,
        NULL                          ATTRIBUTE5,
        NULL                          ATTRIBUTE6,
        NULL                          ATTRIBUTE7,
        NULL                          ATTRIBUTE8,
        NULL                          ATTRIBUTE9,
        NULL                          ATTRIBUTE10,
        NULL                          ATTRIBUTE11,
        NULL                          ATTRIBUTE12,
        NULL                          ATTRIBUTE13,
        NULL                          ATTRIBUTE14,
        NULL                          ATTRIBUTE15,
        opt.ALLOW_ROUNDING_OVERRIDE_FLAG  ALLOW_ROUNDING_OVERRIDE_FLAG
    From
        GL_TAX_OPTIONS    opt,
        zx_party_tax_profile ptp
    Where
        opt.input_tax_code is NULL  and
        opt.output_tax_code is NULL  and
        ptp.party_id        = decode(l_multi_org_flag,'N',l_org_id,opt.org_id) and
        ptp.party_type_code = 'OU' and
        opt.ledger_id =nvl(P_Ledger_Id,opt.ledger_id) and --added for sync
         decode(l_multi_org_flag,'N',l_org_id,opt.org_id) =nvl(P_Org_id, decode(l_multi_org_flag,'N',l_org_id,opt.org_id)) and                            --added for Sync
        NOT EXISTS ( Select 1
                     From zx_account_rates_tmp  -- Bug 6671444
                     Where ledger_id = opt.ledger_id
                     and  content_owner_id = ptp.PARTY_TAX_PROFILE_ID
                     and  account_segment_value is null
                     and  tax_class is NULL );

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_header(-)');
    END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: zx_mig_gl_tax_options_header ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('zx_mig_gl_tax_options_header(-)');
             END IF;
             app_exception.raise_exception;
END zx_mig_gl_tax_options_header;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    zx_mig_gl_tax_options_nt                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine migrates GL TAX OPTIONS SETUP for Non-Taxable Account    |
 |     Type.                                                                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        zx_mig_gl_tax_options                                              |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-Feb-05  Vamshi/Vinit        Created.                               |
 |                                                                           |
 +==========================================================================*/


PROCEDURE zx_mig_gl_tax_options_nt(P_Ledger_Id number,P_Org_id number,P_Account_Segment_Value varchar2) is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_nt(+)');
    END IF;

    Insert ALL
    Into zx_account_rates_tmp
    (
	 LEDGER_ID                      ,
	 CONTENT_OWNER_ID               ,
	 ACCOUNT_SEGMENT_VALUE          ,
 	 TAX_PRECISION                  ,
	 CALCULATION_LEVEL_CODE         ,
 	 ALLOW_RATE_OVERRIDE_FLAG       ,
	 TAX_MAU                        ,
	 TAX_CURRENCY_CODE              ,
	 TAX_CLASS                      ,
	 TAX_REGIME_CODE                ,
	 TAX                            ,
	 TAX_STATUS_CODE                ,
	 TAX_RATE_CODE                  ,
	 ROUNDING_RULE_CODE             ,
	 AMT_INCL_TAX_FLAG              ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15                    ,
	 ALLOW_ROUNDING_OVERRIDE_FLAG)
    Values
    (
 	 LEDGER_ID                      ,
	 CONTENT_OWNER_ID               ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_PRECISION                  ,
	 CALCULATION_LEVEL_CODE         ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 TAX_MAU                        ,
	 TAX_CURRENCY_CODE              ,
	 TAX_CLASS                      ,
	 TAX_REGIME_CODE                ,
	 TAX                            ,
	 TAX_STATUS_CODE                ,
	 TAX_RATE_CODE                  ,
	 ROUNDING_RULE_CODE             ,
	 AMT_INCL_TAX_FLAG              ,
  	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15                    ,
	 ALLOW_ROUNDING_OVERRIDE_FLAG)
    Select
	 accounts.ledger_id                      LEDGER_ID,
	 ptp.PARTY_TAX_PROFILE_ID                CONTENT_OWNER_ID,
	 ACCOUNT_SEGMENT_VALUE                   ACCOUNT_SEGMENT_VALUE,
	 'NON_TAXABLE'		                 TAX_CLASS,
         opt.TAX_PRECISION                       TAX_PRECISION,
	 opt.CALCULATION_LEVEL_CODE              CALCULATION_LEVEL_CODE,
         opt.TAX_MAU                             TAX_MAU,
	 opt.TAX_CURRENCY_CODE                   TAX_CURRENCY_CODE,
	 NULL                                    TAX_CLASSIFICATION_CODE,
         opt.INPUT_ROUNDING_RULE_CODE            ROUNDING_RULE_CODE,
         NULL                                    TAX_REGIME_CODE,
	 NULL                                    TAX,
	 NULL                                    TAX_STATUS_CODE,
	 NULL                                    TAX_RATE_CODE,
         accounts.ALLOW_TAX_CODE_OVERRIDE_FLAG   ALLOW_TAX_CODE_OVERRIDE_FLAG,
         accounts.AMOUNT_INCLUDES_TAX_FLAG       AMT_INCL_TAX_FLAG,
	 'MIGRATED'                              RECORD_TYPE_CODE,
	 SYSDATE 		                 CREATION_DATE,
	 fnd_global.user_id	                 CREATED_BY,
	 fnd_global.user_id	                 LAST_UPDATED_BY,
	 SYSDATE		                 LAST_UPDATE_DATE,
	 fnd_global.conc_login_id                LAST_UPDATE_LOGIN,
	 NULL			                 ATTRIBUTE_CATEGORY,
	 NULL			       		 ATTRIBUTE1,
	 NULL			       		 ATTRIBUTE2,
	 NULL			        	 ATTRIBUTE3,
	 NULL		              		 ATTRIBUTE4,
	 NULL			        	 ATTRIBUTE5,
	 NULL			        	 ATTRIBUTE6,
	 NULL			       		 ATTRIBUTE7,
	 NULL			       		 ATTRIBUTE8,
	 NULL			       		 ATTRIBUTE9,
	 NULL			       		 ATTRIBUTE10,
	 NULL			       		 ATTRIBUTE11,
	 NULL			       		 ATTRIBUTE12,
	 NULL			       		 ATTRIBUTE13,
	 NULL	                   		 ATTRIBUTE14,
         NULL                      		 ATTRIBUTE15,
         opt.ALLOW_ROUNDING_OVERRIDE_FLAG        ALLOW_ROUNDING_OVERRIDE_FLAG
    From
        gl_tax_option_accounts accounts,
        gl_tax_options         opt,
        zx_party_tax_profile   ptp
    Where
        accounts.ledger_id = opt.ledger_id and
        decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) =  decode(l_multi_org_flag,'N',l_org_id,opt.org_id) and
        accounts.tax_type_code = 'N' and
        ptp.party_id =  decode(l_multi_org_flag,'N',l_org_id,opt.org_id) and
        ptp.party_type_code = 'OU' and
        accounts.ledger_id =nvl(P_Ledger_Id,accounts.ledger_id) and --added for sync
        decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) =nvl(P_Org_id,decode(l_multi_org_flag,'N',l_org_id,accounts.org_id)) and
        --added for Sync
        accounts.account_segment_value = nvl(P_Account_Segment_Value,accounts.account_segment_value) and --added for sync
        NOT EXISTS ( Select 1
	                     From zx_account_rates_tmp --Bug 6671444
	                     Where ledger_id = opt.ledger_id
	                     and  content_owner_id = ptp.party_tax_profile_id
	                     and  account_segment_value = accounts.account_segment_value
                             and  tax_class = 'NON_TAXABLE' );

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_nt(-)');
    END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: zx_mig_gl_tax_options_nt ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('zx_mig_gl_tax_options_nt(-)');
             END IF;
             app_exception.raise_exception;
END zx_mig_gl_tax_options_nt;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    zx_mig_gl_tax_options_ap                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine migrates GL TAX OPTIONS SETUP for AP(Input Tax).         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        zx_mig_gl_tax_options                                              |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-Feb-05  Vamshi/Vinit        Created.                               |
 |                                                                           |
 +==========================================================================*/


PROCEDURE zx_mig_gl_tax_options_ap(P_Ledger_Id number,P_Org_id number,P_Account_Segment_Value varchar2) is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_ap(+)');
    END IF;

    Insert ALL
    Into zx_account_rates_tmp
    (
         LEDGER_ID                      ,
         CONTENT_OWNER_ID               ,
         ACCOUNT_SEGMENT_VALUE          ,
         TAX_PRECISION                  ,
         CALCULATION_LEVEL_CODE         ,
         ALLOW_RATE_OVERRIDE_FLAG       ,
         TAX_MAU                        ,
         TAX_CURRENCY_CODE              ,
         TAX_CLASS                      ,
         TAX_REGIME_CODE                ,
         TAX                            ,
         TAX_STATUS_CODE                ,
         TAX_RATE_CODE                  ,
         ROUNDING_RULE_CODE             ,
         AMT_INCL_TAX_FLAG              ,
         RECORD_TYPE_CODE               ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_DATE               ,
         LAST_UPDATE_LOGIN              ,
         ATTRIBUTE_CATEGORY             ,
         ATTRIBUTE1                     ,
         ATTRIBUTE2                     ,
         ATTRIBUTE3                     ,
         ATTRIBUTE4                     ,
         ATTRIBUTE5                     ,
         ATTRIBUTE6                     ,
         ATTRIBUTE7                     ,
         ATTRIBUTE8                     ,
         ATTRIBUTE9                     ,
         ATTRIBUTE10                    ,
         ATTRIBUTE11                    ,
         ATTRIBUTE12                    ,
         ATTRIBUTE13                    ,
         ATTRIBUTE14                    ,
         ATTRIBUTE15                    ,
         ALLOW_ROUNDING_OVERRIDE_FLAG)
    Values
    (
         LEDGER_ID                      ,
         CONTENT_OWNER_ID               ,
         ACCOUNT_SEGMENT_VALUE          ,
         TAX_PRECISION                  ,
         CALCULATION_LEVEL_CODE         ,
         ALLOW_RATE_OVERRIDE_FLAG       ,
         TAX_MAU                        ,
         TAX_CURRENCY_CODE              ,
         TAX_CLASS                      ,
         TAX_REGIME_CODE                ,
         TAX                            ,
         TAX_STATUS_CODE                ,
         TAX_RATE_CODE                  ,
         ROUNDING_RULE_CODE             ,
         AMT_INCL_TAX_FLAG              ,
         RECORD_TYPE_CODE               ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_DATE               ,
         LAST_UPDATE_LOGIN              ,
         ATTRIBUTE_CATEGORY             ,
         ATTRIBUTE1                     ,
         ATTRIBUTE2                     ,
         ATTRIBUTE3                     ,
         ATTRIBUTE4                     ,
         ATTRIBUTE5                     ,
         ATTRIBUTE6                     ,
         ATTRIBUTE7                     ,
         ATTRIBUTE8                     ,
         ATTRIBUTE9                     ,
         ATTRIBUTE10                    ,
         ATTRIBUTE11                    ,
         ATTRIBUTE12                    ,
         ATTRIBUTE13                    ,
         ATTRIBUTE14                    ,
         ATTRIBUTE15                    ,
         ALLOW_ROUNDING_OVERRIDE_FLAG)
    Select
        opt.ledger_id                 LEDGER_ID,
        rates.CONTENT_OWNER_ID        CONTENT_OWNER_ID,
        NULL                          ACCOUNT_SEGMENT_VALUE ,
        opt.TAX_PRECISION             TAX_PRECISION,
        opt.CALCULATION_LEVEL_CODE    CALCULATION_LEVEL_CODE,
        NULL                          ALLOW_RATE_OVERRIDE_FLAG ,
        opt.TAX_MAU                   TAX_MAU,
        opt.TAX_CURRENCY_CODE         TAX_CURRENCY_CODE,
        'INPUT'                       TAX_CLASS,
        rates.TAX_REGIME_CODE         TAX_REGIME_CODE,
        rates.TAX                     TAX,
        rates.TAX_STATUS_CODE         TAX_STATUS_CODE,
        rates.TAX_RATE_CODE           TAX_RATE_CODE,
        opt.INPUT_ROUNDING_RULE_CODE  ROUNDING_RULE_CODE,
        opt.INPUT_AMT_INCL_TAX_FLAG   AMT_INCL_TAX_FLAG,
        'MIGRATED'                    RECORD_TYPE_CODE,
        SYSDATE                       CREATION_DATE,
        fnd_global.user_id            CREATED_BY,
        fnd_global.user_id            LAST_UPDATED_BY,
        SYSDATE                       LAST_UPDATE_DATE,
        fnd_global.conc_login_id      LAST_UPDATE_LOGIN,
        NULL                          ATTRIBUTE_CATEGORY,
        NULL                          ATTRIBUTE1,
        NULL                          ATTRIBUTE2,
        NULL                          ATTRIBUTE3,
        NULL                          ATTRIBUTE4,
        NULL                          ATTRIBUTE5,
        NULL                          ATTRIBUTE6,
        NULL                          ATTRIBUTE7,
        NULL                          ATTRIBUTE8,
        NULL                          ATTRIBUTE9,
        NULL                          ATTRIBUTE10,
        NULL                          ATTRIBUTE11,
        NULL                          ATTRIBUTE12,
        NULL                          ATTRIBUTE13,
        NULL                          ATTRIBUTE14,
        NULL                          ATTRIBUTE15,
        opt.ALLOW_ROUNDING_OVERRIDE_FLAG  ALLOW_ROUNDING_OVERRIDE_FLAG
    From
        GL_TAX_OPTIONS    opt,
        ap_tax_codes_all  aptax,
        zx_RATES_B        rates
    Where
        opt.ledger_id = aptax.set_of_books_id and
        decode(l_multi_org_flag,'N',l_org_id,opt.org_id)= decode(l_multi_org_flag,'N',l_org_id,aptax.org_id) and
        opt.input_tax_code = aptax.name  and
        sysdate between aptax.start_date and nvl(aptax.inactive_date,sysdate) and
        aptax.tax_id=nvl(rates.source_id,rates.tax_rate_id) and
        nvl(aptax.enabled_flag, 'Y') = 'Y' and
        rates.record_type_code = 'MIGRATED' and
        nvl(rates.tax_class,'INPUT') = 'INPUT' and
        opt.ledger_id =nvl(P_Ledger_Id,opt.ledger_id) and --added for sync
	decode(l_multi_org_flag,'N',l_org_id,opt.org_id)=nvl(P_Org_id,decode(l_multi_org_flag,'N',l_org_id,opt.org_id)) and  --added for Sync
	NOT EXISTS ( Select 1
                     From zx_account_rates_tmp --Bug 6671444
                     Where ledger_id = opt.ledger_id
                     and  content_owner_id = rates.content_owner_id
                     and  account_segment_value is null
                     and  tax_class = 'INPUT' );

    Insert ALL
    Into zx_account_rates_tmp
    (
	 LEDGER_ID                      ,
	 CONTENT_OWNER_ID               ,
	 ACCOUNT_SEGMENT_VALUE          ,
 	 TAX_PRECISION                  ,
	 CALCULATION_LEVEL_CODE         ,
 	 ALLOW_RATE_OVERRIDE_FLAG       ,
	 TAX_MAU                        ,
	 TAX_CURRENCY_CODE              ,
	 TAX_CLASS                      ,
	 TAX_REGIME_CODE                ,
	 TAX                            ,
	 TAX_STATUS_CODE                ,
	 TAX_RATE_CODE                  ,
	 ROUNDING_RULE_CODE             ,
	 AMT_INCL_TAX_FLAG              ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15                    ,
	 ALLOW_ROUNDING_OVERRIDE_FLAG)
    Values
    (
 	 LEDGER_ID                      ,
	 CONTENT_OWNER_ID               ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_PRECISION                  ,
	 CALCULATION_LEVEL_CODE         ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 TAX_MAU                        ,
	 TAX_CURRENCY_CODE              ,
	 TAX_CLASS                      ,
	 TAX_REGIME_CODE                ,
	 TAX                            ,
	 TAX_STATUS_CODE                ,
	 TAX_RATE_CODE                  ,
	 ROUNDING_RULE_CODE             ,
	 AMT_INCL_TAX_FLAG              ,
  	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15                    ,
	 ALLOW_ROUNDING_OVERRIDE_FLAG)
    INTO ZX_ACCT_TX_CLS_DEFS_ALL
    (
	 LEDGER_ID		  	,
	 ORG_ID                         ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_CLASS                      ,
	 TAX_CLASSIFICATION_CODE        ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15 )
    Values
    (
	 LEDGER_ID		  	,
	 ORG_ID                         ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_CLASS                      ,
	 TAX_CLASSIFICATION_CODE        ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15 )
    Select
	 accounts.ledger_id                      LEDGER_ID,
	 rates.CONTENT_OWNER_ID                  CONTENT_OWNER_ID,
	 decode(l_multi_org_flag,'N',l_org_id,accounts.ORG_ID)                         ORG_ID,
	 ACCOUNT_SEGMENT_VALUE                   ACCOUNT_SEGMENT_VALUE,
	 'INPUT'		                 TAX_CLASS,
         opt.TAX_PRECISION                       TAX_PRECISION,
	 opt.CALCULATION_LEVEL_CODE              CALCULATION_LEVEL_CODE,
         opt.TAX_MAU                             TAX_MAU,
	 opt.TAX_CURRENCY_CODE                   TAX_CURRENCY_CODE,
	 accounts.TAX_CODE                       TAX_CLASSIFICATION_CODE,
         opt.INPUT_ROUNDING_RULE_CODE            ROUNDING_RULE_CODE,
         rates.TAX_REGIME_CODE                   TAX_REGIME_CODE,
	 rates.TAX                               TAX,
	 rates.TAX_STATUS_CODE                   TAX_STATUS_CODE,
	 rates.TAX_RATE_CODE                     TAX_RATE_CODE,
         accounts.ALLOW_TAX_CODE_OVERRIDE_FLAG   ALLOW_TAX_CODE_OVERRIDE_FLAG,
         accounts.AMOUNT_INCLUDES_TAX_FLAG       AMT_INCL_TAX_FLAG,
	 'MIGRATED'                              RECORD_TYPE_CODE,
	 SYSDATE 		                 CREATION_DATE,
	 fnd_global.user_id	                 CREATED_BY,
	 fnd_global.user_id	                 LAST_UPDATED_BY,
	 SYSDATE		                 LAST_UPDATE_DATE,
	 fnd_global.conc_login_id                LAST_UPDATE_LOGIN,
	 NULL			                 ATTRIBUTE_CATEGORY,
	 NULL			       		 ATTRIBUTE1,
	 NULL			       		 ATTRIBUTE2,
	 NULL			        	 ATTRIBUTE3,
	 NULL		              		 ATTRIBUTE4,
	 NULL			        	 ATTRIBUTE5,
	 NULL			        	 ATTRIBUTE6,
	 NULL			       		 ATTRIBUTE7,
	 NULL			       		 ATTRIBUTE8,
	 NULL			       		 ATTRIBUTE9,
	 NULL			       		 ATTRIBUTE10,
	 NULL			       		 ATTRIBUTE11,
	 NULL			       		 ATTRIBUTE12,
	 NULL			       		 ATTRIBUTE13,
	 NULL	                   		 ATTRIBUTE14,
         NULL                      		 ATTRIBUTE15,
         opt.ALLOW_ROUNDING_OVERRIDE_FLAG        ALLOW_ROUNDING_OVERRIDE_FLAG
    From
        gl_tax_option_accounts accounts,
        ap_tax_codes_all       aptax,
        gl_tax_options         opt,
        zx_rates_b             rates
    Where
        accounts.ledger_id = opt.ledger_id and
        decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) = decode(l_multi_org_flag,'N',l_org_id,opt.org_id) and
        accounts.ledger_id = aptax.set_of_books_id and
        decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) = decode(l_multi_org_flag,'N',l_org_id,aptax.org_id) and
        accounts.tax_type_code = 'I' and
        accounts.tax_code = aptax.name  and
        sysdate between aptax.start_date and nvl(aptax.inactive_date,sysdate) and
        nvl(aptax.enabled_flag, 'Y') = 'Y' and
        aptax.tax_id = nvl(rates.source_id,rates.tax_rate_id) and
        nvl(rates.tax_class,'INPUT') = 'INPUT' and
        rates.record_type_code = 'MIGRATED' and
        accounts.ledger_id =nvl(P_Ledger_Id,accounts.ledger_id) and --added for sync
	decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) =nvl(P_Org_id,decode(l_multi_org_flag,'N',l_org_id,accounts.org_id)) and
       --added for Sync
        accounts.account_segment_value = nvl(P_Account_Segment_Value,accounts.account_segment_value) and --added for sync
        NOT EXISTS ( Select 1
	                     From zx_account_rates_tmp --Bug 6671444
	                     Where ledger_id = opt.ledger_id
	                     and  content_owner_id = rates.content_owner_id
	                     and  account_segment_value = accounts.account_segment_value
                             and  tax_class = 'INPUT' );

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_ap(-)');
    END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: zx_mig_gl_tax_options_ap ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('zx_mig_gl_tax_options_ap(-)');
             END IF;
             app_exception.raise_exception;
END zx_mig_gl_tax_options_ap;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    zx_mig_gl_tax_options_ar                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine migrates GL TAX OPTIONS SETUP for AR(Output Tax).        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        zx_mig_gl_tax_options                                              |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-Feb-05  Vamshi/Vinit        Created.                               |
 |                                                                           |
 +==========================================================================*/

PROCEDURE zx_mig_gl_tax_options_ar(P_Ledger_Id number,P_Org_id number,P_Account_Segment_Value varchar2) is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_ar(+)');
    END IF;

    Insert ALL
    Into zx_account_rates_tmp
    (
         LEDGER_ID                      ,
         CONTENT_OWNER_ID               ,
         ACCOUNT_SEGMENT_VALUE          ,
         TAX_PRECISION                  ,
         CALCULATION_LEVEL_CODE         ,
         ALLOW_RATE_OVERRIDE_FLAG       ,
         TAX_MAU                        ,
         TAX_CURRENCY_CODE              ,
         TAX_CLASS                      ,
         TAX_REGIME_CODE                ,
         TAX                            ,
         TAX_STATUS_CODE                ,
         TAX_RATE_CODE                  ,
         ROUNDING_RULE_CODE             ,
         AMT_INCL_TAX_FLAG              ,
         RECORD_TYPE_CODE               ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_DATE               ,
         LAST_UPDATE_LOGIN              ,
         ATTRIBUTE_CATEGORY             ,
         ATTRIBUTE1                     ,
         ATTRIBUTE2                     ,
         ATTRIBUTE3                     ,
         ATTRIBUTE4                     ,
         ATTRIBUTE5                     ,
         ATTRIBUTE6                     ,
         ATTRIBUTE7                     ,
         ATTRIBUTE8                     ,
         ATTRIBUTE9                     ,
         ATTRIBUTE10                    ,
         ATTRIBUTE11                    ,
         ATTRIBUTE12                    ,
         ATTRIBUTE13                    ,
         ATTRIBUTE14                    ,
         ATTRIBUTE15                    ,
         ALLOW_ROUNDING_OVERRIDE_FLAG)
    Values
    (
         LEDGER_ID                      ,
         CONTENT_OWNER_ID               ,
         ACCOUNT_SEGMENT_VALUE          ,
         TAX_PRECISION                  ,
         CALCULATION_LEVEL_CODE         ,
         ALLOW_RATE_OVERRIDE_FLAG       ,
         TAX_MAU                        ,
         TAX_CURRENCY_CODE              ,
         TAX_CLASS                      ,
         TAX_REGIME_CODE                ,
         TAX                            ,
         TAX_STATUS_CODE                ,
         TAX_RATE_CODE                  ,
         ROUNDING_RULE_CODE             ,
         AMT_INCL_TAX_FLAG              ,
         RECORD_TYPE_CODE               ,
         CREATION_DATE                  ,
         CREATED_BY                     ,
         LAST_UPDATED_BY                ,
         LAST_UPDATE_DATE               ,
         LAST_UPDATE_LOGIN              ,
         ATTRIBUTE_CATEGORY             ,
         ATTRIBUTE1                     ,
         ATTRIBUTE2                     ,
         ATTRIBUTE3                     ,
         ATTRIBUTE4                     ,
         ATTRIBUTE5                     ,
         ATTRIBUTE6                     ,
         ATTRIBUTE7                     ,
         ATTRIBUTE8                     ,
         ATTRIBUTE9                     ,
         ATTRIBUTE10                    ,
         ATTRIBUTE11                    ,
         ATTRIBUTE12                    ,
         ATTRIBUTE13                    ,
         ATTRIBUTE14                    ,
         ATTRIBUTE15                    ,
         ALLOW_ROUNDING_OVERRIDE_FLAG)
    Select
        opt.ledger_id                 LEDGER_ID,
        rates.CONTENT_OWNER_ID        CONTENT_OWNER_ID,
        NULL                          ACCOUNT_SEGMENT_VALUE,
        opt.TAX_PRECISION             TAX_PRECISION,
        opt.CALCULATION_LEVEL_CODE    CALCULATION_LEVEL_CODE,
        NULL                          ALLOW_RATE_OVERRIDE_FLAG,
        opt.TAX_MAU                   TAX_MAU,
        opt.TAX_CURRENCY_CODE         TAX_CURRENCY_CODE,
        'OUTPUT'                      TAX_CLASS,
        rates.TAX_REGIME_CODE         TAX_REGIME_CODE,
        rates.TAX                     TAX,
        rates.TAX_STATUS_CODE         TAX_STATUS_CODE,
        rates.TAX_RATE_CODE           TAX_RATE_CODE,
        opt.OUTPUT_ROUNDING_RULE_CODE ROUNDING_RULE_CODE,
        opt.OUTPUT_AMT_INCL_TAX_FLAG  AMT_INCL_TAX_FLAG,
        'MIGRATED'                    RECORD_TYPE_CODE,
        SYSDATE                       CREATION_DATE,
        fnd_global.user_id            CREATED_BY,
        fnd_global.user_id            LAST_UPDATED_BY,
        SYSDATE                       LAST_UPDATE_DATE,
        fnd_global.conc_login_id      LAST_UPDATE_LOGIN,
        NULL                          ATTRIBUTE_CATEGORY,
        NULL                          ATTRIBUTE1,
        NULL                          ATTRIBUTE2,
        NULL                          ATTRIBUTE3,
        NULL                          ATTRIBUTE4,
        NULL                          ATTRIBUTE5,
        NULL                          ATTRIBUTE6,
        NULL                          ATTRIBUTE7,
        NULL                          ATTRIBUTE8,
        NULL                          ATTRIBUTE9,
        NULL                          ATTRIBUTE10,
        NULL                          ATTRIBUTE11,
        NULL                          ATTRIBUTE12,
        NULL                          ATTRIBUTE13,
        NULL                          ATTRIBUTE14,
        NULL                          ATTRIBUTE15,
        opt.ALLOW_ROUNDING_OVERRIDE_FLAG ALLOW_ROUNDING_OVERRIDE_FLAG
    From
        GL_TAX_OPTIONS    opt,
        AR_VAT_TAX_ALL    artax,
        zx_RATES_B        rates
    Where
        opt.ledger_id = artax.set_of_books_id and
        decode(l_multi_org_flag,'N',l_org_id,opt.org_id) = decode(l_multi_org_flag,'N',l_org_id,artax.org_id) and
        opt.output_tax_code = artax.tax_code  and
        sysdate between artax.start_date and nvl(artax.end_date,sysdate) and
        artax.vat_tax_id = nvl(rates.source_id,rates.tax_rate_id) and
        nvl(artax.enabled_flag, 'Y') = 'Y' and
        nvl(artax.tax_class, 'O') = 'O' and
        rates.record_type_code = 'MIGRATED' and
        nvl(rates.tax_class,'OUTPUT') = 'OUTPUT' and
        opt.ledger_id =nvl(P_Ledger_Id,opt.ledger_id) and --added for sync
        decode(l_multi_org_flag,'N',l_org_id,opt.org_id) =nvl(P_Org_id,decode(l_multi_org_flag,'N',l_org_id,opt.org_id)) and
        --added for Sync
        NOT EXISTS ( Select 1
		     From zx_account_rates_tmp --Bug 6671444
		     Where ledger_id = opt.ledger_id
		     and  content_owner_id = rates.content_owner_id
		     and  account_segment_value is null
                     and  tax_class = 'OUTPUT' );

    Insert ALL
    Into zx_account_rates_tmp
    (
	 LEDGER_ID                      ,
	 CONTENT_OWNER_ID               ,
	 ACCOUNT_SEGMENT_VALUE          ,
 	 TAX_PRECISION                  ,
	 CALCULATION_LEVEL_CODE         ,
 	 ALLOW_RATE_OVERRIDE_FLAG       ,
	 TAX_MAU                        ,
	 TAX_CURRENCY_CODE              ,
	 TAX_CLASS                      ,
	 TAX_REGIME_CODE                ,
	 TAX                            ,
	 TAX_STATUS_CODE                ,
	 TAX_RATE_CODE                  ,
	 ROUNDING_RULE_CODE             ,
	 AMT_INCL_TAX_FLAG              ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15                    ,
	 ALLOW_ROUNDING_OVERRIDE_FLAG)
    Values
    (
 	 LEDGER_ID                      ,
	 CONTENT_OWNER_ID               ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_PRECISION                  ,
	 CALCULATION_LEVEL_CODE         ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 TAX_MAU                        ,
	 TAX_CURRENCY_CODE              ,
	 TAX_CLASS                      ,
	 TAX_REGIME_CODE                ,
	 TAX                            ,
	 TAX_STATUS_CODE                ,
	 TAX_RATE_CODE                  ,
	 ROUNDING_RULE_CODE             ,
	 AMT_INCL_TAX_FLAG              ,
  	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15                    ,
	 ALLOW_ROUNDING_OVERRIDE_FLAG)
    INTO ZX_ACCT_TX_CLS_DEFS_ALL
    (
	 LEDGER_ID		  	,
	 ORG_ID                         ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_CLASS                      ,
	 TAX_CLASSIFICATION_CODE        ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15 )
    Values
    (
	 LEDGER_ID		  	,
	 ORG_ID                         ,
	 ACCOUNT_SEGMENT_VALUE          ,
	 TAX_CLASS                      ,
	 TAX_CLASSIFICATION_CODE        ,
	 ALLOW_TAX_CODE_OVERRIDE_FLAG   ,
	 RECORD_TYPE_CODE               ,
	 CREATION_DATE                  ,
	 CREATED_BY                     ,
	 LAST_UPDATED_BY                ,
	 LAST_UPDATE_DATE               ,
	 LAST_UPDATE_LOGIN              ,
	 ATTRIBUTE_CATEGORY             ,
	 ATTRIBUTE1                     ,
	 ATTRIBUTE2                     ,
	 ATTRIBUTE3                     ,
	 ATTRIBUTE4                     ,
	 ATTRIBUTE5                     ,
	 ATTRIBUTE6                     ,
	 ATTRIBUTE7                     ,
	 ATTRIBUTE8                     ,
	 ATTRIBUTE9                     ,
	 ATTRIBUTE10                    ,
	 ATTRIBUTE11                    ,
	 ATTRIBUTE12                    ,
	 ATTRIBUTE13                    ,
	 ATTRIBUTE14                    ,
	 ATTRIBUTE15 )
     Select
	 accounts.ledger_id       	         LEDGER_ID,
	 rates.CONTENT_OWNER_ID                  CONTENT_OWNER_ID,
	 decode(l_multi_org_flag,'N',l_org_id,accounts.ORG_ID )               	 ORG_ID,
	 ACCOUNT_SEGMENT_VALUE            	 ACCOUNT_SEGMENT_VALUE,
	 'OUTPUT'		       		 TAX_CLASS,
         opt.TAX_PRECISION              	 TAX_PRECISION,
	 opt.CALCULATION_LEVEL_CODE     	 CALCULATION_LEVEL_CODE,
         opt.TAX_MAU                             TAX_MAU,
	 opt.TAX_CURRENCY_CODE                   TAX_CURRENCY_CODE,
	 accounts.TAX_CODE                       TAX_CLASSIFICATION_CODE,
         opt.OUTPUT_ROUNDING_RULE_CODE           ROUNDING_RULE_CODE,
         rates.TAX_REGIME_CODE                   TAX_REGIME_CODE,
	 rates.TAX                               TAX,
	 rates.TAX_STATUS_CODE                   TAX_STATUS_CODE,
	 rates.TAX_RATE_CODE                     TAX_RATE_CODE,
         accounts.ALLOW_TAX_CODE_OVERRIDE_FLAG   ALLOW_TAX_CODE_OVERRIDE_FLAG ,
         accounts.AMOUNT_INCLUDES_TAX_FLAG       AMT_INCL_TAX_FLAG,
	 'MIGRATED'                     	 RECORD_TYPE_CODE,
	 SYSDATE 		       		 CREATION_DATE,
	 fnd_global.user_id	       		 CREATED_BY,
	 fnd_global.user_id	       		 LAST_UPDATED_BY,
	 SYSDATE		                 LAST_UPDATE_DATE,
	 fnd_global.conc_login_id       	 LAST_UPDATE_LOGIN,
	 NULL			       		 ATTRIBUTE_CATEGORY,
	 NULL			       		 ATTRIBUTE1,
	 NULL			       	 	 ATTRIBUTE2,
	 NULL			       		 ATTRIBUTE3,
	 NULL		               		 ATTRIBUTE4,
	 NULL			       		 ATTRIBUTE5,
	 NULL			       		 ATTRIBUTE6,
	 NULL			       		 ATTRIBUTE7,
	 NULL			       		 ATTRIBUTE8,
	 NULL			       		 ATTRIBUTE9,
	 NULL			       		 ATTRIBUTE10,
	 NULL			       		 ATTRIBUTE11,
	 NULL			       		 ATTRIBUTE12,
	 NULL			       		 ATTRIBUTE13,
	 NULL	                       		 ATTRIBUTE14,
         NULL                          		 ATTRIBUTE15,
         opt.ALLOW_ROUNDING_OVERRIDE_FLAG        ALLOW_ROUNDING_OVERRIDE_FLAG
    From
         gl_tax_option_accounts accounts,
         ar_vat_tax_all         artax,
         gl_tax_options         opt,
         zx_rates_b             rates
    Where
         accounts.ledger_id = opt.ledger_id and
         decode(l_multi_org_flag,'N',l_org_id,opt.org_id) = decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) and
         accounts.ledger_id = artax.set_of_books_id and
          decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) =  decode(l_multi_org_flag,'N',l_org_id,artax.org_id) and
         accounts.tax_type_code = 'O' and
         accounts.tax_code = artax.tax_code  and
         sysdate between artax.start_date and nvl(artax.end_date,sysdate) and
         nvl(artax.enabled_flag, 'Y') = 'Y' and
         nvl(artax.tax_class, 'O') = 'O' and
         artax.vat_tax_id = nvl(rates.source_id,rates.tax_rate_id) and
         nvl(rates.tax_class,'OUTPUT') = 'OUTPUT' and
         rates.record_type_code = 'MIGRATED' AND
         accounts.ledger_id =nvl(P_Ledger_Id,accounts.ledger_id) and --added for sync
	 decode(l_multi_org_flag,'N',l_org_id,accounts.org_id) =nvl(P_Org_id,decode(l_multi_org_flag,'N',l_org_id,accounts.org_id)) and
         --added for Sync
         accounts.account_segment_value = nvl(P_Account_Segment_Value,accounts.account_segment_value) and --added for sync
         NOT EXISTS ( Select 1
		      From zx_account_rates_tmp --Bug 6671444
		      Where ledger_id = opt.ledger_id
		      and  content_owner_id = rates.content_owner_id
		      and  account_segment_value = accounts.account_segment_value
		      and  tax_class = 'OUTPUT' );

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('zx_mig_gl_tax_options_ar(-)');
    END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: zx_mig_gl_tax_options_ar ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('zx_mig_gl_tax_options_ar(-)');
             END IF;
             app_exception.raise_exception;
END zx_mig_gl_tax_options_ar;

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
    arp_util_tax.debug('Exception in constructor of GL Tax Options Code '||sqlerrm);
END zx_mig_gl_tax_options_pkg;

/
