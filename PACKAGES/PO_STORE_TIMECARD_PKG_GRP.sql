--------------------------------------------------------
--  DDL for Package PO_STORE_TIMECARD_PKG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_STORE_TIMECARD_PKG_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGSTCS.pls 115.2 2004/04/23 19:35:05 jmojnida noship $ */


  /*

  */
  g_cur_po_header_id number := null;

/*

*/
   g_cur_po_line_id   number := null;

/*
  This procedure initializes the global variables to null.
*/
procedure initGlobals;

function isFirstOccurance(p_po_header_id number, p_po_line_id number)
return number;

-- Start of comments
--	API name 	: store_time_card_details
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: inserts, deletes or updates the given timecard details information.
--                        Note:  This API will not commit. It is the responsibility
--                               of the calling program to commit or rollback.  The
--                               rollback should include the modifications done to
--                               related tables like RCV_TRANSACTIONS_HDR also.
--	Parameters	: IN
--      p_action        : this parameter specifies the action to be carried out.
--                        INSERT   for inserting a new timecard details
--                        UPDATE   for updating --time, rate type, rate-- for existing rec
--                        DELETE   for deleting an existing record.
--                        OUT
--      x_return_status : This parameter will have one of
--                        FND_API.G_RET_STS_UNEXP_ERROR,
--                        FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_SUCCESS.
--                        The calling code should not commit if there is an error;
--                        Commit otherwise.
--	Version	        : Initial version 	1.0
--
-- End of comments

procedure store_timecard_details
	(
	p_api_version	number,
	x_return_status	out NOCOPY varchar2,
	x_msg_data      out NOCOPY varchar2,
	p_vendor_id	number,
	p_vendor_site_id	number,
	p_vendor_contact_id	number,
	p_po_num	varchar2,
	p_po_line_number	number,
	p_org_id	number,
	p_project_id	number,
	p_task_id	number,
	p_tc_id	number, --building_block_id for timecards
	p_tc_day_id	number,  --building_block_id for timecard days
	p_tc_detail_id	number,  -- building_block_id for details
	p_tc_uom	varchar2,  --mostly Hours
	p_tc_Start_date	date,   --Timecard start date
	p_tc_end_date	date,  --Timecard end date
	p_tc_entry_date	date, --date the worker worked
	p_tc_time_received	number, --number of hours worked
	p_tc_approval_status varchar2,
	p_tc_approval_date  date,
	p_tc_submission_date date,
	p_contingent_worker_id	number, --worker id
	p_tc_comment_text	varchar2, --tc comment
	p_line_rate_type	varchar2,  -- Regular, Overtime
	p_line_rate	number,
	p_action	VARCHAR2,
	p_interface_transaction_id number

	);


-- Start of comments
--	API name 	: reconcile_actions
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: inserts, deletes or updates the given timecard details information.
--                        Note:  This API will not commit. It is the responsibility
--                               of the calling program to commit or rollback.  The
--                               rollback should include the modifications done to
--                               related tables like RCV_TRANSACTIONS_HDR also.
--	Parameters	:  OUT
--      x_return_status : This parameter will have one of
--                        FND_API.G_RET_STS_UNEXP_ERROR,
--                        FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_SUCCESS.
--                        The calling code should not commit if there is an error;
--                        Commit otherwise.
--	Version	        : Initial version 	1.0
--
-- End of comments



 procedure reconcile_actions (p_api_version number,
                              x_return_status  out NOCOPY varchar2,
                              x_msg_data       out NOCOPY varchar2
                              );



--For details see the comments above.

 procedure store_timecard_details_rec (p_api_version number,
                                   x_return_status	out NOCOPY varchar2,
	                           x_msg_data      out NOCOPY varchar2,
	                           p_rtrvd_tc  PO_RTRVD_TC_REC,
                                   p_action	VARCHAR2
                                  );




--If there are errors, the procedure tries to loop through all the elements
-- and collect all the errors before returning.  The errors are in x_errs.
/*  Does not work with 8i.
procedure store_timecard_details_bulk (p_api_version number,
                                       x_return_status	out NOCOPY varchar2,
                                       --if x_msg_data is empty (''), then look at x_errs.
	                                   x_msg_data      out NOCOPY varchar2,
	                                   p_rtrvd_tcs PO_RTRVD_TCS_REC,
	                                   p_action VARCHAR2,
	                                   x_errs out NOCOPY PO_RTRVD_TCS_ERR_REC);
*/
end PO_STORE_TIMECARD_PKG_GRP;

 

/
