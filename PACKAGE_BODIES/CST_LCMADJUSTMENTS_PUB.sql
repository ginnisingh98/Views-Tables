--------------------------------------------------------
--  DDL for Package Body CST_LCMADJUSTMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_LCMADJUSTMENTS_PUB" AS
/* $Header: CSTLCAMB.pls 120.1.12010000.3 2008/12/28 13:24:12 anjha noship $ */

/*------------------------------------------------------------------------------------------
  Landed Cost Manager:
  The manager launches worker rows of the Landed Cost Adjustment Worker
  for each organization based on the maximum number of worker rows
  allowed for the Cost manager.
------------------------------------------------------------------------------------------*/

G_PKG_NAME  CONSTANT VARCHAR2(30):='CST_LcmAdjustments_PUB';
G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG CONSTANT VARCHAR2(1)     := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'po.plsql.'||G_PKG_NAME;

/*===========================================================================+
|                                                                            |
| PROCEDURE      : Process_LcmAdjustments                                    |
|                                                                            |
| DESCRIPTION    : This Procedure is called by the Landed Cost Adjustment    |
|                  Processor concurrent program. In the procedure interface  |
|                  records are grouped by organization id and stamped with   |
|                  group_id and transaction_id. The Landed cost Adjustment   |
|                  Worker is launched for each group.                        |
|                                                                            |
| CALLED FROM    : Launch_Workers (CST_LcmAdjustments_PUB)                   |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_group_id        IN  NUMBER    REQUIRED                 |
|                   p_organization_id IN  NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  errbuf           OUT  NOCOPY VARCHAR2                    |
|                   retcode          OUT  NOCOPY NUMBER                      |
|                                                                            |
| NOTES          :  None                                                     |
|                                                                            |
|                                                                            |
+===========================================================================*/

PROCEDURE Launch_Workers
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER
)

IS
  l_api_name    CONSTANT          VARCHAR2(30) :='Launch_Workers';
  l_api_version CONSTANT          NUMBER       := 1.0;
  l_return_status                 VARCHAR2(1);
  l_module       CONSTANT         VARCHAR2(100) := 'cst.plsql.'|| G_PKG_NAME || '.' || l_api_name;

  l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
  l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  l_stmt_num                      NUMBER;

  l_conc_status                   BOOLEAN;
  l_group_id                      NUMBER;
  l_maxrows                       NUMBER;
  l_request_id                    NUMBER;

  CURSOR c_org IS
    SELECT organization_id, primary_cost_method
      FROM mtl_parameters mp
     WHERE EXISTS (SELECT 1
             FROM cst_lc_adj_interface
            WHERE organization_id = mp.organization_id
              AND process_status IN (1,2));
BEGIN

  l_stmt_num := 0;

  -- Procedure level log message for Entry point
  IF (l_pLog) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      l_module || '.begin',
      'Launch_Workers <<'
      );
  END IF;

  -- Initialize message list
  FND_MSG_PUB.initialize;

  --  Initialize API return status to success
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;
  SELECT worker_rows
  INTO   l_maxrows
  FROM   mtl_interface_proc_controls
  WHERE  process_code = 4;

  l_stmt_num := 20;
  FOR c_o in c_org LOOP

    l_stmt_num := 30;
    LOOP

      l_stmt_num := 40;
      SELECT cst_lc_processor_grp_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      l_stmt_num := 50;
      UPDATE cst_lc_adj_interface i
        SET transaction_id = NVL(transaction_id, CST_LC_ADJ_INTERFACE_TRX_S.NEXTVAL),
            group_id = l_group_id,
            request_id = fnd_global.conc_request_id,
            process_phase = 2
      WHERE organization_id = c_o.organization_id
        AND process_status in (1,2)
        AND (group_id IS NULL
            OR
            NOT EXISTS (SELECT 1
        FROM fnd_concurrent_requests R,
             fnd_concurrent_programs P
        WHERE R.program_application_id = P.application_id
	AND R.concurrent_program_id = P.concurrent_program_id
	AND P.concurrent_program_name = 'CSTLCADJ'
	AND R.argument1 = TO_CHAR(i.group_id)
	AND R.phase_code IN ('I','P','R')))
        AND (c_o.primary_cost_method IN (1,2)
             OR
             NOT EXISTS (SELECT 1
            FROM mtl_material_transactions
           WHERE costed_flag in ('N', 'E')
             AND transaction_date < i.transaction_date
             AND transaction_source_type_id = 1
             AND rcv_transaction_id IN (SELECT transaction_id
                 FROM rcv_transactions rt
        START WITH rt.transaction_id = i.rcv_transaction_id
        CONNECT BY rt.parent_transaction_id = PRIOR rt.transaction_id)))
        AND ROWNUM <= l_maxrows;

      EXIT WHEN SQL%NOTFOUND;

      l_stmt_num := 60;
      COMMIT WORK;

      l_stmt_num := 70;
      l_request_id := fnd_request.submit_request (
                      application => 'BOM',
                      program     => 'CSTLCADJ',
                      argument1   => to_char(l_group_id),
                      argument2   => to_char(c_o.organization_id));

      IF l_request_id = 0 THEN
        l_stmt_num := 80;
        UPDATE cst_lc_adj_interface
          SET group_id = NULL,
              process_phase = 1
        WHERE group_id = l_group_id
          AND organization_id = c_o.organization_id;

        COMMIT WORK;
	fnd_file.put_line(fnd_file.log, 'Could not launch landed cost adjustment worker for group_id ' || to_char(l_group_id));
	IF (l_uLog) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,l_module, 'Could not launch landed cost adjustment worker for group_id ' || to_char(l_group_id));
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_stmt_num := 90;
      COMMIT WORK;

    END LOOP;
    l_stmt_num := 100;
  END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

      /* Set concurrent program status to error */
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',FND_MESSAGE.GET);

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      IF (l_exceptionLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,l_module, TRUE);
      END IF;

      /* Set concurrent program status to error */
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',FND_MESSAGE.GET);

    WHEN OTHERS THEN
      ROLLBACK;

      FND_MESSAGE.SET_NAME('BOM','CST_LOG_UNEXPECTED');
      FND_MESSAGE.SET_TOKEN('SQLERRM',SQLERRM);
      IF (l_uLog) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module, TRUE);
      END IF;

      /* Set concurrent program status to error */
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                       FND_MESSAGE.GET);
      fnd_file.put_line( FND_FILE.LOG, FND_MESSAGE.GET);

END Launch_Workers;

END CST_LcmAdjustments_PUB;  -- end package body

/
