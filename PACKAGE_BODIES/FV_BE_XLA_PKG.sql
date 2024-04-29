--------------------------------------------------------
--  DDL for Package Body FV_BE_XLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BE_XLA_PKG" AS
/* $Header: FVBEXLAB.pls 120.13.12010000.3 2009/10/08 20:33:45 snama ship $ */

G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME      CONSTANT VARCHAR2(50) :='FV.PLSQL.FV_BE_XLA_PKG.';


----------------------------------------------------------------
-- Definition of Accounting Event Entities, Classes and Types.
----------------------------------------------------------------

--Budget Execution Entity

  BE_ENTITY CONSTANT VARCHAR2(30)              := 'BE_TRANSACTIONS';

  BE_CLASS CONSTANT VARCHAR2(30)               := 'BUDGET_EXECUTION';

  BUDGET_AUTHORITY_TYPE CONSTANT VARCHAR2(30)  := 'BA_RESERVE';
  FUND_DISTRIBUTION_TYPE CONSTANT VARCHAR2(30) := 'FD_RESERVE';

--Reprogram Budget Execution Entity

  BE_RPR_ENTITY CONSTANT VARCHAR2(30)              := 'BE_RPR_TRANSACTIONS';

  BE_RPR_CLASS CONSTANT VARCHAR2(30)               := 'RPR_BUDGET_EXECUTION';

  RPR_BUDGET_AUTHORITY_TYPE CONSTANT VARCHAR2(30)  := 'RPR_BA_RESERVE';
  RPR_FUND_DISTRIBUTION_TYPE CONSTANT VARCHAR2(30) := 'RPR_FD_RESERVE';

----------------------------------------------------------------
--                  Global varibales declaration
----------------------------------------------------------------

--Event class variable
  g_event_class VARCHAR2(30);

--Application_id variables
  g_application_id FND_APPLICATION.APPLICATION_ID%TYPE;

  g_event_type VARCHAR2(30);
  g_doc_type   VARCHAR2(80);
  g_entity_code   VARCHAR2(80);
  g_doc_id     NUMBER;
  g_entity_id  NUMBER;
  g_ledger_id  GL_LEDGERS.LEDGER_ID%TYPE;
  g_accounting_date DATE;

----------------------------------------------------------------
--                   AOL User and Resp id
----------------------------------------------------------------

  g_user_id FND_USER.USER_ID%TYPE;
  g_user_resp_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

----------------------------------------------------------------
--       Defintions of Private functions/procedures
----------------------------------------------------------------

-- Definition of create_be_acct_event function(private)

   FUNCTION create_be_acct_event  (p_calling_sequence  IN   VARCHAR2)
   RETURN INTEGER;

-- Definition of get_event_source_info function (private)

  FUNCTION get_event_source_info
  RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

-- Defintion of stamping the event_id of the transaction
  PROCEDURE stamp_event(p_event_id XLA_EVENTS.EVENT_ID%TYPE);

-- Definition of reset event_id of the transaction
  PROCEDURE reset_event(p_event_id XLA_EVENTS.EVENT_ID%TYPE);

-- Definition of populate_bc_events_tab (private)
  PROCEDURE populate_bc_events_tab;


/*============================================================================
 |  PROCEDURE -  BUDGETARY_CONTROL (PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is for creating accounting events and invoke BC API for
 |    user actions i.e., Check and Approve the BE transactions
 |
 |  PRAMETERS
 |  IN :
 |          p_ledger_id : Ledger Id of the document
 |          p_doc_id    : Doc_id for BE Transactions
 |                        Transaction_id for Reprogrm BE Transactions
 |          p_doc_type  : Possible values:
 |                       'BE_TRANSACTIONS', 'BE_RPR_TRANSACTIONS'
 |          p_event_type: Possible values:
 |                       'BA_RESERVE,'FD_RESERVE',RPR_BA_RESERVE'
 |                        and 'RPR_FD_RESERVE'
 |          p_accounting_date : Accounting Date
 |          p_bc_mode   : Possible values:
 |                        C - Funds Check, R - Funds Reserve
 |          p_calling_sequence : debug information
 |
 | OUT:
 |          x_return_status: Possible values
 |                           S- Success,E- Error,U- Unexpected
 |          x_status_code :  Possible values
 |                           XLA_ERROR,FAIL,RFAIL,FATAL,PARTIAL,ADVISORY
 |                           and SUCCESS
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 *===========================================================================*/

  PROCEDURE BUDGETARY_CONTROL (p_ledger_id        IN NUMBER
                              ,p_doc_id           IN NUMBER
                              ,p_doc_type         IN VARCHAR2
                              ,p_event_type       IN VARCHAR2
                              ,p_accounting_date  IN DATE
                              ,p_bc_mode          IN VARCHAR2 DEFAULT NULL
                              ,p_calling_sequence IN VARCHAR2
                              ,x_return_status    OUT NOCOPY VARCHAR2
                              ,x_status_code      OUT NOCOPY VARCHAR2)
  IS

  l_calling_sequence VARCHAR2(2000);
  l_module_name VARCHAR2(1000);

  l_event_id XLA_EVENTS.EVENT_ID%TYPE;

  l_msg_data      VARCHAR2(1000);
  l_msg_count     NUMBER;
  l_api_version   VARCHAR2(100);
  l_init_msg_list VARCHAR2(1000);
  l_bc_mode       VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_status_code   VARCHAR2(100);
  l_packet_id     GL_BC_PACKETS.PACKET_ID%TYPE;

  BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Start with FV_BE_XLA_PKG.Budgetary_Control');

   l_calling_sequence := p_calling_sequence ||
                             ' -> FV_BE_XLA_PKG.BUDGETARY_CONTROL';

   l_module_name := G_MODULE_NAME ||'BUDGETARY_CONTROL';

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                        'procedure budgetary_control starts.');
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                 'l_calling_sequence -> '||l_calling_sequence);

     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Parameter values');

     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'p_ledger_id -> '
                                                          ||p_ledger_id);
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'p_doc_id  -> '
                                                          ||p_doc_id);
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'p_doc_type -> '
                                                          ||p_doc_type);
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'p_event_type -> '
                                                          ||p_event_type);
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'p_accounting_date->'
                                                          ||p_accounting_date);
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'p_bc_mode -> '
                                                          ||p_bc_mode);
   END IF;

 -- Assign the parameters to the local variables
   g_application_id := 8901;
   g_doc_type		:= p_doc_type;
   g_event_type		:= p_event_type;
   g_doc_id	        := p_doc_id;
   g_ledger_id		:= p_ledger_id;
   g_accounting_date:= p_accounting_date;
   l_bc_mode    	:= p_bc_mode;

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Input Parameter values...');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_application_id -->'||g_application_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_doc_type -->'||g_doc_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_event_type -->'||g_event_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_doc_id -->'||g_doc_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_ledger_id -->'||g_ledger_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'g_accounting_date -->'||g_accounting_date);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'l_bc_mode -->'||l_bc_mode);


   IF l_bc_mode ='C' THEN
    l_init_msg_list := FND_API.G_TRUE;
   ELSIF l_bc_mode ='R' THEN
    l_init_msg_list := FND_API.G_FALSE;
   END IF;

   --assign AOL user and responsibilty values to global variable
   g_user_id         := FND_GLOBAL.USER_ID;
   g_user_resp_id    := FND_GLOBAL.RESP_ID;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                             'call Create_be_acct_event');
    END IF;
 -- Invoke Create_be_acct_event
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoke Create_BE_Acct_Event() ');

   l_event_id := create_be_acct_event(p_calling_sequence => l_calling_sequence);

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_event_id -->'||l_event_id);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'l_event_id -> '||
                                                            l_event_id);
    END IF;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                             'call populate_bc_events_tab');
    END IF;

 -- Insert into psa_bc_xla_events_gt
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoke populate_bc_events() ');
    populate_bc_events_tab;


    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'call BC PSA API');
    END IF;


 -- call PSA Budgetary Control API
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoke PSA_BC_XLA_PUB.Budgetary_Control() ');

   PSA_BC_XLA_PUB.Budgetary_Control (p_api_version    => 1.0
                     ,p_init_msg_list  => l_init_msg_list
                     ,x_return_status  => l_return_status
                     ,x_msg_count      => l_msg_count
                     ,x_msg_data       => l_msg_data
                     ,p_application_id => g_application_id
                     ,p_bc_mode        => l_bc_mode
                     ,p_override_flag  => 'Y'
                     ,p_user_id        => g_user_id
                     ,p_user_resp_id   => g_user_resp_id
                     ,x_status_code    => l_status_code
                     ,x_packet_id      => l_packet_id);

    IF l_status_code IN ('SUCCESS','PARTIAL','ADVISORY') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PSA Budgetary Control API Success');
    ELSIF l_status_code = 'XLA_ERROR' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PSA BC API failed with XLA_ERROR');
    ELSIF l_status_code IN ('FAIL','RFAIL','FATAL') THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PSA BC API failed with some technical problem');
    ELSIF l_status_code = 'XLA_NO_JOURNAL' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PSA BC API success but with NO SLA Journal ');
    ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PSA BC API failed with unknown error');
    END IF;

 -- Assign the local status values to the return variables
    x_status_code   := l_status_code;
    x_return_status := l_return_status;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get(p_count => l_msg_count,p_data=>l_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.count_and_get(p_count => l_msg_count,p_data=>l_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(G_MODULE_NAME, 'PSA_BC_XLA_PVT');
       END IF;

       FND_MSG_PUB.count_and_get(p_count=>l_msg_count,p_data=>l_msg_data);

  END BUDGETARY_CONTROL;

/*============================================================================
 |  FUNCTION -  CREATE_BE_ACCT_EVENT (PRIVATE)
 |
 |  DESCRIPTION
 |    This function is for the creation of all events resulting from user
 |    actions i.e., Check and Approve the BE transactions
 |
 |  PARAMETERS
 |    IN
 |          p_calling_sequence : For Debug purpose
 |
 |  RETURN : INTEGER
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 *===========================================================================*/

FUNCTION CREATE_BE_ACCT_EVENT (p_calling_sequence IN VARCHAR2)
RETURN INTEGER
IS


-- Cursor to pull Event_Id for Delete_Events API for accounting_date change
	Cursor fv_be_event_id IS
		SELECT distinct fvbe.event_id,xlae.event_date
		FROM fv_be_trx_dtls FVBE, xla_events XLAE
		WHERE FVBE.doc_id = g_doc_id
		AND FVBE.event_id = XLAE.event_id
		AND FVBE.gl_date <> XLAE.event_date
        AND FVBE.transaction_status <> 'AR'
        AND fvbe.approval_date is null
        UNION
        SELECT  distinct fvbe.event_id,xlae.event_date
		FROM fv_be_rpr_transactions FVBE, xla_events XLAE
		WHERE FVBE.transaction_id = g_doc_id
		AND FVBE.event_id = XLAE.event_id
		AND FVBE.gl_date <> XLAE.event_date
        AND FVBE.transaction_status <> 'AR';


-- Cursor to pull gl_date from FV_BE_TRX_DTLS table for doc_id passed
	Cursor fv_be_gl_date IS
		SELECT distinct fvbe.gl_date,fvbe.event_id
		FROM fv_be_trx_dtls FVBE
		WHERE FVBE.doc_id = g_doc_id
                AND fvbe.approval_date is null
        UNION
        SELECT distinct fvbe.gl_date,fvbe.event_id
		FROM fv_be_rpr_transactions FVBE
		WHERE FVBE.transaction_id = g_doc_id;


  l_module_name VARCHAR(1000);
  l_event_id INTEGER;

  -- XLA event source plsql table definition

  l_event_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

  l_entity_deleted  INTEGER;

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Begin Create_BE_Acct_event function');

  l_module_name := G_MODULE_NAME ||'CREATE_BE_ACCT_EVENTS';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                               'Create_be_acct_events start..');
  END IF;

 --Assign the event source info from transactions

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                       'Call get_event_source_info function');
  END IF;

  l_event_source_info := get_event_source_info;

  l_event_security_context.security_id_int_1 := NULL;


-- STEP#1 -DELETING EVENTS ---
-- Invoke DELETE_EVENT to delete the events fetched in the cursor
	BEGIN
		FOR fv_be_event_id_Rec in fv_be_event_id
		LOOP
			l_event_id := fv_be_event_id_Rec.event_id;
			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
					FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Call Delete_Event API');
			END IF;

                         IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    				FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                               'Check if event exists before deleteion for event:'||l_event_id);
		  	END IF;
                        IF XLA_EVENTS_PUB_PKG.EVENT_EXISTS
                                     (p_event_source_info => l_event_source_info
                                     ,p_event_class_code  => g_event_class
                                     ,p_event_type_code   => g_event_type
                                     ,p_event_date        => fv_be_event_id_Rec.event_date
                                     ,p_event_status_code => NULL
                                     ,p_event_number      => NULL
                                     ,p_valuation_method  => NULL
                                     ,p_security_context  => l_event_security_context) THEN
			 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                        FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Call Delete_Event API:'||l_event_id);
                        END IF;
			XLA_EVENTS_PUB_PKG.DELETE_EVENT
                                   (p_event_source_info	=> l_event_source_info
                                   ,p_event_id				=> l_event_id
                                   ,p_valuation_method  	=> NULL
                  				   ,p_security_context		=> l_event_security_context);
			 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                        FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Call Delete_Entity API:'||l_event_id);
                        END IF;

			 l_entity_deleted := XLA_EVENTS_PUB_PKG.delete_entity
                                   (p_source_info	=> l_event_source_info
                                    ,p_valuation_method  	=> NULL
                                    ,p_security_context		=> l_event_security_context);

			 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                        FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Reset event_id:'||l_event_id);
                        END IF;

                         reset_event(l_event_id);

            		END IF;
		END LOOP;
	END;



-- STEP#2 - Find whether accounting_date changed and create/update events
-- Loop the cursor through gl_date

	BEGIN

		FOR fv_be_gl_date_Rec in fv_be_gl_date
		LOOP
			g_accounting_date := fv_be_gl_date_Rec.gl_date;

               IF  NOT XLA_EVENTS_PUB_PKG.EVENT_EXISTS
                                     (p_event_source_info => l_event_source_info
                                     ,p_event_class_code  => g_event_class
                                     ,p_event_type_code   => g_event_type
                                     ,p_event_date        => g_accounting_date
                                     ,p_event_status_code => NULL
                                     ,p_event_number      => NULL
                                     ,p_valuation_method  => NULL
                                     ,p_security_context  => l_event_security_context)  OR
                        	fv_be_gl_date_Rec.event_id IS NULL THEN
			-- Create Event
				IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
 					FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Call xla_events_pub_pkg.create_event');
		 		END IF;
				l_event_id := XLA_EVENTS_PUB_PKG.CREATE_EVENT
                                    (p_event_source_info => l_event_source_info
                                    ,p_event_type_code   => g_event_type
                                    ,p_event_date        => g_accounting_date
                                    ,p_event_status_code => 'U'
                                    ,p_transaction_date  => NULL
                                    ,p_reference_info    => NULL
                                    ,p_event_number      => NULL
                                    ,p_valuation_method  => NULL
                                    ,p_security_context  => l_event_security_context
                                    ,p_budgetary_control_flag => 'Y');
             ELSE
				l_event_id := fv_be_gl_date_Rec.event_id;
                 END IF;
                 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                                        FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,'Event_id:'||l_event_id);
                 END IF;

                 IF(l_event_id IS NOT NULL) THEN
			-- Stamp Event in FV_BE_TRX_DTLS/FV_BE_RPR_TRANSACTIONS table
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Invoke Stamp_Event()');
			   stamp_event(l_event_id);
	       END IF;
		END LOOP;
	END;
FND_FILE.PUT_LINE(FND_FILE.LOG,'End of Create_BE_Acct_Event');

return l_event_id;

END CREATE_BE_ACCT_EVENT;

 /*============================================================================
 |  FUNCTION  -  GET_BE_EVENT_SOURCE_INFO(PRIVATE)
 |
 |  DESCRIPTION
 |    This function is used to get Budget Execution event source information
 |
 |  PARAMETERS:
 |    IN
 |         p_ledger_id: Ledger ID
 |         p_doc_id   : Document ID
 |         p_calling_sequence: Debug information
 |
 |  RETURN: XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 *===========================================================================*/
 FUNCTION get_event_source_info
 RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
 IS

  l_doc_num VARCHAR2(50);
  l_prepare_stmt VARCHAR2(1000);
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_module_name VARCHAR2(1000);

 BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Begin Get_Event_Source_Info');

   l_module_name := G_MODULE_NAME ||'GET_EVENT_SOURCE_INFO';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                                 'get_event_source_info start..');
  END IF;

   l_prepare_stmt := 'SELECT DOC_NUMBER FROM ';

    IF g_doc_type = BE_ENTITY THEN

      l_prepare_stmt := l_prepare_stmt ||'FV_BE_TRX_HDRS WHERE DOC_ID  = :1';
      l_event_source_info.entity_type_code := BE_ENTITY;
      g_event_class := BE_CLASS;

    ELSIF g_doc_type = BE_RPR_ENTITY THEN

      l_prepare_stmt := l_prepare_stmt ||'FV_BE_RPR_TRANSACTIONS WHERE TRANSACTION_ID = :1';
      l_event_source_info.entity_type_code := BE_RPR_ENTITY;
      g_event_class := BE_RPR_CLASS;

    END IF;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name||'get_event_source_info start..');
    END IF;

    EXECUTE IMMEDIATE l_prepare_stmt INTO l_doc_num USING g_doc_id;

    l_event_source_info.transaction_number := l_doc_num;
    l_event_source_info.application_id     := g_application_id;
    l_event_source_info.ledger_id          := g_ledger_id;
    l_event_source_info.source_id_int_1    := g_doc_id;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'End Get_Event_Source_Info');

    RETURN l_event_source_info;

 END get_event_source_info;

  /*============================================================================
 |  PROCEDURE  -  POPULATE_BC_EVENTS_TAB(PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to insert event into psa_bc_xla_events_gt table
 |
 |  PRAMETERS:
 |            NULL
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 *===========================================================================*/

 PROCEDURE populate_bc_events_tab
 IS
 BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Begin Populate_BC_Events_Tab');

  IF g_doc_id is null THEN
   RETURN;
  ELSE
    IF g_doc_type = BE_ENTITY THEN
      INSERT INTO psa_bc_xla_events_gt(event_id,result_code)
      SELECT distinct event_id,'XLA_ERROR'
      FROM FV_BE_TRX_DTLS
      WHERE doc_id = g_doc_id
      AND transaction_status <> 'AR'
      AND approval_date IS NULL;
    ELSIF g_doc_type = BE_RPR_ENTITY THEN
     INSERT INTO psa_bc_xla_events_gt(event_id,result_code)
     SELECT distinct event_id,'XLA_ERROR' FROM FV_BE_RPR_TRANSACTIONS WHERE transaction_id = g_doc_id;
    END IF;
  END IF;
 FND_FILE.PUT_LINE(FND_FILE.LOG,'End Populate_BC_Events_Tab');
 END populate_bc_events_tab;

  /*=========================================================================
 |  PROCEDURE  -  STAMP_EVENT(PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to stamp event_id in the transactions table
 |
 |  PRAMETERS:
 |    IN
 |         p_event_id: Event ID
 |
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 *===========================================================================*/

  PROCEDURE stamp_event(p_event_id XLA_EVENTS.EVENT_ID%TYPE)
  IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Begin Stamp_Event');

    IF g_doc_type = BE_ENTITY THEN
      UPDATE FV_BE_TRX_DTLS
      SET EVENT_ID  = p_event_id
      WHERE doc_id  = g_doc_id
      AND   gl_date = g_accounting_date
      AND   transaction_status <> 'AR'
      AND   approval_date IS NULL;

    ELSIF g_doc_type = BE_RPR_ENTITY THEN
      UPDATE FV_BE_RPR_TRANSACTIONS
      SET EVENT_ID  = p_event_id
      WHERE transaction_id = g_doc_id
      AND   gl_date        = g_accounting_date;
    END IF;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows ->'||SQL%ROWCOUNT||' updated with event_id ->'||p_event_id);

  FND_FILE.PUT_LINE(FND_FILE.LOG,'End Stamp_Event');

  END stamp_event;

/*============================================================================
|    PROCEDURE   - RESET_EVENT(PRIVATE)
|
|    Description:
|       This procedure resets the event_id to null for deleted events.
|
|    Parameters:
|      IN
|           p_event_id: Event ID
|  KNOWN ISSUES:
|
|  NOTES:
*===========================================================================*/


 PROCEDURE reset_event(p_event_id XLA_EVENTS.EVENT_ID%TYPE)
  IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Begin Reset_Event');

    IF g_doc_type = BE_ENTITY THEN
      UPDATE FV_BE_TRX_DTLS
      SET EVENT_ID  = null
      WHERE doc_id  = g_doc_id
      AND   event_id = p_event_id;

    ELSIF g_doc_type = BE_RPR_ENTITY THEN
      UPDATE FV_BE_RPR_TRANSACTIONS
      SET EVENT_ID  = null
      WHERE transaction_id = g_doc_id
      AND   event_id      =  p_event_id;
    END IF;
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows ->'||SQL%ROWCOUNT||' updated with null event_id ');

  FND_FILE.PUT_LINE(FND_FILE.LOG,'End Reset_Event');

  END reset_event;

   Function GET_CCID(application_short_name  IN  Varchar2
		    ,key_flex_code	     IN  Varchar2
		    ,structure_number	     IN  Number
		    ,validation_date	     IN  Date
		    ,concatenated_segments   IN  Varchar2) Return Number Is
      l_date            date;
      l_delim           varchar2(1);
      l_num             number;
      l_segarray        fnd_flex_ext.segmentarray;
      l_ccid	        number;
      l_data_set        number;
      l_module_name     varchar2(1000);
   Begin
      l_module_name := G_MODULE_NAME ||'GET_CCID';
      If (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) Then
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'GET_CCID Parameters ' );
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Application Short Name ' || application_short_name );
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Flex Code ' || key_flex_code);
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Chart of Account Id ' || structure_number );
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Concatenated Segments ' || concatenated_segments);
      End If;

      l_date := validation_date;
      l_delim := fnd_flex_ext.get_delimiter(
                    application_short_name
                    ,key_flex_code
                    ,structure_number);
      FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name, 'Delimiter ' || l_delim);

      l_num :=  fnd_flex_ext.breakup_segments(
                   concatenated_segments
                   ,l_delim
                   ,l_segarray);
      If (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) Then
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name, 'No of Segments ' || l_num);
      End If;

      If fnd_flex_ext.get_combination_id(
	    application_short_name => application_short_name
	    ,key_flex_code         => key_flex_code
	    ,structure_number	   => structure_number
	    ,validation_date	   => l_date
	    ,n_segments	           => l_num
	    ,segments    	   => l_segarray
	    ,combination_id        => l_ccid
            ,data_set  => l_data_set) Then
            If (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) Then
                  FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                                        'Code Combination Id fetched ' || l_ccid);
            End If;
            Return (l_ccid);
      End If;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Code Combination Id cannot be fetched returning 0 ');
      End If;
      Return (0);
   Exception
      When Others Then
         If (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Exception encountered returning 0 ');
            FV_UTILITY.DEBUG_MESG(G_LEVEL_PROCEDURE,l_module_name,
                               'Exception ' || sqlerrm);
         End If;
         Return(0);
   End GET_CCID;
END FV_BE_XLA_PKG;

/
