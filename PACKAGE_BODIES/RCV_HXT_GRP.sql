--------------------------------------------------------
--  DDL for Package Body RCV_HXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_HXT_GRP" AS
/* $Header: RCVGHXTB.pls 120.17.12010000.15 2014/06/26 09:37:23 shikapoo ship $ */

-- record for all timecard attributes interesting to Purchasing
TYPE TimecardAttributesRec IS RECORD
( timecard_bb_id               HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, timecard_bb_ovn              HXC_TIME_BUILDING_BLOCKS.object_version_number%TYPE
, timecard_start_time          HXC_TIME_BUILDING_BLOCKS.start_time%TYPE
, timecard_stop_time           HXC_TIME_BUILDING_BLOCKS.stop_time%TYPE
, timecard_approval_status     HXC_TIMECARD_SUMMARY.approval_status%TYPE
, timecard_approval_date       HXC_TIME_BUILDING_BLOCKS.date_from%TYPE
, timecard_submission_date     HXC_TIMECARD_SUMMARY.submission_date%TYPE
, timecard_comment             HXC_TIME_BUILDING_BLOCKS.comment_text%TYPE
, day_bb_id                    HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, day_start_time               HXC_TIME_BUILDING_BLOCKS.start_time%TYPE
, detail_bb_id                 HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, detail_bb_ovn                HXC_TIME_BUILDING_BLOCKS.object_version_number%TYPE
, detail_type                  HXC_TIME_BUILDING_BLOCKS.type%TYPE
, detail_measure               HXC_TIME_BUILDING_BLOCKS.measure%TYPE
, detail_start_time            HXC_TIME_BUILDING_BLOCKS.start_time%TYPE
, detail_stop_time             HXC_TIME_BUILDING_BLOCKS.stop_time%TYPE
, detail_uom                   HXC_TIME_BUILDING_BLOCKS.unit_of_measure%TYPE
, detail_changed               VARCHAR2(30)
, detail_new                   VARCHAR2(30)
, detail_deleted               VARCHAR2(30)
, detail_date_from             HXC_TIME_BUILDING_BLOCKS.date_from%TYPE
, detail_date_to               HXC_TIME_BUILDING_BLOCKS.date_to%TYPE
, resource_id                  HXC_TIME_BUILDING_BLOCKS.resource_id%TYPE
, po_number                    PO_HEADERS_ALL.segment1%TYPE
, po_header_id                 PO_HEADERS_ALL.po_header_id%TYPE
, po_line                      PO_LINES_ALL.line_num%TYPE
, po_line_id                   PO_LINES_ALL.po_line_id%TYPE
, po_line_location_id          PO_LINE_LOCATIONS_ALL.line_location_id%TYPE
, po_distribution_id           PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE
, project_id                   PO_DISTRIBUTIONS_ALL.project_id%TYPE
, task_id                      PO_DISTRIBUTIONS_ALL.task_id%TYPE
, po_price_type                PO_TEMP_LABOR_RATES_V.asg_rate_type%TYPE
, po_price_type_display        PO_TEMP_LABOR_RATES_V.price_type_dsp%TYPE
, po_billable_amount           PO_LINES_ALL.amount%TYPE
, po_receipt_date              RCV_TRANSACTIONS.transaction_date%TYPE
, lpn_group_id                 RCV_TRANSACTIONS.lpn_group_id%TYPE

-- save the transaction type so we know how to check for success
, transaction_type             VARCHAR2(240)

-- we need to reference two rti rows for corrections
, receive_rti_id               RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE
, deliver_rti_id               RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE

-- we need to reference four rti rows for delete+insert
, delete_receive_rti_id        RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE
, delete_deliver_rti_id        RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE

-- parent txns exist when we have received against this po line before
, parent_receive_txn_id        RCV_TRANSACTIONS.transaction_id%TYPE
, parent_deliver_txn_id        RCV_TRANSACTIONS.transaction_id%TYPE

-- org_id of the PO/CWK
, org_id                       PO_HEADERS_ALL.org_id%TYPE

-- save the purchasing category attribute_id to attach to error messages
, time_attribute_id            HXC_TIME_ATTRIBUTES.time_attribute_id%TYPE

-- transient variable to save the validation status
, validation_status            VARCHAR2(30)

-- is this the old version of a changed block
, old_block                    VARCHAR2(1)
);

-- table to store all attributes for a particular block
TYPE TimecardAttributesTbl IS TABLE OF TimecardAttributesRec INDEX BY BINARY_INTEGER;

-- temp tables for ROI data
-- We will create one rhi row per PO per timecard
-- and one rti row per PO line per timecard
TYPE rhi_table IS TABLE OF RCV_HEADERS_INTERFACE%ROWTYPE INDEX BY BINARY_INTEGER;
TYPE rti_table IS TABLE OF RCV_TRANSACTIONS_INTERFACE%ROWTYPE INDEX BY BINARY_INTEGER;

-- store results of the above in a hash for quick lookup
TYPE rti_status_table IS TABLE OF BINARY_INTEGER INDEX BY BINARY_INTEGER;

-- cache records for use in caches

TYPE po_header_cr IS RECORD
( po_header_id             PO_HEADERS_ALL.po_header_id%TYPE
, segment1                 PO_HEADERS_ALL.segment1%TYPE
, user_hold_flag           PO_HEADERS_ALL.user_hold_flag%TYPE
, org_id                   PO_HEADERS_ALL.org_id%TYPE
, vendor_id                PO_HEADERS_ALL.vendor_id%TYPE
, vendor_site_id           PO_HEADERS_ALL.vendor_site_id%TYPE
);

-- Combine PO line/shipment info into a single record because
-- there is a 1-1 mapping between line and shipment for
-- Rate-Based Temp Labor
TYPE po_line_cr IS RECORD
( po_line_id               PO_LINES_ALL.po_line_id%TYPE
, po_header_id             PO_LINES_ALL.po_header_id%TYPE
, line_num                 PO_LINES_ALL.line_num%TYPE
, unit_price               PO_LINES_ALL.unit_price%TYPE
, matching_basis           PO_LINES_ALL.matching_basis%TYPE
, purchase_basis           PO_LINES_ALL.purchase_basis%TYPE
, order_type_lookup_code   PO_LINES_ALL.order_type_lookup_code%TYPE
, start_date               PO_LINES_ALL.start_date%TYPE
, expiration_date          PO_LINES_ALL.expiration_date%TYPE
, job_id                   PO_LINES_ALL.job_id%TYPE
, line_location_id         PO_LINE_LOCATIONS_ALL.line_location_id%TYPE
, approved_flag            PO_LINE_LOCATIONS_ALL.approved_flag%TYPE
, cancel_flag              PO_LINE_LOCATIONS_ALL.cancel_flag%TYPE
, closed_code              PO_LINE_LOCATIONS_ALL.closed_code%TYPE
, qty_rcv_exception_code   PO_LINE_LOCATIONS_ALL.qty_rcv_exception_code%TYPE
, tolerable_amount         PO_LINE_LOCATIONS_ALL.amount%TYPE
, timecard_amount          PO_LINE_LOCATIONS_ALL.amount%TYPE
, ship_to_organization_id  PO_LINE_LOCATIONS_ALL.ship_to_organization_id%TYPE
, ship_to_location_id      PO_LINE_LOCATIONS_ALL.ship_to_location_id%TYPE
, time_attribute_id        HXC_TIME_ATTRIBUTES.time_attribute_id%TYPE
);

TYPE po_distribution_cr IS RECORD
( po_distribution_id       PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE
, project_id               PO_DISTRIBUTIONS_ALL.project_id%TYPE
, task_id                  PO_DISTRIBUTIONS_ALL.task_id%TYPE
);

TYPE fnd_lookups_cr IS RECORD
( lookup_code              FND_LOOKUPS.lookup_code%TYPE
, meaning                  FND_LOOKUPS.meaning%TYPE
);

TYPE price_differentials_cr IS RECORD
( entity_id                PO_PRICE_DIFFERENTIALS.entity_id%TYPE
, price_type               PO_PRICE_DIFFERENTIALS.price_type%TYPE
, enabled_flag             PO_PRICE_DIFFERENTIALS.enabled_flag%TYPE
, multiplier               PO_PRICE_DIFFERENTIALS.multiplier%TYPE
, price                    PO_LINES_ALL.unit_price%TYPE
);

-- The PO information is new to 11.5.10 so do not introduce
-- compile-time dependency on those fields
TYPE per_all_assignments_cr IS RECORD
( person_id                PER_ALL_ASSIGNMENTS_F.person_id%TYPE
, po_line_id               PO_LINES_ALL.po_line_id%TYPE
, effective_start_date     PER_ALL_ASSIGNMENTS_F.effective_start_date%TYPE
, effective_end_date       PER_ALL_ASSIGNMENTS_F.effective_end_date%TYPE
);

TYPE rcv_transactions_cr IS RECORD
( receive_transaction_id   RCV_TRANSACTIONS.transaction_id%TYPE
, deliver_transaction_id   RCV_TRANSACTIONS.transaction_id%TYPE
, po_line_id               RCV_TRANSACTIONS.po_line_id%TYPE
, po_distribution_id       PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE
, project_id      	   PO_DISTRIBUTIONS_ALL.project_id%TYPE /* Bug 14609848 */
, task_id      		   PO_DISTRIBUTIONS_ALL.task_id%TYPE /* Bug 14609848 */
, timecard_id              RCV_TRANSACTIONS.timecard_id%TYPE
, timecard_ovn             RCV_TRANSACTIONS.timecard_ovn%TYPE
);

-- cache results of expensive OTL APIs and SQLs
TYPE build_block_cache IS TABLE OF HXC_USER_TYPE_DEFINITION_GRP.building_block_info INDEX BY BINARY_INTEGER;
TYPE build_attribute_cache IS TABLE OF HXC_USER_TYPE_DEFINITION_GRP.attribute_info INDEX BY BINARY_INTEGER;
TYPE po_header_cache IS TABLE OF po_header_cr INDEX BY BINARY_INTEGER;
TYPE po_line_cache IS TABLE OF po_line_cr INDEX BY BINARY_INTEGER;
TYPE po_distribution_cache IS TABLE OF po_distribution_cr INDEX BY BINARY_INTEGER;
TYPE price_type_lookup_cache IS TABLE OF fnd_lookups_cr INDEX BY BINARY_INTEGER;
TYPE price_differentials_cache IS TABLE OF price_differentials_cr INDEX BY BINARY_INTEGER;
TYPE assignments_cache IS TABLE OF per_all_assignments_cr INDEX BY BINARY_INTEGER;
TYPE rcv_transactions_cache IS TABLE OF rcv_transactions_cr INDEX BY BINARY_INTEGER;

-- package globals
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'RCV_HXT_GRP';
G_LOG_MODULE  CONSTANT VARCHAR2(40) := 'po.plsql.' || G_PKG_NAME;
G_CONC_LOG             VARCHAR2(32767);
 -- bug 5976883 : Have changed the fnd logging logic according to PO standards
 -- Now at all places we are using the module.package.procedure convention.
 g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
 g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;
-- global counters for summary reporting
g_retrieved_details      NUMBER := 0;
g_successful_details     NUMBER := 0;
g_failed_details         NUMBER := 0;
g_req_id                 NUMBER := 0;
g_group_id               NUMBER := 0;
g_txn_status             hxc_transactions.status%TYPE;
g_txn_msg                hxc_transactions.exception_description%TYPE;
g_overall_status         hxc_transactions.status%TYPE;

-- caches
g_build_block_cache             build_block_cache;
g_build_attribute_cache         build_attribute_cache;
g_po_header_cache               po_header_cache;
g_po_line_cache                 po_line_cache;
g_po_distribution_cache         po_distribution_cache;
g_price_type_lookup_cache       price_type_lookup_cache;
g_price_differentials_cache     price_differentials_cache;
g_assignments_cache             assignments_cache;
g_rcv_transactions_cache        rcv_transactions_cache;

-- performance info
g_retrieval_start                DATE;
g_retrieval_stop                 DATE;
g_retrieval_time                 NUMBER;
g_generic_start                  DATE;
g_generic_stop                   DATE;
g_generic_time                   NUMBER;
g_receiving_start                DATE;
g_receiving_stop                 DATE;
g_receiving_time                 NUMBER;
g_update_start                   DATE;
g_update_stop                    DATE;
g_validate_start                 DATE;
g_validate_stop                  DATE;

g_build_block_calls              NUMBER;
g_build_attribute_calls          NUMBER;
g_po_header_calls                NUMBER;
g_po_line_calls                  NUMBER;
g_po_distribution_calls          NUMBER;
g_price_type_lookup_calls        NUMBER;
g_price_differentials_calls      NUMBER;
g_assignments_calls              NUMBER;
g_rcv_transactions_calls         NUMBER;

g_build_block_misses             NUMBER;
g_build_attribute_misses         NUMBER;
g_po_header_misses               NUMBER;
g_po_line_misses                 NUMBER;
g_po_distribution_misses         NUMBER;
g_price_type_lookup_misses       NUMBER;
g_price_differentials_misses     NUMBER;
g_assignments_misses             NUMBER;
g_rcv_transactions_misses        NUMBER;

g_error_raised_flag    NUMBER := 0;--Bug:5559915
/** Bug:5559915
 *    Above variable is introduced to prevent logging of same
 *    error message for each entries in the Time Card.
 *    g_error_raised_flag = 0 error message is not logged
 *    g_error_raised_flag = 1 error message is logged
 */

-- cursor for retrieving successful receiving transactions
CURSOR new_rt_rows( v_group_id VARCHAR2 ) IS
    SELECT po_line_id
         , timecard_id
         , interface_transaction_id
      FROM rcv_transactions
     WHERE group_id = v_group_id;

ISP_STORE_TIMECARD_FAILED EXCEPTION;
ISP_RECONCILE_ACTIONS_FAILED EXCEPTION;
RETRIEVAL_FAILED EXCEPTION;
DEBUGGING_BREAKPOINT EXCEPTION;
DERIVE_DISTRIBUTION_ID_FAILED EXCEPTION;
DERIVE_JOB_ID_FAILED EXCEPTION;
DERIVE_ROI_VALUES_FAILED EXCEPTION;
TIMECARD_NOT_APPROVED EXCEPTION;

-- Private support procedures

-- wrapper for RCV_HXT_GRP.string
-- Bug 5976883 : Rewrote string debug function according to PO standards
PROCEDURE string
( log_level   IN number
, module      IN varchar2
, message     IN varchar2
) IS
l_debug_on BOOLEAN;
l_progress VARCHAR2(3) := '000';
BEGIN
IF NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y' THEN
 	  l_debug_on := TRUE;
END IF;
    -- add to fnd_log_messages
    -- asn_debug.put_line(module||': '||message,log_level);
    if (log_level = FND_LOG.LEVEL_STATEMENT and g_debug_stmt ) then
 	         po_debug.debug_stmt(module,l_progress,message);

    elsif (log_level = FND_LOG.LEVEL_UNEXPECTED and g_debug_unexp ) then
 	         po_debug.debug_unexp(module,l_progress,message);

    elsif (l_debug_on and log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
 	                FND_LOG.string(
 	                         log_level
 	                      ,  module||'.'||l_progress
 	                      ,  message
 	                         );
    end if;

    BEGIN
 	 FND_FILE.put_line(FND_FILE.log, message);
    EXCEPTION
 	 WHEN FND_FILE.UTL_FILE_ERROR THEN
 	      NULL;
    END;
END string;
-- bug 5976883 : This will help us debug attribute records.
PROCEDURE debug_TimecardAttributesRec
 	 ( p_log_head       IN varchar2
 	 , p_attributes     IN TimecardAttributesRec
 	 , l_new_old        IN varchar2 DEFAULT NULL
 	 ) IS
 	 l_progress varchar2(3):= '000';
 	  l_api_name         CONSTANT varchar2(30) := 'debug_TimecardAttributesRec';
 	  l_log_head         CONSTANT VARCHAR2(100) := G_LOG_MODULE || l_api_name;
 BEGIN
 	 if g_debug_stmt then
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_bb_id '          , p_attributes.timecard_bb_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_bb_ovn '         , p_attributes.timecard_bb_ovn);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_start_time '     , p_attributes.timecard_start_time);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_stop_time '      , p_attributes.timecard_stop_time);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_approval_status ', p_attributes.timecard_approval_status);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_approval_date '  , p_attributes.timecard_approval_date);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_submission_date ', p_attributes.timecard_submission_date);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-timecard_comment '        , p_attributes.timecard_comment);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-day_bb_id '               , p_attributes.day_bb_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-day_start_time '          , p_attributes.day_start_time);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_bb_id '            , p_attributes.detail_bb_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_bb_ovn '           , p_attributes.detail_bb_ovn);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_type '             , p_attributes.detail_type);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_measure '          , p_attributes.detail_measure);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_start_time '       , p_attributes.detail_start_time);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_stop_time '        , p_attributes.detail_stop_time);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_uom '              , p_attributes.detail_uom);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_changed '          , p_attributes.detail_changed);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_new '              , p_attributes.detail_new);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_deleted '          , p_attributes.detail_deleted);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_date_from '        , p_attributes.detail_date_from);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-detail_date_to '          , p_attributes.detail_date_to);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-resource_id '             , p_attributes.resource_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_number '               , p_attributes.po_number);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_header_id '            , p_attributes.po_header_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_line '                 , p_attributes.po_line);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_line_id '              , p_attributes.po_line_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_line_location_id '     , p_attributes.po_line_location_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_distribution_id '      , p_attributes.po_distribution_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-project_id '              , p_attributes.project_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-task_id '                 , p_attributes.task_id);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_price_type '           , p_attributes.po_price_type);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_price_type_display '   , p_attributes.po_price_type_display);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_billable_amount '      , p_attributes.po_billable_amount);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-po_receipt_date '         , p_attributes.po_receipt_date);
 	     PO_DEBUG.debug_var(l_log_head,l_progress,l_new_old ||'-lpn_group_id '       , p_attributes.lpn_group_id);
 	 end if;

 END debug_TimecardAttributesRec;


-- bug 5976883 <Debug END>

-- bug 5928019 : Need to set the rhi rows to error status if none of teh
-- associated rti rows are in PENDING status. We will call this just
-- before inserting the data into RHI AND RTI

procedure set_rhi_table_status (p_rhi_rows IN OUT NOCOPY rhi_table,
                                p_rti_rows IN OUT NOCOPY rti_table,
                                p_processable_rows_exist IN OUT NOCOPY VARCHAR2) IS

 l_transaction_id NUMBER;
 l_status  VARCHAR2(15);
 type l_index_table is table of VARCHAR2(10) index by binary_integer;
 l_temp l_index_table;
 l_api_name     CONSTANT varchar2(30) := 'set_rhi_table_status';
 l_log_head     CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
 l_progress VARCHAR2(3) := '000';
BEGIN
RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
 	                   , module => l_log_head
 	                   , message => 'Begin set_rhi_table_status'
 	                   );
-- bug 	6000903 <start>
/* New logic

The structure:
1. There can be rti rows corresponding to rhi rows (new receipts) or there can be
    rti rows without rhi rows (corrections).
2. These rows will have the header_interface_id AS null.
3. The rti records have the correct value of the processign status code, however
we need to set the processing_status_code of the rhi records and also need to determine
that finally if there are any net processable rows


The Algo:
scratch pad l_temp, which has a cell for each header_interface_id in the rhi table
*loop through the rti table
*If an errored record is found check its header interface_id
*if header_interface_id is present => the record belongs to a rhi record
*mark the scratch pad's cell for this header_interface_id as ERROR if it is not already
 pending
*This is done so that we record header_interface as pending even if one associated
 rti record exists with a pending status.
*if rti processing_status_code is ERROR and no rhi id is present, do nothing
*if rti processing status code is not ERROR, and rhi id is present mark the
  scratch pad's cell for that rhi id as PENDING, to indicate a processable record
  has been found. Also set the processable_rows_exist to Y.
*similarly if rti ps code is NOT error and rhi id is NULL processable rows exist

 Finally check the scratch pad, all header_ids that have ERROR in their
 respective cells will be marked as ERROR */
 	  -- bug 6391432
 	  -- Found that after having one failed record with RTI ID = NULL. The whole
 	  -- batch was failing in retrival process. This was due to an unhanded exception
 	  -- [NO DATA FOUND] was raised in the set_rhi_table_status.
 	  -- l_temp : Place holder plsql table indexed by header_interface_id. There
 	  -- are senario's that this table wont have value for some header_interface_id
 	  -- So when we looping through p_rti_rows there for some header_interface_id
 	  -- l_temp(p_rti_rows(i).header_interface_id) will not have any value. Which will
 	  -- throw a NO DATA FOUND exception.
 	  -- Added logic to overcome this problem. by using .exists() function.

p_processable_rows_exist := 'N';
for i in 1..p_rti_rows.count loop
	   RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE,module =>
	   l_log_head,message => 'p_rti_rows(i).processing_status_code :'||p_rti_rows(i).processing_status_code);
 	   RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE,module =>
	   l_log_head,message => 'p_rti_rows(i).header_interface_id :'||p_rti_rows(i).header_interface_id);

  if ((p_rti_rows(i).processing_status_code = 'ERROR') AND
       (p_rti_rows(i).header_interface_id is not null)) THEN
		if l_temp.exists(p_rti_rows(i).header_interface_id) THEN
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
			                     ,module => l_log_head
					     ,message => 'Setting ERROR l_temp(p_rti_rows(i).header_interface_id) :'||l_temp(p_rti_rows(i).header_interface_id));
			if nvl(l_temp(p_rti_rows(i).header_interface_id),'ERROR') <> 'PENDING' then
				l_temp(p_rti_rows(i).header_interface_id) := 'ERROR';
			end if;
		ELSE
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
			                    ,module => l_log_head
					    ,message => 'Setting ERROR l_temp header_interface_id ');
			l_temp(p_rti_rows(i).header_interface_id) := 'ERROR';
		end if;

  -- do nothing for condition rti_processing_status_code = ERROR AND
  -- rti_header_interface_id NULL
  elsif ((p_rti_rows(i).processing_status_code <> 'ERROR') AND
         (p_rti_rows(i).header_interface_id is  not null)) then
		l_temp(p_rti_rows(i).header_interface_id) := 'PENDING';
		RCV_HXT_GRP.string( log_level =>FND_LOG.LEVEL_PROCEDURE
		                    ,module => l_log_head
				    ,message => 'Setting Pending l_temp');
		p_processable_rows_exist := 'Y';
  elsif ((p_rti_rows(i).processing_status_code <> 'ERROR') AND
         (p_rti_rows(i).header_interface_id is null)) then
		p_processable_rows_exist := 'Y';
  end if;
end loop;

if p_rhi_rows.count > 0 then
	for i in 1..p_rhi_rows.count loop
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
		                    ,module => l_log_head
				    ,message =>'Loop 2 p_rhi_rows.header_interface_id :'||p_rhi_rows(i).header_interface_id);
		if l_temp.exists(p_rhi_rows(i).header_interface_id) THEN
			if l_temp(p_rhi_rows(i).header_interface_id) = 'ERROR' THEN
				RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
				                    ,module => l_log_head
						    ,message =>'Loop 2 l_temp :'||l_temp(p_rhi_rows(i).header_interface_id));
				p_rhi_rows(i).processing_status_code := 'ERROR';
			end if;
		end if;
	end loop;
end if;
EXCEPTION
	WHEN OTHERS THEN
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
		                    , module => l_log_head
				    , message => 'Unexpected exception in set_rhi_table_status ' || SQLERRM
				   );
		RAISE;
END set_rhi_table_status;

PROCEDURE initialize_cache_statistics IS
BEGIN
    -- We want to maintain the stats throughout the session
    -- so do not reset to zero if they are non-null
    IF g_build_block_calls IS NULL THEN
        g_build_block_calls              := 0;
        g_build_attribute_calls          := 0;
        g_po_header_calls                := 0;
        g_po_line_calls                  := 0;
        g_po_distribution_calls          := 0;
        g_price_type_lookup_calls        := 0;
        g_price_differentials_calls      := 0;
        g_assignments_calls              := 0;
        g_rcv_transactions_calls         := 0;

        g_build_block_misses             := 0;
        g_build_attribute_misses         := 0;
        g_po_header_misses               := 0;
        g_po_line_misses                 := 0;
        g_po_distribution_misses         := 0;
        g_price_type_lookup_misses       := 0;
        g_price_differentials_misses     := 0;
        g_assignments_misses             := 0;
        g_rcv_transactions_misses        := 0;
    END IF;
END initialize_cache_statistics;

PROCEDURE initialize_timing_statistics IS
BEGIN
    -- We want to maintain the stats throughout the session
    -- so do not reset to zero if they are non-null
    IF g_retrieval_time IS NULL THEN
        g_retrieval_time                 := 0;
        g_generic_time                   := 0;
        g_receiving_time                 := 0;
    END IF;
END initialize_timing_statistics;

-- This procedure is called by the update process
-- to reset state of the caches for each timecard
-- submission without actually clearing the caches
PROCEDURE initialize_caches IS
    l_po_line_id        PO_LINES_ALL.po_line_id%TYPE;
BEGIN
    l_po_line_id := g_po_line_cache.FIRST;
    WHILE l_po_line_id IS NOT NULL LOOP
        -- Reset the amounts in case the user tries
        -- to submit a timecard more than once
        g_po_line_cache(l_po_line_id).timecard_amount := 0;
        l_po_line_id := g_po_line_cache.NEXT(l_po_line_id);
    END LOOP;
END initialize_caches;

FUNCTION get_rhi_idx
( p_attributes          IN      TimecardAttributesRec
, p_rhi_rows            IN      rhi_table
, p_rti_rows            IN      rti_table
) RETURN NUMBER IS
    l_rhi_id                    RCV_HEADERS_INTERFACE.header_interface_id%TYPE;
BEGIN
    -- find a transaction of the matching header to get the header_interface_id
    FOR i IN 1..p_rti_rows.COUNT LOOP
        IF p_rti_rows(i).po_header_id = p_attributes.po_header_id AND
	   p_rti_rows(i).timecard_id = p_attributes.timecard_bb_id THEN
		l_rhi_id := p_rti_rows(i).header_interface_id;
		EXIT;
	END IF;
    END LOOP;

    -- use the header_interface_id to find the index in rhi_rows
    IF l_rhi_id IS NOT NULL THEN
        FOR i IN 1..p_rhi_rows.COUNT LOOP
            IF p_rhi_rows(i).header_interface_id = l_rhi_id THEN
                RETURN i;
            END IF;
        END LOOP;
    END IF;

    -- index not found
    RETURN NULL;
END get_rhi_idx;

FUNCTION get_rti_idx
( p_attributes          IN      TimecardAttributesRec
, p_rti_rows            IN      rti_table
) RETURN RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE IS
BEGIN
    -- projects case placed in separate loop so we only test once

    IF p_attributes.project_id IS NOT NULL AND
       p_attributes.task_id IS NOT NULL THEN
	FOR i IN 1..p_rti_rows.COUNT LOOP
		IF p_rti_rows(i).po_distribution_id = p_attributes.po_distribution_id AND
		   p_rti_rows(i).project_id = p_attributes.project_id AND /* Bug 14609848 */
		   p_rti_rows(i).task_id = p_attributes.task_id AND       /* Bug 14609848 */
		   p_rti_rows(i).timecard_id = p_attributes.timecard_bb_id THEN
			RETURN i;
		END IF;
	END LOOP;

    -- non-projects case
    ELSE
	FOR i IN 1..p_rti_rows.COUNT LOOP
		IF p_rti_rows(i).po_line_id = p_attributes.po_line_id AND
		   p_rti_rows(i).timecard_id = p_attributes.timecard_bb_id THEN
			RETURN i;
		END IF;
	END LOOP;
    END IF;

    -- index not found
    RETURN NULL;
END get_rti_idx;

FUNCTION get_group_id
( p_rti_rows            IN      rti_table
) RETURN RCV_TRANSACTIONS_INTERFACE.group_id%TYPE IS
BEGIN
    IF g_group_id = 0 THEN
	SELECT RCV_INTERFACE_GROUPS_S.NEXTVAL
	  INTO g_group_id
	  FROM dual;
    END IF;

    RETURN g_group_id;
END get_group_id;

FUNCTION get_po_header
( p_po_header_id              IN PO_HEADERS_ALL.po_header_id%TYPE
) RETURN po_header_cr IS
BEGIN
    g_po_header_calls := g_po_header_calls + 1;

    IF NOT g_po_header_cache.EXISTS(p_po_header_id) THEN
	g_po_header_misses := g_po_header_misses + 1;

        SELECT poh.po_header_id
             , poh.segment1
             , NVL (poh.user_hold_flag, 'N')
             , poh.org_id
             , poh.vendor_id
             , poh.vendor_site_id
          INTO g_po_header_cache(p_po_header_id).po_header_id
             , g_po_header_cache(p_po_header_id).segment1
             , g_po_header_cache(p_po_header_id).user_hold_flag
             , g_po_header_cache(p_po_header_id).org_id
             , g_po_header_cache(p_po_header_id).vendor_id
             , g_po_header_cache(p_po_header_id).vendor_site_id
          FROM po_headers_all poh
         WHERE poh.po_header_id = p_po_header_id;
    END IF;

    RETURN g_po_header_cache(p_po_header_id);
END get_po_header;

FUNCTION get_po_line
( p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE
) RETURN po_line_cr IS
BEGIN
    g_po_line_calls := g_po_line_calls + 1;

    IF NOT g_po_line_cache.EXISTS(p_po_line_id) THEN
        g_po_line_misses := g_po_line_misses + 1;

        SELECT pol.po_line_id
             , pol.po_header_id
             , pol.line_num
             , pol.unit_price
             , pol.matching_basis
             , pol.purchase_basis
             , pol.order_type_lookup_code
             , NVL (pol.start_date, HR_GENERAL.start_of_time)
             , NVL (pol.expiration_date, HR_GENERAL.end_of_time)
             , pol.job_id
             , poll.line_location_id
             , NVL (poll.approved_flag, 'N')
             , NVL (poll.cancel_flag, 'N')
             , NVL (poll.closed_code, 'OPEN')
             , NVL (poll.qty_rcv_exception_code, 'NONE')
             , poll.amount + ( poll.amount * NVL (poll.qty_rcv_tolerance, 0) / 100 )
             , 0
             , poll.ship_to_organization_id
             , poll.ship_to_location_id
          INTO g_po_line_cache(p_po_line_id).po_line_id
             , g_po_line_cache(p_po_line_id).po_header_id
             , g_po_line_cache(p_po_line_id).line_num
             , g_po_line_cache(p_po_line_id).unit_price
             , g_po_line_cache(p_po_line_id).matching_basis
             , g_po_line_cache(p_po_line_id).purchase_basis
             , g_po_line_cache(p_po_line_id).order_type_lookup_code
             , g_po_line_cache(p_po_line_id).start_date
             , g_po_line_cache(p_po_line_id).expiration_date
             , g_po_line_cache(p_po_line_id).job_id
             , g_po_line_cache(p_po_line_id).line_location_id
             , g_po_line_cache(p_po_line_id).approved_flag
             , g_po_line_cache(p_po_line_id).cancel_flag
             , g_po_line_cache(p_po_line_id).closed_code
             , g_po_line_cache(p_po_line_id).qty_rcv_exception_code
             , g_po_line_cache(p_po_line_id).tolerable_amount
             , g_po_line_cache(p_po_line_id).timecard_amount
             , g_po_line_cache(p_po_line_id).ship_to_organization_id
             , g_po_line_cache(p_po_line_id).ship_to_location_id
          FROM po_lines_all pol
             , po_line_locations_all poll
         WHERE pol.po_line_id = p_po_line_id
           AND poll.po_line_id = pol.po_line_id;
    END IF;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                        , module => G_LOG_MODULE
			, message => 'after po_line_id ' ||g_po_line_cache(p_po_line_id).po_line_id||'**'
                                ||'po_header_id '||g_po_line_cache(p_po_line_id).po_header_id||'**'
                                ||'line_num '||g_po_line_cache(p_po_line_id).line_num||'**'
                                ||'unit_price '||g_po_line_cache(p_po_line_id).unit_price||'**'
                                ||'matching_basis '||g_po_line_cache(p_po_line_id).matching_basis||'**'
                                ||'purchase_basis '||g_po_line_cache(p_po_line_id).purchase_basis||'**'
                                ||'order_type_lookup_code '||g_po_line_cache(p_po_line_id).order_type_lookup_code||'**'
                                ||'start_date '||g_po_line_cache(p_po_line_id).start_date||'**'
                                ||'expiration_date '||g_po_line_cache(p_po_line_id).expiration_date||'**'
                                ||'job_id '||g_po_line_cache(p_po_line_id).job_id||'**'
                                ||'line_location_id '||g_po_line_cache(p_po_line_id).line_location_id||'**'
                                ||'approved_flag '||g_po_line_cache(p_po_line_id).approved_flag||'**'
                                ||'cancel_flag '||g_po_line_cache(p_po_line_id).cancel_flag||'**'
                                ||'closed_code '||g_po_line_cache(p_po_line_id).closed_code||'**'
                                ||'qty_rcv_exception_code '||g_po_line_cache(p_po_line_id).qty_rcv_exception_code||'**'
                                ||'tolerable_amount '||g_po_line_cache(p_po_line_id).tolerable_amount||'**'
                                ||'timecard_amount '||g_po_line_cache(p_po_line_id).timecard_amount||'**'
                                ||'ship_to_organization_id '||g_po_line_cache(p_po_line_id).ship_to_organization_id||'**'
                                ||'ship_to_location_id '||g_po_line_cache(p_po_line_id).ship_to_location_id
                      );

    RETURN g_po_line_cache(p_po_line_id);
END get_po_line;

FUNCTION get_po_distribution
( p_po_line_id      IN PO_LINES_ALL.po_line_id%TYPE
, p_project_id      IN PO_DISTRIBUTIONS_ALL.project_id%TYPE
, p_task_id         IN PO_DISTRIBUTIONS_ALL.task_id%TYPE
) RETURN po_distribution_cr IS
                  l_api_name         CONSTANT varchar2(30) := 'get_po_distribution';
 	          l_log_head         CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    g_po_distribution_calls := g_po_distribution_calls + 1;

    IF p_project_id IS NULL OR
       p_task_id IS NULL THEN
	RETURN NULL;
    END IF;

    IF NOT g_po_distribution_cache.EXISTS(p_po_line_id) OR
           g_po_distribution_cache(p_po_line_id).project_id <> p_project_id OR
           g_po_distribution_cache(p_po_line_id).task_id <> p_task_id THEN
		g_po_distribution_misses := g_po_distribution_misses + 1;

		g_po_distribution_cache(p_po_line_id).project_id := p_project_id;
		g_po_distribution_cache(p_po_line_id).task_id := p_task_id;

		-- allocate all the amount to the first distribution that matches
		SELECT MIN(pod.po_distribution_id)
		   INTO g_po_distribution_cache(p_po_line_id).po_distribution_id
		   FROM po_distributions_all pod
		   WHERE pod.po_line_id = p_po_line_id
		     AND pod.project_id = p_project_id
		     AND pod.task_id = p_task_id;

		-- < Service Procurement ER Start>
		-- Get the first distribution from Purchase order which has a Dummp Project Associated.
		-- This is used in the case when user select a Project on the Timecard which doesn't matches
		-- with the projects in Purchase Order which was selected on  Time card.
		IF g_po_distribution_cache(p_po_line_id).po_distribution_id IS NULL THEN
			SELECT  MIN(psp.po_distribution_id)
			   INTO g_po_distribution_cache(p_po_line_id).po_distribution_id
			   FROM    PO_SP_VAL_V psp
			   WHERE   psp.po_line_id           = p_po_line_id
			      AND psp.project_id           IS NOT NULL
			      AND psp.task_id              IS NOT NULL
			      AND psp.VALIDATE_PROJECT_FLAG = 'Y';
		END IF;
		-- < Service Procurement ER Ends>
    END IF;

    RETURN g_po_distribution_cache(p_po_line_id);
EXCEPTION
    WHEN OTHERS THEN
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                          , module => l_log_head
                          , message => 'Unexpected exception deriving po_distribution_id (po_line_id=' || p_po_line_id || ', project_id=' || p_project_id || ', task_id=' || p_task_id || '): ' || SQLERRM
                          );
        RAISE DERIVE_DISTRIBUTION_ID_FAILED;
END get_po_distribution;

FUNCTION get_price_type_lookup
( p_price_type              IN PO_PRICE_DIFFERENTIALS.price_type%TYPE
) RETURN fnd_lookups_cr IS
    l_cache_index         BINARY_INTEGER;
BEGIN
    g_price_type_lookup_calls := g_price_type_lookup_calls + 1;

    -- Since 8i does not have support VARCHAR index we need to loop through the table
    -- which is acceptable for this case because we don't expect many differentials in
    -- the same timecard
    -- Most recently added price type is most likely to get looked up so search backwards
    l_cache_index := g_price_type_lookup_cache.LAST;
    WHILE l_cache_index IS NOT NULL LOOP
        IF g_price_type_lookup_cache(l_cache_index).lookup_code = p_price_type THEN
            EXIT;
        END IF;
        l_cache_index := g_price_type_lookup_cache.PRIOR(l_cache_index);
    END LOOP;

    IF l_cache_index IS NULL THEN
        g_price_type_lookup_misses := g_price_type_lookup_misses + 1;

        l_cache_index := NVL(g_price_type_lookup_cache.LAST, 0) + 1;

        SELECT p_price_type
             , meaning
          INTO g_price_type_lookup_cache(l_cache_index).lookup_code
             , g_price_type_lookup_cache(l_cache_index).meaning
          FROM fnd_lookups
         WHERE lookup_type = 'PRICE DIFFERENTIALS'
           AND lookup_code = p_price_type;
    ELSIF l_cache_index <> g_price_type_lookup_cache.LAST THEN
        -- maintain LRU
        g_price_type_lookup_cache(g_price_type_lookup_cache.LAST + 1) := g_price_type_lookup_cache(l_cache_index);
        g_price_type_lookup_cache.DELETE(l_cache_index);
        l_cache_index := g_price_type_lookup_cache.LAST;
    END IF;

    RETURN g_price_type_lookup_cache(l_cache_index);
END get_price_type_lookup;

FUNCTION get_price_differentials
( p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE
, p_price_type              IN PO_PRICE_DIFFERENTIALS.price_type%TYPE
) RETURN price_differentials_cr IS
    l_cache_index         BINARY_INTEGER;
BEGIN
    g_price_differentials_calls := g_price_differentials_calls + 1;

    -- shortcut for standard rate
    IF p_price_type = 'STANDARD' THEN
        DECLARE
            l_standard_rate    price_differentials_cr;
        BEGIN
            l_standard_rate.entity_id := p_po_line_id;
            l_standard_rate.price_type := p_price_type;
            l_standard_rate.enabled_flag := 'Y';
            l_standard_rate.multiplier := 1.0;
            l_standard_rate.price := get_po_line(p_po_line_id).unit_price;

            RETURN l_standard_rate;
        END;
    END IF;

    l_cache_index := g_price_differentials_cache.LAST;
    WHILE l_cache_index IS NOT NULL LOOP
        IF g_price_differentials_cache(l_cache_index).entity_id = p_po_line_id AND
	   g_price_differentials_cache(l_cache_index).price_type = p_price_type THEN
		EXIT;
        END IF;
        l_cache_index := g_price_differentials_cache.PRIOR(l_cache_index);
    END LOOP;

    IF l_cache_index IS NULL THEN
        g_price_differentials_misses := g_price_differentials_misses + 1;

        l_cache_index := NVL(g_price_differentials_cache.LAST, 0) + 1;

        SELECT entity_id
             , price_type
             , enabled_flag
             , multiplier
          INTO g_price_differentials_cache(l_cache_index).entity_id
             , g_price_differentials_cache(l_cache_index).price_type
             , g_price_differentials_cache(l_cache_index).enabled_flag
             , g_price_differentials_cache(l_cache_index).multiplier
          FROM po_price_differentials
         WHERE entity_type = 'PO LINE'
           AND entity_id = p_po_line_id
           AND price_type = p_price_type;

	 g_price_differentials_cache(l_cache_index).price := get_po_line(p_po_line_id).unit_price * g_price_differentials_cache(l_cache_index).multiplier;
    ELSIF l_cache_index <> g_price_differentials_cache.LAST THEN
	-- maintain LRU
        g_price_differentials_cache(g_price_differentials_cache.LAST + 1) := g_price_differentials_cache(l_cache_index);
        g_price_differentials_cache.DELETE(l_cache_index);
        l_cache_index := g_price_differentials_cache.LAST;
    END IF;

    RETURN g_price_differentials_cache(l_cache_index);
END get_price_differentials;

-- Gets assignment for this PO/person effective on a particular date
-- Throws a NO DATA FOUND if no such assignment exists
FUNCTION get_assignment
( p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE
, p_person_id               IN PER_ALL_ASSIGNMENTS_F.person_id%TYPE
, p_effective_date          IN DATE
) RETURN per_all_assignments_cr IS
    l_sql        VARCHAR2(1500);
BEGIN
    g_assignments_calls := g_assignments_calls + 1;

    IF NOT g_assignments_cache.EXISTS(p_po_line_id) OR
       g_assignments_cache(p_po_line_id).person_id <> p_person_id OR
       p_effective_date NOT BETWEEN
           g_assignments_cache(p_po_line_id).effective_start_date AND
           g_assignments_cache(p_po_line_id).effective_end_date THEN
		g_assignments_misses := g_assignments_misses + 1;

		-- < Service Procurement ER Start>
		-- look for assignment from the new PO CWK Association table
		-- along with with the Assignments in HRMS.

		-- The po info in this table is new in 11.5.10
		-- so we use dynamic sql to avoid compile-time
		-- dependencies to the new fields
		l_sql :=' SELECT effective_start_date , effective_end_date
		             FROM per_all_assignments_f paaf
			     WHERE paaf.po_line_id = :po_line_id
			        AND paaf.person_id = :person_id
				AND Trunc(:effective_date)
				BETWEEN Trunc(paaf.effective_start_date)
				   AND Trunc(paaf.effective_end_date)
                         UNION
			  SELECT effective_start_date , effective_end_date
			     FROM per_all_assignments_f paaf
			          , po_cwk_associations pca
				  , po_headers_all ph
				  , po_lines_all pl
			     WHERE pca.po_line_id = :po_line_id
			        AND pca.cwk_person_id = :person_id
				AND pca.po_line_id = pl.po_line_id
				AND pca.po_header_id = ph.po_header_id
				AND pca.cwk_person_id = paaf.person_id
				AND paaf.job_id = pl.job_id
				AND ph.vendor_id = paaf.vendor_id
				AND ph.vendor_site_id = paaf.vendor_site_id
				AND Trunc(:effective_date)
				BETWEEN Trunc(paaf.effective_start_date)
				   AND Trunc(paaf.effective_end_date) ';

		EXECUTE IMMEDIATE l_sql
		   INTO g_assignments_cache(p_po_line_id).effective_start_date
		        , g_assignments_cache(p_po_line_id).effective_end_date
		   USING p_po_line_id
		         , p_person_id
			 , p_effective_date
			 , p_po_line_id
			 , p_person_id
			 , p_effective_date;
		-- < Service Procurement ER Ends >
    END IF;

    RETURN g_assignments_cache(p_po_line_id);
END get_assignment;

FUNCTION get_rcv_transaction
( p_timecard_bb_id          IN HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE
) RETURN rcv_transactions_cr IS
    l_api_name         CONSTANT varchar2(30) := 'get_rcv_transaction';
    l_log_head         CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Finding Parent Transcations , TimeCard ID: ' || p_timecard_bb_id || ' Po line Id: ' || p_po_line_id
                      );
    g_rcv_transactions_calls := g_rcv_transactions_calls + 1;

    IF NOT g_rcv_transactions_cache.EXISTS(p_timecard_bb_id) OR
       g_rcv_transactions_cache(p_timecard_bb_id).po_line_id <> p_po_line_id THEN
	g_rcv_transactions_misses := g_rcv_transactions_misses + 1;

	g_rcv_transactions_cache(p_timecard_bb_id).po_line_id := p_po_line_id;
	--Bug 5217532 START
	--Break the old SQL into 2 different SQL to avoid Merge Join Catesian
	BEGIN
		SELECT receive.transaction_id
		   INTO g_rcv_transactions_cache(p_timecard_bb_id).receive_transaction_id
		   FROM rcv_transactions receive
		   WHERE receive.timecard_id = p_timecard_bb_id
		      AND receive.po_line_id = p_po_line_id
		      AND receive.transaction_type = 'RECEIVE';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			g_rcv_transactions_cache(p_timecard_bb_id).receive_transaction_id := NULL;
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
			                    , module => l_log_head
					    , message => 'Unable to find Parent Transcations ,TimeCard ID: ' || p_timecard_bb_id || ' po_line_id: ' || p_po_line_id
					  );

        END;

        BEGIN
            SELECT deliver.transaction_id
              INTO g_rcv_transactions_cache(p_timecard_bb_id).deliver_transaction_id
              FROM rcv_transactions deliver
             WHERE deliver.timecard_id = p_timecard_bb_id
               AND deliver.po_line_id = p_po_line_id
               AND deliver.transaction_type = 'DELIVER';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                g_rcv_transactions_cache(p_timecard_bb_id).deliver_transaction_id := NULL;
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Unable to find Parent Transcations ,TimeCard ID: ' || p_timecard_bb_id || ' po_line_id: ' || p_po_line_id
                      );

        END;
        --Bug 5217532 END
    END IF;

    RETURN g_rcv_transactions_cache(p_timecard_bb_id);
END get_rcv_transaction;

FUNCTION get_rcv_transaction
( p_timecard_bb_id          IN HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE
, p_po_distribution_id      IN PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE
, p_project_id      	    IN PO_DISTRIBUTIONS_ALL.project_id%TYPE /* Bug 14609848 */
, p_task_id      		    IN PO_DISTRIBUTIONS_ALL.task_id%TYPE /* Bug 14609848 */
) RETURN rcv_transactions_cr IS
    l_api_name         CONSTANT varchar2(30) := 'get_rcv_transaction';
    l_log_head         CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Finding Parent Transcations , TimeCard ID: ' || p_timecard_bb_id || ' po_line_id: ' || p_po_line_id || ' po_distribution_id: ' || p_po_distribution_id
                      );
    --17921123 check for null project and task instead of null distribution
	IF (p_project_id IS NULL AND p_task_id IS NULL )THEN
        RETURN get_rcv_transaction( p_timecard_bb_id, p_po_line_id );
    END IF;

    g_rcv_transactions_calls := g_rcv_transactions_calls + 1;

    IF NOT g_rcv_transactions_cache.EXISTS(p_timecard_bb_id) OR
       g_rcv_transactions_cache(p_timecard_bb_id).project_id <> p_project_id OR /* Bug 14609848 */
       g_rcv_transactions_cache(p_timecard_bb_id).task_id <> p_task_id OR /* Bug 14609848 */
       g_rcv_transactions_cache(p_timecard_bb_id).po_distribution_id <> p_po_distribution_id THEN
        g_rcv_transactions_misses := g_rcv_transactions_misses + 1;

        g_rcv_transactions_cache(p_timecard_bb_id).po_distribution_id := p_po_distribution_id;
	g_rcv_transactions_cache(p_timecard_bb_id).project_id := p_project_id;  /* Bug 14609848 */
        g_rcv_transactions_cache(p_timecard_bb_id).task_id := p_task_id; /* Bug 14609848 */

        --Bug 5217532 START
        --Break the old SQL into 2 different SQL to avoid Merge Join Catesian
        BEGIN
            SELECT receive.transaction_id
              INTO g_rcv_transactions_cache(p_timecard_bb_id).receive_transaction_id
              FROM rcv_transactions receive
             WHERE receive.timecard_id = p_timecard_bb_id
               AND receive.po_distribution_id = p_po_distribution_id
               AND receive.project_id = p_project_id /* Bug 14609848 */
               AND receive.task_id = p_task_id /* Bug 14609848 */
               AND receive.transaction_type = 'RECEIVE';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                g_rcv_transactions_cache(p_timecard_bb_id).receive_transaction_id := NULL;
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Unable to find Parent Transcations ,TimeCard ID: ' || p_timecard_bb_id || ' po_line_id: ' || p_po_line_id || ' po_distribution_id: ' || p_po_distribution_id
                      );
        END;

        BEGIN
            SELECT deliver.transaction_id
              INTO g_rcv_transactions_cache(p_timecard_bb_id).deliver_transaction_id
              FROM rcv_transactions deliver
             WHERE deliver.timecard_id = p_timecard_bb_id
               AND deliver.po_distribution_id = p_po_distribution_id
               AND deliver.project_id = p_project_id /* Bug 14609848 */
               AND deliver.task_id = p_task_id /* Bug 14609848 */
               AND deliver.transaction_type = 'DELIVER';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                g_rcv_transactions_cache(p_timecard_bb_id).deliver_transaction_id := NULL;
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Unable to find Parent Transcations ,TimeCard ID: ' || p_timecard_bb_id || ' po_line_id: ' || p_po_line_id || ' po_distribution_id: ' || p_po_distribution_id
                      );
        END;
        --Bug 5217532 END
    END IF;

    RETURN g_rcv_transactions_cache(p_timecard_bb_id);
END get_rcv_transaction;

-- cached wrapper for build_block
FUNCTION build_block
( p_bb_id                   IN HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, p_bb_ovn                  IN HXC_TIME_BUILDING_BLOCKS.object_version_number%TYPE
) RETURN HXC_USER_TYPE_DEFINITION_GRP.building_block_info IS
BEGIN
    g_build_block_calls := g_build_block_calls + 1;

    IF NOT g_build_block_cache.EXISTS(p_bb_id) OR
       g_build_block_cache(p_bb_id).object_version_number <> p_bb_ovn
    THEN
        g_build_block_misses := g_build_block_misses + 1;
        g_build_block_cache(p_bb_id) := HXC_INTEGRATION_LAYER_V1_GRP.build_block(p_bb_id, p_bb_ovn);
    END IF;

    RETURN g_build_block_cache(p_bb_id);
END build_block;

-- Cached wrapper for build_attribute
-- Returns the first record in the table returned by OTL
-- since 8i does not support table of tables
FUNCTION build_attribute
( p_bb_id                   IN HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, p_bb_ovn                  IN HXC_TIME_BUILDING_BLOCKS.object_version_number%TYPE
, p_attribute_category      IN HXC_TIME_ATTRIBUTES.attribute_category%TYPE
) RETURN HXC_USER_TYPE_DEFINITION_GRP.attribute_info IS
BEGIN
    g_build_attribute_calls := g_build_attribute_calls + 1;

    IF NOT g_build_attribute_cache.EXISTS(p_bb_id) OR
       g_build_attribute_cache(p_bb_id).object_version_number <> p_bb_ovn OR
       g_build_attribute_cache(p_bb_id).attribute_category <> p_attribute_category THEN
		g_build_attribute_misses := g_build_attribute_misses + 1;
		g_build_attribute_cache(p_bb_id) := HXC_INTEGRATION_LAYER_V1_GRP.build_attribute( p_bb_id, p_bb_ovn, p_attribute_category )(1);
    END IF;

    RETURN g_build_attribute_cache(p_bb_id);
END build_attribute;

-- Procedure to skip over related attributes and old blocks
-- Used when skipping over detail blocks
PROCEDURE skip_block
( p_blocks                 IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.t_building_blocks
, p_blk_idx                IN OUT NOCOPY BINARY_INTEGER
, p_old_blocks             IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.t_building_blocks
, p_old_blk_idx            IN OUT NOCOPY BINARY_INTEGER
, p_attributes             IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute
, p_att_idx                IN OUT NOCOPY BINARY_INTEGER
, p_old_attributes         IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute
, p_old_att_idx            IN OUT NOCOPY BINARY_INTEGER
) IS
BEGIN
    -- skip the attributes for this block
    WHILE p_att_idx <= p_attributes.LAST AND p_attributes(p_att_idx).bb_id = p_blocks(p_blk_idx).bb_id LOOP
        p_att_idx := p_att_idx + 1;
    END LOOP;

    -- skip the old block for this block
    IF p_blocks(p_blk_idx).changed = 'Y' THEN
        -- skip the old attributes as well
        WHILE p_old_att_idx <= p_old_attributes.LAST AND p_old_attributes(p_old_att_idx).bb_id = p_old_blocks(p_old_blk_idx).bb_id LOOP
            p_old_att_idx := p_old_att_idx + 1;
        END LOOP;

        p_old_blk_idx := p_old_blk_idx + 1;
    END IF;

    p_blk_idx := p_blk_idx + 1;
END skip_block;

/*PROCEDURE  Name : Set_Attribute*/
PROCEDURE Set_Attribute
( p_attributes          IN OUT NOCOPY TimecardAttributesRec
, p_attribute_name      IN            HXC_MAPPING_COMPONENTS.field_name%TYPE
, p_attribute_value     IN            HXC_TIME_ATTRIBUTES.attribute1%TYPE
, p_attribute_id        IN            HXC_TIME_ATTRIBUTES.time_attribute_id%TYPE DEFAULT NULL
) IS
    l_attribute_name    HXC_MAPPING_COMPONENTS.field_name%TYPE;
    l_api_name          CONSTANT varchar2(30) := 'Set_Attribute';
    l_log_head          CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;

    -- Bug# 14492865 - Start
    l_decimal_separator_character VARCHAR2(1);
    l_grouping_separator_character VARCHAR2(1);
    g_number_mask       CONSTANT VARCHAR2(255) := '9999999999999999999999999999999999999999999999D9999999999999999';
    l_attribute_value 	VARCHAR2(20);
    nls_num_chars 		VARCHAR(2);
    -- Bug# 14492865 - End
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Setting attribute ' || p_attribute_name || ' with value ' || p_attribute_value || ' (p_attribute_id=' || p_attribute_id || ')'
                      );
    l_attribute_name := upper(p_attribute_name);

    IF l_attribute_name = 'ORG_ID' THEN
        p_attributes.org_id := p_attribute_value;
    ELSIF l_attribute_name = 'PO NUMBER' THEN
        p_attributes.po_number := p_attribute_value;
    ELSIF l_attribute_name = 'PO HEADER ID' THEN
        p_attributes.po_header_id := p_attribute_value;
    ELSIF l_attribute_name = 'PO LINE NUMBER' THEN
        p_attributes.po_line := p_attribute_value;
    ELSIF l_attribute_name = 'PO LINE ID' THEN
        p_attributes.po_line_id := p_attribute_value;
        p_attributes.time_attribute_id := p_attribute_id;   -- can be captured with any purchasing attribute
    ELSIF l_attribute_name = 'PO PRICE TYPE' THEN
        p_attributes.po_price_type := p_attribute_value;
    ELSIF l_attribute_name = 'PO PRICE TYPE DISPLAY' THEN
        p_attributes.po_price_type_display := p_attribute_value;
    ELSIF l_attribute_name = 'PO BILLABLE AMOUNT' THEN
		-- Bug# 14492865 - Start
		/*Getting session preferences.*/
		  select value INTO nls_num_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';
		  l_decimal_separator_character := SubStr(nls_num_chars,1,1);
		  l_grouping_separator_character := SubStr(nls_num_chars,2,1);
		  l_attribute_value :=   p_attribute_value;
		/*Replacing decimal seperator*/
		  IF(instr(l_attribute_value, ',') > 0) THEN
			l_attribute_value := REPLACE(l_attribute_value,',' ,l_decimal_separator_character);
			ELSE IF(instr(l_attribute_value, '.') > 0) THEN
			  l_attribute_value := REPLACE(l_attribute_value,'.' ,l_decimal_separator_character);
			END IF;
		  END IF;
		/*Converting  into destination number format*/
		 p_attributes.po_billable_amount := to_number(l_attribute_value, g_number_mask, 'NLS_NUMERIC_CHARACTERS='||nls_num_chars||'') ;
		-- Bug# 14492865 - End
    ELSIF l_attribute_name = 'PO RECEIPT DATE' THEN
        p_attributes.po_receipt_date := FND_DATE.Canonical_to_Date(p_attribute_value);
    ELSIF l_attribute_name = 'PROJECT_ID' THEN
        p_attributes.project_id := p_attribute_value;
    ELSIF l_attribute_name = 'TASK_ID' THEN
        p_attributes.task_id := p_attribute_value;
    END IF;
END Set_Attribute;

-- This procedure is called during update and validate. In these processes,
-- the attributes are in totally random order, so we use the timecard_id
-- as an index into the attributes table.
PROCEDURE Sort_Attributes
( p_all_attributes      IN OUT NOCOPY TimecardAttributesTbl
, p_raw_attributes      IN            HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info
) IS
    l_bb_id             HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE;
    l_api_name         CONSTANT varchar2(30) := 'Sort_Attributes';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Sort_Attributes'
                  );

    -- loop through all the attributes to sort them out
    FOR att_idx IN 1..p_raw_attributes.COUNT LOOP
        l_bb_id := p_raw_attributes(att_idx).building_block_id;

        IF NOT p_all_attributes.EXISTS(l_bb_id) THEN
            p_all_attributes(l_bb_id).detail_bb_id := l_bb_id;
        END IF;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Capturing attribute_id=' || p_raw_attributes(att_idx).time_attribute_id || ', attribute_name=' || p_raw_attributes(att_idx).attribute_name
                          );

        Set_Attribute( p_all_attributes(l_bb_id)
                     , p_raw_attributes(att_idx).attribute_name
                     , p_raw_attributes(att_idx).attribute_value
                     , p_raw_attributes(att_idx).time_attribute_id
                     );
    END LOOP;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'End Sort_Attributes'
                      );
END Sort_Attributes;

PROCEDURE Update_Attributes
( p_attributes          IN OUT NOCOPY TimecardAttributesRec
, p_messages            IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table
) IS
l_api_name         CONSTANT varchar2(30) := 'Update_Attributes';
l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
po_update_flag    VARCHAR2(1) :='N'; --bug 6998132
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Update_Attributes'
                  );

    -- Derive id's

    -- The layout only deposits id values, so we must always derive the display
    -- values from the id values, and null the outdated display value if
    -- the id is null.

    --bug 6998132 start
    IF p_attributes.po_number IS NOT NULL THEN

      BEGIN
        SELECT 'Y'
        INTO po_update_flag
        FROM dual
        WHERE EXISTS (SELECT segment1
                  FROM po_headers_all
                  WHERE segment1=p_attributes.po_number
                  AND org_id=hxc_timecard_properties.setup_mo_global_params(fnd_global.employee_id)
                  AND Nvl(closed_code,'OPEN') <> 'FINALLY CLOSED'
                  AND Nvl(user_hold_flag,'N') <> 'Y'
                  );
      EXCEPTION
	WHEN  No_Data_Found THEN
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                           , p_message_token => 'ERR&' || 'Existing PO in uneditable state -- Finally Closed/On Hold '
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'HXC'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
      END;

    END IF;
    -- bug 6998132 end

    -- derive po_number
    IF p_attributes.po_header_id IS NULL THEN
        p_attributes.po_number := NULL;
    ELSE
        BEGIN
            p_attributes.po_number := get_po_header(p_attributes.po_header_id).segment1;
        EXCEPTION
            WHEN OTHERS THEN
                -- unexpected exception deriving po header id
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                              , module => l_log_head
                              , message => 'Unexpected exception deriving PO Header Id (PO Number=' || p_attributes.po_number || '): ' || SQLERRM
                              );
        END;
    END IF;

    -- derive po_line
    IF p_attributes.po_line_id IS NULL THEN
        p_attributes.po_line := NULL;
    ELSE
        BEGIN
            p_attributes.po_line := get_po_line(p_attributes.po_line_id).line_num;
        EXCEPTION
            WHEN OTHERS THEN
                -- unexpected exception deriving po line id
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                                  , module => l_log_head
                                  , message => 'Unexpected exception deriving PO Line Number (PO Header Id=' || p_attributes.po_header_id || ', PO Line Id=' || p_attributes.po_line_id || '): ' || SQLERRM
                                  );
        END;
    END IF;

    -- derive price_type_display
    -- not cached because 8i doesn't support non-integer indexing
    -- should cache when moving to 9i
    IF p_attributes.po_price_type IS NULL THEN
        p_attributes.po_price_type_display := NULL;
    ELSE
        BEGIN
            p_attributes.po_price_type_display := get_price_type_lookup(p_attributes.po_price_type).meaning;
        EXCEPTION
            WHEN OTHERS THEN
                -- unexpected exception deriving price type
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                                  , module => l_log_head
                                  , message => 'Unexpected exception deriving PO Price Type Display (PO Price Type=' || p_attributes.po_price_type || '): ' || SQLERRM
                                  );
        END;
    END IF;

    -- calculated fields

    -- PO Billable Amount
    IF p_attributes.detail_measure IS NOT NULL AND
       p_attributes.po_line_id IS NOT NULL AND
       p_attributes.po_price_type IS NOT NULL THEN
	BEGIN
		p_attributes.po_billable_amount := p_attributes.detail_measure * get_price_differentials(p_attributes.po_line_id, p_attributes.po_price_type).price;
	EXCEPTION
		WHEN OTHERS THEN
			-- unexpected exception deriving PO Billable Amount
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
			                    , module => l_log_head
					    , message => 'Unexpected exception deriving PO Billable Amount (PO Price Type=' || p_attributes.po_price_type || ', PO Line Id=' || p_attributes.po_line_id || '): ' || SQLERRM
					  );
        END;
    END IF;

    -- PO Receipt Date
    -- This field is no longer set during deposit, because the correct transaction date
    -- can be determined much more easily at retrieval time, when it is clear whether
    -- the receiving transaction type is RECEIVE or CORRECT
    p_attributes.po_receipt_date := SYSDATE;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Update_Attributes'
                  );
END Update_Attributes;

PROCEDURE Validate_Attributes
( p_attributes          IN OUT NOCOPY TimecardAttributesRec
, p_messages            IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table
) IS
    l_api_name         CONSTANT varchar2(30) := 'Validate_Attributes';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
    l_count                              NUMBER;

    WRONG_BB_TYPE                        EXCEPTION;
    WRONG_BB_UOM                         EXCEPTION;
    INCOMPLETE_PO_INFO                   EXCEPTION;
    NO_PO_INFO                           EXCEPTION;
    NO_PO_LINE_INFO                      EXCEPTION;
    NO_AMT_INFO                          EXCEPTION;
    NO_RATE_INFO                         EXCEPTION;
    NEGATIVE_HOURS                       EXCEPTION;
    INVALID_PO                           EXCEPTION;
    INVALID_PO_EDIT                      EXCEPTION;
    INVALID_PO_LINE                      EXCEPTION;
    INVALID_PO_LINE_EDIT                 EXCEPTION;
    INVALID_RATE_TYPE                    EXCEPTION;
    INVALID_ASSIGNMENT                   EXCEPTION;
    BB_DATE_OUT_OF_ASG_PERIOD            EXCEPTION;
    BB_DATE_OUT_OF_PO_PERIOD             EXCEPTION;
BEGIN
    -- initialize the validation status to error so we can short-circuit
    -- the procedure in case of error
    p_attributes.validation_status := 'ERROR';

    -- validate that the timecard is the correct type
    IF p_attributes.detail_type <> 'MEASURE' THEN
        RAISE WRONG_BB_TYPE;
    END IF;

    IF p_attributes.detail_uom <> 'HOURS' THEN
        RAISE WRONG_BB_UOM;
    END IF;

    IF p_attributes.detail_measure < 0 THEN
        RAISE NEGATIVE_HOURS;
    END IF;

    -- validate that all relevant attributes are populated
    IF p_attributes.po_number IS NULL AND
       p_attributes.po_header_id IS NULL AND
       p_attributes.po_line IS NULL AND
       p_attributes.po_line_id IS NULL AND
       p_attributes.po_price_type_display IS NULL AND
       p_attributes.po_price_type IS NULL THEN
        -- User didn't enter any attribute
        -- This is a special case where OTL does not have a Java object to attach
        -- an inline message to the attribute, so we attach a special message to
        -- every detail block in the row
        RAISE INCOMPLETE_PO_INFO;
    END IF;

    IF p_attributes.po_number IS NULL OR
       p_attributes.po_header_id IS NULL THEN
        RAISE NO_PO_INFO;
    END IF;

    IF p_attributes.po_line IS NULL OR
       p_attributes.po_line_id IS NULL THEN
        RAISE NO_PO_LINE_INFO;
    END IF;

    IF p_attributes.po_price_type_display IS NULL OR
       p_attributes.po_price_type IS NULL THEN
        RAISE NO_RATE_INFO;
    END IF;

    IF p_attributes.po_billable_amount IS NULL THEN
        RAISE NO_AMT_INFO;
    END IF;

    -- we don't check for receipt date because it will be calculated during retrieval

    -- validate that the PO is a valid, open PO
    DECLARE
        -- PO statuses
        l_include_closed_po          fnd_profile_option_values.profile_option_value%TYPE;

        -- PO dates
        pol_start_date        DATE;
        pol_end_date          DATE;
    BEGIN
        -- Capture all the flags so we can print log them when the PO is invalid, to aid debugging
        -- We don't need to check the flags at Shipment level because there is only going to be 1
        -- shipment for the line, so the status will bubble up to the line level.
        l_include_closed_po := NVL (FND_PROFILE.value('RCV_CLOSED_PO_DEFAULT_OPTION'), 'N');

	/*bug 6902391 Changing to single org as in 11.5.10*/

	RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
	                    , module => l_log_head
			    , message => 'TimeCard day_start_time ' || p_attributes.day_start_time || 'Timecard resource_id = '||p_attributes.resource_id
			  );

	RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
	                    , module => l_log_head
			    , message => 'hr_organization_api.get_operating_unit = ' || hxc_timecard_properties.setup_mo_global_params(fnd_global.employee_id)
			  );

	IF get_po_header(p_attributes.po_header_id).user_hold_flag <> 'N' OR
	   get_po_header(p_attributes.po_header_id).org_id <> hxc_timecard_properties.setup_mo_global_params(p_attributes.resource_id) THEN
	   -- Modified the If condition for bug 9255870, passing p_attributes.resource_id instead of fnd_global.employee_id
	   -- Condition removed as not required. After R12 MOAC. User can use Purchase
	   -- Order Created in other Operating Unit.
	   -- get_po_header(p_attributes.po_header_id).org_id <> FND_GLOBAL.org_id
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
		                    , module => l_log_head
				    , message => 'PO is invalid: ' || '*'
				      || get_po_header(p_attributes.po_header_id).user_hold_flag || '*'
				  );

		IF p_attributes.old_block = 'Y' THEN
			RAISE INVALID_PO_EDIT;
		ELSE
			RAISE INVALID_PO;
		END IF;
	END IF;

	IF get_po_line(p_attributes.po_line_id).matching_basis <> 'AMOUNT' OR
           get_po_line(p_attributes.po_line_id).purchase_basis <> 'TEMP LABOR' OR
           get_po_line(p_attributes.po_line_id).order_type_lookup_code <> 'RATE' OR
           get_po_line(p_attributes.po_line_id).approved_flag <> 'Y' OR
           get_po_line(p_attributes.po_line_id).cancel_flag <> 'N' OR
           get_po_line(p_attributes.po_line_id).closed_code = 'FINALLY CLOSED' OR
           (l_include_closed_po <> 'Y' AND get_po_line(p_attributes.po_line_id).closed_code IN ('CLOSED','CLOSED FOR RECEIVING')) THEN
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
		                    , module => l_log_head
				    , message => 'Line is invalid: ' || '*'
                                      || get_po_line(p_attributes.po_line_id).matching_basis || '*'
                                      || get_po_line(p_attributes.po_line_id).purchase_basis || '*'
                                      || get_po_line(p_attributes.po_line_id).order_type_lookup_code || '*'
                                      || get_po_line(p_attributes.po_line_id).approved_flag || '*'
                                      || get_po_line(p_attributes.po_line_id).cancel_flag || '*'
                                      || get_po_line(p_attributes.po_line_id).closed_code || '*'
                                      || l_include_closed_po || '*'
                                  );
		IF p_attributes.old_block = 'Y' THEN
			RAISE INVALID_PO_LINE_EDIT;
		ELSE
			RAISE INVALID_PO_LINE;
		END IF;
	END IF;

	IF p_attributes.old_block = 'N' AND
	   NOT p_attributes.day_start_time BETWEEN get_po_line(p_attributes.po_line_id).start_date AND get_po_line(p_attributes.po_line_id).expiration_date THEN
		RAISE BB_DATE_OUT_OF_PO_PERIOD;
	END IF;
    EXCEPTION
	WHEN INVALID_PO THEN
		-- invalid PO information
		/** Bug:5559915
		*    Call to this procedure Validate_Attributes is done in loop from
		*    Validate_Timecard() for each Time card entry of same Time card.
		*    PO and PO line of the Time card entries will be same. No need to
		*    log the same PO and PO line error message again for every
		*    Time card entry in the Time Card.
		*    So, before logging the PO and PO line related error message
		*    checking whether error message is already logged or not.
		*/
		IF g_error_raised_flag = 0 THEN--Bug:5559915
			HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'RCV_OTL_INVALID_VALUE'
                                                           , p_message_token => 'INVALID_VALUE&' || 'PO'
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'PO'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
			g_error_raised_flag := 1;
		END IF;
		RETURN;
        WHEN INVALID_PO_EDIT THEN
		-- invalid PO information on edit timecard
		IF g_error_raised_flag = 0 THEN--Bug:5559915
			HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'RCV_OTL_UPDATE_INVALID_PO'
                                                           , p_message_token => NULL
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'PO'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
			g_error_raised_flag := 1;
		END IF;
		RETURN;
        WHEN INVALID_PO_LINE THEN
		-- invalid PO information
		IF g_error_raised_flag = 0 THEN--Bug:5559915
			HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'RCV_OTL_UPDATE_INVALID_PO'
                                                           , p_message_token => NULL
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Line Id'
                                                           , p_application_short_name => 'PO'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
			g_error_raised_flag := 1;
		END IF;
		RETURN;
        WHEN INVALID_PO_LINE_EDIT THEN
		-- invalid PO information on edit timecard
		IF g_error_raised_flag = 0 THEN--Bug:5559915
			HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'RCV_OTL_UPDATE_INVALID_PO'
                                                           , p_message_token => NULL
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Line Id'
                                                           , p_application_short_name => 'PO'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
			g_error_raised_flag := 1;
		END IF;
		RETURN;
        WHEN BB_DATE_OUT_OF_PO_PERIOD THEN
		-- tried to record time outside of PO period
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'RCV_OTL_OUT_OF_PO_PER'
                                                           , p_message_token => 'BB_DATE&' || p_attributes.day_start_time || '&' || 'PARAMS&' || 'PO Start Date=' || pol_start_date || ', PO Expiration Date=' || pol_end_date
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'PO'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
	WHEN OTHERS THEN
		-- exception while trying to validate PO information
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                           , p_message_token => 'ERR&' || 'validating PO information: ' || SQLERRM
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'HXC'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );

		-- cannot proceed without valid PO info
		RETURN;
    END;

    -- validate that the Rate Type is valid for this PO line
    BEGIN
	IF p_attributes.old_block = 'N' AND
           p_attributes.po_price_type <> 'STANDARD' THEN
		IF get_price_differentials(p_attributes.po_line_id, p_attributes.po_price_type).enabled_flag <> 'Y' THEN
			RAISE INVALID_RATE_TYPE;
		END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
		-- the price differential does not even exist in the table
		RAISE INVALID_RATE_TYPE;
        WHEN INVALID_RATE_TYPE THEN
		-- the price differential exists but is not enabled
		RAISE;
        WHEN OTHERS THEN
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                           , p_message_token => 'ERR&' || 'validating PO Price Type information: ' || SQLERRM
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Price Type'
                                                           , p_application_short_name => 'HXC'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
		RETURN;
    END;

    -- validate that work is done within assignment period
    DECLARE
        l_assignment        per_all_assignments_cr;
    BEGIN
        l_assignment := get_assignment( p_attributes.po_line_id
                                      , p_attributes.resource_id
                                      , p_attributes.day_start_time
                                      );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
		-- tried to record time outside of assignment period
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'RCV_OTL_OUT_OF_ASG_PER'
                                                           , p_message_token => 'BB_DATE&' || p_attributes.day_start_time || '&' || 'PARAMS&' || ' '
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'PO'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
        WHEN OTHERS THEN
		-- exception while trying to validate assignment period
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                           , p_message_token => 'ERR&' || 'validating against assignment period: '  || SQLERRM
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => 'PO Header Id'
                                                           , p_application_short_name => 'HXC'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => p_attributes.time_attribute_id
                                                           );
		RETURN;
    END;

    -- maintain the po line amounts table
    BEGIN
        -- The check_mappingvalue_sum function that we use to calculate
        -- total timecarded amount only counts the active block
        -- and we set the parameters so it only counts SUBMITTED blocks
        -- So we only count an old block if it is SUBMITTED and active
        IF p_attributes.old_block = 'N' OR
           ( p_attributes.timecard_approval_status = 'SUBMITTED' AND
             p_attributes.detail_date_to = HR_GENERAL.end_of_time ) THEN
		-- assumption is that this entry exists in the cache
		-- be careful if moving this block of code
		g_po_line_cache(p_attributes.po_line_id).timecard_amount := get_po_line(p_attributes.po_line_id).timecard_amount + p_attributes.po_billable_amount;
		g_po_line_cache(p_attributes.po_line_id).time_attribute_id := NVL(get_po_line(p_attributes.po_line_id).time_attribute_id, p_attributes.time_attribute_id);

		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'Amount for PO Line Id ' || p_attributes.po_line_id || ' updated to ' || get_po_line(p_attributes.po_line_id).timecard_amount
                              );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
		-- exception while updating PO Line Amount
		HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                           , p_message_token => 'ERR&' || 'updating PO Line Amounts Table: '  || SQLERRM
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => NULL
                                                           , p_application_short_name => 'HXC'
                                                           , p_timecard_bb_id => p_attributes.detail_bb_id
                                                           , p_timecard_bb_ovn => p_attributes.detail_bb_ovn
                                                           , p_time_attribute_id => NULL
                                                           );
    END;

    -- everything went through fine so set the status to success
    p_attributes.validation_status := 'SUCCESS';
EXCEPTION
    WHEN WRONG_BB_TYPE THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_WRONG_BB_TYPE'
                                                       , p_message_token => NULL
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => NULL
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => p_attributes.detail_bb_id
                                                       , p_timecard_bb_ovn => p_attributes.detail_bb_ovn
                                                       , p_time_attribute_id => NULL
                                                       );
    WHEN WRONG_BB_UOM THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_WRONG_BB_UOM'
                                                       , p_message_token => NULL
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => NULL
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => p_attributes.detail_bb_id
                                                       , p_timecard_bb_ovn => p_attributes.detail_bb_ovn
                                                       , p_time_attribute_id => NULL
                                                       );
    WHEN NEGATIVE_HOURS THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_NEGATIVE_HOURS'
                                                       , p_message_token => NULL
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => NULL
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => p_attributes.detail_bb_id
                                                       , p_timecard_bb_ovn => p_attributes.detail_bb_ovn
                                                       , p_time_attribute_id => NULL
                                                       );
    WHEN INCOMPLETE_PO_INFO THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_INCOMPLETE_PO'
                                                       , p_message_token => NULL
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => NULL
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => p_attributes.detail_bb_id
                                                       , p_timecard_bb_ovn => p_attributes.detail_bb_ovn
                                                       , p_time_attribute_id => NULL
                                                       );
    WHEN NO_PO_INFO THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_INVALID_VALUE'
                                                       , p_message_token => 'INVALID_VALUE&' || 'PO'
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => 'PO Header Id'
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => NULL
                                                       , p_time_attribute_id => p_attributes.time_attribute_id
                                                       );
    WHEN NO_PO_LINE_INFO THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_INVALID_VALUE'
                                                       , p_message_token => 'INVALID_VALUE&' || 'Line'
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => 'PO Line Id'
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => NULL
                                                       , p_time_attribute_id => p_attributes.time_attribute_id
                                                       );
    WHEN NO_RATE_INFO THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_INVALID_VALUE'
                                                       , p_message_token => 'INVALID_VALUE&' || 'Type'
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => 'PO Price Type'
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => NULL
                                                       , p_time_attribute_id => p_attributes.time_attribute_id
                                                       );
    WHEN NO_AMT_INFO THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_NO_AMT'
                                                       , p_message_token => NULL
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => NULL
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => p_attributes.detail_bb_id
                                                       , p_timecard_bb_ovn => p_attributes.detail_bb_ovn
                                                       , p_time_attribute_id => NULL
                                                       );
    WHEN INVALID_RATE_TYPE THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                       , p_message_name => 'RCV_OTL_INVALID_VALUE'
                                                       , p_message_token => 'INVALID_VALUE&' || 'Type'
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => 'PO Price Type'
                                                       , p_application_short_name => 'PO'
                                                       , p_timecard_bb_id => NULL
                                                       , p_time_attribute_id => p_attributes.time_attribute_id
                                                       );
END Validate_Attributes;

PROCEDURE Validate_Amount_Tolerances
( p_messages            IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table
) IS
    l_return_status                   VARCHAR2(1);
    l_po_line_id                      BINARY_INTEGER;
    l_timecard_amount_sum             PO_LINES_ALL.amount%TYPE;
    l_tolerable_amount                PO_LINES_ALL.amount%TYPE;
    l_qty_rcv_exception_code          PO_LINE_LOCATIONS_ALL.qty_rcv_exception_code%TYPE;

    GET_TIMECARD_AMOUNT_FAILED        EXCEPTION;
    l_api_name         CONSTANT varchar2(30) := 'Validate_Amount_Tolerances';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    l_po_line_id := g_po_line_cache.FIRST;
    WHILE l_po_line_id IS NOT NULL LOOP
        BEGIN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Validating amount tolerance for PO Line Id=' || l_po_line_id || ' (Billable Amount=' || get_po_line(l_po_line_id).timecard_amount || ')'
                              );

            -- query the tolerance exception code first so we can move on if there is no check
            -- do not consider the received amounts because that is already included in the timecard amount below
            l_qty_rcv_exception_code := get_po_line(l_po_line_id).qty_rcv_exception_code;
            l_tolerable_amount := get_po_line(l_po_line_id).tolerable_amount;

            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Fetched Tolerable Amount=' || l_tolerable_amount || ', Receiving Tolerance Exception Code=' || l_qty_rcv_exception_code || ' (PO Line Id=' || l_po_line_id || ')'
                              );

            IF l_qty_rcv_exception_code IN ('WARNING', 'REJECT') THEN
                -- consider the amounts already accounted for in submitted timecards
                l_timecard_amount_sum := HXC_INTEGRATION_LAYER_V1_GRP.get_mappingvalue_sum
                                             ( p_bld_blk_info_type => 'PURCHASING'
                                             , p_field_name1 => 'PO Billable Amount'
                                             , p_field_name2 => 'PO Line Id'
                                             , p_field_value2 => l_po_line_id
                                             , p_status => 'SUBMITTED'
                                             , p_resource_id => FND_GLOBAL.employee_id
                                             );

                -- get_mappingvalue_sum returns null when no timecard matches the conditions
                IF l_timecard_amount_sum IS NULL THEN
                    l_timecard_amount_sum := 0;
                END IF;

                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => l_log_head
                                  , message => 'Fetched Timecard Amount Sum=' || l_timecard_amount_sum || ' (PO Line Id=' || l_po_line_id || ')'
                                  );

                -- finally check if the tolerance will be broken
                IF get_po_line(l_po_line_id).timecard_amount + l_timecard_amount_sum > l_tolerable_amount THEN
                    IF l_qty_rcv_exception_code = 'WARNING' THEN
                        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                                       , p_message_name => 'RCV_OTL_WARN_TOLERANCE'
                                                                       , p_message_token => NULL
                                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_warning
                                                                       , p_message_field => 'PO Header Id'
                                                                       , p_application_short_name => 'PO'
                                                                       , p_timecard_bb_id => NULL
                                                                       , p_time_attribute_id => get_po_line(l_po_line_id).time_attribute_id
                                                                       );
                    ELSIF l_qty_rcv_exception_code = 'REJECT' THEN
                        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                                       , p_message_name => 'RCV_OTL_EXCEED_TOLERANCE'
                                                                       , p_message_token => NULL
                                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                                       , p_message_field => 'PO Header Id'
                                                                       , p_application_short_name => 'PO'
                                                                       , p_timecard_bb_id => NULL
                                                                       , p_time_attribute_id => get_po_line(l_po_line_id).time_attribute_id
                                                                       );
                    END IF;
                END IF;
            END IF;

            l_po_line_id := g_po_line_cache.NEXT(l_po_line_id);
        EXCEPTION
            WHEN GET_TIMECARD_AMOUNT_FAILED THEN
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                                  , module => l_log_head
                                  , message => 'PO_HXC_INTERFACE_PVT.get_timecard_amount returned error'
                                  );

                HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                               , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                               , p_message_token => 'ERR&' || 'calling get_timecard_amount'
                                                               , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                               , p_message_field => 'PO Header Id'
                                                               , p_application_short_name => 'HXC'
                                                               , p_timecard_bb_id => NULL
                                                               , p_time_attribute_id => get_po_line(l_po_line_id).time_attribute_id
                                                               );

                l_po_line_id := g_po_line_cache.NEXT(l_po_line_id);
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                              , module => l_log_head
                              , message => 'Unexpected exception validating amount tolerances: ' || SQLERRM
                              );

            HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => p_messages
                                                           , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
                                                           , p_message_token => 'ERR&' || 'validating amount tolerances: ' || SQLERRM
                                                           , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                           , p_message_field => NULL
                                                           , p_application_short_name => 'HXC'
                                                           , p_timecard_bb_id => NULL
                                                           , p_time_attribute_id => NULL
                                                           , p_message_extent => HXC_USER_TYPE_DEFINITION_GRP.c_blk_children_extent
                                                           );
END Validate_Amount_Tolerances;

PROCEDURE Derive_Common_RTI_Values( p_rti_row    IN OUT NOCOPY RCV_TRANSACTIONS_INTERFACE%ROWTYPE
                                  , p_attributes IN            TimecardAttributesRec
                                  ) IS
 l_api_name         CONSTANT varchar2(30) := 'Derive_Common_RTI_Values';
 l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    -- interface_transaction_id
    SELECT RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
      INTO p_rti_row.interface_transaction_id
      FROM dual;

    -- job_id
    BEGIN
        p_rti_row.job_id := get_po_line(p_attributes.po_line_id).job_id;
    EXCEPTION
        WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                              , module => l_log_head
                              , message => 'Unexpected exception deriving job_id (po_line_id=' || p_attributes.po_line_id || '): ' || SQLERRM
                              );
            RAISE DERIVE_JOB_ID_FAILED;
    END;

    -- WHO columns
    p_rti_row.last_update_date := SYSDATE;
    p_rti_row.last_updated_by := FND_GLOBAL.USER_ID;
    p_rti_row.creation_date := p_rti_row.last_update_date;
    p_rti_row.created_by := p_rti_row.last_updated_by;

    -- hardcoded values
    p_rti_row.expected_receipt_date := SYSDATE;
    p_rti_row.processing_mode_code := 'BATCH';
    p_rti_row.processing_status_code := 'PENDING';
    p_rti_row.transaction_status_code := 'PENDING';
    p_rti_row.receipt_source_code := 'VENDOR';
    p_rti_row.source_document_code := 'PO';
    p_rti_row.validation_flag := 'Y';

    -- atomic processing
    p_rti_row.lpn_group_id := p_attributes.lpn_group_id;

    -- PO information
    p_rti_row.po_header_id := p_attributes.po_header_id;
    p_rti_row.po_line_id := p_attributes.po_line_id;
    p_rti_row.po_line_location_id := p_attributes.po_line_location_id;
    p_rti_row.po_distribution_id := p_attributes.po_distribution_id;

    -- timecard info
    p_rti_row.timecard_id := p_attributes.timecard_bb_id;
    p_rti_row.timecard_ovn := p_attributes.timecard_bb_ovn;

    -- projects info
    p_rti_row.project_id := p_attributes.project_id;
    p_rti_row.task_id := p_attributes.task_id;

    -- employee_id
    p_rti_row.employee_id := p_attributes.resource_id;
END Derive_Common_RTI_Values;

PROCEDURE Derive_Receive_Values
( p_rhi_rows         IN OUT NOCOPY rhi_table
, p_rti_rows         IN OUT NOCOPY rti_table
, p_attributes       IN OUT NOCOPY TimecardAttributesRec
) IS
    l_rhi_row        RCV_HEADERS_INTERFACE%ROWTYPE;
    l_rti_row        RCV_TRANSACTIONS_INTERFACE%ROWTYPE;
    l_rhi_row_idx    BINARY_INTEGER;
    l_rti_row_idx    BINARY_INTEGER;
    l_api_name         CONSTANT varchar2(30) := 'Derive_Receive_Values';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Derive_Receive_Values'
                  );

    -- check for existing rhi row
    l_rhi_row_idx := get_rhi_idx( p_attributes, p_rhi_rows, p_rti_rows );
    IF l_rhi_row_idx IS NOT NULL THEN
        -- found a match
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Using existing RHI row'
                          );

        l_rhi_row := p_rhi_rows(l_rhi_row_idx);
    ELSE -- found existing rhi row
        l_rhi_row_idx := p_rhi_rows.COUNT + 1;

        -- header_id
        SELECT RCV_HEADERS_INTERFACE_S.NEXTVAL
          INTO l_rhi_row.header_interface_id
          FROM dual;

        -- group_id
        l_rhi_row.group_id := get_group_id( p_rti_rows );

        -- employee_id
        l_rhi_row.employee_id := p_attributes.resource_id;

        -- WHO columns
        l_rhi_row.last_update_date := SYSDATE;
        l_rhi_row.last_updated_by := FND_GLOBAL.USER_ID;
        l_rhi_row.creation_date := l_rhi_row.last_update_date;
        l_rhi_row.created_by := l_rhi_row.last_updated_by;

        -- hardcoded values
        l_rhi_row.expected_receipt_date := SYSDATE;
        l_rhi_row.processing_status_code := 'PENDING';
        l_rhi_row.receipt_source_code := 'VENDOR';
        l_rhi_row.transaction_type := 'NEW';
        l_rhi_row.auto_transact_code := 'DELIVER';
        l_rhi_row.validation_flag := 'Y';

        -- PO derived values
        l_rhi_row.vendor_id := get_po_header(p_attributes.po_header_id).vendor_id;
        l_rhi_row.vendor_site_id := get_po_header(p_attributes.po_header_id).vendor_site_id;
        l_rhi_row.ship_to_organization_id := get_po_line(p_attributes.po_line_id).ship_to_organization_id;
        l_rhi_row.location_id := get_po_line(p_attributes.po_line_id).ship_to_location_id;
    END IF; -- found existing rhi row

    -- check for existing rti row
    l_rti_row_idx := get_rti_idx( p_attributes, p_rti_rows );
    IF l_rti_row_idx IS NOT NULL THEN
        -- found a match
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Using existing RTI row'
                          );

        -- make a local working copy
        l_rti_row := p_rti_rows(l_rti_row_idx);

        -- txn date = max(start_time) only if user did not specify any override value
        IF p_attributes.po_receipt_date IS NULL AND
           trunc(p_attributes.detail_start_time) > l_rti_row.transaction_date THEN
		l_rti_row.transaction_date := trunc(p_attributes.detail_start_time);

		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Updated transaction_date=' || l_rti_row.transaction_date
                              );
        END IF;

        -- update the amount
        l_rti_row.amount := l_rti_row.amount + p_attributes.po_billable_amount;

        -- use processing_status_code to encode whether to insert to db
	-- BUG6343206
 	-- Reverting the changes done for BUG3550333 [115.69]
 	-- We are allowing the zero amount receipts to be created as of now.
 	-- Whnever a new Reciept is created then let it go to RTP if the amount come to 0.
 	-- Also not updating the RTI to PENDING , as the RTI we found will have the status
 	-- code as 'PENDING' as we do that in ELSE PART in Derive_Common_RTI_Values.
	/*
	IF l_rti_row.amount = 0 THEN
            l_rhi_row.processing_status_code := 'SUCCESS';
            l_rti_row.processing_status_code := 'SUCCESS';
        ELSE
            l_rhi_row.processing_status_code := 'PENDING';
            l_rti_row.processing_status_code := 'PENDING';
        END IF;
	*/

        -- associate the rti rows to the building block
        p_attributes.receive_rti_id := l_rti_row.interface_transaction_id;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Set receive_rti_id=' || p_attributes.receive_rti_id
                          );
    ELSE -- found existing rti row
        l_rti_row_idx := p_rti_rows.COUNT + 1;

        -- group_id
        l_rti_row.group_id := l_rhi_row.group_id;

        -- header_interface_id
        l_rti_row.header_interface_id := l_rhi_row.header_interface_id;

        -- common derivations
        Derive_Common_RTI_Values( l_rti_row
                                , p_attributes
                                );

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Set po_distribution_id=' || l_rti_row.po_distribution_id
                          );

        -- transaction type
        l_rti_row.transaction_type := 'RECEIVE';
        l_rti_row.auto_transact_code := 'DELIVER';

        -- initialize receipt date
        IF p_attributes.po_receipt_date IS NOT NULL THEN
            l_rti_row.transaction_date := p_attributes.po_receipt_date;
        ELSE
            l_rti_row.transaction_date := trunc(p_attributes.detail_start_time);
        END IF;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Initialized transaction_date=' || l_rti_row.transaction_date
                          );

        -- amount received
        l_rti_row.amount := p_attributes.po_billable_amount;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Set amount=' || l_rti_row.amount || ' from ' || p_attributes.po_billable_amount
                          );

        -- use processing_status_code to encode whether to insert to db
       -- BUG6343206
       -- Reverting the changes done for BUG3550333 [115.69]
       -- We are allowing the zero amount receipts to be created as of now.
       -- Whnever a new Reciept is created then let it go at the First time
       -- Even if the amount come to 0.
 	/*
	IF l_rti_row.amount = 0 THEN
            l_rhi_row.processing_status_code := 'SUCCESS';
            l_rti_row.processing_status_code := 'SUCCESS';
        END IF;
	*/

        -- associate the rti rows to the building block
        p_attributes.receive_rti_id := l_rti_row.interface_transaction_id;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Set receive_rti_id=' || p_attributes.receive_rti_id
                          );
    END IF; -- found existing rti row

    -- copy data back to the main tables
    p_rhi_rows(l_rhi_row_idx) := l_rhi_row;
    p_rti_rows(l_rti_row_idx) := l_rti_row;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Derive_Receive_Values'
                  );
END Derive_Receive_Values;

PROCEDURE Derive_Correction_Values
( p_rti_rows         IN OUT NOCOPY rti_table
, p_attributes       IN OUT NOCOPY TimecardAttributesRec
, p_old_attributes   IN OUT NOCOPY TimecardAttributesRec
) IS
    l_correction_amount        po_lines_all.amount%TYPE;
    l_old_correction_amount    po_lines_all.amount%TYPE;
    l_swap                     rcv_transactions_interface.interface_transaction_id%TYPE; /*Bug 6031665*/
    -- we need one correction for each parent transaction
    l_rcv_rti_row              RCV_TRANSACTIONS_INTERFACE%ROWTYPE;
    l_del_rti_row              RCV_TRANSACTIONS_INTERFACE%ROWTYPE;
    l_rti_row_idx              BINARY_INTEGER;
    l_api_name         CONSTANT varchar2(30) := 'Derive_Correction_Values';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Derive_Correction_Values'
                  );

    -- determine the correction amount
    l_correction_amount := p_attributes.po_billable_amount - p_old_attributes.po_billable_amount;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Derived correction amount=' || l_correction_amount
                      );

    -- check if we already have this correction so we can just add the amount to it
    l_rti_row_idx := get_rti_idx( p_attributes, p_rti_rows );
    IF l_rti_row_idx IS NOT NULL THEN
        -- found a match
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Using existing RTI rows'
                          );

        -- save the existing correction amount for calculation and identifying txn types
        l_old_correction_amount := p_rti_rows(l_rti_row_idx).amount;
        l_correction_amount := l_correction_amount + l_old_correction_amount;

        -- since this is a correction, both this row and the next are relevant
        p_rti_rows(l_rti_row_idx).amount := l_correction_amount;
        p_rti_rows(l_rti_row_idx+1).amount := l_correction_amount;

        -- bug 6031665:
 	/*  Bug 6867607
 	  sign(l_correction_amount)A--sign(l_old_correction_amount)B--swap--A+B<1 and A<>B

 	   --------------------------  -----------------------------  ----  -------------
 	   0                             0                               N    False
 	   0                             +1                              N    False
 	   0                             -1                              Y    True
 	   +1                            0                               N    False
 	   +1                            +1                              N    False
 	   +1                            -1                              Y    True
 	   -1                            0                               Y    True
 	   -1                            +1                              Y    True
 	   -1                            -1                              N    False
 	   */

 	if ((sign(l_correction_amount) <> sign(l_old_correction_amount))
	   AND (sign(l_correction_amount)+sign(l_old_correction_amount)<1)) then
		-- This means that one is a positive correction and the other is a negative correction.
		-- If this happens we need to swap the order of the correction records, because for
		-- negative correction the correction record for deliver xaction should go first and
		-- for positive correction the correction record for receipt xaction should go first.
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                           , module => l_log_head
 	                           , message => 'sign(l_correction_amount)=' ||sign(l_correction_amount) || ',sign(l_old_correction_amount) ' || sign(l_old_correction_amount)||',hence swap'
 	                           );
	         l_swap:= p_rti_rows(l_rti_row_idx).interface_transaction_id;
		 p_rti_rows(l_rti_row_idx).interface_transaction_id := p_rti_rows(l_rti_row_idx+1).interface_transaction_id;
		 p_rti_rows(l_rti_row_idx+1).interface_transaction_id := l_swap;
 	end if;
        -- use processing_status_code to encode whether to insert to db
	-- BUG6343206
 	-- Reverting the changes done for BUG3550333 [115.69, 115.78]
 	-- We are allowing the zero amount receipts to be created as of now.
 	-- Whenever a Correcting amount come as Zero we need it to go the  RTP .
 	-- Updating the RTI to PENDING , as the RTI we found might have a differnt status.
 	/*
	IF l_correction_amount = 0 THEN
            p_rti_rows(l_rti_row_idx).processing_status_code := 'SUCCESS';
            p_rti_rows(l_rti_row_idx+1).processing_status_code := 'SUCCESS';
        ELSE
            p_rti_rows(l_rti_row_idx).processing_status_code := 'PENDING';
            p_rti_rows(l_rti_row_idx+1).processing_status_code := 'PENDING';
        END IF;
	*/

        -- associate the rti rows to the building block
        -- bug 6031665 : instead of the old_correction amount check the correction amount.
 	-- IF l_old_correction_amount > 0 THEN
 	/*  Bug 6867607*/

	IF l_correction_amount >= 0 THEN
		IF p_rti_rows(l_rti_row_idx).interface_transaction_id < p_rti_rows(l_rti_row_idx+1).interface_transaction_id then
			p_attributes.receive_rti_id := p_rti_rows(l_rti_row_idx).interface_transaction_id;
			p_attributes.deliver_rti_id := p_rti_rows(l_rti_row_idx+1).interface_transaction_id;
		ELSE
			p_attributes.receive_rti_id := p_rti_rows(l_rti_row_idx+1).interface_transaction_id;
			p_attributes.deliver_rti_id := p_rti_rows(l_rti_row_idx).interface_transaction_id;
		END IF;
        ELSE
	        IF p_rti_rows(l_rti_row_idx).interface_transaction_id > p_rti_rows(l_rti_row_idx+1).interface_transaction_id then
 	               p_attributes.receive_rti_id := p_rti_rows(l_rti_row_idx).interface_transaction_id;
 	               p_attributes.deliver_rti_id := p_rti_rows(l_rti_row_idx+1).interface_transaction_id;
 	        ELSE
			p_attributes.receive_rti_id := p_rti_rows(l_rti_row_idx+1).interface_transaction_id;
 	                p_attributes.deliver_rti_id := p_rti_rows(l_rti_row_idx).interface_transaction_id;
		END IF;
        END IF;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Set receive_rti_id=' || p_attributes.receive_rti_id || ', deliver_rti_id=' || p_attributes.deliver_rti_id
                          );
    ELSE -- found existing rti rows
        -- did not find any match, let's create a new transaction
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Creating new RTI rows'
                          );

        -- group_id
        l_rcv_rti_row.group_id := get_group_id( p_rti_rows );

        -- common derivations
        Derive_Common_RTI_Values( l_rcv_rti_row
                                , p_attributes
                                );

        -- transaction type
        l_rcv_rti_row.transaction_type := 'CORRECT';

        -- initialize receipt date
        IF p_attributes.po_receipt_date IS NOT NULL THEN
            l_rcv_rti_row.transaction_date := p_attributes.po_receipt_date;
        ELSE
            l_rcv_rti_row.transaction_date := trunc(SYSDATE);
        END IF;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Initialized transaction_date=' || l_rcv_rti_row.transaction_date
                          );

        -- amount to be corrected
        l_rcv_rti_row.amount := l_correction_amount;

        -- use processing_status_code to encode whether to insert to db
	-- BUG6343206
 	-- Reverting the changes done for BUG3550333 [115.69]
 	-- We are allowing the zero amount receipts to be created as of now.
 	-- Whnever a Correcting amount come as Zero we need it to go the  RTP .
 	-- Updating the RTI to PENDING , as the RTI we found might have a differnt status.
 	 /*
	IF l_correction_amount = 0 THEN
            l_rcv_rti_row.processing_status_code := 'SUCCESS';
        END IF;
        */
        -- duplicate the rti row to get the other one
        l_del_rti_row := l_rcv_rti_row;

        -- parent transaction id
        l_rcv_rti_row.parent_transaction_id := p_attributes.parent_receive_txn_id;
        l_del_rti_row.parent_transaction_id := p_attributes.parent_deliver_txn_id;

        IF l_correction_amount < 0 THEN
            -- for negative corrections, we correct the deliver first

            -- get the next rti id for the receive transaction
            SELECT RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
              INTO l_rcv_rti_row.interface_transaction_id
              FROM dual;

            -- insert into rti table
            p_rti_rows(p_rti_rows.COUNT + 1) := l_del_rti_row;
            p_rti_rows(p_rti_rows.COUNT + 1) := l_rcv_rti_row;
        ELSE
            -- for positive corrections, we correct the receive first

            -- get the next rti id for the deliver transaction
            SELECT RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
              INTO l_del_rti_row.interface_transaction_id
              FROM dual;

            -- insert into rti table
            p_rti_rows(p_rti_rows.COUNT + 1) := l_rcv_rti_row;
            p_rti_rows(p_rti_rows.COUNT + 1) := l_del_rti_row;
        END IF;

        -- associate the rti rows to the building block
        p_attributes.receive_rti_id := l_rcv_rti_row.interface_transaction_id;
        p_attributes.deliver_rti_id := l_del_rti_row.interface_transaction_id;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Set receive_rti_id=' || p_attributes.receive_rti_id || ', deliver_rti_id=' || p_attributes.deliver_rti_id
                          );
    END IF; -- found existing rti rows

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Derive_Correction_Values'
                  );
END Derive_Correction_Values;

--BUG6343206
-- Added a new parameter for receipt date when calling delete on blocks
-- such that we can have the request Transaction date or the system date
-- insteed of using transaction date from OLD records.
PROCEDURE Derive_Delete_Values
( p_rti_rows         IN OUT NOCOPY rti_table
, p_attributes       IN OUT NOCOPY TimecardAttributesRec
, receipt_date       IN DATE
) IS
    l_new_attributes      TimecardAttributesRec;
    l_api_name         CONSTANT varchar2(30) := 'Derive_Delete_Values';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Derive_Delete_Values'
                  );

    -- delete is the same as correction except the new amount is 0
    l_new_attributes := p_attributes;
    l_new_attributes.detail_measure := 0;
    l_new_attributes.po_billable_amount := 0;
    -- BUG6343206
    -- We are  stamping the request Transaction date or the system date
    -- insteed of using transaction date from OLD records. Which has
    -- been passed.

    l_new_attributes.po_receipt_date := receipt_date;

    Derive_Correction_Values( p_rti_rows
                            , l_new_attributes
                            , p_attributes
                            );

    -- derive_correction_values only sets the rti-bb relationship in the new attributes
    p_attributes.receive_rti_id := l_new_attributes.receive_rti_id;
    p_attributes.deliver_rti_id := l_new_attributes.deliver_rti_id;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Derive_Delete_Values'
                  );
END Derive_Delete_Values;

-- Procedure to derive the ROI values for a new detail block
PROCEDURE Derive_New_Block_Values
( p_rhi_rows         IN OUT NOCOPY rhi_table
, p_rti_rows         IN OUT NOCOPY rti_table
, p_attributes       IN OUT NOCOPY TimecardAttributesRec
) IS
l_api_name         CONSTANT varchar2(30) := 'Derive_New_Block_Values';
l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Derive_New_Block_Values'
                  );

    -- if we have received against this po line before
    -- we will correct that receipt
    IF p_attributes.parent_receive_txn_id <> 0 THEN
        DECLARE
            l_old_attributes TimecardAttributesRec := p_attributes;
        BEGIN
            -- new block to be added to old receipt
            -- we don't have the old attributes so we make them up
            l_old_attributes.detail_measure := 0;
            l_old_attributes.po_billable_amount := 0;

            Derive_Correction_Values( p_rti_rows
                                    , p_attributes
                                    , l_old_attributes
                                    );

            -- save the transaction type
            p_attributes.transaction_type := 'CORRECT';
        END;
    ELSE -- received before
        Derive_Receive_Values( p_rhi_rows
                             , p_rti_rows
                             , p_attributes
                             );

        -- save the transaction type
        p_attributes.transaction_type := 'RECEIVE';
    END IF;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Derive_New_Block_Values'
                  );
END Derive_New_Block_Values;


PROCEDURE Derive_Interface_Values
( p_attributes       IN OUT NOCOPY TimecardAttributesRec
, p_old_attributes   IN OUT NOCOPY TimecardAttributesRec
, p_rhi_rows         IN OUT NOCOPY rhi_table
, p_rti_rows         IN OUT NOCOPY rti_table
) IS
l_api_name         CONSTANT varchar2(30) := 'Derive_Interface_Values';
l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
l_progress VARCHAR2(3) := '000';

temp_attributes TimecardAttributesRec; --17921123
temp_rti_idx Number; --17921123
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Derive_Interface_Values'
                  );

    -- use lpn_group_id to make sure that the receiving transactions are atomic for this block
    BEGIN
        SELECT rcv_interface_groups_s.NEXTVAL
          INTO p_attributes.lpn_group_id
          FROM dual;

        p_old_attributes.lpn_group_id := p_attributes.lpn_group_id;
    EXCEPTION
        WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                          , module => l_log_head
                          , message => 'Unexpected exception setting lpn_group_id: ' || SQLERRM
                          );
            RAISE DERIVE_ROI_VALUES_FAILED;
    END;
    IF g_debug_stmt THEN
 	             PO_DEBUG.debug_stmt(l_log_head,l_progress,'Printing p_attributes');
 	             RCV_HXT_GRP.debug_TimecardAttributesRec(l_log_head, p_attributes,'NEW');
 	             PO_DEBUG.debug_stmt(l_log_head,l_progress,'Printing p_old_attributes');
 	             RCV_HXT_GRP.debug_TimecardAttributesRec(l_log_head, p_old_attributes,'OLD');
    END IF;
    -- find the parent transactions, assume the old block has the same parents
    BEGIN
        /* Bug 14609848 */
        p_attributes.parent_receive_txn_id := get_rcv_transaction(
	                                            p_attributes.timecard_bb_id,
						    p_attributes.po_line_id,
						    p_attributes.po_distribution_id,
						    p_attributes.project_id,
						    p_attributes.task_id).receive_transaction_id;

	p_attributes.parent_deliver_txn_id := get_rcv_transaction(
	                                            p_attributes.timecard_bb_id,
						    p_attributes.po_line_id,
						    p_attributes.po_distribution_id,
						    p_attributes.project_id,
						    p_attributes.task_id).deliver_transaction_id;

        p_old_attributes.parent_receive_txn_id := p_attributes.parent_receive_txn_id;
        p_old_attributes.parent_deliver_txn_id := p_attributes.parent_deliver_txn_id;
    EXCEPTION
        WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                          , module => l_log_head
                          , message => 'Unexpected exception querying for parent transactions in Derive_Interface_Values (po_line_id=' || p_attributes.po_line_id || ', timecard_bb_id=' || p_attributes.timecard_bb_id || '): ' || SQLERRM
                          );
            RAISE DERIVE_ROI_VALUES_FAILED;
    END;

    -- check if the block was updated
    IF p_attributes.detail_changed = 'Y' THEN
        -- BUG# 6798505/6631524
        -- User can Change Project Information on the time card along with the Line Information
        -- Which will lead to change in Distribution Id. If the Distribution ID changes then
        -- follow the same Step as we do in Line Change.
        IF ((p_attributes.po_line_id <> p_old_attributes.po_line_id )
           OR (p_attributes.po_distribution_id is not null AND
	       p_attributes.po_distribution_id <> p_old_attributes.po_distribution_id OR
	       p_attributes.project_id <> p_old_attributes.project_id OR /* Bug 14609848 */
               p_attributes.task_id <> p_old_attributes.task_id /* Bug 14609848 */
	       )) THEN

	    -- if the user changed po information we need to correct
            -- the old receipt to zero and either create a new receipt
            -- or correct an existing one
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                                  , module => l_log_head
                                  , message => 'Correction : Either PO Line OR Project/Task information changed '
                                  );
            -- in this case the old block does not have the same parents
            -- so we need to derive it
            BEGIN
                -- These calls will flush the records cached by the new timecard, but we
                -- do not expect the user to change the PO on a timecard very often
                -- BUG# 6798505/6631524
                -- User can Change Project Information on the time card along with the Line Information
                -- Which will lead to change in Distribution Id. We need to look for Old Attribute
                -- Distribution Id.

		/* Bug 14609848 */
		p_old_attributes.parent_receive_txn_id := get_rcv_transaction(
		                                                   p_old_attributes.timecard_bb_id,
								   p_old_attributes.po_line_id,
								   p_old_attributes.po_distribution_id,
								   p_old_attributes.project_id,
								   p_old_attributes.task_id).receive_transaction_id;

		p_old_attributes.parent_deliver_txn_id := get_rcv_transaction(
		                                                   p_old_attributes.timecard_bb_id,
								   p_old_attributes.po_line_id,
								   p_old_attributes.po_distribution_id,
								   p_old_attributes.project_id,
								   p_old_attributes.task_id).deliver_transaction_id;

		EXCEPTION
                WHEN OTHERS THEN
                    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                                  , module => l_log_head
                                  , message => 'Unexpected exception querying for parent transactions for the old block in Derive_Interface_Values ('
                                      || 'po_line_id=' || p_old_attributes.po_line_id
                                      || ', timecard_bb_id=' || p_old_attributes.timecard_bb_id
                                      || '): ' || SQLERRM
                                  );
                RAISE DERIVE_ROI_VALUES_FAILED;
            END;

            -- BUG6343206
 	    -- Added a new parameter for receipt date when calling delete on blocks
 	    -- such that we can have the request Transaction date or the system date
 	    -- insteed of using transaction date from OLD records.
	    Derive_Delete_Values( p_rti_rows
                                , p_old_attributes
				, p_attributes.po_receipt_date
                                );

            -- capture the rti ids for the delete
            p_attributes.delete_receive_rti_id := p_old_attributes.receive_rti_id;
            p_attributes.delete_deliver_rti_id := p_old_attributes.deliver_rti_id;

            -- either create a new receipt or correct an existing one
            -- against the new po information
            Derive_New_Block_Values( p_rhi_rows
                                   , p_rti_rows
                                   , p_attributes
                                   );

            -- save the transaction type
            p_attributes.transaction_type := 'DELETE ' || p_attributes.transaction_type;

        ELSE -- po line changed
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                       , module => l_log_head
                       , message => 'Correction : Either Rate type or the hours worked changed '
                       );
	    -- if the user only changed the rate type or the hours worked
            -- then we just need to correct the receipt
            IF p_attributes.detail_deleted = 'Y' THEN
	        -- BUG6343206
 	        -- Added a new parameter for receipt date when calling delete on blocks
 	        -- such that we can have the request Transaction date or the system date
 	        -- insteed of using transaction date from OLD records.
                Derive_Delete_Values( p_rti_rows
                                    , p_old_attributes
                                    , p_attributes.po_receipt_date
				    );

                -- capture the rti ids for the delete
                p_attributes.delete_receive_rti_id := p_old_attributes.receive_rti_id;
                p_attributes.delete_deliver_rti_id := p_old_attributes.deliver_rti_id;

                -- save the transaction type
                p_attributes.transaction_type := 'DELETE';
            ELSE

		--Bug 17921123 Start
		--If correction can really be posted, post a 'CORRECT'.
		--Otherwise post a 'RECEIVE' with billed value that of 'CORRECT'.
		temp_rti_idx := get_rti_idx(p_attributes => p_attributes, p_rti_rows => p_rti_rows);
		If ((temp_rti_idx is not null and p_rti_rows(temp_rti_idx).parent_transaction_id is not null)
			or
		     (p_attributes.parent_receive_txn_id is not null)
		 ) THEN
                Derive_Correction_Values( p_rti_rows
                                        , p_attributes
                                        , p_old_attributes
                                        );

                -- save the transaction type
                p_attributes.transaction_type := 'CORRECT';
		 ELSE

			temp_attributes := p_attributes;
			temp_attributes.po_billable_amount := p_attributes.po_billable_amount - p_old_attributes.po_billable_amount;
			Derive_Receive_Values( p_rhi_rows
				              , p_rti_rows
					      , temp_attributes
					      );
			p_attributes.receive_rti_id := temp_attributes.receive_rti_id;
			p_attributes.transaction_type := 'RECEIVE';

                END IF;
            END IF;

        END IF; -- po line changed
    ELSE -- detail_changed
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                    , module => l_log_head
                    , message => 'Receive  : Block is newly created.'
                    );
	Derive_New_Block_Values( p_rhi_rows
                               , p_rti_rows
                               , p_attributes
                               );
    END IF; -- detail_changed

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Done deriving ROI values. Calling iSP to store timecard detail information...'
                  );

    -- iSP Integration - store timecard information in iSP table
    DECLARE
        l_return_status      VARCHAR2(240);
        l_msg_data           VARCHAR2(2000);
        l_action             VARCHAR2(240);

        l_rhi_idx            BINARY_INTEGER;
        l_rti_idx            BINARY_INTEGER;
        l_rhi_row            rcv_headers_interface%ROWTYPE;
        l_rti_row            rcv_transactions_interface%ROWTYPE;
    BEGIN
        /*Bug 17930358 : Need to handle when detail deleted case as well */
	IF p_attributes.detail_changed = 'Y' THEN
	  IF p_attributes.detail_deleted = 'Y' THEN
	    l_action := 'DELETE';
	  ELSE
	    l_action := 'UPDATE';
	  END IF;
	ELSE
	  l_action := 'INSERT';
	END IF;
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Finding ROI rows: p_rhi_rows.COUNT=' || p_rhi_rows.COUNT || ' p_rti_rows.COUNT=' || p_rti_rows.COUNT || ' p_attributes.po_distribution_id=' || p_attributes.po_distribution_id
                          );

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Finding ROI rows: p_rhi_rows.COUNT=' || p_rhi_rows.COUNT || ' p_rti_rows.COUNT=' || p_rti_rows.COUNT || ' p_attributes.po_distribution_id=' || p_attributes.po_distribution_id
                          );
        /*Bug 17930358 : Need to handle when detail deleted case as well */
        IF(l_action = 'DELETE') THEN
	  l_rhi_idx := get_rhi_idx(p_old_attributes, p_rhi_rows, p_rti_rows);
	ELSE
        l_rhi_idx := get_rhi_idx(p_attributes, p_rhi_rows, p_rti_rows);
	END IF;

        IF l_rhi_idx IS NOT NULL THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'rhi_idx=' || l_rhi_idx
                              );
            l_rhi_row := p_rhi_rows(l_rhi_idx);
        END IF;

	/*Bug 17930358 : Need to handle when detail deleted case as well */
        IF(l_action = 'DELETE') THEN
	  l_rti_idx := get_rti_idx(p_old_attributes, p_rti_rows);
	ELSE
        l_rti_idx := get_rti_idx(p_attributes, p_rti_rows);
	END IF;

       --Bug 17921123
	IF l_rti_idx IS NOT NULL THEN
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'rti_idx=' || l_rti_idx
                          );
        l_rti_row := p_rti_rows(l_rti_idx);

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Setting p_action for store_timecard_details'
                          );

        PO_STORE_TIMECARD_PKG_GRP.store_timecard_details (
              p_api_version => 1.0
            , x_return_status => l_return_status
            , x_msg_data => l_msg_data
            , p_vendor_id => l_rhi_row.vendor_id
            , p_vendor_site_id => l_rhi_row.vendor_site_id
            , p_vendor_contact_id => NULL
            , p_po_num => p_attributes.po_number
            , p_po_line_number => p_attributes.po_line
            , p_org_id => p_attributes.org_id
            , p_project_id => p_attributes.project_id
            , p_task_id => p_attributes.task_id
            , p_tc_id => p_attributes.timecard_bb_id
            , p_tc_day_id => p_attributes.day_bb_id
            , p_tc_detail_id => p_attributes.detail_bb_id
            , p_tc_uom => p_attributes.detail_uom
            , p_tc_start_date => p_attributes.timecard_start_time
            , p_tc_end_date => p_attributes.timecard_stop_time
            , p_tc_entry_date => p_attributes.detail_start_time
            , p_tc_time_received => p_attributes.detail_measure
            , p_tc_approval_status => p_attributes.timecard_approval_status
            , p_tc_approval_date => p_attributes.timecard_approval_date
            , p_tc_submission_date => p_attributes.timecard_submission_date
            , p_contingent_worker_id => p_attributes.resource_id
            , p_tc_comment_text => p_attributes.timecard_comment
            , p_line_rate_type => p_attributes.po_price_type
            , p_line_rate => 0
            , p_action => l_action
            , p_interface_transaction_id => l_rti_row.interface_transaction_id
        );

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'After store_timecard_details'
                          );

        IF l_return_status <> FND_API.g_ret_sts_success THEN
            RAISE ISP_STORE_TIMECARD_FAILED;
        END IF;
       END IF;
       --Bug 17921123

    EXCEPTION
        WHEN ISP_STORE_TIMECARD_FAILED THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'iSP store_timecard_details failed: x_return_status=' || l_return_status || ', x_msg_data=' || l_msg_data
                              );
            RAISE DERIVE_ROI_VALUES_FAILED;
        WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'Exception trying to call iSP store_timecard_details: x_return_status=' || l_return_status || ', x_msg_data=' || l_msg_data || ', sqlerrm=' || sqlerrm
                              );
            RAISE DERIVE_ROI_VALUES_FAILED;
    END;   -- end of isp integration

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Derive_Interface_Values'
                  );
EXCEPTION
    WHEN DERIVE_DISTRIBUTION_ID_FAILED THEN
        RAISE DERIVE_ROI_VALUES_FAILED;
    WHEN DERIVE_JOB_ID_FAILED THEN
        RAISE DERIVE_ROI_VALUES_FAILED;
END Derive_Interface_Values;

PROCEDURE Add_Where_Clause
( p_where_clause   IN OUT NOCOPY VARCHAR2
, p_new_condition  IN            VARCHAR2
) IS
BEGIN
    IF p_where_clause IS NOT NULL THEN
        p_where_clause := p_where_clause || ' AND ' || p_new_condition;
    ELSE
        p_where_clause := p_new_condition;
    END IF;
END Add_Where_Clause;

 -- bug6395858
 -- we are using p_rhi_rows and p_rti_row for tracking any errors
 -- which might occur while populating the data in Interface Table.

PROCEDURE Insert_Interface_Values
( p_rhi_rows       IN OUT NOCOPY            rhi_table
, p_rti_rows       IN OUT NOCOPY            rti_table
	-- Bug6343206
	-- Reverting the changes done for BUG3550333 [115.69]
	-- We are allowing the zero amount receipts to be created as of now.
	-- There will be no entry going in as SUCCESS. so we need no track
	-- those block by l_rti_status.
	-- , p_rti_status     IN OUT NOCOPY rti_status_table
) IS

    --added for bugfix 5609476
    CURSOR c_get_currency_code(v_po_header_id NUMBER)  IS
    SELECT currency_code
    FROM   po_headers
    where  po_header_id = v_po_header_id;

    -- for 8i compatibility, we can only do BULK INSERT using an array for each column
    TYPE header_interface_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.header_interface_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE group_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.group_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE processing_status_code_tbl IS TABLE OF RCV_HEADERS_INTERFACE.processing_status_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE receipt_source_code_tbl IS TABLE OF RCV_HEADERS_INTERFACE.receipt_source_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE transaction_type_tbl IS TABLE OF RCV_HEADERS_INTERFACE.transaction_type%TYPE INDEX BY BINARY_INTEGER;
    TYPE auto_transact_code_tbl IS TABLE OF RCV_HEADERS_INTERFACE.auto_transact_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE last_update_date_tbl IS TABLE OF RCV_HEADERS_INTERFACE.last_update_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE last_updated_by_tbl IS TABLE OF RCV_HEADERS_INTERFACE.last_updated_by%TYPE INDEX BY BINARY_INTEGER;
    TYPE creation_date_tbl IS TABLE OF RCV_HEADERS_INTERFACE.creation_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE created_by_tbl IS TABLE OF RCV_HEADERS_INTERFACE.created_by%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.vendor_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_site_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.vendor_site_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE ship_to_organization_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.ship_to_organization_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE location_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.location_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE expected_receipt_date_tbl IS TABLE OF RCV_HEADERS_INTERFACE.expected_receipt_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE employee_id_tbl IS TABLE OF RCV_HEADERS_INTERFACE.employee_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE validation_flag_tbl IS TABLE OF RCV_HEADERS_INTERFACE.validation_flag%TYPE INDEX BY BINARY_INTEGER;

    TYPE interface_transaction_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE lpn_group_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.lpn_group_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE transaction_date_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.transaction_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE processing_mode_code_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.processing_mode_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE transaction_status_code_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.transaction_status_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE source_document_code_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.source_document_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE parent_transaction_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.parent_transaction_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE po_header_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.po_header_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE po_line_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.po_line_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE po_line_location_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.po_line_location_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE po_distribution_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.po_distribution_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE project_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.project_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE task_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.task_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE amount_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.amount%TYPE INDEX BY BINARY_INTEGER;
    TYPE job_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.job_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE timecard_id_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.timecard_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE timecard_ovn_tbl IS TABLE OF RCV_TRANSACTIONS_INTERFACE.timecard_ovn%TYPE INDEX BY BINARY_INTEGER;
    --Bug6395858
    -- A temp table l_rhi_stat is taken to mark those timecards for
    -- which RHI got in error while processing and corrosponding RTI
    -- has to maked error.
    TYPE l_index_table IS TABLE OF VARCHAR2(10) INDEX BY binary_integer;
    l_rhi_stat                          l_index_table;
    rhi_header_interface_id             header_interface_id_tbl;
    rhi_group_id                        group_id_tbl;
    rhi_processing_status_code          processing_status_code_tbl;
    rhi_receipt_source_code             receipt_source_code_tbl;
    rhi_transaction_type                transaction_type_tbl;
    rhi_auto_transact_code              auto_transact_code_tbl;
    rhi_last_update_date                last_update_date_tbl;
    rhi_last_updated_by                 last_updated_by_tbl;
    rhi_creation_date                   creation_date_tbl;
    rhi_created_by                      created_by_tbl;
    rhi_vendor_id                       vendor_id_tbl;
    rhi_vendor_site_id                  vendor_site_id_tbl;
    rhi_ship_to_organization_id         ship_to_organization_id_tbl;
    rhi_location_id                     location_id_tbl;
    rhi_expected_receipt_date           expected_receipt_date_tbl;
    rhi_employee_id                     employee_id_tbl;
    rhi_validation_flag                 validation_flag_tbl;

    rti_interface_transaction_id        interface_transaction_id_tbl;
    rti_header_interface_id             header_interface_id_tbl;
    rti_group_id                        group_id_tbl;
    rti_lpn_group_id                    lpn_group_id_tbl;
    rti_last_update_date                last_update_date_tbl;
    rti_last_updated_by                 last_updated_by_tbl;
    rti_creation_date                   creation_date_tbl;
    rti_created_by                      created_by_tbl;
    rti_transaction_type                transaction_type_tbl;
    rti_transaction_date                transaction_date_tbl;
    rti_processing_status_code          processing_status_code_tbl;
    rti_processing_mode_code            processing_mode_code_tbl;
    rti_transaction_status_code         transaction_status_code_tbl;
    rti_employee_id                     employee_id_tbl;
    rti_auto_transact_code              auto_transact_code_tbl;
    rti_receipt_source_code             receipt_source_code_tbl;
    rti_source_document_code            source_document_code_tbl;
    rti_parent_transaction_id           parent_transaction_id_tbl;
    rti_po_header_id                    po_header_id_tbl;
    rti_po_line_id                      po_line_id_tbl;
    rti_po_line_location_id             po_line_location_id_tbl;
    rti_po_distribution_id              po_distribution_id_tbl;
    rti_project_id                      project_id_tbl;
    rti_task_id                         task_id_tbl;
    rti_expected_receipt_date           expected_receipt_date_tbl;
    rti_validation_flag                 validation_flag_tbl;
    rti_amount                          amount_tbl;
    rti_job_id                          job_id_tbl;
    rti_timecard_id                     timecard_id_tbl;
    rti_timecard_ovn                    timecard_ovn_tbl;

    row_idx                             BINARY_INTEGER;
    l_currency_code                     VARCHAR2(3);     --bugfix 5609476
    l_api_name         CONSTANT varchar2(30) := 'Insert_Interface_Values';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    -- save new ROI data to the database
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Insert_Interface_Values'
                  );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'RHI rows: ' || p_rhi_rows.COUNT || ' RTI rows: '|| p_rti_rows.COUNT
		  );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	          , module => l_log_head
 	          , message => 'Coping the RHI Records to Local PL/SQL tables'
 	          );
    -- transfer data from table of records to tables of each column
    FOR i IN 1..p_rhi_rows.COUNT LOOP
        IF p_rhi_rows(i).processing_status_code = 'PENDING' THEN
	  BEGIN
            row_idx := rhi_header_interface_id.COUNT + 1;
            rhi_header_interface_id(row_idx) := p_rhi_rows(i).header_interface_id;
            rhi_group_id(row_idx) := p_rhi_rows(i).group_id;
            rhi_processing_status_code(row_idx) := p_rhi_rows(i).processing_status_code;
            rhi_receipt_source_code(row_idx) := p_rhi_rows(i).receipt_source_code;
            rhi_transaction_type(row_idx) := p_rhi_rows(i).transaction_type;
            rhi_auto_transact_code(row_idx) := p_rhi_rows(i).auto_transact_code;
            rhi_last_update_date(row_idx) := p_rhi_rows(i).last_update_date;
            rhi_last_updated_by(row_idx) := p_rhi_rows(i).last_updated_by;
            rhi_creation_date(row_idx) := p_rhi_rows(i).creation_date;
            rhi_created_by(row_idx) := p_rhi_rows(i).created_by;
            rhi_vendor_id(row_idx) := p_rhi_rows(i).vendor_id;
            rhi_vendor_site_id(row_idx) := p_rhi_rows(i).vendor_site_id;
            rhi_ship_to_organization_id(row_idx) := p_rhi_rows(i).ship_to_organization_id;
            rhi_location_id(row_idx) := p_rhi_rows(i).location_id;
            rhi_expected_receipt_date(row_idx) := p_rhi_rows(i).expected_receipt_date;
            rhi_employee_id(row_idx) := p_rhi_rows(i).employee_id;
            rhi_validation_flag(row_idx) := p_rhi_rows(i).validation_flag;
	  EXCEPTION
		WHEN OTHERS THEN
			-- Bug6395858
			-- Marking the RHI as error. as it went into exception
			-- Also temp table is marked for rhi rows to make RTI
			-- also in error.
			p_rhi_rows(i).processing_status_code := 'ERROR';
			l_rhi_stat(p_rhi_rows(i).header_interface_id) := 'ERROR';
			row_idx := row_idx - 1;
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
					, module => l_log_head
 	                                , message => 'Exception while populating RHI plsql table '
					||p_rhi_rows(i).header_interface_id
					|| ' Error '||SQLERRM
 	                              );
 	  END;
        END IF;
    END LOOP;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'Inserting ' || rhi_header_interface_id.COUNT || ' rows into RHI'
                  );

    -- insert into db from arrays
    FORALL i IN 1..rhi_header_interface_id.COUNT
        INSERT INTO rcv_headers_interface( header_interface_id
                                         , group_id
                                         , processing_status_code
                                         , receipt_source_code
                                         , transaction_type
                                         , auto_transact_code
                                         , last_update_date
                                         , last_updated_by
                                         , creation_date
                                         , created_by
                                         , vendor_id
                                         , vendor_site_id
                                         , ship_to_organization_id
                                         , location_id
                                         , expected_receipt_date
                                         , employee_id
                                         , validation_flag
                                         ) VALUES ( rhi_header_interface_id(i)
                                                  , rhi_group_id(i)
                                                  , rhi_processing_status_code(i)
                                                  , rhi_receipt_source_code(i)
                                                  , rhi_transaction_type(i)
                                                  , rhi_auto_transact_code(i)
                                                  , rhi_last_update_date(i)
                                                  , rhi_last_updated_by(i)
                                                  , rhi_creation_date(i)
                                                  , rhi_created_by(i)
                                                  , rhi_vendor_id(i)
                                                  , rhi_vendor_site_id(i)
                                                  , rhi_ship_to_organization_id(i)
                                                  , rhi_location_id(i)
                                                  , rhi_expected_receipt_date(i)
                                                  , rhi_employee_id(i)
                                                  , rhi_validation_flag(i)
                                                  );

    -- transfer data from table of records to tables of each column

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                   , module => l_log_head
 	                   , message => 'Inserted ' || rhi_header_interface_id.COUNT || ' rows into RHI'
 	                   );

    -- bug 6031665
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                   , module => l_log_head
 	                   , message => 'Copying the RTI Records to Local PL/SQL tables'
 	                   );
    FOR i IN 1..p_rti_rows.COUNT LOOP
    --Bug6395858
    -- Checking every RTI against the temp table whether the
    -- associated RHI is the Error the mark that records as error.

	IF l_rhi_stat.EXISTS(p_rti_rows(i).header_interface_id) THEN
 		p_rti_rows(i).processing_status_code := 'ERROR';
	END IF;

	IF p_rti_rows(i).processing_status_code = 'PENDING' THEN
	   BEGIN
		row_idx := rti_interface_transaction_id.COUNT + 1;
		rti_interface_transaction_id(row_idx) := p_rti_rows(i).interface_transaction_id;
		rti_header_interface_id(row_idx) := p_rti_rows(i).header_interface_id;
		rti_group_id(row_idx) := p_rti_rows(i).group_id;
		rti_lpn_group_id(row_idx) := p_rti_rows(i).lpn_group_id;
		rti_last_update_date(row_idx) := p_rti_rows(i).last_update_date;
		rti_last_updated_by(row_idx) := p_rti_rows(i).last_updated_by;
		rti_creation_date(row_idx) := p_rti_rows(i).creation_date;
		rti_created_by(row_idx) := p_rti_rows(i).created_by;
		rti_transaction_type(row_idx) := p_rti_rows(i).transaction_type;
		rti_transaction_date(row_idx) := p_rti_rows(i).transaction_date;
		rti_processing_status_code(row_idx) := p_rti_rows(i).processing_status_code;
		rti_processing_mode_code(row_idx) := p_rti_rows(i).processing_mode_code;
		rti_transaction_status_code(row_idx) := p_rti_rows(i).transaction_status_code;
		rti_employee_id(row_idx) := p_rti_rows(i).employee_id;
		rti_auto_transact_code(row_idx) := p_rti_rows(i).auto_transact_code;
		rti_receipt_source_code(row_idx) := p_rti_rows(i).receipt_source_code;
		rti_source_document_code(row_idx) := p_rti_rows(i).source_document_code;
		rti_parent_transaction_id(row_idx) := p_rti_rows(i).parent_transaction_id;
		rti_po_header_id(row_idx) := p_rti_rows(i).po_header_id;
		rti_po_line_id(row_idx) := p_rti_rows(i).po_line_id;
		rti_po_line_location_id(row_idx) := p_rti_rows(i).po_line_location_id;
		rti_po_distribution_id(row_idx) := p_rti_rows(i).po_distribution_id;
		rti_project_id(row_idx) := p_rti_rows(i).project_id;
		rti_task_id(row_idx) := p_rti_rows(i).task_id;
		rti_expected_receipt_date(row_idx) := p_rti_rows(i).expected_receipt_date;
		rti_validation_flag(row_idx) := p_rti_rows(i).validation_flag;
		--bugfix 5609476 {
		OPEN  c_get_currency_code(p_rti_rows(i).po_header_id);
		FETCH c_get_currency_code INTO l_currency_code;
		CLOSE c_get_currency_code;

		--call AP API to get the correct rounded-off amount
		rti_amount(row_idx) := ap_utilities_pkg.ap_round_currency(p_rti_rows(i).amount,l_currency_code);
		--bugfix 5609476 }
		rti_job_id(row_idx) := p_rti_rows(i).job_id;
		rti_timecard_id(row_idx) := p_rti_rows(i).timecard_id;
		rti_timecard_ovn(row_idx) := p_rti_rows(i).timecard_ovn;
	   EXCEPTION
		WHEN OTHERS THEN
			-- Bug6395858
 			-- Now we are marking RTI as error if any exception is raised while populating the tables
 			-- from RTI record.

 			row_idx := row_idx - 1;
 			p_rti_rows(i).processing_status_code := 'ERROR';
 			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                                  , module => l_log_head
 	                                  , message => 'Exception while populating RTI plsql table. Interface transaction id :'
 	                                               || p_rti_rows(i).interface_transaction_id
						       ||' Time card id : '||p_rti_rows(i).timecard_id|| ' Error '||SQLERRM
 	                                  );
 	   END;
	   -- Bug6343206
 	   -- We are allowing the zero amount receipts to be created as of now.
 	   -- There wont be any entry comming as a fake SUCCESS.

	   /*ELSIF p_rti_rows(i).processing_status_code = 'SUCCESS' THEN
	   -- Marking the record as fake success
 	   -- Bug6395858
 	   -- If Records dont have interface transaction id, then we need to mark this error
 	   -- as there is no other option at present to propogate fake success from here back
	   -- to the OTL.
 	   IF (p_rti_rows(i).interface_transaction_id IS NOT NULL) THEN
		p_rti_status(p_rti_rows(i).interface_transaction_id) := 1;
	   ELSE
		-- No Need to decrease the Counter here as we didnt increased.
 	        p_rti_rows(i).processing_status_code := 'ERROR';
 	        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                                  , module => l_log_head
 	                                  , message => 'Exception while propogating fake success. Interface transaction id is NULL:'
 	                                               ||' Time card id : '||p_rti_rows(i).timecard_id|| ' Error '||SQLERRM
 	                                  );
	   END IF;*/
        END IF;
    END LOOP;
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                   , module => l_log_head
 	                   , message => 'Inserting '|| rti_interface_transaction_id.COUNT  || ' rows into RHI'
 	                   );

    -- insert into db from arrays
    FORALL i IN 1..rti_interface_transaction_id.COUNT
        INSERT INTO rcv_transactions_interface( interface_transaction_id
                                              , header_interface_id
                                              , group_id
                                              , lpn_group_id
                                              , last_update_date
                                              , last_updated_by
                                              , creation_date
                                              , created_by
                                              , transaction_type
                                              , transaction_date
                                              , processing_status_code
                                              , processing_mode_code
                                              , transaction_status_code
                                              , employee_id
                                              , auto_transact_code
                                              , receipt_source_code
                                              , source_document_code
                                              , parent_transaction_id
                                              , po_header_id
                                              , po_line_id
                                              , po_line_location_id
                                              , po_distribution_id
                                              , project_id
                                              , task_id
                                              , expected_receipt_date
                                              , validation_flag
                                              , amount
                                              , job_id
                                              , timecard_id
                                              , timecard_ovn
                                              ) VALUES ( rti_interface_transaction_id(i)
                                                       , rti_header_interface_id(i)
                                                       , rti_group_id(i)
                                                       , rti_lpn_group_id(i)
                                                       , rti_last_update_date(i)
                                                       , rti_last_updated_by(i)
                                                       , rti_creation_date(i)
                                                       , rti_created_by(i)
                                                       , rti_transaction_type(i)
                                                       , rti_transaction_date(i)
                                                       , rti_processing_status_code(i)
                                                       , rti_processing_mode_code(i)
                                                       , rti_transaction_status_code(i)
                                                       , rti_employee_id(i)
                                                       , rti_auto_transact_code(i)
                                                       , rti_receipt_source_code(i)
                                                       , rti_source_document_code(i)
                                                       , rti_parent_transaction_id(i)
                                                       , rti_po_header_id(i)
                                                       , rti_po_line_id(i)
                                                       , rti_po_line_location_id(i)
                                                       , rti_po_distribution_id(i)
                                                       , rti_project_id(i)
                                                       , rti_task_id(i)
                                                       , rti_expected_receipt_date(i)
                                                       , rti_validation_flag(i)
                                                       , rti_amount(i)
                                                       , rti_job_id(i)
                                                       , rti_timecard_id(i)
                                                       , rti_timecard_ovn(i)
                                                       );

    COMMIT;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'Inserted ' || rti_interface_transaction_id.COUNT || ' rows into RTI'
                  );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Insert_Interface_Values'
                  );
END Insert_Interface_Values;

PROCEDURE Capture_Timecard_Info
( p_block             IN            HXC_USER_TYPE_DEFINITION_GRP.r_building_blocks
, p_src_attributes    IN            HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute
, p_att_idx           IN OUT NOCOPY BINARY_INTEGER
, p_dst_attributes    IN OUT NOCOPY TimecardAttributesRec
) IS
l_api_name         CONSTANT varchar2(30) := 'Capture_Timecard_Info';
l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
l_progress varchar2(3) := '000';
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'Begin Capture_Timecard_Info'
                      );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Capturing info from block record for detail bb_id=' || p_block.bb_id || ' ovn=' || p_block.ovn
                      );

    -- add the building block info
    p_dst_attributes.detail_bb_id := p_block.bb_id;
    p_dst_attributes.detail_bb_ovn := p_block.ovn;
    p_dst_attributes.detail_changed := p_block.changed;
    p_dst_attributes.detail_deleted := p_block.deleted;
    p_dst_attributes.detail_uom := p_block.uom;
    p_dst_attributes.detail_start_time := p_block.start_time;
    p_dst_attributes.detail_stop_time := p_block.stop_time;
    p_dst_attributes.detail_measure := p_block.measure;
    p_dst_attributes.resource_id := p_block.resource_id;
    p_dst_attributes.day_bb_id := p_block.parent_bb_id;
    p_dst_attributes.timecard_bb_id := p_block.timecard_bb_id;
    p_dst_attributes.timecard_bb_ovn := p_block.timecard_ovn;
    p_dst_attributes.timecard_comment := p_block.comment_text;

    -- add timecard info
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Deriving timecard info for timecard bb_id=' || p_dst_attributes.timecard_bb_id || ' ovn=' || p_dst_attributes.timecard_bb_ovn
                      );

    -- certain timecard information is not provided so we need to query them up
    DECLARE
        l_timecard_block               HXC_USER_TYPE_DEFINITION_GRP.building_block_info;
    BEGIN
        l_timecard_block := RCV_HXT_GRP.build_block( p_dst_attributes.timecard_bb_id
                                                   , p_dst_attributes.timecard_bb_ovn
                                                   );
        p_dst_attributes.timecard_start_time := l_timecard_block.start_time;
        p_dst_attributes.timecard_stop_time := l_timecard_block.stop_time;

        -- these functions are cached so we do not have to cache the results
        p_dst_attributes.timecard_approval_date := HXC_INTEGRATION_LAYER_V1_GRP.get_timecard_approval_date( p_timecard_id => p_dst_attributes.timecard_bb_id );
        p_dst_attributes.timecard_submission_date := HXC_INTEGRATION_LAYER_V1_GRP.get_timecard_submission_date( p_timecard_id => p_dst_attributes.timecard_bb_id );
        p_dst_attributes.timecard_approval_status := HXC_INTEGRATION_LAYER_V1_GRP.get_timecard_approval_status( p_timecard_id => p_dst_attributes.timecard_bb_id );
    	IF g_debug_stmt THEN
		PO_DEBUG.debug_var(l_log_head,l_progress,'timecard_approval_date', p_dst_attributes.timecard_approval_date);
		PO_DEBUG.debug_var(l_log_head,l_progress,'timecard_submission_date', p_dst_attributes.timecard_submission_date);
		PO_DEBUG.debug_var(l_log_head,l_progress,'timecard_approval_status', p_dst_attributes.timecard_approval_status);
	END IF;
    END;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Capturing info from attribute records for detail bb_id=' || p_dst_attributes.detail_bb_id || ' ovn=' || p_dst_attributes.detail_bb_ovn
                      );

    -- store the attributes for this building block in a record
    WHILE p_att_idx <= p_src_attributes.COUNT AND p_src_attributes(p_att_idx).bb_id = p_dst_attributes.detail_bb_id LOOP
        Set_Attribute( p_dst_attributes
                     , p_src_attributes(p_att_idx).field_name
                     , p_src_attributes(p_att_idx).value
                     );
         p_att_idx := p_att_idx + 1;
    END LOOP;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'End Capture_Timecard_Info'
                      );
END Capture_Timecard_Info;

PROCEDURE Capture_Old_Timecard_Info
( p_block             IN            HXC_USER_TYPE_DEFINITION_GRP.r_building_blocks
, p_src_attributes    IN            HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute
, p_att_idx           IN OUT NOCOPY BINARY_INTEGER
, p_dst_attributes    IN OUT NOCOPY TimecardAttributesRec
) IS
l_api_name         CONSTANT varchar2(30) := 'Capture_Old_Timecard_Info';
l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'Begin Capture_Old_Timecard_Info'
                      );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Capturing info from block record for old detail bb_id=' || p_block.bb_id || ' ovn=' || p_block.ovn
                      );

    -- mark this as an old block
    p_dst_attributes.old_block := 'Y';

    -- capture relevant info provided in the block
    p_dst_attributes.detail_bb_id := p_block.bb_id;
    p_dst_attributes.detail_bb_ovn := p_block.ovn;
    p_dst_attributes.detail_changed := p_block.changed;
    p_dst_attributes.detail_deleted := p_block.deleted;
    p_dst_attributes.detail_uom := p_block.uom;
    p_dst_attributes.detail_start_time := p_block.start_time;
    p_dst_attributes.detail_stop_time := p_block.stop_time;
    p_dst_attributes.detail_measure := p_block.measure;
    p_dst_attributes.resource_id := p_block.resource_id;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Deriving day/timecard info for old detail bb_id=' || p_dst_attributes.detail_bb_id || ' ovn=' || p_dst_attributes.detail_bb_ovn
                      );

    -- derive day/timecard info for old block
    DECLARE
        l_detail_block               HXC_USER_TYPE_DEFINITION_GRP.building_block_info;
        l_day_block                  HXC_USER_TYPE_DEFINITION_GRP.building_block_info;
    BEGIN
        l_detail_block := RCV_HXT_GRP.build_block( p_dst_attributes.detail_bb_id
                                                 , p_dst_attributes.detail_bb_ovn
                                                 );
        l_day_block := RCV_HXT_GRP.build_block( l_detail_block.parent_building_block_id
                                              , l_detail_block.parent_building_block_ovn
                                              );

        p_dst_attributes.day_bb_id := l_day_block.time_building_block_id;
        p_dst_attributes.timecard_bb_id := l_day_block.parent_building_block_id;
        p_dst_attributes.timecard_bb_ovn := l_day_block.parent_building_block_ovn;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Derived for old detail block: day_bb_id=' || p_dst_attributes.day_bb_id || ', timecard_bb_id=' || p_dst_attributes.timecard_bb_id || ', timecard_bb_ovn=' || p_dst_attributes.timecard_bb_ovn
                          );
    END;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Capturing info from attribute records for old detail bb_id=' || p_dst_attributes.detail_bb_id || ' ovn=' || p_dst_attributes.detail_bb_ovn
                      );

    -- capture the attributes from the old attributes table
    WHILE p_att_idx <= p_src_attributes.COUNT AND p_src_attributes(p_att_idx).bb_id = p_dst_attributes.detail_bb_id LOOP
        Set_Attribute( p_dst_attributes
                     , p_src_attributes(p_att_idx).field_name
                     , p_src_attributes(p_att_idx).value
                     );

        p_att_idx := p_att_idx + 1;
    END LOOP;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'End Capture_Old_Timecard_Info'
                      );
END Capture_Old_Timecard_Info;

PROCEDURE Query_Timecard_Info
( p_bb_id             IN            HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, p_bb_ovn            IN            HXC_TIME_BUILDING_BLOCKS.object_version_number%TYPE
, p_attributes_rec    IN OUT NOCOPY TimecardAttributesRec
) IS
    l_api_name         CONSTANT varchar2(30) := 'Query_Timecard_Info';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
    l_block                HXC_USER_TYPE_DEFINITION_GRP.building_block_info;
    l_attributes           HXC_USER_TYPE_DEFINITION_GRP.attribute_info;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Querying bb_id=' || p_bb_id || ' bb_ovn=' || p_bb_ovn
                      );

    -- query timecard block
    l_block := RCV_HXT_GRP.build_block( p_bb_id
                                      , p_bb_ovn
                                      );

    p_attributes_rec.detail_bb_id := l_block.time_building_block_id;
    p_attributes_rec.detail_bb_ovn := l_block.object_version_number;
    p_attributes_rec.detail_type := l_block.type;
    p_attributes_rec.detail_measure := l_block.measure;
    p_attributes_rec.detail_uom := l_block.unit_of_measure;
    p_attributes_rec.resource_id := l_block.resource_id;
    p_attributes_rec.timecard_approval_status := l_block.approval_status;
    p_attributes_rec.detail_date_from := l_block.date_from;
    p_attributes_rec.detail_date_to := l_block.date_to;

    -- manually pull up attributes
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Querying timecard attributes'
                      );

    l_attributes := RCV_HXT_GRP.build_attribute( p_bb_id
                                               , p_bb_ovn
                                               , 'PURCHASING'
                                               );
    p_attributes_rec.po_number := l_attributes.attribute1;
    p_attributes_rec.po_line_id := l_attributes.attribute2;
    p_attributes_rec.po_price_type := l_attributes.attribute3;
    p_attributes_rec.po_billable_amount := l_attributes.attribute4;
    p_attributes_rec.po_receipt_date := FND_DATE.canonical_to_date(l_attributes.attribute5);
    p_attributes_rec.po_line := l_attributes.attribute6;
    p_attributes_rec.po_price_type_display := l_attributes.attribute7;
    p_attributes_rec.po_header_id := l_attributes.attribute8;
EXCEPTION

    /* bug 13850458 NO_DATA_FOUND Exception is raised when no PO attribute
    details were entered in the timecard */
    WHEN NO_DATA_FOUND THEN
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                          , module => l_log_head
                          , message => 'No data found exception in Query_Timecard_Info (bb_id='
			  || p_bb_id || ', bb_ovn=' || p_bb_ovn || '): ' || SQLERRM
                          );

    WHEN OTHERS THEN
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                          , module => l_log_head
                          , message => 'Unexpected exception in Query_Timecard_Info (bb_id=' || p_bb_id || ', bb_ovn=' || p_bb_ovn || '): ' || SQLERRM
                          );
        RAISE;
END Query_Timecard_Info;

PROCEDURE Fail_ROI_Rows
( failed_timecard_id        IN            HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE
, p_rti_rows                IN OUT NOCOPY rti_table
) IS
BEGIN
    -- we have to search the entire table because we cannot keep the rows in order of timecard_id
    FOR i IN 1..p_rti_rows.COUNT LOOP
        IF p_rti_rows(i).timecard_id = failed_timecard_id THEN
            p_rti_rows(i).processing_status_code := 'ERROR';
            p_rti_rows(i).transaction_status_code := 'ERROR';
        END IF;
    END LOOP;
END Fail_ROI_Rows;

PROCEDURE Retrieve_Timecards_Body
( p_blocks             IN OUT NOCOPY  HXC_USER_TYPE_DEFINITION_GRP.t_building_blocks
, p_old_blocks         IN OUT NOCOPY  HXC_USER_TYPE_DEFINITION_GRP.t_building_blocks
, p_attributes         IN OUT NOCOPY  HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute
, p_old_attributes     IN OUT NOCOPY  HXC_USER_TYPE_DEFINITION_GRP.t_time_attribute
, p_receipt_date       IN             DATE
) IS
    l_processable_rows_exist varchar2(1);   --Bug6000903
    l_rt_row               new_rt_rows%ROWTYPE;
    l_rti_status           rti_status_table;
    l_attributes           TimecardAttributesRec;
    l_old_attributes       TimecardAttributesRec;
    l_all_attributes       TimecardAttributesTbl;
    l_rhi_rows             rhi_table;
    l_rti_rows             rti_table;

    blk_idx                BINARY_INTEGER;
    old_blk_idx            BINARY_INTEGER;
    att_idx                BINARY_INTEGER;
    old_att_idx            BINARY_INTEGER;

    last_blk_idx           BINARY_INTEGER;
    last_old_blk_idx       BINARY_INTEGER;
    last_att_idx           BINARY_INTEGER;
    last_old_att_idx       BINARY_INTEGER;

    failed_timecard_id     HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE;
     -- Bug6357273
     -- This is added to Propagate the errored Detail block id on those we will get
     -- Skipped by this failed Block
     failed_detail_block_id     HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE;

    TRANSACTION_FAILED     EXCEPTION;
    l_api_name         CONSTANT varchar2(30) := 'Retrieve_Timecards_Body';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
    --Bug6357273
    -- This temp variable is been added to loop through records when a detail block fails
    -- and get the Details blocks for the same timecards which are processed and make them
    -- with errors.
    l_exp_idx              BINARY_INTEGER;
BEGIN
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Retrieve_Timecards_Body'
                  );
    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'last_blk_idx=' || last_blk_idx || ' last_old_blk_idx=' || last_old_blk_idx || ' last_att_idx=' || last_att_idx || ' last_old att_idx=' || last_old_att_idx
                  );

    -- initialize indexes
    blk_idx     := 1;
    old_blk_idx := 1;
    att_idx     := 1;
    old_att_idx := 1;

    last_blk_idx     := p_blocks.COUNT;
    last_old_blk_idx := p_old_blocks.COUNT;
    last_att_idx     := p_attributes.COUNT;
    last_old_att_idx := p_old_attributes.COUNT;

    -- cleanup iSP table by calling reconcile_actions
    DECLARE
        l_return_status                  VARCHAR2(100);
        l_msg_data                       VARCHAR2(2000);
    BEGIN
	-- Making Stages which are been cleared in Retrieval Program which we will help to
 	-- track the Transaction Status. One Transaction is comman to all the timecards
 	-- which are been worked upon.
 	--
 	-- Need to Verified this message is stored in local variable
 	-- which might not get into OTL in Retrieval Program Crash...
 	g_txn_msg := 'Stage 01 - ISP Reconcile Action is been called for First Time';
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Calling iSP to reconcile actions'
                          );

        PO_STORE_TIMECARD_PKG_GRP.reconcile_actions( p_api_version => 1.0
                                                    , x_return_status => l_return_status
                                                    , x_msg_data => l_msg_data
                                                    );

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Done with iSP reconcile actions'
                          );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE ISP_RECONCILE_ACTIONS_FAILED;
        END IF;
    EXCEPTION
        WHEN ISP_RECONCILE_ACTIONS_FAILED THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
	                       ,module=>l_log_head
                              , message => 'iSP reconcile actions failed: x_return_status=' || l_return_status || ' x_msg_data=' || l_msg_data
                              );
            RAISE;
        WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                              , module => l_log_head
                              , message => 'Unexpected exception while calling iSP reconcile actions: x_return_status=' || l_return_status || ' x_msg_data=' || l_msg_data || ' sqlerrm=' || SQLERRM
                              );
            RAISE ISP_RECONCILE_ACTIONS_FAILED;
    END;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'Starting main loop through detail building blocks...'
                  );

    -- loop through the detail building blocks
    g_txn_msg := 'Stage 02 - Start Processing the Blocks one by one before inserting in ROI';
    WHILE blk_idx <= last_blk_idx LOOP
        BEGIN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => '|------------------ blk_idx = ' || blk_idx || ' ------------------|'
                              );

	    --Bug6357273
	    -- We are trying to keep track of every block which is getting processes while the program runs
	    -- such that we can populate this message to OTL, In case of failure we will be to track the
	    -- Flow for that specific Detail Block.

	    --Bug6357273
	    /* Making every record initially as error, Because when OTL passes the Data to Global PL SQL
	    they mark the records as IN PROGRESS, then by any changes if  the Retrieval Program crashes
	    without Completing then this records left in IN PROGRESS only which latter on are not Picked
	    for any futher Retrieval.
	    Also will be overwritting this status, when we get success for the Blocks. This will make the
	    excpetion DETAIL_NOT_PROCESSED unused as there will no records which will have t_tx_detail_status
	    as NULL.
	    This will insure that even if we encounter unexpected error then blocks will not remain as
	    IN PROGRESS. */

	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERROR';
	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO: Start Processing the Block';

	    -- skip unapproved timecards
            WHILE blk_idx <= last_blk_idx AND
                  HXC_INTEGRATION_LAYER_V1_GRP.get_timecard_approval_status( p_blocks(blk_idx).bb_id ) <> 'APPROVED'
            LOOP
                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERRORS';
                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'Timecard not approved';

                skip_block( p_blocks
                          , blk_idx
                          , p_old_blocks
                          , old_blk_idx
                          , p_attributes
                          , att_idx
                          , p_old_attributes
                          , old_att_idx
                          );
            END LOOP;

            -- check that we have not skipped everything left
            EXIT WHEN blk_idx > last_blk_idx;

            -- clear the attribute map
            l_attributes := NULL;
            l_old_attributes := NULL;
	    --Bug6357273
 	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-20- Capture_Timecard_Info - Start';

            Capture_Timecard_Info( p_block => p_blocks(blk_idx)
                                 , p_src_attributes => p_attributes
                                 , p_att_idx => att_idx
                                 , p_dst_attributes => l_attributes
                                 );
	   --Bug6357273
 	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-30- Capture_Timecard_Info - End';

            -- add old block info for changed blocks
	    --Bug 17930358 : For deleted blocks as well
            IF (p_blocks(blk_idx).changed = 'Y' OR p_blocks(blk_idx).deleted = 'Y') THEN
	   --Bug6357273
 	     HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-40- Capture_Old_Timecard_Info - Start';
                Capture_Old_Timecard_Info( p_block => p_old_blocks(old_blk_idx)
                                         , p_src_attributes => p_old_attributes
                                         , p_att_idx => old_att_idx
                                         , p_dst_attributes => l_old_attributes
                                         );

            --Bug6357273
 	     HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-50- Capture_Old_Timecard_Info - End';

		-- maintain the old block index
                old_blk_idx := old_blk_idx + 1;
            END IF;
	    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                        , module => l_log_head
 	                        , message => 'fill the po_distribution_id and line_location_id for NEW attributes'
 	                        );
	    --Bug6357273
 	     HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-60- Get the PO Line - Start';
            -- add PO shipment and distribution information
            l_attributes.po_line_location_id := get_po_line(l_attributes.po_line_id).line_location_id;
	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-70- Get the PO Distribution for the line : '||
 	                                 l_attributes.po_line_id ||
 	                                 ' Project : '||l_attributes.project_id||
 	                                  ' Task : '||l_attributes.task_id||
 	                                  ' - Start';

            l_attributes.po_distribution_id := get_po_distribution( l_attributes.po_line_id
                                                                  , l_attributes.project_id
                                                                  , l_attributes.task_id
                                                                  ).po_distribution_id;
            HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-80- Get the PO Distribution End';

	    -- bug 5976883
 	    -- need to add the shipment and distribution information to the old attributes block also
 	    -- This is required since in the derive_delete_values we build the rti based on the old_attributes
 	    -- only and the rti does not contain the dist, shipment_id values.
 	    -- Hence get_rti_idx fails in case of a po-projects OTL setup, since in this case we use distribution_id
 	    -- to get the rti_idx, before calling PO_STORE_TIMECARD_PKG_GRP.store_timecard_details
 	    --Bug 17930358 : For deleted blocks as well
	    IF ( p_blocks(blk_idx).changed = 'Y' OR p_blocks(blk_idx).deleted = 'Y' )THEN
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                              , module => l_log_head
 	                              , message => 'fill the po_distribution_id and line_location_id for old attributes'
 	                               );
	        HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-90- Get the PO line for Old block - Start';
		l_old_attributes.po_line_location_id := get_po_line(l_old_attributes.po_line_id).line_location_id;
                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-100- Get the PO Distribution for the Old line : '||
 	                                                                            l_old_attributes.po_line_id ||
 	                                                                            ' Project : '||l_old_attributes.project_id||
 	                                                                            ' Task : '||l_old_attributes.task_id||
 	                                                                            ' - Start';
 	        l_old_attributes.po_distribution_id := get_po_distribution( l_old_attributes.po_line_id
 	                                                                           , l_old_attributes.project_id
 	                                                                           , l_old_attributes.task_id
 	                                                                           ).po_distribution_id;
	        HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-110- Get the Old PO Distribution End';

 	    END IF;

            -- set the receipt date
            l_attributes.po_receipt_date := p_receipt_date;

            -- derive roi field values from timecard attributes
	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-120- Calculate the RTI values - Start';
            Derive_Interface_Values(l_attributes, l_old_attributes, l_rhi_rows, l_rti_rows);
            HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'PO-130- Calculate the RTI values - End';
            -- add attributes to big table for use later
            l_all_attributes(l_attributes.detail_bb_id) := l_attributes;

            -- advance the block loop counter
            blk_idx := blk_idx + 1;
        EXCEPTION
		WHEN OTHERS THEN
		--Bug6357273
 		-- save the exception description before we lose it and upending the message with the
 		-- Status message for that block.

		HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERRORS';
 		HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx)
			|| 'Unexpected exception while processing results from Generic Retrieval: ' || SQLERRM;
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                                  , module => l_log_head
                                  , message =>HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx)
                                  );

                -- When a detail fails, we need to fail the entire timecard.
                -- The detail blocks are ordered by day, and timecard, so we only need to search adjacent detail blocks
                failed_timecard_id := p_blocks(blk_idx).timecard_bb_id;

		-- Bug6357273
 	        -- This is added to Propagate the errored Detail block id on those we will get
 	        -- Skipped by this failed Block
 	        failed_detail_block_id := p_blocks(blk_idx).bb_id;

                -- Those that came before can be aborted by setting the ROI status codes to ERROR
		Fail_ROI_Rows( failed_timecard_id, l_rti_rows );

		--Bug6357273
 	        --Even the previous time card blocks which are processed so far need to be skipped and stamped with appropriate error message
 	        l_exp_idx := blk_idx - 1;
 	        WHILE l_exp_idx >= 1 AND p_blocks(l_exp_idx).timecard_bb_id = failed_timecard_id LOOP
			HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_exp_idx) := 'ERRORS';
 	                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_exp_idx) := 'Skipped because detail block '||failed_detail_block_id||' in the same timecard failed';
			l_exp_idx := l_exp_idx -1;
 	        END LOOP;

                -- Those that will come after can be aborted by simply skipping over them
                blk_idx := blk_idx + 1;
                WHILE blk_idx <= last_blk_idx AND p_blocks(blk_idx).timecard_bb_id = failed_timecard_id LOOP
			-- set the error description while we still know what happened
			HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERRORS';
			HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'Skipped because detail block '||failed_detail_block_id||' in the same timecard failed';

			skip_block( p_blocks
                              , blk_idx
                              , p_old_blocks
                              , old_blk_idx
                              , p_attributes
                              , att_idx
                              , p_old_attributes
                              , old_att_idx
                              );
                END LOOP;
        END;
    END LOOP;

    -- bug 6000903: check if any processable rows exists. Launch RTP only if
    -- there are processable rows
    l_processable_rows_exist := 'N';
    g_txn_msg := 'Stage 03 - Done with Capture TimeCard Block Process, going to insert valid one to Receiving interface table';
    set_rhi_table_status(l_rhi_rows, l_rti_rows,l_processable_rows_exist);

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'l_processable_rows_exist' || l_processable_rows_exist
                              );

    IF l_processable_rows_exist ='Y' THEN
      --IF l_rti_rows.COUNT > 0 THEN
      -- Bug6343206
      -- Reverting the changes done for BUG3550333 [115.69]
      -- We are allowing the zero amount receipts to be created as of now.
      -- There will be no entry going in as SUCCESS. so we need no track
      -- those block by l_rti_status.
      -- insert the ROI rows into the database
      -- Insert_Interface_Values(l_rhi_rows, l_rti_rows, l_rti_status);

      Insert_Interface_Values(l_rhi_rows, l_rti_rows);

      -- call the receiving transaction processor
      DECLARE
            l_phase             VARCHAR2(240);
            l_status            VARCHAR2(240);
            l_dev_phase         VARCHAR2(240);
            l_dev_status        VARCHAR2(240);
            l_message           VARCHAR2(240);
            l_success           BOOLEAN;

            l_return_code       NUMBER;
            l_timeout           NUMBER := 300;
            l_outcome           VARCHAR2(240);

            RVCTP_FAILED        EXCEPTION;
      BEGIN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Calling Receiving Transaction Processor with group_id=' || g_group_id
                          );

            g_receiving_start := SYSDATE;

            g_req_id := FND_REQUEST.SUBMIT_REQUEST( application => 'PO'
                                                  , program => 'RVCTP'
                                                  , description => 'Receiving Transaction Processor called by Retrieve Time from OTL'
                                                  , argument1 => 'BATCH'
                                                  , argument2 => g_group_id
                                                  );

            IF (g_req_id = 0) THEN
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                                  , module => l_log_head
                                  , message => 'Concurrent request submission failed'
                                  );

                RAISE RVCTP_FAILED;
            ELSE
                COMMIT;
            END IF;

            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Request ID for RVCTP: ' || TO_CHAR(g_req_id)
                              );

            l_success := FND_CONCURRENT.WAIT_FOR_REQUEST( request_id => g_req_id
                                                        , interval => 15
                                                        , max_wait => 0
                                                        , phase => l_phase
                                                        , status => l_status
                                                        , dev_phase => l_dev_phase
                                                        , dev_status => l_dev_status
                                                        , message => l_message
                                                        );

            g_receiving_stop := SYSDATE;
            g_receiving_time := g_receiving_time + ( g_receiving_stop - g_receiving_start );

            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'RVCTP done: ' || '*' || l_phase || '*' || l_status || '*' || l_dev_phase || '*' || l_dev_status || '*' || l_message || '*'
                              );

            IF NOT l_success THEN
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'Receiving Transaction Processor returned false.'
                              );

                RAISE RVCTP_FAILED;
            END IF;
      EXCEPTION
	WHEN RVCTP_FAILED THEN
		G_CONC_LOG := G_CONC_LOG || FND_MESSAGE.get_string('PO', 'RCV_OTL_RCVTP_FAIL')
                                         || FND_GLOBAL.local_chr(10) || FND_GLOBAL.local_chr(10);

                ROLLBACK;

                --
                UPDATE rcv_transactions_interface
                   SET transaction_status_code = 'ERROR'
                 WHERE group_id = g_group_id
                   AND transaction_status_code = 'RUNNING';

                COMMIT;

        WHEN OTHERS THEN
		RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'Exception trying to run Receiving Transaction Processor: ' || SQLERRM
                              );
                RAISE TRANSACTION_FAILED;
        END;
    END IF;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Finding successful receiving transactions'
                      );
    g_txn_msg := 'Stage 04 - RTP is Sucess, Looping through RCV Transaction for Getting Success Records.';

    -- get the successful transactions we just created
    FOR l_rt_row IN new_rt_rows( l_rti_rows(1).group_id ) LOOP
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Successful RTI id ' || l_rt_row.interface_transaction_id
                          );
        l_rti_status(l_rt_row.interface_transaction_id) := 1;
    END LOOP;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Setting Detail Statuses'
                      );

    -- update detail statuses
    FOR blk_idx IN 1..last_blk_idx LOOP
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Setting Detail Status for blk_idx=' || blk_idx || ' bb_id=' || p_blocks(blk_idx).bb_id
                          );

        DECLARE
            l_bb_id                   HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE;
            l_transaction_type        VARCHAR2(100);
            l_receive_rti_id          RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE;
            l_deliver_rti_id          RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE;
            l_delete_receive_rti_id   RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE;
            l_delete_deliver_rti_id   RCV_TRANSACTIONS_INTERFACE.interface_transaction_id%TYPE;
            l_message                 VARCHAR2(1000);
            DETAIL_NOT_PROCESSED      EXCEPTION;
        BEGIN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Finding RTI ids'
                              );

            l_bb_id := p_blocks(blk_idx).bb_id;

            IF NOT l_all_attributes.EXISTS(l_bb_id) THEN
                RAISE DETAIL_NOT_PROCESSED;
            END IF;

            l_transaction_type := l_all_attributes(l_bb_id).transaction_type;
            l_receive_rti_id := l_all_attributes(l_bb_id).receive_rti_id;
            l_deliver_rti_id := l_all_attributes(l_bb_id).deliver_rti_id;
            l_delete_receive_rti_id := l_all_attributes(l_bb_id).delete_receive_rti_id;
            l_delete_deliver_rti_id := l_all_attributes(l_bb_id).delete_deliver_rti_id;

            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Found bb_id=' || l_bb_id
                                        || ' transaction_type=' || l_transaction_type
                                        || ' receive_rti_id=' || l_receive_rti_id
                                        || ' deliver_rti_id=' || l_deliver_rti_id
                                        || ' delete_receive_rti_id=' || l_delete_receive_rti_id
                                        || ' delete_deliver_rti_id=' || l_delete_deliver_rti_id
                              );

            IF (l_transaction_type = 'RECEIVE'
                AND l_rti_status.EXISTS(l_receive_rti_id))
            OR (l_transaction_type = 'CORRECT'
                AND l_rti_status.EXISTS(l_receive_rti_id)
                AND l_rti_status.EXISTS(l_deliver_rti_id))
            OR (l_transaction_type = 'DELETE'
                AND l_rti_status.EXISTS(l_delete_receive_rti_id)
                AND l_rti_status.EXISTS(l_delete_deliver_rti_id))
            OR (l_transaction_type = 'DELETE RECEIVE'
                AND l_rti_status.EXISTS(l_receive_rti_id)
                AND l_rti_status.EXISTS(l_delete_receive_rti_id)
                AND l_rti_status.EXISTS(l_delete_deliver_rti_id))
            OR (l_transaction_type = 'DELETE CORRECT'
                AND l_rti_status.EXISTS(l_receive_rti_id)
                AND l_rti_status.EXISTS(l_deliver_rti_id)
                AND l_rti_status.EXISTS(l_delete_receive_rti_id)
                AND l_rti_status.EXISTS(l_delete_deliver_rti_id)) THEN

                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'SUCCESS';
                g_successful_details := g_successful_details + 1;

                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => l_log_head
                                  , message => 'Detail success'
                                  );

            ELSE
                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERRORS';
                -- BUG6357273
 	        -- Propogating RTP errors back to the OTL.
 	        -- Logic : We are looping through all the records from rcv_transaction_interface
 	        -- for the Transaction Line id which is  not there in the l_rti_status table which
 	        -- is means this records have failed and can have RTP Error Message.
 	        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                            , module => l_log_head
 	                            , message => 'Stamping RTP errors to the Timecards '
 	                           );

 	        FOR rec IN (SELECT error_message_name ||' : '|| error_message msg
 	                    FROM po_interface_errors
 	                    WHERE interface_line_id IN (l_receive_rti_id,l_deliver_rti_id,
 	                    l_delete_receive_rti_id,l_delete_deliver_rti_id)
 	                    AND table_name = 'RCV_TRANSACTIONS_INTERFACE') LOOP

 	                     RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
 	                                   , module => l_log_head
 	                                   , message => 'RTP errors : ' || rec.msg
 	                                   );

 	                     l_message := l_message || rec.msg;
 	        END LOOP;

 	        IF HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) IS NULL THEN
 	                 HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'Receipt not created : '||l_message;
 	        ELSE
 	                 HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) || ' Receipt not created : '||l_message;
 	        END IF;
                g_failed_details := g_failed_details + 1;

                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => l_log_head
                                  , message => 'Detail error '||HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx)
                                  );
            END IF;
        EXCEPTION
            WHEN DETAIL_NOT_PROCESSED THEN
                -- only set generic message if not already set when ignoring block
                IF HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) IS NULL THEN
                    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERRORS';
                    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'Detail block not processed';
                ELSE
 	            HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx)
			     || ' Detail block not processed';
		END IF;
                g_failed_details := g_failed_details + 1;

                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => l_log_head
                                  , message => 'Detail block not processed'
                                  );

            WHEN OTHERS THEN
                HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(blk_idx) := 'ERRORS';
		IF HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) IS NULL THEN
			HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := 'Unexpected exception while checking receipt for detail block: ' || SQLERRM;
		ELSE
 	            HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(blk_idx) := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception (blk_idx) || 'Exception while checking receipt for detail block: ' || SQLERRM;
 	        END IF;
                g_failed_details := g_failed_details + 1;

                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                                  , module => l_log_head
                                  , message => 'Unexpected exception while checking receipt for detail block: ' || SQLERRM
                                  );
        END;
    END LOOP;
    g_txn_msg := 'Stage 05 - Processed the Records for success/ERROR Transaction. Going for ISP reconcile Action' ;
    DECLARE
        l_return_status                  VARCHAR2(100);
        l_msg_data                       VARCHAR2(2000);

        ISP_RECONCILE_ACTIONS_FAILED     EXCEPTION;
    BEGIN
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Calling iSP to reconcile actions'
                          );

        PO_STORE_TIMECARD_PKG_GRP.reconcile_actions( p_api_version => 1.0
                                                   , x_return_status => l_return_status
                                                   , x_msg_data => l_msg_data
                                                   );

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                          , module => l_log_head
                          , message => 'Done with iSP reconcile actions'
                          );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE ISP_RECONCILE_ACTIONS_FAILED;
        END IF;
    EXCEPTION
        WHEN ISP_RECONCILE_ACTIONS_FAILED THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'iSP reconcile actions failed: x_return_status=' || l_return_status || ' x_msg_data=' || l_msg_data
                              );
        WHEN OTHERS THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                              , module => l_log_head
                              , message => 'Unexpected exception while calling iSP reconcile actions: x_return_status=' || l_return_status || ' x_msg_data=' || l_msg_data || ' sqlerrm=' || SQLERRM
                              );
    END;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'Setting Day/Timecard Statuses'
                  );

    -- update status for day and timecard building blocks
    HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'Setting Transaction Status'
                  );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'RT status count = ' || l_rti_status.COUNT
                  );

    -- if every block was in error, the transaction failed
    IF l_rti_status.COUNT = 0 THEN
        g_txn_status := 'ERRORS';
        g_overall_status := 'ERRORS';
        g_txn_msg := g_txn_msg || 'No Receiving Transaction created';
    ELSE
        g_txn_status := 'SUCCESS';
        g_txn_msg := 'Receiving Transactions created';
    END IF;

    HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
          p_process => 'Purchasing Retrieval Process'
        , p_status  => g_txn_status
        , p_exception_description => g_txn_msg
    );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Retrieval Transaction ' || g_txn_status || ': ' || g_txn_msg
                      );

    COMMIT;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                      , module => l_log_head
                      , message => 'Transaction committed'
                      );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'End Retrieve_Timecards_Body'
                      );
EXCEPTION
    WHEN DEBUGGING_BREAKPOINT THEN
	-- Bug6357273.
 	-- In the case also we need to propogate message back to OTL
 	-- Which will help OTL to debug by the records got failed
 	ROLLBACK;
 	HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;
        HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
		p_process => 'Purchasing Retrieval Process'
		, p_status  => 'ERRORS'
		, p_exception_description => g_txn_msg || 'Hit Breakpoint. Ending process in error, because we are still debugging.'
		);
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                      , module => l_log_head
                      , message => g_txn_msg || 'Hit Breakpoint. Ending process in error, because we are still debugging.'
                      );
        COMMIT;
        RAISE RETRIEVAL_FAILED;
    WHEN ISP_RECONCILE_ACTIONS_FAILED THEN
         -- Bug6357273.
 	 -- In the case also we need to propogate message back to OTL
 	 -- Which will help OTL to debug by the records got failed
 	 ROLLBACK;
 	 HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;
        -- this is only raised in the first call to reconcile actions. the later one is not fatal.
        HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
		p_process => 'Purchasing Retrieval Process'
		, p_status  => 'ERRORS'
		, p_exception_description => g_txn_msg || 'Error calling Reconcile_Actions, please see FND_LOG_MESSAGES for details'
		);
	COMMIT;
        RAISE RETRIEVAL_FAILED;
    WHEN ISP_STORE_TIMECARD_FAILED THEN
        -- Bug6357273.
 	-- In the case also we need to propogate message back to OTL
 	-- Which will help OTL to debug by the records got failed
 	ROLLBACK;
 	HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;
	HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
		p_process => 'Purchasing Retrieval Process'
		, p_status  => 'ERRORS'
		, p_exception_description => g_txn_msg || 'Error in Retrieve_Timecards_Body, please see FND_LOG_MESSAGES for details'
		);
        COMMIT;
        RAISE RETRIEVAL_FAILED;
    WHEN TRANSACTION_FAILED THEN
	-- Bug6357273.
 	-- In the case also we need to propogate message back to OTL
 	-- Which will help OTL to debug by the records got failed
 	ROLLBACK;
 	HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;
        HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
		p_process => 'Purchasing Retrieval Process'
		, p_status  => 'ERRORS'
		, p_exception_description => 'Error in Retrieve_Timecards_Body, please see FND_LOG_MESSAGES for details'
		);
        COMMIT;
	RAISE RETRIEVAL_FAILED;
    WHEN OTHERS THEN
	-- Bug6357273.
 	-- In the case also we need to propogate message back to OTL
 	-- Which will help OTL to debug by the records got failed
 	ROLLBACK;
 	HXC_INTEGRATION_LAYER_V1_GRP.set_parent_statuses;


        HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
          p_process => 'Purchasing Retrieval Process'
        , p_status  => 'ERRORS'
        , p_exception_description => SUBSTR(g_txn_msg || 'Unexpected exception in Retrieve_Timecards_Body: ' || SQLERRM, 1, 2000)
        );
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                      , module => l_log_head
                      , message => SUBSTR(g_txn_msg || 'Unexpected exception in Retrieve_Timecards_Body: ' || SQLERRM, 1, 2000)
                      );
        COMMIT;
        RAISE RETRIEVAL_FAILED;
END Retrieve_Timecards_Body;

-- Public callbacks
FUNCTION Purchasing_Retrieval_Process RETURN VARCHAR2 IS
    l_retrieval_process HXC_TIME_RECIPIENTS.application_retrieval_function%TYPE;
BEGIN
    l_retrieval_process := 'Purchasing Retrieval Process';
    RETURN l_retrieval_process;
END Purchasing_Retrieval_Process;

-- errors/warnings cannot be raised during update
PROCEDURE Update_Timecard( p_operation IN VARCHAR2 )
IS
    l_bb_id                    HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE;

    l_all_attributes           TimecardAttributesTbl;

    l_blocks                   HXC_USER_TYPE_DEFINITION_GRP.timecard_info;
    l_attributes               HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info;
    l_messages                 HXC_USER_TYPE_DEFINITION_GRP.message_table;
    l_api_name         CONSTANT varchar2(30) := 'Update_Timecard';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    g_update_start := SYSDATE;
    initialize_cache_statistics;
    initialize_caches;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'Begin Update_Timecard'
                      );

    -- get time information
    HXC_INTEGRATION_LAYER_V1_GRP.get_app_hook_params(
                                  p_building_blocks => l_blocks,
                                  p_app_attributes  => l_attributes,
                                  p_messages        => l_messages);

    -- sort the attributes by bb_id
    Sort_Attributes( p_all_attributes => l_all_attributes
                   , p_raw_attributes => l_attributes
                   );

    -- loop through the detail blocks to process them with the attributes
    FOR blk_idx IN 1..l_blocks.COUNT LOOP
        IF l_blocks(blk_idx).scope = 'DETAIL' THEN
            l_bb_id := l_blocks(blk_idx).time_building_block_id;

            -- add some block properties
            l_all_attributes(l_bb_id).detail_measure := l_blocks(blk_idx).measure;

            -- modify the attributes as necessary
            Update_Attributes(l_all_attributes(l_bb_id), l_messages);
        END IF;
    END LOOP;

    -- go through the attributes again to save the data
    FOR att_idx IN 1..l_attributes.COUNT LOOP
        l_bb_id := l_attributes(att_idx).building_block_id;

        IF l_attributes(att_idx).attribute_name = 'PO Number' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_number;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Header Id' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_header_id;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Line Number' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_line;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Line Id' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_line_id;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Price Type' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_price_type;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Price Type Display' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_price_type_display;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Billable Amount' THEN
            l_attributes(att_idx).attribute_value := l_all_attributes(l_bb_id).po_billable_amount;
        ELSIF l_attributes(att_idx).attribute_name = 'PO Receipt Date' THEN
            l_attributes(att_idx).attribute_value := FND_DATE.date_to_canonical(l_all_attributes(l_bb_id).po_receipt_date);
        END IF;
    END LOOP;

    -- set time information
    HXC_INTEGRATION_LAYER_V1_GRP.set_app_hook_params(
                                  p_building_blocks => l_blocks,
                                  p_app_attributes => l_attributes,
                                  p_messages => l_messages);

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'End Update_Timecard'
                      );

    g_update_stop := SYSDATE;
END Update_Timecard;

PROCEDURE Validate_Timecard( p_operation IN VARCHAR2 )
IS
    l_all_attributes           TimecardAttributesTbl;
    l_old_attributes           TimecardAttributesTbl;
    l_attributes_rec           TimecardAttributesRec;
    l_old_attributes_rec       TimecardAttributesRec;
    l_bb_id                    HXC_TIME_BUILDING_BLOCKS.time_building_block_id%TYPE;

    l_blocks                   HXC_USER_TYPE_DEFINITION_GRP.timecard_info;
    l_attributes               HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info;
    l_messages                 HXC_USER_TYPE_DEFINITION_GRP.message_table;
    l_api_name         CONSTANT varchar2(30) := 'Validate_Timecard';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    g_validate_start := SYSDATE;
    initialize_cache_statistics;

    /* Bug 5401262: Procedure Validate_Amount_Tolerances() validates all rows in po
                    cache. We need to clear cache to prevent false errors/warnings */
    g_po_line_cache.delete;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Validate_Timecard'
                  );

    -- get time information
    HXC_INTEGRATION_LAYER_V1_GRP.get_app_hook_params(
                                  p_building_blocks => l_blocks,
                                  p_app_attributes  => l_attributes,
                                  p_messages        => l_messages);

    Sort_Attributes( p_all_attributes => l_all_attributes
                   , p_raw_attributes => l_attributes
                   );

    -- loop through the blocks to capture the block properties in the attribute map
    FOR blk_idx IN 1..l_blocks.COUNT LOOP
        l_bb_id := l_blocks(blk_idx).time_building_block_id;

        -- make a local working copy
        l_attributes_rec := l_all_attributes(l_bb_id);

        -- add some relevant bb info as attributes
        IF l_blocks(blk_idx).scope = 'DETAIL' THEN
            l_attributes_rec.detail_bb_id := l_bb_id;
            l_attributes_rec.detail_bb_ovn := l_blocks(blk_idx).object_version_number;
            l_attributes_rec.detail_type := l_blocks(blk_idx).type;
            l_attributes_rec.detail_changed := l_blocks(blk_idx).changed;
            l_attributes_rec.detail_new := l_blocks(blk_idx).new;
            l_attributes_rec.detail_measure := l_blocks(blk_idx).measure;
            l_attributes_rec.detail_uom := l_blocks(blk_idx).unit_of_measure;
            l_attributes_rec.resource_id := l_blocks(blk_idx).resource_id;
            l_attributes_rec.old_block := 'N';

            -- emulate the deleted attribute
            IF l_blocks(blk_idx).date_to <> HR_GENERAL.end_of_time THEN
                l_attributes_rec.detail_deleted := 'Y';
            ELSE
                l_attributes_rec.detail_deleted := 'N';
            END IF;

            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                              , module => l_log_head
                              , message => 'Detail block flags *'
                                        || l_attributes_rec.detail_changed || '*'
                                        || l_attributes_rec.detail_new || '*'
                                        || l_attributes_rec.detail_deleted || '*'
                              );

            -- capture old block/attr info if relevant
            IF l_attributes_rec.detail_new = 'N' THEN
                Query_Timecard_Info( l_attributes_rec.detail_bb_id
                                   , l_attributes_rec.detail_bb_ovn
                                   , l_old_attributes_rec
                                   );

                -- we only care about the most recent SUBMITTED block if it exists
                WHILE l_old_attributes_rec.detail_bb_ovn > 1 AND
                      l_old_attributes_rec.timecard_approval_status <> 'SUBMITTED' LOOP
			Query_Timecard_Info( l_old_attributes_rec.detail_bb_id
                                       , l_old_attributes_rec.detail_bb_ovn - 1
                                       , l_old_attributes_rec
                                       );
                END LOOP;

                -- mark this as an old block since Query_Timecard_Info does not know that
                l_old_attributes_rec.old_block := 'Y';

                -- negate the amount to subtract from the po line amount later
                l_old_attributes_rec.po_billable_amount := 0 - l_old_attributes_rec.po_billable_amount;

                l_old_attributes(l_bb_id) := l_old_attributes_rec;

	    ELSE
		/* bug 13850458 If the timecard is created first time,
		null assignment required for old blocks check */
		l_old_attributes(l_bb_id) := NULL;

            END IF;
        ELSIF l_blocks(blk_idx).scope = 'DAY' THEN
            l_attributes_rec.day_bb_id := l_bb_id;
            l_attributes_rec.day_start_time := l_blocks(blk_idx).start_time;
        END IF;

        -- save the changes back in the main repository
        l_all_attributes(l_bb_id) := l_attributes_rec;
    END LOOP;

    -- loop through the blocks again to perform validations
    /** Bug:5559915
    *    Before looping into the each time card entry of a Time card, set the
    *    g_error_raised_flag to 0 and after the loop reset it to 0.
    *    When Validate_Attributes() is called inside the FOR loop, we have to log
    *    PO and PO line related error message only once and not for each
    *    Time card entry. Validate_Attributes() may set the g_error_raised_flag
    *    to 1, so we have to reset after the FOR loop.
    */

    g_error_raised_flag := 0;--Bug:5559915
    FOR blk_idx IN 1..l_blocks.COUNT LOOP
        l_bb_id := l_blocks(blk_idx).time_building_block_id;

        IF l_blocks(blk_idx).scope = 'DETAIL' THEN
            -- capture the parent information
            l_all_attributes(l_bb_id).day_start_time := l_all_attributes(l_blocks(blk_idx).parent_building_block_id).day_start_time;

	    IF l_old_attributes.EXISTS(l_bb_id) THEN
                l_old_attributes(l_bb_id).day_start_time := l_all_attributes(l_bb_id).day_start_time;
            END IF;

            -- validate the old attributes if relevant
            /*IF l_all_attributes(l_bb_id).detail_new = 'N' AND
               l_all_attributes(l_bb_id).detail_changed = 'Y' AND
               l_old_attributes(l_bb_id).timecard_approval_status = 'SUBMITTED' THEN
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => G_LOG_MODULE
                                  , message => 'Validating old block'
                                  );
                Validate_Attributes(l_old_attributes(l_bb_id), l_messages);
	      ELSE
                -- ignore blocks that have not been submitted
                -- and blocks that have not changed
                l_old_attributes(l_bb_id).validation_status := 'SKIPPED';
              END IF;

              -- validate the new attributes if block is not deleted and old block is good/irrelevant
              IF l_all_attributes(l_bb_id).detail_new = 'Y' OR
               ( l_all_attributes(l_bb_id).detail_changed = 'Y' AND
                 l_all_attributes(l_bb_id).detail_deleted = 'N' AND
                 l_old_attributes(l_bb_id).validation_status IN ('SUCCESS','SKIPPED')
               ) THEN
                  RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => l_log_head
                                  , message => 'Validating new block'
                                  );
                  Validate_Attributes(l_all_attributes(l_bb_id), l_messages);
              END IF;
            */

	    /* Fix for bug 11678258 begins */
	    IF l_all_attributes(l_bb_id).detail_new = 'N' AND
	       l_old_attributes(l_bb_id).timecard_approval_status = 'SUBMITTED'  THEN

	        IF (-1*(l_old_attributes(l_bb_id).po_billable_amount) <> l_all_attributes(l_bb_id).po_billable_amount )  THEN
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                                  , module => G_LOG_MODULE
                                  , message => 'Validating old block'
                                  );
			Validate_Attributes(l_old_attributes(l_bb_id), l_messages);
		ELSE
			/* bug 13850458 Null assignment check for old attributes */
			IF l_old_attributes(l_bb_id).po_line_id IS NOT NULL THEN
				IF NOT(get_po_line(l_old_attributes(l_bb_id).po_line_id).closed_code = 'FINALLY CLOSED' OR
				   (NVL(FND_PROFILE.value('RCV_CLOSED_PO_DEFAULT_OPTION'), 'N')<> 'Y' AND
				   get_po_line(l_old_attributes(l_bb_id).po_line_id).closed_code IN ('CLOSED','CLOSED FOR RECEIVING')))  THEN
					RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
					                    , module => G_LOG_MODULE
							    , message => 'Validating old block'
							  );
					Validate_Attributes(l_old_attributes(l_bb_id), l_messages);
				END IF;
			/* bug 13850458 Validation required if old block has been changed
			and old PO attributes were null */
			ELSIF ( l_all_attributes(l_bb_id).detail_changed = 'Y' AND
			        l_all_attributes(l_bb_id).detail_deleted = 'N') THEN
					RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
					                    , module => l_log_head
							    , message => 'Validating old block'
							  );
					Validate_Attributes(l_old_attributes(l_bb_id), l_messages);
			END IF;
		END IF;
	    ELSE
		-- ignore blocks that have not been submitted
		-- and blocks that have not changed
		l_old_attributes(l_bb_id).validation_status := 'SKIPPED';
	    END IF;

	    -- validate the new attributes if block is not deleted and old block is good/irrelevant
	    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
	                        , module => l_log_head
				, message => 'l_old_attributes(l_bb_id).validation_status'
				||l_old_attributes(l_bb_id).validation_status
		              );
	    IF l_all_attributes(l_bb_id).detail_new = 'Y' OR
	       l_all_attributes(l_bb_id).detail_deleted = 'N' AND
	       l_old_attributes(l_bb_id).validation_status IN ('SUCCESS','SKIPPED') THEN

	               --Bug 18702989
		       --Added NVL clause as for new blocks, the l_old_attributes would be null.
			IF (-1*(nvl(l_old_attributes(l_bb_id).po_billable_amount,0)) <> nvl(l_all_attributes(l_bb_id).po_billable_amount,0) ) THEN
				RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
				                     , module => l_log_head
						     , message => 'Validating new block'
						  );
				Validate_Attributes(l_all_attributes(l_bb_id), l_messages);
			ELSE
				/* bug 13850458 Null assignment check for old attributes */
				IF l_old_attributes(l_bb_id).po_line_id IS NOT NULL THEN
					IF NOT(get_po_line(l_old_attributes(l_bb_id).po_line_id).closed_code = 'FINALLY CLOSED' OR
					       (NVL(FND_PROFILE.value('RCV_CLOSED_PO_DEFAULT_OPTION'), 'N')<> 'Y' AND
					       get_po_line(l_old_attributes(l_bb_id).po_line_id).closed_code IN ('CLOSED','CLOSED FOR RECEIVING'))) THEN
							RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
							                    , module => l_log_head
									    , message => 'Validating new block'
									   );
							Validate_Attributes(l_all_attributes(l_bb_id), l_messages);
					END IF;
				/* bug 13850458 Validation required if old block has been changed
				and old PO attributes were null */
				ELSIF ( l_all_attributes(l_bb_id).detail_changed = 'Y' AND
				        l_all_attributes(l_bb_id).detail_deleted = 'N') THEN
						RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
						                    , module => l_log_head
								    , message => 'Validating new block'
								  );
						Validate_Attributes(l_all_attributes(l_bb_id), l_messages);
				END IF;
			END IF;
	    END IF;
	    /* Fix for bug 11678258 ends */

	    /* Bug 5394967
	    * When user deletes, the flags detail_changed will be 'N', detail_new will be 'Y'
	    * detail_deleted will be 'Y'. We do not handle this case. We did not call the
	    * validate_attributes and because of this, we were deleting the timecards even
	    * if it is in a state where it should not be deleted. Added the following
	    * code to call the procedure that will validate the timecard before deleting it.
	    */

            IF l_all_attributes(l_bb_id).detail_new = 'N' AND
               ( l_all_attributes(l_bb_id).detail_changed = 'N' AND
                 l_all_attributes(l_bb_id).detail_deleted = 'Y'
               ) THEN
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
			                    , module => l_log_head
					    , message => 'Validating block that is deleted '||l_all_attributes(l_bb_id).old_block
					  );
			Validate_Attributes(l_all_attributes(l_bb_id), l_messages);
	    END IF;

	    /* bug 13850458 When an old block was in ERROR status, but updated
	    now. Need to validate the new block with all values. */
	    IF l_all_attributes(l_bb_id).detail_new = 'N' AND
	       ( l_all_attributes(l_bb_id).detail_changed = 'Y' AND
  	         l_all_attributes(l_bb_id).detail_deleted = 'N' AND
		 l_old_attributes(l_bb_id).validation_status IN ('ERROR')) THEN
			RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
					    , module => l_log_head
					    , message => 'Validating block that errored earlier'
					  );
			Validate_Attributes(l_all_attributes(l_bb_id), l_messages);
	    END IF;
	END IF;
    END LOOP;
    g_error_raised_flag := 0;--Bug:5559915

    -- validate the amount tolerances
    Validate_Amount_Tolerances(l_messages);

    -- set time information
    HXC_INTEGRATION_LAYER_V1_GRP.set_app_hook_params(
                                  p_building_blocks => l_blocks,
                                  p_app_attributes => l_attributes,
                                  p_messages => l_messages);

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Validate_Timecard'
                  );

    g_validate_stop := SYSDATE;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'Cache hit rates: ' || FND_GLOBAL.local_chr(10)
                                || '    build_block:         ' || (g_build_block_calls - g_build_block_misses) || '/' || g_build_block_calls || FND_GLOBAL.local_chr(10)
                                || '    build_attribute:     ' || (g_build_attribute_calls - g_build_attribute_misses) || '/' || g_build_attribute_calls || FND_GLOBAL.local_chr(10)
                                || '    po_header:           ' || (g_po_header_calls - g_po_header_misses || '/' || g_po_header_calls) || FND_GLOBAL.local_chr(10)
                                || '    po_line:             ' || (g_po_line_calls - g_po_line_misses || '/' || g_po_line_calls) || FND_GLOBAL.local_chr(10)
                                || '    po_distribution:     ' || (g_po_distribution_calls - g_po_distribution_misses || '/' || g_po_distribution_calls) || FND_GLOBAL.local_chr(10)
                                || '    price_type_lookup:   ' || (g_price_type_lookup_calls - g_price_type_lookup_misses) || '/' || g_price_type_lookup_calls || FND_GLOBAL.local_chr(10)
                                || '    price_differentials: ' || (g_price_differentials_calls - g_price_differentials_misses) || '/' || g_price_differentials_calls || FND_GLOBAL.local_chr(10)
                                || '    assignments:         ' || (g_assignments_calls - g_assignments_misses) || '/' || g_assignments_calls || FND_GLOBAL.local_chr(10)
                                || '    rcv_transactions:    ' || (g_rcv_transactions_calls - g_rcv_transactions_misses) || '/' || g_rcv_transactions_calls || FND_GLOBAL.local_chr(10)
                                || FND_GLOBAL.local_chr(10)
                                || 'Running times: ' || FND_GLOBAL.local_chr(10)
                                || '    Update:   ' || TO_CHAR((g_update_stop - g_update_start) * 8640000, '99,999.90') || ' ms' || FND_GLOBAL.local_chr(10)
                                || '    Validate: ' || TO_CHAR((g_validate_stop - g_validate_start) * 8640000, '99,999.90') || ' ms' || FND_GLOBAL.local_chr(10)
                      );
EXCEPTION
    WHEN OTHERS THEN
        HXC_INTEGRATION_LAYER_V1_GRP.add_error_to_table( p_message_table => l_messages
                                                       , p_message_name => 'HXC_RET_UNEXPECTED_ERROR'
						       , p_message_token => 'ERR&' || 'validating timecard: ' || SQLERRM
                                                       , p_message_level => HXC_USER_TYPE_DEFINITION_GRP.c_error
                                                       , p_message_field => NULL
                                                       , p_application_short_name => 'HXC'
                                                       , p_timecard_bb_id => NULL
                                                       , p_time_attribute_id => NULL
                                                       , p_message_extent => HXC_USER_TYPE_DEFINITION_GRP.c_blk_children_extent
                                                       );

END Validate_Timecard;

PROCEDURE Validate_Block
( p_effective_date            IN DATE
, p_type                      IN VARCHAR2
, p_measure                   IN NUMBER
, p_unit_of_measure           IN VARCHAR2
, p_start_time                IN DATE
, p_stop_time                 IN DATE
, p_parent_building_block_id  IN NUMBER
, p_parent_building_block_ovn IN NUMBER
, p_scope                     IN VARCHAR2
, p_approval_style_id         IN NUMBER
, p_approval_status           IN VARCHAR2
, p_resource_id               IN NUMBER
, p_resource_type             IN VARCHAR2
, p_comment_text              IN VARCHAR2
)
IS
BEGIN
    null;
END Validate_Block;

--
-- This is the wrapper around the actual retrieval.
-- The retrieval needs to access global tables in HXC_GENERIC_RETRIEVAL
-- and the code becomes unreadable with the long references to the tables.
--
-- However, assigning the tables to local tables could be a big performance
-- impact for big retrievals, so we write a wrapper that passes the global
-- tables as NOCOPY parameters.
--
-- This way, the code can reference the local parameters, yet the tables
-- are not copied.
--
PROCEDURE Retrieve_Timecards
( errbuf               OUT NOCOPY VARCHAR2
, retcode              OUT NOCOPY VARCHAR2
, p_vendor_id          IN         NUMBER
, p_start_date         IN         VARCHAR2
, p_end_date           IN         VARCHAR2
, p_receipt_date       IN         VARCHAR2
) IS
    l_start_date               DATE;
    l_end_date                 DATE;
    l_receipt_date             DATE;
     --#Bug 6798505/6631524
    l_where_clause             VARCHAR2(1000);
    l_more_timecards           BOOLEAN := TRUE;

    GENERIC_RETRIEVAL_FAILED   EXCEPTION;
    SUCCESS_SHORT_CIRCUIT      EXCEPTION;
    l_api_name         CONSTANT varchar2(30) := 'Retrieve_Timecards';
    l_log_head                  CONSTANT VARCHAR2(100) := G_LOG_MODULE || '.'||l_api_name;
BEGIN
    -- initialize
    g_retrieval_start := SYSDATE;
    g_overall_status := 'SUCCESS';
    initialize_cache_statistics;
    initialize_timing_statistics;

    G_CONC_LOG := '';

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Begin Retrieve_Timecards'
                  );

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_STATEMENT
                  , module => l_log_head
                  , message => 'Parameters: p_vendor_id=' || p_vendor_id
                                      || ', p_start_date=' || p_start_date
                                      || ', p_end_date=' || p_end_date
                                      || ', p_receipt_date=' || p_receipt_date
                  );

    -- convert the date parameters
    l_start_date := FND_DATE.Canonical_To_Date(p_start_date);
    l_end_date := FND_DATE.Canonical_To_Date(p_end_date);
    l_receipt_date := FND_DATE.Canonical_To_Date(p_receipt_date);

     /* Bug 5713531 .Change made in where clause as po_headers and po_lines */
    -- add supplier name condition
    -- bug 6031665 : corrected the syntax error. Previously the in condition was
    -- in ("RATE", "FIXED PRICE") instead of in (''RATE'', ''FIXED PRICE'')

	-- Bug 18826163 Performance fix
	IF p_vendor_id IS NOT NULL THEN
          Add_Where_Clause( p_where_clause => l_where_clause
                        , p_new_condition => '[PO Line Id]{ IN (SELECT /*+ index(pol PO_LINES_U1) */TO_CHAR(pol.po_line_id)
                          FROM po_headers poh, po_lines pol
                          WHERE poh.po_header_id = pol.po_header_id
                            AND pol.po_line_id = to_number(att.ATTRIBUTE2)
                            AND pol.order_type_lookup_code in (''RATE'',''FIXED PRICE'')  and poh.vendor_id = '
                            || p_vendor_id || ')}');
    /* Else clause also added to impose OU specific behaviour */
    ELSE
        Add_Where_Clause( p_where_clause => l_where_clause
                        , p_new_condition => '[PO Line Id]{ IN (SELECT /*+ index(pol PO_LINES_U1) */TO_CHAR(pol.po_line_id)
			  FROM  po_lines pol
			  WHERE pol.po_line_id = to_number(att.ATTRIBUTE2)
			    AND pol.order_type_lookup_code in (''RATE'',''FIXED PRICE''))}');
    END IF;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'Calling Generic Retrieval with p_where_clause: '
                            || l_where_clause
                  );

    -- loop through the batches
    WHILE l_more_timecards LOOP
        -- call the generic retrieval package to populate global tables
        BEGIN
            g_generic_start := SYSDATE;

            HXC_INTEGRATION_LAYER_V1_GRP.Execute_Retrieval_Process(
                        P_Process          => 'Purchasing Retrieval Process',
                        P_Transaction_code => NULL,
                        P_Start_Date       => l_start_date,
                        P_End_Date         => l_end_date,
                        P_Incremental      => 'Y',
                        P_Rerun_Flag       => 'N',
                        P_Where_Clause     => l_where_clause,
                        P_Scope            => 'DAY',
                        P_Clusive          => 'EX');

            g_generic_stop := SYSDATE;
            g_generic_time := g_generic_time + (g_generic_stop - g_generic_start);
        EXCEPTION
            WHEN OTHERS THEN
                RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_EXCEPTION
                              , module => l_log_head
                              , message => 'Generic Retrieval failed: ' || SQLERRM
                              );
                IF SQLERRM like 'ORA-20001: HXC_0013_GNRET_NO_BLD_BLKS%' OR
                   SQLERRM like 'ORA-20001: HXC_0012_GNRET_NO_TIMECARDS%' THEN
                    G_CONC_LOG := G_CONC_LOG || FND_MESSAGE.get_string('PO', 'RCV_OTL_GNRET_NO_TIMECARDS')
                                             || FND_GLOBAL.local_chr(10) || FND_GLOBAL.local_chr(10);
                    RAISE SUCCESS_SHORT_CIRCUIT;
                ELSIF SQLERRM like 'ORA-20001: HXC_0017_GNRET_PROCESS_RUNNING%' THEN
                    G_CONC_LOG := G_CONC_LOG || FND_MESSAGE.get_string('PO', 'RCV_OTL_GNRET_PROCESS_RUNNING')
                                             || FND_GLOBAL.local_chr(10) || FND_GLOBAL.local_chr(10);
                END IF;

                RAISE GENERIC_RETRIEVAL_FAILED;
        END;

        g_retrieved_details := g_retrieved_details + HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.COUNT;

        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                      , module => l_log_head
                      , message => 'Returned from Generic Retrieval with '
                                || HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.COUNT
                                || ' detail blocks'
                      );

        -- are there any more timecard blocks to process?
        IF HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.COUNT > 0 THEN
            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                          , module => l_log_head
                          , message => 'Calling Retrieval Body...'
                          );

            -- call the body of the retrieval
	   -- Bug6357273
 	   -- We are calling Generic retrieval in the loop now, so there can be multiple batches in
 	   -- Retrieval program. SO now even if one batch get failed due to some error, other batches
 	   -- will executed and the summery report will be printed.
 	   BEGIN
            Retrieve_Timecards_Body( p_blocks => HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks
                                   , p_old_blocks => HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks
                                   , p_attributes => HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes
                                   , p_old_attributes => HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes
                                   , p_receipt_date => l_receipt_date
                                   );
	    EXCEPTION
 	      WHEN OTHERS THEN
 	                   RCV_HXT_GRP.string ( log_level => FND_LOG.LEVEL_UNEXPECTED , module => l_log_head , message => 'Retrieve_Timecards_Body failed. Error:'|| sqlerrm );
 	    END;

            RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                              , module => l_log_head
                              , message => 'Returned from Retrieval Body'
                              );
        ELSE
            l_more_timecards := FALSE;

            HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
                  p_process => 'Purchasing Retrieval Process'
                , p_status  => 'SUCCESS'
                , p_exception_description => 'No more rows to process'
            );
        END IF;
    END LOOP;

    g_retrieval_stop := SYSDATE;
    g_retrieval_time := g_retrieval_stop - g_retrieval_start;

    RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_PROCEDURE
                  , module => l_log_head
                  , message => 'End Retrieve_Timecards'
                  );

    IF g_failed_details > 0 THEN
        G_CONC_LOG := G_CONC_LOG || FND_MESSAGE.get_string('PO', 'RCV_OTL_RCVTP_ERROR')
                                 || FND_GLOBAL.local_chr(10) || FND_GLOBAL.local_chr(10);
    END IF;

    -- generate summary report
    G_CONC_LOG := G_CONC_LOG || 'Summary information: ' || FND_GLOBAL.local_chr(10)
                             || '    Detail blocks retrieved:  ' || g_retrieved_details || FND_GLOBAL.local_chr(10)
                             || '    Detail blocks successful: ' || g_successful_details || FND_GLOBAL.local_chr(10)
                             || '    Detail blocks failed:     ' || g_failed_details || FND_GLOBAL.local_chr(10)
                             || '    Receiving Transaction Processor request id: ' || g_req_id || FND_GLOBAL.local_chr(10)
                             || '    Receiving Transaction Processor group id: ' || g_group_id || FND_GLOBAL.local_chr(10)
                             || '    Retrieval status: ' || g_overall_status || FND_GLOBAL.local_chr(10)
                             || FND_GLOBAL.local_chr(10)
                             || 'Cache hit rates: ' || FND_GLOBAL.local_chr(10)
                             || '    build_block:         ' || (g_build_block_calls - g_build_block_misses) || '/' || g_build_block_calls || FND_GLOBAL.local_chr(10)
                             || '    build_attribute:     ' || (g_build_attribute_calls - g_build_attribute_misses) || '/' || g_build_attribute_calls || FND_GLOBAL.local_chr(10)
                             || '    po_header:           ' || (g_po_header_calls - g_po_header_misses || '/' || g_po_header_calls) || FND_GLOBAL.local_chr(10)
                             || '    po_line:             ' || (g_po_line_calls - g_po_line_misses || '/' || g_po_line_calls) || FND_GLOBAL.local_chr(10)
                             || '    po_distribution:     ' || (g_po_distribution_calls - g_po_distribution_misses || '/' || g_po_distribution_calls) || FND_GLOBAL.local_chr(10)
                             || '    price_type_lookup:   ' || (g_price_type_lookup_calls - g_price_type_lookup_misses) || '/' || g_price_type_lookup_calls || FND_GLOBAL.local_chr(10)
                             || '    price_differentials: ' || (g_price_differentials_calls - g_price_differentials_misses) || '/' || g_price_differentials_calls || FND_GLOBAL.local_chr(10)
                             || '    assignments:         ' || (g_assignments_calls - g_assignments_misses) || '/' || g_assignments_calls || FND_GLOBAL.local_chr(10)
                             || '    rcv_transactions:    ' || (g_rcv_transactions_calls - g_rcv_transactions_misses) || '/' || g_rcv_transactions_calls || FND_GLOBAL.local_chr(10)
                             || FND_GLOBAL.local_chr(10)
                             || 'Running times: ' || FND_GLOBAL.local_chr(10)
                             || '    Generic Retrieval:               ' || TO_CHAR((g_generic_time) * 8640000, '99,999.90') || ' ms' || FND_GLOBAL.local_chr(10)
                             || '    Receiving Transaction Processor: ' || TO_CHAR((g_receiving_time) * 8640000, '99,999.90') || ' ms' || FND_GLOBAL.local_chr(10)
                             || '    Retrieval:                       '
                             || TO_CHAR(((g_retrieval_time) - (g_generic_time) - (g_receiving_time)) * 8640000, '99,999.90')
                             || ' ms' || FND_GLOBAL.local_chr(10);

    -- send output to concurrent log
    errbuf := G_CONC_LOG;
    IF g_failed_details > 0 THEN
        retcode := 1;
    ELSE
        retcode := 0;
    END IF;

EXCEPTION
    WHEN SUCCESS_SHORT_CIRCUIT THEN
        errbuf := G_CONC_LOG;
        retcode := 0;
	-- 13612527: Updating Transaction status to ERRORS which allows other request to run.
	HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
          p_process => 'Purchasing Retrieval Process'
        , p_status  => 'ERRORS'
        , p_exception_description => G_CONC_LOG
        );
    WHEN GENERIC_RETRIEVAL_FAILED THEN
        errbuf := G_CONC_LOG;
        retcode := 2;
	-- 13612527: Updating Transaction status to ERRORS which allows other request to run.
	HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
          p_process => 'Purchasing Retrieval Process'
        , p_status  => 'ERRORS'
        , p_exception_description => G_CONC_LOG
        );
    WHEN OTHERS THEN
        RCV_HXT_GRP.string( log_level => FND_LOG.LEVEL_UNEXPECTED
                      , module => l_log_head
                      , message => 'Unexpected exception in RCV_HXT_GRP.Retrieve_Timecards: ' || SQLERRM
                      );
        errbuf := G_CONC_LOG;
        retcode := 2;
	-- 13612527: Updating Transaction status to ERRORS which allows other request to run.
	HXC_INTEGRATION_LAYER_V1_GRP.update_transaction_status (
          p_process => 'Purchasing Retrieval Process'
        , p_status  => 'ERRORS'
        , p_exception_description => G_CONC_LOG
        );
END;

END RCV_HXT_GRP;


/
