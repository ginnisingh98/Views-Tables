--------------------------------------------------------
--  DDL for Package Body FUN_GL_ASF_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_GL_ASF_EVENTS_PKG" AS
/* $Header: funglasfevntb.pls 120.0 2006/01/13 09:23:10 bsilveir noship $ */

g_debug_level       NUMBER;
g_module CONSTANT VARCHAR2(80) := 'fun.plsql.fun_gl_asf_events_pkg';

 -- This procedure is invoked from the GL Accounting Setup Flow page
 -- when a Balancing Segment Value is removed from the Ledger
 -- Event Name = oracle.apps.gl.Setup.Ledger.BalancingSegmentValueRemove
 --
 FUNCTION ledger_bsv_remove(p_subscription_guid IN RAW
                             ,p_event             IN OUT NOCOPY wf_event_t
                             ) RETURN VARCHAR2
IS

l_routine          VARCHAR2(80) := 'ledger_bsv_remove';
l_ledger_id        NUMBER;
l_bsv              VARCHAR2(100);
l_ret_mode         VARCHAR2(20) := 'SUCCESS';

BEGIN

   SAVEPOINT fun_ledger_bsv_remove;

   -- variable p_validation_level is not used .
   g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   l_ledger_id := wf_event.getvalueforparameter ('LEDGER_ID',p_event.parameter_list);
   l_bsv       := wf_event.getvalueforparameter ('BAL_SEGMENT_VALUE',p_event.parameter_list);

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.ledger_bsv_remove',
                      'Begin Ledger Id ' || l_ledger_id || ', BSV ' || l_bsv);
   END IF;

   IF l_ledger_id IS NULL OR l_bsv       IS NULL
   THEN
       wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
       wf_event.seterrorinfo (p_event, 'WARNING');
       l_ret_mode :=  'WARNING';

   ELSE
       DELETE fun_balance_accounts
       WHERE  (dr_bsv = l_bsv OR cr_bsv = l_bsv)
       AND    template_id IN (SELECT template_id
                              FROM   fun_balance_options
                              WHERE  ledger_id = l_ledger_id);

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.ledger_bsv_remove',
                          ' No. of rows deleted from fun_balance_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;


   END IF; -- Ledger and BSV passed

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.ledger_bsv_remove',
                      'completed');
   END IF;

   RETURN l_ret_mode;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO fun_ledger_bsv_remove;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                      'fun.plsql.fun_gl_asf_events_pkg.ledger_bsv_remove',
                      'Error encountered ' || SQLERRM);
        END IF;
        wf_core.context (g_module,
                         l_routine,
                         p_event.event_name,
                         p_subscription_guid
                        );
        wf_event.seterrorinfo (p_event, 'ERROR');
        RETURN 'ERROR';

END ledger_bsv_remove;

 -- This procedure is invoked from the GL Accounting Setup Flow page
 -- when a Balancing Segment Value is removed from the Legal Entity
 -- Event Name = oracle.apps.gl.Setup.LegalEntity.BalancingSegmentValueRemove
 --
 FUNCTION le_bsv_remove(p_subscription_guid IN RAW
                        ,p_event            IN OUT NOCOPY wf_event_t
                        ) RETURN VARCHAR2
IS

l_routine          VARCHAR2(80) := 'le_bsv_remove';
l_le_id            NUMBER;
l_bsv              VARCHAR2(100);
l_ret_mode         VARCHAR2(20) := 'SUCCESS';

BEGIN
   SAVEPOINT fun_le_bsv_remove;

   -- variable p_validation_level is not used .
   g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   l_le_id := wf_event.getvalueforparameter ('LEGAL_ENTITY_ID',p_event.parameter_list);
   l_bsv   := wf_event.getvalueforparameter ('BAL_SEGMENT_VALUE',p_event.parameter_list);

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.le_bsv_remove',
                      'Begin LE Id ' || l_le_id || ', BSV ' || l_bsv);
   END IF;

   IF l_le_id IS NULL OR l_bsv       IS NULL
   THEN
       wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
       wf_event.seterrorinfo (p_event, 'WARNING');
       l_ret_mode :=  'WARNING';

   ELSE
       DELETE fun_balance_accounts
       WHERE  (dr_bsv = l_bsv OR cr_bsv = l_bsv)
       AND    template_id IN (SELECT template_id
                              FROM   fun_balance_options
                              WHERE  le_id = l_le_id);

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.le_bsv_remove',
                          ' No. of rows deleted from fun_balance_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;


       UPDATE  fun_inter_accounts
       SET     end_date = SYSDATE,
               last_update_date = SYSDATE,
               last_update_login = FND_GLOBAL.LOGIN_ID,
               last_updated_by   = FND_GLOBAL.USER_ID
       WHERE   (trans_bsv = l_bsv AND from_le_id = l_le_id)
       OR      (tp_bsv    = l_bsv AND to_le_id   = l_le_id);

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.le_bsv_remove',
                          ' No. of rows terminated in fun_inter_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;


   END IF; -- Ledger and BSV passed

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.le_bsv_remove',
                      'completed');
   END IF;

   RETURN l_ret_mode;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO fun_le_bsv_remove;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                      'fun.plsql.fun_gl_asf_events_pkg.le_bsv_remove',
                      'Error encountered ' || SQLERRM);
        END IF;
        wf_core.context (g_module,
                         l_routine,
                         p_event.event_name,
                         p_subscription_guid
                        );
        wf_event.seterrorinfo (p_event, 'ERROR');
        RETURN 'ERROR';


END le_bsv_remove;


 -- This procedure is invoked from the GL Accounting Setup Flow page
 -- when a Legal Entity is removed from the Ledger
 -- Event Name = oracle.apps.gl.Setup.Ledger.LegalEntityRemove
 --
 FUNCTION ledger_le_remove(p_subscription_guid IN RAW
                          ,p_event            IN OUT NOCOPY wf_event_t
                          ) RETURN VARCHAR2
IS

l_routine          VARCHAR2(80) := 'ledger_le_remove';
l_le_id            NUMBER;
l_ledger_id        NUMBER;
l_ret_mode         VARCHAR2(20) := 'SUCCESS';

BEGIN
   SAVEPOINT fun_ledger_le_remove;

   -- variable p_validation_level is not used .
   g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   l_le_id      := wf_event.getvalueforparameter ('LEGAL_ENTITY_ID',p_event.parameter_list);
   l_ledger_id  := wf_event.getvalueforparameter ('PRIMARY_LEDGER_ID',p_event.parameter_list);

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.ledger_le_remove',
                      'Begin LE Id ' || l_le_id || ', Ledger Id ' || l_ledger_id);
   END IF;

   IF l_le_id IS NULL OR l_ledger_id IS NULL
   THEN
       wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
       wf_event.seterrorinfo (p_event, 'WARNING');
       l_ret_mode :=  'WARNING';

   ELSE
       UPDATE fun_balance_options
       SET    status_flag = 'N',
              last_update_date = SYSDATE,
              last_update_login = FND_GLOBAL.LOGIN_ID,
              last_updated_by   = FND_GLOBAL.USER_ID
       WHERE  le_id       = l_le_id
       AND    ledger_id   = l_ledger_id;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.ledger_le_remove',
                          ' No. of rows disabled in fun_balance_options is ' ||
                          SQL%ROWCOUNT);
       END IF;

       UPDATE  fun_inter_accounts
       SET     end_date = SYSDATE,
               last_update_date = SYSDATE,
               last_update_login = FND_GLOBAL.LOGIN_ID,
               last_updated_by   = FND_GLOBAL.USER_ID
       WHERE   from_le_id = l_le_id
       AND     ledger_id  = l_ledger_id;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.ledger_le_remove',
                          ' No. of rows terminated in fun_inter_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;

   END IF; -- Ledger and LE passed

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.ledger_le_remove',
                      'completed');
   END IF;

   RETURN l_ret_mode;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO fun_ledger_le_remove;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                      'fun.plsql.fun_gl_asf_events_pkg.ledger_le_remove',
                      'Error encountered ' || SQLERRM);
        END IF;
        wf_core.context (g_module,
                         l_routine,
                         p_event.event_name,
                         p_subscription_guid
                        );
        wf_event.seterrorinfo (p_event, 'ERROR');
        RETURN 'ERROR';

END ledger_le_remove;


 -- This procedure is invoked from the GL Accounting Setup Flow page
 -- when a Secondary ledger is deleted from the ledger
 -- Event Name = oracle.apps.gl.Setup.SecondaryLedger.Delete
 --
 FUNCTION secondary_ledger_delete(p_subscription_guid IN RAW
                          ,p_event            IN OUT NOCOPY wf_event_t
                          ) RETURN VARCHAR2
IS

l_routine          VARCHAR2(80) := 'secondary_ledger_delete';
l_sec_ledger_id    NUMBER;
l_ret_mode         VARCHAR2(20) := 'SUCCESS';

BEGIN
   SAVEPOINT fun_secondary_ledger_delete;

   -- variable p_validation_level is not used .
   g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   l_sec_ledger_id := wf_event.getvalueforparameter ('SECONDARY_LEDGER_ID',p_event.parameter_list);

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.secondary_ledger_delete',
                      'Begin Secondary Ledger Id ' || l_sec_ledger_id );
   END IF;

   IF l_sec_ledger_id IS NULL
   THEN
       wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
       wf_event.seterrorinfo (p_event, 'WARNING');
       l_ret_mode :=  'WARNING';

   ELSE
       DELETE FROM fun_balance_accounts
       WHERE  template_id in (SELECT template_id
                              FROM   fun_balance_options
                              WHERE  ledger_id = l_sec_ledger_id);

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.secondary_ledger_delete',
                          ' No. of rows deleted in fun_balance_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;

       DELETE FROM fun_balance_options
       WHERE  ledger_id   = l_sec_ledger_id;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.secondary_ledger_delete',
                          ' No. of rows deleted in fun_balance_options is ' ||
                          SQL%ROWCOUNT);
       END IF;

       DELETE FROM  fun_inter_accounts
       WHERE  ledger_id  = l_sec_ledger_id;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.secondary_ledger_delete',
                          ' No. of rows deleted in fun_inter_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;


   END IF; -- Ledger passed

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.secondary_ledger_delete',
                      'completed');
   END IF;

   RETURN l_ret_mode;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO fun_secondary_ledger_delete;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                      'fun.plsql.fun_gl_asf_events_pkg.secondary_ledger_delete',
                      'Error encountered ' || SQLERRM);
        END IF;
        wf_core.context (g_module,
                         l_routine,
                         p_event.event_name,
                         p_subscription_guid
                        );
        wf_event.seterrorinfo (p_event, 'ERROR');
        RETURN 'ERROR';

END secondary_ledger_delete;


 -- This procedure is invoked from the GL Accounting Setup Flow page
 -- when a Reporting Ledger is deleted from the Ledger
 -- Event Name = oracle.apps.gl.Setup.ReportingLedger.Delete
 --
 FUNCTION reporting_ledger_delete(p_subscription_guid IN RAW
                          ,p_event            IN OUT NOCOPY wf_event_t
                          ) RETURN VARCHAR2
IS

l_routine          VARCHAR2(80) := 'reporting_ledger_delete';
l_rep_ledger_id    NUMBER;
l_ret_mode         VARCHAR2(20) := 'SUCCESS';

BEGIN
   SAVEPOINT fun_reporting_ledger_delete;

   -- variable p_validation_level is not used .
   g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   l_rep_ledger_id := wf_event.getvalueforparameter ('TARGET_LEDGER_ID',p_event.parameter_list);

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.reporting_ledger_delete',
                      'Begin Reporting Ledger Id ' || l_rep_ledger_id );
   END IF;

   IF l_rep_ledger_id IS NULL
   THEN
       wf_core.context (g_module,
                       l_routine,
                       p_event.event_name,
                       p_subscription_guid
                      );
       wf_event.seterrorinfo (p_event, 'WARNING');
       l_ret_mode :=  'WARNING';

   ELSE
       DELETE FROM fun_balance_accounts
       WHERE  template_id in (SELECT template_id
                              FROM   fun_balance_options
                              WHERE  ledger_id = l_rep_ledger_id);

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.reporting_ledger_delete',
                          ' No. of rows deleted in fun_balance_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;

       DELETE FROM fun_balance_options
       WHERE  ledger_id   = l_rep_ledger_id;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.reporting_ledger_delete',
                          ' No. of rows deleted in fun_balance_options is ' ||
                          SQL%ROWCOUNT);
       END IF;

       DELETE FROM  fun_inter_accounts
       WHERE  ledger_id  = l_rep_ledger_id;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
       THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                          'fun.plsql.fun_gl_asf_events_pkg.reporting_ledger_delete',
                          ' No. of rows deleted in fun_inter_accounts is ' ||
                          SQL%ROWCOUNT);
       END IF;


   END IF; -- Ledger passed

   IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level)
   THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                      'fun.plsql.fun_gl_asf_events_pkg.reporting_ledger_delete',
                      'completed');
   END IF;

   RETURN l_ret_mode;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO fun_reporting_ledger_delete;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                      'fun.plsql.fun_gl_asf_events_pkg.reporting_ledger_delete',
                      'Error encountered ' || SQLERRM);
        END IF;
        wf_core.context (g_module,
                         l_routine,
                         p_event.event_name,
                         p_subscription_guid
                        );
        wf_event.seterrorinfo (p_event, 'ERROR');
        RETURN 'ERROR';

END reporting_ledger_delete;
END;


/
