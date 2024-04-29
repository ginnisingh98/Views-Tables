--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_TAX_EFF_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_TAX_EFF_DATE" AS
  -- $Header: igiefdtb.pls 120.1.12010000.2 2008/12/19 12:58:32 gaprasad ship $
  PROCEDURE main(p_vendor_id IN ap_suppliers.vendor_id%TYPE
            ,   p_vendor_site_id IN ap_supplier_sites_all.vendor_site_id%TYPE
            ,   p_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE
	    ,   p_pay_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE          /* Bug 7218825 */
            ,   p_source IN VARCHAR2
            ,   p_effective_date IN DATE) IS

  -- c_vendor_sites is the cursor which is used
  -- to get all the vendor site of a vendor
  -- when the vendor is null it fetches all the vendor's sites
  -- check for the vendor to be cis_enabled = 'y'
  -- and the vendor_site has allow_awt_flag = 'y'
  CURSOR c_vendor_sites(p_vendor_id ap_suppliers.vendor_id%TYPE
  ,   p_vendor_site_id ap_supplier_sites_all.vendor_site_id%TYPE) IS
  SELECT pov.vendor_id,
    povs.vendor_site_id,
    povs.org_id
  FROM ap_supplier_sites_all povs,
    ap_suppliers pov
  WHERE pov.vendor_id = p_vendor_id
   AND pov.vendor_id = povs.vendor_id
   AND povs.vendor_site_id = nvl(p_vendor_site_id,   povs.vendor_site_id)
   AND pov.cis_enabled_flag = 'Y'
   AND pov.allow_awt_flag = 'Y'
   AND povs.allow_awt_flag = 'Y'
   AND org_id IS NOT NULL;

  -- c_new_tax_rate will be used to get the new rate for the tax_group_id and org
  CURSOR c_new_tax_rate(p_tax_group_id ap_awt_group_taxes.group_id%TYPE
        ,   p_org_id ap_awt_group_taxes.org_id%TYPE) IS
  SELECT atr.tax_rate new_tax_rate
  FROM ap_tax_codes_all atc,
    ap_awt_group_taxes_all agt,
    ap_awt_tax_rates_all atr
  WHERE agt.group_id = p_tax_group_id
   AND agt.tax_name = atc.name
   AND atc.name = atr.tax_name
   AND atc.tax_type = 'AWT'
   AND atr.rate_type = 'STANDARD'
   AND(sysdate BETWEEN nvl(atr.start_date,   sysdate -1)
   AND nvl(atr.end_date,   sysdate + 1))
   AND atc.org_id = agt.org_id
   AND atr.org_id = agt.org_id
   AND atr.org_id = p_org_id
  ORDER BY agt.group_id,
    atr.tax_rate;

  CURSOR c_tax_names(p_vendor_id ap_suppliers.vendor_id%TYPE
        ,   p_vendor_site_id ap_supplier_sites_all.vendor_site_id%TYPE
        ,   p_org_id ap_supplier_sites_all.org_id%TYPE) IS
  SELECT DISTINCT tax_name
  FROM ap_awt_tax_rates_all
  WHERE vendor_id = p_vendor_id
   AND vendor_site_id = p_vendor_site_id
   AND org_id = p_org_id
   AND priority = 1;

  --Cursor Variables
  lcr_vendor_site c_vendor_sites % rowtype;
  lcr_tax_name c_tax_names % rowtype;

  --Local Variables
  l_new_tax_rate ap_awt_tax_rates_all.tax_rate%TYPE;
  l_new_tax_rate_id ap_awt_tax_rates.tax_rate_id%TYPE;
  l_old_tax_grp_name ap_awt_groups.name%TYPE;
  l_new_tax_grp_name ap_awt_groups.name%TYPE;
  l_old_tax_name ap_tax_codes_all.name%TYPE;
  l_update_flag VARCHAR2(2);
  l_tax_name_exists_flag boolean;
  l_start_date DATE;
  l_update_date DATE;
  l_old_tax_grp_id ap_awt_group_taxes_all.group_id%TYPE;
  l_site_old_tax_grp_id ap_awt_group_taxes_all.group_id%TYPE;

  l_tax_grp_id  ap_awt_group_taxes_all.group_id%TYPE;          /* Bug 7218825 */

  BEGIN

    l_tax_grp_id := IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(p_vendor_id,p_vendor_site_id,p_tax_grp_id,p_pay_tax_grp_id);      /* Bug 7218825 */

    --Check for repeated call, if exists return
    IF(g_old_p_vendor_id = p_vendor_id
     AND g_old_p_vendor_site_id = p_vendor_site_id
     AND g_old_p_tax_grp_id = l_tax_grp_id                               /* Bug 7218825 */
     AND g_old_p_source = p_source
     AND g_old_p_effective_date = p_effective_date) THEN
      RETURN;
    END IF;

    g_old_p_vendor_id := p_vendor_id;
    g_old_p_vendor_site_id := p_vendor_site_id;
    g_old_p_tax_grp_id := l_tax_grp_id;                                  /* Bug 7218825 */
    g_old_p_source := p_source;
    g_old_p_effective_date := p_effective_date;

    --Loop for the vendor sites
    FOR lcr_vendor_site IN c_vendor_sites(p_vendor_id,   p_vendor_site_id)
    LOOP --Start of Vendor Sites Loop
    BEGIN

      l_tax_grp_id := IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(lcr_vendor_site.vendor_id,lcr_vendor_site.vendor_site_id,p_tax_grp_id,p_pay_tax_grp_id);      /* Bug 7218825 */

      --Get the new tax rate id for the vendor and vendor site
      OPEN c_new_tax_rate(l_tax_grp_id,   lcr_vendor_site.org_id);                        /* Bug 7218825 */
      FETCH c_new_tax_rate
      INTO l_new_tax_rate;
      CLOSE c_new_tax_rate;

      BEGIN

        --Fetch the old tax group id for the vendor or vendor site
        SELECT decode(p_source,   'VENDOR SITE FORM',   IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(po_site.vendor_id,po_site.vendor_site_id, po_site.awt_group_id, po_site.pay_awt_group_id)
                              ,   'VENDOR FORM',   IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(po.vendor_id,NULL,po.awt_group_id,po.pay_awt_group_id)
                              ,   'CDROM',   IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(po.vendor_id,NULL,po.awt_group_id,po.pay_awt_group_id)
                              ,   'VERIFY',   IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(po.vendor_id,NULL,po.awt_group_id,po.pay_awt_group_id))
        INTO l_old_tax_grp_id
        FROM ap_suppliers po,
          ap_supplier_sites_all po_site
        WHERE po.vendor_id = p_vendor_id
         AND po_site.vendor_id = po.vendor_id
         AND po_site.allow_awt_flag = 'Y'
         AND po_site.vendor_site_id = nvl(p_vendor_site_id,   lcr_vendor_site.vendor_site_id)
         AND org_id = lcr_vendor_site.org_id;

      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;

      --Fetch the old tax group id for the vendor site
      BEGIN
        SELECT IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(po_site.vendor_id,po_site.vendor_site_id, po_site.awt_group_id, po_site.pay_awt_group_id)
        INTO l_site_old_tax_grp_id
        FROM ap_suppliers po,
          ap_supplier_sites_all po_site
        WHERE po.vendor_id = p_vendor_id
         AND po_site.vendor_id = po.vendor_id
         AND po_site.allow_awt_flag = 'Y'
         AND po_site.vendor_site_id = nvl(p_vendor_site_id,   lcr_vendor_site.vendor_site_id)
         AND org_id = lcr_vendor_site.org_id;

      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;

      --Fetch the old tax name
      BEGIN
        SELECT atc.name tax_name
        INTO l_old_tax_name
        FROM ap_awt_group_taxes_all agt,
          ap_tax_codes_all atc
        WHERE agt.group_id = nvl(l_site_old_tax_grp_id,   l_old_tax_grp_id)
         AND atc.tax_type = 'AWT'
         AND agt.tax_name = atc.name
         AND sysdate <= nvl(atc.inactive_date,   sysdate + 1)
         AND atc.org_id = agt.org_id
         AND atc.org_id = lcr_vendor_site.org_id;

      EXCEPTION
      WHEN others THEN
        l_old_tax_name := NULL;
      END;

      -- Check whether the old tax group id at site level is same as the new
      -- tax group id for source as CDROM or VERIFY
      -- If they are same, set the update flag to FALSE. Otherwise, set the
      -- update flag to TRUE
      IF(p_source = 'CDROM' OR p_source = 'VERIFY') --Start of UPDATE If
       AND(l_tax_grp_id IS NOT NULL)                                               /* Bug 7218825 */
       AND(l_site_old_tax_grp_id IS NOT NULL)
       AND(l_site_old_tax_grp_id = l_tax_grp_id) THEN                             /* Bug 7218825 */
        l_update_flag := 'F';
      ELSE
        l_update_flag := 'T';
      END IF;

      -- When l_old_tax_name is Null, then there is an issue with the setup
      -- Tax Code exists, but tax name is not defined for that particular org
      -- In such a case, set l_update_flag to False
      IF l_old_tax_name is NULL and l_update_flag = 'T' THEN
        l_update_flag := 'F';
      END IF;

      -- Call from AP package happens every time Vendor or Vendor Site information
      -- is updated. The following code ensures that insertion happens only
      -- when the Withholding tax is changed and not otherwise
      IF p_source = 'VENDOR SITE FORM'
         AND l_site_old_tax_grp_id IS NOT NULL
         AND l_site_old_tax_grp_id = l_tax_grp_id                               /* Bug 7218825 */
         AND l_update_flag = 'T' THEN
         l_update_flag := 'F';
      END IF;

      -- Call from AP package happens every time Vendor or Vendor Site information
      -- is updated. The following code ensures that insertion happens only
      -- when the Withholding tax is changed and not otherwise
      IF p_source = 'VENDOR FORM'
         AND l_old_tax_grp_id IS NOT NULL
         AND l_old_tax_grp_id = l_tax_grp_id                                  /* Bug 7218825 */
         AND l_update_flag = 'T' THEN
         l_update_flag := 'F';
      END IF;

      IF(l_new_tax_rate IS NOT NULL
       AND(l_site_old_tax_grp_id IS NOT NULL OR(l_site_old_tax_grp_id IS NULL AND p_source <> 'VENDOR SITE FORM'))
       AND l_update_flag = 'T') THEN

        --Initialize the l_tax_name_exists_flag
        l_tax_name_exists_flag := FALSE;

        --For each tax names in ap_awt_tax_rates_all do the following
        --1. Increment the priority of all records wit the current the tax name
        --2. End date the tax name based on the following rules
        --   A. If the start date is greater than p_effective_date then set the
        --      end date of the record as the start date
        --   B. If the start date is lesser or equal to p_effective_date then set
        --      the end date of the record as p_effective_date
        FOR lcr_tax_names IN c_tax_names(lcr_vendor_site.vendor_id
                                    ,   lcr_vendor_site.vendor_site_id
                                    ,   lcr_vendor_site.org_id)
        LOOP -- Start of c_tax_names loop
          BEGIN
          --Increment the priority of all records with the current tax name
          UPDATE ap_awt_tax_rates_all
          SET priority = priority + 1
          WHERE vendor_id = lcr_vendor_site.vendor_id
           AND vendor_site_id = lcr_vendor_site.vendor_site_id
           AND org_id = lcr_vendor_site.org_id
           AND tax_name = lcr_tax_names.tax_name;

          --Fetch the start date of the record which has the current tax name and
          --is of priority 2
          BEGIN
            SELECT start_date
            INTO l_start_date
            FROM ap_awt_tax_rates_all
            WHERE vendor_id = lcr_vendor_site.vendor_id
             AND vendor_site_id = lcr_vendor_site.vendor_site_id
             AND org_id = lcr_vendor_site.org_id
             AND tax_name = lcr_tax_names.tax_name
             AND priority = 2;

          EXCEPTION
          WHEN others THEN
            l_start_date := p_effective_date;
          END;

          --End date the tax name based on the following rules
          --  A. If the start date is greater than p_effective_date then set
          --     l_update_date as l_start_date
          --  B. If the start date is lesser or equal to p_effective_date then
          --     set l_update_date as p_effective_date
          IF l_start_date > p_effective_date THEN
            l_update_date := l_start_date;
          ELSE
            l_update_date := p_effective_date;
          END IF;

          --End date the record which has the current tax name and is of
          --priority 2
          UPDATE ap_awt_tax_rates_all
          SET end_date = l_update_date
          WHERE vendor_id = lcr_vendor_site.vendor_id
           AND vendor_site_id = lcr_vendor_site.vendor_site_id
           AND org_id = lcr_vendor_site.org_id
           AND tax_name = lcr_tax_names.tax_name
           AND priority = 2;

          --Fetch a new tax rate id from the sequence
          SELECT ap_awt_tax_rates_s.nextval
          INTO l_new_tax_rate_id
          FROM dual;

          --If a record corrosponding to the old tax name already exists then
          --set the l_tax_name_exists_flag flag to true
          IF l_old_tax_name = lcr_tax_names.tax_name THEN
            l_tax_name_exists_flag := TRUE;
          END IF;

          --Insert a new record for the current tax name with priority 1
          --Records of priority 1 will have end date as NULL
          INSERT
          INTO ap_awt_tax_rates_all(tax_rate_id
                                ,   tax_name
                                ,   tax_rate
                                ,   rate_type
                                ,   start_date
                                ,   vendor_id
                                ,   vendor_site_id
                                ,   certificate_number
                                ,   certificate_type
                                ,   comments
                                ,   priority
                                ,   org_id
                                ,   last_update_date
                                ,   last_updated_by
                                ,   last_update_login
                                ,   creation_date
                                ,   created_by)
          VALUES(l_new_tax_rate_id                             --tax_rate_id
          ,   lcr_tax_names.tax_name                           --tax_name
          ,   l_new_tax_rate                                   --tax_rate
          ,   'CERTIFICATE'                                    --rate_type
          ,   TRUNC(p_effective_date)                          --start_date
          ,   lcr_vendor_site.vendor_id                        --vendor_id
          ,   lcr_vendor_site.vendor_site_id                   --vendor_site_id
          ,   'CERT'                                           --certificate_number
          ,   'STANDARD'                                       --certificate_type
          ,   initcap(p_source || ' - Tax Treatment Change')   --comments
          ,   1                                                --priority
          ,   lcr_vendor_site.org_id                           --org_id
          ,   sysdate                                          --last_update_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --last_update_by
          ,   nvl(fnd_profile.VALUE('LAST_UPDATE_LOGIN'),   0) --last_update_login
          ,   sysdate                                          --creation_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --created_by
          );

          --Insert a corrosponding row in the history table
          INSERT
          INTO igi_cis_tax_treatment_h(vendor_id
                                   ,   vendor_site_id
                                   ,   tax_rate_id
                                   ,   old_group_id
                                   ,   new_group_id
                                   ,   effective_date
                                   ,   source_name
                                   ,   last_update_date
                                   ,   last_updated_by
                                   ,   last_update_login
                                   ,   creation_date
                                   ,   created_by
                                   ,   request_id
                                   ,   program_id
                                   ,   program_application_id
                                   ,   program_login_id)
          VALUES(lcr_vendor_site.vendor_id                     --vendor_id
          ,   lcr_vendor_site.vendor_site_id                   --vendor_site_id
          ,   l_new_tax_rate_id                                --tax_rate_id
          ,   nvl(l_site_old_tax_grp_id,   l_old_tax_grp_id)   --old_group_id
          ,   l_tax_grp_id                                     --new_group_id                             /* Bug 7218825 */
          ,   p_effective_date                                 --effective_date
          ,   p_source                                         --source_name
          ,   sysdate                                          --last_update_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --last_update_by
          ,   nvl(fnd_profile.VALUE('LAST_UPDATE_LOGIN'),   0) --last_update_login
          ,   sysdate                                          --creation_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --created_by
          ,   fnd_global.conc_request_id                       --request_id
          ,   fnd_global.conc_program_id                       --program_id
          ,   fnd_global.prog_appl_id                          --program_application_id
          ,   fnd_global.conc_login_id);                       --program_login_id

        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        END LOOP; -- End of c_tax_names loop

        --A record for l_old_tax_name does not exists. Insert this record
        IF l_tax_name_exists_flag = FALSE THEN  --Start of l_tax_name_exists_flag IF

          SELECT ap_awt_tax_rates_s.nextval
          INTO l_new_tax_rate_id
          FROM dual;

          --Insert a new record for the l_old_tax_name with priority 1
          --Records of priority 1 will have end date as NULL
          INSERT
          INTO ap_awt_tax_rates_all(tax_rate_id
                                ,   tax_name
                                ,   tax_rate
                                ,   rate_type
                                ,   start_date
                                ,   vendor_id
                                ,   vendor_site_id
                                ,   certificate_number
                                ,   certificate_type
                                ,   comments
                                ,   priority
                                ,   org_id
                                ,   last_update_date
                                ,   last_updated_by
                                ,   last_update_login
                                ,   creation_date
                                ,   created_by)
          VALUES(l_new_tax_rate_id                             --tax_rate_id
          ,   l_old_tax_name                                   --tax_name
          ,   l_new_tax_rate                                   --tax_rate
          ,   'CERTIFICATE'                                    --rate_type
          ,   TRUNC(p_effective_date)                          --start_date
          ,   lcr_vendor_site.vendor_id                        --vendor_id
          ,   lcr_vendor_site.vendor_site_id                   --vendor_site_id
          ,   'CERT'                                           --certificate_number
          ,   'STANDARD'                                       --certificate_type
          ,   initcap(p_source || ' - Tax Treatment Change')   --comments
          ,   1                                                --priority
          ,   lcr_vendor_site.org_id                           --org_id
          ,   sysdate                                          --last_update_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --last_update_by
          ,   nvl(fnd_profile.VALUE('LAST_UPDATE_LOGIN'),   0) --last_update_login
          ,   sysdate                                          --creation_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --created_by
          );

          --Insert a corrosponding row in the history table
          INSERT
          INTO igi_cis_tax_treatment_h(vendor_id
                                   ,   vendor_site_id
                                   ,   tax_rate_id
                                   ,   old_group_id
                                   ,   new_group_id
                                   ,   effective_date
                                   ,   source_name
                                   ,   last_update_date
                                   ,   last_updated_by
                                   ,   last_update_login
                                   ,   creation_date
                                   ,   created_by
                                   ,   request_id
                                   ,   program_id
                                   ,   program_application_id
                                   ,   program_login_id)
          VALUES(lcr_vendor_site.vendor_id                     --vendor_id
          ,   lcr_vendor_site.vendor_site_id                   --vendor_site_id
          ,   l_new_tax_rate_id                                --tax_rate_id
          ,   nvl(l_site_old_tax_grp_id,   l_old_tax_grp_id)   --old_group_id
          ,   l_tax_grp_id                                     --new_group_id                             /* Bug 7218825 */
          ,   p_effective_date                                 --effective_date
          ,   p_source                                         --source_name
          ,   sysdate                                          --last_update_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --last_update_by
          ,   nvl(fnd_profile.VALUE('LAST_UPDATE_LOGIN'),   0) --last_update_login
          ,   sysdate                                          --creation_date
          ,   nvl(fnd_profile.VALUE('USER_ID'),   0)           --created_by
          ,   fnd_global.conc_request_id                       --request_id
          ,   fnd_global.conc_program_id                       --program_id
          ,   fnd_global.prog_appl_id                          --program_application_id
          ,   fnd_global.conc_login_id);                       --program_login_id
        END IF; --END of l_tax_name_exists_flag IF

      END IF; --Start of UPDATE If
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    END LOOP; --End of Vendor Sites Loop

  EXCEPTION
  WHEN others THEN
    NULL;
  END main;

  PROCEDURE set_eff_date(p_eff_date DATE) IS
  BEGIN
    global_eff_date := p_eff_date;
  END;

  FUNCTION get_eff_date RETURN DATE IS
  BEGIN
    RETURN global_eff_date;
  END;

END igi_cis2007_tax_eff_date;


/
