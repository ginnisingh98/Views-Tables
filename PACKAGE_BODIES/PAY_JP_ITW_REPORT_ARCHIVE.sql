--------------------------------------------------------
--  DDL for Package Body PAY_JP_ITW_REPORT_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ITW_REPORT_ARCHIVE" AS
/* $Header: pyjpitwreparch.pkb 120.4.12000000.4 2007/05/07 08:51:10 ttagawa noship $ */
--
-- Constants
--
c_package constant varchar2(31) := 'pay_jp_itw_report_archive.';
--
PROCEDURE submit_request
            (errbuf                      OUT NOCOPY VARCHAR2
            ,retcode                     OUT NOCOPY NUMBER
            ,p_run_pre_tax_archive       IN  VARCHAR2
            --
            ,p_effective_date            IN  VARCHAR2
            ,p_business_group_id         IN  VARCHAR2
            ,p_payroll_id                IN  VARCHAR2 DEFAULT NULL
            ,p_itax_organization_id      IN  VARCHAR2 DEFAULT NULL
            ,p_include_terminated_flag   IN  VARCHAR2
            ,p_termination_date_from     IN  VARCHAR2 DEFAULT NULL
            ,p_termination_date_to       IN  VARCHAR2 DEFAULT NULL
            ,p_rearchive_flag            IN  VARCHAR2
            ,p_inherit_archive_flag      IN  VARCHAR2
            ,p_publication_period_status IN  VARCHAR2
            ,p_publication_start_date    IN  VARCHAR2 DEFAULT NULL
            ,p_publication_end_date      IN  VARCHAR2 DEFAULT NULL
            --
            ,p_enable_flag               IN  VARCHAR2 DEFAULT NULL
            ,p_start_date                IN  VARCHAR2 DEFAULT NULL
            ,p_end_date                  IN  VARCHAR2 DEFAULT NULL
            ,p_consolidation_set_id      IN  VARCHAR2 DEFAULT NULL
            )
IS
  c_proc          constant varchar2(61) := c_package || 'submit_request';
  l_request_id    NUMBER;
  l_rphase        VARCHAR2(80);
  l_rstatus       VARCHAR2(80);
  l_dphase        VARCHAR2(30);
  l_dstatus       VARCHAR2(30);
  l_message       VARCHAR2(240);
  l_req_status    BOOLEAN;
  l_count         NUMBER;
  --
  function param
             (p_parameter_name  in varchar2
             ,p_parameter_value in varchar2
             ,p_pipe            in boolean default false
             ,p_condition       in boolean default true) return varchar2
  is
  begin
    if  p_parameter_name is not null
    and p_parameter_value is not null
    and p_condition then
      if p_pipe then
        return p_parameter_name || '=|' || p_parameter_value || '|';
      else
        return p_parameter_name || '=' || p_parameter_value;
      end if;
    end if;
    --
    return null;
  end param;
  --
  function submit_payjpitw_archive return number
  is
  begin
    return fnd_request.submit_request
             ('PAY'
             ,'PAYJPITW_ARCHIVE'
             ,NULL
             ,NULL
             ,TRUE -- Sub Request
             ,'ARCHIVE'
             ,'JPTW'
             ,'JP'
             ,p_effective_date
             ,p_effective_date
             ,'ARCHIVE'
             ,p_business_group_id
             ,null
             ,null
             ,p_payroll_id
             ,param('PAYROLL_ID', p_payroll_id)
             ,p_itax_organization_id
             ,param('ITAX_ORGANIZATION_ID', p_itax_organization_id)
             ,p_include_terminated_flag
             ,param('INCLUDE_TERMINATED_FLAG', p_include_terminated_flag)
             ,p_termination_date_from
             ,param('TERMINATION_DATE_FROM', p_termination_date_from, true, p_include_terminated_flag = 'Y')
             ,p_termination_date_to
             ,param('TERMINATION_DATE_TO', p_termination_date_to, true, p_include_terminated_flag = 'Y')
             ,p_rearchive_flag
             ,param('REARCHIVE_FLAG', p_rearchive_flag)
             ,p_inherit_archive_flag
             ,param('INHERIT_ARCHIVE_FLAG', p_inherit_archive_flag)
             ,p_publication_period_status
             ,param('PUBLICATION_PERIOD_STATUS', p_publication_period_status)
             ,p_publication_start_date
             ,param('PUBLICATION_START_DATE', p_publication_start_date, true)
             ,p_publication_end_date
             ,param('PUBLICATION_END_DATE', p_publication_end_date, true)
             ,chr(0));
  end submit_payjpitw_archive;
begin
  hr_utility.set_location('Entering: ' || c_proc, 10);
  --
  retcode := 0;
  --
  -- Read the value from REQUEST_DATA. If this is the
  -- first run of the program, then this value will be null.
  -- Otherwise, this will be the value that we passed to
  -- SET_REQ_GLOBALS on the previous run.
  --
  l_request_id := fnd_number.number_to_canonical(fnd_conc_global.request_data);
  --
  -- Exit when REQUEST_DATA was set to "-1" in previous procedure call.
  --
  if l_request_id = -1 then
    return;
  end if;
  --
  hr_utility.set_location(c_proc, 20);
  --
  if p_run_pre_tax_archive = 'Y' then
    if l_request_id is NULL THEN
      hr_utility.set_location(c_proc, 30);
      --
      -- Submit PAYJPPRT_ARCHIVE
      --
      l_request_id := fnd_request.submit_request
                        ('PAY'
                        ,'PAYJPPRT_ARCHIVE'
                        ,NULL
                        ,NULL
                        ,TRUE -- Sub Request
                        ,'ARCHIVE'
                        ,'PRT'
                        ,'JP'
                        ,fnd_date.date_to_canonical(fnd_date.displaydate_to_date(p_start_date))
                        ,fnd_date.date_to_canonical(fnd_date.displaydate_to_date(p_end_date))
                        ,'ARCHIVE'
                        ,p_business_group_id
                        ,null
                        ,null
                        ,null
                        ,null
                        ,p_consolidation_set_id
                        ,param('CONSOLIDATION_SET_ID', p_consolidation_set_id)
                        ,chr(0));
      --
      if (l_request_id = 0) then
        errbuf := fnd_message.get;
        retcode := 2;
        return;
      else
        hr_utility.trace('Child request PAYJPPRT_ARCHIVE submitted, request_id: ' || l_request_id);
        --
        -- Set PAYJPPRT_ARCHIVE request_id as request data.
        --
        fnd_conc_global.set_req_globals
          (conc_status       => 'PAUSED'
          ,request_data      => fnd_number.number_to_canonical(l_request_id));
      end if;
    else
      hr_utility.set_location(c_proc, 40);
      hr_utility.trace('PAYJPPRT_ARCHIVE request_id: ' || l_request_id);
      --
      l_req_status := FND_CONCURRENT.GET_REQUEST_STATUS
                        (request_id  => l_request_id
                        ,phase       => l_rphase
                        ,status      => l_rstatus
                        ,dev_phase   => l_dphase
                        ,dev_status  => l_dstatus
                        ,message     => l_message
                        );
      --
      if (l_req_status = FALSE) then
        errbuf := fnd_message.get;
        retcode := 2;
        return;
      end if;
      --
      hr_utility.trace('Developer Phase  = ' || l_dphase);
      hr_utility.trace('Developer Status = ' || l_dstatus);
      --
      if (l_dphase = 'COMPLETE' and l_dstatus = 'NORMAL') then
        hr_utility.set_location(c_proc, 50);
        --
        select COUNT(1)
        into   l_count
        from   pay_payroll_actions    ppa,
               pay_assignment_actions paa
        where  ppa.request_id = l_request_id
        and    ppa.action_type = 'X'
        and    paa.payroll_action_id = ppa.payroll_action_id
        and    paa.action_status <> 'C';
        --
        if (l_count = 0) then
          hr_utility.set_location(c_proc, 60);
          --
          l_request_id := submit_payjpitw_archive;
          --
          if (l_request_id = 0) then
            errbuf := fnd_message.get;
            retcode := 2;
            return;
          else
            hr_utility.trace('Child request PAYJPITW_ARCHIVE submitted: ' || l_request_id);
            --
            fnd_conc_global.set_req_globals
              (conc_status       => 'PAUSED'
              ,request_data      => fnd_number.number_to_canonical(-1)
              );
          end if;
        else
          fnd_message.set_name('PAY', 'PAY_JP_ITW_ARCH_NOT_SUBMITTED');
          errbuf := fnd_message.get;
          retcode := 1;
          return;
        end if;
      else
        fnd_message.set_name('PAY', 'PAY_JP_ITW_ARCH_NOT_SUBMITTED2');
        errbuf := fnd_message.get;
        retcode := 1;
        return;
      end if;
    end if;
  else
    hr_utility.set_location(c_proc, 70);
    --
    l_request_id := submit_payjpitw_archive;
    --
    if (l_request_id = 0) then
      errbuf := fnd_message.get;
      retcode := 2;
      return;
    else
      hr_utility.trace('Child request PAYJPITW_ARCHIVE submitted: ' || l_request_id);
      --
      fnd_conc_global.set_req_globals
         (conc_status       => 'PAUSED'
         ,request_data      => fnd_number.number_to_canonical(-1)
         );
    end if;
  end if;
  --
  hr_utility.set_location('Leaving: ' || c_proc, 80);
end submit_request;
--
END PAY_JP_ITW_REPORT_ARCHIVE;

/
