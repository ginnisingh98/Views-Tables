--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_CANCEL_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_CANCEL_LINE" AS
/* $Header: OEXFCANB.pls 120.3 2005/08/30 13:03:19 rbellamk ship $ */


--  Start of Comments
--  API name    OE_OE_FORM_CANCEL_LINE
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
g_line_rec                    OE_Order_PUB.Line_Rec_Type;
g_db_line_rec                 OE_Order_PUB.Line_Rec_Type;
FUNCTION Get_line
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
)
RETURN OE_Order_PUB.Line_Rec_Type;

Procedure Process_cancel_quantity
(    p_num_of_records       IN NUMBER
    ,p_record_ids           IN OE_GLOBALS.Selected_Record_Tbl -- MOAC
    ,p_cancel_to_quantity   IN NUMBER
    ,p_cancellation_comments IN VARCHAR2
    ,p_reason_code          IN VARCHAR2
    ,p_cancellation_type    IN VARCHAR2
    ,p_mc_err_handling_flag IN NUMBER := FND_API.G_MISS_NUM
,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

,x_return_status OUT NOCOPY VARCHAR2

,x_error_count OUT NOCOPY NUMBER

) IS
l_line_rec            OE_ORDER_PUB.line_rec_type;
l_control_rec         OE_GLOBALS.Control_Rec_Type;
l_line_tbl            OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl        OE_ORDER_PUB.Line_Tbl_Type;
l_api_name            CONSTANT VARCHAR2(30) := 'Process_Cancel_quantity';
l_line_id             NUMBER;
l_return_status       VARCHAR2(30);
l_error_count         NUMBER :=0;
l_ordered_quantity    NUMBER ;
l_ordered_quantity2   NUMBER ; /* OPM change. NC - 03/30/01. Bug#1651766 */
j                     Integer;
initial               Integer;
nextpos               Integer;

/* B:Included for bug# 2233213 */
t_line_id             NUMBER;
m                     Integer;
initialval            Integer;
nextposval            Integer;
set_flag              VARCHAR2(1) := 'N';
/* E:Included for bug# 2233213 */

l_record_ids          OE_GLOBALS.Selected_Record_Tbl := p_record_ids ;
l_num_of_records      NUMBER;
l_cancel_to_quantity  NUMBER := p_cancel_to_quantity ;
l_prg_line_id         NUMBER;

cursor prg_parent(c_line_id number)
is
select opa1.line_id
from   oe_price_adjustments opa1,
       oe_price_adjustments opa2,
       oe_price_adj_assocs opaa
where  opa1.list_line_type_code = 'PRG'
and    opa1.price_adjustment_id = opaa.price_adjustment_id
and    opa2.price_adjustment_id = opaa.rltd_price_adj_id
and    opa2.line_id             = c_line_id;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_orgid number;
l_skip_process varchar2(1) := 'N';
l_header_id number;
l_tblcount number := 0;
--
BEGIN
x_return_status := fnd_api.g_ret_sts_success;
g_record_ids := l_record_ids;   -- Added For bug#2965878
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTER PROCEDURE PROCESS CANCEL QTY' , 1 ) ;
  END IF;
  oe_msg_pub.initialize;
  x_error_count := l_error_count;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' NO. OF RECORDS: '||TO_CHAR ( P_NUM_OF_RECORDS ) , 1 ) ;
  END IF;

 /* Not needed with MOAC
 j := 1.0;
  initial := 1.0;
  nextpos := INSTR(l_record_ids,',',1,j) ;
 */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'POS'||TO_CHAR ( NEXTPOS ) , 1 ) ;
  END IF;
  l_num_of_records := p_num_of_records;
 g_num_of_records := l_num_of_records;  -- Added For bug#2965878

  l_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
  l_old_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;

  SAVEPOINT Process_cancel_quantity;

   	IF l_orgid is null  THEN
		l_orgid := l_record_ids(1).Org_Id;

  IF l_debug_level  > 0 THEN
oe_debug_pub.add(  ' ORG ID: '||TO_CHAR ( l_orgid ) , 1 ) ;
  END IF;

 Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                               p_org_id      => l_record_ids(1).Org_Id);

	END IF;

  FOR i IN 1..l_num_of_records LOOP

    --OE_DEBUG_PUB.Add('Number Of records'||to_char(l_num_of_records),1);
    --dbms_output.put_line('ini='||to_char(initial)||'next='||to_char(nextpos));

		if l_header_id is null then
			l_header_id := l_record_ids(i).id2;
		elsif l_header_id <> l_record_ids(i).id2 THEN
			IF l_line_tbl.count <> 0 THEN
  IF l_debug_level  > 0 THEN
oe_debug_pub.add(  ' Header ID: '||TO_CHAR ( l_header_id ) , 1 ) ;
  END IF;

			Call_Process_Order (p_line_tbl => l_line_tbl,
				p_old_line_tbl => l_old_line_tbl,
			    x_return_status => l_return_status);

			END IF;

    		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;
				l_header_id := l_record_ids(i).id2;
				l_line_tbl.delete;
				l_tblcount := 0;
				l_old_line_tbl.delete;
		end if; -- end if l header id

   	IF l_record_ids(i).org_id <> l_orgid THEN
		l_orgid := l_record_ids(i).Org_Id;
  IF l_debug_level  > 0 THEN
oe_debug_pub.add(  ' ORG ID Change: '||TO_CHAR ( l_orgid ) , 1 ) ;
  END IF;

 Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                               p_org_id      => l_record_ids(i).Org_Id);

	END IF;

	l_line_id := l_record_ids(i).id1;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE ID: '||TO_CHAR ( L_LINE_ID ) , 1 ) ;
    END IF;

/* Not needed with MOAC changes
    initial := nextpos + 1.0;
    j := j + 1.0;
    nextpos := INSTR(l_record_ids,',',1,j) ;
*/

    OE_LINE_UTIL.Lock_Row
    (   p_line_id       => l_line_id,
	p_x_line_rec    => l_line_rec,
	x_return_status => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_line_rec.split_action_code = FND_API.G_MISS_CHAR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SPLIT ACTION CODE MISSING' , 1 ) ;
      END IF;
    ELSIF l_line_rec.split_action_code IS NULL THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SPLIT ACTION CODE NULL' , 1 ) ;
      END IF;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SPLIT ACTION CODE '||L_LINE_REC.SPLIT_ACTION_CODE , 1 ) ;
      END IF;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CATEGORY: '||L_LINE_REC.LINE_CATEGORY_CODE , 1 ) ;
    END IF;

    l_ordered_quantity := l_line_rec.ordered_quantity;
    /* OPM change. NC - 03/30/01. Bug#1651766 */
    l_ordered_quantity2 := l_line_rec.ordered_quantity2;

    if (l_ordered_quantity = 0 or l_line_rec.cancelled_flag = 'Y') then
      fnd_message.set_name('ONT', 'OE_CANCEL_NOTHING');
      oe_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR ;
    end if;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'LINE ID '||TO_CHAR ( L_LINE_REC.LINE_ID ) || ' , ORD QTY '||TO_CHAR ( L_LINE_REC.ORDERED_QUANTITY ) || ' , CANCEL TYPE '|| P_CANCELLATION_TYPE , 1 ) ;
                     END IF;

    /* Begin:Included for bug# 2233213 */
    IF l_line_rec.item_type_code = OE_Globals.G_ITEM_SERVICE AND
       l_line_rec.service_reference_type_code = 'ORDER' THEN

     /* Not needed with MOAC changes  m := 1.0;
      initialval := 1.0;
      nextposval := INSTR(l_record_ids,',',1,m) ; */
      set_flag := 'N';

      for n in 1..l_num_of_records loop
        t_line_id := l_record_ids(n).id1;
/* Not needed with MOAC changes
        initialval := nextposval + 1.0;
        m := m + 1.0;
        nextposval := INSTR(l_record_ids,',',1,m) ;
*/

        if l_line_rec.service_reference_line_id = t_line_id then
          set_flag := 'Y';
          exit;
        end if;
      end loop;

      IF set_flag = 'Y' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SKIP , PARENT OF THIS SERVICE LINE IS SELECTED FOR CANCELLATION' ) ;
        END IF;
        goto  end_loop;
      END IF;
    END IF;
    /* End:Included for bug# 2233213 */

    /* Fix for bug # 2387919 */
    set_flag := 'N';
    for prg_parent_rec in prg_parent(l_line_rec.line_id) loop
      IF set_flag = 'Y' THEN
        exit;
      end if;

 /* Not required for MOAC
     m := 1.0;
      initialval := 1.0;
      nextposval := INSTR(l_record_ids,',',1,m) ; */

      for n in 1..l_num_of_records loop
        t_line_id := l_record_ids(n).id1;
/* Not required with MOAC changes
        initialval:= nextposval + 1.0;
        m := m + 1.0;
        nextposval := INSTR(l_record_ids,',',1,m) ;
*/

        if prg_parent_rec.line_id = t_line_id then
          set_flag := 'Y';
          exit;
        end if;
      end loop;
    end loop;

    IF set_flag = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SKIP , THIS IS A PROMOTIONAL LINE' ) ;
      END IF;
      goto  end_loop;
    END IF;

    --l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
		IF l_tblcount = 0 THEN
			l_tblcount := 1;
		END IF;
    l_line_tbl(l_tblcount) := l_line_rec;
    -- l_old_line_tbl(l_tblcount) := l_line_rec;
    -- l_line_tbl(1).line_id := l_line_id;
    l_old_line_tbl(l_tblcount) := l_line_rec;
    l_line_tbl(l_tblcount).operation := OE_GLOBALS.G_OPR_UPDATE;
    l_ordered_quantity := 0;
    l_line_tbl(l_tblcount).ordered_quantity :=l_ordered_quantity;

    /* OPM change. NC - 03/30/01. Bug#1651766 */
    IF(l_ordered_quantity2 IS NOT NULL AND l_ordered_quantity2 <> 0 ) THEN
      l_ordered_quantity2 := 0;
      l_line_tbl(1).ordered_quantity2 := l_ordered_quantity2;
    END IF;
    /* End OPM change */

    l_line_tbl(l_tblcount).change_reason :=p_reason_code;
    l_line_tbl(l_tblcount).change_comments :=p_cancellation_comments;
	l_tblcount := l_tblcount + 1;

    /* Included for bug# 2233213 */
    <<end_loop>>
    null;

  END LOOP;

  --  Call OE_Order_PVT.Process_order for last set of rows

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING PROCESSS ORDER LINES PROCEDURE' , 1 ) ;
  END IF;


			IF l_line_tbl.count <> 0 THEN

			Call_Process_Order (p_line_tbl => l_line_tbl,
				p_old_line_tbl => l_old_line_tbl,
			    x_return_status => l_return_status);

			END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING LINES PROCEDURE' , 1 ) ;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING PROCESSE for last set' , 1 ) ;
  END IF;

  OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

  x_return_status  := l_return_status;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INTO CANCELATION UNEXPECTED FAILURE' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INTO CANCELLATION EXPECTED FAILURE' ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  L_RETURN_STATUS ) ;
  END IF;

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
       ROLLBACK TO SAVEPOINT Process_cancel_quantity;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
	ROLLBACK TO SAVEPOINT Process_cancel_quantity;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
       ROLLBACK TO SAVEPOINT Process_cancel_quantity;

end Process_cancel_quantity;

Procedure Process_cancel_order
(    p_num_of_records       IN NUMBER
    ,p_record_ids           IN OE_GLOBALS.Selected_Record_Tbl -- MOAC
    ,p_cancellation_comments IN VARCHAR2
    ,p_reason_code          IN VARCHAR2
    ,p_mc_err_handling_flag IN NUMBER := FND_API.G_MISS_NUM
,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

,x_return_status OUT NOCOPY VARCHAR2

,x_error_count OUT NOCOPY NUMBER

) IS
l_header_rec                OE_ORDER_PUB.Header_Rec_Type;
l_line_rec                OE_ORDER_PUB.line_rec_type;
l_old_header_rec            OE_ORDER_PUB.Header_Rec_Type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_api_name         CONSTANT VARCHAR2(30)         := 'Process_Cancel_Order';
l_header_id         Number;
l_return_status             VARCHAR2(30);
l_error_count   NUMBER :=0;
l_ordered_quantity NUMBER ;
j Integer;
initial Integer;
nextpos Integer;
l_record_ids  OE_GLOBALS.Selected_Record_Tbl := p_record_ids ;
l_num_of_records number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_orgid number;
--
BEGIN
	oe_msg_pub.initialize;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCEDURE PROCESS_CANCEL_ORDER' , 1 ) ;
     END IF;
 l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
 l_old_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
 l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;   --OE.G_OPR_UPDATE;
 x_error_count := l_error_count;
 g_ord_lvl_can := TRUE; --Fix for bug# 2922468.
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'No of IDS'||TO_CHAR ( P_NUM_OF_RECORDS ) , 1 ) ;
  END IF;
/* Not required with MOAC changes
         j := 1.0;
         initial := 1.0;
         nextpos := INSTR(l_record_ids,',',1,j) ;
*/

l_num_of_records := p_num_of_records;


FOR i IN 1..l_num_of_records LOOP
 SAVEPOINT Process_cancel_order;


 l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
 l_old_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
   	IF l_orgid is null OR l_record_ids(i).org_id <> l_orgid THEN
		l_orgid := l_record_ids(i).Org_Id;

 Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                               p_org_id      => l_record_ids(i).Org_Id);

	END IF;

 l_header_id := l_record_ids(i).id1;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'INSTR'||TO_CHAR ( L_HEADER_ID ) , 1 ) ;
END IF;
/* not required with MOAC changes
 initial := nextpos + 1.0;
 j := j + 1.0;
 nextpos := INSTR(l_record_ids,',',1,j) ;
*/

 OE_Header_Util.lock_Row
        (   p_header_id                   => l_header_id,
		  p_x_header_rec                  => l_header_rec
		   ,x_return_status => l_return_status
        );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

l_old_header_rec := l_header_rec;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CANCELLED FLAG'||L_HEADER_REC.CANCELLED_FLAG , 1 ) ;
END IF;
IF l_header_rec.cancelled_flag = 'Y' THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CANCELLED FLAG'||L_HEADER_REC.CANCELLED_FLAG , 1 ) ;
END IF;
                fnd_message.set_name('ONT', 'OE_CAN_ORDER_CANCEL_ALREADY');
                 FND_MESSAGE.SET_TOKEN('ORDER',
                                   L_header_rec.Order_Number);


                oe_msg_pub.Add;
          	RAISE FND_API.G_EXC_ERROR ;
END IF;
IF nvl(l_header_rec.open_flag,'N') = 'N' THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CANCELLED FLAG'||L_HEADER_REC.CANCELLED_FLAG , 1 ) ;
END IF;
                fnd_message.set_name('ONT', 'OE_CAN_ORDER_CLOSED');
                 FND_MESSAGE.SET_TOKEN('ORDER',
                                   L_header_rec.Order_Number);
                oe_msg_pub.Add;
          	RAISE FND_API.G_EXC_ERROR ;
END IF;

  l_header_rec.cancelled_flag :='Y';
  l_header_rec.change_reason :=p_reason_code;
 l_header_rec.change_comments :=p_cancellation_comments;
 l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

	oe_order_pvt.Header
(   p_validation_level               =>    FND_API.G_VALID_LEVEL_NONE
,   p_control_rec                   => l_control_rec
,   p_x_header_rec                    =>  l_header_rec
,   p_x_old_header_rec                => l_old_header_rec
,   x_return_status     => l_return_status

);

        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );


IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
 END IF;


-- Api to call notify OC and Process Delayed Requests

     OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => TRUE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_header_rec                => l_header_rec
          , p_old_header_rec            => l_old_header_rec
          );




x_return_status  := l_return_status;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  L_RETURN_STATUS ) ;
     END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'CANCELLATION UNEXPECTED FAILURE' ) ;
               END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'CANCELLATION EXPECTED FAILURE' ) ;
               END IF;
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


End LOOP; /* end of FOR loop */

g_ord_lvl_can := FALSE; --For fix bug# 2922468.

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
       g_ord_lvl_can := FALSE; --For fix bug# 2922468.
       ROLLBACK TO SAVEPOINT Process_cancel_order;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
g_ord_lvl_can:=FALSE; --Fix for bug# 2922468.
ROLLBACK TO SAVEPOINT Process_cancel_order;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
       g_ord_lvl_can := FALSE; --Fix for bug# 2922468.
       ROLLBACK TO SAVEPOINT Process_cancel_order;


end Process_cancel_order;



FUNCTION Get_line
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
)
RETURN OE_Order_PUB.Line_Rec_Type
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_CANCEL_LINE.GET_LINE' , 1 ) ;
    END IF;

    IF  p_line_id <> g_line_rec.line_id
    THEN

        --  Query row from DB

         OE_Line_Util.Query_Row
        (   p_line_id                     => p_line_id,
		  x_line_rec                    => g_line_rec
        );
        g_line_rec.db_flag             := FND_API.G_TRUE;

        --  Load DB record


        g_db_line_rec                  := g_line_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.GET_LINE' , 1 ) ;
    END IF;

    IF p_db_record THEN

        RETURN g_db_line_rec;

    ELSE

        RETURN g_line_rec;

    END IF;

END Get_Line;

-- Fix for bug 2259556.This procedure is now coded to take care of mass order cancellation.
Procedure Cancel_Remaining_Order(p_num_of_records IN NUMBER,
                  p_record_ids IN OE_GLOBALS.Selected_Record_Tbl, --MOAC
x_return_status OUT NOCOPY VARCHAR2,

                    p_cancellation_comments IN VARCHAR2,
                    p_reason_code          IN VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2)IS

l_header_rec OE_ORDER_PUB.header_rec_type :=
		oe_order_pub.g_miss_header_rec;
l_api_name varchar2(30) := 'Cancel Remaining Order';
l_header_id         Number;
j Integer;
initial Integer;
nextpos Integer;
l_record_ids  OE_GLOBALS.Selected_Record_Tbl := p_record_ids ;
l_num_of_records number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

l_orgid number;
BEGIN
         l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'num of IDS '||TO_CHAR ( P_NUM_OF_RECORDS ) , 1 ) ;
END IF;
/* Not required with MOAC changes
         j := 1.0;
         initial := 1.0;
         nextpos := INSTR(l_record_ids,',',1,j) ;
*/
         l_num_of_records := p_num_of_records;
FOR i IN 1..l_num_of_records LOOP
        SAVEPOINT Cancel_Remaining_Order;
 l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
   	IF l_orgid is null OR l_record_ids(i).org_id <> l_orgid THEN
		l_orgid := l_record_ids(i).Org_Id;

 Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                               p_org_id      => l_record_ids(i).Org_Id);

	END IF;

 l_header_id := l_record_ids(i).id1;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'INSTR'||TO_CHAR ( L_HEADER_ID ) , 1 ) ;
 END IF;

/* Not required with MOAC changes
 initial := nextpos + 1.0;
 j := j + 1.0;
 nextpos := INSTR(l_record_ids,',',1,j) ;
*/

         OE_Header_Util.Query_Row
        (   p_header_id                   => l_header_id,
            x_header_rec                  =>l_header_rec
        );

		 l_header_rec.change_reason := p_reason_code;
		l_header_rec.change_comments := p_cancellation_comments;

oe_sales_can_util.Cancel_Remaining_Order
    (p_header_rec        => l_header_rec,
     p_header_id         => l_header_id
,   x_return_status      => x_return_status
);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INTO CANCELATION UNEXPECTED FAILURE' ) ;
               END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INTO CANCELLATION EXPECTED FAILURE' ) ;
               END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

         /* Fix Bug # 3000720: If there is an error, everything must rollback */
         RAISE FND_API.G_EXC_ERROR;
       END IF;

END LOOP;

EXCEPTION  /* Procedure exception handler */

WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT Cancel_Remaining_Order;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
       ROLLBACK TO SAVEPOINT Cancel_Remaining_Order;

END cancel_remaining_order;

Procedure Call_Process_Order ( p_line_tbl IN OE_ORDER_PUB.LINE_TBL_TYPE,
			       p_old_line_tbl IN OE_ORDER_PUB.LINE_TBL_TYPE,
				x_return_status  OUT NOCOPY VARCHAR2)
IS

l_line_tbl OE_ORDER_PUB.LINE_TBL_TYPE := p_line_tbl;
l_old_line_tbl OE_ORDER_PUB.LINE_TBL_TYPE := p_old_line_tbl;
x_msg_count number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
x_msg_data varchar2(32000);
l_control_rec         OE_GLOBALS.Control_Rec_Type;
l_api_name            CONSTANT VARCHAR2(30) := 'Call_Process_Order';
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING PROCESSS ORDER LINES PROCEDURE' , 1 ) ;
  END IF;

		x_return_status := FND_API.G_RET_STS_SUCCESS;


  --  Call OE_Order_PVT.Process_order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING PROCESS ORDER' , 1 ) ;
  END IF;
      oe_order_pvt.Lines
  (   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
  ,   p_control_rec       => l_control_rec
  ,   p_x_line_tbl         =>  l_line_tbl
  ,   p_x_old_line_tbl    =>  l_old_line_tbl
  ,   x_return_status     => x_return_status
  );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING LINES PROCEDURE' , 1 ) ;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => TRUE
          , p_notify                    => TRUE
          , x_return_status             => x_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING PROCESSE' , 1 ) ;
  END IF;

  OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

  x_return_status  := x_return_status;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INTO CANCELATION UNEXPECTED FAILURE' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INTO CANCELLATION EXPECTED FAILURE' ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  x_RETURN_STATUS ) ;
  END IF;

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);

END Call_Process_Order;

END OE_OE_FORM_CANCEL_LINE;

/
