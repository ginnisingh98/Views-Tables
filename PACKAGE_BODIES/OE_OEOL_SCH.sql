--------------------------------------------------------
--  DDL for Package Body OE_OEOL_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OEOL_SCH" AS
/* $Header: OEXWSCHB.pls 120.12.12010000.2 2009/08/13 08:12:11 rmoharan ship $ */

PROCEDURE Bulk_Mode_Copy_Sch_Attribs
(p_line_rec    IN OUT NOCOPY  OE_Order_Pub.Line_Rec_Type);

-- Chache Values
sch_cached_line_id              NUMBER ;
sch_cached_sch_status_code      VARCHAR2(30);
-- Bug 3083995
sch_elg_cached_line_id          NUMBER;
sch_cached_elg_status           VARCHAR2(8);
sch_cached_source_type_code     VARCHAR2(30); -- Added for bug 5880264
--
g_skip_check                    BOOLEAN :=FALSE; -- 3565621
g_top_model_line_id             NUMBER := NULL; -- 3565621


/*---------------------------------------------
Function : Is_Scheduling_Eligible
---------------------------------------------*/

FUNCTION Is_Scheduling_Eligible(p_line_id IN NUMBER)
RETURN BOOLEAN
IS
   l_activity_status  VARCHAR2(8) := null;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING IS_SCHEDULING_ELIGIBLE: ' || P_LINE_ID , 1 ) ;
   END IF;
   IF NOT OE_GLOBALS.Equal(p_line_id,
                           sch_elg_cached_line_id)
   THEN
      SELECT ACTIVITY_STATUS
      INTO l_activity_status
      FROM wf_item_activity_statuses wias, wf_process_activities wpa
      WHERE wias.item_type = 'OEOL'
      AND wias.item_key  = to_char(p_line_id)
      AND wias.process_activity = wpa.instance_id
      AND wpa.ACTIVITY_ITEM_TYPE = 'OEOL'
      AND wpa.activity_name = 'SCHEDULING_ELIGIBLE'
      AND wias.activity_status = 'NOTIFIED';

      sch_elg_cached_line_id   := p_line_id;
      sch_cached_elg_status := l_activity_status;
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING IS_SCHEDULING_ELIGIBLE ' , 1 ) ;
   END IF;

   IF sch_cached_elg_status = 'NOTIFIED'
   THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Line is in schedule Eligible stage ' , 1 ) ;
      END IF;
      RETURN TRUE;
   ELSE
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Line is not in schedule Eligible stage' , 1 ) ;
       END IF;
      RETURN FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN EXCEPTION OF IS_SCHEDULING_ELIGIBLE' , 1 ) ;
     END IF;
     RETURN FALSE;
END Is_Scheduling_Eligible;

/*---------------------------------------------
Function : Is_Line_Scheduled
---------------------------------------------*/

FUNCTION Is_Line_Scheduled(p_line_id IN NUMBER)
RETURN BOOLEAN
IS
   l_schedule_status_code  VARCHAR2(30) := null;
   l_source_type_code VARCHAR2(30) := null; -- Added for bug 5880264
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING IS_LINE_SCHEDULED: ' || P_LINE_ID , 1 ) ;
   END IF;
   IF NOT OE_GLOBALS.Equal(p_line_id,
                           sch_cached_line_id)
   THEN

      -- Added source_type_code in the below query for bug 5880264
      SELECT schedule_status_code, source_type_code
      INTO  l_schedule_status_code, l_source_type_code
      FROM oe_order_lines_all
      WHERE line_id = p_line_id;


      sch_cached_line_id   := p_line_id;
      sch_cached_sch_status_code := l_schedule_status_code;
      sch_cached_source_type_code := l_source_type_code; -- Added for bug 5880264
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING IS_LINE_SCHEDULED ' , 1 ) ;
   END IF;

   -- Added source_type_code condition in the below IF for bug 5880264
   IF sch_cached_sch_status_code IS NOT NULL OR sch_cached_source_type_code = 'EXTERNAL'
   THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Line is scheduled  ' , 1 ) ;
      END IF;
      RETURN TRUE;
   ELSE
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Line is not scheduled ' , 1 ) ;
       END IF;
      RETURN FALSE;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN EXCEPTION OF IS_LINE_SCHEDULED' , 1 ) ;
     END IF;
     RETURN FALSE;

END Is_Line_Scheduled;

/*--------------------------------------------------------
Procedure Process_Child_Lines

Modfied the signature of the procedure to fix bug 3319120
--------------------------------------------------------*/

PROCEDURE Process_Child_Lines(p_line_id  IN NUMBER,
                              p_top_model_line_id IN NUMBER,
                              p_ato_line_id IN NUMBER,
                              p_item_type_code IN VARCHAR2,
                              p_ship_model_complete_flag IN VARCHAR2)
IS
  TYPE lines_ref_type IS REF CURSOR;
  l_ref_cur_line_id  lines_ref_type;
  l_stmt             VARCHAR2(1000);
  l_where_clause     VARCHAR2(200) := NULL;
  l_line_id          NUMBER;
  l_model_id         NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING PROCESS_CHILD_LINES',1);
   END IF;

   IF NVL(p_ship_model_complete_flag,'N') = 'Y'
      AND p_top_model_line_id = p_line_id
   THEN  -- SMC
      l_where_clause :=' WHERE ola.top_model_line_id = :P1';
      l_model_id :=p_top_model_line_id;
      --fix for 3565621
      g_top_model_line_id := p_top_model_line_id;

   ELSIF p_ato_line_id IS NOT NULL
     AND p_ato_line_id = p_line_id
     -- fix for 3565621
     AND ( g_top_model_line_id IS NULL OR
           ( NOT OE_Globals.Equal(p_top_model_line_id,g_top_model_line_id)
           )
         )
   THEN
      l_where_clause :=' WHERE ola.ato_line_id = :P1';
      l_model_id :=p_ato_line_id;

   ELSIF NVL(p_ship_model_complete_flag,'N') = 'N'
       AND p_item_type_code IN('MODEL','CLASS','KIT')
   THEN
      l_where_clause :=' WHERE ola.link_to_line_id = :P1'||
                        ' AND ola.item_type_code = '||'''INCLUDED''';
      l_model_id := p_line_id;
   END IF;
   IF l_where_clause IS NOT NULL
   THEN
      l_stmt :=' SELECT ola.line_id '||
         ' FROM oe_order_lines_all ola, wf_item_activity_statuses wias, wf_process_activities wpa '||
         l_where_clause||
         ' AND wias.item_key = to_char(ola.line_id)'||
         ' AND wias.item_type = '||'''OEOL'''||
         ' AND wias.process_activity = wpa.instance_id'||
         ' AND wpa.ACTIVITY_ITEM_TYPE = '||'''OEOL'''||
         ' AND wpa.activity_name = '||'''SCHEDULING_ELIGIBLE'''||
         ' AND wias.activity_status = '||'''NOTIFIED''';
      OPEN l_ref_cur_line_id FOR l_stmt USING l_model_id;
      LOOP
         FETCH l_ref_cur_line_id into l_line_id;
         EXIT WHEN l_ref_cur_line_id%NOTFOUND;

         -- Processing the lines
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Processing Line '||l_line_id , 1 ) ;
         END IF;

         WF_ENGINE.CompleteActivityInternalName(
                        itemtype  =>  'OEOL',
                        itemkey   =>  to_char(l_line_id),
                        activity  =>  'SCHEDULING_ELIGIBLE',
                        result    =>  'COMPLETED');
      END LOOP;
      CLOSE l_ref_cur_line_id;
   END IF;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING PROCESS_CHILD_LINES' , 1 ) ;
   END IF;


END Process_Child_Lines;

/*-----------------------------------------------------------------------
Proceudure : Schedule Line
----------------------------------------------------------------------- */

PROCEDURE Schedule_Line (itemtype  in varchar2,
                         itemkey   in varchar2,
                         actid     in number,
                         funcmode  in varchar2,
                         resultout in out nocopy varchar2) /* file.sql.39 change */
IS
   l_line_rec                  OE_Order_PUB.Line_Rec_Type;
   l_old_line_rec              OE_Order_PUB.Line_Rec_Type;
   l_return_status             VARCHAR2(1);
   l_dummy                     VARCHAR2(240);
   l_write_to_db               VARCHAR2(1);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(2000);
   l_atp_tbl                   OE_ATP.atp_tbl_type;
   l_result                    Varchar2(30);
   l_out_return_status         VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
   l_line_id                   NUMBER := 0;
   l_top_model_line_id         NUMBER := 0;
   l_item_type_code            VARCHAR2(30);
   l_line_category_code        VARCHAR2(30);
   l_schedule_status_code      VARCHAR2(30);
   l_source_type_code          VARCHAR2(30);
   l_ship_model_complete_flag  VARCHAR2(1);
   l_ato_line_id               NUMBER;
   l_request_date              DATE;
   l_sch_ship_date             DATE;
   l_ship_from_org_id          NUMBER;
   l_activity_status_code       VARCHAR2(8);
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_header_id                  NUMBER;
   l_order_source_id            NUMBER;
   l_orig_sys_document_ref      VARCHAR2(50);
   l_orig_sys_line_ref          VARCHAR2(50);
   l_orig_sys_shipment_ref      VARCHAR2(50);
   l_change_sequence            VARCHAR2(50);
   l_source_document_type_id    NUMBER;
   l_source_document_id         NUMBER;
   l_source_document_line_id    NUMBER;
   l_scheduled                  BOOLEAN;
   l_link_to_line_id            NUMBER;
   l_child_line_id              NUMBER := 0;

BEGIN
   --
   -- RUN mode - normal process execution
   --

   if (funcmode = 'RUN') then

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'TST1: WITHIN SCHEDULE LINE WORKFLOW COVER ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ITEM KEY IS ' || ITEMKEY ) ;
      END IF;

      OE_STANDARD_WF.Set_Msg_Context(actid);

      SAVEPOINT Before_Lock;

      -- If it is BULK Mode then no need to query these values from Database

      IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCH BULK MODE' , 5 ) ;
         END IF;

         l_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.line_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_top_model_line_id :=
            OE_BULK_ORDER_PVT.G_LINE_REC.top_model_line_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_item_type_code :=
            OE_BULK_ORDER_PVT.G_LINE_REC.item_type_code(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_line_category_code :=
            OE_BULK_ORDER_PVT.G_LINE_REC.line_category_code(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_schedule_status_code :=
            OE_BULK_ORDER_PVT.G_LINE_REC.schedule_status_code(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_ship_model_complete_flag :=
            OE_BULK_ORDER_PVT.G_LINE_REC.ship_model_complete_flag(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_ato_line_id :=
            OE_BULK_ORDER_PVT.G_LINE_REC.ato_line_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_source_type_code :=
            OE_BULK_ORDER_PVT.G_LINE_REC.source_type_code(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_request_date :=
            OE_BULK_ORDER_PVT.G_LINE_REC.request_date(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_sch_ship_date :=
            OE_BULK_ORDER_PVT.G_LINE_REC.schedule_ship_date(OE_BULK_WF_UTIL.G_LINE_INDEX);

         l_ship_from_org_id :=
            OE_BULK_ORDER_PVT.G_LINE_REC.ship_from_org_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

         -- Locking of top model not needed for BULK create as model(kit) and child
         -- (included items) are created in the same DB session
         -- Handle external lines call not needed as BULK does not support external
         -- lines
         -- If the mode is BULK from Order Import Then check globals to find out
         -- if line on activity specific hold

         IF OE_BULK_HOLDS_PVT.G_Line_Holds_Tbl.EXISTS(OE_BULK_WF_UTIL.G_LINE_INDEX)
            AND OE_BULK_HOLDS_PVT.G_Line_Holds_Tbl(OE_BULK_WF_UTIL.G_LINE_INDEX).On_Scheduling_Hold = 'Y'
         THEN
            l_result := FND_API.G_TRUE;
         END IF;

      ELSE  -- If not BULK mode.

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCH NON-BULK MODE' , 5 ) ;
         END IF;

         --Processing added for Locking

         -- To improve performance:
         -- Query all variables needed for local processing here
         -- and query the entire line record only if line needs
         -- to be scheduled just before the call to Schedule_Line.
         SELECT line_id
            , top_model_line_id
            , item_type_code
            , line_category_code
            , schedule_status_code
            , ship_model_complete_flag
            , ato_line_id
            , source_type_code
            , request_date
            , schedule_ship_date
            , ship_from_org_id
            , header_id
            , order_source_id
            , orig_sys_document_ref
            , orig_sys_line_ref
            , orig_sys_shipment_ref
            , change_sequence
            , source_document_type_id
            , source_document_id
            , source_document_line_id
            , link_to_line_id
            , inventory_item_id
         INTO l_line_id, l_top_model_line_id
            , l_item_type_code
            , l_line_category_code
            , l_schedule_status_code
            , l_ship_model_complete_flag
            , l_ato_line_id
            , l_source_type_code
            , l_request_date
            , l_sch_ship_date
            , l_ship_from_org_id
            , l_header_id
            , l_order_source_id
            , l_orig_sys_document_ref
            , l_orig_sys_line_ref
            , l_orig_sys_shipment_ref
            , l_change_sequence
            , l_source_document_type_id
            , l_source_document_id
            , l_source_document_line_id
            , l_link_to_line_id  -- 3000761
            , l_line_rec.inventory_item_id
         FROM   oe_order_lines
         WHERE  line_id = to_number(itemkey);
         --FOR UPDATE; -- 3693569 :This will be locked after parent line is locked.

         l_child_line_id := l_line_id;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'TOP MODEL LINE ID : '||L_TOP_MODEL_LINE_ID , 3 ) ;
         END IF;

         IF nvl(l_top_model_line_id,0) <> 0 THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LOCKING MODEL '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
            END IF;

            SELECT line_id, top_model_line_id
               INTO   l_line_id, l_top_model_line_id
               FROM   oe_order_lines
               WHERE  line_id = l_top_model_line_id
               FOR UPDATE;

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'MODEL LOCKED '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
            END IF;

         END IF;
         -- 3693569: Lock the child line
         SELECT line_id
         INTO l_line_id
         FROM oe_order_lines
         WHERE  line_id = l_child_line_id
         FOR UPDATE;

         l_line_id := to_number(itemkey);

         OE_MSG_PUB.set_msg_context(p_entity_code                => 'LINE'
                                    ,p_entity_id                  => l_line_id
                                    ,p_header_id                  => l_header_id
                                    ,p_line_id                    => l_line_id
                                    ,p_order_source_id            => l_order_source_id
                                    ,p_orig_sys_document_ref      => l_orig_sys_document_ref
                                    ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
                                    ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
                                    ,p_change_sequence            => l_change_sequence
                                    ,p_source_document_type_id    => l_source_document_type_id
                                    ,p_source_document_id         => l_source_document_id
                                    ,p_source_document_line_id    => l_source_document_line_id
                                    );
      /* --
       * -- To push child lines to Schedule_Eligible block if model is not scheduled
       * IF  NVL(l_ship_model_complete_flag,'N') = 'Y'
       *    AND NOT OE_GLOBALS.Equal(l_top_model_line_id,
       *                             l_line_id)
       * THEN  -- SMC
       *
       *    l_scheduled := Is_Line_Scheduled(l_top_model_line_id);
       *
       *    IF NOT l_scheduled
       *    THEN
       *       ROLLBACK TO Before_Lock;
       *       resultout := 'COMPLETE:INCOMPLETE';
       *       return;
       *    END IF;
       *    IF Is_Scheduling_Eligible(l_top_model_line_id) THEN -- Bug3083995
       *       ROLLBACK TO Before_Lock;
       *       resultout := 'COMPLETE:INCOMPLETE';
       *       return;
       *    END IF;
       *
       * ELSIF l_ato_line_id is not null
       *       AND   NOT OE_GLOBALS.Equal(l_ato_line_id,
       *                                  l_line_id)
       * THEN  -- ATO
       *    l_scheduled := Is_Line_Scheduled(l_ato_line_id);
       *    IF NOT l_scheduled
       *    THEN
       *       ROLLBACK TO Before_Lock;
       *       resultout := 'COMPLETE:INCOMPLETE';
       *       return;
       *    END IF;
       *    IF Is_Scheduling_Eligible(l_ato_line_id) THEN ---- Bug3083995
       *       ROLLBACK TO Before_Lock;
       *       resultout := 'COMPLETE:INCOMPLETE';
       *       return;
       *    END IF;
       * ELSIF NVL(l_ship_model_complete_flag,'N') = 'N'
       *       AND l_item_type_code ='INCLUDED'
       * THEN -- Non SMC
       *    l_scheduled := Is_Line_Scheduled(l_link_to_line_id);
       *    IF NOT l_scheduled
       *    THEN
       *       ROLLBACK TO Before_Lock;
       *       resultout := 'COMPLETE:INCOMPLETE';
       *       return;
       *    END IF;
       *    IF Is_Scheduling_Eligible(l_link_to_line_id) THEN -- Bug3083995
       *       ROLLBACK TO Before_Lock;
       *       resultout := 'COMPLETE:INCOMPLETE';
       *       return;
       *    END IF;
       *
       * END IF;
       * --
       */

         -- Added external to if stmt to bypass scheduling.
         IF (l_item_type_code = OE_GLOBALS.G_ITEM_SERVICE) OR
            (l_line_category_code = 'RETURN') OR
            (l_source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL) THEN

            -- This is a service line or a return line. We will complete
            -- this activity with not eligible for these lines.

            ROLLBACK TO Before_Lock;

            IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
               l_source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL AND
               l_ato_line_id = l_line_id AND
               l_sch_ship_date is NULL THEN

               BEGIN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'CALLING HANDEL_EXTERNAL_LINES IN WF' , 4 ) ;
                  END IF;

                  l_line_rec.line_id           := l_line_id;
                  l_line_rec.ato_line_id       := l_ato_line_id;
                  l_line_rec.top_model_line_id := l_top_model_line_id;
                  l_line_rec.request_date      := l_request_date;
                  l_line_rec.ship_from_org_id  := l_ship_from_org_id;

                  OE_Schedule_Util.Handle_External_Lines
                     (p_x_line_rec  => l_line_rec);

               EXCEPTION
                  WHEN OTHERS THEN
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'SCHEDULING WORFKLOW ERRORS' , 1 ) ;
                     END IF;

                     resultout := 'COMPLETE:INCOMPLETE';

                     OE_STANDARD_WF.Save_Messages;
                     OE_STANDARD_WF.Clear_Msg_Context;

                     OE_Delayed_Requests_PVT.Clear_Request
                        (x_return_status => l_return_status);

                     RETURN;
               END;
            END IF;

            resultout := 'COMPLETE:NOT_ELIGIBLE';

            OE_STANDARD_WF.Save_Messages;
            OE_STANDARD_WF.Clear_Msg_Context;

            OE_Delayed_Requests_PVT.Clear_Request
               (x_return_status => l_return_status);
            return;

         END IF;


         -- To push child lines to Schedule_Eligible block if model is not scheduled
         -- 3565621
         IF NOT g_skip_check
         THEN
            IF  NVL(l_ship_model_complete_flag,'N') = 'Y'
               AND NOT OE_GLOBALS.Equal(l_top_model_line_id,
                                        l_line_id)
            THEN  -- SMC

               l_scheduled := Is_Line_Scheduled(l_top_model_line_id);

               IF NOT l_scheduled
               THEN
                  ROLLBACK TO Before_Lock;
                  resultout := 'COMPLETE:INCOMPLETE';
                  OE_STANDARD_WF.Save_Messages;
                  OE_STANDARD_WF.Clear_Msg_Context;
                  --5166476
                  IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
                     OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     OE_SCH_CONC_REQUESTS.g_recorded :='Y';
                  END IF;

                  OE_Delayed_Requests_PVT.Clear_Request
                     (x_return_status => l_return_status);
                  return;
               END IF;
               IF Is_Scheduling_Eligible(l_top_model_line_id) THEN -- Bug3083995
                  ROLLBACK TO Before_Lock;
                  resultout := 'COMPLETE:INCOMPLETE';
                  OE_STANDARD_WF.Save_Messages;
                  OE_STANDARD_WF.Clear_Msg_Context;
                  --5166476
                  IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
                     OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     OE_SCH_CONC_REQUESTS.g_recorded :='Y';
                  END IF;

                  OE_Delayed_Requests_PVT.Clear_Request
                     (x_return_status => l_return_status);
                  return;
               END IF;

            ELSIF l_ato_line_id is not null
                  AND   NOT OE_GLOBALS.Equal(l_ato_line_id,
                                             l_line_id)
            THEN  -- ATO
               l_scheduled := Is_Line_Scheduled(l_ato_line_id);
               IF NOT l_scheduled
               THEN
                  ROLLBACK TO Before_Lock;
                  resultout := 'COMPLETE:INCOMPLETE';
                  OE_STANDARD_WF.Save_Messages;
                  OE_STANDARD_WF.Clear_Msg_Context;
                  --5166476
                  IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
                     OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     OE_SCH_CONC_REQUESTS.g_recorded :='Y';
                  END IF;

                  OE_Delayed_Requests_PVT.Clear_Request
                     (x_return_status => l_return_status);
                  return;
               END IF;
               IF Is_Scheduling_Eligible(l_ato_line_id) THEN ---- Bug3083995
                  ROLLBACK TO Before_Lock;
                  resultout := 'COMPLETE:INCOMPLETE';
                  --5166476
                  IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
                     OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     OE_SCH_CONC_REQUESTS.g_recorded :='Y';
                  END IF;

                  OE_STANDARD_WF.Save_Messages;
                  OE_STANDARD_WF.Clear_Msg_Context;

                  OE_Delayed_Requests_PVT.Clear_Request
                     (x_return_status => l_return_status);
                  return;
               END IF;
            ELSIF NVL(l_ship_model_complete_flag,'N') = 'N'
                  AND l_item_type_code ='INCLUDED'
            THEN -- Non SMC
               l_scheduled := Is_Line_Scheduled(l_link_to_line_id);
               IF NOT l_scheduled
               THEN
                  ROLLBACK TO Before_Lock;
                  resultout := 'COMPLETE:INCOMPLETE';
                  OE_STANDARD_WF.Save_Messages;
                  OE_STANDARD_WF.Clear_Msg_Context;
                  --5166476
                  IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
                     OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     OE_SCH_CONC_REQUESTS.g_recorded :='Y';
                  END IF;

                  OE_Delayed_Requests_PVT.Clear_Request
                     (x_return_status => l_return_status);
                  return;
               END IF;
               IF Is_Scheduling_Eligible(l_link_to_line_id) THEN -- Bug3083995
                  ROLLBACK TO Before_Lock;
                  resultout := 'COMPLETE:INCOMPLETE';
                  --5166476
                  IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN
                     OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     OE_SCH_CONC_REQUESTS.g_recorded :='Y';
                  END IF;

                  OE_STANDARD_WF.Save_Messages;
                  OE_STANDARD_WF.Clear_Msg_Context;

                  OE_Delayed_Requests_PVT.Clear_Request
                     (x_return_status => l_return_status);
                  return;
               END IF;

            END IF;
         END IF; -- 3565621
         --
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING CHECK HOLDS' , 1 ) ;
         END IF;

         OE_Holds_PUB.Check_Holds
            (    p_api_version       => 1.0
             ,   p_init_msg_list     => FND_API.G_FALSE
             ,   p_commit            => FND_API.G_FALSE
             ,   p_validation_level  => FND_API.G_VALID_LEVEL_FULL
             ,   x_return_status     => l_out_return_status
             ,   x_msg_count         => l_msg_count
             ,   x_msg_data          => l_msg_data
             ,   p_line_id           => l_line_id
             ,   p_hold_id           => NULL
             ,   p_entity_code       => NULL
             ,   p_entity_id         => NULL
             ,   p_wf_item           => 'OEOL'
             ,   p_wf_activity       => 'LINE_SCHEDULING'
             ,   p_chk_act_hold_only => 'Y'
             ,   x_result_out        => l_result
             );

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING CHECK HOLDS'||L_OUT_RETURN_STATUS||'/'||L_RESULT , 1 ) ;
         END IF;

         IF (l_out_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_out_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

      END IF; -- End IF BULK Mode

      IF (l_result = FND_API.G_TRUE) THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS ON HOLD' , 1 ) ;
         END IF;
         ROLLBACK TO Before_Lock;

         -- Start modified for bug 2515791
         IF l_schedule_status_code is not null THEN
            -- New message 'Could not Progress. Line is on Hold' added
            FND_MESSAGE.SET_NAME('ONT','OE_SCH_UN_PROGRESS_ON_HOLD');
         ELSE
            FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_ON_HOLD');
         END IF;
         -- End modified for bug 2515791
         OE_MSG_PUB.Add;

         resultout := 'COMPLETE:ON_HOLD';
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;

         OE_Delayed_Requests_PVT.Clear_Request
            (x_return_status => l_return_status);
         return;
      END IF;

      IF (l_schedule_status_code is not null) THEN
         ROLLBACK TO Before_Lock;
         resultout := 'COMPLETE:COMPLETE';


         --Added this call to fix bug 3319120
         --
         -- Processing child lines which are at scheduling eligible block (if any)
         IF l_top_model_line_id = l_line_id
            OR  l_ato_line_id = l_line_id
            OR (NVL(l_ship_model_complete_flag,'N') = 'N'
                AND l_item_type_code IN('MODEL','CLASS','KIT'))
         THEN
            IF OE_GLOBALS.Equal(l_line_id,
                                sch_cached_line_id)
            THEN -- To refresh the cached values
               sch_cached_line_id := NULL;
            END IF;
            -- 3565621
            g_skip_check := TRUE;
            Process_Child_Lines(p_line_id                  => l_line_id,
                                p_top_model_line_id        => l_top_model_line_id,
                                p_ato_line_id              => l_ato_line_id,
                                p_ship_model_complete_flag => l_ship_model_complete_flag,
                                p_item_type_code           => l_item_type_code);
            g_skip_check := FALSE;
         END IF;
         --
         l_line_rec.ship_from_org_id  := l_ship_from_org_id;
         Bulk_Mode_Copy_Sch_Attribs
            (p_line_rec    => l_line_rec);

         return;
      END IF;


      -- This code is not required any more, since flow for the included
      -- items starts at the end due to delayed flow changes.
      -- Introducing dependency on delayed_flow aru.1993341


      -- Modified this code to take care of multiple calls to MRP when SMC model call or
      -- atp model failed to schedule. If model is in schedule eligible status, push the child records
      -- to schedule eligible state. That way when user runs the concurrent program, system will
      -- schedule whole model if possible. Fix is to address bug 2452175

      IF (l_top_model_line_id is not null) AND
         (nvl(l_ship_model_complete_flag,'N') = 'Y') AND
         (l_top_model_line_id <> l_line_id) THEN
         -- This is a SMC option/class/included item. We will bypass this
         -- line since the model line will schedule this line.

         --Bug-2452175

         BEGIN
            --Check whether the Parent line is in Schedule Eligible state

            SELECT ACTIVITY_STATUS
            INTO l_activity_status_code
            FROM wf_item_activity_statuses wias, wf_process_activities wpa
            WHERE wias.item_type = 'OEOL' AND
               wias.item_key  = to_char(l_top_model_line_id) AND
               wias.process_activity = wpa.instance_id AND
               wpa.ACTIVITY_ITEM_TYPE = 'OEOL' AND
               wpa.activity_name = 'SCHEDULING_ELIGIBLE' AND
               wias.activity_status = 'NOTIFIED';

            -- Parent line is in Schedule Eligible Status set the line status
            -- to Schedule Eligible.
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SMC :PUSHING LINE TO SCHEDULE ELIGIBLE' , 2 ) ;
            END IF;
            ROLLBACK TO Before_Lock;
            resultout := 'COMPLETE:INCOMPLETE';
            OE_STANDARD_WF.Save_Messages;
            OE_STANDARD_WF.Clear_Msg_Context;

            OE_Delayed_Requests_PVT.Clear_Request
               (x_return_status => l_return_status);
            return;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Parent line is not in Schedule Eligible State.
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;

      END IF;

      IF (l_ato_line_id is not null) AND
         (l_line_id <> l_ato_line_id) THEN
         -- This is an ATO option or class. We will bypass this
         -- line since the model line will schedule this line.

         --Bug-2452175

         BEGIN
            --Check whether the Parent line is in Schedule Eligible state

            SELECT ACTIVITY_STATUS
            INTO l_activity_status_code
            FROM wf_item_activity_statuses wias, wf_process_activities wpa
            WHERE wias.item_type = 'OEOL' AND
               wias.item_key  = to_char(l_ato_line_id) AND
               wias.process_activity = wpa.instance_id AND
               wpa.ACTIVITY_ITEM_TYPE = 'OEOL' AND
               wpa.activity_name = 'SCHEDULING_ELIGIBLE' AND
               wias.activity_status = 'NOTIFIED';

            -- Parent is in Schedule Eligible Status set the line status
            -- to Schedule Eligible.
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'ATO: PUSHING LINE TO SCHEDULE ELIGIBLE' , 2 ) ;
            END IF;
            ROLLBACK TO Before_Lock;
            resultout := 'COMPLETE:INCOMPLETE';
            OE_STANDARD_WF.Save_Messages;
            OE_STANDARD_WF.Clear_Msg_Context;

            OE_Delayed_Requests_PVT.Clear_Request
               (x_return_status => l_return_status);
            return;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- Parent line is not in Schedule Eligible State.
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;

      END IF;

      OE_Line_Util.Query_Row
         (p_line_id       => to_number(itemkey),
          x_line_rec      => l_line_rec);

      OE_MSG_PUB.update_msg_context( p_entity_code                => 'LINE'
                                    ,p_entity_id                  => l_line_rec.line_id
                                    ,p_header_id                  => l_line_rec.header_id
                                    ,p_line_id                    => l_line_rec.line_id
                                    ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
                                    ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
                                    ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
                                    ,p_change_sequence            => l_line_rec.change_sequence
                                    ,p_source_document_id         => l_line_rec.source_document_id
                                    ,p_source_document_line_id    => l_line_rec.source_document_line_id
                                    ,p_order_source_id            => l_line_rec.order_source_id
                                    ,p_source_document_type_id    => l_line_rec.source_document_type_id);

      l_old_line_rec                  := l_line_rec;
      -- l_line_rec.schedule_action_code := OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
      l_line_rec.schedule_action_code := OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE;
      l_line_rec.operation            := OE_GLOBALS.G_OPR_UPDATE;

      -- Added this savepoint logic to fix bug 2129583.
      SAVEPOINT Schedule_line;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING OE_SCHEDULE_UTIL ' , 1 ) ;
      END IF;
      OE_SCHEDULE_UTIL.Schedule_Line
         (p_x_line_rec    => l_line_rec
          ,p_old_line_rec  => l_old_line_rec
          ,p_caller        => OE_SCHEDULE_UTIL.SCH_EXTERNAL
          ,x_return_status => l_return_status);

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_RETURN_STATUS IS ' || L_RETURN_STATUS , 1 ) ;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCHEDULING WORFKLOW EXP ERRORS' , 1 ) ;
         END IF;
         resultout := 'COMPLETE:INCOMPLETE';
	 --8731703
         -- Rollback the demand for success lines.
         OE_SCHEDULE_UTIL.CALL_MRP_ROLLBACK (x_return_status => l_return_status);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'MRP Rollback result '||l_return_status , 1 ) ;
         END IF;
         -- moved this line up to for the bug fix 2884452
         ROLLBACK TO SAVEPOINT Schedule_line;
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         --commit; /* Added this line to fix the bug 2884452 */
         OE_Delayed_Requests_PVT.Clear_Request
            (x_return_status => l_return_status);
         --5122730
         IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN
            IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN -- 5166476
                 OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_rec.line_id) := 'N';
               OE_SCH_CONC_REQUESTS.g_recorded := 'Y';
            END IF;
         END IF;

         return;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SCHEDULING WORFKLOW UN-EXP ERRORS' , 1 ) ;
         END IF;
         resultout := 'COMPLETE:INCOMPLETE';
         -- moved this line up to for the bug fix 2884452
         ROLLBACK TO SAVEPOINT Schedule_line;
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         --commit; /* Added this line to fix the bug 2884452 */
         OE_Delayed_Requests_PVT.Clear_Request
            (x_return_status => l_return_status);
         -- app_exception.raise_exception;
         --5122730
         IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN
            IF OE_SCH_CONC_REQUESTS.g_recorded = 'N' THEN -- 5166476
               OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_rec.line_id) := 'N';
               OE_SCH_CONC_REQUESTS.g_recorded := 'Y';
            END IF;
         END IF;
         return;
      END IF;

      --
      -- Processing child lines which are at scheduling eligible block (if any)
      IF l_line_rec.top_model_line_id = l_line_rec.line_id
         OR  l_line_rec.ato_line_id = l_line_rec.line_id
         OR (NVL(l_line_rec.ship_model_complete_flag,'N') = 'N'
             AND l_line_rec.item_type_code IN('MODEL','CLASS','KIT'))
      THEN
         IF OE_GLOBALS.Equal(l_line_rec.line_id,
                             sch_cached_line_id)
         THEN -- To refresh the cached values
            sch_cached_line_id := NULL;
         END IF;
         -- 3565621
         g_skip_check := TRUE;
         Process_Child_Lines(p_line_id                  => l_line_rec.line_id,
                             p_top_model_line_id        => l_line_rec.top_model_line_id,
                             p_ato_line_id              => l_line_rec.ato_line_id,
                             p_ship_model_complete_flag => l_line_rec.ship_model_complete_flag,
                             p_item_type_code           => l_line_rec.item_type_code);
         g_skip_check := FALSE;
      END IF;
      --

      resultout := 'COMPLETE:COMPLETE';
      OE_STANDARD_WF.Clear_Msg_Context;

      Bulk_Mode_Copy_Sch_Attribs
         (p_line_rec    => l_line_rec);

      return;
   end if;

   IF (funcmode = 'CANCEL') THEN
      null;
      return;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('OE_OEOL_SCH', 'Schedule Line',
                      itemtype, itemkey, to_char(actid), funcmode);
      -- start data fix project
      OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                            p_itemtype => itemtype,
                                            p_itemkey => itemkey);
      OE_STANDARD_WF.Save_Messages;
      OE_STANDARD_WF.Clear_Msg_Context;
      -- end data fix project
      raise;
END Schedule_Line;



/*----------------------------------------------------------------------
Bulk_Mode_Copy_Sch_Attribs

This procedure sets the sceduling attributes on the bulk glabal line
record, if scheduling happens through workflow.
-----------------------------------------------------------------------*/
PROCEDURE Bulk_Mode_Copy_Sch_Attribs
(p_line_rec    IN OUT NOCOPY  OE_Order_Pub.Line_Rec_Type)
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_key         NUMBER;
BEGIN

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('-- bulk mode set results on global record', 5);
  END IF;

  IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NOT NULL THEN
    -- shippable flag need to be checked based on ship from org.

    IF p_line_rec.inventory_item_id is NULL THEN
      p_line_rec.inventory_item_id   := OE_BULK_ORDER_PVT.G_LINE_REC.inventory_item_id(OE_BULK_WF_UTIL.G_LINE_INDEX);
    END IF;

    l_key := OE_BULK_CACHE.Load_Item
             ( p_key1     => p_line_rec.inventory_item_id
              ,p_key2     => p_line_rec.ship_from_org_id);

      -- not comparing as we have to either do a blind assign or
      -- compare and assign.
      -- this load item will serve at the time if wf shipping call.

      OE_BULK_ORDER_PVT.G_LINE_REC.shippable_flag
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_key).shippable_item_flag;

      IF OE_BULK_ORDER_PVT.G_LINE_REC.schedule_status_code
        (OE_BULK_WF_UTIL.G_LINE_INDEX) is NULL AND
         p_line_rec.schedule_status_code is not NULL
      THEN
        oe_debug_pub.add('2 sch bulk mode, set results wf sch',5);
        -- need not put original item

        OE_BULK_ORDER_PVT.G_LINE_REC.schedule_status_code
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.schedule_status_code;
        OE_BULK_ORDER_PVT.G_LINE_REC.schedule_ship_date
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.schedule_ship_date;
        OE_BULK_ORDER_PVT.G_LINE_REC.schedule_arrival_date
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.schedule_arrival_date;
        OE_BULK_ORDER_PVT.G_LINE_REC.ship_from_org_id
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.ship_from_org_id;
        OE_BULK_ORDER_PVT.G_LINE_REC.shipping_method_code
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.shipping_method_code;
        OE_BULK_ORDER_PVT.G_LINE_REC.delivery_lead_time
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.delivery_lead_time;
        OE_BULK_ORDER_PVT.G_LINE_REC.visible_demand_flag
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.visible_demand_flag;

        --OE_BULK_ORDER_PVT.G_LINE_REC.PLANNING_PRIORITY.extend(l_count);
        --OE_BULK_ORDER_PVT.G_LINE_REC.planning_priority
        --(OE_BULK_WF_UTIL.G_LINE_INDEX) := l_line_rec.planning_priority;

        OE_BULK_ORDER_PVT.G_LINE_REC.re_source_flag
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.re_source_flag;
        OE_BULK_ORDER_PVT.G_LINE_REC.mfg_lead_time
        (OE_BULK_WF_UTIL.G_LINE_INDEX) := p_line_rec.mfg_lead_time;
      END IF;

  END IF; -- bulk mode.

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('-- error in setting global record '|| sqlerrm, 5);
    END IF;
    RAISE;
END Bulk_Mode_Copy_Sch_Attribs;


/*-----------------------------------------------------------------------
Proceudure : Branch on Source Type
----------------------------------------------------------------------- */
PROCEDURE Branch_on_source_type(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2) /* file.sql.39 change */
IS
    --l_line_rec                    OE_Order_PUB.Line_Rec_Type;
    l_source_type_code            VARCHAR2(30);
    l_ato_line_id                 NUMBER;
    l_item_type_code              VARCHAR2(30);
    l_line_id                     NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  --
  -- RUN mode - normal process execution
  --
    -- start data fix project
    OE_STANDARD_WF.Set_Msg_Context(actid);
    -- end data fix project

--  l_line_rec := OE_Line_Util.Query_Row(to_number(itemkey));
/* Changes for performance, the query row is being replaced by a select.

    OE_Line_Util.Query_Row(p_line_id    => to_number(itemkey),
                                       x_line_rec       => l_line_rec);
*/

    l_line_id := to_number(itemkey);

    SELECT   SOURCE_TYPE_CODE,
                   ITEM_TYPE_CODE,
                   ATO_LINE_ID
    INTO     l_source_type_code,
                   l_item_type_code,
                   l_ato_line_id
    FROM     OE_ORDER_LINES
    WHERE    LINE_ID = l_line_id;

  if (funcmode = 'RUN') then


     IF l_source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL AND
        nvl(l_ato_line_id, -1) <> l_line_id
     THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BRANCH: DROPSHIP '|| L_LINE_ID , 2 ) ;
          END IF;
          resultout := 'COMPLETE:DROPSHIP';
          return;

     ELSIF l_ato_line_id = l_line_id THEN

       IF l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
          l_item_type_code = OE_GLOBALS.G_ITEM_CLASS
       THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BRANCH: BUILD '|| L_LINE_ID , 2 ) ;
          END IF;
          resultout := 'COMPLETE:BUILD';
          return;
       ELSIF  (l_item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
               l_item_type_code = OE_GLOBALS.G_ITEM_OPTION)
       THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BRANCH: ATO ITEM '|| L_LINE_ID , 2 ) ;
          END IF;
          resultout := 'COMPLETE:ATO_ITEM';
          return;
       END IF;

     ELSIF l_item_type_code = OE_GLOBALS.G_ITEM_CONFIG
     AND   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
     AND   MSC_ATP_GLOBAL.GET_APS_VERSION = 10  THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BRANCH: ATO ITEM '|| L_LINE_ID , 2 ) ;
          END IF;
          resultout := 'COMPLETE:ATO_ITEM';
          return;
     ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BRANCH: STOCK '|| L_LINE_ID , 2 ) ;
          END IF;
          resultout := 'COMPLETE:STOCK';
          return;
     END IF;
  end if;


  IF (funcmode = 'CANCEL') THEN
    resultout := 'STOCK';
    return;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_OEOL_SCH', 'Branch_on_source_type',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Branch_on_source_type;

/*-----------------------------------------------------------------------
Procedure : Release the line to Purchasing
Description: This procedure validates the line and calls
             OE_Purchase_Release_PVT.Purchase_Release to release the
             line to purchase (i.e: insert into req interface tables).
----------------------------------------------------------------------- */

PROCEDURE Release_to_purchasing(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2) /* file.sql.39 change */
IS
    l_line_rec                OE_Order_PUB.Line_Rec_Type;
    l_header_rec              OE_Order_PUB.Header_Rec_Type;
    l_drop_ship_line_rec      OE_Purchase_Release_PVT.Drop_Ship_Line_Rec_Type;
    l_drop_ship_tbl           OE_Purchase_Release_PVT.Drop_Ship_Tbl_Type;
    ll_drop_ship_tbl          OE_Purchase_Release_PVT.Drop_Ship_Tbl_Type;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_dummy                   VARCHAR2(240);
    l_order_type_name         VARCHAR2(40);
    l_user_name               VARCHAR2(100);
    l_employee_id             NUMBER;
    item_asset_flag           VARCHAR2(1);
    item_expense_account      NUMBER;
    org_material_account      NUMBER;
    org_expense_account       NUMBER;
    l_charge_account_id       NUMBER;
    l_address_id              NUMBER;
    l_deliver_to_location_id  NUMBER;
    l_temp                    BOOLEAN;  -- Fix for bug2097383
    -- OPM
    x_charge_account_id       NUMBER;
    x_accrual_account_id      NUMBER;
    l_allow_item_desc_update  VARCHAR2(1);
    l_line_id                 NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering Release to Purchasing line',1);
    END IF;

    OE_STANDARD_WF.Set_Msg_Context(actid);

    OE_Line_Util.Query_Row(p_line_id => to_number(itemkey), x_line_rec  => l_line_rec);
    OE_Header_Util.Query_Row(p_header_id => l_line_rec.header_id, x_header_rec  => l_header_rec);

    --Bug2432009
    IF nvl(l_line_rec.source_type_code,'INTERNAL') = 'INTERNAL' THEN
      resultout := 'COMPLETE:NOT_ELIGIBLE';
      return;
    END IF;

    OE_MSG_PUB.set_msg_context(
        p_entity_code                => 'LINE'
       ,p_entity_id                  => l_line_rec.line_id
       ,p_header_id                  => l_line_rec.header_id
       ,p_line_id                    => l_line_rec.line_id
       ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
       ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
       ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
       ,p_change_sequence            => l_line_rec.change_sequence
       ,p_source_document_id         => l_line_rec.source_document_id
       ,p_source_document_line_id    => l_line_rec.source_document_line_id
       ,p_order_source_id            => l_line_rec.order_source_id
       ,p_source_document_type_id    => l_line_rec.source_document_type_id);

    IF l_line_rec.ship_from_org_id is null THEN
         -- ship_from_org_id reqd

         FND_MESSAGE.SET_NAME('ONT','OE_DS_WHSE_REQD');
         OE_MSG_PUB.Add;
         resultout := 'COMPLETE:INCOMPLETE';
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         return;
    END IF;

    BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P1' , 1 ) ;
       END IF;
       SELECT name
       INTO l_order_type_name
       FROM oe_order_types_v
       WHERE order_type_id = l_header_rec.order_type_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P2' , 1 ) ;
       END IF;
       SELECT fu.user_name,nvl(fu.employee_id, -99)
       INTO l_user_name,l_employee_id
       FROM fnd_user fu
       WHERE fu.user_id = l_line_rec.created_by; --bug 4682158

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P3' , 1 ) ;
       END IF;
       SELECT inventory_asset_flag,expense_account,allow_item_desc_update_flag
       into item_asset_flag,item_expense_account,l_allow_item_desc_update
       FROM mtl_system_items
       WHERE inventory_item_id = l_line_rec.inventory_item_id
       AND organization_id = l_line_rec.ship_from_org_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P4' , 1 ) ;
       END IF;
       SELECT material_account,expense_account
       into org_material_account,org_expense_account
       FROM mtl_parameters
       WHERE organization_id = l_line_rec.ship_from_org_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'P5' , 1 ) ;
       END IF;
       BEGIN
          /* MOAC_SQL_CHANGE */
         SELECT LOC.LOCATION_ID
         INTO   l_deliver_to_location_id
         FROM   HZ_LOCATIONS LOC,
                HZ_PARTY_SITES PARTY,
                HZ_CUST_ACCT_SITES ACCT,
                HZ_CUST_SITE_USES_ALL CUST
         WHERE  CUST.SITE_USE_ID=L_LINE_REC.SHIP_TO_ORG_ID
         AND    CUST.SITE_USE_CODE='SHIP_TO'
         AND    CUST.STATUS='A'
         AND    ACCT.STATUS='A' --2752321
         AND    ACCT.ORG_ID = CUST.ORG_ID
         AND    CUST.CUST_ACCT_SITE_ID=ACCT.CUST_ACCT_SITE_ID AND ACCT.PARTY_SITE_ID=PARTY.PARTY_SITE_ID
         AND    PARTY.LOCATION_ID=LOC.LOCATION_ID;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'UNABLE TO ASSOCIATE RECEIVING LOCATION ; OEXWSCHB.PLS ' , 1 ) ;
             END IF;
             FND_MESSAGE.SET_NAME('ONT','OE_DS_NO_LOC_LINK');
             OE_MSG_PUB.Add;
             resultout := 'COMPLETE:INCOMPLETE';
             OE_STANDARD_WF.Save_Messages;
             OE_STANDARD_WF.Clear_Msg_Context;
             return;
       END;

    EXCEPTION
       WHEN OTHERS THEN
           RAISE;
    END;
    -- locking the model line so that scheduling and other fields can be updated
    BEGIN
      SELECT line_id
      INTO   l_line_id
      FROM   oe_order_lines_all
      WHERE  line_id = l_line_rec.line_id
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('OEXWSCHB.pls: unable to lock the line:'||l_line_id,1);
           END IF;
           resultout := 'DEFERRED';
           OE_STANDARD_WF.Clear_Msg_Context;
           RETURN;
    END;

    IF item_asset_flag = 'Y' THEN
       l_charge_account_id := org_material_account;
    ELSE
      IF item_expense_account is null THEN
         l_charge_account_id := org_expense_account;
      ELSE
         l_charge_account_id := item_expense_account;
      END IF;
    END IF;

    /* IF INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_line_rec.ship_from_org_id)  -- INVCONV
    THEN
      GMI_RESERVATION_UTIL.get_OPM_account
                         (
                           v_dest_org_id      => l_line_rec.ship_from_org_id,
                           v_apps_item_id     => l_line_rec.inventory_item_id,
                           v_vendor_site_id   => l_line_rec.org_id ,
                           x_cc_id            => x_charge_account_id,
                           x_ac_id            => x_accrual_account_id
                         );
      l_charge_account_id := x_charge_account_id;
     --
    END IF;   */

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Charge account id : ' ||l_charge_account_id,1);
    END IF;

    l_drop_ship_line_rec.header_id            := l_line_rec.header_id;
    l_drop_ship_line_rec.order_type_name      := l_order_type_name;
    l_drop_ship_line_rec.order_number         := l_header_rec.order_number;
    l_drop_ship_line_rec.line_number          := l_line_rec.line_number;
    l_drop_ship_line_rec.line_id              := l_line_rec.line_id;
    l_drop_ship_line_rec.ship_from_org_id     := l_line_rec.ship_from_org_id;
    l_drop_ship_line_rec.item_type_code       := l_line_rec.item_type_code;
    l_drop_ship_line_rec.inventory_item_id    := l_line_rec.inventory_item_id;
    l_drop_ship_line_rec.open_quantity        := l_line_rec.ordered_quantity;
    l_drop_ship_line_rec.uom_code             := l_line_rec.order_quantity_uom;
    l_drop_ship_line_rec.open_quantity2       := l_line_rec.ordered_quantity2;          -- OPM
    l_drop_ship_line_rec.uom2_code            := l_line_rec.ordered_quantity_uom2;      -- OPM
    l_drop_ship_line_rec.preferred_grade      := l_line_rec.preferred_grade;            -- OPM
    l_drop_ship_line_rec.project_id           := l_line_rec.project_id;
    l_drop_ship_line_rec.task_id              := l_line_rec.task_id;
    l_drop_ship_line_rec.end_item_unit_number := l_line_rec.end_item_unit_number;
    l_drop_ship_line_rec.user_name            := l_user_name;
    l_drop_ship_line_rec.employee_id          := l_employee_id;
    l_drop_ship_line_rec.schedule_ship_date   := l_line_rec.schedule_ship_date;
    l_drop_ship_line_rec.request_date         := l_line_rec.request_date;
    l_drop_ship_line_rec.source_type_code     := l_line_rec.source_type_code;
    l_drop_ship_line_rec.charge_account_id    := l_charge_account_id;
    l_drop_ship_line_rec.accrual_account_id   := x_accrual_account_id;  -- OPM
    l_drop_ship_line_rec.deliver_to_location_id   := l_deliver_to_location_id;
    l_drop_ship_line_rec.unit_list_price      := l_line_rec.unit_list_price;

    -- bug 2509121, pass user_item_description to PO.
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509'
      AND l_line_rec.user_item_description IS NOT NULL
      AND nvl(l_allow_item_desc_update, 'N') = 'Y' THEN
      l_drop_ship_line_rec.item_description := l_line_rec.user_item_description;
    ELSE
      l_drop_ship_line_rec.item_description := null;
    END IF;

    l_drop_ship_tbl(1) := l_drop_ship_line_rec;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Calling Purchase Release' ) ;
    END IF;

    OE_Purchase_Release_PVT.Purchase_Release
                 (p_api_version_number  => 1.0
                  ,p_drop_ship_tbl      => l_drop_ship_tbl
                  ,x_drop_ship_tbl      => ll_drop_ship_tbl
                  ,p_mode               => 'ONLINE'
                  ,x_return_status      => l_return_status
                  ,x_msg_count          => l_msg_count
                  ,x_msg_data           => l_msg_data
                  );

    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.add('Return status : '||ll_drop_ship_tbl(1).return_status,1);
    END IF;


    -- Fix for the bug2097383
    IF ll_drop_ship_tbl(1).return_status <> FND_API.G_RET_STS_SUCCESS THEN

         -- #5873209, do not call fnd api, instead just set the retcode (in OEXCDSPB.pls)
         /*IF ll_drop_ship_tbl(1).return_status = 'E' THEN
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','');
         ELSIF ll_drop_ship_tbl(1).return_status='U' THEN
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
         END IF;*/

         -- Changes for Bug - 2352589
         IF ll_drop_ship_tbl(1).result = 'ONHOLD' THEN
            resultout := 'COMPLETE:ON_HOLD';
         ELSE
            resultout := 'COMPLETE:INCOMPLETE';
         END IF;

         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         return;
    END IF;

    resultout := 'COMPLETE:COMPLETE';
    OE_STANDARD_WF.Clear_Msg_Context;
    return;
  end if;


  IF (funcmode = 'CANCEL') THEN
    null;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_OEOL_SCH', 'Release_to_purchasing',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Release_to_purchasing;

/*-----------------------------------------------------------------------
Proceudure : Is Line Scheduled
Description: This procedure checks to see if the line is scheduled or not.
             This procedure will be called before the line is deferred
             in deferred scheduling workflow activity. We should not defer
             a scheduled line, or a service or a return line.
----------------------------------------------------------------------- */

PROCEDURE Is_Line_Scheduled(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2) /* file.sql.39 change */
IS
 l_item_type_code              VARCHAR2(30);
 l_schedule_status_code        VARCHAR2(30);
 l_line_category_code          VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING IS_LINE_SCHEDULED WORKFLOW COVER ' ) ;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ITEM KEY IS ' || ITEMKEY ) ;
    END IF;

    OE_STANDARD_WF.Set_Msg_Context(actid);


    BEGIN
       SELECT item_type_code,schedule_status_code ,line_category_code
       INTO   l_item_type_code,l_schedule_status_code ,l_line_category_code
       FROM oe_order_lines_all
       WHERE line_id = to_number(itemkey);
    EXCEPTION
       WHEN OTHERS THEN
            raise;
    END;

    IF (l_schedule_status_code is not null) THEN
        -- Line is already scheduled.
        resultout := 'COMPLETE:COMPLETE';
        return;
    END IF;

    IF (l_item_type_code = OE_GLOBALS.G_ITEM_SERVICE) OR
       (l_line_category_code = 'RETURN') THEN

        -- This is a service line or a return line. We will complete
        -- this activity with 'NOT_ELIGIBLE'

        resultout := 'COMPLETE:NOT_ELIGIBLE';
        return;

    END IF;

    -- Line is not scheduled, nor is it a service or return line.
    resultout := 'COMPLETE:INCOMPLETE';
    OE_STANDARD_WF.Clear_Msg_Context;
    return;
  end if;

  IF (funcmode = 'CANCEL') THEN
    null;
    return;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_OEOL_SCH', 'Is_Line_Scheduled',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Is_Line_Scheduled;


PROCEDURE Is_Line_Firmed(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2) /* file.sql.39 change */
IS
l_item_type_code     VARCHAR2(30);
l_firm_demand_flag   VARCHAR2(1);
l_line_category_code VARCHAR2(30);
l_shipped_quantity   NUMBER;
l_fulfilled_flag     VARCHAR2(1);
l_open_flag          VARCHAR2(1);
l_cancelled_flag     VARCHAR2(1);
l_source_type_code   VARCHAR2(30);
BEGIN
  --
  -- RUN mode - normal process execution
  --

  oe_debug_pub.add('Entering Is_Line_Firmed Workflow cover ',1 );
  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL > '110509' THEN
  if (funcmode = 'RUN') then


    oe_debug_pub.add('Item Key is ' || itemkey );
    OE_STANDARD_WF.Set_Msg_Context(actid);


    BEGIN
     --Select all required attributes, listing few attributes here.
       SELECT item_type_code,firm_demand_flag ,line_category_code, shipped_quantity,
              fulfilled_flag,open_flag,cancelled_flag,source_type_code
       INTO   l_item_type_code,l_firm_demand_flag ,l_line_category_code, l_shipped_quantity,
              l_fulfilled_flag,l_open_flag,l_cancelled_flag,l_source_type_code
       FROM   oe_order_lines_all
       WHERE line_id = to_number(itemkey);

    EXCEPTION
       WHEN OTHERS THEN
            raise;
    END;

   IF nvl(l_firm_demand_flag,'N') = 'Y' THEN
        -- Line is already scheduled.
        resultout := 'COMPLETE:COMPLETE';
        return;
   END IF;

   IF  l_item_type_code = 'SERVICE' OR
       l_source_type_code = 'EXTERNAL' OR
       l_shipped_quantity is not null OR
       nvl(l_cancelled_flag,'N') = 'Y' OR
       l_open_flag = 'N'  OR
       nvl(l_fulfilled_flag,'N') = 'Y' OR
       l_line_category_code = 'RETURN' THEN

       -- This is a service line or a return line. We will complete
       -- this activity with 'NOT_ELIGIBLE'

        resultout := 'COMPLETE:NOT_ELIGIBLE';
        return;

   END IF;

  -- Line is not firmed.
    resultout := 'COMPLETE:INCOMPLETE';
    OE_STANDARD_WF.Clear_Msg_Context;
    return;
  end if;

  IF (funcmode = 'CANCEL') THEN
    null;
    return;
  END IF;
 END IF; -- Relase control.
 return;
EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Workflow',1);
    wf_core.context('OE_OEOL_SCH', 'Is_Line_Firmed',
            itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Is_Line_Firmed;

PROCEDURE Firm_demand(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2) /* file.sql.39 change */
IS
l_firm_demand_flag         VARCHAR2(1);
l_top_model_line_id        NUMBER;
l_ato_line_id              NUMBER;
l_ship_model_complete_flag VARCHAR2(1);
--variable added for bug 3814076
l_itemkey                  NUMBER;

CURSOR model is
SELECT ola.line_id line_id
FROM  oe_order_lines_all ola,
      wf_item_activity_statuses wias,
      wf_process_activities wpa
WHERE top_model_line_id = nvl(l_top_model_line_id, ola.top_model_line_id)
And   ato_line_id       = nvl(l_ato_line_id, ola.ato_line_id)
And   wias.item_key = ola.line_id
And   wias.item_type = 'OEOL'
And   wias.process_activity = wpa.instance_id
And   wpa.ACTIVITY_ITEM_TYPE = 'OEOL'
And   wpa.activity_name = 'FIRM_ELIGIBLE'
And   wias.activity_status = 'NOTIFIED';

BEGIN

 IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL > '110509' THEN
    IF (funcmode = 'RUN') THEN

      oe_debug_pub.add('Within Firm Demand Workflow cover ',1 );
      oe_debug_pub.add('Item Key is ' || itemkey );

      OE_STANDARD_WF.Set_Msg_Context(actid);

      Select firm_demand_flag, top_model_line_id, ato_line_id,
             ship_model_complete_flag
      Into   l_firm_demand_flag, l_top_model_line_id, l_ato_line_id,
             l_ship_model_complete_flag
      From   oe_order_lines_all
      Where  line_id = to_number(itemkey);

      IF Nvl(l_firm_demand_flag,'N') = 'N' THEN
       IF l_ship_model_complete_flag= 'Y' THEN

      oe_debug_pub.add('Top model' || l_top_model_line_id );
      oe_debug_pub.add('Ato Model ' || l_top_model_line_id );
      oe_debug_pub.add('SMC ' || l_ship_model_complete_flag );
        Select firm_demand_flag
        Into   l_firm_demand_flag
        From   oe_order_lines
        Where  line_id = l_top_model_line_id
        For Update;

        Update oe_order_lines
        Set firm_demand_flag = 'Y'
        Where  top_model_line_id = l_top_model_line_id;

        l_ato_line_id := Null;

        FOR I IN model LOOP
            IF I.line_id <> to_number(itemkey) THEN
              WF_ENGINE.CompleteActivityInternalName(
                        itemtype  =>  'OEOL',
                        itemkey   =>  to_char(I.line_id) ,
                        activity  =>  'FIRM_ELIGIBLE',
                        result    =>  'COMPLETED');
            END IF;
         END LOOP;


       ELSIF l_ato_line_id is not null THEN

        Select firm_demand_flag
        Into    l_firm_demand_flag
        From   oe_order_lines
        Where  line_id = l_ato_line_id
        For Update;

        Update oe_order_lines
        Set firm_demand_flag = 'Y'
        Where  ato_line_id = l_ato_line_id;

        l_top_model_line_id := Null;

        --  Update the firm flag and also move them from firm eligible block.
        --  The below api will be called in a loop.

         FOR I IN model LOOP
            IF I.line_id <> to_number(itemkey) THEN
              WF_ENGINE.CompleteActivityInternalName(
                        itemtype  =>  'OEOL',
                        itemkey   =>  to_char(I.line_id) ,
                        activity  =>  'FIRM_ELIGIBLE',
                        result    =>  'COMPLETED');
            END IF;
         END LOOP;
       ELSE

     --bug 3814076
        l_itemkey := to_number(itemkey);
        Select firm_demand_flag
        Into    l_firm_demand_flag
        From   oe_order_lines
        Where  line_id = l_itemkey
        For Update;

        Update oe_order_lines
        Set firm_demand_flag = 'Y'
        Where  line_id = to_number(itemkey);

        -- Update the firm flag and also move them from firm eligible block.
/*        WF_ENGINE.CompleteActivityInternalName(
                        itemtype  =>  'OEOL',
                        itemkey   =>  itemkey,
                        activity  =>  'FIRM_ELIGIBLE',
                        result    =>  'COMPLETED');
*/
       END IF;

      ELSE

        oe_debug_pub.add('Line is already firmed' );

      END IF;
      resultout := 'COMPLETE:COMPLETE';
      OE_STANDARD_WF.Clear_Msg_Context;
      return;
    END IF;

    IF (funcmode = 'CANCEL') THEN
      null;
      return;
    END IF;
 END IF; -- Release.
 Return;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_OEOL_SCH', 'Firm_Demand',
            itemtype, itemkey, to_char(actid), funcmode);
    oe_debug_pub.add('error in workflow');
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

End Firm_Demand;
END OE_OEOL_SCH;

/
