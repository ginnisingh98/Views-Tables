--------------------------------------------------------
--  DDL for Package WSMPPCPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPPCPD" AUTHID CURRENT_USER AS
/* $Header: WSMPCPDS.pls 120.1 2005/06/29 04:27:01 abgangul noship $ */

/*===========================================================================
  PROCEDURE NAME:       insert_bill

  DESCRIPTION:          This routine is used to populate the
                        bom_bill_of_mtls_interface.

                        x_error_code is set to zero on success.

  PARAMETERS:     x_rec          IN  OUT NOCOPY bom_bill_of_mtls_interface%ROWTYPE
                  x_assembly_item_name         IN VARCHAR2
                  x_organization_code          IN VARCHAR2
                  x_error_code   IN  OUT NOCOPY NUMBER
                  x_error_msg    IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/16/97   Created
===========================================================================*/
-- g_iteration_count number := 0;

PROCEDURE insert_bill (x_rec        IN OUT NOCOPY  bom_bill_of_mtls_interface%ROWTYPE,
                       x_assembly_item_name IN VARCHAR2 DEFAULT NULL,
                       x_organization_code IN VARCHAR2 DEFAULT NULL,
                       x_error_code IN OUT NOCOPY  NUMBER,
                       x_error_msg  IN OUT NOCOPY  VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       insert_component

  DESCRIPTION:          This routine is used to populate the
                        bom_inventory_comps_interface.

                        x_error_code is set to zero on success.

  PARAMETERS:     x_rec          IN  OUT NOCOPY bom_inventory_comps_interface%ROWTYPE
                  x_component_name             IN VARCHAR2
                  x_organization_code          IN VARCHAR2
                  x_assembly_item_name         IN VARCHAR2
                  x_supply_locator             IN VARCHAR2
                  x_error_code   IN  OUT NOCOPY NUMBER
                  x_error_msg    IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/16/97   Created
===========================================================================*/
PROCEDURE insert_component (x_rec        IN OUT NOCOPY  bom_inventory_comps_interface%ROWTYPE,
                            x_component_name IN VARCHAR2 DEFAULT NULL,
                            x_organization_code IN VARCHAR2 DEFAULT NULL,
                            x_assembly_item_name IN VARCHAR2 DEFAULT NULL,
                            x_supply_locator IN VARCHAR2 DEFAULT NULL,
                            x_error_code IN OUT NOCOPY  NUMBER,
                            x_error_msg  IN OUT NOCOPY  VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       insert_substitute_component

  DESCRIPTION:          This routine is used to populate the
                        bom_sub_comps_interface.

                        x_error_code is set to zero on success.

  PARAMETERS:     x_rec          IN  OUT NOCOPY bom_sub_comps_interface%ROWTYPE
                  x_error_code   IN  OUT NOCOPY NUMBER
                  x_error_msg    IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        01/22/98   Created
===========================================================================*/
PROCEDURE insert_substitute_component (
		x_rec        		IN OUT NOCOPY  bom_sub_comps_interface%ROWTYPE,
                x_co_product_name       IN  VARCHAR2,
                x_alternate_designator  IN  VARCHAR2,
                x_component_name        IN  VARCHAR2,
                x_comp_start_eff_date   IN  DATE,
                x_org_code        	IN  VARCHAR2,
                x_error_code 		IN OUT NOCOPY  NUMBER,
                x_error_msg  		IN OUT NOCOPY  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       insert_sub_comps

  DESCRIPTION:          This routine is used to populate the
                        bom_sub_comps_interface table with all
                        the substitutes for a co-product component.

                        x_error_code is set to zero on success.

  PARAMETERS:     x_co_product_group_id     IN NUMBER
                  x_component_sequence_id   IN NUMBER
                  x_qty_multiplier          IN NUMBER
                  x_error_code              IN  OUT NOCOPY NUMBER
                  x_error_msg               IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        01/23/98   Created
===========================================================================*/
PROCEDURE insert_sub_comps (x_co_product_group_id   IN  NUMBER,
                            x_co_product_name 	    IN  VARCHAR2,
                            x_alternate_designator  IN  VARCHAR2,
                            x_component_name        IN  VARCHAR2,
                            x_comp_start_eff_date   IN  DATE,
                            x_org_code        	    IN  VARCHAR2,
                            x_component_sequence_id IN  NUMBER,
                            x_qty_multiplier        IN  NUMBER,
                            x_error_code            IN OUT NOCOPY  NUMBER,
                            x_error_msg             IN OUT NOCOPY  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       process_bom_sub_comp

  DESCRIPTION:          This routine is used to handle the inserts,
                        updates and deletes that are performed
                        in the bom_co_prod_comp_substitutes zone
                        of the Co-Products form.

                        x_error_code is set to zero on success.

                        x_process_code: 1 - Insert
                                        2 - Update
                                        3 - Delete

  PARAMETERS:                   x_co_product_group_id       IN     NUMBER,
                                x_substitute_component_id   IN     NUMBER,
                                x_substitute_comp_id_old    IN     NUMBER,
                                x_process_code              IN     NUMBER,
                                x_org_id                    IN     NUMBER,
                                x_rowid                     IN OUT NOCOPY VARCHAR2,
                                x_last_update_login              NUMBER,
                                x_last_updated_by                NUMBER,
                                x_last_update_date               DATE,
                                x_creation_date                  DATE,
                                x_created_by                     NUMBER,
                                x_substitute_item_quantity       NUMBER,
                                x_attribute_category             VARCHAR2,
                                x_attribute1                     VARCHAR2,
                                x_attribute2                     VARCHAR2,
                                x_attribute3                     VARCHAR2,
                                x_attribute4                     VARCHAR2,
                                x_attribute5                     VARCHAR2,
                                x_attribute6                     VARCHAR2,
                                x_attribute7                     VARCHAR2,
                                x_attribute8                     VARCHAR2,
                                x_attribute9                     VARCHAR2,
                                x_attribute10                    VARCHAR2,
                                x_attribute11                    VARCHAR2,
                                x_attribute12                    VARCHAR2,
                                x_attribute13                    VARCHAR2,
                                x_attribute14                    VARCHAR2,
                                x_attribute15                    VARCHAR2,
                                x_error_code                IN OUT NOCOPY NUMBER,
                                x_error_msg                 IN OUT NOCOPY VARCHAR2


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        01/23/98   Created
===========================================================================*/

PROCEDURE process_bom_sub_comp (x_co_product_group_id       IN     NUMBER,
                                x_substitute_component_id   IN     NUMBER,
                                x_substitute_comp_id_old    IN     NUMBER,
                                x_process_code              IN     NUMBER,
                                x_org_id                    IN     NUMBER,
                                x_rowid                     IN OUT NOCOPY VARCHAR2,
                                x_last_update_login              NUMBER,
                                x_last_updated_by                NUMBER,
                                x_last_update_date               DATE,
                                x_creation_date                  DATE,
                                x_created_by                     NUMBER,
                                x_substitute_item_quantity       NUMBER,
                                x_attribute_category             VARCHAR2,
                                x_attribute1                     VARCHAR2,
                                x_attribute2                     VARCHAR2,
                                x_attribute3                     VARCHAR2,
                                x_attribute4                     VARCHAR2,
                                x_attribute5                     VARCHAR2,
                                x_attribute6                     VARCHAR2,
                                x_attribute7                     VARCHAR2,
                                x_attribute8                     VARCHAR2,
                                x_attribute9                     VARCHAR2,
                                x_attribute10                    VARCHAR2,
                                x_attribute11                    VARCHAR2,
                                x_attribute12                    VARCHAR2,
                                x_attribute13                    VARCHAR2,
                                x_attribute14                    VARCHAR2,
                                x_attribute15                    VARCHAR2,
                                x_basis_type                     NUMBER,    --LBM enh
                                x_error_code                IN OUT NOCOPY NUMBER,
                                x_error_msg                 IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       val_co_product_details

  DESCRIPTION:          Bug# 1418668. Split the validation portion from
                        procedure process_co_product so that co_product form
                        can call this procedure to validate before actually
                        inserting into the tables.

  CHANGE HISTORY:       Pons Ponnambalam     12/13/2000   Created
===========================================================================*/
PROCEDURE val_co_product_details(
                             x_process_code     IN     NUMBER,
                             x_rowid            IN     VARCHAR2 DEFAULT NULL,
                             x_co_product_group_id IN  NUMBER   DEFAULT NULL,
                             x_usage            IN     NUMBER   DEFAULT NULL,
                             x_co_product_id    IN     NUMBER   DEFAULT NULL,
                             x_org_id           IN     NUMBER   DEFAULT NULL,
                             x_primary_flag     IN     VARCHAR2 DEFAULT NULL,
                             x_alternate_designator IN OUT NOCOPY VARCHAR2,
                             x_bill_sequence_id IN  OUT NOCOPY NUMBER,
                             x_effectivity_date IN      DATE     DEFAULT NULL,
                             x_disable_date     IN      DATE     DEFAULT NULL,
                             x_bill_insert      IN OUT NOCOPY  BOOLEAN,
                             x_p_bill_insert    IN OUT NOCOPY  BOOLEAN,
                             x_comp_insert      IN OUT NOCOPY  BOOLEAN,
                             x_p_comp_insert    IN OUT NOCOPY  BOOLEAN,
                             x_error_code       IN OUT NOCOPY  NUMBER,
                             x_error_msg        IN OUT NOCOPY  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       process_co_product

  DESCRIPTION:          Cover routine which is used to validate
                        as well as interface co-products with
                        Bill of Materials.

  PARAMETERS:                x_process_code     IN     NUMBER
                             x_rowid            IN     VARCHAR2
                             x_co_product_group_id IN  NUMBER
                             x_usage            IN     NUMBER
                             x_duality_flag     IN     VARCHAR2
                             x_planning_factor  IN     NUMBER
                             x_component_yield_factor IN NUMBER
                             x_include_in_cost_rollup IN NUMBER
                             x_wip_supply_type  IN     NUMBER
                             x_supply_subinventory IN  VARCHAR2
                             x_supply_locator_id IN    NUMBER
                             x_component_remarks  IN    VARCHAR2
                             x_split            IN     NUMBER
                             x_created_by       IN     NUMBER
                             x_login_id         IN     NUMBER
                             x_co_product_id    IN     NUMBER
                             x_co_product_name  IN     VARCHAR2
                             x_revision         IN     VARCHAR2
                             x_org_id           IN     NUMBER
                             x_org_code         IN     VARCHAR2
                             x_primary_flag     IN     VARCHAR2
                             x_alternate_designator IN VARCHAR2
                             x_component_id     IN     NUMBER
                             x_component_name   IN     VARCHAR2
                             x_bill_sequence_id IN OUT NOCOPY NUMBER
                             x_component_sequence_id IN OUT NOCOPY NUMBER
                             x_effectivity_date IN     DATE
                             x_disable_date     IN     DATE
                             x_coprod_attribute_category VARCHAR2
                             x_coprod_attribute1         VARCHAR2
                             x_coprod_attribute2         VARCHAR2
                             x_coprod_attribute3         VARCHAR2
                             x_coprod_attribute4         VARCHAR2
                             x_coprod_attribute5         VARCHAR2
                             x_coprod_attribute6         VARCHAR2
                             x_coprod_attribute7         VARCHAR2
                             x_coprod_attribute8         VARCHAR2
                             x_coprod_attribute9         VARCHAR2
                             x_coprod_attribute10        VARCHAR2
                             x_coprod_attribute11        VARCHAR2
                             x_coprod_attribute12        VARCHAR2
                             x_coprod_attribute13        VARCHAR2
                             x_coprod_attribute14        VARCHAR2
                             x_coprod_attribute15        VARCHAR2
                             x_comp_attribute_category   VARCHAR2
                             x_comp_attribute1           VARCHAR2
                             x_comp_attribute2           VARCHAR2
                             x_comp_attribute3           VARCHAR2
                             x_comp_attribute4           VARCHAR2
                             x_comp_attribute5           VARCHAR2
                             x_comp_attribute6           VARCHAR2
                             x_comp_attribute7           VARCHAR2
                             x_comp_attribute8           VARCHAR2
                             x_comp_attribute9           VARCHAR2
                             x_comp_attribute10          VARCHAR2
                             x_comp_attribute11          VARCHAR2
                             x_comp_attribute12          VARCHAR2
                             x_comp_attribute13          VARCHAR2
                             x_comp_attribute14          VARCHAR2
                             x_comp_attribute15          VARCHAR2
                             x_error_code       IN OUT NOCOPY NUMBER
                             x_error_msg        IN OUT NOCOPY VARCHAR2

                        x_process_code: 1 - Insert validation.
                                        2 - Update validation.
                                        3 - Delete validation.

                        x_error_code :  0 - Success
                                        Other Values - Failure.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/19/97   Created

===========================================================================*/
PROCEDURE process_co_product(x_process_code     IN     NUMBER,
                             x_rowid            IN     VARCHAR2 DEFAULT NULL,
                             x_co_product_group_id IN  NUMBER   DEFAULT NULL,
                             x_usage            IN     NUMBER   DEFAULT NULL,
                             x_duality_flag     IN     VARCHAR2 DEFAULT NULL,
                             x_planning_factor  IN     NUMBER   DEFAULT NULL,
                             x_component_yield_factor IN NUMBER DEFAULT NULL,
                             x_include_in_cost_rollup IN NUMBER DEFAULT NULL,
                             x_wip_supply_type  IN     NUMBER   DEFAULT NULL,
                             x_supply_subinventory IN  VARCHAR2 DEFAULT NULL,
                             x_supply_locator_id IN    NUMBER   DEFAULT NULL,
                             x_supply_locator    IN    VARCHAR2 DEFAULT NULL,
                             x_component_remarks IN    VARCHAR2 DEFAULT NULL,
                             x_split            IN     NUMBER   DEFAULT NULL,
                             x_created_by       IN     NUMBER   DEFAULT NULL,
                             x_login_id         IN     NUMBER   DEFAULT NULL,
                             x_co_product_id    IN     NUMBER   DEFAULT NULL,
                             x_co_product_name  IN     VARCHAR2 DEFAULT NULL,
                             x_revision         IN     VARCHAR2 DEFAULT NULL,
                             x_org_id           IN     NUMBER   DEFAULT NULL,
                             x_org_code         IN     VARCHAR2 DEFAULT NULL,
                             x_primary_flag     IN     VARCHAR2 DEFAULT NULL,
                             x_alternate_designator IN OUT NOCOPY VARCHAR2,
                             x_component_id     IN     NUMBER   DEFAULT NULL,
                             x_component_name   IN     VARCHAR2 DEFAULT NULL,
                             x_bill_sequence_id IN OUT NOCOPY NUMBER,
                             x_component_sequence_id IN OUT NOCOPY NUMBER,
                             x_effectivity_date IN     DATE     DEFAULT NULL,
                             x_disable_date     IN     DATE     DEFAULT NULL,
            /* Bug# 1418668. Added the following 4 parameters */
                             x_bill_insert      IN    BOOLEAN DEFAULT FALSE,
                             x_p_bill_insert    IN    BOOLEAN DEFAULT FALSE,
                             x_comp_insert      IN    BOOLEAN DEFAULT FALSE,
                             x_p_comp_insert    IN    BOOLEAN DEFAULT FALSE,
                             X_basis_type       IN       NUMBER   DEFAULT 1,   --LBM enh, default type = Item
                             x_coprod_attribute_category VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute1         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute2         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute3         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute4         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute5         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute6         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute7         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute8         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute9         VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute10        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute11        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute12        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute13        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute14        VARCHAR2 DEFAULT NULL,
                             x_coprod_attribute15        VARCHAR2 DEFAULT NULL,
                             x_comp_attribute_category   VARCHAR2 DEFAULT NULL,
                             x_comp_attribute1           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute2           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute3           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute4           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute5           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute6           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute7           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute8           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute9           VARCHAR2 DEFAULT NULL,
                             x_comp_attribute10          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute11          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute12          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute13          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute14          VARCHAR2 DEFAULT NULL,
                             x_comp_attribute15          VARCHAR2 DEFAULT NULL,
                             x_error_code       IN OUT NOCOPY NUMBER,
                             x_error_msg        IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       set_common_bill

  DESCRIPTION:          This routine performs the updates required
                        for BOM Co-Products to bom_bill_of_materials table.
                        The primary co-product's bill is used as the
                        common bill by the other co-products in a specific
                        co-product relationship.

  PARAMETERS:           x_co_product_group_id        IN     NUMBER,
                        x_org_id                     IN     NUMBER,
                        x_co_product_id              IN     NUMBER,
                        x_bill_sequence_id           IN     NUMBER,
                        x_component_sequence_id      IN     NUMBER,
                        x_primary_flag               IN     VARCHAR2,
                        x_error_code                 IN OUT NOCOPY NUMBER,
                        x_error_msg                  IN OUT NOCOPY VARCHAR2

                        x_error_code :  0 - Success
                                        2 - Validation failure.
                                        Other Values - Failure.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/8/97   Created
===========================================================================*/
PROCEDURE set_common_bill ( x_co_product_group_id        IN     NUMBER,
                            x_org_id                     IN     NUMBER,
                            x_co_product_id              IN     NUMBER,
                            x_bill_sequence_id           IN     NUMBER,
                            x_component_sequence_id      IN     NUMBER,
                            x_primary_flag               IN     VARCHAR2,
                            x_error_code                 IN OUT NOCOPY NUMBER,
                            x_error_msg                  IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       delete_component

  DESCRIPTION:          This routine performs the processing
                        required to delete a component. It processes
                        the co-products associated with the
                        component.

  PARAMETERS:           x_co_product_group_id IN     NUMBER,
                        x_rowid               IN     VARCHAR2,
                        x_error_code          IN OUT NOCOPY NUMBER,
                        x_error_msg           IN OUT NOCOPY VARCHAR2

                        x_error_code :  0 - Successful.
                         Other values:    - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/20/97   Created
===========================================================================*/
PROCEDURE delete_component(x_co_product_group_id IN     NUMBER,
                           x_rowid               IN     VARCHAR2,
                           x_error_code          IN OUT NOCOPY NUMBER,
                           x_error_msg           IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       delete_co_product

  DESCRIPTION:          This routine performs the processing
                        required to delete a specific co_product.
                        It updates the disable date on the corresponding
                        bill to reflect the change.

  PARAMETERS:           x_co_product_group_id IN     NUMBER,
                        x_co_product_id       IN     NUMBER,
                        x_error_code          IN OUT NOCOPY NUMBER,
                        x_error_msg           IN OUT NOCOPY VARCHAR2

                        x_error_code :  0 - Successful.
                         Other values:    - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/20/97   Created
===========================================================================*/
PROCEDURE delete_co_product(x_co_product_group_id IN     NUMBER,
                           x_co_product_id        IN     NUMBER,
                           x_error_code          IN OUT NOCOPY NUMBER,
                           x_error_msg           IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       update_co_prod_details

  DESCRIPTION:          This routine performs the processing
                        required to update co-products associated
                        with a component.

  PARAMETERS:           x_co_product_group_id IN     NUMBER,
                        x_effectivity_date    IN     DATE,
                        x_disable_date        IN     DATE,
                        x_usage_rate          IN     NUMBER,
                        x_inv_usage           IN     NUMBER,
                        x_duality_flag        IN     VARCHAR2,
                        x_comp_attribute_category  IN     VARCHAR2,
                        x_comp_attribute1          IN     VARCHAR2,
                        x_comp_attribute2          IN     VARCHAR2,
                        x_comp_attribute3          IN     VARCHAR2,
                        x_comp_attribute4          IN     VARCHAR2,
                        x_comp_attribute5          IN     VARCHAR2,
                        x_comp_attribute6          IN     VARCHAR2,
                        x_comp_attribute7          IN     VARCHAR2,
                        x_comp_attribute8          IN     VARCHAR2,
                        x_comp_attribute9          IN     VARCHAR2,
                        x_comp_attribute10         IN     VARCHAR2,
                        x_comp_attribute11         IN     VARCHAR2,
                        x_comp_attribute12         IN     VARCHAR2,
                        x_comp_attribute13         IN     VARCHAR2,
                        x_comp_attribute14         IN     VARCHAR2,
                        x_comp_attribute15         IN     VARCHAR2,
                        x_error_code          IN OUT NOCOPY NUMBER,
                        x_error_msg           IN OUT NOCOPY VARCHAR2

                        x_error_code :  0 - Successful.
                         Other values:    - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/20/97   Created
===========================================================================*/
PROCEDURE update_co_prod_details(x_co_product_group_id IN     NUMBER,
                                 x_effectivity_date    IN     DATE,
                                 x_disable_date        IN     DATE,
                                 x_usage_rate          IN     NUMBER,
                                 x_inv_usage           IN     NUMBER,
                                 x_duality_flag        IN     VARCHAR2,
                                 x_basis_type          IN     NUMBER,        --LBM enh
                                 x_comp_attribute_category  IN     VARCHAR2,
                                 x_comp_attribute1          IN     VARCHAR2,
                                 x_comp_attribute2          IN     VARCHAR2,
                                 x_comp_attribute3          IN     VARCHAR2,
                                 x_comp_attribute4          IN     VARCHAR2,
                                 x_comp_attribute5          IN     VARCHAR2,
                                 x_comp_attribute6          IN     VARCHAR2,
                                 x_comp_attribute7          IN     VARCHAR2,
                                 x_comp_attribute8          IN     VARCHAR2,
                                 x_comp_attribute9          IN     VARCHAR2,
                                 x_comp_attribute10         IN     VARCHAR2,
                                 x_comp_attribute11         IN     VARCHAR2,
                                 x_comp_attribute12         IN     VARCHAR2,
                                 x_comp_attribute13         IN     VARCHAR2,
                                 x_comp_attribute14         IN     VARCHAR2,
                                 x_comp_attribute15         IN     VARCHAR2,
                                 x_error_code          IN OUT NOCOPY NUMBER,
                                 x_error_msg           IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  FUNCTION NAME:	get_alternate_designator

  DESCRIPTION:		This function gets the alternate designator
                        used to create the bills associated with the co-products
                        belonging to a specific co-product relationship.

  PARAMETERS:		X_co_product_group_id	NUMBER


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	7/7	Created
===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:       lock_bill

  DESCRIPTION:          This routine is used to lock the assembly
                        record prior to updating from the co-products
                        form.

                        x_error_code is set to zero on success.

  PARAMETERS:     x_bill_sequence_id IN  NUMBER
                  x_error_code   IN  OUT NOCOPY NUMBER
                  x_error_msg    IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        02/08/98   Created
===========================================================================*/
 PROCEDURE lock_bill (x_bill_sequence_id       IN       NUMBER,
                      x_error_code             IN OUT NOCOPY   NUMBER,
                      x_error_msg              IN OUT NOCOPY   VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       lock_component

  DESCRIPTION:          This routine is used to lock the component
                        record prior to updating from the co-products
                        form.

                        x_error_code is set to zero on success.

  PARAMETERS:     x_component_sequence_id   IN  NUMBER
                  x_error_code              IN  OUT NOCOPY NUMBER
                  x_error_msg               IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        02/08/98   Created
===========================================================================*/
 PROCEDURE lock_component (x_component_sequence_id  IN       NUMBER,
                           x_error_code             IN OUT NOCOPY   NUMBER,
                           x_error_msg              IN OUT NOCOPY   VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       call_bom_bo_api

  DESCRIPTION:          This routine calls the Bom Business Object API
                        and does required error handling.

                        x_error_code is set to zero on success.

  PARAMETERS:
	p_bom_header_rec    IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	p_component_tbl	    IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type
	p_subs_comp_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
        x_error_code        IN  OUT NOCOPY NUMBER
        x_error_msg         IN  OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:    BOM Business Object API Specs and Documentation

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Raghu Manjunath        04/26/00   Created
===========================================================================*/
PROCEDURE call_bom_bo_api (
   p_bom_header_rec    IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
				Bom_Bo_Pub.G_MISS_BOM_HEADER_REC,
   p_component_tbl     IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
				Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL,
   p_subs_comp_tbl     IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
				Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL,
   x_error_code        IN OUT NOCOPY   NUMBER,
   x_error_msg         IN OUT NOCOPY   VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:       set_common_bill_new

===========================================================================*/

PROCEDURE set_common_bill_new (
        p_co_product_group_id   IN  NUMBER,
        p_organization_id       IN  NUMBER,
        p_organization_code     IN  VARCHAR2,
        p_alternate_designator  IN  VARCHAR2,
        x_error_code            OUT NOCOPY  NUMBER,
        x_error_msg             OUT NOCOPY  VARCHAR2);

-- Declare some global variables for use by the BOM BO API
g_bom_header_rec Bom_Bo_Pub.Bom_Head_Rec_Type :=
				Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
g_component_tbl  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
g_subs_comp_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
                                Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
g_subs_component_count NUMBER := 0;

--for debug only
--g_iteration_count	NUMBER := 0;

END;

 

/
