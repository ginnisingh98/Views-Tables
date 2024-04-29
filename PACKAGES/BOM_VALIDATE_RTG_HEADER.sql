--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_RTG_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_RTG_HEADER" AUTHID CURRENT_USER AS
/* $Header: BOMLRTGS.pls 120.2 2006/05/23 04:55:13 bbpatel noship $*/
/*#
 * This API performs Attribute and Entity level validations for Routing Header.
 * Entity level validations include existence and accessibility check for Routing
 * Header record. Attribute level validations include check for required attributes and
 * business logic validations.
 *
 * @rep:scope private
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Validate Routing Header
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
 */

/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLRTGS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_RTG_Header
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00   Biao Zhang   Initial Creation
--
****************************************************************************/

        /*#
         * Procedure will query the routing header record and return it in old record variable.
         * If the Transaction Type is Create and the record already exists the return status
         * would be error. If the Transaction Type is Update or Delete and the record does not
         * exist then the return status would be an error as well. Such an error in a record will
         * cause all children to error out, since they are referencing an invalid parent.
         * Mesg_Token_Table will carry the error messsage and the tokens associated with the message.
         *
         * @param p_rtg_header_rec IN Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_old_rtg_header_rec IN OUT NOCOPY Routing Header Exposed Record if already exists
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param x_old_rtg_header_unexp_rec IN OUT NOCOPY Routing Header Unexposed Record if already exists
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check Existence for Routing Header record
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_Existence
        (  p_rtg_header_rec         IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
         , p_rtg_header_unexp_rec   IN  Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
         , x_old_rtg_header_rec     IN OUT NOCOPY Bom_Rtg_Pub.Rtg_header_Rec_Type
         , x_old_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        );

        /*#
         * This procedure checks for the access rights of the user on the item for which an operation is performed
         * on routing. An assembly item and any of its child entities can not be operated upon if the user
         * does not have access to the assembly item type. This procedure compares assembly item's
         * BOM_Item_Type against the assembly item access fields in the profile system values.
         *
         * @param p_assembly_item_name IN Assembly Item Name
         * @param p_assembly_item_id IN Assembly Item Id
         * @param p_alternate_rtg_code IN Alternate Routing Code
         * @param p_organization_id IN Organization Id in which item is defined
         * @param p_mesg_token_tbl IN Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check Access for Assembly Item
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_Access
        (  p_assembly_item_name    IN  VARCHAR2
         , p_assembly_item_id      IN  NUMBER
         , p_alternate_rtg_code    IN  VARCHAR2
         , p_organization_id       IN  NUMBER
         , p_mesg_token_tbl        IN  Error_Handler.Mesg_Token_Tbl_Type
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        );


        /*#
         * This procedure checks the flow routing operability depending on CFM_Routing_Flag value.
         * Valid CFM_Routing_Flag values are null, 1, 2, 3. For value 1, Flow Manufacturing should be
         * installed. For value 3, organization should be WSM enabled. For EAM Item Type=2, CFM_Routing_Flag value
         * should be equal to 2. For Lot based routing, check if organization is EAM enabled.
         * Finally set CFM Routing Flag to System Info Record.
         *
         * @param p_assembly_item_name IN Assembly Item Name
         * @param p_cfm_routing_flag IN CFM Routing Flag
         * @param p_organization_code IN Organization Code in which item is defined
         * @param p_organization_id IN Organization Id in which item is defined
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param x_return_status IN OUT NOCOPY Return Status
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check validity of Flow Routing Operability
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_flow_routing_operability
        (  p_assembly_item_name    IN  VARCHAR2
         , p_cfm_routing_flag      IN  NUMBER
         , p_organization_code     IN  VARCHAR2
         , p_organization_id       IN  NUMBER
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        );


        /*#
         * This procedure checks the attributes validity. Validations include check for
         * Eng_Rtg, Mixed_Model_Map, CTP and CFM_Routing Flag.
         *
         * @param x_return_status IN OUT NOCOPY Return Status
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param p_rtg_header_rec IN Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         * @param p_old_rtg_header_rec IN Existing Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_old_rtg_header_unexp_rec IN Existing Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check Routing Header attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_Attributes
        (  x_return_status          IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_rtg_header_Rec         IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
         , p_rtg_header_unexp_rec   IN  Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
         , p_old_rtg_header_rec     IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
         , p_old_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
        );

        /*#
         * Procedure to check the required attributes for the Routing Header record.
         * Some fields are required for an operation to be performed. The user must enter values
         * for these fields.
         * This procedure checks whether the required field columns are not NULL. It raises
         *    1 Severe Error IV for if the Transaction Type is Create
         *    2 Standard Error for other Transaction Types.
         *
         * @param x_return_status IN OUT NOCOPY Return Status
         * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
         * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
         * @param p_rtg_header_rec IN Routing Header Exposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
         * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
         * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
         *
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Check Routing Header required attributes
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        PROCEDURE Check_Required
        (  x_return_status      IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_rtg_header_Rec     IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         );
/*
        PROCEDURE Check_Entity
        ( p_rtg_header_rec       IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
        , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
        , p_old_rtg_header_rec   IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
        , p_old_rtg_header_unexp_rec IN Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
        , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status      IN OUT NOCOPY VARCHAR2
        );
*/
       /*#
        * Procedure to validate the Routing Header entity record.
        * The following are checked.
        *	Non-updateable columns (UPDATEs): Certain columns must not be changed by the user when updating the record
        *	Cross-attribute checking: The validity of attributes may be checked, based on factors external to it
        *	Business logic: The record must comply with business logic rules.
        *
        * @param p_rtg_header_rec IN Routing Header Exposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
        * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
        * @param p_old_rtg_header_rec IN Existing Routing Header Exposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
        * @param p_old_rtg_header_unexp_rec IN Existing Routing Header Unexposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
        * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
        * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
        * @param x_return_status IN OUT NOCOPY Return Status
        *
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Check Routing Header entity
        * @rep:compatibility S
        * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
        */
        PROCEDURE Check_Entity
        ( p_rtg_header_rec       IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , p_old_rtg_header_rec   IN  Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_old_rtg_header_unexp_rec IN Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status       IN OUT NOCOPY VARCHAR2
         );


       /*#
        * This procedure checks the validity of the delete group for the Routing Header Record in case of
        * Transaction Type as Delete. Check for delete group include valid delete group, new or duplicate
        * delete group. This procedure will be called before adding a Routing Header entity to a delete group.
        *
        * @param x_return_status IN OUT NOCOPY Return Status
        * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
        * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
        * @param p_rtg_header_rec IN Routing Header Exposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
        * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
        * @param x_rtg_header_unexp_rec IN OUT NOCOPY Unexposed Routing Header record after updating delete groups
        * related attributes
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type }
        *
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Check Routing Header Delete entity
        * @rep:compatibility S
        * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
        */
        PROCEDURE Check_Entity_Delete
        ( x_return_status       IN OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , p_rtg_header_rec      IN  Bom_Rtg_Pub.Rtg_header_Rec_Type
        , p_rtg_header_Unexp_Rec  IN  Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
        , x_rtg_header_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type
         );


        /*#
         * This procedure will take the organization, sub-inventory, item level control
         * values and the number specifying if the Locator is controlled at the
         * org, sub-inventory or item level. It will also decide
         * if the locator is pre-specified or dynamic.
         *
         * @param org_control IN Organization Level Control
         * @param sub_control IN Sub-inventory Level Control
         * @param item_control IN Item Level Control
         *
         * @return Locator Control
         * @rep:scope private
         * @rep:lifecycle active
         * @rep:displayname Get the Locator Control
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
         */
        FUNCTION CONTROL(org_control      IN    number,
                         sub_control      IN    number,
                         item_control     IN    number default NULL)
        RETURN NUMBER ;

       /*#
        * Procedure to check Serialization Starting Operation Sequence(SSOS) Number.
        *
        * @param p_rtg_header_rec IN Routing Header Exposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Rec_Type }
        * @param p_rtg_header_unexp_rec  IN Routing Header Unexposed Record
        * @paraminfo {@rep:innertype Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type}
        * @param x_mesg_token_tbl IN OUT NOCOPY output Message Token Table with proper error or warning messages
        * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
        * @param x_return_status IN OUT NOCOPY Return Status
        *
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Check SSOS
        * @rep:compatibility S
        * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
        */
       PROCEDURE Check_SSOS -- Added for SSOS (bug 2689249)
        ( p_rtg_header_rec	     IN  Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_rtg_header_unexp_rec     IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status            IN OUT NOCOPY VARCHAR2
	);

      /*#
       * Procedure to check that OSFM routings should not get created for non-lot controlled item.
       *
       * @param p_assembly_item_id IN Assembly Item Id
       * @param p_organization_id IN Organization Id in which item is defined
       * @param x_mesg_token_tbl IN OUT NOCOPY Message Token Table
       * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
       * @param x_return_status IN OUT NOCOPY Return Status
       *
       * @rep:scope private
       * @rep:lifecycle active
       * @rep:displayname Check for OSFM Routing for Non-lot controlled item
       * @rep:compatibility S
       * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
       */
       PROCEDURE Check_lot_controlled_item
        (  p_assembly_item_id    IN  NUMBER
         , p_organization_id     IN  NUMBER
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
        );

      /*#
       * Procedure to validate that Serialization Start Operation Sequence number is
       * entered for serial controlled item and it is present on the primary path.
       *
       * @param p_routing_sequence_id Routing Sequence Id
       * @param p_ser_start_op_seq Serialization Start Operation Sequence Number
       * @param p_validate_from_table Validate Serialization Start Operation Sequence Number
       *                              from table or input parameter
       * @param x_mesg_token_tbl Message Token Table
       * @paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
       * @param x_return_status Return Status
       *
       * @rep:scope private
       * @rep:lifecycle active
       * @rep:displayname Validate Serialization Start Operation Sequence number
       * @rep:compatibility S
       * @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
       */
       PROCEDURE Validate_SSOS
        (  p_routing_sequence_id  IN  NUMBER
         , p_ser_start_op_seq     IN  NUMBER
         , p_validate_from_table  IN  BOOLEAN
         , x_mesg_token_tbl       IN  OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN  OUT NOCOPY VARCHAR2
        );

END Bom_Validate_Rtg_Header;

 

/
