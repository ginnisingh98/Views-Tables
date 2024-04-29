--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_CREATE_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_CREATE_PO_PKG" as
/* $Header: PONCRPOB.pls 120.41.12010000.7 2014/07/22 11:53:00 gkuncham ship $ */

g_fnd_debug 		CONSTANT VARCHAR2(1)   := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module 		CONSTANT VARCHAR2(50) := 'pon.plsql.pon_auction_create_po_pkg';

---------Variables---------------------
PO_SUCCESS NUMBER := 1;
DUPLICATE_PO_NUMBER NUMBER := 2;
PO_SYSTEM_ERROR NUMBER := 3;
SOURCING_SYSTEM_ERROR NUMBER := 4;
PO_PDOI_ERROR NUMBER := 5;
PO_DELETE_ERROR NUMBER :=6;

-------------------------------------------------------------------------------
--------------------------  PACKAGE BODY --------------------------------------
-------------------------------------------------------------------------------

PROCEDURE log_message(p_message  IN    VARCHAR2) IS
BEGIN
   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module,
                        message  => substr(p_message, 0, 4000));
      END IF;
   END IF;
END;

PROCEDURE log_error(p_message  IN    VARCHAR2) IS
BEGIN
   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_unexpected,
                        module  =>  g_module,
                        message  => substr(p_message, 0, 4000));
      END IF;
   END IF;
END;


---------------------------------------------------------------------------
--This procedure is called by the "Auto-Allocation of non-allocated items
--and Split requisition" activity node of the PONCOMPL (Sourcing Complete
--Auction) Workflow.
--It calls ALLOC_ALL_UNALLOC_ITEMS to allocate all unallocated items.
--It also populates PO's interface table with the appropriate award and
--req info and calls PO's Split Requisition API, which populates the same
--table with the new, split req ids
----------------------------------------------------------------------------

procedure AUTO_ALLOC_AND_SPLIT_REQ(p_auction_header_id           IN    NUMBER,       -- 1
                            p_user_name                   IN    VARCHAR2,     -- 2
                            p_user_id                     IN    NUMBER,       -- 3
                            p_formatted_name              IN    VARCHAR2,     -- 4
                            p_auction_title               IN    VARCHAR2,     -- 5
                            p_organization_name           IN    VARCHAR2,
			    p_resultout			  OUT NOCOPY VARCHAR2,
			    x_allocation_error		  OUT NOCOPY VARCHAR2,
			    x_line_number		  OUT NOCOPY NUMBER,
			    x_item_number		  OUT NOCOPY VARCHAR2,
			    x_item_description		  OUT NOCOPY VARCHAR2,
			    x_item_revision		  OUT NOCOPY VARCHAR2,
			    x_requisition_number	  OUT NOCOPY VARCHAR2,
			    x_job_name			  OUT NOCOPY VARCHAR2,
			    x_document_disp_line_number	  OUT NOCOPY VARCHAR2) IS

x_item 				VARCHAR2(50);
x_allocation_result 		VARCHAR2(10);
x_failure_status 		VARCHAR2(10);
x_alloc_failure_reason 		VARCHAR2(2000);
x_source_reqs_flag 		VARCHAR2(1);
x_contract_type 		VARCHAR2(10);
x_split_result 			VARCHAR2(10);
x_split_failure_reason 		VARCHAR2(2000);
x_split_failed_req_number 	NUMBER;
x_return_error_code 		VARCHAR2(10);

x_responsibility_id     	number       := null;
x_application_id        	number       := null;

x_language_code 		VARCHAR2(3);
x_last_update_date 		pon_auction_headers_all.last_update_date%TYPE;
x_progress 			FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
x_origination_code 		pon_auction_headers_all.auction_origination_code%TYPE;
x_return_code 			VARCHAR2(10);

l_api_name			VARCHAR2(30)	:= ' AUTO_ALLOC_AND_SPLIT_REQ';
l_debug_enabled			VARCHAR2(1)	:= 'N';
l_exception_enabled		VARCHAR2(1)	:= 'N';
l_progress			NUMBER		:= 0;

BEGIN

    /* perform initialization for FND logging */
    if(g_fnd_debug = 'Y') then

	if (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) then
		l_debug_enabled := 'Y';
	end if;

	IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) then
		l_exception_enabled := 'Y';
	end if;

    end if;

    if(l_debug_enabled = 'Y') then

	x_progress := ++l_progress || l_api_name || ' : BEGIN :';

	log_message(x_progress);

	x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : ' || p_auction_header_id
				   || '  ' || p_user_name || '  ' || p_user_id || '  '
				|| p_formatted_name || ' ' || p_auction_title || ' '
				|| p_organization_name;
	log_message(x_progress);

     end if;

     -- establish savepoint so that if an exception occurs during either
     -- the auto-allocation or the splitting of requisition, no data inserted
     -- when auto-allocating will get committed to db

     --savepoint PON_BEFORE_AUTO_ALLOC;

     -- basic initialization
     x_failure_status := 'SUCCESS';
     p_resultout := 'SUCCESS';


    FND_PROFILE.GET('RESP_ID', x_responsibility_id);

    FND_PROFILE.GET('RESP_APPL_ID', x_application_id);

    fnd_global.APPS_INITIALIZE (p_user_id, x_responsibility_id, x_application_id);
    --bug 5245568; need to call init to intialize MOAC
    mo_global.init('PON');

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : after retrieving resp_id and resp_appl_id';
	log_message(x_progress);
     end if;


     -- set the session's language so that calls to getMessage would
     -- return the correct message in user's language

     PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_user_name, x_language_code);

     PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, x_language_code);

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : after retrieving language code, etc';
	log_message(x_progress);
     end if;

     -- Lock auction table to prevent concurrency errors

     SELECT last_update_date
     INTO   x_last_update_date
     FROM   pon_auction_headers_all
     WHERE  auction_header_id = p_auction_header_id
     FOR UPDATE;

     -- Determine whether we are sourcing requisition lines against the
     -- blanket agreements. In the case of a blanket agreement, if we are
     -- not, do not automatically allocate or call po's split api

     SELECT nvl(source_reqs_flag,'N'), contract_type, nvl(auction_origination_code, 'NONE')
     into x_source_reqs_flag, x_contract_type, x_origination_code
     FROM pon_auction_headers_all
     where auction_header_id = p_auction_header_id;


    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name;
	log_message(x_progress);
     end if;

     IF (x_origination_code = 'REQUISITION' AND
        ((x_contract_type = 'BLANKET' AND x_source_reqs_flag = 'Y')  OR
          x_contract_type = 'STANDARD')) THEN

     	-- Call procedure to automatically allocate unallocated items
     	ALLOC_ALL_UNALLOC_ITEMS (p_auction_header_id,
                                                          x_allocation_result,
                                                          x_alloc_failure_reason,
                                                          x_line_number,
                                                          x_item_number,
                                                          x_item_description,
                                                          x_item_revision,
                                                          x_requisition_number,
                                                          x_job_name,
                                                          x_document_disp_line_number);

       	IF (x_allocation_result = 'FAILURE') THEN

    	if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' failure after auto_alloc_and_split_req';
		log_message(x_progress);
     	end if;

           x_failure_status := 'FAILURE';
           -- setting failure reason and item line on which allocation failure
           -- occurred;
	   -- assigning error to x_allocation_error variable to be accessed after rollback to savepoint PON_BEFORE_AUTO_ALLOC
	   x_allocation_error := x_alloc_failure_reason;
       	ELSE

    	if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : now invoking split_req_lines for auction ' || p_auction_header_id;
		log_message(x_progress);
     	end if;

           -- Call procedure to split req lines and update
           -- pon_award_allocations with split_req_id

           SPLIT_REQ_LINES(p_auction_header_id,
                                                    x_split_result,
                                                    x_split_failure_reason,
						    x_line_number,
                                                    x_item_number,
                                                    x_item_description,
                                                    x_item_revision,
                                                    x_requisition_number,
                                                    x_job_name);

           IF (x_split_result = 'FAILURE') THEN

    		if(l_debug_enabled = 'Y') then
			x_progress := ++l_progress || l_api_name || ' : split_req_lines resulted in error for '
					|| p_auction_header_id;
			log_message(x_progress);
	     	end if;

             x_failure_status := 'FAILURE';

             -- setting failure reason and item line and req line on which
             -- split failure occurred
             -- assigning error to x_allocation_error variable to be accessed
	     -- after rollback to savepoint PON_BEFORE_AUTO_ALLOC
	     x_allocation_error := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SPLIT_ERROR') || ' - ' || x_split_failure_reason;

    	     if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : alloc_error reported is  '
					|| x_allocation_error;
		log_message(x_progress);
	     end if;

             END IF;
        END IF;
     END IF; -- end of automatic allocation and splitting

     IF (x_failure_status = 'SUCCESS') THEN

    	     if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : so far things are successful  ' ;
		log_message(x_progress);
	     end if;

        IF (x_origination_code = 'REQUISITION') THEN
          -- return req back to the pool for negotiation

    	     if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : invoking cancel_negotiation_ref for auction  ' || p_auction_header_id;
		log_message(x_progress);
	     end if;

          PON_AUCTION_PKG.cancel_negotiation_ref(p_auction_header_id, x_return_code);
          IF (x_return_code = 'SUCCESS') THEN

    	     if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : successful cancel_negotiation_ref for auction  ' || p_auction_header_id;
		log_message(x_progress);
	     end if;
            p_resultout := 'SUCCESS';

          ELSE
    	     if(l_exception_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : failure cancel_negotiation_ref for auction  ' || p_auction_header_id;
		log_error(x_progress);
	     end if;

            x_failure_status := 'FAILURE';
            -- assigning error to x_allocation_error variable to be accessed
	    x_allocation_error := PON_AUCTION_PKG.getMessage('PON_AUC_WF_ALLOC_ERROR');

          END IF;
        END IF;
     END IF;

     IF (x_failure_status = 'FAILURE') THEN

    	     if(l_exception_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : failure for auction  ' || p_auction_header_id;
		log_error(x_progress);
	     end if;


        p_resultout := 'FAILURE';

        -- call new procedure which sets attributes to generate failure e-mail
        -- if fails, rollback to save point prior to auto allocation
	-- double check the setting of alloc_error below


        -- update outcome_status of auction
        UPDATE PON_AUCTION_HEADERS_ALL
        SET OUTCOME_STATUS = 'ALLOCATION_FAILED'
        WHERE AUCTION_HEADER_ID = p_auction_header_id;

    	if(l_exception_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : update outcome_status for  auction  ' || p_auction_header_id;
	  log_error(x_progress);
	end if;

     END IF;

     PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

     if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END' ;
	log_message(x_progress);
     end if;

EXCEPTION
     when others then

    	if(l_exception_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : exception for  auction  ' || p_auction_header_id;
	  log_error(x_progress);
	end if;

        p_resultout := 'FAILURE';

    	if(l_exception_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : set output to failure for auction  ' || p_auction_header_id;
	  log_error(x_progress);
	end if;

	x_allocation_error := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || substrb(SQLERRM, 1, 500);

    	if(l_exception_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : for auction  ' || p_auction_header_id || ' error:: ' || x_allocation_error;
	  log_error(x_progress);
	end if;

        -- update outcome_status of auction
        UPDATE PON_AUCTION_HEADERS_ALL
        SET OUTCOME_STATUS = 'ALLOCATION_FAILED'
        WHERE AUCTION_HEADER_ID = p_auction_header_id;

    	if(l_exception_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : EXCEPTION END';
	  log_error(x_progress);
	end if;

END AUTO_ALLOC_AND_SPLIT_REQ;

----------------------------------------------------------------------
-- This procedure takes in an auction header id and calls
-- PON_AUCTION_CREATEPO_PKG.AUTO_REQ_ALLOCATION on all unallocated,
-- completed items that have awarded bids in this auction, and return a
-- 'success' or 'failure' as the allocation result, as well as the failure
-- reason if it failed.
-----------------------------------------------------------------------


procedure ALLOC_ALL_UNALLOC_ITEMS(p_auction_header_id  IN NUMBER,
                                  p_allocation_result  OUT NOCOPY VARCHAR2,
                                  p_failure_reason     OUT NOCOPY VARCHAR2,
                                  p_item_line_number   OUT NOCOPY NUMBER,
                                  p_item_number        OUT NOCOPY VARCHAR2,
                                  p_item_description   OUT NOCOPY VARCHAR2,
                                  p_item_revision      OUT NOCOPY VARCHAR2,
                                  p_requisition_number OUT NOCOPY VARCHAR2,
                                  p_job_name           OUT NOCOPY VARCHAR2,
                                  p_document_disp_line_number OUT NOCOPY VARCHAR2) IS

x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
x_result VARCHAR2(10);
x_error_message VARCHAR2(1000);

-- unallocatedItems are items that have awarded bids that have yet to be
-- allocated
CURSOR unallocatedItems IS
   SELECT distinct itm.line_number
   FROM pon_auction_item_prices_all itm,
        po_req_lines_in_pool_src_v prlv
   WHERE itm.auction_header_id = p_auction_header_id AND
         nvl(itm.line_origination_code, 'NONE') =  'REQUISITION' AND
         nvl(itm.allocation_status, 'NO') <> 'ALLOCATED' AND
         nvl(itm.award_status, 'NO') = 'COMPLETED' AND
         nvl(itm.awarded_quantity, -99) > 0 AND
         itm.auction_header_id = prlv.auction_header_id AND
         itm.line_number = prlv.auction_line_number;

-- The following cursor is to select line related info to be printed in the
-- Allocation Failure notification, if line fails to be auto-allocated.
CURSOR wf_item_cur (p_auction_header_id NUMBER, p_line_number NUMBER) IS
   SELECT itm.document_disp_line_number, itm.item_number, itm.item_revision, itm.item_description,
          itm.requisition_number, pjo.name
   FROM pon_auction_item_prices_all itm,
        per_jobs pjo
   WHERE itm.auction_header_id = p_auction_header_id AND
         itm.line_number = p_line_number AND
         pjo.job_id (+) = itm.job_id;

l_api_name			VARCHAR2(30)	:= ' ALLOC_ALL_UNALLOC_ITEMS ';
l_debug_enabled			VARCHAR2(1)	:= 'N';
l_exception_enabled		VARCHAR2(1)	:= 'N';
l_progress			NUMBER		:= 0;

BEGIN

    /* perform initialization for FND logging */
    if(g_fnd_debug = 'Y') then

	if (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) then
		l_debug_enabled := 'Y';
	end if;

	IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) then
		l_exception_enabled := 'Y';
	end if;

    end if;

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	log_message(x_progress);
	x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : ' || p_auction_header_id;
	log_message(x_progress);
     end if;

     OPEN unallocatedItems;
     LOOP
        FETCH unallocatedItems into p_item_line_number;
      	EXIT WHEN unallocatedItems%NOTFOUND;
      	-- call procedure to automatically allocate for a particular item

     	if(l_debug_enabled = 'Y') then
	    x_progress := ++l_progress || l_api_name || ' : invoke auto_req_allocation  :';
	    log_message(x_progress);
	end if;

        AUTO_REQ_ALLOCATION(p_auction_header_id,
                            p_item_line_number,
                            x_result,
                            x_error_message);

        IF (x_result = 'FAILURE') THEN

           p_allocation_result := 'FAILURE';
           p_failure_reason := x_error_message;

     	   if(l_exception_enabled = 'Y') then
	       x_progress := ++l_progress || l_api_name || ' : failure after auto_req_allocation  :' || x_error_message;
	       log_error(x_progress);
	   end if;

           -- Fetch the item_number, item_revision, item_description,
		   -- requisition_number and job_name values for a given line_number.
           OPEN wf_item_cur (p_auction_header_id, p_item_line_number);
           FETCH wf_item_cur INTO p_document_disp_line_number,p_item_number, p_item_revision, p_item_description,
                                  p_requisition_number, p_job_name;
           CLOSE wf_item_cur;

           RETURN;
      	ELSE
           -- update allocation status of item to allocated if allocation succeeded

           UPDATE pon_auction_item_prices_all
           SET allocation_status = 'ALLOCATED'
           WHERE auction_header_id = p_auction_header_id and
                 line_number =  p_item_line_number;
        END IF;
     END LOOP;
     p_allocation_result := 'SUCCESS';

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : END :' || p_auction_header_id;
	log_message(x_progress);
    end if;



EXCEPTION
    WHEN OTHERS THEN

       p_allocation_result := 'FAILURE';

      if(l_exception_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' :EXCEPTION :' || p_auction_header_id;
	log_error(x_progress);
      end if;


       IF p_item_line_number IS NULL THEN -- -- it means the exception was thrown before line information is selected
          p_failure_reason := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || SUBSTRB(SQLERRM, 1, 500) || PON_AUCTION_PKG.getMessage('PON_LINE_INFO_NOT_AVAIL');
       ELSE
          p_failure_reason := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || SUBSTRB(SQLERRM, 1, 500);
       END IF;

      if(l_exception_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' :EXCEPTION :' || p_failure_reason;
	log_error(x_progress);
      end if;

       RAISE;

END ALLOC_ALL_UNALLOC_ITEMS;



PROCEDURE SPLIT_REQ_LINES(p_auction_header_id    IN NUMBER,
                          p_split_result         OUT NOCOPY VARCHAR2,
                          p_split_failure_reason OUT NOCOPY VARCHAR2,
			  p_item_line_number     OUT NOCOPY NUMBER,
                          p_item_number          OUT NOCOPY VARCHAR2,
                          p_item_description     OUT NOCOPY VARCHAR2,
                          p_item_revision        OUT NOCOPY VARCHAR2,
                          p_requisition_number   OUT NOCOPY VARCHAR2,
                          p_job_name             OUT NOCOPY VARCHAR2) IS

l_split_error_code VARCHAR2(10);
l_orig_req_line NUMBER;
l_req_qty NUMBER;
l_num_messages NUMBER;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_req_line_id_col dbms_sql.number_table;
lock_not_acquired EXCEPTION;
l_user_id NUMBER;

PRAGMA EXCEPTION_INIT(lock_not_acquired, -54);

-- cursor picks up all req lines allocated to a single supplier where mrp
-- rescheduling has rescheduled the req quantity to a value lower than
-- the alloc quantity
CURSOR reqRescheduledSingleSupplier IS
       SELECT paa.orig_req_line_id, prlsv.requisition_quantity
       FROM pon_award_allocations paa, po_req_lines_in_pool_src_v prlsv,
	    pon_auction_item_prices_all paip
       WHERE paa.allocated_qty > prlsv.requisition_quantity AND
             paa.auction_header_id = p_auction_header_id AND
             nvl(paa.split_req_line_id, -999)= -999 AND
             nvl(paa.allocated_qty,0) > 0 AND
             prlsv.requisition_line_id = paa.orig_req_line_id AND
	     prlsv.requisition_header_id = paa.orig_req_header_id AND
	     paip.auction_header_id = paa.auction_header_id AND
	     paip.line_number = paa.bid_line_number AND
	     paip.order_type_lookup_code IN ('AMOUNT', 'QUANTITY')
       GROUP BY paa.orig_req_line_id, prlsv.requisition_quantity
       HAVING COUNT(distinct bid_number) = 1;

-- cursor picks up all req lines allocated to multiple suppliers in
-- which the req qty is lower than the allocated qty as a result
-- of mrp rescheduling
CURSOR reqRescheduledMultSupplier IS
       SELECT paa.orig_req_line_id
       FROM pon_award_allocations paa, po_req_lines_in_pool_src_v prlsv,
	    pon_auction_item_prices_all paip
       WHERE paa.auction_header_id = p_auction_header_id AND
             nvl(paa.split_req_line_id, -999)= -999 AND
             nvl(paa.allocated_qty,0) > 0 AND
             prlsv.requisition_line_id = paa.orig_req_line_id AND
	     prlsv.requisition_header_id = paa.orig_req_header_id   AND
	     paip.auction_header_id = paa.auction_header_id AND
	     paip.line_number = paa.bid_line_number AND
	     paip.order_type_lookup_code IN ('AMOUNT', 'QUANTITY')
       GROUP BY paa.orig_req_line_id
       HAVING SUM (nvl(paa.allocated_qty,0)) > max(prlsv.requisition_quantity)
              AND COUNT(distinct bid_number) > 1;

-- The following cursor is to select line related info to be printed in the
-- Allocation Failure notification, if line fails to be auto-allocated.
  CURSOR wf_item_cur (p_auction_header_id NUMBER, p_orig_req_line_id NUMBER) IS
   SELECT distinct paa.bid_line_number, itm.item_number, itm.item_revision, itm.item_description,
          itm.requisition_number, pjo.name
   FROM pon_auction_item_prices_all itm,
        per_jobs pjo,
        pon_award_allocations paa
   WHERE paa.auction_header_id = itm.auction_header_id AND
         paa.bid_line_number = itm.line_number AND
         paa.orig_req_line_id = p_orig_req_line_id AND
         itm.auction_header_id = p_auction_header_id AND
         pjo.job_id (+) = itm.job_id;

l_api_name			VARCHAR2(30)	:= ' SPLIT_REQ_LINES ';
l_debug_enabled			VARCHAR2(1)	:= 'N';
l_exception_enabled		VARCHAR2(1)	:= 'N';
l_progress			NUMBER		:= 0;


BEGIN

    /* perform initialization for FND logging */
    if(g_fnd_debug = 'Y') then

	if (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) then
		l_debug_enabled := 'Y';
	end if;

	IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) then
		l_exception_enabled := 'Y';
	end if;

    end if;

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	log_message(x_progress);
	x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : ' || p_auction_header_id;
	log_message(x_progress);
     end if;


     p_split_result := 'SUCCESS';


/*
rrkulkar-large-auction-support :- need to pass USER_ID

out-params-setitemattr

     l_user_id := wf_engine.GetItemAttrNumber (itemtype   => itemtype,
                                               itemkey    => itemkey,
                                               aname      => 'USER_ID');

*/



     -- get lock on all backing reqs for a negotiation.  If it cannot
     -- be locked, try 20 rtimes, then set result to failure and
     -- set appropriate error message before returning and exiting procedure
     FOR l_index IN 1..20 LOOP
        BEGIN
          SELECT requisition_line_id
          BULK COLLECT INTO l_req_line_id_col
          FROM po_requisition_lines_all
          WHERE auction_header_id = p_auction_header_id
          FOR UPDATE NOWAIT;
          EXIT;
        EXCEPTION
          WHEN lock_not_acquired THEN
            IF l_index >= 20 THEN
              p_split_failure_reason := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SPLIT_ERROR') || ' - ' || PON_AUCTION_PKG.getMessage('PON_AUC_CANNOT_GET_LOCK') || PON_AUCTION_PKG.getMessage('PON_LINE_INFO_NOT_AVAIL');
              p_split_result := 'FAILURE';

              RETURN;
            END IF;
        END;
     END LOOP;

     IF (p_split_result = 'SUCCESS') THEN
        -- if any req line allocated to multiple suppliers has been rescheduled
        -- fail the process and include failure reason in e-mail
        OPEN reqRescheduledMultSupplier;
        LOOP
          FETCH reqRescheduledMultSupplier
          INTO l_orig_req_line;
          EXIT WHEN reqRescheduledMultSupplier%NOTFOUND;

          p_split_result := 'FAILURE';
          --p_split_failed_req := l_orig_req_line;
          p_split_failure_reason := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SPLIT_ERROR') || ' - ' || PON_AUCTION_PKG.getMessage('PON_AUC_WF_REQ_RESCHEDULED');

           -- Fetch the line_number, item_number, item_revision, item_description,
           -- requisition_number and job_name values for a given line_number.
           OPEN wf_item_cur (p_auction_header_id, l_orig_req_line);
           FETCH wf_item_cur INTO p_item_line_number, p_item_number, p_item_revision, p_item_description,
                                  p_requisition_number, p_job_name;
           CLOSE wf_item_cur;

		END LOOP;
        CLOSE reqRescheduledMultSupplier;
     END IF;

     IF (p_split_result = 'SUCCESS') THEN

    	if(l_debug_enabled = 'Y') then
	   x_progress := ++l_progress || l_api_name || ' : SUCCESS in split_result so far:';
           log_message(x_progress);
	end if;

        -- if req line allocated to single supplier has been rescheduled
        -- simply decrease allocated qty to new req qty

        OPEN reqRescheduledSingleSupplier;
        LOOP

    	  if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : looping over reqRescheduledSingleSupplier:';
             log_message(x_progress);
	  end if;

          FETCH reqRescheduledSingleSupplier
          INTO l_orig_req_line, l_req_qty;
          EXIT WHEN reqRescheduledSingleSupplier%NOTFOUND;

          UPDATE PON_AWARD_ALLOCATIONS
          SET allocated_qty = l_req_qty,
              last_update_date = sysdate,
              last_updated_by = l_user_id
          WHERE orig_req_line_id = l_orig_req_line;

        END LOOP;
        CLOSE reqRescheduledSingleSupplier;

        -- Insert values into po's split temp global table
        INSERT INTO po_req_split_lines_GT (
             auction_header_id,
             bid_number,
             bid_line_number,
             requisition_header_id,
             requisition_line_id,
             allocated_qty
        )
        SELECT paa.auction_header_id,
               paa.bid_number,
               paa.bid_line_number,
               paa.orig_req_header_id,
               paa.orig_req_line_id,
               paa.allocated_qty
        FROM pon_award_allocations paa
        WHERE paa.auction_header_id = p_auction_header_id AND
              nvl(paa.split_req_line_id, -999)= -999 AND
              nvl(paa.allocated_qty,0) > 0;

	-- DEBUG CODE
	-- INSERT INTO po_req_split_lines_gt_debug (SELECT * FROM po_req_split_lines_gt WHERE auction_header_id = p_auction_header_id);

    	  if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : invoke po_negotiations4_grp.split_requisitionlines :';
             log_message(x_progress);
	  end if;

        -- calling PO's split req api
        -- passing in api_version, init_msg_list, commit_data,
        -- auction_header_id
        -- registering out result, error, num_msgs, error_msg, failed req
	-- bug 3955102 - invoke API by names, not index
        PO_NEGOTIATIONS4_GRP.Split_RequisitionLines(
	P_API_VERSION		=>	1.0,
	P_INIT_MSG_LIST		=>	FND_API.G_FALSE,
	P_COMMIT		=>	FND_API.G_FALSE,
	X_RETURN_STATUS		=>	p_split_result,
	X_MSG_COUNT		=>	l_num_messages,
	X_MSG_DATA		=>	p_split_failure_reason,
	P_AUCTION_HEADER_ID	=>	p_auction_header_id);


    	if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : return from po_negotiations4_grp.split_requisitionlines :' || p_split_failure_reason;
             log_message(x_progress);
	end if;

     END IF;

     -- If successful, insert values back into sourcing's table
     --
     IF (p_split_result = FND_API.G_RET_STS_SUCCESS) THEN

    	if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : p_split_result is successful :';
             log_message(x_progress);
	end if;

        UPDATE PON_AWARD_ALLOCATIONS PAA
        SET split_req_line_id=
        (select new_req_line_id
         from po_req_split_lines_gt prlst
         where prlst.requisition_line_id = PAA.orig_req_line_id
              and  prlst.auction_header_id =  PAA.auction_header_id
              and  prlst.bid_number  =  PAA.bid_number
              and  prlst.bid_line_number  =  PAA.bid_line_number
              and  prlst.record_status in ('S', 'E', 'T')),
              -- status in s and e means newly split lines and lines
              -- with equal allocation
            last_update_date = sysdate,
            last_updated_by = l_user_id
        WHERE PAA.auction_header_id = p_auction_header_id AND
              nvl(paa.split_req_line_id, -999)= -999 AND
              nvl(paa.allocated_qty,0) > 0;

    	if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : after updating pon_award_allocations with split_req_line_id :';
             log_message(x_progress);
	end if;


        p_split_result := 'SUCCESS';

     -- If unsuccessful, determine the item number on which the split
     -- req failed based on the failed req number
     ELSE

    	if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : not successful so far :' || p_split_result;
             log_message(x_progress);
	end if;

         -- bug 3537686: if there is a message to be returned,
         -- po populates the message w/ encoded instead of decoded message.
         -- Here, we will retrieve the last error message to display to user.
         -- in decoded format

         IF (l_num_messages  > 0) THEN
           p_split_failure_reason := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST, FND_API.G_FALSE);
         END IF;

         -- if unexpected error, append the text 'Unexpected System Error' to
         -- error message
         IF (p_split_result = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           p_split_failure_reason :=  PON_AUCTION_PKG.getMessage('PON_UNEXPECTED_ERROR') || ': ' || p_split_failure_reason;
         END IF;

         p_split_result := 'FAILURE';

    	if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : failure :' || p_split_failure_reason ;
             log_message(x_progress);
	end if;

        -- Fetch the line_number, item_number, item_revision, item_description,
        -- requisition_number and job_name values for a given line_number.
        OPEN wf_item_cur (p_auction_header_id, l_orig_req_line);
        FETCH wf_item_cur INTO p_item_line_number, p_item_number, p_item_revision, p_item_description,
                               p_requisition_number, p_job_name;
        CLOSE wf_item_cur;

     END IF;

     if(l_debug_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : END  :';
             log_message(x_progress);
     end if;


EXCEPTION
WHEN OTHERS THEN
       p_split_result := 'FAILURE';

     if(l_exception_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : EXCEPTION  :';
             log_error(x_progress);
     end if;


       IF p_item_line_number IS NULL THEN -- -- it means the exception was thrown before line information is selected
          p_split_failure_reason := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || SUBSTRB(SQLERRM, 1, 500) || PON_AUCTION_PKG.getMessage('PON_LINE_INFO_NOT_AVAIL');
       ELSE
          p_split_failure_reason := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || SUBSTRB(SQLERRM, 1, 500);
       END IF;

     if(l_exception_enabled = 'Y') then
	     x_progress := ++l_progress || l_api_name || ' : EXCEPTION  with reason :' || p_split_failure_reason;
             log_error(x_progress);
     end if;

     RAISE;

END SPLIT_REQ_LINES;

-- This procedure allocates the award quantity across the backing requisition
-- distributions for a particular item.  It does this by ordering the
-- requisition distributions and Awarded Suppliers in a predetermined way and
-- then fulfilling the requisition demand one by one with the supplier's award
-- quantity in a FIFO manner. The ordering is as follows. Requisitions are
-- ordered by need_by_date ascending, then creation_date ascending. Awarded
-- Suppliers are ordered by promise date ascending, awarded quantity
-- descending, bid price ascending, then bid number ascending for standard
-- purchase orders.  In the case of blanket agreements, promise
-- date is implicitly excluded from the ordering, as it will be null.



PROCEDURE Auto_Req_Allocation(p_auctionID     IN  NUMBER,
                              p_line_number   IN  NUMBER,
                              p_result        OUT NOCOPY VARCHAR2,
                              p_error_message OUT NOCOPY VARCHAR2) IS

l_qty_allocated NUMBER;
l_insert_cursor NUMBER;
l_insert_result NUMBER;
l_reqIdx NUMBER;
l_currentReqIdx NUMBER;
l_insert_index NUMBER;
l_count NUMBER;
l_bid_number_col dbms_sql.number_table;
l_award_col dbms_sql.number_table;
l_req_line_id_col dbms_sql.number_table;
l_req_header_id_col dbms_sql.number_table;
l_req_quantity_col dbms_sql.number_table;
l_req_new_quantity_col dbms_sql.number_table;
l_bid_number_insertcol dbms_sql.number_table;
l_bid_line_number_insertcol dbms_sql.number_table;
l_orig_req_line_insertcol dbms_sql.number_table;
l_orig_req_header_insertcol dbms_sql.number_table;
l_allocated_qty_insertcol dbms_sql.number_table;
l_auction_header_id_insertcol dbms_sql.number_table;
l_empty_table dbms_sql.number_table;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_user_id NUMBER;
l_login_id NUMBER;
l_bid_price_col dbms_sql.number_table;
l_order_type_lookup_code pon_auction_item_prices_all.order_type_lookup_code%TYPE;
l_purchase_basis pon_auction_item_prices_all.purchase_basis%TYPE;
l_contract_type pon_auction_headers_all.contract_type%TYPE;


l_api_name			VARCHAR2(30)	:= ' AUTO_REQ_ALLOCATION ';
l_debug_enabled			VARCHAR2(1)	:= 'N';
l_exception_enabled		VARCHAR2(1)	:= 'N';
l_progress			NUMBER		:= 0;

BEGIN

    /* perform initialization for FND logging */
    if(g_fnd_debug = 'Y') then

	if (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) then
		l_debug_enabled := 'Y';
	end if;

	IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) then
		l_exception_enabled := 'Y';
	end if;

    end if;

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : BEGIN :';
	log_message(x_progress);
	x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : ' || p_auctionID || ' ' || p_line_number;
	log_message(x_progress);

     end if;


     /* empty tables to prevent data corruption*/
     l_bid_number_col := l_empty_table;
     l_award_col := l_empty_table;
     l_req_line_id_col := l_empty_table;
     l_req_header_id_col := l_empty_table;
     l_req_quantity_col := l_empty_table;
     l_req_new_quantity_col := l_empty_table;
     l_bid_number_insertcol := l_empty_table;
     l_bid_line_number_insertcol := l_empty_table;
     l_orig_req_line_insertcol := l_empty_table;
     l_orig_req_header_insertcol := l_empty_table;
     l_allocated_qty_insertcol := l_empty_table;
     l_auction_header_id_insertcol := l_empty_table;
     l_bid_price_col := l_empty_table;

     SELECT paip.order_type_lookup_code, paip.purchase_basis, pah.contract_type
     INTO l_order_type_lookup_code, l_purchase_basis, l_contract_type
     FROM pon_auction_item_prices_all paip, pon_auction_headers_all pah
     WHERE paip.auction_header_id = pah.auction_header_id
     AND paip.auction_header_id = p_auctionid
     AND paip.line_number = p_line_number;

     -- Bulk collect req info into collection table.

     SELECT requisition_line_id, requisition_header_id, requisition_quantity
     BULK COLLECT INTO l_req_line_id_col, l_req_header_id_col,
                       l_req_quantity_col
     FROM po_req_lines_in_pool_src_v
     WHERE auction_header_id = p_auctionID AND
           auction_line_number = p_line_number AND
           nvl(modified_by_agent_flag, 'N') <> 'Y'
     ORDER BY need_by_date ASC, creation_date ASC;


     -- bulk collect the supplier and award info.  In the case of amount based
     -- lines, the procedure will pick up bid_currency_unit_price.
     -- Otherwise, the procedure will pick up the award_quantity.

     SELECT decode(itm.order_type_lookup_code, 'AMOUNT',
                   bl.bid_currency_unit_price,
                   bl.award_quantity) quantity,
            bh.bid_number,
            bl.bid_currency_unit_price
     BULK COLLECT INTO l_award_col, l_bid_number_col, l_bid_price_col
     FROM pon_auction_item_prices_all itm,
          pon_bid_item_prices bl,
          pon_bid_headers bh,
          pon_auction_headers_all pah
     WHERE itm.auction_header_id = p_auctionID AND
           itm.line_number = p_line_number AND
           bl.line_number = itm.line_number AND
           bl.auction_header_id = itm.auction_header_id AND
           nvl(bl.award_status,'NO') = 'AWARDED' AND
           bh.bid_number = bl.bid_number AND
           bh.auction_header_id = itm.auction_header_id AND
           nvl(bh.bid_status,'NONE') = 'ACTIVE'AND
           pah.auction_header_id = itm.auction_header_id
     ORDER BY bl.promised_date ASC, decode(pah.contract_type, 'BLANKET', 1, bl.award_quantity) DESC,
              bl.bid_currency_price ASC,
              bl.publish_date ASC;




     l_insert_index := 1;

     -- implements actual allocation algorithm described above

     FOR bidIdx IN 1..l_bid_number_col.COUNT LOOP

    	if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || 'bid award quantity: ' ||  l_award_col(bidIdx) || 'length of req array: '|| l_req_line_id_col.COUNT;
		log_message(x_progress);
     	end if;

        FOR l_reqIdx IN 1..l_req_line_id_col.COUNT LOOP

    	    if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || 'req index: ' ||  l_reqIdx || ' req quantity: ' || l_req_quantity_col(l_reqIdx);
		log_message(x_progress);
     	    end if;


--          IF ('BLANKET' = l_contract_type AND
	--     ('QUANTITY' = l_order_type_lookup_code OR
	  --    'AMOUNT' = l_order_type_lookup_code)) THEN
	--    IF (bidIdx = 1) THEN
	       -- Full allocation goes to first bidder
	  --     l_qty_allocated := l_req_quantity_col(l_reqIdx);
--	     ELSE
	--       l_qty_allocated := 0;
--	    END IF;
     --  ELS

          IF ('RATE' = l_order_type_lookup_code OR
		 'FIXED PRICE' = l_order_type_lookup_code) THEN
	     IF (bidIdx = 1) THEN
	       -- Allocation goes to first bidder
	       l_qty_allocated := 1;
	     ELSE
	       l_qty_allocated := 0;
	     END IF;
	  ELSIF (l_req_quantity_col(l_reqIdx) = 0) THEN
              l_qty_allocated := 0;
           ELSIF (l_award_col(bidIdx) = 0) THEN
              l_qty_allocated := 0;
           -- If award quantity smaller than req quantity, alloc quantity
           -- will be the award quantity
           ELSIF (l_award_col(bidIdx) < l_req_quantity_col(l_reqIdx)) THEN
              l_qty_allocated := l_award_col(bidIdx);
           -- if award quantity equal to req quantity or if award quantity
           -- greater than req quantity
           ELSE
              l_qty_allocated := l_req_quantity_col(l_reqIdx);
           END IF;

            x_progress := '25: Auto_Req_Allocation: ' || 'qty allocated: ' ||  l_qty_allocated;
            log_message(x_progress);

           l_award_col(bidIdx) := l_award_col(bidIdx) - l_qty_allocated;
           l_req_quantity_col(l_reqIdx) := l_req_quantity_col(l_reqIdx) - l_qty_allocated;

           -- insert into collection object for bulk insert later
           l_bid_number_insertcol(l_insert_index) := l_bid_number_col(bidIdx);
           l_bid_line_number_insertcol(l_insert_index) := p_line_number;
           l_orig_req_line_insertcol(l_insert_index) := l_req_line_id_col(l_reqIdx);
           l_orig_req_header_insertcol(l_insert_index) :=  l_req_header_id_col(l_reqIdx);
           l_allocated_qty_insertcol(l_insert_index) :=  l_qty_allocated;

           x_progress := '30: Auto_Req_Allocation: ' || 'qty allocated: ' ||  l_allocated_qty_insertcol(l_insert_index) || ' index: ' || l_insert_index;
           log_message(x_progress);

           l_auction_header_id_insertcol(l_insert_index) :=  p_auctionID;
           l_insert_index := l_insert_index + 1;

        END LOOP;
     END LOOP;

     x_progress := '33: Right before Bulk Insert';
     log_message(x_progress);


     l_user_id := fnd_global.user_id;
     l_login_id := fnd_global.login_id;

     -- doing bulk insert
     FORALL l_count IN 1..l_bid_number_insertcol.COUNT
        INSERT INTO pon_award_allocations(bid_number, bid_line_number, orig_req_line_id, orig_req_header_id, allocated_qty, auction_header_id, created_by, last_update_date, last_updated_by, last_update_login, creation_date)
        VALUES(l_bid_number_insertcol(l_count),
               l_bid_line_number_insertcol(l_count),
               l_orig_req_line_insertcol(l_count),
               l_orig_req_header_insertcol(l_count),
               l_allocated_qty_insertcol(l_count),
               l_auction_header_id_insertcol(l_count),
               l_user_id,
               sysdate,
               l_user_id,
               l_login_id,
               sysdate);
     -- end of bulk insert

    x_progress := '35: Auto_Req_Allocation: ' || 'qty allocated: ' ||  l_allocated_qty_insertcol(l_bid_number_insertcol.COUNT);
    log_message(x_progress);

    p_result := 'SUCCESS';

EXCEPTION
     WHEN OTHERS THEN
        p_result := 'FAILURE';
        p_error_message := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || SUBSTRB(SQLERRM, 1, 500);
        log_message(x_progress);
END Auto_Req_Allocation;


-- This procedure is called by NegotiationDoc.startPOCreation.  It kicks off
-- the po creation workflow and sets up the wf attributes
PROCEDURE START_PO_WORKFLOW(p_auction_header_id           IN    NUMBER,       -- 1
                            p_user_name                   IN    VARCHAR2,     -- 2
                            p_user_id                     IN    NUMBER,       -- 3
                            p_formatted_name              IN    VARCHAR2,     -- 4
                            p_auction_title               IN    VARCHAR2,     -- 5
                            p_organization_name           IN    VARCHAR2,
			    p_email_type		  IN    VARCHAR2,
			    p_itemkey			  IN    VARCHAR2,
			    x_allocation_error		  OUT NOCOPY VARCHAR2,
			    x_line_number		  OUT NOCOPY NUMBER,
			    x_item_number		  OUT NOCOPY VARCHAR2,
			    x_item_description		  OUT NOCOPY VARCHAR2,
			    x_item_revision		  OUT NOCOPY VARCHAR2,
			    x_requisition_number	  OUT NOCOPY VARCHAR2,
			    x_job_name			  OUT NOCOPY VARCHAR2,
			    x_document_disp_line_number	  OUT NOCOPY VARCHAR2) IS  -- 6

x_itemkey		       wf_items.ITEM_KEY%TYPE;
x_itemtype                     wf_items.ITEM_TYPE%TYPE;

x_progress                     VARCHAR2(4000);
x_language_code                VARCHAR2(3);
x_msg_suffix                   VARCHAR2(3) := '';
x_doctype_group_name           pon_auc_doctypes.doctype_group_name%TYPE;
x_doctype_id                   pon_auction_headers_all.doctype_id%TYPE;
x_responsibility_id            NUMBER;
x_application_id               NUMBER;
x_doc_number_dsp               VARCHAR2(60);
x_contract_type                pon_auction_headers_all.contract_type%TYPE;
x_current_round                NUMBER;

x_timezone	                   VARCHAR2(80);
x_newstarttime	               DATE;
x_newendtime	               DATE;
x_newpreviewtime               DATE;
x_oex_timezone                 VARCHAR2(80);
x_timezone_disp                VARCHAR2(240);
p_open_bidding_date            date;
p_close_bidding_date           date;
p_trading_partner_contact_id   number;
x_award_summary_url_buyer      VARCHAR2(2000);
x_alloc_summary_url_buyer      VARCHAR2(2000);
x_alloc_byitem_url_buyer       VARCHAR2(2000);
x_po_summary_url_buyer         VARCHAR2(2000);
p_doctype_id                   PON_AUCTION_HEADERS_ALL.DOCTYPE_ID%TYPE;
p_trading_partner_name         PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
p_trading_partner_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
x_purchase_order               VARCHAR2(30);
x_purchase_orders              VARCHAR2(30);
p_preview_date   	           DATE;
x_requistion_based             VARCHAR2(12);
x_has_items                    PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE;


l_api_name			VARCHAR2(30)	:= ' START_PO_WORKFLOW ';
l_debug_enabled			VARCHAR2(1)	:= 'N';
l_exception_enabled		VARCHAR2(1)	:= 'N';
l_progress			NUMBER		:= 0;

BEGIN

     PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_user_name, x_language_code);

     select 	open_bidding_date,
		close_bidding_date,
		trading_partner_contact_id,
		doctype_id,
            	trading_partner_name,
		trading_partner_contact_name,
		has_items_flag
     into 	p_open_bidding_date,
		p_close_bidding_date,
		p_trading_partner_contact_id,
		p_doctype_id,
          	p_trading_partner_name,
		p_trading_partner_contact_name,
		x_has_items
     from pon_auction_headers_all
     where auction_header_id = p_auction_header_id;

    x_itemkey := p_itemkey;
    x_itemtype:= 'PONCOMPL';

    x_progress := '10: START_PO_WORKFLOW: Called with following parameters: ' ||
                   'ItemType = ' || x_itemType || ', ' ||
                   'ItemKey = ' || x_itemKey || ', ' ||
                   'auction_header_id = ' || p_auction_header_id || ', ' ||
                   'user_name = ' || p_user_name || ', ' ||
                   'user_id = ' || p_user_id || ', ' ||
                   'formatted_name = ' || p_formatted_name || ', ' ||
                   'auction_title = ' || p_auction_title || ', ' ||
                   'organization_name = ' || p_organization_name;

    log_message(x_itemtype ||  ' ' || x_progress);

    wf_engine.CreateProcess(itemtype => x_itemtype,
                            itemkey  => x_itemkey,
                            process  => 'PO_CREATION_ENGINE');

    x_progress := '20: START_PO_WORKFLOW: Just after CreateProcess';

    log_message(x_itemtype || ' ' ||  x_progress);

    PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, x_language_code);



    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE',
                               avalue     => p_open_bidding_date);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE',
                               avalue     => p_close_bidding_date);

    wf_engine.SetItemAttrDate (itemtype	=> x_itemtype,
				               itemkey	=> x_itemkey,
				               aname	=> 'PREVIEW_DATE',
				               avalue	=> p_preview_date);

	-- new item attribute to hold the document type id. Item attribute value is going
	-- to be used as a parameter to Allocation by Item and Allocation Summary pages
	wf_engine.SetItemAttrNumber (itemtype	=> x_itemtype,
				               itemkey	=> x_itemkey,
				               aname	=> 'DOCTYPE_ID',
				               avalue	=> p_doctype_id);

        --
		-- Get the exchange's time zone
		--

	       x_oex_timezone := pon_auction_pkg.Get_Oex_Time_Zone;

		--
		-- Get the user's time zone
		--
	x_timezone := pon_auction_pkg.Get_Time_Zone(p_trading_partner_contact_id);

    --
    -- Make sure that it is a valid time zone
    --

    IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(x_timezone) = 0) THEN
	x_timezone := x_oex_timezone;
    END IF;

    --
    -- Convert the dates to the user's timezone.
    --

    x_newstarttime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_open_bidding_date,x_oex_timezone,x_timezone);
    x_newendtime   := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_close_bidding_date,x_oex_timezone,x_timezone);
    x_newpreviewtime := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_preview_date,x_oex_timezone,x_timezone);

    x_timezone_disp:= pon_auction_pkg.Get_TimeZone_Description(x_timezone, x_language_code);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'TP_TIME_ZONE',
                               avalue     => x_timezone_disp);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_START_DATE_TZ',
                               avalue     => x_newstarttime);

    wf_engine.SetItemAttrDate (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_END_DATE_TZ',
                               avalue     => x_newendtime);


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_PO_EMAIL_TYPE',
                               avalue     => p_email_type);

     IF (p_preview_date IS NULL) THEN
        wf_engine.SetItemAttrDate (itemtype	=> x_itemtype,
				                   itemkey	=> x_itemkey,
				                   aname	=> 'PREVIEW_DATE_TZ',
				                   avalue	=> null);

        wf_engine.SetItemAttrText (itemtype	=> x_itemtype,
			                       itemkey	=> x_itemkey,
			                       aname	=> 'TP_TIME_ZONE1',
		                           avalue	=> null);

        wf_engine.SetItemAttrText (itemtype	=> x_itemtype,
				                   itemkey	=> x_itemkey,
				                   aname	=> 'PREVIEW_DATE_NOTSPECIFIED',
				                   avalue	=> PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC',x_msg_suffix));
    ELSE
        wf_engine.SetItemAttrDate (itemtype	=> x_itemtype,
				                   itemkey	=> x_itemkey,
			                       aname	=> 'PREVIEW_DATE_TZ',
				                   avalue	=> x_newpreviewtime);

        wf_engine.SetItemAttrText (itemtype	=> x_itemtype,
		                           itemkey	=> x_itemkey,
				                   aname	=> 'TP_TIME_ZONE1',
				                   avalue	=> x_timezone_disp);

        wf_engine.SetItemAttrText (itemtype	=> x_itemtype,
			                       itemkey	=> x_itemkey,
				                   aname	=> 'PREVIEW_DATE_NOTSPECIFIED',
				                   avalue	=> null);
    END IF;


    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'AUCTION_ID',
                                 avalue     => p_auction_header_id);


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'USER_NAME',
                               avalue     => p_user_name);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'USER_ID',
                                 avalue     => p_user_id);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'CONTACT_NAME',
                               avalue     => p_formatted_name || ',');


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'AUCTION_TITLE',
                               avalue     => PON_AUCTION_PKG.replaceHtmlChars(p_auction_title));

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'HAS_ITEMS_FLAG',
                               avalue     => x_has_items);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ORGANIZATION_NAME',
                               avalue     => p_organization_name);

      -- call to notification utility package to get the redirect page url that
      -- is responsible for getting the Award Summary url and forward to it.
       x_award_summary_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PON_AWARD_SUMM'
                                 ,p_notif_performer  => 'BUYER');

       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                  aname      => 'AWARD_SUMMARY_URL',
                                  avalue     => x_award_summary_url_buyer);


      -- call to notification utility package to get the redirect page url that
      -- is responsible for getting the purchase order summary url and forward to it.

       x_po_summary_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PON_PO_SUMMARY'
                                 ,p_notif_performer  => 'BUYER');


       wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                  itemkey    => x_itemkey,
                                  aname      => 'PURCHASE_ORDER_SUMMARY_URL',
                                  avalue     => x_po_summary_url_buyer);


    -- call to notification utility package to get the redirect page url that
    -- is responsible for getting the Allocate Summary url and forward to it.
    x_alloc_summary_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PONCPOSUM_ALLOCSUMMARY'
                                 ,p_notif_performer  => 'BUYER');


    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ALLOCATE_SUMMARY_URL',
                               avalue     => x_alloc_summary_url_buyer);


    -- call to notification utility package to get the redirect page url that
    -- is responsible for getting the Allocate by Item url and forward to it.

       x_alloc_byitem_url_buyer := pon_wf_utl_pkg.get_dest_page_url (
		                          p_dest_func => 'PONCPOABI_ALLOCATEBYITEM'
                                 ,p_notif_performer  => 'BUYER');

        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'ALLOCATE_ITEM_URL',
                               avalue     => x_alloc_byitem_url_buyer);


    /* Setting Profile Attributes */

    FND_PROFILE.GET('RESP_ID', x_responsibility_id);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'RESPONSIBILITY_ID',
                                 avalue     => x_responsibility_id);

    FND_PROFILE.GET('RESP_APPL_ID', x_application_id);

    wf_engine.SetItemAttrNumber (itemtype   => x_itemtype,
                                 itemkey    => x_itemkey,
                                 aname      => 'APPLICATION_ID',
                                 avalue     => x_application_id);

    x_progress := 'START_PO_WORKFLOW: profile values: ' ||
                  'x_responsibility_id: ' || x_responsibility_id || ', ' ||
                  'x_application_id: ' || x_application_id;

        log_message(x_itemtype || ' ' ||x_progress);

    /* Setting Message Attributes */

    SELECT auh.document_number,
           dt.doctype_group_name, auh.contract_type,
           nvl(auh.wf_poncompl_current_round, 0), auh.doctype_id
    INTO   x_doc_number_dsp, x_doctype_group_name, x_contract_type,
           x_current_round, x_doctype_id
    FROM   pon_auction_headers_all auh, pon_auc_doctypes dt
    WHERE  auh.auction_header_id = p_auction_header_id and
           auh.doctype_id = dt.doctype_id;

    x_msg_suffix := PON_AUCTION_PKG.GET_MESSAGE_SUFFIX (x_doctype_group_name);

    IF (x_contract_type = 'STANDARD') THEN
    	x_purchase_order := 'Standard Purchase Order';
        x_purchase_orders := 'Standard Purchase Orders';
        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PON_AUC_WF_PO_CREATE_SUBJ',
                                   avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_PO_CREATE_SUBJ', x_msg_suffix, 'DOC_NUMBER', x_doc_number_dsp));
    ELSIF (x_contract_type = 'BLANKET') THEN
    	x_purchase_order := 'Blanket Purchase Agreement';
        x_purchase_orders := 'Blanket Purchase Agreements';
        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PON_AUC_WF_PO_CREATE_SUBJ',
                                   avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_BL_CREATE_SUBJ', x_msg_suffix, 'DOC_NUMBER', x_doc_number_dsp));
    ELSIF (x_contract_type = 'CONTRACT') THEN
    	x_purchase_order := 'Contract Purchase Agreement';
        x_purchase_orders := 'Contract Purchase Agreements';
        wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PON_AUC_WF_PO_CREATE_SUBJ',
                                   avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_CPA_CREATE_SUBJ', x_msg_suffix, 'DOC_NUMBER', x_doc_number_dsp));

     END IF;

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PURCHASE_ORDERS',
                               avalue     => x_purchase_order);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PURCHASE_ORDER_TYPE',
                               avalue     => x_purchase_orders);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'WORKFLOW_ROUND_NUMBER',
                               avalue     => x_current_round);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'DOC_NUMBER',
                               avalue     => x_doc_number_dsp);

    -- Setting workflow message header attributes
    pon_wf_utl_pkg.set_hdr_attributes (p_itemtype	=> x_itemtype
		                              ,p_itemkey	=> x_itemkey
                                      ,p_auction_tp_name  => p_trading_partner_name
	                                  ,p_auction_title => p_auction_title
	                                  ,p_document_number  => x_doc_number_dsp
	                                  ,p_auction_tp_contact_name => p_trading_partner_contact_name);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'MSG_SUFFIX',
                               avalue     => x_msg_suffix);

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                               itemkey    => x_itemkey,
                               aname      => 'PON_AUC_WF_ORG',
                               avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_ORG'));

    wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'PON_AUC_WF_SUCC_MESSAGE',
                              avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_SUCC_MESSAGE'));

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'PON_AUC_WF_RESTART_WF_MSG',
                              avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_RESTART_WF_MSG', x_msg_suffix));

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'PON_AUC_WF_RESTART_MSG',
                              avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_RESTART_MSG', x_msg_suffix));

   wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                                   itemkey    => x_itemkey,
                                   aname      => 'PON_AUC_WF_ALLOC_SUBJ',
                                   avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_WF_ALLOC_SUBJ', x_msg_suffix,
                                                                            'PURCHASE_ORDERS', x_purchase_order,
                                                                            'DOC_NUMBER', x_doc_number_dsp));

      --check if the negotiation has requistion based line
      BEGIN
        SELECT 'REQUISITION'
	INTO x_requistion_based
	FROM DUAL
	WHERE EXISTS(
         SELECT '1'
	 FROM pon_auction_item_prices_all
	 WHERE auction_header_id = p_auction_header_id
	      AND  line_origination_code = 'REQUISITION'
	 );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
          x_requistion_based := 'NONE';

	 WHEN OTHERS THEN
            log_error(x_itemtype || ' ' || x_progress || 'in select exception' || SUBSTRB(SQLERRM, 1, 500));
      END;

      wf_engine.SetItemAttrText (itemtype   => x_itemtype,
                              itemkey    => x_itemkey,
                              aname      => 'AUCTION_ORIGINATION_CODE',
                              avalue     => x_requistion_based);


/*
rrkulkar-large-auction-support
*/



        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey => x_itemkey,
                                   aname => 'ALLOC_ERROR',
 	        	           avalue => PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR') || ' - ' || substrb(SQLERRM, 1, 500));

        IF x_line_number IS NULL THEN

	-- it means the exception was thrown before line information is selected
	-- let buyer know no line information is available

             wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                        itemkey  => x_itemkey,
                                        aname    => 'LINE_NUMBER',
			                avalue   => PON_AUCTION_PKG.getMessage('PON_LINE_INFO_NOT_AVAIL'));
        ELSE
             wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                        itemkey  => x_itemkey,
                                        aname    => 'LINE_NUMBER',
			                avalue   => to_char(x_line_number));
	END IF;

        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'ITEM_NUMBER',
			           avalue   => x_item_number);

        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'LINE_DESCRIPTION',
		   	           avalue   => x_item_description);

        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'REVISION_NUMBER',
			           avalue   => x_item_revision);

        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'REQ_NUMBERS',
		   	           avalue   => x_requisition_number);

       -- setting workflow progress attribute to track the process and easy the debugging process
	    wf_engine.SetItemAttrText (itemtype => x_itemtype,
					itemkey  => x_itemkey,
					aname    => 'WORKFLOW_PROGRESS',
					avalue   => x_progress);

    -- Bug 4456420: Set initiator to current logged in user
        wf_engine.SetItemAttrText (itemtype => x_itemtype,
                                   itemkey  => x_itemkey,
                                   aname    => 'ORIGIN_USER_NAME',
		   	           avalue   => fnd_global.user_name);


     x_progress := '30: START_PO_WORKFLOW: Kicking off StartProcess';
        log_message(x_itemtype || ' ' ||x_progress);

    -- Bug 4295915: Set the  workflow owner
      wf_engine.SetItemOwner(itemtype => x_itemtype,
                             itemkey  => x_itemkey,
                             owner    => fnd_global.user_name);

    wf_engine.StartProcess(itemtype => x_itemtype,
                           itemkey  => x_itemkey );


    PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

END START_PO_WORKFLOW;

/*
   Creates the award purchase order structure in PDOI
   This procedure is invoked from PON_AUCTION_CREATE_PO_PKG.GENERATE_POS procedure
   which is invoked from our create po workflow (refer ponwfau7.wft)

   This procedure inserts data from PON tables to PO interface tables

*/

PROCEDURE CREATE_PO_STRUCTURE(p_auction_header_id           IN NUMBER,
                              p_bid_number                  IN NUMBER,
			      p_user_id			    IN NUMBER,
                              p_interface_header_id         OUT NOCOPY NUMBER,
                              p_pdoi_header                 OUT NOCOPY PDOIheader,
                              p_error_code                  OUT NOCOPY VARCHAR2,
                              p_error_message               OUT NOCOPY VARCHAR2) IS


x_user_id NUMBER;
x_line_number NUMBER;
x_award_quantity NUMBER;
x_allocation_quantity NUMBER;
x_requisition_line_id NUMBER;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
x_interface_header_id NUMBER;
x_interface_line_id NUMBER;
x_price NUMBER;
x_quantity NUMBER;
x_amount NUMBER;
x_pdoi_header PDOIheader;
x_pdoi_line PDOIline;
x_hasBackingReqs pon_auction_headers_all.auction_origination_code%TYPE;
x_source_reqs_flag VARCHAR2(1);
x_sum_requisitions NUMBER;
sum_of_alloc_quantities sumOfReqLineAllocQuantities;

l_rows_processed	NUMBER;
l_batch_end 		NUMBER;
l_batch_start	 	NUMBER;
l_batch_size 		NUMBER;
l_max_line_number      	NUMBER;
l_commit_flag		BOOLEAN;

/* Selects the data from Sourcing that will populate PO_HEADERS_INTERFACE */

CURSOR headerLevelInfo IS
               SELECT pah.auction_header_id,
                      pah.document_number,
                      pah.org_id,
                      pah.contract_type,
                      pah.language_code,
		      pbh.po_start_date,
                      pbh.po_end_date,
                      pah.currency_code,
                      pah.fob_code,
                      pah.freight_terms_code,
                      pah.carrier_code,
                      pah.payment_terms_id,
                      pah.ship_to_location_id,
                      pah.bill_to_location_id,
                      pah.auction_origination_code,
                      pah.source_reqs_flag,
                      pbh.bid_number,
                      pbh.order_number,
                      pbh.vendor_id,
                      pbh.vendor_site_id,
                      PON_AUCTION_CREATE_PO_PKG.get_vendor_contact_id(pbh.trading_partner_contact_id,pbh.vendor_site_id,pbh.vendor_id) vendor_contact_id,
		      pbh.agent_id,
		      pah.global_agreement_flag,
                      round(pah.po_min_rel_amount* pbh.rate,fc.precision),
                      pbh.po_agreed_amount,
                      pbh.bid_currency_code,
                      pah.rate_type,
                      pah.rate_date,
                      pbh.rate_dsp,
                      pbh.create_sourcing_rules,
                      pbh.update_sourcing_rules,
                      pbh.release_method,
                      pbh.initiate_approval,
		      pbh.acceptance_required_flag,
                      pah.po_style_id,
                      pah.progress_payment_type,
                      pah.supplier_enterable_pymt_flag
                FROM  pon_auction_headers_all pah,
                      pon_bid_headers pbh,
                      fnd_currencies fc
                WHERE pah.auction_header_id = p_auction_header_id and
                      pbh.auction_header_id = pah.auction_header_id and
                      pbh.bid_number = p_bid_number and
                      pbh.bid_currency_code = fc.currency_code;

/* Selects the data from Sourcing that will populate PO_LINES_INTERFACE */

/*
   rrkulkar-large-auction-support - this cursor will bring in all the lines in the middle-tier :
   hence, added the following condition in the where clause :-

   paip.line_origination_code		= 'REQUISITION';

   We know that we will not have super-large negotiations with all lines having backing reqs. -
   hence, looping over all such lines is just fine.

   In SPO outcome case, we will use bulk collect along with batching for super-large auctions for
   lines with no backing reqs.

*/
CURSOR reqlineLevelInfo IS
               SELECT paip.line_number,
                      paip.line_type_id,
                      paip.order_type_lookup_code,
                      paip.line_origination_code,
                      paip.item_id,
                      paip.item_revision,
                      paip.category_id,
                      paip.item_description,
                      mtluom.unit_of_measure,
                      paip.ship_to_location_id,
                      paip.need_by_start_date,
                      pbip.award_quantity,
                      nvl(pbip.po_bid_min_rel_amount, round(paip.po_min_rel_amount* pbh.rate,fc.precision)),
                      paip.has_price_elements_flag,
		      decode(paip.order_type_lookup_code, 'FIXED PRICE',
							  round(pbip.bid_currency_unit_price, fc.precision),
 						          pbip.bid_currency_unit_price),
                      pbip.promised_date,
		      paip.job_id,
		      round(paip.po_agreed_amount*pbh.rate, fc.precision),
		      paip.purchase_basis
              , pbip.bid_curr_advance_amount
	          , pbip.recoupment_rate_percent
	          , pbip.progress_pymt_rate_percent
	          , pbip.retainage_rate_percent
	          , pbip.bid_curr_max_retainage_amt
	          , decode(pbip.has_bid_payments_flag, 'Y', decode((select 1 from dual where exists
		                                                      ( select 1 from pon_bid_payments_shipments where
		                                                        auction_header_id = pbip.auction_header_id and
									bid_number= pbip.bid_number and bid_line_number=pbip.line_number
								        and bid_currency_price <> 0
								       )
								     ),
								    1,'Y','N')
		       ,'N') has_bid_payments_flag
	          , pbip.award_shipment_number

               FROM
                      pon_auction_item_prices_all paip,
                      pon_bid_item_prices pbip,
                      mtl_units_of_measure mtluom,
		      pon_bid_headers pbh,
		      fnd_currencies fc
               WHERE pbip.bid_number 			= p_bid_number 			and
                     pbip.auction_header_id 		= p_auction_header_id 		and
                     nvl(pbip.award_status, 'NO') 	= 'AWARDED' 			and
                     paip.auction_header_id 		= pbip.auction_header_id 	and
		     paip.line_number 			= pbip.line_number 		and
		     paip.group_type 			NOT IN ('GROUP','LOT_LINE') 	and
		     paip.uom_code 			= mtluom.uom_code (+) 		and
		     pbh.bid_number 			= pbip.bid_number 		and
		     fc.currency_code 			= pbh.bid_currency_code 	and
		     paip.line_origination_code		= 'REQUISITION';


/* queries the allocation table to get req lines and the allocated quantity backing that particular bid and bid line.*/
CURSOR reqBackingBidItem IS
               SELECT split_req_line_id, allocated_qty
               FROM   pon_award_allocations
               WHERE  auction_header_id = p_auction_header_id and
                      bid_number = p_bid_number and
                      bid_line_number = x_line_number and
                      nvl(allocated_qty,0) <> 0 and
                      nvl(split_req_line_id, -999) <> -999;
/* returns the sum of allocated quantities to backing requisition lines for
   each negotiation line for a particular bid.  The outer join is for picking
   up lines that have no allocations, but have backing requisitions to get a
   sum of 0 */
CURSOR sumOfReqAllocQuantities is
             SELECT   PAIP.line_number, nvl(sum(nvl(PAA.allocated_qty,0)), 0)
             FROM     PON_AWARD_ALLOCATIONS PAA, PON_AUCTION_ITEM_PRICES_ALL PAIP
             WHERE   PAIP.auction_header_id = p_auction_header_id
               AND   PAIP.award_status = 'COMPLETED'
               AND   nvl(PAIP.awarded_quantity,0) > 0
               AND   PAA.auction_header_id(+) = PAIP.auction_header_id
               AND   PAA.bid_line_number(+) = PAIP.line_number
               AND   PAA.bid_number(+) = p_bid_number
               AND   nvl(PAA.split_req_line_id(+), -999) <> -999
             GROUP BY PAIP.line_number;
BEGIN
      x_progress := '10: CREATE_PO_STRUCTURE: ' || 'auction_header_id: ' || p_auction_header_id || ', ' || 'bid_number: ' || p_bid_number;
      log_message(x_progress);

     	SELECT 	po_headers_interface_s.nextval
      	INTO 	x_interface_header_id
      	FROM 	dual;

      	OPEN 	headerLevelInfo;
      	FETCH 	headerLevelInfo
	INTO 	x_pdoi_header;
      	CLOSE 	headerLevelInfo;

      x_hasBackingReqs := x_pdoi_header.auction_origination_code;


      /*loops through sumOfReqAllocQuantities cursor and populates
        sum_of_alloc_quantities(line) array to hold the total number of req
        line quantities for that item line. */

      OPEN sumOfReqAllocQuantities;
        LOOP
          FETCH sumOfReqAllocQuantities INTO x_line_number, x_sum_requisitions;
          EXIT WHEN sumOfReqAllocQuantities%NOTFOUND;
          sum_of_alloc_quantities(x_line_number) := x_sum_requisitions;
        END LOOP;
      CLOSE sumOfReqAllocQuantities;

      /*
      Insert into PO_HEADERS_INTERFACE the purchase order header information based on the negotiation and the award bid.
      */

      INSERT into PO_HEADERS_INTERFACE (
         interface_header_id,
         interface_source_code,
         batch_id,
         action,
         org_id,
         document_type_code,
         document_subtype,
         created_language,
         effective_date,
         expiration_date,
         document_num,
         group_code,
         vendor_id,
         vendor_site_id,
         vendor_contact_id,
         agent_id,
         currency_code,
         rate_type_code,
         rate_date,
         rate,
         fob,
         freight_terms,
         freight_carrier,
         terms_id,
         ship_to_location_id,
         bill_to_location_id,
         consume_req_demand_flag,
	 global_agreement_flag,
	 min_release_amount,
         amount_agreed,
	 acceptance_required_flag,
         style_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date)
         values (
         x_interface_header_id,                           -- interface_header_id
         'SOURCING',                                      -- interface_source_code
         x_interface_header_id,                           -- batch_id
         'NEW',                                           -- action
         x_pdoi_header.org_id,                            -- org_id
         decode(x_pdoi_header.contract_type, 'BLANKET',
                                         'PA','CONTRACT','PA','PO'),     -- document_type_code
         x_pdoi_header.contract_type,                     -- document_subtype
         x_pdoi_header.language_code,                     -- created_language
         x_pdoi_header.po_start_date,                     -- effective_date
         x_pdoi_header.po_end_date,                       -- expiration_date
         x_pdoi_header.order_number,                      -- document_num
         'DEFAULT',                                       -- group_code
         x_pdoi_header.vendor_id,                         -- vendor_id
         x_pdoi_header.vendor_site_id,                    -- vendor_site_id
         x_pdoi_header.vendor_contact_id,         -- vendor_contact_id
         x_pdoi_header.agent_id,                          -- agent_id
         x_pdoi_header.bid_currency_code,                 -- currency_code
         decode(x_pdoi_header.currency_code, x_pdoi_header.bid_currency_code, null, x_pdoi_header.rate_type),           -- rate_type_code
         decode(x_pdoi_header.currency_code, x_pdoi_header.bid_currency_code, null, x_pdoi_header.rate_date),           -- rate_date
         decode(x_pdoi_header.currency_code, x_pdoi_header.bid_currency_code, null, x_pdoi_header.rate_dsp),            -- rate
         x_pdoi_header.fob_code,                          -- fob
         x_pdoi_header.freight_terms_code,                -- freight_terms
         x_pdoi_header.carrier_code,                      -- freight_carrier,
         x_pdoi_header.payment_terms_id,                  -- terms_id
         x_pdoi_header.ship_to_location_id,               -- ship_to_location_id
         x_pdoi_header.bill_to_location_id,               -- bill_to_location_id
         x_pdoi_header.source_reqs_flag,                  -- consume req demandflag
         x_pdoi_header.global_agreement_flag,             -- global_agreement_flag
	 x_pdoi_header.po_min_rel_amount,                 -- min_release_amount
	 x_pdoi_header.po_agreed_amount,                  -- amount_agreed
	 x_pdoi_header.acceptance_required_flag,          -- accept req flag
         x_pdoi_header.po_style_id,                       -- style_id
         p_user_id,                                       -- created_by
         sysdate,                                         -- creation_date
         p_user_id,                                       -- last_update_by
         sysdate);                                        -- last_update_date


       x_progress := '15: CREATE_PO_STRUCTURE: INSERTING the following data into po_headers_interface: ' ||
                     'interface_header_id: ' || to_char(x_interface_header_id) || ', ' ||
                     'interface_source_code: ' || 'SOURCING' || ', ' ||
                     'batch_id: ' || to_char(x_interface_header_id) || ', ' ||
                     'action: ' || 'NEW' || ', ' ||
                     'org_id: ' || to_char(x_pdoi_header.org_id) || ', ' ;

                     IF (x_pdoi_header.contract_type = 'BLANKET') THEN
                         x_progress := x_progress || 'document_type_code: ' || 'PA' || ', ';
                     ELSE
                         x_progress := x_progress || 'document_type_code: ' || 'PO' || ', ';
                     END IF;

      x_progress :=  x_progress ||
                     'document_subtype: ' || x_pdoi_header.contract_type || ', ' ||
                     'created_language: ' || x_pdoi_header.language_code || ', ' ||
                     'effective_date: ' || to_char(x_pdoi_header.po_start_date) || ', ' ||
                     'expiration_date: ' || to_char(x_pdoi_header.po_end_date) || ', ' ||
                     'document_num: ' || x_pdoi_header.order_number || ', ' ||
                     'group_code: ' || 'DEFAULT' || ', ' ||
                     'vendor_id: ' || to_char(x_pdoi_header.vendor_id) || ', ' ||
                     'vendor_site_id: ' || to_char(x_pdoi_header.vendor_site_id) || ', ' ||
                     'vendor_contact_id: ' || to_char(x_pdoi_header.vendor_contact_id) || ', ' ||
                     'agent_id: ' || to_char(x_pdoi_header.agent_id) || ', ' ||
                     'currency_code: ' || x_pdoi_header.bid_currency_code || ', ' ||
                     'rate_type_code: ' || x_pdoi_header.rate_type || ', ';

                     IF (x_pdoi_header.currency_code = x_pdoi_header.bid_currency_code) THEN
                         x_progress := x_progress || 'rate_date: ' || 'null' || ', ' || 'rate: ' || null || ', ';
                     ELSE
                         x_progress := x_progress || 'rate_date: ' || x_pdoi_header.rate_date || ', ' || 'rate: ' || to_char(x_pdoi_header.rate_dsp) || ', ';
                     END IF;

       x_progress := x_progress ||
                     'fob: ' || x_pdoi_header.fob_code || ', ' ||
                     'freight_terms: ' || x_pdoi_header.freight_terms_code || ', ' ||
                     'freight_carrier: ' || x_pdoi_header.carrier_code || ', ' ||
                     'terms_id: ' || to_char(x_pdoi_header.payment_terms_id) || ', ' ||
                     'ship_to_location_id: ' || to_char(x_pdoi_header.ship_to_location_id) || ', ' ||
                     'bill_to_location_id: ' || to_char(x_pdoi_header.bill_to_location_id) || ', ' ||
                     ' source_reqs_flag: ' || x_pdoi_header.source_reqs_flag || ', ' ||
                     'amount_agreed: ' || to_char(x_pdoi_header.po_agreed_amount) || ', ' ||
                     'created_by: ' || to_char(p_user_id) || ', ' ||
                     'last_update_by: ' || to_char(p_user_id);

      log_message(x_progress);

      IF (x_pdoi_header.contract_type = 'STANDARD') THEN --{

        OPEN reqlineLevelInfo;

        LOOP --{ -- loop over reqlineLevelInfo

             FETCH reqlineLevelInfo INTO x_pdoi_line;
             EXIT WHEN reqlineLevelInfo%NOTFOUND;

             x_line_number := x_pdoi_line.line_number;

             x_price := x_pdoi_line.bid_currency_unit_price;

             -- Quantity Based Price Tiers changes
             IF x_pdoi_line.award_shipment_number IS NOT NULL THEN

                SELECT BID_CURRENCY_UNIT_PRICE INTO x_price
                FROM PON_BID_SHIPMENTS
                WHERE LINE_NUMBER = x_pdoi_line.line_number
                AND AUCTION_HEADER_ID = x_pdoi_header.auction_header_id
                AND BID_NUMBER = p_bid_number
                  AND SHIPMENT_NUMBER = x_pdoi_line.award_shipment_number;

             END IF;
	     IF (x_pdoi_line.order_type_lookup_code = 'FIXED PRICE') THEN
		x_amount := x_price;
		x_price := NULL;
	      ELSE
		x_amount := NULL;
		x_price := x_price;
	     END IF;

             IF (x_pdoi_line.order_type_lookup_code = 'AMOUNT') THEN
                 x_award_quantity := x_price;
             ELSE
                 x_award_quantity := x_pdoi_line.award_quantity;
             END IF;

             x_progress := '20: CREATE_PO_STRUCTURE:' || 'Processing bid number: ' || p_bid_number || ', '
                                                      || 'line number: ' || x_line_number || ', '
                                                      || 'award quantity: ' || x_award_quantity;
             log_message(x_progress);


             /* contract type is standard and this line comes from a
                backing requisition and the sum of the allocated quantity
                to the backing requisitions is greater than 0 */

	     /*
		rrkulkar-large-auction-support : since we don't expect too many lines
		with backing requisitions (i.e > 2500), we will not add batching over
		here

	     */

             IF (x_pdoi_line.line_origination_code = 'REQUISITION' AND
                 sum_of_alloc_quantities.EXISTS(x_line_number) AND
                 sum_of_alloc_quantities(x_line_number) > 0) THEN --{

                       x_progress := '30: CREATE_PO_STRUCTURE: ' || 'Single Supplier is handling the demand';

 		 	log_message(x_progress);

                       OPEN reqBackingBidItem;

                       LOOP --{ -- loop over reqBackingBidItem

                       FETCH reqBackingBidItem INTO x_requisition_line_id,
                                      x_allocation_quantity;
                       EXIT WHEN reqBackingBidItem%NOTFOUND;
                          x_progress := '30: CREATE_PO_STRUCTURE: ' || 'Req Line: ' || x_requisition_line_id || ', ' || 'Alloc Quantity: ' || x_allocation_quantity;

 			  log_message(x_progress);

                          /*
                          Insert a row into PO_LINES_INTERFACE with the
                          item information from the negotiation line, and
                          the requisiton_line_id and quantity
                          (price and quantity will be switched when
                          negotiation line is amount-based-
                          check pon_auction_item_prices_all.order_type_lookup_code)
                          from the backing requisition.
                          */


                          INSERT into PO_LINES_INTERFACE (
                              interface_header_id,
                              interface_line_id,
                              requisition_line_id,
                              line_type_id,
                              item_id,
                              item_revision,
                              category_id,
                              item_description,
                              unit_of_measure,
                              quantity,
                              unit_price,
                              min_release_amount,
                              ship_to_location_id,
                              need_by_date,
                              promised_date,
                              last_updated_by,
                              last_update_date,
                              created_by,
                              creation_date,
                              auction_header_id,
                              auction_display_number,
                              auction_line_number,
                              bid_number,
                              bid_line_number,
			      orig_from_req_flag,
			      job_id,
			      amount
	                          , advance_amount
	                          , recoupment_rate
	                          , progress_payment_rate
	                          , retainage_rate
	                          , max_retainage_amount
                              , line_loc_populated_flag

                              )

                              values (

                              x_interface_header_id,  -- interface_header_id
                              po_lines_interface_s.nextval,    -- interface_line_id
                              x_requisition_line_id,  -- requisition_line_id
                              x_pdoi_line.line_type_id,
                                                      -- line_type_id
                              x_pdoi_line.item_id,
                                                       -- item_id
                              x_pdoi_line.item_revision,
                                                       -- item_revision
                              x_pdoi_line.category_id,
                                                       -- category_id
                              substrb(x_pdoi_line.item_description, 1, 240),
                                                       -- item_description
                              decode(x_pdoi_line.order_type_lookup_code, 'AMOUNT', null, x_pdoi_line.unit_of_measure),
                                                       -- unit_of_measure
                              decode(x_pdoi_line.order_type_lookup_code, 'RATE', NULL, 'FIXED PRICE', NULL, x_allocation_quantity),  -- quantity
                              decode(x_pdoi_line.order_type_lookup_code,'AMOUNT', 1, x_price),                                                       -- unit_price
                              x_pdoi_line.po_min_rel_amount,
                                                       -- min_release_amount
                              x_pdoi_line.ship_to_location_id,
                                                       -- ship_to_location_id
                              x_pdoi_line.need_by_start_date,
                                                       -- need_by_start_date
                              x_pdoi_line.promised_date, -- promised_date
                              p_user_id,               -- last_update_by
                              sysdate,                 -- last_update_date
                              p_user_id,                -- created_by
                              sysdate,                 -- creation_date
                              x_pdoi_header.auction_header_id, -- auction_header_id
                              x_pdoi_header.document_number, -- document_number
                              x_pdoi_line.line_number, -- auction_line_number,
                              x_pdoi_header.bid_number, -- bid_number
                              x_pdoi_line.line_number, -- bid_line_number
			      'Y',          -- orig_from_req_flag
			      x_pdoi_line.job_id, -- job_id
                              x_amount -- amount
 	                             , decode(x_pdoi_line.bid_curr_advance_amount,0,null,x_pdoi_line.bid_curr_advance_amount)
	                             , x_pdoi_line.recoupment_rate_percent
	                             , x_pdoi_line.progress_pymt_rate_percent
	                             , x_pdoi_line.retainage_rate_percent
	                             , x_pdoi_line.Bid_curr_max_retainage_amt
	                             , x_pdoi_line.has_bid_payments_flag  -- Line_loc_populated


                              ) return interface_line_id into x_interface_line_id;

                              x_progress :=
                                  '35: CREATE_PO_STRUCTURE: INSERTING the following data into PO_LINES_INTERFACE: ' ||
                                  'interface_header_id: ' || to_char(x_interface_header_id) || ', ' ||
                                  'interface_line_id: ' || to_char(x_interface_line_id) || ', ' ||
                                  'requisition_line_id: ' || to_char(x_requisition_line_id) || ', ' ||
                                  'line_type_id: ' || to_char(x_pdoi_line.line_type_id) || ', ' ||
                                  'item_id: ' || to_char(x_pdoi_line.item_id) || ', ' ||
                                  'item_revision: ' || x_pdoi_line.item_revision || ', ' ||
                                  'category_id: ' || to_char(x_pdoi_line.category_id) || ', ' ||
                                  'item_description: ' || substrb(x_pdoi_line.item_description, 1, 240) || ', ';

                                  IF (x_pdoi_line.order_type_lookup_code = 'AMOUNT') THEN
                                      x_progress := x_progress || 'unit_of_measure: ' || null || ', ' || 'quantity: ' || to_char(x_allocation_quantity) || ', ' ||
                                                               'unit_price: ' || 1 || ', ';
                                  ELSE
                                      x_progress := x_progress || 'unit_of_measure: ' || x_pdoi_line.unit_of_measure || ' ' || 'quantity: ' || to_char(x_allocation_quantity) || ', ' ||
                                                               'unit_price: ' || to_char(x_price) || ', ';
                                  END IF;

                              x_progress := x_progress ||
                                  'min_release_amount: ' || to_char(x_pdoi_line.po_min_rel_amount) || ', ' ||
                                  'ship_to_location_id: ' || to_char(x_pdoi_line.ship_to_location_id) ||', ' ||
                                  'need_by_start_date: ' || x_pdoi_line.need_by_start_date || ', ' ||
                                  'promised_date: ' || x_pdoi_line.promised_date || ', ' ||
                                  'last_update_by: ' || to_char(p_user_id) || ', ' ||
                                  'created_by: ' || to_char(p_user_id) || ', ' ||
                                  'auction_header_id: ' || to_char(x_pdoi_header.auction_header_id) || ', ' ||
                                  'document_number: ' || x_pdoi_header.document_number || ', ' ||
                                  'auction_line_number: ' || to_char(x_pdoi_line.line_number) || ', ' ||
                                  'bid_number: ' || to_char(x_pdoi_header.bid_number) || ', ' ||
                                  'bid_line_number: ' || to_char(x_pdoi_line.line_number) || ', ' ||
                                  'orig_from_req_flag: ' || 'Y';

				log_message(x_progress);

                       END LOOP; --} -- stop loop over reqBackingBidItem

                       CLOSE reqBackingBidItem;

             END IF; --} -- end-if to check for requisitions

             /*
		rrkulkar-large-auction-support :-

		Once we have inserted all the lines having allocated quantities
		with backing reqs, we need to take care of the following 3 more
		conditions :-

		case-1. No backing requisition for current line OR
		case-2. Lines with backing requisitions have 0 allocation
		        award quantities
		case-3. There is an excess award OR

		In either of the aforementioned 3 cases, we need to
               	insert an additional row into PO_LINES_INTERFACE with the
               	item information from the negotiation line, a null
               	requisition_line_id,  a quantity for the excess award,
               	and a value of 'N' in the orig_from_req_flag column.

	      */

             /*
		rrkulkar-large-auction-support : In case of super-large auctions,
		this case will be satisfied more often than not. Here's what we can do :-

		1. split this insert into 2 cases -
		   1a. use cursor approach for lines with backing reqs. (case-2 and case-3 above)
		   1b. use batching for lines with no backing reqs
	      */

             x_progress := '25: before execess award';

	     log_message(x_progress);

             IF (
		 /* case-2 :- zero allocated quantity*/

                 (x_pdoi_line.line_origination_code = 'REQUISITION' AND
                  sum_of_alloc_quantities.EXISTS(x_line_number) AND
                  sum_of_alloc_quantities(x_line_number) = 0) OR

		 /* case-3 :- excess allocated quantity*/

                 (x_pdoi_line.line_origination_code = 'REQUISITION' AND
                  sum_of_alloc_quantities.EXISTS(x_line_number) AND
                  x_award_quantity > sum_of_alloc_quantities(x_line_number))) THEN

		 --{ -- 2nd loop for SPO outcome

                x_progress := '30: Excess award ' || 'Award Quantity: ' || x_award_quantity;
		log_message(x_progress);

	        IF (x_pdoi_line.order_type_lookup_code = 'RATE' OR
		    x_pdoi_line.order_type_lookup_code = 'FIXED PRICE') THEN
		   x_quantity := NULL;
		ELSIF (sum_of_alloc_quantities.EXISTS(x_line_number)) THEN
                   x_quantity := x_award_quantity - sum_of_alloc_quantities(x_line_number);
                ELSE
                   x_quantity := x_award_quantity;
                END IF;
                           INSERT into PO_LINES_INTERFACE (
                              interface_header_id,
                              interface_line_id,
                              requisition_line_id,
                              line_type_id,
                              item_id,
                              item_revision,
                              category_id,
                              item_description,
                              unit_of_measure,
                              quantity,
                              unit_price,
                              min_release_amount,
                              ship_to_location_id,
                              need_by_date,
                              promised_date,
                              last_updated_by,
                              last_update_date,
                              created_by,
                              creation_date,
                              auction_header_id,
                              auction_display_number,
                              auction_line_number,
                              bid_number,
                              bid_line_number,
                              orig_from_req_flag,
			      job_id,
			      amount
                              , advance_amount
	                          , recoupment_rate
	                          , progress_payment_rate
	                          , retainage_rate
	                          , max_retainage_amount
	                          , Line_loc_populated_flag

                              )

                              values (

                              x_interface_header_id,  -- interface_header_id
                              po_lines_interface_s.nextval,    -- interface_line_id
                              NULL,                   -- requisition_line_id
                              x_pdoi_line.line_type_id,
                                                      -- line_type_id
                              x_pdoi_line.item_id,
                                                       -- item_id
                              x_pdoi_line.item_revision,
                                                       -- item_revision
                              x_pdoi_line.category_id,
                                                       -- category_id
                              substrb(x_pdoi_line.item_description, 1, 240),
                                                       -- item_description
                              decode(x_pdoi_line.order_type_lookup_code, 'AMOUNT', null, x_pdoi_line.unit_of_measure),    -- unit_of_measure
                              x_quantity,   -- quantity
                              decode(x_pdoi_line.order_type_lookup_code,'AMOUNT', 1, x_price),                            -- unit_price
                              x_pdoi_line.po_min_rel_amount, -- min_release_amount
                              x_pdoi_line.ship_to_location_id,
                                                      -- ship_to_location_id
                              x_pdoi_line.need_by_start_date,
                                                       -- need_by_start_date
                              x_pdoi_line.promised_date,
                                                       -- promised_date
                              p_user_id,               -- last_update_by
                              sysdate,                 -- last_update_date
                              p_user_id,               -- created_by
                              sysdate,                 -- creation_date
                              x_pdoi_header.auction_header_id, -- auction_header_id
                              x_pdoi_header.document_number, -- document_number
                              x_pdoi_line.line_number, -- auction_line_number,
                              x_pdoi_header.bid_number, -- bid_number
                              x_pdoi_line.line_number, -- bid_line_number
                              'N',          -- orig_from_req_flag
                              x_pdoi_line.job_id, -- job_id
                              x_amount  -- amount
 	                             , decode(x_pdoi_line.bid_curr_advance_amount,0,null,x_pdoi_line.bid_curr_advance_amount)
	                             , x_pdoi_line.recoupment_rate_percent
	                             , x_pdoi_line.progress_pymt_rate_percent
	                             , x_pdoi_line.retainage_rate_percent
	                             , x_pdoi_line.Bid_curr_max_retainage_amt
	                             , x_pdoi_line.has_bid_payments_flag  -- Line_loc_populated

                              ) return interface_line_id into x_interface_line_id;


                             x_progress :=
                                  '35: CREATE_PO_STRUCTURE: INSERTING the following data into PO_LINES_INTERFACE: ' ||
                                  'interface_header_id: ' || to_char(x_interface_header_id) || ', ' ||
                                  'interface_line_id: ' || to_char(x_interface_line_id) || ', ' ||
                                  'requisition_line_id: ' || null || ', ' ||
                                  'line_type_id: ' || to_char(x_pdoi_line.line_type_id) || ', ' ||
                                  'item_id: ' || to_char(x_pdoi_line.item_id) || ', ' ||
                                  'item_revision: ' || x_pdoi_line.item_revision || ', ' ||
                                  'category_id: ' || to_char(x_pdoi_line.category_id) || ', ' ||
                                  'item_description: ' || substrb(x_pdoi_line.item_description, 1, 240) || ', ';

                                 IF (x_pdoi_line.order_type_lookup_code = 'AMOUNT') THEN
                                      x_progress := x_progress || 'unit_of_measure: ' || null || ', ' ||
                                                    'quantity: ' || x_quantity || ', ' ||
                                                    'unit_price: ' || 1 || ',';
                                 ELSE
                                      x_progress := x_progress || 'unit_of_measure: ' || x_pdoi_line.unit_of_measure || ' ' ||
                                                    'quantity: ' || x_quantity || ', ' ||
                                                    'unit_price: ' || to_char(x_price) || ', ';
                                 END IF;

                             x_progress := x_progress ||
                                  'min_releaes_amount: ' || to_char(x_pdoi_line.po_min_rel_amount) || ', ' ||
                                  'ship_to_location_id: ' || to_char(x_pdoi_line.ship_to_location_id) ||', ' ||
                                  'need_by_start_date: ' || x_pdoi_line.need_by_start_date || ', ' ||
                                  'promised_date: ' || x_pdoi_line.promised_date || ', ' ||
                                  'last_update_by: ' || to_char(p_user_id) || ', ' ||
                                  'created_by: ' || to_char(p_user_id) || ', ' ||
                                  'auction_header_id: ' || to_char(x_pdoi_header.auction_header_id) || ', ' ||
                                  'document_number: ' || x_pdoi_header.document_number || ', ' ||
                                  'auction_line_number: ' || to_char(x_pdoi_line.line_number) || ', ' ||
                                  'bid_number: ' || to_char(x_pdoi_header.bid_number) || ', ' ||
                                  'bid_line_number: ' || to_char(x_pdoi_line.line_number) || ', ' ||
                                  'orig_from_req_flag: ' || 'N' || ', ';


				log_message(x_progress);


             END IF; --} -- End of excess award


	  END LOOP; --} -- stop loop over reqlineLevelInfo

	  close reqlineLevelInfo;

	/* rrkulkar-large-auction-support changes */
   	--------------------------------------------------------------------------------------------------------------
   	--BATCHING FOR OUTCOME = STANDARD PURCHASE ORDER : STARTS HERE
   	--------------------------------------------------------------------------------------------------------------

        --get the number of rows to be copied
        select 	nvl(max(line_number),0)
	into 	l_max_line_number
	from 	pon_bid_item_prices
        where 	bid_number = x_pdoi_header.bid_number;

	l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
	l_commit_flag := FALSE;

	l_batch_start := 1;

        IF (l_max_line_number <l_batch_size) THEN
            l_batch_end := l_max_line_number;
        ELSE
            l_batch_end := l_batch_size;
        END IF;

	log_message('spo batching start: l_batch_size=' || l_batch_size || ' l_batch_start=' || l_batch_start || ' l_batch_end=' || l_batch_end);


	WHILE (l_batch_start <= l_max_line_number) LOOP --{ main-batching-loop--spo


		log_message('spo batching start: l_batch_size=' || l_batch_size || ' l_batch_start=' || l_batch_start || ' l_batch_end=' || l_batch_end);


	  /* case-1: Lines with no backing reqs*/

	  /*
		rrkulkar-large-auction-support : study

		need to verify the resolution of the following columns
		1. quantity
		2. unit_price

		need to find out about x_interface_line_id :- is it used for debugging purposes only?
	  */

          INSERT into PO_LINES_INTERFACE (
		interface_header_id,
		interface_line_id,
		requisition_line_id,
		line_type_id,
		item_id,
		item_revision,
		category_id,
		item_description,
		unit_of_measure,
		quantity,
		unit_price,
		min_release_amount,
		ship_to_location_id,
		need_by_date,
		promised_date,
		last_updated_by,
		last_update_date,
		created_by,
		creation_date,
		auction_header_id,
		auction_display_number,
		auction_line_number,
		bid_number,
		bid_line_number,
		orig_from_req_flag,
		job_id,
		amount
       , advance_amount
	   , recoupment_rate
	   , progress_payment_rate
	   , retainage_rate
	   , max_retainage_amount
	  , Line_loc_populated_flag

                )
	SELECT
                x_interface_header_id,  		-- interface_header_id
                po_lines_interface_s.nextval,    	-- interface_line_id
                NULL,                   		-- requisition_line_id
		paip.line_type_id,			-- line_type_id
		paip.item_id,				-- item_id
		paip.item_revision,			-- item_revision
		paip.category_id,			-- category_id
		substrb(paip.item_description, 1, 240),	-- item_description
		decode(paip.order_type_lookup_code, 'AMOUNT', null, mtluom.unit_of_measure), -- unit_of_measure
		decode(paip.order_type_lookup_code, 'RATE', 	   TO_NUMBER(null),
						    'FIXED PRICE', TO_NUMBER(null),
						    'AMOUNT', 	   pbip.bid_currency_unit_price,
						    pbip.award_quantity),  -- QUANTITY
                decode(paip.order_type_lookup_code,'AMOUNT', 	  1,
						   'FIXED PRICE', TO_NUMBER(NULL)
						   ,nvl2( pbip.award_shipment_number,pbs.bid_currency_unit_price
                           ,pbip.bid_currency_unit_price)), --unit_price
                nvl(pbip.po_bid_min_rel_amount, round(paip.po_min_rel_amount* pbh.rate,fc.precision)), 	-- min_release_amount
                paip.ship_to_location_id, 		-- ship_to_location_id
                paip.need_by_start_date, 		-- need_by_start_date
                pbip.promised_date,			-- promised_date
                p_user_id,               		-- last_update_by
                sysdate,                 		-- last_update_date
                p_user_id,               		-- created_by
                sysdate,                 		-- creation_date
                x_pdoi_header.auction_header_id, 	-- auction_header_id
                x_pdoi_header.document_number, 		-- document_number
                paip.line_number, 			-- auction_line_number,
                pbip.bid_number, 			-- bid_number
                pbip.line_number, 			-- bid_line_number
                'N',          				-- orig_from_req_flag
                paip.job_id, 				-- job_id
                decode(paip.order_type_lookup_code,'FIXED PRICE', pbip.bid_currency_unit_price, TO_NUMBER(NULL)) -- amount
	            , decode(pbip.bid_curr_advance_amount,0,null,pbip.bid_curr_advance_amount)
	            , pbip.recoupment_rate_percent
	            , pbip.progress_pymt_rate_percent
	            , pbip.retainage_rate_percent
	            , pbip.Bid_curr_max_retainage_amt
	            , decode(pbip.has_bid_payments_flag, 'Y', decode((select 1 from dual where exists
		                                                      ( select 1 from pon_bid_payments_shipments where
		                                                        auction_header_id = pbip.auction_header_id and
									bid_number= pbip.bid_number and bid_line_number=pbip.line_number
								        and bid_currency_price <> 0
								       )
								     ),
								    1,'Y','N')
		       ,'N')   --Line_loc_populated

	FROM
                pon_auction_item_prices_all paip,
                pon_bid_item_prices pbip,
                mtl_units_of_measure mtluom,
		pon_bid_headers pbh,
		fnd_currencies fc,
        pon_bid_shipments pbs
	WHERE
		pbip.bid_number 			= p_bid_number 			and
                pbip.auction_header_id 			= p_auction_header_id 		and
                nvl(pbip.award_status, 'NO') 		= 'AWARDED' 			and
                paip.auction_header_id 			= pbip.auction_header_id 	and
		paip.line_number 			= pbip.line_number 		and
		paip.group_type 			NOT IN ('GROUP','LOT_LINE') 	and
		paip.uom_code 				= mtluom.uom_code (+) 		and
		pbh.bid_number 				= pbip.bid_number 		and
		fc.currency_code 			= pbh.bid_currency_code 	and
		nvl(paip.line_origination_code, 'NO')	<> 'REQUISITION'		and
		pbip.line_number			>= l_batch_start		and
		pbip.line_number			<= l_batch_end			and
		pbs.bid_number(+)			= pbip.bid_number		and
		pbs.line_number(+)			= pbip.line_number		and
		pbs.shipment_number(+)		= pbip.award_shipment_number;


		x_progress := '35.1: CREATE_PO_STRUCTURE: STANDARD CASE: END OF BULK INSERT';

		log_message(x_progress);

  		x_progress := '35.1.1: CREATE_PAYMENTS: STANDARD CASE: CHECK IF COMPLEX WORK';

		log_message(x_progress);

  	      -- Insert all Payments for all lines in one go, if any and complex work
	   IF (x_pdoi_header.progress_payment_type IN ('ACTUAL','FINANCE')) THEN
        x_progress := '35.1.5: CREATE_PAYMENTS: STANDARD CASE: IT IS COMPLEX WORK';

		log_message(x_progress);

	      INSERT INTO po_line_locations_interface (
		                             interface_header_id,
		                             interface_line_id,
		                             interface_line_location_id,
		                             payment_type,
		                             shipment_num,
		                             ship_to_location_id,
		                             need_by_date,
		                             promised_date,
		                             quantity,
		                             unit_of_measure,
		                             price_override,
		                             amount,
		                             description,
		                             work_approver_id,
		                             project_id,
		                             task_id,
		                             award_id,
		                             expenditure_type,
		                             expenditure_organization_id,
		                             expenditure_item_date,
		                             auction_payment_id,
		                             bid_payment_id,
		                             last_update_date,
		                             last_updated_by,
		                             creation_date,
		                             created_by )

		                       SELECT
		                             x_interface_header_id, -- interface_header_id
		                             pli.interface_line_id, -- interface_line_id
		                             po_line_locations_interface_s.NEXTVAL,
	                                                                  -- interface_line_location_id
		                             bpys.payment_type_code, -- shipment_type
		                             bpys.payment_display_number, -- shipment_num
		                             nvl(apys.ship_to_location_id,
		                                     paip. ship_to_location_id), -- ship_to_location_id
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                            'Y', paip.need_by_date , apys.need_by_date),  -- need_by_date
		                             bpys.promised_date, -- promised_date
		                             nvl(bpys.quantity, decode(paip.order_type_lookup_code,
	                                                                                        'QUANTITY',
		                                                          pli.quantity, null
	                                                               )
		                                ) , -- quantity. Populate this for RATE and Qty Milestone

		                             nvl2(bpys.uom_code, mtluom.unit_of_measure,
		                                              decode(paip.order_type_lookup_code, 'QUANTITY',
		                                                      (select unit_of_measure from
		                                                         mtl_units_of_measure where uom_code=
		                                                         paip.uom_code),
		                                                      null
		                                                    )
		                                ) , -- unit_of_measure.Populate this for RATE and Qty Milestone

		                              nvl2(bpys.quantity, bpys.bid_currency_price,
	                                            decode(paip.order_type_lookup_code,'QUANTITY',
		                                                        bpys.bid_currency_price, null)
		                                ),  -- price_override. Populate this for RATE and Qty Milestone

		                              nvl2(bpys.quantity, null,
		                                    decode(paip.order_type_lookup_code, 'QUANTITY',
		                                              null, bpys.bid_currency_price)
		                                ),-- amount.Populate this for LUMPSUM and Fixed Price Milestone

		                             bpys.payment_description, -- item_description
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                            'Y',paip.work_approver_user_id, apys.work_approver_user_id),
		                                                               -- Work_approver_user_id

		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                            'Y', paip. project_id , apys.project_id),  -- project_id
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                            'Y', paip. project_task_id , apys.project_task_id),
	                                                                                -- project_task_id
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                             'Y', paip.project_award_id,apys.project_award_id),
	                                                                              -- project_award_id
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                            'Y', paip.project_expenditure_type,
		                             apys.project_expenditure_type),
	                                                                       -- project_expenditure_type
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag,
		                             'Y', paip. project_exp_organization_id,
		                             apys.project_exp_organization_id),
	                                                              -- project_exp_organization_id
		                             decode(x_pdoi_header.supplier_enterable_pymt_flag, 'Y',
		                             paip. project_expenditure_item_date,
		                             apys.project_expenditure_item_date),
	                                                              -- project_expenditure_date
		                             bpys.auction_payment_id ,  -- auction_payment_id
		                             bpys.bid_payment_id, -- bid_payment_id
		                                    sysdate, -- last_update_date
		                             x_user_id, -- last_updated_by
		                             sysdate, -- creation_date
		                             x_user_id -- created_by

		                       FROM  pon_auction_item_prices_all paip,
		                             pon_bid_item_prices pbip,
		                             pon_bid_payments_shipments bpys,
		                             pon_auc_payments_shipments apys,
		                             po_lines_interface pli,
		                             mtl_units_of_measure mtluom
		                       WHERE pbip.bid_number = p_bid_number and
		                             pbip.auction_header_id = p_auction_header_id and
		                             nvl(pbip.award_status, 'NO') = 'AWARDED' and
		                             paip.auction_header_id = pbip.auction_header_id and
		                             paip.line_number = pbip.line_number and
		                             bpys.bid_number = pbip.bid_number and
		                             bpys.bid_line_number = pbip.line_number and
		                             pli.interface_header_id = x_interface_header_id and
		                             pli.auction_line_number = paip.line_number and
		                             pli.auction_header_id = paip.auction_header_id and
		                             bpys.auction_payment_id = apys.payment_id (+) and
		                             bpys.uom_code = mtluom.uom_code (+)  and
					     nvl(bpys.bid_currency_price,0) <> 0 and
                                     	     pbip.line_number			>= l_batch_start	and
                                     	     pbip.line_number			<= l_batch_end;

                 x_progress := '35.1.10: CREATE_PAYMENTS: STANDARD CASE: END INSERTING PAYMENTS';

		         log_message(x_progress);
	     END IF;-- if complex work


		x_progress := '35.2: CREATE_PO_STRUCTURE: STANDARD CASE: BATCH FROM '
					|| l_batch_start ||' TO '||l_batch_end ||' (inclusive)';
		log_message(x_progress);
           	l_batch_start := l_batch_end + 1;

           	IF (l_batch_end + l_batch_size > l_max_line_number) THEN
               		l_batch_end := l_max_line_number;
			l_commit_flag := FALSE;
           	ELSE
               		l_batch_end   := l_batch_end + l_batch_size;
			l_commit_flag := TRUE;
           	END IF;

		/*
			Note from ATG-WF website :-

			You CANNOT commit inside a PL/SQL procedure which is called by the workflow engine.
			If you issue a commit you are committing the workflow state as well as your application
			state. If you do commit and your pl/sql function fails subsequently the workflow engine
			will not be able to rollback to a consistent state.
		*/

		IF(l_commit_flag = TRUE) THEN
			COMMIT;
			x_progress := '35.3: CREATE_PO_STRUCTURE: STANDARD CASE: BATCH-COMMIT SUCCESSFUL ';
			log_message(x_progress);
		END IF;

	END LOOP; --} --end-loop- batching-SPO

   	--------------------------------------------------------------------------------------------------------------
   	--BATCHING FOR OUTCOME = STANDARD PURCHASE ORDER : ENDS HERE
   	--------------------------------------------------------------------------------------------------------------

      END IF; -- End of Standard


      /* Blanket Agreement case: will do bulk insert from one table to another */

      IF (x_pdoi_header.contract_type = 'BLANKET') THEN --{ -- if outcome is BPA

	/* rrkulkar-large-auction-support changes */
   	--------------------------------------------------------------------------------------------------------------
   	--BATCHING FOR OUTCOME = BLANKET PURCHASE AGREEMENT: STARTS HERE
   	--------------------------------------------------------------------------------------------------------------

        --get the number of rows to be copied
        select 	nvl(max(line_number),0)
	into 	l_max_line_number
	from 	pon_bid_item_prices
        where 	bid_number = x_pdoi_header.bid_number;

	-- always reset -> although it is not possible that both bpa+spo cases are satisfied  :)
	l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
	l_commit_flag := FALSE;
	l_rows_processed := 0;

	l_batch_start := 1;

        IF (l_max_line_number <l_batch_size) THEN
            l_batch_end := l_max_line_number;
        ELSE
            l_batch_end := l_batch_size;
        END IF;

	log_message('blanket batching start: l_batch_size=' || l_batch_size || ' l_batch_start=' || l_batch_start || ' l_batch_end=' || l_batch_end);

	WHILE (l_batch_start <= l_max_line_number) LOOP --{ main-batching-loop--spo

			log_message('blanket batching loop: l_batch_size=' || l_batch_size || ' l_batch_start=' || l_batch_start || ' l_batch_end=' || l_batch_end);


                        INSERT into PO_LINES_INTERFACE (
                              interface_header_id,
                              interface_line_id,
                              requisition_line_id,
			      line_type_id,
			      line_num,
                              item_id,
                              item_revision,
                              category_id,
                              ip_category_id,
                              item_description,
			      unit_of_measure,
			      price_break_lookup_code,
                              quantity,
                              committed_amount,
                              unit_price,
                              min_release_amount,
                              ship_to_location_id,
                              need_by_date,
                              promised_date,
                              last_updated_by,
                              last_update_date,
                              created_by,
                              creation_date,
                              auction_header_id,
                              auction_display_number,
                              auction_line_number,
                              bid_number,
                              bid_line_number,
			      orig_from_req_flag,
			      job_id,
			      amount
                              )
		              SELECT
                              x_interface_header_id,  -- interface_header_id
                              po_lines_interface_s.nextval,    -- interface_line_id
                              NULL,                   -- requisition_line_id
			      paip.line_type_id,   -- line_type_id
			      l_rows_processed + rownum,    -- line num
                              paip.item_id,
                                                      -- item_id
                              paip.item_revision,
                                                      -- item_revision
                              paip.category_id,
                                                      -- category_id
                              nvl(paip.ip_category_id, -2),
                                                      -- ip category id
                              substrb(paip.item_description, 1, 240),
                                                      -- item_description
                              decode(paip.order_type_lookup_code, 'AMOUNT', null, mtluom.unit_of_measure),
			                              -- unit_of_measure
			      decode(pbip.price_break_type, 'NONE', null, 'NON-CUMULATIVE', 'NON CUMULATIVE', pbip.price_break_type),
			                                 -- price_break_type
  			      decode(paip.order_type_lookup_code,
				     'AMOUNT', NULL,
                                     'RATE', NULL,
				     'FIXED PRICE', NULL,
				      pbip.award_quantity), -- quantity
                              decode(paip.order_type_lookup_code,
					'AMOUNT', pbip.bid_currency_unit_price,
					'RATE', round(paip.po_agreed_amount*pbh.rate, fc.precision),
					'FIXED PRICE', round(paip.po_agreed_amount*pbh.rate, fc.precision),
				     null),        -- committed_amount
                              decode(paip.order_type_lookup_code,
					'AMOUNT', 1,
					'FIXED PRICE', null,
					nvl2( pbip.award_shipment_number,pbs.bid_currency_unit_price
                           ,pbip.bid_currency_unit_price)), --unit_price
                             nvl(pbip.po_bid_min_rel_amount, round(paip.po_min_rel_amount* pbh.rate, fc.precision)), -- min_release_amount
                              paip.ship_to_location_id,	-- ship_to_location_id
                              paip.need_by_start_date,	-- need_by_start_date
                              pbip.promised_date,	-- promised_date
                              p_user_id,              -- last_update_by
                              sysdate,                -- last_update_date
                              p_user_id,              -- created_by
                              sysdate,                -- creation_date
                              x_pdoi_header.auction_header_id, 	-- auction_header_id
                              x_pdoi_header.document_number, 	-- document_number
                              paip.line_number, 		-- auction_line_number,
                              x_pdoi_header.bid_number, 	-- bid_number
                              paip.line_number, 		-- bid_line_number
			      decode(paip.line_origination_code, 'REQUISITION', 'Y', 'N'),          -- orig_from_req_flag
			      paip.job_id, -- job_id
	                      decode(paip.order_type_lookup_code,
						'FIXED PRICE', round(pbip.bid_currency_unit_price, fc.precision),
						null) -- amount
                        FROM pon_auction_item_prices_all paip,
                             pon_bid_item_prices pbip,
                             mtl_units_of_measure mtluom,
			     pon_bid_headers pbh,
			     fnd_currencies fc,
			     pon_bid_shipments pbs
                       WHERE pbip.bid_number 			= p_bid_number 			and
                             pbip.auction_header_id 		= p_auction_header_id 		and
                             nvl(pbip.award_status, 'NO') 	= 'AWARDED' 			and
                             paip.auction_header_id 		= pbip.auction_header_id 	and
			     paip.line_number 			= pbip.line_number 		and
			     paip.group_type 			NOT IN ('GROUP','LOT_LINE') 	and
                             paip.uom_code 			= mtluom.uom_code (+)		and
			     pbh.bid_number 			= pbip.bid_number 		and
			     fc.currency_code 			= pbh.bid_currency_code 	and
			     pbip.line_number 			>= l_batch_start	 	and
			     pbip.line_number 			<= l_batch_end			and
	     		 pbs.bid_number(+)			= pbip.bid_number		and
			     pbs.line_number(+)			= pbip.line_number		and
	     		 pbs.shipment_number(+)		= pbip.award_shipment_number;

         		l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

                        log_message('Inserting iP Descriptors for lines: ' || l_batch_start || ' to ' || l_batch_end);


                       INSERT_IP_DESCRIPTORS(p_auction_header_id, p_bid_number, x_interface_header_id, p_user_id, fnd_global.login_id, l_batch_start, l_batch_end);

                        log_message('inserting blanket price break information');

		       -- Insert Price Break information
                       INSERT INTO po_lines_interface (
                             interface_header_id,
                             interface_line_id,
                             shipment_type,
                             line_type_id,
                             item_id,
                             item_revision,
                             quantity,
                             price_break_lookup_code,
                             unit_price,
                             price_discount,
                             ship_to_organization_id,
                             ship_to_location_id,
                             last_update_date,
                             last_updated_by,
                             creation_date,
                             created_by,
                             line_num,
                             shipment_num,
                             effective_date,
			     expiration_date,
			     auction_header_id,
                             auction_line_number)
                       SELECT
                             x_interface_header_id, -- interface_header_id
                             po_lines_interface_s.NEXTVAL, -- interface_line_id
                             pbs.shipment_type, -- shipment_type
                             paip.line_type_id, -- line_type_id
                             paip.item_id, -- item_id
                             paip.item_revision, -- item_revision
                             pbs.quantity, -- quantity
			     decode(pbip.price_break_type, 'NONE', null, 'NON-CUMULATIVE', 'NON CUMULATIVE', pbip.price_break_type),
				           -- price_break_type
                             pbs.bid_currency_unit_price, -- unit_price
                             pbs.price_discount, -- price_discount
                             pbs.ship_to_organization_id, -- ship_to_organization_id
                             pbs.ship_to_location_id, -- ship_to_location_id
                             sysdate, -- last_update_date
                             p_user_id, -- last_updated_by
                             sysdate, -- creation_date
                             p_user_id, -- created_by
                             pli.line_num, -- line num
                             pbs.shipment_number, -- shipment_number
                             pbs.effective_start_date, -- effective_date
			     pbs.effective_end_date, -- expiration_date
			     pbs.auction_header_id, -- auction_header_id
			     pbs.auction_line_number -- auction_line_number
                       FROM  pon_auction_item_prices_all 	paip,
     	                     pon_bid_item_prices 		pbip,
			     pon_bid_shipments 			pbs,
                             po_lines_interface 		pli
                       WHERE pbip.bid_number 			= p_bid_number 			and
                             pbip.auction_header_id 		= p_auction_header_id 		and
                             nvl(pbip.award_status, 'NO') 	= 'AWARDED' 			and
                             paip.auction_header_id 		= pbip.auction_header_id 	and
                             paip.line_number 			= pbip.line_number 		and
  			     pbs.bid_number 			= p_bid_number 			and
			     pli.interface_header_id 		= x_interface_header_id 	and
                             pli.auction_line_number 		= paip.line_number 		and
			     pli.auction_header_id 		= paip.auction_header_id 	and
			     pbs.shipment_type = 'PRICE BREAK'      and
			     pbip.line_number 			= pbs.line_number		and
			     pbip.line_number			>= l_batch_start		and
			     pbip.line_number			<= l_batch_end			;


		       -- Insert Line Price Differentials
		       INSERT INTO po_price_diff_interface
			 (price_diff_interface_id,
			  price_differential_num,
			  entity_type,
			  interface_header_id,
			  interface_line_id,
			  price_type,
			  enabled_flag,
			  min_multiplier,
			  max_multiplier,
			  last_update_date,
			  last_updated_by,
			  creation_date,
			  created_by,
			  last_update_login)
		       SELECT
			 po_price_diff_interface_s.NEXTVAL, -- price_diff_interface_id
			 ppd.price_differential_number, -- price_differential_num
			 'BLANKET LINE', -- entity_type
			 x_interface_header_id, -- interface_line_id
			 pli.interface_line_id, -- interface_line_id
			 ppd.price_type, -- price_type
			 'Y', -- enabled_flag
			 ppd.multiplier, -- min_multiplier
			 pbpd.multiplier, -- max_multiplier
			 sysdate, -- last_update_date
			 p_user_id, -- last_updated_by
			 sysdate, -- creation_date,
			 p_user_id, -- created_by
			 fnd_global.login_id -- last_update_login
		       FROM pon_price_differentials ppd,
			 pon_bid_item_prices pbip,
			 pon_bid_price_differentials pbpd,
			 pon_auction_headers_all pah,
			 po_lines_interface pli
		       WHERE	pbip.bid_number 		= p_bid_number
			 AND	nvl(pbip.award_status, 'NO') 	= 'AWARDED'
			 AND	pbip.auction_header_id 		= ppd.auction_header_id
			 AND	pbip.line_number 		= ppd.line_number
			 AND    ppd.shipment_number 		= -1
			 AND    p_bid_number 			= pbpd.bid_number(+)
			 AND    ppd.line_number 		= pbpd.line_number(+)
			 AND    ppd.shipment_number 		= pbpd.shipment_number(+)
			 AND    ppd.price_differential_number 	= pbpd.price_differential_number(+)
			 AND	pah.auction_header_id 		= ppd.auction_header_id
			 AND 	pli.interface_header_id 	= x_interface_header_id
			 AND	pli.auction_line_number 	= ppd.line_number
			 AND	pli.auction_header_id 		= ppd.auction_header_id
			 AND    pli.shipment_num 		IS NULL
			 AND    pbip.line_number		>= l_batch_start
			 AND	pbip.line_number		<=  l_batch_end;

		       -- Insert Price Break Price Differentials
		       INSERT INTO po_price_diff_interface
			 (price_diff_interface_id,
			  price_differential_num,
			  entity_type,
			  interface_header_id,
			  interface_line_id,
			  price_type,
			  enabled_flag,
			  min_multiplier,
			  max_multiplier,
			  last_update_date,
			  last_updated_by,
			  creation_date,
			  created_by,
			  last_update_login)
		       SELECT
			 po_price_diff_interface_s.NEXTVAL, -- price_diff_interface_id
			 ppd.price_differential_number, -- price_differential_num
			 'PRICE BREAK', -- entity_type
			 x_interface_header_id, -- interface_header_id
			 pli.interface_line_id, -- interface_line_id
			 ppd.price_type, -- price_type
			 'Y', -- enabled_flag
			 ppd.multiplier, -- min_multiplier
			 pbpd.multiplier, -- max_multiplier
			 sysdate, -- last_update_date
			 p_user_id, -- last_updated_by
			 sysdate, -- creation_date,
			 p_user_id, -- created_by
			 fnd_global.login_id -- last_update_login
		       FROM pon_price_differentials ppd,
			 pon_bid_item_prices pbip,
			 (select pbpd.bid_number, pbpd.line_number,
			         pbpd.shipment_number, pbs.auction_shipment_number,
			         pbpd.price_differential_number, pbpd.price_type,
			         pbpd.multiplier, pbpd.auction_header_id
			  from 	pon_bid_price_differentials pbpd, pon_bid_shipments pbs
			  where pbs.bid_number = p_bid_number
			  and  	pbs.line_number = pbpd.line_number
			  and 	pbs.shipment_number = pbpd.shipment_number) pbpd,
			 pon_bid_shipments pbs,
			 pon_auction_headers_all pah,
			 po_lines_interface pli
		       WHERE pbip.bid_number 			= p_bid_number
			 AND nvl(pbip.award_status, 'NO') 	= 'AWARDED'
			 AND pbip.bid_number 			= pbs.bid_number
			 AND pbip.line_number 			= pbs.line_number
			 AND pbs.auction_header_id 		= ppd.auction_header_id
			 AND pbs.line_number 			= ppd.line_number
			 AND pbs.auction_shipment_number 	= ppd.shipment_number
			 AND pah.auction_header_id 		= ppd.auction_header_id
			 AND ppd.line_number 			= pbpd.line_number(+)
			 AND ppd.shipment_number 		= pbpd.auction_shipment_number(+)
			 AND ppd.price_differential_number 	= pbpd.price_differential_number(+)
			 AND p_bid_number 			= pbpd.bid_number(+)
			 AND pli.interface_header_id 		= x_interface_header_id
			 AND pli.auction_line_number 		= pbs.line_number
			 AND pli.auction_header_id 		= pbs.auction_header_id
			 AND pli.shipment_num 			= pbs.shipment_number
			 AND pbip.line_number			>= l_batch_start
			 AND pbip.line_number			<=  l_batch_end;

			/*
			       -- DEBUG CODE
			       -- ALWAYS COMMENTED OUT

		       		INSERT INTO po_lines_interface_debug
		 		(SELECT * FROM po_lines_interface WHERE interface_header_id =  x_interface_header_id);

		        	INSERT INTO po_price_diff_interface_debug
				(SELECT * FROM po_price_diff_interface WHERE interface_header_id =  x_interface_header_id);
			*/

                        x_progress := '38: CREATE_PO_STRUCTURE: BLANKET CASE: END OF BULK INSERT';

			log_message(x_progress);

			 x_progress := '39: CREATE_PO_STRUCTURE: BLANKET CASE: BATCH FROM '
					|| l_batch_start ||' TO '|| l_batch_end ||' (inclusive)';

			log_message(x_progress);

           		l_batch_start := l_batch_end + 1;

           		IF (l_batch_end + l_batch_size > l_max_line_number) THEN
               			l_batch_end := l_max_line_number;
				l_commit_flag := FALSE;
           		ELSE
               			l_batch_end := l_batch_end + l_batch_size;
				l_commit_flag := TRUE;
           		END IF;


			/*
				Note from ATG-WF website :-

				You CANNOT commit inside a PL/SQL procedure which is called by the workflow engine.
				If you issue a commit you are committing the workflow state as well as your application
				state. If you do commit and your pl/sql function fails subsequently the workflow engine
				will not be able to rollback to a consistent state.
			*/

			IF(l_commit_flag = TRUE) THEN
				COMMIT;
				x_progress := '40: CREATE_PO_STRUCTURE: BLANKET CASE: BATCH-COMMIT SUCCESSFUL ';
				log_message(x_progress);
			END IF;


     	END LOOP; --} -- end-main-batching-loop
   	--------------------------------------------------------------------------------------------------------------
	--BATCHING FOR OUTCOME = BLANKET PURCHASE AGREEMENT: ENDS HERE
	--------------------------------------------------------------------------------------------------------------


      END IF; --} --if outcome is BPA

      /* setting out parameters */

      p_interface_header_id := x_interface_header_id;
      p_pdoi_header := x_pdoi_header;


EXCEPTION

     when others then

          IF (headerLevelInfo%ISOPEN) THEN
              close headerLevelInfo;
          END IF;

          IF (reqlineLevelInfo%ISOPEN) THEN
              close reqlineLevelInfo;
          END IF;

          IF (reqBackingBidItem%ISOPEN) THEN
              close reqBackingBidItem;
          END IF;

          IF (sumOfReqAllocQuantities%ISOPEN) THEN
              close sumOfReqAllocQuantities;
          END IF;

          p_error_code := 'FAILURE';
          p_error_message := SUBSTRB(SQLERRM, 1, 500);

	  log_message('CREATE_PO_STRUCTURE : FATAL_ERROR : ' || p_error_code || ' ' || p_error_message);


END CREATE_PO_STRUCTURE;


PROCEDURE INSERT_IP_DESCRIPTORS(p_auction_header_id      IN  NUMBER,
                                p_bid_number             IN  NUMBER,
                                p_interface_header_id    IN  NUMBER,
                                p_user_id                IN  NUMBER,
                                p_login_id               IN  NUMBER,
                                p_batch_start            IN  NUMBER,
                                p_batch_end              IN  NUMBER)  IS


l_cursorName NUMBER;
l_cursorResult NUMBER;

TYPE NUMBER_LIST is TABLE of NUMBER
                   INDEX BY BINARY_INTEGER;
TYPE VARCHAR_LIST is TABLE of VARCHAR2(32767)
                   INDEX BY BINARY_INTEGER;


-- holds the values to be inserted into the interface tables
l_numValues NUMBER_LIST; -- holds descriptor values of number type
l_txtValues VARCHAR_LIST; -- holds descriptor values of text type
l_transTxtValues VARCHAR_LIST;  -- holds descriptor values of translateable text type

-- empty tables for clearing/resetting above datastructures
l_emptyNumValues NUMBER_LIST;
l_emptyTxtValues VARCHAR_LIST;
l_emptyTransTxtValues VARCHAR_LIST;

-- keeps track of the size of the tables
l_numValuesCount NUMBER;
l_txtValuesCount NUMBER;
l_transTxtValuesCount NUMBER;

l_cur_interface_line_id NUMBER;
l_cur_attr_values_id NUMBER;
l_cur_attr_values_tlp_id NUMBER;
l_cur_item_description pon_auction_item_prices_all.item_description%TYPE;
l_cur_ip_category_id NUMBER;
l_cur_item_id NUMBER;
l_cur_org_id NUMBER;
l_language_code pon_auction_headers_all.language_code%TYPE;

l_po_attr_values_stmt VARCHAR2(32767);
l_po_attr_values_tlp_stmt VARCHAR2(32767);

l_po_attr_values_cols VARCHAR2(32767);
l_po_attr_values_vals VARCHAR2(32767);

l_po_attr_values_tlp_cols VARCHAR2(32767);
l_po_attr_values_tlp_vals VARCHAR2(32767);


CURSOR descriptors IS
          SELECT pbip.line_number,
                 pli.interface_line_id,
                 paip.item_description,
                 nvl(paip.ip_category_id, -2) ip_category_id,
                 nvl(paip.item_id, -2) item_id,
                 paip.org_id,
                 decode(icx.type, 0, 'TXT', 1, 'NUM', 2, 'TRANS') datatype,
                 icx.stored_in_table,
                 icx.stored_in_column,
                 pbav.value,
                 paa.attribute_name
          FROM   pon_bid_item_prices pbip,
                 pon_auction_item_prices_all paip,
                 po_lines_interface pli,
                 pon_bid_attribute_values pbav,
                 pon_auction_attributes paa,
                 icx_cat_agreement_attrs_v icx
          WHERE  pbip.auction_header_id = p_auction_header_id and
                 pbip.bid_number = p_bid_number and
                 nvl(pbip.award_status, 'NO') = 'AWARDED' and
                 pbip.line_number >= p_batch_start and
                 pbip.line_number <= p_batch_end and
                 pbip.auction_header_id = paip.auction_header_id and
                 pbip.line_number = paip.line_number and
                 pli.interface_header_id = p_interface_header_id and
                 pbip.auction_header_id = pli.auction_header_id and
                 pbip.line_number = pli.auction_line_number and
                 pbip.auction_header_id = pbav.auction_header_id (+) and
                 pbip.bid_number = pbav.bid_number (+) and
                 pbip.line_number = pbav.line_number (+) and
                 pbav.auction_header_id = paa.auction_header_id (+) and
                 pbav.line_number = paa.line_number (+) and
                 pbav.sequence_number = paa.sequence_number (+) and
                 paa.ip_category_id (+) is not null and
                 paa.ip_category_id = icx.rt_category_id (+) and
                 paa.ip_descriptor_id = icx.attribute_id (+) and
                 icx.language (+) = userenv('LANG')
         ORDER BY interface_line_id asc, decode(datatype, 'NUM', 0, 'TXT', 1, 2) asc;

descriptor descriptors%ROWTYPE;

l_num_txt_offset NUMBER := 11;
l_trans_txt_offset NUMBER := 13;

BEGIN

  select language_code
  into   l_language_code
  from   pon_auction_headers_all
  where  auction_header_id = p_auction_header_id;


  l_cursorName := DBMS_SQL.Open_Cursor;
  l_cur_interface_line_id := -9999;

  OPEN descriptors;
  LOOP

    FETCH descriptors INTO descriptor;
    IF (descriptors%NOTFOUND OR
        descriptor.interface_line_id <> l_cur_interface_line_id) THEN

      -- process number and text descriptors
      IF (l_cur_interface_line_id <> -9999) THEN

         l_po_attr_values_stmt :=
              'insert into po_attr_values_interface(' ||
                 'interface_header_id, ' ||
                 'interface_line_id, ' ||
                 'interface_attr_values_id, ' ||
                 'ip_category_id, ' ||
                 'inventory_item_id, ' ||
                 'org_id, ' ||
                 'last_update_login, ' ||
                 'last_updated_by, ' ||
                 'last_update_date, ' ||
                 'created_by, ' ||
                 'creation_date' ||
                  l_po_attr_values_cols ||
              ') values('||
                 ':1, '  ||
                 ':2, '  ||
                 ':3, '  ||
                 ':4, '  ||
                 ':5, '  ||
                 ':6, '  ||
                 ':7, '  ||
                 ':8, '  ||
                 ':9, '  ||
                 ':10, ' ||
                 ':11'   ||
                  l_po_attr_values_vals ||
              ')';

         log_message(l_po_attr_values_stmt);

         DBMS_SQL.Parse(l_cursorName, l_po_attr_values_stmt, DBMS_SQL.NATIVE);

         DBMS_SQL.Bind_Variable(l_cursorName, ':1', p_interface_header_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':2', l_cur_interface_line_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':3', l_cur_attr_values_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':4', l_cur_ip_category_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':5', l_cur_item_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':6', l_cur_org_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':7', p_login_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':8', p_user_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':9', sysdate);
         DBMS_SQL.Bind_Variable(l_cursorName, ':10', p_user_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':11', sysdate);

         FOR i in 1 .. l_numValuesCount
         LOOP
           DBMS_SQL.Bind_Variable(l_cursorName, ':' || (i+l_num_txt_offset), l_numValues(i));
         END LOOP;

         FOR i in 1 ..l_txtValuesCount
         LOOP
           DBMS_SQL.Bind_Variable(l_cursorName, ':' || (i+l_num_txt_offset+l_numValuesCount), l_txtValues(i));
         END LOOP;

         l_cursorResult := DBMS_SQL.Execute(l_cursorName);

      END IF;

      -- process translateable text descriptors
      IF (l_cur_interface_line_id <> -9999) THEN

         l_po_attr_values_tlp_stmt :=
              'insert into po_attr_values_tlp_interface(' ||
                 'interface_header_id, ' ||
                 'interface_line_id, ' ||
                 'interface_attr_values_tlp_id, ' ||
                 'ip_category_id, ' ||
                 'inventory_item_id, ' ||
                 'org_id, ' ||
                 'language, ' ||
                 'description, ' ||
                 'long_description, ' ||
                 'last_update_login, ' ||
                 'last_updated_by, ' ||
                 'last_update_date, ' ||
                 'created_by, ' ||
                 'creation_date' ||
                  l_po_attr_values_tlp_cols ||
              ') values('||
                 ':1, '  ||
                 ':2, '  ||
                 ':3, '  ||
                 ':4, '  ||
                 ':5, '  ||
                 ':6, '  ||
                 ':7, '  ||
                 ':8, '  ||
                 ':9, '  ||
                 ':10, '  ||
                 ':11, ' ||
                 ':12, ' ||
                 ':13, ' ||
                 ':14'   ||
                  l_po_attr_values_tlp_vals ||
              ')';

         log_message(l_po_attr_values_tlp_stmt);

         DBMS_SQL.Parse(l_cursorName, l_po_attr_values_tlp_stmt, DBMS_SQL.NATIVE);

         DBMS_SQL.Bind_Variable(l_cursorName, ':1', p_interface_header_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':2', l_cur_interface_line_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':3', l_cur_attr_values_tlp_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':4', l_cur_ip_category_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':5', l_cur_item_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':6', l_cur_org_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':7', l_language_code);
         DBMS_SQL.Bind_Variable(l_cursorName, ':8', SubStrB(l_cur_item_description,1,240));
         DBMS_SQL.Bind_Variable(l_cursorName, ':9', SubStrB(l_cur_item_description,1,2000));
         DBMS_SQL.Bind_Variable(l_cursorName, ':10', p_login_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':11', p_user_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':12', sysdate);
         DBMS_SQL.Bind_Variable(l_cursorName, ':13', p_user_id);
         DBMS_SQL.Bind_Variable(l_cursorName, ':14', sysdate);

         FOR i in 1 .. l_transTxtValuesCount
         LOOP
           DBMS_SQL.Bind_Variable(l_cursorName, ':' || (i+l_trans_txt_offset), l_transTxtValues(i));
         END LOOP;

         l_cursorResult := DBMS_SQL.Execute(l_cursorName);

      END IF;

      EXIT WHEN descriptors%NOTFOUND;

      -- initialize/reset variables on line change

      l_cur_interface_line_id := descriptor.interface_line_id;

      select po_attr_values_interface_s.nextval
      into   l_cur_attr_values_id
      from   dual;

      select po_attr_values_tlp_interface_s.nextval
      into   l_cur_attr_values_tlp_id
      from   dual;

      l_cur_item_description := descriptor.item_description;
      l_cur_ip_category_id := descriptor.ip_category_id;
      l_cur_item_id := descriptor.item_id;
      l_cur_org_id := descriptor.org_id;

      l_po_attr_values_cols := '';
      l_po_attr_values_vals := '';

      l_po_attr_values_tlp_cols := '';
      l_po_attr_values_tlp_vals := '';

      l_numValues := l_emptyNumValues;
      l_txtValues := l_emptyTxtValues;
      l_transTxtValues := l_emptyTxtValues;

      l_numValuesCount := 0;
      l_txtValuesCount := 0;
      l_transTxtValuesCount := 0;


    END IF;


    CASE descriptor.datatype
    WHEN 'NUM' THEN
         l_numValuesCount := l_numValuesCount + 1;
         l_numValues(l_numValuesCount) := to_number(descriptor.value);
         l_po_attr_values_cols := l_po_attr_values_cols || ', ' || descriptor.stored_in_column;
         l_po_attr_values_vals := l_po_attr_values_vals || ', ' || ':' || to_char(l_numValuesCount + l_num_txt_offset);

    WHEN 'TXT' THEN
         l_txtValuesCount := l_txtValuesCount + 1;
         l_txtValues(l_txtValuesCount) := descriptor.value;
         l_po_attr_values_cols := l_po_attr_values_cols || ', ' || descriptor.stored_in_column;
         l_po_attr_values_vals := l_po_attr_values_vals || ', ' || ':' || to_char(l_txtValuesCount + l_num_txt_offset + l_numValuesCount);

    WHEN 'TRANS' THEN
         l_transTxtValuesCount := l_transTxtValuesCount + 1;
         l_transTxtValues(l_transTxtValuesCount) := descriptor.value;
         l_po_attr_values_tlp_cols := l_po_attr_values_tlp_cols || ', ' || descriptor.stored_in_column;
         l_po_attr_values_tlp_vals := l_po_attr_values_tlp_vals || ', ' || ':' || to_char(l_transTxtValuesCount + l_trans_txt_offset);
    ELSE
         NULL;
    END CASE;


  END LOOP;
  CLOSE descriptors;

  IF DBMS_SQL.IS_OPEN(l_cursorName) THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursorName);
  END IF;


END INSERT_IP_DESCRIPTORS;


procedure GENERATE_POS(p_auction_header_id           IN    NUMBER,       -- 1
                       p_user_name                   IN    VARCHAR2,     -- 2
                       p_user_id                     IN    NUMBER,       -- 3
		       p_resultout		     OUT NOCOPY VARCHAR2) IS



--x_auction_header_id NUMBER;
--x_user_name fnd_user.user_name%TYPE;

x_language_code VARCHAR2(4);
x_round_number NUMBER;
x_line_number NUMBER;
x_bid_number NUMBER;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
x_po_header_id NUMBER;
x_order_number pon_bid_headers.order_number%TYPE;
x_interface_header_id NUMBER;
x_last_update_date pon_auction_headers_all.last_update_date%TYPE;
x_auction_start_date DATE;
x_auction_end_date   DATE;
x_tp_time_zone       VARCHAR2(80);
x_tp_time_zone1      VARCHAR2(80);
x_award_summary_url  VARCHAR2(2000);
x_alloc_summary_url  VARCHAR2(2000);
x_allocate_item_url     VARCHAR2(2000);
x_auction_org_name   VARCHAR2(80);

x_doctype_id  NUMBER;
x_conterms_exist_flag pon_auction_headers_all.conterms_exist_flag%TYPE;
x_contract_doc_name  VARCHAR(20);

/* Error code can take on the following values:

   1-  Success
   2-  Failure due to manual numbering (duplicates)
   3-  System/Other Errors
   4-  Auction Error (CREATE_PO_STRUCTURE throws an exception)

*/

x_error_code NUMBER;
x_return_status VARCHAR2(1);
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_failure_code varchar2(10);
x_error_msg varchar2(1000);
x_num_lines_processed NUMBER;
x_pdoi_header PDOIheader;
v_old_policy varchar2(1);
v_old_org_id number;
x_preview_date_notspec VARCHAR2(60);
x_preview_date  DATE;

/* returns all awarded bids where a PO was not created*/

/* rrkulkar-large-auction-support :

Changed this cursor to return active bids only,

Modified the old 'where' clause which was like this :-

.... and nvl(pbh.bid_status, 'NONE') not in ('ARCHIVED', 'DISQUALIFIED') and ...
*/

CURSOR awardedBids IS
             SELECT   	pbh.bid_number
             FROM     	pon_bid_headers pbh
             WHERE    	pbh.auction_header_id = p_auction_header_id 	and
			nvl(pbh.bid_status, 'NONE') = 'ACTIVE' 		and
                        pbh.po_header_id is NULL 			and
         	        nvl(pbh.award_status, 'NO') IN ('AWARDED', 'PARTIAL')
             GROUP BY pbh.bid_number;

BEGIN

     	x_progress := '10: GENERATE_POS: Start of PO Creation Script';

	log_message(x_progress);

	-- initialize to success (3 possible values S=Success; F=Failure; W=Warning)
	p_resultout := 'S';

	select 	open_bidding_date,
		close_bidding_date,
		view_by_date
	into 	x_auction_start_date,
		x_auction_end_date,
		x_preview_date
	from 	pon_auction_headers_all
	where 	auction_header_id = p_auction_header_id;

      /* Lock auction table to prevent concurrency errors */
      /* added doctype_id, conterms_exist_flag for contract terms */

      SELECT last_update_date, doctype_id, conterms_exist_flag
      INTO   x_last_update_date, x_doctype_id, x_conterms_exist_flag
      FROM   pon_auction_headers_all
      WHERE  auction_header_id = p_auction_header_id
      FOR UPDATE;

      x_contract_doc_name := PON_CONTERMS_UTL_PVT.get_response_doc_type(x_doctype_id);


      PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(p_user_name, x_language_code);

      PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, x_language_code);
         OPEN awardedBids;
         x_progress := '40: GENERATE_POS: Going through the awarded bids';

	log_message(x_progress);

         LOOP
                /* for each active bid where a PO was not created  */
                   FETCH awardedBids into x_bid_number;
                   EXIT WHEN awardedBids%NOTFOUND;
                   x_error_code := PO_SUCCESS;
                   x_progress := '50: GENERATE_POS: Just Before CREATE_PO_STRUCTURE: ' ||
                                 'Bid Number: ' || x_bid_number;

                   x_po_header_id := NULL; --Initializing the po_header_id; bug: 18243005

		   log_message(x_progress);

                   /* Establish a savepoint */

                   --savepoint PON_CREATE_PO_DOCUMENTS;

                   /* This call will create the award purchase order structure
                      in PDOI */

		   log_message('2.1 Invoke CREATE_PO_STRUCTURE for auction ' || p_auction_header_id || ' and bid  ' || x_bid_number || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

                   CREATE_PO_STRUCTURE(p_auction_header_id,
                                       x_bid_number,
				       p_user_id,
                                       x_interface_header_id,
                                       x_pdoi_header,
                                       x_failure_code,
                                       x_error_msg);

		   log_message('2.2. CREATE_PO_STRUCTURE completed for auction ' || p_auction_header_id || ' and bid  ' || x_bid_number || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));


                   IF (x_failure_code = 'FAILURE') THEN

		      log_message( substrb(x_progress || SQLERRM, 1, 4000));

                      x_error_code := SOURCING_SYSTEM_ERROR;

                   END IF;


                   x_order_number := x_pdoi_header.order_number;

                   /* call the PO's PL/SQL program to create the Purchase
                      from the new rows in PDOI */

                   IF (x_error_code = PO_SUCCESS) THEN

                       x_progress := '60: GENERATE_POS: Just before creating document';

			log_message(x_progress);

                       -- Get the current policy
                       v_old_policy := mo_global.get_access_mode();
                       v_old_org_id := mo_global.get_current_org_id();

                       if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                         fnd_log.string(
                                fnd_log.level_statement,
                                g_module || '.check_unique_order_number',
                                'old_policy = ' || v_old_policy || ', old_org_id = ' || v_old_org_id);
                       end if;

                       -- Set the connection's policy context
                       mo_global.set_policy_context('S', x_pdoi_header.org_id);

                       --create BPA/CPA/SPO
                       IF x_pdoi_header.contract_type = 'CONTRACT' THEN
                           x_progress := '65: GENERATE_POS: Just before create_CPA interface id '||x_interface_header_id;
                               log_message(x_progress);
                               x_progress := '65.1: GENERATE_POS: Just before create_CPA auction header id '||p_auction_header_id;
                               log_message(x_progress);
                               x_progress := '65.2: GENERATE_POS: Just before create_CPA bid number '||x_bid_number;
                               log_message(x_progress);
                               x_progress := '65.3: GENERATE_POS: Just before create_CPA conterms flag '||x_conterms_exist_flag;
                               log_message(x_progress);
                               x_progress := '65.4: GENERATE_POS: Just before create_CPA conterms doc type '||x_contract_doc_name;
                               log_message(x_progress);


                           PO_SOURCING_GRP.CREATE_CPA(
                             p_api_version     => 1.0,
                             p_init_msg_list   => FND_API.G_TRUE,
                             p_commit          => FND_API.G_FALSE,
                             p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             x_return_status   => x_return_status,
                             p_interface_header_id => x_interface_header_id,
                             p_auction_header_id  =>  p_auction_header_id ,
                             p_bid_number          => x_bid_number ,
                             p_sourcing_k_doc_type  =>   x_contract_doc_name,
                             p_conterms_exist_flag => x_conterms_exist_flag,
                             p_document_creation_method => 'AWARD_SOURCING',
                             x_document_id              => x_po_header_id,
                             x_document_number          => x_order_number
                          );
                          x_progress := '66: GENERATE_POS: Just after create_cpa status:'||x_return_status;


                               log_message(x_progress);
                               x_progress := '66.1: GENERATE_POS: Just after create_CPA order number '||x_order_number;
                               log_message(x_progress);
                               x_progress := '66.2: GENERATE_POS: Just after create_CPA po header id  '||x_po_header_id;
                               log_message(x_progress);

                         IF (x_return_status = FND_API.g_ret_sts_success
                                       AND x_order_number is NOT NULL)   THEN
	                         x_error_code := PO_SUCCESS;
	                     ELSIF (x_return_status = FND_API.g_ret_sts_error
                                   OR x_return_status = FND_API.g_ret_sts_unexp_error) THEN
	                         x_error_code := PO_PDOI_ERROR;
	                         IF x_msg_count = 1 THEN
	                              x_error_msg := x_msg_data;
	                         ELSIF (x_msg_count > 0) THEN
	                              x_error_msg := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST, FND_API.G_FALSE);
	                         END IF;-- msg_count

                           x_progress := substrb('67: GENERATE_POS: create cpa error:'||x_error_msg, 1,4000);

			   log_message(x_progress);


	                END IF;-- return status
                        -- delete the interface record irrespective of whether success or failure

                        x_progress := '68: GENERATE_POS: Before call to Delete interface header id '||x_interface_header_id;

			log_message(x_progress);

                        PO_SOURCING_GRP.DELETE_INTERFACE_HEADER(
                             p_api_version     => 1.0,
                             p_init_msg_list   => FND_API.G_FALSE,
                             p_commit          => FND_API.G_FALSE,
                             p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             x_return_status   => x_return_status,
                             p_interface_header_id => x_interface_header_id
                          );
                         x_progress := '68.1: GENERATE_POS: Just after call to Delete interface header status:'||x_return_status;

			 log_message(x_progress);

                         IF (x_return_status <> FND_API.g_ret_sts_success)   THEN
	                        x_error_code := PO_DELETE_ERROR;
	                         IF x_msg_count = 1 THEN
	                              x_error_msg := x_msg_data;
	                         ELSIF (x_msg_count > 0) THEN
	                              x_error_msg := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST, FND_API.G_FALSE);
	                         END IF;-- msg_count
                           x_progress := substrb('68.2: GENERATE_POS: delete interface header error:'||x_error_msg, 1,4000);

			   log_message(x_progress);

                         END IF;-- x_return_status
                       ELSE  -- else if contracttype is bpa or spo

                         x_progress := '69: GENERATE_POS: Just before create_documents with parameters : x_interface_header_id ='
					|| x_interface_header_id || ' org_id =' || x_pdoi_header.org_id || ' x_po_header_id ='
					|| x_po_header_id || ' x_num_lines_processed =' || x_num_lines_processed
					|| ' x_contract_doc_name =' || x_contract_doc_name || ' x_conterms_exist_flag = '
					|| x_conterms_exist_flag;

			 log_message(x_progress);


			 log_message('2.3 Invoke PO_INTERFACE_S.CREATE_DOCUMENTS for auction ' || p_auction_header_id || ' and bid  ' || x_bid_number || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

                         po_interface_s.create_documents(P_API_VERSION 	 		=> 1.0,
                                                       	 X_RETURN_STATUS 		=> x_return_status,
                                                       	 X_MSG_COUNT	 		=> x_msg_count,
                                                       	 X_MSG_DATA	 		=> x_msg_data,
                                                       	 P_BATCH_ID	 		=> x_interface_header_id,
                                                       	 P_REQ_OPERATING_UNIT_ID	=> x_pdoi_header.org_id,
                                                       	 P_PURCH_OPERATING_UNIT_ID	=> x_pdoi_header.org_id,
                                                       	 X_DOCUMENT_ID			=> x_po_header_id,
                                                       	 X_NUMBER_LINES			=> x_num_lines_processed,
                                                       	 X_DOCUMENT_NUMBER		=> x_order_number,
                                                       	 P_SOURCING_K_DOC_TYPE		=> x_contract_doc_name,
                                                       	 P_CONTERMS_EXIST_FLAG		=> x_conterms_exist_flag,
                                                       	 P_DOCUMENT_CREATION_METHOD	=> 'AWARD_SOURCING');

			 log_message('2.4. Completed PO_INTERFACE_S.CREATE_DOCUMENTS for auction ' || p_auction_header_id || ' and bid  ' || x_bid_number || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

                         --
                         -- Derive x_error_code based on x_return_status
                         --
		         log_message('70.GENERATE_POS: Just after create_documents: x_return_status=' || x_return_status || ' x_num_lines_processed=' || x_num_lines_processed || ' x_order_number=' || x_order_number);



                         IF (x_return_status = FND_API.g_ret_sts_success
                           AND x_num_lines_processed >0 AND x_order_number is NOT NULL)
                         THEN
                           x_error_code := PO_SUCCESS;
                         ELSIF (x_return_status = PO_INTERFACE_S.G_RET_STS_DUP_DOC_NUM) THEN
                           x_error_code := DUPLICATE_PO_NUMBER;
                         ELSE
                           x_error_code := PO_SYSTEM_ERROR;
                         END IF;


			log_message('after create_documents: x_error_code=' || x_error_code);

                         IF (x_error_code <>  PO_SUCCESS) THEN
				null;
                            --rollback to savepoint PON_CREATE_PO_DOCUMENTS;
                         END IF;

                       END IF;--END  if contractType is CONTRACT

                       -- Set the policy context back
                       mo_global.set_policy_context(v_old_policy,v_old_org_id);

                   END IF;

                   IF (x_error_code =  PO_SUCCESS) THEN
                       x_pdoi_header.order_number := x_order_number;
                   END IF;


                   UPDATE pon_bid_headers
                   SET  po_header_id = decode(x_error_code, PO_SUCCESS, x_po_header_id, null),
                        order_number = x_order_number,
                        po_error_code = x_error_code,
                        po_error_msg = x_error_msg,
                        po_wf_creation_rnd = decode(x_error_code, PO_SUCCESS, x_round_number, po_wf_creation_rnd)
                   where auction_header_id = p_auction_header_id and
                         bid_number = x_bid_number;


                   x_progress := '70: GENERATE_POS: After po creation: ' ||
                                'Bid Number: ' || x_bid_number || ', ' ||
                                'PO Header ID: ' || x_po_header_id || ', ' ||
                                'PO Order Number: ' || x_order_number || ', ' ||
                                'Error Code: ' || x_error_code || ', ' ||
                                'Round Number: ' || x_round_number || ', '||
                                'Return Status: '|| x_return_status || ', '||
                                'Message Count: '|| x_msg_count || ', '||
                                'Message Data: '|| x_msg_data;

		  log_message(x_progress);

                   IF (x_error_code = PO_SUCCESS AND x_pdoi_header.initiate_approval = 'Y') THEN

                       	x_progress := '80: GENERATE_POS: Just before approval wf';
			log_message(x_progress);

                       /* kick off the PO approval worflow process */


                       BEGIN

			  log_error('2.5 LAUNCH_PO_APPROVAL for auction ' || p_auction_header_id || ' and bid  ' || x_bid_number
				    || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

                       	  LAUNCH_PO_APPROVAL(x_po_header_id, x_pdoi_header, p_user_id);

			  log_error('2.6 Completed LAUNCH_PO_APPROVAL for auction ' || p_auction_header_id || ' and bid  '
				    || x_bid_number || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

                       EXCEPTION

                           when others then

				log_error('2.61 EXCEPTION IN LAUNCH_PO_APPROVAL for auction ' || p_auction_header_id
					  || ' with progress so far as ' || x_progress);

				log_error('2.7 EXCEPTION IN LAUNCH_PO_APPROVAL for auction ' || p_auction_header_id
					|| ' and bid  ' || x_bid_number || ' at '
					|| to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

				p_resultout := 'W';
                       END;
                   END IF;

         END LOOP;

         CLOSE awardedBids;

         PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

EXCEPTION

     when others then

	  p_resultout := 'F';

	  log_error(substrb(x_progress || SQLERRM, 1, 4000));

          IF (awardedBids%ISOPEN) THEN
              close awardedBids;
          END IF;

          raise;

END GENERATE_POS;



PROCEDURE LAUNCH_PO_APPROVAL (p_po_header_id    IN 	NUMBER,
                              p_pdoi_header     IN 	PDOIheader,
			      p_user_id		IN 	NUMBER) IS

x_ItemType              varchar2(20) := null;
x_ItemKey               varchar2(60) := null;
x_workflow_process      varchar2(40) := null;
x_action_orig_from      varchar2(30) := null;
x_doc_id                number       := null;

x_responsibility_id     number       := null;
x_application_id        number       := null;
x_preparer_id           number       := null;
x_doc_type              varchar2(25) := null;
x_doc_subtype           varchar2(25) := null;
x_seq_for_item_key      varchar2(6)  := null;
x_doc_type_to_create    varchar2(25);
v_old_policy            varchar2(1);
v_old_org_id            number;
x_progress              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
x_supplier_notif_method po_vendor_sites_all.supplier_notif_method%TYPE := null;
x_print_flag            varchar2(1)   := 'N';
x_fax_flag              varchar2(1)   := 'N';
x_email_flag            varchar2(1)   := 'N';
x_eMail_address         po_vendor_sites_all.email_address%TYPE  :=  null;
x_fax_number            varchar2(100) := null;
x_po_api_return_status  varchar2 (3) := null;
x_msg_count             number := NULL;
x_msg_data              varchar2(2000):= NULL;
x_document_num          po_headers.segment1%type := null;

BEGIN
   x_progress := '10: launch_po_approval: Start of Procedure';

   log_message(x_progress);

    FND_PROFILE.GET('RESP_ID', x_responsibility_id);

    FND_PROFILE.GET('RESP_APPL_ID', x_application_id);

    fnd_global.APPS_INITIALIZE (p_user_id, x_responsibility_id, x_application_id);

   -- Get the current policy
   v_old_policy := mo_global.get_access_mode();
   v_old_org_id := mo_global.get_current_org_id();

   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
     fnd_log.string(
        fnd_log.level_statement,
        g_module || '.check_unique_order_number',
        'old_policy = ' || v_old_policy || ', old_org_id = ' || v_old_org_id);
   end if;

   -- Set the connection's policy context
   mo_global.set_policy_context('S', p_pdoi_header.org_id);

   x_doc_type_to_create := p_pdoi_header.contract_type;


   if (x_doc_type_to_create = 'BLANKET') then
      x_doc_type    := 'PA';
      x_doc_subtype := 'BLANKET';
   elsif (x_doc_type_to_create = 'CONTRACT') then
      x_doc_type    := 'PA';
      x_doc_subtype := 'CONTRACT';
   else
      /* STANDARD */
      x_doc_type    := 'PO';
      x_doc_subtype := 'STANDARD';
   end if;

   /* Need to get item_type and workflow process from po_document_types.
    * They may be different based on the doc/org.
    */
    --Bug 18476347
    --Item Type, Item key and Workflow process need not be passed to Purchasing
    --If itemtype and workflow process are passed as NULL in start_wf_process then PO will take the values from setup -
          --1) Document Style
          --2) Document type.

   /*select wf_approval_itemtype,
          wf_approval_process
     into x_ItemType,
          x_workflow_process
     from po_document_types
    where document_type_code = x_doc_type
      and document_subtype   = x_doc_subtype;*/

   x_progress := '20: launch_po_approval: x_doc_type: ' || x_doc_type || ', ' ||
                                          'x_doc_subtype: ' || x_doc_subtype || ', ' ||
                                          'x_ItemType: ' || x_ItemType || ', ' ||
                                          'x_workflow_process: ' || x_workflow_process;
   log_message(x_progress);

/* Get the unique sequence to make sure item key will be unique */

   SELECT to_char(PO_WF_ITEMKEY_S.NEXTVAL)
   INTO x_seq_for_item_key
   FROM dual;

   SELECT employee_id
   INTO   x_preparer_id
   FROM   fnd_user
   WHERE  user_id = p_user_id;

   x_doc_id:= p_po_header_id;

   x_ItemKey := to_char(x_doc_id) || '-' || x_seq_for_item_key;

  x_progress := '25: Calling Get_Transmission_Defaults PO API:' ||
                      'p_api_version: 1.0 , ' ||
                      'p_int_msg_list: 	FND_API.G_FALSE, '||
                      'p_doc_id: ' || x_doc_id || ', ' ||
                      'p_doc_type: ' || x_doc_type || ', ' ||
                      'p_doc_subtype: ' || x_doc_subtype || ', ' ||
                      'p_preparer_id: ' || x_preparer_id;


      /* Get supplier's default transmission settings */
    PO_VENDOR_SITES_GRP.Get_Transmission_Defaults(
                         p_api_version      => 1.0,
                         p_init_msg_list    => FND_API.G_FALSE,
                         p_document_id      => p_po_header_id,
                         p_document_type    => x_doc_type,
                         p_document_subtype => x_doc_subtype,
                         p_preparer_id      => x_preparer_id,
                         x_default_method   => x_supplier_notif_method,
                         x_email_address    => x_email_address,
                         x_fax_number       => x_fax_number,
                         x_document_num     => x_document_num,
                         x_print_flag       => x_print_flag,
                         x_fax_flag         => x_fax_flag,
                         x_email_flag       => x_email_flag,
                         x_return_status    => x_po_api_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data);

   if (x_po_api_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_progress := '27: Failure in :  PO_VENDOR_SITES_GRP.Get_Transmission_Defaults : ' || 'x_po_api_return_status : '||x_po_api_return_status ||','||
             'x_msg_data : '|| x_msg_data;

	log_message(x_progress);

   else

   x_progress := '30: launch_po_approval: Just before kicking off wf process ' ||
                      'x_ItemType: ' || x_ItemType || ', ' ||
                      'x_ItemKey: '  || x_ItemKey  || ', ' ||
                      'x_workflow_process: ' || x_workflow_process || ', ' ||
                      'x_action_orig_from: ' || x_action_orig_from || ', ' ||
                      'x_doc_id: ' || x_doc_id || ', ' ||
                      'x_doc_num: ' || p_pdoi_header.order_number || ', ' ||
                      'x_preparer_id: ' || x_preparer_id || ', ' ||
                      'x_doc_type: ' || x_doc_type || ', ' ||
                      'x_doc_subtype: ' || x_doc_subtype || ', ' ||
                      'createsourcingrule: '  || p_pdoi_header.create_sourcing_rules || ', ' ||
                      'releasegenmethod: ' || p_pdoi_header.release_method || ', ' ||
                      'updatesourcingrule: ' || p_pdoi_header.update_sourcing_rules;




	log_message(x_progress);

  --Bug 18476347
  --Item Type, Item key and Workflow process need not be passed to Purchasing


   po_reqapproval_init1.start_wf_process(
                             NULL,--x_ItemType,
                             NULL,--x_ItemKey,
                             NULL,--x_workflow_process,
                             x_action_orig_from,
                             x_doc_id,
                             p_pdoi_header.order_number, -- x_doc_num
                             x_preparer_id,
                             x_doc_type,
                             x_doc_subtype,
                             null, -- x_submitter_action,
                             null, -- x_forward_to_id,
                             null, -- x_forward_from_id,
                             null, -- x_def_approval_path_id,
                             null, -- x_note,
                             x_print_flag, -- x_printflag
                             x_fax_flag, -- x_faxflag
                             x_fax_number, -- x_faxnum
                             x_email_flag, -- x_emailflag
                             x_email_address, -- x_emailaddress
                             p_pdoi_header.create_sourcing_rules,
                             p_pdoi_header.release_method,
                             p_pdoi_header.update_sourcing_rules
                             );

   -- Set the org context back
   mo_global.set_policy_context(v_old_policy, v_old_org_id);

end if;


EXCEPTION
  when others then

       log_error(substrb(x_progress || SQLERRM, 1, 4000));

       raise;

END LAUNCH_PO_APPROVAL;

PROCEDURE CHECK_PO_STATUS(itemtype               IN  VARCHAR2,
                          itemkey                IN  VARCHAR2,
                          actid                  IN  NUMBER,
                          uncmode                IN  VARCHAR2,
                          resultout              OUT NOCOPY VARCHAR2) IS


x_number_of_failed_pos NUMBER;
x_auction_header_id NUMBER;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
      IF (UNCMODE = 'CANCEL') THEN
          return;
      END IF;

      x_progress := '10: CHECK_PO_STATUS: Start of po status check';
      log_message(x_progress);

x_number_of_failed_pos := 0;

x_auction_header_id :=  wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'AUCTION_ID');


SELECT   count(pbh.bid_number)
INTO     x_number_of_failed_pos
FROM     pon_bid_headers pbh
WHERE    pbh.auction_header_id = x_auction_header_id and
         nvl(pbh.bid_status, 'NONE') not in ('ARCHIVED', 'DISQUALIFIED') and
         pbh.po_header_id is NULL and
         nvl(pbh.award_status, 'NO') in ('AWARDED', 'PARTIAL');

x_progress := '20: CHECK_PO_STATUS: Number of Failed POs: ' || x_number_of_failed_pos;
        log_message(x_progress);

IF (x_number_of_failed_pos > 0) THEN
     resultout := 'N';
     -- setting auction outcome status to outcome failed
     UPDATE PON_AUCTION_HEADERS_ALL
     SET OUTCOME_STATUS = 'OUTCOME_FAILED'
     WHERE AUCTION_HEADER_ID = x_auction_header_id;
ELSE
     /* update auction outcome status to outcome_completed */
     UPDATE PON_AUCTION_HEADERS_ALL
     SET OUTCOME_STATUS = 'OUTCOME_COMPLETED'
     WHERE AUCTION_HEADER_ID = x_auction_header_id;
     resultout := 'Y';

END IF;

x_progress := '30: CHECK_PO_STATUS: resultout: ' || resultout;
        log_message(x_progress);


EXCEPTION

     when others then
          wf_core.context('PON_AUCTION_CREATE_PO_PKG','checkPOStatus', itemtype, itemkey, x_progress, SQLERRM);
          log_error(itemtype || ' ' || itemkey || ' ' || substrb(x_progress || SQLERRM, 1, 4000));
          raise;

END CHECK_PO_STATUS;


/* document_id will have the form of auction_header_id:round_number:msg_suffix */

PROCEDURE GENERATE_PO_SUCCESS_EMAIL(document_id     IN VARCHAR2,
                                    display_type    IN VARCHAR2,
                                    document        IN OUT NOCOPY VARCHAR2,
                                    document_type   IN OUT NOCOPY VARCHAR2) IS

x_language_code VARCHAR2(4);
x_index NUMBER;
x_substr VARCHAR2(4000);
x_auction_header_id NUMBER;
x_round_number NUMBER;
x_msg_suffix VARCHAR2(3) := '';
x_user_name fnd_user.user_name%TYPE;
x_bid_number pon_bid_headers.bid_number%TYPE;
x_vendor_name po_vendors.vendor_name%TYPE;
x_vendor_site_name po_vendor_sites_all.vendor_site_code%TYPE;
x_agent_name per_all_people_f.full_name%TYPE;
x_order_number pon_bid_headers.order_number%TYPE;
po_status varchar2(4000);
msgBid varchar2(2000);
msgSupplier varchar2(2000);
msgSupplierSite varchar2(2000);
msgBuyer varchar2(2000);
msgPO varchar2(2000);
msgPOdetails varchar2(2000);
msgNumCreated varchar2(2000);
newline varchar2(256);
beginBold VARCHAR2(10);
endBold   VARCHAR2(10);
x_count NUMBER;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
itemkey pon_auction_headers_all.wf_poncompl_item_key%TYPE;
x_purchase_orders VARCHAR2(30);
x_contract_type pon_auction_headers_all.contract_type%TYPE;

/* Selects all relevant information for the first 10 successful POs of the current round*/

CURSOR successfulPOs is

        SELECT *
        FROM (
	SELECT  pbh.bid_number,
		pov.vendor_name,
		pbh.vendor_site_code,
		papf.full_name,
		pbh.order_number
	FROM    pon_bid_headers pbh,
		po_vendors pov,
		per_all_people_f papf
	WHERE   pbh.auction_header_id	= x_auction_header_id
	AND	pbh.bid_status		= 'ACTIVE'
	AND	pbh.po_header_id is NOT NULL
	AND	pbh.po_wf_creation_rnd 	= x_round_number
	AND	pbh.vendor_id 		= pov.vendor_id
	AND	pbh.agent_id 		= papf.person_id
	AND	papf.effective_start_date < sysdate
	AND	papf.effective_end_date = (select max(papf2.effective_end_date)
					   from per_all_people_f papf2
					   where papf2.person_id = pbh.agent_id
					   and papf2.effective_start_date < sysdate)
        GROUP BY
		pbh.bid_number,
		pov.vendor_name,
		pbh.vendor_site_code,
		papf.full_name,
		pbh.order_number
             )
        WHERE rownum <= 10;

BEGIN

             x_progress := '10: GENERATE_PO_SUCCESS_EMAIL unique_key: ' || document_id;
             log_message('PONCOMPL' || ' ' || x_progress);
             x_index := instr(document_id, ':');
             x_auction_header_id := substr(document_id, 1, x_index-1);
             x_substr := substr(document_id, x_index+1);
             x_index := instr(x_substr, ':');
             x_round_number := substr(x_substr, 1, x_index-1);
             x_substr := substr(x_substr, x_index+1);
             x_index := instr(x_substr, ':');
             x_msg_suffix := substr(x_substr, 1, x_index-1);
             x_user_name := substr(x_substr, x_index+1);

             SELECT wf_poncompl_item_key, contract_type
             INTO itemkey, x_contract_type
             FROM  pon_auction_headers_all
             WHERE auction_header_id = x_auction_header_id;

             PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_user_name, x_language_code);
             PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, x_language_code);
         IF (x_contract_type = 'STANDARD') THEN
                 x_purchase_orders := 'Standard Purchase Order';
                 msgNumCreated := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NUM_OF_SUCC_PO');
                 msgPOdetails := PON_AUCTION_PKG.getMessage('PON_AUC_WF_PO_DETAILS');
	     ELSIF (x_contract_type = 'BLANKET') THEN
	         x_purchase_orders := 'Blanket Purchase Agreement';
                 msgNumCreated := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NUM_OF_SUCC_BL');
                 msgPOdetails := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BL_DETAILS');
	     ELSIF (x_contract_type = 'CONTRACT') THEN
	         x_purchase_orders := 'Contract Purchase Agreement';
                 msgNumCreated := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NUM_OF_SUCC_CPA');
                 msgPOdetails := PON_AUCTION_PKG.getMessage('PON_AUC_WF_CPA_DETAILS');
	     END IF;
             msgBid := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BID', x_msg_suffix);
             msgSupplier := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SUPPLIER');
             msgSupplierSite := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SUPPLIER_SITE');
             msgBuyer := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BUYER');
             msgPO := PON_AUCTION_PKG.getMessage('PON_AUC_WF_PO', 'null', 'PURCHASE_ORDERS', x_purchase_orders);
             IF (display_type = 'text/plain') THEN
                 document_type := 'text/plain';
                 newline := fnd_global.newline;
                 beginBold := '';
                 endBold := '';
             ELSE
                 document_type := 'text/html';
                 newline := '<BR>';
                 beginBold := '<b>';
                 endBold := '</b>';
             END IF;

             x_progress := '20: GENERATE_PO_SUCCESS_EMAIL auction id: ' || x_auction_header_id || ', ' || 'round number: ' || x_round_number || ', ' || 'message suffix: ' || x_msg_suffix || ', ' || 'user name: ' || x_user_name;
             log_message('PONCOMPL' || ' ' || itemkey || x_progress);
--          end if;
             OPEN successfulPOs;
             LOOP
                  FETCH successfulPOs into x_bid_number, x_vendor_name,
                                           x_vendor_site_name, x_agent_name,
                                           x_order_number;
                  EXIT WHEN successfulPOs%NOTFOUND;
                  po_status :=  msgPOdetails || newline ||
                                msgBid || ' ' || beginBold || x_bid_number || endBold || newline  ||
                                msgSupplier  || ' ' || beginBold || x_vendor_name || endBold || newline ||
                                msgSupplierSite || ' ' || beginBold || x_vendor_site_name || endBold || newline ||
                                msgPO || ' ' || beginBold || x_order_number || endBold || newline ||
                                msgBuyer || ' ' || beginBold || x_agent_name || endBold || newline;

                  x_progress := '30: GENERATE_PO_SUCCESS_EMAIL message: ' || po_status;
                  log_message('PONCOMPL' || ' ' || itemkey || ' '  ||x_progress);
                  document := document || po_status || newline;
             END LOOP;
             x_count := successfulPOs%ROWCOUNT;
             CLOSE successfulPOs;
             document := msgNumCreated || ' ' || beginBold || x_count || endBold || newline || newline|| document;
             x_progress := '40: GENERAGE_PO_SUCCESS_EMAIL final e-mail message: ' || document;
             log_message('PONCOMPL' || ' ' || itemkey || ' ' ||x_progress);

         PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;
EXCEPTION

     when others then
          wf_core.context('PON_AUCTION_CREATE_PO_PKG','generatePOSuccessEmail', x_progress, SQLERRM);
          log_error('PONCOMPL' || ' ' || itemkey || ' ' || substrb(x_progress||SQLERRM, 1, 4000));

          IF (successfulPOs%ISOPEN) THEN
              close successfulPOs;
          END IF;

          raise;

END GENERATE_PO_SUCCESS_EMAIL;


/* document_id will have the form of auction_header_id:msg_suffix */

PROCEDURE GENERATE_PO_FAILURE_EMAIL(document_id     IN VARCHAR2,
                                    display_type    IN VARCHAR2,
                                    document        IN OUT NOCOPY VARCHAR2,
                                    document_type   IN OUT NOCOPY VARCHAR2) IS


x_language_code VARCHAR2(4);
x_index NUMBER;
x_substr VARCHAR2(4000);
x_auction_header_id NUMBER;
x_msg_suffix VARCHAR2(3) := '';
x_user_name fnd_user.user_name%TYPE;
x_bid_number NUMBER;
x_vendor_name po_vendors.vendor_name%TYPE;
x_vendor_site_name po_vendor_sites_all.vendor_site_code%TYPE;
x_agent_name per_all_people_f.full_name%TYPE;
x_order_number pon_bid_headers.order_number%TYPE;
x_error_code pon_bid_headers.po_error_code%TYPE;
po_status varchar2(4000);
msgBid varchar2(2000);
msgSupplier varchar2(2000);
msgSupplierSite varchar2(2000);
msgBuyer varchar2(2000);
msgError varchar2(2000);
msgNumNotCreated varchar2(2000);
msgErrorCode varchar2(2000);
msgPurchaseOrder varchar2(2000);
msgDuplicatePONumber varchar2(2000);
msgSystemError varchar2(2000);
msgPO varchar2(2000);
newline varchar2(256);
beginBold VARCHAR2(10);
endBold   VARCHAR2(10);
x_count NUMBER;
x_progress FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
itemkey pon_auction_headers_all.wf_poncompl_item_key%TYPE;
x_purchase_orders VARCHAR2(30);
x_contract_type pon_auction_headers_all.contract_type%TYPE;
x_error_msg pon_bid_headers.po_error_msg%type;

CURSOR failedPOs is
	SELECT  pbh.bid_number,
		pov.vendor_name,
		povsa.vendor_site_code,
		papf.full_name,
		pbh.order_number,
		pbh.po_error_code,
		pbh.po_error_msg
	FROM    pon_bid_headers pbh,
		po_vendors pov,
		po_vendor_sites_all povsa,
		per_all_people_f papf
	WHERE   pbh.auction_header_id	= x_auction_header_id
	AND	pbh.bid_status		= 'ACTIVE'
	AND	nvl(pbh.award_status, 'NO') in ('AWARDED', 'PARTIAL')
	AND	pbh.po_header_id is NULL
	AND	pbh.vendor_id 		= pov.vendor_id
	AND	pbh.vendor_id 		= povsa.vendor_id
	AND	pbh.agent_id 		= papf.person_id
	AND	papf.effective_start_date < sysdate
	AND	papf.effective_end_date = (select max(papf2.effective_end_date)
					   from per_all_people_f papf2
					   where papf2.person_id = pbh.agent_id)
        GROUP BY
		pbh.bid_number,
		pov.vendor_name,
		povsa.vendor_site_code,
		papf.full_name,
		pbh.order_number,
		pbh.po_error_code,
		pbh.po_error_msg;

BEGIN
             x_progress := '10: GENERATE_PO_FAILURE_EMAIL unique key: ' || document_id;
             log_message('PONCOMPL' || ' ' || x_progress);
             x_index := instr(document_id, ':');
             x_auction_header_id := substr(document_id, 1, x_index-1);
             x_substr := substr(document_id, x_index+1);
             x_index := instr(x_substr, ':');
             x_msg_suffix := substr(x_substr, 1, x_index-1);
             x_user_name := substr(x_substr, x_index+1);


             SELECT wf_poncompl_item_key, contract_type
             INTO itemkey, x_contract_type
             FROM  pon_auction_headers_all
             WHERE auction_header_id = x_auction_header_id;

             x_progress := '20: GENERATE_PO_FAILURE_EMAIL auction id: ' || x_auction_header_id  || ', ' || 'message suffix: ' || x_msg_suffix || ', ' || 'user name: ' || x_user_name;

             log_message('PONCOMPL' || ' ' || itemkey || ' ' || x_progress);
             PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE(x_user_name, x_language_code);
             PON_AUCTION_PKG.SET_SESSION_LANGUAGE(null, x_language_code);


             IF (x_contract_type = 'STANDARD') THEN
                 x_purchase_orders := 'Standard Purchase Order';
                 msgNumNotCreated := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NUM_OF_FAIL_PO');
	     ELSIF (x_contract_type = 'BLANKET') THEN
	         x_purchase_orders := 'Blanket Purchase Agreement';
                 msgNumNotCreated := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NUM_OF_FAIL_BL');
	     ELSIF (x_contract_type = 'CONTRACT') THEN
	         x_purchase_orders := 'Contract Purchase Agreement';
                 msgNumNotCreated := PON_AUCTION_PKG.getMessage('PON_AUC_WF_NUM_OF_FAIL_CPA');
	     END IF;

             msgBid := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BID', x_msg_suffix);
             msgSupplier := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SUPPLIER');
             msgSupplierSite := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SUPPLIER_SITE');
             msgBuyer := PON_AUCTION_PKG.getMessage('PON_AUC_WF_BUYER');
             msgPurchaseOrder := PON_AUCTION_PKG.getMessage('PON_AUCTS_PAY_PO');
             msgDuplicatePONumber := PON_AUCTION_PKG.getMessage('PON_AUC_WF_DUP_PO_NUM');
             msgSystemError := PON_AUCTION_PKG.getMessage('PON_AUC_WF_SYS_ERROR');
             msgPO := PON_AUCTION_PKG.getMessage('PON_AUC_WF_PO', 'null', 'PURCHASE_ORDERS', x_purchase_orders);

             IF (display_type = 'text/plain') THEN
                 document_type := 'text/plain';
                 newline := fnd_global.newline;
                 beginBold := '';
                 endBold := '';
             ELSE
                 document_type := 'text/html';
                 newline := '<BR>';
                 beginBold := '<b>';
                 endBold := '</b>';
             END IF;

             OPEN failedPOs;
             LOOP
                  FETCH failedPOs into x_bid_number, x_vendor_name,
                                       x_vendor_site_name, x_agent_name,
                                       x_order_number, x_error_code ,x_error_msg;
                  EXIT WHEN failedPOs%NOTFOUND;

                  IF (x_error_code = DUPLICATE_PO_NUMBER) THEN
                     msgErrorCode := msgPurchaseOrder || ' ' || x_order_number || ': ' || msgDuplicatePONumber;

                  ELSIF (x_error_code = PO_SYSTEM_ERROR OR x_error_code = SOURCING_SYSTEM_ERROR) THEN
                     msgErrorCode := msgSystemError;
                  ELSIF (x_error_code = PO_PDOI_ERROR ) THEN
                     msgErrorCode := msgSystemError||' :'||substrb(x_error_msg,1,1000);

                  END IF;

                   po_status := msgBid || ' ' || beginBold || x_bid_number || endBold || newline  ||
                                msgSupplier || ' ' || beginBold || x_vendor_name || endBold || newline ||
                                msgSupplierSite || ' ' || beginBold || x_vendor_site_name || endBold || newline ||
                                msgPO || ' ' || beginBold || 'Not Created' ||  endBold || newline ||
                                msgBuyer || ' ' || beginBold || x_agent_name || endBold || newline ||
                                msgError || ' ' || beginBold || msgErrorCode || endBold || newline;


           x_progress := '30: GENERATE_PO_FAILURE_EMAIL message: ' || po_status;
              log_message('PONCOMPL' || ' ' || itemkey || ' ' || x_progress);
                  document := document || po_status || newline;
             END LOOP;
             x_count := failedPOs%ROWCOUNT;
             CLOSE failedPOs;

             document := msgNumNotCreated || ' ' || beginBold || x_count || endBold || newline || newline|| document;
             x_progress := '40: GENERATE_PO_FAILURE_EMAIL final e-mail message: ' || document;

        log_message('PONCOMPL' || ' ' || itemkey || ' ' || x_progress);
     PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

EXCEPTION

     when others then
          wf_core.context('PON_AUCTION_CREATE_PO_PKG','generatePOFailureEmail', x_progress, SQLERRM);
          log_error('PONCOMPL' || ' ' || itemkey || ' ' || substrb(x_progress || SQLERRM, 1, 4000));

          IF (failedPOs%ISOPEN) THEN
              close failedPOs;
          END IF;

          raise;

END GENERATE_PO_FAILURE_EMAIL;



procedure CHECK_PO_EMAIL_TYPE (itemtype               IN VARCHAR2,
                                    itemkey                IN VARCHAR2,
                                    actid                  IN NUMBER,
                                    uncmode                IN VARCHAR2,
                                    resultout              OUT NOCOPY VARCHAR2)
IS

BEGIN

	-- PON_AUC_PO_ALLOC_REQS_FAIL
	-- PON_AUC_PO_ALLOC_SPLIT_FAIL
	-- PON_AUC_PO_CREATE_PO_FAIL
	-- PON_AUC_PO_CREATE_PO_SUCCESS

	-- should get it from a workflow item-attribute

	resultout := wf_engine.GetItemAttrText (itemtype => itemtype,
	    					itemkey  => itemkey,
	    					aname    => 'AUCTION_PO_EMAIL_TYPE');


END CHECK_PO_EMAIL_TYPE;



PROCEDURE START_PO_CREATION(EFFBUF           OUT NOCOPY VARCHAR2,
          		    RETCODE          OUT NOCOPY VARCHAR2,
			    p_auction_header_id           IN    NUMBER,       -- 1
                            p_user_name                   IN    VARCHAR2,     -- 2
                            p_user_id                     IN    NUMBER,       -- 3
                            p_formatted_name              IN    VARCHAR2,     -- 4
                            p_auction_title               IN    VARCHAR2,     -- 5
                            p_organization_name           IN    VARCHAR2,     -- 6
			    p_resultout			  OUT NOCOPY VARCHAR2) IS  -- 7


x_itemkey                      wf_items.ITEM_KEY%TYPE;
x_sequence                     NUMBER;
x_current_round                NUMBER;
x_requistion_based             	VARCHAR2(12);
x_has_items                    	PON_AUCTION_HEADERS_ALL.HAS_ITEMS_FLAG%TYPE;
x_number_of_failed_pos 		NUMBER;
x_email_type			VARCHAR2(240);
x_allocation_error		VARCHAR2(2000);
x_line_number		  	NUMBER;
x_item_number		  	pon_auction_item_prices_all.ITEM_NUMBER%TYPE;
x_item_description		pon_auction_item_prices_all.ITEM_DESCRIPTION%TYPE;
x_item_revision		  	pon_auction_item_prices_all.ITEM_REVISION%TYPE;
x_requisition_number	  	PON_AUCTION_ITEM_PRICES_ALL.REQUISITION_NUMBER%TYPE;
x_job_name			PER_JOBS.NAME%TYPE;
x_document_disp_line_number	PON_AUCTION_ITEM_PRICES_ALL.DOCUMENT_DISP_LINE_NUMBER%TYPE;
l_resultout			VARCHAR2(10);

x_open_bidding_date            date;
x_close_bidding_date           date;
x_trading_partner_contact_id   number;
x_doctype_id                   PON_AUCTION_HEADERS_ALL.DOCTYPE_ID%TYPE;
x_trading_partner_name         PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
x_trading_partner_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;

l_workflow_failure		VARCHAR2(1);

l_api_name			VARCHAR2(30)	:= ' START_PO_CREATION ';
l_debug_enabled			VARCHAR2(1)	:= 'N';
l_exception_enabled		VARCHAR2(1)	:= 'N';
l_progress			NUMBER		:= 0;

x_progress 			FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

-- Business Events Project
x_return_status  		VARCHAR2(20);
x_msg_count      		NUMBER;
x_msg_data       		VARCHAR2(2000);


BEGIN

    /* perform initialization for FND logging */
    if(g_fnd_debug = 'Y') then

	if (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) then
		l_debug_enabled := 'Y';
	end if;

	IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) then
		l_exception_enabled := 'Y';
	end if;

    end if;

    if(l_debug_enabled = 'Y') then

	x_progress := ++l_progress || l_api_name || ' : BEGIN :';

	log_message(x_progress);

	x_progress := ++l_progress || l_api_name || ' : IN PARAMETERS : ' || p_auction_header_id
				   || '  ' || p_user_name || '  ' || p_user_id || '  '
				|| p_formatted_name || ' ' || p_auction_title || ' '
				|| p_organization_name;
	log_message(x_progress);

     end if;


     log_message(++l_progress || l_api_name || '1. Start PO Creation for ' || p_auction_header_id || ' initiated by '
			    || p_user_name || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));

     select 	open_bidding_date,
		close_bidding_date,
		trading_partner_contact_id,
		doctype_id,
            	trading_partner_name,
		trading_partner_contact_name,
		has_items_flag,
		nvl(wf_poncompl_current_round, 0)
     into 	x_open_bidding_date,
		x_close_bidding_date,
		x_trading_partner_contact_id,
		x_doctype_id,
          	x_trading_partner_name,
		x_trading_partner_contact_name,
		x_has_items,
		x_current_round
     from 	pon_auction_headers_all
     where 	auction_header_id = p_auction_header_id;


    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : retrieved header information :';
	log_message(x_progress);
    end if;

      --check if the negotiation has requistion based line
      BEGIN
        SELECT 'REQUISITION'
	INTO x_requistion_based
	FROM DUAL
	WHERE EXISTS(
         SELECT '1'
	 FROM pon_auction_item_prices_all
	 WHERE auction_header_id = p_auction_header_id
	      AND  line_origination_code = 'REQUISITION'
	 );

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : checking whether req-based auction :' || x_requistion_based;
	log_message(x_progress);
    end if;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

          x_requistion_based := 'NONE';

    	  if(l_exception_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : exception while checking whether req-based auction :'
					   || substrb(SQLERRM, 1, 500);
		log_error(x_progress);
    	end if;


      END;

    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : getting in to the main try-catch block  :';
	log_message(x_progress);
    end if;

   BEGIN -- main try-catch block --{

    -- since we havent set wf_poncompl_current_round in pon_auction_headers_all
    -- as yet, x_current_round will be zero if there was no failure reported earlier

    UPDATE pon_auction_headers_all set
           outcome_status = decode(x_current_round, 0, 'OUTCOME_INITIATED', 'OUTCOME_REINITIATED'),
           last_update_date = sysdate
    WHERE auction_header_id = p_auction_header_id;


    if(l_debug_enabled = 'Y') then
	x_progress := ++l_progress || l_api_name || ' : updated the outcome_status with round number :' || x_current_round;
	log_message(x_progress);
    end if;


    -- initialize to success
    l_resultout := 'SUCCESS';

	/* Check whether the auction has any lines  */

	IF(NVL(X_HAS_ITEMS, 'N') = 'Y') THEN

    	if(l_debug_enabled = 'Y') then
		x_progress := ++l_progress || l_api_name || ' : from start_po_creation to x_has_items true '
				||  ' to auto_alloc_and_split_req :' || x_current_round;
		log_message(x_progress);
    	end if;

		/* proceed with allocation if atleast one line has backing reqs */

		IF(NVL(x_requistion_based , 'NONE') = 'REQUISITION') THEN

    		if(l_debug_enabled = 'Y') then
			x_progress := ++l_progress || l_api_name || ' : we have lines with backing reqs,'
					|| ' hence invoke AUTO_ALLOC_AND_SPLIT_REQ.';
			log_message(x_progress);
    		end if;


			log_message('21. from start_po_creation to x_requistion_based is true to auto_alloc_and_split_req');

			AUTO_ALLOC_AND_SPLIT_REQ(
			    p_auction_header_id,       -- 1
                            p_user_name                   ,
                            p_user_id                     ,
                            p_formatted_name              ,
                            p_auction_title               ,
                            p_organization_name           ,
			    l_resultout			  ,
			    x_allocation_error		  ,
			    x_line_number		  ,
			    x_item_number		,
			    x_item_description		,
			    x_item_revision		,
			    x_requisition_number	,
			    x_job_name			,
			    x_document_disp_line_number);

			IF(l_resultout = 'FAILURE') THEN


    			  if(l_exception_enabled = 'Y') then
				x_progress := ++l_progress || l_api_name || ' : auto_alloc_and_split_req returned '
						|| ' failure for auction  ' || p_auction_header_id;
				log_error(x_progress);
    			  end if;

				x_email_type := 'PON_AUC_PO_ALLOC_SPLIT_FAIL';
			END IF;

		END IF;

	END IF;

    	if(l_debug_enabled = 'Y') then
	  x_progress := ++l_progress || l_api_name || ' : so far so good after req. based handling';
	  log_message(x_progress);
    	end if;

	IF(l_resultout = 'SUCCESS') THEN --{

    		if(l_debug_enabled = 'Y') then
	  	  x_progress := ++l_progress || l_api_name || ' : so far so good ready to invoke generate_pos';
	  	  log_message(x_progress);

		  log_message(++l_progress || l_api_name || '2. Invoke GENERATE-POS for  ' || p_auction_header_id
					 || ' initiated by ' || p_user_name || ' at '
					 || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));
		end if;

		GENERATE_POS(p_auction_header_id,
                             p_user_name,
                             p_user_id,
			     l_resultout);


		if(l_resultout = 'W') then
			-- just keep track that po approval workflow caused an error
			-- proceed with normal operations
			l_workflow_failure := 'Y';
		end if;

    		if(l_debug_enabled = 'Y') then
	  	  x_progress := ++l_progress || l_api_name || ' : control returned from  generate_pos' || l_resultout;
	  	  log_message(x_progress);
    		end if;

		x_number_of_failed_pos := 0;

		SELECT   count(pbh.bid_number)
		INTO     x_number_of_failed_pos
		FROM     pon_bid_headers pbh
		WHERE    pbh.auction_header_id = p_auction_header_id 	and
        		 nvl(pbh.bid_status, 'NONE') = 'ACTIVE' 	and
		         pbh.po_header_id is NULL 			and
        		 nvl(pbh.award_status, 'NO') in ('AWARDED', 'PARTIAL');

		IF (x_number_of_failed_pos > 0) THEN

		     	l_resultout := 'FAILURE';

			if(l_exception_enabled = 'Y') then
		  	  log_error(++l_progress || l_api_name || '2. GENERATE-POS failed as x_number_of_failed_pos is '
				    		 || ' more than zero  '
						 || p_auction_header_id || ' initiated by ' || p_user_name || ' at '
						 || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));
			end if;

		     	UPDATE PON_AUCTION_HEADERS_ALL
		     	SET OUTCOME_STATUS = 'OUTCOME_FAILED'
	     		WHERE AUCTION_HEADER_ID = p_auction_header_id;

		     	IF(x_requistion_based = 'REQUISITION') THEN
				x_email_type := 'PON_AUC_PO_ALLOC_REQS_FAIL';
		     	ELSE
				x_email_type := 'PON_AUC_PO_CREATE_PO_FAIL';
	     		END IF;

		ELSE


    		if(l_debug_enabled = 'Y') then
	  	  x_progress := ++l_progress || l_api_name || ' : generate_pos is successful';
	  	  log_message(x_progress);
    		end if;


		     log_message('70. generate_pos successful');
		     /* update auction outcome status to outcome_completed */
		     UPDATE PON_AUCTION_HEADERS_ALL
		     SET OUTCOME_STATUS = 'OUTCOME_COMPLETED'
		     WHERE AUCTION_HEADER_ID = p_auction_header_id;

		     l_resultout := 'SUCCESS';

		     x_email_type := 'PON_AUC_PO_CREATE_PO_SUCCESS';

		END IF;

	END IF; --}

      EXCEPTION  --}

		WHEN OTHERS THEN

			if(l_exception_enabled = 'Y') then
		  	  log_error(++l_progress || l_api_name || ' FATAL EXCEPTION in main try-catch block for generate pos '
						 || substrb(SQLERRM, 1, 2500));
			end if;

			rollback;

			l_resultout := 'FAILURE';

			UPDATE PON_AUCTION_HEADERS_ALL
		     	SET OUTCOME_STATUS = 'OUTCOME_FAILED'
	     		WHERE AUCTION_HEADER_ID = p_auction_header_id;

			x_email_type := 'PON_AUC_PO_CREATE_PO_FAIL';

      END;

      if(l_debug_enabled = 'Y') then
	 x_progress := ++l_progress || l_api_name || ' : invoke start_po_workflow for email ' || x_email_type;
	 log_message(x_progress);

	log_message(++l_progress 	|| l_api_name || '3. Invoke START_PO_WORKFLOW for  ' || p_auction_header_id
			       	|| ' initiated by ' || p_user_name || ' for email ' || x_email_type || ' at '
				|| to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss'));
      END IF;

      /* if we have reached here, check the status so far and set the out parameter accordingly */

      IF (l_resultout = 'SUCCESS') THEN
	p_resultout := 'S';
      ELSE
	p_resultout := 'F';
      END IF;

      /* before we invoke the workflow, lets commit everything -
	 if there was an exception, we have updated the status as well
	*/

      COMMIT;

      BEGIN

    	-- Get next value in sequence for itemkey

    	SELECT pon_auction_wf_createpo_s.nextval
    	INTO   x_sequence
    	FROM   dual;

    	x_itemkey := (to_char(p_auction_header_id)||'-'||to_char(x_sequence));

	-- update pon_auction_headers_all.wf_poncompl_current_round by incrementing by one
	-- update pon_bid_headers.po_wf_creation_rnd by incrementing by one

    	UPDATE 	pon_auction_headers_all set
           	wf_poncompl_item_key 	  = x_itemkey,
           	wf_poncompl_current_round = x_current_round+1,
           	last_update_date 	  = sysdate
    	WHERE  	auction_header_id = p_auction_header_id;

    	UPDATE 	pon_bid_headers set
           	po_wf_creation_rnd 	= x_current_round+1
    	WHERE  	auction_header_id 	= p_auction_header_id;

	log_message(++l_progress || l_api_name || '. invoke start_po_workflow for itemkey=' || x_itemkey);

	START_PO_WORKFLOW(p_auction_header_id		,
        	          p_user_name			,
                	  p_user_id			,
                       	  p_formatted_name		,
                          p_auction_title		,
                          p_organization_name		,
			  x_email_type			,
			  x_itemkey			,
			  x_allocation_error		,
			  x_line_number		  	,
			  x_item_number			,
			  x_item_description		,
			  x_item_revision		,
			  x_requisition_number		,
			  x_job_name			,
			  x_document_disp_line_number	);


	 log_message(++l_progress || l_api_name || '3. AFTER START_PO_WORKFLOW for  ' || p_auction_header_id
					 || ' initiated by ' || p_user_name || ' for email ' || x_email_type || ' at '
					 || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss') || ' with p_resultout = '
					 || p_resultout);


      EXCEPTION
		WHEN OTHERS THEN

      			if(l_exception_enabled = 'Y') then
		  	   log_error(++l_progress || l_api_name || '3. EXCEPTION DURING START_PO_WORKFLOW for  '
						  || p_auction_header_id || ' initiated by ' || p_user_name || ' for email '
						  || x_email_type || ' at ' || to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss')
						  || ' with p_resultout = ' || p_resultout || ' exception = '
						  || substrb(SQLERRM, 1 , 500));
			end if;

			/* our plan is to simply ignore this exception during create PO - we should not
			affect creation of a PO if we are not able to send an email - simply report it as a
			warning
                        */
			l_workflow_failure := 'Y';

	END;

    -- Raise Business Event
    PON_BIZ_EVENTS_PVT.RAISE_PO_CREATION_INIT_EVENT (
        p_api_version            => 1.0 ,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_auction_header_id      => p_auction_header_id,
        p_user_name              => p_user_name,
        p_requisition_based_flag => x_requistion_based,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data);

	-- finally, check whether our workflows behaved badly
	-- we will display a warning on the PO summary page
	-- perform this check only if all proceedings were successful
	if(l_workflow_failure = 'Y') then
		if(p_resultout = 'S') then
			p_resultout := 'W';
		end if;
	end if;

	log_message(++l_progress 	|| l_api_name || '4.Finished PO Creation for   ' || p_auction_header_id
					|| ' initiated by ' || p_user_name || ' for email ' || x_email_type || ' at '
					|| to_char(sysdate, 'Dy DD-Mon-YYYY hh24:mi:ss')
					|| ' with final p_resultout=' || p_resultout);

END START_PO_CREATION;

FUNCTION get_vendor_contact_id(
      p_trading_partner_contact_id IN NUMBER,
      p_vendor_site_id             IN NUMBER,
      p_vendor_id                  IN NUMBER)
    RETURN NUMBER
  IS
    l_vendor_contact_id NUMBER := NULL;
  BEGIN
    SELECT
        vendor_contact_id into l_vendor_contact_id
    FROM po_vendor_contacts
    WHERE per_party_id = p_trading_partner_contact_id
    AND vendor_site_id      = p_vendor_site_id
    AND vendor_id           = p_vendor_id
    AND INACTIVE_DATE > sysdate;
    log_message('PON_AUCTION_CREATE_PO_PKG.get_vendor_contact_id--> l_vendor_contact_id: ' || l_vendor_contact_id);
    RETURN l_vendor_contact_id;

  EXCEPTION
		WHEN OTHERS THEN
			log_error('PON_AUCTION_CREATE_PO_PKG.get_vendor_contact_id' || substrb(SQLERRM, 1, 4000));
      RETURN NULL;

END get_vendor_contact_id;


END PON_AUCTION_CREATE_PO_PKG;

/
