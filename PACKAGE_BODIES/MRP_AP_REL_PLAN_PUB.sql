--------------------------------------------------------
--  DDL for Package Body MRP_AP_REL_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_AP_REL_PLAN_PUB" AS
/* $Header: MRPRELPB.pls 120.11.12010000.6 2010/03/19 13:11:11 vsiyer ship $ */

G_WIP_GROUP_ID        NUMBER;
G_EAM_GROUP_ID        NUMBER; -- dsr
G_OPM_WIP_GROUP_ID    NUMBER;
G_PO_BATCH_NUMBER     NUMBER;

-- PV_RESOURCE_TYPE      NUMBER;  /* profile value */
PV_RES_PRIORITY       NUMBER;
PV_SIM_RES_SEQ        NUMBER;
PV_REL_REQUEST_DATE   VARCHAR2(1);

LT_RESOURCE            CONSTANT INTEGER := 1;  -- wip details load type
LT_COMPONENT           CONSTANT INTEGER := 2;
LT_OPERATION           CONSTANT INTEGER := 3;
LT_RESOURCE_USAGE      CONSTANT INTEGER := 4;

SUBST_DELETE           CONSTANT INTEGER := 1;  -- wip details substitution
SUBST_ADD              CONSTANT INTEGER := 2;  -- type
SUBST_CHANGE           CONSTANT INTEGER := 3;

PURCHASING_BY_REV      CONSTANT INTEGER := 1;
NOT_PURCHASING_BY_REV  CONSTANT INTEGER := 2;
UNDER_REV_CONTROL      CONSTANT INTEGER := 2;
NOT_UNDER_REV_CONTROL  CONSTANT INTEGER := 1;

RESOURCE_INSTANCES CONSTANT INTEGER := 8; -- dsr
RESOURCE_INSTANCE_USAGE CONSTANT INTEGER := 9; -- dsr
RESOURCE_INSTANCES_OSFM CONSTANT INTEGER := 7; -- dsr
RESOURCE_INSTANCE_USAGE_OSFM CONSTANT INTEGER := 4; -- dsr
G_OPR_UPDATE CONSTANT INTEGER := 2; -- dsr

NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';

var_purchasing_by_rev NUMBER := to_number(FND_PROFILE.VALUE('MRP_PURCHASING_BY_REVISION'));

var_lot_job_copy_rout NUMBER := to_number(FND_PROFILE.VALUE('WSM_CREATE_LBJ_COPY_ROUTING'));

v_instance_id         NUMBER;
v_dblink              VARCHAR2(128);
v_instance_code       VARCHAR2(3);
v_application_id      NUMBER;

--This Procedure checks if there is any detail exists for OPM Jobs
--If detail exists, the scheduling method is set to 1(Manual
--scheduling) and if doesn't exist then the scheduling method is
--set to 2(Others).
PROCEDURE SET_OPM_SCHEDULING_METHOD
IS
BEGIN

      UPDATE wip_job_schedule_interface i
      SET i.scheduling_method=2
      WHERE
          i.group_id = G_OPM_WIP_GROUP_ID
      AND i.load_type in(1,3);

      UPDATE wip_job_schedule_interface i
      SET i.scheduling_method=1
      WHERE
           EXISTS(SELECT 1
                  FROM   WIP_JOB_DTLS_INTERFACE jdi
                  WHERE  jdi.group_id=G_OPM_WIP_GROUP_ID
                  AND    jdi.parent_header_id = i.header_id
                  AND    ROWNUM=1)
      AND i.group_id = G_OPM_WIP_GROUP_ID
      AND i.load_type in(1,3);

END SET_OPM_SCHEDULING_METHOD;




--Overloaded this function so that UI code MSCRLWFB.pls can still call other
--Initialize Function
PROCEDURE INITIALIZE
               ( p_user_name         IN  VARCHAR2,
                 p_resp_name         IN  VARCHAR2,
                 p_application_name IN  VARCHAR2,
                 p_instance_id       IN  NUMBER,
                 p_instance_code     IN  VARCHAR2,
                 p_aps_dblink        IN  VARCHAR2,
                 p_wip_group_id      OUT NOCOPY  NUMBER,
                 p_po_batch_number   OUT NOCOPY NUMBER,
                 p_application_id    IN  NUMBER)
IS
BEGIN

 v_instance_id    := p_instance_id;
 v_instance_code  := p_instance_code;
 v_dblink         := p_aps_dblink;
 v_application_id := p_application_id;

  INITIALIZE(  p_user_name ,
               p_resp_name ,
               p_application_name,
               p_wip_group_id,
               p_po_batch_number );


END INITIALIZE;

PROCEDURE INITIALIZE(  p_user_name        IN  VARCHAR2,
                       p_resp_name        IN  VARCHAR2,
                       p_application_name IN  VARCHAR2,
                       p_wip_group_id      OUT NOCOPY NUMBER,
                       p_po_batch_number   OUT NOCOPY NUMBER )
IS

    l_user_id         NUMBER;
    l_application_id  NUMBER;
    l_resp_id         NUMBER;
    lv_log_msg           varchar2(500);
BEGIN

    SELECT wip_job_schedule_interface_s.nextval,
           mrp_workbench_query_s.nextval,
         --  TO_NUMBER( FND_PROFILE.VALUE('MSC_RESOURCE_TYPE')),
           TO_NUMBER( FND_PROFILE.VALUE('MSC_ALT_RES_PRIORITY')),
           TO_NUMBER( FND_PROFILE.VALUE('MSC_SIMUL_RES_SEQ')),
           NVL(FND_PROFILE.VALUE('MSC_UPD_REQ_DATE_REL'),'N')
      INTO G_WIP_GROUP_ID,
           G_PO_BATCH_NUMBER,
         --  PV_RESOURCE_TYPE,
           PV_RES_PRIORITY,
           PV_SIM_RES_SEQ,
           PV_REL_REQUEST_DATE
      FROM DUAL;

    SELECT wip_job_schedule_interface_s.nextval
      INTO G_OPM_WIP_GROUP_ID
      FROM DUAL;

     p_wip_group_id := G_WIP_GROUP_ID;
     p_po_batch_number := G_PO_BATCH_NUMBER;

    /* if user_id = -1, it means this procedure is called from a
       remote database */
    IF FND_GLOBAL.USER_ID = -1 THEN

       BEGIN

          SELECT USER_ID
            INTO l_user_id
            FROM FND_USER
           WHERE USER_NAME = p_user_name;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
              raise_application_error (-20001, 'NO_USER_DEFINED');
        END;

        IF MRP_CL_FUNCTION.validateUser(l_user_id,MSC_UTIL.TASK_RELEASE,lv_log_msg) THEN
            MRP_CL_FUNCTION.MSC_Initialize(MSC_UTIL.TASK_RELEASE,
                                           l_user_id,
                                           -1, --l_resp_id,
                                           -1 --l_application_id
                                           );
        ELSE
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_log_msg);
            raise_application_error (-20001, lv_log_msg);
        END IF;

    END IF;

END INITIALIZE;


PROCEDURE MODIFY_LJ_RES_REQ
IS

TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
TYPE DateTab IS TABLE OF DATE   INDEX BY BINARY_INTEGER;

lv_std_job_count   	NUMBER;
lv_jsi_rowid        	RIDTab;
lv_header_id        	NumTab;
lv_job_schedule_type	NumTab;
lv_routing_seq_id   	NumTab;
lv_start_date       	DateTab;
lv_wip_entity_id    	NumTab;

lv_details          	NUMBER;

lv_nwk_job_op_seq_num  	NumTab;
lv_nwk_op_seq_num	NumTab;
lv_un_op_cnt		NUMBER;

lv_pri_res_rowid        RIDTab;
lv_pri_res_seq_num      NumTab;
lv_pri_sub_grp_num      NumTab;
lv_pri_schd_seq_num     NumTab;

lv_pri_res_cnt          Number;

lv_alt_res_rowid        RIDTab;
lv_alt_sub_grp_num      NumTab;
lv_alt_schd_seq_num     NumTab;

lv_alt_res_cnt          Number;

lv_unschd_op_seq_num	NumTab;
lv_unschd_rtng_op_seq_num	NumTab;
lv_unschd_res_id	NumTab;
lv_unschd_res_seq_num	NumTab;
lv_unschd_schd_seq_num	NumTab;
lv_unschd_rep_grp_num	NumTab;
lv_unschd_subs_grp_num	NumTab;
lv_unschd_load_type	NumTab;
-- dsr added following 7 lines
lv_unschd_firm_flag	NumTab;
lv_unschd_setup_id	NumTab;
lv_unschd_group_sequence_id	NumTab;
LV_UNSCHD_GROUP_SEQ_NUM	NumTab;
lv_unschd_batch_id	NumTab;
LV_UNSCHD_MAX_ASSIGNED_UNITS	NumTab;
lv_unschd_parent_seq_num	NumTab;

lv_unschd_res_cnt	Number;


lv_unres_res_seq_num	NumTab;
lv_unres_schd_seq_num	NumTab;
lv_unres_res_id		NumTab;
lv_unres_sub_grp_num	NumTab;
lv_unres_rep_grp_num	NumTab;


lv_unres_cnt		Number;

lv_res_rowid		RidTab;
lv_res_seq_num		NumTab;
lv_sub_grp_num		NumTab;
lv_schd_seq_num		NumTab;


lv_res_cnt		Number;

lv_cur_op_res_rowid     RIDTab;
lv_cur_op_res_seq_num	NumTab;
lv_cur_op_sub_grp_num   NumTab;
lv_cur_op_schd_seq_num	NumTab;

lv_cur_op_res_cnt       Number;

lv_unschd_job_op_seq_num	NumTab;






Begin

/* get header info for jobs being loaded */

SELECT jsi.rowid,
          jsi.header_id,
          rtng.common_routing_sequence_id,
          jsi.load_type,
          jsi.first_unit_start_date,
          jsi.wip_entity_id
     BULK COLLECT
     INTO lv_jsi_rowid,
          lv_header_id,
          lv_routing_seq_id,
          lv_job_schedule_type,
          lv_start_date,
          lv_wip_entity_id
     FROM BOM_OPERATIONAL_ROUTINGS rtng,
          WSM_LOT_JOB_INTERFACE jsi
    WHERE jsi.group_id = G_WIP_GROUP_ID
      AND jsi.load_type in (5,6)  /* standard job */
      AND rtng.assembly_item_id(+)= jsi.primary_item_id
      AND rtng.organization_id(+)= jsi.organization_id
      AND NVL(rtng.alternate_routing_designator(+),' ')=
              NVL( jsi.alternate_routing_designator,' ');

    lv_std_job_count:= SQL%ROWCOUNT;

    IF lv_std_job_count= 0 THEN RETURN; END IF;

    FOR n IN 1..lv_std_job_count LOOP

    BEGIN

    	/* check whether the details has been released for the job */

    	 select count(*)
    	 into lv_details
    	 From WSM_LOT_JOB_DTL_INTERFACE jdi
    	 Where  jdi.group_id = G_WIP_GROUP_ID
         	and jdi.parent_header_id = lv_header_id(n);

    	 If lv_details = 0 Then

    	 If lv_job_schedule_type(n) in (5,6) Then              --bug#3459145

    	 update WSM_LOT_JOB_INTERFACE
         set FIRST_UNIT_START_DATE  = null
         where GROUP_ID=G_WIP_GROUP_ID
         and   HEADER_ID=lv_header_id(n);

         END IF;

    	 ELSE

    	 BEGIN

        /* when we are releasing the details, scheduling_method is 3  Bug 3401524*/

         IF var_lot_job_copy_rout = 1 THEN
	         update WSM_LOT_JOB_INTERFACE
        	 set SCHEDULING_METHOD=3
	         where GROUP_ID=G_WIP_GROUP_ID
        	 and   HEADER_ID=lv_header_id(n);
         END IF;

        /* Determine the unscheduled operations that are part of the recommended path */

          Select jdi.JOB_OP_SEQ_NUM,
                 jdi.ROUTING_OP_SEQ_NUM
          BULK COLLECT INTO
                lv_nwk_job_op_seq_num,
                lv_nwk_op_seq_num
          From   WSM_LOT_JOB_DTL_INTERFACE jdi
          Where  jdi.group_id = G_WIP_GROUP_ID
         	and jdi.parent_header_id = lv_header_id(n)
    		and jdi.load_type = 3
    		and not exists (  SELECT 1 from WSM_LOT_JOB_DTL_INTERFACE jdi1
         		Where  jdi1.group_id = G_WIP_GROUP_ID
         		and jdi1.parent_header_id = lv_header_id(n)
    			and jdi1.load_type = 1
    			and nvl(jdi1.JOB_OP_SEQ_NUM,-1) = nvl(jdi.JOB_OP_SEQ_NUM,-1)
    			and nvl(jdi1.ROUTING_OP_SEQ_NUM,-1) = nvl(jdi.ROUTING_OP_SEQ_NUM,-1));
    	 /*union
    	 Select  to_number(NULL),			--Bug#3432607
         	jdi.NEXT_ROUTING_OP_SEQ_NUM
         From   WSM_LOT_JOB_DTL_INTERFACE jdi
         Where  jdi.group_id = G_WIP_GROUP_ID
         	and jdi.parent_header_id = lv_header_id(n)
    		and jdi.load_type = 5
    		and not exists (  SELECT 1 from WSM_LOT_JOB_DTL_INTERFACE jdi1
         		Where  jdi1.group_id = G_WIP_GROUP_ID
         		and jdi1.parent_header_id = lv_header_id(n)
    			and jdi1.load_type = 3
    			and jdi1.ROUTING_OP_SEQ_NUM = jdi.NEXT_ROUTING_OP_SEQ_NUM)
    		and not exists (select 1
    				from WSM_LOT_JOB_DTL_INTERFACE jdi1
    				where jdi1.group_id = G_WIP_GROUP_ID
         			and jdi1.parent_header_id = lv_header_id(n)
    				and jdi1.load_type = 5
    				and jdi1.ROUTING_OP_SEQ_NUM = jdi.NEXT_ROUTING_OP_SEQ_NUM);*/

    	lv_un_op_cnt := SQL%ROWCOUNT;

    	/* For Bug 3608361 -- we need not set start_date and completion date as null for unscheduled operations */
    --	IF lv_un_op_cnt > 0 Then

     	  -- FORALL j in 1..lv_un_op_cnt

     	/* insert unscheduled operations with start_date and completion date as null

        INSERT INTO WSM_LOT_JOB_DTL_INTERFACE			--Bug#3432607
          (    last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               substitution_type,
               load_type,
               operation_start_date,
               operation_completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lv_nwk_job_op_seq_num(j),
               lv_nwk_op_seq_num(j),
               4,
               3,
               null,
               null,
	       1,
               1,
               sysdate
          FROM DUAL;*/


          /* For Bug 3608361 -- we need not set start_date and completion date as null for unscheduled operations */
          /*
          UPDATE WSM_LOT_JOB_DTL_INTERFACE jdi
          SET operation_start_date = null, operation_completion_date = null
          WHERE jdi.group_id = G_WIP_GROUP_ID
          	AND jdi.parent_header_id = lv_header_id(n)
          	AND jdi.load_type = 3
          	AND nvl(jdi.job_op_seq_num,-1) = nvl(lv_nwk_job_op_seq_num(j),-1)
          	AND routing_op_seq_num = lv_nwk_op_seq_num(j);
          */

        -- END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;
    END;


    If lv_job_schedule_type(n) = 5 Then   /*New jobs*/

    /* Get resource_seq_num for primary resource records */

    BEGIN

    Select jdi.rowid,
    	   bor.resource_seq_num,
    	   bor.substitute_group_num,
    	   bor.schedule_seq_num
    BULK COLLECT INTO  lv_pri_res_rowid,
    	  lv_pri_res_seq_num,
    	  lv_pri_sub_grp_num,
    	  lv_pri_schd_seq_num
    From WSM_LOT_JOB_DTL_INTERFACE jdi,
    	 bom_operation_resources bor,
    	 bom_operation_sequences bos
    Where jdi.group_id = G_WIP_GROUP_ID
    and jdi.parent_header_id = lv_header_id(n)
    -- ds and jdi.load_type in (1,4)
    and jdi.load_type in (1,4, RESOURCE_INSTANCES_OSFM, RESOURCE_INSTANCE_USAGE_OSFM)
    and jdi.replacement_group_num = 0
    and bos.operation_seq_num = jdi.routing_op_seq_num
    -- and nvl(bor.schedule_seq_num,bor.resource_seq_num) = jdi.resource_seq_num
    and bor.resource_seq_num = jdi.resource_seq_num
    and bor.resource_id = jdi.resource_id_new
    and bos.routing_sequence_id = lv_routing_seq_id(n)
    and bos.operation_sequence_id = bor.operation_sequence_id
    and bos.effectivity_date <= lv_start_date(n)
    and NVL(bos.disable_date, lv_start_date(n)) >= lv_start_date(n);


    lv_pri_res_cnt := SQL%ROWCOUNT;

    	IF lv_pri_res_cnt > 0  THEN

	FORALL k IN 1..lv_pri_res_cnt
        UPDATE WSM_LOT_JOB_DTL_INTERFACE set resource_seq_num = lv_pri_res_seq_num(k),
        substitute_group_num = lv_pri_sub_grp_num(k),
        schedule_seq_num = lv_pri_schd_seq_num(k)
 	WHERE rowid = lv_pri_res_rowid(k);

        END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

    END;

/* get resource_seq_num for alternate resources */

   BEGIN

   Select distinct
    	  jdi.rowid,
   	  bsor.substitute_group_num,
   	  bsor.schedule_seq_num
	  BULK COLLECT INTO lv_alt_res_rowid,
	       lv_alt_sub_grp_num,
	       lv_alt_schd_seq_num
   From  WSM_LOT_JOB_DTL_INTERFACE jdi,
    	 bom_operation_resources bor,
    	 bom_operation_sequences bos,
    	 bom_sub_operation_resources bsor
   Where jdi.group_id = G_WIP_GROUP_ID
    and jdi.parent_header_id = lv_header_id(n)
    -- and jdi.load_type in (1,4)
    and jdi.load_type in (1,4, RESOURCE_INSTANCES_OSFM, RESOURCE_INSTANCE_USAGE_OSFM)
    and jdi.replacement_group_num <> 0
    and bos.routing_sequence_id = lv_routing_seq_id(n)
    and bos.operation_sequence_id = bor.operation_sequence_id
    and bos.effectivity_date <= lv_start_date(n)
    and NVL(bos.disable_date, lv_start_date(n)) >= lv_start_date(n)
    and bsor.substitute_group_num = bor.substitute_group_num
    and bsor.operation_sequence_id = bor.operation_sequence_id
    and nvl(jdi.schedule_seq_num,jdi.resource_seq_num )= nvl(bor.schedule_seq_num,bor.resource_seq_num)
    and jdi.resource_id_new = bsor.resource_id
    and jdi.replacement_group_num = bsor.replacement_group_num
    and jdi.routing_op_seq_num = bos.operation_seq_num;

    lv_alt_res_cnt := SQL%ROWCOUNT;

    	IF lv_alt_res_cnt > 0  THEN

	FORALL k IN 1..lv_alt_res_cnt
        UPDATE WSM_LOT_JOB_DTL_INTERFACE set substitute_group_num = lv_alt_sub_grp_num(k),
        schedule_seq_num = lv_alt_schd_seq_num(k),
        resource_seq_num = null
 	WHERE rowid = lv_alt_res_rowid(k);

        END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

    END;

  /* get details for unscheduled resources and insert them with start_date and completion_date as null */

     BEGIN
	Select bos.operation_seq_num,
	bor.resource_id,
	bor.resource_seq_num,
	bor.schedule_seq_num,
	0,
	bor.substitute_group_num,
	jdi.load_type
	 , jdi.firm_type 	 -- dsr: added the following 7 columns
	 , jdi.setup_id
	 , jdi.group_sequence_id
	 , jdi.group_sequence_num -- sbala
	 , jdi.batch_id
	 , jdi.max_assigned_units   --- sbala
	 , jdi.parent_resource_seq_num  -- sbala
	 -- , resource_seq_num
	 -- , schedule_seq_num
	BULK COLLECT INTO
	lv_unschd_op_seq_num,
	lv_unschd_res_id,
	lv_unschd_res_seq_num,
	lv_unschd_schd_seq_num,
	lv_unschd_rep_grp_num,
	lv_unschd_subs_grp_num,
	lv_unschd_load_type
	-- dsr added following 7 lines
	 , lv_unschd_firm_flag
	 , lv_unschd_setup_id
	 , lv_unschd_group_sequence_id
	 , LV_UNSCHD_GROUP_SEQ_NUM
	 , lv_unschd_batch_id
	 , LV_UNSCHD_MAX_ASSIGNED_UNITS
	 , lv_unschd_parent_seq_num
	 -- , lv_unschd_schedule_seq_num
	from  bom_operation_resources bor,
		bom_operation_sequences bos,
		wsm_lot_job_dtl_interface jdi
	Where	bor.schedule_flag = 2
	and bor.schedule_seq_num = jdi.schedule_seq_num
	and nvl(jdi.replacement_group_num,0) = 0
	and bos.operation_seq_num = jdi.routing_op_seq_num
	and bos.effectivity_date <= lv_start_date(n)
	and NVL(bos.disable_date, lv_start_date(n)) >= lv_start_date(n)
	and bor.operation_sequence_id = bos.operation_sequence_id
	and bos.routing_sequence_id = lv_routing_seq_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	-- and jdi.load_type=1
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM)
	union all
	Select bos.operation_seq_num,
	bsor.resource_id,
	to_number(null),
	bsor.schedule_seq_num,
	bsor.replacement_group_num,
	bsor.substitute_group_num,
	jdi.load_type
	 -- dsr: added the following 7 columns
	 , jdi.firm_type
	 , jdi.setup_id
	 , jdi.group_sequence_id
	 , jdi.group_sequence_num --- sbala
	 , jdi.batch_id
	 , jdi.max_assigned_units --- sbala
	 , jdi.parent_resource_seq_num
	from  bom_sub_operation_resources bsor,
	bom_operation_sequences bos,
	wsm_lot_job_dtl_interface jdi
	Where bsor.schedule_flag = 2
	and bsor.schedule_seq_num = jdi.schedule_seq_num
	and jdi.replacement_group_num = bsor.replacement_group_num
	and bos.operation_seq_num = jdi.routing_op_seq_num
	and bos.effectivity_date <= lv_start_date(n)
	and NVL(bos.disable_date, lv_start_date(n)) >= lv_start_date(n)
	and bsor.operation_sequence_id = bos.operation_sequence_id
	and bos.routing_sequence_id = lv_routing_seq_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	-- and jdi.load_type=1
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM)
	union all
	Select distinct
	bos.operation_seq_num,
	bor.resource_id,
	bor.resource_seq_num,
	bor.schedule_seq_num,
	0,
	bor.substitute_group_num,
	jdi.load_type
	 -- dsr: added the following 7 columns
	 , jdi.firm_type
	 , jdi.setup_id
	 , jdi.group_sequence_id
	 , jdi.group_sequence_num --- sbala
	 , jdi.batch_id
	 , jdi.max_assigned_units   --- sbala
	 , jdi.parent_resource_seq_num --- sbala
	from  bom_operation_resources bor,
	bom_operation_sequences bos,
	wsm_lot_job_dtl_interface jdi
	Where bor.schedule_flag = 2
	and not exists (select schedule_seq_num from wsm_lot_job_dtl_interface jdi1
				where jdi1.group_id = G_WIP_GROUP_ID
				and jdi1.parent_header_id = lv_header_id(n)
				and jdi1.routing_op_seq_num = bos.operation_seq_num
				and jdi1.schedule_seq_num = bor.schedule_seq_num)
	and bos.operation_seq_num = jdi.routing_op_seq_num
	and bos.effectivity_date <= lv_start_date(n)
	and NVL(bos.disable_date, lv_start_date(n)) >= lv_start_date(n)
	and bor.operation_sequence_id = bos.operation_sequence_id
	and bos.routing_sequence_id = lv_routing_seq_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	-- and jdi.load_type=1 ;
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM);

	lv_unschd_res_cnt := SQL%ROWCOUNT;

	IF lv_unschd_res_cnt > 0 Then

	For l in 1..lv_unschd_res_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(      last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               schedule_seq_num,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date
	 -- dsr: added the following 7 columns
	 , firm_type --- sbala
	 , setup_id
	 , group_sequence_id
	 , group_sequence_num --- sbala
	 , batch_id
	 , max_assigned_units  --- sbala
	 , parent_resource_seq_num
	 -- , resource_seq_num
	 -- , schedule_seq_num
	)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lv_unschd_op_seq_num(l),
               lv_unschd_res_seq_num(l),
	       lv_unschd_res_id(l),
	       lv_unschd_schd_seq_num(l),
	       lv_unschd_subs_grp_num(l),
	       lv_unschd_rep_grp_num(l),
               4,
               lv_unschd_load_type(l),
               Null,
               Null,
	       1,
               1,
               sysdate
                -- dsr: added the following 7 columns
	 , lv_unschd_firm_flag(l)
	 , lv_unschd_setup_id(l)
	 , lv_unschd_group_sequence_id(l)
	 , LV_UNSCHD_GROUP_SEQ_NUM(l)
	 , lv_unschd_batch_id(l)
	 , LV_UNSCHD_MAX_ASSIGNED_UNITS(l)
	 , lv_unschd_parent_seq_num(l)
	 -- , lv_unschd_schedule_seq_num(l)
          From Dual;
	END LOOP;
	END IF;

      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

     END ;

 /* Primary resources for unscheduled operation */


	For k in 1..lv_un_op_cnt  LOOP

       BEGIN

	select bor.resource_seq_num,
       	bor.schedule_seq_num,
       	bor.resource_id,
       	bor.substitute_group_num
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_res_id,
       	lv_unres_sub_grp_num
	From  BOM_OPERATION_SEQUENCES bos,
	      	BOM_OPERATION_RESOURCES bor
	Where 	bos.routing_sequence_id = lv_routing_seq_id(n)
	and bos.operation_seq_num = lv_nwk_op_seq_num(k)
	and bos.effectivity_date <= lv_start_date(n)
      	and NVL(bos.disable_date, lv_start_date(n)) >= lv_start_date(n)
        and bor.operation_sequence_id = bos.operation_sequence_id;

	lv_unres_cnt := SQL%ROWCOUNT;

	IF lv_unres_cnt > 0 Then

		For l in 1..lv_unres_cnt  LOOP

		Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    		(    	last_update_date,
               		last_updated_by,
               		last_update_login,
               		creation_date,
               		created_by,
               		RECORD_ID,
               		group_id,
               		parent_header_id,
               		job_op_seq_num,
               		routing_op_seq_num,
               		resource_seq_num,
               		resource_id_new,
               		schedule_seq_num,
               		substitute_group_num,
               		replacement_group_num,
               		substitution_type,
               		load_type,
               		start_date,
               		completion_date,
               		process_phase,
	       		process_status,
	       		transaction_date)
        	SELECT SYSDATE,
               		FND_GLOBAL.USER_ID,
               		FND_GLOBAL.USER_ID,
               		SYSDATE,
               		FND_GLOBAL.USER_ID,
               		WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               		G_WIP_GROUP_ID,
               		lv_header_id(n),
               		null,
               		lv_nwk_op_seq_num(k),
               		lv_unres_res_seq_num(l),
	       		lv_unres_res_id(l),
	       		lv_unres_schd_seq_num(l),
	       		lv_unres_sub_grp_num(l),
	       		0,
               		4,
               		1,
               		null,
               		null,
	       		1,
               		1,
               		sysdate
               	From Dual;

                /* Bug 3344136
		Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    		(    	last_update_date,
               		last_updated_by,
               		last_update_login,
               		creation_date,
               		created_by,
               		RECORD_ID,
               		group_id,
               		parent_header_id,
               		job_op_seq_num,
               		routing_op_seq_num,
               		resource_seq_num,
               		resource_id_new,
               		substitute_group_num,
               		replacement_group_num,
               		substitution_type,
               		load_type,
               		start_date,
               		completion_date,
               		process_phase,
	       		process_status,
	       		transaction_date)
        	SELECT SYSDATE,
               		FND_GLOBAL.USER_ID,
               		FND_GLOBAL.USER_ID,
               		SYSDATE,
               		FND_GLOBAL.USER_ID,
               		WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               		G_WIP_GROUP_ID,
               		lv_header_id(n),
               		null,
               		lv_nwk_op_seq_num(k),
               		lv_unres_res_seq_num(l),
	       		lv_unres_res_id(l),
	       		lv_unres_schd_seq_num(l),
	       		0,
               		4,
               		4,
               		null,
               		null,
	       		2,
               		1,
               		sysdate
               	From Dual;
               */

		END LOOP;
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

      END;

     END LOOP;


    END If;  /* new jobs */


    If lv_job_schedule_type(n) = 6 Then  /* existing jobs */

    BEGIN

   	Select jdi.rowid,
    	wcor.resource_seq_num,
    	wcor.substitute_group_num,
    	wcor.schedule_seq_num
    	BULK COLLECT INTO
    		lv_res_rowid,
    		lv_res_seq_num,
    		lv_sub_grp_num,
    		lv_schd_seq_num
    	From WSM_LOT_JOB_DTL_INTERFACE jdi,
    		WSM_COPY_OP_RESOURCES wcor
    	Where jdi.group_id = G_WIP_GROUP_ID
    	and jdi.parent_header_id = lv_header_id(n)
    	-- and jdi.load_type in (1,4)
    	and jdi.load_type in (1,4, RESOURCE_INSTANCES_OSFM, RESOURCE_INSTANCE_USAGE_OSFM)
    	and jdi.replacement_group_num = wcor.replacement_group_num
    	-- and nvl(wcor.schedule_seq_num,wcor.resource_seq_num) = jdi.resource_seq_num
    	and wcor.resource_seq_num = jdi.resource_seq_num
    	and wcor.resource_id = jdi.resource_id_new
    	and wcor.operation_seq_num = jdi.ROUTING_OP_SEQ_NUM
    	and jdi.job_op_seq_num is null
    	and wcor.wip_entity_id = lv_wip_entity_id(n);


    lv_res_cnt := SQL%ROWCOUNT;

    	IF lv_res_cnt > 0  THEN

	FORALL k IN 1..lv_res_cnt
        UPDATE WSM_LOT_JOB_DTL_INTERFACE set resource_seq_num = lv_res_seq_num(k),
        substitute_group_num = lv_sub_grp_num(k),
        schedule_seq_num = lv_schd_seq_num(k)
 	WHERE rowid = lv_res_rowid(k);

        END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
     WHEN OTHERS THEN RAISE;

    END;

   BEGIN

   Select jdi.rowid,
   	  wor.resource_seq_num,
   	  wor.substitute_group_num,
   	  wor.schedule_seq_num
	  BULK COLLECT INTO
	  	lv_cur_op_res_rowid,
	      	lv_cur_op_res_seq_num,
	       	lv_cur_op_sub_grp_num,
	       	lv_cur_op_schd_seq_num
   From  WSM_LOT_JOB_DTL_INTERFACE jdi,
    	 wip_operation_resources wor
   Where jdi.group_id = G_WIP_GROUP_ID
    and jdi.parent_header_id = lv_header_id(n)
    -- and jdi.load_type in (1,4)
    and jdi.load_type in (1,4, RESOURCE_INSTANCES_OSFM, RESOURCE_INSTANCE_USAGE_OSFM)
    and jdi.replacement_group_num = nvl(wor.replacement_group_num,0)
    and nvl(wor.schedule_seq_num,wor.resource_seq_num) = jdi.resource_seq_num
    and wor.resource_id = jdi.resource_id_new
    and wor.operation_seq_num = jdi.JOB_OP_SEQ_NUM
    and wor.wip_entity_id = lv_wip_entity_id(n)
    union all
    Select jdi.rowid,
   	  wsor.resource_seq_num,
   	  wsor.substitute_group_num,
   	  wsor.schedule_seq_num
   From  WSM_LOT_JOB_DTL_INTERFACE jdi,
    	 wip_sub_operation_resources wsor
   Where jdi.group_id = G_WIP_GROUP_ID
    and jdi.parent_header_id = lv_header_id(n)
    -- and jdi.load_type in (1,4)
    and jdi.load_type in (1,4, RESOURCE_INSTANCES_OSFM, RESOURCE_INSTANCE_USAGE_OSFM)
    and jdi.replacement_group_num = nvl(wsor.replacement_group_num,0)
    and nvl(wsor.schedule_seq_num,wsor.resource_seq_num) = jdi.resource_seq_num
    and wsor.resource_id = jdi.resource_id_new
    and wsor.operation_seq_num = jdi.JOB_OP_SEQ_NUM
    and wsor.wip_entity_id = lv_wip_entity_id(n);

    lv_cur_op_res_cnt := SQL%ROWCOUNT;

    	IF lv_cur_op_res_cnt > 0  THEN

	FORALL k IN 1..lv_cur_op_res_cnt
        UPDATE WSM_LOT_JOB_DTL_INTERFACE set substitute_group_num = lv_cur_op_sub_grp_num(k),
        schedule_seq_num = lv_cur_op_schd_seq_num(k),
        resource_seq_num = lv_cur_op_res_seq_num(k)
 	WHERE rowid = lv_cur_op_res_rowid(k);

        END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

    END;

    BEGIN

	Select wor.operation_seq_num,
	wor.resource_id,
	wor.resource_seq_num,
	wor.schedule_seq_num,
	wor.replacement_group_num,
	wor.substitute_group_num,
	jdi.routing_op_seq_num,
	jdi.load_type
	BULK COLLECT INTO
	lv_unschd_job_op_seq_num,
	lv_unschd_res_id,
	lv_unschd_res_seq_num,
	lv_unschd_schd_seq_num,
	lv_unschd_rep_grp_num,
	lv_unschd_subs_grp_num,
	lv_unschd_rtng_op_seq_num,
	lv_unschd_load_type
	from  wip_operation_resources wor,
	wsm_lot_job_dtl_interface jdi
	where wor.scheduled_flag = 2
	and wor.schedule_seq_num = jdi.schedule_seq_num
	and jdi.replacement_group_num = nvl(wor.replacement_group_num,0)
	and wor.operation_seq_num = jdi.job_op_seq_num
	and wor.wip_entity_id = lv_wip_entity_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	-- and jdi.load_type=1
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM)
	union all
	Select wsor.operation_seq_num,
	wsor.resource_id,
	wsor.resource_seq_num,
	wsor.schedule_seq_num,
	wsor.replacement_group_num,
	wsor.substitute_group_num,
	jdi.routing_op_seq_num,
	jdi.load_type
	from  wip_sub_operation_resources wsor,
	wsm_lot_job_dtl_interface jdi
	where wsor.scheduled_flag = 2
	and wsor.schedule_seq_num = jdi.schedule_seq_num
	and jdi.replacement_group_num = nvl(wsor.replacement_group_num,0)
	and wsor.operation_seq_num = jdi.job_op_seq_num
	and wsor.wip_entity_id = lv_wip_entity_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	-- and jdi.load_type=1
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM)
	union all
	Select distinct
	wor.operation_seq_num,
	wor.resource_id,
	wor.resource_seq_num,
	wor.schedule_seq_num,
	nvl(wor.replacement_group_num,0),
	wor.substitute_group_num,
	jdi.routing_op_seq_num,
	jdi.load_type
	from  wip_operation_resources wor,
	wsm_lot_job_dtl_interface jdi
	Where wor.scheduled_flag = 2
	and not exists (select schedule_seq_num from wsm_lot_job_dtl_interface jdi1
				where jdi1.group_id = G_WIP_GROUP_ID
				and jdi1.parent_header_id = lv_header_id(n)
				and jdi1.job_op_seq_num = wor.operation_seq_num
				and jdi1.schedule_seq_num = wor.schedule_seq_num)
	and wor.operation_seq_num = jdi.job_op_seq_num
	and wor.wip_entity_id = lv_wip_entity_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	--and jdi.load_type=1;
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM);

	lv_unschd_res_cnt := SQL%ROWCOUNT;

	IF lv_unschd_res_cnt > 0 Then

	For l in 1..lv_unschd_res_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(       last_update_date,
               	last_updated_by,
               	last_update_login,
               	creation_date,
               	created_by,
               	RECORD_ID,
               	group_id,
               	parent_header_id,
               	JOB_OP_SEQ_NUM,
               	ROUTING_OP_SEQ_NUM,
               	resource_seq_num,
               	resource_id_new,
               	schedule_seq_num,
               	substitute_group_num,
               	replacement_group_num,
               	substitution_type,
               	load_type,
               	start_date,
               	completion_date,
               	process_phase,
	       	process_status,
	       	transaction_date
	 -- dsr: added the following 8 columns
	 , firm_type --- sbala
	 , setup_id
	 , group_sequence_id
	 , group_sequence_num -- sbala
	 , batch_id
	 , max_assigned_units  --- sbala
	 , parent_resource_seq_num
	 -- , resource_seq_num
	 -- , schedule_seq_num
	 )
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lv_unschd_job_op_seq_num(l),
               lv_unschd_rtng_op_seq_num(l),
               lv_unschd_res_seq_num(l),
	       lv_unschd_res_id(l),
	       lv_unschd_schd_seq_num(l),
	       lv_unschd_subs_grp_num(l),
	       lv_unschd_rep_grp_num(l),
               4,
               lv_unschd_load_type(l),
               Null,
               Null,
	       1,
               1,
               sysdate
          -- dsr: added the following 8 columns
	 , lv_unschd_firm_flag(l)
	 , lv_unschd_setup_id(l)
	 , lv_unschd_group_sequence_id(l)
	 , LV_UNSCHD_GROUP_SEQ_NUM(l)
	 , lv_unschd_batch_id(l)
	 , LV_UNSCHD_MAX_ASSIGNED_UNITS(l)
	 , lv_unschd_parent_seq_num(l)
	 -- , lv_unschd_schedule_seq_num(l)
        From Dual;
	END LOOP;
	END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

     END;

     BEGIN

	Select wcor.operation_seq_num,
	wcor.resource_id,
	wcor.resource_seq_num,
	wcor.schedule_seq_num,
	wcor.replacement_group_num,
	wcor.substitute_group_num,
	jdi.load_type
	BULK COLLECT INTO lv_unschd_op_seq_num,
	lv_unschd_res_id,
	lv_unschd_res_seq_num,
	lv_unschd_schd_seq_num,
	lv_unschd_rep_grp_num,
	lv_unschd_subs_grp_num,
	lv_unschd_load_type
	from  wsm_copy_op_resources wcor,
	wsm_lot_job_dtl_interface jdi
	Where wcor.schedule_flag = 2
	and wcor.schedule_seq_num = jdi.schedule_seq_num
	and jdi.replacement_group_num = wcor.replacement_group_num
	and wcor.operation_seq_num = jdi.ROUTING_op_seq_num
	and jdi.JOB_OP_SEQ_NUM is null
	and wcor.wip_entity_id = lv_wip_entity_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	-- and jdi.load_type=1
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM)
	union all
	Select distinct
	wcor.operation_seq_num,
	wcor.resource_id,
	wcor.resource_seq_num,
	wcor.schedule_seq_num,
	nvl(wcor.replacement_group_num,0),
	wcor.substitute_group_num,
	jdi.load_type
	from  wsm_copy_op_resources wcor,
	wsm_lot_job_dtl_interface jdi
	Where wcor.schedule_flag = 2
	and not exists (select schedule_seq_num from wsm_lot_job_dtl_interface jdi1
				where jdi1.group_id = G_WIP_GROUP_ID
				and jdi1.parent_header_id = lv_header_id(n)
				and jdi1.ROUTING_op_seq_num = wcor.operation_seq_num
				and jdi1.schedule_seq_num = wcor.schedule_seq_num)
	and wcor.operation_seq_num = jdi.routing_op_seq_num
	and wcor.wip_entity_id = lv_wip_entity_id(n)
	and jdi.group_id = G_WIP_GROUP_ID
	and jdi.parent_header_id = lv_header_id(n)
	and jdi.JOB_OP_SEQ_NUM is null
	-- and jdi.load_type =1;
	and jdi.load_type IN (1, RESOURCE_INSTANCES_OSFM);


	lv_unschd_res_cnt := SQL%ROWCOUNT;

	IF lv_unschd_res_cnt > 0 Then

	For l in 1..lv_unschd_res_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(      last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               JOB_OP_SEQ_NUM,
               ROUTING_OP_SEQ_NUM,
               resource_seq_num,
               resource_id_new,
               schedule_seq_num,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               null,
               lv_unschd_op_seq_num(l),
               lv_unschd_res_seq_num(l),
	       lv_unschd_res_id(l),
	       lv_unschd_schd_seq_num(l),
	       lv_unschd_subs_grp_num(l),
	       lv_unschd_rep_grp_num(l),
               4,
               lv_unschd_load_type(l),
               Null,
               Null,
	       1,
               1,
               sysdate
          From Dual;

	END LOOP;
	END IF;


       EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

      END;


	For k in 1..lv_un_op_cnt  LOOP

	BEGIN

	select wor.resource_seq_num,
       	wor.schedule_seq_num,
       	wor.substitute_group_num,
       	wor.replacement_group_num,
       	wor.resource_id
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_sub_grp_num,
       	lv_unres_rep_grp_num,
       	lv_unres_res_id
	From  WIP_OPERATION_RESOURCES wor
	Where 	wor.operation_seq_num = lv_nwk_job_op_seq_num(k)
	and wor.wip_entity_id = lv_wip_entity_id(n);

	lv_unres_cnt := SQL%ROWCOUNT;

	IF lv_unres_cnt > 0 Then

	For l in 1..lv_unres_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(    	last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               schedule_seq_num,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lv_nwk_job_op_seq_num(k),
               lv_nwk_op_seq_num(k),
               lv_unres_res_seq_num(l),
	       lv_unres_res_id(l),
	       lv_unres_schd_seq_num(l),
	       lv_unres_sub_grp_num(l),
	       0,
               4,
               1,
               null,
               null,
	       1,
               1,
               sysdate
          From Dual;

         /* Bug 3344136
          Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(    	last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lv_nwk_job_op_seq_num(k),
               lv_nwk_op_seq_num(k),
               lv_unres_res_seq_num(l),
	       lv_unres_res_id(l),
	       lv_unres_schd_seq_num(l),
	       0,
               4,
               4,
               null,
               null,
	       2,
               1,
               sysdate
          From Dual;
          */

	END LOOP;
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

	END;

	-- dsr start
      For k in 1..lv_un_op_cnt  LOOP

	BEGIN

/*	select wori.resource_seq_num,
       	wori.schedule_seq_num,
       	wori.substitute_group_num,
       	wori.replacement_group_num,
       	wori.resource_id
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_sub_grp_num,
       	lv_unres_rep_grp_num,
       	lv_unres_res_id
	From  WIP_OP_RESOURCE_INSTANCES wori
	Where 	wori.operation_seq_num = lv_nwk_job_op_seq_num(k)
	and wori.wip_entity_id = lv_wip_entity_id(n);*/

	select wor.resource_seq_num,
       	wor.schedule_seq_num,
       	wor.substitute_group_num,
       	wor.replacement_group_num,
       	wor.resource_id
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_sub_grp_num,
       	lv_unres_rep_grp_num,
       	lv_unres_res_id
	From  WIP_OPERATION_RESOURCES wor
	Where 	wor.operation_seq_num = lv_nwk_job_op_seq_num(k)
	and wor.wip_entity_id = lv_wip_entity_id(n);

	lv_unres_cnt := SQL%ROWCOUNT;

	IF lv_unres_cnt > 0 Then

	For l in 1..lv_unres_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(    	last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lv_nwk_job_op_seq_num(k),
               lv_nwk_op_seq_num(k),
               lv_unres_res_seq_num(l),
	       lv_unres_res_id(l),
	       lv_unres_schd_seq_num(l),
	       0,
               4,
               RESOURCE_INSTANCES_OSFM,
               null,
               null,
	       1,
               1,
               sysdate
          From Dual;

	END LOOP;
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

	END;
    END LOOP;
	-- dsr end


       BEGIN

	select wcor.resource_seq_num,
       	wcor.schedule_seq_num,
       	wcor.substitute_group_num,
       	wcor.replacement_group_num,
       	wcor.resource_id
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_sub_grp_num,
       	lv_unres_rep_grp_num,
       	lv_unres_res_id
	From  WSM_COPY_OP_RESOURCES wcor
	Where 	wcor.operation_seq_num = lv_nwk_op_seq_num(k)
	and wcor.wip_entity_id = lv_wip_entity_id(n)
	and lv_nwk_job_op_seq_num(k) is null;

	lv_unres_cnt := SQL%ROWCOUNT;

	IF lv_unres_cnt > 0 Then

	For l in 1..lv_unres_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(    	last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               schedule_seq_num,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               null,
               lv_nwk_op_seq_num(k),
               lv_unres_res_seq_num(l),
	       lv_unres_res_id(l),
	       lv_unres_schd_seq_num(l),
	       lv_unres_sub_grp_num(l),
	       0,
               4,
               1,
               null,
               null,
	       1,
               1,
               sysdate
         From Dual;
         /*Bug 3344136
         Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(    	last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               null,
               lv_nwk_op_seq_num(k),
               lv_unres_res_seq_num(l),
	       lv_unres_res_id(l),
	       lv_unres_schd_seq_num(l),
	       0,
               4,
               4,
               null,
               null,
	       2,
               1,
               sysdate
         From Dual;
         */
	END LOOP;
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

      END;

      -- dsr start

	       BEGIN

/*	select wcori.resource_seq_num,
       	wcori.schedule_seq_num,
       	wcori.substitute_group_num,
       	wcori.replacement_group_num,
       	wcori.resource_id
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_sub_grp_num,
       	lv_unres_rep_grp_num,
       	lv_unres_res_id
	From  WSM_COPY_OP_RESOURCE_INSTANCES wcori
	Where 	wcori.operation_seq_num = lv_nwk_op_seq_num(k)
	and wcori.wip_entity_id = lv_wip_entity_id(n)
	and lv_nwk_job_op_seq_num(k) is null;*/

	select wcor.resource_seq_num,
       	wcor.schedule_seq_num,
       	wcor.substitute_group_num,
       	wcor.replacement_group_num,
       	wcor.resource_id
	Bulk Collect into
       	lv_unres_res_seq_num,
       	lv_unres_schd_seq_num,
       	lv_unres_sub_grp_num,
       	lv_unres_rep_grp_num,
       	lv_unres_res_id
	From  WSM_COPY_OP_RESOURCES wcor
	Where 	wcor.operation_seq_num = lv_nwk_op_seq_num(k)
	and wcor.wip_entity_id = lv_wip_entity_id(n)
	and lv_nwk_job_op_seq_num(k) is null;

	lv_unres_cnt := SQL%ROWCOUNT;

	IF lv_unres_cnt > 0 Then

	For l in 1..lv_unres_cnt  LOOP

	Insert INTO WSM_LOT_JOB_DTL_INTERFACE
    	(    	last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               RECORD_ID,
               group_id,
               parent_header_id,
               job_op_seq_num,
               routing_op_seq_num,
               resource_seq_num,
               resource_id_new,
               substitute_group_num,
               replacement_group_num,
               substitution_type,
               load_type,
               start_date,
               completion_date,
               process_phase,
	       process_status,
	       transaction_date)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               null,
               lv_nwk_op_seq_num(k),
               lv_unres_res_seq_num(l),
	       lv_unres_res_id(l),
	       lv_unres_schd_seq_num(l),
	       0,
               4,
               RESOURCE_INSTANCES_OSFM,
               null,
               null,
	       1,
               1,
               sysdate
         From Dual;
	END LOOP;
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

      END;

	-- dsr end

     END LOOP;

    END If;

    END IF;

    END;

    END LOOP;

  EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

END MODIFY_LJ_RES_REQ;


PROCEDURE MODIFY_LJ_COMP_REQ
IS


Cursor C1 is
Select a.header_id,min(bos.operation_seq_num) new_op_seq
from WSM_LOT_JOB_INTERFACE a,
     WSM_LOT_JOB_DTL_INTERFACE b,
     bom_operation_Sequences bos,
     bom_operational_routings bor
where a.group_id = b.group_id
and   a.group_id = G_WIP_GROUP_ID
and   a.header_id = b.parent_header_id
and   a.load_type = 5
and   a.primary_item_id = bor.assembly_item_id
and   nvl(bor.alternate_routing_Designator,0) = nvl(a.alternate_routing_designator,0)
and bor.common_routing_Sequence_id = bos.routing_Sequence_id
and b.load_type = 2
and b.substitution_type = 4
and a.source_code = 'MSC'
and b.routing_op_seq_num = 1
and ( bos.disable_date IS NULL
         OR trunc(bos.disable_date) >= trunc(nvl(a.bom_revision_date,a.first_unit_start_date))
     )
group by a.header_id;


Cursor C2 is
select sum(b.QUANTITY_PER_ASSEMBLY) qty_per_assy,
       sum(b.REQUIRED_QUANTITY)     reqd_qty,
       sum(b.MPS_REQUIRED_QUANTITY) mps_reqd_qty,
       b.group_id,
       b.parent_header_id,
       b.INVENTORY_ITEM_ID_NEW,
       b.ROUTING_OP_SEQ_NUM
 from WSM_LOT_JOB_INTERFACE a,
      WSM_LOT_JOB_DTL_INTERFACE b
 where a.source_code = 'MSC'
   and a.group_id = G_WIP_GROUP_ID
   and a.group_id = b.group_id
   and a.header_id = b.parent_header_id
   and b.load_type = 2
   and b.substitution_type = 4
   and b.process_phase = 1
   and b.process_status = 1
group by b.group_id,
         b.parent_header_id,
         b.INVENTORY_ITEM_ID_NEW,
         b.ROUTING_OP_SEQ_NUM,
         b.COMPONENT_SEQUENCE_ID,
         b.PRIMARY_ITEM_ID,
         b.SRC_PHANTOM_ITEM_ID;

Cursor C3 is
select b.rowid
 from  WSM_LOT_JOB_INTERFACE a,
       WSM_LOT_JOB_DTL_INTERFACE b
 where a.source_code = 'MSC'
   and a.group_id = G_WIP_GROUP_ID
   and a.group_id = b.group_id
   and a.header_id = b.parent_header_id
   and b.load_type = 2
   and b.substitution_type = 4
   and b.process_phase = 1
   and b.process_status = 1
   and b.rowid not in (select min(c.rowid)
                      from WSM_LOT_JOB_DTL_INTERFACE c
                     where b.group_id = c.group_id
                       and b.parent_header_id = c.parent_header_id
                       and b.INVENTORY_ITEM_ID_NEW = c.INVENTORY_ITEM_ID_NEW
                       and b.ROUTING_OP_SEQ_NUM = c.ROUTING_OP_SEQ_NUM
                       and nvl(b.COMPONENT_SEQUENCE_ID,0) = nvl(c.COMPONENT_SEQUENCE_ID,0)
         	       and nvl(b.PRIMARY_ITEM_ID ,0) = nvl(c.PRIMARY_ITEM_ID ,0)
         	       and nvl(b.SRC_PHANTOM_ITEM_ID,0)= nvl(c.SRC_PHANTOM_ITEM_ID,0)
                       and b.load_type = c.load_type
                       and b.substitution_type = c.substitution_type
                       and b.process_phase = c.process_phase
                       and b.process_status = c.process_status );


Begin

For I in C1

loop
   update WSM_LOT_JOB_DTL_INTERFACE
   set routing_op_Seq_num = I.new_op_seq
   where parent_header_id = I.header_id
   and   routing_op_seq_num = 1
   and   group_id = G_WIP_GROUP_ID
   and load_type = 2
   and substitution_type = 4;

End loop;

For J in C2

loop
   update WSM_LOT_JOB_DTL_INTERFACE
   set    QUANTITY_PER_ASSEMBLY = J.qty_per_assy,
          REQUIRED_QUANTITY = J.reqd_qty,
          MPS_REQUIRED_QUANTITY = J.mps_reqd_qty
   where  group_id = J.group_id
   and    parent_header_id = J.parent_header_id
   and    INVENTORY_ITEM_ID_NEW = J.INVENTORY_ITEM_ID_NEW
   and    ROUTING_OP_SEQ_NUM = J.ROUTING_OP_SEQ_NUM
   and    load_type = 2
   and    substitution_type = 4
   and    process_phase = 1
   and    process_status = 1;

End loop;

For K in C3

loop

   delete WSM_LOT_JOB_DTL_INTERFACE
   where  rowid = K.rowid;

End loop;


End MODIFY_LJ_COMP_REQ;


PROCEDURE LD_LOT_JOB_SCHEDULE_INTERFACE
               ( o_request_id    OUT NOCOPY NUMBER)
IS
    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);
    lv_result         BOOLEAN;

    lv_dummy          INTEGER;
BEGIN

     select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
      into lv_dblink,
           lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                    = v_instance_id
      and   instance_code                  = v_instance_code
      and   nvl(a2m_dblink,NULL_DBLINK)    = nvl(v_dblink,NULL_DBLINK)
      and ALLOW_RELEASE_FLAG=1;


lv_sqlstmt:=
       'INSERT INTO WSM_LOT_JOB_INTERFACE'
||'     ( LAST_UPDATE_DATE,'
||'       MODE_FLAG,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       GROUP_ID,'
||'       SOURCE_CODE,'
||'       SOURCE_LINE_ID,'
||'       ORGANIZATION_ID,'
||'       LOAD_TYPE,'
||'       STATUS_TYPE,'
||'       FIRST_UNIT_START_DATE,'
||'       LAST_UNIT_COMPLETION_DATE,'
||'       PROCESSING_WORK_DAYS,'
||'       DAILY_PRODUCTION_RATE,'
||'       LINE_ID,'
||'       PRIMARY_ITEM_ID,'
||'       BOM_REVISION_DATE,'
||'       ROUTING_REVISION_DATE,'
||'       CLASS_CODE,'
||'       JOB_NAME,'
||'       FIRM_PLANNED_FLAG,'
||'       ALTERNATE_ROUTING_DESIGNATOR,'
||'       ALTERNATE_BOM_DESIGNATOR,'
||'       DEMAND_CLASS,'
||'       START_QUANTITY,'
||'       WIP_ENTITY_ID,'
||'       PROCESS_PHASE,'
||'       PROCESS_STATUS,'
||'       SCHEDULE_GROUP_ID,'
||'       BUILD_SEQUENCE,'
||'       PROJECT_ID,'
||'       TASK_ID,'
||'       NET_QUANTITY,'
||'       END_ITEM_UNIT_NUMBER,'
||'       BOM_REFERENCE_ID,'
||'       ROUTING_REFERENCE_ID,'
||'       ALLOW_EXPLOSION,'
||'       SCHEDULING_METHOD,'
||'       HEADER_ID,'
||'       INTERFACE_ID, '
-- dsr added 2 new columns
||'       priority,'
||'       due_date)'
||'     SELECT'
||'       SYSDATE,'
||'       1,'
||'       FND_GLOBAL.USER_ID,'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       DECODE( ORGANIZATION_TYPE,'
              ||' 1,'||TO_CHAR(G_WIP_GROUP_ID)
              ||',2,'||TO_CHAR(G_OPM_WIP_GROUP_ID)||'),'
||'       SOURCE_CODE,'
||'       SOURCE_LINE_ID,'
||'       ORGANIZATION_ID,'
||'       LOAD_TYPE,'
||'       STATUS_TYPE,'
-- dsr ||'       FIRST_UNIT_START_DATE,'
||'       FIRST_UNIT_START_DATE,'
||'       LAST_UNIT_COMPLETION_DATE,'
||'       PROCESSING_WORK_DAYS,'
||'       DAILY_PRODUCTION_RATE,'
||'       LINE_ID,'
-- dsr ||'       PRIMARY_ITEM_ID,'
||'       DECODE(PRIMARY_ITEM_ID, -1001, NULL, PRIMARY_ITEM_ID),'
||'       BOM_REVISION_DATE,'
||'       ROUTING_REVISION_DATE,'
||'       CLASS_CODE,'
||'       JOB_NAME,'
||'       FIRM_PLANNED_FLAG,'
||'       ALTERNATE_ROUTING_DESIGNATOR,'
||'       ALTERNATE_BOM_DESIGNATOR,'
||'       DEMAND_CLASS,'
||'       decode(status_type,7,0,START_QUANTITY),'
||'       TRUNC(WIP_ENTITY_ID/2),'           /* decode wip_entity_id */
||'       PROCESS_PHASE,'
||'       PROCESS_STATUS,'
||'       SCHEDULE_GROUP_ID,'
||'       BUILD_SEQUENCE,'
||'       PROJECT_ID,'
||'       TASK_ID,'
||'       decode(status_type,7,0,NET_QUANTITY),'
||'       END_ITEM_UNIT_NUMBER,'
||'    DECODE( ORGANIZATION_TYPE,'
           ||' 2,TRUNC(BOM_REFERENCE_ID/2),'  /* decode bill_sequence_id */
           ||' BOM_REFERENCE_ID),'             /* for OPM only */
||'    DECODE( ORGANIZATION_TYPE,'
           ||' 2,TRUNC(ROUTING_REFERENCE_ID/2),' /* decode routing_sequence_id */
           ||' ROUTING_REFERENCE_ID),'            /* for OPM only */
||'       BILL_RTG_EXPLOSION_FLAG,'
||'       decode(:var_lot_job_copy_rout,2,decode(LOAD_TYPE,6,2,3),1),'
||'       WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,'
||'       HEADER_ID, '
-- dsr added 2 new columns
||'       Schedule_priority,'
||'       Requested_completion_date '
||'     FROM MSC_WIP_JOB_SCHEDULE_INTERFACE'||lv_dblink
||'    WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(CFM_ROUTING_FLAG,0) = 3' ;

   EXECUTE IMMEDIATE lv_sqlstmt USING var_lot_job_copy_rout,lv_instance_id,G_WIP_GROUP_ID;

BEGIN

lv_sqlstmt:=
   'INSERT INTO WSM_LOT_JOB_DTL_INTERFACE'
|| '(RECORD_ID, '
|| 'GROUP_ID, '
|| 'PARENT_HEADER_ID, '
|| 'LOAD_TYPE, '
|| 'SUBSTITUTION_TYPE, '
|| 'PROCESS_PHASE, '
|| 'PROCESS_STATUS, '
|| 'JOB_OP_SEQ_NUM, '
|| 'ROUTING_OP_SEQ_NUM, '
|| 'NEXT_ROUTING_OP_SEQ_NUM, '
|| 'RESOURCE_SEQ_NUM, '
|| 'SCHEDULE_SEQ_NUM, '
|| 'RESOURCE_ID_NEW, '
|| 'ASSIGNED_UNITS, '
|| 'START_DATE, '
|| 'COMPLETION_DATE, '
|| 'REPLACEMENT_GROUP_NUM, '
|| 'INVENTORY_ITEM_ID_NEW, '
|| 'PRIMARY_ITEM_ID, '
|| 'SRC_PHANTOM_ITEM_ID, '
|| 'COMPONENT_SEQUENCE_ID, '
|| 'DATE_REQUIRED, '
|| 'REQUIRED_QUANTITY, '
|| 'BASIS_TYPE, '
|| 'QUANTITY_PER_ASSEMBLY, '
|| 'MPS_REQUIRED_QUANTITY, '
|| 'MPS_DATE_REQUIRED, '
|| 'SCHEDULED_QUANTITY,'
|| 'OPERATION_START_DATE, '
|| 'OPERATION_COMPLETION_DATE, '
|| 'TRANSACTION_DATE, '
|| 'LAST_UPDATE_DATE, '
|| 'LAST_UPDATED_BY, '
|| 'CREATION_DATE, '
|| 'CREATED_BY, '
|| 'LAST_UPDATE_LOGIN, '
|| 'REQUEST_ID, '
|| 'PROGRAM_APPLICATION_ID, '
|| 'PROGRAM_ID, '
|| 'PROGRAM_UPDATE_DATE, '
-- dsr added 9 new columns
||'       Serial_number_new,' -- rawasthi changed the column from serial_number to Serial_number_new
||'       Setup_id,'
||'       firm_type,'
||'       Group_Sequence_id,'
||'       Group_Sequence_num,'
||'       Batch_Id,'
||'       instance_id_new,'
-- ||'       Charge_number,'
||'       Max_Assigned_Units,' -- dsr
||' USAGE_RATE_OR_AMOUNT,'
||' SCHEDULED_FLAG ,'
||'       PARENT_RESOURCE_SEQ_NUM) ' -- dsr
|| ' SELECT'
||' WSM_LOT_SM_IFC_HEADER_S.NEXTVAL,'
||  G_WIP_GROUP_ID || ','
||' PARENT_HEADER_ID,'
||' LOAD_TYPE,'
||' SUBSTITUTION_TYPE,'
||' PROCESS_PHASE,'
||' PROCESS_STATUS,'
||' JOB_OP_SEQ_NUM,'
||' OPERATION_SEQ_NUM,'
||' NEXT_ROUTING_OP_SEQ_NUM,'
||' RESOURCE_SEQ_NUM,'
|| 'SCHEDULE_SEQ_NUM, '
||' TRUNC(RESOURCE_ID_NEW/2),'
||' ASSIGNED_UNITS,'
||' START_DATE, '
||' COMPLETION_DATE,'
||' ALTERNATE_NUM,'
||' INVENTORY_ITEM_ID_NEW,'
||' PRIMARY_COMPONENT_ID,'
||' SOURCE_PHANTOM_ID,'
||' COMPONENT_SEQ_ID/2,'
||' DATE_REQUIRED,'
||' REQUIRED_QUANTITY,'
||' BASIS_TYPE,'
||' QUANTITY_PER_ASSEMBLY,'
||' MPS_REQUIRED_QUANTITY,'
||' MPS_DATE_REQUIRED,'
||' SCHEDULED_QUANTITY,'
||' FIRST_UNIT_START_DATE,'
||' LAST_UNIT_COMPLETION_DATE,'
||' SYSDATE,'
||' LAST_UPDATE_DATE,'
||' LAST_UPDATED_BY,'
||' CREATION_DATE,'
||' CREATED_BY,'
||' LAST_UPDATE_LOGIN,'
||' REQUEST_ID,'
||' PROGRAM_APPLICATION_ID,'
||' PROGRAM_ID,'
||' PROGRAM_UPDATE_DATE, '
-- dsr added new columns
||'       Serial_number,'
||'       Setup_id,'
||'       firm_flag,'
||'       Group_Sequence_id,'
||'       Group_Sequence_number,'
||'       Batch_Id,'
||'       trunc(Resource_instance_id/2),'
-- ||'       Charge_number,'
||'       Maximum_Assigned_Units,'
||' USAGE_RATE_OR_AMOUNT,'
||' SCHEDULED_FLAG ,'
||'       PARENT_SEQ_NUM '
||'  FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(CFM_ROUTING_FLAG,0) = 3';


   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

   update WSM_LOT_JOB_DTL_INTERFACE wdi
   set wdi.parent_header_id = (select header_id from wsm_lot_job_interface whi
   				where wdi.parent_header_id = whi.interface_id
   				and wdi.GROUP_ID = whi.GROUP_ID
   				and whi.GROUP_ID = G_WIP_GROUP_ID) ;

  EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;

  END;


MODIFY_LJ_COMP_REQ;
MODIFY_LJ_RES_REQ;


   o_request_id := NULL;

   -- Submit 'OSFM Load' Request --
   BEGIN
      SELECT 1
        INTO lv_dummy
        FROM WSM_LOT_JOB_INTERFACE
       WHERE GROUP_ID= G_WIP_GROUP_ID
         AND ROWNUM=1;

    --set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);

    IF WSMPVERS.get_osfm_release_version >= '110509' then
      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'WSM',      -- application
                                        'WSMPLBJI',   -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE,     -- sub_request
                                        g_wip_group_id); -- group_id
    ELSE
      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'WSM',      -- application
                                        'WSMPLBJI',   -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE);     -- sub_request
    END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;
   END;

END LD_LOT_JOB_SCHEDULE_INTERFACE;



PROCEDURE LD_WIP_JOB_SCHEDULE_INTERFACE
               ( o_request_id    OUT NOCOPY NUMBER)
IS
    lv_sqlstmt        VARCHAR2(4000);
    lv_sqlstmt1        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);

    lv_result         BOOLEAN;

    lv_dummy          INTEGER;

BEGIN

      select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
      into lv_dblink,
           lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                    = v_instance_id
      and   instance_code                  = v_instance_code
      and   nvl(a2m_dblink,NULL_DBLINK)    = nvl(v_dblink,NULL_DBLINK)
      and ALLOW_RELEASE_FLAG=1;

lv_sqlstmt:=
       'INSERT INTO WIP_JOB_SCHEDULE_INTERFACE'
||'     ( LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       GROUP_ID,'
||'       SOURCE_CODE,'
||'       SOURCE_LINE_ID,'
||'       ORGANIZATION_ID,'
||'       LOAD_TYPE,'
||'       STATUS_TYPE,'
||'       FIRST_UNIT_START_DATE,'
||'       LAST_UNIT_COMPLETION_DATE,'
||'       PROCESSING_WORK_DAYS,'
||'       DAILY_PRODUCTION_RATE,'
||'       LINE_ID,'
||'       PRIMARY_ITEM_ID,'
||'       BOM_REVISION_DATE,'
||'       ROUTING_REVISION_DATE,'
||'       CLASS_CODE,'
||'       JOB_NAME,'
||'       FIRM_PLANNED_FLAG,'
||'       ALTERNATE_ROUTING_DESIGNATOR,'
||'       ALTERNATE_BOM_DESIGNATOR,'
||'       DEMAND_CLASS,'
||'       START_QUANTITY,'
||'       WIP_ENTITY_ID,'
||'       PROCESS_PHASE,'
||'       PROCESS_STATUS,'
||'       SCHEDULE_GROUP_ID,'
||'       BUILD_SEQUENCE,'
||'       PROJECT_ID,'
||'       TASK_ID,'
||'       NET_QUANTITY,'
||'       END_ITEM_UNIT_NUMBER,'
||'       BOM_REFERENCE_ID,'
||'       ROUTING_REFERENCE_ID,'
||'       ALLOW_EXPLOSION,'
||'       HEADER_ID,'
||'       priority, ' -- dsr
||'       DUE_DATE)'  ---- Need to check this was already there
||'     SELECT'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       DECODE( ORGANIZATION_TYPE,1,SYSDATE,creation_date), '
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       DECODE( ORGANIZATION_TYPE,'
              ||' 1,'||TO_CHAR(G_WIP_GROUP_ID)
              ||',2,'||TO_CHAR(G_OPM_WIP_GROUP_ID)||'),'
||'       SOURCE_CODE,'
||'       SOURCE_LINE_ID,'
||'       ORGANIZATION_ID,'
||'       LOAD_TYPE,'
||'       STATUS_TYPE,'
||'       FIRST_UNIT_START_DATE,'
||'       LAST_UNIT_COMPLETION_DATE,'
||'       PROCESSING_WORK_DAYS,'
||'       DAILY_PRODUCTION_RATE,'
||'       LINE_ID,'
-- dsr ||'       PRIMARY_ITEM_ID,'
||'       DECODE(PRIMARY_ITEM_ID, -1001, NULL, PRIMARY_ITEM_ID), '
||'       BOM_REVISION_DATE,'
||'       ROUTING_REVISION_DATE,'
||'       CLASS_CODE,'
||'       JOB_NAME,'
||'       FIRM_PLANNED_FLAG,'
||'       ALTERNATE_ROUTING_DESIGNATOR,'
||'       ALTERNATE_BOM_DESIGNATOR,'
||'       DEMAND_CLASS,'
||'       START_QUANTITY,'
||'       TRUNC(WIP_ENTITY_ID/2),'           /* decode wip_entity_id */
||'       PROCESS_PHASE,'
||'       PROCESS_STATUS,'
||'       SCHEDULE_GROUP_ID,'
||'       BUILD_SEQUENCE,'
||'       PROJECT_ID,'
||'       TASK_ID,'
||'       NET_QUANTITY,'
||'       END_ITEM_UNIT_NUMBER,'
||'    DECODE( ORGANIZATION_TYPE,'
           ||' 2,TRUNC(BOM_REFERENCE_ID/2),'  /* decode bill_sequence_id */
           ||' BOM_REFERENCE_ID),'             /* for OPM only */
||'    DECODE( ORGANIZATION_TYPE,'
           ||' 2,TRUNC(ROUTING_REFERENCE_ID/2),' /* decode routing_sequence_id */
           ||' ROUTING_REFERENCE_ID),'            /* for OPM only */
||'       BILL_RTG_EXPLOSION_FLAG,'
||'       HEADER_ID,'
||'       schedule_priority, ' -- dsr
||'       requested_completion_date'  -- need to check in ds code it is requested_completion_date
||'     FROM MSC_WIP_JOB_SCHEDULE_INTERFACE'||lv_dblink
||'    WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||'    AND   load_type <> 21 ' -- dsr: exclude oem:  EAM_RESCHEDULE_WORK_RODER
;

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

lv_sqlstmt:=
   'INSERT INTO WIP_JOB_DTLS_INTERFACE'
||' (  INTERFACE_ID,'
||'    GROUP_ID,'
||'    OPERATION_SEQ_NUM,'
||'    RESOURCE_SEQ_NUM,'
||'    REPLACEMENT_GROUP_NUM,'
||'    RESOURCE_ID_OLD,'
||'    RESOURCE_ID_NEW,'
||'    USAGE_RATE_OR_AMOUNT,'
||'    SCHEDULED_FLAG,'
||'    ASSIGNED_UNITS,'
||'    APPLIED_RESOURCE_UNITS,'
||'    APPLIED_RESOURCE_VALUE,'
||'    UOM_CODE,'
||'    BASIS_TYPE,'
||'    ACTIVITY_ID,'
||'    AUTOCHARGE_TYPE,'
||'    STANDARD_RATE_FLAG,'
||'    START_DATE,'
||'    COMPLETION_DATE,'
||'    INVENTORY_ITEM_ID_OLD,'
||'    INVENTORY_ITEM_ID_NEW,'
||'    QUANTITY_PER_ASSEMBLY,'
||'    COMPONENT_YIELD_FACTOR,'
||'    DEPARTMENT_ID,'
||'    WIP_SUPPLY_TYPE,'
||'    DATE_REQUIRED,'
||'    REQUIRED_QUANTITY,'
||'    QUANTITY_ISSUED,'
||'    SUPPLY_SUBINVENTORY,'
||'    SUPPLY_LOCATOR_ID,'
||'    MRP_NET_FLAG,'
||'    MPS_REQUIRED_QUANTITY,'
||'    MPS_DATE_REQUIRED,'
||'    LOAD_TYPE,'
||'    SUBSTITUTION_TYPE,'
||'    PROCESS_PHASE,'
||'    PROCESS_STATUS,'
||'    REQUEST_ID,'
||'    PROGRAM_APPLICATION_ID,'
||'    PROGRAM_ID,'
||'    PROGRAM_UPDATE_DATE,'
||'    PARENT_HEADER_ID,'
||'    DESCRIPTION,'
||'    STANDARD_OPERATION_ID,'
||'    FIRST_UNIT_START_DATE,'
||'    FIRST_UNIT_COMPLETION_DATE,'
||'    LAST_UNIT_START_DATE,'
||'    LAST_UNIT_COMPLETION_DATE,'
||'    COUNT_POINT_TYPE,'
||'    BACKFLUSH_FLAG,'
||'    MINIMUM_TRANSFER_QUANTITY,'
||'    WIP_ENTITY_ID,'
||'    ORGANIZATION_ID,'
||'    ATTRIBUTE1,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATED_BY,'
||'    CREATION_DATE,'
||'    CREATED_BY,'
||'    LAST_UPDATE_LOGIN '
-- dsr: added following 10 new columns
||'    , Serial_number_new ' -- rawasthi changed the column from serial_number to Serial_number_new
||'    , resource_serial_number ' -- jguo
||'    , setup_id '
||'    , group_sequence_id '
||'    , group_sequence_number '
||'    , batch_id '
||'    , resource_instance_id '
||'    , charge_number '
||'    , maximum_assigned_units '
||'    , parent_seq_num '
||'    , firm_flag '
-- jguo opm ||'    , orig_resource_seq_num ) '
||'    , schedule_seq_num ) '
||' SELECT'
||'    INTERFACE_ID,'
||'    DECODE( ORGANIZATION_TYPE,'
           ||' 1,'||TO_CHAR(G_WIP_GROUP_ID)
           ||',2,'||TO_CHAR(G_OPM_WIP_GROUP_ID)||'),'
||'    OPERATION_SEQ_NUM,'
||'    RESOURCE_SEQ_NUM,'
||'    ALTERNATE_NUM,'
||'    TRUNC(RESOURCE_ID_OLD/2),'  /* decode resource_id */
||'    TRUNC(RESOURCE_ID_NEW/2),'  /* decode resource_id */
||'    USAGE_RATE_OR_AMOUNT,'
||'    SCHEDULED_FLAG,'
||'    ASSIGNED_UNITS,'
||'    APPLIED_RESOURCE_UNITS,'
||'    APPLIED_RESOURCE_VALUE,'
||'    UOM_CODE,'
||'    BASIS_TYPE,'
||'    ACTIVITY_ID,'
||'    AUTOCHARGE_TYPE,'
||'    STANDARD_RATE_FLAG,'
||'    START_DATE,'
||'    COMPLETION_DATE,'
||'    INVENTORY_ITEM_ID_OLD,'
||'    INVENTORY_ITEM_ID_NEW,'
||'    QUANTITY_PER_ASSEMBLY,'
||'    COMPONENT_YIELD_FACTOR,'
||'    TRUNC(DEPARTMENT_ID/2),'     /* decode department_id */
||'    WIP_SUPPLY_TYPE,'
||'    DATE_REQUIRED,'
||'    REQUIRED_QUANTITY,'
||'    QUANTITY_ISSUED,'
||'    SUPPLY_SUBINVENTORY,'
||'    SUPPLY_LOCATOR_ID,'
||'    MRP_NET_FLAG,'
||'    MPS_REQUIRED_QUANTITY,'
||'    MPS_DATE_REQUIRED,'
||'    LOAD_TYPE,'
||'    SUBSTITUTION_TYPE,'
||'    PROCESS_PHASE,'
||'    PROCESS_STATUS,'
||'    REQUEST_ID,'
||'    PROGRAM_APPLICATION_ID,'
||'    PROGRAM_ID,'
||'    PROGRAM_UPDATE_DATE,'
||'    PARENT_HEADER_ID,'
||'    DESCRIPTION,'
||'    STANDARD_OPERATION_ID,'
||'    FIRST_UNIT_START_DATE,'
||'    FIRST_UNIT_COMPLETION_DATE,'
||'    LAST_UNIT_START_DATE,'
||'    LAST_UNIT_COMPLETION_DATE,'
||'    COUNT_POINT_TYPE,'
||'    BACKFLUSH_FLAG,'
||'    MINIMUM_TRANSFER_QUANTITY,'
||'    TRUNC(WIP_ENTITY_ID/2),'       /* decode wip_entity_id */
||'    ORGANIZATION_ID,'
||'    decode(organization_type,2,fnd_number.number_to_canonical(resource_hours),resource_hours),'
||'    SYSDATE,'
||'    FND_GLOBAL.USER_ID,'
||'    SYSDATE,'
||'    FND_GLOBAL.USER_ID,'
||'    LAST_UPDATE_LOGIN '
-- dsr: added following 10 new columns
||'    , serial_number '
||'    , serial_number ' -- jguo
||'    , setup_id '
||'    , group_sequence_id '
||'    , group_sequence_number '
||'    , batch_id '
||'    ,TRUNC(resource_instance_id/2) '-- changed by abhikuma
||'    , charge_number '
||'    , maximum_assigned_units '
||'    , parent_seq_num '
||'    , firm_flag '
||'    , schedule_seq_num '
||'  FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||' AND GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(operation_seq_num,-1) <> -1'
||'    AND   nvl(eam_flag, -1) <> 1 '
;

--Commented out to support OPM integration
--||'    AND   ORGANIZATION_TYPE = 1 ';

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

   o_request_id := NULL;

   -- Submit 'WIP Mass Load' Request --
   BEGIN
      SELECT 1
        INTO lv_dummy
        FROM WIP_JOB_SCHEDULE_INTERFACE
       WHERE GROUP_ID= G_WIP_GROUP_ID
         AND ROWNUM=1;

      MODIFY_COMPONENT_REQUIREMENT;

      MODIFY_RESOURCE_REQUIREMENT;

    --set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);


      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'WIP',      -- application
                                        'WICMLP',   -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE,      -- sub_request
                                        g_wip_group_id, -- group_id
				        1,          -- validation_level
					1);         -- print report


   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;
   END;

   -- Submit 'OPM's WIP Mass Load' Request --
   BEGIN
      SELECT 1
        INTO lv_dummy
        FROM WIP_JOB_SCHEDULE_INTERFACE
       WHERE GROUP_ID= G_OPM_WIP_GROUP_ID
         AND ROWNUM=1;

      SET_OPM_SCHEDULING_METHOD;

   -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);

      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'GMP',      -- application
                                        'GMPAPSFD', -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE,      -- sub_request
                                        G_OPM_WIP_GROUP_ID); -- group_id


   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;
   END;

   -- Submit 'EAM req for CMRO ' Request --
   BEGIN

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '1 dblink is '|| lv_dblink);
      lv_sqlstmt :=  'SELECT 1 '
                  ||' FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
                  ||' WHERE SR_INSTANCE_ID= :lv_instance_id'
                  ||' AND GROUP_ID = (:G_WIP_GROUP_ID *-1)'
                  ||' AND ROWNUM = 1 ';

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' lv_sqlstmt is '|| lv_sqlstmt);

      EXECUTE IMMEDIATE lv_sqlstmt into lv_dummy USING lv_instance_id,G_WIP_GROUP_ID;


   -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'dblink is '|| lv_dblink);
         o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'MSC',      -- application
                                        'MRPPSRELB', -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE,      -- sub_request
                                        lv_dblink, --dblink
                                        G_WIP_GROUP_ID * -1,  --group_id
                                        lv_instance_id );


   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;
   END;
END LD_WIP_JOB_SCHEDULE_INTERFACE;


PROCEDURE LD_PO_REQUISITIONS_INTERFACE
               ( p_po_group_by_name    IN  VARCHAR2,
                 o_request_id          OUT NOCOPY NUMBER)
IS

   -- added for 2541517
    TYPE CharTab  IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
    TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
    TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


    lv_req_count        NUMBER;
    lv_pri_rowid        RIDTab;
    lv_sec_uom_code     CharTab;
    lv_sec_uom_qty      NumTab;

    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);

    lv_result         BOOLEAN;

    lv_accrual_acct_id NUMBER;
    lv_charge_acct_id NUMBER;

    var_revision        VARCHAR2(3);
    var_revision_ctrl   NUMBER;

Cursor c1 is select pvsa.vendor_site_id,pri.rowid,pri.item_id, pri.destination_organization_id,pri.charge_account_id,pri.project_id
from po_vendor_sites_all pvsa, po_Requisitions_interface_All pri
where pri.suggested_vendor_id = pvsa.vendor_id(+)
and   pri.suggested_vendor_site = pvsa.vendor_site_code(+)
and   nvl(pri.org_id,-99) = nvl(pvsa.org_id(+),-99)
and   pri.interface_source_code = 'MSC'
and   pri.batch_id = G_PO_BATCH_NUMBER;

    CURSOR c1_rec is
        SELECT  item_id,
                destination_organization_id,
                rowid
        from    PO_REQUISITIONS_INTERFACE_ALL
	where   batch_id = G_PO_BATCH_NUMBER;


BEGIN

     select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
      into lv_dblink,
           lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                   = v_instance_id
      and   instance_code                 = v_instance_code
      and   nvl(a2m_dblink,NULL_DBLINK)    = nvl(v_dblink,NULL_DBLINK)
      and ALLOW_RELEASE_FLAG=1;

lv_sqlstmt:=
      'INSERT INTO PO_REQUISITIONS_INTERFACE_ALL'
||'    ( PROJECT_ACCOUNTING_CONTEXT,'
||'      PROJECT_ID,'
||'      TASK_ID,'
||'      NEED_BY_DATE,'
||'      ITEM_ID,'
||'      ITEM_REVISION,'
||'      CHARGE_ACCOUNT_ID,'
||'      AUTHORIZATION_STATUS,'
||'      BATCH_ID,'
||'      GROUP_CODE,'
||'      PREPARER_ID,'
||'      AUTOSOURCE_FLAG,'
||'      SOURCE_ORGANIZATION_ID,'
||'      DESTINATION_ORGANIZATION_ID,'
||'      DELIVER_TO_LOCATION_ID,'
||'      DELIVER_TO_REQUESTOR_ID,'
||'      SUGGESTED_VENDOR_ID,'
||'      SUGGESTED_VENDOR_SITE,'
||'      LAST_UPDATED_BY,'
||'      LAST_UPDATE_DATE,'
||'      LAST_UPDATE_LOGIN,'
||'      CREATION_DATE,'
||'      CREATED_BY,'
||'      INTERFACE_SOURCE_CODE,'
||'      SOURCE_TYPE_CODE,'
||'      DESTINATION_TYPE_CODE,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      LINE_TYPE_ID,'
||'      ORG_ID,'
||'      VMI_FLAG,'
||'      END_ITEM_UNIT_NUMBER )'
||'   SELECT'
||'      PROJECT_ACCOUNTING_CONTEXT,'
||'      PROJECT_ID,'
||'      TASK_ID,'
||'      NEED_BY_DATE,'
||'      ITEM_ID,'
||'      ITEM_REVISION,'
||'      CHARGE_ACCOUNT_ID,'
||'      AUTHORIZATION_STATUS,'
||       TO_CHAR(G_PO_BATCH_NUMBER)||','
||'      GROUP_CODE,'
||'      PREPARER_ID,'
||'      AUTOSOURCE_FLAG,'
||'      SOURCE_ORGANIZATION_ID,'
||'      DESTINATION_ORGANIZATION_ID,'
||'      DELIVER_TO_LOCATION_ID,'
||'      DELIVER_TO_REQUESTOR_ID,'
||'      SUGGESTED_VENDOR_ID,'
||'      SUGGESTED_VENDOR_SITE,'
||'      FND_GLOBAL.USER_ID,'
||'      SYSDATE,'
||'      LAST_UPDATE_LOGIN,'
||'      SYSDATE,'
||'      FND_GLOBAL.USER_ID,'
||'      INTERFACE_SOURCE_CODE,'
||'      SOURCE_TYPE_CODE,'
||'      DESTINATION_TYPE_CODE,'
||'      QUANTITY,'
||'      UOM_CODE,'
||'      LINE_TYPE_ID,'
||'      ORG_ID,'
||'      DECODE(VMI_FLAG,1,''Y'',''N''), '
||'      END_ITEM_UNIT_NUMBER'
||'    FROM MSC_PO_REQUISITIONS_INTERFACE'||lv_dblink
||'   WHERE SR_INSTANCE_ID= :lv_instance_id'
||'   AND   BATCH_ID = :G_PO_BATCH_NUMBER';

   EXECUTE IMMEDIATE lv_sqlstmt
               USING lv_instance_id,G_PO_BATCH_NUMBER;



  For i in c1
     Loop
BEGIN
/*  --Added for the bug#3319306
  IF i.vendor_site_id IS NOT NULL THEN
     update po_requisitions_interface_all
     set suggested_vendor_site_id = i.vendor_site_id
     where rowid = i.rowid;
  END IF;
  Removed --- bug 8256097*/

If nvl(i.charge_account_id,-1) = -1 Then

          GMP_UTILITY.generate_opm_acct('INVENTORY',
                                              'ASSET',
                                              'ASSET',
                                              i.destination_organization_id,
                                              i.item_id,
                                              i.vendor_site_id,
                                              lv_charge_acct_id
                                             );
          If NVL(lv_charge_acct_id,0) > 0 Then
               Update po_requisitions_interface_all
               set charge_account_id = lv_charge_acct_id
               where rowid = i.rowid;
          Else
               Update po_requisitions_interface_all
               set charge_account_id =
                (Select nvl(mapv.material_account,
                            decode( msi.inventory_asset_flag,
                                    'Y', mp.material_account,
                                nvl(msi.expense_account, mp.expense_account)))
                 from mtl_system_items msi,
                 mtl_parameters mp,
/* Bug 3341083 Note: Any changes to from clause or where clause of MRP_AP_PROJECTS_V, needs a corresponding change to this inline view*/
                 (SELECT ppp.Project_ID,
       			ppp.Organization_ID,
       			ccga.Material_Account
  			FROM CST_COST_GROUP_ACCOUNTS ccga,
       				PA_PROJECT_PLAYERS ppl,
       				PA_PROJECTS_ALL ppa,
       				PJM_PROJECT_PARAMETERS ppp
 			WHERE ppa.Project_ID= ppp.Project_ID
   			AND ccga.Cost_Group_ID(+)= ppp.Costing_Group_ID
   			AND ccga.Organization_ID(+)= ppp.Organization_ID
   			AND ppl.project_role_type(+)= 'PROJECT MANAGER'
   			AND ppl.project_id(+)= ppa.project_id
			UNION ALL
			SELECT ppp.Project_ID,
       			ppp.Organization_ID,
       			ccga.Material_Account
  			FROM CST_COST_GROUP_ACCOUNTS ccga,
       				PJM_SEIBAN_NUMBERS psn,
       				PJM_PROJECT_PARAMETERS ppp
 			WHERE psn.Project_ID= ppp.Project_ID
   			AND ccga.Cost_Group_ID(+)= ppp.Costing_Group_ID
   			AND ccga.Organization_ID(+)= ppp.Organization_ID) mapv
                 where msi.inventory_item_id = i.item_id
                 and   msi.organization_id = i.destination_organization_id
                 and   mp.organization_id = msi.organization_id
                 and   mapv.organization_id(+) = msi.organization_id
                 and   mapv.project_id(+) = nvl(i.project_id,-23453))
                 where rowid = i.rowid;  --9192631
          End if;

          GMP_UTILITY.generate_opm_acct('ACCRUAL',
                                              'ASSET',
                                              'ASSET',
                                              i.destination_organization_id,
                                              i.item_id,
                                              i.vendor_site_id,
                                              lv_accrual_acct_id
                                             );
          If NVL(lv_accrual_acct_id,0) > 0 Then
               Update po_requisitions_interface_all
               set accrual_account_id = lv_accrual_acct_id
               where rowid = i.rowid;
          Else
               Null;
          End if;

     End if;  /* Charge acct id = -1 */

EXCEPTION
      WHEN OTHERS THEN RAISE;
END;

  End loop;

   -- fix for 2541517
  -- Populating SECONDARY_UOM_CODE and SECONDARY_QUANTITY in PO_REQUISITIONS_INTERFACE_ALL from MTL_SYSTEM_ITEMS
  BEGIN
   SELECT pri.rowid,
          msi.SECONDARY_UOM_CODE,
          inv_convert.inv_um_convert(pri.ITEM_ID,9,pri.QUANTITY,pri.UOM_CODE,msi.SECONDARY_UOM_CODE,null,null)
     BULK COLLECT
     INTO lv_pri_rowid,
          lv_sec_uom_code,
          lv_sec_uom_qty
     FROM PO_REQUISITIONS_INTERFACE_ALL pri,
          MTL_SYSTEM_ITEMS msi
     WHERE pri.ITEM_ID = msi.INVENTORY_ITEM_ID
       AND pri.DESTINATION_ORGANIZATION_ID = msi.ORGANIZATION_ID
       AND msi.SECONDARY_UOM_CODE is not NULL
       AND pri.batch_id = G_PO_BATCH_NUMBER;

       lv_req_count:= SQL%ROWCOUNT;

   EXCEPTION
      WHEN OTHERS THEN RAISE;
  END;

   IF lv_req_count <> 0 THEN

      FOR j IN 1..lv_req_count LOOP

       UPDATE PO_REQUISITIONS_INTERFACE_ALL pri
       SET  pri.SECONDARY_UOM_CODE = lv_sec_uom_code(j),
            pri.SECONDARY_QUANTITY = lv_sec_uom_qty(j)
       WHERE ROWID= lv_pri_rowid(j);

      END LOOP;
   END IF;

FOR ctemp in c1_rec LOOP

       BEGIN
             SELECT max(rev.revision),
                    max(msi.revision_qty_control_code)
             INTO   var_revision,var_revision_ctrl
             FROM   mtl_system_items_b msi,
                    mtl_item_revisions rev
             WHERE  msi.inventory_item_id = ctemp.item_id
             AND    msi.organization_id = ctemp.destination_organization_id
             AND    rev.inventory_item_id = msi.inventory_item_id
             AND    rev.organization_id = msi.organization_id
	     AND    TRUNC(rev.effectivity_date) =
                            (SELECT TRUNC(max(rev2.effectivity_date))
                             FROM   mtl_item_revisions rev2
                            WHERE   rev2.implementation_date IS NOT NULL
                            AND     rev2.effectivity_date <= TRUNC(SYSDATE)+.99999
                            AND     rev2.organization_id = rev.organization_id
                            AND     rev2.inventory_item_id = rev.inventory_item_id);

      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	      var_revision_ctrl := NOT_UNDER_REV_CONTROL;
	 WHEN OTHERS THEN
	      RAISE;
      END;

     BEGIN
       UPDATE PO_REQUISITIONS_INTERFACE_ALL
       set    item_revision = DECODE(var_purchasing_by_rev, NULL,
                              DECODE(var_revision_ctrl, NOT_UNDER_REV_CONTROL, NULL, var_revision),
                                     PURCHASING_BY_REV, var_revision,
                                     NOT_PURCHASING_BY_REV, NULL)
       WHERE ROWID = ctemp.rowid;

     EXCEPTION
             WHEN OTHERS THEN
	        RAISE;
     END;

   END LOOP;

   -- Launching the REQIMPORT in loop for each OU, change for MOAC
   DECLARE
     CURSOR c1 IS
     	SELECT DISTINCT org_id
     	FROM PO_REQUISITIONS_INTERFACE_ALL
     	WHERE batch_id = G_PO_BATCH_NUMBER;

   BEGIN
   FOR C2 IN C1
   LOOP

      /*MO_GLOBAL.INIT ('PO'); Bug 8397994 */
      FND_REQUEST.SET_ORG_ID (c2.org_id);
      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);

      o_request_id := NULL;
      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'PO',       -- application
                      'REQIMPORT',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      'MSC',
                      G_PO_BATCH_NUMBER,
                      p_po_group_by_name,
                      0);
   END LOOP;
   END;

END LD_PO_REQUISITIONS_INTERFACE;

PROCEDURE LD_PO_RESCHEDULE_INTERFACE
               ( o_request_id        OUT NOCOPY NUMBER)
IS
    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);

    lv_result         BOOLEAN;

BEGIN

      select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
      into lv_dblink,
           lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                   = v_instance_id
      and   instance_code                 = v_instance_code
      and   nvl(a2m_dblink,NULL_DBLINK)    = nvl(v_dblink,NULL_DBLINK)
      and ALLOW_RELEASE_FLAG=1;

lv_sqlstmt:=
      'INSERT INTO PO_RESCHEDULE_INTERFACE'
||'    ( LINE_ID,'
||'      QUANTITY,'
||'      NEED_BY_DATE,'
||'      PROCESS_ID,'
||'      LAST_UPDATE_DATE,'
||'      LAST_UPDATED_BY,'
||'      CREATION_DATE,'
||'      CREATED_BY,'
||'      LAST_UPDATE_LOGIN,'
||'      REQUEST_ID,'
||'      PROGRAM_APPLICATION_ID,'
||'      PROGRAM_ID,'
||'      PROGRAM_UPDATE_DATE )'
||'    SELECT'
||'      LINE_ID,'
||'      QUANTITY,'
||'      NEED_BY_DATE,'
||'      NULL,'
||'      SYSDATE,'
||'      FND_GLOBAL.USER_ID,'
||'      SYSDATE,'
||'      FND_GLOBAL.USER_ID,'
||'      LAST_UPDATE_LOGIN,'
||'      REQUEST_ID,'
||'      PROGRAM_APPLICATION_ID,'
||'      PROGRAM_ID,'
||'      PROGRAM_UPDATE_DATE'
||'    FROM MSC_PO_RESCHEDULE_INTERFACE'||lv_dblink
||'   WHERE SR_INSTANCE_ID= :lv_instance_id';

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id;

   -- Launching the POXRSR in loop for each OU, change for MOAC
   DECLARE
     CURSOR c1 IS
     	SELECT DISTINCT prla.org_id
     	FROM PO_RESCHEDULE_INTERFACE PRI, PO_REQUISITION_LINES_ALL PRLA
     	WHERE pri.line_id = prla.requisition_line_id;

   BEGIN
   FOR C2 IN C1
   LOOP

      /*MO_GLOBAL.INIT ('PO');  Bug 8397994 */
      FND_REQUEST.SET_ORG_ID (c2.org_id);
      -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);

      o_request_id := NULL;
      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                       'PO',       -- application
                                       'POXRSR',   -- program
                                       NULL,       -- description
                                       NULL,       -- start_time
                                       FALSE);      -- sub_request
   END LOOP;
   END;

END LD_PO_RESCHEDULE_INTERFACE;


PROCEDURE MODIFY_COMPONENT_REQUIREMENT
IS


Cursor C1 is
Select a.header_id,min(bos.operation_seq_num) new_op_seq
from wip_job_schedule_interface a,
     wip_job_dtls_interface b,
     bom_operation_Sequences bos,
     bom_operational_routings bor
where a.group_id = b.group_id
and   a.header_id = b.parent_header_id --added for the bug#3538800
and   a.group_id = G_WIP_GROUP_ID
and   a.primary_item_id = bor.assembly_item_id
and   a.organization_id = bor.organization_id
and   nvl(bor.alternate_routing_Designator,0) = nvl(a.alternate_routing_designator,0)
and bor.common_routing_Sequence_id = bos.routing_Sequence_id
and b.load_type = 2
and b.substitution_type = 3
and a.source_code = 'MSC'
and b.operation_seq_num = 1
and ( bos.disable_date IS NULL
         OR trunc(bos.disable_date) >= trunc(nvl(a.bom_revision_date,a.first_unit_start_date))
     )
group by a.header_id;

Cursor C2 is
select sum(round(b.QUANTITY_PER_ASSEMBLY*NVL(b.COMPONENT_YIELD_FACTOR,1),6)) qty_per_assy,
       sum(b.REQUIRED_QUANTITY)     reqd_qty,
       b.group_id,
       b.parent_header_id,
       b.INVENTORY_ITEM_ID_OLD,
       b.ORGANIZATION_ID,
       b.OPERATION_SEQ_NUM
 from wip_job_schedule_interface a,
      wip_job_dtls_interface b
 where a.source_code = 'MSC'
   and a.group_id = G_WIP_GROUP_ID
   and a.group_id = b.group_id
   and a.header_id = b.parent_header_id
   and b.load_type = 2
   and b.substitution_type = 3
   and b.process_phase = 2
   and b.process_status = 1
group by b.group_id,
         b.parent_header_id,
         b.ORGANIZATION_ID,
         b.INVENTORY_ITEM_ID_OLD,
         b.OPERATION_SEQ_NUM;

Cursor C3 is
select b.rowid
 from  wip_job_schedule_interface a,
       wip_job_dtls_interface b
 where a.source_code = 'MSC'
   and a.group_id = G_WIP_GROUP_ID
   and a.group_id = b.group_id
   and a.header_id = b.parent_header_id
   and b.load_type = 2
   and b.substitution_type = 3
   and b.process_phase = 2
   and b.process_status = 1
   and b.rowid not in (select min(c.rowid)
                      from wip_job_dtls_interface c
                     where b.group_id = c.group_id
                       and b.parent_header_id = c.parent_header_id
                       and b.ORGANIZATION_ID = c.ORGANIZATION_ID
                       and b.INVENTORY_ITEM_ID_OLD = c.INVENTORY_ITEM_ID_OLD
                       and b.OPERATION_SEQ_NUM = c.OPERATION_SEQ_NUM
                       and b.load_type = c.load_type
                       and b.substitution_type = c.substitution_type
                       and b.process_phase = c.process_phase
                       and b.process_status = c.process_status );

Begin

For I in C1

loop
   update wip_job_dtls_interface
   set operation_Seq_num = I.new_op_seq
   where parent_header_id = I.header_id
   and   operation_seq_num = 1
   and load_type = 2
   and substitution_type = 3;

End loop;

For J in C2

loop
   update wip_job_dtls_interface
   set    QUANTITY_PER_ASSEMBLY = J.qty_per_assy,
          REQUIRED_QUANTITY = J.reqd_qty
   where  group_id = J.group_id
   and    parent_header_id = J.parent_header_id
   and    ORGANIZATION_ID = J.ORGANIZATION_ID
   and    INVENTORY_ITEM_ID_OLD = J.INVENTORY_ITEM_ID_OLD
   and    OPERATION_SEQ_NUM = J.OPERATION_SEQ_NUM
   and    load_type = 2
   and    substitution_type = 3
   and    process_phase = 2
   and    process_status = 1;

End loop;

For K in C3

loop

   delete wip_job_dtls_interface
   where  rowid = K.rowid;

End loop;

End MODIFY_COMPONENT_REQUIREMENT;


PROCEDURE MODIFY_RESOURCE_REQUIREMENT
IS

/* dsr jsi.primary_item_id and jsi.organization_id can be null */
/* dsr: added outer join in the following cursor*/
    cursor cres_upd is select jdi.rowid,jdi.operation_seq_num,
                              jdi.parent_header_id,rtng.common_routing_Sequence_id
     FROM BOM_OPERATIONAL_ROUTINGS rtng,
          wip_job_dtls_interface jdi,
          wip_job_schedule_interface jsi
      where rtng.assembly_item_id (+) = jsi.primary_item_id -- dsr
      and   jsi.group_id = G_WIP_GROUP_ID
      AND rtng.organization_id (+) = jsi.organization_id -- dsr
      AND NVL(rtng.alternate_routing_designator,' ')=
              NVL( jsi.alternate_routing_designator,' ')
    and  jsi.header_id = jdi.parent_header_id
    and nvl(jdi.resource_seq_num,-1) = -1000
    and jdi.load_type = 1
    order by jdi.parent_header_id,jdi.operation_Seq_num;

    v_old_op number;
    v_old_res number;
    v_old_header number;

    TYPE NumTab  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE RIDTab  IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
    TYPE DateTab IS TABLE OF DATE   INDEX BY BINARY_INTEGER;

    v_max_resource_Seq number;

    lv_std_job_count    NUMBER;
    lv_jsi_rowid        RIDTab;
    lv_header_id        NumTab;
    lv_routing_seq_id   NumTab;
    lv_organization_id  NumTab;
    lv_start_date       DateTab;
    lv_end_Date         DateTab;

    lv_res_req_count    NUMBER;
    lv_jdi_rowid        RIDTab;
    lv_op_seq_num       NumTab;
    lv_sim_res_seq      NumTab;
    lv_res_priority     NumTab;
    lv_resource_id      NumTab;
    lv_resource_id_old  NumTab;
    lv_res_seq          NumTab;
    lv_sub_type         NumTab;
    lv_res_id_old       NumTab;
    lv_ld_type          NumTab;

    lu_res_req_count    NUMBER;
    lu_op_seq_num       NumTab;
    lu_sim_res_seq      NumTab;
    lu_res_priority     NumTab;
    lu_res_seq          NumTab;
    lu_resource_id      NumTab;
    lu_res_required     NumTab;
    lu_schedule_seq_num NumTab;


    lun_res_req_count    NUMBER;
    lun_usage NumTab;
    lun_op_seq_num       NumTab;
    lun_sim_res_seq      NumTab;
    lun_res_priority     NumTab;
    lun_res_seq          NumTab;
    lun_resource_id      NumTab;
    lun_basis_type       NumTab;
    lun_res_required     NumTab;


    elsud_op_seq_num NumTab;
    elsud_sim_res_seq NumTab;
    elsud_res_seq NumTab;
    elsud_jdi_rowid RIDTab;
    elsud_sub_grp NumTab;
    elsud_rep_grp NumTab;

    lv_elsud_cnt NUMBER;

   v_previous_op number;
   v_previous_res number;
   v_previous_res1 number;
   v_next_op number;
   v_next_res number;
   v_next_res1 number;
   v_last_end date;
   v_frst_end date;
   v_last_start date;
   v_frst_start date;

   luno_op_count number;
   luno_op_seq_num NumTab;
   luno_std_op_seq_id NumTab;



   lv_res_alt_op_seq_num NumTab;
   lv_res_alt_schd_seq_num NumTab;
   lv_res_alt_prin_flag NumTab;
   lv_res_alt_res_seq_num NumTab;
   lv_res_alt_res_id NumTab;
   lv_res_alt_hdr_id NumTab;
   lv_res_alt_org_id NumTab;
   lv_res_alt_rowid RIDTab;
   lv_res_alt_sub_grp_num NumTab;
   lv_res_alt_rep_grp_num NumTab;
   lv_res_alt_start_date DateTab;
   lv_res_alt_completion_date DateTab;
   lv_res_alt_usage_rate NumTab;
   lv_res_alt_basis_type NumTab;
   lv_res_alt_req_count Number;



              lsud_header_id NumTab;
              lsud_sub_grp NumTab;
              lsud_new_usage NumTab;
              lsud_rep_grp NumTab;
              lsud_organization_id Numtab;
              lsud_op_seq_num   NumTab;
              lsud_sim_res_seq   NumTab;
              lsud_res_priority   NumTab;
              lsud_res_seq   NumTab;
              lsud_resource_id   NumTab;
              lsud_jdi_rowid        RIDTab;
              lsud_resource_id_del   NumTab;
              lsud_basis_type        NumTab;
               lsud_res_req_count   Number;
               lsud_row               NumTab;
               lsud_start_date       DateTab;
               lsud_completion_Date  DateTab;

               -- dsr added following 7 lines
     lsud_firm_flag NumTab;
     lsud_setup_id NumTab;
     lsud_group_sequence_id NumTab;
     lsud_group_sequence_number NumTab;
     lsud_batch_id NumTab;
     lsud_maximum_assigned_units NumTab;
     lsud_parent_seq_num NumTab;


    lv_init_k           NUMBER;
     temp_res_id        NUMBER;
    lv_scheduled_flag NumTab;
    lv_parent_id NumTab;
    lv_job_schedule_type NumTab;
    lv_wip_entity_id NumTab;

BEGIN


   SELECT jsi.rowid,
          jsi.header_id,
          jsi.organization_id,
          jsi.first_unit_start_date,
          jsi.last_unit_completion_date,
          rtng.common_routing_sequence_id,
          jsi.load_type,
          jsi.wip_entity_id
     BULK COLLECT
     INTO lv_jsi_rowid,
          lv_header_id,
          lv_organization_id,
          lv_start_date,
          lv_end_date,
          lv_routing_seq_id,
          lv_job_schedule_type,
          lv_wip_entity_id
     FROM BOM_OPERATIONAL_ROUTINGS rtng,
          wip_job_schedule_interface jsi
    WHERE jsi.group_id = G_WIP_GROUP_ID
      AND jsi.load_type in(1,3)  /* create standard job */
      AND rtng.assembly_item_id(+)= jsi.primary_item_id
      AND rtng.organization_id(+)= jsi.organization_id
      AND NVL(rtng.alternate_routing_designator(+),' ')=
              NVL( jsi.alternate_routing_designator,' ');

    lv_std_job_count:= SQL%ROWCOUNT;

    IF lv_std_job_count= 0 THEN RETURN; END IF;

    FOR n IN 1..lv_std_job_count LOOP

       BEGIN
          SELECT jdi.ROWID,
                 jdi.operation_seq_num,
                 -- jdi.resource_seq_num,
                 nvl(jdi.schedule_seq_num, jdi.resource_seq_num),
                 TO_NUMBER(nvl(jdi.REPLACEMENT_GROUP_NUM,0)),
                 jdi.resource_id_old,
                 jdi.resource_seq_num,
                 jdi.substitution_type,
                 jdi.resource_id_old,
                 jdi.load_type,
                 jdi.scheduled_flag,
                 jdi.parent_header_id
            BULK COLLECT
            INTO lv_jdi_rowid,
                 lv_op_seq_num,
                 lv_sim_res_seq,
                 lv_res_priority,
                 lv_resource_id,
                 lv_res_seq,
                 lv_sub_type,
                 lv_resource_id_old,
                 lv_ld_type,
                 lv_scheduled_flag,
                 lv_parent_id
            FROM WIP_JOB_DTLS_INTERFACE jdi
           WHERE jdi.group_id= G_WIP_GROUP_ID
             AND jdi.parent_header_id= lv_header_id(n)
              -- dsr AND jdi.load_type=LT_RESOURCE
             AND jdi.load_type IN (LT_RESOURCE, LT_RESOURCE_USAGE
			 , RESOURCE_INSTANCES, RESOURCE_INSTANCE_USAGE
			 )
           ORDER BY
                 2,3,5;

          lv_res_req_count:= SQL%ROWCOUNT;

       EXCEPTION
          WHEN OTHERS THEN RAISE;
       END;

       IF nvl(lv_res_req_count,0) = 0 THEN

          UPDATE wip_job_schedule_interface
             SET first_unit_start_date=NULL,
                 scheduling_method= WIP_CONSTANTS.ROUTING
           WHERE ROWID= lv_jsi_rowid(n);

          GOTO next_c_std_job;
       ELSE


          UPDATE wip_job_schedule_interface
                 set scheduling_method= WIP_CONSTANTS.ML_MANUAL
           WHERE ROWID= lv_jsi_rowid(n);

      END IF;

      If nvl(lv_job_schedule_type(n),1) = 1 Then

       SELECT os.operation_seq_num,
              to_number(decode(nvl(bor.schedule_seq_num,-1),-1,bor.resource_seq_num,bor.schedule_seq_num)),
              0,
              bor.resource_seq_num,
              bor.schedule_seq_num,
              bor.resource_id,
              2
         BULK COLLECT
         INTO lu_op_seq_num,
              lu_sim_res_seq,
              lu_res_priority,
              lu_res_seq,
              lu_schedule_seq_num,
              lu_resource_id,
              lu_res_required
         FROM BOM_OPERATION_RESOURCES bor,
              BOM_OPERATION_SEQUENCES os
        WHERE os.routing_sequence_id= lv_routing_seq_id(n)
          AND bor.operation_sequence_id= os.operation_sequence_id
          AND os.effectivity_date <= lv_start_date(n)
          AND NVL(os.disable_date, lv_start_date(n)) >= lv_start_date(n)
       ORDER BY
             1,2,3 ASC,5;



       lu_res_req_count:= SQL%ROWCOUNT;


    BEGIN

       SELECT os.operation_seq_num,os.standard_operation_id
         BULK COLLECT
         INTO luno_op_seq_num,luno_std_op_Seq_id
         FROM BOM_OPERATION_SEQUENCES os
        WHERE os.routing_sequence_id= lv_routing_seq_id(n)
          AND os.effectivity_date <= lv_start_date(n)
          AND NVL(os.disable_date, lv_start_date(n)) >= lv_start_date(n)
          AND not exists(select jdi.operation_seq_num
                        FROM BOM_OPERATIONAL_ROUTINGS rtng,
                             BOM_OPERATION_SEQUEnCES seqs,
                             wip_job_dtls_interface jdi,
                             wip_job_schedule_interface jsi
      where rtng.assembly_item_id= jsi.primary_item_id
      AND rtng.organization_id= jsi.organization_id
      and nvl(rtng.common_routing_sequence_id,rtng.routing_sequence_id) = os.routing_Sequence_id
      AND nvl(rtng.common_routing_sequence_id,rtng.routing_Sequence_id) = seqs.routing_sequence_id
      AND NVL(rtng.alternate_routing_designator,' ')=
              NVL( jsi.alternate_routing_designator,' ')
    and  jsi.header_id = jdi.parent_header_id
    and jdi.load_type = 3
    and seqs.operation_seq_num = os.operation_seq_num
    and seqs.operation_seq_num = jdi.operation_seq_nuM
    and jdi.parent_header_id = lv_header_id(n)
    and jdi.group_id = jsi.group_id
    and jsi.group_id = G_WIP_GROUP_ID);

       luno_op_count:= SQL%ROWCOUNT;


    EXCEPTION WHEN OTHERS THEN
       RAISE;
    END;


       SELECT os.operation_seq_num,
              to_number(decode(nvl(bor.schedule_seq_num,-1),-1,bor.resource_seq_num,bor.schedule_seq_num)),
              0,
              bor.resource_seq_num,
              bor.resource_id,
              bor.basis_type,
              bor.usage_rate_or_Amount,
              2
         BULK COLLECT
         INTO lun_op_seq_num,
              lun_sim_res_seq,
              lun_res_priority,
              lun_res_seq,
              lun_resource_id,
              lun_basis_type,
              lun_usage,
              lun_res_required
         FROM BOM_OPERATION_RESOURCES bor,
              BOM_OPERATION_SEQUENCES os,
              BOM_RESOURCES br
        WHERE os.routing_sequence_id= lv_routing_seq_id(n)
          AND bor.operation_sequence_id= os.operation_sequence_id
          AND os.effectivity_date <= lv_start_date(n)
         -- AND NVL(os.disable_date, lv_start_date(n)) >= lv_start_date(n)
         AND NVL(os.disable_date, nvl(br.disable_date, lv_start_date(n))) >= lv_start_date(n) -- bug# 4290120
         AND br.resource_id = bor.resource_id
         and schedule_flag = 2
          AND not exists(select jdi.resource_id_new
     			FROM BOM_OPERATIONAL_ROUTINGS rtng,
                             BOM_OPERATION_SEQUENCES seqs,
          		     wip_job_dtls_interface jdi,
                             wip_job_schedule_interface jsi
      where rtng.assembly_item_id= jsi.primary_item_id
      AND rtng.organization_id= jsi.organization_id
      AND nvl(rtng.common_routing_sequence_id,rtng.routing_sequence_id) = seqs.routing_sequence_id
      AND NVL(rtng.alternate_routing_designator,' ')=
              NVL( jsi.alternate_routing_designator,' ')
    and  jsi.header_id = jdi.parent_header_id
    and jdi.load_type = 1
    and jdi.resource_id_new = bor.resource_id
    and nvl(rtng.common_routing_sequence_id,rtng.routing_sequence_id) = os.routing_Sequence_id
    and seqs.operation_seq_num = os.operation_seq_num
    and seqs.operation_seq_num = jdi.operation_seq_nuM
    and jdi.parent_header_id = lv_header_id(n)
    and jdi.group_id = jsi.group_id
    and jsi.group_id = G_WIP_GROUP_ID);

       lun_res_req_count:= SQL%ROWCOUNT;

       SELECT distinct os.operation_seq_num,
              to_number(bor.schedule_seq_num),
              bor.principle_flag,
              to_number(bor1.resource_seq_num),
              bor.resource_id,
              bor1.resource_id,
              jdi.parent_header_id,
              jdi.organization_id,
              jdi.rowid,
              bor1.substitute_group_num,
              jdi.REPLACEMENT_GROUP_NUM,
              jdi.start_date,
              jdi.completion_date,
              jdi.usage_rate_or_amount,
              bor.basis_type
               -- dsr: added the following 7 columns
	 , jdi.firm_flag
	 , jdi.setup_id
	 , jdi.group_sequence_id
	 , jdi.group_sequence_number
	 , jdi.batch_id
	 , jdi.maximum_assigned_units
	 , jdi.parent_seq_num
	 -- , resource_seq_num
	 -- , schedule_seq_num
         BULK COLLECT
         INTO lsud_op_seq_num,
              lsud_sim_res_seq,
              lsud_res_priority,
              lsud_res_seq,
              lsud_resource_id,
              lsud_resource_id_del,
              lsud_header_id,
              lsud_organization_id,
              lsud_jdi_rowid,
              lsud_sub_grp,
              lsud_rep_grp,
              lsud_start_date,
              lsud_completion_date,
              lsud_new_usage,
              lsud_basis_type
              -- dsr added following 7 lines
	 , lsud_firm_flag
	 , lsud_setup_id
	 , lsud_group_sequence_id
	 , lsud_group_sequence_number
	 , lsud_batch_id
	 , lsud_maximum_assigned_units
	 , lsud_parent_seq_num
	 -- , lsud_schedule_seq_num
         FROM BOM_SUB_OPERATION_RESOURCES bor,
              bom_operation_resources bor1,
              BOM_OPERATION_SEQUENCES os,
              BOM_RESOURCES br,
              WIP_JOB_DTLS_INTERFACE JDI
        WHERE os.routing_sequence_id= lv_routing_seq_id(n)
          AND bor.operation_sequence_id= os.operation_sequence_id
          AND os.effectivity_date <= lv_start_date(n)
         -- AND NVL(os.disable_date, lv_start_date(n)) >= lv_start_date(n)
          AND NVL(os.disable_date, nvl(br.disable_date,lv_start_date(n))) >= lv_start_date(n)
          AND br.resource_id = bor.resource_id
          AND bor.operation_sequence_id= bor1.operation_sequence_id
          and bor.substitute_group_num = bor1.substitute_group_num
          and bor.schedule_seq_num = bor1.schedule_seq_num
          AND TO_NUMBER(bor.schedule_seq_num) IS NOT NULL
          AND JDI.RESOURCE_ID_NEW = BOR.RESOURCE_ID
          -- and jdi.resource_seq_num = bor1.resource_seq_num
          and jdi.schedule_seq_num = bor1.schedule_seq_num
/*The resource_seq in jdi is actually the schedule_seq*/
          AND JDI.GROUP_ID =G_WIP_GROUP_ID
          and jdi.parent_header_id = lv_header_id(n) /* Bug # 2671426 - Forward Port for Bug 2657820 */
          and nvl(jdi.REPLACEMENT_GROUP_NUM,-1) <> 0
          and bor.replacement_group_num = nvl(jdi.REPLACEMENT_GROUP_NUM,-100)
          -- dsr and jdi.load_type = 1
          and jdi.load_type IN (1, LT_RESOURCE_USAGE, RESOURCE_INSTANCES, RESOURCE_INSTANCE_USAGE)
       ORDER BY
             1,2,3 ASC,5;

       lsud_res_req_count:= SQL%ROWCOUNT;

       lv_init_k:= 1;


      /* If we are recommending any Resource changes, then Get the Resource_seq_num for the Resource from         BOM Tables. (Since we did not collect this - We only collected schedule_seq_num  */

       FOR j IN 1..lv_res_req_count LOOP


--           FOR k in lv_init_k..lu_res_req_count LOOP
/* Bug : 1967136 , in order to fix resource id does not exists issue*/
           FOR k in 1..lu_res_req_count LOOP

               IF lv_op_seq_num(j)  = lu_op_seq_num(k)   AND
                  lv_sim_res_seq(j) = lu_sim_res_seq(k)  AND
                  lv_res_priority(j)= lu_res_priority(k) AND
                  lv_resource_id (j)= lu_resource_id(k)  THEN

              --    lv_res_seq(j):= lu_res_seq(k);
                  lu_res_required(k):= 1;

                  lv_init_k:= k+1;
                  EXIT;
               END IF;

           END LOOP;  -- k

      END LOOP;



       lv_init_k:= 1;


      /* Based on the Resource_Seq_num we got above, update the records with that resource_seq_num
         for the resource records in WIP_JOB_DETAILS_INTERFACE, (the one's we are created) */

       FOR j IN 1..lv_res_req_count

       Loop



       UPDATE WIP_JOB_DTLS_INTERFACE
          SET resource_seq_num= lv_res_seq(j),
              resource_id_old = lv_resource_id(j),
              schedule_seq_num = lv_sim_res_seq(j),
              scheduled_flag = lv_scheduled_flag(j)
        WHERE ROWID= lv_jdi_rowid(j)
        and lv_res_priority(j) =  0;  --Update only the primary resources

     End loop;


     /* HANDLE ALTERNATE RESOURCES */
       /* If we are enforcing use of a alternate resource, then we first need to communicate to WIP to
          delete the primary resource which wip will get by exploding the routing. This loop Below will
          loop through all Resource records where we are implementing alternate and delete the primaries
           for that alternate -- this was old logic*/
         /* Now if we communicating to WIP that we are passing alternate resource to WIP,
            for a resource
            substitution, the record in wip_job_dtls_interface should have the
            following columns filled in:
            load_type = 1
            substitution_type = 3
            opearation_seq_num, resource_seq_num, resource_id_old, resource_id_new,
           and substitute_group_num should be set to the current(or primary) resource in
            wip_operation_resources
            replacement_group_num = valid value in wip_sub_operation_resources.Finally the
            alternate resource record will be deleted from wip_job_dtls_interface*/

  FOR j IN 1..lsud_res_req_count

    Loop
        Begin

       INSERT INTO WIP_JOB_DTLS_INTERFACE
             ( last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               group_id,
               parent_header_id,
               operation_seq_num,
               resource_seq_num,
               resource_id_old,
               resource_id_new,
               replacement_group_num,
               substitute_group_num,
               start_date,
               completion_date,
               organization_id,
               substitution_type,
               load_type,
	       process_phase,
	       process_status,
                 scheduled_flag
	 -- dsr: added the following 7 columns
	 , firm_flag
	 , setup_id
	 , group_sequence_id
	 , group_sequence_number
	 , batch_id
	 , maximum_assigned_units
	 , parent_seq_num
	 -- , resource_seq_num
	 -- , schedule_seq_num
			)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               G_WIP_GROUP_ID,
               lsud_header_id(j),
               lsud_op_seq_num(j),
               lsud_res_seq(j),
               lsud_resource_id_del(j),
               lsud_resource_id_del(j),
               lsud_rep_grp(j),
               lsud_sub_grp(j),
               lsud_start_date(j),
               lsud_completion_date(j),
               lsud_organization_id(j),
               3,
               1,
               2,
               1,
               1 --lv_scheduled_flag(j)
           -- dsr: added the following 7 columns
	 , lsud_firm_flag(j)
	 , lsud_setup_id(j)
	 , lsud_group_sequence_id(j)
	 , lsud_group_sequence_number(j)
	 , lsud_batch_id(j)
	 , lsud_maximum_assigned_units(j)
	 , lsud_parent_seq_num(j)
	 -- , lsud_schedule_seq_num(j)
          FROM DUAL;


        /*Delete the Alternate that we provided */
        delete from WIP_JOB_DTLS_INTERFACE
        WHERE ROWID= lsud_jdi_rowid(j);
  Exception
       when others then raise;
End;

End loop;

/* HANDLE UNSCHEDULES OPERATIONS AND RESOURCES */
       /* Since WIP Will Pull into the Job , all operations that APS didn't even collect
         (scheduled=no), we will set the start and end time of these operations to the
          fall in between the previous op from this op and the next op from this op */


    FOR M in 1..luno_op_count

    Loop


  BEGIN
     select nvl(max(operation_seq_num),-1)
     into v_previous_op
     from wip_job_dtls_interface
     where parent_header_id = lv_header_id(n)
     and group_id = G_WIP_GROUP_ID
     and load_type = 3
     and substitution_type <> 1
     and operation_seq_num < luno_op_seq_num(m);

     select nvl(min(operation_seq_num),-1)
     into v_next_op
     from wip_job_dtls_interface
     where parent_header_id = lv_header_id(n)
     and group_id = G_WIP_GROUP_ID
     and substitution_type <> 1
     and load_type = 3
     and operation_seq_num > luno_op_seq_num(m);


   /* If v_previous_op = -1 and  v_next_op = -1 , Do nothing */
  /*  as we will not plan for just 1 un-scheduled opeartion, if it exists */

  if (v_previous_op = -1 and v_next_op <> -1) then

    Select first_unit_start_date
   into v_last_end
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 3
   and operation_seq_num = v_next_op;

   v_last_start := v_last_end;
   v_frst_start := v_last_end;
   v_frst_end := v_last_end;

  elsif (v_next_op = -1 and v_previous_op <> -1) then

    Select last_unit_completion_date
   into v_frst_start
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 3
   and operation_seq_num = v_previous_op;

   v_frst_end := v_frst_start;
   v_last_start := v_frst_start;
   v_last_end := v_frst_start;

  else

   Select first_unit_start_date
   into v_last_end
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 3
   and operation_seq_num = v_next_op;

   v_last_start := v_last_end;

   Select last_unit_completion_date
   into v_frst_start
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 3
   and operation_seq_num = v_previous_op;

   v_frst_end := v_frst_start;

 end if;

 EXCEPTION WHEN OTHERS THEN
       RAISE;
 END;

       INSERT INTO WIP_JOB_DTLS_INTERFACE
             ( last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               group_id,
               parent_header_id,
               operation_seq_num,
               standard_operation_id,
               organization_id,
               substitution_type,
               load_type,
               first_unit_start_date,
               first_unit_completion_date,
               last_unit_start_date,
               last_unit_completion_date,
	       process_phase,
	       process_status,
               scheduled_flag)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
                FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               luno_op_seq_num(m),
               luno_std_op_seq_id(m),
               lv_organization_id(n),
               3,
               3,
               v_frst_start,
               v_frst_end,
               v_last_start,
               v_last_end,
               2,
               1,
               2 --lv_scheduled_flag(j)
          FROM DUAL;

End loop;

    FOR j IN 1..lun_res_req_count

    Loop
        Begin

  BEGIN
     select max(operation_seq_num)
     into v_previous_op
     from wip_job_dtls_interface
     where parent_header_id = lv_header_id(n)
     and group_id = G_WIP_GROUP_ID
     and load_type = 3
     and substitution_type <> 1
     and operation_seq_num <= lun_op_seq_num(j);

     select min(operation_seq_num)
     into v_next_op
     from wip_job_dtls_interface
     where parent_header_id = lv_header_id(n)
     and group_id = G_WIP_GROUP_ID
     and substitution_type <> 1
     and load_type = 3
     and operation_seq_num >= lun_op_seq_num(j);

     select nvl(max(resource_seq_num),-1)
     into v_previous_res
      from wip_job_dtls_interface s
     where s.parent_header_id = lv_header_id(n)
     and s.group_id = G_WIP_GROUP_ID
     and s.load_type = 1
     and s.substitution_type <> 1
     and s.operation_seq_num = lun_op_seq_num(j)
     and nvl(s.schedule_seq_num,s.resource_seq_num) < lun_res_seq(j);


     select nvl(max(schedule_seq_num),-1)
     into v_previous_res1
     from wip_job_dtls_interface s
     where s.parent_header_id = lv_header_id(n)
     and s.group_id = G_WIP_GROUP_ID
     and s.load_type = 1
     and s.substitution_type <> 1
     and s.operation_seq_num = lun_op_seq_num(j)
     and nvl(s.schedule_seq_num,s.resource_seq_num) < lun_res_seq(j);

     if (v_previous_res1 > v_previous_res) then
        select nvl(max(resource_seq_num),-1)
        into v_previous_res
        from wip_job_dtls_interface s
        where s.parent_header_id = lv_header_id(n)
        and s.group_id = G_WIP_GROUP_ID
        and s.load_type = 1
        and s.substitution_type <> 1
        and s.operation_seq_num = lun_op_seq_num(j)
        and nvl(s.schedule_seq_num,s.resource_seq_num) < lun_res_seq(j)
        and s.schedule_seq_num = v_previous_res1
        and rownum=1;
 		end if ;

     select nvl(min(resource_seq_num),-1)
     into v_next_res
      from wip_job_dtls_interface s
     where s.parent_header_id = lv_header_id(n)
     and s.group_id = G_WIP_GROUP_ID
     and s.substitution_type <> 1
     and s.load_type = 1
     and s.operation_seq_num = lun_op_seq_num(j)
     and nvl(s.schedule_seq_num,s.resource_seq_num) > lun_res_seq(j);

     select nvl(min(schedule_seq_num),-1)
     into v_next_res1
     from wip_job_dtls_interface s
     where s.parent_header_id = lv_header_id(n)
     and s.group_id = G_WIP_GROUP_ID
     and s.substitution_type <> 1
     and s.load_type = 1
     and s.operation_seq_num = lun_op_seq_num(j)
     and nvl(s.schedule_seq_num,s.resource_seq_num) > lun_res_seq(j);

     if (v_next_res1 < v_next_res) then
         select nvl(resource_seq_num,-1)
         into v_next_res
         from wip_job_dtls_interface s
         where s.parent_header_id = lv_header_id(n)
         and s.group_id = G_WIP_GROUP_ID
         and s.substitution_type <> 1
         and s.load_type = 1
         and s.operation_seq_num = lun_op_seq_num(j)
         and nvl(s.schedule_seq_num,s.resource_seq_num) > lun_res_seq(j)
         and s.schedule_seq_num = v_next_res1
         and rownum=1;
 		 end if ;


  if  (v_previous_res = -1 and v_next_res = -1)


  then



   Select first_unit_start_date
   into v_last_end
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 3
   and operation_seq_num = v_next_op;

   v_last_start := v_last_end;

   Select last_unit_completion_date
   into v_frst_start
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 3
   and operation_seq_num = v_previous_op;

   v_frst_end := v_frst_start;


elsif (v_previous_res = -1 and v_next_res <> -1)


 then

   Select start_date
   into v_last_end
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 1
   and operation_seq_num = v_next_op
   and resource_Seq_num  = v_next_res
   and rownum = 1;

   v_last_start := v_last_end;

   Select start_date
   into v_frst_start
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 1
   and operation_seq_num = v_previous_op
   and resource_Seq_num  = v_next_res
   and rownum = 1;

   v_frst_end := v_frst_start;

elsif (v_previous_res <> -1 and v_next_res = -1)

 then

   Select completion_date
   into v_last_end
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 1
   and operation_seq_num = v_next_op
   and resource_Seq_num  = v_previous_res
   and rownum = 1;

   v_last_start := v_last_end;

   Select completion_date
   into v_frst_start
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 1
   and operation_seq_num = v_previous_op
   and resource_Seq_num  = v_previous_res
   and rownum = 1;

   v_frst_end := v_frst_start;

else

   Select start_date
   into v_last_end
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 1
   and operation_seq_num = v_next_op
   and resource_Seq_num  = v_next_res
   and rownum = 1;

   v_last_start := v_last_end;

   Select completion_date
   into v_frst_start
   from wip_job_dtls_interface
   where parent_header_id = lv_header_id(n)
   and group_id = G_WIP_GROUP_ID
   and load_type = 1
   and operation_seq_num = v_previous_op
   and resource_Seq_num  = v_previous_res
   and rownum = 1;

   v_frst_end := v_frst_start;

End if;

 EXCEPTION WHEN OTHERS THEN
       RAISE;
 END;

       /*insert record for  the resource with schedule = no with start and end time
        as that of the opertaion*/
       INSERT INTO WIP_JOB_DTLS_INTERFACE
             ( last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               group_id,
               parent_header_id,
               operation_seq_num,
               resource_seq_num,
               resource_id_old,
               resource_id_new,
               basis_type,
               usage_rate_or_amount,
               organization_id,
               substitution_type,
               load_type,
               start_date,
               completion_date,
	       process_phase,
	       process_status,
               scheduled_flag)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               G_WIP_GROUP_ID,
               lv_header_id(n),
               lun_op_seq_num(j),
               lun_res_seq(j),
               lun_resource_id(j),
               lun_resource_id(j),
               lun_basis_type(j),
               lun_usage(j),
               lv_organization_id(n),
               3,
               1,
               v_frst_start,
               v_last_end,
               2,
               1,
               2 --lv_scheduled_flag(j)
          FROM DUAL;

      End;


       End loop;

ELSE

	BEGIN

          SELECT wor.operation_seq_num,
         	wor.schedule_seq_num,
         	wor.resource_seq_num,
         	jdi.rowid,
         	wor.substitute_group_num,
         	jdi.REPLACEMENT_GROUP_NUM
         BULK COLLECT
         INTO elsud_op_seq_num,
              elsud_sim_res_seq,
              elsud_res_seq,
              elsud_jdi_rowid,
              elsud_sub_grp,
              elsud_rep_grp
          FROM WIP_OPERATION_RESOURCES wor,
          WIP_JOB_DTLS_INTERFACE JDI
        WHERE wor.operation_seq_num = jdi.operation_seq_num
          and nvl(wor.schedule_seq_num,wor.resource_seq_num) = jdi.schedule_seq_num
          -- and wor.resource_seq_num = jdi.resource_seq_num
          and nvl(wor.replacement_group_num,0) = nvl(jdi.replacement_group_num,0)
          and jdi.resource_id_new = wor.resource_id
          and jdi.resource_seq_num = wor.resource_seq_num
           -- dsr and jdi.load_type = 1
          and jdi.load_type IN (1, LT_RESOURCE_USAGE, RESOURCE_INSTANCES, RESOURCE_INSTANCE_USAGE)
          and jdi.parent_header_id = lv_header_id(n)
          and JDI.GROUP_ID =G_WIP_GROUP_ID
          and wor.wip_entity_id = lv_wip_entity_id(n)
          and nvl(wor.repetitive_schedule_id ,-1)= -1
          and jdi.parent_seq_num is null
          ;

	lv_elsud_cnt := SQL%ROWCOUNT;

       	FOR x IN 1..lv_elsud_cnt

       Loop

       UPDATE WIP_JOB_DTLS_INTERFACE
          SET
           -- resource_seq_num= elsud_res_seq(x),
              schedule_seq_num = elsud_sim_res_seq(x),
              substitute_group_num = elsud_sub_grp(x)
        WHERE ROWID= elsud_jdi_rowid(x);


    	 End loop;


    Exception
       when NO_DATA_FOUND THEN
        Null;
       When others THEN raise;

    END;

   BEGIN

    	 select wor.operation_seq_num,
    	 	wsor.schedule_seq_num,
    	 	wsor.principle_flag,
    	 	wor.resource_seq_num,
    	 	wor.resource_id,
    	 	jdi.parent_header_id,
              	jdi.organization_id,
              	jdi.rowid,
              	wor.substitute_group_num,
              	jdi.REPLACEMENT_GROUP_NUM,
              	jdi.start_date,
              	jdi.completion_date,
              	jdi.usage_rate_or_amount,
              	wsor.basis_type
    	 BULK COLLECT INTO lv_res_alt_op_seq_num,
    	 		   lv_res_alt_schd_seq_num,
    	 		   lv_res_alt_prin_flag,
    	 		   lv_res_alt_res_seq_num,
    	 		   lv_res_alt_res_id,
    	 		   lv_res_alt_hdr_id,
    	 		   lv_res_alt_org_id,
    	 		   lv_res_alt_rowid,
    	 		   lv_res_alt_sub_grp_num,
    	 		   lv_res_alt_rep_grp_num,
    	 		   lv_res_alt_start_date,
    	 		   lv_res_alt_completion_date,
    	 		   lv_res_alt_usage_rate,
    	 		   lv_res_alt_basis_type
    	 from wip_job_dtls_interface jdi,
    	 wip_operation_resources wor,
    	 wip_sub_operation_resources wsor
    	 where not exists(select 1 from wip_operation_resources wor1
    	 	where wor1.operation_seq_num = jdi.operation_seq_num
    	 	and nvl(wor1.schedule_seq_num,wor1.resource_seq_num) = jdi.schedule_seq_num
    	 	-- and wor1.resource_seq_num = jdi.resource_seq_num
    	 	and nvl(wor1.replacement_group_num,0) = nvl(jdi.replacement_group_num,0)
    	 	and wor1.wip_entity_id = lv_wip_entity_id(n)
    	 	and nvl(wor1.repetitive_schedule_id ,-1) = -1  )
    	 and wsor.operation_seq_num = wor.operation_seq_num
    	 and wsor.wip_entity_id = wor.wip_entity_id
    	 and nvl(wsor.repetitive_schedule_id,-1) = nvl(wor.repetitive_schedule_id,-1)
    	 and wor.substitute_group_num = wsor.substitute_group_num
    	 and wsor.wip_entity_id = lv_wip_entity_id(n)
    	 and wsor.resource_id = jdi.resource_id_old
    	 and wsor.operation_seq_num = jdi.operation_seq_num
    	 and nvl(wsor.schedule_seq_num,wsor.resource_seq_num) = jdi.schedule_seq_num
         -- and wsor.resource_seq_num = jdi.resource_seq_num
    	 and nvl(wsor.replacement_group_num,0) = nvl(jdi.replacement_group_num,0)
    	 and nvl(wsor.repetitive_schedule_id ,-1)= -1
    	 and jdi.load_type = 1
         and jdi.parent_header_id = lv_header_id(n)
         and JDI.GROUP_ID =G_WIP_GROUP_ID
         and wsor.scheduled_flag <> 2;

         lv_res_alt_req_count:= SQL%ROWCOUNT;

	FOR j IN 1..lv_res_alt_req_count

 	   Loop
   	     Begin

    	 INSERT INTO WIP_JOB_DTLS_INTERFACE
             ( last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               group_id,
               parent_header_id,
               operation_seq_num,
               resource_seq_num,
               resource_id_old,
               resource_id_new,
               replacement_group_num,
               substitute_group_num,
               start_date,
               completion_date,
               organization_id,
               substitution_type,
               load_type,
	       process_phase,
	       process_status,
               scheduled_flag)
        SELECT SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               G_WIP_GROUP_ID,
               lv_res_alt_hdr_id(j),
               lv_res_alt_op_seq_num(j),
               lv_res_alt_res_seq_num(j),
               lv_res_alt_res_id(j),
               lv_res_alt_res_id(j),
               lv_res_alt_rep_grp_num(j),
               lv_res_alt_sub_grp_num(j),
               lv_res_alt_start_date(j),
               lv_res_alt_completion_date(j),
               lv_res_alt_org_id(j),
               3,
               1,
               2,
               1,
               1 --lv_scheduled_flag(j)
          FROM DUAL;

           delete from WIP_JOB_DTLS_INTERFACE
           WHERE ROWID= lv_res_alt_rowid(j);

  	Exception
       when others then raise;

      END;
   END LOOP;

   Exception
     when  NO_DATA_FOUND THEN
        Null;
       When others THEN raise;
   END;

end if;

--Bug 3333343
   UPDATE WIP_JOB_DTLS_INTERFACE set REPLACEMENT_GROUP_NUM = null
   where REPLACEMENT_GROUP_NUM = 0
   AND GROUP_ID= G_WIP_GROUP_ID
   AND PARENT_HEADER_ID= lv_header_id(n)
   AND LOAD_TYPE = LT_RESOURCE;


  <<next_c_std_job>> NULL;
    END LOOP;

   /* Now that we are done processing all Jobs and details, lets go back to the alternate
      resource records for all the jobs we processed and generate a resource_Seq_num by getting
      the max of existing resource_seq_num from the routing for the assembly and adding one to it.
       --old logic this piece of code is now commented out*/
 /*
   for i in cres_upd
     loop
   if (nvl(v_old_op,0) <> i.operation_seq_num and nvl(v_old_header,0) <> i.parent_header_id)

       then

        Select max(bor1.resource_seq_num)
        into v_max_resource_Seq
         FROM bom_operation_resources bor1,
              BOM_OPERATION_SEQUENCES os
        WHERE bor1.operation_sequence_id= os.operation_sequence_id
          and os.routing_sequence_id= i.common_routing_Sequence_id
          and os.operation_seq_num = i.operation_seq_num;

        v_old_header := i.parent_header_id;
        v_old_op := i.operation_seq_num;
    End if;

      v_max_resource_seq := v_max_resource_Seq + 1;


      update wip_job_dtls_interface
      set resource_Seq_num = v_max_resource_Seq
      where rowid = i.rowid;
    End loop;
 */

EXCEPTION
    WHEN OTHERS THEN RAISE;

END MODIFY_RESOURCE_REQUIREMENT;

-- dsr: begin
-- commenting the eam code, refer bug# 4524589

/* PROCEDURE LD_EAM_RESCHEDULE_JOBS
               ( o_request_id    OUT NOCOPY NUMBER)
IS
    lv_sqlstmt        VARCHAR2(4000);
    lv_instance_id    NUMBER;
    lv_dblink         VARCHAR2(128);

    lv_result         BOOLEAN;

    lv_dummy          INTEGER;

BEGIN

dbms_output.put_line( 'LD_EAM_RESCHEDULE_JOBS: 000  ');

      select DECODE( A2M_DBLINK,
                   NULL, ' ',
                   '@'||A2M_DBLINK),
           INSTANCE_ID
      into lv_dblink,
           lv_instance_id
      from MRP_AP_APPS_INSTANCES_ALL
      where instance_id                    = v_instance_id
      and   instance_code                  = v_instance_code
      and   nvl(a2m_dblink,NULL_DBLINK)    = nvl(v_dblink,NULL_DBLINK)
      and ALLOW_RELEASE_FLAG=1;

dbms_output.put_line( 'LD_EAM_RESCHEDULE_JOBS: 111 lv_dblink/lv_instance_id '
						|| lv_dblink
						|| '/' || lv_instance_id
						);

lv_sqlstmt:=
       'INSERT INTO EAM_WORK_ORDER_IMPORT'
||'     ( LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       header_ID,'
||'       GROUP_ID,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       asset_activity_id,'
||'       REQUESTED_START_DATE,'
||'       DUE_DATE,'
||'       FIRM_PLANNED_FLAG,'
||'       SCHEDULED_START_DATE,'
||'       SCHEDULED_COMPLETION_DATE,'
||'       priority,'
||'       STATUS_TYPE,'
||'       WIP_ENTITY_NAME,'
||'       Job_quantity,'
||'       TRANSACTION_TYPE,'
||'       PROCESS_STATUS,'
||'       project_id,'
||'       task_id,'
--||'       bom_reference_id,'
--||'       routing_reference_id,'
||'       alternate_bom_designator,'
||'       alternate_routing_designator, '
||'       end_item_unit_number,'
||'       schedule_group_id,'
||'       REBUILD_SERIAL_NUMBER )' -- build_sequence )'
||'     SELECT'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       DECODE( ORGANIZATION_TYPE,1,SYSDATE,creation_date), '
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       WIP_ENTITY_ID,'
||'       EAM_WORK_ORDER_IMPORT_S.nextval,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
-- dsr ||'       PRIMARY_ITEM_ID,'
||'       DECODE(PRIMARY_ITEM_ID, -1000, NULL, PRIMARY_ITEM_ID),'
||'       FIRST_UNIT_START_DATE,' -- REQUESTED_START_DATE,'
||'       REQUESTED_COMPLETION_DATE,'
||'       firm_planned_flag,'
||'       first_unit_start_date,'
||'       last_unit_completion_date,'
||'       schedule_priority,'
||'       status_type,'
||'       job_name,'
||'       start_quantity,'
||'       2,' -- G_OPR_UPDATE,'
||'       1,' -- process_status
||'       PROJECT_ID,'
||'       TASK_ID,'
--||'       bom_reference_id,'
--||'       routing_reference_id,'
||'       alternate_bom_designator, '
||'       alternate_routing_designator, '
||'       end_item_unit_number, '
||'       schedule_group_id, '
||'       build_sequence '
||'     FROM MSC_WIP_JOB_SCHEDULE_INTERFACE'||lv_dblink
||'    WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||'    AND   load_type = 21 ' -- EAM_RESCHEDULE_WORK_RODER
 		;

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

dbms_output.put_line( 'rows inserted into EAM_WORK_ORDER_IMPORT = '
  					|| SQL%ROWCOUNT);

-- operations

dbms_output.put_line('operations');
lv_sqlstmt:=
       'INSERT INTO EAM_OPERATION_IMPORT'
||'     ( LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       header_ID,'
||'       GROUP_ID,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       TRANSACTION_TYPE,'
--||'       PROCESS_STATUS,'
||'       operation_seq_num,'
||'       OPERATION_SEQUENCE_ID,'
||'       department_id,'
||'       START_DATE,'
||'       COMPLETION_DATE )'
||'     SELECT'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       DECODE( ORGANIZATION_TYPE,1,SYSDATE,creation_date), '
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       WIP_ENTITY_ID,'
||'       EAM_WORK_ORDER_IMPORT_S.nextval,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       2,' -- G_OPR_UPDATE,','
--||'       1,' -- process_status
||'       operation_seq_num,'
||'       operation_seq_id,'
||'       department_id,'
||'       first_unit_start_date,'
||'       last_unit_completion_date '
||'     FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||' AND GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(operation_seq_num,-1) <> -1'
||'    AND   eam_flag = 1 ' -- SYS_YES
||'    AND   load_type = 3 '
;

dbms_output.put_line('lv_dblink/lv_instance_id/G_WIP_GROUP_ID = '
						|| lv_dblink
						|| '/' || lv_instance_id
						|| '/' || G_WIP_GROUP_ID
						);

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

dbms_output.put_line( 'rows inserted into EAM_OPERATION_IMPORT = '
  					|| SQL%ROWCOUNT);

-- operation resource

lv_sqlstmt:=
       'INSERT INTO EAM_RESOURCE_IMPORT'
||'     ( header_ID,'
||'       GROUP_ID,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       TRANSACTION_TYPE,'
--||'       PROCESS_STATUS,'
||'       operation_seq_num,'
||'       resource_seq_num,'
||'       replacement_group_num,'
||'       resource_id,'
||'       START_DATE,'
||'       completion_date, '
||'       Schedule_Seq_num, '
||'       scheduled_flag, '
||'       basis_type, '
||'       department_id, '
||'       Assigned_Units, '
||'       Firm_flag ) '
||'     SELECT'
||'       WIP_ENTITY_ID,'
||'       EAM_WORK_ORDER_IMPORT_S.nextval,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       2,' -- G_OPR_UPDATE,','
--||'       1,' -- process_status
||'       operation_seq_num,'
||'       orig_resource_seq_num,'
||'       alternate_num,'
||'       resource_id_new,'
||'       start_date,'
||'       completion_date, '
||'       999, ' -- calculated for Schedule_Seq_num
||'       999, ' -- calculated for SUBSTITUTE_GROUP_NUM
||'       scheduled_flag, '
||'       basis_type, '
||'       department_id, '
||'       FIRM_FLAG '
||'     FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||' AND GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(operation_seq_num,-1) <> -1'
||'    AND   eam_flag = 1 ' -- SYS_YES
||'    AND   load_type = 1 '
;

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

dbms_output.put_line( 'rows inserted into EAM_RESOURCE_IMPORT = '
  					|| SQL%ROWCOUNT);

-- operation components

lv_sqlstmt:=
       'INSERT INTO EAM_MATERIAL_IMPORT'
||'     ( LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       header_ID,'
||'       GROUP_ID,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       TRANSACTION_TYPE,'
--||'       PROCESS_STATUS,'
||'       operation_seq_num,'
||'       inventory_item_id,'
||'       date_required,'
||'       Required_quantity )'
||'     SELECT'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       DECODE( ORGANIZATION_TYPE,1,SYSDATE,creation_date), '
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       WIP_ENTITY_ID,'
||'       EAM_WORK_ORDER_IMPORT_S.nextval,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       2,' -- G_OPR_UPDATE,','
--||'       1,' -- process_status
||'       operation_seq_num,'
||'       inventory_item_id_old,'
||'       date_required,'
||'       Required_quantity '
||'     FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||' AND GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(operation_seq_num,-1) <> -1'
||'    AND   eam_flag = 1 ' -- SYS_YES
||'    AND   load_type = 2 ' -- components
;

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

dbms_output.put_line( 'rows inserted into EAM_MATERIAL_IMPORT = '
  					|| SQL%ROWCOUNT);

-- reschedule resource instance

lv_sqlstmt:=
       'INSERT INTO EAM_RESOURCE_INSTANCE_IMPORT'
||'     ( LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       header_ID,'
||'       GROUP_ID,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       TRANSACTION_TYPE,'
--||'       PROCESS_STATUS,'
||'       operation_seq_num,'
||'       resource_seq_num,'
||'       INSTANCE_ID,'
||'       START_DATE,'
||'       completion_date, '
||'       SERIAL_NUMBER ) '
||'     SELECT'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       DECODE( ORGANIZATION_TYPE,1,SYSDATE,creation_date), '
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       WIP_ENTITY_ID,'
||'       EAM_WORK_ORDER_IMPORT_S.nextval,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       2,' -- G_OPR_UPDATE,','
--||'       1,' -- process_status
||'       operation_seq_num,'
||'       orig_resource_seq_num,'
||'       RESOURCE_INSTANCE_ID,'
||'       start_date,'
||'       completion_date, '
||'       SERIAL_NUMBER '
||'     FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||' AND GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(operation_seq_num,-1) <> -1'
||'    AND   eam_flag = 1 ' -- SYS_YES
||'    AND   load_type = 6 ' -- resource instance
;

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

dbms_output.put_line( 'rows inserted into EAM_RESOURCE_INSTANCE_IMPORT = '
  					|| SQL%ROWCOUNT);

-- reschedule resource/instance usage

lv_sqlstmt:=
       'INSERT INTO EAM_RESOURCE_USAGE_IMPORT'
||'     ( LAST_UPDATE_DATE,'
||'       LAST_UPDATED_BY,'
||'       CREATION_DATE,'
||'       CREATED_BY,'
||'       LAST_UPDATE_LOGIN,'
||'       header_ID,'
||'       GROUP_ID,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       TRANSACTION_TYPE,'
--||'       PROCESS_STATUS,'
||'       operation_seq_num,'
||'       resource_seq_num,'
||'       INSTANCE_ID,'
||'       START_DATE,'
||'       completion_date, '
||'       SERIAL_NUMBER ) '
||'     SELECT'
||'       SYSDATE,'
||'       FND_GLOBAL.USER_ID,'
||'       DECODE( ORGANIZATION_TYPE,1,SYSDATE,creation_date), '
||'       FND_GLOBAL.USER_ID,'
||'       LAST_UPDATE_LOGIN,'
||'       WIP_ENTITY_ID,'
||'       EAM_WORK_ORDER_IMPORT_S.nextval,'
||'       wip_entity_id,'
||'       ORGANIZATION_ID,'
||'       2,' -- G_OPR_UPDATE,','
--||'       1,' -- process_status
||'       operation_seq_num,'
||'       orig_resource_seq_num,'
||'       RESOURCE_INSTANCE_ID,'
||'       start_date,'
||'       completion_date, '
||'       SERIAL_NUMBER '
||'     FROM MSC_WIP_JOB_DTLS_INTERFACE'||lv_dblink
||' WHERE SR_INSTANCE_ID= :lv_instance_id'
||'    AND   nvl(CFM_ROUTING_FLAG,0) <> 3 '
||' AND GROUP_ID = :G_WIP_GROUP_ID'
||'    AND   nvl(operation_seq_num,-1) <> -1'
||'    AND   eam_flag = 1 ' -- SYS_YES
||'    AND   load_type IN (4, 7) ' -- resource and instance usage
;


--Commented out to support OPM integration
--||'    AND   ORGANIZATION_TYPE = 1 ';

   EXECUTE IMMEDIATE lv_sqlstmt USING lv_instance_id,G_WIP_GROUP_ID;

dbms_output.put_line( 'rows inserted into  EAM_RESOURCE_USAGE_IMPORT = '
  					|| SQL%ROWCOUNT);

   o_request_id := NULL;

   -- Submit EAM RESCHEDULE  Request --
   BEGIN
      SELECT 1
        INTO lv_dummy
        FROM WIP_JOB_SCHEDULE_INTERFACE
       WHERE GROUP_ID= G_WIP_GROUP_ID
         AND ROWNUM=1;

      MODIFY_EAM_COMP_REQUIREMENT;

      MODIFY_EAM_RES_REQUIREMENT;

    --set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.
      lv_result := FND_REQUEST.SET_MODE(TRUE);


      o_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'EAM',      -- application
                                        'EAMIMPWO',   -- program
                                        NULL,       -- description
                                        NULL,       -- start_time
                                        FALSE,      -- sub_request
                                        g_eam_group_id, -- group_id
				        1,          -- validation_level
					1);         -- print report


   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
      WHEN OTHERS THEN RAISE;
   END;

dbms_output.put_line( 'EAM RESCHEDULE Request submitted = ' || o_request_id);

END LD_EAM_RESCHEDULE_JOBS;
*/

/*
PROCEDURE MODIFY_EAM_COMP_REQUIREMENT
IS

Cursor C1 is
Select a.header_id,min(bos.operation_seq_num) new_op_seq
from eam_work_order_import a, -- wip_job_schedule_interface a,
     eam_material_import b, -- wip_job_dtls_interface b,
     bom_operation_Sequences bos,
     bom_operational_routings bor
where a.group_id = b.group_id
and   a.group_id = G_WIP_GROUP_ID
-- and   a.primary_item_id = bor.assembly_item_id
and   a.REBUILD_ITEM_ID = bor.assembly_item_id
and   nvl(bor.alternate_routing_Designator,0) = nvl(a.alternate_routing_designator,0)
and bor.common_routing_Sequence_id = bos.routing_Sequence_id
--and b.load_type = 2
--and b.substitution_type = 3
and a.source_code = 'MSC'
and b.operation_seq_num = 1
and ( bos.disable_date IS NULL
         OR trunc(bos.disable_date) >= trunc(nvl(a.bom_revision_date
		 ,a.scheduled_start_date))
     )
group by a.header_id;

Cursor C2 is
select sum(b.QUANTITY_PER_ASSEMBLY) qty_per_assy,
       sum(b.REQUIRED_QUANTITY)     reqd_qty,
       b.group_id,
       b.wip_entity_id, -- b.parent_header_id,
       b.INVENTORY_ITEM_ID, -- b.INVENTORY_ITEM_ID_OLD,
       b.ORGANIZATION_ID,
       b.OPERATION_SEQ_NUM
 from eam_work_order_import a,  -- wip_job_schedule_interface a,
      eam_material_import b -- wip_job_dtls_interface b
 where a.source_code = 'MSC'
   and a.group_id = G_WIP_GROUP_ID
   and a.group_id = b.group_id
-- and a.header_id = b.parent_header_id
   and a.wip_entity_id = b.wip_entity_id
--   and b.load_type = 2
--   and b.substitution_type = 3
--   and b.process_phase = 2
--   and b.process_status = 1
group by b.group_id,
         b.wip_entity_id, -- b.parent_header_id,
         b.ORGANIZATION_ID,
         b.INVENTORY_ITEM_ID, -- b.INVENTORY_ITEM_ID_OLD,
         b.OPERATION_SEQ_NUM;

Cursor C3 is
select b.rowid
 from  eam_work_order_import a, -- wip_job_schedule_interface a,
       eam_material_import b -- wip_job_dtls_interface b
 where a.source_code = 'MSC'
   and a.group_id = G_WIP_GROUP_ID
   and a.group_id = b.group_id
-- and a.header_id = b.parent_header_id
   and a.wip_entity_id = b.wip_entity_id
--   and b.load_type = 2
--   and b.substitution_type = 3
--   and b.process_phase = 2
   --  and b.process_status = 1
   and b.rowid not in (select min(c.rowid)
                      from eam_material_import c -- wip_job_dtls_interface c
                     where b.group_id = c.group_id
                       -- and b.parent_header_id = c.parent_header_id
                       and b.wip_entity_id = c.wip_entity_id
                       and b.ORGANIZATION_ID = c.ORGANIZATION_ID
                       --  and b.INVENTORY_ITEM_ID_OLD = c.INVENTORY_ITEM_ID_OLD
                       and b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
                       and b.OPERATION_SEQ_NUM = c.OPERATION_SEQ_NUM
                       -- and b.load_type = c.load_type
                       -- and b.substitution_type = c.substitution_type
                       -- and b.process_phase = c.process_phase
                       -- and b.process_status = c.process_status
					);



Begin


For I in C1

loop
   update eam_material_import -- wip_job_dtls_interface
   set operation_Seq_num = I.new_op_seq
   -- where parent_header_id = I.header_id
   where wip_entity_id = I.header_id
   and   operation_seq_num = 1
   --  and load_type = 2
   --  and substitution_type = 3
   ;

End loop;


For J in C2

loop
   update eam_material_import -- wip_job_dtls_interface
   set    QUANTITY_PER_ASSEMBLY = J.qty_per_assy,
          REQUIRED_QUANTITY = J.reqd_qty
   where  group_id = J.group_id
   -- and    parent_header_id = J.parent_header_id
   and    wip_entity_id = J.wip_entity_id
   and    ORGANIZATION_ID = J.ORGANIZATION_ID
   --  and    INVENTORY_ITEM_ID_OLD = J.INVENTORY_ITEM_ID_OLD
   and    INVENTORY_ITEM_ID = J.INVENTORY_ITEM_ID
   and    OPERATION_SEQ_NUM = J.OPERATION_SEQ_NUM
   -- and    load_type = 2
   -- and    substitution_type = 3
   -- and    process_phase = 2
   -- and    process_status = 1
   ;

End loop;

For K in C3

loop

--jguo
--   delete wip_job_dtls_interface
--   where  rowid = K.rowid;

null;

End loop;

End MODIFY_EAM_COMP_REQUIREMENT;
*/

/*
PROCEDURE MODIFY_EAM_RES_REQUIREMENT
IS


    cursor cres_upd is
		select   wor.schedule_seq_num
			   , wor.substitute_group_num
		FROM WIP_OPERATION_RESOURCES  wor
		, EAM_RESOURCE_IMPORT  eir
        WHERE wor.operation_seq_num = eir.operation_seq_num
          and wor.resource_seq_num = eir.resource_seq_num
          and nvl(wor.replacement_group_num,0) = nvl(eir.replacement_group_num,0)
          and eir.resource_id = wor.resource_id
          and eir.GROUP_ID =G_EAM_GROUP_ID
          and wor.wip_entity_id =eir.wip_entity_id
          and nvl(wor.repetitive_schedule_id ,-1)= -1
          ;

    l_schedule_seq_num NUMBER;
    l_substitute_group_num NUMBER;

BEGIN

	OPEN cres_upd;
	FETCH cres_upd INTO l_schedule_seq_num, l_substitute_group_num;
	CLOSE cres_upd;

	Update EAM_RESOURCE_IMPORT  eir
    SET eir.schedule_seq_num =  l_schedule_seq_num
	, eir.substitute_group_num = l_substitute_group_num
	;

EXCEPTION
    WHEN OTHERS THEN RAISE;

END MODIFY_EAM_RES_REQUIREMENT; */

--dsr: end

END MRP_AP_REL_PLAN_PUB;

/
