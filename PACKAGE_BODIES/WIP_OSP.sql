--------------------------------------------------------
--  DDL for Package Body WIP_OSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OSP" AS
 /* $Header: wipospvb.pls 120.16.12010000.6 2010/03/04 13:48:48 shjindal ship $ */

  Additional_Quantity NUMBER := 0;

  PROCEDURE RELEASE_VALIDATION
    (P_Wip_Entity_Id NUMBER,
     P_Organization_id NUMBER,
     P_Repetitive_Schedule_Id NUMBER) IS

  firstop NUMBER;               /* First Op Seq of the Routing */
  outside_proc_acct NUMBER;     /* OSP account from Job or Schedule */
  line_id NUMBER;               /* Line Id for Repetitive Schedule */
  x_osp_found BOOLEAN;
  op_seq_num NUMBER := -1;
  res_seq_num NUMBER := -1;
  l_success number := 0 ;
  -- l_po_receipt_found BOOLEAN := FALSE ;
  -- we will use l_launch_req_import to determine whether we have to launch
  -- Req Import concurrent program or not
  l_launch_req_import NUMBER := WIP_CONSTANTS.NO;
  l_itemkey VARCHAR2(240) := NULL;
  l_primary_uom VARCHAR2(25);
  l_osp_item_id NUMBER := -1; /*Added for the bug 2018510 */
  l_ou_id number;
  l_org_acct_ctxt VARCHAR2(30):= 'Accounting Information';
  l_req_import VARCHAR2(25); -- Fix for bug 8919025(Fp 8850950)

/* Select Op Seq that have outside processing resources and have
 * po_creation_time set to "At Job/Schedule Release"
 */

/* Fixed Bug# 1883170. Defaulted po_creation_time to "At Operation" when
 * po_creation_time is null for upgraded records
 */


  CURSOR Cdisc IS
    SELECT WO.OPERATION_SEQ_NUM, WDJ.OUTSIDE_PROCESSING_ACCOUNT,
           NVL(WDJ.PO_CREATION_TIME, 2) PO_CREATION_TIME,
           WOR.RESOURCE_SEQ_NUM,
           WO.COUNT_POINT_TYPE, WOR.AUTOCHARGE_TYPE,
           decode (WO.PREVIOUS_OPERATION_SEQ_NUM, NULL, 'YES', 'NO') FIRST_OP,
           WO.SCHEDULED_QUANTITY,
           WE.ENTITY_TYPE
      FROM WIP_OPERATION_RESOURCES WOR,
           WIP_OPERATIONS WO,
           WIP_DISCRETE_JOBS WDJ,
           WIP_ENTITIES WE
     WHERE WO.WIP_ENTITY_ID = P_Wip_Entity_Id
       AND WO.ORGANIZATION_ID = P_Organization_Id
       AND WE.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
       AND WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
       AND WDJ.ORGANIZATION_ID = WO.ORGANIZATION_ID
       AND WOR.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
       AND WOR.ORGANIZATION_ID = WO.ORGANIZATION_ID
       AND WOR.OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM
       AND WOR.AUTOCHARGE_TYPE IN (WIP_CONSTANTS.PO_RECEIPT,
                                   WIP_CONSTANTS.PO_MOVE)
  ORDER BY WO.OPERATION_SEQ_NUM;

  CURSOR Crep IS
    SELECT WO.OPERATION_SEQ_NUM,
           WRS.OUTSIDE_PROCESSING_ACCOUNT,
           WOR.RESOURCE_SEQ_NUM, WRS.LINE_ID,
           NVL(WRS.PO_CREATION_TIME, 2) PO_CREATION_TIME,
           WO.COUNT_POINT_TYPE, WOR.AUTOCHARGE_TYPE,
           decode (WO.PREVIOUS_OPERATION_SEQ_NUM, NULL, 'YES', 'NO') FIRST_OP,
           WO.SCHEDULED_QUANTITY
      FROM WIP_OPERATION_RESOURCES WOR,
           WIP_OPERATIONS WO,
           WIP_REPETITIVE_SCHEDULES WRS
     WHERE WO.WIP_ENTITY_ID = P_Wip_Entity_Id
       AND WO.ORGANIZATION_ID = P_Organization_Id
       AND WO.REPETITIVE_SCHEDULE_ID = P_Repetitive_Schedule_Id
       AND WRS.ORGANIZATION_ID = WO.ORGANIZATION_ID
       AND WRS.REPETITIVE_SCHEDULE_ID = WO.REPETITIVE_SCHEDULE_ID
       AND WOR.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
       AND WOR.ORGANIZATION_ID = WO.ORGANIZATION_ID
       AND WOR.REPETITIVE_SCHEDULE_ID = WO.REPETITIVE_SCHEDULE_ID
       AND WOR.OPERATION_SEQ_NUM = WO.OPERATION_SEQ_NUM
       AND WOR.AUTOCHARGE_TYPE IN (WIP_CONSTANTS.PO_RECEIPT,
                                   WIP_CONSTANTS.PO_MOVE)
  ORDER BY WO.OPERATION_SEQ_NUM;

  CURSOR Cuom IS
    SELECT msi.PRIMARY_UOM_CODE
      FROM wip_entities we,
           mtl_system_items msi
     WHERE we.wip_entity_id = P_Wip_Entity_Id
       AND we.organization_id = P_Organization_Id
       AND msi.inventory_item_id = we.primary_item_id
       AND msi.organization_id = we.organization_id;

  BEGIN

  IF P_Repetitive_Schedule_Id IS NULL THEN
    FOR cdis_rec in Cdisc LOOP
      IF(cdis_rec.operation_seq_num <> op_seq_num OR
         cdis_rec.resource_seq_num <> res_seq_num) THEN

        IF((cdis_rec.count_point_type <> WIP_CONSTANTS.NO_DIRECT) AND
           ((cdis_rec.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
             OR (cdis_rec.first_op = 'YES' AND
                 cdis_rec.po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION)
           )
          ) THEN
          CREATE_REQUISITION(
            P_Wip_Entity_Id  => P_Wip_Entity_Id,
            P_Organization_Id => P_Organization_Id,
            P_Repetitive_Schedule_Id => P_Repetitive_Schedule_Id,
            P_Operation_Seq_Num => cdis_rec.OPERATION_SEQ_NUM,
            P_Resource_Seq_Num => cdis_rec.RESOURCE_SEQ_NUM);
        END IF;

        -- Fix bug 2174078 EAM do not want to launch workflow
        if cdis_rec.entity_type <> 6 then -- not eam workorder
        /* If first operation start workflow process (Shipping and Receiving
         * Intermediate) to notify supplier that intermediate has been shipped
         */

          -- Added the following for bug 2018510
          begin
            l_osp_item_id := -1;
            SELECT br.PURCHASE_ITEM_ID
              into l_osp_item_id
              from wip_entities we,
                   wip_operation_resources wor,
                   bom_resources br
             where we.wip_entity_id = p_wip_entity_id
               and we.organization_id = p_organization_id
               and wor.wip_entity_id = we.wip_entity_id
               and wor.organization_id = we.organization_id
               and nvl(wor.repetitive_schedule_id, -1)
                                   = nvl(P_Repetitive_Schedule_Id, -1)
               and wor.operation_seq_num = cdis_rec.operation_seq_num
               and wor.resource_seq_num = cdis_rec.resource_seq_num
               and wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
               and br.resource_id = wor.resource_id
               and br.organization_id = wor.organization_id;
          exception
            when no_data_found then null;
          end;

          IF((cdis_rec.first_op = 'YES') and
             (cdis_rec.autocharge_type = WIP_CONSTANTS.PO_MOVE) and
             (l_osp_item_id <> -1))   THEN

            OPEN Cuom;
            FETCH Cuom into l_primary_uom;
            CLOSE Cuom;

            -- Fixed bug 5569556. Need to set org context before launching
            -- workflow because Req Import need this information.
            -- get the OU, set context for MOAC.

            select to_number(ORG_INFORMATION3) into l_ou_id
              from HR_ORGANIZATION_INFORMATION
             where ORGANIZATION_ID = p_organization_id
               and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;

            FND_REQUEST.SET_ORG_ID (l_ou_id);

            wip_osp_shp_i_wf.StartWFProcess(
              p_itemtype => 'WIPISHPW',
              p_itemkey => l_itemkey,
              p_workflow_process => 'INTERMEDIATE_SHIP',
              p_wip_entity_id => P_Wip_Entity_Id,
              p_rep_sched_id => P_Repetitive_Schedule_Id,
              p_organization_id => P_Organization_Id,
              p_primary_qty => cdis_rec.SCHEDULED_QUANTITY,
              p_primary_uom => l_primary_uom,
              p_op_seq_num => cdis_rec.OPERATION_SEQ_NUM );

            if l_itemkey is not null then
              update wip_operations
                 set wf_itemtype = 'WIPISHPW',
                     wf_itemkey = l_itemkey
               where wip_entity_id = P_Wip_Entity_Id
                 and organization_id = P_Organization_Id
                 and operation_seq_num = cdis_rec.OPERATION_SEQ_NUM;
            end if;
            /* Fixed Bug# 1967211 */
            /* Fix for Bug#2389789. Added po_creation_time and ospEnabled condition */
          ELSIF (cdis_rec.autocharge_type = WIP_CONSTANTS.PO_RECEIPT and
             /* Fix for bug 2777387: Reqimport should be spawned even if
                PO Creation Time is set to At Operation, provided OSP resource
                is attached to the first operation.
              */
                 (cdis_rec.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE or
                 (cdis_rec.po_creation_time = WIP_CONSTANTS.AT_OPERATION
                     and cdis_rec.first_op = 'YES')))
                /*   and wip_common_wf_pkg.ospEnabled ) */ -- FP Bug 5125900, Base Bug 4529326, Commented out this 'and' condition
          THEN
            l_launch_req_import := WIP_CONSTANTS.YES;
          /* Fix for bug 3127921: Adding elsif condition to launch reqimport
             if po_creation_time is at job schedule release and a PO Move
             resource is present in some operation other than the first
             operation
           */
          ELSIF (cdis_rec.autocharge_type = WIP_CONSTANTS.PO_MOVE and
                 cdis_rec.first_op <> 'YES' and
                 cdis_rec.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE and
                 wip_common_wf_pkg.ospEnabled) then
            l_launch_req_import := WIP_CONSTANTS.YES;
          END IF;
        ELSE  -- if EAM work order
            /* Fix for Bug#2389789. Added po_creation_time and ospEnabled condition */
          if(cdis_rec.po_creation_time
               IN(WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE,
                  WIP_CONSTANTS.AT_OPERATION))
          /*   and wip_common_wf_pkg.ospEnabled)  */ -- FP Bug 5125900, Base Bug 4529326, Commented out this 'and' condition
          THEN
             --   l_po_receipt_found := TRUE;
             -- We should always launch Req Import for EAM even if the PO
             -- creation time is "At Operation".(got confirmation from Amit)
             l_launch_req_import := WIP_CONSTANTS.YES;
          end if ;
        END IF; --check for eam work order
      END IF;
      op_seq_num := cdis_rec.operation_seq_num;
      res_seq_num := cdis_rec.resource_seq_num;
    END LOOP;
  ELSE
    FOR crep_rec in Crep LOOP
      IF (crep_rec.operation_seq_num <> op_seq_num OR
          crep_rec.resource_seq_num <> res_seq_num) THEN

        IF(crep_rec.count_point_type <> WIP_CONSTANTS.NO_DIRECT AND
           ((crep_rec.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
             OR (crep_rec.first_op = 'YES' AND
                 crep_rec.po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION)
           )
          ) THEN
          CREATE_REQUISITION(
            P_Wip_Entity_Id => P_Wip_Entity_Id,
            P_Organization_Id => P_Organization_Id,
            P_Repetitive_Schedule_Id => P_Repetitive_Schedule_Id,
            P_Operation_Seq_Num => crep_rec.OPERATION_SEQ_NUM);
        END IF;

        -- Added the following for bug 2018510
        BEGIN
          l_osp_item_id  := -1;
          SELECT br.PURCHASE_ITEM_ID
            into l_osp_item_id
            from wip_entities we,
                 wip_operation_resources wor,
                 bom_resources br
           where we.wip_entity_id = p_wip_entity_id
             and we.organization_id = p_organization_id
             and wor.wip_entity_id = we.wip_entity_id
             and wor.organization_id = we.organization_id
             and nvl(wor.repetitive_schedule_id, -1)
                                = nvl(P_Repetitive_Schedule_Id, -1)
             and wor.operation_seq_num = crep_rec.operation_seq_num
             and wor.resource_seq_num = crep_rec.resource_seq_num
             and wor.autocharge_type = WIP_CONSTANTS.PO_MOVE
             and br.resource_id = wor.resource_id
             and br.organization_id = wor.organization_id;
        EXCEPTION
          when no_data_found then null;
        END;
        IF((crep_rec.first_op = 'YES') and
           (crep_rec.autocharge_type = WIP_CONSTANTS.PO_MOVE) and
           (l_osp_item_id <> -1)) THEN

          OPEN Cuom;
          FETCH Cuom into l_primary_uom;
          CLOSE Cuom;

          -- Fixed bug 5569556. Need to set org context before launching
          -- workflow because Req Import need this information.
          -- get the OU, set context for MOAC.

          select to_number(ORG_INFORMATION3) into l_ou_id
            from HR_ORGANIZATION_INFORMATION
           where ORGANIZATION_ID = p_organization_id
             and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;

          FND_REQUEST.SET_ORG_ID (l_ou_id);

          wip_osp_shp_i_wf.StartWFProcess(
            p_itemtype => 'WIPISHPW',
            p_itemkey => l_itemkey,
            p_workflow_process => 'INTERMEDIATE_SHIP',
            p_wip_entity_id => P_Wip_Entity_Id,
            p_rep_sched_id => P_Repetitive_Schedule_Id,
            p_organization_id => P_Organization_Id,
            p_primary_qty => crep_rec.SCHEDULED_QUANTITY,
            p_primary_uom => l_primary_uom,
            p_op_seq_num => crep_rec.OPERATION_SEQ_NUM );

          if l_itemkey is not null then
            update wip_operations
               set wf_itemtype = 'WIPISHPW',
                   wf_itemkey = l_itemkey
             where wip_entity_id = P_Wip_Entity_Id
               and repetitive_schedule_id = P_Repetitive_Schedule_Id
               and organization_id = P_Organization_Id
               and operation_seq_num = crep_rec.OPERATION_SEQ_NUM;
          end if;
               /* Fixed Bug# 1967211 */
               /* Fix for Bug#2389789. Added po_creation_time and ospEnabled condition */
        ELSIF (crep_rec.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
           /* Fix for bug 2777387: Reqimport should be spawned even if
              PO Creation Time is set to At Operation, provided OSP resource
              is attached to the first operation.
            */
              (crep_rec.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE or
              (crep_rec.po_creation_time = WIP_CONSTANTS.AT_OPERATION AND
               crep_rec.first_op = 'YES')))
            /* AND wip_common_wf_pkg.ospEnabled ) */ -- FP Bug 5125900, Base Bug 4529326, Commented out this 'and' condition
        THEN
           l_launch_req_import := WIP_CONSTANTS.YES;
          /* Fix for bug 3127921: Adding elsif condition to launch reqimport
             if po_creation_time is at job schedule release and a PO Move
             resource is present in some operation other than the first
             operation
           */
        ELSIF (crep_rec.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
               crep_rec.first_op <> 'YES' AND
               crep_rec.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE AND
               wip_common_wf_pkg.ospEnabled) THEN
          l_launch_req_import := WIP_CONSTANTS.YES;
        END IF;
      END IF;
      op_seq_num := crep_rec.operation_seq_num;
      res_seq_num := crep_rec.resource_seq_num;
    END LOOP;
  END IF;

  /* Fixed Bug# 1967211 */

--  if (l_po_receipt_found = TRUE ) then
  if(l_launch_req_import = WIP_CONSTANTS.YES) then

     -- get the OU, set context for MOAC
     select to_number(ORG_INFORMATION3) into l_ou_id
       from HR_ORGANIZATION_INFORMATION
      where ORGANIZATION_ID = p_organization_id
        and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;
     FND_REQUEST.SET_ORG_ID (l_ou_id);

     /*Fix for bug 8919025(Fp 8850950)*/
 	      BEGIN
 	      select reqimport_group_by_code
 	      into l_req_import
 	      from po_system_parameters_all
 	      where org_id = l_ou_id;
 	      EXCEPTION
 	      WHEN NO_DATA_FOUND THEN
 	      raise fnd_api.g_exc_unexpected_error;
 	      END;

     l_success := fnd_request.submit_request(
        'PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, l_req_import, --Fix for 8919025(Fp 8850950)
        NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;

  end if ;


  WIP_SF_STATUS.CREATE_OSP_STATUS (
        p_org_id        => P_Organization_id,
        p_wip_entity_id => P_Wip_Entity_Id,
        p_repetitive_sched_id => P_Repetitive_Schedule_Id );

  END RELEASE_VALIDATION;

  PROCEDURE CREATE_REQUISITION(
              P_Wip_Entity_Id NUMBER,
              P_Organization_Id NUMBER,
              P_Repetitive_Schedule_Id NUMBER,
              P_Operation_Seq_Num NUMBER,
              P_Resource_Seq_Num IN NUMBER DEFAULT NULL,
              P_Run_ReqImport IN NUMBER DEFAULT WIP_CONSTANTS.NO
              ) IS

  x_emp_found BOOLEAN;
  x_no_loc_found BOOLEAN;
  x_dummy VARCHAR2(2);
  x_project_id NUMBER:=NULL;
  x_task_id    NUMBER:=NULL;
  l_success number := 0 ;
  x_released_revs_type          NUMBER ;
  x_released_revs_meaning       Varchar2(30);
  l_org_acct_ctxt VARCHAR2(30):= 'Accounting Information';
  l_ou_id number;
  l_req_import VARCHAR2(25); --Fix for bug 8919025(Fp 8850950)

    /* You cannot create a requisition unless
       you are an employee.  If this returns a row, you are OK */

  CURSOR Cemp IS
        SELECT 'x'
        FROM    FND_USER FU,
                PER_PEOPLE_F PPF
        WHERE   FU.USER_ID = FND_GLOBAL.User_Id
        AND     FU.EMPLOYEE_ID = PPF.PERSON_ID;

  /* You cannot move to queue of the first op if
   * PO RECEIPT:  The 1st op department has no location
   * PO MOVE, Only 1 operation: The 1st op department has no location
   * PO MOVE, Multiple ops: The 2nd op department has no location
   */

  -- If this cursor returns a row, we have an error condition.
  CURSOR Cops IS
    select 'X'
    from  wip_operations wo,bom_departments bd
    where wo.department_id = bd.department_id
    and   wo.organization_id = bd.organization_id
    and   bd.location_id IS NULL
    and   level < 3
    and   exists (select 1
      from wip_operation_resources wor
      where wor.wip_entity_id = P_Wip_Entity_Id
      and wor.organization_id = P_Organization_Id
      and wor.operation_seq_num = P_Operation_Seq_num
      and wor.autocharge_type =
      decode(wo.operation_seq_num,P_Operation_Seq_num,
      WIP_CONSTANTS.PO_RECEIPT,WIP_CONSTANTS.PO_MOVE))
    start with wo.wip_entity_id = P_Wip_Entity_Id
    and wo.organization_id = P_Organization_Id
    and wo.operation_seq_num = P_Operation_Seq_num
    connect by wo.wip_entity_id = P_Wip_Entity_Id
    and  wo.operation_seq_num = prior wo.next_operation_seq_num
    and wo.organization_id = P_Organization_Id;

  CURSOR Cproject IS
    SELECT project_id , task_id
      FROM WIP_DISCRETE_JOBS
     WHERE organization_id = P_Organization_Id
       AND wip_entity_id = P_Wip_Entity_Id;

  BEGIN
    OPEN Cemp;
    FETCH Cemp INTO x_dummy;
    x_emp_found := Cemp%FOUND;
    CLOSE Cemp;

    IF x_emp_found = FALSE THEN
      FND_MESSAGE.SET_NAME('WIP', 'WIP_RELEASE_VALID_EMPLOYEE');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    OPEN Cops;
    FETCH Cops INTO X_dummy;
    x_no_loc_found := Cops%FOUND;
    CLOSE Cops;

    IF x_no_loc_found = TRUE THEN
      FND_MESSAGE.SET_NAME('WIP', 'WIP_RELEASE_PO_MOVE');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF P_Repetitive_Schedule_Id IS NULL THEN
      OPEN Cproject;
      FETCH CProject INTO x_project_id,x_task_id;
      CLOSE Cproject;
    END IF;

    wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                               x_released_revs_meaning
                                              );


    /* Create the requisition */
    IF Additional_Quantity > 0  THEN
      /* This additional_quantity is set to the increased quantity
          of the job that is modified by the user. */
      INSERT INTO PO_REQUISITIONS_INTERFACE_ALL
        ( last_update_date, last_updated_by, creation_date,
          created_by, last_update_login, request_id,
          program_application_id, program_id, program_update_date,
          org_id,  /* Operating unit org */ preparer_id,
          interface_source_code, authorization_status, source_type_code,
          destination_organization_id, destination_type_code, item_id,
          item_revision, uom_code, quantity, line_type_id, charge_account_id,
          deliver_to_location_id, deliver_to_requestor_id, wip_entity_id,
          wip_line_id, wip_operation_seq_num, wip_resource_seq_num,
          bom_resource_id, wip_repetitive_schedule_id, need_by_date,
          autosource_flag, group_code, suggested_buyer_id,
          project_id, task_id, project_accounting_context
        )
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               FND_GLOBAL.CONC_REQUEST_ID,
               FND_GLOBAL.PROG_APPL_ID,
               FND_GLOBAL.CONC_PROGRAM_ID,
               SYSDATE,
               TO_NUMBER(hoi.ORG_INFORMATION3) operating_unit,
               fu.employee_id,
               'WIP',
               'APPROVED',
               'VENDOR',
               wor.organization_id,
               'SHOP FLOOR',
               br.purchase_item_id,
               DECODE (msi.revision_qty_control_code,
                 1, null ,
                 2, decode(br.purchase_item_id,
                      we.primary_item_id, DECODE (we.entity_type,
                        WIP_CONSTANTS.REPETITIVE, wrs.bom_revision,
                        /*Fixed bug2174078 to support eam and osfm*/
                        wdj.bom_revision),
                      BOM_REVISIONS.GET_ITEM_REVISION_FN (
                        x_released_revs_meaning,   -- eco_status
                        'ALL',                 -- examine_type
                         br.ORGANIZATION_ID,    -- org_id
                         br.purchase_item_id,   -- item_id
                         /*Fixed bug2174078 to support eam and osfm*/
                         decode (we.entity_type,-- rev_date
                           WIP_CONSTANTS.REPETITIVE, wrs.FIRST_UNIT_START_DATE,
                           /* Fixed for Bug1623063 */
                           wdj.SCHEDULED_START_DATE)))),
               msi.primary_uom_code,
               DECODE(msi.outside_operation_uom_type,
                 'RESOURCE',
                    DECODE(wor.BASIS_TYPE, WIP_CONSTANTS.PER_ITEM,
                      round (wor.usage_rate_or_amount * additional_quantity,6),
                      round(wor.usage_rate_or_amount,6)),
                 'ASSEMBLY',
                    DECODE(wor.BASIS_TYPE,
                      WIP_CONSTANTS.PER_ITEM, additional_quantity,1)),
               3,
               DECODE(we.entity_type,
                 WIP_CONSTANTS.REPETITIVE, wrs.OUTSIDE_PROCESSING_ACCOUNT,
                 wdj.OUTSIDE_PROCESSING_ACCOUNT),
               bd.location_id,
               fu.employee_id,
               wor.wip_entity_id,
               DECODE(we.entity_type,
                 WIP_CONSTANTS.REPETITIVE, wrs.line_id,
                 NULL),
               wor.operation_seq_num,
               wor.resource_seq_num,
               wor.resource_id,
               P_Repetitive_Schedule_Id,
               /* Fix Bug#2374334 */
               /* Bug 4398047 commented following portion of the sql
               DECODE(we.entity_type,
                 WIP_CONSTANTS.LOTBASED, bcd1.calendar_date,*/
                 (bcd3.calendar_date +
                  (DECODE(we.entity_type,
                     WIP_CONSTANTS.EAM, op1.last_unit_completion_date,
                     WIP_CONSTANTS.LOTBASED, op1.last_unit_completion_date, -- Bug 4398047 Added this line
                     DECODE(op1.next_operation_seq_num,
                       NULL, op1.last_unit_completion_date,
                       op2.first_unit_start_date)) -
                   TRUNC(DECODE(we.entity_type,
                     WIP_CONSTANTS.EAM, op1.last_unit_completion_date,
                     WIP_CONSTANTS.LOTBASED, op1.last_unit_completion_date, -- Bug 4398047 Added this line
                     DECODE(op1.next_operation_seq_num,
                       NULL, op1.last_unit_completion_date,
                       op2.first_unit_start_date))))), -- Bug 4398047 removed one matching bracket as decode was commented above
               'Y',
               NULL,
               msi.buyer_id,
               x_project_id,
               x_task_id,
               DECODE(x_project_id,NULL,NULL,'Y')
          FROM WIP_REPETITIVE_SCHEDULES wrs,
               HR_ORGANIZATION_INFORMATION hoi,
               -- BOM_CALENDAR_DATES bcd1, BOM_CALENDAR_DATES bcd2,-- Bug 4398047 removed bcd1 and bcd2
               BOM_CALENDAR_DATES bcd3, BOM_CALENDAR_DATES bcd4,
               FND_USER fu,  BOM_DEPARTMENTS bd,
               MTL_SYSTEM_ITEMS msi, BOM_RESOURCES br,
               MTL_PARAMETERS mp, WIP_OPERATION_RESOURCES wor,
               WIP_OPERATIONS op2, WIP_OPERATIONS op1,
               WIP_DISCRETE_JOBS wdj, WIP_ENTITIES we
         WHERE op1.organization_id = wor.organization_id
           AND op1.wip_entity_id = wor.wip_entity_id
           AND op1.operation_seq_num = wor.operation_seq_num
           AND decode(nvl(P_Resource_Seq_Num, -1),
                -1, -1, wor.resource_seq_num)
              = decode(nvl(P_Resource_Seq_Num, -1), -1, -1, P_Resource_Seq_Num)
           and NVL(wor.repetitive_schedule_id,-1) =
               NVL(P_repetitive_schedule_id, -1)
           and NVL(op1.repetitive_schedule_id,-1)=
               NVL(P_repetitive_schedule_id, -1)
           and op1.organization_id = P_organization_id
           and op1.wip_entity_id = P_wip_entity_id
           and op1.operation_seq_num = P_operation_seq_num
           and NVL(op2.repetitive_schedule_id,-1)=
               NVL(P_repetitive_schedule_id, -1)
           and op2.organization_id = op1.organization_id
           and op2.wip_entity_id = op1.wip_entity_id
           and wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                       WIP_CONSTANTS.PO_MOVE)
           and op2.operation_seq_num = NVL(op1.next_operation_seq_num,
                                           op1.operation_seq_num)
           AND wor.organization_id = br.organization_id
           AND wor.resource_id = br.resource_id
         /* Additional requisitions are created only
           for resources/assy of basis type ITEM.    */
           AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
           AND br.organization_id = msi.organization_id
           AND br.purchase_item_id = msi.inventory_item_id
           AND FND_GLOBAL.User_Id = fu.user_id
           AND op1.organization_id = bd.organization_id
           /*  Fix for bug 3092030: Corrected condition to ensure we insert
               correct deliver_to_location_id  */
           AND (  (wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT and
                   op1.department_id = bd.department_id)
               OR (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE and
                   op2.department_id = bd.department_id))
           AND mp.organization_id = op1.organization_id
           AND hoi.organization_id = op1.organization_id
           AND hoi.ORG_INFORMATION_CONTEXT = l_org_acct_ctxt
           AND we.wip_entity_id = op1.wip_entity_id
           AND we.organization_id = op1.organization_id
           AND wdj.wip_entity_id (+) = we.wip_entity_id
           AND wdj.organization_id (+) = we.organization_id
           AND wrs.repetitive_schedule_id (+) =
               NVL(P_repetitive_schedule_id, -1)
           AND wrs.organization_id (+) = we.organization_id
           /*  Bug 4398047 commenting out following portion of the sql
           AND bcd2.calendar_code = mp.calendar_code --  Fix for Bug#2374334
           AND bcd2.exception_set_id = mp.calendar_exception_set_id
           AND bcd2.calendar_date = trunc(SYSDATE)
           AND bcd1.calendar_code = mp.calendar_code
           AND bcd1.exception_set_id = mp.calendar_exception_set_id
           AND bcd1.seq_num = (bcd2.next_seq_num +
                CEIL(NVL(msi.preprocessing_lead_time,0) +
                     NVL(msi.fixed_lead_time,0) +
                    (NVL(msi.variable_lead_time,0) *
                      DECODE(msi.outside_operation_uom_type,
                        'RESOURCE',
                          DECODE(wor.basis_type, WIP_CONSTANTS.PER_ITEM,
                            wor.usage_rate_or_amount * op1.scheduled_quantity,
                           wor.usage_rate_or_amount),
                        'ASSEMBLY',
                          DECODE(wor.basis_type, WIP_CONSTANTS.PER_ITEM,
                            op1.scheduled_quantity,
                            1)
                     )) +
                     NVL(msi.postprocessing_lead_time,0))) end commenting out for Bug 4398047  */
           -- consider post processing lead time before inserting need-by-date
           AND bcd4.calendar_code = mp.calendar_code
           AND bcd4.exception_set_id = mp.calendar_exception_set_id
           AND bcd4.calendar_date =
               TRUNC(DECODE(we.entity_type,
                 WIP_CONSTANTS.EAM, op1.last_unit_completion_date,
                 WIP_CONSTANTS.LOTBASED, op1.last_unit_completion_date, -- Bug 4398047 Added this line
                 DECODE(op1.next_operation_seq_num,
                   NULL, op1.last_unit_completion_date,
                   op2.first_unit_start_date)))
           AND bcd3.calendar_code = mp.calendar_code
           AND bcd3.exception_set_id = mp.calendar_exception_set_id
           AND bcd3.seq_num = (bcd4.next_seq_num -
                               CEIL(NVL(msi.postprocessing_lead_time,0)));

    ELSE
      INSERT INTO PO_REQUISITIONS_INTERFACE_ALL
        ( last_update_date, last_updated_by, creation_date,
          created_by, last_update_login, request_id,
          program_application_id, program_id, program_update_date,
          org_id,  /* Operating unit org */ preparer_id,
          interface_source_code, authorization_status, source_type_code,
          destination_organization_id, destination_type_code, item_id,
          item_revision, uom_code, quantity, line_type_id, charge_account_id,
          deliver_to_location_id, deliver_to_requestor_id, wip_entity_id,
          wip_line_id, wip_operation_seq_num, wip_resource_seq_num,
          bom_resource_id, wip_repetitive_schedule_id, need_by_date,
          autosource_flag, group_code, suggested_buyer_id,
          project_id, task_id, project_accounting_context
        )
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               FND_GLOBAL.CONC_REQUEST_ID,
               FND_GLOBAL.PROG_APPL_ID,
               FND_GLOBAL.CONC_PROGRAM_ID,
               SYSDATE,
               TO_NUMBER(hoi.ORG_INFORMATION3) operating_unit,
               fu.employee_id,
               'WIP',
               'APPROVED',
               'VENDOR',
               wor.organization_id,
               'SHOP FLOOR',
               br.purchase_item_id,
               DECODE (msi.revision_qty_control_code,
                 1, null ,
                 2, decode(br.purchase_item_id,
                   we.primary_item_id, DECODE (we.entity_type,
                     WIP_CONSTANTS.REPETITIVE,wrs.bom_revision,
                     wdj.bom_revision),
                   BOM_REVISIONS.GET_ITEM_REVISION_FN (
                        x_released_revs_meaning,   -- eco_status
                    'ALL',                 -- examine_type
                     br.ORGANIZATION_ID,    -- org_id
                     br.purchase_item_id,   -- item_id
                     decode (we.entity_type,-- rev_date
                       WIP_CONSTANTS.REPETITIVE, wrs.FIRST_UNIT_START_DATE,
                       wdj.SCHEDULED_START_DATE)))), /* Fixed Bug# 1623063 */
               msi.primary_uom_code,
               DECODE(msi.outside_operation_uom_type,
                'RESOURCE',
                   DECODE(wor.BASIS_TYPE,
                     WIP_CONSTANTS.PER_ITEM, round (wor.usage_rate_or_amount *
                                                    op1.scheduled_quantity,6),
                     round(wor.usage_rate_or_amount,6)),
                'ASSEMBLY',
                   DECODE(wor.BASIS_TYPE,
                     WIP_CONSTANTS.PER_ITEM, op1.scheduled_quantity,1)),
               3,
               DECODE(we.entity_type,
                 WIP_CONSTANTS.REPETITIVE, wrs.OUTSIDE_PROCESSING_ACCOUNT,
                 wdj.OUTSIDE_PROCESSING_ACCOUNT),
               bd.location_id,
               fu.employee_id,
               wor.wip_entity_id,
               DECODE(we.entity_type,
                 WIP_CONSTANTS.REPETITIVE, wrs.line_id,
                 NULL),
               wor.operation_seq_num ,
               wor.resource_seq_num,
               wor.resource_id,
               P_Repetitive_Schedule_Id,
              /* Fix Bug#2374334 */
              /* Bug 4398047 Commented out following portion of the sql
               DECODE(we.entity_type,
                 WIP_CONSTANTS.LOTBASED, bcd1.calendar_date,*/
                 (bcd3.calendar_date +
                  (DECODE(we.entity_type,
                     WIP_CONSTANTS.EAM, op1.last_unit_completion_date,
                     WIP_CONSTANTS.LOTBASED, op1.last_unit_completion_date, -- Bug 4398047 Added this line
                     DECODE(op1.next_operation_seq_num,
                       NULL, op1.last_unit_completion_date,
                       op2.first_unit_start_date)) -
                   TRUNC(DECODE(we.entity_type,
                     WIP_CONSTANTS.EAM, op1.last_unit_completion_date,
                     WIP_CONSTANTS.LOTBASED, op1.last_unit_completion_date, -- Bug 4398047 Added this line
                     DECODE(op1.next_operation_seq_num,
                       NULL, op1.last_unit_completion_date,
                       op2.first_unit_start_date))))), -- Bug 4398047 Removed one matching bracket as decode was removed above
               'Y',
               NULL,
               msi.buyer_id,
               x_project_id,
               x_task_id,
               DECODE(x_project_id,NULL,NULL,'Y')
          FROM WIP_REPETITIVE_SCHEDULES wrs, /*MTL_ITEM_REVISIONS mir, */
               HR_ORGANIZATION_INFORMATION hoi,
               -- BOM_CALENDAR_DATES bcd1, BOM_CALENDAR_DATES bcd2, -- Bug 4398047 Commented out bcd1 and bcd2
               BOM_CALENDAR_DATES bcd3, BOM_CALENDAR_DATES bcd4,
               FND_USER fu,  BOM_DEPARTMENTS bd,
               MTL_SYSTEM_ITEMS msi, BOM_RESOURCES br,
               MTL_PARAMETERS mp, WIP_OPERATION_RESOURCES wor,
               WIP_OPERATIONS op2, WIP_OPERATIONS op1,
               WIP_DISCRETE_JOBS wdj, WIP_ENTITIES we
         WHERE op1.organization_id = wor.organization_id
           AND op1.wip_entity_id = wor.wip_entity_id
           AND op1.operation_seq_num = wor.operation_seq_num
           AND decode(nvl(P_Resource_Seq_Num, -1),
                -1, -1, wor.resource_seq_num)
               = decode(nvl(P_Resource_Seq_Num, -1),
                  -1, -1, P_Resource_Seq_Num)
           and NVL(wor.repetitive_schedule_id,-1)=
               NVL(P_repetitive_schedule_id, -1)
           and NVL(op1.repetitive_schedule_id,-1)=
               NVL(P_repetitive_schedule_id, -1)
           and op1.organization_id = P_organization_id
           and op1.wip_entity_id = P_wip_entity_id
           and op1.operation_seq_num = P_operation_seq_num
           and NVL(op2.repetitive_schedule_id,-1)=
               NVL(P_repetitive_schedule_id, -1)
           and op2.organization_id = op1.organization_id
           and op2.wip_entity_id = op1.wip_entity_id
           and wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                       WIP_CONSTANTS.PO_MOVE)
           and op2.operation_seq_num = NVL(op1.next_operation_seq_num,
                                           op1.operation_seq_num)
           AND wor.organization_id = br.organization_id
           AND wor.resource_id = br.resource_id
           AND br.organization_id = msi.organization_id
           AND br.purchase_item_id = msi.inventory_item_id
           AND FND_GLOBAL.User_Id = fu.user_id
           AND op1.organization_id = bd.organization_id
           /*  Fix for bug 3092030: Corrected condition to ensure we insert
               correct deliver_to_location_id  */
           AND (  (wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT and
                   op1.department_id = bd.department_id)
               OR (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE and
                   op2.department_id = bd.department_id))
           AND mp.organization_id = op1.organization_id
           AND hoi.organization_id = op1.organization_id
           AND hoi.ORG_INFORMATION_CONTEXT = l_org_acct_ctxt
           AND we.wip_entity_id = op1.wip_entity_id
           AND we.organization_id = op1.organization_id
           AND wdj.wip_entity_id (+) = we.wip_entity_id
           AND wdj.organization_id (+) = we.organization_id
           AND wrs.repetitive_schedule_id (+) =
               NVL (P_repetitive_schedule_id, -1)
           AND wrs.organization_id (+) = we.organization_id
        /* Bug 4398047 commented out the following portion of the sql
           AND bcd2.calendar_code = mp.calendar_code   -- Fix for Bug#2374334
           AND bcd2.exception_set_id = mp.calendar_exception_set_id
           AND bcd2.calendar_date =  trunc(SYSDATE)
           AND bcd1.calendar_code = mp.calendar_code
           AND bcd1.exception_set_id = mp.calendar_exception_set_id
           AND bcd1.seq_num = (bcd2.next_seq_num +
                CEIL(NVL(msi.preprocessing_lead_time,0) +
                     NVL(msi.fixed_lead_time,0) +
                    (NVL(msi.variable_lead_time,0) *
                      DECODE(msi.outside_operation_uom_type,
                        'RESOURCE',
                          DECODE(wor.basis_type, WIP_CONSTANTS.PER_ITEM,
                            wor.usage_rate_or_amount * op1.scheduled_quantity,
                           wor.usage_rate_or_amount),
                        'ASSEMBLY',
                          DECODE(wor.basis_type, WIP_CONSTANTS.PER_ITEM,
                            op1.scheduled_quantity,
                            1)
                     )) +
                     NVL(msi.postprocessing_lead_time,0)))  end of commented sql for bug 4398047 */
           -- consider post processing lead time before inserting need-by-date
           AND bcd4.calendar_code = mp.calendar_code
           AND bcd4.exception_set_id = mp.calendar_exception_set_id
           AND bcd4.calendar_date =
               TRUNC(DECODE(we.entity_type,
                 WIP_CONSTANTS.EAM, op1.last_unit_completion_date,
                 WIP_CONSTANTS.LOTBASED, op1.last_unit_completion_date, -- Bug 4398047 Added this line
                 DECODE(op1.next_operation_seq_num,
                   NULL, op1.last_unit_completion_date,
                   op2.first_unit_start_date)))
           AND bcd3.calendar_code = mp.calendar_code
           AND bcd3.exception_set_id = mp.calendar_exception_set_id
           AND bcd3.seq_num = (bcd4.next_seq_num -
                               CEIL(NVL(msi.postprocessing_lead_time,0)));
    END IF;

    IF (P_Run_ReqImport = WIP_CONSTANTS.YES) THEN

      -- get the OU, set context for MOAC
      select to_number(ORG_INFORMATION3) into l_ou_id
        from HR_ORGANIZATION_INFORMATION
       where ORGANIZATION_ID = p_organization_id
         and ORG_INFORMATION_CONTEXT = l_org_acct_ctxt;
      FND_REQUEST.SET_ORG_ID (l_ou_id);

      /*Fix for bug 8919025(Fp 8850950) */
 	       BEGIN
 	       select reqimport_group_by_code
 	       into l_req_import
 	       from po_system_parameters_all
 	       where org_id = l_ou_id;
 	       EXCEPTION
 	       WHEN NO_DATA_FOUND THEN
 	       raise fnd_api.g_exc_unexpected_error;
 	       END;

      l_success := fnd_request.submit_request(
        'PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, l_req_import, --Fix for bug 8919025(Fp 8850950)
        NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;
    END IF;

  END CREATE_REQUISITION;

  /* Create additional PO requisitions */
  PROCEDURE  CREATE_ADDITIONAL_REQ
    (P_Wip_Entity_Id NUMBER,
     P_Organization_id NUMBER,
     P_Repetitive_Schedule_Id NUMBER,
     P_Added_Quantity NUMBER,
     P_Op_Seq NUMBER default null) IS

  BEGIN

  Additional_Quantity:=P_Added_Quantity;

  IF P_Op_Seq is NULL then

    RELEASE_VALIDATION(P_Wip_Entity_Id,
                       P_Organization_id,
                       P_Repetitive_Schedule_Id);
  ELSE
    CREATE_REQUISITION(
      P_Wip_Entity_Id => P_Wip_Entity_Id,
      P_Organization_Id => P_Organization_id,
      P_Repetitive_Schedule_Id => P_Repetitive_Schedule_Id,
      P_Operation_Seq_Num => P_Op_Seq);
  END IF;

  Additional_Quantity:=0; -- As this is a global variable it has to be
                          -- reinitialized immediately.

  END CREATE_ADDITIONAL_REQ;

  FUNCTION PO_REQ_EXISTS (p_wip_entity_id    in NUMBER,
                          p_rep_sched_id     in NUMBER,
                          p_organization_id  in NUMBER,
                          p_op_seq_num       in NUMBER default NULL,
                          p_entity_type      in NUMBER
                         ) RETURN BOOLEAN IS
  /* Bug 4057595 - Modified the following cursors to consider
     Finally Closed POR/PO/PO LINE/SHIPMENT.
  */

  CURSOR disc_check_po_req_cur IS
    SELECT 'PO/REQ Linked'
      FROM PO_RELEASES_ALL PR,
           PO_HEADERS_ALL PH,
           PO_DISTRIBUTIONS_ALL PD,
           PO_LINE_LOCATIONS_ALL PLL   /* Added as part of Bug2308832 */             /* Fixed bug 3115844 */
     WHERE pd.po_line_id IS NOT NULL
       AND pd.line_location_id IS NOT NULL
       AND PD.WIP_ENTITY_ID = p_wip_entity_id
       AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND (p_op_seq_num is NULL OR PD.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
       AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
       AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID /* Added as part of Bug 2308832 */
       AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
       -- check cancel flag at shipment level instead of at header level
       -- because PO will cancel upto shipment level
       AND (pll.cancel_flag IS NULL OR
            pll.cancel_flag = 'N')
--       AND ((PH.TYPE_LOOKUP_CODE = 'STANDARD' AND
--             nvl(PH.CANCEL_FLAG,'N') ='N')
--             OR
--            (PH.TYPE_LOOKUP_CODE = 'BLANKET' AND
--             PR.PO_RELEASE_ID = PD.PO_RELEASE_ID AND
--             nvl(PR.CANCEL_FLAG, 'N') = 'N'))
           /*Added as part of Bug 2308832 */
       AND (PLL.QUANTITY_RECEIVED < (PLL.QUANTITY-PLL.QUANTITY_CANCELLED))
       AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED'
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITION_LINES_ALL PRL
     WHERE PRL.WIP_ENTITY_ID = p_wip_entity_id
       AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND (p_op_seq_num is NULL OR
            PRL.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
       AND nvl(PRL.cancel_flag, 'N') = 'N'
       AND PRL.LINE_LOCATION_ID is NULL  /* added as part of 2740352 */
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITIONS_INTERFACE_ALL PRI
     WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
       AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND (p_op_seq_num is NULL OR PRI.WIP_OPERATION_SEQ_NUM = p_op_seq_num);


  CURSOR rep_check_po_req_cur IS
    SELECT 'PO/REQ Linked'
      FROM PO_RELEASES_ALL PR,
           PO_HEADERS_ALL PH,
           PO_DISTRIBUTIONS_ALL PD,
           PO_LINE_LOCATIONS_ALL PLL
           /* Fixed bug 3115844 */
     WHERE pd.po_line_id IS NOT NULL
       AND pd.line_location_id IS NOT NULL
       AND PD.WIP_ENTITY_ID = p_wip_entity_id
       AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND PD.WIP_REPETITIVE_SCHEDULE_ID = p_rep_sched_id
       AND (p_op_seq_num is NULL OR PD.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
       AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
       AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
       AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
       -- check cancel flag at shipment level instead of at header level
       -- because PO will cancel upto shipment level
       AND (pll.cancel_flag IS NULL OR
            pll.cancel_flag = 'N')
       AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED'
--       AND ((PH.TYPE_LOOKUP_CODE = 'STANDARD' AND
--             nvl(PH.CANCEL_FLAG, 'N') = 'N' )
--             OR
--            (PH.TYPE_LOOKUP_CODE = 'BLANKET' AND
--             nvl(PR.CANCEL_FLAG, 'N') = 'N'))
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITION_LINES_ALL PRL
     WHERE PRL.WIP_ENTITY_ID = p_wip_entity_id
       AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND PRL.WIP_REPETITIVE_SCHEDULE_ID = p_rep_sched_id
       AND (p_op_seq_num is NULL OR
            PRL.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
       AND nvl(PRL.cancel_flag, 'N') = 'N'
   UNION ALL
    SELECT 'PO/REQ Linked'
      FROM PO_REQUISITIONS_INTERFACE_ALL PRI
     WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
       AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
       AND PRI.WIP_REPETITIVE_SCHEDULE_ID = p_rep_sched_id
       AND (p_op_seq_num is NULL OR PRI.WIP_OPERATION_SEQ_NUM = p_op_seq_num);

  po_req_exist VARCHAR2(20);

  begin
  IF(p_entity_type = WIP_CONSTANTS.REPETITIVE) THEN
    OPEN rep_check_po_req_cur;
    FETCH rep_check_po_req_cur INTO po_req_exist;

    IF (rep_check_po_req_cur%FOUND) THEN
      CLOSE rep_check_po_req_cur;
      RETURN TRUE;
    ELSE
      CLOSE rep_check_po_req_cur;
      RETURN FALSE;
    END IF;
  ELSE  /*FOR DISCRETE, OSFM, AND EAM*/
    OPEN disc_check_po_req_cur;
    FETCH disc_check_po_req_cur INTO po_req_exist;

    IF (disc_check_po_req_cur%FOUND) THEN
      CLOSE disc_check_po_req_cur;
      return TRUE;
    ELSE
      CLOSE disc_check_po_req_cur;
      return FALSE;
    END IF;
  END IF;  -- End check POs and REQs
 END PO_REQ_EXISTS;

 FUNCTION ConvertToPrimaryMoveQty (p_item_id               NUMBER,
                                   p_organization_id       NUMBER,
                                   p_quantity              NUMBER,
                                   p_uom_code              VARCHAR2,
                                   p_primary_uom_code      VARCHAR2,
                                   p_usage_rate_or_amount  NUMBER
                                  ) RETURN NUMBER IS

   l_primary_qty        NUMBER;
   l_move_qty           NUMBER;

 BEGIN
   select decode (msi.outside_operation_uom_type,
            'ASSEMBLY', inv_convert.inv_um_convert(
                          p_item_id,    -- item_id
                          NULL,         -- precision
                          p_quantity,   -- from_quantity
                          NULL,         -- from_unit
                          NULL,         -- to_unit
                          p_uom_code,   -- from_name
                          p_primary_uom_code), -- to_name
            decode (nvl(p_usage_rate_or_amount, 0) ,
              0, 0,
              p_quantity/p_usage_rate_or_amount))
     into l_move_qty
     from mtl_system_items msi
    where msi.inventory_item_id = p_item_id
      and msi.organization_id = p_organization_id;

   --apparently this value indicates an error condition
   if(l_move_qty = -99999) then
     return null;
   end if;
   return l_move_qty;
 END ConvertToPrimaryMoveQty;

  FUNCTION IS_ORDER_OPEN(approved_flag        VARCHAR2 := NULL,
                        closed_code          VARCHAR2 := NULL,
                        line_closed_status   VARCHAR2 := NULL,
                        cancel_flag          VARCHAR2 := NULL,
                        frozen_flag          VARCHAR2 := NULL,
                        user_hold_flag       VARCHAR2 := NULL,
                        line_expiration_date DATE     := NULL,
                        line_cancel_flag     VARCHAR2 := NULL
                       )Return VARCHAR2 AS

    BEGIN
      if((approved_flag = 'Y') AND
        (nvl(closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')) AND
        (nvl(line_closed_status,'OPEN') not in ('FINALLY CLOSED', 'CLOSED'))AND
        (nvl(cancel_flag,'N') = 'N') AND
        (nvl(frozen_flag,'N') = 'N') AND
        (nvl(user_hold_flag, 'N') = 'N') AND
        (trunc(nvl(line_expiration_date, sysdate + 1)) > trunc(sysdate)) AND
        (nvl(line_cancel_flag,'N') = 'N')) then
        return 'Y';
      else
        return 'N';
      end if;
  END IS_ORDER_OPEN;

  PROCEDURE ARE_QA_PLANS_AVAILABLE(
    P_AssemblyItemNumber      IN  VARCHAR2 DEFAULT NULL,
    P_VendorName              IN  VARCHAR2 DEFAULT NULL,
    P_WipEntityName           IN  VARCHAR2 DEFAULT NULL,
    P_BasePoNum               IN  VARCHAR2 DEFAULT NULL,
    P_SupplierItemNumber      IN  VARCHAR2 DEFAULT NULL,
    P_AssemblyPrimaryUom      IN  VARCHAR2 DEFAULT NULL,
    P_Uom                     IN  VARCHAR2 DEFAULT NULL,
    P_WipLineCode             IN  VARCHAR2 DEFAULT NULL,
    P_BomRevision             IN  VARCHAR2 DEFAULT NULL,
    P_StartDate               IN  DATE     DEFAULT NULL,
    P_PoReleaseNumber         IN  NUMBER   DEFAULT NULL,
    P_OrganizationId          IN  NUMBER   DEFAULT NULL,
    P_WipEntityType           IN  NUMBER   DEFAULT NULL,
    P_WipEntityId             IN  NUMBER   DEFAULT NULL,
    P_WipRepetitiveScheduleId IN  NUMBER   DEFAULT NULL,
    P_ResourceSeqNum          IN  NUMBER   DEFAULT NULL,
    P_ItemId                  IN  NUMBER   DEFAULT NULL,
    P_AssemblyItemId          IN  NUMBER   DEFAULT NULL,
    P_WipOperationSeqNum      IN  NUMBER   DEFAULT NULL,
    R_QaAvailable             OUT NOCOPY VARCHAR2) IS

    l_qty   NUMBER;
    l_usage wip_operation_resources.usage_rate_or_amount%TYPE;
    l_rev   VARCHAR2(30);
    x_released_revs_type                NUMBER ;
    x_released_revs_meaning     Varchar2(30);


  BEGIN
    SELECT wor.usage_rate_or_amount
      INTO l_usage
      FROM wip_operation_resources wor
     WHERE wor.wip_entity_id = P_WipEntityId
       and NVL(wor.repetitive_schedule_id, -1) =
           NVL(P_WipRepetitiveScheduleId, -1)
       and wor.operation_seq_num = P_WipOperationSeqNum
       and wor.organization_id = P_OrganizationId
       and wor.resource_seq_num = P_ResourceSeqNum;

     l_qty := WIP_OSP.ConvertToPrimaryMoveQty(
                 p_item_id              => P_ItemId,
                 p_organization_id      => P_OrganizationId,
                 p_quantity             => P_AssemblyItemId,
                 p_uom_code             => P_Uom,
                 p_primary_uom_code     => P_AssemblyPrimaryUom,
                 p_usage_rate_or_amount => l_usage);

          wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                     x_released_revs_meaning
                                                    );


    IF(P_ItemId = P_AssemblyItemId) THEN
      l_rev := P_BomRevision;
    ELSE
      l_rev := BOM_REVISIONS.GET_ITEM_REVISION_FN(
                 eco_status   => x_released_revs_meaning,
                 examine_type => 'ALL',
                 org_id       => P_OrganizationId,
                 item_id      => P_ItemId,
                 rev_date     => P_StartDate);
    END IF;

    R_QaAvailable := QA_SS_OSP.are_osp_plans_applicable(
         P_Item_Number           => P_AssemblyItemNumber,
         P_Supplier              => P_VendorName,
         P_Wip_Entity_Name       => P_WipEntityName,
         P_Po_Number             => P_BasePoNum,
         P_Vendor_Item_Number    => P_SupplierItemNumber,
         P_Wip_Operation_Seq_Num => P_WipOperationSeqNum,
         P_UOM_Name              => P_AssemblyPrimaryUom,
         P_Production_Line       => P_WipLineCode,
         P_Quantity_Ordered      => l_qty,
         P_Item_Revision         => l_rev,
         P_Po_Release_Number     => P_PoReleaseNumber,
         P_Organization_Id       => P_OrganizationId,
         P_Wip_Entity_type       => P_WipEntityId);
  END ARE_QA_PLANS_AVAILABLE;


 /**
  * This function validates the from op and to op for the user relating to
  * OSP operation steps.  The follow rules apply to OSP:
  *   -  Users cannot move into a Queue of an OSP operation unless that
  *      department has a location setup.
  *   -  Users cannot move forward into a queue of an operation that has
  *      PO resource unless the user is an employee
  * The error message for the first case would be WIP_PO_MOVE_LOCATION and
  * WIP_VALID_EMPLOYEE for the second case.
  * Parameters:
  *   p_orgID         The organization identifier.
  *   p_wipEntityID   The wip entity identifier.
  *   p_lineID        The line id used only for repetitive schedule. For
  *                   discrete and lotbased, do not need to pass this value.
  *   p_entityType    The wip entity type. (usually discrete)
  *   p_fmOpSeqNum    The from operation sequence number that user is moving.
  *   p_toOpSeqNum    The to operation sequence number that user is moving.
  *   p_toStep        The to intraoperation step that user is moving to.
  *   userID          The user identifier.
  *   error           The error message stack for displaying error to user.
  * Return:
  *   boolean     A flag indicating whether update successful or not.
  */
  FUNCTION checkOSP(p_orgID             NUMBER,
                    p_wipEntityID       NUMBER,
                    p_lineID            NUMBER := NULL,
                    p_entityType        NUMBER,
                    p_fmOpSeqNum        NUMBER,
                    p_toOpSeqNum        NUMBER,
                    p_toStep            NUMBER,
                    p_userID            NUMBER,
                    x_msg           OUT NOCOPY VARCHAR2,
                    x_error         OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

  CURSOR check_osp(c_org_id          NUMBER,
                   c_wip_entity_id   NUMBER,
                   c_entity_type     NUMBER,
                   c_line_id         NUMBER,
                   c_fm_op           NUMBER,
                   c_to_op           NUMBER,
                   c_to_step         NUMBER,
                   c_user_id         NUMBER) IS

    -- you cannot move into a queue of operation unless that department
    -- has a location set up
    SELECT 'WIP_PO_MOVE_LOCATION' error_message
      FROM bom_departments bd,
           wip_operation_resources wor,
           wip_operations wo1,
           wip_operations wo2
     WHERE wor.organization_id = c_org_id
       AND wor.wip_entity_id = c_wip_entity_id
       AND wor.operation_seq_num = c_to_op
       AND c_fm_op < c_to_op
       AND c_to_step = WIP_CONSTANTS.QUEUE
       AND (c_entity_type IN (WIP_CONSTANTS.DISCRETE,
                              WIP_CONSTANTS.LOTBASED)
            OR
           (c_entity_type = WIP_CONSTANTS.REPETITIVE AND
            wor.repetitive_schedule_id IN
              (SELECT wrs.repetitive_schedule_id
                 FROM wip_repetitive_schedules wrs
                WHERE wrs.wip_entity_id = c_wip_entity_id
                  AND wrs.organization_id = c_org_id
                  AND wrs.line_id = c_line_id
                  AND wrs.status_type in (WIP_CONSTANTS.RELEASED,
                                          WIP_CONSTANTS.COMP_CHRG)
               )
           ))
       AND wo1.organization_id = wor.organization_id
       AND wo1.wip_entity_id = wor.wip_entity_id
       AND NVL(wo1.repetitive_schedule_id,-1) =
           NVL(wor.repetitive_schedule_id,-1)
       AND wo1.operation_seq_num = wor.operation_seq_num
       AND wo2.organization_id = wo1.organization_id
       AND wo2.wip_entity_id = wo1.wip_entity_id
       AND NVL(wo2.repetitive_schedule_id,-1) =
           NVL(wo1.repetitive_schedule_id,-1)
       AND ((wor.autocharge_type = WIP_CONSTANTS.PO_RECEIPT AND
             wo2.operation_seq_num = wor.operation_seq_num)
             OR
            (wor.autocharge_type = WIP_CONSTANTS.PO_MOVE AND
            ((wo1.next_operation_seq_num IS NOT NULL AND
              wo1.next_operation_seq_num = wo2.operation_seq_num)
              OR
             (wo1.next_operation_seq_num IS NULL AND
              wo2.operation_seq_num = wor.operation_seq_num)
            )))
       AND bd.organization_id = c_org_id
       AND wo2.department_id = bd.department_id
       AND bd.location_id IS NULL

    UNION ALL

    -- you cannot forward move into a queue of operation that has
    -- PO resources unless you are an employee
    SELECT 'WIP_VALID_EMPLOYEE' error_message
      FROM wip_operation_resources wor
     WHERE wor.organization_id = c_org_id
       AND wor.wip_entity_id = c_wip_entity_id
       AND wor.operation_seq_num = c_to_op
       AND c_fm_op < c_to_op
       AND c_to_step = WIP_CONSTANTS.QUEUE
       AND wor.autocharge_type IN (WIP_CONSTANTS.PO_RECEIPT,
                                   WIP_CONSTANTS.PO_MOVE)
       AND (c_entity_type IN (WIP_CONSTANTS.DISCRETE,
                              WIP_CONSTANTS.LOTBASED)
            OR
            (c_entity_type = WIP_CONSTANTS.REPETITIVE AND
             wor.repetitive_schedule_id IN
               (SELECT repetitive_schedule_id
                  FROM wip_repetitive_schedules wrs
                 WHERE wrs.organization_id = c_org_id
                   AND wrs.wip_entity_id = c_wip_entity_id
                   AND wrs.line_id = c_line_id
                   AND wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                                           WIP_CONSTANTS.COMP_CHRG)
                )
             ))
       AND NOT EXISTS
           (SELECT 'Current user is an employee'
              FROM fnd_user fu,
                   per_people_f ppf
             WHERE fu.user_id = c_user_id
               AND fu.employee_id = ppf.person_id);

  result NUMBER;
  l_found boolean;
  l_msg VARCHAR2(80);
  BEGIN
    open check_osp(
      c_org_id               => p_orgID,
      c_wip_entity_id        => p_wipEntityID,
      c_entity_type          => p_entityType,
      c_line_id              => p_lineID,
      c_fm_op                => p_fmOpSeqNum,
      c_to_op                => p_toOpSeqNum,
      c_to_step              => p_toStep,
      c_user_id              => p_userID);
    fetch check_osp into l_msg;
    l_found := check_osp%FOUND;
    close check_osp;

    if (l_found) then
      -- cannot perform move
      fnd_message.set_name('WIP', l_msg);
      x_error := substrb(fnd_message.get, 1, 240);
      x_msg := l_msg;
      return false;
    end if;
    return (TRUE);
  END checkOSP;

  PROCEDURE updatePOReqNBDManager(errbuf            OUT NOCOPY VARCHAR2,
                                  retcode           OUT NOCOPY NUMBER,
                                  p_project_id      IN         NUMBER,
                                  p_task_id         IN         NUMBER,
                                  p_days_forward_fm IN         NUMBER,
                                  p_days_forward_to IN         NUMBER,
                                  p_org_id          IN         NUMBER,
                                  p_entity_type     IN         NUMBER) IS
  CURSOR c_job_schedule IS
    SELECT wdj.wip_entity_id job_id,
           to_number(null) rep_schedule_id
      FROM wip_discrete_jobs wdj
     WHERE wdj.status_type IN (WIP_CONSTANTS.RELEASED,
                               WIP_CONSTANTS.UNRELEASED,
                               WIP_CONSTANTS.HOLD)
       AND (p_project_id IS NULL OR wdj.project_id  = p_project_id)
       AND (p_task_id IS NULL OR wdj.task_id = p_task_id)
       AND wdj.organization_id = p_org_id
       AND p_entity_type <> WIP_CONSTANTS.REPETITIVE
      UNION ALL
    SELECT wrs.wip_entity_id job_id,
           wrs.repetitive_schedule_id rep_schedule_id
      FROM wip_repetitive_schedules wrs
     WHERE wrs.status_type IN (WIP_CONSTANTS.RELEASED,
                               WIP_CONSTANTS.UNRELEASED,
                               WIP_CONSTANTS.HOLD)
       AND wrs.organization_id = p_org_id
       AND p_entity_type = WIP_CONSTANTS.REPETITIVE;

  CURSOR c_po_req (p_job_id NUMBER,
                   p_repetitive_id NUMBER) IS
    SELECT pd.po_header_id po_header_id,
           to_number(null) po_release_id,
           pd.line_location_id po_line_location_id,
           to_number(null) req_header_id,
           to_number(null) req_line_id,
           ph.type_lookup_code po_req_type,
           ph.authorization_status approval_status,
           pll.need_by_date old_need_by_date,
           pd.wip_operation_seq_num wip_op_seq,
           pl.item_id item_id,
           pd.org_id ou_id -- operating unit
      FROM po_distributions_all pd,
           po_headers_all ph,
           po_lines_all pl,
           po_line_locations_all pll,
           po_line_types plt
     WHERE ph.type_lookup_code = 'STANDARD'
       AND ph.po_header_id = pd.po_header_id
       AND pd.po_line_id = pl.po_line_id
       AND pd.line_location_id = pll.line_location_id
       AND pl.line_type_id = plt.line_type_id
       AND plt.outside_operation_flag = 'Y'
       AND pd.wip_entity_id = p_job_id
       AND pd.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND (ph.authorization_status IS NULL OR -- INCOMPLETE
            ph.authorization_status IN ('INCOMPLETE',
                                        'APPROVED',
                                        'REQUIRES REAPPROVAL'))
       AND (pll.cancel_flag IS NULL OR pll.cancel_flag = 'N')
  UNION ALL
    SELECT pd.po_header_id po_header_id,
           pr.po_release_id po_release_id,
           pd.line_location_id po_line_location_id,
           to_number(null) req_header_id,
           to_number(null) req_line_id,
           ph.type_lookup_code po_req_type,
           pr.authorization_status approval_status,
           pll.need_by_date old_need_by_date,
           pd.wip_operation_seq_num wip_op_seq,
           pl.item_id item_id,
           pd.org_id ou_id -- operating unit
      FROM po_distributions_all pd,
           po_headers_all ph,
           po_lines_all pl,
           po_line_locations_all pll,
           po_releases_all pr,
           po_line_types plt
     WHERE ph.type_lookup_code = 'BLANKET'
       AND pr.po_release_id = pll.po_release_id
       AND pr.po_header_id = ph.po_header_id
       AND ph.po_header_id = pd.po_header_id
       AND pd.po_line_id = pl.po_line_id
       AND pd.line_location_id = pll.line_location_id
       AND pl.line_type_id = plt.line_type_id
       AND plt.outside_operation_flag = 'Y'
       AND pd.wip_entity_id = p_job_id
       AND pd.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND (pr.authorization_status IS NULL OR -- INCOMPLETE
            pr.authorization_status IN ('INCOMPLETE',
                                        'APPROVED',
                                        'REQUIRES REAPPROVAL'))
       AND (pll.cancel_flag IS NULL OR pll.cancel_flag = 'N')
  UNION ALL
    SELECT to_number(null) po_header_id,
           to_number(null) po_release_id,
           to_number(null) po_line_location_id,
           prl.requisition_header_id req_header_id,
           prl.requisition_line_id req_line_id,
           'REQUISITION' po_req_type,
           prh.authorization_status approval_status,
           prl.need_by_date old_need_by_date,
           prl.wip_operation_seq_num wip_op_seq,
           prl.item_id item_id,
           prl.org_id ou_id -- operating unit
      FROM po_requisition_headers_all prh,
           po_requisition_lines_all prl,
           po_line_types plt
     WHERE NOT EXISTS
          (SELECT 'x'
             FROM po_line_locations_all pll
            WHERE prl.line_location_id = pll.line_location_id)
       AND prh.requisition_header_id = prl.requisition_header_id
       AND prl.line_type_id = plt.line_type_id
       AND plt.outside_operation_flag = 'Y'
       AND prl.wip_entity_id = p_job_id
       AND prl.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            prl.wip_repetitive_schedule_id = p_repetitive_id)
       AND (prl.cancel_flag IS NULL OR prl.cancel_flag = 'N');

  CURSOR c_new_NBD (p_job_id NUMBER,
                    p_repetitive_id NUMBER,
                    p_op_seq NUMBER,
                    p_item_id NUMBER) IS
    SELECT (bcd1.calendar_date +
            (DECODE( p_entity_type,
               WIP_CONSTANTS.EAM, wo1.last_unit_completion_date,
               DECODE(wo1.next_operation_seq_num,
                 NULL, wo1.last_unit_completion_date,
                 wo2.first_unit_start_date)) -
             TRUNC(DECODE( p_entity_type,
                     WIP_CONSTANTS.EAM, wo1.last_unit_completion_date,
                     DECODE(wo1.next_operation_seq_num,
                       NULL, wo1.last_unit_completion_date,
                       wo2.first_unit_start_date))))) new_need_by_date
      FROM bom_calendar_dates bcd1,
           bom_calendar_dates bcd2,
           mtl_system_items msi,
           mtl_parameters mp,
           wip_operations wo1,
           wip_operations wo2
     WHERE mp.organization_id = p_org_id
       AND mp.organization_id = msi.organization_id
       AND msi.inventory_item_id = p_item_id
       AND wo1.organization_id = mp.organization_id
       AND wo1.wip_entity_id = p_job_id
       AND wo1.operation_seq_num = p_op_seq
       AND (p_repetitive_id IS NULL OR
            wo1.repetitive_schedule_id = p_repetitive_id)
       AND wo2.organization_id = wo1.organization_id
       AND wo2.wip_entity_id = wo1.wip_entity_id
       AND ((wo1.next_operation_seq_num IS NOT NULL AND
             wo2.operation_seq_num = wo1.next_operation_seq_num)
             OR
            (wo1.next_operation_seq_num IS NULL AND
             wo2.operation_seq_num = p_op_seq))
       -- consider post processing lead time before inserting need-by-date
       AND bcd2.calendar_code = mp.calendar_code
       AND bcd2.exception_set_id = mp.calendar_exception_set_id
       AND bcd2.calendar_date =
           TRUNC(DECODE( p_entity_type,
             WIP_CONSTANTS.EAM, wo1.last_unit_completion_date,
             DECODE(wo1.next_operation_seq_num,
               NULL, wo1.last_unit_completion_date,
               wo2.first_unit_start_date)))
       AND bcd1.calendar_code = mp.calendar_code
       AND bcd1.exception_set_id = mp.calendar_exception_set_id
       AND bcd1.seq_num = (bcd2.next_seq_num -
                           CEIL(NVL(msi.postprocessing_lead_time,0)));

  l_job_schedule c_job_schedule%ROWTYPE;
  l_po_req c_po_req%ROWTYPE;
  l_new_NBD c_new_NBD%ROWTYPE;
  l_early_nbd NUMBER;
  l_late_nbd NUMBER;
  l_return_status VARCHAR2(1);
  l_fm_date DATE;
  l_to_date DATE;
  BEGIN
    retcode := 0; -- success
    IF(po_code_release_grp.Current_Release >=
       po_code_release_grp.PRC_11i_Family_Pack_J) THEN
      -- set l_fm_date,and l_to_date
      l_fm_date := trunc(sysdate + p_days_forward_fm);
      l_to_date := trunc(sysdate + p_days_forward_to) + (1 - (1/(24*3600)));

      SELECT early_need_by_date_tolerance,
             late_need_by_date_tolerance
        INTO l_early_nbd,
             l_late_nbd
        FROM wip_parameters
       WHERE organization_id = p_org_id;

      FOR l_job_schedule IN c_job_schedule LOOP
        FOR l_po_req IN c_po_req(
                          p_job_id        => l_job_schedule.job_id,
                          p_repetitive_id =>l_job_schedule.rep_schedule_id)LOOP
          FOR l_new_NBD IN c_new_NBD(
                             p_job_id        => l_job_schedule.job_id,
                             p_repetitive_id => l_job_schedule.rep_schedule_id,
                             p_op_seq        => l_po_req.wip_op_seq,
                             p_item_id       => l_po_req.item_id) LOOP
            IF((l_new_NBD.new_need_by_date >= l_fm_date) AND
               (l_new_NBD.new_need_by_date <= l_to_date) AND
               (l_new_NBD.new_need_by_date  <
                l_po_req.old_need_by_date - l_early_nbd
                OR
                l_new_NBD.new_need_by_date  >
                l_po_req.old_need_by_date + l_late_nbd)) THEN

              wip_osp.updatePOReqNBD (
                p_po_header_id        => l_po_req.po_header_id,
                p_po_release_id       => l_po_req.po_release_id,
                p_po_line_location_id => l_po_req.po_line_location_id,
                p_req_header_id       => l_po_req.req_header_id,
                p_req_line_id         => l_po_req.req_line_id,
                p_po_req_type         => l_po_req.po_req_type,
                p_approval_status     => l_po_req.approval_status,
                p_new_NBD             => l_new_NBD.new_need_by_date,
                p_ou_id               => l_po_req.ou_id,
                x_return_status       => l_return_status);
            -- No need to check return status because the PO that we cannot
            -- update now will be picked up by the next concurrent program.
            END IF; -- check new need-by date
          END LOOP; -- new NBD
        END LOOP; -- for each PO associated to the job
      END LOOP; -- for each job
    ELSE
      -- Customers do not have PO FPJ
      retcode := 1; -- warning
      fnd_message.set_name('WIP','WIP_MISSING_PO_FPJ_ONWARD');
      errbuf  := fnd_message.get;
    END IF;
  EXCEPTION
    WHEN others THEN
      retcode := 2; -- error
      errbuf  := SQLERRM;
  END updatePOReqNBDManager;

  PROCEDURE updatePOReqNBD(p_po_header_id        IN         NUMBER,
                           p_po_release_id       IN         NUMBER,
                           p_po_line_location_id IN         NUMBER,
                           p_req_header_id       IN         NUMBER,
                           p_req_line_id         IN         NUMBER,
                           p_po_req_type         IN         VARCHAR2,
                           p_approval_status     IN         VARCHAR2,
                           p_new_NBD             IN         DATE,
                           p_ou_id               IN         NUMBER,
                           x_return_status       OUT NOCOPY VARCHAR2) IS

  l_params       wip_logger.param_tbl_t;
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
  l_returnStatus VARCHAR2(1);
  l_errMsg       VARCHAR2(240);
  l_msgCount     NUMBER;
  l_msgData      VARCHAR2(2000);
  l_po_changes   PO_CHANGES_REC_TYPE;
  l_errors_rec   PO_API_ERRORS_REC_TYPE;
  l_req_changes  PO_REQ_CHANGES_REC_TYPE;

  BEGIN
    -- write parameter value to log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName   := 'p_po_header_id';
      l_params(1).paramValue  :=  p_po_header_id;
      l_params(2).paramName   := 'p_po_release_id';
      l_params(2).paramValue  :=  p_po_release_id;
      l_params(3).paramName   := 'p_po_line_location_id';
      l_params(3).paramValue  :=  p_po_line_location_id;
      l_params(4).paramName   := 'p_req_header_id';
      l_params(4).paramValue  :=  p_req_header_id;
      l_params(5).paramName   := 'p_req_line_id';
      l_params(5).paramValue  :=  p_req_line_id;
      l_params(6).paramName   := 'p_po_req_type';
      l_params(6).paramValue  :=  p_po_req_type;
      l_params(7).paramName   := 'p_approval_status';
      l_params(7).paramValue  :=  p_approval_status;
      l_params(8).paramName   := 'p_new_NBD';
      l_params(8).paramValue  :=  p_new_NBD;
      l_params(9).paramName   := 'p_ou_id';
      l_params(9).paramValue  :=  p_ou_id;
      wip_logger.entryPoint(p_procName => 'wip_osp.updatePOReqNBD',
                            p_params   => l_params,
                            x_returnStatus => l_returnStatus);
    END IF;

    SAVEPOINT s_update_po_nbd;
    x_return_status := fnd_api.g_ret_sts_success;
    -- Set OU context before calling PO API. This change is mandatory for
    -- MOAC change in R12.
    mo_global.set_policy_context('S',p_ou_id);
    -- Update PO need by date and promise date
    IF(p_po_req_type IN('STANDARD', 'BLANKET')) THEN
      IF(p_approval_status IS NULL OR -- INCOMPLETE
         p_approval_status IN('INCOMPLETE',
                              'APPROVED',
                              'REQUIRES REAPPROVAL')) THEN
        -- Call PO API to update NBD. This API will notify supplier after
        -- the PO get approved. Supplier will then change promise date
        -- through iSupplier or communicate the change to buyer if they can
        -- accommodate the new change
        l_po_changes := PO_CHANGES_REC_TYPE.create_object(
                          p_po_header_id  => p_po_header_id,
                          p_po_release_id => p_po_release_id);

        l_po_changes.shipment_changes.add_change(
          p_po_line_location_id => p_po_line_location_id,
          p_need_by_date        => p_new_NBD);

        po_wip_integration_grp.update_document(
          p_api_version           => 1.0,
          p_init_msg_list         => fnd_api.g_true,
          p_changes               => l_po_changes,
          p_run_submission_checks => fnd_api.g_true,
          p_launch_approvals_flag => fnd_api.g_true,
          p_buyer_id              => NULL,
          p_update_source         => NULL,
          p_override_date         => NULL,
          x_return_status         => x_return_status,
          x_api_errors            => l_errors_rec);

        IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
          FOR i IN 1..l_errors_rec.message_name.count LOOP
            fnd_message.set_name('PO', l_errors_rec.message_name(i));
            fnd_msg_pub.add;
          END LOOP;
          raise fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE -- PO in status that do not allow update
        fnd_message.set_name('WIP', 'WIP_INVALID_PO_STATUS');
        fnd_msg_pub.add;
        l_errMsg    := 'PO is in status that does not allow update';
        raise fnd_api.g_exc_unexpected_error;
      END IF; -- Check PO status
    ELSIF (p_po_req_type = 'REQUISITION') THEN
      -- Call PO API to update requisition
      l_req_changes := PO_REQ_CHANGES_REC_TYPE(
                         req_header_id         => p_req_header_id,
                         line_changes          => NULL,
                         distribution_changes  => NULL);

      l_req_changes.line_changes := PO_REQ_LINES_REC_TYPE(
        req_line_id            => PO_TBL_NUMBER(p_req_line_id),
        unit_price             => PO_TBL_NUMBER(NULL),
        currency_unit_price    => PO_TBL_NUMBER(NULL),
        quantity               => PO_TBL_NUMBER(NULL),
        secondary_quantity     => PO_TBL_NUMBER(NULL),
        need_by_date           => PO_TBL_DATE(p_new_NBD),
        deliver_to_location_id => PO_TBL_NUMBER(NULL),
        assignment_start_date  => PO_TBL_DATE(NULL),
        assignment_end_date    => PO_TBL_DATE(NULL),
        amount                 => PO_TBL_NUMBER(NULL));

      po_wip_integration_grp.update_requisition(
          p_api_version           => 1.0,
          p_req_changes           => l_req_changes,
          p_update_source         => NULL,
          x_return_status         => x_return_status,
          x_msg_count             => l_msgCount,
          x_msg_data              => l_msgData);

      IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_msgData);
        fnd_msg_pub.add;
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF; -- PO or Requisition
    -- write to the log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_osp.updatePOReqNBD',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_returnStatus);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO SAVEPOINT s_update_po_nbd;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_osp.updatePOReqNBD',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
      END IF;

    WHEN others THEN
      ROLLBACK TO SAVEPOINT s_update_po_nbd;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_osp.updatePOReqNBD',
                           p_procReturnStatus => x_return_status,
                           p_msg => l_errMsg,
                           x_returnStatus => l_returnStatus);
      END IF;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
  END updatePOReqNBD;

 /* Fix for bug 4734309: Added new parameter p_is_scrap_txn.
  * If passed as WIP_CONSTANTS.YES,
  * then PO/REQ changes affect only future operations.    */

  PROCEDURE updatePOReqQuantity(p_job_id        IN         NUMBER,
                                p_repetitive_id IN         NUMBER :=NULL,
                                p_org_id        IN         NUMBER,
                                p_changed_qty   IN         NUMBER,
                                p_fm_op         IN         NUMBER,
                                p_is_scrap_txn  IN         NUMBER := NULL, /* Bug 4734309 */
                                x_return_status OUT NOCOPY VARCHAR2) IS

  -- Bugfix 5000087 : Modified the cursor so that it checks the PO creation
  -- time and throw the multiple PO error appropriately.
  CURSOR c_multiple_po IS
    SELECT count(*)
      FROM po_distributions_all pd,
           po_lines_all pl,
           po_headers_all ph,
           po_releases_all pr,
           po_line_locations_all pll,
           wip_discrete_jobs wdj,               -- bugfix 5000087
           wip_repetitive_schedules wrs,        -- bugfix 5000087
           wip_operations  wo                   -- bugfix 5000087
     WHERE pd.po_line_id = pl.po_line_id
       AND ph.po_header_id = pd.po_header_id
       AND pd.line_location_id = pll.line_location_id
       AND pd.po_release_id = pr.po_release_id (+)
       AND pd.wip_entity_id = p_job_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND pd.destination_organization_id = p_org_id
       AND (pll.cancel_flag IS NULL OR
            pll.cancel_flag = 'N')
/* begin bugfix 5000087 */
       AND pd.wip_entity_id = wdj.wip_entity_id (+)
       AND pd.destination_organization_id = wdj.organization_id (+)
       AND pd.wip_repetitive_schedule_id = wrs.repetitive_schedule_id (+)
       AND pd.destination_organization_id = wrs.organization_id (+)
       AND wo.wip_entity_id = pd.wip_entity_id
       AND wo.organization_id = pd.destination_organization_id
       AND wo.operation_seq_num = pd.wip_operation_seq_num
       AND (p_repetitive_id IS NULL OR
            wo.repetitive_schedule_id = p_repetitive_id)
       AND (
            (((p_repetitive_id IS NULL AND
               wdj.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
              OR
              (p_repetitive_id IS NOT NULL AND
               wrs.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE))
             AND pd.wip_operation_seq_num > p_fm_op)
          OR
            (((p_repetitive_id IS NULL AND
               wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION)
              OR
              (p_repetitive_id IS NOT NULL AND
               wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION))
             AND wo.previous_operation_seq_num IS NULL
             AND (p_is_scrap_txn IS NULL OR p_is_scrap_txn = WIP_CONSTANTS.NO))         -- bugfix 4702642
          )
/* end bugfix 5000087 */
  GROUP BY pd.wip_operation_seq_num,
           pl.item_id
    HAVING count(*) > 1
   UNION ALL
    SELECT count(*)
      FROM po_requisition_lines_all prl,
           wip_discrete_jobs wdj,               -- bugfix 5000087
           wip_repetitive_schedules wrs,        -- bugfix 5000087
           wip_operations wo                    -- bugfix 5000087
     WHERE prl.wip_entity_id = p_job_id
       AND (p_repetitive_id IS NULL OR
            prl.wip_repetitive_schedule_id = p_repetitive_id)
       AND prl.destination_organization_id = p_org_id
       AND (prl.cancel_flag IS NULL OR
            prl.cancel_flag = 'N')
/* begin bugfix 5000087 */
       AND prl.wip_entity_id = wdj.wip_entity_id (+)
       AND prl.destination_organization_id = wdj.organization_id (+)
       AND prl.wip_repetitive_schedule_id = wrs.repetitive_schedule_id (+)
       AND prl.destination_organization_id = wrs.organization_id (+)
       AND wo.wip_entity_id = prl.wip_entity_id
       AND wo.organization_id = prl.destination_organization_id
       AND wo.operation_seq_num = prl.wip_operation_seq_num
       AND (p_repetitive_id IS NULL OR
            wo.repetitive_schedule_id = p_repetitive_id)
       AND ((((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE))
             AND prl.wip_operation_seq_num > p_fm_op)
             OR
            (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION))
             AND wo.previous_operation_seq_num IS NULL
             AND (p_is_scrap_txn IS NULL OR p_is_scrap_txn = WIP_CONSTANTS.NO)))        -- bugfix 4702642
/* end bugfix 5000087 */
  GROUP BY prl.wip_operation_seq_num,
           prl.item_id
    HAVING count(*) > 1;

/* Fixed bug 4153549. We also need to update PO/requistion quantity if PO
 * creation time is at operation and OSP operation is the first operation
 * Fixed bug 4734309. Need to update quantities only for future PO/REQs when
 * quantity is scrapped.
 * Fixed Bug 8980631 Need to update only future PO/REQ's irrespective of
 * PO creation time parameter
 */
  CURSOR c_update_po_qty IS
    SELECT pd.po_header_id po_header_id,
           to_number(null) po_release_id,
           pd.po_distribution_id po_distribution_id,
           to_number(null) req_header_id,
           to_number(null) req_line_id,
           (pd.quantity_ordered +
              (DECODE(msi.outside_operation_uom_type,
                 'RESOURCE', ROUND(wor.usage_rate_or_amount * p_changed_qty,
                             WIP_CONSTANTS.INV_MAX_PRECISION),
                 'ASSEMBLY', ROUND(p_changed_qty,
                             WIP_CONSTANTS.INV_MAX_PRECISION)))) new_po_qty,
           ph.type_lookup_code po_req_type,
           ph.authorization_status approval_status,
           msi.primary_uom_code uom_code,
           pd.org_id ou_id -- operating unit
      FROM mtl_system_items msi,
           po_distributions_all pd,
           po_headers_all ph,
           po_lines_all pl,
           po_line_locations_all pll,
           wip_operation_resources wor,
           wip_operations wo,
           wip_discrete_jobs wdj,
           wip_repetitive_schedules wrs
     WHERE ph.type_lookup_code = 'STANDARD'
       AND ph.po_header_id = pd.po_header_id
       AND pd.line_location_id = pll.line_location_id
       AND pd.po_line_id = pl.po_line_id
       AND pd.wip_entity_id = wdj.wip_entity_id (+)
       AND pd.destination_organization_id = wdj.organization_id (+)
       AND pd.wip_repetitive_schedule_id = wrs.repetitive_schedule_id (+)
       AND pd.destination_organization_id = wrs.organization_id (+)
       AND pl.item_id = msi.inventory_item_id
       AND pd.destination_organization_id = msi.organization_id
       AND pd.wip_entity_id = p_job_id
       AND pd.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND pd.wip_operation_seq_num > p_fm_op /*Bug 8980631*/
       AND (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE))
            OR
            (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION))
             AND wo.previous_operation_seq_num IS NULL
             AND (p_is_scrap_txn IS NULL OR p_is_scrap_txn = WIP_CONSTANTS.NO)))/* 4734309 */
       AND wor.organization_id = wo.organization_id
       AND wor.wip_entity_id = wo.wip_entity_id
       AND wor.operation_seq_num = wo.operation_seq_num
       AND wor.organization_id = pd.destination_organization_id
       AND wor.wip_entity_id = pd.wip_entity_id
       AND wor.operation_seq_num = pd.wip_operation_seq_num
       AND (p_repetitive_id IS NULL OR
            wor.repetitive_schedule_id = p_repetitive_id)
       AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
       AND (pll.cancel_flag IS NULL OR pll.cancel_flag = 'N')
   UNION ALL
    SELECT pd.po_header_id po_header_id,
           pr.po_release_id po_release_id,
           pd.po_distribution_id po_distribution_id,
           to_number(null) req_header_id,
           to_number(null) req_line_id,
           (pd.quantity_ordered +
              (DECODE(msi.outside_operation_uom_type,
                 'RESOURCE', ROUND(wor.usage_rate_or_amount * p_changed_qty,
                             WIP_CONSTANTS.INV_MAX_PRECISION),
                 'ASSEMBLY', ROUND(p_changed_qty,
                             WIP_CONSTANTS.INV_MAX_PRECISION)))) new_po_qty,
           ph.type_lookup_code po_req_type,
           pr.authorization_status approval_status,
           msi.primary_uom_code uom_code,
           pd.org_id ou_id -- operating unit
      FROM mtl_system_items msi,
           po_distributions_all pd,
           po_headers_all ph,
           po_lines_all pl,
           po_line_locations_all pll,
           po_releases_all pr,
           wip_operation_resources wor,
           wip_operations wo,
           wip_discrete_jobs wdj,
           wip_repetitive_schedules wrs
     WHERE ph.type_lookup_code = 'BLANKET'
       /* Fixed bug 4240329. Add condition below to join pr.po_release_id and
          pll.po_release_id together to prevent the cursor to pick all release
          document
        */
       AND pr.po_release_id = pll.po_release_id
       AND pr.po_header_id = ph.po_header_id
       AND ph.po_header_id = pd.po_header_id
       AND pd.line_location_id = pll.line_location_id
       AND pd.po_line_id = pl.po_line_id
       AND pd.wip_entity_id = wdj.wip_entity_id (+)
       AND pd.destination_organization_id = wdj.organization_id (+)
       AND pd.wip_repetitive_schedule_id = wrs.repetitive_schedule_id (+)
       AND pd.destination_organization_id = wrs.organization_id (+)
       AND pl.item_id = msi.inventory_item_id
       AND pd.destination_organization_id = msi.organization_id
       AND pd.wip_entity_id = p_job_id
       AND pd.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND pd.wip_operation_seq_num > p_fm_op   /*bug 8980631*/
       AND (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE))
            OR
            (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION))
             AND wo.previous_operation_seq_num IS NULL
             AND (p_is_scrap_txn IS NULL OR p_is_scrap_txn = WIP_CONSTANTS.NO)))
       AND wor.organization_id = wo.organization_id
       AND wor.wip_entity_id = wo.wip_entity_id
       AND wor.operation_seq_num = wo.operation_seq_num
       AND wor.organization_id = pd.destination_organization_id
       AND wor.wip_entity_id = pd.wip_entity_id
       AND wor.operation_seq_num = pd.wip_operation_seq_num
       AND (p_repetitive_id IS NULL OR
            wor.repetitive_schedule_id = p_repetitive_id)
       AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
       AND (pll.cancel_flag IS NULL OR pll.cancel_flag = 'N')
    UNION ALL
    SELECT to_number(null) po_header_id,
           to_number(null) po_release_id,
           to_number(null) po_distribution_id,
           prl.requisition_header_id req_header_id,
           prl.requisition_line_id req_line_id,
           (prl.quantity +
              (DECODE(msi.outside_operation_uom_type,
                 'RESOURCE', ROUND(wor.usage_rate_or_amount * p_changed_qty,
                             WIP_CONSTANTS.INV_MAX_PRECISION),
                 'ASSEMBLY', ROUND(p_changed_qty,
                             WIP_CONSTANTS.INV_MAX_PRECISION)))) new_po_qty,
           'REQUISITION' po_req_type,
           prh.authorization_status approval_status,
           msi.primary_uom_code uom_code,
           prl.org_id ou_id -- operating unit
      FROM mtl_system_items msi,
           po_requisition_headers_all prh,
           po_requisition_lines_all prl,
           wip_operation_resources wor,
           wip_operations wo,
           wip_discrete_jobs wdj,
           wip_repetitive_schedules wrs
     WHERE NOT EXISTS
          (SELECT 'x'
             FROM po_line_locations_all pll
            WHERE prl.line_location_id = pll.line_location_id)
       AND prh.requisition_header_id = prl.requisition_header_id
       AND prl.wip_entity_id = wdj.wip_entity_id (+)
       AND prl.destination_organization_id = wdj.organization_id (+)
       AND prl.wip_repetitive_schedule_id = wrs.repetitive_schedule_id (+)
       AND prl.destination_organization_id = wrs.organization_id (+)
       AND prl.item_id = msi.inventory_item_id
       AND prl.destination_organization_id = msi.organization_id
       AND prl.wip_entity_id = p_job_id
       AND prl.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            prl.wip_repetitive_schedule_id = p_repetitive_id)
       AND prl.wip_operation_seq_num > p_fm_op
       AND (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE))
            OR
            (((p_repetitive_id IS NULL AND
             wdj.po_creation_time = WIP_CONSTANTS.AT_OPERATION)
             OR
            (p_repetitive_id IS NOT NULL AND
             wrs.po_creation_time = WIP_CONSTANTS.AT_OPERATION))
             AND wo.previous_operation_seq_num IS NULL
             AND (p_is_scrap_txn IS NULL OR p_is_scrap_txn = WIP_CONSTANTS.NO)))
       AND wor.organization_id = wo.organization_id
       AND wor.wip_entity_id = wo.wip_entity_id
       AND wor.operation_seq_num = wo.operation_seq_num
       AND wor.organization_id = prl.destination_organization_id
       AND wor.wip_entity_id = prl.wip_entity_id
       AND wor.operation_seq_num = prl.wip_operation_seq_num
       AND (p_repetitive_id IS NULL OR
            wor.repetitive_schedule_id = p_repetitive_id)
       AND wor.basis_type = WIP_CONSTANTS.PER_ITEM
       AND (prl.cancel_flag IS NULL OR prl.cancel_flag = 'N');

  l_pending_recs     NUMBER;
  l_multiple_po      c_multiple_po%ROWTYPE;
  l_update_po_qty    c_update_po_qty%ROWTYPE;
  l_params           wip_logger.param_tbl_t;
  l_logLevel         NUMBER := fnd_log.g_current_runtime_level;
  l_returnStatus     VARCHAR2(1);
  l_errMsg           VARCHAR2(240);
  l_debugMsg         VARCHAR2(240);
  l_msgCount         NUMBER;
  l_msgData          VARCHAR2(2000);
  l_po_changes       PO_CHANGES_REC_TYPE;
  l_errors_rec       PO_API_ERRORS_REC_TYPE;
  l_req_changes      PO_REQ_CHANGES_REC_TYPE;
  l_po_creation_time NUMBER;
  BEGIN
    -- write parameter value to log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName   := 'p_job_id';
      l_params(1).paramValue  :=  p_job_id;
      l_params(2).paramName   := 'p_repetitive_id';
      l_params(2).paramValue  :=  p_repetitive_id;
      l_params(3).paramName   := 'p_org_id';
      l_params(3).paramValue  :=  p_org_id;
      l_params(4).paramName   := 'p_changed_qty';
      l_params(4).paramValue  :=  p_changed_qty;
      l_params(5).paramName   := 'p_fm_op';
      l_params(5).paramValue  :=  p_fm_op;
      wip_logger.entryPoint(p_procName => 'wip_osp.updatePOReqQuantity',
                            p_params   => l_params,
                            x_returnStatus => l_returnStatus);
    END IF;

    SAVEPOINT s_update_po_qty;
    x_return_status := fnd_api.g_ret_sts_success;

    IF(p_repetitive_id IS NULL) THEN
      -- Discrete jobs
      SELECT po_creation_time
        INTO l_po_creation_time
        FROM wip_discrete_jobs
       WHERE wip_entity_id = p_job_id
         AND organization_id = p_org_id;
    ELSE
      -- Repetitive schedules
      SELECT po_creation_time
        INTO l_po_creation_time
        FROM wip_repetitive_schedules
       WHERE repetitive_schedule_id = p_repetitive_id
         AND organization_id = p_org_id;
    END IF;

    IF(l_po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION) THEN
      -- Check whether the record is still in the requisition interface table

	  /* Fix for bug 5685068: When performing scrap transactions, validate for pending
	     requisitions only if PO Creation Time is set to At Job/Schedule Release. */
      if((p_is_scrap_txn = WIP_CONSTANTS.YES AND
          l_po_creation_time = WIP_CONSTANTS.AT_JOB_SCHEDULE_RELEASE) OR
		 p_is_scrap_txn IS NULL OR p_is_scrap_txn = WIP_CONSTANTS.NO) THEN

      SELECT count(*)
        INTO l_pending_recs
        FROM po_requisitions_interface_all
       WHERE wip_entity_id = p_job_id
         AND (p_repetitive_id IS NULL OR
              wip_repetitive_schedule_id = p_repetitive_id);

      IF(l_pending_recs <> 0) THEN
        fnd_message.set_name('WIP', 'WIP_REQUISITION_PENDING');
        fnd_msg_pub.add;
        l_errMsg    := 'There are some pending records in ' ||
                       'PO_REQUISITIONS_INTERFACE_ALL';
        raise fnd_api.g_exc_unexpected_error;
      END IF;
      end if; /* if((p_is_scrap_txn = WIP_CONSTANTS.YES AND */

      OPEN c_multiple_po;
      FETCH c_multiple_po INTO l_multiple_po;

      IF (c_multiple_po%FOUND) THEN
        fnd_message.set_name('WIP', 'WIP_MULTIPLE_PO_FOUND');
        fnd_msg_pub.add;
        l_errMsg    := 'Multiple PO/requisitions found for this job/schedule';
        raise fnd_api.g_exc_unexpected_error;
      ELSE
        -- Update PO quantity
        FOR l_update_po_qty IN c_update_po_qty LOOP
          -- Set OU context before calling PO API. This change is
          -- mandatory for MOAC change in R12.
          mo_global.set_policy_context('S',l_update_po_qty.ou_id);
          IF (l_update_po_qty.po_req_type IN ('STANDARD', 'BLANKET')) THEN
            IF (l_update_po_qty.approval_status IS NULL OR -- INCOMPLETE
                l_update_po_qty.approval_status IN ('INCOMPLETE',
                                                    'APPROVED',
                                                    'REQUIRES REAPPROVAL')) THEN
              -- Call an API to update QUANTITY at the distribution level.
              -- This API will recalculate the shipment and line quantity
              -- automatically.
              l_po_changes := PO_CHANGES_REC_TYPE.create_object(
                                p_po_header_id  => l_update_po_qty.po_header_id,
                                p_po_release_id => l_update_po_qty.po_release_id);
              l_po_changes.distribution_changes.add_change(
                p_po_distribution_id => l_update_po_qty.po_distribution_id,
                p_quantity_ordered   => l_update_po_qty.new_po_qty);
              IF (l_logLevel <= wip_constants.full_logging) THEN
                l_debugMsg := 'po_header_id = ' || l_update_po_qty.po_header_id
                              || ' ; ' || 'po_release_id = ' ||
                              l_update_po_qty.po_release_id || ' ; ' ||
                              'po_distribution_id = ' ||
                              l_update_po_qty.po_distribution_id || ' ; ' ||
                              'new_po_qty = ' || l_update_po_qty.new_po_qty;

                wip_logger.log(p_msg          => l_debugMsg,
                               x_returnStatus => l_returnStatus);
              END IF;

              po_wip_integration_grp.update_document(
                p_api_version           => 1.0,
                p_init_msg_list         => fnd_api.g_true,
                p_changes               => l_po_changes,
                p_run_submission_checks => fnd_api.g_true,
                p_launch_approvals_flag => fnd_api.g_true,
                p_buyer_id              => NULL,
                p_update_source         => NULL,
                p_override_date         => NULL,
                x_return_status         => x_return_status,
                x_api_errors            => l_errors_rec);

              IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
                FOR i IN 1..l_errors_rec.message_name.count LOOP
                  fnd_message.set_name('PO', l_errors_rec.message_name(i));
                  fnd_msg_pub.add;
                END LOOP;
                raise fnd_api.g_exc_unexpected_error;
              END IF;
            ELSE -- PO is in the status that does not allow update
              fnd_message.set_name('WIP', 'WIP_INVALID_PO_STATUS');
              fnd_msg_pub.add;
              l_errMsg    := 'PO is in status that does not allow update';
              raise fnd_api.g_exc_unexpected_error;
            END IF; -- Check PO status
          ELSIF (l_update_po_qty.po_req_type = 'REQUISITION') THEN
            -- Call PO API to update QUANTITY in PO_REQUISITION_LINES_ALL.
            l_req_changes := PO_REQ_CHANGES_REC_TYPE(
              req_header_id        => l_update_po_qty.req_header_id,
              line_changes         => NULL,
              distribution_changes => NULL);
            l_req_changes.line_changes := PO_REQ_LINES_REC_TYPE(
              req_line_id            => PO_TBL_NUMBER(l_update_po_qty.req_line_id),
              unit_price             => PO_TBL_NUMBER(NULL),
              currency_unit_price    => PO_TBL_NUMBER(NULL),
              quantity               => PO_TBL_NUMBER(l_update_po_qty.new_po_qty),
              secondary_quantity     => PO_TBL_NUMBER(NULL),
              need_by_date           => PO_TBL_DATE(NULL),
              deliver_to_location_id => PO_TBL_NUMBER(NULL),
              assignment_start_date  => PO_TBL_DATE(NULL),
              assignment_end_date    => PO_TBL_DATE(NULL),
              amount                 => PO_TBL_NUMBER(NULL));

            IF (l_logLevel <= wip_constants.full_logging) THEN
              l_debugMsg := 'req_header_id = ' || l_update_po_qty.req_header_id
                            || ' ; ' || 'req_line_id = ' ||
                            l_update_po_qty.req_line_id || ' ; ' ||
                            'new_po_qty = ' || l_update_po_qty.new_po_qty;

              wip_logger.log(p_msg          => l_debugMsg,
                             x_returnStatus => l_returnStatus);
            END IF;

            po_wip_integration_grp.update_requisition(
              p_api_version           => 1.0,
              p_req_changes           => l_req_changes,
              p_update_source         => NULL,
              x_return_status         => x_return_status,
              x_msg_count             => l_msgCount,
              x_msg_data              => l_msgData);

            IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE', l_msgData);
              fnd_msg_pub.add;
              raise fnd_api.g_exc_unexpected_error;
            END IF;
          END IF; -- PO or Requisition
        END LOOP;
      END IF;-- Multiple PO found for the same job,same item,and same op.
    END IF; -- po_creation_time <> WIP_CONSTANTS.MANUAL_CREATION

    IF(c_multiple_po%ISOPEN) THEN
      CLOSE c_multiple_po;
    END IF;

    -- write to the log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_osp.updatePOReqQuantity',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_returnStatus);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO SAVEPOINT s_update_po_qty;
      IF(c_multiple_po%ISOPEN) THEN
        CLOSE c_multiple_po;
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_osp.updatePOReqQuantity',
                             p_procReturnStatus => x_return_status,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus);
      END IF;

    WHEN others THEN
      ROLLBACK TO SAVEPOINT s_update_po_qty;
      IF(c_multiple_po%ISOPEN) THEN
        CLOSE c_multiple_po;
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_osp.updatePOReqQuantity',
                             p_procReturnStatus => x_return_status,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus);
      END IF;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
  END updatePOReqQuantity;

  PROCEDURE cancelPOReq (p_job_id        IN         NUMBER,
                         p_repetitive_id IN         NUMBER :=NULL,
                         p_org_id        IN         NUMBER,
                         p_op_seq_num    IN         NUMBER :=NULL,
                         x_return_status OUT NOCOPY VARCHAR2,
		         p_clr_fnd_mes_flag IN      VARCHAR2 DEFAULT NULL) IS
 -- added parameter p_clr_fnd_mes_flag for bugfix 7229689.
 -- Bug fix 8681037: Changed the default value from 'N' to NULL for p_clr_fnd_mes_flag parameter
 -- as per the standards.

  CURSOR c_po_req IS
    SELECT pd.po_header_id po_header_id,
           to_number(null) po_release_id,
           pd.po_line_id po_line_id,
           pd.line_location_id po_line_location_id,
           to_number(null) req_header_id,
           to_number(null) req_line_id,
           ph.type_lookup_code po_req_type,
           ph.authorization_status approval_status,
           'PO' document_type,
           ph.type_lookup_code document_subtype,
           pd.org_id ou_id -- operating unit
      FROM po_distributions_all pd,
           po_headers_all ph,
           po_line_locations_all pll
     /* Fixed bug 3115844 */
     WHERE pd.po_line_id IS NOT NULL
       AND pd.line_location_id IS NOT NULL
       AND ph.type_lookup_code = 'STANDARD'
       AND ph.po_header_id = pd.po_header_id
       AND pd.line_location_id = pll.line_location_id
       AND pd.wip_entity_id = p_job_id
       AND pd.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND (p_op_seq_num IS NULL OR
            pd.wip_operation_seq_num = p_op_seq_num)
       AND (pll.cancel_flag IS NULL OR pll.cancel_flag = 'N')
   UNION ALL
    SELECT pd.po_header_id po_header_id,
           pr.po_release_id po_release_id,
           to_number(null) po_line_id,/* Fix for 4368095. Removed pd.po_line_id po_line_id,*/
           pd.line_location_id po_line_location_id,
           to_number(null) req_header_id,
           to_number(null) req_line_id,
           ph.type_lookup_code po_req_type,
           pr.authorization_status approval_status,
           'RELEASE' document_type,
           ph.type_lookup_code document_subtype,
           pd.org_id ou_id -- operating unit
      FROM po_distributions_all pd,
           po_headers_all ph,
           po_line_locations_all pll,
           po_releases_all pr
     /* Fixed bug 3115844 */
     WHERE pd.po_line_id IS NOT NULL
       AND pd.line_location_id IS NOT NULL
       AND ph.type_lookup_code = 'BLANKET'
       AND pr.po_header_id = ph.po_header_id
       /* Bug 4892265: Added condition to pick correct release */
       AND pr.po_release_id = pd.po_release_id
       /* End fix of bug 4892265 */
       AND ph.po_header_id = pd.po_header_id
       AND pd.line_location_id = pll.line_location_id
       AND pd.wip_entity_id = p_job_id
       AND pd.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            pd.wip_repetitive_schedule_id = p_repetitive_id)
       AND (p_op_seq_num IS NULL OR
            pd.wip_operation_seq_num = p_op_seq_num)
       AND (pll.cancel_flag IS NULL OR pll.cancel_flag = 'N')
   UNION ALL
    SELECT to_number(null) po_header_id,
           to_number(null) po_release_id,
           to_number(null) po_line_id,
           to_number(null) po_line_location_id,
           prl.requisition_header_id req_header_id,
           prl.requisition_line_id req_line_id,
           'REQUISITION' po_req_type,
           prh.authorization_status approval_status,
           to_char(null) document_type,
           to_char(null) document_subtype,
           prl.org_id ou_id -- operating unit
      FROM po_requisition_headers_all prh,
           po_requisition_lines_all prl
     WHERE NOT EXISTS
          (SELECT 'x'
             FROM po_line_locations_all pll
            WHERE prl.line_location_id = pll.line_location_id)
       AND prh.requisition_header_id = prl.requisition_header_id
       AND prl.wip_entity_id = p_job_id
       AND prl.destination_organization_id = p_org_id
       AND (p_repetitive_id IS NULL OR
            prl.wip_repetitive_schedule_id = p_repetitive_id)
       AND (p_op_seq_num IS NULL OR
            prl.wip_operation_seq_num = p_op_seq_num)
       AND (prl.cancel_flag IS NULL OR
            prl.cancel_flag = 'N');


  l_po_req c_po_req%ROWTYPE;
  l_err_count NUMBER := 0;
  l_pending_recs NUMBER;
  l_params       wip_logger.param_tbl_t;
  l_logLevel     NUMBER := fnd_log.g_current_runtime_level;
  l_returnStatus VARCHAR2(1);
  l_errMsg       VARCHAR2(240);
  l_debugMsg     VARCHAR2(240);
  l_msgCount     NUMBER;
  l_msgData      VARCHAR2(2000);
  BEGIN
    -- write parameter value to log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      l_params(1).paramName   := 'p_job_id';
      l_params(1).paramValue  :=  p_job_id;
      l_params(2).paramName   := 'p_repetitive_id';
      l_params(2).paramValue  :=  p_repetitive_id;
      l_params(3).paramName   := 'p_org_id';
      l_params(3).paramValue  :=  p_org_id;
      l_params(4).paramName   := 'p_op_seq_num';
      l_params(4).paramValue  :=  p_op_seq_num;
      wip_logger.entryPoint(p_procName => 'wip_osp.cancelPOReq',
                            p_params   => l_params,
                            x_returnStatus => l_returnStatus);
    END IF;

    FOR l_po_req IN c_po_req LOOP
      BEGIN
        -- Set OU context before calling PO API. This change is
        -- mandatory for MOAC change in R12.
        mo_global.set_policy_context('S',l_po_req.ou_id);
        IF (l_po_req.po_req_type IN ('STANDARD', 'BLANKET'))THEN
          -- Call PO API to cancel PO/release. If unable to cancel PO/release
          -- for any reason,skip the error one and try to cancel the next one.

          IF (l_logLevel <= wip_constants.full_logging) THEN
            l_debugMsg := 'po_header_id = ' || l_po_req.po_header_id|| ' ; ' ||
                          'po_release_id = ' || l_po_req.po_release_id || ' ; '
                          ||
                          'po_line_id = ' || l_po_req.po_line_id || ' ; ' ||
                          'po_line_location_id = ' ||
                          l_po_req.po_line_location_id;

            wip_logger.log(p_msg          => l_debugMsg,
                           x_returnStatus => l_returnStatus);
          END IF;

          -- Call PO API to cancel requisition
          -- Bug fix 8681037: Added NVL in the if condition.
          IF NVL(p_clr_fnd_mes_flag, 'N') = 'Y' Then  -- added for bug fix 7415801
             fnd_msg_pub.initialize;
          END IF; --bug fix 7415801

          po_wip_integration_grp.cancel_document
           (p_api_version      => 1.0,
            p_doc_type         => PO_TBL_VARCHAR30(l_po_req.document_type),
            p_doc_subtype      => PO_TBL_VARCHAR30(l_po_req.document_subtype),
            p_doc_id           => PO_TBL_NUMBER(l_po_req.po_header_id),
            p_doc_num          => PO_TBL_VARCHAR30(NULL),
            p_release_id       => PO_TBL_NUMBER(l_po_req.po_release_id),
            p_release_num      => PO_TBL_NUMBER(NULL),
            p_doc_line_id      => PO_TBL_NUMBER(l_po_req.po_line_id),
            p_doc_line_num     => PO_TBL_NUMBER(NULL),
            p_doc_line_loc_id  => PO_TBL_NUMBER(l_po_req.po_line_location_id),
            p_doc_shipment_num => PO_TBL_NUMBER(NULL),
            p_source           => NULL,
            p_cancel_date      => SYSDATE,
            p_cancel_reason    => NULL,
            p_cancel_reqs_flag => 'Y',
            p_print_flag       => 'N',
            p_note_to_vendor   => NULL,
            x_return_status    => x_return_status,
            x_msg_count        => l_msgCount,
            x_msg_data         => l_msgData);

          IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE', l_msgData);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          IF (l_logLevel <= wip_constants.full_logging) THEN
            l_debugMsg := 'req_header_id = ' || l_po_req.req_header_id|| ' ; '
                          || 'req_line_id = ' || l_po_req.req_line_id;

            wip_logger.log(p_msg          => l_debugMsg,
                           x_returnStatus => l_returnStatus);
          END IF;
          -- Call PO API to cancel requisition
          po_wip_integration_grp.cancel_requisition
           (p_api_version   => 1.0,
            p_req_header_id => PO_TBL_NUMBER(l_po_req.req_header_id),
            p_req_line_id   => PO_TBL_NUMBER(l_po_req.req_line_id),
            p_cancel_date   => SYSDATE,
            p_cancel_reason => NULL,
            p_source        => NULL,
            x_return_status => x_return_status,
            x_msg_count     => l_msgCount,
            x_msg_data      => l_msgData);

          IF(x_return_status <> fnd_api.g_ret_sts_success) THEN
            fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
            fnd_message.set_token('MESSAGE', l_msgData);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
      EXCEPTION
        WHEN others THEN
          l_err_count := l_err_count + 1;
      END;
    END LOOP;

    IF (l_err_count > 0) THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('WIP','WIP_UNABLE_TO_CANCEL_PO');
      fnd_msg_pub.add;
    ELSE
      SELECT count(*)
        INTO l_pending_recs
        FROM po_requisitions_interface_all
       WHERE wip_entity_id = p_job_id;
      IF(l_pending_recs <> 0) THEN
        fnd_message.set_name('WIP', 'WIP_REQUISITION_PENDING');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      ELSE
        x_return_status  := fnd_api.g_ret_sts_success;
      END IF;
    END IF;
    -- write to the log file
    IF (l_logLevel <= wip_constants.trace_logging) THEN
      wip_logger.exitPoint(p_procName => 'wip_osp.cancelPOReq',
                           p_procReturnStatus => x_return_status,
                           p_msg => 'procedure complete',
                           x_returnStatus => l_returnStatus);
    END IF;
  EXCEPTION
    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      l_errMsg := 'unexpected error: ' || SQLERRM || 'SQLCODE = ' || SQLCODE;
      IF (l_logLevel <= wip_constants.trace_logging) THEN
        wip_logger.exitPoint(p_procName => 'wip_osp.cancelPOReq',
                             p_procReturnStatus => x_return_status,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus);
      END IF;
      fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
      fnd_message.set_token('MESSAGE', l_errMsg);
      fnd_msg_pub.add;
  END cancelPOReq;

 /* Fix for bug 4446607: This function returns TRUE if a PO/REQ is ever
  * created for this particular job/operation, irrespective of whether the
  * PO/REQ is cancelled or closed. This will be used to determine whether
  * to call release_validation when rescheduling the job through mass-load.
  * We had been using PO_REQ_EXISTS but that would return FALSE if either
  * the PO/REQ is cancelled or if all the quantity is received for the PO.
  * Because of this, requisition creation was erroneously triggered when
  * rescheduling a job, whose associated PO has been received in total.
  */
  FUNCTION PO_REQ_CREATED ( p_wip_entity_id   in  NUMBER
                           ,p_rep_sched_id    in  NUMBER
                           ,p_organization_id in  NUMBER
                           ,p_op_seq_num      in  NUMBER default NULL
                           ,p_entity_type     in  NUMBER
                          ) RETURN BOOLEAN IS

    CURSOR disc_check_po_req_cur IS
      SELECT 'No PO/REQ Created'
        FROM DUAL
       WHERE NOT EXISTS
             (SELECT '1'
                FROM PO_RELEASES_ALL PR,
                     PO_HEADERS_ALL PH,
                     PO_DISTRIBUTIONS_ALL PD
               WHERE PD.WIP_ENTITY_ID = p_wip_entity_id
                 AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
                 AND (p_op_seq_num is NULL
                     OR PD.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
                 AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
                 AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID)
         AND NOT EXISTS
             (SELECT '1'
                FROM PO_REQUISITION_LINES_ALL PRL
               WHERE PRL.WIP_ENTITY_ID = p_wip_entity_id
                 AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
                 AND (p_op_seq_num is NULL
                     OR PRL.WIP_OPERATION_SEQ_NUM = p_op_seq_num))
         AND NOT EXISTS
             (SELECT '1'
                FROM PO_REQUISITIONS_INTERFACE_ALL PRI
               WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
                 AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
                 AND (p_op_seq_num is NULL
                     OR PRI.WIP_OPERATION_SEQ_NUM = p_op_seq_num));

    CURSOR rep_check_po_req_cur IS
      SELECT 'No PO Created'
        FROM DUAL
       WHERE NOT EXISTS
             (SELECT '1'
                FROM PO_RELEASES_ALL PR,
                     PO_HEADERS_ALL PH,
                     PO_DISTRIBUTIONS_ALL PD
               WHERE PD.WIP_ENTITY_ID = p_wip_entity_id
                 AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
                 AND PD.WIP_REPETITIVE_SCHEDULE_ID = p_rep_sched_id
                 AND (p_op_seq_num is NULL
                     OR PD.WIP_OPERATION_SEQ_NUM = p_op_seq_num)
                 AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
                 AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID)
         AND NOT EXISTS
             (SELECT '1'
                FROM PO_REQUISITION_LINES PRL
               WHERE PRL.WIP_ENTITY_ID = p_wip_entity_id
                 AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
                 AND PRL.WIP_REPETITIVE_SCHEDULE_ID = p_rep_sched_id
                 AND (p_op_seq_num is NULL
                     OR PRL.WIP_OPERATION_SEQ_NUM = p_op_seq_num))
         AND NOT EXISTS
             (SELECT '1'
                FROM PO_REQUISITIONS_INTERFACE_ALL PRI
               WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
                 AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
                 AND PRI.WIP_REPETITIVE_SCHEDULE_ID = p_rep_sched_id
                 AND (p_op_seq_num is NULL
                     OR PRI.WIP_OPERATION_SEQ_NUM = p_op_seq_num));

    po_req_exist VARCHAR2(20);

  BEGIN
    IF(p_entity_type = WIP_CONSTANTS.REPETITIVE) THEN
      OPEN rep_check_po_req_cur;
      FETCH rep_check_po_req_cur INTO po_req_exist;

      IF(rep_check_po_req_cur%NOTFOUND) THEN
        CLOSE rep_check_po_req_cur;
        RETURN TRUE;
      ELSE
        CLOSE rep_check_po_req_cur;
        RETURN FALSE;
      END IF;
    ELSE  /*FOR DISCRETE, OSFM, AND EAM*/
      OPEN disc_check_po_req_cur;
      FETCH disc_check_po_req_cur INTO po_req_exist;

      IF(disc_check_po_req_cur%NOTFOUND) THEN
        CLOSE disc_check_po_req_cur;
        return TRUE;
      ELSE
        CLOSE disc_check_po_req_cur;
        return FALSE;
      END IF;
    END IF;  -- End check POs and REQs
  END PO_REQ_CREATED;
  /* End of fix for Bug 4446607. */

END WIP_OSP;


/
