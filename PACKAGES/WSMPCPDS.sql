--------------------------------------------------------
--  DDL for Package WSMPCPDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPCPDS" AUTHID CURRENT_USER as
/* $Header: WSMCPRDS.pls 120.1 2005/06/29 04:29:34 abgangul noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_co_product_group_id     IN OUT NOCOPY NUMBER,
                       X_component_id                   NUMBER,
                       X_organization_id                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_co_product_id                  NUMBER,
/*coprod enh p2 .45*/
			X_alternate_designator		VARCHAR2,
/*end coprod enh p2 .45*/
                       X_bill_sequence_id               NUMBER,
                       X_component_sequence_id          NUMBER,
                       X_split                          NUMBER,
                       X_effectivity_date               DATE,
                       X_disable_date                   DATE,
                       X_primary_flag                   VARCHAR2,
                       X_revision                       VARCHAR2,
                       X_change_notice                  VARCHAR2,
                       X_implementation_date            DATE,
                       X_usage_rate                     NUMBER,
		       X_duality_flag			VARCHAR2,
                       X_planning_factor                NUMBER,
                       X_component_yield_factor         NUMBER,
                       X_include_in_cost_rollup         NUMBER,
                       X_wip_supply_type                NUMBER,
                       X_supply_subinventory            VARCHAR2,
                       X_supply_locator_id              NUMBER,
                       X_component_remarks              VARCHAR2,
                       X_attribute_category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Basis_type                     NUMBER       --LBM enh
                      );

  PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                     X_co_product_group_id            NUMBER,
                     X_component_id                   NUMBER,
                     X_organization_id                NUMBER,
                     X_co_product_id                  NUMBER,
                     X_bill_sequence_id               NUMBER,
                     X_component_sequence_id          NUMBER,
                     X_split                          NUMBER,
                     X_effectivity_date               DATE,
                     X_disable_date                   DATE,
                     X_primary_flag                   VARCHAR2,
                     X_revision                       VARCHAR2,
                     X_change_notice                  VARCHAR2,
                     X_implementation_date            DATE,
                     X_usage_rate                     NUMBER,
		     X_duality_flag		      VARCHAR2,
                     X_planning_factor                NUMBER,
                     X_component_yield_factor         NUMBER,
                     X_include_in_cost_rollup         NUMBER,
                     X_wip_supply_type                NUMBER,
                     X_supply_subinventory            VARCHAR2,
                     X_supply_locator_id              NUMBER,
                     X_component_remarks              VARCHAR2,
                     X_attribute_category             VARCHAR2,
                     X_Attribute1                     VARCHAR2,
                     X_Attribute2                     VARCHAR2,
                     X_Attribute3                     VARCHAR2,
                     X_Attribute4                     VARCHAR2,
                     X_Attribute5                     VARCHAR2,
                     X_Attribute6                     VARCHAR2,
                     X_Attribute7                     VARCHAR2,
                     X_Attribute8                     VARCHAR2,
                     X_Attribute9                     VARCHAR2,
                     X_Attribute10                    VARCHAR2,
                     X_Attribute11                    VARCHAR2,
                     X_Attribute12                    VARCHAR2,
                     X_Attribute13                    VARCHAR2,
                     X_Attribute14                    VARCHAR2,
                     X_Attribute15                    VARCHAR2,
                     X_Basis_type                     NUMBER       --LBM enh
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_co_product_group_id            NUMBER,
                       X_component_id                   NUMBER,
                       X_organization_id                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_last_update_date               DATE,
                       X_last_updated_by                NUMBER,
                       X_co_product_id                  NUMBER,
                       X_bill_sequence_id               NUMBER,
                       X_component_sequence_id          NUMBER,
                       X_split                          NUMBER,
                       X_effectivity_date               DATE,
                       X_disable_date                   DATE,
                       X_primary_flag                   VARCHAR2,
                       X_revision                       VARCHAR2,
                       X_change_notice                  VARCHAR2,
                       X_implementation_date            DATE,
                       X_usage_rate                     NUMBER,
		       	X_duality_flag		        VARCHAR2,
                       X_planning_factor                NUMBER,
                       X_component_yield_factor         NUMBER,
                       X_include_in_cost_rollup         NUMBER,
                       X_wip_supply_type                NUMBER,
                       X_supply_subinventory            VARCHAR2,
                       X_supply_locator_id              NUMBER,
                       X_component_remarks              VARCHAR2,
                       X_attribute_category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Basis_type                     NUMBER       --LBM enh
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE Check_Unique(X_rowid	   VARCHAR2,
			 X_component_id	   NUMBER,
                         X_organization_id NUMBER);

END WSMPCPDS;
 

/
