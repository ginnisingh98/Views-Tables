--------------------------------------------------------
--  DDL for Package Body WMS_LMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LMS_UTILS" AS
/* $Header: WMSLUTLB.pls 120.13.12010000.2 2008/08/19 09:54:39 anviswan ship $ */

g_version_printed BOOLEAN := FALSE;
g_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

PROCEDURE DEBUG(p_message IN VARCHAR2,
                 p_module   IN VARCHAR2 default 'abc',
                 p_level   IN VARCHAR2 DEFAULT 9) IS
BEGIN

 IF NOT g_version_printed THEN
   INV_TRX_UTIL_PUB.TRACE('$Header: WMSLUTLB.pls 120.13.12010000.2 2008/08/19 09:54:39 anviswan ship $',g_pkg_name, 9);
   g_version_printed := TRUE;
 END IF;

 INV_TRX_UTIL_PUB.TRACE( P_MESG =>P_MESSAGE
                        ,P_MOD => p_module
                        ,p_level => p_level
                        );
END DEBUG;


 FUNCTION ORG_LABOR_MGMT_ENABLED ( p_org_id IN NUMBER)
 RETURN BOOLEAN IS

 l_labor_enabled_flag VARCHAR2(1);
 l_labor_mgmt_enabled BOOLEAN;

 BEGIN

   l_labor_enabled_flag := NULL;

   IF g_debug=1 THEN
    debug('The value of p_org_id '|| p_org_id,'ORG_LABOR_MGMT_ENABLED');
   END IF;

   -- select from mtl_parameters table the values of wms_enabled
   -- and labor Mangement enabled flags

  SELECT labor_management_enabled_flag
  INTO   l_labor_enabled_flag
  FROM  mtl_parameters
  WHERE organization_id = p_org_id;

 --Check for the value of this flag and return true if the
 -- the flag is 'Y' and false otherwise

 IF (l_labor_enabled_flag ='Y' ) THEN
   l_labor_mgmt_enabled := TRUE;

  IF g_debug=1 THEN
   debug('Org Labor Management Enabled ','ORG_LABOR_MGMT_ENABLED');
  END IF;

 ELSE
   l_labor_mgmt_enabled := FALSE;


  IF g_debug=1 THEN
   debug('Org not Labor Management Enabled ','ORG_LABOR_MGMT_ENABLED');
  END IF;

 END IF;


 RETURN  l_labor_mgmt_enabled ;

 EXCEPTION
--handle exceptions
  WHEN OTHERS THEN

   IF g_debug=1 THEN
      debug('Came to the Exception','ORG_LABOR_MGMT_ENABLED');
   END IF;

   l_labor_mgmt_enabled := FALSE;
	RETURN  l_labor_mgmt_enabled ;

 END ORG_LABOR_MGMT_ENABLED;


FUNCTION ZONE_LABOR_MGMT_ENABLED ( p_org_id  IN NUMBER,
                                   p_zone_id IN NUMBER
                                  )
RETURN VARCHAR2 IS
  l_labor_enabled_flag VARCHAR2(1);
  --l_labor_mgmt_enabled NUMBER;

BEGIN
  l_labor_enabled_flag := NULL;

  IF g_debug=1 THEN
   debug('The value of p_org_id '|| p_org_id,'ZONE_LABOR_MGMT_ENABLED');
   debug('The value of p_zone_id '|| p_zone_id,'ZONE_LABOR_MGMT_ENABLED');
  END IF;


  -- select the labor enabled flag value for wms_zones_b table
  -- into the local variable

  SELECT labor_enabled
  INTO   l_labor_enabled_flag
  FROM   wms_zones_b
  WHERE  organization_id = p_org_id
  AND    zone_id         = p_zone_id;


 IF (l_labor_enabled_flag IS NULL ) THEN
   --l_labor_mgmt_enabled := TRUE;
    l_labor_enabled_flag :='N';
    IF g_debug=1 THEN
     debug('Zone not Labor Management Enabled ','ZONE_LABOR_MGMT_ENABLED');
    END IF;
 END IF;

 RETURN  l_labor_enabled_flag ;

EXCEPTION
--handle exceptions
  WHEN OTHERS THEN
    IF g_debug=1 THEN
      debug('Came to the Exception','ZONE_LABOR_MGMT_ENABLED');
    END IF;
    l_labor_enabled_flag := 'N';
	 RETURN  l_labor_enabled_flag ;

 END ZONE_LABOR_MGMT_ENABLED;



FUNCTION IS_USER_NON_TRACKED ( p_user_id IN NUMBER,
                               p_org_id  IN NUMBER )
RETURN BOOLEAN IS

l_user_id NUMBER;
BEGIN

   l_user_id := 0;

   IF g_debug=1 THEN
   debug('The value of user_id '|| p_user_id,'IS_USER_NON_TRACKED');
   END IF;

   --select from the WMS_ELS_NON_TRACKED_USERS and see that
   -- is the user_id has been defined as a phantom user or not.

   SELECT 1
   INTO l_user_id
   FROM WMS_ELS_NON_TRACKED_USERS
   WHERE USER_ID = P_USER_ID
   AND ORGANIZATION_ID= P_ORG_ID;

   -- A row is returned so return true(the user is a phantom user)

   RETURN TRUE;

   IF g_debug=1 THEN
   debug('The user is a non tracked user','IS_USER_NON_TRACKED');
   END IF;

   EXCEPTION
   --handle exceptions (the user is not a phantom user
   WHEN NO_DATA_FOUND THEN

   IF g_debug=1 THEN
   debug('No Data found Exception. So user is a tracked user','IS_USER_NON_TRACKED');
   END IF;

   RETURN FALSE;

   WHEN OTHERS THEN

   IF g_debug=1 THEN
   debug('In Exception','IS_USER_NON_TRACKED');
   END IF;

   RETURN FALSE;

END IS_USER_NON_TRACKED;



PROCEDURE PURGE_LMS_SETUP_HISTORY
                                  (errbuf               OUT    NOCOPY VARCHAR2,
                                   retcode              OUT    NOCOPY NUMBER,
                                   p_org_id             IN     NUMBER,
                                   p_purge_date         IN     VARCHAR2
                                   )
IS

   CURSOR els_history(l_org_id NUMBER,l_purge_date VARCHAR2) IS SELECT els_data_id
   FROM wms_els_individual_tasks_b
   WHERE history_flag = 1
   AND organization_id = l_org_id
   AND archive_date <= NVL (TO_DATE(l_purge_date,'YYYY/MM/DD HH24:MI:SS') ,SYSDATE);

   TYPE els_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   l_els_id_tab els_id_tab;
   --l_limit NUMBER;
   l_records_deleted NUMBER;
   l_ret BOOLEAN;
   l_message VARCHAR2(250);

  BEGIN

   SAVEPOINT purge_lms_history;

   l_records_deleted :=0;

   IF g_debug=1 THEN
   debug('The value of organization Id '|| p_org_id,'PURGE_LMS_SETUP_HISTORY');
   END IF;

   -- Only have to proceed when the org_id being passed is not NULL

   IF (p_org_id IS NOT NULL) THEN

        LOOP
         OPEN els_history(p_org_id,p_purge_date);

         FETCH els_history bulk collect INTO l_els_id_tab;
         EXIT WHEN els_history%NOTFOUND;
         END LOOP;

		 CLOSE els_history;

         --delete all records in wms_lab_trx_src table which have els_data_id
         -- costed against them

         FORALL i IN l_els_id_tab.first..l_els_id_tab.last

         DELETE wms_els_trx_src
         WHERE els_data_id = l_els_id_tab(i);

		   l_records_deleted :=SQL%ROWCOUNT;

         IF g_debug=1 THEN
          debug('Number of records deleted from wms_els_trx_src table '|| l_records_deleted,
                'PURGE_LMS_SETUP_HISTORY'
               );
         END IF;

         l_records_deleted:=0;

         -- delete all records from ems_els_individual_tasks table which have
         -- been marked as hsitory

         FORALL j IN l_els_id_tab.first..l_els_id_tab.last

         DELETE wms_els_individual_tasks_b
         WHERE els_data_id = l_els_id_tab(j);

         l_records_deleted :=SQL%ROWCOUNT;

         IF g_debug=1 THEN
          debug('Number of records deleted from wms_els_individual_tasks_b table '|| l_records_deleted,
                'PURGE_LMS_SETUP_HISTORY'
               );
         END IF;

         l_records_deleted:=0;

         FORALL k IN l_els_id_tab.first..l_els_id_tab.last

         DELETE wms_els_individual_tasks_tl
         WHERE els_data_id = l_els_id_tab(k);

         l_records_deleted :=SQL%ROWCOUNT;

         IF g_debug=1 THEN
          debug('Number of records deleted from wms_els_individual_tasks_tl table '|| l_records_deleted,
                'PURGE_LMS_SETUP_HISTORY'
               );
         END IF;

        IF g_debug=1 THEN
          debug('Purge Successfully completed' ,
                'PURGE_LMS_SETUP_HISTORY'
               );
         END IF;

        retcode := 1;
        fnd_message.set_name('WMS', 'WMS_LMS_PURGE_HIST_SUCCESS');
        l_message := fnd_message.get;
        l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);

   ELSE

     IF g_debug=1 THEN
       debug('Org Id being passed is null' ,
             'PURGE_LMS_SETUP_HISTORY'
            );
     END IF;

     retcode := 2;
     fnd_message.set_name('WMS', 'WMS_LMS_REQ_PARAM_NULL');
     l_message := fnd_message.get;
     l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
   END IF;


  EXCEPTION
  WHEN OTHERS THEN
     IF g_debug=1 THEN
       debug('Exception has occured during purge'||SQLERRM ,
             'PURGE_LMS_SETUP_HISTORY'
            );
     END IF;
     ROLLBACK TO purge_lms_history;
     retcode := 2;
     fnd_message.set_name('WMS', 'WMS_LMS_PURGE_HIST_ERROR');
     l_message := fnd_message.get;
     l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

  END PURGE_LMS_SETUP_HISTORY;


PROCEDURE BUCKET_ACTUAL_TIMINGS  (  x_return_status     OUT NOCOPY VARCHAR2
                                  , x_msg_count         OUT NOCOPY VARCHAR2
                                  , x_msg_data          OUT NOCOPY VARCHAR2
                                  , p_org_id            IN  NUMBER
                                  , p_purge_date        IN  DATE
                                 )IS
 l_records_inserted NUMBER;
BEGIN
 l_records_inserted :=0;
   IF g_debug=1 THEN
   debug('The value of organization Id '|| p_org_id,'BUCKET_ACTUAL_TIMINGS');
   debug('The value of purge date is   '|| p_purge_date,'BUCKET_ACTUAL_TIMINGS');
   END IF;

   --select the summary row from the table and insert into the table

  INSERT INTO WMS_ELS_TRX_SRC
             (els_trx_src_id,
              els_data_id,
              organization_id,
              travel_time,
              transaction_time,
              idle_time,
			  last_update_date,
			  last_updated_by,
			  created_by,
			  creation_date
              )
            SELECT WMS_ELS_TRX_SRC_S.NEXTVAL,
                   els_data_id,
                   organization_id,
                   travel_time,
                   transaction_time,
                   idle_time,
				   SYSDATE,
				   FND_GLOBAL.USER_ID,
				   FND_GLOBAL.USER_ID,
				   SYSDATE
            FROM
                 (SELECT ELS_DATA_ID els_data_id,
				         organization_id,
                         AVG(TRAVEL_TIME) travel_time,
                         AVG(TRANSACTION_TIME) transaction_time,
                         AVG(IDLE_TIME) Idle_time
                         FROM WMS_ELS_TRX_SRC
                         WHERE  transaction_date < p_purge_date
                         AND    organization_id = p_org_id
                         AND    els_data_id IS NOT NULL
                         GROUP BY ELS_DATA_ID,organization_id
                   );

 l_records_inserted := SQL%ROWCOUNT;

 IF g_debug=1 THEN
   debug( 'The process of bucketing the transaction records is a success'
         ,'BUCKET_ACTUAL_TIMINGS');
    debug( 'The number of bucketed records inserted are '||  l_records_inserted
         ,'BUCKET_ACTUAL_TIMINGS');
 END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
IF g_debug=1 THEN
   debug( 'The process of bucketing the transaction records is a failure'
         ,'BUCKET_ACTUAL_TIMINGS');
 END IF;

x_return_status := FND_API.G_RET_STS_ERROR;

END BUCKET_ACTUAL_TIMINGS;




 PROCEDURE PURGE_LMS_TRANSACTIONS
    (errbuf               OUT    NOCOPY VARCHAR2,
     retcode              OUT    NOCOPY NUMBER,
     p_org_id             IN     NUMBER,
     p_purge_date         IN     VARCHAR2
     )
    IS
     l_records_deleted NUMBER;
     l_ret BOOLEAN;
     l_message VARCHAR2(250);
     l_return_status VARCHAR2(1);
     l_msg_count VARCHAR2(10);
     l_msg_data VARCHAR2(100);
 BEGIN

   l_records_deleted := 0;

   SAVEPOINT purge_lms_txns;

   IF g_debug=1 THEN
   debug('The value of organization Id '|| p_org_id,'PURGE_LMS_TRANSACTIONS');
   debug('The value of purge date is   '|| p_purge_date,'PURGE_LMS_TRANSACTIONS');
   END IF;


    IF (p_org_id IS NOT NULL) THEN
    -- proceed only when the mandatory parameters are passed

    -- First bucket the actual timings to be later used if the option
    -- for calculating the actual values for the time components when
    -- moving avaerage value is 'ALL'

     IF g_debug=1 THEN
      debug('Before calling Bucket_actual_timings ','PURGE_LMS_TRANSACTIONS');
     END IF;

       WMS_LMS_UTILS.BUCKET_ACTUAL_TIMINGS ( x_return_status  => l_return_status
                                           , x_msg_count      => l_msg_count
                                           , x_msg_data       => l_msg_data
                                           , p_org_id         => p_org_id
                                           , p_purge_date     => TO_DATE(p_purge_date,'YYYY/MM/DD HH24:MI:SS')
                                           );


       IF(l_return_status = FND_API.g_ret_sts_success )THEN
          -- If success then only proceed with the purging

        IF g_debug=1 THEN
         debug( 'Call to Bucket_actual_timings is a success now deleting '
               ,'PURGE_LMS_TRANSACTIONS'
              );
        END IF;

          DELETE wms_els_trx_src
            WHERE transaction_date <= NVL(TO_DATE(p_purge_date,'YYYY/MM/DD HH24:MI:SS'),SYSDATE)
            AND   organization_id = p_org_id;

          l_records_deleted :=SQL%ROWCOUNT;
          -- set the appropiate return code and status

          IF g_debug=1 THEN
          debug( 'Number of rows deleted'|| l_records_deleted
               ,'PURGE_LMS_TRANSACTIONS'
               );
         END IF;

          retcode := 1;
          fnd_message.set_name('WMS', 'WMS_LMS_PURGE_TXNS_SUCCESS');
          l_message := fnd_message.get;
          l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);

       ELSE -- call to bucket actual timings is not a success

          IF g_debug=1 THEN
           debug( 'Call to Bucket_actual_timings is not a success '
                 ,'PURGE_LMS_TRANSACTIONS'
                );
          END IF;

          retcode := 2;
          fnd_message.set_name('WMS', 'WMS_LMS_PURGE_TXNS_ERROR');
          l_message := fnd_message.get;
          l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

          ROLLBACK TO purge_lms_txns;

       END IF;

    ELSE
       -- When the required parameters not passed

     IF g_debug=1 THEN
      debug( 'Required parameters not passed '
            ,'PURGE_LMS_TRANSACTIONS'
           );
     END IF;

     retcode := 2;
     fnd_message.set_name('WMS', 'WMS_LMS_REQ_PARAM_NULL');
     l_message := fnd_message.get;
     l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

    END IF; -- when required parameters passed


 EXCEPTION
     WHEN OTHERS THEN
     IF g_debug=1 THEN
      debug( 'Exception has occured'
            ,'PURGE_LMS_TRANSACTIONS'
           );
     END IF;
     ROLLBACK TO purge_lms_txns;
     retcode := 2;
     fnd_message.set_name('WMS', 'WMS_LMS_PURGE_TXNS_ERROR');
     l_message := fnd_message.get;
     l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

 END PURGE_LMS_TRANSACTIONS;



PROCEDURE COPY_ACTUAL_TIMINGS      (   errbuf               OUT    NOCOPY VARCHAR2
                                      , retcode              OUT    NOCOPY NUMBER
                      	              , p_org_id             IN            NUMBER
                                    ) IS
 l_records_updated NUMBER;
 l_error           NUMBER;
 l_ret BOOLEAN;
 l_message VARCHAR2(250);

 /* The following cursor has been created to fetch the non-history els data records
  * so that the values will be used to create the history records while executing
  * the "Standardize Actual to Expected times" request.
  */

 CURSOR els_individual_tasks_cur(l_org_id NUMBER) IS
   SELECT ELS_DATA_ID
        , ORGANIZATION_ID
        , SEQUENCE_NUMBER
        , ANALYSIS_ID
        , ACTIVITY_ID
        , ACTIVITY_DETAIL_ID
        , OPERATION_ID
        , EQUIPMENT_ID
        , SOURCE_ZONE_ID
        , SOURCE_SUBINVENTORY
        , DESTINATION_ZONE_ID
        , DESTINATION_SUBINVENTORY
        , LABOR_TXN_SOURCE_ID
        , TRANSACTION_UOM
        , FROM_QUANTITY
        , TO_QUANTITY
        , ITEM_CATEGORY_ID
        , OPERATION_PLAN_ID
        , GROUP_ID
        , TASK_TYPE_ID
        , TASK_METHOD_ID
        , EXPECTED_TRAVEL_TIME
        , EXPECTED_TXN_TIME
        , EXPECTED_IDLE_TIME
        , ACTUAL_TRAVEL_TIME
        , ACTUAL_TXN_TIME
        , ACTUAL_IDLE_TIME
        , TRAVEL_TIME_THRESHOLD
        , ARCHIVE_DATE
        , NUM_TRX_MATCHED
        , ATTRIBUTE_CATEGORY
        , ATTRIBUTE1
        , ATTRIBUTE2
        , ATTRIBUTE3
        , ATTRIBUTE4
        , ATTRIBUTE5
        , ATTRIBUTE6
        , ATTRIBUTE7
        , ATTRIBUTE8
        , ATTRIBUTE9
        , ATTRIBUTE10
        , ATTRIBUTE12
        , ATTRIBUTE13
        , ATTRIBUTE14
        , ATTRIBUTE15
    FROM wms_els_individual_tasks_b
   WHERE organization_id= l_org_id
     AND nvl(HISTORY_FLAG, -999) <> 1;

 /*  The following cursor has been added to fetch the records from TL table
  *  for each els_data_id that is present in the base table.
  */

 CURSOR els_individual_tasks_tl_cur(l_els_data_id NUMBER) IS
   SELECT description
        , language
        , source_lang
     FROM wms_els_individual_tasks_tl
    WHERE els_data_id = l_els_data_id;

 l_new_els_data_id NUMBER;

BEGIN

l_records_updated:=0;
l_error := 0;

IF g_debug=1 THEN
debug('The value of organization Id '|| p_org_id,'COPY_ACTUAL_TIMINGS');
END IF;

BEGIN
  /* Start of fix for bug # 5520074
   * The following code has been added to maintain the history records while executing
   * "Standardize Actual to Expected Times" request
   */
   IF g_debug=1 THEN
     debug('Before creating History Records' , 'COPY_ACTUAL_TIMINGS');
   END IF;

   FOR els_individual_tasks_rec IN els_individual_tasks_cur(p_org_id) LOOP

     SELECT WMS_ELS_INDIVIDUAL_TASKS_S.NEXTVAL
       INTO l_new_els_data_id
       FROM dual;

     INSERT INTO wms_els_individual_tasks_b (
                 ELS_DATA_ID
               , ORGANIZATION_ID
               , SEQUENCE_NUMBER
               , ANALYSIS_ID
               , ACTIVITY_ID
               , ACTIVITY_DETAIL_ID
               , OPERATION_ID
               , EQUIPMENT_ID
               , SOURCE_ZONE_ID
               , SOURCE_SUBINVENTORY
               , DESTINATION_ZONE_ID
               , DESTINATION_SUBINVENTORY
               , LABOR_TXN_SOURCE_ID
               , TRANSACTION_UOM
               , FROM_QUANTITY
               , TO_QUANTITY
               , ITEM_CATEGORY_ID
               , OPERATION_PLAN_ID
               , GROUP_ID
               , TASK_TYPE_ID
               , TASK_METHOD_ID
               , EXPECTED_TRAVEL_TIME
               , EXPECTED_TXN_TIME
               , EXPECTED_IDLE_TIME
               , ACTUAL_TRAVEL_TIME
               , ACTUAL_TXN_TIME
               , ACTUAL_IDLE_TIME
               , TRAVEL_TIME_THRESHOLD
               , HISTORY_FLAG
               , ARCHIVE_DATE
               , NUM_TRX_MATCHED
               , LAST_UPDATED_BY
               , LAST_UPDATE_LOGIN
               , CREATED_BY
               , CREATION_DATE
               , LAST_UPDATE_DATE
               , ATTRIBUTE_CATEGORY
               , ATTRIBUTE1
               , ATTRIBUTE2
               , ATTRIBUTE3
               , ATTRIBUTE4
               , ATTRIBUTE5
               , ATTRIBUTE6
               , ATTRIBUTE7
               , ATTRIBUTE8
               , ATTRIBUTE9
               , ATTRIBUTE10
               , ATTRIBUTE12
               , ATTRIBUTE13
               , ATTRIBUTE14
               , ATTRIBUTE15)
        VALUES ( l_new_els_data_id
               , els_individual_tasks_rec.ORGANIZATION_ID
               , els_individual_tasks_rec.SEQUENCE_NUMBER
               , els_individual_tasks_rec.ANALYSIS_ID
               , els_individual_tasks_rec.ACTIVITY_ID
               , els_individual_tasks_rec.ACTIVITY_DETAIL_ID
               , els_individual_tasks_rec.OPERATION_ID
               , els_individual_tasks_rec.EQUIPMENT_ID
               , els_individual_tasks_rec.SOURCE_ZONE_ID
               , els_individual_tasks_rec.SOURCE_SUBINVENTORY
               , els_individual_tasks_rec.DESTINATION_ZONE_ID
               , els_individual_tasks_rec.DESTINATION_SUBINVENTORY
               , els_individual_tasks_rec.LABOR_TXN_SOURCE_ID
               , els_individual_tasks_rec.TRANSACTION_UOM
               , els_individual_tasks_rec.FROM_QUANTITY
               , els_individual_tasks_rec.TO_QUANTITY
               , els_individual_tasks_rec.ITEM_CATEGORY_ID
               , els_individual_tasks_rec.OPERATION_PLAN_ID
               , els_individual_tasks_rec.GROUP_ID
               , els_individual_tasks_rec.TASK_TYPE_ID
               , els_individual_tasks_rec.TASK_METHOD_ID
               , els_individual_tasks_rec.EXPECTED_TRAVEL_TIME
               , els_individual_tasks_rec.EXPECTED_TXN_TIME
               , els_individual_tasks_rec.EXPECTED_IDLE_TIME
               , els_individual_tasks_rec.ACTUAL_TRAVEL_TIME
               , els_individual_tasks_rec.ACTUAL_TXN_TIME
               , els_individual_tasks_rec.ACTUAL_IDLE_TIME
               , els_individual_tasks_rec.TRAVEL_TIME_THRESHOLD
               , 1  -- The new record created will be a history record. Hence, it takes the values as 1.
               , SYSDATE   -- ARCHIVE_DATE
               , els_individual_tasks_rec.NUM_TRX_MATCHED
				   , FND_GLOBAL.USER_ID
				   , FND_GLOBAL.LOGIN_ID
				   , FND_GLOBAL.USER_ID
				   , SYSDATE
               , SYSDATE
               , els_individual_tasks_rec.ATTRIBUTE_CATEGORY
               , els_individual_tasks_rec.ATTRIBUTE1
               , els_individual_tasks_rec.ATTRIBUTE2
               , els_individual_tasks_rec.ATTRIBUTE3
               , els_individual_tasks_rec.ATTRIBUTE4
               , els_individual_tasks_rec.ATTRIBUTE5
               , els_individual_tasks_rec.ATTRIBUTE6
               , els_individual_tasks_rec.ATTRIBUTE7
               , els_individual_tasks_rec.ATTRIBUTE8
               , els_individual_tasks_rec.ATTRIBUTE9
               , els_individual_tasks_rec.ATTRIBUTE10
               , els_individual_tasks_rec.ATTRIBUTE12
               , els_individual_tasks_rec.ATTRIBUTE13
               , els_individual_tasks_rec.ATTRIBUTE14
               , els_individual_tasks_rec.ATTRIBUTE15);

     /* Insert the history record data in TL tables*/
     FOR els_individual_tasks_tl_rec IN els_individual_tasks_tl_cur(els_individual_tasks_rec.els_data_id) LOOP
       INSERT INTO wms_els_individual_tasks_tl(
                   ELS_DATA_ID
                 , LANGUAGE
                 , SOURCE_LANG
                 , DESCRIPTION
                 , LAST_UPDATED_BY
                 , LAST_UPDATE_LOGIN
                 , CREATED_BY
                 , CREATION_DATE
                 , LAST_UPDATE_DATE)
           VALUES( l_new_els_data_id
                 , els_individual_tasks_tl_rec.language
                 , els_individual_tasks_tl_rec.source_lang
                 , els_individual_tasks_tl_rec.description
                 , FND_GLOBAL.USER_ID
  				     , FND_GLOBAL.LOGIN_ID
				     , FND_GLOBAL.USER_ID
				     , SYSDATE
                 , SYSDATE);
     END LOOP;
   END LOOP;

   IF g_debug=1 THEN
     debug('After creating History Records' , 'COPY_ACTUAL_TIMINGS');
   END IF;

  /* End of fix for bug # 5520074 */

--update the expected value fields with the actual values.
UPDATE wms_els_individual_tasks_b
SET
Expected_Travel_Time = NVL(Actual_Travel_time,Expected_Travel_Time),
Expected_Txn_Time    = NVL(Actual_Txn_Time,Expected_Txn_Time),
Expected_Idle_Time   = NVL(Actual_Idle_Time,Expected_Idle_Time),
NUM_TRX_MATCHED      = NULL,                -- Added for bug # 5520074
LAST_UPDATED_BY      = FND_GLOBAL.USER_ID,  -- Added for bug # 5520074
LAST_UPDATE_LOGIN    = FND_GLOBAL.LOGIN_ID, -- Added for bug # 5520074
LAST_UPDATE_DATE     = SYSDATE              -- Added for bug # 5520074
WHERE
organization_id= p_org_id
AND history_flag IS NULL;


l_records_updated := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug( 'The process of copying actual timings is a success for individula and manual data'
      ,'COPY_ACTUAL_TIMINGS');
debug( 'The number of setup records where expectyed timing has been copied are '|| l_records_updated
      ,'COPY_ACTUAL_TIMINGS');
END IF;

EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug('Error in copying timings for Individual and manual tasks','CALCULATE_ACTUAL_TIMINGS');
END IF;

l_error := l_error + 1 ;
END;

--reinitialize this to 0 for getting the rowcount for next update statement

l_records_updated := 0;


BEGIN
--update the expected value fields with the actual values.
UPDATE wms_els_grouped_tasks_b
SET
Expected_Travel_Time = NVL(Actual_Travel_time,Expected_Travel_Time)
WHERE
organization_id= p_org_id;

l_records_updated := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug( 'The process of copying actual timings is a success for grouped data '
      ,'COPY_ACTUAL_TIMINGS');
debug( 'The number of setup records where expected timing has been copied are '|| l_records_updated
      ,'COPY_ACTUAL_TIMINGS');
END IF;

EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug(' Error in copying timings for Grpouped tasks','CALCULATE_ACTUAL_TIMINGS');
END IF;

l_error := l_error+ 1 ;
END;


IF l_error = 0 THEN
 retcode := 1;
 fnd_message.set_name('WMS', 'WMS_LMS_COPY_TIMINGS_SUCCESS');
 l_message := fnd_message.get;
 l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);

ELSIF l_error =2 THEN
 retcode := 2;
 fnd_message.set_name('WMS', 'WMS_LMS_COPY_TIMINGS_ERROR');
 l_message := fnd_message.get;
 l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

ELSE
 retcode := 3;
 fnd_message.set_name('WMS', 'WMS_LMS_COPY_TIMINGS_WARN');
 l_message := fnd_message.get;
 l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARN',l_message);
END IF;



EXCEPTION
 WHEN OTHERS THEN
    IF g_debug=1 THEN
    debug( 'Unexpected Exception occured while updating actuial timings'
      ,'COPY_ACTUAL_TIMINGS');
    END IF;

 retcode := 2;
 fnd_message.set_name('WMS', 'WMS_LMS_COPY_TIMINGS_ERROR');
 l_message := fnd_message.get;
 l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

END COPY_ACTUAL_TIMINGS;



PROCEDURE CALCULATE_ACTUAL_TIMINGS  (   errbuf               OUT    NOCOPY VARCHAR2
                                      , retcode              OUT    NOCOPY NUMBER
                      	              , p_org_id             IN            NUMBER
                                    ) IS


CURSOR C_ELS_DATA_ID (l_organization_id NUMBER) IS
SELECT els_data_id FROM WMS_ELS_INDIVIDUAL_TASKS_B WHERE
organization_id=l_organization_id
and history_flag IS NULL;

-- Ignore history rows

l_date DATE;

TYPE els_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_els_data_id_tab els_id_tab;

l_include_bucket BOOLEAN;

l_time_frame_average_id NUMBER;

l_records_updated NUMBER;

l_ret BOOLEAN;
l_message VARCHAR2(250);

BEGIN

l_date:= NULL;
l_include_bucket := FALSE;
l_time_frame_average_id := NULL;



IF g_debug=1 THEN
debug('The value of organization Id '|| p_org_id,'CALCULATE_ACTUAL_TIMINGS');
END IF;


IF (p_org_id IS NOT NULL) THEN

BEGIN
--Get the global setup variable

SELECT time_frame_average_id INTO l_time_frame_average_id
FROM WMS_ELS_PARAMETERS WHERE organization_id = p_org_id;

IF g_debug=1 THEN
debug('The value of time frame id '|| l_time_frame_average_id,'CALCULATE_ACTUAL_TIMINGS');
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN

IF g_debug=1 THEN
debug('The value of time frame id is NULL Cant Proceed','CALCULATE_ACTUAL_TIMINGS');
END IF;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_LMS_TIME_FRAME_NULL');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
RETURN;
END;

-- Set the local variable l_from_date depending on the
-- Time_frame_average_id from WMS_ELS_GLOBAL_DATA

IF l_time_frame_average_id =1 THEN
-- If the time frame in global setup data is 30 days
l_date:= (trunc(SYSDATE) - 30);

   IF g_debug=1 THEN
   debug( 'Time frame is 30 days.The value of l_date ' || to_CHAR(l_date,'DD-MON-YYYY HH24:MI:SS')
         ,'CALCULATE_ACTUAL_TIMINGS');
   END IF;

ELSIF l_time_frame_average_id =2 THEN
-- If the time frame in global setup data is 6 months
l_date:= ADD_MONTHS(trunc(SYSDATE),-6);

   IF g_debug=1 THEN
   debug( 'Time frame is 6 months.The value of l_date ' || to_CHAR(l_date,'DD-MON-YYYY HH24:MI:SS')
         ,'CALCULATE_ACTUAL_TIMINGS');
   END IF;

END IF;


OPEN C_ELS_DATA_ID (p_org_id);
--Open the cursor
LOOP

FETCH   C_ELS_DATA_ID
BULK COLLECT
INTO l_els_data_id_tab;

EXIT WHEN C_ELS_DATA_ID%NOTFOUND;

END LOOP;

l_records_updated := 0;
--Exit till the records exist and bulk fetch to a table type


FORALL i IN l_els_data_id_tab.first .. l_els_data_id_tab.last
--Bulk update the els data table with actual timings.
--Bulk update is used here for performance enhancement resons.

UPDATE wms_els_individual_tasks_b SET
actual_travel_time=(
              SELECT AVG(travel_time) FROM WMS_ELS_TRX_SRC
              WHERE els_data_id=l_els_data_id_tab(i)
              AND NVL(Transaction_Date,SYSDATE) >= NVL(l_date,SYSDATE)
              AND (
                    (l_time_frame_average_id =3)
                    OR ((l_time_frame_average_id <> 3 ) AND (TRANSACTION_DATE IS NOT NULL))
                   )
                   ),
actual_txn_time =(
              SELECT AVG(Transaction_time) FROM WMS_ELS_TRX_SRC
              WHERE els_data_id=l_els_data_id_tab(i)
              AND NVL(Transaction_Date,SYSDATE) >= NVL(l_date,SYSDATE)
              AND (
                    (l_time_frame_average_id =3)
                    OR ((l_time_frame_average_id <> 3 ) AND (TRANSACTION_DATE IS NOT NULL))
                   )
                   ),
actual_idle_time=(
              SELECT AVG(idle_time) FROM WMS_ELS_TRX_SRC
              WHERE els_data_id=l_els_data_id_tab(i)
              AND NVL(Transaction_Date,SYSDATE) >= NVL(l_date,SYSDATE)
              AND (
                    (l_time_frame_average_id =3)
                    OR ((l_time_frame_average_id <> 3 ) AND (TRANSACTION_DATE IS NOT NULL))
                   )
                   )
WHERE els_data_id = l_els_data_id_tab(i);

l_records_updated := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug('Number of records updated'||l_records_updated ,'CALCULATE_ACTUAL_TIMINGS');
END IF;

CLOSE C_ELS_DATA_ID;

IF g_debug=1 THEN
debug('Calculate actual timings is a success','CALCULATE_ACTUAL_TIMINGS');
END IF;

retcode := 1;
fnd_message.set_name('WMS', 'WMS_LMS_CAL_ACTUALS_SUCCESS');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);

ELSE -- if org id is not passed

IF g_debug=1 THEN
debug('No org Id passed so error out','CALCULATE_ACTUAL_TIMINGS');
END IF;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_LMS_REQ_PARAM_NULL');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

END IF;

EXCEPTION
--Handle exceptions.

WHEN OTHERS THEN

IF g_debug=1 THEN
debug('Exception has occured','CALCULATE_ACTUAL_TIMINGS');
END IF;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_LMS_CAL_ACTUALS_ERROR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

--close the cursor if it is open

IF C_ELS_DATA_ID%isopen THEN
CLOSE C_ELS_DATA_ID;
END IF;

END CALCULATE_ACTUAL_TIMINGS;


FUNCTION unprocessed_rows_remaining ( p_org_id NUMBER )
RETURN NUMBER IS
is_unprocessed NUMBER;
BEGIN

select 1 into is_unprocessed from dual where exists (select 1 from wms_els_exp_resource
                                 where els_data_id IS NULL and organization_id = p_org_id
								 );
RETURN 1;

EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN 2;
END unprocessed_rows_remaining;


FUNCTION unprocessed_rows_remaining ( p_org_id NUMBER,
                                      p_max_id NUMBER  )
RETURN NUMBER IS
is_unprocessed NUMBER;
BEGIN

select 1 into is_unprocessed from dual where exists (select 1 from wms_els_trx_src
                                 where    els_data_id IS NULL
								      and organization_id =  p_org_id
									  and els_trx_src_id  <= p_max_id
								 );
RETURN 1;

EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN 2;
END unprocessed_rows_remaining;


FUNCTION get_parameter_string(p_concurrent_program_id IN NUMBER,
                              p_org_id IN NUMBER)
RETURN VARCHAR2 IS

	l_message_text     VARCHAR2(100);
	l_argument2        VARCHAR2(240);
	l_argument3        VARCHAR2(240);
	l_argument4        VARCHAR2(240);
	l_argument5        VARCHAR2(240);
    l_meaning           VARCHAR2(240);

	BEGIN
	l_message_text := NULL;

   IF g_debug=1 THEN
    debug('Organization Id is '|| p_org_id,'get_parameter_string');
	 debug('p_concurrent_program_id is '|| p_concurrent_program_id,'get_parameter_string');
   END IF;

	--argument 2 = data period unit
	--argument 3 = data period value
	--argument 4 = number of hrs per day
	--argument 5 = utilization rate

 	select ARGUMENT2,ARGUMENT3,
	       ARGUMENT4,ARGUMENT5
	into   l_argument2,l_argument3,
	       l_argument4,l_argument5
   from fnd_concurrent_requests where argument1 = to_char(p_org_id)
   and  request_id = (select Max(Request_ID)
                     From Fnd_Concurrent_Requests
                     Where Concurrent_Program_ID  = p_concurrent_program_id
					 AND PHASE_CODE = 'C' and argument1 = to_char(p_org_id)); -- added this condition for bug 5478746

   IF g_debug=1 THEN
    debug('Argument2 = '|| l_argument2,'get_parameter_string');
    debug('Argument3 = '|| l_argument3,'get_parameter_string');
    debug('Argument4 = '|| l_argument4,'get_parameter_string');
    debug('Argument5 = '|| l_argument5,'get_parameter_string');
   END IF;


   -- Format of the message text is as follows
   -- Data Period= TOKEN1 TOKEN2 ,No. Of Working Hrs/day=TOKEN3, Utilization Rate=TOKEN4%


	select meaning into l_meaning from mfg_lookups where lookup_code = l_argument2
	and lookup_type =  'WMS_ELS_FUTURE_PERIOD';

   IF g_debug=1 THEN
      debug('Data period Unit from lookup = '|| l_meaning,'get_parameter_string');
   END IF;


    FND_MESSAGE.SET_NAME('WMS', 'WMS_LMS_REPORT_PARAMS');
    FND_MESSAGE.SET_TOKEN('TOKEN1',l_argument3);
    FND_MESSAGE.SET_TOKEN('TOKEN2',l_meaning);
	 FND_MESSAGE.SET_TOKEN('TOKEN3',l_argument4);
    FND_MESSAGE.SET_TOKEN('TOKEN4',l_argument5);

    l_message_text := FND_MESSAGE.GET;

   IF g_debug=1 THEN
    debug('Final Message text = '|| l_message_text,'get_parameter_string');
   END IF;

	RETURN l_message_text;

	EXCEPTION
	-- do normal EXCPETION HANDLING

	WHEN OTHERS THEN
   IF g_debug=1 THEN
    debug('In Exception Block','get_parameter_string');
   END IF;
	l_message_text := NULL;
	return l_message_text;

END get_parameter_string;


FUNCTION get_next_scheduled_time ( p_concurrent_program_id IN NUMBER,
	                               p_application_id        IN NUMBER,
								          p_org_id                IN NUMBER
                                 )
	 return VARCHAR2 IS

	 l_next_scheduled_date DATE;
	 l_message VARCHAR2(100);

	 BEGIN

	 l_next_scheduled_date:= NULL;

	 select min(requested_start_date) into l_next_scheduled_date
	 from  fnd_concurrent_requests
	 where concurrent_program_id = p_concurrent_program_id
	 and program_application_id = p_application_id
     and phase_code = 'P'
	 and STATUS_CODE IN ( 'I','Q')
	 and argument1 = to_char(p_org_id);

	 IF ( l_next_scheduled_date IS  NULL) THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_LMS_NOT_SCHEDULED');

     l_message := FND_MESSAGE.GET;

	 RETURN l_message;

	 END IF;

    IF g_debug=1 THEN
    debug('Server time zone code is '||fnd_date.server_timezone_code,'get_parameter_string');
    debug('Client time zone code is '||fnd_date.client_timezone_code,'get_parameter_string');
    END IF;

    l_next_scheduled_date := fnd_date.adjust_datetime( l_next_scheduled_date
                                    ,fnd_date.server_timezone_code
                                    ,fnd_date.client_timezone_code);


	 RETURN to_char(l_next_scheduled_date ,'DD-MON-YYYY HH24:MI:SS');

END get_next_scheduled_time;



FUNCTION last_run_time (  p_concurrent_program_id IN NUMBER,
                           p_org_id IN NUMBER
					     )
RETURN VARCHAR2 IS
l_actual_completion_date DATE;
l_message VARCHAR2(100);

BEGIN
l_actual_completion_date := NULL;

 IF g_debug=1 THEN
    debug('Organization Id is '|| p_org_id,'get_parameter_string');
    debug('p_concurrent_program_id is '|| p_concurrent_program_id,'get_parameter_string');
 END IF;


    select   actual_completion_date
	into     l_actual_completion_date
    from fnd_concurrent_requests where argument1 = to_char(p_org_id)
    and  request_id = (select Max(Request_ID)
                     From Fnd_Concurrent_Requests
                     Where Concurrent_Program_ID  = p_concurrent_program_id
					 AND PHASE_CODE = 'C'
					 and argument1 = to_char(p_org_id)); -- added this condition for bug 5478746


   IF g_debug=1 THEN
    debug('Server time zone code is '||fnd_date.server_timezone_code,'get_parameter_string');
    debug('Client time zone code is '||fnd_date.client_timezone_code,'get_parameter_string');
   END IF;

 l_actual_completion_date := fnd_date.adjust_datetime( l_actual_completion_date
                                    ,fnd_date.server_timezone_code
                                    ,fnd_date.client_timezone_code);

RETURN to_char(l_actual_completion_date,'DD-MON-YYYY HH24:MI:SS');

EXCEPTION
WHEN NO_DATA_FOUND THEN

 FND_MESSAGE.SET_NAME('WMS', 'WMS_LMS_NOT_RUN');
 l_message:= FND_MESSAGE.GET;
 RETURN  l_message;

END last_run_time;

FUNCTION last_run_time_success (  p_concurrent_program_id IN NUMBER,
                                  p_org_id IN NUMBER
					           )
RETURN VARCHAR2 IS
l_actual_completion_date DATE;
l_message VARCHAR2(100);

BEGIN
l_actual_completion_date := NULL;

 IF g_debug=1 THEN
    debug('Organization Id is '|| p_org_id,'get_parameter_string');
    debug('p_concurrent_program_id is '|| p_concurrent_program_id,'get_parameter_string');
 END IF;


    select   actual_completion_date
	into     l_actual_completion_date
    from fnd_concurrent_requests where argument1 = to_char(p_org_id)
    and  request_id = (select Max(Request_ID)
                     From Fnd_Concurrent_Requests
                     Where Concurrent_Program_ID  = p_concurrent_program_id
					 AND PHASE_CODE = 'C'
					 AND STATUS_CODE = 'C'
					 and argument1 = to_char(p_org_id)); -- added this condition for bug 5478746


        IF g_debug=1 THEN
    debug('Server time zone code is '||fnd_date.server_timezone_code,'get_parameter_string');
    debug('Client time zone code is '||fnd_date.client_timezone_code,'get_parameter_string');
    END IF;
l_actual_completion_date := fnd_date.adjust_datetime( l_actual_completion_date
                                    ,fnd_date.server_timezone_code
                                    ,fnd_date.client_timezone_code);

RETURN to_char(l_actual_completion_date,'DD-MON-YYYY HH24:MI:SS');

EXCEPTION
WHEN NO_DATA_FOUND THEN

 FND_MESSAGE.SET_NAME('WMS', 'WMS_LMS_NOT_RUN');
 l_message:= FND_MESSAGE.GET;
 RETURN  l_message;

END last_run_time_success;


FUNCTION last_run_status ( p_concurrent_program_id IN NUMBER,
                           p_org_id IN NUMBER
					     )
RETURN VARCHAR2 IS
l_last_run_status VARCHAR2(20);

BEGIN
IF g_debug=1 THEN
    debug('Organization Id is '|| p_org_id,'get_parameter_string');
    debug('p_concurrent_program_id is '|| p_concurrent_program_id,'get_parameter_string');
 END IF;


    select   fl.meaning
	into     l_last_run_status
    from     fnd_concurrent_requests fcr, fnd_lookups fl
	where    argument1 = to_char(p_org_id)
	and      fl.lookup_code = fcr.status_code
	and      fl.Lookup_type = 'CP_STATUS_CODE'
    and      request_id = (select Max(Request_ID)
                           from Fnd_Concurrent_Requests
                           where Concurrent_Program_ID  = p_concurrent_program_id
					       AND PHASE_CODE = 'C'
				and argument1 = to_char(p_org_id)); -- added this condition for bug 5478746

RETURN l_last_run_status;

EXCEPTION
WHEN NO_DATA_FOUND THEN

 FND_MESSAGE.SET_NAME('WMS', 'WMS_LMS_NOT_RUN');
 l_last_run_status := FND_MESSAGE.GET;
 RETURN l_last_run_status;

END last_run_status;



FUNCTION getWorkOutstanding(l_ActivityId IN NUMBER, l_ActivityDetailId IN NUMBER, l_OrgId IN NUMBER)
RETURN VARCHAR2 IS
    CURSOR CUR_WRK_OUTSTANDING(p_ActivityId number, p_activityDetailId number, p_OrgId number) IS
    SELECT COUNT(*) || ' ' || NVL(DOCUMENT_TYPE, ML1.MEANING) AS WORK
	 FROM WMS_ELS_EXP_RESOURCE, MFG_LOOKUPS ML1
	 WHERE ORGANIZATION_ID = p_OrgId
	 AND ACTIVITY_ID = p_ActivityId
	 AND ACTIVITY_DETAIL_ID = p_ActivityDetailId
	 AND ML1.LOOKUP_TYPE         = 'WMS_ELS_TASKS_LOOKUP'
	 GROUP BY DOCUMENT_TYPE, ML1.MEANING;

         strWorkOutstanding varchar2(4000);
BEGIN
   strWorkOutstanding := NULL;
   FOR l_wrk_outstanding in CUR_WRK_OUTSTANDING(l_ActivityId, l_ActivityDetailId, l_OrgId)
   LOOP
	  strWorkOutstanding := strWorkOutstanding || l_wrk_outstanding.work || ', ';
   END LOOP;
    IF(strWorkOutstanding is not null) THEN
   	   strWorkOutstanding := substr(strWorkOutstanding,1,length(strWorkOutstanding)-2);
    END IF;
   RETURN strWorkOutstanding;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN '';
END getWorkOutstanding;

FUNCTION getWorkOutstandingGraphData(l_ActivityId NUMBER, l_ActivityDetailId NUMBER, l_OrgId NUMBER)
   RETURN NUMBER
IS
     CURSOR CUR_WRK_OUTSTANDING(p_ActivityId number, p_activityDetailId number, p_OrgId number) IS
	 SELECT COUNT(*) AS WORK
	 FROM WMS_ELS_EXP_RESOURCE, MFG_LOOKUPS ML1
	 WHERE ORGANIZATION_ID = p_OrgId
	 AND ACTIVITY_ID = p_ActivityId
	 AND ACTIVITY_DETAIL_ID = p_ActivityDetailId
	 AND ML1.LOOKUP_TYPE         = 'WMS_ELS_TASKS_LOOKUP';
     workValue NUMBER := NULL;
BEGIN
   FOR l_wrk_value in CUR_WRK_OUTSTANDING(l_ActivityId, l_ActivityDetailId, l_OrgId)
   LOOP
	  workValue := workValue || l_wrk_value.work;
   END LOOP;
   RETURN workValue;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN -1;
END getWorkOutstandingGraphData;


FUNCTION getratingfrompoints (p_points NUMBER)
   RETURN VARCHAR2
IS
   l_points NUMBER;
   rating   VARCHAR2 (20) := '';
BEGIN
 l_points := p_points;
 IF(p_points = 0) THEN
   l_points := 4;
 END IF;
   SELECT meaning
     INTO rating
     FROM mfg_lookups
    WHERE lookup_type = 'WMS_LABOR_RATINGS' AND lookup_code = l_points;

   RETURN rating;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN '';
END getratingfrompoints;


PROCEDURE GET_MAX_SEQ_NUMBERS (   x_seq_num_ind_and_sys_directed		OUT NOCOPY		NUMBER
                                , x_seq_num_man_and_usr_directed		OUT NOCOPY     NUMBER
                                , x_seq_num_man_and_sys_directed	   OUT NOCOPY 		NUMBER
                                , x_seq_num_grouped	               OUT NOCOPY     NUMBER
                                , p_org_id                           IN             NUMBER
                              ) IS

BEGIN


      BEGIN
      select round(MAX(sequence_number),-1) into x_seq_num_ind_and_sys_directed
      from WMS_ELS_INDIVIDUAL_TASKS_B
      where group_id= 3
      AND history_flag IS null
      AND organization_id = p_org_id;-- individual group
      EXCEPTION
      WHEN OTHERS THEN
      x_seq_num_ind_and_sys_directed := 0;
      END;

      BEGIN
      select round(MAX(sequence_number),-1) into x_seq_num_man_and_sys_directed
      from WMS_ELS_INDIVIDUAL_TASKS_B
      where group_id= 2
      AND history_flag IS null
      AND organization_id = p_org_id;  -- manual group
      EXCEPTION
      WHEN OTHERS THEN
      x_seq_num_man_and_sys_directed := 0;
      END;

      BEGIN
      select round(MAX(sequence_number),-1) into x_seq_num_man_and_usr_directed
      from WMS_ELS_INDIVIDUAL_TASKS_B
      where group_id= 1
      AND history_flag IS null
      AND organization_id = p_org_id;  -- manual group
      EXCEPTION
      WHEN OTHERS THEN
      x_seq_num_man_and_usr_directed := 0;
      END;

      BEGIN
      select round(MAX(sequence_number),-1) into x_seq_num_grouped
      from WMS_ELS_GROUPED_TASKS_B
      where organization_id = p_org_id; -- grouped tasks
      EXCEPTION
      WHEN OTHERS THEN
      x_seq_num_grouped := 0;
      END;

   -- If the Table Doesnt contain any rows then the sequence numbers will be null. In this case, set them to 0.
      IF x_seq_num_ind_and_sys_directed IS NULL THEN
         x_seq_num_ind_and_sys_directed := 0;
      END IF;

      IF x_seq_num_man_and_sys_directed IS NULL THEN
         x_seq_num_man_and_sys_directed := 0;
      END IF;

      IF x_seq_num_man_and_usr_directed IS NULL THEN
         x_seq_num_man_and_usr_directed := 0;
      END IF;

      IF x_seq_num_grouped IS NULL THEN
         x_seq_num_grouped := 0;
      END IF;

END GET_MAX_SEQ_NUMBERS;

PROCEDURE STANDARDIZE_LINES(
						     X_NUM_LINES_INSERTED_TASKS         OUT NOCOPY NUMBER
                           , X_NUM_LINES_INSERTED_GROUP         OUT NOCOPY NUMBER
   						   , X_RETURN_STATUS                    OUT NOCOPY VARCHAR2
                           , X_MSG_NAME                         OUT NOCOPY VARCHAR2
						   , P_COPY_ID                          IN  VARCHAR2
						   , P_COPY_ANALYSIS				    IN  VARCHAR2
                           , P_ORG_ID                           IN  NUMBER
	                       ) IS

l_seq_num_ind_and_sys_directed				NUMBER;
l_seq_num_man_and_usr_directed				NUMBER;
l_seq_num_man_and_sys_directed				NUMBER;
l_ind_or_man_tasks_inserted					NUMBER;
l_seq_num_grouped						    NUMBER;
l_comma_start_pos						    NUMBER;
l_comma_end_pos						       	NUMBER;
l_els_trx_src_id						    NUMBER;
l_analysis_id							    NUMBER;
i										    NUMBER;
l_return_staus                            VARCHAR2(1);

l_copy_id                                 VARCHAR2(4000);
l_copy_analysis                           VARCHAR2(4000);

TYPE els_src_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE analysis_tab   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_els_trx_src_id_tab  els_src_id_tab;
l_analysis_tab        analysis_tab;
l_grp_id            NUMBER; --Added for bug 5194353

BEGIN

-- set the status to success initially
x_return_status :=  fnd_api.g_ret_sts_success;


SAVEPOINT standardize_lines;


IF g_debug=1 THEN
   debug('The value of organization Id '|| p_org_id,'STANDARDIZE_LINES');
   debug('The p_copy_id '|| p_copy_id,'STANDARDIZE_LINES');
END IF;

-- Check if all required parameters are passed

IF P_COPY_ID IS NULL THEN
--   FND_MESSAGE.SET_NAME('WMS','WMS_NO_LINES_TO_COPY');
--   FND_MSG_PUB.ADD;
   X_MSG_NAME := 'WMS_NO_LINES_SELECTED';
   X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
   RETURN ;
END IF;

IF P_COPY_ANALYSIS IS NULL THEN
--   FND_MESSAGE.SET_NAME('WMS','WMS_NO_LINES_TO_COPY');
--   FND_MSG_PUB.ADD;
   X_MSG_NAME := 'WMS_NO_LINES_SELECTED';
   X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
   RETURN ;
END IF;

-- Proceed if all required parameters are passed.
-- get the max of the sequence numbers (as per HLD)in the
-- setup table(WMS_ELS_INDIVIDUAL_TASKS_B)
-- for both the Individual and the manual group.

IF (P_ORG_ID IS NOT NULL) THEN

     GET_MAX_SEQ_NUMBERS   (   x_seq_num_ind_and_sys_directed	=> l_seq_num_ind_and_sys_directed
                             , x_seq_num_man_and_usr_directed	=> l_seq_num_man_and_usr_directed
                             , x_seq_num_man_and_sys_directed	=> l_seq_num_man_and_sys_directed
                             , x_seq_num_grouped	            => l_seq_num_grouped
                             , p_org_id                        => p_org_id
                            );

      IF g_debug=1 THEN
         debug('The value of new seq for individual and system directed tasks '|| l_seq_num_ind_and_sys_directed,'STANDARDIZE_LINES');
         debug('The value of new seq for manual and system directed tasks '|| l_seq_num_man_and_sys_directed,'STANDARDIZE_LINES');
         debug('The value of new seq for manual and user directed tasks '|| l_seq_num_man_and_usr_directed,'STANDARDIZE_LINES');
         debug('The value of new seq for grouped tasks '|| l_seq_num_grouped,'STANDARDIZE_LINES');
      END IF;

  ELSE

   IF g_debug=1 THEN
      debug('No Organization Specified','STANDARDIZE_LINES');
   END IF;

--   FND_MESSAGE.SET_NAME('WMS','WMS_LMS_NO_ORG');
--	FND_MSG_PUB.ADD;
    X_MSG_NAME := 'WMS_LMS_NO_ORG';
	X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
	RETURN ;

END IF;

IF g_debug=1 THEN
   debug('Before inserting into individual tasks table','STANDARDIZE_LINES');
END IF;



----------------------------------------------------------------------------
--
-- Convert the Comma Separated Strings of Id's and Analyses into two arrays.
--
----------------------------------------------------------------------------

l_copy_id			:= p_copy_id;
l_comma_start_pos	:= 1;
i := 0;

while(l_copy_id is not null)
loop
    BEGIN
        l_comma_end_pos			:= instr(l_copy_id,',');
	if(l_comma_end_pos = 0) then
		l_els_trx_src_id_tab(i) := to_number(l_copy_id);
--		dbms_output.put_line(l_els_trx_src_id_tab(i));
		exit;
	else
		l_els_trx_src_id_tab(i)	:= to_number(substr(l_copy_id,l_comma_start_pos,l_comma_end_pos-1));
--		dbms_output.put_line(l_els_trx_src_id_tab(i));
	end if;
        l_copy_id				:= substr(l_copy_id,l_comma_end_pos+1);
--        l_comma_start_pos		:= l_comma_end_pos + 1;  Commented for bug 5194353
	i := i + 1;
    EXCEPTION
	  when others then
        l_copy_id := null;
		exit;
    END;
end loop;

l_copy_analysis := p_copy_analysis;
l_comma_start_pos := 1;
i := 0;
while(l_copy_analysis is not null)
loop
    BEGIN
        l_comma_end_pos			:= instr(l_copy_analysis,',');
	if(l_comma_end_pos = 0) then
		l_analysis_tab(i)		:= to_number(l_copy_analysis);
--		dbms_output.put_line(l_analysis_tab(i));
		exit;
	else
		l_analysis_tab(i)		:= to_number(substr(l_copy_analysis,l_comma_start_pos,l_comma_end_pos-1));
--		dbms_output.put_line(l_analysis_tab(i));
	end if;
        l_copy_analysis			:= substr(l_copy_analysis,l_comma_end_pos+1);
--        l_comma_start_pos		:= l_comma_end_pos + 1;  Commented for bug 5194353
	i := i + 1;
    EXCEPTION
	  when others then
        l_copy_analysis := null;
		exit;
    END;
end loop;

----------------------------------------------------------------------------
--
-- Inserting into individual or manual tasks table.
--
----------------------------------------------------------------------------


l_ind_or_man_tasks_inserted := 0;
for i in l_els_trx_src_id_tab.first .. l_els_trx_src_id_tab.last
loop
    l_els_trx_src_id := l_els_trx_src_id_tab(i);
	l_analysis_id    := l_analysis_tab(i);
	BEGIN
--		dbms_output.put_line(l_els_trx_src_id || ' els_trx_src_id value');
		if( l_els_trx_src_id <> 0 ) then

			INSERT INTO WMS_ELS_INDIVIDUAL_TASKS_B
			(
			  els_data_id
			, organization_id
			, sequence_number
			, analysis_id
			, activity_id
			, activity_detail_id
			, operation_id
			, equipment_id
			, source_zone_id
			, source_subinventory
			, destination_zone_id
			, destination_subinventory
			, labor_txn_source_id
			, transaction_uom
			, from_quantity
			, to_quantity
			, item_category_id
			, operation_plan_id
			, group_id
			, task_type_id
			, task_method_id
			, expected_travel_time
			, expected_txn_time
			, expected_idle_time
			, actual_travel_time
			, actual_txn_time
			, actual_idle_time
			, last_updated_by
			, last_update_date
			, last_update_login
			, created_by
			, creation_date
			)
				SELECT
					 wms_els_individual_tasks_s.nextval
				   , organization_id
				   , decode(group_id,1,nvl(l_seq_num_man_and_usr_directed,0)+10,
							  2,nvl(l_seq_num_man_and_sys_directed,0) + 10,
							  3,nvl(l_seq_num_ind_and_sys_directed,0) + 10
					   )
				   , l_analysis_id
				   , activity_id
				   , activity_detail_id
				   , operation_id
				   , equipment_id
				   , source_zone_id
				   , source_subinventory
				   , destination_zone_id
				   , destination_subinventory
				   , labor_txn_source_id
				   , transaction_uom
				   , quantity
				   , quantity
				   , item_category_id
				   , operation_plan_id
				   , group_id
				   , task_type_id
				   , task_method_id
				   , travel_and_idle_time
				   , transaction_time
				   , NULL
				   , travel_and_idle_time
				   , transaction_time
				   , idle_time
				   , FND_GLOBAL.USER_ID
				   , sysdate
				   , FND_GLOBAL.LOGIN_ID
				   , FND_GLOBAL.USER_ID
				   , sysdate
				FROM     WMS_ELS_TRX_SRC
				WHERE    ELS_DATA_ID IS NULL
				AND      ELS_TRX_SRC_ID = l_els_trx_src_id
            AND      UNATTRIBUTED_FLAG = 1 ;


/* Added the following select statement for bug 5194353 */

            SELECT  nvl(group_id,0) into l_grp_id
	    FROM WMS_ELS_TRX_SRC
            WHERE ELS_TRX_SRC_ID = l_els_trx_src_id;

		if(l_grp_id = 1) then
			l_seq_num_man_and_usr_directed      := nvl(l_seq_num_man_and_usr_directed,0) +10;
		elsif (l_grp_id = 2) then
			l_seq_num_man_and_sys_directed		:= nvl(l_seq_num_man_and_sys_directed,0) +10;
		elsif (l_grp_id = 3) then
			l_seq_num_ind_and_sys_directed		:= nvl(l_seq_num_ind_and_sys_directed,0) +10;
		end if;

		l_ind_or_man_tasks_inserted			:= l_ind_or_man_tasks_inserted + 1;


	 --  	X_NUM_LINES_INSERTED_TASKS :=   X_NUM_LINES_INSERTED_TASKS + SQL%ROWCOUNT;

		end if;

       X_NUM_LINES_INSERTED_TASKS := l_ind_or_man_tasks_inserted;
	EXCEPTION
	   when others then
	      l_ind_or_man_tasks_inserted := l_ind_or_man_tasks_inserted;
		   ROLLBACK TO standardize_lines;

		   X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
         X_MSG_NAME := 'WMS_LMS_LINES_UPDATE_ERROR';
		   X_NUM_LINES_INSERTED_TASKS := 0;
		   X_NUM_LINES_INSERTED_GROUP := 0;

			IF g_debug=1 THEN
			   debug('Error Occured in Individual Task Insertion ' || SQLERRM  ,'STANDARDIZE_LINES');
			END IF;

		   return;
	END;

end loop;




--We dont know how many new rows are created in the Base table. Also we dont have the els_Data_id's of all those rows.
--So we have the inner select Query.

INSERT INTO WMS_ELS_INDIVIDUAL_TASKS_TL
		    (
		     els_data_id,
		     language,
		     source_lang,
		     description,
		     last_updated_by,
		     last_update_login,
		     created_by,
		     creation_date,
		     last_update_date
		     )
			SELECT	     b.els_data_id
				   , l.language_code
				   , userenv('lang')		--Have to change this line. Need to give a Source Language.
				   , null
				   , b.last_updated_by
				   , b.last_update_login
				   , b.created_by
				   , b.creation_date
				   , b.last_update_date
			FROM	WMS_ELS_INDIVIDUAL_TASKS_B b,
				FND_LANGUAGES L
			WHERE	els_data_id NOT IN (
									  SELECT DISTINCT els_data_id
									  FROM wms_els_individual_tasks_tl
									 )
			AND	L.INSTALLED_FLAG in ('I', 'B');



--X_NUM_LINES_INSERTED_TASKS := SQL%ROWCOUNT;


IF g_debug=1 THEN
   debug('Num lines inserted into WMS_ELS_INDIVIDUAL_TASKS_B '||X_NUM_LINES_INSERTED_TASKS ,'STANDARDIZE_LINES');
   debug('Before inserting into grouped tasks table','STANDARDIZE_LINES');
END IF;



----------------------------------------------------------------------------
--
-- Inserting into Grouped tasks table.
--
----------------------------------------------------------------------------

--l_query1 :=
EXECUTE IMMEDIATE
'INSERT INTO WMS_ELS_GROUPED_TASKS_B' ||
'(' ||
'	  Els_Group_Id' ||
'	, Organization_id' ||
'	, Sequence_Number' ||
'	, activity_id' ||
'	, activity_detail_id' ||
'	, operation_id' ||
'	, labor_txn_source_id' ||
'	, source_zone_id' ||
'	, source_subinventory' ||
'	, destination_zone_id' ||
'	, destination_subinventory' ||
'	, task_method_id' ||
'	, task_range_from' ||
'	, task_range_to' ||
'	, expected_travel_time' ||
'	, actual_travel_time' ||
'	, last_updated_by' ||
'	, last_update_date' ||
'	, last_update_login' ||
'	, created_by' ||
'	, creation_date' ||
')' ||
'SELECT	 wms_els_grouped_tasks_s.NEXTVAL' ||
'	   , organization_id' ||
'	   , (nvl('||l_seq_num_grouped||',0) + (10*ROWNUM)) sequence_number' ||
'	   , activity_id' ||
'	   , activity_detail_id' ||
'	   , operation_id' ||
'	   , labor_txn_source_id	   ' ||
'	   , source_zone_id' ||
'	   , source_subinventory' ||
'	   , destination_zone_id' ||
'	   , destination_subinventory' ||
'	   , task_method_id' ||
'	   , task_range_from' ||
'	   , task_range_to' ||
'	   , exp_travel_time' ||
'	   , act_travel_Time' ||
'	   , FND_GLOBAL.USER_ID  last_updated_by		   ' ||
'	   , sysdate			 last_update_date' ||
'	   , FND_GLOBAL.LOGIN_ID last_update_login' ||
'	   , FND_GLOBAL.USER_ID	 created_by' ||
'	   , sysdate			 creation_date' ||
 ' FROM	   ' ||
  '(	select   organization_id' ||
'		   , activity_id' ||
'		   , activity_detail_id' ||
'		   , operation_id' ||
'		   , source_zone_id' ||
'		   , source_subinventory' ||
'		   , destination_zone_id' ||
'		   , destination_subinventory' ||
'		   , labor_txn_source_id' ||
'		   , task_method_id' ||
'		   , count(*) task_range_from' ||
'		   , count(*) task_range_to' ||
'		   , sum(travel_and_idle_time) exp_travel_time' ||
'		   , sum(travel_and_idle_time) act_travel_Time' ||
'	FROM   wms_els_trx_src' ||
'	where  els_data_id is null' ||
'	and    organization_id = '|| p_org_id ||
'	and   Els_Trx_Src_Id IN (' || P_COPY_ID || ') '||
'   and   unattributed_flag = 1 '||
'   and   grouped_Task_identifier IS NOT NULL'||
'	group by    grouped_Task_identifier' ||
'		  	  , organization_id' ||
'		  	  , activity_id' ||
'			  , activity_detail_id' ||
'			  , operation_id' ||
'			  , source_zone_id' ||
'			  , source_subinventory' ||
'			  , destination_zone_id' ||
'			  , destination_subinventory' ||
'			  , labor_txn_source_id' ||
'			  , task_method_id' ||
 ' )';





X_NUM_LINES_INSERTED_GROUP := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('Num lines inserted in groups table'||X_NUM_LINES_INSERTED_GROUP ,'STANDARDIZE_LINES');
   END IF;

INSERT INTO WMS_ELS_GROUPED_TASKS_TL
		    (
		     els_group_id,
		     language,
		     source_lang,
		     description,
		     last_updated_by,
		     last_update_login,
		     created_by,
		     creation_date,
		     last_update_date
		     )
		    SELECT     b.els_group_id,
			       l.language_code,
			       userenv('lang'),		--Have to change this line. Need to give a Source Language.
			       null,
			       b.last_updated_by,
			       b.last_update_login,
			       b.created_by,
			       b.creation_date,
			       b.last_update_date
			FROM   WMS_ELS_GROUPED_TASKS_B b,
			       FND_LANGUAGES L
			WHERE  els_group_id NOT IN (
					                    SELECT DISTINCT els_group_id
									    FROM wms_els_grouped_tasks_tl
						  			   )
			AND    L.INSTALLED_FLAG in ('I', 'B');


--Completed entering all the values. Now have to change the unattributed_lines flag of all are selected rows.
EXECUTE IMMEDIATE
'UPDATE wms_els_trx_src ' ||
'SET unattributed_flag = null ' ||
'WHERE Els_Trx_Src_Id IN (' || P_COPY_ID || ')';

EXCEPTION
WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('In Exception No lines inserted'||SQLERRM ,'STANDARDIZE_LINES');
   END IF;
   ROLLBACK TO standardize_lines;

   -- return the appropriate status
   X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
    X_MSG_NAME := 'WMS_LMS_LINES_UPDATE_ERROR';
   X_NUM_LINES_INSERTED_TASKS := 0;
   X_NUM_LINES_INSERTED_GROUP := 0;

	--dbms_output.put_line(sqlerrm);
	IF g_debug=1 THEN
	   debug('Error Occured in Standardize Lines function ' || SQLERRM  ,'STANDARDIZE_LINES');
	END IF;


END STANDARDIZE_LINES;


PROCEDURE STANDARDIZE_LINES_CP(
			                     ERRBUF                   OUT    NOCOPY VARCHAR2
                            , RETCODE                  OUT    NOCOPY NUMBER
			                   , P_ORG_ID                 IN     NUMBER
			                   , P_ANALYSIS_TYPE			 IN     NUMBER
                            , P_ACTIVITY_ID            IN     NUMBER
                            , P_ACTIVITY_DETAIL_ID     IN     NUMBER
                            , P_OPERATION_ID           IN     NUMBER
                            , P_FROM_DATE              IN     VARCHAR2
                            , P_TO_DATE                IN     VARCHAR2
	                        )
IS
l_seq_num_ind_and_sys_directed				NUMBER;
l_seq_num_man_and_usr_directed				NUMBER;
l_seq_num_man_and_sys_directed				NUMBER;
l_seq_num_grouped						         NUMBER;
l_where_clause                            VARCHAR2(1000);
l_num_lines_inserted                      NUMBER;
l_num_sql_failed                          NUMBER;
l_which_group_failed                      VARCHAR2(20);
l_not_in_clause                           VARCHAR2(200);
l_ret                                     BOOLEAN;

l_message VARCHAR2(250);
l_sql VARCHAR2(4000);

BEGIN

SAVEPOINT standardize_lines_cp;

l_where_clause := NULL;

l_num_lines_inserted :=0;

l_num_sql_failed := 0;

l_which_group_failed  := NULL;

l_not_in_clause  := NULL;



IF ( P_ORG_ID IS NOT NULL AND P_ANALYSIS_TYPE IS NOT NULL ) THEN

   GET_MAX_SEQ_NUMBERS   (   x_seq_num_ind_and_sys_directed	=> l_seq_num_ind_and_sys_directed
                           , x_seq_num_man_and_usr_directed	=> l_seq_num_man_and_usr_directed
                           , x_seq_num_man_and_sys_directed	=> l_seq_num_man_and_sys_directed
                           , x_seq_num_grouped	            => l_seq_num_grouped
                           , p_org_id                       => p_org_id
                         );
   IF g_debug=1 THEN
     debug('The value of new seq for individual and system directed tasks '|| l_seq_num_ind_and_sys_directed,'STANDARDIZE_LINES_CP');
     debug('The value of new seq for manual and system directed tasks '|| l_seq_num_man_and_sys_directed,'STANDARDIZE_LINES_CP');
     debug('The value of new seq for manual and user directed tasks '|| l_seq_num_man_and_usr_directed,'STANDARDIZE_LINES_CP');
     debug('The value of new seq for grouped tasks '|| l_seq_num_grouped,'STANDARDIZE_LINES_CP');
   END IF;

  IF (P_ACTIVITY_ID IS NOT NULL) THEN
   l_where_clause := l_where_clause || ' AND activity_id = '|| p_activity_id ;
  END IF;

  IF (P_ACTIVITY_DETAIL_ID IS NOT NULL) THEN
   l_where_clause := l_where_clause || ' AND activity_detail_id = '|| p_activity_detail_id ;
  END IF;

  IF (P_OPERATION_ID IS NOT NULL) THEN
   l_where_clause := l_where_clause || ' AND operation_id = '|| p_operation_id ;
  END IF;

  IF (P_FROM_DATE IS NOT NULL ) THEN
     l_where_clause := l_where_clause || ' AND transaction_date >= '|| 'TO_DATE(''' || p_from_date || ''',''YYYY/MM/DD HH24:MI:SS'')' ;
  END IF;

  IF (P_TO_DATE IS NOT NULL ) THEN
     l_where_clause := l_where_clause || ' AND transaction_date <= '|| 'TO_DATE(''' || p_to_date || ''',''YYYY/MM/DD HH24:MI:SS'')' ;
  END IF;


   IF g_debug=1 THEN
     debug('The value of the where clause is '|| l_where_clause,'STANDARDIZE_LINES_CP');
    END IF;

BEGIN
-- for manual and user directed tasks

EXECUTE IMMEDIATE
 ' INSERT INTO WMS_ELS_INDIVIDUAL_TASKS_B '
|| '  ( '
|| '    els_data_id '
|| '  , organization_id '
|| '  , sequence_number '
|| '  , analysis_id '
|| '  , activity_id '
|| '  , activity_detail_id '
|| '  , operation_id '
|| '  , equipment_id '
|| '  , source_zone_id '
|| '  , source_subinventory '
|| '  , destination_zone_id '
|| '  , destination_subinventory '
|| '  , labor_txn_source_id '
|| '  , operation_plan_id '
|| '  , group_id '
|| '  , task_type_id '
|| '  , task_method_id '
|| '  , expected_travel_time '
|| '  , expected_txn_time '
|| '  , expected_idle_time '
|| '  , actual_travel_time '
|| '  , actual_txn_time '
|| '  , actual_idle_time '
|| '  , last_updated_by '
|| '  , last_update_date '
|| '  , last_update_login '
|| '  , created_by '
|| '  , creation_date '
|| '  ) '
|| '     SELECT '
|| '         wms_els_individual_tasks_s.NEXTVAL ' -- els_data_id
|| '        , organization_id ' --organization_id
|| '        , nvl ( ' || l_seq_num_man_and_usr_directed  || ',0)+10*ROWNUM ' --sequence_number
|| '         , ' || p_analysis_type  --analysis_id
|| '         , activity_id ' --activity_id
|| '         , activity_detail_id ' --activity_detail_id
|| '         , operation_id ' --operation_id
|| '         , equipment_id ' --equipment_id
|| '         , source_zone_id ' --source_zone_id
|| '         , source_subinventory '--source_subinventory
|| '         , destination_zone_id ' --destination_zone_id
|| '         , destination_subinventory ' --destination_subinventory
|| '         , labor_txn_source_id ' --labor_txn_source_id
|| '         , operation_plan_id ' --operation_plan_id
|| '         , group_id ' --group_id
|| '         , task_type_id ' --task_type_id
|| '         , task_method_id ' --task_method_id
|| '         , travel_and_idle_time ' --expected_travel_time
|| '         , transaction_time ' --expected_txn_time
|| '         , NULL' --expected_idle_time
|| '         , travel_and_idle_time ' --actual_travel_time
|| '         , transaction_time ' --actual_txn_time
|| '         , idle_time ' --actual_idle_time
|| '         , FND_GLOBAL.USER_ID '
|| '         , sysdate '
|| '         , FND_GLOBAL.LOGIN_ID '
|| '         , FND_GLOBAL.USER_ID '
|| '         , sysdate '
|| '  FROM '
|| ' ( '
|| '     SELECT '
|| '           organization_id ' --organization_id
|| '         , activity_id ' --activity_id
|| '         , activity_detail_id ' --activity_detail_id
|| '         , operation_id ' --operation_id
|| '         , equipment_id ' --equipment_id
|| '         , source_zone_id ' --source_zone_id
|| '         , source_subinventory '--source_subinventory
|| '         , destination_zone_id ' --destination_zone_id
|| '         , destination_subinventory ' --destination_subinventory
|| '         , labor_txn_source_id ' --labor_txn_source_id
|| '         , operation_plan_id ' --operation_plan_id
|| '         , group_id ' --group_id
|| '         , task_type_id ' --task_type_id
|| '         , task_method_id ' --task_method_id
|| '         , ROUND(AVG(travel_and_idle_time),3) travel_and_idle_time ' --expected_travel_time
|| '         , ROUND(AVG(transaction_time),3) transaction_time' --expected_txn_time
|| '         , ROUND(AVG(idle_time),3) idle_time '
|| '      FROM     WMS_ELS_TRX_SRC '
|| '      WHERE    UNATTRIBUTED_FLAG = 1  '
|| '      AND      organization_id = ' || p_org_id
|| '      AND group_id = 1 '
|| l_where_clause
|| '     GROUP BY '
|| '     organization_id,activity_id,activity_detail_id,operation_id '
|| '    ,equipment_id,source_zone_id,source_subinventory,destination_zone_id '
|| '    ,destination_subinventory,labor_txn_source_id,operation_plan_id '
|| '    ,group_id,task_type_id,task_method_id '
|| ' )';


 l_num_lines_inserted := SQL%ROWCOUNT;

 IF g_debug=1 THEN
    debug('Standardization for manual and user directed tasks  successfull','STANDARDIZE_LINES_CP');
    debug('Number of lines inserted for manual and user directed tasks'|| l_num_lines_inserted,'STANDARDIZE_LINES_CP');
 END IF;

EXCEPTION
WHEN OTHERS THEN
 IF g_debug=1 THEN
    debug('Standardization for manual and user directed tasks failed'||SQLERRM,'STANDARDIZE_LINES');
 END IF;
l_num_sql_failed := l_num_sql_failed + 1;
l_which_group_failed := l_which_group_failed  || '1,';

END;

l_num_lines_inserted :=0;--reinitialize

-- for manual and system directed tasks
BEGIN

EXECUTE IMMEDIATE
   ' INSERT INTO WMS_ELS_INDIVIDUAL_TASKS_B '
|| '  ( '
|| '    els_data_id '
|| '  , organization_id '
|| '  , sequence_number '
|| '  , analysis_id '
|| '  , activity_id '
|| '  , activity_detail_id '
|| '  , operation_id '
|| '  , equipment_id '
|| '  , source_zone_id '
|| '  , source_subinventory '
|| '  , destination_zone_id '
|| '  , destination_subinventory '
|| '  , labor_txn_source_id '
|| '  , operation_plan_id '
|| '  , group_id '
|| '  , task_type_id '
|| '  , task_method_id '
|| '  , expected_travel_time '
|| '  , expected_txn_time '
|| '  , expected_idle_time '
|| '  , actual_travel_time '
|| '  , actual_txn_time '
|| '  , actual_idle_time '
|| '  , last_updated_by '
|| '  , last_update_date '
|| '  , last_update_login '
|| '  , created_by '
|| '  , creation_date '
|| '  ) '
|| '     SELECT '
|| '         wms_els_individual_tasks_s.NEXTVAL ' -- els_data_id
|| '        , organization_id ' --organization_id
|| '        , nvl ( ' || l_seq_num_man_and_sys_directed  || ',0)+10*ROWNUM ' --sequence_number
|| '         , ' || p_analysis_type  --analysis_id
|| '         , activity_id ' --activity_id
|| '         , activity_detail_id ' --activity_detail_id
|| '         , operation_id ' --operation_id
|| '         , equipment_id ' --equipment_id
|| '         , source_zone_id ' --source_zone_id
|| '         , source_subinventory '--source_subinventory
|| '         , destination_zone_id ' --destination_zone_id
|| '         , destination_subinventory ' --destination_subinventory
|| '         , labor_txn_source_id ' --labor_txn_source_id
|| '         , operation_plan_id ' --operation_plan_id
|| '         , group_id ' --group_id
|| '         , task_type_id ' --task_type_id
|| '         , task_method_id ' --task_method_id
|| '         , travel_and_idle_time ' --expected_travel_time
|| '         , transaction_time ' --expected_txn_time
|| '         , NULL' --expected_idle_time
|| '         , travel_and_idle_time ' --actual_travel_time
|| '         , transaction_time ' --actual_txn_time
|| '         , idle_time ' --actual_idle_time
|| '         , FND_GLOBAL.USER_ID '
|| '         , sysdate '
|| '         , FND_GLOBAL.LOGIN_ID '
|| '         , FND_GLOBAL.USER_ID '
|| '         , sysdate '
|| '  FROM '
|| ' ( '
|| '     SELECT '
|| '           organization_id ' --organization_id
|| '         , activity_id ' --activity_id
|| '         , activity_detail_id ' --activity_detail_id
|| '         , operation_id ' --operation_id
|| '         , equipment_id ' --equipment_id
|| '         , source_zone_id ' --source_zone_id
|| '         , source_subinventory '--source_subinventory
|| '         , destination_zone_id ' --destination_zone_id
|| '         , destination_subinventory ' --destination_subinventory
|| '         , labor_txn_source_id ' --labor_txn_source_id
|| '         , operation_plan_id ' --operation_plan_id
|| '         , group_id ' --group_id
|| '         , task_type_id ' --task_type_id
|| '         , task_method_id ' --task_method_id
|| '         , ROUND(AVG(travel_and_idle_time),3) travel_and_idle_time ' --expected_travel_time
|| '         , ROUND(AVG(transaction_time),3) transaction_time' --expected_txn_time
|| '         , ROUND(AVG(idle_time),3) idle_time '
|| '      FROM     WMS_ELS_TRX_SRC '
|| '      WHERE    UNATTRIBUTED_FLAG = 1  '
|| '      AND      organization_id = ' || p_org_id
|| '      AND group_id = 2 '
|| l_where_clause
|| '     GROUP BY '
|| '     organization_id,activity_id,activity_detail_id,operation_id '
|| '    ,equipment_id,source_zone_id,source_subinventory,destination_zone_id '
|| '    ,destination_subinventory,labor_txn_source_id,operation_plan_id '
|| '    ,group_id,task_type_id,task_method_id '
|| ' )';


 l_num_lines_inserted := SQL%ROWCOUNT;

 IF g_debug=1 THEN
    debug('Standardization for manual and system directed tasks  successfull','STANDARDIZE_LINES_CP');
    debug('Number of lines inserted for manual and system directed tasks'|| l_num_lines_inserted,'STANDARDIZE_LINES_CP');
 END IF;

EXCEPTION
WHEN OTHERS THEN
 IF g_debug=1 THEN
    debug('Standardization for manual and system directed tasks failed'||SQLERRM,'STANDARDIZE_LINES');
 END IF;

 l_num_sql_failed := l_num_sql_failed + 1;
 l_which_group_failed := l_which_group_failed  || '2,';

END;

l_num_lines_inserted :=0;--reinitialize

-- for individual and system directed  tasks

BEGIN

 EXECUTE IMMEDIATE
   ' INSERT INTO WMS_ELS_INDIVIDUAL_TASKS_B '
|| '  ( '
|| '    els_data_id '
|| '  , organization_id '
|| '  , sequence_number '
|| '  , analysis_id '
|| '  , activity_id '
|| '  , activity_detail_id '
|| '  , operation_id '
|| '  , equipment_id '
|| '  , source_zone_id '
|| '  , source_subinventory '
|| '  , destination_zone_id '
|| '  , destination_subinventory '
|| '  , labor_txn_source_id '
|| '  , operation_plan_id '
|| '  , group_id '
|| '  , task_type_id '
|| '  , task_method_id '
|| '  , expected_travel_time '
|| '  , expected_txn_time '
|| '  , expected_idle_time '
|| '  , actual_travel_time '
|| '  , actual_txn_time '
|| '  , actual_idle_time '
|| '  , last_updated_by '
|| '  , last_update_date '
|| '  , last_update_login '
|| '  , created_by '
|| '  , creation_date '
|| '  ) '
|| '     SELECT '
|| '         wms_els_individual_tasks_s.NEXTVAL ' -- els_data_id
|| '        , organization_id ' --organization_id
|| '        , nvl ( ' || l_seq_num_ind_and_sys_directed  || ',0)+10*ROWNUM ' --sequence_number
|| '         , ' || p_analysis_type  --analysis_id
|| '         , activity_id ' --activity_id
|| '         , activity_detail_id ' --activity_detail_id
|| '         , operation_id ' --operation_id
|| '         , equipment_id ' --equipment_id
|| '         , source_zone_id ' --source_zone_id
|| '         , source_subinventory '--source_subinventory
|| '         , destination_zone_id ' --destination_zone_id
|| '         , destination_subinventory ' --destination_subinventory
|| '         , labor_txn_source_id ' --labor_txn_source_id
|| '         , operation_plan_id ' --operation_plan_id
|| '         , group_id ' --group_id
|| '         , task_type_id ' --task_type_id
|| '         , task_method_id ' --task_method_id
|| '         , travel_and_idle_time ' --expected_travel_time
|| '         , transaction_time ' --expected_txn_time
|| '         , NULL' --expected_idle_time
|| '         , travel_and_idle_time ' --actual_travel_time
|| '         , transaction_time ' --actual_txn_time
|| '         , idle_time ' --actual_idle_time
|| '         , FND_GLOBAL.USER_ID '
|| '         , sysdate '
|| '         , FND_GLOBAL.LOGIN_ID '
|| '         , FND_GLOBAL.USER_ID '
|| '         , sysdate '
|| '  FROM '
|| ' ( '
|| '     SELECT '
|| '           organization_id ' --organization_id
|| '         , activity_id ' --activity_id
|| '         , activity_detail_id ' --activity_detail_id
|| '         , operation_id ' --operation_id
|| '         , equipment_id ' --equipment_id
|| '         , source_zone_id ' --source_zone_id
|| '         , source_subinventory '--source_subinventory
|| '         , destination_zone_id ' --destination_zone_id
|| '         , destination_subinventory ' --destination_subinventory
|| '         , labor_txn_source_id ' --labor_txn_source_id
|| '         , operation_plan_id ' --operation_plan_id
|| '         , group_id ' --group_id
|| '         , task_type_id ' --task_type_id
|| '         , task_method_id ' --task_method_id
|| '         , ROUND(AVG(travel_and_idle_time),3) travel_and_idle_time ' --expected_travel_time
|| '         , ROUND(AVG(transaction_time),3) transaction_time' --expected_txn_time
|| '         , ROUND(AVG(idle_time),3) idle_time '
|| '      FROM     WMS_ELS_TRX_SRC '
|| '      WHERE    UNATTRIBUTED_FLAG = 1  '
|| '      AND      organization_id = ' || p_org_id
|| '      AND group_id = 3 '
|| l_where_clause
|| '     GROUP BY '
|| '     organization_id,activity_id,activity_detail_id,operation_id '
|| '    ,equipment_id,source_zone_id,source_subinventory,destination_zone_id '
|| '    ,destination_subinventory,labor_txn_source_id,operation_plan_id '
|| '    ,group_id,task_type_id,task_method_id '
|| ' )';


 l_num_lines_inserted := SQL%ROWCOUNT;

 IF g_debug=1 THEN
    debug('Standardization for individual and system directed tasks  successfull','STANDARDIZE_LINES_CP');
    debug('Number of lines inserted for individual and system directed tasks'|| l_num_lines_inserted,'STANDARDIZE_LINES_CP');
 END IF;

EXCEPTION
WHEN OTHERS THEN
 IF g_debug=1 THEN
    debug('Standardization for individual and system directed tasks failed'||SQLERRM,'STANDARDIZE_LINES_CP');
 END IF;

 l_num_sql_failed := l_num_sql_failed + 1;
 l_which_group_failed := l_which_group_failed || '3,';

END;

--If all the sql's for the three groups have failed then error out and return from here

IF(l_num_sql_failed = 3 )THEN

  --- Dont PROCEED;return error from here itself;
       ROLLBACK TO standardize_lines_cp;
       retcode := 2;
       fnd_message.set_name('WMS', 'WMS_LMS_STANDARDIZE_ERROR');
       l_message := fnd_message.get;
       l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
       RETURN;

 END IF;

-- Not all sql's have failed so one can procedd and at the end return appropiate
-- staus of SUCCESS(if nothing fails) or WARNING( if some sql but not all fail)

BEGIN
   -- insert lines into TL table for all lines inserted into Base tables

INSERT INTO WMS_ELS_INDIVIDUAL_TASKS_TL
		    (
		     els_data_id,
		     language,
		     source_lang,
		     description,
		     last_updated_by,
		     last_update_login,
		     created_by,
		     creation_date,
		     last_update_date
		     )
			SELECT  b.els_data_id
				   , l.language_code
				   , userenv('lang')
				   , null
				   , b.last_updated_by
				   , b.last_update_login
				   , b.created_by
				   , b.creation_date
				   , b.last_update_date
			FROM	WMS_ELS_INDIVIDUAL_TASKS_B b,
				FND_LANGUAGES L
			WHERE	els_data_id NOT IN (
									  SELECT DISTINCT els_data_id
									  FROM wms_els_individual_tasks_tl
									 )
			AND	L.INSTALLED_FLAG in ('I', 'B');

EXCEPTION
WHEN OTHERS THEN
-- If insertion into TL table fails the rollback everything and return from here
-- no use to proceed after such a mishap

IF g_debug=1 THEN
    debug('Insertion into TL table failed so rolling back everything'||SQLERRM,'STANDARDIZE_LINES_CP');
 END IF;

ROLLBACK TO standardize_lines_cp;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_STANDARDIZE_LINES_ERROR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
RETURN;

END;

-- Now when the insertion to WMS_ELS_INDIVIDUAL_TASKS_B and
-- WMS_ELS_INDIVIDUAL_TASKS_TL table is successfull now we can proceed
-- to inserting lines in the WMS_ELS_GROUPED_TASKS_B and WMS_ELS_GROUPED_TASKS_TL table

l_num_lines_inserted :=0;--reinitialize


IF (l_which_group_failed IS NOT NULL) THEN

SELECT substr(l_which_group_failed,0,length(l_which_group_failed)-1)
INTO l_which_group_failed
FROM dual;

IF g_debug=1 THEN
    debug('Value of  l_which_group_failed '||l_which_group_failed,'STANDARDIZE_LINES_CP');
 END IF;

l_not_in_clause := ' AND group_id NOT IN (' || l_which_group_failed || ') ';

IF g_debug=1 THEN
    debug('Value of  l_not_in_clause  '||l_not_in_clause ,'STANDARDIZE_LINES_CP');
 END IF;

END IF;

BEGIN

EXECUTE IMMEDIATE
'INSERT INTO WMS_ELS_GROUPED_TASKS_B' ||
'(' ||
'	  Els_Group_Id' ||
'	, Organization_id' ||
'	, Sequence_Number' ||
'	, activity_id' ||
'	, activity_detail_id' ||
'	, operation_id' ||
'	, labor_txn_source_id' ||
'	, source_zone_id' ||
'	, source_subinventory' ||
'	, destination_zone_id' ||
'	, destination_subinventory' ||
'	, task_method_id' ||
'	, task_range_from' ||
'	, task_range_to' ||
'	, expected_travel_time' ||
'	, actual_travel_time' ||
'	, last_updated_by' ||
'	, last_update_date' ||
'	, last_update_login' ||
'	, created_by' ||
'	, creation_date' ||
')' ||
'SELECT	 wms_els_grouped_tasks_s.NEXTVAL' ||
'	   , organization_id' ||
'	   , (nvl('||l_seq_num_grouped||',0) + (10*ROWNUM)) sequence_number' ||
'	   , activity_id' ||
'	   , activity_detail_id' ||
'	   , operation_id' ||
'	   , labor_txn_source_id	   ' ||
'	   , source_zone_id' ||
'	   , source_subinventory' ||
'	   , destination_zone_id' ||
'	   , destination_subinventory' ||
'	   , task_method_id' ||
'	   , task_range_from' ||
'	   , task_range_to' ||
'	   , exp_travel_time' ||
'	   , act_travel_Time' ||
'	   , FND_GLOBAL.USER_ID  last_updated_by		   ' ||
'	   , sysdate			 last_update_date' ||
'	   , FND_GLOBAL.LOGIN_ID last_update_login' ||
'	   , FND_GLOBAL.USER_ID	 created_by' ||
'	   , sysdate			 creation_date' ||
 ' FROM	   ' ||
  '(	select   organization_id' ||
'		   , activity_id' ||
'		   , activity_detail_id' ||
'		   , operation_id' ||
'		   , source_zone_id' ||
'		   , source_subinventory' ||
'		   , destination_zone_id' ||
'		   , destination_subinventory' ||
'		   , labor_txn_source_id' ||
'		   , task_method_id' ||
'		   , count(*) task_range_from' ||
'		   , count(*) task_range_to' ||
'		   , sum(travel_and_idle_time) exp_travel_time' ||
'		   , sum(travel_and_idle_time) act_travel_Time' ||
'	FROM   wms_els_trx_src' ||
'	where  els_data_id is null' ||
'	and    organization_id = '|| p_org_id ||
'   and   unattributed_flag = 1 '||
' and   grouped_Task_identifier IS NOT NULL ' ||
   l_where_clause || l_not_in_clause ||
'	group by    grouped_Task_identifier' ||
'		  	  , organization_id' ||
'		  	  , activity_id' ||
'			  , activity_detail_id' ||
'			  , operation_id' ||
'			  , source_zone_id' ||
'			  , source_subinventory' ||
'			  , destination_zone_id' ||
'			  , destination_subinventory' ||
'			  , labor_txn_source_id' ||
'			  , task_method_id' ||
 ' )';

l_num_lines_inserted := SQL%ROWCOUNT;

 IF g_debug=1 THEN
    debug('Standardization for grouped and system directed tasks  successfull','STANDARDIZE_LINES_CP');
    debug('Number of lines inserted for grouped and system directed tasks'|| l_num_lines_inserted,'STANDARDIZE_LINES_CP');
 END IF;

EXCEPTION
WHEN OTHERS THEN
 IF g_debug=1 THEN
    debug('Standardization for grouped and system directed tasks failed'||SQLERRM,'STANDARDIZE_LINES_CP');
 END IF;

ROLLBACK TO standardize_lines_cp;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_STANDARDIZE_LINES_ERROR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
RETURN;

END;

-- proceed with TL table only when insertion to WMS_ELS_GROUPED_TASKS_B is a success

BEGIN

INSERT INTO WMS_ELS_GROUPED_TASKS_TL
		    (
		     els_group_id,
		     language,
		     source_lang,
		     description,
		     last_updated_by,
		     last_update_login,
		     created_by,
		     creation_date,
		     last_update_date
		     )
		    SELECT     b.els_group_id,
			       l.language_code,
			       userenv('lang'),		--Have to change this line. Need to give a Source Language.
			       null,
			       b.last_updated_by,
			       b.last_update_login,
			       b.created_by,
			       b.creation_date,
			       b.last_update_date
			FROM   WMS_ELS_GROUPED_TASKS_B b,
			       FND_LANGUAGES L
			WHERE  els_group_id NOT IN (
					                    SELECT DISTINCT els_group_id
									    FROM wms_els_grouped_tasks_tl
						  			   )
			AND    L.INSTALLED_FLAG in ('I', 'B');

EXCEPTION
WHEN OTHERS THEN
 IF g_debug=1 THEN
    debug('Insertion to TL table failed with '||SQLERRM,'STANDARDIZE_LINES_CP');
 END IF;
 -- roll back to  savepoint and return

ROLLBACK TO standardize_lines_cp;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_STANDARDIZE_LINES_ERROR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
RETURN;


END;

-- now make the unattributed_flag as null for these lines that have been standardized

EXECUTE IMMEDIATE
'UPDATE wms_els_trx_src ' ||
'SET unattributed_flag = null ' ||
'WHERE organization_id = ' || p_org_id ||l_where_clause || l_not_in_clause ;


--NOW check for the status of l_num_sql_failed to
-- determine the status of completion of the program
-- If no sql have failed(variables have the value 0 then SUCCESS)
-- Else if any one sql has failed ( variable has the value of not =0 then WARNING)

IF (  l_num_sql_failed = 0 )THEN
-- every thing is done so the concurrent program has finished normal
COMMIT;
retcode := 1;
fnd_message.set_name('WMS', 'WMS_STANDARDIZE_LINES_SUCCESS');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);

ELSE

COMMIT;
retcode := 3;
fnd_message.set_name('WMS', 'WMS_STANDARDIZE_LINES_WARN');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);

END IF;

ELSE -- When required parameters are not passed

   IF g_debug=1 THEN
           debug( 'Required parameters not passed '
                 ,'PURGE_LMS_TRANSACTIONS'
                );
   END IF;

   retcode := 2;
   fnd_message.set_name('WMS', 'WMS_LMS_REQ_PARAM_NULL');
   l_message := fnd_message.get;
   l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

END IF; -- when required parameters passed


EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug( 'Exception has occured','STANDARDIZE_LINES_CP');
END IF;

 -- roll back to  savepoint and return
ROLLBACK TO standardize_lines_cp;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_STANDARDIZE_LINES_ERROR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

END STANDARDIZE_LINES_CP;


   PROCEDURE INSERT_ELS_TRX
   (
                              P_ACTIVITY_ID		         NUMBER,
                              P_ACTIVITY_DETAIL_ID	      NUMBER,
                              P_OPERATION_ID		         NUMBER,
                              P_ORGANIZATION_ID	         NUMBER,
                              P_USER_ID		            NUMBER,
                              P_EQUIPMENT_ID		         NUMBER,
                              P_SOURCE_SUBINVENTORY	   VARCHAR2,
                              P_DESTINATION_SUBINVENTORY VARCHAR2,
                              P_FROM_LOCATOR_ID	         NUMBER,
                              P_TO_LOCATOR_ID		      NUMBER,
                              P_LABOR_TXN_SOURCE_ID	   NUMBER,
                              P_TRANSACTION_UOM	         VARCHAR2,
                              P_QUANTITY		            NUMBER,
                              P_INVENTORY_ITEM_ID	      NUMBER,
                              P_GROUP_ID		            NUMBER,
                              P_TASK_METHOD_ID           NUMBER,
                              P_TASK_TYPE_ID		         NUMBER,
                              P_GROUPED_TASK_IDENTIFIER	NUMBER,
                              P_GROUP_SIZE		         NUMBER,
                              P_TRANSACTION_TIME	      NUMBER,
                              P_TRAVEL_AND_IDLE_TIME	   NUMBER,
                              P_CREATED_BY		         NUMBER,
                              P_OPERATION_PLAN_ID        NUMBER,
                              X_RETURN_STATUS   OUT      NOCOPY VARCHAR2
   ) AS
   PRAGMA AUTONOMOUS_TRANSACTION;

   BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(IS_USER_NON_TRACKED (
                             P_USER_ID=>P_USER_ID,
                             P_ORG_ID =>P_ORGANIZATION_ID
                             )
         ) THEN
         /* Since this is a non-tracked user, do not
            enter any record for this transaction */
         IF g_debug=1 THEN
            debug('Since this is a non-tracked user: ' || P_USER_ID || ', do not enter any record for this transaction');
         END IF;

         RETURN;
      END IF;


      INSERT INTO WMS_ELS_TRX_SRC
      (
         ELS_TRX_SRC_ID,
         TRANSACTION_DATE,
         ACTIVITY_ID,
         ACTIVITY_DETAIL_ID,
         OPERATION_ID,
         ORGANIZATION_ID,
         USER_ID,
         EQUIPMENT_ID,
         SOURCE_SUBINVENTORY,
         DESTINATION_SUBINVENTORY,
         FROM_LOCATOR_ID,
         TO_LOCATOR_ID,
         LABOR_TXN_SOURCE_ID,
         TRANSACTION_UOM,
         QUANTITY,
         INVENTORY_ITEM_ID,
         GROUP_ID,
         TASK_METHOD_ID,
         TASK_TYPE_ID,
         GROUPED_TASK_IDENTIFIER,
         GROUP_SIZE,
         TRANSACTION_TIME,
         TRAVEL_AND_IDLE_TIME,
         CREATION_DATE,
         CREATED_BY,
         OPERATION_PLAN_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY
      )
      values
      (
         WMS_ELS_TRX_SRC_S.NEXTVAL,
         SYSDATE,
         P_ACTIVITY_ID,
         P_ACTIVITY_DETAIL_ID,
         P_OPERATION_ID,
         P_ORGANIZATION_ID,
         P_USER_ID,
         P_EQUIPMENT_ID,
         P_SOURCE_SUBINVENTORY,
         P_DESTINATION_SUBINVENTORY,
         P_FROM_LOCATOR_ID,
         P_TO_LOCATOR_ID,
         P_LABOR_TXN_SOURCE_ID,
         P_TRANSACTION_UOM,
         P_QUANTITY,
         P_INVENTORY_ITEM_ID,
         P_GROUP_ID,
         P_TASK_METHOD_ID,
         P_TASK_TYPE_ID,
         P_GROUPED_TASK_IDENTIFIER,
         P_GROUP_SIZE,
         P_TRANSACTION_TIME,
         P_TRAVEL_AND_IDLE_TIME,
         SYSDATE,
         P_CREATED_BY,
         P_OPERATION_PLAN_ID,
         SYSDATE,
         P_CREATED_BY
      );
      commit;

      IF g_debug=1 THEN
         debug('Successfully inserted record in WMS_ELS_TRX_SRC table');
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF g_debug=1 THEN
                  debug('Insertion in WMS_ELS_TRX_SRC failed'||SQLERRM);
               END IF;

   END INSERT_ELS_TRX;


END WMS_LMS_UTILS;


/
