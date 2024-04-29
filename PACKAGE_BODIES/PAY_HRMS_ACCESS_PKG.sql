--------------------------------------------------------
--  DDL for Package Body PAY_HRMS_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HRMS_ACCESS_PKG" AS
/* $Header: pyhraces.pkb 120.0 2005/05/29 05:40 appldev noship $ */

PROCEDURE Disable_Enable_HRMS (
        ERRBUF     out nocopy      VARCHAR2
       ,RETCODE    out nocopy      VARCHAR2
) as

--
-- cursor to check the status of 'STATUS' and 'ACTION' fields in
-- hr_legialation_installations

cursor csr_legislation_status is
    Select
          LEGISLATION_CODE       -- which is set by datainstall utility.
      from HR_LEGISLATION_INSTALLATIONS
        where STATUS is null and ACTION is not null
           or STATUS = 'I' and ACTION is not null;

--
-- cursor to check whether the fnd_install_processes table is created or not.
-- The table FND_INSTALL_PROCESSES is created when the adpatch utility starts
-- running the .drv file. So checking for its existence.

cursor csr_fnd_install_processes(p_fnd_schema in varchar2) is
    Select
          OBJECT_NAME
       from ALL_OBJECTS
         where OBJECT_NAME = 'FND_INSTALL_PROCESSES'
           and OBJECT_TYPE ='TABLE'
           and OWNER = p_fnd_schema;

cursor csr_get_sleep_time is
    select
	PARAMETER_VALUE
    from PAY_ACTION_PARAMETERS
    where PARAMETER_NAME = 'HRLEGDEL_SLEEP';
--

l_object_name all_objects.object_name%type;
l_flag_fnd_install_processes boolean;

l_flag_stop_process boolean; -- flag to represent the 'STATUS' and 'ACTION field
                             -- status

l_flag_install_process boolean; -- flag to represent the running state of
                                -- hrglobal.drv from 'R' state in
                                -- fnd_install_processes.

l_stmt_fnd_install_data varchar2(200);
l_cnt_fnd_install_data number;
l_legislation hr_legislation_installations.legislation_code%type;

l_sleep_time PAY_ACTION_PARAMETERS.PARAMETER_VALUE%type;

l_flag_offline boolean;
l_flag_online boolean;

--

NO_SUCH_TABLE EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_SUCH_TABLE, -942);

INVALID_SYNONYM_INVALID EXCEPTION;
PRAGMA EXCEPTION_INIT (INVALID_SYNONYM_INVALID, -980);

l_result boolean;
l_prod_status    varchar2(1);
l_industry       varchar2(1);
l_fnd_schema     varchar2(30);
--

begin

    ERRBUF := null;
    RETCODE := null;

    -- initializing the flag = true as taking into consideration that
    -- this will be called from SQL script only within the hrglobal.drv.
    -- So by then the FND_INSTALL_PROCESSES will be created and also
    -- the 'STATUS' and 'ACTION' flag will be set.
    l_flag_stop_process := true;
    l_flag_install_process := true;
    l_flag_offline := true;
    l_flag_online := false;
    l_sleep_time := null;
    l_stmt_fnd_install_data := 'select count(worker_id) from fnd_install_processes where status =''F''';

--
    -- get fnd schema name
    l_result := fnd_installation.get_app_info ('FND', l_prod_status, l_industry, l_fnd_schema );
--
    -- opening the csr_fnd_install_processes cursor to check whether the
    -- hrglobal.drv has started or not.
    open csr_fnd_install_processes(l_fnd_schema);
    fetch csr_fnd_install_processes into l_object_name;
    if( csr_fnd_install_processes%found) then
        l_flag_fnd_install_processes := true;
    else
        l_flag_fnd_install_processes := false;
    end if;
    close csr_fnd_install_processes;
--
    open csr_get_sleep_time;
    fetch csr_get_sleep_time into l_sleep_time;
    if( csr_get_sleep_time%notfound) then
        l_sleep_time := '10';
    end if;
    close csr_get_sleep_time;
--
    while (l_flag_stop_process and l_flag_fnd_install_processes) loop

--
        -- opening the cursor that check the status of 'STATUS' and 'ACTION'
        -- fields in hr_legialation_installations.
        open csr_legislation_status;
        fetch csr_legislation_status into l_legislation;
        if (csr_legislation_status%found) then
            l_flag_stop_process := true;
        else
            l_flag_stop_process := false;
        end if;
        close csr_legislation_status;
--
        open csr_fnd_install_processes(l_fnd_schema);
        fetch csr_fnd_install_processes into l_object_name;
        if (csr_fnd_install_processes%found) then
            -- checking the status of worker threads.
--
            EXECUTE IMMEDIATE l_stmt_fnd_install_data into l_cnt_fnd_install_data;
--
            if (l_cnt_fnd_install_data = 0) then
                l_flag_install_process := true;
            else
                l_flag_install_process := false;
            end if;
        else
            l_flag_install_process := false;
        end if;
        close csr_fnd_install_processes;
--
        if l_flag_stop_process and l_flag_install_process then
	    if NOT l_flag_offline then
               FND_FORM_FUNCTIONS_PKG.SET_FUNCTION_MODE('PER_%', 'OFFLINE');
               FND_FORM_FUNCTIONS_PKG.SET_FUNCTION_MODE('PAY_%', 'OFFLINE');
	       l_flag_offline := true;
	       l_flag_online := false;
	    end if;
        else
	    if NOT l_flag_online then
                FND_FORM_FUNCTIONS_PKG.SET_FUNCTION_MODE('PER_%', 'NONE');
                FND_FORM_FUNCTIONS_PKG.SET_FUNCTION_MODE('PAY_%', 'NONE');
		l_flag_online := true;
		l_flag_offline := false;
	    end if;
        end if;
--
        -- opening the fnd_install_processes cursor to check whether the
        -- hrglobal.drv has started or not.
        open csr_fnd_install_processes(l_fnd_schema);
        fetch csr_fnd_install_processes into l_object_name;
        if( csr_fnd_install_processes%found) then
            l_flag_fnd_install_processes := true;
        else
            l_flag_fnd_install_processes := false;
        end if;
        close csr_fnd_install_processes;
--
        commit;
	DBMS_LOCK.SLEEP(l_sleep_time);
    end loop; -- end of while loop.

--

    EXCEPTION
            WHEN NO_SUCH_TABLE OR INVALID_SYNONYM_INVALID THEN
                FND_FORM_FUNCTIONS_PKG.SET_FUNCTION_MODE('PER_%', 'NONE');
                FND_FORM_FUNCTIONS_PKG.SET_FUNCTION_MODE('PAY_%', 'NONE');
                commit;
            WHEN OTHERS THEN
                ERRBUF := sqlerrm;
                RETCODE := sqlcode;
--
end Disable_Enable_HRMS;

END PAY_HRMS_ACCESS_PKG;


/
