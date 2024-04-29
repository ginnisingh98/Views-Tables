--------------------------------------------------------
--  DDL for Package Body LNS_INDEX_RATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_INDEX_RATES_PUB" as
/* $Header: LNS_FLOATRATE_B.pls 120.0.12010000.5 2009/08/14 16:15:37 scherkas noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_INDEX_RATES_PUB';

    TYPE LOAN_REC is record(LOAN_ID                 NUMBER,
                            TERM_ID                 NUMBER,
                            LOAN_NUMBER             VARCHAR2(60),
                            LAST_BILLED_INSTALLMENT NUMBER,
                            LOAN_STATUS             VARCHAR2(30),
                            CURRENT_PHASE           VARCHAR2(30),
                            percent_increase        NUMBER,
                            percent_increase_life   NUMBER,
                            floor_rate              NUMBER,
                            ceiling_rate            NUMBER
                            );

    TYPE RATE_LINE_REC is record(INTEREST_RATE_LINE_ID     NUMBER,
                                 INTEREST_RATE_ID          NUMBER,
                                 INTEREST_RATE             NUMBER,
                                 START_DATE_ACTIVE         DATE,
                                 END_DATE_ACTIVE           DATE
                                 );
    TYPE RATE_LINES_TBL is table of RATE_LINE_REC index by binary_integer;

    TYPE RATE_SCHED_REC is record(RATE_ID                     NUMBER,
                                TERM_ID                     NUMBER,
                                BEGIN_INSTALLMENT_NUMBER    NUMBER,
                                END_INSTALLMENT_NUMBER      NUMBER,
                                INDEX_RATE                  NUMBER,
                                SPREAD                      NUMBER,
                                CURRENT_INTEREST_RATE       NUMBER,
                                INTEREST_ONLY_FLAG          VARCHAR2(1),
                                ACTION                      VARCHAR2(20),
                                BEGIN_DATE                  DATE,
                                END_DATE                    DATE
                                );
    TYPE RATE_SCHEDS_TBL is table of RATE_SCHED_REC index by binary_integer;

    TYPE ADJ_RATE_REC is record(FROM_INSTALLMENT          NUMBER,
                                TO_INSTALLMENT            NUMBER,
                                INTEREST_RATE             NUMBER,
                                START_DATE                DATE,
                                END_DATE                  DATE
                                );
    TYPE ADJ_RATES_TBL is table of ADJ_RATE_REC index by binary_integer;

    TYPE RATE_SCHED_LINE_REC is record(BEGIN_DATE               DATE,
                                       END_DATE                DATE,
                                       INDEX_RATE              NUMBER,
                                       SPREAD                  NUMBER,
                                       CURRENT_INTEREST_RATE   NUMBER
                                       );
    TYPE RATE_SCHED_LINES_TBL is table of RATE_SCHED_LINE_REC index by binary_integer;

/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      UPDATE_FLOATING_RATE_LOANS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-01-2004            scherkas          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

    end if;

	if (FND_GLOBAL.Conc_Request_Id is not null) then
		fnd_file.put_line(FND_FILE.LOG, p_msg);
	end if;

EXCEPTION
    WHEN OTHERS THEN
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'ERROR in LogMessage while logging '|| p_msg || ' : ' || sqlerrm);
		end if;
END;



function dateToPayNum(P_PAYMENT_SCHEDULE in LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL
                     ,p_date in date) return number
is
    l_num_installments  number;
    l_pay_num           number;
begin

    l_num_installments := P_PAYMENT_SCHEDULE.count;

    if trunc(p_date) < trunc(P_PAYMENT_SCHEDULE(1).PERIOD_BEGIN_DATE) then
        l_pay_num := 1;
    elsif trunc(p_date) > trunc(P_PAYMENT_SCHEDULE(l_num_installments).PERIOD_END_DATE) then
        l_pay_num := l_num_installments+1;
    else
        for i in 1..l_num_installments loop
            if trunc(p_date) > trunc(P_PAYMENT_SCHEDULE(i).PERIOD_BEGIN_DATE) and
               trunc(p_date) <= trunc(P_PAYMENT_SCHEDULE(i).PERIOD_END_DATE)
            then
                l_pay_num := i+1;
                exit;
            elsif trunc(p_date) = trunc(P_PAYMENT_SCHEDULE(i).PERIOD_BEGIN_DATE) then
                l_pay_num := i;
                exit;
            end if;
        end loop;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, 'Date ' || p_date || ' = payment ' || l_pay_num);
    return l_pay_num;

end;



function payNumToDate(P_PAYMENT_SCHEDULE in LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL
                     ,p_installment in number
                     ,p_target in varchar2) return date
is
    l_num_installments  number;
    l_return_date       date;
begin

    l_num_installments := P_PAYMENT_SCHEDULE.count;

    for i in 1..l_num_installments loop
        if p_installment = i then
            if p_target = 'BEGIN' then
                l_return_date := P_PAYMENT_SCHEDULE(i).PERIOD_BEGIN_DATE;
            elsif p_target = 'END' then
                l_return_date := P_PAYMENT_SCHEDULE(i).PERIOD_END_DATE;
            end if;
            exit;
        end if;
    end loop;

--    logMessage(FND_LOG.LEVEL_STATEMENT, p_target || ' of installment ' || p_installment || ' = ' || l_return_date);
    return l_return_date;

end;



-- This procedure adjust interest rate based on provided rules
procedure adjustInterestRate(p_initial_rate            in number
                            ,p_last_period_rate        in number
                            ,p_max_period_adjustment   in number
                            ,p_max_lifetime_adjustment in number
                            ,p_ceiling_rate            in number
                            ,p_floor_rate              in number
                            ,x_interest_rate           in out nocopy number
                            ,x_adjustment_reason       out nocopy varchar2)

is
    l_api_name                      CONSTANT VARCHAR2(30) := 'adjustInterestRate';
    l_new_rate              number;
    l_rate_diff             number;
    l_life_rate_diff        number;
    l_sign1                 number;
    l_sign2                 number;
    l_adjustment_reason     varchar2(256);
    l_new_rate1             number;
    l_new_line              CONSTANT VARCHAR2(1) := '
';

begin

    logMessage(FND_LOG.LEVEL_PROCEDURE, l_api_name || ' +');

    logMessage(FND_LOG.LEVEL_STATEMENT, 'Input parameters:');
    logMessage(FND_LOG.LEVEL_STATEMENT, 'p_initial_rate = ' || p_initial_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'p_last_period_rate = ' || p_last_period_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'p_max_period_adjustment = ' || p_max_period_adjustment);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'p_max_lifetime_adjustment = ' || p_max_lifetime_adjustment);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'p_ceiling_rate = ' || p_ceiling_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'p_floor_rate = ' || p_floor_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'x_interest_rate = ' || x_interest_rate);

    -- need to check for NULLs
    l_sign1          := 1;
    l_sign2          := 1;

    l_new_rate := x_interest_rate;

    l_rate_diff := ABS(l_new_rate - p_last_period_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'l_rate_diff = ' || l_rate_diff);

    -- rate differentials go both ways
    if l_new_rate < p_last_period_rate then
        l_sign1 := -1;
    end if;

    if p_max_period_adjustment is not null and l_rate_diff > p_max_period_adjustment then
        l_new_rate1 := l_new_rate;
        l_new_rate := p_last_period_rate + (p_max_period_adjustment * l_sign1);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'l_new_rate = ' || l_new_rate);
        l_adjustment_reason :=
            'Difference between previous period rate ' || p_last_period_rate ||
            '% and new rate ' || l_new_rate1 || '% is greater than max period adjustment differential of ' || p_max_period_adjustment ||
            '%. Adjusting new rate to ' || l_new_rate || '%.';
        logMessage(FND_LOG.LEVEL_STATEMENT, l_adjustment_reason);
    end if;

    l_life_rate_diff := ABS(l_new_rate - p_initial_rate);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'l_life_rate_diff = ' || l_life_rate_diff);

    -- rate differentials go both ways
    if l_new_rate < p_initial_rate then
        l_sign2 := -1;
    end if;

    if p_max_lifetime_adjustment is not null and l_life_rate_diff > p_max_lifetime_adjustment then
        l_new_rate1 := l_new_rate;
        l_new_rate := p_initial_rate + (p_max_lifetime_adjustment * l_sign2);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'l_new_rate = ' || l_new_rate);

        if l_adjustment_reason is not null then
            l_adjustment_reason := l_adjustment_reason || l_new_line;
        end if;
        l_adjustment_reason := l_adjustment_reason ||
            'Difference between initial rate ' || p_initial_rate ||
            '% and new rate ' || l_new_rate1 || '% is greater than life adjustment differential of ' || p_max_lifetime_adjustment ||
            '. Adjusting new rate to ' || l_new_rate || '%.';
        logMessage(FND_LOG.LEVEL_STATEMENT, l_adjustment_reason);
    end if;

    if p_floor_rate is not null and l_new_rate < p_floor_rate then
        l_new_rate1 := l_new_rate;
        l_new_rate := p_floor_rate;
        logMessage(FND_LOG.LEVEL_STATEMENT, 'l_new_rate = ' || l_new_rate);

        if l_adjustment_reason is not null then
            l_adjustment_reason := l_adjustment_reason || l_new_line;
        end if;
        l_adjustment_reason := l_adjustment_reason ||
            'New rate ' || l_new_rate1 || '% is below floor of ' || p_floor_rate ||
            '. Adjusting new rate to ' || l_new_rate || '%.';
        logMessage(FND_LOG.LEVEL_STATEMENT, l_adjustment_reason);
    end if;

    if p_ceiling_rate is not null and l_new_rate > p_ceiling_rate then
        l_new_rate1 := l_new_rate;
        l_new_rate := p_ceiling_rate;
        logMessage(FND_LOG.LEVEL_STATEMENT, 'l_new_rate = ' || l_new_rate);

        if l_adjustment_reason is not null then
            l_adjustment_reason := l_adjustment_reason || l_new_line;
        end if;
        l_adjustment_reason := l_adjustment_reason ||
            'New rate ' || l_new_rate1 || '% is above ceiling of ' || p_ceiling_rate ||
            '. Adjusting new rate to ' || l_new_rate || '%.';
        logMessage(FND_LOG.LEVEL_STATEMENT, l_adjustment_reason);
    end if;

    logMessage(FND_LOG.LEVEL_PROCEDURE, 'l_new_rate = ' || l_new_rate);
    logMessage(FND_LOG.LEVEL_PROCEDURE, l_api_name || ' -');

    x_interest_rate := l_new_rate;
    x_adjustment_reason := l_adjustment_reason;

end;




PROCEDURE PROCESS_SINGLE_LOAN(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_REC              IN          LOAN_REC,
    P_RATE_LINES_TBL        IN          RATE_LINES_TBL,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'PROCESS_SINGLE_LOAN';
    l_api_version                   CONSTANT NUMBER := 1.0;
    i                               number;
    j                               number;
    y                               number;
    l_rates_count                   number;
    l_temp_pay_num                  number;
    l_rate_sched_from               number;
    l_rate_sched_to                 number;
    l_index_from                    number;
    l_index_to                      number;
    l_rate_sched_rate               number;
    l_prev_spead                    number;
    l_prev_io                       varchar2(1);
    rate_sched_count                number;
    index_rate_count                number;
    merged_count                    number;
    l_index_rate                    number;
    l_last_period_rate              NUMBER;
    l_initial_int_rate              NUMBER;
    l_start_from_installment        NUMBER;
    l_update1                       boolean;
    l_adjustment_reason             varchar2(256);
    l_start                         number;
    l_do_insert                     boolean;

    l_RATE_LINES_TBL                RATE_LINES_TBL;
    l_RATE_LINE_REC                 RATE_LINE_REC;
    l_RATE_SCHED_REC                RATE_SCHED_REC;
    l_RATE_SCHEDS_TBL               RATE_SCHEDS_TBL;
    l_pay_schedule                  LNS_FIN_UTILS.PAYMENT_SCHEDULE_TBL;
    l_ADJ_RATES_TBL                 ADJ_RATES_TBL;
    l_TEMP_ADJ_RATES_TBL            ADJ_RATES_TBL;
    l_merged_rates_tbl              RATE_SCHEDS_TBL;
    l_merged_rate_lines_tbl         RATE_SCHED_LINES_TBL;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR c_get_rate_sch_info(termId NUMBER, p_phase VARCHAR2) IS
        SELECT rate_id,
            begin_installment_number,
            end_installment_number,
            index_rate,
            spread,
            CURRENT_INTEREST_RATE,
            INTEREST_ONLY_FLAG
        FROM lns_rate_schedules
        WHERE end_date_active IS NULL
            AND term_id = termId
            AND PHASE = p_phase
        order by begin_installment_number;

BEGIN
    LogMessage(FND_LOG.level_unexpected, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT PROCESS_SINGLE_LOAN;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

    -- init
    l_RATE_LINES_TBL := P_RATE_LINES_TBL;
    l_rates_count := l_RATE_LINES_TBL.count;

    LogMessage(FND_LOG.level_unexpected, 'Processing loan ' || P_LOAN_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.level_unexpected, 'loan_id = ' || P_LOAN_REC.LOAN_ID);
    LogMessage(FND_LOG.level_unexpected, 'term_id = ' || P_LOAN_REC.TERM_ID);
    LogMessage(FND_LOG.level_unexpected, 'last_billed_installment = ' || P_LOAN_REC.LAST_BILLED_INSTALLMENT);
    LogMessage(FND_LOG.level_unexpected, 'loan_status = ' || P_LOAN_REC.LOAN_STATUS);
    LogMessage(FND_LOG.level_unexpected, 'CURRENT_PHASE = ' || P_LOAN_REC.CURRENT_PHASE);
    LogMessage(FND_LOG.level_unexpected, 'percent_increase = ' || P_LOAN_REC.percent_increase);
    LogMessage(FND_LOG.level_unexpected, 'percent_increase_life = ' || P_LOAN_REC.percent_increase_life);
    LogMessage(FND_LOG.level_unexpected, 'floor_rate = ' || P_LOAN_REC.floor_rate);
    LogMessage(FND_LOG.level_unexpected, 'ceiling_rate = ' || P_LOAN_REC.ceiling_rate);

    l_start_from_installment := P_LOAN_REC.LAST_BILLED_INSTALLMENT + 1;
    LogMessage(FND_LOG.level_unexpected, 'l_start_from_installment = ' || l_start_from_installment);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Calling LNS_FIN_UTILS.buildPaymentScheduleExt...');
    l_pay_schedule := LNS_FIN_UTILS.buildPaymentScheduleExt(P_LOAN_REC.LOAN_ID, P_LOAN_REC.CURRENT_PHASE);

    i := 0;
    l_RATE_SCHEDS_TBL.delete;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Current loan rate schedule:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'From_date   To_Date   From_Inst   To_Inst   Rate+Spread=Current_Rate   IO   Rate_sched_id');
    LogMessage(FND_LOG.LEVEL_STATEMENT, '---------   -------   ---------   -------   ------------------------   --   -------------');
    open c_get_rate_sch_info(P_LOAN_REC.TERM_ID, P_LOAN_REC.CURRENT_PHASE);
    LOOP

        fetch c_get_rate_sch_info into
            l_RATE_SCHED_REC.RATE_ID,
            l_RATE_SCHED_REC.BEGIN_INSTALLMENT_NUMBER,
            l_RATE_SCHED_REC.END_INSTALLMENT_NUMBER,
            l_RATE_SCHED_REC.INDEX_RATE,
            l_RATE_SCHED_REC.SPREAD,
            l_RATE_SCHED_REC.CURRENT_INTEREST_RATE,
            l_RATE_SCHED_REC.INTEREST_ONLY_FLAG;
        exit when c_get_rate_sch_info%NOTFOUND;

        i := i + 1;
        l_RATE_SCHEDS_TBL(i) := l_RATE_SCHED_REC;

        l_RATE_SCHEDS_TBL(i).BEGIN_DATE := payNumToDate(l_pay_schedule,
                                                             l_RATE_SCHEDS_TBL(i).BEGIN_INSTALLMENT_NUMBER,
                                                             'BEGIN');
        l_RATE_SCHEDS_TBL(i).END_DATE := payNumToDate(l_pay_schedule,
                                                             l_RATE_SCHEDS_TBL(i).END_INSTALLMENT_NUMBER,
                                                             'END');

        LogMessage(FND_LOG.LEVEL_STATEMENT,
            l_RATE_SCHEDS_TBL(i).BEGIN_DATE || '   ' ||
            l_RATE_SCHEDS_TBL(i).END_DATE || '   ' ||
            l_RATE_SCHEDS_TBL(i).BEGIN_INSTALLMENT_NUMBER || '   ' ||
            l_RATE_SCHEDS_TBL(i).END_INSTALLMENT_NUMBER || '   ' ||
            l_RATE_SCHEDS_TBL(i).INDEX_RATE || ' + ' || l_RATE_SCHEDS_TBL(i).SPREAD || ' = ' || l_RATE_SCHEDS_TBL(i).CURRENT_INTEREST_RATE || '   ' ||
            l_RATE_SCHEDS_TBL(i).INTEREST_ONLY_FLAG || '   ' ||
            l_RATE_SCHEDS_TBL(i).RATE_ID);

        if l_RATE_SCHED_REC.BEGIN_INSTALLMENT_NUMBER = 1 then
            l_initial_int_rate := l_RATE_SCHED_REC.CURRENT_INTEREST_RATE;
        end if;

    END LOOP;
    close c_get_rate_sch_info;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adjusting index rate lines for this loan...');
    l_TEMP_ADJ_RATES_TBL.delete;
    y := 0;
    for k in 1..l_rates_count loop
        l_temp_pay_num := dateToPayNum(l_pay_schedule, l_RATE_LINES_TBL(k).START_DATE_ACTIVE);
        if l_temp_pay_num <= l_pay_schedule.count then
            if y = 0 or l_TEMP_ADJ_RATES_TBL(y).FROM_INSTALLMENT <> l_temp_pay_num then
                y := y + 1;
            end if;
            l_TEMP_ADJ_RATES_TBL(y).FROM_INSTALLMENT := l_temp_pay_num;
            l_TEMP_ADJ_RATES_TBL(y).INTEREST_RATE := l_RATE_LINES_TBL(k).INTEREST_RATE;
            l_TEMP_ADJ_RATES_TBL(y).START_DATE := l_RATE_LINES_TBL(k).START_DATE_ACTIVE;
            l_TEMP_ADJ_RATES_TBL(y).END_DATE := l_RATE_LINES_TBL(k).END_DATE_ACTIVE;
        end if;
        if y > 1 then
            l_TEMP_ADJ_RATES_TBL(y-1).TO_INSTALLMENT := l_TEMP_ADJ_RATES_TBL(y).FROM_INSTALLMENT - 1;
        end if;
    end loop;
    if y > 0 then
        l_TEMP_ADJ_RATES_TBL(y).TO_INSTALLMENT := l_RATE_SCHEDS_TBL(i).END_INSTALLMENT_NUMBER;
    end if;

    l_ADJ_RATES_TBL.delete;
    i := 0;
    for k in 1..l_TEMP_ADJ_RATES_TBL.count loop
        if l_start_from_installment between l_TEMP_ADJ_RATES_TBL(k).FROM_INSTALLMENT and l_TEMP_ADJ_RATES_TBL(k).TO_INSTALLMENT then
            i := i + 1;
            l_ADJ_RATES_TBL(i) := l_TEMP_ADJ_RATES_TBL(k);
            l_ADJ_RATES_TBL(i).FROM_INSTALLMENT := l_start_from_installment;
        elsif l_TEMP_ADJ_RATES_TBL(k).FROM_INSTALLMENT > l_start_from_installment then
            i := i + 1;
            l_ADJ_RATES_TBL(i) := l_TEMP_ADJ_RATES_TBL(k);
        end if;
    end loop;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adjusted index rate lines:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'From   To    Rate');
    LogMessage(FND_LOG.LEVEL_STATEMENT, '----   ---   ----');
    for k in 1..l_ADJ_RATES_TBL.count loop
        LogMessage(FND_LOG.LEVEL_STATEMENT, l_ADJ_RATES_TBL(k).FROM_INSTALLMENT || '    ' || l_ADJ_RATES_TBL(k).TO_INSTALLMENT || '    ' || l_ADJ_RATES_TBL(k).INTEREST_RATE);
    end loop;

    if l_ADJ_RATES_TBL.count = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Adjusted index rate table is empty. Nothing to Merge. Exiting.');
        return;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Merging rate schedule with adjusted index rate lines...');

    rate_sched_count := 1;
    index_rate_count := 1;
    merged_count := 1;
    l_update1 := true;

    loop

        l_rate_sched_from := null;
        l_rate_sched_to := null;
        l_index_from := null;
        l_index_to := null;

        if (rate_sched_count <= l_RATE_SCHEDS_TBL.count) then
            l_rate_sched_from := l_RATE_SCHEDS_TBL(rate_sched_count).BEGIN_INSTALLMENT_NUMBER;
            l_rate_sched_to := l_RATE_SCHEDS_TBL(rate_sched_count).END_INSTALLMENT_NUMBER;
            l_rate_sched_rate := l_RATE_SCHEDS_TBL(rate_sched_count).INDEX_RATE;
        else
            l_rate_sched_rate := 0;
        end if;

        if (l_ADJ_RATES_TBL.count = 0) then
            l_index_rate := 0;
        elsif (index_rate_count <= l_ADJ_RATES_TBL.count) then
            l_index_from := l_ADJ_RATES_TBL(index_rate_count).FROM_INSTALLMENT;
            l_index_to := l_ADJ_RATES_TBL(index_rate_count).TO_INSTALLMENT;
            l_index_rate := l_ADJ_RATES_TBL(index_rate_count).INTEREST_RATE;
        else
            l_index_rate := l_ADJ_RATES_TBL(l_ADJ_RATES_TBL.count).INTEREST_RATE;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, '---------------');
        logMessage(FND_LOG.LEVEL_STATEMENT, 'Loop ' || merged_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'rate_sched_count = ' || rate_sched_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'index_rate_count = ' || index_rate_count);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'rate_sched: ' || l_rate_sched_from || ' - ' || l_rate_sched_to);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'index: ' || l_index_from || ' - ' || l_index_to);

        if (l_rate_sched_from is not null and l_rate_sched_to is not null and
            l_index_from is not null and l_index_from is not null)
        then

            if (l_rate_sched_from between l_index_from and l_index_to) then

                if l_rate_sched_to > l_index_to then

                    logMessage(FND_LOG.LEVEL_STATEMENT, 'if 1 - updating');
                    l_merged_rates_tbl(merged_count) := l_RATE_SCHEDS_TBL(rate_sched_count);
                    l_merged_rates_tbl(merged_count).END_INSTALLMENT_NUMBER := l_index_to;
                    l_merged_rates_tbl(merged_count).INDEX_RATE := l_index_rate;
                    l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE := l_index_rate + nvl(l_merged_rates_tbl(merged_count).SPREAD, 0);
                    l_merged_rates_tbl(merged_count).ACTION := 'UPDATE';
                    l_update1 := false;
                    index_rate_count := index_rate_count + 1;

                elsif l_rate_sched_to < l_index_to then

                    l_merged_rates_tbl(merged_count) := l_RATE_SCHEDS_TBL(rate_sched_count);

                    if l_RATE_SCHEDS_TBL(rate_sched_count).INDEX_RATE = l_index_rate then

                        logMessage(FND_LOG.LEVEL_STATEMENT, 'if 21 - skipping');
                        l_merged_rates_tbl(merged_count).ACTION := 'SKIP';

                    else

                        logMessage(FND_LOG.LEVEL_STATEMENT, 'if 22 - updating');
                        l_merged_rates_tbl(merged_count).INDEX_RATE := l_index_rate;
                        l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE := l_index_rate + nvl(l_merged_rates_tbl(merged_count).SPREAD, 0);
                        l_merged_rates_tbl(merged_count).ACTION := 'UPDATE';

                    end if;
                    rate_sched_count := rate_sched_count + 1;

                else  -- l_rate_sched_to = l_index_to

                    l_merged_rates_tbl(merged_count) := l_RATE_SCHEDS_TBL(rate_sched_count);

                    if l_RATE_SCHEDS_TBL(rate_sched_count).INDEX_RATE = l_index_rate then

                        logMessage(FND_LOG.LEVEL_STATEMENT, 'if 31 - skipping');
                        l_merged_rates_tbl(merged_count).ACTION := 'SKIP';

                    else

                        logMessage(FND_LOG.LEVEL_STATEMENT, 'if 32 - updating');
                        l_merged_rates_tbl(merged_count).INDEX_RATE := l_index_rate;
                        l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE := l_index_rate + nvl(l_merged_rates_tbl(merged_count).SPREAD, 0);
                        l_merged_rates_tbl(merged_count).ACTION := 'UPDATE';

                    end if;
                    rate_sched_count := rate_sched_count + 1;
                    index_rate_count := index_rate_count + 1;

                end if;

                l_prev_spead := l_merged_rates_tbl(merged_count).SPREAD;
                l_prev_io := l_merged_rates_tbl(merged_count).INTEREST_ONLY_FLAG;

                if merged_count > 1 then
                    l_last_period_rate := l_merged_rates_tbl(merged_count-1).CURRENT_INTEREST_RATE;
                else
                    if l_last_period_rate is null then
                        l_last_period_rate := l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE;
                    end if;
                end if;

                if l_merged_rates_tbl(merged_count).BEGIN_INSTALLMENT_NUMBER = 1 then
                    l_initial_int_rate := l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE;
                end if;

                if l_merged_rates_tbl(merged_count).ACTION <> 'SKIP' then
                    -- adjust rate based on loan rules
                    adjustInterestRate(p_initial_rate            => l_initial_int_rate
                                        ,p_last_period_rate        => l_last_period_rate
                                        ,p_max_period_adjustment   => P_LOAN_REC.percent_increase
                                        ,p_max_lifetime_adjustment => P_LOAN_REC.percent_increase_life
                                        ,p_ceiling_rate            => P_LOAN_REC.ceiling_rate
                                        ,p_floor_rate              => P_LOAN_REC.floor_rate
                                        ,x_interest_rate           => l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE
                                        ,x_adjustment_reason       => l_adjustment_reason);
                end if;

                merged_count := merged_count + 1;

            elsif (l_rate_sched_from < l_index_from) then

                if l_rate_sched_to < l_index_from then
                    l_merged_rates_tbl(merged_count) := l_RATE_SCHEDS_TBL(rate_sched_count);
                    logMessage(FND_LOG.LEVEL_STATEMENT, 'if 41 - skipping');
                    l_merged_rates_tbl(merged_count).ACTION := 'SKIP';
                    rate_sched_count := rate_sched_count + 1;

                elsif l_rate_sched_to >= l_index_from then

                    if l_RATE_SCHEDS_TBL(rate_sched_count).INDEX_RATE = l_index_rate and
                        l_rate_sched_to = l_index_to and
                        rate_sched_count < l_RATE_SCHEDS_TBL.count and
                        index_rate_count < l_ADJ_RATES_TBL.count
                    then

                        l_merged_rates_tbl(merged_count) := l_RATE_SCHEDS_TBL(rate_sched_count);
                        logMessage(FND_LOG.LEVEL_STATEMENT, 'if 42 - skipping');
                        l_merged_rates_tbl(merged_count).ACTION := 'SKIP';
                        rate_sched_count := rate_sched_count + 1;
                        index_rate_count := index_rate_count + 1;

                    else

                        l_do_insert := true;

                        if l_start_from_installment > 1 and l_update1 then

                            l_merged_rates_tbl(merged_count) := l_RATE_SCHEDS_TBL(rate_sched_count);
                            l_merged_rates_tbl(merged_count).ACTION := 'UPDATE';
                            l_prev_spead := l_merged_rates_tbl(merged_count).SPREAD;
                            l_prev_io := l_merged_rates_tbl(merged_count).INTEREST_ONLY_FLAG;
                            l_update1 := false;

                            if l_RATE_SCHEDS_TBL(rate_sched_count).INDEX_RATE = l_index_rate then
                                logMessage(FND_LOG.LEVEL_STATEMENT, 'if 43 - updating');
                                l_merged_rates_tbl(merged_count).END_INSTALLMENT_NUMBER := l_index_to;
                                l_do_insert := false;
                                index_rate_count := index_rate_count + 1;
                            else
                                logMessage(FND_LOG.LEVEL_STATEMENT, 'if 44 - updating');
                                l_merged_rates_tbl(merged_count).END_INSTALLMENT_NUMBER := l_index_from-1;
                                l_do_insert := true;
                                merged_count := merged_count + 1;
                            end if;

                        end if;

                        if l_do_insert then

                            l_merged_rates_tbl(merged_count).RATE_ID := null;
                            l_merged_rates_tbl(merged_count).TERM_ID := P_LOAN_REC.TERM_ID;
                            l_merged_rates_tbl(merged_count).BEGIN_INSTALLMENT_NUMBER := l_index_from;
                            l_merged_rates_tbl(merged_count).INDEX_RATE := l_index_rate;
                            l_merged_rates_tbl(merged_count).SPREAD := l_prev_spead;
                            l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE := l_index_rate + nvl(l_merged_rates_tbl(merged_count).SPREAD, 0);
                            l_merged_rates_tbl(merged_count).INTEREST_ONLY_FLAG := l_prev_io;
                            l_merged_rates_tbl(merged_count).ACTION := 'INSERT';

                            if l_rate_sched_to > l_index_to then

                                logMessage(FND_LOG.LEVEL_STATEMENT, 'if 45 - inserting');
                                l_merged_rates_tbl(merged_count).END_INSTALLMENT_NUMBER := l_index_to;
                                index_rate_count := index_rate_count + 1;

                            elsif l_rate_sched_to < l_index_to then

                                logMessage(FND_LOG.LEVEL_STATEMENT, 'if 46 - inserting');
                                l_merged_rates_tbl(merged_count).END_INSTALLMENT_NUMBER := l_rate_sched_to;
                                rate_sched_count := rate_sched_count + 1;

                            else  -- l_rate_sched_to = l_index_to

                                logMessage(FND_LOG.LEVEL_STATEMENT, 'if 47 - inserting');
                                l_merged_rates_tbl(merged_count).END_INSTALLMENT_NUMBER := l_rate_sched_to;
                                rate_sched_count := rate_sched_count + 1;
                                index_rate_count := index_rate_count + 1;

                            end if;

                            if merged_count > 1 then
                                l_last_period_rate := l_merged_rates_tbl(merged_count-1).CURRENT_INTEREST_RATE;
                            else
                                if l_last_period_rate is null then
                                    l_last_period_rate := l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE;
                                end if;
                            end if;

                            if l_merged_rates_tbl(merged_count).BEGIN_INSTALLMENT_NUMBER = 1 then
                                l_initial_int_rate := l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE;
                            end if;

                            -- adjust rate based on loan rules
                            adjustInterestRate(p_initial_rate            => l_initial_int_rate
                                                ,p_last_period_rate        => l_last_period_rate
                                                ,p_max_period_adjustment   => P_LOAN_REC.percent_increase
                                                ,p_max_lifetime_adjustment => P_LOAN_REC.percent_increase_life
                                                ,p_ceiling_rate            => P_LOAN_REC.ceiling_rate
                                                ,p_floor_rate              => P_LOAN_REC.floor_rate
                                                ,x_interest_rate           => l_merged_rates_tbl(merged_count).CURRENT_INTEREST_RATE
                                                ,x_adjustment_reason       => l_adjustment_reason);

                        end if;

                    end if;

                end if;

                merged_count := merged_count + 1;

            elsif (l_rate_sched_from > l_index_to) then

                logMessage(FND_LOG.LEVEL_STATEMENT, 'if 5 - going to next index rate record');
                index_rate_count := index_rate_count + 1;

            end if;

        elsif (l_rate_sched_from is null or l_rate_sched_to is null or
               l_index_from is null or l_index_from is null)
        then

            logMessage(FND_LOG.LEVEL_STATEMENT, 'if 6 - exiting loop');
            exit;

        end if;

    end loop;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'New rate schedule:');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'From_date   To_Date   From_Inst   To_Inst   Rate+Spread=Current_Rate   IO   Rate_sched_id');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, '---------   -------   ---------   -------   ------------------------   --   -------------');
    for k in 1..l_merged_rates_tbl.count loop

        if l_merged_rates_tbl(k).ACTION = 'UPDATE' then

            update lns_rate_schedules
                set index_rate = l_merged_rates_tbl(k).INDEX_RATE
                    ,current_interest_rate = l_merged_rates_tbl(k).CURRENT_INTEREST_RATE
                    ,end_installment_number = l_merged_rates_tbl(k).END_INSTALLMENT_NUMBER
                    ,last_update_date = sysdate
                    ,last_updated_by = LNS_UTILITY_PUB.last_updated_by
                    ,last_update_login = LNS_UTILITY_PUB.last_update_login
                    ,object_version_number = object_version_number + 1
            where rate_id = l_merged_rates_tbl(k).RATE_ID;

        elsif l_merged_rates_tbl(k).ACTION = 'INSERT' then

            select LNS_RATE_SCHEDULES_S.NEXTVAL into l_merged_rates_tbl(k).RATE_ID from dual;

            insert into lns_rate_schedules(
                RATE_ID
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
                ,BEGIN_INSTALLMENT_NUMBER
                ,END_INSTALLMENT_NUMBER
                ,INTEREST_ONLY_FLAG
                ,PHASE
                )
            VALUES
                (l_merged_rates_tbl(k).RATE_ID
                ,l_merged_rates_tbl(k).TERM_ID
                ,l_merged_rates_tbl(k).INDEX_RATE
                ,l_merged_rates_tbl(k).SPREAD
                ,l_merged_rates_tbl(k).CURRENT_INTEREST_RATE
                ,sysdate
                ,null
                ,LNS_UTILITY_PUB.created_by
                ,sysdate
                ,LNS_UTILITY_PUB.last_updated_by
                ,sysdate
                ,LNS_UTILITY_PUB.last_update_login
                ,1
                ,l_merged_rates_tbl(k).BEGIN_INSTALLMENT_NUMBER
                ,l_merged_rates_tbl(k).END_INSTALLMENT_NUMBER
                ,l_merged_rates_tbl(k).INTEREST_ONLY_FLAG
                ,P_LOAN_REC.CURRENT_PHASE
                );

        end if;

        LogMessage(FND_LOG.LEVEL_UNEXPECTED,
        l_merged_rates_tbl(k).BEGIN_DATE || '   ' ||
        l_merged_rates_tbl(k).END_DATE || '   ' ||
        l_merged_rates_tbl(k).BEGIN_INSTALLMENT_NUMBER || '   ' ||
        l_merged_rates_tbl(k).END_INSTALLMENT_NUMBER || '   ' ||
        l_merged_rates_tbl(k).INDEX_RATE || ' + ' || l_merged_rates_tbl(k).SPREAD || ' = ' || l_merged_rates_tbl(k).CURRENT_INTEREST_RATE || '   ' ||
        l_merged_rates_tbl(k).INTEREST_ONLY_FLAG || '   ' ||
        l_merged_rates_tbl(k).RATE_ID || '   ' ||
        l_merged_rates_tbl(k).ACTION );

    end loop;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully processed loan ' || P_LOAN_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked');
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to process loan ' || P_LOAN_REC.LOAN_NUMBER);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked');
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to process loan ' || P_LOAN_REC.LOAN_NUMBER);

    WHEN OTHERS THEN
        ROLLBACK TO PROCESS_SINGLE_LOAN;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked');
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to process loan ' || P_LOAN_REC.LOAN_NUMBER);

END;




/*========================================================================
 | PUBLIC PROCEDURE UPDATE_FLOATING_RATE_LOANS
 |
 | DESCRIPTION
 |      This procedure gets called from CM to mass update index rate for floating loans.
 |		Concurrent Program Name: "LNS: Mass Update Floating Rate Loans"
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      INDEX_RATE_ID     IN      Inputs index rate type
 |      INTEREST_RATE_LINE_ID IN    Inputs index rate
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-SEP-2006           karamach          Created
 | 12-Mar-2008           scherkas          Fix for bug 6849817: changed program logic to support multiple rate schedule rows
 |
 *=======================================================================*/
PROCEDURE UPDATE_FLOATING_RATE_LOANS(
    ERRBUF              OUT NOCOPY     VARCHAR2,
    RETCODE             OUT NOCOPY     VARCHAR2,
    P_INDEX_RATE_ID     IN             NUMBER)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'UPDATE_FLOATING_RATE_LOANS';
    l_msg_data                      VARCHAR2(32767);
	l_msg_count	                    number;
    l_return                        boolean;
	l_return_status                 varchar2(10);
	l_Count							number;
    l_success_count                 number;
	l_failure_count 			    number;
	l_setup_int_rate                number;
	l_setup_rate_name               varchar2(50);
	l_setup_rate_desc               varchar2(250);
    j                               number;

    l_RATE_LINES_TBL                RATE_LINES_TBL;
    l_RATE_LINE_REC                 RATE_LINE_REC;
    l_LOAN_REC                      LOAN_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
    CURSOR c_get_loan_info(indexRateId NUMBER) IS
        SELECT loan.loan_id,
            term.term_id,
            loan.loan_number,
            lns_billing_util_pub.last_payment_number(term.loan_id) last_billed_installment,
            loan.loan_status,
            loan.CURRENT_PHASE,
            decode(loan.CURRENT_PHASE, 'TERM', term.percent_increase, 'OPEN', term.open_percent_increase),
            decode(loan.CURRENT_PHASE, 'TERM', term.percent_increase_life, 'OPEN', term.open_percent_increase_life),
            decode(loan.CURRENT_PHASE, 'TERM', term.floor_rate, 'OPEN', term.open_floor_rate),
            decode(loan.CURRENT_PHASE, 'TERM', term.ceiling_rate, 'OPEN', term.open_ceiling_rate)
        FROM lns_loan_headers loan,
            lns_terms term
        WHERE loan.loan_id = term.loan_id
            AND term.rate_type = 'FLOATING'
            AND loan.loan_status NOT IN ('PAIDOFF','REJECTED','DELETED')
            AND nvl(indexRateId, term.index_rate_id) = term.index_rate_id;

    CURSOR c_get_int_rates(P_INDEX_RATE_ID VARCHAR2) IS
        SELECT hdr.interest_rate_id,
            hdr.interest_rate_name,
            hdr.interest_rate_description
        FROM lns_int_rate_headers_vl hdr
        WHERE (EXISTS
            (SELECT null
            FROM lns_loan_headers loan,
                lns_terms term
            WHERE loan.loan_id = term.loan_id
                AND term.rate_type = 'FLOATING'
                AND loan.loan_status NOT IN ('PAIDOFF','REJECTED','DELETED')
                AND term.index_rate_id = hdr.interest_rate_id)
        AND nvl(P_INDEX_RATE_ID, hdr.interest_rate_id) = hdr.interest_rate_id)
        order by hdr.interest_rate_name;

    CURSOR c_get_int_lines(indexRateId NUMBER) IS
        SELECT interest_rate_line_id,
            interest_rate_id,
            interest_rate,
            start_date_active,
            end_date_active
        FROM lns_int_rate_lines
        WHERE interest_rate_id = indexRateId
        order by start_date_active;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT UPDATE_FLOATING_RATE_LOANS_PVT;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

    /* init variables */
	l_Count := 0;
    l_success_count := 0;
	l_failure_count := 0;

	LogMessage(FND_LOG.level_unexpected, 'Input Parameters:');
	LogMessage(FND_LOG.level_unexpected, 'Index: ' || P_INDEX_RATE_ID);

	--Obtain rate setup info based on user input parameters
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Searching for index rates...');
    open c_get_int_rates(P_INDEX_RATE_ID);
    LOOP

        fetch c_get_int_rates into
            l_setup_int_rate,
            l_setup_rate_name,
            l_setup_rate_desc;
        exit when c_get_int_rates%NOTFOUND;

    	LogMessage(FND_LOG.level_unexpected, ' ');
        LogMessage(FND_LOG.level_unexpected, 'Index rate - ' || l_setup_rate_name || ' (' || l_setup_int_rate || ')');

        j := 0;
        l_RATE_LINES_TBL.delete;
        open c_get_int_lines(l_setup_int_rate);
        LOOP

            fetch c_get_int_lines into
                l_RATE_LINE_REC.INTEREST_RATE_LINE_ID,
                l_RATE_LINE_REC.INTEREST_RATE_ID,
                l_RATE_LINE_REC.INTEREST_RATE,
                l_RATE_LINE_REC.START_DATE_ACTIVE,
                l_RATE_LINE_REC.END_DATE_ACTIVE;
            exit when c_get_int_lines%NOTFOUND;

            j := j + 1;
            l_RATE_LINES_TBL(j) := l_RATE_LINE_REC;
            LogMessage(FND_LOG.level_unexpected, l_RATE_LINES_TBL(j).START_DATE_ACTIVE || ' - ' || l_RATE_LINES_TBL(j).END_DATE_ACTIVE || ': ' || l_RATE_LINES_TBL(j).INTEREST_RATE || ' (id=' || l_RATE_LINES_TBL(j).INTEREST_RATE_LINE_ID || ')');

        END LOOP;
        close c_get_int_lines;

        open c_get_loan_info(l_setup_int_rate);
        LOOP

            fetch c_get_loan_info into
                l_LOAN_REC.loan_id,
                l_LOAN_REC.term_id,
                l_LOAN_REC.loan_number,
                l_LOAN_REC.last_billed_installment,
                l_LOAN_REC.loan_status,
                l_LOAN_REC.CURRENT_PHASE,
                l_LOAN_REC.percent_increase,
                l_LOAN_REC.percent_increase_life,
                l_LOAN_REC.floor_rate,
                l_LOAN_REC.ceiling_rate;
            exit when c_get_loan_info%NOTFOUND;

            l_Count := l_Count + 1;

            PROCESS_SINGLE_LOAN(
                P_API_VERSION		    => 1.0,
                P_INIT_MSG_LIST		    => FND_API.G_FALSE,
                P_COMMIT			    => FND_API.G_TRUE,
                P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
                P_LOAN_REC              => l_LOAN_REC,
                P_RATE_LINES_TBL        => l_RATE_LINES_TBL,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data);

            if l_return_status = 'S' then
                l_success_count := l_success_count + 1;
            else
                l_failure_count := l_failure_count + 1;
            end if;

        END LOOP;
        close c_get_loan_info;

    END LOOP;
    close c_get_int_rates;

	LogMessage(FND_LOG.LEVEL_STATEMENT, ' ');
    LogMessage(FND_LOG.level_unexpected, '----------------------------------');
    LogMessage(FND_LOG.level_unexpected, 'Total Processed: ' || l_Count || ' loan(s)');
    LogMessage(FND_LOG.level_unexpected, 'Failed: ' || l_failure_count || ' loan(s)');
    LogMessage(FND_LOG.level_unexpected, 'Succeeded: ' || l_success_count || ' loan(s)');

    RETCODE := FND_API.G_RET_STS_SUCCESS;
    if l_Count = 0 then
        ERRBUF := 'No floating rate loans were found.';
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => 'WARNING',
			            message => ERRBUF);
        LogMessage(FND_LOG.level_unexpected, ERRBUF);
    elsif l_failure_count > 0 then
        ERRBUF := 'Not all floating rate loans were updated successfully. Please review log file.';
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => 'WARNING',
			            message => ERRBUF);
        LogMessage(FND_LOG.level_unexpected, ERRBUF);
    end if;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN OTHERS THEN
        ERRBUF := 	'Update of floating rate loans has failed. Please review log file.';
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => 'ERROR',
			            message => ERRBUF);
        RETCODE := FND_API.G_RET_STS_ERROR;
        LogMessage(FND_LOG.level_unexpected, ERRBUF);

END UPDATE_FLOATING_RATE_LOANS;



-- This api updates floating rates for single loan
PROCEDURE UPDATE_LOAN_FLOATING_RATE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'UPDATE_LOAN_FLOATING_RATE';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_msg_data                      VARCHAR2(32767);
	l_msg_count	                    number;
	l_return_status                 varchar2(10);
    l_index_rate_id                 NUMBER;
    l_interest_rate_name            VARCHAR2(30);
    j                               NUMBER;

    l_RATE_LINES_TBL                RATE_LINES_TBL;
    l_RATE_LINE_REC                 RATE_LINE_REC;
    l_LOAN_REC                      LOAN_REC;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/
    CURSOR c_get_loan_info(p_loan_id NUMBER) IS
        SELECT loan.loan_id,
            term.term_id,
            loan.loan_number,
            lns_billing_util_pub.last_payment_number(term.loan_id) last_billed_installment,
            loan.loan_status,
            loan.CURRENT_PHASE,
            term.index_rate_id,
            hdr.interest_rate_name,
            decode(loan.CURRENT_PHASE, 'TERM', term.percent_increase, 'OPEN', term.open_percent_increase),
            decode(loan.CURRENT_PHASE, 'TERM', term.percent_increase_life, 'OPEN', term.open_percent_increase_life),
            decode(loan.CURRENT_PHASE, 'TERM', term.floor_rate, 'OPEN', term.open_floor_rate),
            decode(loan.CURRENT_PHASE, 'TERM', term.ceiling_rate, 'OPEN', term.open_ceiling_rate)
        FROM lns_loan_headers loan,
            lns_terms term,
            lns_int_rate_headers_vl hdr
        WHERE loan.loan_id = p_loan_id
            AND loan.loan_id = term.loan_id
            AND term.rate_type = 'FLOATING'
            AND loan.loan_status NOT IN ('PAIDOFF','REJECTED','DELETED')
            AND term.index_rate_id = hdr.interest_rate_id;

    CURSOR c_get_int_lines(indexRateId NUMBER) IS
        SELECT interest_rate_line_id,
            interest_rate_id,
            interest_rate,
            start_date_active,
            end_date_active+1
        FROM lns_int_rate_lines
        WHERE interest_rate_id = indexRateId
        order by start_date_active;

BEGIN
    LogMessage(FND_LOG.level_unexpected, ' ');
    LogMessage(FND_LOG.LEVEL_PROCEDURE, l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT UPDATE_LOAN_FLOATING_RATE;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Established savepoint');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- START OF BODY OF API

	LogMessage(FND_LOG.level_unexpected, 'Input Parameters:');
	LogMessage(FND_LOG.level_unexpected, 'P_LOAN_ID: ' || P_LOAN_ID);

    open c_get_loan_info(P_LOAN_ID);
    fetch c_get_loan_info into
        l_LOAN_REC.loan_id,
        l_LOAN_REC.term_id,
        l_LOAN_REC.loan_number,
        l_LOAN_REC.last_billed_installment,
        l_LOAN_REC.loan_status,
        l_LOAN_REC.CURRENT_PHASE,
        l_index_rate_id,
        l_interest_rate_name,
        l_LOAN_REC.percent_increase,
        l_LOAN_REC.percent_increase_life,
        l_LOAN_REC.floor_rate,
        l_LOAN_REC.ceiling_rate;
    close c_get_loan_info;

    j := 0;
    l_RATE_LINES_TBL.delete;
	LogMessage(FND_LOG.level_unexpected, 'Index rate ' || l_interest_rate_name || ':');
    open c_get_int_lines(l_index_rate_id);
    LOOP

        fetch c_get_int_lines into
            l_RATE_LINE_REC.INTEREST_RATE_LINE_ID,
            l_RATE_LINE_REC.INTEREST_RATE_ID,
            l_RATE_LINE_REC.INTEREST_RATE,
            l_RATE_LINE_REC.START_DATE_ACTIVE,
            l_RATE_LINE_REC.END_DATE_ACTIVE;
        exit when c_get_int_lines%NOTFOUND;

        j := j + 1;
        l_RATE_LINES_TBL(j) := l_RATE_LINE_REC;
        LogMessage(FND_LOG.level_unexpected, l_RATE_LINES_TBL(j).START_DATE_ACTIVE || ' - ' || l_RATE_LINES_TBL(j).END_DATE_ACTIVE || ': ' || l_RATE_LINES_TBL(j).INTEREST_RATE || ' (id=' || l_RATE_LINES_TBL(j).INTEREST_RATE_LINE_ID || ')');

    END LOOP;
    close c_get_int_lines;

    PROCESS_SINGLE_LOAN(
        P_API_VERSION		    => 1.0,
        P_INIT_MSG_LIST		    => FND_API.G_FALSE,
        P_COMMIT			    => FND_API.G_FALSE,
        P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
        P_LOAN_REC              => l_LOAN_REC,
        P_RATE_LINES_TBL        => l_RATE_LINES_TBL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data);

    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully processed loan ' || l_LOAN_REC.LOAN_NUMBER);
    LogMessage(FND_LOG.LEVEL_PROCEDURE, l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_LOAN_FLOATING_RATE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked');
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to process loan ' || l_LOAN_REC.LOAN_NUMBER);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_LOAN_FLOATING_RATE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked');
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to process loan ' || l_LOAN_REC.LOAN_NUMBER);

    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_LOAN_FLOATING_RATE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_ERROR, 'Rollbacked');
        LogMessage(FND_LOG.LEVEL_ERROR, 'Failed to process loan ' || l_LOAN_REC.LOAN_NUMBER);

END;


END LNS_INDEX_RATES_PUB;

/
