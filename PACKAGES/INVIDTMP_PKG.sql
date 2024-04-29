--------------------------------------------------------
--  DDL for Package INVIDTMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVIDTMP_PKG" AUTHID CURRENT_USER as
/* $Header: INVIDTMS.pls 120.1 2005/06/21 04:10:13 appldev ship $ */

PROCEDURE Populate_Fields
(  X_template_id                  IN   NUMBER
,                         X_inventory_item_status_code  OUT NOCOPY varchar2,
                          X_primary_unit_of_measure     OUT NOCOPY varchar2,
                          X_item_type_dsp               OUT NOCOPY varchar2,
                          X_bom_item_type               OUT NOCOPY varchar,
                          X_inventory_item_flag         OUT NOCOPY varchar,
                          X_stock_enabled_flag          OUT NOCOPY varchar,
                          X_mtl_transactions_enabled_fla OUT NOCOPY varchar,
                          X_costing_enabled_flag        OUT NOCOPY varchar,
                          X_purchasing_item_flag        OUT NOCOPY varchar,
                          X_purchasing_enabled_flag     OUT NOCOPY varchar,
                          X_customer_order_flag         OUT NOCOPY varchar,
                          X_customer_order_enabled_flag OUT NOCOPY varchar,
                          X_internal_order_flag         OUT NOCOPY varchar,
                          X_internal_order_enabled_flag OUT NOCOPY varchar,
                          X_invoiceable_item_flag       OUT NOCOPY varchar,
                          X_invoice_enabled_flag        OUT NOCOPY varchar,
                          X_build_in_wip_flag           OUT NOCOPY varchar,
                          X_bom_enabled_flag            OUT NOCOPY varchar,
                          X_eam_item_type                OUT  NOCOPY NUMBER,
                          /* Start Bug 3713912 */
                          X_recipe_enabled_flag              OUT NOCOPY varchar,
                          X_process_exec_enabled_flag        OUT NOCOPY varchar,
                          X_process_costing_enabled_flag     OUT NOCOPY varchar,
                          X_process_quality_enabled_flag     OUT NOCOPY varchar
                          /* End Bug 3713912 */
);

FUNCTION Resolve_Mfg_Lookup(X_lu_type IN varchar2,
                            X_lu_code IN number
                            )
return varchar2;

FUNCTION Resolve_Fnd_Lookup(X_lu_type IN varchar2,
                            X_lu_code IN varchar2
                            )
return varchar2;


END INVIDTMP_PKG;

 

/
