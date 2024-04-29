--------------------------------------------------------
--  DDL for Package MRP_SOURCING_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SOURCING_API_PK" AUTHID CURRENT_USER AS
    /* $Header: MRPSAPIS.pls 120.1 2005/06/17 09:25:39 ichoudhu noship $ */

SYS_YES         CONSTANT INTEGER := 1;
SYS_NO          CONSTANT INTEGER := 2;
NULL_VALUE      constant number := -23453;

    FUNCTION    mrp_sourcing(
                arg_mode                    IN          VARCHAR2,
                arg_item_id                 IN          NUMBER,
                arg_commodity_id            IN          NUMBER,
                arg_dest_organization_id    IN          NUMBER,
                arg_dest_subinventory       IN          VARCHAR2,
                arg_autosource_date         IN          DATE,
                arg_vendor_id               OUT  NOCOPY       NUMBER,
                arg_vendor_site_id          OUT  NOCOPY       NUMBER,
                arg_source_organization_id  IN OUT  NOCOPY    NUMBER,
                arg_source_subinventory     IN OUT  NOCOPY    VARCHAR2,/* Bug # 1646303 - changed */
                                                                 /* datatype to varchar2 */
                arg_sourcing_rule_id        OUT    NOCOPY     NUMBER,
                arg_error_message           OUT    NOCOPY     VARCHAR2)
      RETURN BOOLEAN;

    FUNCTION    mrp_sourcing(
                arg_mode                    IN          VARCHAR2,
                arg_item_id                 IN          NUMBER,
                arg_commodity_id            IN          NUMBER,
                arg_dest_organization_id    IN          NUMBER,
                arg_dest_subinventory       IN          VARCHAR2,
                arg_autosource_date         IN          DATE,
                arg_vendor_id               OUT NOCOPY        NUMBER,
                arg_vendor_site_code        OUT NOCOPY        VARCHAR2,
                arg_source_organization_id  IN OUT NOCOPY     NUMBER,
                arg_source_subinventory     IN OUT NOCOPY     VARCHAR2,
                arg_sourcing_rule_id        OUT NOCOPY        NUMBER,
                arg_error_message           OUT NOCOPY        VARCHAR2)
      RETURN BOOLEAN;

    MPS_CONSUME_PROFILE_VALUE   NUMBER := FND_PROFILE.value('MPS_CONSUME_PROFILE_VALUE');

    FUNCTION mrp_sourcing_rule_exists
      (
       arg_item_id          IN   NUMBER,
       arg_category_id      IN   NUMBER,
       arg_supplier_id      IN   NUMBER,
       arg_supplier_site_id IN   NUMBER,
       arg_message          OUT NOCOPY VARCHAR2
       ) RETURN NUMBER;

    FUNCTION  MRP_GET_SOURCING_HISTORY(
				       arg_source_org              IN          NUMBER,
				       arg_vendor_id               IN          NUMBER,
				       arg_vendor_site_id          IN          NUMBER,
				       arg_item_id                 IN          NUMBER,
				       arg_org_id                  IN          NUMBER,
				       arg_sourcing_rule_id        IN          NUMBER,
				       arg_start_date              IN    OUT
NOCOPY  NUMBER,
				       arg_end_date                IN          NUMBER,
				       arg_err_mesg                OUT   NOCOPY       VARCHAR2)
      RETURN NUMBER;

    FUNCTION    mrp_po_historical_alloc(
                                arg_source_org              IN          NUMBER,
                                arg_vendor_id               IN          NUMBER,
                                arg_vendor_site_id          IN          NUMBER,
                                arg_item_id                 IN          NUMBER,
                                arg_org_id                  IN          NUMBER,
                                arg_start_date              IN          DATE,
                                arg_end_date                IN          DATE)
            RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES (mrp_po_historical_alloc, WNDS);

END MRP_SOURCING_API_PK;
 

/
