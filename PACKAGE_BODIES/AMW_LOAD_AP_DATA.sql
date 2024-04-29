--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_AP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_AP_DATA" AS
/* $Header: amwapldb.pls 120.2.12000000.2 2007/03/15 06:09:07 srbalasu ship $ */
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/* Major Functionality of the followIng procedure includes:                  */
/* Reads the amw_risk-ctrl_interface table                                   */
/* following tables:                                                         */
/*           INSERTS OR UPDATES ARE DONE AGAINIST THE FOLLOWING TABLES       */
/*  Insert into AMW_RISKS_B and AMW_RISKS_TL                                 */
/*  Insert into AMW_CONTROLS_B and AMW_CONTROLS_TL                           */
/*  Insert into AMW_CONTROL_ASSOCIATIONS                                     */
/*  Insert into AMW_RISK_ASSOCIATIONS                                        */
/*  Insert into AMW_CONTROL_OBJECTIVES                                       */
/*  Insert into AMW_CONTROL_ASSERTIONS                                       */
/*  Updates amw_ap_interface, with error messages                     */
/*  Deleting successful production inserts, based on profile                 */
/*                                                                           */
/*****************************************************************************/
--
-- Used for exception processing
--
-- npanandi 11/08/2004 Fixed bug# 3824295 on the mainline

   type t_AP_name IS table of amw_AP_INTERFACE.AP_name%type INDEX BY BINARY_INTEGER;
   v_AP_name          t_AP_name;

   G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
   G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
   v_error_found               				BOOLEAN   DEFAULT FALSE;
   v_user_id		           				NUMBER;
   v_interface_id              				NUMBER;
   vx_control_rev_id		   				NUMBER;
   vx_process_objective_id		   			NUMBER 	  := null;
   lx_risk_rev_id		       				NUMBER;
   v_err_msg                   				VARCHAR2 (2000);
   v_table_name                				VARCHAR2 (240);
   v_count                                              NUMBER;
   ---02.03.2005 npanandi: increased Varchar2 length of v_import_func
   ---from 30 to 480 per FND mandate
   v_import_func      CONSTANT 				VARCHAR2(480) := 'AMW_DATA_IMPORT';

   v_ap_db_approval_status					VARCHAR2(30);

   v_invalid_requestor_msg	  				VARCHAR2(2000);
   v_no_import_privilege_msg	  			VARCHAR2(2000);
   v_invalid_risk_type	  					VARCHAR2(2000);

   v_ap_pending_msg	  						VARCHAR2(2000);

   v_valid_risk_type						number := 0;

--
-- function to check the user access privilege
--
   FUNCTION Has_Import_Privilege RETURN Boolean
   IS
      CURSOR c_func_exists IS
	SELECT 'Y'
          FROM fnd_responsibility r, fnd_compiled_menu_functions m, fnd_form_functions f
         WHERE r.responsibility_id = fnd_global.resp_id
	   AND r.application_id=fnd_global.resp_appl_id
           AND r.menu_id = m.menu_id
           AND m.function_id = f.function_id
           AND f.function_name = v_import_func;
      CURSOR c_func_excluded IS
	SELECT 'Y'
          FROM fnd_resp_functions rf, fnd_form_functions f
         WHERE rf.application_id = fnd_global.resp_appl_id
	   AND rf.responsibility_id = fnd_global.resp_id
	   AND rf.rule_type = 'F'
	   AND rf.action_id = f.function_id
	   AND f.function_name = v_import_func;

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
    END Has_Import_Privilege;


   FUNCTION AP_Can_Be_Processed RETURN Boolean
   IS
   BEGIN
     IF v_ap_db_approval_status = 'P' THEN
       update_interface_with_error (v_ap_pending_msg
                                ,'AMW_CONTROLS'
                                ,v_interface_id);
       return FALSE;
     END IF;
     return TRUE;
   END ap_Can_Be_Processed;

/*****************************************************************************/
/*****************************************************************************/
   PROCEDURE create_audit_procedures (
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
     ,p_user_id    IN              NUMBER
   )
   IS
/****************************************************/
   CURSOR C_GET_INV_AP IS
      SELECT AP_NAME
	        ,NVL(AP_APPROVAL_STATUS_CODE,'D') AS AP_APPROVAL_STATUS_CODE
	        ,AP_INTERFACE_ID
	    FROM AMW_AP_INTERFACE
	   WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
         AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
         AND process_flag IS NULL
         AND error_flag IS NULL
	   ORDER BY AP_INTERFACE_ID ASC;


      CURSOR audit_procedures_cur
      IS
	     SELECT ap_name,
		  		ap_description,
				ap_approval_status_code,
				ap_end_date,
				revise_ap_flag,
				control_name,
				ap_step_name,
				ap_step_description,
				ap_step_samplesize,
				---01.14.2005 npanandi: ApStepSeqNum column now supports
				---alphanumeric post AMW.D
				---so, created ApStepNum2 (Varchar2) column in AmwApInterface tbl
				---and quering the new column while retaining the previous alias
				/** ap_step_seqnum, **/
				ap_step_seqnum2 as ap_step_seqnum,
				ap_interface_id,
				upper(nvl(design_effectiveness,'N')) as design_effectiveness,
				upper(nvl(op_effectiveness,'N')) as op_effectiveness
				--npanandi 12.13.2004: added following for AP classification
			   ,CLASSIFICATION
           FROM amw_ap_interface
          WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
            AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
            AND process_flag IS NULL
            AND error_flag IS NULL
            ORDER BY AP_INTERFACE_ID ASC;

     CURSOR c_requestor_id IS
       SELECT party_id
         FROM amw_employees_current_v
        WHERE employee_id = (select employee_id
                               from fnd_user
                              where user_id = p_user_id)
          AND rownum = 1;

     CURSOR c_ap_exists (c_ap_name IN VARCHAR2) IS
       SELECT b.audit_procedure_id, b.approval_status
         FROM amw_audit_procedures_b b, amw_audit_procedures_tl tl
       WHERE tl.name = c_ap_name
	     AND tl.language = USERENV('LANG')
         AND tl.audit_procedure_rev_id = b.audit_procedure_rev_id
         AND b.latest_revision_flag='Y';


	 CURSOR c_step_exists (c_step_num IN NUMBER,c_ap_id IN NUMBER) IS
       SELECT b.ap_step_id,
	   		  b.name,
			  b.description,
			  b.samplesize,
			  b.from_rev_num,
			  b.to_rev_num
         FROM amw_ap_steps_vl b
        WHERE b.seqnum = c_step_num
	   	  AND b.audit_procedure_id = c_ap_id;

     CURSOR c_get_from_rev_num(c_audit_procedure_rev_id in number) is
	   Select audit_procedure_rev_num
	     From amw_audit_procedures_b
		Where audit_procedure_rev_id = c_audit_procedure_rev_id;

	 lx_step_rec				   	 		 c_step_exists%rowtype;

     l_api_version_number      		CONSTANT NUMBER   := 1.0;
     l_requestor_id			      			 NUMBER;
     l_amw_delt_ap_intf        		 		 VARCHAR2 (2);
     l_amw_ap_name_prefix        		 	 VARCHAR2 (30);
     l_ap_rec			      				 AMW_AUDIT_PROCEDURES_PVT.audit_procedure_rec_type;
     l_ap_found                  		 	 BOOLEAN        default true;
	 l_step_found                  		 	 BOOLEAN        default true;
	 l_process_steps                  		 BOOLEAN        default false;
     l_ap_approval_status_code      		 VARCHAR2(30);
     l_ap_step_name		      				 VARCHAR2(240);
     l_control_id		      				 NUMBER;

	 lx_return_status		      			 VARCHAR2(30);
     lx_msg_count		      				 NUMBER;
     lx_msg_data		      				 VARCHAR2(2000);
     lx_risk_id			      				 NUMBER;
     lx_audit_procedure_id		      		 NUMBER;
	 lx_audit_procedure_rev_id		         NUMBER;
	 lx_ap_step_id							 NUMBER;
	 lx_ap_seqnum							 NUMBER;
     lx_mode_affected		      			 VARCHAR2(30);
	 l_from_rev_num							 NUMBER;
     l_object_type_count	      			 NUMBER;
     l_process_flag		      				 VARCHAR2(1);
     e_no_import_access               		 EXCEPTION;
     e_invalid_requestor_id           		 EXCEPTION;
	 e_invalid_risk_type           		 	 EXCEPTION;
     INV_AP_UPL_STATUSES					 EXCEPTION;

	 L_AP_EXISTS							 BOOLEAN;
     l_revise_ap_flag		      			 VARCHAR2(1);
	 L_APPROVAL_DATE						 DATE;
	 L_ERR_MSG								 VARCHAR2(2000);
	 L_COUNT								 NUMBER;
	 L_AUDIT_PROCEDURE_ID					 number;
	 L_AUDIT_PROCEDURE_REV_ID				 number;

	 ---03.01.2005 npanandi:
     l_new_ap                                boolean default true;
     l_has_access                            varchar2(15);
   BEGIN
     fnd_file.put_line (fnd_file.LOG, 'resp id: '||fnd_global.RESP_ID);
     fnd_file.put_line (fnd_file.LOG, 'resp appl id: '||fnd_global.RESP_APPL_ID);

--
--   check access privilege
--

     IF not Has_Import_Privilege THEN
       RAISE e_no_import_access;
     END IF;

--
--   get user requestor_id
--
     v_user_id := p_user_id;

	 OPEN c_requestor_id;
     FETCH c_requestor_id INTO l_requestor_id;
     IF (c_requestor_id%NOTFOUND) THEN
       CLOSE c_requestor_id;
       RAISE e_invalid_requestor_id;
     END IF;
     CLOSE c_requestor_id;


--
--   get profile info for deleting records from interface table
--
     l_amw_delt_ap_intf := NVL(fnd_profile.VALUE ('AMW_DELT_AP_INTF'), 'N');

     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                   p_token_name   => 'OBJ_TYPE',
                                   p_token_value  => AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','AP'));

	 v_ap_pending_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_LAST,
						   				p_encoded => fnd_api.g_false);



--
--   loop processing each record
--

   ---FIRST CHECK HERE TO SEE IF THERE IS ANY CHANGE
   ---IN AP STATUS BETWEEN DIFF. ROWS FOR THE SAME AP BEING UPLOADED
   FOR AP_INV_UPL IN C_GET_INV_AP LOOP
      v_interface_id := AP_INV_UPL.AP_INTERFACE_ID;
      BEGIN
         SELECT count(*)
	       INTO v_count
	       FROM AMW_AP_INTERFACE
	      WHERE BATCH_ID=p_batch_id
	        AND AP_NAME=AP_INV_UPL.AP_NAME
		    AND NVL(AP_APPROVAL_STATUS_CODE,'D') <> AP_INV_UPL.AP_APPROVAL_STATUS_CODE;

		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_interface_id: '||v_interface_id);
		 IF(v_count > 0) THEN
		    RAISE INV_AP_UPL_STATUSES;
		 END IF;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    NULL;
	  END;
   END LOOP;

   --PROCESS THE AUDIT PROCEDURE HERE
   for AP_REC IN AUDIT_PROCEDURES_CUR LOOP
      BEGIN
         --SET INTERFACE_ID TO NULL FOR THIS LOOP,
	     --TO AVOID ANY ERRORS DUE TO GLOBAL VARIABLES
	     V_INTERFACE_ID := NULL;
         v_interface_id := ap_rec.ap_INTERFACE_ID;
	     l_ap_approval_status_code := ap_rec.ap_approval_status_code;
	     l_revise_ap_flag := upper(NVL(ap_rec.revise_ap_flag, 'N'));

	     l_ap_rec.end_date 	 	 		      := ap_rec.ap_end_date;
	     l_ap_rec.approval_status 		      := l_ap_approval_status_code;
	     l_ap_rec.audit_procedure_name 	      := ap_rec.ap_name;
		 l_ap_rec.audit_procedure_description := ap_rec.ap_description;
		 l_ap_rec.requestor_id 			      := l_requestor_id;
		 --NPANANDI 12.13.2004: ADDED BELOW FOR AP CLASSIFICATION
		 L_AP_REC.CLASSIFICATION	  		  := AP_REC.CLASSIFICATION;

	     IF(l_ap_approval_status_code = 'A')THEN
		    L_APPROVAL_DATE := SYSDATE;
	     END IF;

	     L_AP_EXISTS := FALSE;
	     BEGIN
	        SELECT COUNT(1) INTO L_COUNT
	          FROM AMW_AP_INTERFACE
	         WHERE BATCH_ID=P_BATCH_ID
	           AND AP_NAME=ap_rec.ap_name
		       AND AP_INTERFACE_ID < V_INTERFACE_ID;

	        IF(L_COUNT > 0)THEN
		       L_AP_EXISTS := TRUE;
		    END IF;
	     EXCEPTION
	        WHEN NO_DATA_FOUND THEN
		       L_AP_EXISTS := FALSE;
	     END;

	     IF(NOT L_AP_EXISTS) THEN
	        V_AP_NAME(v_interface_id) := ap_rec.ap_name;

		    ---03.01.2005 npanandi: added data security checks
            l_has_access := 'T'; ---setting this to 'T' for new Controls
            lx_audit_procedure_id := null; ---setting this to NULL to avoid conflict with value from previous loop
            begin
               SELECT b.audit_procedure_id
                 into lx_audit_procedure_id
                 FROM amw_audit_procedures_b b, amw_audit_procedures_tl tl
                WHERE tl.name = ap_rec.ap_name
	              AND tl.language = USERENV('LANG')
                  AND tl.audit_procedure_rev_id = b.audit_procedure_rev_id
	              AND b.latest_revision_flag='Y';
            exception
               when no_data_found then
                  l_has_access := 'T';
               when others then
                  l_has_access := 'T';
            end;

	        ----03.01.2005 npanandi: setting this to TRUE for this loop
	        ----to avoid confusion from previous loop value
	        l_new_ap := true;
			if(lx_audit_procedure_id is not null) then
			   ---Check for Update privilege here
			   l_new_ap := false;
			   l_has_access := check_function(
                                  p_function           => 'AMW_UPDATE_AP_DETAILS'
                                 ,p_object_name        => 'AMW_AUDIT_PROCEDURE'
                                 ,p_instance_pk1_value => lx_audit_procedure_id
                                 ,p_user_id            => fnd_global.user_id);

               IF l_has_access <> 'T' then
			      v_err_msg := 'Cannot update this Audit Procedure';
			      update_interface_with_error (v_err_msg
                                              ,'AMW_AUDIT_PROCEDURE'
			                                  ,v_interface_id);
               END IF;
            end if;
		    ---03.01.2005 npanandi: added data security checks ends

		    ---03.01.2005 npanandi: call for LoadAP reqd. only if this has l_has_access='T'
		    if(l_has_access = 'T') then
	           AMW_AUDIT_PROCEDURES_PVT.Load_Ap(
		          p_api_version_number 			=> l_api_version_number,
		          p_init_msg_list      			=> FND_API.G_TRUE,
		          p_commit             			=> FND_API.G_FALSE,
		          p_validation_level   			=> FND_API.G_VALID_LEVEL_FULL,
		          x_return_status      			=> lx_return_status,
		          x_msg_count          			=> lx_msg_count,
		          x_msg_data           			=> lx_msg_data,
		          p_audit_procedure_rec         => l_ap_rec,
		          x_audit_procedure_rev_id      => lx_audit_procedure_rev_id,
		          x_audit_procedure_id	     	=> lx_audit_procedure_id,
		          P_APPROVAL_DATE				=> L_APPROVAL_DATE);

		       ---03.01.2005 npanandi: if new Audit Procedure, grant APOwner prvlg
			   if(l_new_ap) then
			      add_owner_privilege(
			         p_role_name          => 'AMW_AP_OWNER_ROLE'
                    ,p_object_name        => 'AMW_AUDIT_PROCEDURE'
			        ,p_grantee_type       => 'P'
			        ,p_instance_pk1_value => lx_audit_procedure_id
			        ,p_user_id            => FND_GLOBAL.USER_ID);
			   end if;
		       ---03.01.2005 npanandi: if new Audit Procedure, grant APOwner prvlg

	           IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
		          v_err_msg := ' ';
		          FOR x IN 1..lx_msg_count LOOP
			         if(length(v_err_msg) < 1800) then
			            v_err_msg := v_err_msg||' '||substr(
			                   fnd_msg_pub.get(p_msg_index => x,
							   	  			   p_encoded => fnd_api.g_false), 1,100);
			         end if;
		          END LOOP;
		          update_interface_with_error (v_err_msg
		                             ,'AMW_AUDIT_PROCEDURES'
		                             ,v_interface_id);
	           END IF;
	        end if; ---03.01.2005 npanandi: end of if l_has_access = 'T' or not Check
         END IF;	--end of if for ap_exists in this upload or not
	  EXCEPTION
	     WHEN OTHERS THEN
		    V_ERR_MSG := NULL;
		    v_err_msg := 'interface_id: = '|| V_interface_id|| '  '
                || SUBSTR (SQLERRM, 1, 100);
		    update_interface_with_error (v_err_msg
		                             ,'AMW_AUDIT_PROCEDURES'
		                             ,v_interface_id);
	  END; --end of begin for this loop

      --process ap_steps for this loop
	  --GET THE AP_ID
	  BEGIN
	     SELECT AUDIT_PROCEDURE_ID,AUDIT_PROCEDURE_REV_ID
	       INTO L_AUDIT_PROCEDURE_ID,L_AUDIT_PROCEDURE_REV_ID
	       FROM AMW_AUDIT_PROCEDURES_VL
	      WHERE NAME=AP_REC.AP_NAME
		    AND LATEST_REVISION_FLAG='Y';

         ---03.01.2005 npanandi: call for LoadAP reqd. only if this has l_has_access='T'
         if(l_has_access = 'T') then
	        AMW_AUDIT_PROCEDURES_PVT.INSERT_AP_STEP(
		       P_API_VERSION_NUMBER     => L_API_VERSION_NUMBER,
			   P_INIT_MSG_LIST			=> FND_API.G_TRUE,
			   P_COMMIT					=> FND_API.G_FALSE,
			   P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
			   P_SAMPLESIZE				=> AP_REC.ap_step_samplesize,
			   P_AUDIT_PROCEDURE_ID		=> L_AUDIT_PROCEDURE_ID,
			   P_SEQNUM					=> AP_REC.AP_STEP_SEQNUM,
			   P_REQUESTOR_ID			=> L_REQUESTOR_ID,
			   P_NAME					=> AP_REC.AP_STEP_NAME,
			   P_DESCRIPTION			=> AP_REC.AP_STEP_DESCRIPTION,
			   P_AUDIT_PROCEDURE_REV_ID	=> L_AUDIT_PROCEDURE_REV_ID,
			   P_USER_ID				=> G_USER_ID,
			   X_RETURN_STATUS			=> LX_RETURN_STATUS,
			   X_MSG_COUNT				=> LX_MSG_COUNT,
			   X_MSG_DATA 				=> LX_MSG_DATA);

	        IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
	           v_err_msg := ' ';
	           FOR x IN 1..lx_msg_count LOOP
		          if(length(v_err_msg) < 1800) then
		             v_err_msg := v_err_msg||' '||substr(
		                   fnd_msg_pub.get(p_msg_index => x,
							  			p_encoded => fnd_api.g_false), 1,100);
		          end if;
	           END LOOP;
	           update_interface_with_error (v_err_msg
	                             ,'AMW_AUDIT_PROCEDURES'
	                             ,v_interface_id);
            END IF;
         end if; ---03.01.2005 npanandi: end of l_has_access = 'T' check for ApStep insertions
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    V_ERR_MSG := 'interface_id: = '|| V_interface_id|| ',no data found for this AP_Step';
			update_interface_with_error (v_err_msg
		                             ,'AMW_AUDIT_PROCEDURES'
		                             ,v_interface_id);
	  END;

	  --PROCESS CONTROL ASSOCIATIONS
	  IF(AP_REC.CONTROL_NAME IS NOT NULL) THEN
	     BEGIN
	        IF(AP_REC.DESIGN_EFFECTIVENESS='N' AND AP_REC.OP_EFFECTIVENESS='N')THEN
		       --THROW ERROR
			   V_ERR_MSG := FND_MESSAGE.GET_STRING('AMW','AMW_ASSOC_AP_EFF_WEBADI_MSG');
			   update_interface_with_error (v_err_msg
		                             ,'AMW_AUDIT_PROCEDURES'
		                             ,v_interface_id);
		    ELSE
			   fnd_file.put_line(fnd_file.LOG,'FOR THIS LOOP');
			   fnd_file.put_line(fnd_file.LOG,'L_AUDIT_PROCEDURE_ID: '||L_AUDIT_PROCEDURE_ID||', L_AUDIT_PROCEDURE_REV_ID: '||L_AUDIT_PROCEDURE_REV_ID);

               ---03.01.2005 npanandi: call for LoadAP reqd. only if this has l_has_access='T'
               if(l_has_access = 'T') then
			      AMW_AUDIT_PROCEDURES_PVT.INSERT_AP_CONTROL_ASSOC(
				     P_API_VERSION_NUMBER   => L_API_VERSION_NUMBER,
				     P_INIT_MSG_LIST		=> FND_API.G_TRUE,
				     P_COMMIT				=> FND_API.G_FALSE,
				     P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
				     P_CONTROL_ID			=> AP_REC.CONTROL_NAME,
				     P_AUDIT_PROCEDURE_ID	=> L_AUDIT_PROCEDURE_ID,
				     P_DES_EFF				=> AP_REC.DESIGN_EFFECTIVENESS,
				     P_OP_EFF				=> AP_REC.OP_EFFECTIVENESS,
				     P_APPROVAL_DATE		=> L_APPROVAL_DATE,
				     P_USER_ID				=> G_USER_ID,
				     X_RETURN_STATUS		=> LX_RETURN_STATUS,
			         X_MSG_COUNT			=> LX_MSG_COUNT,
			         X_MSG_DATA 			=> LX_MSG_DATA);
               end if; ---03.01.2005 npanandi: end of l_has_access = 'T' check for Ctrl Assoc
		    END IF; --END OF CHECK FOR EFFECTIVENESS VALIDATION
	     EXCEPTION
	        WHEN NO_DATA_FOUND THEN
			   NULL;
	     END; --END OF BEGIN BLOCK FOR PROCESSING CTRL ASSOCIATION
      END IF; --END OF IF CONTROL ID EXISTS
   END LOOP;

--
-- check profile option for (deletion of interface record, when the value is 'N', otherwise
-- set processed flag to 'Y', and update record
--

     IF v_error_found THEN
       ROLLBACK;
       l_process_flag := NULL;
     ELSE
       l_process_flag := 'Y';
     END IF;

     IF UPPER (l_amw_delt_ap_intf) <> 'Y' THEN
       BEGIN
         UPDATE amw_ap_interface
            SET process_flag = l_process_flag
               ,last_update_date = SYSDATE
               ,last_updated_by = v_user_id
          WHERE batch_id = p_batch_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line (fnd_file.LOG,'err in update process flag: '||SUBSTR (SQLERRM, 1, 200));
       END;
     ELSE
       IF NOT v_error_found THEN
         BEGIN
           DELETE FROM amw_ap_interface
                 WHERE batch_id = p_batch_id;

         EXCEPTION
           WHEN OTHERS THEN
             fnd_file.put_line (fnd_file.LOG,'err in delete interface records: '||SUBSTR (SQLERRM, 1, 200));
         END;
       END IF;
     END IF;

   EXCEPTION
      ---NPANANDI 11.21.2004 --> CHECK FOR CONSISTENT STATUS PER UPLOAD OF SAME AP
      WHEN INV_AP_UPL_STATUSES THEN
	     BEGIN
		    FND_FILE.PUT_LINE(FND_FILE.LOG, 'INVALID AP UPLOAD STATUS FOUND' );
			L_ERR_MSG := 'Multiple Approval Statuses found for this Procedure in this Upload';
	        update_interface_with_error(
			   p_ERR_MSG    	=> L_ERR_MSG
			  ,p_table_name 	=> 'AMW_AUDIT_PROCEDURES_B'
			  ,P_INTERFACE_ID 	=> V_INTERFACE_ID);
		 EXCEPTION
		    WHEN OTHERS THEN
 			   fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling INV_AP_UPL_STATUSES: '||sqlerrm);
	     END;
     ----Exception1
     WHEN e_invalid_requestor_id THEN
       fnd_file.put_line (fnd_file.LOG, 'Invalid requestor id.');
       BEGIN
	 IF v_invalid_requestor_msg is null THEN
	   v_invalid_requestor_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_UNKNOWN_EMPLOYEE');
	 END IF;
         UPDATE amw_ap_interface
            SET error_flag = 'Y'
                ,interface_status = v_invalid_requestor_msg
          WHERE batch_id = p_batch_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling e_invalid_requestor_id: '||sqlerrm);
       END;

     ----Exception2
     WHEN e_no_import_access THEN
       fnd_file.put_line (fnd_file.LOG, 'no import privilege');
       BEGIN
         IF v_no_import_privilege_msg is null THEN
	       v_no_import_privilege_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_NO_IMPORT_ACCESS');
	     END IF;
		 fnd_file.put_line(fnd_file.LOG,'v_no_import_privilege_msg: '||v_no_import_privilege_msg);
         UPDATE amw_ap_interface
            SET error_flag = 'Y'
                ,interface_status = v_no_import_privilege_msg
          WHERE batch_id = p_batch_id;
          EXCEPTION
             WHEN OTHERS THEN
               fnd_file.put_line (fnd_file.LOG, 'unexpected exception in handling e_no_import_access: '||sqlerrm);
             END;

	 ----Exception3
     WHEN others THEN
       rollback;
       fnd_file.put_line (fnd_file.LOG, 'unexpected exception in create_audit_procedures: '||sqlerrm);
   END create_audit_procedures;

---
---03.01.2005 npanandi: add Audit Procedure Owner privilege here for data security
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
  ,p_user_id            in number
  ,p_start_date         in date
  ,p_end_date           in date
)
is
   cursor c_get_party_id is
      select person_party_id
        from fnd_user
       where user_id=p_user_id;

   l_return_status  varchar2(10);
   l_msg_count number;
   l_msg_data varchar2(4000);
   l_party_id number;
begin
   open c_get_party_id;
      fetch c_get_party_id into l_party_id;
   close c_get_party_id;

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
     ,p_party_id             => l_party_id
     ,p_start_date           => sysdate
     ,p_end_date             => null
     ,x_return_status        => l_return_status
     ,x_errorcode            => l_msg_count
     ,x_grant_guid           => l_msg_data);
exception
   when others then
      rollback;
end add_owner_privilege;
---03.01.2005 npanandi: ends method for grant owner privilege

---
---03.01.2005 npanandi: function to check access privilege for this Audit Procedure
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
   fnd_file.put_line (fnd_file.LOG, '&&&&&&&&&&&&&&& inside check_function --> l_security_switch: '||l_security_switch||', l_has_access: '||l_has_access);

   return l_has_access;
end;
---03.01.2005 npanandi: end function to check access privilege

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
      l_interface_status   amw_ap_interface.interface_status%TYPE;
   BEGIN
      ROLLBACK; -- rollback any inserts done during the current loop process
      v_error_found := TRUE;

      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_ap_interface
          WHERE ap_interface_id = p_interface_id;
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
         UPDATE amw_ap_interface
            SET interface_status =
                       l_interface_status
               --     || 'Error Msg: '
                    || p_err_msg
               --     || ' Table Name: '
               --     || p_table_name
                    || '**'
               ,error_flag = 'Y'
          WHERE ap_interface_id = p_interface_id;

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

END amw_load_ap_data;

/
