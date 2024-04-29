--------------------------------------------------------
--  DDL for Package Body WIP_WS_EMBEDDED_ANALYTICS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_EMBEDDED_ANALYTICS_PK" AS
/* $Header: wipwseab.pls 120.18 2008/05/29 23:59:37 ankohli noship $ */

/*============================================================================+
|  Copyright (c) 2007 Oracle Corporation    Redwood Shore, California, USA    |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : WIPWSEAB.sql
| DESCRIPTION :
|              This package contains specification for all APIs related to
|              MES First Pass Yield and Parts per Million Defects module
|
| HISTORY     : created   11-DEC-07
|             Nitikorn Tangjeerawong 11-DEC-2007   Creating Initial Version
|
*============================================================================*/

  g_fpy_data_retention NUMBER := 33; -- 29 Days is for 30 days retention period.  More than 29 days are buffer for date without shift.
  g_ppmd_data_retention NUMBER := 33; -- 29 Days is for 30 days retention period.  More than 29 days are buffer for date without shift.

  FUNCTION set_calc_param(p_execution_date IN DATE,
                          p_cutoff_date IN DATE,
                          p_org_id IN NUMBER)
  RETURN wip_logger.param_tbl_t IS
    l_params wip_logger.param_tbl_t;
  BEGIN
        l_params (1).paramName := 'p_execution_date';
        l_params (1).paramValue := p_execution_date;
        l_params (2).paramName := 'p_cutoff_date';
        l_params (2).paramValue := p_cutoff_date;
        l_params (3).paramName := 'p_org_id';
        l_params (3).paramValue := p_org_id;
  RETURN l_params;
  END set_calc_param;

  PROCEDURE begin_log(p_params wip_logger.param_tbl_t,
                          p_proc_name VARCHAR2,
                          p_return_status OUT NOCOPY VARCHAR2
                         ) IS
  BEGIN
    IF (g_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.entryPoint(p_procName => p_proc_name,
                            p_params => p_params,
                            x_returnStatus => p_return_status);

      IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => p_proc_name,
                             p_procReturnStatus => p_return_status,
                             p_msg => 'procedure success.',
                             x_returnStatus => p_return_Status);
    END IF;
  END begin_log;

 PROCEDURE exception_log(p_proc_name VARCHAR2,
                              p_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status varchar2(1);
  BEGIN
     wip_ws_util.trace_log('Error in ' || p_proc_name);
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (g_logLevel <= wip_constants.trace_logging) then
       wip_logger.exitPoint(p_procName => p_proc_name,
                            p_procReturnStatus => l_return_status,
                            p_msg => 'unexpected error: ' || SQLERRM,
                            x_returnStatus => l_return_Status);
     END IF;
  END exception_log;

PROCEDURE populate_fpy_raw_data(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id      IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

  l_return_status varchar2(1);
  l_params wip_logger.param_tbl_t;

  BEGIN

    IF (g_logLevel <= wip_constants.trace_logging) THEN

        l_params(1).paramName := 'p_execution_date';
        l_params(1).paramValue := p_execution_date;
        l_params(2).paramName := 'p_cutoff_date';
        l_params(2).paramValue := p_cutoff_date;
        l_params(3).paramName := 'p_org_id';
        l_params(3).paramValue := p_org_id;

        wip_logger.entryPoint(p_procName => 'wip_ws_embedded_analytics_pk.populate_fpy_raw_data',
                                p_params => l_params,
                                x_returnStatus => l_return_status);

        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Original Query before passing Department when calculating shift.
    INSERT INTO wip_ws_fpy
      (
          ORGANIZATION_ID,
          DEPARTMENT_ID,
          WIP_ENTITY_ID,
          OPERATION_SEQ_NUM,
          INVENTORY_ITEM_ID,
          SHIFT_NUM,
          SHIFT_DATE,
          QUANTITY_REJECTED,
          QUANTITY_SCRAPPED,
          QUANTITY_COMPLETED,
          REQUEST_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          PROGRAM_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE,
          QUANTITY_FIRST_PASS
      )
      SELECT
          wdj.organization_id,
          completed_info.department_id,
          completed_info.wip_entity_id as wip_entity_id,
          completed_info.operation_seq_num as operation_seq_num,
          wdj.primary_item_id,
          completed_info.shift_num as shift_num,
          completed_info.shift_start_date as shift_date,
          0 as quantity_rejected,
          0 as quantity_scraped,
          completed_info.quantity_compelted,
          g_request_id as REQUEST_ID,
          p_execution_date as LAST_UPDATE_DATE,
          g_user_id as LAST_UPDATED_BY,
          p_execution_date as CREATION_DATE,
          g_user_id as CREATED_BY,
          g_login_id as LAST_UPDATE_LOGIN,
          g_prog_id as PROGRAM_ID,
          g_prog_appid as PROGRAM_APPLICATION_ID,
          p_execution_date as PROGRAM_UPDATE_DATE,
          0 as QUANTITY_FIRST_PASS
    FROM
      (
        SELECT
          wop.department_id,
          wmt.shift_start_date,
          wmt.shift_num,
          wop.wip_entity_id,
          wop.operation_seq_num,
          NVL(SUM(wmt.primary_quantity *
              DECODE(SIGN(wmt.to_operation_seq_num -wmt.fm_operation_seq_num),
                     0,DECODE(SIGN(wmt.fm_intraoperation_step_type -WIP_CONSTANTS.RUN),
                                 0,DECODE(SIGN(wmt.to_intraoperation_step_type -WIP_CONSTANTS.RUN),1,1,-1),
                                -1,DECODE(SIGN(wmt.to_intraoperation_step_type -WIP_CONSTANTS.RUN),1,1,-1),
                                 1,-1),
                     1, 1,
                    -1,-1)
                     ),0) quantity_compelted
        FROM
         (
            SELECT
              transaction_date+ mod(shift_info,1)*1000 shift_start_date,
              abs(mod(trunc(shift_info),100)) as shift_num,
              wip_entity_id,
              primary_quantity,
              to_operation_seq_num,
              to_intraoperation_step_type,
              fm_operation_seq_num,
              fm_intraoperation_step_type
            FROM
              (
                SELECT
                       wip_ws_embedded_analytics_pk.get_shift_info(wmt.organization_id, wmt.transaction_date) as shift_info,
                       wmt.*
                FROM
                       wip_move_transactions wmt
                WHERE
                       wmt.transaction_date > p_cutoff_date
                       AND wmt.organization_id = p_org_id
            )
          ) wmt,
            wip_operations wop
        WHERE
            wop.organization_id = p_org_id
            AND wop.wip_entity_id = wmt.wip_entity_id
            AND ((wop.operation_seq_num >= wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                    AND (wop.operation_seq_num < wmt.to_operation_seq_num + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                    AND (wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                        OR (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                            AND wmt.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                            AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
                    AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                        OR wop.operation_seq_num = wmt.fm_operation_seq_num
                        OR (wop.operation_seq_num = wmt.to_operation_seq_num
                        AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN)))
            OR
                (wop.operation_seq_num < wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                AND (wop.operation_seq_num >= wmt.to_operation_seq_num  + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                AND (wmt.fm_operation_seq_num > wmt.to_operation_seq_num
                    OR (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                        AND wmt.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                        AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
                AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                    OR (wop.operation_seq_num = wmt.to_operation_seq_num
                        AND wop.count_point_type < WIP_CONSTANTS.NO_MANUAL )
                    OR (wop.operation_seq_num = wmt.fm_operation_seq_num
                        AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))))
        GROUP BY wop.department_id, wmt.shift_start_date, wmt.shift_num, wop.wip_entity_id, wop.operation_seq_num

      ) completed_info,
        WIP_DISCRETE_JOBS wdj

    WHERE wdj.wip_entity_id = completed_info.wip_entity_id
          AND wdj.organization_id = p_org_id;

*/

    INSERT INTO wip_ws_fpy
      (
          ORGANIZATION_ID,
          DEPARTMENT_ID,
          WIP_ENTITY_ID,
          OPERATION_SEQ_NUM,
          INVENTORY_ITEM_ID,
          SHIFT_NUM,
          SHIFT_DATE,
          QUANTITY_REJECTED,
          QUANTITY_SCRAPPED,
          QUANTITY_COMPLETED,
          REQUEST_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          PROGRAM_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE,
          QUANTITY_FIRST_PASS
      )
      SELECT
          wdj.organization_id,
          completed_info.department_id,
          completed_info.wip_entity_id,
          completed_info.operation_seq_num,
          wdj.primary_item_id,
          completed_info.shift_num,
          completed_info.shift_start_date,
          0 as quantity_rejected,
          0 as quantity_scraped,
          completed_info.quantity_compelted,
          g_request_id as REQUEST_ID,
          p_execution_date as LAST_UPDATE_DATE,
          g_user_id as LAST_UPDATED_BY,
          p_execution_date as CREATION_DATE,
          g_user_id as CREATED_BY,
          g_login_id as LAST_UPDATE_LOGIN,
          g_prog_id as PROGRAM_ID,
          g_prog_appid as PROGRAM_APPLICATION_ID,
          p_execution_date as PROGRAM_UPDATE_DATE,
          0 as QUANTITY_FIRST_PASS
    FROM
      (
        SELECT
          post_cal.department_id,
          post_cal.shift_start_date,
          post_cal.shift_num,
          post_cal.wip_entity_id,
          post_cal.operation_seq_num,
          NVL(SUM(post_cal.primary_quantity *
              DECODE(SIGN(post_cal.to_operation_seq_num -post_cal.fm_operation_seq_num),
                     0,DECODE(SIGN(post_cal.fm_intraoperation_step_type -WIP_CONSTANTS.RUN),
                                 0,DECODE(SIGN(post_cal.to_intraoperation_step_type -WIP_CONSTANTS.RUN),1,1,-1),
                                -1,DECODE(SIGN(post_cal.to_intraoperation_step_type -WIP_CONSTANTS.RUN),1,1,-1),
                                 1,-1),
                     1, 1,
                    -1,-1)
                     ),0) quantity_compelted
        FROM
          (
            SELECT
                pre_cal.department_id,
                pre_cal.primary_quantity,
                pre_cal.wip_entity_id,
                pre_cal.operation_seq_num,
                (case when (pre_cal.shift_info is not null) then pre_cal.transaction_date+ mod(pre_cal.shift_info,1)*1000 else trunc(pre_cal.transaction_date) end )as shift_start_date,
                (case when (pre_cal.shift_info is not null) then abs(mod(trunc(pre_cal.shift_info),100)) else -1 end)as shift_num,
                pre_cal.fm_operation_seq_num,
                pre_cal.to_operation_seq_num,
                pre_cal.fm_intraoperation_step_type,
                pre_cal.to_intraoperation_step_type
            FROM
              (
                SELECT
                    wop.department_id,
                    wmt.wip_entity_id,
                    wmt.transaction_id,
                    wop.operation_seq_num,
                    wmt.fm_operation_seq_num,
                    wmt.to_operation_seq_num,
                    wmt.fm_intraoperation_step_type,
                    wmt.to_intraoperation_step_type,
                    wmt.primary_quantity,
                    wmt.transaction_date,
                    wip_ws_embedded_analytics_pk.get_shift_info(wmt.organization_id,wop.department_id, wmt.transaction_date) as shift_info
                FROM
                    wip_move_transactions wmt,
                    wip_operations wop
                WHERE
                    wmt.transaction_date >= p_cutoff_date
                    AND wmt.organization_id = p_org_id
                    AND wop.organization_id = p_org_id
                    AND wop.wip_entity_id = wmt.wip_entity_id
                    AND ((wop.operation_seq_num >= wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                            AND (wop.operation_seq_num < wmt.to_operation_seq_num + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                            AND (wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                                OR (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                                    AND wmt.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                                    AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
                            AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                                OR wop.operation_seq_num = wmt.fm_operation_seq_num
                                OR (wop.operation_seq_num = wmt.to_operation_seq_num
                                AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN)))
                    OR
                        (wop.operation_seq_num < wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                        AND (wop.operation_seq_num >= wmt.to_operation_seq_num  + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                        AND (wmt.fm_operation_seq_num > wmt.to_operation_seq_num
                            OR (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                                AND wmt.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                                AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
                        AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                            OR (wop.operation_seq_num = wmt.to_operation_seq_num
                                AND wop.count_point_type < WIP_CONSTANTS.NO_MANUAL )
                            OR (wop.operation_seq_num = wmt.fm_operation_seq_num
                                AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))))
              ) pre_cal
          ) post_cal
        GROUP BY post_cal.department_id, post_cal.shift_start_date, post_cal.shift_num, post_cal.wip_entity_id, post_cal.operation_seq_num
      ) completed_info,
        WIP_DISCRETE_JOBS wdj

    WHERE wdj.wip_entity_id = completed_info.wip_entity_id
          AND wdj.organization_id = p_org_id;

    wip_ws_util.trace_log('Finish Inserting QUANTITY_COMPLETED');
--------------------------- Update QUANTITY_SCRAPPED ------------------------------------
    UPDATE
          wip_ws_fpy fpy
    SET
      QUANTITY_SCRAPPED =
           nvl((SELECT
                    NVL(SUM(DECODE(wop.operation_seq_num,wmt.to_operation_seq_num,DECODE(wmt.to_intraoperation_step_type,WIP_CONSTANTS.SCRAP, wmt.primary_quantity,0),0)
                          - DECODE(wop.operation_seq_num, wmt.fm_operation_seq_num,DECODE(wmt.fm_intraoperation_step_type,WIP_CONSTANTS.SCRAP,wmt.primary_quantity,0),0)),0) as quantity_scrap
                FROM
                   (
                      SELECT
                          (case when (shift_info is not null) then transaction_date+ mod(shift_info,1)*1000 else trunc(transaction_date) end )as shift_start_date,
                          (case when (shift_info is not null) then abs(mod(trunc(shift_info),100)) else -1 end)as shift_num,
                          wip_entity_id,
                          primary_quantity,
                           to_operation_seq_num,
                           to_intraoperation_step_type,
                            fm_operation_seq_num,
                            fm_intraoperation_step_type
                      FROM
                         (
                            SELECT
                                wip_ws_embedded_analytics_pk.get_shift_info(wmt.organization_id
                                  ,(case when wmt.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP then wmt.to_department_id else wmt.fm_department_id end)
                                  ,wmt.transaction_date) as shift_info,
                                transaction_date,
                                wip_entity_id,
                                primary_quantity,
                                to_operation_seq_num,
                                to_intraoperation_step_type,
                                fm_operation_seq_num,
                                fm_intraoperation_step_type
                            FROM
                                wip_move_transactions wmt
                            WHERE
                                transaction_date >= p_cutoff_date
                                AND wmt.organization_id = p_org_id
                                AND (wmt.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP
                                     OR wmt.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP)
                         ) wmt_raw_shift_info
                   ) wmt,
                   wip_operations wop

                WHERE
                    wop.wip_entity_id = wmt.wip_entity_id
                    AND wop.organization_id = p_org_id
                    AND ((wmt.fm_intraoperation_step_type = WIP_CONSTANTS.SCRAP AND wmt.fm_operation_seq_num = wop.operation_seq_num)
                        OR (wmt.to_intraoperation_step_type = WIP_CONSTANTS.SCRAP AND wmt.to_operation_seq_num = wop.operation_seq_num))

                    AND fpy.wip_entity_id = wop.wip_entity_id
                    AND fpy.operation_seq_num = wop.operation_seq_num
                    AND fpy.shift_num = wmt.shift_num
                    AND fpy.shift_date = wmt.shift_start_date
                    AND fpy.organization_id = p_org_id

                GROUP BY wmt.shift_start_date, wmt.shift_num, wop.wip_entity_id, wop.operation_seq_num),0);

        wip_ws_util.trace_log('Finish Updating QUANTITY_SCRAPPED');

/* This QUERY works too, if the above SQL turn bad in performance try this one
 SELECT
      NVL(SUM(DECODE(operation_seq_num,to_operation_seq_num,DECODE(to_intraoperation_step_type,WIP_CONSTANTS.SCRAP, primary_quantity,0),0)
      - DECODE(operation_seq_num, fm_operation_seq_num,DECODE(fm_intraoperation_step_type,WIP_CONSTANTS.SCRAP,primary_quantity,0),0)),0) as quantity_scrap
 FROM (
        SELECT
             transaction_date,primary_quantity,to_intraoperation_step_type,fm_intraoperation_step_type,fm_operation_seq_num,to_operation_seq_num,
             transaction_date+ mod(shift_info,1)*1000 as shift_start_date,
             abs(mod(trunc(shift_info),100)) as shift_num,
             wip_entity_id,operation_seq_num
        FROM (
               SELECT
                    wip_ws_embedded_analytics_pk.get_shift_info(wmt.organization_id,(
                      case when (wmt.TO_DEPARTMENT_ID =WIP_CONSTANTS.SCRAP AND wop.operation_seq_num = wmt.fm_operation_seq_num) then wmt.to_department_id else wmt.fm_department_id end),wmt.transaction_date) as shift_info,
                    wop.wip_entity_id, wop.operation_seq_num,
                    wmt.transaction_date,wmt.primary_quantity,wmt.to_intraoperation_step_type,wmt.fm_intraoperation_step_type,fm_operation_seq_num,to_operation_seq_num
               FROM
                    wip_move_transactions wmt,
                    wip_operations wop
               WHERE
                    wop.wip_entity_id = wmt.wip_entity_id
                    AND wmt.organization_id = p_org_id
                    AND wop.organization_id = p_org_id
                    AND transaction_date >= p_cutoff_date
                    AND ((wmt.fm_intraoperation_step_type = 5 AND wmt.fm_operation_seq_num = wop.operation_seq_num)
                       OR (wmt.to_intraoperation_step_type = 5 AND wmt.to_operation_seq_num = wop.operation_seq_num))
             )pre_cal
      ) post_cal
 GROUP BY shift_start_date, shift_num, wip_entity_id, operation_seq_num */




------------------------------------ update QUANTITY_REJECTED ------------------------------------

        UPDATE
              wip_ws_fpy fpy
        SET
              QUANTITY_REJECTED =
              -- Formula = Sum(IN) - Sum(OUT BW)
              -- OUT BW = Move backword from REJECT except  moving to the 'TOMOVE' within the same opeation

                 nvl((SELECT
                          NVL(SUM(DECODE(wop.operation_seq_num,wmt.to_operation_seq_num,
                                         DECODE(wmt.to_intraoperation_step_type,WIP_CONSTANTS.REJECT, wmt.primary_quantity,0),0)
                                  ),0)
                          - NVL(SUM(DECODE(wop.operation_seq_num,fm_operation_seq_num,
                                           DECODE(wmt.fm_intraoperation_step_type,WIP_CONSTANTS.REJECT,
                                                DECODE(SIGN(wmt.fm_operation_seq_num-wmt.to_operation_seq_num),
                                                       1,wmt.primary_quantity, -- Out Backward different operation seq
                                                       0,DECODE(wmt.to_intraoperation_step_type,WIP_CONSTANTS.TOMOVE,0,wmt.primary_quantity),0) -- Out Backward within same operation seq
                                                ),0)
                                    ),0) as quantity_reject
                      FROM
                        (
                            SELECT
                                (case when (shift_info is not null) then transaction_date+ mod(shift_info,1)*1000 else trunc(transaction_date) end )as shift_start_date,
                                (case when (shift_info is not null) then abs(mod(trunc(shift_info),100)) else -1 end)as shift_num,
                                wip_entity_id,
                                primary_quantity,
                                to_operation_seq_num,
                                to_intraoperation_step_type,
                                fm_operation_seq_num,
                                fm_intraoperation_step_type
                            FROM
                                (
                                    SELECT
                                        wip_ws_embedded_analytics_pk.get_shift_info(wmt.organization_id
                                        ,(case when wmt.to_intraoperation_step_type = WIP_CONSTANTS.REJECT then wmt.to_department_id else wmt.fm_department_id end)
                                        ,wmt.transaction_date) as shift_info ,
                                        wmt.*
                                    FROM
                                        wip_move_transactions wmt
                                    WHERE
                                        transaction_date > p_cutoff_date
                                        AND wmt.organization_id = p_org_id
                                        AND (wmt.fm_intraoperation_step_type = WIP_CONSTANTS.REJECT
                                             OR wmt.to_intraoperation_step_type = WIP_CONSTANTS.REJECT)
                                ) wmt_raw_shift_info
                        ) wmt,
                        wip_operations wop

                      WHERE
                        wop.wip_entity_id = wmt.wip_entity_id
                        AND wop.organization_id = p_org_id
                        AND ((wmt.fm_intraoperation_step_type = WIP_CONSTANTS.REJECT AND wmt.fm_operation_seq_num = wop.operation_seq_num )
                            OR (wmt.to_intraoperation_step_type = WIP_CONSTANTS.REJECT AND wmt.to_operation_seq_num = wop.operation_seq_num))
                        AND fpy.wip_entity_id = wop.wip_entity_id
                        AND fpy.operation_seq_num = wop.operation_seq_num
                        AND fpy.shift_num = wmt.shift_num
                        AND fpy.shift_date = wmt.shift_start_date
                        AND fpy.organization_id = p_org_id

                      GROUP BY wmt.shift_start_date, wmt.shift_num, wop.wip_entity_id, wop.operation_seq_num),0);

/*
Wrong SQL
                 nvl((SELECT
                          NVL(SUM(DECODE(wop.operation_seq_num,post_cal.to_operation_seq_num,
                                         DECODE(post_cal.to_intraoperation_step_type,WIP_CONSTANTS.REJECT, post_cal.primary_quantity,0),0)
                                  ),0)
                          - NVL(SUM(DECODE(wop.operation_seq_num,fm_operation_seq_num,
                                           DECODE(post_cal.fm_intraoperation_step_type,WIP_CONSTANTS.REJECT,
                                                DECODE(SIGN(post_cal.fm_operation_seq_num-post_cal.to_operation_seq_num),
                                                       1,post_cal.primary_quantity, -- Out Backward different operation seq
                                                       0,DECODE(post_cal.to_intraoperation_step_type,WIP_CONSTANTS.TOMOVE,0,post_cal.primary_quantity),0) -- Out Backward within same operation seq
                                                ),0)
                                    ),0) as quantity_reject

                      FROM
                        (
                          SELECT
                              pre_cal.department_id,
                              pre_cal.primary_quantity,
                              pre_cal.wip_entity_id,
                              pre_cal.operation_seq_num,
                              pre_cal.transaction_date+ mod(pre_cal.shift_info,1)*1000 as shift_start_date,
                              abs(mod(trunc(pre_cal.shift_info),100)) as shift_num,
                              pre_cal.fm_operation_seq_num,
                              pre_cal.to_operation_seq_num,
                              pre_cal.fm_intraoperation_step_type,
                              pre_cal.to_intraoperation_step_type
                          FROM
                            (
                              SELECT
                                  wop.department_id,
                                  wmt.wip_entity_id,
                                  wmt.transaction_id,
                                  wop.operation_seq_num,
                                  wmt.fm_operation_seq_num,
                                  wmt.to_operation_seq_num,
                                  wmt.fm_intraoperation_step_type,
                                  wmt.to_intraoperation_step_type,
                                  wmt.primary_quantity,
                                  wmt.transaction_date,
                                  wip_ws_embedded_analytics_pk.get_shift_info(wmt.organization_id,null, wmt.transaction_date) as shift_info
                              FROM
                                  wip_move_transactions wmt,
                                  wip_operations wop
                              WHERE
                                  wmt.transaction_date >= p_cutoff_date
                                  AND wmt.organization_id = p_org_id
                                  AND wop.organization_id = p_org_id
                                  AND wop.wip_entity_id = wmt.wip_entity_id
                                  AND (wmt.fm_intraoperation_step_type = WIP_CONSTANTS.REJECT
                                       OR wmt.to_intraoperation_step_type = WIP_CONSTANTS.REJECT)
                                  AND ((wop.operation_seq_num >= wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                                          AND (wop.operation_seq_num < wmt.to_operation_seq_num + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                                          AND (wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                                              OR (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                                                  AND wmt.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                                                  AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
                                          AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                                              OR wop.operation_seq_num = wmt.fm_operation_seq_num
                                              OR (wop.operation_seq_num = wmt.to_operation_seq_num
                                              AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN)))
                                  OR
                                      (wop.operation_seq_num < wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                                      AND (wop.operation_seq_num >= wmt.to_operation_seq_num  + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                                      AND (wmt.fm_operation_seq_num > wmt.to_operation_seq_num
                                          OR (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                                              AND wmt.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                                              AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
                                      AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                                          OR (wop.operation_seq_num = wmt.to_operation_seq_num
                                              AND wop.count_point_type < WIP_CONSTANTS.NO_MANUAL )
                                          OR (wop.operation_seq_num = wmt.fm_operation_seq_num
                                              AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))))
                            ) pre_cal
                        ) post_cal,
                        wip_operations wop
                      WHERE
                        wop.wip_entity_id = post_cal.wip_entity_id
                        AND wop.organization_id = p_org_id
                        AND ((post_cal.fm_intraoperation_step_type = WIP_CONSTANTS.REJECT AND post_cal.fm_operation_seq_num = wop.operation_seq_num )
                            OR (post_cal.to_intraoperation_step_type = WIP_CONSTANTS.REJECT AND post_cal.to_operation_seq_num = wop.operation_seq_num))

                        AND fpy.wip_entity_id = wop.wip_entity_id
                        AND fpy.operation_seq_num = wop.operation_seq_num
                        AND fpy.shift_num = post_cal.shift_num
                        AND fpy.shift_date = post_cal.shift_start_date
                        AND fpy.organization_id = p_org_id
                      GROUP BY post_cal.shift_start_date, post_cal.shift_num, wop.wip_entity_id, wop.operation_seq_num),0);
*/
        wip_ws_util.trace_log('Finish Updating QUANTITY_REJECTED');
------------------------------------ update QUANTITY_FIRST_PASS ------------------------------------
/*
        UPDATE
              wip_ws_fpy fpy
        SET
              QUANTITY_FIRST_PASS = QUANTITY_COMPLETED - QUANTITY_REJECTED - QUANTITY_SCRAPPED
        WHERE
              LAST_UPDATE_DATE = p_execution_date
              AND organization_id = p_org_id;

        wip_ws_util.trace_log('Finish Updating QUANTITY_FIRST_PASS');
*/
-------------------------------------- end of population logic -------------------------------------------------------

        IF (g_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.populate_fpy_raw_data',
                                   p_procReturnStatus => l_return_status,
                                   p_msg => 'procedure success.',
                                   x_returnStatus => l_return_Status);
        END IF;

  EXCEPTION
    WHEN others THEN
      wip_ws_util.trace_log('Error in populate_fpy_raw_data');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.populate_fpy_raw_data',
                               p_procReturnStatus => l_return_status,
                               p_msg => 'unexpected error: ' || SQLERRM,
                               x_returnStatus => l_return_Status);
      END IF;
  END populate_fpy_raw_data;



--============================================ PER JOBOP ========


  PROCEDURE calc_fpy_per_jobop_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_jobop_day_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    UPDATE wip_ws_fpy wwf
    SET
     SCRAP_PERCENT  = (case when (wwf.QUANTITY_COMPLETED = 0 OR (wwf.QUANTITY_COMPLETED-wwf.QUANTITY_SCRAPPED-wwf.QUANTITY_REJECTED)/wwf.QUANTITY_COMPLETED < 0) then 0
      else round(100*(wwf.QUANTITY_SCRAPPED/wwf.QUANTITY_COMPLETED),2) end),
     REJECT_PERCENT = (case when (wwf.QUANTITY_COMPLETED = 0 OR (wwf.QUANTITY_COMPLETED-wwf.QUANTITY_SCRAPPED-wwf.QUANTITY_REJECTED)/wwf.QUANTITY_COMPLETED < 0) then 0
      else round(100*(wwf.QUANTITY_REJECTED/wwf.QUANTITY_COMPLETED),2) end),
     FPY_PERCENT =    (case when (wwf.QUANTITY_COMPLETED = 0 OR (wwf.QUANTITY_COMPLETED-wwf.QUANTITY_SCRAPPED-wwf.QUANTITY_REJECTED)/wwf.QUANTITY_COMPLETED < 0) then 0
      else round(100*(wwf.QUANTITY_COMPLETED-wwf.QUANTITY_SCRAPPED-wwf.QUANTITY_REJECTED)/wwf.QUANTITY_COMPLETED,2) end)
    WHERE
      LAST_UPDATE_DATE = p_execution_date
      AND wwf.organization_id = p_org_id
      AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
      AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
      AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,x_return_status);
  END calc_fpy_per_jobop_day_shift;

  PROCEDURE calc_fpy_per_jobop_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_jobop_day';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, pre_cal.INVENTORY_ITEM_ID,
        pre_cal.WIP_ENTITY_ID, pre_cal.OPERATION_SEQ_NUM,
        null as SHIFT_NUM, pre_cal.SHIFT_DATE,
        pre_cal.QUANTITY_REJECTED AS QUANTITY_REJECTED, pre_cal.QUANTITY_SCRAPPED AS QUANTITY_SCRAPPED, pre_cal.QUANTITY_COMPLETED AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wwf.WIP_ENTITY_ID,wwf.OPERATION_SEQ_NUM,Trunc(wwf.SHIFT_DATE) as SHIFT_DATE,wwf.DEPARTMENT_ID,wwf.INVENTORY_ITEM_ID,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT,
            sum(wwf.QUANTITY_COMPLETED) as QUANTITY_COMPLETED, sum(wwf.QUANTITY_SCRAPPED) as QUANTITY_SCRAPPED, sum (wwf.QUANTITY_REJECTED) as QUANTITY_REJECTED
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY wwf.OPERATION_SEQ_NUM,trunc(wwf.SHIFT_DATE),wwf.WIP_ENTITY_ID,wwf.DEPARTMENT_ID,wwf.INVENTORY_ITEM_ID
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_jobop_day;




  PROCEDURE calc_fpy_per_jobop_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_jobop_week';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, pre_cal.INVENTORY_ITEM_ID,
        pre_cal.WIP_ENTITY_ID, pre_cal.OPERATION_SEQ_NUM,
        null as SHIFT_NUM, null SHIFT_DATE,
        pre_cal.QUANTITY_REJECTED AS QUANTITY_REJECTED, pre_cal.QUANTITY_SCRAPPED AS QUANTITY_SCRAPPED, pre_cal.QUANTITY_COMPLETED AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wwf.WIP_ENTITY_ID,wwf.OPERATION_SEQ_NUM,wwf.DEPARTMENT_ID,wwf.INVENTORY_ITEM_ID,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT,
            sum(wwf.QUANTITY_COMPLETED) as QUANTITY_COMPLETED, sum(wwf.QUANTITY_SCRAPPED) as QUANTITY_SCRAPPED, sum (wwf.QUANTITY_REJECTED) as QUANTITY_REJECTED
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND wwf.SHIFT_DATE >= trunc(p_execution_date)-6
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY wwf.OPERATION_SEQ_NUM,wwf.WIP_ENTITY_ID,wwf.DEPARTMENT_ID,wwf.INVENTORY_ITEM_ID
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_jobop_week;




  PROCEDURE calc_fpy_per_jobop_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_jobop_week_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, pre_cal.INVENTORY_ITEM_ID,
        pre_cal.WIP_ENTITY_ID, pre_cal.OPERATION_SEQ_NUM,
        pre_cal.SHIFT_NUM AS SHIFT_NUM, NULL SHIFT_DATE,
        pre_cal.QUANTITY_REJECTED AS QUANTITY_REJECTED, pre_cal.QUANTITY_SCRAPPED AS QUANTITY_SCRAPPED, pre_cal.QUANTITY_COMPLETED AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wwf.WIP_ENTITY_ID,wwf.OPERATION_SEQ_NUM,wwf.DEPARTMENT_ID,wwf.INVENTORY_ITEM_ID,wwf.SHIFT_NUM,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) AS SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) AS REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT,
            sum(wwf.QUANTITY_COMPLETED) as QUANTITY_COMPLETED, sum(wwf.QUANTITY_SCRAPPED) as QUANTITY_SCRAPPED, sum (wwf.QUANTITY_REJECTED) as QUANTITY_REJECTED
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND wwf.SHIFT_DATE >= trunc(p_execution_date-6)
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY wwf.OPERATION_SEQ_NUM,wwf.WIP_ENTITY_ID,wwf.DEPARTMENT_ID,wwf.INVENTORY_ITEM_ID,wwf.SHIFT_NUM
        ) pre_cal;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_jobop_week_shift;




  /*
 PROCEDURE calc_fpy_per_job_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_job_day';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_job_day;
*/

--============================================ PER JOB ========

 PROCEDURE calc_fpy_per_job_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_job_day';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, pre_calc.INVENTORY_ITEM_ID,
        pre_calc.WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, pre_calc .SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, pre_calc.START_QUANTITY AS QUANTITY_COMPLETED,
        pre_calc.SCRAP_PERCENT * 100 AS SCRAP_PERCENT,
        pre_calc.REJECT_PERCENT * 100 AS REJECT_PERCENT, --Bug 7114765
        pre_calc.FPY_PERCENT*100 AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wdj.START_QUANTITY, day_sum.WIP_ENTITY_ID, day_sum.INVENTORY_ITEM_ID, day_sum.SHIFT_DATE,day_sum.FPY_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_SCRAP/wdj.START_QUANTITY,4) END) as SCRAP_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_REJECT/wdj.START_QUANTITY,4) END) as REJECT_PERCENT  --Bug 7114765
	FROM
             ( SELECT
                 round(exp(sum(ln(DECODE(SIGN(FPY_PERCENT),1,FPY_PERCENT/100,1)))),4) as FPY_PERCENT,
                 SUM(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 SUM(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
		 wwf.WIP_ENTITY_ID,
                 TRUNC(shift_date) as SHIFT_DATE, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
                 AND wwf.SHIFT_DATE is NOT NULL AND wwf.SHIFT_NUM is NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, TRUNC(shift_date),wwf.INVENTORY_ITEM_ID
               HAVING MIN(FPY_PERCENT) > 0

               UNION

               SELECT 0 as FPY_PERCENT,
                 SUM(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 SUM(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --BUG 7114765
		wwf.WIP_ENTITY_ID,
                 TRUNC(shift_date) as SHIFT_DATE, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
                 AND wwf.SHIFT_DATE is NOT NULL AND wwf.SHIFT_NUM is NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
              GROUP BY wwf.WIP_ENTITY_ID, TRUNC(shift_date),wwf.INVENTORY_ITEM_ID
              HAVING MIN(FPY_PERCENT) <= 0
              ) day_sum,
           WIP_DISCRETE_JOBS wdj
          WHERE wdj.WIP_ENTITY_ID = day_sum.WIP_ENTITY_ID
           AND wdj.organization_id = p_org_id) pre_calc;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_job_day;



 PROCEDURE calc_fpy_per_job_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_job_day_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, pre_calc.INVENTORY_ITEM_ID,
        pre_calc.WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_calc.SHIFT_NUM, pre_calc.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, pre_calc.START_QUANTITY AS QUANTITY_COMPLETED,
        pre_calc.SCRAP_PERCENT * 100 AS SCRAP_PERCENT,
        pre_calc.REJECT_PERCENT * 100 AS REJECT_PERCENT, --Bug 7114765
        pre_calc.FPY_PERCENT*100 AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wdj.START_QUANTITY, day_sum.WIP_ENTITY_ID, day_sum.INVENTORY_ITEM_ID, day_sum.SHIFT_DATE, day_sum.SHIFT_NUM, day_sum.FPY_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_SCRAP/wdj.START_QUANTITY,4) END) as SCRAP_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_REJECT/wdj.START_QUANTITY,4) END) as REJECT_PERCENT  --Bug 7114765
	 FROM
             ( SELECT
                 round(exp(sum(ln(DECODE(SIGN(FPY_PERCENT),1,FPY_PERCENT/100,1)))),4) as FPY_PERCENT,
                 SUM(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 SUM(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
		 wwf.WIP_ENTITY_ID,
                 TRUNC(shift_date) as SHIFT_DATE, wwf.SHIFT_NUM, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id AND TRUNC(wwf.shift_date) >= trunc(p_cutoff_date)
                 AND wwf.SHIFT_DATE is NOT NULL AND wwf.SHIFT_NUM is NOT NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, TRUNC(shift_date),wwf.SHIFT_NUM ,wwf.INVENTORY_ITEM_ID
               HAVING MIN(FPY_PERCENT) > 0

               UNION

               SELECT
                 0 as FPY_PERCENT,
                 SUM(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 SUM(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
		 wwf.WIP_ENTITY_ID,
                 TRUNC(shift_date) as SHIFT_DATE, wwf.SHIFT_NUM, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id AND TRUNC(wwf.shift_date) >= trunc(p_cutoff_date)
                 AND wwf.SHIFT_DATE is NOT NULL AND wwf.SHIFT_NUM is NOT NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, TRUNC(shift_date),wwf.SHIFT_NUM ,wwf.INVENTORY_ITEM_ID
               HAVING MIN(FPY_PERCENT) <= 0
             ) day_sum,
           WIP_DISCRETE_JOBS wdj
          WHERE wdj.WIP_ENTITY_ID = day_sum.WIP_ENTITY_ID
           AND wdj.organization_id = p_org_id) pre_calc;
/*
    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, pre_calc.INVENTORY_ITEM_ID,
        pre_calc.WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_calc.SHIFT_NUM, pre_calc.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, pre_calc.START_QUANTITY AS QUANTITY_COMPLETED,
        pre_calc.SCRAP_PERCENT * 100 AS SCRAP_PERCENT,
        100*(1 - pre_calc.FPY_PERCENT- pre_calc.SCRAP_PERCENT) AS REJECT_PERCENT,
        pre_calc.FPY_PERCENT*100 AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wdj.START_QUANTITY, day_sum.WIP_ENTITY_ID, day_sum.INVENTORY_ITEM_ID, day_sum.SHIFT_DATE, day_sum.SHIFT_NUM, day_sum.FPY_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_SCRAP/wdj.START_QUANTITY,4) END) as SCRAP_PERCENT  FROM
             ( SELECT  as FPY_PERCENT, sum(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP, wwf.WIP_ENTITY_ID,
                 TRUNC(shift_date) as SHIFT_DATE, wwf.SHIFT_NUM, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id AND TRUNC(wwf.shift_date) >= trunc(p_cutoff_date)
                AND wwf.SHIFT_DATE is NOT NULL AND wwf.SHIFT_NUM is NOT NULL
                AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
              GROUP BY wwf.WIP_ENTITY_ID, TRUNC(shift_date),wwf.SHIFT_NUM ,wwf.INVENTORY_ITEM_ID
              HAVING MIN(FPY_PERCENT) = 0) day_sum,
           WIP_DISCRETE_JOBS wdj
          WHERE wdj.WIP_ENTITY_ID = day_sum.WIP_ENTITY_ID
           AND wdj.organization_id = p_org_id) pre_calc;
*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_job_day_shift;



 PROCEDURE calc_fpy_per_job_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_job_week';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, pre_calc.INVENTORY_ITEM_ID,
        pre_calc.WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, pre_calc.START_QUANTITY AS QUANTITY_COMPLETED,
        pre_calc.SCRAP_PERCENT * 100 AS SCRAP_PERCENT,
        pre_calc.REJECT_PERCENT * 100 AS REJECT_PERCENT, --Bug 7114765
        pre_calc.FPY_PERCENT*100 AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wdj.START_QUANTITY, day_sum.WIP_ENTITY_ID, day_sum.INVENTORY_ITEM_ID, day_sum.FPY_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_SCRAP/wdj.START_QUANTITY,4) END) as SCRAP_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_REJECT/wdj.START_QUANTITY,4) END) as REJECT_PERCENT  --Bug 7114765
	FROM
             ( SELECT
                 round(exp(sum(ln(DECODE(SIGN(FPY_PERCENT),1,FPY_PERCENT/100,1)))),4) as FPY_PERCENT,
                 sum(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 sum(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
                 wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id
                 AND wwf.SHIFT_DATE is NULL AND wwf.SHIFT_NUM is NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID
               HAVING MIN(FPY_PERCENT) > 0

               UNION

               SELECT 0 as FPY_PERCENT,
                 sum(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 sum(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
                 wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id
                 AND wwf.SHIFT_DATE is NULL AND wwf.SHIFT_NUM is NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID
               HAVING MIN(FPY_PERCENT) <= 0
              ) day_sum,
           WIP_DISCRETE_JOBS wdj
          WHERE wdj.WIP_ENTITY_ID = day_sum.WIP_ENTITY_ID
           AND wdj.organization_id = p_org_id) pre_calc;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_job_week;




 PROCEDURE calc_fpy_per_job_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_job_week_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, pre_calc.INVENTORY_ITEM_ID,
        pre_calc.WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_calc.SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, pre_calc.START_QUANTITY AS QUANTITY_COMPLETED,
        pre_calc.SCRAP_PERCENT * 100 AS SCRAP_PERCENT,
        pre_calc.REJECT_PERCENT * 100 AS REJECT_PERCENT, --Bug 7114765
        pre_calc.FPY_PERCENT*100 AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wdj.START_QUANTITY, day_sum.WIP_ENTITY_ID, day_sum.INVENTORY_ITEM_ID, day_sum.FPY_PERCENT, day_sum.SHIFT_NUM,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_SCRAP/wdj.START_QUANTITY,4) END) as SCRAP_PERCENT,
           (CASE WHEN (wdj.START_QUANTITY = 0) THEN 0 ELSE round(day_sum.TOTAL_DAY_REJECT/wdj.START_QUANTITY,4) END) as REJECT_PERCENT  --Bug 7114765
	FROM
             ( SELECT
                 round(exp(sum(ln(DECODE(SIGN(FPY_PERCENT),1,FPY_PERCENT/100,1)))),4) as FPY_PERCENT,
                 sum(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 sum(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
                 wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID, wwf.SHIFT_NUM
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id
                 AND wwf.SHIFT_DATE is NULL AND wwf.SHIFT_NUM is NOT NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID, wwf.SHIFT_NUM
               HAVING MIN(FPY_PERCENT) > 0

               UNION

               SELECT 0 as FPY_PERCENT,
                 sum(wwf.QUANTITY_SCRAPPED) as TOTAL_DAY_SCRAP,
                 sum(wwf.QUANTITY_REJECTED) as TOTAL_DAY_REJECT, --Bug 7114765
                 wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID, wwf.SHIFT_NUM
               FROM WIP_WS_FPY wwf
               WHERE wwf.organization_id = p_org_id
                 AND wwf.SHIFT_DATE is NULL AND wwf.SHIFT_NUM is NOT NULL
                 AND wwf.WIP_ENTITY_ID is NOT NULL AND wwf.DEPARTMENT_ID is NOT NULL
                 AND wwf.INVENTORY_ITEM_ID is NOT NULL AND wwf.OPERATION_SEQ_NUM is NOT NULL
               GROUP BY wwf.WIP_ENTITY_ID, wwf.INVENTORY_ITEM_ID, wwf.SHIFT_NUM
               HAVING MIN(FPY_PERCENT) <= 0
              ) day_sum,
           WIP_DISCRETE_JOBS wdj
          WHERE wdj.WIP_ENTITY_ID = day_sum.WIP_ENTITY_ID
           AND wdj.organization_id = p_org_id) pre_calc;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_job_week_shift;


--============================================ PER ASSEMBLY ========

 PROCEDURE calc_fpy_per_assm_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_assm_day_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, wwf.INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        wwf.SHIFT_NUM, wwf.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.SCRAP_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS SCRAP_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.REJECT_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS REJECT_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.FPY_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM wip_ws_fpy wwf
      WHERE wwf.WIP_ENTITY_ID is NOT NULL and wwf.OPERATION_SEQ_NUM is NULL
        and wwf.INVENTORY_ITEM_ID is NOT NULL and wwf.DEPARTMENT_ID is NULL
        and wwf.SHIFT_DATE is NOT NULL and wwf.SHIFT_NUM is NOT NULL
        and wwf.ORGANIZATION_ID = p_org_id
        and TRUNC(wwf.SHIFT_DATE) >= TRUNC(p_cutoff_date)
      GROUP BY wwf.Inventory_Item_id, wwf.SHIFT_DATE, wwf.SHIFT_NUM;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_assm_day_shift;




 PROCEDURE calc_fpy_per_assm_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_assm_day';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, wwf.INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, wwf.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.SCRAP_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS SCRAP_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.REJECT_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS REJECT_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.FPY_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM wip_ws_fpy wwf
      WHERE wwf.WIP_ENTITY_ID is NOT NULL and wwf.OPERATION_SEQ_NUM is NULL
        and wwf.INVENTORY_ITEM_ID is NOT NULL and wwf.DEPARTMENT_ID is NULL
        and wwf.SHIFT_DATE is NOT NULL and wwf.SHIFT_NUM is NULL
        and wwf.ORGANIZATION_ID = p_org_id
        and TRUNC(wwf.SHIFT_DATE) >= TRUNC(p_cutoff_date)
      GROUP BY wwf.Inventory_Item_id, wwf.SHIFT_DATE;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_assm_day;



 PROCEDURE calc_fpy_per_assm_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_assm_week_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, wwf.INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        wwf.SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.SCRAP_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS SCRAP_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.REJECT_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS REJECT_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.FPY_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM wip_ws_fpy wwf
      WHERE wwf.WIP_ENTITY_ID is NOT NULL and wwf.OPERATION_SEQ_NUM is NULL
        and wwf.INVENTORY_ITEM_ID is NOT NULL and wwf.DEPARTMENT_ID is NULL
        and wwf.SHIFT_DATE is  NULL and wwf.SHIFT_NUM is NOT NULL
        and wwf.ORGANIZATION_ID = p_org_id
      GROUP BY wwf.Inventory_Item_id, wwf.SHIFT_NUM;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_assm_week_shift;



 PROCEDURE calc_fpy_per_assm_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_assm_week';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
    ) SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, wwf.INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.SCRAP_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS SCRAP_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.REJECT_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS REJECT_PERCENT,
        (CASE WHEN (SUM(wwf.QUANTITY_COMPLETED)=0) THEN 0 ELSE ROUND(SUM(wwf.FPY_PERCENT*wwf.QUANTITY_COMPLETED)/SUM(wwf.QUANTITY_COMPLETED),2) END) AS FPY_PERCENT,
        g_request_id  AS REQUEST_ID, g_prog_id AS PROGRAM_ID,
        p_execution_date AS LAST_UPDATE_DATE, g_user_id AS LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date AS CREATION_DATE, g_user_id AS CREATED_BY,
        g_prog_appid AS PROGRAM_APPLICATION_ID,  p_execution_date AS PROGRAM_UPDATE_DATE
      FROM wip_ws_fpy wwf
      WHERE wwf.WIP_ENTITY_ID is NOT NULL and wwf.OPERATION_SEQ_NUM is NULL
        and wwf.INVENTORY_ITEM_ID is NOT NULL and wwf.DEPARTMENT_ID is NULL
        and wwf.SHIFT_DATE is NULL and wwf.SHIFT_NUM is NULL
        and wwf.ORGANIZATION_ID = p_org_id
      GROUP BY wwf.Inventory_Item_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_assm_week;


--============================================ PER DEPARTMENT ========

  PROCEDURE calc_fpy_per_dept_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_dept_day_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_cal.SHIFT_NUM, pre_cal.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        pre_cal.SCRAP_PERCENT, pre_cal.REJECT_PERCENT, pre_cal.FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT TRUNC(wwf.SHIFT_DATE) as SHIFT_DATE,wwf.DEPARTMENT_ID,wwf.SHIFT_NUM,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY TRUNC(wwf.SHIFT_DATE),wwf.DEPARTMENT_ID,wwf.SHIFT_NUM
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_dept_day_shift;



  PROCEDURE calc_fpy_per_dept_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_dept_day';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, pre_cal.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        pre_cal.SCRAP_PERCENT, pre_cal.REJECT_PERCENT, pre_cal.FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT TRUNC(wwf.SHIFT_DATE) as SHIFT_DATE,wwf.DEPARTMENT_ID,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY TRUNC(wwf.SHIFT_DATE),wwf.DEPARTMENT_ID
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_dept_day;




  PROCEDURE calc_fpy_per_dept_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_dept_week_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_cal.SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        pre_cal.SCRAP_PERCENT, pre_cal.REJECT_PERCENT, pre_cal.FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wwf.DEPARTMENT_ID,wwf.SHIFT_NUM,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND wwf.shift_date >= TRUNC(p_execution_date)-6
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY wwf.DEPARTMENT_ID,wwf.SHIFT_NUM
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_dept_week_shift;


   PROCEDURE calc_fpy_per_dept_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_per_dept_week';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, pre_cal.DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        pre_cal.SCRAP_PERCENT, pre_cal.REJECT_PERCENT, pre_cal.FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wwf.DEPARTMENT_ID,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND wwf.shift_date >= TRUNC(p_execution_date)-6
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY wwf.DEPARTMENT_ID
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_per_dept_week;


  PROCEDURE calc_fpy_all_depts_day_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_all_depts_day_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_cal.SHIFT_NUM, pre_cal.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT TRUNC(wwf.SHIFT_DATE) as SHIFT_DATE ,wwf.SHIFT_NUM,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY TRUNC(wwf.SHIFT_DATE),wwf.SHIFT_NUM
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_all_depts_day_shift;


  PROCEDURE calc_fpy_all_depts_day(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_all_depts_day';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, pre_cal.SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT TRUNC(wwf.SHIFT_DATE) as SHIFT_DATE,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND TRUNC(wwf.shift_date) >= TRUNC(p_cutoff_date)
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY TRUNC(wwf.SHIFT_DATE)
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_all_depts_day;




  PROCEDURE calc_fpy_all_depts_week_shift(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_all_depts_week_shift';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        pre_cal.SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT wwf.SHIFT_NUM,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND wwf.shift_date >= TRUNC(p_execution_date)-6
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL
          GROUP BY wwf.SHIFT_NUM
        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_all_depts_week_shift;


   PROCEDURE calc_fpy_all_depts_week(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_all_depts_week';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    INSERT INTO wip_ws_fpy (
        ORGANIZATION_ID, DEPARTMENT_ID, INVENTORY_ITEM_ID,
        WIP_ENTITY_ID, OPERATION_SEQ_NUM,
        SHIFT_NUM, SHIFT_DATE,
        QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
        SCRAP_PERCENT, REJECT_PERCENT, FPY_PERCENT,
        REQUEST_ID, PROGRAM_ID,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        CREATION_DATE, CREATED_BY,
        PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
      )
      SELECT
        p_org_id AS ORGANIZATION_ID, NULL as DEPARTMENT_ID, NULL AS INVENTORY_ITEM_ID,
        NULL AS WIP_ENTITY_ID, NULL AS OPERATION_SEQ_NUM,
        NULL AS SHIFT_NUM, NULL AS SHIFT_DATE,
        NULL AS QUANTITY_REJECTED, NULL AS QUANTITY_SCRAPPED, NULL AS QUANTITY_COMPLETED,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.SCRAP_PERCENT end) as SCRAP_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.REJECT_PERCENT end) as REJECT_PERCENT,
        (case when (pre_cal.FPY_PERCENT < 0) then 0 else pre_cal.FPY_PERCENT end) as FPY_PERCENT,
        g_request_id  as REQUEST_ID, g_prog_id as PROGRAM_ID,
        p_execution_date as LAST_UPDATE_DATE, g_user_id as LAST_UPDATED_BY, g_login_id as LAST_UPDATE_LOGIN,
        p_execution_date as CREATION_DATE, g_user_id as CREATED_BY,
        g_prog_appid as PROGRAM_APPLICATION_ID,  p_execution_date as PROGRAM_UPDATE_DATE
      FROM
        ( SELECT
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_SCRAPPED)/sum(wwf.QUANTITY_COMPLETED),2) end) as SCRAP_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*sum(wwf.QUANTITY_REJECTED)/sum(wwf.QUANTITY_COMPLETED),2) end) as REJECT_PERCENT,
            (case when (sum(wwf.QUANTITY_COMPLETED) = 0) then 0 else round(100*(sum(wwf.QUANTITY_COMPLETED)-sum(QUANTITY_SCRAPPED+QUANTITY_REJECTED))/sum(wwf.QUANTITY_COMPLETED),2) end) as FPY_PERCENT
          FROM WIP_WS_FPY wwf
          WHERE organization_id =p_org_id
            AND wwf.shift_date >= TRUNC(p_execution_date)-6
            AND wwf.SHIFT_NUM IS NOT NULL AND wwf.SHIFT_DATE IS NOT NULL
            AND wwf.DEPARTMENT_ID IS NOT NULL AND wwf.INVENTORY_ITEM_ID IS NOT NULL
            AND wwf.WIP_ENTITY_ID IS NOT NULL AND wwf.OPERATION_SEQ_NUM IS NOT NULL

        ) pre_cal;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_all_depts_week;


 PROCEDURE calc_fpy_for_jobop_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_for_jobop_all';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => x_return_status);


    populate_fpy_raw_data(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_jobop_day_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_jobop_day(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_jobop_week(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_jobop_week_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);


    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_for_jobop_all;


 PROCEDURE calc_fpy_for_job_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_for_job_all';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => x_return_status);


    calc_fpy_per_job_day(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_job_day_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_job_week(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_job_week_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);


    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_for_job_all;


 PROCEDURE calc_fpy_for_assm_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_for_assm_all';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => x_return_status);


    calc_fpy_per_assm_day_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_assm_day(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_assm_week_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_assm_week(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);


    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_for_assm_all;


 PROCEDURE calc_fpy_for_dept_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_for_dept_all';

  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => x_return_status);

    calc_fpy_per_dept_day_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_dept_day(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_dept_week_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_per_dept_week(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);


    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_for_dept_all;


 PROCEDURE calc_fpy_for_all_depts_all(
              p_execution_date DATE,
              p_cutoff_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.calc_fpy_for_all_depts_all';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_execution_date,p_cutoff_date => p_cutoff_date,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => x_return_status);


    calc_fpy_all_depts_day_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_all_depts_day(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_all_depts_week_shift(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    calc_fpy_all_depts_week(
        p_execution_date => p_execution_date,
        p_cutoff_date => p_cutoff_date,
        p_org_id => p_org_id,
        x_return_status => x_return_status);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END calc_fpy_for_all_depts_all;


FUNCTION get_start_shift_date_to_calc(p_org_id IN NUMBER,
                       p_department_id IN NUMBER,
                       p_execution_date IN DATE)
RETURN DATE
IS
    l_last_shift_date  DATE;
    l_second_last_shift_date  DATE;
    l_retention_boundary DATE;
    l_start_move_tran_date_to_calc DATE;
    l_start_shift_date_to_calc DATE;
    l_shift_seq       NUMBER;
    l_shift_num       NUMBER;
    l_shift_start_date  DATE;
    l_shift_end_date    DATE;
    l_shift_string    VARCHAR2(100);
    l_calc_start_date DATE;
    l_last_calculation_date DATE;
    l_department_id NUMBER;

    l_params wip_logger.param_tbl_t;
    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.get_start_shift_date_to_calc';
  BEGIN

    l_params(1).paramName := 'p_org_id';
    l_params(1).paramValue := p_org_id;
    l_params(2).paramName := 'p_execution_date';
    l_params(2).paramValue := p_execution_date;
    begin_log (p_params => l_params,p_proc_name => l_proc_name,p_return_status => l_return_status);

    l_retention_boundary := TRUNC(p_execution_date - g_fpy_data_retention);


    BEGIN
      SELECT max(shift_date) INTO l_last_shift_date
      FROM wip_ws_fpy wwf
      WHERE organization_id = p_org_id
        AND wwf.operation_seq_num is NOT NULL
        AND wwf.wip_entity_id is NOT NULL
        AND wwf.inventory_item_id is NOT NULL
        AND wwf.department_id is NOT NULL
        AND wwf.shift_date is NOT NULL
        AND wwf.shift_num is NOT NULL;

      IF l_last_shift_date is NULL THEN
        l_second_last_shift_date := l_last_shift_date;
      ELSE
        SELECT max(shift_date) INTO l_second_last_shift_date
        FROM wip_ws_fpy wwf
        WHERE organization_id = p_org_id
          AND shift_date < l_last_shift_date
          AND wwf.operation_seq_num is NOT NULL
          AND wwf.wip_entity_id is NOT NULL
          AND wwf.inventory_item_id is NOT NULL
          AND wwf.department_id is NOT NULL
          AND wwf.shift_date is NOT NULL
          AND wwf.shift_num is NOT NULL;
        IF l_second_last_shift_date is NULL THEN
          l_second_last_shift_date := l_last_shift_date;
        END IF;
      END IF;

      IF l_second_last_shift_date > l_retention_boundary THEN
          l_start_shift_date_to_calc := l_second_last_shift_date;
      ELSE
          l_start_shift_date_to_calc := l_retention_boundary;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_start_shift_date_to_calc := l_retention_boundary;
      WHEN others THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

      SELECT MAX(CREATION_DATE) INTO l_last_calculation_date from WIP_WS_FPY;
      IF l_last_calculation_date is NULL THEN
        l_last_calculation_date := l_retention_boundary;
      ELSE
        IF l_last_calculation_date < l_retention_boundary THEN
          l_last_calculation_date := l_retention_boundary;
        END IF;
      END IF;

      BEGIN


        l_department_id := NULL;

        SELECT transaction_date INTO l_start_move_tran_date_to_calc
        FROM wip_move_transactions
        WHERE creation_date >= l_last_calculation_date
          AND organization_id = p_org_id
          AND ROWNUM = 1;

/*
   SELECT wmt.transaction_date, wop.department_id into l_start_move_tran_date_to_calc, l_department_id
        FROM wip_move_transactions wmt,
            wip_operations wop
        WHERE
            wmt.creation_date >= l_last_calculation_date
            AND wmt.organization_id = p_org_id
            AND wop.organization_id = p_org_id
            AND ROWNUM = 1
            AND wop.wip_entity_id = wmt.wip_entity_id
            AND ((wop.operation_seq_num >= wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                    AND (wop.operation_seq_num < wmt.to_operation_seq_num + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                    AND (wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                        OR (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                            AND wmt.fm_intraoperation_step_type <= WIP_CONSTANTS.RUN
                            AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN))
                    AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                        OR wop.operation_seq_num = wmt.fm_operation_seq_num
                        OR (wop.operation_seq_num = wmt.to_operation_seq_num
                        AND wmt.to_intraoperation_step_type > WIP_CONSTANTS.RUN)))
            OR
                (wop.operation_seq_num < wmt.fm_operation_seq_num + DECODE(SIGN(wmt.fm_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0)
                AND (wop.operation_seq_num >= wmt.to_operation_seq_num  + DECODE(SIGN(wmt.to_intraoperation_step_type - WIP_CONSTANTS.RUN),1,1,0))
                AND (wmt.fm_operation_seq_num > wmt.to_operation_seq_num
                    OR (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                        AND wmt.to_intraoperation_step_type <= WIP_CONSTANTS.RUN
                        AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))
                AND (wop.count_point_type < WIP_CONSTANTS.NO_MANUAL
                    OR (wop.operation_seq_num = wmt.to_operation_seq_num
                        AND wop.count_point_type < WIP_CONSTANTS.NO_MANUAL )
                    OR (wop.operation_seq_num = wmt.fm_operation_seq_num
                        AND wmt.fm_intraoperation_step_type > WIP_CONSTANTS.RUN))));
*/




        IF l_start_move_tran_date_to_calc < l_retention_boundary THEN
            l_start_move_tran_date_to_calc  := l_retention_boundary;
            l_department_id := NULL;
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_start_move_tran_date_to_calc  := l_retention_boundary;
        WHEN others THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      wip_ws_util.retrieve_first_shift(
        p_org_id,
        p_department_id,
        null,
        l_start_move_tran_date_to_calc,
        l_shift_seq,
        l_shift_num,
        l_shift_start_date,
        l_shift_end_date,
        l_shift_string
      );

      IF l_shift_start_date < l_start_shift_date_to_calc THEN
        l_calc_start_date := l_shift_start_date;
      ELSE
        l_calc_start_date := l_start_shift_date_to_calc;
      END IF;


     RETURN l_shift_start_date;
    EXCEPTION
      WHEN others THEN
        exception_log(l_proc_name,p_return_status => l_return_status);
  END get_start_shift_date_to_calc;


 PROCEDURE delete_old_and_replacing_data(
              p_calc_start_date DATE,
              p_retention_boundary DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1);
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.delete_old_and_replacing_data';
  BEGIN

    begin_log (p_params => set_calc_param(p_execution_date => p_calc_start_date,p_cutoff_date => p_retention_boundary,p_org_id => p_org_id),
                      p_proc_name => l_proc_name,
                      p_return_status => l_return_status);

    DELETE FROM wip_ws_fpy
    WHERE shift_date < p_retention_boundary
      AND organization_id = p_org_id;

    DELETE FROM wip_ws_fpy wwf
      WHERE organization_id = p_org_id
        AND shift_date is NULL;

  DELETE FROM wip_ws_fpy
      WHERE shift_date >= p_calc_start_date
      AND organization_id = p_org_id;

    DELETE FROM wip_ws_fpy
      WHERE TRUNC(shift_date) >= TRUNC(p_calc_start_date)
      AND organization_id = p_org_id
      AND (operation_seq_num is NULL
            OR wip_entity_id is NULL
            OR inventory_item_id is NULL
            OR department_id is NULL
            OR shift_num is NULL);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN others THEN
      exception_log(l_proc_name,p_return_status => x_return_status);
  END delete_old_and_replacing_data;


PROCEDURE wip_ws_fpykpi_conc_prog(
                               errbuf            OUT NOCOPY VARCHAR2,
                               retcode           OUT NOCOPY VARCHAR2,
                               p_org_id          IN  NUMBER) IS
/*
    l_msg_data        VARCHAR2(1000);
    l_msg_count       NUMBER;
    l_lock_status     NUMBER;
    l_shift_start_time NUMBER;
    l_cal_code bom_shift_dates.calendar_code%TYPE;
    l_exception_set_id NUMBER;
*/

    l_concurrent_execution_date DATE;
    l_retention_boundary DATE;
    l_calc_start_date DATE;

    l_return_status   VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_proc_name VARCHAR2(60) :='wip_ws_embedded_analytics_pk.wip_ws_fpykpi_conc_prog';

    l_concurrent_count NUMBER;
    l_conc_status boolean;

  BEGIN

    l_concurrent_execution_date := SYSDATE;
    l_retention_boundary := TRUNC(l_concurrent_execution_date - g_fpy_data_retention);

    l_params(1).paramName := 'p_org_id';
    l_params(1).paramValue := p_org_id;
    begin_log (p_params => l_params,
                p_proc_name => l_proc_name,
                p_return_status => l_return_status);


    wip_ws_util.trace_log('Org id  = '||to_char(p_org_id));
    wip_ws_util.trace_log('Start time  = '||to_char(l_concurrent_execution_date));

    SAVEPOINT wip_ws_fpykpi_calc;


    l_concurrent_count := wip_ws_util.get_no_of_running_concurrent(
    p_program_application_id => fnd_global.prog_appl_id,
    p_concurrent_program_id  => fnd_global.conc_program_id,
    p_org_id                 => p_org_id);

    if l_concurrent_count > 1 then
        wip_ws_util.log_for_duplicate_concurrent (
            p_org_id       => p_org_id,
            p_program_name => 'First Pass Yield KPI');
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Errors encountered in calculation program, please check the log file.');
        return;
    end if;


    delete wip_ws_fpy where organization_id = p_org_id;
    l_calc_start_date := trunc(l_concurrent_execution_date-g_fpy_data_retention);

    calc_fpy_for_jobop_all(
        p_execution_date => l_concurrent_execution_date,
        p_cutoff_date => l_calc_start_date,
        p_org_id => p_org_id,
        x_return_status => l_return_status);

    calc_fpy_for_job_all(
        p_execution_date => l_concurrent_execution_date,
        p_cutoff_date => l_calc_start_date,
        p_org_id => p_org_id,
        x_return_status => l_return_status);

    calc_fpy_for_assm_all(
        p_execution_date => l_concurrent_execution_date,
        p_cutoff_date => l_calc_start_date,
        p_org_id => p_org_id,
        x_return_status => l_return_status);

    calc_fpy_for_dept_all(
        p_execution_date => l_concurrent_execution_date,
        p_cutoff_date => l_calc_start_date,
        p_org_id => p_org_id,
        x_return_status => l_return_status);

    calc_fpy_for_all_depts_all(
        p_execution_date => l_concurrent_execution_date,
        p_cutoff_date => l_calc_start_date,
        p_org_id => p_org_id,
        x_return_status => l_return_status);


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        wip_ws_util.trace_log('Unexpected error occured in populate_fpy_raw_data API');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        wip_ws_util.trace_log('Expected error occurred in populate_fpy_raw_data API');
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        wip_ws_util.trace_log('populate_fpy_raw_data is successfull');
    END IF;

    IF (g_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.wip_ws_fpykpi_conc_prog',
                             p_procReturnStatus => l_return_status,
                             p_msg => 'processed successfully',
                             x_returnStatus => l_return_status);
    END IF;

  EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  l_return_status := 2;
                  exception_log(l_proc_name,p_return_status => l_return_status);

                  ROLLBACK TO wip_ws_fpykpi_calc;
                  retcode := 2;  -- End with error
       WHEN FND_API.G_EXC_ERROR THEN
                  retcode := 1;
                  wip_ws_util.trace_log('Came to expected error in wip_ws_fpykpi_conc_prog');
                  ROLLBACK TO wip_ws_fpykpi_calc;
       WHEN others THEN
                  wip_ws_util.trace_log('Came to others error in wip_ws_fpykpi_conc_prog');
                  ROLLBACK TO wip_ws_fpykpi_calc;
                  retcode := 2;  -- End with error
  END wip_ws_fpykpi_conc_prog;

FUNCTION get_shift_info(p_org_id IN NUMBER,
                       p_department_id IN NUMBER,
                       p_transaction_date IN DATE)
RETURN NUMBER
IS
   l_shift_seq       NUMBER;
   l_shift_num       NUMBER;
   l_shift_start_date  DATE;
   l_shift_end_date    DATE;
   l_shift_string    VARCHAR2(100);
   l_date_diff       NUMBER;
   l_return          NUMBER;
BEGIN
     wip_ws_util.retrieve_first_shift(
       p_org_id => p_org_id,
       p_dept_id => p_department_id,
       p_resource_id => null,
       p_date => p_transaction_date,
       x_shift_seq => l_shift_seq,
       x_shift_num => l_shift_num,
       x_shift_start_date => l_shift_start_date,
       x_shift_end_date => l_shift_end_date,
       x_shift_string => l_shift_string
     );

      l_date_diff := l_shift_start_date - p_transaction_date;
      l_return := (nvl(l_shift_seq,1) * 100) + nvl(l_shift_num,0);

      if l_date_diff < 0 then
        l_return := (l_return - (l_date_diff/1000))*-1;
      else
        l_return := l_return + (l_date_diff/1000);
      end if;

   RETURN l_return;
END get_shift_info;




  /*
    Description:
      Given the organization, department, resource, and a timestamp,
      find out which shift the timestamp belongs to. It uses the existing
      shift definition as defined in the wip_ws_util package.
    Parameters:
      p_org_id - the organization id
      p_dept_id - the department id
      p_resource_id - the resource id
      p_date - the timestamp
  */
  function get_shift_info_for_date
  (
    p_org_id in number,
    p_dept_id in number,
    p_resource_id in number,
    p_date in date
  ) return varchar2
  is
    l_cal_code varchar2(30);

    l_c_start_date date;
    l_c_end_date date;
    l_c_from_time varchar2(60);
    l_c_to_time varchar2(60);
    l_24hr_resource number;
    x_shift_seq number;
    x_shift_num number;
    x_shift_start_date date;
    x_shift_end_date date;
    x_shift_string varchar2(100);
  begin
    wip_ws_util.retrieve_first_shift(
      p_org_id => p_org_id,
      p_dept_id => p_dept_id,
      p_resource_id => p_resource_id,
      p_date => p_date,
      x_shift_seq => x_shift_seq,
      x_shift_num => x_shift_num,
      x_shift_start_date => x_shift_start_date,
      x_shift_end_date => x_shift_end_date,
      x_shift_string => x_shift_string
    );
    return (x_shift_seq || '.' ||
      x_shift_num || '.' ||
      TO_CHAR(x_shift_start_date, 'MM-DD-YYYY HH24:MI')  || '.' ||
      TO_CHAR(x_shift_end_date, 'MM-DD-YYYY HH24:MI')  || '.' ||
      x_shift_string || '.');
  end get_shift_info_for_date;

  FUNCTION extract_shift_info(p_shift_info VARCHAR2, p_index NUMBER)
    RETURN VARCHAR2
  IS
    l_start_position NUMBER;
    l_end_position NUMBER;
  BEGIN
    IF p_index = 1 THEN
      l_start_position := 1;
    ELSE
      l_start_position := instr(p_shift_info, '.', 1, p_index-1) + 1;
    END IF;
    l_end_position := instr(p_shift_info, '.', 1, p_index) - 1;
    RETURN substrb(p_shift_info, l_start_position, (l_end_position - l_start_position) + 1);
  END;

  FUNCTION get_shift_seq(p_shift_info VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_number(extract_shift_info(p_shift_info, 1));
  END get_shift_seq;

  FUNCTION get_shift_num(p_shift_info VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN to_number(extract_shift_info(p_shift_info, 2));
  END get_shift_num;

  FUNCTION get_shift_start_date(p_shift_info VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN to_date(extract_shift_info(p_shift_info, 3),'MM-DD-YYYY HH24:MI');
  END get_shift_start_date;


  PROCEDURE wip_ws_ppmdkpi_conc_prog(
                               errbuf            OUT NOCOPY VARCHAR2,
                               retcode           OUT NOCOPY VARCHAR2,
                               p_org_id          IN  NUMBER) IS

    l_return_status   VARCHAR2(1);
    l_concurrent_execution_date DATE;
    l_msg_data        VARCHAR2(1000);
    l_msg_count       NUMBER;
    l_lock_status     NUMBER;
    l_params wip_logger.param_tbl_t;
    l_shift_seq       NUMBER;
    l_shift_num       NUMBER;
    l_shift_start_date  DATE;
    l_shift_end_date    DATE;
    l_shift_string    VARCHAR2(100);
    l_shift_start_time NUMBER;

    l_concurrent_count NUMBER;
    l_conc_status boolean;

  BEGIN

      l_concurrent_execution_date := SYSDATE;

      IF (g_logLevel <= wip_constants.trace_logging) THEN

        l_params(1).paramName := 'p_org_id';
        l_params(1).paramValue := p_org_id;

        wip_logger.entryPoint(p_procName => 'wip_ws_embedded_analytics_pk.wip_ws_ppmdkpi_conc_prog',
                             p_params => l_params,
                             x_returnStatus => l_return_status);

        IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        wip_logger.log(' Start Time   : = '||to_char(l_concurrent_execution_date),l_return_status);

      END IF;

      wip_ws_util.trace_log('Org id  = '||to_char(p_org_id));
      wip_ws_util.trace_log('Start time  = '||to_char(l_concurrent_execution_date));


      SAVEPOINT wip_ws_ppmdkpi_calc;


    l_concurrent_count := wip_ws_util.get_no_of_running_concurrent(
    p_program_application_id => fnd_global.prog_appl_id,
    p_concurrent_program_id  => fnd_global.conc_program_id,
    p_org_id                 => p_org_id);

    if l_concurrent_count > 1 then
        wip_ws_util.log_for_duplicate_concurrent (
            p_org_id       => p_org_id,
            p_program_name => 'Parts Per Million Defects KPI');
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Errors encountered in calculation program, please check the log file.');
        return;
    end if;


      DELETE FROM wip_ws_ppm_defects
      WHERE organization_id = p_org_id;

      populate_ppm_defects_data(
        p_start_date => trunc(sysdate-g_ppmd_data_retention),
        p_org_id => p_org_id,
        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        wip_ws_util.trace_log('Unexpected error occured in populate_fpy_raw_data API');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        wip_ws_util.trace_log('Expected error occurred in populate_fpy_raw_data API');
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        wip_ws_util.trace_log('populate_fpy_raw_data is successful');
      END IF;

      IF (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.wip_ws_ppmdkpi_conc_prog',
                               p_procReturnStatus => l_return_status,
                               p_msg => 'processed successfully',
                               x_returnStatus => l_return_status);
      END IF;

  EXCEPTION


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  wip_ws_util.trace_log('Came to unexpected error in wip_ws_ppmdkpi_conc_prog');

                  IF (g_logLevel <= wip_constants.trace_logging) then
                    wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.wip_ws_ppmdkpi_conc_prog',
                                           p_procReturnStatus => 2,
                                           p_msg => 'unexpected error FND_API.G_EXC_UNEXPECTED_ERROR' || SQLERRM,
                                           x_returnStatus => l_return_status);
                  END IF;
                  ROLLBACK TO wip_ws_ppmdkpi_calc;
                  retcode := 2;  -- End with error
       WHEN FND_API.G_EXC_ERROR THEN
                  retcode := 1;
                  wip_ws_util.trace_log('Came to expected error in wip_ws_ppmdkpi_conc_prog');
                  IF (g_logLevel <= wip_constants.trace_logging) then
                    wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.wip_ws_ppmdkpi_conc_prog',
                                           p_procReturnStatus => 1,
                                           p_msg => 'unexpected error FND_API.G_EXC_ERROR' || SQLERRM,
                                           x_returnStatus => l_return_status);
                  END IF;

                  ROLLBACK TO wip_ws_ppmdkpi_calc;
       WHEN others THEN
                  wip_ws_util.trace_log('Came to others error in wip_ws_ppmdkpi_conc_prog');

                  IF (g_logLevel <= wip_constants.trace_logging) then
                    wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.wip_ws_ppmdkpi_conc_prog',
                                           p_procReturnStatus => 2,
                                           p_msg => 'unexpected error OTHERS' || SQLERRM,
                                           x_returnStatus => l_return_status);
                  END IF;
                  ROLLBACK TO wip_ws_ppmdkpi_calc;
                  retcode := 2;  -- End with error
  END wip_ws_ppmdkpi_conc_prog;

  PROCEDURE populate_ppm_defects_data(
              p_start_date DATE,
              p_org_id NUMBER,
              x_return_status OUT NOCOPY VARCHAR2) IS

    l_params wip_logger.param_tbl_t;
    l_return_status   VARCHAR2(1);

  BEGIN

    IF (g_logLevel <= wip_constants.trace_logging) THEN

      l_params(1).paramName := 'p_start_date';
      l_params(1).paramValue := p_start_date;
      l_params(2).paramName := 'p_org_id';
      l_params(2).paramValue := p_org_id;

      wip_logger.entryPoint(p_procName => 'wip_ws_embedded_analytics_pk.populate_ppm_defects_data',
                           p_params => l_params,
                           x_returnStatus => l_return_status);

      IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO wip_ws_ppm_defects(
      ORGANIZATION_ID,
      WIP_ENTITY_ID,
      INVENTORY_ITEM_ID,
      SHIFT_NUM,
      SHIFT_DATE,
      QUANTITY_DEFECTED,
      QUANTITY_PRODUCED,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE
    )
    select
      wdj.organization_id, -- ORGANIZATION_ID
      wdj.wip_entity_id, -- WIP_ENTITY_ID
      wdj.primary_item_id, -- INVENTORY_ITEM_ID
      WIP_WS_EMBEDDED_ANALYTICS_PK.get_shift_num(shift_info) shift_num, -- SHIFT_NUM
      WIP_WS_EMBEDDED_ANALYTICS_PK.get_shift_start_date(shift_info) shift_date, -- SHIFT_DATE
      wdj.quantity_scrapped, -- qty_defected
      wdj.quantity_completed + wdj.quantity_scrapped, -- qty_produced
      sysdate, --LAST_UPDATE_DATE,
      g_user_id, --LAST_UPDATED_BY,
      g_login_id, --LAST_UPDATE_LOGIN,
      sysdate, --CREATION_DATE,
      g_user_id, --CREATED_BY,
      g_request_id, --REQUEST_ID,
      g_prog_id, --PROGRAM_ID,
      g_prog_appid,--PROGRAM_APPLICATION_ID,
      sysdate --PROGRAM_UPDATE_DATE
    from
      (select
        WIP_WS_EMBEDDED_ANALYTICS_PK.get_shift_info_for_date(
          wdj1.organization_id, null, null,
          nvl(wdj1.date_completed, wdj1.date_closed)) shift_info,
        wdj1.*
      from wip_discrete_jobs wdj1
      where wdj1.date_completed > p_start_date
        and wdj1.organization_id = p_org_id
        and wdj1.status_type in (WIP_CONSTANTS.CLOSED, WIP_CONSTANTS.COMP_CHRG, WIP_CONSTANTS.COMP_NOCHRG)
        and wdj1.quantity_completed > 0) wdj;

    IF (g_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.populate_ppm_defects_data',
                             p_procReturnStatus => l_return_status,
                             p_msg => 'processed successfully',
                             x_returnStatus => l_return_status);
    END IF;

  EXCEPTION

    WHEN others THEN
      wip_ws_util.trace_log('Error in populate_ppm_defects_data');

      IF (g_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_ws_embedded_analytics_pk.populate_ppm_defects_data',
                               p_procReturnStatus => l_return_status,
                               p_msg => 'processed error' || SQLERRM,
                               x_returnStatus => l_return_status);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END populate_ppm_defects_data;

END wip_ws_embedded_analytics_pk;


/
