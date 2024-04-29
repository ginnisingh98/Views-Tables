--------------------------------------------------------
--  DDL for Package Body PO_VENDORS_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORS_AP_PKG" AS
/* $Header: povendrb.pls 120.2.12010000.2 2009/10/12 08:35:08 sjetti ship $ */

     -----------------------------------------------------------------------
     -- Function get_num_active_pay_sites returns the number of active
     -- pay sites for a particular vendor
     --
     FUNCTION get_num_active_pay_sites(X_vendor_id IN NUMBER,
                                       X_ORG_ID IN NUMBER )
         RETURN NUMBER
     IS
         num_active NUMBER;

     BEGIN

       -- Bug 8674710 - Added the join to HZ_PARTY_SITES as site should be
       -- inactive when the Address is inactive.

         SELECT count(pvs.vendor_site_id)
         INTO   num_active
	     FROM   ap_supplier_sites pvs,
                hz_party_sites H,
                ap_suppliers pv
         WHERE  pvs.vendor_id = X_vendor_id
         AND    (( X_ORG_ID IS NOT NULL AND
                   pvs.org_id = X_ORG_ID)
                   OR X_ORG_ID IS NULL)
         AND    pvs.pay_site_flag = 'Y'
         AND    nvl(pvs.inactive_date, sysdate+1) > sysdate
         AND H.party_site_id (+) = pvs.party_site_id
         AND PV.vendor_id = pvs.vendor_id
         AND DECODE(PV.vendor_type_lookup_code,'EMPLOYEE', 'A',NVL(H.status, 'I')) = ('A')
         GROUP BY pvs.vendor_id;

         RETURN(num_active);

     EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(0);
     END get_num_active_pay_sites;


     -----------------------------------------------------------------------
     -- Function get_num_inactive_pay_sites returns the number of active
     -- pay sites for a particular vendor
     --
     FUNCTION get_num_inactive_pay_sites(X_vendor_id IN NUMBER,
                                         X_ORG_ID IN NUMBER )
         RETURN NUMBER
     IS
         num_inactive NUMBER;

     BEGIN


         SELECT count(*)
         INTO   num_inactive
	 FROM   ap_supplier_sites pvs
         WHERE  pvs.vendor_id = X_vendor_id
         AND    (( X_ORG_ID IS NOT NULL AND
                   pvs.org_id = X_ORG_ID)
                   OR X_ORG_ID IS NULL)
         AND    pvs.pay_site_flag = 'Y'
         AND    nvl(pvs.inactive_date, sysdate+1) < sysdate
         GROUP BY pvs.vendor_id;

         RETURN(num_inactive);

     EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(0);
     END get_num_inactive_pay_sites;


END PO_VENDORS_AP_PKG;

/
