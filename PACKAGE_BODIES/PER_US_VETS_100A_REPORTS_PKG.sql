--------------------------------------------------------
--  DDL for Package Body PER_US_VETS_100A_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_VETS_100A_REPORTS_PKG" as
/* $Header: pervetsr100a.pkb 120.0.12010000.2 2009/05/29 09:14:48 pannapur noship $ */
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

  l_request_id number;
  l_set_template boolean;

begin

  -- VETS-100A Veterans Employment Report

   l_set_template :=
          fnd_request.add_layout ('PER',
		     	          'PERRPVTS_100A',
			          'US',
 			          'US',
			          'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPVTS_100A',
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

  if l_request_id = 0 then

    fnd_message.set_name('PER','PER_52992_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;

  end if;

  commit;

  -- VETS-100A Consolidated Veterans Employment Report

   l_set_template :=
          fnd_request.add_layout ('PER',
		     	          'PERRPVTC_100A',
			          'US',
 			          'US',
			          'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERRPVTC_100A',
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

  if l_request_id = 0 then

    fnd_message.set_name('PER','PER_52993_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;

  end if;

  commit;

  -- VETS-100A Employment Listing

  l_set_template :=
          fnd_request.add_layout ('PER',
		     	          'PERUSVEL_100A',
			          'US',
 			          'US',
			          'PDF');

  l_request_id := fnd_request.submit_request
        (application => 'PER',
         program     => 'PERUSVEL_100A',
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

  if l_request_id = 0 then

    fnd_message.set_name('PER','PER_52994_CANNOT_SUBMIT_REPORT');
    fnd_message.raise_error;

  end if;

  commit;

end submit;

end per_us_vets_100a_reports_pkg;

/
