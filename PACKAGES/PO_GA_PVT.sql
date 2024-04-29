--------------------------------------------------------
--  DDL for Package PO_GA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GA_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVGAS.pls 120.0.12010000.2 2011/08/05 07:19:41 inagdeo ship $ */

--< Shared Proc FPJ Start >
g_requesting_org_type CONSTANT VARCHAR2(15) := 'REQUESTING';
g_purchasing_org_type CONSTANT VARCHAR2(15) := 'PURCHASING';
g_owning_org_type     CONSTANT VARCHAR2(15) := 'OWNING';
--< Shared Proc FPJ End >

FUNCTION get_org_id
(	p_po_header_id       IN      PO_HEADERS_ALL.po_header_id%TYPE
) RETURN PO_HEADERS_ALL.org_id%TYPE;

FUNCTION get_current_org
  RETURN PO_SYSTEM_PARAMETERS.org_id%TYPE;

FUNCTION is_owning_org
(   p_po_header_id           IN      PO_HEADERS.po_header_id%TYPE
) RETURN BOOLEAN;

--< Shared Proc FPJ > Modified signature to remove %TYPE
FUNCTION get_org_name
(   p_org_id                 IN      NUMBER
) RETURN VARCHAR2;

FUNCTION is_global_agreement
(   p_po_header_id           IN      PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION is_enabled
(   p_po_header_id           IN      PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION enabled_orgs_exist
(   p_po_header_id           IN	     PO_HEADERS_ALL.po_header_id%TYPE	,
    p_owning_org_id          IN	     PO_HEADERS_ALL.org_id%TYPE
) RETURN BOOLEAN;

FUNCTION is_referenced
(   p_po_line_id             IN      PO_LINES_ALL.from_line_id%TYPE
) RETURN BOOLEAN;

--< Shared Proc FPJ > Modified signature to remove %TYPE
PROCEDURE get_ga_values
(   p_po_header_id           IN  NUMBER,
    x_global_agreement_flag  OUT NOCOPY VARCHAR2,
    x_owning_org_id          OUT NOCOPY NUMBER,
    x_owning_org_name        OUT NOCOPY VARCHAR2
);

FUNCTION is_expired
(   p_po_line_id        IN   PO_LINES_ALL.po_line_id%TYPE
) RETURN BOOLEAN;

FUNCTION is_approved
(   p_po_line_id        IN   PO_LINES_ALL.po_line_id%TYPE
) RETURN BOOLEAN;

FUNCTION is_ga_valid
(   p_po_header_id      IN   PO_HEADERS_ALL.po_header_id%TYPE ,
    p_po_line_id        IN   PO_LINES_ALL.po_line_id%TYPE
) RETURN BOOLEAN;

FUNCTION is_date_valid
(   p_po_header_id      IN   PO_HEADERS_ALL.po_header_id%TYPE ,
    p_date              IN   DATE
) RETURN BOOLEAN;

--< Shared Proc FPJ Start >
PROCEDURE validate_item
(   x_return_status     OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_valid_org_id      IN  NUMBER,
    x_is_purchasable    OUT NOCOPY BOOLEAN,
    x_is_same_uom_class OUT NOCOPY BOOLEAN,
    x_is_not_osp_item   OUT NOCOPY BOOLEAN
);
--< Shared Proc FPJ End >

FUNCTION is_ship_to_org_valid
(   p_ship_to_org_id	IN   PO_LINE_LOCATIONS_ALL.ship_to_organization_id%TYPE
) RETURN BOOLEAN;

FUNCTION get_vendor_site_id
(   p_po_header_id      IN   PO_GA_ORG_ASSIGNMENTS.po_header_id%TYPE
) RETURN PO_GA_ORG_ASSIGNMENTS.vendor_site_id%TYPE;

PROCEDURE get_currency_info                                -- <2694908>
(   p_po_header_id      IN         PO_HEADERS_ALL.po_header_id%TYPE ,
    x_currency_code     OUT NOCOPY PO_HEADERS_ALL.currency_code%TYPE ,
    x_rate_type         OUT NOCOPY PO_HEADERS_ALL.rate_type%TYPE,
    x_rate_date         OUT NOCOPY PO_HEADERS_ALL.rate_date%TYPE,
    x_rate              OUT NOCOPY PO_HEADERS_ALL.rate%TYPE
);

FUNCTION rate_exists                                       -- <2709419>
(   p_po_header_id      IN         PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

--<Bug 2721740 mbhargav START>
PROCEDURE sync_ga_line_attachments(
                  p_po_header_id IN po_headers_all.po_header_id%TYPE,
                  p_po_line_id  IN PO_LINES_ALL.po_line_id%TYPE,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE reference_attachments(
                        p_api_version      IN NUMBER,
                        p_from_entity_name IN VARCHAR2,
                        p_from_pk1_value   IN VARCHAR2,
                        p_from_pk2_value   IN VARCHAR2 DEFAULT NULL,
                        p_from_pk3_value   IN VARCHAR2 DEFAULT NULL,
                        p_from_pk4_value   IN VARCHAR2 DEFAULT NULL,
                        p_from_pk5_value   IN VARCHAR2 DEFAULT NULL,
                        p_to_entity_name   IN VARCHAR2,
                        p_to_pk1_value     IN VARCHAR2,
                        p_to_pk2_value     IN VARCHAR2 DEFAULT NULL,
                        p_to_pk3_value     IN VARCHAR2 DEFAULT NULL,
                        p_to_pk4_value     IN VARCHAR2 DEFAULT NULL,
                        p_to_pk5_value     IN VARCHAR2 DEFAULT NULL,
                        p_automatically_added_flag IN VARCHAR2 DEFAULT NULL,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_data         OUT NOCOPY VARCHAR2);
--<Bug 2721740 mbhargav END>


-- <GC FPJ START>
PROCEDURE is_purchasing_site_on_ga
(   p_po_header_id       IN         NUMBER,
    p_vendor_site_id     IN         NUMBER,
    x_result             OUT NOCOPY VARCHAR2
);

FUNCTION is_local_document
(   p_po_header_id       IN         NUMBER,
    p_type_lookup_code   IN         VARCHAR2
) RETURN BOOLEAN;
-- <GC FPJ END>

--< Shared Proc FPJ Start >
FUNCTION get_purchasing_org_id
(   p_po_header_id	IN 	NUMBER
) RETURN NUMBER;

PROCEDURE validate_item_revision
(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_item_id           IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_ga_item_revision  IN  VARCHAR2,
    p_owning_org_id     IN  NUMBER,
    p_check_rev_control IN  BOOLEAN,
    x_is_valid          OUT NOCOPY BOOLEAN,
    x_item_revision     OUT NOCOPY VARCHAR2
);

PROCEDURE validate_item_in_org
(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_item_id          IN  NUMBER,
    p_org_id           IN  NUMBER,
    p_ga_org_type      IN  VARCHAR2,
    p_ga_item_revision IN  VARCHAR2,
    p_owning_org_id    IN  NUMBER,
    x_is_valid         OUT NOCOPY BOOLEAN,
    x_item_revision    OUT NOCOPY VARCHAR2
);

PROCEDURE val_enabled_purchasing_org
(
    x_return_status     OUT    NOCOPY VARCHAR2,
    p_po_header_id      IN     NUMBER,
    x_purchasing_org_id IN OUT NOCOPY NUMBER,
    x_is_valid          OUT    NOCOPY BOOLEAN
);

PROCEDURE val_enabled_requesting_org
(
    x_return_status     OUT    NOCOPY VARCHAR2,
    p_po_header_id      IN     NUMBER,
    x_requesting_org_id IN OUT NOCOPY NUMBER,
    x_is_valid          OUT    NOCOPY BOOLEAN,
    x_purchasing_org_id OUT    NOCOPY NUMBER
);

PROCEDURE validate_in_purchasing_org
(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_po_header_id      IN  NUMBER,
    p_item_id           IN  NUMBER,
    p_purchasing_org_id IN  NUMBER,
    p_ga_item_revision  IN  VARCHAR2,
    p_owning_org_id     IN  NUMBER,
    x_is_pou_valid      OUT NOCOPY BOOLEAN,
    x_is_item_valid     OUT NOCOPY BOOLEAN,
    x_item_revision     OUT NOCOPY VARCHAR2
);

PROCEDURE validate_in_requesting_org
(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_po_header_id      IN  NUMBER,
    p_item_id           IN  NUMBER,
    p_requesting_org_id IN  NUMBER,
    p_ga_item_revision  IN  VARCHAR2,
    p_owning_org_id     IN  NUMBER,
    x_is_rou_valid      OUT NOCOPY BOOLEAN,
    x_is_item_valid     OUT NOCOPY BOOLEAN,
    x_item_revision     OUT NOCOPY VARCHAR2
);

FUNCTION requesting_org_type RETURN VARCHAR2;

FUNCTION purchasing_org_type RETURN VARCHAR2;

FUNCTION owning_org_type RETURN VARCHAR2;

--< Shared Proc FPJ End >

--Bug 12618619
PROCEDURE sync_all_ga_line_attachments(
                  p_po_header_id IN po_headers_all.po_header_id%TYPE,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_msg_data OUT NOCOPY VARCHAR2);

END PO_GA_PVT;

/
