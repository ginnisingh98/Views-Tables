--------------------------------------------------------
--  DDL for Package Body ZPB_DVAC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DVAC_WF" AS
/* $Header: ZPBVDVCB.pls 120.4 2007/12/04 14:38:43 mbhat noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ZPB_DVAC_WF';

procedure set_dvac_task (errbuf out nocopy varchar2,
            		retcode out nocopy varchar2,
            		BP_ID  in number,
            		instanceId in number,
                        p_business_area_id in number,
                        p_task_id in number)
   IS

   x_return_status varchar2(100);
   x_msg_count number;
   x_msg_data varchar2(4000);
   x_validation_level number := FND_API.G_VALID_LEVEL_FULL;
   cursor exempt_users is
     select a.user_id, a.exemption_id
      from zpb_measure_scope_exempt_users a
      where business_process_entity_type = 'A'
       -- bug 4587184
       -- and business_process_entity_id = BP_ID
       and business_process_entity_id = instanceId
       and task_id = p_task_id;
  l_instance_ac_id number; -- added for bug 5842494

BEGIN

	ZPB_LOG.WRITE_EVENT_TR ('ZPB_DVAC_WF.SET_DVAC_TASK', 'begin...');

        -- bug 5842494
        ZPB_AC_OPS.Get_VM_instance_id(
                            p_api_version     => 1,
                            p_init_msg_list   => FND_API.G_FALSE,
                            x_return_status   => x_return_status,
                            x_msg_count       => x_msg_count,
                            x_msg_data        => x_msg_data,
                            p_ac_id_in        => instanceId,
                            x_vm_instance_id  => l_instance_ac_id);

        --remove current instanceId row
        -- bug 5842494: replaced with l_instance_ac_id
        delete from ZPB_MEASURE_SCOPE
          where INSTANCE_AC_ID = l_instance_ac_Id;

	--copy the BP definition entry as the new instance definition
	insert into ZPB_MEASURE_SCOPE
          (INSTANCE_AC_ID,
           RESTRICTION_TYPE,
           START_TIME_TYPE,
           START_TIME_MEMBER_ID,
           START_RELATIVE_TYPE_CODE,
           START_PERIODS,
           START_TIME_LEVEL_ID,
           END_TIME_TYPE,
           END_TIME_MEMBER_ID,
           END_RELATIVE_TYPE_CODE,
           END_PERIODS,
           END_TIME_LEVEL_ID,
           TIME_HIERARCHY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN)
         select
           -- bug 4587184: replace with BP_ID since where statement has changed
           -- ANALYSIS_CYCLE_ID,
           BP_ID,
           RESTRICTION_TYPE,
           START_TIME_TYPE,
           START_TIME_MEMBER_ID,
           START_RELATIVE_TYPE_CODE,
           START_PERIODS,
           START_TIME_LEVEL_ID,
           END_TIME_TYPE,
           END_TIME_MEMBER_ID,
           END_RELATIVE_TYPE_CODE,
           END_PERIODS,
           END_TIME_LEVEL_ID,
           TIME_HIERARCHY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
         from ZPB_BUSINESS_PROCESS_SCOPE
           -- bug 4587184: Replace BP_ID with instanceId
           -- where ANALYSIS_CYCLE_ID = BP_ID
           where ANALYSIS_CYCLE_ID = instanceId
           and   TASK_ID = p_task_id;

        -- bug 5842494: replaced with l_instance_ac_id
        update ZPB_MEASURE_SCOPE
          set INSTANCE_AC_ID = l_instance_ac_id,
              CREATED_BY = fnd_global.USER_ID,
              CREATION_DATE = SYSDATE,
              LAST_UPDATED_BY = fnd_global.USER_ID,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN = fnd_global.USER_ID
          where INSTANCE_AC_ID = BP_ID;

        -- delete current list of exempt users for instanceId
        -- bug 5842494: replaced with l_instance_ac_id
        delete from ZPB_MEASURE_SCOPE_EXEMPT_USERS
          where BUSINESS_PROCESS_ENTITY_ID = l_instance_ac_id
          and BUSINESS_PROCESS_ENTITY_TYPE = 'I';

	--copy entries for exempt user specification
        -- bug 5842494: replaced with l_instance_ac_id
        for each in exempt_users loop
           insert into zpb_measure_scope_exempt_users
              (user_id, exemption_id, business_process_entity_id,
                business_process_entity_type, created_by, creation_date,
                last_updated_by, last_update_date, last_update_login)
           values(each.user_id, each.exemption_id, l_instance_ac_id, 'I',
                fnd_global.USER_ID, SYSDATE, fnd_global.USER_ID,
                SYSDATE, fnd_global.LOGIN_ID);

        end loop;

        ZPB_AW.INITIALIZE_FOR_AC(1.0, FND_API.G_FALSE, x_validation_level, x_return_status, x_msg_count, x_msg_data, BP_ID, FND_API.G_TRUE, FND_API.G_FALSE);
	ZPB_AW.EXECUTE('call DVAC.SET.CONTROL(''' || l_instance_ac_id || ''')');
	ZPB_AW.EXECUTE('UPDATE');

        ZPB_AW.CLEAN_WORKSPACE(1.0, FND_API.G_FALSE, x_validation_level, x_return_status, x_msg_count, x_msg_data);
	-- Successfully completed run of exception request
 	ZPB_LOG.WRITE_EVENT_TR ('ZPB_DVAC_WF.SET_DVAC_TASK', 'end');
   	retcode :='0';
   	return;

  exception

  when others then
   FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_WF_ERREXCPRUN');
   FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
   retcode :='2';
   errbuf:=substr(sqlerrm, 1, 255);

end SET_DVAC_TASK;

end ZPB_DVAC_WF;

/
