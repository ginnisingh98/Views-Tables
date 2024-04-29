--------------------------------------------------------
--  DDL for Package Body ECE_TRADING_PARTNERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_TRADING_PARTNERS_PUB" AS
-- $Header: ECVNWTPB.pls 120.7.12010000.2 2008/09/04 12:22:58 hgandiko ship $

   PROCEDURE ece_get_address_wrapper(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := FND_API.G_FALSE,
      p_simulate                 IN    VARCHAR2 := FND_API.G_FALSE,
      p_commit                   IN    VARCHAR2 := FND_API.G_FALSE,
      p_validation_level         IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status            OUT NOCOPY   VARCHAR2,
      x_msg_count                OUT NOCOPY   NUMBER,
      x_msg_data                 OUT NOCOPY   VARCHAR2,
      x_status_code              OUT NOCOPY   NUMBER,
      p_address_type             IN    NUMBER,
      p_transaction_type         IN    VARCHAR2,
      p_org_id_in                IN    NUMBER   DEFAULT NULL,
      p_address_id_in            IN    NUMBER   DEFAULT NULL,
      p_tp_location_code_in      IN    VARCHAR2 DEFAULT NULL,
      p_translator_code_in       IN    VARCHAR2 DEFAULT NULL,
      p_tp_location_name_in      IN    VARCHAR2 DEFAULT NULL,
      p_address_line1_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line2_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line3_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line4_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line_alt_in      IN    VARCHAR2 DEFAULT NULL,
      p_city_in                  IN    VARCHAR2 DEFAULT NULL,
      p_county_in                IN    VARCHAR2 DEFAULT NULL,
      p_state_in                 IN    VARCHAR2 DEFAULT NULL,
      p_zip_in                   IN    VARCHAR2 DEFAULT NULL,
      p_province_in              IN    VARCHAR2 DEFAULT NULL,
      p_country_in               IN    VARCHAR2 DEFAULT NULL,
      p_region_1_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_2_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_3_in              IN    VARCHAR2 DEFAULT NULL,
      x_entity_id_out            OUT NOCOPY   NUMBER,
      x_org_id_out               OUT NOCOPY   NUMBER,
      x_address_id_out           OUT NOCOPY   NUMBER,
      x_tp_location_code_out     OUT NOCOPY   VARCHAR2,
      x_translator_code_out      OUT NOCOPY   VARCHAR2,
      x_tp_location_name_out     OUT NOCOPY   VARCHAR2,
      x_address_line1_out        OUT NOCOPY   VARCHAR2,
      x_address_line2_out        OUT NOCOPY   VARCHAR2,
      x_address_line3_out        OUT NOCOPY   VARCHAR2,
      x_address_line4_out        OUT NOCOPY   VARCHAR2,
      x_address_line_alt_out     OUT NOCOPY   VARCHAR2,
      x_city_out                 OUT NOCOPY   VARCHAR2,
      x_county_out               OUT NOCOPY   VARCHAR2,
      x_state_out                OUT NOCOPY   VARCHAR2,
      x_zip_out                  OUT NOCOPY   VARCHAR2,
      x_province_out             OUT NOCOPY   VARCHAR2,
      x_country_out              OUT NOCOPY   VARCHAR2,
      x_region_1_out             OUT NOCOPY   VARCHAR2,
      x_region_2_out             OUT NOCOPY   VARCHAR2,
      x_region_3_out             OUT NOCOPY   VARCHAR2) IS

      v_precedence_code          VARCHAR2(240);
      v_profile_name             VARCHAR2(80);

      BEGIN
         v_profile_name := 'ECE_' || NVL(scrub(p_transaction_type),'') || '_ADDRESS_PRECEDENCE';
         fnd_profile.get(v_profile_name,v_precedence_code);

         ece_get_address(
            p_api_version_number,
            p_init_msg_list,
            p_simulate,
            p_commit,
            p_validation_level,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_status_code,
            NVL(v_precedence_code,'0'),
            p_address_type,
            p_transaction_type,
            p_org_id_in,
            p_address_id_in,
            p_tp_location_code_in,
            p_translator_code_in,
            p_tp_location_name_in,
            p_address_line1_in,
            p_address_line2_in,
            p_address_line3_in,
            p_address_line4_in,
            p_address_line_alt_in,
            p_city_in,
            p_county_in,
            p_state_in,
            p_zip_in,
            p_province_in,
            p_country_in,
            p_region_1_in,
            p_region_2_in,
            p_region_3_in,
            x_org_id_out,
            x_address_id_out,
            x_tp_location_code_out,
            x_translator_code_out,
            x_tp_location_name_out,
            x_address_line1_out,
            x_address_line2_out,
            x_address_line3_out,
            x_address_line4_out,
            x_address_line_alt_out,
            x_city_out,
            x_county_out,
            x_state_out,
            x_zip_out,
            x_province_out,
            x_country_out,
            x_region_1_out,
            x_region_2_out,
            x_region_3_out);

         -- If the address type is CUSTOMER or SUPPLIER and the ADDRESS ID is available,
         -- then derive the CUSTOMER OR SUPPLIER's ID.
	 -- Bug 2570369. This is a fix for the bug 2641276 which is resolved by populating
	 --		 x_translator_code_out with customer account_number.
         IF x_address_id_out IS NOT NULL THEN
           IF p_address_type = G_CUSTOMER THEN
               SELECT   cas.cust_account_id,pt.party_name,  --Bug 2722334
			ca.account_number
               INTO     x_entity_id_out,x_tp_location_name_out,
			x_translator_code_out
               FROM     hz_cust_acct_sites_all cas,
                        hz_cust_accounts ca,
                        hz_parties     pt
               WHERE    cas.cust_acct_site_id = x_address_id_out
               AND      cas.cust_account_id   = ca.cust_account_id
               AND      ca.party_id           = pt.party_id;
            ELSIF p_address_type = G_SUPPLIER THEN
               SELECT   pvs.vendor_id,pv.vendor_name
               INTO     x_entity_id_out,x_tp_location_name_out
               FROM     po_vendor_sites_all pvs,
			po_vendors pv
               WHERE    pvs.vendor_site_id = x_address_id_out AND
			pvs.vendor_id      = pv.vendor_id     AND
                        ROWNUM             = 1;
            ELSE
               x_entity_id_out := NULL;
            END IF;
         END IF;

      END ece_get_address_wrapper;

   PROCEDURE ece_get_address(
      p_api_version_number       IN    NUMBER,
      p_init_msg_list            IN    VARCHAR2 := FND_API.G_FALSE,
      p_simulate                 IN    VARCHAR2 := FND_API.G_FALSE,
      p_commit                   IN    VARCHAR2 := FND_API.G_FALSE,
      p_validation_level         IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status            OUT NOCOPY   VARCHAR2,
      x_msg_count                OUT NOCOPY   NUMBER,
      x_msg_data                 OUT NOCOPY   VARCHAR2,
      x_status_code              OUT NOCOPY   NUMBER,
      p_precedence_code          IN    VARCHAR2,
      p_address_type             IN    NUMBER,
      p_transaction_type         IN    VARCHAR2,
      p_org_id_in                IN    NUMBER DEFAULT NULL,
      p_address_id_in            IN    NUMBER DEFAULT NULL,
      p_tp_location_code_in      IN    VARCHAR2 DEFAULT NULL,
      p_translator_code_in       IN    VARCHAR2 DEFAULT NULL,
      p_tp_location_name_in      IN    VARCHAR2 DEFAULT NULL,
      p_address_line1_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line2_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line3_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line4_in         IN    VARCHAR2 DEFAULT NULL,
      p_address_line_alt_in      IN    VARCHAR2 DEFAULT NULL,
      p_city_in                  IN    VARCHAR2 DEFAULT NULL,
      p_county_in                IN    VARCHAR2 DEFAULT NULL,
      p_state_in                 IN    VARCHAR2 DEFAULT NULL,
      p_zip_in                   IN    VARCHAR2 DEFAULT NULL,
      p_province_in              IN    VARCHAR2 DEFAULT NULL,
      p_country_in               IN    VARCHAR2 DEFAULT NULL,
      p_region_1_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_2_in              IN    VARCHAR2 DEFAULT NULL,
      p_region_3_in              IN    VARCHAR2 DEFAULT NULL,
      x_org_id_out               OUT NOCOPY   NUMBER,
      x_address_id_out           OUT NOCOPY   NUMBER,
      x_tp_location_code_out     OUT NOCOPY   VARCHAR2,
      x_translator_code_out      OUT NOCOPY   VARCHAR2,
      x_tp_location_name_out     OUT NOCOPY   VARCHAR2,
      x_address_line1_out        OUT NOCOPY   VARCHAR2,
      x_address_line2_out        OUT NOCOPY   VARCHAR2,
      x_address_line3_out        OUT NOCOPY   VARCHAR2,
      x_address_line4_out        OUT NOCOPY   VARCHAR2,
      x_address_line_alt_out     OUT NOCOPY   VARCHAR2,
      x_city_out                 OUT NOCOPY   VARCHAR2,
      x_county_out               OUT NOCOPY   VARCHAR2,
      x_state_out                OUT NOCOPY   VARCHAR2,
      x_zip_out                  OUT NOCOPY   VARCHAR2,
      x_province_out             OUT NOCOPY   VARCHAR2,
      x_country_out              OUT NOCOPY   VARCHAR2,
      x_region_1_out             OUT NOCOPY   VARCHAR2,
      x_region_2_out             OUT NOCOPY   VARCHAR2,
      x_region_3_out             OUT NOCOPY   VARCHAR2) IS

      b_use_addr_comp            BOOLEAN                 := FALSE;
      b_use_addr_id              BOOLEAN                 := FALSE;
      b_use_lctc                 BOOLEAN                 := FALSE;
      b_use_loc_name             BOOLEAN                 := FALSE;
      b_use_org_id               BOOLEAN                 := FALSE;

      xProgress                  VARCHAR2(80);

      l_api_name                 CONSTANT VARCHAR2(30)   := 'ece_get_address';
      l_api_version_number       CONSTANT NUMBER         :=  1.0;
      l_return_status            VARCHAR2(10);

      n_loop_count               NUMBER                  :=  0;
      n_match_count              NUMBER                  :=  0;

      n_org_id                   NUMBER;
      n_address_id               NUMBER;
      v_pcode                    VARCHAR2(3);
      v_tp_location_code         VARCHAR2(32000);
      v_translator_code          VARCHAR2(32000);
      v_tp_location_name         VARCHAR2(32000);
      v_address_line1            VARCHAR2(32000);
      v_address_line2            VARCHAR2(32000);
      v_address_line3            VARCHAR2(32000);
      v_address_line4            VARCHAR2(32000);
      v_address_line_alt         VARCHAR2(32000);
      v_city                     VARCHAR2(32000);
      v_county                   VARCHAR2(32000);
      v_state                    VARCHAR2(32000);
      v_zip                      VARCHAR2(32000);
      v_province                 VARCHAR2(32000);
      v_country                  VARCHAR2(32000);
      v_region_1                 VARCHAR2(32000);
      v_region_2                 VARCHAR2(32000);
      v_region_3                 VARCHAR2(32000);

      /*********************************************************************
      | Cursor Declarations                                                |
      | Bug 2151462: Address derivation Cursors will now check for         |
      |              location code,address and postal_code.                |
      *********************************************************************/
      -- Bank Branches Cursor Bug 2551002
      -- Bug 2422787 apb.bank_branch_id    = NVL(cp_address_id_in,apb.bank_branch_id) AND
      CURSOR c1_bank_branches(cp_transaction_type      VARCHAR2,
                             cp_org_id_in             NUMBER DEFAULT NULL,
                             cp_address_id_in         NUMBER DEFAULT NULL,
                             cp_tp_location_code_in   VARCHAR2 DEFAULT NULL,
                             cp_address_line1_in      VARCHAR2 DEFAULT NULL,
                             cp_address_line2_in      VARCHAR2 DEFAULT NULL,
                             cp_address_line3_in      VARCHAR2 DEFAULT NULL,
                             cp_address_line4_in      VARCHAR2 DEFAULT NULL,
                             cp_address_line_alt_in   VARCHAR2 DEFAULT NULL,
                             cp_city_in               VARCHAR2 DEFAULT NULL,
                             cp_county_in             VARCHAR2 DEFAULT NULL,
                             cp_state_in              VARCHAR2 DEFAULT NULL,
                             cp_zip_in                VARCHAR2 DEFAULT NULL,
                             cp_province_in           VARCHAR2 DEFAULT NULL,
                             cp_country_in            VARCHAR2 DEFAULT NULL,
                             cp_region_1_in           VARCHAR2 DEFAULT NULL) IS
         SELECT   TO_NUMBER(NULL)            org_id,
                  cbb.branch_party_id         address_id,
                  hcp.edi_ece_tp_location_code tp_location_code,
                  cbb.bank_branch_name       tp_location_name,
                  cbb.address_line1          address_line1,
                  cbb.address_line2          address_line2,
                  cbb.address_line3          address_line3,
                  cbb.address_line4          address_line4,
                  hzl.address_lines_phonetic      address_line_alt,
                  cbb.city                   city,
                  hzl.county                 county,
                  cbb.state                  state,
                  cbb.zip                    zip,
                  cbb.province               province,
                  cbb.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     ce_bank_branches_v           cbb,
                  hz_contact_points            hcp,
                  hz_locations                 hzl,
                  hz_party_sites               hps
         WHERE    NVL(UPPER(hcp.edi_ece_tp_location_code),' ')   LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  NVL(UPPER(cbb.address_line1),' ')          LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(cbb.address_line2),' ')          LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(cbb.address_line3),' ')          LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(cbb.address_line4),' ')          LIKE NVL(UPPER(cp_address_line4_in),'%') AND
                  NVL(UPPER(hzl.address_lines_phonetic),' ')      LIKE NVL(UPPER(cp_address_line_alt_in),'%') AND
                  NVL(UPPER(cbb.city),' ')                   LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(cbb.zip),' ')                    LIKE NVL(UPPER(cp_zip_in),'%') AND
                  hcp.owner_table_id  = cbb.branch_party_id  AND
                  hcp.owner_table_name = 'HZ_PARTIES' AND
                  hcp.contact_point_type     = 'EDI' AND
                  hps.party_id = cbb.branch_party_id AND
                  hps.identifying_address_flag = 'Y' AND
                  hzl.location_id = hps.party_id;

      -- Bug 3351412
      CURSOR c2_bank_branches(cp_transaction_type       VARCHAR2,
			      cp_org_id_in              NUMBER DEFAULT NULL,
                              cp_tp_location_code_in    VARCHAR2 DEFAULT NULL,
                              cp_tp_translator_code     VARCHAR2 DEFAULT NULL) IS
         SELECT   TO_NUMBER(NULL)            org_id,
                  cbb.branch_party_id         address_id,
                  hcp.edi_ece_tp_location_code   tp_location_code,
                  cbb.bank_branch_name       tp_location_name,
                  cbb.address_line1          address_line1,
                  cbb.address_line2          address_line2,
                  cbb.address_line3          address_line3,
                  cbb.address_line4          address_line4,
                  hzl.address_lines_phonetic     address_line_alt,
                  cbb.city                   city,
                  hzl.county                 county,
                  cbb.state                  state,
                  cbb.zip                    zip,
                  cbb.province               province,
                  cbb.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     ce_bank_branches_v         cbb,
		  ece_tp_details 	     etd,
                  hz_contact_points          hcp,
                  hz_locations               hzl,
                  hz_party_sites             hps
         WHERE    NVL(UPPER(hcp.edi_ece_tp_location_code),' ')   LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  hcp.edi_tp_header_id			     =    etd.tp_header_id	       AND
		  etd.document_id 			     =    UPPER(cp_transaction_type)   AND
                  NVL(UPPER(etd.translator_code),' ')        LIKE NVL(UPPER(cp_tp_translator_code),'%')  AND
                 hcp.owner_table_id = cbb.branch_party_id AND
                 hcp.owner_table_name = 'HZ_PARTIES' AND
                 hcp.contact_point_type    = 'EDI' AND
                 hps.party_id = cbb.branch_party_id AND
                 hps.identifying_address_flag = 'Y' AND
                 hzl.location_id = hps.party_id;

      -- Internal Locations Cursor Bug 2551002
      --  Bug 2570369 Split the c_locations cursor in two. Scan the 2nd
      --	      cursor if the 1st cursor returns no record.
      -- hrl.org_id                       LIKE NVL(cp_org_id_in,'%') AND
      --Bug 2422787        hrl.location_id   = NVL(cp_address_id_in,hrl.location_id) AND
      CURSOR c_locations_1(cp_transaction_type    VARCHAR2,
                         cp_org_id_in           NUMBER DEFAULT NULL,
                         cp_address_id_in       NUMBER DEFAULT NULL,
                         cp_tp_location_code_in VARCHAR2 DEFAULT NULL,
                         cp_address_line1_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line2_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line3_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line4_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line_alt_in VARCHAR2 DEFAULT NULL,
                         cp_city_in             VARCHAR2 DEFAULT NULL,
                         cp_county_in           VARCHAR2 DEFAULT NULL,
                         cp_state_in            VARCHAR2 DEFAULT NULL,
                         cp_zip_in              VARCHAR2 DEFAULT NULL,
                         cp_province_in         VARCHAR2 DEFAULT NULL,
                         cp_country_in          VARCHAR2 DEFAULT NULL,
                         cp_region_1_in         VARCHAR2 DEFAULT NULL) IS
         SELECT   TO_NUMBER(NULL)            org_id,
                  hrl.location_id            address_id,
                  hrl.ece_tp_location_code   tp_location_code,
                  hrl.location_code          tp_location_name,
                  hrl.address_line_1         address_line1,
                  hrl.address_line_2         address_line2,
                  hrl.address_line_3         address_line3,
                  TO_CHAR(NULL)              address_line4,
                  TO_CHAR(NULL)              address_line_alt,
                  hrl.town_or_city           city,
                  TO_CHAR(NULL)              county,
                  TO_CHAR(NULL)              state,
                  hrl.postal_code            zip,
                  TO_CHAR(NULL)              province,
                  hrl.country                country,
                  hrl.region_1               region_1,
                  hrl.region_2               region_2,
                  hrl.region_3               region_3,
		  TO_CHAR(hrl.inventory_organization_id)   inv_organization_id	--Bug 2570369
         FROM     hr_locations_all           hrl,
                  hr_locations_all_tl        hrlt
         WHERE    NVL(UPPER(hrl.ece_tp_location_code),' ')   LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  NVL(UPPER(hrl.address_line_1),' ')         LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(hrl.address_line_2),' ')         LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(hrl.address_line_3),' ')         LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(hrl.town_or_city),' ')           LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(hrl.postal_code),' ')            LIKE NVL(UPPER(cp_zip_in),'%') AND
                  hrl.location_id                     =  hrlt.location_id     AND
                  hrlt.language                       =  userenv('LANG')   AND
                  nvl(hrl.business_group_id, nvl(hr_general.get_business_group_id,-99)) =
                                                         nvl(hr_general.get_business_group_id,-99);

      -- Internal Locations Cursor 2 Bug 2570369
      CURSOR c_locations_2(cp_transaction_type    VARCHAR2,
                         cp_org_id_in           NUMBER DEFAULT NULL,
                         cp_address_id_in       NUMBER DEFAULT NULL,
                         cp_tp_location_code_in VARCHAR2 DEFAULT NULL,
                         cp_address_line1_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line2_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line3_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line4_in    VARCHAR2 DEFAULT NULL,
                         cp_address_line_alt_in VARCHAR2 DEFAULT NULL,
                         cp_city_in             VARCHAR2 DEFAULT NULL,
                         cp_county_in           VARCHAR2 DEFAULT NULL,
                         cp_state_in            VARCHAR2 DEFAULT NULL,
                         cp_zip_in              VARCHAR2 DEFAULT NULL,
                         cp_province_in         VARCHAR2 DEFAULT NULL,
                         cp_country_in          VARCHAR2 DEFAULT NULL,
                         cp_region_1_in         VARCHAR2 DEFAULT NULL) IS
         SELECT   TO_NUMBER(NULL)            org_id,
                  hrl.location_id            address_id,
                  TO_CHAR(NULL)              tp_location_code,
                  TO_CHAR(NULL)              tp_location_name,
                  hrl.address1               address_line1,
                  hrl.address2               address_line2,
                  hrl.address3               address_line3,
                  hrl.address4               address_line4,
                  TO_CHAR(NULL)              address_line_alt,
                  hrl.city                   city,
                  hrl.county                 county,
                  hrl.state                  state,
                  hrl.postal_code            zip,
                  hrl.province               province,
                  hrl.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     hz_locations               hrl
         WHERE    NVL(UPPER(hrl.address1),' ')               LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(hrl.address2),' ')               LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(hrl.address3),' ')               LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(hrl.city),' ')     	             LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(hrl.postal_code),' ')            LIKE NVL(UPPER(cp_zip_in),'%');

      /*  Bug 2551002
                  cas.party_site_id                   =    pts.party_site_id   AND
                  pts.location_id                     =    hrl.location_id;
                  hz_cust_acct_sites_all     cas ,
                  hz_party_sites             pts
         WHERE    nvl(cas.org_id,-99)                 = NVL(cp_org_id_in,nvl(cas.org_id,-99)) AND
	 Bug2422787
    		  hrl.location_id                     = NVL(UPPER(cp_address_id_in,hrl.location_id) AND
                  NVL(UPPER(cas.ece_tp_location_code),' ')   LIKE NVL(UPPER(cp_tp_location_code_in),'%')
                  AND
      */

      --Bug 2422787     pvs.vendor_site_id= NVL(cp_address_id_in,pvs.vendor_site_id) AND
      -- PO Vendors Cursor Bug 2551002
      CURSOR c1_vendor_sites(cp_transaction_type    VARCHAR2,
                            cp_org_id_in           NUMBER DEFAULT NULL,
                            cp_address_id_in       NUMBER DEFAULT NULL,
                            cp_tp_location_code_in VARCHAR2 DEFAULT NULL,
                            cp_address_line1_in    VARCHAR2 DEFAULT NULL,
                            cp_address_line2_in    VARCHAR2 DEFAULT NULL,
                            cp_address_line3_in    VARCHAR2 DEFAULT NULL,
                            cp_address_line4_in    VARCHAR2 DEFAULT NULL,
                            cp_address_line_alt_in VARCHAR2 DEFAULT NULL,
                            cp_city_in             VARCHAR2 DEFAULT NULL,
                            cp_county_in           VARCHAR2 DEFAULT NULL,
                            cp_state_in            VARCHAR2 DEFAULT NULL,
                            cp_zip_in              VARCHAR2 DEFAULT NULL,
                            cp_province_in         VARCHAR2 DEFAULT NULL,
                            cp_region_1_in         VARCHAR2 DEFAULT NULL) IS
         SELECT   pvs.org_id                 org_id,
                  pvs.vendor_site_id         address_id,
                  pvs.ece_tp_location_code   tp_location_code,
                  TO_CHAR(NULL)    	     tp_location_name,
                  pvs.address_line1          address_line1,
                  pvs.address_line2          address_line2,
                  pvs.address_line3          address_line3,
                  pvs.address_line4          address_line4,
                  pvs.address_lines_alt      address_line_alt,
                  pvs.city                   city,
                  pvs.county                 county,
                  pvs.state                  state,
                  pvs.zip                    zip,
                  pvs.province               province,
                  pvs.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     po_vendor_sites_all        pvs
         WHERE    nvl(pvs.org_id,-99)                 = NVL(cp_org_id_in,nvl(pvs.org_id,-99)) AND
                  NVL(UPPER(pvs.ece_tp_location_code),' ')   LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  NVL(UPPER(pvs.address_line1),' ')          LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(pvs.address_line2),' ')          LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(pvs.address_line3),' ')          LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(pvs.address_line4),' ')          LIKE NVL(UPPER(cp_address_line4_in),'%') AND
                  NVL(UPPER(pvs.address_lines_alt),' ')      LIKE NVL(UPPER(cp_address_line_alt_in),'%') AND
                  NVL(UPPER(pvs.city),' ')                   LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(pvs.zip),' ')                    LIKE NVL(UPPER(cp_zip_in),'%') ;

      -- Bug 3351412
      CURSOR c2_vendor_sites(cp_transaction_type     VARCHAR2,
                            cp_org_id_in             NUMBER DEFAULT NULL,
                            cp_tp_location_code_in   VARCHAR2 DEFAULT NULL,
                            cp_tp_translator_code    VARCHAR2 DEFAULT NULL) IS
         SELECT   pvs.org_id                 org_id,
                  pvs.vendor_site_id         address_id,
                  pvs.ece_tp_location_code   tp_location_code,
                  TO_CHAR(NULL)    	     tp_location_name,
                  pvs.address_line1          address_line1,
                  pvs.address_line2          address_line2,
                  pvs.address_line3          address_line3,
                  pvs.address_line4          address_line4,
                  pvs.address_lines_alt      address_line_alt,
                  pvs.city                   city,
                  pvs.county                 county,
                  pvs.state                  state,
                  pvs.zip                    zip,
                  pvs.province               province,
                  pvs.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     po_vendor_sites_all        pvs,
		  ece_tp_details 	     etd
         WHERE    nvl(pvs.org_id,-99)                        =    NVL(cp_org_id_in,nvl(pvs.org_id,-99)) AND
                  NVL(UPPER(pvs.ece_tp_location_code),' ')   LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  pvs.tp_header_id			     =    etd.tp_header_id  AND
                  NVL(UPPER(etd.translator_code),' ')        LIKE NVL(UPPER(cp_tp_translator_code),'%') AND
                  etd.document_id                            LIKE UPPER(cp_transaction_type);

      -- Ra Addresses Cursor Bug 2551002
      -- Ra Addresses Cursor Bug 2551002
      CURSOR c_ra_address(cp_transaction_type      VARCHAR2,
                          cp_org_id_in             NUMBER DEFAULT NULL,
                          cp_address_id_in         NUMBER DEFAULT NULL,
                          cp_tp_location_code_in   VARCHAR2 DEFAULT NULL,
                          cp_address_line1_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line2_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line3_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line4_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line_alt_in   VARCHAR2 DEFAULT NULL,
                          cp_city_in               VARCHAR2 DEFAULT NULL,
                          cp_county_in             VARCHAR2 DEFAULT NULL,
                          cp_state_in              VARCHAR2 DEFAULT NULL,
                          cp_zip_in                VARCHAR2 DEFAULT NULL,
                          cp_province_in           VARCHAR2 DEFAULT NULL,
                          cp_region_1_in           VARCHAR2 DEFAULT NULL) IS
         SELECT   cas.org_id                 org_id,
                  cas.cust_acct_site_id      address_id,
                  cas.ece_tp_location_code   tp_location_code,
                  TO_CHAR(NULL)              tp_location_name,
                  loc.address1               address_line1,
                  loc.address2               address_line2,
                  loc.address3               address_line3,
                  loc.address4               address_line4,
                  loc.address_lines_phonetic address_line_alt,
                  loc.city                   city,
                  loc.county                 county,
                  loc.state                  state,
                  loc.postal_code            zip,
                  loc.province               province,
                  loc.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     hz_cust_acct_sites_all     cas,
                  hz_party_sites             pts,
                  hz_locations               loc
         WHERE    nvl(cas.org_id,-99)                    = NVL(cp_org_id_in,nvl(cas.org_id,-99)) AND
         --       cas.cust_acct_site_id                  = NVL(cp_address_id_in,cas.cust_acct_site_id) AND
                  NVL(UPPER(cas.ece_tp_location_code),' ')      LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  NVL(UPPER(loc.address1),' ')                  LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(loc.address2),' ')                  LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(loc.address3),' ')                  LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(loc.address4),' ')                  LIKE NVL(UPPER(cp_address_line4_in),'%') AND
                  NVL(UPPER(loc.address_lines_phonetic),' ')    LIKE NVL(UPPER(cp_address_line_alt_in),'%') AND
                  NVL(UPPER(loc.city),' ')                      LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(loc.postal_code),' ')               LIKE NVL(UPPER(cp_zip_in),'%') AND
                  cas.party_site_id                      =  pts.party_site_id  AND
                  pts.location_id                        =  loc.location_id;


      -- Ra Addresses Cursor 2 Bug 2551002
      -- The above SQL is split into 2 to improve the POI/POCI performance(bug 2340691).
      CURSOR c2_ra_address( cp_org_id_in             NUMBER DEFAULT NULL,
                            cp_tp_location_code_in   VARCHAR2 DEFAULT NULL
                           ) IS
         SELECT   cas.org_id                 org_id,
                  cas.cust_acct_site_id      address_id,
                  cas.ece_tp_location_code   tp_location_code,
                  cas.party_site_id          party_site_id
         FROM     hz_cust_acct_sites_all     cas
         WHERE    nvl(cas.org_id,-99)                    = NVL(cp_org_id_in,nvl(cas.org_id,-99)) AND
                  NVL(UPPER(cas.ece_tp_location_code),' ')      LIKE NVL(UPPER(cp_tp_location_code_in),'%') ;

      -- Bug 2708573
      CURSOR c3_ra_address(cp_transaction_type      VARCHAR2,
                          cp_address_line1_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line2_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line3_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line4_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line_alt_in   VARCHAR2 DEFAULT NULL,
                          cp_city_in               VARCHAR2 DEFAULT NULL,
                          cp_county_in             VARCHAR2 DEFAULT NULL,
                          cp_state_in              VARCHAR2 DEFAULT NULL,
                          cp_zip_in                VARCHAR2 DEFAULT NULL,
                          cp_province_in           VARCHAR2 DEFAULT NULL,
                          cp_region_1_in           VARCHAR2 DEFAULT NULL) IS
         SELECT   loc.location_id            location_id,
                  TO_CHAR(NULL)              tp_location_name,
                  loc.address1               address_line1,
                  loc.address2               address_line2,
                  loc.address3               address_line3,
                  loc.address4               address_line4,
                  loc.address_lines_phonetic address_line_alt,
                  loc.city                   city,
                  loc.county                 county,
                  loc.state                  state,
                  loc.postal_code            zip,
                  loc.province               province,
                  loc.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     hz_locations               loc
         WHERE    NVL(UPPER(loc.address1),' ')                  LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(loc.address2),' ')                  LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(loc.address3),' ')                  LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(loc.address4),' ')                  LIKE NVL(UPPER(cp_address_line4_in),'%') AND
                  NVL(UPPER(loc.address_lines_phonetic),' ')    LIKE NVL(UPPER(cp_address_line_alt_in),'%') AND
                  NVL(UPPER(loc.city),' ')                      LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(loc.postal_code),' ')               LIKE NVL(UPPER(cp_zip_in),'%') ;

      -- bug3351412
      CURSOR c4_ra_address(cp_transaction_type       VARCHAR2,
                            cp_org_id_in             NUMBER DEFAULT NULL,
                            cp_tp_location_code_in   VARCHAR2 DEFAULT NULL,
                            cp_tp_translator_code    VARCHAR2 DEFAULT NULL
                           ) IS
         SELECT   cas.org_id                 org_id,
                  cas.cust_acct_site_id      address_id,
                  cas.ece_tp_location_code   tp_location_code,
                  cas.party_site_id          party_site_id
         FROM     hz_cust_acct_sites_all     cas,
                  ece_tp_details             etd
         WHERE    nvl(cas.org_id,-99)                      =    NVL(cp_org_id_in,nvl(cas.org_id,-99)) AND
                  NVL(UPPER(cas.ece_tp_location_code),' ') LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  cas.tp_header_id                         =    etd.tp_header_id AND
                  NVL(UPPER(etd.translator_code),' ')      LIKE NVL(UPPER(cp_tp_translator_code),'%') AND
                  etd.document_id                          =    UPPER(cp_transaction_type);


		  CURSOR c5_ra_address(cp_transaction_type      VARCHAR2,
                          cp_org_id_in             NUMBER DEFAULT NULL,
                          cp_address_id_in         NUMBER DEFAULT NULL,
                          cp_tp_location_code_in   VARCHAR2 DEFAULT NULL,
                          cp_address_line1_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line2_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line3_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line4_in      VARCHAR2 DEFAULT NULL,
                          cp_address_line_alt_in   VARCHAR2 DEFAULT NULL,
                          cp_city_in               VARCHAR2 DEFAULT NULL,
                          cp_county_in             VARCHAR2 DEFAULT NULL,
                          cp_state_in              VARCHAR2 DEFAULT NULL,
                          cp_zip_in                VARCHAR2 DEFAULT NULL,
                          cp_province_in           VARCHAR2 DEFAULT NULL,
                          cp_region_1_in           VARCHAR2 DEFAULT NULL,
			  cp_customer_name_in      VARCHAR2 DEFAULT NULL,
			  cp_customer_number_in    VARCHAR2 DEFAULT NULL
			  ) IS
        SELECT           cas.org_id                 org_id,
                  cas.cust_acct_site_id      address_id,
                  cas.ece_tp_location_code   tp_location_code,
                  TO_CHAR(NULL)              tp_location_name,
                  loc.address1               address_line1,
                  loc.address2               address_line2,
                  loc.address3               address_line3,
                  loc.address4               address_line4,
                  loc.address_lines_phonetic address_line_alt,
                  loc.city                   city,
                  loc.county                 county,
                  loc.state                  state,
                  loc.postal_code            zip,
                  loc.province               province,
                  loc.country                country,
                  TO_CHAR(NULL)              region_1,
                  TO_CHAR(NULL)              region_2,
                  TO_CHAR(NULL)              region_3
         FROM     hz_cust_acct_sites_all     cas,
                  hz_party_sites             pts,
                  hz_locations               loc,
                  hz_cust_accounts ca,
                  hz_parties     pt
         WHERE    nvl(cas.org_id,-99)                    = NVL(cp_org_id_in,nvl(cas.org_id,-99)) AND
         --       cas.cust_acct_site_id                  = NVL(cp_address_id_in,cas.cust_acct_site_id) AND
                  NVL(UPPER(cas.ece_tp_location_code),' ')      LIKE NVL(UPPER(cp_tp_location_code_in),'%') AND
                  NVL(UPPER(loc.address1),' ')                  LIKE NVL(UPPER(cp_address_line1_in),'%') AND
                  NVL(UPPER(loc.address2),' ')                  LIKE NVL(UPPER(cp_address_line2_in),'%') AND
                  NVL(UPPER(loc.address3),' ')                  LIKE NVL(UPPER(cp_address_line3_in),'%') AND
                  NVL(UPPER(loc.address4),' ')                  LIKE NVL(UPPER(cp_address_line4_in),'%') AND
                  NVL(UPPER(loc.address_lines_phonetic),' ')    LIKE NVL(UPPER(cp_address_line_alt_in),'%') AND
                  NVL(UPPER(loc.city),' ')                      LIKE NVL(UPPER(cp_city_in),'%') AND
                  NVL(UPPER(loc.postal_code),' ')               LIKE NVL(UPPER(cp_zip_in),'%') AND
                  NVL(UPPER(pt.party_name),' ')                 LIKE NVL(UPPER(cp_customer_name_in),'%') AND
                  NVL(UPPER(ca.account_number),' ')             LIKE NVL(UPPER(cp_customer_number_in),'%') AND
                  cas.party_site_id                      =  pts.party_site_id  AND
                  pts.location_id                        =  loc.location_id AND
                  cas.cust_account_id                    =  ca.cust_account_id AND
                  ca.party_id                            =  pt.party_id;

      BEGIN
         /*********************************************************************
         | API Related Housekeeping Code                                      |
         *********************************************************************/
         -- Standard Start of API savepoint
         xProgress := 'ADDRB-20-1000';
         SAVEPOINT ece_get_address;

         -- Standard call to check for call compatibility.
         IF NOT fnd_api.compatible_api_call(l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME) THEN
            RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF fnd_api.to_boolean(p_init_msg_list) THEN
            fnd_msg_pub.initialize;
         END IF;

         -- Initialize API return status to success
         x_return_status := fnd_api.G_RET_STS_SUCCESS;

         /*********************************************************************
         | Internal Housekeeping Code                                         |
         *********************************************************************/
         IF p_address_id_in IS NOT NULL THEN
            xProgress := 'ADDRB-20-1010';
            b_use_addr_id := TRUE;
         END IF;

         IF p_org_id_in IS NOT NULL THEN
            xProgress := 'ADDRB-20-1020';
            b_use_org_id := TRUE;
         END IF;

         IF p_tp_location_code_in IS NOT NULL THEN
            xProgress := 'ADDRB-20-1030';
            b_use_lctc := TRUE;
         END IF;

         IF p_tp_location_name_in IS NOT NULL THEN
            xProgress := 'ADDRB-20-1040';
            b_use_loc_name := TRUE;
         END IF;

	 /*********************************************************************
         | Let's Validate the Precedence Code                                 |
         *********************************************************************/
         xProgress := 'ADDRB-20-1070';
         v_pcode := NVL(p_precedence_code,'0'); -- Default precedence is 0 if NULL is passed in...

         ec_debug.pl(3,'v_pcode',v_pcode);
	 -- bug3351412
         IF (v_pcode <> '0' AND
             v_pcode <> '1' AND v_pcode <> '2') THEN
            xProgress := 'ADDRB-20-1080';
            x_return_status := fnd_api.G_RET_STS_ERROR;
            x_status_code := G_INVALID_PARAMETER;
            GOTO l_end_of_program;
         END IF;

/* Bug 2151462 : Removed the checks on country,state,regions and province */
         IF (v_pcode = '0' AND (p_address_line1_in IS NOT NULL OR
             p_address_line2_in IS NOT NULL OR
             p_address_line3_in IS NOT NULL OR
             p_address_line4_in IS NOT NULL OR
             p_address_line_alt_in IS NOT NULL OR
             p_city_in IS NOT NULL OR
             p_zip_in IS NOT NULL )) THEN
            xProgress := 'ADDRB-20-1050';
            b_use_addr_comp := TRUE;
         ELSIF (v_pcode = '2' AND (p_address_line1_in IS NOT NULL OR
             p_address_line2_in IS NOT NULL OR
             p_address_line3_in IS NOT NULL OR
             p_address_line4_in IS NOT NULL OR
             p_address_line_alt_in IS NOT NULL OR
             p_city_in IS NOT NULL OR
             p_zip_in IS NOT NULL OR
	     ece_rules_pkg.g_party_name IS NOT NULL OR
	     ece_rules_pkg.g_party_number IS NOT NULL)) THEN
	     xProgress := 'ADDRB-20-1060';
	     b_use_addr_comp := TRUE;
         END IF;



         /*********************************************************************
         | Let's Validate the Org ID                                          |
         *********************************************************************/
         IF b_use_org_id THEN
            xProgress := 'ADDRB-20-1090';
            SELECT   COUNT(*) INTO n_org_id
            FROM     hr_organization_units
            WHERE    organization_id = p_org_id_in;

            IF n_org_id <> 1 THEN
               -- Looks like we have an invalid Org ID here...
               xProgress := 'ADDRB-20-1100';
               x_status_code := G_INVALID_ORG_ID;
               RAISE fnd_api.G_EXC_ERROR;
            END IF; -- n_org_id <> 1
         END IF; -- IF b_use_org_id THEN

         -- Handle special cases when none of the address components
         -- are provided except the ORG_ID. This should be a success.
         IF (NOT b_use_addr_id) AND
            (NOT b_use_lctc) AND
            (NOT b_use_loc_name) AND
            (NOT b_use_addr_comp) THEN
            xProgress := 'ADDRB-20-1060';
            x_org_id_out := NULL;
            x_address_id_out := NULL;
            x_tp_location_code_out := NULL;
            x_translator_code_out := NULL;
            x_tp_location_name_out := NULL;
            x_address_line1_out := NULL;
            x_address_line2_out := NULL;
            x_address_line3_out := NULL;
            x_address_line4_out := NULL;
            x_address_line_alt_out := NULL;
            x_city_out := NULL;
            x_county_out := NULL;
            x_state_out := NULL;
            x_zip_out := NULL;
            x_province_out := NULL;
            x_country_out := NULL;
            x_region_1_out := NULL;
            x_region_2_out := NULL;
            x_region_3_out := NULL;

            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_status_code := G_NO_ERRORS;
            GOTO l_end_of_program;
         END IF;

         /*********************************************************************
         | Let's See what type of address we're dealing w/ here.              |
         *********************************************************************/
         /********************
         | BANK              |
         ********************/
         xProgress := 'ADDRB-20-1110';
         IF p_address_type = G_BANK THEN              -- Bank
            xProgress := 'ADDRB-20-1120';
            IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!
               xProgress := 'ADDRB-20-1130';
               BEGIN
                  xProgress := 'ADDRB-20-1140';
                  SELECT   TO_NUMBER(NULL),
                           cbb.bank_party_id,
                           hcp.edi_ece_tp_location_code,
                           p_translator_code_in,
                           cbb.bank_branch_name,
                           cbb.address_line1,
                           cbb.address_line2,
                           cbb.address_line3,
                           cbb.address_line4,
                           hzl.address_lines_phonetic,
                           cbb.city,
                           hzl.county,
                           cbb.state,
                           cbb.zip,
                           cbb.province,
                           cbb.country,
                           TO_CHAR(NULL),
                           TO_CHAR(NULL),
                           TO_CHAR(NULL)
                  INTO     x_org_id_out,
                           x_address_id_out,
                           x_tp_location_code_out,
                           x_translator_code_out,
                           x_tp_location_name_out,
                           x_address_line1_out,
                           x_address_line2_out,
                           x_address_line3_out,
                           x_address_line4_out,
                           x_address_line_alt_out,
                           x_city_out,
                           x_county_out,
                           x_state_out,
                           x_zip_out,
                           x_province_out,
                           x_country_out,
                           x_region_1_out,
                           x_region_2_out,
                           x_region_3_out
                  FROM     ce_bank_branches_v           cbb,
                           hz_contact_points            hcp,
                           hz_locations                 hzl,
                           hz_party_sites               hps
                  WHERE    cbb.branch_party_id         = p_address_id_in AND
                           hcp.owner_table_id          = cbb.branch_party_id AND
                           hcp.owner_table_name        = 'HZ_PARTIES' AND
                           hcp.contact_point_type            = 'EDI' AND
                           hps.party_id = cbb.branch_party_id AND
                           hps.identifying_address_flag = 'Y' AND
                           hzl.location_id = hps.party_id;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- Looks like we have an invalid ID here...
                     x_status_code := G_INVALID_ADDR_ID;
                     RAISE fnd_api.G_EXC_ERROR;

               END;

               -- Whatever happens, the API has executed successfully...
               xProgress := 'ADDRB-20-1150';
               x_return_status := fnd_api.G_RET_STS_SUCCESS;

               -- If we were given LC/TC and it is not the same as the derived LC/TC...
               IF b_use_lctc AND ((p_tp_location_code_in <> x_tp_location_code_out) OR
                                  (p_translator_code_in  <> x_translator_code_out)) THEN
                  xProgress := 'ADDRB-20-1160';
                  x_status_code := G_CANNOT_DERIVE_ADDR;
               -- If were were given addreses components and they are not the same as what
               -- was derived then...
               ELSIF b_use_addr_comp  THEN
/* bug2151462	 AND NOT(ece_compare_addresses(p_address_line1_in,
                                                                   p_address_line2_in,
                                                                   p_address_line3_in,
                                                                   p_address_line4_in,
                                                                   p_address_line_alt_in,
                                                                   p_city_in,
                                                                   p_county_in,
                                                                   p_state_in,
                                                                   p_zip_in,
                                                                   p_province_in,
                                                                   p_country_in,
                                                                   p_region_1_in,
                                                                   p_region_2_in,
                                                                   p_region_3_in,
                                                                   x_address_line1_out,
                                                                   x_address_line2_out,
                                                                   x_address_line3_out,
                                                                   x_address_line4_out,
                                                                   x_address_line_alt_out,
                                                                   x_city_out,
                                                                   x_county_out,
                                                                   x_state_out,
                                                                   x_zip_out,
                                                                   x_province_out,
                                                                   x_country_out,
                                                                   x_region_1_out,
                                                                   x_region_2_out,
                                                                   x_region_3_out)) THEN
                  xProgress := 'ADDRB-20-1170';
                  x_status_code := G_INCONSISTENT_ADDR_COMP;
               -- If we were given location names and it is not the same as the derived
               -- location name then...
               ELSIF b_use_loc_name AND (p_tp_location_name_in <> x_tp_location_name_out) THEN
*/
                  xProgress := 'ADDRB-20-1180';
                  x_status_code := G_INCONSISTENT_ADDR_COMP;
               ELSE
                  xProgress := 'ADDRB-20-1190';
                  x_status_code := G_NO_ERRORS;
               END IF;

               -- Whether the address was consistent or not, we have an Address ID so time
               -- to die...
               xProgress := 'ADDRB-20-1200';
               GOTO l_end_of_program;

            END IF; -- IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!

            xProgress := 'ADDRB-20-1210';
            IF b_use_lctc OR b_use_addr_comp  THEN -- If LC/TC are available
             xProgress := 'ADDRB-20-1220';
	     IF v_pcode = '1' THEN		-- bug3351412
               FOR r_addr_rec IN c2_bank_branches(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_tp_translator_code  => p_translator_code_in)  LOOP

                     n_loop_count := n_loop_count + 1;

                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
               END LOOP;
	     ELSE
               FOR r_addr_rec IN c1_bank_branches(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_address_line1_in    => p_address_line1_in,
                  cp_address_line2_in    => p_address_line2_in,
                  cp_address_line3_in    => p_address_line3_in,
                  cp_address_line_alt_in => p_address_line_alt_in,
                  cp_city_in             => p_city_in,
                  cp_zip_in              => p_zip_in)  LOOP
                  /* bug 2151462: added the above parameters to the cursor call */

                     xProgress := 'ADDRB-20-1230';
                     n_loop_count := n_loop_count + 1;

                  	 /* bug2151462       IF b_use_addr_comp THEN
			   -- If Address Components are available...
                     	   xProgress := 'ADDRB-20-1240';
                     	   IF ece_compare_addresses(
                           p_address_line1_in,
                           p_address_line2_in,
                           p_address_line3_in,
                           p_address_line4_in,
                           p_address_line_alt_in,
                           p_city_in,
                           p_county_in,
                           p_state_in,
                           p_zip_in,
                           p_province_in,
                           p_country_in,
                           p_region_1_in,
                           p_region_2_in,
                           p_region_3_in,
                           r_addr_rec.address_line1,
                           r_addr_rec.address_line2,
                           r_addr_rec.address_line3,
                           r_addr_rec.address_line4,
                           r_addr_rec.address_line_alt,
                           r_addr_rec.city,
                           r_addr_rec.county,
                           r_addr_rec.state,
                           r_addr_rec.zip,
                           r_addr_rec.province,
                           r_addr_rec.country,
                           r_addr_rec.region_1,
                           r_addr_rec.region_2,
                           r_addr_rec.region_3) THEN
                        xProgress := 'ADDRB-20-1250';
                        n_match_count := n_match_count + 1;

                        x_org_id_out            := r_addr_rec.org_id;
                        x_address_id_out        := r_addr_rec.address_id;
                        x_tp_location_code_out  := r_addr_rec.tp_location_code;
                        x_tp_location_name_out  := r_addr_rec.tp_location_name;
                        x_address_line1_out     := r_addr_rec.address_line1;
                        x_address_line2_out     := r_addr_rec.address_line2;
                        x_address_line3_out     := r_addr_rec.address_line3;
                        x_address_line4_out     := r_addr_rec.address_line4;
                        x_address_line_alt_out  := r_addr_rec.address_line_alt;
                        x_city_out              := r_addr_rec.city;
                        x_county_out            := r_addr_rec.county;
                        x_state_out             := r_addr_rec.state;
                        x_zip_out               := r_addr_rec.zip;
                        x_province_out          := r_addr_rec.province;
                        x_country_out           := r_addr_rec.country;
                        x_region_1_out          := r_addr_rec.region_1;
                        x_region_2_out          := r_addr_rec.region_2;
                        x_region_3_out          := r_addr_rec.region_3;
                         END IF; -- IF ece_compare_addresses
                        ELSE
	           */
                     xProgress := 'ADDRB-20-1260';
                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
                      --END IF; -- IF b_use_addr_comp THEN
               END LOOP;
             END IF;

               xProgress := 'ADDRB-20-1270';
               IF n_loop_count = 0 THEN
                  xProgress := 'ADDRB-20-1280';
                  x_org_id_out            := p_org_id_in;
                  x_address_id_out        := p_address_id_in;
                  x_tp_location_code_out  := p_tp_location_code_in;
                  x_translator_code_out   := p_translator_code_in;
                  x_tp_location_name_out  := p_tp_location_name_in;
                  x_address_line1_out     := p_address_line1_in;
                  x_address_line2_out     := p_address_line2_in;
                  x_address_line3_out     := p_address_line3_in;
                  x_address_line4_out     := p_address_line4_in;
                  x_address_line_alt_out  := p_address_line_alt_in;
                  x_city_out              := p_city_in;
                  x_county_out            := p_county_in;
                  x_state_out             := p_state_in;
                  x_zip_out               := p_zip_in;
                  x_province_out          := p_province_in;
                  x_country_out           := p_country_in;
                  x_region_1_out          := p_region_1_in;
                  x_region_2_out          := p_region_2_in;
                  x_region_3_out          := p_region_3_in;

                  IF b_use_addr_comp THEN
                     xProgress := 'ADDRB-20-1290';
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_INCONSISTENT_ADDR_COMP;
                  ELSE
                     xProgress := 'ADDRB-20-1300';
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_CANNOT_DERIVE_ADDR;
                  END IF; -- IF b_use_addr_comp THEN

                  GOTO l_end_of_program;
               ELSIF n_loop_count = 1 THEN
                     xProgress := 'ADDRB-20-1310';
                 /*bug2151462        IF b_use_addr_comp THEN
                     xProgress := 'ADDRB-20-1320';
                     IF n_match_count = 0 THEN
                        xProgress := 'ADDRB-20-1330';
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := p_translator_code_in;
                        x_tp_location_name_out  := p_tp_location_name_in;
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_INCONSISTENT_ADDR_COMP;

                        GOTO l_end_of_program;
                     ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        xProgress := 'ADDRB-20-1340';
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                     END IF; -- IF n_match_count = 0 THEN
                  ELSE
	         */
                     -- No need to assign variables in this scenario. Correct values
                     -- are already assigned above.
                     xProgress := 'ADDRB-20-1350';
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_NO_ERRORS;
                     GOTO l_end_of_program;
                     -- END IF; -- b_use_addr_comp THEN
               ELSE -- n_loop_count > 1
                  xProgress := 'ADDRB-20-1360';
                  IF b_use_addr_comp THEN
                     xProgress := 'ADDRB-20-1370';
                      --IF n_match_count = 0 THEN
                      --xProgress := 'ADDRB-20-1380';
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := p_translator_code_in;
                        x_tp_location_name_out  := p_tp_location_name_in;
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_MULTIPLE_ADDR_FOUND;

                        GOTO l_end_of_program;
                    /* Bug 2151462        ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        xProgress := 'ADDRB-20-1390';
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                         ELSE -- n_match_count > 1
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above. However, the Address ID has to be
                        -- removed since we got multiple matches.
                        xProgress := 'ADDRB-20-1400';
                        x_address_id_out := NULL;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_CANNOT_DERIVE_ADDR_ID;

                        GOTO l_end_of_program;
                        END IF; -- IF n_match_count = 0 THEN
	             */
                  ELSE
                     -- We have multiple hits on TC/LC pair and no way to tie-break.
                     xProgress := 'ADDRB-20-1410';
                     x_org_id_out            := NULL;
                     x_address_id_out        := NULL;
                     x_tp_location_code_out  := p_tp_location_code_in;
                     x_translator_code_out   := p_translator_code_in;
                     x_tp_location_name_out  := NULL;
                     x_address_line1_out     := NULL;
                     x_address_line2_out     := NULL;
                     x_address_line3_out     := NULL;
                     x_address_line4_out     := NULL;
                     x_address_line_alt_out  := NULL;
                     x_city_out              := NULL;
                     x_county_out            := NULL;
                     x_state_out             := NULL;
                     x_zip_out               := NULL;
                     x_province_out          := NULL;
                     x_country_out           := NULL;
                     x_region_1_out          := NULL;
                     x_region_2_out          := NULL;
                     x_region_3_out          := NULL;

                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_MULTIPLE_LOC_FOUND;

                     GOTO l_end_of_program;
                  END IF; -- IF b_use_addr_comp THEN
               END IF; -- IF n_loop_count = 0 THEN
            END IF; -- IF b_use_lctc THEN

            IF b_use_addr_comp THEN
               -- At this point, all we have are raw address components and nothing else.
               xProgress := 'ADDRB-20-1420';
               x_org_id_out            := p_org_id_in;
               x_address_id_out        := p_address_id_in;
               x_tp_location_code_out  := p_tp_location_code_in;
               x_translator_code_out   := p_translator_code_in;
               x_tp_location_name_out  := p_tp_location_name_in;
               x_address_line1_out     := p_address_line1_in;
               x_address_line2_out     := p_address_line2_in;
               x_address_line3_out     := p_address_line3_in;
               x_address_line4_out     := p_address_line4_in;
               x_address_line_alt_out  := p_address_line_alt_in;
               x_city_out              := p_city_in;
               x_county_out            := p_county_in;
               x_state_out             := p_state_in;
               x_zip_out               := p_zip_in;
               x_province_out          := p_province_in;
               x_country_out           := p_country_in;
               x_region_1_out          := p_region_1_in;
               x_region_2_out          := p_region_2_in;
               x_region_3_out          := p_region_3_in;

               x_return_status := fnd_api.G_RET_STS_SUCCESS;
               x_status_code := G_CANNOT_DERIVE_ADDR_ID;

               GOTO l_end_of_program;
            END IF; -- IF b_use_addr_comp THEN

            xProgress := 'ADDRB-20-1430';
            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_status_code := G_CANNOT_DERIVE_ADDR_ID;

            GOTO l_end_of_program;

         /********************
         | CUSTOMER          |
         ********************/
         ELSIF p_address_type = G_CUSTOMER THEN       -- Customer
            IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!
               BEGIN
                  SELECT                                             cas.org_id,
					                             cas.cust_acct_site_id,
					                             cas.ece_tp_location_code,
					                             p_translator_code_in,
					                             TO_CHAR(NULL),
					                             loc.address1,
					                             loc.address2,
					                             loc.address3,
					                             loc.address4,
					                             loc.address_lines_phonetic,
					                             loc.city,
					                             loc.county,
					                             loc.state,
					                             loc.postal_code,
					                             loc.province,
					                             loc.country,
					                             TO_CHAR(NULL),
					                             TO_CHAR(NULL),
					                             TO_CHAR(NULL)
					                    INTO     x_org_id_out,
					                             x_address_id_out,
					                             x_tp_location_code_out,
					                             x_translator_code_out,
					                             x_tp_location_name_out,
					                             x_address_line1_out,
					                             x_address_line2_out,
					                             x_address_line3_out,
					                             x_address_line4_out,
					                             x_address_line_alt_out,
					                             x_city_out,
					                             x_county_out,
					                             x_state_out,
					                             x_zip_out,
					                             x_province_out,
					                             x_country_out,
					                             x_region_1_out,
					                             x_region_2_out,
					                             x_region_3_out
                  FROM     hz_cust_acct_sites_all     cas,
                           hz_party_sites             pts,
                           hz_locations               loc


                  WHERE      cas.party_site_id  = pts.party_site_id  AND
                             pts.location_id    =  loc.location_id AND
                             cas.cust_acct_site_id             = p_address_id_in;


               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- Looks like we have an invalid ID here...
                     x_status_code := G_INVALID_ADDR_ID;
                     RAISE fnd_api.G_EXC_ERROR;

               END;

               -- Whatever happens, the API has executed successfully...
               x_return_status := fnd_api.G_RET_STS_SUCCESS;

               -- If we were given LC/TC and it is not the same as the derived LC/TC...
               IF b_use_lctc AND ((p_tp_location_code_in <> x_tp_location_code_out) OR
                                  (p_translator_code_in  <> x_translator_code_out)) THEN
                  x_status_code := G_CANNOT_DERIVE_ADDR;
               -- If were were given addreses components and they are not the same as what
               -- was derived then...
               ELSIF b_use_addr_comp  THEN
	         /*bug2151462		 AND NOT(ece_compare_addresses(p_address_line1_in,
                                                                   p_address_line2_in,
                                                                   p_address_line3_in,
                                                                   p_address_line4_in,
                                                                   p_address_line_alt_in,
                                                                   p_city_in,
                                                                   p_county_in,
                                                                   p_state_in,
                                                                   p_zip_in,
                                                                   p_province_in,
                                                                   p_country_in,
                                                                   p_region_1_in,
                                                                   p_region_2_in,
                                                                   p_region_3_in,
                                                                   x_address_line1_out,
                                                                   x_address_line2_out,
                                                                   x_address_line3_out,
                                                                   x_address_line4_out,
                                                                   x_address_line_alt_out,
                                                                   x_city_out,
                                                                   x_county_out,
                                                                   x_state_out,
                                                                   x_zip_out,
                                                                   x_province_out,
                                                                   x_country_out,
                                                                   x_region_1_out,
                                                                   x_region_2_out,
                                                                   x_region_3_out)) THEN
                    x_status_code := G_INCONSISTENT_ADDR_COMP;
                   -- If we were given location names and it is not the same as the derived
                   -- location name then...
               	   ELSIF b_use_loc_name AND (p_tp_location_name_in <> x_tp_location_name_out) THEN
	          */
                  x_status_code := G_INCONSISTENT_ADDR_COMP;
               ELSE
                  x_status_code := G_NO_ERRORS;
               END IF;

               -- Whether the address was consistent or not, we have an Address ID so time
               -- to die...
               GOTO l_end_of_program;

            END IF; -- IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!

            --Bug 2340691 Split the c_ra_address cursor into 2 SQLs
	    --and modified the call to cursor.

            IF b_use_lctc AND NOT b_use_addr_comp THEN -- If LC is available
	      IF v_pcode = '1' THEN		-- bug3351412
                FOR r_addr_rec IN c4_ra_address(
                   cp_transaction_type    => p_transaction_type,
                   cp_org_id_in           => p_org_id_in,
                   cp_tp_location_code_in => p_tp_location_code_in,
                   cp_tp_translator_code  => p_translator_code_in)  LOOP

                   n_loop_count := n_loop_count + 1;

	 	 BEGIN
		   SELECT  TO_CHAR(NULL)              tp_location_name,
                           loc.address1               address_line1,
                           loc.address2               address_line2,
                           loc.address3               address_line3,
                           loc.address4               address_line4,
                           loc.address_lines_phonetic address_line_alt,
                           loc.city                   city,
                           loc.county                 county,
                           loc.state                  state,
                           loc.postal_code            zip,
                           loc.province               province,
                           loc.country                country,
                           TO_CHAR(NULL)              region_1,
                           TO_CHAR(NULL)              region_2,
                           TO_CHAR(NULL)              region_3
                   INTO     x_tp_location_name_out,
                            x_address_line1_out,
                            x_address_line2_out,
                            x_address_line3_out,
                            x_address_line4_out,
                            x_address_line_alt_out,
                            x_city_out,
                            x_county_out,
                            x_state_out,
                            x_zip_out,
                            x_province_out,
                            x_country_out,
                            x_region_1_out,
                            x_region_2_out,
                            x_region_3_out
                   FROM     hz_party_sites             pts,
                            hz_locations               loc
                   WHERE    pts.location_id      = loc.location_id
                   AND      pts.party_site_id    = r_addr_rec.party_site_id;

		 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     exit;

                 END;

                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;

                END LOOP;
              ELSE
               FOR r_addr_rec IN c2_ra_address(
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in)  LOOP

                  n_loop_count := n_loop_count + 1;

		BEGIN
		  SELECT  TO_CHAR(NULL)              tp_location_name,
                          loc.address1               address_line1,
                          loc.address2               address_line2,
                          loc.address3               address_line3,
                          loc.address4               address_line4,
                          loc.address_lines_phonetic address_line_alt,
                          loc.city                   city,
                          loc.county                 county,
                          loc.state                  state,
                          loc.postal_code            zip,
                          loc.province               province,
                          loc.country                country,
                          TO_CHAR(NULL)              region_1,
                          TO_CHAR(NULL)              region_2,
                          TO_CHAR(NULL)              region_3
                  INTO     x_tp_location_name_out,
                           x_address_line1_out,
                           x_address_line2_out,
                           x_address_line3_out,
                           x_address_line4_out,
                           x_address_line_alt_out,
                           x_city_out,
                           x_county_out,
                           x_state_out,
                           x_zip_out,
                           x_province_out,
                           x_country_out,
                           x_region_1_out,
                           x_region_2_out,
                           x_region_3_out
                  FROM     hz_party_sites             pts,
                           hz_locations               loc
                  WHERE    pts.location_id      = loc.location_id
                  AND      pts.party_site_id    = r_addr_rec.party_site_id;

		EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    exit;
                END;

                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;

               END LOOP;
	       END IF;

            ELSIF (b_use_addr_comp AND NOT b_use_lctc) THEN
            --  Bug 2708573
               IF (v_pcode = '0') then
               FOR r_addr_rec IN c3_ra_address(
                  cp_transaction_type    => p_transaction_type,
                  cp_address_line1_in    => p_address_line1_in,
                  cp_address_line2_in    => p_address_line2_in,
                  cp_address_line3_in    => p_address_line3_in,
                  cp_address_line4_in    => p_address_line4_in,
                  cp_address_line_alt_in => p_address_line_alt_in,
                  cp_city_in             => p_city_in,
                  cp_zip_in              => p_zip_in)  LOOP
                  n_loop_count := n_loop_count + 1;

                  BEGIN
                        SELECT  cas.org_id,
                                cas.cust_acct_site_id,
                                cas.ece_tp_location_code
                        INTO
                                x_org_id_out,
                                x_address_id_out,
                                x_tp_location_code_out
                        FROM     hz_party_sites             pts,
                                 hz_cust_acct_sites_all     cas
                        WHERE    cas.party_site_id =  pts.party_site_id
                        AND      pts.location_id   =  r_addr_rec.location_id
                        AND      nvl(cas.org_id,-99) = nvl(p_org_id_in,nvl(cas.org_id,-99));

                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    exit;
                  END;

                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
                 END LOOP;
                ELSE
		  FOR r_addr_rec IN c5_ra_address(
		      cp_transaction_type    => p_transaction_type,
                      cp_address_line1_in    => p_address_line1_in,
                      cp_address_line2_in    => p_address_line2_in,
                      cp_address_line3_in    => p_address_line3_in,
                      cp_address_line4_in    => p_address_line4_in,
                      cp_address_line_alt_in => p_address_line_alt_in,
                      cp_city_in             => p_city_in,
                      cp_zip_in              => p_zip_in,
                      cp_customer_name_in    => ece_rules_pkg.g_party_name,
		      cp_customer_number_in  => ece_rules_pkg.g_party_number) LOOP
                      n_loop_count := n_loop_count + 1;
		      x_org_id_out            := r_addr_rec.org_id;
                      x_address_id_out        := r_addr_rec.address_id;
                      x_tp_location_code_out  := r_addr_rec.tp_location_code;
		      x_tp_location_name_out  := r_addr_rec.tp_location_name;
                      x_address_line1_out     := r_addr_rec.address_line1;
                      x_address_line2_out     := r_addr_rec.address_line2;
                      x_address_line3_out     := r_addr_rec.address_line3;
                      x_address_line4_out     := r_addr_rec.address_line4;
                      x_address_line_alt_out  := r_addr_rec.address_line_alt;
                      x_city_out              := r_addr_rec.city;
                      x_county_out            := r_addr_rec.county;
                      x_state_out             := r_addr_rec.state;
                      x_zip_out               := r_addr_rec.zip;
                      x_province_out          := r_addr_rec.province;
                      x_country_out           := r_addr_rec.country;
                      x_region_1_out          := r_addr_rec.region_1;
                      x_region_2_out          := r_addr_rec.region_2;
                      x_region_3_out          := r_addr_rec.region_3;
                  END LOOP;
		  END IF;
            ELSIF (b_use_lctc AND b_use_addr_comp) THEN
	     -- Bug 2708573
             -- ELSIF (b_use_lctc AND b_use_addr_comp) OR b_use_addr_comp THEN
              IF (v_pcode = '2') then
                 FOR r_addr_rec IN c5_ra_address(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_address_line1_in    => p_address_line1_in,
                  cp_address_line2_in    => p_address_line2_in,
                  cp_address_line3_in    => p_address_line3_in,
                  cp_address_line4_in    => p_address_line4_in,
                  cp_address_line_alt_in => p_address_line_alt_in,
                  cp_city_in             => p_city_in,
                  cp_zip_in              => p_zip_in,
		  cp_customer_name_in    => ece_rules_pkg.g_party_name,
		  cp_customer_number_in  => ece_rules_pkg.g_party_number)  LOOP
		   n_loop_count := n_loop_count + 1;
		      x_org_id_out            := r_addr_rec.org_id;
                      x_address_id_out        := r_addr_rec.address_id;
                      x_tp_location_code_out  := r_addr_rec.tp_location_code;
		      x_tp_location_name_out  := r_addr_rec.tp_location_name;
                      x_address_line1_out     := r_addr_rec.address_line1;
                      x_address_line2_out     := r_addr_rec.address_line2;
                      x_address_line3_out     := r_addr_rec.address_line3;
                      x_address_line4_out     := r_addr_rec.address_line4;
                      x_address_line_alt_out  := r_addr_rec.address_line_alt;
                      x_city_out              := r_addr_rec.city;
                      x_county_out            := r_addr_rec.county;
                      x_state_out             := r_addr_rec.state;
                      x_zip_out               := r_addr_rec.zip;
                      x_province_out          := r_addr_rec.province;
                      x_country_out           := r_addr_rec.country;
                      x_region_1_out          := r_addr_rec.region_1;
                      x_region_2_out          := r_addr_rec.region_2;
                      x_region_3_out          := r_addr_rec.region_3;
                    END LOOP;
               ELSE
		--  Bug 2340691 If LC,Addr_comp or just Addr_comp are available
               FOR r_addr_rec IN c_ra_address(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_address_line1_in    => p_address_line1_in,
                  cp_address_line2_in    => p_address_line2_in,
                  cp_address_line3_in    => p_address_line3_in,
                  cp_address_line4_in    => p_address_line4_in,
                  cp_address_line_alt_in => p_address_line_alt_in,
                  cp_city_in             => p_city_in,
                  cp_zip_in              => p_zip_in)  LOOP
	    	  /* bug 2151462: added the above parameters to the cursor call */

                  n_loop_count := n_loop_count + 1;

		  /*bug2151462      IF b_use_addr_comp THEN -- If Address Components are available...
                     	   IF ece_compare_addresses(
                           p_address_line1_in,
                           p_address_line2_in,
                           p_address_line3_in,
                           p_address_line4_in,
                           p_address_line_alt_in,
                           p_city_in,
                           p_county_in,
                           p_state_in,
                           p_zip_in,
                           p_province_in,
                           p_country_in,
                           p_region_1_in,
                           p_region_2_in,
                           p_region_3_in,
                           r_addr_rec.address_line1,
                           r_addr_rec.address_line2,
                           r_addr_rec.address_line3,
                           r_addr_rec.address_line4,
                           r_addr_rec.address_line_alt,
                           r_addr_rec.city,
                           r_addr_rec.county,
                           r_addr_rec.state,
                           r_addr_rec.zip,
                           r_addr_rec.province,
                           r_addr_rec.country,
                           r_addr_rec.region_1,
                           r_addr_rec.region_2,
                           r_addr_rec.region_3) THEN
                           n_match_count := n_match_count + 1;

                        x_org_id_out            := r_addr_rec.org_id;
                        x_address_id_out        := r_addr_rec.address_id;
                        x_tp_location_code_out  := r_addr_rec.tp_location_code;
                        x_tp_location_name_out  := r_addr_rec.tp_location_name;
                        x_address_line1_out     := r_addr_rec.address_line1;
                        x_address_line2_out     := r_addr_rec.address_line2;
                        x_address_line3_out     := r_addr_rec.address_line3;
                        x_address_line4_out     := r_addr_rec.address_line4;
                        x_address_line_alt_out  := r_addr_rec.address_line_alt;
                        x_city_out              := r_addr_rec.city;
                        x_county_out            := r_addr_rec.county;
                        x_state_out             := r_addr_rec.state;
                        x_zip_out               := r_addr_rec.zip;
                        x_province_out          := r_addr_rec.province;
                        x_country_out           := r_addr_rec.country;
                        x_region_1_out          := r_addr_rec.region_1;
                        x_region_2_out          := r_addr_rec.region_2;
                        x_region_3_out          := r_addr_rec.region_3;
                     	END IF; -- IF ece_compare_addresses
                  	ELSE
		    */
                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
                     --END IF; -- IF b_use_addr_comp THEN
                 END LOOP;

	       END IF;
	       END IF;
	       IF b_use_lctc OR b_use_addr_comp  THEN    -- Bug 2340691
                IF n_loop_count = 0 THEN
                  x_org_id_out            := p_org_id_in;
                  x_address_id_out        := p_address_id_in;
                  x_tp_location_code_out  := p_tp_location_code_in;
                  x_translator_code_out   := nvl(ece_rules_pkg.g_party_number,p_translator_code_in);
                  x_tp_location_name_out  := nvl(ece_rules_pkg.g_party_name,p_tp_location_name_in);
                  x_address_line1_out     := p_address_line1_in;
                  x_address_line2_out     := p_address_line2_in;
                  x_address_line3_out     := p_address_line3_in;
                  x_address_line4_out     := p_address_line4_in;
                  x_address_line_alt_out  := p_address_line_alt_in;
                  x_city_out              := p_city_in;
                  x_county_out            := p_county_in;
                  x_state_out             := p_state_in;
                  x_zip_out               := p_zip_in;
                  x_province_out          := p_province_in;
                  x_country_out           := p_country_in;
                  x_region_1_out          := p_region_1_in;
                  x_region_2_out          := p_region_2_in;
                  x_region_3_out          := p_region_3_in;

                  IF b_use_addr_comp THEN
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_INCONSISTENT_ADDR_COMP;
                  ELSE
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_CANNOT_DERIVE_ADDR;
                  END IF; -- IF b_use_addr_comp THEN

                  GOTO l_end_of_program;
               ELSIF n_loop_count = 1 THEN
		    /*bug2151462      IF b_use_addr_comp THEN
                        IF n_match_count = 0 THEN
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := p_translator_code_in;
                        x_tp_location_name_out  := p_tp_location_name_in;
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_INCONSISTENT_ADDR_COMP;

                        GOTO l_end_of_program;
                     	ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                     	END IF; -- IF n_match_count = 0 THEN
                  	ELSE
		     */
                     -- No need to assign variables in this scenario. Correct values
                     -- are already assigned above.
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_NO_ERRORS;
                     GOTO l_end_of_program;
                    --END IF; -- b_use_addr_comp THEN
               ELSE -- n_loop_count > 1
                   IF b_use_addr_comp THEN
                        --IF n_match_count = 0 THEN
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := nvl(ece_rules_pkg.g_party_number,p_translator_code_in);
                        x_tp_location_name_out  := nvl(ece_rules_pkg.g_party_name,p_tp_location_name_in);
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_MULTIPLE_ADDR_FOUND;

                        GOTO l_end_of_program;
		      /* bug2151462           ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                     	ELSE -- n_match_count > 1
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above. However, the Address ID has to be
                        -- removed since we got multiple matches.
                        x_address_id_out := NULL;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_CANNOT_DERIVE_ADDR_ID;

                        GOTO l_end_of_program;
                     	END IF; -- IF n_match_count = 0 THEN
		       */
                  ELSE
                     -- We have multiple hits on TC/LC pair and no way to tie-break.
                     x_org_id_out            := NULL;
                     x_address_id_out        := NULL;
                     x_tp_location_code_out  := p_tp_location_code_in;
                     x_translator_code_out   := p_translator_code_in;
                     x_tp_location_name_out  := NULL;
                     x_address_line1_out     := NULL;
                     x_address_line2_out     := NULL;
                     x_address_line3_out     := NULL;
                     x_address_line4_out     := NULL;
                     x_address_line_alt_out  := NULL;
                     x_city_out              := NULL;
                     x_county_out            := NULL;
                     x_state_out             := NULL;
                     x_zip_out               := NULL;
                     x_province_out          := NULL;
                     x_country_out           := NULL;
                     x_region_1_out          := NULL;
                     x_region_2_out          := NULL;
                     x_region_3_out          := NULL;

                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_MULTIPLE_LOC_FOUND;

                     GOTO l_end_of_program;
                  END IF; -- IF b_use_addr_comp THEN
                 END IF; -- IF n_loop_count = 0 THEN
                END IF; -- IF b_use_lctc THEN

            IF b_use_addr_comp THEN
               -- At this point, all we have are raw address components and nothing else.
               x_org_id_out            := p_org_id_in;
               x_address_id_out        := p_address_id_in;
               x_tp_location_code_out  := p_tp_location_code_in;
               x_translator_code_out   := nvl(ece_rules_pkg.g_party_number,p_translator_code_in);
               x_tp_location_name_out  := nvl(ece_rules_pkg.g_party_name,p_tp_location_name_in);
               x_address_line1_out     := p_address_line1_in;
               x_address_line2_out     := p_address_line2_in;
               x_address_line3_out     := p_address_line3_in;
               x_address_line4_out     := p_address_line4_in;
               x_address_line_alt_out  := p_address_line_alt_in;
               x_city_out              := p_city_in;
               x_county_out            := p_county_in;
               x_state_out             := p_state_in;
               x_zip_out               := p_zip_in;
               x_province_out          := p_province_in;
               x_country_out           := p_country_in;
               x_region_1_out          := p_region_1_in;
               x_region_2_out          := p_region_2_in;
               x_region_3_out          := p_region_3_in;

               x_return_status := fnd_api.G_RET_STS_SUCCESS;
               x_status_code := G_CANNOT_DERIVE_ADDR_ID;

               GOTO l_end_of_program;
            END IF; -- IF b_use_addr_comp THEN

            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_status_code := G_CANNOT_DERIVE_ADDR_ID;

            GOTO l_end_of_program;

         /********************
         | INTERNAL          |
         ********************/
         ELSIF p_address_type = G_HR_LOCATION THEN    -- Internal Location
            IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!
               BEGIN
                  SELECT   -- hrl.org_id                 org_id,
                           hrl.location_id,
                           hrl.ece_tp_location_code,
                           p_translator_code_in,
                           hrl.location_code,
                           hrl.address_line_1,
                           hrl.address_line_2,
                           hrl.address_line_3,
                           TO_CHAR(NULL),
                           TO_CHAR(NULL),
                           hrl.town_or_city,
                           TO_CHAR(NULL),
                           TO_CHAR(NULL),
                           hrl.postal_code,
                           TO_CHAR(NULL),
                           hrl.country,
                           hrl.region_1,
                           hrl.region_2,
                           hrl.region_3
                  INTO     -- x_org_id_out,
                           x_address_id_out,
                           x_tp_location_code_out,
                           x_translator_code_out,
                           x_tp_location_name_out,
                           x_address_line1_out,
                           x_address_line2_out,
                           x_address_line3_out,
                           x_address_line4_out,
                           x_address_line_alt_out,
                           x_city_out,
                           x_county_out,
                           x_state_out,
                           x_zip_out,
                           x_province_out,
                           x_country_out,
                           x_region_1_out,
                           x_region_2_out,
                           x_region_3_out
                  FROM     hr_locations_all           hrl
                  WHERE    hrl.location_id            = p_address_id_in;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   BEGIN	-- Bug 2743560
                     SELECT   -- hrl.org_id       org_id,
                           	 hrl.location_id,
                           	 TO_CHAR(NULL),
                           	 p_translator_code_in,
                           	 TO_CHAR(NULL),
                           	 hrl.address1,
                           	 hrl.address2,
                           	 hrl.address3,
                           	 hrl.address4,
                           	 TO_CHAR(NULL),
                           	 hrl.city,
                           	 hrl.county,
                           	 hrl.state,
                           	 hrl.postal_code,
                           	 hrl.province,
                           	 hrl.country,
                           	 TO_CHAR(NULL),
                           	 TO_CHAR(NULL),
                           	 TO_CHAR(NULL)
                     INTO     -- x_org_id_out,
                           	 x_address_id_out,
                           	 x_tp_location_code_out,
                           	 x_translator_code_out,
                           	 x_tp_location_name_out,
                           	 x_address_line1_out,
                           	 x_address_line2_out,
                           	 x_address_line3_out,
                           	 x_address_line4_out,
                           	 x_address_line_alt_out,
                           	 x_city_out,
                           	 x_county_out,
                           	 x_state_out,
                           	 x_zip_out,
                           	 x_province_out,
                           	 x_country_out,
                           	 x_region_1_out,
                           	 x_region_2_out,
                           	 x_region_3_out
                     FROM     hz_locations               hrl
                     WHERE    hrl.location_id            = p_address_id_in;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                     -- Looks like we have an invalid ID here...
                     x_status_code := G_INVALID_ADDR_ID;
                     RAISE fnd_api.G_EXC_ERROR;

                  END;
               END;

               -- Whatever happens, the API has executed successfully...
               x_return_status := fnd_api.G_RET_STS_SUCCESS;

               -- If we were given LC/TC and it is not the same as the derived LC/TC...
               IF b_use_lctc AND ((p_tp_location_code_in <> x_tp_location_code_out) OR
                                  (p_translator_code_in  <> x_translator_code_out)) THEN
                  x_status_code := G_CANNOT_DERIVE_ADDR;
               -- If were were given addreses components and they are not the same as what
               -- was derived then...
               ELSIF b_use_addr_comp    THEN
		  /* bug2151462	 NOT(ece_compare_addresses(p_address_line1_in,
                                                                   p_address_line2_in,
                                                                   p_address_line3_in,
                                                                   p_address_line4_in,
                                                                   p_address_line_alt_in,
                                                                   p_city_in,
                                                                   p_county_in,
                                                                   p_state_in,
                                                                   p_zip_in,
                                                                   p_province_in,
                                                                   p_country_in,
                                                                   p_region_1_in,
                                                                   p_region_2_in,
                                                                   p_region_3_in,
                                                                   x_address_line1_out,
                                                                   x_address_line2_out,
                                                                   x_address_line3_out,
                                                                   x_address_line4_out,
                                                                   x_address_line_alt_out,
                                                                   x_city_out,
                                                                   x_county_out,
                                                                   x_state_out,
                                                                   x_zip_out,
                                                                   x_province_out,
                                                                   x_country_out,
                                                                   x_region_1_out,
                                                                   x_region_2_out,
                                                                   x_region_3_out)) THEN
                  	x_status_code := G_INCONSISTENT_ADDR_COMP;
               		- If we were given location names and it is not the same as the derived
               		-- location name then...
               		ELSIF b_use_loc_name AND (p_tp_location_name_in <> x_tp_location_name_out) THEN
		  */
                  x_status_code := G_INCONSISTENT_ADDR_COMP;
               ELSE
                  x_status_code := G_NO_ERRORS;
               END IF;

               -- Whether the address was consistent or not, we have an Address ID so time
               -- to die...
               GOTO l_end_of_program;

            END IF; -- IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!

            IF b_use_lctc OR b_use_addr_comp THEN -- If LC/TC are available
	    /* Bug 2570369 Split the c_locations cursor in two. Thus scan the 2nd
			   cursor if the 1st cursor returns no record
	    */
               FOR r_addr_rec IN c_locations_1(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_address_line1_in    => p_address_line1_in,
 		  cp_address_line2_in    => p_address_line2_in,
 		  cp_address_line3_in    => p_address_line3_in,
 		  cp_city_in             => p_city_in,
 		  cp_zip_in              => p_zip_in) LOOP
		  /* bug 2151462: added the above parameters to the cursor call */

                  n_loop_count := n_loop_count + 1;

        	   /*bug2151462      IF b_use_addr_comp THEN -- If Address Components are available...
                     	   IF ece_compare_addresses(
                           p_address_line1_in,
                           p_address_line2_in,
                           p_address_line3_in,
                           p_address_line4_in,
                           p_address_line_alt_in,
                           p_city_in,
                           p_county_in,
                           p_state_in,
                           p_zip_in,
                           p_province_in,
                           p_country_in,
                           p_region_1_in,
                           p_region_2_in,
                           p_region_3_in,
                           r_addr_rec.address_line1,
                           r_addr_rec.address_line2,
                           r_addr_rec.address_line3,
                           r_addr_rec.address_line4,
                           r_addr_rec.address_line_alt,
                           r_addr_rec.city,
                           r_addr_rec.county,
                           r_addr_rec.state,
                           r_addr_rec.zip,
                           r_addr_rec.province,
                           r_addr_rec.country,
                           r_addr_rec.region_1,
                           r_addr_rec.region_2,
                           r_addr_rec.region_3) THEN
                        n_match_count := n_match_count + 1;
           		ec_debug.pl(0,'n_match_count',n_match_count);

                        x_org_id_out            := r_addr_rec.org_id;
                        x_address_id_out        := r_addr_rec.address_id;
                        x_tp_location_code_out  := r_addr_rec.tp_location_code;
                        x_tp_location_name_out  := r_addr_rec.tp_location_name;
                        x_address_line1_out     := r_addr_rec.address_line1;
                        x_address_line2_out     := r_addr_rec.address_line2;
                        x_address_line3_out     := r_addr_rec.address_line3;
                        x_address_line4_out     := r_addr_rec.address_line4;
                        x_address_line_alt_out  := r_addr_rec.address_line_alt;
                        x_city_out              := r_addr_rec.city;
                        x_county_out            := r_addr_rec.county;
                        x_state_out             := r_addr_rec.state;
                        x_zip_out               := r_addr_rec.zip;
                        x_province_out          := r_addr_rec.province;
                        x_country_out           := r_addr_rec.country;
                        x_region_1_out          := r_addr_rec.region_1;
                        x_region_2_out          := r_addr_rec.region_2;
                        x_region_3_out          := r_addr_rec.region_3;
                     	END IF; -- IF ece_compare_addresses
                  	ELSE
		    */
                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
                     x_translator_code_out   := r_addr_rec.inv_organization_id;	 -- Bug 2570369
                     --END IF; -- IF b_use_addr_comp THEN
               END LOOP;

	    /* Bug 2570369 Split the c_locations cursor in two. Thus scan the 2nd
			   cursor if the 1st cursor returns no record
	    */
               IF n_loop_count = 0  AND b_use_addr_comp THEN
                FOR r_addr_rec IN c_locations_2(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_address_line1_in    => p_address_line1_in,
 		  cp_address_line2_in    => p_address_line2_in,
 		  cp_address_line3_in    => p_address_line3_in,
 		  cp_city_in             => p_city_in,
 		  cp_zip_in              => p_zip_in) LOOP

                  n_loop_count := n_loop_count + 1;

                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
                END LOOP;
	       END IF;

               IF n_loop_count = 0 THEN
                  x_org_id_out            := p_org_id_in;
                  x_address_id_out        := p_address_id_in;
                  x_tp_location_code_out  := p_tp_location_code_in;
                  x_translator_code_out   := p_translator_code_in;
                  x_tp_location_name_out  := p_tp_location_name_in;
                  x_address_line1_out     := p_address_line1_in;
                  x_address_line2_out     := p_address_line2_in;
                  x_address_line3_out     := p_address_line3_in;
                  x_address_line4_out     := p_address_line4_in;
                  x_address_line_alt_out  := p_address_line_alt_in;
                  x_city_out              := p_city_in;
                  x_county_out            := p_county_in;
                  x_state_out             := p_state_in;
                  x_zip_out               := p_zip_in;
                  x_province_out          := p_province_in;
                  x_country_out           := p_country_in;
                  x_region_1_out          := p_region_1_in;
                  x_region_2_out          := p_region_2_in;
                  x_region_3_out          := p_region_3_in;

                  IF b_use_addr_comp THEN
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_INCONSISTENT_ADDR_COMP;
                  ELSE
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_CANNOT_DERIVE_ADDR;
                  END IF; -- IF b_use_addr_comp THEN

                  GOTO l_end_of_program;
               ELSIF n_loop_count = 1 THEN
		   /*bug2151462        IF b_use_addr_comp THEN
                     	IF n_match_count = 0 THEN
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := p_translator_code_in;
                        x_tp_location_name_out  := p_tp_location_name_in;
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_INCONSISTENT_ADDR_COMP;

                        GOTO l_end_of_program;
                     	ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                     	END IF; -- IF n_match_count = 0 THEN
                  	ELSE
		     */
                     -- No need to assign variables in this scenario. Correct values
                     -- are already assigned above.
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_NO_ERRORS;
                     GOTO l_end_of_program;
                --  END IF; -- b_use_addr_comp THEN
               ELSE -- n_loop_count > 1
                   IF b_use_addr_comp THEN
                       --IF n_match_count = 0 THEN
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := p_translator_code_in;
                        x_tp_location_name_out  := p_tp_location_name_in;
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_MULTIPLE_ADDR_FOUND;

                        GOTO l_end_of_program;
		      /* bug2151462          ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                         ELSE -- n_match_count > 1
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above. However, the Address ID has to be
                        -- removed since we got multiple matches.
                        x_address_id_out := NULL;
			ec_debug.pl(3,'Failed here ');
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_CANNOT_DERIVE_ADDR_ID;

                        GOTO l_end_of_program;
                         END IF; -- IF n_match_count = 0 THEN
		       */
                  ELSE
                     -- We have multiple hits on TC/LC pair and no way to tie-break.
                     x_org_id_out            := NULL;
                     x_address_id_out        := NULL;
                     x_tp_location_code_out  := p_tp_location_code_in;
                     x_translator_code_out   := p_translator_code_in;
                     x_tp_location_name_out  := NULL;
                     x_address_line1_out     := NULL;
                     x_address_line2_out     := NULL;
                     x_address_line3_out     := NULL;
                     x_address_line4_out     := NULL;
                     x_address_line_alt_out  := NULL;
                     x_city_out              := NULL;
                     x_county_out            := NULL;
                     x_state_out             := NULL;
                     x_zip_out               := NULL;
                     x_province_out          := NULL;
                     x_country_out           := NULL;
                     x_region_1_out          := NULL;
                     x_region_2_out          := NULL;
                     x_region_3_out          := NULL;

                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_MULTIPLE_LOC_FOUND;

                     GOTO l_end_of_program;
                  END IF; -- IF b_use_addr_comp THEN
               END IF; -- IF n_loop_count = 0 THEN
            END IF; -- IF b_use_lctc THEN

            IF b_use_addr_comp THEN
               -- At this point, all we have are raw address components and nothing else.
               x_org_id_out            := p_org_id_in;
               x_address_id_out        := p_address_id_in;
               x_tp_location_code_out  := p_tp_location_code_in;
               x_translator_code_out   := p_translator_code_in;
               x_tp_location_name_out  := p_tp_location_name_in;
               x_address_line1_out     := p_address_line1_in;
               x_address_line2_out     := p_address_line2_in;
               x_address_line3_out     := p_address_line3_in;
               x_address_line4_out     := p_address_line4_in;
               x_address_line_alt_out  := p_address_line_alt_in;
               x_city_out              := p_city_in;
               x_county_out            := p_county_in;
               x_state_out             := p_state_in;
               x_zip_out               := p_zip_in;
               x_province_out          := p_province_in;
               x_country_out           := p_country_in;
               x_region_1_out          := p_region_1_in;
               x_region_2_out          := p_region_2_in;
               x_region_3_out          := p_region_3_in;

               x_return_status := fnd_api.G_RET_STS_SUCCESS;
               x_status_code := G_CANNOT_DERIVE_ADDR_ID;

               GOTO l_end_of_program;
            END IF; -- IF b_use_addr_comp THEN

            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_status_code := G_CANNOT_DERIVE_ADDR_ID;

            GOTO l_end_of_program;

         /********************
         | SUPPLIER          |
         ********************/
         ELSIF p_address_type = G_SUPPLIER THEN       -- Supplier
            IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!
               BEGIN
                  SELECT   pvs.org_id,
                           pvs.vendor_site_id,
                           pvs.ece_tp_location_code,
                           p_translator_code_in,
                           pvs.vendor_site_code,
                           pvs.address_line1,
                           pvs.address_line2,
                           pvs.address_line3,
                           pvs.address_line4,
                           pvs.address_lines_alt,
                           pvs.city,
                           pvs.county,
                           pvs.state,
                           pvs.zip,
                           pvs.province,
                           pvs.country,
                           TO_CHAR(NULL),
                           TO_CHAR(NULL),
                           TO_CHAR(NULL)
                  INTO     x_org_id_out,
                           x_address_id_out,
                           x_tp_location_code_out,
                           x_translator_code_out,
                           x_tp_location_name_out,
                           x_address_line1_out,
                           x_address_line2_out,
                           x_address_line3_out,
                           x_address_line4_out,
                           x_address_line_alt_out,
                           x_city_out,
                           x_county_out,
                           x_state_out,
                           x_zip_out,
                           x_province_out,
                           x_country_out,
                           x_region_1_out,
                           x_region_2_out,
                           x_region_3_out
                  FROM     po_vendor_sites_all        pvs
                  WHERE    pvs.vendor_site_id         = p_address_id_in;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- Looks like we have an invalid ID here...
                     x_status_code := G_INVALID_ADDR_ID;
                     RAISE fnd_api.G_EXC_ERROR;

               END;

               -- Whatever happens, the API has executed successfully...
               x_return_status := fnd_api.G_RET_STS_SUCCESS;

               -- If we were given LC/TC and it is not the same as the derived LC/TC...
               IF b_use_lctc AND ((p_tp_location_code_in <> x_tp_location_code_out) OR
                                  (p_translator_code_in  <> x_translator_code_out)) THEN
                  x_status_code := G_CANNOT_DERIVE_ADDR;
               -- If were were given addreses components and they are not the same as what
               -- was derived then...
               ELSIF b_use_addr_comp THEN
		  /* bug2151462		  AND NOT(ece_compare_addresses(p_address_line1_in,
                                                                   p_address_line2_in,
                                                                   p_address_line3_in,
                                                                   p_address_line4_in,
                                                                   p_address_line_alt_in,
                                                                   p_city_in,
                                                                   p_county_in,
                                                                   p_state_in,
                                                                   p_zip_in,
                                                                   p_province_in,
                                                                   p_country_in,
                                                                   p_region_1_in,
                                                                   p_region_2_in,
                                                                   p_region_3_in,
                                                                   x_address_line1_out,
                                                                   x_address_line2_out,
                                                                   x_address_line3_out,
                                                                   x_address_line4_out,
                                                                   x_address_line_alt_out,
                                                                   x_city_out,
                                                                   x_county_out,
                                                                   x_state_out,
                                                                   x_zip_out,
                                                                   x_province_out,
                                                                   x_country_out,
                                                                   x_region_1_out,
                                                                   x_region_2_out,
                                                                   x_region_3_out)) THEN
                  	x_status_code := G_INCONSISTENT_ADDR_COMP;
               		-- If we were given location names and it is not the same as the derived
               		-- location name then...
               		ELSIF b_use_loc_name AND (p_tp_location_name_in <> x_tp_location_name_out) THEN
	         */
                  x_status_code := G_INCONSISTENT_ADDR_COMP;
               ELSE
                  x_status_code := G_NO_ERRORS;
               END IF;

               -- Whether the address was consistent or not, we have an Address ID so time
               -- to die...
               GOTO l_end_of_program;

            END IF; -- IF b_use_addr_id THEN   -- We have the ADDRESS_ID. Great!

            IF b_use_lctc OR b_use_addr_comp THEN -- If LC/TC are available
	     IF v_pcode = '1' THEN		-- bug3351412
               FOR r_addr_rec IN c2_vendor_sites(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_tp_translator_code  => p_translator_code_in)  LOOP

                     n_loop_count := n_loop_count + 1;

                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
               END LOOP;
             ELSE
               FOR r_addr_rec IN c1_vendor_sites(
                  cp_transaction_type    => p_transaction_type,
                  cp_org_id_in           => p_org_id_in,
                  cp_tp_location_code_in => p_tp_location_code_in,
                  cp_address_line1_in    => p_address_line1_in,
                  cp_address_line2_in    => p_address_line2_in,
                  cp_address_line3_in    => p_address_line3_in,
                  cp_address_line_alt_in => p_address_line_alt_in,
                  cp_city_in             => p_city_in,
                  cp_zip_in              => p_zip_in)  LOOP
		  /* bug 2151462: added the above parameters to the cursor call */

                  n_loop_count := n_loop_count + 1;

		  /*bug2151462    IF b_use_addr_comp THEN -- If Address Components are available...
                           IF ece_compare_addresses(
                           p_address_line1_in,
                           p_address_line2_in,
                           p_address_line3_in,
                           p_address_line4_in,
                           p_address_line_alt_in,
                           p_city_in,
                           p_county_in,
                           p_state_in,
                           p_zip_in,
                           p_province_in,
                           p_country_in,
                           p_region_1_in,
                           p_region_2_in,
                           p_region_3_in,
                           r_addr_rec.address_line1,
                           r_addr_rec.address_line2,
                           r_addr_rec.address_line3,
                           r_addr_rec.address_line4,
                           r_addr_rec.address_line_alt,
                           r_addr_rec.city,
                           r_addr_rec.county,
                           r_addr_rec.state,
                           r_addr_rec.zip,
                           r_addr_rec.province,
                           r_addr_rec.country,
                           r_addr_rec.region_1,
                           r_addr_rec.region_2,
                           r_addr_rec.region_3) THEN
                        n_match_count := n_match_count + 1;

                        x_org_id_out            := r_addr_rec.org_id;
                        x_address_id_out        := r_addr_rec.address_id;
                        x_tp_location_code_out  := r_addr_rec.tp_location_code;
                        x_tp_location_name_out  := r_addr_rec.tp_location_name;
                        x_address_line1_out     := r_addr_rec.address_line1;
                        x_address_line2_out     := r_addr_rec.address_line2;
                        x_address_line3_out     := r_addr_rec.address_line3;
                        x_address_line4_out     := r_addr_rec.address_line4;
                        x_address_line_alt_out  := r_addr_rec.address_line_alt;
                        x_city_out              := r_addr_rec.city;
                        x_county_out            := r_addr_rec.county;
                        x_state_out             := r_addr_rec.state;
                        x_zip_out               := r_addr_rec.zip;
                        x_province_out          := r_addr_rec.province;
                        x_country_out           := r_addr_rec.country;
                        x_region_1_out          := r_addr_rec.region_1;
                        x_region_2_out          := r_addr_rec.region_2;
                        x_region_3_out          := r_addr_rec.region_3;
                     	END IF; -- IF ece_compare_addresses
                  	ELSE
		     */
                     x_org_id_out            := r_addr_rec.org_id;
                     x_address_id_out        := r_addr_rec.address_id;
                     x_tp_location_code_out  := r_addr_rec.tp_location_code;
                     x_tp_location_name_out  := r_addr_rec.tp_location_name;
                     x_address_line1_out     := r_addr_rec.address_line1;
                     x_address_line2_out     := r_addr_rec.address_line2;
                     x_address_line3_out     := r_addr_rec.address_line3;
                     x_address_line4_out     := r_addr_rec.address_line4;
                     x_address_line_alt_out  := r_addr_rec.address_line_alt;
                     x_city_out              := r_addr_rec.city;
                     x_county_out            := r_addr_rec.county;
                     x_state_out             := r_addr_rec.state;
                     x_zip_out               := r_addr_rec.zip;
                     x_province_out          := r_addr_rec.province;
                     x_country_out           := r_addr_rec.country;
                     x_region_1_out          := r_addr_rec.region_1;
                     x_region_2_out          := r_addr_rec.region_2;
                     x_region_3_out          := r_addr_rec.region_3;
                     --END IF; -- IF b_use_addr_comp THEN
               END LOOP;
             END IF;

               IF n_loop_count = 0 THEN
                  x_org_id_out            := p_org_id_in;
                  x_address_id_out        := p_address_id_in;
                  x_tp_location_code_out  := p_tp_location_code_in;
                  x_translator_code_out   := p_translator_code_in;
                  x_tp_location_name_out  := p_tp_location_name_in;
                  x_address_line1_out     := p_address_line1_in;
                  x_address_line2_out     := p_address_line2_in;
                  x_address_line3_out     := p_address_line3_in;
                  x_address_line4_out     := p_address_line4_in;
                  x_address_line_alt_out  := p_address_line_alt_in;
                  x_city_out              := p_city_in;
                  x_county_out            := p_county_in;
                  x_state_out             := p_state_in;
                  x_zip_out               := p_zip_in;
                  x_province_out          := p_province_in;
                  x_country_out           := p_country_in;
                  x_region_1_out          := p_region_1_in;
                  x_region_2_out          := p_region_2_in;
                  x_region_3_out          := p_region_3_in;

                  IF b_use_addr_comp THEN
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_INCONSISTENT_ADDR_COMP;
                  ELSE
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_CANNOT_DERIVE_ADDR;
                  END IF; -- IF b_use_addr_comp THEN

                  GOTO l_end_of_program;
               ELSIF n_loop_count = 1 THEN -- The Cursor Returned only one row.
		     /* bug2151462      IF b_use_addr_comp THEN
                     	IF n_match_count = 0 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_INCONSISTENT_ADDR_COMP;

                        GOTO l_end_of_program;
                     	ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                     	END IF;
                  	ELSE
		     */
                     -- No need to assign variables in this scenario. Correct values
                     -- are already assigned above.
                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_NO_ERRORS;
                     GOTO l_end_of_program;
                     --END IF;
               ELSE -- n_loop_count > 1
                 IF b_use_addr_comp THEN
                        --IF n_match_count = 0 THEN
                        x_org_id_out            := p_org_id_in;
                        x_address_id_out        := p_address_id_in;
                        x_tp_location_code_out  := p_tp_location_code_in;
                        x_translator_code_out   := p_translator_code_in;
                        x_tp_location_name_out  := p_tp_location_name_in;
                        x_address_line1_out     := p_address_line1_in;
                        x_address_line2_out     := p_address_line2_in;
                        x_address_line3_out     := p_address_line3_in;
                        x_address_line4_out     := p_address_line4_in;
                        x_address_line_alt_out  := p_address_line_alt_in;
                        x_city_out              := p_city_in;
                        x_county_out            := p_county_in;
                        x_state_out             := p_state_in;
                        x_zip_out               := p_zip_in;
                        x_province_out          := p_province_in;
                        x_country_out           := p_country_in;
                        x_region_1_out          := p_region_1_in;
                        x_region_2_out          := p_region_2_in;
                        x_region_3_out          := p_region_3_in;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_MULTIPLE_ADDR_FOUND;

                        GOTO l_end_of_program;
		      /* bug2151462           ELSIF n_match_count = 1 THEN
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above.
                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_NO_ERRORS;
                        GOTO l_end_of_program;
                     	ELSE -- n_match_count > 1
                        -- No need to assign variables in this scenario. Correct values
                        -- are already assigned above. However, the Address ID has to be
                        -- removed since we got multiple matches.
                        x_address_id_out := NULL;

                        x_return_status := fnd_api.G_RET_STS_SUCCESS;
                        x_status_code := G_CANNOT_DERIVE_ADDR_ID;

                        GOTO l_end_of_program;
                     	END IF; -- IF n_match_count = 0 THEN
		       */
                  ELSE
                     -- We have multiple hits on TC/LC pair and no way to tie-break.
                     x_org_id_out            := NULL;
                     x_address_id_out        := NULL;
                     x_tp_location_code_out  := p_tp_location_code_in;
                     x_translator_code_out   := p_translator_code_in;
                     x_tp_location_name_out  := NULL;
                     x_address_line1_out     := NULL;
                     x_address_line2_out     := NULL;
                     x_address_line3_out     := NULL;
                     x_address_line4_out     := NULL;
                     x_address_line_alt_out  := NULL;
                     x_city_out              := NULL;
                     x_county_out            := NULL;
                     x_state_out             := NULL;
                     x_zip_out               := NULL;
                     x_province_out          := NULL;
                     x_country_out           := NULL;
                     x_region_1_out          := NULL;
                     x_region_2_out          := NULL;
                     x_region_3_out          := NULL;

                     x_return_status := fnd_api.G_RET_STS_SUCCESS;
                     x_status_code := G_MULTIPLE_LOC_FOUND;

                     GOTO l_end_of_program;
                  END IF; -- IF b_use_addr_comp THEN
               END IF; -- IF n_loop_count = 0 THEN
            END IF; -- IF b_use_lctc THEN

            IF b_use_addr_comp THEN
               -- At this point, all we have are raw address components and nothing else.
               x_org_id_out            := p_org_id_in;
               x_address_id_out        := p_address_id_in;
               x_tp_location_code_out  := p_tp_location_code_in;
               x_translator_code_out   := p_translator_code_in;
               x_tp_location_name_out  := p_tp_location_name_in;
               x_address_line1_out     := p_address_line1_in;
               x_address_line2_out     := p_address_line2_in;
               x_address_line3_out     := p_address_line3_in;
               x_address_line4_out     := p_address_line4_in;
               x_address_line_alt_out  := p_address_line_alt_in;
               x_city_out              := p_city_in;
               x_county_out            := p_county_in;
               x_state_out             := p_state_in;
               x_zip_out               := p_zip_in;
               x_province_out          := p_province_in;
               x_country_out           := p_country_in;
               x_region_1_out          := p_region_1_in;
               x_region_2_out          := p_region_2_in;
               x_region_3_out          := p_region_3_in;

               x_return_status := fnd_api.G_RET_STS_SUCCESS;
               x_status_code := G_CANNOT_DERIVE_ADDR_ID;

               GOTO l_end_of_program;
            END IF; -- IF b_use_addr_comp THEN

            x_return_status := fnd_api.G_RET_STS_SUCCESS;
            x_status_code := G_CANNOT_DERIVE_ADDR_ID;

            GOTO l_end_of_program;

         ELSE                                         -- Invalid Parameter
            x_return_status := fnd_api.G_RET_STS_ERROR;
            x_status_code := G_INVALID_PARAMETER;
         END IF;

      <<l_end_of_program>>
      NULL;

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO ece_get_address;
            x_return_status := fnd_api.G_RET_STS_ERROR;

            fnd_msg_pub.COUNT_AND_GET(
               p_count  => x_msg_count,
               p_data   => x_msg_data);

         WHEN OTHERS THEN
            ROLLBACK TO ece_get_address;
            x_status_code := G_UNEXP_ERROR;
            x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

            fnd_msg_pub.COUNT_AND_GET(
               p_count  => x_msg_count,
               p_data   => x_msg_data);

      END ece_get_address;

   /* Function: ece_compare_addresses
      This function takes two addresses in components as parameters and returns TRUE if
      all the components match letter for letter. Case differences or leading and trailing
      spaces are not considered for comparison purposes. (e.g. "New York" and "NEW YORK  "
      are considered identical.) */
   FUNCTION ece_compare_addresses(
      p_address_line1_in         IN    VARCHAR2,
      p_address_line2_in         IN    VARCHAR2,
      p_address_line3_in         IN    VARCHAR2,
      p_address_line4_in         IN    VARCHAR2,
      p_address_line_alt_in      IN    VARCHAR2,
      p_city_in                  IN    VARCHAR2,
      p_county_in                IN    VARCHAR2,
      p_state_in                 IN    VARCHAR2,
      p_zip_in                   IN    VARCHAR2,
      p_province_in              IN    VARCHAR2,
      p_country_in               IN    VARCHAR2,
      p_region_1_in              IN    VARCHAR2,
      p_region_2_in              IN    VARCHAR2,
      p_region_3_in              IN    VARCHAR2,
      p2_address_line1_in        IN    VARCHAR2,
      p2_address_line2_in        IN    VARCHAR2,
      p2_address_line3_in        IN    VARCHAR2,
      p2_address_line4_in        IN    VARCHAR2,
      p2_address_line_alt_in     IN    VARCHAR2,
      p2_city_in                 IN    VARCHAR2,
      p2_county_in               IN    VARCHAR2,
      p2_state_in                IN    VARCHAR2,
      p2_zip_in                  IN    VARCHAR2,
      p2_province_in             IN    VARCHAR2,
      p2_country_in              IN    VARCHAR2,
      p2_region_1_in             IN    VARCHAR2,
      p2_region_2_in             IN    VARCHAR2,
      p2_region_3_in             IN    VARCHAR2) RETURN BOOLEAN IS

      b_match                    BOOLEAN := TRUE;

      BEGIN
      /*   IF scrub(p_address_line1_in) <> scrub(p2_address_line1_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_address_line2_in) <> scrub(p2_address_line2_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_address_line3_in) <> scrub(p2_address_line3_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_address_line4_in) <> scrub(p2_address_line4_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_address_line_alt_in) <> scrub(p2_address_line_alt_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_city_in) <> scrub(p2_city_in) THEN
            b_match := FALSE;
	 END IF;

         ELSIF scrub(p_county_in) <> scrub(p2_county_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_state_in) <> scrub(p2_state_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_zip_in) <> scrub(p2_zip_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_province_in) <> scrub(p2_province_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_country_in) <> scrub(p2_country_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_region_1_in) <> scrub(p2_region_1_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_region_2_in) <> scrub(p2_region_2_in) THEN
            b_match := FALSE;
         ELSIF scrub(p_region_3_in) <> scrub(p2_region_3_in) THEN
            b_match := FALSE;
         ELSE
            b_match := TRUE;
         END IF;*/

         RETURN b_match;
      END ece_compare_addresses;

   /* FUNCTION: scrub
      To facilitate comparison of addresses, this function was created. It takes a VARCHAR2
      value as a parameter and converts it to an uppercase string while removing leading and
      trailing blank spaces. If the parameter is a NULL value, it will return the word
      "NULL VALUE". */
   FUNCTION scrub(
      p_instring VARCHAR2) RETURN VARCHAR2 IS

      BEGIN
         RETURN LTRIM(RTRIM(UPPER(NVL(p_instring,'NULL VALUE'))));
      END scrub;

   PROCEDURE Get_TP_Address
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_translator_code		IN	VARCHAR2,
   p_location_code_ext		IN	VARCHAR2,
   p_info_type			IN	VARCHAR2,
   p_entity_id			OUT NOCOPY	NUMBER,
   p_entity_address_id		OUT NOCOPY	NUMBER
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Get_TP_Address';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_entity_id			NUMBER;
   l_entity_address_id		NUMBER;

cursor ra_add is
       select cas.cust_account_id,
              cas.cust_acct_site_id
        from  hz_cust_acct_sites cas,
	      hz_cust_accounts ca,
	      hz_parties pt,
	      ece_tp_details etd
	where
	      etd.translator_code = p_translator_code
	  and cas.ece_tp_location_code = p_location_code_ext
	  and etd.tp_header_id = cas.tp_header_id
	  and cas.cust_account_id   = ca.cust_account_id
          and ca.party_id = pt.party_id;

cursor po_site is
       select pv.vendor_id, pvs.vendor_site_id
         from po_vendors pv, po_vendor_sites pvs,
--              ece_tp_headers ec,
              ece_tp_details etd
        where
              etd.translator_code = p_translator_code
--          and etd.tp_header_id = ec.tp_header_id
          and pvs.ece_tp_location_code = p_location_code_ext
          and etd.tp_header_id = pvs.tp_header_id
          and pvs.vendor_id = pv.vendor_id;

cursor ap_bank is
       select cbb.branch_party_id
         from ce_bank_branches_v cbb,
              ece_tp_details etd,
              hz_contact_points hcp
        where
              etd.translator_code = p_translator_code
          and hcp.edi_ece_tp_location_code = p_location_code_ext
          and etd.tp_header_id = hcp.edi_tp_header_id
          and hcp.owner_table_id = cbb.branch_party_id
          and hcp.owner_table_name = 'HZ_PARTIES'
          and hcp.contact_point_type  = 'EDI';

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Get_TP_Address_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;


   if ( p_info_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in ra_add
      loop
         l_entity_id := addr.cust_account_id;
         l_entity_address_id := addr.cust_acct_site_id;
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for site in po_site
      loop
         l_entity_id := site.vendor_id;
         l_entity_address_id := site.vendor_site_id;
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for bank in ap_bank
      loop
         l_entity_id := -1;
         l_entity_address_id := bank.branch_party_id;
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_entity_id is NULL
     and l_entity_address_id is NULL
   then
      p_return_status := EC_Trading_Partner_PVT.G_TP_NOT_FOUND;
      fnd_message.set_name('EC','ECE_TP_NOT_FOUND');
      p_msg_data := fnd_message.get;
   else
      p_entity_id := l_entity_id;
      p_entity_address_id := l_entity_address_id;
   end if;


   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Get_TP_Address_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Address_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Address_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Get_TP_Address_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Get_TP_Address;


--  ***********************************************
--	procedure Get_TP_Address_Ref
--
--  Overload this procedure per request from
--  the automotive team
--  ***********************************************
PROCEDURE Get_TP_Address_Ref
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
--   p_translator_code		IN	VARCHAR2,
--   p_location_code_ext		IN	VARCHAR2,
   p_reference_ext1		IN	VARCHAR2,
   p_reference_ext2		IN	VARCHAR2,
   p_info_type			IN	VARCHAR2,
   p_entity_id			OUT NOCOPY	NUMBER,
   p_entity_address_id		OUT NOCOPY	NUMBER
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Get_TP_Address_Ref';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_entity_id			NUMBER;
   l_entity_address_id		NUMBER;

cursor ra_add is
       select cas.cust_account_id,
                         cas.cust_acct_site_id
		  from           hz_cust_acct_sites cas,
		                 hz_cust_accounts ca,
		                 hz_parties pt,
		                 ece_tp_headers eth
                  where
	                eth.tp_reference_ext1 = p_reference_ext1
	            and eth.tp_reference_ext2 = p_reference_ext2
                    and eth.tp_header_id      = cas.tp_header_id
		    and cas.cust_account_id   = ca.cust_account_id
		    and ca.party_id = pt.party_id;

cursor po_site is
       select pv.vendor_id, pvs.vendor_site_id
         from po_vendors pv, po_vendor_sites pvs,
              ece_tp_headers eth
        where
	      eth.tp_reference_ext1 = p_reference_ext1
	  and eth.tp_reference_ext2 = p_reference_ext2
          and eth.tp_header_id = pvs.tp_header_id
          and pvs.vendor_id = pv.vendor_id;

cursor ap_bank is
       select cbb.bank_party_id address_id
         from ce_bank_branches_v cbb,
              ece_tp_headers eth,
              hz_contact_points hcp
        where
	      eth.tp_reference_ext1 = p_reference_ext1
	  and eth.tp_reference_ext2 = p_reference_ext2
          and eth.tp_header_id = hcp.edi_tp_header_id
          and hcp.owner_table_id = cbb.branch_party_id
          and hcp.owner_table_name = 'HZ_PARTIES'
          and hcp.contact_point_type = 'EDI';

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Get_TP_Address_Ref_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
         l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;


   if ( p_info_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in ra_add
      loop
         l_entity_id := addr.cust_account_id;
         l_entity_address_id := addr.cust_acct_site_id;
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for site in po_site
      loop
         l_entity_id := site.vendor_id;
         l_entity_address_id := site.vendor_site_id;
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for bank in ap_bank
      loop
         l_entity_id := -1;
         l_entity_address_id := bank.address_id;
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_entity_id is NULL
     and l_entity_address_id is NULL
   then
      p_return_status := EC_Trading_Partner_PVT.G_TP_NOT_FOUND;
      fnd_message.set_name('EC','ECE_TP_NOT_FOUND');
      p_msg_data := fnd_message.get;
   else
      p_entity_id := l_entity_id;
      p_entity_address_id := l_entity_address_id;
   end if;

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Get_TP_Address_Ref_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Address_Ref_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Address_Ref_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Get_TP_Address_Ref_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Get_TP_Address_Ref;

--  ***********************************************
--	procedure Get_TP_Location_Code
--  ***********************************************
PROCEDURE Get_TP_Location_Code
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_entity_address_id		IN	NUMBER,
   p_info_type			IN	VARCHAR2,
   p_location_code_ext		OUT NOCOPY	VARCHAR2,
   p_reference_ext1		OUT NOCOPY	VARCHAR2,
   p_reference_ext2		OUT NOCOPY	VARCHAR2
)
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'Get_TP_Location_Code';
   l_api_version_number	CONSTANT NUMBER	      := 1.0;
   l_return_status		 VARCHAR2(10);

   l_location_code_ext		VARCHAR2(50);

cursor ra_add is
                 select
                  cas.ece_tp_location_code,
                  ec.tp_reference_ext1,
                  ec.tp_reference_ext2
		  from           hz_cust_acct_sites cas,
		                 ece_tp_headers ec
                  where

                      ec.tp_header_id      = cas.tp_header_id
		  and cas.cust_acct_site_id = p_entity_address_id;


cursor po_site is
        select pvs.ece_tp_location_code,
	       ec.tp_reference_ext1,
	       ec.tp_reference_ext2
          from ece_tp_headers ec, po_vendor_sites pvs
         where
               pvs.vendor_site_id = p_entity_address_id
           and pvs.tp_header_id = ec.tp_header_id;

cursor ap_bank is
        select hcp.edi_ece_tp_location_code,
	       ec.tp_reference_ext1,
	       ec.tp_reference_ext2
          from ece_tp_headers ec, ce_bank_branches_v cbb,
               hz_contact_points hcp
         where
               cbb.branch_party_id = p_entity_address_id
           and hcp.edi_tp_header_id = ec.tp_header_id
           and hcp.owner_table_id = cbb.branch_party_id
           and hcp.owner_table_name = 'HZ_PARTIES'
           and hcp.contact_point_type = 'EDI';

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT Get_TP_Location_Code_PVT;

   -- Standard call to check for call compatibility.

   if NOT FND_API.Compatible_API_Call
   (
	l_api_version_number,
	p_api_version_number,
	l_api_name,
	G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success

   p_return_status := FND_API.G_RET_STS_SUCCESS;


   if ( p_info_type = EC_Trading_Partner_PVT.G_CUSTOMER)
   then
      for addr in ra_add loop
         l_location_code_ext := addr.ece_tp_location_code;
         p_reference_ext1 := addr.tp_reference_ext1;
         p_reference_ext2 := addr.tp_reference_ext2;
      end loop;


   elsif (p_info_type = EC_Trading_Partner_PVT.G_SUPPLIER)
   then
      for site in po_site loop
         l_location_code_ext := site.ece_tp_location_code;
         p_reference_ext1 := site.tp_reference_ext1;
         p_reference_ext2 := site.tp_reference_ext2;
      end loop;

   elsif (p_info_type = EC_Trading_Partner_PVT.G_BANK)
   then
      for bank in ap_bank loop
         l_location_code_ext := bank.edi_ece_tp_location_code;
         p_reference_ext1 := bank.tp_reference_ext1;
         p_reference_ext2 := bank.tp_reference_ext2;
      end loop;
   else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_location_code_ext is NULL
   then
      p_return_status := EC_Trading_Partner_PVT.G_TP_NOT_FOUND;
      fnd_message.set_name('EC','ECE_TP_NOT_FOUND');
      p_msg_data := fnd_message.get;
   else
      p_location_code_ext := l_location_code_ext;
   end if;

   -- Both G_EXC_ERROR and G_EXC_UNEXPECTED_ERROR are handled in
   -- the API exception handler.

   if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   then

   -- Unexpected error, abort processing.

      raise FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_return_status = FND_API.G_RET_STS_ERROR THEN

   -- Error, abort processing

      raise FND_API.G_EXC_ERROR;

   end if;

   -- Standard check of p_simulate and p_commit parameters

   if FND_API.To_Boolean( p_simulate)
   then
      ROLLBACK to Get_TP_Location_Code_PVT;

   elsif FND_API.To_Boolean( p_commit)
   then
      commit work;
   end if;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
   (
      p_count		=> p_msg_count,
      p_data		=> p_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

   WHEN OTHERS THEN

      Rollback to Get_TP_Location_Code_PVT;
      p_return_status := FND_API.G_RET_STS_ERROR;

      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_FILE_NAME,
            G_PKG_NAME,
            l_api_name
         );
      end if;

      FND_MSG_PUB.Count_And_Get
      (
         p_count		=> p_msg_count,
         p_data			=> p_msg_data
      );

end Get_TP_Location_Code;

END ece_trading_partners_pub;


/
