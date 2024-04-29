--------------------------------------------------------
--  DDL for Package EGO_GTIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_GTIN_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOUCCPS.pls 120.8 2007/03/27 16:59:27 dsakalle ship $ */

  --Global Variables
  TYPE REF_CURSOR_TYPE IS REF CURSOR;

  /* Public API for getting the Publication Status
  **
  */

  FUNCTION Get_Publication_Status
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN VARCHAR2;


  FUNCTION Get_Publication_Status
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN VARCHAR2;

  FUNCTION Get_Publication_Status_Code
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN VARCHAR2;


  FUNCTION Get_Publication_Status_Code
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN VARCHAR2;



  FUNCTION Is_Not_Published
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Publication_In_Prog
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Published
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN BOOLEAN;


  FUNCTION Is_Re_Publish_Needed
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Withdrawn
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Rejected
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
   , p_gln                        IN  VARCHAR2
   , p_customer_id                IN  NUMBER
   , p_address_id                 IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Delisted
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN BOOLEAN;



  /* Public API for getting the Registration Status
  **
  */

  FUNCTION Get_Registration_Status
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN VARCHAR2;

  FUNCTION Get_Registration_Status_Code
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN VARCHAR2;


  FUNCTION Is_Not_Registered
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Registration_In_Prog
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Is_Registered
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN BOOLEAN;


  FUNCTION Is_Re_Register_Needed
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN BOOLEAN;


  /*
  * This API will return 'Y' if the item with p_inventory_item_id, p_org_id has ever been published
  * to any customers before. Else, this API will return 'N'
  */
  FUNCTION Is_Globally_Published
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN VARCHAR2;

  /* Bug 5523228 - API validates the Unit wt and wt uom against Trade Item Descriptor */
  FUNCTION Validate_Unit_Wt_Uom
  (  p_inventory_item_id          IN  NUMBER
   , p_org_id                     IN  NUMBER
  ) RETURN VARCHAR2;

  /*
  * Added by Nisar and is called from IOI Category update to handle update of UDex Catalog.
  */
  PROCEDURE PROCESS_CAT_ASSIGNMENT ( p_inventory_item_id NUMBER,
                                   p_organization_id   NUMBER);

  /*
  ** Added by Devendra - This method will be called from Items IOI.
  *  This procedure will validate the MSI attributes for UCCnet and will call PROCESS_ATTRIBUTE_UPDATES
  */
  PROCEDURE PROCESS_UCCNET_ATTRIBUTES (P_Prog_AppId  NUMBER  DEFAULT -1,
                                     P_Prog_Id     NUMBER  DEFAULT -1,
                                     P_Request_Id  NUMBER  DEFAULT -1,
                                     P_User_Id     NUMBER  DEFAULT -1,
                                     P_Login_Id    NUMBER  DEFAULT -1,
                                     P_Set_id      NUMBER  DEFAULT -999,
                                     P_Suppress_Rollup VARCHAR2 DEFAULT 'N'
                                    );



  /*
  ** Added by Devendra - for updation of REGISTRATION_LAST_UPDATE_DATE and TP_NEUTRAL_LAST_UPDATE_DATE
  */
  PROCEDURE PROCESS_ATTRIBUTE_UPDATES (p_inventory_item_id NUMBER,
                                     p_organization_id   NUMBER,
                                     p_attribute_names   EGO_VARCHAR_TBL_TYPE,
                                     p_commit            VARCHAR2 := FND_API.G_FALSE,
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_msg_count         OUT NOCOPY NUMBER,
                                     x_msg_data          OUT NOCOPY VARCHAR2);

  /*
  ** Added by Devendra - This method will update the REGISTRATION_UPDATE_DATE and TP_NEUTRAL_UPDATE_DATE
  **  for an item. If parameter p_update_reg is supplied as 'Y' then REGISTRATION_UPDATE_DATE and
  **  TP_NEUTRAL_UPDATE_DATE will be updated else only TP_NEUTRAL_UPDATE_DATE will be updated.
  */
  PROCEDURE UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id NUMBER,
                                       p_organization_id   NUMBER,
                                       p_update_reg        VARCHAR2 := 'N',
                                       p_commit            VARCHAR2 := FND_API.G_FALSE,
                                       x_return_status     OUT NOCOPY VARCHAR2,
                                       x_msg_count         OUT NOCOPY NUMBER,
                                       x_msg_data          OUT NOCOPY VARCHAR2);


  /*
  ** Added by Amay - for propagation of attributes up the hierarchy
  */
  PROCEDURE Item_Propagate_Attributes
        ( p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN VARCHAR2
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , x_error_message                 OUT NOCOPY VARCHAR2
        );

  /*
  ** Added by Amay - for setting of attributes (called by BOM_COMPUTE_FUNCTIONS)
  */
  PROCEDURE Update_Attribute
        ( p_inventory_item_id             IN NUMBER
        , p_organization_id               IN NUMBER
        , p_attr_name                     IN VARCHAR2
        , p_attr_group_type               IN VARCHAR2 DEFAULT NULL
        , p_attr_group_name               IN VARCHAR2 DEFAULT NULL
        , p_attr_new_value_str            IN VARCHAR2 DEFAULT NULL
        , p_attr_new_value_num            IN NUMBER   DEFAULT NULL
        , p_attr_new_value_date           IN DATE     DEFAULT NULL
        , p_attr_new_value_uom            IN VARCHAR2 DEFAULT NULL
        , p_debug_level                   IN NUMBER   DEFAULT 0
        , x_return_status                 OUT NOCOPY VARCHAR2
        , x_errorcode                     OUT NOCOPY NUMBER
        , x_msg_count                     OUT NOCOPY NUMBER
        , x_msg_data                      OUT NOCOPY VARCHAR2
        );

  /*
  ** Added by Amay - for setting of attributes (called by BOM_COMPUTE_FUNCTIONS)
  */
  PROCEDURE Update_Attributes
        ( p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN VARCHAR2
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , x_error_message                 OUT NOCOPY VARCHAR2
        );

  /*
  ** Added by Amay - for getting of attribute diff objects (called by BOM_ROLLUP_PUB)
  */
  PROCEDURE Get_Attr_Diffs
        ( p_inventory_item_id             IN NUMBER
        , p_org_id                        IN NUMBER
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , p_application_id                IN NUMBER DEFAULT NULL
        , p_attr_group_type               IN VARCHAR2 DEFAULT NULL
        , p_attr_group_name               IN VARCHAR2 DEFAULT NULL
        , px_attr_diffs                   IN OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
        , px_pk_column_name_value_pairs    OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        , px_class_code_name_value_pairs   OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        , px_data_level_name_value_pairs   OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        , x_error_message                 OUT NOCOPY VARCHAR2
        );

  /*
  ** Added by Amay - for setting of special case attribute TOP_GTIN
  */
  PROCEDURE Set_Top_GTIN_Flag
        ( p_inventory_item_id             IN NUMBER
        , p_organization_id               IN NUMBER
        , p_top_gtin_flag                 IN VARCHAR2
        , x_return_status                 OUT NOCOPY VARCHAR2
        );

  Function Is_Attribute_Group_Associated
        ( p_application_id                IN NUMBER
        , p_attr_group_type               IN VARCHAR2
        , p_attr_group_name               IN VARCHAR2
        , p_inventory_item_id             IN NUMBER
        , p_organization_id               IN NUMBER
        )
  RETURN BOOLEAN;

  PROCEDURE Seed_Uccnet_Attributes_Pages;

  FUNCTION Is_In_Sync_customer
    ( p_inventory_item_id      IN NUMBER
    , p_org_id                 IN NUMBER
    , p_address_id             IN NUMBER
    , p_explode_group_id       IN NUMBER
    ) RETURN VARCHAR2;

  /*
   * This method validates SBDH attributes. p_address_id is mandatory and not null
   * returns a data object containing all errors
   */
  PROCEDURE Validate_SBDH_Attributes(p_inventory_item_id       NUMBER,
                                     p_organization_id         NUMBER,
                                     p_address_id              NUMBER,
                                     p_errors              OUT NOCOPY REF_CURSOR_TYPE);

  /*
   * This method validates SBDH attributes. p_address_id is mandatory and not null
   * returns 'F' if some validation fails
   */
  FUNCTION Is_SBDH_Attributes_Valid(p_inventory_item_id       NUMBER,
                                    p_organization_id         NUMBER,
                                    p_address_id              NUMBER) RETURN VARCHAR2;

  /*
   * This procedure is added as a part of fix for bug: 3983838
   * This procedure is called from User Defined attributes EO i.e. EgoMtlSyItemsExtVLEOImpl
   * If any Extension GDSN attributes are updated, we update the TP_NEUTRAL_UPDATE_DATE or
   * LAST_UPDATE_DATE of EGO_ITEM_TP_ATTRS_EXT_B, depending upon whether the Attibute group
   * is TP-Dependant or not.
   */
  PROCEDURE PROCESS_EXTN_ATTRIBUTE_UPDATES (p_inventory_item_id NUMBER,
                                            p_organization_id   NUMBER,
                                            p_attribute_names   EGO_VARCHAR_TBL_TYPE,
                                            p_attr_group_name   VARCHAR2,
                                            p_commit            VARCHAR2 := FND_API.G_FALSE,
                                            x_return_status     OUT NOCOPY VARCHAR2,
                                            x_msg_count         OUT NOCOPY NUMBER,
                                            x_msg_data          OUT NOCOPY VARCHAR2);

  PROCEDURE PROCESS_GTID_UPDATE (p_inventory_item_id NUMBER,
                                 p_organization_id   NUMBER,
                                 p_trade_item_desc   VARCHAR2,
                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 x_msg_data          OUT NOCOPY VARCHAR2);

END EGO_GTIN_PVT;

/
