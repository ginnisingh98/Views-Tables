--------------------------------------------------------
--  DDL for Package BEN_EXT_THREAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_THREAD" AUTHID CURRENT_USER as
/* $Header: benxthrd.pkh 120.4.12010000.2 2008/08/05 15:01:13 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
        Benefit Extract Thread
Purpose
        This package is used to multithread benefit extract process
History
        Date             Who        Version    What?
        10/15/98         Pdas       115.0      Created.
        11/06/98         Yrathman   115.1      Added globals for header/trailer
        11/16/98         Pdas       115.2      Added more globals
        11/23/98         Pdas       115.3      Added more globals
        01/22/99         Pdas       115.4      Changed concurrent program date parameters
                                               to varchar2.
        09 Mar 99        G Perry    115.5      IS to AS.
        08 Apr 99        I Sen      115.6      Added use_eff_dt_for_chgs_flag
        12 May 99        T Hayden   115.7      Major Fixes.
        30 May 00        G Perry    115.8      Tuning Fixes.
        29 Nov 00        R Chase    115.9      Bug 1521958.Added global to hold
                                               extract definition id to be used
                                               by formula calls.
        29 Nov 01        dschwart/  115.10     Bug#1931774: added declration of
                         bburns                process_ext_ht_recs to make public
        20 jan 02        tjesumic   115.11     restart process added , rslt_id added in process
        11 mar 02        tjesumic   115.12     UTF changes added
        05 may 02        tjesumic   115.13     p_ext_crit_prfl_id ,p_rquest_id added as paramter
                                               to process_ext_ht_recs
        27 dec 02        lakrish    115.17     NOCOPY changes
        19-Jan-03        tjesumic   115.18     New procedire load_extract added to import and export the
                                               extract definition
        26-May-04       mmudigon   115.19      Bug 3672376. Parameters changed
                                               for Restart procedure
        22-Mar-05       tjesumic   115.20      CWB (CW) , and subheader coded changes
                                               new extract type for 'CW' and new header and trialer procedure
                                               for subheader and new  criteria for both added
        30-Mar-05       tjesumic   115.21      new param p_subhdr_chg_log added for nfc extract to get postion
                                               suheader from  history table for GHR
        31-MAr-05       tjesumic   115.22      GHR changes
        15-Apr-05       tjesumic   115.23      Global/Cross bg changes added
        08-Jun-05       tjesumic   115.24/25   pennserver enhancement for new parameter, outpput type
                                               effective, actual date and pauroll change events
        28-APR-06       hgattu     115.26      new parameter p_out_dummy is added tp process procedure(5131931)
        12-Feb-06       tjesumic   115.27      allow overide param added for uploading file
                                               required file benextse.lct 115.40 , benextse,pkh/pkb 115.24/73
		30-Apr-08       vkodedal   115.28      Changes required for penserver - performance fix--6895935,6801389,6995291


*/
--
g_package     varchar2(80) := 'ben_ext_thread';
--
Type g_num_list is table of number
   Index by binary_integer;
--
type l_number_type is varray(200) of number;
--
g_processes_rec     g_num_list;
--
g_max_errors_allowed    number;
-- RChase Create a global for extract definition id to be used by formula calls
g_ext_dfn_id            ben_ext_dfn.ext_dfn_id%type;
g_ext_rslt_id           ben_ext_rslt.ext_rslt_id%type;
--
g_ext_group_elmt1       ben_ext_fld.short_name%type ;
g_ext_group_elmt2       ben_ext_fld.short_name%type ;

--
g_num_processes     number := 0;
--
g_err_name          varchar2(250);
--
g_err_num           number := 0;
--
g_job_failure_error exception;
--
g_ht_error          exception;
--
g_ext_strt_dt       date;
--
g_ext_end_dt        date;
--
g_effective_start_date date ;
g_effective_end_date date ;
g_actual_start_date date ;
g_actual_end_date date ;
--
g_err_cnt           number := 0;
--
g_per_cnt           number := 0;
--
g_rec_cnt           number := 0;
--
g_dtl_cnt           number := 0;
--
g_hdr_cnt           number := 0;
--
g_trl_cnt           number := 0;
--
g_subhdr_cnt        number := 0;
--
g_subtrl_cnt        number := 0;

g_subhdr_chg_log    varchar2(15)  ;


g_chg_ext_from_ben       varchar2(1) ;
g_chg_ext_from_pay       varchar2(1) ;


procedure do_multithread
  (errbuf                  out nocopy    varchar2
  ,retcode                 out nocopy    number
  ,p_benefit_action_id     in     number
  ,p_ext_dfn_id            in     number
  ,p_thread_id             in     number
  ,p_effective_date        in     varchar2
  ,p_business_group_id     In     number
  ,p_data_typ_cd           in     varchar2
  ,p_ext_typ_cd            in     varchar2
  ,p_ext_crit_prfl_id      in     number
  ,p_ext_rslt_id           in     number
  ,p_ext_file_id           in     number
  ,p_ext_strt_dt           in     varchar2
  ,p_ext_end_dt            in     varchar2
  ,p_prmy_sort_cd          in     varchar2
  ,p_scnd_sort_cd          in     varchar2
  ,p_output_name           in     varchar2
  ,p_apnd_rqst_id_flag     in     varchar2
  ,p_request_id            in     number
  ,p_use_eff_dt_for_chgs_flag in  varchar2
  ,p_master_process_flag   in 	  varchar2
  ,p_eff_start_date        in     varchar2
  ,p_eff_end_date          in     varchar2
  ,p_act_start_date        in     varchar2
  ,p_act_end_date          in     varchar2
  ,p_penserv_mode          in 	  varchar2 DEFAULT 'N'        -- 6995291 vkodedal
);
--
/* Start of Changes for WWBUG: 1931774		*/
/*   Added declaration for previously private procedure */

Procedure process_ext_ht_recs(p_ext_rslt_id         in number,
                              p_ext_file_id         in number,
                              p_ext_typ_cd          in varchar2,
                              p_rcd_typ_cd          in varchar2,
                              p_business_group_id   in number,
                              p_effective_date      in date,
                              p_group_val_01        in varchar2  default null,
                              p_group_val_02        in varchar2  default null,
                              p_request_id          in number default null,
                              p_ext_crit_prfl_id    in number default null,
                              p_ext_per_bg_id       in number default null
                             );

/* End of Changes for WWBUG: 1931774		*/
--
/* PLEASE NOTICE:  be sure that if you add any parameters to
   do_multithread, you also must update benxmgr3.sql */
--
procedure process
  (errbuf                    out nocopy    varchar2
  ,retcode                   out nocopy    varchar2
  ,p_benefit_action_id       in     number
  ,p_ext_dfn_id              in     number
  ,p_effective_date          in     varchar2
  ,p_business_group_id       in     number
  --
  ,p_output_type             in  varchar2 default null
  ,p_out_dummy               in  varchar2  default null
  ,p_xdo_template_id         in  number default null
  ,p_eff_start_date          in  varchar2   default null
  ,p_eff_end_date            in  varchar2   default null
  ,p_act_start_date          in  varchar2   default null
  ,p_act_end_date            in  varchar2   default null
  --
  ,p_ext_rslt_id             in  number default null
  ,p_subhdr_chg_log          in  varchar2  default null
  ,p_penserv_date            in  date   default null        -- 6895935, 6801389 vkodedal
  ,p_penserv_mode            in VARCHAR2 DEFAULT 'N'        -- 6995291 vkodedal
);
--
/* PLEASE NOTICE:  be sure that if you add any parameters to
   process, you also must update benxmgr2.sql */
--
--Old proc. Not used
--
/*procedure restart(errbuf                  out nocopy    varchar2
                 ,retcode                   out nocopy    varchar2
                 ,p_benefit_action_id       in     number
                 ,p_ext_rslt_id             in     number default null );
*/

--
--new proc
--
procedure restart(errbuf                    out nocopy    varchar2
                 ,retcode                   out nocopy    varchar2
                 ,p_ext_dfn_id              in  number
                 ,p_concurrent_request_id   in  number    );

Procedure load_extract(
          errbuf                     out nocopy varchar2
         ,retcode                    out nocopy number
         ,p_mode                     in varchar2
         ,p_seeded                   in varchar2 default 'N'
         ,p_loader_file              in varchar2 default null
         ,p_file_name                in varchar2
         ,p_view_name                in varchar2 default null
         ,p_extract_file_id          in number   default null
         ,p_business_group_id        in number
         ,p_validate                 in  varchar2 default 'N'
         ,p_allow_override           in  varchar2 default 'N'
       )  ;

End ben_ext_thread;

/
