--------------------------------------------------------
--  DDL for Package POR_AUTOSOURCE_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_AUTOSOURCE_CUSTOM_PKG" AUTHID CURRENT_USER AS
    /* $Header: PORSRCCS.pls 115.7 2003/02/21 22:39:45 jjessup ship $ */

    FUNCTION  autosource(p_item_id                    IN                NUMBER,
                         p_category_id                IN                NUMBER,
                         p_dest_organization_id       IN                NUMBER,
                         p_dest_subinventory          IN                VARCHAR2,
                         p_vendor_id                  IN                NUMBER,
                         p_vendor_site_id             IN                NUMBER,
                         p_not_purchasable_override   IN                VARCHAR2,
                         p_unit_of_issue              IN OUT  NOCOPY    VARCHAR2,
                         p_source_organization_id     OUT     NOCOPY    NUMBER,
                         p_source_subinventory        OUT     NOCOPY    VARCHAR2,
                         p_sourcing_type              OUT     NOCOPY    VARCHAR2,
                         p_cost_price                 OUT     NOCOPY    NUMBER,
                         p_error_message              OUT     NOCOPY    VARCHAR2
    ) RETURN BOOLEAN;

END POR_AUTOSOURCE_CUSTOM_PKG;

 

/
