--------------------------------------------------------
--  DDL for Package AP_VENDOR_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_VENDOR_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: apvdmrgs.pls 120.2.12010000.4 2011/06/13 06:00:25 kpasikan ship $ */

-- Bug 5641382. Added the default parameter.
PROCEDURE Other_Products_VendorMerge(v_dup_vendor_id IN NUMBER DEFAULT NULL,
                                     v_dup_vendor_site_id IN NUMBER DEFAULT NULL);   /* for bug 9501188 */

-- Bug 7297864. introduced to resolve contact disappearing issue after supplier merge.
PROCEDURE AP_TCA_Contact_Merge (
p_from_party_site_id           IN  NUMBER,
p_to_party_site_id             IN  NUMBER,
p_from_per_party_id	       IN  NUMBER,
p_to_org_party_id	       IN  NUMBER,
x_return_status                OUT NOCOPY VARCHAR2,
x_msg_count		       OUT NOCOPY NUMBER,
x_msg_data		       OUT NOCOPY VARCHAR2,
p_create_partysite_cont_pts    IN  VARCHAR2 DEFAULT 'N' --bug12571995
);

END AP_VENDOR_PARTY_MERGE_PKG;

/
