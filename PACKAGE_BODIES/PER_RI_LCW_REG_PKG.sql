--------------------------------------------------------
--  DDL for Package Body PER_RI_LCW_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_LCW_REG_PKG" AS
/* $Header: perrilcw.pkb 120.0.12010000.3 2009/07/25 16:05:50 sbrahmad noship $ */
PROCEDURE per_ri_lcw_register
           (p_workbench_item_code            In  Varchar2
 	   ,p_setup_task_code            In  Varchar2
           ,p_setup_task_name            In  Varchar2
	   ,p_setup_task_seq		     In  Number
	   ,p_setup_sub_task_code            In  Varchar2
           ,p_setup_sub_task_name            In  Varchar2
           ,p_setup_sub_task_action          In  Varchar2
           ,p_legislation_code               In  Varchar2
	   ,p_sub_task_seq		     In  Number
	   ,p_object_version_number	     In Out nocopy Number
	   ,p_msg 			     Out nocopy Varchar2
     ) Is
CURSOR csr_chk_task_exists IS
   SELECT 1
     FROM per_ri_setup_tasks
    WHERE workbench_item_code = p_workbench_item_code
      AND setup_task_code = p_setup_task_code;


CURSOR csr_get_max_task_seq IS
   SELECT max(setup_task_sequence)
     FROM per_ri_setup_tasks
    WHERE workbench_item_code = p_workbench_item_code;

CURSOR csr_get_max_sub_task_seq IS
   SELECT max(setup_sub_task_sequence)
     FROM per_ri_setup_sub_tasks
    WHERE setup_task_code = p_setup_task_code;


CURSOR csr_get_max_entry_seq (p_menu_id number) IS
   SELECT max(entry_sequence)
     FROM fnd_menu_entries
    WHERE menu_id = p_menu_id;

--To be changed as soon as the issue with table's PK is resolved
Cursor chk_sub_task_exists IS
   SELECT psst.setup_sub_task_sequence
     FROM per_ri_setup_sub_tasks psst,fnd_territories_vl ter
    WHERE psst.setup_sub_task_code = p_setup_sub_task_code;
   --   AND psst.setup_task_code = 'LCW_' || p_workbench_item_code
  --    AND psst.legislation_code= p_legislation_code;


l_max_task_seq   NUMBER;
l_task_seq      NUMBER;
l_max_sub_task_seq NUMBER;
l_sub_task_seq   NUMBER;
l_max_entry_seq  NUMBER;
l_main_menu_id   NUMBER;
l_dummy          NUMBER;
l_ovn            NUMBER;
l_sub_ovn            NUMBER;
l_leg_code 	 VARCHAR(30);
l_row_id         VARCHAR2(2000);
l_cus_task_start_seq NUMBER := 10000;
Begin


OPEN csr_chk_task_exists;
  FETCH csr_chk_task_exists INTO l_dummy;
  IF (csr_chk_task_exists%NOTFOUND) THEN
      l_task_seq := l_cus_task_start_seq + p_setup_task_seq;
      per_ri_setup_task_api.create_setup_task(
        p_validate                      => FALSE
       ,p_setup_task_code               => p_setup_task_code
       ,p_workbench_item_code           => p_workbench_item_code
       ,p_setup_task_name               => p_setup_task_name
       ,p_setup_task_description        => p_setup_task_name
       ,p_setup_task_sequence           => l_task_seq
       ,p_setup_task_status             => 'NOT_STARTED'
       ,p_setup_task_creation_date      => sysdate
       ,p_setup_task_last_mod_date      => sysdate
       ,p_setup_task_type               => 'WIZARD'
       ,p_setup_task_action             => 'OA.jsp?OAFunc=PER_RI_LCW&setupTaskCode={!SetupTaskCode}&retainAM=Y&addBreadCrumb=Y'
       ,p_effective_date                => sysdate
       ,p_object_version_number         => l_ovn
        );
        create_lcw_oaf_function('S_' || substr(p_setup_task_code , 1 , 28) , p_setup_task_name);
  END IF;
CLOSE csr_chk_task_exists;

/*OPEN chk_sub_task_exists;
  FETCH chk_sub_task_exists into l_sub_task_seq;
  if (chk_sub_task_exists%NOTFOUND) then
    OPEN csr_get_max_sub_task_seq;
      FETCH csr_get_max_sub_task_seq into l_max_sub_task_seq;
    CLOSE csr_get_max_sub_task_seq;
       l_max_sub_task_seq := nvl(l_max_sub_task_seq,0) + 1;
  end if;
CLOSE chk_sub_task_exists;
*/

OPEN chk_sub_task_exists;
 FETCH chk_sub_task_exists into l_sub_task_seq;
  if (chk_sub_task_exists%NOTFOUND) then
  --Create Sub Task
  l_sub_task_seq := l_cus_task_start_seq + p_sub_task_seq;
  per_ri_setup_sub_task_api.CREATE_SETUP_SUB_TASK
  	   (  P_SETUP_SUB_TASK_CODE  	    =>p_setup_sub_task_code,
  	      P_SETUP_SUB_TASK_NAME         =>p_setup_sub_task_name,
  	      P_SETUP_SUB_TASK_DESCRIPTION  =>p_setup_sub_task_name,
	      P_SETUP_TASK_CODE             =>p_setup_task_code,
	      P_SETUP_SUB_TASK_SEQUENCE     =>l_sub_task_seq,
	      P_SETUP_SUB_TASK_STATUS       =>'NOT_STARTED',
	      P_SETUP_SUB_TASK_TYPE         => null,
	      P_SETUP_SUB_TASK_DP_LINK      => null,
	      P_SETUP_SUB_TASK_ACTION       => p_setup_sub_task_action,
	      P_SETUP_SUB_TASK_CREATION_DATE =>sysdate,
	      P_SETUP_SUB_TASK_LAST_MOD_DATE =>sysdate,
	      P_LEGISLATION_CODE            => p_legislation_code,
	      P_LANGUAGE_CODE               => 'US',
	      P_EFFECTIVE_DATE              =>sysdate,
	      P_OBJECT_VERSION_NUMBER       => p_object_version_number
	    );

	    p_msg := 'Success';
  else
  --Update Sub Task
  	if(p_object_version_number = 0)
  	 then
  	  p_msg := 'PER_RI_LCW_DUP_WIZ';
   	else
           l_sub_task_seq := l_cus_task_start_seq + p_sub_task_seq;
	   per_ri_setup_sub_task_api.UPDATE_SETUP_SUB_TASK
	    	   (
	  	      P_SETUP_SUB_TASK_CODE          =>p_setup_sub_task_code,
	  	      P_SETUP_SUB_TASK_NAME          =>p_setup_sub_task_name,
	              P_SETUP_SUB_TASK_DESCRIPTION   =>p_setup_sub_task_name,
       	              P_SETUP_TASK_CODE              =>p_setup_task_code,
	  	      P_SETUP_SUB_TASK_SEQUENCE      =>l_sub_task_seq,
	  	      P_SETUP_SUB_TASK_STATUS        =>'NOT_STARTED',
	  	      P_SETUP_SUB_TASK_TYPE          =>null,
	  	      P_SETUP_SUB_TASK_DP_LINK       =>null,
	  	      P_SETUP_SUB_TASK_ACTION        =>p_setup_sub_task_action,
	  	      P_SETUP_SUB_TASK_LAST_MOD_DATE =>sysdate,
	  	      P_LEGISLATION_CODE             =>p_legislation_code,
	  	      P_LANGUAGE_CODE                =>'US',
	  	      P_EFFECTIVE_DATE               =>sysdate,
	  	      P_OBJECT_VERSION_NUMBER        =>p_object_version_number

	    );
	    p_msg := 'Success';

	   end if;

  end if;
  CLOSE chk_sub_task_exists;

/*per_ri_workbench_pkg.load_setup_sub_task_row
	   (p_setup_sub_task_code            => p_setup_sub_task_code
           ,p_setup_sub_task_name            => p_setup_sub_task_name
           ,p_setup_sub_task_description     => p_setup_sub_task_name
           ,p_setup_task_code                => 'LCW_' || p_workbench_item_code
  --       ,p_setup_sub_task_sequence        => nvl(l_sub_task_seq,l_max_sub_task_seq)
           ,p_setup_sub_task_sequence        => p_sub_task_seq
           ,p_setup_sub_task_status          => 'NOT_STARTED'
           ,p_setup_sub_task_type            => null
           ,p_setup_sub_task_dp_link         => null
           ,p_setup_sub_task_action          => p_setup_sub_task_action
           ,p_setup_sub_task_creation_date   => sysdate
           ,p_setup_sub_task_last_mod_date   => sysdate
           ,p_legislation_code               => p_legislation_code
           ,p_effective_date                 => sysdate
           );*/

END per_ri_lcw_register;


PROCEDURE per_ri_lcw_delete (
			     p_workbench_item_code            In  Varchar2
			     ,p_setup_task_code            In  Varchar2
	   	            ,p_setup_sub_task_code            In  Varchar2
	   	            ,p_object_version_number 	      In  Number
	   	            )
Is

CURSOR csr_chk_sub_task_exists IS
   SELECT 1
   FROM per_ri_setup_sub_tasks
   WHERE setup_task_code = p_setup_task_code;

CURSOR csr_task_object_version_num IS
   SELECT object_version_number
   FROM per_ri_setup_tasks
   WHERE setup_task_code = p_setup_task_code;


l_dummy varchar2(20);
l_task_object_num Number;

Begin

--Delete the setup sub task with setup task LCW_<p_workbench_item_code>

per_ri_setup_sub_task_api.DELETE_SETUP_SUB_TASK(

						P_SETUP_SUB_TASK_CODE =>p_setup_sub_task_code,
						P_OBJECT_VERSION_NUMBER=>p_object_version_number
						);


 OPEN csr_chk_sub_task_exists;
 FETCH csr_chk_sub_task_exists INTO l_dummy;
 IF (csr_chk_sub_task_exists%NOTFOUND) THEN

 OPEN csr_task_object_version_num;
 FETCH csr_task_object_version_num INTO l_task_object_num;
 CLOSE csr_task_object_version_num;

 per_ri_setup_task_api.DELETE_SETUP_TASK(
 					 P_SETUP_TASK_CODE  =>   p_setup_task_code ,
					 P_OBJECT_VERSION_NUMBER => l_task_object_num
					);

 delete_lcw_oaf_function('S_' || substr(p_setup_task_code , 1 ,28 ));

 END IF;

CLOSE csr_chk_sub_task_exists;


commit;

End per_ri_lcw_delete;

PROCEDURE create_lcw_oaf_function(
           p_function_name  IN  Varchar2
           ,p_user_function_name IN Varchar2
) is
l_rowid              VARCHAR2(200);
l_fun_id             NUMBER;
l_application_id     NUMBER;
l_web_host_name      VARCHAR2(200);
l_web_agent_name     VARCHAR2(200);
l_web_html_call      VARCHAR2(200);
l_web_encrypt_parameters VARCHAR2(200);
l_web_secured        VARCHAR2(200);
l_web_icon           VARCHAR2(200);
l_object_id          NUMBER;
l_region_application_id NUMBER;
l_region_code        VARCHAR2(200);
l_form_id            NUMBER;
l_parameters         VARCHAR2(200);
l_type               VARCHAR2(200);
l_maintenance_mode_support VARCHAR2(200);
l_context_dependence VARCHAR2(200);
l_jrad_ref_patch     VARCHAR2(200);

begin
      l_web_encrypt_parameters := 'N';
      l_web_secured := 'N';
      l_type := 'SUBFUNCTION';


      SELECT  fnd_form_functions_s.nextval
      INTO    l_fun_id
      FROM    dual;

      fnd_form_functions_pkg.INSERT_ROW
       (X_ROWID                    => l_rowid
       ,X_FUNCTION_ID              => l_fun_id
       ,X_WEB_HOST_NAME            => l_web_host_name
       ,X_WEB_AGENT_NAME           => l_web_agent_name
       ,X_WEB_HTML_CALL            => l_web_html_call
       ,X_WEB_ENCRYPT_PARAMETERS   => l_web_encrypt_parameters
       ,X_WEB_SECURED              => l_web_secured
       ,X_WEB_ICON                 => l_web_icon
       ,X_OBJECT_ID                => l_object_id
       ,X_REGION_APPLICATION_ID    => l_region_application_id
       ,X_REGION_CODE              => l_region_code
       ,X_FUNCTION_NAME            => p_function_name
       ,X_APPLICATION_ID           => l_application_id
       ,X_FORM_ID                  => l_form_id
       ,X_PARAMETERS               => l_parameters --can be changed later
       ,X_TYPE                     => l_type
       ,X_USER_FUNCTION_NAME       => p_user_function_name --can be changed later
       ,X_DESCRIPTION              => p_user_function_name --can be changed later
       ,X_CREATION_DATE            => Sysdate
       ,X_CREATED_BY               => 120
       ,X_LAST_UPDATE_DATE         => sysdate
       ,X_LAST_UPDATED_BY          => 120
       ,X_LAST_UPDATE_LOGIN        => 0
       ,X_MAINTENANCE_MODE_SUPPORT => l_maintenance_mode_support
       ,X_CONTEXT_DEPENDENCE       => l_context_dependence
       ,X_JRAD_REF_PATH            => l_jrad_ref_patch);
end create_lcw_oaf_function;

PROCEDURE delete_lcw_oaf_function(
           p_function_name IN Varchar2
) is
l_function_id NUMBER;
l_dummy       NUMBER;
begin
select function_id into l_function_id
from fnd_form_functions where function_name = p_function_name;

   FND_FORM_FUNCTIONS_PKG.DELETE_ROW(
         X_FUNCTION_ID => l_function_id);
EXCEPTION
  WHEN OTHERS THEN
  l_dummy := 0;
end delete_lcw_oaf_function;


END per_ri_lcw_reg_pkg;

/
