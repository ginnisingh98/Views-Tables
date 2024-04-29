--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_UTIL_PKG" AS
-- $Header: igiputlb.pls 120.2.12010000.5 2015/01/20 07:22:00 aarsridh ship $

    /*
    * Type: Procedure
    * Access: Public API
    *
    * Description: This function calls the certificate insertion logic
    * for the supplier if CIS is enabled
    *
    * Note: This procedure is called from package AP_VENDORS_PKG (apvndhrb.pls)
    * Care should be taken while modifying this package
    */
    PROCEDURE SUPPLIER_UPDATE(
        p_vendor_id IN ap_suppliers.vendor_id%TYPE,
        p_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE,
        p_pay_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE	     /* Bug 7218825 */
    )
    IS
        l_cis_installed number;
    BEGIN
        l_cis_installed := 0;
        BEGIN
            SELECT count(1)
            INTO l_cis_installed
            FROM   igi_gcc_inst_options_all
            WHERE  option_name = 'CIS'
             AND status_flag = 'Y';
        EXCEPTION
            WHEN OTHERS THEN
                l_cis_installed := 0;
        END;
        IF l_cis_installed > 0 THEN
            IGI_CIS2007_TAX_EFF_DATE.main (
                 p_vendor_id      => p_vendor_id,
                 p_vendor_site_id => NULL,
                 p_tax_grp_id     => p_tax_grp_id,
                 p_pay_tax_grp_id => p_pay_tax_grp_id, 	                 /* Bug 7218825 */
                 p_source         => 'VENDOR FORM',
                 p_effective_date => sysdate
                );
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;


    /*
    * Type: Procedure
    * Access: Public API
    *
    * Description: This function calls the certificate insertion logic
    * for supplier site if CIS is enabled
    *
    * Note: This procedure is called from package AP_VENDOR_SITES_PKG (apvndsib.pls)
    * Care should be taken while modifying this package
    */
    PROCEDURE SUPPLIER_SITE_UPDATE(
        p_vendor_id IN ap_suppliers.vendor_id%TYPE,
        p_vendor_site_id IN ap_supplier_sites_all.vendor_site_id%TYPE,
        p_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE,
        p_pay_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE	   /* Bug 7218825 */
    )
    IS
    BEGIN
    IF igi_gen.is_req_installed('CIS',mo_global.get_current_org_id) = 'Y' THEN
            IGI_CIS2007_TAX_EFF_DATE.main (
             p_vendor_id      => p_vendor_id,
             p_vendor_site_id => p_vendor_site_id,
             p_tax_grp_id     => p_tax_grp_id,
             p_pay_tax_grp_id => p_pay_tax_grp_id,                   	  /* Bug 7218825 */
             p_source         => 'VENDOR SITE FORM',
             p_effective_date => sysdate
            );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

/* This Function Added for CIS Bug 7218825 */

  FUNCTION get_payables_option_based_awt(l_vendor_id NUMBER,l_vendor_site_id NUMBER,l_tax_grp_id NUMBER,l_pay_tax_grp_id NUMBER)
  RETURN NUMBER IS

	l_org_id                  ap_supplier_sites_all.org_id%TYPE;
      l_awt_group_id_po    	  ap_suppliers.awt_group_id%TYPE;
      l_pay_awt_group_id_po	  ap_suppliers.pay_awt_group_id%TYPE;
      l_awt_group_id_pvs	  ap_supplier_sites_all.awt_group_id%TYPE;
      l_pay_awt_group_id_pvs	  ap_supplier_sites_all.pay_awt_group_id%TYPE;
	l_create_awt_dists_type   ap_system_parameters_all.CREATE_AWT_DISTS_TYPE%TYPE;
        l_return_value NUMBER(15);

  BEGIN
	l_return_value := NULL;

     IF (l_vendor_id IS NOT NULL) AND (l_vendor_site_id IS NOT NULL) THEN       /* FOR VENDOR SITE */

         IF  (l_tax_grp_id IS NULL) and (l_pay_tax_grp_id IS NULL) THEN

	        select org_id,awt_group_id,pay_awt_group_id
	        into   l_org_id,l_awt_group_id_pvs,l_pay_awt_group_id_pvs
	        from ap_supplier_sites_all
	        where
	        vendor_id = l_vendor_id and
	        vendor_site_id = l_vendor_site_id and
              upper(allow_awt_flag) = 'Y';

		  select CREATE_AWT_DISTS_TYPE
	        into l_create_awt_dists_type
	 	  from ap_system_parameters_all
		  where
	        org_id = l_org_id  and
              upper(allow_awt_flag) = 'Y';

	        If l_create_awt_dists_type = 'APPROVAL'
	        then
	          l_return_value := l_awt_group_id_pvs;
	        elsif  l_create_awt_dists_type = 'PAYMENT'
	        then
	          l_return_value := l_pay_awt_group_id_pvs;
	        elsif  l_create_awt_dists_type = 'BOTH'
	        then
	          l_return_value := NULL;
	        else
	          l_return_value := NULL;
	        end if;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NULL) THEN

               l_return_value := l_tax_grp_id;

          ELSIF (l_tax_grp_id IS NULL) and (l_pay_tax_grp_id IS NOT NULL) THEN

               l_return_value := l_pay_tax_grp_id;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NOT NULL) AND
     	          (l_tax_grp_id  = l_pay_tax_grp_id) THEN

               l_return_value := l_tax_grp_id;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NOT NULL) AND
     	          (l_tax_grp_id  <> l_pay_tax_grp_id) THEN

               l_return_value := NULL;

          END IF;


     END IF;         /* FOR VENDOR SITE */

     IF (l_vendor_id IS NOT NULL) AND (l_vendor_site_id IS NULL) THEN                      /* FOR VENDOR */

          IF  (l_tax_grp_id IS NULL) and (l_pay_tax_grp_id IS NULL) THEN

		  select awt_group_id,pay_awt_group_id
	        into   l_awt_group_id_po,l_pay_awt_group_id_po
		  from ap_suppliers
	        where
              vendor_id = l_vendor_id;

	        If (l_awt_group_id_po IS NOT NULL) and (l_pay_awt_group_id_po IS NOT NULL) and
	           (l_awt_group_id_po  = l_pay_awt_group_id_po)
	        then
		     l_return_value := l_awt_group_id_po;
	        elsif  (l_awt_group_id_po IS NOT NULL) and (l_pay_awt_group_id_po IS NOT NULL) and
	               (l_awt_group_id_po  <> l_pay_awt_group_id_po)
	        then
	           l_return_value := NULL;
	        elsif  (l_awt_group_id_po IS NOT NULL) and (l_pay_awt_group_id_po IS NULL)
	        then
	           l_return_value := l_awt_group_id_po;
	        elsif  (l_awt_group_id_po IS NULL) and (l_pay_awt_group_id_po IS NOT NULL)
	        then
	           l_return_value := l_pay_awt_group_id_po;
	        end if;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NULL) THEN

               l_return_value := l_tax_grp_id;

          ELSIF (l_tax_grp_id IS NULL) and (l_pay_tax_grp_id IS NOT NULL) THEN

               l_return_value := l_pay_tax_grp_id;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NOT NULL) AND
     	          (l_tax_grp_id  = l_pay_tax_grp_id) THEN

               l_return_value := l_tax_grp_id;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NOT NULL) AND
     	          (l_tax_grp_id  <> l_pay_tax_grp_id) THEN

               l_return_value := NULL;

          END IF;

     END IF;              /* FOR VENDOR */

     IF (l_vendor_id IS NULL) AND (l_vendor_site_id IS NULL) THEN                      /* FOR INVOICE AND PAY TAX GROUP IDS */

          IF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NULL) THEN

               l_return_value := l_tax_grp_id;

          ELSIF (l_tax_grp_id IS NULL) and (l_pay_tax_grp_id IS NOT NULL) THEN

               l_return_value := l_pay_tax_grp_id;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NOT NULL) AND
     	          (l_tax_grp_id  = l_pay_tax_grp_id) THEN

               l_return_value := l_tax_grp_id;

          ELSIF (l_tax_grp_id IS NOT NULL) and (l_pay_tax_grp_id IS NOT NULL) AND
     	          (l_tax_grp_id  <> l_pay_tax_grp_id) THEN

               l_return_value := NULL;

          ELSIF (l_tax_grp_id IS NULL) and (l_pay_tax_grp_id IS  NULL) THEN

               l_return_value := NULL;


          END IF;

     END IF;              /* FOR INVOICE AND PAY TAX GROUP IDS */

	return l_return_value;

  END;

END IGI_CIS2007_UTIL_PKG;


/
