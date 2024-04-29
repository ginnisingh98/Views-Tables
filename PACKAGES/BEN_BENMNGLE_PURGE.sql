--------------------------------------------------------
--  DDL for Package BEN_BENMNGLE_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENMNGLE_PURGE" AUTHID CURRENT_USER as
/* $Header: benpurge.pkh 115.5 2002/12/28 00:57:30 rpillay ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Purge BENMNGLE related tables.
Purpose
	This package is used to purge BENMNGLE stuff from tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        10-AUG-98        GPERRY     110.0      Created.
        06-JAN-99        GPERRY     115.2      Corrected to use concurrent
                                               request id.
        24-FEB-99        GPERRY     115.3      Fixed dates for canonical.
        26-DEC-02        RPILLAY    115.4      NOCOPY changes
        27-DEC-02        RPILLAY    115.5      Fixed GSCC errors
*/
-----------------------------------------------------------------------
procedure purge_single
          (p_benefit_action_id in number);
-----------------------------------------------------------------------
procedure purge_all
          (errbuf                  out nocopy varchar2,
           retcode                 out nocopy number,
           p_concurrent_request_id in  number default null,
           p_business_group_id     in  number default null,
           p_effective_date        in  varchar2 default null);
-----------------------------------------------------------------------
procedure delete_batch_range_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_reporting_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_person_action_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_benefit_action_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_batch_dpnt_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_batch_elctbl_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_batch_elig_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_batch_proc_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_batch_rate_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
procedure delete_batch_ler_rows
          (p_benefit_action_id in  number,
           p_rows              out nocopy number);
-----------------------------------------------------------------------
end ben_benmngle_purge;

 

/
