--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_CONFIG_PVT" AS
/* $Header: OEXVIMCB.pls 120.1 2005/09/10 20:50:38 jjmcfarl noship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    OE_ORDER_IMPORT_CONFIG_PVT
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--
--  End of Comments
------------------------------------------------------------------
*/

/* -----------------------------------------------------------
   Procedure: Pre_Process
   -----------------------------------------------------------
*/
PROCEDURE Pre_Process(
  p_header_rec                  IN     OE_Order_Pub.Header_Rec_Type
 ,p_x_line_tbl                    IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

) IS

  l_orig_sys_document_ref	VARCHAR2(50);
  l_orig_sys_line_ref		VARCHAR2(50);
  l_orig_sys_shipment_ref	VARCHAR2(50);

  l_organization_id            	NUMBER;
  l_sequence_id              	NUMBER;
  l_sort_order              	VARCHAR2(2000);
  l_component_code             	VARCHAR2(1000);
  l_msg_index              	NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_error_code                  NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Pre_Process';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/* -----------------------------------------------------------
   Model/Configurations Pre_Process
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE DOING MODEL/CONFIGURATIONS PRE_PROCESS' ) ;
   END IF;

/* -----------------------------------------------------------
   Get OE_Organization_Id
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE GETTING OE_ORGANIZATION_ID' ) ;
   END IF;

-- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
   l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID', p_header_rec.org_id);
   /*FND_PROFILE.Get('OE_ORGANIZATION_ID', l_organization_id);*/

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE ORGANIZATION ID: '|| TO_CHAR ( L_ORGANIZATION_ID ) ) ;
   END IF;


   FOR i IN 1 .. p_x_line_tbl.count
   LOOP
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE PROCESSING LINE FOR '|| 'REF: ' || RTRIM ( P_X_LINE_TBL ( I ) .ORIG_SYS_LINE_REF ) || ' ID:' || P_X_LINE_TBL ( I ) .INVENTORY_ITEM_ID || ' TYPE: ' || RTRIM ( P_X_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ) ;
	END IF;

/* -----------------------------------------------------------
   Set message context
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT' ) ;
   END IF;

   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => p_header_rec.header_id
        ,p_line_id                    => p_x_line_tbl(i).line_id
--      ,p_batch_request_id           => p_header_rec.request_id
        ,p_order_source_id            => p_header_rec.order_source_id
        ,p_orig_sys_document_ref      => p_header_rec.orig_sys_document_ref
        ,p_change_sequence            => p_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => p_x_line_tbl(i).orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_x_line_tbl(i).orig_sys_shipment_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );


/* ----- Removed as this is also done as part of Config api --
      Setting Link_To_Line_Index
   -----------------------------------------------------------
   -- Bug fix 1707492 -- start --
   IF p_x_line_tbl(i).link_to_line_ref IS NOT NULL THEN
      oe_debug_pub.add('before setting Link_To_Line_Index');

      FOR j IN 1 .. p_x_line_tbl.count
      LOOP
         IF p_x_line_tbl(j).orig_sys_line_ref =
            p_x_line_tbl(i).link_to_line_ref
         THEN
   	    p_x_line_tbl(i).link_to_line_index := j;
         END IF;
      END LOOP;
   END IF;
   -- Bug fix 1707492 -- end --

*/

   IF (nvl(p_x_line_tbl(i).item_type_code,'STANDARD') = 'MODEL') OR
      (p_x_line_tbl(i).item_type_code = FND_API.G_MISS_CHAR AND
      p_x_line_tbl(i).orig_sys_line_ref = p_x_line_tbl(i).top_model_line_ref)
   THEN

/*    -----------------------------------------------------------
      Set Top_Model_Line_Index, Component_Sequence_Id, Component_Code
      and Sort_Order for the classes and options of this model
      -----------------------------------------------------------
*/
      FOR j IN 1 .. p_x_line_tbl.count
      LOOP
	 IF p_x_line_tbl(j).top_model_line_ref = p_x_line_tbl(i).orig_sys_line_ref
	 THEN
/* -----------------------------------------------------------
   	    Setting Top_Model_Line_Index for the options
   -----------------------------------------------------------
*/
		        IF l_debug_level  > 0 THEN
		            oe_debug_pub.add(  'BEFORE SETTING TOP_MODEL_LINE_INDEX FOR '|| RTRIM ( P_X_LINE_TBL ( J ) .ITEM_TYPE_CODE ) || ' REF: ' || RTRIM ( P_X_LINE_TBL ( J ) .ORIG_SYS_LINE_REF ) || ' AND ITEM ID:' || ( P_X_LINE_TBL ( J ) .INVENTORY_ITEM_ID ) ) ;
		        END IF;
-- This is added for the bug# 1380879 both service and top model reference
-- can not be present together
         If nvl(p_x_line_tbl(j).service_reference_line, FND_API.G_MISS_CHAR) =
            FND_API.G_MISS_CHAR Then
            p_x_line_tbl(j).top_model_line_index := i;
         Else
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT', 'OE_SERV_LINE_WITH_TOP_REF');
            FND_MESSAGE.Set_Token('ITEM', p_x_line_tbl(j).inventory_item_id);
            oe_msg_pub.add;
            RETURN;
         End If;

/* -----------------------------------------------------------
   	    Setting Component_Sequence_Id, Component_Code and
            Sort_Order for the options
   -----------------------------------------------------------
*/
		        IF l_debug_level  > 0 THEN
		            oe_debug_pub.add(  'BEFORE SETTING COMPONENT_SEQUENCE_ID FOR ' || RTRIM ( P_X_LINE_TBL ( J ) .ITEM_TYPE_CODE ) );
                            oe_debug_pub.add( ' REF: ' || RTRIM ( P_X_LINE_TBL ( J ) .ORIG_SYS_LINE_REF ) || ' AND ITEM ID:' || ( P_X_LINE_TBL ( J ) .INVENTORY_ITEM_ID ) ) ;
		        END IF;

	 END IF;  /* IF p_x_line_tbl(j).top_model_line_ref = */
      END LOOP;	/* FOR j IN ... */

/*    -----------------------------------------------------------
      Change the item type code to CLASS in case of ATO under PTO
      -----------------------------------------------------------
*/
/* aksingh to check */
   END IF; /* IF nvl(p_x_line_tbl(i).item_type_code,'STANDARD')='MODEL' */

   END LOOP; /* FOR i IN ... */

END Pre_Process;

END OE_ORDER_IMPORT_CONFIG_PVT;

/
