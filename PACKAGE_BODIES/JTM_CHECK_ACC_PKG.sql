--------------------------------------------------------
--  DDL for Package Body JTM_CHECK_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_CHECK_ACC_PKG" as
/* $Header: jtmchkab.pls 120.1 2005/08/24 02:07:53 saradhak noship $ */

FUNCTION check_profile_acc
(p_errtable  IN OUT NOCOPY errTab) RETURN BOOLEAN
IS
l_query_string VARCHAR2(2000);

acctable_list accTab;
errtable_list errTab;

l_status BOOLEAN := TRUE;
l_counter NUMBER;
j NUMBER := 0;


ll_log_id NUMBER;
ll_status VARCHAR2(1);
ll_message VARCHAR2(2000);

BEGIN

acctable_list(1) := 'JTM_FND_PROF_OPTIONS_ACC';
acctable_list(2) := 'JTM_FND_PROF_OPTIONS_VAL_ACC';

for i IN 1 .. acctable_list.count loop

l_query_string := 'SELECT COUNT(*) FROM ' || acctable_list(i) ;

JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => l_query_string
        ,v_start_time => sysdate
        ,v_end_time => NULL
        ,v_status => 'START'
        ,v_message => 'IN PROCESS OF ' || acctable_list(i)
        ,x_log_id => ll_log_id
        ,x_status => ll_status
        ,x_msg_data => ll_message);

EXECUTE IMMEDIATE l_query_string into  l_counter;

JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => l_query_string
        ,v_start_time => NULL
        ,v_end_time => sysdate
        ,v_status => 'COMPLETE'
        ,v_message => 'FINISHED ' || acctable_list(i)
        ,x_log_id => ll_log_id
        ,x_status => ll_status
        ,x_msg_data => ll_message);


if (l_counter = 0 ) then
l_status := FALSE;
errtable_list(j) := acctable_list(i);
j := j+1;
end if;

END LOOP;

p_errtable := errtable_list;

return l_status;

EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
 JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => l_query_string
        ,v_start_time => sysdate
        ,v_end_time => NULL
        ,v_status => 'FAILED'
        ,v_message => sqlerrm
        ,x_log_id => ll_log_id
        ,x_status => ll_status
        ,x_msg_data => ll_message);
 RAISE FND_API.G_EXC_ERROR;

END check_profile_acc;

FUNCTION check_jtf_acc(p_errtable  IN OUT NOCOPY errTab) RETURN BOOLEAN
AS
l_query_string VARCHAR2(2000);

acctable_list accTab;
errtable_list errTab;

l_status BOOLEAN := TRUE;
l_counter NUMBER;
j NUMBER := 0;


ll_log_id NUMBER;
ll_status VARCHAR2(1);
ll_message VARCHAR2(2000);

BEGIN

acctable_list(1) := 'JTM_JTF_TASK_PRIORITIES_ACC';
acctable_list(2) := 'JTM_JTF_TASK_STATUSES_ACC';
acctable_list(3) := 'JTM_JTF_TASK_TYPES_ACC';

for i IN 1 .. acctable_list.count loop

l_query_string := 'SELECT COUNT(*) FROM ' || acctable_list(i) ;

JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => l_query_string
        ,v_start_time => sysdate
        ,v_end_time => NULL
        ,v_status => 'START'
        ,v_message => 'IN PROCESS OF ' || acctable_list(i)
        ,x_log_id => ll_log_id
        ,x_status => ll_status
        ,x_msg_data => ll_message);

EXECUTE IMMEDIATE l_query_string into  l_counter;

JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => l_query_string
        ,v_start_time => NULL
        ,v_end_time => sysdate
        ,v_status => 'COMPLETE'
        ,v_message => 'FINISHED ' || acctable_list(i)
        ,x_log_id => ll_log_id
        ,x_status => ll_status
        ,x_msg_data => ll_message);

if (l_counter = 0 ) then
l_status := FALSE;
errtable_list(j) := acctable_list(i);
j := j+1;
end if;

END LOOP;

p_errtable := errtable_list;

return l_status;

EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
 JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => NULL
        ,v_query_stmt => l_query_string
        ,v_start_time => sysdate
        ,v_end_time => NULL
        ,v_status => 'FAILED'
        ,v_message => sqlerrm
        ,x_log_id => ll_log_id
        ,x_status => ll_status
        ,x_msg_data => ll_message);
 RAISE FND_API.G_EXC_ERROR;

END check_jtf_acc;

end JTM_Check_Acc_PKG;

/
