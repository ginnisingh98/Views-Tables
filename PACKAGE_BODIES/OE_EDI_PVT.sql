--------------------------------------------------------
--  DDL for Package Body OE_EDI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_EDI_PVT" AS
/* $Header: OEXVEDIB.pls 115.15 2004/04/20 05:39:59 jjmcfarl ship $ */

/*
---------------------------------------------------------------
--  Start of Comments
--  API name    OE_EDI_PVT
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
   p_header_rec		IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_header_adj_tbl     IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_header_scredit_tbl IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_line_tbl		IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_line_adj_tbl	IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_line_scredit_tbl   IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_lot_serial_tbl     IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type
  ,p_header_val_rec     IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_header_adj_val_tbl IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_header_scredit_val_tbl IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_line_val_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_line_adj_val_tbl   IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_line_scredit_val_tbl IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_lot_serial_val_tbl IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type
,p_return_status OUT NOCOPY VARCHAR2

) IS
   l_header_rec			OE_Order_Pub.Header_Rec_Type;
   l_header_adj_tbl		OE_Order_Pub.Header_Adj_Tbl_Type;
   l_header_scredit_tbl		OE_Order_Pub.Header_Scredit_Tbl_Type;
   l_line_tbl			OE_Order_Pub.Line_Tbl_Type;
   l_line_adj_tbl		OE_Order_Pub.Line_Adj_Tbl_Type;
   l_line_scredit_tbl		OE_Order_Pub.Line_Scredit_Tbl_Type;
   l_lot_serial_tbl		OE_Order_Pub.Lot_Serial_Tbl_Type;

   l_header_val_rec		OE_Order_Pub.Header_Val_Rec_Type;
   l_header_adj_val_tbl		OE_Order_Pub.Header_Adj_Val_Tbl_Type;
   l_header_scredit_val_tbl	OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
   l_line_val_tbl		OE_Order_Pub.Line_Val_Tbl_Type;
   l_line_adj_val_tbl		OE_Order_Pub.Line_Adj_Val_Tbl_Type;
   l_line_scredit_val_tbl	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
   l_lot_serial_val_tbl		OE_Order_Pub.Lot_Serial_Val_Tbl_Type;

   l_line_exists		VARCHAR2(1);
   l_change_sequence		VARCHAR2(50);
   l_orig_sys_line_ref		VARCHAR2(50);
   l_orig_sys_shipment_ref	VARCHAR2(50);
   l_line_count			NUMBER;
   l_line_id			NUMBER;
   l_line_number		NUMBER;
   l_shipment_number		NUMBER;
   l_option_number		NUMBER;
   l_header_ship_to_org_id	NUMBER;
   l_line_ship_to_org_id	NUMBER;

   G_IMPORT_SHIPMENTS           VARCHAR2(3);

   l_customer_key_profile    VARCHAR2(1)   :=  'N';
/* -----------------------------------------------------------
   Lines cursor: select only the open lines
   -----------------------------------------------------------
*/
    CURSOR l_line_cursor IS
    SELECT orig_sys_line_ref
         , orig_sys_shipment_ref
         , line_id
         , line_number
         , shipment_number
         , option_number
         , ship_to_org_id
      FROM oe_order_lines
     WHERE header_id 		    = l_header_rec.header_id
       AND nvl(ordered_quantity, 0) > 0
  ORDER BY orig_sys_line_ref, orig_sys_shipment_ref;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   l_header_rec			:= p_header_rec;
   l_header_adj_tbl		:= p_header_adj_tbl;
   l_header_scredit_tbl		:= p_header_scredit_tbl;
   l_line_tbl			:= p_line_tbl;
   l_line_adj_tbl		:= p_line_adj_tbl;
   l_line_scredit_tbl		:= p_line_scredit_tbl;
   l_lot_serial_tbl		:= p_lot_serial_tbl;

   l_header_val_rec		:= p_header_val_rec;
   l_header_adj_val_tbl		:= p_header_adj_val_tbl;
   l_header_scredit_val_tbl	:= p_header_scredit_val_tbl;
   l_line_val_tbl		:= p_line_val_tbl;
   l_line_adj_val_tbl		:= p_line_adj_val_tbl;
   l_line_scredit_val_tbl	:= p_line_scredit_val_tbl;
   l_lot_serial_val_tbl		:= p_lot_serial_val_tbl;

   p_return_status := FND_API.G_RET_STS_SUCCESS; /* Init to Success */

   fnd_profile.get('ONT_IMP_MULTIPLE_SHIPMENTS', G_IMPORT_SHIPMENTS);
   G_IMPORT_SHIPMENTS := nvl(G_IMPORT_SHIPMENTS, 'NO');


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DERIVED CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;



/* -----------------------------------------------------------
   Set message context
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT' ) ;
   END IF;

   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => l_header_rec.header_id
        ,p_line_id                    => null
--      ,p_batch_request_id           => l_header_rec.request_id
        ,p_order_source_id            => l_header_rec.order_source_id
        ,p_orig_sys_document_ref      => l_header_rec.orig_sys_document_ref
        ,p_change_sequence            => l_header_rec.change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

/* -----------------------------------------------------------
   Validate change sequence
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE VALIDATING CHANGE SEQUENCE' ) ;
   END IF;

 IF l_header_rec.force_apply_flag = 'Y' THEN
  IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FORCE APPLY FLAG IS SET, NOT CHECKING EXISTENCE OF CHANGE_SEQUENCE' ) ;
   END IF;
 ELSE
   IF  l_header_rec.operation IN (OE_Globals.G_OPR_CREATE,
				  OE_Globals.G_OPR_INSERT)
   THEN
    IF nvl(l_header_rec.change_sequence, ' ') <> ' ' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHANGE SEQUENCE NOT REQUIRED FOR NEW ORDERS... ' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_OI_CHANGE_SEQUENCE');
        OE_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   ELSIF  l_header_rec.operation = OE_Globals.G_OPR_DELETE THEN
    IF nvl(l_header_rec.change_sequence, ' ') <> ' ' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHANGE SEQUENCE NOT REQUIRED FOR DELETING EXISTING ORDERS... ' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_OI_CHANGE_SEQUENCE');
        OE_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   ELSIF  l_header_rec.operation = OE_Globals.G_OPR_UPDATE THEN
    IF nvl(l_header_rec.change_sequence,' ') = ' ' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHANGE SEQUENCE REQUIRED FOR CHANGES TO AN EXISTING ORDER... ' ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_OI_CHANGE_SEQUENCE');
        OE_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
/*     -----------------------------------------------------------
Validate change out nocopy of sequence

       -----------------------------------------------------------
*/
       IF l_debug_level  > 0 THEN
oe_debug_pub.add( 'BEFORE VALIDATING CHANGE OUT NOCOPY OF SEQUENCE' ) ;

       END IF;

       BEGIN
        SELECT change_sequence, ship_to_org_id
          INTO l_change_sequence, l_header_ship_to_org_id
          FROM oe_order_headers
         WHERE order_source_id       = l_header_rec.order_source_id
           AND orig_sys_document_ref = l_header_rec.orig_sys_document_ref
           AND decode(l_customer_key_profile, 'Y',
	       nvl(sold_to_org_id, FND_API.G_MISS_NUM), 1)
               = decode(l_customer_key_profile, 'Y',
	       nvl(l_header_rec.sold_to_org_id, FND_API.G_MISS_NUM), 1);

-- validation for whether change is out of sequence will be done in order import pre_process

        EXCEPTION
        WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
         END IF;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Pre_Process.header_change_sequence_validation');
         END IF;
       END;	  -- header change sequence is not null
    END IF;	 -- If header change sequence is...
   END IF;	-- If header operation code is...
  END IF;       -- force apply flag

/* -----------------------------------------------------------
   Default ship-to-location code for all existing lines if the
   code at the header level has changed.
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE DEFAULTING SHIP-TO-LOCATION FOR ALL OPEN SHIPMENTS' ) ;
   END IF;

   IF  l_header_rec.operation = OE_Globals.G_OPR_UPDATE AND -- update operation
       nvl(l_header_rec.change_sequence,' ') <> ' ' AND	-- new code not null
	  l_header_rec.ship_to_org_id <> FND_API.G_MISS_NUM AND
       nvl(l_header_rec.ship_to_org_id, FND_API.G_MISS_NUM) <>
       nvl(l_header_ship_to_org_id, FND_API.G_MISS_NUM) -- new code not same as old
   THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE READING ALL OPEN SHIPMENTS' ) ;
       END IF;

       OPEN l_line_cursor;
       LOOP
          FETCH l_line_cursor
           INTO l_orig_sys_line_ref
              , l_orig_sys_shipment_ref
              , l_line_id
              , l_line_number
              , l_shipment_number
              , l_option_number
              , l_line_ship_to_org_id;
           EXIT WHEN l_line_cursor%NOTFOUND;

       IF nvl(l_line_ship_to_org_id, l_header_ship_to_org_id) <>
          nvl(l_header_rec.ship_to_org_id, FND_API.G_MISS_NUM)
       THEN
          l_line_exists := 'N';
          FOR I IN 1..l_line_tbl.count
          LOOP
            If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
               G_IMPORT_SHIPMENTS = 'YES' Then
              If l_line_tbl(I).orig_sys_line_ref     = l_orig_sys_line_ref AND
                 l_line_tbl(I).orig_sys_shipment_ref = l_orig_sys_shipment_ref Then
                l_line_exists := 'Y';
                If l_line_tbl(I).operation = OE_Globals.G_OPR_UPDATE AND
                   nvl(l_line_tbl(I).ship_to_org_id, FND_API.G_MISS_NUM) <>
                   nvl(l_header_rec.ship_to_org_id, FND_API.G_MISS_NUM) Then

                  l_line_tbl(I).ship_to_org_id := l_header_rec.ship_to_org_id;
                End If;
              End If;
            Elsif (OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110508' AND
                   G_IMPORT_SHIPMENTS = 'NO') OR
                  OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' Then
              If l_line_tbl(I).orig_sys_line_ref   = l_orig_sys_line_ref Then
                l_line_exists := 'Y';
                If l_line_tbl(I).operation = OE_Globals.G_OPR_UPDATE AND
                   nvl(l_line_tbl(I).ship_to_org_id, FND_API.G_MISS_NUM) <>
                   nvl(l_header_rec.ship_to_org_id, FND_API.G_MISS_NUM) Then

                  l_line_tbl(I).ship_to_org_id := l_header_rec.ship_to_org_id;
                End If;
              End If;

            End If;
          END LOOP;

          IF l_line_exists = 'N' THEN
       	     IF l_debug_level  > 0 THEN
       	         oe_debug_pub.add(  'LINE DOES NOT EXIST. CREATING A NEW LINE...' ) ;
       	     END IF;

	     l_line_count := l_line_tbl.count + 1;
             l_line_tbl(l_line_count).operation:= OE_Globals.G_OPR_UPDATE;
             l_line_tbl(l_line_count).order_source_id := l_header_rec.order_source_id;
             l_line_tbl(l_line_count).orig_sys_document_ref := l_header_rec.orig_sys_document_ref;
             l_line_tbl(l_line_count).orig_sys_line_ref := l_orig_sys_line_ref;
             l_line_tbl(l_line_count).orig_sys_shipment_ref := l_orig_sys_shipment_ref;
             l_line_tbl(l_line_count).line_id := l_line_id;
             l_line_tbl(l_line_count).line_number := l_line_number;
             l_line_tbl(l_line_count).shipment_number:= l_shipment_number;
             l_line_tbl(l_line_count).option_number := l_option_number;
             l_line_tbl(l_line_count).ship_to_org_id := l_header_rec.ship_to_org_id;
       	     IF l_debug_level  > 0 THEN
       	         oe_debug_pub.add(  'COUNT: '||TO_CHAR ( L_LINE_COUNT ) ) ;
       	     END IF;
       	     IF l_debug_level  > 0 THEN
       	         oe_debug_pub.add(  'ORIG_SYS_LINE_REF: '||L_ORIG_SYS_LINE_REF ) ;
       	     END IF;
       	     IF l_debug_level  > 0 THEN
       	         oe_debug_pub.add(  'LINE_ID: '||L_LINE_ID ) ;
       	     END IF;
       	     IF l_debug_level  > 0 THEN
       	         oe_debug_pub.add(  'SHIP_TO_ORG_ID: '||L_HEADER_REC.SHIP_TO_ORG_ID ) ;
       	     END IF;
          END IF;
       END IF;
       END LOOP;
   END IF;

   IF (nvl(l_header_rec.SHIP_TO_ORG_ID,FND_API.G_MISS_NUM)
             <> FND_API.G_MISS_NUM) THEN

      IF (nvl(l_header_val_rec.SHIP_TO_ORG,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.SHIP_TO_ORG := NULL;
      END IF;
      IF (nvl(l_header_val_rec.ship_to_address1,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.ship_to_address1 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.ship_to_address2,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.ship_to_address2 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.ship_to_address3,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.ship_to_address3 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.ship_to_address4,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.ship_to_address4 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.ship_to_location,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.ship_to_location := NULL;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CLEARING THE SHIP_TO_ORG IN HEADER' ) ;
      END IF;
   END IF;
   --
   IF (nvl(l_header_rec.INVOICE_TO_ORG_ID,FND_API.G_MISS_NUM)
             <> FND_API.G_MISS_NUM) THEN

      IF (nvl(l_header_val_rec.INVOICE_TO_ORG,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.INVOICE_TO_ORG := NULL;
      END IF;
      IF (nvl(l_header_val_rec.invoice_to_address1,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.invoice_to_address1 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.invoice_to_address2,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.invoice_to_address2 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.invoice_to_address3,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.invoice_to_address3 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.invoice_to_address4,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.invoice_to_address4 := NULL;
      END IF;
      IF (nvl(l_header_val_rec.invoice_to_location,FND_API.G_MISS_CHAR)
         <> FND_API.G_MISS_CHAR) THEN
          p_header_val_rec.invoice_to_location := NULL;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CLEARING THE INVOICE_TO IN HEADER' ) ;
      END IF;
   END IF;
   BEGIN
     FOR I IN 1..l_line_tbl.count
     LOOP
       IF (nvl(l_line_tbl(I).SHIP_TO_ORG_ID,FND_API.G_MISS_NUM)
               <> FND_API.G_MISS_NUM)  THEN

           IF (nvl(p_line_val_tbl(I).SHIP_TO_ORG ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).SHIP_TO_ORG := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).ship_to_address1 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).ship_to_address1 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).ship_to_address2 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).ship_to_address2 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).ship_to_address3 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).ship_to_address3 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).ship_to_address4 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).ship_to_address4 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).ship_to_location ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).ship_to_location := NULL;
           END IF;

       --
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CLEARING THE SHIP_TO_ORG IN LINE' ) ;
           END IF;
       END IF;

       IF (nvl(l_line_tbl(I).INVOICE_TO_ORG_ID,FND_API.G_MISS_NUM)
               <> FND_API.G_MISS_NUM)  THEN

           IF (nvl(p_line_val_tbl(I).INVOICE_TO_ORG ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).INVOICE_TO_ORG := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).invoice_to_address1 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).invoice_to_address1 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).invoice_to_address2 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).invoice_to_address2 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).invoice_to_address3 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).invoice_to_address3 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).invoice_to_address4 ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).invoice_to_address4 := NULL;
           END IF;
           IF (nvl(p_line_val_tbl(I).invoice_to_location ,FND_API.G_MISS_CHAR)
               <> FND_API.G_MISS_CHAR) THEN
              p_line_val_tbl(I).invoice_to_location := NULL;
           END IF;

       --
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CLEARING THE INVOICE_TO_ORG IN LINE' ) ;
           END IF;
       END IF;
     END LOOP;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;

   p_line_tbl := l_line_tbl;	-- line table could have changed

END Pre_Process;


/* -----------------------------------------------------------
   Procedure: Post_Process
   -----------------------------------------------------------
*/
PROCEDURE Post_Process(
   p_header_rec			IN  	OE_Order_Pub.Header_Rec_Type
  ,p_header_adj_tbl             IN	OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_header_scredit_tbl         IN	OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_line_tbl			IN  	OE_Order_Pub.Line_Tbl_Type
  ,p_line_adj_tbl		IN	OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_line_scredit_tbl           IN	OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_lot_serial_tbl             IN	OE_Order_Pub.Lot_Serial_Tbl_Type

  ,p_header_val_rec             IN	OE_Order_Pub.Header_Val_Rec_Type
  ,p_header_adj_val_tbl         IN	OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_header_scredit_val_tbl     IN	OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_line_val_tbl               IN	OE_Order_Pub.Line_Val_Tbl_Type
  ,p_line_adj_val_tbl           IN	OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_line_scredit_val_tbl       IN	OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_lot_serial_val_tbl         IN	OE_Order_Pub.Lot_Serial_Val_Tbl_Type

,p_return_status OUT NOCOPY VARCHAR2

) IS
   l_header_rec			OE_Order_Pub.Header_Rec_Type;
   l_header_adj_tbl		OE_Order_Pub.Header_Adj_Tbl_Type;
   l_header_scredit_tbl		OE_Order_Pub.Header_Scredit_Tbl_Type;
   l_line_tbl			OE_Order_Pub.Line_Tbl_Type;
   l_line_adj_tbl		OE_Order_Pub.Line_Adj_Tbl_Type;
   l_line_scredit_tbl		OE_Order_Pub.Line_Scredit_Tbl_Type;
   l_lot_serial_tbl		OE_Order_Pub.Lot_Serial_Tbl_Type;

   l_header_val_rec		OE_Order_Pub.Header_Val_Rec_Type;
   l_header_adj_val_tbl		OE_Order_Pub.Header_Adj_Val_Tbl_Type;
   l_header_scredit_val_tbl	OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
   l_line_val_tbl		OE_Order_Pub.Line_Val_Tbl_Type;
   l_line_adj_val_tbl		OE_Order_Pub.Line_Adj_Val_Tbl_Type;
   l_line_scredit_val_tbl	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
   l_lot_serial_val_tbl		OE_Order_Pub.Lot_Serial_Val_Tbl_Type;
BEGIN

   l_header_rec			:= p_header_rec;
   l_header_adj_tbl		:= p_header_adj_tbl;
   l_header_scredit_tbl		:= p_header_scredit_tbl;
   l_line_tbl			:= p_line_tbl;
   l_line_adj_tbl		:= p_line_adj_tbl;
   l_line_scredit_tbl		:= p_line_scredit_tbl;
   l_lot_serial_tbl		:= p_lot_serial_tbl;

   l_header_val_rec		:= p_header_val_rec;
   l_header_adj_val_tbl		:= p_header_adj_val_tbl;
   l_header_scredit_val_tbl	:= p_header_scredit_val_tbl;
   l_line_val_tbl		:= p_line_val_tbl;
   l_line_adj_val_tbl		:= p_line_adj_val_tbl;
   l_line_scredit_val_tbl	:= p_line_scredit_val_tbl;
   l_lot_serial_val_tbl		:= p_lot_serial_val_tbl;

   p_return_status := FND_API.G_RET_STS_SUCCESS; /* Init to Success */

/* --------------------------------------------------------------------
   Have nothing to code here today. But have created this procedure for
   future requirements.
   --------------------------------------------------------------------
*/
END POST_PROCESS;


END OE_EDI_PVT;

/
