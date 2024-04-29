--------------------------------------------------------
--  DDL for Package EGO_STYLE_SKU_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_STYLE_SKU_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOSITMS.pls 120.12 2007/10/09 21:35:36 mantyaku noship $ */

  G_MISS_NUM                CONSTANT  NUMBER       :=  9.99E125;
  G_MISS_CHAR               CONSTANT  VARCHAR2(1)  :=  CHR(0);
  G_MISS_DATE               CONSTANT  DATE         :=  TO_DATE('1','j');
  G_FALSE                   CONSTANT  VARCHAR2(1)  :=  FND_API.G_FALSE; -- 'F'
  G_TRUE                    CONSTANT  VARCHAR2(1)  :=  FND_API.G_TRUE;  -- 'T'

  FUNCTION IsStyle_Item_Exist_For_ICC
  (
    p_item_catalog_group_id          IN   NUMBER
  ) RETURN VARCHAR2;

  FUNCTION IsSKU_Item_Exist_For_ICC
  (
    p_item_catalog_group_id          IN   NUMBER
  ) RETURN VARCHAR2;

  PROCEDURE Process_Items
  (
      p_set_process_id                 IN   NUMBER
     ,p_Process_Flag                   IN   NUMBER
     ,p_commit                         IN   VARCHAR2   DEFAULT  G_FALSE
     ,p_Transaction_Type               IN   VARCHAR2   DEFAULT  NULL
     ,p_Template_Id                    IN   NUMBER     DEFAULT  NULL
     ,p_copy_inventory_item_Id         IN   NUMBER     DEFAULT  NULL
     ,p_copy_revision_Id               IN   NUMBER     DEFAULT  NULL
     ,p_inventory_item_id              IN   NUMBER     DEFAULT  NULL
     ,p_organization_id                IN   NUMBER     DEFAULT  NULL
     ,p_description                    IN   VARCHAR2   DEFAULT  NULL
     ,p_long_description               IN   VARCHAR2   DEFAULT  NULL
     ,p_primary_uom_code               IN   VARCHAR2   DEFAULT  NULL
     ,p_primary_unit_of_measure        IN   VARCHAR2   DEFAULT  NULL
     ,p_item_type                      IN   VARCHAR2   DEFAULT  NULL
     ,p_inventory_item_status_code     IN   VARCHAR2   DEFAULT  NULL
     ,p_allowed_units_lookup_code      IN   NUMBER     DEFAULT  NULL
     ,p_item_catalog_group_id          IN   NUMBER     DEFAULT  NULL
     ,p_bom_enabled_flag               IN   VARCHAR2   DEFAULT  NULL
     ,p_eng_item_flag                  IN   VARCHAR2   DEFAULT  NULL
     ,p_weight_uom_code                IN   VARCHAR2   DEFAULT  NULL
     ,p_unit_weight                    IN   NUMBER     DEFAULT  NULL
     ,p_Item_Number                    IN   VARCHAR2   DEFAULT  NULL
     ,p_Style_Item_Flag                IN   VARCHAR2   DEFAULT  NULL
     ,p_Style_Item_Id                  IN   NUMBER     DEFAULT  NULL
     ,p_Style_Item_Number              IN   VARCHAR2   DEFAULT  NULL
     ,p_Gdsn_Outbound_Enabled_Flag     IN   VARCHAR2   DEFAULT  NULL
     ,p_Trade_Item_Descriptor          IN   VARCHAR2   DEFAULT  NULL
  ) ;

  PROCEDURE Process_Items
  (
     p_commit                         IN   VARCHAR2  DEFAULT  G_FALSE
    ,p_Item_Intf_Data_Tab             IN OUT NOCOPY  EGO_ITEM_INTF_DATA_TAB
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY  NUMBER
  );

  /*
   * This API validates that the variant attribute combination for the SKU
   * is unique. It also inserts the record if combination does not exists
   * This API sets x_sku_exists as TRUE if combination already exists
   * This API sets x_sku_exists as FALSE if combination is not found
   * This API sets x_var_attrs_missing as TRUE if some variant attribute
   *  values are missing.
   *
   * This API returns 0 if no unexpected errors are there, else
   * returns the SQLCODE
   *
   * This API assumes that INVENTORY_ITEM_ID will be present in the intf table
   */
  FUNCTION Validate_SKU_Variant_Usage( p_intf_row_id          IN ROWID
                                      , x_sku_exists          OUT NOCOPY BOOLEAN
                                      , x_var_attrs_missing   OUT NOCOPY BOOLEAN
                                      , x_err_text            OUT NOCOPY VARCHAR2
                                     )
  RETURN INTEGER;

  FUNCTION Default_Style_Variant_Attrs(p_inventory_item_id     IN NUMBER,
                                       p_item_catalog_group_id IN NUMBER,
                                       x_err_text      OUT NOCOPY VARCHAR2)
  RETURN INTEGER;

  /*
   * This method returns FND_API.G_TRUE or FND_API.G_FALSE
   * This method computes whether it is ok to have the new parent ICC
   * wrt style functionality i.e. we should not allow a ICC that has
   * different variant attributes than that are currently associated
   * with the ICC, if ICC already has some styles created.
   */
  FUNCTION Is_Parent_ICC_Valid_For_Style(p_item_catalog_group_id    NUMBER,
                                         p_parent_catalog_group_id  NUMBER)
  RETURN VARCHAR2;

  /*
   * This method inserts a Fake row in the interface table.
   */
  PROCEDURE Insert_Fake_Row_For_Item( p_commit                 IN VARCHAR2 DEFAULT G_FALSE
                                     ,p_batch_id               IN NUMBER
                                     ,p_inventory_item_id      IN NUMBER
                                     ,p_organization_id        IN NUMBER
                                     ,p_item_number            IN VARCHAR2
                                     ,p_style_item_flag        IN VARCHAR2
                                     ,p_style_item_id          IN NUMBER
                                     ,p_item_catalog_group_id  IN NUMBER
                                     ,x_return_status          OUT NOCOPY VARCHAR2
                                     ,x_msg_data               OUT NOCOPY VARCHAR2);

  /*
   * This method inserts Role records for SKUs in the item people interface table.
   */
  PROCEDURE Propagate_Role_To_SKUs ( p_commit                 IN VARCHAR2 DEFAULT G_FALSE
                                    ,p_batch_id               IN NUMBER
                                    ,p_style_item_id          IN NUMBER
                                    ,p_organization_id        IN NUMBER
                                    ,p_role_name              IN VARCHAR2
                                    ,p_grantee_type           IN VARCHAR2
                                    ,p_grantee_party_id       IN NUMBER
                                    ,p_end_date               IN DATE
                                    ,x_return_status          OUT NOCOPY VARCHAR2
                                    ,x_msg_data               OUT NOCOPY VARCHAR2);

  /*
   * This method inserts Category assignment records for SKUs in the mtl categories interface table.
   */
  PROCEDURE Propagate_Category_To_SKUs ( p_commit                 IN VARCHAR2 DEFAULT G_FALSE
                                        ,p_batch_id               IN NUMBER
                                        ,p_style_item_id          IN NUMBER
                                        ,p_organization_id        IN NUMBER
                                        ,p_category_set_id        IN NUMBER
                                        ,p_category_id            IN NUMBER
                                        ,x_return_status          OUT NOCOPY VARCHAR2
                                        ,x_msg_data               OUT NOCOPY VARCHAR2);

END EGO_STYLE_SKU_ITEM_PVT;

/
