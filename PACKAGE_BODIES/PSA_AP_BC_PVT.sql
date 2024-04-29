--------------------------------------------------------
--  DDL for Package Body PSA_AP_BC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_AP_BC_PVT" AS
--$Header: psavapbb.pls 120.49.12010000.23 2010/01/27 09:29:31 cjain ship $

  g_state_level NUMBER          :=    FND_LOG.LEVEL_STATEMENT;
  g_proc_level  NUMBER          :=    FND_LOG.LEVEL_PROCEDURE;
  g_event_level NUMBER          :=    FND_LOG.LEVEL_EVENT;
  g_excep_level NUMBER          :=    FND_LOG.LEVEL_EXCEPTION;
  g_error_level NUMBER          :=    FND_LOG.LEVEL_ERROR;
  g_unexp_level NUMBER          :=    FND_LOG.LEVEL_UNEXPECTED;
  g_full_path CONSTANT VARCHAR2(50) :='psa.plsql.psavapbb.psa_ap_bc_pvt';
  /*=============================================================================
   |Private Procedure Specifications
   *===========================================================================*/
  FUNCTION get_event_security_context
  (
    p_org_id             IN NUMBER,
    p_calling_sequence   IN VARCHAR2
  ) RETURN XLA_EVENTS_PUB_PKG.T_SECURITY;

  FUNCTION get_event_type_code
  (
    p_inv_dist_id         IN NUMBER,
    p_invoice_type_code   IN VARCHAR2,
    p_distribution_type   IN VARCHAR2,
    p_distribution_amount IN NUMBER,
    p_calling_mode        IN VARCHAR2,
    p_bc_mode             IN VARCHAR2
  ) RETURN VARCHAR2;

  PROCEDURE init
  IS
    l_path_name       VARCHAR2(500);
    l_file_info       VARCHAR2(2000);
  BEGIN
    l_path_name := g_full_path || '.init';
    l_file_info :=
       '$Header: psavapbb.pls 120.49.12010000.23 2010/01/27 09:29:31 cjain ship $';
    psa_utils.debug_other_string(g_state_level,l_path_name,  'PSA_BC_XLA_PVT version = '||l_file_info);
  END;

  /*============================================================================
   |  PROCEDURE  -  DELETE_EVENTS
   |  Description - Delete the unprocessed BC events.
   |                Payables call this while sweeping the trxs to next period
   *===========================================================================*/

  PROCEDURE Delete_Events
  (
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
    SELECT xla.event_id,
           xla.event_type_code,
           xla.event_date,
           xla.event_status_code,
           xla.process_status_code,
           xte.entity_id,
           xte.legal_entity_id,
           xte.entity_code,
           xte.source_id_int_1,
           xte.source_id_int_2,
           xte.source_id_int_3,
           xte.source_id_int_4,
           xte.source_id_char_1
      FROM xla_events xla,
           xla_transaction_entities xte
     WHERE NVL(xla.budgetary_control_flag, 'N') ='Y'
       AND xla.application_id = 200
       AND xla.event_date BETWEEN p_start_date AND p_end_date
       AND xla.event_status_code in ('U','I')
       AND xla.process_status_code <> 'P' --Bug#6857834
       AND xla.entity_id = xte.entity_id
       AND xla.application_id = xte.application_id
       AND xte.ledger_id =  p_ledger_id;

    TYPE Event_tab_type IS TABLE OF XLA_EVENTS_INT_GT%ROWTYPE INDEX BY BINARY_INTEGER;
    l_events_Tab        Event_tab_type;
    l_event_count       NUMBER;

    l_curr_calling_sequence VARCHAR2(2000);
    l_log_msg               FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_debug_loc             VARCHAR2(30) := 'Delete_Events';
    l_api_name              VARCHAR2(240);

    l_event_source_info      xla_events_pub_pkg.t_event_source_info;
    l_valuation_method       VARCHAR2(30);
    l_security_context       xla_events_pub_pkg.t_security;
    l_return_status          VARCHAR2(1);

  BEGIN
    fnd_file.put_line(fnd_file.log ,'>> PSA_AP_BC_PVT.Delete_EVENTS');
    l_api_name := g_full_path||'.Delete_Events';
    -- Update the calling sequence --
    l_curr_calling_sequence := 'PSA_AP_BC_PVT.'||l_debug_loc||'<-'||p_calling_sequence;
    x_return_status := Fnd_Api.G_Ret_Sts_Success;
    IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
    END IF;
    psa_utils.debug_other_string(g_state_level,l_api_name, 'BEGIN of procedure Delete_Events..' );
    psa_utils.debug_other_string(g_state_level,l_api_name, 'p_ledger_id '||p_ledger_id);
    psa_utils.debug_other_string(g_state_level,l_api_name, 'p_start_date '|| p_start_date);
    psa_utils.debug_other_string(g_state_level,l_api_name, 'p_end_date '|| p_end_date);
    --setting xla security context to use table xla_transaction_entity

    xla_security_pkg.set_security_context(200); --passing payables application_id

    DELETE FROM XLA_EVENTS_INT_GT;
    psa_utils.debug_other_string(g_state_level,l_api_name, '# Rows deleted from xla_events_int_gt'|| SQL%ROWCOUNT );

    l_event_count := 0;
    FOR rec_events IN c_get_unprocessed_events
    LOOP
      l_event_count := l_event_count+1;
      l_events_tab(l_event_count).entity_id           := rec_events.entity_id;
      l_events_tab(l_event_count).application_id      := 200;
      l_events_tab(l_event_count).ledger_id           := p_ledger_id;
      l_events_tab(l_event_count).legal_entity_id     := rec_events.legal_entity_id;
      l_events_tab(l_event_count).entity_code         := rec_events.entity_code;
      l_events_tab(l_event_count).event_id            := rec_events.event_id;
      l_events_tab(l_event_count).event_status_code   := rec_events.event_status_code;
      l_events_tab(l_event_count).process_status_code := rec_events.process_status_code;
      l_events_tab(l_event_count).source_id_int_1     := rec_events.source_id_int_1;
    END LOOP;


    IF l_event_count > 0 THEN

      FORALL i IN 1..l_event_count
      INSERT INTO XLA_EVENTS_INT_GT
      VALUES l_events_tab(i) ;

      psa_utils.debug_other_string(g_state_level,l_api_name,' # Rows inserted into xla_events_int_gt table:' || l_event_count);
      psa_utils.debug_other_string(g_state_level,l_api_name,'Calling XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENT ');

      XLA_EVENTS_PUB_PKG.DELETE_BULK_EVENTS(p_application_id => 200);

      psa_utils.debug_other_string(g_state_level,l_api_name,'After Deletion of Unprocessed Events');
      fnd_file.put_line(fnd_file.log ,'The following BC unprocessed/Error events have been deleted');
      fnd_file.put_line(fnd_file.log ,'Event_id  Event_status_code Process_status_code');
      fnd_file.put_line(fnd_file.log ,'--------- ----------------- -------------------');

      FOR i IN 1..l_event_count  LOOP
        fnd_file.put_line(fnd_file.log ,l_events_tab(i).event_id||'        '||
         l_events_tab(i).event_status_code   ||'                    '||
         l_events_tab(i).process_status_code);

        psa_utils.debug_other_string(g_state_level,l_api_name,'Updating bc_event_id '||l_events_tab(i).event_id ||'to NULL for related distributions.');
        UPDATE ap_invoice_distributions_all
           SET bc_event_id = NULL
         WHERE bc_event_id = l_events_tab(i).event_id;
        psa_utils.debug_other_string(g_state_level,l_api_name,'# distributions in ap_invoice_distributions_all has been updated to NULL:'||SQL%ROWCOUNT);

        UPDATE ap_prepay_history_all aph
           SET aph.bc_event_id = NULL
         WHERE aph.bc_event_id  = l_events_tab(i).event_id;
        psa_utils.debug_other_string(g_state_level,l_api_name,'# distributions in ap_prepay_history_all has been updated to NULL:'||SQL%ROWCOUNT);

        UPDATE ap_prepay_app_dists apad
           SET apad.bc_event_id = NULL
         WHERE apad.bc_event_id = l_events_tab(i).event_id;
        psa_utils.debug_other_string(g_state_level,l_api_name,'# distributions in ap_prepay_app_dists has been updated to NULL:'||SQL%ROWCOUNT);

      END LOOP;
    END IF;
    fnd_file.put_line(fnd_file.log ,'Count of BC events deleted:' || l_event_count);
    fnd_file.put_line(fnd_file.log ,'<< PSA_AP_BC_PVT.Delete_EVENTS');
    /*
    --IF Federal is installed, call to fv_utility to
    --delete Federal orphan events, if any
    IF fv_install.enabled THEN
      psa_utils.debug_other_string(g_state_level,l_api_name,'Federal is installed:');
      psa_utils.debug_other_string(g_state_level,l_api_name,'Deleting Federal orphan events, if any.');
      fv_utility.delete_fv_bc_orphan
      (
        p_ledger_id => p_ledger_id,
        p_start_date => p_start_date,
        p_end_date => p_end_date,
        p_status => l_return_status
      );
      IF l_return_status <> 'S' THEN
        psa_utils.debug_other_string(g_error_level,l_api_name,
        ' PSA_AP_BC_PVT.CREATE_EVENT Failed after calling fv_utility.delete_fv_bc_orphan!');
        x_return_status := Fnd_Api.G_Ret_Sts_Error;
      END IF;
    END IF;
    */
    psa_utils.debug_other_string(g_state_level,l_api_name,'End of Procedure Delete_Events' );
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_Ret_Sts_Error;
      IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      END IF;
      psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_excep_level,l_api_name,'Error in Delete_Events  Procedure' );
      Fnd_Msg_Pub.Count_And_Get
      (
      p_count   => x_msg_count,
      p_data    => x_msg_data
      );

      psa_utils.debug_other_string(g_state_level,l_api_name,'End of Procedure Delete_Events' );
  END Delete_Events;

  PROCEDURE delete_unprocessed_events
  (
      p_tab_fc_dist      IN  Funds_Dist_Tab_Type,
      p_calling_sequence IN  VARCHAR2,
      p_return_status    OUT NOCOPY VARCHAR2,
      p_msg_count        OUT NOCOPY NUMBER,
      p_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
    l_event_source_info       xla_events_pub_pkg.t_event_source_info;
    l_valuation_method        VARCHAR2(30);
    l_path_name               VARCHAR2(500);
    l_curr_calling_sequence   VARCHAR2(2000);
    l_security_context        xla_events_pub_pkg.t_security;
    l_curr_invoice_id         NUMBER := -1;
    l_curr_org_id             NUMBER := -1;
    l_event_status_code       xla_events.event_status_code%TYPE;
    l_entity_ret_code         INTEGER;
  BEGIN
    l_path_name := g_full_path || '.delete_unprocessed_events';
    p_return_status := Fnd_Api.G_Ret_Sts_Success;
    psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure delete_unprocessed_events ' );
    l_curr_calling_sequence := p_calling_sequence||l_path_name;

    l_event_source_info.source_application_id := NULL;
    l_event_source_info.application_id        := 200;
    l_event_source_info.entity_type_code      := 'AP_INVOICES';

    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST LOOP
      psa_utils.debug_other_string(g_state_level,l_path_name, 'i ='||i );
      psa_utils.debug_other_string(g_state_level,l_path_name, 'l_curr_org_id ='||l_curr_org_id );
      psa_utils.debug_other_string(g_state_level,l_path_name, 'org_id ='||p_tab_fc_dist(i).org_id );
      IF (l_curr_org_id <> p_tab_fc_dist(i).org_id) THEN
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Setting Security Context');
        l_security_context := get_event_security_context
                              (
                                p_org_id           => p_tab_fc_dist(i).org_id,
                                p_calling_sequence => l_curr_calling_sequence
                              );
      END IF;
      l_event_source_info.legal_entity_id       := p_tab_fc_dist(i).legal_entity_id;
      l_event_source_info.ledger_id             := p_tab_fc_dist(i).set_of_books_id;
      l_event_source_info.transaction_number    := p_tab_fc_dist(i).invoice_num;
      l_event_source_info.source_id_int_1       := p_tab_fc_dist(i).invoice_id;

      psa_utils.debug_other_string(g_state_level,l_path_name, 'bc_event_id ='||p_tab_fc_dist(i).bc_event_id );
      IF (p_tab_fc_dist(i).bc_event_id IS NOT NULL) THEN
        BEGIN
          l_event_status_code := NULL;
          SELECT event_status_code
            INTO l_event_status_code
            FROM xla_events e
           WHERE event_id = p_tab_fc_dist(i).bc_event_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            psa_utils.debug_other_string(g_state_level,l_path_name, 'No such BC event in XLA' );
        END;

        psa_utils.debug_other_string(g_state_level,l_path_name, 'l_event_status_code='||l_event_status_code );
        IF (l_event_status_code = 'U') THEN
          psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting Event:'||p_tab_fc_dist(i).bc_event_id);
          xla_events_pub_pkg.delete_event
          (
            p_event_source_info => l_event_source_info,
            p_event_id          => p_tab_fc_dist(i).bc_event_id,
            p_valuation_method  => l_valuation_method,
            p_security_context  => l_security_context
          );
          psa_utils.debug_other_string(g_state_level,l_path_name, 'l_entity_ret_code='||l_entity_ret_code);
        ELSIF (l_event_status_code = 'P') THEN
          psa_utils.debug_other_string(g_state_level,l_path_name, 'Event:'||p_tab_fc_dist(i).bc_event_id||' is in processed status');
          fnd_message.set_name('PSA','PSA_BC_EVENT_ALREADY_PROCESSED');
          fnd_message.set_token('EVENT_ID',p_tab_fc_dist(i).bc_event_id);
          fnd_message.set_token('INVOICE_ID',p_tab_fc_dist(i).invoice_id);
          fnd_message.set_token('INV_DISTRIBUTION_ID',p_tab_fc_dist(i).inv_distribution_id);
          psa_bc_xla_pvt.psa_xla_error ('PSA_BC_EVENT_ALREADY_PROCESSED');

          fnd_message.set_name('PSA','PSA_BC_EVENT_ALREADY_PROCESSED');
          fnd_message.set_token('EVENT_ID',p_tab_fc_dist(i).bc_event_id);
          fnd_message.set_token('INVOICE_ID',p_tab_fc_dist(i).invoice_id);
          fnd_message.set_token('INV_DISTRIBUTION_ID',p_tab_fc_dist(i).inv_distribution_id);
          Fnd_Msg_Pub.ADD;
          Fnd_Msg_Pub.Count_And_Get
          (
            p_count   => p_msg_count,
            p_data    => p_msg_data
          );
          p_return_status := Fnd_Api.G_Ret_Sts_Error;
          EXIT;
        END IF;

        UPDATE ap_invoice_distributions_all
           SET bc_event_id = NULL
         WHERE invoice_distribution_id = p_tab_fc_dist(i).inv_distribution_id;
      END IF;

      /* Delete the orphan events per Invoice Id*/
      IF (l_curr_invoice_id <> p_tab_fc_dist(i).invoice_id) THEN
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting Orphan Events');
        FOR event_rec IN (SELECT e.*
                            FROM xla_events e,
                                 xla_transaction_entities t
                           WHERE e.entity_id = t.entity_id
                             AND t.application_id = 200
                             AND t.entity_code = l_event_source_info.entity_type_code
                             AND t.source_id_int_1 = l_event_source_info.source_id_int_1
                             AND e.budgetary_control_flag = 'Y'
                             AND NOT EXISTS (SELECT 1
                                               FROM ap_invoice_distributions_all
                                              WHERE invoice_id = l_event_source_info.source_id_int_1
                                                AND bc_event_id = e.event_id)) LOOP
          psa_utils.debug_other_string(g_state_level,l_path_name, 'Found Event Id = '||event_rec.event_id);
          psa_utils.debug_other_string(g_state_level,l_path_name, 'process_status_code = '||event_rec.process_status_code);
          IF (event_rec.event_status_code = 'U') THEN
            psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting the event');
            xla_events_pub_pkg.delete_event
            (
              p_event_source_info => l_event_source_info,
              p_event_id          => event_rec.event_id,
              p_valuation_method  => l_valuation_method,
              p_security_context  => l_security_context
            );
            psa_utils.debug_other_string(g_state_level,l_path_name, 'l_entity_ret_code='||l_entity_ret_code);
          ELSIF (l_event_status_code = 'P') THEN
            psa_utils.debug_other_string(g_state_level,l_path_name, 'Event:'||p_tab_fc_dist(i).bc_event_id||' is in processed status');

            fnd_message.set_name('PSA','PSA_BC_EVENT_ALREADY_PROCESSED');
            fnd_message.set_token('EVENT_ID',event_rec.event_id);
            fnd_message.set_token('INVOICE_ID',p_tab_fc_dist(i).invoice_id);
            fnd_message.set_token('INV_DISTRIBUTION_ID',p_tab_fc_dist(i).inv_distribution_id);
            psa_bc_xla_pvt.psa_xla_error ('PSA_BC_EVENT_ALREADY_PROCESSED');

            fnd_message.set_name('PSA','PSA_BC_EVENT_ALREADY_PROCESSED');
            fnd_message.set_token('EVENT_ID',event_rec.event_id);
            fnd_message.set_token('INVOICE_ID',p_tab_fc_dist(i).invoice_id);
            fnd_message.set_token('INV_DISTRIBUTION_ID',p_tab_fc_dist(i).inv_distribution_id);
            Fnd_Msg_Pub.ADD;
            Fnd_Msg_Pub.Count_And_Get
            (
              p_count   => p_msg_count,
              p_data    => p_msg_data
            );
            p_return_status := Fnd_Api.G_Ret_Sts_Error;
            EXIT;
          END IF;
        END LOOP;
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Finished Deleting Orphan Events');
      END IF;
      l_curr_org_id := p_tab_fc_dist(i).org_id;
      l_curr_invoice_id := p_tab_fc_dist(i).invoice_id;
      IF (p_return_status = Fnd_Api.G_Ret_Sts_Error) THEN
        EXIT;
      END IF;
    END LOOP;
   EXCEPTION
     WHEN OTHERS THEN
       p_return_status := Fnd_Api.G_Ret_Sts_Error;
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS','');
       psa_utils.debug_other_string(g_excep_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
       psa_utils.debug_other_string(g_excep_level,l_path_name,'Error in delete_unprocessed_events Procedure' );
       Fnd_Msg_Pub.Count_And_Get
       (
          p_count   => p_msg_count,
          p_data    => p_msg_data
       );
       psa_utils.debug_other_string(g_state_level,'','End of Procedure delete_unprocessed_events' );
  END;

  /*============================================================================
  |  PROCEDURE  -  delete_processed_orphan_events
  |  Description - Delete the payables processed BC events.
  |                Budgetary Control Optimizer program calls this.
  *===========================================================================*/
  PROCEDURE delete_processed_orphan_events
  (
    p_init_msg_list    IN      VARCHAR2,
    p_ledger_id        IN      NUMBER,
    p_calling_sequence IN      VARCHAR2,
    p_return_status OUT NOCOPY VARCHAR2,
    p_msg_count OUT NOCOPY     NUMBER,
    p_msg_data OUT NOCOPY      VARCHAR2
  )
  IS
    l_accounting_date  DATE;
    l_path_name        VARCHAR2(500);
    l_success_count    NUMBER;
    l_fail_count       NUMBER;
    x_return_status    VARCHAR2(300);
    x_msg_count        NUMBER;
    x_msg_data         VARCHAR2(4000);
    x_rev_ae_header_id INTEGER;
    x_rev_event_id     INTEGER;
    x_rev_entity_id    INTEGER;
    x_new_event_id     INTEGER;
    x_new_entity_id    INTEGER;
    x_api_version      NUMBER       := 1.0;
    x_init_msg_list    VARCHAR2(300):= fnd_api.g_true;
    x_application_id   INTEGER      := 200;
    x_reversal_method  VARCHAR2(300):= 'SIDE';
    x_post_to_gl_flag  VARCHAR2(300):= 'N';

    CURSOR c_processed_orphan_events IS
    SELECT xe.event_id                                        ,
           xe.event_status_code                               ,
           xe.process_status_code                             ,
           xah.ae_header_id                    AE_HEADER_ID           ,
           xah.gl_transfer_status_code         GL_TRANSFER_STATUS_CODE,
           NVL(xe.budgetary_control_flag, 'N') BUDGETARY_CONTROL_FLAG ,
           xah.accounting_date                 ACCOUNTING_DATE        ,
           xah.ledger_id
      FROM xla_events xe,
           xla_ae_headers xah
     WHERE xe.application_id         = 200
       AND xah.application_id        = 200
       AND xah.ledger_id             = p_ledger_id
       AND xe.event_id               = xah.event_id
       AND xe.event_status_code      = 'P'
       AND xe.process_status_code    = 'P'
       AND xe.budgetary_control_flag = 'Y'
       AND xe.event_type_code       <> 'MANUAL'
       AND NOT EXISTS (SELECT 'not exists'
                         FROM ap_invoice_distributions_all aid
                        WHERE aid.bc_event_id = xe.event_id)
       AND NOT EXISTS (SELECT 'not exists'
                         FROM ap_prepay_history_all aph
                        WHERE aph.bc_event_id = xe.event_id)
       AND NOT EXISTS (SELECT 'not exists'
                         FROM ap_prepay_app_dists apd
                        WHERE apd.bc_event_id = xe.event_id)
       AND NOT EXISTS (SELECT 'not exists'
                         FROM ap_self_assessed_tax_dist_all aps
                        WHERE aps.bc_event_id = xe.event_id)
     ORDER BY xe.event_id;
  BEGIN
    fnd_file.put_line(fnd_file.log ,'>> PSA_AP_BC_PVT.Delete_Processed_Orphan_Events');
    p_return_status := Fnd_Api.G_Ret_Sts_Success;
    IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
    END IF;

    l_path_name := g_full_path|| '.delete_processed_orphan_events';
    psa_utils.debug_other_string(g_state_level,l_path_name, 'BEGIN of procedure delete_processed_orphan_events ' );
    fnd_file.put_line(fnd_file.log ,' ');
    fnd_file.put_line(fnd_file.log ,'The following BC Processed orphan events have been deleted');
    fnd_file.put_line(fnd_file.log ,'Event_Id  Event_Status_Code Process_Status_Code GL_Transfer_Status_Code Delete_Status');
    fnd_file.put_line(fnd_file.log ,'--------- ----------------- ------------------- ----------------------- -------------');
    l_success_count :=0;
    l_fail_count :=0;

    FOR orphan_event_rec IN c_processed_orphan_events LOOP
      psa_utils.debug_other_string(g_state_level,l_path_name, 'Found Event Id = '||orphan_event_rec.event_id);
      psa_utils.debug_other_string(g_state_level,l_path_name, 'process_status_code = '||orphan_event_rec.process_status_code);
      psa_utils.debug_other_string(g_state_level,l_path_name, 'gl_transfer_status_code = '||orphan_event_rec.gl_transfer_status_code);
      psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting the event');
      BEGIN
        IF NVL(orphan_event_rec.gl_transfer_status_code, 'N') <> 'Y' THEN
          xla_datafixes_pub.delete_journal_entries
          (
            x_api_version,
            x_init_msg_list,
            x_application_id,
            orphan_event_rec.event_id,
            x_return_status,
            x_msg_count,
            x_msg_data
          );
        ELSE
          BEGIN
            psa_utils.debug_other_string(g_state_level,l_path_name, 'Check if GL period is open');
            SELECT start_date
              INTO l_accounting_date
              FROM gl_period_statuses
             WHERE application_id = 101
               AND ledger_id      = p_ledger_id
               AND orphan_event_rec.ACCOUNTING_DATE BETWEEN start_date AND    end_date
               AND closing_status='O';
            l_accounting_date := orphan_event_rec.ACCOUNTING_DATE;
          EXCEPTION
            WHEN no_data_found THEN
              BEGIN
                psa_utils.debug_other_string(g_state_level,l_path_name, 'Get the latest open GL period');
                SELECT max(start_date)
                  INTO l_accounting_date
                  FROM gl_period_statuses
                 WHERE application_id = 101
                   AND ledger_id      = p_ledger_id
                   AND closing_status ='O';
              EXCEPTION
                WHEN OTHERS THEN
                  psa_utils.debug_other_string(g_state_level,l_path_name, 'No open GL accounting period');
                  NULL;
              END;
          END;

          xla_datafixes_pub.reverse_journal_entries
          (
            x_api_version,
            x_init_msg_list,
            x_application_id,
            orphan_event_rec.event_id,
            x_reversal_method,
            l_accounting_date,
            x_post_to_gl_flag,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_rev_ae_header_id,
            x_rev_event_id,
            x_rev_entity_id,
            x_new_event_id,
            x_new_entity_id
          );
        END IF;
      EXCEPTION
        WHEN others THEN
          psa_utils.debug_other_string(g_state_level,l_path_name, 'Inside event deletion/reversal exception for event_id: '||orphan_event_rec.event_id );
          NULL;
      END;

      psa_utils.debug_other_string(g_state_level,l_path_name, 'x_return_status = '||x_return_status);
      IF x_return_status = 'S' THEN
        l_success_count := l_success_count+1;
        fnd_file.put_line(fnd_file.log ,orphan_event_rec.event_id||'        '||
                                        orphan_event_rec.event_status_code||'                    '||
                                        orphan_event_rec.process_status_code||'                   '||
                                        orphan_event_rec.gl_transfer_status_code||'              '||
                                        'Success' );

        DELETE gl_bc_packets
         WHERE event_id = orphan_event_rec.event_id;
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting the gl_bc_packets'|| sql%rowcount);

        DELETE FROM xla_events
         WHERE event_id = orphan_event_rec.event_id;
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting the xla_events'|| sql%rowcount);

        DELETE FROM xla_trial_balances
         WHERE ae_header_id = orphan_event_rec.ae_header_id;
        psa_utils.debug_other_string(g_state_level,l_path_name, 'Deleting the xla_trial_balance'|| sql%rowcount);

      ELSE
        l_fail_count := l_fail_count+1;
        fnd_file.put_line(fnd_file.log ,orphan_event_rec.event_id||'        '||
                                        orphan_event_rec.event_status_code||'                    '||
                                        orphan_event_rec.process_status_code||'                   '||
                                        orphan_event_rec.gl_transfer_status_code||'                '||
                                        'Failed' );
        IF (x_msg_data is not null) then
          psa_utils.debug_other_string(g_state_level,l_path_name, 'Error Message: '||x_msg_data);
          p_return_status := Fnd_Api.G_Ret_Sts_Error;
        END IF;
      END IF;

    END LOOP;

    fnd_file.put_line(fnd_file.log ,'--------- ----------------- ------------------- ----------------------- -------------');
    fnd_file.put_line(fnd_file.log ,'Events deleted successfully: ' || l_success_count);
    fnd_file.put_line(fnd_file.log ,'Events could not be deleted: ' || l_fail_count);
    psa_utils.debug_other_string(g_state_level,l_path_name, 'END of procedure delete_processed_orphan_events ' );
    fnd_file.put_line(fnd_file.log ,'<< PSA_AP_BC_PVT.delete_processed_orphan_events');

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := Fnd_Api.G_Ret_Sts_Error;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', p_calling_sequence);
      END IF;
      psa_utils.debug_other_string(g_excep_level,l_path_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_excep_level,l_path_name,'Error in delete_processed_orphan_events  Procedure' );
      Fnd_Msg_Pub.Count_And_Get
      (
        p_count   => p_msg_count,
        p_data    => p_msg_data
      );

      psa_utils.debug_other_string(g_state_level,l_path_name,'End of Procedure delete_processed_orphan_events' );

  END delete_processed_orphan_events;

/*============================================================================
 |  PROCEDURE  -  CREATE_EVENTS
 *===========================================================================*/

  PROCEDURE Create_Events
  (
    p_init_msg_list    IN VARCHAR2,
    p_tab_fc_dist      IN Funds_Dist_Tab_Type,
    p_calling_mode     IN VARCHAR2,    -- Possible values are 'APPROVAL','CANCEL'
    p_bc_mode          IN VARCHAR2,    -- Possible values are 'C','P'
    p_calling_sequence IN VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
    -- PREPAY APPLY/UNAPPLY NETTING LOGIC BEGIN
    TYPE PrepayProcessRec_Type IS RECORD
    (
      process_flag VARCHAR2(1),
      prepay_flag VARCHAR2(1),
      inv_distribution_id NUMBER
    );
    TYPE PrepayProcessTab_Type IS TABLE OF PrepayProcessRec_Type INDEX BY BINARY_INTEGER;
    l_PrepayProcessTab PrepayProcessTab_Type;


    CURSOR c_parent_prepayapply_processed
    (
      p_prepayapply_dist_id NUMBER
    ) IS
    SELECT 'Y'
      FROM ap_invoice_distributions_all aid, xla_events xe
     WHERE aid.invoice_distribution_id=p_prepayapply_dist_id
       AND aid.bc_event_id = xe.event_id
       AND xe.event_status_code = 'P'
       AND xe.application_id = 200;

    l_parent_prepayapply_processed VARCHAR2(1):= 'N' ;
    -- PREPAY APPLY/UNAPPLY NETTING LOGIC END

    CURSOR c_get_dist_info
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT parent_reversal_id,
           encumbered_flag
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    CURSOR c_get_parent_dist_id
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT charge_applicable_to_dist_id
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    CURSOR c_get_parent_dist_type
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT line_type_lookup_code parent_dist_type
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    CURSOR c_chk_accrue_flag
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT NVL(pod.accrue_on_receipt_flag,'N')
      FROM ap_invoice_distributions_all d,
           po_distributions_all pod
     WHERE d.invoice_distribution_id = p_inv_dist_id
       AND d.po_distribution_id IS NOT NULL
       AND d.po_distribution_id = pod.po_distribution_id;

    CURSOR c_chk_prepayment_match_po
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT d.po_distribution_id
      FROM ap_invoice_distributions_all d
     WHERE d.invoice_distribution_id = p_inv_dist_id;

    l_curr_calling_sequence  VARCHAR2(2000);
    l_log_msg                FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_debug_loc              VARCHAR2(30) := 'Create_Events';

    TYPE BC_Event_tab_type IS TABLE OF xla_events%rowtype
    INDEX BY BINARY_INTEGER;

    l_bc_event_tab           BC_Event_tab_type;
    l_api_name               VARCHAR2(240);
    l_bc_event_count         NUMBER;
    l_event_id               NUMBER;
    l_event_type_code        VARCHAR2(30);
    l_event_date             DATE;
    l_event_status_code      VARCHAR2(30);
    l_event_number           NUMBER;
    l_event_source_info      xla_events_pub_pkg.t_event_source_info;
    l_reference_info         xla_events_pub_pkg.t_event_reference_info;
    l_valuation_method       VARCHAR2(30);
    l_security_context       xla_events_pub_pkg.t_security;
    l_event_check            BOOLEAN;
    l_process_dist           BOOLEAN;
    l_encum_flag             VARCHAR2(1);
    l_parent_reversal_id     ap_invoice_distributions_all.parent_reversal_id%TYPE;
    l_federal_enabled        VARCHAR2(1);
    l_parent_dist_id         NUMBER;
    l_distribution_type      VARCHAR2(30);
    l_po_accrue_flag         VARCHAR2(1);
    l_po_dist_id             NUMBER;
    l_sameBCevent            VARCHAR2(100);
    l_fv_prepay_check        VARCHAR2(10);
    l_create_bc_event        BOOLEAN := TRUE;

    FUNCTION is_unencumbered_prepay
    (
      p_invoice_distribution_id IN NUMBER
    ) RETURN VARCHAR2
    IS
      l_rev_dist_id NUMBER;
      l_line_number NUMBER;
      l_invoice_id NUMBER;
      l_dist_amount NUMBER;
      l_bc_event_id NUMBER;
      l_encumbered_flag VARCHAR2(1);
      l_prepay_distribution_id NUMBER;
      l_api_name1  VARCHAR2(240);
    BEGIN
      l_api_name := g_full_path||'.is_unencumbered_prepay';
      psa_utils.debug_other_string(g_state_level,l_api_name,'Inside program');
      psa_utils.debug_other_string(g_state_level,l_api_name,'p_invoice_distribution_id= '||p_invoice_distribution_id);
      SELECT d.parent_reversal_id,
             d.amount,
             d.invoice_line_number,
             d.invoice_id,
             d.prepay_distribution_id
        INTO l_rev_dist_id,
             l_dist_amount,
             l_line_number,
             l_invoice_id,
             l_prepay_distribution_id
        FROM ap_invoice_distributions_all d
       WHERE invoice_distribution_id = p_invoice_distribution_id;

      psa_utils.debug_other_string(g_state_level,l_api_name,'l_rev_dist_id= '||l_rev_dist_id);
      psa_utils.debug_other_string(g_state_level,l_api_name,'l_prepay_distribution_id= '||l_prepay_distribution_id);
      IF (l_rev_dist_id IS NOT NULL) THEN --Unapply
        SELECT d.bc_event_id,
               d.encumbered_flag
          INTO l_bc_event_id,
               l_encumbered_flag
          FROM ap_invoice_distributions_all d
         WHERE invoice_distribution_id = l_rev_dist_id;
        IF (l_bc_event_id IS NULL AND NVL(l_encumbered_flag, 'N') IN ('N', 'R')) THEN
          RETURN 'Y';
        END IF;
      ELSE --Apply
        SELECT d.bc_event_id,
               d.encumbered_flag
          INTO l_bc_event_id,
               l_encumbered_flag
          FROM ap_invoice_distributions_all d
         WHERE invoice_distribution_id = l_prepay_distribution_id;
        IF (l_bc_event_id IS NULL AND NVL(l_encumbered_flag, 'N') IN ('N', 'R')) THEN
          RETURN 'Y';
        END IF;
      END IF;
      RETURN 'N';
    END;

  BEGIN
    l_api_name := g_full_path||'.Create_events';
    -- Update the calling sequence --
    l_curr_calling_sequence := 'PSA_AP_BC_PVT.'||l_debug_loc|| '<-'||p_calling_sequence;

    x_return_status := Fnd_Api.G_Ret_Sts_Success;
    IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
    END IF;
    psa_utils.debug_other_string(g_state_level,l_api_name, 'BEGIN of procedure Create_Events..' );
    IF p_tab_fc_dist.COUNT < 1 THEN   -- no rows to be processed
      psa_utils.debug_other_string(g_state_level,l_api_name, 'No rows to be processed..' );
      RETURN;
    END IF;

    ----------------------------------------------------------------------
    -- Bug 5160179: clear the temporary gt table before inserting any rows
    ----------------------------------------------------------------------
    DELETE from psa_bc_xla_events_gt;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows deleted of psa_bc_xla_events_gt: ' || SQL%ROWCOUNT);
    DELETE from xla_acct_prog_events_gt;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows deleted of xla_acct_prog_events_gt: ' || SQL%ROWCOUNT);
    DELETE from xla_ae_headers_gt;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows deleted of xla_ae_headers_gt: ' || SQL%ROWCOUNT);
    DELETE from xla_ae_lines_gt;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows deleted of xla_ae_lines_gt: ' || SQL%ROWCOUNT);
    DELETE from xla_validation_lines_gt;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows deleted of xla_validation_lines_gt: ' || SQL%ROWCOUNT);

    l_bc_event_count := 0;
    l_event_status_code := xla_events_pub_pkg.c_event_unprocessed;
    l_valuation_method := NULL;
    l_event_check := TRUE;
    l_process_dist := TRUE;

    IF (FV_INSTALL.ENABLED) THEN
      l_federal_enabled := 'Y';
    ELSE
      l_federal_enabled := 'N';
    END IF;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Federal Enabled: ' || l_federal_enabled);

    -- PREPAY APPLY/UNAPPLY NETTING LOGIC BEGIN
    psa_utils.debug_other_string(g_state_level,l_api_name,'Setting all the table data to Y');
    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST LOOP
      l_PrepayProcessTab(i).process_flag := 'Y';
      l_PrepayProcessTab(i).prepay_flag := 'N';
      l_PrepayProcessTab(i).inv_distribution_id := p_tab_fc_dist(i).inv_distribution_id;
    END LOOP;
    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST LOOP
      psa_utils.debug_other_string(g_state_level,l_api_name,'distribution_type='||p_tab_fc_dist(i).distribution_type);
      psa_utils.debug_other_string(g_state_level,l_api_name,'distribution_amount='||p_tab_fc_dist(i).distribution_amount);
      IF ( isprepaydist( p_tab_fc_dist(i).inv_distribution_id,
                         p_tab_fc_dist(i).invoice_id,
                         p_tab_fc_dist(i).distribution_type
                       )='Y') THEN
        l_PrepayProcessTab(i).prepay_flag := 'Y';
        IF(p_tab_fc_dist(i).distribution_amount > 0) THEN
          psa_utils.debug_other_string(g_state_level,l_api_name,'inv_distribution_id='||p_tab_fc_dist(i).inv_distribution_id);
          OPEN c_get_dist_info(p_tab_fc_dist(i).inv_distribution_id);
          FETCH c_get_dist_info INTO l_parent_reversal_id, l_encum_flag;
          CLOSE c_get_dist_info;
          psa_utils.debug_other_string(g_state_level,l_api_name,'l_parent_reversal_id='||l_parent_reversal_id);
          l_parent_prepayapply_processed :='N';
          IF (l_parent_reversal_id IS NOT NULL) THEN
             OPEN  c_parent_prepayapply_processed(l_parent_reversal_id);
             FETCH c_parent_prepayapply_processed INTO l_parent_prepayapply_processed;
             CLOSE c_parent_prepayapply_processed;
             psa_utils.debug_other_string(g_state_level,l_api_name,
                      'l_parent_prepayapply_processed ='||l_parent_prepayapply_processed);
             --if above cursor returns y , it means unapply dist need to process as
             --parent apply dist has been already processed.
             IF l_parent_prepayapply_processed = 'N' THEN
                FOR j IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST LOOP
                   psa_utils.debug_other_string(g_state_level,l_api_name,'inv_distribution_id(j)='||p_tab_fc_dist(j).inv_distribution_id);
                   IF (p_tab_fc_dist(j).inv_distribution_id = l_parent_reversal_id) THEN
                      l_PrepayProcessTab(i).process_flag := 'N';
                      l_PrepayProcessTab(j).process_flag := 'N';
                   END IF;
                END LOOP;
             END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;
    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST LOOP
      psa_utils.debug_other_string(g_state_level,l_api_name,'l_PrepayProcessTab('||i||').process_flag='||l_PrepayProcessTab(i).process_flag);
    END LOOP;

    -- PREPAY APPLY/UNAPPLY NETTING LOGIC END

    delete_unprocessed_events
    (
      p_tab_fc_dist      => p_tab_fc_dist,
      p_calling_sequence => p_calling_sequence,
      p_return_status    => x_return_status,
      p_msg_count        => x_msg_count,
      p_msg_data         => x_msg_data
    );

    IF (x_return_status = Fnd_Api.G_Ret_Sts_Error) THEN
      RETURN;
    END IF;

    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST
    LOOP
      l_po_accrue_flag := 'N';
      OPEN c_chk_accrue_flag(p_tab_fc_dist(i).inv_distribution_id);
      FETCH c_chk_accrue_flag
       INTO l_po_accrue_flag;
      CLOSE c_chk_accrue_flag;
      psa_utils.debug_other_string(g_state_level,l_api_name,'Accrue on Receipt Option for distribution: '||
                                                            p_tab_fc_dist(i).distribution_type ||
                                                            ' IS: ' || l_po_accrue_flag);

      l_create_bc_event := TRUE;
      IF (l_federal_enabled = 'Y' AND (p_tab_fc_dist(i).invoice_type_code = 'PREPAYMENT' OR p_tab_fc_dist(i).distribution_type = 'PREPAY')) THEN
        --Bug 5532835
        OPEN c_chk_prepayment_match_po (p_tab_fc_dist(i).inv_distribution_id);
        FETCH c_chk_prepayment_match_po
         INTO l_po_dist_id;
        CLOSE c_chk_prepayment_match_po;

        IF l_po_dist_id is NULL THEN
          psa_utils.debug_other_string(g_state_level,l_api_name,'Prepayment is not matched to PO hence Federal Accounting will be created.' );
        ELSE
          psa_utils.debug_other_string(g_state_level,l_api_name,'Prepayment is  matched to PO hence Federal Accounting will not be created.' );
        END IF;

        fnd_profile.get ('FV_PREPAYMENT_PO', l_fv_prepay_check);
        psa_utils.debug_other_string(g_state_level,l_api_name,'Profile: FV: Prepayment PO Required = '||l_fv_prepay_check);
        IF l_fv_prepay_check = 'C' THEN
          l_create_bc_event := FALSE;
        ELSE
          IF (l_po_dist_id IS NOT NULL) THEN
            l_create_bc_event := FALSE;
          END IF;
        END IF;
        psa_utils.debug_other_string(g_state_level,l_api_name,'Event not created for Federal prepayments');
      ELSIF (l_federal_enabled = 'N' AND NVL(l_po_accrue_flag, 'N') = 'Y' AND p_tab_fc_dist(i).distribution_type IN ('ITEM', 'PREPAY',      'QV', 'AV', 'NONREC_TAX' ) ) THEN
        l_create_bc_event := FALSE;
        psa_utils.debug_other_string(g_state_level,l_api_name,'Event not created for Invoice/Prepayment distribution: ' ||
                                                               p_tab_fc_dist(i).distribution_type ||
                                                               ' matched to PO with Accrue on Receipt on');
      ELSIF (p_tab_fc_dist(i).distribution_type = 'REC_TAX') THEN
        l_create_bc_event := FALSE;
        psa_utils.debug_other_string(g_state_level,l_api_name,'Event not created for Rec Tax');

      -- PREPAY APPLY/UNAPPLY NETTING LOGIC BEGIN
      ELSIF (l_PrepayProcessTab(i).process_flag = 'N') THEN
        l_create_bc_event := FALSE;
        psa_utils.debug_other_string(g_state_level,l_api_name,'Event not created for Invoice/Prepayment distribution: '||
                                                              p_tab_fc_dist(i).distribution_type ||
                                                              'Apply/Unapply that is hapenning simultaneously');
      -- PREPAY APPLY/UNAPPLY NETTING LOGIC END
      ELSIF (l_PrepayProcessTab(i).prepay_flag = 'Y' AND is_unencumbered_prepay(l_PrepayProcessTab(i).inv_distribution_id) = 'Y') THEN
        l_create_bc_event := FALSE;
        psa_utils.debug_other_string(g_state_level,l_api_name,'Original Apply/Unapply Distribution not encumbered');

        UPDATE ap_invoice_distributions_all
           SET encumbered_flag = 'R',
               bc_event_id = null
         WHERE invoice_distribution_id = l_PrepayProcessTab(i).inv_distribution_id;
        psa_utils.debug_other_string(g_state_level,l_api_name,'No of prepay distributiuon encumbered set to R = '||SQL%ROWCOUNT);

        UPDATE ap_prepay_app_dists apad
           SET apad.bc_event_id = NULL
         WHERE apad.PREPAY_APP_DISTRIBUTION_ID = p_tab_fc_dist(i).inv_distribution_id
           AND apad.bc_event_id = p_tab_fc_dist(i).bc_event_id;
        psa_utils.debug_other_string(g_state_level,l_api_name,'No of prepay app distributiuon bc_event set to null = '||SQL%ROWCOUNT);
      END IF;

      IF (l_create_bc_event) THEN
        /* Check for Invoice CANCEL event, we will not pick the distribution
        which are not encumbered and their related cancel line bind by
        parent_reversal_id */
        l_process_dist := TRUE;
        IF p_calling_mode = 'CANCEL' THEN
          OPEN c_get_dist_info(p_tab_fc_dist(i).inv_distribution_id);
          FETCH c_get_dist_info
           INTO l_parent_reversal_id,
                l_encum_flag;
          CLOSE c_get_dist_info;
          IF (l_parent_reversal_id IS NULL AND NVL(l_encum_flag, 'N') = 'N') THEN
            l_process_dist := FALSE;
            psa_utils.debug_other_string(g_state_level,l_api_name,'Found non-encumbered distribution :'||p_tab_fc_dist(i).inv_distribution_id);
            psa_utils.debug_other_string(g_state_level,l_api_name,'We will not process this distribution :'||p_tab_fc_dist(i).inv_distribution_id);

          ELSIF (l_parent_reversal_id IS NOT NULL) THEN
            OPEN c_get_dist_info(l_parent_reversal_id);
            FETCH c_get_dist_info
             INTO l_parent_reversal_id,
                  l_encum_flag;
            CLOSE c_get_dist_info;
            IF (NVL(l_encum_flag, 'N') = 'N') THEN
              l_process_dist := FALSE;
              psa_utils.debug_other_string(g_state_level,l_api_name,'Found non-encumbered distribution :'||p_tab_fc_dist(i).inv_distribution_id);
              psa_utils.debug_other_string(g_state_level,l_api_name,'We will not process this distribution :'||p_tab_fc_dist(i).inv_distribution_id);
            END IF;
          END IF;
        END IF;

        /*Bug8940136*/
        IF (p_tab_fc_dist(i).distribution_type IN ('NONREC_TAX') AND p_tab_fc_dist(i).distribution_amount = 0) THEN
          l_process_dist := FALSE;
        END IF;

        IF l_process_dist THEN
          l_event_check := True;
          l_event_source_info.source_application_id := NULL;
          l_event_source_info.application_id        := 200;
          l_event_source_info.legal_entity_id       := p_tab_fc_dist(i).legal_entity_id;
          l_event_source_info.ledger_id             := p_tab_fc_dist(i).set_of_books_id;
          l_event_source_info.entity_type_code      := 'AP_INVOICES';
          l_event_source_info.transaction_number    := p_tab_fc_dist(i).invoice_num;
          l_event_source_info.source_id_int_1       := p_tab_fc_dist(i).invoice_id;

          l_event_type_code := get_event_type_code
                               (
                                 p_inv_dist_id         => p_tab_fc_dist(i).inv_distribution_id,
                                 p_invoice_type_code   => p_tab_fc_dist(i).invoice_type_code,
                                 p_distribution_type   => p_tab_fc_dist(i).distribution_type,
                                 p_distribution_amount => p_tab_fc_dist(i).distribution_amount,
                                 p_calling_mode        => p_calling_mode,
                                 p_bc_mode             => p_bc_mode
                               );

          psa_utils.debug_other_string(g_state_level,l_api_name,'l_event_type_code :'||l_event_type_code);

          l_event_id := null;

          psa_utils.debug_other_string(g_state_level,l_api_name,'l_bc_event_count :'||l_bc_event_count);
          IF l_bc_event_count > 0 THEN
            FOR j IN 1..l_bc_event_count LOOP
              IF (l_bc_event_tab(j).event_type_code = l_event_type_code AND
                  l_bc_event_tab(j).event_date = l_event_date) THEN
                l_event_id := l_bc_event_tab(j).event_id;
                EXIT;
              END IF;
            END LOOP;
          END IF;

          psa_utils.debug_other_string(g_state_level,l_api_name,'l_event_id :'||l_event_id);

          IF l_event_id IS NULL THEN
            psa_utils.debug_other_string(g_state_level,l_api_name,'Event Id is NULL so creating one');
            IF p_bc_mode='C' AND p_tab_fc_dist(i).distribution_type ='PREPAY' THEN
              l_reference_info.reference_char_1 :='FUNDS_CHECK';
            ELSE
              l_reference_info.reference_char_1 := NULL;
            END IF;

            l_event_date := p_tab_fc_dist(i).accounting_date;

            l_security_context :=  get_event_security_context
                                  (
                                    p_org_id           => p_tab_fc_dist(i).org_id,
                                    p_calling_sequence => l_curr_calling_sequence
                                  );

            l_event_id := xla_events_pub_pkg.create_event
                          (
                            p_event_source_info       => l_event_source_info,
                            p_event_type_code         => l_event_type_code,
                            p_event_date              => l_event_date,
                            p_event_status_code       => l_event_status_code,
                            p_event_number            => l_event_number,
                            p_reference_info          => l_reference_info,
                            p_valuation_method        => l_valuation_method,
                            p_security_context        => l_security_context,
                            p_budgetary_control_flag  => 'Y'
                          );
            psa_utils.debug_other_string(g_state_level,l_api_name,'Event Id Created is :l_event_id');

            IF l_event_id IS NULL THEN
              psa_utils.debug_other_string(g_state_level,l_api_name,'Event Id is null');
              RETURN;
            END IF;

            l_bc_event_count := l_bc_event_count + 1;
            l_bc_event_tab(l_bc_event_count).event_id := l_event_id;
            l_bc_event_tab(l_bc_event_count).event_type_code := l_event_type_code;
            l_bc_event_tab(l_bc_event_count).event_date := l_event_date;

          END IF;

          -- Initialize Distribution Type
          l_distribution_type := p_tab_fc_dist(i).distribution_type;

          OPEN c_get_parent_dist_id(p_tab_fc_dist(i).inv_distribution_id);
          FETCH c_get_parent_dist_id
           INTO l_parent_dist_id;
          CLOSE c_get_parent_dist_id;

          -- Check whether current distribution is a related to main distribution
          -- It's the indicator that it could be e.g. REC_TAX or NONREC_TAX lines
          -- related to MAIN ITEM/PREPAY LINE.

          IF (l_parent_dist_id IS NOT NULL) THEN
            OPEN c_get_parent_dist_type(l_parent_dist_id);
            FETCH c_get_parent_dist_type
             INTO l_distribution_type;
            CLOSE c_get_parent_dist_type;
          END IF;


          IF (l_distribution_type = 'PREPAY' AND NVL(p_bc_mode,'P') <> 'C') THEN
            --Modified For Bug 7229803
            UPDATE ap_prepay_history_all aph
               SET aph.bc_event_id = l_event_id
             WHERE aph.invoice_id = p_tab_fc_dist(i).invoice_id
               AND transaction_type = l_event_type_code
               AND (aph.bc_event_id IS NULL OR aph.bc_event_id = p_tab_fc_dist(i).bc_event_id)
               AND aph.prepay_history_id = (SELECT MAX(prepay_history_id)
                                              FROM ap_prepay_app_dists apd
                                             WHERE prepay_app_distribution_id = p_tab_fc_dist(i).inv_distribution_id);
            psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows updated of ap_prepay_history_all: ' || SQL%ROWCOUNT);

            UPDATE ap_prepay_app_dists apad
               SET apad.bc_event_id = l_event_id
             WHERE apad.prepay_app_distribution_id = p_tab_fc_dist(i).inv_distribution_id
               AND (apad.bc_event_id IS NULL OR apad.bc_event_id = p_tab_fc_dist(i).bc_event_id);
            psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows updated of ap_prepay_app_dists: ' || SQL%ROWCOUNT);
          END IF;

          IF nvl(p_tab_fc_dist(i).SELF_ASSESSED_FLAG , 'N') = 'N' THEN
            UPDATE ap_invoice_distributions_all aid
               SET bc_event_id = l_event_id
             WHERE aid.invoice_id = p_tab_fc_dist(i).invoice_id
               AND aid.invoice_line_number = p_tab_fc_dist(i).inv_line_num
               AND aid.invoice_distribution_id = p_tab_fc_dist(i).inv_distribution_id;
            psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows updated of ap_invoice_distributions_all: ' || SQL%ROWCOUNT);
          ELSE  -- added by KS
            UPDATE ap_self_assessed_tax_dist_all sad
               SET bc_event_id = l_event_id
             WHERE sad.invoice_id = p_tab_fc_dist(i).invoice_id
               AND sad.invoice_line_number = p_tab_fc_dist(i).inv_line_num
               AND sad.invoice_distribution_id = p_tab_fc_dist(i).inv_distribution_id;
            psa_utils.debug_other_string(g_state_level,l_api_name,'Number o f rows updated of ap_self_assesed_tax_dist_all: '            || SQL%ROWCOUNT);
          END IF;

        END IF;
      END IF;
    END LOOP;

    IF l_bc_event_count = 0 THEN
      psa_utils.debug_other_string(g_state_level,l_api_name,'No events have been generated');
      RETURN;
    END IF;

    FOR i IN 1..l_bc_event_count LOOP
      psa_utils.debug_other_string(g_state_level,l_api_name,'Loop Index i = '||i||' Event id = '||l_bc_event_tab(i).event_id);
      INSERT INTO psa_bc_xla_events_gt
      (
        event_id,
        result_code
      )
      VALUES
      (
        l_bc_event_tab(i).event_id,
        'XLA_UNPROCESSED'
      );
      psa_utils.debug_other_string(g_state_level,l_api_name,'Number of rows inserted in psa_bc_xla_events_gt: ' || SQL%ROWCOUNT);
    END LOOP;


    IF (p_bc_mode <> 'C') THEN
      -- Checking for if prepay and non-prepay distributions are sharing the same bc event BEGIN
      -- AP poupulates the distributions for only one invoice at a time
      --Hence using p_tab_fc_dist(1).invoice_id to join on invoice id

      BEGIN
        psa_utils.debug_other_string(g_state_level,l_api_name,
        'Checking - Same bc_event_id stamped  for prepay as well non-prepay distributions');

        SELECT 'Same bc_event_id stamped  for prepay as well non-prepay distributions'
          INTO l_sameBCevent
          FROM ap_invoice_distributions_all aid1
         WHERE aid1.invoice_id = p_tab_fc_dist(1).invoice_id
           AND isprepaydist(aid1.invoice_distribution_id,aid1.invoice_id,aid1.line_type_lookup_code)='Y'
           AND aid1.bc_event_id IN (SELECT aid2.bc_event_id
                                      FROM ap_invoice_distributions_all aid2
                                     WHERE aid1.invoice_id = aid2.invoice_id
                                       AND isprepaydist( aid2.invoice_distribution_id,aid2.invoice_id,aid2.line_type_lookup_code)='N');

        x_return_status := Fnd_Api.G_Ret_Sts_Error;
        psa_utils.debug_other_string(g_error_level,l_api_name, ' PSA_AP_BC_PVT.CREATE_EVENT Failed ');
        psa_utils.debug_other_string(g_error_level,l_api_name, 'ERROR: Wrong BC event stamped on distributions for invoice id: '          || p_tab_fc_dist(1).invoice_id );
        fnd_message.set_name('PSA','PSA_AP_BC_STAMPING_ERROR');
        fnd_message.set_token('INVOICE_ID',p_tab_fc_dist(1).invoice_id);
        psa_bc_xla_pvt.psa_xla_error ('PSA_AP_BC_STAMPING_ERROR');

        fnd_message.set_name('PSA','PSA_AP_BC_STAMPING_ERROR');
        fnd_message.set_token('INVOICE_ID',p_tab_fc_dist(1).invoice_id);
        Fnd_Msg_Pub.ADD;
        Fnd_Msg_Pub.Count_And_Get
        (
          p_count   => x_msg_count,
          p_data    => x_msg_data
        );
        RETURN;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          psa_utils.debug_other_string(g_state_level,l_api_name, ' Sucussful - NO duplicate stamping');
      END;
    END IF;
    -- Checking wrong bc event stamped on item/prepay distribution END
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_Ret_Sts_Error;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                    'Invoice_id  = '|| to_char(p_tab_fc_dist(1).invoice_id)
                ||',Calling_Mode = '|| p_calling_mode);
      END IF;
      psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_excep_level,l_api_name,'Error in Create_Events  Procedure' );
      Fnd_Msg_Pub.Count_And_Get
      (
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
       --APP_EXCEPTION.RAISE_EXCEPTION; --Bug 5149493
      psa_utils.debug_other_string(g_state_level,l_api_name,'End of Procedure Create_Events' );
  END Create_Events;

  ---------------------------------------------------------------------------

  PROCEDURE Get_Detailed_Results
  (
    p_init_msg_list    IN  VARCHAR2,
    p_tab_fc_dist      IN OUT NOCOPY Funds_Dist_Tab_Type,
    p_calling_sequence IN VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name    VARCHAR(240);
    l_curr_calling_sequence VARCHAR2(2000);
    l_debug_loc             VARCHAR2(30) := 'Get_Detailed_Results';
    l_log_msg               VARCHAR2(2000);

  BEGIN
    l_api_name := g_full_path || '.Get_Detailed_Results';
    x_return_status := Fnd_Api.G_Ret_Sts_Success;
    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of Procedure Get_Detailed_Results' );
    IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
    END IF;

    -- Update the calling sequence --
    l_curr_calling_sequence := 'PSA_AP_BC_PVT.'||l_debug_loc|| '<-'||p_calling_sequence;

    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST  LOOP
      IF (p_tab_fc_dist(i).distribution_type = 'PREPAY') THEN

       BEGIN
        SELECT DECODE(MIN(p.status_code),'A', 'S', 'F'),
               MIN(p.status_code)
          INTO p_tab_fc_dist(i).result_code,
               p_tab_fc_dist(i).status_code
          FROM psa_bc_xla_events_gt e,
               gl_bc_packets p,
               xla_distribution_links xdl,
               ap_prepay_app_dists apad
         WHERE xdl.event_id = e.event_id
           AND apad.PREPAY_APP_DISTRIBUTION_ID = p_tab_fc_dist(i).inv_distribution_id
           AND xdl.source_distribution_id_num_1 = APAD.Prepay_App_Dist_ID
           AND apad.bc_event_id = xdl.event_id
           AND p.event_id =  xdl.event_id
           AND p.source_distribution_id_num_1 = xdl.source_distribution_id_num_1
           AND p.source_distribution_type = xdl.source_distribution_type
           AND p.ae_header_id = xdl.ae_header_id
           AND p.ae_line_num = xdl.ae_line_num
         GROUP BY apad.PREPAY_APP_DISTRIBUTION_ID;
        EXCEPTION
         WHEN no_data_found THEN
	      p_tab_fc_dist(i).result_code := 'F';
              p_tab_fc_dist(i).status_code := NULL;
       END;

      ELSE

       BEGIN
        SELECT DECODE(MIN(p.status_code),'A', 'S', 'F'),
               MIN(p.status_code)
          INTO p_tab_fc_dist(i).result_code,
               p_tab_fc_dist(i).status_code
          FROM psa_bc_xla_events_gt e,
               gl_bc_packets p,
               xla_distribution_links xdl
         WHERE xdl.event_id = e.event_id
           AND xdl.source_distribution_id_num_1 = p_tab_fc_dist(i).inv_distribution_id
           AND p.event_id =  xdl.event_id
           AND p.source_distribution_id_num_1 = xdl.source_distribution_id_num_1
           AND p.source_distribution_type = xdl.source_distribution_type
           AND p.ae_header_id = xdl.ae_header_id
           AND p.ae_line_num = xdl.ae_line_num
         GROUP BY p.source_distribution_id_num_1;
        EXCEPTION
         WHEN no_data_found THEN
              p_tab_fc_dist(i).result_code := 'F';
              p_tab_fc_dist(i).status_code := NULL;
        END;

      END IF;

      psa_utils.debug_other_string(g_state_level ,l_api_name ,' Distribution ID:'|| p_tab_fc_dist(i).inv_distribution_id||
                                                              ', Result Code: '||p_tab_fc_dist(i).result_code||
                                                              ', Status Code: '||p_tab_fc_dist(i).status_code );

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_Ret_Sts_Error;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice_id  = '|| to_char(p_tab_fc_dist(1).invoice_id));
      END IF;

      psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: '|| SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_excep_level,l_api_name,'Error in Get_Detailed_Results  Procedure' );
      Fnd_Msg_Pub.Count_And_Get
      (
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

      --APP_EXCEPTION.RAISE_EXCEPTION; --Bug 5149493
      psa_utils.debug_other_string(g_state_level,l_api_name,'End of Procedure Get_Detailed_Results' );
  END Get_Detailed_Results;


  /*============================================================================
  |  FUNCTION  -  GET_EVENT_SECURITY_CONTEXT(PRIVATE)
  |
  |  DESCRIPTION
  |    This function is used to get the event security context.
  |
  |  PRAMETERS:
  |         p_org_id: Organization ID
  |         p_calling_sequence: Debug information
  |
  |  RETURN: XLA_EVENTS_PUB_PKG.T_SECURITY
  |
  |  KNOWN ISSUES:
  |
  |  NOTES:
  |
  |  MODIFICATION HISTORY
  |  Date         Author             Description of Change
  |
  *===========================================================================*/

  FUNCTION get_event_security_context
  (
     p_org_id           IN NUMBER,
     p_calling_sequence IN VARCHAR2
  )
  RETURN XLA_EVENTS_PUB_PKG.T_SECURITY
  IS

    l_event_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;

    -- Logging:
    l_api_name  VARCHAR(240);

  BEGIN
    l_api_name := g_full_path || '.get_event_security_context';

    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of Procedure get_event_security_context' );

    l_event_security_context.security_id_int_1 := p_org_id;
    psa_utils.debug_other_string(g_state_level,l_api_name,'security_id_int_1:' ||l_event_security_context.security_id_int_1 );

    psa_utils.debug_other_string(g_state_level,l_api_name,'End of Procedure get_event_security_context' );

    RETURN l_event_security_context;
  END get_event_security_context;


  /*============================================================================
  |  PROCEDURE  GET_GL_FUNDSCHK_RESULT_CODE
  |
  |  DESCRIPTION
  |      Procedure to retrieve the GL_Fundschecker result code after the
  |      GL_Fundschecker has been run.
  |
  |  PARAMETERS
  |      p_packet_id:  Invoice Id
  |      p_fc_result_code :  Variable to contain the gl funds checker result
  |                          code
  |
  |  NOTE
  |
  |  MODIFICATION HISTORY
  |  Date         Author             Description of Change
  |
  *==========================================================================*/

  PROCEDURE Get_GL_FundsChk_Result_Code
  (
    p_fc_result_code  IN OUT NOCOPY VARCHAR2
  ) IS

    l_api_name        VARCHAR(240);
    l_debug_loc       VARCHAR2(30) := 'Get_GL_FundsChk_Result_Code';
    l_debug_info      VARCHAR2(100);

  BEGIN
    l_api_name := g_full_path || '.Get_GL_FundsChk_Result_Code';
    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of Procedure Get_GL_FundsChk_Result_Code' );

    ---------------------------------------------------------------
    -- Retrieve GL Fundschecker Failure Result Code              --
    ---------------------------------------------------------------
    psa_utils.debug_other_string(g_state_level,l_api_name,'Retrieving GL Fundschecker Failure Result Code ');

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := l_debug_loc || ' - Retrieve GL Fundschecker ' ||   'Failure Result Code ';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info);
    END IF;

    BEGIN
      SELECT l.lookup_code
        INTO p_fc_result_code
        FROM gl_lookups l
       WHERE lookup_type = 'FUNDS_CHECK_RESULT_CODE'
         AND EXISTS ( SELECT 'x'
                        FROM gl_bc_packets bc,
                             psa_bc_xla_events_gt e
                       WHERE bc.event_id = e.event_id
                         AND bc.result_code like 'F%'
                         AND bc.result_code = l.lookup_code)
         AND rownum = 1;

      psa_utils.debug_other_string(g_state_level,l_api_name,'Result code:' ||p_fc_result_code );

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: Unknown Error in  Procedure Get_GL_FundsChk_Result_Code');
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Get_GL_FundsChk_Result_Code;


  /*============================================================================
  |  PRIVATE PROCEDURE  PROCESS_FUNDSCHK_FAILURE_CODE
  |
  |  DESCRIPTION
  |      Procedure to process the gl_fundschecker failure code. It updates
  |      all the unapproved invoice distributions associated for a invoice if
  |      p_dist_line_num is null or a particular invoice distribution line if
  |      p_dist_line_num is provided with the given packet_id. It then retrieves
  |      the gl_fundschecker failure result code and determines which message to
  |      return to let the user know why fundschecking failed.
  |
  |  PARAMETERS
  |      p_invoice_id:  Invoice Id
  |      p_inv_line_num
  |      p_dist_line_num
  |      p_packet_id
  |      p_return_message_name - Variable to contain the return message name
  |                              of why fundschecking failed to be populated by
  |                              the procedure.
  |      p_calling_sequence:  Debugging string to indicate path of module
  |                           calls to be printed out NOCOPY upon error.
  |
  |  NOTE
  |
  |  MODIFICATION HISTORY
  |  Date         Author             Description of Change
  |
  *==========================================================================*/

  PROCEDURE Process_Fundschk_Failure_Code
  (
    p_invoice_id             IN            NUMBER,
    p_inv_line_num           IN            NUMBER,
    p_dist_line_num          IN            NUMBER,
    p_return_message_name    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence       IN            VARCHAR2
  ) IS

    l_api_name              VARCHAR(240);
    l_fc_result_code        VARCHAR2(3);
    l_debug_loc             VARCHAR2(30) := 'Process_Fundschk_Failure_Code';
    l_curr_calling_sequence VARCHAR2(2000);

  BEGIN

    l_api_name := g_full_path || '.Process_Fundschk_Failure_Code';
    -- Update the calling sequence --
    l_curr_calling_sequence := 'PSA_AP_BC_PVT.'||l_debug_loc|| '<-'||p_calling_sequence;

    -----------------------------------------------------------
    -- Retrieve the failure result_code from gl fundschecker --
    -----------------------------------------------------------
    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of procedure Process_Fundschk_Failure_Code');

    psa_utils.debug_other_string(g_state_level,l_api_name,'Calling Get_GL_Fundschk_Result_Code');

    Get_GL_Fundschk_Result_Code(l_fc_result_code);

    psa_utils.debug_other_string(g_state_level,l_api_name,'End of Get_GL_Fundschk_Result_Code');

    ------------------------------------------------------------
    -- Process gl fundscheck failure result code to determine --
    -- which failure message to return to the user            --
    ------------------------------------------------------------

    BEGIN

      SELECT meaning
        INTO p_return_message_name
        FROM fnd_lookups
       WHERE lookup_type = 'FUNDS_CHECK_RESULT_CODE'
         AND lookup_code = l_fc_result_code;

    EXCEPTION
      WHEN no_data_found THEN
        ---------------------------------------------------------------
        -- return generic failure message
        ---------------------------------------------------------------
        p_return_message_name := 'AP_FCK_FAILED_FUNDSCHECKER';
        psa_utils.debug_other_string(g_error_level,l_api_name,'No Data Found');
    END;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice_id  = '|| to_char(p_invoice_id)
                                            ||', Dist_line_num = '|| to_char(p_dist_line_num));
      END IF;

      psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: Unknown Error in Process_Fundschk_Failure_Code Procedure');
      APP_EXCEPTION.RAISE_EXCEPTION;

      psa_utils.debug_other_string(g_state_level,l_api_name,'End of procedure Process_Fundschk_Failure_Code');

  END Process_Fundschk_Failure_Code;

   ---------------------------------------------------------------------------

  FUNCTION get_event_type_code
  (
    p_inv_dist_id       IN NUMBER,
    p_invoice_type_code IN VARCHAR2,
    p_distribution_type IN VARCHAR2,
    p_distribution_amount IN NUMBER,
    p_calling_mode IN VARCHAR2,
    p_bc_mode IN VARCHAR2
  ) RETURN VARCHAR2
  IS

    CURSOR c_get_parent_dist_id (p_inv_dist_id NUMBER) IS
    SELECT charge_applicable_to_dist_id
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;
    -- Bug-7484486 .Added AMOUNT COLUMN IN THE SELECT

    CURSOR c_get_parent_dist_type (p_inv_dist_id NUMBER) IS
    SELECT line_type_lookup_code parent_dist_type,
           amount parent_dist_amount
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    l_event_type_code  VARCHAR2(30);
    l_parent_dist_id    NUMBER;
    l_distribution_type VARCHAR2(30);
    -- Logging:
    l_api_name         VARCHAR(240);
    l_distribution_amount NUMBER;

  BEGIN

    l_api_name := g_full_path || '.get_event_type_code';

    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of procedure get_event_type_code');
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_inv_dist_id: ' ||p_inv_dist_id);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_invoice_type_code: '||p_invoice_type_code);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_distribution_type: '||p_distribution_type);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_distribution_amount: '||p_distribution_amount);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_calling_mode: '||p_calling_mode);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_bc_mode: '||p_bc_mode);

    -- Initialize Distribution Type
    l_distribution_type := p_distribution_type;

    l_distribution_amount := p_distribution_amount;

    OPEN c_get_parent_dist_id(p_inv_dist_id);
    FETCH c_get_parent_dist_id
     INTO l_parent_dist_id;
    CLOSE c_get_parent_dist_id;

    -- Check whether current distribution is a related to main distribution
    -- It's the indicator that it could be e.g. REC_TAX or NONREC_TAX lines
    -- related to MAIN ITEM/PREPAY LINE.
    -- Bug-7484486. Also fetching amount from the cursor
    IF (l_parent_dist_id IS NOT NULL) THEN
      OPEN c_get_parent_dist_type(l_parent_dist_id);
      FETCH c_get_parent_dist_type
       INTO l_distribution_type, l_distribution_amount;
      CLOSE c_get_parent_dist_type;
    END IF;

    -- Bug-7484486.Replaced the p_distribution_amount by l_distribution_amount
    IF p_bc_mode = 'C' AND l_distribution_type = 'PREPAY' THEN
      l_event_type_code := 'INVOICE VALIDATED';
    ELSIF l_distribution_type = 'PREPAY' AND l_distribution_amount < 0 THEN
      l_event_type_code := 'PREPAYMENT APPLIED';
    ELSIF l_distribution_type = 'PREPAY' AND l_distribution_amount >= 0 THEN
      l_event_type_code := 'PREPAYMENT UNAPPLIED';
    ELSE
      SELECT decode(p_invoice_type_code, 'CREDIT','CREDIT MEMO',
                                         'DEBIT', 'DEBIT MEMO',
                                         'PREPAYMENT','PREPAYMENT',
                                         'INVOICE')||
                                         ' '|| decode(p_calling_mode,'CANCEL','CANCELLED','VALIDATED')
        INTO l_event_type_code
        FROM dual;
    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'Event Type Code:'||l_event_type_code );
    psa_utils.debug_other_string(g_state_level,l_api_name,'End of procedure get_event_type_code');
    RETURN l_event_type_code;

  END get_event_type_code;

  ---------------------------------------------------------------------------
  PROCEDURE Reinstate_PO_Encumbrance
  (
  p_calling_mode     IN VARCHAR2,
  p_tab_fc_dist      IN Funds_Dist_Tab_Type,
  p_calling_sequence IN VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2

  ) IS
    CURSOR cur_check_matched_invoices
    (
      p_invoice_id NUMBER,
      p_invoice_dist_id NUMBER,
      p_org_id NUMBER
    )
    IS
    SELECT 1
      FROM ap_invoice_distributions_all
     WHERE invoice_id = p_invoice_id
       AND invoice_distribution_id = p_invoice_dist_id
       AND org_id =p_org_id
       AND po_distribution_id is not null;

    CURSOR cur_process_fc_dists
    (
      p_invoice_id NUMBER,
      p_invoice_dist_id NUMBER,
      p_inv_line_num NUMBER,
      p_org_id NUMBER,
      p_sob NUMBER
    ) IS
    SELECT d.dist_code_combination_id,
           d.po_distribution_id,
           PD.code_combination_id,
           nvl(D.quantity_invoiced, 0),
           nvl(PD.quantity_ordered,0)- nvl(PD.quantity_cancelled,0),
           nvl(PD.amount_ordered,0) - nvl(PD.amount_cancelled,0),
           nvl(D.exchange_rate, 1),
           nvl(PLL.match_option, 'P'),
           PLT.matching_basis,
           D.matched_uom_lookup_code,
           RSL.item_id,
           PLL.unit_meas_lookup_code,
           nvl(D.amount, 0),
           decode(I.invoice_currency_code,
           SP.base_currency_code,nvl(D.amount,0),
           nvl(D.base_amount,0)),
           nvl(D.base_invoice_price_variance, 0),
           nvl(D.base_quantity_variance, 0),
           nvl(D.exchange_rate_variance, 0),
           NVL(PD.accrue_on_receipt_flag,'N'),
           I.invoice_currency_code,
           D.accounting_date,
           D.period_name,
           PER.period_num,
           PER.period_year,
           PER.quarter_num,
           D.line_type_lookup_code,
           nvl(D.tax_recoverable_flag, 'N'),
           PD.recovery_rate,
           PLL.tax_code_id,
           nvl(D.base_amount_variance,0),
           I.invoice_date,
           I.vendor_id,
           I.vendor_site_id,
           decode(I.invoice_currency_code,SP.base_currency_code,1,nvl(PD.rate,1)),
           nvl(PLL.price_override,0)
      FROM ap_invoice_distributions D,
           ap_invoices_all I,
           ap_invoice_lines L,
           po_distributions PD,
           po_lines PL,
           po_line_types PLT,
           po_line_locations PLL,
           po_headers PH,
           rcv_transactions RTXN,
           rcv_shipment_lines RSL,
           gl_period_statuses PER,
           po_vendors V,
           ap_system_parameters SP
     WHERE D.invoice_id = I.invoice_id
       AND D.invoice_line_number = L.line_number
       AND I.invoice_id = p_invoice_id
       AND D.invoice_distribution_id = p_invoice_dist_id
       AND L.line_number = p_inv_line_num
       AND I.org_id =p_org_id
       AND L.invoice_id = D.invoice_id
       AND nvl(SP.org_id,-999) = nvl(I.org_id,-999)
       AND I.vendor_id = V.vendor_id
       AND D.po_distribution_id = PD.po_distribution_id
       AND PD.line_location_id = PLL.line_location_id
       AND PL.po_header_id = PD.po_header_id
       AND PLT.line_type_id = PL.line_type_id
       AND PD.po_header_id = PH.po_header_id
       AND PL.po_line_id = PD.po_line_id
       AND D.rcv_transaction_id = RTXN.transaction_id (+)
       AND RTXN.shipment_line_id = RSL.shipment_line_id (+)
       AND D.posted_flag in ('N', 'P')
       AND nvl(D.encumbered_flag, 'N') in ('N', 'H', 'P')
       AND (D.line_type_lookup_code <> 'AWT' OR D.line_type_lookup_code <> 'REC_TAX')
       AND (D.line_type_lookup_code <> 'PREPAY'AND D.prepay_tax_parent_id IS NULL)
       AND D.period_name = PER.period_name
       AND PER.set_of_books_id = p_sob
       AND PER.application_id = 200
       AND NVL(PER.adjustment_period_flag, 'N') = 'N'
       AND D.match_status_flag = 'S'
       AND (NOT EXISTS (SELECT 'X'
                          FROM ap_holds H,
                               ap_hold_codes C
                         WHERE H.invoice_id = D.invoice_id
                           AND ( H.line_location_id is null OR H.line_location_id = PLL.line_location_id )
                           AND  H.hold_lookup_code = C.hold_lookup_code
                           AND  H.release_lookup_code IS NULL
                           AND ((C.postable_flag = 'N') OR (C.postable_flag = 'X'))
                           AND H.hold_lookup_code <> 'CANT FUNDS CHECK'
                           AND H.hold_lookup_code <> 'INSUFFICIENT FUNDS'));

    CURSOR c_get_dist_info
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT parent_reversal_id,
           encumbered_flag
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    CURSOR c_get_bc_event_id
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT bc_event_id
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;



    l_log_msg             FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
    l_debug_loc           VARCHAR2(30) := 'Reinstate_PO_Encumbrance';
    l_dist_ccid		        NUMBER(15);
    l_po_dist_id          NUMBER(15);
    l_po_expense_ccid	    NUMBER;
    l_qty_invoiced	      NUMBER;
    l_po_qty		          NUMBER;
    l_po_amt              NUMBER;
    l_inv_rate		        NUMBER;
    l_match_option        VARCHAR2(1);
    l_match_basis         po_line_types.matching_basis%type;
    l_rtxn_uom            VARCHAR2(30);
    l_rtxn_item_id        NUMBER;
    l_po_uom              VARCHAR2(30);
    l_dist_line_amt       NUMBER;
    l_base_dist_line_amt  NUMBER;
    l_bipv                NUMBER;
    l_bqv                 NUMBER;
    l_erv                 NUMBER;
    l_accrue_on_receipt_flag VARCHAR2(1);
    l_inv_currency_code   VARCHAR2(15);
    l_accounting_date     DATE;
    l_period_name         VARCHAR2(15);
    l_period_num          NUMBER(15);
    l_period_year         NUMBER(15);
    l_quarter_num         NUMBER(15);
    l_dist_line_type      VARCHAR2(15);
    l_tax_recov_flag      VARCHAR2(1);
    l_po_tax_rate         NUMBER;
    l_po_recov_rate       NUMBER;
    l_tax_code_id         NUMBER(15);
    l_bav                 NUMBER;
    l_invoice_date        DATE;
    l_match_rows          NUMBER;
    l_calling_sequence    VARCHAR2(100);
    l_uom_conv_rate       NUMBER;
    l_inv_qty             NUMBER;
    l_po_erv              NUMBER;
    l_base_reverse_po_enc_amt NUMBER;
    l_tax_unencumber_amt  NUMBER;
    l_inventory_org_id financials_system_parameters.inventory_organization_id%type;
    l_total_tax_rate NUMBER := 0;
    l_tax_rate       NUMBER;
    l_tax_recov_rate NUMBER;
    l_vendor_id      po_vendors.vendor_id%type;
    l_vendor_site_id po_vendor_sites.vendor_site_id%type;
    l_po_rate        NUMBER;
    l_po_price       NUMBER;

    TYPE po_api_rec_type IS RECORD
    (
      l_api_po_dist_id number(15),
      l_api_inv_id     number,
      l_api_rev_po_enc_amt number,
      l_api_po_qty         number,
      l_api_ccid           number(15),
      l_api_date           date,
      l_api_period_name    VARCHAR2(15),
      l_api_period_year    NUMBER(15),
      l_api_period_num     NUMBER(15),
      l_api_quarter_num    NUMBER(15),
      l_api_tax_flag       VARCHAR2(1)
    );

    TYPE po_api_table_type IS TABLE OF po_api_rec_type INDEX BY BINARY_INTEGER;

    po_api_table_t        po_api_table_type;
    l_api_name            VARCHAR2(240);
    l_po_api_counter      NUMBER := 0;
    l_po_packet_id        NUMBER;
    l_return_status       VARCHAR2(10);
    l_process_dist        BOOLEAN;
    l_encum_flag          VARCHAR2(1);
    l_parent_reversal_id  AP_INVOICE_DISTRIBUTIONS_ALL.parent_reversal_id%TYPE;
    l_bc_event_id         NUMBER;

  BEGIN

    l_calling_sequence := substr('Reinstate_PO_Enc'||'<-'||p_calling_sequence,1,100);
    l_api_name := g_full_path || '.Reinstate_PO_Encumbrance';

    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of procedure Reinstate_PO_Encumbrance');
    -- Initiliaze the local variables
    l_match_rows := 0;
    l_process_dist := TRUE;

    -- Start process
    FOR i IN p_tab_fc_dist.FIRST..p_tab_fc_dist.LAST  LOOP --PLSQL table loop
      psa_utils.debug_other_string(g_state_level,l_api_name,'Invoice Id = '||p_tab_fc_dist(i).invoice_id);
      psa_utils.debug_other_string(g_state_level,l_api_name,'Invoice Distribution id = '||p_tab_fc_dist(i).inv_distribution_id);
      psa_utils.debug_other_string(g_state_level,l_api_name,'Invoice Line Number = '||p_tab_fc_dist(i).inv_line_num);
      psa_utils.debug_other_string(g_state_level,l_api_name,'Org id = '||p_tab_fc_dist(i).org_id);
      psa_utils.debug_other_string(g_state_level,l_api_name,'Set of Books id = '||p_tab_fc_dist(i).set_of_books_id);

      /* Check for Invoice CANCEL event, we will not pick the distribution
      which are not encumbered and their related cancel line bind by
      parent_reversal_id */

      l_process_dist := TRUE;

      OPEN c_get_dist_info(p_tab_fc_dist(i).inv_distribution_id);
      FETCH c_get_dist_info
       INTO l_parent_reversal_id,
            l_encum_flag;
      CLOSE c_get_dist_info;

      psa_utils.debug_other_string(g_state_level,l_api_name, 'l_parent_reversal_id = '||l_parent_reversal_id);
      psa_utils.debug_other_string(g_state_level,l_api_name, 'l_encum_flag = '||l_encum_flag);

      IF (l_parent_reversal_id IS NULL AND NVL(l_encum_flag, 'N') = 'N') THEN
        l_process_dist := FALSE;

        psa_utils.debug_other_string(g_state_level,l_api_name,'Found non-encumbered distribution :'||p_tab_fc_dist(i).inv_distribution_id);
        psa_utils.debug_other_string(g_state_level,l_api_name,'We will not process this distribution :'||p_tab_fc_dist(i).inv_distribution_id);

      ELSIF (l_parent_reversal_id IS NOT NULL) THEN

        OPEN c_get_bc_event_id(l_parent_reversal_id);
        FETCH c_get_bc_event_id
         INTO l_bc_event_id;
        CLOSE c_get_bc_event_id;

        OPEN c_get_dist_info(l_parent_reversal_id);
        FETCH c_get_dist_info
         INTO l_parent_reversal_id,
              l_encum_flag;
        CLOSE c_get_dist_info;

        -- Check If the Invoice is cancelled then we need to call PO Reinstate
        IF ((p_calling_mode = 'CANCEL') AND (l_bc_event_id IS NULL)) THEN
          l_process_dist := TRUE;

        ELSIF (NVL(l_encum_flag, 'N') = 'N') THEN
          l_process_dist := FALSE;
          psa_utils.debug_other_string(g_state_level,l_api_name,'Found non-encumbered reversal distribution :'||p_tab_fc_dist(i).inv_distribution_id);
          psa_utils.debug_other_string(g_state_level,l_api_name,'We will not process this distribution :'||p_tab_fc_dist(i).inv_distribution_id);
        END IF;
      END IF;

      IF l_process_dist THEN
        OPEN cur_process_fc_dists
        (
          p_tab_fc_dist(i).invoice_id,
          p_tab_fc_dist(i).inv_distribution_id,
          p_tab_fc_dist(i).inv_line_num,
          p_tab_fc_dist(i).org_id,
          p_tab_fc_dist(i).set_of_books_id
        );

        LOOP --cursor starts
          FETCH cur_process_fc_dists
           INTO l_dist_ccid,
                l_po_dist_id,
                l_po_expense_ccid,
                l_qty_invoiced,
                l_po_qty,
                l_po_amt,
                l_inv_rate,
                l_match_option,
                l_match_basis,
                l_rtxn_uom,
                l_rtxn_item_id,
                l_po_uom,
                l_dist_line_amt,
                l_base_dist_line_amt,
                l_bipv,
                l_bqv,
                l_erv,
                l_accrue_on_receipt_flag,
                l_inv_currency_code,
                l_accounting_date,
                l_period_name,
                l_period_num,
                l_period_year,
                l_quarter_num,
                l_dist_line_type,
                l_tax_recov_flag,
                l_po_recov_rate,
                l_tax_code_id,
                l_bav,
                l_invoice_date,
                l_vendor_id,
                l_vendor_site_id,
                l_po_rate,
                l_po_price;

          IF cur_process_fc_dists%NOTFOUND THEN
            psa_utils.debug_other_string(g_state_level,l_api_name,'Invoice distribution not matched to PO ');

            CLOSE  cur_process_fc_dists;
            EXIT;
          END IF;

          IF l_po_dist_id IS NOT NULL THEN

            psa_utils.debug_other_string(g_state_level,l_api_name,'Matced PO distribution id ');

            l_po_api_counter := l_po_api_counter +1;

            --convert quantity invoiced to PO uom
            IF l_po_uom <>l_rtxn_uom THEN
              l_uom_conv_rate := po_uom_s.po_uom_convert
              (
                l_rtxn_uom,
                l_po_uom,
                l_rtxn_item_id
              );

              psa_utils.debug_other_string(g_state_level,l_api_name,'UOM Conversion Rate =  '||l_uom_conv_rate);

            END IF;

            --Not a Tax Distribution Line
            IF l_dist_line_type <>'TAX' THEN
              psa_utils.debug_other_string(g_state_level,l_api_name,'Distribution line Type = '||l_dist_line_type);
              psa_utils.debug_other_string(g_state_level,l_api_name,'Match Basis = '||l_match_basis);

              IF l_match_basis = 'QUANTITY' THEN

                if l_po_uom <> l_rtxn_uom then
                  l_inv_qty := round(l_qty_invoiced * l_uom_conv_rate,5);
                else
                  l_inv_qty := l_qty_invoiced;
                end if;

                psa_utils.debug_other_string(g_state_level,l_api_name,'Invoice Quantity = '||l_inv_qty);

                l_po_erv := AP_UTILITIES_PKG.ap_round_currency
                            (
                              ((l_inv_rate - l_po_rate) * (l_inv_qty * l_po_price)),
                              l_inv_currency_code
                            );
                psa_utils.debug_other_string(g_state_level,l_api_name,'PO erv = '||l_po_erv);

                IF l_match_option ='P' THEN /* match option starts */
                  l_base_reverse_po_enc_amt := l_base_dist_line_amt - (l_bqv + l_bipv + l_erv);
                ELSIF l_match_option = 'R' THEN
                  l_base_reverse_po_enc_amt := l_base_dist_line_amt - (l_bqv + l_bipv + l_po_erv);
                END IF; /* match option ends*/

                psa_utils.debug_other_string(g_state_level,l_api_name,'Base Reverse PO enc amount = '||l_base_reverse_po_enc_amt);

              ELSE
                l_po_erv :=  AP_UTILITIES_PKG.ap_round_currency
                             (
                               ((l_inv_rate - l_po_rate) *  l_dist_line_amt),
                               l_inv_currency_code
                             );

                psa_utils.debug_other_string(g_state_level,l_api_name,'PO erv = '||l_po_erv);

                IF l_match_option ='P' THEN /* match option starts */
                  l_base_reverse_po_enc_amt := l_base_dist_line_amt - (l_bav + l_bipv + l_erv);
                ELSIF l_match_option = 'R' THEN
                  l_base_reverse_po_enc_amt := l_base_dist_line_amt - (l_bav + l_bipv + l_po_erv);
                END IF; /* match option ends */

                psa_utils.debug_other_string(g_state_level,l_api_name,'Base Reverse PO enc amount = '||l_base_reverse_po_enc_amt);

              END IF; /* match basis 'QUANTITY' */

              po_api_table_t(l_po_api_counter).l_api_rev_po_enc_amt :=  l_base_reverse_po_enc_amt * (-1);
              po_api_table_t(l_po_api_counter).l_api_tax_flag       := 'N';

              if l_match_option = 'R' then
                po_api_table_t(l_po_api_counter).l_api_po_qty := nvl(l_inv_qty,0);
              else
                po_api_table_t(l_po_api_counter).l_api_po_qty := nvl(l_qty_invoiced,0);
              end if;

            END IF;  /* l_dist_line_type <>'TAX' */

            psa_utils.debug_other_string(g_state_level,l_api_name,'Distribution line Type = '||l_dist_line_type);

            --Tax distribution line
            IF l_dist_line_type IN ('TAX','NONREC_TAX') THEN

              l_tax_unencumber_amt := AP_UTILITIES_PKG.ap_round_currency
                                     (
                                       l_base_reverse_po_enc_amt * (nvl(l_po_rate/100,0)*(100-nvl(l_po_recov_rate,0))/100),
                                       l_inv_currency_code
                                     );

              psa_utils.debug_other_string(g_state_level,l_api_name,'Tax Unencumberance Amount = '||l_tax_unencumber_amt);

              po_api_table_t(l_po_api_counter).l_api_rev_po_enc_amt := l_tax_unencumber_amt * (-1);
              po_api_table_t(l_po_api_counter).l_api_tax_flag       := 'Y';
              po_api_table_t(l_po_api_counter).l_api_po_qty         := 0;

            END IF; /* l_dist_line_type in TAX,NONREC_TAX */

            po_api_table_t(l_po_api_counter).l_api_po_dist_id      := l_po_dist_id;
            po_api_table_t(l_po_api_counter).l_api_inv_id          := p_tab_fc_dist(i).invoice_id;
            po_api_table_t(l_po_api_counter).l_api_ccid            := l_dist_ccid;
            po_api_table_t(l_po_api_counter).l_api_date            := l_accounting_date;
            po_api_table_t(l_po_api_counter).l_api_period_name     := l_period_name;
            po_api_table_t(l_po_api_counter).l_api_period_year     := l_period_year;
            po_api_table_t(l_po_api_counter).l_api_period_num      := l_period_num;
            po_api_table_t(l_po_api_counter).l_api_quarter_num     := l_quarter_num;
          ELSE -- not matched po case
          psa_utils.debug_other_string(g_state_level,l_api_name,'Invoice distribution not matched to PO ');

          END IF; -- close for matched case

        END LOOP; --cursor end loop

      END IF; /* l_process_dist */

    END LOOP; --PLSQL end loop

    x_return_status := Fnd_Api.G_Ret_Sts_Success;
    IF po_api_table_t.count > 0 THEN
      psa_utils.debug_other_string(g_state_level,l_api_name,'po_api_table_t.count '||po_api_table_t.count);
      FOR i IN po_api_table_t.FIRST..po_api_table_t.LAST LOOP

        psa_utils.debug_other_string(g_state_level,l_api_name,'Invoking PO_INTG_DOCUMENT_FUNDS_GRP.Reinstate_PO_Encumbrance ');


        PO_INTG_DOCUMENT_FUNDS_GRP.reinstate_po_encumbrance
        (
          p_api_version        => 1.0,
          p_commit             => FND_API.G_FALSE,
          p_init_msg_list      => FND_API.G_FALSE,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          p_distribution_id    => po_api_table_t(i).l_api_po_dist_id,
          p_invoice_id         => po_api_table_t(i).l_api_inv_id,
          p_encumbrance_amt    => po_api_table_t(i).l_api_rev_po_enc_amt,
          p_qty_cancelled      => po_api_table_t(i).l_api_po_qty,
          p_budget_account_id  => po_api_table_t(i).l_api_ccid,
          p_gl_date            => po_api_table_t(i).l_api_date,
          p_period_name        => po_api_table_t(i).l_api_period_name,
          p_period_year        => po_api_table_t(i).l_api_period_year,
          p_period_num         => po_api_table_t(i).l_api_period_num,
          p_quarter_num        => po_api_table_t(i).l_api_quarter_num,
          x_packet_id          => l_po_packet_id,
          x_return_status      => l_return_status,
          p_tax_line_flag      => po_api_table_t(i).l_api_tax_flag
        );

        --return status
        IF l_return_status <> 'S' THEN
          psa_utils.debug_other_string(g_state_level,l_api_name,'Failed for PO distribution '||po_api_table_t(i).l_api_po_dist_id );
          x_return_status := Fnd_Api.G_Ret_Sts_Error;
          Exit;
        END IF;

      END LOOP;

      po_api_table_t.DELETE;
    ELSE
      psa_utils.debug_other_string(g_state_level,l_api_name,'Success - zero PO matched rows ' );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_Ret_Sts_Error;
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'Invoice_id  = '|| to_char(p_tab_fc_dist(1).invoice_id)
        ||',Calling_Mode = CANCEL ');
      END IF;
      psa_utils.debug_other_string(g_excep_level,l_api_name,'EXCEPTION: Unknown Error in Reinstate_PO_Encumbrance Procedure');
      Fnd_Msg_Pub.Count_And_Get
      (
        p_count   => x_msg_count,
        p_data    => x_msg_data
      );

      --APP_EXCEPTION.RAISE_EXCEPTION; --Bug 5149493

  End Reinstate_PO_Encumbrance;

  FUNCTION Get_PO_Reversed_Encumb_Amount
  (
    P_Po_Distribution_Id   IN            NUMBER,
    P_Start_gl_Date        IN            DATE,
    P_End_gl_Date          IN            DATE,
    P_Calling_Sequence     IN            VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER
  IS
    l_api_name              VARCHAR2(240);
    l_calling_sequence      VARCHAR2(2000);
    l_r12_upgrade_date      DATE;
    l_dist_creation_date    DATE;
    l_unencumbered_amount   NUMBER;
    l_r12_unencumbered_amount NUMBER;

    CURSOR cur_get_po_encum_rev_amt IS
    SELECT NVL(sum((NVL(dist.amount,0) - NVL(dist.amount_variance,0) - NVL(dist.quantity_variance,0))*nvl(pod.rate,1)), 0) po_reversed_encumbered_amount
      FROM xla_events evt,
           ap_invoice_distributions_all dist,
           po_distributions_all pod
     WHERE evt.event_status_code = 'P'
       AND ((p_start_gl_date is not null
           AND p_start_gl_date <= evt.transaction_date )
            OR(p_start_gl_date is null ))
       AND ((p_end_gl_date is not null
           AND p_end_gl_date >= evt.transaction_date )
            OR (p_end_gl_date is null ))
       AND evt.event_id = dist.bc_event_id
       AND evt.application_id = 200
       AND evt.event_type_code in ('INVOICE VALIDATED',
                                   'INVOICE ADJUSTED',
                                   'INVOICE CANCELLED',
                                   'CREDIT MEMO VALIDATED',
                                   'CREDIT MEMO ADJUSTED',
                                   'CREDIT MEMO CANCELLED',
                                   'DEBIT MEMO VALIDATED',
                                   'DEBIT MEMO ADJUSTED',
                                   'DEBIT MEMO CANCELLED')
       AND dist.po_distribution_id is not null
       AND dist.po_distribution_id = P_PO_Distribution_Id
       AND dist.po_distribution_id = pod.po_distribution_id --Added for bug 7592825
       AND dist.line_type_lookup_code NOT IN ('IPV', 'ERV', 'TIPV', 'TERV', 'TRV', 'QV', 'AV') -- added due to bug 5639595
       AND NOT EXISTS (SELECT 'X'
                         FROM ap_encumbrance_lines_all ael
                        WHERE ael.invoice_distribution_id = dist.invoice_distribution_id
                          AND encumbrance_type_id = 1001 );


    CURSOR cur_dist_creation_date
    (
      l_po_dist_id NUMBER
    ) IS
    SELECT creation_date
      FROM po_distributions_all
     WHERE po_distribution_id = l_po_dist_id;

  BEGIN
    l_api_name := g_full_path || '.Get_PO_Reversed_Encumb_Amount';
    l_unencumbered_amount := 0;

    l_calling_sequence := 'PSA_AP_BC_PVT.Get_PO_Reversed_Encumb_Amount -> '
    ||substr(p_calling_sequence,1,100);

    psa_utils.debug_other_string(g_state_level,l_api_name,'Calling Sequence :  ' || l_calling_sequence );
    psa_utils.debug_other_string(g_state_level,l_api_name,'PO Distribution Id : ' || P_Po_Distribution_Id );
    psa_utils.debug_other_string(g_state_level,l_api_name,'Start GL Date :' || P_Start_gl_Date );
    psa_utils.debug_other_string(g_state_level,l_api_name,'End GL Date :' || P_End_gl_Date );

    -- fetch the profile value
    l_r12_upgrade_date :=to_date(fnd_profile.value_wnps ('PSA_R12_UPGRADE_DATE'), 'MM/DD/RRRR HH24:MI:SS');
    psa_utils.debug_other_string(g_state_level,l_api_name,'PSA_R12_UPGRADE_DATE :' || l_r12_upgrade_date );


    OPEN cur_dist_creation_date(p_po_distribution_id);
    FETCH cur_dist_creation_date
     INTO l_dist_creation_date;
    CLOSE cur_dist_creation_date;

    psa_utils.debug_other_string(g_state_level,l_api_name,'Distribution creation Date :' || l_dist_creation_date );

    OPEN cur_get_po_encum_rev_amt;
    FETCH cur_get_po_encum_rev_amt
     INTO l_r12_unencumbered_amount;
    CLOSE cur_get_po_encum_rev_amt;

    psa_utils.debug_other_string(g_state_level,l_api_name,'R12 Unencumbered Amount from AP distributions: ' || l_r12_unencumbered_amount);
    psa_utils.debug_other_string(g_state_level,l_api_name,'Invoking AP_UTILITIES_PKG.Get_PO_Reversed_Encumb_Amount' );


    l_unencumbered_amount:=  ap_utilities_pkg.get_po_reversed_encumb_amount
                             (
                               p_po_distribution_id,
                               p_start_gl_date,
                               p_end_gl_date,
                               p_calling_sequence
                             );

    psa_utils.debug_other_string(g_state_level,l_api_name,'End of AP_UTILITIES_PKG.Get_PO_Reversed_Encumb_Amount' );
    psa_utils.debug_other_string(g_state_level,l_api_name,'Unencumbered Amount from AP_UTILITIES_PKG.Get_PO_Reversed_Encumb_Amount' || l_unencumbered_amount);

    l_unencumbered_amount := NVL(l_unencumbered_amount, 0) + NVL(l_r12_unencumbered_amount,0);

    psa_utils.debug_other_string(g_state_level,l_api_name,'Unencumbered Amount : ' || l_unencumbered_amount);
    RETURN l_unencumbered_amount;

  EXCEPTION
    WHEN OTHERS THEN
      psa_utils.debug_other_string(g_excep_level,l_api_name,'ERROR: ' || SQLERRM(sqlcode));
      psa_utils.debug_other_string(g_excep_level,l_api_name,'Error in Get_PO_Reversed_Encumb_Amount Procedure');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Get_PO_Reversed_Encumb_Amount;
 -------------------------------------------------------------
  FUNCTION isprepaydist
  (
    p_inv_dist_id       IN NUMBER,
    p_inv_id            IN NUMBER,
    p_dist_type         IN VARCHAR2
  ) RETURN VARCHAR2
  IS
    CURSOR c_get_parent_dist_id
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT charge_applicable_to_dist_id
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    CURSOR c_get_parent_dist_type
    (
      p_inv_dist_id NUMBER
    ) IS
    SELECT line_type_lookup_code parent_dist_type
      FROM ap_invoice_distributions_all
     WHERE invoice_distribution_id = p_inv_dist_id;

    l_parent_dist_id    NUMBER;
    l_distribution_type VARCHAR2(30);
    l_api_name         VARCHAR(240);
  BEGIN
    l_api_name := g_full_path || '.isprepaydist';

    psa_utils.debug_other_string(g_state_level,l_api_name,'Begin of function  isprepaydist');
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_inv_dist_id: '||p_inv_dist_id);
    psa_utils.debug_other_string(g_state_level,l_api_name,'p_dist_type:'||p_dist_type);

    -- Initialize Distribution Type
    l_distribution_type := p_dist_type;

    OPEN c_get_parent_dist_id(p_inv_dist_id);
    FETCH c_get_parent_dist_id
     INTO l_parent_dist_id;
    CLOSE c_get_parent_dist_id;

    -- Check whether current distribution is a related to main distribution
    -- It's the indicator that it could be e.g. REC_TAX or NONREC_TAX lines
    -- related to MAIN ITEM/PREPAY LINE.

    IF (l_parent_dist_id IS NOT NULL) THEN
      OPEN c_get_parent_dist_type(l_parent_dist_id);
      FETCH c_get_parent_dist_type
       INTO l_distribution_type;
      CLOSE c_get_parent_dist_type;
    END IF;

    psa_utils.debug_other_string(g_state_level,l_api_name,'l_distribution_ype:'||l_distribution_type);
    IF l_distribution_type <> 'PREPAY' THEN
      psa_utils.debug_other_string(g_state_level,l_api_name,'End of procedure isprepaydist');
      RETURN 'N';
    END IF;
      psa_utils.debug_other_string(g_state_level,l_api_name,'End of procedure isprepaydist');
    RETURN 'Y';
  END isprepaydist;
 -------------------------------------------------------------
BEGIN
  init;
END PSA_AP_BC_PVT;

/
