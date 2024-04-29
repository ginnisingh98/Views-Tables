--------------------------------------------------------
--  DDL for Package Body RCV_CREATEACCOUNTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_CREATEACCOUNTING_PVT" AS
/* $Header: RCVVACCB.pls 120.11.12010000.7 2010/10/11 23:32:14 anjha ship $*/
G_PKG_NAME CONSTANT VARCHAR2(30) := 'RCV_CreateAccounting_PVT';
G_GL_APPLICATION_ID CONSTANT NUMBER       := 101;
G_PO_APPLICATION_ID CONSTANT NUMBER       := 201;
G_CST_APPLICATION_ID CONSTANT NUMBER      := 707;

G_DEBUG CONSTANT VARCHAR2(1)     := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'po.plsql.'||G_PKG_NAME;

-- Accounting Line Types
ACCRUAL               CONSTANT VARCHAR2(30)      := 'Accrual';
RECEIVING_INSPECTION  CONSTANT VARCHAR2(30)      := 'Receiving Inspection';
CLEARING              CONSTANT VARCHAR2(30)      := 'Clearing';
IC_ACCRUAL            CONSTANT VARCHAR2(30)      := 'IC Accrual';
CHARGE                CONSTANT VARCHAR2(30)      := 'Charge';
IC_COST_OF_SALES      CONSTANT VARCHAR2(30)      := 'IC Cost of Sales';
RETROPRICE_ADJUSTMENT CONSTANT VARCHAR2(30)      := 'Retroprice Adjustment';
ENCUMBRANCE_REVERSAL  CONSTANT VARCHAR2(30)      := 'Encumbrance Reversal';
/* Support for Landed Cost Management */
LC_ABSORPTION CONSTANT VARCHAR2(30)      := 'Landed Cost Absorption';

----------------------------------------------------------------------------------
-- API Name         : Get_GLInformation
-- Type             : Private
-- Function         : The Function returns information from GL tables
--                    into a structure of type RCV_AE_GLINFO_REC_TYPE. This
--                    information is generated for each event since events
--                    could possibly be in different Operating Units, Sets of Books
-- Parameters       :
-- IN               : p_event_date: Event Date
--                    p_event_doc_num : Document Number for the Event (PO Number)
--                    p_event_type_id : Event Type ID (RCV_SeedEvents_PVT lists
--                    all such events
--                    p_set_of_books_id:Set of Books ID
-- OUT              :
----------------------------------------------------------------------------------
PROCEDURE Get_GLInformation(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
                p_event_date            IN  DATE,
                p_event_doc_num         IN  VARCHAR2,
                p_event_type_id         IN  NUMBER,
                p_set_of_books_id       IN  NUMBER,
                x_gl_information        OUT NOCOPY RCV_AE_GLINFO_REC_TYPE
) IS

l_gl_installed  BOOLEAN               := FALSE;

/* Get GL Install Status */
l_status                    varchar2(1);
l_industry                  varchar2(1);
l_oracle_schema             varchar2(30);

l_api_name                  varchar2(30) := 'Get_GLInformation';
l_api_version               number := 1.0;

l_stmt_num                  NUMBER;
l_api_message        	    VARCHAR2(1000);


l_batch_id                  NUMBER;

-- Exceptions
NO_GL_PERIOD                EXCEPTION;
NO_PO_PERIOD                EXCEPTION;

BEGIN
  IF G_DEBUG = 'Y' THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin' ,'Get_GLInformation <<');
    END IF;
  END IF;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list
  l_stmt_num := 10;

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Find if GL is installed
  l_stmt_num := 20;
  l_gl_installed := FND_INSTALLATION.GET_APP_INFO  ('SQLGL',
                                                    l_status,
                                                    l_industry,
                                                    l_oracle_schema);
  -- Set Application_ID and Open Period Name depending on Install Status
  IF ( l_status = 'I' ) THEN
    x_gl_information.application_id := G_GL_APPLICATION_ID;

    l_stmt_num := 30;

    BEGIN
      SELECT GL_PER.period_name
      INTO   x_gl_information.period_name
      FROM   gl_period_statuses GL_PER,
             gl_period_statuses PO_PER
      WHERE  PO_PER.application_id     = G_PO_APPLICATION_ID
      AND    PO_PER.set_of_books_id    = p_set_of_books_id
      AND    trunc(PO_PER.start_date) <= trunc(p_event_date)
      AND    trunc(PO_PER.end_date)   >= trunc(p_event_date)
      AND    PO_PER.closing_status     = 'O'
      AND    PO_PER.period_name        = GL_PER.period_name
      AND    GL_PER.set_of_books_id    = p_set_of_books_id
      AND    GL_PER.application_id     = G_GL_APPLICATION_ID
      AND    trunc(GL_PER.start_date)  <= trunc(p_event_date)
      AND    trunc(GL_PER.end_date)    >= trunc(p_event_date)
      AND    GL_PER.closing_status in ('O', 'F')
      AND    GL_PER.adjustment_period_flag <> 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE NO_GL_PERIOD;
    END;

  ELSE
    x_gl_information.application_id := G_PO_APPLICATION_ID;

    l_stmt_num := 40;
    BEGIN
      SELECT period_name
      INTO   x_gl_information.period_name
      FROM   gl_period_statuses
      WHERE  application_id     = G_PO_APPLICATION_ID
      AND    set_of_books_id    = p_set_of_books_id
      AND    trunc(start_date) <= trunc(p_event_date)
      AND    trunc(end_date)   >= trunc(p_event_date)
      AND    closing_status     = 'O'
      AND    adjustment_period_flag <> 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE NO_PO_PERIOD;
    END;

  END IF;

  -- Get the currency and account information from GL tables and views
  l_stmt_num := 50;

  SELECT p_set_of_books_id,
         nvl(chart_of_accounts_id, 0),
         currency_code
  INTO   x_gl_information.set_of_books_id,
         x_gl_information.chart_of_accounts_id,
         x_gl_information.currency_code
  FROM   GL_SETS_OF_BOOKS
  WHERE  set_of_books_id = p_set_of_books_id;

  -- User GL Source Name and Category
  l_stmt_num := 60;

  SELECT user_je_category_name
  INTO   x_gl_information.user_je_category_name
  FROM   GL_JE_CATEGORIES
  WHERE  je_category_name = 'Receiving';

  l_stmt_num := 70;
  SELECT user_je_source_name
  INTO   x_gl_information.user_je_source_name
  FROM   GL_JE_SOURCES
  WHERE  je_source_name = 'Purchasing';


  -- Get Message count and if 1, return message data
  l_stmt_num := 80;

  FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );
  IF G_DEBUG = 'Y' THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end' ,'Get_GLInformation <<');
    END IF;
  END IF;

EXCEPTION
  WHEN NO_GL_PERIOD THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          l_api_message := 'GL Period is not open';
          FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Get_GLInformation : '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'No Open GL Period Found '||
                            SQLERRM
      );

    END IF;
    FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN NO_PO_PERIOD THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          l_api_message := 'PO Period is not open';
          FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Get_GLInformation : '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'No Open PO Period Found '||
                            SQLERRM
      );

    END IF;
    FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          l_api_message := 'Unexpected Error';
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Get_GLInformation : '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_GLInformation;


----------------------------------------------------------------------------------
-- API Name         : Insert_SubLedgerLines
-- Type             : Private
-- Function         : The API inserts an entry in RCV_RECEIVING_SUB_LEDGER
--                    depending on information passed in P_RCV_AE_LINE and
--                    P_GLINFO structures
-- Parameters       :
-- IN               : P_RCV_AE_LINE : Structure containing the accounting information
--                                    (Credit/Debit) for an event
--                    P_GLINFO      : Structure containing the GL Information
--                                    for the event
-- OUT              :
----------------------------------------------------------------------------------

PROCEDURE Insert_SubLedgerLines(
                p_api_version         IN NUMBER,
                p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	        x_return_status	      OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                p_rcv_ae_line         IN  RCV_AE_REC_TYPE,
                p_glinfo              IN  RCV_AE_GLINFO_REC_TYPE
) IS

L_USER_CURR_CONV_TYPE VARCHAR2(30);

l_stmt_num            NUMBER;
l_api_message         VARCHAR2(1000);

l_api_name   CONSTANT VARCHAR2(30) := 'Insert_SubLedgerLines';
l_return_status       VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
l_msg_count           NUMBER       := 0;
l_msg_data            VARCHAR2(8000) := '';

l_rcv_sub_ledger_id   NUMBER;

/* Support for Landed Cost Management */
L_ACT_DR NUMBER;
L_ACT_CR NUMBER;
L_ENT_DR NUMBER;
L_ENT_CR NUMBER;

-- Timezone
l_accounting_date     DATE;
l_legal_entity        NUMBER;

NO_GL_CONV_TYP_DEFINED EXCEPTION;
INSERT_RRSL_ERROR      EXCEPTION;

BEGIN
  -- Initialize message list
  l_stmt_num := 10;

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- USER_CURRENCY_CONV_TYPE
  BEGIN
    l_stmt_num := 20;

    SELECT user_conversion_type
    INTO   L_USER_CURR_CONV_TYPE
    FROM   RCV_ACCOUNTING_EVENTS RAE,
           gl_daily_conversion_types GLCT
    WHERE  RAE.CURRENCY_CONVERSION_TYPE = GLCT.conversion_type
    AND    RAE.ACCOUNTING_EVENT_ID      = p_rcv_ae_line.accounting_event_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      L_USER_CURR_CONV_TYPE := NULL;
  END;

  -- Timezone Changes
  -- Accounting_Date should be in Legal Entity Zone

  -- Get the Legal Entity
  l_stmt_num := 25;

  SELECT LEGAL_ENTITY
  INTO   l_legal_entity
  FROM   CST_ACCT_INFO_V
  WHERE  ORGANIZATION_ID = p_rcv_ae_line.organization_id;

  -- Convert the event_date to Legal Entity time zome
  l_stmt_num := 27;

  l_accounting_date := INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server (
                         p_trxn_date => p_rcv_ae_line.transaction_date,
			 p_le_id     => l_legal_entity );


  -- Insert into SubLedger.
  -- We insert into the table depending on whether the code_combination_id
  -- is NULL or not
  -- Notes
  -- Source_Doc_Quantity is same as Primary Quantity on the Event since
  -- events are created for every distribution.

  -- REFERENCE1, Doc Type is always "PO"

  IF ( P_RCV_AE_LINE.DEBIT_ACCOUNT IS NOT NULL ) THEN
    -- Insert Debit Entry
  BEGIN
    l_stmt_num := 30;

    INSERT INTO RCV_RECEIVING_SUB_LEDGER (
      RCV_SUB_LEDGER_ID,
      ACCOUNTING_EVENT_ID,
      ACCOUNTING_LINE_TYPE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      RCV_TRANSACTION_ID,
      ACTUAL_FLAG,
      JE_SOURCE_NAME,
      JE_CATEGORY_NAME,
      ACCOUNTING_DATE,
      CODE_COMBINATION_ID,
      ACCOUNTED_DR,
      ACCOUNTED_CR,
      ENTERED_DR,
      ENTERED_CR,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_DATE,
      USER_CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_RATE,
      TRANSACTION_DATE,
      PERIOD_NAME,
      CHART_OF_ACCOUNTS_ID,
      FUNCTIONAL_CURRENCY_CODE,
      SET_OF_BOOKS_ID,
      ENCUMBRANCE_TYPE_ID,
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      SOURCE_DOC_QUANTITY,
      ACCRUAL_METHOD_FLAG,
      ENTERED_REC_TAX,
      ENTERED_NR_TAX,
      ACCOUNTED_REC_TAX,
      ACCOUNTED_NR_TAX,
      USSGL_TRANSACTION_CODE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID )
    VALUES (
     DECODE(p_rcv_ae_line.actual_flag,'E',-1,1) * RCV_RECEIVING_SUB_LEDGER_S.NEXTVAL,
      P_RCV_AE_LINE.ACCOUNTING_EVENT_ID,
      P_RCV_AE_LINE.DEBIT_LINE_TYPE,
      SYSDATE,
      P_RCV_AE_LINE.LAST_UPDATED_BY,
      SYSDATE,
      P_RCV_AE_LINE.CREATED_BY,
      P_RCV_AE_LINE.LAST_UPDATE_LOGIN,
      P_RCV_AE_LINE.RCV_TRANSACTION_ID,
      P_RCV_AE_LINE.ACTUAL_FLAG,
      'Purchasing',
      'Accrual',
      TRUNC(l_accounting_date),
      P_RCV_AE_LINE.DEBIT_ACCOUNT,
      P_RCV_AE_LINE.ACCOUNTED_DR,
      NULL,
      P_RCV_AE_LINE.ENTERED_DR,
      NULL,
      P_RCV_AE_LINE.CURRENCY_CODE,
      P_RCV_AE_LINE.CURRENCY_CONVERSION_DATE,
      L_USER_CURR_CONV_TYPE,
      P_RCV_AE_LINE.CURRENCY_CONVERSION_RATE,
      P_RCV_AE_LINE.TRANSACTION_DATE,
      P_GLINFO.PERIOD_NAME,
      P_GLINFO.CHART_OF_ACCOUNTS_ID,
      P_GLINFO.CURRENCY_CODE,
      P_GLINFO.SET_OF_BOOKS_ID,
      NULL,
      'PO',
      P_RCV_AE_LINE.DOC_HEADER_ID,
      P_RCV_AE_LINE.DOC_DISTRIBUTION_ID,
      P_RCV_AE_LINE.DOC_NUMBER,
      P_RCV_AE_LINE.PRIMARY_QUANTITY,
      'O',
      P_RCV_AE_LINE.ENTERED_REC_TAX,
      P_RCV_AE_LINE.ENTERED_NR_TAX,
      P_RCV_AE_LINE.ACCOUNTED_REC_TAX,
      P_RCV_AE_LINE.ACCOUNTED_NR_TAX,
      decode(P_RCV_AE_LINE.DEBIT_LINE_TYPE,
                        RECEIVING_INSPECTION, NULL,
                        P_RCV_AE_LINE.USSGL_TRANSACTION_CODE),
      P_RCV_AE_LINE.REQUEST_ID,
      P_RCV_AE_LINE.PROGRAM_APPLICATION_ID,
      P_RCV_AE_LINE.PROGRAM_ID )
    RETURNING RCV_SUB_LEDGER_ID INTO L_RCV_SUB_LEDGER_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE INSERT_RRSL_ERROR;
  END;

  END IF; --  Debit Account is not NULL

  IF ( P_RCV_AE_LINE.CREDIT_ACCOUNT IS NOT NULL ) THEN
  l_stmt_num := 50;

  BEGIN
    -- Insert Credit Entry
    INSERT INTO RCV_RECEIVING_SUB_LEDGER (
      RCV_SUB_LEDGER_ID,
      ACCOUNTING_EVENT_ID,
      ACCOUNTING_LINE_TYPE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      RCV_TRANSACTION_ID,
      ACTUAL_FLAG,
      JE_SOURCE_NAME,
      JE_CATEGORY_NAME,
      ACCOUNTING_DATE,
      CODE_COMBINATION_ID,
      ACCOUNTED_DR,
      ACCOUNTED_CR,
      ENTERED_DR,
      ENTERED_CR,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_DATE,
      USER_CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_RATE,
      TRANSACTION_DATE,
      PERIOD_NAME,
      CHART_OF_ACCOUNTS_ID,
      FUNCTIONAL_CURRENCY_CODE,
      SET_OF_BOOKS_ID,
      ENCUMBRANCE_TYPE_ID,
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      SOURCE_DOC_QUANTITY,
      ACCRUAL_METHOD_FLAG,
      ENTERED_REC_TAX,
      ENTERED_NR_TAX,
      ACCOUNTED_REC_TAX,
      ACCOUNTED_NR_TAX,
      USSGL_TRANSACTION_CODE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID )
    VALUES (
     DECODE(p_rcv_ae_line.actual_flag,'E',-1,1) *  RCV_RECEIVING_SUB_LEDGER_S.NEXTVAL,
      P_RCV_AE_LINE.ACCOUNTING_EVENT_ID,
      P_RCV_AE_LINE.CREDIT_LINE_TYPE,
      SYSDATE,
      P_RCV_AE_LINE.LAST_UPDATED_BY,
      SYSDATE,
      P_RCV_AE_LINE.CREATED_BY,
      P_RCV_AE_LINE.LAST_UPDATE_LOGIN,
      P_RCV_AE_LINE.RCV_TRANSACTION_ID,
      P_RCV_AE_LINE.ACTUAL_FLAG,
      'Purchasing',
      'Accrual',
      TRUNC(l_accounting_date),
      P_RCV_AE_LINE.CREDIT_ACCOUNT,
      NULL,
      P_RCV_AE_LINE.ACCOUNTED_CR,
      NULL,
      P_RCV_AE_LINE.ENTERED_CR,
      P_RCV_AE_LINE.CURRENCY_CODE,
      P_RCV_AE_LINE.CURRENCY_CONVERSION_DATE,
      L_USER_CURR_CONV_TYPE,
      P_RCV_AE_LINE.CURRENCY_CONVERSION_RATE,
      P_RCV_AE_LINE.TRANSACTION_DATE,
      P_GLINFO.PERIOD_NAME,
      P_GLINFO.CHART_OF_ACCOUNTS_ID,
      P_GLINFO.CURRENCY_CODE,
      P_GLINFO.SET_OF_BOOKS_ID,
      NULL,
      'PO',
      P_RCV_AE_LINE.DOC_HEADER_ID,
      P_RCV_AE_LINE.DOC_DISTRIBUTION_ID,
      P_RCV_AE_LINE.DOC_NUMBER,
      P_RCV_AE_LINE.PRIMARY_QUANTITY,
      'O',
      P_RCV_AE_LINE.ENTERED_REC_TAX,
      P_RCV_AE_LINE.ENTERED_NR_TAX,
      P_RCV_AE_LINE.ACCOUNTED_REC_TAX,
      P_RCV_AE_LINE.ACCOUNTED_NR_TAX,
      decode(P_RCV_AE_LINE.CREDIT_LINE_TYPE,
                        RECEIVING_INSPECTION, NULL,
                        P_RCV_AE_LINE.USSGL_TRANSACTION_CODE),
      P_RCV_AE_LINE.REQUEST_ID,
      P_RCV_AE_LINE.PROGRAM_APPLICATION_ID,
      P_RCV_AE_LINE.PROGRAM_ID )
    RETURNING RCV_SUB_LEDGER_ID INTO L_RCV_SUB_LEDGER_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE INSERT_RRSL_ERROR;
  END;

  END IF; -- Credit Account is NOT NULL

  /* Support for Landed Cost Management */
  IF ( P_RCV_AE_LINE.LCM_ACCOUNT_ID IS NOT NULL ) THEN
  l_stmt_num := 50;

  IF NVL(p_RCV_AE_LINE.LDD_COST_ABS_ACCOUNTED,0) >= 0 THEN
     L_ENT_DR := ABS(NVL(P_RCV_AE_LINE.LDD_COST_ABS_ENTERED,0));
     L_ACT_DR := ABS(NVL(P_RCV_AE_LINE.LDD_COST_ABS_ACCOUNTED,0));
     L_ENT_CR := NULL;
     L_ACT_CR := NULL;
  ELSE
     L_ENT_DR := NULL;
     L_ACT_DR := NULL;
     L_ENT_CR := ABS(NVL(P_RCV_AE_LINE.LDD_COST_ABS_ENTERED,0));
     L_ACT_CR := ABS(NVL(P_RCV_AE_LINE.LDD_COST_ABS_ACCOUNTED,0));
  END IF;

  BEGIN
    INSERT INTO RCV_RECEIVING_SUB_LEDGER (
      RCV_SUB_LEDGER_ID,
      ACCOUNTING_EVENT_ID,
      ACCOUNTING_LINE_TYPE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      RCV_TRANSACTION_ID,
      ACTUAL_FLAG,
      JE_SOURCE_NAME,
      JE_CATEGORY_NAME,
      ACCOUNTING_DATE,
      CODE_COMBINATION_ID,
      ACCOUNTED_DR,
      ACCOUNTED_CR,
      ENTERED_DR,
      ENTERED_CR,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_DATE,
      USER_CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_RATE,
      TRANSACTION_DATE,
      PERIOD_NAME,
      CHART_OF_ACCOUNTS_ID,
      FUNCTIONAL_CURRENCY_CODE,
      SET_OF_BOOKS_ID,
      ENCUMBRANCE_TYPE_ID,
      REFERENCE1,
      REFERENCE2,
      REFERENCE3,
      REFERENCE4,
      SOURCE_DOC_QUANTITY,
      ACCRUAL_METHOD_FLAG,
      ENTERED_REC_TAX,
      ENTERED_NR_TAX,
      ACCOUNTED_REC_TAX,
      ACCOUNTED_NR_TAX,
      USSGL_TRANSACTION_CODE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID )
    VALUES (
      DECODE(p_rcv_ae_line.actual_flag,'E',-1,1) * RCV_RECEIVING_SUB_LEDGER_S.NEXTVAL,
      P_RCV_AE_LINE.ACCOUNTING_EVENT_ID,
      LC_ABSORPTION,
      SYSDATE,
      P_RCV_AE_LINE.LAST_UPDATED_BY,
      SYSDATE,
      P_RCV_AE_LINE.CREATED_BY,
      P_RCV_AE_LINE.LAST_UPDATE_LOGIN,
      P_RCV_AE_LINE.RCV_TRANSACTION_ID,
      P_RCV_AE_LINE.ACTUAL_FLAG,
      'Purchasing',
      'Accrual',
      TRUNC(l_accounting_date),
      P_RCV_AE_LINE.LCM_ACCOUNT_ID,
      L_ACT_DR,
      L_ACT_CR,
      L_ENT_DR,
      L_ENT_CR,
      P_RCV_AE_LINE.CURRENCY_CODE,
      P_RCV_AE_LINE.CURRENCY_CONVERSION_DATE,
      L_USER_CURR_CONV_TYPE,
      P_RCV_AE_LINE.CURRENCY_CONVERSION_RATE,
      P_RCV_AE_LINE.TRANSACTION_DATE,
      P_GLINFO.PERIOD_NAME,
      P_GLINFO.CHART_OF_ACCOUNTS_ID,
      P_GLINFO.CURRENCY_CODE,
      P_GLINFO.SET_OF_BOOKS_ID,
      NULL,
      'PO',
      P_RCV_AE_LINE.DOC_HEADER_ID,
      P_RCV_AE_LINE.DOC_DISTRIBUTION_ID,
      P_RCV_AE_LINE.DOC_NUMBER,
      P_RCV_AE_LINE.PRIMARY_QUANTITY,
      'O',
      P_RCV_AE_LINE.ENTERED_REC_TAX,
      P_RCV_AE_LINE.ENTERED_NR_TAX,
      P_RCV_AE_LINE.ACCOUNTED_REC_TAX,
      P_RCV_AE_LINE.ACCOUNTED_NR_TAX,
      decode(P_RCV_AE_LINE.CREDIT_LINE_TYPE,
                        RECEIVING_INSPECTION, NULL,
                        P_RCV_AE_LINE.USSGL_TRANSACTION_CODE),
      P_RCV_AE_LINE.REQUEST_ID,
      P_RCV_AE_LINE.PROGRAM_APPLICATION_ID,
      P_RCV_AE_LINE.PROGRAM_ID )
    RETURNING RCV_SUB_LEDGER_ID INTO L_RCV_SUB_LEDGER_ID;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE INSERT_RRSL_ERROR;
  END;

  END IF; -- LCM Account is NOT NULL


  -- Get Message count and if 1, return message data
  l_stmt_num := 70;

  FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );

EXCEPTION
  WHEN INSERT_RRSL_ERROR THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          l_api_message := 'Error inserting into RCV_RECEIVING_SUB_LEDGER ';
          FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Insert_SubLedgerLines : '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;


    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'Error inserting into RCV_RECEIVING_SUB_LEDGER '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );

  WHEN OTHERS THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Insert_SubLedgerLines : '||l_stmt_num||' : '||substr(SQLERRM,1,200));
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );

END Insert_SubLedgerLines;

----------------------------------------------------------------------------------
-- API Name         : Get_AccountingLineType
-- Type             : Private
-- Function         : The API returns the Accounting Line Type for an accounting
--                    event. It returns the line types for both Credit and Debit
--                    lines.
-- Parameters       :
-- IN               : p_event_type_id     : Event Type (RCV_SeedEvent_PVT)
--                    p_parent_txn_type   : Transaction Type of the Parent of the
--                                          current event
--                    p_proc_org_flag     : Whether the Organization where accounting
--                                          event occured is facing the supplier
--                    p_one_time_item_flag: Whether the item associated with the
--                                          event is a one-time item
--                    p_destination_type  : Destination_Type_Code for the Event
--                                          ('Inventory', 'Shop Floor', 'Expense')
--                    p_global_proc_flag  : Whether event has been created in a
--                                          global procurement scenario
-- OUT              : x_debit_line_type   : Accounting Line Type for Debit
--                    x_credit_line_type  : Accounting Line Type for Credit
----------------------------------------------------------------------------------

PROCEDURE Get_AccountingLineType(
                p_api_version         IN NUMBER,
                p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	        x_return_status	      OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                p_event_type_id       IN NUMBER,
                p_parent_txn_type     IN VARCHAR2,
                p_proc_org_flag       IN VARCHAR2,
                p_one_time_item_flag  IN VARCHAR2,
                p_destination_type    IN VARCHAR2,
                p_global_proc_flag    IN VARCHAR2,
                x_debit_line_type     OUT NOCOPY VARCHAR2,
                x_credit_line_type    OUT NOCOPY VARCHAR2
) IS
UNKNOWN_EVENT_TYPE_EXCEPTION EXCEPTION;

l_stmt_num 	NUMBER;
l_api_message   VARCHAR2(1000);

l_api_name CONSTANT VARCHAR2(30) := 'Get_AccountingLineType';



BEGIN
  -- Initialize message list
  l_stmt_num := 10;
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Initialize
     x_debit_line_type  := '';
     x_credit_line_type := '';

  IF ( ( p_event_type_id = RCV_SeedEvents_PVT.RECEIVE OR
         p_event_type_id = RCV_SeedEvents_PVT.MATCH ) OR
       ( p_event_type_id = RCV_SeedEvents_PVT.CORRECT AND
        ( p_parent_txn_type = 'RECEIVE' OR p_parent_txn_type = 'MATCH') ) ) THEN
    -- RECEIVE/MATCH----------------------------
    IF p_proc_org_flag = 'Y' THEN
      l_stmt_num := 20;
      x_debit_line_type := RECEIVING_INSPECTION;
      x_credit_line_type:= ACCRUAL;
    ELSE
      l_stmt_num := 30;
      x_debit_line_type := RECEIVING_INSPECTION;
      x_credit_line_type:= IC_ACCRUAL;
    END IF;
    --------------------------------------------

    -- LOGICAL_RECEIVE--------------------------
    ELSIF p_event_type_id = RCV_SeedEvents_PVT.LOGICAL_RECEIVE THEN
      IF p_proc_org_flag = 'Y' THEN
        IF p_one_time_item_flag = 'Y'  OR p_destination_type = 'SHOP FLOOR' THEN
          l_stmt_num := 40;
          x_debit_line_type := IC_COST_OF_SALES;
          x_credit_line_type:= ACCRUAL;
        ELSE
          l_stmt_num := 50;
          x_debit_line_type := CLEARING;
          x_credit_line_type:= ACCRUAL;
        END IF;
      ELSE
        IF p_one_time_item_flag = 'Y' OR p_destination_type = 'SHOP FLOOR' THEN
          l_stmt_num := 60;
          x_debit_line_type := IC_COST_OF_SALES;
          x_credit_line_type:= IC_ACCRUAL;
        ELSE
          l_stmt_num := 70;
          x_debit_line_type := CLEARING;
          x_credit_line_type:= IC_ACCRUAL;
        END IF;
      END IF;
    --------------------------------------------

    -- DELIVER---------------------------------
    ELSIF ( p_event_type_id = RCV_SeedEvents_PVT.DELIVER OR
            ( p_event_type_id = RCV_SeedEvents_PVT.CORRECT AND p_parent_txn_type = 'DELIVER') )THEN
      l_stmt_num := 80;
      x_debit_line_type := CHARGE;
      x_credit_line_type:= RECEIVING_INSPECTION;
    --------------------------------------------

    -- RETURN_TO_VENDOR----------------------------------
    ELSIF ( p_event_type_id = RCV_SeedEvents_PVT.RETURN_TO_VENDOR OR
            ( p_event_type_id = RCV_SeedEvents_PVT.CORRECT AND p_parent_txn_type = 'RETURN TO VENDOR' ))THEN
      IF p_proc_org_flag = 'Y' THEN
        l_stmt_num := 90;
        x_debit_line_type := ACCRUAL;
        x_credit_line_type:= RECEIVING_INSPECTION;
      ELSE
        l_stmt_num := 100;
        x_debit_line_type := IC_ACCRUAL;
        x_credit_line_type:= RECEIVING_INSPECTION;
      END IF;
    -----------------------------------------------------

    -- LOGICAL_RETURN_TO_VENDOR--------------------------
    ELSIF p_event_type_id = RCV_SeedEvents_PVT.LOGICAL_RETURN_TO_VENDOR THEN
      IF p_proc_org_flag = 'Y' THEN
        IF p_one_time_item_flag = 'Y' OR p_destination_type = 'SHOP FLOOR' THEN
          l_stmt_num := 110;
          x_debit_line_type := ACCRUAL;
          x_credit_line_type:= IC_COST_OF_SALES;
        ELSE
          l_stmt_num := 120;
          x_debit_line_type := ACCRUAL;
          x_credit_line_type:= CLEARING;
        END IF;
      ELSE
        IF p_one_time_item_flag = 'Y' OR p_destination_type = 'SHOP FLOOR' THEN
          l_stmt_num := 130;
          x_debit_line_type := IC_ACCRUAL;
          x_credit_line_type:= IC_COST_OF_SALES;
        ELSE
          l_stmt_num := 140;
          x_debit_line_type := IC_ACCRUAL;
          x_credit_line_type:= CLEARING;
        END IF;
      END IF;
    -----------------------------------------------------

    -- RETURN_TO_RECEIVING--------------------------
    ELSIF ( p_event_type_id = RCV_SeedEvents_PVT.RETURN_TO_RECEIVING OR
            ( p_event_type_id = RCV_SeedEvents_PVT.CORRECT AND
              p_parent_txn_type = 'RETURN TO RECEIVING' ) )THEN
      l_stmt_num := 150;
      x_debit_line_type := RECEIVING_INSPECTION;
      x_credit_line_type:= CHARGE;
    ------------------------------------------------

    -- ADJUST_RECEIVE---------------------------
    ELSIF p_event_type_id = RCV_SeedEvents_PVT.ADJUST_RECEIVE  THEN
      IF p_global_proc_flag = 'N' THEN
        l_stmt_num := 160;
        x_debit_line_type := RECEIVING_INSPECTION;
        x_credit_line_type:= ACCRUAL;
      ELSE -- Global Procurement Case
        l_stmt_num := 165;
        IF (p_destination_type = 'SHOP FLOOR' OR p_one_time_item_flag = 'N') THEN

          x_debit_line_type := RETROPRICE_ADJUSTMENT;
          x_credit_line_type:= ACCRUAL;
        ELSE

          x_debit_line_type := IC_COST_OF_SALES;
          x_credit_line_type:= ACCRUAL;
        END IF;
      END IF;
    --------------------------------------------

    --ADJUST_DELIVER--------------------------------
    ELSIF p_event_type_id = RCV_SeedEvents_PVT.ADJUST_DELIVER THEN
      IF p_destination_type in ('INVENTORY', 'SHOP FLOOR') THEN
        l_stmt_num := 170;
        x_debit_line_type := RETROPRICE_ADJUSTMENT;
        x_credit_line_type:= RECEIVING_INSPECTION;
      ELSE
        IF p_destination_type = 'EXPENSE' THEN
          l_stmt_num := 180;
          x_debit_line_type := CHARGE;
          x_credit_line_type:= RECEIVING_INSPECTION;
        END IF;
      END IF;
    -----------------------------------------------

    -- ENCUMBRANCE_REVERSAL-----------------------
    ELSIF p_event_type_id = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL THEN
      x_debit_line_type := ENCUMBRANCE_REVERSAL;
      x_credit_line_type:= ENCUMBRANCE_REVERSAL;
    ----------------------------------------------
    ELSE
      RAISE UNKNOWN_EVENT_TYPE_EXCEPTION;
  END IF;

  IF G_DEBUG = 'Y' THEN
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_api_message := 'Debit Line Type: '||x_debit_line_type||
                         ' Credit Line Type: '||x_credit_line_type;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num
                ,l_api_message);
     END IF;
  END IF;


  -- Get Message count and if 1, return message data
  FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );
EXCEPTION
  WHEN UNKNOWN_EVENT_TYPE_EXCEPTION THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          l_api_message := 'Unknown Transaction ';
          FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Get_AccountingLineType : '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'Unknown Transaction '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );

  WHEN OTHERS THEN
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                   ,'Get_AccountingLineType : '||l_stmt_num||' : '||SUBSTR(sqlerrm,1,200));
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
          (  p_count  => x_msg_count,
             p_data   => x_msg_data
          );


END Get_AccountingLineType;

----------------------------------------------------------------------------------
-- API Name         : Create_AccountingEntry
-- Type             : Private
-- Function         : This API, called by the API's that seed accounting events, is
--                    responsible for creating accounting entries for the event
--                    that has been seeded in RCV_ACCOUNTING_EVENTS and passed to
--                    it. The API creates entries in the subledger,
--                    RCV_RECEIVING_SUB_LEDGER and also creates lines in GL_INTERFACE.
-- Parameters       :
-- IN               : p_accounting_event_id : Accounting_Event_ID of the Event
--                                            in RCV_ACCOUNTING_EVENTS for which
--                                            entries are to be created in RRS and
--                                            GL_INTERFACE
--
--
--
-- OUT              : The x_return_status variable indicates the SUCCESS or
--                    FAILURE of this routine
----------------------------------------------------------------------------------

PROCEDURE Create_AccountingEntry(
                p_api_version           IN         NUMBER,
                p_init_msg_list         IN         VARCHAR2 := FND_API.G_FALSE,
                p_commit                IN         VARCHAR2 := FND_API.G_FALSE,
                p_validation_level      IN         NUMBER := FND_API.G_VALID_LEVEL_FULL,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_accounting_event_id   IN         NUMBER,
               /* Support for Landed Cost Management */
                p_lcm_flag              IN         VARCHAR2
)
IS
  l_api_name	CONSTANT VARCHAR2(30) := 'Create_AccountingEntry';
  l_api_version	CONSTANT NUMBER       := 1.0;

  /* Return */
  l_return_status	 VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
  l_msg_count            NUMBER       := 0;
  l_msg_data             VARCHAR2(8000) := '';
  l_stmt_num             NUMBER       := 0;
  l_api_message          VARCHAR2(1000);

  /* Local Structures for Event, Currency and GL Information */
  l_rcv_ae_line          RCV_AE_REC_TYPE;
  l_curr_rec             RCV_CURR_REC_TYPE;
  l_glinfo               RCV_AE_GLINFO_REC_TYPE;


  l_parent_rcv_txn_id    NUMBER;
  l_parent_txn_type      VARCHAR2(25);
  l_one_time_item        VARCHAR2(1) := 'N';
  l_destination_type_code VARCHAR2(25);
  l_debit_line_type      NUMBER;
  l_credit_line_type     NUMBER;

  l_drop_ship            VARCHAR2(1);


  -- Service Line Types
  l_nr_tax_amount           NUMBER;
  l_rec_tax_amount          NUMBER;
  -- Retroactive Pricing Events

  l_prior_accounted_dr      NUMBER;
  l_prior_entered_dr        NUMBER;
  l_prior_nr_tax            NUMBER;
  l_prior_rec_tax           NUMBER;
  l_prior_accounted_nr_tax  NUMBER;
  l_prior_entered_nr_tax    NUMBER;
  l_prior_accounted_rec_tax NUMBER;
  l_prior_entered_rec_tax   NUMBER;

  -- Timezone --
  l_legal_entity            NUMBER;
  l_event_le_date           DATE;

  -- SLA Uptake --
  l_trx_info                CST_XLA_PVT.t_xla_rcv_trx_info;
  l_encumbrance_flag        VARCHAR2(1);
  l_bc_status               VARCHAR2(2000);
  l_packet_id               NUMBER;
  l_user_id                 NUMBER;
  l_resp_id                 NUMBER;
  l_resp_appl_id            NUMBER;
  l_source_data             XLA_EVENTS_PUB_PKG.t_event_source_info;
  l_accounting_option       NUMBER;
  l_batch                   NUMBER;
  l_errbuf                  VARCHAR2(1000);
  l_retcode                 NUMBER;
  l_request_id              NUMBER;

  /* Support for Landed Cost Management */
  L_RCV_INSP_ENTERED_VAL    NUMBER;
  L_RCV_INSP_ACCOUNTED_VAL  NUMBER;

  NO_CURRENCY_INFORMATION   EXCEPTION;
  NO_PO_INFORMATION         EXCEPTION;
  NO_RAE_DATA               EXCEPTION;
  l_primary_qty             NUMBER;

BEGIN


  -- Standard start of API savepoint
  SAVEPOINT RCV_CreateAccounting_PVT;

  IF G_DEBUG = 'Y' THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin' ,'Create_AccountingEntry <<');
    END IF;
  END IF;

  -- Standard call to check for call compatibility
  l_stmt_num := 10;
  IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  l_stmt_num := 20;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Get Information from RCV_ACCOUNTING_EVENTS and populate l_rcv_ae_line
  BEGIN
    l_stmt_num := 30;
    SELECT
      ACCOUNTING_EVENT_ID,
      RCV_TRANSACTION_ID,
      DECODE(TRX_FLOW_HEADER_ID, NULL, 'N', 'Y'),
      PO_HEADER_ID,
      PO_DISTRIBUTION_ID,
      ORG_ID,
      ORGANIZATION_ID,
      SET_OF_BOOKS_ID,
      TRANSACTION_DATE,
      EVENT_TYPE_ID,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_RATE,
      CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_DATE,
      SOURCE_DOC_QUANTITY,     -- Document Quantity is used to create distributions
      UNIT_PRICE,
      /* Support for Landed Cost Management */
      UNIT_LANDED_COST,
      PRIOR_UNIT_PRICE,
      TRANSACTION_AMOUNT,
      NR_TAX,
      REC_TAX,
      NR_TAX_AMOUNT,
      REC_TAX_AMOUNT,
      NVL(PRIOR_NR_TAX, 0),
      NVL(PRIOR_REC_TAX, 0),
      DEBIT_ACCOUNT_ID,
      CREDIT_ACCOUNT_ID,
      /* Support for Landed Cost Management */
      LCM_ACCOUNT_ID,
      PROCUREMENT_ORG_FLAG,
      INVENTORY_ITEM_ID,
      USSGL_TRANSACTION_CODE,
      GL_GROUP_ID,
      CREATED_BY,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PRIMARY_QUANTITY
    INTO
      L_RCV_AE_LINE.ACCOUNTING_EVENT_ID,
      L_RCV_AE_LINE.RCV_TRANSACTION_ID,
      L_RCV_AE_LINE.GLOBAL_PROC_FLAG,
      L_RCV_AE_LINE.DOC_HEADER_ID,
      L_RCV_AE_LINE.DOC_DISTRIBUTION_ID,
      L_RCV_AE_LINE.ORG_ID,
      L_RCV_AE_LINE.ORGANIZATION_ID,
      L_RCV_AE_LINE.SET_OF_BOOKS_ID,
      L_RCV_AE_LINE.TRANSACTION_DATE,
      L_RCV_AE_LINE.EVENT_TYPE_ID,
      L_RCV_AE_LINE.CURRENCY_CODE,
      L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE,
      L_RCV_AE_LINE.CURRENCY_CONVERSION_TYPE,
      L_RCV_AE_LINE.CURRENCY_CONVERSION_DATE,
      L_RCV_AE_LINE.PRIMARY_QUANTITY,
      L_RCV_AE_LINE.UNIT_PRICE,
      /* Support for Landed Cost Management */
      L_RCV_AE_LINE.UNIT_LANDED_COST,
      L_RCV_AE_LINE.PRIOR_UNIT_PRICE,
      L_RCV_AE_LINE.TRANSACTION_AMOUNT,
      L_RCV_AE_LINE.NR_TAX,
      L_RCV_AE_LINE.REC_TAX,
      L_NR_TAX_AMOUNT,
      L_REC_TAX_AMOUNT,
      L_PRIOR_NR_TAX,
      L_PRIOR_REC_TAX,
      L_RCV_AE_LINE.DEBIT_ACCOUNT,
      L_RCV_AE_LINE.CREDIT_ACCOUNT,
      /* Support for Landed Cost Management */
      L_RCV_AE_LINE.LCM_ACCOUNT_ID,
      L_RCV_AE_LINE.PROCUREMENT_ORG_FLAG,
      L_RCV_AE_LINE.INVENTORY_ITEM_ID,
      L_RCV_AE_LINE.USSGL_TRANSACTION_CODE,
      L_RCV_AE_LINE.GL_GROUP_ID,
      L_RCV_AE_LINE.CREATED_BY,
      L_RCV_AE_LINE.LAST_UPDATED_BY,
      L_RCV_AE_LINE.LAST_UPDATE_LOGIN,
      L_RCV_AE_LINE.REQUEST_ID,
      L_RCV_AE_LINE.PROGRAM_APPLICATION_ID,
      L_RCV_AE_LINE.PROGRAM_ID,
      l_primary_qty
    FROM
      RCV_ACCOUNTING_EVENTS
    WHERE
      ACCOUNTING_EVENT_ID = p_accounting_event_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_RAE_DATA;
  END;


  l_stmt_num := 35;
  -- Some true drop shipment cases do not have transaction_flow_header_id
  -- The dropship_type_code should also be checked

  SELECT
    DECODE( DROPSHIP_TYPE_CODE, 1, 'Y', 2, 'Y', 'N' )
  INTO
    l_drop_ship
  FROM
    RCV_TRANSACTIONS
  WHERE
    TRANSACTION_ID = L_RCV_AE_LINE.RCV_TRANSACTION_ID;

  l_stmt_num := 37;

  IF ( l_drop_ship = 'Y' ) THEN
    L_RCV_AE_LINE.GLOBAL_PROC_FLAG := 'Y';
  END IF;

  -- Get some information from Document tables for Reference cols in Subledger
  BEGIN
    l_stmt_num := 40;
    SELECT
      SEGMENT1
    INTO
      L_RCV_AE_LINE.DOC_NUMBER
    FROM
      PO_HEADERS
    WHERE
      PO_HEADER_ID = L_RCV_AE_LINE.DOC_HEADER_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_PO_INFORMATION;
  END;
  BEGIN
    l_stmt_num := 50;
    SELECT
      substrb(POL.ITEM_DESCRIPTION,1,100)
    INTO
      L_RCV_AE_LINE.ITEM_DESCRIPTION
    FROM
      PO_LINES POL,
      PO_DISTRIBUTIONS POD
    WHERE
        POD.PO_DISTRIBUTION_ID = L_RCV_AE_LINE.DOC_DISTRIBUTION_ID
    AND POL.PO_LINE_ID         = POD.PO_LINE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_PO_INFORMATION;
  END;


  -- Timezone --
  -- The periods are computed using event_time in the
  -- legal entity time zone. Find it using MGD's Inventory API

  -- Get the Legal Entity
  l_stmt_num := 55;

  SELECT LEGAL_ENTITY
  INTO   l_legal_entity
  FROM   CST_ACCT_INFO_V
  WHERE  ORGANIZATION_ID = l_rcv_ae_line.organization_id;

  -- Convert the event_date to Legal Entity time zome
  l_stmt_num := 57;

  l_event_le_date := INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server (
		       p_trxn_date => l_rcv_ae_line.transaction_date,
		       p_le_id     => l_legal_entity );


  -- Populate GL Information
  l_stmt_num := 60;
  Get_GLInformation
    ( p_api_version     => 1.0,
      x_return_status   => l_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_event_date      => l_event_le_date,
      p_event_doc_num   => l_rcv_ae_line.doc_number,
      p_event_type_id   => l_rcv_ae_line.event_type_id,
      p_set_of_books_id => l_rcv_ae_line.set_of_books_id,
      x_gl_information  => l_glinfo
    );


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_api_message := 'Error in getting GL Information';
    IF G_DEBUG = 'Y' THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||
'.'||l_api_name||l_stmt_num ,'Create_AccountingEntry: '||l_stmt_num||' : '||l_api_message);
      END IF;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  -- Populate currency information into currency structure
  l_stmt_num := 70;

  L_CURR_REC.CURRENCY_CONVERSION_RATE := L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
  L_CURR_REC.CURRENCY_CONVERSION_TYPE := L_RCV_AE_LINE.CURRENCY_CONVERSION_TYPE;
  L_CURR_REC.CURRENCY_CONVERSION_DATE := L_RCV_AE_LINE.CURRENCY_CONVERSION_DATE;

  -- Document Currency
  l_stmt_num := 80;
  BEGIN
    SELECT
      CURRENCY_CODE,
      MINIMUM_ACCOUNTABLE_UNIT,
      PRECISION
    INTO
      L_CURR_REC.DOCUMENT_CURRENCY,
      L_CURR_REC.MIN_ACCT_UNIT_DOC,
      L_CURR_REC.PRECISION_DOC
    FROM
      FND_CURRENCIES
    WHERE
      CURRENCY_CODE = L_RCV_AE_LINE.CURRENCY_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_CURRENCY_INFORMATION;
  END;


  -- Functional Currency
  l_stmt_num := 90;
  BEGIN
    SELECT
      CURRENCY_CODE,
      MINIMUM_ACCOUNTABLE_UNIT,
      PRECISION
    INTO
      L_CURR_REC.FUNCTIONAL_CURRENCY,
      L_CURR_REC.MIN_ACCT_UNIT_FUNC,
      L_CURR_REC.PRECISION_FUNC
    FROM
      FND_CURRENCIES
    WHERE
      CURRENCY_CODE = L_GLINFO.CURRENCY_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NO_CURRENCY_INFORMATION;
  END;



  -- Populate the Accounting Structure

  -- Entered_Dr
  l_stmt_num := 110;
  IF (L_RCV_AE_LINE.UNIT_PRICE IS NULL) THEN
    L_RCV_AE_LINE.ENTERED_DR      := L_RCV_AE_LINE.TRANSACTION_AMOUNT;
    L_RCV_AE_LINE.ENTERED_NR_TAX  := l_nr_tax_amount;
    L_RCV_AE_LINE.ENTERED_REC_TAX := l_rec_tax_amount;
  ELSE
    L_RCV_AE_LINE.ENTERED_DR      := L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.UNIT_PRICE;
    L_PRIOR_ENTERED_DR            := L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.PRIOR_UNIT_PRICE;
    L_RCV_AE_LINE.ENTERED_NR_TAX  := L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.NR_TAX;
    L_RCV_AE_LINE.ENTERED_REC_TAX := L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.REC_TAX;
    L_PRIOR_ENTERED_NR_TAX        := L_RCV_AE_LINE.PRIMARY_QUANTITY * L_PRIOR_NR_TAX;
    L_PRIOR_ENTERED_REC_TAX       := L_RCV_AE_LINE.PRIMARY_QUANTITY * L_PRIOR_REC_TAX;
  END IF;
/*
 -- Accounted_Dr, Accounted_Nr_Tax, Accounted_Rec_Tax
 -- Use Document Currency Precision/MAU to round before doing currency conversion
  l_stmt_num := 120;
  IF ( L_CURR_REC.MIN_ACCT_UNIT_DOC IS NOT NULL ) THEN

    L_RCV_AE_LINE.ENTERED_DR        := ROUND (L_RCV_AE_LINE.ENTERED_DR / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    L_RCV_AE_LINE.ENTERED_NR_TAX    := ROUND (L_RCV_AE_LINE.ENTERED_NR_TAX / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    L_RCV_AE_LINE.ENTERED_REC_TAX   := ROUND (L_RCV_AE_LINE.ENTERED_REC_TAX / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;

    L_PRIOR_ENTERED_DR        := ROUND (L_PRIOR_ENTERED_DR / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    L_PRIOR_ENTERED_NR_TAX    := ROUND (L_PRIOR_ENTERED_NR_TAX / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    L_PRIOR_ENTERED_REC_TAX   := ROUND (L_PRIOR_ENTERED_REC_TAX / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;

    IF ( L_RCV_AE_LINE.UNIT_PRICE IS NULL ) THEN
      -- Tax Columns contain the Tax Amount in the case of Service Line Types
      -- Accounted_Nr_Tax
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_NR_TAX_AMOUNT/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Rec_Tax
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_REC_TAX_AMOUNT/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Dr
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.TRANSACTION_AMOUNT/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

    ELSE
      -- Accounted_Nr_Tax
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.NR_TAX * L_RCV_AE_LINE.PRIMARY_QUANTITY/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Rec_Tax
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.REC_TAX * L_RCV_AE_LINE.PRIMARY_QUANTITY/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Dr
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY *  L_RCV_AE_LINE.UNIT_PRICE/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Prior_Accounted_Nr_Tax
      L_PRIOR_ACCOUNTED_NR_TAX  := ROUND (L_PRIOR_NR_TAX * L_RCV_AE_LINE.PRIMARY_QUANTITY/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Prior_Accounted_Rec_Tax
      L_PRIOR_ACCOUNTED_REC_TAX := ROUND (L_PRIOR_REC_TAX * L_RCV_AE_LINE.PRIMARY_QUANTITY/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Prior_Accounted_Dr
      L_PRIOR_ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY *  L_RCV_AE_LINE.PRIOR_UNIT_PRICE/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

    END IF; -- UNIT_PRICE NULL
  ELSE
    L_RCV_AE_LINE.ENTERED_DR        := ROUND (L_RCV_AE_LINE.ENTERED_DR, L_CURR_REC.PRECISION_DOC);
    L_RCV_AE_LINE.ENTERED_NR_TAX    := ROUND (L_RCV_AE_LINE.ENTERED_NR_TAX, L_CURR_REC.PRECISION_DOC);
    L_RCV_AE_LINE.ENTERED_REC_TAX   := ROUND (L_RCV_AE_LINE.ENTERED_REC_TAX, L_CURR_REC.PRECISION_DOC);
    L_PRIOR_ENTERED_DR        := ROUND (L_PRIOR_ENTERED_DR, L_CURR_REC.PRECISION_DOC);
    L_PRIOR_ENTERED_NR_TAX    := ROUND (L_PRIOR_ENTERED_NR_TAX, L_CURR_REC.PRECISION_DOC);
    L_PRIOR_ENTERED_REC_TAX   := ROUND (L_PRIOR_ENTERED_REC_TAX, L_CURR_REC.PRECISION_DOC);
    -- Accounted_Dr
    IF ( L_RCV_AE_LINE.UNIT_PRICE IS NULL ) THEN
      -- Accounted_Nr_Tax
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_NR_TAX_AMOUNT, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Rec_Tax
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_REC_TAX_AMOUNT, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Dr
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.TRANSACTION_AMOUNT, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
    ELSE
      -- Accounted_Nr_Tax
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.NR_TAX, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Rec_Tax
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.REC_TAX, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Accounted_Dr
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY *  L_RCV_AE_LINE.UNIT_PRICE, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Prior_Accounted_Nr_Tax
      L_PRIOR_ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY * L_PRIOR_NR_TAX, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Prior_Accounted_Rec_Tax
      L_PRIOR_ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY * L_PRIOR_REC_TAX, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

      -- Prior_Accounted_Dr
      L_PRIOR_ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY *  L_RCV_AE_LINE.PRIOR_UNIT_PRICE, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

    END IF;
  END IF; -- MIN_ACCT_UNIT_DOC IS NOT NULL

  -- Accounted_Dr, Entered_Dr, NR_Tax, Rec_Tax
  -- Use Functional Currency to Round the amounts obtained above.
  l_stmt_num := 130;
  IF ( L_CURR_REC.MIN_ACCT_UNIT_FUNC IS NOT NULL ) THEN
    L_RCV_AE_LINE.ACCOUNTED_DR      := ROUND (L_RCV_AE_LINE.ACCOUNTED_DR / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
    L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.ACCOUNTED_NR_TAX / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
    L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.ACCOUNTED_REC_TAX / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;

    -- Retroactive Pricing --
    L_PRIOR_ACCOUNTED_DR      := ROUND (L_PRIOR_ACCOUNTED_DR / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
    L_PRIOR_ACCOUNTED_NR_TAX  := ROUND (L_PRIOR_ACCOUNTED_NR_TAX / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
    L_PRIOR_ACCOUNTED_REC_TAX := ROUND (L_PRIOR_ACCOUNTED_REC_TAX /L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;

  ELSE
    L_RCV_AE_LINE.ACCOUNTED_DR      := ROUND (L_RCV_AE_LINE.ACCOUNTED_DR, L_CURR_REC.PRECISION_FUNC);
    L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.ACCOUNTED_NR_TAX, L_CURR_REC.PRECISION_FUNC);
    L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.ACCOUNTED_REC_TAX, L_CURR_REC.PRECISION_FUNC);

    -- Retroactive Pricing --
    L_PRIOR_ACCOUNTED_DR      := ROUND (L_PRIOR_ACCOUNTED_DR, L_CURR_REC.PRECISION_FUNC);
    L_PRIOR_ACCOUNTED_NR_TAX  := ROUND (L_PRIOR_ACCOUNTED_NR_TAX, L_CURR_REC.PRECISION_FUNC);
    L_PRIOR_ACCOUNTED_REC_TAX := ROUND (L_PRIOR_ACCOUNTED_REC_TAX, L_CURR_REC.PRECISION_FUNC);

  END IF;


  -- Actual_Flag
  l_stmt_num := 140;
  IF ( L_RCV_AE_LINE.EVENT_TYPE_ID = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL ) THEN
    L_RCV_AE_LINE.ACTUAL_FLAG := 'E';
  ELSE
    L_RCV_AE_LINE.ACTUAL_FLAG := 'A';
  END IF;

  l_stmt_num := 145;

  -- For Retroactive Pricing
  -- Accounted_Dr = New_Accounted_Dr (= Accounted_Dr) - Prior_Accounted_Dr and similar

  IF (L_RCV_AE_LINE.EVENT_TYPE_ID IN (RCV_SeedEvents_PVT.ADJUST_RECEIVE, RCV_SeedEvents_PVT.ADJUST_DELIVER)) THEN
    L_RCV_AE_LINE.ACCOUNTED_DR      :=  L_RCV_AE_LINE.ACCOUNTED_DR - L_PRIOR_ACCOUNTED_DR;
    L_RCV_AE_LINE.ENTERED_DR        :=  L_RCV_AE_LINE.ENTERED_DR - L_PRIOR_ENTERED_DR;
    L_RCV_AE_LINE.ACCOUNTED_NR_TAX  :=  L_RCV_AE_LINE.ACCOUNTED_NR_TAX - L_PRIOR_ACCOUNTED_NR_TAX;
    L_RCV_AE_LINE.ENTERED_NR_TAX    :=  L_RCV_AE_LINE.ENTERED_NR_TAX - L_PRIOR_ENTERED_NR_TAX;
    L_RCV_AE_LINE.ACCOUNTED_REC_TAX :=  L_RCV_AE_LINE.ACCOUNTED_REC_TAX - L_PRIOR_ACCOUNTED_REC_TAX;
    L_RCV_AE_LINE.ENTERED_REC_TAX   :=  L_RCV_AE_LINE.ENTERED_NR_TAX - L_PRIOR_ENTERED_REC_TAX;
  END IF;
  */

    /* changes for Bug 6142658 starts */
  -- For Retroactive Pricing
  IF (L_RCV_AE_LINE.EVENT_TYPE_ID IN (RCV_SeedEvents_PVT.ADJUST_RECEIVE, RCV_SeedEvents_PVT.ADJUST_DELIVER)) THEN
   -- ENTERED Values
    L_RCV_AE_LINE.ENTERED_DR        :=L_RCV_AE_LINE.ENTERED_DR-NVL(L_PRIOR_ENTERED_DR,0);
    L_RCV_AE_LINE.ENTERED_NR_TAX    :=L_RCV_AE_LINE.ENTERED_NR_TAX-NVL(L_PRIOR_ENTERED_NR_TAX,0);
    L_RCV_AE_LINE.ENTERED_REC_TAX   :=L_RCV_AE_LINE.ENTERED_REC_TAX-NVL(L_PRIOR_ENTERED_REC_TAX,0);

    L_RCV_AE_LINE.NR_TAX            := L_RCV_AE_LINE.NR_TAX-NVL(L_PRIOR_NR_TAX,0);
    L_RCV_AE_LINE.REC_TAX           := L_RCV_AE_LINE.REC_TAX-NVL(L_PRIOR_REC_TAX,0);
    L_RCV_AE_LINE.UNIT_PRICE        := L_RCV_AE_LINE.UNIT_PRICE-NVL(L_RCV_AE_LINE.PRIOR_UNIT_PRICE,0);
  END IF;

 -- Accounted_Dr, Accounted_Nr_Tax, Accounted_Rec_Tax
 -- Use Document Currency Precision/MAU to round before doing currency conversion
  l_stmt_num := 120;
  IF ( L_CURR_REC.MIN_ACCT_UNIT_DOC IS NOT NULL ) THEN

    L_RCV_AE_LINE.ENTERED_DR        := ROUND (L_RCV_AE_LINE.ENTERED_DR / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    L_RCV_AE_LINE.ENTERED_NR_TAX    := ROUND (L_RCV_AE_LINE.ENTERED_NR_TAX / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    L_RCV_AE_LINE.ENTERED_REC_TAX   := ROUND (L_RCV_AE_LINE.ENTERED_REC_TAX / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;

    IF ( L_RCV_AE_LINE.UNIT_PRICE IS NULL ) THEN
      -- Tax Columns contain the Tax Amount in the case of Service Line Types
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_NR_TAX_AMOUNT/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_REC_TAX_AMOUNT/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.TRANSACTION_AMOUNT/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

    ELSE
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.NR_TAX * L_RCV_AE_LINE.PRIMARY_QUANTITY/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.REC_TAX * L_RCV_AE_LINE.PRIMARY_QUANTITY/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY *  L_RCV_AE_LINE.UNIT_PRICE/L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
    END IF; -- UNIT_PRICE NULL
  ELSE
    L_RCV_AE_LINE.ENTERED_DR        := ROUND (L_RCV_AE_LINE.ENTERED_DR, L_CURR_REC.PRECISION_DOC);
    L_RCV_AE_LINE.ENTERED_NR_TAX    := ROUND (L_RCV_AE_LINE.ENTERED_NR_TAX, L_CURR_REC.PRECISION_DOC);
    L_RCV_AE_LINE.ENTERED_REC_TAX   := ROUND (L_RCV_AE_LINE.ENTERED_REC_TAX, L_CURR_REC.PRECISION_DOC);
    -- Accounted_Dr
    IF ( L_RCV_AE_LINE.UNIT_PRICE IS NULL ) THEN

      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_NR_TAX_AMOUNT, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_REC_TAX_AMOUNT, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.TRANSACTION_AMOUNT, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
    ELSE
      L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.NR_TAX, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY * L_RCV_AE_LINE.REC_TAX, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
      L_RCV_AE_LINE.ACCOUNTED_DR := ROUND (L_RCV_AE_LINE.PRIMARY_QUANTITY *  L_RCV_AE_LINE.UNIT_PRICE, L_CURR_REC.PRECISION_DOC) * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;
    END IF;
  END IF; -- MIN_ACCT_UNIT_DOC IS NOT NULL

  -- Accounted_Dr, Entered_Dr, NR_Tax, Rec_Tax
  -- Use Functional Currency to Round the amounts obtained above.
  l_stmt_num := 130;
  IF ( L_CURR_REC.MIN_ACCT_UNIT_FUNC IS NOT NULL ) THEN
    L_RCV_AE_LINE.ACCOUNTED_DR      := ROUND (L_RCV_AE_LINE.ACCOUNTED_DR / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
    L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.ACCOUNTED_NR_TAX / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
    L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.ACCOUNTED_REC_TAX / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
  ELSE
    L_RCV_AE_LINE.ACCOUNTED_DR      := ROUND (L_RCV_AE_LINE.ACCOUNTED_DR, L_CURR_REC.PRECISION_FUNC);
    L_RCV_AE_LINE.ACCOUNTED_NR_TAX  := ROUND (L_RCV_AE_LINE.ACCOUNTED_NR_TAX, L_CURR_REC.PRECISION_FUNC);
    L_RCV_AE_LINE.ACCOUNTED_REC_TAX := ROUND (L_RCV_AE_LINE.ACCOUNTED_REC_TAX, L_CURR_REC.PRECISION_FUNC);
  END IF;
/* changes for Bug 6142658 Ends */

  -- Actual_Flag
  l_stmt_num := 140;
  IF ( L_RCV_AE_LINE.EVENT_TYPE_ID = RCV_SeedEvents_PVT.ENCUMBRANCE_REVERSAL ) THEN
    L_RCV_AE_LINE.ACTUAL_FLAG := 'E';
  ELSE
    L_RCV_AE_LINE.ACTUAL_FLAG := 'A';
  END IF;

  -- Accounted_Cr
  l_stmt_num := 150;
  L_RCV_AE_LINE.ACCOUNTED_CR :=  L_RCV_AE_LINE.ACCOUNTED_DR;

  -- Entered_Cr
  l_stmt_num := 160;
  L_RCV_AE_LINE.ENTERED_CR :=  L_RCV_AE_LINE.ENTERED_DR;

  -- One Time Item?
  l_stmt_num := 190;
  IF ( L_RCV_AE_LINE.INVENTORY_ITEM_ID IS NULL ) THEN
    l_one_time_item := 'Y';
  END IF;

  -- Get the parent transaction information
  -- Needed for determining accounting line type for certain transaction types

  l_stmt_num := 200;

  SELECT nvl(PARENT_TRANSACTION_ID, -1)
  INTO   l_parent_rcv_txn_id
  FROM   RCV_TRANSACTIONS
  WHERE  transaction_id = L_RCV_AE_LINE.RCV_TRANSACTION_ID;

  -- Get DESTINATION_TYPE_CODE from PO_DISTRIBUTIONS
  l_stmt_num := 205;

  SELECT DESTINATION_TYPE_CODE
  INTO   l_destination_type_code
  FROM   PO_DISTRIBUTIONS
  WHERE  PO_DISTRIBUTION_ID = L_RCV_AE_LINE.DOC_DISTRIBUTION_ID;

  -- Get the parent transaction_type
  l_stmt_num := 210;
  IF (l_parent_rcv_txn_id <> -1) THEN
     SELECT TRANSACTION_TYPE
     INTO   l_parent_txn_type
     FROM   RCV_TRANSACTIONS
     WHERE  transaction_id = l_parent_rcv_txn_id;
 END IF;


  -- Get the accounting line type
  l_stmt_num := 220;
  Get_AccountingLineType(
                p_api_version         => 1.0,
                x_return_status	      => l_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_event_type_id       => L_RCV_AE_LINE.EVENT_TYPE_ID,
                p_parent_txn_type     => l_parent_txn_type,
                p_proc_org_flag       => L_RCV_AE_LINE.PROCUREMENT_ORG_FLAG,
                p_one_time_item_flag  => l_one_time_item,
                p_destination_type    => l_destination_type_code,
                p_global_proc_flag    => L_RCV_AE_LINE.GLOBAL_PROC_FLAG,
                x_debit_line_type     => L_RCV_AE_LINE.DEBIT_LINE_TYPE,
                x_credit_line_type    => L_RCV_AE_LINE.CREDIT_LINE_TYPE
  );

  /* Support for Landed Cost Management */
  IF P_LCM_FLAG = 'Y' THEN
    L_RCV_INSP_ENTERED_VAL := (l_primary_qty * L_RCV_AE_LINE.UNIT_LANDED_COST) / L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

    IF ( L_CURR_REC.MIN_ACCT_UNIT_DOC IS NOT NULL ) THEN
     L_RCV_INSP_ENTERED_VAL := ROUND (L_RCV_INSP_ENTERED_VAL  / L_CURR_REC.MIN_ACCT_UNIT_DOC) * L_CURR_REC.MIN_ACCT_UNIT_DOC;
    ELSE
     L_RCV_INSP_ENTERED_VAL := ROUND (L_RCV_INSP_ENTERED_VAL, L_CURR_REC.PRECISION_DOC);
    END IF;

   L_RCV_INSP_ACCOUNTED_VAL := L_RCV_INSP_ENTERED_VAL  * L_RCV_AE_LINE.CURRENCY_CONVERSION_RATE;

   IF ( L_CURR_REC.MIN_ACCT_UNIT_FUNC IS NOT NULL ) THEN
    L_RCV_INSP_ACCOUNTED_VAL := ROUND (L_RCV_INSP_ACCOUNTED_VAL / L_CURR_REC.MIN_ACCT_UNIT_FUNC) * L_CURR_REC.MIN_ACCT_UNIT_FUNC;
   ELSE
    L_RCV_INSP_ACCOUNTED_VAL := ROUND (L_RCV_INSP_ACCOUNTED_VAL, L_CURR_REC.PRECISION_FUNC);
   END IF;

   /* Reset the Accounted /Entered Dr /Cr with the receiving value
      calculated at landed cost */
   IF L_RCV_AE_LINE.CREDIT_LINE_TYPE = RECEIVING_INSPECTION THEN
      L_RCV_AE_LINE.ACCOUNTED_CR := L_RCV_INSP_ACCOUNTED_VAL;
      L_RCV_AE_LINE.ENTERED_CR := L_RCV_INSP_ENTERED_VAL;

   ELSE
      L_RCV_AE_LINE.ACCOUNTED_DR := L_RCV_INSP_ACCOUNTED_VAL;
      L_RCV_AE_LINE.ENTERED_DR := L_RCV_INSP_ENTERED_VAL;

   END IF;

   /* The landed cost absorption account absorbs the difference between Receiving inspection
      and accrual value */
   L_RCV_AE_LINE.LDD_COST_ABS_ENTERED   := L_RCV_AE_LINE.ENTERED_CR - L_RCV_AE_LINE.ENTERED_DR;
   L_RCV_AE_LINE.LDD_COST_ABS_ACCOUNTED := L_RCV_AE_LINE.ACCOUNTED_CR - L_RCV_AE_LINE.ACCOUNTED_DR;

 END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_api_message := 'Error in getting Accounting Line Type';
    IF G_DEBUG = 'Y' THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||
'.'||l_api_name||l_stmt_num ,'Create_AccountingEntry: '||l_stmt_num||' : '||l_api_message);
      END IF;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Insert Accounting Lines in the Sub Ledger
  l_stmt_num := 240;
  Insert_SubLedgerLines(
                p_api_version         => 1.0,
              x_return_status      => l_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_rcv_ae_line         => l_rcv_ae_line,
                p_glinfo              => l_glinfo
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_api_message := 'Error inserting into RCV_RECEIVING_SUB_LEDGER';
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||
'.'||l_api_name||l_stmt_num ,'Create_AccountingEntry: '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- Raise the SLA event
  l_trx_info.TRANSACTION_ID      := L_RCV_AE_LINE.RCV_TRANSACTION_ID;
  l_trx_info.ACCT_EVENT_ID       := L_RCV_AE_LINE.ACCOUNTING_EVENT_ID;
  l_trx_info.ACCT_EVENT_TYPE_ID  := L_RCV_AE_LINE.EVENT_TYPE_ID;
  l_trx_info.TRANSACTION_DATE    := L_RCV_AE_LINE.TRANSACTION_DATE;
  l_trx_info.INV_ORGANIZATION_ID := L_RCV_AE_LINE.ORGANIZATION_ID;
  l_trx_info.OPERATING_UNIT      := L_RCV_AE_LINE.ORG_ID;
  l_trx_info.LEDGER_ID           := L_RCV_AE_LINE.SET_OF_BOOKS_ID;


  IF L_RCV_AE_LINE.EVENT_TYPE_ID = 3 THEN
    l_trx_info.ATTRIBUTE := l_parent_txn_type;
  END IF;

  l_stmt_num := 250;


  l_trx_info.ENCUMBRANCE_FLAG := 'N';

  IF L_RCV_AE_LINE.GLOBAL_PROC_FLAG = 'N' THEN

    l_stmt_num := 260;

    SELECT nvl(purch_encumbrance_flag, 'N')
    INTO   l_trx_info.ENCUMBRANCE_FLAG
    FROM   financials_system_params_all
    WHERE  set_of_books_id = l_rcv_ae_line.set_of_books_id
    AND    org_id          = l_rcv_ae_line.org_id;

    IF G_DEBUG = 'Y' THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_api_message := 'Encumbrance Flag: '||l_trx_info.ENCUMBRANCE_FLAG;
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,G_LOG_HEAD||'.'||l_api_name||'.'||l_stmt_num ,l_api_message);
      END IF;
    END IF;
  END IF;

  l_stmt_num := 260;

  CST_XLA_PVT.Create_RCVXLAEvent(
    p_api_version      => 1.0,
    p_init_msg_list    => FND_API.G_FALSE,
    p_commit           => FND_API.G_FALSE,
    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
    x_return_status    => l_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_trx_info         => l_trx_info);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_api_message := 'Error raising SLA Event';
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD ||
'.'||l_api_name||l_stmt_num ,'Create_AccountingEntry: '||l_stmt_num||' : '||l_api_message);
       END IF;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF G_DEBUG = 'Y' THEN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
,'Create_AccountingEntry >>');
     END IF;
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO RCV_CreateAccounting_PVT;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
             );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO RCV_CreateAccounting_PVT;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
         );
  WHEN NO_RAE_DATA THEN
    ROLLBACK TO RCV_CreateAccounting_PVT;
    IF G_DEBUG = 'Y' THEN
       l_api_message := 'No Data in RAE for Transaction';
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num, 'Create_AccountingEntry : '||l_stmt_num||' : '||SUBSTR(sqlerrm,1,200));
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'No Data in RAE for Transaction'||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
         );
  WHEN NO_CURRENCY_INFORMATION THEN
    ROLLBACK TO RCV_CreateAccounting_PVT;
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num, 'No Data in FND_CURRENCIES for Currency Specified : '||l_stmt_num||' : '||SUBSTR(sqlerrm,1,200));
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'No Data in FND_CURRENCIES for Currency Specified'||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
         );

  WHEN NO_PO_INFORMATION THEN
    ROLLBACK TO RCV_CreateAccounting_PVT;
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num, 'No Data in PO Tables for the Transaction : '||l_stmt_num||' : '||SUBSTR(sqlerrm,1,200));
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            'No Data in PO Tables for the Transaction'||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
         );


  WHEN OTHERS THEN
    ROLLBACK TO RCV_CreateAccounting_PVT;
    IF G_DEBUG = 'Y' THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num, 'Create_AccountingEntry : '||l_stmt_num||' : '||SUBSTR(sqlerrm,1,200));
       END IF;
    END IF;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name       => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text     => 'Error at: '||
                            to_char(l_stmt_num) || ' '||
                            SQLERRM
      );

    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
         (  p_count  => x_msg_count
          , p_data   => x_msg_data
         );

END Create_AccountingEntry;
END RCV_CreateAccounting_PVT;

/
