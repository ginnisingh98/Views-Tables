--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_UTIL_PVT" AS
/* $Header: OEXVIMUB.pls 120.1 2005/08/05 15:29:37 sphatarp noship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    OE_ORDER_IMPORT_UTIL_PVT
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
   Procedure: Delete_Order
   -----------------------------------------------------------
*/
PROCEDURE Delete_Order(
	p_request_id     		IN  NUMBER
       ,p_order_source_id     		IN  NUMBER
       ,p_orig_sys_document_ref 	IN  VARCHAR2
       ,p_sold_to_org_id                IN  NUMBER
       ,p_sold_to_org                   IN  VARCHAR2
       ,p_change_sequence 		IN  VARCHAR2
       ,p_return_status         	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS
      l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Order';
      l_exists_reject_line           VARCHAR2(1);
BEGIN

    DELETE FROM oe_actions_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
        = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
        = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,	FND_API.G_MISS_NUM)
	= nvl(p_request_id,	FND_API.G_MISS_NUM);

    DELETE FROM oe_reservtns_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
        = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
        = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,	FND_API.G_MISS_NUM)
	= nvl(p_request_id,	FND_API.G_MISS_NUM);

    DELETE FROM oe_lotserials_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
        = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
        = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,	FND_API.G_MISS_NUM)
	= nvl(p_request_id,	FND_API.G_MISS_NUM);

    DELETE FROM oe_credits_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
        = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
        = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,	FND_API.G_MISS_NUM)
	= nvl(p_request_id,	FND_API.G_MISS_NUM);

    DELETE FROM oe_payments_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,	FND_API.G_MISS_NUM)
	= nvl(p_request_id,	FND_API.G_MISS_NUM);

    DELETE FROM oe_price_adjs_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
        = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
        = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,	FND_API.G_MISS_NUM)
	= nvl(p_request_id,	FND_API.G_MISS_NUM);
/* 1433292 */
       DELETE FROM oe_price_atts_interface
    WHERE order_source_id       = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
        = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
        = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
        = nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND nvl(  request_id,     FND_API.G_MISS_NUM)
        = nvl(p_request_id,     FND_API.G_MISS_NUM);

    -- { Following changes are made to fix the bug 2922709
    --   The issue is that the acknowledgment are not being send for the
    --   Rejected Order and Line.
    --   Fix is that we should not delete the lines if the
    --   Reject_flag = 'Y' and if there is such line in that case
    --   Order Header should also be not deleted.
    --   And when the acknowledgments are being processed we should
    --   use this information to create the data.

    --   Check if there is any Line with the Reject_Flag = 'Y'
    Begin

      SELECT 1
      INTO   l_exists_reject_line
      FROM   oe_lines_interface
      WHERE  order_source_id       = p_order_source_id
      AND    orig_sys_document_ref = p_orig_sys_document_ref
      AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
           = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
      AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
           = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
      AND    nvl(  change_sequence,FND_API.G_MISS_CHAR)
	   = nvl(p_change_sequence,FND_API.G_MISS_CHAR)
      AND    nvl(  request_id,	FND_API.G_MISS_NUM)
	   = nvl(p_request_id,	FND_API.G_MISS_NUM)
      AND    nvl(rejected_flag,'N')= 'Y'
      AND    rownum                = 1;

      DELETE FROM oe_lines_interface
      WHERE order_source_id       = p_order_source_id
        AND orig_sys_document_ref = p_orig_sys_document_ref
        AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
          = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
        AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
          = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
        AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
          = nvl(p_change_sequence,FND_API.G_MISS_CHAR)
        AND nvl(  request_id,	FND_API.G_MISS_NUM)
          = nvl(p_request_id,	FND_API.G_MISS_NUM)
        AND nvl(rejected_flag,'N')= 'N';
    EXCEPTION
      When NO_DATA_FOUND Then

      -- This is the OLD code path, let me put debug statement so
      -- developer know this is executed..

      oe_debug_pub.add('Delete_Order - No_DATA - Old Path of execution');

      DELETE FROM oe_lines_interface
      WHERE order_source_id       = p_order_source_id
        AND orig_sys_document_ref = p_orig_sys_document_ref
        AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
          = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
        AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
          = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
        AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
          = nvl(p_change_sequence,FND_API.G_MISS_CHAR)
        AND nvl(  request_id,	FND_API.G_MISS_NUM)
          = nvl(p_request_id,	FND_API.G_MISS_NUM);

      DELETE FROM oe_headers_interface
      WHERE order_source_id       = p_order_source_id
        AND orig_sys_document_ref = p_orig_sys_document_ref
        AND nvl(  sold_to_org_id, FND_API.G_MISS_NUM)
          = nvl(p_sold_to_org_id, FND_API.G_MISS_NUM)
        AND nvl(  sold_to_org, FND_API.G_MISS_CHAR)
          = nvl(p_sold_to_org, FND_API.G_MISS_CHAR)
        AND nvl(  change_sequence,FND_API.G_MISS_CHAR)
          = nvl(p_change_sequence,FND_API.G_MISS_CHAR)
        AND nvl(  request_id,	FND_API.G_MISS_NUM)
         = nvl(p_request_id,	FND_API.G_MISS_NUM);


    END;

    -- End of fix the bug 2922709}

    p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
    WHEN OTHERS THEN
      oe_debug_pub.add('Unexpected error: '||sqlerrm);

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Delete_Order',substr(sqlerrm,1,2000));
      END IF;

END Delete_Order;


/* -----------------------------------------------------------
   Procedure: Delete_Messages
   -----------------------------------------------------------
*/
PROCEDURE Delete_Messages(
	p_request_id     		IN  NUMBER
       ,p_order_source_id     		IN  NUMBER
       ,p_orig_sys_document_ref 	IN  VARCHAR2
       ,p_sold_to_org_id                IN  NUMBER
       ,p_sold_to_org                   IN  VARCHAR2
       ,p_change_sequence 		IN  VARCHAR2
       ,p_org_id                        IN  VARCHAR2
       ,p_return_status         	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS
	l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Messages';
        l_request_id                  NUMBER          := p_request_id;
        l_order_source_id             NUMBER          := p_order_source_id;
        l_orig_sys_document_ref       VARCHAR2(50)    := p_orig_sys_document_ref;
	l_sold_to_org_id              NUMBER          := p_sold_to_org_id;
        l_sold_to_org             VARCHAR2(360)          := p_sold_to_org;

        l_change_sequence             VARCHAR2(50)    := p_change_sequence;
        l_org_id                      Number          := p_org_id;
BEGIN
  --Commented this particular SQL statement as part of the
  --fix for bug#2110646

  /*DELETE FROM OE_PROCESSING_MSGS_VL
    WHERE order_source_id       	= p_order_source_id
      AND original_sys_document_ref 	= p_orig_sys_document_ref
      AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	= nvl(p_change_sequence,	FND_API.G_MISS_CHAR);*/


  --Call to DELETE_OI_MESSAGE to delete the messages from oe_processing_msgs
  --and oe_processing_msgs_tl.Fix for bug#2110646.
    OE_MSG_PUB.DELETE_OI_MESSAGE(
            p_order_source_id           => l_order_source_id,
            p_orig_sys_document_ref     => l_orig_sys_document_ref,
            p_change_sequence           => l_change_sequence,
            p_org_id                    => l_org_id
           );



    p_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
        WHEN OTHERS THEN
	  oe_debug_pub.add('Unexpected error: '||sqlerrm);

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Delete_Messages');
          END IF;

END Delete_Messages;


/* -----------------------------------------------------------
   Function: Get_Line_Index
   -----------------------------------------------------------
*/
FUNCTION Get_Line_Index(
        p_line_tbl			IN OE_Order_Pub.Line_Tbl_Type
       ,p_orig_sys_line_ref 		IN VARCHAR2
       ,p_orig_sys_shipment_ref		IN VARCHAR2
)
RETURN NUMBER
IS
	l_api_name            CONSTANT VARCHAR2(30) := 'Get_Line_Index';
BEGIN

	FOR i IN 1 .. p_line_tbl.count
	LOOP
	   IF p_line_tbl(i).orig_sys_line_ref     = p_orig_sys_line_ref AND
	      p_line_tbl(i).orig_sys_shipment_ref = p_orig_sys_shipment_ref
	   THEN
		RETURN i;
	   END IF;
	END LOOP;

END Get_Line_Index;


END OE_ORDER_IMPORT_UTIL_PVT;

/
