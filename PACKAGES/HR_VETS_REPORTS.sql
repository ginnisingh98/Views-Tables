--------------------------------------------------------
--  DDL for Package HR_VETS_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VETS_REPORTS" AUTHID CURRENT_USER as
/* $Header: pervetsr.pkh 120.1.12000000.1 2007/01/22 03:59:55 appldev noship $ */
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
       06/05/2001      vshukhat      115.0     Created
       06/12/2002      eumenyio      115.2     Added nocopy, dbdrv ans
		                               whenever oserror
       06/28/2005      ynegoro       115.3     Added p_audit_report
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
           p_audit_report               in  varchar2
          );
-----------------------------------------------------------------------
end hr_vets_reports;

 

/
