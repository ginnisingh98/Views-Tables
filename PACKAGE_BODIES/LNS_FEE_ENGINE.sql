--------------------------------------------------------
--  DDL for Package Body LNS_FEE_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FEE_ENGINE" AS
/* $Header: LNS_FEE_ENGINE_B.pls 120.3.12010000.17 2010/02/25 05:05:28 mbolli ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_DEBUG_COUNT                       NUMBER := 0;
 G_DEBUG                             BOOLEAN := FALSE;
 G_FILE_NAME   CONSTANT VARCHAR2(30) := 'LNS_FEE_ENGINE_B.pls';

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_FEE_ENGINE';
-- G_AF_DO_DEBUG                       VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
 G_DAYS_COUNT                        NUMBER;
 G_DAYS_IN_YEAR                      NUMBER;

 --------------------------------------------
 -- internal package routines
 --------------------------------------------

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin
    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;

/*
function loanHasAssignment(p_loan_id        IN NUMBER
                          ,p_assignment_type IN VARCHAR2) return boolean
is
    vSql        varchar2(250);
    TYPE refCur IS REF CURSOR;
    c_hasAssign refCur;
    l_return    boolean;
    l_tmp       varchar2(1);

begin

    vSql := 'Select ''X''                  ' ||
             ' From lns_assignments        ' ||
             'Where exists                 ' ||
             '     (Select assignment_id   ' ||
             '        From lns_assignments ' ||
             '       Where loan_id = :a1   ' ||
             '         and assignment_type = :b1)';
--             dbms_output.put_line('plsql is ' || vSql);
        open c_hasAssign for
            vSql
            using p_loan_id
                 ,p_assignment_type;
        FETCH c_hasAssign INTO l_tmp;

        if c_hasAssign%FOUND then
            l_return := true;
        else
            l_return := false;
        end if;
        CLOSE c_hasAssign;

    return l_return;

end loanHasAssignment;
 */

/*=========================================================================
|| PUBLIC PROCEDURE reprocessFees LNS.B
||
|| DESCRIPTION
|| Overview: processes fees for CONVERSION EVENT or DISBURSEMENT
||
|| PSEUDO CODE/LOGIC
||        1. check if fees needs to be billed
||        2. calculate all fees
||        3. writeFees to the fee schedule
||        4. bill fees as manual billing
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
||            p_Phase => 'OPEN' then p_disb_head_id must not be null
||                       'TERM' then p_disb_head_id must be null
||            p_disb_head_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/28/2005            raverma           created
 *=======================================================================*/
procedure processDisbursementFees(p_init_msg_list      in  varchar2
						                     ,p_commit             in  varchar2
								     ,p_phase              in  varchar2
						                     ,p_loan_id            in  number
								     ,p_disb_head_id       in  number
						                     ,x_return_status      out nocopy varchar2
						                     ,x_msg_count          out nocopy number
						                     ,x_msg_data           out nocopy varchar2)
is
  l_api_name              varchar2(25);
  l_write_fee_tbl         LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_fee_id                number;
  l_fee_basis	            varchar2(25);
  l_fee_amount            number;
  l_fee_description       varchar2(60);
  l_last_payment_number   number;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(32767);
  l_BILL_HEADERS_TBL   LNS_BILLING_BATCH_PUB.BILL_HEADERS_TBL;
  l_BILL_LINES_TBL        	LNS_BILLING_BATCH_PUB.BILL_LINES_TBL;
  l_fees_tbl              		LNS_FEE_ENGINE.FEE_CALC_TBL;
  i                       		number;
  l_fee_installment         	number;
  l_phase				varchar2(30);

	-- get disbursement fees
	cursor c_DisbursementFees(p_disb_head_id number) is
  select ass.fee_id
        --,decode(ass.rate_type, 'FIXED', nvl(ass.fee,fee.fee), 'VARIABLE', nvl(ass.fee,fee.fee)/100 * head.header_amount)
        ,decode(ass.rate_type, 'FIXED', nvl(ass.fee,fee.fee), 'VARIABLE', lns_fee_engine.calculateFee(ass.fee_id, head.disb_header_id,  head.LOAN_ID))
        ,fee.fee_description
        ,ass.fee_basis
        ,nvl(ass.begin_installment_number, 0)  -- fix for bug 8928398
	,nvl(ass.phase, 'TERM')
  from lns_fee_assignments ass
      ,lns_disb_headers head
      ,lns_fees_all    fee
 where ass.loan_id is null
   and ass.disb_header_id = head.disb_header_id
   and fee.fee_id = ass.fee_id
   and ass.disb_header_id = p_disb_head_id;

	cursor c_ConversionFees(c_loan_id number) is
	select ass.fee_id
			,decode(ass.rate_type, 'FIXED', nvl(ass.fee,fee.fee), 'VARIABLE', nvl(ass.fee,fee.fee)/100)
			,fee.fee_description
			,ass.fee_basis
		from lns_fee_assignments ass
			,lns_fees_all fee
		where ass.fee_type = 'EVENT_CONVERSION'
		  and ass.fee_id = fee.fee_id
		  and loan_id = c_loan_id;

	-- fee basis for TOTAL_DISB_AMT
	cursor c_totalDisbursed(p_loan_id number) is
   select sum(l.line_amount)
    from  lns_disb_lines l
	     ,lns_disb_headers h
    where h.disb_header_id = l.disb_header_id
      and l.status = 'FULLY_FUNDED'
      and h.loan_id = p_loan_id;
	--
	cursor c_origLoanAmt(p_loan_id number) is
		select  requested_amount
			from  lns_loan_headers_all
			where loan_id = p_loan_id;

	cursor c_lastPaymentNumber(p_loan_id number) is
	select nvl(last_payment_number, 0)
		from lns_loan_headers_all
		where loan_id = p_loan_id;


begin
   l_api_name           := 'processDisbursementFees';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_id ' || p_loan_id);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase' || p_phase);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_disb_head_id' || p_disb_head_id);

   -- Standard Start of API savepoint
   SAVEPOINT processDisbursementFees;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
	 i := 0;
   -- 1. check if fees needs to be billed
   --	 if p_phase = 'OPEN' then
	   OPEN c_DisbursementFees(p_disb_head_id);
	   LOOP
	       i := i + 1;
	   FETCH c_DisbursementFees INTO
	        l_fee_id
	       ,l_fee_amount
	       ,l_fee_description
	       ,l_fee_basis
               ,l_fee_installment  -- fix for bug 8928398
	       ,l_phase;
	   EXIT WHEN c_DisbursementFees%NOTFOUND;

	   -- 2. calculate all fees
		if l_fee_basis = 'TOTAL_DISB_AMT' then
			open c_totalDisbursed(p_loan_id);
			fetch c_totalDisbursed into l_fee_amount;
			 close c_totalDisbursed;
		end if;

		l_write_fee_tbl(i).fee_id               := l_fee_id;
		l_write_fee_tbl(i).fee_amount      := l_fee_amount;
		l_write_fee_tbl(i).fee_installment := l_fee_installment;  -- fix for bug 8928398
		l_write_fee_tbl(i).fee_description := l_fee_description;
		l_write_fee_tbl(i).disb_header_id  := p_disb_head_id;
		l_write_fee_tbl(i).phase		    := l_phase;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee #: ' || i);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee id: ' || l_fee_id);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount: ' || l_fee_amount);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_fee_description: ' || l_fee_description);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_fee_basis ' || l_fee_basis);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_fee_installment ' || l_fee_installment);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_phase ' || l_phase);

	   END LOOP;


	   /*  Now, Conversion fees inserted into feeSchedules table when this fee is assigned
	 elsif p_phase = 'TERM' then


	   OPEN c_ConversionFees(p_loan_id);
	   LOOP
	        i := i + 1;
	   	FETCH c_ConversionFees INTO
			l_fee_id
			,l_fee_amount
			,l_fee_description
			 ,l_fee_basis;
	   	EXIT WHEN c_ConversionFees%NOTFOUND;

		if l_fee_basis = 'TOTAL_DISB_AMT' then
		 	open c_totalDisbursed(p_loan_id);
			fetch c_totalDisbursed into l_fee_amount;
			close c_totalDisbursed;
		elsif l_fee_basis = 'ORIG_LOAN' then
			open c_origLoanAmt(p_loan_id);
			fetch c_origLoanAmt into l_fee_amount;
			close c_origLoanAmt;
		end if;

		l_write_fee_tbl(i).fee_id          := l_fee_id;
		l_write_fee_tbl(i).fee_amount      := l_fee_amount;
		l_write_fee_tbl(i).fee_installment := 0;
		l_write_fee_tbl(i).fee_description := l_fee_description;
		l_write_fee_tbl(i).disb_header_id  := p_disb_head_id;
		l_write_fee_tbl(i).phase		    := p_phase;

	   	 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee #: ' || i);
	    	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee id: ' || l_fee_id);
	    	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount: ' || l_fee_amount);
	    	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_fee_description: ' || l_fee_description);
	    	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_fee_basis ' || l_fee_basis);

		l_fee_amount      := null;
		l_fee_id          := null;
		l_fee_basis       := null;
		l_fee_description := null;
	   END LOOP;
	   CLOSE c_ConversionFees;
	   */
	-- end if;   -- if p_phase = 'OPEN'

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - i ' || i);
	 if l_write_fee_tbl.count > 0 then
	   -- 3. writeFees to the fee schedule
	   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - writing fees schedule');
	   lns_fee_engine.writeFeeSchedule(p_init_msg_list      => p_init_msg_list
	                                  ,p_commit             => p_commit
	                                  ,p_loan_id            => p_loan_id
	                                  ,p_fees_tbl           => l_write_fee_tbl
	                                  ,x_return_status      => l_return_status
	                                  ,x_msg_count          => l_msg_count
	                                  ,x_msg_data           => l_msg_data);
	   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - writing fees schedule status ' || l_return_status);

	 end if;  -- l_write_fee_tb.count > 0


	 -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------
   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processDisbursementFees;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processDisbursementFees;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processDisbursementFees;

end processDisbursementFees;

/*=========================================================================
|| PUBLIC PROCEDURE reprocessFees LNS.B
||
|| DESCRIPTION
|| Overview: reprocesses fees when a loan is rebilled
||           will recalculate and write late fees and manual fees
||           will write these new fees to fee schedule
||           NOTE: recurring fees are processed during billing API call
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
||            p_installment  => installment number for the loan
||            p_phase	  =>  phase of the loan
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 3/15/2005             raverma           Created
||
 *=======================================================================*/
procedure reprocessFees(p_init_msg_list      in  varchar2
                       ,p_commit             in  varchar2
		       ,p_loan_id            in  number
                       ,p_installment_number in  number
		       ,p_phase		   in  varchar2
                       ,x_return_status      out nocopy varchar2
                       ,x_msg_count          out nocopy number
                       ,x_msg_data           out nocopy varchar2)
is

  l_api_name         varchar2(15);
  l_write_fee_tbl    LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_fee_id           number;
  l_fee_amount       number;
  l_fee_description  varchar2(250);
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(32767);
  i                  	    number;
  l_phase		    VARCHAR2(30);

  -- get the manual fee_ids that were added and billed for the installment
  -- also include origination fees
  -- need to get the max (amortization_id) in case of multiple credits
  cursor c_manual_fees (c_loan_id number, c_installment number, c_phase varchar2) is
  select sched.fee_id
        ,sched.fee_description
	,nvl(sched.phase, 'TERM')
    from lns_fee_schedules sched
        ,lns_fees  fees
        ,lns_amortization_lines lines
        ,lns_amortization_scheds am
   where fees.fee_id = sched.fee_id
     and lines.fee_schedule_id = sched.fee_schedule_id
     and lines.amortization_schedule_id = am.amortization_schedule_id
     and am.amortization_schedule_id =
        (select max(am2.amortization_schedule_id)
           from lns_amortization_scheds am2
          where am2.reversed_flag = 'Y'
            and am2.loan_id = c_loan_id )
     and am.reamortization_amount is null
     and sched.fee_installment = c_installment
     and ((fees.fee_category = 'MANUAL')
       OR (fees.fee_category = 'EVENT' AND fees.fee_type = 'EVENT_ORIGINATION'))
     and sched.loan_id = am.loan_id
     and am.loan_id = c_loan_id
     and sched.active_flag = 'Y'
     and sched.billed_flag = 'Y'
     and nvl(sched.phase, 'TERM') = nvl(c_phase, 'TERM');

begin
   l_api_name           := 'reprocessFees';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_id ' || p_loan_id);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - installment' || p_installment_number);

   -- Standard Start of API savepoint
   SAVEPOINT reprocessFees;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here
   i := 0;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - about to reprocess late fees');

   l_phase := nvl(p_phase, 'TERM');

   -- processing late fees will rewrite them to fee_schedules
   lns_fee_engine.processLateFees(p_init_msg_list => p_init_msg_list
                                 ,p_commit        => p_commit
				 ,p_loan_id       => p_loan_id
                                 ,p_phase       =>  l_phase
                                 ,x_return_status => l_return_status
                                 ,x_msg_count     => l_msg_count
                                 ,x_msg_data      => l_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - reprocess late fees status ' || l_return_status);
   -- we will rewrite any previously written manual fees onto the fee schedule
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - finding manual and origination fees');
   OPEN c_manual_fees(p_loan_id, p_installment_number, l_phase);
   LOOP
       i := i + 1;
   FETCH c_manual_fees INTO
        l_fee_id
       --,l_fee_amount
       ,l_fee_description
       ,l_phase;
   EXIT WHEN c_manual_fees%NOTFOUND;

    l_fee_amount := lns_fee_engine.calculateFee(p_fee_id        => l_fee_id
                                               			,p_loan_id            => p_loan_id
								,p_phase	 	   => l_phase);

    l_write_fee_tbl(i).fee_id          := l_fee_id;
    l_write_fee_tbl(i).fee_amount      := l_fee_amount;
    l_write_fee_tbl(i).fee_installment := p_installment_number;
    l_write_fee_tbl(i).fee_description := l_fee_description;
    l_write_fee_tbl(i).phase := l_phase;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee #: ' || i);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee id: ' || l_fee_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount: ' || l_fee_amount);
   END LOOP;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - writing fees schedule');
   lns_fee_engine.writeFeeSchedule(p_init_msg_list      => p_init_msg_list
                                  ,p_commit             => p_commit
                                  ,p_loan_id            => p_loan_id
                                  ,p_fees_tbl           => l_write_fee_tbl
                                  ,x_return_status      => l_return_status
                                  ,x_msg_count          => l_msg_count
                                  ,x_msg_data           => l_msg_data);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - writing fees schedule status ' || l_return_status);

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO reprocessFees;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO reprocessFees;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO reprocessFees;

end reprocessFees;

/*=========================================================================
|| PUBLIC FUNCTION getFeeStructures LNS.B
||
|| DESCRIPTION
|| Overview: returns structure of fees for a given loan
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
||            p_fee_category => fee category
||            p_fee_type     => fee type
||            p_installment  => installment number for the loan
||
|| Return value:
||               table of fee structures needed to calculate fees
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 1/20/2005             GWBush2           Created
||
 *=======================================================================*/
function getFeeStructures (p_fee_id in number) return LNS_FEE_ENGINE.FEE_STRUCTURE_TBL

   is

      l_fee_id                    number;
      l_fee_name                  varchar2(50);
      l_fee_type                  varchar2(30);
      l_fee_category              varchar2(30);
      l_fee                       number;
      l_fee_basis                 varchar2(30);
      l_billing_option            varchar2(30);
      l_rate_type                 varchar2(30);
      l_number_grace_days         number;
      l_minimum_overdue_amount    number;
      l_begin_installment_number  number;
      l_end_installment_number    number;
      l_fee_editable_flag         varchar2(1);
      l_fee_waivable_flag         varchar2(1);
      i                           number := 0;
      l_fee_struct_tbl            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
      l_api_name                  varchar2(25);

      cursor c_fees (fee_id number) is
      SELECT fees.fee_id
            ,fees.fee_name
            ,fees.fee_type
            ,fees.fee_category
            ,decode(fees.rate_type, 'FIXED', fees.fee, 'VARIABLE', fees.fee/100)
            ,fees.fee_basis
            ,fees.billing_option
            ,fees.rate_type
            ,fees.number_grace_days
            ,fees.minimum_overdue_amount
            ,0
            ,0
            ,nvl(fees.fee_editable_flag,'N')
            ,nvl(fees.fee_waivable_flag,'N')
      from  lns_fees_all fees
      where fees.fee_id = p_fee_id;

  begin
      l_api_name                  := 'getFeeStructures';

     open c_fees(p_fee_id) ;
        i := i + 1;
      fetch c_fees into
         l_fee_id
        ,l_fee_name
        ,l_fee_type
        ,l_fee_category
        ,l_fee
        ,l_fee_basis
        ,l_billing_option
        ,l_rate_type
        ,l_number_grace_days
        ,l_minimum_overdue_amount
        ,l_begin_installment_number
        ,l_end_installment_number
        ,l_fee_editable_flag
        ,l_fee_waivable_flag;

        l_fee_struct_tbl(i).fee_id                    := l_fee_id;
        l_fee_struct_tbl(i).fee_name                  := l_fee_name;
        l_fee_struct_tbl(i).fee_type                  := l_fee_type;
        l_fee_struct_tbl(i).fee_category              := l_fee_category;
        l_fee_struct_tbl(i).fee_amount                := l_fee;
        l_fee_struct_tbl(i).fee_basis                 := l_fee_basis;
        l_fee_struct_tbl(i).fee_billing_option        := l_billing_option;
        l_fee_struct_tbl(i).fee_rate_type             := l_rate_type;
        l_fee_struct_tbl(i).number_grace_days         := l_number_grace_days;
        l_fee_struct_tbl(i).minimum_overdue_amount    := l_minimum_overdue_amount;
        l_fee_struct_tbl(i).fee_from_installment      := l_begin_installment_number;
        l_fee_struct_tbl(i).fee_to_installment        := l_end_installment_number;
        l_fee_struct_tbl(i).fee_editable_flag         := l_fee_editable_flag;
        l_fee_struct_tbl(i).fee_waivable_flag         := l_fee_waivable_flag;
     close c_fees;

     return l_fee_struct_tbl;

     exception
        when no_data_found then
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - no fee structures found');
  end getFeeStructures;

/*=========================================================================
|| PUBLIC FUNCTION getFeeStructures LNS.B
||
|| DESCRIPTION
|| Overview: returns structure of fees for a given loan
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
||            p_fee_category => fee category
||            p_fee_type     => fee type
||            p_installment  => installment number for the loan
||
|| Return value:
||               table of fee structures needed to calculate fees
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 3/29/2004 8:40PM     raverma           Created
|| 15-Sep-2009     MBOLLI	Bug#8904071 -  Returned fee_description along with other column values
 *=======================================================================*/
function getFeeStructures(p_loan_id      in number
                         ,p_fee_category in varchar2
                         ,p_fee_type     in varchar2
                         ,p_installment  in number
			 ,p_phase	       in varchar2
                         ,p_fee_id       in number) return LNS_FEE_ENGINE.FEE_STRUCTURE_TBL

   is

      l_fee_id                    number;
      l_fee_name                  varchar2(50);
      l_fee_description		 varchar2(250);
      l_fee_type                  varchar2(30);
      l_fee_category              varchar2(30);
      l_fee                       number;
      l_fee_basis                 varchar2(30);
      l_billing_option            varchar2(30);
      l_rate_type                 varchar2(30);
      l_number_grace_days   number;
      l_minimum_overdue_amount    number;
      l_fee_basis_rule            varchar2(30);
      l_begin_installment_number  number;
      l_end_installment_number    number;
      l_fee_editable_flag       varchar2(1);
      l_fee_waivable_flag      varchar2(1);
      i                           	number := 0;
      l_fee_struct_tbl            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
      l_phase			varchar2(30);

      --vPLSQL                      varchar2(2000);
      --Type refCur is ref cursor;
      --sql_Cur                     refCur;
      l_api_name                  varchar2(25);

      cursor c_fees(p_loan_id number, p_fee_id number, p_fee_category varchar2, p_fee_type varchar2, p_installment number,c_phase varchar2) is
      SELECT fees.fee_id
            ,fees.fee_name
	    ,fees.fee_description
            ,fees.fee_type
            ,fees.fee_category
	  -- Bug#8915683, Now the FeeAssignment is updated for all fees. So use the assignment feeAmount
	    ,decode(fees.rate_type, 'FIXED', nvl(Assgn.fee,fees.fee), 'VARIABLE', nvl(Assgn.fee,fees.fee)/100)
            ,fees.fee_basis
            ,assgn.billing_option
            ,fees.rate_type
            ,fees.number_grace_days
            ,fees.minimum_overdue_amount
            ,fees.fee_basis_rule
            ,nvl(assgn.begin_installment_number,0)
            ,nvl(assgn.end_installment_number,0)
            ,nvl(fees.fee_editable_flag,'N')
            ,nvl(fees.fee_waivable_flag,'N')
	    ,nvl(assgn.phase, 'TERM')
       from lns_fee_assignments assgn
           ,lns_fees_all fees
       where assgn.loan_id = nvl(p_loan_id, assgn.loan_id)
         and assgn.fee_id = fees.fee_id
         and nvl(trunc(assgn.end_date_active), trunc(sysdate) + 1) >= trunc(sysdate)
         and nvl(trunc(assgn.start_date_active), trunc(sysdate) - 1) <= trunc(sysdate)
         and (((fees.fee_category = nvl(p_fee_category, fees.fee_category) and
              fees.fee_type = nvl(p_fee_type, fees.fee_type)))
            OR
           ((fees.fee_category = nvl(p_fee_category, fees.fee_category) and fees.fee_type is null)))
       and assgn.begin_installment_number <= nvl(p_installment, assgn.begin_installment_number)
       and assgn.end_installment_number >= nvl(p_installment, assgn.end_installment_number)
       and nvl(assgn.phase, 'TERM') = c_phase
       and fees.fee_id = nvl(p_fee_id, fees.fee_id);

  begin
     l_api_name                  := 'getFeeStructures';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id ' || p_loan_id);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee_category ' || p_fee_category);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee_type ' || p_fee_type);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment ' || p_installment);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase ' || p_phase);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_fee_id ' || p_fee_id);

     l_phase := nvl(p_phase, 'TERM');

     open c_fees(p_loan_id, p_fee_id, p_fee_category, p_fee_type, p_installment, l_phase);
     LOOP
        i := i + 1;
      fetch c_fees into
         l_fee_id
        ,l_fee_name
	,l_fee_description
        ,l_fee_type
        ,l_fee_category
        ,l_fee
        ,l_fee_basis
        ,l_billing_option
        ,l_rate_type
        ,l_number_grace_days
        ,l_minimum_overdue_amount
        ,l_fee_basis_rule
        ,l_begin_installment_number
        ,l_end_installment_number
        ,l_fee_editable_flag
        ,l_fee_waivable_flag
	,l_phase;

      exit when c_fees%notfound;
        l_fee_struct_tbl(i).fee_id                    := l_fee_id;
        l_fee_struct_tbl(i).fee_name                  := l_fee_name;
        l_fee_struct_tbl(i).fee_type                  := l_fee_type;
        l_fee_struct_tbl(i).fee_category              := l_fee_category;
	l_fee_struct_tbl(i).fee_description           := l_fee_description;
        l_fee_struct_tbl(i).fee_amount                := l_fee;
        l_fee_struct_tbl(i).fee_basis                 := l_fee_basis;
        l_fee_struct_tbl(i).fee_billing_option        := l_billing_option;
        l_fee_struct_tbl(i).fee_rate_type             := l_rate_type;
        l_fee_struct_tbl(i).number_grace_days         := l_number_grace_days;
        l_fee_struct_tbl(i).minimum_overdue_amount    := l_minimum_overdue_amount;
        l_fee_struct_tbl(i).fee_basis_rule            := l_fee_basis_rule;
        l_fee_struct_tbl(i).fee_from_installment      := l_begin_installment_number;
        l_fee_struct_tbl(i).fee_to_installment        := l_end_installment_number;
        l_fee_struct_tbl(i).fee_editable_flag         := l_fee_editable_flag;
        l_fee_struct_tbl(i).fee_waivable_flag         := l_fee_waivable_flag;
	l_fee_struct_tbl(i).phase			    := l_phase;
     end loop;
     close c_fees;

     return l_fee_struct_tbl;

     exception
        when no_data_found then
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - no fee structures found');
  end getFeeStructures;

/*=========================================================================
|| PUBLIC FUNCTION getDisbursementFeeStructures R12
||
|| DESCRIPTION
|| Overview: returns structure of fees for a given loan
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
||            p_installment  => installment number for the loan
||	     p_phase	  => the disbursement phase
||            p_disb_header_id =>
||	     p_fee_id	  =>
||
|| Return value:
||               table of fee structures needed to calculate disbursement fees
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                 Author            Description of Changes
|| 7/22/2005 8:40PM     raverma           Created
|| 15-Sep-2009     MBOLLI	Bug#8904071 -  Returned fee_description along with other column values
 *=======================================================================*/
function getDisbursementFeeStructures(p_loan_id        in number
							  ,p_installment_no in number
							  ,p_phase in varchar2
							  ,p_disb_header_id in number
							  ,p_fee_id         in number) return LNS_FEE_ENGINE.FEE_STRUCTURE_TBL
   is

      l_fee_id                     number;
      l_fee_name               varchar2(50);
      l_fee_description        varchar(250);
      l_fee_type                 varchar2(30);
      l_fee_category           varchar2(30);
      l_fee                         number;
      l_fee_basis                varchar2(30);
      l_billing_option           varchar2(30);
      l_rate_type                varchar2(30);
      i                               number := 0;
      l_fee_struct_tbl          LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
      l_api_name               varchar2(50);
      l_begin_installment_number  number;
      l_end_installment_number    number;
      l_disbursement_date         date;
      l_disbursement_amount       number;
      l_disb_header_id            number;
      l_phase			varchar2(30);

      cursor c_fees(p_loan_id number, p_installment_no number, c_phase varchar2
			            	, p_disb_header_id number, p_fee_id number) IS
      SELECT fees.fee_id
            ,fees.fee_name
	    ,fees.fee_description
            ,fees.fee_type
            ,fees.fee_category
            ,decode(fees.rate_type, 'FIXED', nvl(Assgn.fee,fees.fee), 'VARIABLE', nvl(Assgn.fee,fees.fee)/100)
            ,fees.fee_basis
            ,assgn.billing_option
            ,fees.rate_type
	    ,nvl(assgn.begin_installment_number,0)
	    ,nvl(assgn.end_installment_number,0)
	    ,dh.disb_header_id
	    ,dh.target_date
	    ,dh.header_amount
	    ,nvl(assgn.phase, 'TERM')
       from lns_fee_assignments assgn
           ,lns_fees_all fees
	   ,lns_disb_headers dh
       where dh.loan_id = nvl(p_loan_id, dh.loan_id)
	 and dh.disb_header_id = nvl(p_disb_header_id, dh.disb_header_id)
	 and fees.fee_id = nvl(p_fee_id, fees.fee_id)
         and assgn.fee_id = fees.fee_id
	 and assgn.disb_header_id = dh.disb_header_id
         and nvl(trunc(assgn.end_date_active), trunc(sysdate) + 1) >= trunc(sysdate)
         and nvl(trunc(assgn.start_date_active), trunc(sysdate) - 1) <= trunc(sysdate)
	 and fees.fee_category = 'EVENT'
	 and fees.fee_type = 'EVENT_FUNDING'
	 and assgn.begin_installment_number <= nvl(p_installment_no, assgn.begin_installment_number)
	 and assgn.end_installment_number   >= nvl(p_installment_no, assgn.end_installment_number)
	 and nvl(assgn.phase, 'TERM')  = c_phase;

  begin
     l_api_name                  := 'getDisbursementFeeStructures';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment_no ' || p_installment_no);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase ' || p_phase);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id ' || p_loan_id);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_disb_header_id ' || p_disb_header_id);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_fee_id ' || p_fee_id);

     l_phase := nvl(p_phase, 'TERM');


     open c_fees(p_loan_id, p_installment_no, l_phase, p_disb_header_id, p_fee_id);
     LOOP
        i := i + 1;
      fetch c_fees into
         l_fee_id
        ,l_fee_name
	,l_fee_description
        ,l_fee_type
        ,l_fee_category
        ,l_fee
        ,l_fee_basis
        ,l_billing_option
        ,l_rate_type
	,l_begin_installment_number
	,l_end_installment_number
	,l_disb_header_id
	,l_disbursement_date
	,l_disbursement_amount
	,l_phase;
      exit when c_fees%notfound;
        l_fee_struct_tbl(i).fee_id                        := l_fee_id;
        l_fee_struct_tbl(i).fee_name                  := l_fee_name;
	l_fee_struct_tbl(i).fee_description           :=l_fee_description;
        l_fee_struct_tbl(i).fee_type                    := l_fee_type;
        l_fee_struct_tbl(i).fee_category              := l_fee_category;
        l_fee_struct_tbl(i).fee_amount               := l_fee;
        l_fee_struct_tbl(i).fee_basis                   := l_fee_basis;
        l_fee_struct_tbl(i).fee_billing_option        := l_billing_option;
        l_fee_struct_tbl(i).fee_rate_type             := l_rate_type;
        l_fee_struct_tbl(i).fee_from_installment   := l_begin_installment_number;
        l_fee_struct_tbl(i).fee_to_installment       := l_end_installment_number;
	l_fee_struct_tbl(i).disb_header_id            := l_disb_header_id;
	l_fee_struct_tbl(i).disbursement_date      := l_disbursement_date;
	l_fee_struct_tbl(i).disbursement_amount  := l_disbursement_amount;
	l_fee_struct_tbl(i).phase			    := l_phase;
     end loop;
     close c_fees;

     return l_fee_struct_tbl;

     exception
        when no_data_found then
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - no fee structures found');
  end getDisbursementFeeStructures;


/*=========================================================================
|| PUBLIC PROCEDURE calculateFee  ----- R12
||
|| DESCRIPTION
|| Overview: this will calculate amount for a single fee for fee assignment page
||
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fee_id = fee to calculate
||            p_disb_header_id = disbursement to calculate for
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 7/29/2005 8:40PM     raverma           Created
||
 *=======================================================================*/
function calculateFee(p_fee_id         in number
			,p_disb_header_id in number
			,p_loan_id        in number)  return number
is

	-- fee basis for originalLoanAmount
	   cursor c_origLoanAmt(p_loan_id number) is
	   select  requested_amount, nvl(current_phase, 'TERM')
	   from  lns_loan_headers_all
	   where loan_id = p_loan_id;

	cursor c_disbAmount(p_disb_header_id number) is
	 	select header_amount
	 	from lns_disb_headers
	 	where disb_header_id = p_disb_header_id;

	cursor c_from_installment(c_fee_id number, c_disb_header_id number, c_phase varchar2) is
    		select nvl(BEGIN_INSTALLMENT_NUMBER,0)
      		from lns_fee_assignments
     		where fee_id = c_fee_id
		and disb_header_id = c_disb_header_id
		and nvl(phase, 'TERM') = c_phase;

	l_original_loan_amount  number;
	l_orig_fee_structures   LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    	l_fee_calc_tbl          LNS_FEE_ENGINE.FEE_CALC_TBL;
	l_fee_basis_tbl         LNS_FEE_ENGINE.FEE_BASIS_TBL;
	l_api_name              varchar2(25);
	l_return_status         VARCHAR2(1);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(32767);
	l_amount                number;
	l_disb_amount        number;
	l_phase		     VARCHAR2(30);
	l_installment	     NUMBER;

begin

	l_amount := 0;
	l_api_name := 'calculateFee';
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_fee_id     ' || p_fee_id);
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_disb_header_id ' || p_disb_header_id  );
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculating ' || p_loan_id);

	open c_origLoanAmt(p_loan_id);
	fetch c_origLoanAmt into l_original_loan_amount, l_phase;
	close c_origLoanAmt;

	if p_disb_header_id is null then

		l_amount := calculateFee(p_fee_id  => p_fee_id
						     ,p_loan_id => p_loan_id
						     ,p_phase  => l_phase);

	elsif p_disb_header_id is not null then

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting DIsb fee structures');
		l_orig_fee_structures := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => null
												      ,p_installment_no => null
									      -- Bug#9255294, Change after adding new column phase in disbHdr table
												      ,p_phase         =>  l_phase
												      ,p_disb_header_id => p_disb_header_id
												      ,p_fee_id         => p_fee_id);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - struct count is ' || l_orig_fee_structures.count);

		l_fee_basis_tbl(1).fee_basis_name   := 'ORIG_LOAN';
		l_fee_basis_tbl(1).fee_basis_amount := l_original_loan_amount;
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - orig_loan ' || l_original_loan_amount);

		IF l_orig_fee_structures.count = 0 THEN
			-- this fee has not yet been assigned to the loan, we need to get the fee structure from LNS_FEES, NOT
			--  FROM LNS_FEE_ASSIGNMENTS
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee is unassigned ');
			l_orig_fee_structures := getFeeStructures(p_fee_id => p_fee_id);
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - structs ' || l_orig_fee_structures.count);

			l_installment := l_orig_fee_structures(1).fee_from_installment;

			open c_disbAmount(p_disb_header_id);
			fetch c_disbAmount into l_disb_amount;
			close c_disbAmount;

			l_fee_basis_tbl(2).fee_basis_name   := 'IND_DISB_AMT';
			l_fee_basis_tbl(2).fee_basis_amount := l_disb_amount;
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - disb amount ' || l_disb_amount);
		ELSE
			l_fee_basis_tbl(2).fee_basis_name   := 'IND_DISB_AMT';
			l_fee_basis_tbl(2).fee_basis_amount := l_orig_fee_structures(1).DISBURSEMENT_AMOUNT;
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - disb amount ' || l_orig_fee_structures(1).DISBURSEMENT_AMOUNT);

			begin
				open c_from_installment(p_fee_id, p_disb_header_id, l_phase);
				fetch c_from_installment into l_installment;
				close c_from_installment;
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_installment ' || l_installment);
			exception
				when no_data_found then
				l_installment := 0;
			end;

		END IF;


		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculating fees');
		calculateFees(p_loan_id         => p_loan_id
				,p_fee_basis_tbl    => l_fee_basis_tbl
				,p_installment        => l_installment
				,p_fee_structures   => l_orig_fee_structures
				,x_fees_tbl            => l_fee_calc_tbl
				,x_return_status    => l_return_status
				,x_msg_count       => l_msg_count
				,x_msg_data         => l_msg_data);
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fees count is ' || l_fee_calc_tbl.count);
		for k in 1..l_fee_calc_tbl.count
		loop
			l_amount := l_amount + l_fee_calc_tbl(k).FEE_AMOUNT;
		end loop;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee total is ' || l_amount);

	 end if;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee total is ' || l_amount);
	 return l_amount;

	 exception
	 	when others then
			 return l_amount;

end calculateFee;


/*=========================================================================
|| PUBLIC PROCEDURE calculateFee  ----- LNS.B
||
|| DESCRIPTION
|| Overview: this will calculate amount for a single fee for fee assignment page
||           fee MUST be assigned to the loan
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fee_id = fee to calculate
||            p_loan_id = loan to calculate for
||            p_phase  = phase of the fee
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 1/10/2005 8:40PM     raverma           Created
||
 *=======================================================================*/
 function calculateFee(p_fee_id   IN NUMBER
                      ,p_loan_id            IN NUMBER
		      ,p_phase		IN VARCHAR2) return number
is
    l_api_name           varchar2(25);
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(32767);
    l_calc_fee            number;
    i                          number;
    l_fee_calc_tbl       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl      LNS_FEE_ENGINE.FEE_BASIS_TBL;
    l_loan_details       LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_fee_structures    LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_installment         Number;
    l_phase	      	       varchar2(30);

    cursor c_from_installment(c_fee_id number, c_loan_id number, c_phase varchar2) is
    select nvl(BEGIN_INSTALLMENT_NUMBER,0)
      from lns_fee_assignments
     where fee_id = c_fee_id
       and loan_id = c_loan_id
       and nvl(phase, 'TERM') = c_phase;

begin

     l_calc_fee := 0;

     l_api_name := 'calculateFee';

     l_phase := nvl(p_phase, 'TERM');
     -- compute the installment based on p_fee_assignment_id
     l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                        ,p_fee_category => null
                                                        ,p_fee_type     => null
                                                        ,p_installment  => null
							,p_phase	      => l_phase
                                                        ,p_fee_id       => p_fee_id);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - structs ' || l_fee_structures.count);

     if l_fee_structures.count = 0 then
        -- this fee has not yet been assigned to the loan, we need to get the fee structure from LNS_FEES, NOT LNS_FEE_ASSIGNMENTS
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee is unassigned ');
        l_fee_structures := getFeeStructures(p_fee_id => p_fee_id);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - structs ' || l_fee_structures.count);
        l_installment := l_fee_structures(1).fee_from_installment;
     else
         -- the fee has been assigned to the loan, get the fee_installment from the assignments table

         begin
             open c_from_installment(p_fee_id, p_loan_id, l_phase);
             fetch c_from_installment into l_installment;
             close c_from_installment;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_installment ' || l_installment);
         exception
            when
                no_data_found then
                l_installment := 0;
         end;
     end if;

     -- build the fee bases
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting details');
     l_loan_details := lns_financials.getLoanDetails(p_loan_id,  'ORIGINAL', l_phase);

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_installment ' || l_installment);

     l_fee_basis_tbl(1).fee_basis_name   := 'ORIG_LOAN';
     -- Bug#6830765 - Commented this as for direct loan, the funded_amount is '0' before Active
     -- l_fee_basis_tbl(1).fee_basis_amount := l_loan_details.funded_amount;
     l_fee_basis_tbl(1).fee_basis_amount := l_loan_details.requested_amount;
     l_fee_basis_tbl(2).fee_basis_name   := 'PREPAYMENT_AMOUNT';
     l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.remaining_balance;
     l_fee_basis_tbl(3).fee_basis_name   := 'TOTAL_BAL';
     l_fee_basis_tbl(3).fee_basis_amount := l_loan_details.remaining_balance;
     l_fee_basis_tbl(4).fee_basis_name   := 'CURR_BAL';
     l_fee_basis_tbl(4).fee_basis_amount := 0;
     l_fee_basis_tbl(5).fee_basis_name   := 'OVERDUE_PRIN';
     l_fee_basis_tbl(5).fee_basis_amount := 0;
     l_fee_basis_tbl(6).fee_basis_name   := 'OVERDUE_PRIN_INT';
     l_fee_basis_tbl(6).fee_basis_amount := 0;
     l_fee_basis_tbl(7).fee_basis_name   := 'IND_DISB_AMT';
     l_fee_basis_tbl(7).fee_basis_amount := l_loan_details.funded_amount;
     l_fee_basis_tbl(8).fee_basis_name   := 'TOTAL_DISB_AMT';
     l_fee_basis_tbl(8).fee_basis_amount := l_loan_details.funded_amount;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculating fees');
     calculateFees(p_loan_id          => p_loan_id
                  ,p_fee_basis_tbl    => l_fee_basis_tbl
                  ,p_installment      => l_installment
                  ,p_fee_structures   => l_fee_structures
                  ,x_fees_tbl         => l_fee_calc_tbl
                  ,x_return_status    => l_return_status
                  ,x_msg_count        => l_msg_count
                  ,x_msg_data         => l_msg_data);

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fees count is ' || l_fee_calc_tbl.count);
     for k in 1..l_fee_calc_tbl.count
     loop
         l_calc_fee := l_calc_fee + l_fee_calc_tbl(k).FEE_AMOUNT;
     end loop;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee total is ' || l_calc_fee);
     return l_calc_fee;

     exception
        when others then
	      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - ERROR ' || sqlerrm);
	      return -1;

end calculateFee;

/*=========================================================================
|| PUBLIC PROCEDURE calculateFees  ----- LNS.B
||
|| DESCRIPTION
|| Overview: this is main fee calculation engine
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fee_structures   => fee structuring for the loan
||            p_fee_basis_tbl    => fee bases
||            p_installment      => installment number
||
|| Return value:
||            x_fees_tbl   table of fees for a given installment
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/16/2004 8:40PM     raverma           Created
||
 *=======================================================================*/
 procedure calculateFees(p_loan_id          in  number
                        ,p_fee_basis_tbl    in  LNS_FEE_ENGINE.FEE_BASIS_TBL
                        ,p_installment      in  number
                        ,p_fee_structures   IN  LNS_FEE_ENGINE.FEE_STRUCTURE_TBL
                        ,x_fees_tbl         OUT nocopy LNS_FEE_ENGINE.FEE_CALC_TBL
                        ,x_return_status    out nocopy varchar2
                        ,x_msg_count        out nocopy number
                        ,x_msg_data         out nocopy varchar2)
is
    l_api_name           varchar2(25);
    l_basis_amount       number;
    l_total_fees         number;
    l_fees_tbl           lns_fee_engine.fee_calc_tbl;
    k                    number;
    l_fee                number;
    l_precision          number;
    l_intervals          number;

    cursor c_precision (p_loan_id number)
    is
    SELECT fndc.precision
      FROM lns_loan_headers_all lnh
          ,fnd_currencies fndc
     WHERE lnh.loan_id = p_loan_id
       and lnh.loan_currency = fndc.currency_code;

begin

  l_api_name           := 'calculateFees';
  l_total_fees         := 0;
  l_intervals          := 1;

  -- first figure out if fee applies to the current installment
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - # fee structures ' || p_fee_structures.count);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - # fee basis ' || p_fee_basis_tbl.count);

  open c_precision(p_loan_id);
  fetch c_precision into l_precision;
  close c_precision;

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - # fee precision ' || l_precision);

  for f in 1..p_fee_structures.count loop
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' -------- STRUCTURE ' || f);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - from inst ' ||  p_fee_structures(f).fee_from_installment  );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - to inst ' ||  p_fee_structures(f).fee_to_installment      );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - basis ' ||  p_fee_structures(f).fee_basis);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - billing option ' ||  p_fee_structures(f).fee_billing_option);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rate ' ||  p_fee_structures(f).fee_rate_type);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rate ' ||  p_fee_structures(f).phase);

      l_fee := 0;

      if p_installment >= p_fee_structures(f).fee_from_installment and
           p_installment <= p_fee_structures(f).fee_to_installment  then

           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fees ' || f || ' applies to this installment ');

           if p_fee_structures(f).fee_billing_option = 'EQUALLY' then
              l_intervals := p_fee_structures(f).fee_to_installment - p_fee_structures(f).fee_from_installment + 1;
           end if;

           if p_fee_structures(f).fee_rate_type = 'FIXED' then
              if p_installment = p_fee_structures(f).fee_to_installment then
               logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - amount is : ' || p_fee_structures(f).fee_amount);
               logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - raw: ' || p_fee_structures(f).fee_amount / l_intervals);
               logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - raw2 - ' || round((p_fee_structures(f).fee_amount / l_intervals),2) * (l_intervals - 1));
               l_fee := p_fee_structures(f).fee_amount - round((p_fee_structures(f).fee_amount / l_intervals),l_precision) * (l_intervals - 1);
           else
               l_fee := round(p_fee_structures(f).fee_amount / l_intervals, l_precision);
           end if;

           elsif p_fee_structures(f).fee_rate_type = 'VARIABLE' then
              begin
                  k := 0;
                  LOOP
                     k := k + 1;
                  --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee basis ' || p_fee_basis_tbl(k).fee_basis_name);
                  --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee basis amount ' || p_fee_basis_tbl(k).fee_basis_amount);
                  EXIT WHEN p_fee_basis_tbl(k).fee_basis_name = p_fee_structures(f).fee_basis;
                  END LOOP;
                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee basis ' || p_fee_basis_tbl(k).fee_basis_name);
                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee basis amount ' || p_fee_basis_tbl(k).fee_basis_amount);

                  l_basis_amount := p_fee_basis_tbl(k).fee_basis_amount;

                  if p_installment = p_fee_structures(f).fee_to_installment then
                      l_fee := (p_fee_structures(f).fee_amount * l_basis_amount) - round((p_fee_structures(f).fee_amount / l_intervals),l_precision) * (l_intervals - 1);
                  else
                      l_fee := round(p_fee_structures(f).fee_amount * l_basis_amount / l_intervals,l_precision) ;
                  end if;

              exception
                when no_data_found then
                    l_fee := -1;
                    --FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_CALC_ERROR');
                    --FND_MSG_PUB.ADD;
                    --RAISE FND_API.G_EXC_ERROR;
              end;
           end if;

      end if;
      --assign output table of fees for each fee structure
      l_fees_tbl(f).fee_id             := p_fee_structures(f).fee_id;
      l_fees_tbl(f).fee_name           := p_fee_structures(f).fee_name;
      l_fees_tbl(f).fee_amount         := round(l_fee, l_precision);
      l_fees_tbl(f).fee_installment    := p_installment;
      l_fees_tbl(f).phase		  := nvl(p_fee_structures(f).phase, 'TERM');
      -- Bug#8904071
      l_fees_tbl(f).fee_description    := p_fee_structures(f).fee_description;
      l_fees_tbl(f).fee_schedule_id    := -1; --assign this AFTER insert into fee_schedules
      l_fees_tbl(f).fee_waivable_flag  := 'N';
      l_fees_tbl(f).FEE_DELETABLE_FLAG := 'N'; --from getFeeStructures
      l_fees_tbl(f).FEE_EDITABLE_FLAG  := 'N'; --from getFeeStructures
      l_total_fees                     := l_total_fees + l_fees_tbl(f).fee_amount;
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount' || l_fee);

  end loop;

  x_fees_tbl := l_fees_tbl;
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculated fees: ' || l_total_fees);

end calculateFees;

/*=========================================================================
|| PUBLIC PROCEDURE getFeeSchedule
||
|| DESCRIPTION
|| Overview: this procedure will return a table of fees off of the fee
||           schedule for the given installment
||
|| THIS WILL BE CALLED BY MAIN AMORTIZATION FUNCTION TO RETURN ACTUAL FEES
||   TO BE BILLED ON A LOAN
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fee_structure_tbl => represents a table of fees
||            p_loan_id           => loan_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/1/2004 8:40PM     raverma           Created
||  7/29.2005           raverma           check for disb_header_id is null
||  02-Sep-2009    mbolli		Bug#8848018 - Added new field fee_billig_option
 *=======================================================================*/
 procedure getFeeSchedule(p_init_msg_list      in  varchar2
                         ,p_loan_id            in  number
                         ,p_installment_number in  number
			 ,p_disb_header_id     in  number
			 ,p_phase		    in varchar2
                         ,x_fees_tbl           OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                         ,x_return_status    out nocopy varchar2
                         ,x_msg_count       out nocopy number
                         ,x_msg_data         out nocopy varchar2)
is
    l_api_name          varchar2(25);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(32767);

    i                    number;
    l_fee_rec            FEE_CALC_REC;
    l_fee_schedule_id    number;
    l_fee_id             number;
    l_fee_amount         number;
    l_fee_name           varchar2(50);
    l_fee_installment    number;
    l_fee_description    varchar2(250);
    l_fee_waivable_flag  varchar2(1);
    l_fee_category       varchar2(30);
    l_fee_type           varchar2(30);
    l_fee_deletable_flag varchar2(1);
    l_fee_editable_flag  varchar2(1);
    l_fee_billing_option  varchar2(30);
    l_phase			 varchar2(30);

    -- unbilled fees on the schedule
    cursor c_fees(c_loan_id number, c_installment number, c_phase varchar2) is
    select sched.fee_schedule_id
          ,sched.fee_id
          ,sched.fee_amount - nvl(sched.waived_amount, 0)
          ,struct.fee_name
          ,struct.fee_category
          ,struct.fee_type
          ,sched.fee_installment
          ,struct.fee_description
          ,sched.fee_waivable_flag      -- should be struct right
          ,decode(struct.fee_category, 'MANUAL', 'Y', 'N')
          ,nvl(struct.fee_editable_flag, 'N')
	  ,struct.billing_option
	  ,sched.phase
      from lns_fee_schedules sched
          ,lns_fees struct
     where sched.loan_id = c_loan_id
       and sched.fee_id = struct.fee_id
       and fee_installment = c_installment
       and nvl(phase, 'TERM') = c_phase
       and active_flag = 'Y'
       and billed_flag = 'N' -- deduce this based on parent records
        -- Bug#6961250 commented below line as for disbFees, disb_header_id  is
        -- NOT NULL
			-- and disb_header_id is null
       and (not exists
          (select 'X'
             from lns_amortization_scheds am
                 ,lns_amortization_lines lines
            where lines.loan_id = c_loan_id
              and lines.fee_schedule_id = sched.fee_schedule_id
              and am.loan_id = lines.loan_id
              and NVL(am.reversed_flag, 'N') = 'N'
              and am.payment_number = c_installment)
            or exists
            (select 'X'
             from lns_amortization_scheds am
                 ,lns_amortization_lines lines
            where lines.loan_id = c_loan_id
              and lines.fee_schedule_id = sched.fee_schedule_id
              and am.loan_id = lines.loan_id
              and am.reversed_flag = 'Y'
              and am.payment_number = c_installment));

	-- for openPhase
	cursor c_feeSchedule(c_disb_header_id number, c_phase varchar2) is
    select sched.fee_id
          ,sched.fee_amount - nvl(sched.waived_amount, 0)
          ,struct.fee_name
          ,struct.fee_description
	  ,sched.phase
      from lns_fee_schedules sched
	     ,lns_fees_all struct
      where disb_header_id = c_disb_header_id
	    and sched.fee_id = struct.fee_id
	    and nvl(sched.phase, 'TERM') = c_phase;

 begin

   l_api_name           := 'getFeeSchedule';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT getFees;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here
   i := 0;

   	 l_phase := nvl(p_phase, 'TERM');

	 if p_disb_header_id is null then
	   OPEN c_fees(p_loan_id, p_installment_number, l_phase);
	   LOOP
	       i := i + 1;
	   FETCH c_fees INTO
	        l_fee_schedule_id
	       ,l_fee_id
	       ,l_fee_amount
	       ,l_fee_name
	       ,l_fee_category
	       ,l_fee_type
	       ,l_fee_installment
	       ,l_fee_description
	       ,l_fee_waivable_flag
	       ,l_fee_deletable_flag
	       ,l_fee_editable_flag
	       ,l_fee_billing_option
	       ,l_phase;
	   EXIT WHEN c_fees%NOTFOUND;

	           l_fee_rec.fee_schedule_id      := l_fee_schedule_id;
	           l_fee_rec.fee_id               := l_fee_id;
	           l_fee_rec.fee_amount           := l_fee_amount;
	           l_fee_rec.fee_name             := l_fee_name;
	           l_fee_rec.fee_category         := l_fee_category;
	           l_fee_rec.fee_type             := l_fee_type;
	           l_fee_rec.fee_installment      := l_fee_installment;
	           l_fee_rec.fee_description      := l_fee_description;
	           l_fee_rec.fee_waivable_flag    := l_fee_waivable_flag;
	           l_fee_rec.fee_deletable_flag   := l_fee_deletable_flag;
	           l_fee_rec.fee_editable_flag    := l_fee_editable_flag;
		   l_fee_rec.fee_billing_option    := l_fee_billing_option;
		   l_fee_rec.phase		      := l_phase;

	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee #: ' || i);
	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee schedule id: ' || l_fee_rec.fee_schedule_id);
	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee id: ' || l_fee_rec.fee_id);
	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount: ' || l_fee_rec.fee_amount);
	           x_fees_tbl(i) := l_fee_rec;
	   END LOOP;
	elsif p_disb_header_id is not null then
	   OPEN c_feeSchedule(p_disb_header_id, l_phase);
	   LOOP
	       i := i + 1;
	   FETCH c_feeSchedule INTO
	        l_fee_id
	       ,l_fee_amount
	       ,l_fee_name
	       --,l_fee_category
	       --,l_fee_type
	       --,l_fee_installment
	       ,l_fee_description
	       --,l_fee_waivable_flag
	       --,l_fee_deletable_flag
	       --,l_fee_editable_flag
	       ,l_phase;
	   EXIT WHEN c_feeSchedule%NOTFOUND;

	           --l_fee_rec.fee_schedule_id      := l_fee_schedule_id;
	           l_fee_rec.fee_id               := l_fee_id;
	           l_fee_rec.fee_amount           := l_fee_amount;
	           l_fee_rec.fee_name             := l_fee_name;
	           --l_fee_rec.fee_category         := l_fee_category;
	           --l_fee_rec.fee_type             := l_fee_type;
	           --l_fee_rec.fee_installment      := l_fee_installment;
	           l_fee_rec.fee_description      := l_fee_description;
	           --l_fee_rec.fee_waivable_flag    := l_fee_waivable_flag;
	           --l_fee_rec.fee_deletable_flag   := l_fee_deletable_flag;
	           --l_fee_rec.fee_editable_flag    := l_fee_editable_flag;
		   l_fee_rec.phase			  := l_phase;

	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee #: ' || i);
	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee schedule id: ' || l_fee_rec.fee_schedule_id);
	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee id: ' || l_fee_rec.fee_id);
	           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount: ' || l_fee_rec.fee_amount);
	           x_fees_tbl(i) := l_fee_rec;
	   END LOOP;
	 end if;

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getFees;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getFees;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getFees;
end getFeeSchedule;

/*=========================================================================
|| PUBLIC PROCEDURE getFeeDetails
||
|| DESCRIPTION
|| Overview: this procedure will return a table of fee details
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_installment   => fees for an installment
||            p_loan_id       => loan_id
||            p_fee_basis_tbl => needed if we are calculating virtual records
||
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 1/6/2005 8:40PM     raverma           Created
|| 1/19/2005           raverma           added in calls to display origination fees
||  02-Sep-2009    mbolli		Bug#8848018 - Added new field fee_billig_option
 *=======================================================================*/
procedure getFeeDetails(p_init_msg_list  in  varchar2
                       ,p_loan_id        in  number
                       ,p_installment    in  number
                       ,p_fee_basis_tbl  in  LNS_FEE_ENGINE.FEE_BASIS_TBL
                       ,p_based_on_terms in  varchar2
		       ,p_phase          in  varchar2
                       ,x_fees_tbl       out nocopy LNS_FEE_ENGINE.FEE_CALC_TBL
                       ,x_return_status  out nocopy varchar2
                       ,x_msg_count      out nocopy number
                       ,x_msg_data       out nocopy varchar2)

is
     l_api_name              varchar2(25);
     l_return_status         VARCHAR2(1);
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(32767);
     iFeeCount               number;
     l_last_installment      number;
     l_loan_details          LNS_FINANCIALS.LOAN_DETAILS_REC;
     l_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL; --use for recurring
     l_orig_fee_structures   LNS_FEE_ENGINE.FEE_STRUCTURE_TBL; --use for origination
     l_conv_fee_structures	LNS_FEE_ENGINE.FEE_STRUCTURE_TBL; --use for conversion
     l_fund_fee_structures	LNS_FEE_ENGINE.FEE_STRUCTURE_TBL; --use for fundingFees
     l_fees_tbl              LNS_FEE_ENGINE.FEE_CALC_TBL;
     l_virtual_fees_tbl      LNS_FEE_ENGINE.FEE_CALC_TBL;
     l_virtual_fundFees_tbl      LNS_FEE_ENGINE.FEE_CALC_TBL;
     i				 number;
     l_recurFeesCnt      NUMBER;
     l_phase		 VARCHAR2(30);

		 -- for disbursement phase
        l_fee_basis_tbl         LNS_FEE_ENGINE.FEE_BASIS_TBL;
	l_payment_tbl           LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;

	-- conversion fees
	cursor c_conv_fees(p_loan_id number) is
		select fee.fee_description
			 ,fee.fee_name
			 ,ass.fee
			 ,fee.fee_category
			 ,fee.fee_type
			 ,ass.billing_option
			 ,nvl(ass.phase, 'TERM')
		from lns_fee_assignments ass
		       ,lns_fees_all fee
		where ass.loan_id = p_loan_id
		    and fee.fee_id = ass.fee_id
		    and ass.fee_type = 'EVENT_CONVERSION';

begin

   l_api_name           := 'getFeeDetails';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT getFeeDetails;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------

	 i := 0;
	-- Bug#8848018 - Changed the function last_payment_number_ext to .. _1
   select LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT_1(p_loan_id) + 1
     into l_last_installment
     from dual;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment is:    ' || p_installment);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_based_on_terms:    ' || p_based_on_terms);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee_basis passed is: ' || p_fee_basis_tbl.count);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase is:          ' || p_phase);
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - last installment is: ' || l_last_installment);

   	 l_phase := nvl(p_phase, 'TERM');

	 if l_phase = 'OPEN' then

	   --if  p_installment <= l_last_installment and p_based_on_terms = 'CURRENT' then
	   	 IF p_based_on_terms = 'CURRENT' THEN
			lns_fee_engine.getFeeSchedule(p_init_msg_list      => p_init_msg_list
						,p_loan_id                   => p_loan_id
						,p_installment_number => p_installment
						,p_disb_header_id     	  => null
						,p_phase			  => l_phase
						,x_fees_tbl           	  => l_fees_tbl
						,x_return_status      	  => l_return_status
						,x_msg_count          	  => l_msg_count
						,x_msg_data           	  => l_msg_data);

			if l_return_status <> FND_API.G_RET_STS_SUCCESS then
				FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_SCHEDULE_READ_ERROR');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			end if;

			iFeeCount := l_fees_tbl.count;
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Found OpenPhase  real fees ' || l_fees_tbl.count);


		 ELSE        -- we going by original amortization schedule
				-- get disbursement_ids for timePeriod
		    l_loan_Details := lns_financials.getLoanDetails(p_loan_id, p_based_on_terms, l_phase);

	          iFeeCount := 0;
	          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found iFeeCount fees ' || iFeeCount);
	          if p_installment <= 1 then
	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - checking origination fees' );
	              l_orig_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
	                                                                      ,p_fee_category => 'EVENT'
	                                                                      ,p_fee_type     => 'EVENT_ORIGINATION'
	                                                                      ,p_installment  => p_installment
									      ,p_phase	    => l_phase
	                                                                      ,p_fee_id       => null);
	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee structures ' || l_orig_fee_structures.count);

	              if l_orig_fee_structures.count > 0 then
	                  lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
	                                              ,p_installment      => p_installment
	                                              ,p_fee_basis_tbl    => p_fee_basis_tbl
	                                              ,p_fee_structures   => l_orig_fee_structures
	                                              ,x_fees_tbl         => l_virtual_fees_tbl
	                                              ,x_return_status    => l_return_status
	                                              ,x_msg_count        => l_msg_count
	                                              ,x_msg_data         => l_msg_data);

	                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - virtual orig fees ' || l_virtual_fees_tbl.count);
	                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - iFeeCount ' || iFeeCount);
	                  -- append virtual records to end of actual records
	                  for k in 1..l_virtual_fees_tbl.count loop
	                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - k ' || k);
	                      l_fees_tbl(iFeeCount + k) := l_virtual_fees_tbl(k);
	                      l_fees_tbl(iFeeCount + k).FEE_DESCRIPTION := l_orig_fee_structures(k).fee_description;
	                      l_fees_tbl(iFeeCount + k).FEE_CATEGORY    := l_orig_fee_structures(k).fee_category;
	                      l_fees_tbl(iFeeCount + k).FEE_TYPE        := l_orig_fee_structures(k).fee_type;
			      l_fees_tbl(iFeeCount + k).FEE_BILLING_OPTION    := l_orig_fee_structures(k).fee_billing_option;
	                  end loop;

	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - virtual FEES COUNT FINAL ' || l_fees_tbl.count);
	              end if;
	           end if;


		   iFeeCount := l_fees_tbl.count;

		    -- fetch all disbursement_ids for given period
		    l_fee_structures := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => p_loan_id
										,p_installment_no	=> p_installment
										,p_phase		=> l_phase
										,p_disb_header_id => null
										,p_fee_id         => null);

	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': fee structures count is ' || l_fee_structures.count);

	    	IF (l_fee_structures.count > 0) THEN
			-- calculate the fees one by one
			for j in 1..l_fee_structures.count
			loop
				-- get the fee basis
				-- get the total disbursed thru the target date of the fee
				logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': IND_DISB_AMOUNT ' || l_fee_structures(j).disbursement_amount);
				l_fee_basis_tbl(1).fee_basis_name   := 'IND_DISB_AMT';
				l_fee_basis_tbl(1).fee_basis_amount := l_fee_structures(j).disbursement_amount;
				l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
				l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.requested_amount;
				l_orig_fee_structures(1) := l_fee_structures(j);
				lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
						,p_installment      => p_installment
						,p_fee_basis_tbl    => l_fee_basis_tbl
						,p_fee_structures   => l_fee_structures
						,x_fees_tbl         => l_virtual_fees_tbl
						,x_return_status    => l_return_status
						,x_msg_count        => l_msg_count
						,x_msg_data         => l_msg_data);
				logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated Funding fees ' || l_virtual_fees_tbl.count);

			end loop;

			for k in 1..l_virtual_fees_tbl.count loop
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - k ' || k);
				l_fees_tbl(iFeeCount + k) := l_virtual_fees_tbl(k);
				l_fees_tbl(iFeeCount + k).FEE_DESCRIPTION := l_fee_structures(k).fee_description;
				l_fees_tbl(iFeeCount + k).FEE_CATEGORY    := l_fee_structures(k).fee_category;
				l_fees_tbl(iFeeCount + k).FEE_TYPE        := l_fee_structures(k).fee_type;
				l_fees_tbl(iFeeCount + k).FEE_BILLING_OPTION        := l_fee_structures(k).fee_billing_option;
			end loop;
		END IF;

	   END IF; -- p_based_on_terms for OPEN pahse

    elsif p_phase = 'TERM' then

	   -- this installment is actual installment on current amortization
	   if  p_installment <= l_last_installment and p_based_on_terms = 'CURRENT' then

	          lns_fee_engine.getFeeSchedule(p_init_msg_list      => p_init_msg_list
	                                       ,p_loan_id            => p_loan_id
	                                       ,p_installment_number => p_installment
					       ,p_disb_header_id     => null
					       ,p_phase		      => l_phase
	                                       ,x_fees_tbl           => l_fees_tbl
	                                       ,x_return_status      => l_return_status
	                                       ,x_msg_count          => l_msg_count
	                                       ,x_msg_data           => l_msg_data);

	          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	                FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_SCHEDULE_READ_ERROR');
	                FND_MSG_PUB.ADD;
	                RAISE FND_API.G_EXC_ERROR;
	          end if;

	          iFeeCount := l_fees_tbl.count;
	          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found real fees ' || l_fees_tbl.count);

		  l_recurFeesCnt := 0;
		  for schdCnt in 1..l_fees_tbl.count loop
			if (l_fees_tbl(schdCnt).fee_billing_option = 'RECUR') then
				l_recurFeesCnt := l_recurFeesCnt + 1;
			end if;
		  end loop;

		  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found recurring fees ' || l_recurFeesCnt);

		  if (l_recurFeesCnt <= 0) then

			-- get any recurring fees yet to be placed on the fee schedule
			l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
									,p_fee_category => 'RECUR'
									,p_fee_type     => null
									,p_installment  => p_installment
									,p_phase	      => l_phase
									,p_fee_id       => null);

			if l_fee_structures.count > 0 then
			lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
							,p_installment      => p_installment
							,p_fee_basis_tbl    => p_fee_basis_tbl
							,p_fee_structures   => l_fee_structures
							,x_fees_tbl         => l_virtual_fees_tbl
							,x_return_status    => l_return_status
							,x_msg_count        => l_msg_count
							,x_msg_data         => l_msg_data);

			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - virtual recurring fees ' || l_virtual_fees_tbl.count);
			-- append virtual records to end of actual records
			for k in 1..l_virtual_fees_tbl.count loop
				l_fees_tbl(iFeeCount + k) := l_virtual_fees_tbl(k);
				l_fees_tbl(iFeeCount + k).FEE_DESCRIPTION := l_fee_structures(k).fee_description;
				l_fees_tbl(iFeeCount + k).FEE_CATEGORY    := l_fee_structures(k).fee_category;
				l_fees_tbl(iFeeCount + k).FEE_TYPE        := l_fee_structures(k).fee_type;
				l_fees_tbl(iFeeCount + k).FEE_BILLING_OPTION        := l_fee_structures(k).fee_billing_option;
			end loop;
			end if;
		end if;  -- recurFeesCnt <= 0

	          iFeeCount := l_fees_tbl.count;

	      else  -- we going by original amortization schedule

	          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculating ALL virtual fees ');

		-- 08-02-05 raverma add conversion fees
		if (p_installment = 0  and l_phase = 'TERM')then
			open c_conv_fees(p_loan_id);
		        LOOP
				i := i + 1;
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - conv fee found  ' || i);
				FETCH c_conv_fees into
					  l_fees_tbl(i).fee_description
					 ,l_fees_tbl(i).fee_name
					 ,l_fees_tbl(i).fee_amount
					 ,l_fees_tbl(i).fee_category
					 ,l_fees_tbl(i).fee_type
				    		--l_fees_tbl(i).fee_schedule_id = -1;
					 ,l_fees_tbl(i).fee_billing_option
					 ,l_fees_tbl(i).phase;
				EXIT WHEN c_conv_fees%NOTFOUND;

			              -- append virtual records to end of actual records
			        iFeeCount := l_fees_tbl.count;
			END LOOP;
		end if;
	        -- get all recurring fees yet to be placed on the fee schedule
	        -- project amounts according to amortization schedule amounts
	        l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
	                                                             ,p_fee_category => 'RECUR'
	                                                             ,p_fee_type     => null
	                                                             ,p_installment  => p_installment
								     ,p_phase	   => l_phase
	                                                             ,p_fee_id       => null);
	        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee structures ' || l_fee_structures.count);

	          if l_fee_structures.count > 0 then
	              lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
	                                          ,p_installment        => p_installment
	                                          ,p_fee_basis_tbl    => p_fee_basis_tbl
	                                          ,p_fee_structures   => l_fee_structures
	                                          ,x_fees_tbl            => l_virtual_fees_tbl
	                                          ,x_return_status    => l_return_status
	                                          ,x_msg_count        => l_msg_count
	                                          ,x_msg_data         => l_msg_data);
	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found virtual recurring  fees ' || l_virtual_fees_tbl.count);
	              -- append virtual records to end of actual records
	              iFeeCount := l_fees_tbl.count;
	              for k in 1..l_virtual_fees_tbl.count loop
	                  l_fees_tbl(iFeeCount + k) := l_virtual_fees_tbl(k);
	                  l_fees_tbl(iFeeCount + k).FEE_DESCRIPTION := l_fee_structures(k).fee_description;
	                  l_fees_tbl(iFeeCount + k).FEE_CATEGORY    := l_fee_structures(k).fee_category;
	                  l_fees_tbl(iFeeCount + k).FEE_TYPE        := l_fee_structures(k).fee_type;
                          l_fees_tbl(iFeeCount + k).FEE_BILLING_OPTION    := l_fee_structures(k).fee_billing_option;
	              end loop;
	              l_virtual_fees_tbl.delete;
	          end if;

	          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - virtual FEES COUNT FINAL ' || l_fees_tbl.count);
	          iFeeCount := l_fees_tbl.count;
	          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found iFeeCount fees ' || iFeeCount);
	          if p_installment <= 1 then
	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - checking origination fees' );
	              l_orig_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
	                                                                      ,p_fee_category => 'EVENT'
	                                                                      ,p_fee_type     => 'EVENT_ORIGINATION'
	                                                                      ,p_installment  => p_installment
									      ,p_phase	    => l_phase
	                                                                      ,p_fee_id       => null);
	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee structures ' || l_orig_fee_structures.count);

	              if l_orig_fee_structures.count > 0 then
	                  lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
	                                              ,p_installment      => p_installment
	                                              ,p_fee_basis_tbl    => p_fee_basis_tbl
	                                              ,p_fee_structures   => l_orig_fee_structures
	                                              ,x_fees_tbl         => l_virtual_fees_tbl
	                                              ,x_return_status    => l_return_status
	                                              ,x_msg_count        => l_msg_count
	                                              ,x_msg_data         => l_msg_data);

	                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - virtual orig fees ' || l_virtual_fees_tbl.count);
	                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - iFeeCount ' || iFeeCount);
	                  -- append virtual records to end of actual records
	                  for k in 1..l_virtual_fees_tbl.count loop
	                  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - k ' || k);
	                      l_fees_tbl(iFeeCount + k) := l_virtual_fees_tbl(k);
	                      l_fees_tbl(iFeeCount + k).FEE_DESCRIPTION := l_orig_fee_structures(k).fee_description;
	                      l_fees_tbl(iFeeCount + k).FEE_CATEGORY    := l_orig_fee_structures(k).fee_category;
	                      l_fees_tbl(iFeeCount + k).FEE_TYPE        := l_orig_fee_structures(k).fee_type;
			      l_fees_tbl(iFeeCount + k).FEE_BILLING_OPTION    := l_orig_fee_structures(k).fee_billing_option;
	                  end loop;

	              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - virtual FEES COUNT FINAL ' || l_fees_tbl.count);
	              end if;
	           end if;

		    iFeeCount := l_fees_tbl.count;

		    -- fetch all disbursement_ids for given period
		    l_fund_fee_structures := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => p_loan_id
										,p_installment_no	=> p_installment
										,p_phase		=> l_phase
										,p_disb_header_id => null
										,p_fee_id         => null);

	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Term Disbfee structures count is ' || l_fund_fee_structures.count);

		 -- calculate the fees one by one
		IF (l_fund_fee_structures.count > 0) THEN
			l_loan_Details := lns_financials.getLoanDetails(p_loan_id, p_based_on_terms, l_phase);


			for j in 1..l_fund_fee_structures.count
			loop
				-- get the fee basis
				-- get the total disbursed thru the target date of the fee
				logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': IND_DISB_AMOUNT ' || l_fund_fee_structures(j).disbursement_amount);
				l_fee_basis_tbl(1).fee_basis_name   := 'IND_DISB_AMT';
				l_fee_basis_tbl(1).fee_basis_amount := l_fund_fee_structures(j).disbursement_amount;
				l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
				l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.requested_amount;

				lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
						,p_installment      => p_installment
						,p_fee_basis_tbl    => l_fee_basis_tbl
						,p_fee_structures   => l_fund_fee_structures
						,x_fees_tbl            => l_virtual_fundFees_tbl
						,x_return_status    => l_return_status
						,x_msg_count        => l_msg_count
						,x_msg_data         => l_msg_data);
				logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated Funding fees ' || l_virtual_fees_tbl.count);

			end loop;

			for k in 1..l_virtual_fundFees_tbl.count loop
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - k ' || k);
				l_fees_tbl(iFeeCount + k) := l_virtual_fundFees_tbl(k);
				l_fees_tbl(iFeeCount + k).FEE_DESCRIPTION := l_fund_fee_structures(k).fee_description;
				l_fees_tbl(iFeeCount + k).FEE_CATEGORY    := l_fund_fee_structures(k).fee_category;
				l_fees_tbl(iFeeCount + k).FEE_TYPE        	     := l_fund_fee_structures(k).fee_type;
				l_fees_tbl(iFeeCount + k).FEE_BILLING_OPTION        := l_fund_fee_structures(k).fee_billing_option;
			end loop;

		END IF;  --  l_fund_fee_structures.count >0

	   end if; --p_based_on_terms
	 end if; --p_phase

   x_fees_tbl := l_fees_tbl;

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getFeeDetails;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getFeeDetails;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getFeeDetails;

end getFeeDetails;


/*=========================================================================
|| PUBLIC PROCEDURE updateFeeSchedule
||
|| DESCRIPTION
|| Overview: this procedure will validate and update a table of fees to
||           the fee_schedule table
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fees_tbl => represents a table of fees
||            p_loan_id           => loan_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 1/7/2005 8:40PM     raverma           Created
||
 *=======================================================================*/
 procedure updateFeeSchedule(p_init_msg_list      in  varchar2
                            ,p_commit             in  varchar2
                            ,p_loan_id            in  number
                            ,p_fees_tbl           IN  LNS_FEE_ENGINE.FEE_CALC_TBL
                            ,x_return_status      out nocopy varchar2
                            ,x_msg_count          out nocopy number
                            ,x_msg_data           out nocopy varchar2)
 is
    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_fee_schedule_id               NUMBER;
    i                               number;

    cursor c_fee_schedule_id (p_loan_id number, p_fee_id number) is
    select fee_schedule_id
      from lns_fee_schedules
     where loan_id = p_loan_id
       and fee_id = p_fee_id
       and billed_flag = 'N'
       and active_flag = 'Y';

    l_precision          number;
    l_intervals          number;
		l_phase              varchar2(30);

     cursor c_phase(p_loan_id number) is
	select nvl(current_phase, 'TERM')
	from lns_loan_headers
	where loan_id = p_loan_id;

    cursor c_precision (p_loan_id number)
    is
    SELECT fndc.precision
      FROM lns_loan_headers lnh
          ,fnd_currencies fndc
     WHERE lnh.loan_id = p_loan_id
       and lnh.loan_currency = fndc.currency_code;
 begin

   l_api_name           := 'updateFeeSchedule';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT updateFeeSchedule;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here

   open c_precision(p_loan_id);
   fetch c_precision into l_precision;
   close c_precision;

   lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                  ,p_init_msg_list  =>  p_init_msg_list
                                  ,x_msg_count      =>  l_msg_count
                                  ,x_msg_data       =>  l_msg_data
                                  ,x_return_status  =>  l_return_status
                                  ,p_col_id         =>  p_loan_id
                                  ,p_col_name       =>  'LOAN_ID'
                                  ,p_table_name     =>  'LNS_LOAN_HEADERS_ALL');

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', p_loan_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
   end if;

   open  c_phase(p_loan_id);
   fetch c_phase into l_phase;
   close c_phase;

   l_loan_details := lns_financials.getLoanDetails(p_loan_id, 'CURRENT', l_phase);
   i := p_fees_tbl.count;
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found ' || i || 'fee structures');

   -- validate all structures
   for k in 1..i loop

       -- first validation as per june : do not add fees far into the future
       if p_fees_tbl(k).fee_installment > l_loan_details.LAST_INSTALLMENT_BILLED + 1 then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_INSTALLMENT_ERROR3');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;


       if p_fees_tbl(k).fee_installment < l_loan_details.LAST_INSTALLMENT_BILLED then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_INSTALLMENT_ERROR1');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;

       if p_fees_tbl(k).fee_installment > l_loan_details.NUMBER_INSTALLMENTS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_INSTALLMENT_ERROR2');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;

       if p_fees_tbl(k).FEE_AMOUNT is null or p_fees_tbl(k).FEE_AMOUNT < 0 then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_FEE_AMOUNT');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;

       if p_fees_tbl(k).FEE_ID is not null then
           lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                          ,p_init_msg_list  =>  p_init_msg_list
                                          ,x_msg_count      =>  l_msg_count
                                          ,x_msg_data       =>  l_msg_data
                                          ,x_return_status  =>  l_return_status
                                          ,p_col_id         =>  p_fees_tbl(k).FEE_ID
                                          ,p_col_name       =>  'FEE_ID'
                                          ,p_table_name     =>  'LNS_FEES');

           if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
                FND_MESSAGE.SET_TOKEN('PARAMETER', 'FEE_ID');
                FND_MESSAGE.SET_TOKEN('VALUE', p_fees_tbl(k).FEE_ID);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
           end if;

       end if;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Fee_schedule_id is '||p_fees_tbl(k).FEE_SCHEDULE_ID);

   if p_fees_tbl(k).FEE_SCHEDULE_ID is null then
     -- we have an origination fee
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'p_loan_id : '||p_loan_id||' and fee_id : '||p_fees_tbl(k).FEE_ID);
     open c_fee_schedule_id(p_loan_id, p_fees_tbl(k).FEE_ID);
     fetch c_fee_schedule_id into l_fee_schedule_id;
     close c_fee_schedule_id;

   else
     l_fee_schedule_id := p_fees_tbl(k).FEE_SCHEDULE_ID;

   end if;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Fee_schedule_id is '||p_fees_tbl(k).FEE_SCHEDULE_ID);

   -- fee structure has been validated write to the fee schedule
   LNS_FEE_SCHEDULES_PKG.UPDATE_ROW(P_FEE_SCHEDULE_ID       => l_fee_schedule_id
                                   ,P_FEE_ID                => p_fees_tbl(k).FEE_ID
                                   ,P_LOAN_ID               => p_loan_id
                                   ,P_FEE_AMOUNT            => round(p_fees_tbl(k).FEE_AMOUNT,l_precision)
                                   ,P_FEE_INSTALLMENT       => p_fees_tbl(k).FEE_INSTALLMENT
                                   ,P_FEE_DESCRIPTION       => p_fees_tbl(k).FEE_DESCRIPTION
                                   ,P_ACTIVE_FLAG           => p_fees_tbl(k).ACTIVE_FLAG --'Y'
                                   ,P_BILLED_FLAG           => p_fees_tbl(k).BILLED_FLAG --'N'
                                   ,P_FEE_WAIVABLE_FLAG     => p_fees_tbl(k).FEE_WAIVABLE_FLAG
                                   ,P_WAIVED_AMOUNT         => null
                                   ,P_LAST_UPDATED_BY       => lns_utility_pub.last_updated_by
                                   ,P_LAST_UPDATE_DATE      => lns_utility_pub.last_update_date
                                   ,P_LAST_UPDATE_LOGIN     => null
                                   ,P_PROGRAM_ID            => null
                                   ,P_REQUEST_ID            => null
                                   ,P_OBJECT_VERSION_NUMBER => 1
				   ,P_DISB_HEADER_ID        => p_fees_tbl(k).DISB_HEADER_ID
				   ,P_PHASE			    => p_fees_tbl(k).PHASE);
   end loop;
   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------

   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO updateFeeSchedule;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO updateFeeSchedule;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO updateFeeSchedule;

 end updateFeeSchedule;

/*=========================================================================
|| PUBLIC PROCEDURE writeFees
||
|| DESCRIPTION
|| Overview: this procedure will validate and write a table of fees to
||           the fee_schedule table
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fee_structure_tbl => represents a table of fees
||            p_loan_id           => loan_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author           Description of Changes
|| 12/1/2004 8:40PM     raverma           Created
|| 07/21/2005 					raverma           support OPEN phase
 *=======================================================================*/
 procedure writeFeeSchedule(p_init_msg_list      in  varchar2
                           ,p_commit             in  varchar2
                           ,p_loan_id            in  number
                           ,p_fees_tbl           IN OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                           ,x_return_status      out nocopy varchar2
                           ,x_msg_count          out nocopy number
                           ,x_msg_data           out nocopy varchar2)

 is
    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_fee_schedule_id               NUMBER;
    i                               	    number;
    l_phase 			     varchar2(30);

    cursor c_phase(p_loan_id number) is
        select nvl(current_phase, 'TERM')
	from lns_loan_headers_all
	where loan_id = p_loan_id;

 begin

   l_api_name           := 'writeFeeSchedule';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT writeFeeSchedule;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here
   lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                  ,p_init_msg_list  =>  p_init_msg_list
                                  ,x_msg_count      =>  l_msg_count
                                  ,x_msg_data       =>  l_msg_data
                                  ,x_return_status  =>  l_return_status
                                  ,p_col_id         =>  p_loan_id
                                  ,p_col_name       =>  'LOAN_ID'
                                  ,p_table_name     =>  'LNS_LOAN_HEADERS_ALL');

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', p_loan_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
   end if;

   open  c_phase(p_loan_id);
   fetch c_phase into l_phase;
   close c_phase;

   l_loan_details := lns_financials.getLoanDetails(p_loan_id, 'CURRENT', l_phase);
   i := p_fees_tbl.count;
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - found ' || i || 'fee structures');

   -- validate all structures
   for k in 1..i loop

			-- bypass this validation temporarily until more time for disbursement fees
	if p_fees_tbl(k).disb_header_id is null then
	       -- first validation as per june : do not add fees far into the future
	       if p_fees_tbl(k).fee_installment > l_loan_details.LAST_INSTALLMENT_BILLED + 1 then
	            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_INSTALLMENT_ERROR3');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	       end if;

	       if p_fees_tbl(k).fee_installment < l_loan_details.LAST_INSTALLMENT_BILLED then
	            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_INSTALLMENT_ERROR1');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	       end if;

	       if p_fees_tbl(k).fee_installment > l_loan_details.NUMBER_INSTALLMENTS then
	            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_INSTALLMENT_ERROR2');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	       end if;

	       if p_fees_tbl(k).FEE_AMOUNT is null or p_fees_tbl(k).FEE_AMOUNT <= 0 then
	            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_FEE_AMOUNT');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	       end if;

	       if p_fees_tbl(k).FEE_ID is not null then
	           lns_utility_pub.validate_any_id(p_api_version    =>  1.0
	                                          ,p_init_msg_list  =>  p_init_msg_list
	                                          ,x_msg_count      =>  l_msg_count
	                                          ,x_msg_data       =>  l_msg_data
	                                          ,x_return_status  =>  l_return_status
	                                          ,p_col_id         =>  p_fees_tbl(k).FEE_ID
	                                          ,p_col_name       =>  'FEE_ID'
	                                          ,p_table_name     =>  'LNS_FEES');

	           if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	                FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
	                FND_MESSAGE.SET_TOKEN('PARAMETER', 'FEE_ID');
	                FND_MESSAGE.SET_TOKEN('VALUE', p_fees_tbl(k).FEE_ID);
	                FND_MSG_PUB.ADD;
	                RAISE FND_API.G_EXC_ERROR;
	           end if;

	       end if;
	else
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - validation bypassed');
	end if; -- disb_header_id
							--
    select lns_fee_schedule_s.nextval
      into l_fee_schedule_id
      from dual;

   -- fee structure has been validated write to the fee schedule
   LNS_FEE_SCHEDULES_PKG.INSERT_ROW(X_FEE_SCHEDULE_ID       => l_fee_schedule_id
                                   ,P_FEE_ID                => p_fees_tbl(k).FEE_ID
                                   ,P_LOAN_ID               => p_loan_id
                                   ,P_FEE_AMOUNT            => round(p_fees_tbl(k).FEE_AMOUNT, l_loan_details.currency_precision)
                                   ,P_FEE_INSTALLMENT       => p_fees_tbl(k).FEE_INSTALLMENT
                                   ,P_FEE_DESCRIPTION       => p_fees_tbl(k).FEE_DESCRIPTION
                                   ,P_ACTIVE_FLAG           => 'Y'
                                   ,P_BILLED_FLAG           => 'N'
                                   ,P_FEE_WAIVABLE_FLAG     => p_fees_tbl(k).FEE_WAIVABLE_FLAG
                                   ,P_WAIVED_AMOUNT         => null
                                   ,P_CREATED_BY            => lns_utility_pub.created_by
                                   ,P_CREATION_DATE         => lns_utility_pub.creation_date
                                   ,P_LAST_UPDATED_BY       => lns_utility_pub.last_updated_by
                                   ,P_LAST_UPDATE_DATE      => lns_utility_pub.last_update_date
                                   ,P_LAST_UPDATE_LOGIN     => null
                                   ,P_PROGRAM_ID            => null
                                   ,P_REQUEST_ID            => null
                                   ,P_OBJECT_VERSION_NUMBER => 1
				   ,P_DISB_HEADER_ID        => p_fees_tbl(k).DISB_HEADER_ID
				   ,P_PHASE			=>	p_fees_tbl(k).PHASE);

    p_fees_tbl(k).fee_schedule_id := l_fee_schedule_id;

   end loop;

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------
   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO writeFeeSchedule;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO writeFeeSchedule;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO writeFeeSchedule;

 end writeFeeSchedule;

/*=========================================================================
|| PUBLIC procedure processFees
||
|| DESCRIPTION
|| Overview: this procedure will be the hook for the application to
||           get, calculate and write fees to the fee schedule
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_installment_number=> installment number to process
||            p_loan_header_rec   => header level infor about loan
||            p_amortization_rec  => installment level info about loan
||            p_fee_structures    => TABLE of Fee_Category/Fee_Types to process
||            p_loan_id           => loan_id
||            x_fees_tbl          => table of records inserted
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/1/2004 8:40PM     raverma           Created
 *=======================================================================*/
procedure processFees(p_init_msg_list      in  varchar2
                     ,p_commit            in  varchar2
                     ,p_loan_id             in  number
                     ,p_installment_number in  number
                     ,p_fee_basis_tbl    in  LNS_FEE_ENGINE.FEE_BASIS_TBL
                     ,p_fee_structures  in  LNS_FEE_ENGINE.FEE_STRUCTURE_TBL
                     ,x_fees_tbl           OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
                     ,x_return_status    out nocopy varchar2
                     ,x_msg_count       out nocopy number
                     ,x_msg_data         out nocopy varchar2)
is

    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_loan_details                  LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_fee_structures                LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fee_schedule_id               NUMBER;
    l_fee_calc_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_category                  varchar2(30);
    l_fee_type                      varchar2(30);
    i                               number;
    l_processed_fees                number;
    l_billed_flag 			VARCHAR2(1);
    writeCount			NUMBER;
    updateCount			NUMBER;
    l_phase				VARCHAR2(30);
    l_write_fee_calc_tbl	LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_update_fee_calc_tbl	LNS_FEE_ENGINE.FEE_CALC_TBL;

    cursor c_processed(c_loan_id number, c_installment number, c_category varchar2, c_type varchar2, c_phase varchar2) is
    select nvl(sum(fee_amount), 0)
      from lns_fee_schedules sched
           ,lns_fees         fees
     where sched.loan_id = c_loan_id
       and sched.fee_id = fees.fee_id
       and sched.fee_installment = c_installment
       and sched.active_flag = 'Y'
       and sched.billed_flag = 'Y' -- deduce this based on parent records
       and fees.fee_category = c_category
       and fees.fee_type = c_type
       and nvl(sched.phase, 'TERM')  = c_phase
       and (exists
           (select 'X'
             from lns_amortization_scheds am
                 ,lns_amortization_lines lines
            where am.loan_id = c_loan_id
              and am.amortization_schedule_id = lines.amortization_schedule_id
              and lines.fee_schedule_id = sched.fee_schedule_id
              and NVL(am.reversed_flag, 'N') = 'N'
              and am.payment_number = c_installment));
 begin

   l_api_name           := 'processFees';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT processFees;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_processed_fees:= 0;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here
    /* encapsulated API
    1. getFeeStructures for a particular event(s)
    2. calculate for installment
    3. write to schedule
    */
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fees super structures to process ' || p_fee_structures.count);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan id ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - installment ' || p_installment_number);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fees basis count ' || p_fee_basis_tbl.count);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - firstFee phase is ' || p_fee_structures(1).phase);

    open c_processed(p_loan_id, p_installment_number, p_fee_structures(1).fee_category, p_fee_structures(1).fee_type, p_fee_structures(1).phase);
    fetch c_processed into l_processed_fees;
    close c_processed;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fees already processed ' || l_processed_fees);

    if l_processed_fees = 0 then
        for i in 1..p_fee_structures.count loop

            l_fee_category := p_fee_structures(i).fee_category;
            l_fee_type       := p_fee_structures(i).fee_type;
	    l_phase		  := nvl(p_fee_structures(i).phase, 'TERM');

            if p_fee_structures(i).fee_category is null AND p_fee_structures(i).fee_type is null then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_CAT_TYPE_MISSING');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            end if;

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee category ' || l_fee_category);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee type ' || l_fee_type);
	    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - phase ' || l_phase);

            l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                               ,p_fee_category => l_fee_category
                                                               ,p_fee_type     => l_fee_type
                                                               ,p_installment  => p_installment_number
							       ,p_phase	     => l_phase
                                                               ,p_fee_id       => null);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee structures count is ' || l_fee_structures.count);

            lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                        ,p_fee_basis_tbl    => p_fee_basis_tbl
                                        ,p_installment      => p_installment_number
                                        ,p_fee_structures   => l_fee_structures
                                        ,x_fees_tbl         => l_fee_calc_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
             if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_CALCULATION_FAILURE');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
             end if;

	    --  Bug#8830789 - To restrict the insertion of duplicate feeSchedule record for the same FeeId and installment of a loan.
	    --  Delete the existed record and insert the new record
	    --  Note:- Manual Fee doesn't be scheduled so no ManualFee records exist in FeeSchedule table.

	    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee calc table count is ' || l_fee_calc_tbl.count);
	    writeCount := 0;
	    updateCount := 0;

	    FOR f in 1..l_fee_calc_tbl.count LOOP
	    	l_fee_schedule_id := NULL;

		BEGIN
			SELECT  fee_schedule_id, billed_flag INTO l_fee_schedule_id, l_billed_flag
			FROM lns_fee_schedules
			WHERE loan_id = p_loan_id
			AND   fee_id = l_fee_calc_tbl(f).fee_id
			AND   fee_installment = l_fee_calc_tbl(f).fee_installment
			AND   nvl(phase, 'TERM')  = l_fee_calc_tbl(f).phase
			AND   active_flag = 'Y';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - No records in feeShcd table for ' ||l_fee_calc_tbl(f).FEE_ID||' at installment  '|| l_fee_calc_tbl(f).fee_installment);
				l_fee_schedule_id := NULL;
		END;

		IF  l_fee_schedule_id IS NULL THEN
			-- Insert the FeeSchedule Record

			logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Inserting calculated fee with fee_id as ' ||l_fee_calc_tbl(f).FEE_ID);
			writeCount := writeCount + 1;
			l_write_fee_calc_tbl(writeCount) := l_fee_calc_tbl(f);

		ELSE
			-- Update the existed FeeSchedule record

			IF  l_billed_flag = 'Y' THEN
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' -The feeSchd '||l_fee_schedule_id||' is already billed. So dont update the record' );
			ELSE
				logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Updating calculated fee for fee_schedule_id '||l_fee_schedule_id);
				updateCount := updateCount + 1;
				l_update_fee_calc_tbl(updateCount) := l_fee_calc_tbl(f);
				l_update_fee_calc_tbl(updateCount).FEE_SCHEDULE_ID := l_fee_schedule_id;
			END IF;
		END IF;

		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Total No of New Records are '||writeCount );
		logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Total No of Updatable Records are '||updateCount );

		IF (writeCount > 0) THEN
			lns_fee_engine.writeFeeSchedule(p_init_msg_list      => p_init_msg_list
						,p_commit             => p_commit
						,p_loan_id            => p_loan_id
						,p_fees_tbl           => l_write_fee_calc_tbl
						,x_return_status      => l_return_status
						,x_msg_count          => l_msg_count
						,x_msg_data           => l_msg_data);
			if l_return_status <> FND_API.G_RET_STS_SUCCESS then
				FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_WRITE_FAILURE');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			end if;

		END IF;

		IF (updateCount > 0) THEN
			lns_fee_engine.updateFeeSchedule(p_init_msg_list      => p_init_msg_list
							,p_commit             => p_commit
							,p_loan_id            => p_loan_id
							,p_fees_tbl           => l_update_fee_calc_tbl
							,x_return_status      => l_return_status
							,x_msg_count          => l_msg_count
							,x_msg_data           => l_msg_data);
			if l_return_status <> FND_API.G_RET_STS_SUCCESS then
				FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_UPDATE_FAILURE');
				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			end if;
		END IF;
	   END LOOP;
        end loop;
   end if;

   for k in 1..l_fee_calc_tbl.count loop
         x_fees_tbl(k) := l_fee_calc_tbl(k);
   end loop;

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------

   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processFees;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processFees;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processFees;

end processFees;

/*=========================================================================
|| PUBLIC PROCEDURE waiveFee
||
|| DESCRIPTION
|| Overview: this procedure will waive a fee
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id           => loan_id
||            p_fee_schedule_id   => pk
||            p_waive_amount      => amount to be waived
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/1/2004 8:40PM     raverma           Created
||
 *=======================================================================*/
procedure waiveFee(p_init_msg_list   in varchar2
                  ,p_commit          in varchar2
                  ,p_loan_id         in number
                  ,p_fee_schedule_id in number
                  ,p_waive_amount    in number
                  ,x_return_status   out nocopy varchar2
                  ,x_msg_count       out nocopy number
                  ,x_msg_data        out nocopy varchar2)
is
    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_fee_amount_remaining          NUMBER;
    l_waived_amount                 NUMBER; --prior waived amount

    -- so the only rule i can think of is the
    -- waived_amount cannot be > fee_amount less any previously waived amount
    cursor c_fee_waive_amount(c_fee_schedule_id number) is
    select sched.fee_amount - nvl(sched.waived_amount, 0) amount_remaining
          ,nvl(sched.waived_amount, 0)                    previously_waived
      from lns_fee_schedules sched
     where sched.loan_id = p_loan_id
       and sched.fee_schedule_id = c_fee_schedule_id
       and sched.fee_waivable_flag = 'Y'
       and sched.active_flag = 'Y'
       and sched.billed_flag = 'N';

begin

   l_api_name           := 'waiveFee';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT waiveFee;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                  ,p_init_msg_list  =>  'T'
                                  ,x_msg_count      =>  l_msg_count
                                  ,x_msg_data       =>  l_msg_data
                                  ,x_return_status  =>  l_return_status
                                  ,p_col_id         =>  p_loan_id
                                  ,p_col_name       =>  'LOAN_ID'
                                  ,p_table_name     =>  'LNS_LOAN_HEADERS_ALL');

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', p_loan_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
   end if;

   lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                  ,p_init_msg_list  =>  'T'
                                  ,x_msg_count      =>  l_msg_count
                                  ,x_msg_data       =>  l_msg_data
                                  ,x_return_status  =>  l_return_status
                                  ,p_col_id         =>  p_fee_schedule_id
                                  ,p_col_name       =>  'FEE_SCHEDULE_ID'
                                  ,p_table_name     =>  'LNS_FEE_SCHEDULES');

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'FEE_SCHEDULE_ID');
        FND_MESSAGE.SET_TOKEN('VALUE', p_fee_schedule_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
   end if;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - amount to waive ' || p_waive_amount);

   if p_waive_amount is null then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_WAIVE_AMOUNT_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
   else
      open  c_fee_waive_amount(p_fee_schedule_id);
      fetch c_fee_waive_amount into l_fee_amount_remaining, l_waived_amount;
      close c_fee_waive_amount;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - amount remain ' || l_fee_amount_remaining);
      if p_waive_amount > l_fee_amount_remaining or p_waive_amount < 0 then
           FND_MESSAGE.SET_NAME('LNS', 'LNS_WAIVE_AMOUNT_INVALID');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
      end if;

      -- fee is valid  and waive amount is valid. update the fee schedule
      -- check on updating object_version_number
      lns_fee_schedules_pkg.update_row(P_FEE_SCHEDULE_ID       => p_fee_schedule_id
                                      ,P_FEE_ID                => null
                                      ,P_LOAN_ID               => p_loan_id
                                      ,P_FEE_AMOUNT            => null
                                      ,P_FEE_INSTALLMENT       => null
                                      ,P_FEE_DESCRIPTION       => null
                                      ,P_ACTIVE_FLAG           => null
                                      ,P_BILLED_FLAG           => null
                                      ,P_FEE_WAIVABLE_FLAG     => null
                                      ,P_WAIVED_AMOUNT         => p_waive_amount + l_waived_amount
                                      ,P_LAST_UPDATED_BY       => lns_utility_pub.last_updated_by
                                      ,P_LAST_UPDATE_DATE      => lns_utility_pub.last_update_date
                                      ,P_LAST_UPDATE_LOGIN     => lns_utility_pub.last_update_login
                                      ,P_PROGRAM_ID            => null
                                      ,P_REQUEST_ID            => null
                                      ,P_OBJECT_VERSION_NUMBER => null
				      ,P_DISB_HEADER_ID     => null
				      ,P_PHASE			    => null);


   end if;
   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------

   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO waiveFee;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO waiveFee;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO waiveFee;

end waiveFee;

/*=========================================================================
||
|| PUBLIC PROCEDURE getFeesTotal
||
|| DESCRIPTION
|| Overview: this procedure will get the sum of fees for a given loan
||            for a given fee category/type , billed flag and waived flag
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id           => loan_id
||
|| Return value:
||               sum of fees for a loan
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/16/2004 8:40PM     raverma           Created
||
 *=======================================================================*/
function getFeesTotal(p_loan_id            in  number
                     ,p_fee_category       in  varchar2
                     ,p_fee_type           in  varchar2
                     ,p_billed_flag        in  varchar2
                     ,p_waived_flag        in  varchar2) return number
is

    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    vPLSQL                          varchar2(1000);
    Type refCur is ref cursor;
    sql_Cur                         refCur;

    l_total                         number;

  begin
    l_api_name                      := 'getFeesTotal';

     vPLSQL := 'SELECT decode(:p_waived_flag, ''Y'', nvl(sum(sched.waived_amount),0), nvl(sum(sched.fee_amount) - sum(sched.waived_amount),0))' ||
               ' from lns_fee_schedules sched             ' ||
               --'     ,lns_fee_assignments assign         ' ||
               --' where assgn.fee_id = sched.fee_id        ' ||
               ' Where sched.loan_id = :p_loan_id           ' ||
               ' and sched.billed_flag = :p_billed_flag   ' ||
               ' and sched.active_flag = ''Y''            ';

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee_category ' || p_fee_category);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee_tpye ' || p_fee_type);
     if p_fee_category is not null then
        vPLSQL := vPLSQL || ' AND fees.fee_category = ''' || p_fee_category || '''';
     end if;

     if p_fee_type is not null then
        vPLSQL := vPLSQL || ' AND fees.fee_type = ''' || p_fee_type || '''';
     end if;

     /*
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - include p_memo_fees ' || p_memo_fees);
     if p_memo_fees = 'Y' then
        vPLSQL := vPLSQL || ' AND fees.fee_category = ''MEMO''';
     else
        vPLSQL := vPLSQL || ' AND fees.fee_category <> ''MEMO''';
     end if;
      */
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - sql ' || vPLSQL);
     open sql_cur for
            vPLSQL
        using p_waived_flag, p_loan_id, p_billed_flag;
     fetch sql_cur into l_total;
     close sql_cur;

     return l_total;

end getFeesTotal;

/*=========================================================================
|| PUBLIC PROCEDURE processLateFees
||
|| DESCRIPTION
|| Overview: this procedure will determine late fees, calculate them and
||            write them to the lns_fee_schedules
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id           => loan_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 1/31/2005 8:40PM      raverma           Created
||
 *=======================================================================*/
procedure processLateFees(p_init_msg_list      in  varchar2
                         ,p_commit             in  varchar2
			 ,p_loan_id            in number
			 ,p_phase		     in varchar2
                         ,x_return_status      out nocopy varchar2
                         ,x_msg_count          out nocopy number
                         ,x_msg_data           out nocopy varchar2)
is

    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_late_fee_structures           LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_late_fee_structure            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fee_basis_tbl                 LNS_FEE_ENGINE.FEE_BASIS_TBL;
    l_fee_calc_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_calc_tbl_full             LNS_FEE_ENGINE.FEE_CALC_TBL;
    i                                    number;
    l_last_installment            number;
    l_amount_overdue          number;
    l_phase			        VARCHAR2(30);

    vPLSQL                         varchar2(4000);
    Type refCur is ref cursor;
    sql_Cur                     refCur;

 begin

   l_api_name           := 'processLateFees';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT processLateFees;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here
   --
   -- 1. getLastInstallment
    --1. getFeeStructures for a particular event(s) / installment
   -- 2. getInvoices for lastinstallment
    --2. calculate for installment
    --3. write to fee schedule
    i := 0;

    l_phase := nvl(p_phase, 'TERM');

    select LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT(p_loan_id)
      into l_last_installment
      from dual;

    if l_last_installment > 0 then

				-- first part is for TERM PHASE
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - last installment ' || l_last_installment);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'processing last installment ' || l_last_installment);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan_id ' || p_loan_id);
        l_late_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                                 ,p_fee_category => 'EVENT'
                                                                 ,p_fee_type     => 'EVENT_LATE_CHARGE'
                                                                 ,p_installment  => l_last_installment
								 ,p_phase	       => l_phase
                                                                 ,p_fee_id       => null);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - after api');

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - late fee structures ' || l_late_fee_structures.count);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'fee structures ' || l_late_fee_structures.count);
        for x in 1..l_late_fee_structures.count loop

        -- get the amount overdue for the last installment (P or P+I depends on fee structure)
          vPlSql := 'select                                                ' ||
                    '       nvl(sum(amount_due_remaining),0)               ' ||
                    '  from lns_amortization_scheds am                     ' ||
                    '      ,ar_payment_schedules    ps                     ' ||
                    '      ,lns_fee_assignments     fass                   ' ||
                    '      ,lns_fees                fees                   ' ||
                    ' where am.loan_id = :p_loan_id and                    ' ||
                    '       am.payment_number = :p_installment and         ' ||
                    '       fees.fee_id  = :p_fee_id and                   ' ||
                    '       ps.amount_due_remaining > 0 and                ' ||
                    '       am.loan_id = fass.loan_id and                  ' ||
                    '       fees.fee_id = fass.fee_id and                  ' ||
		    '	    nvl(fass.phase, ''TERM'') = :l_phase and	'||
                    '       am.reamortization_amount is null and           ' ||
                    '       am.reversed_flag <> ''Y'' and                  ' ||
                    '       am.due_date + nvl(fees.number_grace_days, 0) < trunc(sysdate) ' ||
                    '  and (not exists                                     ' ||
                    '       (select ''X''                                  ' ||
                    '          from lns_fee_schedules sched                ' ||
                    '         where sched.loan_id = am.loan_id             ' ||
                    '           and fee_id = fees.fee_id                   ' ||
                    '           and fee_installment = am.payment_number + 1' ||
		    '		and nvl(sched.phase) = :l_phase	'||
                    '           and billed_flag = ''N''                    ' ||
                    '           and active_flag = ''Y'' )) and             ' ||
                    ' (am.principal_trx_id = ps.customer_trx_id            ';

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee_basis rule ' || l_late_fee_structures(x).fee_basis_rule);
        if l_late_fee_structures(x).fee_basis_rule = 'OVERDUE_PRIN' then
            vPlSql := vPlSql || ')';
        elsif l_late_fee_structures(x).fee_basis_rule = 'OVERDUE_PRIN_INT' then
            vPlSql := vPlSql || 'OR am.interest_trx_id = ps.customer_trx_id)';
        end if;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - last installment ' || l_last_installment);

        l_amount_overdue := 0;
         open sql_cur for
                vPLSQL
            using p_loan_id, l_last_installment, l_late_fee_structures(x).fee_id, l_late_fee_structures(x).phase, l_late_fee_structures(x).phase;
          fetch sql_cur into
                l_amount_overdue;
         close sql_cur;

         if l_amount_overdue > l_late_fee_structures(x).minimum_overdue_amount and l_amount_overdue > 0 then
            -- we have a late fee
            i := i + 1;

            l_fee_basis_tbl(1).fee_basis_name   := 'OVERDUE_PRIN';
            l_fee_basis_tbl(1).fee_basis_amount := l_amount_overdue;
            l_fee_basis_tbl(2).fee_basis_name   := 'OVERDUE_PRIN_INT';
            l_fee_basis_tbl(2).fee_basis_amount := l_amount_overdue;

            l_late_fee_structure(1) := l_late_fee_structures(x);

            lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_installment      => l_last_installment
                                        ,p_fee_structures   => l_late_fee_structure
                                        ,x_fees_tbl         => l_fee_calc_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_CALCULATION_FAILURE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            end if;

            -- Bug#8654492 - The late fee calculated on lastInstallment is billed/scheduled
            -- in next installment
            l_fee_calc_tbl(1).fee_installment    := l_last_installment + 1;

            -- assign this so we can write the fee
            l_fee_calc_tbl_full(i) := l_fee_calc_tbl(1);

         end if;

        end loop;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calculated fees count is ' || l_fee_calc_tbl_full.count);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'calculated fees count is ' || l_fee_calc_tbl_full.count);
        lns_fee_engine.writeFeeSchedule(p_init_msg_list      => p_init_msg_list
                                       ,p_commit             => p_commit
                                       ,p_loan_id            => p_loan_id
                                       ,p_fees_tbl           => l_fee_calc_tbl_full
                                       ,x_return_status      => l_return_status
                                       ,x_msg_count          => l_msg_count
                                       ,x_msg_data           => l_msg_data);
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_FEE_WRITE_FAILURE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

   end if; -- l_last_installment > 1
   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------

   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processLateFees;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processLateFees;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO processLateFees;


end processLateFees;


PROCEDURE LOAN_LATE_FEES_CONCUR(ERRBUF             OUT NOCOPY     VARCHAR2
                               ,RETCODE            OUT NOCOPY     VARCHAR2
                               ,P_BORROWER_ID      IN             NUMBER
                               ,P_LOAN_ID          IN             NUMBER)

is
  l_msg_count       number;
  l_msg_data        varchar2(500);
  l_return_Status   varchar2(1);
  my_message        varchar2(2000);
  l_processed_fees  number;
  l_fee_records1    number;
  l_fee_records2    number;
  l_loan_id         number;
  l_phase		varchar2(30);

  cursor c_borrower_loans(p_borrower_id number) is
  select loan_id, current_phase
    from lns_loan_headers
   where loan_status in ('ACTIVE', 'DELINQUENT', 'DEFAULT')
     and primary_borrower_id = p_borrower_id;

  cursor c_all_active_loans is
  select loan_id, current_phase
    from lns_loan_headers
   where loan_status in ('ACTIVE', 'DELINQUENT', 'DEFAULT');

  cursor c_loan_det(c_loan_id NUMBER) is
  select current_phase
    from lns_loan_headers
   where loan_id = c_loan_id
  and  loan_status in ('ACTIVE', 'DELINQUENT', 'DEFAULT');

BEGIN


    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Beginning Loans Late Fee Assessment');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_LOAN_ID ' || p_loan_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_BORROWER_ID ' || p_borrower_id);

    select count(1) into l_fee_records1
     from lns_fee_schedules
    where active_flag = 'Y'
      and billed_flag = 'N';

    if p_loan_id is not null then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'processing single loan ' || p_loan_id);
	OPEN c_loan_det(p_loan_id);
	FETCH c_loan_det INTO l_phase;
	CLOSE c_loan_det;
        lns_fee_engine.processLateFees(p_init_msg_list => FND_API.G_TRUE
                                      ,p_commit         => FND_API.G_TRUE
				      ,p_loan_id         => p_loan_id
				      ,p_phase	      => l_phase
                                      ,x_return_status => l_return_status
                                      ,x_msg_count    => l_msg_count
                                      ,x_msg_data      => l_msg_data);

    elsif p_borrower_id is not null then

        open c_borrower_loans(p_borrower_id);
        loop
        fetch c_borrower_loans
         into l_loan_id, l_phase;

        exit when c_borrower_loans%notfound;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'processing loan ' || l_loan_id);
        lns_fee_engine.processLateFees(p_init_msg_list => FND_API.G_TRUE
                                      ,p_commit         => FND_API.G_TRUE
				      ,p_loan_id         => l_loan_id
				      ,p_phase	      =>  l_phase
                                      ,x_return_status => l_return_status
                                      ,x_msg_count    => l_msg_count
                                      ,x_msg_data      => l_msg_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'FAP status ' || l_return_status);

        end loop;

    else
        open c_all_active_loans;
        loop
        fetch c_all_active_loans
         into l_loan_id, l_phase;

        exit when c_all_active_loans%notfound;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'processing loan ' || l_loan_id);
        lns_fee_engine.processLateFees(p_init_msg_list => FND_API.G_TRUE
                                      ,p_commit        => FND_API.G_TRUE
				      ,p_loan_id       => l_loan_id
				      ,p_phase	     =>  l_phase
                                      ,x_return_status => l_return_status
                                      ,x_msg_count     => l_msg_count
                                      ,x_msg_data      => l_msg_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'FAP status ' || l_return_status);

        end loop;

    end if;

    select count(1) into l_fee_records2
     from lns_fee_schedules
    where active_flag = 'Y'
      and billed_flag = 'N';

    l_processed_fees := l_fee_records2 - l_fee_records1;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'added ' || l_processed_fees || ' into fee schedule');

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            RAISE FND_API.G_EXC_ERROR;
    else
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Late Fee Assessment: PROCESS COMPLETED SUCCESFULLY.');
    end if;

    EXCEPTION
        -- note do not set retcode when error is expected
        WHEN FND_API.G_EXC_ERROR THEN
                    RETCODE := -1;
                    ERRBUF := l_msg_data;
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN FAP: '  || sqlerrm || ERRBUF);
                    if l_msg_count > 0 then
                        FOR l_index IN 1..l_msg_count LOOP
                            my_message := FND_MSG_PUB.Get(p_msg_index => l_index, p_encoded => 'F');
                            FND_FILE.PUT_LINE(FND_FILE.LOG, my_message);
                        END LOOP;
                    end if;

        WHEN OTHERS THEN
                    RETCODE := -1;
                    ERRBUF := l_msg_data;
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN FAP: '  || sqlerrm || ERRBUF);
                    if l_msg_count > 0 then
                        FOR l_index IN 1..l_msg_count LOOP
                            my_message := FND_MSG_PUB.Get(p_msg_index => l_index, p_encoded => 'F');
                            FND_FILE.PUT_LINE(FND_FILE.LOG, my_message);
                        END LOOP;
                    end if;

END LOAN_LATE_FEES_CONCUR;


/*=========================================================================
|| PUBLIC PROCEDURE getSubmitForApprFeeSchedule
||
|| DESCRIPTION
|| Overview: this procedure will return a table of fees off of the fee
||           schedule of 'At Submit for Approval' fees
||
|| THIS WILL BE CALLED BY BILL_SING_LOAN_SUBMIT_APPR_FEE FUNCTION TO RETURN
|| 'AT SUBMIT FOR APPROVAL' FEES TO BE BILLED ON A LOAN
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_fee_structure_tbl => represents a table of fees
||            p_loan_id           => loan_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date              Author           Description of Changes
|| 07-JUL-2009	     mbolli           Bug#6830765 - Created
|| 26-Oct-2009       mbolli       	Bug#8937530 - Retrieve the BilledFlag ="Y" submitFroApprFee also
 *=======================================================================*/
 procedure getSubmitForApprFeeSchedule(p_init_msg_list        in  varchar2
					,p_loan_id            in  number
					,p_billed_flag        in  varchar2
					,x_fees_tbl           OUT NOCOPY LNS_FEE_ENGINE.FEE_CALC_TBL
					,x_return_status      out nocopy varchar2
					,x_msg_count          out nocopy number
					,x_msg_data           out nocopy varchar2)
is
    l_api_name          varchar2(50);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(32767);

    i                    number;
    l_fee_rec            LNS_FEE_ENGINE.FEE_CALC_REC;
    l_fee_schedule_id    number;
    l_fee_id             number;
    l_fee_amount         number;
    l_fee_name           varchar2(50);
    l_fee_installment    number;
    l_fee_description    varchar2(250);
    l_fee_waivable_flag  varchar2(1);
    l_fee_category       varchar2(30);
    l_fee_type           varchar2(30);
    l_fee_deletable_flag varchar2(1);
    l_fee_editable_flag  varchar2(1);
    l_phase			 varchar2(30);

    -- Billed/Unbilled submitApproval fees on the schedule
    cursor c_submit_appr_fees(c_loan_id number, c_installment number, c_billed_flag varchar2) is
    select sched.fee_schedule_id
          ,sched.fee_id
          ,sched.fee_amount - nvl(sched.waived_amount, 0)
          ,struct.fee_name
          ,struct.fee_category
          ,struct.fee_type
          ,sched.fee_installment
          ,struct.fee_description
          ,sched.fee_waivable_flag      -- should be struct right
          ,decode(struct.fee_category, 'MANUAL', 'Y', 'N')
          ,nvl(struct.fee_editable_flag, 'N')
	  ,nvl(sched.phase, 'TERM')
      from lns_fee_schedules sched
          ,lns_fees struct
     where sched.loan_id = c_loan_id
       and sched.fee_id = struct.fee_id
       and fee_installment = c_installment
       and struct.FEE_CATEGORY = 'EVENT'
       and struct.FEE_TYPE = 'EVENT_ORIGINATION'
       and struct.BILLING_OPTION = 'SUBMIT_FOR_APPROVAL'
       and active_flag = 'Y'
       and billed_flag = c_billed_flag
       and (not exists
          (select 'X'
             from lns_amortization_scheds am
                 ,lns_amortization_lines lines
            where lines.loan_id = c_loan_id
              and lines.fee_schedule_id = sched.fee_schedule_id
              and am.loan_id = lines.loan_id
              and NVL(am.reversed_flag, 'N') = 'N'
              and am.payment_number = c_installment
	      and am.amortization_schedule_id = (select max(amortization_schedule_id)
				from lns_amortization_lines amlines2
				where amlines2.fee_schedule_id = lines.fee_schedule_id)
	    )
            or exists
            (select 'X'
             from lns_amortization_scheds am
                 ,lns_amortization_lines lines
            where lines.loan_id = c_loan_id
              and lines.fee_schedule_id = sched.fee_schedule_id
              and am.loan_id = lines.loan_id
              and am.reversed_flag = 'Y'
              and am.payment_number = c_installment
	      and am.amortization_schedule_id = (select max(amortization_schedule_id)
				from lns_amortization_lines amlines2
				where  amlines2.fee_schedule_id = lines.fee_schedule_id)
	     ));


 begin

   l_api_name           :=	'getSubmitForApprFeeSchedule';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT getSubmitForApprFeeSchedule;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here
   i := 0;
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'The p_billed_flag is :'||p_billed_flag);
	OPEN c_submit_appr_fees(p_loan_id, 0, p_billed_flag);
	LOOP

	FETCH c_submit_appr_fees INTO
	        l_fee_schedule_id
	       ,l_fee_id
	       ,l_fee_amount
	       ,l_fee_name
	       ,l_fee_category
	       ,l_fee_type
	       ,l_fee_installment
	       ,l_fee_description
	       ,l_fee_waivable_flag
	       ,l_fee_deletable_flag
	       ,l_fee_editable_flag
	       ,l_phase;
	EXIT WHEN c_submit_appr_fees%NOTFOUND;

                i := i + 1;
		l_fee_rec.fee_schedule_id      := l_fee_schedule_id;
	        l_fee_rec.fee_id               := l_fee_id;
	        l_fee_rec.fee_amount           := l_fee_amount;
	        l_fee_rec.fee_name             := l_fee_name;
	        l_fee_rec.fee_category         := l_fee_category;
	        l_fee_rec.fee_type             := l_fee_type;
	        l_fee_rec.fee_installment      := l_fee_installment;
	        l_fee_rec.fee_description      := l_fee_description;
	        l_fee_rec.fee_waivable_flag    := l_fee_waivable_flag;
	        l_fee_rec.fee_deletable_flag   := l_fee_deletable_flag;
	        l_fee_rec.fee_editable_flag    := l_fee_editable_flag;
		l_fee_rec.phase			   := l_phase;

	        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - SubmtApproval fee #: ' || i);
	        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee schedule id: ' || l_fee_rec.fee_schedule_id);
	        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee id: ' || l_fee_rec.fee_id);
	        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - fee amount: ' || l_fee_rec.fee_amount);
	        x_fees_tbl(i) := l_fee_rec;
	END LOOP;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Total No. of SubmitApproval Fees are: ' || i);

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getSubmitForApprFeeSchedule;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getSubmitForApprFeeSchedule;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO getSubmitForApprFeeSchedule;

end getSubmitForApprFeeSchedule;

/*=========================================================================
|| PUBLIC PROCEDURE SET_DISB_FEES_INSTALL
||
|| DESCRIPTION
|| Overview: this procedure will update the feeInstallments(begin and end) for the given disb_header_id
||
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_disb_header_id => disbursement header id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date              Author           Description of Changes
|| 16-FEB-2010	     mbolli           Bug#9255294 - Created
 *=======================================================================*/
 procedure SET_DISB_FEES_INSTALL(p_init_msg_list        in  varchar2
					,p_disb_header_id        in  varchar2
					,x_return_status      out nocopy varchar2
					,x_msg_count         out nocopy number
					,x_msg_data           out nocopy varchar2)
is
    l_api_name          varchar2(50);
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(32767);
    l_inst_no		NUMBER;

    l_fee_assignment_rec     LNS_FEE_ASSIGNMENT_PUB.FEE_ASSIGNMENT_REC_TYPE;

 begin

   l_api_name           :=	'SET_DISB_FEES_INSTALL';

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT SET_DISB_FEES_INSTALL;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   -- initialize any variables here

	-- Update the feeInstallment of the fundignFees of this disbursement
    	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Updating the feeAssignment installments of disb_hdr_id: '||p_disb_header_id);

	l_inst_no := LNS_FIN_UTILS.getNextInstForDisbursement(p_disb_header_id);

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Installment No is : '||l_inst_no);

	IF (l_inst_no IS NULL OR  l_inst_no = -1) THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Call to LNS_FIN_UTIL.getNextInstForDisbursement failed');
	ELSE

		UPDATE lns_fee_assignments
		SET begin_installment_number = l_inst_no
			,end_installment_number = l_inst_no
			,object_version_number = object_version_number + 1
			,last_updated_by  = LNS_UTILITY_PUB.last_updated_by
			,last_update_date = LNS_UTILITY_PUB.last_update_date
			,last_update_login = LNS_UTILITY_PUB.last_update_login
		WHERE disb_header_id =p_disb_header_id;

		 LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Updated feeAssignments '||SQL%ROWCOUNT);

	END IF;

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO SET_DISB_FEES_INSTALL;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO SET_DISB_FEES_INSTALL;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO SET_DISB_FEES_INSTALL;


END SET_DISB_FEES_INSTALL;

END LNS_FEE_ENGINE;

/
