--------------------------------------------------------
--  DDL for Package Body OE_ACCEPTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ACCEPTANCE_PVT" AS
/* $Header: OEXVACCB.pls 120.5.12010000.3 2009/09/05 12:50:45 nitagarw ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_ACCEPTANCE_PVT';

G_LINE_ID_TBL                        NUMBER_TYPE;
G_HEADER_ID_TBL                      NUMBER_TYPE;
G_REVREC_COMMENTS_TBL                VARCHAR_2000_TYPE;
G_REVREC_REF_DOC_TBL                 VARCHAR_240_TYPE;
G_REVREC_SIGNATURE_TBL               VARCHAR_240_TYPE;
G_REVREC_IMPLICIT_FLAG_TBL          FLAG_TYPE;
G_REVREC_SIGNATURE_DATE_TBL                DATE_TYPE;
G_ACCEPTED_BY_TBL                    NUMBER_TYPE;
G_ACCEPTED_QUANTITY_TBL              NUMBER_TYPE;
G_FLOW_STATUS_TBL                    VARCHAR_30_TYPE;

PROCEDURE Reset_global_tbls IS
BEGIN
 G_LINE_ID_TBL.delete;
 G_HEADER_ID_TBL.delete;
 G_REVREC_COMMENTS_TBL.delete;
 G_REVREC_REF_DOC_TBL.delete;
 G_REVREC_SIGNATURE_TBL.delete;
 G_REVREC_IMPLICIT_FLAG_TBL.delete;
 G_REVREC_SIGNATURE_DATE_TBL.delete;
 G_ACCEPTED_BY_TBL.delete;
 G_ACCEPTED_QUANTITY_TBL.delete;
 G_FLOW_STATUS_TBL.delete;
END Reset_global_tbls;

PROCEDURE Process_Acceptance
   ( p_request_tbl IN OUT NOCOPY OE_ORDER_PUB.request_tbl_type
    ,p_index IN NUMBER DEFAULT 1
    ,x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2)
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_ACCEPTANCE_UTIL.Process_Acceptance' , 1);
    END IF;

 FOR i IN p_index..p_request_tbl.COUNT
 LOOP
      IF (p_request_tbl(i).processed = 'Y') OR
            p_request_tbl(i).request_type NOT IN (OE_GLOBALS.G_ACCEPT_FULFILLMENT,OE_GLOBALS.G_REJECT_FULFILLMENT)  THEN
            GOTO END_LOOP;
      END IF;
      -- Initialize each request's return_status as 'S'. It will be set to 'E' when required.
      p_request_tbl(i).return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_request_tbl(i).entity_code = 'HEADER' THEN

           Build_Header_Acceptance_table(p_request_rec   =>p_request_tbl(i)
                                                           ,x_return_status  => l_return_status);

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('sasi: p_request_rec return_status after Build_Header_Acceptance_table:'||p_request_tbl(i).return_status , 3);
           END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          p_request_tbl(i).processed := 'Y';
       ELSIF p_request_tbl(i).entity_code = 'LINE' THEN

           Build_Line_Acceptance_table(p_request_rec   => p_request_tbl(i)
                                                          , x_return_status  => l_return_status);

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('sasi: p_request_rec return_status after Build_Line_Acceptance_table:'||p_request_tbl(i).return_status , 3);
           END IF;

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
            p_request_tbl(i).processed := 'Y';
       END IF;
   << END_LOOP >> -- Label for requests that do not need to be processed
   NULL;
 END LOOP;

  IF G_LINE_ID_TBL.count = 0 THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO ROWS to process' , 2 );
      oe_debug_pub.add('EXITING OE_ACCEPTANCE_UTIL.Process_Acceptance' , 1);
    END IF;
      -- No lines are eligible for acceptance
     FND_MESSAGE.set_name('ONT', 'ONT_ACCEPTANCE_NA');
    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('IN OE_ACCEPTANCE_UTIL.Process_Acceptance - before bulk update' , 1);
    END IF;

   FORALL i in g_line_id_tbl.FIRST .. g_line_id_tbl.LAST
   UPDATE oe_order_lines_all
   SET   revrec_comments = g_revrec_comments_tbl(i),
             Revrec_reference_document = g_revrec_ref_doc_tbl(i),
             Revrec_signature = g_revrec_signature_tbl(i),
             Revrec_implicit_flag = g_revrec_implicit_flag_tbl(i),
             Revrec_signature_date = g_revrec_signature_date_tbl(i),
             Accepted_by = g_accepted_by_tbl(i),
             Accepted_quantity = g_accepted_quantity_tbl(i)
   WHERE line_id = g_line_id_tbl(i);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('IN OE_ACCEPTANCE_UTIL.Process_Acceptance - after bulk update' , 1);
    END IF;

  -- Progress workflow for each processed lines in a loop.
  OE_ACCEPTANCE_PVT.Progress_Accepted_lines(l_return_status);

 IF l_debug_level  > 0 THEN
      oe_debug_pub.add('IN OE_ACCEPTANCE_UTIL.Process_Acceptance-progress_accepted_lines return status:'|| l_return_status , 1);
 END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

   Reset_global_tbls;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Acceptance'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Process_Acceptance;

PROCEDURE Build_Header_Acceptance_table(p_request_rec IN OUT NOCOPY OE_ORDER_PUB.request_rec_type,
                                        x_return_status  OUT NOCOPY VARCHAR2)
IS
   l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_header_id NUMBER := p_request_rec.entity_id;
   l_line_id NUMBER;
    CURSOR order_lines is
    SELECT line_id
    FROM   oe_order_lines_all
    WHERE header_id = l_header_id
    AND   open_flag = 'Y'
    AND   flow_status_code in ('PRE-BILLING_ACCEPTANCE', 'POST-BILLING_ACCEPTANCE');
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

  OPEN order_lines ;
  LOOP
    FETCH order_lines into l_line_id;
    EXIT WHEN order_lines%NOTFOUND;

     Build_Line_Acceptance_table(p_request_rec => p_request_rec
                                 ,p_line_id => l_line_id
                                 ,x_return_status => l_return_status);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Build_Header_Acceptance_table '|| SQLERRM , 1);
    END IF;
    x_return_status := l_return_status;

END Build_Header_Acceptance_table;


PROCEDURE Build_Line_Acceptance_table(p_request_rec   IN OUT NOCOPY OE_ORDER_PUB.request_rec_type
                                     ,p_line_id       IN NUMBER DEFAULT NULL
                                     ,x_return_status OUT NOCOPY VARCHAR2)
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_line_id NUMBER := nvl(p_line_id, p_request_rec.entity_id);
l_header_id NUMBER;
l_item_type_code VARCHAR2(30);
l_top_model_line_id NUMBER;
l_flow_status_code VARCHAR2(30);
l_line_count               NUMBER := 0;
l_notify_index NUMBER := NULL;
l_notify_status VARCHAR2(1);
l_fulfilled_quantity NUMBER;
l_ordered_quantity NUMBER;
l_shipped_quantity NUMBER;

  CURSOR model_children is
  SELECT line_id, fulfilled_quantity,shipped_quantity, ordered_quantity,header_id, flow_status_code
  FROM   oe_order_lines_all
  WHERE header_id = l_header_id
  AND   open_flag = 'Y'
  AND top_model_line_id = l_line_id;

  CURSOR c_service_lines is
  SELECT line_id, fulfilled_quantity, shipped_quantity, ordered_quantity, header_id, flow_status_code
  FROM   oe_order_lines_all
  WHERE open_flag='Y'
  AND service_reference_line_id = l_line_id;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN
IF l_line_id IS NOT NULL THEN

      l_line_count := G_LINE_ID_TBL.COUNT;
  -- changes for bug# 5232503
  -- accept all lines sent by implicit program without any check for eligibility if system param is turned off
  IF NVL(OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE'), 'N') = 'N' THEN
            SELECT header_id, item_type_code, top_model_line_id, fulfilled_quantity,
	           shipped_quantity, ordered_quantity, flow_status_code
            INTO l_header_id, l_item_type_code, l_top_model_line_id, l_fulfilled_quantity,
	           l_shipped_quantity, l_ordered_quantity, l_flow_status_code
            FROM oe_order_lines_all
            WHERE line_id=l_line_id;

            l_line_count                 := l_line_count + 1;
            G_LINE_ID_TBL(l_line_count) := l_line_id;
            IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                 G_ACCEPTED_QUANTITY_TBL(l_line_count) := nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,nvl(l_ordered_quantity,0)));
            ELSE
                 G_ACCEPTED_QUANTITY_TBL(l_line_count) := 0;
            END IF;
            G_REVREC_COMMENTS_TBL(l_line_count) := p_request_rec.param1;
            G_REVREC_SIGNATURE_TBL(l_line_count)  := p_request_rec.param2;
            G_REVREC_REF_DOC_TBL(l_line_count)    := p_request_rec.param3;
            G_REVREC_IMPLICIT_FLAG_TBL(l_line_count)    := p_request_rec.param4;
            G_HEADER_ID_TBL(l_line_count) := l_header_id;
            G_REVREC_SIGNATURE_DATE_TBL(l_line_count)  := nvl(p_request_rec.date_param1,sysdate);
            G_ACCEPTED_BY_TBL(l_line_count)    := FND_GLOBAL.USER_ID;
            G_FLOW_STATUS_TBL(l_line_count) := l_flow_status_code;

            IF OE_GLOBALS.G_UPDATE_GLOBAL_PICTURE = 'Y' THEN
               OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                       p_line_id => l_line_id,
                       x_index => l_notify_index,
                       x_return_status => l_notify_status);

	       IF (l_notify_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               IF l_notify_index IS NOT NULL THEN
                  OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
                  IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=
			nvl(l_fulfilled_quantity,nvl(l_shipped_quantity, nvl(l_ordered_quantity,0)));
                  ELSE
                       OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=0;
                  END IF;
                  OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_comments  := p_request_rec.param1;
                  OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature  := p_request_rec.param2;
                  OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_reference_document    := p_request_rec.param3;
		  OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_implicit_flag    := p_request_rec.param4;
		  OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature_date  := nvl(p_request_rec.date_param1,sysdate);
		  OE_ORDER_UTIL.g_line_tbl(l_notify_index).ACCEPTED_BY    := FND_GLOBAL.USER_ID;
               END IF;

            END IF;
  ELSE -- system param on

     IF OE_ACCEPTANCE_UTIL.Customer_Acceptance_Eligible(l_line_id) THEN

            SELECT header_id, item_type_code, top_model_line_id, fulfilled_quantity,
	           shipped_quantity, ordered_quantity, flow_status_code
              INTO l_header_id, l_item_type_code, l_top_model_line_id, l_fulfilled_quantity,
	           l_shipped_quantity, l_ordered_quantity, l_flow_status_code
              FROM oe_order_lines_all
              WHERE line_id=l_line_id;


      --Entering children lines in to global tbls
         IF (l_item_type_code = 'MODEL' OR l_item_type_code='KIT') AND
            ( l_top_model_line_id IS NOT NULL  AND l_top_model_line_id = l_line_id) THEN

            OPEN model_children ;
            LOOP
            FETCH model_children into l_line_id, l_fulfilled_quantity, l_shipped_quantity,
	          		       l_ordered_quantity, l_header_id, l_flow_status_code;
            EXIT when model_children%NOTFOUND;
            l_line_count     := l_line_count+1;
            G_LINE_ID_TBL(l_line_count) := l_line_id;
            IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
               G_ACCEPTED_QUANTITY_TBL(l_line_count) := nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,
										     nvl(l_ordered_quantity,0)));
            ELSE
               G_ACCEPTED_QUANTITY_TBL(l_line_count) := 0;
            END IF;
            G_REVREC_COMMENTS_TBL(l_line_count)   := p_request_rec.param1;
            G_REVREC_SIGNATURE_TBL(l_line_count)  := p_request_rec.param2;
            G_REVREC_REF_DOC_TBL(l_line_count)    := p_request_rec.param3;
            G_REVREC_IMPLICIT_FLAG_TBL(l_line_count)    := p_request_rec.param4;
            G_HEADER_ID_TBL(l_line_count) := l_header_id;
            G_REVREC_SIGNATURE_DATE_TBL(l_line_count)  := nvl(p_request_rec.date_param1,sysdate);
            G_ACCEPTED_BY_TBL(l_line_count)   := FND_GLOBAL.USER_ID;
            G_FLOW_STATUS_TBL(l_line_count) := l_flow_status_code;

             IF OE_GLOBALS.G_UPDATE_GLOBAL_PICTURE = 'Y' THEN
                OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_line_id => l_line_id,
                    x_index => l_notify_index,
                    x_return_status => l_notify_status);

                 IF (l_notify_status <> FND_API.G_RET_STS_SUCCESS) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

                IF l_notify_index IS NOT NULL THEN
	           OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
                   IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=
		          nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,nvl(l_ordered_quantity,0)));
                   ELSE
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=0;
                   END IF;
                   OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_comments  := p_request_rec.param1;
                   OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature  := p_request_rec.param2;
                   OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_reference_document    := p_request_rec.param3;
                   OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_implicit_flag    := p_request_rec.param4;
                   OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature_date  := nvl(p_request_rec.date_param1,sysdate);
                   OE_ORDER_UTIL.g_line_tbl(l_notify_index).ACCEPTED_BY    := FND_GLOBAL.USER_ID;
                END IF;
               END IF;

               OPEN  c_service_lines ;
               LOOP
               FETCH c_service_lines into l_line_id, l_fulfilled_quantity, l_shipped_quantity,
				  l_ordered_quantity, l_header_id, l_flow_status_code;
               EXIT when c_service_lines%NOTFOUND;

                l_line_count                 := l_line_count + 1;
                G_LINE_ID_TBL(l_line_count) := l_line_id;
                IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                   G_ACCEPTED_QUANTITY_TBL(l_line_count) := nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,nvl(l_ordered_quantity,0)));
		ELSE
                    G_ACCEPTED_QUANTITY_TBL(l_line_count) := 0;
                END IF;
                G_REVREC_COMMENTS_TBL(l_line_count) := p_request_rec.param1;
                G_REVREC_SIGNATURE_TBL(l_line_count)  := p_request_rec.param2;
                G_REVREC_REF_DOC_TBL(l_line_count)    := p_request_rec.param3;
                G_REVREC_IMPLICIT_FLAG_TBL(l_line_count)    := p_request_rec.param4;
                G_HEADER_ID_TBL(l_line_count) := l_header_id;
                G_REVREC_SIGNATURE_DATE_TBL(l_line_count)  := nvl(p_request_rec.date_param1,sysdate);
                G_ACCEPTED_BY_TBL(l_line_count)    := FND_GLOBAL.USER_ID;
                G_FLOW_STATUS_TBL(l_line_count) := l_flow_status_code;

		IF OE_GLOBALS.G_UPDATE_GLOBAL_PICTURE = 'Y' THEN
                  OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                       p_line_id => l_line_id,
                       x_index => l_notify_index,
                       x_return_status => l_notify_status);

		  IF (l_notify_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  IF l_notify_index IS NOT NULL THEN
                     OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
                      IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                         OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=
	               		nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,nvl(l_ordered_quantity,0)));
                      ELSE
                         OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=0;
                      END IF;
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_comments  := p_request_rec.param1;
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature  := p_request_rec.param2;
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_reference_document    := p_request_rec.param3;
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_implicit_flag    := p_request_rec.param4;
	              OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature_date  := nvl(p_request_rec.date_param1,sysdate);
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).ACCEPTED_BY    := FND_GLOBAL.USER_ID;
                END IF;
               END IF;
              END LOOP;
	      close c_service_lines;
          END LOOP;
     ELSE --standard lines
           l_line_count                 := l_line_count + 1;
             G_LINE_ID_TBL(l_line_count) := l_line_id;
            IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                 G_ACCEPTED_QUANTITY_TBL(l_line_count) := nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,
										 nvl(l_ordered_quantity,0)));
            ELSE
                 G_ACCEPTED_QUANTITY_TBL(l_line_count) := 0;
            END IF;
           G_REVREC_COMMENTS_TBL(l_line_count) := p_request_rec.param1;
           G_REVREC_SIGNATURE_TBL(l_line_count)  := p_request_rec.param2;
           G_REVREC_REF_DOC_TBL(l_line_count)    := p_request_rec.param3;
           G_REVREC_IMPLICIT_FLAG_TBL(l_line_count)    := p_request_rec.param4;
           G_HEADER_ID_TBL(l_line_count) := l_header_id;
           G_REVREC_SIGNATURE_DATE_TBL(l_line_count)  := nvl(p_request_rec.date_param1,sysdate);
           G_ACCEPTED_BY_TBL(l_line_count)    := FND_GLOBAL.USER_ID;
           G_FLOW_STATUS_TBL(l_line_count) := l_flow_status_code;

        IF OE_GLOBALS.G_UPDATE_GLOBAL_PICTURE = 'Y' THEN
           OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                       p_line_id => l_line_id,
                       x_index => l_notify_index,
                       x_return_status => l_notify_status);

	   IF (l_notify_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           IF l_notify_index IS NOT NULL THEN
              OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
                  IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                      OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=
			nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,
						                nvl(l_ordered_quantity,0)));
                  ELSE
                       OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=0;
                  END IF;
                 OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_comments  := p_request_rec.param1;
                 OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature  := p_request_rec.param2;
                 OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_reference_document    := p_request_rec.param3;
		 OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_implicit_flag    := p_request_rec.param4;
		 OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature_date  := nvl(p_request_rec.date_param1,sysdate);
		 OE_ORDER_UTIL.g_line_tbl(l_notify_index).ACCEPTED_BY    := FND_GLOBAL.USER_ID;
            END IF;

       END IF;
       --Entering service lines for parent line
        OPEN  c_service_lines ;
        LOOP
        FETCH c_service_lines into l_line_id, l_fulfilled_quantity, l_shipped_quantity, l_ordered_quantity,
				    l_header_id, l_flow_status_code;
        EXIT when c_service_lines%NOTFOUND;
        l_line_count                 := l_line_count + 1;
        G_LINE_ID_TBL(l_line_count) := l_line_id;
        IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
           G_ACCEPTED_QUANTITY_TBL(l_line_count):= nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,nvl(l_ordered_quantity,0)));
        ELSE
           G_ACCEPTED_QUANTITY_TBL(l_line_count) := 0;
        END IF;
        G_REVREC_COMMENTS_TBL(l_line_count) := p_request_rec.param1;
        G_REVREC_SIGNATURE_TBL(l_line_count)  := p_request_rec.param2;
        G_REVREC_REF_DOC_TBL(l_line_count)    := p_request_rec.param3;
        G_REVREC_IMPLICIT_FLAG_TBL(l_line_count)    := p_request_rec.param4;
        G_HEADER_ID_TBL(l_line_count) := l_header_id;
        G_REVREC_SIGNATURE_DATE_TBL(l_line_count)  := nvl(p_request_rec.date_param1,sysdate);
        G_ACCEPTED_BY_TBL(l_line_count)    := FND_GLOBAL.USER_ID;
        G_FLOW_STATUS_TBL(l_line_count) := l_flow_status_code;

       IF OE_GLOBALS.G_UPDATE_GLOBAL_PICTURE = 'Y' THEN
           OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                       p_line_id => l_line_id,
                       x_index => l_notify_index,
                       x_return_status => l_notify_status);

	   IF (l_notify_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           IF l_notify_index IS NOT NULL THEN
              OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
              IF p_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT THEN
                 OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=
		    nvl(l_fulfilled_quantity,nvl(l_shipped_quantity,nvl(l_ordered_quantity,0)));
              ELSE
                 OE_ORDER_UTIL.g_line_tbl(l_notify_index).accepted_quantity :=0;
              END IF;
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_comments  := p_request_rec.param1;
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature  := p_request_rec.param2;
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_reference_document    := p_request_rec.param3;
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_implicit_flag    := p_request_rec.param4;
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).revrec_signature_date  := nvl(p_request_rec.date_param1,sysdate);
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).ACCEPTED_BY    := FND_GLOBAL.USER_ID;

          END IF;
	 END IF;
      END LOOP;
      CLOSE c_service_lines;
     END IF;
    ELSE
      IF l_debug_level  > 0 THEN
         OE_DEBUG_PUB.Add('Acceptance not allowed for this line. setting retun status of request_rec to E:'||l_line_id);
      END IF;
      p_request_rec.return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF; -- sys param check
END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Build_Line_Acceptance_table '|| SQLERRM , 1);
    END IF;
    x_return_status := l_return_status;

END Build_Line_Acceptance_table;

PROCEDURE Progress_Accepted_lines
   (x_return_status OUT NOCOPY Varchar2)
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_line_flex_rec ar_deferral_reasons_grp.line_flex_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_org_id                            oe_order_lines_all.org_id%TYPE;            -- Bug 8859412
l_inventory_item_id      oe_order_lines_all.inventory_item_id%TYPE;
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING Progress_ Accepted_Lines' , 1);
  END IF;

    FOR i IN 1..g_line_id_tbl.count LOOP
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Processing line_id:'||g_line_id_tbl(i));
       END IF;
       IF g_flow_status_tbl(i) = 'PRE-BILLING_ACCEPTANCE' THEN
         BEGIN
            WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_LIN, g_line_id_tbl(i), 'INVOICE_PENDING_ACCEPTANCE' , 'COMPLETE');
         EXCEPTION
           WHEN OTHERS THEN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('error progressing INVOICE_PENDING_ACCEPTANCE  for line_id='||g_line_id_tbl(i)||sqlerrm, 1);
               END IF;
               null;
         END;
       ELSIF g_flow_status_tbl(i) = 'POST-BILLING_ACCEPTANCE' THEN -- pending at close line'
          BEGIN
            WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_LIN, g_line_id_tbl(i), 'CLOSE_PENDING_ACCEPTANCE', 'COMPLETE');
         EXCEPTION
           WHEN OTHERS THEN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('error progressing CLOSE_PENDING_ACCEPTANCE for line_id='||g_line_id_tbl(i)||sqlerrm, 1);
               END IF;
               null;
         END;
       END IF;
-- Start bug 8859412


	IF g_accepted_quantity_tbl(i) = 0 THEN                  -- For rejection, Accepted Quantity = 0

        oe_debug_pub.add('Customer is Rejected');

            	SELECT inventory_item_id, org_id
            	INTO l_inventory_item_id, l_org_id
            	FROM oe_order_lines_all
            	WHERE line_id = g_line_id_tbl(i);



      	cst_revenuecogsmatch_grp.receive_closelineevent (
		p_api_version            =>  1.0,
		p_init_msg_list          =>  FND_API.G_FALSE,
		p_commit                 =>  FND_API.G_FALSE,
		p_validation_level	 =>  FND_API.G_VALID_LEVEL_FULL,
		x_return_status          =>  l_return_status,
		x_msg_count		 =>  l_msg_count,
		x_msg_data		 =>  l_msg_data,
		p_revenue_event_line_id	 =>  g_line_id_tbl(i),
		p_event_date             =>  SYSDATE,
		p_ou_id			 =>  l_org_id,
		p_inventory_item_id	 =>  l_inventory_item_id);

        END IF;


 	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

	       	   UPDATE oe_order_lines_all
		   SET flow_status_code='NOTIFY_COSTING_ERROR'
		   WHERE line_id = g_line_id_tbl(i);
 	           x_return_status := l_return_status;
                   --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               return;
 END IF;
-- End Bug 8859412

       --AR should be notified only for post-billing acceptance and not for rejection.(i.e. if accepted_quantity=0)
      IF g_accepted_quantity_tbl(i) is not null and g_accepted_quantity_tbl(i) <>0 THEN
                 OE_AR_Acceptance_GRP.Get_interface_attributes
                           (    p_line_id      => g_line_id_tbl(i)
                          ,    x_line_flex_rec => l_line_flex_rec
                          ,    x_return_status => l_return_status
                          ,    x_msg_count     => l_msg_count
                          ,    x_msg_data      => l_msg_data
                          );

		 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 -- no need to raise if the info cannot be derived. just do not call AR.
                 --ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		 --   RAISE FND_API.G_EXC_ERROR;
		 END IF;

                 IF l_line_flex_rec.interface_line_attribute6 IS NOT NULL THEN
                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Calling ar_deferral_reasons_grp.record_acceptance');
                    END IF;
                    ar_deferral_reasons_grp.record_acceptance (
                     p_api_version  => 1.0,
                     p_order_line  =>  l_line_flex_rec,
                     x_return_status  => l_return_status ,
                     x_msg_count   =>l_msg_count,
                     x_msg_data    => l_msg_data );

                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('return status from AR api '||l_return_status);
                    END IF;

		    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;
		 END IF;

         END IF;
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Progress_ Accepted_Lines '|| SQLERRM , 1);
    END IF;
    x_return_status := l_return_status;
END Progress_Accepted_lines;

END OE_ACCEPTANCE_PVT;

/
