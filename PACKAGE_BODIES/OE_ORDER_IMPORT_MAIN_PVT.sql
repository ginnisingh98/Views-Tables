--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_MAIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_MAIN_PVT" AS
/* $Header: OEXVIMNB.pls 120.13.12000000.2 2009/01/17 02:13:56 smusanna ship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    Order Import Main
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

-- Added this to create new conc. program for FND_STAT
PROCEDURE ORDER_IMPORT_STATS_CONC_PGM(
errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CALLING PERF STATISTICS API' ) ;
   END IF;

   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_HEADERS_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_LINES_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_ACTIONS_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_PRICE_ADJS_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_RESERVTNS_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_CREDITS_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_LOTSERIALS_IFACE_ALL');
   FND_STATS.Gather_Table_Stats(ownname => 'ONT',
                                tabname => 'OE_PAYMENTS_IFACE_ALL');

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALLING PERF STATISTICS API' ) ;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order_stats');
       END IF;

       fnd_file.put_line(FND_FILE.OUTPUT,'Unexpected error: ' || sqlerrm);

END ORDER_IMPORT_STATS_CONC_PGM;

/* -----------------------------------------------------------
   Procedure: Order_Import_Conc_Pgm
   -----------------------------------------------------------
*/
PROCEDURE ORDER_IMPORT_CONC_PGM(
errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER
  ,p_operating_unit                     IN  NUMBER
  ,p_order_source			IN  VARCHAR2
  ,p_orig_sys_document_ref		IN  VARCHAR2
  ,p_operation_code			IN  VARCHAR2
  ,p_validate_only			IN  VARCHAR2 DEFAULT 'N'
  ,p_debug_level			IN  NUMBER
  ,p_num_instances            IN  NUMBER DEFAULT 1
  ,p_sold_to_org_id                     IN  NUMBER
  ,p_sold_to_org                        IN  VARCHAR2
  ,p_change_sequence                    IN  VARCHAR2
  ,p_perf_param				IN  VARCHAR2
  ,p_rtrim_data                         IN  Varchar2
--  ,p_request_id               IN NUMBER
  ,p_process_orders_with_null_org       IN  VARCHAR2
  ,p_default_org_id                     IN  NUMBER
  ,p_validate_desc_flex                 in varchar2 default 'Y' --bug4343612
)
IS
  l_init_msg_list			VARCHAR2(1)  := FND_API.G_TRUE;
  l_validate_only			VARCHAR2(1)  := p_validate_only;
  l_order_source			VARCHAR2(240) := p_order_source;
  l_order_source_id			NUMBER;
  l_orig_sys_document_ref		VARCHAR2(50) := p_orig_sys_document_ref;
  l_sold_to_org_id                      NUMBER       := p_sold_to_org_id;
  l_sold_to_org                         VARCHAR2(360) := p_sold_to_org;
  l_change_sequence			VARCHAR2(50) := p_change_sequence;
  l_orig_sys_line_ref			VARCHAR2(50);
  l_operation_code			VARCHAR2(30) := p_operation_code;
  l_request_id				NUMBER;
  l_org_id				NUMBER;
--  l_debug_level              		NUMBER 	     := p_debug_level;
  l_num_instances             NUMBER := p_num_instances;
  l_count_msgs              		NUMBER;
  l_message_text              		VARCHAR2(2000)  := '';

  l_msg_count              		NUMBER;
  l_msg_data              		VARCHAR2(2000)  := '';
  l_return_status             		VARCHAR2(1) 	:= '';

  l_count_header			NUMBER := 0;
  l_count_header_warning		NUMBER := 0;
  l_count_header_success		NUMBER := 0;
  l_count_header_failure		NUMBER := 0;

  l_filename              		VARCHAR2(100);
  l_database				VARCHAR2(100);

  l_api_name		       CONSTANT VARCHAR2(30):= 'Order_Import_Main';
  l_row_count              NUMBER;
  new_request_id           NUMBER;
  x_new_request_id         NUMBER;
  x_errbuf                 VARCHAR2(2000);
  x_retcode                NUMBER;
  x_order_source           VARCHAR2(240);
  x_orig_sys_document_ref  VARCHAR2(50);
  x_operation_code         VARCHAR2(30);
  x_validate_only          VARCHAR2(1);
  x_debug_level            NUMBER;
  x_num_instances          NUMBER;
  batch_size               NUMBER;
  l_ord_count              NUMBER;
  batch_size_all           NUMBER;
  batch_last               NUMBER;
  l_mod                    NUMBER;
  l_updated_docref         VARCHAR2(50);

  l_closed_flag            VARCHAR2(1);
  l_customer_key_profile   VARCHAR2(3)   :=  'N';

  -- For the Parent Wait for child to finish
  l_req_data               VARCHAR2(10);
  l_req_data_counter       NUMBER;
  G_IMPORT_SHIPMENTS       VARCHAR2(3);

  l_rtrim_data             Varchar2(1) := p_rtrim_data;

/* -----------------------------------------------------------
   Order sources cursor
   -----------------------------------------------------------
*/
    CURSOR l_source_cursor IS
    SELECT order_source_id
      FROM oe_order_sources s
     WHERE (
            (nvl(l_order_source,' ') =  ' ') OR
	    (
             (nvl(l_order_source,' ') <> ' ') AND
             (enabled_flag = 'Y') AND
	     (nvl(to_char(order_source_id),' ')=nvl(rtrim(l_order_source),' '))
	    )
           )
  ORDER BY order_source_id
;

/* -----------------------------------------------------------
   Request Headers cursor
   -----------------------------------------------------------
*/

  l_rowid                               varchar2(100);
  l_looped_flag                         varchar2(1) := 'N';
  l_pnt_request_id                      number;




    CURSOR l_request_cursor IS
    SELECT order_source_id
	 , orig_sys_document_ref
	, sold_to_org_id
         , sold_to_org
       	 , change_sequence
      , nvl(closed_flag, 'N')
      ,org_id
     FROM oe_headers_iface_all
     WHERE request_id = l_request_id
       AND decode(p_perf_param, 'Y',
           nvl(error_flag,'N'), ' ')
         = decode(p_perf_param, 'Y',
           'N', ' ')
       AND decode(l_looped_flag, 'Y',
           l_rowid, ' ')
         = decode(l_looped_flag, 'Y',
           rowidtochar(rowid), ' ')
  ORDER BY org_id,order_source_id, orig_sys_document_ref, change_sequence
;





/* -----------------------------------------------------------
   Messages cursor
   -----------------------------------------------------------
*/
    CURSOR l_msg_cursor IS
-- Oracle IT bug 01/06/2000 1572080
/*
    SELECT order_source_id
         , original_sys_document_ref
    	 , change_sequence
         , original_sys_document_line_ref
         , message_text
      FROM oe_processing_msgs_vl
     WHERE request_id = l_request_id
  ORDER BY order_source_id, original_sys_document_ref, change_sequence
;


*/
-- changed to
    SELECT /*+ INDEX (a,OE_PROCESSING_MSGS_N2)
	   USE_NL (a b) */
           a.order_source_id
         , a.original_sys_document_ref
    	    , a.change_sequence
         , a.original_sys_document_line_ref
         , a.org_id
         , b.message_text
      FROM oe_processing_msgs a, oe_processing_msgs_tl b
     WHERE a.request_id = l_request_id
       AND a.transaction_id = b.transaction_id
       AND b.language = oe_globals.g_lang
  ORDER BY a.order_source_id, a.original_sys_document_ref, a.change_sequence
;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --MOAC set policy context for single Org
  IF p_operating_unit IS NOT NULL THEN
    MO_GLOBAL.set_policy_context('S',p_operating_unit);
  END IF;

  fnd_profile.get('ONT_IMP_MULTIPLE_SHIPMENTS', G_IMPORT_SHIPMENTS);
  G_IMPORT_SHIPMENTS := nvl(G_IMPORT_SHIPMENTS, 'NO');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IMP SHIPMENTS PROFILE = '||G_IMPORT_SHIPMENTS ) ;
  END IF;

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DERIVED CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;



/* -----------------------------------------------------------
   Log Output file
   -----------------------------------------------------------
*/
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Import Concurrent Program');
   fnd_file.put_line(FND_FILE.OUTPUT, '');
   fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
   fnd_file.put_line(FND_FILE.OUTPUT, 'Validate Only: '|| l_validate_only);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Source: '|| l_order_source);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Order Ref: '|| l_orig_sys_document_ref);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Sold To Org Id: '|| l_sold_to_org_id);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Sold To Org: '|| l_sold_to_org);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Change Sequence: '|| l_change_sequence);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Performance Parameter: '|| p_perf_param);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Trim Blanks: '|| p_rtrim_data);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Operation: '|| l_operation_code);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Number of Instances: '|| p_num_instances);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Org Id: '||p_operating_unit);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Process Orders With Null Org: '||p_process_orders_with_null_org);
   fnd_file.put_line(FND_FILE.OUTPUT, 'Default Org Id: '||p_default_org_id);
   fnd_file.put_line(FND_FILE.OUTPUT, '');

  --Check if Ct is atleast on Patchset Level H
  If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' And
     l_order_source = '20'
  Then
    fnd_file.put_line(FND_FILE.OUTPUT, 'Cannot Import Order for Order Source XML. This functionality is available only from Pack H onwards');
    fnd_file.put_line(FND_FILE.OUTPUT, 'End of Order Import Concurrent Program');
    fnd_file.put_line(FND_FILE.OUTPUT, '');
    Return;
  End If;

  --Check if Ct is atleast on Patchset Level H
  If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110508' And
     G_IMPORT_SHIPMENTS = 'YES'
  Then
    fnd_file.put_line(FND_FILE.OUTPUT, 'Cannot Import Multiple Shipments with the same Line Reference. This functionality is available only from Pack H onwards');
    fnd_file.put_line(FND_FILE.OUTPUT, 'End of Order Import Concurrent Program');
    fnd_file.put_line(FND_FILE.OUTPUT, '');
    Return;
  End If;

/* -----------------------------------------------------------
   Setting Debug On
   -----------------------------------------------------------
*/
   -- Removing this initialization as per change in debug package
   --   OE_DEBUG_PUB.debug_on;
   --   OE_DEBUG_PUB.SetDebugLevel(5);
   --   OE_DEBUG_PUB.initialize;
   -- If l_debug_level Is Null
   -- Then
   -- l_debug_level := to_number(nvl(fnd_profile.value('ONT_DEBUG_LEVEL'),'0'));
   -- End If;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER SETTING DEBUG ON' ) ;
   END IF;


   -----------------------------------------------------------
   -- Setting Debug Mode and File
   -----------------------------------------------------------

   FND_FILE.Put_Line(FND_FILE.OUTPUT,'Debug Level: '||l_debug_level);

   IF nvl(l_debug_level, 1) > 0 THEN
--      fnd_profile.put('OE_DEBUG_LOG_DIRECTORY','/sqlcom/outbound');
      l_filename := OE_DEBUG_PUB.set_debug_mode ('FILE');
      FND_FILE.Put_Line(FND_FILE.OUTPUT,'Debug File: ' || l_filename);
      FND_FILE.Put_Line(FND_FILE.OUTPUT, '');
--  Following line moved inside because of the bug 3328608
      l_filename := OE_DEBUG_PUB.set_debug_mode ('CONC');
   END IF;



/* -----------------------------------------------------------
   Initialization
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE INITIALIZATION' ) ;
   END IF;
--Changes made for Bug no 5493479 start
/*-----------------------------------------------------------
  Set the Context for Order Import
------------------------------------------------------------
*/

    if ( OE_ORDER_IMPORT_MAIN_PVT.G_CONTEXT_ID IS NULL) THEN
         OE_ORDER_IMPORT_MAIN_PVT.G_CONTEXT_ID :=
                                   to_number(rtrim(SUBSTRB(SYS_CONTEXT('USERENV','CLIENT_INFO'),1,10),' '));
    end if;
--Changes made for Bug no 5493479 end

/* -----------------------------------------------------------
   Get Concurrent Request Id
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE GETTING REQUEST ID' ) ;
       oe_debug_pub.add(  'PERFORMANCE PARAMETER:' || p_perf_param);
   END IF;
/* Commenting for 7677291
   FND_PROFILE.Get('CONC_REQUEST_ID', l_request_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'REQUEST ID: '|| TO_CHAR ( L_REQUEST_ID ) ) ;
   END IF;
   fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));
   */
  -- Start of bug Fix 7677291
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'REQUEST ID: '|| TO_CHAR ( L_REQUEST_ID ) ) ;
   END IF;
   fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));

  -- End of bug Fix 7677291





 IF l_num_instances > 0 THEN
/* -----------------------------------------------------------
   Sources
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE NUM INSTANCES LOOP' ) ;
       oe_debug_pub.add(  'BEFORE SOURCES LOOP' ) ;
   END IF;

   OPEN l_source_cursor;
   LOOP
     FETCH l_source_cursor
      INTO l_order_source_id
;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'SOURCE CURSOR VALUE = '||L_ORDER_SOURCE_ID ) ;
	 END IF;
      EXIT WHEN l_source_cursor%NOTFOUND;

/* -----------------------------------------------------------
   Update Concurrent Request Ids
   -----------------------------------------------------------
*/
/* oe_debug_pub.add('No of orders in inf table');
   SELECT COUNT(*) INTO l_ord_count
	FROM oe_headers_iface_all
    WHERE order_source_id     = 1084
      AND ( nvl(NULL,' ') =  ' ' OR
           (nvl(NULL,' ') <> ' ' AND
           nvl(NULL,' ') = nvl(orig_sys_document_ref,' ')))
      AND ( nvl(NULL,' ') =  ' ' OR
          (nvl(NULL,' ') <> ' ' AND
           nvl(NULL,' ') = nvl(operation_code,' ')))
      AND request_id          IS NULL
      AND nvl(error_flag,'N') = 'N';
   oe_debug_pub.add('No of ord in inf table = '||l_ord_count);
   oe_debug_pub.add('before updating concurrent request id');
*/

    UPDATE oe_headers_interface
      SET request_id          = l_request_id
    WHERE order_source_id     = l_order_source_id
      AND ( nvl(l_orig_sys_document_ref,' ') =  ' ' OR
           (nvl(l_orig_sys_document_ref,' ') <> ' ' AND
            nvl(l_orig_sys_document_ref,' ') = nvl(orig_sys_document_ref,' ')))
      AND ( nvl(l_operation_code,' ') =  ' ' OR
           (nvl(l_operation_code,' ') <> ' ' AND
            nvl(l_operation_code,' ') = nvl(operation_code,' ')))
      AND ( l_sold_to_org_id IS NULL OR
           (l_sold_to_org_id IS NOT NULL AND
            nvl(l_sold_to_org_id, FND_API.G_MISS_NUM) = nvl(sold_to_org_id, FND_API.G_MISS_NUM)))
      AND
           ( l_sold_to_org IS NULL OR
           (l_sold_to_org IS NOT NULL AND
            nvl(l_sold_to_org, FND_API.G_MISS_CHAR) = nvl(sold_to_org, FND_API.G_MISS_CHAR)))
      AND ( l_change_sequence IS NULL OR
           (l_change_sequence IS NOT NULL AND
            nvl(l_change_sequence, FND_API.G_MISS_CHAR) = nvl(change_sequence, FND_API.G_MISS_CHAR)))
      AND request_id          IS NULL
      AND nvl(error_flag,'N') = 'N';

    --MOAC
    IF p_process_orders_with_null_org = 'Y' THEN
      IF
         (p_operating_unit IS NOT NULL AND
          p_operating_unit = p_default_org_id)
         OR
         (p_operating_unit IS NULL AND
          p_default_org_id IS NOT NULL)
     THEN

        UPDATE oe_headers_iface_all
           SET request_id          = l_request_id,
               org_id              = p_default_org_id
         WHERE order_source_id     = l_order_source_id
           AND ( nvl(l_orig_sys_document_ref,' ') =  ' ' OR
               (nvl(l_orig_sys_document_ref,' ') <> ' ' AND
                nvl(l_orig_sys_document_ref,' ') = nvl(orig_sys_document_ref,' ')))
           AND ( nvl(l_operation_code,' ') =  ' ' OR
               (nvl(l_operation_code,' ') <> ' ' AND
                nvl(l_operation_code,' ') = nvl(operation_code,' ')))
           AND ( l_sold_to_org_id IS NULL OR
               (l_sold_to_org_id IS NOT NULL AND
                nvl(l_sold_to_org_id, FND_API.G_MISS_NUM) = nvl(sold_to_org_id, FND_API.G_MISS_NUM)))
           AND
               ( l_sold_to_org IS NULL OR
               (l_sold_to_org IS NOT NULL AND
                nvl(l_sold_to_org, FND_API.G_MISS_CHAR) = nvl(sold_to_org, FND_API.G_MISS_CHAR)))
           AND ( l_change_sequence IS NULL OR
               (l_change_sequence IS NOT NULL AND
                nvl(l_change_sequence, FND_API.G_MISS_CHAR) = nvl(change_sequence, FND_API.G_MISS_CHAR)))
           AND request_id          IS NULL
           AND nvl(error_flag,'N') = 'N'
           AND org_id IS NULL;

      END IF;
    END IF;



  END LOOP;			/* Sources cursor */
  CLOSE l_source_cursor;

  COMMIT;

   SELECT COUNT(*)
	INTO l_row_count
     FROM oe_headers_iface_all  -- MOAC
    WHERE request_id = l_request_id;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ROW COUNT = '||L_ROW_COUNT ) ;
    END IF;

  IF l_row_count = 0 THEN
    fnd_file.put_line(FND_FILE.OUTPUT,'No orders to process');
    fnd_file.put_line(FND_FILE.OUTPUT,'Not spawning any child processes');
  ELSE
   -- aksingh working
   l_req_data := fnd_conc_global.request_data;
   if (l_req_data is not null) then
	l_req_data_counter := to_number(l_req_data);
	l_req_data_counter := l_req_data_counter + 1;
      --errbuf  := 'Done!';
      -- retcode := 0;
      --return;
   else
	l_req_data_counter := 1;
   end if;
   IF l_num_instances = 1 THEN
	batch_size_all := l_row_count;
   ELSE
     batch_size_all := FLOOR(l_row_count/l_num_instances);
	l_mod := MOD(l_row_count,l_num_instances);
	--batch_last := batch_size_all + MOD(l_row_count,l_num_instances);
   END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BATCH SIZE = '||BATCH_SIZE_ALL ) ;
         oe_debug_pub.add(  'MOD = '||L_MOD ) ;
     END IF;

   IF l_num_instances > l_row_count THEN
	l_num_instances := l_row_count;
   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NUM INSTANCES = '||L_NUM_INSTANCES ) ;
    END IF;
    FOR loop_counter IN 1..l_num_instances LOOP
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE FOR LOOP FOR SPAWNING CHILD REQ' ) ;
     END IF;
	batch_size := batch_size_all;
     x_num_instances := 0;
--	x_new_request_id := new_request_id;
--p_validate_desc_flex added for bug4343612
	new_request_id := FND_REQUEST.SUBMIT_REQUEST('ONT', 'OEOIMP', 'Order Import Child Req' || to_char(l_req_data_counter), NULL, TRUE, p_operating_unit,l_order_source, NULL, NULL,
 p_validate_only, p_debug_level, 0, NULL, NULL, NULL, p_perf_param,p_rtrim_data,
 p_process_orders_with_null_org,p_default_org_id,p_validate_desc_flex);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHILD REQUEST ID = '||NEW_REQUEST_ID ) ;
     END IF;
     fnd_file.put_line(FND_FILE.OUTPUT, 'Child Request ID: '||new_request_id);

	IF (new_request_id = 0) THEN
	  fnd_file.put_line(FND_FILE.OUTPUT,'Error in submitting child request');
	  errbuf  := FND_MESSAGE.GET;
	  retcode := 2;
     ELSE
	  IF loop_counter <= l_mod THEN
	    batch_size := batch_size_all + 1;
       END IF;
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'BEFORE UPDATING REQ ID' ) ;
	      oe_debug_pub.add(  'LOOP COUNT = '||LOOP_COUNTER ) ;
	      oe_debug_pub.add(  'BATCH_SIZE_ALL = '||BATCH_SIZE_ALL ) ;
	      oe_debug_pub.add(  'BATCH_SIZE = '||BATCH_SIZE ) ;
	  END IF;

          IF (p_perf_param = 'Y') THEN
-- only update one record
            UPDATE oe_headers_iface_all
	    SET request_id = new_request_id
            WHERE request_id = l_request_id
	    AND ROWNUM =1;
          ELSE
-- update batchsize records
	    UPDATE oe_headers_iface_all
	    SET request_id = new_request_id
            WHERE request_id = l_request_id
	    AND ROWNUM <= batch_size;
         END IF;

         COMMIT;

     END IF;
    END LOOP;
       fnd_conc_global.set_req_globals(conc_status  => 'PAUSED',
                                       request_data => to_char(l_req_data_counter));
       errbuf  := 'Sub-Request ' || to_char(l_req_data_counter) || 'submitted!';
       retcode := 0;
--    fnd_file.put_line(FND_FILE.OUTPUT,'No of orders imported: 0');
--    fnd_file.put_line(FND_FILE.OUTPUT,'No of orders failed: 0');
    fnd_file.put_line(FND_FILE.OUTPUT,'');
  END IF;

 ELSIF l_num_instances = 0 THEN
/* -----------------------------------------------------------
   Headers
   -----------------------------------------------------------
*/
   --oe_debug_pub.add('before headers loop');

  l_count_header := 0;
  l_count_header_success := 0;
  l_count_header_failure := 0;

<<dist>>

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'after goto') ;
  END IF;

-- if profile is set to 'Y' do updates in interface table based on
-- customer-inclusive key information


if (l_customer_key_profile = 'Y') then

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'customer key profile was yes') ;
  END IF;


-- start of customer inclusive request_id updates

   UPDATE oe_lines_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref, nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	  FROM oe_headers_iface_all
          WHERE request_id = l_request_id);
      /*AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

  IF l_debug_level  > 0 THEN
   oe_debug_pub.add('rows updated: ' || sql%rowcount);
  END IF;

   COMMIT;

   UPDATE oe_price_adjs_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
      /*AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

   COMMIT;


      UPDATE oe_payments_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
     /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691


    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('oe payments rows updated: ' || sql%rowcount);
    END IF;

   COMMIT;

   /* Added for #1433292         */
   UPDATE oe_price_atts_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
        ( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
            FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
      /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

   COMMIT;


   UPDATE oe_credits_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
      /*AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

   COMMIT;

   UPDATE oe_lotserials_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
      /*AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

   COMMIT;

   UPDATE oe_reservtns_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
      /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

   COMMIT;

   UPDATE oe_actions_iface_all
      SET request_id = l_request_id
    WHERE (order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR),nvl(org_id,nvl(p_default_org_id,FND_API.G_MISS_NUM))) IN
	( SELECT order_source_id, orig_sys_document_ref,
nvl(sold_to_org_id, FND_API.G_MISS_NUM), nvl(sold_to_org, FND_API.G_MISS_CHAR), nvl(change_sequence, FND_API.G_MISS_CHAR), nvl(org_id,FND_API.G_MISS_NUM)
	    FROM oe_headers_iface_all
           WHERE request_id = l_request_id) ;
      /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
        = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

  COMMIT;

-- end of customer-inclusive request_id updates

end if;


OPEN l_request_cursor;

  LOOP


     FETCH l_request_cursor
      INTO l_order_source_id
	  ,l_orig_sys_document_ref
	, l_sold_to_org_id
         , l_sold_to_org
	  ,l_change_sequence
       ,l_closed_flag
       ,l_org_id
;
      EXIT WHEN l_request_cursor%NOTFOUND;

-- If doing throughput-enhanced imports, then set the looped_flag if it has not
-- been set already
  If p_perf_param = 'Y' then
    If l_looped_flag = 'N' then
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('setting looped flag');
      END IF;
      l_looped_flag := 'Y';
    End If;
  End If;

  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Performance Parameter: ' || p_perf_param);
  END IF;

IF ( p_perf_param = 'Y') THEN

  if l_count_header = 0 then

  begin
  select parent_request_id
  into   l_pnt_request_id
  from fnd_concurrent_requests
  where request_id=l_request_id;

  exception
  when others then
       IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Unexpected error: '||sqlerrm);
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Order_Import_Conc_Pgm');
       END IF;
       fnd_file.put_line(FND_FILE.OUTPUT,'Unexpected error: ' || sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  end;

  end if;

  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('first parent ' || l_pnt_request_id);
  END IF;
END IF;

--if customer_key_profile <> 'Y'
--update the corresponding child table entries with the header-level
--customer/change_seq information to allow old functionality to remain
--unchanged

if (l_customer_key_profile <> 'Y') then


UPDATE oe_lines_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
    /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691


COMMIT;

UPDATE oe_price_adjs_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

UPDATE oe_payments_iface_all               /* Bug #3419970 */
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

UPDATE oe_price_atts_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

UPDATE oe_credits_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

UPDATE oe_reservtns_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

UPDATE oe_lotserials_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

UPDATE oe_actions_iface_all
   SET request_id = l_request_id,
       sold_to_org_id = nvl(sold_to_org_id, l_sold_to_org_id),
       sold_to_org = nvl(sold_to_org, l_sold_to_org),
       org_id = l_org_id
 WHERE order_source_id = l_order_source_id
   AND orig_sys_document_ref = l_orig_sys_document_ref
   AND nvl(change_sequence, ' ') = nvl(l_change_sequence, ' ')
   AND nvl(org_id,l_org_id) = l_org_id ;
   /* AND decode(p_perf_param, 'Y',
          nvl(error_flag,'N'), ' ')
     = decode(p_perf_param, 'Y',
          'N', ' '); */ -- Bug 5205691

COMMIT;

end if;

-- end of updates to customer information based on profile


      l_count_header       := l_count_header       + 1;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDER SOURCE ID: '|| TO_CHAR ( L_ORDER_SOURCE_ID ) ) ;
          oe_debug_pub.add(  'ORIG SYS REFERENCE: '|| L_ORIG_SYS_DOCUMENT_REF ) ;
          oe_debug_pub.add(  'CHANGE SEQUENCE: ' || L_CHANGE_SEQUENCE ) ;
          oe_debug_pub.add(  'ORG ID: '||l_org_id);
          oe_debug_pub.add(  'L_RETURN_STATUS: ' || L_RETURN_STATUS ) ;
      END IF;

    -- MOAC set the policy context based on the org_id
    If G_ORG_ID IS NULL THEN
      MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
      G_ORG_ID := l_org_id;
    ELSIF G_ORG_ID IS NOT NULL AND
        G_ORG_ID <> l_org_id THEN
      MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
      G_ORG_ID := l_org_id;
    END IF;


/* -----------------------------------------------------------
      Call Import_Order procedure
   -----------------------------------------------------------
*/
      --oe_debug_pub.add('before calling Import_Order procedure');


      IF l_closed_flag = 'N' THEN
        --
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE CALLING IMPORT_ORDER PROCEDURE' ) ;
            oe_debug_pub.add('rtrim data ='||nvl(l_rtrim_data,'Null'));
        END IF;
        OE_ORDER_IMPORT_PVT.Import_Order (
		p_request_id		=> l_request_id,
		p_order_source_id	=> l_order_source_id,
		p_orig_sys_document_ref	=> l_orig_sys_document_ref,
	        p_sold_to_org_id        => l_sold_to_org_id,
                p_sold_to_org           => l_sold_to_org,
		p_change_sequence	=> l_change_sequence,
                p_org_id                => l_org_id,
		p_validate_only		=> l_validate_only,
		p_init_msg_list		=> l_init_msg_list,
                p_rtrim_data            => l_rtrim_data,
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_return_status		=> l_return_status,
		p_validate_desc_flex    => p_validate_desc_flex --bug4343612
		);

      ELSE
        --
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE CALLING IMPORT_ORDER PROCEDURE FOR CLOSED' ) ;
        END IF;
        OE_CNCL_ORDER_IMPORT_PVT.Import_Order (
		p_request_id		=> l_request_id,
		p_order_source_id	=> l_order_source_id,
		p_orig_sys_document_ref	=> l_orig_sys_document_ref,
	        p_sold_to_org_id        => l_sold_to_org_id,
                p_sold_to_org           => l_sold_to_org,
 		p_change_sequence	=> l_change_sequence,
                p_org_id                => l_org_id,
		p_validate_only		=> l_validate_only,
		p_init_msg_list		=> l_init_msg_list,
		p_msg_count		=> l_msg_count,
		p_msg_data		=> l_msg_data,
		p_return_status		=> l_return_status
		);
         --
      END IF;

     --oe_debug_pub.add('after call Import_Order l_return_status ' || l_return_status);
     IF l_return_status = FND_API.G_RET_STS_ERROR OR
        l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
     THEN
        l_count_header_failure := l_count_header_failure + 1;
     ELSE
        l_count_header_success := l_count_header_success + 1;
     END IF;


IF (p_perf_param = 'Y') THEN

        IF l_debug_level  > 0 THEN
        oe_debug_pub.add('after order_import for docref='|| l_orig_sys_document_ref || ' and request_id ' || l_request_id);
        oe_debug_pub.add('parent request_id:' || l_pnt_request_id);
        END IF;


  begin
  loop

    select rowidtochar(rowid)
    into l_rowid
    from oe_headers_iface_all    --MOAC
    where request_id = l_pnt_request_id
    and rownum = 1;

     UPDATE oe_headers_iface_all  --MOAC
        SET request_id = l_request_id
        WHERE request_id = l_pnt_request_id
        AND   nvl(error_flag,'N') = 'N'
        AND rowidtochar(rowid)      = l_rowid
        AND rownum = 1
        RETURNING orig_sys_document_ref
        INTO l_updated_docref;


  if sql%rowcount > 0 then
        IF l_debug_level  > 0 THEN
        oe_debug_pub.add('rowcount:' || sql%rowcount || ' updated docref:' || l_updated_docref);
        END IF;
     commit;
     exit;
  end if;

  end loop;

  close l_request_cursor;
        IF l_debug_level  > 0 THEN
        oe_debug_pub.add('after cursor closed');
        END IF;
  goto dist;

  exception
  when no_data_found then
       IF l_debug_level  > 0 THEN
       oe_debug_pub.add('In handled no data found exception');
       oe_debug_pub.add('No more records to process');
       END IF;

       EXIT;
  when others then
  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('others exception when attempting update' ||sqlerrm);
  END IF;
  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Order_Import_Conc_Pgm');
  END IF;
  fnd_file.put_line(FND_FILE.OUTPUT,'Unexpected error: ' || sqlerrm);
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end;

END IF;  -- p_perf_param was 'Y'


  END LOOP;			/* Request cursor */

  CLOSE l_request_cursor;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF ORDERS FOUND: ' || L_COUNT_HEADER ) ;
      oe_debug_pub.add(  'NO. OF ORDERS IMPORTED: '|| L_COUNT_HEADER_SUCCESS ) ;
      oe_debug_pub.add(  'NO. OF ORDERS FAILED: ' || L_COUNT_HEADER_FAILURE ) ;
  END IF;

  fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders found: ' ||
						l_count_header);
  fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders imported: '||
						l_count_header_success);
  fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders failed: ' ||
						l_count_header_failure);
  fnd_file.put_line(FND_FILE.OUTPUT,'');


/*   SELECT count(*) INTO l_count_msgs
     FROM oe_processing_msgs_vl
    WHERE request_id = l_request_id;

   IF l_count_msgs > 0 THEN
      fnd_file.put_line(FND_FILE.OUTPUT,'No. of messages: '||l_count_msgs);
      fnd_file.put_line(FND_FILE.OUTPUT,'');
      fnd_file.put_line(FND_FILE.OUTPUT,'Source/Order/Seq/Line    Message');
*/
/*    -----------------------------------------------------------
      Messages
      -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE MESSAGES LOOP' ) ;
      END IF;

      fnd_file.put_line(FND_FILE.OUTPUT,'');
      fnd_file.put_line(FND_FILE.OUTPUT,'Source/Order/Seq/Line    Message');
      OPEN l_msg_cursor;
      LOOP
        FETCH l_msg_cursor
         INTO l_order_source_id
            , l_orig_sys_document_ref
            , l_change_sequence
            , l_orig_sys_line_ref
            , l_org_id           --MOAC
            , l_message_text;
         EXIT WHEN l_msg_cursor%NOTFOUND;

         fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_order_source_id)
                                            ||'/'||l_orig_sys_document_ref
                                            ||'/'||l_change_sequence
                                            ||'/'||l_org_id
                                            ||'/'||l_orig_sys_line_ref
                                            ||' '||l_message_text);
         fnd_file.put_line(FND_FILE.OUTPUT,'');
      END LOOP;
--   END IF;

  END IF;
/* -----------------------------------------------------------
   End of Order_Import_Conc_Pgm
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'END OF ORDER IMPORT CONCURRENT PROGRAM' ) ;
   END IF;
   fnd_file.put_line(FND_FILE.OUTPUT, 'End of Order Import Concurrent Program');
   retcode := 0;
   --return;

EXCEPTION
  WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
       END IF;

       retcode := 2;

       fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders found: ' ||
						l_count_header);
       fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders imported: '||
						l_count_header_success);
       fnd_file.put_line(FND_FILE.OUTPUT,'No. of orders failed: ' ||
						l_count_header_failure);
       fnd_file.put_line(FND_FILE.OUTPUT,'');

END ORDER_IMPORT_CONC_PGM;


PROCEDURE ORDER_IMPORT_FORM(
   p_request_id			IN  NUMBER	DEFAULT FND_API.G_MISS_NUM
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref  	IN  VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER
  ,p_sold_to_org                IN  VARCHAR2
  ,p_change_sequence		IN  VARCHAR2	DEFAULT FND_API.G_MISS_CHAR
  ,p_org_id                     IN  Number
  ,p_validate_only		IN  VARCHAR2	DEFAULT FND_API.G_FALSE
  ,p_init_msg_list		IN  VARCHAR2	DEFAULT FND_API.G_TRUE
  ,p_rtrim_data                 In  Varchar2
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2


) IS

l_closed_flag VARCHAR2(1) DEFAULT 'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  --MOAC set policy context for single Org
  IF p_org_id IS NOT NULL THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Setting policy context to single-org' ) ;
     END IF;
    MO_GLOBAL.set_policy_context('S',p_org_id);
  END IF;


   SELECT closed_flag
   INTO   l_closed_flag
   FROM   oe_headers_iface_all
   WHERE  orig_sys_document_ref = p_orig_sys_document_ref
   AND    order_source_id = p_order_source_id
   AND    nvl(sold_to_org_id, -999) = nvl(p_sold_to_org_id, -999)
   AND    nvl(sold_to_org, ' ') = nvl(p_sold_to_org, ' ')
   AND    nvl(change_sequence, ' ') = nvl(p_change_sequence, ' ')
   AND    nvl(org_id,-99) = nvl(p_org_id,-99)
   AND    nvl(request_id, -999) = nvl(p_request_id, -999);


   IF (NVL(l_closed_flag,'N') = 'N') THEN
     --
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING IMPORT_ORDER PROCEDURE' ) ;
     END IF;


     OE_ORDER_IMPORT_PVT.Import_Order (
        p_request_id		=> p_request_id,
        p_order_source_id	=> p_order_source_id,
        p_orig_sys_document_ref	=> p_orig_sys_document_ref,
        p_sold_to_org_id        => p_sold_to_org_id,
        p_sold_to_org           => p_sold_to_org,
        p_change_sequence	=> p_change_sequence,
        p_org_id                => p_org_id,
        p_validate_only		=> p_validate_only,
        p_init_msg_list		=> p_init_msg_list,
        p_rtrim_data            => p_rtrim_data,
        p_msg_count		=> p_msg_count,
        p_msg_data		=> p_msg_data,
        p_return_status		=> p_return_status
        );
     --

   ELSE
     --
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING IMPORT_ORDER PROCEDURE FOR CLOSED' ) ;
     END IF;


     OE_CNCL_ORDER_IMPORT_PVT.Import_Order (
	p_request_id		=> p_request_id,
	p_order_source_id	=> p_order_source_id,
	p_orig_sys_document_ref	=> p_orig_sys_document_ref,
        p_sold_to_org_id        => p_sold_to_org_id,
        p_sold_to_org           => p_sold_to_org,
	p_change_sequence	=> p_change_sequence,
        p_org_id                => p_org_id,
	p_validate_only		=> p_validate_only,
	p_init_msg_list		=> p_init_msg_list,
	p_msg_count		=> p_msg_count,
	p_msg_data		=> p_msg_data,
	p_return_status		=> p_return_status
	);
     --
   END IF;

END ORDER_IMPORT_FORM;

END OE_ORDER_IMPORT_MAIN_PVT;

/
