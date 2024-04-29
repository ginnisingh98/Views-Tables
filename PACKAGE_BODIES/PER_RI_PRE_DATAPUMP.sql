--------------------------------------------------------
--  DDL for Package Body PER_RI_PRE_DATAPUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_PRE_DATAPUMP" as
/* $Header: perripmp.pkb 120.1 2006/05/03 09:42:10 nkkrishn noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Enrollment Process
Purpose
        This is a wrapper procedure for Data pump functionality from workbench.
History
	Date		Who		Version	What?
	----		---		-------	-----
	16 Jan 06	ikasire 	115.0		Created
        23 Mar 06       ikasire         115.1           Added Process beneficiaries
        02 May 06       nkkrishn        115.11          Fixed Beneficiary upload
*/
--
--Globals
--
g_debug boolean := hr_utility.debug_enabled;
--
--
procedure check_slaves_status
  (p_request_id        in number
  ,p_slave_errored    out nocopy boolean
  )
is
  --
  l_package        varchar2(80) := 'per_ri_pre_datapump.check_slaves_status';
  --
  l_no_slaves      boolean;
  l_poll_loops     pls_integer;
  l_slave_errored  boolean := false ;
  --
  cursor c_slaves
    (c_request_id number
    )
  is
    select phase_code,
           status_code
    from   fnd_concurrent_requests fnd
    where  fnd.request_id = c_request_id;
  --
  l_slaves c_slaves%rowtype;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  --
  l_no_slaves := true;
  --
  while l_no_slaves loop
    --
    l_no_slaves := false;
    --
    --
    open c_slaves
        (p_request_id);
      fetch c_slaves into l_slaves;
      if l_slaves.phase_code <> 'C'
      then
        --
        l_no_slaves := true;
        --
      end if;
      --
      if l_slaves.status_code = 'E' then
        --
        l_slave_errored := true;
        --
      end if;
      --
    close c_slaves;
    --
    -- Loop to avoid over polling of fnd_concurrent_requests
    --
    l_poll_loops := 100000;
    --
    for i in 1..l_poll_loops
    loop
      --
      null;
      --
    end loop;
    --
  end loop;
  --
  p_slave_errored := l_slave_errored ;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
  commit;
  --
end check_slaves_status;
--
--
procedure pre_datapump_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) is
    l_retcode number;
    l_errbuf  varchar2(1000);
    l_package        varchar2(80) := 'per_ri_pre_datapump.pre_datapump_process';
    --
    cursor c_api is
     select distinct module_name
       from hr_pump_batch_lines lines,
            hr_api_modules api
      where lines.batch_id = p_batch_id
        and lines.api_module_id = api.api_module_id ;
    --
    l_api        c_api%ROWTYPE;
    l_request_id NUMBER ;
    l_slave_errored  boolean := false ;
    --
  begin
    --Find out the HRDPP information from batch_id
    --Now call the appropriate procedure.
    --once the call is completed, successfully, submit DATAPUMP request
    --
    hr_utility.set_location ('Entering '||l_package,10);
    savepoint pre_datapump_process;
    --
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Before Pre Process call ');
    --
    FOR l_rec in c_api LOOP
      --
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'module_name :'||l_rec.module_name );
      --
      IF l_rec.module_name = 'CREATE_ENROLLMENT' THEN
        --
        ben_pre_datapump_process.pre_create_enrollment(
          p_batch_id => p_batch_id
         ,p_validate => p_validate
        );
        --
      ELSIF l_rec.module_name = 'PROCESS_DEPENDENT' THEN
        --
        ben_pre_datapump_process.pre_process_dependent(
          p_batch_id => p_batch_id
         ,p_validate => p_validate
         );
        --
      ELSIF l_rec.module_name = 'PROCESS_BENEFICIARY' THEN
        --
        ben_pre_datapump_process.pre_process_beneficiary(
          p_batch_id => p_batch_id
         ,p_validate => p_validate
         );
        --
      END IF;
      --
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'After Call - module_name :'||l_rec.module_name );
      --
    END LOOP;
    --
    -- Now lets call Data pump Process
    --
    hr_utility.set_location ('Before Submit Request '||l_package,20);
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Before Datapump Call');
    --
    l_request_id := fnd_request.submit_request
                       (application => 'PER'
                       ,program     => 'DATAPUMP'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_batch_id
                       ,argument2   => p_validate );
    --
    hr_utility.set_location ('After Submit Request '||l_package,30);
    --
    commit;
    --
    fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'After Datapump Call');
    --
    check_slaves_status(p_request_id      => l_request_id
                       ,p_slave_errored   => l_slave_errored);
    --
    if l_slave_errored then
      --
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Datapump Request '||l_request_id||' completed with error.');
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Check the request log for error details.');
      --
    else
      --
      fnd_file.put_line
           (which => fnd_file.log,
            buff  => 'Datapump Request '||l_request_id||' completed successfully.');
      --
    end if;
    --
    hr_utility.set_location ('Leaving '||l_package,40);
    --
  exception when others then
    raise ;
  end pre_datapump_process ;
--
end per_ri_pre_datapump;

/
