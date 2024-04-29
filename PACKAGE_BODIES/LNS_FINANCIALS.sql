--------------------------------------------------------
--  DDL for Package Body LNS_FINANCIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_FINANCIALS" AS
/* $Header: LNS_FINANCIAL_B.pls 120.28.12010000.32 2010/05/20 14:06:05 scherkas ship $ */


 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_DEBUG_COUNT  NUMBER := 0;
 G_DEBUG        BOOLEAN := FALSE;
 G_FILE_NAME    CONSTANT VARCHAR2(30) := 'LNS_FINANCIALS_B.pls';

 G_PKG_NAME     CONSTANT VARCHAR2(30) := 'LNS_FINANCIALS';

procedure LOAD_ORIGINAL_SCHEDULE(p_loan_details in LNS_FINANCIALS.LOAN_DETAILS_REC,
                                 x_loan_amort_tbl out nocopy LNS_FINANCIALS.AMORTIZATION_TBL);

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

-- internal usage only
function formatTerm(p_timeString IN varchar2) return varchar2
is

  l_temp varchar2(30);
begin

    -- this logic is to handle "MONTHLY" => "MONTHS" ETC...
    if substr(p_timeString, length(p_timeString) - 1, 2) = 'LY' then
        l_temp := substr(p_timeString, 1, length(p_timeString) - 2) || 'S';
    else
        l_temp := p_timeString;
    end if;

    return l_temp;

end;

/*
|| Overview:      debugging routine only
||
|| Parameter:     amortizationTable to log
||
|| Creation date:       12/08/2003 6:31PM
||
*/
procedure printAmortizationTable(p_amort_tbl IN lns_financials.amortization_tbl)

is

  l_api_name             varchar2(30);
  i                      number;
  l_installment_number   varchar2(30);
  l_due_date             varchar2(30);
  l_principal_amount     varchar2(30);
  l_interest_amount      varchar2(30);
  l_fee_amount           varchar2(30);
  l_other_amount         varchar2(30);
  l_total                varchar2(30);
  l_begin_balance        varchar2(30);
  l_end_balance          varchar2(30);
  l_principal_cumulative varchar2(30);
  l_interest_cumulative  varchar2(30);
  l_fees_cumulative      varchar2(30);
  l_other_cumulative     varchar2(30);
  l_rate_id              varchar2(30);

begin
        i := 0;
        l_api_name  := 'printAmortizationTable';

        i := p_amort_tbl.count;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization table count: ' || i);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Period  Due Date     TOTAL DUE       Interest        Principal     Fees Other    '  ||
                       ' Cum.Interest     Cum.Principal    Cum.Fees    Cum.Other    Begin Balance       End Balanace  ');
/*
        for k in 1..i
        loop
            l_installment_number   := nvl(to_char(p_amort_tbl(k).installment_number), '       ');
            l_due_date             := nvl(to_char(p_amort_tbl(k).due_date, 'mm/dd/yy'), '       ');
            l_total                := nvl(to_char(p_amort_tbl(k).total), '       ');
            l_interest_amount      := nvl(to_char(p_amort_tbl(k).interest_amount), '       ');
            l_principal_amount     := nvl(to_char(p_amort_tbl(k).principal_amount), '       ');
            l_other_amount         := nvl(to_char(p_amort_tbl(k).other_amount), '       ');
            l_fee_amount           := nvl(to_char(p_amort_tbl(k).fee_amount), '       ');
--            l_interest_cumulative  := nvl(to_char(p_amort_tbl(k).interest_cumulative), '       ');
--            l_principal_cumulative := nvl(to_char(p_amort_tbl(k).principal_cumulative), '       ');
--            l_fees_cumulative      := nvl(to_char(p_amort_tbl(k).fees_cumulative), '       ');
--            l_other_cumulative     := nvl(to_char(p_amort_tbl(k).other_cumulative), '       ');
--            l_rate_id              := nvl(to_char(p_amort_tbl(k).rate_id), '       ');
            l_begin_balance        := nvl(to_char(p_amort_tbl(k).begin_balance), '       ');
            l_end_balance          := nvl(to_char(p_amort_tbl(k).end_balance), '       ');

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ':   ' || l_installment_number ||
                                                                              '    ' || l_due_date ||
                                                                              '       ' || l_total ||
                                                                              '    ' || l_interest_amount ||
                                                                              '        ' || l_principal_amount ||
                                                                              '     ' || l_other_amount ||
                                                                              '        ' || l_fee_amount ||
--                                                                              '     ' ||  l_fees_cumulative ||
--                                                                              '     ' || l_other_cumulative ||
--                                                                              '     ' ||  l_interest_cumulative ||
--                                                                              '     ' || l_principal_cumulative ||
                                                                              '     ' || l_begin_balance ||
                                                                              '     ' || l_end_balance);
        end loop;
 */
end printAmortizationTable;

/* routine will sort loanActivities by activityDate
 */
procedure sortRows(p_loan_activity_tbl in out nocopy LNS_FINANCIALS.LOAN_ACTIVITY_TBL)

is
    j            number;                            -- counter
    l_tmp_row    LNS_FINANCIALS.LOAN_ACTIVITY_REC;  -- to store temp row
    l_min        date;                              -- minimum date

begin

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, ' - sorting the rows');
    for i in 1..p_loan_activity_tbl.count loop
        l_min := p_loan_activity_tbl(i).activity_date;

        for j in i + 1..p_loan_activity_tbl.count loop

            if p_loan_activity_tbl(j).activity_date < l_min then
                l_min := p_loan_activity_tbl(j).activity_date;
                l_tmp_row := p_loan_activity_tbl(i);
                p_loan_activity_tbl(i) := p_loan_activity_tbl(j);
                p_loan_activity_tbl(j) := l_tmp_row;
            end if;
        end loop;
    end loop;
end sortRows;

/*=========================================================================
|| PUBLIC PROCEDURE floatingRatePostProcessing
||
|| DESCRIPTION
||
|| Overview: handle all post processing steps after BILLLING a FLOATING rate loan
||
|| Parameter: p_loan_id                  => loan id
||            p_period_begin_date        => date at which interest was last adjusted
||            p_annualized_interest_rate => rate for which installment was billed
||            p_rate_id                  => rateID for rae
||
|| Return value:
||
|| Source Tables:
||
|| Target Tables:  LNS_TERMS, LNS_RATE_SCHEDULES
||
|| KNOWN ISSUES
||
|| NOTES
||          -- POST PROCESSING STEPS recalculate and enter into LNS_TERMS
||          --  1. next_rate_change_date
||          --  2. new projected rate
||          --  3. re-align rate schedule
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 11/24/2005 11:35AM     raverma           Created
|| 06/16/2006 11:35AM     karamach          Added code to check and update only the existing rate sch row
|| when begin_installment_number = end_installment_number = p_installment_number for the rate schedule row being processed
|| as part of the fix for bug5331888
||
 *=======================================================================*/
procedure floatingRatePostProcessing(p_loan_id                  IN NUMBER
                                    ,p_init_msg_list            IN VARCHAR2
                                    ,p_commit                   IN VARCHAR2
                                    ,p_installment_number       IN NUMBER
                                    ,p_period_begin_date        IN DATE
                                    ,p_interest_adjustment_freq IN VARCHAR2
                                    ,p_annualized_interest_rate IN NUMBER
                                    ,p_rate_id                  IN OUT NOCOPY NUMBER
                                    ,p_phase                    IN VARCHAR2
                                    ,x_return_status            OUT NOCOPY VARCHAR2
                                    ,x_msg_count                OUT NOCOPY NUMBER
                                    ,x_msg_data                 OUT NOCOPY VARCHAR2)
is
   l_next_rate_change  date;
   l_api_name          varchar2(30);
   l_new_rate_id       number;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(32767);

   Cursor c_get_rate_sch_info(pRateId number) is
   select begin_installment_number, end_installment_number
   from lns_rate_schedules where rate_id = pRateId;
   l_begin_inst_num number;
   l_end_inst_num number;
BEGIN

        l_api_name           := 'floatingRatePostProcessing';
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id ' || p_loan_id);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase ' || p_phase);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment_number ' || p_installment_number);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_period_begin_date ' || p_period_begin_date);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_interest_adjustment_freq ' || p_interest_adjustment_freq);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_annualized_interest_rate ' || p_annualized_interest_rate);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_rate_id ' || p_rate_id);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase ' || p_phase);

        -- Standard Start of API savepoint
        SAVEPOINT floatingPostProcessor;

        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- Api body
        -- ----------------------------------------------------------------

        if p_installment_number <> lns_fin_utils.getNumberInstallments(p_loan_id => p_loan_id
                                                                      ,p_phase   => p_phase) then
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting next rate change info');
          l_next_rate_change := lns_fin_utils.getNextDate(p_date          => p_period_begin_date
                                                         ,p_interval_type => p_interest_adjustment_freq
                                                         ,p_direction     => 1);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - updating terms with new date ' || l_next_rate_change);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - updating terms with new rate' || p_annualized_interest_rate);
          if p_phase = 'OPEN' then
            update lns_terms
               set next_rate_change_date = l_next_rate_change
                  ,open_projected_rate   = p_annualized_interest_rate
                  ,last_update_date      = sysdate
                  ,last_updated_by       = lns_utility_pub.user_id
             where loan_id = p_loan_id;
          elsif p_phase = 'TERM' then
            update lns_terms
               set next_rate_change_date = l_next_rate_change
                  ,term_projected_rate    = p_annualized_interest_rate
                  ,last_update_date      = sysdate
                  ,last_updated_by       = lns_utility_pub.user_id
             where loan_id = p_loan_id;
          end if;

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - updating the rate schedule ' || p_rate_id);
          -- store the row on lns_rate_schedules(only if the existing row does not have begin and end installment numbers same as this installment) and update existing rate_schedule row
	 open c_get_rate_sch_info(p_rate_id);
	 fetch c_get_rate_sch_info into l_begin_inst_num,l_end_inst_num;
         close c_get_rate_sch_info;

	 if (l_begin_inst_num = l_end_inst_num and l_begin_inst_num = p_installment_number) then
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' (l_begin_inst_num = l_end_inst_num = p_installment_number) - NO need to insert new row - updating the existing rate schedule ' || p_rate_id);

          -- update existing rate_schedule row
          update lns_rate_schedules
             set current_interest_rate = p_annualized_interest_rate
                ,index_rate = p_annualized_interest_rate - nvl(spread,0)
           where rate_id = p_rate_id;

	 else --else for if (l_begin_inst_num = l_end_inst_num = p_installment_number) then
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' update the existing row as the next row and insert new row for the current rate sch');
           update lns_rate_schedules
             set begin_installment_number = begin_installment_number + 1
                ,current_interest_rate = spread
                ,index_rate = null
           where rate_id = p_rate_id;

          select LNS_RATE_SCHEDULES_S.NEXTVAL into l_new_rate_id
            from dual;

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - adding new row into rate schedule');
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_new_rate_id ' || l_new_rate_id );
          insert into lns_rate_schedules(RATE_ID
                                        ,TERM_ID
                                        ,INDEX_RATE
                                        ,SPREAD
                                        ,CURRENT_INTEREST_RATE
                                        ,START_DATE_ACTIVE
                                        ,END_DATE_ACTIVE
                                        ,CREATED_BY
                                        ,CREATION_DATE
                                        ,LAST_UPDATED_BY
                                        ,LAST_UPDATE_DATE
                                        ,LAST_UPDATE_LOGIN
                                        ,OBJECT_VERSION_NUMBER
                                        ,INDEX_DATE
                                        ,BEGIN_INSTALLMENT_NUMBER
                                        ,END_INSTALLMENT_NUMBER
                                        ,INTEREST_ONLY_FLAG
                                        ,FLOATING_FLAG
                                        ,PHASE)
                                        (select
                                          l_new_rate_id
                                         ,TERM_ID
                                         ,p_annualized_interest_rate - nvl(spread,0)
                                         ,SPREAD
                                         ,p_annualized_interest_rate  --make sure you only insert spread overtop of CIR
                                         ,START_DATE_ACTIVE
                                         ,END_DATE_ACTIVE
                                         ,CREATED_BY
                                         ,sysdate
                                         ,LAST_UPDATED_BY
                                         ,sysdate
                                         ,LAST_UPDATE_LOGIN
                                         ,1
                                         ,INDEX_DATE
                                         ,p_installment_number
                                         ,p_installment_number
                                         ,INTEREST_ONLY_FLAG
                                         ,FLOATING_FLAG
                                         ,PHASE
                                         from lns_rate_schedules
                                         where rate_id =  p_rate_id);

          -- assign new rate id for OUT parameter
          p_rate_id := l_new_rate_id ;

         end if; --end else part for if (l_begin_inst_num = l_end_inst_num = p_installment_number) then

        else --else for if p_installment_number <> lns_fin_utils.getNumberInstallments(p_loan_id => p_loan_id

	  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - updating the rate schedule LAST ROW ' || p_rate_id);
          -- update existing rate_schedule row
          update lns_rate_schedules
             set current_interest_rate = p_annualized_interest_rate
                ,index_rate = p_annualized_interest_rate - nvl(spread,0)
           where rate_id = p_rate_id;

        end if; --end if p_installment_number <> lns_fin_utils.getNumberInstallments(p_loan_id => p_loan_id


        --
        -- End of API body
        --
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO floatingPostProcessor;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO floatingPostProcessor;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO floatingPostProcessor;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end floatingRatePostProcessing;

 --------------------------------------------
 -- validation routines
 --------------------------------------------

/*=========================================================================
|| PUBLIC PROCEDURE validateLoan
||
|| DESCRIPTION
||
|| Overview: cover rountine to validate the loan
||
|| Parameter: loan_id
||
|| Return value:
||
|| Source Tables:  NA
||
|| Target Tables:
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 11:35AM     raverma           Created
||
 *=======================================================================*/
procedure validateLoan(p_api_version    IN NUMBER
                      ,p_init_msg_list  IN VARCHAR2
                      ,p_loan_ID        IN NUMBER
                      ,x_return_status  OUT NOCOPY VARCHAR2
                      ,x_msg_count      OUT NOCOPY NUMBER
                      ,x_msg_data       OUT NOCOPY VARCHAR2)
is
    l_api_name           varchar2(25);
    l_api_version_number number;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(32767);

    l_rate_tbl           LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_amount             number;
    l_status             varchar2(30);

    CURSOR c_terms(p_Loan_id NUMBER) IS
        SELECT TERM_ID
          FROM LNS_TERMS
         WHERE LOAN_ID = p_Loan_id;

BEGIN

        l_api_name           := 'validateLoan';
        l_api_version_number := 1;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

        -- Standard Start of API savepoint
        SAVEPOINT validateLoan;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                            l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- Api body
        -- ----------------------------------------------------------------
        -- there should be one active row in the terms
        -- ----------------------------------------------------------------
        Begin
            OPEN c_terms(p_loan_id);
            CLOSE c_terms;

            Exception
                When No_Data_Found then
                    CLOSE c_terms;
                    FND_MESSAGE.Set_Name('LNS', 'LNS_NO_TERMS');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_ERROR;
        end;

        -- rate schedules should have one row
        l_rate_tbl := lns_financials.getRateSchedule(p_loan_id, 'TERM');

        if l_rate_tbl.count = 0 then
            FND_MESSAGE.Set_Name('LNS', 'LNS_NO_RATE_SCHEDULE');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        Begin
            l_amount := lns_financials.getRemainingBalance(p_loan_id);
            if l_amount <= 0 then
                FND_MESSAGE.Set_Name('LNS', 'LNS_NO_AMOUNT');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            end if;

        end;

        --
        -- End of API body
        --

        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

        EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

            WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

END validateLoan;

---------------------------------------------------------------------------
--- amortization routines
---------------------------------------------------------------------------

/*=========================================================================
|| PUBLIC PROCEDURE runAmortization
||
|| DESCRIPTION
||
|| Overview: procedure will run an amortization and store it into a
||           return an amortization table
||
|| Parameter:  loan_id
||
|| Source Tables:  NA
||
|| Target Tables: None
||
|| Return value: x_amort_tbl is table of amortization records
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 11/09/2004 11:35AM     raverma           Created
||
 *=======================================================================*/
procedure runAmortization(p_api_version    IN NUMBER
                         ,p_init_msg_list  IN VARCHAR2
                         ,p_commit         IN VARCHAR2
                         ,p_loan_ID        IN NUMBER
                         ,p_based_on_terms IN VARCHAR2
                         ,x_amort_tbl      OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_TBL
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2)

is
    l_api_name                varchar2(25);
    l_api_version_number      number;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(32767);

    l_amort_tbl               LNS_FINANCIALS.AMORTIZATION_TBL;
    l_amort_tbl2              LNS_FINANCIALS.AMORTIZATION_TBL;
    l_total_amortization      LNS_FINANCIALS.AMORTIZATION_REC;
    l_key                     NUMBER;
    b_showActual              boolean := false;
    l_last_installment_billed number;
    l_customized              varchar2(1);

   cursor c_customized (p_loan_id number) is
   SELECT nvl(h.custom_payments_flag, 'N')
     FROM lns_loan_headers_all h
    WHERE loan_id = p_loan_id;

    cursor c_customSchedule(p_loan_id number) is
    select payment_number            installment_number
          ,due_date                  due_date
          ,nvl(principal_amount, 0)          principal_amount
          ,nvl(interest_amount, 0)           interest_amount
          ,nvl(other_amount, 0)              other_amount
          ,nvl(installment_begin_balance, 0) begin_balance
          ,nvl(installment_end_balance, 0)   end_balance
     from  lns_custom_paymnt_scheds
    where loan_id = p_loan_id
 order by payment_number;

    -- bug # 4258345
    -- add late fees to
    cursor c_manual_fees(p_loan_id number, p_installment number) is
    select sum(nvl(fee_amount,0))
      from lns_fee_schedules sch,
           lns_fees fees
     where sch.active_flag = 'Y'
       and sch.billed_flag = 'N'
       and fees.fee_id = sch.fee_id
       and ((fees.fee_category = 'MANUAL')
        OR (fees.fee_category = 'EVENT' AND fees.fee_type = 'EVENT_LATE_CHARGE'))
       and sch.loan_id = p_loan_id
       and fee_installment = p_installment
       and sch.phase = 'TERM';

    l_installment_number      number;
    l_due_date                date;
    l_principal_amount        number;
    l_interest_amount         number;
    l_other_amount            number;
    l_fee_amount              number;
    l_begin_balance           number;
    l_end_balance             number;
    l_total                   number;
    l_num_records             number;
    i                         number;
    m                         number;
    l_records_to_copy         number;
    l_num_installments        number;
    l_num_rows                number;
    l_manual_fee_amount       number;
    l_records_to_destroy      number;
    l_start_date              number;
    l_funded_amount           number;
    l_loan_details            LNS_FINANCIALS.LOAN_DETAILS_REC;
	l_amortization_rec		  LNS_FINANCIALS.AMORTIZATION_REC;

    l_last_payment            number;
    l_disb_header_id                 number;
    l_billed                         varchar2(1);
    n                                number;
    l_original_loan_amount    number;
    l_fund_sched_count        number;

    -- for fees
    l_fee_structures          LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fee_structures     LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_orig_fee_structures     LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
--    l_orig_fee_structures1    LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_new_orig_fee_structures LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_funding_fee_structures  LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fees_tbl           LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl           LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fees_tbl                LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_funding_fees_tbl        LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl           LNS_FEE_ENGINE.FEE_BASIS_TBL;

    l_custom_tbl              LNS_CUSTOM_PUB.CUSTOM_TBL;
    l_AMORT_METHOD            varchar2(30);
    l_rate_tbl                LNS_FINANCIALS.RATE_SCHEDULE_TBL;

    cursor c_orig_fee_billed(p_loan_id number, p_fee_id number, p_based_on_terms varchar2) is
        select 'X'
        from lns_fee_schedules sched
            ,lns_fees struct
        where sched.loan_id = p_loan_id
        and sched.fee_id = p_fee_id
        and sched.fee_id = struct.fee_id
        and struct.fee_type = 'EVENT_ORIGINATION'
        and sched.active_flag = 'Y'
        and decode(p_based_on_terms, 'CURRENT', sched.billed_flag, 'N') = 'Y'
        and sched.phase = 'TERM';

    cursor c_fund_sched_exist(p_loan_id number)  is
        select decode(loan.loan_class_code,
            'DIRECT', (select count(1) from lns_disb_headers where loan_id = p_loan_id and status is null and PAYMENT_REQUEST_DATE is not null),
            'ERS', (select count(1) from lns_loan_lines where loan_id = p_loan_id and (status is null or status = 'PENDING') and end_date is null))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT runAmortization_PVT;
        l_api_name                := 'runAmortization';
        l_api_version_number      := 1;
        i                         := 0;
        l_manual_fee_amount       := 0;


        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_ID ' || p_loan_ID);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_based_on_terms ' || p_based_on_terms);

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                            l_api_name, G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- Api body
        -- ----------------------------------------------------------------
        -- validate loan_id
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
/*
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting customization status');

        open c_customized(p_loan_id);
        fetch c_customized into l_customized;
        close c_customized;

        if l_customized = 'N' then
*/

        l_loan_details  := lns_financials.getLoanDetails(p_loan_Id         => p_loan_id
                                                        ,p_based_on_terms  => p_based_on_terms
                                                        ,p_phase           => 'TERM');

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LOAN_STATUS =  ' || l_loan_details.LOAN_STATUS);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_based_on_terms =  ' || p_based_on_terms);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LOAN_PHASE =  ' || l_loan_details.LOAN_PHASE);

        l_amort_tbl.delete;
        if l_loan_details.LOAN_STATUS NOT IN ('INCOMPLETE','DELETED','REJECTED','PENDING') and
           p_based_on_terms <> 'CURRENT' --and l_loan_details.LOAN_PHASE = 'TERM'
        then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LOAD_ORIGINAL_SCHEDULE...');
            LOAD_ORIGINAL_SCHEDULE(p_loan_details => l_loan_details,
                                 x_loan_amort_tbl => l_amort_tbl);

            if l_amort_tbl.count > 0 then
                x_amort_tbl := l_amort_tbl;
                return;
            else
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'ERROR: Failed to load original schedule');
                RAISE FND_API.G_EXC_ERROR;
            end if;
        end if;

        if (l_loan_details.CUSTOM_SCHEDULE = 'N' or
           (l_loan_details.CUSTOM_SCHEDULE = 'Y' and l_loan_details.loan_status <> 'INCOMPLETE' and
            p_based_on_terms <> 'CURRENT' and l_loan_details.ORIG_PAY_CALC_METHOD is not null))
        then

            -- preProcess will add a re-amortization row if the remaining amount < funded amount
			-- bug# 5664316

            if p_based_on_terms = 'CURRENT' and l_loan_details.reamortize_overpay = 'Y' then

                -- call preProcessInstallment only for current amortization
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - preProcess the loan');
                preProcessInstallment(p_api_version    => 1.0
                    ,p_init_msg_list  => p_init_msg_list
                    ,p_commit         => FND_API.G_FALSE --p_commit
                    ,p_loan_ID        => p_loan_id
                    ,p_installment_number => lns_billing_util_pub.last_payment_number(p_loan_id)
                    ,x_amortization_rec => l_amortization_rec
                    ,x_return_status  => l_return_status
                    ,x_msg_count      => l_msg_count
                    ,x_msg_data       => l_msg_data);

            end if;

            -- call amortization API
            lns_financials.amortizeLoan(p_loan_Id            => p_loan_id
                                       ,p_based_on_terms     => p_based_on_terms
                                       ,p_installment_number => null
                                       ,x_loan_amort_tbl     => l_amort_tbl);
        else

            -- call LNS_CUSTOM_PUB.loadCustomSchedule for customized loan

            -- we will overlay fee structures on top of schedule
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - loan is customized');

            l_fee_amount := 0;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting origination1 fee structures');
            l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                                    ,p_fee_category => 'EVENT'
                                                                    ,p_fee_type     => 'EVENT_ORIGINATION'
                                                                    ,p_installment  => null
                                                                    ,p_phase        => 'TERM'
                                                                    ,p_fee_id       => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': origination1 structures count is ' || l_orig_fee_structures.count);

            -- filtering out origination fees based on p_based_on_terms
            n := 0;
            for m in 1..l_orig_fee_structures.count loop
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee = ' || l_orig_fee_structures(m).FEE_ID);
                l_billed := null;
                open c_orig_fee_billed(p_loan_id, l_orig_fee_structures(m).FEE_ID, p_based_on_terms);
                fetch c_orig_fee_billed into l_billed;
                close c_orig_fee_billed;

                if l_billed is null then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is not billed yet');
                    n := n + 1;
                    l_new_orig_fee_structures(n) := l_orig_fee_structures(m);
                else
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is already billed');
                end if;
            end loop;

            if l_new_orig_fee_structures.count > 0 then

                if p_based_on_terms <> 'CURRENT' then
                    open c_fund_sched_exist(p_loan_id);
                    fetch c_fund_sched_exist into l_fund_sched_count;
                    close c_fund_sched_exist;

                    if l_fund_sched_count = 0 then
                        l_original_loan_amount := l_loan_details.requested_amount;
                    else
                        l_original_loan_amount := getFundedAmount(p_loan_id, l_loan_details.loan_start_date, p_based_on_terms);
                    end if;
                else
                    l_original_loan_amount := getFundedAmount(p_loan_id, l_loan_details.loan_start_date, p_based_on_terms);
                end if;

                -- calculate fees here
                -- should be new routine to simply get the fees from the fee schedule
                l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
                l_fee_basis_tbl(1).fee_basis_amount := l_loan_details.requested_amount;
                l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
                l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.requested_amount;
                l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
                l_fee_basis_tbl(3).fee_basis_amount := l_loan_details.requested_amount;
                --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
                --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

                l_orig_fees_tbl.delete;

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
                lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                            ,p_installment      => 0
                                            ,p_fee_basis_tbl    => l_fee_basis_tbl
                                            ,p_fee_structures   => l_new_orig_fee_structures
                                            ,x_fees_tbl         => l_orig_fees_tbl
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fees_tbl.count);

                for k in 1..l_orig_fees_tbl.count loop
                    l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
                end loop;

               if l_fee_amount > 0 then
                   i := i + 1;
                   l_amort_tbl(i).installment_number   := 0;
                   l_amort_tbl(i).due_date             := l_loan_details.loan_start_date;
                   l_amort_tbl(i).PERIOD_START_DATE    := l_loan_details.loan_start_date;
                   l_amort_tbl(i).PERIOD_END_DATE      := l_loan_details.loan_start_date;
                   l_amort_tbl(i).principal_amount     := 0;
                   l_amort_tbl(i).interest_amount      := 0;
                   l_amort_tbl(i).fee_amount           := l_fee_amount;
                   l_amort_tbl(i).other_amount         := 0;
                   l_amort_tbl(i).begin_balance        := l_original_loan_amount;
                   l_amort_tbl(i).end_balance          := l_original_loan_amount;
                   l_amort_tbl(i).interest_cumulative  := 0;
                   l_amort_tbl(i).principal_cumulative := 0;
                   l_amort_tbl(i).fees_cumulative      := l_fee_amount;
                   l_amort_tbl(i).other_cumulative     := 0;
                   l_amort_tbl(i).UNPAID_PRIN          := 0;
                   l_amort_tbl(i).UNPAID_INT           := 0;
                   l_amort_tbl(i).NORMAL_INT_AMOUNT    := 0;
                   l_amort_tbl(i).ADD_PRIN_INT_AMOUNT  := 0;
                   l_amort_tbl(i).ADD_INT_INT_AMOUNT   := 0;
                   l_amort_tbl(i).PENAL_INT_AMOUNT     := 0;
                   l_amort_tbl(i).PERIOD               := l_loan_details.loan_start_date || ' - ' || l_loan_details.loan_start_date;
                   l_amort_tbl(i).DISBURSEMENT_AMOUNT  := 0;
                   -- add the record to the amortization table

                   l_rate_tbl := lns_financials.getRateSchedule(p_loan_id, 'TERM');
                   l_amort_tbl(i).INTEREST_RATE        := l_rate_tbl(1).annual_rate;

                   l_amort_tbl(i).total                := l_fee_amount;
               end if;

            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting recurring fee structures');
            l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                               ,p_fee_category => 'RECUR'
                                                               ,p_fee_type     => null
                                                               ,p_installment  => null
                                                               ,p_phase        => 'TERM'
                                                               ,p_fee_id       => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': fee structures count is ' || l_fee_structures.count);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting memo fee structures');
            l_memo_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => p_loan_id
                                                                    ,p_fee_category => 'MEMO'
                                                                    ,p_fee_type     => null
                                                                    ,p_installment  => null
                                                                    ,p_phase        => 'TERM'
                                                                    ,p_fee_id       => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': memo fee structures count is ' || l_memo_fee_structures.count);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting funding fee structures');
            l_funding_fee_structures  := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => p_loan_id
                                                                                    ,p_installment_no => null
                                                                                    ,p_phase          => 'TERM'
                                                                                    ,p_disb_header_id => null
                                                                                    ,p_fee_id         => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding fee structures count is ' || l_funding_fee_structures.count);

             -- load custom schedule
            LNS_CUSTOM_PUB.loadCustomSchedule(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_TRUE,
                P_COMMIT		        => FND_API.G_FALSE,
                P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
                P_LOAN_ID               => P_LOAN_ID,
                P_BASED_ON_TERMS        => p_based_on_terms,
                X_AMORT_METHOD          => l_AMORT_METHOD,
                X_CUSTOM_TBL            => l_custom_tbl,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

            IF l_return_status <> 'S' THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            for p in 1..l_custom_tbl.count loop

                i := i + 1;
                l_amort_tbl(i).installment_number   := l_custom_tbl(p).PAYMENT_NUMBER;
                l_amort_tbl(i).due_date             := l_custom_tbl(p).DUE_DATE;
                l_amort_tbl(i).PERIOD_START_DATE    := l_custom_tbl(p).PERIOD_START_DATE;
                l_amort_tbl(i).PERIOD_END_DATE      := l_custom_tbl(p).PERIOD_END_DATE;
                l_amort_tbl(i).principal_amount     := l_custom_tbl(p).PRINCIPAL_AMOUNT;
                l_amort_tbl(i).interest_amount      := l_custom_tbl(p).INTEREST_AMOUNT;
                l_amort_tbl(i).begin_balance        := l_custom_tbl(p).INSTALLMENT_BEGIN_BALANCE;
                l_amort_tbl(i).end_balance          := l_custom_tbl(p).INSTALLMENT_END_BALANCE;
                l_amort_tbl(i).UNPAID_PRIN          := l_custom_tbl(p).UNPAID_PRIN;
                l_amort_tbl(i).UNPAID_INT           := l_custom_tbl(p).UNPAID_INT;
                l_amort_tbl(i).INTEREST_RATE        := l_custom_tbl(p).INTEREST_RATE;
                l_amort_tbl(i).NORMAL_INT_AMOUNT    := l_custom_tbl(p).NORMAL_INT_AMOUNT;
                l_amort_tbl(i).ADD_PRIN_INT_AMOUNT  := l_custom_tbl(p).ADD_PRIN_INT_AMOUNT;
                l_amort_tbl(i).ADD_INT_INT_AMOUNT   := l_custom_tbl(p).ADD_INT_INT_AMOUNT;
                l_amort_tbl(i).PENAL_INT_AMOUNT     := l_custom_tbl(p).PENAL_INT_AMOUNT;
                l_other_amount                      := 0;
                l_fee_amount                        := 0;
                l_amort_tbl(i).NORMAL_INT_DETAILS   := l_custom_tbl(p).NORMAL_INT_DETAILS;
                l_amort_tbl(i).ADD_PRIN_INT_DETAILS := l_custom_tbl(p).ADD_PRIN_INT_DETAILS;
                l_amort_tbl(i).ADD_INT_INT_DETAILS  := l_custom_tbl(p).ADD_INT_INT_DETAILS;
                l_amort_tbl(i).PENAL_INT_DETAILS    := l_custom_tbl(p).PENAL_INT_DETAILS;
                l_amort_tbl(i).FUNDED_AMOUNT        := l_custom_tbl(p).FUNDED_AMOUNT;
                l_amort_tbl(i).PERIOD               := l_custom_tbl(p).PERIOD_START_DATE || ' - ' || (l_custom_tbl(p).PERIOD_END_DATE-1);
                l_amort_tbl(i).DISBURSEMENT_AMOUNT  := l_custom_tbl(p).DISBURSEMENT_AMOUNT;

                l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
                l_fee_basis_tbl(1).fee_basis_amount := l_amort_tbl(i).begin_balance + l_amort_tbl(i).UNPAID_PRIN; --fix for bug 6908366
                l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
                l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.requested_amount; --fix for bug 6908366

                l_installment_number := l_amort_tbl(i).installment_number;
                 -- calculate the origination fees
                 if l_installment_number = 1 then

                    if l_new_orig_fee_structures.count > 0 then

                        l_orig_fees_tbl.delete;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
                        lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                                    ,p_installment      => l_installment_number
                                                    ,p_fee_basis_tbl    => l_fee_basis_tbl
                                                    ,p_fee_structures   => l_new_orig_fee_structures
                                                    ,x_fees_tbl         => l_orig_fees_tbl
                                                    ,x_return_status    => l_return_status
                                                    ,x_msg_count        => l_msg_count
                                                    ,x_msg_data         => l_msg_data);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fees_tbl.count);

                        for k in 1..l_orig_fees_tbl.count loop
                            l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
                        end loop;

                    end if;
                 end if;

                 -- calculate the memo fees
                 l_memo_fees_tbl.delete;
                 if l_memo_fee_structures.count > 0 then
                      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for memo fees...');
                      lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                                  ,p_installment      => l_installment_number
                                                  ,p_fee_basis_tbl    => l_fee_basis_tbl
                                                  ,p_fee_structures   => l_memo_fee_structures
                                                  ,x_fees_tbl         => l_memo_fees_tbl
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data);
                      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated memo fees ' || l_memo_fees_tbl.count);

                 end if;

                 -- calculate the recurring fees
                 l_fees_tbl.delete;
                 if l_fee_structures.count > 0 then
                      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for recurring fees...');
                      lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                                  ,p_installment      => l_installment_number
                                                  ,p_fee_basis_tbl    => l_fee_basis_tbl
                                                  ,p_fee_structures   => l_fee_structures
                                                  ,x_fees_tbl         => l_fees_tbl
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data);
                      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated recurring fees ' || l_fees_tbl.count);
                 end if;

                 -- calculate the funding fees
                 l_funding_fees_tbl.delete;
                 if l_funding_fee_structures.count > 0 then
                      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for funding fees...');
                      lns_fee_engine.calculateFees(p_loan_id          => p_loan_id
                                                  ,p_installment      => l_installment_number
                                                  ,p_fee_basis_tbl    => l_fee_basis_tbl
                                                  ,p_fee_structures   => l_funding_fee_structures
                                                  ,x_fees_tbl         => l_funding_fees_tbl
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => l_msg_count
                                                  ,x_msg_data         => l_msg_data);
                      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated funding fees ' || l_fees_tbl.count);
                 end if;

                 for k in 1..l_fees_tbl.count loop
                        l_fee_amount := l_fee_amount + l_fees_tbl(k).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': recurring calculated fees = ' || l_fee_amount);
                 end loop;

                 for j in 1..l_funding_fees_tbl.count loop
                        l_fee_amount := l_fee_amount + l_funding_fees_tbl(j).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding calculated fees = ' || l_fee_amount);
                 end loop;

                 for j in 1..l_memo_fees_tbl.count loop
                        l_other_amount := l_other_amount + l_memo_fees_tbl(j).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': other calculated fees = ' || l_other_amount);
                 end loop;

                 logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': total calculated fees ' || l_fee_amount);
                 l_amort_tbl(i).fee_amount    := l_fee_amount;
                 l_amort_tbl(i).other_amount  := l_other_amount;
                 l_amort_tbl(i).total         := l_amort_tbl(i).principal_amount + l_amort_tbl(i).interest_amount + l_amort_tbl(i).fee_amount + l_amort_tbl(i).other_amount;
                 l_orig_fees_tbl.delete;
                 l_memo_fees_tbl.delete;
                 l_fees_tbl.delete;
                 l_funding_fees_tbl.delete;

            END LOOP;

        end if;

        -- delete predicted records based on ORIGINAL amortization
        if p_based_on_terms = 'CURRENT' and
           l_loan_details.LOAN_STATUS NOT IN ('INCOMPLETE','DELETED','REJECTED','PENDING','APPROVED')
        then

            l_num_records := l_amort_tbl.count;
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - amortization returns # records '|| l_num_records);
            l_last_installment_billed := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT_3(p_loan_id, 'TERM');
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - last installment billed '|| l_last_installment_billed);

            -- copy the records not billed to a temp collection
            m := 0;
            for i in 1..l_num_records
            loop
                if l_amort_tbl(i).installment_number > l_last_installment_billed then
                    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - copying record ' || i);
                    m := m + 1;
                    l_amort_tbl2(m) := l_amort_tbl(i);
                end if;
            end loop;

            -- copy back to original table
            l_amort_tbl.delete;
            m := 0;
            for i in 1..l_amort_tbl2.count
            loop
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - re-copying record ' || i);
                m := m + 1;
                l_amort_tbl(m) := l_amort_tbl2(i);
            end loop;


        end if;

        -- fix for bug 7207609
        if l_amort_tbl.count > 0 then

            -- finally get the manual fees for the 1st record and add them to the total "other Amount"
            -- there has got to be a better way to do this
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - late + manual fee amount is '|| l_manual_fee_amount);
            begin
                open c_manual_fees(p_loan_id, l_last_installment_billed + 1);
                    fetch c_manual_fees into l_manual_fee_amount;
                close c_manual_fees;
            end;

            if l_manual_fee_amount is null then
                   l_manual_fee_amount := 0;
            end if;
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - manual fee amount is '|| l_manual_fee_amount);

            if l_amort_tbl.count > 0 then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': adding fees...');
                l_amort_tbl(1).fee_amount := l_amort_tbl(1).fee_amount + l_manual_fee_amount;
                l_amort_tbl(1).total := l_amort_tbl(1).total + l_manual_fee_amount;
            end if;

        end if;

        x_amort_tbl := l_amort_tbl;
        --
        -- End of API body
        --

        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit) THEN
            COMMIT WORK;
        END IF;

        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO runAmortization_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO runAmortization_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO runAmortization_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

END runAmortization;

/*=========================================================================
 | PUBLIC PROCEDURE termlyPayment
 |
 | DESCRIPTION
||
|| Overview:  number of periods to pay off a loan according to formula
||  periods_to_payoff = [ LN(1-(rate*loanAmount)/(payment*payments_per_period)) /
||                            LN(1 + rate/payments_per_period)]
||
|| Parameter:  p_termly amount = periodic amount to pay
||             p_annual_rate   = annual interest rate on the loan
||             p_loan_amount   = amount of the loan
||             p_payments_per_year = payments @ termly_amount per year
||             p_period_type = 'YEARS', 'QUARTERS', 'MONTHS'
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: number of periods to pay off the loan
||               if return value = -1 then the loan can never be payed off
||               at that termly amount and rate
||
|| KNOWN ISSUES
||
|| NOTES
||      NOTE: INSTALLMENT_NUMBER WILL NOT GET YOU THE GIVEN INSTALLMENT
||            NUMBER CORRESPONDING ON THE LOAN AMORTIZATION SCHEDULE
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/11/2003 6:42PM     raverma           Created
||
 *=======================================================================*/
function termlyPayment(p_termly_amount     in number
                      ,p_annual_rate       in number
                      ,p_loan_amount       in number
                      ,p_payments_per_year in number
                      ,p_period_type       in varchar2) return number
is
  l_periodic_rate number;
  l_num_periods   number;
  l_api_name      varchar2(15);

begin

     l_api_name := 'termlyPayment';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

     l_periodic_rate := p_annual_rate / 100;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': periodic rate: ' || l_periodic_rate);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': termly amount: ' || p_termly_amount);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': payments per year: ' || p_payments_per_year);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': loan amount : ' || p_loan_amount);

     if l_periodic_rate <> 0 then
        -- we cannot have LN < 0
        -- this will be a loan that will never be paid off
        if ( l_periodic_rate * p_loan_amount ) / (p_payments_per_year * p_termly_amount) >= 1 then
             FND_MESSAGE.Set_Name('LNS', 'LNS_NEVER_PAYOFF');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_rate * p_loan_amount :' || l_periodic_rate * p_loan_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_payments_per_year * p_termly_amount : ' || p_payments_per_year * p_termly_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': LN(1-a/b) : ' || LN(1 - ( ( l_periodic_rate * p_loan_amount ) / (p_payments_per_year * p_termly_amount))));
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_rate / p_payments_per_year : ' || l_periodic_rate / p_payments_per_year);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': LN(1+d) : ' || LN(1 + (l_periodic_rate / p_payments_per_year)));
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': - p_payments_per_year : ' || (- p_payments_per_year));

        l_num_periods := (LN(1 - ( ( l_periodic_rate * p_loan_amount ) / (p_payments_per_year * p_termly_amount))) /
                           LN(1 + (l_periodic_rate / p_payments_per_year))) / (- p_payments_per_year) ;
     else
        l_num_periods := p_loan_amount / p_termly_amount / p_payments_per_year;

     end if;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': num years to pay off = ' || l_num_periods);

     if p_period_type = 'MONTHS' then
        l_num_periods := l_num_periods * 12;

     elsif p_period_type = 'QUARTERS' then
        l_num_periods := l_num_periods * 4;

     elsif p_period_type = 'YEARS' then
        null;

     end if;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

     return l_num_periods;

Exception

    When FND_API.G_EXC_ERROR then
        return -1;

    When others then
        return -1;

end termlyPayment;

/*=========================================================================
|| PUBLIC PROCEDURE preProcessInstallment
||
|| DESCRIPTION
||
|| Overview:  this procedure will recalculate an installment for reamortization
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter:  p_loan_id => in loanID
||             p_installment_number = FLAG to notify to get the
||                                    latest installment
||
|| Return value: AMORTIZATION_REC => contains billing and payment information
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||      NOTE: api used by Billing Engine
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 03/12/2004 12:40PM     raverma           Created
||
 *=======================================================================*/
procedure preProcessInstallment(p_api_version        IN NUMBER
                               ,p_init_msg_list      IN VARCHAR2
                               ,p_commit             IN VARCHAR2
                               ,p_loan_ID            IN NUMBER
                               ,p_installment_number IN NUMBER
                               ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                               ,x_return_status      OUT NOCOPY VARCHAR2
                               ,x_msg_count          OUT NOCOPY NUMBER
                               ,x_msg_data           OUT NOCOPY VARCHAR2)
is
  l_amortization_rec      LNS_FINANCIALS.AMORTIZATION_REC;
  l_amort_tbl             LNS_FINANCIALS.AMORTIZATION_TBL;
  l_count                 NUMBER;
  l_api_name              varchar2(40);
  l_loan_details          LNS_FINANCIALS.LOAN_DETAILS_REC;

  l_theoretical_balance   NUMBER;
  l_actual_balance        NUMBER;
  l_api_version_number    number;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(32767);
  l_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;  -- define what event(s) we are processing fees for
  l_fees_tbl              LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_overdue_amount        number;
  i                       number;
  l_due_date              date;
  l_installment           number;
  l_arr_pos               number;

  -- this is for get custom dates
   cursor c_customized (p_loan_id number) is
   SELECT nvl(h.custom_payments_flag, 'N')
     FROM lns_loan_headers_all h
    WHERE loan_id = p_loan_id;

    cursor c_customSchedule(p_loan_id number, p_installment number) is
    select payment_number            installment_number
          ,due_date                  due_date
     from lns_custom_paymnt_scheds
    where loan_id = p_loan_id
      and payment_number = p_installment;

begin

      l_api_name           := 'preProcessInstallment';
      l_api_version_number := 1;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan id ' || p_loan_id);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - instalment# ' || p_installment_number);

      -- Standard Start of API savepoint
      SAVEPOINT preProcessInstallment;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                          l_api_name, G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Api body
      -- get the loan details
      -- compare the actual balance to the theoretical balance
      -- if they are inconsistent and reamorization flag is set
      -- then insert reamortization information into LNS_AMORTIZATION_SCHEDS
/*
      if p_installment_number = 0 then
        i := p_installment_number + 1;
      else
        i := p_installment_number;
      end if;
*/
      l_loan_details  := lns_financials.getLoanDetails(p_loan_Id         => p_loan_id
                                                      ,p_based_on_terms  => 'CURRENT'
													  ,p_phase           => 'TERM');

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting next installment info...');
      if l_loan_details.custom_schedule = 'N' then
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - regular loan');

          -- this is a standard non-customized loan
          lns_financials.amortizeLoan(p_loan_Id            => p_loan_id
                                     ,p_based_on_terms     => 'CURRENT'
                                     ,p_installment_number => p_installment_number
                                     ,x_loan_amort_tbl     => l_amort_tbl);
          l_count :=  l_amort_tbl.count;
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' table count is ' || l_count);

          for i in REVERSE 1..l_amort_tbl.count loop
            if p_installment_number = l_amort_tbl(i).INSTALLMENT_NUMBER then
                l_due_date    := l_amort_tbl(i).due_date;
                l_installment := l_amort_tbl(i).installment_number;
                exit;
            end if;
          end loop;

      else
          -- we are on a customized loan
          -- check if this is 0th installment or not
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - custom loan');
          if p_installment_number > 0 then
              open c_customSchedule(p_loan_id, p_installment_number);
              fetch c_customSchedule into
                       l_installment
                      ,l_due_date;
              close c_customSchedule;
          else
             -- we are on 0th installment
             l_installment := p_installment_number;
             l_due_date    := l_loan_details.loan_start_date;
          end if;
      end if;

      -- assign to output record
        l_amortization_rec.installment_number := l_installment;
        l_amortization_rec.due_date           := l_due_date;
      --l_amortization_rec.principal_amount     := l_amort_tbl(i).principal_amount;
      --l_amortization_rec.interest_amount      := l_amort_tbl(i).interest_amount;
      --l_amortization_rec.fee_amount           := l_amort_tbl(i).fee_amount;
      --l_amortization_rec.other_amount         := l_amort_tbl(i).other_amount;
      --l_amortization_rec.total                := l_amort_tbl(i).total;
      --l_amortization_rec.begin_balance        := l_amort_tbl(i).begin_balance;
      --l_amortization_rec.end_balance          := l_amort_tbl(i).end_balance;
      --l_amortization_rec.principal_cumulative := l_amort_tbl(i).principal_cumulative;
      --l_amortization_rec.interest_cumulative  := l_amort_tbl(i).interest_cumulative;
      --l_amortization_rec.fees_cumulative      := l_amort_tbl(i).fees_cumulative;
      --l_amortization_rec.other_cumulative     := l_amort_tbl(i).other_cumulative;
      --l_amortization_rec.rate_id              := l_amort_tbl(i).rate_id;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' next installment due: ' || l_amortization_rec.installment_number);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' next due date: ' || l_amortization_rec.due_date);

      -- get theoretical balance
	  -- bug# 5664316 - remove installment number check
      if l_loan_details.reamortize_overpay = 'Y' and
         l_loan_details.custom_schedule = 'N' -- fix for bug 6902221
      then --and p_installment_number > 1  then

           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - checking if we need to reamortize...');

           lns_financials.amortizeLoan(p_loan_Id            => p_loan_id
                                     ,p_based_on_terms     => 'ORIGINAL'
                                     ,p_installment_number => p_installment_number
                                     ,x_loan_amort_tbl     => l_amort_tbl);

           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' comparing balances...');
           l_actual_balance      := l_loan_details.remaining_balance;

           if p_installment_number > 0 then

                -- l_arr_pos is array index
                l_arr_pos := p_installment_number;

                -- will get inside if only if there is origination fee
                if l_amort_tbl(1).INSTALLMENT_NUMBER = 0 then
                    l_arr_pos := p_installment_number + 1;
                end if;

                if l_amort_tbl.count < l_arr_pos then
                    l_theoretical_balance := 0;
                else
                    l_theoretical_balance := l_amort_tbl(l_arr_pos).end_balance;
                end if;
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' p_installment_number ' || p_installment_number);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' l_arr_pos ' || l_arr_pos);

           elsif p_installment_number = 0 then
			     -- this check will take care of multiple reAmortizations on 0th installment
		         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' reamortize zero installment');
				 if l_loan_details.reamortize_amount = 0 or l_loan_details.reamortize_amount is null then

		           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' reamortize amount is zero - no previous reamortization ');
				   l_theoretical_balance := l_loan_details.funded_amount;
				 else

		           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' reamortize amount is not zero - previous reamort amount');
				   l_theoretical_balance := l_loan_details.reamortize_amount;
				 end if;
		   end if;

           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' actual balance ' || l_actual_balance);
           logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' theoretical balance ' || l_theoretical_balance);
			-- end bug# 5664316 11-23-2006

           if l_actual_balance < l_theoretical_balance then

              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' REAMORTIZING...');

              -- remove all reAmortize rows from amortization schedule
              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' removing previous reAmortize rows');

              delete
              from lns_amortization_scheds
              where loan_id = p_loan_id
              and reamortization_amount is not null
              and reamortize_from_installment is not null;

              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' REAMORTIZE OVERPAY LOAN');
              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' insert record into amortizations');
              insert into LNS_AMORTIZATION_SCHEDS(amortization_schedule_id
                                                 ,loan_id
                                                 ,reamortization_amount
                                                 ,reamortize_from_installment
                                                 ,reamortize_to_installment
                                                 ,created_by
                                                 ,creation_date
                                                 ,last_updated_by
                                                 ,last_update_date
                                                 ,object_version_number)
                                                 values
                                                 (LNS_AMORTIZATION_SCHEDS_S.NEXTVAL
                                                 ,p_loan_id
                                                 ,l_actual_balance
                                                 ,p_installment_number
                                                 ,null
                                                 ,lns_utility_pub.created_by
                                                 ,lns_utility_pub.creation_date
                                                 ,lns_utility_pub.last_updated_by
                                                 ,lns_utility_pub.last_update_date
                                                 ,1);
           -- bug #3718480
           -- we will need to credit out all unpaid principal documents
           /*
           elsif l_loan_details.reamortize_underpay = 'Y' and l_actual_balance > l_theoretical_balance then
              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' REAMORTIZE UNDERPAY LOAN');
              logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' insert record into amortizations');
              insert into LNS_AMORTIZATION_SCHEDS(amortization_schedule_id
                                                 ,loan_id
                                                 ,reamortization_amount
                                                 ,reamortize_from_installment
                                                 ,reamortize_to_installment
                                                 ,created_by
                                                 ,creation_date
                                                 ,last_updated_by
                                                 ,last_update_date
                                                 ,object_version_number)
                                                 values
                                                 (LNS_AMORTIZATION_SCHEDS_S.NEXTVAL
                                                 ,p_loan_id
                                                 ,l_actual_balance
                                                 ,p_installment_number
                                                 ,null
                                                 ,lns_utility_pub.created_by
                                                 ,lns_utility_pub.creation_date
                                                 ,lns_utility_pub.last_updated_by
                                                 ,lns_utility_pub.last_update_date
                                                 ,1);
           */
           else
               logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' WILL NOT REAMORTIZE!');
           end if;
      end if;

      -- processFees for servicing
      x_amortization_rec := l_amortization_rec;

      --
      -- End of API body
      -- ---------------------------------------------------------------

      -- Standard check for p_commit
      IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO preProcessInstallment;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO preProcessInstallment;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
          ROLLBACK TO preProcessInstallment;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end preProcessInstallment;

/*=========================================================================
|| PUBLIC PROCEDURE preProcessOpenInstallment
||
|| DESCRIPTION
||
|| Overview:  this procedure will preProcess an installment
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter:  p_loan_id => in loanID
||             p_installment_number = FLAG to notify to get the
||                                    latest installment
||
|| Return value: AMORTIZATION_REC => contains billing and payment information
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||      NOTE: api used by Billing Engine
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 03/12/2004 12:40PM     raverma           Created
||
 *=======================================================================*/
procedure preProcessOpenInstallment(p_init_msg_list      IN VARCHAR2
                                   ,p_commit             IN VARCHAR2
                                   ,p_loan_ID            IN NUMBER
                                   ,p_installment_number IN NUMBER
                                   ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                                   ,x_return_status      OUT NOCOPY VARCHAR2
                                   ,x_msg_count          OUT NOCOPY NUMBER
                                   ,x_msg_data           OUT NOCOPY VARCHAR2)
is
  l_amortization_rec      LNS_FINANCIALS.AMORTIZATION_REC;
  l_count                 NUMBER;
  l_api_name              varchar2(40);
  l_loan_details          LNS_FINANCIALS.LOAN_DETAILS_REC;

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(32767);
  l_fees_tbl              LNS_FINANCIALS.FEES_TBL;
  i                       number;
  l_installment           number;

begin

      l_api_name           := 'preProcessOpenInstallment';
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan id ' || p_loan_id);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - instalment# ' || p_installment_number);

      -- Standard Start of API savepoint
      SAVEPOINT preProcessOpenInstallment;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- ---------------------------------------------------------------
      -- Beginning of API body
      --
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting loan details');
      l_loan_details  := lns_financials.getLoanDetails(p_loan_Id            => p_loan_id
                                                      ,p_based_on_terms     => 'CURRENT'
													  ,p_phase              => 'OPEN');

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting Open Installment');
      lns_financials.getOpenInstallment(p_init_msg_list      => 'T'
                                       ,p_loan_ID            => p_loan_ID
                                       ,p_installment_number => p_installment_number
                                       ,x_fees_tbl           => l_fees_tbl
                                       ,x_amortization_rec   => l_amortization_rec
                                       ,x_return_status      => l_return_Status
                                       ,x_msg_count          => l_msg_count
                                       ,x_msg_data           => l_msg_data);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           FND_MESSAGE.SET_NAME('LNS', 'LNS_PROCESS_FEE_ERROR');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
      end if;

      -- processFees for servicing
      x_amortization_rec := l_amortization_rec;

      --
      -- End of API body
      -- ---------------------------------------------------------------

      -- Standard check for p_commit
      IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO preProcessOpenInstallment;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO preProcessOpenInstallment;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
          ROLLBACK TO preProcessOpenInstallment;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
          logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end preProcessOpenInstallment;


/*=========================================================================
|| PUBLIC PROCEDURE getInstallment
||
|| DESCRIPTION
||
|| Overview:  returns interest and principal for a single installment
||            this is used for the billing concurrent program
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter:  p_loan_id => in loanID
||             p_installment_number = FLAG to notify to get the
||                                    latest installment
||
|| Return value: AMORTIZATION_REC => contains billing and payment information
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||      NOTE: api used by Billing Engine
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/11/2003 12:40PM     raverma           Created
||
 *=======================================================================*/
procedure getInstallment(p_api_version        IN NUMBER
                        ,p_init_msg_list      IN VARCHAR2
                        ,p_commit             IN VARCHAR2
                        ,p_loan_Id            in number
                        ,p_installment_number in number
                        ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                        ,x_fees_tbl           OUT NOCOPY LNS_FINANCIALS.FEES_TBL
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER
                        ,x_msg_data           OUT NOCOPY VARCHAR2)
is
  l_amortization_rec      LNS_FINANCIALS.AMORTIZATION_REC;
  l_amortization_tbl      LNS_FINANCIALS.AMORTIZATION_TBL;
  l_loan_details          LNS_FINANCIALS.LOAN_DETAILS_REC;
  l_count                 NUMBER;
  l_api_version_number    number;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(32767);
  l_api_name              varchar2(25);
  l_fees_tbl              LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_fees_tbl_1            LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_fees_tbl_2            LNS_FINANCIALS.FEES_TBL;
  l_total_fees            number;
  l_fee_basis_tbl         LNS_FEE_ENGINE.FEE_BASIS_TBL;
  l_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;  -- define what event(s) we are processing fees for
  i                       number;
  --l_begin_balance         number;       -- used for fees calculation
  l_customized            varchar2(1);
  l_loan_start_date       date;
  l_funded_amount         number;
  l_custom_tbl            LNS_CUSTOM_PUB.CUSTOM_TBL;
  l_AMORT_METHOD          varchar2(30);

  /* query custom amortization */
  CURSOR cust_amort_cur(P_LOAN_ID number, P_PAYMENT_NUMBER number) IS
      select
          cust.DUE_DATE
          ,nvl(cust.PRINCIPAL_AMOUNT, 0)
          ,nvl(cust.INTEREST_AMOUNT, 0)
          ,cust.installment_begin_balance
          ,cust.installment_end_balance
          --cust.FEE_AMOUNT
      from LNS_CUSTOM_PAYMNT_SCHEDS cust
      where cust.LOAN_ID = P_LOAN_ID and
          cust.PAYMENT_NUMBER = P_PAYMENT_NUMBER;

begin

    l_api_version_number    := 1;
    l_api_name              := 'getInstallment';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan id ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - instalment# ' || p_installment_number);

    -- Standard Start of API savepoint
    SAVEPOINT getInstallment;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- --------------------------------------------------------------------
    -- Api body
    -- --------------------------------------------------------------------
    l_total_fees                         := 0;
    l_amortization_rec.principal_amount  := 0;
    l_amortization_rec.interest_amount   := 0;
    l_amortization_rec.total             := 0;
    l_amortization_rec.fee_amount        := 0;
    l_amortization_rec.other_amount      := 0;
    l_amortization_rec.begin_balance     := 0;
    l_amortization_rec.end_balance       := 0;

    -- move logic for billing custom loans into FINANCIALS API
    l_loan_Details := lns_financials.getLoanDetails(p_loan_id, 'CURRENT', 'TERM');

    if l_loan_details.custom_schedule = 'N' then

        if l_loan_details.reamortize_overpay = 'Y' then
            -- preProcess will add a re-amortization row if the remaining amount < funded amount
            -- bug# 5664316 11-23-2006
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - preProcess the loan');
            preProcessInstallment(p_api_version    => 1.0
                ,p_init_msg_list  => p_init_msg_list
                ,p_commit         => p_commit
                ,p_loan_ID        => p_loan_id
                ,p_installment_number => lns_billing_util_pub.last_payment_number(p_loan_id)
                ,x_amortization_rec => l_amortization_rec
                ,x_return_status  => l_return_status
                ,x_msg_count      => l_msg_count
                ,x_msg_data       => l_msg_data);
        end if;

        lns_financials.amortizeLoan(p_loan_Id            => p_loan_id
                                   ,p_installment_number => p_installment_number
                                   ,p_based_on_terms     => 'CURRENT'
                                   ,x_loan_amort_tbl     => l_amortization_tbl);

        for p in 1..l_amortization_tbl.count loop
            if l_amortization_tbl(p).installment_number = p_installment_number then
                l_amortization_rec := l_amortization_tbl(p);
                exit;
            end if;
        end loop;

/*
        l_amortization_rec.installment_number   := l_amortization_tbl(i).installment_number;
        l_amortization_rec.due_date             := l_amortization_tbl(i).due_date;
        l_amortization_rec.principal_amount     := l_amortization_tbl(i).principal_amount;
        l_amortization_rec.interest_amount      := l_amortization_tbl(i).interest_amount;
        l_amortization_rec.total                := l_amortization_tbl(i).total;
        l_amortization_rec.fee_amount           := l_amortization_tbl(i).fee_amount;
        l_amortization_rec.other_amount         := l_amortization_tbl(i).other_amount;
        l_amortization_rec.begin_balance        := l_amortization_tbl(i).begin_balance;
        l_amortization_rec.end_balance          := l_amortization_tbl(i).end_balance;
        l_amortization_rec.interest_cumulative  := l_amortization_tbl(i).interest_cumulative;
        l_amortization_rec.principal_cumulative := l_amortization_tbl(i).principal_cumulative;
        l_amortization_rec.other_cumulative     := l_amortization_tbl(i).other_cumulative;
        l_amortization_rec.rate_id              := l_amortization_tbl(i).rate_id;
        l_amortization_rec.rate_unadj           := l_amortization_tbl(i).rate_unadj;
        l_amortization_rec.RATE_CHANGE_FREQ     := l_amortization_tbl(i).RATE_CHANGE_FREQ;
*/
    else -- this is a customized loan

        if p_installment_number > 0 then
/*
            open cust_amort_cur(p_loan_id, p_installment_number);
            fetch cust_amort_cur into
                 l_amortization_rec.due_date
                ,l_amortization_rec.principal_amount
                ,l_amortization_rec.interest_amount
                ,l_amortization_rec.begin_balance
                ,l_amortization_rec.end_balance;

            close cust_amort_cur;
*/
             -- load custom schedule
            LNS_CUSTOM_PUB.loadCustomSchedule(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_TRUE,
                P_COMMIT		        => FND_API.G_FALSE,
                P_VALIDATION_LEVEL	    => FND_API.G_VALID_LEVEL_FULL,
                P_LOAN_ID               => p_loan_id,
                P_BASED_ON_TERMS        => 'CURRENT',
                X_AMORT_METHOD          => l_AMORT_METHOD,
                X_CUSTOM_TBL            => l_custom_tbl,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

            IF l_return_status <> 'S' THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            for p in 1..l_custom_tbl.count loop

                if l_custom_tbl(p).PAYMENT_NUMBER = p_installment_number then
                    l_amortization_rec.installment_number   := l_custom_tbl(p).PAYMENT_NUMBER;
                    l_amortization_rec.due_date             := l_custom_tbl(p).DUE_DATE;
                    l_amortization_rec.PERIOD_START_DATE    := l_custom_tbl(p).PERIOD_START_DATE;
                    l_amortization_rec.PERIOD_END_DATE      := l_custom_tbl(p).PERIOD_END_DATE;
                    l_amortization_rec.principal_amount     := l_custom_tbl(p).PRINCIPAL_AMOUNT;
                    l_amortization_rec.interest_amount      := l_custom_tbl(p).INTEREST_AMOUNT;
                    l_amortization_rec.begin_balance        := l_custom_tbl(p).INSTALLMENT_BEGIN_BALANCE;
                    l_amortization_rec.end_balance          := l_custom_tbl(p).INSTALLMENT_END_BALANCE;
                    l_amortization_rec.UNPAID_PRIN          := l_custom_tbl(p).UNPAID_PRIN;
                    l_amortization_rec.UNPAID_INT           := l_custom_tbl(p).UNPAID_INT;
                    l_amortization_rec.INTEREST_RATE        := l_custom_tbl(p).INTEREST_RATE;
                    l_amortization_rec.NORMAL_INT_AMOUNT    := l_custom_tbl(p).NORMAL_INT_AMOUNT;
                    l_amortization_rec.ADD_PRIN_INT_AMOUNT  := l_custom_tbl(p).ADD_PRIN_INT_AMOUNT;
                    l_amortization_rec.ADD_INT_INT_AMOUNT   := l_custom_tbl(p).ADD_INT_INT_AMOUNT;
                    l_amortization_rec.PENAL_INT_AMOUNT     := l_custom_tbl(p).PENAL_INT_AMOUNT;
                    l_amortization_rec.FUNDED_AMOUNT        := l_custom_tbl(p).FUNDED_AMOUNT;
                    l_amortization_rec.PERIOD               := l_custom_tbl(p).PERIOD_START_DATE || ' - ' || (l_custom_tbl(p).PERIOD_END_DATE-1);
                    l_amortization_rec.DISBURSEMENT_AMOUNT  := l_custom_tbl(p).DISBURSEMENT_AMOUNT;
                    exit;
                end if;
            end loop;
        else
             l_amortization_rec.begin_balance      := l_loan_details.funded_amount;
             l_amortization_rec.due_date           := l_loan_details.loan_start_date;
             l_amortization_rec.installment_number := p_installment_number;
        end if;
    end if;

    -- bug # 3839974
    if l_amortization_rec.principal_amount > l_loan_details.unbilled_principal then
        l_amortization_rec.principal_amount     := l_loan_details.unbilled_principal;
        l_amortization_rec.principal_cumulative := l_amortization_rec.principal_cumulative - l_amortization_rec.principal_amount + l_loan_details.unbilled_principal;
    end if;

    if p_installment_number > 0 then
        -- add the recurring fees for the installment onto the fee schedule

        l_fee_structures(1).fee_category := 'RECUR';
        l_fee_structures(1).fee_type     := null;

        -- only 2 types of fee basis are valid for RECURRING FEE
        l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
        l_fee_basis_tbl(1).fee_basis_amount := l_amortization_rec.begin_balance + l_amortization_rec.UNPAID_PRIN;
        l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
        l_fee_basis_tbl(2).fee_basis_amount := l_loan_details.requested_amount;
        l_fee_basis_tbl(3).fee_basis_name   := 'OVERDUE_PRIN';
--        l_fee_basis_tbl(3).fee_basis_amount := l_amortization_rec.principal_amount;
        l_fee_basis_tbl(3).fee_basis_amount := l_amortization_rec.UNPAID_PRIN;
        l_fee_basis_tbl(4).fee_basis_name   := 'OVERDUE_PRIN_INT';
--        l_fee_basis_tbl(4).fee_basis_amount := l_amortization_rec.principal_amount + l_amortization_rec.interest_amount;
        l_fee_basis_tbl(4).fee_basis_amount := l_amortization_rec.UNPAID_PRIN + l_amortization_rec.UNPAID_INT;

        lns_fee_engine.processFees(p_init_msg_list      => FND_API.G_FALSE
                                  ,p_commit             => FND_API.G_FALSE
                                  ,p_loan_id            => p_loan_id
                                  ,p_installment_number => p_installment_number
                                  ,p_fee_basis_tbl      => l_fee_basis_tbl
                                  ,p_fee_structures     => l_fee_structures
                                  ,x_fees_tbl           => l_fees_tbl
                                  ,x_return_status      => l_return_Status
                                  ,x_msg_count          => l_msg_count
                                  ,x_msg_data           => l_msg_data);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_PROCESS_FEE_ERROR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    -- 12-21-2004 raverma added for lns.b
		-- only get the dis
    lns_fee_engine.getFeeSchedule(p_init_msg_list      => FND_API.G_FALSE
                                 ,p_loan_id            => p_loan_id
                                 ,p_installment_number => p_installment_number
								 ,p_disb_header_id     => null
                                 ,p_phase              => 'TERM'
                                 ,x_fees_tbl           => l_fees_tbl_1
                                 ,x_return_status      => l_return_status
                                 ,x_msg_count          => l_msg_count
                                 ,x_msg_data           => l_msg_data);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_READ_FEE_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    for k in 1..l_fees_tbl_1.count loop
        l_fees_tbl_2(k).FEE_ID            := l_fees_tbl_1(k).FEE_ID;
        l_fees_tbl_2(k).FEE_NAME          := l_fees_tbl_1(k).FEE_NAME;
        l_fees_tbl_2(k).FEE_AMOUNT        := l_fees_tbl_1(k).FEE_AMOUNT;
        l_fees_tbl_2(k).FEE_INSTALLMENT   := l_fees_tbl_1(k).FEE_INSTALLMENT;
        l_fees_tbl_2(k).FEE_DESCRIPTION   := l_fees_tbl_1(k).FEE_DESCRIPTION;
        l_fees_tbl_2(k).FEE_SCHEDULE_ID   := l_fees_tbl_1(k).FEE_SCHEDULE_ID;
        l_fees_tbl_2(k).FEE_WAIVABLE_FLAG := l_fees_tbl_1(k).FEE_WAIVABLE_FLAG;
        l_fees_tbl_2(k).WAIVE_AMOUNT      := l_fees_tbl_1(k).WAIVE_AMOUNT;
        l_fees_tbl_2(k).BILLED_FLAG       := l_fees_tbl_1(k).BILLED_FLAG;
        l_fees_tbl_2(k).ACTIVE_FLAG       := l_fees_tbl_1(k).ACTIVE_FLAG;
        l_total_fees                      := l_total_fees + l_fees_tbl_1(k).FEE_AMOUNT;
    end loop;

    -- overwrite amortization record returned from amortizationAPI
    l_amortization_rec.fee_amount := l_total_fees;
    x_fees_tbl                    := l_fees_tbl_2;
    x_amortization_rec            := l_amortization_rec;
    -- --------------------------------------------------------------------
    -- End of API body
    -- --------------------------------------------------------------------

    -- Standard check for p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO getInstallment;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO getInstallment;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO getInstallment;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end getInstallment;


-- created for bug 6599682: EQUALLY SPREAD PRINCIPAL FROM IO PERIODS FOR EPRP LOANS
function get_num_non_ro_instal(p_rate_schedule      in  LNS_FINANCIALS.RATE_SCHEDULE_TBL
                               ,p_from_installment in NUMBER
                               ,p_to_installment in NUMBER) return NUMBER
is
    l_local_rate_schedule   LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_num_non_ro_payments   number;
    l_total_installments    number;
    i                       number;
    j                       number;
    l_api_name              varchar2(30);
    l_from_installment      number;

begin

    l_api_name := 'get_num_non_ro_instal';
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_from_installment=' || p_from_installment);

    l_from_installment := p_from_installment;
    if (l_from_installment is null or l_from_installment = 0) then
        l_from_installment := 1;
    end if;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_from_installment=' || l_from_installment);

    -- build normal rate schedule table
    for i in 1..p_rate_schedule.count loop

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'rate schedule row ' || i || ': from ' || p_rate_schedule(i).BEGIN_INSTALLMENT_NUMBER || ' to ' || p_rate_schedule(i).END_INSTALLMENT_NUMBER);

        for j in p_rate_schedule(i).BEGIN_INSTALLMENT_NUMBER..p_rate_schedule(i).END_INSTALLMENT_NUMBER loop

            l_local_rate_schedule(j) := p_rate_schedule(i);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'adding local rate schedule row ' || j);

        end loop;

    end loop;

    l_num_non_ro_payments := 0;
    l_total_installments := l_local_rate_schedule.count;

    if p_to_installment is not null then
        l_total_installments := p_to_installment;
    end if;

    for i in l_from_installment..l_total_installments loop

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'local rate schedule row ' || i || ': IO ' || l_local_rate_schedule(i).INTEREST_ONLY_FLAG);

        if (l_local_rate_schedule(i).INTEREST_ONLY_FLAG = 'N' or i = l_total_installments) then
            l_num_non_ro_payments := l_num_non_ro_payments + 1;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_num_non_ro_payments ' || l_num_non_ro_payments);
        end if;

    end loop;

    if (l_num_non_ro_payments = 0) then
        l_num_non_ro_payments := 1;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Result num_payments ' || l_num_non_ro_payments);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - END');

    return l_num_non_ro_payments;

end;



/*=========================================================================
|| PUBLIC PROCEDURE getOpenInstallment
||
|| DESCRIPTION
||
|| Overview:  returns interest for an installment during openend loan
||            this is used for the billing concurrent program
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter:  p_loan_id => in loanID
||             p_installment_number = installment
||
|| Return value: AMORTIZATION_REC => contains billing and payment information
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||      NOTE: api used by Billing Engine
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/11/2003 12:40PM     raverma           Created
||
 *=======================================================================*/
procedure getOpenInstallment(p_init_msg_list      IN VARCHAR2
                            ,p_loan_Id            in number
                            ,p_installment_number in number
                            ,x_amortization_rec   OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_REC
                            ,x_fees_tbl           OUT NOCOPY LNS_FINANCIALS.FEES_TBL
                            ,x_return_status      OUT NOCOPY VARCHAR2
                            ,x_msg_count          OUT NOCOPY NUMBER
                            ,x_msg_data           OUT NOCOPY VARCHAR2)
is
  l_amortization_rec      LNS_FINANCIALS.AMORTIZATION_REC;
  l_loan_details          LNS_FINANCIALS.LOAN_DETAILS_REC;
  l_payment_tbl           LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
	l_rate_schedule_tbl     LNS_FINANCIALS.RATE_SCHEDULE_TBL;
	l_rates_tbl             LNS_FINANCIALS.RATE_SCHEDULE_TBL;
  l_rate_details          LNS_FINANCIALS.INTEREST_RATE_REC;
    l_amortization_tbl      LNS_FINANCIALS.AMORTIZATION_TBL;

  l_count                 NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(32767);
  l_api_name              varchar2(25);

  l_fees_tbl              LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_fees_tbl_1            LNS_FEE_ENGINE.FEE_CALC_TBL;
  l_fees_tbl_2            LNS_FINANCIALS.FEES_TBL;
  l_total_fees            number;
  l_fee_basis_tbl         LNS_FEE_ENGINE.FEE_BASIS_TBL;
  l_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;  -- define what event(s) we are processing fees for
  i                       number;
	m	                      number;
	l_wtd_balance						number;
	l_periodic_rate					number;
  l_annualized_rate       number;       -- needs to be converted to periodic rate
	l_periodic_interest     number;
	l_periodic_principal	  number;
	l_installments          number;
	l_weigted_rate          number;
	l_days_at_rate					number;
	l_total_days						number;
	l_running_rate					number;
	l_max_date              date;
	l_spread	              number;
	l_rate_schedule_id      number;
	l_rate_to_store         number;
  l_raw_rate              number;
  l_next_rate_change      date;

	cursor c_int_rates(p_rate_id number, p_rate_date date) is
	select interest_rate
   from lns_int_rate_lines
  where start_date_active <= p_rate_date
    and end_date_active >= p_rate_date
    and interest_rate_id = p_rate_id;

	cursor c_rate_info(p_loan_id number) is
	select spread
				,rate_id
		from lns_rate_schedules rs
				,lns_terms t
		where t.loan_id = p_loan_id
		  and t.term_id = rs.term_id
      and phase = 'OPEN';
begin

    l_api_name              := 'getOpenInstallment';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - loan id ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - instalment# ' || p_installment_number);

    -- Standard Start of API savepoint
    SAVEPOINT getOpenInstallment;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- --------------------------------------------------------------------
    -- Api body
    -- --------------------------------------------------------------------
    l_total_fees                         := 0;
    l_amortization_rec.principal_amount  := 0;
    l_amortization_rec.interest_amount   := 0;
    l_amortization_rec.total             := 0;
    l_amortization_rec.fee_amount        := 0;
    l_amortization_rec.begin_balance     := 0;
    l_amortization_rec.end_balance       := 0;

    -- move logic for billing custom loans into FINANCIALS API
    l_loan_Details := lns_financials.getLoanDetails(p_loan_id, 'CURRENT', 'OPEN');
    l_rates_tbl     := lns_financials.getRateSchedule(p_loan_id, 'OPEN');

    -- call projection API
    lns_financials.loanProjection(p_loan_details     => l_loan_Details
                                ,p_based_on_terms  => 'CURRENT'
                                ,p_rate_schedule    => l_rates_tbl
                                ,x_loan_amort_tbl   => l_amortization_tbl);

    for p in 1..l_amortization_tbl.count loop
        if l_amortization_tbl(p).installment_number = p_installment_number then
            l_amortization_rec := l_amortization_tbl(p);
            exit;
        end if;
    end loop;

/*
		-- 0. buildPaymentSchedule
		-- 1. calculate wtd balance
		-- 2. calculateInterest
		-- 3. return record
    l_payment_tbl := lns_fin_utils.buildPaymentSchedule(p_loan_start_date    => l_loan_Details.loan_start_date
                                                       ,p_loan_maturity_date => l_loan_details.maturity_date
                                                       ,p_first_pay_date     => l_loan_details.first_payment_date
                                                       ,p_num_intervals      => l_loan_details.number_installments
                                                       ,p_interval_type      => l_loan_details.payment_frequency
                                                       ,p_pay_in_arrears     => l_loan_details.pay_in_arrears_boolean);

		-- get the weighted balance for the period
		begin
		l_wtd_balance := lns_financials.getWeightedBalance(p_loan_id          => p_loan_id
                                                      ,p_from_date        => l_payment_tbl(1).period_begin_date
                                                      ,p_to_date          => l_payment_tbl(p_installment_number).period_end_date
                                                      ,p_calc_method      => 'ACTUAL'
                                                      ,p_phase            => 'OPEN'
                                                      ,p_day_count_method => l_loan_Details.day_count_method);
		exception
		  when others then
         FND_MESSAGE.SET_NAME('LNS', 'LNS_COMPUTE_BALANCE_ERROR');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    end;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - l_wtd_balance is ' || l_wtd_balance);

    -- now caculate the interest due for this period
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_wtd_balance);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': period start ' || l_payment_tbl(p_installment_number).period_begin_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': period end ' || l_payment_tbl(p_installment_number).period_end_date);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate type = ' || l_loan_details.rate_type );
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': getting rate details');
    l_rate_details := getRateDetails(p_installment => p_installment_number
                                    ,p_rate_tbl    => l_rates_tbl);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate details ' || l_rate_details.annual_rate);

    l_annualized_rate := l_rate_details.ANNUAL_RATE;

              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_annualized_rate ' || l_annualized_rate);
    l_periodic_rate := lns_financials.getPeriodicRate(p_payment_freq      => l_loan_details.payment_frequency
                                                     ,p_period_start_date => l_payment_tbl(p_installment_number).period_begin_date
                                                     ,p_period_end_date   => l_payment_tbl(p_installment_number).period_end_date
                                                     ,p_annualized_rate   => l_annualized_rate
                                                     ,p_days_count_method => l_loan_Details.day_count_method
                                                     ,p_target            => 'INTEREST');

    l_periodic_interest := lns_financials.calculateInterest(p_amount             => l_wtd_balance
                                                           ,p_periodic_rate      => l_periodic_rate
                                                           ,p_compounding_period => null);

    l_periodic_interest  := round(l_periodic_interest, l_loan_Details.currency_precision);

		if p_installment_number = l_loan_details.number_installments and
			 (l_loan_details.OPEN_TO_TERM_FLAG = 'N' OR l_loan_details.SECONDARY_STATUS = 'REMAINING_DISB_CANCELLED')	then
		    l_periodic_principal := l_loan_details.funded_amount;
		else
				l_periodic_principal := 0;
		end if;

    -- this information is needed to calculate fees
    -- rest of the record can be built after fees are calculated
    l_amortization_rec.installment_number   := p_installment_number;
    l_amortization_rec.due_date             := l_payment_tbl(p_installment_number).period_due_date;
    l_amortization_rec.principal_amount     := l_periodic_principal;
    l_amortization_rec.interest_amount      := l_periodic_interest;
    l_amortization_rec.INTEREST_RATE        := l_annualized_rate;
    l_amortization_rec.UNPAID_PRIN          := 0;
    l_amortization_rec.UNPAID_INT           := 0;
    l_amortization_rec.NORMAL_INT_AMOUNT    := l_periodic_interest;
    l_amortization_rec.ADD_PRIN_INT_AMOUNT  := 0;
    l_amortization_rec.ADD_INT_INT_AMOUNT   := 0;
    l_amortization_rec.PENAL_INT_AMOUNT     := 0;
*/


    lns_fee_engine.getFeeSchedule(p_init_msg_list      => FND_API.G_FALSE
                                 ,p_loan_id            => p_loan_id
                                 ,p_installment_number => p_installment_number
								 ,p_disb_header_id     => null
                                 ,p_phase              => 'OPEN'
                                 ,x_fees_tbl           => l_fees_tbl_1
                                 ,x_return_status      => l_return_status
                                 ,x_msg_count          => l_msg_count
                                 ,x_msg_data           => l_msg_data);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_READ_FEE_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    for k in 1..l_fees_tbl_1.count loop
        l_fees_tbl_2(k).FEE_ID            := l_fees_tbl_1(k).FEE_ID;
        l_fees_tbl_2(k).FEE_NAME          := l_fees_tbl_1(k).FEE_NAME;
        l_fees_tbl_2(k).FEE_AMOUNT        := l_fees_tbl_1(k).FEE_AMOUNT;
        l_fees_tbl_2(k).FEE_INSTALLMENT   := l_fees_tbl_1(k).FEE_INSTALLMENT;
        l_fees_tbl_2(k).FEE_DESCRIPTION   := l_fees_tbl_1(k).FEE_DESCRIPTION;
        l_fees_tbl_2(k).FEE_SCHEDULE_ID   := l_fees_tbl_1(k).FEE_SCHEDULE_ID;
        l_fees_tbl_2(k).FEE_WAIVABLE_FLAG := l_fees_tbl_1(k).FEE_WAIVABLE_FLAG;
        l_fees_tbl_2(k).WAIVE_AMOUNT      := l_fees_tbl_1(k).WAIVE_AMOUNT;
        l_fees_tbl_2(k).BILLED_FLAG       := l_fees_tbl_1(k).BILLED_FLAG;
        l_fees_tbl_2(k).ACTIVE_FLAG       := l_fees_tbl_1(k).ACTIVE_FLAG;
        l_total_fees                      := l_total_fees + l_fees_tbl_1(k).FEE_AMOUNT;
    end loop;

    -- overwrite amortization record returned from amortizationAPI
    l_amortization_rec.rate_id         := l_rate_Details.rate_id;
    l_amortization_rec.rate_unadj      := l_annualized_rate;
    l_amortization_rec.RATE_CHANGE_FREQ:= l_loan_details.OPEN_RATE_CHG_FREQ;
    l_amortization_rec.fee_amount      := l_total_fees;
    x_fees_tbl                         := l_fees_tbl_2;
    x_amortization_rec                 := l_amortization_rec;
    -- --------------------------------------------------------------------
    -- End of API body
    -- --------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO getOpenInstallment;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO getOpenInstallment;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO getOpenInstallment;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end getOpenInstallment;

/*=========================================================================
|| PUBLIC PROCEDURE getRatesTable
||
|| DESCRIPTION
||
|| Overview: function will return a table of dates for interest rates
||
|| Parameter: p_index_rate_id => index reference
||            p_index_date    => date to start pulling rates
||            p_rate_change_frequency => frequency of rate changes
||            p_maturity_date  => final date to get rates
||
|| Source Tables:  NA
||
|| Target Tables:
||
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 08/15/2005 11:35AM     raverma           Created
 *=======================================================================*/
function getRatesTable(p_index_rate_id           in number
                      ,p_index_date              in date
                      ,p_rate_change_frequency   in varchar2
                      ,p_maturity_date           in date) return LNS_FINANCIALS.RATE_SCHEDULE_TBL is

 l_intial_date  date;
 l_rate_date    date;
 l_rate         number;
 l_Rates_tbl    LNS_FINANCIALS.RATE_SCHEDULE_TBL;
 i              number;
 l_api_name     varchar2(25);

begin

	l_api_name := 'getRatesTable';

	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
	i := 1;
	l_Rates_tbl(i).begin_date  := p_index_date;
	l_rate_date := p_index_date;
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_index_date ' || p_index_date);
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_rate_change_frequency ' || p_rate_change_frequency);
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_maturity_date ' || p_maturity_date           );
	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_index_rate_id ' || p_index_rate_id           );

  WHILE l_rate_date <= p_maturity_date LOOP
       l_rate_date               := lns_fin_utils.getNextDate(l_rate_date, p_rate_change_frequency, 1);
			 i                         := i + 1;
       l_Rates_tbl(i).begin_date := l_rate_date;
			 --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_rate_date ' || l_rate_date);
  END LOOP;
	/*
	for k in 1..l_Rates_tbl.count loop
				dbms_output.put_line(l_Rates_tbl(k).begin_date);
	end loop;
	 */
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
	return l_Rates_tbl;

end getRatesTable;


-- created for bug 6498771
function get_remain_num_prin_instal(p_payment_tbl in LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL
                                    ,p_from_installment in NUMBER) return NUMBER
is
    l_num_prin_payments     number;
    l_total_installments    number;
    i                       number;
begin

    -- loop throught the amortization schedule and count number of PRIN and PRIN_INT rows
    l_num_prin_payments := 0;
    l_total_installments := p_payment_tbl.count;
    for i in p_from_installment..l_total_installments loop
        if (p_payment_tbl(i).CONTENTS = 'PRIN' or p_payment_tbl(i).CONTENTS = 'PRIN_INT') then
            l_num_prin_payments := l_num_prin_payments + 1;
        end if;
    end loop;

    return l_num_prin_payments;

end;


/*=========================================================================
|| PUBLIC PROCEDURE amortizeSIPLoan
||
|| DESCRIPTION
||
|| Overview: procedure generates seperate interest and principal amortization
||           this is the main calculation API for amortization
||            THIS API WILL BE CALLED FROM 2 PLACES PRIMARILY:
||           1. Amortization UI - when creating a loan
||           2. Billing Engine  - to generate installment bills
||
|| Parameter: p_loan_details  = details of the loan
||            p_rate_schedule = rate schedule for the loan
||            p_installment_number => billing will pass in an installment
||                                    number to generate a billt
||            x_loan_amort_tbl => table of amortization records
||
|| Source Tables:  NA
||
|| Target Tables:  LNS_TEMP_AMORTIZATIONS
||
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
||
|| Date                  Author            Description of Changes
|| 10/08/2007            scherkas          Created: fix for bug 6498771
|| 16/01/2008            scherkas          Fixed bug 6749924
|| 08/04/2008            scherkas          Fixed bug 6945153: change procedure to query past installments
|| 18/06/2008            scherkas          Fixed bug 7184830
 *=======================================================================*/
procedure amortizeSIPLoan(p_loan_details       in  LNS_FINANCIALS.LOAN_DETAILS_REC
                      ,p_rate_schedule      in  LNS_FINANCIALS.RATE_SCHEDULE_TBL
                      ,p_based_on_terms     in  varchar2
                      ,p_installment_number in  number
                      ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL)
is
    l_return_status                  varchar2(1);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(32767);
    -- loan_details
    l_loan_id                        number;
    l_original_loan_amount           number;  -- loan amount
    l_amortized_term                 number;
    l_loan_term                      number;
    l_amortized_term_period          varchar2(30);
    l_amortization_frequency         varchar2(30);
    l_loan_period_number             number;
    l_loan_period_type               varchar2(30);
    l_first_payment_date             date;
    l_pay_in_arrears                 boolean;
    l_payment_frequency              varchar2(30);
    l_day_count_method               varchar2(30);
    l_interest_comp_freq             varchar2(30);
    l_calculation_method             varchar2(30);
    l_reamortize_from_installment    number;
    l_reamortize_amount              number;
    l_annualized_rate                number;  -- annual rate on the loan
--    l_intervals_original             number;
--    l_intervals                      number;
    l_intervals_remaining            number;
--    l_amortization_intervals_orig    number;
--    l_amortization_intervals_rem     number;
--    l_amortization_intervals         number;  -- number of intervals to amortize over
    l_rate_details                   LNS_FINANCIALS.INTEREST_RATE_REC;
    l_current_rate_id                number;
    l_previous_rate_id               number;
    l_precision                      number;

    l_period_start_Date              date;
    l_period_end_date                date;
    l_periodic_rate                  number;
    l_maturity_date                  date;
    l_amortized_maturity_date        date;

    l_amortization_rec               LNS_FINANCIALS.AMORTIZATION_REC;
    l_amortization_tbl               LNS_FINANCIALS.AMORTIZATION_TBL;
    l_rate_tbl                       LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    --l_pay_dates                      LNS_FINANCIALS.DATE_TBL;
    l_payment_tbl                    LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_principal_tbl                  LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_loan_start_date                date;
    l_num_pay_dates                  number;  -- number of dates on installment schedule
    l_periodic_payment               number;
    l_periodic_principal             number;
    l_periodic_interest              number;
    l_interest_based_on_amount       number;  -- do we calculate interest from actual or predicted remaining balance
    l_pay_date                       date;
    l_total_principal                number;
    l_payment_number                 number;
    l_fee_amount                     number;
    l_fee_amount1                    number;
    l_other_amount                   number;
    l_begin_balance                  number;
    l_end_balance                    number;
    l_unbilled_principal             number;
    l_unpaid_principal               number;
    l_unpaid_interest                number;

    l_remaining_balance_actual       number;
    l_remaining_balance_theory       number;
    l_total                          number;
    l_interest_cumulative            number;
    l_principal_cumulative           number;
    l_fees_cumulative                number;
    l_other_cumulative               number;
    i                                number;
    l_installment_number             number;
    l_billing                        boolean;  -- switch to notify if billing is calling API
    l_api_name                       varchar2(20);
    l_last_installment_billed        number;
    l_rate_to_calculate              number;
    l_previous_annualized            number;
    l_interest_only_flag             varchar2(1);
    l_calc_method                    varchar2(30);
    l_compound_freq                  varchar2(30);
    l_interest                       number;
    l_hidden_cumul_interest          number;
    l_num_prin_payments              number;
    l_hidden_periodic_prin           number;
    l_prin_first_pay_date            date;
    l_prin_payment_frequency         varchar2(30);
    l_prin_intervals                 number;
    l_prin_pay_in_arrears            boolean;
    l_prin_amortized_intervals       number;
    l_prin_intervals_diff            number;
    l_remaining_balance_actual1      number;
    l_extend_from_installment        number;
    l_norm_interest                  number;
    l_add_prin_interest              number;
    l_add_int_interest               number;
    l_add_start_date                 date;
    l_add_end_date                   date;
    l_start_installment              number;
    l_end_installment                number;
    l_first_installment_billed       number;
    l_hidden_cumul_norm_int          number;
    l_hidden_cumul_add_prin_int      number;
    l_hidden_cumul_add_int_int       number;
    l_hidden_cumul_penal_int         number;
    l_periodic_norm_int              number;
    l_periodic_add_prin_int          number;
    l_periodic_add_int_int           number;
    l_periodic_penal_int             number;
    l_penal_prin_interest            number;
    l_penal_int_interest             number;
    l_penal_interest                 number;
    l_prev_grace_end_date            date;
    l_raw_rate                       number;
    l_balloon_amount                 number;
    l_remaining_balance              number;
    l_disb_header_id                 number;
    l_billed                         varchar2(1);
    n                                number;
    l_sum_periodic_principal         number;
    l_date1                          date;
    l_billed_principal               number;
    l_detail_int_calc_flag           boolean;
    l_increased_amount               number;
    l_increased_amount1              number;
    l_begin_funded_amount            number;
    l_end_funded_amount              number;
    l_increase_amount_instal         number;
    l_prev_increase_amount_instal    number;
    l_begin_funded_amount_new        number;
    l_begin                          number;
    l_last_prin_installment          number;
    l_fund_sched_count               number;
    l_wtd_balance                    number;
    l_balance1                       number;
    l_balance2                       number;

    l_norm_int_detail_str            varchar2(2000);
    l_add_prin_int_detail_str        varchar2(2000);
    l_add_int_int_detail_str         varchar2(2000);
    l_penal_prin_int_detail_str      varchar2(2000);
    l_penal_int_int_detail_str       varchar2(2000);
    l_penal_int_detail_str           varchar2(2000);

    -- for fees
    l_fee_structures                 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_orig_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
--    l_orig_fee_structures1           LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_new_orig_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_funding_fee_structures         LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
	l_conv_fee_structures			 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fees_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_memo_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_funding_fees_tbl               LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl                  LNS_FEE_ENGINE.FEE_BASIS_TBL;

    cursor c_conv_fees(p_loan_id number) is
    select nvl(sum(fee),0)
      from lns_fee_assignments
     where loan_id = p_loan_id
       and fee_type = 'EVENT_CONVERSION';

    -- get last bill date
    cursor c_get_last_bill_date(p_loan_id number, p_installment_number number)  is
        select ACTIVITY_DATE
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and PARENT_AMORTIZATION_ID is null
        and ACTIVITY_CODE in ('BILLING', 'START');

    -- get last billed principal info
    cursor c_get_last_payment(p_loan_id number, p_installment_number number)  is
        select PRINCIPAL_AMOUNT, PAYMENT_NUMBER
        from lns_amortization_scheds
        where loan_id = p_loan_id
        and PAYMENT_NUMBER > 0
        and PAYMENT_NUMBER <= p_installment_number
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and PARENT_AMORTIZATION_ID is null
        and REAMORTIZE_TO_INSTALLMENT is null
        and PRINCIPAL_AMOUNT > 0
        and nvl(PHASE, 'TERM') = 'TERM'
        order by PAYMENT_NUMBER desc;

    cursor c_orig_fee_billed(p_loan_id number, p_fee_id number, p_based_on_terms varchar2) is
        select 'X'
        from lns_fee_schedules sched
            ,lns_fees struct
        where sched.loan_id = p_loan_id
        and sched.fee_id = p_fee_id
        and sched.fee_id = struct.fee_id
        and struct.fee_type = 'EVENT_ORIGINATION'
        and sched.active_flag = 'Y'
        and decode(p_based_on_terms, 'CURRENT', sched.billed_flag, 'N') = 'Y'
        and sched.phase = 'TERM';

    -- get first billed installment number
    cursor c_get_funded_amount(p_loan_id number, p_installment_number number)  is
        select FUNDED_AMOUNT
        from LNS_AMORTIZATION_SCHEDS
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and PARENT_AMORTIZATION_ID is null
        and nvl(PHASE, 'TERM') = 'TERM';

    cursor c_fund_sched_exist(p_loan_id number)  is
        select decode(loan.loan_class_code,
            'DIRECT', (select count(1) from lns_disb_headers where loan_id = p_loan_id and status is null and PAYMENT_REQUEST_DATE is not null),
            'ERS', (select count(1) from lns_loan_lines where loan_id = p_loan_id and (status is null or status = 'PENDING') and end_date is null))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

begin

    -- initialize all variables
    l_api_name                       := 'amortizeSIPLoan MAIN';

    l_original_loan_amount           := 0;  -- loan amount
    l_loan_period_number             := 0;
    l_previous_rate_id               := -1;
    l_previous_annualized            := -1;
    l_periodic_payment               := 0;
    l_periodic_principal             := 0;
    l_periodic_interest              := 0;
	l_balloon_amount                 := 0;
    l_total_principal                := 0;
    l_payment_number                 := 0;
    l_fee_amount                     := 0;
    l_other_amount                   := 0;
    l_begin_balance                  := 0;
    l_unbilled_principal             := 0;
    l_unpaid_principal               := 0;
    l_remaining_balance_actual       := 0;
    l_remaining_balance_theory       := 0;
    l_total                          := 0;
    l_interest_cumulative            := 0;
    l_principal_cumulative           := 0;
    l_fees_cumulative                := 0;
    l_other_cumulative               := 0;
    i                                := 0;
    l_installment_number             := 1;  -- begin from #1 installment, NOT #0 installment
    l_rate_to_calculate              := 0;
    l_billing                        := false;  -- switch to notify if billing is calling API
    l_hidden_cumul_interest          := 0;
    l_hidden_periodic_prin           := 0;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - based on TERMS====> ' || p_based_on_terms);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment_number = ' || p_installment_number);

    l_loan_term                     := p_loan_details.loan_term;
    l_amortized_term                := p_loan_details.amortized_term;
    l_amortized_term_period         := p_loan_details.amortized_term_period;
    l_amortization_frequency        := p_loan_details.amortization_frequency;
    l_payment_frequency             := p_loan_details.payment_frequency;
    l_first_payment_date            := p_loan_details.first_payment_date;
    l_original_loan_amount          := p_loan_details.requested_amount;
    l_remaining_balance_actual      := p_loan_details.remaining_balance;
    l_remaining_balance_actual1     := p_loan_details.remaining_balance;
    l_maturity_date                 := p_loan_details.maturity_date;
--    l_intervals                     := p_loan_details.number_installments;
--    l_intervals_original            := p_loan_details.number_installments;
--    l_amortization_intervals_orig   := p_loan_details.num_amortization_intervals;
--    l_amortization_intervals        := p_loan_details.num_amortization_intervals;
--    l_amortization_intervals_rem    := p_loan_details.num_amortization_intervals;
	l_balloon_amount                := p_loan_details.balloon_payment_amount;
    l_last_installment_billed       := p_loan_details.last_installment_billed;
    l_day_count_method              := p_loan_details.day_count_method;
    l_loan_start_date               := p_loan_details.loan_start_date;
    l_pay_in_arrears                := p_loan_details.pay_in_arrears_boolean;
    l_precision                     := p_loan_details.currency_precision;
    l_reamortize_from_installment   := p_loan_details.reamortize_from_installment;
    l_reamortize_amount             := p_loan_details.reamortize_amount;
    l_loan_id                       := p_loan_details.loan_id;
    l_calc_method                   := p_loan_details.CALCULATION_METHOD;
    l_compound_freq                 := p_loan_details.INTEREST_COMPOUNDING_FREQ;
    l_prin_first_pay_date           := p_loan_details.PRIN_FIRST_PAY_DATE;
    l_prin_payment_frequency        := p_loan_details.PRIN_PAYMENT_FREQUENCY;
--    l_prin_intervals                := p_loan_details.PRIN_NUMBER_INSTALLMENTS;
--    l_prin_amortized_intervals      := p_loan_details.PRIN_AMORT_INSTALLMENTS;
    l_prin_pay_in_arrears           := p_loan_details.PRIN_PAY_IN_ARREARS_BOOL;
--    l_prin_intervals_diff           := l_prin_amortized_intervals - l_prin_intervals;
    l_extend_from_installment       := p_loan_details.EXTEND_FROM_INSTALLMENT;

    -- get the interest rate schedule
    l_rate_tbl := p_rate_schedule;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- rate schedule count = ' || l_rate_tbl.count);

    -- get payment schedule
    -- this will return the acutal dates that payments will be due on
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting payment schedule');

    l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                             p_loan_start_date      => l_loan_start_date
                             ,p_loan_maturity_date  => l_maturity_date
                             ,p_int_first_pay_date  => l_first_payment_date
                             ,p_int_num_intervals   => null --l_intervals
                             ,p_int_interval_type   => l_payment_frequency
                             ,p_int_pay_in_arrears  => l_pay_in_arrears
                             ,p_prin_first_pay_date => l_prin_first_pay_date
                             ,p_prin_num_intervals  => null --l_prin_intervals
                             ,p_prin_interval_type  => l_prin_payment_frequency
                             ,p_prin_pay_in_arrears => l_prin_pay_in_arrears);

    l_num_pay_dates := l_payment_tbl.count;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- payment schedule count = ' || l_num_pay_dates);

    -- get amortize principal schedule
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting principal schedule');
    l_principal_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                    ,p_loan_maturity_date => l_maturity_date
                                                    ,p_first_pay_date     => l_prin_first_pay_date
                                                    ,p_num_intervals      => null --l_intervals
                                                    ,p_interval_type      => l_prin_payment_frequency
                                                    ,p_pay_in_arrears     => l_prin_pay_in_arrears);

    l_prin_intervals := l_principal_tbl.count;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '-  principal schedule count = ' || l_prin_intervals);

    if l_loan_term <> l_amortized_term then
        -- get amortize maturity date
        l_amortized_maturity_date := LNS_FIN_UTILS.getMaturityDate(p_term         => l_amortized_term
                                                            ,p_term_period  => l_amortized_term_period
                                                            ,p_frequency    => l_prin_payment_frequency
                                                            ,p_start_date   => l_loan_start_date);
        -- get amortize principal schedule
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting amortize principal schedule');
        l_principal_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                        ,p_loan_maturity_date => l_amortized_maturity_date
                                                        ,p_first_pay_date     => l_prin_first_pay_date
                                                        ,p_num_intervals      => null --l_intervals
                                                        ,p_interval_type      => l_prin_payment_frequency
                                                        ,p_pay_in_arrears     => l_prin_pay_in_arrears);

        l_prin_amortized_intervals := l_principal_tbl.count;
    else
        l_prin_amortized_intervals := l_prin_intervals;
    end if;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- amortize principal schedule count = ' || l_prin_amortized_intervals);

    l_prin_intervals_diff := l_prin_amortized_intervals - l_prin_intervals;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- l_prin_intervals_diff = ' || l_prin_intervals_diff);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting conv fee structures');
    l_conv_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                             ,p_fee_category => 'EVENT'
                                                             ,p_fee_type     => 'EVENT_CONVERSION'
                                                             ,p_installment  => null
                                                             ,p_phase        => 'TERM'
                                                             ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': conv structures count = ' || l_conv_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting origination1 fee structures');
    l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                             ,p_fee_category => 'EVENT'
                                                             ,p_fee_type     => 'EVENT_ORIGINATION'
                                                             ,p_installment  => null
                                                             ,p_phase        => 'TERM'
                                                             ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': origination1 structures count is ' || l_orig_fee_structures.count);

    -- filtering out origination fees based on p_based_on_terms
    n := 0;
    for m in 1..l_orig_fee_structures.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee = ' || l_orig_fee_structures(m).FEE_ID);
        l_billed := null;
        open c_orig_fee_billed(l_loan_id, l_orig_fee_structures(m).FEE_ID, p_based_on_terms);
        fetch c_orig_fee_billed into l_billed;
        close c_orig_fee_billed;

        if l_billed is null then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is not billed yet');
            n := n + 1;
            l_new_orig_fee_structures(n) := l_orig_fee_structures(m);
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is already billed');
        end if;
    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting recurring fee structures');
    l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                       ,p_fee_category => 'RECUR'
                                                       ,p_fee_type     => null
                                                       ,p_installment  => null
                                                       ,p_phase        => 'TERM'
                                                       ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': fee structures count = ' || l_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting memo fee structures');
    l_memo_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                            ,p_fee_category => 'MEMO'
                                                            ,p_fee_type     => null
                                                            ,p_installment  => null
                                                            ,p_phase        => 'TERM'
                                                            ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': memo fee structures count = ' || l_memo_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting funding fee structures');
    l_funding_fee_structures  := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => l_loan_id
                                                                            ,p_installment_no => null
                                                                            ,p_phase          => 'TERM'
                                                                            ,p_disb_header_id => null
                                                                            ,p_fee_id         => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding fee structures count is ' || l_funding_fee_structures.count);

    if p_based_on_terms <> 'CURRENT' then
        open c_fund_sched_exist(l_loan_id);
        fetch c_fund_sched_exist into l_fund_sched_count;
        close c_fund_sched_exist;

        if l_fund_sched_count = 0 then
            l_original_loan_amount := p_loan_details.requested_amount;
        else
            l_original_loan_amount := getFundedAmount(l_loan_id, l_loan_start_date, p_based_on_terms);
        end if;
    else
        l_original_loan_amount := getFundedAmount(l_loan_id, l_loan_start_date, p_based_on_terms);
    end if;

    if l_new_orig_fee_structures.count > 0 or l_conv_fee_structures.count > 0 then

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_original_loan_amount;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := p_loan_details.requested_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_original_loan_amount;
       --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
       --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

       if l_new_orig_fee_structures.count > 0 then

            l_orig_fees_tbl.delete;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => 0
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_new_orig_fee_structures
                                        ,x_fees_tbl         => l_orig_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees = ' || l_orig_fees_tbl.count);

            for k in 1..l_orig_fees_tbl.count loop
                    l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
            end loop;

       end if;

       open c_conv_fees(l_loan_id);
       fetch c_conv_fees into l_fee_amount1;
       close c_conv_fees;
	   l_fee_amount := l_fee_amount1 + l_fee_amount;

       if l_fee_amount > 0 then
           i := i + 1;
           l_amortization_rec.installment_number   := 0;
           l_amortization_rec.due_date             := l_loan_start_date;
           l_amortization_rec.PERIOD_START_DATE    := l_loan_start_date;
           l_amortization_rec.PERIOD_END_DATE      := l_loan_start_date;
           l_amortization_rec.principal_amount     := 0;
           l_amortization_rec.interest_amount      := 0;
           l_amortization_rec.fee_amount           := l_fee_amount;
           l_amortization_rec.other_amount         := 0;
           l_amortization_rec.begin_balance        := l_original_loan_amount;
           l_amortization_rec.end_balance          := l_original_loan_amount;
           l_amortization_rec.interest_cumulative  := 0;
           l_amortization_rec.principal_cumulative := 0;
           l_amortization_rec.fees_cumulative      := l_fee_amount;
           l_amortization_rec.other_cumulative     := 0;
           l_amortization_rec.rate_id              := 0;
           l_amortization_rec.SOURCE               := 'PREDICTED';
           -- add the record to the amortization table
           l_amortization_rec.total                := l_fee_amount;
           l_amortization_rec.UNPAID_PRIN          := 0;
           l_amortization_rec.UNPAID_INT           := 0;
           l_amortization_rec.INTEREST_RATE        := l_rate_tbl(1).annual_rate;
           l_amortization_rec.NORMAL_INT_AMOUNT    := 0;
           l_amortization_rec.ADD_PRIN_INT_AMOUNT  := 0;
           l_amortization_rec.ADD_INT_INT_AMOUNT   := 0;
           l_amortization_rec.PENAL_INT_AMOUNT     := 0;
           l_amortization_rec.FUNDED_AMOUNT        := l_original_loan_amount;
           l_amortization_rec.PERIOD               := l_loan_start_date || ' - ' || l_loan_start_date;
           l_amortization_rec.DISBURSEMENT_AMOUNT  := 0;

           l_amortization_tbl(i)                   := l_amortization_rec;
       end if;

       --l_orig_fees_tbl.delete;
       l_fee_amount := 0;

    end if;

    -- go to the nth installment (Billing program doesnt need to go thru whole amortization)
    if p_installment_number is not null then

       l_billing        := true;
       if p_installment_number > 0 then

           if p_installment_number > l_num_pay_dates then
                l_payment_number := l_num_pay_dates;
           else
                l_payment_number := p_installment_number;
           end if;

       else
           l_payment_number := p_installment_number;
       end if;

    else

       l_payment_number := l_num_pay_dates;

    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_payment_number = ' || l_payment_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed = ' || l_last_installment_billed);

    l_begin := 1;

    if p_based_on_terms = 'CURRENT' and l_last_installment_billed > 0 then

        -- find last installment with billed principal
        open c_get_last_payment(l_loan_id, l_last_installment_billed);
        fetch c_get_last_payment into l_hidden_periodic_prin, l_last_prin_installment;
        close c_get_last_payment;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_periodic_prin = ' || l_hidden_periodic_prin);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_prin_installment = ' || l_last_prin_installment);

        l_begin := 0;
        -- find last installment with billed interest
        for j in REVERSE 1..l_last_installment_billed loop
            if l_payment_tbl(j).CONTENTS <> 'PRIN' then
                l_begin := j;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': installment ' || j || ' = ' || l_payment_tbl(j).CONTENTS);
                exit;
            end if;
        end loop;

        l_begin_funded_amount := 0;
        if l_begin > 0 then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ----- Querying INSTALLMENT ' || l_begin  || '-----');
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

            open c_get_funded_amount(l_loan_id, l_begin);
            fetch c_get_funded_amount into l_begin_funded_amount;
            close c_get_funded_amount;

        end if;
        l_begin := l_begin + 1;
    else
        l_remaining_balance_theory := l_original_loan_amount;
        l_begin_funded_amount := 0;  --l_original_loan_amount;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin = ' || l_begin);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_loan_details.REAMORTIZE_ON_FUNDING = ' || p_loan_details.REAMORTIZE_ON_FUNDING);

    l_hidden_cumul_norm_int := 0;
    l_hidden_cumul_add_prin_int := 0;
    l_hidden_cumul_add_int_int := 0;
    l_hidden_cumul_interest := 0;
    l_hidden_cumul_penal_int := 0;
    l_increase_amount_instal := -1;

    -- loop to build the amortization schedule
    for l_installment_number in l_begin..l_payment_number
    loop

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ----- Calculating INSTALLMENT ' || l_installment_number || ' -----');
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

       i := i + 1;
       l_periodic_interest      := 0;
       l_periodic_norm_int      := 0;
       l_periodic_add_prin_int  := 0;
       l_periodic_add_int_int   := 0;
       l_periodic_penal_int     := 0;
       l_periodic_principal     := 0;
       l_fee_amount             := 0;
       l_other_amount           := 0;
       l_unpaid_principal       := 0;
       l_unpaid_interest        := 0;
       l_intervals_remaining    := l_num_pay_dates - l_installment_number + 1;
       l_detail_int_calc_flag   := false;
       l_increased_amount       := 0;
       l_increased_amount1      := 0;
       l_prev_increase_amount_instal := l_increase_amount_instal;

       if l_fund_sched_count > 0 or p_based_on_terms = 'CURRENT' then

            if (l_last_installment_billed >= 0) and (l_last_installment_billed + 1 = l_installment_number) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 = l_installment_number');

                l_principal_cumulative := 0;
                l_interest_cumulative  := 0;
                l_fees_cumulative      := 0;
                l_other_cumulative     := 0;
                l_sum_periodic_principal := 0;
                l_billed_principal     := p_loan_details.billed_principal;
                l_unbilled_principal   := p_loan_details.unbilled_principal;
                l_unpaid_principal     := p_loan_details.unpaid_principal;
                l_unpaid_interest      := p_loan_details.UNPAID_INTEREST;

                if p_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE);
                    l_begin_funded_amount_new := getFundedAmount(l_loan_id, l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1));
                    l_end_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := l_installment_number;
                        else
                            if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := l_installment_number + 1;
                            elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := l_installment_number;
                            end if;
                        end if;

                    elsif l_begin_funded_amount_new > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new > l_begin_funded_amount');
                        l_increase_amount_instal := l_installment_number;
                    end if;

                    l_detail_int_calc_flag := true;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1));
                    l_begin_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                    l_begin_funded_amount := l_begin_funded_amount_new;
                    l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                    l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal;
                else
                    l_remaining_balance_theory := 0;
                end if;

            elsif (l_last_installment_billed >= 0) and (l_last_installment_billed + 1 > l_installment_number) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 > l_installment_number');
                if p_loan_details.loan_status <> 'PAIDOFF' then
                    open c_get_funded_amount(l_loan_id, l_installment_number);
                    fetch c_get_funded_amount into l_end_funded_amount;
                    close c_get_funded_amount;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);
                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');
                        l_detail_int_calc_flag := true;

                        if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                            l_increase_amount_instal := l_installment_number + 1;
                        elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                            l_increase_amount_instal := l_installment_number;
                        end if;

                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_sum_periodic_principal = ' || l_sum_periodic_principal);
                        l_remaining_balance_theory := l_begin_funded_amount - l_sum_periodic_principal;
                        l_increased_amount := l_end_funded_amount - l_begin_funded_amount_new;
                    end if;
                else
                    l_remaining_balance_theory := 0;
                end if;

            elsif (l_last_installment_billed >= 0) and (l_last_installment_billed + 1 < l_installment_number) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 < l_installment_number');
                if p_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1));
                    l_begin_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE);
                    l_begin_funded_amount_new := getFundedAmount(l_loan_id, l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1));
                    l_end_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');
                        l_detail_int_calc_flag := true;

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := l_installment_number;
                        else
                            if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := l_installment_number + 1;
                            elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := l_installment_number;
                            end if;
                        end if;

                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_sum_periodic_principal = ' || l_sum_periodic_principal);

                        l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                        l_begin_funded_amount := l_begin_funded_amount_new;
                        l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                        l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal - l_sum_periodic_principal;
                    end if;
                else
                    l_remaining_balance_theory := 0;
                end if;

            end if;

        end if;

        if p_loan_details.REAMORTIZE_ON_FUNDING = 'NO' then
            l_increase_amount_instal := -1;
        end if;

--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_actual: ' || l_remaining_balance_actual);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': getting rate details');
        l_rate_details := getRateDetails(p_installment => l_installment_number
                                        ,p_rate_tbl    => l_rate_tbl);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate annual rate = ' || l_rate_details.annual_rate);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate spread = ' || l_rate_details.spread);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate id = ' || l_rate_details.rate_id);
--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate floating_flag ' || l_rate_details.floating_flag);

        l_current_rate_id             := l_rate_details.rate_id;
        l_annualized_rate             := l_rate_details.annual_rate;
        l_interest_only_flag          := l_rate_details.interest_only_flag;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_current_rate_id = ' || l_current_rate_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_interest_only_flag = ' || l_interest_only_flag);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_annualized = ' || l_previous_annualized);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_annualized_rate = ' || l_annualized_rate);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed = ' || l_last_installment_billed);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_periodic_prin = ' || l_hidden_periodic_prin);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_extend_from_installment = ' || l_extend_from_installment);
        if l_detail_int_calc_flag then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = true');
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = false');
        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount = ' || l_increased_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount1 = ' || l_increased_amount1);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increase_amount_instal = ' || l_increase_amount_instal);

        -- conditions to recalculate principal payment
        -- 1. 1-st installment
        -- 2. reamortization from installment = current installment
        -- 3. reamortize because loan term has been extended
        -- 4. hidden_periodic_prin = 0
        -- 5. funded amount has increased since last installment

        if ((l_installment_number = 1) OR
            (l_reamortize_from_installment >= 0 and (l_last_installment_billed + 1 = l_installment_number)) OR
            (l_extend_from_installment is not null and (l_extend_from_installment + 1 >= l_installment_number)) OR
            (l_hidden_periodic_prin = 0 and (l_last_installment_billed + 1 = l_installment_number)) OR
            (l_prev_increase_amount_instal = l_installment_number or l_increase_amount_instal = l_installment_number))
        then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- RE-calculating periodic principal payment');

            l_num_prin_payments := get_remain_num_prin_instal(l_payment_tbl, l_installment_number) + l_prin_intervals_diff;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ': l_num_prin_payments = ' || l_num_prin_payments);
/*
            if l_installment_number = 1 and l_reamortize_from_installment is null then
                l_remaining_balance := l_original_loan_amount;
            else
                l_remaining_balance := l_remaining_balance_theory;
            end if;
*/

            l_remaining_balance := l_remaining_balance_theory + l_increased_amount1;

            l_hidden_periodic_prin := lns_financials.calculateEPPayment(p_loan_amount   => l_remaining_balance
                                                                    ,p_num_intervals => l_num_prin_payments
                                                                    ,p_ending_balance=> l_balloon_amount
                                                                    ,p_pay_in_arrears=> l_prin_pay_in_arrears);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': NEW periodic principal payment = ' || l_hidden_periodic_prin);

        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': KEEPING OLD principal payment = ' || l_hidden_periodic_prin);
        end if;

        l_previous_rate_id            := l_current_rate_id;
        l_previous_annualized         := l_annualized_rate;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_interest = ' || l_hidden_cumul_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_norm_int = ' || l_hidden_cumul_norm_int);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_add_prin_int = ' || l_hidden_cumul_add_prin_int);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_add_int_int = ' || l_hidden_cumul_add_int_int);

       l_norm_interest := 0;
       l_add_prin_interest := 0;
       l_add_int_interest := 0;
       l_penal_prin_interest := 0;
       l_penal_int_interest := 0;
       l_penal_interest := 0;
       l_interest := 0;
       l_norm_int_detail_str := null;
       l_add_prin_int_detail_str := null;
       l_add_int_int_detail_str := null;
       l_penal_prin_int_detail_str := null;
       l_penal_int_int_detail_str := null;
       l_penal_int_detail_str := null;

       -- now we will calculate the interest due for this period
--       if ((p_based_on_terms = 'CURRENT' and l_last_installment_billed >= 0 and l_last_installment_billed + 1 = l_installment_number) or
--           (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true)) then
       if (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true) then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating normal interest...');
            LNS_FINANCIALS.CALC_NORM_INTEREST(p_loan_id => l_loan_id,
                                p_calc_method => l_calc_method,
                                p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                p_period_end_date => l_payment_tbl(l_installment_number).period_end_date,
                                p_interest_rate => l_annualized_rate,
                                p_day_count_method => l_day_count_method,
                                p_payment_freq => l_payment_frequency,
                                p_compound_freq => l_compound_freq,
                                p_adj_amount => l_sum_periodic_principal,
                                x_norm_interest => l_norm_interest,
                                x_norm_int_details => l_norm_int_detail_str);

            l_norm_interest  := round(l_norm_interest, l_precision);

            if (l_installment_number-1) >= 0 and l_last_installment_billed + 1 = l_installment_number then

                -- get additional interest start date
                open c_get_last_bill_date(l_loan_id, (l_installment_number-1));
                fetch c_get_last_bill_date into l_add_start_date;
                close c_get_last_bill_date;

                -- get additional interest end date
                --l_add_end_date := l_payment_tbl(l_installment_number).period_end_date;

                if trunc(sysdate) > trunc(l_payment_tbl(l_installment_number).period_end_date) then
                    l_add_end_date := l_payment_tbl(l_installment_number).period_end_date;
                else
                    l_add_end_date := sysdate;
                end if;

                if (l_installment_number-1) > 0 then
                    l_prev_grace_end_date := l_payment_tbl(l_installment_number-1).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS;
                else
                    l_prev_grace_end_date := l_payment_tbl(l_installment_number).period_begin_date;
                end if;

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid principal...');
                -- calculate additional interest on unpaid principal
                LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => l_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_frequency,
                                    p_compound_freq => l_compound_freq,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_penal_int_rate => p_loan_details.PENAL_INT_RATE,
                                    p_grace_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                    p_grace_end_date => (l_payment_tbl(l_installment_number).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_PRIN',
                                    x_add_interest => l_add_prin_interest,
                                    x_penal_interest => l_penal_prin_interest,
                                    x_add_int_details => l_add_prin_int_detail_str,
                                    x_penal_int_details => l_penal_prin_int_detail_str);
                l_add_prin_interest  := round(l_add_prin_interest, l_precision);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid interest...');
                -- calculate additional interest on unpaid interest
                LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => l_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_frequency,
                                    p_compound_freq => l_compound_freq,
                                    p_penal_int_rate => p_loan_details.PENAL_INT_RATE,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_grace_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                    p_grace_end_date => (l_payment_tbl(l_installment_number).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_INT',
                                    x_add_interest => l_add_int_interest,
                                    x_penal_interest => l_penal_int_interest,
                                    x_add_int_details => l_add_int_int_detail_str,
                                    x_penal_int_details => l_penal_int_int_detail_str);
                l_add_int_interest  := round(l_add_int_interest, l_precision);

                if l_penal_prin_int_detail_str is not null and l_penal_int_int_detail_str is not null then
                    l_penal_int_detail_str := l_penal_prin_int_detail_str || ' +<br>' || l_penal_int_int_detail_str;
                else
                    l_penal_int_detail_str := l_penal_prin_int_detail_str || l_penal_int_int_detail_str;
                end if;
            end if;

       elsif (p_based_on_terms <> 'CURRENT' and l_detail_int_calc_flag = true) then

            if (l_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies
                l_periodic_rate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_frequency
                                            ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'INTEREST');

            elsif (l_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                ,p_payment_freq => l_payment_frequency
                                ,p_annualized_rate => l_annualized_rate
                                ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                                ,p_days_count_method => l_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                            ,p_from_date        => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_to_date          => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_calc_method      => 'TARGET'
                                            ,p_phase            => 'TERM'
                                            ,p_day_count_method => l_day_count_method
                                            ,p_adj_amount       => l_sum_periodic_principal
                                            ,x_wtd_balance      => l_wtd_balance
                                            ,x_begin_balance    => l_balance1
                                            ,x_end_balance      => l_balance2);

            l_norm_interest := lns_financials.calculateInterest(p_amount => l_wtd_balance
                                                                ,p_periodic_rate => l_periodic_rate
                                                                ,p_compounding_period => null);
            l_norm_interest := round(l_norm_interest, l_precision);

            l_norm_int_detail_str :=
                'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
                ' * Balance: ' || l_wtd_balance ||
                ' * Rate: ' || l_annualized_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

       else


            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_remaining_balance_theory);
--            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_remaining_balance_actual);

            if (l_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies
                l_periodic_rate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_frequency
                                            ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'INTEREST');

            elsif (l_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                ,p_payment_freq => l_payment_frequency
                                ,p_annualized_rate => l_annualized_rate
                                ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                                ,p_days_count_method => l_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            l_norm_interest := lns_financials.calculateInterest(p_amount => l_remaining_balance_theory --l_remaining_balance_actual
                                                                ,p_periodic_rate => l_periodic_rate
                                                                ,p_compounding_period => null);
            l_norm_interest := round(l_norm_interest, l_precision);

            l_norm_int_detail_str :=
                'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
                ' * Balance: ' || l_remaining_balance_theory ||
                ' * Rate: ' || l_annualized_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

       end if;

       l_penal_interest := round(l_penal_prin_interest + l_penal_int_interest, l_precision);
       l_interest := l_norm_interest + l_add_prin_interest + l_add_int_interest + l_penal_interest;
       l_hidden_cumul_norm_int := l_hidden_cumul_norm_int + l_norm_interest;
       l_hidden_cumul_add_prin_int := l_hidden_cumul_add_prin_int + l_add_prin_interest;
       l_hidden_cumul_add_int_int := l_hidden_cumul_add_int_int + l_add_int_interest;
       l_hidden_cumul_interest := l_hidden_cumul_interest + l_interest;
       l_hidden_cumul_penal_int := l_hidden_cumul_penal_int + l_penal_interest;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_norm_interest = ' || l_norm_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_prin_interest = ' || l_add_prin_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_int_interest = ' || l_add_int_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_penal_interest = ' || l_penal_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_interest = ' || l_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_interest = ' || l_interest);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': CONTENTS = ' || l_payment_tbl(l_installment_number).CONTENTS);

        if (l_payment_tbl(l_installment_number).CONTENTS = 'PRIN') then

            l_periodic_interest := 0;
            l_periodic_norm_int := 0;
            l_periodic_add_prin_int := 0;
            l_periodic_add_int_int := 0;
            l_periodic_penal_int := 0;

            l_num_prin_payments := get_remain_num_prin_instal(l_payment_tbl, l_installment_number);

            if (l_remaining_balance_theory + l_increased_amount1) < l_hidden_periodic_prin then
                l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
            else
                if (l_num_prin_payments = 1) then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': CALCULATING LAST INSTALLMENT PRINCIPAL');
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_unbilled principal = ' || l_unbilled_principal);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);
                    if p_based_on_terms = 'CURRENT' and l_unbilled_principal > 0 then
                        l_periodic_principal := l_unbilled_principal;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_unbilled_principal');
                    else
                        l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
                    end if;
                else
                    l_periodic_principal := l_hidden_periodic_prin;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_hidden_periodic_prin');
                end if;
           end if;

        elsif (l_payment_tbl(l_installment_number).CONTENTS = 'INT') then

            l_periodic_interest := l_hidden_cumul_interest;
            l_periodic_norm_int := l_hidden_cumul_norm_int;
            l_periodic_add_prin_int := l_hidden_cumul_add_prin_int;
            l_periodic_add_int_int := l_hidden_cumul_add_int_int;
            l_periodic_penal_int := l_hidden_cumul_penal_int;
            l_hidden_cumul_interest := 0;
            l_hidden_cumul_norm_int := 0;
            l_hidden_cumul_add_prin_int := 0;
            l_hidden_cumul_add_int_int := 0;
            l_hidden_cumul_penal_int := 0;
            l_periodic_principal := 0;

        else

            l_periodic_interest := l_hidden_cumul_interest;
            l_periodic_norm_int := l_hidden_cumul_norm_int;
            l_periodic_add_prin_int := l_hidden_cumul_add_prin_int;
            l_periodic_add_int_int := l_hidden_cumul_add_int_int;
            l_periodic_penal_int := l_hidden_cumul_penal_int;
            l_hidden_cumul_interest := 0;
            l_hidden_cumul_norm_int := 0;
            l_hidden_cumul_add_prin_int := 0;
            l_hidden_cumul_add_int_int := 0;
            l_hidden_cumul_penal_int := 0;

            l_num_prin_payments := get_remain_num_prin_instal(l_payment_tbl, l_installment_number);

            if (l_remaining_balance_theory + l_increased_amount1) < l_hidden_periodic_prin then
                l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
            else
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': CALCULATING LAST INSTALLMENT PRINCIPAL');
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_unbilled principal = ' || l_unbilled_principal);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);
                if (l_num_prin_payments = 1) then
                    if p_based_on_terms = 'CURRENT' and l_unbilled_principal > 0 then
                        l_periodic_principal := l_unbilled_principal;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_unbilled_principal');
                    else
                        l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
                    end if;
                else
                    l_periodic_principal := l_hidden_periodic_prin;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_hidden_periodic_prin');
                end if;
           end if;

        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_norm_int = ' || l_hidden_cumul_norm_int);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_add_prin_int = ' || l_hidden_cumul_add_prin_int);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_add_int_int = ' || l_hidden_cumul_add_int_int);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_interest = ' || l_hidden_cumul_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_cumul_penal_int = ' || l_hidden_cumul_penal_int);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_hidden_periodic_prin = ' || l_hidden_periodic_prin);

        -- round int and prin and calc total
        l_periodic_principal := round(l_periodic_principal, l_precision);
        l_periodic_interest  := round(l_periodic_interest, l_precision);
        l_periodic_payment := l_periodic_principal + l_periodic_interest;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': principal = ' || l_periodic_principal);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest = ' || l_periodic_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': total = ' || l_periodic_payment);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);

       -- calculate balances and total payment
       l_begin_balance        := l_remaining_balance_theory;
       l_end_balance          := l_remaining_balance_theory - l_periodic_principal + l_increased_amount1;

       -- check to see if this loan has been billed
       if l_unbilled_principal > 0 then
         l_unbilled_principal := l_unbilled_principal - l_periodic_principal;
       end if;

       -- build the amortization record
       -- this information is needed to calculate fees
       -- rest of the record can be built after fees are calculated
       l_amortization_rec.installment_number   := l_installment_number;  /* needed to calculate fees */
       l_amortization_rec.due_date             := l_payment_tbl(l_installment_number).period_due_date;
       l_amortization_rec.PERIOD_START_DATE    := l_payment_tbl(l_installment_number).period_begin_date;
       l_amortization_rec.PERIOD_END_DATE      := l_payment_tbl(l_installment_number).period_end_date;
       l_amortization_rec.principal_amount     := l_periodic_principal;  /* needed to calculate fees */
       l_amortization_rec.interest_amount      := l_periodic_interest;
       l_amortization_rec.begin_balance        := l_begin_balance;       /* needed to calculate fees */
       l_amortization_rec.end_balance          := l_end_balance;
       l_amortization_rec.UNPAID_PRIN          := l_unpaid_principal;
       l_amortization_rec.UNPAID_INT           := l_unpaid_interest;
       l_amortization_rec.INTEREST_RATE        := l_annualized_rate;
       l_amortization_rec.NORMAL_INT_AMOUNT    := l_periodic_norm_int;
       l_amortization_rec.ADD_PRIN_INT_AMOUNT  := l_periodic_add_prin_int;
       l_amortization_rec.ADD_INT_INT_AMOUNT   := l_periodic_add_int_int;
       l_amortization_rec.PENAL_INT_AMOUNT     := l_periodic_penal_int;
       l_amortization_rec.PERIOD               := l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1);
       l_amortization_rec.DISBURSEMENT_AMOUNT  := l_increased_amount;

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_amortization_rec.begin_balance;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := p_loan_details.requested_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_begin_funded_amount;

       if l_installment_number = 1 then

            if l_new_orig_fee_structures.count > 0 then

                l_orig_fees_tbl.delete;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
                lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                            ,p_installment      => l_installment_number
                                            ,p_fee_basis_tbl    => l_fee_basis_tbl
                                            ,p_fee_structures   => l_new_orig_fee_structures
                                            ,x_fees_tbl         => l_orig_fees_tbl
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fees_tbl.count);

                for k in 1..l_orig_fees_tbl.count loop
                        l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
                end loop;

            end if;

       end if;

       l_memo_fees_tbl.delete;
       if l_memo_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for memo fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_memo_fee_structures
                                        ,x_fees_tbl         => l_memo_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated memo fees ' || l_memo_fees_tbl.count);
       end if;

       l_fees_tbl.delete;
       if l_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for recurring fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_fee_structures
                                        ,x_fees_tbl         => l_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated fees ' || l_fees_tbl.count);
       end if;

       -- calculate the funding fees
       l_funding_fees_tbl.delete;
       if l_funding_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for funding fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_funding_fee_structures
                                        ,x_fees_tbl         => l_funding_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated funding fees ' || l_fees_tbl.count);
       end if;

       for k in 1..l_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_fees_tbl(k).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': recurring calculated fees = ' || l_fee_amount);
       end loop;

       for j in 1..l_funding_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_funding_fees_tbl(j).FEE_AMOUNT;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding calculated fees = ' || l_fee_amount);
       end loop;

       for j in 1..l_memo_fees_tbl.count loop
              l_other_amount := l_other_amount + l_memo_fees_tbl(j).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': other calculated fees = ' || l_other_amount);
       end loop;

       l_total                                 := l_fee_amount + l_periodic_principal + l_periodic_interest + l_other_amount;
       l_amortization_rec.total                := l_total;
       l_amortization_rec.fee_amount           := l_fee_amount;
       l_amortization_rec.other_amount         := l_other_amount;

       -- running totals calculated here
       l_principal_cumulative := l_principal_cumulative + l_periodic_principal;
       l_interest_cumulative  := l_interest_cumulative + l_periodic_interest;
       l_fees_cumulative      := l_fees_cumulative + l_fee_amount;
       l_other_cumulative     := l_other_cumulative + l_other_amount;

       l_amortization_rec.interest_cumulative  := l_interest_cumulative;
       l_amortization_rec.principal_cumulative := l_principal_cumulative;
       l_amortization_rec.fees_cumulative      := l_fees_cumulative;
       l_amortization_rec.other_cumulative     := l_other_cumulative;
       l_amortization_rec.rate_id              := l_current_rate_id;
       l_amortization_rec.SOURCE               := 'PREDICTED';
       l_amortization_rec.FUNDED_AMOUNT        := l_end_funded_amount;

       l_amortization_rec.NORMAL_INT_DETAILS   := l_norm_int_detail_str;
       l_amortization_rec.ADD_PRIN_INT_DETAILS := l_add_prin_int_detail_str;
       l_amortization_rec.ADD_INT_INT_DETAILS  := l_add_int_int_detail_str;
       l_amortization_rec.PENAL_INT_DETAILS    := l_penal_int_detail_str;

       -- add the record to the amortization table
       l_amortization_tbl(i)                   := l_amortization_rec;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INSTALLMENT ' || l_installment_number);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD = ' || l_amortization_rec.PERIOD);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_START_DATE = ' || l_amortization_rec.PERIOD_START_DATE);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_END_DATE = ' || l_amortization_rec.PERIOD_END_DATE);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'due date = ' || l_amortization_rec.due_date);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_principal = ' || l_amortization_rec.principal_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_interest = ' || l_amortization_rec.interest_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fee_amount = ' || l_amortization_rec.fee_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other_amount = ' || l_amortization_rec.other_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'total = ' || l_amortization_rec.total);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'begin_balance = ' || l_amortization_rec.begin_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'end_balance = ' || l_amortization_rec.end_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'interest_cumulative = ' || l_amortization_rec.interest_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'principal_cumulative = ' || l_amortization_rec.principal_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fees_cumulative = ' || l_amortization_rec.fees_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other_cumulative = ' || l_amortization_rec.other_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'current_rate_id = ' || l_amortization_rec.rate_id );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INTEREST_RATE = ' || l_amortization_rec.INTEREST_RATE );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_PRIN = ' || l_amortization_rec.UNPAID_PRIN );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_INT = ' || l_amortization_rec.UNPAID_INT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_AMOUNT = ' || l_amortization_rec.NORMAL_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_AMOUNT = ' || l_amortization_rec.ADD_PRIN_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_AMOUNT = ' || l_amortization_rec.ADD_INT_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_AMOUNT = ' || l_amortization_rec.PENAL_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FUNDED_AMOUNT = ' || l_amortization_rec.FUNDED_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_DETAILS = ' || l_amortization_rec.NORMAL_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_DETAILS = ' || l_amortization_rec.ADD_PRIN_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_DETAILS_AMOUNT = ' || l_amortization_rec.ADD_INT_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_DETAILS = ' || l_amortization_rec.PENAL_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');

       -- adjust new loan amount to reflect less periodic principal paid
       -- theoretically without over/underpayments l_loan_amount should = l_remaining_balance
       -- if they diverge then we will calculate interest based from l_remaining_balance
       -- rather than l_loan_amount
       l_remaining_balance_theory :=  l_end_balance;
       l_sum_periodic_principal := l_sum_periodic_principal + l_periodic_principal;

       -- clean up
       l_orig_fees_tbl.delete;
       l_memo_fees_tbl.delete;
       l_fees_tbl.delete;
       l_funding_fees_tbl.delete;

    end loop;

    --printAmortizationTable(p_amort_tbl => l_amortization_tbl);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AMORTIZATION TABLE COUNT IS ' || l_amortization_tbl.count);
    x_loan_amort_tbl := l_amortization_tbl;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end amortizeSIPLoan;



/*=========================================================================
|| PUBLIC PROCEDURE amortizeEPLoan
||
|| DESCRIPTION
||
|| Overview: this is the main calculation API for EP amortization
||            THIS API WILL BE CALLED FROM 2 PLACES PRIMARILY:
||           1. Amortization UI - when creating a loan
||           2. Billing Engine  - to generate installment bills
||
|| Parameter: p_loan_details  = details of the loan
||            p_rate_schedule = rate schedule for the loan
||            p_installment_number => billing will pass in an installment
||                                    number to generate a billt
||            x_loan_amort_tbl => table of amortization records
||
|| Source Tables:  NA
||
|| Target Tables:  LNS_TEMP_AMORTIZATIONS
||
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|
| Date                  Author            Description of Changes
|| 09/13/2007           scherkas          Created
|| 16/01/2008            scherkas          Fixed bug 6749924
 *=======================================================================*/
procedure amortizeEPLoan(p_loan_details       in  LNS_FINANCIALS.LOAN_DETAILS_REC
                      ,p_rate_schedule      in  LNS_FINANCIALS.RATE_SCHEDULE_TBL
                      ,p_based_on_terms     in  varchar2
                      ,p_installment_number in  number
                      ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL)
is
    l_return_status                  varchar2(1);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(32767);
    -- loan_details
    l_loan_id                        number;
    l_original_loan_amount           number;  -- loan amount
    l_amortized_term                 number;
    l_loan_term                      number;
    l_amortized_term_period          varchar2(30);
    l_amortization_frequency         varchar2(30);
    l_loan_period_number             number;
    l_loan_period_type               varchar2(30);
    l_first_payment_date             date;
    l_pay_in_arrears                 boolean;
    l_payment_frequency              varchar2(30);
    l_day_count_method               varchar2(30);
    l_interest_comp_freq             varchar2(30);
    l_calculation_method             varchar2(30);
    l_reamortize_from_installment    number;
    l_reamortize_amount              number;
    l_annualized_rate                number;  -- annual rate on the loan
--    l_intervals_original             number;
--    l_intervals                      number;
    l_intervals_remaining            number;
--    l_amortization_intervals_orig    number;
--    l_amortization_intervals_rem     number;
    l_amortization_intervals         number;  -- number of intervals to amortize over
    l_rate_details                   LNS_FINANCIALS.INTEREST_RATE_REC;
    l_current_rate_id                number;
    l_previous_rate_id               number;
    l_precision                      number;

    l_period_start_Date              date;
    l_period_end_date                date;
    l_periodic_rate                  number;
    l_maturity_date                  date;
    l_amortized_maturity_date        date;

    l_amortization_rec               LNS_FINANCIALS.AMORTIZATION_REC;
    l_amortization_tbl               LNS_FINANCIALS.AMORTIZATION_TBL;
    l_rate_tbl                       LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    --l_pay_dates                      LNS_FINANCIALS.DATE_TBL;
    l_payment_tbl                    LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_amortized_payment_tbl          LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_loan_start_date                date;
    l_num_pay_dates                  number;  -- number of dates on installment schedule
    l_periodic_payment               number;
    l_periodic_principal             number;
    l_periodic_interest              number;
    l_interest_based_on_amount       number;  -- do we calculate interest from actual or predicted remaining balance
    l_pay_date                       date;
    l_total_principal                number;
    l_payment_number                 number;
    l_fee_amount                     number;
    l_fee_amount1                    number;
    l_other_amount                   number;
    l_begin_balance                  number;
    l_end_balance                    number;
    l_unbilled_principal             number;
    l_unpaid_principal               number;
    l_unpaid_interest                number;

    l_remaining_balance_actual       number;
    l_remaining_balance_theory       number;
    l_total                          number;
    l_interest_cumulative            number;
    l_principal_cumulative           number;
    l_fees_cumulative                number;
    l_other_cumulative               number;
    i                                number;
    l_installment_number             number;
    l_billing                        boolean;  -- switch to notify if billing is calling API
    l_api_name                       varchar2(20);
    l_last_installment_billed        number;
    l_rate_to_calculate              number;
    l_previous_annualized            number;
    l_previous_interest_only_flag    varchar2(1);
    l_interest_only_flag             varchar2(1);
    l_calc_method                    varchar2(30);
    l_compound_freq                  varchar2(30);
    l_non_ro_intervals               number;
    l_prev_periodic_principal        number;
--    l_calc_from_amount               number;
    l_intervals_diff                 number;
    l_remaining_balance_actual1      number;
    l_extend_from_installment        number;
    l_orig_num_install               number;
    l_first_installment_billed       number;
    l_begin                          number;
    l_norm_interest                  number;
    l_add_prin_interest              number;
    l_add_int_interest               number;
    l_add_start_date                 date;
    l_add_end_date                   date;
    l_penal_prin_interest            number;
    l_penal_int_interest             number;
    l_penal_interest                 number;
    l_prev_grace_end_date            date;
    l_raw_rate                       number;
    l_balloon_amount                 number;
    l_remaining_balance              number;
    l_disb_header_id                 number;
    l_billed                         varchar2(1);
    n                                number;
    l_sum_periodic_principal         number;
    l_date1                          date;
    l_billed_principal               number;
    l_detail_int_calc_flag           boolean;
    l_increased_amount               number;
    l_increased_amount1              number;
    l_begin_funded_amount            number;
    l_end_funded_amount              number;
    l_increase_amount_instal         number;
    l_prev_increase_amount_instal    number;
    l_begin_funded_amount_new        number;
    l_fund_sched_count               number;
    l_wtd_balance                    number;
    l_balance1                       number;
    l_balance2                       number;

    l_norm_int_detail_str            varchar2(2000);
    l_add_prin_int_detail_str        varchar2(2000);
    l_add_int_int_detail_str         varchar2(2000);
    l_penal_prin_int_detail_str      varchar2(2000);
    l_penal_int_int_detail_str       varchar2(2000);
    l_penal_int_detail_str           varchar2(2000);

    -- for fees
    l_fee_structures                 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_orig_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
--    l_orig_fee_structures1           LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_new_orig_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_funding_fee_structures         LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
	l_conv_fee_structures			 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fees_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_memo_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_funding_fees_tbl               LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl                  LNS_FEE_ENGINE.FEE_BASIS_TBL;

    cursor c_conv_fees(p_loan_id number) is
    select nvl(sum(fee),0)
      from lns_fee_assignments
     where loan_id = p_loan_id
       and fee_type = 'EVENT_CONVERSION';

    -- get last bill date
    cursor c_get_last_bill_date(p_loan_id number, p_installment_number number)  is
        select ACTIVITY_DATE
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and PARENT_AMORTIZATION_ID is null
        and ACTIVITY_CODE in ('BILLING', 'START');

    -- get last billed principal info
    cursor c_get_last_payment(p_loan_id number, p_installment_number number)  is
        select PRINCIPAL_AMOUNT, FUNDED_AMOUNT
        from lns_amortization_scheds
        where loan_id = p_loan_id
        and PAYMENT_NUMBER > 0
        and PAYMENT_NUMBER <= p_installment_number
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and PARENT_AMORTIZATION_ID is null
        and REAMORTIZE_TO_INSTALLMENT is null
        --and PRINCIPAL_AMOUNT > 0
        and nvl(PHASE, 'TERM') = 'TERM'
        order by PAYMENT_NUMBER desc;


    cursor c_orig_fee_billed(p_loan_id number, p_fee_id number, p_based_on_terms varchar2) is
        select 'X'
        from lns_fee_schedules sched
            ,lns_fees struct
        where sched.loan_id = p_loan_id
        and sched.fee_id = p_fee_id
        and sched.fee_id = struct.fee_id
        and struct.fee_type = 'EVENT_ORIGINATION'
        and sched.active_flag = 'Y'
        and decode(p_based_on_terms, 'CURRENT', sched.billed_flag, 'N') = 'Y'
        and sched.phase = 'TERM';

    cursor c_fund_sched_exist(p_loan_id number)  is
        select decode(loan.loan_class_code,
            'DIRECT', (select count(1) from lns_disb_headers where loan_id = p_loan_id and status is null and PAYMENT_REQUEST_DATE is not null),
            'ERS', (select count(1) from lns_loan_lines where loan_id = p_loan_id and (status is null or status = 'PENDING') and end_date is null))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

begin

    -- initialize all variables
    l_original_loan_amount           := 0;  -- loan amount
    l_loan_period_number             := 0;
    l_previous_rate_id               := -1;
    l_previous_annualized            := -1;
    l_previous_interest_only_flag    := 'N';    -- default to regular interest + principal
    l_periodic_payment               := 0;
    l_periodic_principal             := 0;
    l_periodic_interest              := 0;
	l_balloon_amount                 := 0;
    l_total_principal                := 0;
    l_payment_number                 := 0;
    l_fee_amount                     := 0;
    l_other_amount                   := 0;
    l_begin_balance                  := 0;
    l_unbilled_principal             := 0;
    l_unpaid_principal               := 0;
    l_remaining_balance_actual       := 0;
    l_remaining_balance_theory       := 0;
    l_total                          := 0;
    l_interest_cumulative            := 0;
    l_principal_cumulative           := 0;
    l_fees_cumulative                := 0;
    l_other_cumulative               := 0;
    i                                := 0;
    l_installment_number             := 1;  -- begin from #1 installment, NOT #0 installment
    l_rate_to_calculate              := 0;
    l_billing                        := false;  -- switch to notify if billing is calling API
    l_api_name                       := 'amortizeEPLoan MAIN';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - based on TERMS====> ' || p_based_on_terms);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment_number = ' || p_installment_number);

    l_loan_term                     := p_loan_details.loan_term;
    l_amortized_term                := p_loan_details.amortized_term;
    l_amortized_term_period         := p_loan_details.amortized_term_period;
    l_amortization_frequency        := p_loan_details.amortization_frequency;
    l_payment_frequency             := p_loan_details.payment_frequency;
    l_first_payment_date            := p_loan_details.first_payment_date;
    l_original_loan_amount          := p_loan_details.requested_amount; --funded_amount;
    l_remaining_balance_actual      := p_loan_details.remaining_balance;
    l_remaining_balance_actual1     := p_loan_details.remaining_balance;
    l_maturity_date                 := p_loan_details.maturity_date;
--    l_intervals                     := p_loan_details.number_installments;
--    l_intervals_original            := p_loan_details.number_installments;
--    l_amortization_intervals_orig   := p_loan_details.num_amortization_intervals;
--    l_amortization_intervals        := p_loan_details.num_amortization_intervals;
--    l_amortization_intervals_rem    := p_loan_details.num_amortization_intervals;
	l_balloon_amount                := p_loan_details.balloon_payment_amount;
    l_last_installment_billed       := p_loan_details.last_installment_billed;
    l_day_count_method              := p_loan_details.day_count_method;
    l_loan_start_date               := p_loan_details.loan_start_date;
    l_pay_in_arrears                := p_loan_details.pay_in_arrears_boolean;
    l_precision                     := p_loan_details.currency_precision;
    l_reamortize_from_installment   := p_loan_details.reamortize_from_installment;
    l_reamortize_amount             := p_loan_details.reamortize_amount;
    l_loan_id                       := p_loan_details.loan_id;
    l_calc_method                   := p_loan_details.CALCULATION_METHOD;
    l_compound_freq                 := p_loan_details.INTEREST_COMPOUNDING_FREQ;
--    l_intervals_diff                := l_amortization_intervals_orig - l_intervals_original;
    l_extend_from_installment       := p_loan_details.EXTEND_FROM_INSTALLMENT;
    l_orig_num_install              := p_loan_details.ORIG_NUMBER_INSTALLMENTS;

    -- get the interest rate schedule
    l_rate_tbl := p_rate_schedule;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- rate schedule count = ' || l_rate_tbl.count);

    -- get payment schedule
    -- this will return the acutal dates that payments will be due on
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting payment schedule');
    l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                       ,p_loan_maturity_date => l_maturity_date
                                                       ,p_first_pay_date     => l_first_payment_date
                                                       ,p_num_intervals      => null --l_intervals
                                                       ,p_interval_type      => l_payment_frequency
                                                       ,p_pay_in_arrears     => l_pay_in_arrears);

    l_num_pay_dates := l_payment_tbl.count;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- payment schedule count = ' || l_num_pay_dates);

    if l_loan_term <> l_amortized_term then

        -- get amortize maturity date
        l_amortized_maturity_date := LNS_FIN_UTILS.getMaturityDate(p_term         => l_amortized_term
                                                            ,p_term_period  => l_amortized_term_period
                                                            ,p_frequency    => l_payment_frequency
                                                            ,p_start_date   => l_loan_start_date);
        -- get amortize payment schedule
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting amortize payment schedule');
        l_amortized_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                        ,p_loan_maturity_date => l_amortized_maturity_date
                                                        ,p_first_pay_date     => l_first_payment_date
                                                        ,p_num_intervals      => null --l_intervals
                                                        ,p_interval_type      => l_payment_frequency
                                                        ,p_pay_in_arrears     => l_pay_in_arrears);

        l_amortization_intervals := l_amortized_payment_tbl.count;
    else
        l_amortization_intervals := l_num_pay_dates;
    end if;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- amortize payment schedule count: ' || l_amortization_intervals);

    l_intervals_diff := l_amortization_intervals - l_num_pay_dates;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting conv fee structures');
    l_conv_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                             ,p_fee_category => 'EVENT'
                                                             ,p_fee_type     => 'EVENT_CONVERSION'
                                                             ,p_installment  => null
                                                             ,p_phase        => 'TERM'
                                                             ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': conv structures count is ' || l_conv_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting origination1 fee structures');
    l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                             ,p_fee_category => 'EVENT'
                                                             ,p_fee_type     => 'EVENT_ORIGINATION'
                                                             ,p_installment  => null
                                                             ,p_phase        => 'TERM'
                                                             ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': origination1 structures count is ' || l_orig_fee_structures.count);

    -- filtering out origination fees based on p_based_on_terms
    n := 0;
    for m in 1..l_orig_fee_structures.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee = ' || l_orig_fee_structures(m).FEE_ID);
        l_billed := null;
        open c_orig_fee_billed(l_loan_id, l_orig_fee_structures(m).FEE_ID, p_based_on_terms);
        fetch c_orig_fee_billed into l_billed;
        close c_orig_fee_billed;

        if l_billed is null then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is not billed yet');
            n := n + 1;
            l_new_orig_fee_structures(n) := l_orig_fee_structures(m);
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is already billed');
        end if;
    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting recurring fee structures');
    l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                       ,p_fee_category => 'RECUR'
                                                       ,p_fee_type     => null
                                                       ,p_installment  => null
                                                       ,p_phase        => 'TERM'
                                                       ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': fee structures count is ' || l_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting memo fee structures');
    l_memo_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                            ,p_fee_category => 'MEMO'
                                                            ,p_fee_type     => null
                                                            ,p_installment  => null
                                                            ,p_phase        => 'TERM'
                                                            ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': memo fee structures count is ' || l_memo_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting funding fee structures');
    l_funding_fee_structures  := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => l_loan_id
                                                                            ,p_installment_no => null
                                                                            ,p_phase          => 'TERM'
                                                                            ,p_disb_header_id => null
                                                                            ,p_fee_id         => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding fee structures count is ' || l_funding_fee_structures.count);

    if p_based_on_terms <> 'CURRENT' then
        open c_fund_sched_exist(l_loan_id);
        fetch c_fund_sched_exist into l_fund_sched_count;
        close c_fund_sched_exist;

        if l_fund_sched_count = 0 then
            l_original_loan_amount := p_loan_details.requested_amount;
        else
            l_original_loan_amount := getFundedAmount(l_loan_id, l_loan_start_date, p_based_on_terms);
        end if;
    else
        l_original_loan_amount := getFundedAmount(l_loan_id, l_loan_start_date, p_based_on_terms);
    end if;

    if l_new_orig_fee_structures.count > 0 or l_conv_fee_structures.count > 0 then

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_original_loan_amount;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := p_loan_details.requested_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_original_loan_amount;
       --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
       --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

       if l_new_orig_fee_structures.count > 0 then

            l_orig_fees_tbl.delete;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => 0
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_new_orig_fee_structures
                                        ,x_fees_tbl         => l_orig_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fees_tbl.count);

            for k in 1..l_orig_fees_tbl.count loop
                l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
            end loop;

       end if;

       open c_conv_fees(l_loan_id);
       fetch c_conv_fees into l_fee_amount1;
       close c_conv_fees;
	   l_fee_amount := l_fee_amount1 + l_fee_amount;

       if l_fee_amount > 0 then
           i := i + 1;
           l_amortization_rec.installment_number   := 0;
           l_amortization_rec.due_date             := l_loan_start_date;
           l_amortization_rec.PERIOD_START_DATE    := l_loan_start_date;
           l_amortization_rec.PERIOD_END_DATE      := l_loan_start_date;
           l_amortization_rec.principal_amount     := 0;
           l_amortization_rec.interest_amount      := 0;
           l_amortization_rec.fee_amount           := l_fee_amount;
           l_amortization_rec.other_amount         := 0;
           l_amortization_rec.begin_balance        := l_original_loan_amount;
           l_amortization_rec.end_balance          := l_original_loan_amount;
           l_amortization_rec.interest_cumulative  := 0;
           l_amortization_rec.principal_cumulative := 0;
           l_amortization_rec.fees_cumulative      := l_fee_amount;
           l_amortization_rec.other_cumulative     := 0;
           l_amortization_rec.rate_id              := 0;
           l_amortization_rec.SOURCE               := 'PREDICTED';
           -- add the record to the amortization table
           l_amortization_rec.total                := l_fee_amount;
           l_amortization_rec.UNPAID_PRIN          := 0;
           l_amortization_rec.UNPAID_INT           := 0;
           l_amortization_rec.INTEREST_RATE        := l_rate_tbl(1).annual_rate;
           l_amortization_rec.NORMAL_INT_AMOUNT    := 0;
           l_amortization_rec.ADD_PRIN_INT_AMOUNT  := 0;
           l_amortization_rec.ADD_INT_INT_AMOUNT   := 0;
           l_amortization_rec.PENAL_INT_AMOUNT     := 0;
           l_amortization_rec.FUNDED_AMOUNT        := l_original_loan_amount;
           l_amortization_rec.PERIOD               := l_loan_start_date || ' - ' || l_loan_start_date;
           l_amortization_rec.DISBURSEMENT_AMOUNT  := 0;

           l_amortization_tbl(i)                   := l_amortization_rec;
       end if;

       --l_orig_fees_tbl.delete;
       l_fee_amount := 0;

    end if;

    -- go to the nth installment (Billing program doesnt need to go thru whole amortization)
    if p_installment_number is not null then

       l_billing        := true;
       if p_installment_number > 0 then

           if p_installment_number > l_num_pay_dates then
                l_payment_number := l_num_pay_dates;
           else
                l_payment_number := p_installment_number;
           end if;

       else
           l_payment_number := p_installment_number;
       end if;

    else

       l_payment_number := l_num_pay_dates;

    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_payment_number = ' || l_payment_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed = ' || l_last_installment_billed);

    l_begin := 1;

    if p_based_on_terms = 'CURRENT' and l_last_installment_billed > 0 then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ----- Querying INSTALLMENT ' || l_last_installment_billed  || '-----');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

        l_periodic_principal := null;
        open c_get_last_payment(l_loan_id, l_last_installment_billed);
        fetch c_get_last_payment into l_periodic_principal, l_begin_funded_amount;
        close c_get_last_payment;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Periodic principal = ' || l_periodic_principal);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

        if l_periodic_principal is not null then

            l_prev_periodic_principal := l_periodic_principal;
            l_begin := l_last_installment_billed + 1;

            if l_rate_tbl.count = 1 then
                l_previous_annualized := l_rate_tbl(1).annual_rate;
                l_previous_interest_only_flag := l_rate_tbl(1).interest_only_flag;
            else
                l_rate_details := lns_financials.getRateDetails(p_installment => l_last_installment_billed
                                                                ,p_rate_tbl => l_rate_tbl);
                l_previous_annualized := l_rate_details.annual_rate;
                l_previous_interest_only_flag := l_rate_details.interest_only_flag;
            end if;

        end if;

    else
        l_remaining_balance_theory := l_original_loan_amount;
        l_begin_funded_amount := 0;  --l_original_loan_amount;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin = ' || l_begin);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_loan_details.REAMORTIZE_ON_FUNDING = ' || p_loan_details.REAMORTIZE_ON_FUNDING);

    l_increase_amount_instal := -1;

    -- loop to build the amortization schedule
    for l_installment_number in l_begin..l_payment_number
    loop

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ----- Calculating INSTALLMENT ' || l_installment_number || '-----');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

       i := i + 1;
       l_periodic_interest      := 0;
--       l_periodic_principal     := 0;
       l_fee_amount             := 0;
       l_other_amount           := 0;
       l_unpaid_principal       := 0;
       l_unpaid_interest        := 0;
       l_intervals_remaining    := l_num_pay_dates - l_installment_number + 1;
       l_detail_int_calc_flag   := false;
       l_increased_amount       := 0;
       l_increased_amount1      := 0;
       l_prev_increase_amount_instal := l_increase_amount_instal;

       if l_fund_sched_count > 0 or p_based_on_terms = 'CURRENT' then

            if (l_last_installment_billed >= 0) and (l_last_installment_billed + 1 = l_installment_number) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 = l_installment_number');

                l_principal_cumulative := 0;
                l_interest_cumulative  := 0;
                l_fees_cumulative      := 0;
                l_other_cumulative     := 0;
                l_sum_periodic_principal := 0;
                l_billed_principal     := p_loan_details.billed_principal;
                l_unbilled_principal   := p_loan_details.unbilled_principal;
                l_unpaid_principal     := p_loan_details.unpaid_principal;
                l_unpaid_interest      := p_loan_details.UNPAID_INTEREST;

                if p_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE);
                    l_begin_funded_amount_new := getFundedAmount(l_loan_id, l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1));
                    l_end_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount_new then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := l_installment_number;
                        else
                            if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := l_installment_number + 1;
                            elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := l_installment_number;
                            end if;
                        end if;

                    elsif l_begin_funded_amount_new > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new > l_begin_funded_amount');
                        l_increase_amount_instal := l_installment_number;
                    end if;

                    l_detail_int_calc_flag := true;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1));
                    l_begin_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                    l_begin_funded_amount := l_begin_funded_amount_new;
                    l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                    l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal;
                else
                    l_remaining_balance_theory := 0;
                end if;

            else

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 < l_installment_number');
                if p_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1));
                    l_begin_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE);
                    l_begin_funded_amount_new := getFundedAmount(l_loan_id, l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1));
                    l_end_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');
                        l_detail_int_calc_flag := true;

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := l_installment_number;
                        else
                            if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := l_installment_number + 1;
                            elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := l_installment_number;
                            end if;
                        end if;

                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_sum_periodic_principal = ' || l_sum_periodic_principal);

                        l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                        l_begin_funded_amount := l_begin_funded_amount_new;
                        l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                        l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal - l_sum_periodic_principal;
                    end if;
                else
                    l_remaining_balance_theory := 0;
                end if;

            end if;

       end if;

       if p_loan_details.REAMORTIZE_ON_FUNDING = 'NO' then
            l_increase_amount_instal := -1;
       end if;

--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_actual: ' || l_remaining_balance_actual);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': getting rate details');
       l_rate_details := getRateDetails(p_installment => l_installment_number
                                       ,p_rate_tbl    => l_rate_tbl);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate annual rate = ' || l_rate_details.annual_rate);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate spread = ' || l_rate_details.spread);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate id = ' || l_rate_details.rate_id);
--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate floating_flag ' || l_rate_details.floating_flag);

        l_current_rate_id             := l_rate_details.rate_id;
        l_annualized_rate             := l_rate_details.annual_rate;
        l_interest_only_flag          := l_rate_details.interest_only_flag;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_rate_id = ' || l_previous_rate_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_current_rate_id = ' || l_current_rate_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_annualized = ' || l_previous_annualized);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_annualized_rate = ' || l_annualized_rate);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_interest_only_flag = ' || l_previous_interest_only_flag);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_interest_only_flag = ' || l_interest_only_flag);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed = ' || l_last_installment_billed);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_extend_from_installment = ' || l_extend_from_installment);
        if l_detail_int_calc_flag then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = true');
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = false');
        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount = ' || l_increased_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount1 = ' || l_increased_amount1);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increase_amount_instal = ' || l_increase_amount_instal);

        -- conditions to recalculate principal payment
        -- 1. 1-st installment
        -- 2. reamortization from installment = current installment
        -- 3. reamortize because loan term has been extended
        -- 4. emerging from interest only period
        -- 5. funded amount has increased since last installment

        if ((l_installment_number = 1) OR
            (l_reamortize_from_installment >= 0 and (l_last_installment_billed + 1 = l_installment_number)) OR
            (l_extend_from_installment is not null and (l_extend_from_installment + 1 >= l_installment_number)) OR
            (l_previous_interest_only_flag = 'Y' and  l_interest_only_flag = 'N' and l_prev_periodic_principal = 0) OR
            (l_prev_increase_amount_instal = l_installment_number or l_increase_amount_instal = l_installment_number))
        then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- RE-calculating periodic principal payment');

            -- fix for bug 6599682: EQUALLY SPREAD PRINCIPAL FROM IO PERIODS FOR EPRP LOANS
            l_non_ro_intervals := get_num_non_ro_instal(l_rate_tbl, l_installment_number, l_orig_num_install) + l_intervals_diff;

--            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ': l_amortization_intervals=' || l_amortization_intervals);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ': l_non_ro_intervals = ' || l_non_ro_intervals);
/*
            if l_installment_number = 1 and l_reamortize_from_installment is null then
                l_remaining_balance := l_original_loan_amount;
            else
                l_remaining_balance := l_remaining_balance_theory;
            end if;
*/
            l_remaining_balance := l_remaining_balance_theory + l_increased_amount1;

            l_periodic_principal := lns_financials.calculateEPPayment(p_loan_amount   => l_remaining_balance
                                                            ,p_num_intervals => l_non_ro_intervals
                                                            --,p_num_intervals => l_amortization_intervals
                                                            ,p_ending_balance=> l_balloon_amount
                                                            ,p_pay_in_arrears=> l_pay_in_arrears);
            l_prev_periodic_principal := l_periodic_principal;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': NEW periodic principal = ' || l_periodic_principal);

        else
            l_periodic_principal := l_prev_periodic_principal;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': KEEPING OLD periodic principal = ' || l_periodic_principal);
        end if;

        l_previous_interest_only_flag := l_interest_only_flag;
        l_previous_rate_id            := l_current_rate_id;
        l_previous_annualized         := l_annualized_rate;

        l_norm_interest := 0;
        l_add_prin_interest := 0;
        l_add_int_interest := 0;
        l_penal_prin_interest := 0;
        l_penal_int_interest := 0;
        l_penal_interest := 0;
        l_norm_int_detail_str := null;
        l_add_prin_int_detail_str := null;
        l_add_int_int_detail_str := null;
        l_penal_prin_int_detail_str := null;
        l_penal_int_int_detail_str := null;
        l_penal_int_detail_str := null;

        -- now we will caculate the interest due for this period
       -- now we will calculate the interest due
--       if ((p_based_on_terms = 'CURRENT' and l_last_installment_billed >= 0 and l_last_installment_billed + 1 = l_installment_number) or
--           (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true)) then
       if (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true) then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating normal interest...');
            LNS_FINANCIALS.CALC_NORM_INTEREST(p_loan_id => l_loan_id,
                                p_calc_method => l_calc_method,
                                p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                p_period_end_date => l_payment_tbl(l_installment_number).period_end_date,
                                p_interest_rate => l_annualized_rate,
                                p_day_count_method => l_day_count_method,
                                p_payment_freq => l_payment_frequency,
                                p_compound_freq => l_compound_freq,
                                p_adj_amount => l_sum_periodic_principal,
                                x_norm_interest => l_norm_interest,
                                x_norm_int_details => l_norm_int_detail_str);

            l_norm_interest  := round(l_norm_interest, l_precision);

            if (l_installment_number-1) >= 0 and l_last_installment_billed + 1 = l_installment_number then

                -- get additional interest start date
                open c_get_last_bill_date(l_loan_id, (l_installment_number-1));
                fetch c_get_last_bill_date into l_add_start_date;
                close c_get_last_bill_date;

                -- get additional interest end date
                --l_add_end_date := l_payment_tbl(l_installment_number).period_end_date;

                if trunc(sysdate) > trunc(l_payment_tbl(l_installment_number).period_end_date) then
                    l_add_end_date := l_payment_tbl(l_installment_number).period_end_date;
                else
                    l_add_end_date := sysdate;
                end if;

                if (l_installment_number-1) > 0 then
                    l_prev_grace_end_date := l_payment_tbl(l_installment_number-1).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS;
                else
                    l_prev_grace_end_date := l_payment_tbl(l_installment_number).period_begin_date;
                end if;

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid principal...');
                -- calculate additional interest on unpaid principal
                LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => l_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_frequency,
                                    p_compound_freq => l_compound_freq,
                                    p_penal_int_rate => p_loan_details.PENAL_INT_RATE,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_grace_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                    p_grace_end_date => (l_payment_tbl(l_installment_number).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_PRIN',
                                    x_add_interest => l_add_prin_interest,
                                    x_penal_interest => l_penal_prin_interest,
                                    x_add_int_details => l_add_prin_int_detail_str,
                                    x_penal_int_details => l_penal_prin_int_detail_str);
                l_add_prin_interest  := round(l_add_prin_interest, l_precision);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid interest...');
                -- calculate additional interest on unpaid interest
                LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => l_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_frequency,
                                    p_compound_freq => l_compound_freq,
                                    p_penal_int_rate => p_loan_details.PENAL_INT_RATE,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_grace_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                    p_grace_end_date => (l_payment_tbl(l_installment_number).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_INT',
                                    x_add_interest => l_add_int_interest,
                                    x_penal_interest => l_penal_int_interest,
                                    x_add_int_details => l_add_int_int_detail_str,
                                    x_penal_int_details => l_penal_int_int_detail_str);
                l_add_int_interest  := round(l_add_int_interest, l_precision);

                if l_penal_prin_int_detail_str is not null and l_penal_int_int_detail_str is not null then
                    l_penal_int_detail_str := l_penal_prin_int_detail_str || ' +<br>' || l_penal_int_int_detail_str;
                else
                    l_penal_int_detail_str := l_penal_prin_int_detail_str || l_penal_int_int_detail_str;
                end if;
            end if;

       elsif (p_based_on_terms <> 'CURRENT' and l_detail_int_calc_flag = true) then

            if (l_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies
                l_periodic_rate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_frequency
                                            ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'INTEREST');

            elsif (l_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                ,p_payment_freq => l_payment_frequency
                                ,p_annualized_rate => l_annualized_rate
                                ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                                ,p_days_count_method => l_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                            ,p_from_date        => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_to_date          => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_calc_method      => 'TARGET'
                                            ,p_phase            => 'TERM'
                                            ,p_day_count_method => l_day_count_method
                                            ,p_adj_amount       => l_sum_periodic_principal
                                            ,x_wtd_balance      => l_wtd_balance
                                            ,x_begin_balance    => l_balance1
                                            ,x_end_balance      => l_balance2);

            l_norm_interest := lns_financials.calculateInterest(p_amount => l_wtd_balance
                                                                ,p_periodic_rate => l_periodic_rate
                                                                ,p_compounding_period => null);
            l_norm_interest := round(l_norm_interest, l_precision);

            l_norm_int_detail_str :=
                'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
                ' * Balance: ' || l_wtd_balance ||
                ' * Rate: ' || l_annualized_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

       else

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_remaining_balance_actual);

            if (l_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies

                l_periodic_rate := lns_financials.getPeriodicRate(
                                        p_payment_freq      => l_payment_frequency
                                        ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                        ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                        ,p_annualized_rate   => l_annualized_rate
                                        ,p_days_count_method => l_day_count_method
                                        ,p_target            => 'INTEREST');

            elsif (l_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                ,p_payment_freq => l_payment_frequency
                                ,p_annualized_rate => l_annualized_rate
                                ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                                ,p_days_count_method => l_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            l_norm_interest := lns_financials.calculateInterest(p_amount             => l_remaining_balance_theory --l_remaining_balance_actual
                                                                ,p_periodic_rate      => l_periodic_rate
                                                                ,p_compounding_period => null);
            l_norm_interest  := round(l_norm_interest, l_precision);

            l_norm_int_detail_str :=
                'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
                ' * Balance: ' || l_remaining_balance_theory ||
                ' * Rate: ' || l_annualized_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

       end if;

       l_penal_interest := round(l_penal_prin_interest + l_penal_int_interest, l_precision);
       l_periodic_interest := round(l_norm_interest + l_add_prin_interest + l_add_int_interest + l_penal_interest, l_precision);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal = ' || l_periodic_principal);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_interest = ' || l_periodic_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_penal_interest = ' || l_penal_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_intervals_remaining = ' || l_intervals_remaining);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_unbilled_principal = ' || l_unbilled_principal);

       if l_interest_only_flag <> 'Y' or l_intervals_remaining = 1 then

           if (l_remaining_balance_theory  + l_increased_amount1) < l_periodic_principal or l_intervals_remaining = 1 then
              l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
           end if;

       else
           -- we are in an interest only period
           l_periodic_principal := 0;

       end if;

       l_periodic_principal := round(l_periodic_principal, l_precision);
       l_periodic_payment := l_periodic_principal + l_periodic_interest;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_payment = ' || l_periodic_payment);

       -- calculate balances and total payment
       l_begin_balance        := l_remaining_balance_theory;
       l_end_balance          := l_remaining_balance_theory - l_periodic_principal + l_increased_amount1;

       -- check to see if this loan has been billed
       if l_unbilled_principal > 0 then
         l_unbilled_principal := l_unbilled_principal - l_periodic_principal;
       end if;

       -- build the amortization record
       -- this information is needed to calculate fees
       -- rest of the record can be built after fees are calculated
       l_amortization_rec.installment_number   := l_installment_number;  /* needed to calculate fees */
       l_amortization_rec.due_date             := l_payment_tbl(l_installment_number).period_due_date;
       l_amortization_rec.PERIOD_START_DATE    := l_payment_tbl(l_installment_number).period_begin_date;
       l_amortization_rec.PERIOD_END_DATE      := l_payment_tbl(l_installment_number).period_end_date;
       l_amortization_rec.principal_amount     := l_periodic_principal;  /* needed to calculate fees */
       l_amortization_rec.interest_amount      := l_periodic_interest;
       l_amortization_rec.begin_balance        := l_begin_balance;       /* needed to calculate fees */
       l_amortization_rec.end_balance          := l_end_balance;
       l_amortization_rec.UNPAID_PRIN          := l_unpaid_principal;
       l_amortization_rec.UNPAID_INT           := l_unpaid_interest;
       l_amortization_rec.INTEREST_RATE        := l_annualized_rate;
       l_amortization_rec.NORMAL_INT_AMOUNT    := l_norm_interest;
       l_amortization_rec.ADD_PRIN_INT_AMOUNT  := l_add_prin_interest;
       l_amortization_rec.ADD_INT_INT_AMOUNT   := l_add_int_interest;
       l_amortization_rec.PENAL_INT_AMOUNT     := l_penal_interest;
       l_amortization_rec.PERIOD               := l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1);
       l_amortization_rec.DISBURSEMENT_AMOUNT  := l_increased_amount;

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_amortization_rec.begin_balance;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := p_loan_details.requested_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_begin_funded_amount;
       l_fee_amount := 0;

       if l_installment_number = 1 then

            if l_new_orig_fee_structures.count > 0 then

                l_orig_fees_tbl.delete;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
                lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                            ,p_installment      => l_installment_number
                                            ,p_fee_basis_tbl    => l_fee_basis_tbl
                                            ,p_fee_structures   => l_new_orig_fee_structures
                                            ,x_fees_tbl         => l_orig_fees_tbl
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees = ' || l_orig_fees_tbl.count);

                for k in 1..l_orig_fees_tbl.count loop
                        l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
                end loop;

            end if;

       end if;

       l_memo_fees_tbl.delete;
       if l_memo_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for memo fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_memo_fee_structures
                                        ,x_fees_tbl         => l_memo_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated memo fees ' || l_memo_fees_tbl.count);
       end if;

       l_fees_tbl.delete;
       if l_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for recurring fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_fee_structures
                                        ,x_fees_tbl         => l_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated recurring fees ' || l_fees_tbl.count);
       end if;

       -- calculate the funding fees
       l_funding_fees_tbl.delete;
       if l_funding_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for funding fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_funding_fee_structures
                                        ,x_fees_tbl         => l_funding_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated funding fees ' || l_fees_tbl.count);
       end if;

       for k in 1..l_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_fees_tbl(k).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': recurring calculated fees = ' || l_fee_amount);
       end loop;

       for j in 1..l_funding_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_funding_fees_tbl(j).FEE_AMOUNT;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding calculated fees = ' || l_fee_amount);
       end loop;

       for j in 1..l_memo_fees_tbl.count loop
              l_other_amount := l_other_amount + l_memo_fees_tbl(j).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': other calculated fees = ' || l_other_amount);
       end loop;

       l_total                                 := l_fee_amount + l_periodic_principal + l_periodic_interest + l_other_amount;
       l_amortization_rec.total                := l_total;
       l_amortization_rec.fee_amount           := l_fee_amount;
       l_amortization_rec.other_amount         := l_other_amount;

       -- running totals calculated here
       l_principal_cumulative := l_principal_cumulative + l_periodic_principal;
       l_interest_cumulative  := l_interest_cumulative + l_periodic_interest;
       l_fees_cumulative      := l_fees_cumulative + l_fee_amount;
       l_other_cumulative     := l_other_cumulative + l_other_amount;

       l_amortization_rec.interest_cumulative  := l_interest_cumulative;
       l_amortization_rec.principal_cumulative := l_principal_cumulative;
       l_amortization_rec.fees_cumulative      := l_fees_cumulative;
       l_amortization_rec.other_cumulative     := l_other_cumulative;
       l_amortization_rec.rate_id              := l_current_rate_id;
       l_amortization_rec.SOURCE               := 'PREDICTED';
       l_amortization_rec.FUNDED_AMOUNT        := l_end_funded_amount;

       l_amortization_rec.NORMAL_INT_DETAILS   := l_norm_int_detail_str;
       l_amortization_rec.ADD_PRIN_INT_DETAILS := l_add_prin_int_detail_str;
       l_amortization_rec.ADD_INT_INT_DETAILS  := l_add_int_int_detail_str;
       l_amortization_rec.PENAL_INT_DETAILS    := l_penal_int_detail_str;

       -- add the record to the amortization table
       l_amortization_tbl(i)                   := l_amortization_rec;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INSTALLMENT ' || l_installment_number);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD = ' || l_amortization_rec.PERIOD);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_START_DATE = ' || l_amortization_rec.PERIOD_START_DATE);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_END_DATE = ' || l_amortization_rec.PERIOD_END_DATE);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'due date = ' || l_amortization_rec.due_date);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_principal = ' || l_amortization_rec.principal_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_interest = ' || l_amortization_rec.interest_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fee_amount = ' || l_amortization_rec.fee_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other_amount = ' || l_amortization_rec.other_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'total = ' || l_amortization_rec.total);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'begin_balance = ' || l_amortization_rec.begin_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'end_balance = ' || l_amortization_rec.end_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'interest_cumulative = ' || l_amortization_rec.interest_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'principal_cumulative = ' || l_amortization_rec.principal_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fees_cumulative = ' || l_amortization_rec.fees_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other_cumulative = ' || l_amortization_rec.other_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'current_rate_id = ' || l_amortization_rec.rate_id );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INTEREST_RATE = ' || l_amortization_rec.INTEREST_RATE );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_PRIN = ' || l_amortization_rec.UNPAID_PRIN );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_INT = ' || l_amortization_rec.UNPAID_INT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_AMOUNT = ' || l_amortization_rec.NORMAL_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_AMOUNT = ' || l_amortization_rec.ADD_PRIN_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_AMOUNT = ' || l_amortization_rec.ADD_INT_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_AMOUNT = ' || l_amortization_rec.PENAL_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FUNDED_AMOUNT = ' || l_amortization_rec.FUNDED_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_DETAILS = ' || l_amortization_rec.NORMAL_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_DETAILS = ' || l_amortization_rec.ADD_PRIN_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_DETAILS_AMOUNT = ' || l_amortization_rec.ADD_INT_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_DETAILS = ' || l_amortization_rec.PENAL_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');

       -- adjust new loan amount to reflect less periodic principal paid
       -- theoretically without over/underpayments l_loan_amount should = l_remaining_balance
       -- if they diverge then we will calculate interest based from l_remaining_balance
       -- rather than l_loan_amount
       l_remaining_balance_theory :=  l_end_balance;
       l_sum_periodic_principal := l_sum_periodic_principal + l_periodic_principal;

       -- clean up
       l_orig_fees_tbl.delete;
       l_memo_fees_tbl.delete;
       l_fees_tbl.delete;
       l_funding_fees_tbl.delete;

    end loop;

    --printAmortizationTable(p_amort_tbl => l_amortization_tbl);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AMORTIZATION TABLE COUNT = ' || l_amortization_tbl.count);
    x_loan_amort_tbl := l_amortization_tbl;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end amortizeEPLoan;




/*=========================================================================
|| PUBLIC PROCEDURE amortizeLoan
||
|| DESCRIPTION
||
|| Overview: procedure will run an amortization
||            this is the main calculation API for amortization
||            THIS API WILL BE CALLED FROM 2 PLACES PRIMARILY:
||           1. Amortization UI - when creating a loan
||           2. Billing Engine  - to generate installment bills
||
|| Parameter: p_loan_details  = details of the loan
||            p_rate_schedule = rate schedule for the loan
||            p_installment_number => billing will pass in an installment
||                                    number to generate a billt
||            x_loan_amort_tbl => table of amortization records
||
|| Source Tables:  NA
||
|| Target Tables:
||
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/12/2003 11:35AM     raverma           Created
||  2/26/2004             raverma           coded in multiple rates
|| 10/28/2004             raverma           added interest only flag
|| 06/20/2008             scherkas          Synch amortizeLoan procedure with LNS_FINANCIALS 115.112 version
 *=======================================================================*/
procedure amortizeLoan(p_loan_details       in  LNS_FINANCIALS.LOAN_DETAILS_REC
                      ,p_rate_schedule      in  LNS_FINANCIALS.RATE_SCHEDULE_TBL
                      ,p_based_on_terms     in  varchar2
                      ,p_installment_number in  number
                      ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL)
is
    l_return_status                  varchar2(1);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(32767);
    -- loan_details
    l_loan_id                        number;
    l_original_loan_amount           number;  -- loan amount
    l_balloon_amount                 number;
    l_amortized_amount               number;  -- amount of loan less balloon amount
    l_loan_term                      number;
    l_amortized_term                 number;
    l_amortized_term_period          varchar2(30);
    l_amortization_frequency         varchar2(30);
    l_first_payment_date             date;
    l_pay_in_arrears                 boolean;
    l_payment_frequency              varchar2(30);
    l_day_count_method               varchar2(30);
    l_interest_comp_freq             varchar2(30);
    l_reamortize_from_installment    number;
    l_reamortize_amount              number;
    l_annualized_rate                number;  -- annual rate on the loan
    l_raw_rate                       number;  --
--    l_intervals_original             number;
--    l_intervals                      number;
    l_intervals_remaining            number;
    l_amortization_intervals_orig    number;
--    l_amortization_intervals_rem     number;
    l_amortization_intervals         number;  -- number of intervals to amortize over
    l_rate_details                   LNS_FINANCIALS.INTEREST_RATE_REC;
    l_current_rate_id                number;
    l_previous_rate_id               number;
    l_precision                      number;
    l_rate_type                      varchar2(30);
    l_open_rate_change_frequency	 varchar2(30);
    l_open_index_rate_id 			 number;
    l_open_ceiling_rate				 number;
    l_open_floor_rate 				 number;
    l_term_rate_change_frequency	 varchar2(30);
    l_term_index_rate_id 			 number;
    l_term_ceiling_rate				 number;
    l_term_floor_rate 				 number;

    l_period_start_Date              date;
    l_period_end_date                date;
    l_periodic_rate                  number;
    l_maturity_date                  date;
    l_amortized_maturity_date        date;

    l_amortization_rec               LNS_FINANCIALS.AMORTIZATION_REC;
    l_amortization_tbl               LNS_FINANCIALS.AMORTIZATION_TBL;
    l_rate_tbl                       LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_payment_tbl                    LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_amortized_payment_tbl          LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_loan_start_date                date;
    l_num_pay_dates                  number;  -- number of dates on installment schedule
    l_periodic_payment               number;
    l_periodic_principal             number;
    l_periodic_interest              number;
    l_total_principal                number;
    l_payment_number                 number;
    l_fee_amount                     number;
    l_fee_amount1                    number;
    l_other_amount                   number;
    l_begin_balance                  number;
    l_end_balance                    number;
    l_unbilled_principal             number;
    l_unpaid_principal               number;
    l_unpaid_interest                number;

    l_remaining_balance_actual       number;
    l_remaining_balance_theory       number;
    l_total                          number;
    l_interest_cumulative            number;
    l_principal_cumulative           number;
    l_fees_cumulative                number;
    l_other_cumulative               number;
    i                                number;
    l_installment_number             number;
    l_billing                        boolean;  -- switch to notify if billing is calling API
    l_api_name                       varchar2(20);
    l_last_installment_billed        number;
    l_rate_to_calculate              number;
    l_previous_annualized            number;
    l_previous_interest_only_flag    varchar2(1);
    l_interest_only_flag             varchar2(1);
    l_calc_method                    varchar2(30);
    l_compound_freq                  varchar2(30);
    l_remaining_balance_actual1      number;
    l_ending_balance                 number;
    l_due_date                       date;
    l_begin                          number;
    l_installment_number1            number;
    l_norm_interest                  number;
    l_add_prin_interest              number;
    l_add_int_interest               number;
    l_add_start_date                 date;
    l_add_end_date                   date;
    l_penal_prin_interest            number;
    l_penal_int_interest             number;
    l_penal_interest                 number;
    l_first_installment_billed       number;
    l_extend_from_installment        number;
    l_remaining_balance              number;
    l_prev_grace_end_date            date;
    l_disb_header_id                 number;
    l_billed                         varchar2(1);
    n                                number;
    l_sum_periodic_principal         number;
    l_date1                          date;
    l_billed_principal               number;
    l_detail_int_calc_flag           boolean;
    l_increased_amount               number;
    l_increased_amount1              number;
    l_begin_funded_amount            number;
    l_end_funded_amount              number;
    l_increase_amount_instal         number;
    l_prev_increase_amount_instal    number;
    l_begin_funded_amount_new        number;
    l_fund_sched_count               number;
    l_wtd_balance                    number;
    l_balance1                       number;
    l_balance2                       number;

    l_norm_int_detail_str            varchar2(2000);
    l_add_prin_int_detail_str        varchar2(2000);
    l_add_int_int_detail_str         varchar2(2000);
    l_penal_prin_int_detail_str      varchar2(2000);
    l_penal_int_int_detail_str       varchar2(2000);
    l_penal_int_detail_str           varchar2(2000);

    -- for fees
    l_fee_structures                 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_memo_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_orig_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
--    l_orig_fee_structures1           LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_new_orig_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_funding_fee_structures         LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
	l_conv_fee_structures			 LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fees_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_memo_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_funding_fees_tbl               LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl                  LNS_FEE_ENGINE.FEE_BASIS_TBL;

    cursor c_conv_fees(p_loan_id number) is
    select nvl(sum(fee),0)
      from lns_fee_assignments
     where loan_id = p_loan_id
       and fee_type = 'EVENT_CONVERSION';

    -- get last bill date
    cursor c_get_last_bill_date(p_loan_id number, p_installment_number number)  is
        select ACTIVITY_DATE
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and PARENT_AMORTIZATION_ID is null
        and ACTIVITY_CODE in ('BILLING', 'START');

    -- get last billed payment info
    cursor c_get_last_payment(p_loan_id number, p_installment_number number)  is
        select (PRINCIPAL_AMOUNT + INTEREST_AMOUNT), nvl(FUNDED_AMOUNT, 0)
        from lns_amortization_scheds
        where loan_id = p_loan_id
        and PAYMENT_NUMBER > 0
        and PAYMENT_NUMBER = p_installment_number
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and PARENT_AMORTIZATION_ID is null
        and REAMORTIZE_TO_INSTALLMENT is null
        --and PRINCIPAL_AMOUNT > 0
        and nvl(PHASE, 'TERM') = 'TERM';
        --order by PAYMENT_NUMBER desc;

    -- get first billed installment number
    cursor c_first_billed_instal(p_loan_id number)  is
        select min(PAYMENT_NUMBER)
        from LNS_AMORTIZATION_SCHEDS
        where loan_id = p_loan_id
        and PAYMENT_NUMBER > 0
        and (REVERSED_FLAG is null or REVERSED_FLAG = 'N')
        and PARENT_AMORTIZATION_ID is null
        and nvl(PHASE, 'TERM') = 'TERM';

    cursor c_orig_fee_billed(p_loan_id number, p_fee_id number, p_based_on_terms varchar2) is
        select 'X'
        from lns_fee_schedules sched
            ,lns_fees struct
        where sched.loan_id = p_loan_id
        and sched.fee_id = p_fee_id
        and sched.fee_id = struct.fee_id
        and struct.fee_type = 'EVENT_ORIGINATION'
        and sched.active_flag = 'Y'
        and decode(p_based_on_terms, 'CURRENT', sched.billed_flag, 'N') = 'Y'
        and sched.phase = 'TERM';

    cursor c_fund_sched_exist(p_loan_id number)  is
        select decode(loan.loan_class_code,
            'DIRECT', (select count(1) from lns_disb_headers where loan_id = p_loan_id and status is null and PAYMENT_REQUEST_DATE is not null),
            'ERS', (select count(1) from lns_loan_lines where loan_id = p_loan_id and (status is null or status = 'PENDING') and end_date is null))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

begin

    -- initialize all variables
    l_original_loan_amount          := 0;  -- loan amount
	l_amortized_amount              := 0;
    l_previous_rate_id              := -1;
    l_previous_annualized           := -1;
    l_previous_interest_only_flag   := 'N';    -- default to regular interest + principal
    l_periodic_payment              := 0;
    l_periodic_principal            := 0;
    l_periodic_interest             := 0;
	l_balloon_amount                := 0;
    l_total_principal               := 0;
    l_payment_number                := 0;
    l_fee_amount                    := 0;
    l_other_amount                  := 0;
    l_begin_balance                 := 0;
    l_unbilled_principal            := 0;
    l_billed_principal              := 0;
    l_unpaid_principal              := 0;
    l_remaining_balance_actual      := 0;
    l_remaining_balance_theory      := 0;
    l_total                         := 0;
    l_interest_cumulative           := 0;
    l_principal_cumulative          := 0;
    l_fees_cumulative               := 0;
    l_other_cumulative              := 0;
    i                               := 0;
    l_installment_number            := 1;  -- begin from #1 installment, NOT #0 installment
    l_rate_to_calculate             := 0;
    l_billing                       := false;  -- switch to notify if billing is calling API
    l_sum_periodic_principal        := 0;
    l_api_name                      := 'amortizeLoan MAIN';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - based on TERMS====> ' || p_based_on_terms);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_installment_number = ' || p_installment_number);

    l_loan_term                     := p_loan_details.loan_term;
	l_amortized_amount              := p_loan_details.amortized_amount;
    l_amortized_term                := p_loan_details.amortized_term;
    l_amortized_term_period         := p_loan_details.amortized_term_period;
    l_amortization_frequency        := p_loan_details.amortization_frequency;
--    l_amortization_intervals_orig   := p_loan_details.num_amortization_intervals;
--    l_amortization_intervals        := p_loan_details.num_amortization_intervals;
--    l_amortization_intervals_rem    := p_loan_details.num_amortization_intervals;
	l_balloon_amount                := p_loan_details.balloon_payment_amount;
    l_day_count_method              := p_loan_details.day_count_method;
    l_first_payment_date            := p_loan_details.first_payment_date;
    l_loan_id                       := p_loan_details.loan_id;
--    l_intervals                     := p_loan_details.number_installments;
--    l_intervals_original            := p_loan_details.number_installments;
    l_last_installment_billed       := p_loan_details.last_installment_billed;
    l_loan_start_date               := p_loan_details.loan_start_date;
    l_maturity_date                 := p_loan_details.maturity_date;
    l_rate_type                     := p_loan_details.rate_type;
    l_open_rate_change_frequency	:= p_loan_details.open_rate_chg_freq;
    l_open_index_rate_id 			:= p_loan_details.open_index_rate_id;
    l_open_ceiling_rate				:= p_loan_details.open_ceiling_rate;
    l_open_floor_rate 				:= p_loan_details.open_floor_rate;
    l_original_loan_amount          := p_loan_details.requested_amount;
    l_pay_in_arrears                := p_loan_details.pay_in_arrears_boolean;
    l_payment_frequency             := p_loan_details.payment_frequency;
    l_precision                     := p_loan_details.currency_precision;
    l_reamortize_from_installment   := p_loan_details.reamortize_from_installment;
    l_reamortize_amount             := p_loan_details.reamortize_amount;
    l_remaining_balance_actual      := p_loan_details.remaining_balance;
    l_remaining_balance_actual1     := p_loan_details.remaining_balance;
    l_term_rate_change_frequency	:= p_loan_details.term_rate_chg_freq;
    l_term_index_rate_id 			:= p_loan_details.term_index_rate_id;
    l_term_ceiling_rate				:= p_loan_details.term_ceiling_rate;
    l_term_floor_rate 				:= p_loan_details.term_floor_rate;
    l_calc_method                   := p_loan_details.CALCULATION_METHOD;
    l_compound_freq                 := p_loan_details.INTEREST_COMPOUNDING_FREQ;
    l_extend_from_installment       := p_loan_details.EXTEND_FROM_INSTALLMENT;

    -- get the interest rate schedule
    l_rate_tbl := p_rate_schedule;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- rate schedule count = ' || l_rate_tbl.count);

    -- get payment schedule
    -- this will return the acutal dates that payments will be due on
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting payment schedule');
    l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                       ,p_loan_maturity_date => l_maturity_date
                                                       ,p_first_pay_date     => l_first_payment_date
                                                       ,p_num_intervals      => null --l_intervals
                                                       ,p_interval_type      => l_payment_frequency
                                                       ,p_pay_in_arrears     => l_pay_in_arrears);

    l_num_pay_dates := l_payment_tbl.count;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- payment schedule count = ' || l_num_pay_dates);

    if l_loan_term <> l_amortized_term then

        -- get amortize maturity date
        l_amortized_maturity_date := LNS_FIN_UTILS.getMaturityDate(p_term         => l_amortized_term
                                                            ,p_term_period  => l_amortized_term_period
                                                            ,p_frequency    => l_payment_frequency
                                                            ,p_start_date   => l_loan_start_date);
        -- get amortize payment schedule
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting amortize payment schedule');
        l_amortized_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                        ,p_loan_maturity_date => l_amortized_maturity_date
                                                        ,p_first_pay_date     => l_first_payment_date
                                                        ,p_num_intervals      => null --l_intervals
                                                        ,p_interval_type      => l_payment_frequency
                                                        ,p_pay_in_arrears     => l_pay_in_arrears);

        l_amortization_intervals := l_amortized_payment_tbl.count;
    else
        l_amortization_intervals := l_num_pay_dates;
    end if;
    l_amortization_intervals_orig := l_amortization_intervals;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- amortize payment schedule count = ' || l_amortization_intervals);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting conv fee structures');
    l_conv_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                             ,p_fee_category => 'EVENT'
                                                             ,p_fee_type     => 'EVENT_CONVERSION'
                                                             ,p_installment  => null
                                                             ,p_phase        => 'TERM'
                                                             ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': conv structures count = ' || l_conv_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting origination1 fee structures');
    l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                             ,p_fee_category => 'EVENT'
                                                             ,p_fee_type     => 'EVENT_ORIGINATION'
                                                             ,p_installment  => null
                                                             ,p_phase        => 'TERM'
                                                             ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': origination1 structures count is ' || l_orig_fee_structures.count);

    -- filtering out origination fees based on p_based_on_terms
    n := 0;
    for m in 1..l_orig_fee_structures.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee = ' || l_orig_fee_structures(m).FEE_ID);
        l_billed := null;
        open c_orig_fee_billed(l_loan_id, l_orig_fee_structures(m).FEE_ID, p_based_on_terms);
        fetch c_orig_fee_billed into l_billed;
        close c_orig_fee_billed;

        if l_billed is null then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is not billed yet');
            n := n + 1;
            l_new_orig_fee_structures(n) := l_orig_fee_structures(m);
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is already billed');
        end if;
    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting recurring fee structures');
    l_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                       ,p_fee_category => 'RECUR'
                                                       ,p_fee_type     => null
                                                       ,p_installment  => null
                                                       ,p_phase        => 'TERM'
                                                       ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': fee structures count = ' || l_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting memo fee structures');
    l_memo_fee_structures := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                            ,p_fee_category => 'MEMO'
                                                            ,p_fee_type     => null
                                                            ,p_installment  => null
                                                            ,p_phase        => 'TERM'
                                                            ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': memo fee structures count = ' || l_memo_fee_structures.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting funding fee structures');
    l_funding_fee_structures  := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => l_loan_id
                                                                            ,p_installment_no => null
                                                                            ,p_phase          => 'TERM'
                                                                            ,p_disb_header_id => null
                                                                            ,p_fee_id         => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding fee structures count is ' || l_funding_fee_structures.count);

    if p_based_on_terms <> 'CURRENT' then
        open c_fund_sched_exist(l_loan_id);
        fetch c_fund_sched_exist into l_fund_sched_count;
        close c_fund_sched_exist;

        if l_fund_sched_count = 0 then
            l_original_loan_amount := p_loan_details.requested_amount;
        else
            l_original_loan_amount := getFundedAmount(l_loan_id, l_loan_start_date, p_based_on_terms);
        end if;
    else
        l_original_loan_amount := getFundedAmount(l_loan_id, l_loan_start_date, p_based_on_terms);
    end if;

    if l_new_orig_fee_structures.count > 0 or l_conv_fee_structures.count > 0 then

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_original_loan_amount;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := p_loan_details.requested_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_original_loan_amount;
       --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
       --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

       if l_new_orig_fee_structures.count > 0 then

            l_orig_fees_tbl.delete;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => 0
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_new_orig_fee_structures
                                        ,x_fees_tbl         => l_orig_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees = ' || l_orig_fees_tbl.count);

            for k in 1..l_orig_fees_tbl.count loop
                    l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
            end loop;

       end if;

       open c_conv_fees(l_loan_id);
       fetch c_conv_fees into l_fee_amount1;
       close c_conv_fees;
	   l_fee_amount := l_fee_amount1 + l_fee_amount;

       if l_fee_amount > 0 then
           i := i + 1;
           l_amortization_rec.installment_number   := 0;
           l_amortization_rec.due_date             := l_loan_start_date;
           l_amortization_rec.PERIOD_START_DATE    := l_loan_start_date;
           l_amortization_rec.PERIOD_END_DATE      := l_loan_start_date;
           l_amortization_rec.principal_amount     := 0;
           l_amortization_rec.interest_amount      := 0;
           l_amortization_rec.fee_amount           := l_fee_amount;
           l_amortization_rec.other_amount         := 0;
           l_amortization_rec.begin_balance        := l_original_loan_amount;
           l_amortization_rec.end_balance          := l_original_loan_amount;
           l_amortization_rec.interest_cumulative  := 0;
           l_amortization_rec.principal_cumulative := 0;
           l_amortization_rec.fees_cumulative      := l_fee_amount;
           l_amortization_rec.other_cumulative     := 0;
           l_amortization_rec.rate_id              := 0;
           l_amortization_rec.SOURCE               := 'PREDICTED';
           -- add the record to the amortization table
           l_amortization_rec.total                := l_fee_amount;
           l_amortization_rec.UNPAID_PRIN          := 0;
           l_amortization_rec.UNPAID_INT           := 0;
           l_amortization_rec.INTEREST_RATE        := l_rate_tbl(1).annual_rate;
           l_amortization_rec.NORMAL_INT_AMOUNT    := 0;
           l_amortization_rec.ADD_PRIN_INT_AMOUNT  := 0;
           l_amortization_rec.ADD_INT_INT_AMOUNT   := 0;
           l_amortization_rec.PENAL_INT_AMOUNT     := 0;
           l_amortization_rec.FUNDED_AMOUNT        := l_original_loan_amount;
           l_amortization_rec.PERIOD               := l_loan_start_date || ' - ' || l_loan_start_date;
           l_amortization_rec.DISBURSEMENT_AMOUNT  := 0;

           l_amortization_tbl(i)                   := l_amortization_rec;
       end if;

       --l_orig_fees_tbl.delete;
       l_fee_amount := 0;

    end if;

    -- go to the nth installment (Billing program doesnt need to go thru whole amortization)
    if p_installment_number is not null then
       -- we are billing

       l_billing        := true;
       if p_installment_number > 0 then

           if p_installment_number > l_num_pay_dates then
                l_payment_number := l_num_pay_dates;
           else
                l_payment_number := p_installment_number;
           end if;

       else
           l_payment_number := p_installment_number;
       end if;

    else -- we are not billing, go thru entire amortization

       l_payment_number := l_num_pay_dates;

    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_payment_number = ' || l_payment_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed = ' || l_last_installment_billed);

    l_begin := 1;

    if p_based_on_terms = 'CURRENT' and l_last_installment_billed > 0 then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ----- Querying INSTALLMENT ' || l_last_installment_billed  || '-----');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

        l_periodic_payment := null;
        open c_get_last_payment(l_loan_id, l_last_installment_billed);
        fetch c_get_last_payment into l_periodic_payment, l_begin_funded_amount;
        close c_get_last_payment;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Periodic payment = ' || l_periodic_payment);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

        if l_periodic_payment is not null then

            l_begin := l_last_installment_billed + 1;

            if l_rate_tbl.count = 1 then
                l_previous_annualized := l_rate_tbl(1).annual_rate;
                l_previous_interest_only_flag := l_rate_tbl(1).interest_only_flag;
            else
                l_rate_details := lns_financials.getRateDetails(p_installment => l_last_installment_billed
                                                                ,p_rate_tbl => l_rate_tbl);
                l_previous_annualized := l_rate_details.annual_rate;
                l_previous_interest_only_flag := l_rate_details.interest_only_flag;
            end if;

        end if;

    else
        l_remaining_balance_theory := l_original_loan_amount;
        l_begin_funded_amount := 0; --l_original_loan_amount;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin = ' || l_begin);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_loan_details.REAMORTIZE_ON_FUNDING = ' || p_loan_details.REAMORTIZE_ON_FUNDING);

    l_increase_amount_instal := -1;

    for l_installment_number in l_begin..l_payment_number
    loop

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ----- Calculating INSTALLMENT ' || l_installment_number || ' -----');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

       i := i + 1;
       l_periodic_interest      := 0;
       l_periodic_principal     := 0;
       l_fee_amount             := 0;
       l_other_amount           := 0;
       l_unpaid_principal       := 0;
       l_unpaid_interest        := 0;
       l_intervals_remaining    := l_num_pay_dates - l_installment_number + 1;
       l_detail_int_calc_flag   := false;
       l_increased_amount       := 0;
       l_increased_amount1      := 0;
       l_prev_increase_amount_instal := l_increase_amount_instal;

       if l_fund_sched_count > 0 or p_based_on_terms = 'CURRENT' then

            if (l_last_installment_billed >= 0) and (l_last_installment_billed + 1 = l_installment_number) then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 = l_installment_number');

                l_principal_cumulative := 0;
                l_interest_cumulative  := 0;
                l_fees_cumulative      := 0;
                l_other_cumulative     := 0;
                l_sum_periodic_principal := 0;
                l_billed_principal     := p_loan_details.billed_principal;
                l_unbilled_principal   := p_loan_details.unbilled_principal;
                l_unpaid_principal     := p_loan_details.unpaid_principal;
                l_unpaid_interest      := p_loan_details.UNPAID_INTEREST;

                if p_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE);
                    l_begin_funded_amount_new := getFundedAmount(l_loan_id, l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1));
                    l_end_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := l_installment_number;
                        else
                            if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := l_installment_number + 1;
                            elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := l_installment_number;
                            end if;
                        end if;

                    elsif l_begin_funded_amount_new > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new > l_begin_funded_amount');
                        l_increase_amount_instal := l_installment_number;
                    end if;

                    l_detail_int_calc_flag := true;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1));
                    l_begin_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                    l_begin_funded_amount := l_begin_funded_amount_new;
                    l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                    l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal;
                else
                    l_remaining_balance_theory := 0;
                end if;

            else

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed + 1 < l_installment_number');
                if p_loan_details.loan_status <> 'PAIDOFF' then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1));
                    l_begin_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount = ' || l_begin_funded_amount);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE);
                    l_begin_funded_amount_new := getFundedAmount(l_loan_id, l_payment_tbl(l_installment_number).PERIOD_BEGIN_DATE, p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_begin_funded_amount_new = ' || l_begin_funded_amount_new);

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Getting funded amount for ' || (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1));
                    l_end_funded_amount := getFundedAmount(l_loan_id, (l_payment_tbl(l_installment_number).PERIOD_END_DATE-1), p_based_on_terms);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount = ' || l_end_funded_amount);

                    if l_end_funded_amount > l_begin_funded_amount then
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_funded_amount > l_begin_funded_amount');
                        l_detail_int_calc_flag := true;

                        if l_end_funded_amount = l_begin_funded_amount_new then
                            l_increase_amount_instal := l_installment_number;
                        else
                            if p_loan_details.REAMORTIZE_ON_FUNDING = 'REST' then
                                l_increase_amount_instal := l_installment_number + 1;
                            elsif p_loan_details.REAMORTIZE_ON_FUNDING = 'IMMEDIATELY' then
                                l_increase_amount_instal := l_installment_number;
                            end if;
                        end if;

                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_billed_principal = ' || l_billed_principal);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_sum_periodic_principal = ' || l_sum_periodic_principal);

                        l_increased_amount := l_end_funded_amount - l_begin_funded_amount;
                        l_begin_funded_amount := l_begin_funded_amount_new;
                        l_increased_amount1 := l_end_funded_amount - l_begin_funded_amount;
                        l_remaining_balance_theory := l_begin_funded_amount - l_billed_principal - l_sum_periodic_principal;
                    end if;
                else
                    l_remaining_balance_theory := 0;
                end if;

            end if;

       end if;

       if p_loan_details.REAMORTIZE_ON_FUNDING = 'NO' then
            l_increase_amount_instal := -1;
       end if;

--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_actual: ' || l_remaining_balance_actual);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': getting rate details');
       l_rate_details := getRateDetails(p_installment => l_installment_number
                                       ,p_rate_tbl    => l_rate_tbl);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate annual rate = ' || l_rate_details.annual_rate);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate spread = ' || l_rate_details.spread);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate id = ' || l_rate_details.rate_id);
--       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate floating_flag ' || l_rate_details.floating_flag);

        -- get the rate details only need to get it once if a single interest rate exists
        l_current_rate_id          := l_rate_details.rate_id;
        l_annualized_rate          := l_rate_details.annual_rate;
        l_interest_only_flag       := l_rate_details.interest_only_flag;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_rate_id = ' || l_previous_rate_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_current_rate_id = ' || l_current_rate_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_annualized = ' || l_previous_annualized);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_annualized_rate = ' || l_annualized_rate);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_previous_interest_only_flag = ' || l_previous_interest_only_flag);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_interest_only_flag = ' || l_interest_only_flag);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_last_installment_billed = ' || l_last_installment_billed);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_extend_from_installment = ' || l_extend_from_installment);
        if l_detail_int_calc_flag then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = true');
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_detail_int_calc_flag = false');
        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount = ' || l_increased_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increased_amount1 = ' || l_increased_amount1);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_increase_amount_instal = ' || l_increase_amount_instal);

        -- conditions to recalculate payment
        -- 1. 1-st installment
        -- 2. previous interest rate <> current interest rate
        -- 3. reamortization from installment = current installment
        -- 4. emerging from interest only period
        -- 5. reamortize because loan term has been extended
        -- 6. funded amount has increased since last installment

        if ((l_installment_number = 1) OR
            (l_annualized_rate <> l_previous_annualized) OR
            (l_reamortize_from_installment >= 0 and (l_last_installment_billed + 1 = l_installment_number)) OR
            (l_previous_interest_only_flag = 'Y' and  l_interest_only_flag = 'N') OR
            (l_extend_from_installment is not null and (l_extend_from_installment + 1 >= l_installment_number)) OR
            (l_prev_increase_amount_instal = l_installment_number or l_increase_amount_instal = l_installment_number))
        then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': RE-calculating periodic payment');
            -- rate has changed so we know we are on a new rate schedule
            -- we need to recalculate the payment_amount
            l_amortization_intervals      := l_amortization_intervals_orig - l_installment_number + 1;

            if (l_calc_method = 'SIMPLE') then

                l_rate_to_calculate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_frequency
                                            ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_period_end_date   => l_maturity_date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'PAYMENT');

            elsif (l_calc_method = 'COMPOUND') then

                l_rate_to_calculate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                    ,p_payment_freq => l_payment_frequency
                                    ,p_annualized_rate => l_annualized_rate
                                    ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                    ,p_period_end_date => l_maturity_date
                                    ,p_days_count_method => l_day_count_method
                                    ,p_target => 'PAYMENT');

            end if;

            -- we need to calculate payment ONCE per interest rate change
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_rate_to_calculate = ' || l_rate_to_calculate);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_amortization_intervals = ' || l_amortization_intervals);
/*
            if l_installment_number = 1 and l_reamortize_from_installment is null then
                l_remaining_balance := l_original_loan_amount;
            else
                l_remaining_balance := l_remaining_balance_theory;
            end if;
*/
            l_remaining_balance := l_remaining_balance_theory + l_increased_amount1;

            if l_rate_details.rate_id = l_rate_tbl(1).rate_id then
                l_periodic_payment := lns_financials.calculatePayment(p_loan_amount   => l_remaining_balance
                                                            ,p_periodic_rate => l_rate_to_calculate
                                                            ,p_num_intervals => l_amortization_intervals
                                                            ,p_ending_balance=> l_balloon_amount
                                                            ,p_pay_in_arrears=> l_pay_in_arrears);
            else
                l_periodic_payment := lns_financials.calculatePayment(p_loan_amount   => l_remaining_balance
                                                            ,p_periodic_rate => l_rate_to_calculate
                                                            ,p_num_intervals => l_amortization_intervals
                                                            ,p_ending_balance=> l_balloon_amount
                                                            ,p_pay_in_arrears=> true);
            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': NEW periodic payment = ' || l_periodic_payment);

        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': KEEPING OLD periodic payment = ' || l_periodic_payment);
        end if;

        l_previous_interest_only_flag := l_interest_only_flag;
        l_previous_rate_id            := l_current_rate_id;
        l_previous_annualized         := l_annualized_rate;

        l_norm_interest := 0;
        l_add_prin_interest := 0;
        l_add_int_interest := 0;
        l_penal_prin_interest := 0;
        l_penal_int_interest := 0;
        l_penal_interest := 0;
        l_norm_int_detail_str := null;
        l_add_prin_int_detail_str := null;
        l_add_int_int_detail_str := null;
        l_penal_prin_int_detail_str := null;
        l_penal_int_int_detail_str := null;
        l_penal_int_detail_str := null;

        -- now we will caculate the interest due for this period
--       if ((p_based_on_terms = 'CURRENT' and l_last_installment_billed >= 0 and l_last_installment_billed + 1 = l_installment_number) or
--           (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true)) then
       if (p_based_on_terms = 'CURRENT' and l_detail_int_calc_flag = true) then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating normal interest...');
            LNS_FINANCIALS.CALC_NORM_INTEREST(p_loan_id => l_loan_id,
                                p_calc_method => l_calc_method,
                                p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                p_period_end_date => l_payment_tbl(l_installment_number).period_end_date,
                                p_interest_rate => l_annualized_rate,
                                p_day_count_method => l_day_count_method,
                                p_payment_freq => l_payment_frequency,
                                p_compound_freq => l_compound_freq,
                                p_adj_amount => l_sum_periodic_principal,
                                x_norm_interest => l_norm_interest,
                                x_norm_int_details => l_norm_int_detail_str);

            l_norm_interest  := round(l_norm_interest, l_precision);

            if (l_installment_number-1) >= 0 and l_last_installment_billed + 1 = l_installment_number then

                -- get additional interest start date
                open c_get_last_bill_date(l_loan_id, (l_installment_number-1));
                fetch c_get_last_bill_date into l_add_start_date;
                close c_get_last_bill_date;

                -- get additional interest end date
                --l_add_end_date := l_payment_tbl(l_installment_number).period_end_date;

                if trunc(sysdate) > trunc(l_payment_tbl(l_installment_number).period_end_date) then
                    l_add_end_date := l_payment_tbl(l_installment_number).period_end_date;
                else
                    l_add_end_date := sysdate;
                end if;

                if (l_installment_number-1) > 0 then
                    l_prev_grace_end_date := l_payment_tbl(l_installment_number-1).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS;
                else
                    l_prev_grace_end_date := l_payment_tbl(l_installment_number).period_begin_date;
                end if;

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid principal...');
                -- calculate additional interest on unpaid principal
                LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => l_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_frequency,
                                    p_compound_freq => l_compound_freq,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_penal_int_rate => p_loan_details.PENAL_INT_RATE,
                                    p_grace_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                    p_grace_end_date => (l_payment_tbl(l_installment_number).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_PRIN',
                                    x_add_interest => l_add_prin_interest,
                                    x_penal_interest => l_penal_prin_interest,
                                    x_add_int_details => l_add_prin_int_detail_str,
                                    x_penal_int_details => l_penal_prin_int_detail_str);
                l_add_prin_interest  := round(l_add_prin_interest, l_precision);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid interest...');
                -- calculate additional interest on unpaid interest
                LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => l_loan_id,
                                    p_calc_method => l_calc_method,
                                    p_period_start_date => l_add_start_date,
                                    p_period_end_date => l_add_end_date,
                                    p_interest_rate => l_annualized_rate,
                                    p_day_count_method => l_day_count_method,
                                    p_payment_freq => l_payment_frequency,
                                    p_compound_freq => l_compound_freq,
                                    p_prev_grace_end_date => l_prev_grace_end_date,
                                    p_penal_int_rate => p_loan_details.PENAL_INT_RATE,
                                    p_grace_start_date => l_payment_tbl(l_installment_number).period_begin_date,
                                    p_grace_end_date => (l_payment_tbl(l_installment_number).period_begin_date + p_loan_details.PENAL_INT_GRACE_DAYS),
                                    p_target => 'UNPAID_INT',
                                    x_add_interest => l_add_int_interest,
                                    x_penal_interest => l_penal_int_interest,
                                    x_add_int_details => l_add_int_int_detail_str,
                                    x_penal_int_details => l_penal_int_int_detail_str);
                l_add_int_interest  := round(l_add_int_interest, l_precision);

                if l_penal_prin_int_detail_str is not null and l_penal_int_int_detail_str is not null then
                    l_penal_int_detail_str := l_penal_prin_int_detail_str || ' +<br>' || l_penal_int_int_detail_str;
                else
                    l_penal_int_detail_str := l_penal_prin_int_detail_str || l_penal_int_int_detail_str;
                end if;
            end if;

       elsif (p_based_on_terms <> 'CURRENT' and l_detail_int_calc_flag = true) then

            if (l_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies
                l_periodic_rate := lns_financials.getPeriodicRate(
                                            p_payment_freq      => l_payment_frequency
                                            ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_annualized_rate   => l_annualized_rate
                                            ,p_days_count_method => l_day_count_method
                                            ,p_target            => 'INTEREST');

            elsif (l_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                ,p_payment_freq => l_payment_frequency
                                ,p_annualized_rate => l_annualized_rate
                                ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                                ,p_days_count_method => l_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                            ,p_from_date        => l_payment_tbl(l_installment_number).period_begin_date
                                            ,p_to_date          => l_payment_tbl(l_installment_number).period_end_date
                                            ,p_calc_method      => 'TARGET'
                                            ,p_phase            => 'TERM'
                                            ,p_day_count_method => l_day_count_method
                                            ,p_adj_amount       => l_sum_periodic_principal
                                            ,x_wtd_balance      => l_wtd_balance
                                            ,x_begin_balance    => l_balance1
                                            ,x_end_balance      => l_balance2);

            l_norm_interest := lns_financials.calculateInterest(p_amount => l_wtd_balance
                                                                ,p_periodic_rate => l_periodic_rate
                                                                ,p_compounding_period => null);
            l_norm_interest := round(l_norm_interest, l_precision);

            l_norm_int_detail_str :=
                'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
                ' * Balance: ' || l_wtd_balance ||
                ' * Rate: ' || l_annualized_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

       else

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_remaining_balance_theory);
            --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_remaining_balance_actual);

            if (l_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies

                l_periodic_rate := lns_financials.getPeriodicRate(
                                        p_payment_freq      => l_payment_frequency
                                        ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                        ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                        ,p_annualized_rate   => l_annualized_rate
                                        ,p_days_count_method => l_day_count_method
                                        ,p_target            => 'INTEREST');

            elsif (l_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                                ,p_payment_freq => l_payment_frequency
                                ,p_annualized_rate => l_annualized_rate
                                ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                                ,p_days_count_method => l_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            l_norm_interest := lns_financials.calculateInterest(p_amount             => l_remaining_balance_theory --l_remaining_balance_actual
                                                                ,p_periodic_rate      => l_periodic_rate
                                                                ,p_compounding_period => null);

            l_norm_interest := round(l_norm_interest, l_precision);

            l_norm_int_detail_str :=
                'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
                ' * Balance: ' || l_remaining_balance_theory ||
                ' * Rate: ' || l_annualized_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

       end if;

       l_penal_interest := round(l_penal_prin_interest + l_penal_int_interest, l_precision);
       l_periodic_interest := round(l_norm_interest + l_add_prin_interest + l_add_int_interest + l_penal_interest, l_precision);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_payment = ' || l_periodic_payment);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_interest = ' || l_periodic_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_penal_interest = ' || l_penal_interest);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_intervals_remaining = ' || l_intervals_remaining);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_unbilled_principal = ' || l_unbilled_principal);

       -- check to see if we are in an interest only period
       -- if this is the case then the periodic_principal = 0
       -- there is a chance that the loan negatively amortizes
       if l_interest_only_flag <> 'Y' or l_intervals_remaining = 1 then

           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculating principal due');
           l_periodic_principal := l_periodic_payment - l_periodic_interest;
           l_periodic_principal := round(l_periodic_principal, l_precision);

           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal = ' || l_periodic_principal);

           -- this is temporary according to not letting amortizations go negative
           if l_periodic_principal < 0 then
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': DISALLOW NEGATIVE AMORTIZATION');
              l_periodic_principal := 0;
           end if;

           -- if the loan is being pre-paid this will ensure that balance gets to zero
           -- make sure the final installment gets the remaining balance on the loan irregardless
           if (l_remaining_balance_theory + l_increased_amount1) < l_periodic_principal then
              l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
           else
               if l_intervals_remaining = 1 then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': CALCULATING LAST INSTALLMENT PRINCIPAL');
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_unbilled principal = ' || l_unbilled_principal);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);
                    if p_based_on_terms = 'CURRENT' and l_unbilled_principal > 0 then
                        l_periodic_principal := l_unbilled_principal;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_unbilled_principal');
                    else
                        l_periodic_principal := l_remaining_balance_theory + l_increased_amount1;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_principal := l_remaining_balance_theory');
                    end if;
               end if;
           end if;

       else
           -- we are in an interest only period
           l_periodic_principal := 0;

       end if;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_remaining_balance_theory = ' || l_remaining_balance_theory);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': principal = ' || l_periodic_principal);

       -- calculate balances and total payment
       l_begin_balance        := l_remaining_balance_theory;
       l_end_balance          := l_remaining_balance_theory - l_periodic_principal + l_increased_amount1;

       -- check to see if this loan has been billed
       if l_unbilled_principal > 0 then
         l_unbilled_principal := l_unbilled_principal - l_periodic_principal;
       end if;

       -- build the amortization record
       -- this information is needed to calculate fees
       -- rest of the record can be built after fees are calculated
       l_amortization_rec.installment_number   := l_installment_number;  /* needed to calculate fees */
       l_amortization_rec.due_date             := l_payment_tbl(l_installment_number).period_due_date;
       l_amortization_rec.PERIOD_START_DATE    := l_payment_tbl(l_installment_number).period_begin_date;
       l_amortization_rec.PERIOD_END_DATE      := l_payment_tbl(l_installment_number).period_end_date;
       l_amortization_rec.principal_amount     := l_periodic_principal;  /* needed to calculate fees */
       l_amortization_rec.interest_amount      := l_periodic_interest;
       l_amortization_rec.begin_balance        := l_begin_balance;       /* needed to calculate fees */
       l_amortization_rec.end_balance          := l_end_balance;
       l_amortization_rec.rate_id              := l_current_rate_id;
       l_amortization_rec.rate_unadj           := l_annualized_rate;
       l_amortization_rec.RATE_CHANGE_FREQ     := p_loan_details.TERM_RATE_CHG_FREQ;
       l_amortization_rec.UNPAID_PRIN          := l_unpaid_principal;
       l_amortization_rec.UNPAID_INT           := l_unpaid_interest;
       l_amortization_rec.INTEREST_RATE        := l_annualized_rate;
       l_amortization_rec.NORMAL_INT_AMOUNT    := l_norm_interest;
       l_amortization_rec.ADD_PRIN_INT_AMOUNT  := l_add_prin_interest;
       l_amortization_rec.ADD_INT_INT_AMOUNT   := l_add_int_interest;
       l_amortization_rec.PENAL_INT_AMOUNT     := l_penal_interest;
       l_amortization_rec.PERIOD               := l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1);
       l_amortization_rec.DISBURSEMENT_AMOUNT  := l_increased_amount;

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_amortization_rec.begin_balance;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := p_loan_details.requested_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_begin_funded_amount;
       --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
       --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

       l_fee_amount := 0;

       if l_installment_number = 1 then

            if l_new_orig_fee_structures.count > 0 then

                l_orig_fees_tbl.delete;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
                lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                            ,p_installment      => l_installment_number
                                            ,p_fee_basis_tbl    => l_fee_basis_tbl
                                            ,p_fee_structures   => l_new_orig_fee_structures
                                            ,x_fees_tbl         => l_orig_fees_tbl
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees = ' || l_orig_fees_tbl.count);

                for k in 1..l_orig_fees_tbl.count loop
                        l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
                end loop;

            end if;

       end if;

       l_memo_fees_tbl.delete;
       if l_memo_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for memo fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_memo_fee_structures
                                        ,x_fees_tbl         => l_memo_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated memo fees = ' || l_memo_fees_tbl.count);
       end if;

       l_fees_tbl.delete;
       if l_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for recurring fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_fee_structures
                                        ,x_fees_tbl         => l_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated recurring fees ' || l_fees_tbl.count);
       end if;

       -- calculate the funding fees
       l_funding_fees_tbl.delete;
       if l_funding_fee_structures.count > 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for funding fees...');
            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_funding_fee_structures
                                        ,x_fees_tbl         => l_funding_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated funding fees ' || l_fees_tbl.count);
       end if;

       for k in 1..l_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_fees_tbl(k).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': recurring calculated fees = ' || l_fee_amount);
       end loop;

       for j in 1..l_funding_fees_tbl.count loop
              l_fee_amount := l_fee_amount + l_funding_fees_tbl(j).FEE_AMOUNT;
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding calculated fees = ' || l_fee_amount);
       end loop;

       for j in 1..l_memo_fees_tbl.count loop
              l_other_amount := l_other_amount + l_memo_fees_tbl(j).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': other calculated fees = ' || l_other_amount);
       end loop;

       l_total                                 := l_fee_amount + l_periodic_principal + l_periodic_interest + l_other_amount;
       l_amortization_rec.total                := l_total;
       l_amortization_rec.fee_amount           := l_fee_amount;
       l_amortization_rec.other_amount         := l_other_amount;

       -- running totals calculated here
       l_principal_cumulative := l_principal_cumulative + l_periodic_principal;
       l_interest_cumulative  := l_interest_cumulative + l_periodic_interest;
       l_fees_cumulative      := l_fees_cumulative + l_fee_amount;
       l_other_cumulative     := l_other_cumulative + l_other_amount;

       l_amortization_rec.interest_cumulative  := l_interest_cumulative;
       l_amortization_rec.principal_cumulative := l_principal_cumulative;
       l_amortization_rec.fees_cumulative      := l_fees_cumulative;
       l_amortization_rec.other_cumulative     := l_other_cumulative;
       l_amortization_rec.rate_id              := l_current_rate_id;
       l_amortization_rec.SOURCE               := 'PREDICTED';
       l_amortization_rec.FUNDED_AMOUNT        := l_end_funded_amount;

       l_amortization_rec.NORMAL_INT_DETAILS   := l_norm_int_detail_str;
       l_amortization_rec.ADD_PRIN_INT_DETAILS := l_add_prin_int_detail_str;
       l_amortization_rec.ADD_INT_INT_DETAILS  := l_add_int_int_detail_str;
       l_amortization_rec.PENAL_INT_DETAILS    := l_penal_int_detail_str;

       -- add the record to the amortization table
       l_amortization_tbl(i)                   := l_amortization_rec;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INSTALLMENT ' || l_installment_number);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD = ' || l_amortization_rec.PERIOD);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_START_DATE = ' || l_amortization_rec.PERIOD_START_DATE);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERIOD_END_DATE = ' || l_amortization_rec.PERIOD_END_DATE);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'due date = ' || l_amortization_rec.due_date);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_principal = ' || l_amortization_rec.principal_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_interest = ' || l_amortization_rec.interest_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fee_amount = ' || l_amortization_rec.fee_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other_amount = ' || l_amortization_rec.other_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'total = ' || l_amortization_rec.total);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'begin_balance = ' || l_amortization_rec.begin_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'end_balance = ' || l_amortization_rec.end_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'interest_cumulative = ' || l_amortization_rec.interest_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'principal_cumulative = ' || l_amortization_rec.principal_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fees_cumulative = ' || l_amortization_rec.fees_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'other_cumulative = ' || l_amortization_rec.other_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'current_rate_id = ' || l_amortization_rec.rate_id );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INTEREST_RATE = ' || l_amortization_rec.INTEREST_RATE );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_PRIN = ' || l_amortization_rec.UNPAID_PRIN );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'UNPAID_INT = ' || l_amortization_rec.UNPAID_INT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_AMOUNT = ' || l_amortization_rec.NORMAL_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_AMOUNT = ' || l_amortization_rec.ADD_PRIN_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_AMOUNT = ' || l_amortization_rec.ADD_INT_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_AMOUNT = ' || l_amortization_rec.PENAL_INT_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FUNDED_AMOUNT = ' || l_amortization_rec.FUNDED_AMOUNT );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_DETAILS = ' || l_amortization_rec.NORMAL_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_PRIN_INT_DETAILS = ' || l_amortization_rec.ADD_PRIN_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ADD_INT_INT_DETAILS_AMOUNT = ' || l_amortization_rec.ADD_INT_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PENAL_INT_DETAILS = ' || l_amortization_rec.PENAL_INT_DETAILS );
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '********************************************');

       -- adjust new loan amount to reflect less periodic principal paid
       -- theoretically without over/underpayments l_loan_amount should = l_remaining_balance
       -- if they diverge then we will calculate interest based from l_remaining_balance
       -- rather than l_loan_amount
       l_remaining_balance_theory :=  l_end_balance;
       l_sum_periodic_principal := l_sum_periodic_principal + l_periodic_principal;

       -- clean up
       l_orig_fees_tbl.delete;
       l_memo_fees_tbl.delete;
       l_fees_tbl.delete;
       l_funding_fees_tbl.delete;

    end loop;

    --printAmortizationTable(p_amort_tbl => l_amortization_tbl);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AMORTIZATION TABLE COUNT = ' || l_amortization_tbl.count);
    x_loan_amort_tbl := l_amortization_tbl;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end amortizeLoan;

/*=========================================================================
|| PUBLIC PROCEDURE amortizeLoan
||
|| DESCRIPTION
||
|| Overview:  amortizes a loan
||            this api assumes the loan information is in the
||            Loans DataModel
||
|| Parameter: p_loan_id  => Loan ID
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| Return value: x_loan_amort_tbl table of amortization_records
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                 Author            Description of Changes
|| 12/09/2003 1:51PM    raverma           Created
|| 04/07/2004           raverma           alter so we dont need to loop thru
||                                        whole amortization
 *=======================================================================*/
procedure amortizeLoan (p_loan_Id            in number
                       ,p_based_on_terms     in varchar2
                       ,p_installment_number in number
                       ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL)

is
    l_loan_details                   LOAN_DETAILS_REC;
    l_amortization_tbl               amortization_tbl;
    l_rate_tbl                       RATE_SCHEDULE_TBL;
    l_api_name                       varchar2(20);
begin

     l_api_name  := 'amortizeLoan LOANID';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
     l_loan_details  := lns_financials.getLoanDetails(p_loan_Id         => p_loan_id
                                                     ,p_based_on_terms  => p_based_on_terms
									                 ,p_phase           => 'TERM');

     l_rate_tbl := lns_financials.getRateSchedule(p_loan_id, 'TERM');

     if (l_loan_details.PAYMENT_CALC_METHOD = 'EQUAL_PRINCIPAL') then

        lns_financials.amortizeEPLoan(p_loan_details       => l_loan_details
                                    ,p_rate_schedule      => l_rate_tbl
                                    ,p_based_on_terms     => p_based_on_terms
                                    ,p_installment_number => p_installment_number
                                    ,x_loan_amort_tbl     => l_amortization_tbl);

     elsif (l_loan_details.PAYMENT_CALC_METHOD = 'SEPARATE_SCHEDULES') then

        lns_financials.amortizeSIPLoan(p_loan_details       => l_loan_details
                                    ,p_rate_schedule      => l_rate_tbl
                                    ,p_based_on_terms     => p_based_on_terms
                                    ,p_installment_number => p_installment_number
                                    ,x_loan_amort_tbl     => l_amortization_tbl);

     elsif (l_loan_details.PAYMENT_CALC_METHOD = 'EQUAL_PAYMENT') then

        lns_financials.amortizeLoan(p_loan_details       => l_loan_details
                                    ,p_rate_schedule      => l_rate_tbl
                                    ,p_based_on_terms     => p_based_on_terms
                                    ,p_installment_number => p_installment_number
                                    ,x_loan_amort_tbl     => l_amortization_tbl);

     end if;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Tbl count is ' || l_amortization_tbl.count);

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
     x_loan_amort_tbl := l_amortization_tbl;
Exception
    When others then
        null;

end amortizeLoan;

/*=========================================================================
|| PUBLIC PROCEDURE loanProjection
||
|| DESCRIPTION
||
|| Overview: procedure will project an open ended loan
||           1. Amortization UI - when creating a loan
||           2. Billing Engine  - to generate bills
||
|| Parameter: p_loan_details  = details of the loan
||            p_rate_schedule = rate schedule for the loan
||            x_loan_amort_tbl => table of loan records
||
|| Source Tables:  NA
||
|| Target Tables:
||
||
|| KNOWN ISSUES
||         Currently only support single rate
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/20/2005 11:35AM     raverma           Created
 *=======================================================================*/
procedure loanProjection(p_loan_details       in  LNS_FINANCIALS.LOAN_DETAILS_REC
                        ,p_based_on_terms     in  varchar2
                        ,p_rate_schedule      in  LNS_FINANCIALS.RATE_SCHEDULE_TBL
                        ,x_loan_amort_tbl     out nocopy LNS_FINANCIALS.AMORTIZATION_TBL)
is
    l_return_status                  varchar2(1);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(32767);
    -- loan_details
    l_loan_id                        number;
    l_original_loan_amount           number;  -- loan amount
    l_first_payment_date             date;
    l_pay_in_arrears                 boolean;
    l_payment_frequency              varchar2(30);
    l_day_count_method               varchar2(30);
    l_intervals_original             number;
    l_intervals                      number;
    l_intervals_remaining            number;
    l_rate_details                   LNS_FINANCIALS.INTEREST_RATE_REC;
    l_precision                      number;

    l_period_start_Date              date;
    l_period_end_date                date;
    l_periodic_rate                  number;
    l_maturity_date                  date;

    l_amortization_rec               LNS_FINANCIALS.AMORTIZATION_REC;
    l_amortization_tbl               LNS_FINANCIALS.AMORTIZATION_TBL;
    l_rate_tbl                       LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_payment_tbl                    LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_loan_start_date                date;
    l_num_pay_dates                  number;  -- number of dates on installment schedule
    l_periodic_payment               number;
    l_periodic_principal             number;
    l_periodic_interest              number;
    l_total_principal                number;
    l_payment_number                 number;
    l_fee_amount                     number;
    l_begin_balance                  number;
    l_end_balance                    number;
    l_unbilled_principal             number;
    l_unpaid_principal               number;
    --l_open_rate_type                 varchar2(30);
    l_open_rate_change_frequency     varchar2(30);
    l_open_index_rate_id             number;
    l_open_index_date                date;
    l_open_ceiling_rate              number;
    l_open_floor_rate                number;
    l_unpaid_interest                number;

    l_wtd_balance                    number;
    l_total                          number;
    l_interest_cumulative            number;
    l_principal_cumulative           number;
    l_fees_cumulative                number;
    i                                number;  -- for installments
	k                                number;  -- for disbursements
    l_installment_number             number;
    l_api_name                       varchar2(20);
    l_last_installment_billed        number;
    l_rate_to_calculate              number;
    l_disb_header_id                 number;
    l_disb_amount                    number;
    l_total_disbursed	             number;
    l_calc_method                    varchar2(30);
    l_compound_freq                  varchar2(30);
    l_annualized_rate                number;
    l_billed                         varchar2(1);
    n                                number;
    l_norm_int_detail_str            varchar2(2000);
    l_prev_end_balance               number;

    -- for fees
    l_orig_fee_structures            LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_new_orig_fee_structures        LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
	l_funding_fee_structures         LNS_FEE_ENGINE.FEE_STRUCTURE_TBL;
    l_fees_tbl                       LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_orig_fees_tbl                  LNS_FEE_ENGINE.FEE_CALC_TBL;
    l_fee_basis_tbl                  LNS_FEE_ENGINE.FEE_BASIS_TBL;

    cursor c_total_disbursed(p_loan_id number, p_from_date date, p_to_date date)
    is
        select nvl(sum(header_amount), 0)
        from lns_disb_headers
    where loan_id = p_loan_id
        and trunc(payment_request_date) >= p_from_date
        and trunc(payment_request_date) < p_to_date;

    cursor c_orig_fee_billed(p_loan_id number, p_fee_id number, p_based_on_terms varchar2) is
        select 'X'
        from lns_fee_schedules sched
            ,lns_fees struct
        where sched.loan_id = p_loan_id
        and sched.fee_id = p_fee_id
        and sched.fee_id = struct.fee_id
        and struct.fee_type = 'EVENT_ORIGINATION'
        and sched.active_flag = 'Y'
        and decode(p_based_on_terms, 'CURRENT', sched.billed_flag, 'N') = 'Y'
        and sched.phase = 'OPEN';

begin

    -- initialize all variables
    l_original_loan_amount           := 0;  -- loan amount
    l_periodic_payment               := 0;
    l_periodic_principal             := 0;
    l_periodic_interest              := 0;
    l_total_principal                := 0;
    l_payment_number                 := 0;
    l_fee_amount                     := 0;
    l_begin_balance                  := 0;
    l_unbilled_principal             := 0;
    l_unpaid_principal               := 0;
    l_total                          := 0;
    l_interest_cumulative            := 0;
    l_principal_cumulative           := 0;
    l_fees_cumulative                := 0;
    i                                := 0;
    l_installment_number             := 1;  -- begin from #1 installment, NOT #0 installment
    l_rate_to_calculate              := 0;
	l_total_disbursed				 := 0;
    l_api_name                       := 'loanProjection';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    l_payment_frequency             := p_loan_details.payment_frequency;
    l_first_payment_date            := p_loan_details.first_payment_date;
    l_original_loan_amount          := p_loan_details.requested_amount; --funded_amount;
    l_maturity_date                 := p_loan_details.maturity_date;
    l_intervals                     := p_loan_details.number_installments;
    l_last_installment_billed       := p_loan_details.last_installment_billed;
    l_day_count_method              := p_loan_details.day_count_method;
    l_loan_start_date               := p_loan_details.loan_start_date;
    l_pay_in_arrears                := p_loan_details.pay_in_arrears_boolean;
    l_precision                     := p_loan_details.currency_precision;
    l_loan_id                       := p_loan_details.loan_id;
    -- use the projected rate which should be the last calculated rate on the loan
    l_periodic_rate                 := p_loan_details.OPEN_PROJECTED_INTEREST_RATE;
    l_calc_method                   := p_loan_details.CALCULATION_METHOD;
    l_compound_freq                 := p_loan_details.INTEREST_COMPOUNDING_FREQ;
    l_unpaid_principal              := p_loan_details.unpaid_principal;
    l_unpaid_interest               := p_loan_details.UNPAID_INTEREST;

    -- get the interest rate schedule
    l_rate_tbl := p_rate_schedule;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- rate schedule count = ' || l_rate_tbl.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- p_based_on_terms = ' || p_based_on_terms);

    -- get payment schedule
    -- this will return the acutal dates that payments will be due on
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting payment schedule');
    l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => l_loan_start_date
                                                       ,p_loan_maturity_date => l_maturity_date
                                                       ,p_first_pay_date     => l_first_payment_date
                                                       ,p_num_intervals      => l_intervals
                                                       ,p_interval_type      => l_payment_frequency
                                                       ,p_pay_in_arrears     => l_pay_in_arrears);

    l_num_pay_dates := l_payment_tbl.count;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- payment schedule count = ' || l_num_pay_dates);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting origination fee structures');
    l_orig_fee_structures  := lns_fee_engine.getFeeStructures(p_loan_id      => l_loan_id
                                                            ,p_fee_category => 'EVENT'
                                                            ,p_fee_type     => 'EVENT_ORIGINATION'
                                                            ,p_installment  => null
                                                            ,p_phase        => 'OPEN'
                                                            ,p_fee_id       => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': origination structures count is ' || l_orig_fee_structures.count);

    n := 0;
    for m in 1..l_orig_fee_structures.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee = ' || l_orig_fee_structures(m).FEE_ID);
        l_billed := null;
        open c_orig_fee_billed(l_loan_id, l_orig_fee_structures(m).FEE_ID, p_based_on_terms);
        fetch c_orig_fee_billed into l_billed;
        close c_orig_fee_billed;

        if l_billed is null then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is not billed yet');
            n := n + 1;
            l_new_orig_fee_structures(n) := l_orig_fee_structures(m);
        else
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Fee ' || l_orig_fee_structures(m).FEE_ID || ' is already billed');
        end if;
    end loop;

    if l_new_orig_fee_structures.count > 0 then

       -- calculate fees here
       -- should be new routine to simply get the fees from the fee schedule
       l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
       l_fee_basis_tbl(1).fee_basis_amount := l_original_loan_amount;
       l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
       l_fee_basis_tbl(2).fee_basis_amount := l_original_loan_amount;
       l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
       l_fee_basis_tbl(3).fee_basis_amount := l_original_loan_amount;
       --l_fee_basis_tbl(4).fee_basis_name   := 'TOTAL_DISB_AMOUNT';
       --l_fee_basis_tbl(4).fee_basis_amount := l_original_loan_amount;

        l_orig_fees_tbl.delete;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
        lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                    ,p_installment      => 0
                                    ,p_fee_basis_tbl    => l_fee_basis_tbl
                                    ,p_fee_structures   => l_new_orig_fee_structures
                                    ,x_fees_tbl         => l_orig_fees_tbl
                                    ,x_return_status    => l_return_status
                                    ,x_msg_count        => l_msg_count
                                    ,x_msg_data         => l_msg_data);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fees_tbl.count);

        for k in 1..l_orig_fees_tbl.count loop
            l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
        end loop;

       if l_fee_amount > 0 then
            begin
                if p_based_on_terms = 'CURRENT' then

                    lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                                    ,p_from_date        => l_loan_start_date
                                                    ,p_to_date          => l_loan_start_date
                                                    ,p_calc_method      => 'ACTUAL'
                                                    ,p_phase            => 'OPEN'
                                                    ,p_day_count_method => l_day_count_method
                                                    ,p_adj_amount       => 0
                                                    ,x_wtd_balance      => l_wtd_balance
                                                    ,x_begin_balance    => l_begin_balance
                                                    ,x_end_balance      => l_end_balance);

                else

                    lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                                    ,p_from_date        => l_loan_start_date
                                                    ,p_to_date          => l_loan_start_date
                                                    ,p_calc_method      => 'TARGET'
                                                    ,p_phase            => 'OPEN'
                                                    ,p_day_count_method => l_day_count_method
                                                    ,p_adj_amount       => 0
                                                    ,x_wtd_balance      => l_wtd_balance
                                                    ,x_begin_balance    => l_begin_balance
                                                    ,x_end_balance      => l_end_balance);

                end if;
            exception
                when others then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_COMPUTE_BALANCE_ERROR');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, l_api_name || FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end;

           i := i + 1;
           l_amortization_rec.installment_number   := 0;
           l_amortization_rec.due_date             := l_loan_start_date;
           l_amortization_rec.PERIOD_START_DATE    := l_loan_start_date;
           l_amortization_rec.PERIOD_END_DATE      := l_loan_start_date;
           l_amortization_rec.principal_amount     := 0;
           l_amortization_rec.interest_amount      := 0;
           l_amortization_rec.fee_amount           := l_fee_amount;
           l_amortization_rec.other_amount         := 0;
           l_amortization_rec.begin_balance        := l_begin_balance;
           l_amortization_rec.end_balance          := l_end_balance;
           l_amortization_rec.interest_cumulative  := 0;
           l_amortization_rec.principal_cumulative := 0;
           l_amortization_rec.fees_cumulative      := l_fee_amount;
           l_amortization_rec.other_cumulative     := 0;
           l_amortization_rec.rate_id              := 0;
           l_amortization_rec.SOURCE               := 'PREDICTED';
           -- add the record to the amortization table
           l_amortization_rec.total                := l_fee_amount;
           l_amortization_rec.UNPAID_PRIN          := 0;
           l_amortization_rec.UNPAID_INT           := 0;
           l_amortization_rec.INTEREST_RATE        := l_rate_tbl(1).annual_rate;
           l_amortization_rec.NORMAL_INT_AMOUNT    := 0;
           l_amortization_rec.ADD_PRIN_INT_AMOUNT  := 0;
           l_amortization_rec.ADD_INT_INT_AMOUNT   := 0;
           l_amortization_rec.PENAL_INT_AMOUNT     := 0;
           l_amortization_rec.NORMAL_INT_DETAILS   := null;
           l_amortization_rec.ADD_PRIN_INT_DETAILS := null;
           l_amortization_rec.ADD_INT_INT_DETAILS  := null;
           l_amortization_rec.PENAL_INT_DETAILS    := null;
           l_amortization_rec.PERIOD               := l_loan_start_date || ' - ' || l_loan_start_date;
           l_amortization_rec.DISBURSEMENT_AMOUNT  := 0;

           l_amortization_tbl(i)                   := l_amortization_rec;
       end if;

    end if;

    l_prev_end_balance := 0;
    -- loop to build the amortization schedule
    for l_installment_number in 1..l_num_pay_dates
    loop

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' -----CALCULATING -----> installment #' || l_installment_number);
       i := i + 1;
       l_periodic_interest      := 0;
       l_fee_amount             := 0;
       l_intervals_remaining    := l_num_pay_dates - l_installment_number + 1;
       l_norm_int_detail_str    := null;
/*
	   -- get the total funded amount
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' getting total funded amount thru' || l_payment_tbl(l_installment_number).period_end_date);

       open c_total_disbursed(l_loan_id , l_payment_tbl(1).period_begin_date , l_payment_tbl(l_installment_number).period_end_date);
       fetch c_total_disbursed into l_end_balance;
       close c_total_disbursed;

       l_begin_balance := l_end_balance;
*/
       -- get the weighted balance for the period
       begin
            if p_based_on_terms = 'CURRENT' then

                lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                                ,p_from_date        => l_payment_tbl(l_installment_number).period_begin_date
                                                ,p_to_date          => l_payment_tbl(l_installment_number).period_end_date
                                                ,p_calc_method      => 'ACTUAL'
                                                ,p_phase            => 'OPEN'
                                                ,p_day_count_method => l_day_count_method
                                                ,p_adj_amount       => 0
                                                ,x_wtd_balance      => l_wtd_balance
                                                ,x_begin_balance    => l_begin_balance
                                                ,x_end_balance      => l_end_balance);

            else

                lns_financials.getWeightedBalance(p_loan_id         => l_loan_id
                                                ,p_from_date       => l_payment_tbl(l_installment_number).period_begin_date
                                                ,p_to_date         => l_payment_tbl(l_installment_number).period_end_date
                                                ,p_calc_method     => 'TARGET'
                                                ,p_phase            => 'OPEN'
                                                ,p_day_count_method => l_day_count_method
                                                ,p_adj_amount       => 0
                                                ,x_wtd_balance      => l_wtd_balance
                                                ,x_begin_balance    => l_begin_balance
                                                ,x_end_balance      => l_end_balance);

            end if;
       exception
            when others then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_COMPUTE_BALANCE_ERROR');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, l_api_name || FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
       end;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - l_wtd_balance = ' || l_wtd_balance);

       -- now we will caculate the interest due for this period
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest is based upon an amount of ' || l_wtd_balance);

       l_rate_details := getRateDetails(p_installment => l_installment_number
                                       ,p_rate_tbl    => l_rate_tbl);

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate annual rate = ' || l_rate_details.annual_rate);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate spread = ' || l_rate_details.spread);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate id = ' || l_rate_details.rate_id);

       l_annualized_rate          := l_rate_details.annual_rate;

       -- recalculate periodic rate for each period if day counting methodolgy varies
       if (l_calc_method = 'SIMPLE') then

            l_periodic_rate := lns_financials.getPeriodicRate(
                                    p_payment_freq      => l_payment_frequency
                                    ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                                    ,p_period_end_date   => l_payment_tbl(l_installment_number).period_end_date
                                    ,p_annualized_rate   => l_annualized_rate
                                    ,p_days_count_method => l_day_count_method
                                    ,p_target            => 'INTEREST');

       elsif (l_calc_method = 'COMPOUND') then

            l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => l_compound_freq
                            ,p_payment_freq => l_payment_frequency
                            ,p_annualized_rate => l_annualized_rate --p_loan_details.OPEN_PROJECTED_INTEREST_RATE
                            ,p_period_start_date => l_payment_tbl(l_installment_number).period_begin_date
                            ,p_period_end_date => l_payment_tbl(l_installment_number).period_end_date
                            ,p_days_count_method => l_day_count_method
                            ,p_target => 'INTEREST');

       end if;
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_rate rate = ' || l_periodic_rate);

       -- if we are going to compound, then based on compounding the amount should be passed to calculateInterest call here.
       -- how do we determine what the amount to compound on
       -- for example: compound daily at .5% over 30 day period
       l_periodic_interest := lns_financials.calculateInterest(p_amount             => l_wtd_balance
                                                            ,p_periodic_rate      => l_periodic_rate
                                                            ,p_compounding_period => null);

       l_periodic_interest  := round(l_periodic_interest, l_precision);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_interest = ' || l_periodic_interest);

       l_norm_int_detail_str :=
            'Period: ' || l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1) ||
            ' * Balance: ' || l_wtd_balance ||
            ' * Rate: ' || l_annualized_rate || '%';
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);

        --mark
       if l_installment_number = p_loan_details.number_installments and
           (p_loan_details.OPEN_TO_TERM_FLAG = 'N' OR p_loan_details.SECONDARY_STATUS = 'REMAINING_DISB_CANCELLED') then
				    l_periodic_principal := p_loan_details.funded_amount;
       else
						l_periodic_principal := 0;
       end if;

       l_fees_tbl.delete;
       if p_based_on_terms = 'CURRENT' then

            lns_fee_engine.getFeeSchedule(p_init_msg_list      => FND_API.G_FALSE
                                        ,p_loan_id            => l_loan_id
                                        ,p_installment_number => l_installment_number
                                        ,p_disb_header_id => null
                                        ,p_phase              => 'OPEN'
                                        ,x_fees_tbl           => l_fees_tbl
                                        ,x_return_status      => l_return_status
                                        ,x_msg_count          => l_msg_count
                                        ,x_msg_data           => l_msg_data);

            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_READ_FEE_ERROR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            end if;

            for m in 1..l_fees_tbl.count loop
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': m ' || l_fees_tbl(m).FEE_AMOUNT);
                l_fee_amount := l_fee_amount + l_fees_tbl(m).FEE_AMOUNT;
            end loop;

       else

         -- get the fee basis
         -- get the total disbursed thru the target date of the fee
            l_fee_basis_tbl(1).fee_basis_name   := 'TOTAL_BAL';
            l_fee_basis_tbl(1).fee_basis_amount := l_original_loan_amount;
            l_fee_basis_tbl(2).fee_basis_name   := 'ORIG_LOAN';
            l_fee_basis_tbl(2).fee_basis_amount := l_original_loan_amount;
            l_fee_basis_tbl(3).fee_basis_name   := 'IND_DISB_AMOUNT';
            l_fee_basis_tbl(3).fee_basis_amount := l_original_loan_amount;

            if l_installment_number = 1 then

                if l_new_orig_fee_structures.count > 0 then

                    l_orig_fees_tbl.delete;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calling calculateFees for origination fees...');
                    lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                                ,p_installment      => l_installment_number
                                                ,p_fee_basis_tbl    => l_fee_basis_tbl
                                                ,p_fee_structures   => l_new_orig_fee_structures
                                                ,x_fees_tbl         => l_orig_fees_tbl
                                                ,x_return_status    => l_return_status
                                                ,x_msg_count        => l_msg_count
                                                ,x_msg_data         => l_msg_data);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated origination fees ' || l_orig_fees_tbl.count);

                    for k in 1..l_orig_fees_tbl.count loop
                        l_fee_amount := l_fee_amount + l_orig_fees_tbl(k).FEE_AMOUNT;
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_orig_fees_tbl(k).FEE_AMOUNT = ' || l_orig_fees_tbl(k).FEE_AMOUNT);
                        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_fee_amount = ' || l_fee_amount);
                    end loop;

                end if;

            end if;

            -- get the disbursement fees
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '- getting funding fee structures');
            l_funding_fee_structures := lns_fee_engine.getDisbursementFeeStructures(p_loan_id        => l_loan_id
                                                                            ,p_installment_no => l_installment_number
                                                                            ,p_phase          => 'OPEN'
                                                                            ,p_disb_header_id => null
                                                                            ,p_fee_id         => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funding structures count = ' || l_funding_fee_structures.count);

            lns_fee_engine.calculateFees(p_loan_id          => l_loan_id
                                        ,p_installment      => l_installment_number
                                        ,p_fee_basis_tbl    => l_fee_basis_tbl
                                        ,p_fee_structures   => l_funding_fee_structures
                                        ,x_fees_tbl         => l_fees_tbl
                                        ,x_return_status    => l_return_status
                                        ,x_msg_count        => l_msg_count
                                        ,x_msg_data         => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calculated funding fees = ' || l_fees_tbl.count);

            for m in 1..l_fees_tbl.count loop
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': m ' || l_fees_tbl(m).FEE_AMOUNT);
                l_fee_amount := l_fee_amount + l_fees_tbl(m).FEE_AMOUNT;
            end loop;

       end if;

       -- rest of the record can be built after fees are calculated
       l_amortization_rec.installment_number   := l_installment_number;
       l_amortization_rec.due_date             := l_payment_tbl(l_installment_number).period_due_date;
       l_amortization_rec.PERIOD_START_DATE    := l_payment_tbl(l_installment_number).period_begin_date;
       l_amortization_rec.PERIOD_END_DATE      := l_payment_tbl(l_installment_number).period_end_date;
       l_amortization_rec.principal_amount     := l_periodic_principal;
       l_amortization_rec.interest_amount      := l_periodic_interest;
       l_amortization_rec.begin_balance        := l_begin_balance;
       l_amortization_rec.end_balance          := l_end_balance;
       l_amortization_rec.other_amount         := 0;
       l_amortization_rec.UNPAID_PRIN          := l_unpaid_principal;
       l_amortization_rec.UNPAID_INT           := l_unpaid_interest;
       l_amortization_rec.INTEREST_RATE        := l_annualized_rate; --p_loan_details.OPEN_PROJECTED_INTEREST_RATE;
       l_amortization_rec.NORMAL_INT_AMOUNT    := l_periodic_interest;
       l_amortization_rec.ADD_PRIN_INT_AMOUNT  := 0;
       l_amortization_rec.ADD_INT_INT_AMOUNT   := 0;
       l_amortization_rec.PENAL_INT_AMOUNT     := 0;
       l_amortization_rec.NORMAL_INT_DETAILS   := l_norm_int_detail_str;
       l_amortization_rec.ADD_PRIN_INT_DETAILS := null;
       l_amortization_rec.ADD_INT_INT_DETAILS  := null;
       l_amortization_rec.PENAL_INT_DETAILS    := null;
       l_amortization_rec.PERIOD               := l_payment_tbl(l_installment_number).period_begin_date || ' - ' || (l_payment_tbl(l_installment_number).period_end_date-1);
       l_amortization_rec.DISBURSEMENT_AMOUNT  := l_end_balance - l_prev_end_balance;

       l_total                                 := l_fee_amount + l_periodic_principal + l_periodic_interest;
       l_amortization_rec.total                := l_total;
       l_amortization_rec.fee_amount           := l_fee_amount;
       l_prev_end_balance                      := l_end_balance;

       -- running totals calculated here
       --l_principal_cumulative := l_principal_cumulative + l_periodic_principal;
       l_interest_cumulative  := l_interest_cumulative + l_periodic_interest;
       l_fees_cumulative      := l_fees_cumulative + l_fee_amount;

       l_amortization_rec.interest_cumulative  := l_interest_cumulative;
       l_amortization_rec.principal_cumulative := l_principal_cumulative;
       l_amortization_rec.fees_cumulative      := l_fees_cumulative;
       l_amortization_rec.SOURCE               := 'PREDICTED';

       -- add the record to the amortization table
       l_amortization_tbl(i)                   := l_amortization_rec;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: due date ' || l_amortization_rec.due_date);
       --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: periodic_principal ' || l_amortization_rec.principal_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: periodic_interest  ' || l_amortization_rec.interest_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: fee_amount is ' || l_amortization_rec.fee_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: total is ' || l_amortization_rec.fee_amount);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: begin_balance is ' || l_amortization_rec.begin_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: end_balance is ' || l_amortization_rec.end_balance);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: interest_cumulative is ' || l_amortization_rec.interest_cumulative);
       --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: principal_cumulative is ' || l_amortization_rec.principal_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization rec: fees_cumulative is ' || l_amortization_rec.fees_cumulative);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NORMAL_INT_AMOUNT = ' || l_amortization_rec.NORMAL_INT_AMOUNT );

    end loop;
    --printAmortizationTable(p_amort_tbl => l_amortization_tbl);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - AMORTIZATION TABLE COUNT = ' || l_amortization_tbl.count);
    x_loan_amort_tbl := l_amortization_tbl;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end loanProjection;

/*=========================================================================
|| PUBLIC PROCEDURE runLoanProjection
||
|| DESCRIPTION
||
|| Overview: procedure will run a loan projection ||
|| Parameter:  loan_id
||
|| Source Tables:  LNS_LOAN_HEADERS, LNS_TERMS, LNS_RATE_SCHEDULES,
||                 LNS_DISB_HEADERS, LNS_DISB_LINES
||
|| Target Tables: None
||
|| Return value: x_amort_tbl is table of amortization records
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/18/2005 11:35AM    raverma           Created
|| 08/29/2005            raverma           throw error if invalid dates
 *=======================================================================*/
procedure runOpenProjection(p_init_msg_list  IN VARCHAR2
                           ,p_loan_ID        IN NUMBER
                           ,p_based_on_terms IN VARCHAR2
                           ,x_amort_tbl      OUT NOCOPY LNS_FINANCIALS.AMORTIZATION_TBL
                           ,x_return_status  OUT NOCOPY VARCHAR2
                           ,x_msg_count      OUT NOCOPY NUMBER
                           ,x_msg_data       OUT NOCOPY VARCHAR2)
is

    l_api_name                varchar2(25);
    l_api_version_number      number;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(32767);

    l_amort_tbl               LNS_FINANCIALS.AMORTIZATION_TBL;
    l_amort_tbl2              LNS_FINANCIALS.AMORTIZATION_TBL;
    l_total_amortization      LNS_FINANCIALS.AMORTIZATION_REC;
    b_showActual              boolean := false;
    l_last_installment_billed number;

    l_num_records             number;
    i                         number;
    m                         number;
    l_records_to_copy         number;
    l_num_installments        number;
    l_num_rows                number;
    l_manual_fee_amount       number;
    l_records_to_destroy      number;
    l_start_date              number;
    l_funded_amount           number;
    l_loan_details            LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_rate_tbl			      LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_disb_amount	          number;
    l_invalid_disb			  number;

    -- bug # 4258345
    -- add late fees to
    cursor c_manual_fees(p_loan_id number, p_installment number) is
    select sum(nvl(fee_amount,0))
      from lns_fee_schedules sch,
           lns_fees fees
     where sch.active_flag = 'Y'
       and sch.billed_flag = 'N'
       and fees.fee_id = sch.fee_id
       and ((fees.fee_category = 'MANUAL')
        OR (fees.fee_category = 'EVENT' AND fees.fee_type = 'EVENT_LATE_CHARGE'))
       and sch.loan_id = p_loan_id
       and fee_installment = p_installment
       and sch.phase = 'OPEN';

		 cursor c_disbursements(p_loan_id number) is
		 select nvl(sum(header_amount), 0)
			 from lns_disb_headers
			where loan_id = p_loan_id;
/*
		 -- if there is a return count then some dates are invalid
     cursor c_invalid_disb(p_loan_id number) is
		 select count(1)
		 	from lns_disb_headers dh
					,lns_loan_headers h
		 	where h.loan_id = dh.loan_id
			  and trunc(dh.payment_request_date) < trunc(h.open_loan_start_date)
        and h.loan_id = p_loan_id;
*/
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT runLoanProjection_PVT;
        l_api_name                := 'runLoanProjection';
        i                         := 0;
        l_manual_fee_amount       := 0;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- Api body
        -- ----------------------------------------------------------------
        -- validate loan_id
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

        -- check if disbursements exist and is amount > 0 as per karthik instructions
        open  c_disbursements(p_loan_id);
        fetch c_disbursements into l_disb_amount;
        close c_disbursements;
/*
        -- check if disbursement dates are valid
        open c_invalid_disb(p_loan_id);
        fetch c_invalid_disb into l_invalid_disb;
        close c_invalid_disb;
*/
        if l_invalid_disb > 0 then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_DISB_REQ_DATE_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        if l_disb_amount > 0 then
            l_rate_tbl      := lns_financials.getRateSchedule(p_loan_id, 'OPEN');
	        l_loan_details  := lns_financials.getLoanDetails(p_loan_Id            => p_loan_id
	                                                        ,p_based_on_terms     => p_based_on_terms
															,p_phase              => 'OPEN');

	        -- call projection API
	        lns_financials.loanProjection(p_loan_details     => l_loan_details
                                          ,p_based_on_terms  => p_based_on_terms
					  			          ,p_rate_schedule    => l_rate_tbl
					 			          ,x_loan_amort_tbl   => l_amort_tbl);

	        -- delete predicted records based on ORIGINAL amortization
            if p_based_on_terms = 'CURRENT' and
                l_loan_details.LOAN_STATUS NOT IN ('INCOMPLETE','DELETED','REJECTED','PENDING','APPROVED')
            then
	            l_num_records := l_amort_tbl.count;
	            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - amortization returns # records '|| l_num_records);
	            l_last_installment_billed := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER_EXT_3(p_loan_id, 'OPEN');
	            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - last installment billed '|| l_last_installment_billed);

	            -- copy the records not billed to a temp collection
	            m := 0;
	            for i in 1..l_num_records
	            loop
	                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - copying record ' || i);
	                if l_amort_tbl(i).installment_number > l_last_installment_billed then
	                    m := m + 1;
	                    l_amort_tbl2(m) := l_amort_tbl(i);
	                end if;
	            end loop;

	            -- copy back to original table
	            l_amort_tbl.delete;
	            m := 0;
	            for i in 1..l_amort_tbl2.count
	            loop
	                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - re-copying record ' || i);
	                    m := m + 1;
	                    l_amort_tbl(m) := l_amort_tbl2(i);
	            end loop;

	            -- finally get the manual fees for the 1st record and add them to the total "other Amount"
	            -- there has got to be a better way to do this
	            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - late + manual fee amount is '|| l_manual_fee_amount);
	            begin
	                open c_manual_fees(p_loan_id, l_last_installment_billed + 1);
	                    fetch c_manual_fees into l_manual_fee_amount;
	                close c_manual_fees;
	            end;

	            if l_manual_fee_amount is null then
	                   l_manual_fee_amount := 0;
	            end if;
	            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - manual fee amount is '|| l_manual_fee_amount);

                if l_amort_tbl.count > 0 then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': adding fees...');
                    l_amort_tbl(1).fee_amount := l_amort_tbl(1).fee_amount + l_manual_fee_amount;
                    l_amort_tbl(1).total := l_amort_tbl(1).total + l_manual_fee_amount;
                end if;

	        end if;
		end if; -- disb amount > 0
        x_amort_tbl := l_amort_tbl;
        --
        -- End of API body
        --

        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO runLoanProjection_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO runLoanProjection_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO runLoanProjection_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

END runOpenProjection;

---------------------------------------------------------------------------
--- rate routines
---------------------------------------------------------------------------
/*=========================================================================
|| PUBLIC PROCEDURE getRateSchedule - R12
||
|| DESCRIPTION
||
|| Overview:  this api is used to get the rate schedule for a loan
||
|| Parameter:  loan_id,
||             p_phase  'OPEN' or 'TERM'
||
|| Source Tables:  LNS_RATE_SCHEDULES, LNS_TERMS, LNS_LOAN_HEADER_ALL
||
|| Target Tables:  NA
||
|| Return value: rate_schedule_tbl which is defined as
||  TYPE INTEREST_RATE_REC IS RECORD(
||    BEGIN_DATE   DATE,
||    END_DATE     DATE,
||    ANNUAL_RATE  NUMBER);
||  TYPE RATE_SCHEDULE_TBL IS TABLE OF INTEREST_RATE_REC INDEX BY BINARY_INTEGER;
||
|| KNOWN ISSUES
||
|| NOTES
||      NOTE: INSTALLMENT_NUMBER WILL NOT GET YOU THE GIVEN INSTALLMENT
||            NUMBER CORRESPONDING ON THE LOAN AMORTIZATION SCHEDULE
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/18/2005 6:42PM     raverma           Created
 *=======================================================================*/
function getRateSchedule(p_loan_id in number
                        ,p_phase   in varchar2) return LNS_FINANCIALS.RATE_SCHEDULE_TBL
is

    l_rate_tbl           LNS_FINANCIALS.RATE_SCHEDULE_TBL;
    l_rate_id            number;
    l_annual_rate        number;
    l_spread             number;
    l_start_date         date;
    l_begin_installment  number;
    l_end_installment    number;
    l_interest_only_flag varchar2(1);
    l_floating_flag      varchar2(1);
    l_end_date           date;
    i                    number;
    l_api_name           varchar2(20);

    cursor c_rate_schedule (p_loan_id number, p_phase varchar2)
    is
    select rate_id
          ,current_interest_rate
          ,nvl(spread, 0)
          ,trunc(start_date_active)
          ,trunc(end_date_active)
          ,begin_installment_number
          ,end_installment_number
          ,nvl(interest_only_flag, 'N')
          ,nvl(floating_flag, 'N')
      from lns_loan_headers_all h,
           lns_terms t,
           lns_rate_schedules rs
     where h.loan_id = p_loan_id
       and h.loan_id = t.loan_id
       and t.term_id = rs.term_id
       and rs.end_date_active is null
       and nvl(phase, 'TERM') = p_phase
  order by begin_installment_number
          ,start_date_active;

begin

        i          := 0;
        l_api_name := 'getRateSchedule';
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

        Begin
            OPEN c_rate_schedule(p_loan_id, p_phase);
            LOOP
                i := i + 1;
            FETCH c_rate_schedule INTO
                l_rate_id
               ,l_annual_rate
               ,l_spread
               ,l_start_date
               ,l_end_date
               ,l_begin_installment
               ,l_end_installment
               ,l_interest_only_flag
               ,l_floating_flag;
            EXIT WHEN c_rate_schedule%NOTFOUND;
                l_rate_tbl(i).rate_id                  := l_rate_id;
                l_rate_tbl(i).annual_rate              := l_annual_rate;
                l_rate_tbl(i).spread                   := l_spread;
                l_rate_tbl(i).begin_date               := l_start_date;
                l_rate_tbl(i).end_date                 := l_end_date;
                l_rate_tbl(i).begin_installment_number := l_begin_installment;
                l_rate_tbl(i).end_installment_number   := l_end_installment;
                l_rate_tbl(i).interest_only_flag       := l_interest_only_flag;
                l_rate_tbl(i).FLOATING_FLAG            := l_floating_flag;
            END LOOP;
        Exception
            When No_Data_Found then
             FND_MESSAGE.Set_Name('LNS', 'LNS_NO_RATES');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
        End;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

        return l_rate_tbl;

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
         logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end getRateSchedule;

/*=========================================================================
|| PUBLIC PROCEDURE getWeightedRate
||
|| DESCRIPTION
||
|| Overview:  Calculates the weighted average interest rate for a period
||            of time for a table of rates
||
|| Parameter: p_start_date => date to begin periodic rate  (last interest accrual date for loan payoff)
||            p_end_date   => date to end periodic rate
||            p_rate_tbl   => table of rate schedules
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value:  Annualized Rate weighted by rates
||
|| KNOWN ISSUES
||             rounding? only works to the daily level
||             days count method is unclear? (see function intervalsInPeriod)
||             any dates left out will be assumed to be interest rate of 0
||
|| there are 9 scenarios possible:
||
|| P_Start_Date                           p_End_date
||        +------------------------------------+  (time line to get periodic rate)
||
|| Scen 1: (rate tbl matches exactly)
||        +------------------------------------+  (time line to get periodic rate)
||        +------------------------------------+  (rate table time line)
||
|| Scen 2: (rate tbl further than end date)
||        +------------------------------------+  (time line to get periodic rate)
||        +------------------------------------------+ (rate table time line)
||
|| Scen 3: (rate tbl shorter than end date)
||        +------------------------------------+  (time line to get periodic rate)
||        +-------------------------------+       (rate table time line)
||
|| Scen 4: (rate tbl before start date)
||        +------------------------------------+  (time line to get periodic rate)
||    +----------------------------------------+  (rate table time line)
||
|| Scen 5: (rate tbl before start date)
||        +------------------------------------+  (time line to get periodic rate)
||    +----------------------------------------+  (rate table time line)
||
|| Scen 6: (rate tbl after start date)
||        +------------------------------------+  (time line to get periodic rate)
||             +-------------------------------+  (rate table time line)
||
|| Scen 7: (rate tbl is shorter than period)
||        +------------------------------------+  (time line to get periodic rate)
||            +-------------------------+         (rate table time line)
||
|| Scen 8: (rate tbl is longer than period)
||        +------------------------------------+  (time line to get periodic rate)
||    +-------------------------------------------------------+ (rate table time line)
||
|| Scen 9: (rate tbl is not contiguous)
||        +------------------------------------+  (time line to get periodic rate)
||           +--+  +---+     +------+   +-----+   (rate table time line)
||
||
||   only scenarios 3, 6, 7, 9 do we have periods to assume that rate is = 0
||   in all other scenarios the rate table covers the period of time allotted
||
||   also, it is assumed that the rate table is a contiguous period of time
||
|| NOTES
||
||      there are implicit assumptions that CANNOT be made when calculating
||       wtd avg interest for a given period.
||      for example, you cannot simply put in a
||         [ (# days @ rate 1 X rate 1) +
||           (# days @ rate 2 X rate 2) +
||           (# days @ rate 3 X rate 3) +  ]
||         / total # days in rate schedule
||        because we may have p_start_date > rate 1 start date and
||                            p_end_date < rate 3 end date
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 2/09/2003 1:51PM     raverma           Created
||
 *=======================================================================*/
function getWeightedRate(p_loan_details in LNS_FINANCIALS.LOAN_DETAILS_REC
                        ,p_start_date in date
                        ,p_end_date   in date
                        ,p_rate_tbl   in LNS_FINANCIALS.RATE_SCHEDULE_TBL) return number
is
    l_api_name          varchar2(25);
    l_rate_details      LNS_FINANCIALS.INTEREST_RATE_REC;
    l_pay_dates         LNS_FINANCIALS.DATE_TBL;
    l_days_at_rate      number;
    l_weighted_rate     number;
    l_running_weight    number;
    l_total_days        number;
    l_num_pay_dates     number;
    l_period_start_date date;
    l_period_end_date   date;
    --l_pay_in_arrears    boolean;
    l_payment_tbl       LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_exit_loop         boolean;

begin

    l_api_name       := 'getWeightedRate';
    l_days_at_rate   := 0;
    l_weighted_rate  := 0;
    l_running_weight := 0;
    l_total_days     := 0;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' start date ' || p_start_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' end date ' || p_end_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rate table count ' || p_rate_tbl.count);

    if p_loan_details.custom_schedule = 'N' then

        if p_loan_details.PAYMENT_CALC_METHOD = 'SEPARATE_SCHEDULES' then

            l_payment_tbl := LNS_FIN_UTILS.buildSIPPaymentSchedule(
                                    p_loan_start_date      => p_loan_details.loan_start_date
                                    ,p_loan_maturity_date  => p_loan_details.maturity_date
                                    ,p_int_first_pay_date  => p_loan_details.first_payment_date
                                    ,p_int_num_intervals   => p_loan_details.number_installments
                                    ,p_int_interval_type   => p_loan_details.payment_frequency
                                    ,p_int_pay_in_arrears  => p_loan_details.pay_in_arrears_boolean
                                    ,p_prin_first_pay_date => p_loan_details.PRIN_FIRST_PAY_DATE
                                    ,p_prin_num_intervals  => p_loan_details.PRIN_NUMBER_INSTALLMENTS
                                    ,p_prin_interval_type  => p_loan_details.PRIN_PAYMENT_FREQUENCY
                                    ,p_prin_pay_in_arrears => p_loan_details.PRIN_PAY_IN_ARREARS_BOOL);

        else

            l_payment_tbl := LNS_FIN_UTILS.buildPaymentSchedule(p_loan_start_date    => p_loan_details.loan_start_date
                                                                ,p_loan_maturity_date => p_loan_details.maturity_date
                                                                ,p_first_pay_date     => p_loan_details.first_payment_date
                                                                ,p_num_intervals      => p_loan_details.number_installments
                                                                ,p_interval_type      => p_loan_details.payment_frequency
                                                                ,p_pay_in_arrears     => p_loan_details.pay_in_arrears_boolean);


        end if;

    else

        -- build custom payment schedule
        l_payment_tbl := LNS_CUSTOM_PUB.buildCustomPaySchedule(p_loan_details.LOAN_ID);

    end if;

    l_num_pay_dates := l_payment_tbl.count;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' num pay dates is ' || l_num_pay_dates);
--    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' num installments is ' || p_loan_details.number_installments);

--    for k in 1..p_loan_details.number_installments
    for k in 1..l_num_pay_dates
    loop

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Period: ' || k);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' period start is ' || l_payment_tbl(k).period_begin_date);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' period end is ' || l_payment_tbl(k).period_end_date);
       -- check to see if this period is covered in the time

       l_exit_loop := false;
       l_period_start_date := null;
       if p_start_date >= l_payment_tbl(k).period_begin_date and
          p_start_date < l_payment_tbl(k).period_end_date then
            l_period_start_date := p_start_date;
       elsif p_start_date < l_payment_tbl(k).period_begin_date and
          p_start_date < l_payment_tbl(k).period_end_date then
            l_period_start_date := l_payment_tbl(k).period_begin_date;
       end if;

       l_period_end_date := null;
       if p_end_date >= l_payment_tbl(k).period_begin_date and
          p_end_date <= l_payment_tbl(k).period_end_date then
            l_period_end_date := p_end_date;
            l_exit_loop := true;
       elsif p_end_date >= l_payment_tbl(k).period_begin_date and
          p_end_date > l_payment_tbl(k).period_end_date then
            if k = l_num_pay_dates then
                l_period_end_date := p_end_date;
                l_exit_loop := true;
            else
                l_period_end_date := l_payment_tbl(k).period_end_date;
            end if;
       end if;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_period_start_date: ' || l_period_start_date);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_period_end_date: ' || l_period_end_date);

       if l_period_start_date is not null and l_period_end_date is not null then

          l_days_at_rate := LNS_FIN_UTILS.getDayCount(p_start_date       => l_period_start_date
                                                     ,p_end_date         => l_period_end_date
                                                     ,p_day_count_method => p_loan_details.day_count_method);
          l_rate_details := getRateDetails(p_installment => k
                                          ,p_rate_tbl    => p_rate_tbl);

          l_total_days     := l_total_days + l_days_at_rate;
          l_running_weight := l_running_weight + (l_rate_details.annual_rate  * l_days_at_rate);

       end if;

       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_days_at_rate: ' || l_days_at_rate);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_rate: ' || l_rate_details.annual_rate);
       logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_running_weight: ' || l_running_weight);

       if l_exit_loop then
           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' Exiting loop');
           exit;
       end if;

    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' total days is ' || l_total_days);

    if l_total_days = 0 then
        l_total_days := 1;
    end if;

    l_weighted_rate := l_running_weight / l_total_days;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' l_weighted_rate ' || l_weighted_rate);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_weighted_rate;

end getWeightedRate;


/*=========================================================================
|| PUBLIC PROCEDURE getRateDetails
||
|| DESCRIPTION
||
|| Overview:  return a interest_rate_record for a given installment
||
||
|| Parameter:  p_installment => installment to get rate details
||             p_rate_tbl    => table of interest rates
||
||
|| Return value: NA
||
|| Source Tables: NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||      if no rates can be found in set of give dates a rate of 0 is returned
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 2/24/2003 4:28PM     raverma           Created
 *=======================================================================*/
function getRateDetails(p_installment IN NUMBER
                       ,p_rate_tbl    IN LNS_FINANCIALS.RATE_SCHEDULE_TBL) return LNS_FINANCIALS.INTEREST_RATE_REC
is
  x          number;
  l_rate     number;
  l_rate_rec LNS_FINANCIALS.INTEREST_RATE_REC;
  l_api_name varchar2(25);

begin

    l_rate     := 0;
    l_api_name := 'getRateDetails2';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - installment ' || p_installment);

    x := 1;
    Begin
       LOOP
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - match row ' || x);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rate ' || p_rate_tbl(x).annual_rate);
            l_rate := p_rate_tbl(x).annual_rate;
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - rate 1');
            l_rate_rec := p_rate_tbl(x);
          EXIT WHEN p_installment >= p_rate_tbl(x).begin_installment_number and
                    p_installment <= p_rate_tbl(x).end_installment_number;
          x := x + 1;
       END LOOP;
    Exception
       When No_Data_found then
           -- when there is not a rate for this period it is assumed to be zero (see scenarios 3, 6, 8 in comments on getWeightedRate)
           --l_rate := 0;
           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - no rate found for period');
       when others then
           l_rate := 0;

    End;

    if l_rate = 0 then
       l_rate_rec.annual_rate := 0;
    end if;

    --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    return l_rate_rec;

end getRateDetails;


/*=========================================================================
 | PUBLIC PROCEDURE getRateDetails
||
|| DESCRIPTION
||
|| Overview:  return a interest_rate_record for a given date
||
||
|| Parameter:  p_date => to get rate details
||             p_rate_tbl => table of interest rates
||
||
|| Return value: NA
||
|| Source Tables: NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||      if no rates can be found in set of give dates a rate of 0 is returned
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 2/24/2003 4:28PM     raverma           Created
||
 *=======================================================================*/
function getRateDetails(p_date in date
                       ,p_rate_tbl in LNS_FINANCIALS.RATE_SCHEDULE_TBL) return LNS_FINANCIALS.INTEREST_RATE_REC
is
  x          number;
  l_rate     number;
  l_rate_rec LNS_FINANCIALS.INTEREST_RATE_REC;
  l_api_name varchar2(25);

begin

    l_rate     := 0;
    l_api_name := 'getRateDetails';
--        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    x := 1;
    Begin
       LOOP
             l_rate := p_rate_tbl(x).annual_rate;
             l_rate_rec := p_rate_tbl(x);
          EXIT WHEN p_date >= p_rate_tbl(x).begin_date and p_date <= p_rate_tbl(x).end_date;

          x := x + 1;
       END LOOP;
    Exception
       When No_Data_found then
           -- when there is not a rate for this period it is assumed to be zero (see scenarios 3, 6, 8 in comments on getWeightedRate)
           l_rate := 0;
           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - no rate found for period');
       when others then
           l_rate := 0;

    End;

    if l_rate = 0 then
       l_rate_rec.annual_rate := 0;
    end if;

--        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_rate_rec;

end getRateDetails;

/*=========================================================================
|| PUBLIC PROCEDURE getLoanDetails
||
|| DESCRIPTION
||
|| Overview:  return a rec_type of loan details
||
|| Parameter:  loan_id
||
|| Return value: table of dates
||
|| Source Tables: LNS_LOAN_HEADER, LNS_TERMS, LNS_AMORTIZATION_SCHEDS
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 1/15/2004 4:28PM     raverma           Created
|| 2/26/2004            raverma           add loan_maturity_Date
|| 3/12/2004            raverma           added reamortization information
|| 4/15/2004            raverma           added loan_status
|| 8/02/2004            raverma           added logic to calculate num_amortization_intervals based on
||                                        theoretical amortization_maturity_date
|| 01/19/2007           scherkas          Fixed bug 5842639
 *=======================================================================*/
function getLoanDetails(p_loan_id        in number
                       ,p_based_on_terms in varchar2
					   ,p_phase          in varchar2) return LNS_FINANCIALS.LOAN_DETAILS_REC

is


    -- get the loan details assumes there is only ONE ROW in terms (TERM PHASE)
    CURSOR c_loan_details(p_Loan_id NUMBER, p_based_on_terms varchar2, p_phase varchar2) IS
    SELECT h.loan_id
        ,decode(p_phase, 'TERM', h.loan_term, 'OPEN', h.open_loan_term, h.loan_term) TERM
        ,decode(p_phase, 'TERM', h.loan_term_period, 'OPEN', h.open_loan_term_period, h.loan_term_period) TERM_PERIOD
        ,decode(p_phase, 'TERM', decode(h.balloon_payment_type, 'TERM', h.amortized_term, 'AMOUNT', h.loan_term, h.amortized_term), 'OPEN', h.open_loan_term) AMORT_TERM
        ,decode(p_phase, 'TERM', decode(h.balloon_payment_type, 'TERM', h.amortized_term_period, 'AMOUNT', h.loan_term_period, h.amortized_term_period), 'OPEN', h.open_loan_term_period) AMORT_TERM_PERIOD
		,decode(h.balloon_payment_type, 'TERM', 0, 'AMOUNT', h.balloon_payment_amount, 0) BALLOON_PAYMENT_AMT
        ,decode(p_phase, 'TERM', t.amortization_frequency, 'OPEN', t.loan_payment_frequency) AMORT_FREQ
        ,decode(p_phase, 'TERM', t.loan_payment_frequency, 'OPEN', t.open_payment_frequency, t.loan_payment_frequency) PAY_FREQ
        ,decode(p_phase, 'TERM', trunc(h.loan_start_date), 'OPEN' , trunc(h.open_loan_start_date), trunc(h.loan_start_date)) START_DATE
        ,decode(p_phase, 'TERM', trunc(t.first_payment_date), 'OPEN' , trunc(t.open_first_payment_date), trunc(t.first_payment_date)) FIRST_PAY_DATE
		,h.requested_amount REQUEST_AMOUNT
		,h.funded_amount FUNDED_AMOUNT
        ,lns_financials.getRemainingBalance(p_loan_id) BALANCE
        --,decode(p_based_on_terms, 'CURRENT', lns_financials.getRemainingBalance(p_loan_id), 'ORIGINAL', h.requested_amount) BALANCE -- see bug #3881401
        ,decode(p_phase, 'TERM', trunc(h.loan_maturity_date), 'OPEN', trunc(h.open_maturity_date), trunc(h.loan_maturity_date)) MATURITY_DATE
        ,NVL(t.reamortize_over_payment, 'N')
        ,NVL(t.reamortize_under_payment, 'N')
        ,NVL(t.reamortize_with_interest, 'N')
        ,LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id, p_phase) LAST_PAY_NUM
        --,decode(p_based_on_terms, 'CURRENT', LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id),'ORIGINAL', 1) LAST_PAY_NUM
        ,decode(nvl(t.day_count_method, 'PERIODIC30_360'), 'PERIODIC30_360', '30/360', t.day_count_method) DAY_COUNT
        ,decode(p_phase, 'TERM', decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y')
				       , 'OPEN', decode(trunc(t.open_first_payment_date) - trunc(h.open_loan_start_date), 0, 'N', 'Y')
                       , decode(trunc(t.first_payment_date) - trunc(h.loan_start_date), 0, 'N', 'Y')) ARREARS
		,nvl(h.custom_payments_flag, 'N')   CUSTOM
        ,h.loan_status                      LOAN_STATUS
        ,h.loan_currency                    CURRENCY
        ,curr.precision                     PRECISION
        ,h.OPEN_TO_TERM_FLAG                OPEN_TO_TERM_FLAG
        ,h.OPEN_TO_TERM_EVENT               OPEN_TO_TERM_EVENT
        ,h.MULTIPLE_FUNDING_FLAG            MULTIPLE_FUNDING_FLAG
        ,h.SECONDARY_STATUS                 SECONDARY_STATUS
        ,t.RATE_TYPE                        RATE_TYPE
        ,t.CEILING_RATE                     TERM_CEILING_RATE
        ,t.FLOOR_RATE                       TERM_FLOOR_RATE
        ,t.PERCENT_INCREASE                 TERM_PERCENT_INCREASE
        ,t.PERCENT_INCREASE_LIFE            TERM_PERCENT_INCREASE_LIFE
        ,t.FIRST_PERCENT_INCREASE           TERM_FIRST_PERCENT_INCREASE
        ,t.OPEN_PERCENT_INCREASE            OPEN_PERCENT_INCREASE
        ,t.OPEN_PERCENT_INCREASE_LIFE       OPEN_PERCENT_INCREASE_LIFE
        ,t.OPEN_FIRST_PERCENT_INCREASE      OPEN_FIRST_PERCENT_INCREASE
        ,t.OPEN_CEILING_RATE                OPEN_CEILING_RATE
        ,t.OPEN_FLOOR_RATE                  OPEN_FLOOR_RATE
        ,t.OPEN_PROJECTED_RATE              OPEN_PROJECTED_RATE
        ,t.TERM_PROJECTED_RATE              TERM_PROJECTED_RATE
        ,t.rate_change_frequency            TERM_RATE_CHG_FREQ
        ,t.rate_change_frequency            OPEN_RATE_CHG_FREQ
        ,t.INDEX_RATE_ID                    OPEN_INDEX_RATE_ID
        ,t.INDEX_RATE_ID                    TERM_INDEX_RATE_ID
        ,t.OPEN_INDEX_DATE                  OPEN_INDEX_DATE
        ,t.TERM_INDEX_DATE                  TERM_INDEX_DATE
        ,decode(p_phase, 'TERM', t.TERM_PROJECTED_RATE, t.OPEN_PROJECTED_RATE) INITIAL_INTEREST_RATE
        ,nvl(lns_fin_utils.getActiveRate(h.loan_id), decode(p_phase, 'TERM', t.TERM_PROJECTED_RATE, t.OPEN_PROJECTED_RATE))            LAST_INTEREST_RATE
        ,nvl(t.FIRST_RATE_CHANGE_DATE, t.NEXT_RATE_CHANGE_DATE) FIRST_RATE_CHANGE_DATE
        ,t.NEXT_RATE_CHANGE_DATE             NEXT_RATE_CHANGE_DATE
        ,t.CALCULATION_METHOD
        ,t.INTEREST_COMPOUNDING_FREQ
        ,decode(p_phase, 'TERM', decode(p_based_on_terms,
            'CURRENT', decode(nvl(h.custom_payments_flag, 'N'), 'Y', nvl(t.PAYMENT_CALC_METHOD, 'CUSTOM'),
                                                                'N', nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT')),
            decode(nvl(h.custom_payments_flag, 'N'), 'Y', nvl(t.ORIG_PAY_CALC_METHOD, 'CUSTOM'),
                                                     'N', nvl(t.PAYMENT_CALC_METHOD, 'EQUAL_PAYMENT'))
         ), null)
        ,t.ORIG_PAY_CALC_METHOD
        ,decode(p_phase, 'TERM', trunc(nvl(t.prin_first_pay_date, t.first_payment_date)), 'OPEN', null, trunc(nvl(t.prin_first_pay_date, t.first_payment_date)))
        ,nvl(t.prin_payment_frequency, t.loan_payment_frequency)
        ,decode(trunc(nvl(t.prin_first_pay_date, t.first_payment_date)) - trunc(h.loan_start_date), 0, 'N', 'Y')  -- calculate in advance or arrears for principal
        ,nvl(t.PENAL_INT_RATE, 0)
        ,nvl(t.PENAL_INT_GRACE_DAYS, 0)
        ,nvl(h.CURRENT_PHASE, 'TERM')
        ,nvl(t.REAMORTIZE_ON_FUNDING, 'REST')
    FROM lns_loan_headers_all h
        ,lns_terms t
        ,fnd_currencies  curr
    WHERE h.loan_id = p_loan_id
		 AND t.loan_id = h.loan_id
	   AND curr.currency_code = h.loan_currency;

      /*
  -- this is appropriate for OPEN + TERM phase
	cursor c_rate_information(p_loan_id number, p_phase varchar) is
  select t.rate_type                    -- term_phase
        ,t.rate_change_frequency        -- term_phase
        ,t.index_rate_id                -- term_phase
        ,rs.index_date                  -- term_phase
        ,nvl(t.ceiling_rate, 100)       -- term_phase
        ,nvl(t.floor_rate, 0)           -- term_phase
	  from lns_rate_schedules rs
			  ,lns_terms t
	 where t.loan_id = p_loan_id
		 AND t.term_id = rs.term_id
     AND rs.phase = p_phase
		 AND rs.begin_installment_number = 1
		 AND rs.end_date_active is null;
        */

  -- get reamortization information
  -- this is temporary place on LNS_AMORTIZATION_SCHEDS
  -- we should move this to LNS_TERMS when we have terms realignment
	-- bug# 5664316 - we only store ONE reamortization row
    CURSOR c_reamortization(p_Loan_id NUMBER) IS
    SELECT nvl(reamortization_amount, 0)
        ,nvl(reamortize_from_installment, 0)
        ,nvl(reamortize_to_installment, 0)
    FROM lns_loan_headers_all lnh,
         lns_amortization_scheds amort1
    WHERE lnh.loan_id = amort1.loan_id(+)
     AND lnh.loan_id = p_loan_id
     AND amort1.reamortization_amount > 0;

    -- cursor to get the balance information for the loan
    -- changes as per scherkas 11-16-2005
    cursor c_balanceInfo(p_loan_id NUMBER, p_phase varchar2) IS
    select  nvl(sum(amort.PRINCIPAL_AMOUNT),0)                       -- billed principal
          ,nvl(sum(amort.PRINCIPAL_REMAINING),0)  -- unpaid principal
          ,nvl(sum(amort.INTEREST_REMAINING),0)  -- unpaid interest
    from LNS_AM_SCHEDS_V amort
    where amort.Loan_id = p_loan_id
      and amort.REVERSED_CODE = 'N'
      and amort.phase = p_phase;

    -- this cursor will get the last time the loan interest was accrued
    -- fix for bug 7423644: removed condition interest_trx_id is not null
    cursor c_last_interest_accrual(p_loan_id NUMBER) is
    select decode(LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(lnh.loan_id),
          0,
          decode(lnh.current_phase, 'TERM', lnh.loan_start_date, 'OPEN', lnh.open_loan_start_date),
          (select max(due_date)
            from lns_amortization_scheds
            where reversed_flag = 'N'
              and loan_id = lnh.loan_id
              and phase = lnh.current_phase))
    from lns_loan_headers lnh
    where lnh.loan_id = p_loan_id;

    -- this cursor is to get the last activity date on the loan
    -- payoff processing will use this date
    cursor c_last_loan_activity(p_loan_id number) is
    select max(activity_date)
      from LNS_REC_ACT_CASH_CM_V
     where activity_code = 'PMT'
       and loan_id = p_loan_id;

   -- begin fix for bug 6724561
   -- cursor to get latest extended from installment - last billed installment from the last approved loan extension
   cursor c_ext_from_install(p_loan_id NUMBER) IS
    select LAST_BILLED_INSTALLMENT
    from LNS_LOAN_EXTENSIONS
    where loan_id = p_loan_id
        and STATUS = 'APPROVED'
    order by LOAN_EXT_ID desc;
    -- end fix for bug 6724561

   -- begin fix for bug 6724522
   -- cursor to get original loan term if loan has been extended
   cursor c_orig_loan_term(p_loan_id NUMBER) IS
    select OLD_TERM,
        OLD_TERM_PERIOD,
        OLD_BALLOON_TYPE,
        OLD_BALLOON_AMOUNT,
        OLD_AMORT_TERM,
        OLD_MATURITY_DATE,
        OLD_INSTALLMENTS
    from LNS_LOAN_EXTENSIONS
    where loan_id = p_loan_id
        and STATUS = 'APPROVED'
    order by LOAN_EXT_ID;

    l_orig_loan_term        number;
    l_orig_loan_period      varchar2(30);
    l_orig_balloon_type     varchar2(30);
    l_orig_balloon_amount   number;
    l_orig_amort_term       number;
    l_orig_maturity_date    date;
    l_orig_num_install      number;
   -- end fix for bug 6724522

    l_billed_principal  number;
    l_amortized_to_Date date;
    --l_pay_in_arrears    boolean;
    l_loan_Details      LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_amortize_dates    LNS_FIN_UTILS.DATE_TBL;
    l_loan_id           number;
    l_api_name          varchar2(25);

begin

    l_api_name         := 'getLoanDetails';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    --l_loan_id := p_loan_id;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' p_loan_id:         ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' p_based_on_terms:  ' || p_based_on_terms);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' p_phase:           ' || p_phase);

    OPEN c_loan_details(p_loan_id, p_based_on_terms, p_phase);
    FETCH c_loan_details INTO
        l_loan_details.loan_id
        ,l_loan_Details.loan_term
        ,l_loan_Details.loan_term_period
        ,l_loan_Details.amortized_term
        ,l_loan_Details.amortized_term_period
        ,l_loan_details.balloon_payment_amount
        ,l_loan_Details.amortization_frequency
        ,l_loan_Details.payment_frequency
        ,l_loan_Details.loan_start_date
        ,l_loan_Details.first_payment_date
        ,l_loan_Details.requested_amount
        ,l_loan_details.funded_amount
        ,l_loan_details.remaining_balance
        ,l_loan_details.maturity_Date
        ,l_loan_details.reamortize_overpay
        ,l_loan_details.reamortize_underpay
        ,l_loan_details.reamortize_with_interest
        ,l_loan_details.last_installment_billed
        ,l_loan_details.day_count_method
        ,l_loan_details.pay_in_arrears
        ,l_loan_details.custom_schedule
        ,l_loan_details.loan_status
        ,l_loan_details.loan_currency
        ,l_loan_details.currency_precision
        ,l_loan_details.OPEN_TO_TERM_FLAG
        ,l_loan_details.OPEN_TO_TERM_EVENT
        ,l_loan_details.MULTIPLE_FUNDING_FLAG
        ,l_loan_details.SECONDARY_STATUS
        ,l_loan_details.RATE_TYPE                    -- fixed or variable
        ,l_loan_details.TERM_CEILING_RATE            -- term ceiling rate
        ,l_loan_details.TERM_FLOOR_RATE              -- term floor rate
        ,l_loan_details.TERM_ADJ_PERCENT_INCREASE    -- term percentage increase btwn adjustments
        ,l_loan_details.TERM_LIFE_PERCENT_INCREASE   -- term lifetime max adjustment for interest
        ,l_loan_details.TERM_FIRST_PERCENT_INCREASE  -- term first percentage increase
        ,l_loan_details.OPEN_ADJ_PERCENT_INCREASE    -- open percentage increase btwn adjustments
        ,l_loan_details.OPEN_LIFE_PERCENT_INCREASE   -- open lifetime max adjustment for interest
        ,l_loan_details.OPEN_FIRST_PERCENT_INCREASE  -- open first percentage increase
        ,l_loan_details.OPEN_CEILING_RATE            -- open ceiling rate
        ,l_loan_details.OPEN_FLOOR_RATE              -- open floor rate
        ,l_loan_details.OPEN_PROJECTED_INTEREST_RATE -- open projected interest rate
        ,l_loan_details.TERM_PROJECTED_INTEREST_RATE -- term projected interest rate
        ,l_loan_details.OPEN_RATE_CHG_FREQ
        ,l_loan_details.TERM_RATE_CHG_FREQ
        ,l_loan_details.OPEN_INDEX_RATE_ID
        ,l_loan_details.TERM_INDEX_RATE_ID
        ,l_loan_details.OPEN_INDEX_DATE
        ,l_loan_details.TERM_INDEX_DATE
        ,l_loan_details.INITIAL_INTEREST_RATE        -- current phase only
        ,l_loan_details.LAST_INTEREST_RATE           -- current phase only
        ,l_loan_details.FIRST_RATE_CHANGE_DATE       -- current phase only
        ,l_loan_details.NEXT_RATE_CHANGE_DATE        -- current phase only
        ,l_loan_details.CALCULATION_METHOD
        ,l_loan_details.INTEREST_COMPOUNDING_FREQ
        ,l_loan_details.PAYMENT_CALC_METHOD
        ,l_loan_details.ORIG_PAY_CALC_METHOD
        ,l_loan_details.prin_first_pay_date
        ,l_loan_details.prin_payment_frequency
        ,l_loan_details.PRIN_PAY_IN_ARREARS
        ,l_loan_details.PENAL_INT_RATE
        ,l_loan_details.PENAL_INT_GRACE_DAYS
        ,l_loan_details.LOAN_PHASE
        ,l_loan_details.REAMORTIZE_ON_FUNDING
        ;
    close c_loan_details;

     /*  open c_rate_information(p_loan_id, p_phase) ;
			fetch c_rate_information into
					  l_loan_details.open_rate_type
					 ,l_loan_details.open_rate_chg_freq
					 ,l_loan_details.open_index_rate_id
					 ,l_loan_details.open_index_date
					 ,l_loan_details.open_ceiling_rate
					 ,l_loan_details.open_floor_rate;
			close c_rate_information;
      */

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate_type ' || l_loan_details.rate_type);
    --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': open_rate_chg_freq ' || l_loan_details.open_rate_chg_freq);
    --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': open_index_rate_id ' || l_loan_details.open_index_rate_id);
    --logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': open_index_date ' || l_loan_details.open_index_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': open_ceiling_rate ' || l_loan_details.open_ceiling_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': open_floor_rate ' || l_loan_details.open_floor_rate);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': balloon_payment_amount' || l_loan_details.balloon_payment_amount);

    -- begin fix for bug 6724522
    -- replacing loan terms with original data for p_based_on_terms <> 'CURRENT'
    if p_based_on_terms <> 'CURRENT' then
        open c_orig_loan_term(p_loan_id);
        fetch c_orig_loan_term into
            l_orig_loan_term,
            l_orig_loan_period,
            l_orig_balloon_type,
            l_orig_balloon_amount,
            l_orig_amort_term,
            l_orig_maturity_date,
            l_orig_num_install;
        close c_orig_loan_term;

        if l_orig_loan_term is not null and
           l_orig_loan_period is not null and
           l_orig_balloon_type is not null and
           l_orig_balloon_amount is not null and
           l_orig_amort_term is not null and
           l_orig_maturity_date is not null and
           l_orig_num_install is not null
        then
            l_loan_Details.loan_term := l_orig_loan_term;
            l_loan_Details.loan_term_period := l_orig_loan_period;
            l_loan_Details.amortized_term_period := l_orig_loan_period;
            l_loan_Details.maturity_Date := l_orig_maturity_date;
            l_loan_Details.ORIG_NUMBER_INSTALLMENTS := l_orig_num_install;

            if l_orig_balloon_type = 'TERM' then
                l_loan_details.balloon_payment_amount := 0;
                l_loan_Details.amortized_term := l_orig_amort_term;
            elsif l_orig_balloon_type = 'AMOUNT' then
                l_loan_details.balloon_payment_amount := l_orig_balloon_amount;
                l_loan_Details.amortized_term := l_orig_loan_term;
            end if;
        end if;
    end if;
    -- end fix for bug 6724522

    -- begin fix for bug 6724561
    -- get latest extended from installment
    if p_based_on_terms = 'CURRENT' then
        open c_ext_from_install(p_loan_id);
        fetch c_ext_from_install into l_loan_Details.extend_from_installment;
        close c_ext_from_install;
    end if;
    -- end fix for bug 6724561

    -- adding balloon amount
	l_loan_details.amortized_amount := l_loan_details.requested_amount - l_loan_details.balloon_payment_amount;

    open c_last_interest_accrual(p_loan_id);
    fetch c_last_interest_accrual into l_loan_details.last_interest_accrual;
    close c_last_interest_accrual;

    if l_loan_details.pay_in_arrears = 'Y' then
       l_loan_details.pay_in_arrears_boolean := true;
    else
       l_loan_details.pay_in_arrears_boolean := false;
    end if;

    if l_loan_details.PRIN_PAY_IN_ARREARS = 'Y' then
       l_loan_details.PRIN_PAY_IN_ARREARS_BOOL := true;
    else
       l_loan_details.PRIN_PAY_IN_ARREARS_BOOL := false;
    end if;

/*
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': getting number of intervals');
    -- get the number of installments on a loan
    -- this represents the number of payments on the loan

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting number of payment intervals');
    l_loan_details.number_installments := lns_fin_utils.intervalsInPeriod(l_loan_Details.loan_term
                                                                        ,l_loan_Details.loan_term_period
                                                                        ,l_loan_Details.payment_frequency);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting number of principal payment intervals');
    l_loan_details.PRIN_NUMBER_INSTALLMENTS := lns_fin_utils.intervalsInPeriod(l_loan_Details.loan_term
                                                                         ,l_loan_Details.loan_term_period
                                                                         ,l_loan_Details.prin_payment_frequency);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting number of principal amortized payment intervals');
    l_loan_details.PRIN_AMORT_INSTALLMENTS := lns_fin_utils.intervalsInPeriod(l_loan_Details.amortized_term
                                                                         ,l_loan_Details.amortized_term_period
                                                                         ,l_loan_Details.prin_payment_frequency);

    -- get the number of amortization intervals on a loan
    -- the number of amortization intervals is counted from the first payment date
    -- this number will be used in the amortization equation
    if l_loan_details.pay_in_arrears = 'Y' then
        l_loan_details.pay_in_arrears_boolean := true;
    else
        l_loan_details.pay_in_arrears_boolean := false;
    end if;

    if l_loan_details.PRIN_PAY_IN_ARREARS = 'Y' then
       l_loan_details.PRIN_PAY_IN_ARREARS_BOOL := true;
    else
       l_loan_details.PRIN_PAY_IN_ARREARS_BOOL := false;
    end if;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting number of amortization intervals');
    l_loan_details.num_amortization_intervals := lns_fin_utils.intervalsInPeriod(l_loan_Details.amortized_term
                                                                                ,l_loan_Details.amortized_term_period
                                                                                ,l_loan_Details.amortization_frequency);
    if l_loan_details.balloon_payment_amount > 0 then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - reducing number of amortization intervals');
        l_loan_details.num_amortization_intervals := l_loan_details.num_amortization_intervals - 1;
    end if;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting amortized to date');
    l_amortized_to_Date := LNS_FIN_UTILS.getMaturityDate(p_term         => l_loan_Details.amortized_term
                                                        ,p_term_period  => l_loan_Details.amortized_term_period
                                                        ,p_frequency    => l_loan_Details.amortization_frequency
                                                        ,p_start_date   => l_loan_Details.loan_start_date);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting payment schedule');
    -- fix for bug 5842639: added p_loan_start_date parameter to LNS_FIN_UTILS.getPaymentSchedule
    l_amortize_dates := LNS_FIN_UTILS.getPaymentSchedule(p_loan_start_date => l_loan_Details.loan_start_date
                                                        ,p_first_pay_date => l_loan_Details.first_payment_date
                                                        ,p_maturity_Date  => l_amortized_to_Date
                                                        ,p_pay_in_arrears => l_loan_details.pay_in_arrears_boolean
                                                        ,p_num_intervals  => l_loan_details.num_amortization_intervals
                                                        ,p_interval_type  => l_loan_Details.amortization_frequency);

    -- we amortize over the actual number of installments on the payment schedule
    l_loan_details.num_amortization_intervals := l_amortize_dates.count;
*/
    -- use this part of the procedure to differentiate between
    -- elements that are calculated differently for current and original
    -- amortization

    if p_based_on_terms = 'CURRENT' then
        -- get reamortization information
        Begin
            -- bug# 5664316 make sure we catch no data found on EACH cursor: reamortization, activity, balanceInfo
            open c_reamortization(p_loan_id);
            fetch c_reamortization into
                    l_loan_details.reamortize_amount
                ,l_loan_details.reamortize_from_installment
                ,l_loan_details.reamortize_to_installment;
            close c_reamortization;
        Exception
            when no_data_found then
            l_loan_details.reamortize_amount           := 0;
            l_loan_details.reamortize_from_installment := null;
            l_loan_details.reamortize_to_installment   := 0;
        End;

        Begin

            open c_last_loan_activity(p_loan_id);
            fetch c_last_loan_activity into
                    l_loan_details.last_activity_date;
            close c_last_loan_activity;
        Exception
            when no_data_found then
            l_loan_details.last_activity_date          := null;
        End;

        Begin

            -- get balance information
            open c_balanceInfo(p_loan_id, p_phase);
            fetch c_balanceInfo into
                l_billed_principal
                ,l_loan_details.unpaid_principal
                ,l_loan_details.UNPAID_INTEREST;
            close c_balanceInfo;

            l_loan_details.billed_principal := l_billed_principal;
            l_loan_details.unbilled_principal := l_loan_details.funded_amount - l_billed_principal;
        Exception
            when no_data_found then
        --	                   l_loan_details.reamortize_amount           := 0;
        --	                   l_loan_details.reamortize_from_installment := 0;
        --	                   l_loan_details.reamortize_to_installment   := 0;
    --	                   l_loan_details.last_activity_date          := null;
                l_loan_details.unpaid_principal            := 0;
                l_loan_details.billed_principal            := 0;
                l_loan_details.unbilled_principal          := l_loan_details.funded_amount;
                l_loan_details.UNPAID_INTEREST             := 0;
        End;

    else
        l_loan_details.reamortize_amount           := 0;
        l_loan_details.reamortize_from_installment := null;
        l_loan_details.reamortize_to_installment   := 0;
        l_loan_details.last_activity_date          := null;
        l_loan_details.unpaid_principal            := 0;
        l_loan_details.billed_principal            := 0;
        l_loan_details.unbilled_principal          := l_loan_details.funded_amount;
        l_loan_details.UNPAID_INTEREST             := 0;
    end if;

    --open c_last_interest_accrual(p_loan_id);
    --fetch c_last_interest_accrual into l_loan_details.last_interest_accrual;
    --close c_last_interest_accrual;
/*
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': getting number of intervals');
    -- get the number of installments on a loan
    -- this represents the number of payments on the loan
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting number of payment intervals');
    l_loan_details.number_installments := lns_fin_utils.intervalsInPeriod(l_loan_Details.loan_term
                                                                        ,l_loan_Details.loan_term_period
                                                                        ,l_loan_Details.payment_frequency);

    -- get the number of amortization intervals on a loan
    -- the number of amortization intervals is counted from the first payment date
    -- this number will be used in the amortization equation
    if l_loan_details.pay_in_arrears = 'Y' then
        l_loan_details.pay_in_arrears_boolean := true;
    else
        l_loan_details.pay_in_arrears_boolean := false;
    end if;
*/
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '<---------- BEGIN LOAN DETAILS ------------->');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortized_term: ' || l_loan_details.amortized_term);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortized_term_period:  ' || l_loan_details.amortized_term_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': amortization_frequency:  ' || l_loan_details.amortization_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': first_payment_date:  ' || l_loan_details.first_payment_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': loan_start_date: ' || l_loan_details.loan_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': funded_amount: ' || l_loan_details.funded_amount);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': remaining_balance: ' || l_loan_details.remaining_balance);
--    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': number_installments: ' || l_loan_details.number_installments);
--    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': num_amortization_intervals: ' || l_loan_details.num_amortization_intervals);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': reamortize_amount: ' || l_loan_details.reamortize_amount);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': reamortize_from_installment: ' || l_loan_details.reamortize_from_installment);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': day_count_method: ' || l_loan_details.day_count_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': last_installment_billed: ' || l_loan_details.last_installment_billed);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': PAYMENT_CALC_METHOD: ' || l_loan_details.PAYMENT_CALC_METHOD);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': CALCULATION_METHOD: ' || l_loan_details.CALCULATION_METHOD);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': INTEREST_COMPOUNDING_FREQ: ' || l_loan_details.INTEREST_COMPOUNDING_FREQ);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': prin_first_pay_date: ' || l_loan_details.prin_first_pay_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': prin_payment_frequency: ' || l_loan_details.prin_payment_frequency);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': unbilled_principal  ' || l_loan_details.unbilled_principal);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': unpaid_principal  ' || l_loan_details.unpaid_principal);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': UNPAID_INTEREST  ' || l_loan_details.UNPAID_INTEREST);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': extend_from_installment  ' || l_loan_Details.extend_from_installment);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': ORIG_PAY_CALC_METHOD  ' || l_loan_Details.ORIG_PAY_CALC_METHOD);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '<---------- END LOAN DETAILS --------------->');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_loan_details;

Exception
    When No_Data_Found then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - LOAN ID: ' || l_loan_id || ' not found');
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_LOAN_ID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    When Others then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'Err: ' || sqlerrm);
        RAISE FND_API.G_EXC_ERROR;

end getLoanDetails;


/*=========================================================================
|| PUBLIC PROCEDURE shiftLoan
||
|| DESCRIPTION
||
|| Overview: will shift a loans OPEN phase  and/or TERM phase
||           where appropriate
||          1. determine if any disbursements are past the open maturity date
||          2. if so, get the next available maturity date,
||             -- this should increment by amortization frequency
||          3. update the term/term period - in terms of payment frequency,
||             -- the term will change to X MONTHS if TERM was > MONTHS
||
|| Parameter: p_loan_id  = loan_id
||
|| Source Tables:  LNS_LOAN_HEADERS_ALL, LNS_DISB_HEADERS
||                 LNS_TERMS
||
|| Target Tables: LNS_LOAN_HEADERS_ALL, LNS_TERMS
||
|| Return value:  Standard Oracle API
||
|| MODIFICATION HISTORY
|| Date                    Author           Description of Changes
|| 02/14/2005 11:35AM     raverma           Created
 *=======================================================================*/
procedure shiftLoan(p_loan_id        in number
                   ,p_init_msg_list  IN VARCHAR2
                   ,p_commit         IN VARCHAR2
                   ,x_return_status  OUT NOCOPY VARCHAR2
                   ,x_msg_count      OUT NOCOPY NUMBER
                   ,x_msg_data       OUT NOCOPY VARCHAR2)

is

    l_api_name              varchar2(25);
    l_move_maturity_date    number;
    i                       number;
    l_old_maturity_date     date;
    l_new_maturity_date     date;
    l_max_pay_request_date  date;
    l_payment_frequency     varchar2(30);
    l_new_frequency         varchar2(30);
    l_custom_payments_flag  varchar2(1);
    l_current_phase         varchar2(30);
    l_term                  number;
    l_term_period           varchar2(30);
    l_temp                  varchar2(30);
    l_term_phase_exists     varchar2(1);
    l_term_id               number;
    l_initial_months        number;

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_loan_details          LOAN_DETAILS_REC;
    l_loan_header_rec       LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_term_rec              LNS_TERMS_PUB.loan_term_rec_type;
    l_version_number        number;
    l_terms_version_number  number;
    l_dates_shifted_flag    varchar2(1) := 'N';


    CURSOR move_maturity_date_cur(P_LOAN_ID number) IS
    select
      CASE
    WHEN (nvl(loan.CURRENT_PHASE, 'TERM') = 'OPEN') THEN
          sign(trunc(loan.OPEN_MATURITY_DATE) - (select trunc(max(PAYMENT_REQUEST_DATE)) from LNS_DISB_HEADERS where LOAN_ID = loan.LOAN_ID))
    WHEN (nvl(loan.CURRENT_PHASE, 'TERM') = 'TERM' and loan.MULTIPLE_FUNDING_FLAG = 'N') THEN
         sign(trunc(loan.LOAN_MATURITY_DATE) - (select trunc(max(PAYMENT_REQUEST_DATE)) from LNS_DISB_HEADERS where LOAN_ID = loan.LOAN_ID))
    ELSE
    1
    END
    from lns_loan_headers loan
    where loan.LOAN_ID = p_loan_id;


    cursor c_loan_info (p_loan_id number) is
    select  t.open_payment_frequency
           ,decode(h.current_phase, 'OPEN', h.open_maturity_date, h.loan_maturity_date)
           ,nvl(h.custom_payments_flag, 'N')
           ,h.open_to_term_flag
           ,decode(h.current_phase, 'OPEN', h.open_loan_term, h.loan_term)
           ,decode(h.current_phase, 'OPEN', h.open_loan_term_period, h.loan_term_period)
           ,h.OBJECT_VERSION_NUMBER
           ,t.object_VERSION_NUMBER
           ,t.term_id
           ,h.current_phase
      from  lns_terms  t
           ,lns_loan_headers  h
     where h.loan_id = p_loan_id
       and h.loan_id = t.loan_id;

    cursor c_max_pay_req_date(p_loan_id number) is
    select max(payment_request_date)
      from lns_disb_headers
      where loan_id = p_loan_id;

begin
    -- Standard Start of API savepoint
    SAVEPOINT shiftLoan;
    l_api_name           := 'shiftLoan';
    i := 0;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id ' || p_loan_id);

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    -- -----------------------------------------------------------------
    open move_maturity_date_cur(P_LOAN_ID);
    fetch move_maturity_date_cur into l_move_maturity_date;
    close move_maturity_date_cur;

    if l_move_maturity_date = -1 then

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - we need to move the loan');

      -- get the final payment request date
      open c_max_pay_req_date(p_loan_id);
      fetch c_max_pay_req_date into l_max_pay_request_date;
      close c_max_pay_req_date;
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_max_pay_request_date' || l_max_pay_request_date);

      -- get loan info
      open c_loan_info(p_loan_id);
      fetch c_loan_info into
          l_payment_frequency
         ,l_old_maturity_date
         ,l_custom_payments_flag
         ,l_term_phase_exists
         ,l_term
         ,l_term_period
         ,l_version_number
         ,l_terms_version_number
         ,l_term_id
         ,l_current_phase;
      close c_loan_info;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_payment_frequency ' || l_payment_frequency);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_old_maturity_date ' || l_old_maturity_date );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_custom_payments_flag ' || l_custom_payments_flag);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_term_phase_exists ' || l_term_phase_exists );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_term ' || l_term);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_term_period ' || l_term_period );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_version_number ' || l_version_number );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_terms_version_number ' || l_terms_version_number );
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_term_id ' || l_term_id );

      if l_custom_payments_flag <> 'Y' then
          -- we will be converting the term of the loan if frequency > MONTHLY
          if l_payment_frequency <> 'SEMI-MONTHLY' AND l_payment_frequency <> 'WEEKLY' AND l_payment_frequency <> 'BIWEEKLY' then
             l_new_frequency := 'MONTHS';
             l_initial_months := lns_fin_utils.convertPeriod(p_term         => l_term
                                                            ,p_term_period  => l_term_period);
          else
             --weeks or semi-months
             if substr(l_payment_frequency, length(l_payment_frequency) - 1, 2) = 'LY' then
                 l_temp := substr(l_payment_frequency, 1, length(l_payment_frequency) - 2) || 'S';
             else
                 l_temp := l_payment_frequency;
             end if;
             l_new_frequency := l_temp;
             l_initial_months := l_term;
          end if;
          l_new_maturity_Date := l_old_maturity_date;

          loop
            -- i will be the number of "TERMS" to add the LNS_LOAN_HEADERS.TERM
            i := i + 1;
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - i ' || l_new_maturity_date);
            l_new_maturity_date := lns_fin_utils.getNextDate(p_date          => l_new_maturity_date
                                                            ,p_interval_type => l_new_frequency
                                                            ,p_direction     => 1);
            exit when l_new_maturity_date >= l_max_pay_request_date;
          end loop;

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - NEW MATURITY DATE' || l_new_maturity_date );

          --now we move the loan dates
          if (l_current_phase = 'OPEN' and l_term_phase_exists = 'Y') then
             logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting new term dates');

	     -- Bug#6169438, Added new parameter l_dates_shifted_flag
             shiftLoanDates(p_loan_id        => p_loan_id
                           ,p_new_start_date => l_new_maturity_date
                           ,p_phase          => 'TERM'
                           ,x_loan_details   => l_loan_details
                           ,x_dates_shifted_flag => l_dates_shifted_flag
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data);
             logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' new TERM start date is ' || l_loan_details.loan_start_date);
             logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' new TERM first payment date is ' || l_loan_details.first_payment_Date);
             logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' new TERM principal first payment date is ' || l_loan_details.PRIN_FIRST_PAY_DATE);
             logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' new TERM maturity date is ' || l_loan_details.maturity_date);

             -- items to update for term phase
             l_term_rec.term_id                   := l_term_id;
             l_term_rec.FIRST_PAYMENT_DATE        := l_loan_details.first_payment_Date;
             l_term_rec.PRIN_FIRST_PAY_DATE       := l_loan_details.PRIN_FIRST_PAY_DATE;
             l_term_rec.NEXT_PAYMENT_DUE_DATE     := l_loan_details.first_payment_Date;
             l_loan_header_rec.loan_maturity_date := l_loan_details.maturity_date;
             l_loan_header_rec.loan_start_date    := l_loan_details.loan_start_date;
             lns_terms_pub.update_term(p_object_version_number => l_terms_version_number
                                      ,p_init_msg_list         => fnd_api.g_false
                                      ,p_loan_term_rec         => l_term_rec
                                      ,x_return_status         => l_return_status
                                      ,x_msg_count             => l_msg_count
                                      ,x_msg_data              => l_msg_data);
          end if;

          if l_current_phase = 'OPEN' then
              -- update items for loan header table
              l_loan_header_rec.loan_id               := p_loan_id;
              l_loan_header_rec.open_maturity_date    := l_new_maturity_date;
              l_loan_header_rec.open_loan_term        := l_initial_months + i;
              l_loan_header_rec.open_loan_term_period := l_new_frequency;

              lns_loan_header_pub.update_loan(p_object_version_number => l_version_number
                                             ,p_loan_header_rec       => l_loan_header_rec
                                             ,p_init_msg_list         => fnd_api.g_false
                                             ,x_return_status         => l_return_status
                                             ,x_msg_count             => l_msg_count
                                             ,x_msg_data              => l_msg_data);
          elsif l_current_phase = 'TERM' then

              l_loan_header_rec.loan_id               := p_loan_id;
              l_loan_header_rec.loan_maturity_date    := l_new_maturity_date;
              l_loan_header_rec.loan_term             := l_initial_months + i;
              l_loan_header_rec.loan_term_period      := l_new_frequency;

              lns_loan_header_pub.update_loan(p_object_version_number => l_version_number
                                             ,p_loan_header_rec       => l_loan_header_rec
                                             ,p_init_msg_list         => fnd_api.g_false
                                             ,x_return_status         => l_return_status
                                             ,x_msg_count             => l_msg_count
                                             ,x_msg_data              => l_msg_data);

          end if; -- open phase
      end if; -- custom payments

    else
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - NOTHING TO MOVE');
    end if;

    --
    -- End of API body
    --  ----------------------------------------------------------------
    --
    -- Standard check for p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO shiftLoan;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO shiftLoan;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO shiftLoan;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end shiftLoan;

/*=========================================================================
|| PUBLIC PROCEDURE shiftLoanDates
||
|| DESCRIPTION
||
|| Overview: procedure will return a new loan details record with
||           shifted dates
||
|| Parameter: p_loan_id  = loan_id
||            p_new_start_Date = new start date of loan
||
|| Source Tables:  NA
||
|| Target Tables:
||
|| Return value: x_loan_Details
||               detail record of the loan with the new dates
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 11/29/2004 11:35AM     raverma           Created
|| 7/29/2005             raverma            added p_phase
|| 14-JUL-2007		 mbolli		    Bug#6169438 - Added new OUT parameter x_dates_shifted_flag
 *====================================================================================================*/
procedure shiftLoanDates(p_loan_id        in number
                        ,p_new_start_date in date
						,p_phase          in varchar2
                        ,x_loan_details   out NOCOPY lns_financials.loan_details_rec
                        ,x_dates_shifted_flag OUT NOCOPY VARCHAR2
                        ,x_return_status  OUT NOCOPY VARCHAR2
                        ,x_msg_count      OUT NOCOPY NUMBER
                        ,x_msg_data       OUT NOCOPY VARCHAR2)
is
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(32767);
    l_api_name               varchar2(25);
    l_loan_details           lns_financials.loan_Details_rec;
    l_day_difference         number;
    l_new_maturity_date      date;
    l_new_first_payment_date date;
    x                        number;
    l_new_int_first_pay_date date;
    l_new_prin_first_pay_date date;
    l_shift_dates_proc       varchar2(100);
    l_plsql_block            varchar2(200);

begin

    -- Standard Start of API savepoint
    SAVEPOINT shiftLoanDates;
    l_api_name           := 'shiftLoanDates';
    x := 0;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_new_start_date = ' || p_new_start_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase = ' || p_phase);

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_dates_shifted_flag := 'N';

    --
    -- Api body
    -- ----------------------------------------------------------------
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

    l_loan_details := lns_financials.getLoanDetails(p_loan_id        => p_loan_id
                                                   ,p_based_on_terms => 'ORIGINAL'
												   ,p_phase          => p_phase);

    if l_loan_Details.loan_start_date = p_new_start_date then
        x_loan_details := l_loan_details;
        return;
    end if;

    -- get the new maturity date
    l_new_maturity_date := LNS_FIN_UTILS.getMaturityDate(p_term         => l_loan_Details.loan_term
                                                        ,p_term_period  => l_loan_Details.loan_term_period
                                                        ,p_frequency    => l_loan_Details.amortization_frequency
                                                        ,p_start_date   => p_new_start_date);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_new_maturity_date ' || l_new_maturity_date);

    -- fix for FP bug 6938095: get package.procedure from LNS_SHIFT_PAY_DATES_PROC profile and call it dynamically
    l_shift_dates_proc := NVL(FND_PROFILE.VALUE('LNS_SHIFT_PAY_DATES_PROC'), 'LNS_DEFAULT_HOOKS_PVT.SHIFT_PAY_START_DATES');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_shift_dates_proc: ' || l_shift_dates_proc);

    l_plsql_block := 'BEGIN ' || l_shift_dates_proc || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10); END;';

    BEGIN

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Calling...');

        EXECUTE IMMEDIATE l_plsql_block
        USING
            IN p_loan_id,
            IN p_new_start_date,
            IN l_loan_details.loan_start_Date,
            IN l_loan_details.first_payment_Date,
            IN l_loan_details.PRIN_FIRST_PAY_DATE,
            IN l_loan_Details.maturity_Date,
            IN p_new_start_date,
            IN OUT l_new_maturity_date,
            OUT l_new_int_first_pay_date,
            OUT l_new_prin_first_pay_date;

        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Done');

    EXCEPTION
        WHEN OTHERS THEN
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'ERROR: ' || sqlerrm);
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_new_int_first_pay_date: ' || l_new_int_first_pay_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_new_prin_first_pay_date: ' || l_new_prin_first_pay_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_new_maturity_date: ' || l_new_maturity_date);

    if l_new_int_first_pay_date is null or l_new_int_first_pay_date < p_new_start_date then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_PAYMENT_START_DATE_ERROR2');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if l_new_int_first_pay_date > l_new_maturity_date then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_PAYMENT_START_DATE_ERROR1');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if l_loan_details.PRIN_FIRST_PAY_DATE is not null then
        if l_new_prin_first_pay_date is null or l_new_prin_first_pay_date < p_new_start_date then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_PRIN_PAY_START_DATE_ERROR2');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        if l_new_prin_first_pay_date > l_new_maturity_date then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_PRIN_PAY_START_DATE_ERROR1');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    -- assign the new dates to the loan details record
    l_loan_Details.loan_start_date    := p_new_start_date;
    l_loan_details.first_payment_Date := l_new_int_first_pay_date;
    l_loan_details.PRIN_FIRST_PAY_DATE := l_new_prin_first_pay_date;
    l_loan_Details.maturity_Date      := l_new_maturity_Date;

    x_loan_details := l_loan_details;
    x_dates_shifted_flag := 'Y';

    --
    -- End of API body
    --
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO shiftLoanDates;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO shiftLoanDates;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO shiftLoanDates;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              x_return_status := FND_API.G_RET_STS_ERROR;
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
end shiftLoanDates;


/*=========================================================================
|| PUBLIC PROCEDURE calculateEPPayment
||
|| DESCRIPTION
||
|| Overview:  returns a termly equal principal payment amount for a loan
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter:  p_loan_amount     => amount of loan
||             p_num_intervals   => number of installments for loan
||             p_ending_balance  => future or residual value of the loan  (most loans will pass 0)
||             p_pay_in_arrears  => true if payments are at end of period
||                                  false otherwise
||
|| payment = (p_loan_amount - p_ending_balance) / p_num_intervals;
||
|| Return value:  principal amount to pay per installment
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 09/13/2007            scherkas          Created
 *=======================================================================*/
function calculateEPPayment(p_loan_amount     in number
                         ,p_num_intervals   in number
                         ,p_ending_balance  in number
                         ,p_pay_in_arrears  in boolean) return number

is
  l_periodic_amount   number;
  l_api_name          varchar2(25);

begin

     l_api_name := 'calculateEPPayment';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': loan amount is ' || p_loan_amount);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': ending balance is ' || p_ending_balance);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': number of intervals is ' || p_num_intervals);

     l_periodic_amount := (p_loan_amount - p_ending_balance) / p_num_intervals;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': periodic_prin_amount: ' || l_periodic_amount);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

     return l_periodic_amount;

Exception
    When others then
        null;

end calculateEPPayment;



/*=========================================================================
|| PUBLIC PROCEDURE calculatePayment
||
|| DESCRIPTION
||
|| Overview:  returns a termly payment amount for a loan
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter:  p_annualized_rate => annual rate of the loan
||             p_loan_amount     => amount of loan
||             p_num_intervals   => number of installments for loan
||             p_ending_balance  => future or residual value of the loan  (most loans will pass 0)
||             p_pay_in_arrears  => true if payments are at end of period
||                                  false otherwise
||
|| payment =
|| loan_amount x  periodic_rate /
||  (1 - (1 / (1 + periodic_rate)^p_num_intervals  )) -
||   p_ending_balance x periodic_rate /
|| ((1 + periodic_rate)^p_num_intervals  -1)
||
|| Return value:  amount to pay per installment
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/11/2003 12:40PM     raverma           Created
||  7/22/2003             raverma           enable pay in arrears = false
 *=======================================================================*/
function calculatePayment(p_loan_amount     in number
                         ,p_periodic_rate   in number
                         ,p_num_intervals   in number
                         ,p_ending_balance  in number
                         ,p_pay_in_arrears  in boolean) return number

is
  l_periodic_amount   number;
  l_numerator         number;
  l_denominator       number;
  l_api_name          varchar2(25);
  l_num_intervals     number;

begin

     l_api_name := 'calculatePayment';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

     if p_pay_in_arrears then
         logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' pay in arrears');
     else
         logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' pay in advance');
     end if;
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': number of intervals is ' || p_num_intervals);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': periodic rate is ' || p_periodic_rate);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': ending balance is ' || p_ending_balance);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ': loan amount is ' || p_loan_amount);

     l_num_intervals := p_num_intervals;
     if l_num_intervals = 0 then
        l_num_intervals := 1;
     end if;
     -- check for 0 percent interest
     -- this is the pay in arrears formula

     if p_ending_balance = 0 then

        if p_pay_in_arrears then
            if p_periodic_rate <> 0 then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 1');
                l_numerator := p_periodic_rate * Power ((1 + p_periodic_rate), l_num_intervals) * p_loan_amount;
                l_denominator :=  Power ((1 + p_periodic_rate), l_num_intervals) - 1;
            else
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 2');
                l_numerator := Power (1, l_num_intervals) * p_loan_amount;
                l_denominator := l_num_intervals;
            end if;
        else
            if p_periodic_rate <> 0 then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 3');
                l_numerator := p_periodic_rate * Power ((1 + p_periodic_rate), l_num_intervals - 1) * p_loan_amount;
                l_denominator :=  Power ((1 + p_periodic_rate), l_num_intervals) - 1;
            else
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 4');
                l_numerator := Power (1, l_num_intervals - 1) * p_loan_amount;
                l_denominator := l_num_intervals;
            end if;

        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': numerator:' || l_numerator);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': denominator:' || l_denominator);

        l_periodic_amount := l_numerator / l_denominator;

     else -- for case of balloon payment

        if p_pay_in_arrears then
            if p_periodic_rate <> 0 then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 5');
                l_periodic_amount := ( (p_periodic_rate * Power ((1 + p_periodic_rate), l_num_intervals) * p_loan_amount) / (Power ((1 + p_periodic_rate), l_num_intervals) - 1) ) +
                                    ( (p_periodic_rate * p_ending_balance) / ((1 + p_periodic_rate) - Power ((1 + p_periodic_rate), l_num_intervals + 1)) );

            else
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 6');
                l_periodic_amount := ( (Power ((1 + p_periodic_rate), l_num_intervals) * p_loan_amount) / l_num_intervals ) -
                                    ( p_ending_balance / l_num_intervals );
            end if;

        else
            if p_periodic_rate <> 0 then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 7');
                l_periodic_amount := ( (p_periodic_rate * Power ((1 + p_periodic_rate), l_num_intervals - 1) * p_loan_amount) / (Power ((1 + p_periodic_rate), l_num_intervals) - 1) ) +
                                    ( (p_periodic_rate * p_ending_balance) / ((1 + p_periodic_rate) - Power ((1 + p_periodic_rate), l_num_intervals + 1)) );
            else
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': if 8');
                l_periodic_amount := ( (Power ((1 + p_periodic_rate), l_num_intervals - 1) * p_loan_amount) / l_num_intervals ) -
                                    ( p_ending_balance / l_num_intervals );
            end if;

        end if;

     end if;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': periodic_amount: ' || l_periodic_amount);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

     return l_periodic_amount;

Exception
    When others then
        null;

end calculatePayment;

/*=========================================================================
|| PUBLIC PROCEDURE calculateInterest
||
|| DESCRIPTION
||
|| Overview:  returns an interest due on a loan
||            we will use the formula:
||                    FV = P*r^n
||            where FV = future value at a given point in time
||                  PV = Present value of loan / capital
||                  r = rate annualized
||                  n = period of payment
||            to compound interest continually we use the formula:
||                    FV   =   Pe^(Yr)
||            where Y = years and
||                  e = 2.71828....
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Parameter: p_amount = amount of loan
||            p_annual_rate = interest rate for loan expressed as a whole number
||            p_start_date = date at which interest is calculated
||            p_end_date = date at which interest in ended
||            p_compounding_period = for future use
||
|| Return value: amount interest due
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/08/2003 10:56AM     raverma           Created
|| 03/17/2004             raverma           don't allow negative interest for now
 *=======================================================================*/
function calculateInterest(p_amount             in  number
                          ,p_periodic_rate      in number
                          ,p_compounding_period in varchar2)  return number
is
   l_periodic_rate number;
   l_amount        number;
   l_api_name      varchar2(25);

begin

   l_api_name  := 'calculateInterest';
    -- logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    if p_amount > 0  then
       l_amount := p_amount;
    else
       l_amount := 0;
    end if;

    --    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_amount * p_periodic_rate;

end calculateInterest;

/*=========================================================================
|| PUBLIC FUNCTION validatePayoff
||
|| DESCRIPTION
||      contains validation rules on dates and statuses for a payoff
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Return value:
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10/26/2004 12:55PM       raverma           Created
 *=======================================================================*/
procedure validatePayoff(p_loan_details   in LNS_FINANCIALS.LOAN_DETAILS_REC
                        ,p_payoff_date    in date
                        ,x_return_status  OUT NOCOPY VARCHAR2
                        ,x_msg_count      OUT NOCOPY NUMBER
                        ,x_msg_data       OUT NOCOPY VARCHAR2)

is
     l_api_name            varchar2(25);
     l_api_version_number  number;
     l_return_status       VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(32767);

begin

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_api_name      := 'validatePayoff';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    --
    -- Api body
    -- --------------------------------------------------------------------


    -- these dates should be further restricted
    if p_loan_details.loan_status = 'PAIDOFF' then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYOFF_ALREADY');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    --karamach --Bug5295446 --Need to prevent payoff for loans in Approved status as well
    --elsif p_loan_details.loan_status = 'INCOMPLETE' or p_loan_details.loan_status = 'DELETED' or
     --     p_loan_details.loan_status = 'REJECTED' or p_loan_details.loan_status = 'PENDING' then
    elsif p_loan_details.loan_status IN ('INCOMPLETE','DELETED','REJECTED','PENDING','APPROVED') then
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVOICE_SUMMARY_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_payoff_date < p_loan_details.last_interest_accrual  then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - payoff too early');
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYOFF_TOO_EARLY');
        FND_MESSAGE.SET_TOKEN('PAYOFF_DATE', fnd_date.date_to_displaydate(p_loan_details.last_interest_accrual));
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if p_payoff_date < p_loan_details.last_activity_date then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - payoff too early');
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYOFF_TOO_EARLY2');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'LAST_ACTIVITY_DATE');
        FND_MESSAGE.SET_TOKEN('VALUE', fnd_date.date_to_displaydate(p_loan_details.last_activity_date));
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    /* raverma added 12-08-05 */
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calling LNS_FUNDING_PUB.validate_disb_for_payoff returns ');
    LNS_FUNDING_PUB.VALIDATE_DISB_FOR_PAYOFF(P_API_VERSION      => 1.0
                                            ,P_INIT_MSG_LIST    => FND_API.G_FALSE
                                            ,P_COMMIT           => FND_API.G_FALSE
                                            ,P_VALIDATION_LEVEL => 100
                                            ,P_LOAN_ID          => p_loan_details.loan_id
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);
    if l_return_Status <> FND_API.G_RET_STS_SUCCESS then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - validate_disb_for_payoff returns ' || l_return_Status);
        RAISE FND_API.G_EXC_ERROR;
    end if;

    x_return_status := l_return_Status;
    -- --------------------------------------------------------------------
    -- End of API body
    --

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

  exception

        WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end validatePayoff;

/*=========================================================================
|| PUBLIC FUNCTION calculatePayoff
||
|| DESCRIPTION
||      calculate any additional interest due on loan, etc fees, to
||      pay off
||
|| PSEUDO CODE/LOGIC
||     1. get number of interest rates running over remaining period
||     2. get weighted average of those rates
||     3. calculate interest due on remaining principal
||         from payoff_date
||
|| PARAMETERS
||    p_loan_id     => loan_id to payoff
||    p_payoff_date => date at which to payoff the loan
||
|| Return value:
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 03/24/2004 12:55PM       raverma           Created
|| 04/15/2004               raverma           check to see if loan is PAIDOFF
 *=======================================================================*/
procedure calculatePayoff(p_api_version    IN NUMBER
                         ,p_init_msg_list  IN VARCHAR2
                         ,p_loan_id        in number
                         ,p_payoff_date    in date
                         ,x_payoff_tbl     OUT NOCOPY LNS_FINANCIALS.PAYOFF_TBL2
                         ,x_return_status  OUT NOCOPY VARCHAR2
                         ,x_msg_count      OUT NOCOPY NUMBER
                         ,x_msg_data       OUT NOCOPY VARCHAR2)
IS

     l_api_name            varchar2(25);
     l_api_version_number  number;
     l_return_status       VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(32767);

     l_loan_details        LNS_FINANCIALS.LOAN_DETAILS_REC;
     l_rate_tbl            LNS_FINANCIALS.RATE_SCHEDULE_TBL;
     l_annualized_rate     number;
     l_periodic_rate       number;
     l_additional_interest number;
     l_additional_fees     number;
     l_payoff_tbl          LNS_FINANCIALS.PAYOFF_TBL2;
     l_principal_unpaid    number;
     l_interest_unpaid     number;
     l_fees_unpaid         number;
     l_payoff_date         date;
     l_from_date           date;
     l_to_date             date;
     l_multipler           number;
     l_balance             number;
     l_current_phase       varchar2(30);
     l_rate_type           varchar2(30);
     l_index_rate_id       number;
     l_rate_for_date       number;
     l_norm_interest         number;
     l_add_prin_interest     number;
     l_add_int_interest      number;
     l_penal_prin_interest   number;
     l_penal_int_interest    number;
     l_penal_interest        number;
     l_add_start_date        date;
     l_add_end_date          date;

     l_norm_int_detail_str            varchar2(2000);
     l_add_prin_int_detail_str        varchar2(2000);
     l_add_int_int_detail_str         varchar2(2000);
     l_penal_prin_int_detail_str      varchar2(2000);
     l_penal_int_int_detail_str       varchar2(2000);
     l_penal_int_detail_str           varchar2(2000);

     cursor c_additional_fees(p_loan_id number, p_phase varchar2) is
     select nvl(sum(fee_amount), 0)
       from lns_fee_schedules
      where loan_id = p_loan_id
        and billed_flag = 'N'
        and active_flag = 'Y'
        and phase = p_phase;

     cursor c_loan_info(p_loan_id number) is
     select nvl(h.current_phase, 'TERM')
           ,t.rate_type
           ,t.index_rate_id
      from lns_loan_headers h
          ,lns_terms        t
      where h.loan_id = p_loan_id
        and t.loan_id = h.loan_id;

    cursor c_get_last_bill_date(p_loan_id number, p_installment_number number)  is
        select ACTIVITY_DATE
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id
        and PAYMENT_NUMBER = p_installment_number
        and PARENT_AMORTIZATION_ID is null
        and ACTIVITY_CODE in ('BILLING', 'START');

begin

    l_api_name            := 'calculatePayoff';
    l_api_version_number  := 1;
    l_additional_interest := 0;
    l_additional_fees     := 0;
    l_principal_unpaid    := 0;
    l_interest_unpaid     := 0;
    l_fees_unpaid         := 0;
    l_balance             := 0;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_payoff_date ' || p_payoff_date);

    -- Standard Start of API savepoint
    SAVEPOINT calculatePayoff;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number, p_api_version,
                                        l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Api body
    -- --------------------------------------------------------------------

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting current phase');
    open c_loan_info(p_loan_id);
    fetch c_loan_info into l_current_phase, l_rate_type, l_index_rate_id;
    close c_loan_info;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - current phase ' || l_current_phase);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_rate_type ' || l_rate_type);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_index_rate_id ' || l_index_rate_id);

    -- bug #4865575
    if l_rate_type = 'VARIABLE' then

      l_rate_for_date := lns_fin_utils.getRateForDate(p_index_rate_id   => l_index_rate_id
                                                     ,p_rate_date       => p_payoff_date);

      if l_rate_for_date is null then
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || FND_MSG_PUB.Get(p_encoded => 'F'));
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_PAYOFF_DATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      end if;

    end if;

    l_loan_details  := lns_financials.getLoanDetails(p_loan_id        => p_loan_id
                                                    ,p_based_on_terms => 'CURRENT'
                                                    ,p_phase          => l_current_phase);
    l_rate_tbl      := lns_financials.getRateSchedule(p_loan_id, l_current_phase);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - got loan details and rate info');

    lns_financials.validatePayoff(p_loan_details   => l_loan_details
                                 ,p_payoff_date    => p_payoff_date
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, l_api_name || FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - processing late fees');
    lns_fee_engine.processLateFees(p_loan_id       => p_loan_id
                                  ,p_init_msg_list => p_init_msg_list
                                  ,p_commit        => 'F'
                                  ,p_phase         => l_loan_details.LOAN_PHASE
                                  ,x_return_status => l_return_status
                                  ,x_msg_count     => l_msg_count
                                  ,x_msg_data      => l_msg_data);

    if p_payoff_date < l_loan_details.last_interest_accrual  then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - payoff prior to last interest accrual');
        -- we will have a interest credit
        l_from_date   := p_payoff_date;
        l_to_date     := l_loan_details.last_interest_accrual;
        l_multipler   := -1;
/*
        l_balance := lns_financials.getAverageDailyBalance(p_loan_id     => p_loan_id
                                                          ,p_term_id     => null
                                                          ,p_from_date   => p_payoff_date
                                                          ,p_to_date     => l_loan_details.last_interest_accrual
                                                          ,p_calc_method => null);
*/
    else
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - payoff after lastinterest accrual');
        l_from_date   := l_loan_details.last_interest_accrual;
        l_to_date     := p_payoff_date;
        l_multipler   := 1;
--        l_balance     := l_loan_details.remaining_balance;
    end if;
--    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - computed principal balance: ' || l_balance);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - from date: ' || l_from_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - to date: ' || l_to_date);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_muliplier: ' || l_multipler);

    BEGIN
        -- changes as per scherkas 11-16-2005
        select
              nvl(sum(SCHED.PRINCIPAL_REMAINING),0)
             ,nvl(sum(SCHED.INTEREST_REMAINING),0)
             ,nvl(sum(SCHED.FEE_REMAINING),0)
        into  l_principal_unpaid
             ,l_interest_unpaid
             ,l_fees_unpaid
        from LNS_AM_SCHEDS_V SCHED
              ,LNS_LOAN_HEADERS H
        where H.loan_id = p_loan_id and
              H.loan_id = Sched.loan_id and
              SCHED.reversed_code = 'N' and
              nvl(sched.phase, 'TERM') = nvl(h.current_phase, 'TERM');
    Exception
        when no_data_found then
            null;
    END;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_principal_unpaid: ' || l_principal_unpaid);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_interest_unpaid: ' || l_interest_unpaid);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_fees_unpaid: ' || l_fees_unpaid);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - status: ' || l_loan_details.loan_status);

    -- get the wtd rate if necessary
    if l_rate_tbl.count = 1 then
        l_annualized_rate := l_rate_tbl(1).annual_rate;
    else
        l_annualized_rate := lns_financials.getWeightedRate(p_loan_details => l_loan_details
                                                        ,p_start_date   => l_from_date
                                                        ,p_end_date     => l_to_date
                                                        ,p_rate_tbl     => l_rate_tbl);
    end if;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_annualized_rate: ' || l_annualized_rate);

    l_norm_interest := 0;
    l_add_prin_interest := 0;
    l_add_int_interest := 0;
    l_penal_prin_interest := 0;
    l_penal_int_interest := 0;
    l_penal_interest := 0;
    l_norm_int_detail_str := null;
    l_add_prin_int_detail_str := null;
    l_add_int_int_detail_str := null;
    l_penal_prin_int_detail_str := null;
    l_penal_int_int_detail_str := null;
    l_penal_int_detail_str := null;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating normal interest...');
    LNS_FINANCIALS.CALC_NORM_INTEREST(p_loan_id => p_loan_id,
                        p_calc_method => l_loan_details.CALCULATION_METHOD,
                        p_period_start_date => l_from_date,
                        p_period_end_date => l_to_date,
                        p_interest_rate => l_annualized_rate,
                        p_day_count_method => l_loan_details.day_count_method,
                        p_payment_freq => l_loan_details.PAYMENT_FREQUENCY,
                        p_compound_freq => l_loan_details.INTEREST_COMPOUNDING_FREQ,
                        p_adj_amount => 0,
                        x_norm_interest => l_norm_interest,
                        x_norm_int_details => l_norm_int_detail_str);

    l_norm_interest  := round(l_norm_interest, l_loan_details.currency_precision);

    -- get additional interest start date
    open c_get_last_bill_date(p_loan_id, l_loan_details.last_installment_billed);
    fetch c_get_last_bill_date into l_add_start_date;
    close c_get_last_bill_date;

    -- get additional interest end date
    if trunc(l_add_start_date) > trunc(l_from_date) then
        l_add_start_date := l_from_date;
    end if;
    l_add_end_date := l_to_date;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid principal...');
    -- calculate additional interest on unpaid principal
    LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => p_loan_id,
                        p_calc_method => l_loan_details.CALCULATION_METHOD,
                        p_period_start_date => l_add_start_date,
                        p_period_end_date => l_add_end_date,
                        p_interest_rate => l_annualized_rate,
                        p_day_count_method => l_loan_details.day_count_method,
                        p_payment_freq => l_loan_details.PAYMENT_FREQUENCY,
                        p_compound_freq => l_loan_details.INTEREST_COMPOUNDING_FREQ,
                        p_penal_int_rate => l_loan_details.PENAL_INT_RATE,
                        p_prev_grace_end_date => l_from_date,
                        p_grace_start_date => l_from_date,
                        p_grace_end_date => (l_from_date + l_loan_details.PENAL_INT_GRACE_DAYS),
                        p_target => 'UNPAID_PRIN',
                        x_add_interest => l_add_prin_interest,
                        x_penal_interest => l_penal_prin_interest,
                        x_add_int_details => l_add_prin_int_detail_str,
                        x_penal_int_details => l_penal_prin_int_detail_str);
    l_add_prin_interest  := round(l_add_prin_interest, l_loan_details.currency_precision);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculating additional interest on unpaid interest...');
    -- calculate additional interest on unpaid interest

    LNS_FINANCIALS.CALC_ADD_INTEREST(p_loan_id => p_loan_id,
                        p_calc_method => l_loan_details.CALCULATION_METHOD,
                        p_period_start_date => l_add_start_date,
                        p_period_end_date => l_add_end_date,
                        p_interest_rate => l_annualized_rate,
                        p_day_count_method => l_loan_details.day_count_method,
                        p_payment_freq => l_loan_details.PAYMENT_FREQUENCY,
                        p_compound_freq => l_loan_details.INTEREST_COMPOUNDING_FREQ,
                        p_penal_int_rate => l_loan_details.PENAL_INT_RATE,
                        p_prev_grace_end_date => l_from_date,
                        p_grace_start_date => l_from_date,
                        p_grace_end_date => (l_from_date + l_loan_details.PENAL_INT_GRACE_DAYS),
                        p_target => 'UNPAID_INT',
                        x_add_interest => l_add_int_interest,
                        x_penal_interest => l_penal_int_interest,
                        x_add_int_details => l_add_int_int_detail_str,
                        x_penal_int_details => l_penal_int_int_detail_str);
    l_add_int_interest  := round(l_add_int_interest, l_loan_details.currency_precision);

    l_penal_interest := round(l_penal_prin_interest + l_penal_int_interest, l_loan_details.currency_precision);
    l_additional_interest := (l_norm_interest + l_add_prin_interest + l_add_int_interest + l_penal_interest) * l_multipler;
    if l_penal_prin_int_detail_str is not null and l_penal_int_int_detail_str is not null then
        l_penal_int_detail_str := l_penal_prin_int_detail_str || ' +<br>' || l_penal_int_int_detail_str;
    else
        l_penal_int_detail_str := l_penal_prin_int_detail_str || l_penal_int_int_detail_str;
    end if;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_additional_interest: ' || l_additional_interest);

       begin
        open c_additional_fees(p_loan_id, l_current_phase);
        fetch c_additional_fees into l_additional_fees;
        close c_additional_fees;
       exception when no_data_found then
         null;
       end;

    l_payoff_tbl(1).PAYOFF_PURPOSE  := 'PRIN';
    l_payoff_tbl(1).BILLED_AMOUNT   := l_principal_unpaid;
    l_payoff_tbl(1).UNBILLED_AMOUNT := l_loan_details.remaining_balance - l_principal_unpaid;
    l_payoff_tbl(1).TOTAL_AMOUNT    := l_loan_details.remaining_balance;

    l_payoff_tbl(2).PAYOFF_PURPOSE  := 'INT';
    l_payoff_tbl(2).BILLED_AMOUNT   := l_interest_unpaid;
    l_payoff_tbl(2).UNBILLED_AMOUNT := l_additional_interest;
    l_payoff_tbl(2).TOTAL_AMOUNT    := l_additional_interest + l_interest_unpaid;

    l_payoff_tbl(3).PAYOFF_PURPOSE  := 'FEE';
    l_payoff_tbl(3).BILLED_AMOUNT   := l_fees_unpaid;
    l_payoff_tbl(3).UNBILLED_AMOUNT := l_additional_fees;
    l_payoff_tbl(3).TOTAL_AMOUNT    := l_fees_unpaid + l_additional_fees;

    x_payoff_tbl := l_payoff_tbl;

    -- --------------------------------------------------------------------
    -- End of API body
    --

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO calculatePayoff;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO calculatePayoff;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN OTHERS THEN
              ROLLBACK TO calculatePayoff;
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := l_msg_count;
              x_msg_data  := l_msg_data;
              FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
              logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end calculatePayoff;

function frequency2ppy(p_frequency in varchar2) return number
is
    l_ppy   number;
begin
     l_ppy := 1;

     if p_frequency = 'WEEKLY' then
        l_ppy := 52;
     elsif p_frequency = 'BIWEEKLY' then
        l_ppy := 26;
     elsif p_frequency = 'SEMI-MONTHLY' then
        l_ppy := 24;
     elsif p_frequency = 'MONTHLY' then
        l_ppy := 12;
     elsif p_frequency = 'BI-MONTHLY' then
        l_ppy := 6;
     elsif p_frequency = 'QUARTERLY' then
        l_ppy := 4;
     elsif p_frequency = 'SEMI-ANNUALLY' then
        l_ppy := 2;
     elsif p_frequency = 'YEARLY' then
        l_ppy := 1;
     else
         FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_INTERVAL');
         FND_MESSAGE.SET_TOKEN('INTERVAL',p_frequency);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
     end if;

     return l_ppy;
end;


-- Introduced to fix bug 7565117
procedure get_factors(p_frequency in varchar2,
                       p_days_in_year in number,
                       x_ppy in out nocopy number,
                       x_days_in_period in out nocopy number)
is
    l_days_in_year      number;
begin
/*
    if p_days_count_method is not null then   -- used for payment frequency
        if (p_days_count_method = '30/360' or
        p_days_count_method = '30E/360' or
        p_days_count_method = '30E+/360' or
        p_days_count_method = 'ACTUAL_360')
        then
            l_days_in_year := 360;
        elsif (p_days_count_method = 'ACTUAL_365') then
            l_days_in_year := 365;
        elsif (p_days_count_method = 'ACTUAL_365L' or
        p_days_count_method = 'ACTUAL_ACTUAL') then
            l_days_in_year := 365.5;
        end if;
    else   -- used for compounding frequency
        if p_frequency = 'WEEKLY' or p_frequency = 'BIWEEKLY' or p_frequency = 'SEMI-MONTHLY' then
            l_days_in_year := 365;
        else
            l_days_in_year := 360;
        end if;
    end if;

    if p_frequency = 'WEEKLY' then
        x_days_in_period := 7;
        x_ppy := l_days_in_year / x_days_in_period;
    elsif p_frequency = 'BIWEEKLY' then
        x_days_in_period := 14;
        x_ppy := l_days_in_year / x_days_in_period;
    elsif p_frequency = 'SEMI-MONTHLY' then
        x_days_in_period := 15;
        x_ppy := l_days_in_year / x_days_in_period;
    elsif p_frequency = 'MONTHLY' then
        x_ppy := 12;
        x_days_in_period := l_days_in_year / x_ppy;
    elsif p_frequency = 'BI-MONTHLY' then
        x_ppy := 6;
        x_days_in_period := l_days_in_year / x_ppy;
    elsif p_frequency = 'QUARTERLY' then
        x_ppy := 4;
        x_days_in_period := l_days_in_year / x_ppy;
    elsif p_frequency = 'SEMI-ANNUALLY' then
        x_ppy := 2;
        x_days_in_period := l_days_in_year / x_ppy;
    elsif p_frequency = 'YEARLY' then
        x_ppy := 1;
        x_days_in_period := l_days_in_year / x_ppy;
    else
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_INTERVAL');
        FND_MESSAGE.SET_TOKEN('INTERVAL',p_frequency);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;
*/

    x_ppy := frequency2ppy(p_frequency);
    x_days_in_period := p_days_in_year / x_ppy;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_days_in_period = ' || x_days_in_period);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_ppy = ' || x_ppy);

end;


/*=========================================================================
|| PUBLIC PROCEDURE getCompoundPeriodicRate
||
|| DESCRIPTION
||
|| Overview:  this function will return the compound interest rate
||
|| Parameters:
||            p_compound_freq - mandatory; compounding frequency
||            p_payment_freq - mandatory; payment frequency
||            p_start_date - optional; start date of rate
||            p_end_date - optional; end date of rate
||            p_annualized rate  - mandatory; interest rate expressed as a WHOLE number
||            p_days_count_method - mandatory; day count method
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: compound periodic interest rate on the loan
||
 | KNOWN ISSUES
 |
 | NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 09/21/2007            scherkas           Created
||  4/08/2008            scherkas          Fix logic to work with any number of years between period_start_date and period_end_date
 *=======================================================================*/
function getCompoundPeriodicRate(p_compound_freq in varchar2
                        ,p_payment_freq in varchar2
                        ,p_annualized_rate   in number
                        ,p_period_start_date in date
                        ,p_period_end_date   in date
                        ,p_days_count_method in varchar2
                        ,p_target in varchar2) return number
is
    l_periodic_rate   number;
    l_day_count       number;
    l_days_in_year    number;
    l_api_name        varchar2(25);
    l_year1           number;
    l_year2           number;
    l_rate1           number;
    l_days_ratio      number;
    l_payments_per_year  number;
    l_compounds_per_year number;
    l_start_date      date;
    l_end_date        date;
    l_days_in_period  number;
    l_total_periodic_rate   number;
    l_avrg_days_in_years    number;
    l_years_count           number;

begin

    l_api_name        := 'getCompoundPeriodicRate';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_compound_freq: ' || p_compound_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_payment_freq: ' || p_payment_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_annualized_rate: ' || p_annualized_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_days_count_method: ' || p_days_count_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_period_start_date: ' || p_period_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_period_end_date: ' || p_period_end_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_target: ' || p_target);

    l_compounds_per_year := frequency2ppy(p_compound_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': compounds per year = ' || l_compounds_per_year);

    select to_number(to_char(p_period_start_date, 'YYYY')) into l_year1 from dual;
    select to_number(to_char(p_period_end_date, 'YYYY')) into l_year2 from dual;

    l_periodic_rate := 0;
    l_total_periodic_rate := 0;

    if p_target = 'INTEREST' then

        l_days_ratio := 0;
        l_avrg_days_in_years := 0;
        l_years_count := 0;

        for k in l_year1..l_year2 loop

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ------ Calculating for year ' || k);
            l_periodic_rate := 0;
            l_rate1        := 0;
            l_day_count    := 0;
            l_days_in_year := 0;

            if k = l_year1 then
                l_start_date := p_period_start_date;
            else
                l_start_date := l_end_date;
            end if;

            if k = l_year2 then
                l_end_date := p_period_end_date;
            else
                l_end_date := to_date('01/01/' || to_char(k+1),'DD/MM/YYYY');
            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_start_date = ' || l_start_date);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_date = ' || l_end_date);

            l_day_count := LNS_FIN_UTILS.getDayCount(p_start_date       => l_start_date
                                                    ,p_end_date         => l_end_date
                                                    ,p_day_count_method => p_days_count_method);

            l_days_in_year := LNS_FIN_UTILS.daysInYear(p_year              => k
                                                    ,p_year_count_method => p_days_count_method);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_day_count = ' || l_day_count);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_days_in_year = ' || l_days_in_year);

            get_factors(p_frequency => p_payment_freq,
                        p_days_in_year => l_days_in_year,
                        x_ppy => l_payments_per_year,
                        x_days_in_period => l_days_in_period);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_payments_per_year = ' || l_payments_per_year);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_days_in_period = ' || l_days_in_period);

            l_periodic_rate := l_day_count/l_days_in_period * (Power((1+((p_annualized_rate)/(100*l_compounds_per_year))),(l_compounds_per_year/l_payments_per_year))-1);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_rate = ' || l_periodic_rate);

            l_total_periodic_rate := l_total_periodic_rate + l_periodic_rate;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_total_periodic_rate = ' || l_total_periodic_rate);

        end loop;

    else

        l_avrg_days_in_years := 0;
        l_years_count := 0;
        for k in l_year1..l_year2 loop

            l_days_in_year := LNS_FIN_UTILS.daysInYear(p_year              => k
                                                    ,p_year_count_method => p_days_count_method);

            l_avrg_days_in_years := l_avrg_days_in_years + l_days_in_year;
            l_years_count := l_years_count + 1;

        end loop;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_years_count = ' || l_years_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total number of days in all years = ' || l_avrg_days_in_years);

        l_avrg_days_in_years := l_avrg_days_in_years / l_years_count;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_avrg_days_in_years = ' || l_avrg_days_in_years);

        get_factors(p_frequency => p_payment_freq,
                    p_days_in_year => l_avrg_days_in_years,
                    x_ppy => l_payments_per_year,
                    x_days_in_period => l_days_in_period);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': avarage payments per year = ' || l_payments_per_year);

        l_total_periodic_rate := Power((1+((p_annualized_rate)/(100*l_compounds_per_year))),(l_compounds_per_year/l_payments_per_year))-1;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_total_periodic_rate = ' || l_total_periodic_rate);

    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '-------------');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Final Periodic rate ' || l_total_periodic_rate);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_total_periodic_rate;

end getCompoundPeriodicRate;


/*=========================================================================
|| PUBLIC PROCEDURE getPeriodicRate
||
|| DESCRIPTION
||
|| Overview:  this function will return the interest rate for a given
||             period of time so the interest in a give month at
||             12% interest per year will return a 1% monthly rate
||              (30 /360 methodology)
||
|| Parameter: p_start_date optional start date of rate
||            p_end_date optional end date of rate
||            p_annualized rate = interest rate expressed as a WHOLE number
||            p_days_count_method = for future use
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: periodic interest rate on the loan
||
 | KNOWN ISSUES
 |
 | NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/09/2003 1:51PM     raverma           Created
||  2/26/2004            raverma           added more robust day / year counting methodolgy
||  7/22/2004            raverma           handle situation where start date = end date
||  3/22/2006            karamach          Fix date format issue for bug5112031
||  4/08/2008            scherkas          Fix logic to work with any number of years between period_start_date and period_end_date
 *=======================================================================*/
function getPeriodicRate(p_payment_freq in varchar2
                        ,p_period_start_date in date
                        ,p_period_end_date   in date
                        ,p_annualized_rate   in number
                        ,p_days_count_method in varchar2
                        ,p_target            in varchar2) return number
is
    l_annual_rate     number;
    l_periodic_rate   number;
    l_day_count       number;
    l_days_in_year    number;
    l_api_name        varchar2(25);
    l_year1           number;
    l_year2           number;
    l_periodic_factor number;
    l_rate1           number;
    l_rate2           number;
    l_start_date      date;
    l_end_date        date;
    l_avrg_days_in_years    number;
    l_years_count           number;
    l_payments_per_year     number;

begin

    l_api_name        := 'getPeriodicRate';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': days count method: ' || p_days_count_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': annualized rate: ' || p_annualized_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': start date: ' || p_period_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': end date: ' || p_period_end_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': p_target: ' || p_target);

    l_annual_rate   := p_annualized_rate / 100;
    l_periodic_rate := 0;

    select to_number(to_char(p_period_start_date, 'YYYY')) into l_year1 from dual;
    select to_number(to_char(p_period_end_date, 'YYYY')) into l_year2 from dual;

    if p_target = 'INTEREST' then

        for k in l_year1..l_year2 loop

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' ------ Calculating for year ' || k);
            l_rate1        := 0;
            l_day_count    := 0;
            l_days_in_year := 0;

            if k = l_year1 then
                l_start_date := p_period_start_date;
            else
                l_start_date := l_end_date;
            end if;

            if k = l_year2 then
                l_end_date := p_period_end_date;
            else
                l_end_date := to_date('01/01/' || to_char(k+1),'DD/MM/YYYY');
            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_start_date = ' || l_start_date);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_end_date = ' || l_end_date);

            l_day_count := LNS_FIN_UTILS.getDayCount(p_start_date       => l_start_date
                                                    ,p_end_date         => l_end_date
                                                    ,p_day_count_method => p_days_count_method);

            l_days_in_year := LNS_FIN_UTILS.daysInYear(p_year              => k
                                                    ,p_year_count_method => p_days_count_method);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_day_count = ' || l_day_count);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_days_in_year = ' || l_days_in_year);

            l_rate1 := (l_day_count / l_days_in_year) * l_annual_rate;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': rate1 = ' || l_rate1);

            l_periodic_rate := l_periodic_rate + l_rate1;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Periodic rate = ' || l_periodic_rate);

        end loop;

    else

        l_avrg_days_in_years := 0;
        l_years_count := 0;
        for k in l_year1..l_year2 loop

            l_days_in_year := LNS_FIN_UTILS.daysInYear(p_year              => k
                                                    ,p_year_count_method => p_days_count_method);

            l_avrg_days_in_years := l_avrg_days_in_years + l_days_in_year;
            l_years_count := l_years_count + 1;

        end loop;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_years_count = ' || l_years_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total number of days in all years = ' || l_avrg_days_in_years);

        l_avrg_days_in_years := l_avrg_days_in_years / l_years_count;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': avarage days_in_year = ' || l_avrg_days_in_years);

        get_factors(p_frequency => p_payment_freq,
                    p_days_in_year => l_avrg_days_in_years,
                    x_ppy => l_payments_per_year,
                    x_days_in_period => l_day_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': avarage payments per year = ' || l_payments_per_year);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_day_count = ' || l_day_count);

        l_periodic_rate := (l_day_count / l_avrg_days_in_years) * l_annual_rate;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_periodic_rate = ' || l_periodic_rate);

    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || '-------------');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Final Periodic rate ' || l_periodic_rate);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_periodic_rate;

end getPeriodicRate;

/*
||
|| Parameter: p_rate = annualized interest rate
||            p_period_value = time factor like '2'
||            p_period_type = 'DAILY', 'WEEKLY', 'BI-WEEKLY', 'MONTHLY'
||                            'BI-MONTHLY',
|| Return value:
||
|| Source Tables:
||
|| Target Tables:
||
|| Creation date:       12/08/2003 3:33PM
||
|| Major Modifications: when            who                       what
||
*/
function compoundInterest(p_rate in number
                         ,p_period_value in number
                         ,p_period_type in varchar2) return number
is
begin
        null;
end compoundInterest;

/*=========================================================================
|| PUBLIC PROCEDURE getAnnualRate
||
|| DESCRIPTION
||
|| Overview:  gets the current interest rate for the loan
||
|| Parameter:  loan_id
||
|| Return value: current annual rate for the loan
||
|| Source Tables: LNS_RATE_SCHEDULES
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/15/2003 4:28PM     raverma           Created
||
 *=======================================================================*/
function getAnnualRate(p_loan_Id in number) return number
is
 l_rate     number;
 l_api_name varchar2(20);

begin

     --    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    select rs.current_interest_rate into l_rate
      from lns_rate_schedules rs,
           lns_terms t,
           lns_loan_headers_all h
     where h.loan_id = p_loan_id
       and h.loan_id = t.loan_id
       and rs.term_id = t.term_id
       and rs.start_date_active <= sysdate
       and rs.end_date_active >= sysdate;

     --    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_rate;

Exception

    When Others then
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Error: ' || sqlerrm);
    --seed this message
    -- FND_MESSAGE.Set_Name('LNS', 'LNS_UNABLE_TO_COMPUTE_BALANCE');
    -- FND_MSG_PUB.Add;
    -- RAISE FND_API.G_EXC_ERROR;

end getAnnualRate;

/*=========================================================================
|| PUBLIC PROCEDURE getActiveRate
||
|| DESCRIPTION
||
|| Overview:  gets the current interest rate for the loan
||                we will look at the last installment billed (not reversed)
||                to get the rate on the loan
|| Parameter:  loan_id
||
|| Return value: current annual rate for the loan
||
|| Source Tables: LNS_RATE_SCHEDULES,
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 3/8/2004 4:28PM     raverma           Created
||
 *=======================================================================*/
function getActiveRate(p_loan_id in number) return number
is
 l_rate_details     LNS_FINANCIALS.INTEREST_RATE_REC;
 l_last_installment number;
 l_active_rate      number;
 l_rate_tbl         LNS_FINANCIALS.RATE_SCHEDULE_TBL;


begin

 l_active_rate      := -1;
 l_rate_tbl         := getRateSchedule(p_loan_id, 'TERM');

 if l_rate_tbl.count = 1 then
   l_active_rate := l_rate_tbl(1).annual_rate;

 else

   begin

		 l_last_installment := LNS_BILLING_UTIL_PUB.LAST_PAYMENT_NUMBER(p_loan_id);

		 if l_last_installment = 0
		 	 then l_last_installment := 1;
		 end if;

   exception when others then
     l_last_installment := 1;
   end;
   l_rate_details := getRateDetails(p_installment => l_last_installment
                                   ,p_rate_tbl    => l_rate_tbl);
   l_active_rate := l_rate_Details.annual_rate;

 end if;

 return l_active_rate;

end getActiveRate;


/*=========================================================================
|| PUBLIC PROCEDURE calculateInterestRate
||
|| DESCRIPTION
||
|| Overview:      function to calcualte interest for a variableRate Loan
||
|| Parameter:
||           p_initial_rate            in number => initial interest rate for loan
||           p_last_period_rate        in number => last periodic rate
||           p_max_period_adjustment   in number => maximum rate diff between adjustments
||           p_max_lifetime_adjustment in number => maximum lifetime rate difference
||           p_ceiling                 in number => maximum rate
||           p_floor                   in number => minimum rate
||           p_rate_to_compare         in number => index rate plus spread
||
|| Return value:  variable interest rate
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| Creation date:       12/08/2003 6:31PM
||
|| Major Modifications: when            who                       what
||                     11/20/2005    raverma                   created
 *=======================================================================*/
function calculateInterestRate(p_initial_rate            in number
                              ,p_rate_to_compare         in number
                              ,p_last_period_rate        in number
                              ,p_max_first_adjustment    in number
                              ,p_max_period_adjustment   in number
                              ,p_max_lifetime_adjustment in number
                              ,p_ceiling_rate            in number
                              ,p_floor_rate              in number
                              ,p_installment_number      in number) return number

is
  l_new_rate       number;
  l_rate_diff      number;
  l_life_rate_diff number;
  l_sign1          number;
  l_sign2          number;
  l_api_name       varchar2(30);

begin

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    -- need to check for NULLs
    l_rate_diff      := ABS(p_rate_to_compare - p_last_period_rate);
    l_life_rate_diff := ABS(p_rate_to_compare - p_initial_rate);
    l_sign1          := 1;
    l_sign2          := 1;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_rate_diff ' || l_rate_diff);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_life_rate_diff ' || l_life_rate_diff);

    -- rate differentials go both ways
    if p_rate_to_compare < p_last_period_rate then
        l_sign1 := -1;
    end if;

    -- rate differentials go both ways
    if p_rate_to_compare < p_initial_rate then
        l_sign2 := -1;
    end if;

    l_new_rate := p_rate_to_compare;

    if l_new_rate > p_ceiling_rate and p_ceiling_rate is not null then
        l_new_rate := p_ceiling_rate;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - New Rate was above CEILING of: ' || p_ceiling_rate);
    end if;

    l_life_rate_diff := ABS(l_new_rate - p_initial_rate);
    if l_life_rate_diff > p_max_lifetime_adjustment and p_max_lifetime_adjustment is not null then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - New Rate was above life differential of: ' || l_life_rate_diff );
        l_new_rate := p_last_period_rate + (p_max_lifetime_adjustment * l_sign2);
    end if;
    l_rate_diff      := ABS(l_new_rate - p_last_period_rate);

    if l_rate_diff > p_max_period_adjustment and p_max_period_adjustment is not null then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - New rate was above adjustment differential of: ' || l_rate_diff);
        l_new_rate := p_last_period_rate + (p_max_period_adjustment * l_sign1);
    end if;

    if l_new_rate < p_floor_rate and p_floor_rate is not null then
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' -  New Rate was below floor of ' || p_floor_rate );
        l_new_rate := p_floor_rate;
    end if;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_new_rate ' || l_new_rate);

  return l_new_rate;

end calculateInterestRate;

/*=========================================================================
|| PUBLIC PROCEDURE getRemainingBalance
||
|| DESCRIPTION
||
|| Overview:      function to get the remaining balance on the loan
||
|| Parameter:  loan_id
||
|| Return value:  Amount Or BALANCE on loan
||
|| Source Tables: LNS_TERMS, LNS_LOAN_HEADER, LNS_AMORTIZATION_SCHEDS
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| Creation date:       12/08/2003 6:31PM
||
|| Major Modifications: when            who                       what
||                     12/26/2003  raverma base the remaining balance from
||                                 loan status
||                      2/03/2004  balance if ACTIVE is based on PRINCIPAL_BALANCE
||                      7/29/2004  balance if DEFAULT or DELINQUENT = ACTIVE
 *=======================================================================*/
function getRemainingBalance(p_loan_id in number) return number
is
    l_balance        number;
    l_initial_amount number;
    l_billed_amount  number;
    l_loan_status    varchar2(30);
    l_column         varchar2(30);
    l_table          varchar2(30);
    l_api_name       varchar2(30);

begin
    l_balance        := -1;
    l_initial_amount := 0;
    l_billed_amount  := 0;
    l_api_name       := 'getRemainingBalance';
    --    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

     Execute Immediate
             ' Select Loan_Status ' ||
             ' From lns_loan_headers_all ' ||
             ' where loan_id = :p_loan_id'
              into l_loan_status
             using p_loan_id;

     if l_loan_status = 'APPROVED' then
        l_column := 'REQUESTED_AMOUNT';
        l_table  := 'LNS_LOAN_HEADERS_ALL';

     elsif l_loan_Status = 'ACTIVE' then
        l_column := 'TOTAL_PRINCIPAL_BALANCE';
        l_table  := 'LNS_PAY_SUM_V';

     elsif l_loan_Status = 'DELINQUENT' then
        l_column := 'TOTAL_PRINCIPAL_BALANCE';
        l_table  := 'LNS_PAY_SUM_V';

     elsif l_loan_Status = 'DEFAULT' then
        l_column := 'TOTAL_PRINCIPAL_BALANCE';
        l_table  := 'LNS_PAY_SUM_V';

     elsif l_loan_Status = 'PAIDOFF' then
        l_column := 'TOTAL_PRINCIPAL_BALANCE';
        l_table  := 'LNS_PAY_SUM_V';
--        l_column := 'REQUESTED_AMOUNT';
--        l_table  := 'LNS_LOAN_HEADERS_ALL';

     elsif l_loan_status = 'PENDING' then
        l_column := 'REQUESTED_AMOUNT';
        l_table  := 'LNS_LOAN_HEADERS_ALL';

     elsif l_loan_status = 'INCOMPLETE' then
        l_column := 'REQUESTED_AMOUNT';
        l_table  := 'LNS_LOAN_HEADERS_ALL';

     elsif l_loan_status = 'IN_FUNDING' then
        l_column := 'REQUESTED_AMOUNT';
        l_table  := 'LNS_LOAN_HEADERS_ALL';

     elsif l_loan_status = 'FUNDING_ERROR' then
        l_column := 'REQUESTED_AMOUNT';
        l_table  := 'LNS_LOAN_HEADERS_ALL';

     else -- catch any new statuses
        l_column := 'REQUESTED_AMOUNT';
        l_table  := 'LNS_LOAN_HEADERS_ALL';

     end if;

     Execute Immediate
             ' Select ' || l_column ||
             ' From ' || l_table ||
             ' where loan_id = :p_loan_id'
             into l_balance
             using p_loan_id;

    --    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': remainingBalance: ' || l_balance);
    --    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_balance;
/*
  Exception
        When Others then
         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Error: ' || sqlerrm);
        --seed this message
         FND_MESSAGE.Set_Name('LNS', 'LNS_UNABLE_TO_COMPUTE_BALANCE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
 */
end getRemainingBalance;


function getFundedAmount(p_loan_id in number, p_date in date, p_based_on_terms varchar2) return number
is

    l_api_name  varchar2(30) := 'getFundedAmount';
    l_funded_amount   number;

    cursor c_get_loan_balance(p_loan_id number, p_date date) is
        select
        decode(loan.loan_class_code,
        'DIRECT', (select nvl(sum(disb_line.LINE_AMOUNT), 0) from lns_disb_lines disb_line, lns_disb_headers disb_hdr
                    where disb_hdr.loan_id = loan.loan_id and /*disb_hdr.phase = 'TERM' and */
                    disb_hdr.disb_header_id = disb_line.disb_header_id and disb_line.STATUS = 'FULLY_FUNDED' and
                    trunc(disb_line.DISBURSEMENT_DATE) <= trunc(p_date)),
        'ERS', (select nvl(sum(lines.REQUESTED_AMOUNT), 0) from lns_loan_lines lines
                where lines.loan_id = loan.loan_id and lines.STATUS = 'APPROVED' and
                trunc(lines.ADJUSTMENT_DATE) <= trunc(p_date)))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

    cursor c_get_loan_balance1(p_loan_id number, p_date date) is
        select
        decode(loan.loan_class_code,
        'DIRECT', (select nvl(sum(disb_line.LINE_AMOUNT), 0) from lns_disb_lines disb_line, lns_disb_headers disb_hdr
                    where disb_hdr.loan_id = loan.loan_id and /*disb_hdr.phase = 'TERM' and */
                    disb_hdr.disb_header_id = disb_line.disb_header_id and
                    disb_line.STATUS is null and trunc(disb_hdr.PAYMENT_REQUEST_DATE) <= trunc(p_date)),
        'ERS', (select nvl(sum(lines.REQUESTED_AMOUNT), 0) from lns_loan_lines lines
                where lines.loan_id = loan.loan_id and (lines.STATUS is null or lines.STATUS = 'PENDING') and
                end_date is null))
        from lns_loan_headers_all loan
        where loan.loan_id = p_loan_id;

begin
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_date = ' || p_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_based_on_terms = ' || p_based_on_terms);

    if p_based_on_terms = 'CURRENT' then
        open c_get_loan_balance(p_loan_id, p_date);
        fetch c_get_loan_balance into l_funded_amount;
        close c_get_loan_balance;
    else
        open c_get_loan_balance1(p_loan_id, p_date);
        fetch c_get_loan_balance1 into l_funded_amount;
        close c_get_loan_balance1;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_funded_amount = ' || l_funded_amount);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_funded_amount;
end;


/*========================================================================
 | PUBLIC FUNCTION weightBalance
 |
 | DESCRIPTION
 |      takes a table of loan_activities, sorts them and weights the balance
||       by the from/to dates
 |
 | PSEUDO CODE/LOGIC
||     - calculate the wtd average daily balance for the loan (construction)
||     - day counting method is accoring to the terms of the loan
||
||      within the given from/to date range
||      ADB =[(# of days X Balance 1 ) +
||            (# of days X Balance 2 ) +
||            (# of days X Balance 3 ) +
||             .
||             .
||             .
||            (# of days X Balance N ) ]
||             /
||             Total Number of Days (from <-> to dates)
 |
 | PARAMETERS
 |
 | Return value:
 |
 | Source Tables: NA
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07/19/05 4:13:PM       raverma           Created
 *=======================================================================*/
function weightBalance(p_loan_activities   IN LNS_FINANCIALS.LOAN_ACTIVITY_TBL
                      ,p_from_date         in date
                      ,p_to_date     			 in date
                      ,p_day_count_method	 in varchar2) return number
is
    l_balance_days          number;
    l_total_days            number;
		l_num_days							number;
    l_weighted_balance      number;
    k                       number;
    m                       number;
    l_api_name              varchar2(25);
    l_begin_balance         number;
    l_end_balance           number;
		l_total_activity_amount number;
		l_loan_activities       LNS_FINANCIALS.LOAN_ACTIVITY_TBL;


begin
		 l_api_name := 'weightBalance';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - number of activities: ' || p_loan_activities.count);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_date:          ' ||  p_from_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_to_date:            ' || p_to_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_day_count_method:   ' || p_day_count_method);

		 -- sort activities by activity date

     -- # of days @ balance 1
     -- # of days @ balance 2
     -- # of days @ balance N
     -- find balance on from date
     -- find balance on to date
     -- find number of balance changes between the 2
     -- loop thru each balance change and calc # of days at balance
     -- now calculate ADB using dates from and to
     l_balance_days          := 0;
     l_total_days            := 0;
	   l_num_days					     := 0;
     l_weighted_balance      := 0;
		 l_total_activity_amount := 0;
		 l_loan_activities       := p_loan_activities;
 		 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - sorting the activities');
		 sortRows(l_loan_activities);

		 /*
		 for j in 1..p_loan_activities.count
		 loop
			dbms_output.put_line(p_loan_activities(j).activity_date );
			dbms_output.put_line(p_loan_activities(j).ending_balance );
		 end loop;
			*/

		 m := l_loan_activities.count;

		 if m = 1 then
	     l_weighted_balance := l_loan_activities(1).ending_balance;
		 else

	 		 for p in 1..m loop
			  	--dbms_output.put_line('p is ' || p);
					 if l_loan_activities(p).activity_amount > 0 then
						     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p ' || p);
						     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - activity date: ' || l_loan_activities(p).activity_date);
						     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - activity amount: ' || l_loan_activities(p).activity_amount);
							 if p = 1 then
									 -- this is for the previous balance
				           l_num_days := LNS_FIN_UTILS.getDayCount(p_start_date       => p_from_date
				                                                  ,p_end_date         => p_to_date
				                                                  ,p_day_count_method => p_day_count_method);
						   elsif p < m then
				           l_num_days := LNS_FIN_UTILS.getDayCount(p_start_date       => l_loan_activities(p).activity_date
				                                                  ,p_end_date         => l_loan_activities(p+1).activity_date
				                                                  ,p_day_count_method => p_day_count_method);
				       elsif p = m  then
				          --dbms_output.put_line('2');
				           l_num_days := LNS_FIN_UTILS.getDayCount(p_start_date       => l_loan_activities(p).activity_date
				                                                  ,p_end_date         => p_to_date
				                                                  ,p_day_count_method => p_day_count_method);
				       end if;

							 if l_num_days > 0 then
							    l_total_activity_amount := l_total_activity_amount + l_loan_activities(p).activity_amount;
							 end if;

						   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - total activity amount: ' || l_total_activity_amount);
				       --dbms_output.put_line('day count is ' || l_num_days);
				       --dbms_output.put_line('balance is ' || p_loan_activities(p).ending_balance);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_balance_days: ' || l_balance_days);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_num_days: ' || l_num_days);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - activity_amount: ' || l_loan_activities(p).activity_amount);
				       l_balance_days := l_balance_days + (l_num_days * l_loan_activities(p).activity_amount);
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - result l_balance_days: ' || l_balance_days);
				   end if;

			 end loop;

	     -- this is the total days (denominator)
		    l_total_Days := LNS_FIN_UTILS.getDayCount(p_start_date       => p_from_date
		                                             ,p_end_date         => p_to_date
		                                             ,p_day_count_method => p_day_count_method);
		    -- dbms_output.put_line('total days is ' || l_total_Days );
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_balance_days: ' || l_balance_days);
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_total_days: ' || l_total_days);
		    l_weighted_balance := l_balance_days / l_total_days;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_weighted_balance: ' || l_weighted_balance);

		 end if;

     return l_weighted_balance;

end weightBalance;

/*=========================================================================
|| PUBLIC FUNCTION getWeightedBalance
||
|| DESCRIPTION
||
|| PARAMETERS
||                p_loan_id   loan_id
||                p_term_id   term_id (for future use)
||                p_from_date date from which to calculate ADB
||                p_to_date   date to which to calculate ADB
||                p_calc_method 'ACTUAL' or 'TARGET'
||
|| Return value: wtd average daily balance for the loan
||
|| Source Tables: LNS_DISB_HEADERS, LNS_DISB_LINES
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/17/05 1:51:PM      raverma           Created
 *=======================================================================*/
procedure getWeightedBalance(p_loan_id          in number
                           ,p_from_date        in date
                           ,p_to_date          in date
                           ,p_calc_method      in varchar2
                           ,p_phase            in varchar2
                           ,p_day_count_method in varchar2
                           ,p_adj_amount       in number
                           ,x_wtd_balance      out NOCOPY number
                           ,x_begin_balance    out NOCOPY number
                           ,x_end_balance      out NOCOPY number)

is
	l_api_name         varchar2(25);
	l_loan_activities  LNS_FINANCIALS.LOAN_ACTIVITY_TBL;
	i                  number;
	l_activity_date    date;
	l_activity_amount  number;
	l_loan_start_date  date;
    l_display_order    number;

	cursor c_actual_balance(p_loan_id number, p_from_date date, p_to_date date)  IS
		select * from
            (select p_from_date activity_date
                ,nvl(sum(line_amount), 0)
                ,1 display_order
            from lns_disb_lines lines
            where disb_header_id in (select disb_header_id from lns_disb_headers where loan_id = p_loan_id)
                and trunc(disbursement_date) <= p_from_date
            UNION
            select trunc(line.disbursement_date) activity_date
                ,nvl(sum(inv.amount), 0)
                ,2 display_order
            from AP_INVOICE_PAYMENTS_ALL inv
                ,lns_disb_headers head
                ,lns_disb_lines line
            where head.loan_id = p_loan_id
                and line.disb_header_id = head.disb_header_id
                and line.invoice_id is not null
                and line.invoice_id = inv.invoice_id
                and line.status IN ('PARTIALLY_FUNDED', 'FULLY_FUNDED')
                and trunc(line.disbursement_date) > p_from_date
                and trunc(line.disbursement_date) < p_to_date
            group by trunc(line.disbursement_date))
        order by display_order, activity_date;

    /*  raverma 12-13-05 removed
		select disbursement_date
		      ,sum(line_amount)
		  from lns_disb_lines
     where disb_header_id in (select disb_header_id from lns_disb_headers where loan_id = p_loan_id)
       and disbursement_date is not null
       and trunc(disbursement_date) >= p_from_date
			 and trunc(disbursement_date) < p_to_date
  group by disbursement_date;
     */
    cursor c_theoretical_balance(p_loan_id number, p_from_date date, p_to_date date) IS
            select * from
                (select p_from_date activity_date
                    ,nvl(sum(header_amount),0)
                    ,1 display_order
                from lns_disb_headers
                where loan_id = p_loan_id
                    and trunc(payment_request_date) <= p_from_date
                UNION
                select payment_request_date activity_date
                    ,nvl(sum(header_amount),0)
                    ,2 display_order
                from lns_disb_headers
                where loan_id = p_loan_id
                    and trunc(payment_request_date) > p_from_date
                    and trunc(payment_request_date) < p_to_date
                group by payment_request_date
                UNION
                select lines.*
                from
                (select p_from_date activity_date
                    ,nvl(sum(REQUESTED_AMOUNT),0)
                    ,3 display_order
                from lns_loan_lines
                where loan_id = p_loan_id
                    and (status is null or status = 'PENDING')
                    and end_date is null) lines,
                lns_loan_headers_all loan
                where loan.loan_id = p_loan_id
                and loan.LOAN_CLASS_CODE = 'ERS')
            order by display_order, activity_date;

    cursor c_loan_boundaries(p_loan_id number)
    is
        select open_loan_start_date
            from lns_loan_headers
            where loan_id = p_loan_id;

begin

     l_api_name             := 'getWeightedBalance';
     i                      := 0;
	 x_wtd_balance			:= 0;
     x_begin_balance := 0;
     x_end_balance := 0;
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Begin');
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_date: ' || p_from_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_to_date: ' || p_to_date);
	 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_loan_id: ' || p_loan_id);
	 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_calc_method: ' || p_calc_method);
	 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_adj_amount: ' || p_adj_amount);
	 logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_phase: ' || p_phase);

     -- validate the from and to Dates
     if p_from_date > p_to_date  then
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_ACTIVE_DATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end if;
		 /*
     l_loan_details := lns_financials.getLoanDetails(p_loan_id        => p_loan_id
                                                    ,p_based_on_terms => 'CURRENT'
																										,p_phase          => 'OPEN');

     -- validate if dates are within the boundaries of loan_start and maturity_dates
     if p_to_date > l_loan_details.maturity_date then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYMENT_START_DATE_ERROR1');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end if;

     if p_from_date < l_loan_details.loan_start_date then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYMENT_START_DATE_ERROR2');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end if;
		 */
     l_loan_activities(1).ending_balance := 0;

     if p_calc_method = 'ACTUAL' then

        -- get all the balance activities on the loan
        OPEN c_actual_balance(p_loan_id, p_from_date, p_to_date);
        LOOP
            i := i + 1;
            FETCH c_actual_balance INTO
                l_activity_date
                ,l_activity_amount
                ,l_display_order;
            EXIT WHEN c_actual_balance%NOTFOUND;

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - #: ' || i);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_activity_date = ' || l_activity_date);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_activity_amount = ' || l_activity_amount);
            l_loan_activities(i).activity_date    := l_activity_date;
            l_loan_activities(i).activity_amount  := l_activity_amount;
            if i = 1 then
                l_loan_activities(i).ending_balance   := l_activity_amount;
                x_begin_balance := l_loan_activities(i).ending_balance;
                x_end_balance := l_loan_activities(i).ending_balance;
            else
                l_loan_activities(i).ending_balance   := l_activity_amount + l_loan_activities(i-1).ending_balance;
                x_end_balance := l_loan_activities(i).ending_balance;
            end if;
            l_activity_date                       := null;
            l_activity_amount                     := null;
        END LOOP;
        close c_actual_balance;

     elsif p_calc_method = 'TARGET' then

        OPEN c_theoretical_balance(p_loan_id, p_from_date, p_to_date);
        LOOP
            i := i + 1;
            FETCH c_theoretical_balance INTO
                l_activity_date
                ,l_activity_amount
                ,l_display_order;
            EXIT WHEN c_theoretical_balance%NOTFOUND;

            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - #: ' || i);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_activity_date = ' || l_activity_date);
            logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_activity_amount = ' || l_activity_amount);

            if i = 1 then
                l_activity_amount := l_activity_amount - p_adj_amount;
                logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - NEW l_activity_amount = ' || l_activity_amount);

                l_loan_activities(i).ending_balance   := l_activity_amount;
                x_begin_balance := l_loan_activities(i).ending_balance;
            else
                l_loan_activities(i).ending_balance   := l_activity_amount + l_loan_activities(i-1).ending_balance;
            end if;

            x_end_balance := l_loan_activities(i).ending_balance;
            l_loan_activities(i).activity_date    := l_activity_date;
            l_loan_activities(i).activity_amount  := l_activity_amount;

            l_activity_date                       := null;
            l_activity_amount                     := null;
        END LOOP;
        close c_theoretical_balance;

    end if;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - getting wtd balance');
     x_wtd_balance := weightBalance(p_loan_activities    => l_loan_activities
                                    ,p_from_date          => p_from_date
                                    ,p_to_date     			 => p_to_date
                                    ,p_day_count_method	 => p_day_count_method);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - x_wtd_balance = ' || x_wtd_balance);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - x_begin_balance = ' || x_begin_balance);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - x_end_balance = ' || x_end_balance);

end getWeightedBalance;



/*=========================================================================
|| PUBLIC FUNCTION getAverageDailyBalance
||
|| DESCRIPTION
||     - calculate average daily balance for the loan (term)
||     - day counting method is accoring to the terms of the loan
||
||      only one method supported right now:
||      within the given from/to date range
||      ADB =[(# of days X Balance 1 ) +
||            (# of days X Balance 2 ) +
||            (# of days X Balance 3 ) +
||             .
||             .
||             .
||            (# of days X Balance N ) ]
||             /
||             Total Number of Days (from <-> to dates)
||
|| PARAMETERS
||                p_loan_id   loan_id
||                p_term_id   term_id (for future use)
||                p_from_date date from which to calculate ADB
||                p_to_date   date to which to calculate ADB
||                p_calc_method for future use
||
|| Return value: average daily balance for the loan
||
|| Source Tables: LNS_RECEIVABLE_ACTIVITIES_V, LNS_LOAN_HEADERS
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 05/31/06 1:51:PM       karamach          Added cursor c_loan_phase and passed current_phase to getLoanDetails api to fix bug5237022
|| 09/30/04 1:51:PM       raverma           Created
||
 *=======================================================================*/
function getAverageDailyBalance(p_loan_id     number
                               ,p_term_id     number
                               ,p_from_date   date
                               ,p_to_date     date
                               ,p_calc_method number) return number
is

    -- this cursor will get balance by activity date
    -- the markers ensure that funding and maturity are the 1st and last rows
    cursor c_balance_history(p_loan_id number) is
    select trunc(loan_start_date) activity_date,
           funded_amount          activity_amount,
           funded_amount          ending_balance
      from lns_loan_headers
     where loan_id = p_loan_id
    union all
    select trunc(activity_date)          activity_date,
           sum(activity_amount)          activity_amount,
           LNS_BILLING_UTIL_PUB.LOAN_BALANCE_BY_DATE(P_LOAN_ID, activity_date)     --min(balance_by_activity_date) ending_balance
      from LNS_REC_ACT_CASH_CM_V rav
     where rav.loan_id = p_loan_id and
           line_type_code = 'PRIN' and
           (activity_code in ('PMT', 'ADJ') or (activity_code = 'CM' and activity_number like 'NET%'))
    group by activity_date
    union all
    select trunc(loan_maturity_date) activity_date
          ,null
          ,lns_financials.getRemainingBalance(p_loan_id)
      from lns_loan_headers
     where loan_id = p_loan_id
    order by activity_date asc;

    -- this cursor will get the current phase of the loan
    cursor c_loan_phase(p_loan_id number) is
    select nvl(current_phase,'TERM') current_phase
      from lns_loan_headers
     where loan_id = p_loan_id;

    l_activity_date         date;
    l_activity_amount       number;
    l_balance_days          number;
    l_num_days              number;
    l_total_days            number;
    l_loan_details          LNS_FINANCIALS.LOAN_DETAILS_REC;
    l_loan_activities       LNS_FINANCIALS.LOAN_ACTIVITY_TBL;
    l_average_daily_balance number;
    k                       number;
    m                       number;
    l_num_balance_changes   number;
    l_api_name              varchar2(25);
    l_begin_balance         number;
    l_end_balance           number;
    i                       number;
--    l_marker                number;
    l_loan_phase            varchar2(30);

begin

     --LNS_BILLING_UTIL_PUB.LOAN_BALANCE_BY_DATE(P_LOAN_ID IN NUMBER, P_DATE IN DATE) function
     l_api_name             := 'getAverageDailyBalance';
     l_balance_days         := 0;
     l_num_days             := 0;
     l_total_days           := 0;
     l_average_daily_balance:= 0;
     i                      := 0;
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - Begin');
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_date: ' || p_from_date);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_to_date: ' || p_to_date);

     -- validate the from and to Dates
     if p_from_date > p_to_date  then
        FND_MESSAGE.Set_Name('LNS', 'LNS_INVALID_ACTIVE_DATE');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end if;

     OPEN c_loan_phase(p_loan_id);
     FETCH c_loan_phase INTO l_loan_phase;
     CLOSE c_loan_phase;

     l_loan_details := lns_financials.getLoanDetails(p_loan_id        => p_loan_id
                                                    ,p_based_on_terms => 'CURRENT'
						    --karamach bug5237022
                                                    --,p_phase          => 'TERM');
                                                    ,p_phase          => l_loan_phase);

     -- validate if dates are within the boundaries of loan_start and maturity_dates
     if p_to_date > l_loan_details.maturity_date then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYMENT_START_DATE_ERROR1');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end if;

     if p_from_date < l_loan_details.loan_start_date then
        FND_MESSAGE.Set_Name('LNS', 'LNS_PAYMENT_START_DATE_ERROR2');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     end if;

     -- get all the balance activities on the loan
     OPEN c_balance_history(p_loan_id);
     LOOP
         i := i + 1;
     FETCH c_balance_history INTO
         l_activity_date
        ,l_activity_amount
        ,l_end_balance;
--        ,l_marker;
         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - #: ' || i);
         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_activity_date: ' || l_activity_date);
         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_activity_amount: ' || l_activity_amount);
         logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_end_balance: ' || l_end_balance);
     EXIT WHEN c_balance_history%NOTFOUND;

         l_loan_activities(i).activity_date    := l_activity_date;
         l_loan_activities(i).activity_amount  := l_activity_amount;
         l_loan_activities(i).ending_balance   := l_end_balance;

     END LOOP;
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - number of activities: ' || l_loan_activities.count);

     -- # of balance changes = l_loan_activities.count - 2
     -- # of days @ balance 1
     -- # of days @ balance 2
     -- # of days @ balance N
     -- find balance on from date
     -- find balance on to date
     -- find number of balance changes between the 2
     -- loop thru each balance change and calc # of days at balance
     -- now calculate ADB using dates from and to
     k := 1;
     WHILE p_from_date >= l_loan_activities(k).activity_date loop
           l_begin_balance := l_loan_activities(k).ending_balance;
           k := k + 1;
     end loop;
     k := k - 1;

     m := 1;
     WHILE p_to_date >= l_loan_activities(m).activity_date loop
           l_end_balance := l_loan_activities(m).ending_balance;
           m := m + 1;
     end loop;
     m := m - 1;

     --dbms_output.put_line('output k' || k);
     --dbms_output.put_line('output m' || m);

     if k = m then
         l_average_daily_balance := l_loan_activities(k).ending_balance;
     else
         for p in k..m loop
            --dbms_output.put_line('p is ' || p);
             if p = k then              -- first record
                --dbms_output.put_line('1');
                 l_num_days := LNS_FIN_UTILS.getDayCount(p_start_date       => p_from_date
                                                        ,p_end_date         => l_loan_activities(p + 1).activity_date
                                                        ,p_day_count_method => l_loan_details.day_count_method);

             elsif p = m then
             --   dbms_output.put_line('3');
                 l_num_days := LNS_FIN_UTILS.getDayCount(p_start_date       => l_loan_activities(p).activity_date
                                                        ,p_end_date         => p_to_date
                                                        ,p_day_count_method => l_loan_details.day_count_method);

             else
             --   dbms_output.put_line('2');
                 l_num_days := LNS_FIN_UTILS.getDayCount(p_start_date       => l_loan_activities(p).activity_date
                                                        ,p_end_date         => l_loan_activities(p + 1).activity_date
                                                        ,p_day_count_method => l_loan_details.day_count_method);

             end if;
             --dbms_output.put_line('day count is ' || l_num_days);
             --dbms_output.put_line('balance is ' || l_loan_activities(p).ending_balance);
             l_balance_days := l_balance_days + l_num_days * l_loan_activities(p).ending_balance;

         end loop;
         -- this is the total days (denominator)
         l_total_Days := LNS_FIN_UTILS.getDayCount(p_start_date       => p_from_date
                                                  ,p_end_date         => p_to_date
                                                  ,p_day_count_method => l_loan_details.day_count_method);

         --dbms_output.put_line('total days is ' || l_total_Days );
         l_average_daily_balance := l_balance_days / l_total_days;
     end if;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_balance_days: ' || l_balance_days);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_total_balance: ' || l_total_days);
     --dbms_output.put_line('adb is ' || l_average_daily_balance);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_end_balance: ' || l_end_balance);
     return round(l_average_daily_balance, l_loan_details.currency_precision);

EXCEPTION

    When others Then
        return -1;
        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - ' || sqlerrm);


end getAverageDailyBalance;


function getAPR(p_loan_id     in number
               ,p_term_id     in number
               ,p_actual_flag in varchar2) return number
is

begin
           null;
           /*
    public static double RATE(double d, double d1, double d2)
    {
        double d3 = 1.0D;
        double d4 = 0.5D;
        double d5 = d1;
        if(d * d1 <= d2)
        {
            return 0.0D;
        }
        for(int i = 1; i < 50; i++)
        {
            double d6 = PMT(d3, d, d2);
            if(d6 == d1)
            {
                return d3;
            }
            if(d6 < d1)
            {
                d3 += d4;
            } else
            {
                d3 -= d4;
            }
            d4 /= 2D;
        }

        return d3;
    }
             */
end;


-- This procedure calculates normal interest
procedure CALC_NORM_INTEREST(p_loan_id               in  number,
                           p_calc_method           in  varchar2,
                           p_period_start_date     in  date,
                           p_period_end_date       in  date,
                           p_interest_rate         in  number,
                           p_day_count_method      in  varchar2,
                           p_payment_freq          in  varchar2,
                           p_compound_freq         in  varchar2,
                           p_adj_amount            in  number,
                           x_norm_interest         out NOCOPY number,
                           x_norm_int_details      out NOCOPY varchar2)
is
    l_api_name              varchar2(25);
    l_activity_date         date;
    l_activity_code         varchar2(30);
    l_activity_amount       number;
    l_theory_balance        number;
    l_actual_balance        number;
    l_days_late             number;
    l_display_order         number;
    l_rate                  number;
    l_day_count             number;
    i                       number;
    l_norm_prev_amount      number;
    l_norm_interest         number;
    l_norm_prev_act_date    date;
    l_cum_norm_interest     number;
    l_periodic_rate         number;
    l_norm_int_detail_str   varchar2(2000);

    cursor c_trx_activities(p_loan_id number, p_start_date date, p_end_date date) is
        select
        trunc(ACTIVITY_DATE),
        ACTIVITY_CODE,
        ACTIVITY_AMOUNT,
        THEORETICAL_BALANCE,
        ACTUAL_BALANCE,
        DAYS_LATE,
        display_order
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id and
        trunc(ACTIVITY_DATE) >= trunc(p_start_date) and
        trunc(ACTIVITY_DATE) <= trunc(p_end_date) and
        ACTIVITY_CODE in ('START', 'DUE', 'DISBURSEMENT', 'INVOICE_ADDED')
        order by activity_date, display_order, LOAN_AMORTIZATION_ID;

begin

    l_api_name  := 'CALC_NORM_INTEREST';
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Input:');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': loan_id: ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calc_method: ' || p_calc_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': start date: ' || p_period_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': end date: ' || p_period_end_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest rate: ' || p_interest_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': days count method: ' || p_day_count_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': compound frequency: ' || p_compound_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': payment frequency: ' || p_payment_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': adj amount: ' || p_adj_amount);

    -- calculating normal and additional interest
    i := 1;
    l_norm_interest := 0;
    l_cum_norm_interest := 0;
    l_norm_prev_amount := 0;
    l_norm_prev_act_date := p_period_start_date;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Querying trx history...');

    OPEN c_trx_activities(p_loan_id, p_period_start_date, p_period_end_date);
    LOOP

        FETCH c_trx_activities INTO
          l_activity_date
          ,l_activity_code
          ,l_activity_amount
          ,l_theory_balance
          ,l_actual_balance
          ,l_days_late
          ,l_display_order;

        EXIT WHEN c_trx_activities%NOTFOUND;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '--------- Record ' || i || '---------');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Act_Date  Act  Act_Amount   Theory_Bal  Actual_Bal  Days_Late');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_activity_date || '  ' || l_activity_code || '  ' || l_activity_amount || '  ' || l_theory_balance || '  ' || l_actual_balance || '  ' || l_days_late);

        -- normal interest
        if l_activity_code = 'DISBURSEMENT' or l_activity_code = 'INVOICE_ADDED' then
            l_norm_prev_amount := l_theory_balance - l_activity_amount - p_adj_amount;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating normal interest...');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period = ' || l_norm_prev_act_date || ' - ' || l_activity_date);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Amount = ' || l_norm_prev_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Rate = ' || p_interest_rate);

        if (p_calc_method = 'SIMPLE') then

            -- recalculate periodic rate for each period if day counting methodolgy varies

            l_periodic_rate := lns_financials.getPeriodicRate(
                                    p_payment_freq      => p_payment_freq
                                    ,p_period_start_date => l_norm_prev_act_date
                                    ,p_period_end_date   => l_activity_date
                                    ,p_annualized_rate   => p_interest_rate
                                    ,p_days_count_method => p_day_count_method
                                    ,p_target            => 'INTEREST');

        elsif (p_calc_method = 'COMPOUND') then

            l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => p_compound_freq
                            ,p_payment_freq => p_payment_freq
                            ,p_annualized_rate => p_interest_rate
                            ,p_period_start_date => l_norm_prev_act_date
                            ,p_period_end_date => l_activity_date
                            ,p_days_count_method => p_day_count_method
                            ,p_target => 'INTEREST');

        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_rate = ' || l_periodic_rate);

        l_norm_interest := lns_financials.calculateInterest(p_amount => l_norm_prev_amount
                                                    ,p_periodic_rate => l_periodic_rate
                                                    ,p_compounding_period => null);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'normal interest = ' || l_norm_interest);

        if trunc(l_norm_prev_act_date) <> trunc(l_activity_date) then
            if l_norm_int_detail_str is not null then
                l_norm_int_detail_str := l_norm_int_detail_str || ' +<br>';
            end if;
            l_norm_int_detail_str := l_norm_int_detail_str ||
                'Period: ' || l_norm_prev_act_date || ' - ' || (l_activity_date-1) ||
                ' * Balance: ' || l_norm_prev_amount ||
                ' * Rate: ' || p_interest_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);
        end if;

        l_cum_norm_interest := l_cum_norm_interest + l_norm_interest;
        if l_activity_code = 'DISBURSEMENT' or l_activity_code = 'INVOICE_ADDED' then
            l_norm_prev_amount := l_theory_balance - p_adj_amount;
        else
            l_norm_prev_amount := l_theory_balance;
        end if;
        l_norm_prev_act_date := l_activity_date;
        i := i + 1;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'cumulative normal interest = ' || l_cum_norm_interest);

    END LOOP;
    close c_trx_activities;

    -- manually adding last record for p_period_end_date date
    l_activity_date := p_period_end_date;
    l_activity_code := 'DUE';
    l_activity_amount := 0;
    l_days_late := 0;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '--------- Record ' || i || '---------');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Act_Date  Act  Act_Amount   Theory_Bal  Actual_Bal  Days_Late');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '*' || l_activity_date || '  ' || l_activity_code || '  ' || l_activity_amount || '  ' || l_theory_balance || '  ' || l_actual_balance || '  ' || l_days_late);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating normal interest...');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period = ' || l_norm_prev_act_date || ' - *' || l_activity_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Amount = ' || l_norm_prev_amount);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Rate = ' || p_interest_rate);

    -- normal interest
    if (p_calc_method = 'SIMPLE') then

        -- recalculate periodic rate for each period if day counting methodolgy varies

        l_periodic_rate := lns_financials.getPeriodicRate(
                                p_payment_freq      => p_payment_freq
                                ,p_period_start_date => l_norm_prev_act_date
                                ,p_period_end_date   => l_activity_date
                                ,p_annualized_rate   => p_interest_rate
                                ,p_days_count_method => p_day_count_method
                                ,p_target            => 'INTEREST');
    elsif (p_calc_method = 'COMPOUND') then

        l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => p_compound_freq
                        ,p_payment_freq => p_payment_freq
                        ,p_annualized_rate => p_interest_rate
                        ,p_period_start_date => l_norm_prev_act_date
                        ,p_period_end_date => l_activity_date
                        ,p_days_count_method => p_day_count_method
                        ,p_target => 'INTEREST');

    end if;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_rate = ' || l_periodic_rate);

    l_norm_interest := lns_financials.calculateInterest(p_amount => l_norm_prev_amount
                                                ,p_periodic_rate => l_periodic_rate
                                                ,p_compounding_period => null);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'normal interest = ' || l_norm_interest);

    if trunc(l_norm_prev_act_date) <> trunc(l_activity_date) then
        if l_norm_int_detail_str is not null then
            l_norm_int_detail_str := l_norm_int_detail_str || ' +<br>';
        end if;
        l_norm_int_detail_str := l_norm_int_detail_str ||
            'Period: ' || l_norm_prev_act_date || ' - ' || (l_activity_date-1) ||
            ' * Balance: ' || l_norm_prev_amount ||
            ' * Rate: ' || p_interest_rate || '%';
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_norm_int_detail_str);
    end if;

    l_cum_norm_interest := l_cum_norm_interest + l_norm_interest;

    x_norm_interest := l_cum_norm_interest;
    x_norm_int_details := l_norm_int_detail_str;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total Normal Interest = ' || x_norm_interest);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total Normal Interest Details = ' || x_norm_int_details);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

end;


-- This procedure calculates additional and penal interest
procedure CALC_ADD_INTEREST(p_loan_id               in  number,
                           p_calc_method           in  varchar2,
                           p_period_start_date     in  date,
                           p_period_end_date       in  date,
                           p_interest_rate         in  number,
                           p_day_count_method      in  varchar2,
                           p_payment_freq          in  varchar2,
                           p_compound_freq         in  varchar2,
                           p_penal_int_rate        in  number,
                           p_prev_grace_end_date   in  date,
                           p_grace_start_date      in  date,
                           p_grace_end_date        in  date,
                           p_target                in  varchar2,
                           x_add_interest          out NOCOPY number,
                           x_penal_interest        out NOCOPY number,
                           x_add_int_details       out NOCOPY varchar2,
                           x_penal_int_details     out NOCOPY varchar2)
is
    l_api_name              varchar2(25);
    l_activity_date         date;
    l_activity_code         varchar2(30);
    l_activity_amount       number;
    l_theory_balance        number;
    l_actual_balance        number;
    l_days_late             number;
    l_display_order         number;
    l_rate                  number;
    l_day_count             number;
    i                       number;
    l_add_prev_amount       number;
    l_add_interest          number;
    l_add_prev_act_date     date;
    l_cum_add_interest      number;
    l_periodic_rate         number;
    l_penal_interest        number;
    l_cum_penal_interest    number;
    l_penal_period_rate     number;
    l_interest_rate         number;
    l_first_act_after_grace boolean;
    l_first_act_after_prev_grace    boolean;
    l_add_int_setting       varchar2(1);
    l_add_int_detail_str    varchar2(2000);
    l_penal_int_detail_str  varchar2(2000);
    l_penal_prev_act_date   date;

    cursor c_trx_prin_activities(p_loan_id number, p_start_date date, p_end_date date) is
        select
        trunc(ACTIVITY_DATE),
        ACTIVITY_CODE,
        ACTIVITY_AMOUNT,
        INTEREST_RATE,
        THEORETICAL_BALANCE,
        ACTUAL_BALANCE,
        DAYS_LATE,
        display_order
        from LNS_PRIN_TRX_ACTIVITIES_V
        where loan_id = p_loan_id and
        trunc(ACTIVITY_DATE) >= trunc(p_start_date) and
        trunc(ACTIVITY_DATE) < trunc(p_end_date) and
        ACTIVITY_CODE not in ('DISBURSEMENT', 'INVOICE_ADDED')
        order by activity_date, display_order;

    cursor c_trx_int_activities(p_loan_id number, p_start_date date, p_end_date date) is
        select
        trunc(ACTIVITY_DATE),
        ACTIVITY_CODE,
        ACTIVITY_AMOUNT,
        INTEREST_RATE,
        THEORETICAL_BALANCE,
        ACTUAL_BALANCE,
        DAYS_LATE,
        display_order
        from LNS_INT_TRX_ACTIVITIES_V
        where loan_id = p_loan_id and
        trunc(ACTIVITY_DATE) >= trunc(p_start_date) and
        trunc(ACTIVITY_DATE) < trunc(p_end_date)
        order by activity_date, display_order;

    cursor c_add_int_setting(p_loan_id number, p_target varchar2) is
        select decode(p_target, 'UNPAID_PRIN', nvl(term.CALC_ADD_INT_UNPAID_PRIN, 'Y'), 'UNPAID_INT', nvl(term.CALC_ADD_INT_UNPAID_INT, 'Y'))
        from lns_loan_headers loan,
        lns_terms term
        where loan.loan_id = p_loan_id and
        loan.loan_id = term.loan_id;


begin

    l_api_name  := 'CALC_ADD_INTEREST';
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Input:');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': loan_id: ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': calc_method: ' || p_calc_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': start date: ' || p_period_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': end date: ' || p_period_end_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': interest rate: ' || p_interest_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': days count method: ' || p_day_count_method);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': compound frequency: ' || p_compound_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': payment frequency: ' || p_payment_freq);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': target: ' || p_target);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': penal_int_rate: ' || p_penal_int_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': prev_grace_end_date: ' || p_prev_grace_end_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': grace_start_date: ' || p_grace_start_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': grace_end_date: ' || p_grace_end_date);

    -- fix for bug 8609721
    OPEN c_add_int_setting(p_loan_id, p_target);
    FETCH c_add_int_setting INTO l_add_int_setting;
    CLOSE c_add_int_setting;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': l_add_int_setting = ' || l_add_int_setting);

    if l_add_int_setting = 'N' and p_penal_int_rate = 0 then  -- fix for bug 8609721
        x_add_interest := 0;
        x_penal_interest := 0;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Calculate additional interest is off and penal interest rate = 0');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': exiting');
        return;
    end if;

    if p_period_start_date > p_period_end_date then
        x_add_interest := 0;
        x_penal_interest := 0;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': x_add_interest: ' || x_add_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': x_add_interest: ' || x_add_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': exiting');
        return;
    end if;

    -- calculating normal and additional interest
    i := 1;
    l_add_interest := 0;
    l_cum_add_interest := 0;
    l_add_prev_amount := 0;
    l_add_prev_act_date := p_period_start_date;
    l_penal_interest := 0;
    l_cum_penal_interest := 0;
    l_interest_rate := 0;
    l_first_act_after_grace := true;
    l_first_act_after_prev_grace := true;
    l_penal_prev_act_date := p_grace_end_date;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Querying trx history...');

    if p_target = 'UNPAID_PRIN' then
        OPEN c_trx_prin_activities(p_loan_id, p_period_start_date, p_period_end_date);
    elsif p_target = 'UNPAID_INT' then
        OPEN c_trx_int_activities(p_loan_id, p_period_start_date, p_period_end_date);
    end if;

    LOOP

        l_add_interest := 0;
        l_penal_interest := 0;

        if p_target = 'UNPAID_PRIN' then
            FETCH c_trx_prin_activities INTO
                l_activity_date
                ,l_activity_code
                ,l_activity_amount
                ,l_interest_rate
                ,l_theory_balance
                ,l_actual_balance
                ,l_days_late
                ,l_display_order;

            EXIT WHEN c_trx_prin_activities%NOTFOUND;
        elsif p_target = 'UNPAID_INT' then
            FETCH c_trx_int_activities INTO
                l_activity_date
                ,l_activity_code
                ,l_activity_amount
                ,l_interest_rate
                ,l_theory_balance
                ,l_actual_balance
                ,l_days_late
                ,l_display_order;

            EXIT WHEN c_trx_int_activities%NOTFOUND;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '--------- Record ' || i || '---------');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Act_Date  Act  Act_Amount  Rate   Theory_Bal  Actual_Bal  Days_Late');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_activity_date || '  ' || l_activity_code || '  ' || l_activity_amount || '  ' || l_interest_rate || '  ' || l_theory_balance || '  ' || l_actual_balance || '  ' || l_days_late);

        if l_add_int_setting = 'Y' then  -- fix for bug 8609721

            -- additional interest
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating additional interest...');
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period = ' || l_add_prev_act_date || ' - ' || l_activity_date);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Amount = ' || l_add_prev_amount);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Rate = ' || p_interest_rate);

            if (p_calc_method = 'SIMPLE') then

                -- recalculate periodic rate for each period if day counting methodolgy varies

                l_periodic_rate := lns_financials.getPeriodicRate(
                                        p_payment_freq      => p_payment_freq
                                        ,p_period_start_date => l_add_prev_act_date
                                        ,p_period_end_date   => l_activity_date
                                        ,p_annualized_rate   => p_interest_rate
                                        ,p_days_count_method => p_day_count_method
                                        ,p_target            => 'INTEREST');

            elsif (p_calc_method = 'COMPOUND') then

                l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => p_compound_freq
                                ,p_payment_freq => p_payment_freq
                                ,p_annualized_rate => p_interest_rate
                                ,p_period_start_date => l_add_prev_act_date
                                ,p_period_end_date => l_activity_date
                                ,p_days_count_method => p_day_count_method
                                ,p_target => 'INTEREST');

            end if;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_rate = ' || l_periodic_rate);

            l_add_interest := lns_financials.calculateInterest(p_amount => l_add_prev_amount
                                                        ,p_periodic_rate => l_periodic_rate
                                                        ,p_compounding_period => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'additional interest = ' || l_add_interest);

            if trunc(l_add_prev_act_date) <> trunc(l_activity_date) then
                if l_add_int_detail_str is not null then
                    l_add_int_detail_str := l_add_int_detail_str || ' +<br>';
                end if;
                l_add_int_detail_str := l_add_int_detail_str ||
                    'Period: ' || l_add_prev_act_date || ' - ' || (l_activity_date-1) ||
                    ' * Balance: ' || l_add_prev_amount ||
                    ' * Rate: ' || p_interest_rate || '%';
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_add_int_detail_str);
            end if;

        end if;

        if p_penal_int_rate > 0 and
           ((trunc(l_activity_date) >= trunc(p_prev_grace_end_date) and trunc(l_activity_date) <= trunc(p_grace_start_date)) or
            (trunc(l_activity_date) > trunc(p_grace_end_date)))
        then

            if trunc(l_activity_date) > trunc(p_grace_end_date) and
               l_first_act_after_grace = true
              then
                l_add_prev_act_date := p_grace_start_date;
                l_first_act_after_grace := false;
            elsif trunc(l_activity_date) >= trunc(p_prev_grace_end_date) and
                  trunc(l_activity_date) <= trunc(p_grace_start_date) and
                  l_first_act_after_prev_grace = true
              then
                if trunc(p_prev_grace_end_date) < trunc(p_period_start_date) then
                    l_add_prev_act_date := p_period_start_date;
                else
                    l_add_prev_act_date := p_prev_grace_end_date;
                end if;
                l_first_act_after_prev_grace := false;
            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating penal interest...');
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period = ' || l_add_prev_act_date || ' - ' || l_activity_date);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Amount = ' || l_add_prev_amount);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Rate = ' || p_penal_int_rate);

            -- calc penal interest rate
            if (p_calc_method = 'SIMPLE') then

                l_penal_period_rate := lns_financials.getPeriodicRate(
                                        p_payment_freq      => p_payment_freq
                                        ,p_period_start_date => l_add_prev_act_date
                                        ,p_period_end_date   => l_activity_date
                                        ,p_annualized_rate   => p_penal_int_rate
                                        ,p_days_count_method => p_day_count_method
                                        ,p_target            => 'INTEREST');

            elsif (p_calc_method = 'COMPOUND') then

                l_penal_period_rate := getCompoundPeriodicRate(p_compound_freq => p_compound_freq
                                ,p_payment_freq => p_payment_freq
                                ,p_annualized_rate => p_penal_int_rate
                                ,p_period_start_date => l_add_prev_act_date
                                ,p_period_end_date => l_activity_date
                                ,p_days_count_method => p_day_count_method
                                ,p_target => 'INTEREST');

            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'penal periodic_rate = ' || l_penal_period_rate);

            l_penal_interest := lns_financials.calculateInterest(p_amount => l_add_prev_amount
                                                        ,p_periodic_rate => l_penal_period_rate
                                                        ,p_compounding_period => null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'penal interest = ' || l_penal_interest);

            if trunc(l_add_prev_act_date) <> trunc(l_activity_date) then
                if l_penal_int_detail_str is not null then
                    l_penal_int_detail_str := l_penal_int_detail_str || ' +<br>';
                end if;
                l_penal_int_detail_str := l_penal_int_detail_str ||
                    'Period: ' || l_add_prev_act_date || ' - ' || (l_activity_date-1) ||
                    ' * Balance: ' || l_add_prev_amount ||
                    ' * Rate: ' || p_penal_int_rate || '%';
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_penal_int_detail_str);
            end if;

        end if;

        l_cum_add_interest := l_cum_add_interest + l_add_interest;
        l_cum_penal_interest := l_cum_penal_interest + l_penal_interest;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'cumulative additional interest = ' || l_cum_add_interest);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'cumulative penal interest = ' || l_cum_penal_interest);

        if p_target = 'UNPAID_PRIN' then
            l_add_prev_amount := l_actual_balance - l_theory_balance;
        elsif p_target = 'UNPAID_INT' then
            l_add_prev_amount := l_theory_balance - l_actual_balance;
        end if;

        l_add_prev_act_date := l_activity_date;
        i := i + 1;

    END LOOP;
    if p_target = 'UNPAID_PRIN' then
        close c_trx_prin_activities;
    elsif p_target = 'UNPAID_INT' then
        close c_trx_int_activities;
    end if;

    -- manually adding last record for p_period_end_date date
    l_activity_date := p_period_end_date;
    l_activity_code := 'DUE';
    l_activity_amount := 0;
    l_days_late := 0;
    l_add_interest := 0;
    l_penal_interest := 0;
/*
    if p_interest_rate is not null then
        l_interest_rate := p_interest_rate;
    end if;
*/
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '--------- Record ' || i || '---------');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Act_Date  Act  Act_Amount  Rate  Theory_Bal  Actual_Bal  Days_Late');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '*' || l_activity_date || '  ' || l_activity_code || '  ' || l_activity_amount || '  ' || l_interest_rate || '  ' || l_theory_balance || '  ' || l_actual_balance || '  ' || l_days_late);

    if l_add_int_setting = 'Y' then   -- fix for bug 8609721

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating additional interest...');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period = ' || l_add_prev_act_date || ' - *' || l_activity_date);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Amount = ' || l_add_prev_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Rate = ' || p_interest_rate);

        -- additional interest
        if (p_calc_method = 'SIMPLE') then

            -- recalculate periodic rate for each period if day counting methodolgy varies

            l_periodic_rate := lns_financials.getPeriodicRate(
                                    p_payment_freq      => p_payment_freq
                                    ,p_period_start_date => l_add_prev_act_date
                                    ,p_period_end_date   => l_activity_date
                                    ,p_annualized_rate   => p_interest_rate
                                    ,p_days_count_method => p_day_count_method
                                    ,p_target            => 'INTEREST');

        elsif (p_calc_method = 'COMPOUND') then

            l_periodic_rate := getCompoundPeriodicRate(p_compound_freq => p_compound_freq
                            ,p_payment_freq => p_payment_freq
                            ,p_annualized_rate => p_interest_rate
                            ,p_period_start_date => l_add_prev_act_date
                            ,p_period_end_date => l_activity_date
                            ,p_days_count_method => p_day_count_method
                            ,p_target => 'INTEREST');

        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'periodic_rate = ' || l_periodic_rate);

        l_add_interest := lns_financials.calculateInterest(p_amount => l_add_prev_amount
                                                    ,p_periodic_rate => l_periodic_rate
                                                    ,p_compounding_period => null);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'additional interest = ' || l_add_interest);

        if trunc(l_add_prev_act_date) <> trunc(l_activity_date) then
            if l_add_int_detail_str is not null then
                l_add_int_detail_str := l_add_int_detail_str || ' +<br>';
            end if;
            l_add_int_detail_str := l_add_int_detail_str ||
                'Period: ' || l_add_prev_act_date || ' - ' || (l_activity_date-1) ||
                ' * Balance: ' || l_add_prev_amount ||
                ' * Rate: ' || p_interest_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_add_int_detail_str);
        end if;

    end if;

    if p_penal_int_rate > 0 and
    ((trunc(l_activity_date) >= trunc(p_prev_grace_end_date) and trunc(l_activity_date) <= trunc(p_grace_start_date)) or
        (trunc(l_activity_date) > trunc(p_grace_end_date)))
    then

        if trunc(l_activity_date) > trunc(p_grace_end_date) and
        l_first_act_after_grace = true
        then
            l_add_prev_act_date := p_grace_start_date;
            l_first_act_after_grace := false;
        elsif trunc(l_activity_date) >= trunc(p_prev_grace_end_date) and
            trunc(l_activity_date) <= trunc(p_grace_start_date) and
            l_first_act_after_prev_grace = true
        then
            if trunc(p_prev_grace_end_date) < trunc(p_period_start_date) then
                l_add_prev_act_date := p_period_start_date;
            else
                l_add_prev_act_date := p_prev_grace_end_date;
            end if;
            l_first_act_after_prev_grace := false;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calculating penal interest...');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Period = ' || l_add_prev_act_date || ' - *' || l_activity_date);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Amount = ' || l_add_prev_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Rate = ' || p_penal_int_rate);

        -- calc penal interest rate
        if (p_calc_method = 'SIMPLE') then

            l_penal_period_rate := lns_financials.getPeriodicRate(
                                    p_payment_freq      => p_payment_freq
                                    ,p_period_start_date => l_add_prev_act_date
                                    ,p_period_end_date   => l_activity_date
                                    ,p_annualized_rate   => p_penal_int_rate
                                    ,p_days_count_method => p_day_count_method
                                    ,p_target            => 'INTEREST');

        elsif (p_calc_method = 'COMPOUND') then

            l_penal_period_rate := getCompoundPeriodicRate(p_compound_freq => p_compound_freq
                            ,p_payment_freq => p_payment_freq
                            ,p_annualized_rate => p_penal_int_rate
                            ,p_period_start_date => l_add_prev_act_date
                            ,p_period_end_date => l_activity_date
                            ,p_days_count_method => p_day_count_method
                            ,p_target => 'INTEREST');

        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'penal periodic_rate = ' || l_penal_period_rate);

        l_penal_interest := lns_financials.calculateInterest(p_amount => l_add_prev_amount
                                                    ,p_periodic_rate => l_penal_period_rate
                                                    ,p_compounding_period => null);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'penal interest = ' || l_penal_interest);

        if trunc(l_add_prev_act_date) <> trunc(l_activity_date) then
            if l_penal_int_detail_str is not null then
                l_penal_int_detail_str := l_penal_int_detail_str || ' +<br>';
            end if;
            l_penal_int_detail_str := l_penal_int_detail_str ||
                'Period: ' || l_add_prev_act_date || ' - ' || (l_activity_date-1) ||
                ' * Balance: ' || l_add_prev_amount ||
                ' * Rate: ' || p_penal_int_rate || '%';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_penal_int_detail_str);
        end if;

    end if;

    l_cum_add_interest := l_cum_add_interest + l_add_interest;
    l_cum_penal_interest := l_cum_penal_interest + l_penal_interest;

    x_add_interest := l_cum_add_interest;
    x_penal_interest := l_cum_penal_interest;
    x_add_int_details := l_add_int_detail_str;
    x_penal_int_details := l_penal_int_detail_str;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total Additional Interest = ' || x_add_interest);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total Additional Interest Details = ' || x_add_int_details);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total Penal Interest = ' || x_penal_interest);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ': Total Penal Interest Details = ' || x_penal_int_details);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');

end;



procedure get_char2num_conv_chars(x_chars_to_replace out nocopy varchar2, x_replace_chars out nocopy varchar2)
is
    l_num number;
    l_str varchar2(10);
    l_char varchar2(1);
BEGIN

    l_num := 123.12;

    select to_char(l_num) into l_str from dual;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'number 123.12 => string ' || l_str);

    l_char := substr(l_str, 4, 1);
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'number . => char ' || l_char);

    x_chars_to_replace := ',.';
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_chars_to_replace = ' || x_chars_to_replace);
    x_replace_chars := l_char || l_char;
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_replace_chars = ' || x_replace_chars);

END;



-- this procedure loads original amortization schedule from agreement report
procedure LOAD_ORIGINAL_SCHEDULE(p_loan_details in LNS_FINANCIALS.LOAN_DETAILS_REC,
                                 x_loan_amort_tbl out nocopy LNS_FINANCIALS.AMORTIZATION_TBL)
is
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name              CONSTANT VARCHAR2(30) := 'LOAD_ORIGINAL_SCHEDULE';
    l_clob                  CLOB;
    l_parser                dbms_xmlparser.Parser;
    l_doc                   dbms_xmldom.DOMDocument;
    l_nl                    dbms_xmldom.DOMNodeList;
    l_n                     dbms_xmldom.DOMNode;
    i                       number;
    l_data                  varchar2(100);
    l_loan_id               number;
    l_period_start_date     date;
    l_replace_chars         varchar2(10);
    l_chars_to_replace      varchar2(10);
    l_adj                   number;

    l_amort_tbl             LNS_FINANCIALS.AMORTIZATION_TBL;
    l_rate_schedule         LNS_FINANCIALS.RATE_SCHEDULE_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR c_get_xml(p_loan_id NUMBER) IS
        SELECT DOCUMENT_XML
        FROM LNS_LOAN_DOCUMENTS
        WHERE source_id = p_loan_id and
        SOURCE_TABLE = 'LNS_LOAN_HEADERS_ALL' and
        DOCUMENT_TYPE = 'LOAN_AGREEMENT' AND
        VERSION = 1;

BEGIN

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    open c_get_xml(p_loan_details.LOAN_ID);
    fetch c_get_xml into l_clob;
    close c_get_xml;

    -- Create a parser.
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Creating a parser...');
    l_parser := dbms_xmlparser.newParser;

    -- Parse the document and create a new DOM document.
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Parsing the document and creating a new DOM document...');
    dbms_xmlparser.parseClob(l_parser, l_clob);
    l_doc := dbms_xmlparser.getDocument(l_parser);

    -- Free resources associated with the CLOB and Parser now they are no longer needed.
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Freeing resources...');
    dbms_xmlparser.freeParser(l_parser);

    get_char2num_conv_chars(l_chars_to_replace, l_replace_chars);

    -- Get a list of all the RATE_SCHEDULE_ROW nodes in the document using the XPATH syntax.
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Getting a list of all the RATE_SCHEDULE_ROW nodes...');
    l_nl := dbms_xslprocessor.selectNodes(dbms_xmldom.makeNode(l_doc),'/LNSAGREEMENT/ROWSET/ROW/RATE_SCHEDULE/RATE_SCHEDULE_ROW');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Rate schedule:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FROM   TO    RATE');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '----   ----  ----');

    i := 0;
    FOR cur_emp IN 0 .. dbms_xmldom.getLength(l_nl) - 1 LOOP
        l_n := dbms_xmldom.item(l_nl, cur_emp);
        i := i+1;

        dbms_xslprocessor.valueOf(l_n,'INSTALLMENT_FROM/text()',l_data);
        l_rate_schedule(i).BEGIN_INSTALLMENT_NUMBER := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));
        dbms_xslprocessor.valueOf(l_n,'INSTALLMENT_TO/text()',l_data);
        l_rate_schedule(i).END_INSTALLMENT_NUMBER := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));
        dbms_xslprocessor.valueOf(l_n,'INTEREST_RATE/text()',l_data);
        l_rate_schedule(i).ANNUAL_RATE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME,
                    l_rate_schedule(i).BEGIN_INSTALLMENT_NUMBER || '  ' ||
                    l_rate_schedule(i).END_INSTALLMENT_NUMBER || '  ' ||
                    l_rate_schedule(i).ANNUAL_RATE);
    END LOOP;

    -- Get a list of all the AMORTIZATION_ROW nodes in the document using the XPATH syntax.
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Getting a list of all the AMORTIZATION_ROW nodes...');
    l_nl := dbms_xslprocessor.selectNodes(dbms_xmldom.makeNode(l_doc),'/LNSAGREEMENT/ROWSET/ROW/AMORTIZATION/AMORTIZATION_ROW');

    -- Loop through the list and create a new record in a tble collection
    -- for each EMP record.

    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' ');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Original amortization schedule:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PN   DD       RATE  BB      PAY     PRIN    INT     FEE     OTHER   EB');
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '---  -------  ----  ------  ------  ------  ------  ------  ------  ------');

    i := 0;
    l_period_start_date := p_loan_details.LOAN_START_DATE;
    FOR cur_emp IN 0 .. dbms_xmldom.getLength(l_nl) - 1 LOOP
        l_n := dbms_xmldom.item(l_nl, cur_emp);
        i := i+1;

        -- Use XPATH syntax to assign values to he elements of the collection.
        dbms_xslprocessor.valueOf(l_n,'PAYMENT_NUMBER/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_NUMBER = ' || l_data);
        l_amort_tbl(i).INSTALLMENT_NUMBER := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'DUE_DATE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DUE_DATE = ' || l_data);
        l_amort_tbl(i).DUE_DATE := to_date(l_data,'MM/DD/YYYY');

        dbms_xslprocessor.valueOf(l_n,'PAYMENT_PRINCIPAL/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_PRINCIPAL = ' || l_data);
        l_amort_tbl(i).PRINCIPAL_AMOUNT := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'PAYMENT_INTEREST/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_INTEREST = ' || l_data);
        l_amort_tbl(i).INTEREST_AMOUNT := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'PAYMENT_FEES/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_FEES = ' || l_data);
        l_amort_tbl(i).FEE_AMOUNT := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'OTHER_AMOUNT/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'OTHER_AMOUNT = ' || l_data);
        l_amort_tbl(i).OTHER_AMOUNT := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'PAYMENT_TOTAL/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PAYMENT_TOTAL = ' || l_data);
        l_amort_tbl(i).TOTAL := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'BEGINNING_BALANCE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'BEGINNING_BALANCE = ' || l_data);
        l_amort_tbl(i).BEGIN_BALANCE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'ENDING_BALANCE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ENDING_BALANCE = ' || l_data);
        l_amort_tbl(i).END_BALANCE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'INTEREST_CUMULATIVE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'INTEREST_CUMULATIVE = ' || l_data);
        l_amort_tbl(i).INTEREST_CUMULATIVE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'PRINCIPAL_CUMULATIVE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PRINCIPAL_CUMULATIVE = ' || l_data);
        l_amort_tbl(i).PRINCIPAL_CUMULATIVE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'FEES_CUMULATIVE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'FEES_CUMULATIVE = ' || l_data);
        l_amort_tbl(i).FEES_CUMULATIVE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'OTHER_CUMULATIVE/text()',l_data);
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'OTHER_CUMULATIVE = ' || l_data);
        l_amort_tbl(i).OTHER_CUMULATIVE := to_number(nvl(translate(l_data, l_chars_to_replace, l_replace_chars), 0));

        dbms_xslprocessor.valueOf(l_n,'SOURCE/text()',l_data);
        l_amort_tbl(i).SOURCE := l_data;

        FOR j IN 1 .. l_rate_schedule.count LOOP
            if l_amort_tbl(i).INSTALLMENT_NUMBER >= l_rate_schedule(j).BEGIN_INSTALLMENT_NUMBER and
                l_amort_tbl(i).INSTALLMENT_NUMBER <= l_rate_schedule(j).END_INSTALLMENT_NUMBER
            then
                l_amort_tbl(i).INTEREST_RATE := l_rate_schedule(j).ANNUAL_RATE;
                exit;
            end if;
        END LOOP;

        l_amort_tbl(i).PERIOD_START_DATE    := l_period_start_date;
        l_amort_tbl(i).PERIOD_END_DATE      := l_amort_tbl(i).DUE_DATE;
        l_amort_tbl(i).UNPAID_PRIN          := 0;
        l_amort_tbl(i).UNPAID_INT           := 0;
        l_amort_tbl(i).NORMAL_INT_AMOUNT    := l_amort_tbl(i).INTEREST_AMOUNT;
        l_amort_tbl(i).ADD_PRIN_INT_AMOUNT  := 0;
        l_amort_tbl(i).ADD_INT_INT_AMOUNT   := 0;
        l_amort_tbl(i).PENAL_INT_AMOUNT     := 0;

        if l_amort_tbl(i).INSTALLMENT_NUMBER = 0 then
            l_amort_tbl(i).INTEREST_RATE := l_rate_schedule(1).ANNUAL_RATE;
            l_amort_tbl(i).PERIOD := l_period_start_date || ' - ' || l_period_start_date;
        else
            l_amort_tbl(i).PERIOD := l_period_start_date || ' - ' || (l_amort_tbl(i).DUE_DATE-1);
        end if;

        if l_amort_tbl(i).INSTALLMENT_NUMBER = 0 or l_amort_tbl(i).INSTALLMENT_NUMBER = 1 then
            l_adj := 0;
        else
            l_adj := l_amort_tbl(i-1).END_BALANCE;
        end if;
        l_amort_tbl(i).DISBURSEMENT_AMOUNT  :=
            abs(l_amort_tbl(i).BEGIN_BALANCE - l_amort_tbl(i).END_BALANCE - l_amort_tbl(i).PRINCIPAL_AMOUNT) +
            (l_amort_tbl(i).BEGIN_BALANCE - l_adj);

        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME,
                    l_amort_tbl(i).INSTALLMENT_NUMBER || '  ' ||
                    l_amort_tbl(i).DUE_DATE || '  ' ||
                    l_amort_tbl(i).INTEREST_RATE || '  ' ||
                    l_amort_tbl(i).BEGIN_BALANCE  || '  ' ||
                    l_amort_tbl(i).TOTAL || '  ' ||
                    l_amort_tbl(i).PRINCIPAL_AMOUNT || '  ' ||
                    l_amort_tbl(i).INTEREST_AMOUNT  || '  ' ||
                    l_amort_tbl(i).FEE_AMOUNT  || '  ' ||
                    l_amort_tbl(i).OTHER_AMOUNT  || '  ' ||
                    l_amort_tbl(i).END_BALANCE);

        l_period_start_date := l_amort_tbl(i).PERIOD_END_DATE;

    END LOOP;

    -- Free any resources associated with the document now it
    -- is no longer needed.
    LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Freeing resources...');
    dbms_xmldom.freeDocument(l_doc);
    dbms_xmlparser.freeParser(l_parser);

    x_loan_amort_tbl := l_amort_tbl;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, ' - in exception. Error: ' || sqlerrm);
        --dbms_lob.freetemporary(l_clob);
        dbms_xmlparser.freeParser(l_parser);
        dbms_xmldom.freeDocument(l_doc);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,sqlerrm);
        FND_MSG_PUB.Add;
END;


END LNS_FINANCIALS;

/
