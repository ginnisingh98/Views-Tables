--------------------------------------------------------
--  DDL for Package Body PO_DRAFT_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DRAFT_EVENTS_PKG" AS
/* $Header: PO_DRAFT_EVENTS_PKG.plb 120.0.12010000.3 2012/09/01 01:57:12 sbontala noship $*/

g_pkg_name                       CONSTANT
   VARCHAR2(30)
   := 'PO_DRAFT_EVENTS_PKG';

g_log_head                       CONSTANT
   VARCHAR2(50)
   := 'po.plsql.' || g_pkg_name || '.';


g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;


-------------------------------------------------------------------------------
  --Start of Comments
  --Name: delete_draft_events
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  -- This procedure will be used to delete invalid/draft events
  -- for all PO,PA and Requistion encumbrance events
  --Parameters:
  --IN:
  --  p_init_msg_list
  --  p_ledger_id
  --  p_start_date
  --  p_end_date
  --  p_calling_sequence
  --  p_currency_code_func: currency code of the functional currency.
  --IN OUT:
  --  None.
  --OUT:
  --  x_return_status
  --  x_msg_count
  --  x_msg_data
  --Notes:
  --  This procedure will be called from PSA BC optimizer to delete
  -- invalid/draft encumbrance events. This is required to avoid showing
  -- in subledger exception report.
  --Testing:
  --
  --End of Comments
  -------------------------------------------------------------------------------
PROCEDURE delete_draft_events (
			    p_init_msg_list    IN VARCHAR2,
			    p_ledger_id        IN NUMBER,
			    p_start_date       IN DATE,
			    p_end_date         IN DATE,
			    p_calling_sequence IN VARCHAR2,
			    x_return_status    OUT NOCOPY VARCHAR2,
			    x_msg_count        OUT NOCOPY NUMBER,
			    x_msg_data         OUT NOCOPY VARCHAR2
			  ) IS

CURSOR c_get_unprocessed_events IS
  SELECT DISTINCT xe.event_id,
     xe.event_type_code,
     xe.event_date,
     xe.event_status_code,
     xe.process_status_code,
     xte.entity_id,
     xte.legal_entity_id,
     xte.entity_code,
     xte.source_id_int_1,
     xte.source_id_int_2,
     xte.source_id_int_3,
     xte.source_id_int_4,
     xte.source_id_char_1
 FROM xla_transaction_entities xte,
      xla_events  xe
 WHERE NVL(xe.budgetary_control_flag, 'N') ='Y'
   AND xte.entity_code IN ('REQUISITION','PURCHASE_ORDER','RELEASE')
   AND xte.application_id = 201
   AND xe.application_id =xte.application_id
   AND xte.entity_id =  xe.entity_id
   AND xe.EVENT_STATUS_CODE  in ('U' ,'I')
   AND xe.PROCESS_STATUS_CODE  IN ('I','D')
   AND xte.ledger_id =  p_ledger_id
   AND xe.event_date BETWEEN p_start_date AND p_end_date;

   TYPE Event_tab_type IS TABLE OF XLA_EVENTS_INT_GT%ROWTYPE INDEX BY BINARY_INTEGER;
    l_events_Tab        Event_tab_type;
    l_event_count       NUMBER;


    l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_DRAFT_EVENTS';
    l_log_head     CONSTANT VARCHAR2(200) := g_log_head || l_api_name;
    l_curr_calling_sequence VARCHAR2(2000);
    l_progress              VARCHAR2(3);

 BEGIN

   fnd_file.put_line(fnd_file.log ,'>> PO_DRAFT_EVENTS_PKG.DELETE_DRAFT_EVENTS');

   l_progress := '000';

   IF g_debug_stmt THEN

     PO_DEBUG.debug_begin(l_log_head);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_ledger_id',p_ledger_id);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_start_date',p_start_date);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_end_date',p_end_date);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_calling_sequence',p_calling_sequence);

   END IF;

   IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
     Fnd_Msg_Pub.Initialize;
   END IF;

   l_curr_calling_sequence := l_log_head||'<-'||p_calling_sequence;

   xla_security_pkg.set_security_context(602); --passing SLA application_id

   l_progress := '001';

   DELETE FROM XLA_EVENTS_INT_GT;

   IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(l_log_head,l_progress,'# Rows deleted from xla_events_int_gt'|| SQL%ROWCOUNT );
   END IF;

   l_progress := '002';

   l_event_count := 0;
   FOR rec_events IN c_get_unprocessed_events
   LOOP
     l_event_count := l_event_count+1;
     l_events_tab(l_event_count).entity_id           := rec_events.entity_id;
     l_events_tab(l_event_count).application_id      := 201;
     l_events_tab(l_event_count).ledger_id           := p_ledger_id;
     l_events_tab(l_event_count).legal_entity_id     := rec_events.legal_entity_id;
     l_events_tab(l_event_count).entity_code         := rec_events.entity_code;
     l_events_tab(l_event_count).event_id            := rec_events.event_id;
     l_events_tab(l_event_count).event_status_code   := rec_events.event_status_code;
     l_events_tab(l_event_count).process_status_code := rec_events.process_status_code;
     l_events_tab(l_event_count).source_id_int_1     := rec_events.source_id_int_1;
   END LOOP;

   l_progress := '003';

   IF l_event_count > 0 THEN

     FORALL i IN 1..l_event_count
       INSERT INTO XLA_EVENTS_INT_GT
       VALUES l_events_tab(i) ;

     IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(l_log_head,l_progress,'#Rows inserted into xla_events_int_gt table:' || l_event_count);
     END IF;

   END IF;

   l_progress := '004';

   IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENT ');
   END IF;

   XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENTS(p_application_id => 201);

   IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Deletion of Unprocessed Events');
   END IF;

   fnd_file.put_line(fnd_file.log ,'The following BC unprocessed/Error events have been deleted');
   fnd_file.put_line(fnd_file.log ,'Event_id  Event_status_code Process_status_code');
   fnd_file.put_line(fnd_file.log ,'--------- ----------------- -------------------');

   FOR i IN 1..l_event_count  LOOP
     fnd_file.put_line(fnd_file.log ,l_events_tab(i).event_id||'        '||
     l_events_tab(i).event_status_code   ||'                    '||
     l_events_tab(i).process_status_code);
   END LOOP;

   fnd_file.put_line(fnd_file.log ,'Count of BC events deleted:' || l_event_count);
   fnd_file.put_line(fnd_file.log ,'>> PO_DRAFT_EVENTS_PKG.DELETE_DRAFT_EVENTS');

   l_progress := '005';

   IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(l_log_head,l_progress,'Deleting the events from po_bc_distributions');
   END IF;

   FORALL i in 1..l_event_count
     DELETE FROM po_bc_distributions
      WHERE ae_event_id = l_events_tab(i).event_id;

   x_return_status := Fnd_Api.G_Ret_Sts_Success;

   IF g_debug_stmt THEN
     PO_DEBUG.debug_end(l_log_head);
   END IF;

 EXCEPTION
   WHEN OTHERS THEN

     IF g_debug_unexp THEN
       PO_DEBUG.debug_exc(l_log_head,l_progress);
     END IF;

     x_return_status := Fnd_Api.G_Ret_Sts_Error;

     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','PO_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
     END IF;

     Fnd_Msg_Pub.Count_And_Get
      (
      p_count   => x_msg_count,
      p_data    => x_msg_data
      );

     po_message_s.sql_error(g_pkg_name, l_api_name, l_progress, SQLCODE, SQLERRM);
     fnd_msg_pub.add;
     RAISE;
END delete_draft_events;

END PO_DRAFT_EVENTS_PKG;

/
