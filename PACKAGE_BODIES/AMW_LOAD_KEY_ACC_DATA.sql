--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_KEY_ACC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_KEY_ACC_DATA" AS
/* $Header: amwkaccb.pls 120.0.12000000.3 2007/04/13 00:00:17 npanandi ship $ */
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


/*****************************************************************************/
/*****************************************************************************/
   PROCEDURE create_key_acc_assoc (
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
     ,p_user_id    IN              NUMBER
   )
   IS
/****************************************************/
      CURSOR key_acc_cur
      IS
         SELECT key_acc_interface_id
		 	   ,process_id
               ,financial_statement_id
               ,financial_item_id
               ,to_number(natural_account_id) as natural_account_id
               ,natural_account_acc_id
               ,processed_flag
               ,error_flag
               ,interface_status
           FROM amw_key_acc_interface
          WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
            AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
            AND processed_flag IS NULL
            AND error_flag IS NULL;

     CURSOR c_requestor_id IS
       SELECT party_id
         FROM amw_employees_current_v
        WHERE employee_id = (select employee_id
                               from fnd_user
                              where user_id = p_user_id)
          AND rownum = 1;

     cursor c_key_acc_exists(p_process_id in number, p_natural_account_id in number) is
        select acct_assoc_id
          from amw_acct_associations
         where object_type = 'PROCESS'
           and pk1 = p_process_id
           and natural_account_id = p_natural_account_id;

     l_process_id                            NUMBER;
     l_natural_account_id                    NUMBER;
     l_natural_account_acc_id                varchar2(100);
     l_natural_account_value                 varchar2(100);
     l_api_version_number      		CONSTANT NUMBER   := 1.0;
     l_requestor_id			      			 NUMBER;
     l_amw_delt_key_acc_intf        		 	 VARCHAR2 (2);

     lx_return_status		      			 VARCHAR2(30);
     lx_msg_count		      				 NUMBER;
     lx_msg_data		      				 VARCHAR2(2000);
     lx_acct_assoc_id		      			NUMBER;
     l_object_type_count	      			 NUMBER;
     l_process_flag		      				 VARCHAR2(1);
     e_no_import_access               		 EXCEPTION;
     e_invalid_requestor_id           		 EXCEPTION;

     L_ACCT_ASSOCIATION_ID      number;
     L_APPROVAL_DATE            date;

     l_startpos number;
     l_length number;
     l_valid_acc number;
     l_body varchar2(4000);
     l_prb_counts number;

     l_has_proc_acct_assoc_access varchar2(15) := 'T'; --defaulting to 'T', which means 'has access'
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
     l_amw_delt_key_acc_intf := nvl(fnd_profile.VALUE ('AMW_DELT_KEY_ACC_INTF'), 'N');

     AMW_UTILITY_PVT.Error_Message(p_message_name => 'AMW_PENDING_CHANGE_ERROR',
                                   p_token_name   => 'OBJ_TYPE',
                                   p_token_value  => AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','CTRL'));
     v_control_pending_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.G_LAST,p_encoded => fnd_api.g_false);

--
--   loop processing each record
--
     FOR kacc_rec IN key_acc_cur LOOP
       v_interface_id := kacc_rec.key_acc_interface_id;
	   l_process_id := kacc_rec.process_id;
	   l_natural_account_id := kacc_rec.natural_account_id;
       lx_acct_assoc_id := null;

	/**03.01.2007 npanandi: bug 5457611 fix -- parse the l_natural_account_acc_id
	        to get natural_account_id**/
              /*04.12.2007 npanandi: this is the scenario for existing
                problematic spreadsheets; multiple records with same
                NaturalAccountName exist, and the NaturalAccountAccId column
                is NULL*/
              if(kacc_rec.natural_account_acc_id is null) then
                 l_prb_counts := 0;
                 select count(distinct natural_account_value)
                   into l_prb_counts
                   from amw_fin_key_accounts_vl
                  where end_date is null
                    and account_name in (select distinct afkav.account_name
                                           from amw_fin_key_accounts_vl afkav
                                          where afkav.natural_account_id=kacc_rec.natural_account_id
                                            and afkav.end_date is null);
                 if(l_prb_counts > 1) then
                    fnd_message.set_name('AMW', 'AMW_WEBADI_VALID_ERROR');
                    fnd_message.set_token('ITEM', 'NATURAL_ACCOUNT_ID');
	            V_ERR_MSG := fnd_message.get;
	            UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
                 end if;
              end if;
              /*04.12.2007 npanandi: ends fix for NULL columns*/

	      if(kacc_rec.natural_account_acc_id is not null) then
	         ---parse the new column, only if it is not blank!!
	         l_natural_account_acc_id := kacc_rec.natural_account_acc_id;

	         /*compute NaturalAccountValue*/
	         l_natural_account_value := substr(l_natural_account_acc_id,1,(instr(l_natural_account_acc_id,'-',1,1)-1));
	         /*computed NaturalAccountValue*/

	         /*compute NaturalAccountId*/
	         l_startpos := instr(l_natural_account_acc_id,'-',1,2)+1; ---starting from the 2nd '-'
	         if(instr(l_natural_account_acc_id,'-',1,3) = 0)then --no parentNaturalAccountId
	            l_length := length(l_natural_account_acc_id) - (l_startpos-1);
	         else --parentNaturalAccountId exists
	            l_length := (instr(l_natural_account_acc_id,'-',1,3)) - l_startpos;
	         end if;
	         l_natural_account_id := substr(l_natural_account_acc_id,l_startpos,l_length);
	         /*computed NaturalAccountId*/

	         begin
	            select 1 into l_valid_acc from dual
	             where exists (select * from amw_fin_key_accounts_vl
	                            where natural_account_id=l_natural_account_id
	                              and natural_account_value=l_natural_account_value
	                              and end_date is null);
	         exception
	            when others then
	               fnd_message.set_name('AMW', 'AMW_WEBADI_VALID_ERROR');
	               fnd_message.set_token('ITEM', 'NATURAL_ACCOUNT_ID');
	               V_ERR_MSG := fnd_message.get;
	               UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
	         end;
	      end if;
	      /**03.01.2007 npanandi: bug 5457611 fix ends**/


	   --NPANANDI 12.08.2004: CALLING THIS PROCEDURE TO REVISE PROCESS, PER CHANGED
	   --PROCESS REVISION DATAMODEL
	   AMW_RL_HIERARCHY_PKG.revise_process_if_necessary(
		  P_PROCESS_ID => L_PROCESS_ID
	   );

	   --SET THESE VALUES TO NULL FOR THIS LOOP
	   L_ACCT_ASSOCIATION_ID := NULL;
	   L_APPROVAL_DATE		 := NULL;
	   BEGIN
          SELECT ACCT_ASSOC_ID, APPROVAL_DATE
            INTO L_ACCT_ASSOCIATION_ID,L_APPROVAL_DATE
            FROM AMW_ACCT_ASSOCIATIONS
           WHERE OBJECT_TYPE='PROCESS'
             AND PK1=l_process_id
             AND NATURAL_ACCOUNT_ID=l_natural_account_id
             AND DELETION_DATE IS NULL;
	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		     NULL;
	   END;

	   fnd_file.put_line (fnd_file.LOG, 'l_process_id '||l_process_id);
	   fnd_file.put_line (fnd_file.LOG, 'l_natural_account_id '||l_natural_account_id);
	   fnd_file.put_line (fnd_file.LOG, 'lx_acct_assoc_id '||lx_acct_assoc_id);

	   ---03.02.2005 npanandi: check here to see if this Process has AMW_UPDATE_AP_DETAILS
       ---privilege to associate this Control to AP
	   l_has_proc_acct_assoc_access := 'T';
       l_has_proc_acct_assoc_access := check_function(
                          p_function           => 'AMW_UPD_RL_PROC_ACCT_ASSOC'
                         ,p_object_name        => 'AMW_PROCESS_APPR_ETTY'
                         ,p_instance_pk1_value => l_PROCESS_ID
                         ,p_user_id            => fnd_global.user_id);

       fnd_file.put_line(fnd_file.log,'%%%%%%%%%%%%%%% l_has_proc_acct_assoc_access: '||l_has_proc_acct_assoc_access||' %%%%%%%%%%%%%%%');

       if(l_has_proc_acct_assoc_access = 'T')then
	      IF (L_ACCT_ASSOCIATION_ID is null) THEN
		     --NO ROW RETRIEVED, SO ASSOCIATION DOESN'T EXIST YET
		     --CREATE AN ASSOCIATION, SET ASSOCIATION_CREATION_DATE=SYSDATE
		     CREATE_AMW_KEY_ACC_ASSOC(
		        L_natural_account_id
		       ,L_process_id
		     );
	      ELSE
		     --THIS MEANS THAT ASSOCIATION EXISTS, SO CHECK APPROVAL_DATE

    		 --IF APPROVAL_DATE IS NULL FOR OBJECTIVE_ASSOCIATIONS,
		     --THIS MEANS THAT THIS ASSOCIATION
		     --IS LATEST_REVISION, SO SIMPLY UPDATE ASSOC ATTRIBUTES
		     IF(L_APPROVAL_DATE IS NOT NULL) THEN
		        --THIS MEANS THAT THIS IS LATEST REVISION FOR THIS ASSOCIATION
		        --AND IS APPROVED, SO
		        BEGIN
			       UPDATE AMW_ACCT_ASSOCIATIONS
			          SET DELETION_DATE=SYSDATE
				         ,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
				         ,LAST_UPDATE_DATE=SYSDATE
				         ,LAST_UPDATED_BY=G_USER_ID
				         ,LAST_UPDATE_LOGIN=G_LOGIN_ID
			        WHERE ACCT_ASSOC_ID=L_ACCT_ASSOCIATION_ID;

			       -- ...AND CREATE A NEW ROW FOR THE LATEST ASSOCIATION
			        CREATE_AMW_KEY_ACC_ASSOC(
			           L_natural_account_id
			          ,L_process_id
			        );
		         EXCEPTION
			        WHEN OTHERS THEN
			           V_ERR_MSG := 'INTERFACE_ID := '||v_interface_id||'  '||SUBSTR (SQLERRM, 1, 200);
			           UPDATE_INTERFACE_WITH_ERROR(V_ERR_MSG,V_TABLE_NAME,v_interface_id);
			     END;
              END IF;
           END IF; -- end of IF lx_acct_assoc_id is null OR...
        end if; ---end of if for l_has_proc_acct_assoc_access check
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

     IF UPPER (l_amw_delt_key_acc_intf) <> 'Y' THEN
       BEGIN
         UPDATE amw_key_acc_interface
            SET processed_flag = l_process_flag
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
           DELETE FROM amw_key_acc_interface WHERE batch_id = p_batch_id;
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
         UPDATE amw_key_acc_interface
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
         UPDATE amw_key_acc_interface
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
       fnd_file.put_line (fnd_file.LOG, 'unexpected exception in create_controls: '||sqlerrm);
   END create_key_acc_assoc;

PROCEDURE CREATE_AMW_KEY_ACC_ASSOC(
  P_natural_account_id			   IN NUMBER
 ,P_process_id 	  				   IN NUMBER
)
IS

BEGIN
  INSERT INTO amw_acct_associations(
    acct_assoc_id
   ,last_update_date
   ,last_updated_by
   ,creation_date
   ,created_by
   ,last_update_login
   ,ASSOCIATION_CREATION_DATE
   ,natural_account_id
   ,pk1
   ,object_type
   ,object_version_number
  )VALUES (
    amw_acct_associations_s.NEXTVAL
   ,SYSDATE
   ,v_user_id
   ,SYSDATE
   ,v_user_id
   ,G_LOGIN_ID
   ,SYSDATE
   ,P_natural_account_id
   ,P_process_id
   ,'PROCESS'
   ,1
  );
END CREATE_AMW_KEY_ACC_ASSOC;

---
---03.02.2005 npanandi: function to check access privilege for this Risk/Ctrl
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

   fnd_file.put_line (fnd_file.LOG, 'l_security_switch: '||l_security_switch);
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
---03.02.2005 npanandi: end function to check access privilege


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
      l_interface_status   amw_key_acc_interface.interface_status%TYPE;
   BEGIN
      ROLLBACK; -- rollback any inserts done during the current loop process
      v_error_found := TRUE;

      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_key_acc_interface
          WHERE key_acc_interface_id = p_interface_id;
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
         UPDATE amw_key_acc_interface
            SET interface_status =
                       l_interface_status
               --     || 'Error Msg: '
                    || p_err_msg
               --     || ' Table Name: '
               --     || p_table_name
                    || '**'
               ,error_flag = 'Y'
          WHERE key_acc_interface_id = p_interface_id;

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

END amw_load_key_acc_data;

/
