--------------------------------------------------------
--  DDL for Package Body AP_TCA_SUPPLIER_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TCA_SUPPLIER_SYNC_PKG" AS
/* $Header: aptcasyb.pls 120.3.12010000.6 2010/02/25 23:01:18 vinaik ship $ */

  -- Logging Infrastructure
  G_CURRENT_RUNTIME_LEVEL       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED   CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR        CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION    CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT        CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE    CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT    CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME        CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_TCA_SUPPLIER_SYNC_PKG.';

  -- Procedure Sync Supplier
  PROCEDURE SYNC_Supplier
            (x_return_status    OUT     NOCOPY VARCHAR2,
             x_msg_count        OUT     NOCOPY NUMBER,
             x_msg_data         OUT     NOCOPY VARCHAR2,
             x_party_id         IN             NUMBER) IS

    l_num_1099                   ap_suppliers.num_1099%type;
    l_vat_registration_num       ap_suppliers.vat_registration_num%type;
    l_vendor_name_alt            ap_suppliers.vendor_name_alt%type;
    l_vendor_name                ap_suppliers.vendor_name%type;
    l_tca_vendor_name            ap_suppliers.tca_sync_vendor_name%type;
    l_tca_vat_registration_num   ap_suppliers.tca_sync_vat_reg_num%type;
    l_check_party_id             hz_parties.party_id%type;
    l_upgraded_num_1099          ap_suppliers.num_1099%type;
    l_check_num_1099             ap_suppliers.tca_sync_num_1099%type;

    -- Logging Infra:
    l_procedure_name             CONSTANT VARCHAR2(30) := 'SYNC_Supplier';
    l_log_msg                    FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Begin of procedure '|| l_procedure_name;
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                       l_procedure_name||'.begin', l_log_msg);
    END IF;

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Party ID '|| x_party_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                       '.'||l_procedure_name, l_log_msg);
    END IF;


    IF x_party_id IS NOT NULL THEN

       -- Logging Infra: Statement level
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Select sync attrributes from TCA for '|| x_party_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                        '.'||l_procedure_name, l_log_msg);
       END IF;

       SELECT jgzz_fiscal_code,
              substrb(tax_reference,1,20),
              organization_name_phonetic,
              substrb(party_name,1,240),
              party_name,
              tax_reference
       INTO   l_num_1099,
              l_vat_registration_num,
              l_vendor_name_alt,
              l_vendor_name,
              l_tca_vendor_name,
              l_tca_vat_registration_num
       FROM   hz_parties
       WHERE  party_id = x_party_id;

       -- Logging Infra: Statement level
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'After Selecting Attributes for '|| x_party_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                        '.'||l_procedure_name, l_log_msg);
       END IF;

       -- Logging Infra: Statement level
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'Select to check if supplier exists for '|| x_party_id;
           FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                        '.'||l_procedure_name, l_log_msg);
       END IF;

       --
       -- Here we are also selecting the num_1099 columns
       -- the num_1099 (tax payer id) has a greater length in
       -- AP than in TCA.
       -- In the upgraded case, we wanted to preserve the old value
       -- hence we are moving the old value from the num_1099 column
       -- to tca_sync_num_1099 column. We will do this only if the
       -- tca_sync_num_1099 column is null (only the first time).
       --

       BEGIN
         SELECT party_id,
                num_1099,
                tca_sync_num_1099
         INTO   l_check_party_id,
                l_upgraded_num_1099,
                l_check_num_1099
         FROM   ap_suppliers
         WHERE  party_id = x_party_id;
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
       END;

       IF l_check_party_id IS NOT NULL THEN

        --bug6050423.We maintain the sync from tca to ap only if the vendor type is
	--not contractor individual.For contractor individuals,if we update the
	--the jgzz_fisacl_code in tca,the same thing will not be reflected in
	--num_1099 of the ap_suppliers.We store the TIN numbers of the contractors
	--in the field individual_1099 of ap_suppliers and not in TCA.


	UPDATE ap_suppliers
        SET
        --bug6691916.commented the below assignment statement and added
        --the one below that.As per analysis,only organization type lookup
        --code of individual or foreign individual are considered
	/*num_1099              = decode(UPPER(vendor_type_lookup_code),'CONTRACTOR',
						decode(UPPER(organization_type_lookup_code),
							'INDIVIDUAL',NULL,
							'FOREIGN INDIVIDUAL',NULL,
							'PARTNERSHIP',NULL,
							'FOREIGN PARTNERSHIP',NULL,
							l_num_1099),
						l_num_1099),*/
          num_1099                    = decode(UPPER(organization_type_lookup_code),
                                                        'INDIVIDUAL',NULL,
                                                        'FOREIGN INDIVIDUAL',NULL,
					 l_num_1099),
                vat_registration_num  = l_vat_registration_num,
                vendor_name_alt       = l_vendor_name_alt,
           /*   vendor_name           = l_vendor_name), commented for  Bug9328048 */
                vendor_name           =  decode(vendor_type_lookup_code, 'EMPLOYEE',nvl(vendor_name,l_vendor_name),l_vendor_name), --Bug9328048
                tca_sync_vendor_name  = l_tca_vendor_name,
                tca_sync_vat_reg_num  = l_tca_vat_registration_num,
                tca_sync_num_1099     = nvl(l_check_num_1099,
                                            l_upgraded_num_1099)
         WHERE  party_id              = x_party_id;

         -- Logging Infra: Statement level
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
             l_log_msg := 'After updating suppliers for '|| x_party_id;
             FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                          '.'||l_procedure_name, l_log_msg);
         END IF;
       END IF;
    END IF;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'End of procedure '|| l_procedure_name;
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name||'.begin', l_log_msg);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','Party ID  = '|| x_party_id);
         FND_MSG_PUB.Add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       FND_MSG_PUB.Count_And_Get
         (p_count=>x_msg_count,
          p_data=>x_msg_data
         );
  END SYNC_Supplier;

  -- Procedure Sync Supplier Site
  PROCEDURE SYNC_Supplier_Sites
            (x_return_status    OUT     NOCOPY VARCHAR2,
             x_msg_count        OUT     NOCOPY NUMBER,
             x_msg_data         OUT     NOCOPY VARCHAR2,
             x_location_id      IN             NUMBER,
             x_party_site_id    IN             NUMBER,
	     x_vendor_site_id	IN	NUMBER DEFAULT NULL) IS -- bug 8723400

    -- Logging Infra:
    l_procedure_name             CONSTANT VARCHAR2(30) := 'SYNC_Supplier_Sites';
    l_log_msg                    FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

    --
    l_state                      ap_supplier_sites_all.state%type;
    l_province                   ap_supplier_sites_all.province%type;
    l_county                     ap_supplier_sites_all.county%type;
    l_tca_sync_city              ap_supplier_sites_all.tca_sync_city%type;
    l_tca_sync_zip               ap_supplier_sites_all.tca_sync_zip%type;
    l_tca_sync_country           ap_supplier_sites_all.tca_sync_country%type;
    l_city                       ap_supplier_sites_all.city%type;
    l_zip                        ap_supplier_sites_all.zip%type;
    l_country                    ap_supplier_sites_all.country%type;
    l_address_style              ap_supplier_sites_all.address_style%type;
    l_language                   ap_supplier_sites_all.language%type;
    l_address1                   ap_supplier_sites_all.address_line1%type;
    l_address2                   ap_supplier_sites_all.address_line2%type;
    l_address3                   ap_supplier_sites_all.address_line3%type;
    l_address4                   ap_supplier_sites_all.address_line4%type;
    l_address_line_alt           ap_supplier_sites_all.address_lines_alt%type;
    l_last_update_date           ap_supplier_sites_all.last_update_date%type; -- B# 7646333

    l_check_vendor_site_id       ap_supplier_sites_all.vendor_site_id%type;


    l_duns_number                ap_supplier_sites_all.duns_number%type;

  BEGIN

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Begin of procedure '|| l_procedure_name;
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                       l_procedure_name||'.begin', l_log_msg);
    END IF;

    -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Party Site ID '|| x_party_site_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                       '.'||l_procedure_name, l_log_msg);
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Location ID '|| x_location_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                       '.'||l_procedure_name, l_log_msg);
    END IF;

    IF x_location_id IS NOT NULL THEN

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Selecting Attributes for : '|| x_location_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                         '.'||l_procedure_name, l_log_msg);
       END IF;

       SELECT hl.state,
              hl.province,
              hl.county,
              hl.city,
              hl.postal_code,
              hl.country,
              substrb(hl.city,1,60), --6708281
              substrb(hl.postal_code,1,60), --6708281
              substrb(hl.country,1,60), --6708281
              hl.address_style,
              fl.nls_language,
              hl.address1,
              hl.address2,
              hl.address3,
              hl.address4,
              hl.address_lines_phonetic
              ,hl.last_update_date           -- B# 7646333
       INTO   l_state,
              l_province,
              l_county,
              l_tca_sync_city,
              l_tca_sync_zip,
              l_tca_sync_country,
              l_city,
              l_zip,
              l_country,
              l_address_style,
              l_language,
              l_address1,
              l_address2,
              l_address3,
              l_address4,
              l_address_line_alt
              ,l_last_update_date           -- B# 7646333
       FROM   hz_locations hl,
              fnd_languages fl
       WHERE  hl.language = fl.language_code (+)
       AND    hl.location_id = x_location_id;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Check atleast one Supplier Site exist for : '
                       || x_location_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                         '.'||l_procedure_name, l_log_msg);
       END IF;

       BEGIN
	-- bug 8723400 starts
	IF (x_vendor_site_id is not NULL) THEN
		SELECT vendor_site_id
		INTO   l_check_vendor_site_id
		FROM   ap_supplier_sites_all
		WHERE  location_id = x_location_id
		AND vendor_site_id = x_vendor_site_id
		AND    rownum = 1;
	ELSE
		SELECT vendor_site_id
		INTO   l_check_vendor_site_id
		FROM   ap_supplier_sites_all
		WHERE  location_id = x_location_id
		AND    rownum = 1;
	END IF;
	-- bug 8723400 ends
       EXCEPTION
         WHEN OTHERS THEN
           NULL;
       END;

       IF l_check_vendor_site_id IS NOT NULL THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'Update Supplier Sites Upgrade Cases: '
                         || x_location_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                           '.'||l_procedure_name, l_log_msg);
         END IF;

         --
         -- There are cases where some column lengths are longer in AP
         -- than in TCA. For the upgrade cases, in order to prevent the
         -- data loss, we will copy the values of these longer length AP
         -- column values to the corresponding TCA SYNC columns.
         -- We will do this only once so that the upgraded value is not lost.
         -- The columns at the site level that fall into this category are
         -- state, province and county.
         --

         UPDATE ap_supplier_sites_all
         SET    tca_sync_state = nvl(tca_sync_state,state),
                tca_sync_county = nvl(tca_sync_county,county),
                tca_sync_province = nvl(tca_sync_province,province)
         WHERE  location_id = x_location_id;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'Update Supplier Sites for : '|| x_location_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                           '.'||l_procedure_name, l_log_msg);
         END IF;

         UPDATE ap_supplier_sites_all
         SET    state             =         l_state,
                province          =         l_province,
                county            =         l_county,
                tca_sync_city     =         l_tca_sync_city,
                tca_sync_zip      =         l_tca_sync_zip,
                tca_sync_country  =         l_tca_sync_country,
                city              =         l_city,
                zip               =         l_zip,
                country           =         l_country,
                address_style     =         l_address_style,
                language          =         l_language,
                address_line1     =         l_address1,
                address_line2     =         l_address2,
                address_line3     =         l_address3,
                address_line4     =         l_address4,
                address_lines_alt  =         l_address_line_alt
         WHERE  location_id = x_location_id;

	 --bug 8723400 starts
	 IF (x_vendor_site_id is not NULL) THEN
		UPDATE ap_supplier_sites_all
		SET	last_update_date  =         SYSDATE             -- B# 7646333
			,LAST_UPDATED_BY   =         FND_GLOBAL.user_id  -- B# 7646333
			,last_update_login =         FND_GLOBAL.LOGIN_ID -- B# 7646333
		WHERE location_id = x_location_id
		AND vendor_site_id = l_check_vendor_site_id;
	 ELSE
		UPDATE ap_supplier_sites_all
		SET	last_update_date  =         SYSDATE             -- B# 7646333
			,LAST_UPDATED_BY   =         FND_GLOBAL.user_id  -- B# 7646333
			,last_update_login =         FND_GLOBAL.LOGIN_ID -- B# 7646333
		WHERE location_id = x_location_id;
	 END IF;
	 --bug 8723400 ends

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'After Update of Site Attributes for : '
                         || x_location_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                           '.'||l_procedure_name, l_log_msg);
         END IF;
      END IF;
    END IF;

    -- Desicon form the PM team states that
    -- duns number is an attribute that needs to
    -- be stored at the supplier site and not at
    -- the aprty site level.

    -- Hence the update and the insert supplier
    -- site API's would take care to insert the
    -- duns number directly into the table
    -- ap_supplier_sites_sites instead of having
    -- it sync up from the TCA data

    -- Commenting out the code below thus.
    -- Bug 6388041

    /*
    IF x_party_site_id IS NOT NULL THEN

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Selecting Attributes for : '|| x_party_site_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                         '.'||l_procedure_name, l_log_msg);
       END IF;

       SELECT duns_number_c
       INTO   l_duns_number
       FROM   hz_party_sites
       WHERE  party_site_id = x_party_site_id;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'Update Supplier Sites for : '|| x_party_site_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                         '.'||l_procedure_name, l_log_msg);
       END IF;

       UPDATE ap_supplier_sites_all
       SET    duns_number       =         l_duns_number
       WHERE  party_site_id     =         x_party_site_id
       AND EXISTS (SELECT 'Site Exists'
                   FROM   ap_supplier_sites_all a
                   WHERE  a.party_site_id = x_party_site_id);

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'After Update of Site Attributes for : '|| x_party_site_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||
                         '.'||l_procedure_name, l_log_msg);
       END IF;

    END IF;
    */

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'End of procedure '|| l_procedure_name;
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name||'.begin', l_log_msg);
    END IF;

  EXCEPTION

     WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','Party Site ID  = '|| x_party_site_id);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','Location ID  = '|| x_location_id);
         FND_MSG_PUB.Add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       FND_MSG_PUB.Count_And_Get
         (p_count=>x_msg_count,
          p_data=>x_msg_data
         );

  END SYNC_Supplier_Sites;

END AP_TCA_SUPPLIER_SYNC_PKG;

/
