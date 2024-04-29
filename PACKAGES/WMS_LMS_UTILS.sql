--------------------------------------------------------
--  DDL for Package WMS_LMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_LMS_UTILS" AUTHID CURRENT_USER AS
/* $Header: WMSLUTLS.pls 120.7.12010000.1 2008/07/28 18:35:01 appldev ship $ */

G_PKG_NAME  VARCHAR2(30) := 'WMS_LMS_UTILS';


/** This function check that a given org is labor management enabled or not.<br>
* @param p_org_id                     The organization Id
*/

FUNCTION ORG_LABOR_MGMT_ENABLED ( p_org_id NUMBER) RETURN BOOLEAN;

/** This function check that a given zone in a given org is labor management enabled or not.<br>
* @param p_org_id                     The organization Id
* @param p_zone_id                     The zone Id
*/

FUNCTION ZONE_LABOR_MGMT_ENABLED ( p_org_id  IN NUMBER,
                                   p_zone_id IN NUMBER
                                  )
RETURN VARCHAR2;


/** This function check that a given user is a non-tracked user or not.<br>
* @param p_user_id                     The organization Id
*/
FUNCTION IS_USER_NON_TRACKED ( p_user_id IN NUMBER,
                               p_org_id  IN NUMBER )
RETURN BOOLEAN;


/** This procedure is launched from a concurrent request and it will purge all<br>
*   the setup rows in WMS_ELS_INDIVIDUAL_TASKS_B thable that are marked as history records <br>
*   This program will also delete the transactions in the WMS_ELS_TRX_SRC table
*   which had been costed against the purged history setup records
* @param p_org_id                     The organization Id
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of the is program.
                                      Whether this program is a success, warning or a failure
*/
PROCEDURE PURGE_LMS_SETUP_HISTORY
                                  (errbuf               OUT    NOCOPY VARCHAR2,
                                   retcode              OUT    NOCOPY NUMBER,
                                   p_org_id             IN     NUMBER,
                                   p_purge_date         IN     VARCHAR2
                                   );

/** This procedure is launched from a concurrent request and it will purge all<br>
*   the transactions in the WMS_ELS_TRX_SRC table that have been done before the <br>
*   given purge date
* @param p_org_id                     The organization Id
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of the is program.
                                      Whether this program is a success, warning or a failure
* @param p_purge_date                 This is the in parameter which gives that date before which all
                                      transaction records have to be purged
*/
PROCEDURE PURGE_LMS_TRANSACTIONS
                                  (errbuf               OUT    NOCOPY VARCHAR2,
                                   retcode              OUT    NOCOPY NUMBER,
                                   p_org_id             IN     NUMBER,
                                   p_purge_date   IN     VARCHAR2
                                   );

/** This procedure is launched from a concurrent request and it will copy all<br>
*   the expected time components to actuals in the wms_els-individual_tasks table <br>
* @param p_org_id                     The organization Id
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of the is program.
                                      Whether this program is a success, warning or a failure
*/
PROCEDURE COPY_ACTUAL_TIMINGS      (   errbuf               OUT    NOCOPY VARCHAR2
                                      , retcode              OUT    NOCOPY NUMBER
                      	              , p_org_id             IN            NUMBER
                                    ) ;

/** This procedure is launched from a concurrent request and it calculates the actuals<br>
*   based on the average of the time taken for the actula transactions. The number of trxns<br>
*   needs to be considered for this averaging is based on the setup done in the <br>
*   global setup for moving average value. <br>
* @param p_org_id                     The organization Id
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of the is program.
                                      Whether this program is a success, warning or a failure
*/
PROCEDURE CALCULATE_ACTUAL_TIMINGS  (   errbuf               OUT    NOCOPY VARCHAR2
                                      , retcode              OUT    NOCOPY NUMBER
                      	              , p_org_id             IN            NUMBER
                                    );

/** This function is called from the concurrent program "Expected Resource Requirement Analysis"<br>
*   This fuction will return TRUE  if more rows are left non matched after a certain pass of the <br>
*   setup data. It will return FALSE when no more rows are left to process. This fucntion will be  <br>
*   used to exit the processing once all rows in wms_els_trx_src are exhaused even before <br>
*   all the rows in setup are exhausted.
* @param p_org_id                    The Organization_id
*/
FUNCTION unprocessed_rows_remaining ( p_org_id NUMBER )
RETURN NUMBER;


/** This function is called from the concurrent program "Labor Productivity Analysis" <br>
*   This fuction will return TRUE  if more rows are left non matched after a certain pass of the <br>
*   setup data. It will return FALSE when no more rows are left to process. This fucntion will be  <br>
*   used to exit the processing once all rows in wms_els_trx_src are exhaused even before <br>
*   all the rows in setup are exhausted. This fuction is overloaded
* @param p_org_id                    The Organization_id
*/
FUNCTION unprocessed_rows_remaining ( p_org_id NUMBER,
                                      p_max_id NUMBER )
RETURN NUMBER;


/** This function is called from the reports main page in OA to get the <br>
*   argument values that have been used for the last run of the concurrent program
* @param p_org_id                    The organization Id for the concurrent program last run
* @param  p_concurrent_program_id    Concurrent Program ID
*/
FUNCTION get_parameter_string(p_concurrent_program_id IN NUMBER,
                              p_org_id IN NUMBER)
RETURN VARCHAR2;


/** This function is called from the reports main page in OA to get the <br>
*   next scheduled time for the of the concurrent programs
* @param  p_org_id                    The organization Id for the concurrent program last run
* @param  p_concurrent_program_id     Concurrent Program ID
* @param  p_application_id            application Id for the concurrent program
*/
FUNCTION get_next_scheduled_time ( p_concurrent_program_id IN NUMBER,
	                               p_application_id        IN NUMBER,
								   p_org_id                IN NUMBER
                                 )
RETURN VARCHAR2;

/** This function is called from the reports main page in OA to get the <br>
*   last run time for the of the concurrent programs
* @param  p_org_id                    The organization Id for the concurrent program last run
* @param  p_concurrent_program_id     Concurrent Program ID
*/

FUNCTION last_run_time( p_concurrent_program_id IN NUMBER,
                           p_org_id IN NUMBER
					     )
RETURN VARCHAR2;

/** This function is called from the reports main page in OA to get the <br>
*   last run time for the of the concurrent programs which completed Normal
* @param  p_org_id                    The organization Id for the concurrent program last run
* @param  p_concurrent_program_id     Concurrent Program ID
*/
FUNCTION last_run_time_success (  p_concurrent_program_id IN NUMBER,
                                  p_org_id IN NUMBER
					           )
RETURN VARCHAR2;

/** This function is called from the reports main page in OA to get the <br>
*   last run status for the of the concurrent programs
* @param  p_org_id                    The organization Id for the concurrent program last run
* @param  p_concurrent_program_id     Concurrent Program ID
*/
FUNCTION last_run_status ( p_concurrent_program_id IN NUMBER,
                           p_org_id IN NUMBER
					     )
RETURN VARCHAR2;

/** This function is called from the Summary Main page in OA to get the <br>
*   Work Outstanding string for all the Activity, Activity Details combinations
* @param  l_ActivityId        Activity ID
* @param  l_ActivityDetailId  Activity Detail ID
* @param  l_OrgId             The organization Id selected by the user
*/

FUNCTION getWorkOutstanding ( l_ActivityId IN NUMBER,
                              l_ActivityDetailId IN NUMBER,
                              l_OrgId IN NUMBER
				            )
RETURN VARCHAR2;


/** This function is called from the Summary Main page in OA to get the <br>
*   Work Outstanding string for all the Activity, Activity Details combinations for graphs
* @param  l_ActivityId        Activity ID
* @param  l_ActivityDetailId  Activity Detail ID
* @param  l_OrgId             The organization Id selected by the user
*/
FUNCTION getWorkOutstandingGraphData(l_ActivityId NUMBER,
                                     l_ActivityDetailId NUMBER,
                                     l_OrgId NUMBER
                                     )
   RETURN NUMBER;


/** This function is called from different LMS pages in OA to get the <br>
*   rating for the corresponding point sent.
* @param  p_points   Value sent.
*/
FUNCTION getratingfrompoints (p_points NUMBER)
RETURN VARCHAR2;

/** This function is called from the Non Standardized Lines page in OA to Standardize <br>
*   the selected Non-Standard Lines
* @param  P_COPY_ID        Comma Separated String of els_trx_src_id's for all the selected Non-Standard Lines
* @param  P_COPY_ANALYSIS  Comma Separated String of analysis id's selected for all the selected Non-Standard Lines
* @param  P_ORG_ID         The organization Id selected by the user
* @param  X_NUM_LINES_INSERTED_TASKS Number of lines that are inserted into the individual Tasks Table (Either for Individual or Grouped Tasks)
* @param  X_RETURN_STATUS  Status message whether the standardizing is successful or Failure.
* @param  X_MSG_NAME       Name of the Message that has to be shown in case of Failure.
*/


PROCEDURE STANDARDIZE_LINES(
			                     X_NUM_LINES_INSERTED_TASKS         OUT NOCOPY NUMBER
                            , X_NUM_LINES_INSERTED_GROUP         OUT NOCOPY NUMBER
   			                , X_RETURN_STATUS                    OUT NOCOPY VARCHAR2
                            , X_MSG_NAME                         OUT NOCOPY VARCHAR2
			                   , P_COPY_ID                          IN  VARCHAR2
			                   , P_COPY_ANALYSIS			           IN  VARCHAR2
                            , P_ORG_ID                           IN  NUMBER
	                        );

/** This procedure is launched from a concurrent request and it Standardizes all<br>
*   non-standardized lines based on the value of value of the parameters passed <br>
*   for activity, activity detail, operation, from date and to date.<br>
* @param errbuf                       This is the out message having the buffer of the return message
* @param retcode                      This variable is a out variable having the return code of the is program.
                                      Whether this program is a success, warning or a failure
* @param p_org_id                     The organization Id
* @param p_activity_id                What is the activity ID (1-Inbound, 2- Manufacturing etc)
* @param p_activity_detail_Id          What is the activity detail Id(1-Receipt, 2-Putaway etc)
* @param p_operation_id               What is the operation (1-Load, 2-Drop etc..)
* @param p_from_date                  What is the date after which all transactions need to be picked for standardization
* @param p_to_date                   What is the date prior to which all transactions need to be picked for standardization
*/
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
	                          );

/** This procedure is called from Mobile Transaction pages to capture the
*   Transaction data.
*   Calling Program: oracle.apps.inv.utilities.server.UtilFns.java
*   Author: Anupam Jain
*
* @P_ACTIVITY_ID              Activity Id (lookup code for WMS_ELS_ACTIVITIES)
* @P_ACTIVITY_DETAIL_ID       Activity Detail Id (lookup code for WMS_ELS_ACTIVITY_DETAILS)
* @P_OPERATION_ID		         Operaiton Id (lookup code for WMS_ELS_OPERATIONS)
* @P_ORGANIZATION_ID	         Current Organization
* @P_USER_ID		            Curent User
* @P_EQUIPMENT_ID		         Current Equipment instance
* @P_SOURCE_SUBINVENTORY	   Source Sub code
* @P_DESTINATION_SUBINVENTORY Destination Sub code
* @P_FROM_LOCATOR_ID	         From Locator Id
* @P_TO_LOCATOR_ID		      To Loactor Id
* @P_LABOR_TXN_SOURCE_ID	   lookup code for WMS_ELS_TXN_TYPES
* @P_TRANSACTION_UOM	         Transaction UOM
* @P_QUANTITY		            Quantity transacted
* @P_INVENTORY_ITEM_ID	      Item id
* @P_GROU@P_ID		            lookup code for WMS_ELS_TASK_EXECUTION_MODES
* @P_TASK_METHOD_ID           Lookup code for WMS_ELS_TASK_METHODS
* @P_TASK_TYPE_ID		         User task type id
* @P_GROUPED_TASK_IDENTIFIER	based on sequence WMS_ELS_GRP_TASK_IDENTIFIER_S
                              All the tasks with same vaue for this column belongs
                              to one group.

* @P_GROU@P_SIZE		         Primarily used for Number of groups in Cluster Group.
* @P_TRANSACTION_TIME	      Time taken for Transaction
* @P_TRAVEL_AND_IDLE_TIME	   Time taken for Travel and Idle activities
* @P_CREATED_BY		         WHO cloumn
* @P_OPERATION_PLAN_ID        Operation Plan Id
* @X_RETURN_STATUS            Return status of this procedure

*/


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
);

END WMS_LMS_UTILS;


/
