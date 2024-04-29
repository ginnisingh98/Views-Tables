--------------------------------------------------------
--  DDL for Package MRP_SOURCING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SOURCING_GRP" AUTHID CURRENT_USER AS
    /* $Header: MRPGSRCS.pls 115.0 2003/07/17 23:24:15 ichoudhu noship $ */

  PROCEDURE    Get_Source(
                p_api_version              IN       NUMBER,
                x_return_status            OUT   NOCOPY   VARCHAR2,
                p_mode                    IN          VARCHAR2,
                p_item_id                 IN          NUMBER,
                p_commodity_id            IN          NUMBER,
                p_dest_organization_id    IN          NUMBER,
                p_dest_subinventory       IN          VARCHAR2,
                p_autosource_date         IN          DATE,
                x_vendor_id               OUT    NOCOPY     NUMBER,
                x_vendor_site_code          OUT    NOCOPY     VARCHAR2,
                x_source_organization_id  IN OUT  NOCOPY    NUMBER,
                x_source_subinventory     IN OUT  NOCOPY    VARCHAR2,
                x_sourcing_rule_id        OUT    NOCOPY     NUMBER,
                x_error_message           OUT    NOCOPY     VARCHAR2);

END MRP_Sourcing_GRP;

 

/
