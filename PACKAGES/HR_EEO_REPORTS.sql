--------------------------------------------------------
--  DDL for Package HR_EEO_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EEO_REPORTS" AUTHID CURRENT_USER as
/* $Header: pereeosr.pkh 120.1.12000000.1 2007/01/22 03:04:34 appldev noship $ */
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
       06/12/2002      eumenyio      115.1     Added nocopy, dbdrv and whenever
                                               oserror
       26/08/2003      vbanner       115.4     Changed to reflect new parameters
                                               removed audit start and end dates
                                               added report mode Draft or Final.
                                               Bug 2677421.
       27/06/2005      ynegoro       115.5     Added p_audit_report parameter
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
           p_report_mode                in  varchar2,
           p_no_employees               in  number,
           p_audit_report               in  varchar2);
-----------------------------------------------------------------------
end hr_eeo_reports;

 

/
