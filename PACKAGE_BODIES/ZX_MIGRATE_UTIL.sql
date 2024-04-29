--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_UTIL" AS
/* $Header: zxmigrateutilb.pls 120.15.12010000.2 2009/07/14 09:31:35 prigovin ship $ */

PG_DEBUG CONSTANT VARCHAR(1) default
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);


/*===========================================================================+
|  Function:     GET_TAX_REGIME                                              |
|  Description:  This function returns tax regime code using tax type and    |
|		 org_id in Tax Code.					     |
|    								             |
|  ARGUMENTS  : p_org_id    IN  : Organization ID    			     |
|               p_tax_type  IN  : Tax Type                                   |
|                                                                            |
|  History                                                                   |
|  14-Sep-2004  Yoshimichi Konishi  Modified the function to use get_country |
|                                   procedure.                               |
|    									     |
+===========================================================================*/
FUNCTION GET_TAX_REGIME (p_tax_type        IN  VARCHAR2,
                         p_org_id          IN  NUMBER) RETURN VARCHAR2
IS
 l_country hr_locations_all.country%TYPE;
 p_tax_regime_code VARCHAR2(30);

BEGIN

 l_country := get_country(p_org_id);

 IF l_country IS NOT NULL THEN
     p_tax_regime_code := l_country || '-' || p_tax_type;
 ELSE
     p_tax_regime_code := p_tax_type;
 END IF;

 RETURN p_tax_regime_code;

END GET_TAX_REGIME ;

FUNCTION GET_TAX (p_tax_name    IN  VARCHAR2 ,
                  p_tax_type    IN  VARCHAR2 ) RETURN VARCHAR2
IS
   p_tax VARCHAR2(50);
BEGIN
   IF length(p_tax_name) = lengthb(p_tax_name) THEN
      --
      -- Strip numbers , space and special characters
      --
      -- numbers(0123456789), space( ), dash(-), underscore(_),
      -- percent(%), comma(,), period(.), asterisk(*), at(@),
      -- exclamation(!), pound(#), tilde(~), dollar($), carat(^),
      -- ampasand(&), plus(+), equal(=), backslash(\), vertical(|),
      -- colon(:), semi colon(;), quote('), double quote("),
      -- question(?), slash(/)

      -- If Tax contains only numbers and special characters then
      -- tax = tax_type|| '-' ||name

      p_tax := nvl(replace(translate(p_tax_name,'1234567890 -_%,.*@!#~$^&+=\|:;"?/''',
                                                '                                  '),' ','')
                                                    ,p_tax_type || '-' || p_tax_name) ;



   ELSE
      -- Multi byte Tax will be converted to Tax Type || '-' || Tax .
         p_tax := p_tax_type || '-' || p_tax_name;
   END IF;

       IF lengthb(p_tax)>30
       THEN
            --Bug 8676678
            --Replaced the sequence ZX_MIG_TAX_S with ZX_TAXES_B_S
            p_tax:=substrb(p_tax,1,24)||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_TAXES_B_S');
       END IF;

   RETURN p_tax;
END GET_TAX;

/*===========================================================================+
|  Function:     IS_INSTALLED                                               |
|  Description:  This function returns true if the passed product code	    |
|		 is installed.						    |
|    								            |
|  ARGUMENTS  : Product Code						    |
|                                                                           |
|                                                                           |
|  History                                                                  |
|   11-Aug-04	Venkat		Initial Version                             |
|    									    |
+===========================================================================*/


FUNCTION IS_INSTALLED(p_product_code IN Varchar2)
	 RETURN VARCHAR2 IS

	l_status 	fnd_product_installations.STATUS%type;
	l_db_status	fnd_product_installations.DB_STATUS%type;
	l_product_id    Number;

BEGIN

	arp_util_tax.debug( ' IS_INSTALLED .. (+) ' );

	IF p_product_code = 'INV' THEN
	   l_product_id := 401;
	ELSIF p_product_code = 'AP' THEN
	   l_product_id := 200;
	ELSIF p_product_code = 'AR' THEN
	   l_product_id := 222;
	END IF;

	BEGIN
		SELECT 	STATUS, DB_STATUS
			INTO l_status, l_db_status
		FROM
			FND_PRODUCT_INSTALLATIONS
		WHERE
			APPLICATION_ID = l_product_id;
	EXCEPTION
		WHEN OTHERS THEN
		   arp_util_tax.debug('Error while getting status and db status value from FND_PRODUCT_INSTALLATIONS');
	END;

	arp_util_tax.debug( ' IS_INSTALLED .. (-) ' );

	IF (nvl(l_status,'N') in ('I','S') or
	    nvl(l_db_status,'N') in ('I','S')) THEN
		return 'Y';
	ELSE
		return 'N';
	END IF;

END IS_INSTALLED;



/*===========================================================================+
|  Procedure:    ZX_UPDATE_LOOKUPS                                           |
|  Description:  This Procedure updates the customization level              |
|                to system in pre-upgrade run mode and reverts back          |
|                in other mode. To lock lookups related to FC and Tax Def    |
|                so that user would not be able to create new codes and this |
|                avoids need for synchronization.                            |
|                                                                            |
|  ARGUMENTS  :                                                              |
|                                                                            |
| MODIFICATION HISTORY                                                       |
|                                                                            |
| 01-Mar-04    Ranjith Palani        Created.                                |
 +===========================================================================*/
PROCEDURE ZX_UPDATE_LOOKUPS(P_UPGRADE_MODE IN VARCHAR2) IS

BEGIN

        arp_util_tax.debug('ZX_UPDATE_LOOKUPS (+) ' );

        IF  P_UPGRADE_MODE = 'PRE-UPGRADE' THEN

           arp_util_tax.debug(' Updating fnd_lookup_types setting the customization level to System' );

                UPDATE  fnd_lookup_types
                SET             customization_level = 'S'
                WHERE   lookup_type in
                                ('JLCL_AP_DOCUMENT_TYPE',
                                'JGZZ_STATISTICAL_CODE',
                                'JEES_INVOICE_CATEGORY',
                                'JATW_DEDUCTIBLE_TYPE',
                                'JATW_GUI_TYPE',
                                -- Tax Def Lookups
                                'TAX TYPE' , 'JATW_GOVERNMENT_TAX_TYPE' , 'JLCL_TAX_CODE_CLASS'
                                );

        ELSE

           arp_util_tax.debug(' Updating fnd_lookup_types setting the customization level to Extensible..' );

                UPDATE  fnd_lookup_types
                SET             customization_level = 'U'
                WHERE   lookup_type in
                                ('JLCL_AP_DOCUMENT_TYPE',
                                'JGZZ_STATISTICAL_CODE',
                                'JEES_INVOICE_CATEGORY',
                                -- Tax Def Lookups
                                'JLCL_TAX_CODE_CLASS'
                                );

           arp_util_tax.debug(' Updating fnd_lookup_types setting the customization level to user..' );

                UPDATE  fnd_lookup_types
                SET             customization_level = 'E'
                WHERE   lookup_type in
                                ('JATW_DEDUCTIBLE_TYPE',
                                'JATW_GUI_TYPE',
                                -- Tax Def Lookups
                                'TAX TYPE' , 'JATW_GOVERNMENT_TAX_TYPE'
                                );

        END IF;

        arp_util_tax.debug(' ZX_UPDATE_LOOKUPS (-) ' );

END ZX_UPDATE_LOOKUPS;


/*===========================================================================+
|  Function:     GET_COUNTRY                                                 |
|  Description:  This function returns country code.         	             |
|    								             |
|  ARGUMENTS  : p_org_id IN  organization_id    			     |
|                                                                            |
|                                                                            |
|  History                                                                   |
|   14-Sep-04	Yoshimichi Konishi   Created                                 |
|    									     |
+===========================================================================*/

FUNCTION get_country(p_org_id  IN  NUMBER) RETURN VARCHAR2 IS

 l_country hr_locations_all.country%TYPE;
 l_style   hr_locations_all.style%TYPE;
 l_vat_country_code financials_system_params_all.vat_country_code%TYPE;

BEGIN
 -- 1. Select country code from hr_location
 BEGIN
 /*Bug fix 5245448*/
 if l_multi_org_flag = 'Y'
 then
   SELECT substr(loc.country,1,2),
          substr(loc.style,1,2)
     INTO l_country,
          l_style
     FROM hr_all_organization_units ou,
          hr_organization_information oi,
          hr_locations_all loc
    WHERE ou.organization_id = oi.organization_id
      AND ou.location_id = loc.location_id
      AND oi.org_information_context = 'Operating Unit Information'
      AND oi.organization_id = p_org_id;
  else
     SELECT substr(loc.country,1,2),
          substr(loc.style,1,2)
     INTO l_country,
          l_style
     FROM hr_all_organization_units ou,
          hr_organization_information oi,
          hr_locations_all loc
    WHERE oi.organization_id = l_org_id
      AND ou.organization_id = oi.organization_id
      AND ou.location_id = loc.location_id
      AND oi.org_information_context = 'Operating Unit Information';
   end if;

 EXCEPTION
    WHEN OTHERS THEN
        l_country := NULL;
        l_style := NULL;
 END;

 -- 2. Select default_country from AR System Options
 -- ar_system_parameters_all.default_country is mandatory in UI
 IF l_country IS NULL THEN
   BEGIN
     SELECT default_country
     INTO   l_country
     FROM   ar_system_parameters_all
     WHERE  decode(l_multi_org_flag,'N',l_org_id,org_id) = p_org_id
     AND    org_id <> -3113 ; --Bug Fix 5108463
   EXCEPTION
     WHEN OTHERS THEN
        l_country := NULL;
        l_style := NULL;
   END;
 END IF;

 -- 3. Select vat_country_code from Financials System Options
 -- Applies to the instance where only AP is installed.
 IF l_country IS NULL THEN
   BEGIN
     SELECT  vat_country_code
     INTO    l_vat_country_code
     FROM    financials_system_params_all
     WHERE   decode(l_multi_org_flag,'N',l_org_id,org_id) = p_org_id;
   EXCEPTION
     WHEN OTHERS THEN
       l_country := NULL;
       l_style := NULL;
   END;
 END IF;

 -- 4. None of them above did not work to get country information
 -- Use location style to get country code
 IF l_country IS NULL THEN
   IF l_style IS NOT NULL THEN
      l_country := l_style;
   ELSE
      l_country := NULL;
   END IF;
 END IF;

 RETURN l_country;

END;

/*===========================================================================+
|  Function:     GET_NEXT_SEQID                                              |
|  Description:  This function returns next sequence value for a given       |
|    		 sequence name				                     |
|  ARGUMENTS  :  p_seq_name IN  sequence name   			     |
|                                                                            |
|                                                                            |
|  History                                                                   |
|   07-Oct-04	Arnab Sengupta       Created                                 |
|    									     |
+===========================================================================*/


FUNCTION get_next_seqid(p_seq_name varchar2) return number is

seq_id number;

begin

EXECUTE IMMEDIATE 'SELECT '||p_seq_name||'.nextval from dual ' INTO seq_id;

return seq_id;

end get_next_seqid;

/*===========================================================================+
|  Procedure  :  ZX_ALTER_RATES_SEQUENCE                                     |
|  Description:  This function is used to bump the zx_rates_b_s sequence     |
|                                                                            |
|  ARGUMENTS  :  None                                                        |
|                                                                            |
|                                                                            |
|  History                                                                   |
|   18-Jul-05   Arnab Sengupta       Created                                 |
|                                                                            |
+===========================================================================*/


PROCEDURE zx_alter_rates_sequence  IS


l_new_seq_id NUMBER;
l_rates_count NUMBER;

BEGIN

SELECT count(tax_rate_id) into l_rates_count from zx_rates_b where record_type_code = 'MIGRATED';

IF l_rates_count = 0
THEN

SELECT decode(sign(AP_TAX_CODES_S.nextval - AR_VAT_TAX_S.nextval),
                            '-1',AR_VAT_TAX_S.currval,
                                  AP_TAX_CODES_S.currval)
INTO l_new_seq_id
FROM DUAL;


EXECUTE IMMEDIATE  'DROP    SEQUENCE   ZX.ZX_RATES_B_S';
EXECUTE IMMEDIATE  'CREATE SEQUENCE  ZX.ZX_RATES_B_S    START    WITH '||l_new_seq_id;

END IF;


END;


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
    arp_util_tax.debug('Exception in constructor of Migrate Util '||sqlerrm);


end Zx_Migrate_Util;

/
