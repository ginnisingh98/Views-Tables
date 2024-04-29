--------------------------------------------------------
--  DDL for Package Body WIP_JOBCLOSE_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JOBCLOSE_PRIV" AS
/* $Header: wipjclpb.pls 120.17.12010000.9 2010/02/25 03:09:11 pding ship $ */

procedure populate_close_temp
(
      p_organization_id          IN    NUMBER   ,
      p_class_type               IN    VARCHAR2 ,
      p_from_class               IN    VARCHAR2 ,
      p_to_class                 IN    VARCHAR2 ,
      p_from_job                 IN    VARCHAR2 ,
      p_to_job                   IN    VARCHAR2 ,
      p_from_release_date        IN    DATE     ,
      p_to_release_date          IN    DATE     ,
      p_from_start_date          IN    DATE     ,
      p_to_start_date            IN    DATE     ,
      p_from_completion_date     IN    DATE     ,
      p_to_completion_date       IN    DATE     ,
      p_status                   IN    NUMBER   ,
      p_exclude_reserved_jobs    IN    VARCHAR2 ,
      p_exclude_pending_txn_jobs IN    VARCHAR2 ,
      p_report_type              IN    VARCHAR2 ,
      p_act_close_date           IN    DATE     ,
      x_group_id                 OUT   NOCOPY NUMBER ,
      x_ReturnStatus             OUT   NOCOPY VARCHAR2
)
IS

l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
l_number_temp NUMBER ;

BEGIN
x_returnStatus := fnd_api.g_ret_sts_success;
fnd_file.put_line(FND_FILE.LOG,'Populate Close Temp');

IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.populate_close_temp',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;

SELECT WIP_DJ_CLOSE_TEMP_S.nextval
  INTO x_group_id
  FROM DUAL ;

/*For bug 8808014(FP 8674750), the following insert statement will not insert
CMRO related Work Order into WDCT. A separate insert statement will
responsible to insert CMRO related Work Order into WDCT. Insert
statement for WDCT was split for performance reason*/
INSERT INTO WIP_DJ_CLOSE_TEMP
                ( wip_entity_id ,
                organization_id ,
                wip_entity_name ,
                primary_item_id ,
                status_type     ,
                group_id        ,
                actual_close_date )
    SELECT DJ.WIP_ENTITY_ID,
           DJ.ORGANIZATION_ID,
           WE.WIP_ENTITY_NAME,
           DJ.PRIMARY_ITEM_ID,
           DJ.STATUS_TYPE,
           x_group_id,
           p_act_close_date
     FROM ORG_ACCT_PERIODS AP,
          WIP_DISCRETE_JOBS DJ,
          WIP_ENTITIES WE
    WHERE DJ.ORGANIZATION_ID = p_organization_id
      AND WE.ORGANIZATION_ID = DJ.ORGANIZATION_ID
      AND AP.ORGANIZATION_ID = DJ.ORGANIZATION_ID
      AND AP.OPEN_FLAG = 'Y'
      AND WE.WIP_ENTITY_ID = DJ.WIP_ENTITY_ID
      AND NOT EXISTS
               (SELECT 'X'
                  FROM WIP_DJ_CLOSE_TEMP WDCT
                  WHERE WDCT.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
      AND DJ.STATUS_TYPE IN
      --      (1,3,4,5,6,7,9,11,15)
              (WIP_CONSTANTS.UNRELEASED,
               WIP_CONSTANTS.RELEASED,
               WIP_CONSTANTS.COMP_CHRG,
               WIP_CONSTANTS.COMP_NOCHRG ,
               WIP_CONSTANTS.HOLD ,
               WIP_CONSTANTS.CANCELLED ,
               WIP_CONSTANTS.FAIL_BOM,
               WIP_CONSTANTS.FAIL_ROUT,
               WIP_CONSTANTS.FAIL_CLOSE
              )
      AND ( p_class_type IS NULL OR
            DJ.CLASS_CODE IN  ( SELECT CLASS_CODE
                                  FROM WIP_ACCOUNTING_CLASSES
                                 WHERE  CLASS_TYPE = p_class_type
                                   AND ORGANIZATION_ID = p_organization_id ))
      AND ( p_from_class IS NULL OR DJ.CLASS_CODE >= p_from_class )
      AND ( p_to_class   IS NULL OR DJ.CLASS_CODE <= p_to_class   )
      AND ( p_from_job   IS NULL OR WE.WIP_ENTITY_NAME >= p_from_job )
      AND ( p_to_job     IS NULL OR WE.WIP_ENTITY_NAME <= p_to_job )
      AND ( p_from_start_date IS NULL OR
	    DJ.SCHEDULED_START_DATE >= p_from_start_date )
      AND ( p_to_start_date IS NULL OR
	    DJ.SCHEDULED_START_DATE <= p_to_start_date )
      AND ( p_from_completion_date IS NULL OR
	    DJ.DATE_COMPLETED >= p_from_completion_date )
      AND ( p_to_completion_date IS NULL OR
	    DJ.DATE_COMPLETED <= p_to_completion_date )
      AND ( p_from_release_date    IS NULL OR
	    DJ.DATE_RELEASED >= p_from_release_date )
      AND ( p_to_release_date IS NULL OR
	    DJ.DATE_RELEASED <= p_to_release_date )
      AND ( p_status IS NULL  OR DJ.STATUS_TYPE = p_status)
     -- AND ( DJ.DATE_RELEASED <= p_act_close_date) /* Bug 5007538 */
      AND ( p_exclude_reserved_jobs <> '1' OR NOT EXISTS
               (SELECT 'X'FROM WIP_RESERVATIONS_V WRV
                 WHERE WRV.WIP_ENTITY_ID = WE.WIP_ENTITY_ID ))
      AND ( p_exclude_pending_txn_jobs <> '1' OR ( NOT EXISTS
               (SELECT 'X' FROM WIP_MOVE_TXN_INTERFACE WMTI
                 WHERE WMTI.ORGANIZATION_ID = p_organization_id
                   AND WMTI.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
                   AND NOT EXISTS
                       (SELECT 'X'
                          FROM WIP_COST_TXN_INTERFACE WCTI
                         WHERE WCTI.ORGANIZATION_ID = p_organization_id
                           AND WCTI.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
                   AND NOT EXISTS
                       (SELECT 'X'
                          FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                         WHERE ORGANIZATION_ID = p_organization_id
                           AND MMTT.TRANSACTION_SOURCE_TYPE_ID = 5
                           AND MMTT.TRANSACTION_SOURCE_ID = WE.WIP_ENTITY_ID)
		   AND NOT EXISTS
   			   (SELECT /*+ index(mmt MTL_MATERIAL_TRANSACTIONS_n2) */ 'X'
         	          FROM MTL_MATERIAL_TRANSACTIONS MMT
		         WHERE MMT.COSTED_FLAG IN ('N','E')
  		           AND MMT.TRANSACTION_SOURCE_TYPE_ID = 5
		           AND MMT.ORGANIZATION_ID = p_organization_id
  		           AND MMT.TRANSACTION_SOURCE_ID = WE.WIP_ENTITY_ID)
		   AND NOT EXISTS
			   (SELECT 'X'
      		          FROM WIP_OPERATION_YIELDS WOY
                  		 WHERE WOY.ORGANIZATION_ID = p_organization_id
		           AND WOY.STATUS IN (1, 3)
  		           AND WOY.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
 		   AND (WE.ENTITY_TYPE <> 5  OR
		       (WE.ENTITY_TYPE = 5   AND NOT EXISTS
		       (SELECT 'X'
          	          FROM  wsm_sm_starting_jobs sj,
                                wsm_split_merge_transactions wmt
		         WHERE sj.wip_entity_id = we.wip_entity_id
			   AND sj.transaction_id = wmt.transaction_id
           	  	   AND (wmt.status <> 4 or nvl(wmt.costed,1) <> 4))))
 		   AND (WE.ENTITY_TYPE <> 5 OR
 		       (WE.ENTITY_TYPE = 5  AND NOT EXISTS
		       (SELECT 'X'
             		  FROM  wsm_sm_resulting_jobs rj,
                             	wsm_split_merge_transactions wmt
			 WHERE rj.wip_entity_id = we.wip_entity_id
                 	   AND rj.transaction_id = wmt.transaction_id
                 	   AND (wmt.status <> 4 or nvl(wmt.costed,1) <> 4))))))
       /*for bug 8808014(FP 8674750), exclude CMRO work order*/
       AND NOT (WE.ENTITY_TYPE = 6 AND DJ.MAINTENANCE_OBJECT_SOURCE = 2)
 GROUP BY DJ.WIP_ENTITY_ID, DJ.ORGANIZATION_ID, WE.WIP_ENTITY_NAME,
          DJ.PRIMARY_ITEM_ID, DJ.STATUS_TYPE ;

/*For bug 8808014(FP 8674750), the following insert statement will populate WDCT
with CMRO related Work Order and undergo CMRO validation before closing
CMRO Work Order*/
INSERT INTO WIP_DJ_CLOSE_TEMP
                ( wip_entity_id ,
                organization_id ,
                wip_entity_name ,
                primary_item_id ,
                status_type     ,
                group_id        ,
                actual_close_date )
    SELECT DJ.WIP_ENTITY_ID,
           DJ.ORGANIZATION_ID,
           WE.WIP_ENTITY_NAME,
           DJ.PRIMARY_ITEM_ID,
           DJ.STATUS_TYPE,
           x_group_id,
           p_act_close_date
     FROM ORG_ACCT_PERIODS AP,
          WIP_DISCRETE_JOBS DJ,
          WIP_ENTITIES WE
    WHERE DJ.ORGANIZATION_ID = p_organization_id
      AND WE.ORGANIZATION_ID = DJ.ORGANIZATION_ID
      AND AP.ORGANIZATION_ID = DJ.ORGANIZATION_ID
      AND AP.OPEN_FLAG = 'Y'
      AND WE.WIP_ENTITY_ID = DJ.WIP_ENTITY_ID
      AND NOT EXISTS
               (SELECT 'X'
                  FROM WIP_DJ_CLOSE_TEMP WDCT
                  WHERE WDCT.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
      AND DJ.STATUS_TYPE IN
      --      (1,3,4,5,6,7,9,11,15)
              (WIP_CONSTANTS.UNRELEASED,
               WIP_CONSTANTS.RELEASED,
               WIP_CONSTANTS.COMP_CHRG,
               WIP_CONSTANTS.COMP_NOCHRG ,
               WIP_CONSTANTS.HOLD ,
               WIP_CONSTANTS.CANCELLED ,
               WIP_CONSTANTS.FAIL_BOM,
               WIP_CONSTANTS.FAIL_ROUT,
               WIP_CONSTANTS.FAIL_CLOSE
              )
      AND ( p_class_type IS NULL OR
            DJ.CLASS_CODE IN  ( SELECT CLASS_CODE
                                  FROM WIP_ACCOUNTING_CLASSES
                                 WHERE  CLASS_TYPE = p_class_type
                                   AND ORGANIZATION_ID = p_organization_id ))
      AND ( p_from_class IS NULL OR DJ.CLASS_CODE >= p_from_class )
      AND ( p_to_class   IS NULL OR DJ.CLASS_CODE <= p_to_class   )
      AND ( p_from_job   IS NULL OR WE.WIP_ENTITY_NAME >= p_from_job )
      AND ( p_to_job     IS NULL OR WE.WIP_ENTITY_NAME <= p_to_job )
      AND ( p_from_start_date IS NULL OR
	    DJ.SCHEDULED_START_DATE >= p_from_start_date )
      AND ( p_to_start_date IS NULL OR
	    DJ.SCHEDULED_START_DATE <= p_to_start_date )
      AND ( p_from_completion_date IS NULL OR
	    DJ.DATE_COMPLETED >= p_from_completion_date )
      AND ( p_to_completion_date IS NULL OR
	    DJ.DATE_COMPLETED <= p_to_completion_date )
      AND ( p_from_release_date    IS NULL OR
	    DJ.DATE_RELEASED >= p_from_release_date )
      AND ( p_to_release_date IS NULL OR
	    DJ.DATE_RELEASED <= p_to_release_date )
      AND ( p_status IS NULL  OR DJ.STATUS_TYPE = p_status)
     -- AND ( DJ.DATE_RELEASED <= p_act_close_date) /* Bug 5007538 */
      AND ( p_exclude_reserved_jobs <> '1' OR NOT EXISTS
               (SELECT 'X'FROM WIP_RESERVATIONS_V WRV
                 WHERE WRV.WIP_ENTITY_ID = WE.WIP_ENTITY_ID ))
      AND ( p_exclude_pending_txn_jobs <> '1' OR ( NOT EXISTS
               (SELECT 'X' FROM WIP_MOVE_TXN_INTERFACE WMTI
                 WHERE WMTI.ORGANIZATION_ID = p_organization_id
                   AND WMTI.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
                   AND NOT EXISTS
                       (SELECT 'X'
                          FROM WIP_COST_TXN_INTERFACE WCTI
                         WHERE WCTI.ORGANIZATION_ID = p_organization_id
                           AND WCTI.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
                   AND NOT EXISTS
                       (SELECT 'X'
                          FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                         WHERE ORGANIZATION_ID = p_organization_id
                           AND MMTT.TRANSACTION_SOURCE_TYPE_ID = 5
                           AND MMTT.TRANSACTION_SOURCE_ID = WE.WIP_ENTITY_ID)
		   AND NOT EXISTS
   			   (SELECT /*+ index(mmt MTL_MATERIAL_TRANSACTIONS_n2) */ 'X'
         	          FROM MTL_MATERIAL_TRANSACTIONS MMT
		         WHERE MMT.COSTED_FLAG IN ('N','E')
  		           AND MMT.TRANSACTION_SOURCE_TYPE_ID = 5
		           AND MMT.ORGANIZATION_ID = p_organization_id
  		           AND MMT.TRANSACTION_SOURCE_ID = WE.WIP_ENTITY_ID)
		   AND NOT EXISTS
			   (SELECT 'X'
      		          FROM WIP_OPERATION_YIELDS WOY
                  		 WHERE WOY.ORGANIZATION_ID = p_organization_id
		           AND WOY.STATUS IN (1, 3)
  		           AND WOY.WIP_ENTITY_ID = WE.WIP_ENTITY_ID)
 		   AND (WE.ENTITY_TYPE <> 5  OR
		       (WE.ENTITY_TYPE = 5   AND NOT EXISTS
		       (SELECT 'X'
          	          FROM  wsm_sm_starting_jobs sj,
                                wsm_split_merge_transactions wmt
		         WHERE sj.wip_entity_id = we.wip_entity_id
			   AND sj.transaction_id = wmt.transaction_id
           	  	   AND (wmt.status <> 4 or nvl(wmt.costed,1) <> 4))))
 		   AND (WE.ENTITY_TYPE <> 5 OR
 		       (WE.ENTITY_TYPE = 5  AND NOT EXISTS
		       (SELECT 'X'
             		  FROM  wsm_sm_resulting_jobs rj,
                             	wsm_split_merge_transactions wmt
			 WHERE rj.wip_entity_id = we.wip_entity_id
                 	   AND rj.transaction_id = wmt.transaction_id
                 	   AND (wmt.status <> 4 or nvl(wmt.costed,1) <> 4))))))
       /*Fix for 8808014(FP 8674750), added validation for CMRO, check whether the CMRO
       item is in location_type_code = WIP*/
       AND (WE.ENTITY_TYPE = 6 AND DJ.MAINTENANCE_OBJECT_SOURCE = 2 AND NOT EXISTS
            (SELECT 'x'
            FROM CSI_ITEM_INSTANCES CII
            WHERE CII.WIP_JOB_ID = WE.WIP_ENTITY_ID
            AND CII.ACTIVE_START_DATE <= SYSDATE
            AND ((CII.ACTIVE_END_DATE IS NULL) OR (CII.ACTIVE_END_DATE >= SYSDATE))
            AND CII.LOCATION_TYPE_CODE = 'WIP'
            AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
		        WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
		        AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
		        AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE,SYSDATE) AND NVL(ACTIVE_END_DATE,SYSDATE))))
 GROUP BY DJ.WIP_ENTITY_ID, DJ.ORGANIZATION_ID, WE.WIP_ENTITY_NAME,
          DJ.PRIMARY_ITEM_ID, DJ.STATUS_TYPE ;

SELECT count(*)
  INTO l_number_temp
  FROM WIP_DJ_CLOSE_TEMP
 WHERE group_id = x_group_id  ;

fnd_file.put_line(FND_FILE.LOG,'Records inserted in close temp '||to_char(l_number_temp));

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.populate_close_temp',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

 /* Handling Exceptions */

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_close_priv.populate_close_temp',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;

END populate_close_temp ;

procedure TIME_ZONE_CONVERSIONS
(
      p_from_release_date   IN  VARCHAR2  ,
      p_to_release_date     IN  VARCHAR2  ,
      p_from_start_date     IN  VARCHAR2  ,
      p_to_start_date       IN  VARCHAR2  ,
      p_from_completion_date IN VARCHAR2  ,
      p_to_completion_date  IN  VARCHAR2  ,
      p_act_close_date      IN  VARCHAR2  ,
      x_from_release_date   OUT NOCOPY DATE ,
      x_to_release_date     OUT NOCOPY DATE ,
      x_from_start_date     OUT NOCOPY DATE ,
      x_to_start_date       OUT NOCOPY DATE ,
      x_from_completion_date OUT NOCOPY DATE ,
      x_to_completion_date   OUT NOCOPY DATE ,
      x_act_close_date      OUT NOCOPY DATE ,
      x_returnstatus       OUT NOCOPY VARCHAR2
)IS
  l_params       wip_logger.param_tbl_t;
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
  l_return_status         VARCHAR2(1) ;
  l_msg_count             NUMBER ;
  l_msg_data              VARCHAR2(200);
  l_msg                   VARCHAR(240);
BEGIN
IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_from_release_date';
    l_params(1).paramValue  :=  p_from_release_date ;
    l_params(2).paramName   := 'p_to_release_date';
    l_params(2).paramValue  :=  p_to_release_date ;
    l_params(3).paramName   := 'p_from_start_date';
    l_params(3).paramValue  :=  p_from_start_date ;
    l_params(4).paramName   := 'p_to_start_date';
    l_params(4).paramValue  :=  p_to_start_date ;
    l_params(5).paramName   := 'p_from_completion_date';
    l_params(5).paramValue  :=  p_from_completion_date ;
    l_params(6).paramName   := 'p_to_completion_date';
    l_params(6).paramValue  :=  p_to_completion_date ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.time_zone_conversion',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;
x_ReturnStatus  := fnd_api.g_ret_sts_success ;
fnd_file.put_line(FND_FILE.LOG,'Time Zone Conversions');

IF(fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y') THEN

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_from_start_date) ,
  x_dest_day_time   => x_from_start_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_to_start_date) ,
  x_dest_day_time   => x_to_start_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_from_release_date) ,
  x_dest_day_time   => x_from_release_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_to_release_date) ,
  x_dest_day_time   => x_to_release_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_from_completion_date) ,
  x_dest_day_time   => x_from_completion_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_to_completion_date) ,
  x_dest_day_time   => x_to_completion_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

  HZ_TIMEZONE_PUB.Get_Time(
  p_api_version     => 1.0,
  p_init_msg_list   => 'F',
  p_source_tz_id => to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID')),
  p_dest_tz_id   => to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID')),
  p_source_day_time => fnd_date.canonical_to_date(p_act_close_date) ,
  x_dest_day_time   => x_act_close_date ,
  x_return_status   => l_return_status,
  x_msg_count       => l_msg_count,
  x_msg_data        => l_msg_data);

ELSE

  x_from_release_date     := fnd_date.canonical_to_date(p_from_release_date);
  x_to_release_date       := fnd_date.canonical_to_date(p_to_release_date);
  x_from_start_date       := fnd_date.canonical_to_date(p_from_start_date);
  x_to_start_date         := fnd_date.canonical_to_date(p_to_start_date);
  x_from_completion_date  := fnd_date.canonical_to_date(p_from_completion_date);
  x_to_completion_date    := fnd_date.canonical_to_date(p_to_completion_date);
  x_act_close_date        := fnd_date.canonical_to_date(p_act_close_date);


END IF;

fnd_file.put_line(FND_FILE.LOG,'x_from_release_date : '||to_char(x_from_release_date));
fnd_file.put_line(FND_FILE.LOG,'x_to_release_date : '||to_char(x_to_release_date));
fnd_file.put_line(FND_FILE.LOG,'x_from_start_date : '||to_char(x_from_start_date));
fnd_file.put_line(FND_FILE.LOG,'x_to_start_date : '||to_char(x_to_start_date));
fnd_file.put_line(FND_FILE.LOG,'x_from_completion_date : '||to_char(x_from_completion_date));
fnd_file.put_line(FND_FILE.LOG,'x_to_completion_date : '||to_char(x_to_completion_date));
fnd_file.put_line(FND_FILE.LOG,'x_act_close_date : '||to_char(x_act_close_date));

IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
   wip_logger.exitPoint(
            p_procName => 'wip_close_priv.time_zone_conversions',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
END IF;
EXCEPTION
   WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName=>'wip_close_priv.time_zone_conversions',
            p_procReturnStatus => x_returnStatus,
            p_msg => l_msg,
            x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;

END TIME_ZONE_CONVERSIONS;

procedure PRIOR_DATE_RELEASE
(
      x_returnstatus        OUT  NOCOPY VARCHAR2,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS

--
-- Bug 5148397
--
    l_params         wip_logger.param_tbl_t;
    l_return_status  VARCHAR2(1);
    l_msg            VARCHAR(2000);
    l_failed_counter NUMBER;
    l_failed_ids     dbms_sql.number_table;

BEGIN

    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        l_params(1).paramName   := 'p_organization_id';
        l_params(1).paramValue  :=  p_organization_id;
        l_params(2).paramName   := 'p_group_id';
        l_params(2).paramValue  :=  p_group_id;
        wip_logger.entryPoint(
            p_procName => 'wip_jobclose_priv.prior_date_release',
            p_params => l_params,
            x_returnStatus => l_return_status);
    END IF;

    --
    -- The most efficient algorithm is to start deleting all
    -- invalid records from wip_dj_close_temp collecting the
    -- wip_entity_ids at the same time.  Then use BULK op
    -- to update wip_discrete_jobs' status for those records.
    -- bso Sat Jun 17 17:18:45 PDT 2006
    --

    DELETE FROM wip_dj_close_temp wdct
    WHERE  wdct.organization_id = p_organization_id AND
           wdct.group_id = p_group_id AND
           wdct.actual_close_date <
           (SELECT wdj.date_released
            FROM   wip_discrete_jobs wdj
            WHERE  wdj.wip_entity_id = wdct.wip_entity_id AND
                   wdj.organization_id = p_organization_id)
    RETURNING wdct.wip_entity_id
    BULK COLLECT INTO l_failed_ids;

    l_failed_counter := l_failed_ids.COUNT;

fnd_file.put_line(FND_FILE.LOG,'Number of jobs failed because release date before close date : '|| to_char(l_failed_counter));

    IF l_failed_counter = 0 THEN
        x_returnstatus := FND_API.G_RET_STS_SUCCESS;
    ELSE
        --
        -- Some invalid jobs found.  Set expected error flag and
        -- update wip_discrete_jobs' status_type to fail_close.
        --
        x_returnstatus := FND_API.G_RET_STS_ERROR;

        FORALL i IN l_failed_ids.FIRST .. l_failed_ids.LAST
            UPDATE wip_discrete_jobs
            SET    status_type = WIP_CONSTANTS.FAIL_CLOSE
            WHERE  organization_id = p_organization_id AND
                   wip_entity_id = l_failed_ids(i);

        l_failed_ids.DELETE;
    END IF;

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.prior_date_release',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
   WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName=>'wip_close_priv.prior_date_release',
            p_procReturnStatus => x_returnStatus,
            p_msg => l_msg,
            x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;

END PRIOR_DATE_RELEASE;


procedure PENDING_TXNS
(
      x_Returnstatus        OUT   NOCOPY  VARCHAR2 ,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS
l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

CURSOR c_pending_txns IS
SELECT WIP_ENTITY_NAME
  FROM WIP_DJ_CLOSE_TEMP
 WHERE GROUP_ID = p_group_id
   AND ORGANIZATION_ID = p_organization_id
   AND WIP_ENTITY_ID IN
          (SELECT WIP_ENTITY_ID
             FROM WIP_MOVE_TXN_INTERFACE
            WHERE ORGANIZATION_ID = p_organization_id
         UNION ALL
           SELECT WIP_ENTITY_ID
             FROM WIP_COST_TXN_INTERFACE
            WHERE ORGANIZATION_ID = p_organization_id
         UNION ALL
            SELECT TRANSACTION_SOURCE_ID
              FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
             WHERE ORGANIZATION_ID = p_organization_id
               AND TRANSACTION_SOURCE_TYPE_ID = 5
               AND TRANSACTION_SOURCE_ID NOT IN
                  (SELECT TXN_SOURCE_ID
                     FROM MTL_TXN_REQUEST_LINES
                    WHERE TXN_SOURCE_ID = MMTT.TRANSACTION_SOURCE_ID
                      AND ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                      AND LINE_STATUS = 9)
          UNION ALL
             SELECT TRANSACTION_SOURCE_ID
               FROM MTL_MATERIAL_TRANSACTIONS
              WHERE COSTED_FLAG IN ('N','E')
                AND TRANSACTION_SOURCE_TYPE_ID = 5
                AND ORGANIZATION_ID = p_organization_id
          UNION ALL
              SELECT DISTINCT WIP_ENTITY_ID
               FROM WIP_OPERATION_YIELDS
              WHERE ORGANIZATION_ID = p_organization_id
                AND   STATUS IN (1, 3)
	  UNION ALL
	   SELECT WLC.WIP_ENTITY_ID
                FROM WIP_LPN_COMPLETIONS WLC,
                     WMS_LICENSE_PLATE_NUMBERS LPN  ,
                     MTL_TXN_REQUEST_LINES MTRL
               WHERE WLC.ORGANIZATION_ID = p_organization_id
                 AND WLC.LPN_ID = LPN.LPN_ID
                 AND MTRL.LPN_ID = LPN.LPN_ID
                 AND MTRL.txn_source_id = WLC.wip_entity_id
                 AND MTRL.line_status = 7       /*Bugfix 6455522 added one condition for mtrl.line_status=7*/
                 AND LPN.LPN_CONTEXT = 2);

l_failed_jobs WIP_DJ_CLOSE_TEMP.WIP_ENTITY_NAME%TYPE ;
l_failed_counter NUMBER ;
BEGIN

IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.pending_txns',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;
x_returnStatus := fnd_api.g_ret_sts_success;
l_failed_counter := 0 ;
fnd_file.put_line(FND_FILE.LOG,'Pending Txns Check');

OPEN c_pending_txns ;
LOOP
  FETCH c_pending_txns INTO l_failed_jobs ;
    if (c_pending_txns%FOUND) then
      l_failed_counter := l_failed_counter + 1 ;
      x_returnStatus   := FND_API.G_RET_STS_ERROR  ;
      fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_failed_jobs));
    end if ;

  UPDATE  WIP_DJ_CLOSE_TEMP
     SET  STATUS_TYPE = 99
   WHERE  WIP_ENTITY_NAME = l_failed_jobs ;

  EXIT WHEN c_pending_txns%NOTFOUND ;
END LOOP ;

UPDATE WIP_DISCRETE_JOBS
   SET STATUS_TYPE = WIP_CONSTANTS.FAIL_CLOSE
 WHERE WIP_ENTITY_ID IN
            (SELECT WIP_ENTITY_ID
               FROM WIP_DJ_CLOSE_TEMP
              WHERE GROUP_ID = p_group_id
                AND ORGANIZATION_ID = p_organization_id
                AND STATUS_TYPE = 99);

DELETE FROM WIP_DJ_CLOSE_TEMP
 WHERE GROUP_ID = p_group_id
   AND ORGANIZATION_ID = p_organization_id
   AND STATUS_TYPE = 99;

fnd_file.put_line(FND_FILE.LOG,'Number of jobs failed due to Pending txns : '|| to_char(l_failed_counter));

IF (c_pending_txns%ISOPEN) THEN
   CLOSE c_pending_txns ;
END IF;

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.pending_txns',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
   WHEN others THEN
    IF (c_pending_txns%ISOPEN) THEN
       CLOSE c_pending_txns ;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_close_priv.pending_txns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;
END PENDING_TXNS ;


procedure CLOSE_JOB_EXCEPTIONS
(
      x_returnstatus        OUT  NOCOPY VARCHAR2,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS
        cursor c_jobs is
          select wdct.wip_entity_id,
                 we.organization_id
            from wip_dj_close_temp wdct,
                 wip_entities we
           where we.wip_entity_id = wdct.wip_entity_id
             and we.organization_id = wdct.organization_id
             and wdct.group_id = p_group_id
             and wdct.organization_id = p_organization_id;

l_ret_status VARCHAR2(30);
l_msg_data VARCHAR2(2000);
l_ret_exp_status boolean := true;

BEGIN
   x_returnstatus := FND_API.G_RET_STS_SUCCESS;

  for l_jobRec in c_jobs loop
          l_ret_exp_status :=
            wip_ws_exceptions.close_exception_job
               (p_wip_entity_id => l_jobRec.wip_entity_id,
                p_organization_id => l_jobRec.organization_id);

    IF (l_ret_exp_status = false) then
      UPDATE  WIP_DJ_CLOSE_TEMP
         SET  STATUS_TYPE = 99
       WHERE  WIP_ENTITY_ID = l_jobRec.wip_entity_id;

      x_returnstatus := FND_API.G_RET_STS_ERROR;
    END IF;
  end loop;

END CLOSE_JOB_EXCEPTIONS ;


procedure PENDING_CLOCKS
(
      x_returnstatus        OUT  NOCOPY VARCHAR2,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS
        cursor c_jobs is
          select wdct.wip_entity_id,
                 we.wip_entity_name
            from wip_dj_close_temp wdct,
                 wip_entities we
           where we.wip_entity_id = wdct.wip_entity_id
             and we.organization_id = wdct.organization_id
             and wdct.group_id = p_group_id
             and wdct.organization_id = p_organization_id;

l_ret_status VARCHAR2(30);
l_msg_data VARCHAR2(2000);
l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
l_failed_counter NUMBER ;
BEGIN
IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.pending_clocks',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;
x_returnstatus := FND_API.G_RET_STS_SUCCESS;
l_failed_counter := 0;

for l_jobRec in c_jobs loop
         l_ret_status :=
            WIP_WS_TIME_ENTRY.is_clock_pending
               (p_wip_entity_id => l_jobRec.wip_entity_id,
                p_operation_seq_num => NULL);

    IF (l_ret_status <> 'N') then
      UPDATE  WIP_DJ_CLOSE_TEMP
         SET  STATUS_TYPE = 99
       WHERE  WIP_ENTITY_ID = l_jobRec.wip_entity_id;
       l_failed_counter := l_failed_counter + 1 ;
       fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_jobRec.wip_entity_name));
       x_returnstatus := FND_API.G_RET_STS_ERROR;
    END IF;
  end loop;

  UPDATE WIP_DISCRETE_JOBS
   SET STATUS_TYPE = WIP_CONSTANTS.FAIL_CLOSE
 WHERE WIP_ENTITY_ID IN
            (SELECT WIP_ENTITY_ID
               FROM WIP_DJ_CLOSE_TEMP
              WHERE GROUP_ID = p_group_id
                AND ORGANIZATION_ID = p_organization_id
                AND STATUS_TYPE = 99);

DELETE FROM WIP_DJ_CLOSE_TEMP
 WHERE GROUP_ID = p_group_id
   AND ORGANIZATION_ID = p_organization_id
   AND STATUS_TYPE = 99;

fnd_file.put_line(FND_FILE.LOG,'Number of jobs failed due to Pending Clocks : '|| to_char(l_failed_counter));

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.pending_clocks',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
   WHEN others THEN
    IF (c_jobs%ISOPEN) THEN
       CLOSE c_jobs ;
    END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_close_priv.pending_clocks',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;

END PENDING_CLOCKS ;

procedure CANCEL_MOVE_ORDERS
(
      x_returnstatus        OUT  NOCOPY VARCHAR2,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS
        cursor c_jobs is
          select wdct.wip_entity_id,
                 we.entity_type,
		 we.wip_entity_name
            from wip_dj_close_temp wdct,
                 wip_entities we
           where we.wip_entity_id = wdct.wip_entity_id
             and we.organization_id = wdct.organization_id
             and wdct.group_id = p_group_id
             and wdct.organization_id = p_organization_id;

l_ret_status VARCHAR2(30);
l_msg_data VARCHAR2(2000);
l_failed_counter NUMBER ;
BEGIN
  l_failed_counter := 0 ;
  fnd_file.put_line(FND_FILE.LOG,'Cancelling Move Orders if any exists ');
  for l_jobRec in c_jobs loop
          wip_picking_pvt.cancel_allocations
           (p_wip_entity_id => l_jobRec.wip_entity_id,
            p_wip_entity_type => l_jobRec.entity_type,
            x_return_status => l_ret_status,
            x_msg_data => l_msg_data);
    fnd_file.put_line(FND_FILE.LOG,'return status '||l_ret_status);
    IF (l_ret_status <>  FND_API.G_RET_STS_SUCCESS ) then
      UPDATE  WIP_DJ_CLOSE_TEMP
         SET  STATUS_TYPE = 99
       WHERE  WIP_ENTITY_ID = l_jobRec.wip_entity_id;
       l_failed_counter := l_failed_counter + 1 ;
       fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_jobRec.wip_entity_name));
       x_returnstatus := FND_API.G_RET_STS_ERROR;
    END IF;
  end loop;

UPDATE WIP_DISCRETE_JOBS
   SET STATUS_TYPE = WIP_CONSTANTS.FAIL_CLOSE
 WHERE WIP_ENTITY_ID IN
            (SELECT WIP_ENTITY_ID
               FROM WIP_DJ_CLOSE_TEMP
              WHERE GROUP_ID = p_group_id
                AND ORGANIZATION_ID = p_organization_id
                AND STATUS_TYPE = 99);

DELETE FROM WIP_DJ_CLOSE_TEMP
 WHERE GROUP_ID = p_group_id
   AND ORGANIZATION_ID = p_organization_id
   AND STATUS_TYPE = 99;

END CANCEL_MOVE_ORDERS ;

procedure CANCEL_PO
(
      x_returnstatus        OUT  NOCOPY VARCHAR2,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS
        cursor c_jobs is
          select wdct.wip_entity_id,
                 we.entity_type
            from wip_dj_close_temp wdct,
                 wip_entities we
           where we.wip_entity_id = wdct.wip_entity_id
             and we.organization_id = wdct.organization_id
             and wdct.group_id = p_group_id
             and wdct.organization_id = p_organization_id;

        l_ret_status VARCHAR2(30);
        l_msg_data VARCHAR2(2000);
        l_propagate_job_change_to_po NUMBER;
BEGIN
  fnd_file.put_line(FND_FILE.LOG,'Cancel PO');

        select propagate_job_change_to_po
          into l_propagate_job_change_to_po
          from wip_parameters
         where organization_id = p_organization_id;

        for l_jobRec in c_jobs loop
          -- add code to cancel PO/requisitions if exists and applicable
          IF(po_code_release_grp.Current_Release >=
             po_code_release_grp.PRC_11i_Family_Pack_J AND
             l_propagate_job_change_to_po = WIP_CONSTANTS.YES) THEN
            -- try to cancel all PO/requisitions associated to the jobs.
            wip_osp.cancelPOReq(p_job_id        => l_jobRec.wip_entity_id,
                                p_org_id        => p_organization_id,
				 p_clr_fnd_mes_flag => 'Y',
                                x_return_status => l_ret_status);
	  -- added parameter p_clr_fnd_mes_flag for bugfix 7415801.


          END IF;
        end loop;

END CANCEL_PO ;


procedure PAST_CLOSE_DATE
(
      x_returnstatus        OUT  NOCOPY VARCHAR2,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER

)
IS

l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

  CURSOR c_pending_txns IS
  SELECT WIP_ENTITY_NAME
    FROM WIP_DJ_CLOSE_TEMP
   WHERE WIP_ENTITY_ID IN
      (SELECT wdct.WIP_ENTITY_ID
                FROM WIP_TRANSACTIONS wt,
                     WIP_DJ_CLOSE_TEMP wdct
                WHERE wdct.GROUP_ID = p_group_id
                AND wdct.ORGANIZATION_ID = p_organization_id
                AND wdct.WIP_ENTITY_ID = wt.WIP_ENTITY_ID
                AND wt.ORGANIZATION_ID = p_organization_id
                AND wt.TRANSACTION_DATE > wdct.ACTUAL_CLOSE_DATE
       UNION
       SELECT wdct.WIP_ENTITY_ID
                FROM MTL_MATERIAL_TRANSACTIONS mmt,
                     WIP_DJ_CLOSE_TEMP wdct
                WHERE wdct.GROUP_ID = p_group_id
                AND wdct.ORGANIZATION_ID = p_organization_id
                AND wdct.WIP_ENTITY_ID = mmt.TRANSACTION_SOURCE_ID
                AND mmt.TRANSACTION_SOURCE_TYPE_ID = 5
                AND mmt.ORGANIZATION_ID = p_organization_id
                AND mmt.TRANSACTION_DATE > wdct.ACTUAL_CLOSE_DATE) ;
  l_failed_jobs WIP_DJ_CLOSE_TEMP.WIP_ENTITY_NAME%TYPE ;
  l_failed_counter NUMBER ;
BEGIN
fnd_file.put_line(FND_FILE.LOG,'Inside Procedure Close Date ');
x_returnStatus := fnd_api.g_ret_sts_success;
l_failed_counter := 0 ;

IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.past_close_date',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;

  OPEN c_pending_txns ;
  LOOP
  FETCH c_pending_txns INTO l_failed_jobs ;
  if (c_pending_txns%FOUND) then
  fnd_file.put_line(FND_FILE.LOG,'Close date precedes the txn date for job '||l_failed_jobs);
  l_failed_counter := l_failed_counter + 1 ;
  x_returnstatus := FND_API.G_RET_STS_ERROR ;
  fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_failed_jobs));
  end if ;

  UPDATE  WIP_DJ_CLOSE_TEMP
     SET STATUS_TYPE = 99
   WHERE  WIP_ENTITY_NAME = l_failed_jobs ;

  EXIT WHEN c_pending_txns%NOTFOUND ;
  END LOOP ;
  fnd_file.put_line(FND_FILE.LOG,'Number of failed jobs because of past close date : '||l_failed_counter);

  UPDATE WIP_DISCRETE_JOBS
     SET STATUS_TYPE = WIP_CONSTANTS.FAIL_CLOSE
   WHERE WIP_ENTITY_ID IN
            (SELECT WIP_ENTITY_ID
               FROM WIP_DJ_CLOSE_TEMP
              WHERE GROUP_ID = p_group_id
                AND ORGANIZATION_ID = p_organization_id
                AND STATUS_TYPE = 99);

  DELETE FROM WIP_DJ_CLOSE_TEMP
   WHERE GROUP_ID = p_group_id
     AND ORGANIZATION_ID = p_organization_id
     AND STATUS_TYPE = 99;


  IF (c_pending_txns%ISOPEN) THEN
   CLOSE c_pending_txns ;
  END IF;

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.past_close_date',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

 EXCEPTION
  WHEN others THEN
  IF (c_pending_txns%ISOPEN) THEN
   CLOSE c_pending_txns ;
  END IF;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_close_priv.past_close_date',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;
END PAST_CLOSE_DATE ;

procedure CHECK_OPEN_PO
(
      x_returnstatus        OUT   NOCOPY VARCHAR2 ,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS

l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

CURSOR c_open_po IS
  SELECT WIP_ENTITY_NAME
    FROM WIP_DJ_CLOSE_TEMP WDCT
   WHERE  wdct.GROUP_ID = p_group_id
     AND wdct.ORGANIZATION_ID = p_organization_id
     AND EXISTS
       (SELECT '1'
          FROM PO_RELEASES_ALL PR,
               PO_HEADERS_ALL PH,
               PO_DISTRIBUTIONS_ALL PD,
               PO_LINE_LOCATIONS_ALL PL
         WHERE PD.WIP_ENTITY_ID = wdct.WIP_ENTITY_ID
           AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
	   AND pd.po_line_id IS NOT NULL
	   AND pd.line_location_id IS NOT NULL
           AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
           AND PL.PO_HEADER_ID = PD.PO_HEADER_ID
	   AND PL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
           AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
	   AND (PL.CANCEL_FLAG IS NULL OR
            PL.CANCEL_FLAG = 'N')
           AND (PL.QUANTITY_RECEIVED<(PL.QUANTITY-PL.QUANTITY_CANCELLED))
	   AND NVL(PL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
         )
	 --
          OR EXISTS
             (SELECT '1'
               FROM PO_REQUISITION_LINES_ALL PRL
              WHERE PRL.WIP_ENTITY_ID = wdct.WIP_ENTITY_ID
                AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
                AND nvl(PRL.cancel_flag, 'N') = 'N'
		AND PRL.LINE_LOCATION_ID is NULL
             )
           OR EXISTS
             (SELECT '1'
                FROM PO_REQUISITIONS_INTERFACE_ALL PRI
               WHERE PRI.WIP_ENTITY_ID = wdct.WIP_ENTITY_ID
                 AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
             ) ;

  l_failed_jobs WIP_DJ_CLOSE_TEMP.WIP_ENTITY_NAME%TYPE ;
  l_failed_counter NUMBER ;

BEGIN
fnd_file.put_line(FND_FILE.LOG,'Open PO Check');

IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.check_open_po',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;
x_returnStatus := fnd_api.g_ret_sts_success;
l_failed_counter := 0 ;

OPEN c_open_po ;
LOOP
  FETCH c_open_po INTO l_failed_jobs ;
   if (c_open_po%FOUND) then
     fnd_file.put_line(FND_FILE.LOG,'Open PO Exists');
     l_failed_counter := l_failed_counter + 1 ;
     x_returnStatus := fnd_api.g_ret_sts_error;
     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_failed_jobs));
     fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
     l_msg := fnd_message.get;
     fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
     fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
   end if ;

  EXIT WHEN c_open_po%NOTFOUND ;
 END LOOP ;

fnd_file.put_line(FND_FILE.LOG,'Number of jobs failed in Open PO : '||to_char( l_failed_counter));

IF (c_open_po%ISOPEN) THEN
   CLOSE c_open_po ;
END IF;

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.check_open_po',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
  WHEN others THEN
  IF (c_open_po%ISOPEN) THEN
   CLOSE c_open_po ;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_unexp_error;
  l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_close_priv.check_open_po',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
  END IF;
  fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
  fnd_message.set_token('MESSAGE', l_msg);
  fnd_msg_pub.add;

END CHECK_OPEN_PO ;

/* Add for Bug 9143739 (FP of 9020768)*/
procedure CHECK_DELIVERY_QTY
(
      x_returnstatus        OUT   NOCOPY VARCHAR2 ,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS

l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

CURSOR c_delivered_qty IS
  SELECT WIP_ENTITY_NAME
    FROM WIP_DJ_CLOSE_TEMP WDCT
   WHERE  wdct.GROUP_ID = p_group_id
     AND wdct.ORGANIZATION_ID = p_organization_id
     AND EXISTS
       (SELECT '1'
          FROM PO_RELEASES_ALL PR,
               PO_HEADERS_ALL PH,
               PO_DISTRIBUTIONS_ALL PD,
               PO_LINE_LOCATIONS_ALL PL
         WHERE PD.WIP_ENTITY_ID = wdct.WIP_ENTITY_ID
           AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
	   AND pd.po_line_id IS NOT NULL
	   AND pd.line_location_id IS NOT NULL
           AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
           AND PL.PO_HEADER_ID = PD.PO_HEADER_ID
	   AND PL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
           AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
	   AND (PL.CANCEL_FLAG IS NULL OR
            PL.CANCEL_FLAG = 'N')
           AND PD.QUANTITY_DELIVERED < PL.QUANTITY_RECEIVED
	   AND NVL(PL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
         );

  l_failed_jobs WIP_DJ_CLOSE_TEMP.WIP_ENTITY_NAME%TYPE ;
  l_failed_counter NUMBER ;

BEGIN
fnd_file.put_line(FND_FILE.LOG,'Delivery Quantity Check');

IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.check_delivery_qty',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;
x_returnStatus := fnd_api.g_ret_sts_success;
l_failed_counter := 0 ;

OPEN c_delivered_qty ;
LOOP
  FETCH c_delivered_qty INTO l_failed_jobs ;
   if (c_delivered_qty%FOUND) then
     fnd_file.put_line(FND_FILE.LOG,'Quantity delivered less than Quantity received');
     l_failed_counter := l_failed_counter + 1 ;
     x_returnStatus := fnd_api.g_ret_sts_error;
     fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_failed_jobs));
     fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
     l_msg := fnd_message.get;
     fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
     fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
   end if ;

  EXIT WHEN c_delivered_qty%NOTFOUND ;
 END LOOP ;

fnd_file.put_line(FND_FILE.LOG,'Number of jobs failed in Delivered Quantity : '||to_char( l_failed_counter));

IF (c_delivered_qty%ISOPEN) THEN
   CLOSE c_delivered_qty ;
END IF;

    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.check_delivery_qty',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
  WHEN others THEN
  IF (c_delivered_qty%ISOPEN) THEN
   CLOSE c_delivered_qty ;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_unexp_error;
  l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_close_priv.check_delivery_qty',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
  END IF;
  fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
  fnd_message.set_token('MESSAGE', l_msg);
  fnd_msg_pub.add;

END CHECK_DELIVERY_QTY ;

procedure LOT_VALIDATE
(
      x_returnstatus        OUT   NOCOPY VARCHAR2 ,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER
)
IS

l_error_code     number;
l_err_msg        varchar2(1000);
l_wsm_org          number ;
l_return_status  Varchar2(1);
l_params       wip_logger.param_tbl_t;
l_msg          VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;

BEGIN
x_returnStatus := fnd_api.g_ret_sts_success;
fnd_file.put_line(FND_FILE.LOG,'lot validate');
IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.lot_validate',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;

l_wsm_org := WSMPUTIL.CHECK_WSM_ORG(p_organization_id, l_error_code,l_err_msg);

If (l_wsm_org = 1) then
  WSMPUTIL.validate_lbj_before_close( p_group_id,
                                       p_organization_id,
                                       l_error_code,
                                       l_err_msg,
                                       l_return_status
                                      );
End if;

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.lot_validate',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
  WHEN others THEN
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_jobclose_priv.lot_validate',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
    END IF;
    fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
    fnd_message.set_token('MESSAGE', l_msg);
    fnd_msg_pub.add;

END LOT_VALIDATE ;


procedure DELETE_RESERVATIONS
(
      x_Returnstatus        OUT   NOCOPY  VARCHAR2 ,
      p_organization_id     IN    NUMBER ,
      p_group_id            IN    NUMBER

)
IS
l_params       wip_logger.param_tbl_t;
l_return_Status VARCHAR2(1);
l_msg         VARCHAR(240);
l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
l_rsv          inv_reservation_global.mtl_reservation_rec_type;
l_serialnumber inv_reservation_global.serial_number_tbl_type;
l_status                VARCHAR2(1) ;
l_msg_count             NUMBER;

CURSOR C_del_reservation IS
/* fix for bug 8681037 (FP 8461467) */

/*  SELECT wrv.reservation_id
    FROM wip_reservations_v wrv,
         wip_dj_close_temp wdct
   WHERE wdct.organization_id = p_organization_id
     AND wdct.group_id = p_group_id
     AND wdct.wip_entity_id = wrv.wip_entity_id;
*/
select /*+ leading(wdct) index(mr MTL_RESERVATIONS_N9) */       -- otimizacao
      mr.reservation_id
 from
      wip_dj_close_temp wdct,       -- otimizacao
      mtl_reservations mr,          -- otimizacao
      mtl_sales_orders mso,         -- otimizacao
      oe_order_lines_all ool        -- otimizacao
 where ((wdct.organization_id= p_organization_id and wdct.group_id= p_group_id)
  and mr.supply_source_header_id=wdct.wip_entity_id)
  and mr.demand_source_type_id in (2,8)                    -- otimizacao
  and mr.supply_source_type_id = 5                         -- otimizacao
  and mso.sales_order_id = mr.demand_source_header_id      -- otimizacao
  and ool.line_id = mr.demand_source_line_id;              -- otimizacao

 /* end of fix 8681037 (FP 8461467) */
BEGIN
x_returnStatus := fnd_api.g_ret_sts_success;
fnd_file.put_line(FND_FILE.LOG,'delete Existing reservations');

IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(1).paramName   := 'p_group_id';
    l_params(1).paramValue  :=  p_group_id ;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.delete_reservation',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
END IF;
OPEN C_del_reservation ;
LOOP
  FETCH C_del_reservation
   INTO l_rsv.reservation_id ;

   /* Inventory Call for deleting reservations */
   inv_reservation_pub.delete_reservation
                                (
                                p_api_version_number        => 1.0
                                , p_init_msg_lst              => fnd_api.g_true
                                , x_return_status             => l_status
                                , x_msg_count                 => l_msg_count
                                , x_msg_data                  => l_msg
                                , p_rsv_rec                   => l_rsv
                                , p_serial_number             => l_serialnumber -- no serial control
                        );
    EXIT WHEN c_del_reservation%NOTFOUND ;
  END LOOP ;

IF (c_del_reservation%ISOPEN) THEN
   CLOSE c_del_reservation ;
END IF;

    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.delete_reservation',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

EXCEPTION
  WHEN others THEN
  IF (c_del_reservation%ISOPEN) THEN
   CLOSE c_del_reservation ;
  END IF;
  x_returnStatus := fnd_api.g_ret_sts_unexp_error;
  l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;

  IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName=>'wip_jobclose_priv.delete_reservation',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => l_msg,
                           x_returnStatus => l_return_Status);
  END IF;
  fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
  fnd_message.set_token('MESSAGE', l_msg);
  fnd_msg_pub.add;

END DELETE_RESERVATIONS ;


/**************************************************************************
*   PROCEDURE TO WAIT FOR CONC. PROGRAM.
*   IT WILL RETURN ONLY AFTER THE CONC. PROGRAM COMPLETES
/**************************************************************************/

  PROCEDURE WAIT_CONC_PROGRAM(p_request_id in number,
			   errbuf       out NOCOPY varchar2,
                           retcode      out NOCOPY number) is
    l_call_status      boolean;
    l_phase            varchar2(80);
    l_status           varchar2(80);
    l_dev_phase        varchar2(80);
    l_dev_status       varchar2(80);
    l_message          varchar2(240);

    l_counter	       number := 0;
  BEGIN
    LOOP
      l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                    ( p_request_id,
                      10,
                      -1,
                      l_phase,
                      l_status,
                      l_dev_phase,
                      l_dev_status,
                      l_message);
      exit when l_call_status=false;

      if (l_dev_phase='COMPLETE') then
        if (l_dev_status = 'NORMAL') then
          retcode := -1;
        elsif (l_dev_status = 'WARNING') then
          retcode := 1;
        else
          retcode := 2;
        end if;
        errbuf := l_message;
        return;
      end if;

      l_counter := l_counter + 1;
      exit when l_counter >= 2;

    end loop;

    retcode := 2;
    return ;
END WAIT_CONC_PROGRAM;

PROCEDURE RUN_REPORTS ( x_Returnstatus        OUT   NOCOPY  VARCHAR2 ,
      p_group_id            IN  NUMBER ,
      p_organization_id     IN  NUMBER ,
      p_report_type         IN	NUMBER,
      p_class_type          IN  VARCHAR2  ,
      p_from_class          IN  VARCHAR2  ,
      p_to_class            IN  VARCHAR2  ,
      p_from_job            IN  VARCHAR2  ,
      p_to_job              IN  VARCHAR2  ,
      p_status		    IN  VARCHAR2
      )
IS
l_req_id NUMBER;
l_acct_period           NUMBER;
l_chart_of_accounts_id  NUMBER;
l_std_asst_jobs         NUMBER;
l_expense_jobs          NUMBER;
l_std_org_count         NUMBER;
l_acct_period_id        NUMBER;
SORT_BY_JOB		NUMBER;
l_precision_profile	NUMBER;
l_report_type		NUMBER ;
l_per_str_date          VARCHAR2(30);
l_per_cls_date          VARCHAR2(30);
wait BOOLEAN;
phase VARCHAR2(2000);
status VARCHAR2(2000);
devphase VARCHAR2(2000);
devstatus VARCHAR2(2000);
message VARCHAR2(2000);
errbuf  VARCHAR2(200);
retcode NUMBER ;

BEGIN
fnd_file.put_line(FND_FILE.LOG,'Running Reports.........');

x_ReturnStatus := fnd_api.g_ret_sts_success;
SORT_BY_JOB := 1 ;
l_report_type := p_report_type ;
l_precision_profile := fnd_profile.value('REPORT_QUANTITY_PRECISION');

IF ( l_precision_profile = NULL ) then
      l_precision_profile := 2;
END IF ;

fnd_file.put_line(FND_FILE.LOG,'Report Quantity Precision');

SELECT COUNT(*)
  INTO l_std_asst_jobs
  FROM WIP_DJ_CLOSE_TEMP TEMP,
       WIP_DISCRETE_JOBS WDJ,
       WIP_ACCOUNTING_CLASSES WAC
 WHERE WDJ.WIP_ENTITY_ID = TEMP.WIP_ENTITY_ID
   AND TEMP.ORGANIZATION_ID = p_organization_id
   AND WDJ.ORGANIZATION_ID = TEMP.ORGANIZATION_ID
   AND WAC.ORGANIZATION_ID = TEMP.ORGANIZATION_ID
   AND WDJ.CLASS_CODE = WAC.CLASS_CODE
   AND TEMP.GROUP_ID = p_group_id
   AND WAC.CLASS_TYPE IN
		     --(1,3,5,6)
		(WIP_CONSTANTS.DISC_CLASS,
		 WIP_CONSTANTS.NS_ASSET_CLASS,
		 WIP_CONSTANTS.LOT_CLASS,
		 WIP_CONSTANTS.EAM_CLASS ) ;

SELECT COUNT(*)
  INTO l_expense_jobs
  FROM WIP_DJ_CLOSE_TEMP TEMP,
       WIP_DISCRETE_JOBS WDJ,
       WIP_ACCOUNTING_CLASSES WAC
 WHERE WDJ.WIP_ENTITY_ID = TEMP.WIP_ENTITY_ID
   AND TEMP.ORGANIZATION_ID = p_organization_id
   AND WDJ.ORGANIZATION_ID = p_organization_id
   AND WAC.ORGANIZATION_ID = p_organization_id
   AND WDJ.CLASS_CODE = WAC.CLASS_CODE
   AND TEMP.GROUP_ID = p_group_id
   AND WAC.CLASS_TYPE = WIP_CONSTANTS.NS_EXPENSE_CLASS ;

-- Bug 4890159. Performance Fix
-- saugupta 1-Jun-06
/*
SELECT CHART_OF_ACCOUNTS_ID
  INTO l_chart_of_accounts_id
  FROM ORG_ORGANIZATION_DEFINITIONS
 WHERE ORGANIZATION_ID = p_organization_id ;
*/
SELECT  lgr.chart_of_accounts_id chart_of_accounts_id
INTO l_chart_of_accounts_id
FROM    hr_organization_information hoi,
        gl_ledgers lgr
WHERE   hoi.organization_id             = p_organization_id
        and hoi.org_information_context = 'Accounting Information'
        and (ltrim(hoi.org_information1,'0123456789') is null
                 and hoi.org_information1    = lgr.ledger_id )
        and lgr.object_type_code    = 'L'
        AND nvl(complete_flag, 'Y') = 'Y';

SELECT ACCT_PERIOD_ID,
          to_char(PERIOD_START_DATE,'YYYY/MM/DD'),
          to_char(SCHEDULE_CLOSE_DATE,'YYYY/MM/DD')
  INTO l_acct_period_id ,
	  l_per_str_date,
	  l_per_cls_date
  FROM ORG_ACCT_PERIODS
 WHERE INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG (SYSDATE, p_organization_id) >= TRUNC(PERIOD_START_DATE)
   AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG (SYSDATE, p_organization_id) <= TRUNC(SCHEDULE_CLOSE_DATE)
   AND ORGANIZATION_ID = p_organization_id;

 SELECT COUNT(*)
   INTO l_std_org_count
   FROM MTL_PARAMETERS
  WHERE ORGANIZATION_ID = p_organization_id
    AND PRIMARY_COST_METHOD = 1 ;

IF (l_std_asst_jobs >= 1)  and ( l_report_type <> 4 ) THEN
  /* STANDARD  AND ASSET JOBS  */

  IF (l_std_org_count = 1 ) THEN
  fnd_file.put_line(FND_FILE.LOG,'--------WIPRDJVR---------');

  l_req_id := FND_REQUEST.SUBMIT_REQUEST('WIP','WIPRDJVR',NULL,NULL,
    NULL,
    to_char(p_organization_id),		-- Organziation id	Parameter 1
    to_char(l_chart_of_accounts_id),	--			Parameter 2
    to_char(l_acct_period_id),		--			Parameter 3
    to_char(l_precision_profile),	--			Parameter 4
    'PLS', -- default SRS		--			Parameter 5
    to_char(SORT_BY_JOB),		--			Parameter 6
    to_char(l_report_type),		--			Parameter 7
    NULL,	 			-- 1 ,p_class_type	Parameter 8
    NULL,--1				--			Parameter 9
    NULL,--1				--			Parameter 10
    NULL,				-- p_from_class		Parameter 11
    NULL,				-- p_to_class		Parameter 12
    NULL,				-- p_from_job		Parameter 13
    NULL ,				-- p_to_job		Parameter 14
    NULL, 				-- Status type		Parameter 15
    NULL, 				--			Parameter 16
    NULL,				--			Parameter 17
    NULL,		                -- Currency Code	Parameter 18
    NULL,				--'N'			Parameter 19
    NULL,				--2 Exchange Rate type	Parameter 20
    NULL,				--1 Exchange Rate	Parameter 21
    NULL,
    NULL,
    p_group_id ,                        -- Group Id             Parameter 24
  NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

ELSE
  fnd_file.put_line(FND_FILE.LOG,'CSTRDJVA');

  l_req_id := FND_REQUEST.SUBMIT_REQUEST('BOM','CSTRDJVA',NULL,NULL,
  FALSE,
  NULL ,  -- Parameter  1
  NULL ,  -- Parameter  2
  NULL ,  -- Parameter  3
  NULL ,  -- Parameter  4
  to_char(p_organization_id),  -- Parameter  5
  to_char(l_chart_of_accounts_id),  -- Parameter  6
  to_char(l_acct_period_id),  -- Parameter  7
  to_char( l_precision_profile), -- Parameter  8
  'PLS',
  to_char(SORT_BY_JOB),  -- Parameter  10
  to_char(l_report_type), -- Parameter  11
  NULL,   -- Parameter  12
  NULL,
  NULL,
  NULL,   -- Parameter  15
  NULL,   -- Parameter  16
  NULL,   -- Parameter  17
  NULL,   -- Parameter  18
  NULL,   -- Parameter  19
  NULL,   -- Parameter  20
  NULL, NULL, NULL, NULL, NULL ,
  p_group_id , NULL, NULL , NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  END IF ;

  COMMIT ;

  IF (l_req_id = 0) THEN
      RETCODE := 2;
      RETURN;
  END IF;

  WAIT_CONC_PROGRAM(l_req_id,ERRBUF,RETCODE);

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Costing Report Concurrent Program return code  : '||retcode);

  if (retcode <> -1 ) then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Report has errored or has a warning');
      errbuf := fnd_message.get;
      raise FND_API.G_EXC_ERROR ;
  end if;

END IF ;

/* EXPENSE REPORTS */

IF (l_expense_jobs >= 1)  and ( l_report_type <> 4 ) THEN

 l_report_type := 1 ; -- Always detailed reports only
 fnd_file.put_line(FND_FILE.LOG,'WIPREJVR');

 l_req_id := FND_REQUEST.SUBMIT_REQUEST('WIP','WIPREJVR',NULL,NULL,
    FALSE,
    to_char(p_organization_id),      -- Parameter 1
    to_char(l_chart_of_accounts_id), -- Parameter 2
    to_char(l_precision_profile),    -- Parameter 3
    'PLS',			     -- Parameter 4
    to_char(SORT_BY_JOB),            -- Parameter 5
    to_char(l_report_type),	     -- Parameter 6
    l_per_str_date,
    l_per_cls_date,
    NULL,     -- Parameter  9
    NULL,     -- Parameter  10
    NULL,     -- Parameter  11
    NULL,    -- Parameter  12
    NULL,     -- Parameter  13
    NULL, NULL, p_group_id ,
  NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  COMMIT ;

  IF (l_req_id = 0) THEN
      RETCODE := 2;
      RETURN;
  END IF;

  WAIT_CONC_PROGRAM(l_req_id,ERRBUF,RETCODE);

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Expense report reurn code  : '||retcode);

  if (retcode <> -1 ) then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Report has errored or has a warning');
      errbuf := fnd_message.get;
      raise FND_API.G_EXC_ERROR ;
  end if;

END IF ;  -- Expense Reports End

EXCEPTION
 WHEN OTHERS THEN
   x_ReturnStatus := FND_API.G_RET_STS_ERROR;
END RUN_REPORTS;



/**************************************************************************
* This is the main API . This is the equivalent of wicdcl.opp .This API   *
* closes discrete jobs .
**************************************************************************/


procedure WIP_CLOSE
(
      p_organization_id     IN  NUMBER    ,
      p_class_type          IN  VARCHAR2  ,
      p_from_class          IN  VARCHAR2  ,
      p_to_class            IN  VARCHAR2  ,
      p_from_job            IN  VARCHAR2  ,
      p_to_job              IN  VARCHAR2  ,
      p_from_release_date   IN  VARCHAR2  ,
      p_to_release_date     IN  VARCHAR2  ,
      p_from_start_date     IN  VARCHAR2  ,
      p_to_start_date       IN  VARCHAR2  ,
      p_from_completion_date IN VARCHAR2  ,
      p_to_completion_date  IN  VARCHAR2  ,
      p_status              IN  VARCHAR2  ,
      p_group_id            IN  NUMBER  ,
      p_select_jobs         IN  NUMBER  ,
      p_exclude_reserved_jobs IN  VARCHAR2  ,
      p_uncompleted_jobs    IN VARCHAR2,
      p_exclude_pending_txn_jobs IN  VARCHAR2  ,
      p_report_type         IN  VARCHAR2 ,
      p_act_close_date      IN  VARCHAR2 ,
      x_warning             OUT NOCOPY NUMBER ,
      x_returnStatus	    OUT NOCOPY VARCHAR2
)
IS
  l_group_id              NUMBER ;
  l_from_release_date     DATE ;
  l_to_release_date       DATE ;
  l_from_start_date       DATE ;
  l_to_start_date         DATE ;
  l_from_completion_date  DATE ;
  l_to_completion_date    DATE ;
  l_act_close_date        DATE ;
  l_ret_code              NUMBER;
  l_at_submission_time    NUMBER;
  l_immediate             NUMBER;
  l_acct_period_id	  NUMBER;
  l_num_close             NUMBER;
  l_dest_day_time	  DATE;
  l_per_str_date	  DATE;
  l_per_cls_date	  DATE;
  l_costing_group_id      NUMBER;
  l_return_status         VARCHAR2(1) ;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(200);
  l_msg                   VARCHAR2(2000);
  l_req_id                NUMBER;
  l_params       wip_logger.param_tbl_t;
  l_errMsg       VARCHAR2(240);
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
	l_acct_period_close_date  DATE;  -- Added for bug : 8262844(FP of 8215957)
  l_jobs_to_close NUMBER; --fix bug 9250439

BEGIN

l_at_submission_time := 1 ; ---SRS
l_immediate := 2 ; -- From Close Form
x_returnStatus := FND_API.G_RET_STS_SUCCESS ;

fnd_file.put_line(FND_FILE.LOG,'WIP DISCRETE JOB CLOSE');

fnd_file.put_line(FND_FILE.OUTPUT,'*****************************');
fnd_file.put_line(FND_FILE.OUTPUT,'WIP DISCRETE JOB CLOSE OUTPUT');
fnd_file.put_line(FND_FILE.OUTPUT,'*****************************');
 -- write parameter value to log file

 IF (l_logLevel <= wip_constants.trace_logging) THEN
    l_params(1).paramName   := 'p_organization_id';
    l_params(1).paramValue  :=  p_organization_id ;
    l_params(2).paramName   := 'p_class_type';
    l_params(2).paramValue  :=  p_class_type;
    l_params(3).paramName   := 'p_from_class';
    l_params(3).paramValue  :=  p_from_class;
    l_params(4).paramName   := 'p_to_class';
    l_params(4).paramValue  :=  p_to_class;
    l_params(5).paramName   := 'p_from_job';
    l_params(5).paramValue  :=  p_from_job;
    l_params(6).paramName   := 'p_to_job';
    l_params(6).paramValue  :=  p_to_job;
    l_params(7).paramName   := 'p_from_release_date';
    l_params(7).paramValue  :=  p_from_release_date;
    l_params(8).paramName   := 'p_to_release_date';
    l_params(8).paramValue  :=  p_to_release_date;
    wip_logger.entryPoint(p_procName => 'wip_jobclose_priv.wip_close',
                          p_params => l_params,
                          x_returnStatus => l_return_Status);
 END IF;


IF ( p_select_jobs = l_at_submission_time) THEN

/***************************************************/
/*            TIME ZONE CONVERSION                 */
/***************************************************/

TIME_ZONE_CONVERSIONS(
  p_from_release_date => p_from_release_date ,
  p_to_release_date   => p_to_release_date   ,
  p_from_start_date   => p_from_start_date   ,
  p_to_start_date     => p_to_start_date     ,
  p_from_completion_date => p_from_completion_date  ,
  p_to_completion_date => p_to_completion_date  ,
  p_act_close_date    => p_act_close_date    ,
  x_from_release_date => l_from_release_date ,
  x_to_release_date   => l_to_release_date   ,
  x_from_start_date   => l_from_start_date   ,
  x_to_start_date     => l_to_start_date     ,
  x_from_completion_date => l_from_completion_date  ,
  x_to_completion_date => l_to_completion_date ,
  x_act_close_date     => l_act_close_date ,
  x_returnstatus      => l_return_status
);
IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'time zone conversion failed',
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

if  ( sysdate > l_act_close_date ) then
  fnd_file.put_line(FND_FILE.LOG,'WIP DISCRETE CLOSE');
else
 fnd_message.set_name('WIP','CLOSE DATE');
 l_msg := fnd_message.get;
 l_msg := l_msg || ' ' || l_act_close_date ;
 fnd_message.set_name('WIP','WIP_LESS_OR_EQUAL');
 fnd_message.set_token('ENTITY1',l_msg);
 fnd_message.set_token('ENTITY2', sysdate);
 l_msg := fnd_message.get;
 fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
 fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
 fnd_file.put_line(FND_FILE.LOG,l_msg);
 RAISE  FND_API.G_EXC_ERROR ;
end if ;

/****************************************************************
*                                                                *
*  Check for ACTUAL CLOSE DATE to be in an open accounting period*
*                                                                *
*****************************************************************/
  BEGIN

   SELECT ACCT_PERIOD_ID
    INTO l_acct_period_id
    FROM ORG_ACCT_PERIODS
   WHERE ORGANIZATION_ID = p_organization_id
     AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG (l_act_close_date,p_organization_id)
 BETWEEN PERIOD_START_DATE AND SCHEDULE_CLOSE_DATE
     AND PERIOD_CLOSE_DATE IS NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('WIP','WIP_CLOSE_CLOSED_PERIOD');
      l_msg := fnd_message.get;
      fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
      fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
      fnd_file.put_line(FND_FILE.LOG,l_msg) ;
      RAISE  FND_API.G_EXC_ERROR ;
  END ;

/**********************************************************
*                                                         *
* This procedure populates details into temp table before *
* deletion . This is an equivalent API of wildct.ppc      *
*                                                         *
**********************************************************/

populate_close_temp(
      p_organization_id => p_organization_id  ,
      p_class_type      => p_class_type       ,
      p_from_class      => p_from_class       ,
      p_to_class        => p_to_class         ,
      p_from_job        => p_from_job         ,
      p_to_job          => p_to_job           ,
      p_from_release_date =>  l_from_release_date     ,
      p_to_release_date => l_to_release_date  ,
      p_from_start_date => l_from_start_date  ,
      p_to_start_date   => l_to_start_date    ,
      p_from_completion_date => l_from_completion_date ,
      p_to_completion_date   => l_to_completion_date   ,
      p_status          => to_number(p_status),
      p_exclude_reserved_jobs =>  p_exclude_reserved_jobs  ,
      p_exclude_pending_txn_jobs  => p_exclude_pending_txn_jobs ,
      p_report_type     => p_report_type       ,
      p_act_close_date  => l_act_close_date ,
      x_group_id        => l_group_id ,
      x_ReturnStatus    => l_return_status
);
IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'populate_close_temp',
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

/*Bug 6908428: Raise workflow notifications for eam workorders for status change to Pending close */
EAM_WorkOrderTransactions_PUB.RAISE_WORKFLOW_STATUS_PEND_CLS(
        p_group_id    => l_group_id               ,
        p_new_status  => WIP_CONSTANTS.PEND_CLOSE ,
        ERRBUF        => l_errMsg                 ,
        RETCODE       => l_return_status
);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'error during eam update workflow to pending close' || l_errMsg,
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;
/*Bug 6908428*/

UPDATE wip_discrete_jobs
   SET status_type = WIP_CONSTANTS.PEND_CLOSE ,
       request_id =  fnd_global.conc_request_id ,
       last_update_date = sysdate,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.login_id,
       program_application_id = fnd_global.prog_appl_id,
       program_id =  fnd_global.conc_program_id
 WHERE organization_id = p_organization_id
   AND wip_entity_id in (SELECT wip_entity_id
                           FROM wip_dj_close_temp
                          WHERE group_id = l_group_id
                            AND organization_id = p_organization_id);

/*Bug 6908428: Updating the status in eam_work_order_details pending close for eam workorders */
EAM_WorkOrderTransactions_PUB.Update_EWOD(
        p_group_id          => l_group_id,
        p_organization_id   => p_organization_id,
        p_new_status        => WIP_CONSTANTS.PEND_CLOSE,
        ERRBUF              => l_errMsg,
        RETCODE             => l_return_status
);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'eam update workoder error during pending close ' || l_errMsg,
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

/*Bug 6908428*/


CANCEL_PO(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);

ELSE
/* When the concurrent program is being called from Form */
     l_group_id := p_group_id ;

END IF ;

fnd_file.put_line(FND_FILE.LOG,'GROUP ID '||to_char(l_group_id));

/*Fix bug 9250439*/
SELECT COUNT(*)
INTO l_jobs_to_close
FROM WIP_DJ_CLOSE_TEMP
WHERE GROUP_ID = l_group_id
AND ROWNUM = 1;

IF (l_jobs_to_close = 0) THEN
    GOTO skip_close_job; -- Fix bug 9250439
END IF;

/**********************************************************
*                                                         *
*  Checks  if Job Release date <= actual close date        *
*                                                         *
**********************************************************/

PRIOR_DATE_RELEASE(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
  fnd_message.set_name('WIP', 'WIP_PRIOR_DATE_RELEASE');
  l_msg := fnd_message.get;
  fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
  fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
  x_warning := 1 ;
  --
  -- Bug 5345660 Added profile check before invoking wip_logger
  --
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_return_Status);
  END IF;
 END IF;

/**********************************************************
*                                                         *
*  Close all exceptions for this Job                      *
*                                                         *
**********************************************************/

CLOSE_JOB_EXCEPTIONS(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
  x_warning := 1 ;
 END IF;

 /**********************************************************
*                                                         *
* This call validates if any pending clocks exist         *
* and error out if there are any .                        *
*                                                         *
**********************************************************/

PENDING_CLOCKS(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
  fnd_message.set_name('WIP', 'WIP_PENDING_CLOCKS');
  l_msg := fnd_message.get;
  fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
  fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
  x_warning := 1 ;
  --
  -- Bug 5345660 Added profile check before invoking wip_logger
  --
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_return_Status);
  END IF;
 END IF;
/**********************************************************
*                                                         *
*  Try to cancel any move orders or tasks created by the  *
*  component picking process related to this job.         *
*                                                         *
*                                                         *
**********************************************************/

 CANCEL_MOVE_ORDERS(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);
 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
  fnd_message.set_name('WIP', 'TRANSACTIONS PENDING');
  l_msg := fnd_message.get;
  fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
  fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
  x_warning := 1 ;
  --
  -- Bug 5345660 Added profile check before invoking wip_logger
  --
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_return_Status);
  END IF;
 END IF;

 /**********************************************************
*                                                         *
* This call validates if any pending transactions exist   *
* and error out if there are any .                        *
*                                                         *
**********************************************************/

PENDING_TXNS(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
  fnd_message.set_name('WIP', 'TRANSACTIONS PENDING');
  l_msg := fnd_message.get;
  fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
  fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
  x_warning := 1 ;
  --
  -- Bug 5345660 Added profile check before invoking wip_logger
  --
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
    wip_logger.log(p_msg          => l_msg,
                   x_returnStatus => l_return_Status);
  END IF;
 END IF;

 /**********************************************************
*                                                         *
* This call validates if the close date is in past.       *
*                                                         *
**********************************************************/

PAST_CLOSE_DATE(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id);

 IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    fnd_message.set_name('WIP', 'CLOSE DATE IN PAST');
    l_msg := fnd_message.get;
    fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
    fnd_file.put_line(FND_FILE.OUTPUT,'*******************');
    x_warning := 1 ;
    --
    -- Bug 5345660 Added profile check before invoking wip_logger
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_return_Status);
    END IF;
  END IF;

/**********************************************************
*                                                         *
* This call validates if any open purchase orders exist   *
* and Warn  if there are any . This check is done         *
* only from SRS                                           *
**********************************************************/

IF ( p_select_jobs = l_at_submission_time) THEN

 CHECK_OPEN_PO(
  x_returnstatus    => l_return_status,
  p_organization_id => p_organization_id,
  p_group_id        => l_group_id);

  IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    x_warning := 1 ;
    fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
    l_msg := fnd_message.get;
    --
    -- Bug 5345660 Added profile check before invoking wip_logger
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => l_msg,
                     x_returnStatus => l_return_Status);
    END IF;
  END IF;
 END IF ;

/**********************************************************
* Add for Bug 9143739 (FP of 9020768)                     *
* This validation is to check:                            *
* If PO quantity delivered < PO quantity recieved,        *
* fail closed the job                                     *
**********************************************************/
 CHECK_DELIVERY_QTY(
  x_returnstatus    => l_return_status,
  p_organization_id => p_organization_id,
  p_group_id        => l_group_id);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'CHECK_DELIVERY_QTY procedure failed',
                     x_returnStatus => l_return_Status);
  END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;


 /**********************************************************
*                                                         *
* This validation is for LOT Based Jobs .                 *
*                                                         *
**********************************************************/

LOT_VALIDATE(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id );
IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'LOT_VALIDATE procedure failed',
                     x_returnStatus => l_return_Status);
  END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

 /**********************************************************
*                                                         *
* Cover routine for the inventory API delete_reservation. *
*                                                         *
**********************************************************/


DELETE_RESERVATIONS(
 x_returnstatus    => l_return_status,
 p_organization_id => p_organization_id,
 p_group_id        => l_group_id );

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
  IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'DELETE_RESERVATIONS procedure failed',
                     x_returnStatus => l_return_Status);
  END IF;
END IF;

/* Modified for bug : 8262844(FP of 8215957). If an accounting period is not open as of sysdate,
 	 then accounting period that is open as of job actual close date is fetched
 	 and passed to hooks code.
*/

BEGIN

SELECT ACCT_PERIOD_ID
  INTO l_acct_period_id
  FROM ORG_ACCT_PERIODS
 WHERE TRUNC(SYSDATE) >= TRUNC(PERIOD_START_DATE)
   AND TRUNC(SYSDATE) <= TRUNC(SCHEDULE_CLOSE_DATE)
   AND ORGANIZATION_ID = p_organization_id;

    fnd_file.put_line(FND_FILE.LOG,'Current accounting Period ID : '||to_char(l_acct_period_id));
 	 EXCEPTION
 	   WHEN OTHERS THEN

 	    IF p_act_close_date IS NULL THEN
         SELECT MAX(ACTUAL_CLOSE_DATE)
         INTO l_acct_period_close_date
         FROM WIP_DJ_CLOSE_TEMP
         WHERE GROUP_ID = l_group_id;
      END IF;

      SELECT ACCT_PERIOD_ID
      INTO l_acct_period_id
      FROM ORG_ACCT_PERIODS oap
      WHERE
      oap.ORGANIZATION_ID = p_organization_id
      AND oap.PERIOD_CLOSE_DATE IS NULL
      AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(nvl(l_acct_period_close_date,to_date(p_act_close_date,'YYYY/MM/DD HH24:MI:SS')),p_organization_id)
      BETWEEN oap.PERIOD_START_DATE and oap.SCHEDULE_CLOSE_DATE;

      fnd_file.put_line(FND_FILE.LOG,'Last accounting Period ID : '||to_char(l_acct_period_id));
END;


/*********************************************************
* This is a hook which returns success and can be used to*
* call other procedures depending on client requirements *
**********************************************************/

WIP_CLOSE_JOB_HOOK.WIP_CLOSE_JOB_HOOK_PRC
      (P_group_id => l_group_id,
       P_org_id => p_organization_id ,
       P_acct_per_id => l_acct_period_id ,
       P_ret_code => l_ret_code ,
       P_err_buf => l_errMsg );

IF (l_ret_code <> 0 ) THEN
  RAISE  FND_API.G_EXC_ERROR ;
END IF;


/*****************************************
*                                        *
*	Costing Function updates	 *
*                                        *
******************************************/

SELECT WIP_TRANSACTIONS_S.nextval
  INTO l_costing_group_id
  FROM DUAL;

INSERT INTO WIP_COST_TXN_INTERFACE
        (LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
         CREATION_DATE,
	 CREATED_BY,
         REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         TRANSACTION_ID,
	 ACCT_PERIOD_ID,
         GROUP_ID,
	 PROCESS_STATUS,
	 PROCESS_PHASE,
	 TRANSACTION_TYPE,
         ORGANIZATION_ID,
	 WIP_ENTITY_ID,
	 WIP_ENTITY_NAME,
         ENTITY_TYPE,
	 TRANSACTION_DATE)
     SELECT
            SYSDATE,
	    fnd_global.user_id,
	    fnd_global.login_id ,
            SYSDATE,
	    fnd_global.user_id,
	    fnd_global.conc_request_id ,
	   fnd_global.prog_appl_id,
  	   fnd_global.conc_program_id ,
	    SYSDATE,
            WIP_TRANSACTIONS_S.nextval,
	    oap.ACCT_PERIOD_ID,
            l_costing_group_id,
	    2, -- PROCESS_STATUS
	    3, -- PROCESS_PHASE
	    6, -- TRANSACTION_TYPE
            p_organization_id,
	    wdct.WIP_ENTITY_ID,
	    wdct.WIP_ENTITY_NAME,
            we.ENTITY_TYPE,
	    wdct.ACTUAL_CLOSE_DATE
       FROM WIP_DJ_CLOSE_TEMP wdct,
            ORG_ACCT_PERIODS oap,
            WIP_ENTITIES we
       WHERE wdct.GROUP_ID = l_group_id
            AND we.wip_entity_id = wdct.wip_entity_id
            AND we.organization_id = p_organization_id
            AND wdct.ORGANIZATION_ID = p_organization_id
            AND oap.ORGANIZATION_ID = p_organization_id
            AND oap.PERIOD_CLOSE_DATE IS NULL
            AND INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG (wdct.ACTUAL_CLOSE_DATE, wdct.ORGANIZATION_ID)
	        BETWEEN oap.PERIOD_START_DATE and oap.SCHEDULE_CLOSE_DATE;

/*==============================================================+
|     CALL  COSTING function to update variances                |
|===============================================================*/

CST_JobCloseVar_GRP.Calculate_Job_Variance
(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL ,
        x_return_status        =>     l_return_status,
        x_msg_count            =>     l_msg_count,
        x_msg_data             =>     l_msg_data,
        p_user_id              =>      fnd_global.user_id,
        p_login_id             =>      fnd_global.login_id,
        p_prg_appl_id          =>      fnd_global.prog_appl_id,
        p_prg_id               =>      fnd_global.conc_program_id,
        p_req_id               =>      fnd_global.conc_request_id,
        p_wcti_group_id        =>      l_costing_group_id,
        p_org_id               =>      p_organization_id
);
-- Bug 5370550
IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'costing function error',
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;


/* Closing the jobs */

/*Bug 6908428: updating the status of eam workorders in eam_work_order_details to closed and workflow update*/
EAM_WorkOrderTransactions_PUB.RAISE_WORKFLOW_STATUS_PEND_CLS(
        p_group_id        => l_group_id,
        p_new_status      => WIP_CONSTANTS.CLOSED,
        ERRBUF            => l_errMsg,
        RETCODE           => l_return_Status
);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'error during eam update workflow to closed' || l_errMsg,
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

EAM_WorkOrderTransactions_PUB.Update_EWOD(
        p_group_id          => l_group_id,
        p_organization_id   => p_organization_id,
        p_new_status        => WIP_CONSTANTS.CLOSED,
        ERRBUF              => l_errMsg,
        RETCODE             => l_return_status
);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'eam update workoder error while job close' || l_errMsg,
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

/*Bug 6908428*/


UPDATE WIP_DISCRETE_JOBS wdj
   SET DATE_CLOSED = (SELECT wdct.ACTUAL_CLOSE_DATE
                       FROM WIP_DJ_CLOSE_TEMP wdct
                       WHERE wdct.ORGANIZATION_ID = p_organization_id
                       AND wdj.ORGANIZATION_ID = p_organization_id
                       AND wdj.WIP_ENTITY_ID = wdct.WIP_ENTITY_ID
                       AND wdct.GROUP_ID = l_group_id),
	LAST_UPDATE_DATE = SYSDATE,
   	last_updated_by = fnd_global.user_id,
	last_update_login = fnd_global.login_id,
	STATUS_TYPE =  WIP_CONSTANTS.CLOSED
  WHERE ORGANIZATION_ID = p_organization_id
    AND WIP_ENTITY_ID IN (SELECT WIP_ENTITY_ID
                          FROM WIP_DJ_CLOSE_TEMP
                          WHERE ORGANIZATION_ID = p_organization_id
                         AND GROUP_ID = l_group_id);


UPDATE WIP_ENTITIES
   SET ENTITY_TYPE = --DECODE(entity_type,6,7,5,8,3),
			DECODE(entity_type,
			WIP_CONSTANTS.EAM,
			WIP_CONSTANTS.CLOSED_EAM,
			WIP_CONSTANTS.LOTBASED ,
			WIP_CONSTANTS.CLOSED_OSFM ,
			WIP_CONSTANTS.CLOSED_DISC),
	LAST_UPDATE_DATE = SYSDATE,
  	last_updated_by = fnd_global.user_id,
	last_update_login = fnd_global.login_id
 WHERE ORGANIZATION_ID = p_organization_id
   AND WIP_ENTITY_ID IN (SELECT wdct.WIP_ENTITY_ID
                          FROM WIP_DJ_CLOSE_TEMP wdct
                          WHERE wdct.ORGANIZATION_ID = p_organization_id
                          AND wdct.GROUP_ID = l_group_id);


/*****************************************************/
/*                  CALLING REPORTS                  */
/*****************************************************/

fnd_file.get_names(l_msg,l_msg_data);
fnd_file.put_line( FND_FILE.LOG,l_msg);
fnd_file.put_line( FND_FILE.LOG,l_msg_data);

Run_Reports(
         x_returnstatus    => l_return_status,
	 p_group_id        => l_group_id ,
	 p_organization_id => p_organization_id,
	 p_report_type     => p_report_type,
	 p_class_type      => p_class_type ,
         p_from_class      => p_from_class ,
         p_to_class        => p_to_class  ,
         p_from_job        => p_from_job  ,
         p_to_job          => p_to_job ,
	 p_status          => p_status);

IF(l_return_status <> fnd_api.g_ret_sts_success) THEN
  x_warning := 1 ;
END IF;


/*****************************************************/
/*               END OF CALLING REPORTS             */
/****************************************************/


 SELECT COUNT(*)
   INTO l_num_close
   FROM WIP_DJ_CLOSE_TEMP
  WHERE ORGANIZATION_ID = p_organization_id
    AND GROUP_ID = l_group_id;

 fnd_file.put_line( FND_FILE.LOG,'Number of jobs Closed '||to_char(l_num_close));
 fnd_file.put(FND_FILE.OUTPUT,to_char(l_num_close)||' ');
 fnd_message.set_name('WIP','WIP_NUM_CLOSED');
 l_msg := fnd_message.get;
 fnd_file.put_line(FND_FILE.OUTPUT,l_msg);
 fnd_file.put_line(FND_FILE.OUTPUT,'*******************');


 IF ( l_num_close > 0 ) THEN
   DELETE FROM WIP_DJ_CLOSE_TEMP
    WHERE ORGANIZATION_ID = p_organization_id
      AND GROUP_ID = l_group_id;
 END IF;

    --Fix bug 9250439
    <<skip_close_job>>
    --
    -- Bug 5345660 exitPoint for normal exit.
    --
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.wip_close',
            p_procReturnStatus => x_returnStatus,
            p_msg => 'procedure normal exit',
            x_returnStatus => l_return_status);
    END IF;

COMMIT ;

EXCEPTION
  WHEN others THEN
    rollback ;
    fnd_file.put_line( FND_FILE.LOG,'Exception has occured');
    x_returnStatus :=  FND_API.G_RET_STS_ERROR ;
    /* Update jobs to Failed Close status  */

/*Bug 6908428: Update the status of  eam_work_order_details to failed close and proceed workflow notification*/
EAM_WorkOrderTransactions_PUB.RAISE_WORKFLOW_STATUS_PEND_CLS(
        p_group_id        => l_group_id,
        p_new_status      => WIP_CONSTANTS.FAIL_CLOSE,
        ERRBUF            => l_errMsg,
        RETCODE           => l_return_Status
);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'error during eam update workflow to fail closed' || l_errMsg,
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

EAM_WorkOrderTransactions_PUB.Update_EWOD(
        p_group_id          => l_group_id,
        p_organization_id   => p_organization_id,
        p_new_status        => WIP_CONSTANTS.FAIL_CLOSE,
        ERRBUF              => l_errMsg,
        RETCODE             => l_return_status
);

IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
   IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
      wip_logger.log(p_msg          => 'eam update workoder error during fail close' || l_errMsg,
                     x_returnStatus => l_return_Status);
    END IF;
  RAISE  FND_API.G_EXC_ERROR ;
END IF;

/*Bug 6908428*/


    UPDATE WIP_DISCRETE_JOBS wdj
       SET LAST_UPDATE_DATE = SYSDATE,
	   last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.login_id,
	   STATUS_TYPE =  WIP_CONSTANTS.FAIL_CLOSE
     WHERE ORGANIZATION_ID = p_organization_id
       AND WIP_ENTITY_ID IN (SELECT WIP_ENTITY_ID
	                      FROM WIP_DJ_CLOSE_TEMP
                             WHERE ORGANIZATION_ID = p_organization_id
                              AND GROUP_ID = l_group_id);

   /* Clean up  Temp Table  */

    DELETE FROM WIP_DJ_CLOSE_TEMP
     WHERE ORGANIZATION_ID = p_organization_id
       AND GROUP_ID = l_group_id;

    --
    -- Bug 5345660 exitPoint for exception exit.
    --
    l_msg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
    IF fnd_log.g_current_runtime_level <= wip_constants.trace_logging THEN
        wip_logger.exitPoint(
            p_procName => 'wip_close_priv.wip_close',
            p_procReturnStatus => x_returnStatus,
            p_msg => l_msg,
            x_returnStatus => l_return_status);
    END IF;

    COMMIT ;

END WIP_CLOSE ;

/* Wrapper function which will be called by the concurrent manager */

procedure WIP_CLOSE_MGR
(
      ERRBUF               OUT NOCOPY VARCHAR2 ,
      RETCODE              OUT NOCOPY VARCHAR2 ,
      p_organization_id     IN  NUMBER    ,
      p_class_type          IN  VARCHAR2  ,
      p_from_class          IN  VARCHAR2  ,
      p_to_class            IN  VARCHAR2  ,
      p_from_job            IN  VARCHAR2  ,
      p_to_job              IN  VARCHAR2  ,
      p_from_release_date   IN  VARCHAR2  ,
      p_to_release_date     IN  VARCHAR2  ,
      p_from_start_date     IN  VARCHAR2  ,
      p_to_start_date       IN  VARCHAR2  ,
      p_from_completion_date IN VARCHAR2  ,
      p_to_completion_date  IN  VARCHAR2  ,
      p_status              IN  VARCHAR2  ,
      p_group_id            IN  NUMBER  ,
      p_select_jobs         IN  NUMBER  ,
      p_exclude_reserved_jobs IN  VARCHAR2  ,
      p_uncompleted_jobs    IN VARCHAR2,
      p_exclude_pending_txn_jobs IN  VARCHAR2  ,
      p_report_type         IN  VARCHAR2 ,
      p_act_close_date      IN  VARCHAR2
)
IS
  l_returnstatus         VARCHAR2(1) ;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(200);
  l_warning               NUMBER;
BEGIN
  RETCODE := 0 ; -- success

WIP_CLOSE
(
      p_organization_id    => p_organization_id ,
      p_class_type         => p_class_type ,
      p_from_class         => p_from_class ,
      p_to_class           => p_to_class ,
      p_from_job           => p_from_job ,
      p_to_job             => p_to_job ,
      p_from_release_date  => p_from_release_date ,
      p_to_release_date    => p_to_release_date ,
      p_from_start_date    => p_from_start_date ,
      p_to_start_date      => p_to_start_date  ,
      p_from_completion_date => p_from_completion_date ,
      p_to_completion_date => p_to_completion_date ,
      p_status             => p_status  ,
      p_group_id           => p_group_id ,
      p_select_jobs        => p_select_jobs  ,
      p_exclude_reserved_jobs => p_exclude_reserved_jobs   ,
      p_uncompleted_jobs   => p_uncompleted_jobs ,
      p_exclude_pending_txn_jobs => p_exclude_pending_txn_jobs  ,
      p_report_type        => p_report_type ,
      p_act_close_date     => p_act_close_date  ,
      x_warning            => l_warning ,
      x_returnStatus	   => l_returnstatus
);

IF l_warning = 1 THEN
 retcode := 1 ; -- warning ;
 wip_utilities.get_message_stack(p_msg =>errbuf);
END IF ;

IF(l_returnStatus <> fnd_api.g_ret_sts_success) THEN
 retcode := 2; -- error
 wip_utilities.get_message_stack(p_msg =>errbuf);
END IF;

EXCEPTION
  WHEN others THEN
     retcode := 2; -- error
     errbuf := SQLERRM;

END WIP_CLOSE_MGR ;

END wip_jobclose_priv ;

/
