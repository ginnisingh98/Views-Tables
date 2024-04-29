--------------------------------------------------------
--  DDL for Package Body PAY_JP_IWHT_REPORT_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_IWHT_REPORT_ARCH_PKG" AS
-- $Header: pyjpiwra.pkb 120.1.12010000.2 2010/03/05 07:33:31 rdarasi noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- *  PAYJLWL.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of PAY_JP_IWHT_REPORT_PKG
-- *
-- * USAGE
-- *   To install       sqlplus <apps_user>/<apps_pwd> @PAYJPIWHTREPORTARCHPKG .pkh
-- *   To Execute       sqlplus <apps_user>/<apps_pwd> EXEC PAY_JP_IWHT_REPORT_ARCH_PKG.<procedure name>
-- *
-- * PROGRAM LIST
-- * ==========
-- * NAME                 DESCRIPTION
-- * -----------------    --------------------------------------------------
-- * SUBMIT_REQUEST
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   10-Feb-2010
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * VERSION            DATE        AUTHOR(S)             DESCRIPTION
-- * -------           ----------- -----------------     -----------------------------
-- * 120.0.12010000.1  09-Aug-2009  MPOTHALA               Creation
-- *************************************************************************
c_package constant varchar2(31) := 'pay_jp_iwht_report_arch_pkg.';
--
PROCEDURE submit_request
             (errbuf                      OUT NOCOPY VARCHAR2
             ,retcode                     OUT NOCOPY NUMBER
             ,p_run_pre_tax_archive       IN  VARCHAR2
              --
             ,p_effective_date            IN  VARCHAR2
             ,p_business_group_id         IN  VARCHAR2
             ,p_rearchive_flag            IN  VARCHAR2 DEFAULT NULL
             ,p_itax_organization_id      IN  VARCHAR2 DEFAULT NULL
             ,p_payroll_id                IN  VARCHAR2 DEFAULT NULL
             ,p_termination_date_from     IN  VARCHAR2 DEFAULT NULL
             ,p_termination_date_to       IN  VARCHAR2 DEFAULT NULL
             ,p_assignment_set_id         IN  VARCHAR2 DEFAULT NULL
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
             ,'PAYJPIWHT_ARCHIVE'
             ,NULL
             ,NULL
             ,TRUE -- Sub Request
             ,'ARCHIVE'
             ,'JP_IWHT_ARCH'
             ,'JP'
             ,p_effective_date
             ,p_effective_date
             ,'ARCHIVE'
             ,p_business_group_id
             ,null
             ,null
             ,null
             ,null
             ,p_rearchive_flag
             ,param('REARCHIVE_FLAG',p_rearchive_flag)
             ,p_itax_organization_id
             ,param('ITAX_ORGANIZATION_ID', p_itax_organization_id)
             ,p_payroll_id
             ,param('PAYROLL_ID', p_payroll_id)
             ,p_termination_date_from
             ,param('TERMINATION_DATE_FROM', p_termination_date_from)
             ,p_termination_date_to
             ,param('TERMINATION_DATE_TO', p_termination_date_to)
             ,p_assignment_set_id
             ,param('ASSIGNMENT_SET_ID',p_assignment_set_id)
             ,chr(0));
  end submit_payjpitw_archive;
begin
  --
  hr_utility.set_location('Entering '||c_proc,1);
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
      hr_utility.trace('Child request PAYJPIWHT_ARCHIVE submitted: ' || l_request_id);
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
END PAY_JP_IWHT_REPORT_ARCH_PKG;

/
