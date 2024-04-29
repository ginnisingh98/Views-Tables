--------------------------------------------------------
--  DDL for Package BOM_COMPUTE_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COMPUTE_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: BOMCMPFS.pls 120.0 2005/05/25 04:26:55 appldev noship $ */
/*# This package defines the atttribute Compute functions and Rollup compute functions
 * Whenever an item attribute needs to have computation based on related attributes
 * a computation function can be added and registered in the Attribute Map. Only
 * function per attribute is permitted.
 * Similarly, Rollup functions help in computing the value of a Parent in a Parent
 * Child relationship.
 * For eg. Container's wt = Wt. of Container item + 1..n[Sum(qty of child * unit wt of child)]
 * A rollup function is expected to impact atmost 1 attribute of the parent.
 * When rollup functions are registered, it is not required for them to always belong to this
 * package, but are expected to conform to the input/output parameter restrictions.
 * @rep:scope private
 * @rep:product BOM
 * @rep:displayname Rollup Functions
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/


  /*#
  * This method will be used for computing the net_weight attributes value
  * The method does not have any parameters, but it will have access to the
  * attribute map or the current item in process.
  * This should not be confused with the actual rollup function. This function
  * helps the derivation of the net_weight attribute for that particulat item
  * whereas rollup function of net_weight would take into consideration all the
  * child components of the current item.
  * @param p_component_sequence_id IN Component Identifier
  * @param x_attribute_value OUT Attribute Value
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Compute Net weight
  */
        PROCEDURE Compute_Net_Weight( x_attribute_value IN OUT NOCOPY VARCHAR2
            , p_component_sequence_id IN OUT NOCOPY NUMBER);

        /*#
        * This method will be used for computing the net_weight attributes value
        * The method does not have any parameters, but it will have access to the
        * attribute map or the current item in process.
        * This should not be confused with the actual rollup function. This function
        * helps the derivation of the net_weight attribute for that particulat item
        * whereas rollup function of net_weight would take into consideration all the
        * child components of the current item.
        *
  * @param p_component_sequence_id IN Component Identifier
        * @param x_attribute_value OUT Attribute Value
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Compute Net weight
        */
        PROCEDURE Compute_Gross_Weight( x_attribute_value IN OUT NOCOPY VARCHAR2
              , p_component_sequence_id IN OUT NOCOPY NUMBER
              );

        /*#
        * This method will be used for computing the net_weight attributes value
        * The method does not have any parameters, but it will have access to the
        * attribute map or the current item in process.
        * This should not be confused with the actual rollup function. This function
        * helps the derivation of the net_weight attribute for that particulat item
        * whereas rollup function of net_weight would take into consideration all the
        * child components of the current item.
        * To call this function create an action map by calling Bom_Rollup_Pub.Add_Rollup_Action
        * with Bom_Rollup_Pub.G_COMPUTE_GROSS_WEIGHT
        *
        * @param p_header_item_id IN Header Item Identifier
        * @param p_organization_id IN Header Item's Organization Identifier
        * @param p_validate IN Flag specifying whether to perform validation
        * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
        * @param x_return_status OUT Return Status
        * @param x_error_message OUT Error Message
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Rollup Net weight
        */
  PROCEDURE Rollup_Net_Weight(p_header_item_id    IN NUMBER DEFAULT NULL
                             ,p_organization_id   IN NUMBER DEFAULT NULL
                             ,p_validate          IN VARCHAR2
                             ,p_halt_on_error     IN VARCHAR2
                             ,x_return_status     OUT NOCOPY VARCHAR2
                             ,x_error_message     OUT NOCOPY VARCHAR2
                             );


        /*#
        * This method will be used for computing the net_weight attributes value
        * The method does not have any parameters, but it will have access to the
        * attribute map or the current item in process.
        * This is the actual rollup function. This function
        * helps the derivation of the gross_weight attribute for a parent item.
  * To call this function create an action map by calling Bom_Rollup_Pub.Add_Rollup_Action
  * with Bom_Rollup_Pub.G_COMPUTE_NET_WEIGHT
        *
        * @param p_header_item_id IN Header Item Identifier
        * @param p_organization_id IN Header Item's Organization Identifier
        * @param p_validate IN Flag specifying whether to perform validation
        * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
        * @param x_return_status OUT Return Status
        * @param x_error_message OUT Error Message
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Rollup Net weight
        */
  PROCEDURE Rollup_Gross_Weight(p_header_item_id    IN NUMBER DEFAULT NULL
                               ,p_organization_id   IN NUMBER DEFAULT NULL
                               ,p_validate          IN VARCHAR2
                               ,p_halt_on_error     IN VARCHAR2
                               ,x_return_status     OUT NOCOPY VARCHAR2
                               ,x_error_message     OUT NOCOPY VARCHAR2
                               );

        /*#
        * This method will be used for propogating value of Private Flag.
        * Propogation of Private flag is based on a simple rule:
  * A non-private Parent cannot have a Private Child.
  * This attribute will be propogated in 2 cases:
  * 1. When user added a private component to a public parent
  * 2. When private flag atttribute changes from N to Y for a GTIN
  *
  * To call this function create an action map by calling Bom_Rollup_Pub.Add_Rollup_Action
  * with Bom_Rollup_Pub.G_PROPOGATE_PRIVATE_FLAG
        * @param p_header_item_id IN Header Item Identifier
        * @param p_organization_id IN Header Item's Organization Identifier
        * @param p_validate IN Flag specifying whether to perform validation
        * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
        * @param x_return_status OUT Return Status
        * @param x_error_message OUT Error Message
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Propogate Private Flag
        */
  PROCEDURE Propogate_Private_Flag(p_header_item_id   IN NUMBER DEFAULT NULL
                                  ,p_organization_id   IN NUMBER DEFAULT NULL
                                  ,p_validate          IN VARCHAR2
                                  ,p_halt_on_error     IN VARCHAR2
                                  ,x_return_status     OUT NOCOPY VARCHAR2
                                  ,x_error_message     OUT NOCOPY VARCHAR2
                                  );

        /*#
        * This method will be used for propogating value of Private Flag.
        * Propogation of Private flag is based on a simple rule:
        * A non-private Parent cannot have a Private Child.
        * This attribute will be propogated in 2 cases:
        * 1. When user added a private component to a public parent
        * 2. When private flag atttribute changes from N to Y for a GTIN
        *
        * @param p_header_item_id IN Header Item Identifier
        * @param p_organization_id IN Header Item's Organization Identifier
        * @param p_validate IN Flag specifying whether to perform validation
        * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
        * @param x_return_status OUT Return Status
        * @param x_error_message OUT Error Message
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Propogate Brand Info
        */
        PROCEDURE Propogate_Brand_Info(p_header_item_id         IN NUMBER DEFAULT NULL
                                     ,p_organization_id   IN NUMBER DEFAULT NULL
                                     ,p_validate          IN VARCHAR2
                                     ,p_halt_on_error     IN VARCHAR2
                                     ,x_return_status     OUT NOCOPY VARCHAR2
                                     ,x_error_message     OUT NOCOPY VARCHAR2
                                     );


        /*#
        * This method will compute the TOP GTIN flag.
        * Computation of TOP GTIN is based on 2 flags, Consumable and Orderable other than the fact
        * that both the Parent Item and Component Item have to be GTINs.
        * At any time there are atmost 2 rows that will be affected, one is the current row
        * and second is the top item.
        * Following matrix explains which combination evaluates to a Top GTIN flag of Yes:
        * All other conditions evaluate to a Top GTIN flag = No.
        * ---------------------------------------------------
        * | Top Item Flag | Consumable     | Orderable      |
        * ---------------------------------------------------
        * | Yes           | Component Item | Component Item |
        * | -------------------------------------------------
        * | Yes           | Component Item | Top Item       |
        * | -------------------------------------------------
        * | Yes           | Top Item       | Component Item |
        * | -------------------------------------------------
        * | Yes           | Top Item       | Top Item       |
        * | -------------------------------------------------
        *
  * To call this function create an action map by calling Bom_Rollup_Pub.Add_Rollup_Action
  * with Bom_Rollup_Pub.G_COMPUTE_TOP_GTIN_FLAG
  *
        * @param p_header_item_id IN Header Item Identifier
        * @param p_organization_id IN Header Item's Organization Identifier
        * @param p_validate IN Flag specifying whether to perform validation
        * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
        * @param x_return_status OUT Return Status
        * @param x_error_message OUT Error Message
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Compute Top GTIN Flag
        */
  PROCEDURE Propogate_Top_GTIN_Flag
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  );


  /*#
   * This method will compute the MultirowAttrs.
   * To call this function create an action map by calling Bom_Rollup_Pub.Add_Rollup_Action
   * with Bom_Rollup_Pub.G_COMPUTE_MULTI_ROW_ATTRS
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_validate IN Flag specifying whether to perform validation
   * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
   * @param x_return_status OUT Return Status
   * @param x_error_message OUT Error Message
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Compute Top GTIN Flag
   */
  PROCEDURE Compute_Multi_Row_Attrs
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  );

  /*#
   * This method will copy storage and handling temperature maximums, minimums, and uoms.
   * To call this function create an action map by calling Bom_Rollup_Pub.Add_Rollup_Action
   * with Bom_Rollup_Pub.G_PROPAGATE_SH_TEMPS
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_validate IN Flag specifying whether to perform validation
   * @param p_halt_on_error IN Flag specifying whether to halt on validation errors
   * @param x_return_status OUT Return Status
   * @param x_error_message OUT Error Message
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Propagate SH Temps
   */
  PROCEDURE Propagate_SH_Temps
                  (p_header_item_id    IN NUMBER DEFAULT NULL
                  ,p_organization_id   IN NUMBER DEFAULT NULL
                  ,p_validate          IN VARCHAR2
                  ,p_halt_on_error     IN VARCHAR2
                  ,x_return_status     OUT NOCOPY VARCHAR2
                  ,x_error_message     OUT NOCOPY VARCHAR2
                  );

  /*#
   * This method is the DML Function for Net Weight and UOM
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_header_attrs_flag IN Flag that is 'Y' if using Header Attributes Map
   * @param x_return_status OUT Return Status
   * @param x_msg_count OUT Message Count
   * @param x_msg_data OUT Message Data
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Set Net Weight
   */
  PROCEDURE Set_Net_Weight
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2 DEFAULT 'Y'
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      );

  /*#
   * This method is the DML Function for Private Flag
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_header_attrs_flag IN Flag that is 'Y' if using Header Attributes Map
   * @param x_return_status OUT Return Status
   * @param x_msg_count OUT Message Count
   * @param x_msg_data OUT Message Data
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Set Private Flag
   */
  PROCEDURE Set_Private_Flag
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2 DEFAULT 'Y'
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      );

  /*#
   * This method is the DML Function for Brand Info
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_header_attrs_flag IN Flag that is 'Y' if using Header Attributes Map
   * @param x_return_status OUT Return Status
   * @param x_msg_count OUT Message Count
   * @param x_msg_data OUT Message Data
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Set Brand Info
   */
  PROCEDURE Set_Brand_Info
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2 DEFAULT 'Y'
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      );

  /*#
   * This method is the DML Function for Top GTIN Flag
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_header_attrs_flag IN Flag that is 'Y' if using Header Attributes Map
   * @param x_return_status OUT Return Status
   * @param x_msg_count OUT Message Count
   * @param x_msg_data OUT Message Data
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Set Top GTIN Flag
   */
  PROCEDURE Set_Top_GTIN_Flag
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2 DEFAULT 'Y'
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      );

  /*#
   * This method is the DML Function for Multirow Attributes
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_header_attrs_flag IN Flag that is 'Y' if using Header Attributes Map
   * @param x_return_status OUT Return Status
   * @param x_msg_count OUT Message Count
   * @param x_msg_data OUT Message Data
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Set Multirow Attributes
   */
  PROCEDURE Set_Multirow_Attributes
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2 DEFAULT 'Y'
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      );

  /*#
   * This method is the DML Function for Storage Handling Temps
   *
   * @param p_header_item_id IN Header Item Identifier
   * @param p_organization_id IN Header Item's Organization Identifier
   * @param p_header_attrs_flag IN Flag that is 'Y' if using Header Attributes Map
   * @param x_return_status OUT Return Status
   * @param x_msg_count OUT Message Count
   * @param x_msg_data OUT Message Data
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Set SH Temps
   */
  PROCEDURE Set_SH_Temps
      ( p_Header_Item_Id    IN  NUMBER
      , p_Organization_Id   IN  NUMBER
      , p_Header_Attrs_Flag IN  VARCHAR2 DEFAULT 'Y'
      , x_return_status     OUT NOCOPY VARCHAR2
      , x_msg_count         OUT NOCOPY NUMBER
      , x_msg_data          OUT NOCOPY VARCHAR2
      );
END Bom_Compute_Functions;

 

/
