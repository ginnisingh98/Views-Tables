--------------------------------------------------------
--  DDL for Package Body LNS_XLA_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_XLA_EVENTS" AS
/* $Header: LNS_XLA_EVENTS_B.pls 120.8.12010000.5 2010/04/28 14:30:17 mbolli ship $ */

 --------------------------------------------
 -- declaration of global variables and types
 --------------------------------------------
 G_DEBUG_COUNT                       NUMBER := 0;
 G_DEBUG                             BOOLEAN := FALSE;
 G_FILE_NAME   CONSTANT VARCHAR2(30) := 'LNS_XLA_EVENTS_B.pls';

 G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'LNS_XLA_EVENTS';
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
        if FND_GLOBAL.Conc_Request_Id is not null then
            fnd_file.put_line(FND_FILE.LOG, message);
        end if;
    END IF;

end;



/*=========================================================================
|| PUBLIC PROCEDURE create_event
||
|| DESCRIPTION
|| Overview: will write to xla_events table
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
||           ,p_disb_header_id      => for disbursement
||           ,p_loan_amount_adj_id => for loan Amount Adjustments of direct loans
||           ,p_loan_line			=> for additional receivable of ERS loans
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
|| 4/11/2005             raverma           Created
|| 15-Mar-2010           mbolli            MultiDisbursement - added loanAmountAdjustmentId as param
|| 13-Apr-2010           mboli            Added new param p_loan_line_id
 *=======================================================================*/
procedure create_event(p_loan_id            in  number
                      ,p_disb_header_id     in  number
                      ,p_loan_amount_adj_id  in  number default NULL
		      ,p_loan_line_id		  in  number default NULL
                      ,p_event_type_code    in  varchar
                      ,p_event_date         in  date
                      ,p_event_status       in  varchar2
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,p_bc_flag            in  varchar2
                      ,x_event_id           out nocopy number
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2)
is

    l_api_name         varchar2(15);
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(32767);

    l_event_id         integer;
    l_loan_details     XLA_EVENTS_PUB_PKG.t_event_source_info;
    l_security_context XLA_EVENTS_PUB_PKG.t_security;
    l_legal_entity_id  number;
    l_sob_id           number;
    l_loan_number      varchar2(60);
    l_disb_header_id   number;
    l_loan_amount_adj_id number;
    l_loan_line_id	     number;
    l_event_exists     boolean;
    l_event_info       xla_events_pub_pkg.t_event_info;

    CURSOR C_Get_Loan_Info (X_Loan_Id NUMBER) IS
    SELECT LEGAL_ENTITY_ID
            ,LOAN_NUMBER
        FROM LNS_LOAN_HEADERS_ALL
    WHERE LOAN_ID = X_Loan_Id;

    cursor c_sob_id is
    select so.ledger_id
        from lns_system_options sb,
            gl_ledgers so
    where sb.set_of_books_id = so.ledger_id;

    CURSOR C_Get_Event (p_application_id NUMBER,
                        p_ledger_id NUMBER,
                        p_entity_type_code VARCHAR2,
                        p_source_id_int_1 NUMBER,
                        p_source_id_int_2 NUMBER,
                        p_source_id_int_3 NUMBER,
			p_source_id_int_4 NUMBER,
                        p_valuation_method VARCHAR2) IS
    SELECT xe.event_id
    FROM  xla_transaction_entities   xte
          ,xla_events     xe
          ,xla_entity_types_b xet
    WHERE xte.application_id                    = p_application_id
        AND xte.ledger_id                       = p_ledger_id
        AND xte.entity_code                     = p_entity_type_code
        AND NVL(xte.source_id_int_1,-99)        = NVL(p_source_id_int_1,-99)
        AND NVL(xte.source_id_int_2,-99)        = NVL(p_source_id_int_2,-99)
        AND NVL(xte.source_id_int_3,-99)        = NVL(p_source_id_int_3,-99)
	AND NVL(xte.source_id_int_4,-99)        = NVL(p_source_id_int_4,-99)
        AND NVL(xte.valuation_method,' ')        = NVL(p_valuation_method,' ')
        AND xe.entity_id                        = xte.entity_id
        AND xet.application_id                  = xte.application_id
        AND xte.entity_code                     = xet.entity_code;

begin

    l_api_name           := 'create_event';
    logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_id = ' || p_loan_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_header_id = ' || p_disb_header_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = ' || p_loan_amount_adj_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_line_id = ' || p_loan_line_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_type_code = ' || p_event_type_code);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_date = ' || p_event_date);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_status = ' || p_event_status);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_bc_flag = ' || p_bc_flag);

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

    open C_Get_Loan_Info(p_loan_id);
    fetch C_Get_Loan_Info into l_legal_entity_id, l_loan_number;
    close C_Get_Loan_Info;

    open c_sob_id;
    fetch c_sob_id into l_sob_id;
    close c_sob_id;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_number = ' || l_loan_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_legal_entity_id = ' || l_legal_entity_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_sob_id = ' || l_sob_id);

    -- force caller to pass disbursement_id/loan_amount_adj_id/loan_line_id
    if (p_disb_header_id is null and p_loan_amount_adj_id is null and p_loan_line_id is null)then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed API call: ' || l_api_name || ' SQLERRM: ' || SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- initialize any variables here
    l_loan_details.application_id          := 206;   -- XLA registered application
    l_loan_details.ledger_id               := l_sob_id;  -- l_sob_id;
    l_loan_details.legal_entity_id         := l_legal_entity_id;
    l_loan_details.source_id_int_1         := p_loan_id; -- loan_id
    l_loan_details.entity_type_code        := 'LOANS';
    l_loan_details.transaction_number      := l_loan_number;
    l_loan_details.source_id_int_2         := p_disb_header_id; -- disb_header_id
    l_loan_details.source_id_int_3         := NVL(p_loan_amount_adj_id, -1); -- loan_amount_adj_id
    l_loan_details.source_id_int_4         := NVL(p_loan_line_id, -1); 		-- loan_line_id
    l_loan_details.source_application_id   := 206;   -- XLA registered application

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_1 = ' || l_loan_details.source_id_int_1);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_2 = ' || l_loan_details.source_id_int_2);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_3 = ' || l_loan_details.source_id_int_3);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_4 = ' || l_loan_details.source_id_int_4);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.transaction_number = ' || l_loan_details.transaction_number);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_application_id = ' || l_loan_details.source_application_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.entity_type_code = ' || l_loan_details.entity_type_code);

/*
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Checking if event already exists...');
    l_event_exists :=  xla_events_pub_pkg.event_exists (p_event_source_info => l_loan_details
                                                        ,p_event_type_code   => p_event_type_code
                                                        ,p_valuation_method  => null
                                                        ,p_security_context  => l_security_context);
    if not l_event_exists then
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Event doesnt exist');
*/

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling XLA_EVENTS_PUB_PKG.create_event...');
        x_event_id := XLA_EVENTS_PUB_PKG.create_event(p_event_source_info      => l_loan_details
	                                                ,p_event_type_code        => p_event_type_code  -- event type code
	                                                ,p_event_date             => p_event_date       -- gl date
	                                                ,p_event_status_code      => p_event_status     -- event status
	                                                ,p_event_number           => NULL
	                                                ,p_reference_info         => null
	                                                ,p_valuation_method       => null
	                                                ,p_security_context       => l_security_context
                                                   ,p_budgetary_control_flag => p_bc_flag);
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_event_id = ' || x_event_id);
        if x_event_id is null then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed to create Loans XLA event ' || p_event_type_code);
            FND_MSG_PUB.ADD;
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Successfully created Loans XLA event ' || p_event_type_code);

/*
    else
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Event already exists');

        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Querying event_id...');
        OPEN C_Get_Event (p_application_id => l_loan_details.application_id,
                            p_ledger_id => l_sob_id,
                            p_entity_type_code => l_loan_details.entity_type_code,
                            p_source_id_int_1 => l_loan_details.source_id_int_1,
                            p_source_id_int_2 => l_loan_details.source_id_int_2,
                            p_source_id_int_3 => l_loan_details.source_id_int_3,
			    p_source_id_int_4 => l_loan_details.source_id_int_4,
                            p_valuation_method => null);
        fetch C_Get_Event into x_event_id;
        CLOSE C_Get_Event;
        logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'x_event_id = ' || x_event_id);

        if x_event_id is null then
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
            FND_MESSAGE.SET_TOKEN('ERROR' ,'Failed to find Loans XLA event ' || p_event_type_code);
            FND_MSG_PUB.ADD;
            logMessage(FND_LOG.LEVEL_UNEXPECTED, G_PKG_NAME, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;
*/

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
            ROLLBACK TO create_event;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
            ROLLBACK TO create_event;

    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
            ROLLBACK TO create_event;

end create_event;

/*=========================================================================
|| PUBLIC PROCEDURE update_event
||
|| DESCRIPTION
|| Overview: will write to xla_events table
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_loan_id => loan_id
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
|| 4/11/2005             raverma           Created
||
 *=======================================================================*/
procedure update_event(p_loan_id            in  number
                      ,p_disb_header_id     in  number
                      ,p_loan_amount_adj_id in  number default NULL
		      ,p_loan_line_id		  in  number default NULL
                      ,p_event_id           in  number
                      ,p_event_type_code    in  varchar
                      ,p_event_date         in  date
                      ,p_event_status       in  varchar2
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2)
is
  l_api_name         varchar2(15);
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(32767);

  --l_event_id         integer;
  l_loan_details     XLA_EVENTS_PUB_PKG.t_event_source_info;
  l_security_context XLA_EVENTS_PUB_PKG.t_security;
  l_legal_entity_id  number;
  l_sob_id           number;

  CURSOR C_Get_Loan_Info (X_Loan_Id NUMBER) IS
  SELECT LEGAL_ENTITY_ID
    FROM LNS_LOAN_HEADERS
   WHERE LOAN_ID = X_Loan_Id;

  cursor c_sob_id is
  select so.set_of_books_id
    from lns_system_options sb,
         gl_sets_of_books so
   where sb.set_of_books_id = so.set_of_books_id;

begin
   l_api_name           := 'update_event';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Input:');
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'event_id ' || p_event_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_id = ' || p_loan_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_header_id = ' || p_disb_header_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = ' || p_loan_amount_adj_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_line_id = ' || p_loan_line_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_type_code ' || p_event_type_code);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_date ' || p_event_date);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_event_status ' || p_event_status);

   -- Standard Start of API savepoint
   SAVEPOINT update_event;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------
   open C_Get_Loan_Info(p_loan_id);
   fetch C_Get_Loan_Info into l_legal_entity_id;
   close C_Get_Loan_Info;

   open c_sob_id;
   fetch c_sob_id into l_sob_id;
   close c_sob_id;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_legal_entity_id = ' || l_legal_entity_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_sob_id = ' || l_sob_id);

   -- initialize any variables here
   l_loan_details.application_id   := 206;   -- XLA registered application
   l_loan_details.legal_entity_id  := l_legal_entity_id;     --
   l_loan_details.ledger_id        := l_sob_id;     --
   l_loan_details.source_id_int_1  := p_loan_id; -- loan_id
   l_loan_details.entity_type_code := 'LOANS';
   l_loan_details.source_id_int_2  := p_disb_header_id;     -- disb_header_id
   l_loan_details.source_id_int_3  := p_loan_amount_adj_id; -- loan_amount_adj_id
   l_loan_details.source_id_int_4  := p_loan_line_id; 		-- loan_line_id

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_1 = ' || l_loan_details.source_id_int_1);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_2 = ' || l_loan_details.source_id_int_2);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_3 = ' || l_loan_details.source_id_int_3);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_4 = ' || l_loan_details.source_id_int_4);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.entity_type_code = ' || l_loan_details.entity_type_code);

   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling XLA_EVENTS_PUB_PKG.Update_event...');
   XLA_EVENTS_PUB_PKG.Update_event(p_event_source_info   => l_loan_details
                                  ,p_event_id            => p_event_id
                                  ,p_event_type_code     => p_event_type_code
                                  ,p_event_date          => p_event_date
                                  ,p_event_status_code   => p_event_status
                                  ,p_valuation_method    => null
                                  ,p_security_context    => l_security_context);

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
             ROLLBACK TO update_event;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO update_event;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO update_event;

end update_event;

/*=========================================================================
|| PUBLIC PROCEDURE delete_event
||
|| DESCRIPTION
|| Overview: will delete events from xla_events table
||
|| PSEUDO CODE/LOGIC
||
|| PARAMETERS
|| Parameter: p_event_id => event_id
||
|| Return value:
||               standard
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 4/11/2005             raverma           Created
||
 *=======================================================================*/
procedure delete_event(p_loan_id            in  number
		      ,p_disb_header_id     in  number
                      ,p_loan_amount_adj_id in  number default NULL
		      ,p_loan_line_id		  in  number default NULL
                      ,p_event_id           in  number
                      ,p_init_msg_list      in  varchar2
                      ,p_commit             in  varchar2
                      ,x_return_status      out nocopy varchar2
                      ,x_msg_count          out nocopy number
                      ,x_msg_data           out nocopy varchar2)
is
  l_api_name         varchar2(15);
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(32767);

  CURSOR C_Get_Loan_Info (X_Loan_Id NUMBER) IS
  SELECT LEGAL_ENTITY_ID
    FROM LNS_LOAN_HEADERS
   WHERE LOAN_ID = X_Loan_Id;

  cursor c_sob_id is
  select so.set_of_books_id
    from lns_system_options sb,
         gl_sets_of_books so
   where sb.set_of_books_id = so.set_of_books_id;

  l_loan_details     XLA_EVENTS_PUB_PKG.t_event_source_info;
  l_security_context XLA_EVENTS_PUB_PKG.t_security;
  l_legal_entity_id  number;
  l_sob_id           number;

begin
   l_api_name           := 'delete_event';
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - BEGIN');
   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - event_id ' || p_event_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'loan_id = ' || p_loan_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_disb_header_id = ' || p_disb_header_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_amount_adj_id = ' || p_loan_amount_adj_id);
   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'p_loan_line_id = ' || p_loan_line_id);


   -- Standard Start of API savepoint
   SAVEPOINT delete_event;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ---------------------------------------------------------------------
   -- Api body
   -- ---------------------------------------------------------------------

   open C_Get_Loan_Info(p_loan_id);
   fetch C_Get_Loan_Info into l_legal_entity_id;
   close C_Get_Loan_Info;

   open c_sob_id;
   fetch c_sob_id into l_sob_id;
   close c_sob_id;

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_legal_entity_id = ' || l_legal_entity_id);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_sob_id = ' || l_sob_id);

   -- initialize any variables here
   l_loan_details.application_id   := 206;                -- XLA registered application
   l_loan_details.legal_entity_id  := l_legal_entity_id;  --
   l_loan_details.ledger_id        := l_sob_id;           --
   l_loan_details.source_id_int_1  := p_loan_id;          -- loan_id
   l_loan_details.entity_type_code := 'LOANS';
   l_loan_details.source_id_int_2  := p_disb_header_id;          -- disb_header_id
   l_loan_details.source_id_int_3  := p_loan_amount_adj_id;      -- loan_amount_adj_id
   l_loan_details.source_id_int_4  := p_loan_line_id;      -- loan_line_id

    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_1 = ' || l_loan_details.source_id_int_1);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_2 = ' || l_loan_details.source_id_int_2);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_3 = ' || l_loan_details.source_id_int_3);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.source_id_int_4 = ' || l_loan_details.source_id_int_4);
    logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'l_loan_details.entity_type_code = ' || l_loan_details.entity_type_code);


   logMessage(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME, 'Calling XLA_EVENTS_PUB_PKG.delete_event...');
   XLA_EVENTS_PUB_PKG.delete_event
   (p_event_source_info            => l_loan_details
   ,p_event_id                     => p_event_id
   ,p_valuation_method             => null
   ,p_security_context             => l_security_context);

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
             ROLLBACK TO delete_event;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO delete_event;

       WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;
             FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
             logMessage(FND_LOG.LEVEL_ERROR, G_PKG_NAME, sqlerrm);
             ROLLBACK TO delete_event;

end delete_event;

end lns_xla_events;

/
