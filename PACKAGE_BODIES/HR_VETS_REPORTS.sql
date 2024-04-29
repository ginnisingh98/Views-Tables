--------------------------------------------------------
--  DDL for Package Body HR_VETS_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_VETS_REPORTS" as
/* $Header: pervetsr.pkb 120.3.12000000.1 2007/01/22 03:59:51 appldev noship $ */
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
     06/12/2002       eumenyio      115.2      Added nocopy, dbdrv and
                                               whenever oserror
     06/28/2005       ynegoro       115.3      Added p_audit_report
     07/25/2005       ynegoro       115.4      Added p_audit_report to PERUSVEL
     05/19/2006       ssouresr      115.5      Added template
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
           p_state                      in  varchar2,
           p_show_new_hires             in  varchar2,
           p_show_totals                in  varchar2,
           p_audit_report               in  varchar2) is
  --
  l_request_id number;
  l_set_template boolean;
  --
begin
  --
  -- Fire off all the vets reports
  --
  -- VETS-100 Veterans Employment Report
  --
   l_set_template :=
          fnd_request.add_layout ('PER',
		     	          'PERRPVTS',
			          'US',
 			          'US',
			          'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPVTS',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_date_start,
         argument3   => p_date_end,
         argument4   => p_hierarchy_id,
         argument5   => p_hierarchy_version_id,
         argument6   => p_show_totals,
         argument7   => p_show_new_hires,
         argument8   => p_state,
         argument9   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52992_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
  --
  -- VETS-100 Consolidated Veterans Employment Report
  --
   l_set_template :=
          fnd_request.add_layout ('PER',
		     	          'PERRPVTC',
			          'US',
 			          'US',
			          'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPVTC',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_date_start,
         argument3   => p_date_end,
         argument4   => p_hierarchy_id,
         argument5   => p_hierarchy_version_id,
         argument6   => p_state,
         argument7   => p_show_totals,
         argument8   => p_show_new_hires,
         argument9   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52993_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
  --
  -- VETS-100 Employment Listing
  --
  l_set_template :=
          fnd_request.add_layout ('PER',
		     	          'PERUSVEL',
			          'US',
 			          'US',
			          'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERUSVEL',
         description => NULL,
         sub_request => FALSE,
         argument1   => p_business_group_id,
         argument2   => p_hierarchy_id,
         argument3   => p_hierarchy_version_id,
         argument4   => p_date_start,
         argument5   => p_date_end,
         argument6   => p_state,
         argument7   => p_show_totals,
         argument8   => p_show_new_hires,
         argument9   => p_audit_report);
  --
  if l_request_id = 0 then
    --
    fnd_message.set_name('PER','PER_52994_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;
    --
  end if;
  --
  commit;
  --
end submit;
-----------------------------------------------------------------------
end hr_vets_reports;

/
