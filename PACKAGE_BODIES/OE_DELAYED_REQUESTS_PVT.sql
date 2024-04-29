--------------------------------------------------------
--  DDL for Package Body OE_DELAYED_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DELAYED_REQUESTS_PVT" AS
/* $Header: OEXVREQB.pls 120.25.12010000.25 2012/09/14 08:17:47 rahujain ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Delayed_Requests_PVT';
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8233604

g_requesting_entities  		OE_Order_PUB.Requesting_Entity_Tbl_Type;
G_MAX_REQUESTS                  NUMBER := 10000;

/* Local Procedures */
/* Local procedure to check if a request exists for a given entity, request
   return the result in p_request_search_result which is set to FND_API.G_TRUE
   if the request exists. The index of the request in request table is returned
   in parameter x_request_ind

   BUG 1794544 -
   05/30/01: Changes to improve scalability of this search when there
   is a large number of requests:

   The index value where the request is stored is a function of the
   entity_id value (the function  was chosen to be 'mod' as this has
   a high probability of resulting in a unique value as line ids are
   generated sequentially). Therefore, this check would search only
   through requests for the entity_id that resolves to the same
   mod value.

   If the request does NOT exist, then x_result is set to FND_API.G_FALSE
   and the parameter x_request_ind has the index value where this request
   should be inserted.
*/

PROCEDURE Process_Scheduling_Request
( p_request_ind    IN  NUMBER
 ,p_request_rec    IN  OE_Order_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Check_Pricing_Request
( p_request_ind    IN  NUMBER
 ,p_request_rec    IN  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.request_rec_type
 ,x_log_request    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

Procedure  Check_for_Request( p_entity_code    in Varchar2
			      ,p_entity_id     in Number
			      ,p_request_type  in Varchar2
			      ,p_request_unique_key1 	IN VARCHAR2
			      ,p_request_unique_key2 	IN VARCHAR2
			      ,p_request_unique_key3 	IN VARCHAR2
			      ,p_request_unique_key4 	IN VARCHAR2
			      ,p_request_unique_key5 	IN VARCHAR2
,x_request_ind OUT NOCOPY Number

,x_result OUT NOCOPY Varchar2

,x_return_status OUT NOCOPY Varchar2)

IS
     l_ind	PLS_INTEGER;
     l_max_ind  PLS_INTEGER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_return_status	:= FND_API.G_RET_STS_SUCCESS;
   x_result		:= FND_API.G_FALSE;
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Entering Procedure Check_for_Request in Package OE_Delayed_Requests_Pvt');
   END IF;
   -- l_ind to l_max_ind is the range of index positions that can
   -- hold requests for this entity id - for e.g. if entity_id is
   -- 2341 and G_MAX_REQUESTS is 10000 then the range would be:
   -- 23410001 - 23420000

   l_ind := (mod(p_entity_id,100000) * G_MAX_REQUESTS)+1;
   l_max_ind := l_ind + G_MAX_REQUESTS - 1;

   --oe_debug_pub.add('Max Ind :'||l_max_ind);

   -- Starting from l_ind, search for the first index position
   -- with a request. This is required as requests can be
   -- deleted later which will result in indexes without any
   -- requests. However, the search should still go over the
   -- requests in the range from l_ind to l_max_ind.

   IF NOT G_Delayed_Requests.Exists(l_ind) THEN
      x_request_ind := l_ind;
      l_ind := G_Delayed_Requests.Next(l_ind);
   END IF;

   WHILE G_Delayed_Requests.Exists(l_ind)
         AND l_ind <= l_max_ind LOOP

        x_request_ind := l_ind+1;

        --oe_debug_pub.add('Index :'||l_ind);
        --oe_debug_pub.add('Entity :'||G_Delayed_Requests(l_ind).Entity_code);
        --oe_debug_pub.add('Entity ID:'||G_Delayed_Requests(l_ind).entity_id);
        --oe_debug_pub.add('Request:'||G_Delayed_Requests(l_ind).request_type);

	IF G_Delayed_Requests(l_ind).Entity_code = p_entity_code
	  AND
	  G_Delayed_Requests(l_ind).Entity_id = p_entity_id
	  AND
	  G_Delayed_Requests(l_ind).Request_Type = p_request_type
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key1, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key1, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key2, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key2, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key3, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key3, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key4, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key4, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key5, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key5, FND_API.G_MISS_CHAR)
          AND NVL(G_Delayed_Requests(l_ind).processed,'N') = 'N'
	THEN
	   x_request_ind := l_ind;
	   x_result := FND_API.G_TRUE;
	   EXIT;
	END IF;

        l_ind := G_Delayed_Requests.Next(l_ind);

     END LOOP;

     IF x_request_ind > l_max_ind THEN
        FND_MESSAGE.SET_NAME('ONT','OE_MAX_REQUESTS_EXCEEDED');
        OE_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'CheckForRequest');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Check_For_Request;

FUNCTION Requests_Count
RETURN NUMBER
IS
BEGIN

	RETURN G_Delayed_Requests.COUNT;

END Requests_Count;

PROCEDURE Process_Request_Pvt
   (p_request_ind	IN Number
   ,p_delete            IN Varchar2 default  FND_API.G_FALSE
,x_return_status OUT NOCOPY VARCHAR2)

IS
cursor included_lines_cur(p_header_id in number) is
select line_id
from oe_order_lines_all
where header_id = p_header_id
and item_type_code = 'INCLUDED';

l_request_rec       OE_Order_PUB.request_rec_type;
l_request_type	VARCHAR2(30);
l_return_status	VARCHAR2(1);
l_entity_id	NUMBER;
l_entity_code	Varchar2(30);
l_req_entity_ind		number;
l_set_index     NUMBER;
l_set_request  OE_Order_PUB.request_tbl_type;
l_sch_set_tbl          OE_Order_PUB.request_tbl_type;
l_deleted_options_tbl  OE_Order_PUB.request_tbl_type;
l_updated_options_tbl  OE_Order_PUB.request_tbl_type;
l_index                NUMBER;
l_d_index              NUMBER;
l_u_index              NUMBER;
l_set                  VARCHAR2(2000);
K                      NUMBER;
l_cto_request_rec      OE_Order_PUB.request_rec_type;
l_cto_request_tbl      OE_Order_PUB.request_tbl_type;
l_cto_split_tbl        OE_Order_PUB.request_tbl_type;
l_cto_decimal_tbl      OE_Order_PUB.request_tbl_type;
l_line_Tbl 			OE_ORDER_PUB.line_Tbl_type;
l_prc_adj_request      OE_ORDER_PUB.request_tbl_type;
l_prc_adj_index NUMBER := 1;
I                      NUMBER := 1;
l_price_control_rec		QP_PREQ_GRP.control_record_type;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_entity_id_tbl    		Entity_Id_Tbl_Type;
j   number := 1;
l_unit_cost                     number; --MRG
l_count               NUMBER; --2391781
l_set_id              NUMBER := NULL; -- 2391781
payment_line_id       NUMBER;
payment_header_id     NUMBER;
old_invoice_to_org_id NUMBER; --R12 CC Encryption

l_header_id      NUMBER; -- For IR ISO CMS Project
l_line_id        NUMBER; -- For IR ISO CMS Project
l_cancel_order   BOOLEAN := FALSE; -- For IR ISO CMS Project
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_mod_entity_id  number; -- Bug 8636027

l_otm_volume NUMBER; --BUG#10052614
l_dynamic_call varchar2(1000); -- Bug#10052614


BEGIN
 IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering Procedure Process_Request_Pvt ',1);
      oe_debug_pub.add('Request processed  '||G_Delayed_Requests(p_request_ind).processed);
 END IF;

IF NOT oe_globals.g_call_process_req THEN --9354229
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT Procedure Process_Request_Pvt' , 1 ) ;
      END IF;
      RETURN;
END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- if request has already been processed ('Y') or if the request is
      -- being processed ('I'): this would occur if request resulted in
      -- to a recursive call to process order (bug#1003821)
      if  (G_Delayed_Requests(p_request_ind).processed = 'Y'
		OR G_Delayed_Requests(p_request_ind).processed = 'I')
	 then
          RETURN;
      end if;
      l_request_rec :=  G_Delayed_Requests(p_request_ind);
      l_entity_code    := l_request_rec.entity_code;
      l_entity_Id      := l_request_rec.entity_Id;
      l_request_type   := l_request_rec.request_type;
 IF l_debug_level > 0 THEN
      oe_debug_pub.add('Request type  '||l_request_type,1);
      oe_debug_pub.add('Entity id     '||l_entity_id, 5);
      oe_debug_pub.add('param1        '||l_request_rec.param1, 5);
      oe_debug_pub.add('param2        '||l_request_rec.param2, 5);
      oe_debug_pub.add('param3        '||l_request_rec.param3, 5);
 END IF;
          G_Delayed_Requests(p_request_ind).processed := 'I';

 IF l_debug_level > 0 THEN
      IF OE_GLOBALS.G_CASCADING_REQUEST_LOGGED THEN
         oe_debug_pub.add('cascade flag set to true');
      ELSE
         oe_debug_pub.add('cascade flag set to false');
      END IF;
 END IF;
      -- Fix Bug 2062937: Do not set the cascade flag blindly for certain
      -- delayed requests.
      -- This will improve the performance of sales order form as lines
      -- would not be re-queried if cascade flag is not set.
      -- Requests for which cascade flag is not set:
      -- 1) Pricing Integration will set the cascade flag only if order level
      -- modifiers result in a change to attributes on any lines on this order.
      -- 2) Verify Payment will set the cascade flag only if there are updates
      -- back to the header for credit card payments.
      -- 3) Apply Automatic Attachments: never results in an update back to order/lines.
      -- NOTE: All other delayed requests also need to be evaluated so
      -- that cascade flag is set in the request and not here.
      IF OE_GLOBALS.G_PROCESS_OBJECTS_FLAG = TRUE THEN

         IF l_Request_type NOT IN ('RECORD_HISTORY'
                            ,OE_GLOBALS.G_PRICE_ORDER
                            ,OE_GLOBALS.G_PRICE_ADJ
                            ,OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT
                            ,OE_GLOBALS.G_VERIFY_PAYMENT
                            ,OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP
                            ,OE_GLOBALS.G_CHECK_HSC_QUOTA_TOTAL
			    ,OE_GLOBALS.G_GENERATE_XML_REQ_HDR
			    ,OE_GLOBALS.G_GENERATE_XML_REQ_LN)
         THEN
            IF l_debug_level > 0 THEN
            oe_debug_pub.add('****** process_obj=>delayed req execution ****', 1);
            END IF;
            OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
         END IF;

      END IF;


     IF l_Request_type = 'RECORD_HISTORY' THEN
         NULL;
     ELSIF l_request_type = OE_GLOBALS.G_CHECK_PERCENTAGE
	 THEN

	 OE_DELAYED_REQUESTS_UTIL.check_percentage
			(p_request_rec	     => l_request_rec,
			 x_return_status     => l_return_status);

       ELSIF l_request_type = OE_GLOBALS.G_CHECK_DUPLICATE THEN

	 OE_DELAYED_REQUESTS_UTIL.check_duplicate
			(p_request_rec	     => l_request_rec,
			 x_return_status     => l_return_status);

       ELSIF l_request_type = OE_GLOBALS.G_CANCEL_WF THEN

	 OE_SALES_CAN_UTIL.Cancel_Wf
			(x_request_rec	     => l_request_rec,
			 x_return_status     => l_return_status);

       ELSIF l_request_type = OE_GLOBALS.G_CHECK_FIXED_PRICE
	 THEN

	 OE_DELAYED_REQUESTS_UTIL.check_fixed_price
			(p_request_rec	     => l_request_rec,
			 x_return_status     => l_return_status);

       ELSIF l_request_type = OE_GLOBALS.G_PRICE_ADJ THEN
 IF l_debug_level > 0 THEN
	   Oe_Debug_pub.Add('Before Executing Delayed request Price Adjustment for '||l_request_rec.entity_id);
 END IF;
		/* 1905650
	           G_PRICE_ADJ request is now logged against LINE entity
	        */
	 	If l_entity_code = OE_GLOBALS.G_ENTITY_LINE Then

			oe_order_adj_pvt.Price_Adjustments(
				X_Return_Status     => l_Return_Status
				,p_Header_id        => Null
				,p_Line_id          => l_request_rec.entity_id
				,p_request_type_code=> 'ONT'
				,p_request_rec      => l_request_rec
				);
		Else
			oe_order_adj_pvt.Price_Adjustments(
				X_Return_Status     => l_Return_Status
				,p_Header_id        => l_request_rec.entity_id
				,p_Line_id          => null
				,p_request_type_code=> 'ONT'
				,p_request_rec      => l_request_rec
				);
		End if;
     IF l_debug_level > 0 THEN
	   	Oe_Debug_pub.Add('After Executing Delayed request Price Adj for '||l_request_rec.entity_id);
     END IF;
       ELSIF l_request_type =
                        OE_GLOBALS.G_CHECK_HSC_QUOTA_TOTAL then
           if l_entity_code = OE_GLOBALS.G_ENTITY_HEADER_SCREDIT
            OR l_entity_code = OE_GLOBALS.G_ENTITY_ALL then   -- bug 5746190
             OE_DELAYED_REQUESTS_UTIL.Validate_HSC_QUOTA_TOTAL
                 ( x_return_status =>l_return_status
                  ,p_header_id     =>to_number(l_request_rec.param1)
                 );
           end if;

       ELSIF l_request_type =
                         OE_GLOBALS.G_CHECK_LSC_QUOTA_TOTAL then
           if l_entity_code = OE_GLOBALS.G_ENTITY_Line_SCREDIT then
             OE_DELAYED_REQUESTS_UTIL.Validate_LSC_QUOTA_TOTAL
                 ( x_return_status =>l_return_status
                  ,p_line_id     =>to_number(l_request_rec.param1)
                 );
           end if;

       ELSIF l_request_type =
                         OE_GLOBALS.G_CHECK_LSC_QUOTA_TOTAL then
           if l_entity_code = OE_GLOBALS.G_ENTITY_Line_SCREDIT then
             OE_DELAYED_REQUESTS_UTIL.Validate_LSC_QUOTA_TOTAL
                 ( x_return_status =>l_return_status
                  ,p_line_id     =>to_number(l_request_rec.param1)
                 );
           end if;

       ELSIF l_request_type =
                         OE_GLOBALS.G_CASCADE_SERVICE_SCREDIT then
           IF l_entity_code = OE_GLOBALS.G_ENTITY_Line_SCREDIT THEN
             OE_DELAYED_REQUESTS_UTIL.Cascade_Service_Scredit
                 ( x_return_status =>l_return_status
                  ,p_request_rec   =>l_request_rec
                 );
           end if;


       ELSIF  (l_request_type = OE_GLOBALS.G_CREATE_SETS) then
               OE_DELAYED_REQUESTS_UTIL.Insert_Set
			(p_request_rec  => l_request_rec,
			 x_return_status     => l_return_status);
       ELSIF  l_request_type = OE_GLOBALS.G_INSERT_INTO_SETS then
           IF l_entity_code = OE_GLOBALS.G_ENTITY_LINE then
/* Commenting out nocopy per Rupal */

		 null;
           /*  OE_Process_Models.Insert_Into_Line_Sets
                  (p_line_id            =>l_entity_id
                   ,p_top_model_line_id =>l_request_rec.param2
                   ,p_set_type          => 'ALL'
                   ,x_return_status     =>l_return_status
                 ); */
           END IF;
       ELSIF  l_request_type = OE_GLOBALS.G_VALIDATE_LINE_SET then
			oe_delayed_requests_util.validate_line_set(
				p_line_set_id => l_request_rec.entity_id,
				x_return_status => l_return_status);
       ELSIF l_request_type =
                        OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP then
             OE_DELAYED_REQUESTS_UTIL.DFLT_Hscredit_Primary_Srep
                 ( x_return_status =>l_return_status
                  ,p_header_id     =>to_number(l_request_rec.param1)
                  ,p_salesrep_id   =>to_number(l_request_rec.param2)
                 );


       ELSIF l_request_type =
                        OE_GLOBALS.G_VERIFY_PAYMENT then
               OE_DELAYED_REQUESTS_UTIL.Verify_Payment
                 ( x_return_status      =>l_return_status
                  ,p_header_id     => l_entity_id
                 );

       ELSIF l_request_type =
                        OE_GLOBALS.G_INSERT_RMA then
               OE_DELAYED_REQUESTS_UTIL.INSERT_RMA_SCREDIT_ADJUSTMENT
                 ( x_return_status      =>l_return_status
                  ,p_line_id     => l_entity_id
                 );
               OE_DELAYED_REQUESTS_UTIL.INSERT_RMA_OPTIONS_INCLUDED
                 ( x_return_status      =>l_return_status
                  ,p_line_id     => l_entity_id
                 );
               -- Do not call INSERT_RMA_LOT_SERIAL for system split.
               -- Bug 4651421
               IF NOT((l_request_rec.param1 = OE_GLOBALS.G_OPR_UPDATE and
                   nvl(l_request_rec.param2,'USER') = 'SYSTEM' and
                   NVL(l_request_rec.param3,'X') = 'SPLIT')
                   OR
                   (l_request_rec.param1 = OE_GLOBALS.G_OPR_CREATE AND
                    l_request_rec.param4 IS NOT NULL AND
                    nvl(l_request_rec.param2, 'USER') = 'SYSTEM'))
               THEN
                   OE_DELAYED_REQUESTS_UTIL.INSERT_RMA_LOT_SERIAL
                   ( x_return_status      =>l_return_status
                    ,p_line_id     => l_entity_id
                   );
               END IF;
       ELSIF l_request_type = OE_GLOBALS.G_TAX_LINE then

         -- Renga - changed so that we call Process_Tax
         l_entity_id_tbl(1).entity_id := l_entity_id;
         -- l_entity_id_tbl(l_count).request_ind := 1;

         l_entity_id_tbl(1).request_ind := p_request_ind;

          /*
	      OE_DELAYED_REQUESTS_UTIL.TAX_LINE
             (  x_return_status => l_return_status
	           , p_line_id  =>  l_entity_id
		    );
           */

           OE_Delayed_Requests_UTIL.Process_Tax
             (p_Entity_id_tbl      => l_entity_id_tbl
              ,x_return_status     => l_return_status
             );

	  ELSIF l_request_type = OE_GLOBALS.G_SPLIT_HOLD then
              OE_DELAYED_REQUESTS_UTIL.Split_hold
			    ( p_entity_code        => l_request_rec.entity_code
				,p_entity_id          => l_request_rec.entity_id
				,p_split_from_line_id => l_request_rec.param1
				,x_return_status      => l_return_status
			    );
       ELSIF l_request_type =
                        OE_GLOBALS.G_EVAL_HOLD_SOURCE then
               OE_DELAYED_REQUESTS_UTIL.Eval_Hold_Source
                 ( x_return_status      => l_return_status
                  ,p_entity_code	=> l_request_rec.entity_code
                  ,p_entity_id		=> l_request_rec.entity_id
                  ,p_hold_entity_code   => l_request_rec.param1
                  ,p_hold_entity_id	=> l_request_rec.param2
                 );

      /* 1739574 */
      ELSIF  l_request_type = OE_GLOBALS.G_COMPLETE_ACTIVITY THEN
  IF l_debug_level > 0 THEN
	    oe_debug_pub.ADD('Calling wf_engine.CompleteActivityInternalName for '||l_request_rec.param1 || '/'||l_request_rec.param2||'/'||l_request_rec.param3 ||'/'||'/'||l_request_rec.param4, 3);
  END IF;
       	    wf_engine.CompleteActivityInternalName(l_request_rec.param1,l_request_rec.param2,l_request_rec.param3,l_request_rec.param4);
  IF l_debug_level > 0 THEN
	    oe_debug_pub.ADD('Returned from wf_engine.CompleteActivityInternalName ',3);
  END IF;
  -- Start of bug 10032407
     ELSIF  l_request_type = OE_GLOBALS.G_SKIP_ACTIVITY THEN
        if l_debug_level > 0 then
           oe_debug_pub.ADD('Calling wf_engine.CompleteActivityInternalName for '||l_request_rec.param1 || '/'||l_request_rec.param2||'/'||l_request_rec.param3 ||'/'||'/'||l_request_rec.param4, 3);
        end if;
	BEGIN
	   wf_engine.CompleteActivityInternalName(l_request_rec.param1,l_request_rec.param2,l_request_rec.param3,l_request_rec.param4);
	EXCEPTION
	  WHEN OTHERS THEN
	    IF l_debug_level > 0 THEN
	      oe_debug_pub.ADD('Calling wf_engine.handleerror for '||l_request_rec.param1 || '/'||l_request_rec.param2||'/'||l_request_rec.param3 ||'/'||'/'||l_request_rec.param4, 3);
	    END IF;
            OE_SHIPPING_WF.G_DEV_SKIP := 'Y';
            wf_engine.handleerror(l_request_rec.param1,l_request_rec.param2,l_request_rec.param3,'SKIP',l_request_rec.param4);
            if l_debug_level > 0 then
              oe_debug_pub.ADD('Returned from wf_engine.handleerror ',3);
            end if;
	END;
  -- End of bug 10032407
      ELSIF l_request_rec.request_type = OE_GLOBALS.G_UPDATE_SHIPPING THEN

		OE_Delayed_Requests_UTIL.Update_Shipping
			( p_update_shipping_tbl => g_delayed_requests
			, p_line_id		    => l_request_rec.entity_id
			, p_operation           => l_request_rec.request_unique_key1
			, x_return_status       => l_return_status
		  );

	   ELSIF l_request_rec.request_type = OE_GLOBALS.G_SHIP_CONFIRMATION THEN

		OE_Delayed_Requests_UTIL.Ship_Confirmation
			( p_ship_confirmation_tbl => g_delayed_requests
			, p_line_id		      => l_request_rec.entity_id
			, p_process_type	      => l_request_rec.request_unique_key1
			, p_process_id			 => l_request_rec.param1
			, x_return_status         => l_return_status
		  );

  ELSIF l_request_rec.request_type = OE_GLOBALS.G_PRE_EXPLODED_KIT THEN

  /* Start DOO Pre Exploded Kit ER 9339742 */
  /* Note: It should be ensured that this delayed request should be executed only
           after all the lines in p_line_tbl input primer of the Process Order api are
           processed. If this delayed request gets executed as part of delayed request
           execution for a single record then at the time of executing this delayed
           request, there may be a case that all the lines of the Kit are not processed
           leading to sure failure of this delayed request, which is incorrect. Hence, if
           we happen to find this issue in future then we should introduce a new global and
           set it to TRUE soon after the main big WHILE loop completes in
           OE_Order_Pvt.Lines. Hence, ensure to check that global to TRUE before executing
           this delayed request. If it is FALSE then reset the delayed request execution
           (G_Delayed_Requests(p_request_ind).processed) to N. While this global is set
           ensure to reset it to FALSE in the starting of the big WHILE Loop of the
           OE_Order_Pvt.Lines and in the Exception block of it, and the Process_Request_Pvt
           and Process_Delayed_Request procedures
  */

    If l_debug_level > 0 then
      oe_debug_pub.add(' Processing DOO Pre Exploded ER');
    End if;

    OE_Delayed_Requests_UTIL.Process_Pre_Exploded_Kits
    ( p_top_model_line_id => l_request_rec.entity_id
    , p_explosion_date    => l_request_rec.date_param1
    , x_return_status     => l_return_status);

    If l_debug_level > 0 then
      oe_debug_pub.add(' Processed DOO Pre Exploded ER');
    End if;

  /* End DOO Pre Exploded Kit ER 9339742 */



/* 7576948: IR ISO Change Management project Start */
-- This code is hooked up for IR ISO project so as to trigger
-- the new procedure OE_Delated_Requests_Util.Update_Requisition_Info
-- for update of internal requisition based on changes offered by
-- sales order user w.r.t Ordered Quantity, Schedule Ship/Arrival
-- Date or Line/Header cancellation

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc


 ELSIF l_request_rec.request_type = OE_GLOBALS.G_UPDATE_REQUISITION THEN

   IF NVL(l_request_rec.param2,'N') = 'Y' THEN
     IF l_debug_level > 0 THEN
       oe_debug_pub.add('Requisition Header Cancellation is TRUE',5);
     END IF;
     l_cancel_order := TRUE;

     -- For Requisition Header Cancellation, following information is not needed -
     l_request_rec.param1 := NULL;
     l_request_rec.param4 := NULL; --bug 14211120
     l_request_rec.date_param1 := NULL;
   ELSE
     IF l_debug_level > 0 THEN
       oe_debug_pub.add('Requisition Header Cancellation is FALSE',5);
     END IF;
     l_cancel_order := FALSE;
   END IF;

   IF l_request_rec.entity_code = OE_Globals.G_Entity_Header THEN
     l_header_id := l_request_rec.entity_id;
     l_line_id   := NULL;
   ELSIF l_request_rec.entity_code = OE_Globals.G_Entity_Line THEN
     l_header_id := l_request_rec.request_unique_key1;
     l_line_id   := l_request_rec.entity_id;
   END IF;

   OE_Delayed_Requests_UTIL.Update_Requisition_Info
         ( P_Requisition_Header_id  => l_request_rec.request_unique_key2
         , P_Requisition_Line_id    => l_request_rec.request_unique_key3
         , P_Header_id              => l_header_id
         , p_Line_id                => l_line_id
         , p_Line_ids               => l_request_rec.long_param1
         , p_num_records            => l_request_rec.param3
         , P_Quantity_Change        => l_request_rec.param1
         , P_Quantity2_Change       => l_request_rec.param4 --Bug 14211120
         , P_New_Schedule_Ship_Date => l_request_rec.date_param1
         , P_Cancel_order           => l_cancel_order  -- Param2
         , X_Return_Status          => l_return_status
         );


/* ============================= */
/* IR ISO Change Management Ends */


       ELSIF l_request_type =
                        OE_GLOBALS.G_CASCADE_CHANGES then
           IF l_debug_level > 0 THEN
            oe_debug_pub.add('Performing Delayed Req for Cascade Changes',1);
           END IF;

            OE_CONFIG_UTIL.CASCADE_CHANGES
                      ( p_parent_line_id   => l_request_rec.entity_id
                      , p_request_rec      => l_request_rec
                      , x_return_status    => l_return_status
                      );
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('done Delayed Req for Cascade Changes',1);
          END IF;

       ELSIF l_request_type =
                        OE_GLOBALS.G_CHANGE_CONFIGURATION then

            oe_debug_pub.add('Performing Delayed Req for Change Config',1);

            OE_CONFIG_UTIL.CHANGE_CONFIGURATION
                      ( p_request_rec      => l_request_rec
                      , x_return_status    => l_return_status
                      );
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('Done Delayed Req for Change Config',1);
          END IF;

       ELSIF l_request_type =
                        OE_GLOBALS.G_CREATE_RESERVATIONS then
             OE_DELAYED_REQUESTS_UTIL.SPLIT_RESERVATIONS
                      ( p_reserved_line_id   => l_request_rec.entity_id
                      , p_ordered_quantity   => to_number(l_request_rec.param1)
                      , p_reserved_quantity  => to_number(l_request_rec.param2)
                      , x_return_status      => l_return_status
                      );

       ELSIF l_request_type =
                        OE_GLOBALS.G_COPY_CONFIGURATION then
             OE_Config_Pvt.Copy_Config
                     ( p_top_model_line_id  => l_request_rec.entity_id ,
                       p_config_hdr_id      => l_request_rec.param1 ,
                       p_config_rev_nbr     => l_request_rec.param2 ,
                       p_configuration_id   => l_request_rec.param4 ,
                       p_remnant_flag       => l_request_rec.param3 ,
                       x_return_status      => l_return_status
                     );

       ELSIF l_request_type =
                        OE_GLOBALS.G_COMPLETE_CONFIGURATION then
             OE_DELAYED_REQUESTS_UTIL.COMPLETE_CONFIGURATION
                      ( p_top_model_line_id  => l_request_rec.entity_id
                      , x_return_status      => l_return_status
                      );
       -- No Processing here. The processing will be done in
       -- Process_Delayed_Requests at the Commit Time.

       ELSIF l_request_type = OE_GLOBALS.G_DROPSHIP_CMS THEN
          RETURN;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
       ELSIF l_request_type = OE_GLOBALS.G_UPDATE_OPTION THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('upd: processed with cfg val', 3);
         END IF;
         RETURN;

       ELSIF l_request_type = OE_GLOBALS.G_DELETE_OPTION THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('del: processed with cfg val', 3);
         END IF;
         RETURN;

       ELSIF l_request_type =
                        OE_GLOBALS.G_VALIDATE_CONFIGURATION
       THEN

         -- Get the delayed requests logged for deletions and updatations
         -- which needs to be passed to validate_configuration.

         l_d_index := 0;
         l_u_index := 0;
         K         := G_Delayed_Requests.FIRST;

         WHILE K is not null -- while loop safe that tbl.first to last
         LOOP

            IF G_Delayed_Requests(K).request_type = OE_GLOBALS.G_DELETE_OPTION  OR
               G_Delayed_Requests(K).request_type = OE_GLOBALS.G_UPDATE_OPTION
            THEN

                IF G_Delayed_Requests(K).request_type = OE_GLOBALS.G_DELETE_OPTION
                   AND G_Delayed_Requests(K).param1 = l_request_rec.entity_id
                THEN
                    l_d_index := l_d_index + 1;
	    	      l_deleted_options_tbl(l_d_index) :=
                                   g_delayed_requests(K);
                END IF;

                IF G_Delayed_Requests(K).request_type = OE_GLOBALS.G_UPDATE_OPTION
                   AND G_Delayed_Requests(K).param1 = l_request_rec.entity_id
                THEN
                    l_u_index := l_u_index + 1;
	  	        l_updated_options_tbl(l_u_index) :=
                                   g_delayed_requests(K);
                END IF;
                -- delete after both updete and delete checks,
                -- if deleted in the inside if, no_data_found exceptiion
                -- g_delayed_requests.delete(K);
            END IF;
            K :=  G_Delayed_Requests.NEXT(K);
         END LOOP;
         IF l_debug_level > 0 THEN
             oe_debug_pub.add('out of loop for upd/del options table', 1);
         END IF;

         OE_DELAYED_REQUESTS_UTIL.VALIDATE_CONFIGURATION
                ( p_top_model_line_id   => l_request_rec.entity_id
                , p_deleted_options_tbl => l_deleted_options_tbl
                , p_updated_options_tbl => l_updated_options_tbl
                , x_return_status       => l_return_status
                );
         IF l_debug_level > 0 THEN
             oe_debug_pub.add('ret sts: '|| x_return_status, 4);
         END IF;

         IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
           oe_debug_pub.add('deleteing after success ', 3);
           K         := G_Delayed_Requests.FIRST;

           WHILE K is not null
           LOOP
             IF (G_Delayed_Requests(K).request_type =
                   OE_GLOBALS.G_DELETE_OPTION  OR
                 G_Delayed_Requests(K).request_type =
                   OE_GLOBALS.G_UPDATE_OPTION ) AND
                 G_Delayed_Requests(K).param1 = l_request_rec.entity_id
             THEN
               G_Delayed_Requests.delete(K);
             END IF;

             K := G_Delayed_Requests.NEXT(K);

           END LOOP;
         END IF;


       ELSIF l_request_type = OE_GLOBALS.G_CTO_CHANGE THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('cto: processed with notification', 3);
         END IF;
         RETURN;

       ELSIF l_request_type =
                        OE_GLOBALS.G_CTO_NOTIFICATION then
         -- loop over and call cto
         IF l_debug_level > 0 THEN
             oe_debug_pub.add('cto notification excecution', 2);
         END IF;

         K := G_Delayed_Requests.FIRST;

         WHILE K is not null
         LOOP
           IF G_Delayed_Requests(K).request_type =
                     OE_GLOBALS.G_CTO_CHANGE AND
              G_Delayed_Requests(K).param3 = l_request_rec.entity_id
           THEN
              IF l_debug_level > 0 THEN
                 oe_debug_pub.add(K || 'cto change req ', 3);
              END IF;
             IF G_Delayed_Requests(K).request_unique_key1 = 'Quantity'
             THEN
               l_cto_request_rec.param1 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param2 := G_Delayed_Requests(K).param2;

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Req Date'
             THEN
               l_cto_request_rec.param3 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param4 := G_Delayed_Requests(K).param2;

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Ship Date'
             THEN
               l_cto_request_rec.param5 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param6 := G_Delayed_Requests(K).param2;

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Arr Date'
             THEN
               l_cto_request_rec.param7 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param8 := G_Delayed_Requests(K).param2;

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Config Chg'
             THEN
               l_cto_request_rec.param9 := 'Y';

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Warehouse'
             THEN
               l_cto_request_rec.param10 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param11 := G_Delayed_Requests(K).param2;
                         -- INVCONV
             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Quantity2'
             THEN
               l_cto_request_rec.param12 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param13 := G_Delayed_Requests(K).param2;

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Uom2'
             THEN
               l_cto_request_rec.param14 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param15 := G_Delayed_Requests(K).param2;

             ELSIF G_Delayed_Requests(K).request_unique_key1 = 'Uom'
             THEN
               l_cto_request_rec.param16 := G_Delayed_Requests(K).param1;
               l_cto_request_rec.param17 := G_Delayed_Requests(K).param2;

						-- INVCONV

             ELSIF G_Delayed_Requests(K).request_unique_key1 =
                                      'Config Chg pto_ato'
             THEN
                 IF l_debug_level > 0 THEN
                 oe_debug_pub.add('ptoato '|| G_Delayed_Requests(K).param4, 1);
                 END IF;
                 l_cto_request_tbl(K).param1 := G_Delayed_Requests(K).param4;
                 l_cto_request_tbl(K).param2 := G_Delayed_Requests(K).param5;

             ELSIF G_Delayed_Requests(K).request_unique_key1 =
                                      'Decimal Chg'
             THEN
                 IF l_debug_level > 0 THEN
                 oe_debug_pub.add('for decimal '||G_Delayed_Requests(K).entity_id, 1);
                 END IF;
                 l_cto_decimal_tbl(K) := G_Delayed_Requests(K);

             ELSIF G_Delayed_Requests(K).request_unique_key1 =
                                      'Split Create'
             THEN
                IF l_debug_level > 0 THEN
                 oe_debug_pub.add('split '|| G_Delayed_Requests(K).param4, 1);
                END IF;
                 l_cto_split_tbl(K) := G_Delayed_Requests(K);
             END IF;
             IF l_debug_level > 0 THEN
               oe_debug_pub.add(G_Delayed_Requests(K).request_unique_key1, 4);
             END IF;
             --G_Delayed_Requests.delete(K);
           END IF;

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('cto looping', 4);
           END IF;

           K := G_Delayed_Requests.NEXT(K);
         END LOOP;

         OE_CONFIG_UTIL.Notify_CTO
         ( p_ato_line_id        => l_request_rec.entity_id
         , p_request_rec        => l_cto_request_rec
         , p_request_tbl        => l_cto_request_tbl
         , p_split_tbl          => l_cto_split_tbl
         , p_decimal_tbl        => l_cto_decimal_tbl
         , x_return_status      => l_return_status);

         IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
           IF l_debug_level > 0 THEN
             oe_debug_pub.add('deleteing after success ', 3);
           END IF;
           K := G_Delayed_Requests.FIRST;

           WHILE K is not null
           LOOP
             IF G_Delayed_Requests(K).request_type =
                       OE_GLOBALS.G_CTO_CHANGE AND
                G_Delayed_Requests(K).param3 = l_request_rec.entity_id
             THEN
               G_Delayed_Requests.delete(K);
             END IF;

             K := G_Delayed_Requests.NEXT(K);

           END LOOP;
         END IF;
       ELSIF l_request_type =
                 OE_GLOBALS.G_GROUP_SET THEN


         l_index  := 0;
         K        := G_Delayed_Requests.FIRST;

         WHILE K is not null -- while loop safer than tbl.first to last
         LOOP

            IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_GROUP_SET)
            THEN

                l_index := l_index + 1;
	    	    l_sch_set_tbl(l_index) := g_delayed_requests(K);
                g_delayed_requests(K).processed := 'I';
            END IF;

            K :=  G_Delayed_Requests.NEXT(K);
         END LOOP;

         OE_GROUP_SCH_UTIL.Group_Schedule_sets
           ( p_sch_set_tbl     => l_sch_set_tbl
           , x_return_status   => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;

          K         := G_Delayed_Requests.FIRST;
          WHILE K is not null -- while loop safer than tbl.first to last
          LOOP

           IF G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_GROUP_SET
           THEN
                  g_delayed_requests(K).processed := 'Y';
           END IF;

            K :=  G_Delayed_Requests.NEXT(K);

          END LOOP;
         l_sch_set_tbl.delete;
       ELSIF l_request_type =
                 OE_GLOBALS.G_SPLIT_SCHEDULE THEN


         l_index  := 0;
         K        := G_Delayed_Requests.FIRST;

         WHILE K is not null -- while loop safer than tbl.first to last
         LOOP

            IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_SPLIT_SCHEDULE)
            THEN

                l_index := l_index + 1;
	    	    l_sch_set_tbl(l_index) := g_delayed_requests(K);
                g_delayed_requests(K).processed := 'I';
            END IF;

            K :=  G_Delayed_Requests.NEXT(K);
         END LOOP;

         OE_SCHEDULE_UTIL.Schedule_split_lines
           ( p_sch_set_tbl     => l_sch_set_tbl
           , x_return_status   => l_return_status);

         K         := G_Delayed_Requests.FIRST;
         WHILE K is not null -- while loop safer than tbl.first to last
         LOOP

           IF G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_SPLIT_SCHEDULE
           THEN
               IF l_return_status <> FND_API.G_RET_STS_UNEXP_ERROR
               THEN
                  g_delayed_requests(K).processed := 'Y';
               ELSE
                  g_delayed_requests(K).processed := Null;
               END IF;
           END IF;

            K :=  G_Delayed_Requests.NEXT(K);

         END LOOP;
         l_sch_set_tbl.delete;
       ELSIF l_request_type =
					   OE_GLOBALS.G_INSERT_SERVICE then
              OE_DELAYED_REQUESTS_UTIL.INSERT_SERVICE_FOR_OPTIONS
			  ( x_return_status    => l_return_status
			  , p_serviced_line_id => l_entity_id
			  );

       /* BUG 2013611 - Increment promotional balances in response to cancellations */
       ELSIF l_request_rec.request_type = OE_GLOBALS.G_REVERSE_LIMITS THEN
            IF l_debug_level > 0 THEN
            oe_debug_pub.add('About to PERFORM Delayed Request for Reverse Limits',1);
            END IF;

            OE_DELAYED_REQUESTS_UTIL.REVERSE_LIMITS
			  ( x_return_status           => l_return_status
                          , p_action_code             => l_request_rec.param1
                          , p_cons_price_request_code => l_request_rec.param2
                          , p_orig_ordered_qty        => to_number(l_request_rec.param3)
                          , p_amended_qty             => to_number(l_request_rec.param4)
                          , p_ret_price_request_code  => l_request_rec.param5
                          , p_returned_qty            => to_number(l_request_rec.param6)
                          , p_line_id                 => l_request_rec.entity_id
			  );
            IF l_debug_level > 0 THEN
            oe_debug_pub.add('Call Issued to OE_DELAYED_REQUESTS_UTIL.Reverse_Limits',1);
            END IF;
       /* BUG 2013611 END */

       -- Freight Rating.
       ELSIF l_request_rec.request_type = OE_GLOBALS.G_FREIGHT_RATING THEN
       IF l_debug_level > 0 THEN
	 Oe_Debug_pub.Add('Before Executing Delayed request Freight Rating for header: '||l_request_rec.entity_id, 3);
       END IF;
         OE_FTE_INTEGRATION_PVT.Process_FTE_Action
                    ( p_header_id           => l_request_rec.entity_id
                     ,p_line_id             => null
                     ,p_ui_flag             => 'N'
                     ,p_action              => 'R'
                     ,p_call_pricing_for_FR => l_request_rec.param1
                     ,x_return_status       => l_return_status
                     ,x_msg_count           => l_msg_count
                     ,x_msg_data            => l_msg_data
                     );


       ELSIF l_request_rec.request_type = OE_GLOBALS.G_PRICE_LINE THEN
       IF l_debug_level > 0 THEN
	   Oe_Debug_pub.Add('Before Executing Delayed request Price line for '||l_request_rec.entity_id);
	   Oe_Debug_pub.Add('The Event is '||l_request_rec.param2);
       END IF;
		l_Price_Control_Rec.pricing_event := l_request_rec.param2;
		l_Price_Control_Rec.calculate_flag :=  QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
		l_Price_Control_Rec.Simulation_Flag := 'N';

               --RT{
                If l_Price_Control_Rec.pricing_event IN ('BATCH','RETROBILL')
                Then
                   l_price_control_rec.source_order_amount_flag := 'Y';
                End If;
                --RT}
             IF l_debug_level > 0 THEN
			 Oe_Debug_pub.Add('Before Line Price');
             END IF;
		    	oe_order_adj_pvt.Price_line(
					X_Return_Status	=> l_Return_Status
					,p_Line_id		=> l_request_rec.entity_id
					,p_Request_Type_code=> 'ONT'
					,p_Control_rec		=> l_Price_Control_Rec
					,p_write_to_db      => TRUE
					,p_request_rec      => l_request_rec
					,x_line_Tbl         => l_Line_Tbl
					);
             IF l_debug_level > 0 THEN
	   Oe_Debug_pub.Add('After Executing Delayed request Price line for '||l_request_rec.entity_id);
             END IF;
       ELSIF l_request_rec.request_type = OE_GLOBALS.G_PRICE_ORDER THEN
         IF l_debug_level > 0 THEN
	       Oe_Debug_pub.Add('Before Executing Delayed request Price line for '||l_request_rec.entity_id);
	       Oe_Debug_pub.Add('Before Header Price');
	       Oe_Debug_pub.Add('The Event is '||l_request_rec.param2);
           Oe_Debug_pub.Add('The Action is '||l_request_rec.param3);
           Oe_Debug_pub.Add('The get freight flag is: '||l_request_rec.request_unique_key2, 3);
        END IF;
		l_Price_Control_Rec.pricing_event := l_request_rec.param2;
		l_Price_Control_Rec.calculate_flag :=  QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
		l_Price_Control_Rec.Simulation_Flag := 'N';
                l_Price_Control_Rec.get_freight_flag := nvl(l_request_rec.request_unique_key2, 'N');

                If l_Price_Control_Rec.pricing_event = 'BATCH' Then
                   l_price_control_rec.source_order_amount_flag := 'Y';
                End If;

               --Bug 2619506, Added p_action_code
		oe_order_adj_pvt.Price_line(
					X_Return_Status	=> l_Return_Status
					,p_Header_id		=> l_request_rec.entity_id
					,p_Request_Type_code=> 'ONT'
					,p_Control_rec		=> l_Price_Control_Rec
					,p_write_to_db      => TRUE
					,p_request_rec      => l_request_rec
					,x_line_Tbl         => l_Line_Tbl
                                        ,p_action_code      => l_request_rec.param3
					);
             IF l_debug_level > 0 THEN
			    Oe_Debug_pub.Add('After Header Price');
	            Oe_Debug_pub.Add('After Executing Delayed request Price line for '||l_request_rec.entity_id);
             END IF;

       /* Customer Acceptance - Start */
       ELSIF l_request_rec.request_type = OE_GLOBALS.G_DFLT_CONTINGENCY_ATTRIBUTES THEN
          IF l_debug_level > 0 THEN
	         Oe_Debug_pub.Add('Before Defaulting Contingency Attributes ');
          END IF;
	   OE_ACCEPTANCE_UTIL.Default_contingency_Attributes();
	     IF l_debug_level > 0 THEN
	       Oe_Debug_pub.Add('After Defaulting Contingency Attributes ');
         END IF;
       /* Customer Acceptance - End */

       ELSIF  (l_request_type = OE_GLOBALS.G_PROCESS_ADJUSTMENTS) then
         if l_entity_code = OE_GLOBALS.G_ENTITY_LINE then
          IF l_debug_level > 0 THEN
          oe_debug_pub.add('count is : ' || G_Delayed_Requests.count );
          END IF;
          l_prc_adj_index := G_Delayed_Requests.first;

         WHILE l_prc_adj_index is NOT NULL LOOP
                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Ren 0: Param1 :' || l_request_rec.param1);
                END IF;
                IF G_Delayed_Requests(l_prc_adj_index).request_type = l_request_type THEN
                IF l_debug_level > 0 THEN
                    oe_debug_pub.add('REN: SUCCESS - FOUND THE REQUEST');

                     oe_debug_pub.add('Ren 1: Param2 :' || g_delayed_requests(l_prc_adj_index).param2);
                END IF;

		  l_prc_adj_request(I) := g_delayed_requests(l_prc_adj_index);
                   oe_debug_pub.add('Ren 2: Param2 :' || l_prc_adj_request(I).param2);
		  g_delayed_requests.delete(l_prc_adj_index);
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('Ren 3: Param2 :' || l_prc_adj_request(I).param2);
          END IF;
                  I := I + 1;

                ELSE
                    IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Ren: Req not found ' || l_prc_adj_index);
                    END IF;

                END IF;

	   l_prc_adj_index := G_Delayed_Requests.Next(l_prc_adj_index);

          END LOOP;

             IF l_prc_adj_request.count > 0 THEN
                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('before calling process_adjustments ');
                END IF;

               OE_DELAYED_REQUESTS_UTIL.Process_Adjustments
			(p_adjust_tbl	     => l_prc_adj_request,
			 x_return_status     => l_return_status);

             END IF; /* if count > 0 */

         end if; /* entity_code = G_ENTITY_LINE */

	  -- Delayed Request to Apply Automatic Attachments
       ELSIF  l_request_type = OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT THEN

               OE_DELAYED_REQUESTS_UTIL.Apply_Automatic_Attachments
					( p_entity_code 		=> l_request_rec.entity_code
					, p_entity_id 			=> l_request_rec.entity_id
					, p_is_user_action		=> 'N'
					, x_return_status		=> l_return_status
					);

       ELSIF  l_request_type = OE_GLOBALS.G_COPY_ATCHMT THEN

               OE_DELAYED_REQUESTS_UTIL.Copy_Attachments
                    (p_entity_code             => l_request_rec.entity_code
                    ,p_from_entity_id          =>
                                            to_number(l_request_rec.param1)
                    ,p_to_entity_id            => l_request_rec.entity_id
                    ,p_manual_attachments_only => l_request_rec.param2
                    ,x_return_status           => l_return_status
                    );

       ELSIF  l_request_type = OE_GLOBALS.G_COPY_ADJUSTMENTS THEN

			OE_Line_Adj_Util.copy_adjustment_lines
                    (p_from_line_id        => to_number(l_request_rec.param2)
                     ,p_to_line_id         => l_request_rec.entity_id
                     ,p_from_Header_id     => to_number(l_request_rec.param3)
                     ,p_to_Header_id       => to_number(l_request_rec.param1)
                     ,p_line_category_code => l_request_rec.param4
                     ,p_split_by           => l_request_rec.param5
                     ,p_booked_flag        => l_request_rec.param6
                     --RT{
                     ,p_mode               => l_request_rec.param7
                     ,p_retrobill_request_id=>l_request_rec.param8
                     --RT}
                     ,x_return_status      => l_return_status
                     );
       /* Added for Bug # 1559906 */
       ELSIF  l_request_type = OE_GLOBALS.G_COPY_FREIGHT_CHARGES THEN

              OE_Header_Adj_Util.copy_freight_charges
                    ( p_from_header_id    => to_number(l_request_rec.param2)
                    , p_to_header_id      => l_request_rec.entity_id
                    , p_to_order_category => l_request_rec.param1
                    , x_return_status     => l_return_status
                    );


       /* Added the new delayed req for Bug # 2170086 */
       ELSIF  l_request_type = OE_GLOBALS.G_COPY_HEADER_ADJUSTMENTS THEN

              OE_Header_Adj_Util.copy_header_adjustments
                    ( p_from_header_id    => to_number(l_request_rec.param2)
                    , p_to_header_id      => l_request_rec.entity_id
                    , p_to_order_category => l_request_rec.param1
                    , x_return_status     => l_return_status
                    );



 /* csheu added for bug #1533658 */

       ELSIF  l_request_type = OE_GLOBALS.G_UPDATE_SERVICE THEN
           IF l_debug_level > 0 THEN
              oe_debug_pub.add('CSH-- Before calls OE_Service_Util.cascade_changes', 1);
           END IF;

	 OE_Service_Util.cascade_changes
                    ( p_parent_line_id   => l_request_rec.entity_id
                     ,p_request_rec      => l_request_rec
                     ,x_return_status    => l_return_status
                     );
        IF l_debug_level > 0 THEN
        oe_debug_pub.add('CSH-- After calls OE_Service_Util.cascade_changes', 1);
        END IF;

  /* lchen added for bug #1761154 */

       ELSIF l_request_type = OE_GLOBALS.G_CASCADE_OPTIONS_SERVICE then
       IF l_debug_level > 0 THEN
      oe_debug_pub.add('lchen-- Before calls OE_DELAYED_REQUESTS_UTIL.CASCADE_SERVICE_FOR_OPTIONS', 1);
       END IF;
       OE_DELAYED_REQUESTS_UTIL.CASCADE_SERVICE_FOR_OPTIONS
			  ( x_return_status    => l_return_status
			  , p_option_line_id => l_entity_id
			  );
      IF l_debug_level > 0 THEN
      oe_debug_pub.add('lchen-- After calls OE_DELAYED_REQUESTS_UTIL.CASCADE_SERVICE_FOR_OPTIONS', 1);
      END IF;

       -- added by lkxu: to copy pricing attributes
       ELSIF  l_request_type = OE_GLOBALS.G_COPY_PRICING_ATTRIBUTES THEN

			OE_Line_PAttr_Util.copy_pricing_attributes
                    (p_from_line_id        => to_number(l_request_rec.param2)
                     ,p_to_line_id         => l_request_rec.entity_id
                     ,p_to_Header_id       => to_number(l_request_rec.param1)
                     ,x_return_status      => l_return_status
                     );

       ELSIF  l_request_type = OE_GLOBALS.G_COPY_MODEL_PATTR THEN

	/* bug 1857538
           copy_model_pattr now takes only the line_id as parameter
	   Corresponding changes are in OEXULPAS and OEXULPAB
	*/
			OE_Line_PAttr_Util.copy_model_pattr
                    (
		     --p_model_line_id       => l_request_rec.entity_id
                      p_to_line_id         => to_number(l_request_rec.param1)
                     ,x_return_status      => l_return_status
                     );

        ELSIF l_request_type = OE_GLOBALS.G_DELETE_CHARGES THEN
          OE_Header_Util.cancel_header_charges
                     (
                      p_header_id       => l_request_rec.entity_id,
                      --p_x_line_id         => to_number(l_request_rec.param1),
                      x_return_status      => l_return_status
                     );

       ELSIF l_request_type = OE_GLOBALS.G_CASCADE_SCH_ATTRBS THEN

          G_Delayed_Requests(p_request_ind).processed := 'Y';

      ELSIF l_request_type =
                        OE_GLOBALS.G_CASCADE_SHIP_SET_ATTR then

         l_index  := 0;
         l_set_id    := l_request_rec.param2;

         K         := G_Delayed_Requests.FIRST;

         WHILE K is not null
         LOOP

            IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_CASCADE_SHIP_SET_ATTR) AND
                G_Delayed_Requests(K).param2 = l_set_id AND
                K <> p_request_ind
            THEN

                g_delayed_requests.delete(K);

            END IF;

            K :=  G_Delayed_Requests.NEXT(K);

         END LOOP;

        OE_SCHEDULE_UTIL.Cascade_ship_set_attr
               ( p_request_rec      => l_request_rec
               , x_return_status    => l_return_status);

       ELSIF l_request_type =
                        OE_GLOBALS.G_GROUP_SCHEDULE then

         l_index  := 0;
         l_set_id    := l_request_rec.param1;

         K         := G_Delayed_Requests.FIRST;

         WHILE K is not null
         LOOP

            IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_GROUP_SCHEDULE) AND
                G_Delayed_Requests(K).param1 = l_set_id AND
                K <> p_request_ind
            THEN

                l_index := l_index + 1;

                IF nvl(g_delayed_requests(K).param12,'N') = 'Y' THEN
                   l_request_rec.param12 := 'Y';
                END IF;

                g_delayed_requests.delete(K);

            END IF;

            K :=  G_Delayed_Requests.NEXT(K);

         END LOOP;

         -- Removed the below code -Bug4504362
            -- Start 2391781
            -- Storing Cascade Warehouse records
            l_set_id := l_request_rec.param1;
            l_count := G_Delayed_Requests.FIRST;
            WHILE l_count is not null
            LOOP

               IF G_Delayed_Requests(l_count).request_type =
                                      OE_GLOBALS.G_CASCADE_SCH_ATTRBS AND
                  G_Delayed_Requests(l_count).param1 = l_set_id
               THEN
                   /* Modified below code for bug 8636027 */

                  l_mod_entity_id := mod(G_Delayed_Requests(l_count).entity_id, G_BINARY_LIMIT); -- Bug 8636027

                 /* commenetd for bug 9885436

                  oe_schedule_util.OE_sch_Attrb_Tbl
                   (G_Delayed_Requests(l_mod_entity_id).entity_id).set_id :=
                                    G_Delayed_Requests(l_count).param1;
                  oe_schedule_util.OE_sch_Attrb_Tbl
                   (G_Delayed_Requests(l_mod_entity_id).entity_id).line_id :=
                                     G_Delayed_Requests(l_count).entity_id;
                  oe_schedule_util.OE_sch_Attrb_Tbl
                   (G_Delayed_Requests(l_mod_entity_id).entity_id).attribute1 :=
                       G_Delayed_Requests(l_count).param2;
                  oe_schedule_util.OE_sch_Attrb_Tbl
                   (G_Delayed_Requests(l_mod_entity_id).entity_id).date_attribute1 :=
                                G_Delayed_Requests(l_count).date_param1;
                   */

                  /* End of bug 8636027 */
                  --End of 9885436

                  --Added below code for 9885436
                oe_schedule_util.OE_sch_Attrb_Tbl(l_mod_entity_id).set_id :=
		                G_Delayed_Requests(l_count).param1;
                oe_schedule_util.OE_sch_Attrb_Tbl(l_mod_entity_id).line_id:=
                                G_Delayed_Requests(l_count).entity_id;
                oe_schedule_util.OE_sch_Attrb_Tbl(l_mod_entity_id).attribute1 :=
                                G_Delayed_Requests(l_count).param2;
                oe_schedule_util.OE_sch_Attrb_Tbl(l_mod_entity_id).date_attribute1:=
                                G_Delayed_Requests(l_count).date_param1;
                  --End of 9885436
                  g_delayed_requests.delete(l_count);
               END IF;

               l_count :=  G_Delayed_Requests.NEXT(l_count);

           END LOOP;
           -- End 2391781

           OE_GROUP_SCH_UTIL.Schedule_Set
               ( p_request_rec      => l_request_rec
               , x_return_status    => l_return_status);

         IF l_debug_level > 0 THEN
         oe_debug_pub.add('Group Schedule Return Status ' || l_return_status,1);
	 END IF;
         --11825106
         IF nvl(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS'),'Y') = 'N'
            AND l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- Ignore Scheduling Failure
           l_return_status := FND_API.G_RET_STS_SUCCESS;
           oe_schedule_util.OESCH_SET_SCHEDULING := 'N';
         ELSE
           oe_schedule_util.OESCH_SET_SCHEDULING := 'Y';
         END IF;
       -- 4026758
       ELSIF l_request_type =
                        OE_GLOBALS.G_DELETE_SET THEN
          l_set_id := l_request_rec.param1;

          K := G_Delayed_Requests.FIRST;

          WHILE K is not null
          LOOP

             IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_DELETE_SET)
               AND G_Delayed_Requests(K).param1 = l_set_id
               AND K <> p_request_ind THEN

                g_delayed_requests.delete(K);

             END IF;

             K :=  G_Delayed_Requests.NEXT(K);

          END LOOP;

          oe_set_util.Delete_Set(p_request_rec      => l_request_rec
                               , x_return_status    => l_return_status);
          oe_debug_pub.add('Delete Set Return Status ' || l_return_status,1);
       ELSIF (l_request_type =
                        OE_GLOBALS.G_SCHEDULE_LINE OR
              l_request_type =
                        OE_GLOBALS.G_RESCHEDULE_LINE) then

         l_index  := 0;
         l_set    := l_request_rec.param1;

         K        := G_Delayed_Requests.FIRST;

         WHILE K is not null -- while loop safer than tbl.first to last
         LOOP

            IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_SCHEDULE_LINE OR
                G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_RESCHEDULE_LINE) AND
                G_Delayed_Requests(K).param1 = l_set
            THEN

                l_index := l_index + 1;
	    	l_sch_set_tbl(l_index) := g_delayed_requests(K);
                g_delayed_requests(K).processed := 'I';
            END IF;

            K :=  G_Delayed_Requests.NEXT(K);
         END LOOP;
         IF l_debug_level > 0 THEN
         oe_debug_pub.add('Calling Sch_Line with '|| l_sch_set_tbl.count,1);
         END IF;

         -- Commented out the below code -Bug4504362
             OE_GROUP_SCH_UTIL.Schedule_Set_lines
               ( p_sch_set_tbl     => l_sch_set_tbl
               , x_return_status   => l_return_status);


         IF l_debug_level > 0 THEN
         oe_debug_pub.add('After Calling Sch_Line: '|| l_return_status,1);
         END IF;

         -- If Schedule_Line is success for all the lines, mark
         -- the request for others lines as processed.

         K         := G_Delayed_Requests.FIRST;
         WHILE K is not null -- while loop safer than tbl.first to last
         LOOP

           IF (G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_SCHEDULE_LINE OR
               G_Delayed_Requests(K).request_type =
                           OE_GLOBALS.G_RESCHEDULE_LINE) AND
                G_Delayed_Requests(K).param1 = l_set
           THEN
                l_index := l_index + 1;
               IF l_return_status <> FND_API.G_RET_STS_UNEXP_ERROR
               THEN
                  g_delayed_requests(K).processed := 'Y';
               ELSE
                  g_delayed_requests(K).processed := Null;
               END IF;
           END IF;

            K :=  G_Delayed_Requests.NEXT(K);

         END LOOP;

       -- bug 1829201, commitment related changes.
       ELSIF  l_request_type = OE_GLOBALS.G_CALCULATE_COMMITMENT THEN
        IF l_debug_level > 0 THEN
	    oe_debug_pub.add('Calling procedure calculate_commtment!',1);
        END IF;

                     --bug 3560198
			OE_Commitment_Pvt.calculate_commitment(
                            p_request_rec        => l_request_rec
                           ,x_return_status      => l_return_status
                          );

       ELSIF  l_request_type = OE_GLOBALS.G_UPDATE_COMMITMENT THEN

			OE_Commitment_Pvt.update_commitment
                          ( p_line_id       => l_request_rec.entity_id
                           ,x_return_status => l_return_status
                          );
       -- multiple payments
       ELSIF  l_request_type = OE_GLOBALS.G_UPDATE_COMMITMENT_APPLIED THEN
         IF l_debug_level > 0 THEN
         oe_debug_pub.add('OEXVREQB param1 is: '||l_request_rec.param1,3);
         oe_debug_pub.add('OEXVREQB param2 is: '||l_request_rec.param2,3);
         oe_debug_pub.add('OEXVREQB param3 is: '||l_request_rec.param3,3);
         END IF;
			OE_Commitment_Pvt.update_commitment_applied
                          ( p_line_id       => l_request_rec.entity_id
                           ,p_amount	    => l_request_rec.param1
                           ,p_header_id     => l_request_rec.param2
                           ,p_commitment_id => l_request_rec.param3
                           ,x_return_status => l_return_status
                          );

       -- Included for the Spares Management (ikon) project  mshenoy
       -- For the delayed request type of Create Internal Req call the procedure
      ELSIF  l_request_type = OE_GLOBALS.G_CREATE_INTERNAL_REQ THEN
         IF l_debug_level > 0 THEN
	     oe_debug_pub.add(' Calling auto_create_internal_req hdr id '|| l_entity_id,1);
         END IF;
             OE_DELAYED_REQUESTS_UTIL.auto_create_internal_req
                     ( p_ord_header_id     => l_entity_id
                      ,x_return_status   => l_return_status);
           IF l_debug_level > 0 THEN
         oe_debug_pub.add('After Calling auto_create_internal_req ret_status : '|| l_return_status,1);
           END IF;

/* Modified the following condition to fix the bug 6663462 */

       ELSIF l_request_type = OE_GLOBALS.G_SCHEDULE_ATO OR
             l_request_type = OE_GLOBALS.G_SCHEDULE_SMC OR
             l_request_type = OE_GLOBALS.G_SCHEDULE_NONSMC  OR
             l_request_type = OE_GLOBALS.G_DELAYED_SCHEDULE THEN
         IF l_debug_level > 0 THEN
         oe_debug_pub.add('calling Process_Scheduling_Request');
         END IF;
         Process_Scheduling_Request
         ( p_request_ind   => p_request_ind
          ,p_request_rec   => l_request_rec
          ,x_return_status => l_return_status);
         IF l_debug_level > 0 THEN
         oe_debug_pub.add('Scheduling_Request '|| l_return_status);
         END IF;
       ---------
       -- Added by rsreeniv
       ----------
      ELSIF l_request_rec.request_type = OE_GLOBALS.G_FREIGHT_FOR_INCLUDED THEN
        IF l_debug_level > 0 THEN
             Oe_Debug_pub.Add('Before Executing Delayed request Freight for included for '||l_request_rec.entity_id);
			 Oe_Debug_pub.Add('Before Order Price - Freight');
	         Oe_Debug_pub.Add('The Event is '||l_request_rec.param2);
        END IF;
		l_Price_Control_Rec.pricing_event := l_request_rec.param2;
		l_Price_Control_Rec.calculate_flag :=  QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
		l_Price_Control_Rec.Simulation_Flag := 'N';

                If l_Price_Control_Rec.pricing_event = 'BATCH' Then
                   l_price_control_rec.source_order_amount_flag := 'Y';
                End If;

                j := 1;

             /*

              FOR inclinesrec in included_lines_cur(l_request_rec.entity_id) LOOP

                 IF OE_LINE_ADJ_UTIL.G_CHANGED_LINE_TBL.exists(inclinesrec.line_id) THEN

                 l_line_tbl(j) := OE_LINE_UTIL.QUERY_ROW(p_line_id => inclinesrec.line_id);

                 END IF;

                 j := j + 1;

              END LOOP; */


		oe_order_adj_pvt.Price_line(
					X_Return_Status	=> l_Return_Status
					,p_Request_Type_code=> 'ONT'
					,p_Control_rec		=> l_Price_Control_Rec
                                        ,p_Header_id            => l_request_rec.entity_id
					,p_write_to_db      => TRUE
					,p_request_rec      => l_request_rec
					,x_line_Tbl         => l_Line_Tbl
					);
        IF l_debug_level > 0 THEN
			 Oe_Debug_pub.Add('After Header Price');
	         Oe_Debug_pub.Add('After Executing Delayed request Price line for '||l_request_rec.entity_id);
        END IF;
       --MRG BGN
      ELSIF l_request_type = OE_GLOBALS.G_MARGIN_HOLD THEN
         IF l_debug_level > 0 THEN
         oe_debug_pub.add('From delayed request: executing Oe_Margin_Pvt.Margin_Hold');
         END IF;
         Oe_Margin_Pvt.Margin_Hold(p_header_id => l_request_rec.entity_id);
       --MRG END
       -------------
       --Added btea
       -------------


       --MRG BGN
       ELSIF l_request_type = OE_GLOBALS.G_GET_COST THEN
          IF l_debug_level > 0 THEN
         oe_debug_pub.add('From delayed request: executing Oe_Margin_Pvt.Get_Cost');
          END IF;
         l_unit_cost := Oe_Margin_Pvt.Get_Cost(p_request_rec => l_request_rec);
       --MRG END


       ELSIF l_request_type = OE_GLOBALS.G_DEL_CHG_LINES Then
           IF l_debug_level > 0 THEN
          oe_debug_pub.add('Executing Delete_Changed_Lines delayed request');
           END IF;

          Oe_Line_Adj_Util.Delete_Changed_Lines_Tbl;
          IF l_debug_level > 0 THEN
          oe_debug_pub.add('After Delete_Changed_Lines delayed request');
          END IF;

       ELSIF l_request_type = OE_GLOBALS.G_VERSION_AUDIT THEN

          OE_Versioning_Util.Execute_Versioning_Request(p_header_id => l_request_rec.entity_id,
        p_document_type => l_request_rec.entity_code,
        p_changed_attribute => l_request_rec.param1,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_return_status => x_return_status);

       -- BLANKETS: Ignore process release related requests here. These
       -- will be executed with all requests in process_delayed_requests call.
       ELSIF l_request_type = OE_GLOBALS.G_PROCESS_RELEASE THEN
         RETURN;
       ELSIF l_request_type = OE_GLOBALS.G_VALIDATE_RELEASE_SHIPMENTS THEN
         RETURN;

       -- Delayed requests logged by blankets business object APIs.
       ELSIF l_request_type = 'VALIDATE_BLANKET_LINE_NUMBER' THEN
          OE_BLANKET_UTIL.VALIDATE_LINE_NUMBER( p_req_ind => p_request_ind,
                            x_return_status => l_return_status);

       ELSIF l_request_type = 'VALIDATE_BLANKET_INV_ITEM' THEN
          OE_BLANKET_UTIL.VALIDATE_ITEM_UNIQUENESS( p_req_ind => p_request_ind,
                            x_return_status => l_return_status);
       ELSIF l_request_type = 'CREATE_BLANKET_PRICE_LIST' THEN
          OE_BLANKET_UTIL.create_price_list( p_index => p_request_ind,
                            x_return_status => l_return_status);
       ELSIF l_request_type = 'ADD_BLANKET_PRICE_LIST_LINE' THEN
          OE_BLANKET_UTIL.add_price_list_line( p_req_ind => p_request_ind,
                            x_return_status => l_return_status);
       -- for bug 3309427
       ELSIF l_request_type = OE_GLOBALS.G_CLEAR_BLKT_PRICE_LIST_LINE THEN
          OE_BLANKET_UTIL.clear_price_list_line( p_req_ind => p_request_ind,
                            x_return_status => l_return_status);
       ELSIF l_request_type = 'RECORD_BLANKET_HISTORY' THEN
          OE_BLANKET_UTIL.record_blanket_history(
                            x_return_status => l_return_status);
       ELSIF l_request_type = 'VALIDATE_BLANKET_SOLD_TO' THEN
          OE_BLANKET_UTIL.validate_sold_to( p_header_id => l_entity_id,
                            p_sold_To_org_id => l_request_rec.param1,
                            x_return_status => l_return_status);
       -- End of requests logged by blankets business object APIs.
       -- Begin of Multiple Payments
       	ELSIF l_request_type = OE_GLOBALS.G_SPLIT_PAYMENT then
	    OE_PrePayment_Pvt.split_payment (
	                    p_line_id               	  => l_request_rec.entity_id
	                  , p_header_id               	  => l_request_rec.param2
	                  , p_split_from_line_id  	  => l_request_rec.param1
	                  , x_return_status        	 => l_return_status
	                  , x_msg_count           	  => l_msg_count
	                  , x_msg_data             	 => l_msg_data
	                  );
       -- End of Multiple Payments

       -- OIP SUN ER Changes
              ELSIF l_request_type = 'OE_ORDER_BOOKED' then
                 OE_ORDER_UTIL.RAISE_BUSINESS_EVENT(p_header_id => l_entity_id,
       	   	    	                            p_status    => 'BOOKED');
       -- OIP SUN ER Changes End

       ELSIF l_request_type = OE_GLOBALS.G_UPDATE_HDR_PAYMENT then

         IF l_debug_level > 0 THEN
           oe_debug_pub.add('param1 is : ' || l_request_rec.param1);
           oe_debug_pub.add('param2 is : ' || l_request_rec.param2);
           oe_debug_pub.add('entity id is : ' || l_request_rec.entity_id);
           oe_debug_pub.add('entity code is : ' || l_request_rec.entity_code);
         END IF;

            IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT
            AND l_request_rec.param1 = 'UPDATE_LINE' THEN
               payment_line_id := l_request_rec.entity_id;
               payment_header_id := l_request_rec.param2;

            ELSE
               payment_header_id := l_request_rec.entity_id;
               payment_line_id := NULL;
            END IF;

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('header id for update_hdr_payment is : ' || payment_header_id,3);
              oe_debug_pub.add('line id for update_hdr_payment is : ' || payment_line_id,3);
            END IF;

	    OE_PrePayment_Pvt.Update_Hdr_Payment (
	                    p_header_id             => payment_header_id
                          , p_action                => l_request_rec.param1
                          , p_line_id               => payment_line_id
	                  , x_return_status         => l_return_status
	                  , x_msg_count             => l_msg_count
	                  , x_msg_data              => l_msg_data
	                  );

       ELSIF l_request_type = OE_GLOBALS.G_APPLY_PPP_HOLD  THEN
	    --bug3507871 start
        IF l_debug_level > 0 THEN
	    oe_debug_pub.add('Before calling Process_Payments for applying PPP hold');
        END IF;

	    OE_PREPAYMENT_PVT.Process_Payments(
             	       p_header_id 	=> l_request_rec.entity_id,
                       p_calling_action => 'UPDATE',
                       p_amount         => null,
                       p_delayed_request=> FND_API.G_TRUE,
                       x_msg_data	=> l_msg_data,
                       x_msg_count	=> l_msg_count,
                       x_return_status	=> l_return_status);
	    --bug3507871 end
--bug3625027 start
      ELSIF l_request_type = OE_GLOBALS.G_PROCESS_PAYMENT THEN
        IF l_debug_level > 0 THEN
	    oe_debug_pub.add('Request Type: '||l_request_type);
        END IF;
	 IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_HEADER_PAYMENT THEN
        IF l_debug_level > 0 THEN
	       oe_debug_pub.add('Before calling Process_Payments Procedure at the header level');
        END IF;

	    OE_PREPAYMENT_PVT.Process_Payments(
             	       p_header_id 	=> l_request_rec.entity_id,
                       p_calling_action => null,
                       p_amount         => null,
                       p_delayed_request=> FND_API.G_TRUE,
		       p_process_prepayment=>'N',
	               p_process_authorization=>'N',
                       x_msg_data	=> l_msg_data,
                       x_msg_count	=> l_msg_count,
                       x_return_status	=> l_return_status);
	 ELSIF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT THEN
        IF l_debug_level > 0 THEN
	    oe_debug_pub.add('Before calling Process_Payments Procedure at the line level');
        END IF;

	    OE_PREPAYMENT_PVT.Process_Payments(
             	       p_header_id 	=> l_request_rec.entity_id,
		       p_line_id        => l_request_rec.param1,
                       p_calling_action => null,
                       p_amount         => null,
                       p_delayed_request=> FND_API.G_TRUE,
		       p_process_prepayment=>'N',
	               p_process_authorization=>'N',
		       x_msg_data	=> l_msg_data,
                       x_msg_count	=> l_msg_count,
                       x_return_status	=> l_return_status);
	END IF;
--bug3625027 end

       ELSIF l_request_type = OE_GLOBALS.G_DELETE_PAYMENT_HOLD  THEN
         IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT THEN
            payment_line_id := l_request_rec.entity_id;
            payment_header_id := l_request_rec.param2;
         ELSE
            payment_header_id := l_request_rec.entity_id;
            payment_line_id := NULL;
         END IF;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('header id for delete_payment_hold is : ' || payment_header_id,3);
           oe_debug_pub.add('line id for delete_payment_hold is : ' || payment_line_id,3);
         END IF;

	 OE_PrePayment_Pvt.Delete_Payment_Hold
                          ( p_line_id          	  => payment_line_id
	                  , p_header_id           => payment_header_id
	                  , p_hold_type           => l_request_rec.param1
	                  , x_return_status       => l_return_status
	                  , x_msg_count           => l_msg_count
	                  , x_msg_data            => l_msg_data
	                  );

       -- End of Multiple Payments

       -- 11i10 Work Flow Changes
       ELSIF l_request_type = 'BLANKET_DATE_CHANGE' THEN
          OE_BLANKET_WF_UTIL.Blanket_Date_Changed(p_header_id => l_entity_id,
                                                  x_return_status => l_return_status);
        -- End of Work Flow Changes.
       -- 11i10 Pricing Changes for blankets
       ELSIF l_request_type IN ('CREATE_MODIFIER_LIST'
                               ,'ADD_MODIFIER_LIST_LINE'
                               )
       THEN
          OE_BLANKET_PRICING_UTIL.Create_Modifiers(
                            p_index         => p_request_ind,
                            x_return_status => l_return_status);

       ELSIF l_request_type IN (OE_GLOBALS.G_GENERATE_XML_REQ_HDR, OE_GLOBALS.G_GENERATE_XML_REQ_LN) THEN
        -- only do processing on header-level requests

        IF l_request_type = OE_GLOBALS.G_GENERATE_XML_REQ_HDR THEN
        OE_DELAYED_REQUESTS_UTIL.process_xml_delayed_request(p_request_ind => p_request_ind,
                                                               x_return_status  => l_return_status);
        END IF;
	--R12 CC Encryption
	ELSIF l_request_type = OE_GLOBALS.G_DELETE_PAYMENTS  THEN
		IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT THEN
			payment_line_id := l_request_rec.entity_id;
			payment_header_id := l_request_rec.param1;
			old_invoice_to_org_id := to_number(l_request_rec.param2);
		ELSE
			payment_header_id := l_request_rec.entity_id;
			payment_line_id := NULL;
			old_invoice_to_org_id := to_number(l_request_rec.param1);
		END IF;

                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('header id for delete_payments is : ' || payment_header_id,3);
                  oe_debug_pub.add('line id for delete_payments is : ' || payment_line_id,3);
                END IF;

		OE_PrePayment_Pvt.Delete_Payments
		 ( p_line_id             => payment_line_id
		, p_header_id           => payment_header_id
		, p_invoice_to_org_id	=> old_invoice_to_org_id
		, x_return_status       => l_return_status
                , x_msg_count           => l_msg_count
		, x_msg_data            => l_msg_data
		);
       --R12 CC Encryption
       -- End of requests logged by blankets business object APIs.

       --BUG#10052614 Starts
       ELSIF l_request_type = OE_GLOBALS.G_DR_COPY_OTM_RECORDS  THEN
       	/*   Modified below call to dynamic SQL to avoid dependency on OTM
         *   patch, since OTM patch mandates a pre-req of R12 RUP6.
       	     l_otm_volume := OZF_VOLUME_CALCULATION_PUB.copy_order_group_details( p_to_order_line_id    => l_entity_id
	                                                                                , p_from_order_line_id  => l_request_rec.param2
                                                                           );
       */
        oe_debug_pub.add(' OEXVREQB.pls : Building dynamic call string for calling OZF_VOLUME_CALCULATION_PUB.copy_order_group_details', 3);
	l_dynamic_call := 'declare ' ||
			  'begin ' ||
			  ':return_value := OZF_VOLUME_CALCULATION_PUB.copy_order_group_details' ||
			  		    '( p_to_order_line_id => :l_to_order_line_id, ' ||
			                     ' p_from_order_line_id  => :l_from_order_line_id ); ' ||
			  'end;';
        oe_debug_pub.add(' OEXVREQB.pls : dynamics sql : ' || l_dynamic_call, 3);

        Begin
	EXECUTE IMMEDIATE l_dynamic_call USING OUT l_otm_volume, IN l_entity_id, IN l_request_rec.param2;

             oe_debug_pub.add('Return from OTM after executing delayed request : ' || l_otm_volume,3);

        Exception When OTHERS Then
           oe_debug_pub.add('Erroring calling OTM API, please check if the dependent OTM patch is applied and if OZF_VOLUME_CALCULATION_PUB.copy_order_group_details API existis in the DB', 1);
        End;
       --BUG#10052614 Ends

       ELSE
            FND_MESSAGE.SET_NAME('ONT','ONT_INVALID_REQUEST');
		  FND_MESSAGE.SET_TOKEN('ACTION',l_request_type);
            OE_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (p_delete = FND_API.G_TRUE) then

             G_Delayed_Requests.Delete(p_request_ind);

/*
       BUG 1794544 - do not delete from req entities table
       , delete table in the end when all requests are processed
       This to improve performance as this search loops through
       the entire pl/sql table which becomes very large with
       greater number of lines being processed
	-- Delete all the records in the requesting entities table
	-- that have this request.

	l_req_entity_ind := G_Requesting_Entities.First;


          WHILE l_req_entity_ind IS NOT NULL LOOP
	   IF G_Requesting_Entities(l_req_entity_ind).request_index = p_request_ind
	   THEN
		G_Requesting_Entities.Delete(l_req_entity_ind);
	   END IF;
	   l_req_entity_ind := G_Requesting_Entities.Next(l_req_entity_ind);
	  END LOOP;
*/

       ELSE

          G_Delayed_Requests(p_request_ind).processed := 'Y';

       END IF;

/*       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;*/
/* The request  is not removed if return_status is error  Rajeev*/
       --IF (p_delete = FND_API.G_TRUE) then
        --  G_Delayed_Requests.Delete(p_request_ind);
       --ELSE
        --  G_Delayed_Requests(p_request_ind).processed := 'Y';
       --END IF;
       IF l_debug_level > 0 THEN
           oe_debug_pub.add('leaving Process_Request_Pvt', 1);
       END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
           oe_debug_pub.add('exe error Process_Request_Pvt', 1);
/* commented the fowwoing 2 debug messages to fix the bug 13256519  */
/*
           oe_debug_pub.add
           ('1 type----- '|| G_Delayed_Requests(p_request_ind).request_type, 1);
           oe_debug_pub.add
           ('1 ind----- '|| p_request_ind, 1);
*/
  --	13637782: Delete only if request exists.
		IF (p_delete = FND_API.G_TRUE)
                  AND G_Delayed_Requests.EXISTS(p_request_ind) THEN --	13637782
    		-- Bug 11811300 starts
    		IF G_Delayed_Requests(p_request_ind).request_type IN
    		(OE_GLOBALS.G_SCHEDULE_LINE,OE_GLOBALS.G_GROUP_SCHEDULE,OE_GLOBALS.G_SCHEDULE_ATO,OE_GLOBALS.G_SCHEDULE_SMC,OE_GLOBALS.G_SCHEDULE_NONSMC,OE_GLOBALS.G_DELAYED_SCHEDULE)
    		-- Bug 11811300 ends
		THEN -- 9714072
            		G_Delayed_Requests.Delete(p_request_ind);
            	ELSE -- 9714072
	  		G_Delayed_Requests(p_request_ind).processed := 'N';
	  	END IF ; -- 9714072
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           oe_debug_pub.add('unexp error Process_Request_Pvt', 1);
           oe_debug_pub.add('SQL ERROR MESSAGE:'||SQLERRM);

		IF (p_delete = FND_API.G_TRUE)
                  AND G_Delayed_Requests.EXISTS(p_request_ind) THEN --	13637782
    		-- Bug 11811300 starts
		IF G_Delayed_Requests(p_request_ind).request_type IN
    		(OE_GLOBALS.G_SCHEDULE_LINE,OE_GLOBALS.G_GROUP_SCHEDULE,OE_GLOBALS.G_SCHEDULE_ATO,OE_GLOBALS.G_SCHEDULE_SMC,OE_GLOBALS.G_SCHEDULE_NONSMC,OE_GLOBALS.G_DELAYED_SCHEDULE)
    		-- Bug 11811300 ends
		THEN -- 9714072
            		G_Delayed_Requests.Delete(p_request_ind);
            	ELSE -- 9714072
	  		G_Delayed_Requests(p_request_ind).processed := 'N';
	  	END IF ; -- 9714072
                END IF;
	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN NO_DATA_FOUND THEN
        oe_debug_pub.add('Exiting  Process_Request_Pvt no_data_found exception ');
		IF (p_delete = FND_API.G_TRUE)
                 AND G_Delayed_Requests.EXISTS(p_request_ind) THEN --	13637782
                -- Bug 11811300 starts
                IF  G_Delayed_Requests(p_request_ind).request_type IN
                (OE_GLOBALS.G_SCHEDULE_LINE,OE_GLOBALS.G_GROUP_SCHEDULE,OE_GLOBALS.G_SCHEDULE_ATO,OE_GLOBALS.G_SCHEDULE_SMC,OE_GLOBALS.G_SCHEDULE_NONSMC,OE_GLOBALS.G_DELAYED_SCHEDULE)
                -- Bug 11811300 ends
		THEN -- 9714072
            		G_Delayed_Requests.Delete(p_request_ind);
            	ELSE -- 9714072
	  		G_Delayed_Requests(p_request_ind).processed := 'N';
	  	END IF ; -- 9714072
                END IF;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_Pvt'
            );
        END IF;

    WHEN OTHERS THEN
	oe_debug_pub.add('SQL ERROR MESSAGE FOR WHEN OTHRES:'||SQLERRM);
		IF (p_delete = FND_API.G_TRUE)
                  AND G_Delayed_Requests.EXISTS(p_request_ind) THEN --	13637782
    		-- Bug 11811300 starts
    		IF G_Delayed_Requests(p_request_ind).request_type IN
    		(OE_GLOBALS.G_SCHEDULE_LINE,OE_GLOBALS.G_GROUP_SCHEDULE,OE_GLOBALS.G_SCHEDULE_ATO,OE_GLOBALS.G_SCHEDULE_SMC,OE_GLOBALS.G_SCHEDULE_NONSMC,OE_GLOBALS.G_DELAYED_SCHEDULE)
    		-- Bug 11811300 ends
		THEN -- 9714072
            		G_Delayed_Requests.Delete(p_request_ind);
            	ELSE -- 9714072
	  		G_Delayed_Requests(p_request_ind).processed := 'N';
	  	END IF ; -- 9714072
                END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_Pvt'
            );
        END IF;

   oe_debug_pub.add('Exiting  Process_Request_Pvt with others exception ');


End Process_Request_Pvt;

/** End Local Procedures **/

/** Global Procedures **/
Procedure  Log_Request
(   p_entity_code	IN VARCHAR2
,   p_entity_id		IN NUMBER
,   p_requesting_entity_code IN VARCHAR2
,   p_requesting_entity_id   IN NUMBER
,   p_request_type	IN VARCHAR2
,   p_request_unique_key1	IN VARCHAR2 := NULL
,   p_request_unique_key2	IN VARCHAR2 := NULL
,   p_request_unique_key3	IN VARCHAR2 := NULL
,   p_request_unique_key4	IN VARCHAR2 := NULL
,   p_request_unique_key5	IN VARCHAR2 := NULL
,   p_param1		IN VARCHAR2 := NULL
,   p_param2		IN VARCHAR2 := NULL
,   p_param3		IN VARCHAR2 := NULL
,   p_param4		IN VARCHAR2 := NULL
,   p_param5		IN VARCHAR2 := NULL
,   p_param6		IN VARCHAR2 := NULL
,   p_param7		IN VARCHAR2 := NULL
,   p_param8		IN VARCHAR2 := NULL
,   p_param9		IN VARCHAR2 := NULL
,   p_param10		IN VARCHAR2 := NULL
,   p_param11		IN VARCHAR2 := NULL
,   p_param12		IN VARCHAR2 := NULL
,   p_param13		IN VARCHAR2 := NULL
,   p_param14 		IN VARCHAR2 := NULL
,   p_param15		IN VARCHAR2 := NULL
,   p_param16		IN VARCHAR2 := NULL
,   p_param17		IN VARCHAR2 := NULL
,   p_param18		IN VARCHAR2 := NULL
,   p_param19		IN VARCHAR2 := NULL
,   p_param20		IN VARCHAR2 := NULL
,   p_param21		IN VARCHAR2 := NULL
,   p_param22		IN VARCHAR2 := NULL
,   p_param23		IN VARCHAR2 := NULL
,   p_param24		IN VARCHAR2 := NULL
,   p_param25		IN VARCHAR2 := NULL
,   p_date_param1   IN DATE := NULL
,   p_date_param2   IN DATE := NULL
,   p_date_param3   IN DATE := NULL
,   p_date_param4   IN DATE := NULL
,   p_date_param5   IN DATE := NULL
,   p_date_param6   IN DATE := NULL
,   p_date_param7   IN DATE := NULL
,   p_date_param8   IN DATE := NULL
,   p_long_param1	IN VARCHAR2 := NULL
, x_return_status OUT NOCOPY VARCHAR2

)
  IS
     l_request_search_rslt	VARCHAR2(1);
     l_return_status		VARCHAR2(1);
     l_request_ind		NUMBER;
     l_req_entity_ind		NUMBER;
     l_request			OE_Order_PUB.REQUEST_REC_TYPE;
     l_req_entity		OE_Order_PUB.Requesting_Entity_Rec_Type;
     l_log_request              VARCHAR2(1);
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering Procedure Log_Request in Package OE_Delayed_Requests_Pvt, entity id: '||p_entity_id||', request type:'||p_request_type);
   END IF;

    -- Initialize the request_record
   l_request.request_type		:= p_request_type;
   l_request.entity_id			:= p_entity_id;
   l_request.entity_code		:= p_entity_code;
   l_request.request_unique_key1 	:= p_request_unique_key1;
   l_request.request_unique_key2 	:= p_request_unique_key2;
   l_request.request_unique_key3 	:= p_request_unique_key3;
   l_request.request_unique_key4 	:= p_request_unique_key4;
   l_request.request_unique_key5 	:= p_request_unique_key5;
   l_request.param1			:= p_param1;
   l_request.param2			:= p_param2;
   l_request.param3			:= p_param3;
   l_request.param4			:= p_param4;
   l_request.param5			:= p_param5;
   l_request.param6			:= p_param6;
   l_request.param7			:= p_param7;
   l_request.param8			:= p_param8;
   l_request.param9			:= p_param9;
   l_request.param10			:= p_param10;
   l_request.param11			:= p_param11;
   l_request.param12			:= p_param12;
   l_request.param13			:= p_param13;
   l_request.param14			:= p_param14;
   l_request.param15			:= p_param15;
   l_request.param16			:= p_param16;
   l_request.param17			:= p_param17;
   l_request.param18			:= p_param18;
   l_request.param19			:= p_param19;
   l_request.param20			:= p_param20;
   l_request.param21			:= p_param21;
   l_request.param22			:= p_param22;
   l_request.param23			:= p_param23;
   l_request.param24			:= p_param24;
   l_request.param25			:= p_param25;
   l_request.date_param1           := p_date_param1;
   l_request.date_param2           := p_date_param2;
   l_request.date_param3           := p_date_param3;
   l_request.date_param4           := p_date_param4;
   l_request.date_param5           := p_date_param5;
   l_request.date_param6           := p_date_param6;
   l_request.date_param7           := p_date_param7;
   l_request.date_param8           := p_date_param8;
   l_request.long_param1		:= p_long_param1;

   -- Initialize the return variable
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Check_For_Request(p_entity_code,
		     p_entity_id,
		     p_request_type,
		     p_request_unique_key1,
		     p_request_unique_key2,
		     p_request_unique_key3,
		     p_request_unique_key4,
		     p_request_unique_key5,
		     l_request_ind,
		     l_request_search_rslt,
		     l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

     l_request.processed := 'N';

     -- Added for bug 12673852
     IF l_request.request_type = OE_GLOBALS.G_DEL_CHG_LINES THEN
         IF oe_mass_change_pvt.Lines_Remaining = 'Y'
         THEN
            oe_debug_pub.add('Called from Mass Change, line remaining, NOT logging G_DEL_CHG_LINES request');
            RETURN;
         ELSE
            oe_debug_pub.add('Called from Mass Change, last line reached, logging G_DEL_CHG_LINES request');
         END IF;
     END IF;
     -- End of bug 12673852

     IF l_request.request_type = OE_GLOBALS.G_PRICE_ORDER
        AND (l_request.request_unique_key1 = 'BATCH'
              AND nvl(l_request.request_unique_key2,'N') = 'Y'
              OR l_request.request_unique_key1 = 'ORDER'
              AND nvl(l_request.request_unique_key2,'N') = 'N'
              OR l_request.request_unique_key1 = 'BATCH'
              AND nvl(l_request.request_unique_key2,'N') = 'N'
              OR l_request.request_unique_key1 = 'BATCH,BOOK'
              AND nvl(l_request.request_unique_key2,'N') = 'Y'
              OR l_request.request_unique_key1 = 'ORDER,BOOK'
              AND nvl(l_request.request_unique_key2,'N') = 'N'
              OR l_request.request_unique_key1 = 'BATCH,BOOK'
              AND nvl(l_request.request_unique_key2,'N') = 'N')
         AND l_request_search_rslt = FND_API.g_false THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('In log_request, calling check_pricing_request.',3);
           oe_debug_pub.add('request_unique_key1 is: '||l_request.request_unique_key1,3);
           oe_debug_pub.add('request_unique_key2 is: '||l_request.request_unique_key2,3);
         END IF;
         Check_Pricing_Request
         ( p_request_ind   => l_request_ind
          ,p_request_rec   => l_request
          ,x_log_request   => l_log_request);

         -- no need to log this delayed request.
         IF l_log_request = 'N' THEN
            RETURN;
         END IF;

         --Bug 7566697
         IF oe_mass_change_pvt.Lines_Remaining = 'Y'
         THEN
            oe_debug_pub.add('Called from Mass Change, line remaining, NOT logging pricing request');
            RETURN;
         ELSE
            oe_debug_pub.add('Called from Mass Change, last line reached, logging pricing request');
         END IF;

      END IF;

      /* Added the following code to fix the fp bug 3498435 */

         IF l_request.request_type = OE_GLOBALS.G_PRICE_LINE
           AND (nvl(l_request.request_unique_key1, l_request.param2) = 'BATCH'
                 AND nvl(l_request.request_unique_key2,'N') = 'N'
                 OR nvl(l_request.request_unique_key1,l_request.param2) = 'BATCH,BOOK'
                 AND nvl(l_request.request_unique_key2,'N') = 'N')
                 OR nvl(l_request.request_unique_key1, l_request.param2) = 'LINE'
            AND l_request_search_rslt = FND_API.g_false THEN
            Check_Pricing_Request
            ( p_request_ind   => l_request_ind
             ,p_request_rec   => l_request
             ,x_log_request   => l_log_request);
                 -- no need to log this delayed request.
            IF l_log_request = 'N' THEN
               RETURN;
            END IF;

         END IF;

     /* End of the code added to fix the fp bug 3498435  */

      IF l_request_search_rslt = FND_API.g_true       -- replace the request
      THEN
    IF l_debug_level > 0 THEN
	    OE_Debug_PUB.ADD('Request replaced');
    END IF;

        IF g_delayed_requests(l_request_ind).request_type =
           OE_GLOBALS.G_CASCADE_CHANGES THEN
          IF l_debug_level > 0 THEN
             OE_Debug_PUB.ADD('cascade changes, orig qty '||
          g_delayed_requests(l_request_ind).param1, 3);
          END IF;
          l_request.param1 := g_delayed_requests(l_request_ind).param1;

        ELSIF g_delayed_requests(l_request_ind).request_type =
           OE_GLOBALS.G_UPDATE_OPTION THEN
          IF l_debug_level > 0 THEN
          OE_Debug_PUB.ADD('update option, orig qty '||
          g_delayed_requests(l_request_ind).param4, 3);
          END IF;

          l_request.param4 := g_delayed_requests(l_request_ind).param4;

        -- Added 09-DEC-2002
        -- BLANKETS: exception for blankets to retain old parameters
        ELSIF p_request_type = OE_GLOBALS.G_PROCESS_RELEASE
        THEN
            IF l_debug_level > 0 THEN
            oe_debug_pub.add('Retain parameters for old values');
            END IF;
            l_request.param1 := g_delayed_requests(l_request_ind).param1;
            l_request.param2 := g_delayed_requests(l_request_ind).param2;
            l_request.param3 := g_delayed_requests(l_request_ind).param3;
            l_request.param4 := g_delayed_requests(l_request_ind).param4;
            l_request.param5 := g_delayed_requests(l_request_ind).param5;
            l_request.param6 := g_delayed_requests(l_request_ind).param6;

        ELSIF p_request_type = OE_GLOBALS.G_DROPSHIP_CMS
        THEN
            l_request.param1  :=  g_delayed_requests(l_request_ind).param1;
            l_request.param2  :=  g_delayed_requests(l_request_ind).param2;
            l_request.param3  :=  g_delayed_requests(l_request_ind).param3;
            l_request.param4  :=  g_delayed_requests(l_request_ind).param4;
            l_request.param5  :=  g_delayed_requests(l_request_ind).param5;
            l_request.param6  :=  g_delayed_requests(l_request_ind).param6;
/*****Begin changes for bug#6918700*********/
--          l_request.param7  :=  g_delayed_requests(l_request_ind).param7;
            l_request.date_param1  :=  g_delayed_requests(l_request_ind).date_param1;
/*****End changes for bug#6918700*********/

        ELSIF p_request_type = OE_GLOBALS.G_GROUP_SCHEDULE
        THEN
            --2819258 -- Retain the operation
            l_request.param14  :=  g_delayed_requests(l_request_ind).param14;
        -- 4052648
        ELSIF p_request_type = OE_GLOBALS.G_SCHEDULE_ATO
        THEN
            -- Retain old parameter values.
            l_request.param7  :=  g_delayed_requests(l_request_ind).param7; -- Ship From
            l_request.param8  :=  g_delayed_requests(l_request_ind).param8; -- Demand Class
            l_request.param14  :=  g_delayed_requests(l_request_ind).param14; -- Ship To
            l_request.param15  :=  g_delayed_requests(l_request_ind).param15; -- Ship Method
            l_request.param16  :=  g_delayed_requests(l_request_ind).param16; -- Planning Priority
            l_request.param17  :=  g_delayed_requests(l_request_ind).param17; -- Delivery Lead Time
            l_request.date_param4  :=  g_delayed_requests(l_request_ind).date_param4; -- Req Date
            l_request.date_param5  :=  g_delayed_requests(l_request_ind).date_param5; -- SSD
            l_request.date_param6  :=  g_delayed_requests(l_request_ind).date_param6; -- SAD
        ELSIF p_request_type = OE_GLOBALS.G_SCHEDULE_SMC
        THEN
            -- Retain old parameter values.
            l_request.param7  :=  g_delayed_requests(l_request_ind).param7; -- Ship From
            l_request.param8  :=  g_delayed_requests(l_request_ind).param8; -- Demand Class
            l_request.param14  :=  g_delayed_requests(l_request_ind).param14; -- Ship To
            l_request.param15  :=  g_delayed_requests(l_request_ind).param15; -- Ship Method
            l_request.param16  :=  g_delayed_requests(l_request_ind).param16; -- Planning Priority
            l_request.param17  :=  g_delayed_requests(l_request_ind).param17; -- Delivery Lead Time
            l_request.date_param4  :=  g_delayed_requests(l_request_ind).date_param4; -- Req Date
            l_request.date_param5  :=  g_delayed_requests(l_request_ind).date_param5; -- SSD
            l_request.date_param6  :=  g_delayed_requests(l_request_ind).date_param6; -- SAD
        ELSIF p_request_type = OE_GLOBALS.G_SCHEDULE_NONSMC
        THEN
            -- Retain old parameter values.
            l_request.param7  :=  g_delayed_requests(l_request_ind).param7; -- Ship From
            l_request.param8  :=  g_delayed_requests(l_request_ind).param8; -- Demand Class
            l_request.param14  :=  g_delayed_requests(l_request_ind).param14; -- Ship To
            l_request.param15  :=  g_delayed_requests(l_request_ind).param15; -- Ship Method
            l_request.param16  :=  g_delayed_requests(l_request_ind).param16; -- Planning Priority
            l_request.param17  :=  g_delayed_requests(l_request_ind).param17; -- Delivery Lead Time
            l_request.date_param4  :=  g_delayed_requests(l_request_ind).date_param4; -- Req Date
            l_request.date_param5  :=  g_delayed_requests(l_request_ind).date_param5; -- SSD
            l_request.date_param6  :=  g_delayed_requests(l_request_ind).date_param6; -- SAD

/* 7576948: IR ISO Change Management project Start */
-- This code is hooked for IR ISO project and specific to
-- OE_GLOBALS.G_UPDATE_REQUISITION delayed request, where if this request
-- is getting replaced then certain parameter values should be retained
-- or manipulated. Following parameters are used for this delayed request
-- Please refer them with their meaning -
--
-- P_entity_code        Entity for which delayed request has to be logged.
--                      In this project it can be OE_Globals.G_Entity_Line
--                      or OE_Globals.G_Entity_Header
-- P_entity_id          Primary key of the entity record. In this project,
--                      it can be Order Line_id or Header_id
-- P_requesting_entity_code Which entity has requested this delayed request to
--                          be logged! In this project it will be OE_Globals.
--                          G_Entity_Line or OE_Globals.G_Entity_Header
-- P_requesting_entity_id       Primary key of the requesting entity. In this
--                              project, it is Line_id or Header_id
-- P_request_type       Indicates which business logic (or which procedure)
--                      should be executed. In this project, it is OE_Global
--                      s.G_UPDATE_REQUISITION
-- P_request_unique_key1        Additional argument in form of parameters.
--                              In this project, it will denote the Sales Order
--                              Header id
-- P_request_unique_key2        Additional argument in form of parameters.
--                              In this project, it will denote the Requisition
--                              Header id
-- P_request_unique_key3        Additional argument in form of parameters. In
--                              this project, it will denote the Requistion Line
--                              id
-- P_param1     Additional argument in form of parameters. In this project, it
--              will denote net change in order quantity with respective single
--              requisition line. If it is greater than 0 then it is an increment
--              in the quantity, while if it is less than 0 then it is a decrement
--              in the ordered quantity. If it is 0 then it indicates there is no
--              change in ordered quantity value
-- P_param2     Additional argument in form of parameters. In this project, it
--              will denote whether internal sales order is cancelled or not. If
--              it is cancelled then respective Purchasing api will be called to
--              trigger the requisition header cancellation. It accepts a value of
--              Y indicating requisition header has to be cancelled.
-- P_param3     Additional argument in form of parameters. In this project, it
--              will denote the number of sales order lines cancelled while order
--              header is (Full/Partial) cancelled.
-- p_date_param1        Additional date argument in form of parameters. In this
--                      project, it will denote the change in Schedule Ship Date
--                      with to respect to single requisition line.
-- P_Long_param1        Additional argument in form of parameters. In this project,
--                      it will store all the sales order line_ids, which are getting
--                      cancelled while order header gets cancelled (Full/Partial).
--                      These Line_ids will be separated by a delimiter comma ','
-- x_return_status      The return status of the API (Expected/Unexcepted/Success)

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc


   ELSIF p_request_type = OE_GLOBALS.G_UPDATE_REQUISITION THEN
     IF l_debug_level > 0 THEN
       oe_debug_pub.add('Type: G_UPDATE_REQUISITION, retain old parameter values',5);
     END IF;

     IF g_delayed_requests(l_request_ind).param1 IS NOT NULL
      AND l_request.param1 IS NULL THEN
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Retaining Delta Quantity change for index '||l_request_ind,5);
         oe_debug_pub.add(' Old Delta Quantity change is '||g_delayed_requests(l_request_ind).param1,5);
         oe_debug_pub.add(' New Delta Quantity change is NULL',5);
       END IF;
       l_request.param1 := g_delayed_requests(l_request_ind).param1;
       -- Retaining the delta quantity change value if the new delta change is null, which could
       -- be typically a case when user will change the order quantity first, and then the
       -- schedule ship date
     END IF;

     IF NVL(g_delayed_requests(l_request_ind).param2,'N') = 'Y' THEN
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Retaining Header Level Cancellation Flag for index '||l_request_ind,5);
         oe_debug_pub.add(' Old Header Level Cancelation flag is '||g_delayed_requests(l_request_ind).param2,5);
         oe_debug_pub.add(' New Header Level Cancelation flag is '||l_request.param2,5);
       END IF;
       l_request.param2 := g_delayed_requests(l_request_ind).param2;
       -- Order Header is requested for cancellation
     END IF;

     IF g_delayed_requests(l_request_ind).param3 IS NOT NULL THEN
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Incrementing the counter for lines to be cancelled for index  '||l_request_ind,5);
         oe_debug_pub.add(' Old counter value is '||g_delayed_requests(l_request_ind).param3,5);
       END IF;
       l_request.param3 := nvl(l_request.param3,0) + g_delayed_requests(l_request_ind).param3;
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' New counter value is '||l_request.param3,5);
       END IF;
       -- Counter maintaining number of order line records cancelled during
       -- the order header level (Full/Partial) cancellation request
     END IF;

     IF l_request.long_param1 IS NOT NULL THEN
       IF g_delayed_requests(l_request_ind).long_param1 IS NOT NULL THEN
         IF l_debug_level > 0 THEN
           oe_debug_pub.add(' Line_ids to be cancelled for index '||l_request_ind,5);
           oe_debug_pub.add(' Old Line_ids are '||g_delayed_requests(l_request_ind).long_param1,5);
         END IF;
         l_request.long_param1 := g_delayed_requests(l_request_ind).long_param1||','|| l_request.long_param1;
         IF l_debug_level > 0 THEN
           oe_debug_pub.add(' New Line_ids are '||l_request.long_param1,5);
         END IF;
         -- A string variable containing line_ids, which are cancelled during
         -- the Order Header level (Full/Partial) cancellation request
         -- In this string, the Line_ids will be separated by a delimiter comma ','
       END IF;
     ELSE
       l_request.long_param1 := g_delayed_requests(l_request_ind).long_param1;
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Only old Line_ids are retained '||l_request.long_param1,5);
       END IF;
       -- Since this request has not passed the line_id, just retain the global
     END IF;

     IF g_delayed_requests(l_request_ind).date_param1 IS NOT NULL
      AND l_request.date_param1 IS NULL THEN
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Retain Old date_param1 : '||g_delayed_requests(l_request_ind).date_param1,5);
       END IF;
       l_request.date_param1 := g_delayed_requests(l_request_ind).date_param1;
     END IF;

     --Bug 14211120 Start
     IF g_delayed_requests(l_request_ind).param4 IS NOT NULL
      AND l_request.param4 IS NULL THEN
       IF l_debug_level > 0 THEN
         oe_debug_pub.add(' Secondary: Retaining Delta Quantity change for index '||l_request_ind,5);
         oe_debug_pub.add(' Secondary: Old Delta Quantity change is'||g_delayed_requests(l_request_ind).param4,5);
         oe_debug_pub.add(' Secondary: New Delta Quantity change is NULL',5);
       END IF;
       l_request.param4 := g_delayed_requests(l_request_ind).param4;
     END IF;
     --Bug 14211120 End


/* ============================= */
/* IR ISO Change Management Ends */


        END IF;

         g_delayed_requests(l_request_ind) := l_request;

       ELSE					   -- insert the new request
    IF l_debug_level > 0 THEN
	OE_Debug_PUB.ADD('New request inserted');
    END IF;
--         l_request_ind := nvl(g_delayed_requests.LAST, 0) + 1;

        -- 11i10 Pricing Changes for blankets
        IF p_request_type = OE_GLOBALS.G_PROCESS_RELEASE
           AND OE_Code_Control.Get_Code_Release_Level >= '110510'
        THEN
           OE_Blkt_Release_Util.Cache_Order_Qty_Amt
              (p_request_rec     => l_request
              ,x_return_status   => l_return_status
              ) ;
           if l_return_status = fnd_api.g_ret_sts_error then
              raise fnd_api.g_exc_error;
           elsif l_return_status = fnd_api.g_ret_sts_error then
              raise fnd_api.g_exc_unexpected_error;
           end if;
        END IF;

         g_delayed_requests(l_request_ind) := l_request;

      END IF;

	-- Initialize the requesting entity record
      l_req_entity.entity_code := p_requesting_entity_code;
      l_req_entity.entity_id := p_requesting_entity_id;
      l_req_entity.request_index := l_request_ind;

	l_req_entity_ind := nvl(g_requesting_entities.LAST, 0) + 1;

      -- Insert into the requesting entities table
      g_requesting_entities(l_req_entity_ind) := l_req_entity;
      IF l_debug_level > 0 THEN
      oe_debug_pub.add('!!!!!!! index '|| l_request_ind, 5);
      END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'LOGREQUEST');
      END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Log_Request;

Function Check_for_Request( p_entity_code   IN VARCHAR2,
                            p_entity_id     IN NUMBER,
                            p_request_type  IN VARCHAR2,
                            p_request_unique_key1 	IN VARCHAR2 := NULL,
			    p_request_unique_key2 	IN VARCHAR2 := NULL,
			    p_request_unique_key3 	IN VARCHAR2 := NULL,
			    p_request_unique_key4 	IN VARCHAR2 := NULL,
			    p_request_unique_key5 	IN VARCHAR2 := NULL
			    )
RETURN BOOLEAN IS
l_ind           Number;
x_result        Varchar2(30);
x_return_status Varchar2(30);
Begin
    Check_for_Request( p_entity_code    	=> p_entity_code
		       ,p_entity_id    	 	=> p_entity_id
		       ,p_request_type  	=> p_request_type
		       ,p_request_unique_key1 	=> p_request_unique_key1
		       ,p_request_unique_key2 	=> p_request_unique_key2
		       ,p_request_unique_key3 	=> p_request_unique_key3
		       ,p_request_unique_key4 	=> p_request_unique_key4
		       ,p_request_unique_key5	=> p_request_unique_key5
		       ,x_request_ind   	=> l_ind
		       ,x_result        	=> x_result
		       ,x_return_status 	=> x_return_status);

    if x_result = FND_API.G_TRUE then
       return(TRUE);
    else
       return(FALSE);
    end if;

End;

Procedure Delete_Request(p_entity_code     IN VARCHAR2
                        ,p_entity_id       IN NUMBER
                        ,p_request_Type    IN VARCHAR2
                        ,p_request_unique_key1 	IN VARCHAR2 := NULL
			,p_request_unique_key2 	IN VARCHAR2 := NULL
			,p_request_unique_key3 	IN VARCHAR2 := NULL
			,p_request_unique_key4 	IN VARCHAR2 := NULL
			,p_request_unique_key5 	IN VARCHAR2 := NULL
,x_return_status OUT NOCOPY VARCHAR2)

  IS
     l_request_search_rslt  Varchar2(1);
     l_return_status     Varchar2(1);
     l_request_ind       number;
     l_req_entity_ind    number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Entering Procedure Delete_Request in Package OE_Delayed_Requests_Pvt');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    Check_for_Request( p_entity_code    	=> p_entity_code
		       ,p_entity_id    	 	=> p_entity_id
		       ,p_request_type  	=> p_request_type
		       ,p_request_unique_key1 	=> p_request_unique_key1
		       ,p_request_unique_key2 	=> p_request_unique_key2
		       ,p_request_unique_key3 	=> p_request_unique_key3
		       ,p_request_unique_key4 	=> p_request_unique_key4
		       ,p_request_unique_key5	=> p_request_unique_key5
		       ,x_request_ind   	=> l_request_ind
		       ,x_result        	=> l_request_search_rslt
		       ,x_return_status 	=> l_return_status);


       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

   if l_request_search_rslt = FND_API.G_TRUE     -- delete the request
     then
      G_Delayed_Requests.Delete(l_request_ind);
/*
       BUG 1794544 - do not delete from req entities table
       , delete table in the end when all requests are processed
       This to improve performance as this search loops through
       the entire pl/sql table which becomes very large with
       greater number of lines being processed
      -- Delete all the records in the requesting entities table
      -- that have this request.
        l_req_entity_ind := G_Requesting_Entities.First;
          WHILE l_req_entity_ind IS NOT NULL LOOP
           IF G_Requesting_Entities(l_req_entity_ind).request_index = l_request_ind
           THEN
                G_Requesting_Entities.Delete(l_req_entity_ind);
           END IF;
           l_req_entity_ind := G_Requesting_Entities.Next(l_req_entity_ind);
          END LOOP;
*/
   end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   when others THEN

      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'DeleteRequest');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Delete_Request;

Procedure Clear_Request( x_return_status OUT NOCOPY VARCHAR2)

  IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Entering Procedure Clear_Request in Package OE_Delayed_Requests_Pvt');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

      G_Delayed_Requests.DELETE;
      g_requesting_entities.DELETE;

      --Bug4504362
        OE_Config_Schedule_Pvt.Delete_Attribute_Changes;

    --- Bug #2674349
     IF(OE_Line_Adj_Util.G_CHANGED_LINE_TBL.count>0) THEN
         Oe_Line_Adj_Util.Delete_Changed_Lines_Tbl;
      END IF;

   ----Bug #2822222
     /*   IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN
                OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
                END IF;          */


EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'Clear_Request');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Clear_Request;

Procedure Process_Request( p_entity_code          IN VARCHAR2
                        ,p_entity_id              IN Number
                        ,p_request_Type           IN VARCHAR2
                        ,p_request_unique_key1 	IN VARCHAR2 := NULL
                        ,p_request_unique_key2 	IN VARCHAR2 := NULL
                        ,p_request_unique_key3 	IN VARCHAR2 := NULL
                        ,p_request_unique_key4 	IN VARCHAR2 := NULL
                        ,p_request_unique_key5 	IN VARCHAR2 := NULL
                        ,p_delete                 IN Varchar2 Default
											FND_API.G_TRUE
,x_return_status OUT NOCOPY Varchar2)

IS
l_request_ind          Number;
l_request_search_rslt  Varchar2(30);
l_return_status        Varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Entering Procedure Process_Request in Package OE_Delayed_Requests_Pvt');
   END IF;
    Check_for_Request( p_entity_code    	=> p_entity_code
		       ,p_entity_id    	 	=> p_entity_id
		       ,p_request_type  	=> p_request_type
		       ,p_request_unique_key1 	=> p_request_unique_key1
		       ,p_request_unique_key2 	=> p_request_unique_key2
		       ,p_request_unique_key3 	=> p_request_unique_key3
		       ,p_request_unique_key4 	=> p_request_unique_key4
		       ,p_request_unique_key5	=> p_request_unique_key5
		       ,x_request_ind   	=> l_request_ind
		       ,x_result        	=> l_request_search_rslt
		       ,x_return_status 	=> l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   if l_request_search_rslt = FND_API.G_TRUE then
      Process_Request_Pvt
         (p_request_ind       => l_request_ind
         ,p_delete            => p_delete
         ,x_return_status     => l_return_status
         );
   end if;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request'
            );
        END IF;

End Process_Request;

Procedure Process_Request_for_Entity
     ( p_entity_code     in Varchar2
     ,p_delete            in Varchar2 Default FND_API.G_TRUE
,x_return_status OUT NOCOPY Varchar2) IS

l_return_status        Varchar2(30);
l_ind                  Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Enter OE_Delayed_Requests_Pvt.Process_Request_for_Entity',1);
   END IF;
   IF NOT oe_globals.g_call_process_req THEN --9354229
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT PROCESS_REQUESTS_FOR_ENTITY' , 1 ) ;
      END IF;
      RETURN;
   END IF;
    oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 1);


        IF oe_globals.g_recursion_mode = 'N' THEN


   l_ind := G_Delayed_Requests.first;

   WHILE l_ind IS NOT NULL LOOP
     IF G_Delayed_Requests(l_ind).Entity_code = p_entity_code THEN
        Process_Request_Pvt
           (p_request_ind       => l_ind
           ,p_delete            => p_delete
           ,x_return_status     => l_return_status
           );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level > 0 THEN
             oe_debug_pub.add('Expected error in Process_Request_for_Entity ');
/* Commented the following 2 debug messages to fix the bug 13513618 */
/*
           oe_debug_pub.add
           ('2 type----- '|| G_Delayed_Requests(l_ind).request_type, 1);
           oe_debug_pub.add
           ('2 ind----- '|| l_ind, 1);
*/
           END IF;
	         RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
     l_ind := G_Delayed_Requests.Next(l_ind);
  END LOOP;
  END IF; -- Recursion mode

  IF l_debug_level > 0 THEN
   oe_debug_pub.add('Exiting Process_Request_for_Entity ');
  END IF;

  oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
        oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_for_Entity'
            );
        END IF;
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Exiting Process_Request_for_Entity ');
   END IF;

End Process_Request_for_Entity;


Procedure Process_Request_for_ReqType
          ( p_request_type   in Varchar2
           ,p_delete         in Varchar2 Default FND_API.G_TRUE
,x_return_status OUT NOCOPY Varchar2

          ) IS
l_return_status        Varchar2(30);
l_ind                  Number;
l_count                Number;
l_req_entity_ind       Number;

l_entity_id_tbl    Entity_Id_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Entering Procedure Process_Request_for_ReqType in Package OE_Delayed_Requests_Pvt');
   END IF;

   IF NOT oe_globals.g_call_process_req THEN --9354229
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT Process_Request_for_ReqType' , 1 ) ;
      END IF;
      RETURN;
   END IF;

   oe_order_pvt.set_recursion_mode(p_Entity_Code => 11,
                                   p_In_out  => 1);

	--IF oe_globals.g_recursion_mode = 'N' THEN
   l_ind := G_Delayed_Requests.first;
   l_count := 0;
   WHILE l_ind IS NOT NULL LOOP
     IF G_Delayed_Requests(l_ind).request_type = p_request_type THEN
	   IF p_request_type = OE_GLOBALS.G_TAX_LINE THEN
		 l_count := l_count + 1;
           l_entity_id_tbl(l_count).entity_id := G_Delayed_Requests(l_ind).entity_id;
           l_entity_id_tbl(l_count).request_ind := l_ind;
	   ELSE
            Process_Request_Pvt
               (p_request_ind       => l_ind
               ,p_delete            => p_delete
               ,x_return_status     => l_return_status
               );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	             RAISE FND_API.G_EXC_ERROR;
            END IF;
	   END IF;
     END IF;
     l_ind := G_Delayed_Requests.Next(l_ind);
  END LOOP;
  IF l_entity_id_tbl.COUNT > 0 THEN
       OE_Delayed_Requests_UTIL.Process_Tax
       (p_Entity_id_tbl       => l_entity_id_tbl
       ,x_return_status     => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
       END IF;
	  l_count := l_entity_id_tbl.FIRST;
	  WHILE l_count IS NOT NULL LOOP  -- Fixing 1888284
		 G_Delayed_Requests.DELETE(l_entity_id_tbl(l_count).request_ind);
/*
       BUG 1794544 - do not delete from req entities table
       , delete table in the end when all requests are processed
       This to improve performance as this search loops through
       the entire pl/sql table which becomes very large with
       greater number of lines being processed
           l_req_entity_ind := G_Requesting_Entities.First;
           WHILE l_req_entity_ind IS NOT NULL LOOP
               IF G_Requesting_Entities(l_req_entity_ind).request_index
                  = l_entity_id_tbl(l_count).request_ind
               THEN
                   G_Requesting_Entities.Delete(l_req_entity_ind);
               END IF;
               l_req_entity_ind := G_Requesting_Entities.Next(l_req_entity_ind);
           END LOOP;
*/
           l_count := l_entity_id_tbl.NEXT(l_count);
	  END LOOP;

  END IF;
	--END IF ; -- Recursion mode
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 11,
                                   p_In_out  => 0);
  IF l_debug_level > 0 THEN
  oe_debug_pub.add('leaving process_requenst_for_reqtype', 1);
  END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 11,
                                   p_In_out  => 0);
        oe_debug_pub.add('execution error', 1);
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 11,
                                   p_In_out  => 0);
        oe_debug_pub.add('unexp error', 1);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 11,
                                   p_In_out  => 0);
        oe_debug_pub.add('others error', 1);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_for_ReqType'
            );
        END IF;

End Process_Request_for_ReqType;

Procedure Process_Delayed_Requests(
x_return_status OUT NOCOPY Varchar2

          ) IS
l_ind NUMBER;  /* 1739574 */
l_return_status Varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Enter OE_Delayed_Requests_Pvt.Process_Delayed_Requests');
   END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF NOT oe_globals.g_call_process_req THEN --9354229
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_Delayed_Requests_Pvt.Process_Delayed_Requests' , 1 ) ;
      END IF;
      RETURN;
   END IF;
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 1);

   -- Process requests as per the dependency
   -- Process a request to default header sales credit for
   -- primary sales person
	IF oe_globals.g_recursion_mode = 'N' THEN

      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- Process Header Sales Credits Delayed Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CHECK_HSC_QUOTA_TOTAL
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- Process Lines Sales Credits Delayed Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CHECK_LSC_QUOTA_TOTAL
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

/* Bug 12673852 */
    Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_VERSION_AUDIT
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;
/* End of Bug 12673852 */

     -- Process CREATE_SETS Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CREATE_SETS
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;



     -- Process CREATE_CONFIG_ITEM Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CREATE_CONFIG_ITEM
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process INSERT_INTO_SETS Requests
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_INSERT_INTO_SETS
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

/* Start DOO Pre Exploded Kit ER 9339742 */
     Process_Request_for_Reqtype
        ( p_request_type  => OE_GLOBALS.G_PRE_EXPLODED_KIT
        , p_delete        => FND_API.G_TRUE
        , x_return_status => l_return_status );

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;
/* End DOO Pre Exploded Kit ER 9339742 */

     -- Process INS_INCLUDED_ITEM Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_INS_INCLUDED_ITEMS
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;



     -- Process requests for RMA
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_INSERT_RMA
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for Split_hold
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_SPLIT_HOLD
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for Delayed Requests
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_EVAL_HOLD_SOURCE
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for Quantity Cascade
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CASCADE_QUANTITY
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

/*** we do not need this, confirm with ashwin
     -- Process requests for project Cascade
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CASCADE_PROJECT
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for task Cascade
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CASCADE_TASK
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for task Cascade
***/
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CASCADE_CHANGES
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests to Split Reservations
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CREATE_RESERVATIONS
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests to Complete Configuration
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_COMPLETE_CONFIGURATION
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for Validate Configuration
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_VALIDATE_CONFIGURATION
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for CTO Notification
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CTO_NOTIFICATION
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process requests for Service
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_INSERT_SERVICE
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;

    /* Added the below call for bug 5925600 */
    Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_GROUP_SCHEDULE
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;
/* Bug 9845427 */
    Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_DELAYED_SCHEDULE
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;
/* End of Bug 9845427 */

    Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CASCADE_OPTIONS_SERVICE
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
     END IF;
    /* End of changes done for bug 5925600 */

-- bug 5717671/5736696, need to execute copy header adj
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_HEADER_ADJUSTMENTS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- bug 1834260, moved this block of code from after processing
    -- for request type G_PRICE_LINE to before it.
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_ADJUSTMENTS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Process Requests for Freight Rating.
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_FREIGHT_RATING
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Added for Bug # 1559906 */
    /* Renga- copy_freight_charges delayed request should be executed
       right after copy_adjustments - please do not put any delayed
       request in between copy_adjustments and copy_freight_charges */

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_FREIGHT_CHARGES
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Process Requests for Pricing
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_PRICE_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


   -- Renga - added freight_for_included items call
    -- Process Requests for Freight For included items.
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_FREIGHT_FOR_INCLUDED
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

 -- Renga - done for freight for included items.


    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_PRICE_ORDER
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_PRICE_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- added by lkxu
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_PRICING_ATTRIBUTES
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_MODEL_PATTR
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Process Delete Charges Delayed Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_DELETE_CHARGES
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- Process Tax Delayed Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_TAX_LINE
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;


      -- Process Commitment Delayed Requests
      Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_CALCULATE_COMMITMENT
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Process Commitment Delayed Requests
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_UPDATE_COMMITMENT
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- for multiple payments
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_UPDATE_COMMITMENT_APPLIED
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- for multiple payments
    Process_Request_for_ReqType
	        (p_request_type  	=> OE_GLOBALS.G_SPLIT_PAYMENT
	         ,p_delete        	=> FND_API.G_TRUE
	         ,x_return_status 	=> l_return_status
	        );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    Process_Request_for_ReqType
	        (p_request_type  	=> OE_GLOBALS.G_UPDATE_HDR_PAYMENT
	         ,p_delete        	=> FND_API.G_TRUE
	         ,x_return_status 	=> l_return_status
	        );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Process requests for Payment Verification
     Process_Request_for_ReqType
        (p_request_type   => OE_GLOBALS.G_VERIFY_PAYMENT
         ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

     Process_Request_for_ReqType
	        (p_request_type  	=> OE_GLOBALS.G_DELETE_PAYMENT_HOLD
	         ,p_delete        	=> FND_API.G_TRUE
	         ,x_return_status 	=> l_return_status
	        );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Process Request to create automatic attachments
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Process Request to copy attachments
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_ATCHMT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

        --added by MShenoy for Spares Management ikon project - Create internal req.
     IF l_debug_level > 0 THEN
     oe_debug_pub.add(' Entering Procedure process_Delayed_Requests in Package OE_Delayed_Requests_Pvt');
     END IF;

      OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
             (p_request_type   =>OE_GLOBALS.G_CREATE_INTERNAL_REQ
              ,p_delete        => FND_API.G_TRUE
             ,x_return_status => l_return_status);
     IF l_debug_level > 0 THEN
     oe_debug_pub.add(' leaving Procedure process_Delayed_Requests in Package
                       OE_Delayed_Requests_Pvt ret status '||l_return_status);
     END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- B2013611 reverse promotional limits
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_REVERSE_LIMITS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    --MRG BGN
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   => OE_GLOBALS.G_MARGIN_HOLD
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    --MRG END


    ----------
    --Btea
    ----------

    --MRG BGN
    IF l_debug_level > 0 THEN
    oe_debug_pub.add('before call to OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype in process_delayed_requests');
    END IF;
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   => OE_GLOBALS.G_GET_COST
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
         );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    --MRG END


    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_DEL_CHG_LINES
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


    --process delayed requests for xml generation

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_GENERATE_XML_REQ_HDR
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Please do not put any delayed requests that can update qty
    -- or price before this point !

    -- BLANKETS: Update released amount/qty on blanket order/line
    -- IMPORTANT: This request should be executed after all requests that
    -- can result in change to qty or price are executed.
    -- This will execute both requests of type: PROCESS_RELEASE
    -- and VALIDATE_RELEASE_SHIPMENTS.
    OE_Blkt_Release_Util.Process_Releases
             (p_request_tbl   => G_Delayed_Requests
             ,x_return_status => l_return_status);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Changes for Enhanced Dropshipments

    OE_Purchase_Release_PVT.Process_DropShip_CMS_Requests
             (p_request_tbl   => G_Delayed_Requests
             ,x_return_status => l_return_status);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


/* 7576948: IR ISO Change Management project Start */
-- This code is hooked up for IR ISO project so as to trigger
-- the delayed request processing for update of internal requisition

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc


    -- Process Request to Update the Internal Requisition
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         ( p_request_type  => OE_GLOBALS.G_UPDATE_REQUISITION
         , p_delete        => FND_API.G_TRUE
         , x_return_status => l_return_status
         );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

/* ============================= */
/* IR ISO Change Management Ends */


    --process delayed requests for cancel workflow

    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_CANCEL_WF
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;


   /* Please do not put execution of any delayed request beyond this point */
   l_ind := G_Delayed_Requests.first;

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('Global Request count-PDR-E'||G_Delayed_Requests.count,1);
     oe_debug_pub.add('*****l_ind :' || l_ind, 1);
   END IF;

   WHILE l_ind IS NOT NULL LOOP
        Process_Request_Pvt
           (p_request_ind       => l_ind
           ,p_delete            => FND_API.G_TRUE
           ,x_return_status     => l_return_status
           );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	         RAISE FND_API.G_EXC_ERROR;
        END IF;
     l_ind := G_Delayed_Requests.Next(l_ind);
  END LOOP;

    -- Process Request to Complete workflow activity
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COMPLETE_ACTIVITY
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
     IF l_debug_level > 0 THEN
     oe_debug_pub.add('Global Request count-PDR-AL'||G_Delayed_Requests.count,1);
     END IF;

     -- clear the delayed request cache
     Clear_Request(x_return_status);
	END IF; -- Recursion mode
     oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
        oe_order_pvt.set_recursion_mode(p_Entity_Code => 9,
                                   p_In_out  => 0);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Delayed_Requests'
            );
        END IF;
End Process_Delayed_Requests;

/** This procedure is called twice from Process Order.  Once to
**  process action requests that need to be processed before the flows have
** started and a second time to process action requests that can ONLY be
** processed after the flow has started (book, LINK, match_and_reserve)
**/

PROCEDURE Process_Order_Actions
(p_validation_level	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 p_x_request_tbl		IN OUT NOCOPY OE_Order_PUB.request_tbl_type,
 p_process_WF_requests IN boolean DEFAULT TRUE
 )
  IS
     l_request_rec		OE_Order_PUB.request_rec_type;
     l_return_status            VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_header_id                 NUMBER;
l_line_id                   NUMBER;
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref         VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
l_source_document_line_id   NUMBER;
--R12 CVV2
--comm rej l_reject_on_auth_failure    VARCHAR2(1);
--comm rej l_reject_on_risk_failure    VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                 VARCHAR2(4000);
l_result_out               VARCHAR2(30);
l_header_rec               OE_ORDER_PUB.Header_Rec_Type;
--R12 CVV2

-- ER 7243028
l_lines_count               NUMBER;
l_lines_list                VARCHAR2(4000);

BEGIN
   IF l_debug_level > 0 THEN
   oe_debug_pub.ADD('Entering OE_ORDER_PUB.PROCESS_ORDER_ACTIONS', 1);
   END IF;

IF NOT oe_globals.g_call_process_req THEN --9354229
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_ORDER_PUB.PROCESS_ORDER_ACTIONS' , 1 ) ;
      END IF;
      RETURN;
   END IF;

   -- added for notification framework
   -- check code release leve first, notificaiont framework is at pack H
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 10,
                                   p_In_out  => 1);
   END IF;

   FOR i IN 1..p_x_request_tbl.COUNT LOOP
   BEGIN
      IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('Processing delayed requests # = '
		       || To_char(i), 2);
      END IF;

      -- If request is already processed then loop around.

	 IF (p_x_request_tbl(i).processed = 'Y') then
	    goto END_OF_LOOP;
      END IF;

      l_request_rec := p_x_request_tbl(i);
      IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('Request Type =  '
		       || l_request_rec.request_type, 2);
      END IF;
      IF l_request_rec.entity_code = 'HEADER' THEN
         l_header_id := l_request_rec.entity_id;
         IF l_request_rec.entity_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_request_rec.entity_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;
      ELSIF l_request_rec.entity_code = 'LINE' THEN
         l_line_id := l_request_rec.entity_id;
         IF l_request_rec.entity_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||l_request_rec.entity_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id,  orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref, header_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref, l_header_id
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_request_rec.entity_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_header_id := null;
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_header_id := null;
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
            END;
         END IF;
      ELSIF l_request_rec.entity_code = 'HEADER_ADJ' THEN
         IF l_request_rec.entity_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting header_id of the header adjustment:'||l_request_rec.entity_id);
               END IF;
               SELECT header_id
               INTO   l_header_id
               FROM   oe_price_adjustments
               WHERE  price_adjustment_id = l_request_rec.entity_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_header_id := null;
               WHEN OTHERS THEN
                  l_header_id := null;
            END;
         END IF;
         IF l_header_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;
      ELSIF l_request_rec.entity_code = 'LINE_ADJ' THEN
         IF l_request_rec.entity_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting line_id of the line adjustment:'||l_request_rec.entity_id);
               END IF;
               SELECT line_id
               INTO   l_line_id
               FROM   oe_price_adjustments
               WHERE  price_adjustment_id = l_request_rec.entity_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_line_id := null;
               WHEN OTHERS THEN
                  l_line_id := null;
            END;
         END IF;
         IF l_line_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||l_line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id,  orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref, header_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref, l_header_id
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_line_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_header_id := null;
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_header_id := null;
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
            END;
         END IF;
      ELSIF l_request_rec.entity_code = 'HEADER_SCREDIT' THEN
         IF l_request_rec.entity_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting header_id of the header scredit:'||l_request_rec.entity_id);
               END IF;
               SELECT header_id
               INTO   l_header_id
               FROM   oe_sales_credits
               WHERE  sales_credit_id = l_request_rec.entity_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_header_id := null;
               WHEN OTHERS THEN
                  l_header_id := null;
            END;
         END IF;
         IF l_header_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for header_id:'||l_header_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = l_header_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
         END IF;
      ELSIF l_request_rec.entity_code = 'LINE_SCREDIT' THEN
         IF l_request_rec.entity_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting line_id of the line scredit:'||l_request_rec.entity_id);
               END IF;
               SELECT line_id
               INTO   l_line_id
               FROM   oe_sales_credits
               WHERE  sales_credit_id = l_request_rec.entity_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_line_id := null;
               WHEN OTHERS THEN
                  l_line_id := null;
            END;
         END IF;
         IF l_line_id IS NOT NULL THEN
            BEGIN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Getting reference data for line_id:'||l_line_id);
               END IF;
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id,  orig_sys_line_ref,
               source_document_line_id, orig_sys_shipment_ref, header_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id, l_orig_sys_line_ref,
               l_source_document_line_id, l_orig_sys_shipment_ref, l_header_id
               FROM   OE_ORDER_LINES_ALL
               WHERE  line_id = l_line_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_header_id := null;
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
               WHEN OTHERS THEN
                   l_header_id := null;
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
                   l_orig_sys_line_ref := null;
                   l_source_document_line_id := null;
                   l_orig_sys_shipment_ref := null;
            END;
         END IF;
      END IF;

      OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> l_request_rec.entity_code
  	,p_entity_id         		=> l_request_rec.entity_id
    	,p_header_id         		=> l_header_id
    	,p_line_id           		=> l_line_id
    	,p_order_source_id  		=> l_order_source_id
    	,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    	,p_orig_sys_document_line_ref	=> l_orig_sys_line_ref
    	,p_orig_sys_shipment_ref	=> l_orig_sys_shipment_ref
    	,p_change_sequence  		=> l_change_sequence
    	,p_source_document_type_id	=> l_source_document_type_id
    	,p_source_document_id		=> l_source_document_id
    	,p_source_document_line_id	=> l_source_document_line_id );
    IF l_debug_level > 0 THEN
	oe_debug_pub.add('Request Entity:'||l_request_rec.entity_code||
					' Request ID:'||l_request_rec.entity_id);
    END IF;

	   -- Action Request to Apply Automatic Attachments
        IF  l_request_rec.request_type = OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT THEN

               OE_DELAYED_REQUESTS_UTIL.Apply_Automatic_Attachments
					( p_entity_code 		=> l_request_rec.entity_code
					, p_entity_id 			=> l_request_rec.entity_id
					, p_is_user_action		=> 'Y'
					, x_return_status		=> l_return_status
					);
               l_request_rec.processed := 'Y';
        ELSIF l_request_rec.request_type = OE_GLOBALS.G_PRICE_ORDER THEN
        -- For ER 7243028
            IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
                IF l_debug_level > 0 THEN
                  oe_debug_pub.add('Before calling Price Order for :' || l_request_rec.entity_id, 5);
                END IF;
		OE_ORDER_ADJ_PVT.price_action
		(
			p_header_count          =>      1,
			p_header_list           =>      l_request_rec.entity_id,
			p_line_count            =>      0,
			p_line_list             =>      NULL,
			p_price_level           =>      'ORDER',
			x_return_status		=>      l_return_status,
			x_msg_count             =>      l_msg_count,
			x_msg_data              =>      l_msg_data
		);
            ELSIF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE THEN

                l_lines_count :=0;

                for j in i .. p_x_request_tbl.count loop
                    if p_x_request_tbl(j).request_type = OE_GLOBALS.G_PRICE_ORDER and
                       p_x_request_tbl(j).entity_code = OE_GLOBALS.G_ENTITY_LINE
                    then
                       l_lines_count := l_lines_count + 1;
                       if l_lines_count = 1 then
                         l_lines_list := p_x_request_tbl(j).entity_id;
                       else
                         l_lines_list := l_lines_list || ',' || p_x_request_tbl(j).entity_id;
                       end if;
                       p_x_request_tbl(j).processed := 'Y';
                    end if;
                end loop;

                IF l_debug_level > 0 THEN
                  oe_debug_pub.add('Before calling Price Line for count :' || l_lines_count || '; List : ' || l_lines_list, 5);
                END IF;
                OE_ORDER_ADJ_PVT.price_action
                (
                        p_header_count          =>      0,
                        p_header_list           =>      null,
                        p_line_count            =>      l_lines_count,
                        p_line_list             =>      l_lines_list,
                        p_price_level           =>      'LINE',
                        x_return_status         =>      l_return_status,
                        x_msg_count             =>      l_msg_count,
                        x_msg_data              =>      l_msg_data
                );
            ELSE
                IF l_debug_level > 0 THEN
                  oe_debug_pub.add('Invalid entity given for Price Order Action. Entity has to be Header or Line', 5);
                END IF;

		    FND_MESSAGE.SET_NAME('ONT','ONT_INVALID_REQUEST');
		    FND_MESSAGE.SET_TOKEN('ACTION',l_request_rec.request_type);
		    OE_MSG_PUB.Add;
		    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_debug_level > 0 THEN
              oe_debug_pub.add('After Price Order, Status : ' || l_return_status, 5);
            END IF;

            l_request_rec.processed := 'Y';

            IF l_request_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_request_rec.return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

        -- End of ER 7243028

	   ELSIF l_request_rec.request_type = OE_GLOBALS.G_APPLY_HOLD THEN
		IF l_debug_level > 0 THEN
		OE_Debug_PUB.ADD('Calling Apply_Hold', 2);
		END IF;
		OE_Delayed_Requests_UTIL.Apply_Hold
	           (p_validation_level => p_validation_level,
	            x_request_rec      => l_request_rec);

                l_request_rec.processed := 'Y';
        IF l_debug_level > 0 THEN
		OE_Debug_PUB.ADD('After Calling Apply_hold', 2);
        END IF;

	   ELSIF l_request_rec.request_type = OE_GLOBALS.G_RELEASE_HOLD THEN
               IF l_debug_level > 0 THEN
               OE_Debug_PUB.ADD('Calling Release_Hold', 2);
               END IF;
	       OE_Delayed_Requests_UTIL.Release_Hold
	       	   (p_validation_level => p_validation_level,
	             x_request_rec => l_request_rec);
               l_request_rec.processed := 'Y';
               IF l_debug_level > 0 THEN
               OE_Debug_PUB.ADD('After Calling Release_hold', 2);
               END IF;
           --R12 CVV2
           ELSIF l_request_rec.request_type = OE_GLOBALS.G_VERIFY_PAYMENT THEN
               /*comm rej  IF nvl(l_request_rec.param2, 'HOLD') = 'REJECT' THEN
                    l_reject_on_auth_failure := 'Y';
                 ELSE
                    l_reject_on_auth_failure := 'N';
                 END IF;

                 IF nvl(l_request_rec.param3, 'HOLD') = 'REJECT' THEN
                    l_reject_on_risk_failure := 'Y';
                 ELSE
                    l_reject_on_risk_failure := 'N';
                 END IF; comm rej*/

                 /*
                 OE_Verify_Payment_PUB.Verify_Payment
                                     ( p_header_id      => l_request_rec.entity_id
                                     , p_calling_action => null
                                     , p_delayed_request=> null
                                     , p_reject_on_auth_failure => l_reject_on_auth_failure
                                     , p_reject_on_risk_failure => l_reject_on_risk_failure
                                     , p_risk_eval_flag => l_request_rec.param1
                                     , p_msg_count      => l_msg_count
                                     , p_msg_data       => l_msg_data
                                     , p_return_status  => l_return_status
                                     );
                l_request_rec.return_status := l_return_status;
                */

                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Before call to Authrize Payment header_id is: ' || l_header_id);
                   oe_debug_pub.add('Before call to Authrize Payment line_id is: ' || l_line_id);
               --comm rej    oe_debug_pub.add('reject on auth is: ' || l_reject_on_auth_failure);
               --comm rej    oe_debug_pub.add('reject on risk is: ' || l_reject_on_risk_failure);
                   oe_debug_pub.add('risk eval flag is: ' || l_request_rec.param1);
                END IF;

                OE_Header_UTIL.Query_Row
        		(p_header_id            => l_header_id
        		,x_header_rec           => l_header_rec
        		);

                 OE_Verify_Payment_PUB.Authorize_MultiPayments
                            ( p_header_rec          => l_header_rec
                            , p_line_id             => l_line_id --bug3524209
                            , p_calling_action      => null
                            --R12 CVV2
                          --comm rej  , p_reject_on_auth_failure => l_reject_on_auth_failure
                          --comm rej  , p_reject_on_risk_failure => l_reject_on_risk_failure
                            , p_risk_eval_flag         => l_request_rec.param1
                            --R12 CVV2
                            , p_msg_count           => l_msg_count
                            , p_msg_data            => l_msg_data
                            , p_result_out          => l_result_out
                            , p_return_status       => l_return_status
                            );

                l_request_rec.return_status := l_return_status;

                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('After call to Authorizat Payment return status : ' || l_return_status);
                END IF;

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                l_request_rec.processed := 'Y';
                -- to ensure verify_payment not getting called again during book_order.
                OE_GLOBALS.G_PAYMENT_PROCESSED := 'Y';
           --R12 CVV2


           ELSIF (l_request_rec.request_type = OE_GLOBALS.G_BOOK_ORDER
			AND p_process_WF_requests) THEN

		IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
                   IF l_debug_level > 0 THEN
                        OE_Debug_PUB.ADD('Calling Book Order');
                   END IF;
			OE_Delayed_Requests_UTIL.Book_Order
			( p_validation_level => p_validation_level
			, p_header_id       => l_request_rec.entity_id
			, x_return_status   => l_request_rec.return_status
		  	);
                        l_request_rec.processed := 'Y';
		END IF;

           ELSIF (l_request_rec.request_type = OE_GLOBALS.G_GET_SHIP_METHOD
                  OR l_request_rec.request_type = OE_GLOBALS.G_GET_FREIGHT_RATES
                  OR l_request_rec.request_type = OE_GLOBALS.G_GET_SHIP_METHOD_AND_RATES) THEN

                  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
                        IF l_debug_level > 0 THEN
                        OE_DEBUG_PUB.Add('Calling Get Ship Method');
                        END IF;

                        -- Get_Ship_Method API not only gets ship method
                        -- from FTE, but also can get freight rates
                        -- from FTE. This API was named as Get_Ship_Method
                        -- initially for Carrier Selection, we added the
                        -- capability for Freight Rating later, and decided
                        -- to not change the API name.
                        OE_Delayed_Requests_UTIL.Get_Ship_Method
                        ( p_entity_code     => l_request_rec.entity_code
                        , p_entity_id       => l_request_rec.entity_id
                        , p_action_code     => l_request_rec.request_type
                        , x_return_status   => l_request_rec.return_status
                        );
                        l_request_rec.processed := 'Y';

                  END IF;

          ELSIF (l_request_rec.request_type = OE_GLOBALS.G_ADD_FULFILLMENT_SET OR
                 l_request_rec.request_type = OE_GLOBALS.G_REMOVE_FULFILLMENT_SET ) AND
                 l_request_rec.param5  IS NOT NULL   THEN

                 IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

                     IF l_request_rec.entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
                        OE_Delayed_Requests_UTIL.Fulfillment_Sets
                        ( p_entity_code          => l_request_rec.entity_code
                        , p_entity_id            => l_request_rec.entity_id
                        , p_action_code          => l_request_rec.request_type
                        , p_fulfillment_set_name => l_request_rec.param5
                        , x_return_status        => l_request_rec.return_status
                        );
                        l_request_rec.processed := 'Y';
                     END IF;
                 END IF;

	   ELSIF l_request_rec.request_type = OE_GLOBALS.G_DELINK_CONFIG
           THEN

		OE_Delayed_Requests_UTIL.DELINK_CONFIG
                ( p_line_id         => l_request_rec.entity_id
                 , x_return_status   => l_request_rec.return_status
                 );
                l_request_rec.processed := 'Y';

            ELSIF (l_request_rec.request_type = OE_GLOBALS.G_MATCH_AND_RESERVE
                    AND p_process_WF_requests) THEN

		OE_Delayed_Requests_UTIL.MATCH_AND_RESERVE
                ( p_line_id         => l_request_rec.entity_id
		, x_return_status   => l_request_rec.return_status
		  );
                 l_request_rec.processed := 'Y';

       ELSIF (l_request_rec.request_type = OE_GLOBALS.G_LINK_CONFIG
                  AND p_process_WF_requests)
       THEN
             OE_Config_UTIL.LINK_CONFIG
             ( p_line_id         => l_request_rec.entity_id
             , p_config_item_id  => to_number(l_request_rec.param1)
             , x_return_status   => l_request_rec.return_status	);
              l_request_rec.processed := 'Y';
	--Customer Acceptance Project actions
        ELSIF ( l_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT OR
	        l_request_rec.request_type = OE_GLOBALS.G_REJECT_FULFILLMENT) AND
                p_process_WF_requests THEN

	        OE_ACCEPTANCE_PVT.Process_Acceptance(p_request_tbl => p_x_request_tbl
					      ,x_return_status => l_return_status);

          /*** IMPORTANT ****/
	  /** This has to be the last elsif.  When adding new action requests  **/
	  /** please add above this elsif.  Since process_order_actions is now **/
	  /** called twice, this cannot be an 'else' statement to ensure that  **/
	  /** the WF requests are NOT marked invalid in the first call but     **/
	  /** processed in the second call                                     **/
       ELSIF p_process_WF_requests THEN

          IF l_request_rec.entity_code = OE_Globals.G_ENTITY_HEADER THEN
             OE_MSG_PUB.update_msg_context(
                         p_header_id   => l_request_rec.entity_id);

          ELSIF l_request_rec.entity_code = OE_Globals.G_ENTITY_LINE THEN
              OE_MSG_PUB.update_msg_context(
  	           p_line_id  	=> l_request_rec.entity_id);
          END IF;
            FND_MESSAGE.SET_NAME('ONT','ONT_INVALID_REQUEST');
            FND_MESSAGE.SET_TOKEN('ACTION',l_request_rec.request_type);
            OE_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;

	   IF l_request_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR
	   THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   ELSIF l_request_rec.return_status = FND_API.G_RET_STS_ERROR
	   THEN
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;

           IF ( l_request_rec.request_type = OE_GLOBALS.G_ACCEPT_FULFILLMENT OR
                l_request_rec.request_type = OE_GLOBALS.G_REJECT_FULFILLMENT) AND
                p_process_WF_requests THEN
                -- do not override return status set by process acceptance
                null;
           else
	        p_x_request_tbl(i) := l_request_rec;
           end if;

         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);

    EXCEPTION

   	WHEN FND_API.G_EXC_ERROR THEN
      		l_request_rec.return_status := FND_API.G_RET_STS_ERROR;
                l_request_rec.processed := 'Y';
      		p_x_request_tbl(i):= l_request_rec;
         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);

   	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      		l_request_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                l_request_rec.processed := 'Y';
      		p_x_request_tbl(i):= l_request_rec;
         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);
      		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


      	WHEN OTHERS THEN
      		l_request_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                l_request_rec.processed := 'Y';
      		p_x_request_tbl(i)		:= l_request_rec;

      	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
	 	OE_MSG_PUB.Add_Exc_Msg
	   	(   G_PKG_NAME
	       	,   'Process_Order_Actions'
	       	);
      	END IF;

         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);
      	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
     <<END_OF_LOOP>> -- Label for requests that do not need to be processed
      null;
    END LOOP;

    -- added for notification framework
    IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
   oe_order_pvt.set_recursion_mode(p_Entity_Code => 10,
                                   p_In_out  => 0);
   END IF;
   IF l_debug_level > 0 THEN
   oe_debug_pub.ADD('Exiting OE_ORDER_PUB.PROCESS_ORDER_ACTIONS', 1);
   END IF;
   OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);
        RAISE;

    WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
            OE_MSG_PUB.Add_Exc_Msg
	      (   G_PKG_NAME
		  ,   'Process_Order_Actions'
		  );
       END IF;

         OE_MSG_PUB.reset_msg_context(l_request_rec.entity_code);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Order_Actions;

-- delete_against defaulting to TRUE to prevent delete
-- of versioning requests for deletes.
-- Bug 3800577
-- Make p_entity_id an optional parameter so if it is null, delete
-- all requests for that entity code
Procedure Delete_Reqs_for_Deleted_Entity ( p_entity_code	IN Varchar2
                                        ,  p_delete_against    IN BOOLEAN := TRUE
					,   p_entity_id       in Number := NULL
, x_return_status OUT NOCOPY Varchar2)

IS
     i			       	number;
     j			       	number;
     req_ind			number;
     request_delete		BOOLEAN;
     version_request_id		number := 0;
     config_req_id	        number := 0; -- Bug 11939948
     del_option_req_id          number := 0; -- Bug 11939948
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN



   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('In Delete_Reqs_for_Deleted_Entity');
   oe_debug_pub.add('p_entity_code/p_entity_id' ||
   p_entity_code || '/' || p_entity_id);
   END IF;

-- DELETING REQUESTS LOGGED AGAINST THIS ENTITY

   i := G_Delayed_Requests.first;

   WHILE i IS NOT NULL LOOP
     IF l_debug_level > 0 THEN
     oe_debug_pub.add('G_Delayed_Requests.entity_code/entity_id' ||
                       G_Delayed_Requests(i).entity_code || '/' ||
                       G_Delayed_Requests(i).entity_id);
     oe_debug_pub.add('G_Delayed_Requests.request_type' ||
                       G_Delayed_Requests(i).request_type);

     END IF;

     IF (G_Delayed_Requests(i).request_type = OE_GLOBALS.G_VERSION_AUDIT) THEN --Bug # 5206049
	version_request_id := i;
     END IF;
     IF (G_Delayed_Requests(i).request_type = OE_GLOBALS.G_DELETE_OPTION) THEN --Bug # 11939948
	config_req_id := i;
     END IF;
     IF (G_Delayed_Requests(i).request_type = OE_GLOBALS.G_VALIDATE_CONFIGURATION) THEN --Bug # 11939948
	del_option_req_id := i;
     END IF;

     IF (G_Delayed_Requests(i).entity_code = p_entity_code
     	 AND (p_entity_id IS NULL OR
              G_Delayed_Requests(i).entity_id = p_entity_id)
        )
     THEN
	    IF l_debug_level > 0 THEN
        oe_debug_pub.add('Delete above request');
        END IF;

	-- delete records in requesting entity tables with this request
	j := G_Requesting_Entities.first;
	WHILE j IS NOT NULL LOOP
       	   IF G_Requesting_Entities(j).request_index = i THEN
 		  G_Requesting_Entities.Delete(j);
	   END IF;
     	j := G_Requesting_Entities.Next(j);
	END LOOP;

	-- delete the delayed request
	   G_Delayed_Requests.Delete(i);

     END IF;

     i := G_Delayed_Requests.Next(i);

  END LOOP;


-- DELETING REQUESTS LOGGED BY THIS ENTITY
-- DO this only if delete agains is false. If true we delete request logged
-- against the given entity.

IF NOT p_delete_against THEN
   IF l_debug_level > 0 THEN
   oe_debug_pub.add('Delete against is FALSE');
   END IF;


   i := G_Requesting_Entities.first;

   WHILE i  IS NOT NULL LOOP

   -- search for requests logged by this entity

     IF (G_Requesting_Entities(i).entity_code = p_entity_code
     	 AND (p_entity_id IS NULL OR
              G_Requesting_Entities(i).entity_id = p_entity_id)
        )
     THEN

	req_ind := G_Requesting_Entities(i).request_index;

	-- initialize request delete to TRUE
	request_delete := TRUE;

	-- set the delete to FALSE if there are other entities that
	-- logged the same request but if the same entity has logged this
	-- request, then delete in the requesting entities table

	j := G_Requesting_Entities.first;
	WHILE j IS NOT NULL LOOP
       	   IF G_Requesting_Entities(j).request_index = req_ind THEN
		IF ((G_Requesting_Entities(j).entity_code = p_entity_code
       		    AND (p_entity_id is null
                         OR G_Requesting_Entities(j).entity_id = p_entity_id)
                    )AND (G_Requesting_Entities(j).request_index <> version_request_id )   --Bug # 5206049
                          AND (G_Requesting_Entities(j).request_index <> config_req_id )   --Bug # 11939948
                          AND (G_Requesting_Entities(j).request_index <> del_option_req_id))   --Bug # 11939948
                THEN
 		  G_Requesting_Entities.Delete(j);
		ELSE
		  request_delete := FALSE;
		END IF;
	   END IF;
     	j := G_Requesting_Entities.Next(j);
	END LOOP;

	-- deleting the delayed request
	IF request_delete
           AND G_Delayed_Requests.Exists(req_ind) THEN
              IF l_debug_level > 0 THEN
              oe_debug_pub.add('Delete following request =>');
              oe_debug_pub.add('G_Delayed_Requests.entity_code/entity_id' ||
                       G_Delayed_Requests(req_ind).entity_code || '/' ||
                       G_Delayed_Requests(req_ind).entity_id);
              oe_debug_pub.add('G_Delayed_Requests.request_type' ||
                       G_Delayed_Requests(req_ind).request_type);
              END IF;
           -- Bug 3800577
           -- Reset versioning globals if version request is deleted
           IF G_Delayed_Requests(req_ind).request_type
              = OE_GLOBALS.G_VERSION_AUDIT
           THEN
              IF l_debug_level > 0 THEN
              oe_debug_pub.add('reset versioning globals');
              END IF;
              IF (NOT OE_Versioning_Util.Reset_Globals) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;
	   G_Delayed_Requests.Delete(req_ind);
	END IF;

     END IF;

     i := G_Requesting_Entities.Next(i);

  END LOOP;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   when others THEN

      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'Delete_Reqs_for_Deleted_Entity');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Delete_Reqs_for_Deleted_Entity;


/*---------------------------------------------------------------
PROCEDURE Process_Scheduling_Request
will be used for configurations scheduling requests.
----------------------------------------------------------------*/
PROCEDURE Process_Scheduling_Request
( p_request_ind    IN  NUMBER
 ,p_request_rec    IN  OE_Order_PUB.request_rec_type
,x_return_status OUT NOCOPY VARCHAR2)

IS
  I               NUMBER;
  K               NUMBER;
  l_ato_line_id   NUMBER;
  l_res_changes   VARCHAR2(1);
  l_request_tbl   OE_Order_PUB.request_tbl_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level > 0 THEN
  oe_debug_pub.add('sch request '|| p_request_rec.request_type, 1);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_request_rec.request_type = OE_GLOBALS.G_SCHEDULE_ATO THEN
    IF l_debug_level > 0 THEN
    oe_debug_pub.add('.. schedule_ato '|| p_request_rec.entity_id, 1);
    END IF;

    IF p_request_rec.param9 = 'Y' THEN
      K := p_request_ind;
      IF l_debug_level > 0 THEN
      oe_debug_pub.add('searh for duplicates '|| K, 3);
      END IF;
      WHILE K is not null
      LOOP
        IF G_Delayed_Requests(K).request_type
                 = OE_GLOBALS.G_SCHEDULE_ATO AND
           G_Delayed_Requests(K).param2 = p_request_rec.param2 AND
           G_Delayed_Requests(K).param9 = 'Y'
        THEN
          IF l_debug_level > 0 THEN
          oe_debug_pub.add('another req for same top model', 2);
          END IF;
          SELECT ato_line_id
          INTO   l_ato_line_id
          FROM   oe_order_lines
          WHERE  line_id = G_Delayed_Requests(K).entity_id;

          IF nvl(l_ato_line_id, -1) <> G_Delayed_Requests(K).entity_id THEN
             IF l_debug_level > 0 THEN
            oe_debug_pub.add('2 incorrect sch_ato req ', 3);
             END IF;
            G_Delayed_Requests.DELETE(K);
          END IF;
        END IF;
        K :=  G_Delayed_Requests.NEXT(K);
      END LOOP;
    END IF; -- pto ato non ui

    IF G_Delayed_Requests.EXISTS(p_request_ind) THEN
      OE_Config_Schedule_Pvt.Schedule_ATO
      ( p_request_rec    => p_request_rec
       ,x_return_status  => x_return_status);
    END IF;

  ELSIF p_request_rec.request_type = OE_GLOBALS.G_SCHEDULE_SMC THEN
    IF l_debug_level > 0 THEN
    oe_debug_pub.add('calling schedule_smc '||  p_request_rec.param24 , 1);
    END IF;

    OE_Config_Schedule_Pvt.Schedule_SMC
    ( p_request_rec    => p_request_rec
     ,x_return_status  => x_return_status);

  ELSIF p_request_rec.request_type = OE_GLOBALS.G_SCHEDULE_NONSMC
  THEN
    I := 0;
    K := p_request_ind;

    WHILE K is not null
    LOOP
      IF G_Delayed_Requests(K).request_type
            = OE_GLOBALS.G_SCHEDULE_NONSMC AND
         G_Delayed_Requests(K).param2 = p_request_rec.param2 AND
         G_Delayed_Requests(K).param1 = p_request_rec.param1
      THEN

        l_ato_line_id := null;

        IF G_Delayed_Requests(K).param9 = 'Y' OR OE_Config_Util.G_Config_UI_Used ='N' THEN --12597797
          SELECT ato_line_id
          INTO   l_ato_line_id
          FROM   oe_order_lines
          WHERE  line_id = G_Delayed_Requests(K).entity_id;
        END IF;

        IF l_ato_line_id is NULL THEN
          IF l_debug_level > 0 THEN
          oe_debug_pub.add('req for same model, same action', 2);
          END IF;
          I := I + 1;
          l_request_tbl(I) := G_Delayed_Requests(K);

          IF l_request_tbl(I).param24 = 'Y' THEN
            l_res_changes := 'Y';
          END IF;
        ELSE
          IF l_debug_level > 0 THEN
          oe_debug_pub.add('part of ato '|| l_ato_line_id , 3);
          END IF;
        END IF;

        G_Delayed_Requests.DELETE(K);

      END IF;
      K :=  G_Delayed_Requests.NEXT(K);
    END LOOP;
    IF l_debug_level > 0 THEN
    oe_debug_pub.add('calling schedule_nonsmc '||l_res_changes , 1);
    END IF;
    OE_Config_Schedule_Pvt.Schedule_NONSMC
    ( p_request_tbl    => l_request_tbl
     ,p_res_changes    => l_res_changes
     ,x_return_status  => x_return_status);

    ELSIF p_request_rec.request_type = OE_GLOBALS.G_DELAYED_SCHEDULE THEN
      if l_debug_level > 0 then
          oe_debug_pub.add('6663462 : calling delayed_schedule ' , 1);
      end if;

       OE_SCHEDULE_UTIL.DELAYED_SCHEDULE_LINES
       (x_return_status  => x_return_status);

  END IF;
  IF l_debug_level > 0 THEN
  oe_debug_pub.add('type----- '|| p_request_rec.request_type, 4);
  oe_debug_pub.add('leaving sch reqs '|| x_return_status, 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('Process_Scheduling_Request error '|| sqlerrm, 1);
    RAISE;
END Process_Scheduling_Request;

/*---------------------------------------------------------------
PROCEDURE Check_Pricing_Request

----------------------------------------------------------------*/
PROCEDURE Check_Pricing_Request
( p_request_ind    IN  NUMBER
 ,p_request_rec    IN  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.request_rec_type
 ,x_log_request    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS
     l_request_search_rslt1	VARCHAR2(1);
     l_request_search_rslt2	VARCHAR2(1);
     l_request_search_rslt3	VARCHAR2(1);
     l_request_search_rslt4	VARCHAR2(1);
     l_return_status		VARCHAR2(1);
     l_request_ind		NUMBER;
     l_req_entity_ind		NUMBER;
     l_request			OE_Order_PUB.REQUEST_REC_TYPE;
     l_req_entity		OE_Order_PUB.Requesting_Entity_Rec_Type;
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  /* Added the following condition to fix the fp bug 3498435 */

IF p_request_rec.request_type = OE_GLOBALS.G_PRICE_ORDER THEN


  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Entering check_pricing_request in Oe_Delayed_Request_PVT.',1);
  END IF;
  IF (p_request_rec.request_unique_key1 = 'BATCH'
      OR p_request_rec.request_unique_key1 = 'BATCH,BOOK')
     AND nvl(p_request_rec.request_unique_key2,'N') = 'Y' THEN

     IF p_request_rec.request_unique_key1 = 'BATCH' THEN
        Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH,BOOK',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt1,
                       l_return_status);
       IF l_request_search_rslt1 = FND_API.G_TRUE THEN
          -- no need to log request with BATCH and Y if
          -- 'BATCH,BOOK' and N already exists.
          x_log_request := 'N';
          return;
       ELSE
         Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt1,
                       l_return_status);
         END IF;
      ELSIF p_request_rec.request_unique_key1 = 'BATCH,BOOK' THEN
         Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH,BOOK',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt1,
                       l_return_status);

      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;

       IF l_request_search_rslt1 = FND_API.G_TRUE THEN
          -- no need to log request with BATCH and Y if BATCH
          -- and N already exists.
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('there already exists BATCH + N so no need to log pricing request.', 3);
          END IF;
          x_log_request := 'N';

       ELSE
         IF p_request_rec.request_unique_key1 = 'BATCH' THEN
            -- check if there already exists request with
            -- pricing event 'ORDER' with get_freight_flag = 'N'.
            Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'ORDER',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt2,
                       l_return_status);
         ELSIF p_request_rec.request_unique_key1 = 'BATCH,BOOK' THEN
            Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'ORDER,BOOK',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt2,
                       l_return_status);

         END IF;


       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_search_rslt2 = FND_API.G_TRUE THEN
          -- check if there already exists request with
          -- pricing event 'LINE' with get_freight_flag = 'Y'.
          -- If exists, do nothing.
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('there already exists request with ORDER + N.',3);
          END IF;
          Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'LINE',
                       'Y',
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt3,
                       l_return_status);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_request_search_rslt3 = FND_API.G_TRUE THEN
             -- If not exists, replace BATCH event with LINE event
             -- since request with 'ORDER' event already exists.
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('there exists LINE + Y and ORDER + N so no need to log request for BATCH + Y.', 3);
             END IF;
             x_log_request := 'N';
          ELSE
             -- if l_request_search_rslt3 = FND_API.G_FALSE THEN
             -- check for LINE and N.
             Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'LINE',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt4,
                       l_return_status);
             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;


             IF l_request_search_rslt4 = FND_API.G_TRUE THEN
                -- if already exists request with LINE and N.
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('there exists LINE + N and ORDER + N so no need to log request for BATCH + Y.', 3);
                END IF;
                x_log_request := 'N';

             ELSE
               --  p_request_rec.request_unique_key1 := 'LINE';
               -- replace event BATCH with LINE.
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('replace BATCH event with LINE + Y and ORDER + N.', 3);
               END IF;
               p_request_rec.param2 := 'LINE';
               p_request_rec.request_unique_key1 := 'LINE';
               p_request_rec.request_unique_key2 := 'Y';
             END IF;
          END IF;  -- end of l_request_search_rslt3.


        END IF;  -- end of l_request_search_rslt2
      END IF;  -- end of l_request_search_rslt1

  ELSIF p_request_rec.request_unique_key1 = 'ORDER'
        AND nvl(p_request_rec.request_unique_key2,'N') = 'N' THEN
        Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt1,
                       l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_search_rslt1 = FND_API.G_TRUE THEN
         -- if l_request_search_rslt1 = FND_API.G_TRUE
         -- request with event 'BATCH' and get_freight_flag ='N'
         -- exists, don't need to log request.
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('there exists BATCH + N so no need to log request.', 3);
         END IF;
         x_log_request := 'N';
       ELSE
          -- if l_request_search_rslt1 = FND_API.G_FALSE
          -- request with event 'BATCH' and get_freight_flag ='N'
          -- does not exist.
          Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH',
                       'Y',
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt2,
                       l_return_status);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_request_search_rslt2 = FND_API.G_TRUE THEN

            -- there exists request with BATCH+Y already.
            -- need to delete BATCH+Y, log the current request which is
            -- ORDER+N and log an additional request LINE+Y.
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('need to have two separate requests ORDER + N and LINE + Y',3);
            END IF;
            delete_request(p_entity_code         => p_request_rec.entity_code,
                           p_entity_id           => p_request_rec.entity_id,
                           p_request_type        => p_request_rec.request_type,
                           p_request_unique_key1 => 'BATCH',
                           p_request_unique_key2 => 'Y',
                           x_return_status       => l_return_status);

            log_request(p_entity_code  => OE_GLOBALS.G_ENTITY_ALL,
         	       p_entity_id         	=> p_request_rec.entity_id,
		       p_requesting_entity_code => p_request_rec.entity_code,
		       p_requesting_entity_id   => p_request_rec.entity_id,
		       p_request_unique_key1  	=> 'LINE',
		       p_request_unique_key2  	=> 'Y',
		       p_param1                 => p_request_rec.entity_id,
                       p_param2                 => 'LINE',
		       p_request_type           => p_request_rec.request_type,
		       x_return_status          => l_return_status);

          END IF;

        END IF; -- enf of l_request_search_rslt1.
  ELSIF p_request_rec.request_unique_key1 = 'BATCH'
        AND nvl(p_request_rec.request_unique_key2,'N') = 'N'
        OR  p_request_rec.request_unique_key1 = 'BATCH,BOOK'
        AND nvl(p_request_rec.request_unique_key2,'N') = 'N' THEN
        -- delete all other request for G_PRICE_ORDER.
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('delete all other price_order request.',1);
        END IF;
        delete_request(p_entity_code   =>OE_GLOBALS.G_ENTITY_ALL,
                       p_entity_id     => p_request_rec.entity_id,
                       p_request_type  => p_request_rec.request_type,
                       p_request_unique_key1 => 'ORDER',
                       x_return_status => l_return_status);
        delete_request(p_entity_code   =>OE_GLOBALS.G_ENTITY_ALL,
                       p_entity_id     => p_request_rec.entity_id,
                       p_request_type  => p_request_rec.request_type,
                       p_request_unique_key1 => 'BATCH',
                       x_return_status => l_return_status);
      IF p_request_rec.request_unique_key1 = 'BATCH,BOOK'
        AND nvl(p_request_rec.request_unique_key2,'N') = 'N' THEN
        -- event is 'BATCH,BOOK'
        delete_request(p_entity_code   =>OE_GLOBALS.G_ENTITY_ALL,
                       p_entity_id     => p_request_rec.entity_id,
                       p_request_type  => p_request_rec.request_type,
                       p_request_unique_key1 => 'ORDER,BOOK',
                       x_return_status => l_return_status);
        delete_request(p_entity_code   =>OE_GLOBALS.G_ENTITY_ALL,
                       p_entity_id     => p_request_rec.entity_id,
                       p_request_type  => p_request_rec.request_type,
                       p_request_unique_key1 => 'BATCH,BOOK',
                       x_return_status => l_return_status);
      END IF;

  ELSIF p_request_rec.request_unique_key1 = 'ORDER,BOOK'
        AND nvl(p_request_rec.request_unique_key2,'N') = 'N' THEN
     Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH,BOOK',
                       NULL,
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt1,
                       l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_search_rslt1 = FND_API.G_TRUE THEN
          -- request with event 'BATCH' and get_freight_flag ='N'
          -- already exists, no need to log request.
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('there exists BATCH + N so no need to log request.', 3);
         END IF;
         x_log_request := 'N';
       ELSE
          -- l_request_search_rslt1 = FND_API.G_FALSE
          -- request with event 'BATCH' and get_freight_flag ='N'
          -- does not exist.
          Check_For_Request(p_request_rec.entity_code,
                       p_request_rec.entity_id,
                       p_request_rec.request_type,
                       'BATCH,BOOK',
                       'Y',
                       p_request_rec.request_unique_key3,
                       p_request_rec.request_unique_key4,
                       p_request_rec.request_unique_key5,
                       l_request_ind,
                       l_request_search_rslt2,
                       l_return_status);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF l_request_search_rslt2 = FND_API.G_TRUE THEN

            -- there exists request with BATCH,BOOK+Y already.
            -- need to delete BATCH,BOOK+Y, log the current request which is
            -- ORDER,BOOK+N and log an additional request LINE+Y.
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('need to have two separate requests ORDER,BOOK + N and LINE + Y and delete BATCH,BOOK + Y',1);
            END IF;
            delete_request(p_entity_code     => p_request_rec.entity_code,
                       p_entity_id           => p_request_rec.entity_id,
                       p_request_type        => p_request_rec.request_type,
                       p_request_unique_key1 => 'BATCH,BOOK',
                       p_request_unique_key2 => 'Y',
                       x_return_status       => l_return_status);

           log_request(p_entity_code  => OE_GLOBALS.G_ENTITY_ALL,
         	       p_entity_id         	=> p_request_rec.entity_id,
		       p_requesting_entity_code => p_request_rec.entity_code,
		       p_requesting_entity_id   => p_request_rec.entity_id,
		       p_request_unique_key1  	=> 'LINE',
		       p_request_unique_key2  	=> 'Y',
		       p_param1                 => p_request_rec.entity_id,
                       p_param2                 => 'LINE',
		       p_request_type           => p_request_rec.request_type,
		       x_return_status          => l_return_status);

          END IF;

        END IF;

  END IF;

  /* New code added to fix the fp bug 3498435 */
ELSIF p_request_rec.request_type = OE_GLOBALS.G_PRICE_LINE  THEN
     IF l_debug_level > 0 THEN
     oe_debug_pub.add('3498435: Entering check_pricing_request '||p_request_rec.request_unique_key1,1);
     END IF;
       IF p_request_rec.request_unique_key1 = 'LINE' THEN
            Check_For_Request(p_request_rec.entity_code,
                           p_request_rec.entity_id,
                           p_request_rec.request_type,
                           'BATCH',
                           NULL,
                           p_request_rec.request_unique_key3,
                           p_request_rec.request_unique_key4,
                           p_request_rec.request_unique_key5,
                           l_request_ind,
                           l_request_search_rslt1,
                           l_return_status);
           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF l_request_search_rslt1 = FND_API.G_TRUE THEN
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('there exists BATCH + N so no need to log request.', 3);
             END IF;
             x_log_request := 'N';
           ELSE
                          IF l_debug_level  > 0 THEN
                          oe_debug_pub.add('3498435: Search result is false ',1);
                          END IF;
                          Check_For_Request(p_request_rec.entity_code,
                           p_request_rec.entity_id,
                           p_request_rec.request_type,
                           'BATCH,BOOK',
                           NULL,
                           p_request_rec.request_unique_key3,
                           p_request_rec.request_unique_key4,
                           p_request_rec.request_unique_key5,
                           l_request_ind,
                           l_request_search_rslt2,
                           l_return_status);
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF l_request_search_rslt2 = FND_API.G_TRUE THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('there exists BATCH,BOOK + N so no need to log request.', 3);
                  END IF;
                  x_log_request := 'N';
                END IF; --l_request_search_rslt2
           END IF; --l_request_search_rslt1
       ELSIF (nvl(p_request_rec.request_unique_key1,p_request_rec.param2) = 'BATCH'
          OR  nvl(p_request_rec.request_unique_key1,p_request_rec.param2) = 'BATCH,BOOK') THEN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Delete Line',3);
                END IF;
                delete_request(p_entity_code         => p_request_rec.entity_code,
                               p_entity_id           => p_request_rec.entity_id,
                               p_request_type        => p_request_rec.request_type,
                               p_request_unique_key1 => 'LINE',
                               p_request_unique_key2 => NULL,
                               x_return_status       => l_return_status);
       END IF; --p_request_rec.request_unique_key1 check
    END IF;  --Price order or price line check


/* End of New code added to fix the fp bug 3498435   */


  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Exiting procedure OE_Delayed_Requests_Pvt.Check_Pricing_Request', 1);
  END IF;

END Check_Pricing_Request;

END OE_Delayed_Requests_Pvt;

/
