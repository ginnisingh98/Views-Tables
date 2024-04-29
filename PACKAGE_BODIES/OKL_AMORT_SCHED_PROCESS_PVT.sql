--------------------------------------------------------
--  DDL for Package Body OKL_AMORT_SCHED_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AMORT_SCHED_PROCESS_PVT" as
 /* $Header: OKLRLAMB.pls 120.6 2008/02/12 18:52:01 srsreeni noship $ */
  -- Start of comments
  --
  -- API name       : insert_hdr
  -- Pre-reqs       : None
  -- Function       : This procedure inserts the Amortization Schedule generated
  --                  into the OKL_AMORT_SCHED_HDRS
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --				  p_trx_req_id	- Request ID from okl_trx_requests table
  --				  p_summ_flag	- Boolean value indicating whether summary is available
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  --				  x_amor_hdr_id - The header ID record
  -- Version        : 1.0
  -- History        : srsreeni created.
	procedure insert_hdr(p_api_version IN  NUMBER,p_init_msg_list IN VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,
							   x_msg_count OUT NOCOPY NUMBER,x_msg_data OUT NOCOPY VARCHAR2,
							   p_trx_req_id in okl_trx_requests.id%type,p_summ_flag in boolean,
							   x_amor_hdr_id out NOCOPY amort_hdr_id_tbl_type) as
			l_amor_hdr_id amort_hdr_id_tbl_type;
			l_hdr_id number;
			l_indx number := 1;
			l_amor_type varchar2(30) := G_PRINCIPAL_TYPE;
	begin
		x_return_status := OKL_API.G_RET_STS_SUCCESS;
--Insert for Detail
--Insert 4 records into the header for detail for Principal, Interest, Principal Balance, and Period
		for ins_count in 1 .. G_DET_COLUMNS
		loop
			select okl_amort_sched_hdr_s.nextval into l_hdr_id from dual;
			if ins_count = 1 then
				l_amor_hdr_id(l_indx).pri_det_id := l_hdr_id;
				l_amor_type := G_PRINCIPAL_TYPE;
			elsif ins_count = 2 then
				l_amor_hdr_id(l_indx).int_det_id := l_hdr_id;
				l_amor_type := G_INTEREST_TYPE;
			elsif ins_count = 3 then
				l_amor_hdr_id(l_indx).pri_bal_det_id := l_hdr_id;
				l_amor_type := G_PRINCIPAL_BAL_TYPE;
			elsif ins_count = 4 then
				l_amor_hdr_id(l_indx).date_from_det_id := l_hdr_id;
				l_amor_type := G_DATE_FROM;
			elsif ins_count = 5 then
				l_amor_hdr_id(l_indx).loan_pymnt_det_id := l_hdr_id;
				l_amor_type := G_LOAN_PAYMENT;
			elsif ins_count = 6 then
				l_amor_hdr_id(l_indx).pastproj_det_id := l_hdr_id;
				l_amor_type := G_PAST_PROJ;
			elsif ins_count = 7 then
				l_amor_hdr_id(l_indx).proj_interest_rate_id := l_hdr_id;
				l_amor_type := G_PROJ_INTEREST_RATE;
			else
				l_amor_hdr_id(l_indx).order_by_det_id := l_hdr_id;
				l_amor_type := G_ORDER_BY;
			end if;
			insert into OKL_AMORT_SCHED_HDRS (AMORT_HDR_ID,TRX_REQ_ID,AMORT_TYPE,AMORT_REPORT_FLAG,created_by,creation_date,
									   		  LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
			values(l_hdr_id,p_trx_req_id,l_amor_type,G_REPORT_TYPE_DETAIL_C,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
		end loop;
--        dbms_output.put_line('After invoking insert detail');
--Insert for Summary only if data is available
		if p_summ_flag then
--            dbms_output.put_line('Inside invoking insert summary');

--Insert 5 records into the header for detail for Principal, Interest, Principal Balance, Date from and Date to
			for ins_count in 1 .. G_SUMM_COLUMNS
			loop
				select okl_amort_sched_hdr_s.nextval into l_hdr_id from dual;
				if ins_count = 1 then
					l_amor_hdr_id(l_indx).pri_summ_id := l_hdr_id;
					l_amor_type := G_PRINCIPAL_TYPE;
				elsif ins_count = 2 then
					l_amor_hdr_id(l_indx).int_summ_id := l_hdr_id;
					l_amor_type := G_INTEREST_TYPE;
				elsif ins_count = 3 then
					l_amor_hdr_id(l_indx).pri_bal_summ_id := l_hdr_id;
					l_amor_type := G_PRINCIPAL_BAL_TYPE;
				elsif ins_count = 4 then
					l_amor_hdr_id(l_indx).date_from_summ_id := l_hdr_id;
					l_amor_type := G_DATE_FROM;
				elsif ins_count = 5 then
					l_amor_hdr_id(l_indx).date_to_summ_id := l_hdr_id;
					l_amor_type := G_DATE_TO;
				elsif ins_count = 6 then
					l_amor_hdr_id(l_indx).loan_pymnt_summ_id := l_hdr_id;
					l_amor_type := G_LOAN_PAYMENT;
				else
					l_amor_hdr_id(l_indx).order_by_summ_id := l_hdr_id;
					l_amor_type := G_ORDER_BY;
				end if;
				insert into OKL_AMORT_SCHED_HDRS (AMORT_HDR_ID,TRX_REQ_ID,AMORT_TYPE,AMORT_REPORT_FLAG,created_by,creation_date,
												  LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values(l_hdr_id,p_trx_req_id,l_amor_type,G_REPORT_TYPE_SUMMARY_C,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
			end loop;
		end if;
		x_amor_hdr_id := l_amor_hdr_id;
	exception
	    WHEN OKL_API.G_EXCEPTION_ERROR Then
    	  x_return_status := OKL_API.G_RET_STS_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_ERROR;
	    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    	  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    WHEN OTHERS THEN
	      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	end insert_hdr;


  -- Start of comments
  --
  -- API name       : insert_lines
  -- Pre-reqs       : None
  -- Function       : This procedure inserts the Amortization Schedule generated
  --                  into the OKL_AMORT_SCHED_LINES
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --				  p_amort_sched_tbl - PL/SQL table for amor schedule
  --				  p_amor_line_id - PL/SQL table containing AMORT_LINE_ID
  --				  p_pri_id  - Principal Header Id
  --				  p_int_id  - Interest Header Id
  --				  p_pri_bal_id - Principal Balance Header Id
  --        		  p_date_from_id - Date From Header Id
  --				  p_loan_pymnt_id - Loan Payment Header Id
  --                  p_pastproj_id - Past Projected Header Id
  --				  p_date_to_id - Date To Header Id
  --		      p_proj_interest_rate_id - Proj Interest Rate Header Id
  --                  p_summ_flag - Indicates Summary Report or not
  --                  p_proj_interest_rate - The interest rate used for
  --                                         calculating projected schedule
  --                  p_order_by_id - The order by Header Id
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  -- Version        : 1.0
  -- History        : srsreeni created.
	procedure insert_lines(p_api_version IN  NUMBER,p_init_msg_list IN VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,
						   x_msg_count OUT NOCOPY NUMBER,x_msg_data OUT NOCOPY VARCHAR2,
						   p_amort_sched_tbl in OKL_LOAN_AMORT_SCHEDULE_PVT.amort_sched_tbl_type,p_amor_line_id in AMORT_LINE_ID,
   	 				       p_pri_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type,
						   p_int_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type,p_pri_bal_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type,
						   p_date_from_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type,p_loan_pymnt_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type,
						   p_pastproj_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type default NULL,
						   p_date_to_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type default null,
p_proj_interest_rate_id in OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%type default null,
						   p_summ_flag in boolean default false,
p_proj_interest_rate in number default NULL,p_order_by_id in
OKL_AMORT_SCHED_HDRS.AMORT_HDR_ID%TYPE) as
	begin
		x_return_status := OKL_API.G_RET_STS_SUCCESS;
--Following Code is performance oriented but commented since it is not supported in version prior to 11g.
/*
		--Insert for Principal
			forall ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
			insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date)
			values (p_pri_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).principal,g_user_id,sysdate);
		--Insert for Interest
			forall ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
			insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date)
			values (p_int_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).interest,g_user_id,sysdate);
		--Insert for Principal Balance
			forall ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
			insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date)
			values (p_pri_bal_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).principal_balance,g_user_id,sysdate);
		--Insert for Period
			forall ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
			insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date)
			values (p_date_from_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).start_date,g_user_id,sysdate);
		--Insert for Past
			forall ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
			insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date)
			values (p_pastproj_id,p_amor_line_id(ins_count),p_past_proj,g_user_id,sysdate);

		--Insert for Date To for Summary
			if p_summ_flag then
				forall ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date)
				values (p_date_to_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).end_date,g_user_id,sysdate);
			end if;
*/
			for ins_count in p_amort_sched_tbl.first .. p_amort_sched_tbl.last
			loop
		--Insert for Principal
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,
												   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_pri_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).principal,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
		--Insert for Interest
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,
												   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_int_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).interest,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
		--Insert for Principal Balance
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,
												   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_pri_bal_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).principal_balance,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
		--Insert for Loan Payment
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,
												   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_loan_pymnt_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).loan_payment,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
		--Insert for Period
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,
												   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_date_from_id,p_amor_line_id(ins_count),to_char(p_amort_sched_tbl(ins_count).start_date,'dd-mon-yyyy'),g_user_id,sysdate,g_user_id,sysdate,g_user_id);
		--Insert for Order BY
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,
												   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_order_by_id,p_amor_line_id(ins_count),ins_count,g_user_id,sysdate,g_user_id,sysdate,g_user_id);

		--Insert for Date To for Summary
				if p_summ_flag then
					insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
					values (p_date_to_id,p_amor_line_id(ins_count),to_char(p_amort_sched_tbl(ins_count).end_date,'dd-mon-yyyy'),g_user_id,sysdate,g_user_id,sysdate,g_user_id);
				else
--Insert into Payment type only for detail
				insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
				values (p_pastproj_id,p_amor_line_id(ins_count),p_amort_sched_tbl(ins_count).payment_type,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
--Insert for Projected Interest rate only for detail and for the first record
				if ins_count = 1 then
					insert into OKL_AMORT_SCHED_LINES(AMORT_HDR_ID,AMORT_LINE_ID,AMORT_VALUE,created_by,creation_date,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
					values (p_proj_interest_rate_id,p_amor_line_id(ins_count),p_proj_interest_rate,g_user_id,sysdate,g_user_id,sysdate,g_user_id);
				end if;
				end if;
			end loop;
	exception
		WHEN NO_DATA_FOUND then
			x_return_status := OKL_API.G_RET_STS_ERROR;
			x_msg_data := 'No data found in collection';
			RAISE OKL_API.G_EXCEPTION_ERROR;
		WHEN COLLECTION_IS_NULL then
			x_return_status := OKL_API.G_RET_STS_ERROR;
			x_msg_data := 'Collection is null';
			RAISE OKL_API.G_EXCEPTION_ERROR;
	    WHEN OKL_API.G_EXCEPTION_ERROR Then
    	  x_return_status := OKL_API.G_RET_STS_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_ERROR;
	    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    	  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    WHEN OTHERS THEN
	      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	end insert_lines;



  -- Start of comments
  --
  -- API name       : prepare_insert_lines
  -- Pre-reqs       : None
  -- Function       : This procedure prepares for inserting the Amortization Schedule generated
  --                  into the OKL_AMORT_SCHED_LINES
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --				  p_det_amort_sched_tbl - PL/SQL table for Detail amor schedule
  --				  p_summ_amort_sched_tbl - PL/SQL table for Summary amor schedule
  --				  p_amor_hdr_id - The header ID record
  --				  p_proj_interest_rate - The Projected interest
  --				rate
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  -- Version        : 1.0
  -- History        : srsreeni created.
	procedure prepare_insert_lines(p_api_version IN  NUMBER,p_init_msg_list IN VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,
							   x_msg_count OUT NOCOPY NUMBER,x_msg_data OUT NOCOPY VARCHAR2,
							   p_det_amort_sched_tbl in OKL_LOAN_AMORT_SCHEDULE_PVT.amort_sched_tbl_type,
							   p_summ_amort_sched_tbl in OKL_LOAN_AMORT_SCHEDULE_PVT.amort_sched_tbl_type,
   	   	 				       p_amor_hdr_id in amort_hdr_id_tbl_type,p_proj_interest_rate in number) as
   		l_det_amor_line_id AMORT_LINE_ID := AMORT_LINE_ID(-1);
   		l_summ_amor_line_id AMORT_LINE_ID := AMORT_LINE_ID(-1);
   		l_rec_count number := 0;
   		l_hdr_indx number := 1;
   		l_summ_det_cnt number := 0;
	begin
		x_return_status := OKL_API.G_RET_STS_SUCCESS;
--Retrieve the count of line_id for detail to be inserted. Retrieve the line_id from sequence
		if p_det_amort_sched_tbl is not null then
			l_rec_count := p_det_amort_sched_tbl.count;
		end if;
--Populate actual line_id
		if l_rec_count > 0 then
			l_rec_count := l_rec_count - 1;
			l_det_amor_line_id.extend(l_rec_count,1);
			for i in 1 .. l_det_amor_line_id.count
			loop
				select okl_amort_sched_lines_s.nextval into l_det_amor_line_id(i) from dual;
			end loop;
		end if;
--		dbms_output.put_line('l_det_amor_line_id : ' || l_det_amor_line_id.count || ',p_det_amort_sched_tbl.count: ' || p_det_amort_sched_tbl.count);
		l_rec_count := 0;
--Retrieve the count of line_id for summary to be inserted. Assign line_id from the detail
		if p_summ_amort_sched_tbl is not null then
			l_rec_count := p_summ_amort_sched_tbl.count;
		end if;
--Populate actual line_id
		if l_rec_count > 0 then
			l_rec_count := l_rec_count - 1;
			l_summ_amor_line_id.extend(l_rec_count,1);
--Logic to check if Detail Report has less records than Summary Report
			if l_summ_amor_line_id.count > l_det_amor_line_id.count then
				l_summ_det_cnt := l_det_amor_line_id.count;
			else
				l_summ_det_cnt := l_summ_amor_line_id.count;
			end if;

			for i in 1 .. l_summ_det_cnt
			loop
				l_summ_amor_line_id(i) := l_det_amor_line_id(i);
			end loop;
			if l_summ_amor_line_id.count > l_det_amor_line_id.count then
				l_summ_det_cnt := l_summ_det_cnt + 1;
				for i in l_summ_det_cnt .. l_summ_amor_line_id.count
				loop
					select okl_amort_sched_lines_s.nextval into l_summ_amor_line_id(i) from dual;
				end loop;
			end if;
		end if;

		if l_det_amor_line_id.first = -1 then
			x_msg_data := 'Error querying data for Detail Report';
			raise OKL_API.G_EXCEPTION_ERROR;
		end if;
--Insert Detail Schedule
		if p_det_amort_sched_tbl is not null and p_det_amort_sched_tbl.count > 0 then
			insert_lines(p_api_version => p_api_version,p_init_msg_list => p_init_msg_list,
						 x_return_status => x_return_status,x_msg_count => x_msg_count,
						 x_msg_data => x_msg_data,p_amort_sched_tbl =>  p_det_amort_sched_tbl,
						 p_amor_line_id => l_det_amor_line_id,
   	 				     p_pri_id => p_amor_hdr_id(l_hdr_indx).pri_det_id,
					     p_int_id => p_amor_hdr_id(l_hdr_indx).int_det_id,
						 p_pri_bal_id => p_amor_hdr_id(l_hdr_indx).pri_bal_det_id,
						 p_date_from_id => p_amor_hdr_id(l_hdr_indx).date_from_det_id,
						 p_loan_pymnt_id => p_amor_hdr_id(l_hdr_indx).loan_pymnt_det_id,
						 p_pastproj_id => p_amor_hdr_id(l_hdr_indx).pastproj_det_id,
p_proj_interest_rate_id => p_amor_hdr_id(l_hdr_indx).proj_interest_rate_id,
p_proj_interest_rate => p_proj_interest_rate,
p_order_by_id => p_amor_hdr_id(l_hdr_indx).order_by_det_id);
		end if;
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
--Insert Summary Schedule
		if p_summ_amort_sched_tbl is not null and p_summ_amort_sched_tbl.count > 0 then
			insert_lines(p_api_version => p_api_version,p_init_msg_list => p_init_msg_list,
						 x_return_status => x_return_status,x_msg_count => x_msg_count,
						 x_msg_data => x_msg_data,p_amort_sched_tbl =>  p_summ_amort_sched_tbl,
						 p_amor_line_id => l_summ_amor_line_id,
   	 				     p_pri_id => p_amor_hdr_id(l_hdr_indx).pri_summ_id,
						 p_int_id => p_amor_hdr_id(l_hdr_indx).int_summ_id,
						 p_pri_bal_id => p_amor_hdr_id(l_hdr_indx).pri_bal_summ_id,
						 p_date_from_id => p_amor_hdr_id(l_hdr_indx).date_from_summ_id,
						 p_loan_pymnt_id => p_amor_hdr_id(l_hdr_indx).loan_pymnt_summ_id,
						 p_date_to_id => p_amor_hdr_id(l_hdr_indx).date_to_summ_id,
						 p_summ_flag => true,
p_order_by_id => p_amor_hdr_id(l_hdr_indx).order_by_summ_id);
		end if;
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
	exception
	    WHEN OKL_API.G_EXCEPTION_ERROR Then
    	  x_return_status := OKL_API.G_RET_STS_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
		  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    	  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    WHEN OTHERS THEN
	      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
		  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	end prepare_insert_lines;

  -- Start of comments
  --
  -- API name       : delete_old_sched
  -- Pre-reqs       : None
  -- Function       : This procedure deletes the Amortization Schedule generated
  --                  in the past for the contract.Deletes both Summary and Detail
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --				  p_chr_id - Contract ID
  --				  p_req_id - Request ID from okl_trx_requests table
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  -- Version        : 1.0
  -- History        : srsreeni created.

	procedure delete_old_sched(p_api_version IN  NUMBER,p_init_msg_list IN VARCHAR2,x_return_status OUT NOCOPY VARCHAR2,
							   x_msg_count OUT NOCOPY NUMBER,x_msg_data OUT NOCOPY VARCHAR2,p_chr_id in okc_k_headers_b.id%type,
							   p_req_id in okl_trx_requests.id%type) as
		cursor trx_req_csr(p_chr_id in okc_k_headers_b.id%type,p_req_id in okl_trx_requests.id%type) is
		select nvl(max(trx_req_id),-1) trx_req_id from OKL_AMORT_SCHED_HDRS
		where trx_req_id = (select nvl(max(tr.id),-1) from okl_trx_requests tr
							where dnz_khr_id = p_chr_id and id < p_req_id
							and request_type_code='AMORITIZATION_SCHEDULE_CURRENT')
		group by AMORT_REPORT_FLAG;
        l_old_trx_req_id	okl_trx_requests.id%type := -1;
	begin
		x_return_status := OKL_API.G_RET_STS_SUCCESS;
--Depending on the report type insert into the tables appropriately
--Check if request already existing and retrieve the maximum request number
--Delete the records from the hdr and detail tables
		OPEN trx_req_csr(p_chr_id => p_chr_id,p_req_id => p_req_id);
	    FETCH trx_req_csr INTO l_old_trx_req_id;
		loop
		--If value returned from query is -1, then there is no report history for the contract
		--Else there is a record, deletion need to be performed to maintain one copy each of Summary/Detail
		--of the report for the contract
		    if l_old_trx_req_id is not null and l_old_trx_req_id <> -1 then
	    		delete from OKL_AMORT_SCHED_LINES where AMORT_HDR_ID in(select AMORT_HDR_ID from OKL_AMORT_SCHED_HDRS
				where trx_req_id=l_old_trx_req_id);
	    		delete from OKL_AMORT_SCHED_HDRS where trx_req_id=l_old_trx_req_id;
		    end if;
			--commit;
			exit when trx_req_csr%notfound;
			fetch trx_req_csr INTO l_old_trx_req_id;
		end loop;
	    CLOSE trx_req_csr;
	exception
	    WHEN OKL_API.G_EXCEPTION_ERROR Then
    	  x_return_status := OKL_API.G_RET_STS_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_ERROR;
	    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    	  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    WHEN OTHERS THEN
	      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    	  x_msg_data := substr(sqlerrm,1,255);
    	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	end delete_old_sched;

  -- Start of comments
  --
  -- API name       : generate_amor_sched
  -- Pre-reqs       : None
  -- Function       : This procedure is invoked to generate the Amortization Schedule
  --				  Invoked after the request record is created from Lease Center
  -- Parameters     :
  -- IN             : p_chr_id - Contract ID
  --				  p_trx_req_id - Request ID from okl_trx_requests table
  --				  p_user_id	-	User ID requesting the schedule
  -- OUT			: x_return_status - Standard output parameter for Output status
  --				  x_msg_count - Standard output parameter
  --				  x_msg_data - Standard output parameter
  --				  x_summ_flag - Boolean indicating whether Summary is available or not
  -- Version        : 1.0
  -- History        : srsreeni created.
    procedure generate_amor_sched(p_chr_id in okc_k_headers_b.id%type,p_api_version IN NUMBER,
								  p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
								  p_trx_req_id in okl_trx_requests.id%type,p_user_id in number,
    							  x_return_status OUT NOCOPY VARCHAR2,x_msg_count OUT NOCOPY NUMBER,
								  x_msg_data OUT NOCOPY VARCHAR2,x_summ_flag OUT boolean) as
        l_api_name		CONSTANT VARCHAR2(30) := 'GENERATE_AMOR_SCHED';
        l_api_version	CONSTANT NUMBER	      := 1.0;
		l_amor_hdr_id amort_hdr_id_tbl_type;
		l_summ_flag	boolean := false;
		l_det_amort_sched_tbl OKL_LOAN_AMORT_SCHEDULE_PVT.amort_sched_tbl_type;
		l_summ_amort_sched_tbl OKL_LOAN_AMORT_SCHEDULE_PVT.amort_sched_tbl_type;
		l_proj_interest_rate number;
    begin
    	g_user_id := p_user_id;
    	x_return_status := OKL_API.G_RET_STS_SUCCESS;
    	-- Call start_activity to create savepoint, check compatibility
    	-- and initialize message list
    	x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    	-- Check if activity started successfully
    	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    	END IF;

--        dbms_output.put_line('B4 invoking OKL_LOAN_AMORT_SCHEDULE_PVT - Detail');
--Invoke the API to obtain the generated amoritization schedule
--Invoke with Summary and Detail to generate the reports
        OKL_LOAN_AMORT_SCHEDULE_PVT.load_loan_amort_schedule(
   	        p_api_version => p_api_version,
       	    p_init_msg_list => OKL_API.G_TRUE,
           	x_return_status => x_return_status,
            x_msg_count => x_msg_count,
         	x_msg_data => x_msg_data,
         	p_chr_id => p_chr_id,
         	p_report_type => G_REPORT_TYPE_DETAIL,
		x_proj_interest_rate => l_proj_interest_rate,
           	x_amort_sched_tbl => l_det_amort_sched_tbl);
--        dbms_output.put_line('B4 invoking OKL_LOAN_AMORT_SCHEDULE_PVT - Summary');
       	OKL_LOAN_AMORT_SCHEDULE_PVT.load_loan_amort_schedule(
           	p_api_version => p_api_version,
           	p_init_msg_list => OKL_API.G_TRUE,
           	x_return_status => x_return_status,
           	x_msg_count => x_msg_count,
           	x_msg_data => x_msg_data,
           	p_chr_id => p_chr_id,
           	p_report_type => G_REPORT_TYPE_SUMMARY,
		x_proj_interest_rate => l_proj_interest_rate,
           	x_amort_sched_tbl => l_summ_amort_sched_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
--        dbms_output.put_line('B4 invoking delete_old_sched');
--Invoke procedure for deleting old reports for the contract if any
/*
		delete_old_sched(p_api_version       => p_api_version,
                         p_init_msg_list     => p_init_msg_list,
                         x_return_status     => x_return_status,
                         x_msg_count         => x_msg_count,
                         x_msg_data          => x_msg_data,
						 p_chr_id 		     => p_chr_id,
						 p_req_id 			 => p_trx_req_id);
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
	   */
	    if (l_summ_amort_sched_tbl is not null and l_summ_amort_sched_tbl.count > 0)
		then
	    	l_summ_flag := true;
	    end if;
--        dbms_output.put_line('B4 invoking insert_hdr');
--Insert records into the hdr tables for amor_sched and obtain header ID
		insert_hdr(p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
				   p_trx_req_id 	=> p_trx_req_id,
				   p_summ_flag		=> l_summ_flag,
				   x_amor_hdr_id	=> l_amor_hdr_id);
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
--        dbms_output.put_line('B4 invoking prepare_insert_lines');
--Insert records into the hdr and detail tables for the amor_sched
/*
		prepare_insert_lines(p_api_version       			=> p_api_version,
                         p_init_msg_list     			=> p_init_msg_list,
                         x_return_status     			=> x_return_status,
                         x_msg_count         			=> x_msg_count,
                         x_msg_data          			=> x_msg_data,
                         p_det_amort_sched_tbl			=> l_det_amort_sched_tbl,
                         p_det_amort_sched_proj_tbl 	=> l_det_amort_sched_proj_tbl,
                         p_summ_amort_sched_tbl			=> l_summ_amort_sched_tbl,
                         p_summ_amort_sched_proj_tbl 	=> l_summ_amort_sched_proj_tbl,
	 				     p_amor_hdr_id 					=> l_amor_hdr_id);*/
		prepare_insert_lines(p_api_version       			=> p_api_version,
                         p_init_msg_list     			=> p_init_msg_list,
                         x_return_status     			=> x_return_status,
                         x_msg_count         			=> x_msg_count,
                         x_msg_data          			=> x_msg_data,
                         p_det_amort_sched_tbl			=> l_det_amort_sched_tbl,
                         p_summ_amort_sched_tbl			=> l_summ_amort_sched_tbl,
	 				     p_amor_hdr_id 					=> l_amor_hdr_id,p_proj_interest_rate => l_proj_interest_rate);
	    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    	  RAISE Okl_Api.G_EXCEPTION_ERROR;
	    END IF;
        OKL_API.END_ACTIVITY (x_msg_count,x_msg_data);
		--commit;
		x_summ_flag := l_summ_flag;
    Exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --rollback;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --rollback;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN
      --rollback;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');
    end generate_amor_sched;
end OKL_AMORT_SCHED_PROCESS_PVT;

/
