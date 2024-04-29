--------------------------------------------------------
--  DDL for Package Body AHL_PRD_RESOURCE_TRANX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_RESOURCE_TRANX_PVT" AS
/*$Header: AHLVTRSB.pls 120.18 2008/01/15 00:47:10 sikumar ship $*/
--
G_PKG_NAME      	VARCHAR2(30):='AHL_PRD_RESOURCE_TRANX_PVT';
G_DEBUG			VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE VALIDATE_RES_TRNX
(
 p_prd_resrc_txn_tbl            IN OUT NOCOPY  PRD_RESOURCE_TXNS_TBL,
 x_return_status                OUT NOCOPY     VARCHAR2
)
AS
l_ctr                   NUMBER:=0;
Cursor ValidWrkDet(C_WORKORDER_ID NUMBER)
Is
Select wip_entity_id, workorder_name, status_code
from AHL_WORKORDERS
Where Workorder_id=C_WORKORDER_ID;

l_wrkrec        ValidWrkDet%rowtype;

-- rroy
-- resource validation should be based on resource sequence number
-- not resource name, since resource name is not entered if the resource
-- is not validated against the lov
-- sracha 7/31.
-- changing validation to be based on resource name or resource id.
-- resource sequence will be derived if exists.
/*
Cursor GetResourceDet(c_op_seq_num NUMBER,
                      c_org_id NUMBER,
                      c_wo_id NUMBER,
                      c_res_code VARCHAR2)
--                      c_res_seq_num NUMBER)
IS
SELECT bomr.resource_code,
bomr.resource_type, aor.resource_sequence_num
FROM BOM_RESOURCES bomr,
AHL_WORKORDER_OPERATIONS awop,
AHL_OPERATION_RESOURCES aor
WHERE awop.workorder_operation_id = aor.workorder_operation_id(+)
AND bomr.resource_id = aor.resource_id(+)
AND awop.operation_sequence_num = c_op_seq_num
--AND aor.resource_sequence_num = c_res_seq_num
AND bomr.resource_code = c_res_code
AND awop.workorder_id = c_wo_id
AND bomr.organization_id = c_org_id;
*/

Cursor GetResourceDet(c_org_id NUMBER,
                      c_res_code VARCHAR2)
--
IS
SELECT bomr.resource_code, bomr.resource_type
FROM BOM_RESOURCES bomr
WHERE bomr.organization_id = c_org_id
  and bomr.resource_code = c_res_code;

/*Select * from bom_resources
where resource_code=c_resource_name
and   organization_id=c_org_id;*/
l_res_rec   GetResourceDet%rowtype;

 -- Adithya modified the code for Bug # 6326254 - Start
 CURSOR get_instance_sernum (c_department_id NUMBER,
                             c_serial_number VARCHAR2,
                             c_resource_id NUMBER,
                             c_organization_id NUMBER)
  IS
    SELECT instance_id
    FROM bom_dept_res_instances
    WHERE department_id in (
    		   select
  			 distinct nvl(bodres.share_from_dept_id, bodres.department_id)
  		   from
  			 bom_departments bomdep,
  			 bom_department_resources bodres
  		   where
  			 bodres.department_id = bomdep.department_id and
  			 bomdep.department_id = c_department_id and
  			 bomdep.organization_id = c_organization_id
    )
    and   Serial_Number=c_serial_number
    and   Resource_id=c_resource_id;

  -- bug# 4553747 - Fixed employee validation.
  -- validate employee_num.
  -- remove dependency on resource requirements.
  CURSOR chk_valid_emp_csr(p_org_id  in number,
                           --p_job_id  in number,
                           --p_oper_seq  in number,
                           --p_resrc_seq in number,
                           p_resrc_id   in number,
                           --p_emp_num in number) -- fix for bug# 6032288.
                           p_emp_num in varchar2)
  IS
    SELECT 'x'
    FROM  mtl_employees_current_view pf, bom_resource_employees bre, bom_dept_res_instances bdri
          --, ahl_pp_requirement_v aprv
    WHERE --aprv.department_id = bdri.department_id
      --and aprv.RESOURCE_ID= bdri.resource_id
      --and
      bre.instance_id = bdri.instance_id
      and pf.employee_id=bre.person_id
      and pf.organization_id = bre.organization_id
      and bdri.resource_id = p_resrc_id
      --and aprv.OPERATION_SEQUENCE = p_oper_seq
      --and aprv.RESOURCE_SEQUENCE = p_resrc_seq
      --and aprv.RESOURCE_ID = p_resrc_id
      --and aprv.job_id= p_job_id
      and bre.organization_id= p_org_id
      and pf.employee_num = p_emp_num;

  -- validate employee_id.
  -- remove dependency on resource requirements.
  CURSOR chk_valid_empid_csr(p_org_id  in number,
                             --p_job_id  in number,
                             --p_oper_seq  in number,
                             --p_resrc_seq in number,
                             p_resrc_id  in number,
                             p_emp_id    in number)

  IS
    SELECT 'x'
    FROM  bom_resource_employees bre, bom_dept_res_instances bdri --,
          --ahl_pp_requirement_v aprv
    WHERE --aprv.department_id = bdri.department_id
      --and aprv.RESOURCE_ID= bdri.resource_id
      --and
      bre.instance_id = bdri.instance_id
      and bre.person_id = p_emp_id
      and bdri.resource_id = p_resrc_id
      --and aprv.OPERATION_SEQUENCE = p_oper_seq
      --and aprv.RESOURCE_SEQUENCE = p_resrc_seq
      --and aprv.RESOURCE_ID = p_resrc_id
      --and aprv.job_id= p_job_id
      and bre.organization_id= p_org_id;

-- rroy
-- R12 Tech UIs
CURSOR get_wo_release_date(c_wip_entity_id NUMBER)
IS
SELECT DATE_RELEASED
FROM WIP_DISCRETE_JOBS
WHERE WIP_ENTITY_ID = c_wip_entity_id;

/*
Cursor get_wo_org_id(c_wo_id number)
Is
Select vst.organization_id
from  ahl_workorders wo,
ahl_visits_b vst
where vst.visit_id = wo.visit_id
and wo.workorder_id = c_wo_id;
*/

l_release_date  DATE;
l_inst_id       NUMBER;
l_return_status VARCHAR2(1);
l_org_id        NUMBER;

l_junk          VARCHAR2(1);

l_proc_name VARCHAR2(80) := 'VALIDATE_RES_TRNX';

l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);
l_msg_index_out  number;

BEGIN
IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'Start of procedure',l_proc_name);
END IF;

IF p_prd_resrc_txn_tbl.COUNT >0
THEN
     FOR i in p_prd_resrc_txn_tbl.FIRST..p_prd_resrc_txn_tbl.LAST
     LOOP
        IF p_prd_resrc_txn_tbl(I).workorder_id IS NULL OR
	     p_prd_resrc_txn_tbl(I).workorder_id=FND_API.G_MISS_NUM
          THEN
                FND_MESSAGE.set_name('AHL','AHL_PRD_WORKORDER_ID_NULL');
                FND_MSG_PUB.ADD;
          ELSE

            /* sracha: already queried this info in translate_meaning_to_id procedure.
            If p_prd_resrc_txn_tbl(I).organization_id is null
               or p_prd_resrc_txn_tbl(I).organization_id=fnd_api.G_miss_num
            Then
                    OPEN get_wo_org_id(p_prd_resrc_txn_tbl(I).workorder_id);
                    FETCH get_wo_org_id INTO l_org_id;
                    CLOSE get_wo_org_id;
                    --FND_MESSAGE.set_name('AHL','AHL_PRD_ORGID_NULL');
                    --FND_MSG_PUB.ADD;
            Else
                    l_org_id := p_prd_resrc_txn_tbl(I).organization_id;
            End if;
            **sracha */

            IF (G_DEBUG = 'Y') THEN
              AHL_DEBUG_PUB.Debug('Before GetResourceDet:' || l_org_id || ':' || p_prd_resrc_txn_tbl(i).resource_name);
            END IF;

            Open GetResourceDet(--p_prd_resrc_txn_tbl(i).operation_sequence_num,
                                p_prd_resrc_txn_tbl(i).organization_id,
                                --p_prd_resrc_txn_tbl(i).workorder_id,
                                --p_prd_resrc_txn_tbl(i).resource_sequence_num);
                                p_prd_resrc_txn_tbl(i).resource_name);
            Fetch GetResourceDet into l_res_rec;
            if GetResourceDet%NotFound
            Then
                  FND_MESSAGE.set_name('AHL','AHL_PRD_RESOURCE_ID_INVALID');
                  FND_MESSAGE.SET_TOKEN('RES_NAME', p_prd_resrc_txn_tbl(i).resource_name);
                  FND_MSG_PUB.ADD;
            End if;
            Close GetResourceDet;

            Open  ValidWrkDet(p_prd_resrc_txn_tbl(I).workorder_id);
            Fetch ValidWrkDet into l_wrkrec;
            If ValidWrkDet%NOTFOUND
            THEN
                 FND_MESSAGE.set_name('AHL','AHL_PRD_WORKORDER_ID_INVALID');
                 FND_MESSAGE.SET_TOKEN('RECORD',p_prd_resrc_txn_tbl(I).WORKORDER_ID);
                 FND_MSG_PUB.ADD;
                 Close ValidWrkDet;
                 return;
            END IF;
            Close ValidWrkDet;

            -- rroy
            -- ACL Changes
            l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
                                   p_workorder_id => p_prd_resrc_txn_tbl(i).workorder_id,
                                   p_ue_id => NULL,
                                   p_visit_id => NULL,
                                   p_item_instance_id => NULL);
            IF l_return_status = FND_API.G_TRUE THEN
                 FND_MESSAGE.Set_Name('AHL', 'AHL_PP_RESTXN_UNTLCKD');
    	         FND_MESSAGE.Set_Token('WO_NAME', l_wrkrec.workorder_name);
                 FND_MSG_PUB.ADD;
                 IF G_DEBUG='Y' THEN
                    AHL_DEBUG_PUB.debug('Unit is Locked',l_proc_name);
                 END IF;
            END IF;
            -- rroy
            -- ACL Changes

            -- rroy
            -- R12
            -- From EAM User Guide
            -- Workorders which are Unreleased (1), Complete No Charge (5), Closed (12), On Hold (6)
            -- Cannot be charged resources
            -- Hence adding these additional statuses to the validation below
            -- Also, resources can be charged when the workorder status is Complete(4). Hence, removing
            -- this status from the validation below
            IF l_wrkrec.STATUS_CODE = '12' OR  l_wrkrec.STATUS_CODE = '6'
               OR l_wrkrec.STATUS_CODE = '13' OR  l_wrkrec.STATUS_CODE = '7'
               OR l_wrkrec.STATUS_CODE = '1' OR l_wrkrec.STATUS_CODE = '5'
            THEN
               FND_MESSAGE.set_name('AHL','AHL_PRD_RESOURCE_CANNOTEDIT');
               FND_MSG_PUB.ADD;
               return;
            END IF;
        END IF; -- work order ID is null

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'After Work Order ID validation:status is:' || l_wrkrec.STATUS_CODE,l_proc_name);
        END IF;

        IF p_prd_resrc_txn_tbl(I).workorder_operation_id IS NULL
  	OR p_prd_resrc_txn_tbl(I).workorder_operation_id=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.set_name('AHL','AHL_PRD_WORKORDER_OP_ID_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        -- validate operation sequence.
        If p_prd_resrc_txn_tbl(I).operation_sequence_num is null
	   or p_prd_resrc_txn_tbl(I).operation_sequence_num=fnd_api.g_miss_num
        Then
                FND_MESSAGE.set_name('AHL','AHL_PRD_OPSEQNUM_NULL');
                FND_MSG_PUB.ADD;
        Else
                --Select count(*) into l_ctr
                Select 1 into l_ctr
                from AHL_WORKORDER_OPERATIONS A
                WHERE A.WORKORDER_ID=p_prd_resrc_txn_tbl(I).workorder_id
                AND A.OPERATION_SEQUENCE_NUM=p_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM;

                IF nvl(l_ctr,0)=0
                THEN
                   FND_MESSAGE.set_name('AHL','AHL_PRD_INVALID_OP_SEQ_NUM');
                   FND_MESSAGE.SET_TOKEN('RECORD',p_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM);
                   FND_MSG_PUB.ADD;
                END IF;
        End if; -- p_prd_resrc_txn_tbl(I).operation_sequence_num is null

        -- Validate resource sequence.
        If p_prd_resrc_txn_tbl(I).resource_sequence_num is not null
	   and p_prd_resrc_txn_tbl(I).resource_sequence_num<>fnd_api.g_miss_num
        Then
            --Select count(*) into l_ctr
            Select 1 into l_ctr
            From AHL_OPERATION_RESOURCES  A
            WHERE A.WORKORDER_OPERATION_ID=p_prd_resrc_txn_tbl(I).workorder_OPERATION_id
            AND A.RESOURCE_SEQUENCE_NUM=p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM;

            IF nvl(l_ctr,0)=0
            THEN
               FND_MESSAGE.set_name('AHL','AHL_PRD_RESOURCE_SEQ_INV');
               FND_MESSAGE.SET_TOKEN('RECORD',p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
               FND_MSG_PUB.ADD;
            END IF;
        End if;

        -- validate department id.
        If p_prd_resrc_txn_tbl(I).department_id  is null or
           p_prd_resrc_txn_tbl(I).department_id=fnd_api.g_miss_num
        Then
                FND_MESSAGE.set_name('AHL','AHL_PRD_TRX_DEPTID_NULL');
                FND_MESSAGE.SET_TOKEN('OPER_RES',P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                      ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
                FND_MSG_PUB.ADD;
        End if;

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'After resource seq/dept validation',l_proc_name);
        END IF;

        --Validate for employee number when resource is 'Labor'
        IF l_res_rec.resource_type =2 THEN
           --Check for employee id
           IF p_prd_resrc_txn_tbl(I).employee_num IS NULL AND p_prd_resrc_txn_tbl(I).person_id IS NULL
           THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_EMPLOYEE_NULL');
              FND_MSG_PUB.ADD;
           ELSIF (p_prd_resrc_txn_tbl(I).person_id IS NULL) THEN  -- only when person_id is not there.
              OPEN chk_valid_emp_csr(p_prd_resrc_txn_tbl(I).organization_id,
                                     --p_prd_resrc_txn_tbl(I).workorder_id,
                                     --p_prd_resrc_txn_tbl(I).operation_sequence_num,
                                     --p_prd_resrc_txn_tbl(I).resource_sequence_num,
                                     p_prd_resrc_txn_tbl(I).resource_id,
                                     p_prd_resrc_txn_tbl(I).employee_num);
              FETCH chk_valid_emp_csr INTO l_junk;
              IF (chk_valid_emp_csr%NOTFOUND) THEN
                  FND_MESSAGE.set_name('AHL','AHL_PRD_EMPNUM_INVALID');
                  FND_MESSAGE.set_token('WRK_ID',l_wrkrec.workorder_name);
                  FND_MESSAGE.set_token('OP_SEQ',p_prd_resrc_txn_tbl(I).operation_sequence_num);
                  --FND_MESSAGE.set_token('RES_SEQ', p_prd_resrc_txn_tbl(I).resource_sequence_num);
                  FND_MESSAGE.set_token('RES_SEQ', p_prd_resrc_txn_tbl(I).resource_name);
                  FND_MSG_PUB.ADD;
              END IF;
              CLOSE chk_valid_emp_csr;

           ELSE
              OPEN chk_valid_empid_csr(p_prd_resrc_txn_tbl(I).organization_id,
                                       --p_prd_resrc_txn_tbl(I).workorder_id,
                                       --p_prd_resrc_txn_tbl(I).operation_sequence_num,
                                       --p_prd_resrc_txn_tbl(I).resource_sequence_num,
                                       p_prd_resrc_txn_tbl(I).resource_id,
                                       p_prd_resrc_txn_tbl(I).person_id);
              FETCH chk_valid_empid_csr INTO l_junk;
              IF (chk_valid_empid_csr%NOTFOUND) THEN
                  FND_MESSAGE.set_name('AHL','AHL_PRD_EMPID_INVALID');
                  FND_MESSAGE.set_token('WRK_ID',l_wrkrec.workorder_name);
                  FND_MESSAGE.set_token('OP_SEQ',p_prd_resrc_txn_tbl(I).operation_sequence_num);
                  --FND_MESSAGE.set_token('RES_SEQ', p_prd_resrc_txn_tbl(I).resource_sequence_num);
                  FND_MESSAGE.set_token('RES_SEQ', p_prd_resrc_txn_tbl(I).resource_name);
                  FND_MSG_PUB.ADD;
              END IF;
              CLOSE chk_valid_empid_csr;

           END IF; -- p_prd_resrc_txn_tbl(I).employee_num IS NULL

        END IF; -- l_res_rec.resource_type =2

        IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'After employee validation:employee_num:'|| p_prd_resrc_txn_tbl(I).employee_num || ':Person ID:' || p_prd_resrc_txn_tbl(I).person_id,l_proc_name);
        END IF;

        If p_prd_resrc_txn_tbl(I).uom_code  is null
        Then
                FND_MESSAGE.set_name('AHL','AHL_PRD_UOM_NULL');
                FND_MSG_PUB.ADD;
        End if;

        -- rroy
        -- R12 Tech UIs
        -- throw an error if both qty and end date are null
        If (p_prd_resrc_txn_tbl(I).qty is null OR p_prd_resrc_txn_tbl(I).qty = fnd_api.g_miss_num)
            AND (p_prd_resrc_txn_tbl(I).end_date IS NULL OR p_prd_resrc_txn_tbl(I).transaction_date IS NULL)
        THEN
                FND_MESSAGE.set_name('AHL','AHL_PRD_TRX_QTY_NULL');
                -- Change the message to reflect that at least one of qty or end date should be given
                FND_MESSAGE.SET_TOKEN('RECORD',P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                      ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
                FND_MSG_PUB.ADD;
        --OPER_RES rroy
        -- R12 Tech UIs
        -- Negative resource transactions are allowed
        /*elsif p_prd_resrc_txn_tbl(I).qty <=0
        then
                FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_QTY_INVALID');
                FND_MESSAGE.SET_TOKEN('OPER_RES',P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                       ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
                FND_MSG_PUB.ADD;
								*/
        Else
          IF (p_prd_resrc_txn_tbl(I).qty is NOT NULL AND p_prd_resrc_txn_tbl(I).end_date IS NOT NULL
              AND p_prd_resrc_txn_tbl(I).transaction_date IS NOT NULL)
          THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_TRX_QTY_NOT_NULL');
              FND_MESSAGE.SET_TOKEN('RECORD',P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                      ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
              FND_MSG_PUB.ADD;
          End if;

        End if;

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'After quantity validation' ,l_proc_name);
        END IF;

        -- validate and set txn date or end date.
        IF (p_prd_resrc_txn_tbl(i).end_date IS NULL) THEN
          IF (p_prd_resrc_txn_tbl(i).transaction_date) IS NOT NULL THEN
             p_prd_resrc_txn_tbl(i).end_date := p_prd_resrc_txn_tbl(i).transaction_date + (p_prd_resrc_txn_tbl(I).qty/24);

             IF (G_DEBUG = 'Y') THEN
               ahl_debug_pub.debug('End Date is null and Txn date is not Null. Txn Date is:' || to_char(p_prd_resrc_txn_tbl(i).transaction_date,'DD-MON-YYYY HH24:MI:SS'));
               ahl_debug_pub.debug('Calc End Date is:' || to_char(p_prd_resrc_txn_tbl(i).end_date,'DD-MON-YYYY HH24:MI:SS'));
             END IF;

             IF (p_prd_resrc_txn_tbl(i).end_date > sysdate)
             THEN
               FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_ENDDT_INVALID');
               FND_MESSAGE.SET_TOKEN('OPER_RES',P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                                 ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);

               FND_MESSAGE.SET_TOKEN('DATE', to_char(p_prd_resrc_txn_tbl(i).end_date,fnd_date.outputDT_mask));
               IF (G_DEBUG = 'Y') THEN
                 ahl_debug_pub.debug('End Date > sysdate' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
               END IF;
               FND_MSG_PUB.ADD;
             END IF;
          END IF; -- (p_prd_resrc_txn_tbl(i).transaction_date)
        ELSE -- p_prd_resrc_txn_tbl(i).end_date IS NULL
           IF (p_prd_resrc_txn_tbl(i).transaction_date IS NULL) THEN
              p_prd_resrc_txn_tbl(i).transaction_date := p_prd_resrc_txn_tbl(i).end_date - (p_prd_resrc_txn_tbl(I).qty/24) ;
             IF (G_DEBUG = 'Y') THEN
               ahl_debug_pub.debug('End Date is not null and Txn date is Null. End Date is:' || to_char(p_prd_resrc_txn_tbl(i).End_date,'DD-MON-YYYY HH24:MI:SS'));
               ahl_debug_pub.debug('Calc Txn Date is:' || to_char(p_prd_resrc_txn_tbl(i).transaction_date,'DD-MON-YYYY HH24:MI:SS'));
             END IF;
           END IF;
        END IF;


        -- rroy
        -- R12 Tech UIs
        -- Validations for Transaction Date
        -- transaction date should be less than or equal to sysdate
        IF p_prd_resrc_txn_tbl(i).transaction_date IS NOT NULL THEN
           IF p_prd_resrc_txn_tbl(i).transaction_date > sysdate THEN
             IF (G_DEBUG = 'Y') THEN
               ahl_debug_pub.debug('Trx Date is greater than sysdate:' || to_char(p_prd_resrc_txn_tbl(i).transaction_date,'DD-MON-YYYY HH24:MI:SS'));
             END IF;

                FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_DT_INVALID');
                FND_MESSAGE.SET_TOKEN('OPER_RES',P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                                 ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
                FND_MESSAGE.SET_TOKEN('DATE', to_char(p_prd_resrc_txn_tbl(i).transaction_date,fnd_date.outputDT_mask));
               IF (G_DEBUG = 'Y') THEN
                 ahl_debug_pub.debug('Txn Date > sysdate' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
               END IF;
                FND_MSG_PUB.ADD;
           END IF;-- IF p_prd_resrc_txn_tbl(i).transaction_date > sysdate THEN


           -- transaction date should be greater than the workorder release date
           OPEN get_wo_release_date(l_wrkrec.wip_entity_id);
           FETCH get_wo_release_date INTO l_release_date;
           CLOSE get_wo_release_date;

           -- Not checking to see that the release date is not null
           -- because if it is null, then the workorder is not released and
           -- the resource transactions are not allowed for unreleased workorders in any case.
           IF p_prd_resrc_txn_tbl(i).transaction_date <
                nvl(l_release_date, p_prd_resrc_txn_tbl(i).transaction_date - 1)
           THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_DT_RLSDT');
              FND_MESSAGE.SET_TOKEN('OPER_RES', P_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM||'-'
                                    ||p_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
              FND_MESSAGE.SET_TOKEN('DATE',to_char(l_release_date,fnd_date.outputDT_mask));
              FND_MESSAGE.set_token('WRK_ID',l_wrkrec.workorder_name);
              FND_MSG_PUB.ADD;
           END IF;-- IF p_prd_resrc_txn_tbl(i).transaction_date < l_release_date THEN
	END IF;-- IF p_prd_resrc_txn_tbl(i).transaction_date IS NOT NULL THEN

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'After transaction date validation' ,l_proc_name);
        END IF;

        -- validate serial number.
        -- Adithya modified the code to take department_id for Bug # 6326254 - Start
        IF p_prd_resrc_txn_tbl(i).serial_number  IS NOT NULL AND
           p_prd_resrc_txn_tbl(i).serial_number<>FND_API.G_MISS_CHAR
        THEN

          Open get_instance_sernum (p_prd_resrc_txn_tbl(i).department_id,
                                    p_prd_resrc_txn_tbl(i).serial_number,
                                    p_prd_resrc_txn_tbl(i).resource_id,
                                    p_prd_resrc_txn_tbl(i).organization_id
                                    );
          FETCH get_instance_sernum INTO l_inst_id;
      	  IF get_instance_sernum%NOTFOUND
          THEN
            FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_SERNUM_INVALID');
            FND_MESSAGE.SET_TOKEN('SERNUMB',P_prd_resrc_txn_tbl(I).serial_number);
            FND_MSG_PUB.ADD;
    	  END IF;

          Close get_instance_sernum;
         -- Adithya modified the code to take department_id for Bug # 6326254 - End
        /*
        ELSE
          IF (l_res_rec.resource_type = 1) THEN
             FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_MACH_RES_REQD' );
             FND_MESSAGE.set_token( 'WO_NAME', l_wrkrec.workorder_name );
             FND_MESSAGE.set_token( 'OP_SEQ', p_prd_resrc_txn_tbl(I).operation_sequence_num );
             FND_MESSAGE.set_token( 'RES_SEQ', p_prd_resrc_txn_tbl(I).resource_sequence_num );
             FND_MSG_PUB.add;
          END IF;*/

        END IF; -- p_prd_resrc_txn_tbl(i).serial_number

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'After serial number validation' ,l_proc_name);
        END IF;

     END LOOP;
END IF; -- IF p_prd_resrc_txn_tbl.COUNT >0
IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'End of procedure',l_proc_name);
END IF;

--Adithya added the following debug
FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
IF l_msg_count > 0 THEN
    if (l_msg_count = 1) THEN

      IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( l_msg_data,l_proc_name);
      END IF;
    else
      FOR i IN 1..l_msg_count LOOP

              fnd_msg_pub.get(
                 p_encoded       => 'F',
                 p_data           => l_msg_data,
                 p_msg_index_out  => l_msg_index_out);
                 IF G_DEBUG='Y' THEN
                   AHL_DEBUG_PUB.debug( 'Err mesg(i) -'|| i || ' ' || l_msg_data,l_proc_name);
                 END IF;

      end loop;
    end if;
  END IF;

END;


PROCEDURE TRANSLATE_MEANING_TO_ID
(
 p_x_prd_resrc_txn_tbl            IN OUT  NOCOPY  PRD_RESOURCE_TXNS_TBL,
 x_return_status                IN              VARCHAR2
)
AS

Cursor CurGetOperSeq(c_Oper_seq  number,c_work_id number)
Is
/*
Select workorder_operation_id, department_id, department_code
from  ahl_workorder_operations_v
where operation_sequence_num=c_oper_seq
and   workorder_id=c_work_id;
*/

Select awo.workorder_operation_id, wop.department_id, bd.department_code,
       wo.organization_id
from ahl_workorder_tasks_v wo, ahl_workorder_operations awo, bom_departments bd,
     wip_operations wop
where wo.wip_entity_id = wop.wip_entity_id
and wop.operation_seq_num = c_Oper_seq
and wop.department_id = bd.department_id
and wo.workorder_id = awo.workorder_id
and awo.operation_sequence_num=c_oper_seq
and wo.workorder_id=c_work_id;

l_oper_rec           CurGetOperSeq%rowtype;


Cursor CurGetResSeq(c_workorder_operation_id number,c_res_seq  number)
Is
Select a.resource_id, BR.UNIT_OF_MEASURE UOM_CODE, br.resource_code
from ahl_operation_resources a, bom_resources br
where a.resource_id = br.resource_id
and a.workorder_operation_id = c_workorder_operation_id
and resource_sequence_num=c_res_seq;

l_res_Seq_rec            CurGetResSeq%rowtype;


Cursor CurGetDeptdet(c_department_code Varchar2,c_org_id number)
Is
Select department_id
From  BOM_DEPARTMENTS
Where department_code=C_department_code
and   organization_id=c_org_id;

l_deptrec               CurGetDeptdet%rowtype;


/*
Cursor Curres(WORK_ID NUMBER,C_RES_SEQ NUMBER)
Is
Select  AOR.RESOURCE_ID, BOM.UNIT_OF_MEASURE UOM_CODE
FROM AHL_OPERATION_RESOURCES AOR, AHL_WORKORDER_OPERATIONS AWO , BOM_RESOURCES BOM, MFG_LOOKUPS MFG
WHERE AOR.RESOURCE_SEQUENCE_NUM = C_RES_SEQ
AND AOR.WORKORDER_OPERATION_ID = AWO.WORKORDER_OPERATION_ID
AND AWO.WORKORDER_ID = WORK_ID
AND AOR.RESOURCE_ID = BOM.RESOURCE_ID
AND MFG.LOOKUP_TYPE(+) = 'BOM_RESOURCE_TYPE'
AND MFG.LOOKUP_CODE(+) = BOM.RESOURCE_TYPE;
*/

/*Select  * -- resource_id, UOM_CODE
From  AHL_PP_REQUIREMENT_V
Where JOB_ID=WORK_ID
AND   RESOURCE_SEQUENCE=C_RES_SEQ;*/

Cursor getResID(p_resource_code IN VARCHAR2,
                p_org_id        IN NUMBER,
                p_dept_id       IN NUMBER,
                p_workorder_operation_id IN NUMBER)
Is
SELECT BR.RESOURCE_ID, aor.resource_sequence_num, BR.UNIT_OF_MEASURE UOM_CODE
FROM BOM_RESOURCES BR, BOM_DEPARTMENT_RESOURCES BDR, ahl_operation_resources aor
WHERE BR.RESOURCE_ID = BDR.RESOURCE_ID
  AND BDR.DEPARTMENT_ID = p_dept_id
  AND BR.RESOURCE_CODE = p_resource_code
  AND BR.ORGANIZATION_ID = p_org_id
  AND aor.resource_id(+) = BDR.resource_id
  AND aor.workorder_operation_id(+) = p_workorder_operation_id;

--l_Resrec              Curres%rowtype;

Cursor CurGetActivity(C_ACTIVITY VARCHAR2)
Is
Select activity_id
From  CST_ACTIVITIES
Where ACTIVITY=C_ACTIVITY;

Cursor CurGetReason(C_Reason Varchar2)
Is
Select Reason_id
From   mtl_transaction_reasons
Where  reason_name=C_Reason
AND  NVL(disable_date,SYSDATE+1) >=TRUNC(SYSDATE);

Cursor CurGetEmployee(C_EMPLOYEE Varchar2, c_org_id number)
Is
/*
SELECT person_id,employee_number,full_name
FROM per_all_people_f pf,per_person_types pt
WHERE pf.person_type_id = pt.person_type_id
AND   pt.system_person_type = 'EMP'
AND UPPER(pf.employee_number) LIKE UPPER(C_EMPLOYEE)
AND TRUNC(SYSDATE) BETWEEN TRUNC(pf.effective_start_date)
AND TRUNC(nvl(pf.effective_end_Date,sysdate+1)) ORDER BY 1;
*/

-- Bug# 4553747.
SELECT employee_id person_id, employee_num employee_number, full_name
FROM   mtl_employees_current_view
WHERE  UPPER(employee_num) LIKE UPPER(C_EMPLOYEE)
AND organization_id = c_org_id;

l_emp_rec               CurGetEmployee%Rowtype;

Cursor get_wo_org_id(c_wo_id number)
Is
Select vst.organization_id
from  ahl_workorders wo,
ahl_visits_b vst
where vst.visit_id = wo.visit_id
and wo.workorder_id = c_wo_id;

--Adithya commented out the following code as part of fix for bug# 6326254.
 /* CURSOR get_instance_sernum (c_department_id NUMBER,c_serial_number VARCHAR2)
  IS
    SELECT instance_id
    FROM bom_dept_res_instances
    WHERE department_id = c_department_id
    and   Serial_Number=c_serial_number; */

l_ctr                   NUMBER:=0;

l_proc_name             VARCHAR2(40) := 'TRANSLATE_MEANING_TO_ID';

BEGIN

     IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.enable_debug;
     END IF;

IF p_x_prd_resrc_txn_tbl.COUNT>0
THEN
     FOR i in p_x_prd_resrc_txn_tbl.FIRST..p_x_prd_resrc_txn_tbl.LAST
        LOOP
        ---
         IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( ' API Input Dump->',l_proc_name);
           AHL_DEBUG_PUB.debug( ' workorder_id------->'||p_x_prd_resrc_txn_tbl(I).WORKORDER_ID,l_proc_name);
           AHL_DEBUG_PUB.debug( ' workorder_Oper_id-->'||p_x_prd_resrc_txn_tbl(I).WORKORDER_operation_id,l_proc_name);
           AHL_DEBUG_PUB.debug( ' operation_sequence->'||p_x_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM,l_proc_name);
           AHL_DEBUG_PUB.debug( ' resource_sequence-->'||p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_num,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Organization id -->'||p_x_prd_resrc_txn_tbl(I).organization_id,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Resource     id -->'||p_x_prd_resrc_txn_tbl(I).resource_id,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Serial Number------->'||p_x_prd_resrc_txn_tbl(I).serial_number,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Instance Id------->'||p_x_prd_resrc_txn_tbl(I).instance_id,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Quantity------->'||p_x_prd_resrc_txn_tbl(I).qty,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Employee Num------->'||p_x_prd_resrc_txn_tbl(I).employee_num,l_proc_name);
           AHL_DEBUG_PUB.debug( ' Person ID------->'||p_x_prd_resrc_txn_tbl(I).person_id,l_proc_name);
           AHL_DEBUG_PUB.debug( ' uom_code------->'||p_x_prd_resrc_txn_tbl(I).uom_code,l_proc_name);
           AHL_DEBUG_PUB.debug( ' uom_meaning------->'||p_x_prd_resrc_txn_tbl(I).uom_meaning,l_proc_name);
         END IF;
         ---

        IF p_x_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM IS NOT NULL AND
           p_x_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM<>FND_API.G_MISS_NUM
        THEN
           Open CurGetOperSeq(p_x_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM,
                              p_x_prd_resrc_txn_tbl(I).WORKORDER_ID);

           FETCH CurGetOperSeq into l_oper_rec;

           IF CurGetOperSeq%NOTFOUND
           THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_OPERATION_SEQ_INV');
              FND_MESSAGE.SET_TOKEN('RECORD',p_x_prd_resrc_txn_tbl(I).operation_Sequence_num);
              FND_MSG_PUB.ADD;
           Else
              p_x_prd_resrc_txn_tbl(I).Workorder_operation_id:=l_oper_rec.workorder_operation_id;

              IF (p_x_prd_resrc_txn_tbl(I).organization_id IS NULL) OR
                 (p_x_prd_resrc_txn_tbl(I).organization_id = FND_API.G_MISS_NUM) THEN
                  p_x_prd_resrc_txn_tbl(I).organization_id:=l_oper_rec.organization_id;
              END IF;

              -- Adithya commented out the code for bug# 6326254. Charge deparment can be different
              -- from the operation department.
              -- Adithya added code to default dept id/code if they are null - Bug# 6452479.
              IF ( p_x_prd_resrc_txn_tbl(I).department_id IS NULL OR
                   p_x_prd_resrc_txn_tbl(I).department_id = FND_API.G_MISS_NUM ) AND
                   ( p_x_prd_resrc_txn_tbl(I).department_code IS NULL OR
                   p_x_prd_resrc_txn_tbl(I).department_code = FND_API.G_MISS_CHAR )
              THEN
                IF G_DEBUG='Y' THEN
                   AHL_DEBUG_PUB.debug( 'Defaulting Dept Id and Code',l_proc_name);
                END IF;
                p_x_prd_resrc_txn_tbl(I).department_id:=l_oper_rec.department_id;
                p_x_prd_resrc_txn_tbl(I).department_code:=l_oper_rec.department_code;
                p_x_prd_resrc_txn_tbl(I).organization_id:=l_oper_rec.organization_id;
              ELSIF ( p_x_prd_resrc_txn_tbl(I).department_id IS NULL OR
                   p_x_prd_resrc_txn_tbl(I).department_id = FND_API.G_MISS_NUM ) AND
                   ( p_x_prd_resrc_txn_tbl(I).department_code IS NOT NULL AND
                   p_x_prd_resrc_txn_tbl(I).department_code <> FND_API.G_MISS_CHAR )
              THEN
                  OPEN CurGetDeptdet(p_x_prd_resrc_txn_tbl(I).department_code
                      ,p_x_prd_resrc_txn_tbl(I).organization_id);
                  FETCH CurGetDeptdet INTO p_x_prd_resrc_txn_tbl(I).department_id;
                  IF(CurGetDeptdet%NOTFOUND)THEN
                    FND_MESSAGE.set_name('AHL','AHL_PRD_TRX_DEPT_INV');
                    FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_resrc_txn_tbl(I).DEPARTMENT_CODE);
                    FND_MESSAGE.SET_TOKEN('RECORD',nvl(p_x_prd_resrc_txn_tbl(I).Operation_Sequence_num,'')
      	   	            ||'-'||nvl(p_x_prd_resrc_txn_tbl(I).resource_Sequence_num,''));
                     FND_MSG_PUB.ADD;
                  END IF;
                  CLOSE CurGetDeptdet;

              END IF;

           END IF;
           CLOSE CurGetOperSeq;
        ELSE
           FND_MESSAGE.set_name('AHL','AHL_PRD_OPSEQNUM_NULL');
           FND_MSG_PUB.ADD;
        END IF; -- p_x_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM

        If p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM is not null and
           p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM<>fnd_api.g_miss_num
        Then

           Open  CurGetResSeq(p_x_prd_resrc_txn_tbl(I).WORKORDER_OPERATION_ID,
                              p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
           FETCH CurGetResSeq into l_res_seq_rec;
           IF CurGetResSeq%NOTFOUND
           THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_RESOURCE_SEQ_INV');
              FND_MESSAGE.SET_TOKEN('RECORD',p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM,false);
              FND_MSG_PUB.ADD;
           ELSE
              p_x_prd_resrc_txn_tbl(I).UOM_CODE:=l_res_seq_rec.UOM_CODE;
              p_x_prd_resrc_txn_tbl(I).RESOURCE_ID:=l_res_seq_rec.RESOURCE_ID;
              p_x_prd_resrc_txn_tbl(I).RESOURCE_NAME :=l_res_seq_rec.RESOURCE_CODE;
              /*
              Open Curres(p_x_prd_resrc_txn_tbl(I).WORKORDER_ID,
                 --         p_x_prd_resrc_txn_tbl(I).WORKORDER_OPERATION_ID,
                          p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM);
              FETCH Curres into l_Resrec;
              IF Curres%NOTFOUND
              THEN
                 FND_MESSAGE.set_name('AHL','AHL_PRD_OPERATION_SEQ_INV');
                 FND_MESSAGE.SET_TOKEN('RECORD',p_x_prd_resrc_txn_tbl(I).operation_Sequence_num,false);
                 FND_MSG_PUB.ADD;
              ELSE
                 p_x_prd_resrc_txn_tbl(I).resource_id:=l_resrec.resource_id;
                 p_x_prd_resrc_txn_tbl(I).UOM_CODE:=l_resrec.UOM_CODE;
              END IF;
              CLOSE Curres;
              */
           END If; -- CurGetResSeq%NOTFOUND
           CLOSE CurGetResSeq;
        Else
          -- check resource name.
          IF (p_x_prd_resrc_txn_tbl(I).Resource_Name is not null and
              p_x_prd_resrc_txn_tbl(I).Resource_Name <> fnd_api.g_miss_char) THEN
            OPEN getResID(p_x_prd_resrc_txn_tbl(I).resource_name,
                          p_x_prd_resrc_txn_tbl(I).organization_id,
                          p_x_prd_resrc_txn_tbl(I).department_id,
                          p_x_prd_resrc_txn_tbl(I).workorder_operation_id);
            FETCH getResID INTO p_x_prd_resrc_txn_tbl(I).resource_id,
                                p_x_prd_resrc_txn_tbl(I).resource_sequence_num,
                                p_x_prd_resrc_txn_tbl(I).UOM_CODE;
            IF (getResID%NOTFOUND) THEN
              FND_MESSAGE.set_name('AHL','AHL_PP_RESOURCE_NOT_EXISTS');
              FND_MSG_PUB.ADD;
            END IF;
            CLOSE getResID;
          END IF; -- p_x_prd_resrc_txn_tbl(I).Resource_Name

        End if; -- p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM

        /*
        IF p_x_prd_resrc_txn_tbl(I).organization_id IS NULL THEN
           OPEN get_wo_org_id(p_x_prd_resrc_txn_tbl(I).WORKORDER_ID);
           FETCH get_wo_org_id INTO p_x_prd_resrc_txn_tbl(I).organization_id;
           CLOSE get_wo_org_id;
	END IF;

        IF p_x_prd_resrc_txn_tbl(I).department_CODE IS NOT NULL AND
           p_x_prd_resrc_txn_tbl(I).department_CODE<>FND_API.G_MISS_CHAR
        THEN
           OPEN  CurGetDeptdet(p_x_prd_resrc_txn_tbl(I).department_CODE,
                               p_x_prd_resrc_txn_tbl(I).organization_id);
           FETCH CurGetDeptdet into l_deptrec;
           If CurGetDeptdet%NOTFOUND
           Then
              FND_MESSAGE.set_name('AHL','AHL_PRD_TRX_DEPT_INV');
              FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_resrc_txn_tbl(I).DEPARTMENT_CODE);
              FND_MESSAGE.SET_TOKEN('RECORD',nvl(p_x_prd_resrc_txn_tbl(I).Operation_Sequence_num,'')
      	   	||'-'||nvl(p_x_prd_resrc_txn_tbl(I).resource_Sequence_num,''));
              FND_MSG_PUB.ADD;
           Else
              p_x_prd_resrc_txn_tbl(I).DEPARTMENT_ID:=L_DEPTREC.DEPARTMENT_ID;
           End If;
           CLOSE CurGetDeptdet;
        END IF;
        */

        IF p_x_prd_resrc_txn_tbl(I).ACTIVITY_MEANING IS NOT NULL AND
           p_x_prd_resrc_txn_tbl(I).ACTIVITY_MEANING<>FND_API.G_MISS_CHAR
        THEN
           OPEN  CurGetActivity(p_x_prd_resrc_txn_tbl(I).ACTIVITY_MEANING);
           FETCH CurGetActivity into p_x_prd_resrc_txn_tbl(I).ACTIVITY_ID;
           If    CurGetActivity%NOTFOUND
           Then
              FND_MESSAGE.set_name('AHL','AHL_PRD_ACTIVITY_INV');
              FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_resrc_txn_tbl(I).Activity_Meaning);
              FND_MESSAGE.SET_TOKEN('RECORD',nvl(p_x_prd_resrc_txn_tbl(I).Operation_Sequence_num,
                                    '')||'-'||nvl(p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM,''));
              FND_MSG_PUB.ADD;
           End If;
           CLOSE CurGetActivity;
        END IF;

        IF p_x_prd_resrc_txn_tbl(I).REASON IS NOT NULL AND
           p_x_prd_resrc_txn_tbl(I).REASON<>FND_API.G_MISS_CHAR
        THEN
           OPEN  CurGetReason(p_x_prd_resrc_txn_tbl(I).Reason);
           FETCH CurGetReason into p_x_prd_resrc_txn_tbl(I).REASON_ID;
           If    CurGetReason%NOTFOUND
           Then
              FND_MESSAGE.set_name('AHL','AHL_PRD_REASON_INV');
              FND_MESSAGE.SET_TOKEN('FIELD1',p_x_prd_resrc_txn_tbl(I).Reason,false);
              FND_MESSAGE.SET_TOKEN('RECORD',nvl(p_x_prd_resrc_txn_tbl(I).Operation_Sequence_num,
                                    '')||'-'||nvl(p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_NUM,''),false);
              FND_MSG_PUB.ADD;
           End If;
           CLOSE CurGetReason;
        END IF;

        --Adithya commented out the following code
	/*
	IF p_x_prd_resrc_txn_tbl(I).serial_number  IS NOT NULL AND
           p_x_prd_resrc_txn_tbl(I).serial_number<>FND_API.G_MISS_CHAR
        THEN

           Open get_instance_sernum (p_x_prd_resrc_txn_tbl(i).department_id,
                                     p_x_prd_resrc_txn_tbl(i).serial_number);
           FETCH get_instance_sernum INTO p_x_prd_resrc_txn_tbl(I).instance_id;
           IF get_instance_sernum%NOTFOUND
           THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_SERNUM_INVALID');
              FND_MESSAGE.SET_TOKEN('SERNUMB',p_x_prd_resrc_txn_tbl(I).serial_number);
              FND_MSG_PUB.ADD;
           END IF;
           Close get_instance_sernum;

        END IF;
	*/


        If p_x_prd_resrc_txn_tbl(I).EMPLOYEE_NUM is not null and
           p_x_prd_resrc_txn_tbl(I).EMPLOYEE_NUM<>fnd_api.g_miss_CHAR
        Then
           Open  CurGetEmployee(p_x_prd_resrc_txn_tbl(I).EMPLOYEE_NUM,p_x_prd_resrc_txn_tbl(I).organization_id);
           FETCH CurGetEmployee into l_emp_rec;
           IF  CurGetEmployee%NOTFOUND
           THEN
              FND_MESSAGE.set_name('AHL','AHL_PRD_EMPNUM_INV');
              FND_MESSAGE.SET_TOKEN('EMP_NUM',p_x_prd_resrc_txn_tbl(I).EMPLOYEE_NUM);
              FND_MSG_PUB.ADD;
           ELSE
              p_x_prd_resrc_txn_tbl(I).PERSON_ID:=l_emp_rec.person_id;
           END IF;
           CLOSE CurGetEmployee;
        End if;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( ' workorder_id------->'||p_x_prd_resrc_txn_tbl(I).WORKORDER_ID);
	  AHL_DEBUG_PUB.debug( ' workorder_Oper_id-->'||p_x_prd_resrc_txn_tbl(I).WORKORDER_operation_id);
	  AHL_DEBUG_PUB.debug( ' operation_sequence->'||p_x_prd_resrc_txn_tbl(I).OPERATION_SEQUENCE_NUM);
	  AHL_DEBUG_PUB.debug( ' resource_sequence-->'||p_x_prd_resrc_txn_tbl(I).RESOURCE_SEQUENCE_num);
	  AHL_DEBUG_PUB.debug( ' Organization id  -->'||p_x_prd_resrc_txn_tbl(I).organization_id);
	  AHL_DEBUG_PUB.debug( ' Resource     id  -->'||p_x_prd_resrc_txn_tbl(I).resource_id);
          AHL_DEBUG_PUB.debug( ' Serial Number------->'||p_x_prd_resrc_txn_tbl(I).serial_number);
          AHL_DEBUG_PUB.debug( ' Instance Id------->'||p_x_prd_resrc_txn_tbl(I).instance_id);
          AHL_DEBUG_PUB.debug( ' Person Id------->'|| p_x_prd_resrc_txn_tbl(I).person_id);
          AHL_DEBUG_PUB.debug( ' Quantity------->'||p_x_prd_resrc_txn_tbl(I).qty,l_proc_name);
          AHL_DEBUG_PUB.debug( ' Employee Num------->'||p_x_prd_resrc_txn_tbl(I).employee_num,l_proc_name);
          AHL_DEBUG_PUB.debug( ' uom_code------->'||p_x_prd_resrc_txn_tbl(I).uom_code,l_proc_name);
          AHL_DEBUG_PUB.debug( ' uom_meaning------->'||p_x_prd_resrc_txn_tbl(I).uom_meaning,l_proc_name);

	END IF;
   END LOOP;
END IF;
END;


PROCEDURE PROCESS_RESOURCE_TXNS
(
 p_api_version                  IN  		NUMBER     := 1.0,
 p_init_msg_list                IN  		VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  		VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  		NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  		VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  		VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY             VARCHAR2,
 x_msg_count                    OUT NOCOPY             NUMBER,
 x_msg_data                     OUT NOCOPY             VARCHAR2,
 p_x_prd_resrc_txn_tbl          IN OUT   NOCOPY PRD_RESOURCE_TXNS_TBL
)
AS
 l_api_name     CONSTANT VARCHAR2(30):= 'PROCESS_RESOURCE_TXNS';
 l_api_version  CONSTANT NUMBER:= 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
 l_commit                VARCHAR2(1):= FND_API.G_FALSE;
 l_ahl_res_txn_tbl       AHL_WIP_JOB_PVT.ahl_res_txn_tbl_type;
 l_wip_entity_id         NUMBER;
 l_txn_group_id          NUMBER;
 l_ctr                   NUMBER:=0;
 l_str_len               NUMBER := 0;
 l_short_mesg            VARCHAR2(21) := 'Machine Serial #: ';
 l_oper_start_dt         DATE;
 l_oper_end_dt           DATE;

 l_Resrc_Require_Tbl     AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type;

 Cursor GetWipid (C_WORK_ID  Number)
 Is
 Select wip_entity_id
 from ahl_workorders
 where workorder_id=c_work_id;

 Cursor get_oper_res_det(p_workorder_id IN NUMBER,
                         p_operation_seq_num IN NUMBER)
 Is
 Select WOP.FIRST_UNIT_START_DATE, WOP.LAST_UNIT_COMPLETION_DATE,
        (select nvl(max(resource_seq_num),0) + 10 from wip_operation_resources
         where wip_entity_id = WOP.wip_entity_id and operation_seq_num = WOP.operation_seq_num),
        WOP.Department_id
 From   WIP_OPERATIONS WOP, AHL_WORKORDERS AW
 Where  AW.wip_entity_id = WOP.wip_entity_id
   and  AW.workorder_id = p_workorder_id
   and  WOP.operation_seq_num = p_operation_seq_num;

BEGIN
        SAVEPOINT PROCESS_RESOURCE_TRANX;

   --   Enable Debug

        IF G_DEBUG='Y' THEN
		--  AHL_DEBUG_PUB.enable_debug;
          AHL_DEBUG_PUB.debug('At start of procedure PROCESS_RESOURCE_TRANX');
	END IF;



   --   Standard call to check for call compatibility.

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                         p_api_version,
                                         l_api_name,G_PKG_NAME)  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   --   Initialize message list if p_init_msg_list is set to TRUE.

        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

   --   Initialize API return status to success

        x_return_status:=FND_API.G_RET_STS_SUCCESS;


    --  Debug info.

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Enter PROCESS_RESOURCE_TRNX',L_API_NAME);
	END IF;
        IF p_module_type IN ('JSP','OAF') THEN
          IF p_x_prd_resrc_txn_tbl.COUNT>0 THEN
             FOR i in p_x_prd_resrc_txn_tbl.FIRST..p_x_prd_resrc_txn_tbl.LAST LOOP
                 p_x_prd_resrc_txn_tbl(i).DEPARTMENT_ID := NULL;
             END LOOP;
          END IF;
        END IF;
    --  Convert meanings to ID values.
        TRANSLATE_MEANING_TO_ID
        (
         p_x_prd_resrc_txn_tbl      => p_x_prd_resrc_txn_tbl,
         x_return_status            =>x_return_status
        );

    --  check error message.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'Error Thrown in translate',L_API_NAME);
	   END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


   --   Start of API Body

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

   --   Validate input.
        VALIDATE_RES_TRNX
        (
         p_prd_resrc_txn_tbl            => p_x_prd_resrc_txn_tbl,
         x_return_status                =>x_Return_status
        );


   --   check errors.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug( 'Error Thrown In Validation',L_API_NAME);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_ctr := 0;

        -- Create resource requirements if it does not exist.
        FOR i IN p_x_prd_resrc_txn_tbl.FIRST..p_x_prd_resrc_txn_tbl.LAST
        LOOP
           IF (p_x_prd_resrc_txn_tbl(i).resource_sequence_num is null OR
               p_x_prd_resrc_txn_tbl(i).resource_sequence_num = fnd_api.g_miss_num) THEN

               l_Resrc_Require_Tbl(l_ctr).workorder_id := p_x_prd_resrc_txn_tbl(i).workorder_id;
               l_Resrc_Require_Tbl(l_ctr).operation_seq_number := p_x_prd_resrc_txn_tbl(i).operation_sequence_num;
               -- get operation start and end dates.
               OPEN get_oper_res_det(p_x_prd_resrc_txn_tbl(i).workorder_id,
                                     p_x_prd_resrc_txn_tbl(i).operation_sequence_num);
               FETCH get_oper_res_det INTO l_oper_start_dt, l_oper_end_dt,
                                           p_x_prd_resrc_txn_tbl(i).resource_sequence_num,
                                           -- added to fix bug# 6326254.
                                           p_x_prd_resrc_txn_tbl(i).DEPARTMENT_ID;


               IF (get_oper_res_det%NOTFOUND) THEN
                 FND_MESSAGE.set_name('AHL','AHL_PRD_OPERATION_SEQ_INV');
                 FND_MESSAGE.SET_TOKEN('RECORD',p_x_prd_resrc_txn_tbl(I).operation_Sequence_num);
                 FND_MSG_PUB.ADD;
               END IF;
               CLOSE get_oper_res_det;

               IF (G_DEBUG = 'Y') THEN
                  AHL_DEBUG_PUB.debug('Resource seq number:' || p_x_prd_resrc_txn_tbl(i).resource_sequence_num);
               END IF;

               l_Resrc_Require_Tbl(l_ctr).resource_seq_number :=
                                     p_x_prd_resrc_txn_tbl(i).resource_sequence_num;
               l_Resrc_Require_Tbl(l_ctr).oper_start_date := l_oper_start_dt;
               l_Resrc_Require_Tbl(l_ctr).oper_end_date   := l_oper_end_dt;
               l_Resrc_Require_Tbl(l_ctr).req_start_date  := l_oper_start_dt;
               l_Resrc_Require_Tbl(l_ctr).req_end_date    := l_oper_end_dt;
               l_Resrc_Require_Tbl(l_ctr).resource_id    := p_x_prd_resrc_txn_tbl(i).resource_id;
               l_Resrc_Require_Tbl(l_ctr).resource_Name  := p_x_prd_resrc_txn_tbl(i).resource_Name;

               l_Resrc_Require_Tbl(l_ctr).uom_code :=substr(p_x_prd_resrc_txn_tbl(i).UOM_CODE,1,3);
               -- commented this out as this attribute is now charge department.
               --l_Resrc_Require_Tbl(l_ctr).department_id :=p_x_prd_resrc_txn_tbl(i).DEPARTMENT_ID;
               l_Resrc_Require_Tbl(l_ctr).quantity := 1;

               IF p_x_prd_resrc_txn_tbl(i).qty IS NOT NULL THEN
                   l_Resrc_Require_Tbl(l_ctr).duration := p_x_prd_resrc_txn_tbl(i).qty;
               ELSE
                   -- UOM is hours, so multiplying by 24
                   l_Resrc_Require_Tbl(l_ctr).duration := ROUND((p_x_prd_resrc_txn_tbl(i).end_date -
                                                         p_x_prd_resrc_txn_tbl(i).transaction_date) * 24, 2);
               END IF;
               l_ctr := l_ctr + 1;
            END IF; -- p_x_prd_resrc_txn_tbl(i).resource_sequence_num is null
        END LOOP;

        IF (l_Resrc_Require_tbl.count > 0) THEN
            AHL_PP_RESRC_REQUIRE_PVT.Process_Resrc_Require (
                  p_api_version     => 1.0,
                  p_init_msg_list   => Fnd_Api.G_FALSE,
                  p_commit          => Fnd_Api.G_FALSE,
                  p_module_type     => 'JSP',  -- need to pass JSP otherwise EAM api is not called.
                  p_operation_flag  => 'C',
                  p_interface_flag  => NULL,
                  p_x_Resrc_Require_tbl => l_Resrc_Require_tbl,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data);

            IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               IF (fnd_log.level_error >= G_DEBUG)THEN
                   fnd_log.string
                  (
                    fnd_log.level_error,
                    'ahl.plsql.AHL_PRD_RESOURCE_TRANX_PVT.Process_Resource_Txns',
                    'AHL_PP_RESRC_REQUIRE_PVT.Process_Resrc_Require API returned error'
                  );
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Before Process transactions',L_API_NAME);
           AHL_DEBUG_PUB.debug( 'Number of Records'||p_x_prd_resrc_txn_tbl.count,L_API_NAME);
	END IF;

        l_ctr := 0;
        FOR i IN p_x_prd_resrc_txn_tbl.FIRST..p_x_prd_resrc_txn_tbl.LAST
        LOOP

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Enter loop ',L_API_NAME);
	END IF;

         IF p_x_prd_resrc_txn_tbl(i).DML_operation = 'C'
         THEN
          Open   GetWipid (p_x_prd_resrc_txn_tbl(i).workorder_id);
          Fetch  GetWipid into l_wip_entity_id;
          Close  GetWipid;

          IF G_DEBUG='Y' THEN
	    AHL_DEBUG_PUB.debug( 'Workorder id'||p_x_prd_resrc_txn_tbl(i).workorder_id,L_API_NAME);
          END IF;

          l_ahl_res_txn_tbl(l_ctr).wip_entity_id    := l_wip_entity_id;
          l_ahl_res_txn_tbl(l_ctr).operation_seq_num    :=p_x_prd_resrc_txn_tbl(i).Operation_sequence_num;
          l_ahl_res_txn_tbl(l_ctr).resource_seq_num     :=p_x_prd_resrc_txn_tbl(i).Resource_sequence_num;
          l_ahl_res_txn_tbl(l_ctr).resource_id          :=p_x_prd_resrc_txn_tbl(i).RESOURCE_ID;
          l_ahl_res_txn_tbl(l_ctr).transaction_type     :=1;
          -- rroy
          -- R12 Tech UIs
          l_ahl_res_txn_tbl(l_ctr).transaction_date     := nvl(p_x_prd_resrc_txn_tbl(i).transaction_date, sysdate);
          IF p_x_prd_resrc_txn_tbl(i).qty IS NOT NULL THEN
            l_ahl_res_txn_tbl(l_ctr).transaction_quantity := p_x_prd_resrc_txn_tbl(i).qty;
          ELSE
            l_ahl_res_txn_tbl(l_ctr).transaction_quantity := ROUND((p_x_prd_resrc_txn_tbl(i).end_date - p_x_prd_resrc_txn_tbl(i).transaction_date) * 24, 2);
          -- UOM is hours, so multiplying by 24
          END IF;
          --l_ahl_res_txn_tbl(l_ctr).transaction_quantity :=p_x_prd_resrc_txn_tbl(i).QTY        ;

          l_ahl_res_txn_tbl(l_ctr).transaction_uom      :=substr(p_x_prd_resrc_txn_tbl(i).UOM_CODE,1,3);
          l_ahl_res_txn_tbl(l_ctr).department_id        :=p_x_prd_resrc_txn_tbl(i).DEPARTMENT_ID;
          l_ahl_res_txn_tbl(l_ctr).employee_id          :=p_x_prd_resrc_txn_tbl(i).PERSON_ID;
          l_ahl_res_txn_tbl(l_ctr).activity_id          :=p_x_prd_resrc_txn_tbl(i).ACTIVITY_ID;
          l_ahl_res_txn_tbl(l_ctr).activity_meaning     :=p_x_prd_resrc_txn_tbl(i).ACTIVITY_MEANING;
          l_ahl_res_txn_tbl(l_ctr).reason_id            :=p_x_prd_resrc_txn_tbl(i).REASON_ID  ;
          l_ahl_res_txn_tbl(l_ctr).reason               :=p_x_prd_resrc_txn_tbl(i).REASON  ;

          -- bug 3955565
    	  -- the reference field will now contain short message, serial number and reference
    	  -- short message will be of type '; Machine Serial #: ' so that the appended serial number
    	  -- in the reference field makes sense when seen from the WIP UIs.
          IF p_x_prd_resrc_txn_tbl(i).serial_number IS NULL THEN
             -- if the serial number is null, then simply append a ';' at the end of the ref text
             -- to add as a demarking for us
             IF p_x_prd_resrc_txn_tbl(i).REFERENCE IS NOT NULL THEN
		l_ahl_res_txn_tbl(l_ctr).reference := p_x_prd_resrc_txn_tbl(i).REFERENCE || ';';
             END IF;
          ELSE
             -- if serial number is not null and ref text is null then
             -- simply add the serial number with short mesg prefix and without a semi colon
             -- 240 is the length of the reference column in the wip_transactions table
             IF p_x_prd_resrc_txn_tbl(i).REFERENCE IS NOT NULL THEN
                l_str_len := 240 - (length(p_x_prd_resrc_txn_tbl(i).serial_number) + length(l_short_mesg) + 2);
                l_ahl_res_txn_tbl(l_ctr).reference := substr(p_x_prd_resrc_txn_tbl(i).REFERENCE, 1, l_str_len) || '; ' || l_short_mesg || p_x_prd_resrc_txn_tbl(i).serial_number;
             ELSE
                -- ref text is null
                -- then simply add the serial number without a ';'
                l_ahl_res_txn_tbl(l_ctr).reference :=  p_x_prd_resrc_txn_tbl(i).REFERENCE || l_short_mesg || p_x_prd_resrc_txn_tbl(i).serial_number;
             END IF;
          END IF;


	  l_ahl_res_txn_tbl(l_ctr).serial_number        := p_x_prd_resrc_txn_tbl(i).serial_number  ;

          l_ctr:=l_ctr+1;
          End if;

        END LOOP;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Before Insert Process transactions',L_API_NAME);

	END IF;

	IF l_ahl_res_txn_tbl.count >0
	Then


        AHL_WIP_JOB_PVT.insert_resource_txn
        (
        p_api_version           =>p_api_version,
        p_init_msg_list         =>L_init_msg_list,
        p_commit                =>l_commit,
        p_validation_level      =>p_validation_level,
        x_return_status         =>x_return_status,
        x_msg_count             =>l_msg_count,
        x_msg_data              =>l_msg_data,
        p_ahl_res_txn_tbl       =>l_ahl_res_txn_tbl
        );
	End if;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Validation Errors in interface API');
	END IF;

        END IF;

        --Adithya added
        X_msg_count := l_msg_count;

        IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
        END IF;

    -- Debug info

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of Private api '||l_api_name,'+debug+');

	END IF;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.disable_debug;

	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_RESOURCE_TRANX;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_RESOURCE_TRANX;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_RESOURCE_TRANX;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>l_api_name,
                            p_error_text      =>SUBSTR(SQLERRM,1,240)
                            );
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END;

-- ADDED BY VSUNDARA FOR TRANSIT CHECK ENHANCEMENTS

PROCEDURE VALIDATE_MYWORKORDER_TRNX
(
 p_prd_myworkorder_txn_tbl            IN      PRD_MYWORKORDER_TXNS_TBL,
 x_return_status                OUT NOCOPY     VARCHAR2
)
AS
l_return_status VARCHAR2(1);
l_wo_name       VARCHAR2(80);
L_wo_status VARCHAR2(30);

CURSOR get_wo_details(c_workorder_id NUMBER)
IS
SELECT workorder_name
FROM AHL_WORKORDERS
WHERE WORKORDER_ID = c_workorder_id;

BEGIN

  IF p_prd_myworkorder_txn_tbl.COUNT >0
  THEN
        --- Basic Validation..
        FOR i IN p_prd_myworkorder_txn_tbl.FIRST..p_prd_myworkorder_txn_tbl.LAST
        LOOP
	   -- rroy
	   -- R12 Tech UIs
	   -- Negative resource transactions are allowed starting R12
           /*IF p_prd_myworkorder_txn_tbl(i).TRANSACTED_HOURS IS NOT NULL OR
             p_prd_myworkorder_txn_tbl(i).TRANSACTED_HOURS  <> fnd_api.g_miss_num
            THEN
                IF p_prd_myworkorder_txn_tbl(i).TRANSACTED_HOURS   < 0
                THEN
                    FND_MESSAGE.set_name('AHL','AHL_PRD_RESTXN_QTY_INVALID');
                    FND_MESSAGE.SET_TOKEN('OPER_RES', p_prd_myworkorder_txn_tbl(i).OPERATION_SEQUENCE||'-'|| p_prd_myworkorder_txn_tbl(i).RESOURCE_SEQUENCE);
                    FND_MSG_PUB.ADD;

                  IF G_DEBUG='Y' THEN
                      AHL_DEBUG_PUB.debug( 'Error in Quantity');
                   END IF;
                 END IF;
          END IF ;
	  */
	   -- rroy
	   -- R12 Tech UIs

          IF p_prd_myworkorder_txn_tbl(i).WORKORDER_ID IS NULL OR
             p_prd_myworkorder_txn_tbl(i).WORKORDER_ID = fnd_api.g_miss_num
          THEN
                FND_MESSAGE.set_name('AHL','AHL_PRD_WORKORDER_ID_NULL');
                FND_MSG_PUB.ADD;
               IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug( 'Error in Quantity');
               END IF;
          END IF ;

          -- rroy
          -- ACL Changes
          IF p_prd_myworkorder_txn_tbl(i).TRANSACTED_HOURS <> 0 THEN
                l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
                     p_workorder_id => p_prd_myworkorder_txn_tbl(i).workorder_id,
                     p_ue_id => NULL,
                     p_visit_id => NULL,
                     p_item_instance_id => NULL);
                IF l_return_status = FND_API.G_TRUE THEN
                   OPEN get_wo_details(p_prd_myworkorder_txn_tbl(i).workorder_id);
                   FETCH get_wo_details INTO l_wo_name;
                   CLOSE get_wo_details;
                   FND_MESSAGE.Set_Name('AHL', 'AHL_PP_RESTXN_UNTLCKD');
                   FND_MESSAGE.Set_Token('WO_NAME', l_wo_name);
                   FND_MSG_PUB.ADD;
               END IF;
         END IF;
         -- rroy
         -- ACL Changes
         IF p_prd_myworkorder_txn_tbl(i).OPERATION_SEQUENCE  IS NULL OR
             p_prd_myworkorder_txn_tbl(i).OPERATION_SEQUENCE  = fnd_api.g_miss_num
          THEN
                FND_MESSAGE.set_name('AHL','AHL_PRD_OPERATION_NULL');
                FND_MSG_PUB.ADD;
               IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug( 'Error in Quantity');
               END IF;
          END IF ;

         IF p_prd_myworkorder_txn_tbl(i).RESOURCE_SEQUENCE  IS NULL OR
             p_prd_myworkorder_txn_tbl(i).RESOURCE_SEQUENCE  = fnd_api.g_miss_num
          THEN
                FND_MESSAGE.set_name('AHL','AHL_PRD_RESOURCE_NULL');
                FND_MSG_PUB.ADD;
               IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug( 'Error in Quantity');
               END IF;
          END IF ;
        END LOOP;
  END IF ;

END;


PROCEDURE getOperationRecord
(
  p_operation_Id       IN NUMBER ,
  p_x_operation_rec    IN OUT NOCOPY   AHL_PRD_OPERATIONS_PVT.PRD_WORKOPERATION_REC,
  x_return_status      OUT NOCOPY     VARCHAR2
 )

IS

cursor get_operation_rec(c_operation_id NUMBER)
is
SELECT *
FROM   AHL_WORKORDER_OPERATIONS_V
WHERE  workorder_operation_id=c_operation_id;

l_operation_rec       get_operation_rec%ROWTYPE;

BEGIN

  OPEN get_operation_rec(p_operation_Id);
  FETCH get_operation_rec INTO l_operation_rec;
  CLOSE get_operation_rec;

  IF l_operation_rec.scheduled_start_date > SYSDATE THEN
      l_operation_rec.actual_start_date  :=  SYSDATE;
  ELSE
      l_operation_rec.actual_start_date  := l_operation_rec.Scheduled_start_date;
  END IF;

  IF l_operation_rec.scheduled_end_date > SYSDATE THEN
     l_operation_rec.actual_end_date  :=  SYSDATE;
  ELSE
    l_operation_rec.actual_end_date := l_operation_rec.scheduled_end_date;
  END IF;

  p_x_operation_rec.WORKORDER_OPERATION_ID := l_operation_rec.WORKORDER_OPERATION_ID;
  p_x_operation_rec.ACTUAL_START_DATE  := l_operation_rec.actual_start_date ;
  p_x_operation_rec.ACTUAL_END_DATE  := l_operation_rec.actual_end_date;
  p_x_operation_rec.OBJECT_VERSION_NUMBER  := l_operation_rec.OBJECT_VERSION_NUMBER;
  p_x_operation_rec.DML_OPERATION := 'U';
END ;






--- Changes by VSUNDARA For Transit Check

PROCEDURE PROCESS_MYWORKORDER_TXNS
(
 p_api_version                  IN  	NUMBER     := 1.0,
 p_init_msg_list                IN  	VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  	VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  	NUMBER:=FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN 	VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN 	VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY   VARCHAR2,
 x_msg_count                    OUT NOCOPY   NUMBER,
 x_msg_data                     OUT NOCOPY   VARCHAR2,
 p_x_prd_myworkorder_txn_tbl    IN OUT NOCOPY   PRD_MYWORKORDER_TXNS_TBL
)

AS

 l_api_name     CONSTANT VARCHAR2(30):= 'PROCESS_MYWORKORDER_TXNS';
 l_api_version  CONSTANT NUMBER:= 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_FALSE;
 l_commit                VARCHAR2(1):= FND_API.G_FALSE;
 l_ahl_res_txn_tbl       AHL_WIP_JOB_PVT.ahl_res_txn_tbl_type;
 l_wip_entity_id         NUMBER;
 l_txn_group_id          NUMBER;
 l_ctr                   NUMBER:=0;
 l_uom_code             VARCHAR2(3);
	l_wo_status_code       VARCHAR2(30);
 l_prd_operation_rec    AHL_PRD_OPERATIONS_PVT.PRD_WORKOPERATION_REC;
 l_prd_operation_tbl    AHL_PRD_OPERATIONS_PVT.PRD_OPERATION_TBL;

 Cursor GetWipid (C_WORK_ID  Number)
 Is
 Select wip_entity_id, status_code
 from ahl_workorders
 where workorder_id=c_work_id;


CURSOR getDefaultUOM
IS
SELECT  UOM_CODE
FROM  MTL_UNITS_OF_MEASURE
WHERE UPPER(UNIT_OF_MEASURE) = UPPER('Hour')
AND UOM_CLASS = 'Time';


CURSOR getResDetails(p_assignment_id NUMBER)
IS
 SELECT
  AWAS.ASSIGNMENT_ID,
  AWOS.WORKORDER_ID JOB_ID,
  AWOP.WORKORDER_OPERATION_ID OPERATION_ID,
  AWOS.ORGANIZATION_ID,
  AWOP.OPERATION_SEQUENCE_NUM OPERATION_SEQUENCE,
  AOPR.RESOURCE_SEQUENCE_NUM RESOURCE_SEQUENCE,
  BOMR.DESCRIPTION RESOURCE_NAME,
  BOMR.RESOURCE_TYPE RESOURCE_TYPE_CODE ,
  MFGL.MEANING RESOURCE_TYPE_NAME ,
  AOPR.RESOURCE_ID,
  BOMR.RESOURCE_CODE RESOURCE_CODE ,
  PEPF.employee_num EMPLOYEE_NUMBER,
  PEPF.FULL_NAME ,
  AWOS.DEPARTMENT_NAME,
  AWOS.DEPARTMENT_ID,
  AWOS.ITEM_INSTANCE_ID
FROM AHL_WORK_ASSIGNMENTS AWAS, AHL_WORKORDER_TASKS_V AWOS, AHL_WORKORDER_OPERATIONS AWOP,
AHL_OPERATION_RESOURCES AOPR,AHL_DEPARTMENT_SHIFTS ADS,  mtl_employees_current_view PEPF, BOM_RESOURCES BOMR, MFG_LOOKUPS MFGL
WHERE AWAS.OPERATION_RESOURCE_ID = AOPR.OPERATION_RESOURCE_ID
AND AWOP.WORKORDER_OPERATION_ID = AOPR.WORKORDER_OPERATION_ID
AND AWOP.WORKORDER_ID = AWOS.WORKORDER_ID
AND AWOS.DEPARTMENT_ID = ADS.DEPARTMENT_ID (+)
AND AWAS.EMPLOYEE_ID = PEPF.EMPLOYEE_ID AND SYSTEM_PERSON_TYPE ='EMP' AND AOPR.RESOURCE_ID = BOMR.RESOURCE_ID
AND MFGL.LOOKUP_CODE(+) = BOMR.RESOURCE_TYPE AND MFGL.LOOKUP_TYPE(+) = 'BOM_RESOURCE_TYPE'
AND AWAS.ASSIGNMENT_ID  = p_assignment_id;

l_res_rec   getResDetails%rowtype;

BEGIN
        SAVEPOINT PROCESS_MYWORKORDER_TXNS;

   --   Enable Debug

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.enable_debug;
        END IF;



   --   Standard call to check for call compatibility.

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                         p_api_version,
                                         l_api_name,G_PKG_NAME)  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   --   Initialize message list if p_init_msg_list is set to TRUE.

        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

   --   Initialize API return status to success

        x_return_status:=FND_API.G_RET_STS_SUCCESS;


    --  Debug info.

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'Enter PROCESS_MYWORKORDER_TXNS',L_API_NAME);
        END IF;

      VALIDATE_MYWORKORDER_TRNX(
         p_prd_myworkorder_txn_tbl   => p_x_prd_myworkorder_txn_tbl,
         x_return_status             =>x_return_status
      );


      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF G_DEBUG='Y' THEN
          		  AHL_DEBUG_PUB.debug( 'Error Thrown in Validate',L_API_NAME);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
            -- Get the Defalut UOM Code --- Hr
        Open getDefaultUOM;
        fetch getDefaultUOM into l_uom_code;
        CLOSE getDefaultUOM;

      IF p_x_prd_myworkorder_txn_tbl.COUNT > 0 THEN
        FOR i IN p_x_prd_myworkorder_txn_tbl.FIRST..p_x_prd_myworkorder_txn_tbl.LAST
        LOOP
          IF p_x_prd_myworkorder_txn_tbl(i).TRANSACTED_HOURS > 0
          THEN

              IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.debug( 'Enter loop ',L_API_NAME);
              END IF;

              OPEN   GetWipid (p_x_prd_myworkorder_txn_tbl(i).workorder_id);
              FETCH  GetWipid into l_wip_entity_id, l_wo_status_code;
              CLOSE  GetWipid;
														IF l_wo_status_code IN ('1', '12', '7', '6', '13', '5') THEN
														  FND_MESSAGE.set_name('AHL', 'AHL_PRD_RESOURCE_CANNOTEDIT');
																FND_MSG_PUB.ADD;
																RAISE FND_API.G_EXC_ERROR;
														END IF;

                Open getResDetails(p_x_prd_myworkorder_txn_tbl(i).ASSIGNMENT_ID);
                FETCH getResDetails into l_res_rec;
		CLOSE getResDetails;
                  IF G_DEBUG='Y' THEN
                     AHL_DEBUG_PUB.debug( 'Workorder id'||p_x_prd_myworkorder_txn_tbl(i).workorder_id,L_API_NAME);
                  END IF;
                  l_ahl_res_txn_tbl(l_ctr).operation_seq_num    :=l_res_rec.OPERATION_SEQUENCE;
                  l_ahl_res_txn_tbl(l_ctr).resource_seq_num     :=l_res_rec.RESOURCE_SEQUENCE;
                  l_ahl_res_txn_tbl(l_ctr).resource_id          :=l_res_rec.RESOURCE_ID;
                  l_ahl_res_txn_tbl(l_ctr).transaction_type     :=1;
                  l_ahl_res_txn_tbl(l_ctr).transaction_date     :=sysdate;
                  l_ahl_res_txn_tbl(l_ctr).transaction_quantity :=p_x_prd_myworkorder_txn_tbl(i).TRANSACTED_HOURS;
                  --- Default UOM CODE
                  l_ahl_res_txn_tbl(l_ctr).transaction_uom      := l_uom_code;
                  l_ahl_res_txn_tbl(l_ctr).department_id        :=l_res_rec.DEPARTMENT_ID;
                  l_ahl_res_txn_tbl(l_ctr).employee_id          :=p_x_prd_myworkorder_txn_tbl(i).EMPLOYEE_ID;
                  l_ahl_res_txn_tbl(l_ctr).wip_entity_id   := l_wip_entity_id;

                  l_ctr:=l_ctr+1;
          END IF;
        END LOOP;
       END IF;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Before Insert Process transactions',L_API_NAME);

	END IF;


	IF l_ahl_res_txn_tbl.count >0
	Then

        AHL_WIP_JOB_PVT.insert_resource_txn
        (
        p_api_version           =>p_api_version,
        p_init_msg_list         =>L_init_msg_list,
        p_commit                =>l_commit,
        p_validation_level      =>p_validation_level,
        x_return_status         =>x_return_status,
        x_msg_count             =>l_msg_count,
        x_msg_data              =>l_msg_data,
        p_ahl_res_txn_tbl       =>l_ahl_res_txn_tbl
        );
	End if;
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
             X_msg_count := l_msg_count;
             X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             RAISE FND_API.G_EXC_ERROR;
             IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.debug( 'Error in Insert_Resource_Txn API');
             END IF;
        END IF;

   --- Complete the Operation if the Complete Operation is True
        l_ctr := 0;
	IF p_x_prd_myworkorder_txn_tbl.COUNT > 0 THEN
        FOR i IN p_x_prd_myworkorder_txn_tbl.FIRST..p_x_prd_myworkorder_txn_tbl.LAST
        LOOP



            IF (p_x_prd_myworkorder_txn_tbl(i).OPERATION_COMPLETE IS NOT NULL AND
                p_x_prd_myworkorder_txn_tbl(i).OPERATION_COMPLETE <> FND_API.G_MISS_CHAR AND
                p_x_prd_myworkorder_txn_tbl(i).OPERATION_COMPLETE = 'Y')
            THEN
                getOperationRecord(
                                   p_operation_id   => p_x_prd_myworkorder_txn_tbl(i).WORKORDER_OPERATION_ID,
                                   p_x_operation_rec => l_prd_operation_rec,
                                   x_return_status => x_return_status);
                l_prd_operation_tbl(l_ctr) := l_prd_operation_rec;
                l_ctr := l_ctr +1 ;

            END IF ;

        END LOOP;
	END IF;

  	IF l_prd_operation_tbl.count >0
    Then
        AHL_PRD_OPERATIONS_PVT.PROCESS_OPERATIONS
        (
        p_api_version           =>1.0,
        p_init_msg_list         =>FND_API.G_FALSE,
        p_commit                =>l_commit,
        p_validation_level      =>p_validation_level,
        p_default               =>  FND_API.G_TRUE,
        p_module_type           =>  NULL,
        p_wip_mass_load_flag    =>   'N',
        x_return_status         =>x_return_status,
        x_msg_count             =>l_msg_count,
        x_msg_data              =>l_msg_data,
        p_x_prd_operation_tbl       =>l_prd_operation_tbl
        );
	End if;
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_ERROR;
         IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'Error in Process Operations API');
         END IF;
    END IF;

  --- Complete the Operation
    IF l_prd_operation_tbl.COUNT > 0 THEN
    FOR i IN l_prd_operation_tbl.FIRST..l_prd_operation_tbl.LAST
    LOOP
       AHL_COMPLETIONS_PVT.complete_operation
        (
          p_api_version           =>   1.0,
          p_init_msg_list         =>  FND_API.G_TRUE,
          p_commit                =>  FND_API.G_FALSE,
          p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
          p_default               =>  FND_API.G_FALSE,
          p_module_type           =>  NULL,
          x_return_status         => x_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          p_workorder_operation_id  => l_prd_operation_tbl(i).workorder_operation_id,
          p_object_version_no   => l_prd_operation_tbl(i).object_version_number
      );
     END LOOP;
     END IF;
   l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
         X_msg_count := l_msg_count;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_ERROR;
         IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'Error in Complete Operation API');
         END IF;
    END IF;

        IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
        END IF;

    -- Debug info

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'End of api '||l_api_name,'+debug+');

	END IF;

        IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.disable_debug;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_MYWORKORDER_TXNS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_MYWORKORDER_TXNS;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_MYWORKORDER_TXNS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>l_api_name,
                            p_error_text      =>SUBSTR(SQLERRM,1,240)
                            );
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END;



FUNCTION Get_transacted_hours
(
    p_wip_entity_id  IN  NUMBER,
    p_operation_seq_num IN NUMBER,
    p_resource_seq_num IN NUMBER,
    p_employee_id IN NUMBER
)  RETURN NUMBER

IS

l_completed_hrs    NUMBER ;
l_pending_hrs      NUMBER ;
l_return_value     NUMBER;


CURSOR   get_resource_txns(c_wip_entity_id NUMBER,
                           c_operation_seq_num NUMBER,
                           c_resource_seq_num NUMBER,
                           c_employee_id NUMBER )
IS

SELECT         NVL( SUM( transaction_quantity ), 0 )
FROM           WIP_TRANSACTIONS
WHERE          wip_entity_id = c_wip_entity_id
AND            operation_seq_num = c_operation_seq_num
AND            resource_seq_num = c_resource_seq_num
AND            employee_id = c_employee_id;


CURSOR         get_pending_resource_txns(  c_wip_entity_id NUMBER,
                                           c_operation_seq_num NUMBER,
                                           c_resource_seq_num NUMBER,
                                           c_employee_id NUMBER )
IS
SELECT           NVL( SUM( transaction_quantity ), 0 )
FROM             WIP_COST_TXN_INTERFACE
WHERE            wip_entity_id = c_wip_entity_id
AND              operation_seq_num = c_operation_seq_num
AND              resource_seq_num = c_resource_seq_num
AND              employee_id = c_employee_id
AND              process_status = 1;


BEGIN
  OPEN get_resource_txns(  p_wip_entity_id,
                           p_operation_seq_num,
                           p_resource_seq_num,
                           p_employee_id );
  FETCH get_resource_txns INTO l_completed_hrs;
  CLOSE get_resource_txns;

  OPEN get_pending_resource_txns( p_wip_entity_id,
                           p_operation_seq_num,
                           p_resource_seq_num,
                           p_employee_id
                           );
  FETCH get_pending_resource_txns INTO l_pending_hrs;
  CLOSE get_pending_resource_txns;

  l_return_value:=l_completed_hrs+l_pending_hrs;

  RETURN l_return_value ;
END ;

/*##################################################################################################*/
--# NAME
--#     PROCEDURE: Get_Resource_Txn_Defaults
--# PARAMETERS
--# Standard IN Parameters
--#  p_api_version                  IN 	NUMBER     := 1.0
--#  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_TRUE
--#  p_module_type                  IN 	VARCHAR2   := NULL
--#
--# Standard OUT Parameters
--#  x_return_status    OUT NOCOPY VARCHAR2
--#  x_msg_count        OUT NOCOPY   NUMBER
--#  x_msg_data         OUT NOCOPY   VARCHAR2
--#
--# Get_Resource_Txn_Defaults Parameters
--#  p_employee_id			IN  	NUMBER
--#  p_workorder_id			IN  	NUMBER
--#  p_operation_seq_num		IN	NUMBER
--#  p_function_name	         	IN	VARCHAR2 - The function name identifying the type of user
--#  x_resource_txn_tbl                 OUT  NOCOPY  PRD_RESOURCE_TXNS_TBL
--#
--# DESCRIPTION
--# 	This procedure is used to retrieve the default resource transactions based on the user/function name
--#
--# HISTORY
--#   16-Jun-2005   rroy  Created
--###################################################################################################*/

PROCEDURE Get_Resource_Txn_Defaults
(
 p_api_version                  IN  	NUMBER     := 1.0,
 p_init_msg_list                IN  	VARCHAR2   := FND_API.G_TRUE,
 p_module_type                  IN 	VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY   VARCHAR2,
 x_msg_count                    OUT NOCOPY   NUMBER,
 x_msg_data                     OUT NOCOPY   VARCHAR2,
 p_employee_id			IN  	NUMBER,
 p_workorder_id			IN  	NUMBER,
 p_operation_seq_num		IN	NUMBER,
 p_function_name	        IN	VARCHAR2,
 x_resource_txn_tbl             OUT  NOCOPY  PRD_RESOURCE_TXNS_TBL
)
IS
	l_user_role VARCHAR2(4);
	l_employee_id NUMBER;
	i NUMBER;
	l_employee_name VARCHAR2(240);
	l_employee_num VARCHAR2(30);


	CURSOR   c_get_resource_assgmt_tech(x_workorder_id NUMBER,
	x_operation_seq_num NUMBER,
	x_employee_id NUMBER)
	IS
	SELECT APRV.RESOURCE_SEQUENCE,
	APRV.RESOURCE_ID,
	APRV.RESOURCE_CODE,
	APRV.RESOURCE_TYPE_NAME,
	APRV.RESOURCE_TYPE_CODE,
	APRV.UOM_NAME,
	APRV.UOM_CODE,
	APRV.DEPARTMENT_ID,
	BD.department_code,
	APRV.REQUIREMENT_ID
	FROM AHL_WORK_ASSIGNMENTS AWAS,
	AHL_PP_REQUIREMENT_V APRV,bom_departments BD
	WHERE AWAS.OPERATION_RESOURCE_ID = APRV.REQUIREMENT_ID
	AND APRV.DEPARTMENT_ID = BD.department_id
	AND APRV.JOB_ID = x_workorder_id
	AND APRV.OPERATION_SEQUENCE = x_operation_seq_num
	AND AWAS.EMPLOYEE_ID = x_employee_id;

	CURSOR   c_get_other_res_assgmt_tech(x_workorder_id NUMBER,
	x_operation_seq_num NUMBER)
	IS
	SELECT APRV.RESOURCE_SEQUENCE,
	APRV.RESOURCE_ID,
	APRV.RESOURCE_CODE,
	APRV.RESOURCE_TYPE_NAME,
	APRV.RESOURCE_TYPE_CODE,
	APRV.UOM_NAME,
	APRV.UOM_CODE,
	AWAS.SERIAL_NUMBER,
	AWAS.INSTANCE_ID,
	APRV.DEPARTMENT_ID,
	BD.department_code,
	APRV.REQUIREMENT_ID
	FROM AHL_WORK_ASSIGNMENTS AWAS,
	AHL_PP_REQUIREMENT_V APRV,bom_departments BD
	WHERE AWAS.OPERATION_RESOURCE_ID = APRV.REQUIREMENT_ID
	AND APRV.DEPARTMENT_ID = BD.department_id
	AND APRV.JOB_ID = x_workorder_id
	AND APRV.OPERATION_SEQUENCE = x_operation_seq_num
	AND RESOURCE_TYPE_CODE <> 2;

	CURSOR c_get_other_resource_req_tech(x_workorder_id NUMBER,
	                                    x_operation_seq_num NUMBER)
	IS
	SELECT APRV.RESOURCE_SEQUENCE,
	APRV.RESOURCE_ID,
	APRV.RESOURCE_CODE,
	APRV.RESOURCE_TYPE_NAME,
	APRV.RESOURCE_TYPE_CODE,
	APRV.UOM_NAME,
	APRV.UOM_CODE,
	APRV.DEPARTMENT_ID,
	BD.department_code,
	APRV.REQUIREMENT_ID
	FROM AHL_PP_REQUIREMENT_V APRV ,bom_departments BD
	WHERE APRV.JOB_ID = x_workorder_id
	AND APRV.DEPARTMENT_ID = BD.department_id
	AND APRV.OPERATION_SEQUENCE = x_operation_seq_num
	AND APRV.RESOURCE_TYPE_CODE <> 2
	AND NOT EXISTS (SELECT ASSIGNMENT_ID
	FROM AHL_WORK_ASSIGNMENTS AWAS
	WHERE AWAS.OPERATION_RESOURCE_ID = APRV.REQUIREMENT_ID);

	CURSOR   c_get_resource_assgmt_data(x_workorder_id NUMBER,
	x_operation_seq_num NUMBER)
	IS
	SELECT APRV.RESOURCE_SEQUENCE,
	APRV.RESOURCE_ID,
	APRV.RESOURCE_CODE,
	APRV.RESOURCE_TYPE_NAME,
	APRV.RESOURCE_TYPE_CODE,
	APRV.UOM_NAME,
	APRV.UOM_CODE,
	AWAS.EMPLOYEE_ID,
	AWAS.SERIAL_NUMBER,
	AWAS.INSTANCE_ID,
	APRV.DEPARTMENT_ID,
	BD.department_code,
	APRV.REQUIREMENT_ID
	FROM AHL_WORK_ASSIGNMENTS AWAS,
	AHL_PP_REQUIREMENT_V APRV ,bom_departments BD
	WHERE AWAS.OPERATION_RESOURCE_ID = APRV.REQUIREMENT_ID
	AND APRV.DEPARTMENT_ID = BD.department_id
	AND APRV.JOB_ID = x_workorder_id
	AND APRV.OPERATION_SEQUENCE = x_operation_seq_num;

	CURSOR c_get_resource_req_data(x_workorder_id NUMBER,
	                                           x_operation_seq_num NUMBER)
	IS
	SELECT APRV.RESOURCE_SEQUENCE,
	APRV.RESOURCE_ID,
	APRV.RESOURCE_CODE,
	APRV.RESOURCE_TYPE_NAME,
	APRV.RESOURCE_TYPE_CODE,
	APRV.UOM_NAME,
	APRV.UOM_CODE,
	APRV.DEPARTMENT_ID,
	BD.department_code,
	APRV.REQUIREMENT_ID
	FROM AHL_PP_REQUIREMENT_V APRV ,bom_departments BD
	WHERE APRV.JOB_ID = x_workorder_id
	AND APRV.DEPARTMENT_ID = BD.department_id
	AND APRV.OPERATION_SEQUENCE = x_operation_seq_num
	AND NOT EXISTS (SELECT ASSIGNMENT_ID
	FROM AHL_WORK_ASSIGNMENTS AWAS
	WHERE AWAS.OPERATION_RESOURCE_ID = APRV.REQUIREMENT_ID);

        CURSOR c_get_emp_details(x_employee_id NUMBER)
        IS
        SELECT FULL_NAME,
        EMPLOYEE_NUMBER
        FROM PER_PEOPLE_F
        WHERE PERSON_ID = x_employee_id;

        l_manual_enabled_profile_value VARCHAR2(1);

BEGIN

  -- if the employee id is NULL then get the employee id
  -- id of the user who is currently logged in
  IF p_employee_id IS NULL THEN
      L_employee_id := AHL_PRD_WO_LOGIN_PVT.get_employee_id;
  ELSE
      L_employee_id := p_employee_id;
  END IF;

  i:= 0;

  l_manual_enabled_profile_value := NVL(fnd_profile.value('AHL_PRD_MANUAL_RES_TXN'), 'N');

  IF p_function_name = 'AHL_PRD_TECH_MYWO' OR p_function_name = 'AHL_PRD_TRANSIT_TECH' THEN
      IF (l_manual_enabled_profile_value = 'Y') THEN
        OPEN c_get_emp_details(l_employee_id);
        FETCH c_get_emp_details INTO l_employee_name, l_employee_num;
        CLOSE c_get_emp_details;

	FOR res_txn_rec IN c_get_resource_assgmt_tech(p_workorder_id, p_operation_seq_num, l_employee_id)
	LOOP
		X_resource_txn_tbl(i).operation_sequence_num := p_operation_seq_num;
		X_resource_txn_tbl(i).workorder_id := p_workorder_id;
		X_resource_txn_tbl(i).resource_sequence_num := res_txn_rec.resource_sequence;
		x_resource_txn_tbl(i).operation_resource_id := res_txn_rec.requirement_id;
		X_resource_txn_tbl(i).resource_id := res_txn_rec.resource_id;
		X_resource_txn_tbl(i).resource_name := res_txn_rec.resource_CODE;
		X_resource_txn_tbl(i).resource_type_name := res_txn_rec.resource_type_name;
		X_resource_txn_tbl(i).resource_type_code := res_txn_rec.resource_type_code;
		X_resource_txn_tbl(i).uom_code := res_txn_rec.uom_code;
		X_resource_txn_tbl(i).uom_meaning := res_txn_rec.uom_name;
		X_resource_txn_tbl(i).person_id := l_employee_id;
		X_resource_txn_tbl(i).employee_name := l_employee_name;
		X_resource_txn_tbl(i).employee_num := l_employee_num;
		x_resource_txn_tbl(i).department_id := res_txn_rec.department_id;
		x_resource_txn_tbl(i).department_code := res_txn_rec.department_code;
		x_resource_txn_tbl(i).transaction_date := SYSDATE;
		i := i + 1;
	END LOOP;
      END IF; -- IF (l_manual_enabled_profile_value = 'Y') THEN

      FOR res_txn_rec IN c_get_other_res_assgmt_tech(p_workorder_id, p_operation_seq_num) LOOP
		X_resource_txn_tbl(i).operation_sequence_num := p_operation_seq_num;
		X_resource_txn_tbl(i).workorder_id := p_workorder_id;
		X_resource_txn_tbl(i).resource_sequence_num := res_txn_rec.resource_sequence;
		x_resource_txn_tbl(i).operation_resource_id := res_txn_rec.requirement_id;
		X_resource_txn_tbl(i).resource_id := res_txn_rec.resource_id;
		X_resource_txn_tbl(i).resource_name := res_txn_rec.resource_CODE;
		X_resource_txn_tbl(i).resource_type_name := res_txn_rec.resource_type_name;
		X_resource_txn_tbl(i).resource_type_code := res_txn_rec.resource_type_code;
		X_resource_txn_tbl(i).uom_code := res_txn_rec.uom_code;
		X_resource_txn_tbl(i).uom_meaning := res_txn_rec.uom_name;
		X_resource_txn_tbl(i).serial_number := res_txn_rec.serial_number;
		X_resource_txn_tbl(i).Instance_id := res_txn_rec.Instance_id;
		x_resource_txn_tbl(i).department_id := res_txn_rec.department_id;
		x_resource_txn_tbl(i).department_code := res_txn_rec.department_code;
		x_resource_txn_tbl(i).transaction_date := SYSDATE;
		i := i + 1;
     END LOOP;
     FOR res_txn_rec IN c_get_other_resource_req_tech(p_workorder_id, p_operation_seq_num) LOOP
		X_resource_txn_tbl(i).operation_sequence_num := p_operation_seq_num;
		X_resource_txn_tbl(i).workorder_id := p_workorder_id;
		X_resource_txn_tbl(i).resource_sequence_num := res_txn_rec.resource_sequence;
		x_resource_txn_tbl(i).operation_resource_id := res_txn_rec.requirement_id;
		X_resource_txn_tbl(i).resource_id := res_txn_rec.resource_id;
		X_resource_txn_tbl(i).resource_name := res_txn_rec.resource_CODE;
		X_resource_txn_tbl(i).resource_type_name := res_txn_rec.resource_type_name;
		X_resource_txn_tbl(i).resource_type_code := res_txn_rec.resource_type_code;
		X_resource_txn_tbl(i).uom_code := res_txn_rec.uom_code;
		X_resource_txn_tbl(i).uom_meaning := res_txn_rec.uom_name;
		x_resource_txn_tbl(i).department_id := res_txn_rec.department_id;
		x_resource_txn_tbl(i).department_code := res_txn_rec.department_code;
		x_resource_txn_tbl(i).transaction_date := SYSDATE;
		i := i + 1;
     END LOOP;
  ELSE
	FOR res_txn_rec IN c_get_resource_assgmt_data(p_workorder_id, p_operation_seq_num) LOOP
                IF res_txn_rec.employee_id IS NOT NULL THEN
                    OPEN c_get_emp_details(res_txn_rec.employee_id);
                    FETCH c_get_emp_details INTO l_employee_name, l_employee_num;
	            CLOSE c_get_emp_details;
                END IF;
		X_resource_txn_tbl(i).operation_sequence_num := p_operation_seq_num;
		X_resource_txn_tbl(i).workorder_id := p_workorder_id;
		X_resource_txn_tbl(i).resource_sequence_num := res_txn_rec.resource_sequence;
		x_resource_txn_tbl(i).operation_resource_id := res_txn_rec.requirement_id;
		X_resource_txn_tbl(i).resource_id := res_txn_rec.resource_id;
		X_resource_txn_tbl(i).resource_name := res_txn_rec.resource_CODE;
		X_resource_txn_tbl(i).resource_type_name := res_txn_rec.resource_type_name;
		X_resource_txn_tbl(i).resource_type_code := res_txn_rec.resource_type_code;
		X_resource_txn_tbl(i).uom_code := res_txn_rec.uom_code;
		X_resource_txn_tbl(i).uom_meaning := res_txn_rec.uom_name;
		X_resource_txn_tbl(i).person_id := res_txn_rec.employee_id;
		X_resource_txn_tbl(i).employee_name := l_employee_name;
		X_resource_txn_tbl(i).employee_num := l_employee_num;
		X_resource_txn_tbl(i).serial_number := res_txn_rec.serial_number;
		X_resource_txn_tbl(i).Instance_id := res_txn_rec.Instance_id;
		x_resource_txn_tbl(i).department_id := res_txn_rec.department_id;
		x_resource_txn_tbl(i).department_code := res_txn_rec.department_code;
		x_resource_txn_tbl(i).transaction_date := SYSDATE;
		i := i + 1;
	END LOOP;
	FOR res_txn_rec IN c_get_resource_req_data(p_workorder_id, p_operation_seq_num) LOOP
		X_resource_txn_tbl(i).operation_sequence_num := p_operation_seq_num;
		X_resource_txn_tbl(i).workorder_id := p_workorder_id;
		X_resource_txn_tbl(i).resource_sequence_num := res_txn_rec.resource_sequence;
		x_resource_txn_tbl(i).operation_resource_id := res_txn_rec.requirement_id;
		X_resource_txn_tbl(i).resource_id := res_txn_rec.resource_id;
		X_resource_txn_tbl(i).resource_name := res_txn_rec.resource_CODE;
		X_resource_txn_tbl(i).resource_type_name := res_txn_rec.resource_type_name;
		X_resource_txn_tbl(i).resource_type_code := res_txn_rec.resource_type_code;
		X_resource_txn_tbl(i).uom_code := res_txn_rec.uom_code;
		X_resource_txn_tbl(i).uom_meaning := res_txn_rec.uom_name;
		x_resource_txn_tbl(i).department_id := res_txn_rec.department_id;
		x_resource_txn_tbl(i).department_code := res_txn_rec.department_code;
		x_resource_txn_tbl(i).transaction_date := SYSDATE;
		i := i + 1;
	END LOOP;
  END IF;--IF p_user_role = 'TECH' OR p_user_role = 'LINE' THEN


END Get_Resource_Txn_Defaults;

END  AHL_PRD_RESOURCE_TRANX_PVT;

/
