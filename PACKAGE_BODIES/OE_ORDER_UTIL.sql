--------------------------------------------------------
--  DDL for Package Body OE_ORDER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_UTIL" AS
/* $Header: OEXUORDB.pls 120.5.12010000.3 2010/10/06 12:03:35 srsunkar ship $ */

--  Global constant holding the package name
G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'OE_ORDER_UTIL';

/*lchen*/
-- Constants added for notification framework
G_MAX_REQUESTS                  NUMBER := 10000;


-- GET_ATTRIBUTE_NAME
-- Returns the translated display name of the attribute from the AK
-- dictionary based on the attribute code
-- Use this function to resolve message tokens that display attribute
-- names.
---------------------------------------------------------------
FUNCTION GET_ATTRIBUTE_NAME
        ( p_attribute_code               IN VARCHAR2
        )
RETURN VARCHAR2
IS
-- Fix bug#1349549:
-- Increased l_attribute_name length to 240 as length
-- of column - NAME on AK_ATTRIBUTES_VL was increased
l_attribute_name		VARCHAR2(240);
BEGIN

        -- Bug 2648277 => NAME column is not translatable any more.
        -- Use ATTRIBUTE_LABEL_LONG column, this is translated.
	SELECT AK.ATTRIBUTE_LABEL_LONG
	INTO l_attribute_name
	FROM AK_ATTRIBUTES_VL AK
	WHERE ak.attribute_code = upper(p_attribute_code)
	  AND ak.attribute_application_id = 660;

	RETURN(l_attribute_name);

EXCEPTION
    When Others Then
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_ATTRIBUTE_NAME'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ATTRIBUTE_NAME;

---------------------------------------------------------------
PROCEDURE LOCK_ORDER_OBJECT
	(p_header_id			IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

	)
IS
CURSOR header IS
	SELECT header_id
	FROM OE_ORDER_HEADERS
	WHERE HEADER_ID = p_header_id
	FOR UPDATE NOWAIT;
CURSOR lines IS
	SELECT line_id
	FROM OE_ORDER_LINES
	WHERE HEADER_ID = p_header_id
	FOR UPDATE NOWAIT;
CURSOR price_adjustments IS
	SELECT price_adjustment_id
	FROM OE_PRICE_ADJUSTMENTS
	WHERE HEADER_ID = p_header_id
	FOR UPDATE NOWAIT;
CURSOR sales_credits IS
	SELECT sales_credit_id
	FROM OE_SALES_CREDITS
	WHERE HEADER_ID = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	SAVEPOINT Lock_Order_Object;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Lock order header
	OPEN header;
	CLOSE header;

	-- Lock all the lines in this order
	OPEN lines;
	CLOSE lines;

	-- Lock all the price adjustments for this order
	OPEN price_adjustments;
	CLOSE price_adjustments;

	-- Lock all the sales credits for this order
	OPEN sales_credits;
	CLOSE sales_credits;

EXCEPTION
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('ONT','OE_ORDER_OBJECT_LOCKED');
	OE_MSG_PUB.ADD;
	IF (header%ISOPEN) THEN
	   CLOSE header;
	ELSIF (lines%ISOPEN) THEN
	   CLOSE lines;
	ELSIF (price_adjustments%ISOPEN) THEN
	   CLOSE price_adjustments;
	ELSIF (sales_credits%ISOPEN) THEN
	   CLOSE sales_credits;
	END IF;
	ROLLBACK TO Lock_Order_Object;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Lock_Order_Object'
                        );
        END IF;
	IF (header%ISOPEN) THEN
	   CLOSE header;
	ELSIF (lines%ISOPEN) THEN
	   CLOSE lines;
	ELSIF (price_adjustments%ISOPEN) THEN
	   CLOSE price_adjustments;
	ELSIF (sales_credits%ISOPEN) THEN
	   CLOSE sales_credits;
	END IF;
	ROLLBACK TO Lock_Order_Object;
END LOCK_ORDER_OBJECT;


-- Update_Global_Picture
-- This procedure takes in the entity to be updated and inserts or updates the
-- global old and new tables holding that entity information for the order feedback
-- notification processes.
-- This routine should only be updating the global tables if the order is booked.
-- We should always be passed:
--  1-  id for the entity to be updated,
--  2-  old record for the entity to be updated, and
--  3-  new record for the entity to be updated.
-- If the action is insert, the old record passed will be empty.
-- If the action is delete, the new record passed will be empty.

PROCEDURE Update_Global_Picture
(
   p_Upd_New_Rec_If_Exists   IN BOOLEAN := TRUE
,  p_Header_Rec              IN OE_Order_Pub.Header_Rec_Type := NULL
,  p_Line_Rec                IN OE_Order_Pub.Line_Rec_Type := NULL
,  p_Hdr_Scr_Rec             IN OE_Order_Pub.Header_Scredit_Rec_Type :=  NULL
,  p_Hdr_Adj_Rec             IN OE_Order_Pub.Header_Adj_Rec_Type :=  NULL
,  p_Line_Adj_Rec            IN OE_Order_Pub.Line_Adj_Rec_Type := NULL
,  p_Line_Scr_Rec            IN OE_Order_Pub.Line_Scredit_Rec_Type := NULL
,  p_Lot_Serial_Rec          IN OE_Order_Pub.Lot_Serial_Rec_Type := NULL
,  p_old_Header_Rec          IN OE_Order_Pub.Header_Rec_Type := NULL
,  p_old_Line_Rec            IN OE_Order_Pub.Line_Rec_Type := NULL
,  p_old_Hdr_Scr_Rec         IN OE_Order_Pub.Header_Scredit_Rec_Type := NULL
,  p_old_Hdr_Adj_Rec         IN OE_Order_Pub.Header_Adj_Rec_Type := NULL
,  p_old_Line_Adj_Rec        IN OE_Order_Pub.Line_Adj_Rec_Type := NULL
,  p_old_Line_Scr_Rec        IN OE_Order_Pub.Line_Scredit_Rec_Type := NULL
,  p_old_Lot_Serial_Rec      IN OE_Order_Pub.Lot_Serial_Rec_Type := NULL
,  p_header_id               IN NUMBER := NULL
,  p_line_id                 IN NUMBER := NULL
,  p_hdr_scr_id              IN NUMBER := NULL
,  p_line_scr_id             IN NUMBER := NULL
,  p_hdr_adj_id              IN NUMBER := NULL
,  p_line_adj_id             IN NUMBER := NULL
,  p_lot_serial_id           IN NUMBER := NULL
, x_index OUT NOCOPY NUMBER

, x_return_status OUT NOCOPY VARCHAR2)


IS
  l_ind    		PLS_INTEGER;
  l_result 		VARCHAR2(30);
  l_return_stat 	VARCHAR2(1);
  l_old_line_rec             OE_Order_Pub.Line_Rec_Type;
  l_old_Header_Rec           OE_Order_Pub.Header_Rec_Type;
  l_old_Hdr_Scr_Rec          OE_Order_Pub.Header_Scredit_Rec_Type;
  l_old_Hdr_Adj_Rec          OE_Order_Pub.Header_Adj_Rec_Type;
  l_old_Line_Adj_Rec         OE_Order_Pub.Line_Adj_Rec_Type;
  l_old_Line_Scr_Rec         OE_Order_Pub.Line_Scredit_Rec_Type;
  l_old_Lot_Serial_Rec       OE_Order_Pub.Lot_Serial_Rec_Type;

  -- Begin Audit/Versioning Changes
  l_reason_existed      BOOLEAN := FALSE;
  l_change_reason       VARCHAR2(30);
  l_change_comments     VARCHAR2(2000);
  -- End Audit/Versioning Changes
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_return_status      := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_ORDER_UTIL.UPDATE_GLOBAL_PICTURE' , 1 ) ;
  END IF;

  /*  The global entities will be populated for booked orders */
  /* coming in via Process Order or for entered orders via the GUI */
  /* or at 11.5.10 or higher (for versioning changes) */

    IF NOT (OE_GLOBALS.G_UI_FLAG )  THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UI FLAG IS FALSE' , 1 ) ;
       END IF;
    end if;

-- check for code set level, Update_Global_Picture is at OM Pack H level

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'CODE_RELEASE_LEVEL='|| OE_CODE_CONTROL.CODE_RELEASE_LEVEL , 1 ) ;
 END IF;

 IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508'
  THEN

  IF p_header_id is not NULL THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'GETTING THE CACHE' || P_HEADER_ID ) ;
   END IF;
   OE_Order_Cache.Load_Order_Header(p_header_id);
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CACHED VALUE' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
  END IF;
  IF (oe_order_cache.g_header_rec.booked_flag = 'Y') OR
     (OE_GLOBALS.G_UI_FLAG ) OR
      OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

-- If the order is booked, then do the logic for each entity as follows:
--  1- search old table for this line
--       and if it's not there, query it and add to global picture
--  2- search new table for this line
--       and if it is there, update the record and return the index
--       and if it's not there, query it and add to global picture

 IF(p_header_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_HEADER_ID=' || P_HEADER_ID , 1 ) ;
   END IF;

        IF g_old_header_rec.header_id=FND_API.G_MISS_NUM OR
                g_old_header_rec.header_id is NULL THEN

          IF p_old_header_rec.header_id=FND_API.G_MISS_NUM OR
                P_old_header_rec.header_id is NULL THEN

                        IF p_header_Rec.header_id is not null and
                         p_header_Rec.operation = oe_globals.g_opr_create THEN
                         IF l_debug_level > 0 THEN

                             oe_debug_pub.add(  'P_HEADER_REC.HEADER_ID=' || P_HEADER_REC.HEADER_ID , 1 ) ;
                         END IF;
                           g_old_header_rec := p_header_Rec;
                         IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'JPN: OLD HEADER GLOBAL PIC UPDATED' ) ;
                        END IF;
                        ELSE
                           oe_header_util.query_row( p_header_id =>p_header_id,
                                     x_header_rec => l_old_header_rec);
                           g_old_header_rec := l_old_header_rec;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'JPN: OLD HEADER GLOBAL PIC UPDATED AFTER QUERY' ) ;
                          END IF;
                        END IF;
          ELSE
             g_old_header_rec := p_old_header_rec;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'JPN: OLD HEADER GLOBAL PIC UPDATED IN THIS LOOP' ) ;
             END IF;
          END IF;
        END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GLOBAL OLD HEADER BOOKED FLAG VALUE' || G_OLD_HEADER_REC.BOOKED_FLAG ) ;
      END IF;

   IF p_upd_new_rec_If_Exists THEN
       /* Update the record in the new global table */
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE LOOP P_UPD_NEW_REC' ) ;
       END IF;
       -- Begin Audit/Versioning changes (retain old change reason)
       IF (OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
           g_header_rec.change_reason IS NOT NULL AND
           g_header_rec.change_reason <> FND_API.G_MISS_CHAR) THEN
           l_reason_existed := TRUE;
           l_change_reason   := g_header_rec.change_reason;
           l_change_comments := g_header_rec.change_comments;
       END IF;
       -- End Audit/Versioning changes

       g_header_rec := p_header_rec;

       -- Begin Audit/Versioning changes
       IF (l_reason_existed) THEN
           g_header_rec.change_reason := l_change_reason;
           g_header_rec.change_comments := l_change_comments;
           l_reason_existed := FALSE;
       END IF;
       -- End Audit/Versioning changes

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'GLOBAL HEADER BOOKED FLAG VALUE' || G_HEADER_REC.BOOKED_FLAG ) ;
         oe_debug_pub.add(  'GLOBAL HEADER REC OPERATION' || G_HEADER_REC.OPERATION ) ;
     END IF;
   END IF; -- update flag is set

    /* return the index value */
    x_index:=1;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' OD GLOBAL HEADER_ID= '|| G_OLD_HEADER_REC.HEADER_ID , 1 ) ;
       oe_debug_pub.add(  ' NEW GLOBAL HEADER_ID= '|| G_HEADER_REC.HEADER_ID , 1 ) ;
   END IF;

 END IF; -- header_id is not null

IF (p_hdr_scr_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_HDR_SCR_ID=' || P_HDR_SCR_ID , 1 ) ;
   END IF;

   /* search the old global header sales credits table */
   Return_Glb_Ent_Index(
			OE_GLOBALS.G_ENTITY_HEADER_SCREDIT,
			p_hdr_scr_id,
			l_ind,
			l_result,
			l_return_stat);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STAT , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
   END IF;

   IF l_result = FND_API.G_FALSE  THEN

     IF p_old_hdr_scr_rec.sales_credit_id = FND_API.G_MISS_NUM OR
             p_old_hdr_scr_rec.sales_credit_id is NULL THEN

           IF p_hdr_scr_rec.sales_credit_id is not null and
              p_hdr_scr_rec.operation = oe_globals.g_opr_create THEN
                 g_old_header_scredit_tbl(l_ind):= p_hdr_scr_rec;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'JPN: OLD HEADER SALES CREDITS GLOBAL PIC UPDATED' ) ;
                 END IF;
            ELSE
            OE_HEADER_SCREDIT_UTIL.Query_Row(p_sales_credit_id => p_hdr_scr_id,
                            x_header_scredit_rec =>l_old_hdr_scr_rec);                       g_old_header_scredit_tbl(l_ind) :=l_old_hdr_scr_rec;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'JPN: OLD HEADER SCREDIT GLOBAL PIC UPDATED AFTER QUERY' ) ;
              END IF;
            END IF;

      ELSE
         g_old_header_scredit_tbl(l_ind) := p_old_hdr_scr_rec;
      END IF;
    END IF;

   IF p_upd_new_rec_If_Exists THEN
       -- Begin Audit/Versioning changes (retain old change reason)
       IF (OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
           g_header_scredit_tbl.exists(l_ind) AND
           g_header_scredit_tbl(l_ind).change_reason IS NOT NULL AND
           g_header_scredit_tbl(l_ind).change_reason <> FND_API.G_MISS_CHAR) THEN
           l_reason_existed := TRUE;
           l_change_reason   := g_header_scredit_tbl(l_ind).change_reason;
           l_change_comments := g_header_scredit_tbl(l_ind).change_comments;
       END IF;
       -- End Audit/Versioning changes

      /* Update the record in the new global table */
      g_header_scredit_tbl(l_ind) := p_hdr_scr_rec;

       -- Begin Audit/Versioning changes
       IF (l_reason_existed) THEN
           g_header_scredit_tbl(l_ind).change_reason := l_change_reason;
           g_header_scredit_tbl(l_ind).change_comments := l_change_comments;
           l_reason_existed := FALSE;
       END IF;
       -- End Audit/Versioning changes

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GLOBAL HDR_SCR_REC OPERATION' || G_HEADER_SCREDIT_TBL ( L_IND ) .OPERATION ) ;
      END IF;
   END IF; -- update flag is set

   /* return the index value */
   x_index := l_ind;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OLD SCR_ID ' || G_OLD_HEADER_SCREDIT_TBL ( L_IND ) .SALES_CREDIT_ID , 1 ) ;
        oe_debug_pub.add(  'NEW SCR_ID' || G_HEADER_SCREDIT_TBL ( L_IND ) .SALES_CREDIT_ID , 1 ) ;
    END IF;

END IF; -- hdr_scr_id is not null


IF (p_hdr_adj_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_HDR_ADJ_ID=' || P_HDR_ADJ_ID , 1 ) ;
   END IF;

   /* search the old global header adjustments table */
   Return_Glb_Ent_Index(
			OE_GLOBALS.G_ENTITY_HEADER_ADJ,
			p_hdr_adj_id,
			l_ind,
			l_result,
			l_return_stat);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STAT , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
   END IF;

   IF l_result = FND_API.G_FALSE   THEN
       IF p_old_hdr_adj_rec.price_adjustment_id = FND_API.G_MISS_NUM OR
             p_old_hdr_adj_rec.price_adjustment_id is NULL THEN

           IF p_hdr_adj_rec.price_adjustment_id is not null and
              p_hdr_adj_rec.operation = oe_globals.g_opr_create THEN
                 g_old_header_adj_tbl(l_ind):= p_hdr_adj_rec;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'JPN: OLD HEADER ADJ GLOBAL PIC UPDATED' ) ;
                 END IF;
            ELSE
            OE_HEADER_ADJ_UTIL.Query_Row(p_price_adjustment_id => p_hdr_adj_id,
                            x_header_adj_rec =>l_old_hdr_adj_rec);
             g_old_header_adj_tbl(l_ind):=l_old_hdr_adj_rec;
            END IF;
        ELSE
            IF l_debug_level > 0 THEN
              oe_debug_pub.add('Updating the old global table');
            END IF;
            g_old_header_adj_tbl(l_ind) := p_old_hdr_adj_rec;
        END IF;
    END IF;

   IF p_upd_new_rec_If_Exists THEN
       -- Begin Audit/Versioning changes (retain old change reason)
       IF (OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
           g_header_adj_tbl.exists(l_ind) AND
           g_header_adj_tbl(l_ind).change_reason_code IS NOT NULL AND
           g_header_adj_tbl(l_ind).change_reason_code <> FND_API.G_MISS_CHAR) THEN
           l_reason_existed := TRUE;
           l_change_reason := g_header_adj_tbl(l_ind).change_reason_code;
           l_change_comments := g_header_adj_tbl(l_ind).change_reason_text;
       END IF;
       -- End Audit/Versioning changes

      /* Update the record in the new global table */
      g_header_adj_tbl(l_ind) := p_hdr_adj_rec;

       -- Begin Audit/Versioning changes
       IF (l_reason_existed) THEN
           g_header_adj_tbl(l_ind).change_reason_code := l_change_reason;
           g_header_adj_tbl(l_ind).change_reason_text := l_change_comments;
           l_reason_existed := FALSE;
       END IF;
       -- End Audit/Versioning changes

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'GLOBAL HDR_ADJ_REC OPERATION' || G_HEADER_ADJ_TBL ( L_IND ) .OPERATION ) ;
     END IF;
   END IF; -- update flag is set

   /* return the index value */
   x_index := l_ind;

/*  commented the debug statement for bug # 2919714 hashraf
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OLD HDR ADJ ID' || G_OLD_HEADER_ADJ_TBL ( L_IND ) .PRICE_ADJUSTMENT_ID , 1 ) ;
   END IF;
*/

END IF; -- adj_hdr_id is not null


IF (p_line_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_ID=' || P_LINE_ID , 1 ) ;
   END IF;

   /* search the old global line table */
   Return_Glb_Ent_Index(
			OE_GLOBALS.G_ENTITY_LINE,
			p_line_id,
			l_ind,
			l_result,
			l_return_stat);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STAT , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
   END IF;

   IF l_result = FND_API.G_FALSE   then
    IF p_old_line_rec.line_id = FND_API.G_MISS_NUM OR
             p_old_line_rec.line_id is NULL THEN

           IF p_line_rec.line_id is not null and
              p_line_rec.operation = oe_globals.g_opr_create THEN
                 g_old_line_tbl(l_ind):= p_line_rec;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'JPN: OLD LINE GLOBAL PIC UPDATED' ) ;
                 END IF;
            ELSE
                 OE_LINE_UTIL.Query_Row(p_line_id => p_line_id,
                                        x_line_rec => l_old_line_rec);
                 g_old_line_tbl(l_ind):=l_old_line_rec;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'JPN: OLD LINE GLOBAL PIC UPDATED AFTER QUERY' ) ;
              END IF;
            END IF;

        ELSE
            g_old_line_tbl(l_ind) := p_old_line_rec;
        END IF;
    END IF;

   IF p_upd_new_rec_If_Exists THEN
       -- Begin Audit/Versioning changes (retain old change reason)
       IF (OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
           g_line_tbl.exists(l_ind) AND
           g_line_tbl(l_ind).change_reason IS NOT NULL AND
           g_line_tbl(l_ind).change_reason <> FND_API.G_MISS_CHAR) THEN
           l_reason_existed := TRUE;
           l_change_reason  := g_line_tbl(l_ind).change_reason;
           l_change_comments := g_line_tbl(l_ind).change_comments;
       END IF;
       -- End Audit/Versioning changes

      /* Update the record in the new global table */
      g_line_tbl(l_ind) := p_line_rec;

       -- Begin Audit/Versioning changes
       IF (l_reason_existed) THEN
           g_line_tbl(l_ind).change_reason := l_change_reason;
           g_line_tbl(l_ind).change_comments := l_change_comments;
           l_reason_existed := FALSE;
       END IF;
       -- End Audit/Versioning changes

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GLOBAL LINE REC OPERATION' || G_LINE_TBL ( L_IND ) .OPERATION ) ;
      END IF;
   END IF; -- update flag is set

   /* return the index value */
   x_index := l_ind;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OLD LINE ID' || G_OLD_LINE_TBL ( L_IND ) .LINE_ID , 1 ) ;
   END IF;

 END IF; -- line_id is not null


IF (p_line_scr_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_SCR_ID=' || P_LINE_SCR_ID , 1 ) ;
   END IF;

   /* search the old global line sales credits table */
   Return_Glb_Ent_Index(
			OE_GLOBALS.G_ENTITY_LINE_SCREDIT,
			p_line_scr_id,
                        l_ind,
			l_result,
			l_return_stat);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STAT , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
   END IF;

   IF l_result = FND_API.G_FALSE   THEN
     IF p_old_line_scr_rec.sales_credit_id = FND_API.G_MISS_NUM OR
             p_old_line_scr_rec.sales_credit_id is NULL THEN

           IF p_line_scr_rec.sales_credit_id is not null and
              p_line_scr_rec.operation = oe_globals.g_opr_create THEN
                 g_old_line_scredit_tbl(l_ind):= p_line_scr_rec;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'JPN: OLD LINE SALES CREDITS GLOBAL PIC UPDATED' ) ;
                 END IF;
            ELSE
              OE_LINE_SCREDIT_UTIL.Query_Row(p_sales_credit_id =>p_line_scr_id,
                                    x_line_scredit_rec =>l_old_line_scr_rec);
               g_old_line_scredit_tbl(l_ind):=l_old_line_scr_rec;
           END IF;
       ELSE
         g_old_line_scredit_tbl(l_ind) := p_old_line_scr_rec;

      END IF;
    END IF;

   IF  p_upd_new_rec_If_Exists THEN
       -- Begin Audit/Versioning changes (retain old change reason)
       IF (OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
           g_line_scredit_tbl.exists(l_ind) AND
           g_line_scredit_tbl(l_ind).change_reason IS NOT NULL AND
           g_line_scredit_tbl(l_ind).change_reason <> FND_API.G_MISS_CHAR) THEN
           l_reason_existed := TRUE;
           l_change_reason   := g_line_scredit_tbl(l_ind).change_reason;
           l_change_comments := g_line_scredit_tbl(l_ind).change_comments;
       END IF;
       -- End Audit/Versioning changes

      /* Update the record in the new global table */
      g_line_scredit_tbl(l_ind) := p_line_scr_rec;

       -- Begin Audit/Versioning changes
       IF (l_reason_existed) THEN
           g_line_scredit_tbl(l_ind).change_reason := l_change_reason;
           g_line_scredit_tbl(l_ind).change_comments := l_change_comments;
           l_reason_existed := FALSE;
       END IF;
       -- End Audit/Versioning changes

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'GLOBAL LINE_SCR_REC OPERATION' || G_LINE_SCREDIT_TBL ( L_IND ) .OPERATION ) ;
       END IF;
   END IF; -- update flag is set

   /* return the index value */
   x_index := l_ind;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OLD LINE SCR ID' || G_OLD_LINE_SCREDIT_TBL ( L_IND ) .SALES_CREDIT_ID , 1 ) ;
       oe_debug_pub.add(  'NEW LINE SCR ID' || G_LINE_SCREDIT_TBL ( L_IND ) .SALES_CREDIT_ID , 1 ) ;
   END IF;

END IF; -- scr_line_id is not null


IF (p_line_adj_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LINE_ADJ_ID=' || P_LINE_ADJ_ID , 1 ) ;
   END IF;

   /* search the old global line adjustments table */
   Return_Glb_Ent_Index(
			OE_GLOBALS.G_ENTITY_LINE_ADJ,
			p_line_adj_id,
                        l_ind,
			l_result,
			l_return_stat);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STAT , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
       oe_debug_pub.add(  'OPERATION =' || P_LINE_ADJ_REC.OPERATION , 1 ) ;
   END IF;

   IF l_result = FND_API.G_FALSE   then
      IF p_old_line_adj_rec.price_adjustment_id = FND_API.G_MISS_NUM OR
             p_old_line_adj_rec.price_adjustment_id is NULL THEN

           IF p_line_adj_rec.price_adjustment_id is not null and
              p_line_adj_rec.operation = oe_globals.g_opr_create THEN
                 g_old_line_adj_tbl(l_ind):= p_line_adj_rec;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'JPN: OLD LINE ADJ GLOBAL PIC UPDATED' ) ;
                 END IF;
            ELSE
              OE_LINE_ADJ_UTIL.Query_Row(p_price_adjustment_id =>p_line_adj_id,
                            x_line_adj_rec =>l_old_line_adj_rec);
                  g_old_line_adj_tbl(l_ind):=l_old_line_adj_rec;
            END IF;
          ELSE
            g_old_line_adj_tbl(l_ind) := p_old_line_adj_rec;
        END IF;
    END IF;

   IF p_upd_new_rec_If_Exists THEN
       -- Begin Audit/Versioning changes (retain old change reason)
       IF (OE_CODE_CONTROL.Code_Release_Level >= '110510' AND
           g_line_adj_tbl.exists(l_ind) AND
           g_line_adj_tbl(l_ind).change_reason_code IS NOT NULL AND
           g_line_adj_tbl(l_ind).change_reason_code <> FND_API.G_MISS_CHAR) THEN
           l_reason_existed := TRUE;
           l_change_reason := g_line_adj_tbl(l_ind).change_reason_code;
           l_change_comments := g_line_adj_tbl(l_ind).change_reason_text;
       END IF;
       -- End Audit/Versioning changes

      /* Update the record in the new global table */
      g_line_adj_tbl(l_ind) := p_line_adj_rec;

       -- Begin Audit/Versioning changes
       IF (l_reason_existed) THEN
           g_line_adj_tbl(l_ind).change_reason_code := l_change_reason;
           g_line_adj_tbl(l_ind).change_reason_text := l_change_comments;
           l_reason_existed := FALSE;
       END IF;
       -- End Audit/Versioning changes

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GLOBAL LINE_ADJ_REC OPERATION' || G_LINE_ADJ_TBL ( L_IND ) .OPERATION ) ;
      END IF;
   END IF; -- update flag is set

   /* return the index value */
   x_index := l_ind;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OLD LINE ADJ ID' || G_OLD_LINE_ADJ_TBL ( L_IND ) .PRICE_ADJUSTMENT_ID , 1 ) ;
-- do not uncomment the line below...it will give no-data found error
--       oe_debug_pub.add(  'NEW LINE ADJ ID' || G_LINE_ADJ_TBL ( L_IND ) .PRICE_ADJUSTMENT_ID , 1 ) ;
   END IF;

END IF; -- adj_line_id is not null


IF (p_lot_serial_id is not null) THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_LOT_SERIAL_ID=' || P_LOT_SERIAL_ID , 1 ) ;
   END IF;

   /* search the old global lot serial table */
   Return_Glb_Ent_Index(
			OE_GLOBALS.G_ENTITY_LOT_SERIAL,
			p_lot_serial_id,
                        l_ind,
			l_result,
			l_return_stat);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STAT , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
   END IF;

   IF l_result = FND_API.G_FALSE   then
     IF p_old_lot_serial_rec.lot_serial_id = FND_API.G_MISS_NUM OR
             p_old_lot_serial_rec.lot_serial_id is NULL THEN

           IF p_lot_serial_rec.lot_serial_id is not null and
              p_lot_serial_rec.operation = oe_globals.g_opr_create THEN
                 g_old_lot_serial_tbl(l_ind):= p_lot_serial_rec;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'JPN: OLD LOT SERIAL GLOBAL PIC UPDATED' ) ;
                 END IF;
            ELSE
              OE_LOT_SERIAL_UTIL.Query_Row(p_lot_serial_id =>p_lot_serial_id,
                            x_lot_serial_rec =>l_old_lot_serial_rec);
              g_old_lot_serial_tbl(l_ind):= l_old_lot_serial_rec;
            END IF;
          ELSE
            g_old_lot_serial_tbl(l_ind) := p_old_lot_serial_rec;
        END IF;
    END IF;

   IF p_upd_new_rec_If_Exists THEN
      /* Update the record in the new global table */
      g_lot_serial_tbl(l_ind) := p_lot_serial_rec;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GLOBAL LOT_SERIAL_REC OPERATION' || G_LOT_SERIAL_TBL ( L_IND ) .OPERATION ) ;
      END IF;
   END IF; -- update flag is set

   /* return the index value */
   x_index := l_ind;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' OLD LOT SERIAL ID' || G_OLD_LOT_SERIAL_TBL ( L_IND ) .LOT_SERIAL_ID , 1 ) ;
       oe_debug_pub.add(  'NEW LOT SERIAL ID' || G_LOT_SERIAL_TBL ( L_IND ) .LOT_SERIAL_ID , 1 ) ;
   END IF;

 END IF; -- lot_serial_id is not null

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_ORDER_UTIL.UPDATE_GLOBAL_PICTURE' , 1 ) ;
  END IF;

 END IF; /* check for booked flag or g_ui_flag */
END IF; /* check for code set level*/

EXCEPTION

   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'Update_Global_picture');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Global_Picture;


-- Return_Glb_Ent_Index
-- This procedure, given an entity code and id, searches the new or old global tables
-- for the index.
-- If it exists in the global table specified, x_result = TRUE and location = x_index.
-- If it doesn't exist in the global table, x_result = FALSE and x_index holds the
-- location where it should be inserted.

Procedure Return_Glb_Ent_Index(
				p_entity_code    IN VARCHAR2,
                               	p_entity_id      IN NUMBER,
x_index OUT NOCOPY NUMBER,

x_result OUT NOCOPY VARCHAR2,

x_return_status OUT NOCOPY VARCHAR2 )

IS
   l_ind      PLS_INTEGER;
   l_max_ind  PLS_INTEGER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_return_status	:= FND_API.G_RET_STS_SUCCESS;
    x_result	  	:= FND_API.G_FALSE;

    l_ind 		:= (mod(p_entity_id,100000) * G_MAX_REQUESTS)+1;
    l_max_ind 		:= l_ind + G_MAX_REQUESTS - 1;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_ORDER_UTIL.RETURN_GLB_ENT_INDEX' , 1 ) ;
   END IF;

IF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN

	-- search until we find the first index position with a value
    	IF NOT g_old_line_tbl.Exists(l_ind) THEN
      	   x_index := l_ind;
      	   l_ind := g_old_line_tbl.Next(l_ind);
  	END IF;

	-- search the index positions for our entity id, or where it should be placed
   	WHILE g_old_line_tbl.Exists(l_ind) AND l_ind <= l_max_ind LOOP

       	 	x_index := l_ind+1;

		IF (g_old_line_tbl(l_ind).line_id = p_entity_id OR
		    g_old_line_tbl(l_ind).line_id IS NULL )
		THEN
	   	    x_index := l_ind;
	   	    x_result := FND_API.G_TRUE;
	   	EXIT;
		END IF;

        	l_ind := g_old_line_tbl.Next(l_ind);
   	END LOOP;
      -- end entity is line

ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_SCREDIT THEN

	-- search until we find the first index position with a value
    	IF NOT g_old_header_scredit_tbl.Exists(l_ind) THEN
      	   x_index := l_ind;
      	   l_ind := g_old_header_scredit_tbl.Next(l_ind);
  	END IF;

	-- search the index positions for our entity id, or where it should be placed
   	WHILE g_old_header_scredit_tbl.Exists(l_ind)
             AND l_ind <= l_max_ind LOOP

       	 	x_index := l_ind+1;

	       IF (g_old_header_scredit_tbl(l_ind).sales_credit_id = p_entity_id OR
	           g_old_header_scredit_tbl(l_ind).sales_credit_id IS NULL)
		THEN
	   	    x_index := l_ind;
	   	    x_result := FND_API.G_TRUE;
	   	EXIT;
		END IF;

        	l_ind := g_old_header_scredit_tbl.Next(l_ind);
   	END LOOP;
        -- end entity is header sales credit

ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_SCREDIT THEN

	-- search until we find the first index position with a value
    	IF NOT g_old_line_scredit_tbl.Exists(l_ind) THEN
      	   x_index := l_ind;
      	   l_ind := g_old_line_scredit_tbl.Next(l_ind);
  	END IF;

	-- search the index positions for our entity id, or where it should be placed
   	WHILE g_old_line_scredit_tbl.Exists(l_ind)
          AND l_ind <= l_max_ind LOOP

       	 	x_index := l_ind+1;

		IF (g_old_line_scredit_tbl(l_ind).sales_credit_id = p_entity_id OR
		    g_old_line_scredit_tbl(l_ind).sales_credit_id IS NULL)
		 THEN
	   	    x_index := l_ind;
	   	    x_result := FND_API.G_TRUE;
	   	 EXIT;
		END IF;

        	l_ind := g_old_line_scredit_tbl.Next(l_ind);
   	END LOOP;
       -- end entity is line sales credit


ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ THEN

	-- search until we find the first index position with a value
    	IF NOT g_old_header_adj_tbl.Exists(l_ind) THEN
      	   x_index := l_ind;
      	   l_ind := g_old_header_adj_tbl.Next(l_ind);
  	END IF;

	-- search the index positions for our entity id, or where it should be placed
   	WHILE g_old_header_adj_tbl.Exists(l_ind)
          AND l_ind <= l_max_ind LOOP

       	 	x_index := l_ind+1;

		IF (g_old_header_adj_tbl(l_ind).price_adjustment_id= p_entity_id OR
		    g_old_header_adj_tbl(l_ind).price_adjustment_id IS NULL)
		THEN
	   	    x_index := l_ind;
	   	    x_result := FND_API.G_TRUE;
	   	EXIT;
		END IF;

        	l_ind := g_old_header_adj_tbl.Next(l_ind);
   	END LOOP;
       -- end entity is header adjustment


ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN

	-- search until we find the first index position with a value
    	IF NOT g_old_line_adj_tbl.Exists(l_ind) THEN
      	   x_index := l_ind;
      	   l_ind := g_old_line_adj_tbl.Next(l_ind);
  	END IF;

	-- search the index positions for our entity id, or where it should be placed
   	WHILE g_old_line_adj_tbl.Exists(l_ind) AND l_ind <= l_max_ind LOOP
       	 	x_index := l_ind+1;

	        IF (g_old_line_adj_tbl(l_ind).price_adjustment_id = p_entity_id OR
	            g_old_line_adj_tbl(l_ind).price_adjustment_id IS NULL)
		 THEN
	   	    x_index := l_ind;
	   	    x_result := FND_API.G_TRUE;
	   	 EXIT;
		END IF;

        	l_ind := g_old_line_adj_tbl.Next(l_ind);
   	END LOOP;
     -- entity is line adjustment


ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LOT_SERIAL THEN

	-- search until we find the first index position with a value
    	IF NOT g_old_lot_serial_tbl.Exists(l_ind) THEN
      	   x_index := l_ind;
      	   l_ind := g_old_lot_serial_tbl.Next(l_ind);
  	END IF;

	-- search the index positions for our entity id, or where it should be placed
   	WHILE g_old_lot_serial_tbl.Exists(l_ind) AND l_ind <= l_max_ind LOOP
       	 	x_index := l_ind+1;

		IF (g_old_lot_serial_tbl(l_ind).lot_serial_id = p_entity_id OR
		    g_old_lot_serial_tbl(l_ind).lot_serial_id IS NULL)
		THEN
	   	    x_index := l_ind;
	   	    x_result := FND_API.G_TRUE;
	   	EXIT;
		END IF;

        	l_ind := g_old_lot_serial_tbl.Next(l_ind);
   	END LOOP;
     -- entity is lot/serial number
END IF; -- going through 7 entities

IF x_index > l_max_ind THEN
        FND_MESSAGE.SET_NAME('ONT','OE_MAX_REQUESTS_EXCEEDED');
        OE_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_ORDER_UTIL.RETURN_GLB_ENT_INDEX' , 1 ) ;
    END IF;

EXCEPTION

   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'Return_Glb_Ent_Index');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END Return_Glb_Ent_Index;

Procedure Clear_Global_Picture(x_return_status OUT NOCOPY VARCHAR2)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING PROCEDURE CLEAR_GLOBAL_STRUCTURE' ) ;
      END IF;
      G_Header_Rec := NULL;
      G_Old_Header_Rec := NULL;
      G_line_tbl.DELETE;
      G_old_line_tbl.DELETE;
      G_Header_Scredit_tbl.DELETE;
      G_Old_Header_Scredit_tbl.DELETE;
      G_Old_Line_Scredit_tbl.DELETE;
      G_Line_Scredit_tbl.DELETE;
      G_old_Header_Adj_tbl.DELETE;
      G_Header_Adj_tbl.DELETE;
      G_old_Line_Adj_tbl.DELETE;
      G_Line_Adj_tbl.DELETE;
      G_old_Lot_Serial_tbl.DELETE;
      G_Lot_Serial_tbl.DELETE;
      --Bug 4569284
      OE_GLOBALS.G_FTE_REINVOKE:=NULL;
      --Bug 4569284
      x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

      WHEN OTHERS THEN

           IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
              (G_PKG_NAME
            ,'Clear_Global_Picture');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Clear_Global_Picture;

PROCEDURE Initialize_Access_List
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_is_xdo_licensed           varchar2(1);

BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_UTIL.INITIALIZE_ACCESS_LIST' , 1 ) ;
      END IF;
      IF FND_FUNCTION.TEST('ONT_OEXOEORD_APPLY_HOLDS') THEN
        Add_Access('APPLY_HOLDS');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_RELEASE_HOLDS') THEN
        Add_Access('RELEASE_HOLDS');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_CANCEL_ORDER') THEN
        Add_Access('CANCEL_ORDER');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_COPY_ORDER') THEN
        Add_Access('COPY');
      END IF;
      IF FND_FUNCTION.TEST('ONT_OEXOEORD_PRICE_ORDER') THEN
        Add_Access('PRICE_ORDER');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_CALCULATE_TAX') THEN
        Add_Access('CALCULATE_TAX');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_PROGRESS_ORDER') THEN
        Add_Access('PROGRESS_ORDER');
      END IF;

--datafix_begin
      IF FND_FUNCTION.TEST('ONT_OEXOEORD_RETRY_WF') THEN
        Add_Access('RETRY_WF');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_PROCESS_MESSAGES') THEN
        Add_Access('PROCESS_MESSAGES');
      END IF;
--datafix_end

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_CONFIGURATIONS') THEN
        Add_Access('CONFIGURATIONS');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_SALES_CREDITS') THEN
        Add_Access('SALES_CREDITS');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_CHARGES') THEN
        Add_Access('CHARGES');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_BOOK_ORDER') THEN
        Add_Access('BOOK_ORDER');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_NOTIFICATION') THEN
        Add_Access('NOTIFICATION');
      END IF;


      IF FND_FUNCTION.TEST('ONT_OEXOEORD_AUTHORIZE_PAYMENT') THEN
        Add_Access('AUTHORIZE_PAYMENT');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_SCHEDULE') THEN
        Add_Access('SCHEDULE');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_INSTALL_BASE') THEN
        Add_Access('INSTALL_BASE');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_REMOVE_UCOMP') THEN
        Add_Access('REMOVE_UCOMP');
      END IF;

--Payment Receipt Report
     IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >='110510' THEN
       IF FND_FUNCTION.TEST('ONT_OEXOEORD_PRINT_RECEIPT') THEN
         Add_Access('PAYMENT_RECEIPT');
       END IF;
     END IF;
--Payment Receipt Report

--choose ship method
     IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >='110510' THEN
       IF FND_FUNCTION.TEST('ONT_OEXOEFCH') THEN
          Add_Access('CHOOSE_SHIP_METHOD');
       END IF;
     END IF;
--choose ship method

     --IF OE_FEATURES_PVT.Is_Margin_Avail THEN
      --MRG BGN
      IF FND_FUNCTION.TEST('ONT_OEXOEORD_VIEW_MARGIN') THEN
        Add_Access('VIEW_MARGIN');
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO PERMISSION TO VIEW MARGIN' ) ;
        END IF;
      END IF;
      --MRG END
     --END IF;

     --Freight Rating Begin
      /*IF OE_FREIGHT_RATING_UTIL.IS_FREIGHT_RATING_AVAILABLE THEN
         Add_Access('GET_FREIGHT_RATES');
      END IF;*/
     --Freight Rating End
      --oe_debug_pub.add('Freight RATE :-(');
      IF FND_FUNCTION.TEST('ONT_OEXOEORD_FRTCOSTS') THEN
            Add_Access('VIEW_FREIGHT_COSTS');
      END IF;


      --ABH
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
          IF FND_FUNCTION.TEST('OKC_CONTRACT_TERMS_FORMS') THEN

             --Make a check to see if contracts has been licensed
             IF OE_Contracts_util.check_license() = 'Y' THEN
                Add_Access('CONTRACT_TERMS');
             END IF;

          END IF;

          IF FND_FUNCTION.TEST('ONT_PRINT') THEN

             --Add the preview print only if XDO is licensed
             l_is_xdo_licensed := Oe_Globals.CHECK_PRODUCT_INSTALLED (p_application_id => 603);  --Oracle XML Publisher
             IF l_is_xdo_licensed = 'Y' THEN
                Add_Access('PREVIEW_AGREEMENT');
             END IF;

          END IF;

          IF FND_FUNCTION.TEST('OKC_REPO_DOC_SUMMARY_FORMS') THEN

             --Make a check to see if contracts has been licensed
             IF OE_Contracts_util.check_license() = 'Y' THEN
                Add_Access('CONTRACT_DOCUMENT');
             END IF;

          END IF;
      END IF;
      --ABH
      --Customer Acceptance
       IF FND_FUNCTION.TEST('ONT_OEXOEORD_FULFILL_ACCEPT') THEN
        Add_Access('FULFILLMENT_ACCEPTANCE');
       END IF;


      OE_ORDER_UTIL.G_Access_List_Initialized:='Y';
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ORDER_UTIL.INITIALIZE_ACCESS_LIST' , 1 ) ;
      END IF;

END Initialize_Access_List;

PROCEDURE Add_Access(Function_Name VARCHAR2)
IS
   i  number:=0;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_UTIL.ADD_ACCESS' , 1 ) ;
      END IF;
     IF OE_GLOBALS.G_ACCESS_List.Count=0 THEN
       OE_GLOBALS.G_Access_List(1):=Function_Name;
     ELSIF OE_GLOBALS.G_ACCESS_List.Count>0 THEN
       i:=OE_GLOBALS.G_ACCESS_List.Last+1;
       OE_GLOBALS.G_ACCESS_List(i):=Function_Name;
     END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ORDER_UTIL.ADD_ACCESS' , 1 ) ;
      END IF;
   EXCEPTION
    When Others Then
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IS_ACTION_IN_ACCESS_LIST'
            );
        END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_Access;

FUNCTION IS_ACTION_IN_ACCESS_LIST(Action_code in varchar2)
RETURN BOOLEAN IS
  rg_count number;
  j number;
  exit_function  exception;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_UTIL.IS_ACTION_IN_ACCESS_LIST' , 1 ) ;
      END IF;
  IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >='110508' THEN
    IF OE_ORDER_UTIL.G_Access_List_Initialized IS NULL THEN
      Initialize_Access_List;
    END IF;

    rg_count:=OE_GLOBALS.G_ACCESS_List.Last;

    IF rg_count=0 THEN
      Return FALSE ;
    ELSE
     For j in 1..rg_count LOOP
      IF upper(OE_GLOBALS.G_Access_List(j))=upper(action_code) THEN
        return TRUE;
      END IF;
     END LOOP;
    END IF;
  ELSE
     Return(True);
  END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_ORDER_UTIL.IS_ACTION_IN_ACCESS_LIST' , 1 ) ;
   END IF;
   RAISE Exit_Function;
  EXCEPTION
    When Exit_Function Then
    Return FALSE;
    When Others Then
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IS_ACTION_IN_ACCESS_LIST'
            );
        END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IS_ACTION_IN_ACCESS_LIST;

PROCEDURE Get_Access_List
                (
p_Access_List OUT NOCOPY OE_GLOBALS.ACCESS_LIST)

IS

BEGIN
  Initialize_Access_List;
  p_access_list:=OE_GLOBALS.G_ACCESS_LIST;
END Get_Access_List;

Function Get_Precision(
                         p_currency_code IN Varchar2  Default Null,
                         p_header_id     IN Number Default Null,
                         p_line_id       IN Number Default Null
                        )
RETURN BOOLEAN IS
l_currency_code Varchar2(100);
l_precision     NUMBER;
l_ext_precision NUMBER;
l_min_acct_unit NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF p_currency_code IS NULL AND p_header_id IS NOT NULL THEN
   SELECT TRANSACTIONAL_CURR_CODE
   INTO   l_currency_code
   FROM   OE_ORDER_HEADERS
   WHERE  HEADER_ID=p_header_id;
ELSIF p_header_id IS NULL AND p_currency_code IS NULL AND p_line_id IS NOT NULL THEN
   SELECT /*MOAC_SQL_CHANGES*/ OH.TRANSACTIONAL_CURR_CODE
   INTO   l_currency_code
   FROM   OE_ORDER_HEADERS OH, OE_ORDER_LINES_ALL OL
   WHERE  OH.HEADER_ID=OL.HEADER_ID
   AND    OL.LINE_ID=p_line_id;
ELSIF p_currency_code IS NOT NULL THEN
   l_currency_code:=p_currency_code;
END IF;

IF l_debug_level > 0 THEN
   OE_DEBUG_PUB.add('Currency Code : '||l_currency_code,5);
END IF;

IF l_currency_code IS NOT NULL THEN
   FND_CURRENCY.GET_INFO(l_currency_code,
                          l_precision,
                          l_ext_precision,
                          l_min_acct_unit
                         );
   -- #2713025
   OE_ORDER_UTIL.G_Precision := l_precision;
   G_Header_Id:=p_header_id;
   G_line_id:=p_line_id;
   Return(TRUE);
ELSE
   l_precision:=2;
   OE_ORDER_UTIL.G_Precision := l_precision;
   G_Header_Id:=p_header_id;
   G_line_id:=p_line_id;
   Return(TRUE);
END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
               l_precision:=2;
               G_Header_Id:=p_header_id;
               G_line_id:=p_line_id;
               Return(TRUE);
          WHEN TOO_MANY_ROWS THEN
               Return(FALSE);
          WHEN OTHERS THEN
               Return(FALSE);
END GET_Precision;

PROCEDURE RAISE_BUSINESS_EVENT(
                               p_header_id IN Number Default Null,
	                       p_line_id   IN Number Default Null,
                               p_status    IN Varchar2 Default Null
                               )
IS
l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
l_event_name            varchar2(200);
BEGIN


If NVL (Fnd_Profile.Value('ONT_RAISE_STATUS_CHANGE_BUSINESS_EVENT'), 'N')='Y' THEN

l_event_name := 'oracle.apps.ont.oip.statuschange.update' ;

wf_event.AddParameterToList(p_name=>          'HEADER_ID',
		            p_value=>         p_header_id,
			    p_parameterlist=> l_parameter_list);

wf_event.AddParameterToList(p_name=>          'LINE_ID',
			    p_value=>         p_line_id,
			    p_parameterlist=> l_parameter_list);

wf_event.AddParameterToList(p_name=>          'STATUS_CODE',
			    p_value=>         p_status,
		            p_parameterlist=> l_parameter_list);

 wf_event.raise(p_event_name => l_event_name,
   		p_event_key => OE_RAISE_BUSINESS_EVENT_S.nextval,
		p_parameters => l_parameter_list);

end if;

End RAISE_BUSINESS_EVENT;

END OE_ORDER_UTIL;

/
