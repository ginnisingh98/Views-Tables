--------------------------------------------------------
--  DDL for Package Body PO_STORE_TIMECARD_PKG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_STORE_TIMECARD_PKG_GRP" AS
/* $Header: POXGSTCB.pls 120.2 2007/12/26 11:39:36 adbharga ship $ */

--  *** PRIVATE PROCEDURES  **

/*  8i compatibility issue.  Commenting out
function  add_error (
        p_rtrvd_tcs PO_RTRVD_TCS_REC
    ) return PO_RTRVD_TCS_ERR_REC
    IS
      tc_id           po_tbl_number;
      tc_day_id       po_tbl_number;
      tc_detail_id    po_tbl_number;
      po_number       po_tbl_varchar20;
      line_number     po_tbl_number;
      original_index   po_tbl_number;
      msg_data        po_tbl_varchar2000;
      msg_cnt number;
      errors  NUMBER;
      err_index  number;
    begin

    errors := SQL%BULK_EXCEPTIONS.COUNT;

       --dbms_output.put_line('Number of errors is ' || errors);
       FOR i IN 1..errors LOOP
               err_index := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
               tc_id.extend;
	       tc_day_id.extend;
	       tc_detail_id.extend;
	       po_number.extend;
	       line_number.extend;
	       original_index.extend;
	       msg_data.extend;

	       msg_cnt := msg_data.count;

	       tc_id(msg_cnt) := p_rtrvd_tcs.tc_id(err_index);
	       tc_day_id(msg_cnt) := p_rtrvd_tcs.tc_day_id(err_index);
	       tc_detail_id(msg_cnt) := p_rtrvd_tcs.tc_detail_id(err_index);
	       po_number(msg_cnt) := p_rtrvd_tcs.po_number(err_index);
	       line_number(msg_cnt) := p_rtrvd_tcs.po_line_number(err_index);
	       original_index(msg_cnt) := err_index;
	       msg_data(msg_cnt) := SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);


         / *  old comment
          dbms_output.put_line('Error ' || i || ' occurred during '||
             'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
          dbms_output.put_line('Oracle error is ' ||
             SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
         * /
   END LOOP;

    return (PO_RTRVD_TCS_ERR_REC(tc_id  => tc_id,
                                 tc_day_id  => tc_day_id,
                                 tc_detail_id => tc_detail_id,
                                 po_number  => po_number,
                                 line_number => line_number,
                                 original_index => original_index,
                                 msg_data   => msg_data
                                ));

   end add_error;

end of 8i compatibility issue
*/
--  *** PUBLIC PROCEDURES  **
procedure initGlobals
is
begin
  g_cur_po_header_id := null;
  g_cur_po_line_id := null;
end initGlobals;

function isFirstOccurance(p_po_header_id number, p_po_line_id number)
    return number is
    begin
    if (p_po_header_id = g_cur_po_header_id and p_po_line_id = g_cur_po_line_id) then
      return 1;
    else
      g_cur_po_header_id := p_po_header_id;
      g_cur_po_line_id := p_po_line_id;
      return 0;
    end if;
end ;

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
	p_action  VARCHAR2,
	p_interface_transaction_id number
	) is
  l_po_header_id  number;
  l_po_currency varchar2(15);
  l_po_creation_date  date;
  l_po_line_id number;
  l_po_line_number number;
  l_contractor_full_name varchar2(500);
  l_contractor_first_name varchar2(240);
  l_contractor_last_name varchar2(240);
  l_project_name  varchar2(255);
  l_task_number   varchar2(255);
  l_line_rate	number;
  l_stage  varchar2(2000);
  l_vendor_id  number;
  l_vendor_site_id number;
  l_action  varchar2(2);
  l_po_number varchar2(20);
  l_org_id number;
  l_tc_approved_date  date;
  l_tc_uom  varchar2(30);
  l_tc_start_date date;
  l_tc_end_date date;
  l_tc_entry_date date;
  l_contingent_worker_id number;
  l_line_rate_type varchar2(30);
  l_tc_entry_seq  number;

  l_get_fresh varchar2(1) := 'N';
  -- Bug6391432
  -- To avoid the no data found for a zero amount time card correction
  -- added up the logic to catch NO_DATA_FOUND exception and treat the
  -- update action as insert action for timecards which had zero amount
  -- when making a insert in ISP table and didnt went into ISP table.
  begin

       if (upper(p_action) = 'UPDATE' OR upper(p_action) = 'DELETE') then
           --Get the mandatory data to create a new row with the above action.
           l_stage := 'Getting ready to UPDATE or DELETE';
	   Begin
           select VENDOR_ID, VENDOR_SITE_ID, PO_HEADER_ID, PO_NUMBER, PO_LINE_ID, PO_LINE_NUMBER,
                  ORG_ID, PO_CREATION_DATE,
	     	         PO_CONTRACTOR_FULL_NAME, TC_UOM, TC_APPROVED_DATE,
	     	         TC_START_DATE, TC_ENTRY_DATE, TC_END_DATE,
	     	         CONTINGENT_WORKER_ID, LINE_RATE_TYPE, LINE_RATE, LINE_RATE_CURRENCY
	     	    into l_vendor_id, l_vendor_site_id, l_po_header_id, l_po_number,
	     	         l_po_line_id, l_po_line_number,
	     	         l_org_id, l_po_creation_date,
	     	         l_contractor_full_name, l_tc_uom, l_tc_approved_date,
	     	         l_tc_start_date, l_tc_entry_date, l_tc_end_date,
	     	         l_contingent_worker_id, l_line_rate_type, l_line_rate, l_po_currency
	     	    from po_retrieved_timecards
  	           where tc_detail_id = p_tc_detail_id and tc_day_id = p_tc_day_id and
  	                 tc_id = p_tc_id and rownum = 1;  --all we need is mandatory data; so first row is sufficient.
  	   EXCEPTION
 	                  WHEN No_Data_Found THEN
 	                     l_get_fresh := 'Y';
 	   END;
	   l_stage := 'Got data for UPDATE or DELETE';
  	   END IF;
  	   IF ( (NOT (upper(p_action) = 'UPDATE' OR upper(p_action) = 'DELETE') ) OR
 	          l_get_fresh = 'Y') THEN
  	        l_action := 'I';
  	        l_stage := 'Getting ready for INSERT';

  	       	 select po_header_id, currency_code, creation_date,
	   	            vendor_id, vendor_site_id
	           into l_po_header_id, l_po_currency, l_po_creation_date,
	   	            l_vendor_id, l_vendor_site_id
	           from po_headers_all
  	          where segment1 = p_po_num and org_id = p_org_id;

              l_stage := 'Getting the line id';
	          SELECT po_line_id
	            INTO l_PO_LINE_ID
	            FROM  po_lines_all pla
	           WHERE pla.po_header_id = l_po_header_id
                 AND pla.line_num = p_po_line_number;



              if (p_line_rate is null or p_line_rate = 0) then

                 l_stage := 'getting the line rate';
  	             SELECT ptlv.rate_value
	               INTO l_line_rate
	               FROM po_temp_labor_rates_v ptlv, po_lines_all pla
                  WHERE ptlv.po_line_id = pla.po_line_id
                    AND ptlv.asg_rate_type = p_line_rate_type
                    AND pla.po_header_id = l_po_header_id
                    AND pla.line_num = p_po_line_number;
             else
                 l_line_rate := p_line_rate;
             end if;

  	         if (p_contingent_worker_id is not null) then
  	             l_stage := 'getting the contingent worker';
		     -- Bug6391432
 	             -- Use per_all_people_f instead of per_people_f because of security settings
 	             -- for this responsibility/user settings, some of the resource ids may not be
 	             -- eligible for the per_people_f view criteria. which in turn will fail the query.
  	             select first_name || last_name contractor_full_name,
	   	                first_name, last_name
	     	       into l_contractor_full_name,
	   	                l_contractor_first_name, l_contractor_last_name
	   	           from per_all_people_f
  	              where person_id = p_contingent_worker_id and
  	                    sysdate between effective_start_date and effective_end_date;
  	          end if;

              if (p_project_id is not null) then
  	             l_stage := 'getting the project id';
  	             select SEGMENT1
  	               into l_project_name
  	               from PA_PROJECTS_ALL
  	              where project_id = p_project_id;

  	              if (p_task_id is not null) then
  	                 l_stage := 'getting the task id';
  	                 select TASK_NUMBER
  	                   into l_task_number
  	                   from PA_TASKS
  	                  where project_id = p_project_id and task_id = p_task_id;
  	               end if;

              end if;
          /* set the local vars right to get ready to insert */
          l_stage := 'Getting some misc data before INSERT';
          l_po_number := p_PO_NUM;
          l_po_line_number := p_po_line_number;
          l_ORG_ID := p_ORG_ID;
          l_TC_UOM := p_TC_UOM;
          l_TC_START_DATE := p_TC_START_DATE;
	      l_TC_END_DATE := p_TC_END_DATE;
	      l_TC_ENTRY_DATE := p_TC_ENTRY_DATE;
	      l_tc_approved_date := p_TC_APPROVAL_DATE;
	      l_CONTINGENT_WORKER_ID := p_CONTINGENT_WORKER_ID;
	      l_LINE_RATE_TYPE := p_LINE_RATE_TYPE;


       end if;  --end of if insert

  	if (upper(p_action) = 'UPDATE') then
  	  l_stage := 'updating';
  	  /*
  	  update PO_RETRIEVED_TIMECARDS
  	  set tc_time_received = p_tc_time_received, tc_comment_text = p_tc_comment_text,
  	      line_rate_type = p_line_rate_type, line_rate =  p_line_rate
  	  where tc_detail_id = p_tc_detail_id and tc_day_id = p_tc_day_id and tc_id = p_tc_id;
  	  */


  	  l_action := 'U';
  	elsif (upper(p_action) = 'DELETE') then
  	  l_stage := 'deleting';
  	  l_action := 'D';
  	  /*
  	  delete PO_RETRIEVED_TIMECARDS
  	  where tc_detail_id = p_tc_detail_id and tc_day_id = p_tc_day_id and tc_id = p_tc_id;
  	  */
    end if;

    select po_timecards_entry_s.nextval into l_tc_entry_seq  from dual;
    l_stage := 'inserting';

  	insert into PO_RETRIEVED_TIMECARDS
  	(
  	  PO_HEADER_ID,
	  PO_NUMBER,
	  PO_LINE_ID,
	  PO_LINE_NUMBER,
	  ORG_ID,
	  PO_CREATION_DATE,
	  PO_CONTRACTOR_FULL_NAME,
	  PROJECT_ID,
	  PROJECT_NAME,
	  TASK_ID,
	  TASK_NAME,
	  TC_ID,
	  TC_DAY_ID,
	  TC_DETAIL_ID,
	  TC_SCOPE,
	  TC_UOM,
	  TC_START_DATE,
	  TC_END_DATE,
	  TC_ENTRY_DATE,
	  TC_TIME_RECEIVED,
	  TC_SUBMISSION_DATE,
	  TC_APPROVED_DATE,
	  TC_APPROVAL_STATUS,
	  CONTINGENT_WORKER_ID,
	  TC_COMMENT_TEXT,
	  LINE_RATE_TYPE,
	  LINE_RATE,
	  LINE_RATE_CURRENCY,
	  VENDOR_ID,
	  VENDOR_SITE_ID,
	  VENDOR_CONTACT_ID,
	  PO_CONTRACTOR_FIRST_NAME,
      PO_CONTRACTOR_LAST_NAME,
      INTERFACE_TRANSACTION_ID,
      ACTION_FLAG,
      TC_ENTRY_SEQUENCE
  	)
  	values
  	(
  	 l_PO_HEADER_ID,
	 l_PO_NUMBER,
	 l_PO_LINE_ID,
	 l_PO_LINE_NUMBER,
	 l_ORG_ID,
     l_po_creation_date,
	 l_CONTRACTOR_FULL_NAME,
     p_PROJECT_ID,
	 l_PROJECT_NAME,
	 p_TASK_ID,
	 l_TASK_NUMBER,
	 p_TC_ID,
	 p_TC_DAY_ID,
	 p_TC_DETAIL_ID,
     'DETAIL',
	 l_TC_UOM,
	 l_TC_START_DATE,
	 l_TC_END_DATE,
	 l_TC_ENTRY_DATE,
	 p_TC_TIME_RECEIVED,
	 p_TC_SUBMISSION_DATE,
	 l_tc_approved_date,
	 p_TC_APPROVAL_STATUS,
	 l_CONTINGENT_WORKER_ID,
	 p_TC_COMMENT_TEXT,
	 l_LINE_RATE_TYPE,
	 l_LINE_RATE,
	 l_PO_CURRENCY,
	 l_VENDOR_ID,
	 l_VENDOR_SITE_ID,
	 p_VENDOR_CONTACT_ID,
	 l_contractor_first_name,
     l_contractor_last_name,
     p_interface_transaction_id,
     l_action,
     l_tc_entry_seq
  	);

  	x_return_status := FND_API.G_RET_STS_SUCCESS;

  	--Do not commit

  	exception
  	when others then
  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_msg_data  := 'Action = ' || p_action || 'Stage = ' || l_stage ||  ' PO Number: ' || p_po_num ||
	               ' Line : ' || to_char(p_po_line_number) ||
	               ' TC_ID : ' || to_char (p_tc_id) ||
	               ' TC_DAY_ID : ' || to_char(p_tc_day_id) ||
	               ' TC_DETAIL_ID : ' || to_char(p_tc_detail_id) ||
	               ' Error : ' || SQLERRM
	               ;
	-- dbms_output.put_line(SQLERRM);

end store_timecard_details;


 procedure reconcile_actions (p_api_version number,
                              x_return_status  out NOCOPY varchar2,
                              x_msg_data       out NOCOPY varchar2
                              )
 is
 cursor  reconcile_csr is
   select /*+ PO_RETRIEVED_TIMECARDS_N6 */ tc_id, tc_day_id, tc_detail_id,
          action_flag, tc_time_received,
          tc_comment_text, interface_transaction_id
     from po_retrieved_timecards
     where action_flag in ('I', 'U', 'D')
     order by TC_ENTRY_SEQUENCE;

 l_tc_id number;
 l_tc_day_id number;
 l_tc_detail_id number;
 l_action_flag varchar2(2);
 l_tc_time_received number;
 l_tc_comment_text varchar2(2000);
 l_transaction_id  number;

 begin

 --First cleanup all the failed transactions from the po_retrieved_timecards.
 delete /*+ PO_RETRIEVED_TIMECARDS_N6 */po_retrieved_timecards prt
    where action_flag in ('I', 'U', 'D') and
          not exists (select interface_transaction_id from rcv_transactions
                      where interface_transaction_id = prt.interface_transaction_id);

  --now we will reconcile the succsful transactions.
  open reconcile_csr;
  loop

    fetch reconcile_csr into
       l_tc_id, l_tc_day_id, l_tc_detail_id,
          l_action_flag, l_tc_time_received,
          l_tc_comment_text, l_transaction_id;

    exit when reconcile_csr%NOTFOUND;


    if (l_action_flag = 'I') then
       update po_retrieved_timecards
       set action_flag = 'P'
       where tc_id = l_tc_id and
             tc_day_id = l_tc_day_id and
             tc_detail_id = l_tc_detail_id and
             action_flag = 'I';

    elsif (l_action_flag = 'U') then
         update po_retrieved_timecards
            set tc_time_received = l_tc_time_received,
                tc_comment_text = l_tc_comment_text
          where tc_id = l_tc_id and
                tc_day_id = l_tc_day_id and
                tc_detail_id = l_tc_detail_id and
                action_flag = 'P';
    elsif (l_action_flag = 'D') then
         update po_retrieved_timecards
            set action_flag = 'DP'
         where tc_id = l_tc_id and
               tc_day_id = l_tc_day_id and
               tc_detail_id = l_tc_detail_id and
               action_flag = 'P';

    end if;

  end loop;

  close reconcile_csr;

 delete po_retrieved_timecards
  where action_flag in ('U', 'D');


   x_return_status := FND_API.G_RET_STS_SUCCESS;

  	--Do not commit


 exception
 when others then
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_data := ' Error : ' || SQLERRM;
 end;



 procedure store_timecard_details_rec (p_api_version number,
                                   x_return_status	out NOCOPY varchar2,
	                           x_msg_data      out NOCOPY varchar2,
	                           p_rtrvd_tc  PO_RTRVD_TC_REC,
                                   p_action	VARCHAR2
                                  ) is
 begin
    store_timecard_details
    	(
    	 p_api_version           => p_api_version,
         x_return_status         => x_return_status,
    	 x_msg_data              =>x_msg_data,
    	p_vendor_id              =>p_rtrvd_tc.VENDOR_ID,
    	p_vendor_site_id         =>p_rtrvd_tc.VENDOR_SITE_ID,
    	p_vendor_contact_id      =>p_rtrvd_tc.VENDOR_CONTACT_ID,
    	p_po_num                 =>p_rtrvd_tc.PO_NUMBER,
    	p_po_line_number         =>p_rtrvd_tc.PO_LINE_NUMBER,
    	p_org_id                 =>p_rtrvd_tc.ORG_ID,
    	p_project_id             =>p_rtrvd_tc.PROJECT_ID,
    	p_task_id                =>p_rtrvd_tc.TASK_ID,
    	p_tc_id                  =>p_rtrvd_tc.TC_ID,
    	p_tc_day_id              =>p_rtrvd_tc.TC_DAY_ID,
    	p_tc_detail_id           =>p_rtrvd_tc.TC_DETAIL_ID ,
    	p_tc_uom                 =>p_rtrvd_tc.TC_UOM,
    	p_tc_Start_date          =>p_rtrvd_tc.TC_START_DATE ,
    	p_tc_end_date            =>p_rtrvd_tc.TC_END_DATE,
    	p_tc_entry_date          =>p_rtrvd_tc.TC_ENTRY_DATE,
    	p_tc_time_received       =>p_rtrvd_tc.TC_TIME_RECEIVED,
    	p_tc_approval_status     =>p_rtrvd_tc.TC_APPROVAL_STATUS,
    	p_tc_approval_date       =>p_rtrvd_tc.TC_APPROVED_DATE,
    	p_tc_submission_date     =>p_rtrvd_tc.TC_SUBMISSION_DATE,
    	p_contingent_worker_id   =>p_rtrvd_tc.CONTINGENT_WORKER_ID,
    	p_tc_comment_text        =>p_rtrvd_tc.TC_COMMENT_TEXT,
    	p_line_rate_type         =>p_rtrvd_tc.LINE_RATE_TYPE,
    	p_line_rate              => p_rtrvd_tc.LINE_RATE,
        p_action                 => p_action,
        p_interface_transaction_id       => 0  --this api is not being used currently.
    	);

  exception
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := ' Error : ' || SQLERRM;
 end store_timecard_details_rec;


/*  8i compatibility issue.  Commenting out.
 procedure store_timecard_details_bulk (p_api_version number,
                                       x_return_status	out NOCOPY varchar2,
	                                   x_msg_data      out NOCOPY varchar2,
	                                   p_rtrvd_tcs PO_RTRVD_TCS_REC,
	                                   p_action varchar2,
	                                   x_errs out NOCOPY PO_RTRVD_TCS_ERR_REC)
is
errors  NUMBER;
err_index  number;
dml_errors EXCEPTION;
PRAGMA exception_init(dml_errors, -24381);
begin

 if (upper(p_action) = 'UPDATE') then
    forall i in p_rtrvd_tcs.po_number.first..p_rtrvd_tcs.po_number.last
       SAVE EXCEPTIONS
  	  update PO_RETRIEVED_TIMECARDS
  	  set tc_time_received = p_rtrvd_tcs.tc_time_received(i),
  	      tc_comment_text = p_rtrvd_tcs.tc_comment_text(i),
  	      line_rate_type = p_rtrvd_tcs.line_rate_type(i),
  	      line_rate =  p_rtrvd_tcs.line_rate(i)
  	  where tc_detail_id = p_rtrvd_tcs.tc_detail_id(i) and
  	        tc_day_id = p_rtrvd_tcs.tc_day_id(i) and
  	        tc_id = p_rtrvd_tcs.tc_id(i);

 elsif (upper(p_action) = 'DELETE') then
 forall i in p_rtrvd_tcs.po_number.first..p_rtrvd_tcs.po_number.last
     SAVE EXCEPTIONS
  	  delete PO_RETRIEVED_TIMECARDS
  	  where tc_detail_id = p_rtrvd_tcs.tc_detail_id(i) and
  	        tc_day_id = p_rtrvd_tcs.tc_day_id(i) and
  	        tc_id = p_rtrvd_tcs.tc_id(i);

 else

  forall i in p_rtrvd_tcs.po_number.first..p_rtrvd_tcs.po_number.last
     SAVE EXCEPTIONS
    insert into PO_RETRIEVED_TIMECARDS
  	(
  	  PO_HEADER_ID,
	  PO_NUMBER,
	  PO_LINE_ID,
	  PO_LINE_NUMBER,
	  ORG_ID,
	  PO_APPROVED_DATE,
	  PO_CONTRACTOR_FULL_NAME,
	  PROJECT_ID,
	  PROJECT_NAME,
	  TASK_ID,
	  TASK_NAME,
	  TC_ID,
	  TC_DAY_ID,
	  TC_DETAIL_ID,
	  TC_SCOPE,
	  TC_UOM,
	  TC_START_DATE,
	  TC_END_DATE,
	  TC_ENTRY_DATE,
	  TC_TIME_RECEIVED,
	  TC_SUBMISSION_DATE,
	  TC_APPROVED_DATE,
	  TC_APPROVAL_STATUS,
	  CONTINGENT_WORKER_ID,
	  TC_COMMENT_TEXT,
	  LINE_RATE_TYPE,
	  LINE_RATE,
	  LINE_RATE_CURRENCY,
	  VENDOR_ID,
	  VENDOR_SITE_ID,
	  VENDOR_CONTACT_ID,
	  PO_CONTRACTOR_FIRST_NAME,
      PO_CONTRACTOR_LAST_NAME
  	)
  	values
  	(
  	 p_rtrvd_tcs.PO_HEADER_ID(i),
	 p_rtrvd_tcs.PO_NUMBER(i),
	 p_rtrvd_tcs.PO_LINE_ID(i),
	 p_rtrvd_tcs.PO_LINE_NUMBER(i),
	 p_rtrvd_tcs.ORG_ID(i),
     p_rtrvd_tcs.po_CREATION_DATE(i),
	 p_rtrvd_tcs.CONTRACTOR_FULL_NAME(i),
     p_rtrvd_tcs.PROJECT_ID(i),
	 p_rtrvd_tcs.PROJECT_NAME(i),
	 p_rtrvd_tcs.TASK_ID(i),
	 p_rtrvd_tcs.TASK_NUMBER(i),
	 p_rtrvd_tcs.TC_ID(i),
	 p_rtrvd_tcs.TC_DAY_ID(i),
	 p_rtrvd_tcs.TC_DETAIL_ID(i),
     'DETAIL',
	 p_rtrvd_tcs.TC_UOM(i),
	 p_rtrvd_tcs.TC_START_DATE(i),
	 p_rtrvd_tcs.TC_END_DATE(i),
	 p_rtrvd_tcs.TC_ENTRY_DATE(i),
	 p_rtrvd_tcs.TC_TIME_RECEIVED(i),
	 p_rtrvd_tcs.TC_SUBMISSION_DATE(i),
	 p_rtrvd_tcs.TC_APPROVAL_DATE(i),
	 p_rtrvd_tcs.TC_APPROVAL_STATUS(i),
	 p_rtrvd_tcs.CONTINGENT_WORKER_ID(i),
	 p_rtrvd_tcs.TC_COMMENT_TEXT(i),
	 p_rtrvd_tcs.LINE_RATE_TYPE(i),
	 p_rtrvd_tcs.LINE_RATE(i),
	 p_rtrvd_tcs.PO_CURRENCY(i),
	 p_rtrvd_tcs.VENDOR_ID(i),
	 p_rtrvd_tcs.VENDOR_SITE_ID(i),
	 p_rtrvd_tcs.VENDOR_CONTACT_ID(i),
	 p_rtrvd_tcs.contractor_first_name(i),
     p_rtrvd_tcs.contractor_last_name(i)
  	);
 end if;

exception
  when dml_errors then
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  x_msg_data := '';

  x_errs := add_error (p_rtrvd_tcs);

  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := ' Error : ' || SQLERRM;

end store_timecard_details_bulk;

End of 8i compatibility issue.
*/


end PO_STORE_TIMECARD_PKG_GRP;

/
