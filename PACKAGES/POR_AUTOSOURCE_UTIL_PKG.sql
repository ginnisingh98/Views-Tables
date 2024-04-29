--------------------------------------------------------
--  DDL for Package POR_AUTOSOURCE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_AUTOSOURCE_UTIL_PKG" AUTHID CURRENT_USER AS
    /* $Header: PORSRCUS.pls 115.6 2003/02/21 22:40:11 jjessup ship $ */

    FUNCTION  is_internal_orderable(p_item_id           IN    NUMBER,
                                    p_organization_id   IN    NUMBER
    ) RETURN NUMBER;

    FUNCTION  is_item_purchasable(p_item_id           IN    NUMBER,
                                  p_organization_id   IN    NUMBER
    ) RETURN NUMBER;


    FUNCTION  is_item_shippable(p_item_id           IN    NUMBER,
                                p_organization_id   IN    NUMBER
    ) RETURN NUMBER;


    FUNCTION  is_valid_shipping_network(p_from_organization_id     IN    NUMBER,
                                        p_to_organization_id       IN    NUMBER
    ) RETURN NUMBER;

    FUNCTION  is_item_assigned(p_item_id                  IN    NUMBER,
                               p_source_organization_id   IN    NUMBER
    ) RETURN NUMBER;

    FUNCTION  autosource(p_item_id                   IN            NUMBER,
                         p_category_id               IN            NUMBER,
                         p_dest_organization_id      IN            NUMBER,
                         p_dest_subinventory         IN            VARCHAR2,
                         p_vendor_id                 IN            NUMBER,
                         p_vendor_site_id            IN            NUMBER,
                         p_not_purchasable_override  IN            VARCHAR2,
                         p_unit_of_issue             IN OUT NOCOPY VARCHAR2,
                         p_source_organization_id    OUT    NOCOPY NUMBER,
                         p_source_subinventory       OUT    NOCOPY VARCHAR2,
                         p_sourcing_type             OUT    NOCOPY VARCHAR2,
                         p_cost_price                OUT    NOCOPY NUMBER,
                         p_error_msg_code            OUT    NOCOPY VARCHAR2
    ) RETURN BOOLEAN;

END POR_AUTOSOURCE_UTIL_PKG;

 

/
