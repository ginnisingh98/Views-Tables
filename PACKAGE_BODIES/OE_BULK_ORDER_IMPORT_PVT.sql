--------------------------------------------------------
--  DDL for Package Body OE_BULK_ORDER_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_ORDER_IMPORT_PVT" AS
/* $Header: OEBVIMNB.pls 120.13.12010000.8 2010/03/06 08:50:29 srsunkar ship $ */


G_PKG_NAME         CONSTANT     VARCHAR2(30):= 'OE_BULK_ORDER_IMPORT_PVt';


-----------------------------------------------------------------
-- DATA TYPES (RECORD/TABLE TYPES)
-----------------------------------------------------------------

TYPE number_arr IS TABLE OF number;
TYPE char30_arr IS TABLE OF varchar2(30);
TYPE char50_arr IS TABLE OF varchar2(50);

TYPE Order_Rec_Type IS RECORD
( order_source_id               number_arr := number_arr()
, orig_sys_document_ref         char50_arr := char50_arr()
, num_lines                     number_arr := number_arr()
, request_id                    number_arr := number_arr()
, batch_id                      number_arr := number_arr()
, org_id                        number_arr := number_arr()

);

TYPE Instance_Rec_Type IS RECORD
( request_id                    NUMBER
, total_lines                   NUMBER := 0
);
TYPE Instance_Tbl_Type IS TABLE OF Instance_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Batch_Rec_Type IS RECORD
( batch_id                      NUMBER
, total_lines                   NUMBER
, org_id                        NUMBER -- For MOAC
);
TYPE Batch_Tbl_Type IS TABLE OF Batch_Rec_Type
INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------
-- LOCAL PROCEDURES/FUNCTIONS
---------------------------------------------------------------------

PROCEDURE Initialize_Request
( p_request_id               IN  NUMBER
, p_validate_desc_flex       IN  VARCHAR2
, p_rtrim_data               IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)IS
  l_start_time               NUMBER;
  l_end_time                 NUMBER;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------------------------------------------
   -- Initialize Request level globals/variables, these will be
   -- used in the batch processing APIs later.
   -- These do not vary with the batch being processed
   -- and are common for a request.
   -- It will also include profile options that do not change
   -- for a given request_id
   ------------------------------------------------------------

   -- Set the globals in OE_BULK_ORDER_PVT using system parameters

   -- Initialize Request ID Global

   OE_BULK_ORDER_PVT.G_REQUEST_ID := p_request_id;

   --  This ensures that the WF selector functions do not test context.

   OE_STANDARD_WF.RESET_APPS_CONTEXT_OFF;

   -- Initialize Global Flex Status

   IF p_validate_desc_flex = 'Y' THEN

      OE_BULK_ORDER_PVT.G_OE_HEADER_ATTRIBUTES :=
        OE_BULK_ORDER_PVT.GET_FLEX_ENABLED_FLAG('OE_HEADER_ATTRIBUTES');
      OE_BULK_ORDER_PVT.G_OE_HEADER_GLOBAL_ATTRIBUTE :=
        OE_BULK_ORDER_PVT.GET_FLEX_ENABLED_FLAG('OE_HEADER_GLOBAL_ATTRIBUTE');
      OE_BULK_ORDER_PVT.G_OE_HEADER_TP_ATTRIBUTES :=
        OE_BULK_ORDER_PVT.GET_FLEX_ENABLED_FLAG('OE_HEADER_TP_ATTRIBUTES');

      OE_BULK_ORDER_PVT.G_OE_LINE_ATTRIBUTES :=
        OE_BULK_ORDER_PVT.GET_FLEX_ENABLED_FLAG('OE_LINE_ATTRIBUTES');
      OE_BULK_ORDER_PVT.G_OE_LINE_INDUSTRY_ATTRIBUTE :=
        OE_BULK_ORDER_PVT.GET_FLEX_ENABLED_FLAG('OE_LINE_INDUSTRY_ATTRIBUTE');
      OE_BULK_ORDER_PVT.G_OE_LINE_TP_ATTRIBUTES :=
        OE_BULK_ORDER_PVT.GET_FLEX_ENABLED_FLAG('OE_LINE_TP_ATTRIBUTES');

   END IF;

   -- Initialize OE_GLOBALS.g_org_id
   --OE_GLOBALS.SET_CONTEXT; removed as part of MOAC

   IF OE_GLOBALS.G_EC_INSTALLED IS NULL THEN
     OE_GLOBALS.G_EC_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(175);
   END IF;

   ----------------------------------------------------------
   -- Set the Global to RTRIM interface data
   ----------------------------------------------------------
   G_RTRIM_IFACE_DATA := p_rtrim_data;

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Initialize_Request Error :'||substr(sqlerrm,1,200));
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Initialize_Request'
        );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Initialize_Request;

PROCEDURE Initialize_Batch
( x_return_status OUT NOCOPY VARCHAR2
)IS
  l_start_time               NUMBER;
  l_end_time                 NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------------------------------------------
   -- Initialize Org Level globals/variables
   -- used in the batch processing APIs later.
   -- These do not vary for an org_id  being processed
   -- It will also include system parameters that only change
   -- during the OU change.
   ------------------------------------------------------------

   OE_BULK_ORDER_PVT.G_SCHEDULE_LINE_ON_HOLD := OE_Sys_Parameters.value('ONT_SCHEDULE_LINE_ON_HOLD');

   OE_BULK_ORDER_PVT.G_RESERVATION_TIME_FENCE := OE_Sys_Parameters.value('ONT_RESERVATION_TIME_FENCE');

   OE_BULK_ORDER_PVT.G_ITEM_ORG := OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID');

   OE_BULK_ORDER_PVT.G_SOB_ID := OE_Sys_Parameters.value('SET_OF_BOOKS_ID');

   OE_BULK_ORDER_PVT.G_CUST_RELATIONS := OE_Sys_Parameters.value('CUSTOMER_RELATIONSHIPS_FLAG');

   OE_BULK_ORDER_PVT.G_CUST_RELATIONS := OE_Sys_Parameters.value('CUSTOMER_RELATIONSHIPS_FLAG');


   ----------------------------------------------------------
   -- Load Hold Sources into globals
   ----------------------------------------------------------
   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 THEN
     SELECT hsecs INTO l_start_time from v$timer;
   END IF;

   -- Load the Hold Sources Globals
   OE_Bulk_Holds_PVT.Load_Hold_Sources;

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level  > 0 THEN
      SELECT hsecs INTO l_end_time from v$timer;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Time spent in Load Hold Sources is (sec) '
          ||((l_end_time-l_start_time)/100));

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Initialize_Batch Error :'||substr(sqlerrm,1,200));
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Initialize_Batch'
        );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Initialize_Batch;


PROCEDURE Post_Process
( p_batch_id                 IN  NUMBER
, p_validate_only            IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR
)IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- No need to delete records if it is validation only mode

   if p_validate_only = 'Y' then
      return;
   end if;

   -- Delete all successfully processed records from interface
   -- tables

   delete from oe_actions_interface
   where (order_source_id, orig_sys_document_ref) IN
            (select order_source_id, orig_sys_document_ref
             from oe_headers_iface_all
             where batch_id = p_batch_id
               and nvl(error_flag,'N') = 'N');

  --ER 9060917
  If NVL (Fnd_Profile.Value('ONT_HVOP_DROP_INVALID_LINES'), 'N')='Y' then

  	DELETE FROM oe_price_adjs_interface
	WHERE(order_source_id,   orig_sys_document_ref) IN
	  (SELECT order_source_id,
	     orig_sys_document_ref
	   FROM oe_headers_iface_all a
	   WHERE batch_id = p_batch_id
	   AND nvl(error_flag,'N') = 'N'
	   AND EXISTS
	    (SELECT 1
	     FROM oe_lines_iface_all b
	     WHERE b.orig_sys_document_ref = a.orig_sys_document_ref
	     AND b.order_source_id = a.order_source_id
	     AND batch_id = p_batch_id
             AND nvl(error_flag,    'N') = 'N'));

         DELETE FROM oe_price_adjs_interface
	 WHERE(order_source_id,   orig_sys_line_ref,   orig_sys_document_ref) IN
	   (SELECT a.order_source_id,
	      a.orig_sys_line_ref,
	      a.orig_sys_document_ref
	    FROM oe_lines_iface_all a
	    WHERE nvl(a.error_flag,    'N') = 'N'
	    AND(a.order_source_id,    a.orig_sys_document_ref) IN
	     (SELECT order_source_id,
	        orig_sys_document_ref
	      FROM oe_headers_iface_all b
	      WHERE nvl(a.error_flag,    'N') = 'N'
	      AND batch_id = p_batch_id));


	UPDATE oe_headers_iface_all a
	SET operation_code = 'UPDATE'
	WHERE a.batch_id = p_batch_id
	AND nvl(error_flag,'N') = 'N'
	 AND(order_source_id,   orig_sys_document_ref) IN
	  (SELECT b.order_source_id,
	     b.orig_sys_document_ref
	   FROM oe_lines_iface_all b
	   WHERE a.orig_sys_document_ref = b.orig_sys_document_ref
	   AND a.order_source_id = b.order_source_id
	   AND nvl(error_flag,    'N') = 'Y'
	   AND EXISTS
	    (SELECT 'X'
	     FROM oe_lines_iface_all c
	     WHERE c.orig_sys_document_ref = a.orig_sys_document_ref
	     AND c.order_source_id = a.order_source_id
	     AND nvl(error_flag,    'N') = 'N'));


	DELETE FROM oe_lines_iface_all
   	WHERE(order_source_id,   orig_sys_document_ref) IN
     	     (SELECT order_source_id,orig_sys_document_ref
      	      FROM oe_headers_iface_all
      	      WHERE batch_id = p_batch_id
      	      AND nvl(error_flag,   'N') = 'N')
	AND nvl(error_flag,  'N') = 'N';

        DELETE FROM oe_headers_iface_all a
	WHERE batch_id = p_batch_id
	AND nvl(error_flag,   'N') = 'N'
	AND NOT EXISTS
	 	 (SELECT 1
	 	  FROM oe_lines_iface_all b
	 	  WHERE b.orig_sys_document_ref = a.orig_sys_document_ref
	 	  AND b.order_source_id = a.order_source_id
                  AND nvl(error_flag,    'N') = 'Y');


  --ER 	9060917
  else
   delete from oe_price_adjs_interface
   where (order_source_id, orig_sys_document_ref) IN
            (select order_source_id, orig_sys_document_ref
             from oe_headers_iface_all
             where batch_id = p_batch_id
               and nvl(error_flag,'N') = 'N');

   delete from oe_lines_interface
   where (order_source_id, orig_sys_document_ref) IN
            (select order_source_id, orig_sys_document_ref
             from oe_headers_iface_all
             where batch_id = p_batch_id
               and nvl(error_flag,'N') = 'N');

   delete from oe_headers_iface_all
   where batch_id = p_batch_id
     and nvl(error_flag,'N') = 'N';
  end if;

   -- commit after every batch is processed
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Post_Process'
        );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Post_Process;


---------------------------------------------------------------------
-- PUBLIC PROCEDURES/FUNCTIONS
---------------------------------------------------------------------

-----------------------------------------------------------
--   Procedure: Order_Import_Conc_Pgm
-----------------------------------------------------------
PROCEDURE ORDER_IMPORT_CONC_PGM(
errbuf OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY NUMBER
  ,p_operating_unit                     IN  NUMBER
  ,p_order_source_id                    IN  NUMBER
  ,p_orig_sys_document_ref              IN  VARCHAR2
  ,p_validate_only                      IN  VARCHAR2 DEFAULT 'N'
  ,p_validate_desc_flex                 IN  VARCHAR2 DEFAULT 'Y'
  ,p_defaulting_mode                    IN  VARCHAR2 DEFAULT 'N'
  ,p_debug_level                        IN  NUMBER DEFAULT NULL
  ,p_num_instances                      IN  NUMBER DEFAULT 1
  ,p_batch_size                         IN  NUMBER DEFAULT 10000
  ,p_rtrim_data                         IN  VARCHAR2 DEFAULT 'N'
  ,p_process_recs_with_no_org           IN  VARCHAR2 DEFAULT 'Y'
  ,p_process_tax                        IN  VARCHAR2 DEFAULT 'N'
 , p_process_configurations             IN  VARCHAR2 DEFAULT 'N'
 , p_dummy                              IN  VARCHAR2 DEFAULT NULL
 , p_validate_configurations            IN  VARCHAR2 DEFAULT 'Y'
 , p_schedule_configurations            IN  VARCHAR2 DEFAULT 'N'
)
IS
  l_init_msg_list			VARCHAR2(1)  := FND_API.G_TRUE;
  l_change_sequence			VARCHAR2(50);
  l_order_source_id                     NUMBER;
  l_orig_sys_document_ref		VARCHAR2(50);
  l_orig_sys_line_ref			VARCHAR2(50);
  l_request_id				NUMBER;
  l_new_request_id		 	NUMBER;
  b_org_id                              NUMBER;
  l_count_msgs              		NUMBER;
  l_count              		NUMBER;
  l_message_text              		VARCHAR2(2000)  := '';

  l_msg_count              		NUMBER;
  l_msg_data              		VARCHAR2(2000)  := '';
  l_return_status             		VARCHAR2(1) 	:= '';

  l_count_batch			NUMBER := 0;
  l_count_batch_warning		NUMBER := 0;
  l_count_batch_success		NUMBER := 0;
  l_count_batch_failure		NUMBER := 0;

  l_filename              		VARCHAR2(100);
  l_database				VARCHAR2(100);

  l_api_name		       CONSTANT VARCHAR2(30):= 'Order_Import_Main';
  l_row_count              NUMBER;
  l_num_instances          NUMBER := p_num_instances;

  l_closed_flag            VARCHAR2(1);

  -- For the Parent Wait for child to finish
  l_req_data               VARCHAR2(10);
  l_req_data_counter       NUMBER;

  l_default_org_id         NUMBER;

  -----------------------------------------------------------
  -- Batches cursor
  -----------------------------------------------------------
    CURSOR l_batch_cursor IS
    SELECT DISTINCT batch_id,org_id
      FROM oe_headers_iface_all
     WHERE request_id = l_request_id;

  --ER 9060917
  ------------------------------------------------------------
  -- Paritially processed orders
  ------------------------------------------------------------

     CURSOR l_partial_orders IS
     SELECT orig_sys_document_ref
     FROM oe_headers_iface_all a
     WHERE request_id = l_request_id
     AND nvl(error_flag,   'N') = 'N'
     AND EXISTS
       (SELECT orig_sys_line_ref
        FROM oe_lines_iface_all b
        WHERE b.orig_sys_document_ref = a.orig_sys_document_ref
        AND b.order_source_id = a.order_source_id
        AND nvl(error_flag,    'N') = 'Y')
      ORDER BY a.order_source_id, a.orig_sys_document_ref  ;

  --End of ER 9060917

  ------------------------------------------------------------
  -- Messages cursor
  ------------------------------------------------------------
  CURSOR l_msg_cursor IS
    -- Oracle IT bug 01/06/2000 1572080
    SELECT /*+ INDEX (a,OE_PROCESSING_MSGS_N2)
           USE_NL (a b) */
           a.order_source_id
         , a.original_sys_document_ref
    	    , a.change_sequence
         , a.original_sys_document_line_ref
         , nvl(a.message_text, b.message_text)
      FROM oe_processing_msgs a, oe_processing_msgs_tl b
     WHERE a.request_id = l_request_id
       AND a.transaction_id = b.transaction_id (+)
       AND b.language (+) = oe_globals.g_lang
  ORDER BY a.order_source_id, a.original_sys_document_ref, a.change_sequence;

  l_order_rec                Order_Rec_Type;
  l_instance_tbl             Instance_Tbl_Type;
  l_batch_tbl                Batch_Tbl_Type;

  -----------------------------------------------------------
  -- Lines per order cursor
  -----------------------------------------------------------
  -- Outer join to lines interface table so that the cursor also
  -- selects headers with no order lines.
  -- Headers with no order lines will be counted as 1 line
  -- (num_lines = 1) for assigning batches.

  CURSOR c_lines_per_order IS
     SELECT /* MOAC_SQL_CHANGE */ h.order_source_id
            , h.orig_sys_document_ref
            , count(*) num_lines
            , NULL request_id
            , NULL batch_id
            , h.org_id
     FROM oe_headers_interface h, oe_lines_iface_all l,  --bug 4685432
          oe_sys_parameters_all sys
     WHERE h.order_source_id = nvl(p_order_source_id,h.order_source_id)
       AND h.orig_sys_document_ref = nvl(p_orig_sys_document_ref,h.orig_sys_document_ref)
       AND h.org_id = l.org_id
       AND sys.org_id(+) = h.org_id                         --bug 4685432, 5209313
       AND sys.parameter_code(+) = 'ENABLE_FULFILLMENT_ACCEPTANCE'
       AND nvl(sys.parameter_value,'N') = 'N'
       -- This phase of BULK supports only CREATION of complete orders
       AND nvl(h.operation_code,'CREATE') IN ('INSERT','CREATE')
       AND h.request_id IS NULL
       AND h.order_source_id <> 20
       AND nvl(h.error_flag,'N') = 'N'
       AND nvl(h.ineligible_for_hvop, 'N')='N'
       AND nvl(h.ready_flag,'Y') = 'Y'
       AND nvl(h.rejected_flag,'N') = 'N'
       AND nvl(h.force_apply_flag,'Y') = 'Y'
       AND h.orig_sys_document_ref = l.orig_sys_document_ref(+)
       AND h.order_source_id = l.order_source_id(+)
       AND h.org_id = l.org_id(+)
       AND nvl(h.change_sequence,               FND_API.G_MISS_CHAR)
         = nvl(l.change_sequence(+),               FND_API.G_MISS_CHAR)
       AND nvl(l.error_flag(+),'N')                  = 'N'
       AND nvl(l.rejected_flag(+),'N')              = 'N'
       AND nvl (h.payment_type_code, ' ') <>  'CREDIT_CARD'
       AND  nvl(h.order_source_id,0)  <> 10
       AND  h.customer_preference_set_code IS NULL
       AND  h.return_reason_code IS NULL
       AND  nvl(h.closed_flag ,'N') = 'N'
       AND  nvl(l.source_type_code,'INTERNAL') = 'INTERNAL'
       AND  l.arrival_set_name IS NULL
       AND  l.ship_set_name IS NULL
       AND  l.commitment_id IS NULL
       AND  l.return_reason_code IS NULL
       AND  l.override_atp_date_code IS NULL
       AND h.org_id = nvl(p_operating_unit,h.org_id)
       -- Do not process orders with manual sales credits, manual
       -- pricing attributes or with action requests other than booking
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_credits_iface_all sc
                        WHERE sc.order_source_id = h.order_source_id
                          AND sc.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND sc.org_id = h.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_price_atts_iface_all pa
                        WHERE pa.order_source_id = h.order_source_id
                          AND pa.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = pa.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_actions_iface_all a
                        WHERE a.order_source_id = h.order_source_id
                          AND a.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND operation_code <> 'BOOK_ORDER'
                          AND h.org_id = a.org_id)
     GROUP BY h.org_id, h.order_source_id, h.orig_sys_document_ref, h.change_sequence
     ORDER BY h.org_id, h.order_source_id, h.orig_sys_document_ref ;

  ----------------------------------------------------------
  -- second lines cursor to get the orders with null org
  ----------------------------------------------------------
  CURSOR c_lines_per_order_2 IS
     SELECT /* MOAC_SQL_CHANGE */ order_source_id,
       orig_sys_document_ref,
       num_lines,
       request_id,
       batch_id,
       org_id
     FROM (
     SELECT   h.order_source_id
            , h.orig_sys_document_ref
            , count(*) num_lines
            , NULL request_id
            , NULL batch_id
            , h.org_id org_id
     FROM oe_headers_interface h, oe_lines_iface_all l,  --bug 4685432
          oe_sys_parameters_all sys
     WHERE h.order_source_id = nvl(p_order_source_id,h.order_source_id)
       AND h.orig_sys_document_ref = nvl(p_orig_sys_document_ref,h.orig_sys_document_ref)
       AND sys.org_id(+) = h.org_id                         --bug 4685432, 5209313
       AND sys.parameter_code(+) = 'ENABLE_FULFILLMENT_ACCEPTANCE'
       AND nvl(sys.parameter_value,'N') = 'N'
       -- This phase of BULK supports only CREATION of complete orders
       AND nvl(h.operation_code,'CREATE') IN ('INSERT','CREATE')
       AND h.request_id IS NULL
       AND h.order_source_id <> 20
       AND nvl(h.error_flag,'N') = 'N'
       AND nvl(h.ready_flag,'Y') = 'Y'
       AND nvl(h.rejected_flag,'N') = 'N'
       AND nvl(h.force_apply_flag,'Y') = 'Y'
       AND h.orig_sys_document_ref = l.orig_sys_document_ref(+)
       AND h.order_source_id = l.order_source_id(+)
       AND h.org_id IS NOT NULL
       AND h.org_id = l.org_id(+)
       AND nvl(h.change_sequence, FND_API.G_MISS_CHAR)
         = nvl(l.change_sequence(+), FND_API.G_MISS_CHAR)
       AND nvl(l.error_flag(+),'N')                  = 'N'
       AND nvl(l.rejected_flag(+),'N')              = 'N'
       AND h.org_id = nvl(p_operating_unit,h.org_id)
       -- Do not process orders with manual sales credits, manual
       -- pricing attributes or with action requests other than booking
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_credits_iface_all sc
                        WHERE sc.order_source_id = h.order_source_id
                          AND sc.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = sc.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_price_atts_iface_all pa
                        WHERE pa.order_source_id = h.order_source_id
                          AND pa.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = pa.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_actions_iface_all a
                        WHERE a.order_source_id = h.order_source_id
                          AND a.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = a.org_id
                          AND operation_code <> 'BOOK_ORDER')
     GROUP BY h.org_id, h.order_source_id, h.orig_sys_document_ref, h.change_sequence
     UNION
     SELECT   h.order_source_id
            , h.orig_sys_document_ref
            , count(*) num_lines
            , NULL request_id
            , NULL batch_id
            , l_default_org_id org_id
     FROM oe_headers_iface_all h, oe_lines_iface_all l,  --bug 4685432
          oe_sys_parameters_all sys
     WHERE h.order_source_id = nvl(p_order_source_id,h.order_source_id)
       AND h.orig_sys_document_ref = nvl(p_orig_sys_document_ref,h.orig_sys_document_ref)
       AND nvl(sys.org_id,l_default_org_id) = l_default_org_id    --bug 4685432, 5209313
       AND sys.org_id(+) = h.org_id
       AND sys.parameter_code(+) = 'ENABLE_FULFILLMENT_ACCEPTANCE'
       AND nvl(sys.parameter_value,'N') = 'N'
       -- This phase of BULK supports only CREATION of complete orders
       AND nvl(h.operation_code,'CREATE') IN ('INSERT','CREATE')
       AND h.request_id IS NULL
       AND h.order_source_id <> 20
       AND nvl(h.error_flag,'N') = 'N'
       AND nvl(h.ready_flag,'Y') = 'Y'
       AND nvl(h.rejected_flag,'N') = 'N'
       AND nvl(h.force_apply_flag,'Y') = 'Y'
       AND h.orig_sys_document_ref = l.orig_sys_document_ref(+)
       AND h.order_source_id = l.order_source_id(+)
       AND nvl(h.org_id, l_default_org_id) = nvl(l.org_id(+), l_default_org_id)
       AND nvl(h.change_sequence, FND_API.G_MISS_CHAR)
         = nvl(l.change_sequence(+), FND_API.G_MISS_CHAR)
       AND nvl(l.error_flag(+),'N')                  = 'N'
       AND nvl(l.rejected_flag(+),'N')              = 'N'
       AND (h.org_id is NULL AND
            l_default_org_id = nvl(p_operating_unit,l_default_org_id))
       -- Do not process orders with manual sales credits, manual
       -- pricing attributes or with action requests other than booking
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_credits_iface_all sc
                        WHERE sc.order_source_id = h.order_source_id
                          AND sc.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND NVL(h.org_id, l_default_org_id) =
                              NVL(sc.org_id, l_default_org_id))
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_price_atts_iface_all pa
                        WHERE pa.order_source_id = h.order_source_id
                          AND pa.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND NVL(h.org_id, l_default_org_id) =
                              NVL(pa.org_id, l_default_org_id))
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_actions_iface_all a
                        WHERE a.order_source_id = h.order_source_id
                          AND a.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND NVL(h.org_id, l_default_org_id) =
                              NVL(a.org_id, l_default_org_id)
                          AND operation_code <> 'BOOK_ORDER')
     GROUP BY h.org_id, h.order_source_id, h.orig_sys_document_ref, h.change_sequence)
     ORDER BY org_id, order_source_id, orig_sys_document_ref ;

  -- Start bug 4685432
  -------------------------------------
  -- Get Customer Acceptance enabled OU
  -------------------------------------
  CURSOR ca_enabled_cur IS
   SELECT count(org_id), org_id
     FROM oe_sys_parameters_syn
    WHERE parameter_code = 'ENABLE_FULFILLMENT_ACCEPTANCE'
      AND nvl(parameter_value,'N') = 'Y'
      AND ((p_operating_unit IS NULL) OR (org_id = p_operating_unit))
    GROUP BY org_id
    ORDER BY org_id ;
  -- End bug 4685432

  -----------------------------------------------------------
  -- Headers Cursor
  -----------------------------------------------------------
  CURSOR c_headers(p_request_id NUMBER) IS
     SELECT order_source_id, orig_sys_document_ref,org_id,request_id
       FROM oe_headers_iface_all
      WHERE request_id = p_request_id
   ORDER BY order_source_id, orig_sys_document_ref, change_sequence;

minimum                      number;
l_order_count                number;
l_index                      number;
l_instance_index             number;
l_batch_index                number;

I                            number;
l_batch_id                   number;
l_num_lines                  number;
l_batch_found                BOOLEAN;
l_max_batches                NUMBER := 1000;
v_end                        number;
v_start                      number;
l_exists                     varchar2(1);
l_start_total_time           number;
l_end_total_time             number;
l_batch_orders               number;
l_entered_orders             number;
l_booked_orders              number;
l_error_orders               number;
l_oper_unit_name             varchar2(240) := NULL;  --bug 4685432
BEGIN

   -----------------------------------------------------------
   -- Log Output file
   -----------------------------------------------------------

   fnd_file.put_line(FND_FILE.OUTPUT, '');
   fnd_file.put_line(FND_FILE.OUTPUT, 'BULK Order Import Concurrent Program');
   fnd_file.put_line(FND_FILE.OUTPUT, '');
   fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
   fnd_file.put_line(FND_FILE.OUTPUT, 'Validate Only: '|| p_validate_only);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Validate Desc Flex: '|| p_validate_desc_flex);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Source: '|| p_order_source_id);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Ref: '|| p_orig_sys_document_ref);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Instances: '|| p_num_instances);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Defaulting Mode: '|| p_defaulting_mode);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Process Recs With No Org: '|| p_process_recs_with_no_org );
   fnd_file.put_line(FND_FILE.OUTPUT, '');
   fnd_file.put_line(FND_FILE.OUTPUT,'Process Configurations  '||P_PROCESS_CONFIGURATIONS);
   fnd_file.put_line(FND_FILE.OUTPUT, ' Process Tax  ' || p_process_tax  );


   -----------------------------------------------------------
   -- Setting Debug Mode and File
   -----------------------------------------------------------

   FND_FILE.Put_Line(FND_FILE.OUTPUT,'Debug Level: '||nvl(p_debug_level,0));

   IF nvl(p_debug_level, 0) > 0 THEN
      FND_PROFILE.PUT('ONT_DEBUG_LEVEL',p_debug_level);
   --moved this stmt in if loop for bug 3747791
       l_filename := oe_debug_pub.set_debug_mode ('CONC');
   END IF;

  -- l_filename := oe_debug_pub.set_debug_mode ('CONC');

   -----------------------------------------------------------
   -- Get Concurrent Request Id
   -----------------------------------------------------------

   FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);

   fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));


   If p_operating_unit IS NOT NULL Then
     MO_GLOBAL.set_policy_context('S',p_operating_unit);
   End If;
   l_default_org_id := MO_UTILS.get_default_org_id;

   If p_debug_level > 0 Then
     oe_debug_pub.add('Default Org Id '||l_default_org_id);
   End If;

   fnd_file.put_line(FND_FILE.OUTPUT, 'Org Id: '|| to_char(p_operating_unit));
   fnd_file.put_line(FND_FILE.OUTPUT, '');

   l_req_data := fnd_conc_global.request_data;
   if (l_req_data is not null) then
      l_req_data_counter := to_number(l_req_data);
      l_req_data_counter := l_req_data_counter + 1;
   else
      l_req_data_counter := 1;
   end if;

   --Start bug 4685432
   ---------------------------------------------------------------
   -- Populate Customer Acceptance enabled informations
   -- If Customer Acceptance is enabled then HVOP is not supported
   ---------------------------------------------------------------
   FOR ca_enabled_rec IN ca_enabled_cur LOOP
       BEGIN
         SELECT name
           INTO l_oper_unit_name
           FROM hr_operating_units
          WHERE organization_id = ca_enabled_rec.org_id ;

         FND_MESSAGE.SET_NAME('ONT','ONT_BULK_NOT_SUPP_ACCEPTANCE');
	 FND_MESSAGE.SET_TOKEN('OU','''' || l_oper_unit_name || '''');
         fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.GET);

	 EXCEPTION
           WHEN OTHERS THEN
             NULL ;
	 END ;
   END LOOP;

	if p_debug_level >0 then
		oe_debug_pub.add('process recs with no org '||p_process_recs_with_no_org);
		oe_debug_pub.add('G_CONFIG_EFFECT_DATE'||OE_BULK_ORDER_PVT.G_CONFIG_EFFECT_DATE);
	end if;
   --End bug 4685432

   -----------------------------------------------------------

   -----------------------------------------------------------
   -- If number of instances > 0, submit order import child requests
   -- and assign request_id/batch_id to all orders in this BULK import run.
   -----------------------------------------------------------
   IF l_num_instances > 0 THEN

     --------------------------------------------------------------
     -- IMPORTANT: This check is necessary as an EXIT criteria.
     -- Parent requests are automatically re-submitted by the concurrent
     -- manager until there are no more child requests submitted.
     -- Without this exit criteria, an infinite number of child
     -- requests will be spawned.
     --------------------------------------------------------------

     BEGIN

   If p_process_recs_with_no_org = 'Y' Then

          oe_debug_pub.add('p_process_recs_with_no_org =Y',1);

       SELECT count(orig_sys_document_ref)
       INTO l_row_count
       FROM(
       SELECT /* MOAC_SQL_CHANGE */
             h.orig_sys_document_ref orig_sys_document_ref
       FROM oe_headers_interface h, oe_order_sources os,  --bug 4685432
            oe_sys_parameters_all sys
       WHERE request_id IS NULL
       AND sys.org_id(+) = h.org_id                          --bug 4685432, 5209313
       AND sys.parameter_code(+) = 'ENABLE_FULFILLMENT_ACCEPTANCE'
       AND nvl(sys.parameter_value,'N') = 'N'
       AND os.order_source_id = nvl(p_order_source_id,os.order_source_id)
       AND os.order_source_id <> 20
       AND h.order_source_id = os.order_source_id
       AND orig_sys_document_ref = nvl(p_orig_sys_document_ref,orig_sys_document_ref)
       AND nvl(operation_code,'CREATE') IN ('INSERT','CREATE')
       AND nvl(error_flag,'N') = 'N'
       AND nvl(ready_flag,'Y') = 'Y'
       AND nvl(rejected_flag,'N') = 'N'
       AND nvl(force_apply_flag,'Y') = 'Y'
       AND nvl(Ineligible_for_hvop, 'N')='N'
       AND nvl (h.payment_type_code, ' ') <>  'CREDIT_CARD'
       AND  nvl(h.order_source_id,0)  <> 10
       AND  h.customer_preference_set_code IS NULL
       AND  h.return_reason_code IS NULL
       AND  nvl(h.closed_flag ,'N') = 'N'
       AND h.org_id = nvl(p_operating_unit,h.org_id)
       AND NOT EXISTS
       ( SELECT orig_sys_line_ref
         FROM oe_lines_iface_all l
         WHERE h.orig_sys_document_ref = l.orig_sys_document_ref
          AND h.order_source_id = l.order_source_id
          AND  (nvl(l.source_type_code,'INTERNAL') = 'EXTERNAL'
                        OR  l.arrival_set_name IS NOT NULL
                        OR  l.ship_set_name IS NOT NULL
              OR  l.commitment_id IS NOT NULL
              OR  l.return_reason_code IS NOT NULL
              OR  l.override_atp_date_code IS NOT NULL OR
                  (l.item_type_code IN ('MODEL', 'CLASS', 'OPTION') AND
                               l.top_model_line_ref is not null AND
                               p_process_configurations = 'N' )))

       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_credits_iface_all sc
                        WHERE sc.order_source_id = h.order_source_id
                          AND sc.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = sc.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_price_atts_iface_all pa
                        WHERE pa.order_source_id = h.order_source_id
                          AND pa.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = pa.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_actions_iface_all a
                        WHERE a.order_source_id = h.order_source_id
                          AND a.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND h.org_id = a.org_id
                          AND operation_code <> 'BOOK_ORDER')
       UNION
       SELECT h.orig_sys_document_ref orig_sys_document_ref
       FROM oe_headers_iface_all h, oe_order_sources os,  --bug 4685432
            oe_sys_parameters_all sys
       WHERE request_id IS NULL
       AND nvl(sys.org_id,l_default_org_id) = l_default_org_id    --bug 4685432, 5209313
       AND sys.org_id(+) = h.org_id
       AND sys.parameter_code(+) = 'ENABLE_FULFILLMENT_ACCEPTANCE'
       AND nvl(sys.parameter_value,'N') = 'N'
       AND os.order_source_id = nvl(p_order_source_id,os.order_source_id)
       AND os.order_source_id <> 20
       AND h.order_source_id = os.order_source_id
       AND orig_sys_document_ref = nvl(p_orig_sys_document_ref,orig_sys_document_ref)
       AND nvl(operation_code,'CREATE') IN ('INSERT','CREATE')
       AND nvl(error_flag,'N') = 'N'
       AND nvl(ready_flag,'Y') = 'Y'
       AND nvl(rejected_flag,'N') = 'N'
       AND nvl(force_apply_flag,'Y') = 'Y'
       AND (h.org_id is NULL AND
            l_default_org_id = nvl(p_operating_unit,l_default_org_id))
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_credits_iface_all sc
                        WHERE sc.order_source_id = h.order_source_id
                          AND sc.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND NVL(h.org_id, l_default_org_id) =
                              NVL(sc.org_id, l_default_org_id))
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_price_atts_iface_all pa
                        WHERE pa.order_source_id = h.order_source_id
                          AND pa.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND NVL(h.org_id, l_default_org_id) =
                              NVL(pa.org_id, l_default_org_id))
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_actions_iface_all a
                        WHERE a.order_source_id = h.order_source_id
                          AND a.orig_sys_document_ref
                                    = h.orig_sys_document_ref
                          AND NVL(h.org_id, l_default_org_id) =
                              NVL(a.org_id, l_default_org_id)
                          AND operation_code <> 'BOOK_ORDER'));
	if p_debug_level > 0 then
		oe_debug_pub.add('the number of orders to process is '||l_row_count);
	end if;
    Else

     -- No need to select NULL org_id records.
      oe_debug_pub.add('p_process_recs_with_no_org =N',1);
     SELECT /* MOAC_SQL_CHANGE */ count(*)
     INTO l_row_count
     FROM oe_headers_interface h, oe_order_sources os,  --bug 4685432
          oe_sys_parameters_all sys
     WHERE request_id IS NULL
       AND sys.org_id(+) = h.org_id                        --bug 4685432, 5209313
       AND sys.parameter_code(+) = 'ENABLE_FULFILLMENT_ACCEPTANCE'
       AND nvl(sys.parameter_value,'N') = 'N'
       AND os.order_source_id = nvl(p_order_source_id,os.order_source_id)
       AND os.order_source_id <> 20
       AND h.order_source_id = os.order_source_id
       AND orig_sys_document_ref = nvl(p_orig_sys_document_ref,orig_sys_document_ref)
       AND nvl(operation_code,'CREATE') IN ('INSERT','CREATE')
       AND nvl(error_flag,'N') = 'N'
       AND nvl(ready_flag,'Y') = 'Y'
       AND nvl(rejected_flag,'N') = 'N'
       AND nvl(force_apply_flag,'Y') = 'Y'
       AND h.org_id = nvl(p_operating_unit,h.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_credits_iface_all sc
                        WHERE sc.order_source_id = h.order_source_id
                          AND sc.orig_sys_document_ref
                                    = h.orig_sys_document_ref
			  AND sc.org_id = h.org_id)
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_price_atts_iface_all pa
                        WHERE pa.order_source_id = h.order_source_id
                          AND pa.orig_sys_document_ref
                                    = h.orig_sys_document_ref
			  AND pa.org_id = h.org_id )
       AND NOT EXISTS (SELECT 'Y'
                         FROM oe_actions_iface_all a
                        WHERE a.order_source_id = h.order_source_id
                          AND a.orig_sys_document_ref
                                    = h.orig_sys_document_ref
			  AND a.org_id = h.org_id
                          AND operation_code <> 'BOOK_ORDER');
     End If;
       IF l_row_count = 0 THEN
         oe_debug_pub.add('No Data found in the IFCAE table');
         RAISE NO_DATA_FOUND;
       END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        fnd_file.put_line(FND_FILE.OUTPUT,'No more orders to process');
        fnd_file.put_line(FND_FILE.OUTPUT,'Not spawning any child processes');
        RETURN;

	WHEN OTHERS THEN
	fnd_file.put_line(FND_FILE.OUTPUT,'SOME OTHER ERROR IN SQL STATEMENT');
	RETURN;
     END;





   If p_debug_level > 0 Then
     oe_debug_pub.add('Remaining Header Row Count is '||l_row_count);
   end if;
     IF l_num_instances > l_row_count THEN
        l_num_instances := l_row_count;
     END IF;

     -----------------------------------------------------------
     -- Populate l_instance_tbl for l_num_instances
     -----------------------------------------------------------

     v_start := DBMS_UTILITY.GET_TIME;
     FOR I IN 1..l_num_instances LOOP

      -- Generate and populate request_id for each instance
      l_new_request_id := FND_REQUEST.SUBMIT_REQUEST('ONT', 'OEHVIMP',
          'High Volume Order Import Child Req' || to_char(l_req_data_counter)
          , NULL, TRUE, p_operating_unit,p_order_source_id,
p_orig_sys_document_ref, p_validate_only
          , p_validate_desc_flex, p_defaulting_mode , p_debug_level
          , 0,
p_batch_size,p_rtrim_data,p_process_recs_with_no_org,p_process_tax,
p_process_configurations, p_dummy, p_validate_configurations, p_schedule_configurations);
      fnd_file.put_line(FND_FILE.OUTPUT, 'Child Request ID: '||l_new_request_id);
      IF (l_new_request_id = 0) THEN
	  fnd_file.put_line(FND_FILE.OUTPUT,'Error in submitting child request');
	  errbuf  := FND_MESSAGE.GET;
	  retcode := 2;
          RETURN;
      END IF;

      l_instance_tbl(I).request_id := l_new_request_id;  -- I*1000;

     END LOOP;

     v_end := DBMS_UTILITY.GET_TIME;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Time for submit REQUESTs :'||to_char((v_end-v_start)/100));

     -----------------------------------------------------------
     -- BULK Populate Orders Table - l_order_rec
     -----------------------------------------------------------
   If p_debug_level > 0 Then
     oe_debug_pub.add('p_operating_unit = '||p_operating_unit);
     oe_debug_pub.add('p_process_recs_with_no_org = '||p_process_recs_with_no_org);
     oe_debug_pub.add('l_default_org_id = '||l_default_org_id);
   end if;
     If p_process_recs_with_no_org = 'N' Then
       v_start := DBMS_UTILITY.GET_TIME;
       OPEN c_lines_per_order;
       FETCH c_lines_per_order BULK COLLECT
       INTO l_order_rec.order_source_id
        , l_order_rec.orig_sys_document_ref
        , l_order_rec.num_lines
        , l_order_rec.request_id
        , l_order_rec.batch_id
        , l_order_rec.org_id
        ;
       CLOSE c_lines_per_order;
       v_end := DBMS_UTILITY.GET_TIME;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'TIME FOR BULK COLLECT:'||TO_CHAR ( ( V_END-V_START ) /100 ) ) ;
     Elsif p_process_recs_with_no_org = 'Y' Then
       v_start := DBMS_UTILITY.GET_TIME;
       If p_debug_level > 0 Then
         oe_debug_pub.add('here1');
       End If;
       OPEN c_lines_per_order_2;
       FETCH c_lines_per_order_2 BULK COLLECT
       INTO l_order_rec.order_source_id
        , l_order_rec.orig_sys_document_ref
        , l_order_rec.num_lines
        , l_order_rec.request_id
        , l_order_rec.batch_id
        , l_order_rec.org_id
        ;
       CLOSE c_lines_per_order_2;
       v_end := DBMS_UTILITY.GET_TIME;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'TIME FOR BULK COLLECT:'||TO_CHAR ( ( V_END-V_START ) /100 ) ) ;
     End If;
     -----------------------------------------------------------
     -- Assign request_id (instance) AND batch_id to the orders
     -----------------------------------------------------------

     l_order_count := l_order_rec.orig_sys_document_ref.count;
     If p_debug_level > 0 Then
         oe_debug_pub.add('Order Count = '||l_order_count);
     End If;
     minimum := 0;
     v_start := DBMS_UTILITY.GET_TIME;
     l_index := 1;

     <<BEGINNING_OF_LOOP>>
     WHILE l_index <= l_order_count LOOP

        l_num_lines := l_order_rec.num_lines(l_index);


        --------------------------------------------------------------
        -- Print error in the output if order size > batch size
        --------------------------------------------------------------

        IF l_num_lines > p_batch_size THEN


          fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_order_rec.order_source_id(l_index))
                            ||'/'||l_order_rec.orig_sys_document_ref(l_index));
	  fnd_file.put_line(FND_FILE.OUTPUT,'This order cannot be processed in this batch.'||
                            ' Order Size is > '||to_char(p_batch_size));


          -- Assign parent import program's request id. Without this, infinite
          -- number of child requests are spawned as this order will continue
          -- to exist with no request id assigned.
          l_order_rec.request_id(l_index) := l_request_id;

          update oe_headers_iface_all
          set error_flag='Y'  --- did not update ineligible_for_hvop as per the TDD
          where order_source_id = l_order_rec.order_source_id(l_index)
            and orig_sys_document_ref = l_order_rec.orig_sys_document_ref(l_index)
            and nvl(org_id,-99) = nvl(l_order_rec.org_id(l_index),-99);

          l_index := l_index + 1;

          GOTO BEGINNING_OF_LOOP;

        END IF;

        --------------------------------------------------------------
        -- I. Identify the instance with the least number of total lines
        --------------------------------------------------------------

        FOR I IN 1..l_num_instances LOOP
          IF l_instance_tbl(I).total_lines <= minimum THEN
             minimum := l_instance_tbl(I).total_lines;
             l_instance_index := I;
          END IF;
        END LOOP;

        -- Assign request_id for this instance to the order
        l_order_rec.request_id(l_index)
              := l_instance_tbl(l_instance_index).request_id;

        -- Update total number of lines for this instance/request.
        l_instance_tbl(l_instance_index).total_lines
                                := minimum + l_num_lines;
        minimum :=  minimum + l_num_lines;

        --------------------------------------------------------------
        -- II. Identify the batch within this request where this order
        -- can be accommodated.
        --------------------------------------------------------------

        l_batch_index := l_instance_index * l_max_batches;

        -- Search if a batch exists that can accommodate this order
        -- and total number of lines (incl. this order) will be
        -- <= p_batch_size
        l_batch_found := FALSE;

        -- Added logic to check if the org_id on the batch is same as the one on
        -- l_order_rec. This is to make sure that within a batch, there are records
        -- for only one org_id.

        WHILE l_batch_tbl.EXISTS(l_batch_index) LOOP

          IF l_batch_tbl(l_batch_index).total_lines + l_num_lines <= p_batch_size
          AND l_order_rec.org_id(l_index) = l_batch_tbl(l_batch_index).org_id
          THEN
              -- If batch exists, assign batch number to this order
     If p_debug_level > 0 Then
              oe_debug_pub.add(' Found the empty batch'||l_batch_tbl(l_batch_index).batch_id);
     END IF;
              l_batch_tbl(l_batch_index).total_lines :=
                  l_batch_tbl(l_batch_index).total_lines + l_num_lines;
              l_order_rec.batch_id(l_index) := l_batch_tbl(l_batch_index).batch_id;
              l_batch_found := TRUE;
              EXIT;
          END IF;
          l_batch_index := l_batch_index + 1;
        END LOOP;

        -- If batch does not exist, create a new batch.
        -- Assign new batch to this order and update number of batches
        -- for this instance.

        IF NOT l_batch_found THEN
          -- Generate a new batch_id
     If p_debug_level > 0 Then
          oe_debug_pub.add('Did not find empty batch so creating a new one');
          oe_debug_pub.add('Org_id for this batch is '||l_order_rec.org_id(l_index));
     end if;
          SELECT oe_batch_id_s.nextval
          INTO l_batch_id FROM DUAL;
          l_batch_tbl(l_batch_index).batch_id := l_batch_id;
          l_order_rec.batch_id(l_index) := l_batch_id;
          l_batch_tbl(l_batch_index).total_lines := l_num_lines;
          l_batch_tbl(l_batch_index).org_id := l_order_rec.org_id(l_index);
        END IF;

        l_index := l_index + 1;

     END LOOP; -- End of loop over Orders table - l_order_rec
     v_end := DBMS_UTILITY.GET_TIME;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Time to ASSIGN IDs :'||to_char((v_end-v_start)/100));


     --------------------------------------------------------------
     -- BULK UPDATE Request_ID and Batch_ID on headers iface table
     --------------------------------------------------------------

     v_start := DBMS_UTILITY.GET_TIME;
     FORALL l_index IN 1..l_order_count
       UPDATE oe_headers_iface_all
           SET request_id = l_order_rec.request_id(l_index)
             , batch_id = l_order_rec.batch_id(l_index)
             , org_id = l_order_rec.org_id(l_index) -- added for MOAC
        WHERE order_source_id = l_order_rec.order_source_id(l_index)
          AND orig_sys_document_ref
                   = l_order_rec.orig_sys_document_ref(l_index)
          and nvl(org_id,l_default_org_id) = l_order_rec.org_id(l_index);

     -- Sequential assignment of header_ids/line_ids
     -- Improves performance in parallel threads by reducing contention
     -- on OE tables and WF tables as WF itemkeys are also constructed
     -- using these id values.

     --------------------------------------------------------------
     -- BULK UPDATE org_id all iface tables if processing NULL records
     --------------------------------------------------------------
     IF p_process_recs_with_no_org = 'Y' Then

         -- Update on lines iface is done as a part of request_id update.

         -- Update on actions iface all
         FORALL l_index IN 1..l_order_count
         UPDATE oe_actions_iface_all
           SET org_id = l_order_rec.org_id(l_index) -- added for MOAC
         WHERE order_source_id = l_order_rec.order_source_id(l_index)
         AND orig_sys_document_ref
                   = l_order_rec.orig_sys_document_ref(l_index)
         AND org_id IS NULL
         AND l_default_org_id = nvl(p_operating_unit,l_default_org_id);

         -- Update on oe_price_adjs_interface
         FORALL l_index IN 1..l_order_count
         UPDATE OE_PRICE_ADJS_IFACE_ALL
           SET org_id = l_order_rec.org_id(l_index) -- added for MOAC
         WHERE order_source_id = l_order_rec.order_source_id(l_index)
         AND orig_sys_document_ref
                   = l_order_rec.orig_sys_document_ref(l_index)
         AND org_id IS NULL
         AND l_default_org_id = nvl(p_operating_unit,l_default_org_id);

     END IF;

     FOR l_index IN 1..l_num_instances LOOP

       -- Bug 3045608
       -- High volume import assumes that global headers table
       -- populated by oe_bulk_process_header.load_headers will have
       -- header records sorted in the ascending order for BOTH header_id
       -- and for (order_source_id,orig_sys_ref) combination.
       -- So order by order_source_id, orig_sys_ref when assigning
       -- header_id from the sequence. If it is not ordered thus, header_ids
       -- will be in random order in the global table and workflows/pricing
       -- for orders may be skipped.
       FOR c IN c_headers(l_instance_tbl(l_index).request_id) LOOP

       If p_debug_level > 0 Then
         oe_debug_pub.add('Updating Line_Ids for'||c.org_id);
         oe_debug_pub.add('Updating Line_Ids for'||c.orig_sys_document_ref);
       End If;
        UPDATE oe_headers_iface_all
           SET header_id = oe_order_headers_s.nextval
         WHERE order_source_id = c.order_source_id
           AND orig_sys_document_ref = c.orig_sys_document_ref
           AND nvl(org_id,-99) = nvl(c.org_id,-99)
           AND request_id = c.request_id; -- Changed for MOAC

        UPDATE oe_lines_iface_all
           SET line_id = oe_order_lines_s.nextval,
               request_id = l_instance_tbl(l_index).request_id,
               org_id = c.org_id
         WHERE order_source_id = c.order_source_id
           AND orig_sys_document_ref = c.orig_sys_document_ref
           AND nvl(org_id, l_default_org_id) = nvl(c.org_id,l_default_org_id); -- changed for MOAC

       END LOOP;

     END LOOP;

     v_end := DBMS_UTILITY.GET_TIME;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Time to BULK UPDATE:'||to_char((v_end-v_start)/100));

     COMMIT;

     fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                     request_data => to_char(l_req_data_counter));
     errbuf  := 'Sub-Request ' || to_char(l_req_data_counter) || 'submitted!';
     retcode := 0;

  -----------------------------------------------------------
  -- If number of instances = 0, this is a child request.
  -- For each batch in this request, run BULK order import.
  -----------------------------------------------------------
  ELSIF l_num_instances = 0 THEN

/* Commenting out as the request ID assignment on these tables can
   take a long time. In particular, when there are multiple child requests
   working on these updates - the performance could be poor due to disk
   contention on these tables.
   BULK Processing APIs should use the global request ID (G_REQUEST_ID)
   to identify current child request ID. Do not use request_id on the
   interface tables.

   UPDATE oe_lines_interface
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref) IN
	( SELECT order_source_id, orig_sys_document_ref
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id);

   COMMIT;

   UPDATE oe_price_adjs_interface
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref) IN
	( SELECT order_source_id, orig_sys_document_ref
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id);

   COMMIT;

   UPDATE oe_actions_interface
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref) IN
	( SELECT order_source_id, orig_sys_document_ref
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id);

   COMMIT;
   */

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF p_debug_level > 0 THEN
     SELECT hsecs INTO l_start_total_time from v$timer;
   END IF;

   Initialize_Request
       ( p_request_id          => l_request_id
       , p_validate_desc_flex  => p_validate_desc_flex
       , p_rtrim_data          => p_rtrim_data  -- 3390458
       , x_return_status       => l_return_status
       );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      retcode := 2;
      errbuf := 'Please check the log file for error messages';
      RETURN;
   END IF;

   OPEN l_batch_cursor;
   LOOP
     FETCH l_batch_cursor INTO l_batch_id,b_org_id;
      EXIT WHEN l_batch_cursor%NOTFOUND;
     If p_debug_level > 0 Then
       oe_debug_pub.add(' Inside the Batch cursor for org '||b_org_id);
       oe_debug_pub.add(' Inside the Batch cursor for batch '||l_batch_id);
       oe_debug_pub.add(' The G_ORG_ID is '||G_ORG_ID);
     end if;

   l_entered_orders := G_ENTERED_ORDERS;
   l_booked_orders := G_BOOKED_ORDERS;
   l_error_orders := G_ERROR_ORDERS;

   IF G_ORG_ID IS NULL OR
      (G_ORG_ID IS NOT NULL AND
       G_ORG_ID <> b_org_id) Then
     If p_debug_level > 0 Then
         oe_debug_pub.add(' Setting the policy context for '||b_org_id);
     end if;
     MO_GLOBAL.SET_POLICY_CONTEXT('S',b_org_id);
     G_ORG_ID := b_org_id;

     -- Set all globals that are derived based on OU
     Initialize_Batch
       ( x_return_status       => l_return_status
       );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        retcode := 2;
        errbuf := 'Please check the log file for error messages';
        RETURN;
     END IF;
   End if;

   -----------------------------------------------------------
   --Customer Acceptance
   --If Customer Acceptance is enabled then HVOP is not supported
   -----------------------------------------------------------
   --IF OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE',G_ORG_ID) = 'Y'
   --THEN
   --     FND_MESSAGE.SET_NAME('ONT','OE_BULK_NOT_SUPP_ACCEPTANCE');
   --     fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.GET);
   --     retcode := 2;
   --     RETURN;
   -- END IF;

   -----------------------------------------------------------
   --   Call Process_Batch procedure
   -----------------------------------------------------------
        If p_debug_level > 0 Then
         oe_debug_pub.add(' Calling Process Batch with process Tax :'|| p_process_tax, 1);
     end if;

      OE_BULK_ORDER_PVT.PROCESS_BATCH (
		p_batch_id		=> l_batch_id,
		p_validate_only		=> p_validate_only,
                p_validate_desc_flex    => p_validate_desc_flex,
                p_defaulting_mode       => p_defaulting_mode,
                p_process_configurations  => p_process_configurations,
                p_validate_configurations => p_validate_configurations,
                p_schedule_configurations => p_schedule_configurations,
		p_init_msg_list		=> l_init_msg_list,
                p_process_tax           => p_process_tax,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		x_return_status		=> l_return_status
		);

     -- Save messages logged during the processing of this batch

     OE_BULK_MSG_PUB.Save_Messages(OE_Bulk_Order_PVT.G_REQUEST_ID);

     -- Save messages from non-bulk enabled API calls
     OE_MSG_PUB.Save_Messages(OE_Bulk_Order_PVT.G_REQUEST_ID);


     -- Process_Batch will only return unexp error or success result
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        UPDATE oe_headers_iface_all
        SET    error_flag = 'Y'
        WHERE  batch_id = l_batch_id;

        -- All orders in this batch would have failed as it is an unexp error.
        -- Therefore, re-set entered/booked count to values before this
        -- batch was processed. And update error count with number of orders
        -- assigned to this batch.
        G_ENTERED_ORDERS := l_entered_orders;
        G_BOOKED_ORDERS := l_booked_orders;

        SELECT count(*)
          INTO l_batch_orders
          FROM oe_headers_iface_all
         WHERE batch_id = l_batch_id;

        G_ERROR_ORDERS := l_error_orders + l_batch_orders;

        l_count_batch_failure := l_count_batch_failure + 1;
        fnd_file.put_line(FND_FILE.LOG,'Batch id: '|| to_char(l_batch_id)||
             ' Status : Unexpected Error (all orders failed to import)'
             );

     ELSE
        l_count_batch_success := l_count_batch_success + 1;
        -- Call order import post processing routine.
        -- This will delete all records from interface tables that were
        -- successfully imported.
        Post_Process(
                p_batch_id              => l_batch_id,
                p_validate_only         => p_validate_only,
		x_return_status		=> l_return_status
		);
        fnd_file.put_line(FND_FILE.LOG,'Batch ID: '|| to_char(l_batch_id)||
             ' Status : Processed (orders could have failures due to validation errors)'
             );
     END IF;

     l_count_batch := l_count_batch + 1;
     OE_BULK_MSG_PUB.Save_Messages(l_request_id);

     -- Save messages from non-bulk enabled API calls
     OE_MSG_PUB.Save_Messages(l_request_id);



  END LOOP;			-- Batch cursor
  CLOSE l_batch_cursor;

  -- Bug 5640601 =>
  -- Selecting hsecs from v$times is changed to execute only when debug
  -- is enabled, as hsec is used for logging only when debug is enabled.
  IF p_debug_level > 0 THEN
    SELECT hsecs INTO l_end_total_time from v$timer;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Total time is (sec) '
          ||((l_end_total_time-l_start_total_time)/100));

  fnd_file.put_line(FND_FILE.OUTPUT,'No. of batches found: ' ||
						l_count_batch);
  fnd_file.put_line(FND_FILE.OUTPUT,'');


  fnd_file.put_line(FND_FILE.OUTPUT,'No. of Orders Processed across All Batches :'||
                 to_char(G_BOOKED_ORDERS + G_ENTERED_ORDERS + G_ERROR_ORDERS));
  fnd_file.put_line(FND_FILE.OUTPUT,'No. of Booked Orders: '||
                                     to_char(G_BOOKED_ORDERS));
  fnd_file.put_line(FND_FILE.OUTPUT,'No. of Entered Orders: ' ||
                                     to_char(G_ENTERED_ORDERS));
  fnd_file.put_line(FND_FILE.OUTPUT,'No. of Orders Failed: ' ||
                                     to_char(G_ERROR_ORDERS));

  -- ER 9060917
  IF NVL (Fnd_Profile.Value('ONT_HVOP_DROP_INVALID_LINES'), 'N')='Y' then
  	fnd_file.put_line(FND_FILE.OUTPUT,'');
  	fnd_file.put_line(FND_FILE.OUTPUT,'Following orders are processed partially as profile OM: Allow HVOP to drop invalid lines is set');

  	OPEN l_partial_orders;
 	 LOOP
    	FETCH l_partial_orders
     	INTO l_orig_sys_document_ref;
    	EXIT when l_partial_orders%NOTFOUND;

    	fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_orig_sys_document_ref));

  	END LOOP;
  	CLOSE l_partial_orders;
  END IF;
  -- End of ER 9060917
  -----------------------------------------------------------
  -- Messages
  -----------------------------------------------------------

      fnd_file.put_line(FND_FILE.OUTPUT,'');
      fnd_file.put_line(FND_FILE.OUTPUT,'Source/Order/Seq/Line    Message');
      OPEN l_msg_cursor;
      LOOP
        FETCH l_msg_cursor
         INTO l_order_source_id
            , l_orig_sys_document_ref
            , l_change_sequence
            , l_orig_sys_line_ref
            , l_message_text;
         EXIT WHEN l_msg_cursor%NOTFOUND;

         fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_order_source_id)
                                            ||'/'||l_orig_sys_document_ref
                                            ||'/'||l_change_sequence
                                            ||'/'||l_orig_sys_line_ref
                                            ||' '||l_message_text);
         fnd_file.put_line(FND_FILE.OUTPUT,'');
      END LOOP;

  END IF; -- End if for l_num_instances

  -----------------------------------------------------------
  -- End of Order_Import_Conc_Pgm
  -----------------------------------------------------------
   fnd_file.put_line(FND_FILE.OUTPUT, 'End of BULK Order Import Concurrent Program');

EXCEPTION
  WHEN OTHERS THEN
       retcode := 2;
       fnd_file.put_line(FND_FILE.OUTPUT,'Unexpected error '||substr(sqlerrm,1,200));
       fnd_file.put_line(FND_FILE.OUTPUT,'no. of batches imported: '||
						l_count_batch_success);
       fnd_file.put_line(FND_FILE.OUTPUT,'no. of batches failed: ' ||
						l_count_batch_failure);
       fnd_file.put_line(FND_FILE.OUTPUT,'');
END ORDER_IMPORT_CONC_PGM;


END OE_BULK_ORDER_IMPORT_PVT;

/
