--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_RC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_RC_DATA" AS
/* $Header: amwrcldb.pls 120.4.12000000.1 2007/01/16 20:40:57 appldev ship $ */
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
/*  Updates amw_risk-ctrl_interface, with error messages                     */
/*  Deleting successful production inserts, based on profile                 */
/*                                                                           */
/*****************************************************************************/
--
-- Used for exception processing
--

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

   ---02.03.2005 npanandi: increased Varchar2 length of v_import_func
   ---from 30 to 480 per FND mandate
   v_import_func      CONSTANT 				VARCHAR2(480) := 'AMW_DATA_IMPORT';

   v_risk_db_approval_status   				VARCHAR2(30);
   v_control_db_approval_status				VARCHAR2(30);

   v_invalid_requestor_msg	  				VARCHAR2(2000);
   v_no_import_privilege_msg	  			VARCHAR2(2000);
   v_invalid_risk_type	  					VARCHAR2(2000);

   v_risk_pending_msg		  				VARCHAR2(2000);
   v_control_pending_msg	  				VARCHAR2(2000);

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


   FUNCTION Risk_Can_Be_Processed RETURN Boolean
   IS
   BEGIN
     IF v_risk_db_approval_status = 'P' THEN
       update_interface_with_error (v_risk_pending_msg
                                ,'AMW_RISKS'
                                ,v_interface_id);
       return FALSE;
     END IF;
     return TRUE;
   END Risk_Can_Be_Processed;


   FUNCTION Control_Can_Be_Processed RETURN Boolean
   IS
   BEGIN
     IF v_control_db_approval_status = 'P' THEN
       update_interface_with_error (v_control_pending_msg
                                ,'AMW_CONTROLS'
                                ,v_interface_id);
       return FALSE;
     END IF;
     return TRUE;
   END Control_Can_Be_Processed;

/*****************************************************************************/
/*****************************************************************************/
   PROCEDURE create_risks_and_controls (
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
     ,p_user_id    IN              NUMBER
   )
   IS
/****************************************************/
      CURSOR risk_controls_cur
      IS
         SELECT risk_approval_status_code
               ,control_automation_type_code
               ,control_description
               ,control_location_code
               ,control_name
               ,control_type_code
			   ,control_application_id
               ,risk_impact_code
               ,risk_control_interface_id
               ,control_job_id
               ,risk_likelihood_code
               ,physical_evidence
               ,process_name
			   ,process_code
               ,risk_description
               ,risk_name
               ,risk_type_code
               ,control_source
               ,control_approval_status_code
               ,process_id
               ,parent_process_id
			   ,process_objective_id
			   ,process_objective_name
			   ,process_obj_description
			   ,upper(material) as material
			   ,decode(nvl(upper(material),'N'),'N',null,material_value) as material_value
			   ,ap_name
			   ,upper(nvl(design_effectiveness,'N')) as design_effectiveness
			   ,upper(nvl(op_effectiveness,'N')) as op_effectiveness
	   		   ,preventive_control
	   		   ,detective_control
	   		   ,disclosure_control
	   		   ,key_mitigating
	   		   ,verification_source
	   		   ,verification_source_name
	   		   ,verification_instruction
			   ,risk_type1
	       ,risk_type2
	       ,risk_type3
	       ,risk_type4
	       ,risk_type5
	       ,risk_type6
	       ,risk_type7
	       ,risk_type8
	       ,risk_type9
	       ,risk_type10
	       ,risk_type11
	       ,risk_type12
	       ,risk_type13
	       ,risk_type14
	       ,risk_type15
	       ,risk_type16
	       ,risk_type17
	       ,risk_type18
	       ,risk_type19
	       ,risk_type20
	       ,risk_type21
	       ,risk_type22
	       ,risk_type23
	       ,risk_type24
	       ,risk_type25
	       ,risk_type26
	       ,risk_type27
	       ,risk_type28
	       ,risk_type29
	       ,risk_type30
  		   ,control_comp1
	       ,control_comp2
	       ,control_comp3
	       ,control_comp4
	       ,control_comp5
	       ,control_comp6
	       ,control_comp7
	       ,control_comp8
	       ,control_comp9
	       ,control_comp10
	       ,control_comp11
	       ,control_comp12
	       ,control_comp13
	       ,control_comp14
	       ,control_comp15
	       ,control_comp16
	       ,control_comp17
	       ,control_comp18
	       ,control_comp19
	       ,control_comp20
	       ,control_comp21
	       ,control_comp22
	       ,control_comp23
	       ,control_comp24
	       ,control_comp25
	       ,control_comp26
	       ,control_comp27
	       ,control_comp28
	       ,control_comp29
	       ,control_comp30
		   ,control_obj1
	       ,control_obj2
	       ,control_obj3
	       ,control_obj4
	       ,control_obj5
	       ,control_obj6
	       ,control_obj7
	       ,control_obj8
	       ,control_obj9
	       ,control_obj10
	       ,control_obj11
	       ,control_obj12
	       ,control_obj13
	       ,control_obj14
	       ,control_obj15
	       ,control_obj16
	       ,control_obj17
	       ,control_obj18
	       ,control_obj19
	       ,control_obj20
	       ,control_obj21
	       ,control_obj22
	       ,control_obj23
	       ,control_obj24
	       ,control_obj25
	       ,control_obj26
	       ,control_obj27
	       ,control_obj28
	       ,control_obj29
	       ,control_obj30
	       ,control_assert1
	       ,control_assert2
	       ,control_assert3
	       ,control_assert4
	       ,control_assert5
	       ,control_assert6
	       ,control_assert7
	       ,control_assert8
	       ,control_assert9
	       ,control_assert10
	       ,control_assert11
	       ,control_assert12
	       ,control_assert13
	       ,control_assert14
	       ,control_assert15
	       ,control_assert16
	       ,control_assert17
	       ,control_assert18
	       ,control_assert19
	       ,control_assert20
	       ,control_assert21
	       ,control_assert22
	       ,control_assert23
	       ,control_assert24
	       ,control_assert25
	       ,control_assert26
	       ,control_assert27
	       ,control_assert28
	       ,control_assert29
	       ,control_assert30
	       ,revise_risk_flag
	       ,revise_ctrl_flag
		   --npanandi 12.10.2004: added the foll
		   --for Risk/Ctrl Classification
		   ,risk_classification
		   ,ctrl_classification
		   ,uom_code
           FROM amw_risk_ctrl_interface
          WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
            AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
            AND process_flag IS NULL
            AND error_flag IS NULL;

     CURSOR c_requestor_id IS
       SELECT party_id
         FROM amw_employees_current_v
        WHERE employee_id = (select employee_id
                               from fnd_user
                              where user_id = p_user_id)
          AND rownum = 1;

     CURSOR c_risk_exists (c_risk_name IN VARCHAR2) IS
       SELECT b.risk_id, b.approval_status
         FROM amw_risks_b b, amw_risks_tl tl
       WHERE tl.name = c_risk_name
	 AND tl.language = USERENV('LANG')
         AND tl.risk_rev_id = b.risk_rev_id
         AND b.latest_revision_flag='Y';

     CURSOR c_control_exists (c_control_name IN VARCHAR2) IS
       SELECT b.control_id, b.approval_status
         FROM amw_controls_b b, amw_controls_tl tl
       WHERE tl.name = c_control_name
	 AND tl.language = USERENV('LANG')
         AND tl.control_rev_id = b.control_rev_id
	 AND b.latest_revision_flag='Y';

	 --
	 --npanandi 11.24.2004 added for ProcessId check handling
	 --in Pl/Sql API instead of GroupValidator
	 --
	 CURSOR C_CHECK_VALIDITY IS
        SELECT PROCESS_ID
			  ,PROCESS_NAME
			  ,PROCESS_CODE
			  ,risk_control_interface_id
		  FROM AMW_RISK_CTRL_INTERFACE
	     WHERE CREATED_BY=DECODE(P_USER_ID,NULL,CREATED_BY,P_USER_ID)
	       AND BATCH_ID=DECODE(p_batch_id, NULL, batch_id, p_batch_id)
           AND process_flag IS NULL
           AND error_flag IS NULL
		   ---NPANANDI 12.09.2004: FIX TO CHECK ONLY
		   ---IF PROCESS NAME  ARE EITHER DEFINED
		   AND NOT (PROCESS_CODE IS NULL AND PROCESS_NAME IS NULL)
	     ORDER BY BATCH_ID DESc;

     l_api_version_number      		CONSTANT NUMBER   := 1.0;
     l_requestor_id			      			 NUMBER;
     l_amw_delt_risk_cntl_intf        		 VARCHAR2 (2);
     l_amw_control_name_prefix        		 VARCHAR2 (30);
     l_risk_rec			      				 AMW_RISK_PVT.risk_rec_type;
     l_control_rec		      				 AMW_CONTROL_PVT.control_rec_type;
     l_control_found                  		 BOOLEAN        default true;
	 l_process_obj_column					 BOOLEAN		default true;
     l_risk_approval_status_code      		 VARCHAR2(30);
     l_control_approval_status_code   		 VARCHAR2(30);
     l_control_name		      				 VARCHAR2(240);
     l_process_id		      				 NUMBER;
	 l_process_objective_id		      		 NUMBER;
	 l_application_id		  				 NUMBER;
	 l_process_objectives_count				 number;
	 l_risk_objectives_count				 number;

     lx_return_status		      			 VARCHAR2(30);
     lx_msg_count		      				 NUMBER;
     lx_msg_data		      				 VARCHAR2(2000);
     lx_risk_id			      				 NUMBER;
     lx_control_id		      				 NUMBER;
     lx_mode_affected		      			 VARCHAR2(30);
     l_object_type_count	      			 NUMBER;
     l_process_flag		      				 VARCHAR2(1);
     e_no_import_access               		 EXCEPTION;
     e_invalid_requestor_id           		 EXCEPTION;
	 e_invalid_risk_type           		 	 EXCEPTION;

     l_revise_risk_flag		      			 VARCHAR2(1);
     l_revise_control_flag	      			 VARCHAR2(1);
	 L_PROCESS_CODE							 VARCHAR2(30);

	 L_CONTROL_ASSOCIATION_ID				 NUMBER;
	 L_APPROVAL_DATE						 DATE;
	 L_AP_ASSOCIATION_ID					 NUMBER;

	 L_PROC_OBJ_ASSOCIATION_ID				 NUMBER;
	 L_PROC_OBJ_APPROVAL_DATE				 DATE;
	 L_RISK_OBJ_ASSOCIATION_ID				 NUMBER;
	 L_RISK_OBJ_APPROVAL_DATE				 DATE;
	 L_RISK_ASSOCIATION_ID					 NUMBER;
	 L_RISK_APPROVAL_DATE					 DATE;
	 L_AP_APPROVAL_DATE						 DATE;
	 L_ASSOC_AP_TO_CTRL						 BOOLEAN DEFAULT FALSE;

	 ---01.13.2005 NPANANDI: ADDED BELOW VARS FOR CTRL TO OBJ ASSOCIATION
	 L_CTRL_OBJ_ASSOCIATION_ID				 NUMBER;
	 L_CTRL_OBJ_APPROVAL_DATE				 DATE;
         l_ctrl_objective_id number;
	 ---02.28.2005 npanandi: added below variables for data security check
	 l_new_risk                           boolean default true;
     l_has_risk_access                    varchar2(15);
     l_new_control                        boolean default true;
     l_has_ctrl_access                    varchar2(15);

     ---03.02.2005 npanandi: added below vars for data security checks
     l_has_ap_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
     l_has_risk_ctrl_assn_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
     l_has_proc_obj_assoc_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
     l_has_proc_risk_assoc_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
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
     l_amw_delt_risk_cntl_intf :=
                       NVL(fnd_profile.VALUE ('AMW_DELT_RISK_CNTRL_INTF'), 'N');

--
--   get profile info for null control names and descriptions
--
     --02.01.2005 npanandi: fix for Customer to upload Controls with only sequence numbers
	 --l_amw_control_name_prefix := NVL(fnd_profile.VALUE ('AMW_CONTROL_NAME_PREFIX'), 'ORAC-');
	 --l_amw_control_name_prefix := fnd_profile.VALUE ('AMW_CONTROL_NAME_PREFIX');
	 l_amw_control_name_prefix := null;


     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                   p_token_name   => 'OBJ_TYPE',
                                   p_token_value  =>
			AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','RISK'));
     v_risk_pending_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_LAST,
					p_encoded => fnd_api.g_false);

     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                   p_token_name   => 'OBJ_TYPE',
                                   p_token_value  =>
			AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','CTRL'));
     v_control_pending_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_LAST,
					p_encoded => fnd_api.g_false);


---
---NPANANDI 11.24.2004
---CHECK THE DATA VALIDITY BETWEEN PROCESS_CODE,PROCESS_NAME,PROCESS_ID
---
	FOR VALID_REC IN C_CHECK_VALIDITY LOOP
	   BEGIN

	      --PROCESS_NAME, ORG_ID ARE ALWAYS NON-NULL
		  --PROCESS_CODE CAN BE NULL
		  IF(VALID_REC.PROCESS_CODE IS NULL) THEN
		     SELECT PROCESS_CODE,PROCESS_ID INTO L_PROCESS_CODE,L_PROCESS_ID
			   FROM AMW_LATEST_REVISIONS_V
		      WHERE DISPLAY_NAME=VALID_REC.PROCESS_NAME;
		  ELSE
		     SELECT PROCESS_CODE,PROCESS_ID INTO L_PROCESS_CODE,L_PROCESS_ID
			   FROM AMW_LATEST_REVISIONS_V
		      WHERE DISPLAY_NAME=VALID_REC.PROCESS_NAME
				AND PROCESS_CODE=VALID_REC.PROCESS_CODE;
		  END IF;
	   EXCEPTION
	      WHEN TOO_MANY_ROWS THEN
		     V_ERR_MSG := 'Multiple processes exist with same Process Name, please select Unique Process Code';
			 update_interface_with_error (v_err_msg
                                         ,'AMW_RISKS'
                                         ,VALID_REC.risk_control_interface_id);
		  WHEN NO_DATA_FOUND THEN
		     V_ERR_MSG := 'Please select valid combination of Process Name and Process Code';
			 update_interface_with_error (v_err_msg
                                         ,'AMW_RISKS'
                                         ,VALID_REC.risk_control_interface_id);
	   END;
	END LOOP;

--
--   loop processing each record
--
     FOR rc_rec IN risk_controls_cur LOOP
       BEGIN
	      v_interface_id := rc_rec.RISK_CONTROL_INTERFACE_ID;
	      l_risk_approval_status_code := rc_rec.risk_approval_status_code;
	      l_control_approval_status_code :=
		  rc_rec.control_approval_status_code;

	      l_revise_risk_flag := upper(NVL(rc_rec.revise_risk_flag, 'N'));
	      l_revise_control_flag := upper(NVL(rc_rec.revise_ctrl_flag, 'N'));
--
--   process risk
--
	 lx_risk_id := null;
	 v_risk_db_approval_status := null;
	 OPEN c_risk_exists(rc_rec.risk_name);
         FETCH c_risk_exists INTO lx_risk_id, v_risk_db_approval_status;
	 CLOSE c_risk_exists;

	 ---03.01.2005 npanandi: added data security checks
	 l_has_risk_access := 'T'; ---setting this to 'T' for new Risks
	 l_new_risk := true; ---setting this to TRUE to avoid conflict with previous loop value
	 if(lx_risk_id is not null) then
	    ---Check for Update privilege here
		l_new_risk := false;
		fnd_file.put_line (fnd_file.LOG, '************** Checking Update Privilege for rc_rec.risk_name: '||rc_rec.risk_name);
		l_has_risk_access := check_function(
				                     p_function           => 'AMW_RISK_UPDATE_PRVLG'
                                    ,p_object_name        => 'AMW_RISK'
                                    ,p_instance_pk1_value => lx_risk_id
                                    ,p_user_id            => fnd_global.user_id);
        fnd_file.put_line (fnd_file.LOG, 'l_has_risk_access: '||l_has_risk_access);
        fnd_file.put_line (fnd_file.LOG, '************** Checked Update Privilege for rc_rec.risk_name: '||rc_rec.risk_name);

        IF l_has_risk_access <> 'T' then
           v_err_msg := 'Cannot update this Risk';
		   update_interface_with_error (v_err_msg
                                       ,'AMW_RISKS'
			                           ,v_interface_id);
        END IF;
     end if;
	 ---03.01.2005 npanandi: added data security checks ends


	 L_PROCESS_ID := null;

	     FND_FILE.PUT_LINE(FND_FILE.LOG, 'GETTING PROCESS_ID');
		 --npanandi 12.09.2004: check to get processId
		 --only if processCode and processName are not both
		 --uniformly NULL
		 if(not (rc_rec.process_code is null and rc_rec.process_name is null))then
		    --executing these if blocks as before
		    if(rc_rec.process_code is null)then
		       FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_interface_id: '||v_interface_id||', process_code is null --> display_name: '||rc_rec.process_name);
		       select process_id into l_process_id
			     from amw_latest_revisions_v
			    where display_name=rc_rec.process_name;
		    else
		       FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_interface_id: '||v_interface_id||', process_code is exists --> display_name: '||rc_rec.process_name||', process_code: '||rc_rec.process_code);
		       select process_id into l_process_id
			     from amw_latest_revisions_v
			    where display_name=rc_rec.process_name
			      and process_code=rc_rec.process_code;
		    end if;
	     end if; --end of npanandi check 12.09.2004
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'GOT PROCESS_ID: '||l_process_id);

		 IF((L_PROCESS_ID IS NOT NULL) AND (L_PROCESS_ID <> -1)) THEN
		    FND_FILE.PUT_LINE(FND_FILE.LOG, '>>>>>>> Revising ProcessId: '||L_PROCESS_ID);
		    AMW_RL_HIERARCHY_PKG.revise_process_if_necessary(
		       P_PROCESS_ID => L_PROCESS_ID
		    );
		 END IF;


	     IF Risk_Can_Be_Processed AND
	        ---03.01.2005 npanandi: added check for lHasRiskAccess to update this Risk
            ---only if this user has Upd privilege
	        l_has_risk_access = 'T' and
	        (lx_risk_id is null OR
             l_revise_risk_flag = 'Y') THEN
	           l_risk_rec.risk_impact := rc_rec.risk_impact_code;
	           l_risk_rec.risk_type := rc_rec.risk_type_code;
	           l_risk_rec.approval_status := l_risk_approval_status_code;
	           l_risk_rec.likelihood := rc_rec.risk_likelihood_code;
	           l_risk_rec.risk_name := rc_rec.risk_name;
	           l_risk_rec.risk_description := rc_rec.risk_description;
	           l_risk_rec.requestor_id := l_requestor_id;
	           l_risk_rec.material := nvl(rc_rec.material,'N');
	           --npanandi 12.10.2004: added the following for Risk Classification
	           l_risk_rec.classification := rc_rec.risk_classification;
               /** Added this by Nilesh 08/29/2003
	               Currently Tsun Tsun's API needs a valid value for risk_type_code
		           But due to multiple Risk_Type_Associations, use of
		           Risk_Type_Code in amw_risks_b is now obsoleted
		           Hence passing a blank field!
		        **/
		       l_risk_rec.risk_type := 'C';

	           AMW_RISK_PVT.Load_Risk(
		          p_api_version_number => l_api_version_number,
		          p_init_msg_list      => FND_API.G_TRUE,
		          p_commit             => FND_API.G_FALSE,
		          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		          p_risk_rec           => l_risk_rec,
		          x_return_status      => lx_return_status,
	              x_msg_count          => lx_msg_count,
		          x_msg_data           => lx_msg_data,
		          x_risk_rev_id        => lx_risk_rev_id,
		          x_risk_id	     	   => lx_risk_id
		       );

		       ---03.01.2005 npanandi: if new Control, grant CtrlOwner prvlg
               if(l_new_risk) then
			      add_owner_privilege(
				     p_role_name          => 'AMW_RISK_OWNER_ROLE'
					,p_object_name        => 'AMW_RISK'
					,p_grantee_type       => 'P'
					,p_instance_pk1_value => lx_risk_id
					,p_user_id            => FND_GLOBAL.USER_ID);
               end if;
               ---02.28.2005 npanandi: if new Control, grant CtrlOwner prvlg

		       fnd_file.put_line (fnd_file.LOG,'lx_return_status: '||lx_return_status);
		       fnd_file.put_line (fnd_file.LOG,'lx_risk_rev_id: '||lx_risk_rev_id);
		       fnd_file.put_line (fnd_file.LOG,'lx_risk_id: '||lx_risk_id);

	          IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
	             v_err_msg := ' ';
	             FOR x IN 1..lx_msg_count LOOP
	                if(length(v_err_msg) < 1800) then
	                   v_err_msg := v_err_msg||' '||substr(fnd_msg_pub.get(p_msg_index => x,
					                              p_encoded => fnd_api.g_false), 1,100);
	                end if;
	             END LOOP;
	             update_interface_with_error (v_err_msg
                                       ,'AMW_RISKS'
                                       ,v_interface_id);
	          END IF;

	   --
	   -- process risk types
	   --
       /*** 05.19.2006 npanandi: bug 5210357 fix --- setting the global parameter value to zero, else
	        Risks with no RiskTypes get uploaded ***/
	   v_valid_risk_type := 0;
	   /*** 05.19.2006 npanandi: bug 5210357 fix ends ***/

	   IF NOT v_error_found THEN
	     risk_types(rc_rec.risk_type1, '1', 'n');
	     risk_types(rc_rec.risk_type2, '2', 'n');
	     risk_types(rc_rec.risk_type3, '3', 'n');
	     risk_types(rc_rec.risk_type4, '4', 'n');
	     risk_types(rc_rec.risk_type5, '5', 'n');
	     risk_types(rc_rec.risk_type6, '6', 'n');
	     risk_types(rc_rec.risk_type7, '7', 'n');
	     risk_types(rc_rec.risk_type8, '8', 'n');
	     risk_types(rc_rec.risk_type9, '9', 'n');
	     risk_types(rc_rec.risk_type10, '10', 'n');
	     risk_types(rc_rec.risk_type11, '11', 'n');
	     risk_types(rc_rec.risk_type12, '12', 'n');
	     risk_types(rc_rec.risk_type13, '13', 'n');
	     risk_types(rc_rec.risk_type14, '14', 'n');
	     risk_types(rc_rec.risk_type15, '15', 'n');
	     risk_types(rc_rec.risk_type16, '16', 'n');
	     risk_types(rc_rec.risk_type17, '17', 'n');
	     risk_types(rc_rec.risk_type18, '18', 'n');
	     risk_types(rc_rec.risk_type19, '19', 'n');
	     risk_types(rc_rec.risk_type20, '20', 'n');
	     risk_types(rc_rec.risk_type21, '21', 'n');
	     risk_types(rc_rec.risk_type22, '22', 'n');
	     risk_types(rc_rec.risk_type23, '23', 'n');
	     risk_types(rc_rec.risk_type24, '24', 'n');
	     risk_types(rc_rec.risk_type25, '25', 'n');
	     risk_types(rc_rec.risk_type26, '26', 'n');
	     risk_types(rc_rec.risk_type27, '27', 'n');
	     risk_types(rc_rec.risk_type28, '28', 'n');
	     risk_types(rc_rec.risk_type29, '29', 'n');
	     risk_types(rc_rec.risk_type30, '30', 'y');
	   END IF; --end of if for v_error_found
	 END IF; -- end of process risk
--
--    only process control then control info exists
--
	 l_control_found := true;
	 IF rc_rec.control_automation_type_code is null
                AND rc_rec.control_description is null
                AND rc_rec.control_location_code is null
                AND rc_rec.control_name is null
                AND rc_rec.control_type_code is null
                AND rc_rec.control_job_id is null
                AND rc_rec.physical_evidence is null
                AND rc_rec.control_source is null
				AND rc_rec.preventive_control is null
				AND rc_rec.detective_control is null
				AND rc_rec.disclosure_control is null
				AND rc_rec.key_mitigating is null
				AND rc_rec.verification_source is null
				AND rc_rec.verification_source_name is null
				AND rc_rec.verification_instruction is null
				AND rc_rec.control_comp1 is null
	        AND rc_rec.control_comp2 is null
	        AND rc_rec.control_comp3 is null
	        AND rc_rec.control_comp4 is null
	        AND rc_rec.control_comp5 is null
	        AND rc_rec.control_comp6 is null
	        AND rc_rec.control_comp7 is null
	        AND rc_rec.control_comp8 is null
	        AND rc_rec.control_comp9 is null
	        AND rc_rec.control_comp10 is null
	        AND rc_rec.control_comp11 is null
	        AND rc_rec.control_comp12 is null
	        AND rc_rec.control_comp13 is null
	        AND rc_rec.control_comp14 is null
	        AND rc_rec.control_comp15 is null
	        AND rc_rec.control_comp16 is null
	        AND rc_rec.control_comp17 is null
	        AND rc_rec.control_comp18 is null
	        AND rc_rec.control_comp19 is null
	        AND rc_rec.control_comp20 is null
	        AND rc_rec.control_comp21 is null
	        AND rc_rec.control_comp22 is null
	        AND rc_rec.control_comp23 is null
	        AND rc_rec.control_comp24 is null
	        AND rc_rec.control_comp25 is null
	        AND rc_rec.control_comp26 is null
	        AND rc_rec.control_comp27 is null
	        AND rc_rec.control_comp28 is null
	        AND rc_rec.control_comp29 is null
	        AND rc_rec.control_comp30 is null
	        AND rc_rec.control_obj1 is null
	        AND rc_rec.control_obj2 is null
	        AND rc_rec.control_obj3 is null
	        AND rc_rec.control_obj4 is null
	        AND rc_rec.control_obj5 is null
	        AND rc_rec.control_obj6 is null
	        AND rc_rec.control_obj7 is null
	        AND rc_rec.control_obj8 is null
	        AND rc_rec.control_obj9 is null
	        AND rc_rec.control_obj10 is null
	        AND rc_rec.control_obj11 is null
	        AND rc_rec.control_obj12 is null
	        AND rc_rec.control_obj13 is null
	        AND rc_rec.control_obj14 is null
	        AND rc_rec.control_obj15 is null
	        AND rc_rec.control_obj16 is null
	        AND rc_rec.control_obj17 is null
	        AND rc_rec.control_obj18 is null
	        AND rc_rec.control_obj19 is null
	        AND rc_rec.control_obj20 is null
	        AND rc_rec.control_obj21 is null
	        AND rc_rec.control_obj22 is null
	        AND rc_rec.control_obj23 is null
	        AND rc_rec.control_obj24 is null
	        AND rc_rec.control_obj25 is null
	        AND rc_rec.control_obj26 is null
	        AND rc_rec.control_obj27 is null
	        AND rc_rec.control_obj28 is null
	        AND rc_rec.control_obj29 is null
	        AND rc_rec.control_obj30 is null
	        AND rc_rec.control_assert1 is null
	        AND rc_rec.control_assert2 is null
	        AND rc_rec.control_assert3 is null
	        AND rc_rec.control_assert4 is null
	        AND rc_rec.control_assert5 is null
	        AND rc_rec.control_assert6 is null
	        AND rc_rec.control_assert7 is null
	        AND rc_rec.control_assert8 is null
	        AND rc_rec.control_assert9 is null
	        AND rc_rec.control_assert10 is null
	        AND rc_rec.control_assert11 is null
	        AND rc_rec.control_assert12 is null
	        AND rc_rec.control_assert13 is null
	        AND rc_rec.control_assert14 is null
	        AND rc_rec.control_assert15 is null
	        AND rc_rec.control_assert16 is null
	        AND rc_rec.control_assert17 is null
	        AND rc_rec.control_assert18 is null
	        AND rc_rec.control_assert19 is null
	        AND rc_rec.control_assert20 is null
	        AND rc_rec.control_assert21 is null
	        AND rc_rec.control_assert22 is null
	        AND rc_rec.control_assert23 is null
	        AND rc_rec.control_assert24 is null
	        AND rc_rec.control_assert25 is null
	        AND rc_rec.control_assert26 is null
	        AND rc_rec.control_assert27 is null
	        AND rc_rec.control_assert28 is null
	        AND rc_rec.control_assert29 is null
	        AND rc_rec.control_assert30 is null
            AND rc_rec.control_approval_status_code is null
			---npanandi 12.10.2004: added foll. for Ctrl Classification
			AND rc_rec.ctrl_classification is null
			THEN
	   l_control_found := false;
	 END IF;

	 IF l_control_found THEN
--
--    process control
--
	   lx_control_id := null;
	   v_control_db_approval_status := null;
	   OPEN c_control_exists(rc_rec.control_name);
           FETCH c_control_exists INTO lx_control_id, v_control_db_approval_status;
	   CLOSE c_control_exists;

	   ---03.01.2005 npanandi: added data security checks
	   l_has_ctrl_access := 'T'; ---setting this to 'T' for new Risks
	   l_new_control := true; ---setting this to TRUE to avoid conflict with previous loop value
	   if(lx_control_id is not null) then
	      ---Check for Update privilege here
		  l_new_control := false;
		  fnd_file.put_line (fnd_file.LOG, '************** Checking Update Privilege for rc_rec.control_name: '||rc_rec.control_name);
		  l_has_ctrl_access := check_function(
				                     p_function           => 'AMW_CTRL_UPDATE_PRVLG'
                                    ,p_object_name        => 'AMW_CONTROL'
                                    ,p_instance_pk1_value => lx_control_id
                                    ,p_user_id            => fnd_global.user_id);
          fnd_file.put_line (fnd_file.LOG, 'l_has_ctrl_access: '||l_has_ctrl_access);
          fnd_file.put_line (fnd_file.LOG, '************** Checked Update Privilege for rc_rec.control_name: '||rc_rec.control_name);

          IF l_has_ctrl_access <> 'T' then
             v_err_msg := 'Cannot update this Ctrl';
		     update_interface_with_error (v_err_msg
                                       ,'AMW_CONTROLS'
			                           ,v_interface_id);
          END IF;
       end if;
	   ---03.01.2005 npanandi: added data security checks ends


       IF Control_Can_Be_Processed AND
          ---02.28.2005 npanandi: added check for lHasAccess to update this Ctrl
          ---only if this user has Upd privilege
	      l_has_ctrl_access = 'T' and
	      (lx_control_id is null OR
	       l_revise_control_flag = 'Y') THEN

	             SELECT DECODE (rc_rec.control_name,NULL
			                   ,l_amw_control_name_prefix||amw_controls_tl_s1.NEXTVAL
                               ,rc_rec.control_name)
	               INTO l_control_name
	               FROM dual;

  	     l_control_rec.name := l_control_name;
	     l_control_rec.description := nvl(rc_rec.CONTROL_DESCRIPTION, l_control_name);
	     l_control_rec.approval_status := l_control_approval_status_code;
	     l_control_rec.control_type := rc_rec.CONTROL_TYPE_CODE;
	     l_control_rec.source := rc_rec.CONTROL_SOURCE;
	     l_control_rec.control_location := rc_rec.CONTROL_LOCATION_CODE;
	     l_control_rec.automation_type:= rc_rec.CONTROL_AUTOMATION_TYPE_CODE;
	     l_control_rec.job_id := rc_rec.CONTROL_JOB_ID;
	     l_control_rec.physical_evidence := rc_rec.PHYSICAL_EVIDENCE;
	     l_control_rec.requestor_id := l_requestor_id;
		 l_control_rec.application_id := rc_rec.control_application_id;

         -- KOSRINIV Changes on 2 April 2004...
	    l_control_rec.preventive_control := rc_rec.preventive_control;
	    l_control_rec.detective_control :=	rc_rec.detective_control;
	    l_control_rec.disclosure_control :=	rc_rec.disclosure_control;
 	    l_control_rec.key_mitigating := rc_rec.key_mitigating;
	    l_control_rec.verification_source :=	 rc_rec.verification_source;
	    l_control_rec.verification_source_name :=	rc_rec.verification_source_name;
	    l_control_rec.verification_instruction := rc_rec.verification_instruction;

		---npanandi 12.10.2004: added foll. for Ctrl Classification
		l_control_rec.classification := rc_rec.ctrl_classification;
		l_control_rec.uom_code := rc_rec.uom_code;
	     AMW_CONTROL_PVT.Load_Control(
		p_api_version_number => l_api_version_number,
		p_init_msg_list      => FND_API.G_TRUE,
		p_commit             => FND_API.G_FALSE,
		p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		p_control_rec        => l_control_rec,
		x_return_status      => lx_return_status,
		x_msg_count          => lx_msg_count,
		x_msg_data           => lx_msg_data,
		x_control_rev_id     => vx_control_rev_id,
		x_control_id	     => lx_control_id,
		x_mode_affected      => lx_mode_affected
		);

		---03.01.2005 npanandi: if new Control, grant CtrlOwner prvlg
	    if(l_new_control) then
		   add_owner_privilege(
		      p_role_name          => 'AMW_CTRL_OWNER_ROLE'
             ,p_object_name        => 'AMW_CONTROL'
			 ,p_grantee_type       => 'P'
			 ,p_instance_pk1_value => lx_control_id
			 ,p_user_id            => FND_GLOBAL.USER_ID);
		end if;
		---03.01.2005 npanandi: if new Control, grant CtrlOwner prvlg

		fnd_file.put_line (fnd_file.LOG,'lx_return_status: '||lx_return_status);
		fnd_file.put_line (fnd_file.LOG,'lx_risk_rev_id: '||lx_risk_rev_id);
		fnd_file.put_line (fnd_file.LOG,'vx_control_rev_id: '||vx_control_rev_id);

	     IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
	       v_err_msg := ' ';
	       FOR x IN 1..lx_msg_count LOOP
	         if(length(v_err_msg) < 1800) then
	           v_err_msg := v_err_msg||' '
			||substr(fnd_msg_pub.get(p_msg_index => x,
					p_encoded => fnd_api.g_false), 1,100);
	         end if;
	       END LOOP;
	       update_interface_with_error (v_err_msg
                                       ,'AMW_CONTROLS'
                                       ,v_interface_id);
	     END IF;

		 IF NOT v_error_found THEN
--
-- process control components
--
		     control_components(rc_rec.control_comp1, '1');
		     control_components(rc_rec.control_comp2, '2');
		     control_components(rc_rec.control_comp3, '3');
		     control_components(rc_rec.control_comp4, '4');
		     control_components(rc_rec.control_comp5, '5');
		     control_components(rc_rec.control_comp6, '6');
		     control_components(rc_rec.control_comp7, '7');
		     control_components(rc_rec.control_comp8, '8');
		     control_components(rc_rec.control_comp9, '9');
		     control_components(rc_rec.control_comp10, '10');
		     control_components(rc_rec.control_comp11, '11');
		     control_components(rc_rec.control_comp12, '12');
		     control_components(rc_rec.control_comp13, '13');
		     control_components(rc_rec.control_comp14, '14');
		     control_components(rc_rec.control_comp15, '15');
		     control_components(rc_rec.control_comp16, '16');
		     control_components(rc_rec.control_comp17, '17');
		     control_components(rc_rec.control_comp18, '18');
		     control_components(rc_rec.control_comp19, '19');
		     control_components(rc_rec.control_comp20, '20');
		     control_components(rc_rec.control_comp21, '21');
		     control_components(rc_rec.control_comp22, '22');
		     control_components(rc_rec.control_comp23, '23');
		     control_components(rc_rec.control_comp24, '24');
		     control_components(rc_rec.control_comp25, '25');
		     control_components(rc_rec.control_comp26, '26');
		     control_components(rc_rec.control_comp27, '27');
		     control_components(rc_rec.control_comp28, '28');
		     control_components(rc_rec.control_comp29, '29');
		     control_components(rc_rec.control_comp30, '30');


--
-- process control objectives
--
		     control_objectives(rc_rec.control_obj1, '1');
		     control_objectives(rc_rec.control_obj2, '2');
		     control_objectives(rc_rec.control_obj3, '3');
		     control_objectives(rc_rec.control_obj4, '4');
		     control_objectives(rc_rec.control_obj5, '5');
		     control_objectives(rc_rec.control_obj6, '6');
		     control_objectives(rc_rec.control_obj7, '7');
		     control_objectives(rc_rec.control_obj8, '8');
		     control_objectives(rc_rec.control_obj9, '9');
		     control_objectives(rc_rec.control_obj10, '10');
		     control_objectives(rc_rec.control_obj11, '11');
		     control_objectives(rc_rec.control_obj12, '12');
		     control_objectives(rc_rec.control_obj13, '13');
		     control_objectives(rc_rec.control_obj14, '14');
		     control_objectives(rc_rec.control_obj15, '15');
		     control_objectives(rc_rec.control_obj16, '16');
		     control_objectives(rc_rec.control_obj17, '17');
		     control_objectives(rc_rec.control_obj18, '18');
		     control_objectives(rc_rec.control_obj19, '19');
		     control_objectives(rc_rec.control_obj20, '20');
		     control_objectives(rc_rec.control_obj21, '21');
		     control_objectives(rc_rec.control_obj22, '22');
		     control_objectives(rc_rec.control_obj23, '23');
		     control_objectives(rc_rec.control_obj24, '24');
		     control_objectives(rc_rec.control_obj25, '25');
		     control_objectives(rc_rec.control_obj26, '26');
		     control_objectives(rc_rec.control_obj27, '27');
		     control_objectives(rc_rec.control_obj28, '28');
		     control_objectives(rc_rec.control_obj29, '29');
		     control_objectives(rc_rec.control_obj30, '30');
--
-- process control assertions
--
		     control_assertions(rc_rec.control_assert1, '1');
		     control_assertions(rc_rec.control_assert2, '2');
		     control_assertions(rc_rec.control_assert3, '3');
		     control_assertions(rc_rec.control_assert4, '4');
		     control_assertions(rc_rec.control_assert5, '5');
		     control_assertions(rc_rec.control_assert6, '6');
		     control_assertions(rc_rec.control_assert7, '7');
		     control_assertions(rc_rec.control_assert8, '8');
		     control_assertions(rc_rec.control_assert9, '9');
		     control_assertions(rc_rec.control_assert10, '10');
		     control_assertions(rc_rec.control_assert11, '11');
		     control_assertions(rc_rec.control_assert12, '12');
		     control_assertions(rc_rec.control_assert13, '13');
		     control_assertions(rc_rec.control_assert14, '14');
		     control_assertions(rc_rec.control_assert15, '15');
		     control_assertions(rc_rec.control_assert16, '16');
		     control_assertions(rc_rec.control_assert17, '17');
		     control_assertions(rc_rec.control_assert18, '18');
		     control_assertions(rc_rec.control_assert19, '19');
		     control_assertions(rc_rec.control_assert20, '20');
		     control_assertions(rc_rec.control_assert21, '21');
		     control_assertions(rc_rec.control_assert22, '22');
		     control_assertions(rc_rec.control_assert23, '23');
		     control_assertions(rc_rec.control_assert24, '24');
		     control_assertions(rc_rec.control_assert25, '25');
		     control_assertions(rc_rec.control_assert26, '26');
		     control_assertions(rc_rec.control_assert27, '27');
		     control_assertions(rc_rec.control_assert28, '28');
		     control_assertions(rc_rec.control_assert29, '29');
		     control_assertions(rc_rec.control_assert30, '30');
		   END IF; --- end of if for v_error_found ....
           END IF; -- end of IF lx_control_id is null OR...

--
-- create the control associations
--

		   IF (NOT v_error_found AND L_PROCESS_ID IS NOT NULL AND L_PROCESS_ID <> -1) THEN
			   --SET THESE 2 VARIABLES TO NULL FOR THIS LOOP
			   L_CONTROL_ASSOCIATION_ID := NULL;
			   L_APPROVAL_DATE			:= NULL;
			   --CHECK FOR EXISTING LATEST_REVISION OF THIS ASSOCIATION, IF ANY
			   fnd_file.PUT_LINE(fnd_file.log, 'L_PROCESS_ID: '||L_PROCESS_ID||', LX_RISK_ID: '||LX_RISK_ID);
		       BEGIN
			      SELECT CONTROL_ASSOCIATION_ID,APPROVAL_DATE
		            INTO L_CONTROL_ASSOCIATION_ID,L_APPROVAL_DATE
			        FROM AMW_CONTROL_ASSOCIATIONS
			       WHERE CONTROL_ID=LX_CONTROL_ID
			         AND PK1=L_PROCESS_ID
				     AND PK2=LX_RISK_ID
				     AND OBJECT_TYPE='RISK'
				     AND DELETION_DATE IS NULL;
			   EXCEPTION
			      WHEN NO_DATA_FOUND THEN
				     NULL;
			   END;

               ---03.02.2005 npanandi: check here to see if this Process has
               ---AMW_UPD_RL_PROC_RISK_CTRL_ASSN privilege to associate this Risk to Ctrl
               l_has_risk_ctrl_assn_access := 'T'; --setting this to 'T' to avoid conflict
                                                   --with value from previous loop
               l_has_risk_ctrl_assn_access := check_function(
                          p_function           => 'AMW_UPD_RL_PROC_RISK_CTRL_ASSN'
                         ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                         ,p_instance_pk1_value => l_PROCESS_ID
                         ,p_user_id            => fnd_global.user_id);
               fnd_file.put_line(fnd_file.log,'%%%%%%%%%%%%%%%%%% l_has_risk_ctrl_assn_access: '||l_has_risk_ctrl_assn_access||' %%%%%%%%%%%%%%%%%%');

			   IF(L_CONTROL_ASSOCIATION_ID IS NULL and l_has_risk_ctrl_assn_access = 'T') THEN
			     --NO ROW RETRIEVED, SO ASSOCIATION DOESN'T EXIST YET
			     --CREATE AN ASSOCIATION
				 CREATE_AMW_CTRL_ASSOC(
				   P_CONTROL_ID => lx_control_id
				  ,P_PROCESS_ID => L_PROCESS_ID
				  ,P_RISK_ID    => lx_risk_id
				 );
			   ELSE
			     --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

				 --IF APPROVAL_DATE IS NULL FOR CONTROL_ASSOCIATIONS,
				 --THIS MEANS THAT THIS ASSOCIATIONS
				 --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
				 --but of course, for Ctrl - Risk Associations, there ARE NO
				 --association attributes ....
				 IF(L_APPROVAL_DATE IS NOT NULL and l_has_risk_ctrl_assn_access = 'T') THEN
				   --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
				   --AND IS APPROVED, SO
				   BEGIN
				     UPDATE AMW_CONTROL_ASSOCIATIONS
				        SET DELETION_DATE=SYSDATE
					       ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
						   ,LAST_UPDATE_DATE=SYSDATE
						   ,LAST_UPDATED_BY=G_USER_ID
						   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
					  WHERE CONTROL_ASSOCIATION_ID=L_CONTROL_ASSOCIATION_ID;

					 -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
				     CREATE_AMW_CTRL_ASSOC(
				       P_CONTROL_ID => lx_control_id
				      ,P_PROCESS_ID => L_PROCESS_ID
				      ,P_RISK_ID    => lx_risk_id
				     );
				   EXCEPTION
				     WHEN OTHERS THEN
					   V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
					   UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
				   END;
				 END IF; --END OF IF FOR APPROVAL DATE NULL CHECK
               --END IF; -- end of complex if condition
             END IF; -- end of L_CONTROL_ASSOCIATION_ID NULLITY CHK
           END IF; -- end of if not v_error_found

---
---Create the Audit_Procedure_Association
---
		   IF ((NOT v_error_found) AND (rc_rec.ap_name IS NOT NULL)) THEN
		      if(rc_rec.design_effectiveness = 'N' and rc_rec.op_effectiveness = 'N') then
			     ---fnd_message.set_name('AMW','AMW_ASSOC_AP_EFF_WEBADI_MSG');
				 v_err_msg := fnd_message.GET_STRING('AMW','AMW_ASSOC_AP_EFF_WEBADI_MSG');
				 ---v_err_msg := fnd_message.get;
				 update_interface_with_error (v_err_msg
                                             ,v_table_name
                                             ,v_interface_id);
			  else
		         fnd_file.put_line (fnd_file.LOG,'%%%%%% Processing AP_Association data');
                 fnd_file.PUT_LINE(fnd_file.log, 'CREATING AP_ASSOCIATIONS HERE');
				 --SET THESE 2 VARS TO NULL FOR PROCESSING THIS LOOP
				 L_AP_ASSOCIATION_ID := NULL;
				 L_AP_APPROVAL_DATE	 := NULL;
				 --NPANANDI 10/26/2004: CHANGED THE ABOVE SELECT CHECK
				 --FOR EXISTING AP 2 CTRL ASSOCIATION
				 BEGIN
				    SELECT AP_ASSOCIATION_ID,APPROVAL_DATE
				      INTO L_AP_ASSOCIATION_ID,L_AP_APPROVAL_DATE
				      FROM AMW_AP_ASSOCIATIONS
				     WHERE AUDIT_PROCEDURE_ID=RC_REC.AP_NAME
				       AND PK1=LX_CONTROL_ID
					   AND OBJECT_TYPE='CTRL'
					   AND DELETION_DATE IS NULL;
				 EXCEPTION
				    WHEN OTHERS THEN
					   NULL; --DO NOTHING
				 END;

				 fnd_file.PUT_LINE(fnd_file.log, 'L_AP_ASSOCIATION_ID: '||L_AP_ASSOCIATION_ID||', L_AP_APPROVAL_DATE: '||L_AP_APPROVAL_DATE);
				 L_ASSOC_AP_TO_CTRL := FALSE;
				 IF((((l_revise_control_flag ='Y' OR v_control_db_approval_status is null)
		            AND l_control_approval_status_code = 'A')
		  	        OR (l_revise_control_flag='N' and v_control_db_approval_status='A'))) THEN
				   L_ASSOC_AP_TO_CTRL := TRUE;
				 END IF;

                 ---03.01.2005 npanandi: check here to see if this AP has AMW_UPDATE_AP_DETAILS
                 ---privilege to associate this Control to AP
                 l_has_ap_access := check_function(
                          p_function           => 'AMW_UPDATE_AP_DETAILS'
                         ,p_object_name        => 'AMW_AUDIT_PROCEDURE'
                         ,p_instance_pk1_value => RC_REC.AP_NAME
                         ,p_user_id            => fnd_global.user_id);
                 fnd_file.put_line(fnd_file.log,'%%%%%%%%%%%%%%%%%% l_has_ap_access: '||l_has_ap_access||' %%%%%%%%%%%%%%%%%%');

				 IF(L_ASSOC_AP_TO_CTRL and l_has_ap_access = 'T') THEN --putting this check, because Ctrl
					                         --to AP association is only for Approved Ctrls

				    fnd_file.put_line (fnd_file.LOG,'l_object_type_count --> '||l_object_type_count);
                    ---IF l_object_type_count = 0 THEN
				    IF( L_AP_ASSOCIATION_ID IS NULL) THEN
				       --for associating between Controls , take due cognizance of the
					   --revise flags  the following gory logic!
                       fnd_file.PUT_LINE(fnd_file.log, 'L_ASSOC_AP_TO_CTRL: MUST BE TRUE, HENCE I AM HERE');
				       fnd_file.put_line (fnd_file.LOG,'~~~~~~~~~~~~~~~~~~~AP_Association processable, values to be entered: ');
				       fnd_file.put_line (fnd_file.LOG,'pk1: '||lx_control_id);
				       fnd_file.put_line (fnd_file.LOG,'audit_procedure_id: '||rc_rec.ap_name);

					   --NPANANDI 12/09/2004:
					   --WHEN CTRL TO AP ASSOCIATION IS BEING DONE, POST AMW.D
					   --AP NEEDS TO BE REVISED
					   --THIS IS HANDLED IN CREATE_AMW_AP_ASSOC
					   fnd_file.PUT_LINE(fnd_file.log, 'CREATE_AMW_AP_ASSOC START');
					   LX_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
					   LX_MSG_COUNT := 0;
					   LX_MSG_DATA := NULL;
                       CREATE_AMW_AP_ASSOC(
					     P_CONTROL_ID 			=> lx_control_id
					    ,P_AUDIT_PROCEDURE_ID	=> rc_rec.ap_name
					    ,P_DESIGN_EFFECTIVENESS => rc_rec.design_effectiveness
					    ,P_OP_EFFECTIVENESS 	=> rc_rec.op_effectiveness
						,X_RETURN_STATUS		=> LX_RETURN_STATUS
						,X_MSG_COUNT			=> LX_MSG_COUNT
						,X_MSG_DATA				=> LX_MSG_DATA
					   );
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
		                                             ,'AMW_AP_ASSOCIATIONS'
		                                             ,v_interface_id);
	                   END IF;
					   fnd_file.PUT_LINE(fnd_file.log, 'CREATE_AMW_AP_ASSOC END');
				    ELSE
				       --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

					   --IF APPROVAL_DATE IS NULL FOR CONTROL_ASSOCIATIONS,
					   --THIS MEANS THAT THIS ASSOCIATIONS
					   --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
					   IF(L_AP_APPROVAL_DATE IS NOT NULL) THEN
					      --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
				          --AND IS APPROVED, SO
					      fnd_file.PUT_LINE(fnd_file.log, 'UPSERTING AP 2 CTRL ASSOCIATION');
					      BEGIN
					         UPDATE AMW_AP_ASSOCIATIONS
				                SET DELETION_DATE=SYSDATE
					               ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
						           ,LAST_UPDATE_DATE=SYSDATE
						           ,LAST_UPDATED_BY=G_USER_ID
						           ,LAST_UPDATE_LOGIN=G_LOGIN_ID
					          WHERE AP_ASSOCIATION_ID=L_AP_ASSOCIATION_ID;

						     -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
					         CREATE_AMW_AP_ASSOC(
					            P_CONTROL_ID 			=> lx_control_id
					           ,P_AUDIT_PROCEDURE_ID	=> rc_rec.ap_name
					           ,P_DESIGN_EFFECTIVENESS 	=> rc_rec.design_effectiveness
					           ,P_OP_EFFECTIVENESS 		=> rc_rec.op_effectiveness
						       ,X_RETURN_STATUS		=> LX_RETURN_STATUS
						       ,X_MSG_COUNT			=> LX_MSG_COUNT
						       ,X_MSG_DATA				=> LX_MSG_DATA
					         );
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
				                                             ,'AMW_AP_ASSOCIATIONS'
				                                             ,v_interface_id);
			                 END IF;
					      EXCEPTION
					         WHEN OTHERS THEN
					            V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
					            UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
					      END;
					   ELSE
					      --THIS MEANS THAT AP 2 CTRL ASSOCIATION IS LATEST REVISION
					      -- YET APPROVED, SO
				          --SIMPLY UPDATE THE ASSOCIATION ATTRIBUTES HERE
					      fnd_file.PUT_LINE(fnd_file.log, 'UPDATING AP 2 CTRL ASSOCIATION --> L_AP_ASSOCIATION_ID: '||L_AP_ASSOCIATION_ID);
					      --IF(L_ASSOC_AP_TO_CTRL) THEN
					      BEGIN
					         UPDATE AMW_AP_ASSOCIATIONS
					            SET DESIGN_EFFECTIVENESS=rc_rec.design_effectiveness
					               ,OP_EFFECTIVENESS=rc_rec.op_effectiveness
						           ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
						           ,LAST_UPDATE_DATE=SYSDATE
						           ,LAST_UPDATED_BY=G_USER_ID
						           ,LAST_UPDATE_LOGIN=G_LOGIN_ID
					          WHERE AP_ASSOCIATION_ID=L_AP_ASSOCIATION_ID;
						  EXCEPTION
						     WHEN OTHERS THEN
						        V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
					            UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
						  END;
					   END IF; --END OF L_APPROVAL_DATE IS NOT NULL CHECK
				    END IF; -- end of L_AP_ASSOCIATION_ID IS NULL if block
				 END IF; --END OF CTRL APPR STATUS CHECK FOR AP - CTRL ASSOCIATION
		      END IF; -- end of if Design_Eff and Op_Eff not null
           END IF; -- end of if not v_error_found
         END IF; -- end of IF l_control_found THEN

--
--create the Process_Objective
--
		 lx_return_status := FND_API.G_RET_STS_SUCCESS;
		 vx_process_objective_id := null; ---Process_Objective_Id being reset here
		 						 		 ---because for this loop, it is different
			l_process_obj_column := TRUE;
			if(rc_rec.process_objective_name is null or (trim(rc_rec.process_objective_name) = ''))then
			  l_process_obj_column := FALSE;
			end if;

			---if(not ((rc_rec.process_objective_name is null) or (trim(rc_rec.process_objective_name) = ' ')))then
			---if(not ((rc_rec.process_objective_name is null) or (trim(rc_rec.process_objective_name) = '')))then
			if(l_process_obj_column = true)then
			 fnd_file.put_line(fnd_file.LOG,'########## Before Going to Create_Process_Objectives');
			 fnd_file.put_line(fnd_file.LOG,'vx_process_objective_id: '||vx_process_objective_id);
			 create_process_objectives(p_process_objective_name 	  => rc_rec.process_objective_name,
			 						   p_process_obj_description 	  => rc_rec.process_obj_description,
			 						   p_requestor_id				  => l_requestor_id,
			 						   x_return_status				  => lx_return_status);

	         fnd_file.put_line(fnd_file.LOG,'########## After Going to Create_Process_Objectives');
			 fnd_file.put_line(fnd_file.LOG,'vx_process_objective_id: '||vx_process_objective_id);

	         IF lx_return_status <> FND_API.G_RET_STS_SUCCESS then
			   v_err_msg := ' ';
		       FOR x IN 1..lx_msg_count LOOP
		         if(length(v_err_msg) < 1800) then
		           v_err_msg := v_err_msg||' '
				||substr(fnd_msg_pub.get(p_msg_index => x,
						p_encoded => fnd_api.g_false), 1,100);
		         end if;
		       END LOOP;
		       update_interface_with_error (v_err_msg
	                                       ,'AMW_PROCESS_OBJECTIVES'
	                                       ,v_interface_id);
		     END IF;
		end if; --end of if for process obj name nulkl
--
-- create the process objective associations
--
 		 l_process_objective_id := vx_process_objective_id;

		 ---fnd_file.put_line (fnd_file.LOG, 'v_error_found: '||v_error_found);
		 fnd_file.put_line (fnd_file.LOG, 'rc_rec.process_objective_name: '||rc_rec.process_objective_name);
		 fnd_file.put_line (fnd_file.LOG, 'l_process_id: '||l_process_id);
		 fnd_file.put_line (fnd_file.LOG, 'l_process_objective_id: '||l_process_objective_id);

         IF((not v_error_found) AND
		    (l_process_obj_column = TRUE) AND
	        (l_process_id is not null) AND
	        (l_process_id <> -1) AND
			(l_process_objective_id is not null)) then
			  --SET THESE 2 VARS TO NULL FOR THIS LOOP
			  L_PROC_OBJ_ASSOCIATION_ID := NULL;
			  L_PROC_OBJ_APPROVAL_DATE	:= NULL;
			  --npanandi 10/26/2004: changed the way insert logic is handled
			  --post AMW.D+
		   BEGIN
		      SELECT OBJECTIVE_ASSOCIATION_ID,APPROVAL_DATE
			    INTO L_PROC_OBJ_ASSOCIATION_ID,L_PROC_OBJ_APPROVAL_DATE
			    FROM AMW_OBJECTIVE_ASSOCIATIONS
			   WHERE PROCESS_OBJECTIVE_ID=l_process_objective_id
			     AND PK1=l_process_id
			     AND OBJECT_TYPE='PROCESS'
			     AND DELETION_DATE IS NULL;
		   EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			     NULL; ---DO NOTHING ....
		   END;

           ---03.02.2005 npanandi: check here to see if this Process has AMW_UPD_RL_PROC_OBJ_ASSOC
           ---privilege to associate this Objective to Process

           ---IMPORTANTE --> check this privilege only when associating this Objective
           ---to a Process AND NOT to a Risk!!
           l_has_proc_obj_assoc_access := 'T'; ---set to T to avoid conflict with previous loop value
           l_has_proc_obj_assoc_access := check_function(
                             p_function           => 'AMW_UPD_RL_PROC_OBJ_ASSOC'
                            ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                            ,p_instance_pk1_value => l_process_id
                            ,p_user_id            => fnd_global.user_id);
           fnd_file.put_line(fnd_file.log,'%%%%%%%%%%%%%%%%%%% l_has_proc_obj_assoc_access: '||l_has_proc_obj_assoc_access||' %%%%%%%%%%%%%%%%%%%');

		   fnd_file.put_line (fnd_file.LOG, 'inside if for process: l_process_objective_id '||l_process_objective_id);
		   fnd_file.put_line (fnd_file.LOG, 'inside if for risk: l_process_objectives_count '||l_process_objectives_count);
		   IF (L_PROC_OBJ_ASSOCIATION_ID IS NULL and l_has_proc_obj_assoc_access = 'T') THEN
			 --NO ROW RETRIEVED, SO ASSOCIATION DOESN'T EXIST YET
			 --CREATE AN ASSOCIATION, SET ASSOCIATION_CREATION_DATE=SYSDATE
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Need to change the way data is inserted in amw_risk_associations');
			   CREATE_AMW_OBJ_ASSOC(
				 P_PROCESS_OBJECTIVE_ID => l_process_objective_id
				,P_PK1		  			=> l_process_id
				,P_OBJECT_TYPE 	  		=> 'PROCESS'
			   );
		   ELSE
		     --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

			 --IF APPROVAL_DATE IS NULL FOR OBJECTIVE_ASSOCIATIONS,
			 --THIS MEANS THAT THIS ASSOCIATION
			 --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
			 IF(L_PROC_OBJ_APPROVAL_DATE IS NOT NULL and l_has_proc_obj_assoc_access = 'T') THEN
			   --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
			   --AND IS APPROVED, SO
			   FND_FILE.PUT_LINE(FND_FILE.LOG,'UPDATE THIS ASSOCIATION, THEN INSERT');
			   BEGIN
			     UPDATE AMW_OBJECTIVE_ASSOCIATIONS
			        SET DELETION_DATE=SYSDATE
				       ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
					   ,LAST_UPDATE_DATE=SYSDATE
					   ,LAST_UPDATED_BY=G_USER_ID
					   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
				  WHERE OBJECTIVE_ASSOCIATION_ID=L_PROC_OBJ_ASSOCIATION_ID;

				 -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
			     CREATE_AMW_OBJ_ASSOC(
				   P_PROCESS_OBJECTIVE_ID => l_process_objective_id
				  ,P_PK1		  		  => l_process_id
				  ,P_OBJECT_TYPE 	  	  => 'PROCESS'
			     );
			   EXCEPTION
			     WHEN OTHERS THEN
				   V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
				   UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
			   END;
		     END IF;
		   end if; --end of if for process insertions
	     end if;  ---end of if no error found for process insertions

--
-- create the risk objective associations
--
   		 fnd_file.put_line (fnd_file.LOG, 'rc_rec.process_objective_name: '||rc_rec.process_objective_name);
		 fnd_file.put_line (fnd_file.LOG, 'l_process_objective_id: '||l_process_objective_id);

   		 IF((not v_error_found) AND
		    (l_process_obj_column = TRUE) AND
		    (l_process_objective_id is not null)) then
		   --SET THESE 2 VARS TO NULL FOR THIS LOOP PROCESSING
		   L_RISK_OBJ_ASSOCIATION_ID := NULL;
		   L_RISK_OBJ_APPROVAL_DATE	 := NULL;
		   --npanandi 10/26/2004: changed the way check is done post AMW.D
		   BEGIN
		      SELECT OBJECTIVE_ASSOCIATION_ID,APPROVAL_DATE
			    INTO L_RISK_OBJ_ASSOCIATION_ID,L_RISK_OBJ_APPROVAL_DATE
			    FROM AMW_OBJECTIVE_ASSOCIATIONS
			   WHERE PROCESS_OBJECTIVE_ID=l_process_objective_id
			     AND PK1=lx_risk_id
			     AND OBJECT_TYPE='RISK'
			     AND DELETION_DATE IS NULL;
		   EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			     NULL; --DO NOTHING ...
		   END;

		   ---IF l_risk_objectives_count = 0 THEN
		   IF(L_RISK_OBJ_ASSOCIATION_ID IS NULL) THEN
		     --NO ROW RETRIEVED, SO ASSOCIATION DOESN'T EXIST YET
			 --CREATE AN ASSOCIATION, SET ASSOCIATION_CREATION_DATE=SYSDATE
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Need to change the way data is inserted in amw_risk_associations');
			   CREATE_AMW_OBJ_ASSOC(
				 P_PROCESS_OBJECTIVE_ID => l_process_objective_id
				,P_PK1		  			=> lx_risk_id
				,P_OBJECT_TYPE 	  		=> 'RISK'
			   );
			   fnd_file.put_line (fnd_file.LOG, 'inserting lx_risk_id: '||lx_risk_id||' l_process_objective_id '||l_process_objective_id);
           ELSE
		     --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

			 --IF APPROVAL_DATE IS NULL FOR OBJECTIVE_ASSOCIATIONS,
			 --THIS MEANS THAT THIS ASSOCIATION
			 --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
			 IF(L_RISK_OBJ_APPROVAL_DATE IS NOT NULL) THEN
			   --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
			   --AND IS APPROVED, SO
			   FND_FILE.PUT_LINE(FND_FILE.LOG,'UPDATE THIS ASSOCIATION, THEN INSERT');
			   BEGIN
			     UPDATE AMW_OBJECTIVE_ASSOCIATIONS
			        SET DELETION_DATE=SYSDATE
				       ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
					   ,LAST_UPDATE_DATE=SYSDATE
					   ,LAST_UPDATED_BY=G_USER_ID
					   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
				  WHERE OBJECTIVE_ASSOCIATION_ID=L_RISK_OBJ_ASSOCIATION_ID;

				 -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
			     CREATE_AMW_OBJ_ASSOC(
				   P_PROCESS_OBJECTIVE_ID => l_process_objective_id
				  ,P_PK1		  		  => lx_risk_id
				  ,P_OBJECT_TYPE 	  	  => 'RISK'
			     );
			   EXCEPTION
			     WHEN OTHERS THEN
				   V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
				   UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
			   END;
			 END IF; --END OF IF FOR L_RISK_OBJ_APPR_DATE CHK
		   end if; --end of if L_RISK_OBJ_ASSOCIATION_ID NULLITY CHK
	     end if; --- end of if no error found for risk insertions

--
--
-- 01.13.2005 npanandi: create the Control - objective associations
-- per the changed datamodel for Process/Control Objective associations
--
--
   		 IF((not v_error_found) AND
		    (l_process_obj_column = TRUE) AND
		    (l_process_objective_id is not null) AND
			---need processId for pk1 column
			(l_process_id is not null) AND
	        (l_process_id <> -1) AND
			---need riskId for pk2 column
			lx_risk_id is not null AND
			---need controlId for pk3 column
			lx_control_id is not null) then
			---this means that processId, riskId, controlId and processObjectiveId
			---are all valid ---> hence create the Ctrl - ProcObj association
			---as per the new datamodel

		   --SET THESE 2 VARS TO NULL FOR THIS LOOP PROCESSING
		   L_CTRL_OBJ_ASSOCIATION_ID := NULL;
		   L_CTRL_OBJ_APPROVAL_DATE	 := NULL;
		   BEGIN
		      SELECT OBJECTIVE_ASSOCIATION_ID,APPROVAL_DATE,process_objective_id
			    INTO L_CTRL_OBJ_ASSOCIATION_ID,L_CTRL_OBJ_APPROVAL_DATE,l_ctrl_objective_id
			    FROM AMW_OBJECTIVE_ASSOCIATIONS
			   WHERE
--                             PROCESS_OBJECTIVE_ID=l_process_objective_id AND
                                 PK1=l_process_id
				 AND PK2=LX_RISK_ID
				 AND PK3=LX_CONTROL_ID
			     AND OBJECT_TYPE='CONTROL'
			     AND DELETION_DATE IS NULL;
		   EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			     NULL; --DO NOTHING ...
		   END;

		   IF(L_CTRL_OBJ_ASSOCIATION_ID IS NULL) THEN
		       CREATE_AMW_OBJ_ASSOC(
				 P_PROCESS_OBJECTIVE_ID => l_process_objective_id
				,P_PK1		  			=> l_process_id
				--01.13.2005 npanandi: added pk2,pk3 for Ctrl to Obj association
				,P_PK2					=> LX_RISK_ID
				,P_PK3					=> LX_CONTROL_ID
				,P_OBJECT_TYPE 	  		=> 'CONTROL'
			   );
			   fnd_file.put_line (fnd_file.LOG, 'inserting lx_CONTROL_id: '||lx_CONTROL_id||' l_process_objective_id '||l_process_objective_id);
           ELSE
		     --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

			 --IF APPROVAL_DATE IS NULL FOR OBJECTIVE_ASSOCIATIONS,
			 --THIS MEANS THAT THIS ASSOCIATION
			 --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
			 IF(L_CTRL_OBJ_APPROVAL_DATE IS NOT NULL) THEN
			   --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
			   --AND IS APPROVED, SO
			   BEGIN
                             if ( l_ctrl_objective_id <> l_process_objective_id) then
			     UPDATE AMW_OBJECTIVE_ASSOCIATIONS
			        SET DELETION_DATE=SYSDATE
				       ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
					   ,LAST_UPDATE_DATE=SYSDATE
					   ,LAST_UPDATED_BY=G_USER_ID
					   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
				  WHERE OBJECTIVE_ASSOCIATION_ID=L_CTRL_OBJ_ASSOCIATION_ID;

				 -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
			     CREATE_AMW_OBJ_ASSOC(
				   P_PROCESS_OBJECTIVE_ID => l_process_objective_id
				  ,P_PK1		  		  => l_process_id
				   --01.13.2005 npanandi: added pk2,pk3 for Ctrl to Obj association
				  ,P_PK2				  => LX_RISK_ID
				  ,P_PK3				  => LX_CONTROL_ID
				  ,P_OBJECT_TYPE 	  	  => 'CONTROL'
			     );
                             end if;
			   EXCEPTION
			     WHEN OTHERS THEN
				   V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
				   UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
			   END;
                         else
                             if ( l_ctrl_objective_id <> l_process_objective_id) then
                             begin
                                     delete from AMW_OBJECTIVE_ASSOCIATIONS
                                     WHERE OBJECTIVE_ASSOCIATION_ID=L_CTRL_OBJ_ASSOCIATION_ID;

                                         -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
                                     CREATE_AMW_OBJ_ASSOC(
                                           P_PROCESS_OBJECTIVE_ID => l_process_objective_id
                                          ,P_PK1		  		  => l_process_id
                                           --01.13.2005 npanandi: added pk2,pk3 for Ctrl to Obj association
                                          ,P_PK2				  => LX_RISK_ID
                                          ,P_PK3				  => LX_CONTROL_ID
                                          ,P_OBJECT_TYPE 	  	  => 'CONTROL'
                                     );
                                EXCEPTION
                                WHEN OTHERS THEN
                                        V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
                                        UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
                                 END;
                          end if;
			 END IF; --END OF IF FOR L_CTRL_OBJ_APPR_DATE CHK
		   end if; --end of if L_CTRL_OBJ_ASSOCIATION_ID NULLITY CHK
	     end if; --- end of if no error found for CTRL insertions

--
-- create the risk associations
--
         IF (not v_error_found AND l_process_id is not null AND l_process_id <> -1
			--NPANANDI 10/26/2004:
			--DISREGARD THE REVISE FLAGS FOR ASSOCIATIONS, POST AMW.D

			--AND
	        --(((l_revise_risk_flag ='Y' OR v_risk_db_approval_status is null)
		    --    AND l_risk_approval_status_code = 'A')
	        --OR (l_revise_risk_flag='N' and v_risk_db_approval_status='A')
		 ) THEN
		   --SET THESE 2 VARS TO NULL FOR THIS LOOP PROCESSING
		   L_RISK_ASSOCIATION_ID := NULL;
		   L_RISK_APPROVAL_DATE	 := NULL;
		   --npanandi 10/26/2004: changed the way check is done post AMW.D
		   BEGIN
		      SELECT RISK_ASSOCIATION_ID,APPROVAL_DATE
		        INTO L_RISK_ASSOCIATION_ID,L_RISK_APPROVAL_DATE
			    FROM AMW_RISK_ASSOCIATIONS
			   WHERE RISK_ID=lx_risk_id
			     AND PK1=L_PROCESS_ID
			     AND OBJECT_TYPE='PROCESS'
			     AND DELETION_DATE IS NULL;
		   EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			     NULL;
		   END;

           ---03.02.2005 npanandi: check here to see if this Process has AMW_UPDATE_AP_DETAILS
           ---privilege to associate this Control to AP
           l_has_proc_risk_assoc_access := 'T';
           l_has_proc_risk_assoc_access := check_function(
                          p_function           => 'AMW_UPD_RL_PROC_RISK_ASSOC'
                         ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                         ,p_instance_pk1_value => L_PROCESS_ID
                         ,p_user_id            => fnd_global.user_id);
           fnd_file.put_line(fnd_file.log,'%%%%%%%%%%%%%%% l_has_proc_risk_assoc_access: '||l_has_proc_risk_assoc_access||' %%%%%%%%%%%%%%%');

        ---03.02.2005 npanandi: added this for access privilege
        ---check before inserting/update AmwRiskAssociations
        if(l_has_proc_risk_assoc_access = 'T') then

           IF(L_RISK_ASSOCIATION_ID IS NULL) THEN
		     --NO ROW RETRIEVED, SO ASSOCIATION DOESN'T EXIST YET
			 --CREATE AN ASSOCIATION, SET ASSOCIATION_CREATION_DATE=SYSDATE
		     CREATE_AMW_RISK_ASSOC(
			   P_RISK_ID 	  		   => lx_risk_id
			  ,P_PROCESS_ID	  		   => l_process_id
			  ,P_RISK_LIKELIHOOD_CODE  => rc_rec.risk_likelihood_code
			  ,P_RISK_IMPACT_CODE	   => rc_rec.risk_impact_code
			  ,P_MATERIAL			   => RC_REC.MATERIAL
			  ,P_MATERIAL_VALUE		   => RC_REC.MATERIAL_VALUE);

		   ELSE
		     --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

			 --IF APPROVAL_DATE IS NULL FOR RISK_ASSOCIATIONS,
			 --THIS MEANS THAT THIS ASSOCIATION
			 --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
			 IF(L_RISK_APPROVAL_DATE IS NOT NULL) THEN
			   --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
			   --AND IS APPROVED, SO
			   FND_FILE.PUT_LINE(FND_FILE.LOG,'UPDATE THIS ASSOCIATION, THEN INSERT');
			   BEGIN
			     UPDATE AMW_RISK_ASSOCIATIONS
				    SET DELETION_DATE=SYSDATE
					   ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
					   ,LAST_UPDATE_DATE=SYSDATE
					   ,LAST_UPDATED_BY=G_USER_ID
					   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
				  WHERE RISK_ASSOCIATION_ID=L_RISK_ASSOCIATION_ID;

				 CREATE_AMW_RISK_ASSOC(
				   P_RISK_ID 	  		   => lx_risk_id
				  ,P_PROCESS_ID	  		   => l_process_id
				  ,P_RISK_LIKELIHOOD_CODE  => rc_rec.risk_likelihood_code
				  ,P_RISK_IMPACT_CODE	   => rc_rec.risk_impact_code
				  ,P_MATERIAL			   => RC_REC.MATERIAL
				  ,P_MATERIAL_VALUE		   => RC_REC.MATERIAL_VALUE);
			   EXCEPTION
			     WHEN OTHERS THEN
				   V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
				   UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
			   END;
			 ELSE
			   --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
			   --AND IS NOT APPROVED, SO SIMPLY UPDATE THE ATTRIBUTES
			   UPDATE AMW_RISK_ASSOCIATIONS
			      SET RISK_LIKELIHOOD_CODE=rc_rec.risk_likelihood_code
				     ,RISK_IMPACT_CODE=rc_rec.risk_IMPACT_code
				     ,MATERIAL=RC_REC.MATERIAL
				     ,MATERIAL_VALUE=RC_REC.MATERIAL_VALUE
				     ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
				     ,LAST_UPDATE_DATE=SYSDATE
				     ,LAST_UPDATED_BY=G_USER_ID
				     ,LAST_UPDATE_LOGIN=G_LOGIN_ID
			    WHERE RISK_ASSOCIATION_ID=L_RISK_ASSOCIATION_ID;
			 END IF;
           END IF; -- end of IF l_object_type_count = 0 THEN
           end if; --end of if for l_has_proc_risk_assoc_access check
         END IF; -- --- end of if no error found for risk insertions

		 --NEED TO CALL BELOW APIS TO RESET RISK/CTRL COUNTS
		 --THIS HAVE TO BE CALLED ON A PER ROW BASIS, AS AGAINST
		 --THE EARLIER AMIT'S SYNCH API, SINCE THE BELOW APIS TAKE PROCESS_ID AS PARAMETER
		 IF(L_PROCESS_ID IS NOT NULL AND L_PROCESS_ID <> -1) THEN
		    AMW_RL_HIERARCHY_PKG.update_latest_control_counts(P_PROCESS_ID => L_PROCESS_ID);
	        AMW_RL_HIERARCHY_PKG.update_latest_risk_counts(P_PROCESS_ID => L_PROCESS_ID);
		 END IF;

       EXCEPTION
         WHEN OTHERS THEN
           v_err_msg := 'interface_id: = '|| v_interface_id|| '  '|| SUBSTR (SQLERRM, 1, 100);
           v_table_name := 'UNKNOWN';
	       update_interface_with_error (v_err_msg
                                       ,v_table_name
                                       ,v_interface_id);
           fnd_file.put_line (fnd_file.LOG, 'err in interface rec '||v_interface_id
					||': '||SUBSTR (v_err_msg, 1, 200));
       END;
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


     IF UPPER (l_amw_delt_risk_cntl_intf) <> 'Y' THEN
       BEGIN
         UPDATE amw_risk_ctrl_interface
            SET process_flag = l_process_flag
                ,last_update_date = SYSDATE
                ,last_updated_by = v_user_id
          WHERE batch_id = p_batch_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line (fnd_file.LOG
                              ,'err in update process flag: '||SUBSTR (SQLERRM, 1, 200));
       END;
     ELSE
       IF NOT v_error_found THEN
         BEGIN
           DELETE FROM amw_risk_ctrl_interface
                 WHERE batch_id = p_batch_id;

         EXCEPTION
           WHEN OTHERS THEN
             fnd_file.put_line (fnd_file.LOG
                              ,'err in delete interface records: '||SUBSTR (SQLERRM, 1, 200));
         END;
       END IF;
     END IF;


   EXCEPTION
   /** nilesh added for invalid risk type **/
     WHEN e_invalid_risk_type THEN
       fnd_file.put_line (fnd_file.LOG
                         , 'Invalid Risk Type.');

       BEGIN
	 IF v_invalid_risk_type is null THEN
	   v_invalid_risk_type := FND_MESSAGE.GET_STRING('AMW', 'AMW_INVALID_RISK_TYPE');
	 END IF;
         UPDATE amw_risk_ctrl_interface
            SET error_flag = 'Y'
                ,interface_status = v_invalid_risk_type
          WHERE batch_id = p_batch_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line (fnd_file.LOG
                         , 'unexpected exception in handling e_invalid_risk_type: '||sqlerrm);
       END;
	   /** nilesh added for invalid risk type **/

     WHEN e_invalid_requestor_id THEN
       fnd_file.put_line (fnd_file.LOG
                         , 'Invalid requestor id.');

       BEGIN
	 IF v_invalid_requestor_msg is null THEN
	   v_invalid_requestor_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_UNKNOWN_EMPLOYEE');
	 END IF;
         UPDATE amw_risk_ctrl_interface
            SET error_flag = 'Y'
                ,interface_status = v_invalid_requestor_msg
          WHERE batch_id = p_batch_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line (fnd_file.LOG
                         , 'unexpected exception in handling e_invalid_requestor_id: '||sqlerrm);
       END;
     WHEN e_no_import_access THEN
       fnd_file.put_line (fnd_file.LOG
                         , 'no import privilege');

       BEGIN
         IF v_no_import_privilege_msg is null THEN
	       v_no_import_privilege_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_NO_IMPORT_ACCESS');
	     END IF;
         UPDATE amw_risk_ctrl_interface
            SET error_flag = 'Y'
                ,interface_status = v_no_import_privilege_msg
          WHERE batch_id = p_batch_id;
          EXCEPTION
             WHEN OTHERS THEN
               fnd_file.put_line (fnd_file.LOG
                         , 'unexpected exception in handling e_no_import_access: '||sqlerrm);
             END;
     WHEN others THEN
       rollback;
       fnd_file.put_line (fnd_file.LOG
                         , 'unexpected exception in create_risks_and_controls: '||sqlerrm);
   END create_risks_and_controls;

--
--  Insert or update the Risk Types
--
--
   PROCEDURE create_process_objectives (p_process_objective_name 			   IN VARCHAR2,
   			 						   	p_process_obj_description			   IN Varchar2,
   			 						    p_requestor_id			 			   IN	number,
   			 						   	x_return_status			 			   out nocopy	varchar2)
   IS
      CURSOR c_get_objective IS
	    SELECT name,process_objective_id
	      FROM AMW_process_objectives_vl
	     WHERE name = p_process_objective_name;


	  CURSOR c_process_objective_id IS
        SELECT AMW_process_objectives_S.NEXTVAL
          FROM dual;

	  l_rowid  						amw_process_objectives_vl.row_id%type;
	  l_get_objective				c_get_objective%rowtype;
	  l_process_objective_id		number;
      e_invalid_obj					EXCEPTION;
      e_invalid_flag				EXCEPTION;
	  e_invalid_risk_type_flag 		exception;
   BEGIN
   		fnd_file.put_line(fnd_file.log,'~~~~~~~~~~~~~~~~~~~~~~ create_process_objectives: START');
		fnd_file.put_line(fnd_file.log,'p_process_objective_name: '||p_process_objective_name);
     	 open c_get_objective;
		   fetch c_get_objective into l_get_objective;
		 close c_get_objective;

		 if(l_get_objective.process_objective_id is null)then

				fnd_file.put_line(fnd_file.log,'p_process_objective_name does not exist');

 		 	    OPEN c_process_objective_id;
          		 FETCH c_process_objective_id INTO l_process_objective_id;
     			CLOSE c_process_objective_id;

				amw_process_objectives_b_pkg.insert_row(
						X_ROWID 						=> l_rowid,
          				x_last_updated_by				=> g_user_id,
				        x_last_update_date   			=> sysdate,
				        x_created_by    				=> g_user_id,
				        x_creation_date    				=> sysdate,
				        x_last_update_login				=> g_login_id,
				        x_objective_type   				=> 'C',
				        x_start_date    				=> sysdate,
				        x_end_date    					=> null,
				        x_attribute_category    		=> null,
				        x_attribute1    				=> null,
				        x_attribute2    				=> null,
          				x_attribute3    				=> null,
          				x_attribute4    				=> null,
          				x_attribute5    				=> null,
          				x_attribute6    				=> null,
          				x_attribute7    				=> null,
          				x_attribute8    				=> null,
          				x_attribute9    				=> null,
          				x_attribute10   				=> null,
          				x_attribute11   				=> null,
          				x_attribute12   				=> null,
          				x_attribute13   				=> null,
          				x_attribute14   				=> null,
          				x_attribute15   				=> null,
          				x_security_group_id    			=> null,
          				x_object_version_number			=> 1,
          				x_process_objective_id 			=> l_process_objective_id,
		  				x_requestor_id 					=> p_requestor_id,
		  				X_NAME 							=> p_process_objective_name,
  		  				X_DESCRIPTION 					=> p_process_obj_description
				);

				vx_process_objective_id := l_process_objective_id;
				fnd_file.put_line(fnd_file.log,'vx_process_objective_id: '||vx_process_objective_id);
		else
			vx_process_objective_id := l_get_objective.process_objective_id;
			fnd_file.put_line(fnd_file.log,'p_process_objective_name exists --> vx_process_objective_id: '||vx_process_objective_id);
			update AMW_PROCESS_OBJECTIVEs_TL set
				    NAME = p_process_objective_name,
				    DESCRIPTION = p_process_obj_description,
				    LAST_UPDATE_DATE = sysdate,
				    LAST_UPDATED_BY = g_user_id,
				    LAST_UPDATE_LOGIN = g_login_id,
				    SOURCE_LANG = userenv('LANG')
				  where PROCESS_OBJECTIVE_ID = l_get_objective.process_objective_id
				  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

			if (sql%notfound) then
			    raise FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;

		 end if;

	   fnd_file.put_line(fnd_file.log,'~~~~~~~~~~~~~~~~~~~~~~ create_process_objectives: END');

   EXCEPTION
  	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			v_err_msg :=
                   'Error working in procedure Create_Process_Objectives:  '
                || 'Process_Objective_Name: '
                || p_process_objective_name
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100)
				|| ' ';
            v_table_name := 'AMW_PROCESS_OBJECTIVES_B';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );

      WHEN OTHERS THEN
	        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            v_err_msg :=
                   'Error working in procedure Create_Process_Objectives:  '
                || 'Process_Objective_Name: '
                || p_process_objective_name
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100)
				|| ' ';
            v_table_name := 'AMW_PROCESS_OBJECTIVES_B';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
END create_process_objectives;



--
--  Insert or update the Risk Types
--
--
   PROCEDURE risk_types (p_risk_type_flag IN VARCHAR2, p_lookup_tag IN VARCHAR2, p_is_last_call in varchar2)
   IS

-- kosriniv changing cursor defn. for basel-II enhancement
    	CURSOR c_risk_type IS
	    SELECT risk_type_code
	     FROM AMW_SETUP_RISK_TYPES_VL
	     WHERE
	     start_date <= sysdate AND (end_date IS NULL OR end_date >= sysdate)
	     AND tag=p_lookup_tag;
 --CURSOR c_risk_type IS
--	    SELECT lookup_code
--	      FROM AMW_LOOKUPS
--	     WHERE lookup_type='AMW_RISK_TYPE'
--	       AND enabled_flag='Y'
--	       AND tag=p_lookup_tag;

	  CURSOR c_risk_type_id IS
        SELECT AMW_RISK_TYPE_S.NEXTVAL
          FROM dual;

	  l_risk_type_code		VARCHAR2(30);
	  l_risk_type_code_del	VARCHAR2(30);
      l_risk_type_flag		VARCHAR2(1);
	  l_risk_type_flag_dummy		VARCHAR2(1);
	  ---l_risk_type_exists	varchar2(30);
	  l_risk_type_exists	number;
	  l_RISK_type_id		number;
      e_invalid_obj			EXCEPTION;
      e_invalid_flag		EXCEPTION;
	  e_invalid_risk_type_flag exception;
   BEGIN

     --if(p_risk_type_flag is null or trim(p_risk_type_flag) = '')then
	 --  l_risk_type_flag_dummy := 'N';
	 --else
	   l_risk_type_flag_dummy := upper(p_risk_type_flag);


	 --end if;
	 if(l_risk_type_flag_dummy = 'Y') then
	   v_valid_risk_type := v_valid_risk_type+1;
	 end if;

	 if(upper(p_is_last_call) = 'Y')then
	   if(v_valid_risk_type = 0) then
	     raise e_invalid_risk_type_flag;
	   end if;
	 end if;

	 IF l_risk_type_flag_dummy is not null THEN
       IF UPPER (l_risk_type_flag_dummy) = 'Y' THEN
	     l_risk_type_flag := 'Y';
       ELSIF UPPER (l_risk_type_flag_dummy) = 'N' THEN
	     l_risk_type_flag := 'N';
       ELSE
	     RAISE e_invalid_flag;
       END IF;
	 --end if;

	 --if(p_risk_type_flag is null) then
	   --l_risk_type_flag := 'N';
	 --end if;

       OPEN c_risk_type;
       FETCH c_risk_type INTO l_risk_type_code;
       IF (c_risk_type%NOTFOUND) THEN
         CLOSE c_risk_type;
	     ---RAISE e_invalid_obj;
       END IF;
       CLOSE c_risk_type;


	   if(l_risk_type_flag = 'N') then

		 select count(*) into l_risk_type_exists
		 from 	amw_risk_type
		 where	risk_rev_id = lx_risk_rev_id
		 and 	risk_type_code = l_risk_type_code;

	     if(l_risk_type_exists > 0) then
	        delete from amw_risk_type
		    where	 risk_rev_id=lx_risk_rev_id
		    and	 risk_type_code=l_risk_type_code;
		 end if;
	   end if;

	   ---insert into test_test (text,creation_date) values ('risk_type_flag: '||p_risk_type_flag||' lookup_tag: '||p_lookup_tag,sysdate);


	   if(l_risk_type_flag = 'Y') then

	     --this risk_type has been selected for this risk ....
		 --need to check if this row already exists in amw_risk_type
		 --for this risk_rev_id

		 select count(*) into l_risk_type_exists
		 from 	amw_risk_type
		 where	risk_rev_id = lx_risk_rev_id
		 and 	risk_type_code = l_risk_type_code;

	     --IF SQL%NOTFOUND THEN
		 if(l_risk_type_exists = 0) then

		   --this means that this risk_type is not present
		   --for the current risk ... hence insert a new row

		   OPEN c_risk_type_id;
             FETCH c_risk_type_id INTO l_RISK_type_id;
           CLOSE c_risk_type_id;

           INSERT INTO amw_risk_type
	                 (risk_type_id,
					  last_update_date,
					  last_updated_by,
					  creation_date,
					  created_by,
					  last_update_login,
					  risk_rev_id,
					  risk_type_code,
					  OBJECT_VERSION_NUMBER) VALUES
					  (l_risk_type_id,
					   SYSDATE,
					   g_user_id,
					   SYSDATE,
					   g_user_id,
					   g_login_id,
					   lx_risk_rev_id,
					   l_risk_type_code,
					   1);
         END IF; -- end if for l_risk_type_exists = 0
	   end if; --- end if for l_risk_type_flag = 'Y'
     END IF; -- end of if risk_type_flag is not null condition

   EXCEPTION
      WHEN e_invalid_risk_type_flag THEN
            v_err_msg :=
                   'Error working in procedure risk types:  '
                || 'Atleast one Risk_Type flag must be Y/N';
            v_table_name := 'AMW_RISK_TYPE';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );

      WHEN e_invalid_flag THEN
            v_err_msg :=
                   'Error working in procedure risk types:  '
                || 'risk_type_code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   flag must be Y/N';
            v_table_name := 'AMW_RISK_TYPE';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN e_invalid_obj THEN
            v_err_msg :=
                   'Error working in procedure risk types:  '
                || 'risk_type_code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   code does not exist';
            v_table_name := 'AMW_RISK_TYPE';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN OTHERS THEN
            v_err_msg :=
                   'Error working in procedure risk types:  '
                || 'risk_type_code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100)
				|| ' ';
            v_table_name := 'AMW_RISK_TYPE';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
   END risk_types;

--
--  Insert or update the control objectives
--
--

     PROCEDURE control_objectives (p_ctrl_obj_flag IN VARCHAR2, p_lookup_tag IN VARCHAR2)
   IS
      CURSOR c_control_obj IS
	  		 SELECT lookup_code
			   FROM AMW_LOOKUPS
			  WHERE lookup_type='AMW_CONTROL_OBJECTIVES'
	  		  	AND enabled_flag='Y'
	  			AND tag=p_lookup_tag;

      l_ctrl_obj_code		VARCHAR2(30);
      l_ctrl_obj_flag		VARCHAR2(1);
	  l_obj_exists			number;
      e_invalid_obj			EXCEPTION;
      e_invalid_flag		EXCEPTION;
   BEGIN
   		---fnd_file.put_line(fnd_file.log,'control_objectives --> p_ctrl_obj_flag: '||p_ctrl_obj_flag||'p_lookup_tag: '||p_lookup_tag);

     IF p_ctrl_obj_flag is not null THEN
       IF UPPER (p_ctrl_obj_flag) = 'Y' THEN
	   	  l_ctrl_obj_flag := 'Y';
       ELSIF UPPER (p_ctrl_obj_flag) = 'N' THEN
	   	  l_ctrl_obj_flag := 'N';
       ELSE
	   	   RAISE e_invalid_flag;
       END IF;

       OPEN c_control_obj;
       FETCH c_control_obj INTO l_ctrl_obj_code;
       		 IF (c_control_obj%NOTFOUND) THEN
         	 	CLOSE c_control_obj;
	 			RAISE e_invalid_obj;
       		END IF;
       CLOSE c_control_obj;

	   if (l_ctrl_obj_flag = 'N') then
	   	  select count(*)
		    into l_obj_exists
			from amw_control_objectives
		   where control_rev_id = vx_control_rev_id
		   	 AND objective_code = l_ctrl_obj_code;

		   if(l_obj_exists > 0) then
		   		delete from amw_control_objectives
				where control_rev_id = vx_control_rev_id
		   	 	  AND objective_code = l_ctrl_obj_code;
		   end if;
	   end if;

	  if (l_ctrl_obj_flag = 'Y') then
		 --- this control objective has been selected
		 --- need to check if it is already present or not
		   select count(*)
		    into l_obj_exists
			from amw_control_objectives
		   where control_rev_id = vx_control_rev_id
		   	 AND objective_code = l_ctrl_obj_code;

			 if(l_obj_exists = 0) then
		 	 				 ---IF SQL%NOTFOUND THEN
         			INSERT INTO amw_control_objectives
	                 (control_objective_id
                           ,last_update_date
                           ,last_updated_by
                           ,creation_date
                           ,created_by
                           ,control_rev_id
                           ,objective_code
						   ,OBJECT_VERSION_NUMBER
                           ) VALUES (
						   amw_control_objectives_s.NEXTVAL
                           ,SYSDATE
                           ,v_user_id
                           ,SYSDATE
                           ,v_user_id
                           ,vx_control_rev_id
                           ,l_ctrl_obj_code
						   ,1
                           );
		     end if; -- end if for l_obj_exists = 0
         END IF; --end if for l_obj_flag = 'Y'
     END IF; -- end if for objective not null condition

   EXCEPTION
      WHEN e_invalid_flag THEN
            v_err_msg :=
                   'Error working in procedure control objectives:  '
                || 'objective code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   flag must be Y/N';
            v_table_name := 'AMW_CONTROL_OBJECTIVES';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN e_invalid_obj THEN
            v_err_msg :=
                   'Error working in procedure control objectives:  '
                || 'objective code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   code does not exist';
            v_table_name := 'AMW_CONTROL_OBJECTIVES';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN OTHERS THEN
            v_err_msg :=
                   'Error working in procedure control objectives:  '
                || 'objective code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
            v_table_name := 'AMW_CONTROL_OBJECTIVES';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
   END control_objectives;


--
--  Insert or update the control assertions
--
  PROCEDURE control_assertions (p_ctrl_assert_flag IN VARCHAR2, p_lookup_tag IN VARCHAR2)
   IS
      CURSOR c_control_assert IS
  		 SELECT lookup_code
  		   FROM AMW_LOOKUPS
		  WHERE lookup_type='AMW_CONTROL_ASSERTIONS'
  		    AND enabled_flag='Y'
  		    AND tag=p_lookup_tag;

      l_ctrl_assert_code	VARCHAR2(30);
      l_ctrl_assert_flag	VARCHAR2(1);
	  l_assert_exists		number;
      e_invalid_assert		EXCEPTION;
      e_invalid_flag		EXCEPTION;
   BEGIN
     -----fnd_file.put_line(fnd_file.log,'control_assertions --> p_ctrl_assert_flag: '||p_ctrl_assert_flag||'p_lookup_tag: '||p_lookup_tag);

     IF (p_ctrl_assert_flag is not null) THEN
       IF UPPER (p_ctrl_assert_flag) = 'Y' THEN
	   	  l_ctrl_assert_flag := 'Y';
       ELSIF UPPER (p_ctrl_assert_flag) = 'N' THEN
	   	l_ctrl_assert_flag := 'N';
       ELSE
	   	   RAISE e_invalid_flag;
       END IF;

       OPEN c_control_assert;
       FETCH c_control_assert INTO l_ctrl_assert_code;
       		 IF (c_control_assert%NOTFOUND) THEN
         	 	CLOSE c_control_assert;
	 			RAISE e_invalid_assert;
       		END IF;
       CLOSE c_control_assert;

	   		if (l_ctrl_assert_flag = 'N') then
	   	  select count(*)
		    into l_assert_exists
			from amw_control_assertions
		   where control_rev_id = vx_control_rev_id
		   	 AND assertion_code = l_ctrl_assert_code;

		   if(l_assert_exists > 0) then
		   		delete from amw_control_assertions
				where control_rev_id = vx_control_rev_id
		   	 	  AND assertion_code = l_ctrl_assert_code;
		   end if;
	   end if;

		if(l_ctrl_assert_flag = 'Y') then
			select count(*)
		    into l_assert_exists
			from amw_control_assertions
		   where control_rev_id = vx_control_rev_id
		   	 AND assertion_code = l_ctrl_assert_code;

			 if(l_assert_exists = 0)then
			 	---IF SQL%NOTFOUND THEN
         		INSERT INTO amw_control_assertions
	                 (control_assertion_id
                           ,last_update_date
                           ,last_updated_by
                           ,creation_date
                           ,created_by
                           ,control_rev_id
                           ,ASSERTION_CODE
						   ----not using the date columns anyway
                           ----,effective_date_from
			   			   ----,effective_date_to
			   			   ,OBJECT_VERSION_NUMBER
                           ) VALUES (
						   amw_control_assertions_s.NEXTVAL
                           ,SYSDATE
                           ,v_user_id
                           ,SYSDATE
                           ,v_user_id
                           ,vx_control_rev_id
                           ,l_ctrl_assert_code
                           ----not using the date columns anyway
						   ----,SYSDATE
			   			   ----,DECODE (l_ctrl_assert_flag, 'N', SYSDATE, NULL)
			   			   ,1
                           );
			 end if; --end of if for l_assert_exists
		end if; -- end of if for l_assert_flag = 'Y'
     END IF; --- end of if p_assert_flag not null
   EXCEPTION
      WHEN e_invalid_flag THEN
            v_err_msg :=
                   'Error working in procedure control assertions:  '
                || 'assertion code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   flag must be Y/N';
            v_table_name := 'AMW_CONTROL_ASSERTIONS';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN e_invalid_assert THEN
            v_err_msg :=
                   'Error working in procedure control assertions:  '
                || 'assertion code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   code does not exist';
            v_table_name := 'AMW_CONTROL_ASSERTIONS';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN OTHERS THEN
            v_err_msg :=
                   'Error working in procedure control assertions:  '
                || 'assertion code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
            v_table_name := 'AMW_CONTROL_ASSERTIONS';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
   END control_assertions;


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
      l_interface_status   amw_risk_ctrl_interface.interface_status%TYPE;
   BEGIN
      ROLLBACK; -- rollback any inserts done during the current loop process
      v_error_found := TRUE;

      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_risk_ctrl_interface
          WHERE risk_control_interface_id = p_interface_id;
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
         UPDATE amw_risk_ctrl_interface
            SET interface_status =
                       l_interface_status
               --     || 'Error Msg: '
                    || p_err_msg
               --     || ' Table Name: '
               --     || p_table_name
                    || '**'
               ,error_flag = 'Y'
          WHERE risk_control_interface_id = p_interface_id;

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

--KOSRINIV ---control_components procedure
--
--  Insert or update the control components
--
--

   PROCEDURE control_components (p_ctrl_comp_flag IN VARCHAR2, p_lookup_tag IN VARCHAR2)
   IS
      CURSOR c_control_comp IS
	  		 SELECT lookup_code
			   FROM AMW_LOOKUPS
			  WHERE lookup_type='AMW_ASSESSMENT_COMPONENTS'
	  		  	AND enabled_flag='Y'
	  			AND tag=p_lookup_tag;

      l_ctrl_comp_code		VARCHAR2(30);
      l_ctrl_comp_flag		VARCHAR2(1);
	  l_comp_exists			number;
      e_invalid_comp			EXCEPTION;
      e_invalid_flag		EXCEPTION;
   BEGIN
   		---fnd_file.put_line(fnd_file.log,'control_objectives --> p_ctrl_obj_flag: '||p_ctrl_obj_flag||'p_lookup_tag: '||p_lookup_tag);

     IF p_ctrl_comp_flag is not null THEN
       IF UPPER (p_ctrl_comp_flag) = 'Y' THEN
	   	  l_ctrl_comp_flag := 'Y';
       ELSIF UPPER (p_ctrl_comp_flag) = 'N' THEN
	   	  l_ctrl_comp_flag := 'N';
       ELSE
	   	   RAISE e_invalid_flag;
       END IF;

       OPEN c_control_comp;
       FETCH c_control_comp INTO l_ctrl_comp_code;
       		 IF (c_control_comp%NOTFOUND) THEN
         	 	CLOSE c_control_comp;
	 			RAISE e_invalid_comp;
       		END IF;
	CLOSE c_control_comp;

	   if (l_ctrl_comp_flag = 'N') then
	   	  select count(*)
		    into l_comp_exists
			from amw_assessment_components
		   where object_type='CONTROL'
		     AND object_id = vx_control_rev_id
		   	 AND component_code = l_ctrl_comp_code;

		   if(l_comp_exists > 0) then
		   		delete from amw_assessment_components
				where object_type='CONTROL'
		     	  AND object_id = vx_control_rev_id
		   	      AND component_code = l_ctrl_comp_code;
		   end if;
	   end if;

	  if (l_ctrl_comp_flag = 'Y') then
		 --- this control objective has been selected
		 --- need to check if it is already present or not
		   select count(*)
		    into l_comp_exists
			from amw_assessment_components
		   where object_type='CONTROL'
		     AND object_id = vx_control_rev_id
		   	 AND component_code = l_ctrl_comp_code;

			 if(l_comp_exists = 0) then
		 	 				 ---IF SQL%NOTFOUND THEN
         			INSERT INTO amw_assessment_components
	                 (assessment_component_id
                           ,last_update_date
                           ,last_updated_by
                           ,creation_date
                           ,created_by
						   ,last_update_login
						   ,component_code
                           ,object_type
                           ,object_id
						   ,OBJECT_VERSION_NUMBER
                           ) VALUES (
						   amw_assessment_components_s.NEXTVAL
                           ,SYSDATE
                           ,v_user_id
                           ,SYSDATE
                           ,v_user_id
						   ,v_user_id
						   ,l_ctrl_comp_code
						   ,'CONTROL'
                           ,vx_control_rev_id
                           ,1
                           );
		     end if; -- end if for l_obj_exists = 0
         END IF; --end if for l_obj_flag = 'Y'
     END IF; -- end if for objective not null condition

   EXCEPTION
      WHEN e_invalid_flag THEN
            v_err_msg :=
                   'Error working in procedure control components:  '
                || 'component code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   flag must be Y/N';
            v_table_name := 'AMW_ASSESSMENT_COMPONENTS';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN e_invalid_comp THEN
            v_err_msg :=
                   'Error working in procedure control components:  '
                || 'component code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   code does not exist';
            v_table_name := 'AMW_ASSESSMENT_COMPONENTS';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
      WHEN OTHERS THEN
            v_err_msg :=
                   'Error working in procedure control components:  '
                || 'component code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
            v_table_name := 'AMW_ASSESSMENT_COMPONENTS';
            update_interface_with_error (v_err_msg
                                        ,v_table_name
                                        ,v_interface_id
                                        );
   END control_components;

PROCEDURE CREATE_AMW_CTRL_ASSOC(
  P_CONTROL_ID IN NUMBER
 ,P_PROCESS_ID IN NUMBER
 ,P_RISK_ID    IN NUMBER
)
IS
   l_has_risk_ctrl_assn_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
BEGIN
/**
  ---03.02.2005 npanandi: check here to see if this Process has
  ---AMW_UPD_RL_PROC_RISK_CTRL_ASSN privilege to associate this Risk to Ctrl
  l_has_risk_ctrl_assn_access := check_function(
                          p_function           => 'AMW_UPD_RL_PROC_RISK_CTRL_ASSN'
                         ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                         ,p_instance_pk1_value => P_PROCESS_ID
                         ,p_user_id            => fnd_global.user_id);

  fnd_file.put_line(fnd_file.log,'&&&&&&&&&&&&&&& l_has_risk_ctrl_assn_access: '||l_has_risk_ctrl_assn_access||' &&&&&&&&&&&&&&&');
  --03.02.2005 npanandi: imposing the foll. IF condition to
  --create the association only if access privilege is present
  if(l_has_risk_ctrl_assn_access = 'T') then
  **/
    INSERT INTO amw_control_associations(
        control_association_id
       ,last_update_date
       ,last_updated_by
       ,creation_date
       ,created_by
       ,control_id
       ,pk1
       ,PK2
       ,object_type
       ,effective_date_from
       ,effective_date_to
       ,ASSOCIATION_CREATION_DATE
       ,OBJECT_VERSION_NUMBER)
    VALUES (
	    amw_control_associations_s.NEXTVAL
       ,SYSDATE
       ,v_user_id
       ,SYSDATE
       ,v_user_id
       ,P_control_id
       ,P_PROCESS_ID
       ,P_RISK_ID
       ,'RISK'
       ,SYSDATE
       ,NULL
       ,SYSDATE
       ,1
    );
  ---end if; ---end of l_has_risk_ctrl_assn_access check
END CREATE_AMW_CTRL_ASSOC;

PROCEDURE CREATE_AMW_AP_ASSOC(
  P_CONTROL_ID 				  IN NUMBER
 ,P_AUDIT_PROCEDURE_ID		  IN NUMBER
 ,P_DESIGN_EFFECTIVENESS 	  IN VARCHAR2
 ,P_OP_EFFECTIVENESS 		  IN VARCHAR2
 --NPANANDI 12.09.2004: ADDED RETURN STATUS BECAUSE
 --CALLING REVISE_AP BELOW
 ,X_RETURN_STATUS			  OUT NOCOPY VARCHAR2
 ,X_MSG_COUNT				  OUT NOCOPY NUMBER
 ,X_MSG_DATA				  OUT NOCOPY VARCHAR2
)
IS
   l_has_ap_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
BEGIN
/**
   ---03.01.2005 npanandi: check here to see if this AP has AMW_UPDATE_AP_DETAILS
   ---privilege to associate this Control to AP
   l_has_ap_access := check_function(
                          p_function           => 'AMW_UPDATE_AP_DETAILS'
                         ,p_object_name        => 'AMW_AUDIT_PROCEDURE'
                         ,p_instance_pk1_value => P_AUDIT_PROCEDURE_ID
                         ,p_user_id            => fnd_global.user_id);

  fnd_file.put_line(fnd_file.log,'&&&&&&&&&&&&&&& l_has_ap_access: '||l_has_ap_access||' &&&&&&&&&&&&&&&');
  --03.01.2005 npanandi: imposing the foll. IF condition to
  --create the association only if access privilege is present
  if(l_has_ap_access = 'T') then
  **/
    fnd_file.put_line(fnd_file.log,'Associating Ctrl to Audit Procedure');
    --NPANANDI 12.09.2004: CALLING REVISE_AP FOR CHANGED DATAMODEL
    --
    AMW_AUDIT_PROCEDURES_PVT.Revise_Ap_If_Necessary(
       p_api_version_number => 1,
       p_init_msg_list      => FND_API.G_TRUE,
       P_audit_procedure_id => P_audit_procedure_id,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data
    );

    IF(x_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      INSERT INTO amw_ap_associations(
        ap_association_id
       ,last_update_date
       ,last_updated_by
       ,creation_date
       ,created_by
       ,last_update_login
       ,pk1
       ,object_type
       ,audit_procedure_id
       ,design_effectiveness
       ,op_effectiveness
       ,object_version_number
	   ,ASSOCIATION_CREATION_DATE)
      VALUES (
        AMW_AP_ASSOCIATIONS_S.NEXTVAL
       ,SYSDATE
       ,v_user_id
       ,SYSDATE
       ,v_user_id
       ,v_user_id
       ,P_control_id
       ,'CTRL'
       ,P_AUDIT_PROCEDURE_ID
       ,NVL(P_DESIGN_EFFECTIVENESS,'N')
       ,NVL(P_OP_EFFECTIVENESS,'N')
       ,1
	   ,SYSDATE
     );
    END IF;
  ---end if; ---03.01.2005 npanandi: end of if for l_has_ap_access check
END CREATE_AMW_AP_ASSOC;

PROCEDURE CREATE_AMW_OBJ_ASSOC(
  P_PROCESS_OBJECTIVE_ID 	  IN NUMBER
 ,P_PK1		  				  IN NUMBER
 ---01.13.2005 npanandi: added pk2,pk3,pk4,pk5 for Ctrl to Obj association
 ,P_PK2		  				  IN NUMBER
 ,P_PK3		  				  IN NUMBER
 ,P_PK4		  				  IN NUMBER
 ,P_PK5		  				  IN NUMBER
 ,P_OBJECT_TYPE 	  		  IN VARCHAR2
)
IS
   l_has_proc_obj_assoc_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
BEGIN
/**
  ---03.02.2005 npanandi: check here to see if this Process has AMW_UPD_RL_PROC_OBJ_ASSOC
  ---privilege to associate this Objective to Process

  ---IMPORTANTE --> check this privilege only when associating this Objective
  ---to a Process AND NOT to a Risk!!
  if(P_OBJECT_TYPE = 'PROCESS')then
     l_has_proc_obj_assoc_access := check_function(
                             p_function           => 'AMW_UPD_RL_PROC_OBJ_ASSOC'
                            ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                            ,p_instance_pk1_value => P_PK1
                            ,p_user_id            => fnd_global.user_id);
  end if;

  fnd_file.put_line(fnd_file.log,'&&&&&&&&&&&&&&& l_has_proc_obj_assoc_access: '||l_has_proc_obj_assoc_access||' &&&&&&&&&&&&&&&');
  --03.02.2005 npanandi: imposing the foll. IF condition to
  --create the association only if access privilege is present,
  --and moreover, only when associating Process to Objective in the spreadsheet
  if(l_has_proc_obj_assoc_access = 'T') then
  **/
     INSERT INTO amw_objective_associations(
         objective_association_id
        ,last_update_date
        ,last_updated_by
        ,creation_date
        ,created_by
        ,process_objective_id
        ,pk1
	    ---01.13.2005 npanandi: added pk2,pk3,pk4,pk5 for Ctrl to Obj association
	    ,PK2
	    ,PK3
	    ,PK4
	    ,PK5
        ,object_type
        ,effective_date_from
        ,ASSOCIATION_CREATION_DATE
        ,OBJECT_VERSION_NUMBER)
     VALUES (
         amw_objective_associations_s.NEXTVAL
        ,SYSDATE
        ,v_user_id
        ,SYSDATE
        ,v_user_id
        ,P_PROCESS_OBJECTIVE_ID
        ,P_PK1 --PROCESS_ID OR RISK_ID
	    ,P_PK2 --NULL OR RISK_ID
	    ,P_PK3 --NULL OR CONTROL_ID
	    ,P_PK4
	    ,P_PK5
        ,P_OBJECT_TYPE --'PROCESS' OR 'RISK' OR 'CONTROL'
        ,SYSDATE
        ,SYSDATE
        ,1
     );
  ---end if; ---end of check for l_has_proc_obj_assoc_access
END CREATE_AMW_OBJ_ASSOC;

PROCEDURE CREATE_AMW_RISK_ASSOC(
  P_RISK_ID 	  		   IN NUMBER
 ,P_PROCESS_ID	  		   IN NUMBER
 ,P_RISK_LIKELIHOOD_CODE   IN VARCHAR2
 ,P_RISK_IMPACT_CODE	   IN VARCHAR2
 ,P_MATERIAL			   IN VARCHAR2
 ,P_MATERIAL_VALUE		   IN NUMBER
)
IS
  l_has_proc_risk_assoc_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
BEGIN
/**
  ---03.02.2005 npanandi: check here to see if this Process has AMW_UPDATE_AP_DETAILS
  ---privilege to associate this Control to AP
  l_has_proc_risk_assoc_access := check_function(
                          p_function           => 'AMW_UPD_RL_PROC_RISK_ASSOC'
                         ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                         ,p_instance_pk1_value => P_PROCESS_ID
                         ,p_user_id            => fnd_global.user_id);

  fnd_file.put_line(fnd_file.log,'&&&&&&&&&&&&&&& l_has_proc_risk_assoc_access: '||l_has_proc_risk_assoc_access||' &&&&&&&&&&&&&&&');
  --03.02.2005 npanandi: imposing the foll. IF condition to
  --create the association only if access privilege is present
  if(l_has_proc_risk_assoc_access = 'T') then
  **/
    INSERT INTO amw_risk_associations(
        risk_association_id
       ,last_update_date
       ,last_updated_by
       ,creation_date
       ,created_by
       ,risk_id
       ,pk1
       ,object_type
       ,effective_date_from
	   ,ASSOCIATION_CREATION_DATE
       ,OBJECT_VERSION_NUMBER
       ,RISK_LIKELIHOOD_CODE
       ,RISK_IMPACT_CODE
       ,MATERIAL
       ,MATERIAL_VALUE)
    VALUES (
        amw_risk_associations_s.NEXTVAL
       ,SYSDATE
       ,v_user_id
       ,SYSDATE
       ,v_user_id
       ,P_RISK_ID
       ,P_process_id
       ,'PROCESS'
       ,SYSDATE
	   ,SYSDATE
       ,1
       ,P_risk_likelihood_code
       ,P_risk_impact_code
       ,P_MATERIAL
       ,P_MATERIAL_VALUE
    );
  --end if; ---end of check for l_has_proc_risk_assoc_access
END CREATE_AMW_RISK_ASSOC;

---
---03.01.2005 npanandi: add Risk/Ctrl Owner privilege here for data security
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
---03.01.2005 npanandi: function to check access privilege for this Risk/Ctrl
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


END amw_load_rc_data;

/
