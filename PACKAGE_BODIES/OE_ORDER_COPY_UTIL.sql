--------------------------------------------------------
--  DDL for Package Body OE_ORDER_COPY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_COPY_UTIL" AS
/* $Header: OEXUCPYB.pls 120.13.12010000.17 2010/04/07 06:12:33 spothula ship $ */

G_DOC_HEADER_ID    NUMBER := NULL;
G_ATT_HEADER_ID    NUMBER := NULL;
G_ORDER_NUMBER     NUMBER := NULL;
G_VERSION_NUMBER   NUMBER := NULL;
G_ORDER_TYPE_ID    NUMBER := NULL;
G_ADJ_HDR_ID       NUMBER := NULL;
G_HDR_ADJ_TBL      OE_Order_PUB.Header_Adj_Tbl_Type;
G_NEED_TO_EXPLODE_CONFIG  BOOLEAN := FALSE;
G_COPY_TO_DIFFERENT_ORDER_TYPE BOOLEAN := FALSE;     -- 5404002

-- Added for the ER 1480867

PROCEDURE Process_Line_Numbers(p_header_id IN NUMBER);

PROCEDURE Create_Line_Set(
                 p_src_line_id  IN NUMBER,
                 p_line_id      IN NUMBER,
                 p_line_set_id  IN NUMBER,
                 p_header_id    IN NUMBER,
                 p_line_type_id IN NUMBER
                 );

PROCEDURE EXTEND_TBL(p_num IN NUMBER);

PROCEDURE DELETE_TBL;

PROCEDURE sort_line_tbl(p_line_id_tbl  IN OE_GLOBALS.Selected_Record_Tbl,
                         p_version_number IN NUMBER,
                         p_phase_change_flag IN VARCHAR2,
                         p_num_lines  IN NUMBER,
                         x_line_tbl   IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type);

-- End

-- Added as part of Inline Code Documentation Drive.
------------------------------------------------------------------------------------
-- Function Name  : Get_Copy_Rec
-- Input Params   : None.
-- Return Type    : Copy_Rec_Type : Copy Record Type
-- Description    : This function returns default initialized values for control
--                  variables (denoting Checkboxes on Copy Form),while creating a
--                  copy record type variable. This is used only in Copy Flow, and
--                  is called in OEORDCPY.pld for initializing p_copy_rec.
------------------------------------------------------------------------------------

Function Get_copy_rec
Return Copy_rec_type
IS
 x_copy_rec copy_rec_type;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
   x_copy_rec.init_msg_list   := FND_API.G_FALSE;
   x_copy_rec.commit          := FND_API.G_FALSE;
   x_copy_rec.copy_order      := FND_API.G_TRUE;
   x_copy_rec.hdr_info        := FND_API.G_TRUE;
   x_copy_rec.hdr_descflex    := FND_API.G_TRUE;
   x_copy_rec.hdr_scredits    := FND_API.G_TRUE;
   x_copy_rec.hdr_attchmnts   := FND_API.G_TRUE;
   x_copy_rec.hdr_holds       := FND_API.G_TRUE;
   x_copy_rec.hdr_credit_card_details := FND_API.G_FALSE;
   x_copy_rec.all_lines       := FND_API.G_TRUE;
   x_copy_rec.incl_cancelled  := FND_API.G_FALSE;
   x_copy_rec.line_price_mode := G_CPY_ORIG_PRICE;
   x_copy_rec.line_price_date := FND_API.G_MISS_DATE;
   x_copy_rec.line_descflex   := FND_API.G_TRUE;
   x_copy_rec.line_scredits   := FND_API.G_TRUE;
   x_copy_rec.line_attchmnts  := FND_API.G_TRUE;
   x_copy_rec.line_fulfill_sets := FND_API.G_FALSE;  -- Copy Sets ER #2830872 , #1566254.
   x_copy_rec.line_ship_arr_sets := FND_API.G_FALSE; -- Copy Sets ER #2830872 , #1566254.

   RETURN x_copy_rec;

END Get_copy_rec;

Function Find_LineIndex
(p_line_tbl IN OE_Order_PUB.Line_Tbl_type,
 p_line_id  IN NUMBER
)
Return Number
IS

 K 			NUMBER; -- Used as Index for loop.
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.FIND_LINEINDEX ' , 1 ) ;
      END IF;

      k := p_line_tbl.FIRST;

	 WHILE K IS NOT NULL LOOP
	 BEGIN

		IF p_line_tbl(k).line_id = p_line_id THEN

		   -- Return Index

		   IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.FIND_LINEINDEX ' , 1 ) ;
		   END IF;
		   RETURN k;

          END IF;
      END;
          k := p_line_tbl.NEXT(k);
      END LOOP;

      -- Line not in table

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.FIND_LINEINDEX ' , 1 ) ;
      END IF;
      RETURN FND_API.G_MISS_NUM;

END Find_LineIndex;


FUNCTION Get_Order_Category ( p_order_type_id IN NUMBER )
RETURN VARCHAR2
IS
l_api_name                    VARCHAR2(30) := 'Get_Order_Category';
l_category                    VARCHAR2(30) := NULL;

-- Bug 7829434 : Following cursor is changed to avoid org ctx change in case of
-- copy accross organization. Hence cat code is directly selected from master
-- table instead of org specific view.
CURSOR GET_ORDER_CAT (p_order_type_in NUMBER) IS
       SELECT ORDER_CATEGORY_CODE --SELECT ORDER_CATEGORY_CODE
       FROM   OE_transaction_TYPES_all  --FROM   OE_ORDER_TYPES_V
       WHERE  TRANSACTION_TYPE_ID = p_order_type_in; --WHERE  ORDER_TYPE_ID = p_order_type_in;
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.GET_ORDER_CATEGORY' , 1 ) ;
    END IF;

    OPEN  GET_ORDER_CAT (p_order_type_id);
    FETCH GET_ORDER_CAT
    INTO  l_category;

    CLOSE GET_ORDER_CAT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.GET_ORDER_CATEGORY' , 1 ) ;
    END IF;

    RETURN l_category;
EXCEPTION
  WHEN OTHERS THEN


    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Category;

FUNCTION Get_Line_Category ( p_Line_type_id IN NUMBER )
RETURN VARCHAR2
IS
l_api_name                    VARCHAR2(30) := 'Get_Line_Category';
l_category                    VARCHAR2(30) := NULL;

-- Bug 7829434 : Following cursor is changed to avoid org ctx change in case of
-- copy accross organization. Hence cat code is directly selected from master
-- table instead of org specific view.
CURSOR GET_LINE_CAT (p_line_type_in NUMBER) IS
       SELECT ORDER_CATEGORY_CODE --SELECT ORDER_CATEGORY_CODE
       FROM   OE_transaction_TYPES_all --FROM   OE_LINE_TYPES_V
       WHERE  TRANSACTION_TYPE_ID = p_line_type_in; --WHERE  LINE_TYPE_ID = p_line_type_in;
       --
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
       --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.GET_LINE_CATEGORY' , 1 ) ;
    END IF;

    OPEN GET_LINE_CAT(p_line_type_id);
    FETCH GET_LINE_CAT
    INTO  l_category;
    CLOSE GET_LINE_CAT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.GET_LINE_CATEGORY' , 1 ) ;
    END IF;

    RETURN l_category;
EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Line_Category;

FUNCTION Get_Default_Line ( p_order_type_id IN NUMBER
,x_line_type_id OUT NOCOPY NUMBER)

RETURN VARCHAR2
IS
l_api_name                    VARCHAR2(30) := 'Get_Default_Line';
l_category                    VARCHAR2(30) := NULL;
l_line_type_id                NUMBER;
l_line_type                   VARCHAR2(240);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.GET_DEFAULT_LINE' , 1 ) ;
    END IF;
    l_category := get_order_category(p_order_type_id);

   BEGIN
    IF l_category = 'RETURN' THEN
       SELECT default_inbound_line_type_id
	  INTO   l_line_type_id
	  FROM   oe_transaction_types_v
	  WHERE  transaction_type_id = p_order_type_id;
    ELSE

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE DEFAULT LINE_TYPE' , 2 ) ;
       END IF;
       SELECT default_outbound_line_type_id
	  INTO   l_line_type_id
	  FROM   oe_transaction_types_v
	  WHERE  transaction_type_id = p_order_type_id;
    END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE LINE_TYPE ID' , 2 ) ;
      END IF;
	SELECT name
	INTO   l_line_type
	FROM   Oe_line_types_v
	WHERE  line_type_id = l_line_type_id;


   EXCEPTION

    WHEN NO_DATA_FOUND THEN

	 Null;

   END;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.GET_DEFAULT_LINE' , 1 ) ;
    END IF;
     x_line_type_id := l_line_type_id;
	Return l_line_type;

EXCEPTION
  WHEN OTHERS THEN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'IN OTHERS ASWIN' , 2 ) ;
   END IF;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Default_Line;


Procedure Get_Document_info (p_header_id IN NUMBER
,x_order_number OUT NOCOPY NUMBER

,x_version_number OUT NOCOPY NUMBER

,x_order_type_id OUT NOCOPY NUMBER)

IS
l_order_number   NUMBER;
l_version_number NUMBER;
l_order_type_id  NUMBER;
l_api_name       VARCHAR2(30) := 'Get_Document_info';

CURSOR GET_DOC_INFO(p_header_In NUMBER) IS
       SELECT order_number,
              version_number,
              order_type_id
         FROM OE_ORDER_HEADERS
        WHERE header_id = p_header_in;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.GET_DOCUMENT_INFO' , 1 ) ;
    END IF;

    IF G_DOC_HEADER_ID IS NOT NULL THEN
       IF p_header_id = G_DOC_HEADER_ID THEN
          x_order_number := G_ORDER_NUMBER;
          x_version_number := G_VERSION_NUMBER;
          x_order_type_id := G_ORDER_TYPE_ID;
          RETURN;
       END IF;
    END IF;

    OPEN GET_DOC_INFO(p_header_id);
    FETCH GET_DOC_INFO
     INTO l_order_number,
          l_version_number,
          l_order_type_id;

   -- Set Cached Globals.

   G_DOC_HEADER_ID  := p_header_id;
   G_ORDER_NUMBER   := l_order_number;
   G_VERSION_NUMBER := l_version_number;
   G_ORDER_TYPE_ID  := l_order_type_id;

   -- Set Out variables

   x_order_number   := l_order_number;
   x_version_number := l_version_number;
   x_order_type_id  := l_order_type_id;


   CLOSE GET_DOC_INFO;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.GET_DOCUMENT_INFO' , 1 ) ;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Document_info;

Procedure  Copy_Header
( p_header_id               IN NUMBER
 ,p_copy_rec                IN copy_rec_type
 ,x_header_rec              IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type)
IS
  l_api_name                  CONSTANT VARCHAR(30) := 'Copy_Header';
  l_orig_category             VARCHAR2(30);
  l_cpy_category              VARCHAR2(30);
  l_orig_ship_from_org_id     OE_Order_Headers.ship_from_org_id%TYPE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  --R12 CC Encryption
  l_payment_exists	 VARCHAR2(1) := 'N';
  --R12 CC Encryption
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.COPY_HEADER' , 1 ) ;
    END IF;

-- Query the Header to be copied

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER HEADER IS '||TO_CHAR ( P_HEADER_ID ) , 2 ) ;
    END IF;

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
        OE_Version_History_Util.Query_row(p_header_id  => p_header_id,
                           p_version_number => p_copy_rec.version_number,
                           p_phase_change_flag => p_copy_rec.phase_change_flag,
                           x_header_rec => x_header_rec);
    ELSE
        OE_Header_Util.Query_row(p_header_id  => p_header_id,
                                 x_header_rec => x_header_rec);
    END IF;

    IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'After querying Header '||x_header_rec.order_number,1);
    END IF;

/* Added the following code to null out nocopy acknowledgement related fields in the order header , to fix the bug 1862719 */


    x_header_rec.first_ack_code := FND_API.G_MISS_CHAR;
    x_header_rec.first_ack_date := FND_API.G_MISS_DATE;
    x_header_rec.last_ack_code  := FND_API.G_MISS_CHAR;
    x_header_rec.last_ack_date  := FND_API.G_MISS_DATE;

/* End of code added to fix the bug 1862719 */

    -- Adding Code for New COPY chnages for 11.5.10
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'  THEN

        x_header_rec.USER_STATUS_CODE := FND_API.G_MISS_CHAR;
        x_header_rec.DRAFT_SUBMITTED_FLAG := FND_API.G_MISS_CHAR;
        x_header_rec.QUOTE_DATE := FND_API.G_MISS_DATE;
        x_header_rec.SOURCE_DOCUMENT_VERSION_NUMBER :=
                                           x_header_rec.version_number;

        /* Added the following code to null out signature columns Bug:3698434*/
        x_header_rec.supplier_signature := FND_API.G_MISS_CHAR;
        x_header_rec.supplier_signature_date := FND_API.G_MISS_DATE;
        x_header_rec.customer_signature := FND_API.G_MISS_CHAR;
        x_header_rec.customer_signature_date := FND_API.G_MISS_DATE;

        IF p_copy_rec.new_phase = 'N' THEN
            x_header_rec.TRANSACTION_PHASE_CODE := 'N';
        ELSE
            x_header_rec.TRANSACTION_PHASE_CODE := 'F';
        END IF;

        IF p_copy_rec.copy_transaction_name = FND_API.G_FALSE THEN
            x_header_rec.SALES_DOCUMENT_NAME := p_copy_rec.transaction_name;
        END IF;

        IF p_copy_rec.copy_expiration_date = FND_API.G_FALSE THEN
            x_header_rec.EXPIRATION_DATE := NVL(p_copy_rec.expiration_date,
                                             FND_API.G_MISS_DATE);
        END IF;

        IF p_copy_rec.manual_quote_number IS NOT NULL THEN
            x_header_rec.quote_number   := p_copy_rec.manual_quote_number;
        ELSE
            x_header_rec.quote_number   := FND_API.G_MISS_NUM;
        END IF;

    END IF;

--key Transaction Dates Project
	   x_header_rec.order_firmed_date := FND_API.G_MISS_DATE ;
--end

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER TO BE COPIED IS '||TO_CHAR ( X_HEADER_REC.ORDER_NUMBER ) , 2 ) ;
    END IF;

-- Query Original Order Category

   l_orig_category := Get_Order_category(x_header_rec.order_type_id);

-- Query Copy Order Category

   IF p_copy_rec.hdr_type IS NULL THEN
      l_cpy_category := l_orig_category;
   ELSE
      l_cpy_category := Get_Order_category(p_copy_rec.hdr_type);
   END IF;

-- Is Order being copied to different Order Type ?   5404002
   IF NVL(p_copy_rec.hdr_type, x_header_rec.order_type_id) <> x_header_rec.order_type_id THEN
      G_COPY_TO_DIFFERENT_ORDER_TYPE := TRUE;
   END IF;


-- Init required attributes on the Header Record


    -- Set Order Type if passed in.
    IF (p_copy_rec.hdr_type IS NOT NULL) THEN
      x_header_rec.order_type_id := p_copy_rec.hdr_type;
    END IF;

    -- Clear category. Process Order will re-set this.
    x_header_rec.order_category_code := FND_API.G_MISS_CHAR;

    -- Set Source Information
    x_header_rec.source_document_type_id := 2;
    x_header_rec.source_document_id  := x_header_rec.header_id;

    --Set Order Number
    IF p_copy_rec.manual_order_number IS NOT NULL THEN
       x_header_rec.order_number   := p_copy_rec.manual_order_number;
    ELSE
       x_header_rec.order_number   := FND_API.G_MISS_NUM;
    END IF;

    x_header_rec.header_id      := FND_API.G_MISS_NUM;
    x_header_rec.version_number := FND_API.G_MISS_NUM;
    x_header_rec.operation      := OE_GLOBALS.G_OPR_CREATE;

    IF (x_header_rec.ordered_date < sysdate) THEN
       x_header_rec.ordered_date   := FND_API.G_MISS_DATE;
    END IF;

    IF (x_header_rec.request_date  < sysdate) THEN
       x_header_rec.request_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_copy_rec.new_phase = 'F'
    AND x_header_rec.ordered_date IS NULL THEN
       x_header_rec.ordered_date := FND_API.G_MISS_DATE;

    END IF;

    /* To fix bug 1411329 */
--    x_header_rec.agreement_id   := FND_API.G_MISS_NUM;
    /* To fix bug 1765169 */
      x_header_rec.pricing_date := sysdate ;
    /* To fix bug 1794902 */
      x_header_rec.booked_date := FND_API.G_MISS_DATE;

    -- Clear Orig Sys ref columns

    x_header_rec.order_source_id       := 2;
    x_header_rec.orig_sys_document_ref := FND_API.G_MISS_CHAR;

    -- Clear who columns.
    x_header_rec.creation_date          := FND_API.G_MISS_DATE;
    x_header_rec.created_by             := FND_API.G_MISS_NUM;
    x_header_rec.last_update_date       := FND_API.G_MISS_DATE;
    x_header_rec.last_updated_by        := FND_API.G_MISS_NUM;
    x_header_rec.last_update_login      := FND_API.G_MISS_NUM;
    x_header_rec.program_application_id := FND_API.G_MISS_NUM;
    x_header_rec.program_id             := FND_API.G_MISS_NUM;
    x_header_rec.program_update_date    := FND_API.G_MISS_DATE;
    x_header_rec.request_id             := FND_API.G_MISS_NUM;

    if x_header_rec.ACCOUNTING_RULE_ID is null then  -- added for Bug 6519067
       x_header_rec.ACCOUNTING_RULE_ID     :=  FND_API.G_MISS_NUM;  -- added for Bug 6519067
    end if;

    -- Clear Status flags
    x_header_rec.booked_flag     := FND_API.G_MISS_CHAR;
    x_header_rec.cancelled_flag  := FND_API.G_MISS_CHAR;
    x_header_rec.open_flag       := FND_API.G_MISS_CHAR;

    IF p_copy_rec.new_phase = 'F' THEN
        x_header_rec.flow_status_code := 'ENTERED';
    ELSE
        x_header_rec.flow_status_code := NULL;
    END IF;

    -- Do not copy credit card details if check box not checked
    -- in Copy Orders form
    -- Reason 1:  User does not have privileges to copy CC details
    -- Reason 2:  User have privileges but did not choose to copy

    -- retain the original behavior if multiple payments not enabled.
    IF NOT OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Multiple Payments not enabled, old code path.', 3 ) ;
      END IF;

      IF (p_copy_rec.hdr_payments = FND_API.G_FALSE) THEN
	  x_header_rec.credit_card_number          := FND_API.G_MISS_CHAR;
	  x_header_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
	  x_header_rec.credit_card_holder_name     := FND_API.G_MISS_CHAR;
      END IF;


    -- don't copy any payment information to order of RETURN type.
    --R12 CC Encryption
    ELSIF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
       --x_header_rec.payment_type_code           := FND_API.G_MISS_CHAR;
       --x_header_rec.check_number                := FND_API.G_MISS_CHAR; --Verify

	--Before populating the header rec, have to make sure that the
	--payment record corresponding to this order is not present in
	--oe_payments already to avoid duplicate records while copying an
	--order from 11510 non migrated order.
	 BEGIN
		SELECT 'Y'
		INTO l_payment_exists
		FROM oe_payments
		WHERE header_id = p_header_id
		AND line_id is null -- bug 5167945
		AND PAYMENT_COLLECTION_EVENT = 'INVOICE';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_payment_exists := 'N';
		IF l_debug_level >0 THEN
			oe_debug_pub.add('Header id'||p_header_id);
		END IF;
	END;
	IF l_payment_exists = 'Y' THEN
	       x_header_rec.credit_card_number          := FND_API.G_MISS_CHAR;
	       x_header_rec.credit_card_code		:= FND_API.G_MISS_CHAR;
	       x_header_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
	       x_header_rec.credit_card_holder_name     := FND_API.G_MISS_CHAR;
	END IF;

       IF (l_cpy_category = 'RETURN' OR NOT FND_API.to_Boolean(p_copy_rec.hdr_payments)) THEN
	       x_header_rec.payment_type_code := FND_API.G_MISS_CHAR; --Verify
	       x_header_rec.check_number                := FND_API.G_MISS_CHAR;
	       x_header_rec.credit_card_number          := FND_API.G_MISS_CHAR;
	       x_header_rec.credit_card_code		:= FND_API.G_MISS_CHAR;
	       x_header_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
	       x_header_rec.credit_card_holder_name     := FND_API.G_MISS_CHAR;

       --ELSIF x_header_rec.payment_type_code IN ('CHECK','CREDIT_CARD','CASH') THEN
		--g_create_payment_flag := 'Y';
       END IF;
    --R12 CC Encryption
    END IF;

    -- Fix for Bug # 1691168 : Never Copy Credit_Card_Approval_Code,
    -- Credit_Card_Approval_Date and Payment Amount.
    x_header_rec.credit_card_approval_code := FND_API.G_MISS_CHAR;
    x_header_rec.credit_card_approval_date := FND_API.G_MISS_DATE;
    x_header_rec.payment_amount            := FND_API.G_MISS_NUM;

    -- Clear Descriptive flex if it isn't being copied

    IF (p_copy_rec.hdr_descflex = FND_API.G_FALSE) THEN

        x_header_rec.context     := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute1  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute10 := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute11  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute12  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute13  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute14  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute15  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute16  := FND_API.G_MISS_CHAR;  --For bug 2184255
	   x_header_rec.attribute17  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute18  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute19  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute2  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute20  := FND_API.G_MISS_CHAR; --For bug 2184255
	   x_header_rec.attribute3  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute4  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute5  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute6  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute7  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute8  := FND_API.G_MISS_CHAR;
	   x_header_rec.attribute9  := FND_API.G_MISS_CHAR;


	   x_header_rec.global_attribute_category := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute1         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute2         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute3         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute4         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute5         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute6         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute7         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute8         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute9         := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute10        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute11        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute12        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute13        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute14        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute15        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute16        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute17        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute18        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute19        := FND_API.G_MISS_CHAR;
        x_header_rec.global_attribute20        := FND_API.G_MISS_CHAR;

	   x_header_rec.tp_context            := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute1         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute2         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute3         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute4         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute5         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute6         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute7         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute8         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute9         := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute10        := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute11        := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute12        := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute13        := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute14        := FND_API.G_MISS_CHAR;
        x_header_rec.tp_attribute15        := FND_API.G_MISS_CHAR;

    END IF; -- We are not copying descflex


    -- Special handling if we are copying a Regular Order to a Return
    IF ((l_orig_category = 'ORDER') OR
	   (l_orig_category = 'MIXED')) AND
	   (l_cpy_category = 'RETURN')THEN

       -- Set Freight cols to missing
       x_header_rec.shipping_method_code   := FND_API.G_MISS_CHAR;
       x_header_rec.freight_carrier_code   := FND_API.G_MISS_CHAR;
       x_header_rec.fob_point_code         := FND_API.G_MISS_CHAR;
       x_header_rec.freight_terms_code     := FND_API.G_MISS_CHAR;
       x_header_rec.shipping_instructions  := FND_API.G_MISS_CHAR;
       x_header_rec.packing_instructions   := FND_API.G_MISS_CHAR;

       -- Deliver to Org should match Ship to Org

       x_header_rec.deliver_to_org_id := FND_API.G_MISS_NUM;


       -- Set Other attributes to Missing

/* Commented the following line to fix the bug 1901882  */
  /*     x_header_rec.ship_to_contact_id    := FND_API.G_MISS_NUM;  */

       x_header_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
       x_header_rec.demand_class_code     := FND_API.G_MISS_CHAR;

       x_header_rec.accounting_rule_duration := NULL;

    END IF;

       -- PROMOTIONS SEP/01 Set price_request_code to NULL
      x_header_rec.price_request_code := NULL;

      -- Clear line set information.
      IF x_header_rec.customer_preference_set_code IS NULL THEN
         x_header_rec.customer_preference_set_code := FND_API.G_MISS_CHAR;
      END IF;

/* Take the comment out nocopy once testing is done in omhut2 */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.COPY_HEADER ' , 1 ) ;
    END IF;


EXCEPTION

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN OTHERS' , 2 ) ;
        END IF;

        If OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Copy_Header;


PROCEDURE  Load_and_Init_Hdr_Scredits
(p_header_Id IN Number
,p_version_number IN NUMBER
,p_phase_change_flag IN VARCHAR2
,x_Header_Scredit_tbl IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type)
IS
l_api_name           CONSTANT VARCHAR(30) := 'Load_and_Init_Hdr_Scredits';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_HDR_SCREDITS' , 1 ) ;
     END IF;

     -- Load Header Sales Credits
     BEGIN

        x_Header_Scredit_tbl.delete;    --   1724939
        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
            OE_Version_History_UTIL.query_rows(
                                  p_sales_credit_id => NULL,
                                  p_header_id => p_header_id,
                                  p_version_number => p_version_number,
                                  p_phase_change_flag => p_phase_change_flag,
	                              x_header_scredit_tbl => x_header_scredit_tbl);
        ELSE
            OE_Header_Scredit_Util.query_rows(p_header_id => p_header_id,
	                              x_header_scredit_tbl => x_header_scredit_tbl);
        END IF;

	EXCEPTION

	  WHEN NO_DATA_FOUND THEN
	  NULL;

     END;
     -- Init Table for Copying

     IF x_header_scredit_tbl.COUNT > 0 THEN

        FOR k IN x_header_scredit_tbl.FIRST .. x_header_scredit_tbl.LAST LOOP

             x_header_scredit_tbl(k).operation := OE_GLOBALS.G_OPR_CREATE;
             x_header_scredit_tbl(k).header_id := FND_API.G_MISS_NUM;
             x_header_scredit_tbl(k).sales_credit_id := FND_API.G_MISS_NUM;

        END LOOP;

     END IF; -- Table has rows

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADER SC IS '||TO_CHAR ( X_HEADER_SCREDIT_TBL.COUNT ) , 2 ) ;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_HDR_SCREDITS' , 1 ) ;
     END IF;



EXCEPTION

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN OTHERS' , 2 ) ;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_and_Init_Hdr_Scredits;

-- This function loads header based holds into the action request table.
Function Load_and_Init_Hdr_Holds
(p_header_Id          IN Number
,p_version_number     IN NUMBER
,p_phase_change_flag  IN VARCHAR2
,p_action_request_tbl IN OE_Order_PUB.Request_Tbl_Type)
Return OE_Order_PUB.Request_Tbl_Type
IS
l_api_name              CONSTANT VARCHAR(30) := 'Load_and_Init_Hdr_Holds';
l_action_request_tbl    OE_Order_PUB.Request_Tbl_Type;
k                       NUMBER := 1;
l_hold_source_tbl       OE_Hold_Sources_PVT.Hold_Source_TBL;
l_return_status         VARCHAR2(1);
l_v_number              NUMBER;

      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_HDR_HOLDS' , 1 ) ;
     END IF;

     -- Since the action request table could already have rows in it
     -- set the index appropriately.
     l_action_request_tbl := p_action_request_tbl;

     -- If the Source is from a History Table then No Need to COPY holds.

     IF p_phase_change_flag = 'Y' THEN
         RETURN l_action_request_tbl;
     END IF;

     IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
         SELECT version_number
         INTO l_v_number
         FROM oe_order_headers
         WHERE header_id = p_header_id;

         IF NOT OE_GLOBALS.EQUAL(l_v_number,p_version_number) THEN
             RETURN l_action_request_tbl;
         END IF;
     END IF;

     k := l_action_request_tbl.COUNT + 1;

     -- Load Order Based holds for Copying

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING OE_HOLD_SOURCES_PVT.QUERY_HOLD_SOURCE' , 2 ) ;
     END IF;

     OE_HOLD_SOURCES_PVT.QUERY_HOLD_SOURCE(p_header_id,
                                           l_hold_source_tbl,
                                           l_return_status);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER OE_HOLD_SOURCES_PVT.QUERY_HOLD_SOURCE' , 2 ) ;
     END IF;

     IF (l_hold_source_tbl.COUNT > 0) THEN
        FOR curr in l_hold_source_tbl.FIRST .. l_hold_source_tbl.LAST LOOP
        -- copy only non seeded holds. Seeded holds are from 1 to 1000.
        -- only copy Order vbased source and holds

          IF  l_hold_source_tbl(curr).hold_entity_code = 'O'
	     AND l_hold_source_tbl(curr).hold_id >= 1000 THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'LOADING HOLD SOURCE '|| TO_CHAR ( L_HOLD_SOURCE_TBL ( CURR ) .HOLD_ID ) , 2 ) ;
                END IF;

              l_action_request_tbl(k).entity_code := OE_GLOBALS.G_ENTITY_HEADER;
              l_action_request_tbl(k).request_type:= OE_Globals.G_APPLY_HOLD;
              l_action_request_tbl(k).param1      := l_hold_source_tbl(curr).hold_id;
              l_action_request_tbl(k).param2      := 'O';

              -- load other source fields
              l_action_request_tbl(k).param4  := l_hold_source_tbl(curr).hold_comment;
              l_action_request_tbl(k).date_param1 :=
					l_hold_source_tbl(curr).hold_until_date;

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'AFTER LOADING HOLD SOURCE DATE' , 3 ) ;
              END IF;

              -- load Hold source desc flex
              l_action_request_tbl(k).param10 := l_hold_source_tbl(curr).context;
              l_action_request_tbl(k).param11 := l_hold_source_tbl(curr).attribute1;
              l_action_request_tbl(k).param12 := l_hold_source_tbl(curr).attribute2;
              l_action_request_tbl(k).param13 := l_hold_source_tbl(curr).attribute3;
              l_action_request_tbl(k).param14 := l_hold_source_tbl(curr).attribute4;
              l_action_request_tbl(k).param15 := l_hold_source_tbl(curr).attribute5;
              l_action_request_tbl(k).param16 := l_hold_source_tbl(curr).attribute6;
              l_action_request_tbl(k).param17 := l_hold_source_tbl(curr).attribute7;
              l_action_request_tbl(k).param18 := l_hold_source_tbl(curr).attribute8;
              l_action_request_tbl(k).param19 := l_hold_source_tbl(curr).attribute9;
              l_action_request_tbl(k).param20 := l_hold_source_tbl(curr).attribute10;
              l_action_request_tbl(k).param21 := l_hold_source_tbl(curr).attribute11;
              l_action_request_tbl(k).param22 := l_hold_source_tbl(curr).attribute12;
              l_action_request_tbl(k).param23 := l_hold_source_tbl(curr).attribute13;
              l_action_request_tbl(k).param24 := l_hold_source_tbl(curr).attribute14;
              l_action_request_tbl(k).param25 := l_hold_source_tbl(curr).attribute15;

              -- Increment index
              k := k + 1;
          END IF; -- IF Order Based Source
        END LOOP;
     END IF; -- Table has records

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_HDR_HOLDS' , 1 ) ;
     END IF;

     RETURN l_action_request_tbl;


EXCEPTION

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN OTHERS' , 3 ) ;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_and_Init_Hdr_Holds;

-- Added for multiple payments
PROCEDURE  Load_and_Init_Hdr_Payments
(p_header_Id IN Number
,x_Header_Payment_tbl IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type)
 IS
k	pls_integer;

--R12 CC Encryption
l_invoice_to_cust_id  NUMBER;
l_invoice_to_org_id NUMBER;
L_trxn_extension_id NUMBER;
l_return_status VARCHAR2(30);
L_msg_count		NUMBER;
L_msg_data		VARCHAR2(2000);
--R12 CC Encryption

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.Load_and_Init_Hdr_Payments', 3
 ) ;
  END IF;

  x_Header_Payment_tbl.delete;
  OE_Header_Payment_Util.query_rows
    (p_header_id => p_header_id,
     x_header_payment_tbl => x_header_payment_tbl);

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'After query_rows, the count is: '|| x_header_payment_tbl.COUNT,3) ;
  END IF;

  IF x_header_payment_tbl.COUNT > 0 THEN
    -- assign G_MISS to those attributes that are not copied.
    FOR k IN x_header_payment_tbl.FIRST .. x_header_payment_tbl.LAST LOOP
      x_header_payment_tbl(k).operation := OE_GLOBALS.G_OPR_CREATE;
      x_header_payment_tbl(k).header_id := FND_API.G_MISS_NUM;
      x_header_payment_tbl(k).line_id := FND_API.G_MISS_NUM;
      x_header_payment_tbl(k).prepaid_amount := FND_API.G_MISS_NUM;
      x_header_payment_tbl(k).commitment_applied_amount:= FND_API.G_MISS_NUM;
      x_header_payment_tbl(k).commitment_interfaced_amount := FND_API.G_MISS_NUM;
      x_header_payment_tbl(k).credit_card_approval_code := FND_API.G_MISS_CHAR;
      x_header_payment_tbl(k).payment_amount := 0;
      x_header_payment_tbl(k).payment_set_id := FND_API.G_MISS_NUM;
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('trxn_extension id'||x_header_payment_tbl(k).trxn_extension_id);
      END IF;

	--R12 CC Encryption
	/*IF  x_header_payment_tbl(k).payment_type_code
	IN ('CREDIT_CARD','ACH','DIRECT_DEBIT','CASH','CHECK','WIRE_TRANSFER') THEN

		Select	customer_id
		Into 	l_invoice_to_cust_id
		From 	Oe_invoice_to_orgs_v
		Where	organization_id = oe_order_cache.g_header_rec.invoice_to_org_id;
		Select invoice_to_org_id
		into l_invoice_to_org_id
		from oe_order_headers_all
		where header_id = p_header_id;

		--populate the header payment table with the trxn_extension_id
		--before process order api is called for the new order.

		L_trxn_extension_id := x_header_payment_tbl(k).trxn_extension_id;

		OE_PAYMENT_TRXN_UTIL.Create_Payment_Trxn(
			P_header_id		=> p_header_id, --Verify
			P_line_id		=> null,
			P_cust_id		=> l_invoice_to_cust_id,
			P_site_use_id		=> l_invoice_to_org_id,
			p_payment_number	=> x_header_payment_tbl(k).payment_number,
			P_payment_type_code	=> x_header_payment_tbl(k).payment_type_code,
			P_payment_trx_id	=> x_header_payment_tbl(k).payment_trx_id,
			P_card_number		=> x_header_payment_tbl(k).credit_card_number,
			p_card_code		=> x_header_payment_tbl(k).credit_card_code,
			P_card_holder_name	=> x_header_payment_tbl(k).credit_card_holder_name,
			P_exp_date		=> x_header_payment_tbl(k).credit_card_expiration_date,
			P_check_number		=> x_header_payment_tbl(k).check_number,
			P_instrument_security_code=> x_header_payment_tbl(k).instrument_security_code,
			P_X_trxn_extension_id	=> l_trxn_extension_id,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data);

			x_header_payment_tbl(k).credit_card_number := FND_API.G_MISS_CHAR;
			x_header_payment_tbl(k).credit_card_code := FND_API.G_MISS_CHAR;
			x_header_payment_tbl(k).credit_card_holder_name := FND_API.G_MISS_CHAR;
			x_header_payment_tbl(k).credit_card_expiration_date := FND_API.G_MISS_DATE;
			x_header_payment_tbl(k).check_number := FND_API.G_MISS_CHAR;
			x_header_payment_tbl(k).instrument_security_code := FND_API.G_MISS_CHAR;
			x_header_payment_tbl(k).trxn_extension_id := l_trxn_extension_id;
	END IF;*/
	--R12 CC Encryption
    END LOOP;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'Exiting OE_ORDER_COPY_UTIL.Load_and_Init_Hdr_Payments', 3) ;
  END IF;
END Load_and_Init_Hdr_Payments;


-- This function loads Line based holds into the action request table.
PROCEDURE Load_and_Init_line_Holds
(p_line_Id            IN Number
,p_new_line_id        IN Number
,p_action_request_tbl IN OUT NOCOPY OE_Order_PUB.Request_Tbl_Type)
IS
l_api_name              CONSTANT VARCHAR(30) := 'Load_and_Init_Line_Holds';
l_action_request_tbl    OE_Order_PUB.Request_Tbl_Type;
k                       NUMBER := 1;
l_hold_source_tbl       OE_Hold_Sources_PVT.Hold_Source_TBL;
l_return_status         VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_LINE_HOLDS' , 1 ) ;
     END IF;

     k := p_action_request_tbl.COUNT + 1;

     -- Load Order Based holds for Copying

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING OE_HOLD_SOURCES_PVT.Query_Line__Hold_Source' , 2 ) ;
     END IF;

     OE_HOLD_SOURCES_PVT.Query_Line__Hold_Source(p_line_id,
                                           l_hold_source_tbl,
                                           l_return_status);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('AFTER Query_Line__Hold_Source count '||l_hold_source_tbl.COUNT) ;
     END IF;

     IF (l_hold_source_tbl.COUNT > 0) THEN

        FOR curr in l_hold_source_tbl.FIRST .. l_hold_source_tbl.LAST LOOP
        -- copy only non seeded holds. Seeded holds are from 1 to 1000.
        -- only copy Order vbased source and holds

          IF  l_hold_source_tbl(curr).hold_entity_code = 'O'
	     AND l_hold_source_tbl(curr).hold_id >= 1000 THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'LOADING HOLD SOURCE '|| TO_CHAR ( L_HOLD_SOURCE_TBL ( CURR ) .HOLD_ID ) , 2 ) ;
                END IF;

              p_action_request_tbl(k).entity_code := OE_GLOBALS.G_ENTITY_LINE;
              p_action_request_tbl(k).entity_id := p_new_line_id;
              p_action_request_tbl(k).request_type:= OE_Globals.G_APPLY_HOLD;
              p_action_request_tbl(k).param1 := l_hold_source_tbl(curr).hold_id;
              p_action_request_tbl(k).param2 := 'O';

              -- load other source fields
              p_action_request_tbl(k).param4 := l_hold_source_tbl(curr).hold_comment;
              p_action_request_tbl(k).date_param1 :=
                                    l_hold_source_tbl(curr).hold_until_date;

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'AFTER LOADING HOLD SOURCE DATE' , 3 ) ;
              END IF;

              -- load Hold source desc flex
              p_action_request_tbl(k).param10 := l_hold_source_tbl(curr).context;
              p_action_request_tbl(k).param11 := l_hold_source_tbl(curr).attribute1;
              p_action_request_tbl(k).param12 := l_hold_source_tbl(curr).attribute2;
              p_action_request_tbl(k).param13 := l_hold_source_tbl(curr).attribute3;
              p_action_request_tbl(k).param14 := l_hold_source_tbl(curr).attribute4;
              p_action_request_tbl(k).param15 := l_hold_source_tbl(curr).attribute5;
              p_action_request_tbl(k).param16 := l_hold_source_tbl(curr).attribute6;
              p_action_request_tbl(k).param17 := l_hold_source_tbl(curr).attribute7;
              p_action_request_tbl(k).param18 := l_hold_source_tbl(curr).attribute8;
              p_action_request_tbl(k).param19 := l_hold_source_tbl(curr).attribute9;
              p_action_request_tbl(k).param20 := l_hold_source_tbl(curr).attribute10;
              p_action_request_tbl(k).param21 := l_hold_source_tbl(curr).attribute11;
              p_action_request_tbl(k).param22 := l_hold_source_tbl(curr).attribute12;
              p_action_request_tbl(k).param23 := l_hold_source_tbl(curr).attribute13;
              p_action_request_tbl(k).param24 := l_hold_source_tbl(curr).attribute14;
              p_action_request_tbl(k).param25 := l_hold_source_tbl(curr).attribute15;

              -- Increment index
              k := k + 1;
          END IF; -- IF Order Based Source
        END LOOP;
     END IF; -- Table has records

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_LINE_HOLDS' , 1 ) ;
     END IF;


EXCEPTION

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN OTHERS' , 3 ) ;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_and_Init_Line_Holds;

-- This function processes the rows in the Lines table to handle configuration
-- issues when destination order type is RETURN.
-- It deletes rows for Included Items, Config items and options  when top model
-- record is passed in since Process ORder will re-explode them.
-- It converts rows for Included Items, Class items, Config items and options to
-- Standard line when the model item record is not passed in.
-- Delete Class items always.
-- This functions also deletes fully cancelled lines based on the flag.

Procedure Handle_Return_Lines
(  p_x_line_tbl 	IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
  ,p_incl_cancelled IN VARCHAR2
)
IS
l_line_tbl         OE_ORDER_PUB.Line_Tbl_Type;
l_line_out_tbl     OE_ORDER_PUB.Line_Tbl_Type;
l_api_name         CONSTANT VARCHAR2(30) := 'Handle_Return_Lines';
l_top_model_index  NUMBER;
k   			    NUMBER;
j                  NUMBER := 1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.HANDLE_RETURN_LINES ' , 1 ) ;
      END IF;

	 -- Initialize local table

      l_line_tbl := p_x_line_tbl;

      k := l_line_tbl.FIRST;
	 WHILE k IS NOT NULL LOOP
	 BEGIN

          -- RetroBill Fix
          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
              -- Do not copy RetroBill Line
              IF p_x_line_tbl(k).retrobill_request_id IS NOT NULL THEN
                 l_line_tbl.DELETE(k);
                 GOTO Excluded_cancelled_line;
              END IF;
          END IF;

          -- If Fully cancelled then delete if desired
          IF (l_line_tbl(k).cancelled_flag = 'Y') AND
             (p_incl_cancelled = FND_API.G_FALSE) THEN
             G_Canceled_Line_Deleted := TRUE;
             l_line_tbl.DELETE(k);
             GOTO Excluded_cancelled_line;

          END IF;

          -- If Model or Standard then do nothing.
          IF l_line_tbl(k).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
									 OE_GLOBALS.G_ITEM_MODEL) THEN

		   GOTO Leave_record_as_is;

          END IF;

          -- Config item gets copied over as Standard if parent is not
          -- passed in.  It gets deleted if parent is passed in since
          -- auto-create will recreate it as part of normal Order processing.
          -- Included item gets copied over as Standard if parent is not
	     -- passed in.  It gets deleted if parent is passed in since
	     -- Process Order will re-exploded based on Freeze date.

	     IF l_line_tbl(k).item_type_code IN
		   (OE_GLOBALS.G_ITEM_CONFIG,
		    OE_GLOBALS.G_ITEM_INCLUDED,
		    OE_GLOBALS.G_ITEM_OPTION) THEN

           -- Find if Parent Line has been passed In
              IF l_line_tbl(k).top_model_line_id IS NOT NULL THEN
                 l_top_model_index := Find_LineIndex(l_line_tbl,
									 l_line_tbl(k).top_model_line_id);
                 IF l_top_model_index = FND_API.G_MISS_NUM THEN
                    l_line_tbl(k).item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
                    GOTO Leave_record_as_is;
                 END IF;
              END IF;

             -- delete row since auto-create/explode incl will
		   -- recreate it as part of normal Order processing.

                l_line_tbl.DELETE(k);
                GOTO Leave_record_as_is;
          END IF; -- End Included, Option  or Config Item

		-- Delete class lines.
	     IF l_line_tbl(k).item_type_code  = OE_GLOBALS.G_ITEM_CLASS THEN

		   l_line_tbl.DELETE(k);
             GOTO Leave_record_as_is;

	     END IF;

          -- Delete Service Line if the Line category is Return
		-- Delete service lines.
	     IF l_line_tbl(k).item_type_code  = OE_GLOBALS.G_ITEM_SERVICE THEN
	        l_line_tbl.DELETE(k);
             GOTO Leave_record_as_is;
	     END IF;

/* Following If condition added to fix the bug 2012594 */
             IF (l_line_tbl(k).item_type_code  = OE_GLOBALS.G_ITEM_KIT) AND
                (l_line_tbl(k).top_model_line_id IS NOT NULL) AND
                (l_line_tbl(k).top_model_line_id <>l_line_tbl(k).line_id) THEN
                 l_top_model_index := Find_LineIndex(l_line_tbl,l_line_tbl(k).top_model_line_id);
                 IF l_top_model_index <> FND_API.G_MISS_NUM THEN

                    l_line_tbl.DELETE(k);
                    GOTO Leave_record_as_is;
                 END IF;
             END IF;


          <<Leave_record_as_is>>  -- For Model And standard
          <<Excluded_cancelled_line>>  -- For fully cancelled lines
          NULL;
	 END;

	   IF l_line_tbl.EXISTS(k) THEN

	      l_line_out_tbl(j) := l_line_tbl(k);
	      j := j + 1;

	   END IF;

	   k := l_line_tbl.NEXT(k);
      END LOOP;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exiting OE_ORDER_COPY_UTIL.HANDLE_RETURN_LINES',1);
      END IF;

	 p_x_line_tbl := l_line_out_tbl;

END Handle_Return_Lines;

-- This function processes the rows in the Lines table to handle configuration issues
-- It deletes rows for Included Items, since Process ORder will re-explode them.
-- It also changes the item-type code of options and classes if any of
-- the parent lines have not been passed in.

--CHANGE RECORD:
--MACD: as per ver 4.9 of HLD, the copy validations for lines
--holding container models are moved to this API

--bug3441056 start
--display message only for top container model
--so that when a header level copy is done, multiple msgs
--are not displayed.  This is not applicable for a line level copy
--Also, dont raise exception
--bcoz non container model lines should not fail copy

--For bug 3923574, we added new parameter x_top_model_tbl to mark the
-- has_canceled_flag on the model.

Procedure Handle_NonStandard_Lines
(  p_x_line_tbl 	IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
  ,p_incl_cancelled IN VARCHAR2
  ,x_top_model_tbl  IN OUT NOCOPY Top_Model_Tbl_Type
)
IS
l_line_tbl         OE_ORDER_PUB.Line_Tbl_Type;
l_line_out_tbl     OE_ORDER_PUB.Line_Tbl_Type;
l_api_name         CONSTANT VARCHAR2(30) := 'Handle_NonStandard_Lines';
l_top_model_index  NUMBER;
l_link_to_index    NUMBER;
l_service_index    NUMBER;
k                  NUMBER;
j                  NUMBER := 1;
--
l_top_container_model VARCHAR2(1);
l_part_of_container   VARCHAR2(1);
l_config_mode         NUMBER;
l_ret_status          VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_top NUMBER;
idx   NUMBER;
BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.HANDLE_NONSTANDARD_LINES ' , 1 ) ;
      END IF;
      --ER 2264774
      --Load PRG lines in memory, it will used
      --for matching during line processing.
      --During line processing, we do not copy it is a PRG line
      IF G_LINE_PRICE_MODE IN (G_CPY_REPRICE,G_CPY_REPRICE_WITH_ORIG_DATE) THEN
        OE_LINE_ADJ_UTIL.Set_PRG_Cache(p_header_id=>p_x_line_tbl(p_x_line_tbl.first).header_id);
      END IF;

	 -- Initialize local table

      l_line_tbl := p_x_line_tbl;

      k := l_line_tbl.FIRST;
	 WHILE k IS NOT NULL LOOP
	 BEGIN

          --Clear Indexes
          l_top_model_index  := FND_API.G_MISS_NUM;
          l_link_to_index    := FND_API.G_MISS_NUM;


          --MACD------------------------------------------------------

          IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('RowCount:'||l_line_tbl.COUNT,3);
                OE_DEBUG_PUB.Add('MACD-Copy Level is:'
                                ||G_ORDER_LEVEL_COPY,3);
             END IF;

             OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
             (  p_line_id              => l_line_tbl(k).line_id
               ,p_top_model_line_id    => l_line_tbl(k).top_model_line_id
               ,p_ato_line_id          => l_line_tbl(k).ato_line_id
               ,p_inventory_item_id    => NULL
               ,x_top_container_model  => l_top_container_model
               ,x_part_of_container    => l_part_of_container  );

             IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('Line ID:'||l_line_tbl(k).line_id,2);
		OE_DEBUG_PUB.Add('TopLine:'||l_line_tbl(k).top_model_line_id,2);
                OE_DEBUG_PUB.Add('Top Container:'||l_top_container_model,3);
                OE_DEBUG_PUB.Add('Part of Container:'||l_part_of_container,3);
             END IF;

             IF l_part_of_container = 'Y' THEN

                IF G_ORDER_LEVEL_COPY = 0 THEN

                   IF l_debug_level > 0 THEN
                      OE_DEBUG_PUB.Add('MACD:No line level copy allowed!',3);
                   END IF;

                   l_line_tbl.DELETE(k);
                   --bug3441056 start
                   FND_MESSAGE.SET_NAME('ONT','ONT_TSO_NO_LINE_COPY');
                   OE_MSG_PUB.Add;
                   --RAISE FND_API.G_EXC_ERROR;
                   --bug3441056 contd
                   GOTO OUT_OF_MACD_LOGIC;
                ELSIF G_ORDER_LEVEL_COPY = 1 THEN

                   IF l_line_tbl(k).booked_flag = 'Y' THEN
                      IF l_debug_level > 0 THEN
		         OE_DEBUG_PUB.Add('Order level copy, booked=Y',3);
			 OE_DEBUG_PUB.Add('Header:'||l_line_tbl(k).header_id,3);
			 OE_DEBUG_PUB.Add('TopLine:'||l_line_tbl(k).top_model_line_id,3);
			 OE_DEBUG_PUB.Add('LineID:'||l_line_tbl(k).line_id,3);
		      END IF;

		      OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode
		      (  p_top_model_line_id => l_line_tbl(k).top_model_line_id
		        ,p_line_id     => l_line_tbl(k).line_id
			,x_config_mode => l_config_mode
			,x_return_status => l_ret_status  );

                      IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
		         IF l_debug_level > 0 THEN
			    OE_DEBUG_PUB.Add('Error in Get_MACD_Action_Mode',3);
			 END IF;
	              END IF;

                      -- config mode of 4 indicates macd reconfig
		      IF l_config_mode = 4 THEN
		         IF l_debug_level > 0 THEN
			    OE_DEBUG_PUB.Add('Order is a reconfiguration!',2);
			 END IF;

			 l_line_tbl.DELETE(k);

			 IF l_top_container_model = 'Y' THEN
			    FND_MESSAGE.SET_NAME('ONT','ONT_TSO_NO_BOOKED_ORDER_COPY');
			    OE_MSG_PUB.Add;
			 END IF;

			 GOTO OUT_OF_MACD_LOGIC;
	              END IF;
		   END IF; --booked_flag  = Y
		END IF; --order level copy = 1
             END IF; --part of container = Y

        ELSE
          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('Not in 110510. No MACD Logic Executed!',3);
          END IF;
        END IF;
        --bug3441056 contd
        --this label has been moved with the rest of the labels
        /*
        << OUT_OF_MACD_LOGIC >>
                  NULL;
        */
        --bug3441056 contd
        --MACD------------------------------------------------------

          -- RetroBill Fix
          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
              -- Do not copy RetroBill Line
              IF p_x_line_tbl(k).retrobill_request_id IS NOT NULL THEN
                 l_line_tbl.DELETE(k);
                 GOTO Excluded_cancelled_line;
              END IF;
          END IF;

          --ER 2264774
	  IF OE_LINE_ADJ_UTIL.IS_PRG_LINE(p_x_line_tbl(k).line_id) THEN
	    IF G_LINE_PRICE_MODE IN (G_CPY_REPRICE,G_CPY_REPRICE_WITH_ORIG_DATE) THEN
              l_line_tbl.DELETE(k);
              GOTO Excluded_cancelled_line;
	    END IF;
	  END IF;

          -- If Fully cancelled then delete if desired
          IF (l_line_tbl(k).cancelled_flag = 'Y') AND
             (p_incl_cancelled = FND_API.G_FALSE) THEN
             G_Canceled_Line_Deleted := TRUE;
             l_line_tbl.DELETE(k);
             GOTO Excluded_cancelled_line;

          END IF;

          -- If Model or Standard  or KIT then do nothing.
          IF l_line_tbl(k).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
									 OE_GLOBALS.G_ITEM_MODEL,
									 OE_GLOBALS.G_ITEM_KIT) THEN

		   GOTO Leave_record_as_is;

          END IF;

		-- Delete options and class if remnant flag is true.

		IF l_line_tbl(k).model_remnant_flag = 'Y' THEN

             l_line_tbl.DELETE(k);
             GOTO Excluded_model_remnant_line;

		END IF;

          -- Config item gets copied over as Standard if parent is not
          -- passed in.  It gets deleted if parent is passed in since
          -- auto-create will recreate it as part of normal Order processing.
          -- Included item gets copied over as Standard if parent is not
	     -- passed in.  It gets deleted if parent is passed in since
	     -- Process Order will re-exploded based on Freeze date.

  	     IF l_line_tbl(k).item_type_code IN (OE_GLOBALS.G_ITEM_CONFIG,
									OE_GLOBALS.G_ITEM_INCLUDED) THEN


            -- Find if Link to Line has been passed in.

               IF l_line_tbl(k).link_to_line_id IS NOT NULL THEN
                  l_link_to_index := Find_LineIndex(l_line_tbl,l_line_tbl(k).link_to_line_id);
                  IF l_link_to_index = FND_API.G_MISS_NUM THEN

                     l_line_tbl(k).item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
                     l_line_tbl(k).option_number := NULL;
                     l_line_tbl(k).component_number := NULL;
                     l_line_tbl(k).split_from_line_id := NULL;
                     l_line_tbl(k).split_by := NULL;
                     GOTO Leave_record_as_is;

                  END IF;
               END IF;


           -- If Parent Line, ATO line and Link to Line have been passed in then
           -- delete row since auto-create/explode incl will recreate it as
		 -- part of normal Order processing.

                l_line_tbl.DELETE(k);
                GOTO Leave_record_as_is;
          END IF; -- End Included or Config Item

          -- Option gets copied over as such if parent is passed in
          -- else it gets converted to a Standard item.

          IF l_line_tbl(k).item_type_code = (OE_GLOBALS.G_ITEM_OPTION) THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  ' OPTION 1' || TO_CHAR ( L_LINE_TBL ( K ) .LINE_ID ) , 1 ) ;
             END IF;

	     -- Find if Parent Line has been passed In
	        IF l_line_tbl(k).top_model_line_id IS NOT NULL THEN
	           l_top_model_index := Find_LineIndex(l_line_tbl,
									l_line_tbl(k).top_model_line_id);

	           IF l_top_model_index = FND_API.G_MISS_NUM THEN

	              l_line_tbl(k).item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
                  l_line_tbl(k).option_number := NULL;
                  l_line_tbl(k).component_number := NULL;
                  l_line_tbl(k).split_from_line_id := NULL;
                  l_line_tbl(k).split_by := NULL;
	              GOTO Leave_record_as_is;

	           END IF;
	        END IF;

             -- Find if Link to Line has been passed in.
		  IF l_line_tbl(k).link_to_line_id IS NOT NULL THEN
		     l_link_to_index := Find_LineIndex(l_line_tbl,
								  	 l_line_tbl(k).link_to_line_id);

		     IF l_link_to_index = FND_API.G_MISS_NUM THEN

		        l_line_tbl(k).item_type_code := OE_GLOBALS.G_ITEM_STANDARD;
                  l_line_tbl(k).option_number := NULL;
                  l_line_tbl(k).component_number := NULL;
                  l_line_tbl(k).split_from_line_id := NULL;
                  l_line_tbl(k).split_by := NULL;
		        GOTO Leave_record_as_is;

               END IF;

	         END IF;

             -- Parent Line, Link to Line have been passed.
             -- Therefore we need to set the index columns.
             /* Start 3923574 */
             -- Top Model Line is present in the COPY selection
             -- Check if user has selected to copy canceled lines and
             -- there are canceled lines in the config.
             IF p_incl_cancelled = FND_API.G_TRUE AND
                l_line_tbl(k).cancelled_flag = 'Y' AND
                l_top_model_index IS NOT NULL
             THEN
                 -- Mark the top model
                 x_top_model_tbl(l_top_model_index).has_canceled_lines := 'Y';
             END IF;
             /* End 3923574 */

/* Populate indexes in the new table.

			oe_debug_pub.add('OPTION 3' || to_char(l_line_tbl(k).line_id));
              	l_line_tbl(k).top_model_line_index := l_top_model_index;
           	l_line_tbl(k).link_to_line_index := l_link_to_index;
*/
          END IF; --  Option

		-- Classes get copied over as such if the parent is passed in
		-- else it gets deleted(Classes cannot be conveted to STANDARD)

		IF l_line_tbl(k).item_type_code = (OE_GLOBALS.G_ITEM_CLASS) THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CLASS 1' || TO_CHAR ( L_LINE_TBL ( K ) .LINE_ID ) , 1 ) ;
         END IF;

	     -- Find if Parent Line has been passed In
	        IF l_line_tbl(k).top_model_line_id IS NOT NULL THEN
	           l_top_model_index := Find_LineIndex(l_line_tbl,
								  l_line_tbl(k).top_model_line_id);

	           IF l_top_model_index = FND_API.G_MISS_NUM THEN

		        -- Delete when top model is not passed in.
		        l_line_tbl.DELETE(K);
                  GOTO Leave_record_as_is;

	           END IF;
	        END IF;


             -- Find if Line to Line has been passed in.
		  IF l_line_tbl(k).link_to_line_id IS NOT NULL THEN
		     l_link_to_index := Find_LineIndex(l_line_tbl,
									   l_line_tbl(k).link_to_line_id);

		     IF l_link_to_index = FND_API.G_MISS_NUM THEN
		        l_line_tbl.DELETE(K);
                GOTO Leave_record_as_is;
             END IF;

           END IF;
           /* Start 3923574 */
           -- Top Model Line is present in the COPY selection
           -- Check if user has selected to copy canceled lines and
           -- there are canceled lines in the config.
           IF p_incl_cancelled = FND_API.G_TRUE AND
              l_line_tbl(k).cancelled_flag = 'Y' AND
              l_top_model_index IS NOT NULL
           THEN
               -- Mark the top model
               x_top_model_tbl(l_top_model_index).has_canceled_lines := 'Y';
           END IF;
           /* End 3923574 */

--           l_line_tbl(k).top_model_line_index := l_top_model_index;

   	     END IF; -- Class

-- For the Service Lines

		IF l_line_tbl(k).item_type_code = (OE_GLOBALS.G_ITEM_SERVICE) THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SERVICE ' || TO_CHAR ( L_LINE_TBL ( K ) .LINE_ID ) , 2 ) ;
            END IF;

	     -- Find if Parent Line has been passed In and Not a Customer Product
	        IF l_line_tbl(k).service_reference_line_id IS NOT NULL AND
                l_line_tbl(k).service_reference_type_code = 'ORDER' THEN

	           l_service_index :=
                    Find_LineIndex(l_line_tbl,
                                   l_line_tbl(k).service_reference_line_id);

	           IF l_service_index = FND_API.G_MISS_NUM THEN
			    l_line_tbl.delete(k);
                   GOTO Leave_record_as_is;
                ELSE
  				IF l_line_tbl(l_service_index).item_type_code =
						             (OE_GLOBALS.G_ITEM_CLASS) THEN

	        		  IF l_line_tbl(l_service_index).top_model_line_id
                                                         IS NOT NULL THEN

			          l_top_model_index := Find_LineIndex(l_line_tbl,
                                l_line_tbl(l_service_index).top_model_line_id);

	    			       IF l_top_model_index = FND_API.G_MISS_NUM THEN

                              -- Delete when top model is not passed in.
                              l_line_tbl.DELETE(K);
                			GOTO Leave_record_as_is;

	          		 END IF;
                      END IF; -- top_model_line_id not null
                    END IF; -- CLASS

                    GOTO Leave_record_as_is;

                END IF; -- l_service_index = FND_API.G_MISS_NUM
             END IF; -- l_line_tbl(k).service_reference_line_id is not null

             GOTO Leave_record_as_is; -- No Parent for the Customer Product
          END IF;  -- Service

          <<Leave_record_as_is>>  -- For Model And standard
          <<Excluded_cancelled_line>>  -- For fully cancelled lines
          <<Excluded_model_remnant_line>> -- For model remnant lines.
          --bug3441056 contd
          << OUT_OF_MACD_LOGIC >>
          --bug3441056 end
	     NULL;
      END;

	   IF l_line_tbl.EXISTS(k) THEN
              IF l_debug_level > 0 THEN
	         OE_DEBUG_PUB.Add('Adding to Out tbl:'||l_line_tbl(k).line_id);
	      END IF;
	      l_line_out_tbl(j) := l_line_tbl(k);
	      j := j + 1;

	   END IF;

	   k := l_line_tbl.NEXT(k);
      END LOOP;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Exiting OE_ORDER_COPY_UTIL.HANDLE_NONSTANDARD_LINES ',1);
      END IF;
      p_x_line_tbl := l_line_out_tbl;

      --ER 2264774
      OE_LINE_ADJ_UTIL.RESET_PRG_CACHE;

END Handle_NonStandard_Lines;

Procedure Load_Lines
( p_num_lines      IN NUMBER
 ,p_line_id_tbl    IN OE_GLOBALS.Selected_Record_Tbl
 ,p_all_lines      IN VARCHAR2
 ,p_incl_cancelled IN VARCHAR2
 ,p_header_id      IN NUMBER
 ,p_hdr_type_id    IN NUMBER
 ,p_line_type_id   IN NUMBER
 ,p_version_number IN NUMBER
 ,p_phase_change_flag IN VARCHAR2
 ,x_line_tbl       IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
/* Added the following line to fix the bug 1923460 */
 ,x_top_model_tbl  IN OUT NOCOPY Top_Model_Tbl_Type
)
IS
 l_top_model_index           NUMBER;
 l_line_id                   OE_Order_LINES.Line_id%Type;
 l_cpy_category  		    VARCHAR2(30);
 l_line_category  		    VARCHAR2(30);
 l_line_rec                  OE_Order_PUB.Line_Rec_Type;

 l_api_name                  CONSTANT VARCHAR(30) := 'Load_Lines';

/* Start - Code added for the bug 1923460 */

 out_config_hdr_id         NUMBER;
 out_config_rev_nbr        NUMBER;
 l_error_message           VARCHAR2(100);
 l_return_value            NUMBER;
 l_dynamicSqlString        VARCHAR2(2000);
 l_new_config_flag         VARCHAR2(1)   :=NULL;
 l_handle_deleted_flag     VARCHAR2(1)   :=NULL;
 l_new_name                VARCHAR2(1000):=NULL;
/* End - Code added for the bug 1923460 */

  l_orig_item_id_tbl       CZ_API_PUB.number_tbl_type;
  l_new_item_id_tbl        CZ_API_PUB.number_tbl_type;

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);
  K                        NUMBER;
  J                        NUMBER;
  l_in_config_header_id    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --

  l_part_of_container      VARCHAR2(1);
  l_top_container_model    VARCHAR2(1);

BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.LOAD_LINES' , 1 ) ;
        oe_debug_pub.add('p_all_lines is ' || p_all_lines , 1 ) ;
    END IF;

    IF p_hdr_type_id IS NOT NULL THEN
       l_cpy_category := get_order_category(p_hdr_type_id);
    END IF;

    IF p_line_type_id IS NOT NULL THEN
	  l_line_category := get_line_category(p_line_type_id);
    END If;

    IF FND_API.to_Boolean(p_all_lines) THEN
        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
            OE_Version_History_UTIL.query_rows(
                                p_line_id => NULL
                               ,p_header_id => p_header_id
                               ,p_line_set_id => NULL
                               ,p_version_number => p_version_number
                               ,p_phase_change_flag => p_phase_change_flag
                               ,x_line_tbl  => x_line_tbl);
        ELSE
            OE_LINE_UTIL.query_rows(p_header_id => p_header_id
                                   ,x_line_tbl  => x_line_tbl);
        END IF;

    ELSIF p_num_lines > 0 THEN

        sort_line_tbl(p_line_id_tbl,
                       p_version_number,
                       p_phase_change_flag,
                       p_num_lines,
                       x_line_tbl);

    END IF; -- If All Lines


    -- Handle Configurations
    IF x_line_tbl.count > 0 THEN

       -- Fix for bug1959957
        FOR i IN x_line_tbl.FIRST .. x_line_tbl.LAST LOOP
            IF (x_line_tbl(i).line_category_code = 'RETURN') THEN
                x_line_tbl(i).reference_line_id := NULL;
                x_line_tbl(i).return_attribute2 := NULL;
                x_line_tbl(i).return_attribute1 := NULL;
                x_line_tbl(i).reference_header_id := NULL;
                x_line_tbl(i).reference_type := NULL;
                x_line_tbl(i).return_context := NULL;
            END IF;
        END LOOP;

	    IF (l_cpy_category = 'RETURN' OR
		    l_line_category = 'RETURN') THEN  -- When Destination is return.

	       Handle_Return_Lines(x_line_tbl, p_incl_cancelled);

	    ELSE -- When the destination is Mixed or Order.


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CALLING HANDLE_NONSTANDARD_LINES' , 1 ) ;
           END IF;
            /* Start 3923574 */
            Handle_NonStandard_Lines(x_line_tbl
                                     ,p_incl_cancelled
                                     ,x_top_model_tbl);
            /* Start 3923574 */

           --  Set  top_model_index for options  and classes.

           IF x_line_tbl.count > 0 THEN
	          FOR I in x_line_tbl.FIRST .. x_line_tbl.LAST LOOP

                  l_top_model_index := FND_API.G_MISS_NUM;

                 IF x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_OPTION
	             OR x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_CLASS THEN


                     l_top_model_index := Find_LineIndex(x_line_tbl,
                                          x_line_tbl(I).top_model_line_id);
                     x_line_tbl(I).top_model_line_index := l_top_model_index;

                 ELSIF x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_KIT
                 THEN

		            IF  x_line_tbl(I).top_model_line_id <> x_line_tbl(I).line_id                    THEN

                        l_top_model_index := Find_LineIndex(x_line_tbl,
                                             x_line_tbl(I).top_model_line_id);
                        x_line_tbl(I).top_model_line_index := l_top_model_index;

	                END IF;

                -- ## fixed as a prt of 1826688, however we need to always
                -- populate the top_model_line_index on the model line,
                -- irrespective of this bug fix.

                ELSIF x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_MODEL
                THEN
                    x_line_tbl(I).top_model_line_index := I;

                    /* Start 3923574 */
                    IF NOT x_top_model_tbl.EXISTS(I) THEN
                        x_top_model_tbl(I).has_canceled_lines := 'N';
                    END IF;
                    /* End 3923574 */

/* Start - Code for bug 1923460 */
                  -- For fixing the Line Level Config COPY 3508387
                  --  IF G_ORDER_LEVEL_COPY = 1 AND
                  /* Start 3923574 */
                  -- Added extra condition to check if Model has canceled lines
                  -- selected for copy. If true then do not call CZ api.
                  /* End 3923574 */
                    IF G_COPY_REC.copy_complete_config = FND_API.G_TRUE AND
                       x_line_tbl(I).config_header_id IS NOT NULL AND
                       x_line_tbl(I).config_rev_nbr IS NOT NULL AND
                       x_line_tbl(I).cancelled_flag <> 'Y' AND
                       NVL(x_top_model_tbl(I).has_canceled_lines, 'N') = 'N'
                    THEN
                    IF OE_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('1923460: ABOUT TO RUN COPY CONFIGURATION' , 1 ) ;
                       END IF;

                       l_dynamicSqlString  := '
                       Begin
                       cz_cf_api.copy_configuration_auto(
                                             :config_hdr_id ,
                                             :config_rev_nbr,
                                             :new_config_flag,
                                             :out_config_hdr_id ,
                                             :out_config_rev_nbr,
                                             :Error_message     ,
                                             :Return_value      ,
                                             :handle_deleted_flag,
                                             :new_name);
                       end;';

                       EXECUTE IMMEDIATE l_dynamicSqlString
                       USING IN x_line_tbl(I).config_header_id,
                        IN x_line_tbl(I).config_rev_nbr,
                        IN l_new_config_flag,
                        IN OUT out_config_hdr_id,
                        IN OUT out_config_rev_nbr,
                        IN OUT l_Error_message,
                        IN OUT l_Return_value,
                        IN l_handle_deleted_flag,
                        IN l_new_name ;

                       IF (l_Return_value = 1) THEN
                           x_top_model_tbl(I).config_header_id :=
                                                             out_config_hdr_id;
                           x_top_model_tbl(I).config_rev_nbr :=
                                                            out_config_rev_nbr;
                           IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  '1923460: INDEX IS '
                                                        ||TO_CHAR ( I ) , 1 ) ;
                           oe_debug_pub.add(  '1923460: OUT_CONFIG_HEADER_ID
                                     IS '||TO_CHAR ( OUT_CONFIG_HDR_ID ) , 1 ) ;
                           oe_debug_pub.add(  '1923460: OUT_CONFIG_REV_NBR IS '
                                     ||TO_CHAR ( OUT_CONFIG_REV_NBR ) , 1 ) ;
                           END IF;
                       ELSE
                           IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  '1923460: FAILED IN COPY
                                                         CONFIGURATION' , 1 ) ;
                       END IF;
                   END IF;

                ELSE -- pack I onwards

                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'NEW COPY CONFIG API' , 1 ) ;
                  END IF;

                  l_in_config_header_id := x_line_tbl(I).config_header_id;

                  CZ_Config_API_Pub.copy_configuration_auto
                 ( p_api_version          => 1.0
                  ,p_config_hdr_id        => x_line_tbl(I).config_header_id
                  ,p_config_rev_nbr       => x_line_tbl(I).config_rev_nbr
                  ,p_copy_mode            => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                  ,x_config_hdr_id        => out_config_hdr_id
                  ,x_config_rev_nbr       => out_config_rev_nbr
                  ,x_orig_item_id_tbl     => l_orig_item_id_tbl
                  ,x_new_item_id_tbl      => l_new_item_id_tbl
                  ,x_return_status        => l_return_status
                  ,x_msg_count            => l_msg_count
                  ,x_msg_data             => l_msg_data);

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    OE_Msg_Pub.Add_Text(l_msg_data);
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'ERROR FROM NEW COPY: '
                                                  || L_MSG_DATA , 1 ) ;
                    END IF;
                  END IF;

                  K := I;

                  WHILE K is not null
                  LOOP

                    J := l_orig_item_id_tbl.FIRST;

                    WHILE J is not null
                    LOOP

                      IF x_line_tbl(K).config_header_id is not null AND
                         x_line_tbl(K).config_header_id = l_in_config_header_id
                      THEN
                        IF x_line_tbl(K).configuration_id =
                           l_orig_item_id_tbl(J) THEN

                           x_line_tbl(K).configuration_id
                           := l_new_item_id_tbl(J);

                           IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'OLD CONFIG '||
                                                L_ORIG_ITEM_ID_TBL ( J ) , 1 ) ;
                           END IF;
                           IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'NEW CONFIG '
                                    ||X_LINE_TBL ( K ) .CONFIGURATION_ID , 1 ) ;
                           END IF;
                           EXIT;
                        END IF;
                      END IF;

                      J := l_orig_item_id_tbl.NEXT(J);
                    END LOOP;

                    K := x_line_tbl.NEXT(K);
                  END LOOP;

                  IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('DONE UPDATING NEW CONFIG ITEM IDS',1);
                  END IF;

                  -- now set the new cofig hdr/rev on model.
                  -- is this table always populated??
                  x_top_model_tbl(I).config_header_id := out_config_hdr_id;
                  x_top_model_tbl(I).config_rev_nbr   := out_config_rev_nbr;

                END IF; -- pack I check
            END IF;
/* End - Code for bug 1923460 */

      --  Set  service line index for service lines.
          ELSIF x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_SERVICE
          THEN

             l_top_model_index := Find_LineIndex(x_line_tbl,
                                       x_line_tbl(I).service_reference_line_id);
             x_line_tbl(I).service_line_index := l_top_model_index;

          END IF;


          IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ITEM_TYPE_CODE IS'
                               ||X_LINE_TBL ( I ) .ITEM_TYPE_CODE , 1 ) ;
          oe_debug_pub.add(  'LINE ID IS'||X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
          oe_debug_pub.add(  'TOP_MODEL_LINE_INDEX IS '
                               ||TO_CHAR ( L_TOP_MODEL_INDEX ) , 1 ) ;
          END IF;
        END LOOP;
       END IF; -- IF x_line_tbl.count > 0
      END IF; -- IF (l_cpy_category = 'RETURN' OR

    END IF; -- IF x_line_tbl.count > 0

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.LOAD_LINES' , 1 ) ;
    END IF;


EXCEPTION

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN OTHERS LOAD LINES '|| sqlerrm , 1 ) ;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Load_Lines;

procedure Clear_Missing_Attributes(
              p_line_rec IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_line_rec.SERVICE_REFERENCE_TYPE_CODE IS NULL THEN
        p_line_rec.SERVICE_REFERENCE_TYPE_CODE :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.ORDERED_QUANTITY2 IS NULL THEN
        p_line_rec.ORDERED_QUANTITY2 :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.ORDERED_QUANTITY_UOM2 IS NULL THEN
        p_line_rec.ORDERED_QUANTITY_UOM2 :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.PREFERRED_GRADE IS NULL THEN
        p_line_rec.PREFERRED_GRADE :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.TAX_EXEMPT_FLAG  IS NULL THEN
        p_line_rec.TAX_EXEMPT_FLAG :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.TAX_EXEMPT_NUMBER IS NULL THEN
        p_line_rec.TAX_EXEMPT_NUMBER :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.PAYMENT_TERM_ID  IS NULL THEN
        p_line_rec.PAYMENT_TERM_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.PRICE_LIST_ID IS NULL THEN
        p_line_rec.PRICE_LIST_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.PRICING_DATE  IS NULL THEN
        p_line_rec.PRICING_DATE :=  FND_API.G_MISS_DATE;
    END IF;

    IF p_line_rec.REQUEST_DATE  IS NULL THEN
        p_line_rec.REQUEST_DATE :=  FND_API.G_MISS_DATE;
    END IF;

    IF p_line_rec.RETURN_REASON_CODE IS NULL THEN
        p_line_rec.RETURN_REASON_CODE :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.SHIPPING_METHOD_CODE  IS NULL THEN
        p_line_rec.SHIPPING_METHOD_CODE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.SHIP_FROM_ORG_ID  IS NULL THEN
        p_line_rec.SHIP_FROM_ORG_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SHIP_TOLERANCE_ABOVE  IS NULL THEN
        p_line_rec.SHIP_TOLERANCE_ABOVE  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SHIP_TO_CONTACT_ID IS NULL THEN
        p_line_rec.SHIP_TO_CONTACT_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SOLD_TO_ORG_ID IS NULL THEN
        p_line_rec.SOLD_TO_ORG_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SOURCE_TYPE_CODE  IS NULL THEN
        p_line_rec.SOURCE_TYPE_CODE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.TAX_CODE IS NULL THEN
        p_line_rec.TAX_CODE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.INVOICE_TO_CONTACT_ID  IS NULL THEN
        p_line_rec.INVOICE_TO_CONTACT_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.INVOICING_RULE_ID  IS NULL THEN
        p_line_rec.INVOICING_RULE_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.ITEM_REVISION   IS NULL THEN
        p_line_rec.ITEM_REVISION :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.ORDERED_QUANTITY  IS NULL THEN
        p_line_rec.ORDERED_QUANTITY :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.ORDER_QUANTITY_UOM  IS NULL THEN
        p_line_rec.ORDER_QUANTITY_UOM  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.SUBINVENTORY  IS NULL THEN
        p_line_rec.SUBINVENTORY :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.AGREEMENT_ID  IS NULL THEN
        p_line_rec.AGREEMENT_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.CUST_PO_NUMBER  IS NULL THEN
        p_line_rec.CUST_PO_NUMBER  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.DELIVER_TO_ORG_ID  IS NULL THEN
        p_line_rec.DELIVER_TO_ORG_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.FOB_POINT_CODE IS NULL THEN
        p_line_rec.FOB_POINT_CODE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.SALESREP_ID  IS NULL THEN
        p_line_rec.SALESREP_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SHIPMENT_PRIORITY_CODE  IS NULL THEN
        p_line_rec.SHIPMENT_PRIORITY_CODE :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.SHIP_TO_ORG_ID  IS NULL THEN
        p_line_rec.SHIP_TO_ORG_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.ACCOUNTING_RULE_ID  IS NULL THEN
        p_line_rec.ACCOUNTING_RULE_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.DELIVER_TO_CONTACT_ID  IS NULL THEN
        p_line_rec.DELIVER_TO_CONTACT_ID  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.DEMAND_CLASS_CODE  IS NULL THEN
        p_line_rec.DEMAND_CLASS_CODE :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.FREIGHT_TERMS_CODE  IS NULL THEN
        p_line_rec.FREIGHT_TERMS_CODE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.INVOICE_TO_ORG_ID  IS NULL THEN
        p_line_rec.INVOICE_TO_ORG_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SHIP_TOLERANCE_BELOW  IS NULL THEN
        p_line_rec.SHIP_TOLERANCE_BELOW  :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.ITEM_IDENTIFIER_TYPE  IS NULL THEN
        p_line_rec.ITEM_IDENTIFIER_TYPE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.CALCULATE_PRICE_FLAG  IS NULL THEN
        p_line_rec.CALCULATE_PRICE_FLAG  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.LINE_TYPE_ID  IS NULL THEN
        p_line_rec.LINE_TYPE_ID :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_line_rec.SERVICE_PERIOD  IS NULL THEN
        p_line_rec.SERVICE_PERIOD  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.SERVICE_START_DATE  IS NULL THEN
        p_line_rec.SERVICE_START_DATE  :=  FND_API.G_MISS_DATE;
    END IF;

    IF p_line_rec.TAX_EXEMPT_REASON_CODE  IS NULL THEN
        p_line_rec.TAX_EXEMPT_REASON_CODE  :=  FND_API.G_MISS_CHAR;
    END IF;

    IF p_line_rec.COMMITMENT_ID IS NULL THEN
        p_line_rec.COMMITMENT_ID :=  FND_API.G_MISS_NUM;
    END IF;

END Clear_Missing_Attributes;

Procedure Init_Lines_New
( p_x_line_tbl         IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
 ,p_x_top_model_tbl    IN OUT NOCOPY Top_Model_Tbl_Type
 ,p_line_type          IN NUMBER
 ,p_header_id          IN NUMBER
 ,p_line_price_mode    IN NUMBER
 ,p_line_price_date    IN DATE
 ,p_line_descflex      IN VARCHAR2
 ,p_create_rma         IN VARCHAR2 := FND_API.G_FALSE
 ,p_return_reason_code IN VARCHAR2
 ,p_default_null_values IN VARCHAR2
 ,p_reason_code        IN VARCHAR2
 ,p_comments           IN VARCHAR2
 ,p_copy_rec           IN COPY_REC_TYPE
 ,p_action_request_tbl IN OUT NOCOPY OE_Order_PUB.Request_Tbl_Type
)
IS
 l_api_name           CONSTANT VARCHAR2(30) := 'Init_Lines_New';
 l_temp_line_rec      OE_ORDER_PUB.Line_Rec_Type;
 l_orig_line_category VARCHAR2(30);
 l_cpy_line_category  VARCHAR2(30);
 l_order_number       NUMBER;
 l_order_type_id      NUMBER;
 l_version_number     NUMBER;
 l_rma_to_reg         VARCHAR2(1) := FND_API.G_FALSE;
 l_reg_to_rma         VARCHAR2(1) := FND_API.G_FALSE;
 k 		            NUMBER;
 l_top_model_line_index NUMBER;
 j                    BINARY_INTEGER;
/* Added the following 3 variables to fix the bug 2400441 */
 l_max_line_no        NUMBER;
 l_total_lines        NUMBER;
 l_copying_all_lines  VARCHAR2(3);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 l_line_set_tbl       Line_Set_Tbl_Type;
 l_count              NUMBER;
 l_index              NUMBER;
 l_parent_found       BOOLEAN := FALSE;
 l_operation          VARCHAR2(30);
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.INIT_LINES_NEW' , 1 ) ;
     END IF;

     IF p_line_type IS NOT NULL THEN -- If Returns is calling us then this is NULL.
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' GET LINE CATEGORY ' , 1 ) ;
         END IF;
         l_cpy_line_category := Get_Line_Category(p_line_type);
     END IF;

     -- Delete all records from G_Line_Num_Rec
     DELETE_TBL;

     -- Set the counter for global rec
     j := 0;

     IF p_x_line_tbl.COUNT > 0 THEN

       -- Allocate memory to the Global Line Number rec.
       EXTEND_TBL(p_x_line_tbl.COUNT);

       k := p_x_line_tbl.FIRST;
       WHILE k IS NOT NULL LOOP
	   BEGIN

         -- Load Temporary Line Record to be used for setting various values
         -- Doing so removes dependency on the Order in which we clear attributes.

           l_temp_line_rec := p_x_line_tbl(k);


           -- Populate the Global Line Number record
           j := j + 1;

           G_Line_Num_Rec.line_id(J) := p_x_line_tbl(k).line_id;
           G_Line_Num_Rec.line_number(J) := p_x_line_tbl(k).line_number;
           G_Line_Num_Rec.shipment_number(J) := p_x_line_tbl(k).shipment_number;
           G_Line_Num_Rec.option_number(J) := p_x_line_tbl(k).option_number;
           G_Line_Num_Rec.component_number(J) := p_x_line_tbl(k).component_number;
           G_Line_Num_Rec.service_number(J) := p_x_line_tbl(k).service_number;
           G_Line_Num_Rec.split_from_line_id(J) := p_x_line_tbl(k).split_from_line_id;

           -- Find the Split_from_line_id from pre-populated line_ids
           IF G_Line_Num_Rec.split_from_line_id(J) IS NOT NULL AND
              J > 1 THEN

               G_Order_Has_Split_Lines := TRUE;

               -- Find out the Split_from_line_id from G_Line_Num_Rec;
               FOR m in 1..J LOOP
                   IF G_Line_Num_Rec.line_id(m) =
                      G_Line_Num_Rec.split_from_line_id(J)
                   THEN
                       G_Line_Num_Rec.split_from_line_id(J) :=
                                               G_Line_Num_Rec.new_line_id(m);
                       G_Line_Num_Rec.split_by(J) := 'USER';
		       IF l_debug_level  > 0 THEN
		           oe_debug_pub.add(  'FOUND THE SPLIT_FROM '||G_LINE_NUM_REC.NEW_LINE_ID ( M ) , 1 ) ;
		       END IF;
                       EXIT;
                   END IF;

               END LOOP;

           END IF;

          -- Set Boolean to handle Return Lines
          -- If Returns is calling us then p_create_rma will be set to
          -- 'T' else the default is 'F'.
          l_reg_to_rma := p_create_rma;

          -- Check if the Line Category is RETURN

          IF Get_line_category(NVL(p_line_type,l_temp_line_rec.line_type_id)) =
             'RETURN' AND p_return_reason_code IS NOT NULL
          THEN
               p_x_line_tbl(k).return_reason_code := p_return_reason_code;
          END IF;

          -- Get the line category for the source line
          l_orig_line_category := Get_line_category(l_temp_line_rec.line_type_id);
          -- Check If we are changing Line Type

          IF p_line_type IS NOT NULL THEN -- IF return is calling us then this will be null.
             p_x_line_tbl(k).line_type_id := p_line_type;
             IF p_line_type <> l_temp_line_rec.line_type_id THEN

                 IF l_debug_level  > 0 THEN
oe_debug_pub.add(  'AK :COPY LINE CAT ' || L_CPY_LINE_CATEGORY , 2 ) ;
oe_debug_pub.add(  'AK :ORIG LINE CAT ' || L_ORIG_LINE_CATEGORY , 2 ) ;
                 END IF;
                 -- If we are copying from a non-return to a return type
                 IF (l_orig_line_category = 'ORDER') AND
                    (l_cpy_line_category = 'RETURN') THEN
                     l_reg_to_rma := FND_API.G_TRUE;
                     l_operation := 'ORDER_TO_RETURN';
                 ELSIF (l_orig_line_category = 'RETURN') AND
                       (l_cpy_line_category = 'ORDER') THEN
                     l_rma_to_reg := FND_API.G_TRUE;
                     l_operation := 'RETURN_TO_ORDER';
                 END IF;
             END IF;
          ELSE -- IF p_line_type IS NULL

              IF l_orig_line_category = 'ORDER'  THEN
                  l_operation := 'ORDER_TO_ORDER';
              ELSE
                  l_operation := 'RETURN_TO_RETURN';
              END IF;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'IF REG TO RET'||L_REG_TO_RMA , 1 ) ;
          END IF;


           -- Init various columns
           -- OE_DEBUG_PUB.ADD('Init various Cols');
           -- Set Date, Time, who columns

           p_x_line_tbl(k).creation_date          := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).created_by             := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).last_update_date       := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).last_updated_by        := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).last_update_login      := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).program_application_id := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).program_id             := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).request_id             := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).program_update_date    := FND_API.G_MISS_DATE;

	   if p_x_line_tbl(k).ACCOUNTING_RULE_ID is null then  -- added for Bug 6519067
	      p_x_line_tbl(k).ACCOUNTING_RULE_ID     :=  FND_API.G_MISS_NUM;  -- added for Bug 6519067
           end if;

           -- Clear Transaction Phase for New Lines
           IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
              p_x_line_tbl(k).transaction_phase_code    := FND_API.G_MISS_CHAR;

              IF p_reason_code IS NOT NULL THEN
                  p_x_line_tbl(k).change_reason := p_reason_code;
              END IF;

              IF p_comments IS NOT NULL THEN
                  p_x_line_tbl(k).change_comments := p_comments;
              END IF;

              -- Copy the Source Version Number..
              p_x_line_tbl(k).SOURCE_DOCUMENT_VERSION_NUMBER := G_LN_VER_NUMBER;

           END IF;

/* Start - code added for bug 1923460 */

           l_top_model_line_index                 := p_x_line_tbl(k).top_model_line_index;

           -- Added the check for FND_API.G_MISS_NUM to avoid the numeric
           -- overflow as reported in bug 3640804

           IF l_top_model_line_index IS NOT NULL and
              l_top_model_line_index <>  FND_API.G_MISS_NUM
           THEN
               IF p_x_top_model_tbl.EXISTS(l_top_model_line_index) THEN
                 IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  '1923460: IN INIT_LINES , MODEL_INDEX IS '||TO_CHAR ( L_TOP_MODEL_LINE_INDEX ) , 1 ) ;
                 oe_debug_pub.add(  '1923460: IN INIT_LINES , CONFIG_HEADER_ID IS '||TO_CHAR ( P_X_TOP_MODEL_TBL ( L_TOP_MODEL_LINE_INDEX ) .CONFIG_HEADER_ID ) , 1 ) ;
                 oe_debug_pub.add(  '1923460: IN INIT_LINES , CONFIG_REV_NBR IS '||TO_CHAR ( P_X_TOP_MODEL_TBL ( L_TOP_MODEL_LINE_INDEX ) .CONFIG_REV_NBR ) , 1 ) ;
                 END IF;
                 p_x_line_tbl(k).config_header_id
                 := p_x_top_model_tbl(l_top_model_line_index).config_header_id;
                 p_x_line_tbl(k).config_rev_nbr
                 := p_x_top_model_tbl(l_top_model_line_index).config_rev_nbr;
               ELSE
                 p_x_line_tbl(k).config_header_id  := NULL;
                 p_x_line_tbl(k).config_rev_nbr    := NULL;
               END IF;
           ELSE
             p_x_line_tbl(k).config_header_id  := NULL;
             p_x_line_tbl(k).config_rev_nbr    := NULL;
           END IF;

/* End - code added for bug 1923460 */

/* Added the following code to null out nocopy acknowledgement related fields in the order header , to fix the bug 1862719 */


           p_x_line_tbl(k).first_ack_code := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).first_ack_date := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).last_ack_code  := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).last_ack_date  := FND_API.G_MISS_DATE;

/* End of code added to fix the bug 1862719 */

            -- Set foreign keys
           p_x_line_tbl(k).header_id := FND_API.G_MISS_NUM;

           -- Pre-populate the line_id to load G_Line_Num_Rec
           SELECT  OE_ORDER_LINES_S.NEXTVAL
           INTO p_x_line_tbl(k).line_id
           FROM dual;
           G_Line_Num_Rec.new_line_id(J) := p_x_line_tbl(k).line_id;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NEW LINE ID IS '||P_X_LINE_TBL ( K ) .LINE_ID , 1 ) ;
           END IF;

           -- Load line level holds for this line
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('The COPy Line Level HOLDS '||p_copy_rec.line_holds);
              oe_debug_pub.add('REG to RMA '||l_reg_to_rma);
              oe_debug_pub.add('RMA to REG '||l_rma_to_reg);
           END IF;

           IF p_copy_rec.line_holds = FND_API.G_TRUE AND
              l_reg_to_rma = FND_API.G_FALSE AND
              l_rma_to_reg = FND_API.G_FALSE
           THEN
               Load_and_Init_line_Holds(
                     p_line_Id => l_temp_line_rec.line_id ,
                     p_new_line_id => p_x_line_tbl(k).line_id ,
                     p_action_request_tbl => p_action_request_tbl
                     );
           END IF;


           -- Adding logic to check if the line is a part of the Split Set.

           IF p_x_line_tbl(k).SPLIT_BY IS NOT NULL AND
              NOT (FND_API.to_Boolean(l_reg_to_rma) OR
                   FND_API.to_Boolean(l_rma_to_reg))
           THEN

               l_parent_found := FALSE;

               IF l_line_set_tbl.COUNT > 0
               AND G_Line_Num_Rec.split_by(J) IS NOT NULL --Added for bug 5199676
               THEN

                   FOR x IN 1..l_line_set_tbl.COUNT LOOP

                       IF l_line_set_tbl(x).old_set_id =
                          p_x_line_tbl(k).line_set_id
                       THEN

                           IF l_line_set_tbl(x).set_count = 1 AND
                              l_line_set_tbl(x).line_set_id IS NULL
                           THEN
                               SELECT OE_SETS_S.NEXTVAL
                               INTO l_line_set_tbl(x).line_set_id
                               FROM   DUAL;
                               l_index := l_line_set_tbl(x).line_index;
                               p_x_line_tbl(l_index).line_set_id :=
                                                  l_line_set_tbl(x).line_set_id;
                           END IF;
                           p_x_line_tbl(k).line_set_id :=
                                                  l_line_set_tbl(x).line_set_id;
                           l_line_set_tbl(x).set_count :=
                                               l_line_set_tbl(x).set_count + 1;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Line Set Id is'||P_X_LINE_TBL( K ).line_set_id , 1 ) ;
             END IF;
                           l_parent_found := TRUE;
                           EXIT;
                       END IF;

                   END LOOP;

               END IF; -- IF l_line_set_tbl.COUNT > 0 THEN

               IF NOT l_parent_found THEN
                   l_count := l_line_set_tbl.COUNT;
                   l_line_set_tbl(l_count+1).line_id := p_x_line_tbl(k).line_id;
                   l_line_set_tbl(l_count+1).old_line_id :=
                                                     G_Line_Num_Rec.line_id(J);
                   l_line_set_tbl(l_count+1).header_id := p_header_id;
                   l_line_set_tbl(l_count+1).line_type_id :=
                                                  p_x_line_tbl(k).line_type_id;
                   l_line_set_tbl(l_count+1).set_count := 1;
                   l_line_set_tbl(l_count+1).old_set_id :=
                                                    p_x_line_tbl(k).line_set_id;
                   l_line_set_tbl(l_count+1).line_set_id := NULL;
                   l_line_set_tbl(l_count+1).line_index := k;
                   p_x_line_tbl(k).line_set_id := NULL;
                   G_Line_Num_Rec.split_from_line_id(j) := NULL;
               END IF;

           END IF;

           p_x_line_tbl(k).commitment_id := FND_API.G_MISS_NUM;

           p_x_line_tbl(k).line_number := FND_API.G_MISS_NUM;
    	   p_x_line_tbl(k).top_model_line_id := FND_API.G_MISS_NUM;
	       p_x_line_tbl(k).link_to_line_id := FND_API.G_MISS_NUM;

           IF
     ---- G_ORDER_LEVEL_COPY = 1 AND bug# 7436888 ,8439061
             OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
             p_x_line_tbl(k).config_header_id is not NULL AND
             p_x_line_tbl(k).config_header_id <> FND_API.G_MISS_NUM AND
             p_x_line_tbl(k).cancelled_flag <> 'Y'
           THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'COPY: PACK H NEW LOGIC MI '||P_X_LINE_TBL ( K ) .CONFIGURATION_ID , 1 ) ;
             END IF;
           ELSE
	           p_x_line_tbl(k).configuration_id := FND_API.G_MISS_NUM;
           END IF;

           -- Added following logic to retain split info.
           IF p_x_line_tbl(k).split_by IS NULL THEN
               p_x_line_tbl(k).line_set_id := FND_API.G_MISS_NUM;
           END IF;

           p_x_line_tbl(k).split_from_line_id := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).shipment_number := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).option_number   := FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).ato_line_id     := FND_API.G_MISS_NUM;

            -- Status flags
           p_x_line_tbl(k).booked_flag     := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).cancelled_flag  := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).open_flag       := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).shipping_interfaced_flag :=  FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).invoice_interface_status_code := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).model_remnant_flag := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).flow_status_code := 'ENTERED';
		   p_x_line_tbl(k).fulfilled_flag := FND_API.G_MISS_CHAR;

           -- Added this line to initialize ship_model_complete_flag
           -- to 'NULL'. Refer Bug1864983
           p_x_line_tbl(k).ship_model_complete_flag := FND_API.G_MISS_CHAR;

           -- Set ordered_qty to cancelled lines for fully cancelled lines
           IF l_temp_line_rec.cancelled_flag = 'Y' THEN
              p_x_line_tbl(k).ordered_quantity :=
                                         l_temp_line_rec.cancelled_quantity;
              p_x_line_tbl(k).config_header_id  := NULL;
              p_x_line_tbl(k).config_rev_nbr    := NULL;
           END IF;

            -- Various quantities
           p_x_line_tbl(k).cancelled_quantity := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).reserved_quantity  := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).fulfilled_quantity := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).shipped_quantity   := FND_API.G_MISS_NUM;

					 -- INVCONV
           p_x_line_tbl(k).cancelled_quantity2 := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).reserved_quantity2  := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).fulfilled_quantity2 := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).shipped_quantity2   := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).shipping_quantity_uom2   := FND_API.G_MISS_CHAR;

	   --Customer Acceptance
           p_x_line_tbl(k).CONTINGENCY_ID  	      := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).REVREC_EVENT_CODE	      := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).REVREC_EXPIRATION_DAYS     := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).ACCEPTED_QUANTITY	      := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).REVREC_COMMENTS	      := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).REVREC_SIGNATURE	      := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).REVREC_SIGNATURE_DATE      := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).ACCEPTED_BY                := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).REVREC_REFERENCE_DOCUMENT  := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).REVREC_IMPLICIT_FLAG       := FND_API.G_MISS_CHAR;

     --key Transaction Dates Project
           p_x_line_tbl(k).order_firmed_date := FND_API.G_MISS_DATE ;
	       p_x_line_tbl(k).actual_fulfillment_date := FND_API.G_MISS_DATE ;
    --end

         -- Pack J catchweight
           IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                p_x_line_tbl(k).shipped_quantity2   := NULL;
           END IF;
         -- Pack J catchweight
           p_x_line_tbl(k).invoiced_quantity  := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).Auto_Selected_quantity  := FND_API.G_MISS_NUM;

           -- Scheduling attributes

           -- If future date then copy it
           IF (p_x_line_tbl(k).Request_Date < sysdate) THEN
               p_x_line_tbl(k).Request_Date := FND_API.G_MISS_DATE;
           END IF;

		   IF (p_x_line_tbl(k).re_source_flag = 'Y') THEN
			   p_x_line_tbl(k).ship_from_org_Id := FND_API.G_MISS_NUM;
               p_x_line_tbl(k).subinventory := FND_API.G_MISS_CHAR;
           END IF;


           p_x_line_tbl(k).Promise_Date  := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Earliest_Acceptable_Date  := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Latest_Acceptable_Date  := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Schedule_Ship_Date := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Schedule_Arrival_date := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Actual_shipment_date := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Actual_arrival_date  := FND_API.G_MISS_DATE;
           p_x_line_tbl(k).Fulfillment_date  := FND_API.G_MISS_DATE;

           p_x_line_tbl(k).delivery_lead_time := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).schedule_status_code := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).visible_demand_flag     := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).customer_trx_line_id :=  FND_API.G_MISS_NUM;
           p_x_line_tbl(k).Credit_Invoice_line_id :=  FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).First_Ack_Code := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).First_Ack_Date := FND_API.G_MISS_DATE;
		   p_x_line_tbl(k).Last_Ack_Code  :=  FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Last_Ack_Date := FND_API.G_MISS_DATE;
		   p_x_line_tbl(k).Order_Source_Id := 2;
		   p_x_line_tbl(k).Orig_Sys_shipment_Ref := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Change_Sequence := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Drop_Ship_Flag  := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Customer_Line_Number := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Customer_Shipment_Number := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Customer_Item_Net_Price  := FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).Customer_Payment_Term_Id := FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).Planning_Priority := FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).Reference_Customer_Trx_line_Id := FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).Split_By := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).Model_Remnant_Flag := FND_API.G_MISS_CHAR;

          -- Item substitution attributes.

           p_x_line_tbl(k).Original_Inventory_Item_Id := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).Original_item_identifier_Type := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Original_ordered_item_id := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).item_relationship_type := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).Item_substitution_type_code := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Late_Demand_Penalty_Factor := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).Override_atp_date_code := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Original_ordered_item := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Firm_demand_flag := Null;
           p_x_line_tbl(k).Earliest_ship_date := Null;

           -- Set attributes
           p_x_line_tbl(k).ship_set_id        := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).arrival_set_id     := FND_API.G_MISS_NUM;

           -- Clear Original System Ref Info

           p_x_line_tbl(k).orig_sys_document_ref     := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).orig_sys_line_ref         := FND_API.G_MISS_CHAR;

		   -- Clear Service Reference Line ID

           IF p_x_line_tbl(k).service_reference_type_code = 'ORDER' THEN
              p_x_line_tbl(k).service_reference_line_id := FND_API.G_MISS_NUM;
           END IF;

           -- Clear Config related info if item type is STANDARD

           IF l_temp_line_rec.item_type_code = 'STANDARD' THEN
              p_x_line_tbl(k).component_sequence_id := FND_API.G_MISS_NUM;
              p_x_line_tbl(k).component_code        := FND_API.G_MISS_CHAR;
           -- p_x_line_tbl(k).component_number      := FND_API.G_MISS_NUM;
              p_x_line_tbl(k).sort_order            := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).config_display_sequence:= FND_API.G_MISS_NUM;
           END IF;

           p_x_line_tbl(k).explosion_date        := FND_API.G_MISS_DATE;

           -- Clear shipping attributes
           p_x_line_tbl(k).over_ship_reason_code   := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).over_ship_resolved_flag := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).shipping_instructions   := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).packing_instructions    := FND_API.G_MISS_CHAR;
		   p_x_line_tbl(k).fulfillment_method_code := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Shipping_quantity       := FND_API.G_MISS_NUM;
           p_x_line_tbl(k).Shipping_quantity2      := FND_API.G_MISS_NUM; -- OPM 3482303
           p_x_line_tbl(k).Shipping_quantity_uom   := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Shipping_quantity_uom2  := FND_API.G_MISS_CHAR; -- OPM 3482303
           p_x_line_tbl(k).dep_plan_required_flag  := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).Shippable_Flag          := FND_API.G_MISS_CHAR;


	       -- Service attributes
		   p_x_line_tbl(k).Service_Number :=  FND_API.G_MISS_NUM;

            -- Clear RLA related attributes

           p_x_line_tbl(k).rla_schedule_type_code  := FND_API.G_MISS_CHAR;
           p_x_line_tbl(k).veh_cus_item_cum_key_id := FND_API.G_MISS_NUM;

		   -- Tax related attributes.

		   p_x_line_tbl(k).tax_value               := FND_API.G_MISS_NUM;
		   p_x_line_tbl(k).tax_date                := FND_API.G_MISS_DATE;

           -- PROMOTIONS SEP/01 Clear price request code
           p_x_line_tbl(k).price_request_code := NULL;

		   -- If the line type or order type  has changed tax related code will
		   -- default tax code.
                  -- But if it is a RETURN line don't  default, 5404002 and 6449117

           IF ( G_COPY_TO_DIFFERENT_ORDER_TYPE  OR
                p_line_type <> l_temp_line_rec.line_type_id ) AND
                l_temp_line_rec.line_category_code <> 'RETURN'  THEN
                   oe_debug_pub.add(  'Redefaulting the Tax Code' ,1);
                   p_x_line_tbl(k).tax_code := FND_API.G_MISS_CHAR;
           END IF;



           -- Special handling if we are copying from a Return to a regular line

           IF FND_API.to_Boolean(l_rma_to_reg) THEN
              -- Clear Reference Information.
              p_x_line_tbl(k).reference_line_id   := FND_API.G_MISS_NUM;
              p_x_line_tbl(k).reference_type      := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).reference_header_id := FND_API.G_MISS_NUM;

              -- clear shipping information
              p_x_line_tbl(k).shipment_priority_code := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).shipping_method_code   := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).freight_carrier_code   := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).freight_terms_code     := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).fob_point_code         := FND_API.G_MISS_CHAR;

              -- Clear Return Reason code
              p_x_line_tbl(k).return_reason_code := FND_API.G_MISS_CHAR;

		      -- Clear Line Category
		      p_x_line_tbl(k).line_category_code := FND_API.G_MISS_CHAR;

		      -- Clear return descriptive information.
              p_x_line_tbl(k).return_context		:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute1	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute2	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute3	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute4	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute5	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute6	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute7	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute8	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute9	:= FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute10 := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute11 := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute12 := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute13 := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute14 := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).return_attribute15 := FND_API.G_MISS_CHAR;
		      p_x_line_tbl(k).ship_tolerance_above := FND_API.G_MISS_NUM;
		      p_x_line_tbl(k).ship_tolerance_below := FND_API.G_MISS_NUM;
           END IF;


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'AK: BEFORE REG_TO RETURN' , 3 ) ;
           END IF;
           -- Special Handling if we are copying to a Return Line.
           IF FND_API.to_Boolean(l_reg_to_rma) THEN

             -- Set the global
               G_REGULAR_TO_RMA := TRUE;
		     -- Process order will fill all remaining columns for the line,
		     -- when it is copied from reg to return.

		       p_x_line_tbl(k) := OE_Order_PUB.G_MISS_LINE_REC;
               p_x_line_tbl(k).line_type_id :=
                              nvl(p_line_type,l_temp_line_rec.line_type_id);
		       p_x_line_tbl(k).return_reason_code := p_return_reason_code;


		     -- Set return attributes to order.

		       p_x_line_tbl(k).return_context    := 'ORDER';
		       p_x_line_tbl(k).return_attribute1 := l_temp_line_rec.header_id;
		       p_x_line_tbl(k).return_attribute2 := l_temp_line_rec.line_id;

             -- Copy Reason for creating a Return.
               p_x_line_tbl(k).return_reason_code := p_return_reason_code;

             -- Set Reference Information.
               p_x_line_tbl(k).reference_line_id   := l_temp_line_rec.line_id;
               p_x_line_tbl(k).reference_type      := 'ORDER';
               p_x_line_tbl(k).reference_header_id := l_temp_line_rec.header_id;

               IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                  IF p_reason_code IS NOT NULL THEN
                      p_x_line_tbl(k).change_reason := p_reason_code;
                  END IF;

                  IF p_comments IS NOT NULL THEN
                      p_x_line_tbl(k).change_comments := p_comments;
                  END IF;
               END IF;

           END IF;


           -- Clear Descriptive flex if it isn't being copied

           IF NOT (FND_API.to_boolean(p_line_descflex)) THEN

              p_x_line_tbl(k).context     := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute1  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute2  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute3  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute4  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute5  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute6  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute7  := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute8  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).attribute9  := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute10 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute11 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute12 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute13 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute14 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute15 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute16 := FND_API.G_MISS_CHAR;    -- For bug 2184255
	          p_x_line_tbl(k).attribute17 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute18 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute19 := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).attribute20 := FND_API.G_MISS_CHAR;

              p_x_line_tbl(k).global_attribute_category := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute1         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute2         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute3         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute4         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute5         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute6         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute7         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute8         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute9         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute10        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute11        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute12        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute13        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute14        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute15        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute16        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute17        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute18        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute19        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).global_attribute20        := FND_API.G_MISS_CHAR;

              p_x_line_tbl(k).industry_context     := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute1  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute2  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute3  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute4  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute5  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute6  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute7  := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).industry_attribute8  := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).industry_attribute9  := FND_API.G_MISS_CHAR;
	          p_x_line_tbl(k).industry_attribute10 := FND_API.G_MISS_CHAR;

              p_x_line_tbl(k).tp_context           := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute1         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute2         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute3         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute4         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute5         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute6         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute7         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute8         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute9         := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute10        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute11        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute12        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute13        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute14        := FND_API.G_MISS_CHAR;
              p_x_line_tbl(k).tp_attribute15        := FND_API.G_MISS_CHAR;

           END IF; -- We are not copying descflex

           -- If users have implementated the Hook API OE_COPY_UTIL_EXT.Copy_Line_DFF

           IF CALL_DFF_COPY_EXTN_API(l_temp_line_rec.org_id) AND
              FND_API.to_boolean(p_line_descflex) AND
              FND_API.to_Boolean(l_reg_to_rma)
           THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Copying DFF from REF Line '||
                          l_temp_line_rec.context) ;
     END IF;
               -- Since we have cleared line record, we need to get back the
               -- values from reference line record.
               copy_line_dff_from_ref
                    (p_ref_line_rec => l_temp_line_rec,
                     p_x_line_rec => p_x_line_tbl(k));

           END IF;


		   -- Set calculate price falg to 'N' when repricing is not required.

		   IF p_line_price_mode = G_CPY_ORIG_PRICE THEN

              p_x_line_tbl(k).calculate_price_flag := 'N';

            -- Set pricing date if we are re-pricing and a date is provided.
           ELSIF (p_line_price_mode = G_CPY_REPRICE) THEN
               IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                  p_x_line_tbl(k).original_list_price := NULL;
               END IF;
               IF (p_line_price_date IS NOT NULL)    THEN
                   p_x_line_tbl(k).pricing_date := p_line_price_date;
               ELSE --else we re-price based on a date that Process Order defaults
                   p_x_line_tbl(k).pricing_date := FND_API.G_MISS_DATE;
               END IF;

 /* Added the following line to fix the bug 1812860 */
               p_x_line_tbl(k).calculate_price_flag := 'Y';
 /* Added the following condition to fix the bug 2107810 */
           ELSIF (p_line_price_mode = G_CPY_REPRICE_PARTIAL) THEN
               p_x_line_tbl(k).calculate_price_flag := 'P';
           END IF;

           -- Set operation
           p_x_line_tbl(k).operation := OE_GLOBALS.G_OPR_CREATE;

           -- Set source Information
           p_x_line_tbl(k).source_document_type_id   := 2;
           p_x_line_tbl(k).source_document_id        := l_temp_line_rec.header_id;
           p_x_line_tbl(k).source_document_Line_id   := l_temp_line_rec.line_id;

          -- Added for bug 3426181 (FP:3442246)
          -- Initialize the source_type_code to G_MISS_CHAR so that it will get
          -- defaulted again
           IF  FND_API.to_Boolean(l_rma_to_reg) THEN
               p_x_line_tbl(k).source_type_code := FND_API.G_MISS_CHAR;
           END IF;

           -- Added for ER 2351654
           IF p_default_null_values = FND_API.G_TRUE THEN
               Clear_Missing_Attributes(p_x_line_tbl(k));
           END IF;
        END;

        -- Added the following code to support a User Hook to copy DFF at
        -- line level.
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('The Operation is '||l_operation) ;
        END IF;

        IF CALL_DFF_COPY_EXTN_API(l_temp_line_rec.org_id) THEN

            OE_COPY_UTIL_EXT.Copy_Line_DFF(
                               p_copy_rec => p_copy_rec,
                               p_operation => l_operation,
                               p_ref_line_rec => l_temp_line_rec,
                               p_copy_line_rec => p_x_line_tbl(k));

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('After COPY Line DFF '|| p_x_line_tbl(k).context) ;
     END IF;
        END IF;

        k := p_x_line_tbl.NEXT(k);
      END LOOP;

        -- Added following code to retain line set info for split lines.
        IF l_line_set_tbl.COUNT > 0 THEN
            FOR k IN 1..l_line_set_tbl.COUNT LOOP
                IF l_line_set_tbl(k).set_count > 1 THEN
                    create_line_set(
                        l_line_set_tbl(k).old_line_id,
                        l_line_set_tbl(k).line_id,
                        l_line_set_tbl(k).line_set_id,
                        l_line_set_tbl(k).header_id,
                        l_line_set_tbl(k).line_type_id
                        );
                END IF;
            END LOOP;
        END IF;

     END IF; -- Table has rows;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.INIT_LINES_NEW' , 1 ) ;
     END IF;



END Init_Lines_New;

Procedure Load_and_Init_Line_Scredits
 (p_line_tbl          IN OE_Order_PUB.Line_Tbl_type
 ,p_version_number    IN NUMBER
 ,p_phase_change_flag IN VARCHAR2
 ,x_Line_Scredit_Tbl  IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type )
IS

l_line_id          NUMBER;
I                  NUMBER := 1;
l_sub_scredit_tbl  OE_Order_PUB.Line_Scredit_Tbl_Type;
l_api_name         CONSTANT VARCHAR(30) := 'Load_and_Init_Line_Scredits';
K                  NUMBER; -- Used as loop index.
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_LINE_SCREDITS' , 1 ) ;
     END IF;

     -- Load Line Sales Credits

     IF p_line_tbl.COUNT > 0  THEN

	   -- For every line in the line table
	   k := p_line_tbl.FIRST;
	   WHILE k IS NOT NULL LOOP
	   BEGIN

            l_line_id := p_line_tbl(k).line_id;
		  -- Load line level Sales Credits into temporary table
		  BEGIN
               IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN

                   OE_Version_History_UTIL.Query_Rows(
                                 p_sales_credit_id => NULL
                                ,p_line_id => l_line_id
                                ,p_Header_id => NULL
                                ,p_version_number => p_version_number
                                ,p_phase_change_flag => p_phase_change_flag
				                ,x_line_scredit_tbl => l_sub_scredit_tbl);
               ELSE
                   OE_Line_Scredit_Util.Query_Rows(p_line_id => l_line_id
				                ,x_line_scredit_tbl => l_sub_scredit_tbl);
               END IF;

		  EXCEPTION

			WHEN NO_DATA_FOUND THEN
			NULL;

		  END;

            -- Init Table for Copying
            IF l_sub_scredit_tbl.COUNT > 0 THEN

              -- Load rows from Temp table into Sales Credit table
               FOR j IN l_sub_scredit_tbl.FIRST .. l_sub_scredit_tbl.LAST LOOP

                   x_Line_scredit_tbl(I) := l_sub_scredit_tbl(j);

                   -- Init columns
                   x_line_scredit_tbl(I).operation := OE_GLOBALS.G_OPR_CREATE;
                   x_Line_scredit_tbl(I).line_index := k;
                   x_Line_scredit_tbl(I).header_id := FND_API.G_MISS_NUM;
                   x_Line_scredit_tbl(I).line_id   := FND_API.G_MISS_NUM;
                   x_Line_scredit_tbl(I).sales_credit_id := FND_API.G_MISS_NUM;

                   I := I + 1;
               END LOOP;

               -- Clear Sub Table
               l_sub_scredit_tbl.DELETE;


            END IF; -- Sub table has rows
        END;

		k := p_line_tbl.NEXT(k);
        END LOOP;

     END IF; -- Line Table has rows

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE SC IS '||TO_CHAR ( X_LINE_SCREDIT_TBL.COUNT ) , 2 ) ;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.LOAD_AND_INIT_LINE_SCREDITS' , 1 ) ;
     END IF;


EXCEPTION

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN OTHERS' , 1 ) ;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_and_Init_Line_Scredits;

-- Added for multiple payments
PROCEDURE  Load_and_Init_Line_Payments
(p_line_tbl  		IN OE_Order_PUB.Line_Tbl_type
,p_line_type          	IN NUMBER
,x_Line_Payment_tbl 	IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type)
 IS

l_sub_payment_tbl	OE_Order_PUB.Line_payment_Tbl_Type;
l_line_id		NUMBER;
k			NUMBER;
I			NUMBER := 1;
l_line_category	VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

--R12 CC Encryption
l_invoice_to_cust_id NUMBER;
l_invoice_to_org_id NUMBER;
L_trxn_extension_id NUMBER;
l_return_status VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
--R12 CC Encryption

BEGIN

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.Load_and_Init_Line_Payments.' , 1 ) ;
  END IF;

  IF p_line_tbl.COUNT > 0  THEN
    -- For every line in the line table
    k := p_line_tbl.FIRST;
    WHILE k IS NOT NULL LOOP

    IF p_line_type IS NOT NULL THEN
      l_line_category := Get_Line_Category(p_line_type);
    ELSE
      l_line_category := Get_Line_Category(p_line_tbl(k).line_type_id);
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' Destination line type is:  '||l_line_category, 3 ) ;
    END IF;

    IF l_line_category = 'RETURN' THEN
      goto Next_Line;
    END IF;

    BEGIN
    l_line_id := p_line_tbl(k).line_id;
    -- Load line level payments
      BEGIN
        OE_Line_payment_Util.Query_Rows
	  (p_line_id => l_line_id
          ,p_header_id =>  p_line_tbl(k).header_id
	  ,x_line_payment_tbl => l_sub_payment_tbl);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
      END;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'After query_rows the count is: '||l_sub_payment_tbl.COUNT, 3 ) ;
  END IF;

      -- Init Table for Copying
      IF l_sub_payment_tbl.COUNT > 0 THEN
        -- Load rows into payment table
        FOR J IN l_sub_payment_tbl.FIRST .. l_sub_payment_tbl.LAST LOOP
	    --bug5741708
	    IF l_sub_payment_tbl(j).payment_type_code = 'COMMITMENT' THEN
	       goto Next_Payment;
	    END IF;
	    x_Line_payment_tbl(I) := l_sub_payment_tbl(j);
	    -- Init columns
	    x_line_payment_tbl(I).operation := OE_GLOBALS.G_OPR_CREATE;
	    x_Line_payment_tbl(I).header_id := FND_API.G_MISS_NUM;
	    x_Line_payment_tbl(I).line_id   := FND_API.G_MISS_NUM;
	    x_Line_payment_tbl(I).line_index   := k;
	    --bug5741708 setting the payment_number to G_MISS_NUM since we aren't copying commitments
	    x_Line_payment_tbl(I).payment_number := FND_API.G_MISS_NUM;
            x_Line_payment_tbl(I).prepaid_amount := FND_API.G_MISS_NUM;
            x_Line_payment_tbl(I).payment_amount := FND_API.G_MISS_NUM;
            x_Line_payment_tbl(I).commitment_applied_amount:= FND_API.G_MISS_NUM;
            x_Line_payment_tbl(I).commitment_interfaced_amount := FND_API.G_MISS_NUM;
            x_Line_payment_tbl(I).credit_card_approval_code := FND_API.G_MISS_CHAR;
            x_Line_payment_tbl(I).payment_set_id := FND_API.G_MISS_NUM;
	    --R12 CC Encryption
	    /*IF  x_line_payment_tbl(k).payment_type_code
	    IN ('CREDIT_CARD','ACH','DIRECT_DEBIT','CASH','CHECK','WIRE_TRANSFER') THEN

		Select	 oit.customer_id, ooh.invoice_to_org_id
		Into 	l_invoice_to_cust_id, l_invoice_to_org_id
		From 	oe_order_lines_all ooh,Oe_invoice_to_orgs_v oit
		Where	ooh.line_id = x_line_payment_tbl(I).line_id
		And    	oit.organization_id = ooh.invoice_to_org_id;

		-- need to create a new trxn extension id and populate
		-- x_line_payments_tbl(I).trxn_extension_id with the new id before
		-- calling process order api to create new order.

		L_trxn_extension_id := x_line_payment_tbl(I).trxn_extension_id;

		OE_PAYMENT_TRXN_UTIL.Create_Payment_Trxn(
			P_header_id		=> x_line_payment_tbl(I).header_id,
			P_line_id		=> x_line_payment_tbl(I).line_id,
			P_cust_id		=> l_invoice_to_cust_id,
			P_site_use_id		=> l_invoice_to_org_id,
			P_payment_type_code	=> x_line_payment_tbl(I).payment_type_code,
			P_Payment_trx_id	=> x_line_payment_tbl(I).payment_trx_id,
			p_payment_number	=> x_line_payment_tbl(I).payment_number,
			P_card_number		=> x_line_payment_tbl(I).credit_card_number,
			p_card_code		=> x_line_payment_tbl(I).credit_card_code,
			P_card_holder_name	=> x_line_payment_tbl(I).credit_card_holder_name,
			P_exp_date		=> x_line_payment_tbl(I).credit_card_expiration_date,
			P_check_number		=> x_line_payment_tbl(I).check_number,
			P_instrument_security_code=> x_line_payment_tbl(I).instrument_security_code,
			P_X_trxn_extension_id	=> l_trxn_extension_id,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data);

			x_line_payment_tbl(I).credit_card_number := FND_API.G_MISS_CHAR;
			x_line_payment_tbl(I).credit_card_code := FND_API.G_MISS_CHAR;
			x_line_payment_tbl(I).credit_card_holder_name := FND_API.G_MISS_CHAR;
			x_line_payment_tbl(I).credit_card_expiration_date := FND_API.G_MISS_DATE;
			x_line_payment_tbl(I).check_number := FND_API.G_MISS_CHAR;
			x_line_payment_tbl(I).instrument_security_code := FND_API.G_MISS_CHAR;
			x_line_payment_tbl(I).trxn_extension_id := l_trxn_extension_id;
	    END IF;*/
	    --R12 CC Encryption

     	    I := I + 1;
	 <<Next_Payment>>
	 null;
	 END LOOP;
	 -- Clear Sub Table
	 l_sub_payment_tbl.DELETE;
       END IF; -- Sub table has rows
     END;

     <<Next_Line>>
     k := p_line_tbl.NEXT(k);
     END LOOP;

  END IF; -- Line Table has rows

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'Exiting OE_ORDER_COPY_UTIL.Load_and_Init_Line_Payments.' , 1 ) ;
  END IF;

END Load_and_Init_Line_Payments;

/* Added the following procedure to fix the bug 1923460 */

Procedure delete_config(
                         p_top_model_tbl             top_model_tbl_type)
IS
 k 			NUMBER; -- Used as Index for loop.
 l_return_status        VARCHAR2(100);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.DELETE_CONFIG ' , 1 ) ;
      END IF;

      k := p_top_model_tbl.FIRST;

	 WHILE K IS NOT NULL LOOP
		oe_config_pvt.delete_config(
                                                p_top_model_tbl(k).config_header_id,
                                                p_top_model_tbl(k).config_rev_nbr,
                                                l_return_status );
                k := p_top_model_tbl.NEXT(k);
         END LOOP;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.DELETE_CONFIG' , 1 ) ;
      END IF;
EXCEPTION

    WHEN OTHERS THEN
     NULL;

END delete_config;

--To insert the transaction extension id in the oe_payments table
--after the credit card details have been stored in the payments tables.
--R12 CC Encryption
/*Procedure Create_Payment(p_header_id IN NUMBER) IS
BEGIN
	INSERT INTO oe_payments
	(trxn_extension_id,
	payment_level_code,
	header_id,
	line_id,
	payment_type_code,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by
	)
	VALUES
	(g_trxn_extension_id,
	'ORDER',
	p_header_id,
	null,   -- line id
	g_payment_type_code,
	sysdate,
	1,
	sysdate,
	1);
END Create_Payment;*/
--R12 CC Encryption

-- Added as part of Inline Code Documentation Drive.
------------------------------------------------------------------------------------
-- Procedure Name : Copy_Order
-- Input Params   : p_copy_rec     : Copy Control record.
--                  p_hdr_id_tbl   : Table of Header Ids to be processed.
--                  p_line_id_tbl  : Table of Line Ids to be processed.
-- Output Params  : x_header_id    : New Header ID of the Copied Order.
--                  x_return_status: Return status of the operation.
--                  x_msg_count    : Count of messages returned.
--                  x_msg_data     : Message Data returned.
-- Description    : This is the main procedure for Copying Orders. It takes
--                  header_id table, ine_id table, and a copy record for control
--                  variables as input and provides the new header_id output.
--                  It is called from OE_ORDER_COPY_MAIN.Copy_Main (OEORDCPY.pld).
--                  It internally makes a PO API Call to create the new order/lines.
--                  This procedure is used in this package and in this flow only
--                  and not used anywhere else in any other flow in the product.
------------------------------------------------------------------------------------

-- For Bug 1935675
-- The code has been modified so as to deal with the partial copy case. Prior
-- to this enhacement the Copy_Order procedure would return a complete success
-- or a total failure, the partial case wasnot being dealt with.

-- Modification Done :
-- Code has been modified after the call to the Process Order API, we would
-- query the database to verify if a header has been created or not( in the
-- case of copying an order ). If created, would indicate a case of partial
-- success even if all the lines fail to get copied.
-- Two variables l_all_lines_copied and l_all_lines_failed have been used to
-- capture the three cases :
-- 1. Complete Success in creating a new Order or all the selected lines
--    appended successfully to an existing order
-- 2. Failure in adding the lines
-- 3. Partial Success case.

-- The flag l_copy_partial_or_full is used to capture patrial copy and
-- the return status of the  copy_order procedure depends on the value of
-- this flag.

-- The issue that has been addressed in Bug 1923460 has been taken care off.
-- end of bug 1935675


PROCEDURE Copy_Order
( p_copy_rec     IN  copy_rec_type
,p_hdr_id_tbl    IN  OE_GLOBALS.Selected_Record_Tbl
,p_line_id_tbl   IN  OE_GLOBALS.Selected_Record_Tbl
,x_header_id     OUT NOCOPY NUMBER
,x_return_status OUT NOCOPY VARCHAR2
,x_msg_count     OUT NOCOPY NUMBER
,x_msg_data      OUT NOCOPY VARCHAR2)

IS
  l_api_version_number        CONSTANT NUMBER := 1.0;
  l_api_name                  CONSTANT VARCHAR(30) := 'Copy_Order';

  l_header_id                 NUMBER;
  l_to_header_id              NUMBER;
  l_line_header_id            NUMBER;
  l_line_id                   NUMBER;
  l_destination_header_id     NUMBER;
  l_get_type_from_line        VARCHAR2(01)   := FND_API.G_FALSE;
  l_hdr_type_id               NUMBER;
  l_order_number              NUMBER;
  l_Order_version             NUMBER;
  l						NUMBER; -- Used as loop index.
  k						NUMBER; -- Used as loop index.
  j						NUMBER; -- Used as loop index.

  l_header_rec                OE_Order_PUB.Header_Rec_Type;
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
/* Added the following line to fix the bug 1923460 */
  l_top_model_tbl             top_model_tbl_type;
  l_line_final_tbl            OE_Order_PUB.Line_Tbl_Type;
  l_header_out_rec            OE_Order_PUB.Header_Rec_Type;
  l_line_out_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_line_rec                  OE_Order_PUB.Line_Rec_Type;
  l_header_adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
  l_header_price_att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_header_Adj_att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
  l_header_scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_line_adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
  l_line_price_att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_line_Adj_att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_line_adj_out_tbl          OE_Order_PUB.Line_Adj_Tbl_Type;
  l_line_scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_lot_serial_out_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_action_request_tbl        OE_Order_PUB.Request_Tbl_Type;
  l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;

  l_header_exists             BOOLEAN;                  -- variables added for bug 1935675
  l_copy_partial_or_full      BOOLEAN := FALSE;
  l_all_lines_copied          BOOLEAN;
  l_all_lines_failed          BOOLEAN;
  l_delete_config             BOOLEAN;
  l_dummy_header              NUMBER;                   --  end 1935675

  l_top_model_index           NUMBER;
  l_return_status             VARCHAR2(30);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_copy_header_id            NUMBER;
  l_temp_var VARCHAR2(2000) := NULL;
  l_copy_rec                  COPY_REC_TYPE;
  --serla begin
  l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
  l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
  --serla end

  --R12 CC Encryption
  l_cpy_category	     VARCHAR2(30);
  l_msg_count		     NUMBER;
  l_msg_data		     VARCHAR2(2000);
  l_trxn_extension_id	     NUMBER;
  l_invoice_to_cust_id	     NUMBER;
  l_exists		     VARCHAR2(1);
  --R12 CC Encryption
  --bug 5113795
  l_payment_type_code VARCHAR2(80);
  l_copy_header_payments VARCHAR2(10);
  l_copy_line_payments VARCHAR2(10);
  l_cc_line_payments NUMBER;

  -- Copy Sets ER #2830872 , #1566254 Begin.
  l_sets_result         VARCHAR2(1);
  l_hdr_id_sets_tbl     OE_GLOBALS.Selected_Record_Tbl;
  l_sets_found_flag     BOOLEAN := FALSE;
  l_sets                NUMBER := 0;
  l_sets_header_id      NUMBER;
  l_copy_fulfill_sets   BOOLEAN := FALSE;
  l_copy_ship_arr_sets  BOOLEAN := FALSE;
  -- Copy Sets ER #2830872 , #1566254 End.

BEGIN

    -- p_hdr_id_tbl and p_line_id_tbl are now passed as separate tables because client side pl-sql can
    -- not handle record of table of record

    -- Set the Global COPY rec
    G_COPY_REC := p_copy_rec;
    --bug 5113795
    l_copy_header_payments := p_copy_rec.hdr_payments;
    l_copy_line_payments := p_copy_rec.line_payments;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_ORDER_COPY_UTIL.COPY_ORDER' , 1 ) ;
        oe_debug_pub.add(  'BEFORE RESETTING LEVEL : '|| TO_CHAR ( G_ORDER_LEVEL_COPY ) , 3 ) ;
        oe_debug_pub.add(  'REDEFAULT MISSING IS ' || P_COPY_REC.DEFAULT_NULL_VALUES ) ;
    END IF;

    G_LINE_PRICE_MODE :=  p_copy_rec.line_price_mode;
    G_ORDER_LEVEL_COPY := 0;

    -- Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (l_api_version_number
           ,p_copy_rec.api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     --  Initialize message list.

    IF FND_API.to_Boolean(p_copy_rec.init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Set the global variable.
    G_REGULAR_TO_RMA := FALSE;
    G_NEED_TO_EXPLODE_CONFIG := FALSE;
    -- Loop Through the table of header Ids
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('BEfore looping for '||p_hdr_id_tbl.COUNT);
    END IF;

    FOR i IN p_hdr_id_tbl.FIRST..p_hdr_id_tbl.LAST LOOP

      --Bug 7707530 : Moved following portion inside the loop to set org id with
      --each iteration
        --ER 7258165 : Start : Copy accross organizations
        --Set the org context to source lock in order to fetch all the source details
        IF G_COPY_REC.source_org_id IS NOT NULL THEN
          mo_global.set_policy_context(NVL(G_COPY_REC.source_access_mode,'S')
                                      ,G_COPY_REC.source_org_id);
        END IF;
        --ER 7258165 : End
      --Bug 7707530 : End

        -- Set the global variables
        G_Canceled_Line_Deleted := FALSE;
        G_Order_Has_Split_Lines := FALSE;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'HDR ID IS '||p_hdr_id_tbl(i).id1 , 2 ) ;
        END IF;

        l_header_id := p_hdr_id_tbl(i).id1;

        G_ATT_HEADER_ID := l_header_id;

        -- Are we Copying an Order or Copying Lines to existing Order.

        IF FND_API.to_Boolean(p_copy_rec.copy_order) THEN
           -- Copy Hdr Information

        /* Added the following line to fix the bug 1923460 */
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SETTING LEVEL : '|| TO_CHAR ( G_ORDER_LEVEL_COPY ) , 3 ) ;
      END IF;
           G_ORDER_LEVEL_COPY := 1;
           IF p_copy_rec.source_block_type = 'LINE' AND
              p_copy_rec.copy_complete_config = FND_API.G_TRUE
           THEN
               G_NEED_TO_EXPLODE_CONFIG := TRUE;
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Setting G_NEED_TO_EXPLODE_CONFIG ' , 3 ) ;
               END IF;
           END IF;
           l_destination_header_id := l_header_id;
           IF  FND_API.to_Boolean(p_copy_rec.hdr_info) THEN
                Copy_Header(l_header_id,
                            p_copy_rec,
					        l_header_rec);

                ----  Creating New Sales Order or Quoted Order
               l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
               l_header_rec.transaction_phase_code := p_copy_rec.new_phase;

	          IF l_debug_level  > 0 THEN
	              oe_debug_pub.add(  'AK1 HEADER ID ' || TO_CHAR ( L_HEADER_ID ) , 2 ) ;
	          END IF;
           ELSE -- Create Blank Header

             l_copy_rec := p_copy_rec;
             -- May need to explode config for line level COPY.
             IF p_copy_rec.source_block_type = 'LINE' AND
                p_copy_rec.copy_complete_config = FND_API.G_TRUE
             THEN
                 G_NEED_TO_EXPLODE_CONFIG := TRUE;
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Setting G_NEED_TO_EXPLODE_CONFIG ' , 3 ) ;
               END IF;

             END IF;

	         IF l_debug_level  > 0 THEN
	             oe_debug_pub.add(  'AK IN FIRST LINE HEADER LOGIC' , 2 ) ;
	         END IF;

		     -- Get header_id from first line.
             l_line_id := p_line_id_tbl(1).id1;

              -- Set the version number as NULL so that the current version
              -- of Order Header will be selected from oe_order_headers.

              l_copy_rec.version_number := NULL;
              l_copy_rec.phase_change_flag := NULL;

		      BEGIN

			  Select header_id
			  Into   l_line_header_id
			  From   oe_order_lines
			  Where  line_id = l_line_id;

		      EXCEPTION

		          WHEN OTHERS THEN

			           l_line_header_id := Null;

		      END;

		      IF l_line_header_id is not null THEN
                 Copy_Header(l_line_header_id,
                             l_copy_rec,
					         l_header_rec);

              ELSE

	              IF l_debug_level  > 0 THEN
	                  oe_debug_pub.add(  'AK BLANK HEADER' , 3 ) ;
	              END IF;
                  -- Set Source to COPY
                  l_header_rec.source_document_type_id := 2;
                  l_header_rec.source_document_id := l_header_id;
                  l_header_rec.source_document_version_number := NULL;

                  -- Need to specify OrderType
                  IF p_copy_rec.hdr_type IS NOT NULL THEN
                     l_header_rec.order_type_id := p_copy_rec.hdr_type;
                  END IF;

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'ORDER TYPE ' || TO_CHAR ( L_HEADER_REC.ORDER_TYPE_ID ) , 2 ) ;
                 END IF;
	  	          -- Set manual order number
			      IF p_copy_rec.manual_order_number IS NOT NULL THEN
			        l_header_rec.order_number := p_copy_rec.manual_order_number;
			      END IF;

                  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                      IF p_copy_rec.new_phase = 'N' THEN
                          l_header_rec.TRANSACTION_PHASE_CODE := 'N';
                      ELSE
                          l_header_rec.TRANSACTION_PHASE_CODE := 'F';
                      END IF;

                      IF p_copy_rec.copy_transaction_name = FND_API.G_FALSE THEN
                          l_header_rec.SALES_DOCUMENT_NAME :=
                                                    p_copy_rec.transaction_name;
                      END IF;

                      IF p_copy_rec.copy_expiration_date = FND_API.G_FALSE THEN
                          l_header_rec.EXPIRATION_DATE :=
                            NVL(p_copy_rec.expiration_date,FND_API.G_MISS_DATE);
                      END IF;

	  	              -- Set manual quote number
			          IF p_copy_rec.manual_quote_number IS NOT NULL THEN
			              l_header_rec.quote_number :=
                                               p_copy_rec.manual_quote_number;
			          END IF;

                   END IF;

               END IF; -- l_line_header_id
               l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
           END IF; -- IF FND_API.to_Boolean(p_copy_rec.hdr_info)

            -- Copy Header Sales Credits if desired.
           IF FND_API.to_Boolean(p_copy_rec.hdr_scredits) THEN
               Load_and_Init_Hdr_Scredits(l_header_id,
                                          p_copy_rec.version_number,
                                          p_copy_rec.phase_change_flag,
                                          l_header_scredit_tbl);
           END IF;


            -- Copy Order Based Holds if desired.
           IF FND_API.to_Boolean(p_copy_rec.hdr_holds) THEN
               l_action_request_tbl := Load_and_Init_Hdr_Holds(l_header_id,
                                                 p_copy_rec.version_number,
                                                 p_copy_rec.phase_change_flag,
                                                 l_action_request_tbl);
           END IF;

           -- for multiple payments.
           IF FND_API.to_Boolean(p_copy_rec.hdr_payments)
             AND OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
             -- don't copy payment information to order of RETURN type.
             IF l_debug_level  > 0 THEN
               oe_Debug_pub.add('Before hdr payments processing, destination order type is: '||get_order_category(l_header_rec.order_type_id),3);
             END IF;
	     --R12 CC Encryption
	     l_cpy_category := Get_Order_Category(p_copy_rec.hdr_type);
             IF nvl(l_cpy_category,'NULL') <> 'RETURN' THEN --R12 CC Encryption
	           --bug 5113795
		   select payment_type_code into l_payment_type_code
		   from oe_order_headers_all where header_id  = l_header_id;
		   IF l_debug_level > 0 THEN
			   oe_debug_pub.add('Payment type code in copy order..ksurendr'||l_payment_type_code);
			   oe_debug_pub.add('Header_id ...'||l_header_id);
			   oe_debug_pub.add('Copy Header Payments flag...'||l_copy_header_payments);
		   END IF;
		   IF l_payment_type_code = 'CREDIT_CARD' and
		   OE_Payment_Trxn_Util.Get_CC_Security_Code_Use = 'REQUIRED'
		   AND l_copy_header_payments = 'T' THEN
			   IF l_debug_level > 0 THEN
				   oe_debug_pub.add('Error in Copy order');
			   END IF;
			   FND_MESSAGE.SET_NAME('ONT','OE_CC_NO_COPY_SEC_CODE_REQ');
			   OE_MSG_PUB.Add;
			   RAISE FND_API.G_EXC_ERROR;
		   ELSE
               	       IF l_debug_level > 0 THEN
			   oe_debug_pub.add('Before calling load and init header payments....');
		       END IF;
		       Load_and_Init_Hdr_Payments(l_header_id,l_x_header_payment_tbl);
		   END IF;
		   --bug 5113795
             END IF;
	   END IF;

           -- Pre-populate header_id on the header record.
           SELECT  OE_ORDER_HEADERS_S.NEXTVAL
           INTO    l_header_rec.header_id
           FROM    DUAL;

	   --R12 CC Encryption
	   oe_debug_pub.add('New header id...'||l_header_rec.header_id);
	   --oe_debug_pub.adD('Original trxn extn id'||l_x_header_payment_tbl(1).trxn_extension_id);
	   oe_debug_pub.add('category'||l_cpy_category);
	   oe_debug_pub.add('g_create fl'||g_create_payment_flag||'and'||p_copy_rec.hdr_info||'and'||p_copy_rec.hdr_payments);

	   /*IF nvl(l_cpy_category,'-1') <> 'RETURN' AND FND_API.to_Boolean(p_copy_rec.hdr_info)
	   AND FND_API.to_Boolean(p_copy_rec.hdr_payments) AND g_create_payment_flag = 'Y'  THEN
		-- Condition for the payment types supported by order header
		IF l_header_rec.payment_type_code IN('CASH','CHECK','CREDIT_CARD') THEN

			begin
				SELECT 'Y'
				INTO l_exists
				FROM oe_payments
				Where header_id = l_header_id;
				--0and trxn_extension_id is not null; --Verify
			exception
			when no_data_found then
				IF l_debug_level  > 0 THEN
					oe_debug_pub.add('no data found while querying oe_payments in copy_order..'||sqlerrm);
				END IF;
				l_exists := 'N';
			end;
			begin
				Select customer_id
				Into l_invoice_to_cust_id
				From oe_invoice_to_orgs_v
				Where organization_id = l_header_rec.invoice_to_org_id;
			exception
			when no_data_found then
				IF l_debug_level  > 0 THEN
					oe_debug_pub.add('no data found while querying for customer id in copy_order..'||sqlerrm);
				END IF;
			end;

			IF nvl(l_exists, 'N') = 'N' THEN  --Verify
			--New trxn_extension_id and a new record in oe_payments table
			OE_PAYMENT_TRXN_UTIL.Create_Payment_Trxn
			(P_header_id		=> l_header_rec.header_id, --Verify
			P_line_id		=> null,
			P_cust_id		=> l_invoice_to_cust_id,
			P_site_use_id		=> l_header_rec.invoice_to_org_id,
			P_payment_type_code	=> l_header_rec.payment_type_code,
			P_payment_trx_id	=> null,--l_x_header_payment_tbl.payment_trx_id,
			p_payment_number	=> null, --Verify
			P_card_number		=> l_header_rec.credit_card_number,
			p_card_code		=> l_header_rec.credit_card_code,
			P_card_holder_name	=> l_header_rec.credit_card_holder_name,
			P_exp_date		=> l_header_rec.credit_card_expiration_date,
			P_check_number		=> l_header_rec.check_number,
			P_instrument_security_code=> null,--l_header_rec.instrument_security_code,
			P_X_trxn_extension_id	=> l_trxn_extension_id,
			X_return_status		=> l_return_status,
			X_msg_count		=> l_msg_count,
			X_msg_data		=> l_msg_data);


			IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		       l_header_rec.credit_card_number          := FND_API.G_MISS_CHAR;
		       l_header_rec.credit_card_code		:= FND_API.G_MISS_CHAR;
		       l_header_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
		       l_header_rec.credit_card_holder_name     := FND_API.G_MISS_CHAR; --Verify

			--set global variables before calling create_payment
			G_trxn_extension_id := l_trxn_extension_id;
			g_payment_type_code := l_header_rec.payment_type_code;
			Create_Payment(l_header_rec.header_id);
			null;
			END IF;
		END IF;
	END IF;*/
        -- R12 CC Encryption
        ELSE -- Append to Existing Order
           l_destination_header_id := p_copy_rec.append_to_header_id;
           l_header_rec.header_id := p_copy_rec.append_to_header_id;
           l_header_rec.operation := OE_GLOBALS.G_OPR_NONE; --  Add Lines to Existing Order
           -- May need to explode config for line level COPY.
           IF p_copy_rec.source_block_type = 'LINE' AND
              p_copy_rec.copy_complete_config = FND_API.G_TRUE
           THEN
               G_NEED_TO_EXPLODE_CONFIG := TRUE;
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Setting G_NEED_TO_EXPLODE_CONFIG ' , 3 ) ;
               END IF;
           END IF;
        END IF;

        -- Initialize the Lines Table

        IF l_line_tbl.COUNT > 0 THEN
            l_line_tbl.DELETE;
        END IF;

        -- Initialize the Top_Model_Tbl

        IF l_top_model_tbl.COUNT > 0 THEN
            l_top_model_tbl.DELETE;
        END IF;

        -- Set the Globals for COPY (To be used by copy_adjustments)

        G_HDR_VER_NUMBER := p_copy_rec.version_number;
        G_HDR_PHASE_CHANGE_FLAG := p_copy_rec.phase_change_flag;
        G_LN_VER_NUMBER := p_copy_rec.line_version_number;
        G_LN_PHASE_CHANGE_FLAG := p_copy_rec.line_phase_change_flag;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Header Version Number IS '|| G_HDR_VER_NUMBER , 1 ) ;
            oe_debug_pub.add('Header Phase Change Flag IS '|| G_HDR_PHASE_CHANGE_FLAG , 1 ) ;
            oe_debug_pub.add('Line Version Number IS '|| G_LN_VER_NUMBER , 1 ) ;
            oe_debug_pub.add('Line Phase Change Flag IS '|| G_LN_PHASE_CHANGE_FLAG , 1 ) ;
        END IF;
        -- Load Lines to be copied into table and handle configurations.
        -- Will be used in Nonstandard lines procedure.

	    l_hdr_type_id := nvl(p_copy_rec.hdr_type,l_header_rec.order_type_id);
        load_lines(p_copy_rec.line_count,
                   p_line_id_tbl,
                   p_copy_rec.all_lines,
                   p_copy_rec.incl_cancelled,
                   l_header_id,
                   l_hdr_type_id,
                   p_copy_rec.line_type,
                   p_copy_rec.line_version_number,
                   p_copy_rec.line_phase_change_flag,
	  	           l_line_tbl,
                   l_top_model_tbl);

    --  Load Line Sales Credits

        IF FND_API.to_Boolean(p_copy_rec.line_scredits) THEN
           Load_and_Init_line_scredits(l_line_tbl,
                                       p_copy_rec.line_version_number,
                                       p_copy_rec.line_phase_change_flag,
                                       l_line_scredit_tbl);
        END IF;

        -- for multiple payments
      	IF FND_API.to_Boolean(p_copy_rec.line_payments)
          AND OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
	        --bug 5113795
		select count(*) into l_cc_line_payments
		from oe_payments where header_id = l_header_id
		and line_id is not null and payment_type_code = 'CREDIT_CARD';

		IF l_debug_level  > 0 THEN
			oe_debug_pub.add('In Line payments copy...');
			oe_debug_pub.add('Line cc payments count'|| l_cc_line_payments);
			oe_debug_pub.add('Header_id ..'||l_header_id);
		END IF;

		IF l_cc_line_payments > 0 AND
		OE_Payment_Trxn_Util.Get_CC_Security_Code_Use = 'REQUIRED'
		AND l_copy_line_payments = 'T' THEN
			IF l_debug_level > 0 THEN
			   oe_debug_pub.add('Error in Line Payments Copy order');
			   oe_debug_pub.add('Copy line payments checkbox...'||l_copy_line_payments);
			END IF;
			FND_MESSAGE.SET_NAME('ONT','OE_CC_NO_COPY_SEC_CODE_REQ');
			OE_MSG_PUB.Add;
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Before calling load and init line payments...');
			END IF;
			Load_and_Init_Line_Payments(l_line_tbl
				     ,p_copy_rec.line_type
				     ,l_x_line_payment_tbl);
		END IF;
		--bug 5113795
	END IF;

    --  Initialize Lines table after children have been loaded
    --  ,since we need the line_id to load children.

    --  Modified for the ER 2351654 added extra parameter default_null_values
    --R12 CC Encryption
    IF l_debug_level > 0 THEN
	--oe_debug_pub.add('Credit card number in header rec...'||l_header_rec.credit_card_number);
	oe_debug_pub.add('Payment type code'||l_header_rec.payment_type_code);
    END IF;

    -- Added for the ER 1480867. Call the Init_Lines_New for the ER.
        Init_lines_new(l_line_tbl,
                   l_top_model_tbl,
                   p_copy_rec.line_type,
                   l_header_rec.header_id,
                   p_copy_rec.line_price_mode,
                   p_copy_rec.line_price_date,
                   p_copy_rec.line_descflex,
                   FND_API.G_FALSE,
                   p_copy_rec.return_reason_code,
                   p_copy_rec.default_null_values,
                   p_copy_rec.version_reason_code,
                   p_copy_rec.comments,
                   p_copy_rec,
                   l_action_request_tbl);
    -- Set Control Flags.

        l_control_rec.controlled_operation := TRUE; -- Since we set PARTIAL_PROCESS to true
        l_control_rec.check_security       := TRUE;
        l_control_rec.default_attributes   := TRUE;

        l_control_rec.change_attributes    := TRUE;  -- since we are creating Orders
        l_control_rec.clear_dependents     := FALSE;
        l_control_rec.validate_entity      := TRUE;
        l_control_rec.write_to_DB          := TRUE;
        l_control_rec.process              := TRUE;
        l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;

    -- Instruct API to process as many records as it can

        l_control_rec.Process_Partial      := TRUE;

    -- Instruct API to retain its caches

        l_control_rec.clear_api_cache      := TRUE;
        l_control_rec.clear_api_requests   := TRUE;


    -- Call Process Order API to process request.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE PROCESS ORDER' , 2 ) ;
            oe_debug_pub.add('Header Currency is '|| l_header_rec.transactional_curr_code);
            IF l_line_tbl.COUNT <> 0 THEN
               oe_debug_pub.add('Line Context is:'||l_line_tbl(1).context);
            END IF;
        END IF;

        --ER 7258165 : Start : Copy accross organizations
        --Set the org context to OU in which the order is to be copied
        mo_global.set_policy_context('S',G_COPY_REC.copy_org_id);


        if G_COPY_REC.copy_org_id <> G_COPY_REC.source_org_id then
               l_header_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
               l_header_rec.ship_to_org_id := FND_API.G_MISS_NUM;
               l_header_rec.deliver_to_org_id := FND_API.G_MISS_NUM;
               l_header_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
               for i in 1..l_line_tbl.COUNT LOOP
                  l_line_tbl(i).invoice_to_org_id  := FND_API.G_MISS_NUM;
                  l_line_tbl(i).ship_to_org_id := FND_API.G_MISS_NUM;
                  l_line_tbl(i).deliver_to_org_id := FND_API.G_MISS_NUM;
                  l_line_tbl(i).DELIVER_TO_CONTACT_ID  :=  FND_API.G_MISS_NUM;
               END LOOP ;
        end if ;

        --ER 7258165 : End

	OE_Order_PVT.Process_Order(
                     p_api_version_number     => 1
                    ,p_init_msg_list          => FND_API.G_FALSE
                                                -- to keep messages between calls
                    ,p_validation_level       => OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
                                                 -- to miss out invalid attrs.
                    ,p_control_rec            => l_control_rec
                    ,p_x_header_rec           => l_header_rec
                    ,p_x_header_Adj_tbl       => l_header_Adj_out_tbl
				,p_x_header_price_att_tbl => l_header_price_att_tbl
				,p_x_header_adj_att_tbl   => l_header_adj_att_tbl
				,p_x_header_adj_assoc_tbl => l_header_adj_assoc_tbl
                    ,p_x_Header_Scredit_tbl   => l_Header_Scredit_tbl
--serla begin
                    ,p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
                    ,p_x_line_tbl             => l_line_tbl
                    ,p_x_line_Adj_tbl         => l_line_adj_out_tbl
				,p_x_line_price_att_tbl   => l_line_price_att_tbl
				,p_x_line_adj_att_tbl     => l_line_adj_att_tbl
				,p_x_line_adj_assoc_tbl   => l_line_adj_assoc_tbl
                    ,p_x_line_Scredit_tbl     => l_Line_Scredit_tbl
--serla begin
                    ,p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
	               ,p_x_lot_Serial_tbl       => l_Lot_Serial_out_tbl
                    ,p_x_action_request_tbl   => l_action_request_tbl
                    ,x_return_status          => l_return_status
                    ,x_msg_count              => x_msg_count
                    ,x_msg_data               => x_msg_data
                    );


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS AFTER CALL TO PO '||L_RETURN_STATUS , 1 ) ;
	END IF;

        -- Copy Sets ER #2830872 , #1566254 Begin.
	-- Creating the table of header ids for operation.

        IF ((p_copy_rec.line_fulfill_sets = 'T' OR p_copy_rec.line_ship_arr_sets = 'T')
         AND l_line_tbl.Count > 0) THEN

        	IF p_copy_rec.line_fulfill_sets = 'T' THEN
  			l_copy_fulfill_sets := TRUE;
  			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Copying Fulfill Sets :'||p_copy_rec.line_fulfill_sets);
			END IF;
  		END IF;

  		IF p_copy_rec.line_ship_arr_sets = 'T' THEN
  			l_copy_ship_arr_sets := TRUE;
  			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Copying Ship/Arr Sets :'||p_copy_rec.line_ship_arr_sets);
			END IF;
  		END IF;

  		IF l_debug_level > 0 THEN
		      	oe_debug_pub.add(' Creating Header ID Table for Copy of Sets');
  		END IF;

  		IF l_line_tbl.Count > 0 THEN
        		FOR i in 1..l_line_tbl.Count LOOP
			 	IF l_line_tbl(i).source_document_type_id = 2 THEN
			 		l_sets_header_id := l_line_tbl(i).source_document_id;
			 	ELSE
			 		l_sets_header_id := NULL;
			 	END IF;

	 		 	IF l_hdr_id_sets_tbl.Count > 0 THEN
	 		 		FOR j IN 1..l_hdr_id_sets_tbl.Count LOOP
	 		 			IF l_sets_header_id IS NOT NULL THEN
	 		 				IF l_hdr_id_sets_tbl(j).id1 = l_sets_header_id THEN
	 		 					l_sets_found_flag := TRUE;
			 		        	END IF;
			 		        END IF;
	 		 		END LOOP;
	 		 	END IF;

	 		 	IF NOT (l_sets_found_flag) THEN
	 		 		l_sets := l_sets + 1;
	 		 		l_hdr_id_sets_tbl(l_sets).id1 := l_sets_header_id;
	 		 	END IF;
			 	l_sets_found_flag :=FALSE;
			END LOOP;
		END IF;
	        l_sets := 0;

		-- Calling the Copy Line Sets Procedure.
		IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Calling Copy Line Sets ');
		END IF;

		IF l_hdr_id_sets_tbl.Count > 0 THEN
			FOR i IN 1..l_hdr_id_sets_tbl.Count LOOP
				COPY_LINE_SETS(l_hdr_id_sets_tbl(i).id1,
			               l_header_rec.header_id,
			               l_line_tbl,
			               l_copy_fulfill_sets,
			               l_copy_ship_arr_sets,
			               l_sets_result);
			END LOOP;
		END IF;

		IF l_sets_result = FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Set Result :'||l_sets_result);
			END IF;

			FND_MESSAGE.SET_NAME('ONT','OE_COPY_LINE_SETS');
        	        OE_MSG_PUB.Add;
		ELSE
			IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Set Result :'||l_sets_result);
			END IF;

			FND_MESSAGE.SET_NAME('ONT','OE_FAIL_LINE_SETS');
        	        OE_MSG_PUB.Add;
		END IF;
	END IF;
	-- Copy Sets ER #2830872 , #1566254 End.

	-- code to deal with the partial request case
	-- being added for the bug 1935675

	l_header_exists    := TRUE;
	l_all_lines_copied := TRUE;
	l_all_lines_failed := TRUE;
	l_delete_config    := FALSE;
    l_to_header_id     := NULL;

	IF FND_API.to_Boolean( p_copy_rec.copy_order ) THEN

	   BEGIN
          l_to_header_id := l_header_rec.header_id;
	      SELECT header_id
	      INTO   l_dummy_header
	      FROM   OE_ORDER_HEADERS
	      WHERE  header_id = l_header_rec.header_id;
	   EXCEPTION
	      WHEN NO_DATA_FOUND  THEN
		 l_header_exists := FALSE;
	   END;
	END IF; -- copy_order

	IF ( l_header_exists ) THEN

	   IF FND_API.to_Boolean( p_copy_rec.copy_order ) THEN

          IF l_header_rec.transaction_phase_code = 'F' OR
             l_header_rec.transaction_phase_code IS NULL THEN
	         FND_MESSAGE.SET_NAME( 'ONT', 'OE_CPY_NEW_HEADER' );
	         FND_MESSAGE.SET_TOKEN('ORDER', to_char(l_header_rec.order_number));
          ELSE
	         FND_MESSAGE.SET_NAME( 'ONT', 'OE_CPY_NEW_QUOTE' );
	         FND_MESSAGE.SET_TOKEN('QUOTE', to_char(l_header_rec.quote_number));
          END IF;
	      OE_MSG_PUB.Add;

	      l_copy_partial_or_full := TRUE;
	      x_header_id := l_header_rec.header_id;

	      IF FND_API.to_Boolean( p_copy_rec.hdr_attchmnts ) THEN

		 OE_Atchmt_Util.Copy_Attachments
			(p_entity_code             => OE_GLOBALS.G_ENTITY_HEADER
			,p_from_entity_id          => G_ATT_HEADER_ID
			,p_to_entity_id            => l_header_rec.header_id
			,p_manual_attachments_only => 'Y'
		        ,x_return_status           => l_return_status);
	      END IF; -- attachments

          --Copy Articles takintoy
          IF OE_CODE_CONTROL.Get_Code_Release_Level >='110510'Then
                  OE_Contracts_Util.copy_articles
                     (p_api_version        => 1,
                      p_doc_type           => OE_Contracts_Util.G_SO_DOC_TYPE,
                      p_copy_from_doc_id   => G_ATT_HEADER_ID,
                      ---p_version_number     => l_copy_rec.version_number,
                      p_version_number     => p_copy_rec.version_number,  --Bug 3689174 --l_copy_rec.version_number holds no value
                      p_copy_to_doc_id     => l_header_rec.header_id,
                      p_copy_to_doc_number => l_header_rec.order_number,
                      x_return_status      => l_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data
                      );
          END IF;

	   END IF; -- copy order

	   k := l_line_tbl.first;

	   WHILE k IS NOT NULL LOOP

	      IF ( l_line_tbl(k).return_status =  FND_API.g_ret_sts_success ) THEN

		     IF FND_API.to_Boolean( p_copy_rec.line_attchmnts ) THEN
		     OE_Atchmt_Util.Copy_Attachments
			  (p_entity_code             => OE_GLOBALS.G_ENTITY_LINE
			  ,p_from_entity_id          => l_line_tbl(k).source_document_line_id
			  ,p_to_entity_id            => l_line_tbl(k).line_id
			  ,p_manual_attachments_only => 'Y'
		          ,x_return_status           => l_return_status);
		     END IF; -- attachments;

		     l_all_lines_failed := FALSE;

             IF l_to_header_id IS NULL THEN
                 l_to_header_id := l_line_tbl(k).header_id;
             END IF;

		     IF NOT FND_API.to_Boolean(p_copy_rec.copy_order) THEN
		        l_copy_partial_or_full := TRUE;
		     END IF ; -- case of appending lines to an existing order

	       ELSE

		     IF ( ( l_line_tbl(k).config_header_id IS NOT NULL ) AND
		        ( l_line_tbl(k).config_rev_nbr IS NOT NULL   ) ) THEN
		        l_delete_config := TRUE;
		     END IF;

		     l_all_lines_copied := FALSE;

	       END IF; -- return_status = 'S'

	       k := l_line_tbl.NEXT(k);

	   END LOOP; -- loop on lines

       IF (l_all_lines_copied AND
          NOT G_Canceled_Line_Deleted AND
          NOT G_Order_Has_Split_Lines) OR
          G_REGULAR_TO_RMA OR
          OE_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN
           -- Do nothing as the Line numbers will match
           NULL;
       ELSE

           Process_Line_Numbers(p_header_id => l_to_header_id);

       END IF;

	   IF ( l_all_lines_failed ) THEN


          IF l_header_rec.transaction_phase_code = 'F' OR
             l_header_rec.transaction_phase_code IS NULL THEN
	         FND_MESSAGE.SET_NAME( 'ONT', 'OE_CPY_LINES_FAILED' );
	         FND_MESSAGE.SET_TOKEN('ORDER', to_char(l_header_rec.order_number));
          ELSE
	         FND_MESSAGE.SET_NAME( 'ONT', 'OE_QUOTE_CPY_LINES_FAILED' );
	         FND_MESSAGE.SET_TOKEN('QUOTE', to_char(l_header_rec.quote_number));
          END IF;
	      OE_MSG_PUB.Add;

	    ELSIF ( l_all_lines_copied ) THEN

	      IF FND_API.to_Boolean(p_copy_rec.copy_order) THEN

	         IF l_debug_level  > 0 THEN
	             oe_debug_pub.add(  'THE NEW ORDER IS '||TO_CHAR ( L_HEADER_REC.ORDER_NUMBER ) , 1 ) ;
	         END IF;

                 IF l_header_rec.transaction_phase_code = 'F' OR
                    l_header_rec.transaction_phase_code IS NULL THEN

                     FND_MESSAGE.SET_NAME('ONT','OE_CPY_NEW_ORDER');
                     FND_MESSAGE.SET_TOKEN('ORDER',
                                        to_char(l_header_rec.order_number));
                 ELSE
                     FND_MESSAGE.SET_NAME('ONT','OE_CPY_NEW_QUOTE_SUCCESS');
                     FND_MESSAGE.SET_TOKEN('QUOTE',
                                        to_char(l_header_rec.quote_number));
                 END IF;
                 OE_MSG_PUB.Add;

	       ELSE

				  IF l_debug_level  > 0 THEN
				      oe_debug_pub.add(  'APPENEDED LINES SUCCESSFULLY FOR ORDER : ' || TO_CHAR ( L_HEADER_REC.ORDER_NUMBER ) , 1 ) ;
				  END IF;

		 FND_MESSAGE.SET_NAME('ONT','OE_CPY_APPEND_LINES');
	         OE_MSG_PUB.Add;

	      END IF;

	      x_header_id := l_header_rec.header_id;

	    ELSE

            IF l_header_rec.transaction_phase_code = 'F' OR
               l_header_rec.transaction_phase_code IS NULL THEN
	            FND_MESSAGE.SET_NAME('ONT','OE_CPY_COPY_PARTIAL');
	            FND_MESSAGE.SET_TOKEN('ORDER',
                                       to_char(l_header_rec.order_number));
            ELSE
	            FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_CPY_COPY_PARTIAL');
	            FND_MESSAGE.SET_TOKEN('QUOTE',
                                       to_char(l_header_rec.quote_number));
            END IF;
	        OE_MSG_PUB.Add;

				 IF l_debug_level  > 0 THEN
				     oe_debug_pub.add(  'COPY SUCCEEDED PARTIALLY FOR ORDER : ' || TO_CHAR ( L_HEADER_REC.ORDER_NUMBER ) , 1 ) ;
				 END IF;

	      x_header_id := l_header_rec.header_id;

	   END IF; -- all_lines_failed

	   --debug information
	   IF( l_all_lines_copied ) THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  ' ALL LINES COPIED : TRUE' , 5 ) ;
	      END IF;
	    ELSE
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  ' ALL LINES COPIED : FALSE' , 5 ) ;
	      END IF;
	   END IF;

	   IF( l_all_lines_failed ) THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  ' ALL LINES FAILED : TRUE' , 5 ) ;
	      END IF;
	    ELSE
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  ' ALL LINES FAILED : FALSE' , 5 ) ;
	      END IF;
	   END IF;

	   IF( l_delete_config ) THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  ' DELETE CONFIG : TRUE' , 5 ) ;
	      END IF;
	    ELSE
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  ' DELETE CONFIG : FALSE' , 5 ) ;
	      END IF;
	   END IF;
	   -- end of debug

	 ELSE  -- l_header_exists

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'FAILED TO COPY ORDER' , 1 ) ;
	   END IF;

	   FND_MESSAGE.SET_NAME('ONT','OE_CPY_COPY_FAILED');
	   OE_MSG_PUB.Add;

	END IF; -- header created or not;

	IF ( l_delete_config ) THEN
	   delete_config(l_top_model_tbl);
	END IF;

	-- code ends here 1935675

/* Test  2288800 */
      j := l_line_tbl.FIRST;
         WHILE j IS NOT NULL LOOP
         BEGIN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'LINECOUNT : ' || TO_CHAR ( J ) , 1 ) ;
             END IF;
             l_line_tbl.DELETE(j);
             j := l_line_tbl.NEXT(j);
         END;
         END LOOP; -- loop on lines
/* Test 2288800 */

    END LOOP; -- l_hdr_lst

    OE_MSG_PUB.Count_And_Get
       (  p_count  => x_msg_count,
          p_data   => x_msg_data  );

    -- for bug 1935675
    IF ( l_copy_partial_or_full ) THEN
       x_return_status :=  FND_API.G_RET_STS_SUCCESS;
     ELSE
       x_return_status :=  FND_API.G_RET_STS_ERROR;
    END IF;
    -- end 1935675;

    G_LINE_PRICE_MODE := NULL;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RET STATUS SUCCESS ' || X_RETURN_STATUS , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_COPY_UTIL.COPY_ORDER' , 1 ) ;
    END IF;

    OE_DEBUG_PUB.DumpDebug;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN G_EXC_ERROR ' , 1 ) ;
       END IF;
       G_LINE_PRICE_MODE := NULL;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
       OE_DEBUG_PUB.DumpDebug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN G_EXC_UNEXPECTED_ERROR' ) ;
        END IF;
        G_LINE_PRICE_MODE := NULL;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        OE_DEBUG_PUB.DumpDebug;

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COPY_ORDER IN OTHERS '||SQLERRM , 1 ) ;
        END IF;
        G_LINE_PRICE_MODE := NULL;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   l_api_name
            );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

        OE_DEBUG_PUB.DumpDebug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Copy_Order;

-- Added for the ER 1480867

PROCEDURE EXTEND_TBL(p_num IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    G_Line_Num_Rec.line_id.EXTEND(p_num);
    G_Line_Num_Rec.new_line_id.EXTEND(p_num);
    G_Line_Num_Rec.line_number.EXTEND(p_num);
    G_Line_Num_Rec.shipment_number.EXTEND(p_num);
    G_Line_Num_Rec.option_number.EXTEND(p_num);
    G_Line_Num_Rec.component_number.EXTEND(p_num);
    G_Line_Num_Rec.service_number.EXTEND(p_num);
    G_Line_Num_Rec.split_from_line_id.EXTEND(p_num);
    G_Line_Num_Rec.split_by.EXTEND(p_num);

END EXTEND_TBL;

-- Added for the ER 1480867

PROCEDURE DELETE_TBL
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    G_Line_Num_Rec.line_id.DELETE;
    G_Line_Num_Rec.new_line_id.DELETE;
    G_Line_Num_Rec.line_number.DELETE;
    G_Line_Num_Rec.shipment_number.DELETE;
    G_Line_Num_Rec.option_number.DELETE;
    G_Line_Num_Rec.component_number.DELETE;
    G_Line_Num_Rec.service_number.DELETE;
    G_Line_Num_Rec.split_from_line_id.DELETE;
    G_Line_Num_Rec.split_by.DELETE;

END DELETE_TBL;

-- Added for the ER 1480867

PROCEDURE Process_Line_Numbers(p_header_id IN NUMBER)
IS
l_copied_rec Line_Number_Rec_Type;
CURSOR C_Line_Nums IS
    SELECT line_id,
           line_number,
           shipment_number,
           option_number,
           component_number,
           service_number,
           split_from_line_id,
           source_document_Line_id,
           source_document_type_id,
           split_by,
           line_set_id,
           item_type_code,
           service_reference_line_id,
           link_to_line_id,
           top_model_line_id --9534576
    FROM oe_order_lines
    WHERE header_id = p_header_id
    ORDER BY line_number , shipment_number ,NVL(option_number, -1),
    NVL(component_number,-1),NVL(service_number,-1);
    l_split_by            VARCHAR2(30);
    l_split_from_line_id  BINARY_INTEGER;
    l_line_number_ctr     BINARY_INTEGER;
    l_shipment_number_ctr BINARY_INTEGER;
    l_option_number_ctr   BINARY_INTEGER;
    l_comp_number_ctr     BINARY_INTEGER;
    l_service_number_ctr  BINARY_INTEGER;
    k                     BINARY_INTEGER;
    l_counter             BINARY_INTEGER;

    TYPE l_number_tbl IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    l_shipment_num_tbl  l_number_tbl;
      l_option_num_tbl    l_number_tbl; --Bug 5757050
    l_first_split_index l_number_tbl;
    l_prev_line_number  NUMBER;
    l_line_number       NUMBER;
    l_comp_number_tbl   l_number_tbl;
    l_line_set_id       NUMBER;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING PROCESS_LINE_NUMBERS ' , 1 ) ;
    END IF;
    -- Get the lines from the copied order
    OPEN C_Line_Nums;
    FETCH C_Line_Nums BULK COLLECT INTO
                  l_copied_rec.line_id,
                  l_copied_rec.line_number,
                  l_copied_rec.shipment_number,
                  l_copied_rec.option_number,
                  l_copied_rec.component_number,
                  l_copied_rec.service_number,
                  l_copied_rec.split_from_line_id,
                  l_copied_rec.source_document_Line_id,
                  l_copied_rec.source_document_type_id,
                  l_copied_rec.split_by,
                  l_copied_rec.line_set_id,
                  l_copied_rec.item_type_code,
                  l_copied_rec.service_reference_line_id,
                  l_copied_rec.link_to_line_id,
		  l_copied_rec.top_model_line_id;--9534576

    CLOSE C_Line_Nums;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CLOSING C_LINE_NUMS ' , 1 ) ;
    END IF;

    -- Initialize the counters.
    l_line_number_ctr := NULL;
    l_shipment_number_ctr := NULL;
    l_option_number_ctr := NULL;
    l_comp_number_ctr := NULL;
    l_service_number_ctr := NULL;
    l_split_by := NULL;
    l_split_from_line_id := NULL;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'C_LINE_NUMS COUNT IS '||L_COPIED_REC.LINE_ID.COUNT , 1 ) ;
    END IF;

    -- Debugging loop, should be taken out
    FOR i in 1..l_copied_rec.line_id.COUNT LOOP
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE ID IS '||L_COPIED_REC.LINE_ID( I ) , 1 ) ;
           oe_debug_pub.add(  'ITEM TYPE CODE IS '||L_COPIED_REC.ITEM_TYPE_CODE ( I ) , 1 ) ;
           oe_debug_pub.add(  'set id IS '||L_COPIED_REC.line_set_id( I ) , 1 ) ;
        END IF;
    END LOOP;

    l_prev_line_number := NULL;
    l_line_number := NULL;

    FOR i in 1..l_copied_rec.line_id.COUNT LOOP

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ITEM TYPE CODE IS '||L_COPIED_REC.ITEM_TYPE_CODE ( I ) , 1 ) ;
    END IF;
        -- Keep track of the original line_number
        l_line_number := l_copied_rec.line_number(i);

        -- Need to track the shipment_numbers for Split Line Cases.
        -- So initialize is by setting to its own shipment_number returned by
        -- the l_copied_rec cursor

        l_shipment_num_tbl(i) := l_copied_rec.shipment_number(i);
           l_option_num_tbl(i)   := l_copied_rec.option_number(i); --Bug 5757050

        -- This table keeps track of the Split_From line index. It points to the
        -- the first split line in the line set. Initialize this to NULL.

        l_first_split_index(i) := NULL;

        -- This table is used to track the link to line for included items and
        -- it keeps the track for the MAX component number under a KIT.
        l_comp_number_tbl(i) := l_copied_rec.component_number(i);


        -- Loop through the  COPY Global Line Rec to find the match for the
        -- line_id  and try to find whether the COPIED line is a aplit line.

        -- If the line is a Service Line then get the line number components
        -- from the parent line.

        IF l_copied_rec.item_type_code(i) = 'SERVICE' AND
           l_copied_rec.service_reference_line_id(i) IS NOT NULL
        THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ENTERING SERVICE LINE' , 1 ) ;
         END IF;

            FOR m in REVERSE 1..(i-1) LOOP
                IF l_copied_rec.line_id(m) =
                   l_copied_rec.service_reference_line_id(i)
                THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ENTERING SERVICE LINE M IS ' ||M , 1 ) ;
         END IF;
                    l_copied_rec.line_number(i) := l_copied_rec.line_number(m);
                    l_copied_rec.shipment_number(i) :=
                                               l_copied_rec.shipment_number(m);
                    l_copied_rec.option_number(i) :=
                                               l_copied_rec.option_number(m);
                    l_copied_rec.component_number(i) :=
                                             l_copied_rec.component_number(m);
                    l_line_number_ctr := l_copied_rec.line_number(i);
                    l_shipment_number_ctr := l_copied_rec.shipment_number(i);
                    l_option_number_ctr := l_copied_rec.option_number(i);
                    l_comp_number_ctr := l_copied_rec.component_number(i);

                    GOTO SERVICE_NUMBER;
                END IF;

            END LOOP;

        END IF;

        -- If the line is an Included Item Line then get the line number
        -- components from the link to line id.

        IF l_copied_rec.item_type_code(i) = 'INCLUDED'
        THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ENTERING INCLUDED ITEM LINE ' , 1 ) ;
         END IF;
            -- Find the link_to_line_id to get the line numbers..
            FOR m in REVERSE 1..(i-1) LOOP
                IF l_copied_rec.line_id(m) =
                   l_copied_rec.link_to_line_id(i)
                THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINK TO LINE ID IS ' ||L_COPIED_REC.LINE_ID ( M ) , 1 ) ;
         END IF;
                    l_copied_rec.line_number(i) := l_copied_rec.line_number(m);
                    l_copied_rec.shipment_number(i) :=
                                               l_copied_rec.shipment_number(m);
                    l_copied_rec.option_number(i) :=
                                               l_copied_rec.option_number(m);
                    l_line_number_ctr := l_copied_rec.line_number(i);
                    l_shipment_number_ctr := l_copied_rec.shipment_number(i);
                    l_option_number_ctr := l_copied_rec.option_number(i);
                    l_comp_number_tbl(m) := nvl(l_comp_number_tbl(m),0) + 1;
                    l_copied_rec.component_number(i) := l_comp_number_tbl(m);
                    l_comp_number_ctr := l_comp_number_tbl(m);

                    GOTO COMPONENT_NUMBER;
                END IF;

            END LOOP;

        END IF;

	 /* Bug 5757050 */
              -- If the line is an Option Item Line then get the line number
              -- options from the link to line id.

             -- IF l_copied_rec.item_type_code(i) = 'OPTION'
             IF l_copied_rec.item_type_code(i) in ('OPTION','CLASS')  --9534576
              THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'ENTERING OPTION ITEM LINE ' , 1 ) ;
               END IF;
                  -- Find the link_to_line_id to get the line numbers..
                  FOR m in REVERSE 1..(i-1) LOOP
                      IF l_copied_rec.line_id(m) =
                         l_copied_rec.link_to_line_id(i)
                      THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'LINK TO LINE ID IS ' ||L_COPIED_REC.LINE_ID ( M) , 1 ) ;
               END IF;
                          l_copied_rec.line_number(i) := l_copied_rec.line_number(m);
                          l_copied_rec.shipment_number(i) :=
                                                     l_copied_rec.shipment_number(m);

      		    l_option_num_tbl(m) := NVL(l_option_num_tbl(m),0) + 1;
                          l_copied_rec.option_number(i) := l_option_num_tbl(m);
                    l_copied_rec.component_number(i) := l_copied_rec.component_number(m);


		l_line_number_ctr := l_copied_rec.line_number(i);
		l_shipment_number_ctr := l_copied_rec.shipment_number(i);
		l_option_number_ctr := l_option_num_tbl(m);
		l_comp_number_ctr := l_copied_rec.component_number(i);
		----9534576 adding new loop
			FOR n IN REVERSE 1..(i-1) LOOP

                           IF  l_copied_rec.top_model_line_id(n)=l_copied_rec.top_model_line_id(i)
                           AND l_copied_rec.option_number(n)>= l_option_number_ctr THEN
			   --suneela loop

                               l_option_number_ctr := l_copied_rec.option_number(n)+1;
                               --   l_option_num_tbl(m) :=  l_option_number_ctr;
                               l_copied_rec.option_number(i) := l_option_number_ctr;

                           END IF ;

                        END LOOP ;
		   ----9534576 ending new loop
		GOTO OPTION_NUMBER;
	    END IF;

	END LOOP;

    END IF;
   /*END  Bug 5757050 */

        -- Ignore the line if it is not created by COPY. This may also include
        -- lines which are created as a part of the COPY call.

        IF NOT OE_GLOBALS.EQUAL(l_copied_rec.source_document_type_id(i),2) THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'THIS IS NON COPIED LINE' , 1 ) ;
            END IF;
            GOTO NOT_COPIED_LINE;
        END IF;

        -- Loop through the global copy rec to find out the match for Split Line
        -- cases.

        FOR j in 1..G_Line_Num_Rec.line_id.COUNT LOOP

            -- If the line is not a SPLIT line case then assign line numbers
            -- from the counters.

            IF NOT ( l_copied_rec.line_id(i) = G_Line_Num_Rec.new_line_id(j) AND
                G_Line_Num_Rec.split_from_line_id(j) IS NOT NULL AND
                 l_copied_rec.line_set_id(i) IS NOT NULL)
            THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'NON-SPLIT LINE' , 1 ) ;
                END IF;
                goto CONTINUE_LOOP;
            END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SEARCHING FOR MATCH' , 1 ) ;
            END IF;
            -- Loop through the Copied Rec of tables to find the parent line
            FOR m in REVERSE 1..(i-1) LOOP

                IF G_Line_Num_Rec.split_from_line_id(j) =
                   l_copied_rec.line_id(m)
                THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW_LINE_ID IS '||G_LINE_NUM_REC.NEW_LINE_ID ( J ) , 1 ) ;
             oe_debug_pub.add(  'COPY LINE_ID IS '||L_COPIED_REC.LINE_ID ( I ) , 1 ) ;
             oe_debug_pub.add(  'SPLIT_FROM_LINE_ID IS '||G_LINE_NUM_REC.SPLIT_FROM_LINE_ID ( J ) , 1 ) ;
             oe_debug_pub.add(  'MATCH FOUND WITH SPLIT FROM LINE_ID' , 1 ) ;
         END IF;
                    IF l_copied_rec.line_set_id(m) IS NULL THEN

                        SELECT OE_SETS_S.NEXTVAL
                        INTO   l_copied_rec.line_set_id(m)
                        FROM   DUAL;
                        /*
                        Create_Line_Set(
                               p_line_id => l_copied_rec.line_id(m),
                               p_line_set_id => l_copied_rec.line_set_id(m)
                               );
                        */
                    END IF;

                    -- Set the split_by on the parent line.
                    l_copied_rec.split_by(m) := 'USER';

                    l_copied_rec.line_number(i) := l_copied_rec.line_number(m);
                    l_copied_rec.line_set_id(i) := l_copied_rec.line_set_id(m);
                    l_first_split_index(i) := m;

                    -- Added logic to figure out the original line in the
                    -- Split Set. l_first_split_index will store the split from
                    -- line index for each line.

                    k := i;
                    l_counter := 1;
                    WHILE (l_first_split_index(k) is NOT NULL)
                    LOOP
                        k := l_first_split_index(k);
                        l_counter := l_counter + 1;
                        IF l_counter > l_copied_rec.line_id.COUNT THEN
                            EXIT;
                        END IF;

                    END LOOP;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'THE SPLIT FROM IS M '||M , 1 ) ;
                   oe_debug_pub.add(  'THE L_COUNTER IS '||L_COUNTER , 1 ) ;
                   oe_debug_pub.add(  'THE FIRST SPLIT FROM INDEX K IS '||K , 1 ) ;
                   oe_debug_pub.add(  'SHIPMENT_NUMBER FOR K IS '||L_SHIPMENT_NUM_TBL ( K ) , 1 ) ;
               END IF;

                    l_shipment_num_tbl(k) := l_shipment_num_tbl(k) + 1;

                    -- Set the shipment number
                    l_copied_rec.shipment_number(i) := l_shipment_num_tbl(k);
		    l_shipment_number_ctr := l_copied_rec.shipment_number(i); --9534576
                    l_copied_rec.split_from_line_id(i) :=
                                          G_Line_Num_Rec.split_from_line_id(j);
                    l_copied_rec.split_by(i) := G_Line_Num_Rec.split_by(j);

                    l_shipment_num_tbl(i) := l_copied_rec.shipment_number(i);
                    l_copied_rec.option_number(i) :=
                           G_Line_Num_Rec.option_number(j);
                    l_copied_rec.component_number(i) :=
                           G_Line_Num_Rec.component_number(j);
                    l_copied_rec.service_number(i) :=
                           G_Line_Num_Rec.service_number(j);

                    GOTO post_line_ship;
                END IF;

            END LOOP;
            <<CONTINUE_LOOP>>
            NULL;
        END LOOP;

        <<NOT_COPIED_LINE>>


        IF l_copied_rec.line_number(i) IS NOT NULL AND
           NOT OE_GLOBALS.EQUAL(l_line_number_ctr,l_copied_rec.line_number(i))
           AND NOT OE_GLOBALS.EQUAL(l_copied_rec.line_number(i),
                                    l_prev_line_number)
        THEN
            l_line_number_ctr := NVL(l_line_number_ctr,0) + 1;
            l_shipment_number_ctr := NULL;
            l_option_number_ctr := NULL;
            l_comp_number_ctr := NULL;
            l_service_number_ctr := NULL;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'IN L_LINE_NUMBER_CTR' , 1 ) ;
            END IF;
        END IF;

        l_copied_rec.line_number(i) := l_line_number_ctr;

        IF l_copied_rec.shipment_number(i) IS NOT NULL AND
           NOT OE_GLOBALS.EQUAL(l_shipment_number_ctr,
                                l_copied_rec.shipment_number(i))
        THEN
           -- l_shipment_number_ctr := NVL(l_shipment_number_ctr,0) + 1;
        IF l_shipment_number_ctr IS NULL
        OR l_shipment_number_ctr<l_copied_rec.shipment_number(i)THEN  --9534576
            l_shipment_number_ctr := NVL(l_shipment_number_ctr,0) + 1;
	END IF ; --9534576
            l_option_number_ctr := NULL;
            l_comp_number_ctr := NULL;
            l_service_number_ctr := NULL;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'IN L_SHIPMENT_NUMBER_CTR' , 1 ) ;
            END IF;
        END IF;

        l_copied_rec.shipment_number(i) := l_shipment_number_ctr;

	<<OPTION_NUMBER>> --Bug5757050
        IF l_copied_rec.option_number(i) IS NOT NULL AND
           NOT OE_GLOBALS.EQUAL(l_option_number_ctr,
                                l_copied_rec.option_number(i))
        THEN
            l_option_number_ctr := NVL(l_option_number_ctr,0) + 1;
            l_comp_number_ctr := NULL;
            l_service_number_ctr := NULL;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'IN L_OPTION_NUMBER_CTR' , 1 ) ;
            END IF;
        END IF;

        l_copied_rec.option_number(i) := l_option_number_ctr;

        <<COMPONENT_NUMBER>>
        IF l_copied_rec.component_number(i) IS NOT NULL AND
           NOT OE_GLOBALS.EQUAL(l_comp_number_ctr,
                                l_copied_rec.component_number(i))
        THEN
            l_comp_number_ctr := NVL(l_comp_number_ctr,0) + 1;
            l_service_number_ctr := NULL;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'IN L_COMP_NUMBER_CTR' , 1 ) ;
            END IF;
        END IF;

        l_copied_rec.component_number(i) := l_comp_number_ctr;

        <<SERVICE_NUMBER>>
        IF l_copied_rec.service_number(i) IS NOT NULL AND
           NOT OE_GLOBALS.EQUAL(l_service_number_ctr,
                                l_copied_rec.service_number(i))
        THEN
            l_service_number_ctr := NVL(l_service_number_ctr,0) + 1;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'IN L_SERVICE_NUMBER_CTR' , 1 ) ;
            END IF;
            l_copied_rec.service_number(i) := l_service_number_ctr;
        END IF;


        <<post_line_ship>> -- All Numbers already assigned.

        NULL;
        l_prev_line_number := l_line_number;
    END LOOP;

    -- Added following loop for debuging
    FOR i in 1..l_copied_rec.line_id.COUNT LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE ID IS '||L_COPIED_REC.LINE_ID ( I ) , 1 ) ;
            oe_debug_pub.add(  'ITEM TYPE CODE IS '||L_COPIED_REC.ITEM_TYPE_CODE ( I ) , 1 ) ;
        END IF;

    END LOOP;
    k := l_copied_rec.line_id.COUNT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE ORDER LINES IN BULK' , 1 ) ;
    END IF;
    FORALL i in 1..K
        UPDATE OE_ORDER_LINES
        SET line_number = l_copied_rec.line_number(i)
        , shipment_number = l_copied_rec.shipment_number(i)
        , option_number = l_copied_rec.option_number(i)
        , component_number = l_copied_rec.component_number(i)
        , service_number = l_copied_rec.service_number(i)
        , split_from_line_id = l_copied_rec.split_from_line_id(i)
        , split_by = l_copied_rec.split_by(i)
        , line_set_id = l_copied_rec.line_set_id(i)
        WHERE line_id = l_copied_rec.line_id(i);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' AFTER UPDATE ORDER LINES IN BULK' , 1 ) ;
    END IF;
    l_copied_rec.line_id.delete;
    l_copied_rec.line_number.delete;
    l_copied_rec.shipment_number.delete;
    l_copied_rec.option_number.delete;
    l_copied_rec.component_number.delete;
    l_copied_rec.service_number.delete;
    l_copied_rec.split_from_line_id.delete;
    l_copied_rec.source_document_Line_id.delete;
    l_copied_rec.source_document_type_id.delete;
    l_copied_rec.split_by.delete;
    l_copied_rec.line_set_id.delete;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CLEAR L_COPY_REC' , 1 ) ;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , PROCESS_LINE_NUMBERS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Process_Line_Numbers'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Process_Line_Numbers;

PROCEDURE Create_Line_Set(
                 p_src_line_id  IN NUMBER,
                 p_line_id      IN NUMBER,
                 p_line_set_id  IN NUMBER,
                 p_header_id    IN NUMBER,
                 p_line_type_id IN NUMBER
                 ) IS
                 --
                 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                 --
BEGIN

    INSERT INTO OE_SETS(
      SET_ID
    , SET_NAME
    , SET_TYPE
    , Header_Id
    , inventory_item_id
    , ordered_quantity_uom
    , line_type_id
    , Ship_tolerance_above
    , ship_tolerance_below
    , CREATED_BY
    , CREATION_DATE
    , UPDATE_DATE
    , UPDATED_BY
    )
    SELECT
      p_line_set_id
    , to_char(p_line_id)
    , 'SPLIT'
    , p_header_id
    , l.inventory_item_id
    , l.order_quantity_uom
    , p_line_type_id
    , l.Ship_tolerance_above
    , l.ship_tolerance_below
    , FND_GLOBAL.USER_ID
    , sysdate
    , sysdate
    , 1001
    FROM OE_ORDER_LINES l
    WHERE line_id = p_src_line_id;

END Create_Line_Set;

-- Comment Label for procedure added as part of Inline Documentation Drive.
---------------------------------------------------------------------------------
-- Procedure Name : Sort_Line_Tbl
-- Input Params   : p_line_id_tbl       : Table of Lines to be sorted.
--                  p_version_number    : Version of Lines to be sorted for Copy.
--                  p_phase_change_flag : To designate whether phase has changed
--                                        from Fulfillment to Negotiation or
--                                        vice versa.
--                  p_num_lines         : Number of Lines to be sorted.
-- Output Params  : x_line_tbl          : Sorted table of lines for Copy.
-- Description    : This procedure sorts the Table of Lines that need to be copied
--                  and gets them ready for Copy in Order. If there are any
--                  Configuration lines, or lines pertaining to any particular
--                  sales order version that need to be copied, it gets those
--                  lines in order and returns the list of sorted lines ready to
--                  be copied in the x_line_tbl. This procedure is exclusively
--                  used in this package only and in this particular flow only
--                  and not used anywhere else in any other flow in the product.
--                  This is called from the Load Lines procedure if any
--                  lines are being copied.
---------------------------------------------------------------------------------

PROCEDURE sort_line_tbl(p_line_id_tbl  IN OE_GLOBALS.Selected_Record_Tbl,
                         p_version_number IN NUMBER,
                         p_phase_change_flag IN VARCHAR2,
                         p_num_lines  IN NUMBER,
                         x_line_tbl   IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type)
IS
 i              binary_integer := 1;
 j              binary_integer := 1;
 l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_line_id      T_NUM := T_NUM();
 l_source       T_V1  := T_V1();
 l_line_rec     OE_Order_PUB.Line_Rec_Type;
 CURSOR C_MODEL IS
     SELECT line_id
     FROM OE_COPY_LINE_SORT_TMP
     WHERE top_model_line_id = line_id;

BEGIN
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('Entering load_lines '||to_char(p_num_lines));
    END IF;
    -- Extend the tables
    l_line_id.EXTEND(p_num_lines);

    -- Get the line ids sorted and insert them into the COPY temp table

    i:= p_line_id_tbl.FIRST;
    WHILE i <= p_line_id_tbl.LAST LOOP
        l_line_id(j) := p_line_id_tbl(i).id1;
        IF l_debug_level > 0 THEN
            oe_debug_pub.add(' The line id is '|| l_line_id(j),1);
        END IF;
        j := j + 1;
        i := p_line_id_tbl.NEXT(i);
    END LOOP;

    -- Few code changes have been done for bug 7443507. This is just for performance
    -- tuning. To remove NVL function from query, the value of the p_version_number
    -- is been checked before the query and accordingly the query is modified to
    -- either check for or not check the p_version_number value, in new IF - ELSE.
    -- Also, the condition to check for line_id not being same as top_model_line_id,
    -- the condition line_id <> top_model_line_id was commented and the item_type_code
    -- condition was modified to include 'MODEL' and 'KIT', wherever needed.

    IF p_phase_change_flag = 'Y' THEN
        IF l_debug_level > 0 THEN
            oe_debug_pub.add(' For Phase Change ',1);
        END IF;

	IF p_version_number IS NOT NULL THEN --bug 7443507

        FORALL i IN 1..l_line_id.COUNT
            INSERT INTO OE_COPY_LINE_SORT_TMP(
            line_id,
            version_number,
            header_id,
            line_number,
            shipment_number,
            option_number,
            component_number,
            service_number,
            phase_change_flag,
            top_model_line_id,
            item_type_code
            )
            SELECT
              l_line_id(i),
              p_version_number,
              l.header_id,
              l.line_number,
              l.shipment_number,
              l.option_number,
              l.component_number,
              l.service_number,
              'Y',
              l.top_model_line_id,
              l.item_type_code
            FROM
              oe_order_lines_history l
            WHERE l.line_id = l_line_id(i)
            --and l.version_number = NVL(p_version_number,l.version_number) -- bug 7443507
            and l.version_number = p_version_number -- bug 7443507
            and l.phase_change_flag = 'Y';

        ELSE -- bug 7443507

        FORALL i IN 1..l_line_id.COUNT

        -- bug 7443507 new code added
	    INSERT INTO OE_COPY_LINE_SORT_TMP(
            line_id,
            version_number,
            header_id,
            line_number,
            shipment_number,
            option_number,
            component_number,
            service_number,
            phase_change_flag,
            top_model_line_id,
            item_type_code
            )
            SELECT
              l_line_id(i),
              p_version_number,
              l.header_id,
              l.line_number,
              l.shipment_number,
              l.option_number,
              l.component_number,
              l.service_number,
              'Y',
              l.top_model_line_id,
              l.item_type_code
            FROM
              oe_order_lines_history l
            WHERE l.line_id = l_line_id(i)
            and l.phase_change_flag = 'Y';

        -- bug 7443507 new code ends.
        END IF; -- bug 7443507

            -- For line level copy, we are exploding the full config if
            -- top model line has been selected for copy.
            IF G_NEED_TO_EXPLODE_CONFIG THEN
                DELETE FROM OE_COPY_LINE_SORT_TMP a
                WHERE a.top_model_line_id is NOT NULL
                AND a.line_id <> a.top_model_line_id
                AND EXISTS (select b.line_id
                            from OE_COPY_LINE_SORT_TMP b
                            WHERE b.line_id = a.top_model_line_id);

                -- Select records for Model Line, get all child lines except
                -- for CONFIG item and INCLUDED items as we do not copy them.

    		IF p_version_number IS NOT NULL THEN -- bug 7443507

                INSERT INTO OE_COPY_LINE_SORT_TMP(
                  line_id,
                  version_number,
                  header_id,
                  line_number,
                  shipment_number,
                  option_number,
                  component_number,
                  service_number,
                  phase_change_flag,
                  top_model_line_id,
                  item_type_code
                   )
                SELECT
                  l.line_id,
                  p_version_number,
                  l.header_id,
                  l.line_number,
                  l.shipment_number,
                  l.option_number,
                  l.component_number,
                  l.service_number,
                  'Y',
                  l.top_model_line_id,
                  l.item_type_code
                FROM
                  oe_order_lines_history l,
                  oe_copy_line_sort_tmp c
                WHERE c.line_id = c.top_model_line_id
                and l.top_model_line_id = c.line_id
                --and l.line_id <> l.top_model_line_id -- bug 7443507
                and l.item_type_code not in ('CONFIG','INCLUDED','MODEL','KIT') -- bug 7443507
                --and l.version_number = NVL(p_version_number,l.version_number) -- bug 7443507
                and l.version_number = p_version_number -- bug 7443507
                and l.phase_change_flag = 'Y';

             	ELSE --bug 7443507
             	-- bug 7443507 new code added
             	INSERT INTO OE_COPY_LINE_SORT_TMP(
                  line_id,
                  version_number,
                  header_id,
                  line_number,
                  shipment_number,
                  option_number,
                  component_number,
                  service_number,
                  phase_change_flag,
                  top_model_line_id,
                  item_type_code
                   )
                SELECT
                  l.line_id,
                  p_version_number,
                  l.header_id,
                  l.line_number,
                  l.shipment_number,
                  l.option_number,
                  l.component_number,
                  l.service_number,
                  'Y',
                  l.top_model_line_id,
                  l.item_type_code
                FROM
                  oe_order_lines_history l,
                  oe_copy_line_sort_tmp c
                WHERE c.line_id = c.top_model_line_id
                and l.top_model_line_id = c.line_id
                and l.item_type_code not in ('CONFIG','INCLUDED','MODEL','KIT')
                and l.phase_change_flag = 'Y';

             	--bug 7443507 new code ends
             	END IF; --bug 7443507

            END IF; -- IF G_NEED_TO_EXPLODE_CONFIG THEN
    ELSE

	IF p_version_number IS NOT NULL THEN -- bug 7443507

        FORALL i IN 1..l_line_id.COUNT
            INSERT INTO OE_COPY_LINE_SORT_TMP(
            line_id,
            version_number,
            header_id,
            line_number,
            shipment_number,
            option_number,
            component_number,
            service_number,
            top_model_line_id,
            item_type_code
            )
            SELECT
              l_line_id(i),
              p_version_number,
              l.header_id,
              l.line_number,
              l.shipment_number,
              l.option_number,
              l.component_number,
              l.service_number,
              l.top_model_line_id,
              l.item_type_code
            FROM
              oe_order_lines l,
              oe_order_headers h
            WHERE l.line_id = l_line_id(i)
            and l.header_id = h.header_id
            --and h.version_number = NVL(p_version_number,h.version_number) -- bug 7443507
            and h.version_number = p_version_number -- bug 7443507
            UNION
            SELECT
              l_line_id(i),
              p_version_number,
              l.header_id,
              l.line_number,
              l.shipment_number,
              l.option_number,
              l.component_number,
              l.service_number,
              l.top_model_line_id,
              l.item_type_code
            FROM
              oe_order_lines_history l
            WHERE l.line_id = l_line_id(i)
            --and l.version_number = NVL(p_version_number,-1) --bug 7443507
            and l.version_number = p_version_number -- bug 7443507
            and l.version_flag = 'Y';

        ELSE --bug 7443507

        FORALL i IN 1..l_line_id.COUNT
        --bug 7443507 new code added
            INSERT INTO OE_COPY_LINE_SORT_TMP(
	        line_id,
	        version_number,
	        header_id,
	        line_number,
	        shipment_number,
	        option_number,
	        component_number,
	        service_number,
	        top_model_line_id,
	        item_type_code
	        )
	        SELECT
	        l_line_id(i),
	        p_version_number,
	        l.header_id,
	        l.line_number,
	        l.shipment_number,
	        l.option_number,
	        l.component_number,
	        l.service_number,
	        l.top_model_line_id,
	        l.item_type_code
	        FROM
	        oe_order_lines l,
	        oe_order_headers h
	        WHERE l.line_id = l_line_id(i)
	        and l.header_id = h.header_id;

	--bug 7443507 new code ends
        END IF; --bug 7443507


            -- For line level copy, we are exploding the full config if
            -- top model line has been selected for copy.

            IF G_NEED_TO_EXPLODE_CONFIG THEN

                DELETE FROM OE_COPY_LINE_SORT_TMP a
                WHERE a.top_model_line_id is NOT NULL
                AND a.line_id <> a.top_model_line_id
                AND EXISTS (select b.line_id
                            from OE_COPY_LINE_SORT_TMP b
                            WHERE b.line_id = a.top_model_line_id);

                -- Select records for Model Line, get all child lines except
                -- for CONFIG item and INCLUDED items as we do not copy them.

		IF p_version_number IS NOT NULL THEN -- bug 7443507

                INSERT INTO OE_COPY_LINE_SORT_TMP(
                  line_id,
                  version_number,
                  header_id,
                  line_number,
                  shipment_number,
                  option_number,
                  component_number,
                  service_number,
                  top_model_line_id,
                  item_type_code
                 )
                SELECT
                  l.line_id,
                  p_version_number,
                  l.header_id,
                  l.line_number,
                  l.shipment_number,
                  l.option_number,
                  l.component_number,
                  l.service_number,
                  l.top_model_line_id,
                  l.item_type_code
                FROM
                  oe_order_lines l,
                  oe_order_headers h,
                  oe_copy_line_sort_tmp c
                WHERE c.line_id = c.top_model_line_id
                and l.top_model_line_id = c.line_id
                --and l.line_id <> l.top_model_line_id --bug 7443507
                and l.item_type_code not in ('CONFIG','INCLUDED','MODEL','KIT') --bug 7443507
                and l.header_id = h.header_id
                --and h.version_number = NVL(p_version_number,h.version_number) --bug 7443507
                and h.version_number = p_version_number --bug 7443507
                UNION
                SELECT
                  l.line_id,
                  p_version_number,
                  l.header_id,
                  l.line_number,
                  l.shipment_number,
                  l.option_number,
                  l.component_number,
                  l.service_number,
                  l.top_model_line_id,
                  l.item_type_code
                FROM
                  oe_order_lines_history l,
                  oe_copy_line_sort_tmp c
                WHERE c.line_id = c.top_model_line_id
                and l.top_model_line_id = c.line_id
                --and l.line_id <> l.top_model_line_id -- bug 7443507
                and l.item_type_code not in ('CONFIG','INCLUDED','MODEL','KIT') -- bug 7443507
                --and l.version_number = NVL(p_version_number,-1) -- bug 7443507
                and l.version_number = p_version_number -- bug 7443507
                and l.version_flag = 'Y';

            	ELSE --bug 7443507
            	--bug 7443507 new code added

                INSERT INTO OE_COPY_LINE_SORT_TMP(
                  line_id,
                  version_number,
                  header_id,
                  line_number,
                  shipment_number,
                  option_number,
                  component_number,
                  service_number,
                  top_model_line_id,
                  item_type_code
                 )
                SELECT
                  l.line_id,
                  p_version_number,
                  l.header_id,
                  l.line_number,
                  l.shipment_number,
                  l.option_number,
                  l.component_number,
                  l.service_number,
                  l.top_model_line_id,
                  l.item_type_code
                FROM
                  oe_order_lines l,
                  oe_order_headers h,
                  oe_copy_line_sort_tmp c
                WHERE c.line_id = c.top_model_line_id
                and l.top_model_line_id = c.line_id
                and l.item_type_code not in ('CONFIG','INCLUDED','MODEL','KIT')
                and l.header_id = h.header_id;

            	--bug 7443507 new code ends
            	END IF; --bug 7443507

         END IF; -- IF G_NEED_TO_EXPLODE_CONFIG THEN

    END IF;

    -- Clear the line_id table

    IF l_line_id.COUNT > 0 THEN
        l_line_id.DELETE;
    END IF;

    -- Select the data from TEMP table and sort it by line numbers..

    SELECT line_id
    BULK COLLECT INTO
          l_line_id
    FROM OE_COPY_LINE_SORT_TMP
    ORDER BY header_id, line_number, shipment_number, NVL(option_number, -1),
    NVL(component_number,-1),NVL(service_number,-1);

    -- Populate the full line record by calling the oe_line_util.query_row

    FOR i IN 1..l_line_id.COUNT LOOP

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
            OE_Version_History_UTIL.query_row(
                                p_line_id => l_line_id(i)
                               ,p_version_number => p_version_number
                               ,p_phase_change_flag => p_phase_change_flag
                               ,x_line_rec  => l_line_rec);
        ELSE
            OE_Line_Util.Query_Row(p_line_id  => l_line_id(i),
                               x_line_rec => l_line_rec);
        END IF;
        x_line_tbl(i) := l_line_rec;
    END LOOP;
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('The Line Table Count is ' || x_line_tbl.COUNT);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        oe_debug_pub.add('In Others exception');
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END sort_line_tbl;


PROCEDURE copy_line_dff_from_ref
(p_ref_line_rec IN OE_Order_PUB.Line_Rec_Type,
 p_x_line_rec IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type)
IS
BEGIN
    p_x_line_rec.context := p_ref_line_rec.context;
    p_x_line_rec.attribute1 := p_ref_line_rec.attribute1;
    p_x_line_rec.attribute2 := p_ref_line_rec.attribute2;
    p_x_line_rec.attribute3 := p_ref_line_rec.attribute3;
    p_x_line_rec.attribute4 := p_ref_line_rec.attribute4;
    p_x_line_rec.attribute5 := p_ref_line_rec.attribute5;
    p_x_line_rec.attribute6 := p_ref_line_rec.attribute6;
    p_x_line_rec.attribute7 := p_ref_line_rec.attribute7;
    p_x_line_rec.attribute8 := p_ref_line_rec.attribute8;
    p_x_line_rec.attribute9 := p_ref_line_rec.attribute9;
    p_x_line_rec.attribute10 := p_ref_line_rec.attribute10;
    p_x_line_rec.attribute11 := p_ref_line_rec.attribute11;
    p_x_line_rec.attribute12 := p_ref_line_rec.attribute12;
    p_x_line_rec.attribute13 := p_ref_line_rec.attribute13;
    p_x_line_rec.attribute14 := p_ref_line_rec.attribute14;
    p_x_line_rec.attribute15 := p_ref_line_rec.attribute15;
    p_x_line_rec.attribute16 := p_ref_line_rec.attribute16;
    p_x_line_rec.attribute17 := p_ref_line_rec.attribute17;
    p_x_line_rec.attribute18 := p_ref_line_rec.attribute18;
    p_x_line_rec.attribute19 := p_ref_line_rec.attribute19;
    p_x_line_rec.attribute20 := p_ref_line_rec.attribute20;

    -- Retain the Global DFF Info
    p_x_line_rec.global_attribute_category
                              := p_ref_line_rec.global_attribute_category;
    p_x_line_rec.global_attribute1 := p_ref_line_rec.global_attribute1;
    p_x_line_rec.global_attribute2 := p_ref_line_rec.global_attribute2;
    p_x_line_rec.global_attribute3 := p_ref_line_rec.global_attribute3;
    p_x_line_rec.global_attribute4 := p_ref_line_rec.global_attribute4;
    p_x_line_rec.global_attribute5 := p_ref_line_rec.global_attribute5;
    p_x_line_rec.global_attribute6 := p_ref_line_rec.global_attribute6;
    p_x_line_rec.global_attribute7 := p_ref_line_rec.global_attribute7;
    p_x_line_rec.global_attribute8 := p_ref_line_rec.global_attribute8;
    p_x_line_rec.global_attribute9 := p_ref_line_rec.global_attribute9;
    p_x_line_rec.global_attribute10 := p_ref_line_rec.global_attribute10;
    p_x_line_rec.global_attribute11 := p_ref_line_rec.global_attribute11;
    p_x_line_rec.global_attribute12 := p_ref_line_rec.global_attribute12;
    p_x_line_rec.global_attribute13 := p_ref_line_rec.global_attribute13;
    p_x_line_rec.global_attribute14 := p_ref_line_rec.global_attribute14;
    p_x_line_rec.global_attribute15 := p_ref_line_rec.global_attribute15;
    p_x_line_rec.global_attribute16 := p_ref_line_rec.global_attribute16;
    p_x_line_rec.global_attribute17 := p_ref_line_rec.global_attribute17;
    p_x_line_rec.global_attribute18 := p_ref_line_rec.global_attribute18;
    p_x_line_rec.global_attribute19 := p_ref_line_rec.global_attribute19;
    p_x_line_rec.global_attribute20 := p_ref_line_rec.global_attribute20;

    -- Retain the Industry DFF Info
    p_x_line_rec.industry_context    := p_ref_line_rec.industry_context;
    p_x_line_rec.industry_attribute1 := p_ref_line_rec.industry_attribute1;
    p_x_line_rec.industry_attribute2 := p_ref_line_rec.industry_attribute2;
    p_x_line_rec.industry_attribute3 := p_ref_line_rec.industry_attribute3;
    p_x_line_rec.industry_attribute4 := p_ref_line_rec.industry_attribute4;
    p_x_line_rec.industry_attribute5 := p_ref_line_rec.industry_attribute5;
    p_x_line_rec.industry_attribute6 := p_ref_line_rec.industry_attribute6;
    p_x_line_rec.industry_attribute7 := p_ref_line_rec.industry_attribute7;
    p_x_line_rec.industry_attribute8 := p_ref_line_rec.industry_attribute8;
    p_x_line_rec.industry_attribute9 := p_ref_line_rec.industry_attribute9;
    p_x_line_rec.industry_attribute10 := p_ref_line_rec.industry_attribute10;

    -- Retain the Trading Partner DFF Info
    p_x_line_rec.tp_context    := p_ref_line_rec.tp_context;
    p_x_line_rec.tp_attribute1 := p_ref_line_rec.tp_attribute1;
    p_x_line_rec.tp_attribute2 := p_ref_line_rec.tp_attribute2;
    p_x_line_rec.tp_attribute3 := p_ref_line_rec.tp_attribute3;
    p_x_line_rec.tp_attribute4 := p_ref_line_rec.tp_attribute4;
    p_x_line_rec.tp_attribute5 := p_ref_line_rec.tp_attribute5;
    p_x_line_rec.tp_attribute6 := p_ref_line_rec.tp_attribute6;
    p_x_line_rec.tp_attribute7 := p_ref_line_rec.tp_attribute7;
    p_x_line_rec.tp_attribute8 := p_ref_line_rec.tp_attribute8;
    p_x_line_rec.tp_attribute9 := p_ref_line_rec.tp_attribute9;
    p_x_line_rec.tp_attribute10 := p_ref_line_rec.tp_attribute10;
    p_x_line_rec.tp_attribute11 := p_ref_line_rec.tp_attribute11;
    p_x_line_rec.tp_attribute12 := p_ref_line_rec.tp_attribute12;
    p_x_line_rec.tp_attribute13 := p_ref_line_rec.tp_attribute13;
    p_x_line_rec.tp_attribute14 := p_ref_line_rec.tp_attribute14;
    p_x_line_rec.tp_attribute15 := p_ref_line_rec.tp_attribute15;

END copy_line_dff_from_ref;

Function CALL_DFF_COPY_EXTN_API(p_org_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN
IS
BEGIN
    IF OE_COPY_UTIL_EXT.G_CALL_API = 'Y' THEN
        RETURN TRUE;
    ELSIF OE_Sys_Parameters.value('COPY_LINE_DFF_EXT_API',p_org_id) = 'Y'
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END CALL_DFF_COPY_EXTN_API;

-- Copy Sets ER #2830872 , #1566254 Begin.

------------------------------------------------------------------------------------
-- Procedure Name : Copy_Line_Sets
-- Input Params   : p_old_header_id         : Header Id of Order of source Line.
--                  p_new_header_id         : Header Id of Order of destination Line.
--                  p_line_tbl              : Table of all new copied lines.
--                  p_copy_fulfillment_sets : Flag to check user preference.
--                  p_copy_ship_arr_sets    : Flag to check user preference.
-- Output Params  : x_result                : Flag to Check result of the Operation.
-- Description    : This procedure copies the set information for lines being copied.
--                  It check the value of the Flags for user preference before
--                  doing the operation for a particular Line.
--                  It takes header id of the source and destination lines and
--                  returns FND_API.G_RET_STS_SUCCESS if all sets were copied
--                  successfully. It returns FND_API.G_RET_STS_ERROR or
--                  G_RET_STS_UNEXP_ERROR if some or all sets are not copied.
--                  This procedure is used in this package and in this flow only
--                  and not used anywhere else in any other flow in the product.
--                  This is called from the Copy Order procedure if user selects
--                  fulfillment / ship / arrival sets to be copied.
------------------------------------------------------------------------------------

PROCEDURE COPY_LINE_SETS(
p_old_header_id         IN NUMBER,
p_new_header_id         IN NUMBER,
p_line_tbl              IN OE_Order_PUB.Line_Tbl_Type,
p_copy_fulfillment_sets IN BOOLEAN,
p_copy_ship_arr_sets    IN BOOLEAN,
x_result               OUT NOCOPY VARCHAR2)
IS

l_debug_level        CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_selected_line_tbl  OE_GLOBALS.Selected_Record_Tbl;
I                    NUMBER := 0;
l_set_id             NUMBER;
l_return_status      VARCHAR2(30);
l_msg_count          NUMBER :=0;
l_msg_data           VARCHAR2(2000) := '';

-- Cursor for finding all sets of a particular type from source order.
CURSOR set_cur(stype IN VARCHAR2)
IS
SELECT distinct set_id, set_name,set_type
  FROM oe_sets
 WHERE header_id = p_old_header_id
   AND set_type = stype
 ORDER BY set_id;

-- Cursor for finding all lines belonging to a particular ship set from source order.
CURSOR line_cur_ship(p_set_id IN NUMBER)
IS
SELECT l.line_id
  FROM oe_order_lines_all l
 WHERE l.ship_set_id = p_set_id;

-- Cursor for finding all lines belonging to a particular arrival set from source order.
CURSOR line_cur_arrival(p_set_id IN NUMBER)
IS
SELECT l.line_id
  FROM oe_order_lines_all l
 WHERE l.arrival_set_id = p_set_id;

-- Cursor for finding all lines belonging to a particular fulfillment set from source order.
CURSOR line_cur_fulfill(p_set_id IN NUMBER)
IS
SELECT l.line_id
  FROM oe_order_lines_all l,
       oe_line_sets ols
 WHERE l.line_id = ols.line_id
   AND l.header_id = p_old_header_id
   AND ols.set_id = p_set_id;

BEGIN

-- Initializing the result to Success.
x_result := FND_API.G_RET_STS_SUCCESS;
IF l_debug_level > 0 THEN
	oe_debug_pub.add(' Entering Copy Line Sets.');
END IF;
-- Copying Fulfillment Sets based on user preference.
IF p_copy_fulfillment_sets THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' Copying Fulfillment Sets.');
	END IF;

	FOR set_rec IN set_cur('FULFILLMENT_SET')
	LOOP
		-- Initializing processing tools.
		I := 0;
		l_selected_line_tbl.DELETE;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Copying Set ID :'||set_rec.set_id);
			oe_debug_pub.add(' Copying Set Name :'||set_rec.set_name);
			oe_debug_pub.add(' Copying Set Type :'||set_rec.set_type);
		END IF;

		-- Initializing the Line Table for Set processing in new header.
		FOR line_rec IN line_cur_fulfill(set_rec.set_id)
		LOOP
			IF p_line_tbl.Count > 0 THEN
			FOR lindex IN 1..p_line_tbl.Count
			LOOP
			IF p_line_tbl(lindex).source_document_line_id = line_rec.line_id
			AND (p_line_tbl(lindex).item_type_code = 'STANDARD' OR
			     p_line_tbl(lindex).item_type_code = 'MODEL'    OR
			     p_line_tbl(lindex).item_type_code = 'SERVICE'  OR
			     p_line_tbl(lindex).item_type_code = 'KIT')
			THEN
				-- Incrementing index and populating table.
				I := I + 1;
				l_selected_line_tbl(I).id1 := p_line_tbl(lindex).line_id;
			END IF;
			END LOOP;
			END IF;
		END LOOP;

		IF l_selected_line_tbl.COUNT > 0 THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Line Table Ready. Processing this set:'||set_rec.set_name);
			END IF;

			-- Processing the Set for New Lines.
			oe_set_util.Process_Sets
			(   p_selected_line_tbl    => l_selected_line_tbl,
			    p_record_count         => l_selected_line_tbl.COUNT,
			    p_set_name             => set_rec.set_name,
			    p_set_type             => 'FULFILLMENT',
			    p_operation            => 'ADD' ,
			    p_header_id            => p_new_header_id,
			    x_Set_Id               => l_set_id,
			    x_return_status        => l_return_status,
			    x_msg_count            => l_msg_count ,
	        	    x_msg_data             => l_msg_data
	        	);

	       		-- Checking Result Status.
	      		IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	      		        IF l_debug_level > 0 THEN
	      			        oe_debug_pub.add(' Lines Copied to new/existing Set ID :'||l_set_id);
	      		        END IF;
	      		ELSE
				x_result := FND_API.G_RET_STS_ERROR;
				IF l_debug_level > 0 THEN
					oe_debug_pub.add(' Copy of Set has errors :'||l_msg_data);
        			END IF;
        			l_msg_count := 0;
				l_msg_data := '';
              		END IF;
                ELSE
                        IF l_debug_level > 0 THEN
                                oe_debug_pub.add(' Line Table Empty. Not processing this set:'||set_rec.set_name);
                        END IF;
              	END IF;
	END LOOP;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' Copied Fulfillment Sets.');
	END IF;
END IF; -- Copy of Fulfillment Sets

-- Copying Ship Sets based on user preference.
IF p_copy_ship_arr_sets THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' Copying Ship Sets.');
	END IF;
	FOR set_rec IN set_cur('SHIP_SET')
	LOOP
		-- Initializing processing tools.
		I := 0;
		l_selected_line_tbl.DELETE;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Copying Set ID :'||set_rec.set_id);
			oe_debug_pub.add(' Copying Set Name :'||set_rec.set_name);
			oe_debug_pub.add(' Copying Set Type :'||set_rec.set_type);
		END IF;

		-- Initializing the Line Table for Set processing in new header.
		FOR line_rec IN line_cur_ship(set_rec.set_id)
		LOOP
			IF p_line_tbl.Count > 0 THEN
			FOR lindex IN 1..p_line_tbl.Count
			LOOP
			IF p_line_tbl(lindex).source_document_line_id = line_rec.line_id
			AND (p_line_tbl(lindex).item_type_code = 'STANDARD' OR
			     p_line_tbl(lindex).item_type_code = 'MODEL'    OR
			     p_line_tbl(lindex).item_type_code = 'KIT')
			THEN
				-- Incrementing index and populating table.
				I := I + 1;
				l_selected_line_tbl(I).id1 := p_line_tbl(lindex).line_id;
			END IF;
			END LOOP;
			END IF;
		END LOOP;

		IF l_selected_line_tbl.COUNT > 0 THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Line Table Ready. Processing this set:'||set_rec.set_name);
			END IF;

			-- Processing the Set for New Lines.
			oe_set_util.Process_Sets
			(   p_selected_line_tbl    => l_selected_line_tbl,
			    p_record_count         => l_selected_line_tbl.COUNT,
			    p_set_name             => set_rec.set_name,
			    p_set_type             => 'SHIP',
			    p_operation            => 'ADD' ,
			    p_header_id            => p_new_header_id,
			    x_Set_Id               => l_set_id,
			    x_return_status        => l_return_status,
			    x_msg_count            => l_msg_count ,
	        	    x_msg_data             => l_msg_data
	        	);

	      		-- Checking Result Status.
	      		IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			       	IF l_debug_level > 0 THEN
				       	oe_debug_pub.add(' Lines copied to new/existing Set ID :'||l_set_id);
			       	END IF;
       	      		ELSE
				x_result := FND_API.G_RET_STS_ERROR;
				IF l_debug_level > 0 THEN
				   	oe_debug_pub.add(' Copy of Set has errors :'||l_msg_data);
        			END IF;
        			l_msg_count := 0;
				l_msg_data := '';
              		END IF;
                ELSE
                        IF l_debug_level > 0 THEN
                                oe_debug_pub.add(' Line Table Empty. Not processing this set:'||set_rec.set_name);
                        END IF;
              	END IF;
	END LOOP;

	oe_debug_pub.add(' Copied Ship Sets.');

END IF; -- Copy of Ship Sets

-- Copying Arrival Sets based on user preference.
IF p_copy_ship_arr_sets THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' Copying Arrival Sets.');
	END IF;

	FOR set_rec IN set_cur('ARRIVAL_SET')
	LOOP
	        -- Initializing processing tools.
		I := 0;
		l_selected_line_tbl.delete;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Copying Set ID :'||set_rec.set_id);
			oe_debug_pub.add(' Copying Set Name :'||set_rec.set_name);
			oe_debug_pub.add(' Copying Set Type :'||set_rec.set_type);
		END IF;

		-- Initializing the Line Table for Set processing in new header.
		FOR line_rec IN line_cur_arrival(set_rec.set_id)
		LOOP
			IF p_line_tbl.Count > 0 THEN
			FOR lindex IN 1..p_line_tbl.Count
			LOOP
			IF p_line_tbl(lindex).source_document_line_id = line_rec.line_id
			AND (p_line_tbl(lindex).item_type_code = 'STANDARD' OR
			     p_line_tbl(lindex).item_type_code = 'MODEL'    OR
			     p_line_tbl(lindex).item_type_code = 'KIT')
			THEN
				-- Incrementing index and populating table.
				I := I + 1;
				l_selected_line_tbl(I).id1 := p_line_tbl(lindex).line_id;
			END IF;
			END LOOP;
			END IF;
		END LOOP;

		IF l_selected_line_tbl.COUNT > 0 THEN

			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Line Table Ready. Processing this set:'||set_rec.set_name);
			END IF;

			-- Processing the Set for New Lines.
			oe_set_util.Process_Sets
			(   p_selected_line_tbl    => l_selected_line_tbl,
			    p_record_count         => l_selected_line_tbl.COUNT,
			    p_set_name             => set_rec.set_name,
			    p_set_type             => 'ARRIVAL',
			    p_operation            => 'ADD' ,
			    p_header_id            => p_new_header_id,
			    x_Set_Id               => l_set_id,
			    x_return_status        => l_return_status,
			    x_msg_count            => l_msg_count ,
	        	    x_msg_data             => l_msg_data
	        	);

	       		-- Checking Result Status.
	       		IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			       	IF l_debug_level > 0 THEN
			       		oe_debug_pub.add(' Lines copied to new/existing Set ID :'||l_set_id);
			       	END IF;
	       		ELSE
				x_result := FND_API.G_RET_STS_ERROR;
				IF l_debug_level > 0 THEN
					oe_debug_pub.add(' Copy of Set has errors :'||l_msg_data);
        			END IF;
        			l_msg_count := 0;
				l_msg_data := '';
               		END IF;
                ELSE
                        IF l_debug_level > 0 THEN
                                oe_debug_pub.add(' Line Table Empty. Not processing this set:'||set_rec.set_name);
                        END IF;
               	END IF;
	END LOOP;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' Copied Arrival Sets.');
	END IF;

END IF; -- Copy of Arrival Sets

EXCEPTION
WHEN OTHERS THEN

	x_result := FND_API.G_RET_STS_UNEXP_ERROR;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Unexpected Error Occured during Copy of Line Sets');
		oe_debug_pub.add(SQLERRM);
	END IF;

END COPY_LINE_SETS;

-- Copy Sets ER #2830872 , #1566254 End.

END OE_Order_Copy_Util;

/
