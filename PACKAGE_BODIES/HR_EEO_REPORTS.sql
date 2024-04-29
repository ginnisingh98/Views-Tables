--------------------------------------------------------
--  DDL for Package Body HR_EEO_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EEO_REPORTS" as
/* $Header: pereeosr.pkb 120.2.12000000.1 2007/01/22 03:04:31 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Batch Reporting
Purpose
	This package is used to perform reporting for batch processes.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
     06/05/2001       vshukhat      115.0      Created
     06/10/2001       vshukhat      115.1      Added exception report
     06/25/2001       vshukhat      115.2      Removed audit dates from
                                               Exception Report.
     06/12/2002       eumenyio      115.3      Added nocopy, dbdrv and whenever
                                               oserror
     26/08/2003       vbanner       115.4      Changed to reflect new parameters
                                               removed audit start and end dates
                                               added report mode Draft or Final.
                                               Bug 2677421.
     27/06/2005       ynegoro       115.5      Added p_audit_report parameter
                                               BUG4461644
     05/19/2006       ssouresr      115.6      Added templates
*/
-----------------------------------------------------------------------
procedure submit
          (errbuf                       out nocopy varchar2,
           retcode                      out nocopy number,
           p_business_group_id          in  number,
           p_hierarchy_id               in  number,
           p_hierarchy_version_id       in  number,
           p_date_start                 in  varchar2,
           p_date_end                   in  varchar2,
           p_report_mode               in  varchar2,
           p_no_employees               in  number,
           p_audit_report               in varchar2) is
  --
  l_request_id number;
  l_set_template boolean;
  --
begin
  --
  -- Fire off all the eeo reports
  --
  -- EEO-1 Individual Establishment Report
  --
  l_set_template :=
          fnd_request.add_layout ('PER',
                                  'PERRPEO1',
                                  'US',
                                  'US',
                                  'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPEO1',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_date_start,
         argument3   => p_date_end,
         argument4   => p_hierarchy_id,
         argument5   => p_hierarchy_version_id,
         argument6   => p_report_mode,
         argument7   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52995_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
  --
  -- EEO-1 Consolidated Report
  --
  l_set_template :=
          fnd_request.add_layout ('PER',
                                  'PERRPEOC',
                                  'US',
                                  'US',
                                  'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPEOC',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_date_start,
         argument3   => p_date_end,
         argument4   => p_hierarchy_id,
         argument5   => p_hierarchy_version_id,
         argument6   => p_report_mode,
         argument7   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52996_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
  --
  -- EEO-1 Employment Listing
  --
  l_set_template :=
          fnd_request.add_layout ('PER',
                                  'PERRPE1L',
                                  'US',
                                  'US',
                                  'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPE1L',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_date_start,
         argument3   => p_date_end,
         argument4   => p_hierarchy_id,
         argument5   => p_hierarchy_version_id,
         argument6   => p_no_employees,
         argument7   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52997_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
  --
  -- EEO-1 Exception Report
  --
  l_set_template :=
          fnd_request.add_layout ('PER',
                                  'PERUSEOX',
                                  'US',
                                  'US',
                                  'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERUSEOX',
         description => 'EEO-1 Exception Report',
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_date_start,
         argument3   => p_date_end,
         argument4   => p_hierarchy_id,
         argument5   => p_hierarchy_version_id,
         argument6   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52998_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
end submit;
-----------------------------------------------------------------------
end hr_eeo_reports;

/
