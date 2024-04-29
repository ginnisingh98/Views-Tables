--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_PROC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_PROC_DATA" AS
/* $Header: amwprldb.pls 120.4 2005/10/24 01:04:54 appldev noship $ */
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/* Major Functionality of the followIng procedure includes:                  */
/* Reads the amw_processes_interface table                                   */
/* following tables:                                                         */
/*  INSERTS ARE DONE AGAINST THE FOLLOWING TABLES                            */
/*  Insert into Wf_Activities_B and Wf_Activities_Tl                         */
/*  Insert/Updates into AMW_Process                                          */
/*  Insert/Updates into Wf_Process_Activities                                */
/*  Updates amw_processes_interface, with error messages                     */
/*  Deleting successful production inserts, based on profile                 */
/*                                                                           */
/*****************************************************************************/
--
-- Used FOR EXCEPTION processing
--

   G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
   G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
   v_error_found                        BOOLEAN   DEFAULT FALSE;
   ----v_user_id                             NUMBER;
   v_user_id                            NUMBER := FND_GLOBAL.USER_ID;
   v_interface_id                       NUMBER;
   v_new_parent_interface_id			NUMBER;
   vx_control_rev_id                    NUMBER;
   lx_risk_rev_id                       NUMBER;
   v_err_msg                            VARCHAR2 (2000);
   v_table_name                         VARCHAR2 (240);
   v_interface_hierarchy_error          NUMBER := 0;
   V_PARENT_PROCESS_CODE_COUNTER		NUMBER := 0;
   v_parent_process_code                amw_processes_interface.PARENT_PROCESS_CODE%type;

   V_INTF_HIERARCHY_INV					VARCHAR2(1);
   v_counter							number := 0;

   type t_parent_process_NAME IS table of
amw_processes_interface.parent_process_name%type INDEX BY BINARY_INTEGER;
   v_parent_process_name          t_parent_process_name;

   /**
   type t_parent_process_CODE IS table of
amw_processes_interfacE.PARENT_PROCESS_CODE%type INDEX BY BINARY_INTEGER;
   v_parent_process_CODE          t_parent_process_CODE;

   TYPE t_parent_process_CODE IS VARRAY(500) OF
amw_processes_interfacE.PARENT_PROCESS_CODE%type;
   v_parent_process_CODE          t_parent_process_CODE;
   */
   type t_process_name IS table of amw_process.name%type INDEX BY BINARY_INTEGER;
   v_process_name          t_process_name;

   v_import_func      CONSTANT             VARCHAR2(30) := 'AMW_DATA_IMPORT';

   v_invalid_hierarchy_msg              VARCHAR2(2000);
   v_no_import_privilege_msg            VARCHAR2(2000);
   v_invalid_risk_type                  VARCHAR2(2000);
   v_inv_parent_prc_hier                VARCHAR2(2000);
   v_process_exist_no_update            VARCHAR2(2000);
   v_parent_process_error               VARCHAR2(80);
   v_parent_found                       NUMBER;



--
-- function to check the user access privilege
--
FUNCTION New_Parent_Processes_Check(p_batch_id in NUMBER)
     RETURN Boolean
IS
   Cursor c_new_parents Is
      select parent_process_name,process_interface_id,PARENT_PROCESS_CODE
        from amw_processes_interface
       where batch_id=p_batch_id
	     --WORKAROUND FOR NULL CODES ...
         and NVL(parent_process_CODE,'-1234567890') not in (
             select PROCESS_CODE
               from amw_LATEST_REVISIONS_v);

   l_func_exists NUMBER := 1;
   l_parent_name c_new_parents%rowtype;
   l_process_name NUMBER := 0;
BEGIN
   FOR l_parent_name in c_new_parents LOOP
   exit when c_new_parents%notfound;
      l_process_name := null;
	  --this loop is essentially all new parent_processes
	  --defined in the spreadsheet for the first time
	  --So, we need to check whether these processes are defined
	  --(i.e. have same ProcessDisplayName specified) in the same spreadsheet
	  --for the same upload or not.
	  --If not, this is not acceptable -- so shout, kick f!
	  BEGIN
         select count(1)
	       into l_process_name
           from amw_processes_interface
          where batch_id=p_batch_id
            and process_display_name = l_parent_name.parent_process_name
		    AND PROCESS_CODE IN (
			    SELECT PARENT_PROCESS_CODE
			      FROM AMW_PROCESSES_INTERFACE
				 WHERE BATCH_ID=P_BATCH_ID
				   AND PARENT_PROCESS_CODE NOT IN (SELECT PROCESS_CODE
				                                     FROM AMW_LATEST_REVISIONS_v)
								);
      EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    NULL;
	  END;

	  IF(l_process_name = 0)THEN
	     fnd_file.put_line (fnd_file.LOG, '**********************************');
         v_parent_process_error    := l_parent_name.parent_process_name;
	     v_new_parent_interface_id := l_parent_name.process_interface_id;
         return False;
      END IF;
   END LOOP;
   return TRUE;
END New_Parent_Processes_Check;


/*****************************************************************************/
/*****************************************************************************/
PROCEDURE create_processes (
   errbuf       OUT NOCOPY      VARCHAR2
  ,retcode      OUT NOCOPY      VARCHAR2
  ,p_batch_id   IN              NUMBER
  ,p_user_id    IN              NUMBER
)
IS
/****************************************************/
   CURSOR C_GET_INTF_DATA IS
      SELECT BATCH_ID
            ,PROCESS_INTERFACE_ID
            ,SIGNIFICANT_PROCESS_FLAG
            ,NVL(STANDARD_PROCESS_FLAG,'N') AS STANDARD_PROCESS_FLAG
            ,NVL(APPROVAL_STATUS,'D') AS APPROVAL_STATUS
            ,PROCESSED_FLAG
            ,ERROR_FLAG
            ,INTERFACE_STATUS
            ,PROCESS_CATEGORY
            ,NVL(REVISE_PROCESS_FLAG,'R') AS REVISE_PROCESS_FLAG
            ,PARENT_PROCESS_NAME
            ,PROCESS_DISPLAY_NAME
            ,PARENT_PROCESS_ID
            ,PROCESS_TYPE
            ,CONTROL_ACTIVITY_TYPE
            ,PROCESS_CODE
            ,PROCESS_SEQUENCE_NUMBER
            ,PARENT_PROCESS_CODE
            ,ATTACHMENT_URL
		FROM AMW_PROCESSES_INTERFACE
	   WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
         AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
         AND processed_flag IS NULL
         AND error_flag IS NULL
       order by process_interface_id asc;

   CURSOR C_GET_INTF_ROWS IS
      SELECT BATCH_ID
            ,PROCESS_INTERFACE_ID
            ,SIGNIFICANT_PROCESS_FLAG
            ,NVL(STANDARD_PROCESS_FLAG,'Y') AS STANDARD_PROCESS_FLAG
            ,NVL(APPROVAL_STATUS,'D') AS APPROVAL_STATUS
            ,PROCESSED_FLAG
            ,ERROR_FLAG
            ,INTERFACE_STATUS
            ,PROCESS_CATEGORY
            ,NVL(REVISE_PROCESS_FLAG,'R') AS REVISE_PROCESS_FLAG
            ,PARENT_PROCESS_NAME
            ,PROCESS_DISPLAY_NAME
            ,PARENT_PROCESS_ID
            ,PROCESS_TYPE
            ,CONTROL_ACTIVITY_TYPE
            ,PROCESS_CODE
            ,PROCESS_SEQUENCE_NUMBER
            ,PARENT_PROCESS_CODE
            ,ATTACHMENT_URL
			,CERTIFICATION_STATUS
			---12.29.2004 NPANANDI: ADDED STD VAR d COLS
			,STANDARD_VARIATION
			,CLASSIFICATION
			---04.22.2005 npanandi: added 3 owner columns below
			,process_owner_id
			,finance_owner_id
			,application_owner_id
		FROM AMW_PROCESSES_INTERFACE
	   WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
         AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
         AND processed_flag IS NULL
         AND error_flag IS NULL
       order by process_interface_id asc;

   CURSOR C_CREATE_LINKS IS
      SELECT BATCH_ID
            ,PROCESS_INTERFACE_ID
            ,PROCESSED_FLAG
            ,ERROR_FLAG
            ,INTERFACE_STATUS
            ,NVL(REVISE_PROCESS_FLAG,'R') AS REVISE_PROCESS_FLAG
            ,PARENT_PROCESS_NAME
            ,PROCESS_DISPLAY_NAME
            ,PARENT_PROCESS_ID
            ,PROCESS_TYPE
            ,PROCESS_CODE
            ,NVL(PROCESS_SEQUENCE_NUMBER,-100) AS PROCESS_SEQUENCE_NUMBER
            ,PARENT_PROCESS_CODE
		FROM AMW_PROCESSES_INTERFACE
	   WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
         AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
         AND processed_flag IS NULL
         AND error_flag IS NULL
       order by process_interface_id asc;

   CURSOR C_CREATE_APPROVALS IS
      SELECT BATCH_ID
	        ,PROCESS_INTERFACE_ID
			,PROCESSED_FLAG
			,ERROR_FLAG
			,INTERFACE_STATUS
			,NVL(REVISE_PROCESS_FLAG,'R') AS REVISE_PROCESS_FLAG
            ,PARENT_PROCESS_NAME
            ,PROCESS_DISPLAY_NAME
            ,PARENT_PROCESS_ID
            ,PROCESS_TYPE
            ,PROCESS_CODE
            ,NVL(PROCESS_SEQUENCE_NUMBER,-100) AS PROCESS_SEQUENCE_NUMBER
            ,PARENT_PROCESS_CODE
			,NVL(APPROVAL_STATUS,'D') AS APPROVAL_STATUS
	    FROM AMW_PROCESSES_INTERFACE
	   WHERE CREATED_BY=DECODE(p_user_id, NULL, created_by, p_user_id)
	     AND  batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
         AND processed_flag IS NULL
         AND error_flag IS NULL
       order by process_interface_id asc;

   e_no_import_access              EXCEPTION;
   e_invalid_risk_type             EXCEPTION;
   e_inv_parent_prc_hier           EXCEPTION;
   e_process_exist_no_update       EXCEPTION;
   e_synch_hierarchy_amw_process   Exception;
   E_PRC_CODE					   EXCEPTION;
   E_INTF_HIER_INV				   EXCEPTION;
   E_PRC_APPR_INV				   EXCEPTION;

   L_PROCESS_REC				   AMW_PROCESS_REC;

   l_amw_delt_process_intf		   VARCHAR2(2);
   l_process_flag				   VARCHAR2(1);

   L_PROCESS_ITEM_TYPE			   VARCHAR2(8);
   L_PARENT_PROCESS_ITEM_TYPE	   VARCHAR2(8);
   L_PROCESS_CODE				   VARCHAR2(80);
   L_PARENT_PROCESS_CODE		   VARCHAR2(80);
   L_PROCESS_ID			   		   NUMBER;
   L_PARENT_PROCESS_ID			   NUMBER;
   L_INTF_ID					   NUMBER;
   L_PROCESS_SEQUENCE_NUMBER	   NUMBER;
   L_PROCESS_APPROVAL_STATUS	   VARCHAR2(1);
   L_REVISE_FLAG				   VARCHAR2(1);

   L_HIER_DENORM_CHK			   NUMBER;

   L_ENBL_AUTO_APPR				   VARCHAR2(1);
   L_GET_PARAM					   VARCHAR2(1);
   L_PRC_APPR_CHK_FAILS			   BOOLEAN;

   lx_return_status                VARCHAR2(30);
   lx_msg_count                    NUMBER;
   lx_msg_data                     VARCHAR2(2000);

   ---03.02.2005 npanandi: added below variable for data security
   l_has_access                    varchar2(15) := 'T';
   l_count_processes			   number := 0;

   ---05.11.2005 npanandi: added below variable for check before Approving
   l_db_proc_appr_status           varchar2(1);
   l_db_process_display_name       varchar2(80);
BEGIN
   fnd_file.put_line (fnd_file.LOG, 'resp id: '||fnd_global.RESP_ID);
   fnd_file.put_line (fnd_file.LOG, 'resp appl id: '||fnd_global.RESP_APPL_ID);
   fnd_file.put_line (fnd_file.LOG, 'Batch_Id: '||p_batch_id);
   -- Check that User has access to Process Import Functionality

   ---05.11.2005 npanandi: included the below statement to count
   ---the initial # of processes in the system, prior to the current upload
   select count(process_id) into l_count_processes from amw_process_vl;
   fnd_file.put_line(fnd_file.LOG, '********* Initial # of Processes, prior to this Upload: '||l_count_processes||' *********' );
   ---05.11.2005 npanandi: ends above statement

   IF not Check_Function_Security('AMW_ALLOW_PROCESS_CREATION') THEN
      RAISE e_no_import_access;
   END IF;

   ---CHECK FOR PROCESS_CODE ENTERED WHEN PRC EXISTS AND REVISE FLAG='Y'
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: hierarchy Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   POPULATE_INTF_TBL(P_BATCH_ID => P_BATCH_ID);

   L_INTF_ID := GET_INV_PRC_CODE_ROW(P_BATCH_ID);
   IF(L_INTF_ID <> 0)THEN
      --THIS MEANS THAT USER ENTERED UNACCEPTABLE VALUES
	  --HENCE, SHOUT, KICK, AND SCREAM!!!
	  RAISE E_PRC_CODE;
   END IF;

   ---NEW_PARENT_PROCESSES_CHECK
   ---THIS CHECKS THE FACT THAT ALL NEW PARENT PROCESSES
   ---DEFINED IN THE SPREADSHEET FOR THE 1ST TIME ALSO NEED TO BE DEFINED
   ---AS PROCESSES IN THE SAME SPREADSHEET FOR THE SAME UPLOAD ...
   ---THROWS ERROR, OTHERWISE
   If (New_Parent_Processes_Check(p_batch_id) = false) THEN
      v_error_found := true;
	  fnd_message.set_name('AMW','AMW_NEW_PROC_NOT_CHILD');
	  fnd_message.set_token('PROCESS',v_parent_process_error);
	  v_err_msg := fnd_message.get;
	  ---fnd_file.put_line(fnd_file.LOG,'fnd_message.set_name brings: '||v_err_msg);
      raise e_inv_parent_prc_hier;
   END IF;

   ---FIRST DO HIERARCHY CHECKS
   FOR PROCESS_REC IN C_GET_INTF_DATA LOOP
      L_PROCESS_CODE  		:= PROCESS_REC.PROCESS_CODE;
	  L_PARENT_PROCESS_CODE := PROCESS_REC.PARENT_PROCESS_CODE;

      --SET THESE VALUES TO NULL FOR THIS PARTICULAR LOOP,
	  --LEST PARAM VALUES GET CORRUPTED ....
	  L_PROCESS_ID := NULL;
	  L_PROCESS_ITEM_TYPE := NULL;
	  L_PARENT_PROCESS_ID := NULL;
	  L_PARENT_PROCESS_ITEM_TYPE := NULL;

	  begin
	     SELECT PROCESS_ID,ITEM_TYPE
	       INTO L_PROCESS_ID,L_PROCESS_ITEM_TYPE
		   FROM AMW_PROCESS_VL
	      WHERE END_DATE IS NULL
	        AND PROCESS_CODE=L_PROCESS_CODE;
	  exception
        when no_data_found then
		   null;
      end;

      begin
         SELECT PROCESS_ID,ITEM_TYPE
	       INTO L_PARENT_PROCESS_ID,L_PARENT_PROCESS_ITEM_TYPE
		   FROM AMW_PROCESS_VL
	      WHERE END_DATE IS NULL
	        AND PROCESS_CODE=L_PARENT_PROCESS_CODE;
      exception
         when no_data_found then
		    null;
      end;

	  find_parent_process_v(
	     p_process_code  	   => L_PROCESS_CODE
        ,p_parent_process_code => L_PROCESS_CODE
        ,p_batch_id            => p_batch_id);

	  IF(V_INTF_HIERARCHY_INV = 'Y') THEN
         v_interface_id := PROCESS_REC.PROCESS_INTERFACE_ID;
		 RAISE E_INTF_HIER_INV;
      END IF;

	  --only here check the denorm table
	  IF(L_PROCESS_ID IS NOT NULL AND L_PARENT_PROCESS_ID IS NOT NULL)THEN
	     ---BOTH PROCESS AND PARENT EXIST, SO CHECK UPWARDS HIERARCHY IN DENORM
		 L_HIER_DENORM_CHK := null;
		 BEGIN
		    SELECT 1
		      INTO L_HIER_DENORM_CHK
		      FROM AMW_PROC_HIERARCHY_DENORM
		     WHERE PARENT_CHILD_ID=L_PARENT_PROCESS_ID
		       AND PROCESS_ID=L_PROCESS_ID
			   AND UP_DOWN_IND='D';
		 EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			   NULL;
		 END;

	     IF(L_HIER_DENORM_CHK IS NOT NULL AND L_HIER_DENORM_CHK=1) THEN
		    v_interface_id := PROCESS_REC.PROCESS_INTERFACE_ID;
		    RAISE E_INTF_HIER_INV;
		 END IF;
	  END IF;
   END LOOP;
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: hierarchy End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: insert records Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   FOR INSERT_REC IN C_GET_INTF_ROWS LOOP
      ---HERE IF ALL ABOVE CHECKS ARE FINE, THEN ALL PROCESS CODES,
	  ---PROCESS DISPLAY NAMES AND THE PROCESS ITEM TYPES ARE KNOWN
	  --- .... SO START PROCESSING, WE HAVE TO WORRY ONLY ABOUT THE
	  ---PROCESS AND IT'S ATTRIBUTES HERE, NOT CARE FOR THE
	  ---PARENT PROCESS ASSOCIATIONS YET

	  --SET THESE VALUES TO NULL FOR THIS PARTICULAR LOOP,
	  --LEST PARAM VALUES GET CORRUPTED ....
	  L_PROCESS_CODE := NULL;
	  L_PARENT_PROCESS_CODE := NULL;
	  L_PROCESS_ID := NULL;
	  L_PROCESS_ITEM_TYPE := NULL;
	  L_PARENT_PROCESS_ID := NULL;
	  L_PARENT_PROCESS_ITEM_TYPE := NULL;
	  L_PROCESS_CODE := INSERT_REC.PROCESS_CODE;
	  L_PARENT_PROCESS_CODE := INSERT_REC.PARENT_PROCESS_CODE;

	  BEGIN
	     SELECT PROCESS_ID,ITEM_TYPE
	       INTO L_PROCESS_ID,L_PROCESS_ITEM_TYPE
		   FROM AMW_PROCESS_VL
	      WHERE END_DATE IS NULL
	        AND PROCESS_CODE=L_PROCESS_CODE;
	  EXCEPTION
        when no_data_found then
           null;
      END;

	  BEGIN
	     SELECT PROCESS_ID,ITEM_TYPE
	       INTO L_PARENT_PROCESS_ID,L_PARENT_PROCESS_ITEM_TYPE
		   FROM AMW_PROCESS_VL
	      WHERE END_DATE IS NULL
	        AND PROCESS_CODE=L_PARENT_PROCESS_CODE;
	  EXCEPTION
        when no_data_found then
           null;
      END;
	  L_PROCESS_REC.SIGNIFICANT_PROCESS_FLAG := INSERT_REC.SIGNIFICANT_PROCESS_FLAG;
	  L_PROCESS_REC.STANDARD_PROCESS_FLAG    := INSERT_REC.STANDARD_PROCESS_FLAG;
	  L_PROCESS_REC.CERTIFICATION_STATUS     := INSERT_REC.CERTIFICATION_STATUS;
	  L_PROCESS_REC.PROCESS_CATEGORY         := INSERT_REC.PROCESS_CATEGORY;
	  L_PROCESS_REC.PROCESS_TYPE             := INSERT_REC.PROCESS_TYPE;
	  L_PROCESS_REC.CONTROL_ACTIVITY_TYPE    := INSERT_REC.CONTROL_ACTIVITY_TYPE;
	  L_PROCESS_REC.DISPLAY_NAME             := INSERT_REC.PROCESS_DISPLAY_NAME;
	  L_PROCESS_REC.ATTACHMENT_URL           := INSERT_REC.ATTACHMENT_URL;
	  ---12.29.2004 NPANANDI: ADDED STD VAR d ATTRIBUTES
	  L_PROCESS_REC.STANDARD_VARIATION       := INSERT_REC.STANDARD_VARIATION;
	  L_PROCESS_REC.CLASSIFICATION           := INSERT_REC.CLASSIFICATION;
	  --04.22.2005 npanandi: added 3 owner columns below
	  l_process_rec.process_owner_id         := insert_rec.process_owner_id;
	  l_process_rec.finance_owner_id         := insert_rec.finance_owner_id;
	  l_process_rec.application_owner_id     := insert_rec.application_owner_id;

	  IF(L_PROCESS_ID IS NULL) THEN
	     L_PROCESS_REC.ITEM_TYPE := 'AUDITMGR';
	     --L_PROCESS_REC.NAME      := '';
	     L_PROCESS_REC.PROCESS_CODE := INSERT_REC.PROCESS_CODE;
	     L_PROCESS_REC.REVISION_NUMBER := 1;
	     --hard code all approval statuses for now to D
		 L_PROCESS_REC.APPROVAL_STATUS := 'D';
	     L_PROCESS_REC.START_DATE := SYSDATE;

		 ---begin
		    --SET THESE VALUES APPROPRIATELY ....
		    lx_return_status := FND_API.G_RET_STS_SUCCESS;
		    LX_MSG_COUNT := NULL;
		    LX_MSG_DATA  := NULL;

	        INSERT_AMW_PROCESS(
		       P_PROCESS_REC   => L_PROCESS_REC
			  ,X_RETURN_STATUS => LX_RETURN_STATUS
			  ,X_MSG_COUNT     => LX_MSG_COUNT
			  ,X_MSG_DATA      => LX_MSG_DATA
		    );

			IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
	           v_err_msg := ' ';
	           FOR x IN 1..lx_msg_count LOOP
	              if(length(v_err_msg) < 1800) then
	                 v_err_msg := v_err_msg||' '||substr(fnd_msg_pub.get(p_msg_index => x,
					           p_encoded => fnd_api.g_false), 1,100);
	              end if;
	           END LOOP;
			   update_interface_with_error (v_err_msg
                                           ,'AMW_PROCESS_VL'
                                           ,INSERT_REC.PROCESS_INTERFACE_ID);
	     END IF;
      END IF;

      ---03.02.2005 npanandi: added check in the IF condition for v_error_found
	  IF(L_PROCESS_ID IS NOT NULL AND INSERT_REC.REVISE_PROCESS_FLAG='R' and not v_error_found) THEN
	     --THIS PROCESS EXISTS, SO REVISE, IF NECESSARY, AND THEN UPDATE ...
		 AMW_RL_HIERARCHY_PKG.REVISE_PROCESS_IF_NECESSARY(
		    P_PROCESS_ID => L_PROCESS_ID
		 );

		 L_PROCESS_REC.PROCESS_ID := L_PROCESS_ID;
		 --ACTUALLY SET THE APPROVAL STATUS AS WELL TO DRAFT ....
		 --IT DOES NOT MATTER HERE WHAT IS THE USER ENTERED APPROVAL STATUS
		 --SINCE APPROVALS ARE TAKEN CARE OF TOWARDS THE END
		 L_PROCESS_REC.APPROVAL_STATUS := 'D';
         --SET THESE VALUES APPROPRIATELY ....
		 lx_return_status := FND_API.G_RET_STS_SUCCESS;
		 LX_MSG_COUNT := NULL;
		 LX_MSG_DATA  := NULL;

         l_has_access := 'T';

		 ---04.22.2005 npanandi: commented the below to remove
		 ---                     security check during updates
		 /**
         l_has_access := check_function(
                            p_function           => 'AMW_UPD_RL_PROC'
                           ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                           ,p_instance_pk1_value => L_PROCESS_ID
                           ,p_user_id            => fnd_global.user_id);

          IF l_has_access <> 'T' then
             v_err_msg := 'Cannot update this Process';
			 update_interface_with_error (v_err_msg
                                         ,'AMW_PROCESS_VL'
			                             ,INSERT_REC.PROCESS_INTERFACE_ID);
         END IF;
		 **/
         ---04.22.2005 npanandi: ends security check commenting out

         ---03.02.2005 npanandi: add check for update depending on access privilege
         if(l_has_access = 'T')then
		    UPD_AMW_PROCESS(
		       P_PROCESS_REC => L_PROCESS_REC
		      ,X_RETURN_STATUS => LX_RETURN_STATUS
		      ,X_MSG_COUNT     => LX_MSG_COUNT
		      ,X_MSG_DATA      => LX_MSG_DATA
		    );

		    IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
               v_err_msg := ' ';
               FOR x IN 1..lx_msg_count LOOP
                  if(length(v_err_msg) < 1800) then
                     v_err_msg := v_err_msg||' '||substr(fnd_msg_pub.get(p_msg_index => x,
				              p_encoded => fnd_api.g_false), 1,100);
                  end if;
               END LOOP;
		       update_interface_with_error (v_err_msg
                                           ,'AMW_PROCESS_VL'
                                           ,INSERT_REC.PROCESS_INTERFACE_ID);
	        END IF;
	     end if; ---end of if l_has_access access privilege check
      END IF;
	  -- deletion is really deletion of a process d
	  -- link --> stands to reason that parent_process_code is needed
	  -- for a delete
	  ---03.02.2005 npanandi: added check in the IF condition for v_error_found
	  IF(L_PROCESS_ID IS NOT NULL AND L_PARENT_PROCESS_ID IS NOT NULL AND INSERT_REC.REVISE_PROCESS_FLAG='D' and not v_error_found) THEN
	     --SET THESE VALUES APPROPRIATELY ....
		 lx_return_status := FND_API.G_RET_STS_SUCCESS;
		 LX_MSG_COUNT := NULL;
		 LX_MSG_DATA  := NULL;
		 AMW_RL_HIERARCHY_PKG.DELETE_CHILD(
		    P_PARENT_PROCESS_ID => L_PARENT_PROCESS_ID
		   ,P_CHILD_PROCESS_ID  => L_PROCESS_ID
		   ,X_RETURN_STATUS     => LX_RETURN_STATUS
		   ,X_MSG_COUNT         => LX_MSG_COUNT
		   ,X_MSG_DATA          => LX_MSG_COUNT);
	  END IF;
   END LOOP;
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: insert records End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   --OPEN ANOTHER LOOP HERE FOR DOING THE HIERARCHY LINKS ...
   --INSERT A ROW IN

   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: create links Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   FOR INSERT_LINKS IN C_CREATE_LINKS LOOP
      --SET THESE VALUES TO NULL FOR THIS PARTICULAR LOOP,
	  --LEST PARAM VALUES GET CORRUPTED ....
	  L_PROCESS_CODE := NULL;
	  L_PROCESS_ID := NULL;
	  L_PROCESS_ITEM_TYPE := NULL;
	  L_PARENT_PROCESS_ID := NULL;
	  L_PARENT_PROCESS_ITEM_TYPE := NULL;
	  L_PARENT_PROCESS_CODE := NULL;
	  L_PROCESS_SEQUENCE_NUMBER := NULL;

	  --NEED THE PROCESS CODES TO GET PRC_ID d ....
	  L_PROCESS_CODE := INSERT_LINKS.PROCESS_CODE;
	  L_PARENT_PROCESS_CODE := INSERT_LINKS.PARENT_PROCESS_CODE;
	  L_PROCESS_SEQUENCE_NUMBER := INSERT_LINKS.PROCESS_SEQUENCE_NUMBER;
	  BEGIN
	     SELECT PROCESS_ID,ITEM_TYPE
	       INTO L_PROCESS_ID,L_PROCESS_ITEM_TYPE
		   FROM AMW_LATEST_REVISIONS_v
	      WHERE PROCESS_CODE=L_PROCESS_CODE;
	  EXCEPTION
        when no_data_found then
           null;
      END;

      BEGIN
	     SELECT PROCESS_ID,ITEM_TYPE
	       INTO L_PARENT_PROCESS_ID,L_PARENT_PROCESS_ITEM_TYPE
		   FROM AMW_LATEST_REVISIONS_v
	      WHERE PROCESS_CODE=L_PARENT_PROCESS_CODE;
	  EXCEPTION
        when no_data_found then
           null;
      END;

      --CALLING BELOW PROCEDURE TO ADD LINKS
	  --SET THESE VALUES APPROPRIATELY ....
	  lx_return_status := FND_API.G_RET_STS_SUCCESS;
	  LX_MSG_COUNT := NULL;
	  LX_MSG_DATA  := NULL;
	  --THE BELOW METHOD HAS BEEN ADDED BY NPANANDI
	  --IT IS THE SAME AS ADD_EXISTING_PROCESS_AS_CHILD ...
	  ---03.02.2005 npanandi: added check for v_error_found below
	  if(L_PARENT_PROCESS_ID is not null and L_PROCESS_ID is not null and INSERT_LINKS.revise_process_flag='R' and not v_error_found)then
         AMW_RL_HIERARCHY_PKG.add_WEBADI_HIERARCHY_LINKS(
	        P_CHILD_ORDER_NUMBER => L_PROCESS_SEQUENCE_NUMBER
           ,P_PARENT_PROCESS_ID  => L_PARENT_PROCESS_ID
           ,P_CHILD_PROCESS_ID   => L_PROCESS_ID
           ,X_RETURN_STATUS      => LX_RETURN_STATUS
           ,X_MSG_COUNT          => LX_MSG_COUNT
           ,X_MSG_DATA           => LX_MSG_DATA);
      end if;
   END LOOP;
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: create links End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   ---03.02.2005 npanandi: added check in the IF condition for v_error_found
   ---call updateDenorm  only if no errors encountered
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: update denorm, count Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   if(not v_error_found)then
      ---calling Nirman's procedure to update denorm tbl
      AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => -1);

      ---nirman's update latest ctrl, risk API called here ...
      AMW_RL_HIERARCHY_PKG.update_all_latest_rc_counts(p_mode => 'RC');
   end if;
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: update denorm, count End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   ---do the approval related stuff here ....
   ---check to see what is the option given here
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: insert Approvals Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   FOR INSERT_APPR IN C_CREATE_APPROVALS LOOP
      L_PROCESS_CODE             := NULL;
	  L_PROCESS_ID 				 := NULL;
	  L_PROCESS_ITEM_TYPE 		 := NULL;
	  L_PARENT_PROCESS_ID 		 := NULL;
	  L_PARENT_PROCESS_ITEM_TYPE := NULL;
	  L_PARENT_PROCESS_CODE 	 := NULL;
	  L_PROCESS_SEQUENCE_NUMBER  := NULL;
	  L_PROCESS_APPROVAL_STATUS  := NULL;

	  L_PROCESS_CODE            := INSERT_APPR.PROCESS_CODE;
	  L_PARENT_PROCESS_CODE 	:= INSERT_APPR.PARENT_PROCESS_CODE;
	  L_PROCESS_APPROVAL_STATUS := INSERT_APPR.APPROVAL_STATUS;
	  L_INTF_ID 				:= INSERT_APPR.PROCESS_INTERFACE_ID;
	  L_REVISE_FLAG 			:= INSERT_APPR.REVISE_PROCESS_FLAG;

	  L_ENBL_AUTO_APPR := AMW_UTILITY_PVT.GET_PARAMETER(-1,'PROCESS_AUTO_APPROVE');
	  L_GET_PARAM := AMW_UTILITY_PVT.GET_PARAMETER(-1,'PROCESS_APPROVAL_OPTION'); --A currently

	  --CHECK FOR APPROVAL_STATUS
	  --CHECK FOR Enable Automatic Approval PARAMETER VALUE
	  --FOR NOW HARDCODED TO 'Y' OR 'N' FOR TESTING'

	  --NOTE THAT FOR 'N' THERE NEED BE NO CHANGE SINCE USER DATA GETS
	  --UPLOADED IN DRAFT STATUS, REGARDLESS OF USER' ENTERED VALUE
	  IF(L_PROCESS_APPROVAL_STATUS = 'A' AND L_ENBL_AUTO_APPR = 'Y' AND L_REVISE_FLAG='R') THEN
	    --IF APPR CHOICE CASE CORRESPONDS TO:
		--    1)APPROVE EVERYTHING BELOW     	--> A
		--    2)APPRV THE procedure INDPNDNTLY	--> B
		--    3)DON'T APPR UNLESS EVERYTHING
		--      BELOW IS APPRVD					--> C
		l_prc_appr_chk_fails := prc_appr_chk_fails(
		                           p_batch_id => insert_appr.batch_id
								  ,p_process_interface_id => insert_appr.process_interface_id);

		IF(L_GET_PARAM = 'C' AND L_PRC_APPR_CHK_FAILS)THEN
		   RAISE E_PRC_APPR_INV;
		ELSE
		   BEGIN
		      ---05.11.2005 npanandi: added approval_status below
			  ---for use in call to WebADIApprove procedure
	          SELECT PROCESS_ID,ITEM_TYPE,approval_status,display_name
	            INTO L_PROCESS_ID,L_PROCESS_ITEM_TYPE,l_db_proc_appr_status,l_db_process_display_name
		        FROM AMW_LATEST_REVISIONS_v
	           WHERE PROCESS_CODE=L_PROCESS_CODE;
	       EXCEPTION
              when no_data_found then
                 null;
           END;

           --03.02.2005 npanandi: added below check for v_error_found
		   ---fnd_file.put_line(fnd_file.log, 'display_name: '||l_db_process_display_name||', l_db_proc_appr_status: '||l_db_proc_appr_status );
           if(not v_error_found and l_db_proc_appr_status = 'D')then
		      BEGIN
			     /*fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: sub_for_approval Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
		         AMW_PROC_APPROVAL_PKG.SUB_FOR_APPROVAL(p_process_id => L_PROCESS_ID,p_webadi_call => 'Y');
				 fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: sub_for_approval End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

				 fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: approve Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
		         AMW_PROC_APPROVAL_PKG.APPROVE(P_PROCESS_ID => L_PROCESS_ID);
				 fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: approve End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
				 */
				 ---fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: webadi_approve Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
				 amw_proc_approval_pkg.WEBADI_APPROVE(
				    p_process_id    => l_process_id
                   ,p_approv_choice => l_get_param);
				 ---fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: webadi_approve End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
		      EXCEPTION
		         WHEN OTHERS THEN
			        v_err_msg := 'unexpected EXCEPTION in create_processes: '||sqlerrm;
				    v_table_name := 'AMW_PROCESS';
                    update_interface_with_error (v_err_msg,v_table_name,L_INTF_ID);
			        fnd_file.put_line (fnd_file.LOG, 'unexpected EXCEPTION in create_processes: '||sqlerrm);
		      END;
		    end if; --03.02.2005 npanandi: end of v_error_found check
         END IF; --END OF CHK FOR PARAM d DOWNWARD HIER CHK
	  END IF; --END OF CHK FOR APPR_STATUS=A, REVISE_FLAG='R', ENBL_AUTO_APPR='Y'
   END LOOP;
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: insert Approvals End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: write approved hierarchy Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   ---05.11.2005 npanandi: added below as a one time call, instead of per-row
   amw_proc_approval_pkg.write_approved_hierarchy(p_step => 4);
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: write approved hierarchy End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: update approved denorm Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   amw_rl_hierarchy_pkg.update_approved_denorm(-1);
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: update approved denorm End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );

   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: update approved Risk/Ctrl count Start '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   amw_rl_hierarchy_pkg.update_appr_control_counts;
   amw_rl_hierarchy_pkg.update_appr_risk_counts;
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: update approved Risk/Ctrl count End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );
   ---05.11.2005 npanandi: ends above change
   fnd_file.put_line(fnd_file.LOG, 'TIMECHECK: new procedures End '||to_char(sysdate,'DD-MON-YYYY  HH24:MI:SS') );


--
--   get profile info FOR deleting records from interface table
--
   l_amw_delt_process_intf := NVL(fnd_profile.VALUE ('AMW_DELT_PROCESS_INTF'), 'N');
   IF v_error_found THEN
      ---Commenting the rollback FOR now ....
      ---ROLLBACK;
	  l_process_flag := NULL;
   ELSE
      l_process_flag := 'Y';
   END IF;

   IF UPPER (l_amw_delt_process_intf) <> 'Y' THEN
      BEGIN
	     UPDATE amw_processes_interface
            SET processed_flag = l_process_flag
               ,last_update_date = SYSDATE
               ,last_updated_by = v_user_id
          WHERE batch_id = p_batch_id;
      EXCEPTION
	     WHEN OTHERS THEN
		    fnd_file.put_line (fnd_file.LOG,'err in update process flag: '||SUBSTR (SQLERRM, 1,200));
      END;
   ELSE
      IF NOT v_error_found THEN
	     BEGIN
		   DELETE FROM amw_processes_interface WHERE batch_id = p_batch_id;
         EXCEPTION
		   WHEN OTHERS THEN
		     fnd_file.put_line (fnd_file.LOG,'err in delete interface records: '||SUBSTR (SQLERRM,1, 200));
         END;
      END IF;
   END IF;


--
--   get profile info FOR null control names and descriptions
--
--
--   LOOP processing each record
--
   /***

			***/
--
-- check profile option FOR (deletion of interface record,
-- when the value is 'N', otherwise
-- set processed flag to 'Y', and update record
--

   EXCEPTION
      WHEN E_INTF_HIER_INV THEN
	    BEGIN
		   UPDATE AMW_PROCESSES_INTERFACE
		      SET ERROR_FLAG='Y'
			     ,INTERFACE_STATUS='Upwards Interface hierarchy defined for this Process is Invalid'
			WHERE PROCESS_INTERFACE_ID=V_INTERFACE_ID;
		EXCEPTION
		   WHEN OTHERS THEN
			   FND_FILE.PUT_LINE(FND_FILE.LOG,'unexpected exception in handling E_INTF_HIER_INV');
		END;

      WHEN E_PRC_CODE THEN
	     BEGIN
		   UPDATE AMW_PROCESSES_INTERFACE
		      SET ERROR_FLAG='Y'
			     ,INTERFACE_STATUS='Please enter valid Process Code for this new Process'
			WHERE PROCESS_INTERFACE_ID=L_INTF_ID;
         EXCEPTION
		    WHEN OTHERS THEN
			   FND_FILE.PUT_LINE(FND_FILE.LOG,'unexpected exception in handling E_PRC_CODE');
		 END;

	  WHEN E_PRC_APPR_INV THEN
	     BEGIN
		   UPDATE AMW_PROCESSES_INTERFACE
		      SET ERROR_FLAG='Y'
			     ,INTERFACE_STATUS='Process Approval status is Draft for Process(es)
below this Process in the Risk Library'
			WHERE PROCESS_INTERFACE_ID=L_INTF_ID;
         EXCEPTION
		    WHEN OTHERS THEN
			   FND_FILE.PUT_LINE(FND_FILE.LOG,'unexpected exception in handling E_PRC_APPR_INV');
		 END;

      when e_synch_hierarchy_amw_process THEN
         BEGIN
         ---rollback;
            UPDATE amw_processes_interface
            SET error_flag = 'Y'
                ,interface_status = v_err_msg
            WHERE batch_id = p_batch_id;
            EXCEPTION
            WHEN OTHERS THEN
            fnd_file.put_line (fnd_file.LOG, 'unexpected EXCEPTION in handling e_synch_hierarchy_amw_process: '||sqlerrm);
         END;

      when e_process_exist_no_update THEN
         BEGIN
            ---rollback;
            IF v_process_exist_no_update is null THEN
               v_process_exist_no_update := FND_MESSAGE.GET_STRING('AMW','AMW_PROCESS_EXIST');
            END IF;
            UPDATE amw_processes_interface
               SET error_flag = 'Y'
                  ,interface_status = v_process_exist_no_update
             WHERE batch_id = p_batch_id;
         EXCEPTION
            WHEN OTHERS THEN
            fnd_file.put_line (fnd_file.LOG, 'unexpected EXCEPTION in handling e_process_exist_no_update: '||sqlerrm);
         END;

      when e_inv_parent_prc_hier THEN
         --npanandi added following code to throw proper messages 02/18/2004
		 BEGIN
            IF v_invalid_hierarchy_msg is null THEN
               v_invalid_hierarchy_msg := FND_MESSAGE.GET_STRING('AMW','AMW_INVALID_HIERARCHY');
            END IF;
            UPDATE amw_processes_interface
               SET error_flag = 'Y'
                   ,interface_status = v_invalid_hierarchy_msg
             WHERE batch_id = p_batch_id;
			 ----and (not process_interface_id = v_interface_id);

            ---usability handling
			UPDATE amw_processes_interface
                SET error_flag = 'Y'
                    ---,interface_status = 'Invalid hierarchy FOR this row'
					,interface_status = v_err_msg
              WHERE batch_id = p_batch_id
			    and process_interface_id = v_new_parent_interface_id;

         EXCEPTION
             WHEN OTHERS THEN
              fnd_file.put_line (fnd_file.LOG, 'unexpected EXCEPTION in handling e_invalid_process_hierarchy: '||sqlerrm);
         END;

      WHEN e_no_import_access THEN
         BEGIN
            ---rollback;
            IF v_no_import_privilege_msg is null THEN
             v_no_import_privilege_msg := FND_MESSAGE.GET_STRING('AMW','AMW_NO_IMPORT_ACCESS');
            END IF;
            UPDATE amw_processes_interface
               SET error_flag = 'Y'
                  ,interface_status = v_no_import_privilege_msg
             WHERE batch_id = p_batch_id;
         EXCEPTION
            WHEN OTHERS THEN
               fnd_file.put_line (fnd_file.LOG, 'unexpected EXCEPTION in handling e_no_import_access: '||sqlerrm);
         END;
      WHEN others THEN
         rollback;
		 fnd_file.put_line (fnd_file.LOG, 'unexpected EXCEPTION in create_processes: '||sqlerrm);
   END create_processes;

---CHECKING FOR PROPER ENTRY OF PROCESS CODE
---WHEN PROCESS DISPLAY NAME EXISTS AND PROCESS CODE IS NULL
--AND REVISE FLAG IS YES
FUNCTION GET_INV_PRC_CODE_ROW(
   P_BATCH_ID IN NUMBER
) RETURN NUMBER
IS
   L_INTF_ID NUMBER;
BEGIN
   SELECT COUNT(*) INTO L_INTF_ID
     from amw_processes_interface api
    where (api.revise_process_flag='R'
       or API.REVISE_PROCESS_FLAG IS NULL)
      and api.process_code is null
      and api.batch_id=P_BATCH_ID
      and exists (select 1
	                from amw_latest_revisions_v
				   where display_name=api.process_display_name);

   IF(L_INTF_ID <> 0) THEN
      SELECT PROCESS_INTERFACE_ID INTO L_INTF_ID
        from amw_processes_interface api
       where (api.revise_process_flag='R'
          or API.REVISE_PROCESS_FLAG IS NULL)
         and api.process_code is null
         and api.batch_id=P_BATCH_ID
         and exists (select 1
	                   from amw_latest_revisions_v
				      where display_name=api.process_display_name)
         AND ROWNUM <=1;

   END IF;

   RETURN L_INTF_ID;
END GET_INV_PRC_CODE_ROW;

PROCEDURE POPULATE_INTF_TBL(
   P_BATCH_ID IN NUMBER
)
IS
   ---GET ALL ROWS WITH PROCESS CODE NULL, AND PROCESS NEW
   CURSOR C_GET_INTF_ROW IS
      SELECT PROCESS_INTERFACE_ID
	        ,PROCESS_CODE
			,PROCESS_DISPLAY_NAME
			,REVISE_PROCESS_FLAG
			,PARENT_PROCESS_CODE
			,PARENT_PROCESS_NAME
	    FROM AMW_PROCESSES_INTERFACE
	   WHERE BATCH_ID=P_BATCH_ID
	     AND PROCESS_CODE IS NULL
		 AND PROCESS_DISPLAY_NAME NOT IN (SELECT DISPLAY_NAME
		                                    FROM AMW_LATEST_REVISIONS_v);

   ---04.22.2005 npanandi: get all existing parent processes
   ---with null parent process codes
   cursor c_get_null_processes is
      select process_interface_id
	        ,parent_process_name
			,revise_process_flag
		from amw_processes_interface api
	   where batch_id = p_batch_id
	     and parent_process_code is null
		 and exists (select 1
		               from amw_latest_revisions_v
					  where display_name = api.parent_process_name);

   ---05.12.2005 npanandi: get all existing processes
   ---with null process codes
   cursor c_get_null_procs is
      select process_interface_id
	        ,process_display_name
			,revise_process_flag
		from amw_processes_interface api
	   where batch_id = p_batch_id
	     and process_code is null
		 and exists (select 1
		               from amw_latest_revisions_v
					  where display_name = api.process_display_name);
   L_INTF_ID  NUMBER;
   L_PRC_CODE VARCHAR2(80);
   L_DISP_NAME VARCHAR2(80);

   ---04.22.2005 npanandi: added below var for process_code of parent_process
   l_process_code varchar2(30);
BEGIN

   FOR PROCESS_REC IN C_GET_INTF_ROW LOOP
      L_DISP_NAME := PROCESS_REC.PROCESS_DISPLAY_NAME;
	  L_INTF_ID := PROCESS_REC.PROCESS_INTERFACE_ID;
	  ---putting an NVL, just in case,
	  ---since we cannot afford a NULL Process_Code!!
	  L_PRC_CODE :=  NVL(AMW_RL_HIERARCHY_PKG.get_process_code(),'AUTO: ');
	  --SET THE PROCESS CODE FOR THE ROW WITH
	  --NEW PROCESS NAME AND NULL PROCESS CODE
	  BEGIN
	     UPDATE AMW_PROCESSES_INTERFACE
	        SET PROCESS_CODE=L_PRC_CODE
	      WHERE PROCESS_INTERFACE_ID=L_INTF_ID
	        AND BATCH_ID=P_BATCH_ID;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    NULL;
		 WHEN OTHERS THEN
            v_err_msg := 'Error during package processing  '|| ' interface_id: = '||L_INTF_ID|| SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
	  END;

	  --CHECK WHERE THIS PROCESS APPEARS AS THE
	  --PARENT PROCESS FOR THE SAME UPL SPRDSHEET,
	  --AND SET THE PARENT PRC CODE FOR THIS ROW
	  --TO BE THE PROCESS CODE FOR THE ABOVE ROW
	  BEGIN
         UPDATE AMW_PROCESSES_INTERFACE
	        SET PARENT_PROCESS_CODE=L_PRC_CODE
	      WHERE BATCH_ID=P_BATCH_ID
	        AND PARENT_PROCESS_NAME=L_DISP_NAME;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    NULL;
		 WHEN OTHERS THEN
            v_err_msg := 'Error during package processing  '|| ' PARENT_PROCESS_NAME: = '|| L_DISP_NAME|| SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
	  END;
   END LOOP;

   ---04.22.2005 npanandi: added below to add process code for existing
   ---parent processes which do not have process code entered in the spreadsheet
   for c in c_get_null_processes loop
      l_process_code := null;
	  begin
         select process_code
           into l_process_code
           from amw_latest_revisions_v
          where display_name = c.parent_process_name;

	      ---do the update of the interface table here
	      update amw_processes_interface
	         set parent_process_code = l_process_code
		        ,last_update_date = sysdate
		   where process_interface_id = c.process_interface_id
		     and batch_id = p_batch_id;
      exception
	     when too_many_rows then
		    v_err_msg := 'Please select valid Parent Process Code for this Process';
		    update_interface_with_error (v_err_msg,v_table_name,L_INTF_ID);
		 when others then
		    fnd_file.put_line (fnd_file.LOG,'UNHANDLED EXCEPTION');
			v_err_msg := 'Please select valid Parent Process Code for this Process';
		    update_interface_with_error (v_err_msg,v_table_name,L_INTF_ID);
	  end;
   end loop;
   ---04.22.2005 npanandi: ends

   ---05.12.2005 npanandi: added below to add process_code for existing
   ---processes which do not have process code entered in the spreadsheet
   for c1 in c_get_null_procs loop
      l_process_code := null;
	  begin
	     select process_code
           into l_process_code
           from amw_latest_revisions_v
          where display_name = c1.process_display_name;

         ---do the update of the interface table here
	     update amw_processes_interface
	        set process_code = l_process_code
		       ,last_update_date = sysdate
		  where process_interface_id = c1.process_interface_id
		    and batch_id = p_batch_id;
	  exception
	     when too_many_rows then
		    v_err_msg := 'Please select valid Process Code for this Process';
		    update_interface_with_error (v_err_msg,v_table_name,L_INTF_ID);
		 when others then
		    fnd_file.put_line (fnd_file.LOG,'UNHANDLED EXCEPTION');
			v_err_msg := 'Please select valid Process Code for this Process';
		    update_interface_with_error (v_err_msg,v_table_name,L_INTF_ID);
	  end;
   end loop;
   ---05.12.2005 npanandi: ends
EXCEPTION
   WHEN OTHERS THEN
      fnd_file.put_line (fnd_file.LOG,'UNHANDLED EXCEPTION');
END POPULATE_INTF_TBL;

---
---Finding the upwards hierarchy in Amw_Processes_Interface table
---
PROCEDURE FIND_PARENT_PROCESS_V(P_PROCESS_CODE 		  IN VARCHAR2
                               ,P_PARENT_PROCESS_CODE IN VARCHAR2
                               ,P_BATCH_ID     		  IN NUMBER)
IS
  CURSOR C_PRNT_PRC_CODE IS
     SELECT PARENT_PROCESS_CODE
	       ,PROCESS_INTERFACE_ID
	   FROM AMW_PROCESSES_INTERFACE
	  WHERE PROCESS_CODE=P_PARENT_PROCESS_CODE
	    AND BATCH_ID=P_BATCH_ID;
BEGIN
   --check to see if this process_code exists in application
   --v_counter := v_counter+1;
   --fnd_file.put_line (fnd_file.LOG, '***** v_parent_process_code: '||v_parent_process_code);
   IF(    v_parent_process_CODE is null
      and PROCESS_CODE_EXISTS(p_PARENT_PROCESS_CODE =>P_PROCESS_CODE))then
      --add the first element
	  v_parent_process_CODE := P_PROCESS_CODE;
   end if;

   FOR GET_PRC_CODE IN C_PRNT_PRC_CODE LOOP
   EXIT WHEN C_PRNT_PRC_CODE%NOTFOUND;
      --fnd_file.put_line (fnd_file.LOG, '***** P_PROCESS_CODE: '||P_PROCESS_CODE||', GET_PRC_CODE.PARENT_PROCESS_CODE: '||GET_PRC_CODE.PARENT_PROCESS_CODE);
      IF(P_PROCESS_CODE = GET_PRC_CODE.PARENT_PROCESS_CODE)THEN
	     V_INTF_HIERARCHY_INV := 'Y';
		 EXIT;
	  elsif(PROCESS_CODE_EXISTS(p_PARENT_PROCESS_CODE => GET_PRC_CODE.PARENT_PROCESS_CODE))then
	    if(inv_hierarchy_EXISTS(p_PARENT_child_CODE => GET_PRC_CODE.PARENT_PROCESS_CODE,p_PROCESS_CODE => v_parent_process_CODE)) then
	        --check here to see if this parent_process_code exists as a
		    --child of the previous v_parent_process_CODE
		    V_INTF_HIERARCHY_INV := 'Y';
		    EXIT;
		 else
		    --next time, start off with the upwards hierarchy check
			--with this parent_process_code
		    --v_parent_process_code := GET_PRC_CODE.PARENT_PROCESS_CODE;
			--if (v_counter <= 100) then
		       FIND_PARENT_PROCESS_V(P_PROCESS_CODE   		=> P_PROCESS_CODE
	                                ,P_PARENT_PROCESS_CODE  => GET_PRC_CODE.PARENT_PROCESS_CODE
	                                ,P_BATCH_ID 			=> P_BATCH_ID);
		    --end if;
		 end if;
	  ELSE
	     FIND_PARENT_PROCESS_V(P_PROCESS_CODE   		=> P_PROCESS_CODE
	                          ,P_PARENT_PROCESS_CODE  	=> GET_PRC_CODE.PARENT_PROCESS_CODE
	                          ,P_BATCH_ID 				=> P_BATCH_ID);
		 --end if;
      END IF;
   END LOOP;
   v_parent_process_code := null;
END	FIND_PARENT_PROCESS_V;

/****
procedure find_parent_process(p_orig_process_display_name in VARCHAR2,
                              p_process_display_name 	  in VARCHAR2,
                              p_batch_id             	  in NUMBER,
                              p_interface_id       	 	  in NUMBER)
is
   cursor ct (l_process_display_name in VARCHAR2) is
      select parent_process_name
	        ,process_interface_id
        from amw_processes_interface
       where process_display_name = p_process_display_name
         and batch_id = p_batch_id;

   ct_rec ct%rowtype;
BEGIN
   v_parent_process_name(0) := p_orig_process_display_name;

   FOR ct_rec in ct(p_process_display_name) LOOP
      exit when ct%notfound;

      ---putting this to conserver hierarchy check
      IF((p_process_display_name = p_orig_process_display_name) And
         (p_interface_id <> ct_rec.process_interface_id)) THEN
         fnd_file.put_line(fnd_file.LOG,'Exiting from this LOOP since this is a dIFferent hierarchy FOR the same process being traversed');
         exit;
      END IF;
      ----END of check

      fnd_file.put_line(fnd_file.LOG,'p_orig_process_display_name:
'||p_orig_process_display_name||' p_process_display_name:
'||p_process_display_name||' p_interface_id: '||p_interface_id||'
process_interface_id: '||ct_rec.process_interface_id);
      IF(v_parent_process_name.exists(ct_rec.process_interface_id))THEN
         --this means that violation of interface hierarchy is detected.
         v_interface_hierarchy_error := 1;
         fnd_file.put_line(fnd_file.LOG,'EXITING from find_parent_process');
         exit;
      ELSE
         v_parent_process_name(ct_rec.process_interface_id) :=
ct_rec.parent_process_name;
         find_parent_process(p_orig_process_display_name     =>
p_orig_process_display_name,
                             p_process_display_name          =>
ct_rec.parent_process_name,
                             p_batch_id                      => p_batch_id,
                             p_interface_id               	 => p_interface_id);
      END IF;
   END LOOP;
END find_parent_process;
***/

--
-- procedure update_interface_with_error
--
--
   PROCEDURE update_interface_with_error (
      p_err_msg        IN   VARCHAR2
     ,p_table_name     IN   VARCHAR2
     ,p_interface_id   IN   NUMBER
   )
   IS
      l_interface_status   amw_processes_interface.interface_status%TYPE;
   BEGIN
      ----commenting this rollback FOR now
      ROLLBACK; -- rollback any inserts done during the current LOOP process
      v_error_found := TRUE;
      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_processes_interface
          WHERE process_interface_id = p_interface_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_err_msg :=
                   'interface_id: = '
                || p_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;

      BEGIN
         UPDATE amw_processes_interface
            SET interface_status =
                       l_interface_status
               --     || 'Error Msg: '
                    || p_err_msg
               --     || ' Table Name: '
               --     || p_table_name
                    || '**'
               ,error_flag = 'Y'
          WHERE process_interface_id = p_interface_id;

         fnd_file.put_line (fnd_file.LOG, SUBSTR (l_interface_status, 1, 200));
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_err_msg :=
                   'Error during package processing  '
                || ' interface_id: = '
                || p_interface_id
                || SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;
      COMMIT;
   END update_interface_with_error;



-- function to check the user access privilege
--
   FUNCTION Check_Function_Security(p_function_name IN varchar2) RETURN Boolean
   IS

   CURSOR c_func_exists IS
   SELECT 'Y'
   FROM fnd_responsibility r, fnd_compiled_menu_functions m, fnd_FORm_functions f
   WHERE r.responsibility_id = fnd_global.resp_id
   AND r.application_id=fnd_global.resp_appl_id
   AND r.menu_id = m.menu_id
   AND m.function_id = f.function_id
   AND f.function_name = p_function_name;

   CURSOR c_func_excluded IS
   SELECT 'Y'
   FROM fnd_resp_functions rf, fnd_FORm_functions f
   WHERE rf.application_id = fnd_global.resp_appl_id
   AND rf.responsibility_id = fnd_global.resp_id
   AND rf.rule_type = 'F'
   AND rf.action_id = f.function_id
   AND f.function_name = p_function_name;

   l_func_exists VARCHAR2(1);
   l_func_excluded VARCHAR2(1);
   BEGIN
      OPEN c_func_exists;
      FETCH c_func_exists INTO l_func_exists;
      IF c_func_exists%NOTFOUND THEN
      CLOSE c_func_exists;
         return FALSE;
      END IF;
      CLOSE c_func_exists;

      OPEN c_func_excluded;
      FETCH c_func_excluded INTO l_func_excluded;
      CLOSE c_func_excluded;

      IF l_func_excluded is not null THEN
         return FALSE;
      END IF;

      return TRUE;
   END Check_Function_Security;

-- function to check WHETHER PROCESS_CODE EXISTS IN THE APPLICATION OR NOT
--
   FUNCTION PROCESS_CODE_EXISTS(p_PARENT_PROCESS_CODE IN VARCHAR2) RETURN Boolean
   IS

   CURSOR c_PROCESS_CODE_EXISTS IS
      SELECT 'Y'
        FROM AMW_PROCESS_VL
       WHERE PROCESS_CODE=p_PARENT_PROCESS_CODE;

   l_CODE_exists VARCHAR2(1);
   l_func_excluded VARCHAR2(1);
   BEGIN
      OPEN c_PROCESS_CODE_EXISTS;
      FETCH c_PROCESS_CODE_EXISTS INTO l_CODE_exists;
      CLOSE c_PROCESS_CODE_EXISTS;

      IF l_CODE_exists is not null THEN
	     return TRUE;
      END IF;

	  return FALSE;
   END PROCESS_CODE_EXISTS;

-- function to check WHETHER invalid hierarchy exists
--
FUNCTION inv_hierarchy_EXISTS(
   p_PARENT_child_CODE IN VARCHAR2
  ,p_PROCESS_CODE IN VARCHAR2
) RETURN Boolean
IS

   CURSOR c_INV_HIER IS
      SELECT 'Y'
        FROM AMW_PROC_HIERARCHY_DENORM
       WHERE PROCESS_ID IN (SELECT PROCESS_ID
	                          FROM AMW_PROCESS_VL
							 WHERE PROCESS_CODE=p_PARENT_child_CODE)
	     AND PARENT_CHILD_ID IN (SELECT PROCESS_ID
		                           FROM AMW_PROCESS_VL
								  WHERE PROCESS_CODE=p_PROCESS_CODE)
         AND UP_DOWN_IND='U';

   l_INV_HIER_exists VARCHAR2(1);
   BEGIN
      OPEN c_INV_HIER;
      FETCH c_INV_HIER INTO l_INV_HIER_exists;
      CLOSE c_INV_HIER;

      IF ((l_INV_HIER_exists is not null)  AND (l_INV_HIER_exists='Y')) THEN
	     return TRUE;
      END IF;
	  return FALSE;
END inv_hierarchy_EXISTS;

FUNCTION PRC_APPR_CHK_FAILS(
   P_BATCH_ID 				IN NUMBER
  ,P_PROCESS_INTERFACE_ID 	IN NUMBER
) RETURN BOOLEAN

IS
   CURSOR C_INV_APPR IS
      SELECT distinct 'Y'
  FROM AMW_LATEST_REVISIONS_V ALRV
      ,AMW_PROC_HIERARCHY_DENORM APHD
 WHERE APHD.UP_DOWN_IND='D'
   AND ALRV.PROCESS_ID=APHD.PARENT_CHILD_ID
   AND APHD.PROCESS_ID IN (SELECT ALRV.PROCESS_ID
                             FROM AMW_LATEST_REVISIONS_V ALRV
                                 ,AMW_PROCESSES_INTERFACE API
                            WHERE API.PROCESS_INTERFACE_ID=P_PROCESS_INTERFACE_ID
                              AND API.PROCESS_CODE=ALRV.PROCESS_CODE
                              AND API.PROCESS_DISPLAY_NAME=ALRV.display_name)
   AND APHD.PARENT_CHILD_ID NOT IN (SELECT ALRV.PROCESS_ID
                                      FROM AMW_LATEST_REVISIONS_V ALRV
                                          ,AMW_PROCESSES_INTERFACE API
                                     WHERE API.BATCH_ID=P_BATCH_ID
                                       AND API.PROCESS_CODE=ALRV.PROCESS_CODE
                                       AND API.PROCESS_DISPLAY_NAME=ALRV.display_name
                                       AND API.APPROVAL_STATUS='A');

   L_INV_APPR VARCHAR2(1);
BEGIN
   OPEN C_INV_APPR;
      FETCH C_INV_APPR INTO L_INV_APPR;
   CLOSE C_INV_APPR;

   IF((L_INV_APPR IS NOT NULL) AND (L_INV_APPR = 'Y'))THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;
END PRC_APPR_CHK_FAILS;

PROCEDURE INSERT_AMW_PROCESS(
   P_PROCESS_REC IN AMW_PROCESS_REC
  ,X_RETURN_STATUS OUT NOCOPY VARCHAR2
  ,X_MSG_COUNT OUT NOCOPY NUMBER
  ,X_MSG_DATA OUT NOCOPY VARCHAR2
)
IS
   l_process_id number;
   l_process_rev_id number;
   l_process_name number;
   L_SEQ_NUM NUMBER;
   LX_MEDIA_ID NUMBER;
   LX_DOCUMENT_ID NUMBER;
   LX_ATTACHED_DOCUMENT_ID NUMBER;
   L_LANGUAGE VARCHAR2(30);

   LX_ROW_ID VARCHAR2(30);

   l_attachment_rec amw_attachment_pvt.fnd_attachment_rec_type;

   lX_return_status   varchar2(1);
   lX_msg_count       number;
   lX_msg_data        varchar2(2000);
   lx_index           number;

   ---12.29.2004 npanandi: addition of StdVariation flag
   l_standard_variation		 number;

   ---04.22.2005 npanandi: added vars below for profile option values
   l_amw_process_owner_col     varchar2(30);
   l_amw_application_owner_col varchar2(30);
   l_amw_finance_owner_col     varchar2(30);
BEGIN
   select amw_process_s.nextval into l_process_id from dual;
   select amw_process_s.nextval into l_process_rev_id from dual;

   --npanandi 12.01.2004: Name column is not null in fin115p2 hence adding below
   if(P_PROCESS_REC.name is null or trim(P_PROCESS_REC.name) = '') then
      select amw_process_name_s.nextval into l_process_name from dual;
   else
      l_process_name := P_PROCESS_REC.name;
   end if;

   ---12.29.2004 npanandi: check for StdVariation=NULL if Process is Std Process
   if(P_PROCESS_REC.standard_process_flag = 'Y')then
      l_standard_variation := NULL;
   else
      l_standard_variation := P_PROCESS_REC.standard_variation;
   end if;

   insert into amw_process (
		    PROCESS_ID,
            ITEM_TYPE,
            NAME,
            PROCESS_CODE,
            REVISION_NUMBER,
            PROCESS_REV_ID,
            APPROVAL_STATUS,
            START_DATE,
            SIGNIFICANT_PROCESS_FLAG,
            STANDARD_PROCESS_FLAG,
            CERTIFICATION_STATUS,
            PROCESS_CATEGORY,
            STANDARD_VARIATION,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
            PROCESS_TYPE,
            CONTROL_ACTIVITY_TYPE,
			---12.29.2004 NPANANDI: ADDED STD VAR d COLS
			CLASSIFICATION
	     ) VALUES (
		    l_process_id,
            P_PROCESS_REC.item_type,
            l_process_name,
            P_PROCESS_REC.process_code,
            1,
            l_process_rev_id,
            'D',
            sysdate,
            P_PROCESS_REC.significant_process_flag,
            P_PROCESS_REC.standard_process_flag,
            P_PROCESS_REC.certification_status,
            P_PROCESS_REC.process_category,
            l_standard_variation,
            sysdate,
            G_USER_ID,
            sysdate,
            G_USER_ID,
            G_LOGIN_ID,
            1,
            P_PROCESS_REC.process_type,
            P_PROCESS_REC.control_activity_type,
			---12.29.2004 NPANANDI: ADDED STD VAR d COLS
			P_PROCESS_REC.CLASSIFICATION
		 );

   insert into amw_process_names_tl (
          process_id
         ,revision_number
         ,process_rev_id
         ,display_name
         ,description
         ,language
         ,source_lang
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
		 ,object_version_number
   )
      select
          l_process_id
         ,1
         ,l_process_rev_id
         ,P_PROCESS_REC.display_name
         ,P_PROCESS_REC.description
         ,L.LANGUAGE_CODE
         ,USERENV('LANG')
         ,sysdate
         ,g_user_id
         ,sysdate
         ,g_user_id
         ,g_login_id
		 ,1
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B');

      ---04.22.2005 npanandi: commenting out below grants for now
      /**
	  add_owner_privilege(
         p_role_name          => 'AMW_RL_PROC_OWNER_ROLE'
        ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
		,p_grantee_type       => 'P'
		,p_instance_pk1_value => l_process_id
		,p_user_id            => FND_GLOBAL.USER_ID);
		**/
	  ---04.22.2005 npanandi: commented out above grants for now

	  ---04.22.2005 npanandi: added below grants bug 4323387
	  l_amw_process_owner_col := NVL(fnd_profile.VALUE ('AMW_PROC_IMP_PROC_OWNER_COL'),'AMW_RL_PROC_OWNER_ROLE');
	  if(p_process_rec.process_owner_id is not null) then
	     add_owner_privilege(
            p_role_name          => l_amw_process_owner_col
           ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
		   ,p_grantee_type       => 'P'
		   ,p_instance_pk1_value => l_process_id
		   ,p_party_id           => P_PROCESS_REC.process_owner_id);
	  end if;

	  if(p_process_rec.application_owner_id is not null) then
	     l_amw_application_owner_col := NVL(fnd_profile.VALUE ('AMW_PROC_IMP_APPL_OWNER_COL'),'AMW_RL_PROC_APPL_OWNER_ROLE');
		 add_owner_privilege(
            p_role_name          => l_amw_application_owner_col
           ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
		   ,p_grantee_type       => 'P'
		   ,p_instance_pk1_value => l_process_id
		   ,p_party_id           => P_PROCESS_REC.application_owner_id);
	  end if;

	  if(p_process_rec.finance_owner_id is not null) then
	     l_amw_finance_owner_col := NVL(fnd_profile.VALUE ('AMW_PROC_IMP_FINANCE_OWNER_COL'),'AMW_RL_PROC_FINANCE_OWNER_ROLE');
		 add_owner_privilege(
            p_role_name          => l_amw_finance_owner_col
           ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
		   ,p_grantee_type       => 'P'
		   ,p_instance_pk1_value => l_process_id
		   ,p_party_id           => P_PROCESS_REC.finance_owner_id);
	  end if;
	  ---04.22.2005 npanandi: ends bug 4323387 fix


   ---if(P_PROCESS_REC.ATTACHMENT_URL IS NOT NULL AND not (TRIM(P_PROCESS_REC.ATTACHMENT_URL)='')) THEN
   if(P_PROCESS_REC.ATTACHMENT_URL IS NOT NULL) THEN
      --SELECT FND_ATTACHED_DOCUMENTS_S.NEXTVAL INTO L_ATTACHED_DOCUMENT_ID FROM DUAL;
	  --SELECT fnd_documents_s.nextval INTO L_DOCUMENT_ID FROM DUAL;
      BEGIN
	     SELECT MAX(SEQ_NUM) INTO L_SEQ_NUM FROM FND_ATTACHED_DOCUMENTS WHERE ENTITY_NAME='AMW_PROCESS' AND PK1_VALUE=l_process_rev_id;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    L_SEQ_NUM := 0;
	     WHEN OTHERS THEN
		    L_SEQ_NUM := 0;
	  END;

	  L_SEQ_NUM := L_SEQ_NUM+1;

	  l_attachment_rec.description := 'AUTO: ';
	  l_attachment_rec.file_name := P_PROCESS_REC.ATTACHMENT_URL;
	  l_attachment_rec.datatype_id := 5;
	  l_attachment_rec.seq_num := l_seq_num;
	  l_attachment_rec.entity_name := 'AMW_PROCESS';
	  l_attachment_rec.pk1_value := to_char(L_PROCESS_REV_ID);
	  l_attachment_rec.automatically_added_flag := 'N';
	  l_attachment_rec.datatype_id := 5;
	  l_attachment_rec.category_id := 1;
	  l_attachment_rec.security_type := 4;
	  l_attachment_rec.publish_flag := 'Y';
	  l_attachment_rec.media_id := lx_media_id;

	  x_msg_data := null;
	  x_msg_count := 0;
	  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
	  AMw_ATTACHMENT_PVT.CREATE_FND_ATTACHMENT(
         p_api_version_number         => 1,
		 p_init_msg_list              => FND_API.G_TRUE,
         x_return_status              => X_RETURN_STATUS,
         x_msg_count                  => X_MSG_COUNT,
         x_msg_data                   => X_MSG_DATA,
         p_Fnd_Attachment_rec         => l_attachment_rec,
         x_document_id                => LX_DOCUMENT_ID,
         x_attached_document_id       => LX_ATTACHED_DOCUMENT_ID
      );
   END IF;	--END OF IF ATTACHMENT URL IS NOT NULL
END INSERT_AMW_PROCESS;

PROCEDURE UPD_AMW_PROCESS(
   P_PROCESS_REC IN AMW_PROCESS_REC
  ,X_RETURN_STATUS OUT NOCOPY VARCHAR2
  ,X_MSG_COUNT OUT NOCOPY NUMBER
  ,X_MSG_DATA OUT NOCOPY VARCHAR2
)IS
   L_PROCESS_REV_ID NUMBER;

   L_SEQ_NUM NUMBER;
   LX_MEDIA_ID NUMBER;
   LX_DOCUMENT_ID NUMBER;
   LX_ATTACHED_DOCUMENT_ID NUMBER;
   L_LANGUAGE VARCHAR2(30);

   LX_ROW_ID VARCHAR2(30);

   l_attachment_rec amw_attachment_pvt.fnd_attachment_rec_type;

   lX_return_status   varchar2(1);
   lX_msg_count       number;
   lX_msg_data        varchar2(2000);
   lx_index           number;

   ---12.29.2004 NPANANDI: STD VAR VAR ADDED
   L_STANDARD_VARIATION	   NUMBER;
   L_IS_STD_VAR			   NUMBER;
   l_standard_process_flag varchar2(1);

   ---04.22.2005 npanandi: added vars below for profile option values
   l_amw_process_owner_col     varchar2(30);
   l_amw_application_owner_col varchar2(30);
   l_amw_finance_owner_col     varchar2(30);
   l_process_id                number;

   --04.28.2005 npanandi: added below var for deleting grant
   l_grant_guid raw(16);

   ---08.04.2005 npanandi: added below variable for Classification updates
   l_classification number default null;
   l_classification_new number default null;

BEGIN
   ---GET THE PROCESS_REV_ID FOR UPDATING THE _TL TBL
   BEGIN
      ---04.26.2005 npanandi: added process_id in below SQL query
	  ---to get processId for grants
      SELECT PROCESS_REV_ID,process_id
        INTO L_PROCESS_REV_ID,l_process_id
	    FROM AMW_LATEST_REVISIONS_v
       WHERE PROCESS_ID=P_PROCESS_REC.PROCESS_ID;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    NULL;
   END;

   ---12.29.2004 npanandi:
   ---for an update, check if the Std Process chosen for this NonStdVariation
   ---is not the same Process, if it is same Process, then set StandardVariation=NULL
   L_STANDARD_VARIATION := NULL;
   l_standard_process_flag := 'Y';
   L_IS_STD_VAR := 0;
   begin
      select 1
	    into L_IS_STD_VAR
        from amw_process ap
       where (select process_id
	            from amw_process
			   where process_rev_id = ap.standard_variation) =
			 (select process_id
			    from amw_process
			   where process_rev_id = L_PROCESS_REV_ID)
         and ap.end_date is null;
   exception
      WHEN NO_DATA_FOUND THEN
	     L_IS_STD_VAR := 0;
   END;

   IF(P_PROCESS_REC.STANDARD_VARIATION <> L_PROCESS_REV_ID AND L_IS_STD_VAR = 0)THEN
      L_STANDARD_VARIATION := P_PROCESS_REC.STANDARD_VARIATION;
	  if(P_PROCESS_REC.STANDARD_PROCESS_FLAG='N')then
	     l_standard_process_flag := 'N';
	  end if;
   END IF;

   --disregard the StandardVariation if the Process is Std Process
   if(P_PROCESS_REC.STANDARD_PROCESS_FLAG='Y')then
      L_STANDARD_VARIATION := null;
   end if;

   UPDATE AMW_PROCESS
      SET APPROVAL_STATUS=P_PROCESS_REC.APPROVAL_STATUS
	     ,SIGNIFICANT_PROCESS_FLAG=P_PROCESS_REC.SIGNIFICANT_PROCESS_FLAG
		 ---,STANDARD_PROCESS_FLAG=P_PROCESS_REC.STANDARD_PROCESS_FLAG
		 ,STANDARD_PROCESS_FLAG=l_STANDARD_PROCESS_FLAG
		 ,CERTIFICATION_STATUS=P_PROCESS_REC.CERTIFICATION_STATUS
		 ,PROCESS_CATEGORY=P_PROCESS_REC.PROCESS_CATEGORY
		 ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
		 ,PROCESS_TYPE=P_PROCESS_REC.PROCESS_TYPE
		 ,CONTROL_ACTIVITY_TYPE=P_PROCESS_REC.CONTROL_ACTIVITY_TYPE
		 ,LAST_UPDATE_DATE=SYSDATE
		 ,LAST_UPDATED_BY=G_USER_ID
		 ,LAST_UPDATE_LOGIN=G_LOGIN_ID
		 ---12.29.2004 NPANANDI: ADDED STD VARIATION COL UPDATE
		 ,STANDARD_VARIATION=L_STANDARD_VARIATION
	WHERE PROCESS_ID=P_PROCESS_REC.PROCESS_ID
	  AND END_DATE IS NULL;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   ---07.28.2005 npanandi: fixing bug for update Classification
      l_classification := null;
	l_classification_new := null;

      begin
         select classification
           into l_classification
   	    from amw_process
   	   where process_id=p_process_rec.process_id
   	     and end_date is null;
	--- For bug 4692219
	select w.work_type_id into l_classification_new from amw_work_types_b w,
	amw_work_categories_b c
	where w.work_type_code = 'AMW_UNDEF'
	and w.category_id = c.category_id
	and category_code = 'RL_PROCESS';

      exception
         when no_data_found then
   	     l_classification := null;
	     l_classification_new := null;
         when others then
   	     l_classification := null;
	     l_classification_new := null;

      end;

      /*** fnd_file.put_line(fnd_file.LOG, '^^^^^^^^^^^^^^^^ l_classification: '||l_classification ); **/

      if ((l_classification is null or (l_classification = l_classification_new)) and p_process_rec.classification is not null) then
         /*** fnd_file.put_line(fnd_file.LOG, '^^^^^^^^^^^^^^^^ Updating AmwProcess here' ); ***/
         update amw_process
   	     set classification = p_process_rec.classification
   		    ,last_update_date = sysdate
   			,last_updated_by = g_user_id
   			,last_update_login = g_login_id
   	   where process_id=p_process_rec.process_id
   	     and end_date is null;
      end if;

      /*** fnd_file.put_line(fnd_file.LOG, '^^^^^^^^^^^^^^^^ Am out of the updates' ); ***/
   ----7.28.2005 npanandi: end of bug fix for update Classification

   update AMW_PROCESS_NAMES_TL
      set DISPLAY_NAME = P_PROCESS_REC.DISPLAY_NAME
	      ---03.28.2005 npanandi: commented out update on description
		  ---bug 4241577 fix
         ---,DESCRIPTION = P_PROCESS_REC.DESCRIPTION
		 ---03.28.2005 npanandi: bugfix ends
         ,LAST_UPDATE_DATE = SYSDATE
         ,LAST_UPDATED_BY=G_USER_ID
		 ,LAST_UPDATE_LOGIN=G_LOGIN_ID
         ,SOURCE_LANG = userenv('LANG')
		 ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
    where PROCESS_REV_ID = L_PROCESS_REV_ID
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%notfound) then
      raise no_data_found;
   end if;

   ---04.22.2005 npanandi: added below grants bug 4323387
   l_amw_process_owner_col := NVL(fnd_profile.VALUE ('AMW_PROC_IMP_PROC_OWNER_COL'),'AMW_RL_PROC_OWNER_ROLE');
   if(p_process_rec.process_owner_id is not null) then
      ---04.29.2005 npanandi: check here to see
	  ---if the role is ProcessOwner Role, then
	  ---whether to add or to replace
	  if(l_amw_process_owner_col = 'AMW_RL_PROC_OWNER_ROLE')then
	     pre_process_role_grant(
		    p_role_name => l_amw_process_owner_col
		   ,p_pk1_value => l_process_id);
	  end if;
      add_owner_privilege(
         p_role_name          => l_amw_process_owner_col
        ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
	    ,p_grantee_type       => 'P'
	    ,p_instance_pk1_value => l_process_id
	    ,p_party_id           => P_PROCESS_REC.process_owner_id);
   end if;

   if(p_process_rec.application_owner_id is not null) then
      l_amw_application_owner_col := NVL(fnd_profile.VALUE ('AMW_PROC_IMP_APPL_OWNER_COL'),'AMW_RL_PROC_APPL_OWNER_ROLE');
	  ---04.29.2005 npanandi: check here to see
	  ---if the role is ProcessOwner Role, then
	  ---whether to add or to replace
	  if(l_amw_application_owner_col = 'AMW_RL_PROC_OWNER_ROLE')then
	     pre_process_role_grant(
		    p_role_name => l_amw_application_owner_col
		   ,p_pk1_value => l_process_id);
	  end if;
      add_owner_privilege(
         p_role_name          => l_amw_application_owner_col
        ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
        ,p_grantee_type       => 'P'
        ,p_instance_pk1_value => l_process_id
        ,p_party_id           => P_PROCESS_REC.application_owner_id);
   end if;

   if(p_process_rec.finance_owner_id is not null) then
      l_amw_finance_owner_col := NVL(fnd_profile.VALUE ('AMW_PROC_IMP_FINANCE_OWNER_COL'),'AMW_RL_PROC_FINANCE_OWNER_ROLE');
	  ---04.29.2005 npanandi: check here to see
	  ---if the role is ProcessOwner Role, then
	  ---whether to add or to replace
	  if(l_amw_finance_owner_col = 'AMW_RL_PROC_OWNER_ROLE')then
	     pre_process_role_grant(
		    p_role_name => l_amw_finance_owner_col
		   ,p_pk1_value => l_process_id);
	  end if;
      add_owner_privilege(
         p_role_name          => l_amw_finance_owner_col
        ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
        ,p_grantee_type       => 'P'
        ,p_instance_pk1_value => l_process_id
        ,p_party_id           => P_PROCESS_REC.finance_owner_id);
   end if;
   ---04.22.2005 npanandi: ends bug 4323387 fix

   ---if(P_PROCESS_REC.ATTACHMENT_URL IS NOT NULL AND not (TRIM(P_PROCESS_REC.ATTACHMENT_URL)='')) THEN
   if(P_PROCESS_REC.ATTACHMENT_URL IS NOT NULL) THEN
      --SELECT FND_ATTACHED_DOCUMENTS_S.NEXTVAL INTO L_ATTACHED_DOCUMENT_ID FROM DUAL;
	  --SELECT fnd_documents_s.nextval INTO L_DOCUMENT_ID FROM DUAL;
      BEGIN
	     SELECT MAX(SEQ_NUM) INTO L_SEQ_NUM FROM FND_ATTACHED_DOCUMENTS WHERE ENTITY_NAME='AMW_PROCESS' AND PK1_VALUE=l_process_rev_id;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    L_SEQ_NUM := 0;
	     WHEN OTHERS THEN
		    L_SEQ_NUM := 0;
	  END;

	  L_SEQ_NUM := L_SEQ_NUM+1;

	  l_attachment_rec.description := 'AUTO: ';
	  l_attachment_rec.file_name := P_PROCESS_REC.ATTACHMENT_URL;
	  l_attachment_rec.datatype_id := 5;
	  l_attachment_rec.seq_num := l_seq_num;
	  l_attachment_rec.entity_name := 'AMW_PROCESS';
	  l_attachment_rec.pk1_value := to_char(L_PROCESS_REV_ID);
	  l_attachment_rec.automatically_added_flag := 'N';
	  l_attachment_rec.datatype_id := 5;
	  l_attachment_rec.category_id := 1;
	  l_attachment_rec.security_type := 4;
	  l_attachment_rec.publish_flag := 'Y';
	  l_attachment_rec.media_id := lx_media_id;

	  x_msg_data := null;
	  x_msg_count := 0;
	  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
	  AMW_ATTACHMENT_PVT.CREATE_FND_ATTACHMENT(
         p_api_version_number         => 1,
		 p_init_msg_list              => FND_API.G_TRUE,
         x_return_status              => X_RETURN_STATUS,
         x_msg_count                  => X_MSG_COUNT,
         x_msg_data                   => X_MSG_DATA,
         p_Fnd_Attachment_rec         => l_attachment_rec,
         x_document_id                => LX_DOCUMENT_ID,
         x_attached_document_id       => LX_ATTACHED_DOCUMENT_ID
      );

   END IF;	--END OF IF ATTACHMENT URL IS NOT NULL

END UPD_AMW_PROCESS;

---
---03.02.2005 npanandi: add Process Owner privilege here for data security
---
procedure add_owner_privilege(
   p_role_name          in varchar2
  ,p_object_name        in varchar2
  ,p_grantee_type       in varchar2
  ,p_instance_set_id    in number
  ,p_instance_pk1_value in varchar2
  ,p_instance_pk2_value in varchar2
  ,p_instance_pk3_value in varchar2
  ,p_instance_pk4_value in varchar2
  ,p_instance_pk5_value in varchar2
  ,p_party_id            in number
  ,p_start_date         in date
  ,p_end_date           in date
)
is
   ---04.22.2005 npanandi: party_id is being passed directly
   /**
   cursor c_get_party_id is
      select person_party_id
        from fnd_user
       where user_id=p_user_id;
   **/

   l_return_status  varchar2(10);
   l_msg_count number;
   l_msg_data varchar2(4000);
   ---l_party_id number;
begin
   ---04.22.2005 npanandi: party_id is being passed directly
   /**
   open c_get_party_id;
      fetch c_get_party_id into l_party_id;
   close c_get_party_id;
   **/

   amw_security_pub.grant_role_guid(
      p_api_version          => 1
     ,p_role_name            => p_role_name
     ,p_object_name          => p_object_name
     ,p_instance_type        => 'INSTANCE'
     ,p_instance_set_id      => null
     ,p_instance_pk1_value   => p_instance_pk1_value
     ,p_instance_pk2_value   => null
     ,p_instance_pk3_value   => null
     ,p_instance_pk4_value   => null
     ,p_instance_pk5_value   => null
     ,p_party_id             => p_party_id
     ,p_start_date           => sysdate
     ,p_end_date             => null
     ,x_return_status        => l_return_status
     ,x_errorcode            => l_msg_count
     ,x_grant_guid           => l_msg_data);
exception
   when others then
      rollback;
end add_owner_privilege;
---03.02.2005 npanandi: ends method for grant owner privilege

---
---03.02.2005 npanandi: function to check access privilege for this Process
---
function check_function(
   p_function           in varchar2
  ,p_object_name        in varchar2
  ,p_instance_pk1_value in number
  ,p_instance_pk2_value in number
  ,p_instance_pk3_value in number
  ,p_instance_pk4_value in number
  ,p_instance_pk5_value in number
  ,p_user_id            in number
) return varchar2
is
   cursor c_get_user_name is
      select user_name from fnd_user where user_id=p_user_id;

   l_has_access varchar2(15) := 'T';
   l_user_name  varchar2(100); ---fnd_user.user_name colLength = 100
   l_security_switch VARCHAR2 (2);
begin
   open c_get_user_name;
      fetch c_get_user_name into l_user_name;
   close c_get_user_name;

   l_security_switch := NVL(fnd_profile.VALUE ('AMW_DATA_SECURITY_SWITCH'), 'N');

   if(l_security_switch = 'Y') then ---check for Upd prvlg only if Security mode is set on
      l_has_access := fnd_data_security.check_function(
                         p_api_version         => 1
                        ,p_function            => p_function
                        ,p_object_name         => p_object_name
                        ,p_instance_pk1_value  => p_instance_pk1_value
                        ,p_user_name           => l_user_name);
   end if;

   return l_has_access;
end;
---03.01.2005 npanandi: end function to check access privilege

---
---04.29.2005 npanandi: added below procedure to check for existing
---                     Owner roles
---
procedure pre_process_role_grant(
   p_role_name in varchar2
  ,p_pk1_value in number
)
is
   l_count_owners   number;
   l_grant_guid     raw(16);
   lx_return_status VARCHAR2(30);
   lx_error_code    number;
begin
   l_count_owners := 0;
   begin
      ---check how many owners with the specified Role are already there
	  ---for the chosen Process
      select count(party_name)
	    into l_count_owners
	    from amw_owner_roles_v
	   where role_name=p_role_name
	     and pk1_value=to_char(p_pk1_value);
   exception
      when no_data_found then
	     l_count_owners := 0;
	  when others then
	     l_count_owners := 0;
   end;

   ---if the # of owners is 1, then replace i.e. remove this
   ---grant and add owner in the main API above
   if(l_count_owners = 1)then
      select grant_guid
	    into l_grant_guid
		from amw_owner_roles_v
	   where role_name=p_role_name
	     and pk1_value=to_char(p_pk1_value);

	  amw_security_pub.REVOKE_GRANT(
	     p_api_version   => 1
		,p_grant_guid    => l_grant_guid
		,x_return_status => lx_return_status
		,x_errorcode     => lx_error_code
	  );
   end if;
exception
   when others then
      rollback;
end pre_process_role_grant;
---04.29.2005 npanandi: ends method for grant owner privilege



END amw_load_proc_data;

/
