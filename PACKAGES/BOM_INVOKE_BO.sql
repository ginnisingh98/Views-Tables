--------------------------------------------------------
--  DDL for Package BOM_INVOKE_BO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_INVOKE_BO" AUTHID DEFINER AS
/* $Header: BOMBIVKS.pls 120.0 2005/05/25 06:03:07 appldev noship $ */
/*#
 * API for invoking  methods in BOM Public packages from a different schema.
 * When integration applications or code with Oracle Bills of Material resides
 * in a different schema, these integration application(s) or code can call the
 * methods in this API to process the Bills of Material.
 * @rep:scope public
 * @rep:product BOM
 * @rep:displayname Invoke Business Object
 * @rep:compatibility S
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBIVKS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Invoke_BO
--
--  NOTES
--
--  HISTORY
--
--  09-MAR-01	Refai Farook	   Initial Creation
--  16-MAR-01   Masanori Kimizuka  Added wrapper procedures for Error_Handlers
--                                 and FND_GLOBALS.Apps_Initialize
--
***************************************************************************/

   -- Invoker for Bom_Bo_Pub.Process_Bom
   /*#
    * This method invokes the Process_BOM procedure.This invokes the Process_Bom procedure
    * in Bom_Bo_Pub public package for creating updating or deleting BOM/Structure Header and all its child entites.
    * @see Bom_Bo_Pub.Process_Bom
    * @param p_bo_identifier IN Business Object Identifier
    * @param p_api_version_number IN API Version Number
    * @param p_init_msg_list IN Message List Initializer flag
    * @param p_bom_header_rec IN BOM Header Exposed Column Record
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
    * @param p_bom_revision_tbl IN BOM Revision Record Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
    * @param p_bom_component_tbl IN BOM Component Record Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
    * @param p_bom_ref_designator_tbl IN BOM Reference Designator Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type}
    * @param p_bom_sub_component_tbl IN BOM Substitute Component Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
    * @param x_bom_header_rec OUT NOCOPY processed BOM Header Exposed Column Record
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
    * @param x_bom_revision_tbl OUT NOCOPY processed BOM Revision Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
    * @param  x_bom_component_tbl OUT NOCOPY processed BOM Component Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
    * @param x_bom_ref_designator_tbl OUT NOCOPY processed BOM Reference Designator Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type}
    * @param x_bom_sub_component_tbl OUT NOCOPY processed BOM Substitute Component Table
    * @paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
    * @param x_return_status OUT NOCOPY Return Status
    * @param x_msg_count OUT NOCOPY Message Count
    * @param p_debug IN Debug Flag
    * @param p_output_dir IN Output Directory for Debug
    * @param p_debug_filename IN Debug File Name
    * @rep:scope public
    * @rep:displayname Invoke Process BOM
    * @rep:compatibility S
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    * @rep:lifecycle active
    */
   PROCEDURE Process_Bom
   (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
    , p_api_version_number      IN  NUMBER := 1.0
    , p_init_msg_list           IN  BOOLEAN := FALSE
    , p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
    , p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
    , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
    , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type :=
                                        Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
    , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
   , x_bom_header_rec          OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
    , x_bom_revision_tbl        OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
    , x_bom_component_tbl       OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
    , x_bom_ref_designator_tbl  OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
    , x_bom_sub_component_tbl   OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , p_debug                   IN  VARCHAR2 := 'N'
    , p_output_dir              IN  VARCHAR2 := NULL
    , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
   );

   -- Invoker for Error_Handler procedures/functions
   /*#
    * This is the invoke call for Initialize method in Error Handler.The user should
    * use this invoke call to initialize the message list.
    * @see Error_Handler.Initialize
    * @rep:displayname Invoke Initialize
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    */
   PROCEDURE Initialize;
   /*#
    * This is the invoke call for Reset method in Error Handler.The user should
    * use this invoke call to reset the message list to the begining.
    * @see Error_Handler.Reset
    * @rep:displayname Invoke Reset
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    */
   PROCEDURE Reset;
   /*#
    * This is the invoke call for Get_Message_List in Error Handler.This invokes the
    * error handling method which returns the entire message list for the business object.
    * @see Error_Handler.Get_Message_List
    * @param x_message_list  OUT NOCOPY Message List
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    * @rep:displayname Invoke Get Message List
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    */
   PROCEDURE Get_Message_List
   ( x_message_list    OUT NOCOPY Error_Handler.Error_Tbl_Type);
  /*#
   * This is the invoke call for Get_Entity_Message in Error_Handler.The user should use this
   * invoke call to enable the error handler to retrieves all  Messages for the given entity
   * @see Eror_Handler.Get_Entity_Message
   * @param p_entity_id IN Entity Id
   * @param x_message_list OUT NOCOPY Message List
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:compatibility S
   * @rep:displayname Invoke Get Entity Message
   * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
   */
   PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , x_message_list   OUT NOCOPY Error_Handler.Error_Tbl_Type
   );
   /*#
   * This is the invoke call for Get_Entity_Message in Error_Handler and it invokes
   * the method  which will retrieve a particular Message at the entity index  for an entity
   * @see Eror_Handler.Get_Entity_Message
   * @param  p_entity_id IN Entity Id
   * @param p_entity_index Entity Index
   * @param x_message_text OUT NOCOPY Message List
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:compatibility S
   * @rep:displayname Invoke Get Entity Message
   * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
   */
   PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , p_entity_index   IN  NUMBER
   , x_message_text   OUT NOCOPY VARCHAR2
   );
    /*#
   * This is the invoke call for Delete_Message in Error_Handler.The user invokes the
   * error handler method which deletes a particular Messages for an entity at the entity index given
   * with this call.
   * @see Eror_Handler.Delete_Message
   * @param  p_entity_id IN Entity Id
   * @param p_entity_index IN Entity Index
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:compatibility S
   * @rep:displayname Invoke Delete Message
   * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
   */
   PROCEDURE Delete_Message
   ( p_entity_id          IN  VARCHAR2
   , p_entity_index       IN  NUMBER
   );
    /*#
   * This is the invoke call for Delete_Message in Error_Handler.This will invoke the Error_Handler
   * method which  deletes all Messages for the specified entity.
   * @see Eror_Handler.Delete_Message
   * @param p_entity_id IN Entity Id
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:compatibility S
   * @rep:displayname Invoke Delete Message
   * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
   */
   PROCEDURE Delete_Message
   (  p_entity_id          IN  VARCHAR2 );
   /*#
    * This is the invoke call for the Get_Message in Error_Handler.This invokes the
    * Error_Handler to retrieve message from the Message List
    * @see Error_Handler.Get_Message
    * @param x_message_text OUT NOCOPY Message Text
    * @param x_entity_index OUT NOCOPY Entity Index
    * @param  x_entity_id OUT NOCOPY Entity Id
    * @param x_message_type OUT NOCOPY Message Type
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    * @rep:displayname Invoke Get Message
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    */
   PROCEDURE Get_Message
   ( x_message_text   OUT NOCOPY VARCHAR2
   , x_entity_index   OUT NOCOPY NUMBER
   , x_entity_id      OUT NOCOPY VARCHAR2
   , x_message_type   OUT NOCOPY VARCHAR2
   );
   /*#
    * This is the invoke call for the Get_Message_Count function in Error_Handler.The user should use this
    * invoke call to get the number of curretn messages in Message List.
    * @return Message Count
    * @see Error_Handler.Get_Message_Count
    * @rep:displayname Invoke Get Message Count
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    */

   FUNCTION Get_Message_Count RETURN NUMBER;
   /*#
    * This is the invoke call for the Dump_Message in Error Handler.This invoke call enables the
    * Error_Handler to create a dump of message using dbms output.
    * @see Error_Handler.Dump_Message_List
    * @rep:displayname Invoke Get Message Count
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    */
   PROCEDURE Dump_Message_List;


   -- Invoker for FND_GLOBAL.APPS_INITIALIZE
   PROCEDURE Apps_Initialize
   ( user_id           IN NUMBER
    ,resp_id           IN NUMBER
    ,resp_appl_id      IN NUMBER
    ,security_group_id IN NUMBER  default 0
   ) ;
--Invoker for Export_BOM
    /*#
     * This is the invoke call for the Export_BOM method in BOMPXINQ API.
     * @see BOMPXINQ.Export_BOM
     * @param P_org_hierarchy_name IN Organization Hierarchy Name
     * @param  P_assembly_item_name IN Assembly Item Name
     * @param P_organization_code IN Organizaion Code
     * @param P_alternate_bm_designator IN Alternate BOM Designator
     * @param P_Costs IN Costs
     * @param P_Cost_type_id IN Coste Type Id
     * @param X_bom_header_tbl OUT NOCOPY processed BOM Header Exposed Column Table
     * @paraminfo {@rep:innertype BOM_BO_PUB.BOM_HEADER_TBL_TYPE}
     * @param X_bom_revisions_tbl OUT NOCOPY BOM Revision Table
     * @paraminfo {@rep:innertype BOM_BO_PUB.BOM_REVISION_TBL_TYPE}
     * @param X_bom_components_tbl OUT NOCOPY BOM Components Table
     * @paraminfo {@rep:innertype BOM_BO_PUB.BOM_COMPS_TBL_TYPE}
     * @param X_bom_ref_designators_tbl OUT NOCOPY BOM Reference Designator Table
     * @paraminfo {@rep:innertype BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE}
     * @param X_bom_sub_components_tbl OUT NOCOPY BOM Substitute Components Table
     * @paraminfo {@rep:innertype BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE}
     * @param X_bom_comp_ops_tbl OUT NOCOPY BOM Component Operation Table
     * @paraminfo {@rep:innertype BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE}
     * @param X_Err_Msg OUT NOCOPY Error Message
     * @param X_Error_Code OUT NOCOPY Error Code
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:compatibility S
     * @rep:displayname Invoke Export BOM
     */
PROCEDURE Export_BOM(P_org_hierarchy_name        IN   VARCHAR2 DEFAULT NULL,
                     P_assembly_item_name        IN   VARCHAR2,
                     P_organization_code         IN   VARCHAR2,
                     P_alternate_bm_designator   IN   VARCHAR2 DEFAULT NULL,
                     P_Costs                     IN   NUMBER DEFAULT 2,
                     P_Cost_type_id            IN   NUMBER DEFAULT 0,
                     X_bom_header_tbl          OUT NOCOPY BOM_BO_PUB.BOM_HEADER_TBL_TYPE,
                     X_bom_revisions_tbl       OUT NOCOPY BOM_BO_PUB.BOM_REVISION_TBL_TYPE,
                     X_bom_components_tbl      OUT NOCOPY BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     X_bom_ref_designators_tbl OUT NOCOPY BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     X_bom_sub_components_tbl  OUT NOCOPY BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     X_bom_comp_ops_tbl        OUT NOCOPY BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_Err_Msg                 OUT NOCOPY VARCHAR2,
                     X_Error_Code              OUT NOCOPY NUMBER);

END Bom_Invoke_Bo;

 

/
