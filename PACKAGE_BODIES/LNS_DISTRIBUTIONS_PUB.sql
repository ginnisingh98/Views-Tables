--------------------------------------------------------
--  DDL for Package Body LNS_DISTRIBUTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_DISTRIBUTIONS_PUB" AS
/* $Header: LNS_DIST_PUBP_B.pls 120.45.12010000.13 2010/05/27 14:53:21 mbolli ship $ */

/*========================================================================+
 |  Package Global Constants
 +=======================================================================*/
 G_DEBUG_COUNT               NUMBER := 0;
 G_DEBUG                     BOOLEAN := FALSE;

 G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'LNS_DISTRIBUTIONS_PUB';

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
        if FND_GLOBAL.Conc_Request_Id is not null then
            fnd_file.put_line(FND_FILE.LOG, message);
        end if;
    END IF;
end;


procedure cancel_disbursements(p_init_msg_list          in varchar2
                              ,p_commit                 in varchar2
                              ,p_loan_id                in number
                              ,x_return_status          OUT NOCOPY VARCHAR2
                              ,x_msg_count              OUT NOCOPY NUMBER
                              ,x_msg_data               OUT NOCOPY VARCHAR2)
is

  l_api_name         varchar2(50);
  l_event_id         number;
  l_budget_req_approval   varchar2(1);
  l_funds_reserved_flag   varchar2(1);
  l_gl_date               date;
  l_budget_event_exists   number;
  l_status_code           varchar2(25);
  l_return_status         varchar2(1);
  l_packet_id             number;
  l_msg_count             number;
  l_msg_data              VARCHAR2(2000);
  l_version               number;
  l_loan_header_rec       LNS_LOAN_HEADER_PUB.loan_header_rec_type;
  l_disbursement_id       number;

    cursor c_events(p_loan_id number) is
    select event_id
        from xla_transaction_entities xlee
            ,xla_events xle
      where xle.application_id = 206
        and xle.entity_id = xlee.entity_id
        and xlee.source_id_int_1 = p_loan_id
        and xle.budgetary_control_flag = 'Y'
        and xle.event_type_code = 'FUTURE_DISBURSEMENT_CANCELLED'
        and xle.process_status_code <> 'P';

    cursor c_budget_req(p_loan_id number) is
    select nvl(p.BDGT_REQ_FOR_APPR_FLAG, 'N')
          ,nvl(h.funds_reserved_flag, 'N')
          ,nvl(h.gl_date, sysdate)
      from lns_loan_headers h,
           lns_loan_products p
      where p.loan_product_id = h.product_id
        and h.loan_id = p_loan_id;

    cursor c_obj_vers(p_loan_id number) is
    select object_version_number
      from lns_loan_headers
     where loan_id = p_loan_id;

    cursor c_disbursements(p_loan_id number) is
    select disb_header_id
      from lns_disb_headers
     where loan_id = p_loan_id
       and disbursement_number = 1;

begin

      SAVEPOINT cancel_disbursements;
      l_api_name := 'cancel_disbursements';
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id '  || p_loan_id);

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status         := FND_API.G_RET_STS_SUCCESS;

      -- first complete accounting for any unprocessed events / documents for the loan transaction
      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling lns_distributions_pub.onlineAccounting...');
      lns_distributions_pub.onlineAccounting(p_loan_id            => p_loan_id
                                            ,p_init_msg_list      => fnd_api.g_false
                                            ,p_accounting_mode    => 'F'
                                            ,p_transfer_flag      => 'Y'
                                            ,p_offline_flag       => 'N'
                                            ,p_gl_posting_flag    => 'N'
                                            ,x_return_status      => l_return_status
                                            ,x_msg_count          => l_msg_count
                                            ,x_msg_data           => l_msg_data);
      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);
      if l_return_status <> 'S' then
            RAISE FND_API.G_EXC_ERROR;
      end if;

      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fetching l_disbusement_id ');
      open c_disbursements(p_loan_id);
      fetch c_disbursements into l_disbursement_id;
      close c_disbursements;
      logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_disbusement_id ' || l_disbursement_id);

      if (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y') then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'federal enabled');
            open c_budget_req(p_loan_id);
            fetch c_budget_req into l_budget_req_approval, l_funds_reserved_flag, l_gl_date;
            close c_budget_req;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_budget_req_approval '  || l_budget_req_approval);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_funds_reserved_flag '  || l_funds_reserved_flag);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');

            LNS_XLA_EVENTS.create_event(p_loan_id         => p_loan_id
                                    ,p_disb_header_id  => l_disbursement_id
                                    ,p_loan_amount_adj_id => -1
                                    ,p_event_type_code => 'FUTURE_DISBURSEMENT_CANCELLED'
                                    ,p_event_date      => l_gl_date
                                    ,p_event_status    => 'U'
                                    ,p_init_msg_list   => fnd_api.g_false
                                    ,p_commit          => fnd_api.g_false
                                    ,p_bc_flag         => 'Y'
                                    ,x_event_id        => l_event_id
                                    ,x_return_status   => l_return_status
                                    ,x_msg_count       => l_msg_count
                                    ,x_msg_data        => l_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
                FND_MSG_PUB.ADD;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'stamping new event_id on distributions');
            update lns_distributions
            set event_id = l_event_id
            ,last_update_date = sysdate
            where distribution_type = 'ORIGINATION'
            and loan_id           = p_loan_id
            and event_id       is not null
            and (disb_header_id is null and loan_amount_adj_id is null);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');

            if l_funds_reserved_flag = 'Y' then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'inserting into PSA_BC_XLA_EVENTS_GT - event => ' || l_event_id);
                insert into PSA_BC_XLA_EVENTS_GT (event_id, result_code)
                values (l_event_id, 'FAIL');

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling PSA_BC_XLA_PUB.Budgetary_Control  '  || l_event_id);
                -- always pass P_BC_MODE = reserve as per shaniqua williams
                PSA_BC_XLA_PUB.Budgetary_Control(p_api_version      => 1.0
                                                ,p_init_msg_list    => FND_API.G_FALSE
                                                ,x_return_status    => l_return_status
                                                ,x_msg_count        => l_msg_count
                                                ,x_msg_data         => l_msg_data
                                                ,p_application_id   => 206
                                                ,p_bc_mode          => 'R'
                                                ,p_override_flag    => null
                                                ,p_user_id          => null
                                                ,p_user_resp_id     => null
                                                ,x_status_code      => l_status_code
                                                ,x_packet_ID        => l_packet_id);

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'BC status is = ' || l_return_status);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_status_code = ' || l_status_code);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_packet_id = ' || l_packet_id);

                -- we want to commit ONLY in the case of SUCCESS or ADVISORY
                if (l_return_status <> 'S') then

                    x_return_status         := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
                    FND_MESSAGE.SET_TOKEN('ERROR' ,'Call to PSA_BC_XLA_PUB.Budgetary_Control failed with Status Code = ' || l_status_code);
                    FND_MSG_PUB.ADD;
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;

                else
                    -- caller handle success status
                    null;

                end if; -- BC_API.RETURN_STATUS

            end if; -- l_funds_reserved_flag

      end if;

      x_return_status         := l_return_status;
      IF FND_API.to_Boolean(p_commit)
      THEN
        COMMIT WORK;
      END IF;

      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO cancel_disbursements;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO cancel_disbursements;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO cancel_disbursements;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

end cancel_disbursements;

/*=========================================================================
|| FUNCTION GENERATE_BC_REPORT
||
|| DESCRIPTION
||         this function generatesthe BC report and returns the sequence_id
||          needed for the rpt
||
|| PARAMETERS   p_loan_id => loan identifier
||              p_loan_amount_adj_id => Loan Amount Adjustment Identifier default NULL
||              p_source => Report generation for LoanApproval/LoanAdjustment default NULL
||
|| Return value:  sequence for BC report
||
|| Source Tables:
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10-01-2005            raverma             Created
 *=======================================================================*/
FUNCTION GENERATE_BC_REPORT(p_loan_id number
			  , p_source varchar2 default NULL
                          , p_loan_amount_adj_id number default NULL
                         ) RETURN NUMBER IS

	l_api_name             varchar2(50);
	l_count                NUMBER;
 	l_event_id             number;
	l_distribution_id      number;
	l_errbuf               VARCHAR2(3000);
	l_retcode              NUMBER;
	l_ledger_id            number;
	l_application_id       number;
	l_event_flag           varchar2(1);
	l_sequence_id          number;
  	l_loan_amount_adj_id   number;
  	l_return_status         VARCHAR2(1);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(32767);


	cursor c_event (c_loan_id number, c_loan_amount_adj_id number) is
    select xle.event_id, xll.source_distribution_id_num_1, ledger_id
    from xla_transaction_entities xlee
        ,xla_events xle
        ,xla_distribution_links   xll
    where xle.application_id = 206
        and xle.entity_id = xlee.entity_id
        and xlee.source_id_int_1 = c_loan_id
    --    and nvl(xlee.source_id_int_3, -1) = nvl(c_loan_amount_adj_id, -1)
        and xle.budgetary_control_flag = 'Y'
        and xll.event_id =xle.event_id
	order by event_id desc;

  cursor c_loan_adj(c_loan_id number) is
   select max(ladj.loan_amount_adj_id)
    from lns_loan_amount_adjs ladj
         ,xla_transaction_entities xlee
         ,xla_events xle
    where ladj.loan_id = c_loan_id
      and xlee.entity_id = xle.entity_id
      and xle.event_type_code in ('DIRECT_LOAN_ADJ_APPROVED', 'DIRECT_LOAN_ADJ_REVERSED')
      and xlee.source_id_int_1 = ladj.loan_id
      and xlee.source_id_int_3 = ladj.loan_amount_adj_id
      and ladj.status in ('PENDING', 'APPROVED')
    order by ladj.loan_amount_adj_id desc;

BEGIN

    l_sequence_id    := -1;
    l_application_id := 206;
    l_event_flag     := 'E';
    l_api_name       := 'generate_bc_report';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id '  || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id '  || p_loan_amount_adj_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_source '  || p_source);

    -- steps 1. delete from PSA_BC_REPORT_EVENTS_GT
    --       2. insert into PSA_BC_REPORT_EVENTS_GT
    --       3. generate sequence
    --       4. call Create_BC_Transaction_report API
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'deleting from PSA_BC_REPORT_EVENTS_GT');
    DELETE FROM PSA_BC_REPORT_EVENTS_GT;

    IF p_source = 'LOAN_AMOUNT_ADJUSTMENT' THEN
      IF p_loan_amount_adj_id IS NULL THEN
        -- Retrieve the Pending Loan Amount Adjustment Id of the loan
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Retrieve the pending loan_amount_adj_id based on the input loan_id');

        lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                      ,p_init_msg_list  =>  'F'
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,x_return_status  =>  l_return_status
                                      ,p_col_id         =>  p_loan_id
                                      ,p_col_name       =>  'LOAN_ID'
                                      ,p_table_name     =>  'LNS_LOAN_HEADERS');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', p_loan_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        OPEN c_loan_adj(p_loan_id);
        FETCH c_loan_adj INTO l_loan_amount_adj_id;
        CLOSE c_loan_adj;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_loan_amount_adj_id = ' || l_loan_amount_adj_id);

	-- if l_loan_amount_adj_id IS NULL then no adjustment fundsCheck happened till now and so generate the report
	-- for the Direct Loan Approved


      ELSE  -- ELSE IF p_loan_amount_adj_id IS NOT NULL
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Validating input p_loan_amount_adj_id');

        lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                      ,p_init_msg_list  =>  'F'
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,x_return_status  =>  l_return_status
                                      ,p_col_id         =>  p_loan_amount_adj_id
                                      ,p_col_name       =>  'LOAN_AMOUNT_ADJ_ID'
                                      ,p_table_name     =>  'LNS_LOAN_AMOUNT_ADJS');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_AMOUNT_ADJ_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', p_loan_amount_adj_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        l_loan_amount_adj_id  :=  p_loan_amount_adj_id;

      END IF;   -- IF p_loan_amount_adj_id IS NULL

    END IF;



    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'opening c_event...');
    open c_event(p_loan_id, l_loan_amount_adj_id);
     LOOP
		fetch c_event into
				 	 l_event_id
          				,l_distribution_id
					,l_ledger_id;
      EXIT WHEN c_event%NOTFOUND;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_id = ' || l_distribution_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_ledger_id = ' || l_ledger_id);

		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'inserting into psa table...');
		INSERT INTO PSA_BC_REPORT_EVENTS_GT
			(event_id
			,SOURCE_DISTRIBUTION_ID_NUM_1
			,SOURCE_DISTRIBUTION_ID_NUM_2)
		values(l_event_id
			,l_distribution_id
			,null);
		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');
    end loop;
    close c_event;

    select PSA_BC_XML_REPORT_S.nextval
    into l_sequence_id
    from dual;

    SELECT count(*) INTO l_count
    FROM PSA_BC_REPORT_EVENTS_GT;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'rows found ' || l_count);

    IF l_count > 0 then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'calling PSA_BC_XML_REPORT_PUB.Create_BC_Transaction_Report...');
        -- Call the XML Genertion Procedure
        PSA_BC_XML_REPORT_PUB.Create_BC_Transaction_Report(l_errbuf
                                                        ,l_retcode
                                                        ,l_ledger_id
                                                        ,l_application_id
                                                        ,l_event_flag
                                                        ,l_sequence_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_errbuf = ' || l_errbuf);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_retcode = ' || l_retcode);
    END IF;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_sequence_id = ' || l_sequence_id);
    return l_sequence_id;

END GENERATE_BC_REPORT;

/*=========================================================================
|| PROCEDURE budgetary_control
||
|| DESCRIPTION
||         this procedure does funds check / funds reserve
||
||
|| PARAMETERS   p_loan_id => loan identifier
||              p_budgetary_control_mode => 'C' Check ; 'R' Reserve
||
|| Return value:  x_budgetary_status_code
||                    SUCCESS   = FUNDS CHECK / RESERVE SUCCESSFUL
||                    PARTIAL   = AT LEAST ONE EVENT FAILED
||                    FAIL      = FUNDS CHECK / RESERVE FAILED
||                    XLA_ERROR = XLA SetUp ERROR
||                    ADVISORY  = BUDGETARY WARNING
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10-01-2005            raverma             Created
 *=======================================================================*/
procedure budgetary_control(p_init_msg_list          in varchar2
                            ,p_commit                 in varchar2
                            ,p_loan_id                in number
                            ,p_budgetary_control_mode in varchar2
                            ,x_budgetary_status_code  out nocopy varchar2
                            ,x_return_status          OUT NOCOPY VARCHAR2
                            ,x_msg_count              OUT NOCOPY NUMBER
                            ,x_msg_data               OUT NOCOPY VARCHAR2)
is
    l_api_name              varchar2(50);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_status_code           varchar2(50);
    l_packet_id             number;
    l_event_id              number;
    l_version               number;
    l_budget_req_approval   varchar2(1);
    l_funds_reserved_flag   varchar2(1);
    l_gl_date               date;
    l_budget_event_exists   number;
    l_loan_header_rec       LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_disbursement_id       number;
    x_event_id              number;

    cursor c_budget_req(p_loan_id number) is
    select nvl(p.BDGT_REQ_FOR_APPR_FLAG, 'N')
          ,nvl(h.funds_reserved_flag, 'N')
          ,nvl(h.gl_date, sysdate)
        from lns_loan_headers h,
                lns_loan_products p
        where p.loan_product_id = h.product_id
        and h.loan_id = p_loan_id;

    -- get budgetary control events only
    cursor c_events(p_loan_id number) is
    select event_id
            from xla_transaction_entities xlee
                ,xla_events xle
        where xle.application_id = 206
        and xle.entity_id = xlee.entity_id
            and xlee.source_id_int_1 = p_loan_id
            and xle.budgetary_control_flag = 'Y'
            and xle.event_type_code = 'DIRECT_LOAN_APPROVED'
            and xle.process_status_code <> 'P'
        order by event_id desc;

    cursor c_disbursements(p_loan_id number) is
    select disb_header_id
      from lns_disb_headers
     where loan_id = p_loan_id
       and disbursement_number = 1;

		cursor c_obj_vers(p_loan_id number) is
		select object_version_number
			from lns_loan_headers
		 where loan_id = p_loan_id;

    cursor c_budget_event(p_loan_id number, p_disb_header_id number) is
    select count(1)
      from xla_transaction_entities xlee
          ,xla_events xle
      where xle.application_id = 206
        and xle.entity_id = xlee.entity_id
        and xlee.source_id_int_1 = p_loan_id
        and xlee.source_id_int_2 = p_disb_header_id
        and xle.budgetary_control_flag = 'Y';

begin

    SAVEPOINT budgetary_control_pvt;
    l_api_name := 'budgetary_control';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = '  || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_budgetary_control_mode = ' || p_budgetary_control_mode);

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status         := FND_API.G_RET_STS_SUCCESS;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fetching l_disbusement_id ');
    open c_disbursements(p_loan_id);
    fetch c_disbursements into l_disbursement_id;
    close c_disbursements;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_disbusement_id = ' || l_disbursement_id);

    -- Bug#6711479 We can't check funds without valid disbursement
    IF (l_disbursement_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CHK_FUND_DISB_INVALID');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CREATE_DISB_SCHED');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    if (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y' AND l_disbursement_id IS NOT NULL) then

        -- check if budget event exists
        -- find if budgetary event already exists, if not, create the event
        open c_budget_event(p_loan_id, l_disbursement_id);
        fetch c_budget_event into l_budget_event_exists;
        close c_budget_event;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_budget_event_exists = ' || l_budget_event_exists);

        open c_budget_req(p_loan_id);
        fetch c_budget_req into l_budget_req_approval, l_funds_reserved_flag, l_gl_date;
        close c_budget_req;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_budget_req_approval = '  || l_budget_req_approval);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_funds_reserved_flag = '  || l_funds_reserved_flag);

        if l_budget_event_exists = 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');

            LNS_XLA_EVENTS.create_event(p_loan_id         => p_loan_id
                                    ,p_disb_header_id  => l_disbursement_id
                                    ,p_loan_amount_adj_id => -1
                                    ,p_event_type_code => 'DIRECT_LOAN_APPROVED'
                                    ,p_event_date      => l_gl_date
                                    ,p_event_status    => 'U'
                                    ,p_init_msg_list   => fnd_api.g_false
                                    ,p_commit          => fnd_api.g_false
                                    ,p_bc_flag         => 'Y'
                                    ,x_event_id        => x_event_id
                                    ,x_return_status   => x_return_status
                                    ,x_msg_count       => x_msg_count
                                    ,x_msg_data        => x_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_return_status = ' || x_return_status);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_event_id ' || x_event_id);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
                FND_MSG_PUB.ADD;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

	    -- stamp the eventID onto the lns_distributions table
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'stamping eventID on lns_distributions');

            update lns_distributions
            set event_id = x_event_id
                ,last_update_date = sysdate
            where distribution_type = 'ORIGINATION'
            and loan_id           = p_loan_id
            and loan_amount_adj_id IS NULL;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updated event_id succesfully for '||SQL%ROWCOUNT||' rows');

        end if; -- budget event already created




        -- now process the event
        if l_funds_reserved_flag <> 'Y' then
            --and p_budgetary_control_mode = 'R' then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting events');

            open c_events(p_loan_id);
        --    LOOP
            fetch c_events into l_event_id;
         --       EXIT WHEN c_events%NOTFOUND;
	     IF l_event_id IS NOT NULL THEN

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);

		-- Bug#9328437, First time, when we do fundsCheck, the event_id creates and updates in lns_distributions table.
		-- However if we do fundsCheck/fundsReserver later, existed distribtuions are deleted and again
		-- defaulted, which has event_id as NULL. So, update the event_id if it is already created whose event_id is NULL
		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'stamping eventID on lns_distributions whose eventID is NULL');
            	update lns_distributions
            	set event_id = l_event_id
                	,last_update_date = sysdate
              where distribution_type = 'ORIGINATION'
              and event_id IS NULL
              and loan_id  = p_loan_id;

		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updated event_id succesfully for '||SQL%ROWCOUNT||' rows');
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'inserting into  PSA_BC_XLA_EVENTS_GT ');
                insert
                into PSA_BC_XLA_EVENTS_GT (event_id, result_code)
                values (l_event_id, 'FAIL');

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling PSA_BC_XLA_PUB.Budgetary_Control  '  || l_event_id);
                PSA_BC_XLA_PUB.Budgetary_Control(p_api_version      => 1.0
                                                ,p_init_msg_list    => FND_API.G_FALSE
                                                ,x_return_status    => l_return_status
                                                ,x_msg_count        => l_msg_count
                                                ,x_msg_data         => l_msg_data
                                                ,p_application_id   => 206
                                                ,p_bc_mode          => p_budgetary_control_mode
                                                ,p_override_flag    => null
                                                ,p_user_id          => null
                                                ,p_user_resp_id     => null
                                                ,x_status_code      => l_status_code
                                                ,x_packet_ID        => l_packet_id);
        --    end loop;
	    END IF;
            close c_events;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'BC status is = ' || l_return_status);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_status_code = ' || l_status_code);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_packet_id = ' || l_packet_id);

            -- we want to commit ONLY in the case of SUCCESS or ADVISORY
            if (l_return_status <> 'S' ) then

                l_return_status         := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,'Call to PSA_BC_XLA_PUB.Budgetary_Control failed with Status Code = ' || l_status_code);
                FND_MSG_PUB.ADD;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            else
		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_budget_req_approval = '  || l_budget_req_approval);

		if ( l_budget_req_approval = 'N' and p_budgetary_control_mode = 'R'
			and (l_status_code = 'FAIL' or l_status_code = 'PARTIAL' or l_status_code = 'XLA_ERROR')) then

			x_budgetary_status_code  := l_status_code;
        		x_return_status                 := l_return_status;

			/*
			FND_MESSAGE.SET_NAME('LNS', 'LNS_APPROVAL_NO_BUDGET');
        		FND_MSG_PUB.ADD_DETAIL(p_message_type => FND_MSG_PUB.G_WARNING_MSG );
        		LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
			*/

			LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' BudgetReserve is not mandatory for LoanApproval, so returning to invoked method');

			FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

			return;

		end if;

                if l_status_code NOT IN ('SUCCESS','ADVISORY') then
                    IF  (l_status_code = 'PARTIAL') THEN
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_CHK_PARTIAL');
                        FND_MSG_PUB.ADD;
                        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
                        FND_MESSAGE.SET_TOKEN('ERROR' ,'Call to PSA_BC_XLA_PUB.Budgetary_Control failed with Status Code = ' || l_status_code);
                        FND_MSG_PUB.ADD;
                        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                end if;

                open c_obj_vers(p_loan_id);
                fetch c_obj_vers into l_version;
                close c_obj_vers;

                if (l_status_code = 'ADVISORY' or l_status_code = 'SUCCESS') and p_budgetary_control_mode = 'R' then
                    l_loan_header_rec.FUNDS_RESERVED_FLAG := 'Y';
                end if;

                l_loan_header_rec.loan_id             := p_loan_id;
                l_loan_header_rec.FUNDS_CHECK_DATE    := sysdate;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'updating loan');
                LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version
                                            ,P_LOAN_HEADER_REC       => l_loan_header_rec
                                            ,P_INIT_MSG_LIST         => FND_API.G_FALSE
                                            ,X_RETURN_STATUS         => l_return_status
                                            ,X_MSG_COUNT             => l_msg_count
                                            ,X_MSG_DATA              => l_msg_data);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'update loan status = ' || l_return_status);

                if l_return_status <> 'S' then
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
                    FND_MSG_PUB.ADD;
                    logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                end if;

            end if; -- BC_API.RETURN_STATUS

        end if; -- l_funds_reserved_flag
        x_budgetary_status_code  := l_status_code;
        x_return_status          := l_return_status;

        IF (l_return_status = 'S' AND FND_API.to_Boolean(p_commit))
        THEN
            COMMIT WORK;
        END IF;

 	end if;  -- no budgetary control-- end if (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y' AND l_disbursement_id IS NOT NULL) then

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO budgetary_control_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO budgetary_control_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO budgetary_control_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

end budgetary_control;


/*=========================================================================
|| PRIVATE PROCEDURE do_insert_distributions
||
|| DESCRIPTION
||         this procedure insert records into lns_distributions table
||
|| PARAMETERS   p_distributions_tbl => table -f distribution records
||
|| Return value:  NA
||
|| Source Tables:
||
|| Target Tables: LNS_DISTRIBUTIONS
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 04-20-2005            raverma             Created
 *=======================================================================*/
procedure do_insert_distributions(p_distributions_tbl in lns_distributions_pub.distribution_tbl
                                 ,p_loan_id           in number)

is
   l_total_distributions  number;
   l_api_name             varchar2(25);
begin
    l_api_name  := 'do_insert_distributions';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'rows received  = ' || p_distributions_tbl.count);

     l_total_distributions := p_distributions_tbl.count;

     if l_total_distributions > 0 then

         for k in 1..l_total_distributions
         loop
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Inserting row : ' || k);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LINE_TYPE  = ' || p_distributions_tbl(k).line_type);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ACC_NAME  = ' || p_distributions_tbl(k).account_name);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CC_ID  = ' || p_distributions_tbl(k).code_combination_id);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ACC_TYPE  = ' || p_distributions_tbl(k).account_type);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'PERCENT  = ' || p_distributions_tbl(k).distribution_percent);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'AMOUNT  = ' || p_distributions_tbl(k).distribution_amount);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DIST_TYPE  = ' || p_distributions_tbl(k).distribution_type);
	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DISB_HEADER_ID  = ' || p_distributions_tbl(k).disb_header_id);
	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LOAN_AMOUNT_ADJ_ID  = ' || p_distributions_tbl(k).loan_amount_adj_id);
	    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LOAN_LINE_ID  = ' || p_distributions_tbl(k).loan_line_id);

            Insert into lns_distributions
            (DISTRIBUTION_ID
            ,LOAN_ID
            ,LINE_TYPE
            ,ACCOUNT_NAME
            ,CODE_COMBINATION_ID
            ,ACCOUNT_TYPE
            ,DISTRIBUTION_PERCENT
            ,DISTRIBUTION_AMOUNT
            ,DISTRIBUTION_TYPE
            ,EVENT_ID
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,OBJECT_VERSION_NUMBER
            ,DISB_HEADER_ID
            ,LOAN_AMOUNT_ADJ_ID
            ,LOAN_LINE_ID)
            values
            (LNS_DISTRIBUTIONS_S.nextval
            ,p_loan_id
            ,p_distributions_tbl(k).line_type
            ,p_distributions_tbl(k).account_name
            ,p_distributions_tbl(k).code_combination_id
            ,p_distributions_tbl(k).account_type
            ,p_distributions_tbl(k).distribution_percent
            ,p_distributions_tbl(k).distribution_amount
            ,p_distributions_tbl(k).distribution_type
            ,p_distributions_tbl(k).event_id
            ,lns_utility_pub.creation_date
            ,lns_utility_pub.created_by
            ,lns_utility_pub.last_update_date
            ,lns_utility_pub.last_updated_by
            ,1
            ,p_distributions_tbl(k).disb_header_id
            ,p_distributions_tbl(k).loan_amount_adj_id
            ,p_distributions_tbl(k).loan_line_id);

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, '****************************************** ');
         end loop;

     else

       FND_MESSAGE.SET_NAME('LNS', 'LNS_DEFAULT_DIST_NOT_FOUND');
       FND_MSG_PUB.ADD;
       logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
       RAISE FND_API.G_EXC_ERROR;

     end if;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

end do_insert_distributions;

/*=========================================================================
|| PRIVATE PROCEDURE defaultDistributionsCatch
||
|| DESCRIPTION
||      ths procedure is the "catchAll" logic for accounting set-up
||      it will ensure that a valid distributions_tbl is built for
||     INTEREST_INCOME, INTEREST_RECEIVABLE, and PRINCIPAL_RECEIVABLE
||
||  as well if the parameter p_include_loan_receivables = 'Y' then
||  it will also pull
||      LOAN_RECEIVABLE and LOAN_CLEARING
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS p_include_loan_receivables 'Y' to include loan_receivable/clearing
||                                       'X' to exclude loan_clearing
||
|| Return value: x_distribution_tbl           distribution table set to write to database
||
|| Source Tables: lns_default_distribs
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
|| 02-18-2004            raverma             Created
 *=======================================================================*/
procedure defaultDistributionsCatch(p_api_version                IN NUMBER
                                   ,p_init_msg_list              IN VARCHAR2
                                   ,p_commit                     IN VARCHAR2
                                   ,p_loan_id                    IN NUMBER
                                   ,p_disb_header_id             IN NUMBER
                                   ,p_loan_amount_adj_id         IN NUMBER DEFAULT NULL
                                   ,p_include_loan_receivables   IN VARCHAR2
                                   ,p_distribution_type          IN VARCHAR2
                                   ,x_distribution_tbl           OUT NOCOPY lns_distributions_pub.distribution_tbl
                                   ,x_return_status              OUT NOCOPY VARCHAR2
                                   ,x_msg_count                  OUT NOCOPY NUMBER
                                   ,x_msg_data                   OUT NOCOPY VARCHAR2)

is
/*------------------------------------------------------------------------+
 | Local Variable Declarations and initializations                        |
 +-----------------------------------------------------------------------*/
    l_api_name               varchar2(50);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_return_Status          VARCHAR2(1);
    l_class                  varchar2(30);
    l_loan_type_id           number;
    i                        number := 0;
    l_line_type              varchar2(30);
    l_account_name           varchar2(30);
    l_code_combination_id    number;
    l_account_type           varchar2(30);
    l_distribution_percent   number;
    l_distribution_type      varchar2(30);
    l_funded_amount          number;
    l_adj_reversal           varchar2(1);
    l_loan_receivables_count number;
    l_loan_payables_count    number;
    l_distributions          lns_distributions_pub.distribution_tbl;
    l_running_amount1        number;
    l_running_amount2        number;
    l_running_amount3        number;
    l_running_amount4        number;
    k                        number;
    n                        number;
    l                        number;
    m                        number;
    l_ledger_details         lns_distributions_pub.gl_ledger_details;
    Type refCur is ref cursor;
    sql_Cur                  refCur;
    vSqlCur                 varchar2(1000);
    vPLSQL                  VARCHAR2(1000);

/*------------------------------------------------------------------------+
 | Cursor Declarations                                                    |
 +-----------------------------------------------------------------------*/
		-- R12 for loan_types
    cursor c_loan_info(p_loan_id NUMBER)
    is
    select h.loan_class_code
          ,t.loan_type_id
        --  ,h.funded_amount
	  ,h.requested_amount   -- Bug#9755933
      from lns_loan_headers_all h
					,lns_loan_types t
     where h.loan_id = p_loan_id
		   and h.loan_type_id = t.loan_type_id;

    cursor c_loan_info2(p_loan_id NUMBER, p_disb_header_id number)
    is
    select h.loan_class_code
          ,t.loan_type_id
          ,d.header_amount
      from lns_loan_headers_all h
					,lns_loan_types t
					,lns_disb_headers d
     where h.loan_id = p_loan_id
		   and h.loan_type_id = t.loan_type_id
			 and h.loan_id = d.loan_id
			 and d.disb_header_id = p_disb_header_id;

    cursor c_loan_info3(c_loan_id NUMBER, c_loan_amount_adj_id number)
    is
    select h.loan_class_code
          ,t.loan_type_id
          ,ladj.adjustment_amount
      from lns_loan_headers_all h
		,lns_loan_types t
		,LNS_LOAN_AMOUNT_ADJS ladj
     where h.loan_id = p_loan_id
	and h.loan_type_id = t.loan_type_id
	and h.loan_id = ladj.loan_id
        and ladj.status = 'PENDING'
	and ladj.loan_amount_adj_id = c_loan_amount_adj_id;


    cursor c_num_receivables(p_loan_class varchar2, p_loan_type_id number)
    is
    select count(1)
      from lns_default_distribs
     where loan_class = p_loan_class
       AND loan_type_id  = p_loan_type_id
       and account_name = 'LOAN_RECEIVABLE'
       and distribution_type = 'ORIGINATION'
       and account_type      = 'DR';

    cursor c_num_payables(p_loan_class varchar2, p_loan_type_id number)
    is
    select count(1)
      from lns_default_distribs
     where loan_class = p_loan_class
       AND loan_type_id  = p_loan_type_id
       and account_name = 'LOAN_PAYABLE'
       and distribution_type = 'FUNDING'
       and account_type      = 'DR';

begin
     SAVEPOINT defaultDistributionsCatch;
     l_api_name := 'defaultDistributionsCatch';
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = ' || p_loan_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_header_id = ' || p_disb_header_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = ' || p_loan_amount_adj_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_include_loan_receivables = ' || p_include_loan_receivables);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_distribution_type = ' || p_distribution_type);

     -- Initialize message list IF p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     n := 0;
     k := 0;
     l := 0;
     m := 0;
     l_running_amount1 := 0;
     l_running_amount2 := 0;
     l_running_amount3 := 0;
     l_running_amount4 := 0;
     l_ledger_details   := lns_distributions_pub.getLedgerDetails;

     -- get class and type for the loan
     l_adj_reversal := 'N';
     if p_loan_amount_adj_id is not null then
        OPEN c_loan_info3(p_loan_id, p_loan_amount_adj_id);
        FETCH c_loan_info3 INTO l_class, l_loan_type_id, l_funded_amount;
        close c_loan_info3;
        if l_funded_amount < 0 then
          logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Before reversal, l_funded_amount = ' || l_funded_amount);
          l_adj_reversal  :=  'Y';
          l_funded_amount := -(l_funded_amount);
          logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'After reversal, l_funded_amount = ' || l_funded_amount);
        end if;
     elsif p_disb_header_id is null then
        OPEN c_loan_info(p_loan_id);
        FETCH c_loan_info INTO l_class, l_loan_type_id, l_funded_amount;
        close c_loan_info;
     elsif p_disb_header_id is not null then
        OPEN c_loan_info2(p_loan_id, p_disb_header_id);
        FETCH c_loan_info2 INTO l_class, l_loan_type_id, l_funded_amount;
        close c_loan_info2;
     end if;
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_class = ' || l_class);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_type_id = ' || l_loan_type_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_funded_amount = ' || l_funded_amount);

     open c_num_receivables(l_class, l_loan_type_id);
     fetch c_num_receivables into l_loan_receivables_count;
     close c_num_receivables;
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_receivables_count = ' || l_loan_receivables_count);

     open c_num_payables(l_class, l_loan_type_id);
     fetch c_num_payables into l_loan_payables_count;
     close c_num_payables;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_payables_count = ' || l_loan_payables_count);

     -- now see if any default distributions exist for this loan
     -- 2-24-2005 raverma -- add loan_payable IF loan_class = DIRECT OR
     --                                             loan is not MFAR
     -- Bug#5295575 Modified the query to work for an organization instead
     -- of working for all organzations by replacing  lns_default_distribs_all
     -- with lns_default_distribs table


     Begin
         vPLSQL := 'SELECT d.line_type                 ' ||
                   '      ,d.account_name              ' ||
                   '      ,d.code_combination_id       ' ||
                   '      ,d.account_type              ' ||
                   '      ,d.distribution_percent      ' ||
                   '      ,d.distribution_type         ' ||
                   'FROM lns_default_distribs  d       ' ||
                   'WHERE ((d.loan_class = :p_loan_class_code AND d.loan_type_id  = :p_loan_type_id) ) ' ||
                   '  AND account_name IN (''PRINCIPAL_RECEIVABLE'', ''INTEREST_RECEIVABLE'', ''INTEREST_INCOME'' ';

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'include receivabvles ' || p_include_loan_receivables);
        -- these are only appropriate for class=DIRECT or loan <> MFAR
        if p_include_loan_receivables = 'Y' then
            vPLSQL := vPLSQL || ' ,''LOAN_RECEIVABLE'', ''LOAN_CLEARING'', ''LOAN_PAYABLE'')';
        else
            vPLSQL := vPLSQL || ' )';
        end if;

            if p_distribution_type is not null then
            vPLSQL := vPLSQL || ' AND d.distribution_type = ' || '''' || p_distribution_type || '''';
            end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'sql: ' || vPLSQL);

        open sql_cur for
                vPLSQL
            using l_class, l_loan_type_id;
        LOOP
            fetch sql_cur into  l_line_type
                            ,l_account_name
                            ,l_code_combination_id
                            ,l_account_type
                            ,l_distribution_percent
                            ,l_distribution_type;
            exit when sql_cur%NOTFOUND;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_adj_reversal = ' || l_adj_reversal);


            if (l_adj_reversal = 'Y' and l_distribution_type = 'ORIGINATION') then
              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_type = ' || l_account_type);
              if l_account_type = 'DR' then
                l_account_type := 'CR';
              elsif l_account_type = 'CR' then
                l_account_type := 'DR';
              end if;
            end if;

            i := i + 1;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Record ' || i);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_line_type = ' || l_line_type);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_name = ' || l_account_name);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_type = ' || l_account_type);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_percent = ' || l_distribution_percent);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_type = ' || l_distribution_type);


            l_distributions(i).line_type              := l_line_type;
            l_distributions(i).account_name           := l_account_name;
            l_distributions(i).code_combination_id    := l_code_combination_id;
            l_distributions(i).account_type           := l_account_type;
            l_distributions(i).distribution_percent   := l_distribution_percent;
            l_distributions(i).distribution_type      := l_distribution_type;

            if l_account_name = 'LOAN_RECEIVABLE' and l_distribution_type = 'ORIGINATION' then

                k := k + 1;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan receivables line ' || k);

                if k <> l_loan_receivables_count then
                    l_distributions(i).distribution_amount    := round(l_distribution_percent * l_funded_amount, l_ledger_details.currency_precision) / 100;
                    l_running_amount1 := l_running_amount1 + l_distributions(i).distribution_amount;
                else
                    l_distributions(i).distribution_amount    := l_funded_amount - l_running_amount1;
                end if;

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distributions(i).distribution_amount = ' || l_distributions(i).distribution_amount);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_running_amount1 = ' || l_running_amount1);

            end if;

            if (l_account_name = 'LOAN_CLEARING' or l_account_name = 'LOAN_PAYABLE') and l_distribution_type = 'ORIGINATION' then

                n := n + 1;
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan clearing line ' || n);

                if n <> l_loan_receivables_count then
                    l_distributions(i).distribution_amount    := round(l_distribution_percent * l_funded_amount, l_ledger_details.currency_precision) / 100;
                    l_running_amount2 := l_running_amount2 + l_distributions(i).distribution_amount;
                else
                    l_distributions(i).distribution_amount    := l_funded_amount - l_running_amount2;
                end if;

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distributions(i).distribution_amount = ' || l_distributions(i).distribution_amount);
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_running_amount2 = ' || l_running_amount2);

            end if;

        end loop;
        close sql_cur;

     exception
       when no_data_found then
           FND_MESSAGE.SET_NAME('LNS', 'LNS_DEFAULT_DIST_NOT_FOUND');
           FND_MSG_PUB.ADD;
           logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
           RAISE FND_API.G_EXC_ERROR;
     End; -- c_default_info cursor

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'distribs2 count is ' || l_distributions.count);
     x_distribution_tbl := l_distributions;

     IF FND_API.to_Boolean(p_commit)
     THEN
         COMMIT WORK;
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO defaultDistributionsCatch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO defaultDistributionsCatch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO defaultDistributionsCatch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

end defaultDistributionsCatch;



/*=========================================================================
|| PUBLIC PROCEDURE create_event
||
|| DESCRIPTION
|| Overview: will write to xla_events table and update lns_distributions
||           this can handle a set of accounting event records
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_acc_event_tbl => table of accounting records
||           ,p_event_type_code    => seeded code for loans "APPROVED" "IN_FUNDING"
||           ,p_event_date         => most likely GL_DATE
||           ,p_event_status       => event Status
||             CONSTANT  = 'U';   -- event status:unprocessed
||             CONSTANT  = 'I';   -- event status:incomplete
||             CONSTANT  = 'N';   -- event status:noaction
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 8/3/2005             raverma           Created
||
 *=======================================================================*/
procedure create_event(p_acc_event_tbl      in  LNS_DISTRIBUTIONS_PUB.acc_event_tbl
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2)

is
    l_api_name            varchar2(25);
    l_loan_class			     varchar2(30);
    l_loan_type_id        number;
    l_distributions       LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_return_Status       VARCHAR2(1);
    l_event_id            number;

    cursor c_loan_info(p_loan_id number) is
    select h.loan_class_code
                    ,h.loan_type_id
        from lns_loan_headers_all h
    where h.loan_id = p_loan_id;

begin
    l_api_name           := 'create_event';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_acc_event_tbl count = ' || p_acc_event_tbl.count);

    -- Standard Start of API savepoint
    SAVEPOINT create_event;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- ---------------------------------------------------------------------
    -- Api body
    -- ---------------------------------------------------------------------
    for k in 1..p_acc_event_tbl.count loop

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_id = ' || p_acc_event_tbl(k).loan_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_type_code = ' || p_acc_event_tbl(k).event_type_code);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_acc_event_tbl('||k||').disb_header_id = ' || p_acc_event_tbl(k).disb_header_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_acc_event_tbl('||k||').loan_amount_adj_id = ' || p_acc_event_tbl(k).loan_amount_adj_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_date = ' || p_acc_event_tbl(k).event_date);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_status = ' || p_acc_event_tbl(k).event_status);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_bc_flag = ' || p_acc_event_tbl(k).budgetary_control_flag);


        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');
        LNS_XLA_EVENTS.create_event(p_loan_id         => p_acc_event_tbl(k).loan_id
                                    ,p_disb_header_id  => p_acc_event_tbl(k).disb_header_id
                                    ,p_loan_amount_adj_id => p_acc_event_tbl(k).loan_amount_adj_id
                                    ,p_event_type_code => p_acc_event_tbl(k).event_type_code
                                    ,p_event_date      => p_acc_event_tbl(k).event_date
                                    ,p_event_status    => p_acc_event_tbl(k).event_status
                                    ,p_bc_flag         => p_acc_event_tbl(k).budgetary_control_flag
                                    ,p_init_msg_list   => p_init_msg_list
                                    ,p_commit          => p_commit
                                    ,x_event_id        => l_event_id
                                    ,x_return_status   => x_return_status
                                    ,x_msg_count       => x_msg_count
                                    ,x_msg_data        => x_msg_data);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_return_status = ' || x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
            FND_MSG_PUB.ADD;
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
            -- update the distributions table with proper event_id for valid disb_header_id/loan_amount_adj_id
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_distributions...');
            update lns_distributions
            set event_id = l_event_id
            ,last_update_date = sysdate
           -- where (disb_header_id IS NULL OR disb_header_id = p_acc_event_tbl(k).disb_header_id)
           --   and (loan_amount_adj_id IS NULL OR loan_amount_adj_id = p_acc_event_tbl(k).loan_amount_adj_id)
	   where nvl(disb_header_id, -1) = nvl(p_acc_event_tbl(k).disb_header_id,-1)
	   	and nvl(loan_amount_adj_id, -1) = nvl(p_acc_event_tbl(k).loan_amount_adj_id, -1)
              	and loan_id = p_acc_event_tbl(k).loan_id;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'In LNS_DISTRIBUTIONS_PUB.createEvent(), updation of event_id is done for '||SQL%ROWCOUNT||' rows');

        end if;

	end loop;
    -- ---------------------------------------------------------------------
    -- End of API body
    -- ---------------------------------------------------------------------
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO create_event;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO create_event;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
            ROLLBACK TO create_event;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end create_event;




/*=========================================================================
|| PRIVATE function getNaturalSwapAccount
||
|| DESCRIPTION
||         this procedure will return the swap the segment from loans setup
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS   p_loan_id = loan_id
||
|| Return value:  new swap segment value
||
|| Source Tables: lns_system_options
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 04-19-2005            raverma             Created
 *=======================================================================*/
function getNaturalSwapAccount(p_loan_id number) return varchar2
is

    -- this is cursor is for reading configuration for multi-fund swap natural account
    cursor c_mfar_nat_acct (p_loan_id number) is
    select MFAR_NATURAL_ACCOUNT_REC
    from lns_default_distribs_all d
        ,lns_loan_headers_all h
    where account_name = 'MFAR_FUND_ACCOUNT_CHANGE'
      and h.loan_id = p_loan_id
      and h.loan_class_code = d.loan_class
      and h.loan_type_id  = d.loan_type_id
      and h.org_id = d.org_id;

    l_segment_value   varchar2(60);

begin

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Opening c_mfar_nat_acct...');
    open c_mfar_nat_acct(p_loan_id);
    fetch c_mfar_nat_acct into l_segment_value;
    close c_mfar_nat_acct;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_segment_value = ' || l_segment_value);

	return l_segment_value;

Exception
    When others then
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'failed to retrieve replacement natural account');
        FND_MESSAGE.SET_NAME('LNS', 'LNS_MFAR_CONFIGURATION_ERROR');
        FND_MSG_PUB.ADD;
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

end getNaturalSwapAccount;

/*=========================================================================
|| PRIVATE PROCEDURE swap_code_combination
||
|| DESCRIPTION
||         this procedure will swap the segment at given segment number
||         with given value and create and return the new cc_id
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS   p_chart_of_accounts_id => chart of accounts id
||              p_original_cc_id       => original cc_id
||              p_swap_segment_number  => segment number to swap
||              p_swap_segment_value   => segment value to swap with
||
|| Return value:  new code_combination_id
||
|| Source Tables:
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 04-19-2005            raverma             Created
 *=======================================================================*/
function swap_code_combination(p_chart_of_accounts_id in number
                              ,p_original_cc_id       in number
                              ,p_swap_segment_number  in number
                              ,p_swap_segment_value   in varchar
                              ) return number

is
    l_original_segments   FND_FLEX_EXT.SEGMENTARRAY;
    l_new_segments        FND_FLEX_EXT.SEGMENTARRAY;
    l_num_segments        number;
    l_api_name            varchar2(50);
    l_new_cc_id           number;

begin
    l_api_name  := 'swap_code_combination';
    l_new_cc_id := -1;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_chart_of_accounts_id  = ' || p_chart_of_accounts_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_original_cc_id  = ' || p_original_cc_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_swap_segment_number  = ' || p_swap_segment_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_swap_segment_value  = ' || p_swap_segment_value);

    -- build the original code combination segments into array
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling FND_FLEX_EXT.GET_SEGMENTS...');
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL'
                                     ,'GL#'
                                     ,p_chart_of_accounts_id
                                     ,p_original_cc_id
                                     ,l_num_segments
                                     ,l_original_segments))
    Then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ERR_BUILDING_SEGMENTS');
        FND_MSG_PUB.ADD;
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Original segments:');
    for n in 1..l_num_segments loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'seg#' || n || ' = ' || l_original_segments(n));
    end loop;

    -- get the replacement accounts from lns_default_distribs
    FOR n IN 1..l_num_segments LOOP
        IF (n = p_swap_segment_number) THEN
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'found the account to swap = ' || l_original_segments(n));
            l_new_segments(n) := p_swap_segment_value;
        else
            l_new_segments(n) := l_original_segments(n);
        END IF;
    END LOOP;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'New segments:');
    for n in 1..l_num_segments loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'seg#' || n || ' = ' || l_new_segments(n));
    end loop;

    -------------------------- Get new ccid -------------------------------
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling FND_FLEX_EXT.GET_COMBINATION_ID...');
    iF (NOT FND_FLEX_EXT.GET_COMBINATION_ID(
                            'SQLGL',
                            'GL#',
                            p_chart_of_accounts_id,
                            SYSDATE,
                            l_num_segments,
                            l_new_segments,
                            l_new_cc_id))
    Then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CODE_COMBINATION_ERROR');
        FND_MSG_PUB.ADD;
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    END IF;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'new cc_id = ' || l_new_cc_id);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_new_cc_id;

exception
    when others then
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'failed to create new code combination');
        RAISE FND_API.G_EXC_ERROR;
end swap_code_combination;


/*=========================================================================
|| PRIVATE PROCEDURE  transformDistribution
||
|| DESCRIPTION
||         this function is currently not used nor finished
||         the idea was to include this function into the transaction_object as
||         part of the accounting sources within AAD
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Return value:  new code_combination_id
||
|| Source Tables:
||
|| Target Tables: NA
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 06-19-2005            raverma             Created
 *=======================================================================*/
function transformDistribution(p_distribution_id   number
                                ,p_distribution_type varchar2
                                ,p_loan_id           number) return number
is

	l_new_cc_id  		       number;
    l_ledger_details   		 lns_distributions_pub.gl_ledger_details;
    l_natural_account_rec  varchar2(25);  -- the lns_def_distribs replacement  for Loans Receivable
    l_nat_acct_seg_number  number;
	l_api_name					   varchar2(25);

	-- gets the swap natural account value for LOAN_RECEIVABLE
    cursor c_mfar_nat_acct (p_loan_id number) is
    select MFAR_NATURAL_ACCOUNT_REC
    from lns_default_distribs d
        ,lns_loan_headers h
    where account_name = 'MFAR_FUND_ACCOUNT_CHANGE'
      and h.loan_id = p_loan_id
      and h.loan_class_code = d.loan_class
      and h.loan_type_id  = d.loan_type_id;

begin

    l_ledger_details   := lns_distributions_pub.getLedgerDetails;
    -- given a code_combination
    if p_distribution_type = 'LOAN_RECEIVABLE' then

        -- build new cc_id
        Begin
            -- swap account is established from set-up
            open c_mfar_nat_acct(p_loan_id);
            fetch c_mfar_nat_acct into l_natural_account_rec;
            close c_mfar_nat_acct;

        Exception
            When others then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_MFAR_CONFIGURATION_ERROR');
                FND_MSG_PUB.ADD;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
        End;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'swap natural account with ' || l_natural_account_rec);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'COA ' || l_ledger_details.chart_of_accounts_id);

        -- Get natural account segment number to swap
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling FND_FLEX_APIS.GET_QUALIFIER_SEGNUM...');
        IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(appl_id         => 101
                                                ,key_flex_code   => 'GL#'
                                                ,structure_number=> l_ledger_details.chart_of_accounts_id
                                                ,flex_qual_name  => 'GL_ACCOUNT'
                                                ,segment_number  => l_nat_acct_seg_number))
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_NATURAL_ACCOUNT_SEGMENT');
            FND_MSG_PUB.ADD;
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'natural acct segment is ' || l_nat_acct_seg_number);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling swap_code_combination...');
        l_new_cc_id := swap_code_combination(p_chart_of_accounts_id => l_ledger_details.chart_of_accounts_id
                                            ,p_original_cc_id       => p_distribution_id
                                            ,p_swap_segment_number  => l_nat_acct_seg_number
                                            ,p_swap_segment_value   => l_natural_account_rec);

    elsif p_distribution_type = 'LOAN_CLEARING' then
        -- get adjustment cc_id
        l_new_cc_id := 123;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_new_cc_id = ' || l_new_cc_id);
    return l_new_cc_id;

end transformDistribution;


/*=========================================================================
|| function getDefaultDistributions
||
|| DESCRIPTION
||      This function returns default distribution entities
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||   p_loan_class = loan class
||   p_loan_type = loan_type
||   p_account_type  = 'CR' or 'DR'
||   p_account_name  = 'LOAN_RECEIVABLE' 'LOAN_CLEARING', 'PRINCIPAL_RECIEVABLE',
||                     'INTEREST_RECEIVABLE', 'INTEREST_INCOME'
||                      'FEE_RECEIVABLE', 'FEE_INCOME'
||
||   p_line_type     = 'ORIG', 'PRIN', 'INT', 'CLEAR' , 'FEE'
||   p_distribution_type = 'ORIGINATION' , 'BILLING', 'FUNDING'
||
|| Return value:  table of distribution entities
||
|| Source Tables: lns_distributions
||
|| Target Tables:
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 06-28-2004            raverma             Created
||
 *=======================================================================*/
function getDefaultDistributions(p_loan_class        in varchar2
                                ,p_loan_type_id      in number
                                ,p_account_type      in varchar2
                                ,p_account_name      in varchar2
                                ,p_line_type         in varchar2
                                ,p_distribution_type in varchar2) return LNS_DISTRIBUTIONS_PUB.default_distributions_tbl
is
    x_distribution_tbl         LNS_DISTRIBUTIONS_PUB.default_distributions_tbl;
    l_index                		 number := 1;
    l_loan_id              		 number;
    l_loan_class           		 varchar2(30);
    l_loan_type_id         		 number;
    l_line_type            		 varchar2(30);
    l_account_name         		 varchar2(30);
    l_code_combination_id  		 number;
    l_distribution_percent 		 number;
    l_distribution_type        varchar2(30);
    l_fee_id                   number;
    l_org_id                   number;
    l_mfar_natural_account_rec varchar2(60);

    cursor c_get_distribution(p_loan_class   varchar2
                             ,p_loan_type_id number
                             ,p_acct_type    varchar2
                             ,p_acct_name 	 varchar2
                             ,p_line_type    varchar2
                             ,p_distribution_type varchar2) is
       select loan_class
             ,loan_type_id
             ,line_type
             ,account_name
             ,code_combination_id
             ,distribution_percent
             ,distribution_type
             ,FEE_ID
             ,ORG_ID
             ,MFAR_NATURAL_ACCOUNT_REC
       from lns_default_distribs
       where loan_class = p_loan_class
         and loan_type_id  = p_loan_type_id
         and account_type = p_acct_type
         and account_name = p_acct_name
         and line_type = p_line_type
         and distribution_type = p_distribution_type
         and distribution_percent > 0
    order by code_combination_id;

    l_api_name              varchar2(30);

begin

    l_api_name  := 'getDefaultDistributions';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_class = ' || p_loan_class);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan typeID = ' || p_loan_type_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account type = ' || p_account_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account name = ' || p_account_name);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'line tpye = ' || p_line_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'distribution type = ' || p_distribution_type);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'opening c_get_distribution...');
    OPEN c_get_distribution (p_loan_class
                            ,p_loan_type_id
                            ,p_account_type
                            ,p_account_name
                            ,p_line_type
                            ,p_distribution_type);
    LOOP
        FETCH C_Get_Distribution into
            l_loan_class
            ,l_loan_type_id
            ,l_line_type
            ,l_account_name
            ,l_code_combination_id
            ,l_distribution_percent
            ,l_distribution_type
            ,l_fee_id
            ,l_org_id
            ,l_mfar_natural_account_rec;
        EXIT WHEN C_Get_Distribution%NOTFOUND;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Record ' || l_index);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_class = ' || l_loan_class);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_type_id = ' || l_loan_type_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_line_type = ' || l_line_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_name = ' || l_account_name);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_percent = ' || l_distribution_percent);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_type = ' || l_distribution_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_fee_id = ' || l_fee_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_org_id = ' || l_org_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_mfar_natural_account_rec = ' || l_mfar_natural_account_rec);

        x_distribution_tbl(l_index).line_type                   := l_line_type;
        x_distribution_tbl(l_index).account_name                := l_account_name;
        x_distribution_tbl(l_index).code_combination_id         := l_code_combination_id;
        x_distribution_tbl(l_index).distribution_percent        := l_distribution_percent;
        x_distribution_tbl(l_index).distribution_type           := l_distribution_type;
        x_distribution_tbl(l_index).fee_id                      := l_fee_id;
        x_distribution_tbl(l_index).org_id                      := l_org_id;
        x_distribution_tbl(l_index).mfar_natural_account_rec    := l_mfar_natural_account_rec;
        l_line_type                 := null;
        l_account_name              := null;
        l_code_combination_id       := null;
        l_distribution_percent      := null;
        l_distribution_type         := null;
        l_fee_id                    := null;
        l_org_id                    := null;
        l_mfar_natural_account_rec  := null;

        l_index := l_index + 1;

    END LOOP;

    CLOSE C_Get_Distribution;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'found: ' || x_distribution_tbl.count || ' distributions');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    return x_distribution_tbl;

end getDefaultDistributions;

/*=========================================================================
|| function getDistributions
||
|| DESCRIPTION
||      This function returns distribution entities
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||   p_loan_id = loan_id
||   p_account_type  = 'CR' or 'DR'
||   p_account_name  = 'LOAN_RECEIVABLE' 'LOAN_CLEARING', 'PRINCIPAL_RECIEVABLE',
||                     'INTEREST_RECEIVABLE', 'INTEREST_INCOME'
||                      'FEE_RECEIVABLE', 'FEE_INCOME'
||   p_line_type     = 'ORIG', 'PRIN', 'INT', 'CLEAR' , 'FEE'
||   p_distribution_type = 'ORIGINATION' , 'BILLING'  , ' FUNDING'
||
|| Return value:  table of distribution entities
||
|| Source Tables: lns_distributions
||
|| Target Tables:
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 04-26-2004            raverma             Created
||
 *=======================================================================*/
function getDistributions(p_loan_id           in number
                         ,p_account_type      in varchar2
                         ,p_account_name      in varchar2
                         ,p_line_type         in varchar2
                         ,p_distribution_type in varchar2) return LNS_DISTRIBUTIONS_PUB.distribution_tbl

is

    l_api_name             varchar2(30);
    x_distribution_tbl     lns_distributions_pub.distribution_tbl;
    l_index                number;
    l_loan_id              number;
    l_distribution_id      number;
    l_line_type            varchar2(30);
    l_account_name         varchar2(30);
    l_code_combination_id  number;
    l_distribution_percent number;
    l_distribution_amount  number;
    l_distribution_type    varchar2(30);
    l_event_id             number;

    cursor c_get_distribution(x_loan_id number
                             ,x_acct_type varchar2
                             ,x_acct_name varchar2
                             ,x_line_type varchar2
                             ,x_distribution_type varchar2) is
       select d.distribution_id
             ,d.loan_id
             ,d.line_type
             ,d.account_name
             ,d.code_combination_id
             ,d.distribution_percent
             ,d.distribution_amount
             ,d.distribution_type
             ,d.event_id
       from lns_distributions d
       where d.loan_id = x_loan_id
         and d.account_type = x_acct_type
         and d.account_name = x_acct_name
         and d.line_type = x_line_type
         and d.distribution_type = x_distribution_type
         and d.distribution_percent > 0
        order by d.code_combination_id;

begin

    l_api_name    := 'getDistributions';
    l_index       := 0;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_account_type = ' || p_account_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_account_name = ' || p_account_name);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_line_type = ' || p_line_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_distribution_type = ' || p_distribution_type);
    x_distribution_tbl.delete;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'opening c_get_distribution...');
    OPEN c_get_distribution (p_loan_id
                            ,p_account_type
                            ,p_account_name
                            ,p_line_type
                            ,p_distribution_type);
    LOOP
        FETCH C_Get_Distribution into
            l_distribution_id
            ,l_loan_id
            ,l_line_type
            ,l_account_name
            ,l_code_combination_id
            ,l_distribution_percent
            ,l_distribution_amount
            ,l_distribution_type
            ,l_event_id;
        EXIT WHEN C_Get_Distribution%NOTFOUND;
        l_index := l_index + 1;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Record ' || l_index);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_id = ' || l_distribution_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_id = ' || l_loan_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_line_type = ' || l_line_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_name = ' || l_account_name);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_percent = ' || l_distribution_percent);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_amount = ' || l_distribution_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_type = ' || l_distribution_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);

        x_distribution_tbl(l_index).distribution_id        := l_distribution_id;
        x_distribution_tbl(l_index).loan_id                := l_loan_id;
        x_distribution_tbl(l_index).line_type              := l_line_type;
        x_distribution_tbl(l_index).account_name           := l_account_name;
        x_distribution_tbl(l_index).code_combination_id    := l_code_combination_id;
        x_distribution_tbl(l_index).distribution_percent   := l_distribution_percent;
        x_distribution_tbl(l_index).distribution_amount    := l_distribution_amount;
        x_distribution_tbl(l_index).distribution_type      := l_distribution_type;
        x_distribution_tbl(l_index).event_id               := l_event_id;
        x_distribution_tbl(l_index).account_type           := p_account_type;
        l_distribution_id       := null;
        l_loan_id               := null;
        l_line_type             := null;
        l_account_name          := null;
        l_code_combination_id   := null;
        l_distribution_percent  := null;
        l_distribution_amount   := null;
        l_distribution_type     := null;
        l_event_id              := null;

    END LOOP;

    CLOSE C_Get_Distribution;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'found: ' || x_distribution_tbl.count || ' distributions');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    return x_distribution_tbl;

end getDistributions;

function getDistributions(p_distribution_id in number) return LNS_DISTRIBUTIONS_PUB.distribution_rec

is

    x_distribution_rec     lns_distributions_pub.distribution_rec;
    l_api_name             varchar2(30);

    cursor c_get_distribution(x_distribution_id number) is
       select distribution_id
             ,loan_id
             ,line_type
             ,account_name
             ,code_combination_id
             ,distribution_percent
             ,distribution_amount
             ,distribution_type
             ,account_type
             ,account_name
             ,event_id
       from lns_distributions
       where distribution_id = x_distribution_id
         and distribution_percent > 0;

begin
    l_api_name    := 'getDistributions';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    OPEN c_get_distribution (p_distribution_id);
      FETCH C_Get_Distribution into
           x_distribution_rec.distribution_id
          ,x_distribution_rec.loan_id
          ,x_distribution_rec.line_type
          ,x_distribution_rec.account_name
          ,x_distribution_rec.code_combination_id
          ,x_distribution_rec.distribution_percent
          ,x_distribution_rec.distribution_amount
          ,x_distribution_rec.distribution_type
          ,x_distribution_rec.account_type
          ,x_distribution_rec.account_name
          ,x_distribution_rec.event_id;
    CLOSE C_Get_Distribution;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'distribution_id = ' || x_distribution_rec.distribution_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_id = ' || x_distribution_rec.loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'line_type = ' || x_distribution_rec.line_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account_name = ' || x_distribution_rec.account_name);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'code_combination_id = ' || x_distribution_rec.code_combination_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'distribution_percent = ' || x_distribution_rec.distribution_percent);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'distribution_amount = ' || x_distribution_rec.distribution_amount);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'distribution_type = ' || x_distribution_rec.distribution_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account_type = ' || x_distribution_rec.account_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account_name = ' || x_distribution_rec.account_name);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'event_id = ' || x_distribution_rec.event_id);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    return x_distribution_rec;

end getDistributions;

/*=========================================================================
|| function getDistributions
||
|| DESCRIPTION
||      This function returns distribution entities
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||   p_loan_id = loan_id
||   p_loan_line_id = loan_line_id
||   p_account_type  = 'CR' or 'DR'
||   p_account_name  = 'LOAN_RECEIVABLE' 'LOAN_CLEARING', 'PRINCIPAL_RECIEVABLE',
||                     'INTEREST_RECEIVABLE', 'INTEREST_INCOME'
||                      'FEE_RECEIVABLE', 'FEE_INCOME'
||   p_line_type     = 'ORIG', 'PRIN', 'INT', 'CLEAR' , 'FEE'
||   p_distribution_type = 'ORIGINATION' , 'BILLING'  , ' FUNDING'
||
|| Return value:  table of distribution entities
||
|| Source Tables: lns_distributions
||
|| Target Tables:
||
|| KNOWN ISSUES
||
|| NOTES
||
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 04-01-2010            raverma             Created
||
 *=======================================================================*/
function getDistributions(p_loan_id           in number
                         ,p_loan_line_id      in number
                         ,p_account_type      in varchar2
                         ,p_account_name      in varchar2
                         ,p_line_type         in varchar2
                         ,p_distribution_type in varchar2) return LNS_DISTRIBUTIONS_PUB.distribution_tbl

is

    l_api_name             varchar2(30);
    x_distribution_tbl     lns_distributions_pub.distribution_tbl;
    l_index                number;
    l_loan_id              number;
    l_distribution_id      number;
    l_line_type            varchar2(30);
    l_account_name         varchar2(30);
    l_account_type         varchar2(30);
    l_code_combination_id  number;
    l_distribution_percent number;
    l_distribution_amount  number;
    l_distribution_type    varchar2(30);
    l_event_id             number;

    cursor c_get_distribution(x_loan_id number
                             ,x_loan_line_id number
                             ,x_acct_type varchar2
                             ,x_acct_name varchar2
                             ,x_line_type varchar2
                             ,x_distribution_type varchar2) is
       select d.distribution_id
             ,d.loan_id
             ,d.line_type
             ,d.account_name
             ,d.account_type
             ,d.code_combination_id
             ,d.distribution_percent
             ,d.distribution_amount
             ,d.distribution_type
             ,d.event_id
       from lns_distributions d
       where d.loan_id = x_loan_id
         and d.loan_line_id = x_loan_line_id
         and d.account_type = x_acct_type
         and d.account_name = x_acct_name
         and d.line_type = x_line_type
         and d.distribution_type = x_distribution_type
         and d.distribution_percent > 0
        order by d.code_combination_id;

begin

    l_api_name    := 'getDistributions';
    l_index       := 0;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_line_id = ' || p_loan_line_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_account_type = ' || p_account_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_account_name = ' || p_account_name);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_line_type = ' || p_line_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_distribution_type = ' || p_distribution_type);
    x_distribution_tbl.delete;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'opening c_get_distribution...');
    OPEN c_get_distribution (p_loan_id
                            ,p_loan_line_id
                            ,p_account_type
                            ,p_account_name
                            ,p_line_type
                            ,p_distribution_type);
    LOOP
        FETCH C_Get_Distribution into
            l_distribution_id
            ,l_loan_id
            ,l_line_type
            ,l_account_name
            ,l_account_type
            ,l_code_combination_id
            ,l_distribution_percent
            ,l_distribution_amount
            ,l_distribution_type
            ,l_event_id;
        EXIT WHEN C_Get_Distribution%NOTFOUND;
        l_index := l_index + 1;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Record ' || l_index);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_id = ' || l_distribution_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_id = ' || l_loan_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_line_type = ' || l_line_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_name = ' || l_account_name);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_type = ' || l_account_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_percent = ' || l_distribution_percent);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_amount = ' || l_distribution_amount);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_type = ' || l_distribution_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);

        x_distribution_tbl(l_index).distribution_id        := l_distribution_id;
        x_distribution_tbl(l_index).loan_id                := l_loan_id;
        x_distribution_tbl(l_index).line_type              := l_line_type;
        x_distribution_tbl(l_index).account_name           := l_account_name;
        x_distribution_tbl(l_index).account_type           := l_account_type;
        x_distribution_tbl(l_index).code_combination_id    := l_code_combination_id;
        x_distribution_tbl(l_index).distribution_percent   := l_distribution_percent;
        x_distribution_tbl(l_index).distribution_amount    := l_distribution_amount;
        x_distribution_tbl(l_index).distribution_type      := l_distribution_type;
        x_distribution_tbl(l_index).event_id               := l_event_id;
        l_distribution_id       := null;
        l_loan_id               := null;
        l_line_type             := null;
        l_account_name          := null;
        l_account_type          := null;
        l_code_combination_id   := null;
        l_distribution_percent  := null;
        l_distribution_amount   := null;
        l_distribution_type     := null;
        l_event_id              := null;

    END LOOP;

    CLOSE C_Get_Distribution;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'found: ' || x_distribution_tbl.count || ' distributions');
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    return x_distribution_tbl;

end getDistributions;


/*=========================================================================
|| PUBLIC PROCEDURE getLedgerDetails
||
|| DESCRIPTION
||      This procedure gets details about the General Ledger
||      THIS FUNCTION IS THE MAIN INTERFACE INTO GENERAL LEDGER
||
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||
|| Return value:
||  type gl_ledger_details is record(SET_OF_BOOKS_ID      NUMBER(15)
||                                  ,NAME                 VARCHAR2(30)
||                                  ,SHORT_NAME           VARCHAR2(20)
||                                  ,CHART_OF_ACCOUNTS_ID NUMBER(15)
||                                  ,PERIOD_SET_NAME      VARCHAR2(15));
||
|| Source Tables: LNS_SYSTEM_OPTIONS, GL_SETS_OF_BOOKS
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
|| 02-18-2004            raverma             Created
||
 *=======================================================================*/
function getLedgerDetails return lns_distributions_pub.gl_ledger_details
is
    cursor c_ledger
    is
    SELECT  so.set_of_books_id
           ,sb.name
           ,sb.short_name
           ,sb.chart_of_accounts_id
           ,sb.period_set_name
           ,sb.currency_code
           ,fndc.precision
      FROM lns_system_options so,
           gl_ledgers sb,
           fnd_currencies fndc
     WHERE sb.ledger_id = so.set_of_books_id
       and sb.currency_code = fndc.currency_code;

    l_ledger_details lns_distributions_pub.gl_ledger_details;

begin

    begin
        open c_ledger;
        fetch c_ledger into  l_ledger_details.set_of_books_id
                            ,l_ledger_details.name
                            ,l_ledger_details.short_name
                            ,l_ledger_details.chart_of_accounts_id
                            ,l_ledger_details.period_set_name
                            ,l_ledger_details.currency_code
                            ,l_ledger_details.currency_precision;
        close c_ledger;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Ledger details:');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'set_of_books_id = ' || l_ledger_details.set_of_books_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'name = ' || l_ledger_details.name);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'short_name = ' || l_ledger_details.short_name);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'chart_of_accounts_id = ' || l_ledger_details.chart_of_accounts_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'period_set_name = ' || l_ledger_details.period_set_name);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'currency_code = ' || l_ledger_details.currency_code);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'currency_precision = ' || l_ledger_details.currency_precision);

        return l_ledger_details;

    exception
        when others then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_LEDGER_DETAILS_FAIL');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
    end;

end getLedgerDetails;

/*=========================================================================
|| PUBLIC FUNCTION calculateDistributionAmount
||
|| DESCRIPTION
||      calculatest the distribution amount based on the distribution percentage
||      this api assumes the defaultDistributions API has been called to
||      store the distributions on LNS_DISTRIBUTIONS
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||           p_distribution_id = pk to LNS_DISTRIBUTIONS
||
|| Return value: amount of distribution based from loan funded amount
||
|| Source Tables: lns_distributions, lns_loan_headers
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
|| 06/15/04 2:48:PM       raverma           Created
|| 09/07/04               raverma           enhance to know about all distributions on loan
||                                          bug #3736979
 *=======================================================================*/
function calculateDistributionAmount(p_distribution_id in number) return number

is
    l_api_name              varchar2(50);
    l_distribution_amount   number;
    l_ledger_details        lns_distributions_pub.gl_ledger_details;
    l_distribution_rec      lns_distributions_pub.distribution_rec;
    l_distribution_tbl      lns_distributions_pub.distribution_tbl;
    l_loan_id               number;
    l_max_distribution_id   number;

    cursor c_get_distribution(p_distribution_id number) is
    select round(lnh.funded_amount * lnd.distribution_percent / 100, curr.precision)
      from lns_distributions lnd
          ,lns_loan_headers lnh
          ,fnd_currencies  curr
     where lnh.loan_id = lnd.loan_id
       and curr.currency_code = lnh.loan_currency
       and lnd.distribution_id = p_distribution_id;

    -- cursor to find if this is the last distribution on the loan
    cursor c_max_dist(p_loan_id number
                     ,p_distribution_type varchar
                     ,p_account_type varchar2)    is
         select max(distribution_id)
           from lns_distributions lnd
               ,lns_loan_headers lnh
          where lnh.loan_id = lnd.loan_id
            and lnd.distribution_type = p_distribution_type
            and lnd.account_type = p_account_type
            and lnh.loan_id = p_loan_id;

    cursor c_last_distribution(p_loan_id number
                              ,p_distribution_id number
                              ,p_distribution_type varchar
                              ,p_account_type varchar2) is
    select
    lnh.funded_amount -
    (round(lnh.funded_amount *
    (select sum(distribution_percent) / 100
       from lns_distributions
      where distribution_id <> p_distribution_id
        and distribution_type = p_distribution_type
        and account_type = p_account_type
        and loan_id = p_loan_id), curr.precision))
      from lns_distributions lnd
          ,lns_loan_headers lnh
          ,fnd_currencies  curr
     where lnh.loan_id = lnd.loan_id
       and lnh.loan_id = p_loan_id
       and curr.currency_code = lnh.loan_currency;

begin

    l_api_name := 'calculateDistributionAmount';
    --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    l_ledger_details   := lns_distributions_pub.getLedgerDetails;
    l_distribution_rec := lns_distributions_pub.getDistributions(p_distribution_id);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loanID = ' || l_distribution_rec.loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DIST_ID = ' || p_distribution_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'disttype = ' || l_distribution_rec.distribution_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'accounttype = ' || l_distribution_rec.account_type);

    if l_distribution_rec.distribution_amount is null then
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling lns_distributions_pub.getDistributions...');
         l_distribution_tbl := lns_distributions_pub.getDistributions(p_loan_id           => l_distribution_rec.loan_id
                                                                     ,p_account_type      => l_distribution_rec.account_type
                                                                     ,p_account_name      => l_distribution_rec.account_name
                                                                     ,p_line_type         => l_distribution_rec.line_type
                                                                     ,p_distribution_type => l_distribution_rec.distribution_type);
        open c_max_dist(l_distribution_rec.loan_id
                       ,l_distribution_rec.distribution_type
                       ,l_distribution_rec.account_type);
        fetch c_max_dist into l_max_distribution_id;
        close c_max_dist;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_max_distribution_id = ' ||l_max_distribution_id);

        -- check to see if this is the last distribution
        if l_max_distribution_id = p_distribution_id and l_distribution_tbl.count > 1 then
           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'last distribution');
            open c_last_distribution(l_distribution_rec.loan_id
                                    ,l_distribution_rec.distribution_id
                                    ,l_distribution_rec.distribution_type
                                    ,l_distribution_rec.account_type);
            fetch c_last_distribution into l_distribution_amount;
            close c_last_distribution;
        else
        --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
            open c_get_distribution(p_distribution_id);
            fetch c_get_distribution into l_distribution_amount;
            close c_get_distribution;

        end if;
    else
        l_distribution_amount :=  l_distribution_rec.distribution_amount;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_amount = ' ||l_distribution_amount);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');
    return l_distribution_amount;

end calculateDistributionAmount;

/*========================================================================
|| PUBLIC FUNCTION calculateDistributionAmount
||
|| DESCRIPTION
||      calculatest the distribution amount based on the distribution percentage
||      this api assumes the defaultDistributions API has been called to
||      store the distributions on LNS_DISTRIBUTIONS
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||           p_distribution_id = pk to LNS_DISTRIBUTIONS
||           p_accounted_flag = 'Y' to get amount in set_of_books currency
||                              'N' to get amount in loan currency
||
|| Return value: amount of distribution based from loan funded amount
||
|| Source Tables: lns_distributions, lns_loan_headers
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
|| 06/15/04 2:48:PM       raverma           Created
|| 09/07/04               raverma           enhance to know about all distributions on loan
||                                          bug #3736979
 *=======================================================================*/
function calculateDistributionAmount(p_distribution_id in number
                                    ,p_accounted_flag  in varchar2) return number

is
    l_api_name              varchar2(50);
    l_distribution_amount   number;
    l_return                number;
    l_ledger_details        lns_distributions_pub.gl_ledger_details;
    l_distribution_rec      lns_distributions_pub.distribution_rec;
    l_distribution_tbl      lns_distributions_pub.distribution_tbl;
    l_loan_id               number;
    l_max_distribution_id   number;
    l_currency_code         varchar2(10);
    l_exchange_rate_type    varchar2(30);
    l_exchange_rate         number;
    l_exchange_date         date;

    cursor c_exchange_info(p_loan_id number) is
    select lnh.exchange_rate_type
          ,lnh.exchange_rate
          ,lnh.exchange_date
          ,lnh.loan_currency
      from lns_loan_headers lnh
     where loan_id = p_loan_id;

    cursor c_get_distribution(p_distribution_id number) is
    select round(lnh.funded_amount * lnd.distribution_percent / 100, curr.precision)
      from lns_distributions lnd
          ,lns_loan_headers lnh
          ,fnd_currencies  curr
     where lnh.loan_id = lnd.loan_id
       and curr.currency_code = lnh.loan_currency
       and lnd.distribution_id = p_distribution_id;

    cursor c_last_distribution(p_loan_id number
                              ,p_distribution_id number
                              ,p_distribution_type varchar
                              ,p_account_type varchar2) is
    select
    lnh.funded_amount -
    (round(lnh.funded_amount *
    (select sum(distribution_percent) / 100
       from lns_distributions
      where distribution_id <> p_distribution_id
        and distribution_type = p_distribution_type
        and account_type = p_account_type
        and loan_id = p_loan_id), curr.precision))
      from lns_distributions lnd
          ,lns_loan_headers lnh
          ,fnd_currencies  curr
     where lnh.loan_id = lnd.loan_id
       and lnh.loan_id = p_loan_id
       and curr.currency_code = lnh.loan_currency;

begin

    l_api_name := 'calculateDistributionAmount';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    l_ledger_details   := lns_distributions_pub.getLedgerDetails;
    l_distribution_rec := lns_distributions_pub.getDistributions(p_distribution_id);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loanID = ' || l_distribution_rec.loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DIST_ID = ' || p_distribution_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'disttype = ' || l_distribution_rec.distribution_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'accounttype = ' || l_distribution_rec.account_type);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'accounted flag = ' || p_accounted_flag);

    if p_accounted_flag = 'Y' then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loanID = ' || l_distribution_rec.loan_id);
        open c_exchange_info(l_distribution_rec.loan_id);
        fetch c_exchange_info into
            l_exchange_rate_type
           ,l_exchange_rate
           ,l_exchange_date
           ,l_currency_code;
        close c_exchange_info;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'exchange rate type = ' || l_exchange_rate_type);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'exchange rate = ' || l_exchange_rate);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'exchange date = ' || l_exchange_date);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'currency = ' || l_currency_code);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'currency2 = ' || l_ledger_details.CURRENCY_CODE);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'amount = ' || l_distribution_rec.distribution_amount);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling lns_utility_pub.convertAmount...');
        l_return    := lns_utility_pub.convertAmount(p_from_amount   => l_distribution_rec.distribution_amount
                                                    ,p_from_currency => l_currency_code  -- loan currency
                                                    ,p_to_currency   => l_ledger_details.CURRENCY_CODE  -- set of books currency
                                                    ,p_exchange_type => l_exchange_rate_type
                                                    ,p_exchange_date => l_exchange_date
                                                    ,p_exchange_rate => l_exchange_rate);
    else
        l_return := l_distribution_rec.distribution_amount;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'accounted amount = ' || l_return);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_return;

end calculateDistributionAmount;


function calculateDistAmount(p_distribution_id in number
                            ,p_accounted_flag  in varchar2) return varchar2
is

    l_api_name              varchar2(50);
    l_return                varchar2(100);
    l_currency              varchar2(10);
    l_char                  varchar2(25);
    l_amount                number;

    cursor c_currency1(p_distribution_id number) is
    select lnh.loan_currency
      from lns_loan_headers lnh
           ,lns_distributions lnd
     where lnh.loan_id = lnd.loan_id
       and lnd.distribution_id = p_distribution_id;

    cursor c_currency2 is
    SELECT sb.currency_code
      FROM lns_system_options so,
           gl_sets_of_books sb
     WHERE sb.set_of_books_id = so.set_of_books_id;

begin
    l_api_name := 'calculateDistAmount';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DIST_ID = ' || p_distribution_id);

    if p_accounted_flag = 'Y' then
        open c_currency2;
        fetch c_currency2 into l_currency;
        close c_currency2;
    else
        open c_currency1(p_distribution_id);
        fetch c_currency1 into l_currency;
        close c_currency1;
    end if;

    l_amount := lns_distributions_pub.calculateDistributionAmount(p_distribution_id => p_distribution_id
                                                                 ,p_accounted_flag  => p_accounted_flag);
    l_char := to_char(l_amount,  fnd_currency.safe_get_format_mask(l_currency,25));

    l_return := l_char || ' ' || l_currency;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'returned amount = ' || l_return);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

    return l_return;
end;

/*========================================================================
 | PUBLIC FUNCTION getFlexSegmentNumber
 |
 | DESCRIPTION
 |      returns the segmentNumber for a given segment attribute type
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_segment_attribute_type = 'GL_BALANCING' 'GL_ACCOUNT' etc
 | Return value: value_set_id
 |
 | Source Tables: fnd_id_flex_segments s, fnd_segment_attribute_values sav,
 |                fnd_segment_attribute_types sat
 |                lns_system_options lso
 |                gl_sets_of_books gl
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10/06/05 2:48:PM       raverma           Created
 *=======================================================================*/
function getFlexSegmentNumber(p_flex_code in varchar2
                             ,p_application_id in number
														 ,p_segment_attribute_type in varchar2) return number

is
	l_flex_seg_num number;

	cursor c_segmentNumber(p_flex_code varchar2, p_application_id number, p_segment_attribute_type varchar2)
	is
		SELECT s.segment_num
		  FROM fnd_id_flex_segments s
			   , fnd_segment_attribute_values sav
				 , fnd_segment_attribute_types sat
			   , lns_system_options lso
				 , gl_ledgers gl
		  WHERE s.application_id = p_application_id
		  and lso.set_of_books_id = gl.ledger_id
		  AND s.id_flex_code = p_flex_code
		  AND s.id_flex_num = gl.chart_of_accounts_id
		  AND s.enabled_flag = 'Y'
		  AND s.application_column_name = sav.application_column_name
		  AND sav.application_id = p_application_id
		  AND sav.id_flex_code = p_flex_code
		  AND sav.id_flex_num = gl.chart_of_accounts_id
		  AND sav.attribute_value = 'Y'
		  AND sav.segment_attribute_type = sat.segment_attribute_type
		  AND sat.application_id = p_application_id
		  AND sat.id_flex_code = p_flex_code
		  AND sat.unique_flag = 'Y'
      and sat.segment_attribute_type = p_segment_attribute_type;

begin

	l_flex_seg_num := -1;

	open c_segmentNumber(p_flex_code , p_application_id , p_segment_attribute_type );
	fetch c_segmentNumber into l_flex_seg_num;
	close c_segmentNumber;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_flex_seg_num = ' || l_flex_seg_num);

	return l_flex_seg_num;

end getFlexSegmentNumber;

/*========================================================================
 | PUBLIC FUNCTION getValueSetID
 |
 | DESCRIPTION
 |      returns a valueSetID for a given segment attribute
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_segment_attribute_type = 'GL_BALANCING' 'GL_ACCOUNT' etc
 | Return value: value_set_id
 |
 | Source Tables: fnd_id_flex_segments s, fnd_segment_attribute_values sav,
 |                fnd_segment_attribute_types sat
 |                lns_system_options lso
 |                gl_sets_of_books gl
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06/15/04 2:48:PM       raverma           Created
 |
 *=======================================================================*/
function getValueSetID(p_segment_attribute_type in varchar) return number
is
    l_value_set_id number;

    cursor c_valueSetID(p_segment_attribute_type varchar2) is
		 SELECT s.flex_value_set_id
      FROM fnd_id_flex_segments s
      ,fnd_segment_attribute_values sav
      ,fnd_segment_attribute_types sat
		  ,lns_system_options lso
		  ,gl_ledgers gl
		  WHERE s.application_id = 101
		  and lso.set_of_books_id = gl.ledger_id
		  AND s.id_flex_code = 'GL#'
		  AND s.id_flex_num = gl.chart_of_accounts_id
		  AND s.enabled_flag = 'Y'
		  AND s.application_column_name = sav.application_column_name
		  AND sav.application_id = 101
		  AND sav.id_flex_code = 'GL#'
		  AND sav.id_flex_num = gl.chart_of_accounts_id
		  AND sav.attribute_value = 'Y'
		  AND sav.segment_attribute_type = sat.segment_attribute_type
		  AND sat.application_id = 101
		  AND sat.id_flex_code = 'GL#'
		  AND sat.unique_flag = 'Y'
		  AND sat.segment_attribute_type = p_segment_attribute_type;

begin
    open c_valueSetID(p_segment_attribute_type);
	fetch c_valueSetID	into l_value_set_id;
	close c_valueSetID;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_value_set_id = ' || l_value_set_id);

    return l_value_set_id;

end getValueSetID;

/*=========================================================================
 | PUBLIC procedure validateAccounting
 |
 | DESCRIPTION
 |        validates all accounting for a given loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
 |
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |  E. The code combinations distribution percentages for each Loans Receivable
 |  and corresponding Loans Clearing account must be equal
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06/28/04 2:48:PM       raverma           Created
 |
 *=======================================================================*/
procedure validateAccounting(p_loan_id                    in  number
                            ,p_init_msg_list              IN VARCHAR2
                            ,x_return_status              OUT NOCOPY VARCHAR2
                            ,x_msg_count                  OUT NOCOPY NUMBER
                            ,x_msg_data                   OUT NOCOPY VARCHAR2)
is

    --l_loan_liability_fund   LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_loan_clearing_fund    LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_loan_receivables_orig LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_loan_clearing_orig    LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_loan_receivables_bill LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_prin_receivables_bill LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_int_receivables_bill  LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_int_income_bill       LNS_DISTRIBUTIONS_PUB.distribution_tbl;

    l_dist_percent_rec_orig   number;
    l_dist_percent_rec_bill   number;
    l_dist_percent_clear_orig number;
    l_dist_percent_int_income number;
    l_loan_class              varchar2(30);
    l_num_receivables_ers     number;
    l_num_receivables_acc     number;

    l_api_name              varchar2(30);

    cursor c_loan_class(p_loan_id number) is
    select loan_class_code
        from lns_loan_headers_all
    where loan_id = p_loan_id;

begin

    l_api_name := 'validateAccounting1';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_dist_percent_rec_orig   := 0;
    l_dist_percent_rec_bill   := 0;
    l_dist_percent_clear_orig := 0;
    l_dist_percent_int_income := 0;

    open c_loan_class(p_loan_id);
        fetch c_loan_class into l_loan_class;
    close c_loan_class;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_class = ' || l_loan_class);
    -- get the distributions details
    /*
    l_loan_liability_fund := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                    ,p_account_type      => 'DR'
                                                                    ,p_account_name      => 'LOAN_LIABILITY'
                                                                    ,p_line_type         => 'ORIG'
                                                                    ,p_distribution_type => 'FUNDING');
        */
    if l_loan_class = 'ERS' then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 1...');
        l_loan_clearing_orig    := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                            ,p_account_type      => 'CR'
                                                                            ,p_account_name      => 'LOAN_CLEARING'
                                                                            ,p_line_type         => 'CLEAR'
                                                                            ,p_distribution_type => 'ORIGINATION');
    elsif l_loan_class = 'DIRECT' then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 2...');
        l_loan_clearing_orig := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                        ,p_account_type      => 'CR'
                                                                        ,p_account_name      => 'LOAN_PAYABLE'
                                                                        ,p_line_type         => 'CLEAR'
                                                                        ,p_distribution_type => 'ORIGINATION');
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 3...');
    l_loan_receivables_orig := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                        ,p_account_type      => 'DR'
                                                                        ,p_account_name      => 'LOAN_RECEIVABLE'
                                                                        ,p_line_type         => 'ORIG'
                                                                        ,p_distribution_type => 'ORIGINATION');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 4...');
    l_loan_receivables_bill  := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                        ,p_account_type      => 'CR'
                                                                        ,p_account_name      => 'LOAN_RECEIVABLE'
                                                                        ,p_line_type         => 'PRIN'
                                                                        ,p_distribution_type => 'BILLING');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 5...');
    l_prin_receivables_bill := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                    ,p_account_type      => 'DR'
                                                                    ,p_account_name      => 'PRINCIPAL_RECEIVABLE'
                                                                    ,p_line_type         => 'PRIN'
                                                                    ,p_distribution_type => 'BILLING');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 6...');
    l_int_receivables_bill := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                    ,p_account_type      => 'DR'
                                                                    ,p_account_name      => 'INTEREST_RECEIVABLE'
                                                                    ,p_line_type         => 'INT'
                                                                    ,p_distribution_type => 'BILLING');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 7...');
    l_int_income_bill := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                ,p_account_type      => 'CR'
                                                                ,p_account_name      => 'INTEREST_INCOME'
                                                                ,p_line_type         => 'INT'
                                                                ,p_distribution_type => 'BILLING');

    if l_loan_class = 'ERS' then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ERS VALIDATION');

        /*
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting number of receivables on ers loan');
        open c_num_receivables_ers(p_loan_id);
        fetch c_num_receivables_ers into l_num_receivables_ers;
        close c_num_receivables_ers;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'num is: ' || l_num_receivables_ers);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting number of receivables ACCOUNTED');
        open c_num_receivables_acc(p_loan_id);
        fetch c_num_receivables_acc into l_num_receivables_acc;
        close c_num_receivables_acc;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'num is: ' || l_num_receivables_acc);

        if l_num_receivables_acc <> l_num_receivables_ers then
        FND_MESSAGE.Set_Name('LNS', 'LNS_AR_RECEIVABLES_UNACC');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        end if;
        */

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'comparing origination receivables to billing receivables count');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables origination Count = ' || l_loan_receivables_orig.count );
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables billing Count = ' || l_loan_receivables_bill.count);
        if l_loan_receivables_orig.count <> l_loan_receivables_bill.count then
            FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_INVALID_RECEIVABLES');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;

        -- B. The account code combinations for the Loans Receivable accounts within
        -- Origination must be the same as the account code combinations for the Loans
        -- Receivable accounts within Billing
        for j in 1..l_loan_receivables_orig.count loop

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'comparing origination receivables to billing receivables cc_ids');
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables origination cc_id = ' || l_loan_receivables_orig(j).code_combination_id );
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables billing cc_id = ' || l_loan_receivables_bill(j).code_combination_id);
            if l_loan_receivables_orig(j).code_combination_id <> l_loan_receivables_bill(j).code_combination_id  then
                FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_LOAN_REC_CCIDS_UNMATCH');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking for duplicate IDs');
            if j < l_loan_receivables_orig.count then
                if (l_loan_receivables_orig(j).code_combination_id = l_loan_receivables_orig(j+1).code_combination_id) OR
                    (l_loan_clearing_orig(j).code_combination_id = l_loan_clearing_orig(j+1).code_combination_id)
                then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'found duplicate IDs');
                    FND_MESSAGE.Set_Name('LNS', 'LNS_UNIQUE_CC_IDS');
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                end if;
            end if;

            -- F. The code combinations distribution percentages for each Loans Receivable
            -- within Origination must equal the distribution percentage for each Loans
            -- Receivable within Billing
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'comparing origination receivables to billing receivables percentages');
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables origination percent = ' || l_loan_receivables_orig(j).distribution_percent );
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables billing percent = ' || l_loan_receivables_bill(j).distribution_percent);
            if l_loan_receivables_orig(j).distribution_percent <> l_loan_receivables_bill(j).distribution_percent then
                FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_LOAN_REC_PER_UNMATCH');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;

            l_dist_percent_rec_orig   := l_dist_percent_rec_orig + l_loan_receivables_orig(j).distribution_percent;
            l_dist_percent_rec_bill   := l_dist_percent_rec_bill + l_loan_receivables_bill(j).distribution_percent;
            --l_dist_percent_clear_orig := l_dist_percent_clear_orig + l_loan_clearing_orig(j).distribution_percent;

        end loop;

        -- C. The distribution percentage for the Loans Receivable accounts in both
        -- Origination and Billing must add to 100%
        -- D. The distribution percentage for the Loans Clearing accounts in Origination must add to 100%
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking origination receivables total percentages');
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables total percent = ' || l_dist_percent_rec_orig);
        if l_dist_percent_rec_orig <> 100 then
            FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_ORIG_REC_PER_INVALID');
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

        /*
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking billing receivables total percentages');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan recivables total percent: ' || l_dist_percent_rec_bill);
    if l_dist_percent_rec_bill <> 100 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_BILL_REC_PER_INVALID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;
        */

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking origination clearing  total percentages');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan clearing total percent = ' || l_dist_percent_clear_orig);
    /*
    if l_dist_percent_clear_orig <> 100 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_ORIG_CLR_PER_INVALID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;
    */
    --  G. In the current release of 11i, there must be only one Principal Receivable
    --  account
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking principal receivables count');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'principal receivables count = ' || l_prin_receivables_bill.count);
    if l_prin_receivables_bill.count <> 1 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_MULT_PRIN_RECEIVABLE');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    --  H. In the current release of 11i, there must be only one Interest Receivable
    --  account
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking Interest receivables count');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest receivables count = ' || l_int_receivables_bill.count);
    if l_int_receivables_bill.count <> 1 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_MULT_INT_RECEIVABLE');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    --  I. There may be multiple Interest Income accounts
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking Interest Income count');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Income count = ' || l_int_income_bill.count);
    if l_int_income_bill.count < 1 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_NO_INTEREST_INCOME');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    --  J. The distribution percentages for Interest Income must add to 100%
    for j in 1..l_int_income_bill.count loop
        l_dist_percent_int_income := l_dist_percent_int_income + l_int_income_bill(j).distribution_percent;
    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking Interest Income percentage');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Interest Income percentage = ' || l_dist_percent_int_income);
    if l_dist_percent_int_income <> 100 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_INT_INCOME_PER_INVALID');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                            ,p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

Exception
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end validateAccounting;


/*========================================================================
 | PUBLIC procedure validateDefaultAccounting
 |
 | DESCRIPTION
 |        validates all accounting for a given loan loan_class and type
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
||
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
    E. The code combinations distribution percentages for each Loans Receivable
    and corresponding Loans Clearing account must be equal
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06/28/04 2:48:PM       raverma           Created
 | 06/29/04               raverma           added MFAR checking
|| 08/04/05               raverma           deprecate
 *=======================================================================*/
procedure validateDefaultAccounting(p_loan_class                 in varchar2
                                   ,p_loan_type_id               in number
                                   ,p_init_msg_list              IN VARCHAR2
                                   ,x_return_status              OUT NOCOPY VARCHAR2
                                   ,x_msg_count                  OUT NOCOPY NUMBER
                                   ,x_msg_data                   OUT NOCOPY VARCHAR2)
is
begin

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

end validateDefaultAccounting;

/*========================================================================
 | PUBLIC procedure validateLoanLines
 |
 | DESCRIPTION
 |        verifies that the loan lines are either ALL MFAR or ALL NON-MFAR
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
||
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
    E. The code combinations distribution percentages for each Loans Receivable
    and corresponding Loans Clearing account must be equal
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12/20/04 2:48:PM       raverma           Created
 *=======================================================================*/
procedure validateLoanLines(p_init_msg_list         IN VARCHAR2
                           ,p_loan_id               IN number
                           ,x_MFAR                  OUT NOCOPY boolean
                           ,x_return_status         OUT NOCOPY VARCHAR2
                           ,x_msg_count             OUT NOCOPY NUMBER
                           ,x_msg_data              OUT NOCOPY VARCHAR2)
is
    l_api_name                      varchar2(25);
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_trx_type_id                   number;
    l_psa_trx_type_id               number;
    l_mfar                          boolean;
    l_lines_count                   number;
    i                               number;
    l_multifund                     number;

    --find out if there is more than one line
    cursor c_loan_lines(p_loan_id number) is
    select count(1)
     from lns_loan_lines
    where loan_id = p_loan_id
      and reference_type = 'RECEIVABLE'
      and end_date is null;

    -- for loans with more than one line
    cursor c_validate_MFAR (p_loan_id number) is
    select ra.cust_trx_type_id, nvl(psa.psa_trx_type_id,-1)
      from lns_loan_lines  lines
          ,ra_customer_trx ra
          ,psa_trx_types_all psa
     where ra.customer_trx_id = lines.reference_id
       and psa.psa_trx_type_id (+)= ra.cust_trx_type_id
       and lines.reference_type = 'RECEIVABLE'
       and lines.end_date is null
       and lines.loan_id = p_loan_id
       group by ra.cust_trx_type_id, psa.psa_trx_type_id;

     -- cursor to identify MFAR trx 1 = MFAR, 0 <> MFAR
     -- assumes only one line is on the loan
     cursor c_multiFundTrx(p_loan_id in number)
     is
        select nvl(1,0)
          from ra_customer_trx ra
              ,psa_trx_types_all psa
              ,lns_loan_lines lines
         where ra.CUST_TRX_TYPE_ID = psa.psa_trx_type_id
           and ra.customer_trx_id = lines.reference_id
           and lines.end_date is null
           and lines.reference_type = 'RECEIVABLE'
           and lines.loan_id = p_loan_id
      group by lines.loan_id;

begin

   l_api_name           := 'validateLoanLines';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

   -- Standard Start of API savepoint
   SAVEPOINT validateLoanLines;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   l_lines_count := 0;
   i             := 0;

    open c_loan_lines(p_loan_id);
    fetch c_loan_lines into l_lines_count;
    close c_loan_lines;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'lines count is ' || l_lines_count);
    -- check if ALL are MFAR or all are NOT MFAR only if there is more
    --  than 1 line on the loan
    if l_lines_count > 1 then

        open c_validate_MFAR(p_loan_id);
        LOOP

            i := i + 1;
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'processing ' || i || ' loan line');
            fetch c_validate_MFAR
            into l_trx_type_id
                ,l_psa_trx_type_id;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'trx type ' || l_trx_type_id);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'psa trx type '|| l_psa_trx_type_id);

            exit when c_validate_MFAR%NOTFOUND;

            if i <> 1 then
                if l_mfar then
                    if l_psa_trx_type_id = -1 then
                        RAISE FND_API.G_EXC_ERROR;
                    end if;
                else
                    if l_psa_trx_type_id <> -1 then
                        RAISE FND_API.G_EXC_ERROR;
                    end if;
                end if;
            else
                if l_psa_trx_type_id = -1 then
                    -- the first line on the loan is NOT MFAR
                    -- all subsequent lines SHOULD be MFAR
                    l_mfar := false;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'NON-MFAR');
                else
                    l_mfar := true;
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'MFAR');
                end if;

            end if;
        end loop;

    else
        -- we only have 1 line on the loan...verify is it is MFAR or not
        -- check to see if trx_type is refered to in psa_trx_type
        -- if so this is a multi-fund receivable
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking for MFAR');
        begin

            open c_multiFundTrx(p_loan_id) ;
            fetch c_multiFundTrx into l_multifund;
            close c_multiFundTrx;

        exception
            when others then
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'no rows found');
                 l_multifund := 0;
        end;

        if l_multifund = 1 then
            l_mfar := true;
        else
            l_mfar := false;
        end if;

    end if;

    -- this will be needed by defaultDistributions
    x_mfar := l_mfar;
   --logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'sql ' || vPLSQL);

   -- ---------------------------------------------------------------------
   -- End of API body
   -- ---------------------------------------------------------------------

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO validateLoanLines;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO validateLoanLines;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
            ROLLBACK TO validateLoanLines;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end validateLoanLines;


procedure create_DisbursementDistribs(p_api_version           IN NUMBER
			                               ,p_init_msg_list         IN VARCHAR2
			                               ,p_commit                IN VARCHAR2
			                               ,p_loan_id               IN NUMBER
							,p_disb_header_id        IN NUMBER
							,p_loan_amount_adj_id    IN NUMBER     DEFAULT NULL
							,p_activity_type         IN VARCHAR2   DEFAULT NULL
			                               ,x_return_status         OUT NOCOPY VARCHAR2
			                               ,x_msg_count             OUT NOCOPY NUMBER
			                               ,x_msg_data              OUT NOCOPY VARCHAR2)

is
    l_api_name                 varchar2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_return_Status            VARCHAR2(1);
    l_distributions            lns_distributions_pub.distribution_tbl;
    l_exists                   number;
    l_disb_header_id           number;
    l_loan_amount_adj_id       number;
    l_distributions_count      number;
    i                          number;
    l_subsidy_rate             number;
    l_subsidy_exists           number;


    cursor c_distribsExist(p_loan_id number, p_disb_header_id number) is
    select count(1)
        from lns_distributions
    where loan_id = p_loan_id
        and distribution_type = 'ORIGINATION'
        and disb_header_id = p_disb_header_id;

    cursor c_adjustmentDistribsExist(c_loan_id number, c_loan_amount_adj_id number) is
    select count(1)
        from lns_distributions
    where loan_id = p_loan_id
        and distribution_type = 'ORIGINATION'
        and loan_amount_adj_id = c_loan_amount_adj_id;

    cursor c_first_disb(p_loan_id number) is
    select disb_header_id
      from lns_disb_headers
      where loan_id = p_loan_id;

    cursor c_subsidy_rows_exist(p_loan_id number) is
    select count(1)
      from lns_distributions
     where loan_id = p_loan_id
       and line_type = 'SUBSIDY'
       and distribution_type = 'ORIGINATION'
       and event_id is not null;

    -- Bug#6711399 subsidy_rate is taken from 'loan header' table, which is
    -- defaulted from product at the loan creation time.
    cursor c_subsidy_rate (p_loan_id number) is
    SELECT
	(nvl(subsidy_rate, 0)/100)
    FROM
	lns_loan_headers_all
    WHERE
	loan_id = p_loan_id;

    cursor c_loan_adj(c_loan_id number) is
      SELECT LOAN_AMOUNT_ADJ_ID
      FROM LNS_LOAN_AMOUNT_ADJS
      WHERE loan_id = c_loan_id
        AND status = 'PENDING';

begin

     l_api_name   := 'create_DisbursementDistribs';
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - BEGIN');

     SAVEPOINT create_DisbursementDistribs;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = ' || p_loan_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_header_id = ' || p_disb_header_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = ' || p_loan_amount_adj_id);
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_activity_type = ' || p_activity_type);


     -- Initialize message list IF p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_activity_type IS NULL THEN  -- Used for DirectLoanApproval and Disbursement
	 l_disb_header_id := p_disb_header_id;

      /*  Bug#9755933
       if p_disb_header_id is not null then
           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_header_id = ' || p_disb_header_id);
           l_disb_header_id := p_disb_header_id;
       else
          logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'finding first disbursement');
          open c_first_disb(p_loan_id);
          fetch c_first_disb into l_disb_header_id;
          close c_first_disb;
       end if;
       */
     ELSE   -- At present, only one activityType is 'DIRECT_LOAN_ADJUSTMENT'

       l_disb_header_id := p_disb_header_id;  -- Here this disb_header_id might be null

       if p_loan_amount_adj_id is not null then
           logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amt_adj_id = ' || p_loan_amount_adj_id);
           l_loan_amount_adj_id := p_loan_amount_adj_id;
       else
          logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'finding Pending adjustment');
          open c_loan_adj(p_loan_id);
          fetch c_loan_adj into l_loan_amount_adj_id;
          close c_loan_adj;
          logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Pending l_loan_amount_adj_id = ' || l_loan_amount_adj_id);
       end if;

     END IF;

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting subsidy_rate ');
     open c_subsidy_rate(p_loan_id);
     fetch c_subsidy_rate into l_subsidy_rate;
     close c_subsidy_rate;
     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_subsidy_rate = ' || l_subsidy_rate);

     logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_disb_header_id = ' || l_disb_header_id);

     IF p_activity_type IS NULL THEN
       open  c_distribsExist(p_loan_id, l_disb_header_id);
       fetch c_distribsExist into l_exists;
       close c_distribsExist;
     ELSE
       open  c_adjustmentDistribsExist(p_loan_id, l_loan_amount_adj_id);
       fetch c_adjustmentDistribsExist into l_exists;
       close c_adjustmentDistribsExist;
     END IF;

     if l_exists = 0 then
        -- get the cc_ids and percentages for the each loan_class_code and loan_type_id
        --break up the distribution amounts for the disbursement
        -- insert into the distributions table
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling defaultDistributionsCatch...');
        defaultDistributionsCatch(p_api_version                => 1.0
                                    ,p_init_msg_list              => FND_API.G_TRUE
                                    ,p_commit                     => p_commit
                                    ,p_loan_id                    => p_loan_id
                                    ,p_disb_header_id             => l_disb_header_id
                                    ,p_loan_amount_adj_id         => l_loan_amount_adj_id
                                    ,p_include_loan_receivables   => 'Y'
                                    ,p_distribution_type          => 'ORIGINATION'
                                    ,x_distribution_tbl           => l_distributions
                                    ,x_return_status              => l_return_status
                                    ,x_msg_count                  => l_msg_count
                                    ,x_msg_data                   => l_msg_data);

        if l_return_status <> 'S' then
            RAISE FND_API.G_EXC_ERROR;
        end if;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distributionsCatch.count = ' || l_distributions.count);
        for j in 1..l_distributions.count loop
            IF p_activity_type IS NULL THEN   -- Used for DirectLoanApproval and Disbursement
	    	logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'adding disb_header_id ' ||p_disb_header_id ||' to '|| j);
                l_distributions(j).disb_header_id := p_disb_header_id;
            ELSE   -- -- At present, only one activityType is 'DIRECT_LOAN_ADJUSTMENT'
	    	logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'adding l_loan_amount_adj_id ' ||l_loan_amount_adj_id ||' to '|| j);
                l_distributions(j).loan_amount_adj_id := l_loan_amount_adj_id;
            END IF;
        end loop;

        l_distributions_count := l_distributions.count;
        i                     := l_distributions.count;

        if lns_utility_pub.IS_FED_FIN_ENABLED = 'Y' then

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'checking for existing subsidy rows');
            open  c_subsidy_rows_exist(p_loan_id);
            fetch c_subsidy_rows_exist into l_subsidy_exists;
            close c_subsidy_rows_exist;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_subsidy_exists = ' || l_subsidy_exists);
            if l_subsidy_exists = 0 then

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fed enabled adding subsidy rows ');
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'subsidy rows do not exist ');
                for j in 1..l_distributions_count loop

                    -- if (l_distributions(j).ACCOUNT_TYPE = 'ORIGINATION' AND
                    --     (l_distributions(j).ACCOUNT_NAME = 'LOAN_RECEIVABLE' OR
                    --      l_distributions(j).ACCOUNT_NAME = 'LOAN_PAYABLE' )) then
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'adding subsidy row # ' || j);
                    i := i + 1;
                    -- add rows for subsidy cost

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account_name = ' || l_distributions(j).account_name);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'CODE_COMBINATION_ID = ' || l_distributions(j).CODE_COMBINATION_ID);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'account_type = ' || l_distributions(j).account_type);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DISTRIBUTION_PERCENT = ' || l_distributions(j).DISTRIBUTION_PERCENT);
                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DISTRIBUTION_TYPE = ' || l_distributions(j).DISTRIBUTION_TYPE);
                    l_distributions(i).LOAN_ID             := p_loan_id;
                    l_distributions(i).LINE_TYPE           := 'SUBSIDY';
                    l_distributions(i).ACCOUNT_NAME        := l_distributions(j).account_name;
                    l_distributions(i).CODE_COMBINATION_ID := l_distributions(j).CODE_COMBINATION_ID;
                    l_distributions(i).ACCOUNT_TYPE        := l_distributions(j).account_type;
                    l_distributions(i).DISTRIBUTION_PERCENT:= l_distributions(j).DISTRIBUTION_PERCENT;
                    l_distributions(i).distribution_amount := l_distributions(j).DISTRIBUTION_AMOUNT * l_subsidy_Rate;
                    l_distributions(i).DISTRIBUTION_TYPE   := l_distributions(j).DISTRIBUTION_TYPE;
                    l_distributions(i).EVENT_ID            := null;

                    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'running count = ' || l_distributions.count);
                -- end if;
                end loop;

            end if; -- l_subsidy_exists

        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'total distributions adding = ' || l_distributions.count);

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling do_insert_distributions...');
        do_insert_distributions(l_distributions, p_loan_id);

     end if;

     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'p_commit is '||p_commit);
     IF FND_API.to_Boolean(p_commit)
     THEN
         COMMIT;
	  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'Commited');
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
     logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_DisbursementDistribs;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_DisbursementDistribs;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_DisbursementDistribs;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

end create_DisbursementDistribs;


/*=========================================================================
|| PUBLIC PROCEDURE defaultDistributions
||
|| DESCRIPTION
||      This procedure defaults distributions (if set) for a particular
||       loan_class + loan_Type
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||  Parameter:   p_loan_id => loan to default
||
|| Return value:  Standard  S = Success E = Error U = Unexpected
||
|| Source Tables: LNS_DEFAULT_DISTRIBUTIONS, lns_loan_headers_all
||
|| Target Tables: LNS_DISTRIBUTIONS
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 02-16-2004            raverma             Created
|| 03-16-2004            raverma             added in default for multi-fund loans inherit from receivables
|| 06-16-2004            raverma             changed rules on inheritance for MFAR transactions
||                                           get amounts for MFAR from PSA_MF_BALANCES_VIEW
|| 07-26-2004            raverma             delete rows before each call to accounting
|| 12-18-2004            raverma             look at lns_loan_lines
|| 12-18-2004            raverma             need to get loan class code
|| 04-19-2005            raverma             establish loan clearing as per bug #4313925
 *=======================================================================*/
procedure defaultDistributions(p_api_version           IN NUMBER
                              ,p_init_msg_list         IN VARCHAR2
                              ,p_commit                IN VARCHAR2
                              ,p_loan_id               IN NUMBER
                              ,p_loan_class_code       IN VARCHAR2
                              ,x_return_status         OUT NOCOPY VARCHAR2
                              ,x_msg_count             OUT NOCOPY NUMBER
                              ,x_msg_data              OUT NOCOPY VARCHAR2)

is
/*------------------------------------------------------------------------+
 | Local Variable Declarations and initializations                        |
 +-----------------------------------------------------------------------*/
    l_api_name                 varchar2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_return_Status            VARCHAR2(1);
    i                          number;
    n                          number;
    l_code_combination_id      number;
    l_code_combination_id_new_rec number;
    l_distributions            lns_distributions_pub.distribution_tbl;
    l_distributionsCLEAR_ORIG  lns_distributions_pub.distribution_tbl;
    l_distributionsREC_ORIG    lns_distributions_pub.distribution_tbl;
    l_distributionsREC_BILL    lns_distributions_pub.distribution_tbl;
    l_distributionsCatch       lns_distributions_pub.distribution_tbl;
    l_distributionsALL         lns_distributions_pub.distribution_tbl;
    l_distributions_count      number;
    l_distributionsCatch_count number;
    l_total_distributions      number;
    l_ers_distribution_amount  number;
    l_orig_distribution_amount number;
    l_ledger_details           lns_distributions_pub.gl_ledger_details;
    l_include_receivables      varchar2(1);
    l_sum                      number;
    l_multifund                number;
    l_multifund_exists         number;
    l_total_percent            number;
    l_total_receivable_amount  number;
    l_natural_account_rec      varchar2(25);  -- the lns_def_distribs replacement  for Loans Receivable
    l_nat_acct_seg_number      number;
    l_num_segments             number;
    l_adjustment_exists        boolean;
    l_funded_amount            number;
    l_total_amount_due         number;
    l_amount_adjusted          number;
    l_running_amount           number;
    l_running_percent          number;
    l_amount                   number;
    l_percent                  number;
    l_subsidy_rate             number;
    l_loan_class               varchar2(30);
    l_loan_type_id             number;
    l_loan_header_rec          LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    adj_info                   xla_events_pub_pkg.t_event_source_info;
    inv_info                   xla_events_pub_pkg.t_event_source_info;
    l_adjustment_id            number;
    l_customer_trx_id          number;
    l_accounting_batch_id      NUMBER;
    l_errbuf                   VARCHAR2(10000);
    l_retcode                  NUMBER;
    l_request_id               NUMBER;
    l_legal_entity_id          number;
    l_version                  number;
    l_error_counter            number;
    l_event_array              xla_events_pub_pkg.t_array_event_info;
    l_error_message               varchar2(2000);
    l_invoice_number              varchar2(100);
    l_entity_code                 varchar2(30);
    l_transactions_count          number;
    l_entity_id                   number;
    l_source_id_int_1             number;
    l_upgrade_status              varchar2(1);
    l_trx_number                  varchar2(100);
    l_clearing_total_amount_due   number;
    l_receivable_total_amount_due number;
    l_transaction_number          VARCHAR2(240);
    l_sob_id                      number;
    l_EVENT_SOURCE_INFO           xla_events_pub_pkg.t_event_source_info;

/*------------------------------------------------------------------------+
 | Cursor Declarations                                                    |
 +-----------------------------------------------------------------------*/

		 -- cursor to establish the loan receivables accounts
     -- 11-16-2005 added reference to XLA_POST_ACCT_PROGS_B as per
     --  xla team instructions (noela, ayse)
     cursor C_ERS_LOAN_RECEIVABLE(p_loan_id number) is
      select sum(ael.entered_dr)
			      ,ael.code_combination_id
  	 	  from ra_customer_trx_all inv
            ,xla_transaction_entities ent
            ,xla_ae_headers aeh
            ,xla_ae_lines ael
			 where ent.application_id = 222
			   and inv.customer_trx_id = ent.source_id_int_1
			   and ent.entity_code = 'TRANSACTIONS'
			   and ent.entity_id = aeh.entity_id
         and ent.ledger_id = aeh.ledger_id
			   and aeh.ae_header_id = ael.ae_header_id
			   and aeh.accounting_entry_status_code = 'F'
         and ael.accounting_class_code IN
         (select xaa.accounting_class_code
            from XLA_ACCT_CLASS_ASSGNS xaa
                ,XLA_ASSIGNMENT_DEFNS_B xad
                ,XLA_POST_ACCT_PROGS_B xpa
           where xaa.program_code = 'GET_RECEIVABLE_CCID'
             and xpa.program_code = xaa.program_code
             and xaa.program_code = xad.program_code
             and xad.assignment_code = xaa.assignment_code
             and xad.enabled_flag = 'Y')
			   and inv.customer_trx_id in
				 (select reference_id
		        from lns_loan_lines lines
					 where reference_type = 'RECEIVABLE'
     		     and end_date is null
		         and loan_id = p_loan_id)
			group by ael.code_combination_id;

		 -- cursor to establish the loan clearing accounts
     -- 11-16-2005 added reference to XLA_POST_ACCT_PROGS_B as per
     --  xla team instructions (noela, ayse)
     cursor C_ERS_LOAN_CLEARING(p_loan_id number) is
			select sum(ael.entered_dr)
				 		,ael.code_combination_id
			  from ar_adjustments_all adj
            ,xla_transaction_entities ent
				    ,xla_ae_headers aeh
				    ,xla_ae_lines ael
			where ent.application_id = 222
				and adj.adjustment_id = ent.source_id_int_1
				and ent.entity_code = 'ADJUSTMENTS'
				and ent.entity_id = aeh.entity_id
				and ent.ledger_id = aeh.ledger_id
				and aeh.ae_header_id = ael.ae_header_id
				and aeh.accounting_entry_status_code = 'F'
        and ael.accounting_class_code in
         (select xaa.accounting_class_code
            from XLA_ACCT_CLASS_ASSGNS xaa
                ,XLA_ASSIGNMENT_DEFNS_B xad
                ,XLA_POST_ACCT_PROGS_B xpa
           where xaa.program_code = 'LNS_ADJUSTMENT_DEBIT'     -- Bug#8231149
             and xpa.program_code = xaa.program_code
             and xaa.program_code = xad.program_code
             and xad.assignment_code = xaa.assignment_code
             and xad.enabled_flag = 'Y')
				and adj.adjustment_id in
      (select rec_adjustment_id
			   from lns_loan_lines lines
				where reference_type = 'RECEIVABLE'
			    and end_date is null
			    and loan_id = p_loan_id)
			group by ael.code_combination_id;

		-- use this to get the loan_class and type
    cursor c_loan_class(p_loan_id number) is
    select h.loan_class_code
          ,t.loan_type_id
          ,h.funded_amount
					,h.legal_entity_id
      from lns_loan_headers_all h
					,lns_loan_types t
     where h.loan_id = p_loan_id
 		   and h.loan_type_id = t.loan_type_id;

		-- use this to get all adjustments to be processed for the loan
		cursor c_adj_ids (p_loan_id number) is
		select adj.adjustment_id
          ,adj.adjustment_number
			from ar_adjustments adj
					,lns_loan_lines lines
		 where lines.rec_adjustment_number = adj.adjustment_number
			 and lines.end_date is null
			 and lines.reference_type = 'RECEIVABLE'
			 and lines.loan_id = p_loan_id;

    -- use this to get all receivables to be processed for the loan
    cursor c_inv_ids(p_loan_id number) is
    select lines.reference_id
          ,lines.reference_number
      from lns_loan_lines lines
     where lines.end_date is null
       and lines.reference_type = 'RECEIVABLE'
       and lines.loan_id = p_loan_id;

    -- cursor to update loan header
    cursor c_obj_vers(p_loan_id number) is
    select object_version_number
      from lns_loan_headers
     where loan_id = p_loan_id;

    -- cursor to get documents and check upgrade status
    cursor c_get_loan_documents(p_loan_id number) is
    select lines.reference_id, trx.trx_number
      from lns_loan_lines lines
          ,ra_customer_trx trx
     where lines.reference_type = 'RECEIVABLE'
       and lines.end_date is null
       and lines.loan_id = p_loan_id
       and lines.reference_id = trx.customer_trx_id;

    -- cursor to get accounting errors
    cursor c_acc_errors (p_loan_id number, p_accounting_batch_id number) is
    select xlt.transaction_number, xlt.entity_code, err.encoded_msg
      from xla_accounting_errors err
          ,xla_transaction_entities xlt
     where xlt.application_id = 222
       --and err.accounting_batch_id = nvl(p_accounting_batch_id, null)
       and xlt.entity_id = err.entity_id
       and xlt.entity_id in (select entity_id from xla_transaction_entities
                              where application_id = 222
                                and entity_code IN ('TRANSACTIONS', 'ADJUSTMENTS')
                                and ((source_id_int_1 in (select reference_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_id = p_loan_id))
                                  OR (source_id_int_1 in (select rec_adjustment_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_id = p_loan_id))));
      -- -----------------------------------------------------------------
      cursor c_entities(p_loan_id number) is
          select entity_id, entity_code, source_id_int_1, transaction_number
            from xla_transaction_entities
           where application_id = 222
             and entity_code IN ('TRANSACTIONS', 'ADJUSTMENTS')
             and ((source_id_int_1 in (select reference_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_id = p_loan_id)
             OR   (source_id_int_1 in (select rec_adjustment_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_id = p_loan_id))));

begin

      SAVEPOINT defaultDistributions;
      l_api_name   := 'defaultDistributions';
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'p_loan_id = ' || p_loan_id);
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'p_loan_class_code = ' || p_loan_class_code);

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- initialize variables
      l_distributions_count      := 0;
      l_distributionsCatch_count := 0;
      l_total_distributions      := 0;
      l_ers_distribution_amount  := 0;
      i                          := 0;
      l_distributions_count      := 0;
      l_distributionsCatch_count := 0;
      l_total_distributions      := 0;
      l_orig_distribution_amount := 0;
      l_include_receivables      := 'Y';
      l_sum                      := 0;
      l_funded_amount            := 0;
      l_multifund_exists         := 0;
      n                          := 0;
      l_total_percent            := 0;
      l_total_receivable_amount  := 0;
      l_adjustment_exists        := false;
      l_running_amount           := 0;
      l_running_percent          := 0;
      l_total_amount_due         := 0;
      l_subsidy_rate             := 0;
      l_receivable_total_amount_due := 0;
      l_clearing_total_amount_due := 0;

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Opening cursor c_loan_class...');
      open c_loan_class(p_loan_id);
      fetch c_loan_class
       into l_loan_class
           ,l_loan_type_id
           ,l_funded_amount
		   ,l_legal_entity_id;
      close c_loan_class;

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_loan_class = ' || l_loan_class);
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_loan_type_id = ' || l_loan_type_id);
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_funded_amount = ' || l_funded_amount);
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_legal_entity_id = ' || l_legal_entity_id);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling lns_distributions_pub.validateDefaultAccounting...');
      lns_distributions_pub.validateDefaultAccounting(p_loan_class      => l_loan_class
                                                     ,p_loan_type_id    => l_loan_type_id
                                                     ,p_init_msg_list   => p_init_msg_list
                                                     ,x_return_status   => l_return_status
                                                     ,x_msg_count       => l_msg_count
                                                     ,x_msg_data        => l_msg_data);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          FND_MESSAGE.SET_NAME('LNS', 'LNS_DEFAULT_DIST_NOT_FOUND');
          FND_MSG_PUB.ADD;
          LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
          RAISE FND_API.G_EXC_ERROR;
      end if;

      /* delete any rows for this loan before inheritance do not delete FEE_RECEIVABLE or FEE_INCOME rows*/
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Deleting any existing accounting rows except FEE_RECEIVABLE or FEE_INCOME...');
      delete from lns_distributions
      where loan_id = p_loan_id
        and account_name in ('PRINCIPAL_RECEIVABLE', 'INTEREST_RECEIVABLE', 'INTEREST_INCOME', 'LOAN_RECEIVABLE', 'LOAN_CLEARING', 'LOAN_LIABILITY', 'LOAN_PAYABLE');
        --and event_id is null;  --fix for bug 8815841: delete all rows including rows with event_id not null
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Done');

      -- first check if we are creating accounting for an ERS or DIRECT loan
      if p_loan_class_code = 'DIRECT' then


        /*
     -- Bug#6711399 Subsidy_rate defaulted from loanProduct to loan at the time of loanCreation
     --  in API LNS_LOAN_HEADER_PUB.do_create_loan.

					-- we are creating accounting for DIRECT loan class
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' fetching subsidy rate');
          begin
                open c_subsidy_rate(p_loan_id);
                fetch c_subsidy_rate into l_subsidy_rate;
                close c_subsidy_rate;
          exception
            when no_data_found then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_SUBSIDY_RATE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          end;

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' l_subsidy_rate ' || l_subsidy_rate );

          open c_obj_vers(p_loan_id);
          fetch c_obj_vers into l_version;
          close c_obj_vers;

          l_loan_header_rec.subsidy_rate := l_subsidy_rate;
          l_loan_header_rec.loan_id             := p_loan_id;
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'updating loan');
          LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version
                                         ,P_LOAN_HEADER_REC       => l_loan_header_rec
                                         ,P_INIT_MSG_LIST         => p_init_msg_list
                                         ,X_RETURN_STATUS         => l_return_status
                                         ,X_MSG_COUNT             => l_msg_count
                                         ,X_MSG_DATA              => l_msg_data);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' update loan status = ' || l_return_status);
          if l_return_status <> 'S' then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          end if;
   */
		    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'DIRECT LOAN INHERITANCE');

            -- we establish BILING only for this procedure
	        -- inherit based on loan class + type ONLY
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling defaultDistributionsCatch...');
	        defaultDistributionsCatch(p_api_version                 => 1.0
                                    ,p_init_msg_list              => p_init_msg_list
                                    ,p_commit                     => FND_API.G_FALSE
                                    ,p_loan_id                    => p_loan_id
                                    ,p_disb_header_id             => null
                                    ,p_loan_amount_adj_id         => null
                                    ,p_include_loan_receivables   => 'Y'
                                    ,p_distribution_type          => 'BILLING'
                                    ,x_distribution_tbl           => l_distributionsCatch
                                    ,x_return_status              => l_return_status
                                    ,x_msg_count                  => l_msg_count
                                    ,x_msg_data                   => l_msg_data);
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
            if l_return_status <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
            end if;

            -- we establish the distributions for the first DISBURSEMENT only
            -- in order to process Budgetary Control Information
            -- in SLA Transaction Line Object
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling create_DisbursementDistribs...');
            create_DisbursementDistribs(p_api_version           => 1.0
                                      ,p_init_msg_list         => p_init_msg_list
                                      ,p_commit                => FND_API.G_FALSE
                                      ,p_loan_id               => p_loan_id
                                      ,p_disb_header_id        => null
                                      ,p_loan_amount_adj_id    => null
                                      ,x_return_status         => l_return_status
                                      ,x_msg_count             => l_msg_count
                                      ,x_msg_data              => l_msg_data);
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
            if l_return_status <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
            end if;

      elsif p_loan_class_code = 'ERS' then

		    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'ERS LOAN INHERITANCE');

            -- this switch is for the CatchAll Procedure
            l_include_receivables := 'N';
            l_ledger_details := lns_distributions_pub.getLedgerDetails;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'chart_of_accounts_id = ' || l_ledger_details.chart_of_accounts_id);

            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Fetching documents to account...');
            open c_get_loan_documents(p_loan_id);
            loop
                fetch c_get_loan_documents into l_source_id_int_1, l_trx_number;
                exit when c_get_loan_documents%notfound;

                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_source_id_int_1 = ' || l_source_id_int_1);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_trx_number = ' || l_trx_number);

                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling arp_acct_event_pkg.upgrade_status_per_doc...');
                -- check for upgrade status bug#4872154
                arp_acct_event_pkg.upgrade_status_per_doc(p_init_msg_list     => p_init_msg_list
                                                        ,p_entity_code       => l_entity_code
                                                        ,p_source_int_id     => l_source_id_int_1
                                                        ,x_upgrade_status    => l_upgrade_status
                                                        ,x_return_status     => l_return_status
                                                        ,x_msg_count         => l_msg_count
                                                        ,x_msg_data          => l_msg_data);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_upgrade_status = ' || l_upgrade_status);

                if l_return_status <> 'S' then
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_CHK_UPG_FAIL');
                    FND_MESSAGE.SET_TOKEN('DOC_NUM', l_trx_number);
                    FND_MSG_PUB.ADD;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
                else
                    if l_upgrade_status <> 'Y' then
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_TRX');
                        FND_MESSAGE.SET_TOKEN('DOC_NUM', l_trx_number);
                        FND_MSG_PUB.ADD;
                        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
                    end if;
                end if;

            end loop;
            close c_get_loan_documents;

            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Fetching entities xla_transaction_entities...');
            l_transactions_count := 0;
            open c_entities(p_loan_id);
            loop
                fetch c_entities into l_entity_id, l_entity_code, l_source_id_int_1, l_transaction_number;
                exit when c_entities%notfound;

                l_transactions_count := l_transactions_count + 1;
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Entity ' || l_transactions_count);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_entity_id = ' || l_entity_id);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_entity_code = ' || l_entity_code);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_source_id_int_1 = ' || l_source_id_int_1);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_transaction_number = ' || l_transaction_number);

                insert into XLA_ACCT_PROG_DOCS_GT (entity_id) VALUES (l_entity_id);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Inserted into XLA_ACCT_PROG_DOCS_GT');

            end loop;
            close  c_entities ;

            select count(1) into l_transactions_count
            from XLA_ACCT_PROG_DOCS_GT;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Inserted transaction_entities  = ' || l_transactions_count);

            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling XLA_ACCOUNTING_PUB_PKG.accounting_program_doc_batch...');
            XLA_ACCOUNTING_PUB_PKG.accounting_program_doc_batch(p_application_id      => 222
                                                                ,p_accounting_mode     => 'F'
                                                                ,p_gl_posting_flag     => 'N'
                                                                ,p_accounting_batch_id => l_accounting_batch_id
                                                                ,p_errbuf              => l_errbuf
                                                                ,p_retcode             => l_retcode);
            logMessage(FND_LOG.level_statement, G_PKG_NAME, ' l_retcode = ' || l_retcode);
            logMessage(FND_LOG.level_statement, G_PKG_NAME, ' l_accounting_batch_id = ' || l_accounting_batch_id);

            if l_retcode <> 0 then

                logMessage(FND_LOG.level_unexpected, G_PKG_NAME, 'Online accounting failed with error: ' || l_errbuf);

                /* query XLA_ACCOUNTING_ERRORS */
                l_error_counter := 0;
                open c_acc_errors(p_loan_id, l_accounting_batch_id);

                LOOP

                    fetch c_acc_errors into
                        l_invoice_number,
                        l_entity_code,
                        l_error_message;
                    exit when c_acc_errors%NOTFOUND;

                    l_error_counter := l_error_counter + 1;

                    if l_error_counter = 1 then
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_ONLINE_ACCOUNTING_FAILED');
                        FND_MSG_PUB.Add;
                        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    end if;

                    FND_MESSAGE.SET_NAME('LNS', 'LNS_ACC_DOC_FAIL');
                    FND_MESSAGE.SET_TOKEN('DOC_NUM', l_invoice_number);
                    FND_MESSAGE.SET_TOKEN('DOC_TYPE', l_entity_code);
                    FND_MESSAGE.SET_TOKEN('ACC_ERR', l_error_message);
                    FND_MSG_PUB.Add;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));

                END LOOP;

                close c_acc_errors;

                RAISE FND_API.G_EXC_ERROR;
            else
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Online accounting SUCCESS! ');
            end if;

            -- get the swap segment value
	        l_natural_account_rec := getNaturalSwapAccount(p_loan_id);
	        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Swap natural account with ' || l_natural_account_rec);

            -- Get natural account segment number
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling FND_FLEX_APIS.GET_QUALIFIER_SEGNUM...');
            IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(appl_id         => 101
                                                        ,key_flex_code   => 'GL#'
                                                        ,structure_number=> l_ledger_details.chart_of_accounts_id
                                                        ,flex_qual_name  => 'GL_ACCOUNT'
                                                        ,segment_number  => l_nat_acct_seg_number))
            THEN
                FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_NATURAL_ACCOUNT_SEGMENT');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Natural acct segment = ' || l_nat_acct_seg_number);

            -- here we establish the loan clearing first
            -- if adjustment activity is found in XLA then we take amounts, cc_ids from XLA tables for both CLEARING and RECEIVABLES
            Begin
	            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Opening cursor C_ERS_LOAN_CLEARING...');
                i := 0;
	            open C_ERS_LOAN_CLEARING(p_loan_id);
	            Loop
                    -- reintialize these
                    l_code_combination_id     := null;
                    l_ers_distribution_amount := 0;

                    fetch C_ERS_LOAN_CLEARING into l_ers_distribution_amount, l_code_combination_id;
                    EXIT WHEN C_ERS_LOAN_CLEARING%NOTFOUND;

                    l_clearing_total_amount_due := l_clearing_total_amount_due + l_ers_distribution_amount;

                    -- bug #4313925 --
                    l_adjustment_exists := true;
                    i := i + 1;

                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Loan Clearing Record ' || i);
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_ers_distribution_amount = ' || l_ers_distribution_amount);
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_clearing_total_amount_due = ' || l_clearing_total_amount_due);

                    l_distributionsCLEAR_ORIG(i).line_type            := 'CLEAR';
                    l_distributionsCLEAR_ORIG(i).account_name         := 'LOAN_CLEARING';
                    l_distributionsCLEAR_ORIG(i).code_combination_id  := l_code_combination_id;
                    l_distributionsCLEAR_ORIG(i).account_type         := 'CR';
                    l_distributionsCLEAR_ORIG(i).distribution_amount  := l_ers_distribution_amount;
                    l_distributionsCLEAR_ORIG(i).distribution_percent := null;
                    l_distributionsCLEAR_ORIG(i).distribution_type    := 'ORIGINATION';

	            end loop; -- loan clearing loop
	       exception
                when others then
                    --logMessage(FND_LOG.LEVEL_UNEX, G_PKG_NAME, 'Failed to inherit receivables distributions');
                    FND_MESSAGE.SET_NAME('LNS', 'LNS_INHERIT_DIST_NOT_FOUND');
                    FND_MSG_PUB.ADD;
                    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                    RAISE FND_API.G_EXC_ERROR;
	       end;

           --logMessage(FND_LOG.level_statement, G_PKG_NAME, 'After loan clearing lines calculated. total amount due = ' || l_total_amount_due);

	       -- if the adjustment exists in PSA table it means loan is approved and adjustment was created for receivables
	       i := 0;
	       if l_adjustment_exists then
	           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'ACCOUNTED ADJUSTMENT EXISTS');
	           Begin
	               logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Opening cursor C_ERS_LOAN_RECEIVABLE...');
	               open C_ERS_LOAN_RECEIVABLE(p_loan_id);
	               Loop
	                   -- reintialize these
	                   l_code_combination_id         := null;
	                   l_code_combination_id_new_rec := null;
	                   l_ers_distribution_amount     := 0;

                       fetch C_ERS_LOAN_RECEIVABLE into l_ers_distribution_amount, l_code_combination_id;
	                   EXIT WHEN C_ERS_LOAN_RECEIVABLE%NOTFOUND;

                       l_receivable_total_amount_due := l_receivable_total_amount_due + l_ers_distribution_amount;

                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Record:');
                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_ers_distribution_amount = ' || l_ers_distribution_amount);
                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_receivable_total_amount_due = ' || l_receivable_total_amount_due);

	                   -- here we need to rebuild the code_Combination_id as per swapping rules
	                   -- replace the natual account segement with the natural account segment found in the set-up/configuration
	                   if l_ers_distribution_amount > 0 then
	                        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling swap_code_combination...');
	                        l_code_combination_id_new_rec :=
                                    swap_code_combination(p_chart_of_accounts_id => l_ledger_details.chart_of_accounts_id
	                                                      ,p_original_cc_id       => l_code_combination_id
	                                                      ,p_swap_segment_number  => l_nat_acct_seg_number
	                                                      ,p_swap_segment_value   => l_natural_account_rec);

	                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_code_combination_id_new_rec = ' || l_code_combination_id_new_Rec);

	                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Assigning distributions...');

	                       -- we need 2 records PER receivable account distribution
	                       i := i + 1;
	                       l_distributionsREC_ORIG(i).line_type           := 'ORIG';
	                       l_distributionsREC_ORIG(i).account_name        := 'LOAN_RECEIVABLE';
	                       l_distributionsREC_ORIG(i).code_combination_id := l_code_combination_id_new_rec;
	                       l_distributionsREC_ORIG(i).account_type        := 'DR';
	                       l_distributionsREC_ORIG(i).distribution_amount := l_ers_distribution_amount;
	                       l_distributionsREC_ORIG(i).distribution_type   := 'ORIGINATION';

                           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Added LOAN_RECEIVABLE FOR ORIGINATION ' || l_code_combination_id_new_rec);
                           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_ORIG.count = ' || l_distributionsREC_ORIG.count);

	                       l_distributionsREC_BILL(i).line_type           := 'PRIN';
	                       l_distributionsREC_BILL(i).account_name        := 'LOAN_RECEIVABLE';
	                       l_distributionsREC_BILL(i).code_combination_id := l_code_combination_id_new_rec;
	                       l_distributionsREC_BILL(i).account_type        := 'CR';
	                       l_distributionsREC_BILL(i).distribution_amount := null;
	                       l_distributionsREC_BILL(i).distribution_type   := 'BILLING';

	                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Added LOAN_RECEIVABLE FOR BILLING ' || l_code_combination_id_new_rec);
                           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_BILL.count = ' || l_distributionsREC_BILL.count);

	                       l_sum := l_sum + l_ers_distribution_amount;
	                       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_sum = ' || l_sum);
	                   end if;

	               end loop;

	               close C_ERS_LOAN_RECEIVABLE;

	           exception
	                when others then
--                        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'failed to inherit receivables distributions');
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_INHERIT_DIST_NOT_FOUND');
                        FND_MSG_PUB.ADD;
                        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
	           end;

	       else
	           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'NO ACCOUNTED ADJUSTMENT EXISTS');
	       end if;

           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_BILL.count = ' || l_distributionsREC_BILL.count);
           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_ORIG.count = ' || l_distributionsREC_ORIG.count);
	       logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsCLEAR_ORIG.count = ' || l_distributionsCLEAR_ORIG.count);
           --logMessage(FND_LOG.level_statement, G_PKG_NAME, 'TOTAL AMOUNT DUE = ' || l_total_amount_due);
           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_funded_amount = ' || l_funded_amount);

	       -- this logic is copied from PSA 04-19-2005
           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'CALCULATING %AGES FOR LOANS RECEIVABLE...');

	       for k in 1..l_distributionsREC_ORIG.count loop

                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Iteration ' || k);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calculating %ages for a loan with ERS Adjustments...');

                if k <> l_distributionsREC_ORIG.count then
                    -- use the adjustment amounts to calculate percentages  -- this ensures percents but not cc_ids
                    -- this may or may not be an offending line karamach
                    l_percent := round(l_distributionsCLEAR_ORIG(k).distribution_amount / l_clearing_total_amount_due * 100,4);
                    --l_percent := round(l_distributionsREC_ORIG(k).distribution_amount / l_receivable_total_amount_due * 100,4);
                    l_distributionsREC_ORIG(k).distribution_percent := l_percent;
                    l_distributionsREC_BILL(k).distribution_percent := l_percent;
                    -- ensure this amount is accurate it will get inserted into lns_distributions for loans booking
                    l_distributionsREC_ORIG(k).distribution_amount  := l_percent / 100 * l_funded_amount;
                else
                    -- last row ensure that amounts = 100% and total = funded amount of loan
                    l_percent := 100 - l_running_percent;
                    l_distributionsREC_ORIG(k).distribution_percent := l_percent;
                    l_distributionsREC_BILL(k).distribution_percent := l_percent;
                    l_distributionsREC_ORIG(k).distribution_amount  := l_funded_amount - l_running_amount;
                end if;
                l_running_amount  := l_running_amount + l_distributionsREC_ORIG(k).distribution_amount;
                l_running_percent := l_running_percent + l_percent;

                l_percent := 0;
                l_amount  := 0;

                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'distribution_percent = ' || l_distributionsREC_ORIG(k).distribution_percent);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'distribution_amount = ' || l_distributionsREC_ORIG(k).distribution_amount);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_running_percent = ' || l_running_percent);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_running_amount = ' || l_running_amount);

	       end loop;

	       l_running_percent := 0;
	       l_running_amount  := 0;

	       -- this logic is copied from PSA 04-19-2005
           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'CALCULATING %AGES FOR LOANS CLEARING...');

	       for k in 1..l_distributionsCLEAR_ORIG.count loop

	            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'iteration ' || k);

                if k <> l_distributionsCLEAR_ORIG.count then
                    l_percent := round(l_distributionsCLEAR_ORIG(k).distribution_amount / l_clearing_total_amount_due * 100,4);
                    l_distributionsCLEAR_ORIG(k).distribution_percent  := l_percent;
                    l_distributionsCLEAR_ORIG(k).distribution_amount   := l_percent / 100 * l_funded_amount;
                else
                    -- last row ensure that amounts = 100% and total = funded amount of loan
                    l_percent := 100 - l_running_percent;
                    l_distributionsCLEAR_ORIG(k).distribution_percent := 100 - l_running_percent;
                    l_distributionsCLEAR_ORIG(k).distribution_amount  := l_funded_amount - l_running_amount;
                end if;
                l_running_percent := l_running_percent + l_percent;
                l_running_amount  := l_running_amount + l_distributionsCLEAR_ORIG(k).distribution_amount;

                l_percent := 0;
                l_amount  := 0;

                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'distribution_percent = ' || l_distributionsCLEAR_ORIG(k).distribution_percent);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'distribution_amount = ' || l_distributionsCLEAR_ORIG(k).distribution_amount);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_running_percent = ' || l_running_percent);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_running_amount = ' || l_running_amount);

           end loop;

	       -- inherit remaining account_names based on loan class + type for
	       -- principal / interest receivable, interest income
           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling defaultDistributionsCatch...');
	       defaultDistributionsCatch(p_api_version                => 1.0
                                  ,p_init_msg_list              => FND_API.G_FALSE
                                  ,p_commit                     => FND_API.G_FALSE
	                                ,p_loan_id                    => p_loan_id
                                  ,p_disb_header_id             => null
                                  ,p_loan_amount_adj_id         => null
	                                ,p_include_loan_receivables   => l_include_receivables
                                  ,p_distribution_type          => null
	                                ,x_distribution_tbl           => l_distributionsCatch
	                                ,x_return_status              => l_return_status
	                                ,x_msg_count                  => l_msg_count
	                                ,x_msg_data                   => l_msg_data);
           logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
           if l_return_status <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
           end if;

      End if; --loan class

      l_distributionsCatch_count := l_distributionsCatch.count;
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsCatch_count = ' || l_distributionsCatch_count);

      l_total_distributions      := l_distributions_count + l_distributionsCatch_count;

      n := 0;
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsREC_ORIG to l_distributionsALL...');
      for j in 1..l_distributionsREC_ORIG.count loop
            n := n + 1;
            l_distributionsALL(n)     := l_distributionsREC_ORIG(j);
      end loop;
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsCLEAR_ORIG to l_distributionsALL...');
      for j in 1..l_distributionsCLEAR_ORIG.count loop
            n := n + 1;
            l_distributionsALL(n)     := l_distributionsCLEAR_ORIG(j);
      end loop;
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsREC_BILL to l_distributionsALL...');
      for j in 1..l_distributionsREC_BILL.count loop
            n := n + 1;
            l_distributionsALL(n)     := l_distributionsREC_BILL(j);
      end loop;
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsCatch to l_distributionsALL...');
      for j in 1..l_distributionsCatch.count
      loop
            n := n + 1;
            l_distributionsALL(n) := l_distributionsCatch(j);
      end loop;
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling do_insert_distributions...');
      do_insert_distributions(p_distributions_tbl => l_distributionsALL
                             ,p_loan_id           => p_loan_id);

      -- validate the accounting rows here
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling lns_distributions_pub.validateAccounting...');
      lns_distributions_pub.validateAccounting(p_loan_id          => p_loan_id
                                              ,p_init_msg_list    => p_init_msg_list
                                              ,x_return_status    => l_return_status
                                              ,x_msg_count        => l_msg_count
                                              ,x_msg_data         => l_msg_data);

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
      if l_return_status <> 'S' then
         FND_MESSAGE.SET_NAME('LNS', 'LNS_DEFAULT_DIST_NOT_FOUND');
         FND_MSG_PUB.ADD;
         LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
         RAISE FND_API.G_EXC_ERROR;
      end if;

      IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO defaultDistributions;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO defaultDistributions;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
        ROLLBACK TO defaultDistributions;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end defaultDistributions;

/*=========================================================================
|| PUBLIC PROCEDURE onlineAccounting
||
|| DESCRIPTION
||      This procedure generates online-Accounting
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||  Parameter:   p_loan_id => loan_ID
||               p_disb_header_id => null for ERS loan,
||                                  disb_header_id for DIRECT loan
||
|| Return value:  Standard  S = Success E = Error U = Unexpected
||
|| Source Tables:
||
|| Target Tables:
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 08-25-2005            raverma             Created
 *=======================================================================*/
procedure onlineAccounting(p_loan_id            IN NUMBER
                            ,p_init_msg_list      IN VARCHAR2
                            ,p_accounting_mode    IN VARCHAR2
                            ,p_transfer_flag		  IN VARCHAR2
                            ,p_offline_flag       IN VARCHAR2
                            ,p_gl_posting_flag    IN VARCHAR2
                            ,x_return_status      OUT NOCOPY VARCHAR2
                            ,x_msg_count          OUT NOCOPY NUMBER
                            ,x_msg_data           OUT NOCOPY VARCHAR2)

is
	l_legal_entity_id	     number;
    l_accounting_batch_id  NUMBER;
	l_errbuf               VARCHAR2(500);
	l_retcode              NUMBER;
	l_api_name		         varchar2(25);
	l_loan_class           varchar2(30);
    l_transactions_count   number;
    l_error_counter        number;
    l_error_message        varchar2(2000);
    l_invoice_number       varchar2(100);
    l_entity_code          varchar2(30);

    cursor c_loan_info(p_loan_id number) is
    select h.legal_entity_id
					,h.loan_class_code
      from lns_loan_headers h
     where h.loan_id = p_loan_id;

    -- this is only for loans entities
    cursor c_acc_errors (p_loan_id number, p_accounting_batch_id number) is
    select xlt.transaction_number, xlt.entity_code, err.encoded_msg
      from xla_accounting_errors err
          ,xla_Transaction_entities xlt
     where xlt.application_id = 206
       and err.accounting_batch_id = p_accounting_batch_id
       and err.entity_id = xlt.entity_id
       and xlt.entity_id in (select entity_id from xla_transaction_entities
                          where application_id = 206
                            and entity_code = 'LOANS'
                            and source_id_int_1 = p_loan_id
                            and source_id_int_2 IN
                             (select disb.disb_header_id
                                         from lns_disb_headers dh
                                             ,lns_distributions disb
                                        where disb.loan_id = p_loan_id
                                          and disb.disb_header_id = dh.disb_header_id
                                          and disb.account_name = 'LOAN_RECEIVABLE'
                                          and dh.status = 'FULLY_FUNDED'
                                          and not exists
                                            (select 'X'
                                               from xla_events xle
                                                    ,XLA_TRANSACTION_ENTITIES XLEE
                                                    ,xla_ae_headers aeh
                                              where XLE.application_id = 206
                                                and XLE.event_id = disb.event_id
                                                and XLE.entity_id = xlee.entity_id
                                                and XLEE.source_id_int_1 = dh.loan_id
                                                and XLEE.source_id_int_2 = dh.disb_header_id
                                                and xlee.entity_id = aeh.entity_id
                                                and xlee.ledger_id = aeh.ledger_id
                                                and aeh.accounting_entry_status_code = 'F'
                                                and xlee.entity_code = 'LOANS')
                                          or source_id_int_2 = -1)

                            and source_id_int_3 IN
                             (select disb.loan_amount_adj_id
                                         from lns_loan_amount_adjs ladj
                                             ,lns_distributions disb
                                        where disb.loan_id = p_loan_id
                                          and disb.loan_amount_adj_id = ladj.loan_amount_adj_id
                                          and disb.account_name = 'LOAN_RECEIVABLE'
                                          and ladj.status = 'APPROVED'
                                          and not exists
                                          (select 'X'
                                             from xla_events xle
                                                  ,XLA_TRANSACTION_ENTITIES XLEE
                                                  ,xla_ae_headers aeh
                                            where XLE.application_id = 206
                                              and XLE.event_id = disb.event_id
                                              and XLE.entity_id = xlee.entity_id
                                              and XLEE.source_id_int_1 = ladj.loan_id
                                              and XLEE.source_id_int_3 = ladj.loan_amount_adj_id
                                              and xlee.entity_id = aeh.entity_id
                                              and xlee.ledger_id = aeh.ledger_id
                                              and aeh.accounting_entry_status_code = 'F'
                                              and xlee.entity_code = 'LOANS')
                                          or source_id_int_3 = -1
                                          or source_id_int_3 IS NULL)
                               );

begin

    SAVEPOINT onlineAccounting;
    l_api_name := 'onlineAccounting';

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    open c_loan_info(p_loan_id);
    fetch c_loan_info into l_legal_entity_id, l_loan_class;
    close c_loan_info;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'running on-line accounting for loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_accounting_mode = ' || p_accounting_mode);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_transfer_flag = ' || p_transfer_flag);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_gl_posting_flag = ' || p_gl_posting_flag);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_offline_flag = ' || p_offline_flag);

    if l_loan_class = 'ERS' then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'ERS loan accounting');
        -- at this point in time, the INVOICES and ADJUSTMENTS MUST have already been accounted for
        insert into XLA_ACCT_PROG_DOCS_GT
                (entity_id)
            select entity_id from xla_transaction_entities
            where application_id = 206
            and entity_code = 'LOANS'
            and source_id_int_1 = p_loan_id
            and source_id_int_2 = -1
            and nvl(source_id_int_3, -1) = -1;

    else

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'DIRECT loan accounting');

        -- can we make join thru lns_distributions
        insert into XLA_ACCT_PROG_DOCS_GT
                (entity_id)
            select entity_id from xla_transaction_entities
            where application_id = 206
            and entity_code = 'LOANS'
            and source_id_int_1 = p_loan_id
            and (source_id_int_2 = -1
                 OR source_id_int_2 in (select disb.disb_header_id
                                        from lns_disb_headers dh
                                            ,lns_distributions disb
                                        where disb.loan_id = p_loan_id
                                        and disb.disb_header_id = dh.disb_header_id
                                        and disb.account_name = 'LOAN_RECEIVABLE'
                                        and dh.status = 'FULLY_FUNDED')
                )
            and (source_id_int_3 IS NULL  -- Before introducing MD loanAdjustment, source_id_int_3 values are NULL
                 OR source_id_int_3 = -1
                 OR source_id_int_3 in (select disb.loan_amount_adj_id
                                        from lns_loan_amount_adjs ladj
                                            ,lns_distributions disb
                                        where disb.loan_id = p_loan_id
                                        and disb.loan_amount_adj_id = ladj.loan_amount_adj_id
                                        and disb.account_name = 'LOAN_RECEIVABLE'
                                        and ladj.status = 'APPROVED')
                );
    end if;

    select count(1) into l_transactions_count
    from XLA_ACCT_PROG_DOCS_GT;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'inserted transaction_entities ' || l_transactions_count);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'calling XLA_ACCOUNTING_PUB_PKG.accounting_program_doc_batch ');
    XLA_ACCOUNTING_PUB_PKG.accounting_program_doc_batch(p_application_id      => 206
                                                        ,p_accounting_mode     => p_accounting_mode
                                                        ,p_gl_posting_flag     => p_gl_posting_flag
                                                        ,p_accounting_batch_id => l_accounting_batch_id
                                                        ,p_errbuf              => l_errbuf
                                                        ,p_retcode             => l_retcode);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_retcode = ' || l_retcode);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_accounting_batch_id = ' || l_accounting_batch_id);

    if l_retcode = 0 then

        --FND_MESSAGE.SET_NAME('XLA', 'XLA_ONLINE_ACCT_SUCCESS');
        --FND_MSG_PUB.Add;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'online accounting SUCCESS! ');

    elsif l_retcode = 2 then

        FND_MESSAGE.SET_NAME('XLA', 'XLA_ONLINE_ACCTG_ERROR');
        FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    elsif l_retcode = 1 then

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'online accounting failed ' || l_errbuf);
        /* query XLA_ACCOUNTING_ERRORS */
        l_error_counter := 0;
        open c_acc_errors(p_loan_id, l_accounting_batch_id);

        LOOP

            fetch c_acc_errors into
                l_invoice_number,
                l_entity_code,
                l_error_message;
            exit when c_acc_errors%NOTFOUND;

            l_error_counter := l_error_counter + 1;

            if l_error_counter = 1 then
                FND_MESSAGE.SET_NAME('XLA', 'XLA_ONLINE_ACCT_WARNING');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            end if;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_ACC_DOC_FAIL');
            FND_MESSAGE.SET_TOKEN('DOC_NUM', l_invoice_number);
            FND_MESSAGE.SET_TOKEN('DOC_TYPE', l_entity_code);
            FND_MESSAGE.SET_TOKEN('ACC_ERR', l_error_message);
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));

        END LOOP;

        close c_acc_errors;

        RAISE FND_API.G_EXC_ERROR;
    end if;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
    commit;
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO onlineAccounting;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO onlineAccounting;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO onlineAccounting;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

end onlineAccounting;


/*=========================================================================
|| PUBLIC PROCEDURE LNS_ACCOUNTING_CONCUR
||
|| DESCRIPTION
||      This procedure generates generates ERS distributions
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
||  Parameter:   p_loan_id => p_loan_ID
||
|| Return value:  Standard  CP parameters
||
|| Source Tables:
||
|| Target Tables:
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 01-05-2006            raverma             Created
|| 23-Dec-2008           mbolli             Changed the param name from loan_id
||                                            to p_loan_id
 *=======================================================================*/
PROCEDURE LNS_ACCOUNTING_CONCUR(ERRBUF              OUT NOCOPY     VARCHAR2
                               ,RETCODE             OUT NOCOPY     VARCHAR2
                               ,P_LOAN_ID             IN             NUMBER)
IS
   l_loan_class_code        varchar2(30);
   l_gl_date                date;
   l_api_name               varchar2(30);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_return_Status          VARCHAR2(1);
   x_event_id               number;
   l_object_version_number  number;
   l_loan_header_rec        LNS_LOAN_HEADER_PUB.LOAN_HEADER_REC_TYPE;
   l_return                 boolean;
   l_do_billing             number;
   l_last_api_called        varchar2(100);
   l_request_id             number;
   l_org_id                 number;
   l_xml_output            BOOLEAN;
   l_iso_language          FND_LANGUAGES.iso_language%TYPE;
   l_iso_territory         FND_LANGUAGES.iso_territory%TYPE;

   cursor c_loan_info (c_loan_id number) is
   select loan_class_code
         ,gl_date
         ,OBJECT_VERSION_NUMBER
         ,org_id
     from lns_loan_headers
    where loan_id = c_loan_id;

    CURSOR do_billing_cur(C_LOAN_ID number) IS
    select nvl(count(1),0)
      from lns_fee_assignments
     where begin_installment_number = 0
       and end_installment_number = 0
       and end_date_active is null
       and billing_option = 'ORIGINATION'
       and loan_id = C_LOAN_ID;


begin

    l_api_name   := 'LNS_ACCOUNTING_CONCUR';

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Generate Distributions process has started');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'LOAN_ID = ' || P_LOAN_ID);
    if P_LOAN_ID is null then

--        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: Loan must be set.');
    	FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_LOAN');
		FND_MSG_PUB.Add;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    open c_loan_info(P_LOAN_ID);
    fetch c_loan_info into l_loan_class_code, l_gl_date, l_object_version_number, l_org_id;
    close c_loan_info;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_class_code = ' || l_loan_class_code);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_gl_date = ' || l_gl_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_object_version_number = ' || l_object_version_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_org_id = ' || l_org_id);


    IF ((l_loan_class_code IS NULL) OR (l_loan_class_code <> 'ERS')) THEN
	logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || ' - Only works for ERS loans.');
	return;
    END IF;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');
        LNS_XLA_EVENTS.create_event(p_loan_id         =>  P_LOAN_ID
                                    ,p_disb_header_id  => -1
                                    ,p_loan_amount_adj_id => -1
                                    ,p_event_type_code => 'APPROVED'
                                    ,p_event_date      => l_gl_date
                                    ,p_event_status    => 'U'
                                    ,p_init_msg_list   => fnd_api.g_false
                                    ,p_commit          => fnd_api.g_false
                                    ,p_bc_flag         => 'N'
                                    ,x_event_id        => x_event_id
                                    ,x_return_status   => l_return_status
                                    ,x_msg_count       => l_msg_count
                                    ,x_msg_data        => l_msg_data);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'event_id = ' || x_event_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
            FND_MSG_PUB.ADD;
            --l_last_api_called := 'LNS_XLA_EVENTS.create_event';
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



    -- we should do online accounting in batch mode here
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling Lns_distributions_pub.defaultDistributions...');
    Lns_distributions_pub.defaultDistributions(p_api_version     => 1.0
                                                ,p_init_msg_list   => FND_API.G_TRUE
                                                ,p_commit          => FND_API.G_FALSE
                                                ,p_loan_id         => P_LOAN_ID
                                                ,p_loan_class_code => l_loan_class_code
                                                ,x_return_status   => l_return_status
                                                ,x_msg_count       => l_msg_count
                                                ,x_msg_data        => l_msg_data);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
--        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Call to Lns_distributions_pub.defaultDistributions failed with status ' || l_return_status);
--        fnd_file.put_line(FND_FILE.LOG, 'FAILED TO INHERIT DISTRIBUTIONS');
        --l_last_api_called := 'Lns_distributions_pub.defaultDistributions';
        RAISE FND_API.G_EXC_ERROR;
    ELSE

        if x_event_id is not null then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_distributions...');
            update lns_distributions
                set event_id = x_event_id
            where loan_id = P_LOAN_ID
                and account_name in ('LOAN_RECEIVABLE', 'LOAN_CLEARING')
                and distribution_type = 'ORIGINATION';
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');
        end if;

        -- finally update the loan header
        l_loan_header_rec.loan_id               := P_LOAN_ID;
        l_loan_header_rec.loan_status           := 'ACTIVE';
        l_loan_header_rec.secondary_status      := FND_API.G_MISS_CHAR;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Before call to LNS_LOAN_HEADER_PUB.update_loan');
        LNS_LOAN_HEADER_PUB.update_loan(p_init_msg_list         => FND_API.G_FALSE
                                        ,p_loan_header_rec       => l_loan_header_rec
                                        ,p_object_version_number => l_object_version_number
                                        ,x_return_status         => l_return_status
                                        ,x_msg_count             => l_msg_count
                                        ,x_msg_data              => l_msg_data);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_msg_data = ' || l_msg_data);

    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        RAISE FND_API.G_EXC_ERROR;
    else
      -- now check if 0th installment needs billing

        /* check to start billing for 0-th installment */
        open do_billing_cur(l_loan_header_rec.loan_id);
        fetch do_billing_cur into l_do_billing;
        close do_billing_cur;
        LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_do_billing = ' || l_do_billing);

        if l_do_billing > 0 then

            LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Billing Concurrent Program to bill 0-th installment...');
            FND_REQUEST.SET_ORG_ID(l_org_id);

            -- Bug#6313716 : Invoke the function add_layout to specify the template type,code etc., before submitting request
            SELECT
            lower(iso_language),iso_territory
            INTO
            l_iso_language,l_iso_territory
            FROM
            FND_LANGUAGES
            WHERE
            language_code = USERENV('LANG');

            l_xml_output:=  fnd_request.add_layout(
                    template_appl_name  => 'LNS',
                    template_code       => 'LNSRPTBL',  --fix for bug 8830573
                    template_language   => l_iso_language,
                    template_territory  => l_iso_territory,
                    output_format       => 'PDF'
                    );


            l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                            'LNS',
                            'LNS_BILLING',
                            '', '', FALSE,
                            null,
                            l_loan_header_rec.loan_id,
                            null,
                            null);

            if l_request_id = 0 then
                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('LNS', 'LNS_BILLING_REQUEST_FAILED');
                FND_MSG_PUB.Add;
                l_last_api_called := 'FND_REQUEST.SUBMIT_REQUEST for 0th installment billing';
                RAISE FND_API.G_EXC_ERROR;
            else
                LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully submited Billing Concurrent Program to bill 0-th installment. Request id = ' || l_request_id);
            end if;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'After call to submit request');

        end if;

    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, ' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, '-------------------');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Generate Distributions process has succeeded!');

EXCEPTION
    WHEN others THEN
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status  => 'ERROR',
                        message => 'Generate Distributions process has failed. Please review log file.');
        RETCODE := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count => l_msg_count,   p_data => ERRBUF);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, ' ');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, '-------------------');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, 'Generate Distributions process has failed!');

end LNS_ACCOUNTING_CONCUR;


procedure createDistrForImport(p_api_version                IN NUMBER
                            ,p_init_msg_list              IN VARCHAR2
                            ,p_commit                     IN VARCHAR2
                            ,p_loan_id                    IN NUMBER
                            ,x_distribution_tbl           IN OUT NOCOPY lns_distributions_pub.distribution_tbl
                            ,x_return_status              OUT NOCOPY VARCHAR2
                            ,x_msg_count                  OUT NOCOPY NUMBER
                            ,x_msg_data                   OUT NOCOPY VARCHAR2)

is
/*------------------------------------------------------------------------+
 | Local Variable Declarations and initializations                        |
 +-----------------------------------------------------------------------*/
    l_api_name                 varchar2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_return_Status            VARCHAR2(1);
    l_event_id                 NUMBER;
    l_gl_date                  DATE;

/*------------------------------------------------------------------------+
 | Cursor Declarations                                                    |
 +-----------------------------------------------------------------------*/

    cursor c_loan_info (c_loan_id number) is
        select gl_date
        from lns_loan_headers
        where loan_id = c_loan_id;

begin

    SAVEPOINT createDistrForImport;
    l_api_name   := 'createDistrForImport';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* deleting any existing accounting rows */
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' deleting any existing accounting rows');
    delete from lns_distributions
    where loan_id = p_loan_id;

    do_insert_distributions(p_distributions_tbl => x_distribution_tbl
                            ,p_loan_id           => p_loan_id);

    -- validate the accounting rows here
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' validating Accounting');
    lns_distributions_pub.validateAccounting(p_loan_id          => p_loan_id
                                            ,p_init_msg_list    => p_init_msg_list
                                            ,x_return_status    => l_return_status
                                            ,x_msg_count        => l_msg_count
                                            ,x_msg_data         => l_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'Accounting status is ' || l_return_status);
    if l_return_status <> 'S' then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_DEFAULT_DIST_NOT_FOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    open c_loan_info(P_LOAN_ID);
    fetch c_loan_info into l_gl_date;
    close c_loan_info;
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_gl_date = ' || l_gl_date);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');
    LNS_XLA_EVENTS.create_event(p_loan_id         =>  P_LOAN_ID
                                ,p_disb_header_id  => -1
                                ,p_loan_amount_adj_id => -1
                                ,p_event_type_code => 'APPROVED'
                                ,p_event_date      => l_gl_date
                                ,p_event_status    => 'U'
                                ,p_init_msg_list   => fnd_api.g_false
                                ,p_commit          => fnd_api.g_false
                                ,p_bc_flag         => 'N'
                                ,x_event_id        => l_event_id
                                ,x_return_status   => l_return_status
                                ,x_msg_count       => l_msg_count
                                ,x_msg_data        => l_msg_data);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
        FND_MSG_PUB.ADD;
        --l_last_api_called := 'LNS_XLA_EVENTS.create_event';
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    if l_event_id is not null then
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_distributions...');
        update lns_distributions
            set event_id = l_event_id
        where loan_id = P_LOAN_ID
            and account_name in ('LOAN_RECEIVABLE', 'LOAN_CLEARING')
            and distribution_type = 'ORIGINATION';
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');
    end if;

    IF FND_API.to_Boolean(p_commit)
    THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        ROLLBACK TO createDistrForImport;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        ROLLBACK TO createDistrForImport;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        ROLLBACK TO createDistrForImport;

end;



/*=========================================================================
|| PROCEDURE DEFAULT_ADJUSTMENT_DISTRIBS
||
|| DESCRIPTION
||   This procedure does funds check / funds reserve for negative loanAdjustment
||
||
|| PARAMETERS   p_loan_amount_adj_id => loan adjustment identifier
||              p_loan_id            => loan_id is considered to retrieve
||                        pending adjustment if loan_amount_adj_id is NULL
||
|| Return value:  None
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 26-Mar-2010           mbolli              Created
 *=======================================================================*/
PROCEDURE DEFAULT_ADJUSTMENT_DISTRIBS(p_init_msg_list          in varchar2
                            ,p_commit                 in varchar2
                            ,p_loan_amount_adj_id     in number  DEFAULT NULL
                            ,p_loan_id                in number
                            ,x_return_status          OUT NOCOPY VARCHAR2
                            ,x_msg_count              OUT NOCOPY NUMBER
                            ,x_msg_data               OUT NOCOPY VARCHAR2)
is
    l_api_name              varchar2(50);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_loan_id               number;
    l_loan_amount_adj_id    number;
    l_adj_status		varchar2(30);
    l_adj_amount		number;


    cursor c_loan_adj_det(c_loan_amount_adj_id number) is
      SELECT LOAN_ID, STATUS, ADJUSTMENT_AMOUNT
      FROM LNS_LOAN_AMOUNT_ADJS
      WHERE loan_amount_adj_id = c_loan_amount_adj_id;


    cursor c_loan_adj(c_loan_id number) is
      SELECT LOAN_AMOUNT_ADJ_ID, STATUS, ADJUSTMENT_AMOUNT
      FROM LNS_LOAN_AMOUNT_ADJS
      WHERE loan_id = c_loan_id
        AND status = 'PENDING';

BEGIN

    SAVEPOINT adjustment_distribs_pvt;
    l_api_name := 'DEFAULT_ADJUSTMENT_DISTRIBS';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = '  || p_loan_amount_adj_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = '  || p_loan_id);

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status         := FND_API.G_RET_STS_SUCCESS;

    -- We can't default distributions without valid loan adjustment
    IF p_loan_amount_adj_id IS NULL THEN
        -- Retrieve the Pending Loan Amount Adjustment Id of the loan
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Retrieve the pending loan_amount_adj_id based on the input loan_id');

        lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                      ,p_init_msg_list  =>  p_init_msg_list
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,x_return_status  =>  l_return_status
                                      ,p_col_id         =>  p_loan_id
                                      ,p_col_name       =>  'LOAN_ID'
                                      ,p_table_name     =>  'LNS_LOAN_HEADERS');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', p_loan_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        OPEN c_loan_adj(p_loan_id);
        FETCH c_loan_adj INTO l_loan_amount_adj_id, l_adj_status, l_adj_amount;
        CLOSE c_loan_adj;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_loan_amount_adj_id = ' || l_loan_amount_adj_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_adj_status = ' || l_adj_status);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_adj_amount = ' || l_adj_amount);


        -- We can't default distributions without valid loan adjustment
        IF (l_loan_amount_adj_id IS NULL) THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_AMOUNT_ADJ_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', l_loan_amount_adj_id);
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_loan_id := p_loan_id;

    ELSE  -- ELSE OF p_loan_amount_adj_id IS NULL
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Validating input p_loan_amount_adj_id');

        lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                      ,p_init_msg_list  =>  p_init_msg_list
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,x_return_status  =>  l_return_status
                                      ,p_col_id         =>  p_loan_amount_adj_id
                                      ,p_col_name       =>  'LOAN_AMOUNT_ADJ_ID'
                                      ,p_table_name     =>  'LNS_LOAN_AMOUNT_ADJS');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_AMOUNT_ADJ_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', p_loan_amount_adj_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;


        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fetching l_loan_adj details');

        open c_loan_adj_det(p_loan_amount_adj_id);
        fetch c_loan_adj_det into l_loan_id, l_adj_status, l_adj_amount;
        close c_loan_adj_det;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_loan_id = ' || l_loan_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_adj_status = ' || l_adj_status);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_adj_amount = ' || l_adj_amount);

        l_loan_amount_adj_id  :=  p_loan_amount_adj_id;

    END IF;   -- IF p_loan_amount_adj_id IS NULL

    IF l_adj_status in ('APPROVED', 'REJECTED', 'DELETED') THEN
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'The distributions of adjustment with status '||l_adj_status||' cant be deleted');

      FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
      FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_AMOUNT_ADJ_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', l_loan_amount_adj_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      /* delete any rows for this loan before inheritance do not delete FEE_RECEIVABLE or FEE_INCOME rows*/
      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Deleting any existing adjustment accounting rows for '||l_loan_id||'-'||l_loan_amount_adj_id);

      delete from lns_distributions
      where loan_id = l_loan_id
        and loan_amount_adj_id = l_loan_amount_adj_id
        and account_name in ('LOAN_RECEIVABLE', 'LOAN_PAYABLE');

      logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Deleted '||SQL%ROWCOUNT||' rows succesfully');

    END IF;

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' Calling create_DisbursementDistribs');
    LNS_DISTRIBUTIONS_PUB.create_DisbursementDistribs(p_api_version  => 1
			                               ,p_init_msg_list  => 'F'
			                               ,p_commit         => 'T'
			                               ,p_loan_id        =>  l_loan_id
                                     ,p_disb_header_id =>  NULL
                                     ,p_loan_amount_adj_id => l_loan_amount_adj_id
                                     ,p_activity_type  =>  'DIRECT_LOAN_ADJUSTMENT'
			                               ,x_return_status  =>  l_return_status
			                               ,x_msg_count      =>  l_msg_count
			                               ,x_msg_data       =>  l_msg_data);
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' The return status is '||l_return_status);

    IF l_return_status <> 'S' THEN
      logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' CreationDisbursementDistribs failed with error '||l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO adjustment_distribs_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO adjustment_distribs_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO adjustment_distribs_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
 END DEFAULT_ADJUSTMENT_DISTRIBS;

/*=========================================================================
|| PROCEDURE LOAN_ADJUSTMENT_BUDGET_CONTROL
||
|| DESCRIPTION
||   This procedure does funds check / funds reserve for negative loanAdjustment
||
||
|| PARAMETERS   p_loan_amount_adj_id => loan adjustment identifier
||              p_loan_id            => loan_id is considered if loan_amount_adj_id is NULL
||              p_budgetary_control_mode => 'C' Check ; 'R' Reserve
||
|| Return value:  x_budgetary_status_code
||                    SUCCESS   = FUNDS CHECK / RESERVE SUCCESSFUL
||                    PARTIAL   = AT LEAST ONE EVENT FAILED
||                    FAIL      = FUNDS CHECK / RESERVE FAILED
||                    XLA_ERROR = XLA SetUp ERROR
||                    ADVISORY  = BUDGETARY WARNING
||
|| Source Tables: NA
||
|| Target Tables: NA
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 24-Mar-2010           mbolli              Created
 *=======================================================================*/
PROCEDURE LOAN_ADJUSTMENT_BUDGET_CONTROL(p_init_msg_list          in varchar2
                            ,p_commit                 in varchar2
                            ,p_loan_amount_adj_id     in number  DEFAULT NULL
                            ,p_loan_id                in number
                            ,p_budgetary_control_mode in varchar2
                            ,x_budgetary_status_code  out nocopy varchar2
                            ,x_return_status          OUT NOCOPY VARCHAR2
                            ,x_msg_count              OUT NOCOPY NUMBER
                            ,x_msg_data               OUT NOCOPY VARCHAR2)
is
    l_api_name              varchar2(50);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_return_Status         VARCHAR2(1);
    l_status_code           varchar2(50);
    l_packet_id             number;
    l_event_id              number;
    l_version               number;
    l_budget_req_approval   varchar2(1);
    l_funds_reserved_flag   varchar2(1);
    l_gl_date               date;
    l_budget_event_exists   number;
    l_loan_header_rec       LNS_LOAN_HEADER_PUB.loan_header_rec_type;
    l_loan_id               number;
    l_loan_amount_adj_id    number;
    l_adj_status		varchar2(30);
    l_adj_amount		number;
    x_event_id              number;
    l_event_type            varchar2(30);

    cursor c_budget_req(c_loan_amount_adj_id number) is
    select nvl(p.BDGT_REQ_FOR_APPR_FLAG, 'N')
               ,nvl(ladj.funds_reserved_flag, 'N')
               ,nvl(h.gl_date, sysdate)
        from lns_loan_headers h,
                lns_loan_products p,
                lns_loan_amount_adjs ladj
        where p.loan_product_id = h.product_id
          and ladj.loan_id = h.loan_id
          and ladj.loan_amount_adj_id = c_loan_amount_adj_id;

    -- get budgetary control events only
    cursor c_events(c_loan_amount_adj_id number, c_event_type varchar2) is
    select event_id
            from xla_transaction_entities xlee
                ,xla_events xle
        where xle.application_id = 206
        and xle.entity_id = xlee.entity_id
            and xlee.source_id_int_3 = c_loan_amount_adj_id
            and xle.event_type_code = c_event_type
            and xle.budgetary_control_flag = 'Y'
            and xle.process_status_code <> 'P'
        order by event_id desc;


    cursor c_loan_adj_det(c_loan_amount_adj_id number) is
      SELECT LOAN_ID, STATUS, ADJUSTMENT_AMOUNT
      FROM LNS_LOAN_AMOUNT_ADJS
      WHERE loan_amount_adj_id = c_loan_amount_adj_id;


    cursor c_loan_adj(c_loan_id number) is
      SELECT LOAN_AMOUNT_ADJ_ID, STATUS, ADJUSTMENT_AMOUNT
      FROM LNS_LOAN_AMOUNT_ADJS
      WHERE loan_id = c_loan_id
        AND status = 'PENDING';

	cursor c_obj_vers(p_loan_id number) is
	  	select object_version_number
		from lns_loan_headers
		where loan_id = p_loan_id;

	cursor c_obj_vers_adj(c_loan_amount_adj_id number) is
	  	select object_version_number
		from lns_loan_amount_adjs
		where loan_amount_adj_id = c_loan_amount_adj_id;


    cursor c_budget_event(c_loan_adj_id number, c_event_type varchar2) is
    select count(1)
      from xla_transaction_entities xlee
          ,xla_events xle
      where xle.application_id = 206
        and xle.entity_id = xlee.entity_id
        and xlee.source_id_int_3 = c_loan_adj_id
        and xle.event_type_code = c_event_type
        and xle.budgetary_control_flag = 'Y'
        and xle.process_status_code <> 'P';

begin

    SAVEPOINT loan_adj_reverse_bc_pvt;
    l_api_name := 'LOAN_ADJUSTMENT_BUDGET_CONTROL';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = '  || p_loan_amount_adj_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_id = '  || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_budgetary_control_mode = ' || p_budgetary_control_mode);

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status         := FND_API.G_RET_STS_SUCCESS;

    -- We can't check funds without valid loan adjustment
    IF p_loan_amount_adj_id IS NULL THEN
        -- Retrieve the Pending Loan Amount Adjustment Id of the loan
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Retrieve the pending loan_amount_adj_id based on the input loan_id');

        lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                      ,p_init_msg_list  =>  p_init_msg_list
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,x_return_status  =>  l_return_status
                                      ,p_col_id         =>  p_loan_id
                                      ,p_col_name       =>  'LOAN_ID'
                                      ,p_table_name     =>  'LNS_LOAN_HEADERS');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', p_loan_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

        OPEN c_loan_adj(p_loan_id);
        FETCH c_loan_adj INTO l_loan_amount_adj_id, l_adj_status, l_adj_amount;
        CLOSE c_loan_adj;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_loan_amount_adj_id = ' || l_loan_amount_adj_id);

        -- We can't check funds without valid loan adjustment
        IF (l_loan_amount_adj_id IS NULL) THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_AMOUNT_ADJ_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', l_loan_amount_adj_id);
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_loan_id := p_loan_id;

    ELSE  -- ELSE OF p_loan_amount_adj_id IS NULL
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Validating input p_loan_amount_adj_id');

        lns_utility_pub.validate_any_id(p_api_version    =>  1.0
                                      ,p_init_msg_list  =>  p_init_msg_list
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,x_return_status  =>  l_return_status
                                      ,p_col_id         =>  p_loan_amount_adj_id
                                      ,p_col_name       =>  'LOAN_AMOUNT_ADJ_ID'
                                      ,p_table_name     =>  'LNS_LOAN_AMOUNT_ADJS');

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_AMOUNT_ADJ_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', p_loan_amount_adj_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;


        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'fetching l_loan_adj details');

        open c_loan_adj_det(p_loan_amount_adj_id);
        fetch c_loan_adj_det into l_loan_id, l_adj_status, l_adj_amount;
        close c_loan_adj_det;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_loan_id = ' || l_loan_id);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_adj_status = ' || l_adj_status);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_adj_amount = ' || l_adj_amount);


        IF l_adj_status <> 'PENDING' THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CHK_PENDING_ADJ');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'LOAN_ID');
            FND_MESSAGE.SET_TOKEN('VALUE', l_loan_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_loan_amount_adj_id  :=  p_loan_amount_adj_id;

    END IF;   -- IF p_loan_amount_adj_id IS NULL

    -- If it is negative adjustment then the event is reversal else it is adj approved
    l_event_type    :=  'DIRECT_LOAN_ADJ_APPROVED';
    IF l_adj_amount < 0 THEN
      l_event_type  :=  'DIRECT_LOAN_ADJ_REVERSED';
    END IF;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_event_type = ' || l_event_type);

    if (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y' AND l_loan_amount_adj_id IS NOT NULL) then

        -- check if budget event exists
        -- find if budgetary event already exists, if not, create the event
        open c_budget_event(l_loan_amount_adj_id, l_event_type);
        fetch c_budget_event into l_budget_event_exists;
        close c_budget_event;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_budget_event_exists = ' || l_budget_event_exists);

        open c_budget_req(l_loan_amount_adj_id);
        fetch c_budget_req into l_budget_req_approval, l_funds_reserved_flag, l_gl_date;
        close c_budget_req;

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_budget_req_approval = '  || l_budget_req_approval);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_funds_reserved_flag = '  || l_funds_reserved_flag);

        if l_budget_event_exists = 0 then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');

            LNS_XLA_EVENTS.create_event(p_loan_id         => p_loan_id
                                    ,p_disb_header_id  => -1
                                    ,p_loan_amount_adj_id => l_loan_amount_adj_id
                                    ,p_event_type_code => l_event_type
                                    ,p_event_date      => l_gl_date
                                    ,p_event_status    => 'U'
                                    ,p_init_msg_list   => fnd_api.g_false
                                    ,p_commit          => fnd_api.g_false
                                    ,p_bc_flag         => 'Y'
                                    ,x_event_id        => x_event_id
                                    ,x_return_status   => x_return_status
                                    ,x_msg_count       => x_msg_count
                                    ,x_msg_data        => x_msg_data);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_return_status = ' || x_return_status);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_event_id ' || x_event_id);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
                FND_MSG_PUB.ADD;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

	    -- stamp the eventID onto the lns_distributions table
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'stamping eventID on lns_distributions');



            update lns_distributions
            set event_id = x_event_id
                ,last_update_date = sysdate
            where distribution_type = 'ORIGINATION'
            and loan_id             = p_loan_id
            and loan_amount_adj_id  =  l_loan_amount_adj_id;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updated event_id succesfully for '||SQL%ROWCOUNT||' rows');

        end if; -- budget event already created




        -- now process the event
        if l_funds_reserved_flag <> 'Y' then
            --and p_budgetary_control_mode = 'R' then
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'getting the latest events');

            open c_events(l_loan_amount_adj_id, l_event_type);
          --  LOOP
            fetch c_events into l_event_id;
           --     EXIT WHEN c_events%NOTFOUND;
	   IF l_event_id IS NOT NULL THEN

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);

		-- Bug#9328437, First time, when we do fundsCheck, the event_id creates and updates in lns_distributions table.
		-- However if we do fundsCheck/fundsReserver later, existed distribtuions are deleted and again
		-- defaulted, which has event_id as NULL. So, update the event_id if it is already created whose event_id is NULL
		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'stamping eventID on lns_distributions whose eventID is NULL');
            	update lns_distributions
            	set event_id = l_event_id
                	,last_update_date = sysdate
              where distribution_type = 'ORIGINATION'
                and event_id IS NULL
                and loan_id  = p_loan_id
                and loan_amount_adj_id = l_loan_amount_adj_id;

              logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updated event_id succesfully for '||SQL%ROWCOUNT||' rows');
                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'inserting into  PSA_BC_XLA_EVENTS_GT ');
                insert
                into PSA_BC_XLA_EVENTS_GT (event_id, result_code)
                values (l_event_id, 'FAIL');

                logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling PSA_BC_XLA_PUB.Budgetary_Control  '  || l_event_id);
                PSA_BC_XLA_PUB.Budgetary_Control(p_api_version      => 1.0
                                                ,p_init_msg_list    => FND_API.G_FALSE
                                                ,x_return_status    => l_return_status
                                                ,x_msg_count        => l_msg_count
                                                ,x_msg_data         => l_msg_data
                                                ,p_application_id   => 206
                                                ,p_bc_mode          => p_budgetary_control_mode
                                                ,p_override_flag    => null
                                                ,p_user_id          => null
                                                ,p_user_resp_id     => null
                                                ,x_status_code      => l_status_code
                                                ,x_packet_ID        => l_packet_id);
	    END IF;
          --  end loop;
            close c_events;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'BC status is = ' || l_return_status);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_status_code = ' || l_status_code);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'l_packet_id = ' || l_packet_id);

            -- we want to commit ONLY in the case of SUCCESS or ADVISORY
            if (l_return_status <> 'S' ) then

                l_return_status         := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,'Call to PSA_BC_XLA_PUB.Budgetary_Control failed with Status Code = ' || l_status_code);
                FND_MSG_PUB.ADD;
                logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;

            else
		logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_budget_req_approval = '  || l_budget_req_approval);

		if ( l_budget_req_approval = 'N' and p_budgetary_control_mode = 'R'
			and (l_status_code = 'FAIL' or l_status_code = 'PARTIAL' or l_status_code = 'XLA_ERROR')) then

			x_budgetary_status_code  := l_status_code;
        		x_return_status          := l_return_status;

			/*
			FND_MESSAGE.SET_NAME('LNS', 'LNS_ADJ_APPROVAL_NO_BUDGET');
        		FND_MSG_PUB.ADD_DETAIL(p_message_type => FND_MSG_PUB.G_WARNING_MSG );
        		LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
			*/

			LogMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, ' BudgetReserve is not mandatory for LoanAdjustment Approval, so returning to invoked method');

			FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

			return;

		end if;


                if l_status_code NOT IN ('SUCCESS','ADVISORY') then
                    IF  (l_status_code = 'PARTIAL') THEN
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_FUND_CHK_PARTIAL');
                        FND_MSG_PUB.ADD;
                        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
                        FND_MESSAGE.SET_TOKEN('ERROR' ,'Call to PSA_BC_XLA_PUB.Budgetary_Control failed with Status Code = ' || l_status_code);
                        FND_MSG_PUB.ADD;
                        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                end if;

		-- For FundsReserve, we update the fundsCheckDate from UI
		IF  p_budgetary_control_mode = 'C'  THEN
			open c_obj_vers(p_loan_id);
			fetch c_obj_vers into l_version;
			close c_obj_vers;

			l_loan_header_rec.loan_id             := p_loan_id;
			l_loan_header_rec.FUNDS_CHECK_DATE    := sysdate;
			logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_api_name || 'updating loan');
			LNS_LOAN_HEADER_PUB.UPDATE_LOAN(P_OBJECT_VERSION_NUMBER => l_version
						,P_LOAN_HEADER_REC       => l_loan_header_rec
						,P_INIT_MSG_LIST         => FND_API.G_FALSE
						,X_RETURN_STATUS         => l_return_status
						,X_MSG_COUNT             => l_msg_count
						,X_MSG_DATA              => l_msg_data);
			logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'update loan status = ' || l_return_status);

			if l_return_status <> 'S' then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_UPD_LOAN_FAIL');
        FND_MSG_PUB.ADD;
        logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
			end if;
		END IF;

		x_budgetary_status_code  := l_status_code;
        	x_return_status          := l_return_status;

            end if; -- BC_API.RETURN_STATUS

        end if; -- l_funds_reserved_flag


        IF (l_return_status = 'S' AND FND_API.to_Boolean(p_commit))
        THEN
            COMMIT WORK;
        END IF;

 	end if;  -- no budgetary control-- end if (lns_utility_pub.IS_FED_FIN_ENABLED = 'Y' AND l_disbursement_id IS NOT NULL) then

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO loan_adj_reverse_bc_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO loan_adj_reverse_bc_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO loan_adj_reverse_bc_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END LOAN_ADJUSTMENT_BUDGET_CONTROL;


/*=========================================================================
 | PUBLIC procedure validateAddRecAccounting
 |
 | DESCRIPTION
 |        validates accounting records for a given additional receivable
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
 |           p_loan_line_id => loan line id
 |
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date             Author            Description of Changes
 | 04-01-2010       scherkas          Created
 |
 *=======================================================================*/
procedure validateAddRecAccounting(p_loan_id                    in  number
                                   ,p_loan_line_id              IN NUMBER
                                   ,p_init_msg_list             IN VARCHAR2
                                   ,x_return_status             OUT NOCOPY VARCHAR2
                                   ,x_msg_count                 OUT NOCOPY NUMBER
                                   ,x_msg_data                  OUT NOCOPY VARCHAR2)
is

    l_loan_receivables_orig LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_loan_clearing_orig    LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_loan_receivables_bill LNS_DISTRIBUTIONS_PUB.distribution_tbl;
    l_dist_percent_rec_bill number;
    l_api_name              varchar2(30);

begin

    l_api_name := 'validateAddRecAccounting';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_dist_percent_rec_bill   := 0;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 1...');
    l_loan_clearing_orig    := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                        ,p_loan_line_id      => p_loan_line_id
                                                                        ,p_account_type      => 'CR'
                                                                        ,p_account_name      => 'LOAN_CLEARING'
                                                                        ,p_line_type         => 'CLEAR'
                                                                        ,p_distribution_type => 'ORIGINATION');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_clearing_orig count = ' || l_loan_clearing_orig.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 2...');
    l_loan_receivables_orig := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                        ,p_loan_line_id      => p_loan_line_id
                                                                        ,p_account_type      => 'DR'
                                                                        ,p_account_name      => 'LOAN_RECEIVABLE'
                                                                        ,p_line_type         => 'ORIG'
                                                                        ,p_distribution_type => 'ORIGINATION');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_receivables_orig count = ' || l_loan_receivables_orig.count);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_DISTRIBUTIONS_PUB.getDistributions 3...');
    l_loan_receivables_bill  := LNS_DISTRIBUTIONS_PUB.getDistributions(p_loan_id           => p_loan_id
                                                                        ,p_loan_line_id      => p_loan_line_id
                                                                        ,p_account_type      => 'CR'
                                                                        ,p_account_name      => 'LOAN_RECEIVABLE'
                                                                        ,p_line_type         => 'PRIN'
                                                                        ,p_distribution_type => 'BILLING');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_receivables_bill count = ' || l_loan_receivables_bill.count);

    for j in 1..l_loan_receivables_bill.count loop
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, l_loan_receivables_bill(j).CODE_COMBINATION_ID || ' - ' ||
            l_loan_receivables_bill(j).distribution_percent || '%');
        l_dist_percent_rec_bill := l_dist_percent_rec_bill + l_loan_receivables_bill(j).distribution_percent;
    end loop;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_dist_percent_rec_bill = ' || l_dist_percent_rec_bill);
    if l_dist_percent_rec_bill <> 100 then
        FND_MESSAGE.Set_Name('LNS', 'LNS_ACC_BILL_REC_PER_INVALID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                            ,p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

Exception
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                                ,p_data  => x_msg_data);
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);

end;



/*=========================================================================
 | PUBLIC procedure createDistrForAddRec
 |
 | DESCRIPTION
 |        This procedure creates accounting records for an additional receivable
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |           p_loan_id => id of loan
 |           p_loan_line_id => loan line id
 |
 | Return value: standard api values
 |
 | Source Tables: lns_Distritbutions
 |
 | Target Tables: NA
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date             Author            Description of Changes
 | 04-01-2010       scherkas          Created
 |
 *=======================================================================*/
procedure createDistrForAddRec(p_api_version                IN NUMBER
                              ,p_init_msg_list              IN VARCHAR2
                              ,p_commit                     IN VARCHAR2
                              ,p_loan_id                    IN NUMBER
                              ,p_loan_line_id               IN NUMBER
                              ,x_return_status              OUT NOCOPY VARCHAR2
                              ,x_msg_count                  OUT NOCOPY NUMBER
                              ,x_msg_data                   OUT NOCOPY VARCHAR2)
is
/*------------------------------------------------------------------------+
 | Local Variable Declarations and initializations                        |
 +-----------------------------------------------------------------------*/
    l_api_name                 varchar2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_return_Status            VARCHAR2(1);
    i                          number;
    n                          number;
    y                          number;
    l_code_combination_id      number;
    l_code_combination_id_new_rec number;
    l_distributionsCLEAR_ORIG  lns_distributions_pub.distribution_tbl;
    l_distributionsREC_ORIG    lns_distributions_pub.distribution_tbl;
    l_distributionsREC_BILL    lns_distributions_pub.distribution_tbl;
    l_distributionsALL         lns_distributions_pub.distribution_tbl;
    l_ers_distribution_amount  number;
    l_ledger_details           lns_distributions_pub.gl_ledger_details;
    l_sum                      number;
    l_natural_account_rec      varchar2(25);  -- the lns_def_distribs replacement  for Loans Receivable
    l_nat_acct_seg_number      number;
    l_adjustment_exists        boolean;
    l_funded_amount            number;
    l_billed_amount            number;
    l_adj_date                 date;
    l_running_percent          number;
    l_percent                  number;
    l_accounting_batch_id      NUMBER;
    l_errbuf                   VARCHAR2(10000);
    l_retcode                  NUMBER;
    l_error_counter            number;
    l_error_message               varchar2(2000);
    l_invoice_number              varchar2(100);
    l_entity_code                 varchar2(30);
    l_transactions_count          number;
    l_entity_id                   number;
    l_source_id_int_1             number;
    l_upgrade_status              varchar2(1);
    l_trx_number                  varchar2(100);
    l_transaction_number          VARCHAR2(240);
    l_gl_date                     date;
    l_found_match                 boolean;
    l_event_id                    number;

    l_loan_id                   number;
    l_distribution_id           number;
    l_line_type                 varchar2(30);
    l_account_name              varchar2(30);
    l_account_type              varchar2(30);
    l_distribution_percent      number;
    l_distribution_amount       number;
    l_distribution_type         varchar2(30);

/*------------------------------------------------------------------------+
 | Cursor Declarations                                                    |
 +-----------------------------------------------------------------------*/

    -- cursor to get documents and check upgrade status
    cursor c_get_line_documents(p_loan_line_id number) is
    select lines.reference_id, trx.trx_number
      from lns_loan_lines lines
          ,ra_customer_trx trx
     where lines.reference_type = 'RECEIVABLE'
       and lines.end_date is null
       and lines.loan_line_id = p_loan_line_id
       and lines.reference_id = trx.customer_trx_id;

    cursor c_entities(p_loan_line_id number) is
        select entity_id, entity_code, source_id_int_1, transaction_number
            from xla_transaction_entities
        where application_id = 222
            and entity_code IN ('TRANSACTIONS', 'ADJUSTMENTS')
            and ((source_id_int_1 in (select reference_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_line_id = p_loan_line_id)
            OR   (source_id_int_1 in (select rec_adjustment_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_line_id = p_loan_line_id))));

    -- cursor to get accounting errors
    cursor c_acc_errors (p_loan_line_id number, p_accounting_batch_id number) is
    select xlt.transaction_number, xlt.entity_code, err.encoded_msg
      from xla_accounting_errors err
          ,xla_transaction_entities xlt
     where xlt.application_id = 222
       --and err.accounting_batch_id = nvl(p_accounting_batch_id, null)
       and xlt.entity_id = err.entity_id
       and xlt.entity_id in (select entity_id from xla_transaction_entities
                              where application_id = 222
                                and entity_code IN ('TRANSACTIONS', 'ADJUSTMENTS')
                                and ((source_id_int_1 in (select reference_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_line_id = p_loan_line_id))
                                  OR (source_id_int_1 in (select rec_adjustment_id from lns_loan_lines where end_date is null and reference_type = 'RECEIVABLE' and loan_line_id = p_loan_line_id))));

    -- cursor to establish the loan clearing accounts
    cursor C_ERS_LOAN_CLEARING(p_loan_line_id number) is
        select sum(ael.entered_dr)
               ,ael.code_combination_id
        from ar_adjustments_all adj
            ,xla_transaction_entities ent
            ,xla_ae_headers aeh
            ,xla_ae_lines ael
        where ent.application_id = 222
            and adj.adjustment_id = ent.source_id_int_1
            and ent.entity_code = 'ADJUSTMENTS'
            and ent.entity_id = aeh.entity_id
            and ent.ledger_id = aeh.ledger_id
            and aeh.ae_header_id = ael.ae_header_id
            and aeh.accounting_entry_status_code = 'F'
            and ael.accounting_class_code in
            (select xaa.accounting_class_code
                from XLA_ACCT_CLASS_ASSGNS xaa
                    ,XLA_ASSIGNMENT_DEFNS_B xad
                    ,XLA_POST_ACCT_PROGS_B xpa
            where xaa.program_code = 'LNS_ADJUSTMENT_DEBIT'     -- Bug#8231149
                and xpa.program_code = xaa.program_code
                and xaa.program_code = xad.program_code
                and xad.assignment_code = xaa.assignment_code
                and xad.enabled_flag = 'Y')
                and adj.adjustment_id in
                (select rec_adjustment_id
                 from lns_loan_lines
                 where reference_type = 'RECEIVABLE'
                 and end_date is null
                 and loan_line_id = p_loan_line_id)
            group by ael.code_combination_id;

    cursor C_ERS_LOAN_RECEIVABLE(p_loan_line_id number) is
        select sum(ael.entered_dr)
                ,ael.code_combination_id
        from ra_customer_trx_all inv
            ,xla_transaction_entities ent
            ,xla_ae_headers aeh
            ,xla_ae_lines ael
        where ent.application_id = 222
            and inv.customer_trx_id = ent.source_id_int_1
            and ent.entity_code = 'TRANSACTIONS'
            and ent.entity_id = aeh.entity_id
            and ent.ledger_id = aeh.ledger_id
            and aeh.ae_header_id = ael.ae_header_id
            and aeh.accounting_entry_status_code = 'F'
            and ael.accounting_class_code IN
            (select xaa.accounting_class_code
            from XLA_ACCT_CLASS_ASSGNS xaa
                ,XLA_ASSIGNMENT_DEFNS_B xad
                ,XLA_POST_ACCT_PROGS_B xpa
            where xaa.program_code = 'GET_RECEIVABLE_CCID'
                and xpa.program_code = xaa.program_code
                and xaa.program_code = xad.program_code
                and xad.assignment_code = xaa.assignment_code
                and xad.enabled_flag = 'Y')
                and inv.customer_trx_id in
				 (select reference_id
		          from lns_loan_lines
				  where reference_type = 'RECEIVABLE'
     		      and end_date is null
		          and loan_line_id = p_loan_line_id)
			group by ael.code_combination_id;

    cursor c_get_funded_amount(p_loan_id number, p_code_combination_id number, p_adj_date date) is
        select nvl(sum(dist.distribution_amount), 0)
        from lns_distributions dist,
            lns_loan_lines lines
        where dist.distribution_type = 'ORIGINATION'
            and dist.line_type = 'ORIG'
            and dist.account_name = 'LOAN_RECEIVABLE'
            and dist.account_type = 'DR'
            and dist.loan_id = p_loan_id
            and dist.code_combination_id = p_code_combination_id
            and dist.LOAN_LINE_ID = lines.LOAN_LINE_ID(+)
            and lines.loan_id(+) = dist.loan_id
            and trunc(lines.ADJUSTMENT_DATE(+)) <= trunc(p_adj_date)
            and lines.status(+) = 'APPROVED';

    cursor c_get_billed_amount(p_loan_id number, p_code_combination_id number, p_adj_date date) is
        select nvl(sum(dist.amount), 0)
        from lns_amortization_lines lines,
            lns_amortization_scheds am,
            RA_CUST_TRX_LINE_GL_DIST_ALL dist
        where am.loan_id = p_loan_id
            and (am.REVERSED_FLAG is null or am.REVERSED_FLAG = 'N')
            and am.REAMORTIZATION_AMOUNT is null
            and am.loan_id = lines.loan_id
            and am.amortization_schedule_id = lines.amortization_schedule_id
            and dist.CUSTOMER_TRX_ID = lines.cust_trx_id
            and dist.CUSTOMER_TRX_LINE_ID = lines.cust_trx_line_id
            and dist.code_combination_id = p_code_combination_id
            and trunc(am.due_date) <= trunc(p_adj_date);

    cursor c_adj_date(p_loan_line_id number) is
        select ADJUSTMENT_DATE, adj.gl_date
        from lns_loan_lines lines, ar_adjustments_all adj
        where lines.LOAN_LINE_ID = p_loan_line_id
            and lines.REC_ADJUSTMENT_ID = adj.ADJUSTMENT_ID;

    CURSOR c_get_prin_distr(P_LOAN_ID number, P_ADJ_DATE date) IS
       select dist.distribution_id
             ,dist.loan_id
             ,dist.line_type
             ,dist.account_name
             ,dist.account_type
             ,dist.code_combination_id
             ,dist.distribution_percent
             ,dist.distribution_amount
             ,dist.distribution_type
       from lns_distributions dist
       where dist.loan_id = P_LOAN_ID
         and dist.account_type = 'CR'
         and dist.account_name = 'LOAN_RECEIVABLE'
         and dist.line_type = 'PRIN'
         and dist.distribution_type = 'BILLING'
         and dist.distribution_percent > 0
         and nvl(dist.loan_line_id, -1) =
                nvl((select max(loan_line_id)
                from lns_loan_lines
                where status = 'APPROVED'
                and LOAN_ID = P_LOAN_ID
                and original_flag = 'N'
                and trunc(adjustment_date) < trunc(P_ADJ_DATE)), -1)
        order by dist.distribution_id;

begin

    SAVEPOINT createDistrForAddRec;
    l_api_name   := 'createDistrForAddRec';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input p_loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input p_loan_line_id = ' || p_loan_line_id);

    if P_LOAN_ID is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_ID' );
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    if P_LOAN_LINE_ID is null then

        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_LINE_ID' );
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;

    end if;

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Starting ERS INHERITANCE');

    l_ledger_details := lns_distributions_pub.getLedgerDetails;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'chart_of_accounts_id = ' || l_ledger_details.chart_of_accounts_id);

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Fetching documents to account...');
    open c_get_line_documents(p_loan_line_id);
    loop
        fetch c_get_line_documents into l_source_id_int_1, l_trx_number;
        exit when c_get_line_documents%notfound;

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_source_id_int_1 = ' || l_source_id_int_1);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_trx_number = ' || l_trx_number);

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling arp_acct_event_pkg.upgrade_status_per_doc...');
        -- check for upgrade status bug#4872154
        arp_acct_event_pkg.upgrade_status_per_doc(p_init_msg_list     => p_init_msg_list
                                                ,p_entity_code       => l_entity_code
                                                ,p_source_int_id     => l_source_id_int_1
                                                ,x_upgrade_status    => l_upgrade_status
                                                ,x_return_status     => l_return_status
                                                ,x_msg_count         => l_msg_count
                                                ,x_msg_data          => l_msg_data);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_return_status = ' || l_return_status);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_upgrade_status = ' || l_upgrade_status);

        if l_return_status <> 'S' then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CHK_UPG_FAIL');
            FND_MESSAGE.SET_TOKEN('DOC_NUM', l_trx_number);
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        else
            if l_upgrade_status <> 'Y' then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_INVALID_TRX');
                FND_MESSAGE.SET_TOKEN('DOC_NUM', l_trx_number);
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
            end if;
        end if;

    end loop;
    close c_get_line_documents;

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Fetching entities xla_transaction_entities...');
    l_transactions_count := 0;
    open c_entities(p_loan_line_id);
    loop
        fetch c_entities into l_entity_id, l_entity_code, l_source_id_int_1, l_transaction_number;
        exit when c_entities%notfound;

        l_transactions_count := l_transactions_count + 1;
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Entity ' || l_transactions_count);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_entity_id = ' || l_entity_id);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_entity_code = ' || l_entity_code);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_source_id_int_1 = ' || l_source_id_int_1);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_transaction_number = ' || l_transaction_number);

        insert into XLA_ACCT_PROG_DOCS_GT (entity_id) VALUES (l_entity_id);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Inserted into XLA_ACCT_PROG_DOCS_GT');

    end loop;
    close  c_entities ;

    select count(1) into l_transactions_count
    from XLA_ACCT_PROG_DOCS_GT;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Inserted transaction_entities  = ' || l_transactions_count);

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling XLA_ACCOUNTING_PUB_PKG.accounting_program_doc_batch...');
    XLA_ACCOUNTING_PUB_PKG.accounting_program_doc_batch(p_application_id      => 222
                                                        ,p_accounting_mode     => 'F'
                                                        ,p_gl_posting_flag     => 'N'
                                                        ,p_accounting_batch_id => l_accounting_batch_id
                                                        ,p_errbuf              => l_errbuf
                                                        ,p_retcode             => l_retcode);
    logMessage(FND_LOG.level_statement, G_PKG_NAME, ' l_retcode = ' || l_retcode);
    logMessage(FND_LOG.level_statement, G_PKG_NAME, ' l_accounting_batch_id = ' || l_accounting_batch_id);

    if l_retcode <> 0 then

        logMessage(FND_LOG.level_unexpected, G_PKG_NAME, 'Online accounting failed with error: ' || l_errbuf);

        /* query XLA_ACCOUNTING_ERRORS */
        l_error_counter := 0;
        open c_acc_errors(p_loan_line_id, l_accounting_batch_id);

        LOOP

            fetch c_acc_errors into
                l_invoice_number,
                l_entity_code,
                l_error_message;
            exit when c_acc_errors%NOTFOUND;

            l_error_counter := l_error_counter + 1;

            if l_error_counter = 1 then
                FND_MESSAGE.SET_NAME('LNS', 'LNS_ONLINE_ACCOUNTING_FAILED');
                FND_MSG_PUB.Add;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            end if;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_ACC_DOC_FAIL');
            FND_MESSAGE.SET_TOKEN('DOC_NUM', l_invoice_number);
            FND_MESSAGE.SET_TOKEN('DOC_TYPE', l_entity_code);
            FND_MESSAGE.SET_TOKEN('ACC_ERR', l_error_message);
            FND_MSG_PUB.Add;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));

        END LOOP;

        close c_acc_errors;

        RAISE FND_API.G_EXC_ERROR;
    else
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Online accounting SUCCESS! ');
    end if;

    -- get the swap segment value
    l_natural_account_rec := getNaturalSwapAccount(p_loan_id);
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Swap natural account with ' || l_natural_account_rec);

    -- Get natural account segment number
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling FND_FLEX_APIS.GET_QUALIFIER_SEGNUM...');
    IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(appl_id         => 101
                                                ,key_flex_code   => 'GL#'
                                                ,structure_number=> l_ledger_details.chart_of_accounts_id
                                                ,flex_qual_name  => 'GL_ACCOUNT'
                                                ,segment_number  => l_nat_acct_seg_number))
    THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NO_NATURAL_ACCOUNT_SEGMENT');
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Natural acct segment = ' || l_nat_acct_seg_number);

    -- here we establish the loan clearing first
    -- if adjustment activity is found in XLA then we take amounts, cc_ids from XLA tables for both CLEARING and RECEIVABLES
    Begin
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Opening cursor C_ERS_LOAN_CLEARING...');
        i := 0;
        open C_ERS_LOAN_CLEARING(p_loan_line_id);
        Loop
            -- reintialize these
            l_code_combination_id     := null;
            l_ers_distribution_amount := 0;

            fetch C_ERS_LOAN_CLEARING into l_ers_distribution_amount, l_code_combination_id;
            EXIT WHEN C_ERS_LOAN_CLEARING%NOTFOUND;

            l_adjustment_exists := true;
            i := i + 1;

            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Loan Clearing Record ' || i);
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_ers_distribution_amount = ' || l_ers_distribution_amount);
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);

            l_distributionsCLEAR_ORIG(i).line_type            := 'CLEAR';
            l_distributionsCLEAR_ORIG(i).account_name         := 'LOAN_CLEARING';
            l_distributionsCLEAR_ORIG(i).code_combination_id  := l_code_combination_id;
            l_distributionsCLEAR_ORIG(i).account_type         := 'CR';
            l_distributionsCLEAR_ORIG(i).distribution_amount  := l_ers_distribution_amount;
            l_distributionsCLEAR_ORIG(i).distribution_percent := 100;
            l_distributionsCLEAR_ORIG(i).distribution_type    := 'ORIGINATION';
            l_distributionsCLEAR_ORIG(i).loan_line_id         := p_loan_line_id;

        end loop; -- loan clearing loop
    exception
        when others then
            --logMessage(FND_LOG.LEVEL_UNEX, G_PKG_NAME, 'Failed to inherit receivables distributions');
            FND_MESSAGE.SET_NAME('LNS', 'LNS_INHERIT_DIST_NOT_FOUND');
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
    end;

    -- if the adjustment exists in PSA table it means loan is approved and adjustment was created for receivables
    i := 0;
    if l_adjustment_exists then

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'ACCOUNTED ADJUSTMENT EXISTS');

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Getting adjustment date...');
        open c_adj_date(p_loan_line_id);
        fetch c_adj_date into l_adj_date, l_gl_date;
        close c_adj_date;
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_adj_date = ' || l_adj_date);

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Fetching existent LOAN_RECEIVABLE PRIN BILLING records...');
        y := 0;
        l_sum := 0;
        OPEN c_get_prin_distr(p_loan_id, l_adj_date);
        LOOP

            FETCH c_get_prin_distr into
                l_distribution_id
                ,l_loan_id
                ,l_line_type
                ,l_account_name
                ,l_account_type
                ,l_code_combination_id
                ,l_distribution_percent
                ,l_distribution_amount
                ,l_distribution_type;
            EXIT WHEN c_get_prin_distr%NOTFOUND;

            y := y + 1;
            l_distributionsREC_BILL(y).distribution_id        := l_distribution_id;
            l_distributionsREC_BILL(y).loan_id                := l_loan_id;
            l_distributionsREC_BILL(y).line_type              := l_line_type;
            l_distributionsREC_BILL(y).account_name           := l_account_name;
            l_distributionsREC_BILL(y).account_type           := l_account_type;
            l_distributionsREC_BILL(y).code_combination_id    := l_code_combination_id;
            l_distributionsREC_BILL(y).distribution_percent   := l_distribution_percent;
            l_distributionsREC_BILL(y).distribution_amount    := l_distribution_amount;
            l_distributionsREC_BILL(y).distribution_type      := l_distribution_type;

            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Record ' || y);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_id = ' || l_distribution_id);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_id = ' || l_loan_id);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_line_type = ' || l_line_type);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_name = ' || l_account_name);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_account_type = ' || l_account_type);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_percent = ' || l_distribution_percent);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_amount = ' || l_distribution_amount);
            logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_distribution_type = ' || l_distribution_type);

            l_distributionsREC_BILL(y).DISTRIBUTION_PERCENT := null;
            l_distributionsREC_BILL(y).loan_line_id := p_loan_line_id;

            open c_get_funded_amount(p_loan_id, l_distributionsREC_BILL(y).CODE_COMBINATION_ID, l_adj_date);
            fetch c_get_funded_amount into l_funded_amount;
            close c_get_funded_amount;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_funded_amount = ' || l_funded_amount);

            open c_get_billed_amount(p_loan_id, l_distributionsREC_BILL(y).CODE_COMBINATION_ID, l_adj_date);
            fetch c_get_billed_amount into l_billed_amount;
            close c_get_billed_amount;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_billed_amount = ' || l_billed_amount);

            l_distributionsREC_BILL(y).DISTRIBUTION_AMOUNT := l_funded_amount - l_billed_amount;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'DISTRIBUTION_AMOUNT = ' || l_distributionsREC_BILL(y).DISTRIBUTION_AMOUNT);

            l_sum := l_sum + l_distributionsREC_BILL(y).DISTRIBUTION_AMOUNT;
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_sum = ' || l_sum);

        END LOOP;
        CLOSE c_get_prin_distr;

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Fetched ' || l_distributionsREC_BILL.count || ' records');

        Begin
            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Opening cursor C_ERS_LOAN_RECEIVABLE...');
            open C_ERS_LOAN_RECEIVABLE(p_loan_line_id);
            Loop
                -- reintialize these
                l_code_combination_id         := null;
                l_code_combination_id_new_rec := null;
                l_ers_distribution_amount     := 0;

                fetch C_ERS_LOAN_RECEIVABLE into l_ers_distribution_amount, l_code_combination_id;
                EXIT WHEN C_ERS_LOAN_RECEIVABLE%NOTFOUND;

                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Record:');
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_ers_distribution_amount = ' || l_ers_distribution_amount);
                logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_code_combination_id = ' || l_code_combination_id);

                -- here we need to rebuild the code_Combination_id as per swapping rules
                -- replace the natual account segement with the natural account segment found in the set-up/configuration
                if l_ers_distribution_amount > 0 then
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling swap_code_combination...');
                    l_code_combination_id_new_rec :=
                            swap_code_combination(p_chart_of_accounts_id => l_ledger_details.chart_of_accounts_id
                                                ,p_original_cc_id       => l_code_combination_id
                                                ,p_swap_segment_number  => l_nat_acct_seg_number
                                                ,p_swap_segment_value   => l_natural_account_rec);

                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_code_combination_id_new_rec = ' || l_code_combination_id_new_Rec);

                    -- adding LOAN_RECEIVABLE ORIGINATION record
                    i := i + 1;

                    l_ers_distribution_amount := l_distributionsCLEAR_ORIG(i).distribution_amount;
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'NEW l_ers_distribution_amount = ' || l_ers_distribution_amount);

                    l_distributionsREC_ORIG(i).line_type           := 'ORIG';
                    l_distributionsREC_ORIG(i).account_name        := 'LOAN_RECEIVABLE';
                    l_distributionsREC_ORIG(i).code_combination_id := l_code_combination_id_new_rec;
                    l_distributionsREC_ORIG(i).account_type        := 'DR';
                    l_distributionsREC_ORIG(i).distribution_amount := l_ers_distribution_amount;
                    l_distributionsREC_ORIG(i).distribution_percent := 100;
                    l_distributionsREC_ORIG(i).distribution_type   := 'ORIGINATION';
                    l_distributionsREC_ORIG(i).loan_line_id        := p_loan_line_id;

                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Added LOAN_RECEIVABLE FOR ORIGINATION ' || l_code_combination_id_new_rec);
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_ORIG.count = ' || l_distributionsREC_ORIG.count);

                    -- searching ccid amoung existent l_distributionsREC_BILL records
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Searching for ccid match...');
                    l_found_match := false;
                    for k in 1..y loop
                        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Record #' || k);
                        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'CODE_COMBINATION_ID = ' || l_distributionsREC_BILL(k).CODE_COMBINATION_ID);

                        if l_distributionsREC_BILL(k).CODE_COMBINATION_ID = l_code_combination_id_new_rec then
                            logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Found ccid match!!!');
                            l_distributionsREC_BILL(k).distribution_amount := l_distributionsREC_BILL(k).distribution_amount + l_ers_distribution_amount;
                            l_found_match := true;
                            exit;
                        end if;
                    end loop;

                    if l_found_match = false then
                        y := y + 1;
                        l_distributionsREC_BILL(y).line_type           := 'PRIN';
                        l_distributionsREC_BILL(y).account_name        := 'LOAN_RECEIVABLE';
                        l_distributionsREC_BILL(y).code_combination_id := l_code_combination_id_new_rec;
                        l_distributionsREC_BILL(y).account_type        := 'CR';
                        l_distributionsREC_BILL(y).distribution_amount := l_ers_distribution_amount;
                        l_distributionsREC_BILL(y).distribution_type   := 'BILLING';
                        l_distributionsREC_BILL(y).loan_line_id        := p_loan_line_id;

                        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Added LOAN_RECEIVABLE FOR BILLING ' || l_code_combination_id_new_rec);
                        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_BILL.count = ' || l_distributionsREC_BILL.count);
                    end if;

                    l_sum := l_sum + l_ers_distribution_amount;
                    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_sum = ' || l_sum);
                end if;

            end loop;

            close C_ERS_LOAN_RECEIVABLE;

        exception
            when others then
--                        logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'failed to inherit receivables distributions');
                FND_MESSAGE.SET_NAME('LNS', 'LNS_INHERIT_DIST_NOT_FOUND');
                FND_MSG_PUB.ADD;
                LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
                RAISE FND_API.G_EXC_ERROR;
        end;

    else
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'NO ACCOUNTED ADJUSTMENT EXISTS');
    end if;

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsCLEAR_ORIG.count = ' || l_distributionsCLEAR_ORIG.count);
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_ORIG.count = ' || l_distributionsREC_ORIG.count);
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsREC_BILL.count = ' || l_distributionsREC_BILL.count);

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'CALCULATING %AGES FOR PRIN BILLING LOAN_RECEIVABLE...');
    l_running_percent := 0;
    for k in 1..l_distributionsREC_BILL.count loop

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Iteration ' || k);
        l_percent := 0;

        if k <> l_distributionsREC_BILL.count then
            l_percent := round(l_distributionsREC_BILL(k).distribution_amount / l_sum * 100,4);
            l_distributionsREC_BILL(k).distribution_percent := l_percent;
        else
            -- last row ensure that amounts = 100% and total = funded amount of loan
            l_percent := 100 - l_running_percent;
            l_distributionsREC_BILL(k).distribution_percent := l_percent;
        end if;
        l_distributionsREC_BILL(k).distribution_amount  := null;
        l_running_percent := l_running_percent + l_percent;

        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'distribution_percent = ' || l_distributionsREC_BILL(k).distribution_percent);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'distribution_amount = ' || l_distributionsREC_BILL(k).distribution_amount);
        logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_running_percent = ' || l_running_percent);

    end loop;

    n := 0;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsREC_ORIG to l_distributionsALL...');
    for j in 1..l_distributionsREC_ORIG.count loop
        n := n + 1;
        l_distributionsALL(n)     := l_distributionsREC_ORIG(j);
    end loop;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsCLEAR_ORIG to l_distributionsALL...');
    for j in 1..l_distributionsCLEAR_ORIG.count loop
        n := n + 1;
        l_distributionsALL(n)     := l_distributionsCLEAR_ORIG(j);
    end loop;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Copying l_distributionsREC_BILL to l_distributionsALL...');
    for j in 1..l_distributionsREC_BILL.count loop
        n := n + 1;
        l_distributionsALL(n)     := l_distributionsREC_BILL(j);
    end loop;
    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'l_distributionsALL.count = ' || l_distributionsALL.count);

    logMessage(FND_LOG.level_statement, G_PKG_NAME, 'Calling do_insert_distributions...');
    do_insert_distributions(p_distributions_tbl => l_distributionsALL
                            ,p_loan_id           => p_loan_id);

    -- validate the accounting rows here
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' validating Accounting');
    lns_distributions_pub.validateAddRecAccounting(p_loan_id          => p_loan_id
                                                ,p_loan_line_id    => p_loan_line_id
                                                ,p_init_msg_list    => p_init_msg_list
                                                ,x_return_status    => l_return_status
                                                ,x_msg_count        => l_msg_count
                                                ,x_msg_data         => l_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || 'Accounting status is ' || l_return_status);
    if l_return_status <> 'S' then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_gl_date = ' || l_gl_date);

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling LNS_XLA_EVENTS.create_event...');
    LNS_XLA_EVENTS.create_event(p_loan_id         =>  p_loan_id
                                ,p_disb_header_id  => -1
                                ,p_loan_amount_adj_id => -1
				,p_loan_line_id		  => p_loan_line_id
                                ,p_event_type_code => 'ERS_LOAN_ADD_REC_APPROVED'
                                ,p_event_date      => l_gl_date
                                ,p_event_status    => 'U'
                                ,p_init_msg_list   => fnd_api.g_false
                                ,p_commit          => fnd_api.g_false
                                ,p_bc_flag         => 'N'
                                ,x_event_id        => l_event_id
                                ,x_return_status   => l_return_status
                                ,x_msg_count       => l_msg_count
                                ,x_msg_data        => l_msg_data);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_event_id = ' || l_event_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_return_status = ' || l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ACCOUNTING_EVENT_ERROR');
        FND_MSG_PUB.ADD;
        --l_last_api_called := 'LNS_XLA_EVENTS.create_event';
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    if l_event_id is not null then
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Updating lns_distributions...');
        update lns_distributions
            set event_id = l_event_id
        where loan_id = P_LOAN_ID
            and loan_line_id = p_loan_line_id
            and account_name in ('LOAN_RECEIVABLE', 'LOAN_CLEARING')
            and distribution_type = 'ORIGINATION';
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Done');
    end if;

    IF FND_API.to_Boolean(p_commit)
    THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - END');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ADD_REC_ACC_FAIL');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        ROLLBACK TO createDistrForAddRec;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ADD_REC_ACC_FAIL');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        ROLLBACK TO createDistrForAddRec;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
        FND_MESSAGE.SET_NAME('LNS', 'LNS_ADD_REC_ACC_FAIL');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
        ROLLBACK TO createDistrForAddRec;

end createDistrForAddRec;



END LNS_DISTRIBUTIONS_PUB;

/
