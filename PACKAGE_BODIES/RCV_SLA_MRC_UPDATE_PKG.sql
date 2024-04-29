--------------------------------------------------------
--  DDL for Package Body RCV_SLA_MRC_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SLA_MRC_UPDATE_PKG" AS
/* $Header: RCVPUMCB.pls 120.4 2006/04/24 00:00 bigoyal noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'RCV_SLA_MRC_UPDATE_PKG';
G_LOG_LEVEL    CONSTANT NUMBER  := fnd_log.G_CURRENT_RUNTIME_LEVEL;
gUserId        number := nvl(fnd_global.user_id, -888);
gLoginId       number := nvl(fnd_global.login_id, -888);
gUpdateDate    DATE := sysdate;

-------------------------------------------------------------------------------------
--  API name   : Update_Receiving_MRC_Subledger
--  Type       : Private
--  Function   : To update Receiving MRC Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_upg_batch_id     in number(15),
--                     X_je_category_name in varchar2(30)
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from CST_SLA_UPDATE_PKG.Update_RCV_Subledger
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Receiving_MRC_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_upg_batch_id      in number,
               X_je_category_name  in varchar2 default 'Receiving')
IS
   l_upg_batch_id number(15):=0;
   l_je_category_name varchar2(30);

   l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.RCV_SLA_MRC_UPDATE_PKG.Update_Receiving_MRC_Subledger';

   l_uLog         CONSTANT BOOLEAN := fnd_log.level_unexpected >= G_LOG_LEVEL AND
                                      fnd_log.TEST(fnd_log.level_unexpected, l_module);
   l_errorLog     CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= G_LOG_LEVEL;
   l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND fnd_log.level_exception >= G_LOG_LEVEL;
   l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND fnd_log.level_procedure >= G_LOG_LEVEL;

   l_stmt_num      number;

BEGIN
   l_stmt_num   :=0;

   IF l_plog THEN
     fnd_log.string(
       fnd_log.level_procedure,
       l_module||'.'||l_stmt_num,
       'Entering RCV_SLA_MRC_UPDATE_PKG.Update_Receiving_MRC_Subledger with '||
       'X_upg_batch_id = '||X_upg_batch_id||','||
       'X_je_category_name = '||X_je_category_name
     );
   END IF;

   l_upg_batch_id := X_upg_batch_id;

   l_je_category_name := X_je_category_name;

   x_retcode := FND_API.G_RET_STS_SUCCESS;

   insert all
       when (line_id=1) then
       into xla_ae_headers (
          upg_batch_id,
          application_id,
          AMB_CONTEXT_CODE,
          entity_id,
          event_id,
          event_type_code,
          ae_header_id,
          ledger_id,
          je_category_name,
          ACCOUNTING_DATE,
          PERIOD_NAME,
          BALANCE_TYPE_CODE,
          BUDGET_VERSION_ID,
          DOC_SEQUENCE_ID,
          DOC_SEQUENCE_VALUE,
          GL_TRANSFER_STATUS_CODE,
          GL_TRANSFER_DATE,
          ACCOUNTING_ENTRY_STATUS_CODE,
          ACCOUNTING_ENTRY_TYPE_CODE,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          UPG_SOURCE_APPLICATION_ID,
          description)
       values (
          upg_batch_id,
          application_id,
          AMB_CONTEXT_CODE,
          entity_id,
          event_id,
          event_type_code,
          xla_ae_headers_s.NEXTVAL,
          ledger_id,
          je_category_name,
          ACCOUNTING_DATE,
          PERIOD_NAME,
          BALANCE_TYPE_CODE,
          BUDGET_VERSION_ID,
          DOC_SEQUENCE_ID,
          DOC_SEQUENCE_VALUE,
          GL_TRANSFER_STATUS_CODE,
          GL_TRANSFER_DATE,
          ACCOUNTING_ENTRY_STATUS_CODE,
          ACCOUNTING_ENTRY_TYPE_CODE,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          UPG_SOURCE_APPLICATION_ID,
          description)
       select
          /*+ leading(cxs) use_nl(rrs rt rmt) index(rrs) index(rt) index(rmt) index(rae) index(gcc)*/
          l_upg_batch_id upg_batch_id,
          707 application_id,
          'DEFAULT' AMB_CONTEXT_CODE,
          cxs.entity_id entity_id,
          cxs.event_id event_id,
          event_type_code,
          rrs.set_of_books_id ledger_id,
          l_je_category_name je_category_name,
          rrs.accounting_date accounting_date,
          rrs.PERIOD_NAME PERIOD_NAME,
          rrs.actual_flag BALANCE_TYPE_CODE,
          rrs.budget_version_id BUDGET_VERSION_ID,
          rrs.SUBLEDGER_DOC_SEQUENCE_ID DOC_SEQUENCE_ID,
          rrs.SUBLEDGER_DOC_SEQUENCE_VALUE DOC_SEQUENCE_VALUE,
          'Y' GL_TRANSFER_STATUS_CODE,
          nvl(rrs.DATE_CREATED_IN_GL,rrs.accounting_date) GL_TRANSFER_DATE,
          'F' ACCOUNTING_ENTRY_STATUS_CODE,
          'STANDARD' ACCOUNTING_ENTRY_TYPE_CODE,
          rrs.creation_date creation_date,
          rrs.created_by created_by,
          rrs.last_update_date last_update_date,
          rrs.last_updated_by last_updated_by,
          rrs.last_update_login LAST_UPDATE_LOGIN,
          rrs.program_update_date PROGRAM_UPDATE_DATE,
          rrs.program_application_id PROGRAM_APPLICATION_ID,
          rrs.program_id PROGRAM_ID,
          rrs.request_id REQUEST_ID,
          201 UPG_SOURCE_APPLICATION_ID,
          rrs.je_header_name description,
          row_number() over(partition by rt.transaction_id,rae.accounting_event_id,NVL(rae.ORGANIZATION_ID, rt.ORGANIZATION_ID),rrs.set_of_books_id order by rt.transaction_id) as line_id
   from   rcv_mc_transactions rmt,
          rcv_transactions rt,
          rcv_accounting_events rae,
          rcv_mc_rec_sub_ledger rrs,
          cst_xla_rcv_event_map cem,
          GL_CODE_COMBINATIONS gcc,
          cst_xla_seq_gt cxs
   where  rt.transaction_id=cxs.source_id_int_1
          and rt.transaction_id = rmt.transaction_id
          and rmt.set_of_books_id = rrs.set_of_books_id
          and nvl(rae.organization_id,rt.organization_id)=cxs.source_id_int_3
          and rrs.rcv_transaction_id = rt.transaction_id
          and ((rae.accounting_event_id is not null
                  and rae.accounting_event_id = rrs.accounting_event_id
                  and rae.accounting_event_id = cxs.source_id_int_2)
                or (rae.accounting_event_id is null
                  and rrs.accounting_event_id is null)
              )
          and rrs.ENCUMBRANCE_TYPE_ID is null
          and rt.transaction_id = rae.rcv_transaction_id (+)
          and nvl(rae.EVENT_TYPE_ID,decode(rt.transaction_type,
                             'RECEIVE', 1, 'DELIVER', 2, 'CORRECT',3,
                             'MATCH', 4, 'RETURN TO RECEIVING', 5,
                             'RETURN TO VENDOR', 6, -1))=cem.transaction_type_id
          and (cem.transaction_type_id <> 3
               or
               (cem.transaction_type_id = 3
                and rt.PARENT_TRANSACTION_ID is not null
                and cem.attribute = (SELECT TRANSACTION_TYPE
                               FROM RCV_TRANSACTIONS rt1
                               WHERE  rt1.transaction_id =  rt.PARENT_TRANSACTION_ID))
               )
          and gcc.CODE_COMBINATION_ID=rrs.CODE_COMBINATION_ID;






       insert into xla_ae_lines (
          upg_batch_id,
          application_id,
          ae_header_id,
          ae_line_num,
          code_combination_id,
          gl_transfer_mode_code,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          CURRENCY_CONVERSION_TYPE,
          ENTERED_DR,
          ENTERED_CR,
          accounting_class_code,
          gl_sl_link_id,
          gl_sl_link_table,
          USSGL_TRANSACTION_CODE,
          CONTROL_BALANCE_FLAG,
          GAIN_OR_LOSS_FLAG,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          description,
          accounting_date,
          ledger_id)
          SELECT
          /*+ leading(cxs) use_nl(rrs rt rmt xla) index(rrs) index(rt) index(rmt) index(rae) index(gcc) index(xla)*/
          l_upg_batch_id,
          707,
          xla.ae_header_id,
          row_number() over(partition by rt.transaction_id,rae.accounting_event_id,NVL(rae.ORGANIZATION_ID, rt.ORGANIZATION_ID),rrs.set_of_books_id order by rt.transaction_id) as line_id,
          rrs.CODE_COMBINATION_ID ccid,
          'D' GL_Update_code,
          rrs.accounted_dr ACCOUNTED_DR,
          rrs.accounted_cr ACCOUNTED_CR,
          rrs.currency_code,
          rrs.CURRENCY_CONVERSION_DATE CURRENCY_CONVERSION_DATE,
          rrs.CURRENCY_CONVERSION_RATE CURRENCY_CONVERSION_RATE,
          rrs.USER_CURRENCY_CONVERSION_TYPE CURRENCY_CONVERSION_TYPE,
          rrs.entered_dr ENTERED_DR,
          rrs.entered_cr ENTERED_CR,
          decode(nvl(rrs.accounting_line_type,'888'),
                 'Accrual','ACCRUAL',
                 'Charge','CHARGE',
                 'Clearing','CLEARING',
                 'IC Accrual','INTERCOMPANY_ACCRUAL',
                 'IC Cost of Sales','INTERCOMPANY_COGS',
                 'Receiving Inspection','RECEIVING_INSPECTION',
                 'Retroprice Adjustment','RETROACTIVE_PRICE_ADJUSTMENT',
                 '888',decode(cem.transaction_type_id,
                             1, decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                             2, decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','CHARGE'),
                             3, decode(cem.attribute,
                                       'RECEIVE', decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                                       'MATCH', decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                                       'DELIVER', decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','CHARGE'),
                                       'RETURN TO VENDOR',decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','ACCRUAL'),
                                       'RETURN TO RECEIVING', decode(sign(rrs.accounted_cr),1,'CHARGE','RECEIVING_INSPECTION'),
                                       ''),
                             4, decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                             5, decode(sign(rrs.accounted_cr),1,'CHARGE','RECEIVING_INSPECTION'),
                             6, decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','ACCRUAL'),
                             ''),
                 'UNKNOWN') accounting_class_code,
          rrs.gl_sl_link_id link_id,
          'RSL' link_table,
          rrs.USSGL_TRANSACTION_CODE USSGL_TRANSACTION_CODE,
          decode(gcc.reference3,'Y', 'P', null) CONTROL_BALANCE_FLAG,
          'N',
          rrs.creation_date creation_date,
          rrs.created_by created_by,
          rrs.last_update_date last_update_date,
          rrs.last_updated_by last_updated_by,
          rrs.last_update_login LAST_UPDATE_LOGIN,
          rrs.program_update_date PROGRAM_UPDATE_DATE,
          rrs.program_application_id PROGRAM_APPLICATION_ID,
          rrs.program_id PROGRAM_ID,
          rrs.request_id REQUEST_ID,
          rrs.je_line_description je_line_description,
          rrs.accounting_date accounting_date,
          rrs.set_of_books_id ledger_id
   from   rcv_transactions rt,
          rcv_accounting_events rae,
          xla_ae_headers xla,
          rcv_mc_rec_sub_ledger rrs,
          cst_xla_rcv_event_map cem,
          GL_CODE_COMBINATIONS gcc,
          cst_xla_seq_gt cxs
   where  rt.transaction_id=cxs.source_id_int_1
          and xla.event_id = cxs.event_id
          and xla.entity_id = cxs.entity_id
          and xla.upg_batch_id = l_upg_batch_id
          and xla.ledger_id = rrs.set_of_books_id
          and xla.application_id = 707
          and nvl(rae.organization_id,rt.organization_id)=cxs.source_id_int_3
          and rrs.rcv_transaction_id = rt.transaction_id
          and ((rae.accounting_event_id is not null
                  and rae.accounting_event_id = rrs.accounting_event_id
                  and rae.accounting_event_id = cxs.source_id_int_2)
                or (rae.accounting_event_id is null
                  and rrs.accounting_event_id is null)
              )
          and rrs.ENCUMBRANCE_TYPE_ID is null
          and rt.transaction_id = rae.rcv_transaction_id (+)
          and nvl(rae.EVENT_TYPE_ID,decode(rt.transaction_type, 'RECEIVE', 1, 'DELIVER', 2, 'CORRECT', 3,
                             'MATCH', 4, 'RETURN TO RECEIVING', 5, 'RETURN TO VENDOR', 6, -1))=cem.transaction_type_id
          and (cem.transaction_type_id <> 3
               or
               (cem.transaction_type_id = 3
                and rt.PARENT_TRANSACTION_ID is not null
                and cem.attribute = (SELECT TRANSACTION_TYPE
                               FROM RCV_TRANSACTIONS rt1
                               WHERE  rt1.transaction_id =  rt.PARENT_TRANSACTION_ID))
               )
          and gcc.CODE_COMBINATION_ID=rrs.CODE_COMBINATION_ID;


   update /*+ leading(cxs) use_nl(rrs) index(rrs) */
       rcv_mc_rec_sub_ledger rrs
   set reference10 = 'Migrated to SLA',
       rcv_sub_ledger_id = nvl(rcv_sub_ledger_id, rcv_receiving_sub_ledger_s.nextval),
       last_update_date = gUpdateDate,
       last_updated_by = gUserId,
       last_update_login = gLoginId
   where rrs.rcv_transaction_id in (select source_id_int_1 from cst_xla_seq_gt cxs)
         and rrs.ENCUMBRANCE_TYPE_ID is null;

   <<out_arg_log>>

   IF l_plog THEN
     fnd_log.string(
       fnd_log.level_procedure,
       l_module||'.end',
       'Exiting RCV_SLA_MRC_UPDATE_PKG.Update_Receiving_MRC_Subledger with '||
       'X_errbuf = '||X_errbuf||','||
       'X_retcode = '||X_retcode
     );
   END IF;

EXCEPTION

  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    IF l_exceptionlog THEN
      fnd_msg_pub.add_exc_msg(
        p_pkg_name => 'RCV_SLA_MRC_UPDATE_PKG',
        p_procedure_name => 'Update_Receiving_MRC_Subledger',
        p_error_text => 'An exception has occurred.'
      );
      fnd_log.string(
        fnd_log.level_exception,
        l_module||'.'||l_stmt_num,
        'An exception has occurred.'
      );
    END IF;
    X_errbuf:=l_module||'.'||l_stmt_num||': An exception has occurred.';
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_error;
    IF l_errorLog THEN
      fnd_message.set_name('BOM','CST_ERROR');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_error,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;
  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    IF (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) THEN
      fnd_message.set_name('BOM','CST_UNEXPECTED');
      fnd_message.set_token('SQLERRM',SQLERRM);
      fnd_msg_pub.add;
      fnd_log.message(
        fnd_log.level_unexpected,
        l_module||'.'||l_stmt_num,
        FALSE
      );
    END IF;
    X_errbuf:=l_module||'.'||l_stmt_num||': '|| SQLERRM;

end Update_Receiving_MRC_Subledger;


END RCV_SLA_MRC_UPDATE_PKG;

/
