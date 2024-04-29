--------------------------------------------------------
--  DDL for Package INVIDIT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVIDIT2" AUTHID CURRENT_USER AS
/* $Header: INVIDI2S.pls 115.8 2003/03/15 22:09:04 anakas ship $ */

PROCEDURE Table_Inserts
(
   X_event                       VARCHAR2
,  X_item_id                     NUMBER
,  X_org_id                      NUMBER
,  X_master_org_id               NUMBER
,  X_status_code                 VARCHAR2    DEFAULT  NULL
,  X_inventory_item_flag         VARCHAR2
,  X_purchasing_item_flag        VARCHAR2
,  X_internal_order_flag         VARCHAR2
,  X_mrp_planning_code           NUMBER
,  X_serviceable_product_flag    VARCHAR2
,  X_costing_enabled_flag        VARCHAR2
,  X_eng_item_flag               VARCHAR2
,  X_customer_order_flag         VARCHAR2
,  X_eam_item_type               NUMBER
,  X_contract_item_type_code     VARCHAR2
,  p_Folder_Category_Set_id      IN   NUMBER
,  p_Folder_Item_Category_id     IN   NUMBER
,  X_allowed_unit_code           NUMBER      DEFAULT  0
,  X_primary_uom                 VARCHAR2    DEFAULT  NULL
,  X_primary_uom_code            VARCHAR2    DEFAULT  NULL
,  X_primary_uom_class           VARCHAR2    DEFAULT  NULL
,  X_inv_install                 NUMBER      DEFAULT  0
,  X_last_updated_by             NUMBER      DEFAULT  0
,  X_last_update_login           NUMBER      DEFAULT  0
,  X_item_catalog_group_id       NUMBER
,  P_Default_Move_Order_Sub_Inv  VARCHAR2 -- Item Transaction Defaults for 11.5.9
,  P_Default_Receiving_Sub_Inv   VARCHAR2
,  P_Default_Shipping_Sub_Inv    VARCHAR2
,  P_Lifecycle_Id                NUMBER      DEFAULT  NULL
,  P_Current_Phase_Id            NUMBER      DEFAULT  NULL

);

PROCEDURE Insert_Pending_Status( X_event	      varchar2,
				 X_item_id	      number,
				 X_org_id	      number,
				 X_master_org_id      number,
				 X_status	      varchar2,
				 X_Lifecycle_Id       number default null,
				 X_current_phase_Id   number default null);


PROCEDURE Insert_Revision(X_event       varchar2,
                          X_item_id     number,
                          X_org_id      number,
			  X_last_updated_by	number,
			  X_last_update_login	number
                         );


PROCEDURE Insert_Categories
(
   X_event                       VARCHAR2
,  X_item_id                     NUMBER
,  X_org_id                      NUMBER
,  X_master_org_id               NUMBER
,  X_inventory_item_flag         VARCHAR2
,  X_purchasing_item_flag        VARCHAR2
,  X_internal_order_flag         VARCHAR2
,  X_mrp_planning_code           NUMBER
,  X_serviceable_product_flag    VARCHAR2
,  X_costing_enabled_flag        VARCHAR2
,  X_eng_item_flag               VARCHAR2
,  X_customer_order_flag         VARCHAR2
,  X_eam_item_type               NUMBER
,  X_contract_item_type_code     VARCHAR2
,  p_Folder_Category_Set_id      IN   NUMBER
,  p_Folder_Item_Category_id     IN   NUMBER
,  X_last_updated_by             NUMBER
);


PROCEDURE Insert_Costing_Category(X_item_id     number,
                                  X_org_id      number
                                 );


PROCEDURE Insert_Cost_Row(X_item_id     number,
                          X_org_id      number,
                          X_inv_install number,
			  X_last_updated_by	number
                         );

PROCEDURE Insert_Cost_Details(X_item_id         number,
                              X_org_id          number,
                              X_inv_install     number,
                              X_last_updated_by number,
                              X_cst_item_type   number
                             );


PROCEDURE Insert_Uom_Conversion(X_item_id               number,
                                X_allowed_unit_code     number,
                                X_primary_uom           varchar2,
                                X_primary_uom_code      varchar2,
                                X_primary_uom_class     varchar2
                                );

PROCEDURE Delete_Categories(X_item_id   number,
                            X_org_id    number
                           );

PROCEDURE Match_Catalog_Descr_Elements(X_item_id	number,
				       X_catalog_group_id  number
				      );


-- Procedure to insert Item Transaction Default SubInventories

PROCEDURE Insert_Default_SubInventories ( X_Event       VARCHAR2
					, X_item_id    NUMBER
					, X_org_id     NUMBER
					, P_Default_Move_Order_Sub_Inv  VARCHAR2
					, P_Default_Receiving_Sub_Inv   VARCHAR2
					, P_Default_Shipping_Sub_Inv    VARCHAR2
					);

END INVIDIT2;

 

/
