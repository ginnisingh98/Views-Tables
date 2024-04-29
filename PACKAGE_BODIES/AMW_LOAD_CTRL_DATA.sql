--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_CTRL_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_CTRL_DATA" AS
/* $Header: amwctrdb.pls 120.0 2005/05/31 18:37:39 appldev noship $ */
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/* Major Functionality of the followIng procedure includes:                  */
/* Reads the amw_risk-ctrl_interface table                                   */
/* following tables:                                                         */
/*  INSERTS OR UPDATES ARE DONE AGAINIST THE FOLLOWING TABLES       */
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
   v_err_msg                   				VARCHAR2 (2000);
   v_table_name                				VARCHAR2 (240);

   ---02.03.2005 npanandi: increased Varchar2 length of v_import_func
   ---from 30 to 480 per FND mandate
   v_import_func      CONSTANT 				VARCHAR2(480) := 'AMW_DATA_IMPORT';

   v_control_db_approval_status				VARCHAR2(30);

   v_invalid_requestor_msg	  				VARCHAR2(2000);
   v_no_import_privilege_msg	  			VARCHAR2(2000);
   v_control_pending_msg	  				VARCHAR2(2000);
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
   PROCEDURE create_controls (
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
     ,p_user_id    IN              NUMBER
   )
   IS
/****************************************************/
      CURSOR controls_cur
      IS
         SELECT     ctrl_interface_id
		 			,control_approval_status_code
		 			,control_automation_type_code
                    ,control_description
					,control_job_id
					,control_location_code
                    ,control_name
					,control_source
                    ,control_type_code
			        ,physical_evidence
					,revise_ctrl_flag
					,control_application_id
                    ,preventive_control
					,detective_control
					,disclosure_control
					,key_mitigating
					,verification_source
					,verification_source_name
					,verification_instruction
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
					--npanandi 12.08.2004: Control Enhancements upload
					,UOM_CODE
					,CONTROL_FREQUENCY
					,CTRL_PURPOSE1
					,CTRL_PURPOSE2
					,CTRL_PURPOSE3
					,CTRL_PURPOSE4
					,CTRL_PURPOSE5
					,CTRL_PURPOSE6
					,CTRL_PURPOSE7
					,CTRL_PURPOSE8
					,CTRL_PURPOSE9
					,CTRL_PURPOSE10
					,CTRL_PURPOSE11
					,CTRL_PURPOSE12
					,CTRL_PURPOSE13
					,CTRL_PURPOSE14
					,CTRL_PURPOSE15
					,CTRL_PURPOSE16
					,CTRL_PURPOSE17
					,CTRL_PURPOSE18
					,CTRL_PURPOSE19
					,CTRL_PURPOSE20
					,CTRL_PURPOSE21
					,CTRL_PURPOSE22
					,CTRL_PURPOSE23
					,CTRL_PURPOSE24
					,CTRL_PURPOSE25
					,CTRL_PURPOSE26
					,CTRL_PURPOSE27
					,CTRL_PURPOSE28
					,CTRL_PURPOSE29
					,CTRL_PURPOSE30
					---NPANANDI 12.13.2004: ADDED BELOW FOR CTRL CLASSIFICATION ENH.
					,CLASSIFICATION
           FROM amw_ctrl_interface
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

     CURSOR c_control_exists (c_control_name IN VARCHAR2) IS
       SELECT b.control_id, b.approval_status
         FROM amw_controls_b b, amw_controls_tl tl
        WHERE tl.name = c_control_name
	      AND tl.language = USERENV('LANG')
          AND tl.control_rev_id = b.control_rev_id
	      AND b.latest_revision_flag='Y';

     l_api_version_number      		CONSTANT NUMBER   := 1.0;
     l_requestor_id			      			 NUMBER;
     l_amw_delt_ctrl_intf        		 	 VARCHAR2 (2);
     l_amw_control_name_prefix        		 VARCHAR2 (30);
     l_control_rec		      				 AMW_CONTROL_PVT.control_rec_type;
     l_control_found                  		 BOOLEAN        default true;
     l_control_approval_status_code   		 VARCHAR2(30);
     l_control_name		      				 VARCHAR2(240);
	 l_application_id		  				 NUMBER;

     lx_return_status		      			 VARCHAR2(30);
     lx_msg_count		      				 NUMBER;
     lx_msg_data		      				 VARCHAR2(2000);
     lx_control_id		      				 NUMBER;
     lx_mode_affected		      			 VARCHAR2(30);
     l_object_type_count	      			 NUMBER;
     l_process_flag		      				 VARCHAR2(1);
     e_no_import_access               		 EXCEPTION;
     e_invalid_requestor_id           		 EXCEPTION;

     l_revise_control_flag	      			 VARCHAR2(1);

     ---02.28.2005 npanandi:
     l_new_control                           boolean default true;
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
     l_amw_delt_ctrl_intf := NVL(fnd_profile.VALUE ('AMW_DELT_CTRL_INTF'), 'N');

     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                   p_token_name   => 'OBJ_TYPE',
                                   p_token_value  => AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','CTRL'));
     v_control_pending_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_LAST,p_encoded => fnd_api.g_false);

--
--   loop processing each record
--
     FOR ctrl_rec IN controls_cur LOOP
       BEGIN
			 v_interface_id := ctrl_rec.ctrl_interface_id;
			 l_control_approval_status_code := ctrl_rec.control_approval_status_code;
			 l_revise_control_flag := upper(NVL(ctrl_rec.revise_ctrl_flag, 'N'));

			 fnd_file.put_line (fnd_file.LOG, 'v_interface_id: '||v_interface_id);
			 fnd_file.put_line (fnd_file.LOG, 'l_control_approval_status_code: '||l_control_approval_status_code);
			 fnd_file.put_line (fnd_file.LOG, 'l_revise_control_flag: '||l_revise_control_flag);

--
--    process control
--
			   lx_control_id := null;
			   v_control_db_approval_status := null;

			   ---02.18.2005 npanandi: fix for bug 4141121
			   l_amw_control_name_prefix := fnd_profile.VALUE ('AMW_CONTROL_NAME_PREFIX');
			   ---02.18.2005 npanandi: ends fix for bug 4141121

			   SELECT DECODE (ctrl_rec.control_name,NULL
						     ,l_amw_control_name_prefix||amw_controls_tl_s1.NEXTVAL
			                 ,ctrl_rec.control_name)
				 INTO l_control_name
				 FROM dual;

			   OPEN c_control_exists(l_control_name);
		           FETCH c_control_exists INTO lx_control_id, v_control_db_approval_status;
			   CLOSE c_control_exists;

			   fnd_file.put_line (fnd_file.LOG, 'l_control_name: '||l_control_name);
			   fnd_file.put_line (fnd_file.LOG, 'lx_control_id: '||lx_control_id);
			   fnd_file.put_line (fnd_file.LOG, 'v_control_db_approval_status: '||v_control_db_approval_status);

			   ---02.28.2005 npanandi: added data security checks
			   l_has_access := 'T'; ---setting this to 'T' for new Controls
			   if(lx_control_id is not null) then
			      ---Check for Update privilege here
				  l_new_control := false;
				  fnd_file.put_line (fnd_file.LOG, '************** Checking Update Privilege for l_control_name: '||l_control_name);
				  l_has_access := check_function(
				                     p_function           => 'AMW_CTRL_UPDATE_PRVLG'
                                    ,p_object_name        => 'AMW_CONTROL'
                                    ,p_instance_pk1_value => lx_control_id
                                    ,p_user_id            => fnd_global.user_id);
                  fnd_file.put_line (fnd_file.LOG, 'l_has_access: '||l_has_access);
                  fnd_file.put_line (fnd_file.LOG, '************** Checked Update Privilege for l_control_name: '||l_control_name);

                  IF l_has_access <> 'T' then
				     v_err_msg := 'Cannot update this Ctrl';
				     update_interface_with_error (v_err_msg
			                                       ,'AMW_CONTROLS'
			                                       ,v_interface_id);
				  END IF;
			   end if;
			   ---02.28.2005 npanandi: added data security checks ends

	           IF Control_Can_Be_Processed AND
	              ---02.28.2005 npanandi: added check for lHasAccess to update this Ctrl
	              ---only if this user has Upd privilege
	              l_has_access = 'T' and
		       (lx_control_id is null OR
		        l_revise_control_flag = 'Y') THEN

				     l_control_rec.name   				   			:= l_control_name;
				     l_control_rec.description 			   			:= nvl(ctrl_rec.CONTROL_DESCRIPTION, l_control_name);
				     l_control_rec.approval_status 		   			:= l_control_approval_status_code;
					 l_control_rec.control_location 	   			:= ctrl_rec.CONTROL_LOCATION_CODE;
					 l_control_rec.control_type 		   			:= ctrl_rec.CONTROL_TYPE_CODE;
					 l_control_rec.automation_type		   			:= ctrl_rec.CONTROL_AUTOMATION_TYPE_CODE;
				     l_control_rec.application_id 		   			:= ctrl_rec.control_application_id;
				     l_control_rec.source 				   			:= ctrl_rec.CONTROL_SOURCE;
					 l_control_rec.physical_evidence 	   			:= ctrl_rec.PHYSICAL_EVIDENCE;
				     l_control_rec.job_id 				   			:= ctrl_rec.CONTROL_JOB_ID;
				     l_control_rec.preventive_control 	   			:= Upper(nvl(ctrl_rec.preventive_control,'N'));
					 l_control_rec.detective_control 	   			:= Upper(nvl(ctrl_rec.detective_control,'N'));
					 l_control_rec.disclosure_control 	   			:= Upper(nvl(ctrl_rec.disclosure_control,'N'));
					 l_control_rec.key_mitigating 	   	   			:= Upper(nvl(ctrl_rec.key_mitigating,'N'));
					 l_control_rec.verification_source 	   			:= ctrl_rec.verification_source;
					 l_control_rec.verification_source_name 	   	:= ctrl_rec.verification_source_name;
					 l_control_rec.verification_instruction 	   	:= ctrl_rec.verification_instruction;
				     l_control_rec.requestor_id 		   			:= l_requestor_id;
					 --NPANANDI 12.08.2004: ADDITION OF CONTROL ENHANCEMENTS --> CTRL_FREQ, UOM_CODE
					 L_CONTROL_REC.UOM_CODE							:= CTRL_REC.UOM_CODE;
					 L_CONTROL_REC.CONTROL_FREQUENCY				:= CTRL_REC.CONTROL_FREQUENCY;
					 ---NPANANDI 12.13.2004: ADDED BELOW FOR CTRL CLASSIFICATION ENH.
					 L_CONTROL_REC.CLASSIFICATION				  	:= CTRL_REC.CLASSIFICATION;

					 fnd_file.put_line (fnd_file.LOG,'%%%%%%%%%%%%%% AMW_CONTROL_PVT.Load_Control calling below, checking values passed');
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.name: '||l_control_rec.name);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.description: '||l_control_rec.description);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.approval_status: '||l_control_rec.approval_status);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.control_location: '||l_control_rec.control_location);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.control_type: '||l_control_rec.control_type);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.automation_type: '||l_control_rec.automation_type);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.application_id: '||l_control_rec.application_id);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.source: '||l_control_rec.source);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.physical_evidence: '||l_control_rec.physical_evidence);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.job_id: '||l_control_rec.job_id);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.preventive_control: '||l_control_rec.preventive_control);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.detective_control: '||l_control_rec.detective_control);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.disclosure_control: '||l_control_rec.disclosure_control);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.key_mitigating: '||l_control_rec.key_mitigating);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.verification_source: '||l_control_rec.verification_source);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.verification_source_name: '||l_control_rec.verification_source_name);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.verification_instruction: '||l_control_rec.verification_instruction);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.UOM_CODE: '||l_control_rec.UOM_CODE);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.CONTROL_FREQUENCY: '||l_control_rec.CONTROL_FREQUENCY);
					 fnd_file.put_line (fnd_file.LOG,'l_control_rec.CLASSIFICATION: '||l_control_rec.CLASSIFICATION);

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

					 ---02.28.2005 npanandi: if new Control, grant CtrlOwner prvlg
					 if(l_new_control) then
					    add_owner_privilege(
						   p_role_name          => 'AMW_CTRL_OWNER_ROLE'
						  ,p_object_name        => 'AMW_CONTROL'
						  ,p_grantee_type       => 'P'
						  ,p_instance_pk1_value => lx_control_id
						  ,p_user_id            => FND_GLOBAL.USER_ID);
					 end if;
					 ---02.28.2005 npanandi: if new Control, grant CtrlOwner prvlg

					 fnd_file.put_line (fnd_file.LOG,'lx_return_status: '||lx_return_status);
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

                     ---12.28.2004 npanandi: execute the below
                     ---procedures only if AmwControlPvt goes through successfully
                     if(lx_return_status = FND_API.G_RET_STS_SUCCESS)then
					--
					-- process control components
					--
				     control_components(ctrl_rec.control_comp1, '1');
				     control_components(ctrl_rec.control_comp2, '2');
				     control_components(ctrl_rec.control_comp3, '3');
				     control_components(ctrl_rec.control_comp4, '4');
				     control_components(ctrl_rec.control_comp5, '5');
				     control_components(ctrl_rec.control_comp6, '6');
				     control_components(ctrl_rec.control_comp7, '7');
				     control_components(ctrl_rec.control_comp8, '8');
				     control_components(ctrl_rec.control_comp9, '9');
				     control_components(ctrl_rec.control_comp10, '10');
				     control_components(ctrl_rec.control_comp11, '11');
				     control_components(ctrl_rec.control_comp12, '12');
				     control_components(ctrl_rec.control_comp13, '13');
				     control_components(ctrl_rec.control_comp14, '14');
				     control_components(ctrl_rec.control_comp15, '15');
				     control_components(ctrl_rec.control_comp16, '16');
				     control_components(ctrl_rec.control_comp17, '17');
				     control_components(ctrl_rec.control_comp18, '18');
				     control_components(ctrl_rec.control_comp19, '19');
				     control_components(ctrl_rec.control_comp20, '20');
				     control_components(ctrl_rec.control_comp21, '21');
				     control_components(ctrl_rec.control_comp22, '22');
				     control_components(ctrl_rec.control_comp23, '23');
				     control_components(ctrl_rec.control_comp24, '24');
				     control_components(ctrl_rec.control_comp25, '25');
				     control_components(ctrl_rec.control_comp26, '26');
				     control_components(ctrl_rec.control_comp27, '27');
				     control_components(ctrl_rec.control_comp28, '28');
				     control_components(ctrl_rec.control_comp29, '29');
				     control_components(ctrl_rec.control_comp30, '30');

--
-- process control components
--
				     control_objectives(ctrl_rec.control_obj1, '1');
				     control_objectives(ctrl_rec.control_obj2, '2');
				     control_objectives(ctrl_rec.control_obj3, '3');
				     control_objectives(ctrl_rec.control_obj4, '4');
				     control_objectives(ctrl_rec.control_obj5, '5');
				     control_objectives(ctrl_rec.control_obj6, '6');
				     control_objectives(ctrl_rec.control_obj7, '7');
				     control_objectives(ctrl_rec.control_obj8, '8');
				     control_objectives(ctrl_rec.control_obj9, '9');
				     control_objectives(ctrl_rec.control_obj10, '10');
				     control_objectives(ctrl_rec.control_obj11, '11');
				     control_objectives(ctrl_rec.control_obj12, '12');
				     control_objectives(ctrl_rec.control_obj13, '13');
				     control_objectives(ctrl_rec.control_obj14, '14');
				     control_objectives(ctrl_rec.control_obj15, '15');
				     control_objectives(ctrl_rec.control_obj16, '16');
				     control_objectives(ctrl_rec.control_obj17, '17');
				     control_objectives(ctrl_rec.control_obj18, '18');
				     control_objectives(ctrl_rec.control_obj19, '19');
				     control_objectives(ctrl_rec.control_obj20, '20');
				     control_objectives(ctrl_rec.control_obj21, '21');
				     control_objectives(ctrl_rec.control_obj22, '22');
				     control_objectives(ctrl_rec.control_obj23, '23');
				     control_objectives(ctrl_rec.control_obj24, '24');
				     control_objectives(ctrl_rec.control_obj25, '25');
				     control_objectives(ctrl_rec.control_obj26, '26');
				     control_objectives(ctrl_rec.control_obj27, '27');
				     control_objectives(ctrl_rec.control_obj28, '28');
				     control_objectives(ctrl_rec.control_obj29, '29');
				     control_objectives(ctrl_rec.control_obj30, '30');
			--
			-- process control assertions
			--
				     control_assertions(ctrl_rec.control_assert1, '1');
				     control_assertions(ctrl_rec.control_assert2, '2');
				     control_assertions(ctrl_rec.control_assert3, '3');
				     control_assertions(ctrl_rec.control_assert4, '4');
				     control_assertions(ctrl_rec.control_assert5, '5');
				     control_assertions(ctrl_rec.control_assert6, '6');
				     control_assertions(ctrl_rec.control_assert7, '7');
				     control_assertions(ctrl_rec.control_assert8, '8');
				     control_assertions(ctrl_rec.control_assert9, '9');
				     control_assertions(ctrl_rec.control_assert10, '10');
				     control_assertions(ctrl_rec.control_assert11, '11');
				     control_assertions(ctrl_rec.control_assert12, '12');
				     control_assertions(ctrl_rec.control_assert13, '13');
				     control_assertions(ctrl_rec.control_assert14, '14');
				     control_assertions(ctrl_rec.control_assert15, '15');
				     control_assertions(ctrl_rec.control_assert16, '16');
				     control_assertions(ctrl_rec.control_assert17, '17');
				     control_assertions(ctrl_rec.control_assert18, '18');
				     control_assertions(ctrl_rec.control_assert19, '19');
				     control_assertions(ctrl_rec.control_assert20, '20');
				     control_assertions(ctrl_rec.control_assert21, '21');
				     control_assertions(ctrl_rec.control_assert22, '22');
				     control_assertions(ctrl_rec.control_assert23, '23');
				     control_assertions(ctrl_rec.control_assert24, '24');
				     control_assertions(ctrl_rec.control_assert25, '25');
				     control_assertions(ctrl_rec.control_assert26, '26');
				     control_assertions(ctrl_rec.control_assert27, '27');
				     control_assertions(ctrl_rec.control_assert28, '28');
				     control_assertions(ctrl_rec.control_assert29, '29');
				     control_assertions(ctrl_rec.control_assert30, '30');

					 --NPANANDI 12.08,2004: ADDED BELOW TO PROCESS
					 --CONTROL PURPOSES FOR CONTROL ENHANCEMENT

					 --
			         -- process control assertions
			         --
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE1, '1');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE2, '2');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE3, '3');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE4, '4');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE5, '5');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE6, '6');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE7, '7');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE8, '8');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE9, '9');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE10, '10');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE11, '11');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE12, '12');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE13, '13');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE14, '14');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE15, '15');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE16, '16');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE17, '17');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE18, '18');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE19, '19');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE20, '20');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE21, '21');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE22, '22');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE23, '23');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE24, '24');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE25, '25');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE26, '26');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE27, '27');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE28, '28');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE29, '29');
				     CONTROL_PURPOSES(ctrl_rec.CTRL_PURPOSE30, '30');
				     end if; ---end of if(lx_return_status = FND_API.G_RET_STS_SUCCESS)then
               END IF; -- end of IF lx_control_id is null OR...

       EXCEPTION
         WHEN OTHERS THEN
           v_err_msg := 'interface_id: = '
                      || v_interface_id
                      || '  '
                      || SUBSTR (SQLERRM, 1, 100);
                  v_table_name := 'UNKNOWN';
	   			  update_interface_with_error (v_err_msg,v_table_name,v_interface_id);
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

     IF UPPER (l_amw_delt_ctrl_intf) <> 'Y' THEN
       BEGIN
         UPDATE amw_ctrl_interface
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
           DELETE FROM amw_ctrl_interface
                 WHERE batch_id = p_batch_id;

         EXCEPTION
           WHEN OTHERS THEN
             fnd_file.put_line (fnd_file.LOG,'err in delete interface records: '||SUBSTR (SQLERRM, 1, 200));
         END;
       END IF;
     END IF;
   EXCEPTION

     WHEN e_invalid_requestor_id THEN
       fnd_file.put_line (fnd_file.LOG
                         , 'Invalid requestor id.');

       BEGIN
	 IF v_invalid_requestor_msg is null THEN
	   v_invalid_requestor_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_UNKNOWN_EMPLOYEE');
	 END IF;
         UPDATE amw_ctrl_interface
            SET error_flag = 'Y'
                ,interface_status = v_invalid_requestor_msg
          WHERE batch_id = p_batch_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line (fnd_file.LOG
                         , 'unexpected exception in handling e_invalid_requestor_id: '||sqlerrm);
       END;
     WHEN e_no_import_access THEN
       fnd_file.put_line (fnd_file.LOG,'no import privilege --> p_batch_id: '||p_batch_id);
       BEGIN
         IF v_no_import_privilege_msg is null THEN
		   fnd_file.put_line (fnd_file.LOG,'1 v_no_import_privilege_msg: '||v_no_import_privilege_msg);
	       v_no_import_privilege_msg := FND_MESSAGE.GET_STRING('AMW', 'AMW_NO_IMPORT_ACCESS');
		   fnd_file.put_line (fnd_file.LOG,'2 v_no_import_privilege_msg: '||v_no_import_privilege_msg);
	     END IF;
         UPDATE amw_ctrl_interface
            SET error_flag = 'Y'
                ,interface_status = v_no_import_privilege_msg
          WHERE batch_id = p_batch_id;
		  fnd_file.put_line (fnd_file.LOG,'updated the Intf table');
          EXCEPTION
             WHEN OTHERS THEN
               fnd_file.put_line (fnd_file.LOG
                         , 'unexpected exception in handling e_no_import_access: '||sqlerrm);
             END;
     WHEN others THEN
       rollback;
       fnd_file.put_line (fnd_file.LOG, 'unexpected exception in create_controls: '||sqlerrm);
   END create_controls;

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
						   ---effective_date from and to are not used anywa
                           ---,effective_date_from
			   			   ---,effective_date_to
			   			   ,OBJECT_VERSION_NUMBER
                           ) VALUES (
						   amw_control_objectives_s.NEXTVAL
                           ,SYSDATE
                           ,v_user_id
                           ,SYSDATE
                           ,v_user_id
                           ,vx_control_rev_id
                           ,l_ctrl_obj_code
						   ---effective_date from and to are not used anywa
                           ---,SYSDATE
			   			   ---,DECODE (l_ctrl_obj_flag, 'N', SYSDATE, NULL)
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

	   /*
	   UPDATE amw_control_assertions
          SET effective_date_to = DECODE (l_ctrl_assert_flag, 'N', SYSDATE, NULL)
             ,last_update_date = SYSDATE
             ,last_updated_by = v_user_id
	     ,OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
       WHERE control_rev_id = vx_control_rev_id
         AND ASSERTION_CODE = l_ctrl_assert_code;
		 */

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

-- NPANANDI 12.08.2004: ADDED BELOW PROCEDURE TO HANDLE CTRL PURPOSES
-- ---> CONTROL ENHANCEMENT
--
--  Insert or update the control PURPOSES
--
PROCEDURE control_PURPOSES (p_ctrl_PURPOSE_flag IN VARCHAR2, p_lookup_tag IN VARCHAR2)
IS
   CURSOR c_control_PURPOSE IS
  	  SELECT lookup_code
  		FROM AMW_LOOKUPS
	   WHERE lookup_type='AMW_CONTROL_PURPOSES'
  		 AND enabled_flag='Y'
  		 AND tag=p_lookup_tag;

   l_ctrl_PURPOSE_code	VARCHAR2(30);
   l_ctrl_PURPOSE_flag	VARCHAR2(1);
   l_PURPOSE_exists		number;
   e_invalid_PURPOSE	EXCEPTION;
   e_invalid_flag		EXCEPTION;
BEGIN
   IF (p_ctrl_PURPOSE_flag is not null) THEN
      IF UPPER (p_ctrl_PURPOSE_flag) = 'Y' THEN
	   	 l_ctrl_PURPOSE_flag := 'Y';
      ELSIF UPPER (p_ctrl_PURPOSE_flag) = 'N' THEN
	   	 l_ctrl_PURPOSE_flag := 'N';
      ELSE
	   	 RAISE e_invalid_flag;
      END IF;

      OPEN c_control_PURPOSE;
      FETCH c_control_PURPOSE INTO l_ctrl_PURPOSE_code;
         IF (c_control_PURPOSE%NOTFOUND) THEN
            CLOSE c_control_PURPOSE;
	 		RAISE e_invalid_PURPOSE;
         END IF;
      CLOSE c_control_PURPOSE;

	  if (l_ctrl_PURPOSE_flag = 'N') then
	     select count(*)
		   into l_PURPOSE_exists
		   from amw_control_PURPOSES
		  where control_rev_id = vx_control_rev_id
		   	AND PURPOSE_code = l_ctrl_PURPOSE_code;

		 if(l_PURPOSE_exists > 0) then
		   	delete from amw_control_PURPOSEs
			 where control_rev_id = vx_control_rev_id
		   	   AND PURPOSE_code = l_ctrl_PURPOSE_code;
		 end if;
	  end if;

	  if(l_ctrl_PURPOSE_flag = 'Y') then
		 select count(*)
		   into l_PURPOSE_exists
		   from amw_control_PURPOSEs
		  where control_rev_id = vx_control_rev_id
		   	AND PURPOSE_code = l_ctrl_PURPOSE_code;

		 if(l_PURPOSE_exists = 0)then
			---IF SQL%NOTFOUND THEN
         	INSERT INTO amw_control_PURPOSES(
			   control_PURPOSE_id
              ,last_update_date
              ,last_updated_by
              ,creation_date
              ,created_by
              ,control_rev_id
              ,PURPOSE_CODE
			  ,effective_date_from
			  ----,effective_date_to
			  ,OBJECT_VERSION_NUMBER
            ) VALUES (
			   amw_control_PURPOSEs_s.NEXTVAL
              ,SYSDATE
              ,v_user_id
              ,SYSDATE
              ,v_user_id
              ,vx_control_rev_id
              ,l_ctrl_PURPOSE_code
              ,SYSDATE
			  ----,DECODE (l_ctrl_PURPOSE_flag, 'N', SYSDATE, NULL)
			  ,1
            );
		 end if; --end of if for l_PURPOSE_exists
	  end if; -- end of if for l_PURPOSE_flag = 'Y'
   END IF; --- end of if p_PURPOSE_flag not null
EXCEPTION
   WHEN e_invalid_flag THEN
      v_err_msg := 'Error working in procedure control PURPOSES:  '
                || 'PURPOSE code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   flag must be Y/N';
      v_table_name := 'AMW_CONTROL_PURPOSES';
      update_interface_with_error (v_err_msg
                                  ,v_table_name
                                  ,v_interface_id);

   WHEN e_invalid_PURPOSE THEN
      v_err_msg := 'Error working in procedure control PURPOSES:  '
                || 'PURPOSE code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '   code does not exist';
      v_table_name := 'AMW_CONTROL_PURPOSES';
      update_interface_with_error (v_err_msg
                                  ,v_table_name
                                  ,v_interface_id);

   WHEN OTHERS THEN
      v_err_msg := 'Error working in procedure control PURPOSES:  '
                || 'PURPOSE code tag: '
                || p_lookup_tag
                || 'using interface id of: '
                || v_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
      v_table_name := 'AMW_CONTROL_PURPOSES';
      update_interface_with_error (v_err_msg
                                  ,v_table_name
                                  ,v_interface_id);
END control_PURPOSEs;
--NPANANDI 12.08.2004 ENHANCEMENT ENDS

---
---02.28.2005 npanandi: add Control Owner privilege here for data security
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
---02.28.2005 npanandi: ends method for grant owner privilege

---
---02.28.2005 npanandi: function to check access privilege for this Control
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
---02.28.2005 npanandi: end function to check access privilege

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
      l_interface_status   amw_ctrl_interface.interface_status%TYPE;
   BEGIN
      ROLLBACK; -- rollback any inserts done during the current loop process
      v_error_found := TRUE;

      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_ctrl_interface
          WHERE ctrl_interface_id = p_interface_id;
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
         UPDATE amw_ctrl_interface
            SET interface_status =
                       l_interface_status
               --     || 'Error Msg: '
                    || p_err_msg
               --     || ' Table Name: '
               --     || p_table_name
                    || '**'
               ,error_flag = 'Y'
          WHERE ctrl_interface_id = p_interface_id;

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

END amw_load_ctrl_data;

/
