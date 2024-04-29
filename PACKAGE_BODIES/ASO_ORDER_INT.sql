--------------------------------------------------------
--  DDL for Package Body ASO_ORDER_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ORDER_INT" as
/* $Header: asoiordb.pls 120.10.12010000.32 2016/12/23 20:05:38 vidsrini ship $ */
-- Start of Comments
-- Package name     : ASO_ORDER_INT
-- Purpose          :
-- History          :
--                  10/07/2002 hyang - 2611381, performance fix for 1158
--				          10/18/2002 hyang - 2633507, performance fix
--                  12/04/2002 hyang - 2692785, performance nocopy fix
--                  04/07/2003 hyang - 2860045, performance fix.
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_ORDER_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiordb.pls';


 PROCEDURE Initialize_OM_rec_types
  (
     px_header_rec           IN OUT NOCOPY       OE_Order_PUB.Header_Rec_Type,
     px_line_tbl             IN OUT NOCOPY       OE_Order_PUB.Line_Tbl_Type,
     p_line_tbl_count        IN           NUMBER
  )
 IS
 BEGIN

    px_header_rec         := OE_Order_PUB.G_MISS_HEADER_REC;
    FOR i in 1..p_line_tbl_count LOOP
       px_line_tbl(i)           := OE_Order_PUB.G_MISS_LINE_REC;
    END LOOP;

 /* the following record types are exact replicas of OM record types
    and are initialized to G_MISS values in aso_order_int.

    px_Header_Scredit_tbl := OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;
    px_Line_Scredit_tbl   := OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;
    px_Lot_Serial_tbl    := OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;
 */

 END Initialize_OM_rec_types;




FUNCTION Salesrep_Id (
     employee_person_id NUMBER
     ) RETURN NUMBER
     IS
     l_salesrep_id NUMBER;

     Cursor C_salesrep IS
         SELECT salesrep_id
         FROM ra_salesreps
         WHERE person_id = employee_person_id
         AND  (sysdate  BETWEEN NVL(start_date_active, sysdate) AND
				 NVL(end_date_active, sysdate));
     BEGIN
         OPEN C_salesrep;
         FETCH C_salesrep into l_salesrep_id;

         IF (C_salesrep%NOTFOUND) THEN
            null;
         END IF;
         CLOSE C_salesrep;

         RETURN l_salesrep_id;
    END Salesrep_Id;


FUNCTION Service_Index (
     quote_line_id     NUMBER := FND_API.G_MISS_NUM,
     quote_line_index  NUMBER := FND_API.G_MISS_NUM,
     P_Line_Rltship_Tbl    ASO_QUOTE_PUB.Line_Rltship_Tbl_Type ,
     p_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type
     ) RETURN NUMBER
     IS
         l_parent_id       NUMBER := FND_API.G_MISS_NUM;
         l_parent_index    NUMBER := FND_API.G_MISS_NUM;
         l_shipment_id     NUMBER := FND_API.G_MISS_NUM;
         l_shipment_index  NUMBER := FND_API.G_MISS_NUM;
     BEGIN

         -- ids  is a fall back. quotes should be using index
 -- figure OUT NOCOPY /* file.sql.39 change */ the parent to which this service has to be linked.
-- this gives the line id/index

       FOR i in 1..p_line_rltship_tbl.count LOOP
          IF (p_line_rltship_tbl(i).related_quote_line_id = quote_line_id
            OR p_line_rltship_tbl(i).related_qte_line_index = quote_line_index)
            AND p_line_rltship_tbl(i).relationship_type_code = 'SERVICE'
          THEN

              l_parent_id     := p_line_rltship_tbl(i).quote_line_id;
              l_parent_index  := p_line_rltship_tbl(i).qte_line_index;
              exit;
           END IF;
        END LOOP;

-- figure OUT NOCOPY /* file.sql.39 change */ the corresponding shipment line id/index
-- If the service is a delayed service then both parent_id and parent_index
-- will be g_miss values.

        IF l_parent_id <> FND_API.G_MISS_NUM
           OR l_parent_index <> FND_API.G_MISS_NUM THEN

           FOR i in 1..p_shipment_tbl.count LOOP
            IF p_shipment_tbl(i).quote_line_id = l_parent_id
              OR p_shipment_tbl(i).qte_line_index = l_parent_index THEN

              l_shipment_id    :=  p_shipment_tbl(i).shipment_id;
              l_shipment_index :=  i;
              exit;
            END IF;
           END LOOP;
        END IF;

-- if every shipment line becomes one and only one quote line then i is the
-- index into the order line. however, this may not be the case in future.
-- then we will have to check the source code id to figure it out.


        IF l_shipment_index <> FND_API.G_MISS_NUM THEN
           return l_shipment_index;
        END IF;

     END;

-- usage: this function is needed because OM is writing messages into its on
-- stack and is not using the fnd stack. here the exception handlers will not
-- take care of it.

PROCEDURE Retrieve_OE_Messages IS
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);
  x_msg_data  VARCHAR2(2000);

  l_len_sqlerrm NUMBER;
  i             NUMBER := 1;

  l_error_index_flag            VARCHAR2(1)  := 'N';
  l_msg_index                   NUMBER := 0;
  l_msg_context                 VARCHAR2(2000);
  l_msg_entity_code             VARCHAR2(30);
  l_msg_entity_ref              VARCHAR2(50);
  l_msg_entity_id               NUMBER;
  l_msg_header_id               NUMBER;
  l_msg_line_id                 NUMBER;
  l_msg_order_source_id         NUMBER;
  l_msg_orig_sys_document_ref   VARCHAR2(50);
  l_msg_change_sequence         VARCHAR2(50);
  l_msg_orig_sys_line_ref       VARCHAR2(50);
  l_msg_orig_sys_shipment_ref   VARCHAR2(50);
  l_msg_source_document_type_id NUMBER;
  l_msg_source_document_id      NUMBER;
  l_msg_source_document_line_id NUMBER;
  l_msg_attribute_code          VARCHAR2(50);
  l_msg_constraint_id           NUMBER;
  l_msg_process_activity        NUMBER;
  l_msg_notification_flag       VARCHAR2(1);
  l_msg_type                    VARCHAR2(30);

 BEGIN

     OE_MSG_PUB.Count_And_Get
   		( p_count         	=>      l_msg_count,
        	  p_data          	=>      l_msg_data
    		);

   IF l_msg_count > 0 THEN

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('before updating the processing messages table',1,'N');
	END IF;

     FOR k IN 1 .. l_msg_count LOOP

       i:=1;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('before calling oe_msg_pub.get',1,'N');
	  END IF;
       oe_msg_pub.get (
           p_msg_index     => k
          ,p_encoded       => FND_API.G_FALSE
          ,p_data          => l_msg_data
          ,p_msg_index_out => l_msg_index);

       IF (upper(l_msg_data) <> 'ORDER HAS BEEN BOOKED.') THEN  -- bug# 1935468

         BEGIN
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('before calling get_msg_context l_msg_index:'||l_msg_index,1,'N');
	    END IF;
         oe_msg_pub.get_msg_context (
           p_msg_index                    => l_msg_index
          ,x_entity_code                  => l_msg_entity_code
          ,x_entity_ref                   => l_msg_entity_ref
          ,x_entity_id                    => l_msg_entity_id
          ,x_header_id                    => l_msg_header_id
          ,x_line_id                      => l_msg_line_id
          ,x_order_source_id              => l_msg_order_source_id
          ,x_orig_sys_document_ref        => l_msg_orig_sys_document_ref
          ,x_orig_sys_line_ref            => l_msg_orig_sys_line_ref
          ,x_orig_sys_shipment_ref        => l_msg_orig_sys_shipment_ref
          ,x_change_sequence              => l_msg_change_sequence
          ,x_source_document_type_id      => l_msg_source_document_type_id
          ,x_source_document_id           => l_msg_source_document_id
          ,x_source_document_line_id      => l_msg_source_document_line_id
          ,x_attribute_code               => l_msg_attribute_code
          ,x_constraint_id                => l_msg_constraint_id
          ,x_process_activity             => l_msg_process_activity
          ,x_notification_flag            => l_msg_notification_flag
          ,x_type                         => l_msg_type
          );

        EXCEPTION
        WHEN others THEN
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Unexpected error in get msg : '||sqlerrm,1,'N');
          aso_debug_pub.add('Ignoring above message',1,'N');
		END IF;
          l_error_index_flag := 'Y';
        END;

        IF l_error_index_flag = 'Y' THEN
           EXIT;
        END IF;
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('after calling get_msg_context',1,'N');
	   END IF;

        IF oe_msg_pub.g_msg_tbl(l_msg_index).message_text IS NULL THEN
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('In index.message_text is null',1,'N');
		END IF;
          x_msg_data := oe_msg_pub.get(l_msg_index, 'F');
        END IF;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('l_msg_orig_sys_line_ref'||l_msg_orig_sys_line_ref,1,'N');
	   END IF;
        IF l_msg_orig_sys_line_ref IS NOT NULL AND l_msg_orig_sys_line_ref <> FND_API.G_MISS_CHAR THEN
          l_msg_context := 'Error in Line: '||rtrim(l_msg_orig_sys_line_ref)||' :';
        END IF;

        x_msg_data := l_msg_context||l_msg_data;

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add(x_msg_data,1,'N');
	   END IF;

        l_len_sqlerrm := Length(x_msg_data) ;
        WHILE l_len_sqlerrm >= i LOOP
          FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
          FND_MESSAGE.Set_token('MSG_TXT' , substr(x_msg_data,i,240));
          i := i + 240;
          FND_MSG_PUB.ADD;
        END LOOP;

       END IF;  -- bug# 1935468

     END LOOP;

   END IF;

END Retrieve_OE_Messages;


PROCEDURE Map_quote_to_fulfillment(
   P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
 			:= ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
   P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
  -- P_fulfillment_tbl            IN  ASO_ORDER_INT.FULFILLMENT_TBL_TYPE,
   X_ffm_content_tbl   OUT NOCOPY /* file.sql.39 change */   ASO_FFM_INT.ffm_content_tbl_type,
   X_ffm_bind_tbl      OUT NOCOPY /* file.sql.39 change */   ASO_FFM_INT.ffm_bind_tbl_type
)
IS


    /*
     * 2611381: changed the cursor variable name so that it is not the
     *          same as column name.
     */
    -- hyang, bug 2860045, performance fix.
    CURSOR C_fulfillment(lc_inventory_item_id NUMBER) IS
       SELECT CAN_FULFILL_ELECTRONIC_FLAG , jtf_amv_item_id
       FROM AMS_DELIVERABLES_ALL_B
       WHERE inventory_item_id =  lc_inventory_item_id;

   fulfil_index NUMBER := 0;
   i            NUMBER;
   j            NUMBER;
   l_electronic_flag VARCHAR2(1);
   l_content_id NUMBER;

BEGIN


     FOR i in 1..p_qte_line_tbl.count LOOP
       Open C_fulfillment(p_qte_line_tbl(i).inventory_item_id);
       FETCH C_fulfillment into l_electronic_flag, l_content_id;
       Close C_fulfillment;

       IF  l_electronic_flag = FND_API.G_TRUE THEN
             fulfil_index := fulfil_index + 1;
             x_ffm_content_tbl(fulfil_index).content_id
			:= l_content_id;
             x_ffm_content_tbl(fulfil_index).quantity
			:= p_qte_line_tbl(i).quantity;
  	     x_ffm_content_tbl(fulfil_index).content_name
			:= p_qte_line_tbl(i).ffm_content_name;
 	     x_ffm_content_tbl(fulfil_index).document_type
                        := p_qte_line_tbl(i).ffm_document_type;
 	     x_ffm_content_tbl(fulfil_index).media_type
                        := p_qte_line_tbl(i).ffm_media_type;

    IF x_ffm_content_tbl(fulfil_index).media_type = 'PRINTER' THEN
      x_ffm_content_tbl(fulfil_index).printer:= p_qte_line_tbl(i).ffm_media_id;
    ELSIF x_ffm_content_tbl(fulfil_index).media_type = 'EMAIL' THEN
      x_ffm_content_tbl(fulfil_index).email  := p_qte_line_tbl(i).ffm_media_id;
    ELSIF x_ffm_content_tbl(fulfil_index).media_type = 'FAX' THEN
      x_ffm_content_tbl(fulfil_index).fax  := p_qte_line_tbl(i).ffm_media_id;
    ELSIF x_ffm_content_tbl(fulfil_index).media_type = 'FILE' THEN
      x_ffm_content_tbl(fulfil_index).file_path
                                            := p_qte_line_tbl(i).ffm_media_id;
    END IF;

         FOR k in 1..p_line_attribs_ext_tbl.count LOOP
          IF p_line_attribs_ext_tbl(k).qte_line_index = i THEN

           x_ffm_bind_tbl(k).content_index := fulfil_index;
           x_ffm_bind_tbl(k).bind_var      := p_line_attribs_ext_tbl(k).name;
           x_ffm_bind_tbl(k).bind_val      := p_line_attribs_ext_tbl(k).value;
           x_ffm_bind_tbl(k).bind_var_type
                                       := p_line_attribs_ext_tbl(k).value_type;

          END IF; -- quote_line_index

        END LOOP;  -- line attribs
    END IF;  -- electronic flag

  END LOOP;

END Map_quote_to_fulfillment;


/*
** convert from ASO_ORDER_INT.Sales_Credit and ASO_ORDER_INT.Lot_Serial
** to ASO_QUOTE_PUB.Sales_Credit and ASO_QUOTE_PUB.Lot_Serial
** respectively.
*/
Procedure Map_Scredit_to_Qcredit(
 P_header_sales_credit_TBL IN  Sales_credit_tbl_type
                := G_MISS_sales_credit_TBL,
 P_Line_sales_credit_TBL IN  Sales_credit_tbl_type
                 := G_MISS_sales_credit_TBL,
 P_Lot_Serial_Tbl    IN   Lot_Serial_Tbl_Type
                                        := G_MISS_Lot_Serial_Tbl,
 x_header_sales_credit_TBL   OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Sales_credit_tbl_type,
 x_Line_sales_credit_TBL     OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Sales_credit_tbl_type,
 x_Lot_Serial_Tbl        OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type,
 X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
 X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS
CURSOR resource_id(p_salesrepid NUMBER) IS
SELECT RESOURCE_ID
from jtf_rs_srp_vl
where SALESREP_ID = p_salesrepid;

BEGIN

FOR i in 1..P_header_sales_credit_TBL.Count LOOP
  x_header_sales_credit_TBL(i).QTE_LINE_INDEX := P_header_sales_credit_TBL(i).line_index;
--  x_header_sales_credit_TBL(i).OPERATION_CODE   :=  P_header_sales_credit_TBL(i).operation;
  x_header_sales_credit_TBL(i).SALES_CREDIT_ID  :=  P_header_sales_credit_TBL(i).sales_credit_id;
--  x_header_sales_credit_TBL(i).CREATION_DATE                   :=  P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).CREATED_BY                      :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).LAST_UPDATED_BY                 :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).LAST_UPDATE_DATE                :=  P_header_sales_credit_TBL(i).;
-- x_header_sales_credit_TBL(i).LAST_UPDATE_LOGIN               :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).REQUEST_ID                      :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).PROGRAM_APPLICATION_ID          :=   P_header_sales_credit_TBL(i).;
-- x_header_sales_credit_TBL(i).PROGRAM_ID                      :=   P_header_ sales_credit_TBL(i).;
--x_header_sales_credit_TBL(i).PROGRAM_UPDATE_DATE             :=  P_header_sales_credit_TBL(i).;
--x_header_sales_credit_TBL(i).SECURITY_GROUP_ID               :=   P_header_sales_credit_TBL(i).;
x_header_sales_credit_TBL(i).QUOTE_HEADER_ID                 :=   P_header_sales_credit_TBL(i).QUOTE_HEADER_ID;
  x_header_sales_credit_TBL(i).QUOTE_LINE_ID                   :=   P_header_sales_credit_TBL(i).QUOTE_LINE_ID;
  x_header_sales_credit_TBL(i).PERCENT                         :=   P_header_sales_credit_TBL(i).PERCENT;

 OPEN resource_id(P_header_sales_credit_TBL(i).SALESREP_ID);
 FETCH resource_id INTO x_header_sales_credit_TBL(i).RESOURCE_ID;
 IF (resource_id%NOTFOUND) THEN
     CLOSE resource_id;
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		 FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
		 FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE ID', FALSE);
		 FND_MSG_PUB.ADD;
	END IF;
 ELSE
	CLOSE resource_id;
 END IF;

/*
SELECT RESOURCE_ID  into  x_header_sales_credit_TBL(i).RESOURCE_ID
  from jtf_rs_srp_vl
  where SALESREP_ID = P_header_sales_credit_TBL(i).SALESREP_ID;
*/

--  x_header_sales_credit_TBL(i).FIRST_NAME                      :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).LAST_NAME                       :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).SALES_CREDIT_TYPE               :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).RESOURCE_GROUP_ID               :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).EMPLOYEE_PERSON_ID              :=   P_header_sales_credit_TBL(i).;
--  x_header_sales_credit_TBL(i).SALES_CREDIT_TYPE_ID            :=    P_header_sales_credit_TBL(i).;
  x_header_sales_credit_TBL(i).ATTRIBUTE_CATEGORY_CODE         :=     P_header_sales_credit_TBL(i).CONTEXT;
  x_header_sales_credit_TBL(i).ATTRIBUTE1                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE1;
  x_header_sales_credit_TBL(i).ATTRIBUTE2                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE2;
  x_header_sales_credit_TBL(i).ATTRIBUTE3                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE3;
  x_header_sales_credit_TBL(i).ATTRIBUTE4                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE4;
  x_header_sales_credit_TBL(i).ATTRIBUTE5                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE5;
  x_header_sales_credit_TBL(i).ATTRIBUTE6                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE6;
  x_header_sales_credit_TBL(i).ATTRIBUTE7                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE7;
  x_header_sales_credit_TBL(i).ATTRIBUTE8                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE8;
  x_header_sales_credit_TBL(i).ATTRIBUTE9                      :=   P_header_sales_credit_TBL(i).ATTRIBUTE9;
  x_header_sales_credit_TBL(i).ATTRIBUTE10                     :=   P_header_sales_credit_TBL(i).ATTRIBUTE10;
  x_header_sales_credit_TBL(i).ATTRIBUTE11                     :=   P_header_sales_credit_TBL(i).ATTRIBUTE11;
  x_header_sales_credit_TBL(i).ATTRIBUTE12                     :=   P_header_sales_credit_TBL(i).ATTRIBUTE12;
  x_header_sales_credit_TBL(i).ATTRIBUTE13                     :=   P_header_sales_credit_TBL(i).ATTRIBUTE13;
  x_header_sales_credit_TBL(i).ATTRIBUTE14                     :=   P_header_sales_credit_TBL(i).ATTRIBUTE14;
  x_header_sales_credit_TBL(i).ATTRIBUTE15                     :=   P_header_sales_credit_TBL(i).ATTRIBUTE15;
END LOOP;



FOR i in 1..P_line_sales_credit_TBL.Count LOOP

x_line_sales_credit_TBL(i).QTE_LINE_INDEX := P_line_sales_credit_TBL(i).line_index;
--x_line_sales_credit_TBL(i).OPERATION_CODE   :=  P_line_sales_credit_TBL(i).operation;
  x_line_sales_credit_TBL(i).SALES_CREDIT_ID  :=  P_line_sales_credit_TBL(i).sales_credit_id;
--  x_line_sales_credit_TBL(i).CREATION_DATE                   :=  P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).CREATED_BY                      :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).LAST_UPDATED_BY                 :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).LAST_UPDATE_DATE                :=  P_line_sales_credit_TBL(i).;
-- x_line_sales_credit_TBL(i).LAST_UPDATE_LOGIN               :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).REQUEST_ID                      :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).PROGRAM_APPLICATION_ID          :=   P_line_sales_credit_TBL(i).;
-- x_line_sales_credit_TBL(i).PROGRAM_ID                      :=   P_line_sales_credit_TBL(i).;
--x_line_sales_credit_TBL(i).PROGRAM_UPDATE_DATE             :=  P_line_sales_credit_TBL(i).;
--x_line_sales_credit_TBL(i).SECURITY_GROUP_ID               :=   P_line_sale_credit_TBL(i).;
x_line_sales_credit_TBL(i).QUOTE_HEADER_ID                 :=   P_line_sales_credit_TBL(i).QUOTE_HEADER_ID;
  x_line_sales_credit_TBL(i).QUOTE_LINE_ID                   :=   P_line_sales_credit_TBL(i).QUOTE_LINE_ID;
  x_line_sales_credit_TBL(i).PERCENT                         :=   P_line_sales_credit_TBL(i).PERCENT;

OPEN resource_id(P_line_sales_credit_TBL(i).SALESREP_ID);
FETCH resource_id into x_line_sales_credit_TBL(i).RESOURCE_ID;
IF (resource_id%NOTFOUND) THEN
	CLOSE resource_id;
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
	       FND_MESSAGE.Set_Token('COLUMN', 'RESOURCE ID', FALSE);
		  FND_MSG_PUB.ADD;
	END IF;
ELSE
	CLOSE resource_id;
END IF;


/*
  SELECT RESOURCE_ID  into  x_line_sales_credit_TBL(i).RESOURCE_ID
  from jtf_rs_srp_vl
  where SALESREP_ID = P_line_sales_credit_TBL(i).SALESREP_ID;
*/

--  x_line_sales_credit_TBL(i).FIRST_NAME                      :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).LAST_NAME                       :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).SALES_CREDIT_TYPE               :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).RESOURCE_GROUP_ID               :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).EMPLOYEE_PERSON_ID              :=   P_line_sales_credit_TBL(i).;
--  x_line_sales_credit_TBL(i).SALES_CREDIT_TYPE_ID            :=    P_line_sales_credit_TBL(i).;
x_line_sales_credit_TBL(i).ATTRIBUTE_CATEGORY_CODE         :=     P_line_sales_credit_TBL(i).CONTEXT;
  x_line_sales_credit_TBL(i).ATTRIBUTE1                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE1;
 x_line_sales_credit_TBL(i).ATTRIBUTE2                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE2;
x_line_sales_credit_TBL(i).ATTRIBUTE3                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE3;
  x_line_sales_credit_TBL(i).ATTRIBUTE4                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE4;
  x_line_sales_credit_TBL(i).ATTRIBUTE5                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE5;
  x_line_sales_credit_TBL(i).ATTRIBUTE6                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE6;
  x_line_sales_credit_TBL(i).ATTRIBUTE7                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE7;
  x_line_sales_credit_TBL(i).ATTRIBUTE8                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE8;
  x_line_sales_credit_TBL(i).ATTRIBUTE9                      :=   P_line_sales_credit_TBL(i).ATTRIBUTE9;
  x_line_sales_credit_TBL(i).ATTRIBUTE10                     :=   P_line_sales_credit_TBL(i).ATTRIBUTE10;
  x_line_sales_credit_TBL(i).ATTRIBUTE11                     :=   P_line_sales_credit_TBL(i).ATTRIBUTE11;
  x_line_sales_credit_TBL(i).ATTRIBUTE12                     :=   P_line_sales_credit_TBL(i).ATTRIBUTE12;
  x_line_sales_credit_TBL(i).ATTRIBUTE13                     :=   P_line_sales_credit_TBL(i).ATTRIBUTE13;
  x_line_sales_credit_TBL(i).ATTRIBUTE14                     :=   P_line_sales_credit_TBL(i).ATTRIBUTE14;
  x_line_sales_credit_TBL(i).ATTRIBUTE15                     :=   P_line_sales_credit_TBL(i).ATTRIBUTE15;

END LOOP;


FOR i in 1..p_Lot_Serial_Tbl.COUNT LOOP
 x_Lot_Serial_Tbl(i).attribute1                    := p_Lot_Serial_Tbl(i).attribute1 ;
x_Lot_Serial_Tbl(i).attribute10                   := p_Lot_Serial_Tbl(i).attribute10 ;
x_Lot_Serial_Tbl(i).attribute11                   := p_Lot_Serial_Tbl(i).attribute11 ;
x_Lot_Serial_Tbl(i).attribute12                   := p_Lot_Serial_Tbl(i).attribute12 ;
x_Lot_Serial_Tbl(i).attribute13                   := p_Lot_Serial_Tbl(i).attribute13 ;
x_Lot_Serial_Tbl(i).attribute14                   := p_Lot_Serial_Tbl(i).attribute14 ;
   x_Lot_Serial_Tbl(i).attribute15                   := p_Lot_Serial_Tbl(i).attribute15 ;
   x_Lot_Serial_Tbl(i).attribute2                    := p_Lot_Serial_Tbl(i).attribute2 ;
   x_Lot_Serial_Tbl(i).attribute3                    := p_Lot_Serial_Tbl(i).attribute3 ;
   x_Lot_Serial_Tbl(i).attribute4                    := p_Lot_Serial_Tbl(i).attribute4 ;
   x_Lot_Serial_Tbl(i).attribute5                    := p_Lot_Serial_Tbl(i).attribute5 ;
   x_Lot_Serial_Tbl(i).attribute6                    := p_Lot_Serial_Tbl(i).attribute6 ;
   x_Lot_Serial_Tbl(i).attribute7                    := p_Lot_Serial_Tbl(i).attribute7 ;
    x_Lot_Serial_Tbl(i).attribute8                    := p_Lot_Serial_Tbl(i).attribute8 ;
   x_Lot_Serial_Tbl(i).attribute9                    := p_Lot_Serial_Tbl(i).attribute9 ;
   x_Lot_Serial_Tbl(i).context     := p_Lot_Serial_Tbl(i).context ;
   x_Lot_Serial_Tbl(i).created_by                    := p_Lot_Serial_Tbl(i).created_by ;
x_Lot_Serial_Tbl(i).creation_date                := p_Lot_Serial_Tbl(i).creation_date ;
x_Lot_Serial_Tbl(i).from_serial_number    := p_Lot_Serial_Tbl(i).from_serial_number ;
   x_Lot_Serial_Tbl(i).last_updated_by           := p_Lot_Serial_Tbl(i).last_updated_by ;
   x_Lot_Serial_Tbl(i).last_update_date              := p_Lot_Serial_Tbl(i).last_update_date ;
   x_Lot_Serial_Tbl(i).last_update_login             := p_Lot_Serial_Tbl(i).last_update_login ;
   x_Lot_Serial_Tbl(i).line_id                       := p_Lot_Serial_Tbl(i).line_id ;
   x_Lot_Serial_Tbl(i).lot_number            := p_Lot_Serial_Tbl(i).lot_number;
   x_Lot_Serial_Tbl(i).lot_serial_id                := p_Lot_Serial_Tbl(i).lot_serial_id ;
   x_Lot_Serial_Tbl(i).quantity                     := p_Lot_Serial_Tbl(i).quantity ;
   x_Lot_Serial_Tbl(i).to_serial_number      := p_Lot_Serial_Tbl(i).to_serial_number ;
   x_Lot_Serial_Tbl(i).return_status          := p_Lot_Serial_Tbl(i).return_status ;
   x_Lot_Serial_Tbl(i).db_flag                := p_Lot_Serial_Tbl(i).db_flag ;
x_Lot_Serial_Tbl(i).operation             := p_Lot_Serial_Tbl(i).operation ;
   x_Lot_Serial_Tbl(i).line_index                   := p_Lot_Serial_Tbl(i).line_index ;
   x_Lot_Serial_Tbl(i).orig_sys_lotserial_ref        := p_Lot_Serial_Tbl(i).orig_sys_lotserial_ref ;
   x_Lot_Serial_Tbl(i).change_request_code          := p_Lot_Serial_Tbl(i).change_request_code ;
   x_Lot_Serial_Tbl(i).status_flag                    := p_Lot_Serial_Tbl(i).status_flag ;
   x_Lot_Serial_Tbl(i).line_set_id                   := p_Lot_Serial_Tbl(i).line_set_id;

END LOOP;


END Map_Scredit_to_Qcredit;



PROCEDURE Create_order(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                            := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			    := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			    := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl  IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			     := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl    IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_header_sales_credit_TBL      IN   Sales_credit_tbl_type
			     := G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_tbl IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl  IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			     := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl  IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			     := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   Sales_credit_tbl_type
			     := G_MISS_sales_credit_TBL,
    P_Lot_Serial_Tbl        IN   Lot_Serial_Tbl_Type
                             := G_MISS_Lot_Serial_Tbl,
    P_Control_Rec                IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30):= 'CREATE_ORDER';
  l_header_sales_credit_TBL   ASO_QUOTE_PUB.Sales_credit_tbl_type := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL;
  l_Line_sales_credit_TBL     ASO_QUOTE_PUB.Sales_credit_tbl_type := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL;
  l_Lot_Serial_Tbl             ASO_QUOTE_PUB.Lot_Serial_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl;
  l_prg_index number:=0;
  l_dis_index number:=0;

BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ORDER_PVT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      Map_Scredit_to_Qcredit(
         	P_header_sales_credit_TBL => p_header_sales_credit_TBL,
 		P_Line_sales_credit_TBL => P_Line_sales_credit_TBL,
 		P_Lot_Serial_Tbl    => P_Lot_Serial_Tbl,
 		x_header_sales_credit_TBL => l_header_sales_credit_TBL,
 		x_Line_sales_credit_TBL    => l_Line_sales_credit_TBL,
 		x_Lot_Serial_Tbl       => l_Lot_Serial_Tbl,
 		X_Return_Status   => X_Return_Status,
 		X_Msg_Count    => X_Msg_Count,
 		X_Msg_Data  => X_Msg_Data
           );


     -- call the overloaded procedure create_order

     Create_Order(
         P_Api_Version   => l_api_version_number,
    P_Init_Msg_List    =>P_Init_Msg_List,
    P_Commit           =>p_commit,
    P_Qte_Rec          => P_Qte_Rec,
    P_Header_Payment_Tbl   => P_Header_Payment_Tbl,
    P_Header_Price_Adj_Tbl    => P_Header_Price_Adj_Tbl,
    P_Header_Price_Attributes_Tbl => P_Header_Price_Attributes_Tbl,
    P_Header_Price_Adj_rltship_Tbl =>P_Header_Price_Adj_rltship_Tbl,
    P_Header_Price_Adj_Attr_Tbl  => P_Header_Price_Adj_Attr_Tbl,
    P_Header_Shipment_Tbl   => P_Header_Shipment_Tbl,
    P_Header_TAX_DETAIL_Tbl =>P_Header_TAX_DETAIL_Tbl,
    P_Header_FREIGHT_CHARGE_Tbl   => P_Header_FREIGHT_CHARGE_Tbl,
    P_Header_ATTRIBS_EXT_Tbl  => ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Header_Quote_Party_Tbl      =>  ASO_QUOTE_PUB.G_MISS_QUOTE_PARTY_TBL,
    P_header_sales_credit_TBL  => l_header_sales_credit_TBL,
    P_Qte_Line_Tbl    => P_Qte_Line_Tbl,
    P_Qte_Line_Dtl_Tbl => P_Qte_Line_Dtl_Tbl,
    P_Line_Payment_Tbl => P_Line_Payment_Tbl,
    P_Line_Price_Adj_Tbl  => P_Line_Price_Adj_Tbl,
    P_Line_Price_Attributes_Tbl => P_Line_Price_Attributes_Tbl,
    P_Line_Price_Adj_rltship_Tbl => P_Line_Price_Adj_rltship_Tbl,
    P_Line_Price_Adj_Attr_Tbl  => P_Line_Price_Adj_Attr_Tbl,
    P_Line_Shipment_Tbl     => P_Line_Shipment_Tbl,
    P_Line_TAX_DETAIL_Tbl  => P_Line_TAX_DETAIL_Tbl,
    P_Line_FREIGHT_CHARGE_Tbl     => P_Line_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl =>P_Line_ATTRIBS_EXT_Tbl,
    P_Line_Rltship_Tbl  => P_Line_Rltship_Tbl,
    P_Line_sales_credit_TBL  =>  l_line_sales_credit_TBL,
    P_Line_Quote_Party_Tbl   =>  ASO_QUOTE_PUB.G_MISS_QUOTE_PARTY_TBL,
    P_Lot_Serial_Tbl     => l_Lot_Serial_Tbl,
    P_Control_Rec        => P_Control_Rec,
    X_Order_Header_Rec  => X_Order_Header_Rec,
    X_Order_Line_Tbl   => X_Order_Line_Tbl,
    X_Return_Status   => X_Return_Status,
    X_Msg_Count    => X_Msg_Count,
    X_Msg_Data  => X_Msg_Data
   );
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
--	retrieve_oe_messages;
        RAISE FND_API.G_EXC_ERROR;
 END IF;


      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		null;
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		null;
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
		null;
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Order;


PROCEDURE Update_order(
   P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
   P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
   P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
   P_Header_Price_Attributes_Tbl IN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
   P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
   P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			 := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
   P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
   P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
   P_Header_FREIGHT_CHARGE_Tbl   IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
   P_header_sales_credit_TBL      IN   Sales_credit_tbl_type
			  := G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_tbl IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl    IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   Sales_credit_tbl_type
			:= G_MISS_sales_credit_TBL,
    P_Lot_Serial_Tbl        IN   Lot_Serial_Tbl_Type
                             := G_MISS_Lot_Serial_Tbl,
    P_Control_Rec                IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Update_Order';
  l_header_sales_credit_TBL   ASO_QUOTE_PUB.Sales_credit_tbl_type := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL;
  l_Line_sales_credit_TBL     ASO_QUOTE_PUB.Sales_credit_tbl_type := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL;
  l_Lot_Serial_Tbl             ASO_QUOTE_PUB.Lot_Serial_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl;

BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT UPDATE_order_PVT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --



      Map_Scredit_to_Qcredit(
         P_header_sales_credit_TBL => p_header_sales_credit_TBL,
 P_Line_sales_credit_TBL => P_Line_sales_credit_TBL,
 P_Lot_Serial_Tbl    => P_Lot_Serial_Tbl,
 x_header_sales_credit_TBL => l_header_sales_credit_TBL,
 x_Line_sales_credit_TBL    => l_Line_sales_credit_TBL,
 x_Lot_Serial_Tbl       => l_Lot_Serial_Tbl,
 X_Return_Status   => X_Return_Status,
 X_Msg_Count    => X_Msg_Count,
 X_Msg_Data  => X_Msg_Data
           );



      -- call overloaded procedure UpdatE_order.
           Update_Order(
             P_Api_Version   => l_api_version_number,
    P_Init_Msg_List    =>P_Init_Msg_List,
    P_Commit           =>p_commit,
    P_Qte_Rec          => P_Qte_Rec,
    P_Header_Payment_Tbl   => P_Header_Payment_Tbl,
    P_Header_Price_Adj_Tbl    => P_Header_Price_Adj_Tbl,
    P_Header_Price_Attributes_Tbl => P_Header_Price_Attributes_Tbl,
    P_Header_Price_Adj_rltship_Tbl =>P_Header_Price_Adj_rltship_Tbl,
    P_Header_Price_Adj_Attr_Tbl  => P_Header_Price_Adj_Attr_Tbl,
    P_Header_Shipment_Tbl   => P_Header_Shipment_Tbl,
    P_Header_TAX_DETAIL_Tbl =>P_Header_TAX_DETAIL_Tbl,
    P_Header_FREIGHT_CHARGE_Tbl   => P_Header_FREIGHT_CHARGE_Tbl,
    P_Header_ATTRIBS_EXT_Tbl  => ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Header_Quote_Party_Tbl      =>  ASO_QUOTE_PUB.G_MISS_QUOTE_PARTY_TBL,
    P_header_sales_credit_TBL  => l_header_sales_credit_TBL,
    P_Qte_Line_Tbl    => P_Qte_Line_Tbl,
    P_Qte_Line_Dtl_Tbl => P_Qte_Line_Dtl_Tbl,
    P_Line_Payment_Tbl => P_Line_Payment_Tbl,
    P_Line_Price_Adj_Tbl  => P_Line_Price_Adj_Tbl,
    P_Line_Price_Attributes_Tbl => P_Line_Price_Attributes_Tbl,
    P_Line_Price_Adj_rltship_Tbl => P_Line_Price_Adj_rltship_Tbl,
    P_Line_Price_Adj_Attr_Tbl  => P_Line_Price_Adj_Attr_Tbl,
    P_Line_Shipment_Tbl     => P_Line_Shipment_Tbl,
    P_Line_TAX_DETAIL_Tbl  => P_Line_TAX_DETAIL_Tbl,
    P_Line_FREIGHT_CHARGE_Tbl     => P_Line_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl =>ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl  => P_Line_Rltship_Tbl,
    P_Line_sales_credit_TBL  =>  l_Line_sales_credit_TBL ,
    P_Line_Quote_Party_Tbl   =>  ASO_QUOTE_PUB.G_MISS_QUOTE_PARTY_TBL,
    P_Lot_Serial_Tbl     => l_Lot_Serial_Tbl,
    P_Control_Rec        => P_Control_Rec,
    X_Order_Header_Rec  => X_Order_Header_Rec,
    X_Order_Line_Tbl   => X_Order_Line_Tbl,
    X_Return_Status   => X_Return_Status,
    X_Msg_Count    => X_Msg_Count,
    X_Msg_Data  => X_Msg_Data
   );

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
--        retrieve_oe_messages;
        RAISE FND_API.G_EXC_ERROR;
 END IF;

       --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		null;
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		null;
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
		null;
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_Order;


PROCEDURE Delete_order(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Order_Header_id            IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'DELETE_ORDER';
BEGIN


   -- Standard Start of API savepoint
      SAVEPOINT Delete_Order_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


	OE_ORDER_PUB.Delete_Order
	(
 	    p_header_id      => p_order_header_id
	,   x_return_status  => x_return_status
	,   x_msg_count      => x_msg_count
	,   x_msg_data       => x_msg_data
	);


         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     retrieve_oe_messages;
             RAISE FND_API.G_EXC_ERROR;
         END IF;


       --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		null;
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		null;
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
		null;
		 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Delete_order;



PROCEDURE BOOK_ORDER(
    P_Api_Version_Number         IN   NUMBER ,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_order_header_id            IN   NUMBER ,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'BOOK_ORDER';




 l_request_tbl                 OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL;
  l_line_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;


l_return_values               varchar2(50);
l_header_val_rec	      OE_Order_PUB.Header_Val_Rec_Type;
l_old_header_val_rec          OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_old_header_adj_val_tbl      OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_old_header_scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_val_tbl		      OE_Order_PUB.Line_Val_Tbl_Type;
l_old_line_val_tbl            OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_old_line_adj_val_tbl        OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_old_line_scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_old_lot_serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
 l_msg_count                  number;
 l_msg_data                   varchar2(200);

 -- hyang: 2692785
 lx_header_rec                  OE_Order_PUB.Header_Rec_Type;

BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT Book_Order_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
       OE_ORDER_BOOK_UTIL.BOOK_ORDER
        (p_api_version_number	=> 1.0
	,p_header_id		=> p_order_header_id
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	) ;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   retrieve_oe_messages;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

*/

   Initialize_OM_rec_types(
     px_header_rec         => l_header_rec,
     px_line_tbl           => l_line_tbl,
     p_line_tbl_count      => 0
    );


     l_request_tbl(1).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;
     l_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;
     l_header_rec.header_id        := p_order_header_id;
  -- l_header_rec.operation        :=  OE_Globals.G_OPR_UPDATE;

-- bug# 1927450
OE_STANDARD_WF.SAVE_MESSAGES_OFF;

OE_Order_GRP.Process_Order
(   p_api_version_number        => 1.0
,   p_init_msg_list             => FND_API.G_TRUE
,   p_return_values	  	=> l_return_values
,   p_commit 	                => FND_API.G_FALSE
,   x_return_status	  	=> x_return_status
,   x_msg_count    	  	=> x_msg_count
,   x_msg_data    	  	=>  x_msg_data
,   p_header_rec  	  	=> l_header_rec
,   p_Action_Request_tbl        => l_request_tbl
,   x_header_rec     		=> lx_header_rec
,   x_header_val_rec 		=> l_header_val_rec
,   x_Header_Adj_tbl 		=> l_header_adj_tbl
,   x_Header_Adj_val_tbl 	=> l_header_adj_val_tbl
,   x_Header_price_Att_tbl 	=> l_header_price_att_tbl
,   x_Header_Adj_Att_tbl  	=> l_header_adj_att_tbl
,   x_Header_Adj_Assoc_tbl   	=> l_header_adj_assoc_tbl
,   x_Header_Scredit_tbl   	=> l_header_scredit_tbl
,   x_Header_Scredit_val_tbl 	=> l_header_scredit_val_tbl
,   x_line_tbl      		=> l_line_tbl
,   x_line_val_tbl  		=> l_line_val_tbl
,   x_Line_Adj_tbl 	 	=> l_line_adj_tbl
,   x_Line_Adj_val_tbl 		=> l_line_adj_val_tbl
,   x_Line_price_Att_tbl 	=> l_line_price_att_tbl
,   x_Line_Adj_Att_tbl  	=> l_line_adj_att_tbl
,   x_Line_Adj_Assoc_tbl	=> l_line_adj_assoc_tbl
,   x_Line_Scredit_tbl 		=> l_line_scredit_tbl
,   x_Line_Scredit_val_tbl	=> l_line_scredit_val_tbl
,   x_Lot_Serial_tbl    	=> l_lot_serial_tbl
,   x_Lot_Serial_val_tbl 	=> l_lot_serial_val_tbl
,   x_action_request_tbl	=> l_action_request_tbl
);


 -- hyang: 2692785
	l_header_rec := lx_header_rec;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Book_Order;




PROCEDURE CANCEL_ORDER(
    P_Api_Version_Number         IN   NUMBER ,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_order_header_id            IN   NUMBER ,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'CANCEL_ORDER';




 l_request_tbl                 OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL;
  l_line_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;


l_return_values               varchar2(50);
l_header_val_rec	      OE_Order_PUB.Header_Val_Rec_Type;
l_old_header_val_rec          OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_old_header_adj_val_tbl      OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_old_header_scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_val_tbl		      OE_Order_PUB.Line_Val_Tbl_Type;
l_old_line_val_tbl            OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_old_line_adj_val_tbl        OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_old_line_scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_old_lot_serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_msg_count                  number;
l_msg_data                   varchar2(200);

 -- hyang: 2692785
  lx_header_rec                  OE_Order_PUB.Header_Rec_Type;

CURSOR C_cancel_reason IS
	SELECT lookup_code
	from oe_lookups
	WHERE lookup_type = 'CANCEL_CODE'
	AND lookup_code = 'Not provided';
BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT CANCEL_Order_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


    -- Initialize OM record types
  Initialize_OM_rec_types(
     px_header_rec         => l_header_rec,
     px_line_tbl           => l_line_tbl,
     p_line_tbl_count      => 0
    );


     l_header_rec.header_id        := p_order_header_id;
     l_header_rec.cancelled_flag   := 'Y';

	OPEN C_cancel_reason;
	FETCH C_cancel_reason into l_header_rec.change_reason;
	CLOSE C_cancel_reason;

     l_header_rec.operation        := OE_Globals.G_OPR_UPDATE;

-- bug# 1927450
OE_STANDARD_WF.SAVE_MESSAGES_OFF;

OE_Order_GRP.Process_Order
(   p_api_version_number        => 1.0
,   p_init_msg_list             => FND_API.G_TRUE
,   p_return_values	  	=> l_return_values
,   p_commit 	                => FND_API.G_FALSE
,   x_return_status	  	=> x_return_status
,   x_msg_count    	  	=> x_msg_count
,   x_msg_data    	  	=>  x_msg_data
,   p_header_rec  	  	=> l_header_rec
,   x_header_rec     		=> lx_header_rec
,   x_header_val_rec 		=> l_header_val_rec
,   x_Header_Adj_tbl 		=> l_header_adj_tbl
,   x_Header_Adj_val_tbl 	=> l_header_adj_val_tbl
,   x_Header_price_Att_tbl 	=> l_header_price_att_tbl
,   x_Header_Adj_Att_tbl  	=> l_header_adj_att_tbl
,   x_Header_Adj_Assoc_tbl   	=> l_header_adj_assoc_tbl
,   x_Header_Scredit_tbl   	=> l_header_scredit_tbl
,   x_Header_Scredit_val_tbl 	=> l_header_scredit_val_tbl
,   x_line_tbl      		=> l_line_tbl
,   x_line_val_tbl  		=> l_line_val_tbl
,   x_Line_Adj_tbl 	 	=> l_line_adj_tbl
,   x_Line_Adj_val_tbl 		=> l_line_adj_val_tbl
,   x_Line_price_Att_tbl 	=> l_line_price_att_tbl
,   x_Line_Adj_Att_tbl  	=> l_line_adj_att_tbl
,   x_Line_Adj_Assoc_tbl	=> l_line_adj_assoc_tbl
,   x_Line_Scredit_tbl 		=> l_line_scredit_tbl
,   x_Line_Scredit_val_tbl	=> l_line_scredit_val_tbl
,   x_Lot_Serial_tbl    	=> l_lot_serial_tbl
,   x_Lot_Serial_val_tbl 	=> l_lot_serial_val_tbl
,   x_action_request_tbl	=> l_action_request_tbl
);


 -- hyang: 2692785
  l_header_rec := lx_header_rec;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Cancel_Order;

PROCEDURE copy_configuration(p_config_hdr_id       IN      NUMBER,
                             p_config_rev_nbr      IN      NUMBER,
                             x_config_hdr_id   IN  OUT NOCOPY NUMBER,
                             x_config_rev_nbr  IN  OUT NOCOPY NUMBER,
                             x_error_message       IN  OUT NOCOPY VARCHAR2,
                             x_return_value        IN  OUT NOCOPY NUMBER)
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
Begin
        CZ_CF_API.Copy_Configuration
        (config_hdr_id => p_config_hdr_id ,
          config_rev_nbr => p_config_rev_nbr ,
          new_config_flag => 1,
          out_config_hdr_id => x_config_hdr_id ,
          out_config_rev_nbr => x_config_rev_nbr ,
          Error_message => x_error_message ,
          Return_value => x_return_value );

	    Commit;
End;

--- create order overloaded
-- the following procedure is an overloaded procedure which takes the same
-- parameters as the create order but all record types are defined in
-- ASO_QUOTE_PUB.

PROCEDURE Create_order(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl   IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Header_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Header_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_header_sales_credit_TBL   IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			:= ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_Tbl IN    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl      IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			:= ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Line_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Lot_Serial_Tbl        IN   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type
                             := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl,
    P_Control_Rec           IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30):= 'CREATE_ORDER';
  l_control_rec                 OE_GLOBALS.Control_Rec_Type;
  l_return_status               VARCHAR2(1);

  l_line_shipment_tbl            ASO_QUOTE_PUB.Shipment_Tbl_Type;

  -- header record types
  l_header_rec                  OE_Order_PUB.Header_Rec_Type;
  l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
  l_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
  l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
  l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
  l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
  l_Header_Payment_val_tbl      OE_Order_PUB.Header_Payment_Val_Tbl_Type;
  -- line record types
  l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
  l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
  l_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
  l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
  l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
  l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
  l_Line_Payment_val_tbl        OE_Order_PUB.Line_Payment_Val_Tbl_Type;

  l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
  l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
  l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
  l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
  l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
  l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
  l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
  l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
  l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
  l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
  l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;

  l_return_values               varchar2(50);
  l_header_val_rec              OE_Order_PUB.Header_Val_Rec_Type;
  l_old_header_val_rec          OE_Order_PUB.Header_Val_Rec_Type;
  l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
  l_old_header_adj_val_tbl      OE_Order_PUB.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
  l_old_header_scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
  l_line_val_tbl                OE_Order_PUB.Line_Val_Tbl_Type;
  l_old_line_val_tbl            OE_Order_PUB.Line_Val_Tbl_Type;
  l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
  l_old_line_adj_val_tbl        OE_Order_PUB.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
  l_old_line_scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
  l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
  l_old_lot_serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
  l_request_tbl                 OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL;

  -- hyang: bug 2692785
  lx_header_rec                  OE_Order_PUB.Header_Rec_Type;
  lx_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
  lx_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
  lx_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
  lx_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
  lx_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
  lx_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
  lx_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
  lx_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
  lx_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
  lx_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
  lx_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
  lx_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
  lx_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
  lx_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;

  -- needed for fulfillment
  fulfil_index                  NUMBER := 1;
  l_electronic_flag             varchar2(1);

   fulfillment                  FULFILLMENT_TBL_TYPE;
   p_ffm_request_rec            ASO_FFM_INT.FFM_REQUEST_REC_TYPE;
   l_ffm_content_tbl            ASO_FFM_INT.FFM_CONTENT_TBL_TYPE;
   l_ffm_bind_tbl               ASO_FFM_INT.FFM_Bind_Tbl_Type;
   X_Request_ID                 NUMBER;

   l_split_pay_prof			  VARCHAR2(2) := FND_PROFILE.Value('ASO_ENABLE_SPLIT_PAYMENT');
   l_CC_Auth_Prof			  VARCHAR2(2) := FND_PROFILE.Value('ASO_CC_AUTHORIZATION_ENABLED');
   l_Enable_Risk_Mgmt_Prof	  VARCHAR2(2);
   l_CC_Auth_Failure_Prof   	  VARCHAR2(20);
   l_Risk_Mgmt_Failure_Prof 	  VARCHAR2(20);

   i                            NUMBER := 1;
   --c_lock number;
   L_QUOTE_HEADER_ID number;
   L_QUOTE_STATUS_ID number;
   dbg_file varchar2(1024);
   P varchar2(50);
 l_prg_index number:=0;
 l_dis_index number:=0;
 mod_header_id number;
  cc number;
 v number;
 vs1 number;
 modifier_type VARCHAR2(100);
  prg_index number :=0;
 dis_index number :=0;
 chk_index number :=0;
   PREV_ADJ_INDEX NUMBER:=0;
  assoc_tbl_index number :=1;
  mod_head_id number;
   l_qte_line_tbl            ASO_QUOTE_PUB.Qte_Line_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Qte_Line_Tbl  ;

  /*** Start : Code change done for Bug 14358079 ***/

  CURSOR C_LOCK(P_QUOTE_HEADER_ID NUMBER, P_QUOTE_STATUS_ID NUMBER) IS
  SELECT QUOTE_HEADER_ID,
         QUOTE_STATUS_ID
    FROM ASO_QUOTE_HEADERS_ALL
   WHERE QUOTE_HEADER_ID = P_QUOTE_HEADER_ID
     AND QUOTE_STATUS_ID = P_QUOTE_STATUS_ID
     FOR UPDATE OF QUOTE_STATUS_ID NOWAIT;

--Bug 21224933
  l_qte_line_dtl_rec                  ASO_QUOTE_PUB.Qte_Line_Rec_Type;
 l_qte_line_dtl_tbl              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
 l_config_hdr_id number;
 l_config_rev_nbr    number;
 l_return_value      number;
 l_error_message     varchar2(100);
  /*** End : Code change done for Bug 14358079 ***/



j number := 1;
   l_len_sqlerrm NUMBER;
  k NUMBER := 1;
    lx_return_status                  varchar2(10);

BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT CREATE_ORDER_PVT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: Begin ', 1, 'N');
END IF;
   -- change the org to whatever is stored in the org id column
       IF p_qte_rec.org_id is not NULL
          AND p_qte_rec.org_id <> FND_API.G_MISS_NUM THEN

		 /* fnd_client_info.set_org_context(p_qte_rec.org_id); */ --Commented Code Yogeshwar (MOAC)
		   MO_GLOBAL.set_policy_context('S', p_qte_rec.org_id) ;   --New Code Yogeshwar (MOAC)

       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_split_pay_prof: '||l_split_pay_prof,1,'N');
END IF;

    IF (l_split_pay_prof = 'N') THEN
       IF p_header_payment_tbl.count > 1 THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
                FND_MSG_PUB.ADD;
          END IF;
         RAISE FND_API.G_EXC_ERROR;
       ELSIF p_header_payment_tbl.count = 1 THEN
        IF p_header_payment_tbl(1).payment_option = 'SPLIT' THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
               FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

       END IF;-- p_hd_payment

    END IF;-- FND_PROFILE.Value
 --    Validate_Payment;(-- there should be only one rec if payment_option<>'SPLIT')
    IF (l_split_pay_prof = 'Y') THEN
       IF p_header_payment_tbl.count > 1 THEN
           FOR i IN 1..p_header_payment_tbl.count LOOP
            IF p_header_payment_tbl(i).payment_option <> 'SPLIT' THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_PAYMENTS');
                    FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
           END LOOP;
       END IF;
     END IF;

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('Create_Order: Before MAP_QUOTE_ORDER_INT.Map_Quote_to_Order : ', 1, 'N');
 END IF;
   ASO_MAP_QUOTE_ORDER_INT.Map_Quote_to_order(
    p_operation                   => 'CREATE'                      ,
    P_Qte_Rec                     => P_Qte_Rec                     ,
    P_Header_Payment_Tbl          => P_Header_Payment_Tbl          ,
    P_Header_Price_Adj_Tbl        => P_Header_Price_Adj_Tbl        ,
    P_Header_Price_Attributes_Tbl => P_Header_Price_Attributes_Tbl ,
    P_Header_Price_Adj_rltship_Tbl=> P_Header_Price_Adj_rltship_Tbl  ,
    P_Header_Price_Adj_Attr_Tbl   => P_Header_Price_Adj_Attr_Tbl  ,
    P_Header_Shipment_Tbl         => P_Header_Shipment_Tbl        ,
    P_Header_TAX_DETAIL_Tbl       => P_Header_TAX_DETAIL_Tbl      ,
    P_Header_FREIGHT_CHARGE_Tbl   => P_Header_FREIGHT_CHARGE_Tbl  ,
    P_header_sales_credit_TBL     => P_header_sales_credit_TBL    ,
    P_Qte_Line_Tbl                => P_Qte_Line_Tbl               ,
    P_Qte_Line_Dtl_Tbl            => P_Qte_Line_Dtl_Tbl           ,
    P_Line_Payment_Tbl            => P_Line_Payment_Tbl           ,
    P_Line_Price_Adj_Tbl          => P_Line_Price_Adj_Tbl         ,
    P_Line_Price_Attributes_Tbl   => P_Line_Price_Attributes_Tbl  ,
    P_Line_Price_Adj_rltship_Tbl  => P_Line_Price_Adj_rltship_Tbl ,
    P_Line_Price_Adj_Attr_Tbl     => P_Line_Price_Adj_Attr_Tbl    ,
    P_Line_Shipment_Tbl           => P_Line_Shipment_Tbl          ,
    P_Line_TAX_DETAIL_Tbl         => P_Line_TAX_DETAIL_Tbl        ,
    P_Line_FREIGHT_CHARGE_Tbl     => P_Line_FREIGHT_CHARGE_Tbl    ,
    P_Line_Rltship_Tbl            => P_Line_Rltship_Tbl           ,
    P_Line_sales_credit_TBL       => P_Line_sales_credit_TBL      ,
    P_Lot_serial_TBL              => P_Lot_serial_TBL             ,
    P_Calculate_Price_Flag        => P_Control_Rec.Calculate_Price,
    x_header_rec                  => l_header_rec                 ,
    x_header_val_rec              => l_header_val_rec             ,
    x_header_Adj_tbl              => l_header_Adj_tbl             ,
    x_header_Adj_val_tbl          => l_header_Adj_val_tbl         ,
    x_header_price_Att_tbl        => l_header_price_Att_tbl       ,
    x_header_Adj_Att_tbl          => l_header_Adj_Att_tbl         ,
    x_header_Adj_Assoc_tbl        => l_header_Adj_Assoc_tbl       ,
    x_header_Scredit_tbl          => l_header_Scredit_tbl         ,
    x_Header_Scredit_val_tbl      => l_Header_Scredit_val_tbl     ,
    x_Header_Payment_tbl          => l_Header_Payment_tbl         ,
    x_line_tbl                    => l_line_tbl                   ,
    x_line_val_tbl                => l_line_val_tbl               ,
    x_line_Adj_tbl                => l_line_Adj_tbl               ,
    x_line_Adj_val_tbl            => l_line_Adj_val_tbl           ,
    x_line_price_Att_tbl          => l_line_price_Att_tbl         ,
    x_line_Adj_Att_tbl            => l_line_Adj_Att_tbl           ,
    x_line_Adj_Assoc_tbl          => l_line_Adj_Assoc_tbl         ,
    x_line_Scredit_tbl            => l_line_Scredit_tbl           ,
    x_line_Scredit_val_tbl        => l_line_Scredit_val_tbl       ,
    x_lot_Serial_tbl              => l_lot_Serial_tbl             ,
    X_Lot_Serial_val_tbl          => l_Lot_Serial_val_tbl         ,
    x_Line_Payment_tbl            => l_Line_Payment_tbl
);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: After Map_Quote_to_Order: ', 1, 'N');
END IF;

-- set the control record flags
-- book order

  IF p_control_rec.book_flag =  FND_API.G_TRUE THEN
     l_request_tbl(i).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;
     l_request_tbl(i).request_type := OE_GLOBALS.G_BOOK_ORDER;
	i := i + 1;
  END IF;   -- booking

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: l_CC_Auth_Prof: '||l_CC_Auth_Prof, 1, 'N');
END IF;

  IF l_CC_Auth_Prof = 'Y' AND P_Control_Rec.CC_By_Fax <> FND_API.G_TRUE THEN

    FOR x IN 1..l_Header_Payment_tbl.count LOOP
      IF l_Header_Payment_tbl(x).Payment_Type_Code = 'CREDIT_CARD' AND l_Header_Payment_tbl(x).trxn_extension_id IS NOT NULL THEN
	    --l_cc_auth_failure_prof := NVL(FND_PROFILE.Value('ASO_CC_AUTH_FAILURE'), 'REJECT');
	    l_enable_risk_mgmt_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_CC_AUTH'), 'Y');

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Order: l_enable_risk_mgmt_prof: '||l_enable_risk_mgmt_prof, 1, 'N');
           END IF;

	      l_request_tbl(i).request_type := OE_GLOBALS.G_VERIFY_PAYMENT;
	      l_request_tbl(i).entity_code := OE_GLOBALS.G_ENTITY_HEADER;
	      --l_request_tbl(i).param2 := l_cc_auth_failure_prof;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Order: l_request_tbl(i).param2: '|| l_request_tbl(i).param2, 1, 'N');
           END IF;

	      IF l_enable_risk_mgmt_prof = 'Y' THEN
		   --l_risk_mgmt_failure_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_FAILURE'), 'REJECT');

	        l_request_tbl(i).param1 := 'Y';
	        --l_request_tbl(i).param3 := l_risk_mgmt_failure_prof;
	      ELSE
	        l_request_tbl(i).param1 := 'N';
	      END IF;
           i := i + 1;
       END IF; -- l_Header_Payment_tbl
     END LOOP; -- l_Header_Payment_tbl

    FOR x IN 1..l_Line_Payment_tbl.count LOOP
      IF l_Line_Payment_tbl(x).Payment_Type_Code = 'CREDIT_CARD' AND l_Line_Payment_tbl(x).trxn_extension_id IS NOT NULL THEN
         --l_cc_auth_failure_prof := NVL(FND_PROFILE.Value('ASO_CC_AUTH_FAILURE'), 'REJECT');
         l_enable_risk_mgmt_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_CC_AUTH'), 'Y');

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Order: l_enable_risk_mgmt_prof: '||l_enable_risk_mgmt_prof, 1, 'N');
           END IF;

           l_request_tbl(i).request_type := OE_GLOBALS.G_VERIFY_PAYMENT;
           l_request_tbl(i).entity_code := OE_GLOBALS.G_ENTITY_LINE;
           l_request_tbl(i).entity_index := l_Line_Payment_tbl(x).Line_Index;
           --l_request_tbl(i).param2 := l_cc_auth_failure_prof;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Order: l_request_tbl(i).param2: '||l_request_tbl(i).param2, 1, 'N');
           END IF;

           IF l_enable_risk_mgmt_prof = 'Y' THEN
             --l_risk_mgmt_failure_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_FAILURE'), 'REJECT');

             l_request_tbl(i).param1 := 'Y';
             --l_request_tbl(i).param3 := l_risk_mgmt_failure_prof;
           ELSE
             l_request_tbl(i).param1 := 'N';
           END IF;
           i := i + 1;
       END IF; -- l_Line_Payment_tbl
     END LOOP; -- l_Line_Payment_tbl

  END IF; -- l_CC_Auth_Prof

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: Before Proc_Order: ', 1, 'N');
aso_utility_pvt.print_login_info();
END IF;

-- added new debug messages
IF l_line_tbl.count > 0 then
  for i in 1..l_line_tbl.count loop
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').operation:           ' || l_line_tbl(i).operation, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').service_duration:    ' || l_line_tbl(i).service_duration, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').service_period:      ' || l_line_tbl(i).service_period, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').service_start_date:  ' || l_line_tbl(i).service_start_date, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').service_end_date:    ' || l_line_tbl(i).service_end_date, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').inventory_item_id:   ' || l_line_tbl(i).inventory_item_id, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').ordered_quantity:    ' || l_line_tbl(i).ordered_quantity, 1, 'N');
        aso_debug_pub.add('Create_Order: l_line_tbl('|| i ||').order_quantity_uom:  ' || l_line_tbl(i).order_quantity_uom, 1, 'N');
     END IF;
  end loop;
else
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('Create_Order: l_line_tbl count is 0 ', 1, 'N');
  END IF;
end if;

 --Bug 12800776 starts
 for I in 1 .. L_LINE_ADJ_TBL.COUNT
  LOOP
 aso_debug_pub.add('i value ' || I || 'l_line_adj_tbl.line_index ' || L_LINE_ADJ_TBL(I).LINE_INDEX || 'l_line_adj_tbl.list_line_type_code ' ||
 L_LINE_ADJ_TBL(I).LIST_LINE_TYPE_CODE ||'  L_LINE_ADJ_TBL(I).modifier_header_id' ||  L_LINE_ADJ_TBL(I).list_header_id);
 end loop;

  -- start bug 16980660

  assoc_tbl_index:=0;
 for adj_rltn_index in 1..P_Line_Price_Adj_rltship_Tbl.count loop
 assoc_tbl_index:=assoc_tbl_index+1;
   for oe_adj_index in 1..L_LINE_ADJ_TBL.count loop
     if P_Line_Price_Adj_rltship_Tbl(adj_rltn_index).price_adjustment_id = L_LINE_ADJ_TBL(oe_adj_index).price_adjustment_id THEN
        l_line_adj_assoc_tbl(assoc_tbl_index).adj_index:=oe_adj_index;
        l_line_adj_assoc_tbl(assoc_tbl_index).price_adjustment_id:=FND_API.G_MISS_NUM;

     end if;
     if P_Line_Price_Adj_rltship_Tbl(adj_rltn_index).rltd_price_adj_id = L_LINE_ADJ_TBL(oe_adj_index).price_adjustment_id THEN
        l_line_adj_assoc_tbl(assoc_tbl_index).rltd_adj_index:=oe_adj_index;
        l_line_adj_assoc_tbl(assoc_tbl_index).RLTD_price_adj_id:=FND_API.G_MISS_NUM;

     end if;
   end loop;
 end loop;

  for I in 1 .. L_LINE_ADJ_TBL.COUNT
  LOOP
   L_LINE_ADJ_TBL(i).price_adjustment_id := FND_API.G_MISS_NUM;
  end loop;

 /*for line_index in 1..l_line_adj_tbl.count loop
    if l_line_adj_tbl(line_index).list_line_type_code in ('PBH','PRG','OID') then
          l_line_adj_assoc_tbl(assoc_tbl_index).adj_index:=line_index;
	  prev_adj_index:=line_index;
      mod_head_id := l_line_adj_tbl(line_index).list_header_id;
       aso_debug_pub.add('Entered in PBH  l_line_adj_assoc_tbl(assoc_tbl_index).adj_index' ||  L_LINE_ADJ_ASSOC_TBL(ASSOC_TBL_INDEX).ADJ_INDEX);
     elsif l_line_adj_tbl(line_index).list_line_type_code  = 'DIS'  and l_line_adj_tbl(line_index).list_header_id =  mod_head_id then
           l_line_adj_assoc_tbl(assoc_tbl_index).adj_index:=prev_adj_index;
           l_line_adj_assoc_tbl(assoc_tbl_index).rltd_adj_index:=line_index;
	   aso_debug_pub.add('Entered in Dis l_line_adj_assoc_tbl(assoc_tbl_index).adj_index, rltd_adj_index ' || l_line_adj_assoc_tbl(assoc_tbl_index).adj_index || l_line_adj_assoc_tbl(assoc_tbl_index).rltd_adj_index);
           assoc_tbl_index:=assoc_tbl_index+1;
       END IF;
  end loop;
  */
  -- end bug 16980660

  FOR i IN 1 .. l_line_adj_assoc_tbl.count
  LOOP

     aso_debug_pub.add('bug 16980660 after mapping  i value ' || i || 'l_line_adj_assoc_tbl(i).Adj_index: ' || l_line_adj_assoc_tbl(i).adj_index
    || 'l_line_adj_assoc_tbl(I).Rltd_Adj_index ' || l_line_adj_assoc_tbl(i).rltd_adj_index );
  END LOOP;

--Bug 12800776 ends

--End P1 Bug 12918022

-- bug# 1927450
OE_STANDARD_WF.SAVE_MESSAGES_OFF;
--Bug11671808

P:=FND_GLOBAL.APPLICATION_SHORT_NAME;

/*** Start : Code change done for Bug 14358079 ***/

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order , Product : ' || P ,1,'N');
   aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order , P_Qte_Rec.QUOTE_HEADER_ID : '||P_Qte_Rec.QUOTE_HEADER_ID ,1,'N');
   aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order , P_Qte_Rec.QUOTE_STATUS_ID : '||P_Qte_Rec.QUOTE_STATUS_ID ,1,'N');
End If;

If UPPER(P) IN ('QOT','ASO','ASF','ASL','AST','ASN','ONT') THEN

   BEGIN
        Open C_LOCK(P_Qte_Rec.QUOTE_HEADER_ID,P_Qte_Rec.QUOTE_STATUS_ID);
        Fetch C_LOCK Into L_QUOTE_HEADER_ID, L_QUOTE_STATUS_ID;

	If aso_debug_pub.g_debug_flag = 'Y' Then
	   aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order , L_QUOTE_HEADER_ID : '||L_QUOTE_HEADER_ID ,1,'N');
           aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order , L_QUOTE_STATUS_ID : '||L_QUOTE_STATUS_ID ,1,'N');
        End If;

        If C_LOCK%NOTFOUND Then
	   If aso_debug_pub.g_debug_flag = 'Y' Then
	      aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order , Cursor C_LOCK NOT FOUND ' ,1,'N');
	   End If;
        End if;

        Close C_LOCK;

   EXCEPTION

     WHEN OTHERS THEN

	  If aso_debug_pub.g_debug_flag = 'Y' Then
	     aso_debug_pub.add('Create_Order:  When Others exception occures , ASO_API_QUOTE_ORDER_PROGRESS ');
	     aso_debug_pub.add('SQLCODE : '|| SQLCODE, 1, 'N');
	     aso_debug_pub.add('SQLERRM : '|| SQLERRM, 1, 'N');
          End If;

          If FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) Then
	     FND_MESSAGE.SET_NAME('ASO', 'ASO_API_QUOTE_ORDER_PROGRESS');
             FND_MSG_PUB.ADD;
	  END If;
          RAISE FND_API.G_EXC_ERROR;
   END;

   /*** End : Code change done for Bug 14358079 ***/

/* BEGIN
 SELECT QUOTE_HEADER_ID, QUOTE_STATUS_ID
    INTO L_QUOTE_HEADER_ID, L_QUOTE_STATUS_ID
    FROM ASO_QUOTE_HEADERS_ALL
  WHERE QUOTE_HEADER_ID = P_Qte_Rec.QUOTE_HEADER_ID
  and  QUOTE_STATUS_ID =  P_Qte_Rec.QUOTE_STATUS_ID
  FOR UPDATE OF QUOTE_STATUS_ID NOWAIT;

    IF SQL%NOTFOUND THEN
    aso_debug_pub.add('sql % not found Create_OrderSQL%NOTFOUND ASO_API_QUOTE_ORDER_PROGRESS ');
       FND_MESSAGE.Set_Name('ASO', 'ASO_API_QUOTE_ORDER_PROGRESS');
          FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  End if;
EXCEPTION
    WHEN OTHERS THEN
        aso_debug_pub.add('when others sql % not found Create_OrderSQL%NOTFOUND ASO_API_QUOTE_ORDER_PROGRESS ');
       FND_MESSAGE.SET_NAME('ASO', 'ASO_API_QUOTE_ORDER_PROGRESS');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
 END; */

End If;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Create_Order: Before ASO_QUOTE_CUHK.CREATE_ORDER_PRE ',1,'N');
END IF;

 IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN

    ASO_QUOTE_CUHK.CREATE_ORDER_PRE (
    P_Control_Rec	,
    l_header_rec     ,
    l_line_tbl       ,
    X_Return_Status  ,
    X_Msg_Count      ,
    X_Msg_Data       );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		       FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		       FND_MESSAGE.Set_Token('API', 'ASO_QUOTE_CUHK.CREATE_ORDER_PRE', FALSE);
		       FND_MSG_PUB.ADD;
             END IF;

             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
        END IF;
END IF; -- customer hook

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order',1,'N');
END IF;

/*oe_debug_pub.initialize;
oe_debug_pub.debug_on;
oe_debug_pub.setdebuglevel(5);
dbg_file := oe_debug_pub.set_debug_mode('FILE');
oe_debug_pub.add(  '12767703 Starts');*/

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Create_Order: Before OE_Order_GRP.Process_Order p_qte_rec.quote_header_id :' || p_qte_rec.quote_header_id,1,'N');
  END IF;

FOR I IN 1.. p_qte_line_tbl.COUNT LOOP
  IF p_qte_line_tbl(I).item_type_code = 'MDL' OR  p_qte_line_tbl(I).item_type_code = 'ATO' THEN

    IF aso_debug_pub.g_debug_flag     = 'Y' THEN
       aso_debug_pub.add('Model item query line L_LINE_TBL(I).QUOTE_LINE_ID: ' ||p_qte_line_tbl(I).QUOTE_LINE_ID );
       aso_debug_pub.add('Model item query line L_LINE_TBL(I).item_type_code: ' ||p_qte_line_tbl(I).item_type_code );

    End if;

    l_qte_line_dtl_tbl := aso_utility_pvt.Query_Line_Dtl_Rows( p_qte_line_tbl(I).QUOTE_LINE_ID);

    IF aso_debug_pub.g_debug_flag     = 'Y' THEN

      aso_debug_pub.add('model item query line details line l_qte_line_dtl_tbl(1).QUOTE_LINE_ID: ' || l_qte_line_dtl_tbl(1).QUOTE_LINE_ID );
      aso_debug_pub.add('Model item query line details line l_qte_line_dtl_tbl(1).config_header_id: ' ||l_qte_line_dtl_tbl(1).config_header_id );
      aso_debug_pub.add('Model item query line details line l_qte_line_dtl_tbl(1).config_revision_num : ' || l_qte_line_dtl_tbl(1).config_revision_num );
      aso_debug_pub.add('Model item query line details line l_qte_line_dtl_tbl(1).top_model_line_id :' ||l_qte_line_dtl_tbl(1).top_model_line_id);


    END IF;


--  Bug 22985990
-- CZ DEV suggested to used this api in autonomous transaction and commit
--    CZ_CF_API.Copy_Configuration
--        (config_hdr_id => l_qte_line_dtl_tbl(1).config_header_id ,
--          config_rev_nbr => l_qte_line_dtl_tbl(1).config_revision_num ,
--          new_config_flag => 1,
--          out_config_hdr_id => l_config_hdr_id ,
--          out_config_rev_nbr => l_config_rev_nbr ,
--          Error_message => l_error_message ,
--          Return_value => l_return_value );

Copy_Configuration
	     (p_config_hdr_id => l_qte_line_dtl_tbl(1).config_header_id ,
          p_config_rev_nbr => l_qte_line_dtl_tbl(1).config_revision_num ,
          x_config_hdr_id => l_config_hdr_id ,
          x_config_rev_nbr => l_config_rev_nbr ,
          x_error_message => l_error_message ,
          x_return_value => l_return_value );

    IF l_return_value = 1 THEN

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Return success from CZ_CF_API.Copy_Configuration api before assigning model l_config_hdr_id ' || l_config_hdr_id);
          aso_debug_pub.add('Return success from CZ_CF_API.Copy_Configuration api before assigning model l_config_rev_nbr ' || l_config_rev_nbr);

        END IF;

        l_line_tbl(j).config_header_id := l_config_hdr_id;
        l_line_tbl(j).config_rev_nbr   := l_config_rev_nbr;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Return success from CZ_CF_API.Copy_Configuration api for MDL item and after assigning model l_line_tbl(i).config_header_id: ' || l_line_tbl(j).config_header_id);
          aso_debug_pub.add('Return success from CZ_CF_API.Copy_Configuration api for MDL item and after assigning model l_line_tbl(i).config_rev_nbr: ' || l_line_tbl(j).config_rev_nbr);
        END IF;

    ELSE

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Return failure from CZ_CF_API.Copy_Configuration api ');
        END IF;
		  l_len_sqlerrm := Length(l_error_message) ;
		  WHILE l_len_sqlerrm >= k LOOP
            FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
            FND_MESSAGE.Set_token('MSG_TXT' , substr(l_error_message,i,240));
		          k := k + 240;
             FND_MSG_PUB.ADD;
         END LOOP;
            x_return_status := FND_API.G_RET_STS_ERROR;
           raise FND_API.G_EXC_ERROR;

  END IF;
   END IF;

  IF p_qte_line_tbl(I).item_type_code = 'CFG'   THEN


    l_line_tbl(j).config_header_id := l_config_hdr_id;
    l_line_tbl(j).config_rev_nbr   := l_config_rev_nbr;


    IF aso_debug_pub.g_debug_flag   = 'Y' THEN
      aso_debug_pub.add('CFG item after assigning l_line_tbl(i).config_header_id: ' ||l_line_tbl(j).config_header_id );
      aso_debug_pub.add('CFG item after assigning l_line_tbl(i).config_rev_nbr: ' ||l_line_tbl(j).config_rev_nbr );

    END IF;
  END IF;
  j := j + 1;
END LOOP;

    IF aso_debug_pub.g_debug_flag   = 'Y' THEN
      FOR i IN 1..l_line_tbl.count LOOP
        IF l_line_tbl(i).config_header_id IS NOT NULL Then
            aso_debug_pub.add('Before call OE_Order_GRP.Process_Order API - l_line_tbl value CONFIG_ITEM_ID:( ' ||i|| ')'||l_line_tbl(i).configuration_id);
            aso_debug_pub.add('Before call OE_Order_GRP.Process_Order API - l_line_tbl value config_header_id:( ' ||i|| ')' ||l_line_tbl(i).config_header_id );
            aso_debug_pub.add('Before call OE_Order_GRP.Process_Order API - l_line_tbl value config_rev_nbr:( ' ||i|| ')' ||l_line_tbl(i).config_rev_nbr );
        End if;
      End loop;
    END IF;

OE_Order_GRP.Process_Order
(   p_api_version_number        => 1.0
,   p_init_msg_list             => FND_API.G_TRUE
,   p_return_values             => l_return_values
,   p_commit                    => FND_API.G_FALSE
,   x_return_status             => x_return_status
,   x_msg_count                 => x_msg_count
,   x_msg_data                  =>  x_msg_data
,   p_header_rec                => l_header_rec
,   p_Header_Adj_tbl            => l_header_adj_tbl
,   p_Header_price_Att_tbl      => l_header_price_att_tbl
,   p_Header_Adj_Att_tbl        => l_header_adj_att_tbl
,   p_Header_Adj_Assoc_tbl      => l_header_adj_assoc_tbl
,   p_Header_Scredit_tbl        => l_header_scredit_tbl
,   p_Header_Payment_tbl        => l_header_payment_tbl
,   p_line_tbl                  => l_line_tbl
,   p_Line_Adj_tbl              => l_line_adj_tbl
,   p_Line_price_Att_tbl        => l_line_price_att_tbl
,   p_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl
,   p_Line_Adj_Assoc_tbl        => l_line_adj_assoc_tbl
,   p_Line_Scredit_tbl          => l_line_scredit_tbl
,   p_Lot_Serial_tbl            => l_lot_serial_tbl
,   p_Line_Payment_tbl          => l_line_payment_tbl
,   p_Action_Request_tbl        => l_request_tbl
,   x_header_rec                => lx_header_rec
,   x_header_val_rec            => l_header_val_rec
,   x_Header_Adj_tbl            => lx_header_adj_tbl
,   x_Header_Adj_val_tbl        => l_header_adj_val_tbl
,   x_Header_price_Att_tbl      => lx_header_price_att_tbl
,   x_Header_Adj_Att_tbl        => lx_header_adj_att_tbl
,   x_Header_Adj_Assoc_tbl      => lx_header_adj_assoc_tbl
,   x_Header_Scredit_tbl        => lx_header_scredit_tbl
,   x_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
,   x_Header_Payment_tbl        => lx_header_payment_tbl
,   x_Header_Payment_val_tbl    => l_header_payment_val_tbl
,   x_line_tbl                  => lx_line_tbl
,   x_line_val_tbl              => l_line_val_tbl
,   x_Line_Adj_tbl              => lx_line_adj_tbl
,   x_Line_Adj_val_tbl          => l_line_adj_val_tbl
,   x_Line_price_Att_tbl        => lx_line_price_att_tbl
,   x_Line_Adj_Att_tbl          => lx_line_adj_att_tbl
,   x_Line_Adj_Assoc_tbl        => lx_line_adj_assoc_tbl
,   x_Line_Scredit_tbl          => lx_line_scredit_tbl
,   x_Line_Scredit_val_tbl      => l_line_scredit_val_tbl
,   x_Lot_Serial_tbl            => lx_lot_serial_tbl
,   x_Lot_Serial_val_tbl        => l_lot_serial_val_tbl
,   x_Line_Payment_tbl          => lx_line_payment_tbl
,   x_Line_Payment_val_tbl      => l_line_payment_val_tbl
,   x_action_request_tbl        => l_action_request_tbl
);

-- hyang: bug 2692785
  l_header_rec := lx_header_rec;
  l_Header_Adj_tbl := lx_Header_Adj_tbl;
  l_Header_price_Att_tbl := lx_Header_price_Att_tbl;
  l_Header_Adj_Att_tbl := lx_Header_Adj_Att_tbl;
  l_Header_Adj_Assoc_tbl := lx_Header_Adj_Assoc_tbl;
  l_Header_Scredit_tbl := lx_Header_Scredit_tbl;
  l_line_tbl := lx_line_tbl;
  l_Line_Adj_tbl := lx_Line_Adj_tbl;
  l_Line_price_Att_tbl := lx_Line_price_Att_tbl;
  l_Line_Adj_Att_tbl := lx_Line_Adj_Att_tbl;
  l_Line_Adj_Assoc_tbl := lx_Line_Adj_Assoc_tbl;
  l_Line_Scredit_tbl := lx_Line_Scredit_tbl;
  l_Lot_Serial_tbl := lx_Lot_Serial_tbl;

 oe_debug_pub.add( '12767703 Ends');

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: After Proc_Order: x_return_status: '||x_return_status, 1, 'N');
aso_utility_pvt.print_login_info();
END IF;

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
 --Bug 22985990
 If (l_config_hdr_id is not null) and (l_config_rev_nbr is not null) then
  ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER => 1.0,
                                                        P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                        P_CONFIG_HDR_ID       => l_config_hdr_id,
                                                        P_CONFIG_REV_NBR      => l_config_rev_nbr,
                                                        X_RETURN_STATUS       => lx_return_status,
                                                        X_MSG_COUNT           => x_msg_count,
                                                        X_MSG_DATA            => x_msg_data);

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Create_Order:After call to ASO_CFG_INT.DELETE_CONFIGURATION: x_Return_Status: ' || lx_Return_Status);
                 END IF;

                 IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                    x_return_status := lx_return_status;
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                       FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                       FND_MSG_PUB.ADD;
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

			 End if;
		 -- END IF;

       --Bug 22985990
--        retrieve_oe_messages;
     IF x_msg_count > 0 THEN
         	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR_MSG');
		  FND_MSG_PUB.ADD;
	 	END IF;
     END IF;

     retrieve_oe_messages;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

 END IF;

 --bug 25308441 added condition AND l_header_rec.order_number is NUll

IF  (x_return_status = FND_API.G_RET_STS_SUCCESS AND
     p_control_rec.book_flag =  FND_API.G_TRUE AND
     l_action_request_tbl(1).return_status <> FND_API.G_RET_STS_SUCCESS AND l_header_rec.order_number is NUll)
	THEN
       if x_msg_count > 0 then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR_MSG');
		  FND_MSG_PUB.ADD;
	 END IF;
     end if;
       retrieve_oe_messages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
END IF;

retrieve_oe_messages;

-- return the header values
   x_order_header_rec.order_number := l_header_rec.order_number;
   x_order_header_rec.order_header_id    := l_header_rec.header_id;
   x_order_header_rec.status       := l_header_rec.return_status;
   x_order_header_rec.quote_header_id := l_header_rec.source_document_id;

-- return line values
   FOR i in 1..l_line_tbl.count LOOP
       x_order_line_tbl(i).order_line_id := l_line_tbl(i).line_id;
       x_order_line_tbl(i).order_header_id := l_line_tbl(i).header_id;
       x_order_line_tbl(i).quote_shipment_line_id := l_line_tbl(i).source_document_line_id;
       x_order_line_tbl(i).status   := l_line_tbl(i).return_status;
    END LOOP;

-- map fulfillment

-- check if the order can be satisfied by fulfillment alone. If yes, then call
-- to OM can be avoided.
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: Before fulfilment: ', 1, 'N');
END IF;
 IF p_control_rec.INTERFACE_FFM_FLAG = FND_API.G_TRUE
          AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    p_ffm_request_rec.party_id  := p_qte_rec.party_id;
    p_ffm_request_rec.user_id  := FND_GLOBAL.USER_ID;
    p_ffm_request_rec.server_id := p_control_rec.server_id;


   Map_quote_to_fulfillment(
    p_qte_line_tbl         =>   p_qte_line_tbl,
    p_line_attribs_ext_tbl =>   p_line_attribs_ext_tbl,
--    p_fulfillment_tbl      =>   fulfillment,
    x_ffm_content_tbl      =>   l_ffm_content_tbl,
    x_ffm_bind_tbl         =>   l_ffm_bind_tbl
   );

   IF l_ffm_content_tbl.count > 0 THEN

   ASO_FFM_INT.Submit_FFM_Request(
    P_Api_Version_Number        =>  1.0 ,
    p_Init_Msg_List             =>  p_init_msg_list  ,
    p_Commit                    =>  FND_API.G_FALSE  ,
    p_validation_Level          =>  FND_API.G_VALID_LEVEL_FULL,
    p_ffm_request_rec           =>  p_ffm_request_rec,
    p_ffm_content_tbl           =>  l_ffm_content_tbl,
    p_bind_tbl                  =>  l_ffm_bind_tbl     ,
    X_Request_ID                =>  x_request_id   ,
    X_Return_Status             =>  x_return_status,
    X_Msg_Count                 =>  x_msg_count    ,
    X_Msg_Data                  =>  x_msg_data );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: After submit_ffm_request x_return_status: '||x_return_status, 1, 'N');
END IF;
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --retrieve_oe_messages;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

 END IF;


      --
      -- End of API body
      --
     -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                null;
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                null;
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
                null;
		   IF SQLCODE = -54 THEN

                   --FND_MSG_PUB.initialize;
                     FND_MESSAGE.SET_NAME('ASO', 'ASO_API_QUOTE_ORDER_PROGRESS');
                     FND_MSG_PUB.ADD;
                       RAISE FND_API.G_EXC_ERROR;
                   --  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
                  END IF;

                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Order;



PROCEDURE Update_order(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			 := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl    IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
		        := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Header_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Header_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_header_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			:= ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl   IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			:= ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl        IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type  			 := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_ATTRIBS_EXT_Tbl  IN  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
			  := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
   P_Line_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
			 := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Line_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Lot_Serial_Tbl        IN   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type
                             := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl,
    P_Control_Rec                IN Control_Rec_Type := G_MISS_Control_Rec,
    X_Order_Header_Rec           OUT NOCOPY /* file.sql.39 change */   Order_Header_Rec_Type,
    X_Order_Line_Tbl             OUT NOCOPY /* file.sql.39 change */   Order_Line_Tbl_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
-- this should be changed post 11.5.1
   CURSOR C_cancel_reason IS
      SELECT lookup_code
      from oe_lookups
      WHERE lookup_type = 'CANCEL_CODE'
      AND lookup_code = 'Not provided';


l_line_shipment_tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Update_Order';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
l_Header_Payment_val_tbl      OE_Order_PUB.Header_Payment_Val_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
l_Line_Payment_val_tbl        OE_Order_PUB.Line_Payment_Val_Tbl_Type;
l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_request_tbl                 OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL;

l_return_values               varchar2(50);
l_header_val_rec              OE_Order_PUB.Header_Val_Rec_Type;
l_old_header_val_rec          OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_old_header_adj_val_tbl      OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_old_header_scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_val_tbl                OE_Order_PUB.Line_Val_Tbl_Type;
l_old_line_val_tbl            OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_old_line_adj_val_tbl        OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_old_line_scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_old_lot_serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type;

  -- hyang: bug 2692785
  lx_header_rec                  OE_Order_PUB.Header_Rec_Type;
  lx_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
  lx_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
  lx_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
  lx_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
  lx_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
  lx_Header_Payment_tbl          OE_Order_PUB.Header_Payment_Tbl_Type;
  lx_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
  lx_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
  lx_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
  lx_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
  lx_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
  lx_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
  lx_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
  lx_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
  lx_request_tbl                 OE_Order_PUB.Request_Tbl_Type;

   l_split_pay_prof             VARCHAR2(2) := FND_PROFILE.Value('ASO_ENABLE_SPLIT_PAYMENT');
   l_CC_Auth_Prof               VARCHAR2(2) := FND_PROFILE.Value('ASO_CC_AUTHORIZATION_ENABLED');
   l_Enable_Risk_Mgmt_Prof      VARCHAR2(2);
   l_CC_Auth_Failure_Prof       VARCHAR2(20);
   l_Risk_Mgmt_Failure_Prof     VARCHAR2(20);

   i                            NUMBER := 1;
BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT UPDATE_order_PVT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version ,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


-- change the org to whatever is stored in the org id column
       IF p_qte_rec.org_id is not NULL
          AND p_qte_rec.org_id <> FND_API.G_MISS_NUM THEN

	/* fnd_client_info.set_org_context(p_qte_rec.org_id); */  --Commented Code Yogeshwar (MOAC)
	 MO_GLOBAL.set_policy_context ('S', p_qte_rec.org_id)  ;   --New Code Yogeshwar (MOAC)

       END IF;

       IF p_qte_rec.order_id is null OR
         p_qte_rec.order_id = FND_API.G_MISS_NUM THEN

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
		 FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
		 FND_MESSAGE.Set_Token('COLUMN', 'ORDER_ID', FALSE);
           FND_MSG_PUB.ADD;
         END IF;
         raise FND_API.G_EXC_ERROR;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_split_pay_prof: '||l_split_pay_prof,1,'N');
END IF;

    IF (l_split_pay_prof = 'N') THEN
         IF p_header_payment_tbl.count > 1 THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
               FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF p_header_payment_tbl.count = 1 THEN
           IF p_header_payment_tbl(1).payment_option = 'SPLIT' THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_SPLIT_PAYMENT');
                    FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

       END IF;-- p_hd_payment

   END IF;-- FND_PROFILE.Value
  IF (l_split_pay_prof = 'Y') THEN
       IF p_header_payment_tbl.count > 1 THEN
        FOR i IN 1..p_header_payment_tbl.count LOOP
           IF p_header_payment_tbl(i).payment_option <> 'SPLIT' THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_PAYMENTS');
                    FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
       END IF;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before ASO_MAP_QUOTE_ORDER_INT.Map_Quote_Order_Int: ',1,'N');
aso_debug_pub.add('before ASO_MAP_QUOTE_ORDER_INT.Map_Quote_Order_Int: P_Calculate_Price_Flag '||P_Control_Rec.Calculate_Price,1,'N');
END IF;

   ASO_MAP_QUOTE_ORDER_INT.Map_Quote_to_order(
    p_operation                   => 'UPDATE'                      ,
    P_Qte_Rec                     => P_Qte_Rec                     ,
    P_Header_Payment_Tbl          => P_Header_Payment_Tbl          ,
    P_Header_Price_Adj_Tbl        => P_Header_Price_Adj_Tbl        ,
    P_Header_Price_Attributes_Tbl => P_Header_Price_Attributes_Tbl ,
    P_Header_Price_Adj_rltship_Tbl=> P_Header_Price_Adj_rltship_Tbl  ,
    P_Header_Price_Adj_Attr_Tbl   => P_Header_Price_Adj_Attr_Tbl  ,
    P_Header_Shipment_Tbl         => P_Header_Shipment_Tbl        ,
    P_Header_TAX_DETAIL_Tbl       => P_Header_TAX_DETAIL_Tbl      ,
    P_Header_FREIGHT_CHARGE_Tbl   => P_Header_FREIGHT_CHARGE_Tbl  ,
    P_header_sales_credit_TBL     => P_header_sales_credit_TBL    ,
    P_Qte_Line_Tbl                => P_Qte_Line_Tbl               ,
    P_Qte_Line_Dtl_Tbl            => P_Qte_Line_Dtl_Tbl           ,
    P_Line_Payment_Tbl            => P_Line_Payment_Tbl           ,
    P_Line_Price_Adj_Tbl          => P_Line_Price_Adj_Tbl         ,
    P_Line_Price_Attributes_Tbl   => P_Line_Price_Attributes_Tbl  ,
    P_Line_Price_Adj_rltship_Tbl  => P_Line_Price_Adj_rltship_Tbl ,
    P_Line_Price_Adj_Attr_Tbl     => P_Line_Price_Adj_Attr_Tbl    ,
    P_Line_Shipment_Tbl           => P_Line_Shipment_Tbl          ,
    P_Line_TAX_DETAIL_Tbl         => P_Line_TAX_DETAIL_Tbl        ,
    P_Line_FREIGHT_CHARGE_Tbl     => P_Line_FREIGHT_CHARGE_Tbl    ,
    P_Line_Rltship_Tbl            => P_Line_Rltship_Tbl           ,
    P_Line_sales_credit_TBL       => P_Line_sales_credit_TBL      ,
    P_Lot_serial_TBL              => P_Lot_serial_TBL             ,
     P_Calculate_Price_Flag        => P_Control_Rec.Calculate_Price,  -- bug 13010966
    x_header_rec                  => l_header_rec                 ,
    x_header_val_rec              => l_header_val_rec             ,
    x_header_Adj_tbl              => l_header_Adj_tbl             ,
    x_header_Adj_val_tbl          => l_header_Adj_val_tbl         ,
    x_header_price_Att_tbl        => l_header_price_Att_tbl       ,
    x_header_Adj_Att_tbl          => l_header_Adj_Att_tbl         ,
    x_header_Adj_Assoc_tbl        => l_header_Adj_Assoc_tbl       ,
    x_header_Scredit_tbl          => l_header_Scredit_tbl         ,
    x_Header_Scredit_val_tbl      => l_Header_Scredit_val_tbl     ,
    x_Header_Payment_tbl          => l_Header_Payment_tbl         ,
    x_line_tbl                    => l_line_tbl                   ,
    x_line_val_tbl                => l_line_val_tbl               ,
    x_line_Adj_tbl                => l_line_Adj_tbl               ,
    x_line_Adj_val_tbl            => l_line_Adj_val_tbl           ,
    x_line_price_Att_tbl          => l_line_price_Att_tbl         ,
    x_line_Adj_Att_tbl            => l_line_Adj_Att_tbl           ,
    x_line_Adj_Assoc_tbl          => l_line_Adj_Assoc_tbl         ,
    x_line_Scredit_tbl            => l_line_Scredit_tbl           ,
    x_line_Scredit_val_tbl        => l_line_Scredit_val_tbl       ,
    x_lot_Serial_tbl              => l_lot_Serial_tbl             ,
    X_Lot_Serial_val_tbl          => l_Lot_Serial_val_tbl         ,
    x_Line_Payment_tbl            => l_Line_Payment_tbl
);

 l_header_rec.operation := OE_Globals.G_OPR_UPDATE;

-- set the control record flags
-- book order

  IF p_control_rec.book_flag =  FND_API.G_TRUE THEN
     l_request_tbl(i).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;
     l_request_tbl(i).request_type := OE_GLOBALS.G_BOOK_ORDER;
     i := i + 1;
  END IF;   -- booking

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Create_Order: l_CC_Auth_Prof: '||l_CC_Auth_Prof, 1, 'N');
END IF;

  IF l_CC_Auth_Prof = 'Y' AND P_Control_Rec.CC_By_Fax <> FND_API.G_TRUE THEN

    FOR x IN 1..l_Header_Payment_tbl.count LOOP
      IF l_Header_Payment_tbl(x).Payment_Type_Code = 'CREDIT_CARD' AND l_Header_Payment_tbl(x).trxn_extension_id IS NOT NULL THEN
         --l_cc_auth_failure_prof := NVL(FND_PROFILE.Value('ASO_CC_AUTH_FAILURE'), 'REJECT');
         l_enable_risk_mgmt_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_CC_AUTH'), 'Y');

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Create_Order: l_enable_risk_mgmt_prof: '||l_enable_risk_mgmt_prof, 1, 'N');
          END IF;

           l_request_tbl(i).request_type := OE_GLOBALS.G_VERIFY_PAYMENT;
           l_request_tbl(i).entity_code := OE_GLOBALS.G_ENTITY_HEADER;
           --l_request_tbl(i).param2 := l_cc_auth_failure_prof;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Create_Order: l_request_tbl(i).param2: '|| l_request_tbl(i).param2, 1, 'N');
          END IF;

           IF l_enable_risk_mgmt_prof = 'Y' THEN
             --l_risk_mgmt_failure_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_FAILURE'), 'REJECT');
             l_request_tbl(i).param1 := 'Y';
             --l_request_tbl(i).param3 := l_risk_mgmt_failure_prof;
           ELSE
             l_request_tbl(i).param1 := 'N';
           END IF;
           i := i + 1;
       END IF; -- l_Header_Payment_tbl
     END LOOP; -- l_Header_Payment_tbl

    FOR x IN 1..l_Line_Payment_tbl.count LOOP
      IF l_Line_Payment_tbl(x).Payment_Type_Code = 'CREDIT_CARD' AND l_Line_Payment_tbl(x).trxn_extension_id IS NOT NULL THEN
         --l_cc_auth_failure_prof := NVL(FND_PROFILE.Value('ASO_CC_AUTH_FAILURE'), 'REJECT');
         l_enable_risk_mgmt_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_CC_AUTH'), 'Y');

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Order: l_enable_risk_mgmt_prof: '||l_enable_risk_mgmt_prof, 1, 'N');
           END IF;

           l_request_tbl(i).request_type := OE_GLOBALS.G_VERIFY_PAYMENT;
           l_request_tbl(i).entity_code := OE_GLOBALS.G_ENTITY_LINE;
           l_request_tbl(i).entity_index := l_Line_Payment_tbl(x).Line_Index;
           --l_request_tbl(i).param2 := l_cc_auth_failure_prof;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Order: l_request_tbl(i).param2: '|| l_request_tbl(i).param2, 1, 'N');
           END IF;

           IF l_enable_risk_mgmt_prof = 'Y' THEN
             --l_risk_mgmt_failure_prof := NVL(FND_PROFILE.Value('ASO_RISK_MANAGE_FAILURE'), 'REJECT');
             l_request_tbl(i).param1 := 'Y';
             --l_request_tbl(i).param3 := l_risk_mgmt_failure_prof;
           ELSE
             l_request_tbl(i).param1 := 'N';
           END IF;
           i := i + 1;
       END IF; -- l_Line_Payment_tbl
     END LOOP; -- l_Line_Payment_tbl

  END IF; -- l_CC_Auth_Prof

-- cancel code - this should be changed
FOR i in 1..l_line_tbl.count LOOP
   IF l_line_tbl(i).ordered_quantity is not NULL
      OR l_line_tbl(i).ordered_quantity <> FND_API.G_MISS_NUM THEN

       OPEN C_cancel_reason;
       FETCH C_cancel_reason into l_line_tbl(i).change_reason;
       CLOSE C_cancel_reason;

   END IF;
END LOOP;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Update_Order: Before Process_order',1,'Y');
aso_utility_pvt.print_login_info();
END IF;

-- bug# 1927450
OE_STANDARD_WF.SAVE_MESSAGES_OFF;

OE_Order_GRP.Process_Order
(   p_api_version_number       =>  l_api_version_number
,   p_init_msg_list            =>  FND_API.G_TRUE
,   p_return_values             => l_return_values
,   p_commit                    => p_commit
,   x_return_status             => x_return_status
,   x_msg_count                 => x_msg_count
,   x_msg_data                  => x_msg_data
,   p_header_rec                => l_header_rec
--,   p_header_val_rec          => l_header_val_rec
,   p_Header_Adj_tbl            => l_header_adj_tbl
--,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
,   p_Header_price_Att_tbl      => l_header_price_att_tbl
,   p_Header_Adj_Att_tbl        => l_header_adj_att_tbl
,   p_Header_Adj_Assoc_tbl      => l_header_adj_assoc_tbl
,   p_Header_Scredit_tbl        => l_header_scredit_tbl
--,   p_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
,   p_Header_Payment_tbl        => l_header_payment_tbl
,   p_line_tbl                  => l_line_tbl
--,   p_line_val_tbl            => l_line_val_tbl
,   p_Line_Adj_tbl              => l_line_adj_tbl
--,   p_Line_Adj_val_tbl                => l_line_adj_val_tbl
,   p_Line_price_Att_tbl        => l_line_price_att_tbl
,   p_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl
,   p_Line_Adj_Assoc_tbl        => l_line_adj_assoc_tbl
,   p_Line_Scredit_tbl          => l_line_scredit_tbl
--,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
,   p_Lot_Serial_tbl            => l_lot_serial_tbl
--,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
,   p_Line_Payment_tbl          => l_line_payment_tbl
,   P_Action_Request_tbl        => l_request_tbl
,   x_header_rec                => lx_header_rec
,   x_header_val_rec            => l_header_val_rec
,   x_Header_Adj_tbl            => lx_header_adj_tbl
,   x_Header_Adj_val_tbl        => l_header_adj_val_tbl
,   x_Header_price_Att_tbl      => lx_header_price_att_tbl
,   x_Header_Adj_Att_tbl        => lx_header_adj_att_tbl
,   x_Header_Adj_Assoc_tbl      => lx_header_adj_assoc_tbl
,   x_Header_Scredit_tbl        => lx_header_scredit_tbl
,   x_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
,   x_Header_Payment_tbl        => lx_header_payment_tbl
,   x_Header_Payment_val_tbl    => l_header_payment_val_tbl
,   x_line_tbl                  => lx_line_tbl
,   x_line_val_tbl              => l_line_val_tbl
,   x_Line_Adj_tbl              => lx_line_adj_tbl
,   x_Line_Adj_val_tbl          => l_line_adj_val_tbl
,   x_Line_price_Att_tbl        => lx_line_price_att_tbl
,   x_Line_Adj_Att_tbl          => lx_line_adj_att_tbl
,   x_Line_Adj_Assoc_tbl        => lx_line_adj_assoc_tbl
,   x_Line_Scredit_tbl          => lx_line_scredit_tbl
,   x_Line_Scredit_val_tbl      => l_line_scredit_val_tbl
,   x_Lot_Serial_tbl            => lx_lot_serial_tbl
,   x_Lot_Serial_val_tbl        => l_lot_serial_val_tbl
,   x_Line_Payment_tbl          => lx_line_payment_tbl
,   x_Line_Payment_val_tbl      => l_line_payment_val_tbl
,   x_action_request_tbl        => lx_request_tbl
);

-- hyang: bug 2692785
  l_header_rec := lx_header_rec;
  l_Header_Adj_tbl := lx_Header_Adj_tbl;
  l_Header_price_Att_tbl := lx_Header_price_Att_tbl;
  l_Header_Adj_Att_tbl := lx_Header_Adj_Att_tbl;
  l_Header_Adj_Assoc_tbl := lx_Header_Adj_Assoc_tbl;
  l_Header_Scredit_tbl := lx_Header_Scredit_tbl;
  l_line_tbl := lx_line_tbl;
  l_Line_Adj_tbl := lx_Line_Adj_tbl;
  l_Line_price_Att_tbl := lx_Line_price_Att_tbl;
  l_Line_Adj_Att_tbl := lx_Line_Adj_Att_tbl;
  l_Line_Adj_Assoc_tbl := lx_Line_Adj_Assoc_tbl;
  l_Line_Scredit_tbl := lx_Line_Scredit_tbl;
  l_Lot_Serial_tbl := lx_Lot_Serial_tbl;
  l_request_tbl := lx_request_tbl;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Update_Order: After Process_Order: x_return_status'||x_return_status,1,'Y');
aso_utility_pvt.print_login_info();
END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF x_msg_count > 0 THEN
         	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR_MSG');
		  FND_MSG_PUB.ADD;
	 	END IF;
     END IF;

     retrieve_oe_messages;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF;

IF  (x_return_status = FND_API.G_RET_STS_SUCCESS AND
	p_control_rec.book_flag =  FND_API.G_TRUE AND
     l_request_tbl(1).return_status <> FND_API.G_RET_STS_SUCCESS)   THEN
       if x_msg_count > 0 then
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR_MSG');
		  FND_MSG_PUB.ADD;
	 END IF;
     end if;
       retrieve_oe_messages;
   x_return_status := FND_API.G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR;
END IF;

retrieve_oe_messages;

x_order_header_rec.order_number := l_header_rec.order_number;
x_order_header_rec.order_header_id    := l_header_rec.header_id;
x_order_header_rec.status       := l_header_rec.return_status;
-- x_order_header_rec.quote_header_id := to_number(l_header_rec.orig_sys_document_ref);
x_order_header_rec.quote_header_id := l_header_rec.source_document_id;

FOR i in 1..l_line_tbl.count LOOP
    x_order_line_tbl(i).order_line_id := l_line_tbl(i).line_id;
    x_order_line_tbl(i).order_header_id := l_line_tbl(i).header_id;
--    x_order_line_tbl(i).quote_shipment_line_id := to_number(l_line_tbl(i).orig_sys_document_ref);
    x_order_line_tbl(i).quote_shipment_line_id := l_line_tbl(i).source_document_line_id;
    x_order_line_tbl(i).status   := l_line_tbl(i).return_status;
END LOOP;

       --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
                null;
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                null;
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
          WHEN OTHERS THEN
                null;
                 ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_Order;




FUNCTION Get_Header_Status (
    p_Header_Id		NUMBER) RETURN VARCHAR2
IS
    l_result_date    DATE;
    l_latest_date    DATE := NULL;
    l_result         VARCHAR2(1);
    l_return_status  VARCHAR2(20) := NULL;
BEGIN


    OE_HEADER_STATUS_PUB.Get_Booked_Status
    (
      p_header_id    => p_Header_Id
      , x_result     => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      l_return_status := 'BOOKED';
      l_latest_date := l_result_date;

    END IF;


    OE_HEADER_STATUS_PUB.Get_Closed_Status
    (
      p_header_id    => p_Header_Id
      , x_result     => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'CLOSED';

      END IF;

    END IF;

    OE_HEADER_STATUS_PUB.Get_Cancelled_Status
    (
      p_header_id    => p_Header_Id
      , x_result     => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'CANCELLED';

      END IF;

    END IF;

    IF ( l_return_status IS NULL ) THEN

	 l_return_status := 'ENTERED';

    END IF;

    return (l_return_status);

END Get_Header_Status;


FUNCTION Get_Line_Status (
    p_Line_Id		NUMBER) RETURN VARCHAR2
IS
    l_result_date    DATE;
    l_latest_date    DATE := NULL;
    l_result         VARCHAR2(1);
    l_return_status  VARCHAR2(20) := NULL;
BEGIN

    OE_LINE_STATUS_PUB.Get_Closed_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      l_latest_date := l_result_date;
      l_return_status := 'CLOSED';

    END IF;

    OE_LINE_STATUS_PUB.Get_Cancelled_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'CANCELLED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_Purchase_Release_status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'RELEASED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_ship_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );


    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'SHIPPED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_Received_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'RECEIVED';

      END IF;

    END IF;

    OE_LINE_STATUS_PUB.Get_Invoiced_Status
    (
      p_line_id        => p_Line_Id
      , x_result       => l_result
      , x_result_date  => l_result_date
    );

    IF ( l_result = 'Y' ) THEN

      IF ( l_latest_date IS NULL OR l_result_date > l_latest_date ) THEN

        l_latest_date   := l_result_date;
        l_return_status := 'INVOICED';

      END IF;

    END IF;

    IF ( l_return_status IS NULL ) THEN

	 l_return_status := 'ENTERED';

    END IF;

    return(l_return_status);

END Get_Line_Status;


FUNCTION Total_List_Price (
   p_Header_Id in  NUMBER,
   p_Line_Id in NUMBER,
   p_line_number in NUMBER,
   p_shipment_number in number := null)
RETURN NUMBER
IS
    l_total  NUMBER;
BEGIN

  l_total := OE_OE_TOTALS_SUMMARY.LINE_TOTAL(
             p_Header_Id , p_Line_Id ,
             p_line_number, p_shipment_number);

  RETURN l_total;
  EXCEPTION
    WHEN OTHERS THEN
        return null;
END Total_List_Price;

FUNCTION Total_Order_Price (
   p_Header_Id	in	NUMBER) RETURN NUMBER
IS
    l_total  NUMBER;
    l_subtotal number;
    l_discount number;
    l_charges number;
    l_tax number;
BEGIN

  OE_OE_TOTALS_SUMMARY.ORDER_TOTALS( p_Header_Id,
                                     l_subtotal,
                                     l_discount,
                                     l_charges,
                                     l_tax
                                    );

  l_total := l_subtotal + l_charges + l_tax;

  RETURN (l_total);

  EXCEPTION
    WHEN OTHERS THEN
	return null;
END Total_Order_Price;

FUNCTION GET_ORDER_TOTAL(
   P_HEADER_ID  IN        NUMBER,
   P_LINE_ID    IN        NUMBER,
   P_TOTAL_TYPE IN        VARCHAR2   := 'ALL')
RETURN NUMBER
IS
l_total number;
begin

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

l_total := OE_Totals_GRP.GET_Order_Total (
			P_HEADER_ID ,
			P_LINE_ID,
			P_TOTAL_TYPE);
return (l_total);
EXCEPTION
  WHEN OTHERS THEN
    return null;
END GET_ORDER_TOTAL;

PROCEDURE  get_acct_site_uses
(
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_site_use_id OUT NOCOPY /* file.sql.39 change */   number
)
IS
CURSOR relationship_cur IS
SELECT a.party_type
from
HZ_PARTIES a, HZ_PARTY_SITES b
where
a.status = 'A'
and b.party_site_id = p_party_site_id
and b.party_id = a.party_id;
CURSOR site_use_cur IS
select a.site_use_id
from
hz_cust_site_uses_all a, hz_cust_acct_sites_all b
where
a.status = 'A'
and b.cust_account_id = p_cust_account_id
and b.party_site_id = p_party_site_id
and a.cust_acct_site_id = b.cust_acct_site_id
and a.site_use_code = p_acct_site_type;
l_party_type VARCHAR2(30);
l_site_use_id number;
begin

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN relationship_cur;
  FETCH relationship_cur INTO l_party_type;
  IF (relationship_cur%NOTFOUND) THEN
     l_party_type := NULL;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE relationship_cur;

  IF l_party_type = 'PARTY_RELATIONSHIP' THEN
     OPEN site_use_cur;
     FETCH site_use_cur INTO l_site_use_id;
     IF (site_use_cur%NOTFOUND) THEN
        l_site_use_id := NULL;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE site_use_cur;
  END IF;

  x_site_use_id := l_site_use_id;
END get_acct_site_uses;

PROCEDURE get_cust_acct_roles
(
p_party_id IN NUMBER,
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */   number
)
IS
CURSOR relationship_cur IS
SELECT party_type
from
HZ_PARTIES
where party_id = p_party_id and status ='A';
CURSOR org_contact IS
select a.org_contact_id
from
hz_org_contacts a, hz_relationships b
where
b.party_id = p_party_id
--and a.status = 'A' -- status column is obseleted
and b.relationship_id = a.party_relationship_id
and (sysdate between nvl(b.start_date, sysdate) and nvl(b.end_date, sysdate));
CURSOR cust_role IS
select a.cust_account_role_id
from
hz_cust_account_roles a, hz_role_responsibility b, hz_cust_acct_sites_all c
where
a.role_type = 'CONTACT'
and a.party_id = p_party_id
and a.cust_account_id = p_cust_account_id
and a.cust_acct_site_id = c.cust_acct_site_id
and a.cust_account_id = c.cust_account_id
and c.party_site_id = p_party_site_id
and a.cust_account_role_id = b.cust_account_role_id
and responsibility_type = p_acct_site_type;
l_org_contact_id number;
l_party_type VARCHAR2(30);
l_cust_account_role_id number;
begin

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN relationship_cur;
 FETCH relationship_cur INTO l_party_type;
 IF (relationship_cur%NOTFOUND) THEN
   l_party_type := NULL;
   x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
 CLOSE relationship_cur;

 IF l_party_type = 'PARTY_RELATIONSHIP' THEN
  OPEN org_contact;
  FETCH org_contact INTO l_org_contact_id;
  IF (org_contact%NOTFOUND) THEN
    l_org_contact_id := NULL;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE org_contact;

  OPEN cust_role;
  FETCH cust_role INTO l_cust_account_role_id;
  IF (cust_role%NOTFOUND) THEN
    l_cust_account_role_id := NULL;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE cust_role;

 END IF;

 x_cust_account_role_id := l_cust_account_role_id;
END get_cust_acct_roles;

  PROCEDURE Get_Cust_Accnt_Id(
   P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                           := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
   p_Party_Id  IN  NUMBER,
   p_Cust_Acct_Id  OUT NOCOPY /* file.sql.39 change */   NUMBER,
   x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
   x_msg_count  OUT NOCOPY /* file.sql.39 change */   NUMBER,
   x_msg_data  OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
   IS

   CURSOR C_get_cust_id_from_party_id(l_Party_Id NUMBER) IS
     SELECT cust_account_id
     FROM hz_cust_accounts
     WHERE party_id = l_Party_Id
     and status = 'A';

     count NUMBER := 0;
     x_cust_id NUMBER := NULL;
     lx_cust_id NUMBER := NULL;

    l_msg_count                   number;
    l_msg_data                    varchar2(200);
    lx_cust_account_id         NUMBER;
    l_return_status               VARCHAR2(1);



BEGIN

OPEN C_get_cust_id_from_party_id(p_Party_Id);

LOOP
  FETCH C_get_cust_id_from_party_id INTO lx_cust_id;
  IF C_get_cust_id_from_party_id%ROWCOUNT > 1 THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     EXIT;
  END IF;
  EXIT WHEN C_get_cust_id_from_party_id%NOTFOUND;
END LOOP;

CLOSE C_get_cust_id_from_party_id;

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
   FND_MESSAGE.Set_Name('ASO', 'ASO_MULTIPLE_CUST_ACCOUNT');
    FND_MESSAGE.Set_Token('ID', to_char( p_qte_rec.party_id), FALSE);
    FND_MSG_PUB.ADD;
    raise FND_API.G_EXC_ERROR;
 END IF;

IF lx_cust_id IS NULL OR lx_cust_id = FND_API.G_MISS_NUM THEN
          IF p_qte_rec.party_id is not NULL
             AND p_qte_rec.party_id <> FND_API.G_MISS_NUM THEN
                ASO_PARTY_INT.Create_Customer_Account(
                      p_api_version      => 1.0
                     ,P_Qte_REC          => p_qte_rec
                     ,x_return_status    => l_return_status
                     ,x_msg_count        => l_msg_count
                     ,x_msg_data         => l_msg_data
                     ,x_acct_id          => lx_cust_account_id
                             );

                 IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                       THEN
                          FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
                          FND_MESSAGE.Set_Token('ID', to_char( p_qte_rec.party_id), FALSE);
                          FND_MSG_PUB.ADD;
                    END IF;
                    raise FND_API.G_EXC_ERROR;
               END IF;

          p_Cust_Acct_Id := lx_cust_account_id;
     END IF;

ELSE
          p_Cust_Acct_Id := lx_cust_id;

END IF;

END Get_Cust_Accnt_Id;

End ASO_ORDER_INT;


/
