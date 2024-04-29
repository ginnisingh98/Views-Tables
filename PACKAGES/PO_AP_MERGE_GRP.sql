--------------------------------------------------------
--  DDL for Package PO_AP_MERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_MERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXPVENS.pls 115.1 2002/11/20 02:28:51 dreddy noship $ */


PROCEDURE validate_merge
(
    p_api_version    IN         NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    p_from_vendor_id IN         PO_VENDORS.vendor_id%TYPE,
    p_from_site_id   IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE,
    p_to_vendor_id   IN         PO_VENDORS.vendor_id%TYPE,
    p_to_site_id     IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE,
    x_result         OUT NOCOPY VARCHAR2
);

PROCEDURE update_org_assignments
(
    p_api_version    IN         NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    p_from_vendor_id IN         PO_VENDORS.vendor_id%TYPE,
    p_from_site_id   IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE,
    p_to_vendor_id   IN         PO_VENDORS.vendor_id%TYPE,
    p_to_site_id     IN         PO_VENDOR_SITES_ALL.vendor_site_id%TYPE
);

END PO_AP_MERGE_GRP;

 

/
