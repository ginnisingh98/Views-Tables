--------------------------------------------------------
--  DDL for Package Body QA_SOLUTION_DISPOSITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SOLUTION_DISPOSITION_PKG" as
/* $Header: qasodisb.pls 120.1.12010000.3 2010/04/26 17:23:12 ntungare ship $ */

 -- Package level constants

 -- check every 900 seconds to find the request completed or not.

 -- Bug 2696473. Reduced the time interval for checking the request completion
 -- to 30 seconds.

 g_check_request_time  CONSTANT NUMBER := 30;

 -- wait for 6000 seconds for the concurrent request to complete.
 g_total_request_time  CONSTANT NUMBER := 6000;

 -- Bug 3684073. Modified the constants to VARCHAR2 below.
 -- We are no longer using mfg_lookups to derive the lookup_code.
 -- g_lookup_yes CONSTANT NUMBER := 1;  -- 1 is lookup_code for 'YES' in mfg_lookups.
 -- g_lookup_no  CONSTANT NUMBER := 2;  -- 2 is lookup_code for 'NO' in mfg_lookups.

 g_lookup_yes CONSTANT VARCHAR2(3) := 'YES';
 g_lookup_no  CONSTANT VARCHAR2(3) := 'NO';

 g_success CONSTANT VARCHAR2(10) := 'SUCCESS';
 g_failed  CONSTANT VARCHAR2(10) := 'FAILED';
 g_warning CONSTANT VARCHAR2(10) := 'WARNING';
 g_int_err CONSTANT VARCHAR2(10) := 'INT_ERROR';

 -- Bug 2689276. Added the below variable.
 g_pending CONSTANT VARCHAR2(10) := 'PENDING';

-------------------------------------------------------------------------------
--  Forward declaration of Local functions.
-------------------------------------------------------------------------------

 FUNCTION get_mfg_lookups_value (p_meaning     VARCHAR2,
                                 p_lookup_type VARCHAR2)  RETURN NUMBER;

 FUNCTION get_organization_id (p_organization_code VARCHAR2)  RETURN NUMBER;
 FUNCTION get_plan_id(p_plan_name VARCHAR2)  RETURN NUMBER;

  -- anagarwa Fri Jul  2 16:30:00 PDT 2004
  -- bug 3736593 action fired element cannot be validated.
  -- following function looks for values in qa_plan_char_value_lookups and
  -- if not found, it executes the sql validation string
 TYPE LookupCur IS REF CURSOR;
 FUNCTION get_short_code(p_plan_id NUMBER,
                         p_char_id NUMBER,
                         p_short_code IN VARCHAR2) RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- Create a New Work Order API
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    REWORK_NEW_NONSTANDARD_JOB
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_job_class                 => Class of the Job to be created.This should be 'Rework'
--     p_job_name                  => Name of the Rework Job to be created
--     p_job_start                 => Start Date of the Job
--     p_job_end                   => End Date of the Job
--     p_bill_reference            => Bill reference
--     p_bom_revision              => Bom revision
--     p_routing_reference         => Routing reference
--     p_routing_revision          => Routing revision
--     p_quantity                  => Quantity
--     p_job_mrp_net_quantity      => MRP Net Quantity
--     p_project_number            => Project Number
--     p_task_number               => Task Number
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully create Rework Job
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully create Rework Job
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  We are performing all the below activities here
--
--    1. Get the different id values.
--    2. Call REWORK_NEW_NONSTANDARD_JOB_INT() procedure for inserting into interface table
--       and spawn the WIP Mass Load Program (WICMLX).
--    3. Wait for the Mass Load Program to get completed.
--    4. Get the results and perform the handshaking. Call the procedure
--       WRITE_BACK() for performing the same.
--
--  End of Comments
--
--  Bug Fixes
--
--    Bug 2689276 : Call WRITE_BACK() to handshake the concurrent request id as
--                  soon as the concurrnt request gets launched.
--
--    Bug 2656461 : Code added to support copying of attachments to the
--                  WIP_DISCRETE_OPERATIONS entity, once the Action is successful.
--
--    Bug 2697388 : Changed the parameter p_bill_revision to p_bom_revision. Functionality
--                  remains the same. kabalakr Tue Dec 17 22:48:31 PST 2002.
--
--    Bug 2720431 : Added one more parameter p_job_mrp_net_quantity to the API. This input
--                  parameter carries the value for MRP Net Quantiy of the new rework Job.
--
--
--
--


 PROCEDURE REWORK_NEW_NONSTANDARD_JOB(
                  p_item                  IN VARCHAR2,
                  p_job_class             IN VARCHAR2,
                  p_job_name              IN VARCHAR2,
                  p_job_start             IN VARCHAR2,
                  p_job_end               IN VARCHAR2,
                  p_bill_reference        IN VARCHAR2,
                  p_bom_revision          IN VARCHAR2,
                  p_routing_reference     IN VARCHAR2,
                  p_routing_revision      IN VARCHAR2,
                  p_quantity              IN NUMBER,
                  p_job_mrp_net_quantity  IN NUMBER,
                  p_project_number        IN VARCHAR2,
                  p_task_number           IN VARCHAR2,
                  p_collection_id         IN NUMBER,
                  p_occurrence            IN NUMBER,
                  p_organization_code     IN VARCHAR2,
                  p_plan_name             IN VARCHAR2,
                  p_launch_action         IN VARCHAR2,
                  p_action_fired          IN VARCHAR2) IS


  l_request          NUMBER;
  l_group_id         NUMBER;
  l_plan_id          NUMBER;
  l_organization_id  NUMBER;

  -- Bug 3684073. These variables are no longer required.
  -- l_launch_action    NUMBER;
  -- l_action_fired     NUMBER;

  l_err_msg          VARCHAR2(2000)  := NULL;

  l_wait           BOOLEAN;
  l_phase          VARCHAR2(2000);
  l_status         VARCHAR2(2000);
  l_devphase       VARCHAR2(2000);
  l_devstatus      VARCHAR2(2000);
  l_message        VARCHAR2(2000);

  l_error          VARCHAR2(1000);
  l_job_id         NUMBER := NULL;
  l_result         VARCHAR2(1800);
  l_item_id        NUMBER;

  l_bill_id        NUMBER;
  l_routing_id     NUMBER;

  l_source_code    VARCHAR2(30);

  CURSOR group_cur IS
     SELECT WIP_JOB_SCHEDULE_INTERFACE_S.nextval
     FROM   DUAL;

  -- Bug 3019869. Changed the below cursor to wip_job cursor.
  -- Records will not reside in WJSI if the MRP Debug mode
  -- profile option is set to 'No'. kabalakr

  /*
  CURSOR job_cur IS
     SELECT we.wip_entity_id
     FROM   WIP_ENTITIES we, WIP_JOB_SCHEDULE_INTERFACE wjsi
     WHERE  wjsi.process_status = 4
     AND    wjsi.group_id = l_group_id
     AND    we.wip_entity_id = wjsi.wip_entity_id;
  */

  -- Bug 3641781. Modified the sql to include primary_item_id.
  -- This would avoid a full table scan on wip_discrete_jobs and
  -- make the sql pick up the NON-UNIQUE index WIP_DISCRETE_JOBS_N1
  -- (on primary_item_id). kabalakr

  CURSOR wip_job(l_src_code VARCHAR2, l_pri_item_id NUMBER) IS
     SELECT wip_entity_id
     FROM   wip_discrete_jobs
     WHERE  primary_item_id = l_pri_item_id
     AND    source_code = l_src_code;

 BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- Launch_action is 'Yes' and Action_fired is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
    NULL;

  ELSE
    -- dont fire the action.
    RETURN;
  END IF;

  -- Get the plan_id, group_id and org_id now.
  OPEN group_cur;
  FETCH group_cur INTO l_group_id;
  CLOSE group_cur;

  l_organization_id  := get_organization_id(p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);

  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Update the Disposition Status to 'Pending'.
  UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

  l_item_id    := qa_flex_util.get_item_id(l_organization_id, p_item);
  l_bill_id    := qa_flex_util.get_item_id(l_organization_id, p_bill_reference);
  l_routing_id := qa_flex_util.get_item_id(l_organization_id, p_routing_reference);


  -- Call the rework_int(). It returns back the concurrent request
  -- id of the WIP Mass Load Program that gets spawned.

  -- Bug 2697388. Changed the argument p_bill_revision to p_bom_revision.

  -- Bug 2720431. Added p_job_mrp_net_quantity. This parameter carries the value
  -- for MRP Net Quantiy of the new rework Job. kabalakr.

  l_request := REWORK_NEW_NONSTANDARD_JOB_INT(
                             l_item_id,
                             l_group_id,
                             p_job_class,
                             p_job_name,
                             qltdate.any_to_date(p_job_start),
                             qltdate.any_to_date(p_job_end),
                             l_bill_id,
                             p_bom_revision,
                             l_routing_id,
                             p_routing_revision,
                             p_quantity,
                             p_job_mrp_net_quantity,
                             p_project_number,
                             p_task_number,
                             l_organization_id);

  IF (l_request = 0) THEN

     -- Concurrent Request not launched
     l_result := g_failed;
     l_err_msg := fnd_message.get_string('QA', 'QA_SODISP_REQ_NOT_LAUNCHED');

     WRITE_BACK( p_plan_id           =>  l_plan_id,
                 p_collection_id     =>  p_collection_id,
                 p_occurrence        =>  p_occurrence,
                 p_status            =>  l_result,
                 p_message           =>  l_err_msg);
     RETURN;

  -- Bug 2689276. Added the ELSE condition below. If the request gets launched,
  -- write back the concurrent request id.

  ELSE

     WRITE_BACK( p_plan_id           =>  l_plan_id,
                 p_collection_id     =>  p_collection_id,
                 p_occurrence        =>  p_occurrence,
                 p_status            =>  g_pending,
                 p_request_id        =>  l_request);

  END IF;


  -- If request gets launched, proceed.
  -- But first, wait for the WIP Mass Load Program request to be completed.
  -- We wait 100 minutes for the Mass Load to Complete. And we check in
  -- every 15 Minutes

  l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_request,
                                            g_check_request_time,
                                            g_total_request_time,
                                            l_phase,
                                            l_status,
                                            l_devphase,
                                            l_devstatus,
                                            l_message);

  IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
     IF (substr(l_devstatus,1,5) = 'ERROR') THEN

        l_result := g_failed;

     ELSIF (substr(l_devstatus,1,7) = 'WARNING') THEN

        l_result := g_warning;


     ELSIF (substr(l_devstatus,1,6) = 'NORMAL') THEN

        -- Bug 3019869. We had passed the source_code concatenated
        -- with the group_id. Hence fetching the wip_entity_id from
        -- wip_discrete_jobs table using the source_code. kabalakr

        l_source_code := 'QA ACTION: REWORK'||to_char(l_group_id);

        -- Bug 3641781. Pass the item_id also to the cursor sql. kabalakr.

        OPEN wip_job(l_source_code, l_item_id);
        FETCH wip_job INTO l_job_id;
        CLOSE wip_job;

        l_result := g_success;

        -- Bug 2656461. Once the Action is successful, we also need to copy
        -- the attachments to the new Job created.

        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                               X_from_entity_name => 'QA_RESULTS',
                               X_from_pk1_value   => to_char(p_occurrence),
                               X_from_pk2_value   => to_char(p_collection_id),
                               X_from_pk3_value   => to_char(l_plan_id),
                               X_to_entity_name   => 'WIP_DISCRETE_JOBS',
                               X_to_pk1_value     => to_char(l_job_id),
                               X_to_pk2_value     => to_char(l_organization_id));

     ELSE
        l_result := g_failed;

     END IF;

     -- Call for handshaking the outcome onto the Collection Plan.

     WRITE_BACK(p_plan_id        =>  l_plan_id,
                p_collection_id  =>  p_collection_id,
                p_occurrence     =>  p_occurrence,
                p_status         =>  l_result,
                p_job_id         =>  l_job_id,
                p_wjsi_group_id  =>  l_group_id,
                p_request_id     =>  l_request
                );

  END IF; -- if complete.

 END REWORK_NEW_NONSTANDARD_JOB;


 FUNCTION REWORK_NEW_NONSTANDARD_JOB_INT(
                     p_item_id              NUMBER,
                     p_group_id             NUMBER,
                     p_jclass               VARCHAR2,
                     p_job_name             VARCHAR2,
                     p_job_start            DATE,
                     p_job_end              DATE,
                     p_bill_id              NUMBER,
                     p_bill_revision        VARCHAR2,
                     p_routing_id           NUMBER,
                     p_routing_revision     VARCHAR2,
                     p_quantity             NUMBER,
                     p_job_mrp_net_quantity NUMBER,
                     p_project_number       VARCHAR2,
                     p_task_number          VARCHAR2,
                     p_organization_id      NUMBER)

 RETURN NUMBER IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_request_id       NUMBER;
 l_update_by        NUMBER :=  fnd_global.user_id;
 l_update_name      VARCHAR2(100);

 l_source_code      VARCHAR2(30);

 CURSOR update_cur IS
    SELECT user_name
    FROM   fnd_user_view
    WHERE  user_id = l_update_by;


 BEGIN

   OPEN update_cur;
   FETCH update_cur INTO l_update_name;
   CLOSE update_cur;

   -- Bug 3019869. The source_code will be concatenated with the
   -- group_id in order to retrieve the wip_entity_id when writing
   -- back to the results. kabalakr

   l_source_code := 'QA ACTION: REWORK'||to_char(p_group_id);


   -- Bug 2720431. Added p_job_mrp_net_quantity as NET_QUANTITY.

   INSERT INTO WIP_JOB_SCHEDULE_INTERFACE(
        PRIMARY_ITEM_ID,
        SOURCE_CODE,
        LOAD_TYPE,
        PROCESS_PHASE,
        PROCESS_STATUS,
        GROUP_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATED_BY_NAME,
        CREATION_DATE,
        CREATED_BY_NAME,
        CREATED_BY,
        FIRST_UNIT_START_DATE,
        LAST_UNIT_COMPLETION_DATE,
        CLASS_CODE,
        ORGANIZATION_ID,
        START_QUANTITY,
        NET_QUANTITY,
        JOB_NAME,
        PROJECT_NUMBER,
        TASK_NUMBER,
        BOM_REFERENCE_ID,
        BOM_REVISION,
        ROUTING_REFERENCE_ID,
        ROUTING_REVISION
   )
   VALUES
   (
        p_item_id,
        l_source_code,
        4,
        2,
        1,
        p_group_id,
        SYSDATE,
        l_update_by,
        l_update_name,
        SYSDATE,
        l_update_name,
        l_update_by,
        p_job_start,
        p_job_end,
        p_jclass,
        p_organization_id,
        p_quantity,
        p_job_mrp_net_quantity,
        p_job_name,
        nvl(p_project_number,NULL),
        nvl(p_task_number,NULL),
        p_bill_id,
        p_bill_revision,
        p_routing_id,
        p_routing_revision
   );

   -- Call the WIP Mass Load Program in Background.
   l_request_id := FND_REQUEST.SUBMIT_REQUEST('WIP', 'WICMLP',
                                               NULL, NULL, FALSE,
                                               TO_CHAR(p_group_id),          /* grp id*/
                                               TO_CHAR(WIP_CONSTANTS.FULL), /*validation lvl*/
                                               TO_CHAR(WIP_CONSTANTS.YES));  /* print report */

   -- Commit the insert
   COMMIT;

   RETURN l_request_id;

 END REWORK_NEW_NONSTANDARD_JOB_INT;



-------------------------------------------------------------------------------
-- WIP Scrap Transactions API
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    WIP_SCRAP_WIP_MOVE
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_job_name                  => Job Name to do the WIP Scrap Transaction
--     p_scrap_alias               => Scrap Account
--     p_from_op_seq               => From Operation Sequence Number
--     p_from_intra_step           => From Intraoperation Step
--     p_to_op_seq                 => To Operation Sequence Number
--     p_to_intra_step             => To Intraoperation Step
--     p_from_op_code              => From Operation Code
--     p_to_op_code                => To Operation Code
--     p_reason_code               => Reason Code
--     p_uom                       => Transacting UOM
--     p_quantity                  => Quantity
--     p_txn_date                  => WIP Scrap requires date in varchar2. This should be either Canonical
--                                    format ('YYYY/MM/DD') or in Real format ('DD-MON-YYYY')
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully do WIP Scrap Transactions
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully do WIP Scrap Transactions
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  We are performing all the below activities here
--
--    1. Get the different id values.
--    2. Call WIP_SCRAP_WIP_MOVE_INT() procedure for inserting into interface table
--       and spawn the WIP Move Transaction manager.
--    3. Wait for the Move Manager and Worker Program to get completed.
--    4. Get the results and perform the handshaking. Call the procedure
--       WRITE_BACK() for performing the same.
--
--  End of Comments
--
--  Bug Fixes
--
--    Bug 2689276 : Call WRITE_BACK() to handshake the concurrent request id as
--                  soon as the concurrnt request gets launched.
--
--    Bug 2697388 : Changed the parameters p_fm_op_code and p_reason_name to p_from_op_code
--                  and p_reason_code respectively. Functionality remains the same.
--                  kabalakr Tue Dec 17 22:48:31 PST 2002.
--
--
--


 PROCEDURE WIP_SCRAP_WIP_MOVE(
                    p_item               IN VARCHAR2,
                    p_job_name           IN VARCHAR2,
		    p_scrap_alias        IN VARCHAR2,
                    p_from_op_seq        IN NUMBER,
                    p_from_intra_step    IN VARCHAR2,
                    p_to_op_seq          IN NUMBER,
                    p_to_intra_step      IN VARCHAR2,
                    p_from_op_code       IN VARCHAR2,
                    p_to_op_code         IN VARCHAR2,
                    p_reason_code        IN VARCHAR2,
                    p_uom                IN VARCHAR2,
                    p_quantity           IN NUMBER,
                    p_txn_date           IN VARCHAR2,
                    p_collection_id      IN NUMBER,
                    p_occurrence         IN NUMBER,
                    p_organization_code  IN VARCHAR2,
                    p_plan_name          IN VARCHAR2,
                    p_launch_action      IN VARCHAR2,
                    p_action_fired       IN VARCHAR2) IS


   l_request          NUMBER;
   l_child_request    NUMBER;
   l_plan_id          NUMBER;
   l_organization_id  NUMBER;
   l_to_step          NUMBER;
   l_from_step        NUMBER;
   l_src_code         VARCHAR2(30);

   -- Bug 3684073. These variables are no longer required.
   -- l_launch_action    NUMBER;
   -- l_action_fired     NUMBER;

   l_reason_id        NUMBER;
   l_group_id         NUMBER;
   l_transaction_id   NUMBER;
   l_txn_id           NUMBER;
   l_dist_account_id  NUMBER;
   l_item_id          NUMBER;

   l_wait          BOOLEAN;
   l_phase         VARCHAR2(2000);
   l_status        VARCHAR2(2000);
   l_devphase      VARCHAR2(2000);
   l_devstatus     VARCHAR2(2000);
   l_message       VARCHAR2(2000);

   l_result     VARCHAR2(1800);
   l_err_msg    VARCHAR2(2000) := NULL;
   l_err_col    VARCHAR2(1000);
   l_arg        VARCHAR2(240);

   -- Bug 2697724.suramasw.
   l_txn_date   DATE;

 CURSOR txn_cur IS
    SELECT wip_transactions_s.nextval
    FROM DUAL;

 CURSOR req_cur IS
    SELECT request_id
    FROM   FND_CONC_REQ_SUMMARY_V
    WHERE  parent_request_id = l_request;

 CURSOR grp_cur IS
    SELECT group_id
    FROM   WIP_MOVE_TXN_INTERFACE
    WHERE  source_code = l_src_code;

 CURSOR acc_cur IS
    SELECT distribution_account
    FROM   mtl_generic_dispositions_kfv
    WHERE  concatenated_segments = p_scrap_alias
    AND    organization_id = l_organization_id;

 CURSOR txns_cur IS
    SELECT transaction_id
    FROM wip_move_transactions
    WHERE source_code = l_src_code;

 CURSOR reason_cur IS
    SELECT reason_id
    FROM mtl_transaction_reasons_val_v
    WHERE reason_name LIKE p_reason_code;

 CURSOR arg_cur IS
    SELECT argument_text
    FROM FND_CONC_REQ_SUMMARY_V
    WHERE request_id = l_child_request;

 BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- Launch_action is 'Yes' and relaunch_flag is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
     NULL;
  ELSE
     -- dont fire the action
     RETURN;
  END IF;

  l_organization_id  := get_organization_id(p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);

  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_item_id   := qa_flex_util.get_item_id(l_organization_id, p_item);

  -- Get transaction_id and lookup code for the Intraoperation step.

  l_to_step   := get_mfg_lookups_value(p_to_intra_step,'WIP_INTRAOPERATION_STEP');
  l_from_step := get_mfg_lookups_value(p_from_intra_step,'WIP_INTRAOPERATION_STEP');

  -- IF the To Intraoperation step is not 'SCRAP', do not execute the action.
  -- Write back INT_ERROR and RETURN.

  IF (l_to_step <> 5) THEN

    l_result := g_int_err;
    l_err_msg := fnd_message.get_string('QA', 'QA_SODISP_INVALID_OP_STEP');

    WRITE_BACK( p_plan_id           =>  l_plan_id,
                p_collection_id     =>  p_collection_id,
                p_occurrence        =>  p_occurrence,
                p_status            =>  l_result,
                p_message           =>  l_err_msg);
    RETURN;
  END IF;

  UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

  OPEN txn_cur;
  FETCH txn_cur INTO l_txn_id;
  CLOSE txn_cur;

  OPEN reason_cur;
  FETCH reason_cur INTO l_reason_id;
  CLOSE reason_cur;

  OPEN acc_cur;
  FETCH acc_cur INTO l_dist_account_id;
  CLOSE acc_cur;


  -- Added the following code to make the transaction date to have the time portion
  -- so that WIP processor picks the transaction date.If the transaction date doesn't
  -- have the time portion and the transaction happens on the job release date the
  -- WIP Move transaction fails saying 'Transaction date precedes release date for
  -- the job/schedule'.l_txn_date in the following code will be passed to the
  -- WIP_SCRAP_WIP_MOVE_INT instead of the p_txn_date.
  -- Bug 2697724.suramasw.Mon Jan 20 06:21:03 PST 2003.

  IF (qltdate.canon_to_date(p_txn_date) - trunc(sysdate)) = 0 THEN
      l_txn_date := sysdate;
  ELSE
      l_txn_date := qltdate.canon_to_date(p_txn_date);
  END IF;


  -- Call the wipscrap_int(). It spawns and returns back the concurrent request
  -- id of the WIP Move Manager Program.

  -- Bug 2697388. Changed the argument p_fm_op_code to p_from_op_code.

  l_request := WIP_SCRAP_WIP_MOVE_INT(
                              l_item_id,
                              l_txn_id,
                              p_job_name,
			      l_dist_account_id,
                              p_from_op_seq,
                              l_from_step,
                              p_to_op_seq,
                              l_to_step,
                              nvl(p_from_op_code,NULL),
                              nvl(p_to_op_code,NULL),
                              nvl(l_reason_id,0),
                              p_uom,
                              p_quantity,
                              qltdate.any_to_date(l_txn_date),
                              p_organization_code,
                              p_collection_id);

  IF (l_request = 0) THEN

     -- Concurrent Request not launched
     l_result := g_failed;
     l_err_msg := fnd_message.get_string('QA', 'QA_SODISP_REQ_NOT_LAUNCHED');

     WRITE_BACK(p_plan_id           =>  l_plan_id,
                p_collection_id     =>  p_collection_id,
                p_occurrence        =>  p_occurrence,
                p_status            =>  l_result,
                p_message           =>  l_err_msg);
     RETURN;

  -- Bug 2689276. Added the ELSE condition below. If the request gets launched,
  -- write back the concurrent request id.

  ELSE

     WRITE_BACK( p_plan_id           =>  l_plan_id,
                 p_collection_id     =>  p_collection_id,
                 p_occurrence        =>  p_occurrence,
                 p_status            =>  g_pending,
                 p_request_id        =>  l_request);

  END IF;

  -- If request gets launched, proceed.
  -- But first, wait for the WIP Move Manager Program to be completed.
  -- After that, wait for the WIP Move Worker to be completed.
  -- We wait 100 minutes each for these requests to be Completed. And we
  -- check in every 15 Minutes

  l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_request,
                                            g_check_request_time,
                                            g_total_request_time,
                                            l_phase,
                                            l_status,
                                            l_devphase,
                                            l_devstatus,
                                            l_message);

  l_src_code := 'QA WIP SCRAP:'||to_char(l_txn_id);

  OPEN grp_cur;
  FETCH grp_cur INTO l_group_id;
  CLOSE grp_cur;

  IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
    -- If the Manager gets completed, we need to find the correct
    -- worker that processes the record we have inserted.

    FOR i IN req_cur LOOP
      l_child_request := i.request_id;

      -- Get the Argument text of the concurrent request so that we can
      -- extract the group_id.

      OPEN arg_cur;
      FETCH arg_cur INTO l_arg;
      IF (to_char(l_group_id) = substr(l_arg, 1, instr(l_arg, ',') - 1)) THEN
         CLOSE arg_cur;
         EXIT;
      END IF;
      CLOSE arg_cur;

    END LOOP;

  ELSE
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_child_request,
                                            g_check_request_time,
                                            g_total_request_time,
                                            l_phase,
                                            l_status,
                                            l_devphase,
                                            l_devstatus,
                                            l_message);

  IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
     IF (substr(l_devstatus,1,7) = 'WARNING') THEN

        l_result := g_warning;
        l_transaction_id := 0;

     ELSIF (substr(l_devstatus,1,6) = 'NORMAL') THEN

        l_result := g_success;

        OPEN txns_cur;
        FETCH txns_cur INTO  l_transaction_id;
        CLOSE txns_cur;

        l_group_id := 0;

     ELSE
        -- If error, or any other cases, give FAILURE.
        l_result := g_failed;
        l_transaction_id := 0;

     END IF;

     -- Call for handshaking the outcome onto the Collection Plan.
     WRITE_BACK(p_plan_id             =>  l_plan_id,
                p_collection_id       =>  p_collection_id,
                p_occurrence          =>  p_occurrence,
                p_status              =>  l_result,
                p_wmti_group_id       =>  l_group_id,
                p_wmt_transaction_id  =>  l_transaction_id,
                p_request_id          =>  l_child_request);

  END IF; -- if complete.

 END WIP_SCRAP_WIP_MOVE;




 FUNCTION WIP_SCRAP_WIP_MOVE_INT(
                       p_item_id           NUMBER,
                       p_txn_id            NUMBER,
                       p_job_name          VARCHAR2,
                       p_dist_account_id   NUMBER,
                       p_from_op_seq       NUMBER,
                       p_from_intra_step   NUMBER,
                       p_to_op_seq         NUMBER,
                       p_to_intra_step     NUMBER,
                       p_fm_op_code        VARCHAR2,
                       p_to_op_code        VARCHAR2,
                       p_reason_id         NUMBER,
                       p_uom               VARCHAR2,
                       p_quantity          NUMBER,
                       p_txn_date          DATE,
                       p_organization_code VARCHAR2,
                       p_collection_id     VARCHAR2)

  RETURN NUMBER IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_request_id      NUMBER;
  l_update_by       NUMBER :=  fnd_global.user_id;
  l_update_name     VARCHAR2(100);

  CURSOR update_cur IS
     SELECT user_name
     FROM   fnd_user_view
     WHERE  user_id = l_update_by;

 BEGIN

   OPEN update_cur;
   FETCH update_cur INTO l_update_name;
   CLOSE update_cur;

   -- Insert into Interface table.

   -- Bug 2689305. Added NVL() to p_reason_id in the below sql.

   INSERT INTO WIP_MOVE_TXN_INTERFACE(
     PRIMARY_ITEM_ID,
     TRANSACTION_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY_NAME,
     CREATION_DATE,
     CREATED_BY_NAME,
     ORGANIZATION_CODE,
     WIP_ENTITY_NAME,
     TRANSACTION_DATE,
     SOURCE_CODE,
     SCRAP_ACCOUNT_ID,
     PROCESS_PHASE,
     PROCESS_STATUS,
     TRANSACTION_TYPE,
     FM_OPERATION_SEQ_NUM,
     FM_INTRAOPERATION_STEP_TYPE,
     TO_OPERATION_SEQ_NUM,
     TO_INTRAOPERATION_STEP_TYPE,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     FM_OPERATION_CODE,
     TO_OPERATION_CODE,
     QA_COLLECTION_ID,
     REASON_ID
     )
    VALUES(
     p_item_id,
     p_txn_id,
     sysdate,
     l_update_name,
     sysdate,
     l_update_name,
     p_organization_code,
     p_job_name,
     p_txn_date,
     'QA WIP SCRAP:'||to_char(p_txn_id),
     p_dist_account_id,
     1,
     1,
     1,
     p_from_op_seq,
     p_from_intra_step,
     p_to_op_seq,
     p_to_intra_step,
     p_quantity,
     p_uom,
     p_fm_op_code,
     p_to_op_code,
     p_collection_id,
     NVL(p_reason_id, 0));

   -- Call the WIP Move Transaction Manager Program in Background.
   l_request_id := FND_REQUEST.SUBMIT_REQUEST( 'WIP', 'WICTMS');

   -- Commit Now.
   COMMIT;

   RETURN l_request_id;

 END WIP_SCRAP_WIP_MOVE_INT;


-------------------------------------------------------------------------------
--  INV Scrap - Account Alias Transactions API
-------------------------------------------------------------------------------
--
--  Start of Comments
--
--  API name    INV_SCRAP_ACCOUNT_ALIAS
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_revision                  => Item Revision
--     p_subinventory              => Subinventory Name
--     p_locator                   => Locator Name
--     p_lot_number                => Lot Number
--     p_serial_number             => Serial Number
--     p_transaction_uom           => Transacting UOM
--     p_transaction_qty           => Transaction Quantity
--     p_transaction_date          => INV Scrap requires date in varchar2. This should be
--				      either Canonical format ('YYYY/MM/DD') or in Real
--				      format ('DD-MON-YYYY')
--     p_inv_acc_alias             => INV Scrap Account Name
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully do INV Scrap Transaction
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully do INV Scrap Transaction
--
--  Notes
--
--  We are performing all the below activities here
--
--   1. Inserts into the MTL_TRANSACTIONS_INTERFACE
--   2. If applicable, inserts into MTL_TRANSACTION_LOTS_INTERFACE
--      and MTL_SERIAL_NUMBERS_INTERFACE
--   3. Invokes the MTL_ONLINE_TRANSACTION_PUB.PROCESS_ONLINE proc to do the
--      transaction processing.
--   4. Calls WRITE_BACK proc to write the result of the transaction processor
--     against the Quality record.
--
--  End of Comments
--

 PROCEDURE INV_SCRAP_ACCOUNT_ALIAS(
				 p_item                IN VARCHAR2,
                                 p_revision            IN VARCHAR2,
                                 p_subinventory        IN VARCHAR2,
                                 p_locator             IN VARCHAR2,
                                 p_lot_number          IN VARCHAR2,
                                 p_serial_number       IN VARCHAR2,
                                 p_transaction_uom     IN VARCHAR2,
                                 p_transaction_qty     IN NUMBER,
                                 p_transaction_date    IN VARCHAR2,
                                 p_inv_acc_alias       IN VARCHAR2,
                                 p_collection_id       IN NUMBER,
                                 p_occurrence          IN NUMBER,
                                 p_organization_code   IN VARCHAR2,
                                 p_plan_name           IN VARCHAR2,
                                 p_launch_action       IN VARCHAR2,
                                 p_action_fired        IN VARCHAR2) IS


   l_header_id        NUMBER;
   l_plan_id          NUMBER;
   l_organization_id  NUMBER;
   l_transaction_date DATE;
   l_disposition_id   NUMBER;

   -- Meant for Inventory transaction processing
   -- Using process online which is similar to the trip stop/pick release functionality

   l_outcome           BOOLEAN := TRUE;
   l_error_code        VARCHAR2(240) := NULL;
   l_error_explanation VARCHAR2(240) := NULL;
   l_time_out          NUMBER := 1200;
   l_profile_time_out  NUMBER;
   l_phase             VARCHAR2(240);
   l_result            VARCHAR2(240);

   -- Bug 3684073. These variables are no longer required.
   -- l_launch_action     NUMBER;
   -- l_action_fired      NUMBER;

   l_int_txn_id        NUMBER;
   l_txn_id            NUMBER;
   l_item_id           NUMBER;
   l_locator_id        NUMBER;


   CURSOR mmt_cur (set_id NUMBER) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_set_id = set_id;

   CURSOR mti_cur (header_id NUMBER) IS
      SELECT transaction_interface_id
      FROM   mtl_transactions_interface
      WHERE  transaction_header_id = header_id;

  CURSOR disp IS
     SELECT disposition_id
     FROM   mtl_generic_dispositions_kfv
     WHERE  organization_id = l_organization_id
     AND    concatenated_segments = p_inv_acc_alias;


 BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- launch_action is 'Yes' and action_fired is 'No'

   IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
     NULL;
   ELSE
     -- dont fire the action.
     RETURN;
   END IF;

   -- Get the org_id, plan_id
   l_organization_id  := get_organization_id (p_organization_code);
   l_plan_id          := get_plan_id(p_plan_name);

   IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Update the Dispostion Status to 'Pending'.
   UPDATE_STATUS(l_plan_id, p_collection_id, p_occurrence);

   IF p_transaction_date IS NULL THEN
      l_transaction_date := sysdate;
   ELSE
      l_transaction_date := qltdate.any_to_date(p_transaction_date);
   END IF;

   -- Get the Inventory Item ID and Locator ID.
   l_item_id    := qa_flex_util.get_item_id(l_organization_id, p_item);
   l_locator_id := qa_flex_util.get_locator_id(l_organization_id, p_locator);

   -- Get the Disposition ID.
   OPEN disp;
   FETCH disp INTO l_disposition_id;
   CLOSE disp;

   -- Call the INV_SCRAP_ACCOUNT_ALIAS_INT() AT proc to Insert into interface table
   l_header_id := INV_SCRAP_ACCOUNT_ALIAS_INT(
				l_item_id,
                                p_revision,
                                p_subinventory,
                                l_locator_id,
                                p_lot_number,
                                p_serial_number,
                                p_transaction_uom,
                                p_transaction_qty,
                                l_transaction_date,
                                l_disposition_id,
                                p_collection_id,
                                p_occurrence,
                                l_organization_id);


    l_outcome := mtl_online_transaction_pub.process_online(l_header_id,
                                                           l_time_out,
                                                           l_error_code,
                                                           l_error_explanation);
    IF (l_outcome <> TRUE) THEN
      l_result := g_failed;

      OPEN  mti_cur(l_header_id);
      FETCH mti_cur INTO l_int_txn_id;
      CLOSE mti_cur;

      l_txn_id := 0;

    ELSE
      l_result := g_success;

      OPEN  mmt_cur(l_header_id);
      FETCH mmt_cur INTO l_txn_id;
      CLOSE mmt_cur;

      l_int_txn_id := 0;


   END IF;


   WRITE_BACK(p_plan_id                      => l_plan_id,
              p_collection_id                => p_collection_id,
              p_occurrence                   => p_occurrence,
              p_status                       => l_result,
              p_mti_transaction_header_id    => l_header_id,
              p_mti_transaction_interface_id => l_int_txn_id,
              p_mmt_transaction_id           => l_txn_id);


 END INV_SCRAP_ACCOUNT_ALIAS;

 FUNCTION INV_SCRAP_ACCOUNT_ALIAS_INT(
		       p_item_id           NUMBER,
                       p_revision          VARCHAR2,
                       p_subinventory      VARCHAR2,
                       p_locator_id        NUMBER,
                       p_lot_number        VARCHAR2,
                       p_serial_number     VARCHAR2,
                       p_transaction_uom   VARCHAR2,
                       p_transaction_qty   NUMBER,
                       p_transaction_date  DATE,
                       p_disposition_id    NUMBER,
                       p_collection_id     NUMBER,
                       p_occurrence        NUMBER,
                       p_organization_id   NUMBER)
 RETURN NUMBER IS

 PRAGMA AUTONOMOUS_TRANSACTION;

  l_header_id           NUMBER;
  l_interface_id        NUMBER;
  l_update_by           NUMBER := fnd_global.user_id;
  l_lot_control_code    NUMBER;
  l_serial_control_code NUMBER;
  l_transaction_qty     NUMBER := -p_transaction_qty;

  CURSOR item_cur IS
     SELECT lot_control_code,serial_number_control_code
     FROM mtl_system_items_b
     WHERE inventory_item_id = p_item_id
     AND organization_id = p_organization_id;


 BEGIN

   OPEN item_cur;
   FETCH item_cur INTO l_lot_control_code,l_serial_control_code;
   CLOSE item_cur;

  -- Insert into Interface table.
  INSERT INTO MTL_TRANSACTIONS_INTERFACE (
        TRANSACTION_HEADER_ID,
        TRANSACTION_INTERFACE_ID,
        SOURCE_CODE,
        SOURCE_HEADER_ID,
        SOURCE_LINE_ID,
        PROCESS_FLAG,
        TRANSACTION_MODE,
        LOCK_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        INVENTORY_ITEM_ID,
        REVISION,
        ORGANIZATION_ID,
        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,
        TRANSACTION_DATE,
        SUBINVENTORY_CODE,
        LOCATOR_ID,
        TRANSACTION_TYPE_ID,
        TRANSACTION_ACTION_ID,
        TRANSACTION_SOURCE_TYPE_ID,
        TRANSACTION_SOURCE_ID)
  VALUES(
        mtl_material_transactions_s.nextval,
        mtl_material_transactions_s.nextval,
        'QA ACTION: INVSCRAP',
        p_collection_id,
        p_occurrence,
        1,
        3,
        2,
        SYSDATE,
        l_update_by,
        SYSDATE,
        l_update_by,
        p_item_id,
        p_revision,
        p_organization_id,
        l_transaction_qty,
        p_transaction_uom,
        p_transaction_date,
        p_subinventory,
        p_locator_id,
        31,
        1,
        6,
        p_disposition_id)

  RETURNING TRANSACTION_HEADER_ID INTO l_header_id;

  IF l_serial_control_code IN (2,5) OR l_lot_control_code = 2 THEN

     -- The item is serial control set to predefined/at receipt.
     -- (l_serial_control_code IN (2,5)).
     -- The item is lot controlled.(l_lot_control_code = 2).

     -- One of Lot or Serial controls are existing for the item
     -- Need to insert in appropriate interface table against
     -- the transaction_header_id

     l_interface_id := l_header_id;
  END IF;

  IF l_lot_control_code = 2 THEN

    INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE (
        TRANSACTION_INTERFACE_ID,
        SERIAL_TRANSACTION_TEMP_ID,
        LOT_NUMBER,
        TRANSACTION_QUANTITY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY
     ) VALUES (
        l_interface_id,
        l_interface_id,
        p_lot_number,
        l_transaction_qty,
        SYSDATE,
        l_update_by,
        SYSDATE,
        l_update_by
     );
  END IF;

  IF  l_serial_control_code IN (2,5) THEN
    INSERT INTO MTL_SERIAL_NUMBERS_INTERFACE (
        TRANSACTION_INTERFACE_ID,
        FM_SERIAL_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY
     ) VALUES (
        l_interface_id,
        p_serial_number,
        SYSDATE,
        l_update_by,
        SYSDATE,
        l_update_by
     );
  END IF;

  COMMIT;

  RETURN l_header_id;

 END INV_SCRAP_ACCOUNT_ALIAS_INT;



-------------------------------------------------------------------------------
--  PO Return To Vendor API
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    PO_RETURN_TO_VENDOR
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_revision                  => Item Revision
--     p_subinventory              => Subinventory Name
--     p_locator                   => Locator Name
--     p_lot_number                => Lot Number
--     p_serial_number             => Serial Number
--     p_uom_code                  => Transacting UOM code
--     p_quantity                  => Transaction Quantity(Return to Vendor Quantity)
--     p_po_number                 => PO Number, against which item is return to vendor
--     p_po_line_number            => PO Line Number
--     p_po_shipment_number        => PO Shipment Number
--     p_po_receipt_number         => PO Receipt Number
--
--     p_transaction_date          => Transaction Date in varchar2. This should be either Canonical
--                                    format ('YYYY/MM/DD') or in Real format ('DD-MON-YYYY')
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully return to vendor
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully return to vendor
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
--
-- bug 9652549 CLM changes
--
 PROCEDURE PO_RETURN_TO_VENDOR(
			    p_item               IN VARCHAR2,
                            p_revision           IN VARCHAR2,
                            p_subinventory       IN VARCHAR2,
                            p_locator            IN VARCHAR2,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_uom_code           IN VARCHAR2,
                            p_quantity           IN NUMBER,
                            p_po_number          IN VARCHAR2,
                            p_po_line_number     IN VARCHAR2,
                            p_po_shipment_number IN NUMBER,
                            p_po_receipt_number  IN NUMBER,
                            p_transaction_date   IN VARCHAR2,
                            p_collection_id      IN NUMBER,
                            p_occurrence         IN NUMBER,
                            p_plan_name          IN VARCHAR2,
                            p_organization_code  IN VARCHAR2,
                            p_launch_action      IN VARCHAR2,
                            p_action_fired       IN VARCHAR2 ) IS


 BEGIN

  null;

 END PO_RETURN_TO_VENDOR;

--
-- bug 9652549 CLM changes
--
 FUNCTION PO_RETURN_TO_VENDOR_INT(
		   p_item_id                  IN NUMBER,
                   p_revision                 IN VARCHAR2,
                   p_subinventory             IN VARCHAR2,
                   p_locator_id               IN NUMBER,
                   p_lot_number               IN VARCHAR2,
                   p_serial_number            IN VARCHAR2,
                   p_uom_code                 IN VARCHAR2,
                   p_quantity                 IN NUMBER,
                   p_po_number                IN VARCHAR2,
                   p_po_line_number           IN VARCHAR2,
                   p_po_shipment_number       IN NUMBER,
                   p_po_receipt_number        IN NUMBER,
                   p_transaction_date         IN DATE,
                   p_collection_id            IN NUMBER,
                   p_occurrence               IN NUMBER,
                   p_plan_id                  IN NUMBER,
                   p_organization_id          IN NUMBER,
                   p_interface_transaction_id IN NUMBER)
 RETURN NUMBER IS

 BEGIN

   RETURN NULL;

 END PO_RETURN_TO_VENDOR_INT;



-------------------------------------------------------------------------------
-- Inventory Create Move Order API
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    INV_CREATE_MOVE_ORDER
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_revision                  => Item Revision
--     p_from_subinventory         => From Subinventory Name
--     p_from_locator              => From Locator Name
--     p_lot_number                => Lot Number
--     p_serial_number             => Serial Number
--     p_uom_code                  => Transacting UOM code
--     p_quantity                  => Quantity
--     p_to_subinventory           => From Subinventory Name
--     p_to_locator                => From Locator Name
--     p_date_required             => Moveorder Required date in varchar2. This should be either Canonical
--                                    format ('YYYY/MM/DD') or in Real format ('DD-MON-YYYY')
--
--     p_project_number            => Project Number
--     p_task_number               => Task Number
--
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully create move order
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully create move order
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--   Move order created by this actions will be of type 'Move Order Transfer'
--   approval is Preapproved. And the columns
--   mtl_txn_request_header.Request Number = mtl_txn_request_header.Header_id
--
--  End of Comments



 PROCEDURE INV_CREATE_MOVE_ORDER (
                            p_item               IN VARCHAR2,
                            p_revision           IN VARCHAR2,
                            p_from_subinventory  IN VARCHAR2,
                            p_from_locator       IN VARCHAR2,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_uom_code           IN VARCHAR2,
                            p_quantity           IN NUMBER,
                            p_to_subinventory    IN VARCHAR2,
                            p_to_locator         IN VARCHAR2,
                            p_date_required      IN VARCHAR2,
                            p_project_number     IN VARCHAR2,
                            p_task_number        IN VARCHAR2,
                            p_collection_id      IN NUMBER,
                            p_occurrence         IN NUMBER,
                            p_plan_name          IN VARCHAR2,
                            p_organization_code  IN VARCHAR2,
                            p_launch_action      IN VARCHAR2,
                            p_action_fired       IN VARCHAR2 ) IS

   -- Bug 3684073. These variables are no longer required.
   -- l_launch_action         NUMBER;
   -- l_action_fired          NUMBER;

   l_item_id               NUMBER;
   l_from_locator_id       NUMBER;
   l_to_locator_id         NUMBER;
   l_project_id            NUMBER;
   l_task_id               NUMBER;

   l_organization_id       NUMBER;
   l_plan_id               NUMBER;
   l_status                VARCHAR2(2000);
   l_request_number        VARCHAR2(30); -- holds move order request number

 BEGIN

   -- Get the value entered in confirm_action Collection element.

   -- Bug 3684073. We should not derive the lookup_code value from
   -- mfg_lookups because the value passed to this api would be the
   -- qa_plan_char_value_lookups.short_code, which is not a translated
   -- column. The mfg_lookups view would have the lookup meaning in the
   -- language used in the current session.
   --
   -- Commented the below piece of code and compared p_launch_action
   -- and p_action_fired parameters below with the new constants to resolve
   -- the value entered. kabalakr.

   -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
   -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

   -- The Action Code should get executed only if
   -- Launch_action is 'Yes' and Action_fired is 'No'

   IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
     NULL;

   ELSE
     -- dont fire the action.
     RETURN;
   END IF;

   l_organization_id := Get_organization_id (p_organization_code);
   l_plan_id         := Get_plan_id(p_plan_name);

   IF (l_plan_id = -1 OR l_organization_id = -1) THEN

     -- We may need to populate appropriate error message here before return.
     Raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Update the Disposition Status to 'Pending'.
   UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

   l_item_id         := qa_flex_util.get_item_id(l_organization_id, p_item);
   l_from_locator_id := qa_flex_util.get_locator_id(l_organization_id, p_from_locator);
   l_to_locator_id   := qa_flex_util.get_locator_id(l_organization_id, p_to_locator);

   l_project_id := qa_flex_util.get_project_id(p_project_number);
   l_task_id    := qa_flex_util.get_task_id(l_project_id,p_task_number);


   l_status := INV_CREATE_MOVE_ORDER_INT (
                            l_item_id ,
                            p_revision ,
                            p_from_subinventory ,
                            l_from_locator_id,
                            p_lot_number,
                            p_serial_number,
                            p_uom_code,
                            p_quantity,
                            p_to_subinventory,
                            l_to_locator_id,
                            qltdate.any_to_date (p_date_required),
                            l_project_id,
                            l_task_id,
                            l_organization_id,
                            l_request_number);

   -- Call for handshaking the outcome onto the Collection Plan.

   WRITE_BACK(p_plan_id                      =>  l_plan_id,
              p_collection_id                =>  p_collection_id,
              p_occurrence                   =>  p_occurrence,
              p_status                       =>  l_status,
              p_move_order_number            =>  l_request_number);

 END INV_CREATE_MOVE_ORDER;


 FUNCTION INV_CREATE_MOVE_ORDER_INT (
                            p_item_id            IN NUMBER,
                            p_revision           IN VARCHAR2,
                            p_from_subinventory  IN VARCHAR2,
                            p_from_locator_id    IN NUMBER,
                            p_lot_number         IN VARCHAR2,
                            p_serial_number      IN VARCHAR2,
                            p_uom_code           IN VARCHAR2,
                            p_quantity           IN NUMBER,
                            p_to_subinventory    IN VARCHAR2,
                            p_to_locator_id      IN NUMBER,
                            p_date_required      IN DATE,
                            p_project_id         IN NUMBER,
                            p_task_id            IN NUMBER,
                            p_organization_id    IN NUMBER,
                            x_request_number     OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS


   l_lot_control_code      NUMBER;
   l_serial_control_code   NUMBER;
   l_revision_control_code NUMBER;

   l_status                VARCHAR2(2000);
   l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(240);
   l_message               VARCHAR2(2000);

   -- Bug 2698365. GSCC warning fix. Commented the usage of
   -- FND_API.G_MISS_NUM. kabalakr.
   l_header_id             NUMBER;  -- := FND_API.G_MISS_NUM;

   l_line_num              NUMBER := 0;
   l_order_count           NUMBER := 1;
   l_commit                VARCHAR2(1) := FND_API.G_FALSE;

   l_request_number        VARCHAR2(30);

   l_trohdr_rec            INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;
   l_trohdr_val_rec        INV_MOVE_ORDER_PUB.Trohdr_Val_Rec_Type;

   l_trolin_tbl            INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
   l_trolin_val_tbl        INV_MOVE_ORDER_PUB.Trolin_Val_Tbl_Type;

   CURSOR item_att_cur IS
     SELECT revision_qty_control_code,
            lot_control_code,serial_number_control_code
     FROM   mtl_system_items_b
     WHERE  inventory_item_id = p_item_id
     AND    organization_id = p_organization_id;

  BEGIN

   -- Bug 2698365. GSCC warning fix. Moved the usage of FND_API.G_MISS_NUM
   -- to here. kabalakr.
   l_header_id := FND_API.G_MISS_NUM;

   -- populate Header WHO columns
   l_trohdr_rec.created_by                 :=   FND_GLOBAL.USER_ID;
   l_trohdr_rec.creation_date              :=   sysdate;
   l_trohdr_rec.last_updated_by            :=   FND_GLOBAL.USER_ID;
   l_trohdr_rec.last_update_date           :=   sysdate;
   l_trohdr_rec.last_update_login          :=   FND_GLOBAL.USER_ID;

   l_trohdr_rec.from_subinventory_code     :=   p_from_subinventory;
   l_trohdr_rec.to_subinventory_code       :=   p_to_subinventory;

   l_trohdr_rec.header_status              :=   INV_Globals.G_TO_STATUS_PREAPPROVED;
   l_trohdr_rec.organization_id            :=   p_organization_id;
   l_trohdr_rec.status_date                :=   sysdate;
   l_trohdr_rec.date_required              :=   p_date_required;
   l_trohdr_rec.move_order_type            :=   INV_GLOBALS.G_MOVE_ORDER_REQUISITION;
   l_trohdr_rec.transaction_type_id        :=   INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
   l_trohdr_rec.db_flag                    :=   FND_API.G_TRUE;
   l_trohdr_rec.operation                  :=   INV_GLOBALS.G_OPR_CREATE;

   l_line_num := l_line_num + 1;

   -- populate Lines WHO columns.

   l_trolin_tbl(l_order_count).created_by         := FND_GLOBAL.USER_ID;
   l_trolin_tbl(l_order_count).creation_date      := sysdate;
   l_trolin_tbl(l_order_count).last_updated_by    := FND_GLOBAL.USER_ID;
   l_trolin_tbl(l_order_count).last_update_date   := sysdate;
   l_trolin_tbl(l_order_count).last_update_login  := FND_GLOBAL.LOGIN_ID;

   l_trolin_tbl(l_order_count).date_required      := p_date_required;
   l_trolin_tbl(l_order_count).status_date        := sysdate;

   l_trolin_tbl(l_order_count).inventory_item_id  := p_item_id;


   OPEN item_att_cur;
   FETCH item_att_cur INTO
           l_revision_control_code,
           l_lot_control_code,l_serial_control_code;

   IF l_revision_control_code = 2 THEN
      -- revision control item
      l_trolin_tbl(l_order_count).revision   := p_revision;
   END IF;

   IF l_lot_control_code = 2 THEN
      -- lot control item
      l_trolin_tbl(l_order_count).lot_number   := p_lot_number;
   END IF;

   IF l_serial_control_code in( 2,5) THEN
      -- serial control item
      l_trolin_tbl(l_order_count).serial_number_start := p_serial_number;
      l_trolin_tbl(l_order_count).serial_number_end   := p_serial_number;
   END IF;

   CLOSE item_att_cur;

   l_trolin_tbl(l_order_count).quantity           := p_quantity;
   l_trolin_tbl(l_order_count).uom_code           := p_uom_code;

   l_trolin_tbl(l_order_count).from_subinventory_code := p_from_subinventory;
   l_trolin_tbl(l_order_count).from_locator_id        := p_from_locator_id;
   l_trolin_tbl(l_order_count).to_subinventory_code   := p_to_subinventory;
   l_trolin_tbl(l_order_count).to_locator_id          := p_to_locator_id;

   l_trolin_tbl(l_order_count).organization_id    := p_organization_id;
   l_trolin_tbl(l_order_count).project_id         := p_project_id;
   l_trolin_tbl(l_order_count).task_id            := p_task_id;


   l_trolin_tbl(l_order_count).header_id          := l_trohdr_rec.header_id;
   l_trolin_tbl(l_order_count).line_id            := FND_API.G_MISS_NUM;

   l_trolin_tbl(l_order_count).line_number        := l_line_num;
   l_trolin_tbl(l_order_count).line_status        := INV_GLOBALS.G_TO_STATUS_PREAPPROVED;

   l_trolin_Tbl(l_order_count).transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;

   l_trolin_tbl(l_order_count).db_flag       := FND_API.G_TRUE;
   l_trolin_tbl(l_order_count).operation     := INV_GLOBALS.G_OPR_CREATE;


   Inv_Move_Order_Pub.Process_Move_order(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => FND_API.G_FALSE,
                   p_return_values      => FND_API.G_TRUE,
                   p_commit             => FND_API.G_FALSE,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data,
                   p_trohdr_rec         => l_trohdr_rec,
                   p_trohdr_val_rec     => l_trohdr_val_rec,
                   p_trolin_tbl         => l_trolin_tbl,
                   p_trolin_val_tbl     => l_trolin_val_tbl,
                   x_trohdr_rec         => l_trohdr_rec,
                   x_trohdr_val_rec     => l_trohdr_val_rec,
                   x_trolin_tbl         => l_trolin_tbl,
                   x_trolin_val_tbl     => l_trolin_val_tbl
                  );


   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        l_status := g_failed;
        x_request_number := NULL;

   ELSE
        -- on success commit the txn.
        COMMIT;

        l_status := g_success;
        x_request_number := l_trohdr_rec.request_number;
   END IF;

   RETURN l_status;

 END INV_CREATE_MOVE_ORDER_INT;


-------------------------------------------------------------------------------
--  WIP Component Return to Inventory
-------------------------------------------------------------------------------
--
--  Start of Comments
--
--  API name    WIP_COMP_RETURN
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_job_name                  => Job Name to do the WIP Component Issue Transaction
--     p_revision                  => Item Revision
--     p_subinventory              => Subinventory Name
--     p_locator                   => Locator Name
--     p_lot_number                => Lot Number
--     p_serial_number             => Serial Number
--     p_transaction_uom           => Transacting UOM
--     p_transaction_qty           => Transaction Quantity
--     p_transaction_date          => WIP Component Issue requires date in varchar2. This
--                                    should be either Canonical format ('YYYY/MM/DD') or
--                                    in Real format ('DD-MON-YYYY')
--     p_op_seq_num                => Operation Sequence Number
--     p_reason_code               => Reason Code
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully perform
--                                    WIP Component Issue Transaction
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully perform
--                                    WIP Component Issue Transaction
--
--  Notes
--
--  We are performing all the below activities here
--
--   1. Get the collection element values. Derive the other values.
--   2. Call WIP_MATERIAL_TXN_INT () function for inserting into interface table.
--   3. Call mtl_online_transaction_pub.process_online () procedure.
--   4. Call the WRITE_BACK () procedure for handshaking.
--
--
--  End of Comments
--

 PROCEDURE WIP_COMP_RETURN(p_job_name            IN VARCHAR2,
                           p_item                IN VARCHAR2,
                           p_revision            IN VARCHAR2,
                           p_subinventory        IN VARCHAR2,
                           p_locator             IN VARCHAR2,
                           p_lot_number          IN VARCHAR2,
                           p_serial_number       IN VARCHAR2,
                           p_transaction_uom     IN VARCHAR2,
                           p_transaction_qty     IN NUMBER,
                           p_transaction_date    IN VARCHAR2,
                           p_op_seq_num          IN NUMBER,
                           p_reason_code         IN VARCHAR2,
                           p_collection_id       IN NUMBER,
                           p_occurrence          IN NUMBER,
                           p_organization_code   IN VARCHAR2,
                           p_plan_name           IN VARCHAR2,
                           p_launch_action       IN VARCHAR2,
                           p_action_fired        IN VARCHAR2) IS


  l_plan_id            NUMBER;
  l_organization_id    NUMBER;

  -- Bug 3684073. These variables are no longer required.
  -- l_launch_action      NUMBER;
  -- l_action_fired       NUMBER;

  l_outcome            BOOLEAN := TRUE;
  l_header_id          NUMBER;
  l_result             VARCHAR2(240);
  l_error_code         VARCHAR2(240) := NULL;
  l_error_explanation  VARCHAR2(240) := NULL;
  l_time_out           NUMBER := 1200;
  l_int_txn_id         NUMBER;
  l_txn_id             NUMBER;
  l_transaction_date   DATE;
  l_item_id            NUMBER;
  l_locator_id         NUMBER;
  l_reason_id          NUMBER;

  CURSOR mmt_cur (set_id NUMBER) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_set_id = set_id;

  CURSOR mti_cur (header_id NUMBER) IS
      SELECT transaction_interface_id
      FROM   mtl_transactions_interface
      WHERE  transaction_header_id = header_id;

  CURSOR reason_cur IS
      SELECT reason_id
      FROM mtl_transaction_reasons_val_v
      WHERE reason_name LIKE p_reason_code;


  BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- launch_action is 'Yes' and action_fired is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
    NULL;
  ELSE
    -- dont fire the action.
    RETURN;
  END IF;

  -- Get the plan_id and org_id now.

  l_organization_id  := get_organization_id (p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);

  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_transaction_date IS NULL THEN
     l_transaction_date := sysdate;
  ELSE
     l_transaction_date := qltdate.any_to_date(p_transaction_date);
  END IF;

  -- Update the Disposition Status to 'Pending'.
  UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

  -- Get the Inventory Item ID and Locator ID and Reason ID.
  l_item_id    := qa_flex_util.get_item_id(l_organization_id, p_item);
  l_locator_id := qa_flex_util.get_locator_id(l_organization_id, p_locator);

  OPEN reason_cur;
  FETCH reason_cur INTO l_reason_id;
  CLOSE reason_cur;


  l_header_id := WIP_MATERIAL_TXN_INT(
                                p_job_name,
                                l_item_id,
                                p_revision,
                                p_subinventory,
                                l_locator_id,
                                p_lot_number,
                                p_serial_number,
                                p_transaction_uom,
                                p_transaction_qty,
                                l_transaction_date,
                                p_op_seq_num,
                                l_reason_id,
                                'QA ACTION:WIP COMP RETURN',
                                43,
                                27,
                                p_collection_id,
                                p_occurrence,
                                l_organization_id);

  l_outcome := MTL_ONLINE_TRANSACTION_PUB.PROCESS_ONLINE(l_header_id,
                                                         l_time_out,
                                                         l_error_code,
                                                         l_error_explanation);


  IF (l_outcome <> TRUE) THEN
      l_result := g_failed;

      OPEN  mti_cur(l_header_id);
      FETCH mti_cur INTO l_int_txn_id;
      CLOSE mti_cur;

      l_txn_id := 0;


  ELSE
      l_result := g_success;

      OPEN  mmt_cur(l_header_id);
      FETCH mmt_cur INTO l_txn_id;
      CLOSE mmt_cur;

      l_int_txn_id := 0;


  END IF;


   -- call WRITE_BACK procedure.

   WRITE_BACK(p_plan_id                      => l_plan_id,
              p_collection_id                => p_collection_id,
              p_occurrence                   => p_occurrence,
              p_status                       => l_result,
              p_mti_transaction_header_id    => l_header_id,
              p_mti_transaction_interface_id => l_int_txn_id,
              p_mmt_transaction_id           => l_txn_id);

 END WIP_COMP_RETURN;


-------------------------------------------------------------------------------
--  WIP Component Issue
-------------------------------------------------------------------------------
--
--  Start of Comments
--
--  API name    WIP_COMP_ISSUE
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_job_name                  => Job Name
--     p_revision                  => Item Revision
--     p_subinventory              => Subinventory Name
--     p_locator                   => Locator Name
--     p_lot_number                => Lot Number
--     p_serial_number             => Serial Number
--     p_transaction_uom           => Transacting UOM
--     p_transaction_qty           => Transaction Quantity
--     p_transaction_date          => WIP Component Issue requires date in varchar2. This
--                                    should be either Canonical format ('YYYY/MM/DD') or
--                                    in Real format ('DD-MON-YYYY')
--     p_op_seq_num                => Operation Sequence Number
--     p_reason_code               => Reason Code
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully perform
--                                    WIP Component Issue Transaction
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully perform
--                                    WIP Component Issue Transaction
--
--  Notes
--
--  We are performing all the below activities here
--
--   1. Get the collection element values. Derive the other values.
--   2. Call WIP_MATERIAL_TXN_INT () function for inserting into interface table.
--   3. Call mtl_online_transaction_pub.process_online () procedure.
--   4. Call the WRITE_BACK () procedure for handshaking.
--
--
--  End of Comments
--

 PROCEDURE WIP_COMP_ISSUE (p_job_name                   IN VARCHAR2,
                           p_item                       IN VARCHAR2,
                           p_revision                   IN VARCHAR2,
                           p_subinventory               IN VARCHAR2,
                           p_locator                    IN VARCHAR2,
                           p_lot_number                 IN VARCHAR2,
                           p_serial_number              IN VARCHAR2,
                           p_transaction_uom            IN VARCHAR2,
                           p_transaction_qty            IN NUMBER,
                           p_transaction_date           IN VARCHAR2,
                           p_op_seq_num                 IN NUMBER,
                           p_reason_code                IN VARCHAR2,
                           p_collection_id              IN NUMBER,
                           p_occurrence                 IN NUMBER,
                           p_organization_code          IN VARCHAR2,
                           p_plan_name                  IN VARCHAR2,
                           p_launch_action              IN VARCHAR2,
                           p_action_fired               IN VARCHAR2) IS


  l_plan_id            NUMBER;
  l_organization_id    NUMBER;

  -- Bug 3684073. These variables are no longer required.
  -- l_launch_action      NUMBER;
  -- l_action_fired       NUMBER;

  l_outcome            BOOLEAN := TRUE;
  l_header_id          NUMBER;
  l_result             VARCHAR2(240);
  l_error_code         VARCHAR2(240) := NULL;
  l_error_explanation  VARCHAR2(240) := NULL;
  l_time_out           NUMBER := 1200;
  l_int_txn_id         NUMBER;
  l_txn_id             NUMBER;
  l_transaction_date   DATE;
  l_item_id            NUMBER;
  l_locator_id         NUMBER;
  l_reason_id          NUMBER;


  CURSOR mmt_cur (set_id NUMBER) IS
      SELECT transaction_id
      FROM   mtl_material_transactions
      WHERE  transaction_set_id = set_id;

  CURSOR mti_cur (header_id NUMBER) IS
      SELECT transaction_interface_id
      FROM   mtl_transactions_interface
      WHERE  transaction_header_id = header_id;

  CURSOR reason_cur IS
      SELECT reason_id
      FROM mtl_transaction_reasons_val_v
      WHERE reason_name LIKE p_reason_code;

  BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');


  -- The Action Code should get executed only if
  -- launch_action is 'Yes' and action_fired is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
    NULL;
  ELSE
    -- dont fire the action.
    RETURN;
  END IF;

  -- Get the plan_id and org_id now.

  l_organization_id  := get_organization_id (p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);

  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_transaction_date IS NULL THEN
     l_transaction_date := sysdate;
  ELSE
     l_transaction_date := qltdate.any_to_date(p_transaction_date);
  END IF;

  -- Update the Disposition Status to 'Pending'.
  UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

  -- Get the Inventory Item ID and Locator ID and Reason ID.
  l_item_id    := qa_flex_util.get_item_id(l_organization_id, p_item);
  l_locator_id := qa_flex_util.get_locator_id(l_organization_id, p_locator);

  OPEN reason_cur;
  FETCH reason_cur INTO l_reason_id;
  CLOSE reason_cur;


  l_header_id := WIP_MATERIAL_TXN_INT(
                                p_job_name,
                                l_item_id,
                                p_revision,
                                p_subinventory,
                                l_locator_id,
                                p_lot_number,
                                p_serial_number,
                                p_transaction_uom,
                                -p_transaction_qty,
                                l_transaction_date,
                                p_op_seq_num,
                                l_reason_id,
                                'QA ACTION:WIP COMP ISSUE',
                                35,
                                1,
                                p_collection_id,
                                p_occurrence,
                                l_organization_id);


  l_outcome := MTL_ONLINE_TRANSACTION_PUB.PROCESS_ONLINE(l_header_id,
                                                         l_time_out,
                                                         l_error_code,
                                                         l_error_explanation);


  IF (l_outcome <> TRUE) THEN
      l_result := g_failed;

      OPEN  mti_cur(l_header_id);
      FETCH mti_cur INTO l_int_txn_id;
      CLOSE mti_cur;

      l_txn_id := 0;


  ELSE
      l_result := g_success;

      OPEN  mmt_cur(l_header_id);
      FETCH mmt_cur INTO l_txn_id;
      CLOSE mmt_cur;

      l_int_txn_id := 0;


   END IF;

   -- call WRITE_BACK procedure.


   WRITE_BACK(p_plan_id                      => l_plan_id,
              p_collection_id                => p_collection_id,
              p_occurrence                   => p_occurrence,
              p_status                       => l_result,
              p_mti_transaction_header_id    => l_header_id,
              p_mti_transaction_interface_id => l_int_txn_id,
              p_mmt_transaction_id           => l_txn_id);


 END WIP_COMP_ISSUE;



 FUNCTION WIP_MATERIAL_TXN_INT(
                                p_job_name          VARCHAR2,
                                p_item_id           NUMBER,
                                p_revision          VARCHAR2,
                                p_subinventory      VARCHAR2,
                                p_locator_id        NUMBER,
                                p_lot_number        VARCHAR2,
                                p_serial_number     VARCHAR2,
                                p_transaction_uom   VARCHAR2,
                                p_transaction_qty   NUMBER,
                                p_transaction_date  DATE,
                                p_op_seq_num        NUMBER,
                                p_reason_id         NUMBER,
                                p_source_code       VARCHAR2,
                                p_txn_type_id       NUMBER,
                                p_txn_action_id     NUMBER,
                                p_collection_id     NUMBER,
                                p_occurrence        NUMBER,
                                p_organization_id   NUMBER)
  RETURN NUMBER IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_header_id           NUMBER;
  l_entity_id           NUMBER;
  l_entity_type         VARCHAR2(30);
  l_interface_id        NUMBER;
  l_lot_control_code    NUMBER;
  l_serial_control_code NUMBER;
  l_update_by           NUMBER :=  fnd_global.user_id;

  CURSOR wip_cur IS
     SELECT wip_entity_id, entity_type
     FROM wip_entities
     WHERE wip_entity_name = p_job_name
     AND organization_id = p_organization_id;

  CURSOR item_cur IS
     SELECT lot_control_code,serial_number_control_code
     FROM mtl_system_items_b
     WHERE inventory_item_id = p_item_id
     AND organization_id = p_organization_id;


  BEGIN

    OPEN wip_cur;
    FETCH wip_cur INTO l_entity_id,l_entity_type;
    CLOSE wip_cur ;


    OPEN item_cur;
    FETCH item_cur INTO l_lot_control_code,l_serial_control_code;
    CLOSE item_cur;

    INSERT INTO MTL_TRANSACTIONS_INTERFACE (
                 TRANSACTION_HEADER_ID,
                 TRANSACTION_INTERFACE_ID,
                 SOURCE_CODE,
                 SOURCE_HEADER_ID,
                 SOURCE_LINE_ID,
                 PROCESS_FLAG,
                 TRANSACTION_MODE,
                 LOCK_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 INVENTORY_ITEM_ID,
                 REVISION,
                 ORGANIZATION_ID,
                 TRANSACTION_QUANTITY,
                 TRANSACTION_UOM,
                 TRANSACTION_DATE,
                 SUBINVENTORY_CODE,
                 LOCATOR_ID,
                 TRANSACTION_TYPE_ID,
                 TRANSACTION_ACTION_ID,
                 TRANSACTION_SOURCE_TYPE_ID,
                 TRANSACTION_SOURCE_ID,
                 WIP_ENTITY_TYPE,
                 OPERATION_SEQ_NUM,
                 REASON_ID)
    VALUES (
                 mtl_material_transactions_s.nextval,
                 mtl_material_transactions_s.nextval,
                 p_source_code,
                 p_collection_id,
                 p_occurrence,
                 1,
                 3,
                 2,
                 SYSDATE,
                 l_update_by,
                 SYSDATE,
                 l_update_by,
                 p_item_id,
                 p_revision,
                 p_organization_id,
                 p_transaction_qty,
                 p_transaction_uom,
                 p_transaction_date,
                 p_subinventory,
                 p_locator_id,
                 p_txn_type_id,
                 p_txn_action_id,
                 5,
                 l_entity_id,
                 l_entity_type,
                 p_op_seq_num,
                 p_reason_id)

   RETURNING TRANSACTION_HEADER_ID INTO l_header_id;


   IF l_serial_control_code IN (2,5) OR l_lot_control_code = 2 THEN

      -- The item is serial control set to predefined/at receipt.
      -- (l_serial_control_code IN (2,5)).
      -- The item is lot controlled.(l_lot_control_code = 2).

      -- One of Lot or Serial controls are existing for the item
      -- Need to insert in appropriate interface table against
      -- the transaction_header_id

      l_interface_id := l_header_id;
   END IF;

   IF l_lot_control_code = 2 THEN

     INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE (
         TRANSACTION_INTERFACE_ID,
         SERIAL_TRANSACTION_TEMP_ID,
         LOT_NUMBER,
         TRANSACTION_QUANTITY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY)
     VALUES (
         l_interface_id,
         l_interface_id,
         p_lot_number,
         p_transaction_qty,
         SYSDATE,
         l_update_by,
         SYSDATE,
         l_update_by);

   END IF;



   IF  l_serial_control_code IN (2,5) THEN


     INSERT INTO MTL_SERIAL_NUMBERS_INTERFACE (
         TRANSACTION_INTERFACE_ID,
         FM_SERIAL_NUMBER,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY)
     VALUES (
         l_interface_id,
         p_serial_number,
         SYSDATE,
         l_update_by,
         SYSDATE,
         l_update_by);

   END IF;

   -- Commit the insert.
   COMMIT;

   RETURN l_header_id;

 END WIP_MATERIAL_TXN_INT;

-------------------------------------------------------------------------------
-- WIP Move Transactions API
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    WIP_MOVE_TXN
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_item                      => Item Name
--     p_job_name                  => Job Name to do the WIP Scrap Transaction
--     p_from_op_seq               => From Operation Sequence Number
--     p_from_intra_step           => From Intraoperation Step
--     p_to_op_seq                 => To Operation Sequence Number
--     p_to_intra_step             => To Intraoperation Step
--     p_fm_op_code                => Operation Code
--     p_to_op_code                => To Operation Code
--     p_reason_name               => Reason Code
--     p_uom                       => Transacting UOM
--     p_quantity                  => Quantity
--     p_txn_date                  => WIP Move requires date in varchar2. This should be either Canonical
--                                    format ('YYYY/MM/DD') or in Real format ('DD-MON-YYYY')
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully do WIP Scrap Transactions
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully do WIP Scrap Transactions
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  We are performing all the below activities here
--
--    1. Get the different id values.
--    2. Call WIP_SCRAP_WIP_MOVE_INT() procedure for inserting into interface table
--       and spawn the WIP Move Transaction manager.
--    3. Wait for the Move Manager and Worker Program to get completed.
--    4. Get the results and perform the handshaking. Call the procedure
--       WRITE_BACK() for performing the same.
--
--  End of Comments
--
--
--  Bug Fixes
--
--    Bug 2689276 : Call WRITE_BACK() to handshake the concurrent request id as
--                  soon as the concurrnt request gets launched.
--
--


 PROCEDURE WIP_MOVE_TXN(
                    p_item               IN VARCHAR2,
                    p_job_name           IN VARCHAR2,
                    p_from_op_seq        IN NUMBER,
                    p_from_intra_step    IN VARCHAR2,
                    p_to_op_seq          IN NUMBER,
                    p_to_intra_step      IN VARCHAR2,
                    p_fm_op_code         IN VARCHAR2,
                    p_to_op_code         IN VARCHAR2,
                    p_reason_name        IN VARCHAR2,
                    p_uom                IN VARCHAR2,
                    p_quantity           IN NUMBER,
                    p_txn_date           IN VARCHAR2,
                    p_collection_id      IN NUMBER,
                    p_occurrence         IN NUMBER,
                    p_organization_code  IN VARCHAR2,
                    p_plan_name          IN VARCHAR2,
                    p_launch_action      IN VARCHAR2,
                    p_action_fired       IN VARCHAR2) IS


   l_request          NUMBER;
   l_child_request    NUMBER;
   l_plan_id          NUMBER;
   l_organization_id  NUMBER;
   l_to_step          NUMBER;
   l_from_step        NUMBER;
   l_src_code         VARCHAR2(30);

   -- Bug 3684073. These variables are no longer required.
   -- l_launch_action    NUMBER;
   -- l_action_fired     NUMBER;

   l_reason_id        NUMBER;
   l_group_id         NUMBER;
   l_transaction_id   NUMBER;
   l_txn_id           NUMBER;
   l_item_id          NUMBER;

   l_wait          BOOLEAN;
   l_phase         VARCHAR2(2000);
   l_status        VARCHAR2(2000);
   l_devphase      VARCHAR2(2000);
   l_devstatus     VARCHAR2(2000);
   l_message       VARCHAR2(2000);

   l_result     VARCHAR2(1800);
   l_err_msg    VARCHAR2(2000) := NULL;
   l_err_col    VARCHAR2(1000);
   l_arg        VARCHAR2(240);

   -- Bug 7395743 FP for bug 7394787.pdube.
   l_txn_date   DATE;

 CURSOR txn_cur IS
    SELECT wip_transactions_s.nextval
    FROM DUAL;

 CURSOR req_cur IS
    SELECT request_id
    FROM   FND_CONC_REQ_SUMMARY_V
    WHERE  parent_request_id = l_request;

 CURSOR grp_cur IS
    SELECT group_id
    FROM   WIP_MOVE_TXN_INTERFACE
    WHERE  source_code = l_src_code;


 CURSOR txns_cur IS
    SELECT transaction_id
    FROM wip_move_transactions
    WHERE source_code = l_src_code;

 CURSOR reason_cur IS
    SELECT reason_id
    FROM mtl_transaction_reasons_val_v
    WHERE reason_name LIKE p_reason_name;

 CURSOR arg_cur IS
    SELECT argument_text
    FROM FND_CONC_REQ_SUMMARY_V
    WHERE request_id = l_child_request;

 BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- Launch_action is 'Yes' and relaunch_flag is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
     NULL;
  ELSE
     -- dont fire the action
     RETURN;
  END IF;

  l_organization_id  := get_organization_id(p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);

  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_item_id   := qa_flex_util.get_item_id(l_organization_id, p_item);

  -- Get transaction_id and lookup code for the Intraoperation step.

  l_to_step   := get_mfg_lookups_value(p_to_intra_step,'WIP_INTRAOPERATION_STEP');
  l_from_step := get_mfg_lookups_value(p_from_intra_step,'WIP_INTRAOPERATION_STEP');

  UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

  OPEN txn_cur;
  FETCH txn_cur INTO l_txn_id;
  CLOSE txn_cur;

  OPEN reason_cur;
  FETCH reason_cur INTO l_reason_id;
  CLOSE reason_cur;

  --WIP move is similar to scrap, so call the same WIP_SCRAP_WIP_MOVE_INT
  -- Call the wipscrap_int(). It spawns and returns back the concurrent request
  -- id of the WIP Move Manager Program.

  -- Bug 7395743 FP for bug 7394787.pdube Sun Dec 20 22:30:33 PST 2009
  -- The time part of the transaction date was truncating,
  -- making this code fix to handle it.
  IF (qltdate.canon_to_date(p_txn_date) - trunc(sysdate)) = 0 THEN
      l_txn_date := sysdate;
  ELSE
      l_txn_date := qltdate.canon_to_date(p_txn_date);
  END IF;

  l_request := WIP_SCRAP_WIP_MOVE_INT(
                              l_item_id,
                              l_txn_id,
                              p_job_name,
			                  null, --no scrap account
                              p_from_op_seq,
                              l_from_step,
                              p_to_op_seq,
                              l_to_step,
                              nvl(p_fm_op_code,NULL),
                              nvl(p_to_op_code,NULL),
                              nvl(l_reason_id,0),
                              p_uom,
                              p_quantity,
                              qltdate.any_to_date(l_txn_date), -- Bug 7395743
                              p_organization_code,
                              p_collection_id);

  IF (l_request = 0) THEN

     -- Concurrent Request not launched
     l_result := g_failed;
     l_err_msg := fnd_message.get_string('QA', 'QA_SODISP_REQ_NOT_LAUNCHED');

     WRITE_BACK(p_plan_id           =>  l_plan_id,
                p_collection_id     =>  p_collection_id,
                p_occurrence        =>  p_occurrence,
                p_status            =>  l_result,
                p_message           =>  l_err_msg);
     RETURN;

  -- Bug 2689276. Added the ELSE condition below. If the request gets launched,
  -- write back the concurrent request id.

  ELSE

     WRITE_BACK( p_plan_id           =>  l_plan_id,
                 p_collection_id     =>  p_collection_id,
                 p_occurrence        =>  p_occurrence,
                 p_status            =>  g_pending,
                 p_request_id        =>  l_request);

  END IF;

  -- If request gets launched, proceed.
  -- But first, wait for the WIP Move Manager Program to be completed.
  -- After that, wait for the WIP Move Worker to be completed.
  -- We wait 100 minutes each for these requests to be Completed. And we
  -- check in every 15 Minutes

  l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_request,
                                            g_check_request_time,
                                            g_total_request_time,
                                            l_phase,
                                            l_status,
                                            l_devphase,
                                            l_devstatus,
                                            l_message);

  l_src_code := 'QA WIP SCRAP:'||to_char(l_txn_id);
                    --This QA WIP SCRAP is just a varchar that we use
                    --Same Varchar is used for WIP move and WIP Scrap
                    --This will not cause any problem

  OPEN grp_cur;
  FETCH grp_cur INTO l_group_id;
  CLOSE grp_cur;

  IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
    -- If the Manager gets completed, we need to find the correct
    -- worker that processes the record we have inserted.

    FOR i IN req_cur LOOP
      l_child_request := i.request_id;

      -- Get the Argument text of the concurrent request so that we can
      -- extract the group_id.

      OPEN arg_cur;
      FETCH arg_cur INTO l_arg;
      IF (to_char(l_group_id) = substr(l_arg, 1, instr(l_arg, ',') - 1)) THEN
         CLOSE arg_cur;
         EXIT;
      END IF;
      CLOSE arg_cur;

    END LOOP;

  ELSE
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_child_request,
                                            g_check_request_time,
                                            g_total_request_time,
                                            l_phase,
                                            l_status,
                                            l_devphase,
                                            l_devstatus,
                                            l_message);

  IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
     IF (substr(l_devstatus,1,7) = 'WARNING') THEN

        l_result := g_warning;
        l_transaction_id := 0;

     ELSIF (substr(l_devstatus,1,6) = 'NORMAL') THEN

        l_result := g_success;

        OPEN txns_cur;
        FETCH txns_cur INTO  l_transaction_id;
        CLOSE txns_cur;

        l_group_id := 0;

     ELSE
        -- If error, or any other cases, give FAILURE.
        l_result := g_failed;
        l_transaction_id := 0;

     END IF;

     -- Call for handshaking the outcome onto the Collection Plan.
     WRITE_BACK(p_plan_id             =>  l_plan_id,
                p_collection_id       =>  p_collection_id,
                p_occurrence          =>  p_occurrence,
                p_status              =>  l_result,
                p_wmti_group_id       =>  l_group_id,
                p_wmt_transaction_id  =>  l_transaction_id,
                p_request_id          =>  l_child_request);

  END IF; -- if complete.

 END WIP_MOVE_TXN;


-------------------------------------------------------------------------------
-- Add New Rework Operation API
-------------------------------------------------------------------------------
--  Start of Comments
--  API name    REWORK_ADD_OPERATION
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--     p_job_name                  => Name of the Rework Job to be created
--     p_op_seq_num                => Rework Operation Sequence Number
--     p_operation_code            => Rework Operation Code
--     p_department_code           => Department Code for NON Standard Operation.
--     p_res_seq_num               => Resource Sequence Number to add resources to NON
--                                    Standard Operations.
--     p_resource_code             => Resource Code to add resources to NON Standard Operations.
--     p_assigned_units            => Assigned units for the resource.
--     p_usage_rate                => Usage rate of resources.
--     p_start_date                => First Unit Start date and First unit completion date.
--     p_end_date                  => Last Unit Start date and Last unit completion date.
--     p_collection_id             => Collection ID
--     p_occurrence                => Occurrence
--     p_plan_name                 => Collection Plan Name
--     p_organization_code         => Organization Code, from which transaction happens
--     p_launch_action             => This takes two values(Yes/No)
--                                    Pass a value of 'Yes' to successfully create Rework Job
--     p_action_fired              => This takes two values(Yes/No)
--                                    Pass a value of 'No' to successfully create Rework Job
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  We are performing all the below activities here
--
--    1. Get the different id values.
--    2. Call REWORK_OP_ADD_OP_INT() procedure for inserting into interface table
--       and spawn the WIP Mass Load Program (WICMLX) for adding Standard and NON
--       Standard operations.
--    3. Wait for the Mass Load Program to get completed.
--    4. Get the results and perform the handshaking. Call the procedure
--       WRITE_BACK() for performing the same.
--    5. Call REWORK_OP_ADD_RES_INT() procedure for inserting into interface table
--       and spawn the WIP Mass Load Program (WICMLX) for automatic adding of resources
--       for Standard Operations and adding specified resources for specified NON
--       Standard operations.
--    6. Wait for the Mass Load Program to get completed.
--    7. Get the results and perform the handshaking. Call the procedure
--       WRITE_BACK() for performing the same.
--
--  End of Comments
--
--  Bug Fixes
--
--    Bug 2689276 : Call WRITE_BACK() to handshake the concurrent request id as
--                  soon as the concurrnt request gets launched.
--
--    Bug 2656461 : Code added to support copying of attachments to the
--                  WIP_DISCRETE_OPERATIONS entity, once the Action is successful.
--
--    Bug 2714880 : Derive the STATUS_TYPE of the Job from WIP_DISCRETE_JOBS. This
--                  value is needed when importing Operations and resources in the
--                  internal functions REWORK_OP_ADD_OP_INT() and
--                  REWORK_OP_ADD_RES_INT().
--
--

 PROCEDURE REWORK_ADD_OPERATION(
                  p_job_name           IN VARCHAR2,
                  p_op_seq_num         IN NUMBER,
                  p_operation_code     IN VARCHAR2,
                  p_department_code    IN VARCHAR2,
                  p_res_seq_num        IN NUMBER,
                  p_resource_code      IN VARCHAR2,
                  p_assigned_units     IN NUMBER,
                  p_usage_rate         IN NUMBER,
                  p_start_date         IN VARCHAR2,
                  p_end_date           IN VARCHAR2,
                  p_collection_id      IN NUMBER,
                  p_occurrence         IN NUMBER,
                  p_organization_code  IN VARCHAR2,
                  p_plan_name          IN VARCHAR2,
                  p_launch_action      IN VARCHAR2,
                  p_action_fired       IN VARCHAR2) IS


  l_request          NUMBER;
  l_group_id         NUMBER;
  l_plan_id          NUMBER;
  l_organization_id  NUMBER;

  -- Bug 3684073. These variables are no longer required.
  -- l_launch_action    NUMBER;
  -- l_action_fired     NUMBER;

  l_err_msg          VARCHAR2(2000)  := NULL;

  l_wait           BOOLEAN;
  l_phase          VARCHAR2(2000);
  l_status         VARCHAR2(2000);
  l_devphase       VARCHAR2(2000);
  l_devstatus      VARCHAR2(2000);
  l_message        VARCHAR2(2000);
  l_result         VARCHAR2(1800);

  l_dup_op_seq     NUMBER;
  l_dup_res_seq    NUMBER;

  l_wip_entity_id  NUMBER;
  l_operation_id   NUMBER;
  l_department_id  NUMBER;
  l_resource_id    NUMBER;
  l_op_type        NUMBER := 2;

  -- Bug 2714880.
  l_status_type    NUMBER;


  CURSOR group_cur IS
     SELECT WIP_JOB_SCHEDULE_INTERFACE_S.nextval
       FROM DUAL;

  CURSOR job_cur IS
     SELECT wip_entity_id
       FROM wip_entities
      WHERE wip_entity_name = p_job_name
        AND organization_id = l_organization_id;

  CURSOR op_cur IS
     SELECT bsoav.standard_operation_id
       FROM bom_standard_operations_all_v bsoav, bom_departments_val_v bdvv
      WHERE bsoav.organization_id = l_organization_id
        AND bsoav.department_id = bdvv.department_id
        AND NVL (bsoav.operation_type, 1) = 1
        AND bsoav.operation_code = p_operation_code;

  CURSOR op_seq_cur IS
     SELECT operation_seq_num
       FROM wip_operations
      WHERE wip_entity_id = l_wip_entity_id
        AND operation_seq_num = p_op_seq_num;

  CURSOR dept_cur IS
     SELECT department_id
       FROM bom_departments
      WHERE organization_id = l_organization_id
        AND nvl(disable_date, sysdate + 2) > sysdate
        AND department_code = p_department_code;

  CURSOR res_cur IS
     SELECT resource_id
       FROM bom_resources_val_v
      WHERE organization_id = l_organization_id
        AND resource_code = p_resource_code;

  CURSOR res_seq_cur IS
     SELECT resource_seq_num
       FROM wip_operation_resources
      WHERE wip_entity_id = l_wip_entity_id
        AND operation_seq_num = p_op_seq_num
        AND resource_seq_num = p_res_seq_num;

  -- Bug 2714880. Added the cursor below to fetch the status of the job.

  CURSOR job_status IS
     SELECT status_type
       FROM wip_discrete_jobs
      WHERE wip_entity_id = l_wip_entity_id;


 BEGIN

  -- Get the value entered in confirm_action Collection element.

  -- Bug 3684073. We should not derive the lookup_code value from
  -- mfg_lookups because the value passed to this api would be the
  -- qa_plan_char_value_lookups.short_code, which is not a translated
  -- column. The mfg_lookups view would have the lookup meaning in the
  -- language used in the current session.
  --
  -- Commented the below piece of code and compared p_launch_action
  -- and p_action_fired parameters below with the new constants to resolve
  -- the value entered. kabalakr.

  -- l_launch_action := get_mfg_lookups_value(p_launch_action,'SYS_YES_NO');
  -- l_action_fired  := get_mfg_lookups_value(p_action_fired,'SYS_YES_NO');

  -- The Action Code should get executed only if
  -- Launch_action is 'Yes' and Action_fired is 'No'

  IF (upper(p_launch_action) = g_lookup_yes AND upper(p_action_fired) = g_lookup_no) THEN
    NULL;

  ELSE
    -- dont fire the action.
    RETURN;
  END IF;

  -- Get the plan_id, group_id and org_id now. We need these values
  -- for Handshaking in this procedure.

  l_organization_id  := get_organization_id(p_organization_code);
  l_plan_id          := get_plan_id(p_plan_name);


  IF (l_plan_id = -1 OR l_organization_id = -1) THEN

      -- We may need to populate appropriate error message here before return.
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN  group_cur;
  FETCH group_cur INTO l_group_id;
  CLOSE group_cur;


  -- Update the Disposition Status to 'Pending'.
  UPDATE_STATUS(l_plan_id,p_collection_id,p_occurrence);

  -- Derive the wip_entity_id of the Job.
  OPEN  job_cur;
  FETCH job_cur INTO l_wip_entity_id;
  CLOSE job_cur;

  -- Bug 2714880. Fetch the status_type of the job. We pass this value to the
  -- internal functions REWORK_OP_ADD_OP_INT() REWORK_OP_ADD_RES_INT()  that
  -- adds Operations and Resources respectively.
  OPEN  job_status;
  FETCH job_status INTO l_status_type;
  CLOSE job_status;

  -- Validate the Rework Operation Sequence Num. If Operation code is specified,
  -- its a standard Operation. If Operation Code is not mentioned, user is
  -- intending to add NON Standard Operation OR to add just resource to the
  -- existing Operation Sequence Number.

  OPEN  op_seq_cur;
  FETCH op_seq_cur INTO l_dup_op_seq;
  CLOSE op_seq_cur;


  -- If Operation Seq Num is already existing and the Operation code is
  -- specified, user is intending to add a standard Operation with Duplicate
  -- Operation Seq Num. So error out.

  IF (l_dup_op_seq IS NOT NULL) AND (p_operation_code IS NOT NULL) THEN
     l_result    := g_int_err;
     l_err_msg   := fnd_message.get_string('QA', 'QA_SODISP_DUP_OP_SEQ_NUM');

     WRITE_BACK( p_plan_id          =>  l_plan_id,
                 p_collection_id    =>  p_collection_id,
                 p_occurrence       =>  p_occurrence,
                 p_status           =>  l_result,
                 p_message          =>  l_err_msg);
     RETURN;
  END IF;

  -- Check whehter the Resource Seq Num given as input is not a duplicate one.
  -- We cannot accespt duplicate resource seq num for a operation Seq Num.

  OPEN  res_seq_cur;
  FETCH res_seq_cur INTO l_dup_res_seq;
  CLOSE res_seq_cur;

  IF (l_dup_res_seq IS NOT NULL) AND (p_operation_code IS NULL) THEN
     l_result    := g_int_err;
     l_err_msg   := fnd_message.get_string('QA', 'QA_SODISP_DUP_RES_SEQ_NUM');

     WRITE_BACK( p_plan_id          =>  l_plan_id,
                 p_collection_id    =>  p_collection_id,
                 p_occurrence       =>  p_occurrence,
                 p_status           =>  l_result,
                 p_message          =>  l_err_msg);
     RETURN;

  END IF;


  -- If Operation Seq Num specified is not a duplicate, we need to add this
  -- Operation onto the Job. If Operation Code is specified, then add the specified
  -- operation, otherwise just add the Operation Seq Num with Department details.

  IF (p_operation_code IS NOT NULL) THEN

     -- A value of 1 in l_op_type means, its standard operation.
     l_op_type := 1;

     OPEN  op_cur;
     FETCH op_cur INTO l_operation_id;
     CLOSE op_cur;

  END IF;

  IF (p_department_code IS NOT NULL) THEN

     OPEN  dept_cur;
     FETCH dept_cur INTO l_department_id;
     CLOSE dept_cur;

  END IF;

  IF ( l_dup_op_seq IS NULL) THEN

     -- Call REWORK_OP_ADD_OP_INT procedure for Adding Operations.
     -- It returns the WIP Mass Load Concurrent Request Id launched for
     -- processing the Addition of Operation.

     l_request := REWORK_OP_ADD_OP_INT(
                                  l_group_id,
                                  p_job_name,
                                  l_wip_entity_id,
                                  p_op_seq_num,
                                  l_operation_id,
                                  l_department_id,
                                  qltdate.any_to_date(p_start_date),
                                  qltdate.any_to_date(p_end_date),
                                  l_organization_id,
                                  l_status_type);


     IF (l_request = 0) THEN

        -- Concurrent Request not launched
        l_result := g_failed;
        l_err_msg := fnd_message.get_string('QA', 'QA_SODISP_REQ_NOT_LAUNCHED');

        WRITE_BACK( p_plan_id           =>  l_plan_id,
                    p_collection_id     =>  p_collection_id,
                    p_occurrence        =>  p_occurrence,
                    p_status            =>  l_result,
                    p_message           =>  l_err_msg);

        RETURN;

     -- Bug 2689276. Added the ELSE condition below. If the request gets launched,
     -- write back the concurrent request id.

     ELSE

        WRITE_BACK( p_plan_id           =>  l_plan_id,
                    p_collection_id     =>  p_collection_id,
                    p_occurrence        =>  p_occurrence,
                    p_status            =>  g_pending,
                    p_request_id        =>  l_request);

     END IF;

     -- If request gets launched, proceed.
     -- But first, wait for the WIP Mass Load Program request to be completed.
     -- We wait 100 minutes for the Mass Load to Complete. And we check in
     -- every 15 Minutes

     l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_request,
                                               g_check_request_time,
                                               g_total_request_time,
                                               l_phase,
                                               l_status,
                                               l_devphase,
                                               l_devstatus,
                                               l_message);

     IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
        IF (substr(l_devstatus,1,5) = 'ERROR') THEN

           l_result := g_failed;

        ELSIF (substr(l_devstatus,1,7) = 'WARNING') THEN

           l_result := g_warning;

        ELSIF (substr(l_devstatus,1,6) = 'NORMAL') THEN

           -- Bug 2656461. Commented the 'COMMIT' below. Its not required.

           -- Issue a Commit.
           -- COMMIT;

           l_result := g_success;

           -- Bug 2656461. Once the Action is successful, we also need to copy
           -- the attachments to the new Operation added.

           FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                               X_from_entity_name => 'QA_RESULTS',
                               X_from_pk1_value   => to_char(p_occurrence),
                               X_from_pk2_value   => to_char(p_collection_id),
                               X_from_pk3_value   => to_char(l_plan_id),
                               X_to_entity_name   => 'WIP_DISCRETE_OPERATIONS',
                               X_to_pk1_value     => to_char(l_wip_entity_id),
                               X_to_pk2_value     => to_char(p_op_seq_num),
                               X_to_pk3_value     => to_char(l_organization_id));


        ELSE
           l_result := g_failed;

        END IF;

        -- Call for handshaking the outcome onto the Collection Plan.

        WRITE_BACK(p_plan_id        =>  l_plan_id,
                   p_collection_id  =>  p_collection_id,
                   p_occurrence     =>  p_occurrence,
                   p_status         =>  l_result,
                   p_wjsi_group_id  =>  l_group_id,
                   p_request_id     =>  l_request
                   );

        -- Return from the API if the WIP Mass Load errors out.
        IF (l_result <> g_success) THEN
           RETURN;
        END IF;

     END IF; -- if complete.

  END IF; -- l_dup_op_seq IS NULL.

  -- Call REWORK_OP_ADD_RES_INT procedure for Adding Resources. It returns the
  -- WIP Mass Load Concurrent Request Id launched for processing the Addition
  -- of Resource. For Standard Operations. all the resources will be added
  -- together. For Non Standard Operation, only one resource will be added at
  -- a time.
  -- The parameter p_op_type decides internally whether the resources are being
  -- added for s Standard Operation (1) or NON standard operation (2).

  -- Get the new group_id from the Sequence for Adding Resources.
  OPEN  group_cur;
  FETCH group_cur INTO l_group_id;
  CLOSE group_cur;


  -- Get the id for Resource.
  OPEN  res_cur;
  FETCH res_cur INTO l_resource_id;
  CLOSE res_cur;


  l_request := REWORK_OP_ADD_RES_INT(
                                    l_group_id,
                                    p_job_name,
                                    l_wip_entity_id,
                                    p_op_seq_num,
                                    l_operation_id,
                                    l_department_id,
                                    p_res_seq_num,
                                    l_resource_id,
                                    p_assigned_units,
                                    p_usage_rate,
                                    l_organization_id,
                                    l_op_type,
                                    l_status_type
                                    );


  IF (l_request = 0) THEN

     -- Concurrent Request not launched
     l_result := g_failed;
     l_err_msg := fnd_message.get_string('QA', 'QA_SODISP_REQ_NOT_LAUNCHED');

     WRITE_BACK( p_plan_id           =>  l_plan_id,
                 p_collection_id     =>  p_collection_id,
                 p_occurrence        =>  p_occurrence,
                 p_status            =>  l_result,
                 p_message           =>  l_err_msg);

     RETURN;

  -- Bug 2689276. Added the ELSE condition below. If the request gets launched,
  -- write back the concurrent request id.

  ELSE

     WRITE_BACK( p_plan_id           =>  l_plan_id,
                 p_collection_id     =>  p_collection_id,
                 p_occurrence        =>  p_occurrence,
                 p_status            =>  g_pending,
                 p_request_id        =>  l_request);

  END IF;

  -- If request gets launched, proceed.
  -- But first, wait for the WIP Mass Load Program request to be completed.
  -- We wait 100 minutes for the Mass Load to Complete. And we check in
  -- every 15 Minutes

  l_wait := FND_CONCURRENT.WAIT_FOR_REQUEST(l_request,
                                            g_check_request_time,
                                            g_total_request_time,
                                            l_phase,
                                            l_status,
                                            l_devphase,
                                            l_devstatus,
                                            l_message);

  IF (substr(l_devphase,1,8) = 'COMPLETE') THEN
     IF (substr(l_devstatus,1,5) = 'ERROR') THEN

        l_result := g_failed;

     ELSIF (substr(l_devstatus,1,7) = 'WARNING') THEN

        l_result := g_warning;

     ELSIF (substr(l_devstatus,1,6) = 'NORMAL') THEN

        l_result := g_success;

     ELSE
        l_result := g_failed;

     END IF;

     -- Call for handshaking the outcome onto the Collection Plan.

     WRITE_BACK(p_plan_id        =>  l_plan_id,
                p_collection_id  =>  p_collection_id,
                p_occurrence     =>  p_occurrence,
                p_status         =>  l_result,
                p_wjsi_group_id  =>  l_group_id,
                p_request_id     =>  l_request
                );

     END IF; -- if complete.

 END REWORK_ADD_OPERATION;


 -- Procedure to Add Operations.

 FUNCTION REWORK_OP_ADD_OP_INT(
                            p_group_id         NUMBER,
                            p_job_name         VARCHAR2,
                            p_wip_entity_id    NUMBER,
                            p_op_seq_num       NUMBER,
                            p_operation_id     NUMBER,
                            p_department_id    NUMBER,
                            p_start_date       DATE,
                            p_end_date         DATE,
                            p_organization_id  NUMBER,
                            p_status_type      NUMBER)

 RETURN NUMBER IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_request_id       NUMBER;
 l_update_by        NUMBER :=  fnd_global.user_id;
 l_update_name      VARCHAR2(100);

 l_header_id        NUMBER;

 l_department_id    NUMBER;
 l_count_point_type NUMBER;
 l_backflush_flag   NUMBER;
 l_min_txfr_qty     NUMBER;


 CURSOR update_cur IS
    SELECT user_name
      FROM fnd_user_view
     WHERE user_id = l_update_by;

 CURSOR op_det IS
    SELECT bdp.department_id, nvl(bso.count_point_type, 1) count_point_type,
           bso.backflush_flag, nvl(bso.minimum_transfer_quantity, 0) minimum_transfer_quantity
      FROM bom_departments bdp, bom_standard_operations bso
     WHERE bso.organization_id = p_organization_id
       AND bso.line_id is null
       AND nvl(bso.operation_type,1) = 1
       AND bdp.organization_id = p_organization_id
       AND bso.department_id = bdp.department_id
       AND nvl(bdp.disable_date, sysdate + 2) > sysdate
       AND bso.standard_operation_id = p_operation_id;


 BEGIN

   OPEN  update_cur;
   FETCH update_cur INTO l_update_name;
   CLOSE update_cur;


   IF (p_operation_id IS NOT NULL) THEN
     OPEN  op_det;
     FETCH op_det INTO l_department_id, l_count_point_type, l_backflush_flag, l_min_txfr_qty;
     CLOSE op_det;

   ELSE
     -- Get the default values.
     l_department_id    := p_department_id;
     l_min_txfr_qty     := 0;
     l_count_point_type := 1;
     l_backflush_flag   := 2;

   END IF;


   INSERT INTO WIP_JOB_SCHEDULE_INTERFACE
   (
         SOURCE_CODE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATED_BY_NAME,
         CREATION_DATE,
         CREATED_BY,
         CREATED_BY_NAME,
         GROUP_ID,
         ORGANIZATION_ID,
         LOAD_TYPE,
         STATUS_TYPE,
         JOB_NAME,
         WIP_ENTITY_ID,
         INTERFACE_ID,
         PROCESS_PHASE,
         PROCESS_STATUS,
         HEADER_ID
    )
       VALUES
        (
            'QA_ACTION: ADD_OP',
            sysdate,
            l_update_by,
            l_update_name,
            sysdate,
            l_update_by,
            l_update_name,
            p_group_id,
            p_organization_id,
            3,
            p_status_type,
            p_job_name,
            p_wip_entity_id,
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval,
            2,
            1,
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval
        ) returning header_id into l_header_id;


    INSERT INTO WIP_JOB_DTLS_INTERFACE
    (
         INTERFACE_ID,
         GROUP_ID,
         WIP_ENTITY_ID,
         ORGANIZATION_ID,
         OPERATION_SEQ_NUM,
         DEPARTMENT_ID,
         LOAD_TYPE,
         SUBSTITUTION_TYPE,
         PROCESS_PHASE,
         PROCESS_STATUS,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         PARENT_HEADER_ID,
         STANDARD_OPERATION_ID,
         FIRST_UNIT_START_DATE,
         FIRST_UNIT_COMPLETION_DATE,
         LAST_UNIT_START_DATE,
         LAST_UNIT_COMPLETION_DATE,
         MINIMUM_TRANSFER_QUANTITY,
         BACKFLUSH_FLAG,
         COUNT_POINT_TYPE
    )
        VALUES
        (
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval,
            p_group_id,
            p_wip_entity_id,
            p_organization_id,
            p_op_seq_num,
            l_department_id,
            3,             -- ( 3- Load Operation) LOAD_TYPE
            2,             -- ( 2- Add wip_job_details.wip_add) SUBSTITUTION_TYPE
            2,             -- ( 2- wip_constants.ml_validation) PROCESS_PHASE
            1,             -- ( 1- wip_constants.pending) PROCESS_STATUS
            sysdate,
            l_update_by,
            sysdate,
            l_update_by,
            l_header_id,
            p_operation_id,
            p_start_date,
            p_start_date,
            p_end_date,
            p_end_date,
            l_min_txfr_qty,
            l_backflush_flag,
            l_count_point_type
        );



   -- Call the WIP Mass Load Program in Background.
   l_request_id := FND_REQUEST.SUBMIT_REQUEST('WIP', 'WICMLP',
                                               NULL, NULL, FALSE,
                                               TO_CHAR(p_group_id),          -- grp id
                                               TO_CHAR(WIP_CONSTANTS.FULL),  -- validation lvl
                                               TO_CHAR(WIP_CONSTANTS.YES));  -- print report

   -- Commit the insert
   COMMIT;

   RETURN l_request_id;

 END REWORK_OP_ADD_OP_INT;


 -- addres

 FUNCTION REWORK_OP_ADD_RES_INT(
                     p_group_id         NUMBER,
                     p_job_name         VARCHAR2,
                     p_wip_entity_id    NUMBER,
                     p_op_seq_num       NUMBER,
                     p_operation_id     NUMBER,
                     p_department_id    NUMBER,
                     p_res_seq_num      NUMBER,
                     p_resource_id      NUMBER,
                     p_assigned_units   NUMBER,
                     p_usage_rate       NUMBER,
                     p_organization_id  NUMBER,
                     p_op_type          NUMBER,
                     p_status_type      NUMBER)

 RETURN NUMBER IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 l_request_id       NUMBER;
 l_update_by        NUMBER  :=  fnd_global.user_id;
 l_update_name      VARCHAR2(100);

 l_header_id        NUMBER;

 l_res_seq_num      NUMBER;
 l_resource_id      NUMBER;
 l_activity_id      NUMBER;
 l_assigned_units   NUMBER;
 l_basis_type       NUMBER;
 l_schedule_flag    NUMBER;
 l_std_rate_flag    NUMBER;
 l_usage_rate       NUMBER;
 l_autocharge_type  NUMBER;
 l_uom              VARCHAR2(3);


 CURSOR update_cur IS
   SELECT user_name
     FROM fnd_user_view
    WHERE user_id = l_update_by;


 CURSOR res_det IS
   SELECT bsor.resource_seq_num, bsor.resource_id, bsor.activity_id,
          bsor.assigned_units, bsor.basis_type, bsor.schedule_flag,
          bsor.standard_rate_flag, bsor.usage_rate_or_amount,
          bsor.autocharge_type, br.unit_of_measure
     FROM bom_std_op_resources bsor, bom_resources br
    WHERE bsor.resource_id = br.resource_id
      AND bsor.standard_operation_id = p_operation_id;


 CURSOR m_res_det IS
   SELECT res.unit_of_measure, nvl(res.default_basis_type,1) basis_type,
          2 "scheduled_flag", res.default_activity_id,
          nvl(res.autocharge_type, 1) autocharge_type,
          nvl(res.standard_rate_flag,1) standard_rate_flag
     FROM bom_resources res, bom_department_resources bdr
    WHERE res.organization_id = p_organization_id
      AND nvl(res.disable_date, sysdate + 2) > sysdate
      AND res.resource_id = bdr.resource_id
      AND bdr.department_id = p_department_id
      AND res.resource_id = p_resource_id;

 BEGIN


   OPEN  update_cur;
   FETCH update_cur INTO l_update_name;
   CLOSE update_cur;

   INSERT INTO WIP_JOB_SCHEDULE_INTERFACE
   (
         SOURCE_CODE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATED_BY_NAME,
         CREATION_DATE,
         CREATED_BY,
         CREATED_BY_NAME,
         GROUP_ID,
         ORGANIZATION_ID,
         LOAD_TYPE,
         STATUS_TYPE,
         JOB_NAME,
         WIP_ENTITY_ID,
         INTERFACE_ID,
         PROCESS_PHASE,
         PROCESS_STATUS,
         HEADER_ID
   )
        VALUES
        (
            'QA_ACTION: ADD_RES',
            sysdate,
            l_update_by,
            l_update_name,
            sysdate,
            l_update_by,
            l_update_name,
            p_group_id,
            p_organization_id,
            3,
            p_status_type,
            p_job_name,
            p_wip_entity_id,
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval,
            2,
            1,
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval
        ) returning header_id into l_header_id;


   IF (p_op_type = 2) THEN

     OPEN  m_res_det;
     FETCH m_res_det INTO l_uom, l_basis_type, l_schedule_flag, l_activity_id,
                          l_autocharge_type, l_std_rate_flag;
     CLOSE m_res_det;

     INSERT INTO WIP_JOB_DTLS_INTERFACE
     (
         INTERFACE_ID,
         GROUP_ID,
         ORGANIZATION_ID,
         OPERATION_SEQ_NUM,
         LOAD_TYPE,
         SUBSTITUTION_TYPE,
         PROCESS_PHASE,
         PROCESS_STATUS,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         PARENT_HEADER_ID,
         ACTIVITY_ID,
         ASSIGNED_UNITS,
         AUTOCHARGE_TYPE,
         BASIS_TYPE,
         RESOURCE_ID_NEW,
         RESOURCE_SEQ_NUM,
         SCHEDULED_FLAG,
         STANDARD_RATE_FLAG,
         USAGE_RATE_OR_AMOUNT,
         UOM_CODE
     )
        VALUES
        (
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval,
            p_group_id,
            p_organization_id,
            p_op_seq_num,
            1,             -- ( 1- Load Resource) LOAD_TYPE
            2,             -- ( 2- Add wip_job_details.wip_add) SUBSTITUTION_TYPE
            2,             -- ( 2- wip_constants.ml_validation) PROCESS_PHASE
            1,             -- ( 1- wip_constants.pending) PROCESS_STATUS
            sysdate,
            l_update_by,
            sysdate,
            l_update_by,
            l_header_id,
            l_activity_id,
            p_assigned_units,
            l_autocharge_type,
            l_basis_type,
            p_resource_id,
            p_res_seq_num,
            l_schedule_flag,
            l_std_rate_flag,
            p_usage_rate,
            l_uom
        );


   ELSIF (p_op_type = 1) THEN

     OPEN  res_det;
     LOOP
       FETCH res_det INTO l_res_seq_num, l_resource_id, l_activity_id,
                          l_assigned_units, l_basis_type, l_schedule_flag,
                          l_std_rate_flag, l_usage_rate, l_autocharge_type, l_uom;

       EXIT WHEN res_det%NOTFOUND;


       INSERT INTO WIP_JOB_DTLS_INTERFACE
       (
         INTERFACE_ID,
         GROUP_ID,
         ORGANIZATION_ID,
         OPERATION_SEQ_NUM,
         LOAD_TYPE,
         SUBSTITUTION_TYPE,
         PROCESS_PHASE,
         PROCESS_STATUS,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         PARENT_HEADER_ID,
         ACTIVITY_ID,
         ASSIGNED_UNITS,
         AUTOCHARGE_TYPE,
         BASIS_TYPE,
         RESOURCE_ID_NEW,
         RESOURCE_SEQ_NUM,
         SCHEDULED_FLAG,
         STANDARD_RATE_FLAG,
         USAGE_RATE_OR_AMOUNT,
         UOM_CODE
       )
        VALUES
        (
            WIP_JOB_SCHEDULE_INTERFACE_S.nextval,
            p_group_id,
            p_organization_id,
            p_op_seq_num,
            1,             -- ( 1- Load Resource) LOAD_TYPE
            2,             -- ( 2- Add wip_job_details.wip_add) SUBSTITUTION_TYPE
            2,             -- ( 2- wip_constants.ml_validation) PROCESS_PHASE
            1,             -- ( 1- wip_constants.pending) PROCESS_STATUS
            sysdate,
            l_update_by,
            sysdate,
            l_update_by,
            l_header_id,
            l_activity_id,
            l_assigned_units,
            l_autocharge_type,
            l_basis_type,
            l_resource_id,
            l_res_seq_num,
            l_schedule_flag,
            l_std_rate_flag,
            l_usage_rate,
            l_uom
        );

     END LOOP;
     CLOSE res_det;

   END IF;

   -- Call the WIP Mass Load Program in Background.
   l_request_id := FND_REQUEST.SUBMIT_REQUEST('WIP', 'WICMLP',
                                               NULL, NULL, FALSE,
                                               TO_CHAR(p_group_id),          -- grp id
                                               TO_CHAR(WIP_CONSTANTS.FULL),  -- validation lvl
                                               TO_CHAR(WIP_CONSTANTS.YES));  -- print report

   -- Commit the insert
   COMMIT;

   RETURN l_request_id;

 END REWORK_OP_ADD_RES_INT;




 PROCEDURE UPDATE_STATUS(p_plan_id       IN NUMBER,
                         p_collection_id IN NUMBER,
                         p_occurrence    IN NUMBER) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

  l_txnheader_id       NUMBER;

 BEGIN

  -- Update the Dispostion_Status to 'Pending'.

  UPDATE qa_results
  SET    disposition_status = 'PENDING',
         txn_header_id =  mtl_material_transactions_s.nextval
  WHERE  collection_id = p_collection_id AND occurrence = p_occurrence
  RETURNING txn_header_id INTO l_txnheader_id;

  -- Calling parent-child pkg to insert History child record for the plan.
  QA_PARENT_CHILD_PKG.insert_history_auto_rec(p_plan_id,l_txnheader_id, 1, 4);

  -- Commit now.
  COMMIT;

 END UPDATE_STATUS;


 PROCEDURE WRITE_BACK(p_plan_id                        IN NUMBER,
                      p_collection_id                  IN NUMBER,
                      p_occurrence                     IN NUMBER,
                      p_status                         IN VARCHAR2,
                      p_mti_transaction_header_id      IN NUMBER,
                      p_mti_transaction_interface_id   IN NUMBER,
                      p_mmt_transaction_id             IN NUMBER,
                      p_wmti_group_id                  IN NUMBER,
                      p_wmt_transaction_id             IN NUMBER,
                      p_rti_interface_transaction_id   IN NUMBER,
                      p_job_id                         IN NUMBER,
                      p_wjsi_group_id                  IN NUMBER,
                      p_request_id                     IN NUMBER,
                      p_message                        IN VARCHAR2,
                      p_move_order_number              IN VARCHAR2,
                      p_eco_name                       IN VARCHAR2) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

  l_action_fired_column    VARCHAR2(30);
  l_disp_message_column    VARCHAR2(30);
  l_move_order_column      VARCHAR2(30);

  l_sql_string         VARCHAR2(10000);
  l_action_fired       VARCHAR2(250);

  -- Find out correct element char_id and assign to the below constant

  l_move_order_char_id   CONSTANT NUMBER := qa_ss_const.move_order_number;
  l_action_fired_char_id CONSTANT NUMBER := qa_ss_const.action_fired;
  l_disp_message_char_id CONSTANT NUMBER := qa_ss_const.disposition_message;

  l_txnheader_id       NUMBER;

  -- Bug 2698365. The below cursor is no longer required.
  -- We are returning the sequence value from the update statement.
  -- kabalakr.

/*
  CURSOR txn_head_seq IS
    SELECT mtl_material_transactions_s.nextval
    FROM DUAL;
*/

  -- We are not translating the Action_Fired value.
  -- Hence commenting the below cursor.
  -- Bug 2595276. kabalakr

/*
  CURSOR lookup_cur(l_lookup_code NUMBER) IS
    SELECT substr(ltrim(rtrim(meaning)),1,20)
    FROM mfg_lookups
    WHERE lookup_type = 'SYS_YES_NO'
    AND lookup_code = l_lookup_code ;
*/

 BEGIN


   IF p_status = 'INT_ERROR' THEN
     -- When internal error occurs, we need to set the action_fired to 'No'
     -- so that user can refire the action form UQR

     -- OPEN lookup_cur(g_lookup_no);

     -- We are not translating the Action_Fired value. Commented the
     -- above line of code. Assigning the hardcoded string below.
     -- Bug 2595276. kabalakr.

  -- anagarwa Fri Jul  2 16:30:00 PDT 2004
  -- bug 3736593 action fired element cannot be validated.
  -- following function looks for values in qa_plan_char_value_lookups and
  -- if not found, it executes the sql validation string
     --l_action_fired := 'No' ;
     l_action_fired := get_short_code(p_plan_id, l_action_fired_char_id, 'NO');

   ELSE
     -- all other cases, set action_fired to 'Yes'

     -- OPEN lookup_cur(g_lookup_yes);

     -- We are not translating the Action_Fired value. Commented the
     -- above line of code. Assigning the hardcoded string below.
     -- Bug 2595276. kabalakr.

  -- anagarwa Fri Jul  2 16:30:00 PDT 2004
  -- bug 3736593 action fired element cannot be validated.
  -- following function looks for values in qa_plan_char_value_lookups and
  -- if not found, it executes the sql validation string
     --l_action_fired := 'Yes' ;
       l_action_fired := get_short_code(p_plan_id, l_action_fired_char_id, 'YES');


   END IF;

   -- We are not translating the Action_Fired value. Commenting the
   -- code below. Bug 2595276. kabalakr.

   -- FETCH lookup_cur INTO l_action_fired;
   -- CLOSE lookup_cur;

   -- Needs to get the result column names of the Seeded handshaking
   -- Collection elements.

   l_action_fired_column := QA_FLEX_UTIL.qpc_result_column_name(p_plan_id, l_action_fired_char_id);
   l_disp_message_column := QA_FLEX_UTIL.qpc_result_column_name(p_plan_id, l_disp_message_char_id);

   -- Bug 2698365. The cursor txn_head_seq is no longer required. Hence commenting
   -- the piece of code below. We are returning the value of txn_header_id from the
   -- update statement. kabalakr.
  /*
   OPEN txn_head_seq;
   FETCH txn_head_seq INTO l_txnheader_id;
   CLOSE txn_head_seq;
  */

   -- Added the eco_name column to support 'Create ECO' corrective action.

   -- Bug 2689305. Added NVL () for all the parameter variables used below
   -- which had a default value of NULL. kabalakr.

   -- Bug 2698365. Added txn_header_id in the update statement below and
   -- returning its value to the variable l_txnheader_id. kabalakr.

   UPDATE qa_results
   SET disposition_status           = p_status,
       wip_rework_id                = NVL(p_job_id, 0),
       wjsi_group_id                = NVL(p_wjsi_group_id, 0),
       mti_transaction_header_id    = NVL(p_mti_transaction_header_id, 0),
       mti_transaction_interface_id = NVL(p_mti_transaction_interface_id, 0),
       mmt_transaction_id           = NVL(p_mmt_transaction_id, 0),
       wmti_group_id                = NVL(p_wmti_group_id, 0),
       wmt_transaction_id           = NVL(p_wmt_transaction_id, 0),
       rti_interface_transaction_id = NVL(p_rti_interface_transaction_id, 0),
       concurrent_request_id        = NVL(p_request_id, 0),
       eco_name                     = p_eco_name,
       txn_header_id                = mtl_material_transactions_s.nextval
   WHERE collection_id = p_collection_id
   AND   occurrence = p_occurrence
   RETURNING txn_header_id INTO l_txnheader_id;


   -- Bug 2935558/2941809. Need to use bind variables instead of literal values when
   -- using EXECUTE IMMEDIATE. This is for the SQL Bind Compliance Project.
   -- kabalakr

   IF p_move_order_number IS NOT NULL THEN
      l_move_order_column   := QA_FLEX_UTIL.qpc_result_column_name(p_plan_id, l_move_order_char_id);

      l_sql_string := 'UPDATE qa_results SET '||
                        l_move_order_column  ||' = :move_order_number, ' ||
                        l_action_fired_column||' = :action_fired, '||
                        l_disp_message_column||' = :message '||
                        ' WHERE collection_id = :coll_id AND occurrence = :occ';

      EXECUTE IMMEDIATE l_sql_string USING p_move_order_number, l_action_fired, p_message,  p_collection_id, p_occurrence;

   ELSE


      l_sql_string := 'UPDATE qa_results SET ' ||
                       l_action_fired_column||' = :action_fired, '||
                       l_disp_message_column||' = :message '||
                       ' WHERE collection_id = :coll_id AND occurrence = :occ';

      EXECUTE IMMEDIATE l_sql_string USING l_action_fired, p_message, p_collection_id, p_occurrence;

   END IF;


   -- Calling parent-child pkg to insert History child record for the plan.
   -- action firing for child rec is taken care in the parent-child pkg.
   QA_PARENT_CHILD_PKG.insert_history_auto_rec(p_plan_id, l_txnheader_id, 1, 4);

   -- We need to fire action for the parent record only.
   QA_PARENT_CHILD_PKG.enable_fire_for_txn_hdr_id(l_txnheader_id);

   -- Commit Now.
   COMMIT;

 END WRITE_BACK;

 FUNCTION get_mfg_lookups_value (p_meaning     VARCHAR2,
                                 p_lookup_type VARCHAR2)
 RETURN NUMBER IS

   l_lookup_code VARCHAR2(2);

   CURSOR meaning_cur IS
      SELECT lookup_code
      FROM mfg_lookups
      WHERE lookup_type = p_lookup_type
      AND upper(meaning) = upper(ltrim(rtrim(p_meaning)));

 BEGIN

   OPEN meaning_cur;
   FETCH meaning_cur INTO l_lookup_code;
   CLOSE meaning_cur;

   RETURN l_lookup_code;

 END get_mfg_lookups_value;

 FUNCTION get_plan_id(p_plan_name VARCHAR2)
   RETURN NUMBER IS

   l_plan_id NUMBER := -1;

   CURSOR plan_cur IS
      SELECT plan_id
      FROM QA_PLANS
      WHERE name = p_plan_name;

 BEGIN
    OPEN plan_cur;
    FETCH plan_cur INTO l_plan_id;
    CLOSE plan_cur;

    RETURN l_plan_id;

    EXCEPTION
    when NO_DATA_FOUND then
       RETURN -1;
    when OTHERS then
       RAISE;

 END get_plan_id;


 FUNCTION get_organization_id (p_organization_code VARCHAR2)
    RETURN NUMBER IS

   l_organization_id NUMBER := -1;

   -- Bug 4958743. SQL Repository Fix SQL ID: 15008948
   CURSOR org_cur IS
        SELECT organization_id
        FROM mtl_parameters
        WHERE organization_code = upper(p_organization_code);
/*
      SELECT organization_id
      FROM org_organization_definitions
      WHERE organization_code = p_organization_code;
*/

 BEGIN

    OPEN org_cur;
    FETCH org_cur INTO l_organization_id;
    CLOSE org_cur;

    RETURN l_organization_id;

    EXCEPTION

    when NO_DATA_FOUND then
       RETURN -1;
    when OTHERS then
       RAISE;

 END get_organization_id;

  -- anagarwa Fri Jul  2 16:30:00 PDT 2004
  -- bug 3736593 action fired element cannot be validated.
  -- following function looks for values in qa_plan_char_value_lookups and
  -- if not found, it executes the sql validation string
 FUNCTION get_short_code(p_plan_id NUMBER,
                         p_char_id NUMBER,
                         p_short_code IN VARCHAR2)
 RETURN VARCHAR2 IS

 l_return_value VARCHAR2(250);
 x_ref LookupCur;
 sql_string VARCHAR2(3000);

 CURSOR c IS
 SELECT  short_code
 FROM    qa_plan_char_value_lookups
 WHERE   plan_id = p_plan_id
 AND     char_id = p_char_id
 AND     upper(short_code) = upper(p_short_code);

 BEGIN

    IF qa_plan_element_api.values_exist(p_plan_id, p_char_id) THEN

        OPEN c;
        FETCH c INTO l_return_value;
        CLOSE c;

    ELSIF qa_plan_element_api.sql_validation_exists(p_char_id) THEN

        sql_string := qa_plan_element_api.get_sql_validation_string(p_char_id);

        --
        -- Bug 1474995.  Adding filter to the user-defined SQL.
        --
        sql_string :=
            'select code
            from
               (select ''x'' code, ''x'' description
                from dual
                where 1 = 2
                union
                select * from
                ( '|| sql_string ||
               ' )) where upper(code) = upper(:1)';

        OPEN x_ref FOR sql_string USING p_short_code;
        FETCH x_ref INTO l_return_value;
        CLOSE x_ref;
    ELSE
        l_return_value := p_short_code;
    END IF;

    RETURN l_return_value;
 END;

END QA_SOLUTION_DISPOSITION_PKG;


/
