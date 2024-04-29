--------------------------------------------------------
--  DDL for Package Body CS_SR_PURGE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_PURGE_CP" AS
/* $Header: csvsrpgb.pls 120.9 2006/05/18 17:57:09 varnaray noship $ */
--------------------------------------------------------------------------------
-- Package level definitions
--------------------------------------------------------------------------------
g_pkg_name CONSTANT VARCHAR2(30) := 'CS_SR_PURGE_CP';

PROCEDURE Validate_Purge_Params
(
  p_incident_id                   IN              NUMBER
, p_incident_status_id            IN              NUMBER
, p_incident_type_id              IN              NUMBER
, p_creation_from_date            IN              VARCHAR2
, p_creation_to_date              IN              VARCHAR2
, p_last_update_from_date         IN              VARCHAR2
, p_last_update_to_date           IN              VARCHAR2
, x_creation_from_date            OUT NOCOPY      DATE
, x_creation_to_date              OUT NOCOPY      DATE
, x_last_update_from_date         OUT NOCOPY      DATE
, x_last_update_to_date           OUT NOCOPY      DATE
, p_not_updated_since             IN              VARCHAR2
, p_customer_id                   IN              NUMBER
, p_customer_acc_id               IN              NUMBER
, p_item_category_id              IN              NUMBER
, p_inventory_item_id             IN              NUMBER
, p_history_size                  IN              NUMBER
, p_number_of_workers             IN              NUMBER
, p_purge_batch_size              IN              NUMBER
, p_purge_source_with_open_task   IN              VARCHAR2
, p_audit_required                IN              VARCHAR2
, x_msg_count                     OUT NOCOPY      NUMBER
, x_msg_data                      OUT NOCOPY      VARCHAR2
);

PROCEDURE Form_And_Exec_Statement
(
  p_incident_id                   IN              NUMBER
, p_incident_status_id            IN              NUMBER
, p_incident_type_id              IN              NUMBER
, p_creation_from_date            IN              DATE
, p_creation_to_date              IN              DATE
, p_last_update_from_date         IN              DATE
, p_last_update_to_date           IN              DATE
, p_customer_id                   IN              NUMBER
, p_customer_acc_id               IN              NUMBER
, p_item_category_id              IN              NUMBER
, p_inventory_item_id             IN              NUMBER
, p_history_size                  IN              NUMBER
, p_number_of_workers             IN OUT NOCOPY   NUMBER
, p_purge_batch_size              IN              NUMBER
, p_request_id                    IN              NUMBER
, p_row_count                     OUT NOCOPY      NUMBER
);

PROCEDURE Write_Purge_Output
(
  p_purge_batch_size              IN              NUMBER
, p_request_id                    IN              NUMBER
, p_worker_id                     IN              NUMBER := NULL
);

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--  Procedure Name         :   PURGE_SERVICEREQUESTS
--
-- Parameters (other than standard ones)
--
-- IN OUT
-- errbuf                  : This parameter is not used but is a standard
--                           parameter for concurrent program procedures.
--                           The function fnd_concurrent.set_completion_status
--                           is called instead.
-- errcode                 : This parameter is not used but is a standard
--                           parameter for concurrent program procedures.
--                           The function fnd_concurrent.set_completion_status
--                           is called instead.
--
-- IN
-- p_incident_id           : Indicates that SR with this id needs
--                           to be purged
-- p_incident_status_id    : Indicates that SR with this status id
--                           needs to be purged
-- p_incident_type_id      : Indicates that SRs with this type id
--                           needs to be purged
-- p_creation_from_date    : Indicates the lower end of the range of dates
--                           that need to be compared with CREATION_DATE of
--                           the SR to pick it up for purge
-- p_creation_to_date      : Indicates the higher end of the range of dates
--                           that need to be compared with CREATION_DATE of
--                           the SR to pick it up for purge
-- p_last_update_from_date : Indicates the lower end of the range of dates
--                           that need to be compared with LAST_UPDATED_DATE of
--                           the SR to pick it up for purge
-- p_last_update_to_date   : Indicates the higher end of the range of dates
--                           that need to be compared with LAST_UPDATED_DATE of
--                           the SR to pick it up for purge
-- p_not_updated_since     : This is a set of values like 1Y,2Y etc. which
--                           shall be compared with the LAST_UPDATED_DATE of the
--                           the SR to pick it up for purge
-- p_customer_id           : Indicates that SRs with this customer_id need
--                           to be purged.
-- p_customer_acc_id       : Indicates that SRs with this customer acc id
--                           need to be purged
-- p_item_category_id      : Indicates that SRs created for items falling
--                           under this category need to be purged
-- p_inventory_item_id     : Indicates that SRs created for this item
--                           need to be purged
-- p_history_size          : Number of  customer SR's to retain while purging
--                           SRs identified using other parameters. This param
--                           alone CANNOT be used to identify a valid purgeset.
-- p_number_of_workers     : Number of workers that needs to be launched for
--                           purging Service Requests
-- p_purge_batch_size      : Number of Service Requests that needs to be purged
--                           in a batch
-- p_purge_source_with_open_task :
--                           This signifies if the Tasks Validation API can
--                           delete tasks that are open. If this is N, only SRs
--                           linked to closed Tasks are allowed to be purged.
--                           If this is Y, all SRs, irrespective of whether the
--                           Tasks linked tothem are open or closed, can be
--                           deleted.
-- p_audit_required        : This indicates if the SR Delete API should write
--                           the purge audit information. If this is N, no rows
--                           are inserted into the table
--                           CS_INCIDENTS_PURGE_AUDIT_B and TL. If this is Y,
--                           audit rows are inserted into these tables.
--
-- Note: The above parameters are not mandatory and may contain NULL values.
--       If these have been sent NULL, it means that the parameter should not be
--       considered for identifying SRs to be purged. A where clause shall be
--       constructed using values sent in these parameters and this will be used
--       to identify SRs that need to be purged.
--
-- Description
--     This procedure accepts the above list of parameters to identify the SRs
--     that need to be purged. It constructs a WHERE clause out of these
--     parameters after validating them. This WHERE clause is appended to a
--     query on the table CS_INCIDENTS_ALL_B and result of this query is
--     inserted into a staging table CS_INCIDENTS_PURGE_STAGING after which
--     the rows are divided among the number of worker concurrent programs
--     using a formula 'mod(rownum - 1, <no. of workers>) + 1'. After that
--     the child concurrent requests are launched and the SRs are purged. This
--     procedure waits for all the child concurrent requests to complete
--     purging the SRs allocated to them and then ends.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--   2-Aug_2005 | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure accepts the above list of parameters to identify the SRs that
 * need to be purged. It constructs a WHERE clause out of these parameters after
 * validating them. This WHERE clause is appended to a query on the table
 * CS_INCIDENTS_ALL_B and result of this query is inserted into a staging table
 * CS_INCIDENTS_PURGE_STAGING after which the rows are divided among the number
 * of worker concurrent programs using a formula 'mod(rownum - 1,
 * <no. of workers>) + 1'. After that the child concurrent requests are
 * launched and the SRs are purged. This procedure waits for all the child
 * concurrent requests to complete purging the SRs allocated to them and then
 * ends.
 * @param errbuf This parameter is not used but is a standard parameter for
 * concurrent program procedures. The function fnd_concurrent.
 * set_completion_status is called instead.
 * @param errcode This parameter is not used but is a standard parameter
 * for concurrent program procedures. The function fnd_concurrent.
 * set_completion_status is called instead.
 * @param p_incident_id Indicates that SR with this id needs to be purged
 * @param p_incident_status_id Indicates that SR with this status id needs
 * to be purged
 * @param p_incident_type_id Indicates that SRs with this type id needs to
 * be purged
 * @param p_creation_from_date Indicates the lower end of the range of dates
 * that need to be compared with CREATION_DATE of the SR to pick it up for purge
 * @param p_creation_to_date Indicates the higher end of the range of dates that
 * need to be compared with CREATION_DATE of the SR to pick it up for purge
 * @param p_last_update_from_date Indicates the lower end of the range of dates
 * that need to be compared with LAST_UPDATED_DATE of the SR to pick it
 * up for purge
 * @param p_last_update_to_date Indicates the higher end of the range of dates
 * that need to be compared with LAST_UPDATED_DATE of the SR to pick it up for
 * purge
 * @param p_not_updated_since This is a set of values like 1Y,2Y etc. which
 * shall be compared with the LAST_UPDATED_DATE of the the SR to pick it up
 * for purge
 * @param p_customer_id Indicates that SRs with this customer_id need to
 * be purged.
 * @param p_customer_acc_id Indicates that SRs with this customer acc id need
 * to be purged
 * @param p_item_category_id Indicates that SRs created for items falling
 * under this category need to be purged
 * @param p_inventory_item_id Indicates that SRs created for this item need
 * to be purged
 * @param p_history_size Number of  customer SR's to retain while purging SRs
 * identified using other parameters. This parameter alone CANNOT be used to
 * identify a valid purgeset.
 * @param p_number_of_workers Number of workers that needs to be launched
 * for purging Service Requests
 * @param p_purge_batch_size Number of Service Requests that needs to be purged
 * in a batch
 * @param p_purge_source_with_open_task This signifies if the Tasks Validation
 * API can delete tasks that are open. If this is N, only SRs linked to closed
 * Tasks are allowed to be purged. If this is Y, all SRs, irrespective of
 * whether the Tasks linked to them are open or closed, can be deleted.
 * @param p_audit_required This indicates if the SR Delete API should write
 * the purge audit information. If this is N, no rows are inserted into the
 * table CS_INCIDENTS_PURGE_AUDIT_B and TL. If this is Y, audit rows are
 * inserted into these tables.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Purge Service Requests Concurrent Program
 */
PROCEDURE Purge_ServiceRequests
(
  errbuf                          IN OUT NOCOPY VARCHAR2
, errcode                         IN OUT NOCOPY INTEGER
, p_api_version_number            IN            NUMBER
, p_init_msg_list                 IN            VARCHAR2
, p_commit                        IN            VARCHAR2
, p_validation_level              IN            NUMBER
, p_incident_id                   IN            NUMBER
, p_incident_status_id            IN            NUMBER
, p_incident_type_id              IN            NUMBER
, p_creation_from_date            IN            VARCHAR2
, p_creation_to_date              IN            VARCHAR2
, p_last_update_from_date         IN            VARCHAR2
, p_last_update_to_date           IN            VARCHAR2
, p_not_updated_since             IN            VARCHAR2
, p_customer_id                   IN            NUMBER
, p_customer_acc_id               IN            NUMBER
, p_item_category_id              IN            NUMBER
, p_inventory_item_id             IN            NUMBER
, p_history_size                  IN            NUMBER
, p_number_of_workers             IN            NUMBER
, p_purge_batch_size              IN            NUMBER
, p_purge_source_with_open_task   IN            VARCHAR2
, p_audit_required                IN            VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'PURGE_SERVICEREQUESTS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255):= 'cs.plsql.' || L_API_NAME_FULL || '.';

-- PL/SQL table defined to hold the ids of the child
-- concurrent requests. This will be used to check
-- their statuses in a loop.

TYPE t_worker_conc_req_arr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

L_EXC_PURGE_WARNING             EXCEPTION;

x_msg_index_out                 NUMBER;
x_msg_count                     NUMBER;
x_msg_data                      VARCHAR2(1000);
x_return_status                 VARCHAR2(1);

-- Request id of the current
-- concurrent request.

l_request_id                    NUMBER;

-- Request data used to identify if the concurrent
-- request is started for the first time or if it
-- is resumed from a PAUSED state.

l_request_data                  VARCHAR2(1);

-- variables defined for holding the validated
-- value of the dates that are received as
-- VARCHARs from the concurrent program UI

l_creation_from_date            DATE;
l_creation_to_date              DATE;
l_last_update_from_date         DATE;
l_last_update_to_date           DATE;

l_row_count                     NUMBER;
l_ret                           BOOLEAN;

-- Actual number of worker concurrent requests
-- to be started based on the number of SRs in
-- the purgeset.

l_number_of_workers             NUMBER := p_number_of_workers;

-- Table of request ids of the worker concurrent request

l_worker_conc_req_arr           t_worker_conc_req_arr;

-- Variables holding the status information of each
-- worker concurrent request

l_worker_conc_req_phase         VARCHAR2(100);
l_worker_conc_req_status        VARCHAR2(100);
l_worker_conc_req_dev_phase     VARCHAR2(100);
l_worker_conc_req_dev_status    VARCHAR2(100);
l_worker_conc_req_message       VARCHAR2(512);

-- Variables holding the status information of
-- the parent concurrent request

l_main_conc_req_phase           VARCHAR2(100);
l_main_conc_req_status          VARCHAR2(100);
l_main_conc_req_dev_phase       VARCHAR2(100);
l_main_conc_req_dev_status      VARCHAR2(100);
l_main_conc_req_message         VARCHAR2(512);
l_child_message                 VARCHAR2(4000);

CURSOR c_child_request
(
  c_request_id    NUMBER
)
IS
  SELECT
    request_id
  FROM
    fnd_concurrent_requests
  WHERE
    parent_request_id = c_request_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start_time'
    , 'The start time is ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'errbuf:' || errbuf
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'errcode:' || errcode
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_incident_id:' || p_incident_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_incident_status_id:' || p_incident_status_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 9'
    , 'p_incident_type_id:' || p_incident_type_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 10'
    , 'p_creation_from_date:' || p_creation_from_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 11'
    , 'p_creation_to_date:' || p_creation_to_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 12'
    , 'p_last_update_from_date:' || p_last_update_from_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 13'
    , 'p_last_update_to_date:' || p_last_update_to_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 14'
    , 'p_not_updated_since:' || p_not_updated_since
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 15'
    , 'p_customer_id:' || p_customer_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 16'
    , 'p_customer_acc_id:' || p_customer_acc_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 17'
    , 'p_item_category_id:' || p_item_category_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 18'
    , 'p_inventory_item_id:' || p_inventory_item_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 19'
    , 'p_history_size:' || p_history_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 20'
    , 'p_number_of_workers:' || p_number_of_workers
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 21'
    , 'p_purge_batch_size:' || p_purge_batch_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 22'
    , 'p_purge_source_with_open_task:' || p_purge_source_with_open_task
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 23'
    , 'p_audit_required:' || p_audit_required
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , g_pkg_name
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'get_request_info_start'
    , 'Getting Current Concurrent Request ID '
    );
  END IF;

  -- preserving this concurrent request's
  -- request_id in a local variable

  l_request_id   := fnd_global.conc_request_id;
  l_request_data := fnd_conc_global.request_data;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'get_request_info_end'
    , 'After Getting Current Concurrent Request ID ' || l_request_id ||
        '(' || NVL(l_request_data, 'NULL') || ')'
    );
  END IF;

  ---

  IF l_request_data IS NULL

    -- This portion of the code is executed when the concurrent request is
    -- invokedby the user. This time, the request data is NULL indicating
    -- that the request is started newly.

  THEN

    ----------------------------------------------------------------------------
    -- Cleanup process: Delete all the rows in the staging table corresponding
    -- to completed concurrent programs that have been left behind by an earlier
    -- execution of this concurrent program.
    ----------------------------------------------------------------------------

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'cleanup_start'
      , 'deleting rows in staging table that were not cleared earlier'
      );
    END IF;

    DELETE cs_incidents_purge_staging
    WHERE
      concurrent_request_id IN
      (
      SELECT
        request_id
      FROM
        fnd_concurrent_requests r
      , fnd_concurrent_programs p
      WHERE
          r.phase_code              = 'C'
      AND p.concurrent_program_id   = r.concurrent_program_id
      AND p.concurrent_program_name = 'CSSRPGP'
      AND p.application_id          = 170
      );

    l_row_count := SQL%ROWCOUNT;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'cleanup_end'
      , 'after deleting rows in staging table that were not cleared earlier '
        || l_row_count || ' rows'
      );
    END IF;

    -- Committing the changes in order to make
    -- the rows unavailable to all sessions.

    COMMIT;

    ----------------------------------------------------------------------------
    -- Purge Parameter Validations:
    ----------------------------------------------------------------------------

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_validate_param_start'
      , 'Calling procedure to validate purge parameters'
      );
    END IF;

    -- calling a private procedure to perform validations on all the
    -- purge parameters and throw corresponding exceptions in case
    -- there are any errors

    Validate_Purge_Params
    (
      p_incident_id                   =>  p_incident_id
    , p_incident_status_id            =>  p_incident_status_id
    , p_incident_type_id              =>  p_incident_type_id
    , p_creation_from_date            =>  p_creation_from_date
    , p_creation_to_date              =>  p_creation_to_date
    , p_last_update_from_date         =>  p_last_update_from_date
    , p_last_update_to_date           =>  p_last_update_to_date
    , p_not_updated_since             =>  p_not_updated_since
    , p_customer_id                   =>  p_customer_id
    , p_customer_acc_id               =>  p_customer_acc_id
    , p_item_category_id              =>  p_item_category_id
    , p_inventory_item_id             =>  p_inventory_item_id
    , p_history_size                  =>  p_history_size
    , p_number_of_workers             =>  p_number_of_workers
    , p_purge_batch_size              =>  p_purge_batch_size
    , p_purge_source_with_open_task   =>  p_purge_source_with_open_task
    , p_audit_required                =>  p_audit_required
    , x_creation_from_date            =>  l_creation_from_date
    , x_creation_to_date              =>  l_creation_to_date
    , x_last_update_from_date         =>  l_last_update_from_date
    , x_last_update_to_date           =>  l_last_update_to_date
    , x_msg_count                     =>  x_msg_count
    , x_msg_data                      =>  x_msg_data
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_validate_param_end'
      , 'After calling procedure to validate purge parameters'
      );
    END IF;

    ---

    ----------------------------------------------------------------------------
    -- Preparation of Staging Table Data and Submission of Child Requests
    ----------------------------------------------------------------------------

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_form_and_exec_statement_start'
      , 'Calling procedure to form and execute statement to fill staging table'
      );
    END IF;

    -- Calling the procedure to form an SQL statement
    -- that will insert the rows that need to be purged
    -- as per the parameters passed by the user, into
    -- the Staging table.

    Form_And_Exec_Statement
    (
      p_incident_id           => p_incident_id
    , p_incident_status_id    => p_incident_status_id
    , p_incident_type_id      => p_incident_type_id
    , p_creation_from_date    => l_creation_from_date
    , p_creation_to_date      => l_creation_to_date
    , p_last_update_from_date => l_last_update_from_date
    , p_last_update_to_date   => l_last_update_to_date
    , p_customer_id           => p_customer_id
    , p_customer_acc_id       => p_customer_acc_id
    , p_item_category_id      => p_item_category_id
    , p_inventory_item_id     => p_inventory_item_id
    , p_history_size          => p_history_size
    , p_number_of_workers     => l_number_of_workers
    , p_purge_batch_size      => p_purge_batch_size
    , p_request_id            => l_request_id
    , p_row_count             => l_row_count
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_form_and_exec_statement_end'
      , 'After calling procedure to form and execute statement to '
        || 'fill staging table ' || l_row_count
      );
    END IF;

    ---

    IF l_row_count = 0
    THEN

      -- If there were no SRs selected to be purged, return
      -- from the concurrent program with a warning

      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'no_rows_to_purge'
        , 'There were no rows to purge. Row count was ' || l_row_count
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_NO_SRS_TO_PURGE');
      FND_MSG_PUB.ADD;

      RAISE L_EXC_PURGE_WARNING;
    END IF;

    ---

    -- Start worker concurrent programs: Here if the number of
    -- SRs to be purged is lesser than the no.of workers, only
    -- one worker is started per SR. This is an optimization for
    -- Case management.

    FOR
      j IN 1..l_number_of_workers
    LOOP
      l_worker_conc_req_arr(j) := FND_REQUEST.Submit_Request
      (
        application => 'CS'
      , program     => 'CSSRPGW'
      , description => TO_CHAR(j)
      , start_time  => NULL
      , sub_request => TRUE
      , argument1   => p_api_version_number
      , argument2   => p_init_msg_list
      , argument3   => p_commit
      , argument4   => p_validation_level
      , argument5   => j                             -- p_worker_id
      , argument6   => p_purge_batch_size
      , argument7   => l_request_id                  -- p_purge_set_id
      , argument8   => p_purge_source_with_open_task
      , argument9   => p_audit_required
      );

      IF
        l_worker_conc_req_arr(j) = 0
      THEN
        -- If the worker request was not created successfully
        -- raise an unexpected exception and terminate the
        -- process.

        IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'create_workers_error'
          , 'Failed while starting worker concurrent request'
          );
        END IF;

        FND_MESSAGE.Set_Name('CS', 'CS_SR_SUBMIT_CHILD_FAILED');
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'create_workers_doing'
        , 'After starting worker ' || l_worker_conc_req_arr(j)
        );
      END IF;
    END LOOP;

    -- Committing so that the worker concurrent program that
    -- was submitted above is started by the concurrent manager.

    COMMIT;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'create_workers_end'
      , 'After starting all worker concurrent requests'
      );
    END IF;

    ---

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'move_parent_to_paused_start'
      , 'Moving parent concurrent request to paused status'
      );
    END IF;

    -- Moving the parent concurrent request to Paused
    -- status in order to start the child

    fnd_conc_global.set_req_globals
    (
      conc_status  => 'PAUSED'
    , request_data => '1'
    );

    COMMIT;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'move_parent_to_paused_end'
      , 'After moving parent concurrent request to paused status'
      );
    END IF;

    -- At this point, execution of the parent request, invoked for the
    -- first time, gets over. Here the parent request is moved to a
    -- paused status after which the procedure execution ends.

  ELSIF l_request_data IS NOT NULL

    -- If the concurrent request is restarted from the PAUSED state,
    -- this portion of the code is executed. When all the child
    -- requests have completed their work, (their PHASE_CODE
    -- is 'COMPLETED') the concurrent manager restarts the parent. This
    -- time, the request_data returns a Non NULL value and so this
    -- portion of the code is executed.

  THEN

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'collect_child_status_start'
      , 'Collecting child completion status'
      );
    END IF;

    l_main_conc_req_dev_status := 'NORMAL';

    -- check status of worker concurrent request
    -- to arrive at the parent request's
    -- completion status

    FOR r_child_request IN c_child_request(l_request_id)
    LOOP
      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'collect_a_child_status'
        , 'Worker Concurrent Request No : ' || r_child_request.request_id
        );
      END IF;

      IF  FND_CONCURRENT.Get_Request_Status
          (
            request_id => r_child_request.request_id
          , phase      => l_worker_conc_req_phase
          , status     => l_worker_conc_req_status
          , dev_phase  => l_worker_conc_req_dev_phase
          , dev_status => l_worker_conc_req_dev_status
          , message    => l_worker_conc_req_message
          )
      THEN
        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'child_return_status'
          , 'l_worker_conc_req_phase:' || l_worker_conc_req_phase
          );
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'child_return_status'
          , 'l_worker_conc_req_status:' || l_worker_conc_req_status
          );
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'child_return_status'
          , 'l_worker_conc_req_dev_phase:' || l_worker_conc_req_dev_phase
          );
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'child_return_status'
          , 'l_worker_conc_req_dev_status:' || l_worker_conc_req_dev_status
          );
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'child_return_status'
          , 'l_worker_conc_req_message:' || l_worker_conc_req_message
          );
        END IF;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'resolve_main_dev_status_start'
          , 'Resolving l_main_conc_req_dev_status'
          );
        END IF;

        -- If the current worker has completed its work, based
        -- on the return status of the worker, mark the completion
        -- status of the main concurrent request.

        IF l_worker_conc_req_dev_status <> 'NORMAL'
        THEN
          IF  l_main_conc_req_dev_status IN ('WARNING', 'NORMAL')
          AND l_worker_conc_req_dev_status IN ('ERROR', 'DELETED', 'TERMINATED')
          THEN
            l_main_conc_req_dev_status := 'ERROR';
            l_child_message            := l_worker_conc_req_message;
          ELSIF l_main_conc_req_dev_status = 'NORMAL'
          AND l_worker_conc_req_dev_status = 'WARNING'
          THEN
            l_main_conc_req_dev_status := 'WARNING';
            l_child_message            := l_worker_conc_req_message;
          END IF;
        END IF;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'resolve_main_dev_status_end'
          , 'After resolving l_main_conc_req_dev_status:'
            || l_main_conc_req_dev_status
          );
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'resolve_main_dev_status_end'
          , 'After resolving l_main_conc_req_dev_status - child_message :'
            || l_child_message
          );
        END IF;

      ELSE

        -- There was a failure while collecting a child request
        -- status, raising an unexpected exception

        IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'collect_child_status_failed'
          , 'Call to function fnd_concurrent.get_request_status failed. '
            || l_main_conc_req_message
          );
        END IF;

        FND_MESSAGE.Set_Name('CS', 'CS_SR_GET_CHILD_STAT_FAILED');
        FND_MESSAGE.Set_Token('ERROR', SQLERRM);
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'collect_child_status_end'
      , 'After collecting child completion status'
      );
    END IF;

    ---

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'write_purge_output_start'
      , 'Calling procedure to write_purge_output'
      );
    END IF;

    -- Write the details of no. of SRs picked up for purge,
    -- number of SRs purged successfully, no. of SRs failed
    -- during validation and a list of these SRs along with
    -- the cause of failure.

    Write_Purge_Output
    (
      p_purge_batch_size => p_purge_batch_size
    , p_request_id       => l_request_id
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'write_purge_output_end'
      , 'After calling procedure to write_purge_output'
      );
    END IF;

    ---

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'staging_table_cleanup_start'
      , 'Cleaning up staging table'
      );
    END IF;

    -- Cleaning up the staging table

    DELETE cs_incidents_purge_staging
    WHERE
      concurrent_request_id = l_request_id;

    l_row_count := SQL%ROWCOUNT;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'staging_table_cleanup_end'
      , 'After cleaning up staging table ' || l_row_count
      );
    END IF;

    ---

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'act_on_ret_status_start'
      , 'Acting on the main concurrent request return status:'
        || l_main_conc_req_dev_status
      );
    END IF;

    -- Set the completion status of the main concurrent request
    -- by raising corresponding exceptions.

    IF l_main_conc_req_dev_status = 'WARNING'
    THEN
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_RET_STAT');
      FND_MSG_PUB.ADD;

      RAISE L_EXC_PURGE_WARNING;
    ELSIF l_main_conc_req_dev_status = 'ERROR'
    THEN
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_RET_STAT');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'act_on_ret_status_end'
      , 'after Acting on the main concurrent request return status:'
        || l_main_conc_req_dev_status
      );
    END IF;

    ---

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'set_comp_stat_normal_start'
      , 'Setting completion status for parent concurrent request as NORMAL'
      );
    END IF;

    -- Setting the completion status of this concurrent
    -- request as COMPLETED NORMALLY

    l_ret := fnd_concurrent.set_completion_status
    (
      'NORMAL'
    , ' '
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'set_comp_stat_normal_end'
      , 'After setting completion status for parent concurrent '
        || 'request as NORMAL'
      );
    END IF;

    -- At this point, execution of the concurrent program
    -- that is restarted from the paused state is completed.

  END IF;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    IF  FND_CONCURRENT.Get_Request_Status
        (
          request_id => l_request_id
        , phase      => l_main_conc_req_phase
        , status     => l_main_conc_req_status
        , dev_phase  => l_main_conc_req_dev_phase
        , dev_status => l_main_conc_req_dev_status
        , message    => l_main_conc_req_message
        )
    THEN
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_1'
      , 'l_main_conc_req_phase:' || l_main_conc_req_phase
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_2'
      , 'l_main_conc_req_status:' || l_main_conc_req_status
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_3'
      , 'l_main_conc_req_dev_phase:' || l_main_conc_req_dev_phase
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_4'
      , 'l_main_conc_req_dev_status:' || l_main_conc_req_dev_status
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_5'
      , 'l_main_conc_req_message:' || l_main_conc_req_message
      );
    END IF;
  END IF ;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end_time'
    , 'The end time is ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );
  END IF ;

EXCEPTION

  WHEN L_EXC_PURGE_WARNING THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- setting the completion status as WARNING since
    -- there was a warning in the execution of this
    -- request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'WARNING'
    , SUBSTR(x_msg_data, 1, 240)
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'error'
      , 'Inside WHEN L_EXC_PURGE_WARNING of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- setting the completion status as ERROR since
    -- there was an error in the execution of this
    -- request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'error'
      , 'Inside WHEN FND_API.G_EXC_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- setting the completion status as ERROR since
    -- there was an unexpected error in the execution
    -- of this request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PURG_MAIN_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    -- setting the completion status as ERROR since
    -- there was an unexpected error in the execution
    -- of this request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;

END Purge_ServiceRequests;

--------------------------------------------------------------------------------
-- Procedure Name            :   PURGE_SR_WORKER
--
-- Parameters (other than standard ones)
--
-- IN OUT
-- errbuf             : This parameter is not used but is a standard
--                      parameter for concurrent program procedures.
--                      The function fnd_concurrent.set_completion_status
--                      is called instead.
-- errcode            : This parameter is not used but is a standard
--                      parameter for concurrent program procedures.
--                      The function fnd_concurrent.set_completion_status
--                      is called instead.
--
-- IN
-- p_worker_id        : The number assigned to this worker which enables
--                      the worker concurrent program to identify the SRs
--                      in the staging table that it needs to purge
-- p_purge_set_id     : The concurrent request id of the parent concurrent
--                      request. This is used in addition to the worker id
--                      to identify the SRs in the staging table that need
--                      to be purged.
-- p_purge_batch_size : Number of SRs that need to be processed in one
--                      call to the SR Delete API. At any point in time, a
--                      maximum of batch_size number of rows will be inserted
--                      into the table JTF_OBJECT_PURGE_PARAM_TMP, which will
--                      be picked up by the SR Delete API to purge SRs.
-- p_purge_source_with_open_task   :
--                      This signifies if the Tasks Validation API can delete
--                      tasks that are open. If this is N, only SRs linked to
--                      closed Tasks are allowed to be purged. If this is Y,
--                      all SRs, irrespective of whether the Tasks linked to
--                      them are open or closed, can be deleted.
-- p_audit_required   : This indicates if the SR Delete API should write the
--                      purge audit information. If this is N, no rows are
--                      inserted into the table CS_INCIDENTS_PURGE_AUDIT_B and
--                      TL. If this is Y, audit rows are inserted into these
--                      tables.
-- Description
--     This procedure is invoked by the procedure cs_sr_purge_cp.
--     purge_servicerequests as child concurrent requests using an API
--     fnd_request.submit_request. It reads the staging table filled by
--     purge_servicerequests with the purge_set_id and worker_id
--     in batches of size purge_batch_size through a cursor and bulk
--     inserts these rows into the global temp table JTF_OBJECT_PURGE_PARAM_TMP
--     and calls the SR Delete API. At any point in time, several copies of
--     this procedure may be running in parallel since the Purge Concurrent
--     Program will generate multiple Worker Concurrent Programs
--     based on its parameter no_of_workers.
--
-- HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--   2-Aug_2005 | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure is invoked by the procedure cs_sr_purge_cp.
 * purge_servicerequests as child concurrent requests using an API
 * fnd_request.submit_request. It reads the staging table filled by
 * purge_servicerequests with the purge_set_id and worker_id
 * in batches of size purge_batch_size through a cursor and bulk inserts
 * these rows into the global temp table JTF_OBJECT_PURGE_PARAM_TMP and calls
 * the SR Delete API. At any point in time, several copies of this procedure
 * may be running in parallel since the Purge Concurrent Program will generate
 * multiple Worker Concurrent Programs based on its parameter no_of_workers.
 * @param errbuf This parameter is not used but is a standard parameter for
 * concurrent program procedures. The function fnd_concurrent.
 * set_completion_status is called instead.
 * @param errcode This parameter is not used but is a standard parameter
 * for concurrent program procedures. The function
 * fnd_concurrent.set_completion_status is called instead.
 * @param p_worker_id The number assigned to this worker which enables the
 * worker concurrent program to identify the SRs in the staging table that
 * it needs to purge
 * @param p_purge_set_id The concurrent request id of the parent concurrent
 * request. This is used in addition to the worker id to identify the SRs
 * in the staging table that need to be purged.
 * @param p_purge_batch_size Number of SRs that need to be processed in
 * one call to the SR Delete API. At any point in time, a maximum of
 * batch_size number of rows will be inserted into the table
 * JTF_OBJECT_PURGE_PARAM_TMP, which will be picked up by the SR Delete
 * API to purge SRs.
 * @param p_purge_source_with_open_task This signifies if the Tasks
 * Validation API can delete tasks that are open. If this is N, only SRs
 * linked to closed Tasks are allowed to be purged. If this is
 * Y, all SRs, irrespective of whether the Tasks linked to them are
 * open or closed, can be deleted.
 * @param p_audit_required This indicates if the SR Delete API should write
 * the purge audit information. If this is N, no rows are inserted into the
 * table CS_INCIDENTS_PURGE_AUDIT_B and TL. If this is Y, audit rows
 * are inserted into these tables.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Purge Service Requests Worker Concurrent Program
 */
PROCEDURE Purge_Sr_Worker
(
  errbuf                          IN OUT NOCOPY VARCHAR2
, errcode                         IN OUT NOCOPY INTEGER
, p_api_version_number            IN NUMBER
, p_init_msg_list                 IN VARCHAR2
, p_commit                        IN VARCHAR2
, p_validation_level              IN NUMBER
, p_worker_id                     IN NUMBER
, p_purge_batch_size              IN NUMBER
, p_purge_set_id                  IN NUMBER
, p_purge_source_with_open_task   IN VARCHAR2
, p_audit_required                IN VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'PURGE_SR_WORKER';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

x_msg_count                 NUMBER;
x_msg_index_out             NUMBER;
x_msg_data                  VARCHAR2(1000);
x_return_status             VARCHAR2(1);

l_conc_req_phase            VARCHAR2(100);
l_conc_req_status           VARCHAR2(100);
l_conc_req_dev_phase        VARCHAR2(100);
l_conc_req_dev_status       VARCHAR2(100);
l_conc_req_message          VARCHAR2(512);

l_request_id                NUMBER;

l_processing_set_id         NUMBER;
l_row_count                 NUMBER;
l_ret                       BOOLEAN;
l_has_any_batch_failed      BOOLEAN := FALSE;

l_message                  VARCHAR2(1000);

-- PL/SQL table to hold the incident_ids retrieved
-- from the staging table, a batch at a time.

TYPE t_incident_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_incident_id_tbl           t_incident_id_tbl;

-- PL/SQL table to hold the incident ids that had
-- errors while performing validations with other
-- products before purging the SRs. This table is
-- used only when one of these procedures encountered
-- an ORACLE EXCEPTION.

l_err_incident_id_tbl       t_incident_id_tbl;

-- PL/SQL table to hold the error messages retrieved
-- from the staging table when one of the procedures
-- in the worker encounters an ORACLE EXCEPTION.
-- This table is only used under these circumstances.

TYPE t_purge_error_message_tbl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
l_purge_error_message_tbl   t_purge_error_message_tbl;

-- Cursor to fetch SRs that need to
-- be purged from the staging table

CURSOR c_staging IS
  SELECT
    incident_id
  FROM
    cs_incidents_purge_staging
  WHERE
      worker_id             = p_worker_id
  AND concurrent_request_id = p_purge_set_id
  AND purge_status IS NULL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- capturing the request id of the
  -- worker thread into a local variable.

  l_request_id := fnd_global.conc_request_id;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start_time'
    , 'The start time is ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_worker_id:' || p_worker_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_purge_set_id:' || p_purge_set_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_purge_batch_size:' || p_purge_batch_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_purge_source_with_open_task:' || p_purge_source_with_open_task
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 9'
    , 'p_audit_required:' || p_audit_required
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , g_pkg_name
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'param_null_check_start'
    , 'checking if any of the parameters are NULL'
    );
  END IF ;

  -- none of the parameters passed to the worker
  -- concurrent request should be null

  IF  p_worker_id                     IS NULL
  OR  p_purge_set_id                  IS NULL
  OR  p_purge_batch_size              IS NULL
  OR  p_purge_source_with_open_task   IS NULL
  OR  p_audit_required                IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'worker_params_not_enuf'
      , 'no parameters were supplied to the purge worker program'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_PARAM_NULL');
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'param_null_check_end'
    , 'after checking if any of the parameters are NULL'
    );
  END IF ;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'parent_request_id_check_start'
    , 'checking if the parent request id is valid'
    );
  END IF ;

  -- the worker concurrent request should
  -- be supplied with a purge_set_id which
  -- is a valid concurrent request id and
  -- should be one that is not complete.

  BEGIN
    SELECT
      1
    INTO
      l_row_count
    FROM
      fnd_concurrent_requests r
    , fnd_concurrent_programs p
    WHERE
        r.request_id              = p_purge_set_id
    AND p.concurrent_program_id   = r.concurrent_program_id
    AND p.concurrent_program_name = 'CSSRPGP'
    AND p.application_id          = 170
    AND r.status_code             <> 'C';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'worker_purgset_invalid'
        , 'invalid purge set id supplied to the worker concurrent program'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_PURGSET_INV');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'parent_request_id_check_end'
    , 'after checking if the parent request id is valid'
    );
  END IF ;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'loop_start'
    , 'At the beginning of the main loop'
    );
  END IF ;

  LOOP

    -- Opening the cursor inside the loop to avoid
    -- the ORA-1555 snapshot too old problem

    OPEN c_staging;

    -- main loop of the worker thread that collects
    -- incident_ids that need to be purged into a
    -- pl/sql table, a batch at a time and inserts
    -- into the global temp table and calls the
    -- SR delete API.

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'fetch_start'
      , 'fetching rows from the cursor on the table CS_INCIDENTS_PURGE_STAGING'
      );
    END IF ;

    -- fetch a batch of records at a time
    -- to be purged into a pl/sql table

    FETCH             c_staging
    BULK COLLECT INTO l_incident_id_tbl
    LIMIT             p_purge_batch_size;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'fetch_end'
      , 'after fetching rows from the cursor on the table '
        || 'CS_INCIDENTS_PURGE_STAGING '
        || l_incident_id_tbl.COUNT
      );
    END IF ;

    ---

    IF l_incident_id_tbl.COUNT > 0

      -- [IF-1]
      -- check if there is some data fetched into
      -- the pl/sql table before inserting into the
      -- global temp table.

    THEN
      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'gen_proc_setid_start'
        , 'generating processing set id'
        );
      END IF ;

      -- Generating a new processing set id

      SELECT
        jtf_object_purge_proc_set_s.NEXTVAL
      INTO
        l_processing_set_id
      FROM
        dual;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'gen_proc_setid_end'
        , 'after generating processing set id ' || l_processing_set_id
        );
      END IF ;

      ---

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'insert_temp_start'
        , 'inserting incident ids into global temp table '
          || 'JTF_OBJECT_PURGE_PARAM_TMP'
        );
      END IF ;

      -- Inserting the current batch of incident_ids
      -- into the global temp table for purging

      FORALL j IN 1..l_incident_id_tbl.COUNT
        INSERT INTO jtf_object_purge_param_tmp
        (
          object_id
        , object_type
        , processing_set_id
        )
        VALUES
        (
          l_incident_id_tbl(j)
        , 'SR'
        , l_processing_set_id
        );

      l_row_count := SQL%ROWCOUNT;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'insert_temp_end'
        , 'after inserting incident ids into global temp table '
          || 'JTF_OBJECT_PURGE_PARAM_TMP ' || l_row_count
        );
      END IF ;

      ---

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'sr_del_api_start'
        , 'calling the service request delete private api'
        );
      END IF ;

      -- Calling the Service Request Private API to
      -- delete service requests that have been uploaded
      -- to the global temp table.

      CS_SERVICEREQUEST_PVT.Delete_ServiceRequest
      (
        p_api_version_number          => 1.0
      , p_init_msg_list               => FND_API.G_FALSE
      , p_commit                      => FND_API.G_FALSE
      , p_validation_level            => FND_API.G_VALID_LEVEL_FULL
      , p_processing_set_id           => l_processing_set_id
      , p_purge_set_id                => p_purge_set_id
      , p_purge_source_with_open_task => p_purge_source_with_open_task
      , p_audit_required              => p_audit_required
      , x_return_status               => x_return_status
      , x_msg_count                   => x_msg_count
      , x_msg_data                    => x_msg_data
      );

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'sr_del_api_end'
        , 'after calling the service request delete private api'
        );
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'sr_del_api_end'
        , 'return status of api call was ' || x_return_status
        );
      END IF;

      ---

      IF x_return_status = FND_API.G_RET_STS_SUCCESS

        -- [IF-2]
        -- If all went well while
        -- executing the SR delete API

      THEN

        -- Since the current batch execution succeeded
        -- committing the work done in this transaction.

        COMMIT;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'curr_batch_commit'
          , 'committed work done in batch with processing set id '
            || l_processing_set_id
          );
        END IF ;

      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      OR    x_return_status = FND_API.G_RET_STS_ERROR

        -- If there was an error or unexpected error
        -- while executing the SR delete API

      THEN

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'error_incident_id_collect_start'
            , 'collecting errored incident ids into pl/sql table since batch '
              || ' with processing set id ' || l_processing_set_id || ' failed'
            );
        END IF ;

        -- Collecting the set of SRs in the temp table
        -- that encountered errors during validations.
        -- This is done to preserve errors so that it is
        -- clear that these SRs would anyways not have been
        -- deleted even if an error condition had not occurred.

        SELECT
          object_id
        , purge_error_message
        BULK COLLECT INTO
          l_err_incident_id_tbl
        , l_purge_error_message_tbl
        FROM
            jtf_object_purge_param_tmp
        WHERE
            processing_set_id      = l_processing_set_id
        AND object_type            = 'SR'
        AND NVL(purge_status, 'S') = 'E';

        l_row_count := SQL%ROWCOUNT;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'error_incident_id_collect_end'
          , 'after collecting errored incident ids into pl/sql table '
            || l_row_count || ' rows'
          );
        END IF ;

        ---

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'curr_batch_rollback'
          , 'issuing ROLLBACK due to failure of batch with processing set id '
            || l_processing_set_id
          );
        END IF ;

        -- Since the current batch execution failed
        -- rolling back the work done in this transaction.

        ROLLBACK;

        ---

        x_msg_count := FND_MSG_PUB.Count_Msg;
        IF x_msg_count > 0
        THEN
          FND_MSG_PUB.Get
          (
            p_msg_index     => 1
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
        END IF;

        -- setting the interim status of this
        -- worker thread as running with WARNINGS
        -- since purging this batch failed.
        -- however this will NOT stop the process
        -- from running further.

        l_ret := fnd_concurrent.set_interim_status
        (
          'WARNING'
        , SUBSTR(x_msg_data, 1, 240)
        );

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'worker_completion_sts_warn'
          , 'setting completion status to WARNING since batch '
            || l_processing_set_id || ' failed'
          );
        END IF ;

        -- setting flag to identify that
        -- the batch has failed if the
        -- concurrent request was not terminated

        IF NVL(fnd_conc_global.request_data, 'X') <> 'T'
        THEN
          -- Only if the program is not terminated, we
          -- set the batch failed status to TRUE if a
          -- batch had some problems and completed with
          -- errors.
          l_has_any_batch_failed := TRUE;
        END IF;

        ---

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'update_validation_errors'
          , 'updating validation errors to staging table again'
          );
        END IF ;

        -- Updating the staging table with the errors
        -- that occurred due to validations.

        FORALL j IN l_err_incident_id_tbl.FIRST..l_err_incident_id_tbl.LAST
          UPDATE cs_incidents_purge_staging
          SET
            purge_status        = 'E'
          , purge_error_message = l_purge_error_message_tbl(j)
          WHERE
            incident_id = l_err_incident_id_tbl(j);

        l_row_count := SQL%ROWCOUNT;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'update_validation_errors'
          , 'updating validation errors to staging table again ' || l_row_count
          );
        END IF ;

        ---

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'update_oracle_errors'
          , 'updating oracle errors to staging table - '
            || 'CS:CS_SR_PURG_BATCH_FAIL~' || x_msg_data
          );
        END IF ;

        -- Updating the staging table with the errors
        -- that occurred due to failure during execution
        -- of the SR delete API.

        FORALL j IN l_incident_id_tbl.FIRST..l_incident_id_tbl.LAST
          UPDATE cs_incidents_purge_staging
          SET
            purge_status      = 'E'
          , purge_error_message = 'CS:CS_SR_PURG_BATCH_FAIL~' || x_msg_data
          WHERE
              incident_id            = l_incident_id_tbl(j)
          AND NVL(purge_status, 'S') = 'S';

        l_row_count := SQL%ROWCOUNT;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'update_oracle_errors'
          , 'after updating oracle errors to staging table ' || l_row_count
          );
        END IF ;

        -- committing the above error update

        COMMIT;

        ---

        -- collecting the error messages
        -- and writing them to the log

        IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
        THEN
          x_msg_count := FND_MSG_PUB.Count_Msg;

          IF x_msg_count > 0
          THEN
            FOR
              i IN 1..x_msg_count
            LOOP
              FND_MSG_PUB.Get
              (
                p_msg_index     => i
              , p_encoded       => 'F'
              , p_data          => x_msg_data
              , p_msg_index_out => x_msg_index_out
              );
              FND_LOG.String
              (
                FND_LOG.level_unexpected
              , L_LOG_MODULE || 'curr_batch_error'
              , 'Error encountered is : ' || x_msg_data || ' [Index:'
                || x_msg_index_out || ']'
              );
            END LOOP;
          END IF ;
        END IF;
      END IF; -- [IF-2]
    END IF; -- [IF-1]

    -- exit the loop when no more records
    -- are left in the cursor to process
    -- of if the user has requested to
    -- terminate the process.

    EXIT WHEN
        c_staging%NOTFOUND
    OR  fnd_conc_global.request_data = 'T';

    -- Closing the cursor inside the loop to prevent
    -- ORA-1555 error. This cursor is reopened in the
    -- beginning of the loop during the next iteration.

    CLOSE c_staging;

  END LOOP;

  IF c_staging%ISOPEN
  THEN
    -- In case the cursor did not have sufficient
    -- while executing, closing it outside the loop.

    CLOSE c_staging;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'loop_end'
    , 'At the end of the main loop'
    );
  END IF ;

  -- Writing the output for this worker thread
  -- indicating the operations carried out in it.

  IF FND_CONC_GLOBAL.request_data = 'T'
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'write_purge_output_start'
      , 'Writing purge output since parent was terminated'
      );
    END IF ;

    Write_Purge_Output
    (
      p_purge_batch_size => p_purge_batch_size
    , p_request_id       => p_purge_set_id
    , p_worker_id        => p_worker_id
    );

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'write_purge_output_end'
      , 'After writing purge output since parent was terminated'
      );
    END IF ;
  END IF;

  ---

  IF NVL(fnd_conc_global.request_data, 'X') <> 'T'

    -- If the concurrent request is not terminated
    -- then the completion status is determined
    -- based on the outcome of the concurrent request.
    -- Otherwise, it is just not changed since the
    -- concurrent manager sets the request's status
    -- to 'TERMINATED' when the user requests to
    -- terminate the process.

  THEN
    IF NOT l_has_any_batch_failed

      -- If none of the batches have
      -- failed, then set the completion
      -- status to NORMAL.

    THEN
      -- Setting the completion status of this concurrent
      -- request as COMPLETED NORMALLY

      l_ret := fnd_concurrent.set_completion_status
      (
        'NORMAL'
      , ' '
      );
    ELSE
      -- Setting the completion status of this concurrent
      -- request as COMPLETED with WARNINGS since there
      -- were some batches that had failed

      l_message := FND_MESSAGE.Get_String
      (
        'CS'
      , 'CS_SR_WORKER_BATCH_FAIL'
      );

      l_ret := fnd_concurrent.set_completion_status
      (
        'WARNING'
      , l_message
      );
    END IF;
  ELSE

    -- If a request has been terminated
    -- completion status has to be made
    -- as TERMINATED explicitly; otherwise
    -- the concurrent manager flags the
    -- request has completed with status
    -- NORMAL which is not correct in the
    -- current scenario.

    l_ret := fnd_concurrent.set_completion_status
    (
      'TERMINATED'
    , ' '
    );
  END IF;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    IF  fnd_concurrent.get_request_status
        (
          request_id => l_request_id
        , phase      => l_conc_req_phase
        , status     => l_conc_req_status
        , dev_phase  => l_conc_req_dev_phase
        , dev_status => l_conc_req_dev_status
        , message    => l_conc_req_message
        )
    THEN
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_1'
      , 'l_main_conc_req_phase:' || l_conc_req_phase
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_2'
      , 'l_conc_req_status:' || l_conc_req_status
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_3'
      , 'l_conc_req_dev_phase:' || l_conc_req_dev_phase
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_4'
      , 'l_conc_req_dev_status:' || l_conc_req_dev_status
      );
      FND_LOG.String
      (
        FND_LOG.level_procedure
      , L_LOG_MODULE || 'request_status_5'
      , 'l_conc_req_message:' || l_conc_req_message
      );
    END IF;
  END IF ;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
        || x_return_status
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end_time'
    , 'The end time is ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    -- since there was an unexpected error,
    -- rolling back the work done

    ROLLBACK;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- setting the completion status of this
    -- worker thread as COMPLETED with ERRORS
    -- since purging failed.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN OTHERS THEN

    -- since there was an unexpected error,
    -- rolling back the work done

    ROLLBACK;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PURG_WORKER_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    -- setting the completion status of this
    -- worker thread as COMPLETED with ERRORS
    -- since purging failed.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;

END Purge_Sr_Worker;

--------------------------------------------------------------------------------
--  Procedure Name            :   ACTIVITY_SUMMARIZER
--
--  Parameters (other than standard ones)
--      None.
--
--  Description
--      This procedure helps the administrator to get a summary of the
--      number of rows that each object that is associated with an SR
--      has in the database. This will be called by the Oracle Application
--      Manager when the administrator invokes the activitiy summarizer
--      option for this concurrent program.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure helps the administrator to get a summary of the
 * number of rows that each object that is associated with an SR
 * has in the database. This will be called by the Oracle Application
 * Manager when the administrator invokes the activitiy summarizer
 * option for this concurrent program.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Activity Summarizer
 */
PROCEDURE Activity_Summarizer
IS
--------------------------------------------------------------------------------

L_API_NAME      CONSTANT VARCHAR2(30) := 'ACTIVITY_SUMMARIZER';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_sr_audit_1    NUMBER;
l_sr_audit_2    NUMBER;
l_sr_audit_3    NUMBER;
l_sr_audit_4    NUMBER;
l_sr_audits     NUMBER;
l_sr_attr_1     NUMBER;
l_sr_attr_2     NUMBER;
l_sr_attrs      NUMBER;
l_sr_rows       NUMBER;
l_sr_contacts   NUMBER;
l_sr_cont_attrs NUMBER;
l_sr_links      NUMBER;
l_sr_msgs       NUMBER;
l_sr_kb_links   NUMBER;
l_sr_estimates  NUMBER;
l_sr_tasks      NUMBER;
l_sr_notes      NUMBER;
l_sr_activities NUMBER;
l_sr_attachs    NUMBER;
l_sr_work_items NUMBER;
l_sr_total_rows NUMBER;

l_string        VARCHAR2(500);

BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', does not have any parameters.'
    );
  END IF ;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  -- The statements below collect the number of Service Requests
  -- and the corresponding child objects, to be displayed
  -- in the activity summarizer.

  --- 1

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_start'
    , 'fetching count of closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_rows
  FROM
    cs_incidents_all_b b
  WHERE
    NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    )
  AND status_flag = 'C';

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_end'
    , 'after fetching count of closed SRs ' || l_sr_rows
    );
  END IF ;

  --- 2

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'contact_start'
    , 'fetching count of contacts linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_contacts
  FROM
    cs_hz_sr_contact_points cp
  , cs_incidents_all_b      b
  WHERE
    NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
        incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    )
  AND b.incident_id = cp.incident_id
  AND b.status_flag = 'C';

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'contact_end'
    , 'after fetching count of contacts linked to closed SRs ' || l_sr_contacts
    );
  END IF ;

  --- 3

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'contact_attr_start'
    , 'fetching count of extended attributes of contacts linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_cont_attrs
  FROM
    cs_sr_contacts_ext ex
  , cs_incidents_all_b b
  WHERE
    NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    )
  AND b.incident_id = ex.incident_id
  AND b.status_flag = 'C';

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'contact_attr_end'
    , 'after fetching count of extended attributes of contacts '
      || 'linked to closed SRs '
      || l_sr_cont_attrs
    );
  END IF ;

  --- 4

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'link_start'
    , 'fetching count of links to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_links
  FROM
    cs_incident_links  l
  , cs_incidents_all_b b
  WHERE
    (
      l.subject_id = b.incident_id
    AND l.subject_type = 'SR'
    OR  l.object_id = b.incident_id
    AND l.object_type = 'SR'
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    )
  AND b.status_flag = 'C';

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'link_end'
    , 'after fetching count of links to closed SRs ' || l_sr_links
    );
  END IF ;

  --- 5

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'message_start'
    , 'fetching count of messages linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_msgs
  FROM
    cs_messages        msg
  , cs_incidents_all_b b
  WHERE
      msg.source_object_int_id    = b.incident_id
  AND msg.source_object_type_code = 'INC'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
            maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
            cmro_flag
        , 'N'
        ) = 'Y'
      )
    )
  AND b.status_flag = 'C';

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'message_end'
    , 'after fetching count of messages linked to closed SRs ' || l_sr_msgs
    );
  END IF ;

  --- 6

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'km_start'
    , 'fetching count of solutions linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_kb_links
  FROM
    cs_kb_set_links    k
  , cs_incidents_all_b b
  WHERE
      k.object_code = 'SR'
  AND k.other_id    = b.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'km_end'
    , 'after fetching count of solutions linked to closed SRs ' || l_sr_kb_links
    );
  END IF ;

  --- 7

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'charge_start'
    , 'fetching count of charge lines linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_estimates
  FROM
    cs_estimate_details es
  , cs_incidents_all_b  b
  WHERE
      b.incident_id = es.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'charge_end'
    , 'after fetching count of charge lines linked to closed SRs '
      || l_sr_estimates
    );
  END IF ;

  --- 8

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'task_start'
    , 'fetching count of tasks linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_tasks
  FROM
    jtf_tasks_b        j
  , cs_incidents_all_b b
  WHERE
    b.incident_id             = j.source_object_id
  AND j.source_object_type_code = 'SR'
  AND b.status_flag             = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'task_end'
    , 'after fetching count of tasks linked to closed SRs ' || l_sr_tasks
    );
  END IF ;

  --- 9

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'note_start'
    , 'fetching count of notes linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_notes
  FROM
    jtf_notes_b        j
  , cs_incidents_all_b b
  WHERE
      b.incident_id        = j.source_object_id
  AND j.source_object_code = 'SR'
  AND b.status_flag        = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'note_end'
    , 'after fetching count of notes linked to closed SRs ' || l_sr_notes
    );
  END IF ;

  --- 10

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'activity_start'
    , 'fetching count of activities linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_activities
  FROM
    jtf_ih_activities  j
  , cs_incidents_all_b b
  WHERE
      b.incident_id = j.doc_id
  AND j.doc_ref     = 'SR'
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
            maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
            cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'activity_end'
    , 'after fetching count of activities linked to closed SRs '
      || l_sr_activities
    );
  END IF ;

  --- 11

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'attach_start'
    , 'fetching count of attachments linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_attachs
  FROM
    fnd_attached_documents d
  , cs_incidents_all_b     b
  WHERE
      b.incident_id = d.pk1_value
  AND d.entity_name = 'CS_INCIDENTS'
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
            maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
            cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'attach_end'
    , 'after fetching count of attachments linked to closed SRs '
      || l_sr_attachs
    );
  END IF ;

  --- 12

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'work_item_start'
    , 'fetching count of uwq work items linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_work_items
  FROM
    ieu_uwqm_items     u
  , cs_incidents_all_b b
  WHERE
      b.incident_id       = u.workitem_pk_id
  AND u.workitem_obj_code = 'SR'
  AND b.status_flag       = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'work_item_end'
    , 'after fetching count of uwq work items linked to closed SRs '
      || l_sr_work_items
    );
  END IF ;

  --- 13

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_sr_ext_start'
    , 'fetching count of sr extended attributes audit linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_audit_1
  FROM
    cs_incidents_ext_audit a
  , cs_incidents_all_b     b
  WHERE
    b.incident_id = a.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_sr_ext_end'
    , 'after fetching count of sr extended attributes audit'
      || ' linked to closed SRs '
      || l_sr_audit_1
    );
  END IF ;

  --- 14

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_sr_cont_start'
    , 'fetching count of contact extended attributes audit linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_audit_2
  FROM
    cs_sr_contacts_ext_audit a
  , cs_incidents_all_b       b
  WHERE
      b.incident_id = a.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_sr_cont_end'
    , 'after fetching count of contact extended attributes audit '
      || 'linked to closed SRs '
      || l_sr_audit_2
    );
  END IF ;

  --- 15

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_srtl_start'
    , 'fetching count of sr audit TL rows linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_audit_3
  FROM
    cs_incidents_audit_tl a
  , cs_incidents_all_b    b
  WHERE
      b.incident_id = a.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_srtl_end'
    , 'after fetching count of sr audit TL rows linked to closed SRs '
      || l_sr_audit_3
    );
  END IF ;

  --- 16

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_srb_start'
    , 'fetching count of sr audit B rows linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_audit_4
  FROM
    cs_incidents_audit_b a
  , cs_incidents_all_b   b
  WHERE
      b.incident_id = a.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
            maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
            cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'audit_srb_end'
    , 'after fetching count of sr audit B rows linked to closed SRs '
      || l_sr_audit_4
    );
  END IF ;

  --- 17

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'cug_attrib_start'
    , 'fetching count of cug attributes linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_attr_1
  FROM
    cug_incidnt_attr_vals_b a
  , cs_incidents_all_b      b
  WHERE
      b.incident_id = a.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
          maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
          cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'cug_attrib_end'
    , 'after fetching count of cug attributes linked to closed SRs '
      || l_sr_attr_1
    );
  END IF ;

  --- 18

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_attrib_start'
    , 'fetching count of sr extended attributes linked to closed SRs'
    );
  END IF ;

  SELECT
    count(*)
  INTO
    l_sr_attr_2
  FROM
    cs_incidents_ext   a
  , cs_incidents_all_b b
  WHERE
      b.incident_id = a.incident_id
  AND b.status_flag = 'C'
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      csd_repairs
    WHERE
      incident_id = b.incident_id
    )
  AND NOT EXISTS
    (
    SELECT
      1
    FROM
      cs_incident_types_b
    WHERE
      incident_type_id = b.incident_type_id
    AND
      (
        NVL
        (
            maintenance_flag
        , 'N'
        ) = 'Y'
      OR  NVL
        (
            cmro_flag
        , 'N'
        ) = 'Y'
      )
    );

  l_sr_audits     := l_sr_audit_1 + l_sr_audit_2 + l_sr_audit_3 + l_sr_audit_4;
  l_sr_attrs      := l_sr_attr_1 + l_sr_attr_2;
  l_sr_total_rows := l_sr_rows + l_sr_contacts + l_sr_cont_attrs
                     + l_sr_links + l_sr_msgs + l_sr_kb_links + l_sr_estimates
                     + l_sr_tasks + l_sr_notes + l_sr_activities + l_sr_attachs
                     + l_sr_work_items + l_sr_audits + l_sr_attrs;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_attrib_end'
    , 'after fetching count of sr extended attributes linked to closed SRs '
        || l_sr_attr_2
    );
  END IF ;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'activity_summary_start'
    , 'preparing the activity summary report'
    );
  END IF ;

  -- The following lines fetch the text that needs to be displayed
  -- in the activity summarizer and then inserts a new row into
  -- the table indicating the number of instances that are available
  -- under each object.
  --
  -- Eg.,
  -- +--------------------------------------------------+-------+
  -- | Name                                             | Value |
  -- +--------------------------------------------------+-------+
  -- | Service Requests                                 | 20039 |
  -- +--------------------------------------------------+-------+

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SERVICE_REQUESTS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_rows)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_ATTRIBUTES'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_attrs)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_CONTACTS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_contacts)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_CONTACT_ATTRIBS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_cont_attrs)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_LINKS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_links)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_MESSAGES'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_msgs)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_KM_LINKS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_kb_links)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_CHARGE_LINES'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_estimates)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_TASKS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_tasks)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_NOTES'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_notes)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_INT_ACTIVITIES'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_activities)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_ATTACHMENTS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_attachs)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_UWQ_WORK_ITEMS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_work_items)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_AUDIT_RECORDS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_audits)
  );

  l_string := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_TOTAL_ROWS'
  );
  FND_CONC_SUMMARIZER.Insert_Row
  (
    l_string
  , to_char(l_sr_total_rows)
  );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'activity_summary_end'
    , 'after preparing the activity summary report'
    );
  END IF ;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with Success'
    );
  END IF ;

EXCEPTION
	WHEN OTHERS THEN
    FND_MESSAGE.Set_Name('CS', 'CS_SR_PURG_ACT_SUM_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Activity_Summarizer;

--------------------------------------------------------------------------------
-- Procedure Name          :   VALIDATE_PURGE_PARAMS
--
-- Parameters (other than standard ones)
--
-- OUT
--
-- x_creation_from_date    : If the p_creation_from_date is supplied, the
--                           validated and converted value is returned into
--                           this parameter
-- x_creation_to_date      : If the p_creation_to_date is supplied, the
--                           validated and converted value is returned into
--                           this parameter
-- x_last_update_from_date : If the p_last_update_from_date is supplied, the
--                           validated and converted value is returned into
--                           this parameter
-- x_last_update_to_date   : If the p_last_update_to_date is supplied,
--                           the validated and converted value is returned
--                           into this parameter
--
-- IN
--
-- p_incident_id           : Indicates that SR with this id needs
--                           to be purged
-- p_incident_status_id    : Indicates that SR with this status id
--                           needs to be purged
-- p_incident_type_id      : Indicates that SRs with this type id
--                           needs to be purged
-- p_creation_from_date    : Indicates the lower end of the range of dates
--                           that need to be compared with CREATION_DATE of
--                           the SR to pick it up for purge
-- p_creation_to_date      : Indicates the higher end of the range of dates
--                           that need to be compared with CREATION_DATE of
--                           the SR to pick it up for purge
-- p_last_update_from_date : Indicates the lower end of the range of dates
--                           that need to be compared with LAST_UPDATED_DATE of
--                           the SR to pick it up for purge
-- p_last_update_to_date   : Indicates the higher end of the range of dates
--                           that need to be compared with LAST_UPDATED_DATE of
--                           the SR to pick it up for purge
-- p_not_updated_since     : This is a set of values like 1Y,2Y etc. which
--                           shall be compared with the LAST_UPDATED_DATE
--                           of the the SR to pick it up for purge
-- p_customer_id           : Indicates that SRs with this customer_id need
--                           to be purged.
-- p_customer_acc_id       : Indicates that SRs with this customer acc id
--                           need to be purged
-- p_item_category_id      : Indicates that SRs created for items falling
--                           under this category need to be purged
-- p_inventory_item_id     : Indicates that SRs created for this item
--                           need to be purged
-- p_history_size          : Number of  customer SR's to retain while purging
--                           SRs identified using other parameters. This
--                           parameter alone CANNOT be used to identify a valid
--                           purgeset.
-- p_number_of_workers     : Number of workers that needs to be launched for
--                           purging Service Requests
-- p_purge_batch_size      : Number of Service Requests that needs to be purged
--                           in a batch
-- p_purge_source_with_open_task :
--                           This signifies if the Tasks Validation API can
--                           delete tasks that are open. If this is N, only SRs
--                           linked to closed Tasks are allowed to be purged.
--                           If this is Y, all SRs, irrespective of whether the
--                           Tasks linked to them are open or closed, can
--                           be deleted.
-- p_audit_required        : This indicates if the SR Delete API should write
--                           the purge audit information. If this is N, no rows
--                           are inserted into the table
--                           CS_INCIDENTS_PURGE_AUDIT_B and TL. If this is Y,
--                           audit rows are inserted into these tables.
--
-- Description
--     This procedure performs validations on all the purge parameters.
--     It uses global variables to set the values for the creation from/to
--     dates and last updated from/to dates to avoid too many parameters
--     being passed back and forth.
--
--
-- HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure performs validations on all the purge parameters.
 * It uses global variables to set the values for the creation from/to
 * dates and last updated from/to dates to avoid too many parameters
 * being passed back and forth.
 * @param x_creation_from_date If the p_creation_from_date is supplied,
 * the validated and converted value is returned into this parameter
 * @param x_creation_to_date If the p_creation_to_date is supplied, the
 * validated and converted value is returned into this parameter
 * @param x_last_update_from_date If the p_last_update_from_date is supplied,
 * the validated and converted value is returned into this parameter
 * @param x_last_update_to_date If the p_last_update_to_date is supplied,
 * the validated and converted value is returned into this parameter
 * @param p_incident_id Indicates that SR with this id needs to be purged
 * @param p_incident_status_id Indicates that SR with this status id needs
 * to be purged
 * @param p_incident_type_id Indicates that SRs with this type id needs to
 * be purged
 * @param p_creation_from_date Indicates the lower end of the range of
 * dates that need to be compared with CREATION_DATE of the SR to pick
 * it up for purge
 * @param p_creation_to_date Indicates the higher end of the range of
 * dates that need to be compared with CREATION_DATE of the SR to pick
 * it up for purge
 * @param p_last_update_from_date Indicates the lower end of the range of
 * dates that need to be compared with LAST_UPDATED_DATE of the SR to
 * pick it up for purge
 * @param p_last_update_to_date Indicates the higher end of the range of
 * dates that need to be compared with LAST_UPDATED_DATE of the SR to pick
 * it up for purge
 * @param p_not_updated_since This is a set of values like 1Y,2Y etc.
 * which shall be compared with the LAST_UPDATED_DATE of the the SR to pick
 * it up for purge
 * @param p_customer_id Indicates that SRs with this customer_id need to
 * be purged.
 * @param p_customer_acc_id Indicates that SRs with this customer acc id
 * need to be purged
 * @param p_item_category_id Indicates that SRs created for items falling
 * under this category need to be purged
 * @param p_inventory_item_id Indicates that SRs created for this item
 * need to be purged
 * @param p_history_size Number of  customer SR's to retain while purging
 * SRs identified using other parameters. This parameter alone CANNOT be
 * used to identify a valid purgeset.
 * @param p_number_of_workers Number of workers that needs to be launched
 * for purging Service Requests
 * @param p_purge_batch_size Number of Service Requests that needs to
 * be purged in a batch
 * @param p_purge_source_with_open_task This signifies if the Tasks
 * Validation API can delete tasks that are open. If this is N, only SRs
 * linked to closed Tasks are allowed to be purged. If this is Y, all SRs,
 * irrespective of whether the Tasks linked to them are open or closed,
 * can be deleted.
 * @param p_audit_required This indicates if the SR Delete API should write
 * the purge audit information. If this is N, no rows are inserted into the
 * table CS_INCIDENTS_PURGE_AUDIT_B and TL. If this is Y, audit rows are
 * inserted into these tables.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Validate Purge Parameters
 */
PROCEDURE Validate_Purge_Params
(
  p_incident_id                   IN          NUMBER
, p_incident_status_id            IN          NUMBER
, p_incident_type_id              IN          NUMBER
, p_creation_from_date            IN          VARCHAR2
, p_creation_to_date              IN          VARCHAR2
, p_last_update_from_date         IN          VARCHAR2
, p_last_update_to_date           IN          VARCHAR2
, x_creation_from_date            OUT NOCOPY  DATE
, x_creation_to_date              OUT NOCOPY  DATE
, x_last_update_from_date         OUT NOCOPY  DATE
, x_last_update_to_date           OUT NOCOPY  DATE
, p_not_updated_since             IN          VARCHAR2
, p_customer_id                   IN          NUMBER
, p_customer_acc_id               IN          NUMBER
, p_item_category_id              IN          NUMBER
, p_inventory_item_id             IN          NUMBER
, p_history_size                  IN          NUMBER
, p_number_of_workers             IN          NUMBER
, p_purge_batch_size              IN          NUMBER
, p_purge_source_with_open_task   IN          VARCHAR2
, p_audit_required                IN          VARCHAR2
, x_msg_count                     OUT NOCOPY  NUMBER
, x_msg_data                      OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_NAME      CONSTANT VARCHAR2(30) := 'VALIDATE_PURGE_PARAMS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_prompt                VARCHAR2(250);
l_not_updated_since     VARCHAR2(10);

-- Variables used for calculating the
-- interval value used for processing
-- value in p_not_updated_since.

l_month_loc             NUMBER;
l_year_loc              NUMBER;
l_month_part            NUMBER;
l_year_part             NUMBER;
l_interval              VARCHAR2(50);

-- Constant value containing the number that when added
-- to a truncated date will point to the last second of
-- the day.
-- Eg., if a_date is '10-JAN-1999 14:01:02' then the
-- TRUNC(a_date) will be '10-JAN-1999 00:00:00'. Adding
-- the constant to this date will give '10-JAN-1999 23:59:59'.

TIME_23_59_59 CONSTANT  NUMBER := 1 - 1 / (24*60*59);

l_str_month_part        VARCHAR2(30);
l_str_year_part         VARCHAR2(30);

-- Function to check if a given value is
-- numeric or not. This is used to find
-- out if the format of value given in the
-- lookup for NOT_UPDATED_SINCE is valid.

FUNCTION Is_Number
(
  p_value   IN          VARCHAR2
, p_result  OUT NOCOPY  NUMBER
)
RETURN BOOLEAN
IS
BEGIN
  p_result := TO_NUMBER(p_value);
  RETURN TRUE;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN FALSE;
END Is_Number;
--------------------------------------------------------------------------------

BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_incident_id:' || p_incident_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_incident_status_id:' || p_incident_status_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_incident_type_id:' || p_incident_type_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_creation_from_date:' || p_creation_from_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_creation_to_date:' || p_creation_to_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_last_update_from_date:' || p_last_update_from_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_last_update_to_date:' || p_last_update_to_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_not_updated_since:' || p_not_updated_since
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 9'
    , 'p_customer_id:' || p_customer_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 10'
    , 'p_customer_acc_id:' || p_customer_acc_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 11'
    , 'p_item_category_id:' || p_item_category_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 12'
    , 'p_inventory_item_id:' || p_inventory_item_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 13'
    , 'p_history_size:' || p_history_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 14'
    , 'p_number_of_workers:' || p_number_of_workers
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 15'
    , 'p_purge_batch_size:' || p_purge_batch_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 16'
    , 'p_purge_source_with_open_task:' || p_purge_source_with_open_task
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 17'
    , 'p_audit_required:' || p_audit_required
    );
  END IF ;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'check_blind_purge_start'
    , 'checking for blind search'
    );
  END IF;

  -- raising error if none of the parameters are entered
  -- while submitting the concurrent program

  IF  p_incident_id              IS NULL
  AND p_incident_status_id       IS NULL
  AND p_incident_type_id         IS NULL
  AND p_creation_from_date       IS NULL
  AND p_creation_to_date         IS NULL
  AND p_last_update_from_date    IS NULL
  AND p_last_update_to_date      IS NULL
  AND p_not_updated_since        IS NULL
  AND p_customer_id              IS NULL
  AND p_customer_acc_id          IS NULL
  AND p_item_category_id         IS NULL
  AND p_inventory_item_id        IS NULL
  AND p_history_size             IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'no_params'
      , 'no parameters were supplied to the purge program'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_NO_PURGE_PARAMS');
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'check_blind_purge_end'
    , 'after checking for blind search'
    );
  END IF;

  ---

  IF p_creation_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_start_1'
      , 'checking if p_creation_from_date is in the format '
        || fnd_date.user_mask
      );
    END IF;

    -- Check if p_creation_from_date is of the format
    -- as maintained in the profile option ICX_DATE_FORMAT
    -- and if not, throw an error.

    x_creation_from_date := fnd_date.string_to_date
    (
      p_creation_from_date
    , fnd_date.user_mask
    );

    IF x_creation_from_date IS NULL
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crtfrmdt_format_invalid'
        , 'format of field p_creation_from_date is invalid. should be '
          || fnd_date.user_mask
        );
      END IF ;

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_CREATION_FROM_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_FORMAT_ERR');
      FND_MESSAGE.Set_Token('DATEFIELDNAME', l_prompt);
      FND_MESSAGE.Set_Token('FORMAT', fnd_date.user_mask);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_end_1'
      , 'after checking if p_creation_from_date is in the format '
        || fnd_date.user_mask
      );
    END IF;
  END IF;

  ---

  IF p_creation_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_start_2'
      , 'checking if p_creation_to_date is in the format '
        || fnd_date.user_mask
      );
    END IF;

    -- Check if p_creation_to_date is of the format
    -- as maintained in the profile option ICX_DATE_FORMAT
    -- and if not, throw an error.

    x_creation_to_date := fnd_date.string_to_date
    (
      p_creation_to_date
    , fnd_date.user_mask
    );

    IF x_creation_to_date IS NULL
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crttodt_format_invalid'
        , 'format of field p_creation_to_date is invalid. should be ' ||
            fnd_date.user_mask
        );
      END IF ;

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
        end_user_column_name         = 'P_CREATION_TO_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_FORMAT_ERR');
      FND_MESSAGE.Set_Token('DATEFIELDNAME', l_prompt);
      FND_MESSAGE.Set_Token('FORMAT', fnd_date.user_mask);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_end_2'
      , 'after checking if p_creation_to_date is in the format ' ||
        fnd_date.user_mask
      );
    END IF;

    ---

    -- If the user_mask does not contain the time, then appending the time
    -- 23:59:59 to the date so that the whole day is covered. This is to
    -- take care of conditions where the from and to dates are the same day.
    --
    -- For ex., if the from date is 1-jan-1999 and to date is also 1-jan-1999,
    -- since there is no time given for these dates, the condition "where
    -- creation_date <= from_date and creation_date >= to_date" will not
    -- return any rows because if the creation date is 1-jan-1999 12:00:01,
    -- the condition creation_date >= from_date will be satisfied but the
    -- condition creation_date <= to_date will not be satisfied. In this
    -- situation, no rows will be picked up. To correct this issue, if the
    -- to_date contains the time 23:59:59, both the conditions will be
    -- satisfied.

    IF TRUNC(x_creation_to_date) = x_creation_to_date
    THEN
      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'add_time_to_todate_start'
        , 'adding time to x_creation_to_date if it does not have time'
        );
      END IF;

      x_creation_to_date := x_creation_to_date + TIME_23_59_59;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'add_time_to_todate_end'
        , 'adding time to x_creation_to_date if it does not have time ' ||
            TO_CHAR(x_creation_to_date, 'DD-MON-YYYY HH24:MI:SS')
        );
      END IF;
    END IF;
  END IF;

  ---

  IF p_last_update_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_start_3'
      , 'checking if p_last_update_from_date is in the format '
        || fnd_date.user_mask
      );
    END IF;

    -- Check if p_last_update_from_date is of the format
    -- as maintained in the profile option ICX_DATE_FORMAT
    -- and if not, throw an error.

    x_last_update_from_date := fnd_date.string_to_date
    (
      p_last_update_from_date
    , fnd_date.user_mask
    );

    IF x_last_update_from_date IS NULL
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'lstupdfrmdt_format_invalid'
        , 'format of field p_last_update_from_date is invalid. should be '
          || fnd_date.user_mask
        );
      END IF ;

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_LAST_UPDATE_FROM_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_FORMAT_ERR');
      FND_MESSAGE.Set_Token('DATEFIELDNAME', l_prompt);
      FND_MESSAGE.Set_Token('FORMAT', fnd_date.user_mask);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_end_3'
      , 'after checking if p_last_update_from_date is in the format '
        || fnd_date.user_mask
      );
    END IF;
  END IF;

  ---

  IF p_last_update_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_start_4'
      , 'checking if p_last_update_to_date is in the format '
        || fnd_date.user_mask
      );
    END IF;

    -- Check if p_last_update_to_date is of the format
    -- as maintained in the profile option ICX_DATE_FORMAT
    -- and if not, throw an error.

    x_last_update_to_date := fnd_date.string_to_date
    (
      p_last_update_to_date
    , fnd_date.user_mask
    );

    IF x_last_update_to_date IS NULL
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'lstupdtodt_format_invalid'
        , 'format of field p_last_update_to_date is invalid. should be '
          || fnd_date.user_mask
        );
      END IF ;

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_LAST_UPDATE_TO_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_FORMAT_ERR');
      FND_MESSAGE.Set_Token('DATEFIELDNAME', l_prompt);
      FND_MESSAGE.Set_Token('FORMAT', fnd_date.user_mask);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_end_4'
      , 'after checking if p_last_update_to_date is in the format '
        || fnd_date.user_mask
      );
    END IF;

    ---

    -- If the user_mask does not contain the time, then appending
    -- time 23:59:59 to the date so that the whole day is covered.

    IF TRUNC(x_last_update_to_date) = x_last_update_to_date
    THEN
      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'add_time_to_todate_start'
          , 'adding time to x_last_update_to_date as it does not have time'
          );
      END IF;

      x_last_update_to_date := x_last_update_to_date + TIME_23_59_59;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
          FND_LOG.String
          (
            FND_LOG.level_statement
          , L_LOG_MODULE || 'add_time_to_todate_end'
          , 'after adding time to x_last_update_to_date as it '
            || 'does not have time '
            || TO_CHAR(x_last_update_to_date, 'DD-MON-YYYY HH24:MI:SS')
          );
      END IF;
    END IF;
  END IF;

  ---

  IF  p_not_updated_since     IS NOT NULL
  AND p_last_update_from_date IS NULL
  AND p_last_update_to_date   IS NULL

    -- Consider the p_not_updated_since parameter only
    -- if the parameters last_updated_from_date and
    -- last_updated_to_date are omitted. Otherwise, use
    -- the explisit values provided in the parameters.

  THEN

    -- Assign the value of p_not_updated_since to l_not_updated_since
    -- just to indicate that the value of the parameter p_not_updated_since
    -- is considered for framing the purge set.

    l_not_updated_since := p_not_updated_since;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'not_updated_since_start'
      , 'computing last_updated_from_date and last_updated_to_date'
      );
    END IF;

    -- Resolving the value for the field p_not_updated_since. The following
    -- Table explains the buckets in which the SRs shall be arranged in order
    -- to pick them up as per the value chosen by the user.

    --+-----------------------------------+------------------------+
    --|  Condition                        |   Expression (YY-MM)   |
    --+-----------------------------------+------------------------+
    --|  Not updated since last 3 months  |  < SYSDATE - (00-03)   |
    --|  Not updated since last 6 months  |  < SYSDATE - (00-06)   |
    --|  Not updated between 0-1 year     |  < SYSDATE - (01-00)   |
    --|  Not updated between 0-2 years    |  < SYSDATE - (02-00)   |
    --|  Not updated between 0-3 years    |  < SYSDATE - (03-00)   |
    --|  Not updated between 0-4 years    |  < SYSDATE - (04-00)   |
    --|  Not updated between 0-5 years    |  < SYSDATE - (05-00)   |
    --+-----------------------------------+------------------------+

    -- The oracle function to_yminterval('yy-mm') takes a string containing
    -- the number of years and number of months and returns an interval value
    -- that could be added to or subtracted from a date to move that many
    -- years and months ahead or behind that date.

    -- The following code assumes that the lookup setup for
    -- this parameter will have the values in the format <n>Y<n>M.
    -- Eg., 10 Years 3 Months will be created as 10Y3M.
    -- Just 3 months will be created as 3M.

    l_month_loc := INSTR(p_not_updated_since, 'M');
    l_year_loc  := INSTR(p_not_updated_since, 'Y');

    IF  l_month_loc = 0
    AND l_year_loc  = 0

      -- If the value specified for Not Updated Since, chosen
      -- from the LOV does not confirm to the format <n>Y<n>M
      -- then the following error is raised

    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'month_year_loc_err_1'
        , 'error while getting the month/year combination from the lookup'
        );
      END IF;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'month_year_loc'
      , 'after getting month and year occurrence locations '
        || l_month_loc || ' ' || l_year_loc
      );
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'month_year_part_start'
      , 'getting month and year values from p_not_updated_since'
      );
    END IF;

    IF  l_year_loc  = 0
    AND l_month_loc > 0
    THEN
      l_str_month_part := SUBSTR(p_not_updated_since, 1, l_month_loc - 1);
      IF NOT Is_Number(l_str_month_part, l_month_part)
      OR l_month_loc < LENGTH(p_not_updated_since)
      THEN
        IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'month_year_loc_err_2'
          , 'error while getting the month/year combination from the lookup'
          );
        END IF;

        FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_year_part := 0;
    ELSIF l_year_loc  > 0
    AND   l_month_loc = 0
    THEN
      l_month_part := 0;
      l_str_year_part := SUBSTR(p_not_updated_since, 1, l_year_loc - 1);
      IF NOT Is_Number(l_str_year_part, l_year_part)
      OR l_year_loc < LENGTH(p_not_updated_since)
      THEN
        IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
        THEN
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'month_year_loc_err_3'
          , 'error while getting the month/year combination from the lookup'
          );
        END IF;

        FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF l_year_loc  > 0
    AND   l_month_loc > 0
    THEN
      IF l_month_loc > l_year_loc
      THEN
        l_str_year_part  := SUBSTR(p_not_updated_since, 1, l_year_loc - 1);
        l_str_month_part := SUBSTR
          (
            p_not_updated_since
          , l_year_loc  + 1
          , l_month_loc - l_year_loc - 1
          );
        IF NOT Is_Number(l_str_year_part, l_year_part)
        THEN
          IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_unexpected
            , L_LOG_MODULE || 'month_year_loc_err_5'
            , 'error while getting the month/year combination from the lookup'
            );
          END IF;

          FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
          FND_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF NOT Is_Number(l_str_month_part, l_month_part)
        OR l_month_loc < LENGTH(p_not_updated_since)
        THEN
          IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_unexpected
            , L_LOG_MODULE || 'month_year_loc_err_4'
            , 'error while getting the month/year combination from the lookup'
            );
          END IF;

          FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
          FND_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF l_year_loc  > l_month_loc
      THEN
        l_str_month_part := SUBSTR(p_not_updated_since, 1, l_month_loc - 1);
        l_str_year_part  := SUBSTR
          (
            p_not_updated_since
          , l_month_loc + 1
          , l_year_loc  - l_month_loc - 1
          );
        IF NOT Is_Number(l_str_month_part, l_month_part)
        THEN
          IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_unexpected
            , L_LOG_MODULE || 'month_year_loc_err_6'
            , 'error while getting the month/year combination from the lookup'
            );
          END IF;

          FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
          FND_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF NOT Is_Number(l_str_year_part, l_year_part)
        OR l_year_loc < LENGTH(p_not_updated_since)
        THEN
          IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_unexpected
            , L_LOG_MODULE || 'month_year_loc_err_7'
            , 'error while getting the month/year combination from the lookup'
            );
          END IF;

          FND_MESSAGE.Set_Name('CS', 'CS_SR_NOT_UPD_SINCE_INV');
          FND_MSG_PUB.ADD;

          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF ;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'month_year_part_literal'
      , 'after getting literal values for month and year parts ' ||
        l_month_part || ' ' || l_year_part
      );
    END IF;

    -- If the month part is given more than 11, it means that
    -- it is going beyond a year. so this portion of the code
    -- makes the month < 12 and adds up Years to the extent
    -- required.

    IF l_month_part > 11
    THEN
      l_year_part := l_year_part + FLOOR
      (
        l_month_part / 12
      );
      l_month_part := MOD
      (
        l_month_part
      , 12
      );
    END IF ;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'month_year_part_end'
      , 'after getting computed month and year values '
        || 'from p_not_updated_since ' ||
        l_month_part || ' ' || l_year_part
      );
    END IF;

    l_interval := l_year_part || '-' || l_month_part;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'interval_formed'
      , 'after forming the interval to be used for the value ' ||
        p_not_updated_since || ' ' || l_interval
      );
    END IF;

    -- Since the date computed out of p_not_updated_since does not contain time,
    -- appending time 23:59:59 to the date so that the whole day is covered.

    x_last_update_to_date := trunc(SYSDATE)
                             - to_yminterval(l_interval)
                             + TIME_23_59_59;
    x_last_update_from_date := NULL;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'not_updated_since_1'
      , 'x_last_update_from_date:' || x_last_update_from_date
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'not_updated_since_2'
      , 'x_last_update_to_date:'
        || TO_CHAR(x_last_update_to_date, 'DD-MON-YYYY HH24:MI:SS')
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'not_updated_since_end'
      , 'after computing last_updated_from_date and last_updated_to_date'
      );
    END IF;
  END IF;

  ---

  IF x_creation_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_crtdtfrom_start'
      , 'checking value for field x_creation_from_date'
      );
    END IF;

    -- if the field x_creation_from_date is after sysdate
    -- throw an error since there will not be any SRs in
    -- that date range.

    IF x_creation_from_date > SYSDATE
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crtdtfrom_invalid'
        , 'x_creation_from_date is invalid'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_CRTDT_FROM_ERR');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_crtdtfrom_end'
      , 'after checking value for field x_creation_from_date'
      );
    END IF;
  END IF;

  ---

  IF x_creation_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_crtdtto_start'
      , 'checking value for field x_creation_to_date'
      );
    END IF;

    -- if the field x_creation_to_date is after sysdate
    -- throw an error since there will not be any SRs in
    -- that date range.

    IF x_creation_to_date > SYSDATE
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crtdtto_invalid'
        , 'x_creation_to_date is invalid'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_CRTDT_TO_ERR');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_crtdtto_end'
      , 'after checking value for field x_creation_to_date'
      );
    END IF;
  END IF;

  ---

  IF x_last_update_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_lupdfromdt_start'
      , 'checking value for field x_last_update_from_date'
      );
    END IF;

    -- if the field x_last_update_from_date is after sysdate
    -- throw an error since there will not be any SRs in
    -- that date range.

    IF x_last_update_from_date > SYSDATE
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'lupddtfrom_invalid'
        , 'x_last_update_from_date is invalid'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_MODDT_FROM_ERR');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_lupdfromdt_end'
      , 'after checking value for field x_last_update_from_date'
      );
    END IF;
  END IF;

  ---

  IF x_last_update_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_lupdtodt_start'
      , 'checking value for field x_last_update_to_date'
      );
    END IF;

    -- if the field x_last_update_to_date is after sysdate
    -- throw an error since there will not be any SRs in
    -- that date range.

    IF x_last_update_to_date > SYSDATE
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'lupddtto_invalid'
        , 'x_last_update_to_date is invalid'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_MODDT_TO_ERR');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_lupdtodt_end'
      , 'after checking value for field x_last_update_to_date'
      );
    END IF;
  END IF;

  ---

  IF  x_creation_from_date IS NOT NULL
  AND x_creation_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_start_1'
      , 'doing cross field validations x_creation_from_date '
        || '> x_creation_to_date '
      );
    END IF;

    -- if both x_creation_from_date and x_creation_to_date are
    -- entered then x_creation_from_date should be before
    -- x_creation_to_date

    IF x_creation_from_date > x_creation_to_date
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crtfrmdt_after_crttodt'
        , 'it is invalid to have x_creation_from_date > x_creation_to_date'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_VALUE_ERR');

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_CREATION_FROM_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME1', l_prompt);

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_CREATION_TO_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME2', l_prompt);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_end_1'
      , 'after doing cross field validations x_creation_from_date > '
        || 'x_creation_to_date '
      );
    END IF;
  END IF;

  ---

  IF  x_creation_from_date IS NOT NULL
  AND x_last_update_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_start_2'
      , 'doing cross field validations x_creation_from_date > '
        || 'x_last_update_from_date '
      );
    END IF;

    -- if both x_creation_from_date and x_last_update_from_date are
    -- entered then x_creation_from_date should be before
    -- x_last_update_from_date

    IF x_creation_from_date > x_last_update_from_date
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crtfrmdt_after_lupdfrmdt'
        , 'it is invalid to have x_creation_from_date > '
          || 'x_last_update_from_date'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_VALUE_ERR');

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_CREATION_FROM_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME1', l_prompt);

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
        end_user_column_name = DECODE
        (
            l_not_updated_since
        , NULL
        , 'P_LAST_UPDATE_FROM_DATE'
        , 'P_NOT_UPDATED_SINCE'
        )
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME2', l_prompt);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_end_2'
      , 'after doing cross field validations x_creation_from_date > '
        || 'x_last_update_from_date '
      );
    END IF;
  END IF;

  ---

  IF  x_creation_from_date IS NOT NULL
  AND x_last_update_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_start_3'
      , 'doing cross field validations x_creation_from_date > '
        || 'x_last_update_to_date'
      );
    END IF;

    -- if both x_creation_from_date and x_last_update_to_date are
    -- entered then x_creation_from_date should be before
    -- x_last_update_to_date

    IF x_creation_from_date > x_last_update_to_date
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crttodt_after_lupdtodt'
        , 'it is invalid to have x_creation_from_date > '
          || 'x_last_update_to_date'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_VALUE_ERR');

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_CREATION_FROM_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME1', l_prompt);

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
        end_user_column_name = DECODE
        (
            l_not_updated_since
        , NULL
        , 'P_LAST_UPDATE_TO_DATE'
        , 'P_NOT_UPDATED_SINCE'
        )
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME2', l_prompt);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_end_3'
      , 'after doing cross field validations x_creation_from_date > '
        || 'x_last_update_to_date'
      );
    END IF;
  END IF;

  ---

  IF  x_creation_to_date IS NOT NULL
  AND x_last_update_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_start_4'
      , 'doing cross field validations x_creation_to_date > '
        || 'x_last_update_to_date'
      );
    END IF;

    -- if both x_creation_to_date and x_last_update_to_date are
    -- entered then x_creation_to_date should be before
    -- x_last_update_to_date

    IF x_creation_to_date > x_last_update_to_date
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'crttodt_after_lupdtodt'
        , 'it is invalid to have x_creation_to_date > x_last_update_to_date'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_VALUE_ERR');

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
        end_user_column_name         = 'P_CREATION_TO_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME1', l_prompt);

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
        end_user_column_name = DECODE
        (
            l_not_updated_since
        , NULL
        , 'P_LAST_UPDATE_TO_DATE'
        , 'P_NOT_UPDATED_SINCE'
        )
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME2', l_prompt);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_end_4'
      , 'after doing cross field validations x_creation_to_date > '
        || 'x_last_update_to_date'
      );
    END IF;
  END IF;

  ---

  IF  x_last_update_from_date IS NOT NULL
  AND x_last_update_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_start_5'
      , 'doing cross field validations x_last_update_from_date > '
        || 'x_last_update_to_date'
      );
    END IF;

    -- if both x_last_update_from_date and x_last_update_to_date are
    -- entered then x_last_update_from_date should be before
    -- x_last_update_to_date

    IF x_last_update_from_date > x_last_update_to_date
    THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'lupdfrmdt_after_lupdtodt'
        , 'it is invalid to have x_last_update_from_date > '
          || 'x_last_update_to_date'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_VALUE_ERR');

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_LAST_UPDATE_FROM_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME1', l_prompt);

      SELECT
        form_left_prompt
      INTO
        l_prompt
      FROM
        fnd_descr_flex_col_usage_vl
      WHERE
          end_user_column_name       = 'P_LAST_UPDATE_TO_DATE'
      AND application_id             = 170
      AND descriptive_flexfield_name = '$SRS$.CSSRPGP';

      FND_MESSAGE.Set_Token('DATEFIELDNAME2', l_prompt);
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_end_5'
      , 'after doing cross field validations x_last_update_from_date > '
        || 'x_last_update_to_date'
      );
    END IF;
  END IF;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with Success'
    );
  END IF ;

END Validate_Purge_Params;

--------------------------------------------------------------------------------
--  Procedure Name            :   FORM_AND_EXEC_STATEMENT
--
--  Parameters (other than standard ones)
--
-- IN
--
-- p_request_id            : Concurrent Request Id of the
--                           current request
-- p_incident_id           : Indicates that SR with this id needs
--                           to be purged
-- p_incident_status_id    : Indicates that SR with this status id
--                           needs to be purged
-- p_incident_type_id      : Indicates that SRs with this type id
--                           needs to be purged
-- p_creation_from_date    : Indicates the lower end of the range of dates
--                           that need to be compared with CREATION_DATE of
--                           the SR to pick it up for purge
-- p_creation_to_date      : Indicates the higher end of the range of dates
--                           that need to be compared with CREATION_DATE of
--                           the SR to pick it up for purge
-- p_last_update_from_date : Indicates the lower end of the range of dates
--                           that need to be compared with LAST_UPDATED_DATE of
--                           the SR to pick it up for purge
-- p_last_update_to_date   : Indicates the higher end of the range of dates
--                           that need to be compared with LAST_UPDATED_DATE of
--                           the SR to pick it up for purge
-- p_customer_id           : Indicates that SRs with this customer_id need
--                           to be purged.
-- p_customer_acc_id       : Indicates that SRs with this customer acc id
--                           need to be purged
-- p_item_category_id      : Indicates that SRs created for items falling
--                           under this category need to be purged
-- p_inventory_item_id     : Indicates that SRs created for this item
--                           need to be purged
-- p_history_size          : Number of  customer SR's to retain while purging
--                           SRs identified using other parameters. This
--                           parameter alone CANNOT be used to identify a
--                           valid purgeset.
-- p_number_of_workers     : Number of workers that needs to be launched for
--                           purging Service Requests
--
-- OUT
--
-- p_row_count             : Number of rows inserted into the staging table
--
-- Description
--     This procedure takes all the validated concurrent request parameters
--     and based on their availability constructs and executes an SQL statement
--     that inserts SR ids that can be purged into the staging table. Bind
--     variables are created and used in the dynamic SQL.
--
-- HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure takes all the validated concurrent request parameters and
 * based on their availability constructs and executes an SQL statement that
 * inserts SR ids that can be purged into the staging table. Bind variables are
 * created and used in the dynamic SQL.
 * @param p_request_id Concurrent Request Id of the current request
 * @param p_incident_id Indicates that SR with this id needs to be purged
 * @param p_incident_status_id Indicates that SR with this status id needs to
 * be purged
 * @param p_incident_type_id Indicates that SRs with this type id needs to be
 * purged
 * @param p_creation_from_date Indicates the lower end of the range of dates
 * that need to be compared with CREATION_DATE of the SR to pick it up for
 * purge
 * @param p_creation_to_date Indicates the higher end of the range of dates
 * that need to be compared with CREATION_DATE of the SR to pick it up for purge
 * @param p_last_update_from_date Indicates the lower end of the range of dates
 * that need to be compared with LAST_UPDATED_DATE of the SR to pick it up for
 * purge
 * @param p_last_update_to_date Indicates the higher end of the range of dates
 * that need to be compared with LAST_UPDATED_DATE of the SR to pick it up for
 * purge
 * @param p_customer_id Indicates that SRs with this customer_id need to be
 * purged.
 * @param p_customer_acc_id Indicates that SRs with this customer acc id need
 * to be purged
 * @param p_item_category_id Indicates that SRs created for items falling under
 * this category need to be purged
 * @param p_inventory_item_id Indicates that SRs created for this item need to
 * be purged
 * @param p_history_size Number of  customer SR's to retain while purging SRs
 * identified using other parameters. This parameter alone CANNOT be used to
 * identify a valid purgeset.
 * @param p_number_of_workers Number of workers that needs to be launched for
 * purging Service Requests
 * @param p_row_count Number of rows inserted into the staging table
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Form and Execute SQL Statement
 */
PROCEDURE Form_And_Exec_Statement
(
  p_incident_id                   IN              NUMBER
, p_incident_status_id            IN              NUMBER
, p_incident_type_id              IN              NUMBER
, p_creation_from_date            IN              DATE
, p_creation_to_date              IN              DATE
, p_last_update_from_date         IN              DATE
, p_last_update_to_date           IN              DATE
, p_customer_id                   IN              NUMBER
, p_customer_acc_id               IN              NUMBER
, p_item_category_id              IN              NUMBER
, p_inventory_item_id             IN              NUMBER
, p_history_size                  IN              NUMBER
, p_number_of_workers             IN OUT NOCOPY   NUMBER
, p_purge_batch_size              IN              NUMBER
, p_request_id                    IN              NUMBER
, p_row_count                     OUT NOCOPY      NUMBER
)
IS
--------------------------------------------------------------------------------

L_API_NAME      CONSTANT VARCHAR2(30) := 'FORM_AND_EXEC_STATEMENT';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

-- PL/SQL tables defined for holding bind variables for the
-- where clause which is constructed and added to the main
-- SQL that will identify SRs that need to be purged

TYPE t_bind_var_val_arr  IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
TYPE t_bind_var_type_arr IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE t_where_clause_arr  IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;

-- Actual number of worker concurrent requests
-- to be started based on the number of SRs in
-- the purgeset.

l_number_of_workers             NUMBER;

-- variables used to hold intermediate information that
-- is used to construct a full-blown SQL statement by
-- collecting all the purge parameters and making a
-- predicate out of them

l_bind_var_val_arr              t_bind_var_val_arr;
l_bind_var_type_arr             t_bind_var_type_arr;
l_where_clause_arr              t_where_clause_arr;
l_bind_var_ctr                  NUMBER;

l_sql_statement                 VARCHAR2(10000);
l_where_clause                  VARCHAR2(4000);
l_dbms_sql_cursor               NUMBER;

l_row_count                     NUMBER;

BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_incident_id:' || p_incident_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_incident_status_id:' || p_incident_status_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_incident_type_id:' || p_incident_type_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_creation_from_date:' || p_creation_from_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_creation_to_date:' || p_creation_to_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_last_update_from_date:' || p_last_update_from_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_last_update_to_date:' || p_last_update_to_date
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_customer_id:' || p_customer_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_customer_acc_id:' || p_customer_acc_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 10'
    , 'p_item_category_id:' || p_item_category_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 11'
    , 'p_inventory_item_id:' || p_inventory_item_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 12'
    , 'p_history_size:' || p_history_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 13'
    , 'p_number_of_workers:' || p_number_of_workers
    );
  END IF;

  -- Initializing the bind variable counter to 0.
  -- This variable will be incremented for each
  -- bind variable that is added to the where clause.

  l_bind_var_ctr := 0;

  ---

  IF p_incident_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_incident_id_start'
      , 'Framing where clause for incident_id'
      );
    END IF;

    -- frame the where clause for the parameter p_incident_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' incident_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_incident_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_incident_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_incident_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_incident_id_end'
      , 'After framing where clause for incident_id'
        || l_where_clause_arr(l_bind_var_ctr)
      );
    END IF;
  END IF;

  ---

  IF p_incident_status_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_status_id_start'
      , 'framing where clause for status_id'
      );
    END IF;

    -- frame the where clause for the parameter p_incident_status_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' incident_status_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_incident_status_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_status_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_status_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_status_id_end'
      , 'after framing where clause for status_id '
        || l_where_clause_arr(l_bind_var_ctr)
      );
    END IF;
  END IF;

  ---

  IF p_incident_type_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_type_id_start'
      , 'framing where clause for p_incident_type_id'
      );
    END IF;

    -- frame the where clause for the parameter p_incident_type_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' incident_type_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_incident_type_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_type_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_type_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_type_id_end'
      , 'after framing where clause for p_incident_type_id'
      );
    END IF;
  END IF;


  ---

  IF p_creation_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_from_date_start'
      , 'framing where clause for p_creation_from_date'
      );
    END IF;

    -- frame the where clause for the parameter p_creation_from_date
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' creation_date >= :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := TO_CHAR
    (
      p_creation_from_date
    , 'DD-MM-RRRR HH24:MI:SS'
    );
    l_bind_var_type_arr(l_bind_var_ctr) := 'D';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_from_date_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_from_date_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_from_date_end'
      , 'after framing where clause for p_creation_from_date'
      );
    END IF;
  END IF;

  ---

  IF p_creation_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_to_date_start'
      , 'framing where clause for p_creation_to_date'
      );
    END IF;

    -- frame the where clause for the parameter p_creation_to_date
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' creation_date <= :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := TO_CHAR
    (
      p_creation_to_date
    , 'DD-MM-RRRR HH24:MI:SS'
    );
    l_bind_var_type_arr(l_bind_var_ctr) := 'D';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_to_date_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_to_date_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_creation_to_date_end'
      , 'after framing where clause for p_creation_to_date'
      );
    END IF;
  END IF;

  ---

  IF p_last_update_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_from_date_start'
      , 'framing where clause for p_last_update_from_date'
      );
    END IF;

    -- frame the where clause for the parameter p_last_update_from_date
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' last_update_date >= :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := TO_CHAR
    (
      p_last_update_from_date
    , 'DD-MM-RRRR HH24:MI:SS'
    );
    l_bind_var_type_arr(l_bind_var_ctr) := 'D';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_from_date_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_from_date_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_from_date_end'
      , 'after framing where clause for p_last_update_from_date'
      );
    END IF;
  END IF;

  ---

  IF p_last_update_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_to_date_start'
      , 'framing where clause for p_last_update_to_date'
      );
    END IF;

    -- frame the where clause for the parameter p_last_update_to_date
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' last_update_date <= :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := TO_CHAR
    (
      p_last_update_to_date
    , 'DD-MM-RRRR HH24:MI:SS'
    );
    l_bind_var_type_arr(l_bind_var_ctr) := 'D';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_to_date_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_to_date_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_last_update_to_date_end'
      , 'after framing where clause for p_last_update_to_date'
      );
    END IF;
  END IF;

  ---

  IF p_customer_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_id_start'
      , 'framing where clause for p_customer_id'
      );
    END IF;

    -- frame the where clause for the parameter p_customer_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' customer_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_customer_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_id_end'
      , 'after framing where clause for p_customer_id'
      );
    END IF;
  END IF;

  ---

  IF p_customer_acc_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_acc_id_start'
      , 'framing where clause for p_customer_acc_id'
      );
    END IF;

    -- frame the where clause for the parameter p_customer_acc_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' account_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_customer_acc_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_acc_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_acc_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_customer_acc_id_end'
      , 'after framing where clause for p_customer_acc_id'
      );
    END IF;
  END IF;

  ---

  IF p_item_category_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_item_category_id_start'
      , 'framing where clause for p_item_category_id'
      );
    END IF;

    -- frame the where clause for the parameter p_item_category_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' category_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_item_category_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_item_category_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_item_category_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_item_category_id_end'
      , 'after framing where clause for p_item_category_id'
      );
    END IF;
  END IF;

  ---

  IF p_inventory_item_id IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_inventory_item_id_start'
      , 'framing where clause for p_inventory_item_id'
      );
    END IF;

    -- frame the where clause for the parameter p_item_category_id
    -- along with the bind variable value into the plsql tables

    l_bind_var_ctr                      := l_bind_var_ctr + 1;
    l_where_clause_arr(l_bind_var_ctr)  := ' inventory_item_id = :bind'
                                        || l_bind_var_ctr || ' ';
    l_bind_var_val_arr(l_bind_var_ctr)  := p_inventory_item_id;
    l_bind_var_type_arr(l_bind_var_ctr) := 'N';

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_inventory_item_id_1'
      , 'l_where_clause_arr(l_bind_var_ctr):'
        || l_where_clause_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_inventory_item_id_2'
      , 'l_bind_var_val_arr(l_bind_var_ctr):'
        || l_bind_var_val_arr(l_bind_var_ctr)
      );
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'where_inventory_item_id_end'
      , 'after framing where clause for p_inventory_item_id'
      );
    END IF;
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'final_where_clause_start'
    , 'framing final where clause'
    );
  END IF;

  -- Initializing the where clause to eleminate SRs that
  -- have depot repair orders linked to them. We do not
  -- purge these SRs now.

  l_where_clause :=    ' NOT EXISTS '
                    || ' ( '
                    || '     SELECT '
                    || '         1 '
                    || '     FROM '
                    || '         csd_repairs '
                    || '     WHERE '
                    || '         incident_id = basetbl.incident_id '
                    || ' ) ';

  IF p_incident_id IS NULL
  THEN
    -- If the incident_id is null, then include the
    -- clause to filter out only SRs that are closed.

    l_where_clause := l_where_clause || ' AND basetbl.status_flag = ''C'' ';
  END IF;

  IF p_incident_type_id IS NULL
  THEN

    -- If the incident type is not chosen in the purge parameters
    -- make sure no SRs of type CMRO or EAM are included in the
    -- purge set. These SRs shall not be purged now.

    l_where_clause  := l_where_clause || ' AND '
                    || ' NOT EXISTS '
                    || ' ( '
                    || '     SELECT '
                    || '         1 '
                    || '     FROM '
                    || '         cs_incident_types_b '
                    || '     WHERE '
                    || '         incident_type_id = basetbl.incident_type_id '
                    || '     AND '
                    || '         ( '
                    || '             NVL(maintenance_flag, ''N'') = ''Y'' '
                    || '         OR  NVL(cmro_flag, ''N'') = ''Y'' '
                    || '         ) '
                    || ' ) ';
  END IF;

  -- constructing the where clause from the pl/sql table
  -- formed by looking up the values of the purge parameters

  FOR j in 1..l_bind_var_ctr
  LOOP
    l_where_clause := l_where_clause || ' AND ' || l_where_clause_arr(j);
  END LOOP;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'final_where_clause_end'
    , 'l_where_clause:' || l_where_clause
    );
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'final_where_clause_end'
    , 'after framing final where clause'
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'final_select_start'
    , 'framing final select statement'
    );
  END IF;

  -- Initializing the statement to insert the SRs to be
  -- purged into the STAGING table. The APPEND hint is used
  -- to make sure no redo log is generated. After executing
  -- this statement, a COMMIT is mandated.

  l_sql_statement   := ' INSERT /*+ APPEND */ INTO cs_incidents_purge_staging '
                    || ' ( '
                    || '      incident_id '
                    || ' ,  worker_id '
                    || ' ,  concurrent_request_id '
                    || ' ) '
                    || ' SELECT '
                    || '      incident_id '
                    || ' ,  NULL '
                    || ' ,  :request_id ';

  IF p_history_size IS NOT NULL
  THEN

    -- If the Retain Service History parameter is given a value,
    -- a sub query is constructed which ranks the rows in the table
    -- for each customer_id and based on the incident_id and creation
    -- date in order to choose all the SRs that fall after the
    -- number specified in the History Size.

    l_sql_statement := l_sql_statement
                    || ' FROM '
                    || ' ( '
                    || '    SELECT '
                    || '        incident_id '
                    || '    , RANK() OVER '
                    || '        ( '
                    || '        PARTITION BY '
                    || '            customer_id '
                    || '        ORDER BY '
                    || '            creation_date DESC '
                    || '        ,   incident_id   DESC '
                    || '        ) AS group_row_num '
                    || '    FROM '
                    || '        cs_incidents_all_b basetbl '
                    || '    WHERE '
                    ||          l_where_clause
                    || ' ) inner '
                    || ' WHERE '
                    || '     inner.group_row_num > :histoy_size ';
  ELSIF p_history_size IS NULL

    -- If the Service History parameter is NOT selected, only
    -- the where clause is appended to the main query.

  THEN
    l_sql_statement := l_sql_statement
                    || ' FROM '
                    || '     cs_incidents_all_b basetbl '
                    || ' WHERE '
                    ||       l_where_clause;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'final_select_end'
    , 'l_sql_statement:' || l_sql_statement
    );
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'final_select_end'
    , 'after framing final select statement'
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sql_execution_start'
    , 'Executing the SQL framed to insert SRs to staging table'
    );
  END IF;

  -- Open a cursor to execute the Dynamic SQL

  l_dbms_sql_cursor := DBMS_SQL.OPEN_CURSOR;

  -- Parse the sql dynamic SQL statement

  DBMS_SQL.PARSE
  (
    l_dbms_sql_cursor
  , l_sql_statement
  , DBMS_SQL.NATIVE
  );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'bind_variable_values'
    , ':request_id - ' || p_request_id
    );
  END IF;

  -- Bind value of the variable p_request_id to the dynamic SQL

  DBMS_SQL.BIND_VARIABLE
  (
    l_dbms_sql_cursor
  , ':request_id'
  , p_request_id
  );

  FOR j IN 1..l_bind_var_ctr
  LOOP
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'bind_variable_values'
      , ':bind' || j || '(' || l_bind_var_type_arr(j) || ') - '
        || l_bind_var_val_arr(j)
      );
    END IF;

    -- Bind value of the variables the dynamic SQL

    IF l_bind_var_type_arr(j) = 'V'
    THEN
      DBMS_SQL.BIND_VARIABLE
      (
        l_dbms_sql_cursor
      , ':bind' || j
      , l_bind_var_val_arr(j)
      );
    ELSIF l_bind_var_type_arr(j) = 'N'
    THEN
      DBMS_SQL.BIND_VARIABLE
      (
        l_dbms_sql_cursor
      , ':bind' || j
      , TO_NUMBER(l_bind_var_val_arr(j))
      );
    ELSIF l_bind_var_type_arr(j) = 'D'
    THEN
      DBMS_SQL.BIND_VARIABLE
      (
        l_dbms_sql_cursor
      , ':bind' || j
      , TO_DATE(l_bind_var_val_arr(j), 'DD-MM-RRRR HH24:MI:SS')
      );
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'bind_variable_values'
      , 'after binding the field ' || j
      );
    END IF;
  END LOOP;

  IF p_history_size IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'bind_variable_values'
      , ':histoy_size - ' || p_history_size
      );
    END IF;

    -- Bind value of the variable p_history_size to the dynamic SQL

    DBMS_SQL.BIND_VARIABLE
    (
      l_dbms_sql_cursor
    , ':histoy_size'
    , p_history_size
    );
  END IF;

  -- Execute the Query

  p_row_count := DBMS_SQL.EXECUTE
  (
    l_dbms_sql_cursor
  );

  -- Since the APPEND hint forces to commit
  -- after the transaction, committing here

  COMMIT;

  DBMS_SQL.CLOSE_CURSOR
  (
    l_dbms_sql_cursor
  );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sql_execution_end'
    , 'After executing the SQL framed to insert SRs to '
      || 'staging table - inserted ' || p_row_count || ' rows'
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'compute_required_workers_start'
    , 'Computing required number of worker concurrent requests'
    );
  END IF;

  -- Computing the number of worker concurrent
  -- requests required for purging the SRs.
  -- The approach followed to decide on howmany
  -- workers is required is as follows:
  -- 1. If the no. of rows < batch size, only 1 worker
  --    is required for processing the purge set.
  -- 2. If the no. of rows > batch size, ceil(batch_size / no_of_rows)
  --    is the no. of workers required for processing the purge set.
  --    But if this is more than the no. of workers asked for,
  --    no. of workers is = p_number_of_workers. Otherwise, it will
  --    be the result of the above formula.

  IF p_row_count <= p_purge_batch_size
  THEN
    l_number_of_workers := 1;
  ELSIF p_row_count > p_purge_batch_size
  THEN
    l_number_of_workers := LEAST
    (
        p_number_of_workers
    , CEIL(p_row_count / p_purge_batch_size)
    );
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'compute_required_workers_end'
    , 'Starting worker concurrent requests : asked for - '
      || p_number_of_workers || ', actual - '
      || l_number_of_workers
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'allocating_worker_id_start'
    , 'Allocating worker ids to rows in the staging table'
    );
  END IF;

  -- Updating the staging table with the worker id
  -- which helps in dividing the work among the
  -- number of workers actually required for working
  -- on the current purge set.

  UPDATE cs_incidents_purge_staging
  SET
    worker_id = MOD
    (
      ROWNUM - 1
    , l_number_of_workers
    ) + 1;

  l_row_count := SQL%ROWCOUNT;

  COMMIT;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'allocating_worker_id_end'
    , 'After allocating worker ids to rows in the staging table '
      || l_row_count
    );
  END IF;

  p_number_of_workers := l_number_of_workers;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with Success'
    );
  END IF ;
END Form_And_Exec_Statement;

--------------------------------------------------------------------------------
--  Procedure Name            :   WRITE_PURGE_OUTPUT
--
--  Parameters (other than standard ones)
--  p_purge_batch_size : Used to indicate the number of rows that need to
--                       be inserted into the output file at any point in time.
--                       This parameter is the same batch size that is used
--                       while picking up SRs for purging.
--  p_request_id       : Concurrent Request id for which output needs to be
--                       generated.
--  p_worker_id        : Worker Number for which the output needs to be
--                       generated. This field can be left NULL if the
--                       output is to be generated for the parent request.
--
--  Description
--      This procedure lists out the number of SRs submitted for purge, the
--      number of SRs that were successfully purged and the number of SRs that
--      failed purge due to business reasons. This also prints a list of the
--      SRs that failed for business reasons along with the error messages.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure lists out the number of SRs submitted for purge, the number
 * of SRs that were successfully purged and the number of SRs that failed purge
 * due to business reasons. This also prints a list of the SRs that failed for
 * business reasons along with the error messages.
 * @param p_purge_batch_size Used to indicate the number of rows that need to
 * be inserted into the output file at any point in time. This parameter is
 * the same batch size that is used while picking up SRs for purging.
 * @param p_request_id Concurrent Request id for which output needs to be
 * generated.
 * @param p_worker_id Worker Number for which the output needs to be generated.
 * This field can be left NULL if the output is to be generated for the parent
 * request.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Write Purge Program Output
 */
PROCEDURE Write_Purge_Output
(
  p_purge_batch_size     IN   NUMBER
, p_request_id           IN   NUMBER
, p_worker_id            IN   NUMBER := NULL
)
IS
--------------------------------------------------------------------------------

L_API_NAME      CONSTANT VARCHAR2(30) := 'WRITE_PURGE_OUTPUT';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

TYPE t_varchar_arr IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
TYPE t_number_arr  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Cursor used to fetch all the SRs that could not
-- be purged due to business reasons as indicated
-- by the various validation routines, along with
-- the basic information of those SRs, to be used
-- to generate a report of such SRs.

CURSOR c_purge_staging_err
IS
  SELECT
    b.incident_number       incident_number
  , p.party_number          customer_number
  , i.segment1              item_number
  , t.summary               summary
  , s.purge_error_message   purge_error_message
  FROM
    cs_incidents_purge_staging  s
  , cs_incidents_all_b          b
  , cs_incidents_all_tl         t
  , mtl_system_items_b          i
  , hz_parties                  p
  WHERE
      s.purge_status          = 'E'
  AND s.incident_id           = b.incident_id
  AND s.incident_id           = t.incident_id
  AND b.inventory_item_id     = i.inventory_item_id(+)
  AND b.inv_organization_id   = i.organization_id(+)
  AND b.customer_id           = p.party_id
  AND t.language              = USERENV('LANG')
  AND s.concurrent_request_id = p_request_id
  AND s.worker_id             = NVL(p_worker_id, s.worker_id)
  ORDER BY
    b.incident_number;

l_incident_number_arr           t_number_arr;
l_customer_number_arr           t_number_arr;
l_item_number_arr               t_varchar_arr;
l_summary_arr                   t_varchar_arr;
l_purge_error_message_arr       t_varchar_arr;

l_row_count                     NUMBER;
l_report_caption                VARCHAR2(2000);
l_text                          VARCHAR2(2000);
l_error_code_loc                NUMBER;
l_error_message_loc             NUMBER;
l_error_message_text            VARCHAR2(2000);

l_exec_count                    NUMBER := 0;

BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_purge_batch_size:' || p_purge_batch_size
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_request_id:' || p_request_id
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_worker_id:' || p_worker_id
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_submit_count_start'
    , 'Getting number of SRs submitted for purge'
    );
  END IF;

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<html><body>'
  );
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'html_output_1'
    , '<html><body>'
    );
  END IF;

  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_PURGE_RESULT'
  );
  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<h3>' || l_report_caption
    || '</h3><table border cellspacing=0 cellpadding=5 width=40%>'
  );
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'html_output_2'
    , '<h3>' || l_report_caption
      || '</h3><table border cellspacing=0 cellpadding=5 width=40%>'
    );
  END IF;

  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_PURGE_SUBMIT_COUNT'
  );

  -- Query to find out the total number of SRs
  -- submitted for purge

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_incidents_purge_staging s
  WHERE
    s.worker_id = NVL(p_worker_id, s.worker_id);

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<tr><td><b>' || l_report_caption || '</b></td><td><b>'
    || l_row_count || '</b></td></tr>'
  );
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'html_output_3'
    , '<tr><td><b>' || l_report_caption || '</b></td><td><b>'
      || l_row_count || '</b></td></tr>'
    );
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_submit_count_end'
    , 'After getting number of SRs submitted for purge ' || l_row_count
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_success_count_start'
    , 'Getting number of SRs Successfully purged'
    );
  END IF;

  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_PURGE_SUCCESS_COUNT'
  );

  -- Query to find out the total number of SRs
  -- successfully purged

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_incidents_purge_staging s
  WHERE
      purge_status = 'S'
  AND s.worker_id = NVL(p_worker_id, s.worker_id);

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<tr><td><b>' || l_report_caption || '</b></td><td><font color=green><b>'
    || l_row_count || '</b></font></td></tr>'
  );
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'html_output_4'
    , '<tr><td><b>' || l_report_caption || '</b></td><td><font color=green><b>'
      || l_row_count || '</b></font></td></tr>'
    );
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_success_count_end'
    , 'After getting number of SRs Successfully purged ' || l_row_count
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_notdone_count_start'
    , 'Getting number of SRs not attempted to be purged'
    );
  END IF;

  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_PURGE_NOTDONE_COUNT'
  );

  -- Query to find out the total number of SRs
  -- successfully purged

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_incidents_purge_staging s
  WHERE
      purge_status IS NULL
  AND s.worker_id = NVL(p_worker_id, s.worker_id);

  IF l_row_count > 0

    -- if there were some rows that were not
    -- processed, display that too in the report.

  THEN
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<tr><td><b>' || l_report_caption
      || '</b></td><td><font color=blue><b>'
      || l_row_count || '</b></font></td></tr>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_5'
      , '<tr><td><b>' || l_report_caption
        || '</b></td><td><font color=blue><b>' || l_row_count
        || '</b></font></td></tr>'
      );
    END IF;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_success_count_end'
    , 'After getting number of SRs not attempted to be purged '
      || l_row_count
    );
  END IF;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_failed_count_start'
    , 'Getting number of SRs not purged due to validation failures'
    );
  END IF;

  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_PURGE_FAILURE_COUNT'
  );

  -- Query to find out the total number of SRs
  -- failed while attempting to purge due to
  -- failure in validations

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_incidents_purge_staging s
  WHERE
      purge_status = 'E'
  AND s.worker_id = NVL(p_worker_id, s.worker_id);

  IF l_row_count > 0

    -- if there were some rows that failed during
    -- processing, display that in the report.

  THEN
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<tr><td><b>' || l_report_caption
      || '</b></td><td><font color=red><b>' || l_row_count
      || '</b></font></td></tr></table>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_6'
      , '<tr><td><b>' || l_report_caption
        || '</b></td><td><font color=red><b>' || l_row_count
        || '</b></font></td></tr></table>'
      );
    END IF;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_failed_count_end'
    , 'After getting number of SRs not purged due to validation failures '
      || l_row_count
    );
  END IF;

  ---

  IF l_row_count > 0

    -- if there are any rows in the staging
    -- table with purge_status = E

  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'sr_failure_report_start'
      , 'Listing all SRs that failed with details and error message'
      );
    END IF;

    -- Starting to print the report on all the SRs that failed
    -- purge due to business reasons along with the vital details

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<h3>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_7'
      , '<h3>'
      );
    END IF;

    l_report_caption := FND_MESSAGE.Get_String
    (
      'CS'
    , 'CS_SR_FAILED_SRS_REPORT'
    );
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , l_report_caption
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_8'
      , l_report_caption
      );
    END IF;

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '</h3>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_9'
      , '</h3>'
      );
    END IF;

    ---

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<table border cellspacing=0 width=100%><tr>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_10'
      , '<table border cellspacing=0 width=100%><tr>'
      );
    END IF;

    l_report_caption := FND_MESSAGE.Get_String
    (
      'CS'
    , 'CS_SR_FAILED_SRS_RPT_HEAD'
    );
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , l_report_caption
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_11'
      , l_report_caption
      );
    END IF;

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '</tr>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_12'
      , '</tr>'
      );
    END IF;

    -- Opening cursor on staging table that lists
    -- all the SRs that failed due to business reasons
    -- along with the vital details of the SR

    OPEN c_purge_staging_err;

    -- Loop that retrieves the rows from the staging table
    -- in batches and prints the output file.

    LOOP
      FETCH c_purge_staging_err
      BULK COLLECT INTO
        l_incident_number_arr
      , l_customer_number_arr
      , l_item_number_arr
      , l_summary_arr
      , l_purge_error_message_arr
      LIMIT p_purge_batch_size;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'report_fetch_count'
        , 'Fetched ' || l_incident_number_arr.COUNT
          || ' rows during this execution'
        );
      END IF;

      IF l_incident_number_arr.COUNT > 0
      THEN

        -- Inner loop that inserts the current batch of
        -- SRs into the output file. Here, it is assumed
        -- that the purge_error_message field contains
        -- messages in the format
        -- <product>:<message code>~<concurrent request text-message>
        -- using which the message text is retrieved from
        -- the message dictionary.

        FOR j IN l_incident_number_arr.FIRST..l_incident_number_arr.LAST
        LOOP
          fnd_file.put_line
          (
            FND_FILE.OUTPUT
          , '<tr>'
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'html_output_13'
            , '<tr>'
            );
          END IF;

          l_text := '<td>' || l_incident_number_arr(j)
                    ||  '</td><td>' || l_customer_number_arr(j)
                    ||  '</td><td>' || NVL(l_item_number_arr(j), '-')
                    ||  '</td><td>' || l_summary_arr(j)
                    ||  '</td><td>';

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'compute_text'
            , 'framing l_text = ' || l_text
            );
          END IF;

          l_error_code_loc := INSTR
          (
            l_purge_error_message_arr(j)
          , ':'
          , 1
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'compute_text_1'
            , 'getting l_error_code_loc = ' || l_error_code_loc
            );
          END IF;

          l_error_message_loc := INSTR
          (
            l_purge_error_message_arr(j)
          , '~'
          , 1
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'compute_text_2'
            , 'getting l_error_message_loc = ' || l_error_message_loc
            );
          END IF;

          IF l_error_message_loc > 0
          THEN
            l_error_message_text := FND_MESSAGE.Get_String
            (
              SUBSTR
              (
                  l_purge_error_message_arr(j)
              , 1
              , l_error_code_loc - 1
              )
            , SUBSTR
              (
                  l_purge_error_message_arr(j)
              , l_error_code_loc + 1
              , l_error_message_loc - l_error_code_loc - 1
              )
            )
            || ' - '
            || SUBSTR
            (
              l_purge_error_message_arr(j)
            , l_error_message_loc + 1
            );

            IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
            THEN
              FND_LOG.String
              (
                FND_LOG.level_statement
              , L_LOG_MODULE || 'compute_text_3.1'
              , 'getting l_error_message_text = ' || l_error_message_text
              );
            END IF;
          ELSIF l_error_message_loc <= 0
          THEN
            l_error_message_text := FND_MESSAGE.Get_String
            (
              SUBSTR
              (
                l_purge_error_message_arr(j)
              , 1
              , l_error_code_loc - 1
              )
            , SUBSTR
              (
                l_purge_error_message_arr(j)
              , l_error_code_loc + 1
              )
            );

            IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
            THEN
              FND_LOG.String
              (
                FND_LOG.level_statement
              , L_LOG_MODULE || 'compute_text_3.2'
              , 'getting l_error_message_text = ' || l_error_message_text
              );
            END IF;
          END IF;

          l_text := l_text || NVL(l_error_message_text, '-') || '</td>';

          fnd_file.put_line
          (
            FND_FILE.OUTPUT
          , l_text
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'html_output_14'
            , l_text
            );
          END IF;

          fnd_file.put_line
          (
            FND_FILE.OUTPUT
          , '</tr>'
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'html_output_15'
            , '</tr>'
            );
          END IF;
        END LOOP;
      END IF;

      EXIT WHEN c_purge_staging_err%NOTFOUND;
    END LOOP;

    CLOSE c_purge_staging_err;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'sr_failure_report_end'
      , 'After listing all SRs that failed with details and error message'
      );
    END IF;
  END IF;

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '</table></body></html>'
  );
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'html_output_16'
    , '</table></body></html>'
    );
  END IF;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with Success'
    );
  END IF ;
END Write_Purge_Output;
--------------------------------------------------------------------------------

END CS_SR_PURGE_CP;

/
