--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_RATE_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_RATE_CHG" AUTHID CURRENT_USER as
/* $Header: benrtchg.pkh 120.0.12000000.1 2007/01/19 18:55:46 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                       |
+==============================================================================+
Name:
    Determine rate/benefit changes.
Purpose:
    This process determines what rate or benefit amount have changed and updates
    prtt_enrt_rslt
History:
     Date             Who        Version    What?
     ----             ---        -------    -----
     25 Oct 98        T Guy       115.0      Created.
     22 Jan 99        T Guy       115.1      Added p_lf_evt_cord_dt parm
     09 Mar 99        G Perry     115.2      IS to AS.
     30 Dec 99        maagrawa    115.3      Added parameter business_group_id.
     05 Jan 01        kmahendr    115.4      Added parameter per_in_ler_id
     26 Jun 01        ikasire     115.5      bug 1849019 added two new procedures
                                             prv_delete and get_rate_codes to
                                             handle ENTRBL rate start date codes.
     17 Aug 01        kmahendr    115.6      Added parameter p_mode to prv_delete
     25 Sep 01        kmahendr    115.7      Added parameter p_mode to main
     20 Mar 02        kmahendr    115.8      Added dbdrv lines.
    11-dec-2002       hmani       115.9		NoCopy changes
     22 Apr 03        kmahendr    115.10     New function Determine_change_in_flex added - bug#2908231
*/
--------------------------------------------------------------------------------
--
--
PROCEDURE main
     (p_effective_date         in date,
      p_lf_evt_ocrd_dt         in date,
      p_business_group_id      in number,
      p_person_id              in number,
      p_per_in_ler_id          in number,
      p_mode                   in varchar2 default null);
--
-- ben_determine_rate_chg.prv_delete
procedure prv_delete
     (p_prtt_rt_val_id    in number ,
      p_enrt_rt_id        in number,
      p_rt_val            in number,
      p_rt_strt_dt        in date,
      p_business_group_id in number,
      p_prtt_enrt_rslt_id in number,
      p_person_id         in number,
      p_effective_date    in date,
      p_mode              in varchar2 default 'NEW'
);
--
-- This is a wrapper to get rt_end_dt_cd and rt_srt_dt_cd from forms.
--
procedure get_rate_codes
          (p_business_group_id      in number
          ,p_elig_per_elctbl_chc_id in number
          ,p_rt_strt_dt_cd          out nocopy varchar2
          ,p_rt_end_dt_cd           out nocopy varchar2
          ,p_acty_base_rt_id        in number
          ,p_effective_date         in date);
--
function Determine_change_in_flex
         (p_prtt_enrt_rslt_id number,
          p_per_in_ler_id     number,
          p_effective_date    date)
          return boolean;
--
end ben_determine_rate_chg;


 

/
