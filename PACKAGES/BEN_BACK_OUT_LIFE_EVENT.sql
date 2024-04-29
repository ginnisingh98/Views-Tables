--------------------------------------------------------
--  DDL for Package BEN_BACK_OUT_LIFE_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BACK_OUT_LIFE_EVENT" AUTHID CURRENT_USER as
/* $Header: benbolfe.pkh 120.0.12010000.2 2009/08/17 11:26:20 pvelvano ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Back Out Life Event
Purpose
	This package is used to back out all information that is related to
        a particular life event.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07-JUN-1998      GPERRY     110.0      Created.
        22-Sep-99        pbodla     115.1        per in ler which causes this
                                               per in ler to back out is
                                               (bckt_per_in_ler_id) added.
        04-Oct-99        Gperry     115.2      Added p_bckt_stat_cd to
                                               back_out_life_events procedure.
        07-Oct-99        Gperry     115.3      Fixed defaulting parameter.
        14-Sep-2000      jcarpent   115.4      Bug 1269016.  added bolfe
                                               effective_date global.
        14-Dec-2001      kmahendr   115.5      Bug 2151619 - added g_backout_flag
        12-Feb-2002      shdas      115.7      Created self-service wrapper for
                                               running backout life events.
        29-Oct-2003      tjesumic   115.9      #  2982606 Result level backup added, new parameter
                                               p_bckdt_prtt_enrt_rslt_id added for the purpose.
                                               if the per_in_ler careated the result level backout then
                                               backing out the per inler reinstate the result
       07-feb-2005       tjesumic   115.10     # 4118315 copy_only parameter added to copy the extract
       17-Aug-2009       velvanop   115.11     Bug 8604243: When a lifeevent is being backed out and the previous LE
                                               does not have electability and there are no enrollment results for the
					       previous LE, enrollments results of the LE for which enrollments are ended should
					       be reopened. In this case previous LE status will not be updated to 'STARTED' status and then
					       FORCE close the LE.
*/
--------------------------------------------------------------------------------
--
-- Global variable declaration.
-- This variable is to check the condition that enrollment was made or not.

g_enrt_made_flag              varchar2(10);
g_backout_flag                varchar2(10);
--
-- Some of the future_change deletes cascade delete
-- so need to pass the original p_effective_date
--
g_bolfe_effective_date        date:=null;

/*Bug 8604243: If flag is set to 'Y',while backing out
the LE, previous LE status will not be updated to 'STRTD' status and
force close of the previous LE will not happen*/
g_no_reopen_flag varchar2(1) default 'N';

--
procedure back_out_life_events
  (p_per_in_ler_id           in number,
   p_bckt_per_in_ler_id      in number default null,
   p_bckt_stat_cd            in varchar2 default 'UNPROCD',
   p_business_group_id       in number,
   p_bckdt_prtt_enrt_rslt_id in number default null,
   p_copy_only               in varchar2  default null,
   p_effective_date          in  date);
-----------------------------------------------------------------------
procedure delete_routine(p_routine           in varchar2,
                         p_per_in_ler_id     in number,
                         p_business_group_id in number,
                         p_bckdt_prtt_enrt_rslt_id in number default null,
                         p_copy_only          in varchar2 default null,
                         p_effective_date    in date);
-----------------------------------------------------------------------
procedure back_out_life_events_ss
  (p_per_in_ler_id           in  number,
   p_bckt_per_in_ler_id      in  number default null,
   p_bckt_stat_cd            in  varchar2 default 'UNPROCD',
   p_business_group_id       in  number,
   p_effective_date          in  date);

-----------------------------------------------------------------------
end ben_back_out_life_event;

/
