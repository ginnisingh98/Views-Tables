--------------------------------------------------------
--  DDL for Package Body BEN_EXT_THREAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_THREAD" as
/* $Header: benxthrd.pkb 120.40.12010000.9 2009/03/30 12:00:46 vkodedal ship $ */

/*
+==============================================================================+
|   Copyright (c) 1997 Oracle Corporation                                      |
|      Redwood Shores, California, USA                                         |
|           All rights reserved.                                               |
+==============================================================================+

Name
        Benefit Extract Thread
Purpose
        This package is used to multithread benefit extract process
History
        Date             Who        Version    What?
        10/15/98         Pdas       115.0      Created.
        10/30/98         Yrathman   115.1      Added messages
        11/04/98         Pdas       115.2      Modified call to
                                               benutils.get_parameter
        11/06/98         Yrathman   115.3      Added header/trailer
        11/06/98         PDas       115.4      Added Person Count, Record Count
        11/23/98         PDas       115.5      Added logic for smart totals
        12/09/98         PDas       115.6      Modified call to process_ext_ht_recs
        12/09/98         Thayden    115.7      Added logic for directroy name.
        12/30/98         PDas       115.8      Added BENXSMRY report.
        01/22/99         Pdas       115.9      Changed concurrent program date parameters
                                               to varchar2.
        02/10/99         Pdas       115.10     Modified process_ext_ht_recs procedure
        02/17/99         Pdas       115.11     Modified process_ext_ht_recs procedure error handling
        02/24/99         Pdas       115.12     Modified procedure process
        02/26/99         Pdas       115.13     Modified procedure process
        03/02/99         Pdas       115.14     Modified procedure process
        03/09/99         Tmathers   115.15     changed != to <>.
        03/09/99         Gperry     115.16     is to AS
        03/09/99         Tmathers   115.18     Made dates MLS.
        03/10/99         Tmathers   115.19     Missed one
        03/22/99         Tmathers   115.20     Changed -MON- to /MM/
        04/07/99         Thayden    115.22     Leapfrog version 115.4 for patch.
        04/07/99         Thayden    115.23     Communication Fixes
        04/13/99         Isen       115.24     Added upd_cm_sent_dt_flag to the
                                               cursor ext_dfn_c
        05/07/99         Asen       115.26     Solved the date conversion problem and moved the function
            Calc_ext_date to benxutil.pkb, change the call accordingly.
        05/13/99         Thayden    115.27     Major Fixes.
        05/17/99         Isen       115.28     Corrected dates for header/triler
                                               Bug - 2106
        06/03/99         Asen       115.29     Added two parameters to action api call.
        06/16/99         Isen       115.30     Added foreign key ref ext_rslt_id
        07/09/99         Jcarpent   115.31     Added checks for backed out nocopy pil
        20/07/99         Gperry     115.32     genutils -> benutils package
                                               rename.
        06/08/99         Asen       115.33     Added messages : Entering, Exiting.
        08/31/99         Asen       115.34     Changed call to decode program (from ben_ext_decodes).
        09/22/99         Thayden    115.36     Changes to cm and chg cursors (new incl crit).
        09/27/99         Thayden    115.37     Added defaults for filename and directory.
        10/01/99         Thayden    115.38     Changed call to calc_smart_totals.
        10/04/99         Thayden    115.39     Added call for post processing rule.
        10/06/99         Thayden    115.40     Fix bugs related with 115.39 changes.
                                               Fix sql navigator erroring.
        10/07/99         Thayden    115.41     load fnd_sessions table call.
        10/11/99         Thayden    115.42     Comment calls to calc_ext_date.
        11/03/99         Thayden    115.43     Move decode logic back to ben_ext_fmt.
        01/10/2000       Thayden    115.44     Fix post process rule call.
        02/06/2000       Thayden    115.45     Added performance enhancements.
        02/23/2000       Thayden    115.46     Fixed performance enhancements.
        03/01/2000       RChase     115.47     Fixed dynamic cursors in build_select_statements.
                                               to use explict date conversion.  This clears up
                                               issues with clients using NLS date formats other
                                               than DD-MON-YYYY.
                                               Updated process procedure to output a wrapped dynamic
                                               sql statement to the log file for better debugging
                                               purposes.
        03/14/2000       Thayden    115.48     Advanced Conditions for headers and trailers.
        05/31/2000       gperry     115.49     Tuning.
        06/20/2000       jcarpent   115.50     Fix for Tuning fix,
                                               uninitialized collection.
                                               bug 5339.
        08/10/2000       tilak      115.51     Dynamic sql date format changed from YYYY to RRRR to
                                               support all the other lang
        08/17/2000       tilak      115.52
        08/17/2000       tilak      115.53     bug 1381514 fixed before calling calc_ext_date the type of code is calidat                                               ed
        08/17/2000       tilak      115.54     Backport of 115.48 for 11.5.2
                                               patchset with NLS fixes from
                                               115.51.  wwbug 1391217.
        08/30/2000       stee       115.55     Leapfrog of 115.53.
        09/03/2000       stee       115.56     Leapfrog of 115.51.
        09/03/2000       stee       115.57     Leapfrog of 115.55.
        12/06/2000       rchase     115.58     Leapfrog of 115.56 with fixes
                                               for 1521958.  Added rule contexts.
        12/07/2000       jcarpent   115.59     Merged version of 115.57 and 115.58.
        01/23/2001       rchase     115.60     Bug 1608852. Correct thread issue.
                                               Lock being released before status
                                               updating batch range status.
        01/30/2001       tilak      115.61     error message changed ,get from get_error_messages
                                               with element name
        06/06/2001       tilak      115.62     caling formula is added for header/trailer - 1786750
        06/21/2001       tilak      115.63     gv$_system_parameter used instead of v$system_paramter
        07/27/2001       tilak      115.65     Change Event Dynomic sql is cahnged,
                                               chg_eff_Dt is replaced  p_effective date
        11/07/2001       mhoyes     115.66   - bug 2100912. Moved call to ben_extract.set_ext_lvls
                                               from chunk level to thread level. Globals were
                                               being over refreshed.
        11/09/2001       mhoyes     115.67   - bug 2100912. Moved call to ben_extract.setup_rcd_typ_lvl
                                               from chunk level to thread level. Globals were
                                               being over refreshed.
        11/26/2001       mhoyes     115.68   - dbdrv lines.

        01/20/2002      tjesumic    115.69   - restart process added
        02/12/2002 hnarayan    115.70     added procedure update_ht_strt_end_dt to update
             data which correspond to fields STRTDT and ENDDT
             in header and trailer records of result detail.
        03/11/2002      tjesumic    115.71   -  UTF changes
        03/12/2002      ikasire     115.72      BEN UTF8 Changes
        05/06/2002      tjesumic    115.73      p_ext_crit_prfl_id ,p_rquest_id added as
                                                paramter to process_ext_ht_recs
        05/16/2002      tjesumic    115.74      dynamic sql chnaged the assg date validate changed from nvl to (+)                                                bug : 2376285
        05/21/2002      tjesumic    115.75      PLPLCY element added for header level
        05/24/2002      tjesumic    115.76     change event dynomic sql fixed
        08-Jun-02       pabodla    115.78      Do not select the contingent worker
                                               assignment when assignment data is
                                               fetched.
        17-Jun-02       pabodla    115.79      Fetching assignment data even if assignment_type is null
        15-Aug-02       tjesumic   115.79      Max_lenght added for String Element
        28-Aug-02       tjesumic   115.80      if the string Element is null and max_lenght defined
                                               string element will be considered as space
        17-dec-02       tjesumic   115.81      115.78,115.79 reversed
        27-Dec-02       lakrish    115.84      NOCOPY changes
        13-Feb-03       rpillay    115.85      HRMS Debug Performance changes to
                                                hr_utility.set_location calls
        23-Aug-03       tjesumic   115.86      calcualted records added for  detail record
        02-Oct-03       tjesumic   115.87      Upper/lower/initcap applied for string format mask
        29-Oct-03       tjesumic   115.88      total for detail records are considers only non hiden records
                                               hiden recors are filterd
        30-dec-03       mmudigon   115.89      Bug 3232205. Modified cursors on
                                               ben_person_actions to drive by
                                               benefit_action_id
        19-Jan-03       tjesumic   115.91      New procedire load_extract added to import and export the
                                               extract definition
        19-Jan-03       tjesumic   115.92      extract sedded or not decided by the extract not the parameter
        19-Jan-03       tjesumic   115.92      view name cahnged to ben_pl_v
        26-Jan-03       tjesumic   115.94      validate_mode parameterized for fndload concurren mgr
        26-Jan-03       tjesumic   115.95      Extract header formula format mask is fixed
        10-Feb-03       tjesumic   115.96      Person Type usage added in dynamic sql  - ppt
        21-Apr-04       tjesumic   115.97      when the header/trailed element is null and mandatory
                                               then throw the warning , if the record is mandatory then
                                               throw the error and rollback the header and trailer
        26-May-04       mmudigon   115.98      Bug 367237. Parameters changed
                                               for Restart procedure
        04-Jun-04       mmudigon   115.99      GSCC file.sql.6 fix
        06-Jul-04       tjesumic   115.100     for security check_asg_security added and per_people_f view used
        06-Jul-04       tjesumic   115.104     brought forward the version 100 above the leaf frog
        02-Aug-04       nhunur     115.105     ensure request_id is not passed as null to benefit actions api.
        06-Aug-04       nhunur     115.106     3810114 - Added code to prevent over polling of fnd_conc_requests.
        13-aug-04       tjesumic   115.107     chg_actl_ct is truncated to validated the dates
        18-Nov-04       rpinjala   115.108     New procedure chk_pqp_extract added
        19-Nov-04       rpinjala   115.109     Changed chk_pqp_extract procedure.
        05-Dec-04       rpinjala   115.110     Changed chk_pqp_extract procedure.
        15-Dec-04       tjesumic   115.111     ext_rcd_in_file_id added to ben_Ext_rslt_dtl table
        01-Feb-05       tjesumic   115.112     300 elements allowed in  a record
        08-Mar-05       tjesumic   115.113     check_asg_security changed for performance
        09-Mar-05       tjesumic   115.114     check_asg_security changed for performance
        22-Mar-05       tjesumic   115.115     CWB (CW) , subheader codes changes
                                               new extract type for 'CW' and new header and trialer procedure
                                               for subheader and new  criteria for both added
       24-Mar-05        tjesumic   115.116     position extracted from  position base table
       30-Mar-05        tjesumic   115.117    new param p_subhdr_chg_log added for nfc extract to get postion
                                               suheader from  history table
       30-Mar-05        tjesumic   115.118    nfc changes
       31-Mar-05        tjesumic   115.119    GHR changes
       15-Mar-05        tjesumic   115.120    Global/Cross bg changes added
       27-Apr-05        rpinjala   115.121    Changed chk_pqp_extract procedure.
       28-Apr-05        tjesumic   115.122    to_date change to canonical_to_date for formula result date conversion
       30-Apr-05        tjesumic   115.123    string element added for  rule element
       12-May-05        tjesumic   115.124    g_ext_dfn_id and g_ext_rslt_id intialised in subheader for subhdr formula
       17-May-05        tjesumic   115.125    p_ghr_date parameter changed to p_eff_start/end_dte
       08-Jun-05        tjesumic   115.125    pennserver enhancement for new parameter, outpput type
                                              effective, actual date and pauroll change events
       08-Jun-05        tjesumic   115.127    pennserver enhancement
       13-Jun-05        tjesumic   115.128    payroll dynamic sql changed
       13-Jun-05        tjesumic   115.129    ghr sql cahnged for pos02
       25-Jul-05        tjesumic   115.130    Dynamic sql build changed fro performance  and bug 4440823
       22-Aug-05        tjesumic   115.131    business group id variable initalization in security check is changed
       22-Aug-05        rbingi     115.132    Bug 4545881 - Global flag retrieved from Ext_Crit_Prfl
       21-Sep-05        tjesumic   115.133    grade inforamtion extracted in  subheader
       13-Sep-05        tjesumic   115.134    when the extract excuted with only subheader, the process should not
                                              go throuh person information
       9-nov-05         nhunur     115.135    xcl > per for performance - bug 4721453
       6-Dec-05         tjesumic   115.136    cm_display_flag is  added and validated
       9-Dec-05         tjesumic   115.137    benxmlwrit called for cm_display on
      10-Dec-05         tjesumic   115.138    output_code to set the output type for display
      20-Dec-05         tjesumic   115.139    cm_downlaod added for download and GHR fix as per 4609093
      20-Dec-05         tjesumic   115.141    c_xdoi cursor closed
      22-Dec-05         tjesumic   115.142    XSL changed to EXCEL
      11-Jan-06         tjesumic   115.143    restart changed to send correct parameters to process
      02-Feb-06         tjesumic   115.144    restart changed to process the errorerd ranges from advance condition
      12-Feb-06         tjesumic   115.145    Assignment set added in extract criteria's person level
      15-Mar-06         tjesumic   115.146    Penserver Sql changes
      23-Mar-06         tjesumic   115.147    Penserver Sql changes
      27-Mar-06         tjesumic   115.148    debug  function call removed
      29-Mar-06         tjesumic   115.149    end dte and start parsed  in update_ht_strt_end_dt
      28-APR-06         hgattu     115.150    new param p_out_dummy is added to process procedure(5131931)
      07-Aug-06         tjesumic   115.151    parameter p_out_dummy passed in wrong position
      06-Oct-06         tjesumic   115.152    The Advance Date criteria added to Dynamic sql
                                              Pay change event sql splited into two, 1 for non Asg event
                                              another one for Asg Events. New procedure
                                              chck_non_asg_pay_evt and build_adv_criteria added.
     20-oct-06          tjesumic   115.153    The dynamic query changed to calc the criteria value and validated
                                              as in clause without using extract table. per_all_people removed
                                              from pay change event query
     23-Oct-06          tjesumic   115.154    nocopy added
     31-Oct-06          tjesumic   115.155    payroll id added to the dynamic query
     07-Dec-06          tjesumic   115.156    subheader's org, job and grade from and to date are validated
     12-Feb-07          tjesumic   115.157    allow overide param added for uploading file
                                              required file benextse.lct 115.40 , benextse,pkh/pkb 115.24/73
     13-Feb-07          tjesumic   115.158    Legislation ang global check in pay_event_updates table is removed
                                              The primary key is passed from process event table.
     07-mar-07          tjesumic   115.159    Dynamic sql error is fixed
     20-mar-07          tjesumic   115.162    115.160 and 161 reverted
     04-Sep-07          tjesumic   115.163    total count and detail count elements are fixed by adding ext_rcd_in_file_id in validation
     26-Nov-07          tjesumic   115.164    when the extract is global, for 'PPT' person type usage the criteria are validated from table
                                              big - 6642051
     30-Apr-08          vkodedal   115.165    Changes required for penserver - performance fix--6895935,6801389,6995291
     11-Aug-08          vkodedal   115.167    Penserver perf issue-7274509
     25-Aug-08          vkodedal   115.168    Penserver perf issue-7341530
     12-Sep-08          jvaradra   115.170    Penserver perf issue-7358558
     30-Mar-09          vkodedal   115.172,173    Bug#8335771 -Restart process not spawning threads - get l_num_range as count
*/

--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_debug boolean := hr_utility.debug_enabled;
--
g_val_def ben_ext_fmt.valtabtyp :=
           ben_ext_fmt.valtabtyp(null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null,
                                 null,null,null,null,null,null,null,null,null,null
                                 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< write_error >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure write_error(p_err_num             in number,
                      p_err_name            in varchar2,
                      p_typ_cd              in varchar2,
                      p_person_id           in number,
                      p_request_id          in number,
                      p_ext_rslt_id         in number,
                      p_business_group_id   in number
                      ) IS
--
  l_proc               varchar2(72);
--
begin
--
  if g_debug then
    l_proc := g_package || '.write_error';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
  if p_business_group_id is not null then
--
    ben_ext_util.write_err
         (p_err_num           => p_err_num,
          p_err_name          => p_err_name,
          p_typ_cd            => p_typ_cd,
          p_person_id         => p_person_id,
          p_request_id        => p_request_id,
          p_ext_rslt_id        => p_ext_rslt_id,
          p_business_group_id => p_business_group_id
         );
--
    commit;
--
  end if;
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
end write_error;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_ext_prmtrs >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_ext_prmtrs(p_ext_dfn_id               in  number,
                         p_business_group_id        in  number,
                         p_data_typ_cd              in out nocopy varchar2,
                         p_ext_typ_cd               in out nocopy varchar2,
                         p_ext_crit_prfl_id         in out nocopy number,
                         p_ext_file_id              in out nocopy number,
                         p_ext_strt_dt              in out nocopy varchar2,
                         p_ext_end_dt               in out nocopy varchar2,
                         p_prmy_sort_cd             in out nocopy varchar2,
                         p_scnd_sort_cd             in out nocopy varchar2,
                         p_output_name              in out nocopy varchar2,
                         p_drctry_name              in out nocopy varchar2,
                         p_apnd_rqst_id_flag        in out nocopy varchar2,
                         p_kickoff_wrt_prc_flag     in out nocopy varchar2,
                         p_use_eff_dt_for_chgs_flag in out nocopy varchar2,
                         p_ext_post_prcs_rl         in out nocopy number,
                         p_ext_global_flag          in out nocopy varchar2,
                         p_cm_display_flag          in out nocopy varchar2,
                         p_output_type              in out nocopy varchar2,
                         p_xdo_template_id          in out nocopy number
                       ) IS
--
  l_proc               varchar2(72);
--
  cursor ext_dfn_c is
  SELECT data_typ_cd
       , ext_typ_cd
       , strt_dt
       , end_dt
       , ext_crit_prfl_id
       , ext_file_id
       , prmy_sort_cd
       , scnd_sort_cd
       , output_name
       , drctry_name
       , apnd_rqst_id_flag
       , kickoff_wrt_prc_flag
       , use_eff_dt_for_chgs_flag
       , upd_cm_sent_dt_flag
       , ext_post_prcs_rl
       , ext_global_flag
       , output_type
       , xdo_template_id
       , cm_display_flag
  FROM  ben_ext_dfn
  WHERE ext_dfn_id = p_ext_dfn_id;
--

  -- subhead
  cursor c_ext_file (p_file_id number) is
  select ext_data_elmt_in_rcd_id1,
         ext_data_elmt_in_rcd_id2
  from  ben_Ext_file exf
  where exf.ext_file_id = p_file_id ;


  cursor  c_ext_elmt (p_data_elmt_in_rcd_id  number
                      ) is
  select  exf.short_name
  from ben_ext_fld  exf,
       ben_Ext_data_elmt_in_rcd edr,
       ben_ext_data_elmt        ede
  where edr.ext_data_elmt_in_rcd_id = p_data_elmt_in_rcd_id
    and edr.ext_data_elmt_id     = ede.ext_Data_elmt_id
    and ede.ext_fld_id           = exf.ext_fld_id (+)
    ;

  l_ext_rcd c_ext_file%rowtype ;


  cursor c_ext_global  is
  select ext_global_flag
  from ben_ext_crit_prfl
  where ext_crit_prfl_id = p_ext_crit_prfl_id
  ;

begin
--
  if g_debug then
    l_proc := g_package||'.get_ext_prmtrs';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
  open ext_dfn_c;
  fetch ext_dfn_c into p_data_typ_cd,
                       p_ext_typ_cd,
                       p_ext_strt_dt,
                       p_ext_end_dt,
                       p_ext_crit_prfl_id,
                       p_ext_file_id,
                       p_prmy_sort_cd,
                       p_scnd_sort_cd,
                       p_output_name,
                       p_drctry_name,
                       p_apnd_rqst_id_flag,
                       p_kickoff_wrt_prc_flag,
                       p_use_eff_dt_for_chgs_flag,
                       ben_ext_person.g_upd_cm_sent_dt_flag,
                       p_ext_post_prcs_rl,
                       p_ext_global_flag,
                       p_output_type ,
                       p_xdo_template_id,
                       p_cm_display_flag
                       ;
--
  if ext_dfn_c%notfound then
    ben_ext_thread.g_err_num := 91873;
    ben_ext_thread.g_err_name := 'BEN_91873_EXT_NOT_FOUND';
    close ext_dfn_c;
    raise g_job_failure_error;
  end if;
--
  close ext_dfn_c;
--

-- confirm the global flag from criteria too
--  for CWB the criterai may not global but definition is global

 /*if p_ext_global_flag <> 'Y'  and  p_Ext_crit_prfl_id is not null  then
      open c_ext_global ;
      fetch c_ext_global into p_ext_global_flag ;
      close c_ext_global ;
   end if ; */ -- Bug 4545881 by rbingi
  --
  -- For CWB type is always global
  -- for other types same as the Criteria profile
  if p_data_typ_cd = 'CW' then
    --
    p_ext_global_flag := 'Y' ;
    --
  else
    --
    open c_ext_global ;
    fetch c_ext_global into p_ext_global_flag ;
    close c_ext_global ;
    --
  end if;

  --subhead
  open c_ext_file(p_ext_file_id) ;
  fetch c_ext_file into l_ext_rcd ;
  close c_ext_file ;

  if l_ext_rcd.ext_data_elmt_in_rcd_id1 is not null then
     open  c_ext_elmt(l_ext_rcd.ext_data_elmt_in_rcd_id1) ;
     fetch c_ext_elmt into g_ext_group_elmt1 ;
     close c_ext_elmt ;

     if l_ext_rcd.ext_data_elmt_in_rcd_id2 is not null then
        open  c_ext_elmt(l_ext_rcd.ext_data_elmt_in_rcd_id2) ;
        fetch c_ext_elmt into g_ext_group_elmt2 ;
        close c_ext_elmt ;
     end if ;
  end if ;
  -- eof subheader

  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
Exception
--
  when g_job_failure_error then
    raise g_job_failure_error;
--
End get_ext_prmtrs;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ht_strt_end_dt >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_ht_strt_end_dt (p_ext_rslt_id  number)
IS
--
  l_proc          varchar2(72);
--
  l_cursor_id     integer;
  l_cnt_rows_upd  number;
  l_tot_string    varchar2(5000) := null;
  l_col_name      varchar2(5000) := null;
  l_value        varchar2(5000) := null;
  l_curr_string   varchar2(600)  := null;  --UTF8
  l_run_strt_dt   date := null;
  l_run_end_dt    date := null;
  l_temp_dt       date := null;
--
  cursor c_ext_rslt is
   SELECT rslt.run_strt_dt , rslt.run_end_dt
   FROM    ben_ext_rslt rslt
   WHERE   rslt.ext_rslt_id = p_ext_rslt_id;
--
  cursor c_ext_rcd is
   SELECT distinct rdtl.ext_rcd_id ext_rcd_id
   FROM ben_ext_rcd rcd, ben_ext_rslt_dtl rdtl
   WHERE  rdtl.ext_rslt_id = p_ext_rslt_id
     and  rdtl.ext_rcd_id = rcd.ext_rcd_id
     and rcd.rcd_type_cd in ('H','T');
--
  cursor c_data_elmt_seq_num(p_ext_rcd_id number) is
   SELECT elrc.seq_num, fld.short_name, elmt.frmt_mask_cd
   FROM ben_ext_data_elmt_in_rcd elrc, ben_ext_data_elmt elmt, ben_ext_fld fld
   WHERE elrc.ext_rcd_id = p_ext_rcd_id
     and elrc.ext_data_elmt_id = elmt.ext_data_elmt_id
     and elmt.ext_fld_id = fld.ext_fld_id
     and ltrim(rtrim(fld.short_name)) in ('STRTDT','ENDDT');

BEGIN
  --
  if g_debug then
    l_proc := g_package||'.update_ht_strt_end_dt';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
  --
  --
  l_cursor_id := DBMS_SQL.OPEN_CURSOR;
  --
  open c_ext_rslt;
  fetch c_ext_rslt into l_run_strt_dt, l_run_end_dt ;
  close c_ext_rslt;
  --
  for rcd_rec in c_ext_rcd loop
    --
    l_tot_string := null;
    for elmt_rec in c_data_elmt_seq_num(rcd_rec.ext_rcd_id) loop
      --
      if (elmt_rec.short_name = 'STRTDT') then
        l_temp_dt := l_run_strt_dt;
      elsif (elmt_rec.short_name = 'ENDDT') then
        l_temp_dt := l_run_end_dt;
      else
        l_temp_dt := null;
      end if;
      --

      l_col_name    := ' VAL_' || ltrim(to_char(elmt_rec.seq_num,'09'))  ;
      if (elmt_rec.frmt_mask_cd is null) then
        --l_curr_string := ' VAL_' || ltrim(to_char(elmt_rec.seq_num,'09')) || ' = ''' || to_char(l_temp_dt) || ''' ' ;
        l_value       :=  to_char(l_temp_dt)  ;
      else
        --l_curr_string := ' VAL_' || ltrim(to_char(elmt_rec.seq_num,'09')) || ' = ''' ||
        -- to_char(l_temp_dt,hr_general.decode_lookup('BEN_EXT_FRMT_MASK',elmt_rec.frmt_mask_cd)) || ''' ' ;
        l_col_name    := ' VAL_' || ltrim(to_char(elmt_rec.seq_num,'09'))  ;
        l_value       :=  to_char(l_temp_dt,hr_general.decode_lookup('BEN_EXT_FRMT_MASK',elmt_rec.frmt_mask_cd)) ;
      end if;
      --
      /*
      if l_tot_string is null then
        l_tot_string := ' SET ' || l_curr_string ;
      else
        l_tot_string := l_tot_string || ' , ' || l_curr_string ;
      end if;
      --
    end loop;
    --

    if l_tot_string is not null then
      */
      --
      /*
      l_tot_string := 'UPDATE BEN_EXT_RSLT_DTL ' || l_tot_string
         || ' WHERE ext_rslt_id = ' || to_char(p_ext_rslt_id)
         || ' AND   ext_rcd_id  = ' || to_char(rcd_rec.ext_rcd_id);

      */

      l_tot_string := 'UPDATE BEN_EXT_RSLT_DTL SET  ' ||  l_col_name  ||  '   = :VAL  where ext_rslt_id = :RSLT_ID and ext_rcd_id  = :RCD_ID' ;

      DBMS_SQL.PARSE(l_cursor_id, l_tot_string, dbms_sql.v7);


      --DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':COL' , l_col_name  );
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':VAL' , l_value  );
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':RSLT_ID' , p_ext_rslt_id  );
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':RCD_ID' , rcd_rec.ext_rcd_id  );


      l_cnt_rows_upd := DBMS_SQL.EXECUTE(l_cursor_id);
      --
  --  end if;
    --
      end loop;
  end loop;
  --
  DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
--
--
  if g_debug then
    hr_utility.set_location('Exiting'||l_proc, 15);
  end if;
--
EXCEPTION
 --
 when OTHERS then
   if DBMS_SQL.IS_OPEN(l_cursor_id) then
     DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
   end if;
 raise;

END update_ht_strt_end_dt;




--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_ht_elmt_data >-------------------------|
-- ----------------------------------------------------------------------------
--
Function get_ht_elmt_data(p_ext_rslt_id              in number,
                          p_data_elmt_typ_cd         in varchar2 ,
                          p_short_name               in varchar2 ,
                          p_ext_data_elmt_id         in number,
                          p_frmt_mask_cd             in varchar2 default null,
                          p_frmt_mask_lookup_cd      in varchar2 default null,
                          p_dflt_val                 in varchar2 default null,
                          p_data_elmt_rl             in number   default null,
                          p_pl_id                    in number   default null,
                          p_business_group_id        in number,
                          p_effective_date           in date ,
                          p_request_id               in number,
                          p_ext_file_id              in number   default null,
                          p_ttl_fnctn_cd             in varchar2 default null,
                          p_ttl_sum_ext_data_elmt_id in number   default null,
                          p_ttl_cond_ext_data_elmt_id in number   default null,
                          p_rcd_typ_cd               in varchar2 default null,
                          p_group_val_01             in varchar2  default null,
                          p_group_val_02             in varchar2  default null,
                          p_ext_per_bg_id            in varchar2  default null,
                          p_String_val               in varchar2  default null
                          )
                          return varchar2 IS


  cursor c_rule_type(p_rule_id ff_formulas_f.formula_id%type) is
    select formula_type_id
    from   ff_formulas_f
    where  formula_id = p_rule_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;

  cursor bus_c (p_bg_id  number) is
  select name
  from   per_business_groups
  where  organization_id = p_bg_id ;

  cursor c_plcy (l_pl_id Number , l_typ_cd varchar2) is
   select a.plcy_r_grp
     from ben_popl_org_f a,
          ben_popl_org_role_f b
    where a.pl_id = l_pl_id
      and a.plcy_r_grp is not null
      and a.popl_org_id = b.popl_org_id
      and b.org_role_typ_cd = l_typ_cd
      and p_effective_date between a.effective_start_date
                             and a.effective_end_date
       and p_effective_date between b.effective_start_date
                             and b.effective_end_date;

  cursor c_plplcy (l_pl_id Number) is
   select a.plcy_r_grp
     from ben_popl_org_f a
    where a.pl_id = l_pl_id
      and a.plcy_r_grp is not null
      and p_effective_date between a.effective_start_date
                             and a.effective_end_date ;


  cursor c_custid (l_pl_id Number , l_typ_cd varchar2) is
   select a.cstmr_num
     from ben_popl_org_f a,
          ben_popl_org_role_f b
    where a.pl_id = l_pl_id
      and a.cstmr_num is not null
      and a.popl_org_id = b.popl_org_id
      and b.org_role_typ_cd = l_typ_cd
      and p_effective_date between a.effective_start_date
                             and a.effective_end_date
       and p_effective_date between b.effective_start_date
                             and b.effective_end_date;

  cursor c_rolname (l_pl_id Number , l_typ_cd varchar2) is
   select b.name
   from ben_popl_org_f a,
        ben_popl_org_role_f b
   where a.pl_id = l_pl_id
     and b.name is not null
     and b.org_role_typ_cd = l_typ_cd
      and a.popl_org_id = b.popl_org_id
     and p_effective_date between a.effective_start_date
         and a.effective_end_date
     and p_effective_date between b.effective_start_date
         and b.effective_end_date;


  cursor get_per_cnt (p_group_val_01 varchar2 ,
                      p_group_val_02 varchar2) is
  select count(distinct person_id)
  from   ben_ext_rslt_dtl xrd
  where  xrd.ext_rslt_id = p_ext_rslt_id
  and    person_id not in (0, 999999999999)
  and    xrd.group_val_01 = p_group_val_01
  and    nvl(xrd.group_val_02,'-1')  =  nvl(p_group_val_02,'-1') ;


   cursor get_dtl_cnt(p_group_val_01 varchar2 ,
                      p_group_val_02 varchar2) is
   select count(*)
   from   ben_ext_rslt_dtl xrd ,
          ben_ext_rcd_in_file erf
   where  xrd.ext_rslt_id = p_ext_rslt_id
    and   xrd.ext_rcd_id  = erf.ext_rcd_id
    and   xrd.ext_rcd_in_file_id  = erf.ext_rcd_in_file_id
    and   erf.ext_file_id = p_ext_file_id
    and   erf.hide_flag    = 'N'
    and   xrd. person_id not in (0, 999999999999)
    and   xrd.group_val_01 = p_group_val_01
    and   nvl(xrd.group_val_02,'-1')  =  nvl(p_group_val_02,'-1')
  ;


  cursor get_ttl_cnt(p_group_val_01 varchar2 ,
                      p_group_val_02 varchar2) is
   select count(*)
   from   ben_ext_rslt_dtl xrd ,
          ben_ext_rcd_in_file erf
   where  xrd.ext_rslt_id  = p_ext_rslt_id
    and   xrd.ext_rcd_id   = erf.ext_rcd_id
    and   xrd.ext_rcd_in_file_id  = erf.ext_rcd_in_file_id
    and   erf.ext_file_id  = p_ext_file_id
    and   erf.hide_flag    = 'N'
    and   xrd.group_val_01 = p_group_val_01
    and   nvl(xrd.group_val_02,'   ')  =  nvl(p_group_val_02,'   ')
  ;

  cursor get_subtrl_cnt is
 select count(*)
  from   ben_ext_rcd_in_file fil, ben_ext_rcd rcd
  where  fil.ext_rcd_id = rcd.ext_rcd_id
  and    fil.ext_file_id = p_ext_file_id
  and    rcd.rcd_type_cd = 'L';


 l_subtrl_cnt    number ;
 l_business_group_name    per_business_groups.name%TYPE;
 l_rule_type  c_rule_type%rowtype;
 l_outputs  ff_exec.outputs_t;
 l_dummy_var  varchar2(1000) ;
 l_proc           varchar2(72) ;
 l_rslt_elmt      varchar2(600) := null;  -- UTF8
 l_rslt_elmt_fmt  varchar2(600) := null;

Begin

  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'.get_ht_elmt_data';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

    IF p_data_elmt_typ_cd = 'F' THEN

       IF p_short_name = 'EFFDT' THEN
           l_rslt_elmt := ben_ext_fmt.apply_format_mask(p_effective_date, P_frmt_mask_cd);
        ELSIF p_short_name = 'STRTDT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_ext_strt_dt, P_frmt_mask_cd);
        ELSIF p_short_name = 'ENDDT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_ext_end_dt, P_frmt_mask_cd);
        ELSIF p_short_name = 'RUNDT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(sysdate, P_frmt_mask_cd);
        ELSIF p_short_name = 'RECCNT' THEN

          open  get_subtrl_cnt ;
          fetch  get_subtrl_cnt into l_subtrl_cnt ;
          close  get_subtrl_cnt ;

          --
          -- 1  there can be sub trailer without  grouping
          -- 2  there could be multiple subtrailer
          -- 3  sub trailer has to be counted when the total in subtrailer
          -- 4  sub trailer has to be counted when the total in trailer or header
          -- 5  g_rec_cnt calcualted when the header or trailer processes so
          --    we have to count them for non grouping subtrailer

          if  g_subtrl_cnt is null or g_subtrl_cnt = 0  then
              l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_rec_cnt + nvl(l_subtrl_cnt,0)  , P_frmt_mask_cd);
          else
               l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_rec_cnt+ nvl(g_subtrl_cnt,0)  , P_frmt_mask_cd);
          end if ;

          --- sub grouping trailer
          if p_rcd_typ_cd = 'L' and  p_group_val_01 is not null then
             l_rslt_elmt := null ;
             open get_ttl_cnt (p_group_val_01 ,
                               p_group_val_02)  ;
             fetch get_ttl_cnt into l_rslt_elmt ;
             close  get_ttl_cnt ;

             hr_utility.set_location( ' ttl  count ' || l_rslt_elmt , 99 ) ;
             hr_utility.set_location( ' su ttl   ' || l_subtrl_cnt , 99 ) ;
             if l_rslt_elmt is not null or l_subtrl_cnt is not null  then
                l_rslt_elmt :=
                 ben_ext_fmt.apply_format_mask(nvl(to_number(l_rslt_elmt),0)+
                              nvl(l_subtrl_cnt,0),P_frmt_mask_cd);
             end if ;

          end if ;

        ELSIF p_short_name = 'DTLCNT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_dtl_cnt, P_frmt_mask_cd);
           --- sub grouping trailer
          if p_rcd_typ_cd = 'L' and  p_group_val_01 is not null then
             l_rslt_elmt := null ;
             open get_dtl_cnt (p_group_val_01 ,
                               p_group_val_02)  ;
             fetch get_dtl_cnt into l_rslt_elmt ;
             close  get_dtl_cnt ;
             hr_utility.set_location( ' dtl  count ' || l_rslt_elmt , 99 ) ;
             if l_rslt_elmt is not null then
                l_rslt_elmt := ben_ext_fmt.apply_format_mask(l_rslt_elmt, P_frmt_mask_cd);
             end if ;

          end if ;

        ELSIF p_short_name = 'HDRCNT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_hdr_cnt, P_frmt_mask_cd);
        ELSIF p_short_name = 'TRLCNT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_trl_cnt, P_frmt_mask_cd);
        ELSIF p_short_name = 'PERCNT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_per_cnt, P_frmt_mask_cd);
          if p_rcd_typ_cd = 'L' and  p_group_val_01 is not null then
             l_rslt_elmt := null ;
             open get_per_cnt (p_group_val_01 ,
                               p_group_val_02)  ;
             fetch get_per_cnt into l_rslt_elmt ;
             close  get_per_cnt ;

             if l_rslt_elmt is not null then
                l_rslt_elmt := ben_ext_fmt.apply_format_mask(l_rslt_elmt, P_frmt_mask_cd);
             end if ;

          end if ;

        ELSIF p_short_name = 'BSGRP' THEN
          if p_ext_per_bg_id is not null then

              open bus_c (p_ext_per_bg_id );
             fetch bus_c into l_business_group_name;
             close bus_c;
          else
             open bus_c (p_business_group_id);
             fetch bus_c into l_business_group_name;
             close bus_c;
          end if ;
          l_rslt_elmt := l_business_group_name;

        ELSIF p_short_name = 'PBSGRP' THEN
          open bus_c (p_business_group_id);
          fetch bus_c into l_business_group_name;
          close bus_c;
          l_rslt_elmt := l_business_group_name;

        ELSIF p_short_name = 'SHDRCNT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_subhdr_cnt, P_frmt_mask_cd);
        ELSIF p_short_name = 'STRLCNT' THEN
          l_rslt_elmt := ben_ext_fmt.apply_format_mask(g_subtrl_cnt, P_frmt_mask_cd);

        ELSIF p_short_name = 'EXRQID' THEN
             l_rslt_elmt := ben_ext_fmt.apply_format_mask(p_request_id,P_frmt_mask_cd);
        ELSIF p_short_name = 'SPOIDNO' THEN
              open c_custid (p_pl_id ,'SPON');
              fetch c_custid into l_rslt_elmt ;
              close c_custid ;
        ELSIF p_short_name = 'SPONAME' THEN
              open c_rolname (p_pl_id ,'SPON');
              fetch c_rolname into l_rslt_elmt ;
              close c_rolname ;
        ELSIF p_short_name = 'SPOPONO' THEN
              open c_plcy (p_pl_id ,'SPON');
              fetch c_plcy into l_rslt_elmt ;
              close c_plcy ;
        ELSIF p_short_name = 'SPOTYPCD' THEN
               l_rslt_elmt  := 'SPON' ;
        ELSIF p_short_name = 'INSIDNO' THEN
              open c_custid (p_pl_id ,'INSR');
              fetch c_custid into l_rslt_elmt ;
              close c_custid ;
        ELSIF p_short_name = 'INSNAME' THEN
             open  c_rolname (p_pl_id ,'INSR');
             fetch c_rolname into l_rslt_elmt ;
             close c_rolname  ;
        ELSIF p_short_name = 'INSPONO' THEN
              open c_plcy (p_pl_id ,'INSR');
              fetch c_plcy into l_rslt_elmt ;
              close c_plcy ;
        ELSIF p_short_name = 'INSTYPCD' THEN
               l_rslt_elmt  := 'INSR' ;
        ELSIF p_short_name = 'BROIDNO' THEN
              open c_custid (p_pl_id ,'BROK');
              fetch c_custid into l_rslt_elmt ;
              close c_custid ;

        ELSIF p_short_name = 'BRONAME' THEN
              open c_rolname (p_pl_id ,'BROK');
              fetch c_rolname into l_rslt_elmt ;
              close c_rolname ;
        ELSIF p_short_name = 'BROPONO' THEN
             open c_plcy (p_pl_id ,'BROK');
              fetch c_plcy into l_Rslt_elmt ;
              close c_plcy ;
        ELSIF p_short_name = 'BROTYPCD' THEN
              l_rslt_elmt  := 'BROK' ;
        ELSIF p_short_name = 'PLPLCY' THEN
              open  c_plplcy (p_pl_id );
              fetch c_plplcy into l_rslt_elmt ;
              close c_plplcy ;
        ELSIF p_short_name = 'FILLER' THEN
          l_rslt_elmt := null;
        END IF;
    ELSIF p_data_elmt_typ_cd = 'D' THEN

        IF p_short_name = 'BSGRP' THEN
          if p_ext_per_bg_id is not null then
              l_rslt_elmt := ben_ext_fmt.apply_decode
                        (to_char(p_ext_per_bg_id),
                        p_ext_data_elmt_id,
                        p_dflt_val);
          else
             l_rslt_elmt := ben_ext_fmt.apply_decode
                        (to_char(p_business_group_id),
                        p_ext_data_elmt_id,
                        p_dflt_val);
          end if ;
       ELSIF p_short_name = 'PBSGRP' THEN
             l_rslt_elmt := ben_ext_fmt.apply_decode
                        (to_char(p_business_group_id),
                        p_ext_data_elmt_id,
                        p_dflt_val);

       END IF ;


   ELSIF p_data_elmt_typ_cd = 'R' THEN
        -- data element is a rule:

           --
       if g_debug then
         hr_utility.set_location(' Rule546:'||P_data_elmt_rl, 39);
       end if;


       open  c_rule_type(P_data_elmt_rl);
       fetch c_rule_type into l_rule_type;
       close c_rule_type;

       if g_debug then
         hr_utility.set_location(' rule type :'||l_rule_type.formula_type_id, 39);
         hr_utility.set_location(' ext_dfn_id  :'||ben_ext_thread.g_ext_dfn_id, 39);
         hr_utility.set_location(' rslt id  :'||ben_ext_thread.g_ext_rslt_id, 39);
       end if;
       if l_rule_type.formula_type_id = -546 then
          l_outputs := benutils.formula
                      (p_formula_id         => p_data_elmt_rl,
                       p_effective_date     => p_effective_date ,
                       p_business_group_id  => nvl(p_ext_per_bg_id, p_business_group_id)
                       ,p_param1             => 'EXT_DFN_ID'
                       ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                       ,p_param2             => 'EXT_RSLT_ID'
                       ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                       ,p_param3             => 'EXT_USER_VALUE'
                       ,p_param3_value       => p_string_val
                       ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                       ,p_param4_value       =>  to_char(p_business_group_id)
                    );

           l_rslt_elmt := l_outputs(l_outputs.first).value;
           --
           hr_utility.set_location(' rule result :'|| l_rslt_elmt, 39);

           -- format mask handling
           if p_frmt_mask_lookup_cd is not null then
              begin
                if substr(p_frmt_mask_lookup_cd,1,1) = 'N' then
                    l_rslt_elmt_fmt := ben_ext_fmt.apply_format_mask(to_number(l_rslt_elmt), p_frmt_mask_cd);
                    l_rslt_elmt := l_rslt_elmt_fmt;
                end if;
                if substr(p_frmt_mask_lookup_cd,1,1) = 'D' then
                    l_rslt_elmt_fmt :=  ben_ext_fmt.apply_format_mask(fnd_date.canonical_to_date(l_rslt_elmt), p_frmt_mask_cd);
                    l_rslt_elmt := l_rslt_elmt_fmt;
                end if ;
              exception  -- incase l_rslt_elmt is not valid for formatting, just don't format it.
                when others then
                  null;
              end;
           end if ;
           hr_utility.set_location(' rule result frmt :'|| l_rslt_elmt, 39);
       else
         --- this avoid copying the previous result
         l_rslt_elmt := null ;
       end if ;

      ELSIF p_data_elmt_typ_cd = 'T' THEN
        --
        -- data element is a total:
        -- ---------------------------------------------------------
        ben_ext_smart_total.calc_smart_total
        (p_ext_rslt_id => p_ext_rslt_id,
         p_ttl_fnctn_cd => p_ttl_fnctn_cd,
         p_ttl_sum_ext_data_elmt_id => p_ttl_sum_ext_data_elmt_id,
         p_ttl_cond_ext_data_elmt_id => p_ttl_cond_ext_data_elmt_id,
         p_ext_data_elmt_id => p_ext_data_elmt_id,
         p_frmt_mask_cd => p_frmt_mask_cd,
         p_ext_file_id => p_ext_file_id,
         p_business_group_id => p_business_group_id,
         p_smart_total => l_rslt_elmt);


    end if ;

    return l_rslt_elmt ;

Exception
   when others then
    raise;  -- such that the calling pgm will handle the rest.


End get_ht_elmt_data ;



-- ----------------------------------------------------------------------------
-- |---------< get_calc_value >---------------------------------------------|
-- ----------------------------------------------------------------------------
function get_calc_value
                         (
                          p_ext_rslt_id         in number,
                          p_ext_file_id         in number,
                          p_data_elmt_typ_cd    in varchar2 ,
                          p_short_name          in varchar2 ,
                          p_ext_data_elmt_id    in number,
                          p_frmt_mask_cd        in varchar2 default null,
                          p_frmt_mask_lookup_cd in varchar2 default null,
                          p_dflt_val            in varchar2 default null,
                          p_data_elmt_rl        in number   default null,
                          p_pl_id               in number   default null,
                          p_business_group_id   in number,
                          p_effective_date      in date ,
                          p_request_id          in number ,
                          p_calc                in varchar2 ,
                          p_rcd_typ_cd          in varchar2 default null
                           ) return varchar2 IS
--
 l_proc               varchar2(72) := g_package||'get_calc_value';
 l_number                       varchar2(1);
 l_max_len                      integer ;
--
 l_rslt_elmt          varchar2(4000) ;
 l_rslt_calc          varchar2(4000) ;
 Cursor c_calc_elmt is
 select ewc.seq_num
       ,xel.ext_data_elmt_id
       , xel.data_elmt_typ_cd
       , xel.data_elmt_rl
       , xel.name
       , xel.string_val
       , xel.dflt_val
       , xel.max_length_num
       , xel.ttl_fnctn_cd
       , xel.ttl_cond_oper_cd
       , xel.ttl_cond_val
       , xel.ttl_sum_ext_data_elmt_id
       , xel.ttl_cond_ext_data_elmt_id
       , efl.short_name
 from ben_Ext_where_clause ewc,
      ben_Ext_data_elmt    xel,
      ben_ext_fld          efl
 where ewc.ext_data_elmt_id = p_ext_data_elmt_id
   and xel.ext_data_elmt_id = ewc.cond_ext_data_elmt_id
   and xel.ext_fld_id       = efl.ext_fld_id (+)  ;
begin

    hr_utility.set_location('Entering'||l_proc, 5);
    for elmt in c_calc_elmt Loop
            l_rslt_calc :=get_ht_elmt_data(p_ext_rslt_id        => p_ext_rslt_id,
                          p_data_elmt_typ_cd    => elmt.data_elmt_typ_cd ,
                          p_short_name          => elmt.short_name ,
                          p_ext_data_elmt_id    => elmt.ext_data_elmt_id,
                          p_frmt_mask_cd        => p_frmt_mask_cd ,
                          p_frmt_mask_lookup_cd => p_frmt_mask_lookup_cd,
                          p_dflt_val            => elmt.dflt_val  ,
                          p_data_elmt_rl        => elmt.data_elmt_rl ,
                          p_pl_id               => p_pl_id ,
                          p_business_group_id   => p_business_group_id,
                          p_effective_date      => p_effective_date ,
                          p_request_id          => p_request_id,
                          p_ext_file_id         => p_ext_file_id,
                          p_ttl_fnctn_cd        => elmt.ttl_fnctn_cd ,
                          p_ttl_sum_ext_data_elmt_id  =>   elmt.ttl_sum_ext_data_elmt_id,
                          p_ttl_cond_ext_data_elmt_id =>  elmt.ttl_cond_ext_data_elmt_id,
                          p_rcd_typ_cd          => p_rcd_typ_cd
                          ) ;
            hr_utility.set_location (' HT ' || elmt.short_name || l_rslt_calc , 999 );
            hr_utility.set_location (' type  ' || elmt.short_name || elmt.data_elmt_typ_cd , 999 );

         Begin
            l_rslt_calc := to_number(l_rslt_calc) ;
         exception
            when value_error then
               l_rslt_calc := null ;
         end ;

         if  l_rslt_elmt is null  then
             l_rslt_elmt := l_rslt_calc ;
         else
            if l_rslt_calc is not null then
               l_rslt_elmt := ben_ext_fmt.Calculate_calc_value
                               (p_firtst_value   => to_number(l_rslt_elmt)
                               ,p_second_value   => l_rslt_calc
                               ,p_calc           => p_calc ) ;
            end if ;
         end if ;
         hr_utility.set_location (' HT result ' ||  l_rslt_elmt , 999 );
    end loop ;
    l_rslt_elmt := ben_ext_fmt.apply_format_mask(to_number(l_rslt_elmt), p_frmt_mask_cd);


   hr_utility.set_location (' HT return result ' ||  l_rslt_elmt , 999 );
   hr_utility.set_location(' Exiting:'||l_proc, 15);
   return l_rslt_elmt ;
end get_calc_value ;




--
-- ----------------------------------------------------------------------------
-- |--------------------------< process_ext_ht_recs >-------------------------|
-- ----------------------------------------------------------------------------
--
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
                             )
                              IS
--
  l_proc               varchar2(72);
--
  l_chg                varchar2(1) := 'I';
  l_ext_rcd_id         number(15) := null;
  l_ext_rcd_in_file_id number(15) := null;
  l_rslt_elmt          varchar2(600) := null;  -- UTF8
--
  l_ext_rslt_dtl_id        number(15);
  l_object_version_number  number(15);
--
  l_trans_num              number(15);
  l_person_id              number(15);
  l_prmy_sort_val          ben_ext_rslt_dtl.prmy_sort_val%TYPE;  -- UTF8 varchar2(30);
  l_scnd_sort_val          ben_ext_rslt_dtl.scnd_sort_val%TYPE;  -- UTF8 varchar2(30);
  l_exclude_this_rcd_flag  boolean;
  l_write_rcd              varchar2(1);
  l_elmt_name              varchar2(2000) ;
  l_error_message          varchar2(2000) ;
  l_rqd_elmt_available     varchar2(1) := 'Y' ;
  l_group_val_01           varchar2(2000) ;
  l_group_val_02           varchar2(2000) ;
--
  cursor ext_rcd_typ_c is
  select a.ext_rcd_id,
         b.ext_rcd_in_file_id,
         b.seq_num,
         b.sprs_cd,
         b.rqd_flag
  from   ben_ext_rcd          a,
         ben_ext_rcd_in_file  b
  where  a.ext_rcd_id  = b.ext_rcd_id
  and    b.ext_file_id = p_ext_file_id
  and    a.rcd_type_cd = p_rcd_typ_cd
  order by b.seq_num;
--
  cursor rcd_elmt_c  is
  select a.ext_data_elmt_in_rcd_id,
         a.seq_num,
         a.sprs_cd,
         a.strt_pos,
         a.dlmtr_val,
         a.rqd_flag,
         b.ext_data_elmt_id,
         b.data_elmt_typ_cd,
         b.data_elmt_rl,
         b.name,
         hr_general.decode_lookup('BEN_EXT_FRMT_MASK',b.frmt_mask_cd) frmt_mask_cd,
         b.frmt_mask_cd frmt_mask_lookup_cd ,
         b.string_val,
         b.dflt_val,
         b.max_length_num,
         b.just_cd,
         b.ttl_fnctn_cd,
         b.ttl_cond_oper_cd,
         b.ttl_cond_val,
         b.ttl_sum_ext_data_elmt_id,
         b.ttl_cond_ext_data_elmt_id,
         c.short_name
  from   ben_ext_data_elmt_in_rcd    a,
         ben_ext_data_elmt           b,
         ben_ext_fld                 c
  where  a.ext_rcd_id = l_ext_rcd_id
  and    a.ext_data_elmt_id = b.ext_data_elmt_id
  and    b.ext_fld_id = c.ext_fld_id (+)
  order by a.seq_num;
--

  CURSOR get_pl_val IS
  SELECT b.val_1
  FROM ben_ext_crit_typ a,
       ben_ext_crit_val b
  WHERE  a.ext_crit_typ_id = b.ext_crit_typ_id
    and  a.crit_typ_cd = 'BPL'
    and  a.ext_crit_prfl_id = p_ext_crit_prfl_id;


  cursor get_subtrl_cnt is
  select count(*)
  from   ben_Ext_rslt_dtl xrd,
         ben_ext_rcd rcd,
         ben_ext_rcd_in_file erf
   where  xrd.ext_rslt_id = p_ext_rslt_id
    and   xrd.ext_rcd_id = erf.ext_rcd_id
    and   xrd.ext_rcd_in_file_id  = erf.ext_rcd_in_file_id
    and   erf.ext_file_id = p_ext_file_id
    and   rcd.ext_rcd_id = erf.ext_rcd_id
    and   erf.hide_flag    = 'N'
   and    rcd.rcd_type_cd = 'L' ;

l_pl_id   number ;
l_dummy_var  varchar2(1000) ;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'.process_ext_ht_recs';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;
--
  savepoint head_trail;
--
-- assign values for sorting
-- for now let's do this, but maybe there is a better way
--
  IF p_rcd_typ_cd = 'H' THEN
    l_person_id := 0;
    l_trans_num := 0;
    l_prmy_sort_val := '   ';
    l_scnd_sort_val := '   ';
    l_group_val_01  := '   ' ;
    l_group_val_02  := '   ' ;
  elsif   p_rcd_typ_cd = 'T' THEN
    l_person_id := 999999999999;
    l_trans_num := 999999999999;
    l_prmy_sort_val := null;
    l_scnd_sort_val := null;
    l_group_val_01  := null ;
    l_group_val_02  := null ;
  elsif  p_rcd_typ_cd = 'L' THEN
    l_person_id := 999999999999;
    l_trans_num := 999999999999;
    l_prmy_sort_val := null;
    l_scnd_sort_val := null;
    l_group_val_01  := p_group_val_01 ;
    l_group_val_02  := p_group_val_02 ;
    if p_group_val_01 = '   '  then
       l_group_val_01  := null ;
       l_group_val_02  := null ;
    elsif p_group_val_02 = '   '  then
       l_group_val_02  := null ;
    end if ;


  END IF;

  if  p_rcd_typ_cd <>  'L' and g_subtrl_cnt = 0 and
      ben_ext_thread.g_ext_group_elmt1 is not null   then
     open  get_subtrl_cnt   ;
     fetch get_subtrl_cnt into g_subtrl_cnt ;
     close  get_subtrl_cnt ;
  end if ;

-- Get the  plan type for ansi
  open get_pl_val ;
  fetch get_pl_val into l_pl_id ;
  close get_pl_val ;


-- This loop will be executed for each record in the extract definition
-- of a given record type (Header, Trailer)
--
  FOR rcd IN ext_rcd_typ_c LOOP
--
    l_ext_rcd_id          := rcd.ext_rcd_id;
    l_ext_rcd_in_file_id  := rcd.ext_rcd_in_file_id;
    l_rqd_elmt_available  := 'Y';
--
-- Initialize array
--
    ben_ext_fmt.g_val_tab := g_val_def;
--
    FOR elmt IN rcd_elmt_c LOOP
--
      l_rslt_elmt := null ;
      if g_debug then
        hr_utility.set_location('element '||elmt.short_name, 5);
        hr_utility.set_location('element type  '||elmt.data_elmt_typ_cd, 5);
      end if;
      IF elmt.data_elmt_typ_cd in ( 'F','D','R')  THEN

          l_rslt_elmt := get_ht_elmt_data(p_ext_rslt_id        => p_ext_rslt_id,
                          p_data_elmt_typ_cd    => elmt.data_elmt_typ_cd ,
                          p_short_name          => elmt.short_name ,
                          p_ext_data_elmt_id    => elmt.ext_data_elmt_id,
                          p_frmt_mask_cd        => elmt.frmt_mask_cd ,
                          p_frmt_mask_lookup_cd => elmt.frmt_mask_lookup_cd,
                          p_dflt_val            => elmt.dflt_val  ,
                          p_data_elmt_rl        => elmt.data_elmt_rl ,
                          p_pl_id               => l_pl_id ,
                          p_business_group_id   => p_business_group_id,
                          p_effective_date      => p_effective_date ,
                          p_request_id          => p_request_id ,
                          p_ext_file_id         => p_ext_file_id,
                          p_rcd_typ_cd          => p_rcd_typ_cd ,
                          p_group_val_01        => l_group_val_01,
                          p_group_val_02        => l_group_val_02,
                          p_ext_per_bg_id       => p_ext_per_bg_id ,
                          p_String_val          => elmt.String_val
                          ) ;

         if substr(elmt.frmt_mask_lookup_cd,1,1)  = 'C' then
            l_rslt_elmt := ben_ext_fmt.apply_format_Function(l_rslt_elmt, elmt.frmt_mask_lookup_cd);
         end if ;

--
      ELSIF elmt.data_elmt_typ_cd = 'C' THEN
               l_rslt_elmt :=   get_calc_value
                         (p_ext_rslt_id        => p_ext_rslt_id,
                          p_data_elmt_typ_cd    => elmt.data_elmt_typ_cd ,
                          p_short_name          => elmt.short_name ,
                          p_ext_data_elmt_id    => elmt.ext_data_elmt_id,
                          p_frmt_mask_cd        => elmt.frmt_mask_cd ,
                          p_frmt_mask_lookup_cd => elmt.frmt_mask_lookup_cd,
                          p_dflt_val            => elmt.dflt_val  ,
                          p_data_elmt_rl        => elmt.data_elmt_rl ,
                          p_pl_id               => l_pl_id ,
                          p_business_group_id   => p_business_group_id,
                          p_effective_date      => p_effective_date ,
                          p_request_id          => p_request_id,
                          p_ext_file_id         => p_ext_file_id,
                          p_calc                => elmt.ttl_fnctn_cd ,
                          p_rcd_typ_cd          => p_rcd_typ_cd
                         );

--
      ELSIF elmt.data_elmt_typ_cd = 'S' THEN
            --
            -- data element is a string:
            l_rslt_elmt := elmt.string_val;
            if g_debug then
              hr_utility.set_location(' mass lengh   :'||elmt.max_length_num , 39);
            end if;
             IF elmt.max_length_num is not null THEN
                 l_rslt_elmt := rPad(nvl(l_rslt_elmt,' '),elmt.max_length_num );
                 if g_debug then
                   hr_utility.set_location('ele    :'||l_rslt_elmt , 39);
                 end if;
             end if ;
      ELSIF elmt.data_elmt_typ_cd = 'T' THEN

        ben_ext_smart_total.calc_smart_total
        (p_ext_rslt_id => p_ext_rslt_id,
         p_ttl_fnctn_cd => elmt.ttl_fnctn_cd,
         p_ttl_sum_ext_data_elmt_id => elmt.ttl_sum_ext_data_elmt_id,
         p_ttl_cond_ext_data_elmt_id => elmt.ttl_cond_ext_data_elmt_id,
         p_ext_data_elmt_id => elmt.ext_data_elmt_id,
         p_frmt_mask_cd => elmt.frmt_mask_cd,
         p_ext_file_id => p_ext_file_id,
         p_group_val_01  => p_group_val_01 ,
         p_group_val_02  => p_group_val_02 ,
         p_business_group_id => p_business_group_id,
         p_smart_total => l_rslt_elmt);

         --- set fromat mask

         ---

       /*

        l_rslt_elmt :=get_ht_elmt_data(p_ext_rslt_id  => p_ext_rslt_id,
                          p_data_elmt_typ_cd    => elmt.data_elmt_typ_cd ,
                          p_short_name          => elmt.short_name ,
                          p_ext_data_elmt_id    => elmt.ext_data_elmt_id,
                          p_frmt_mask_cd        => elmt.frmt_mask_cd ,
                          p_dflt_val            => elmt.dflt_val  ,
                          p_data_elmt_rl        => elmt.data_elmt_rl ,
                          p_pl_id               => l_pl_id ,
                          p_business_group_id   => p_business_group_id,
                          p_effective_date      => p_effective_date ,
                          p_request_id          => p_request_id,
                          p_ext_file_id         => p_ext_file_id,
                          p_ttl_fnctn_cd        => elmt.ttl_fnctn_cd ,
                          p_ttl_sum_ext_data_elmt_id  =>   elmt.ttl_sum_ext_data_elmt_id,
                          p_ttl_cond_ext_data_elmt_id =>  elmt.ttl_cond_ext_data_elmt_id
                          ) ;


      */
--
      END IF;
--
      -- if resulting data element is null, substitute it with
      -- default value
--
      IF l_rslt_elmt is null then
--
        l_rslt_elmt := elmt.dflt_val;
--
      END IF;
--
      -- truncate data element
--
      IF elmt.max_length_num is not null THEN
--
        l_rslt_elmt := SUBSTR(l_rslt_elmt, 1, elmt.max_length_num);
--
      END IF;
--
      if g_debug then
        hr_utility.set_location(' max ele    :'||l_rslt_elmt , 39);
      end if;
      -- if data element is mandatory, but l_rslt_elmt is null then
      -- raise ht error
      -- when the element is required and not elemnt skip the record
      -- dont skip the entire header or details : tilak

--
      IF elmt.rqd_flag = 'Y' and (l_rslt_elmt is null) then
--
        g_err_name  := 'BEN_91887_EXT_RQD_DATA_ELMT';
        l_elmt_name :=  elmt.name ;
        l_error_message :=
        ben_ext_fmt.get_error_msg(to_number(substr(g_err_name, 5, 5)),g_err_name,l_elmt_name );
        -- when the elmt is null and required  can not create a record , if the record also required
        -- then throw the error or throw the warning , the assumption is  header allwasy has one record
        -- for a record definition
        if nvl(rcd.rqd_flag,'N') =  'Y' then
           write_error(p_err_num    => to_number(substr(g_err_name, 5, 5)),
                p_err_name          => l_error_message,
                p_typ_cd            => 'F',
                p_person_id         => null,
                p_request_id        => fnd_global.conc_request_id,
                p_ext_rslt_id       => p_ext_rslt_id,
                p_business_group_id => p_business_group_id
               );
            raise g_ht_error;
        else

              write_error(p_err_num => to_number(substr(g_err_name, 5, 5)),
                p_err_name          => l_error_message,
                p_typ_cd            => 'W',
                p_person_id         => null,
                p_request_id        => fnd_global.conc_request_id,
                p_ext_rslt_id       => p_ext_rslt_id,
                p_business_group_id => p_business_group_id
               );

        end if ;
        l_rqd_elmt_available  := 'N' ;
        exit ;
--        raise g_ht_error;
--
      END IF;
--
      --val_tab(elmt.seq_num) := l_rslt_elmt;
      ben_ext_fmt.g_val_tab(elmt.seq_num) := l_rslt_elmt;
--
    END LOOP;
--
     if l_rqd_elmt_available = 'Y'  then
        l_write_rcd := 'Y';
        --
        ben_ext_adv_conditions.data_elmt_in_rcd
           (p_ext_rcd_id => l_ext_rcd_id,
            p_exclude_this_rcd_flag => l_exclude_this_rcd_flag);
         --
         if l_exclude_this_rcd_flag = true then
            l_write_rcd := 'N';
         end if;
           --
         if l_write_rcd = 'Y' then
             ben_ext_adv_conditions.rcd_in_file
              (p_ext_rcd_in_file_id => rcd.ext_rcd_in_file_id,
               p_sprs_cd => rcd.sprs_cd,
               p_exclude_this_rcd_flag => l_exclude_this_rcd_flag);
               --
              if l_exclude_this_rcd_flag = true then
                 l_write_rcd := 'N';
              end if;
              --
         end if;
--
         if l_write_rcd = 'Y' then
--
         --  call 'create ext detail api' here
--
            ben_ext_rslt_dtl_api.create_ext_rslt_dtl
              (p_validate                   =>  false
             ,p_ext_rslt_dtl_id            =>  l_ext_rslt_dtl_id
             ,p_prmy_sort_val              =>  l_prmy_sort_val
             ,p_scnd_sort_val              =>  l_scnd_sort_val
             ,p_trans_seq_num              =>  l_trans_num
             ,p_rcrd_seq_num               =>  rcd.seq_num
             ,p_ext_rslt_id                =>  p_ext_rslt_id
             ,p_ext_rcd_id                 =>  l_ext_rcd_id
             ,p_person_id                  =>  l_person_id
             ,p_business_group_id          =>  p_business_group_id
             ,p_val_01                     =>  ben_ext_fmt.g_val_tab(1)
             ,p_val_02                     =>  ben_ext_fmt.g_val_tab(2)
             ,p_val_03                     =>  ben_ext_fmt.g_val_tab(3)
             ,p_val_04                     =>  ben_ext_fmt.g_val_tab(4)
             ,p_val_05                     =>  ben_ext_fmt.g_val_tab(5)
             ,p_val_06                     =>  ben_ext_fmt.g_val_tab(6)
             ,p_val_07                     =>  ben_ext_fmt.g_val_tab(7)
             ,p_val_08                     =>  ben_ext_fmt.g_val_tab(8)
             ,p_val_09                     =>  ben_ext_fmt.g_val_tab(9)
             ,p_val_10                     =>  ben_ext_fmt.g_val_tab(10)
             ,p_val_11                     =>  ben_ext_fmt.g_val_tab(11)
             ,p_val_12                     =>  ben_ext_fmt.g_val_tab(12)
             ,p_val_13                     =>  ben_ext_fmt.g_val_tab(13)
             ,p_val_14                     =>  ben_ext_fmt.g_val_tab(14)
             ,p_val_15                     =>  ben_ext_fmt.g_val_tab(15)
             ,p_val_16                     =>  ben_ext_fmt.g_val_tab(16)
             ,p_val_17                     =>  ben_ext_fmt.g_val_tab(17)
             ,p_val_18                     =>  ben_ext_fmt.g_val_tab(18)
             ,p_val_19                     =>  ben_ext_fmt.g_val_tab(19)
             ,p_val_20                     =>  ben_ext_fmt.g_val_tab(20)
             ,p_val_21                     =>  ben_ext_fmt.g_val_tab(21)
             ,p_val_22                     =>  ben_ext_fmt.g_val_tab(22)
             ,p_val_23                     =>  ben_ext_fmt.g_val_tab(23)
             ,p_val_24                     =>  ben_ext_fmt.g_val_tab(24)
             ,p_val_25                     =>  ben_ext_fmt.g_val_tab(25)
             ,p_val_26                     =>  ben_ext_fmt.g_val_tab(26)
             ,p_val_27                     =>  ben_ext_fmt.g_val_tab(27)
             ,p_val_28                     =>  ben_ext_fmt.g_val_tab(28)
             ,p_val_29                     =>  ben_ext_fmt.g_val_tab(29)
             ,p_val_30                     =>  ben_ext_fmt.g_val_tab(30)
             ,p_val_31                     =>  ben_ext_fmt.g_val_tab(31)
             ,p_val_32                     =>  ben_ext_fmt.g_val_tab(32)
             ,p_val_33                     =>  ben_ext_fmt.g_val_tab(33)
             ,p_val_34                     =>  ben_ext_fmt.g_val_tab(34)
             ,p_val_35                     =>  ben_ext_fmt.g_val_tab(35)
             ,p_val_36                     =>  ben_ext_fmt.g_val_tab(36)
             ,p_val_37                     =>  ben_ext_fmt.g_val_tab(37)
             ,p_val_38                     =>  ben_ext_fmt.g_val_tab(38)
             ,p_val_39                     =>  ben_ext_fmt.g_val_tab(39)
             ,p_val_40                     =>  ben_ext_fmt.g_val_tab(40)
             ,p_val_41                     =>  ben_ext_fmt.g_val_tab(41)
             ,p_val_42                     =>  ben_ext_fmt.g_val_tab(42)
             ,p_val_43                     =>  ben_ext_fmt.g_val_tab(43)
             ,p_val_44                     =>  ben_ext_fmt.g_val_tab(44)
             ,p_val_45                     =>  ben_ext_fmt.g_val_tab(45)
             ,p_val_46                     =>  ben_ext_fmt.g_val_tab(46)
             ,p_val_47                     =>  ben_ext_fmt.g_val_tab(47)
             ,p_val_48                     =>  ben_ext_fmt.g_val_tab(48)
             ,p_val_49                     =>  ben_ext_fmt.g_val_tab(49)
             ,p_val_50                     =>  ben_ext_fmt.g_val_tab(50)
             ,p_val_51                     =>  ben_ext_fmt.g_val_tab(51)
             ,p_val_52                     =>  ben_ext_fmt.g_val_tab(52)
             ,p_val_53                     =>  ben_ext_fmt.g_val_tab(53)
             ,p_val_54                     =>  ben_ext_fmt.g_val_tab(54)
             ,p_val_55                     =>  ben_ext_fmt.g_val_tab(55)
             ,p_val_56                     =>  ben_ext_fmt.g_val_tab(56)
             ,p_val_57                     =>  ben_ext_fmt.g_val_tab(57)
             ,p_val_58                     =>  ben_ext_fmt.g_val_tab(58)
             ,p_val_59                     =>  ben_ext_fmt.g_val_tab(59)
             ,p_val_60                     =>  ben_ext_fmt.g_val_tab(60)
             ,p_val_61                     =>  ben_ext_fmt.g_val_tab(61)
             ,p_val_62                     =>  ben_ext_fmt.g_val_tab(62)
             ,p_val_63                     =>  ben_ext_fmt.g_val_tab(63)
             ,p_val_64                     =>  ben_ext_fmt.g_val_tab(64)
             ,p_val_65                     =>  ben_ext_fmt.g_val_tab(65)
             ,p_val_66                     =>  ben_ext_fmt.g_val_tab(66)
             ,p_val_67                     =>  ben_ext_fmt.g_val_tab(67)
             ,p_val_68                     =>  ben_ext_fmt.g_val_tab(68)
             ,p_val_69                     =>  ben_ext_fmt.g_val_tab(69)
             ,p_val_70                     =>  ben_ext_fmt.g_val_tab(70)
             ,p_val_71                     =>  ben_ext_fmt.g_val_tab(71)
             ,p_val_72                     =>  ben_ext_fmt.g_val_tab(72)
             ,p_val_73                     =>  ben_ext_fmt.g_val_tab(73)
             ,p_val_74                     =>  ben_ext_fmt.g_val_tab(74)
             ,p_val_75                     =>  ben_ext_fmt.g_val_tab(75)
             ,p_val_76                     =>  ben_ext_fmt.g_val_tab(76)
             ,p_val_77                     =>  ben_ext_fmt.g_val_tab(77)
             ,p_val_78                     =>  ben_ext_fmt.g_val_tab(78)
             ,p_val_79                     =>  ben_ext_fmt.g_val_tab(79)
             ,p_val_80                     =>  ben_ext_fmt.g_val_tab(80)
             ,p_val_81                     =>  ben_ext_fmt.g_val_tab(81)
             ,p_val_82                     =>  ben_ext_fmt.g_val_tab(82)
             ,p_val_83                     =>  ben_ext_fmt.g_val_tab(83)
             ,p_val_84                     =>  ben_ext_fmt.g_val_tab(84)
             ,p_val_85                     =>  ben_ext_fmt.g_val_tab(85)
             ,p_val_86                     =>  ben_ext_fmt.g_val_tab(86)
             ,p_val_87                     =>  ben_ext_fmt.g_val_tab(87)
             ,p_val_88                     =>  ben_ext_fmt.g_val_tab(88)
             ,p_val_89                     =>  ben_ext_fmt.g_val_tab(89)
             ,p_val_90                     =>  ben_ext_fmt.g_val_tab(90)
             ,p_val_91                     =>  ben_ext_fmt.g_val_tab(91)
             ,p_val_92                     =>  ben_ext_fmt.g_val_tab(92)
             ,p_val_93                     =>  ben_ext_fmt.g_val_tab(93)
             ,p_val_94                     =>  ben_ext_fmt.g_val_tab(94)
             ,p_val_95                     =>  ben_ext_fmt.g_val_tab(95)
             ,p_val_96                     =>  ben_ext_fmt.g_val_tab(96)
             ,p_val_97                     =>  ben_ext_fmt.g_val_tab(97)
             ,p_val_98                     =>  ben_ext_fmt.g_val_tab(98)
             ,p_val_99                     =>  ben_ext_fmt.g_val_tab(99)
             ,p_val_100                    =>  ben_ext_fmt.g_val_tab(100)
             ,p_val_101                    =>  ben_ext_fmt.g_val_tab(101)
             ,p_val_102                    =>  ben_ext_fmt.g_val_tab(102)
             ,p_val_103                    =>  ben_ext_fmt.g_val_tab(103)
             ,p_val_104                    =>  ben_ext_fmt.g_val_tab(104)
             ,p_val_105                    =>  ben_ext_fmt.g_val_tab(105)
             ,p_val_106                    =>  ben_ext_fmt.g_val_tab(106)
             ,p_val_107                    =>  ben_ext_fmt.g_val_tab(107)
             ,p_val_108                    =>  ben_ext_fmt.g_val_tab(108)
             ,p_val_109                    =>  ben_ext_fmt.g_val_tab(109)
             ,p_val_110                    =>  ben_ext_fmt.g_val_tab(110)
             ,p_val_111                    =>  ben_ext_fmt.g_val_tab(111)
             ,p_val_112                    =>  ben_ext_fmt.g_val_tab(112)
             ,p_val_113                    =>  ben_ext_fmt.g_val_tab(113)
             ,p_val_114                    =>  ben_ext_fmt.g_val_tab(114)
             ,p_val_115                    =>  ben_ext_fmt.g_val_tab(115)
             ,p_val_116                    =>  ben_ext_fmt.g_val_tab(116)
             ,p_val_117                    =>  ben_ext_fmt.g_val_tab(117)
             ,p_val_118                    =>  ben_ext_fmt.g_val_tab(118)
             ,p_val_119                    =>  ben_ext_fmt.g_val_tab(119)
             ,p_val_120                    =>  ben_ext_fmt.g_val_tab(120)
             ,p_val_121                    =>  ben_ext_fmt.g_val_tab(121)
             ,p_val_122                    =>  ben_ext_fmt.g_val_tab(122)
             ,p_val_123                    =>  ben_ext_fmt.g_val_tab(123)
             ,p_val_124                    =>  ben_ext_fmt.g_val_tab(124)
             ,p_val_125                    =>  ben_ext_fmt.g_val_tab(125)
             ,p_val_126                    =>  ben_ext_fmt.g_val_tab(126)
             ,p_val_127                    =>  ben_ext_fmt.g_val_tab(127)
             ,p_val_128                    =>  ben_ext_fmt.g_val_tab(128)
             ,p_val_129                    =>  ben_ext_fmt.g_val_tab(129)
             ,p_val_130                    =>  ben_ext_fmt.g_val_tab(130)
             ,p_val_131                    =>  ben_ext_fmt.g_val_tab(131)
             ,p_val_132                    =>  ben_ext_fmt.g_val_tab(132)
             ,p_val_133                    =>  ben_ext_fmt.g_val_tab(133)
             ,p_val_134                    =>  ben_ext_fmt.g_val_tab(134)
             ,p_val_135                    =>  ben_ext_fmt.g_val_tab(135)
             ,p_val_136                    =>  ben_ext_fmt.g_val_tab(136)
             ,p_val_137                    =>  ben_ext_fmt.g_val_tab(137)
             ,p_val_138                    =>  ben_ext_fmt.g_val_tab(138)
             ,p_val_139                    =>  ben_ext_fmt.g_val_tab(139)
             ,p_val_140                    =>  ben_ext_fmt.g_val_tab(140)
             ,p_val_141                    =>  ben_ext_fmt.g_val_tab(141)
             ,p_val_142                    =>  ben_ext_fmt.g_val_tab(142)
             ,p_val_143                    =>  ben_ext_fmt.g_val_tab(143)
             ,p_val_144                    =>  ben_ext_fmt.g_val_tab(144)
             ,p_val_145                    =>  ben_ext_fmt.g_val_tab(145)
             ,p_val_146                    =>  ben_ext_fmt.g_val_tab(146)
             ,p_val_147                    =>  ben_ext_fmt.g_val_tab(147)
             ,p_val_148                    =>  ben_ext_fmt.g_val_tab(148)
             ,p_val_149                    =>  ben_ext_fmt.g_val_tab(149)
             ,p_val_150                    =>  ben_ext_fmt.g_val_tab(150)
             ,p_val_151                    =>  ben_ext_fmt.g_val_tab(151)
             ,p_val_152                    =>  ben_ext_fmt.g_val_tab(152)
             ,p_val_153                    =>  ben_ext_fmt.g_val_tab(153)
             ,p_val_154                    =>  ben_ext_fmt.g_val_tab(154)
             ,p_val_155                    =>  ben_ext_fmt.g_val_tab(155)
             ,p_val_156                    =>  ben_ext_fmt.g_val_tab(156)
             ,p_val_157                    =>  ben_ext_fmt.g_val_tab(157)
             ,p_val_158                    =>  ben_ext_fmt.g_val_tab(158)
             ,p_val_159                    =>  ben_ext_fmt.g_val_tab(159)
             ,p_val_160                    =>  ben_ext_fmt.g_val_tab(160)
             ,p_val_161                    =>  ben_ext_fmt.g_val_tab(161)
             ,p_val_162                    =>  ben_ext_fmt.g_val_tab(162)
             ,p_val_163                    =>  ben_ext_fmt.g_val_tab(163)
             ,p_val_164                    =>  ben_ext_fmt.g_val_tab(164)
             ,p_val_165                    =>  ben_ext_fmt.g_val_tab(165)
             ,p_val_166                    =>  ben_ext_fmt.g_val_tab(166)
             ,p_val_167                    =>  ben_ext_fmt.g_val_tab(167)
             ,p_val_168                    =>  ben_ext_fmt.g_val_tab(168)
             ,p_val_169                    =>  ben_ext_fmt.g_val_tab(169)
             ,p_val_170                    =>  ben_ext_fmt.g_val_tab(170)
             ,p_val_171                    =>  ben_ext_fmt.g_val_tab(171)
             ,p_val_172                    =>  ben_ext_fmt.g_val_tab(172)
             ,p_val_173                    =>  ben_ext_fmt.g_val_tab(173)
             ,p_val_174                    =>  ben_ext_fmt.g_val_tab(174)
             ,p_val_175                    =>  ben_ext_fmt.g_val_tab(175)
             ,p_val_176                    =>  ben_ext_fmt.g_val_tab(176)
             ,p_val_177                    =>  ben_ext_fmt.g_val_tab(177)
             ,p_val_178                    =>  ben_ext_fmt.g_val_tab(178)
             ,p_val_179                    =>  ben_ext_fmt.g_val_tab(179)
             ,p_val_180                    =>  ben_ext_fmt.g_val_tab(180)
             ,p_val_181                    =>  ben_ext_fmt.g_val_tab(181)
             ,p_val_182                    =>  ben_ext_fmt.g_val_tab(182)
             ,p_val_183                    =>  ben_ext_fmt.g_val_tab(183)
             ,p_val_184                    =>  ben_ext_fmt.g_val_tab(184)
             ,p_val_185                    =>  ben_ext_fmt.g_val_tab(185)
             ,p_val_186                    =>  ben_ext_fmt.g_val_tab(186)
             ,p_val_187                    =>  ben_ext_fmt.g_val_tab(187)
             ,p_val_188                    =>  ben_ext_fmt.g_val_tab(188)
             ,p_val_189                    =>  ben_ext_fmt.g_val_tab(189)
             ,p_val_190                    =>  ben_ext_fmt.g_val_tab(190)
             ,p_val_191                    =>  ben_ext_fmt.g_val_tab(191)
             ,p_val_192                    =>  ben_ext_fmt.g_val_tab(192)
             ,p_val_193                    =>  ben_ext_fmt.g_val_tab(193)
             ,p_val_194                    =>  ben_ext_fmt.g_val_tab(194)
             ,p_val_195                    =>  ben_ext_fmt.g_val_tab(195)
             ,p_val_196                    =>  ben_ext_fmt.g_val_tab(196)
             ,p_val_197                    =>  ben_ext_fmt.g_val_tab(197)
             ,p_val_198                    =>  ben_ext_fmt.g_val_tab(198)
             ,p_val_199                    =>  ben_ext_fmt.g_val_tab(199)
             ,p_val_200                    =>  ben_ext_fmt.g_val_tab(200)
             ,p_val_201                    =>  ben_ext_fmt.g_val_tab(201)
             ,p_val_202                    =>  ben_ext_fmt.g_val_tab(202)
             ,p_val_203                    =>  ben_ext_fmt.g_val_tab(203)
             ,p_val_204                    =>  ben_ext_fmt.g_val_tab(204)
             ,p_val_205                    =>  ben_ext_fmt.g_val_tab(205)
             ,p_val_206                    =>  ben_ext_fmt.g_val_tab(206)
             ,p_val_207                    =>  ben_ext_fmt.g_val_tab(207)
             ,p_val_208                    =>  ben_ext_fmt.g_val_tab(208)
             ,p_val_209                    =>  ben_ext_fmt.g_val_tab(209)
             ,p_val_210                    =>  ben_ext_fmt.g_val_tab(210)
             ,p_val_211                    =>  ben_ext_fmt.g_val_tab(211)
             ,p_val_212                    =>  ben_ext_fmt.g_val_tab(212)
             ,p_val_213                    =>  ben_ext_fmt.g_val_tab(213)
             ,p_val_214                    =>  ben_ext_fmt.g_val_tab(214)
             ,p_val_215                    =>  ben_ext_fmt.g_val_tab(215)
             ,p_val_216                    =>  ben_ext_fmt.g_val_tab(216)
             ,p_val_217                    =>  ben_ext_fmt.g_val_tab(217)
             ,p_val_218                    =>  ben_ext_fmt.g_val_tab(218)
             ,p_val_219                    =>  ben_ext_fmt.g_val_tab(219)
             ,p_val_220                    =>  ben_ext_fmt.g_val_tab(220)
             ,p_val_221                    =>  ben_ext_fmt.g_val_tab(221)
             ,p_val_222                    =>  ben_ext_fmt.g_val_tab(222)
             ,p_val_223                    =>  ben_ext_fmt.g_val_tab(223)
             ,p_val_224                    =>  ben_ext_fmt.g_val_tab(224)
             ,p_val_225                    =>  ben_ext_fmt.g_val_tab(225)
             ,p_val_226                    =>  ben_ext_fmt.g_val_tab(226)
             ,p_val_227                    =>  ben_ext_fmt.g_val_tab(227)
             ,p_val_228                    =>  ben_ext_fmt.g_val_tab(228)
             ,p_val_229                    =>  ben_ext_fmt.g_val_tab(229)
             ,p_val_230                    =>  ben_ext_fmt.g_val_tab(230)
             ,p_val_231                    =>  ben_ext_fmt.g_val_tab(231)
             ,p_val_232                    =>  ben_ext_fmt.g_val_tab(232)
             ,p_val_233                    =>  ben_ext_fmt.g_val_tab(233)
             ,p_val_234                    =>  ben_ext_fmt.g_val_tab(234)
             ,p_val_235                    =>  ben_ext_fmt.g_val_tab(235)
             ,p_val_236                    =>  ben_ext_fmt.g_val_tab(236)
             ,p_val_237                    =>  ben_ext_fmt.g_val_tab(237)
             ,p_val_238                    =>  ben_ext_fmt.g_val_tab(238)
             ,p_val_239                    =>  ben_ext_fmt.g_val_tab(239)
             ,p_val_240                    =>  ben_ext_fmt.g_val_tab(240)
             ,p_val_241                    =>  ben_ext_fmt.g_val_tab(241)
             ,p_val_242                    =>  ben_ext_fmt.g_val_tab(242)
             ,p_val_243                    =>  ben_ext_fmt.g_val_tab(243)
             ,p_val_244                    =>  ben_ext_fmt.g_val_tab(244)
             ,p_val_245                    =>  ben_ext_fmt.g_val_tab(245)
             ,p_val_246                    =>  ben_ext_fmt.g_val_tab(246)
             ,p_val_247                    =>  ben_ext_fmt.g_val_tab(247)
             ,p_val_248                    =>  ben_ext_fmt.g_val_tab(248)
             ,p_val_249                    =>  ben_ext_fmt.g_val_tab(249)
             ,p_val_250                    =>  ben_ext_fmt.g_val_tab(250)
             ,p_val_251                    =>  ben_ext_fmt.g_val_tab(251)
             ,p_val_252                    =>  ben_ext_fmt.g_val_tab(252)
             ,p_val_253                    =>  ben_ext_fmt.g_val_tab(253)
             ,p_val_254                    =>  ben_ext_fmt.g_val_tab(254)
             ,p_val_255                    =>  ben_ext_fmt.g_val_tab(255)
             ,p_val_256                    =>  ben_ext_fmt.g_val_tab(256)
             ,p_val_257                    =>  ben_ext_fmt.g_val_tab(257)
             ,p_val_258                    =>  ben_ext_fmt.g_val_tab(258)
             ,p_val_259                    =>  ben_ext_fmt.g_val_tab(259)
             ,p_val_260                    =>  ben_ext_fmt.g_val_tab(260)
             ,p_val_261                    =>  ben_ext_fmt.g_val_tab(261)
             ,p_val_262                    =>  ben_ext_fmt.g_val_tab(262)
             ,p_val_263                    =>  ben_ext_fmt.g_val_tab(263)
             ,p_val_264                    =>  ben_ext_fmt.g_val_tab(264)
             ,p_val_265                    =>  ben_ext_fmt.g_val_tab(265)
             ,p_val_266                    =>  ben_ext_fmt.g_val_tab(266)
             ,p_val_267                    =>  ben_ext_fmt.g_val_tab(267)
             ,p_val_268                    =>  ben_ext_fmt.g_val_tab(268)
             ,p_val_269                    =>  ben_ext_fmt.g_val_tab(269)
             ,p_val_270                    =>  ben_ext_fmt.g_val_tab(270)
             ,p_val_271                    =>  ben_ext_fmt.g_val_tab(271)
             ,p_val_272                    =>  ben_ext_fmt.g_val_tab(272)
             ,p_val_273                    =>  ben_ext_fmt.g_val_tab(273)
             ,p_val_274                    =>  ben_ext_fmt.g_val_tab(274)
             ,p_val_275                    =>  ben_ext_fmt.g_val_tab(275)
             ,p_val_276                    =>  ben_ext_fmt.g_val_tab(276)
             ,p_val_277                    =>  ben_ext_fmt.g_val_tab(277)
             ,p_val_278                    =>  ben_ext_fmt.g_val_tab(278)
             ,p_val_279                    =>  ben_ext_fmt.g_val_tab(279)
             ,p_val_280                    =>  ben_ext_fmt.g_val_tab(280)
             ,p_val_281                    =>  ben_ext_fmt.g_val_tab(281)
             ,p_val_282                    =>  ben_ext_fmt.g_val_tab(282)
             ,p_val_283                    =>  ben_ext_fmt.g_val_tab(283)
             ,p_val_284                    =>  ben_ext_fmt.g_val_tab(284)
             ,p_val_285                    =>  ben_ext_fmt.g_val_tab(285)
             ,p_val_286                    =>  ben_ext_fmt.g_val_tab(286)
             ,p_val_287                    =>  ben_ext_fmt.g_val_tab(287)
             ,p_val_288                    =>  ben_ext_fmt.g_val_tab(288)
             ,p_val_289                    =>  ben_ext_fmt.g_val_tab(289)
             ,p_val_290                    =>  ben_ext_fmt.g_val_tab(290)
             ,p_val_291                    =>  ben_ext_fmt.g_val_tab(291)
             ,p_val_292                    =>  ben_ext_fmt.g_val_tab(292)
             ,p_val_293                    =>  ben_ext_fmt.g_val_tab(293)
             ,p_val_294                    =>  ben_ext_fmt.g_val_tab(294)
             ,p_val_295                    =>  ben_ext_fmt.g_val_tab(295)
             ,p_val_296                    =>  ben_ext_fmt.g_val_tab(296)
             ,p_val_297                    =>  ben_ext_fmt.g_val_tab(297)
             ,p_val_298                    =>  ben_ext_fmt.g_val_tab(298)
             ,p_val_299                    =>  ben_ext_fmt.g_val_tab(299)
             ,p_val_300                    =>  ben_ext_fmt.g_val_tab(300)
             ,p_group_val_01               =>  l_group_val_01
             ,p_group_val_02               =>  l_group_val_02
             ,p_program_application_id     =>  fnd_global.prog_appl_id
             ,p_program_id                 =>  fnd_global.conc_program_id
             ,p_program_update_date        =>  sysdate
             ,p_request_id                 =>  fnd_global.conc_request_id
             ,p_object_version_number      =>  l_object_version_number
             ,p_ext_per_bg_id            =>  p_ext_per_bg_id
             ,p_ext_rcd_in_file_id         =>  l_ext_rcd_in_file_id
             );
          --
         end if;
     end if ;
--
  END LOOP;
--
  commit;
--
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
--
exception
--
  when g_ht_error then

    rollback to head_trail;
    l_error_message :=
    ben_ext_fmt.get_error_msg(to_number(substr(g_err_name, 5, 5)),g_err_name,l_elmt_name );
    write_error(p_err_num           => to_number(substr(g_err_name, 5, 5)),
                p_err_name          => l_error_message,
                p_typ_cd            => 'F',
                p_person_id         => null,
                p_request_id        => fnd_global.conc_request_id,
                p_ext_rslt_id       => p_ext_rslt_id,
                p_business_group_id => p_business_group_id
               );
    raise ben_ext_thread.g_job_failure_error;
--
  when others then

    rollback to head_trail;
    raise;  -- such that the calling pgm will handle the rest.
--
end process_ext_ht_recs;
--



Procedure process_subtrailer(p_ext_rslt_id         in number,
                              p_ext_file_id         in number,
                              p_ext_typ_cd          in varchar2,
                              p_rcd_typ_cd          in varchar2,
                              p_business_group_id   in number,
                              p_effective_date      in date,
                              p_request_id          in number default null,
                              p_ext_group_elmt1     in varchar2,
                              p_ext_group_elmt2     in varchar2,
                              p_ext_crit_prfl_id    in number default null)
                              IS
--
  l_proc               varchar2(72);
--
   cursor get_subhdr_group is
  select distinct
         xrd.group_val_01,
         xrd.group_val_02,
         nvl(xrd.ext_per_bg_id,-1)  ext_per_bg_id
  from   ben_Ext_rslt_dtl xrd,
         ben_ext_rcd rcd,
         ben_ext_rcd_in_file erf
   where  xrd.ext_rslt_id = p_ext_rslt_id
    and   xrd.ext_rcd_id = erf.ext_rcd_id
    and   erf.ext_file_id = p_ext_file_id
    and   rcd.ext_rcd_id = erf.ext_rcd_id
   and    rcd.rcd_type_cd = 'S'
   and    ltrim(xrd.group_val_01)  is not null ;

--
  l_ext_per_bg_id  number ;
begin
--
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'.process_subtrailer';
    hr_utility.set_location('Entering'||l_proc, 5);
  end if;

  if p_ext_group_elmt1 is null then
         process_ext_ht_recs
             (p_ext_rslt_id       => p_ext_rslt_id,
              p_ext_file_id       => p_ext_file_id,
              p_ext_typ_cd        => p_ext_typ_cd,
              p_rcd_typ_cd        => p_rcd_typ_cd,
              p_business_group_id => p_business_group_id,
              p_effective_date    => p_effective_date,
              p_request_id        => p_request_id,
              p_ext_crit_prfl_id  => p_ext_crit_prfl_id ,
              p_ext_per_bg_id     => p_business_group_id
              );
  else

    for i  in get_subhdr_group   Loop

         l_ext_per_bg_id :=  i.ext_per_bg_id ;
         if i.ext_per_bg_id =  -1 then
            l_ext_per_bg_id := null ;
         end if  ;


         process_ext_ht_recs
             (p_ext_rslt_id       => p_ext_rslt_id,
              p_ext_file_id       => p_ext_file_id,
              p_ext_typ_cd        => p_ext_typ_cd,
              p_rcd_typ_cd        => p_rcd_typ_cd,
              p_business_group_id => p_business_group_id,
              p_effective_date    => p_effective_date,
              p_group_val_01      => i.group_val_01,
              p_group_val_02      => i.group_val_02,
              p_request_id        => p_request_id,
              p_ext_crit_prfl_id  => p_ext_crit_prfl_id ,
              p_ext_per_bg_id     => l_ext_per_bg_id );

    end Loop ;

  end if ;


--
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
--
--
end process_subtrailer;




-- ----------------------------------------------------------------------------
-- |--------------------< check_all_threads_finished >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_all_threads_finished
  (p_effective_date        in     date
  ,p_business_group_id     in     number
  ,p_data_typ_cd           in     varchar2
  ,p_ext_typ_cd            in     varchar2
  ,p_ext_crit_prfl_id      in     number
  ,p_ext_rslt_id           in     number
  ,p_request_id            in     number
  ,p_ext_file_id           in     number
  ,p_ext_strt_dt           in     date
  ,p_ext_end_dt            in     date
  ,p_master_process_flag   in     varchar2
  ) is
--
  l_proc         varchar2(80);
  l_no_threads           boolean := true;
  l_globals_filled       boolean;
  l_dummy                varchar2(1);
  l_count                binary_integer;
  l_xrs_object_version_number number;
  l_error_cd             hr_lookups.lookup_code%TYPE; -- UTF8 varchar2(80);
--
  cursor c_threads(p_request_id number) is
  select null
  from   fnd_concurrent_requests fnd
  where  fnd.phase_code <> 'C'
  and    fnd.request_id = p_request_id;
--
  cursor get_hdr_cnt is
  select count(*)
  from   ben_ext_rcd_in_file fil, ben_ext_rcd rcd
  where  fil.ext_rcd_id = rcd.ext_rcd_id
  and    fil.ext_file_id = p_ext_file_id
  and    rcd.rcd_type_cd = 'H';
--
  cursor get_trl_cnt is
  select count(*)
  from   ben_ext_rcd_in_file fil, ben_ext_rcd rcd
  where  fil.ext_rcd_id = rcd.ext_rcd_id
  and    fil.ext_file_id = p_ext_file_id
  and    rcd.rcd_type_cd = 'T';
--

  cursor get_subhdr_cnt is
  select count(*)
  from   ben_Ext_rslt_dtl xrd,
         ben_ext_rcd rcd,
         ben_ext_rcd_in_file erf
   where  xrd.ext_rslt_id = p_ext_rslt_id
    and   xrd.ext_rcd_id = erf.ext_rcd_id
    and   xrd.ext_rcd_in_file_id  = erf.ext_rcd_in_file_id
    and   erf.ext_file_id = p_ext_file_id
    and   rcd.ext_rcd_id = erf.ext_rcd_id
    and   erf.hide_flag    = 'N'
   and    rcd.rcd_type_cd = 'S' ;

--

  cursor get_dtl_cnt is
   select count(*)
   from   ben_ext_rslt_dtl xrd , ben_ext_rcd_in_file erf
   where  xrd.ext_rslt_id = p_ext_rslt_id
    and   xrd.ext_rcd_id = erf.ext_rcd_id
    and   xrd.ext_rcd_in_file_id  = erf.ext_rcd_in_file_id
    and   erf.ext_file_id = p_ext_file_id
    and   erf.hide_flag    = 'N'
    and   person_id not in (0, 999999999999) ;

--  select count(*)
--  from   ben_ext_rslt_dtl xrd
--  where  xrd.ext_rslt_id = p_ext_rslt_id;
--
  cursor get_per_cnt is
  select count(distinct person_id)
  from   ben_ext_rslt_dtl xrd
  where  xrd.ext_rslt_id = p_ext_rslt_id
  and    person_id not in (0, 999999999999);
--
  cursor get_err_cnt is
  select count(*)
  from   ben_ext_rslt_err err
  where  err.ext_rslt_id = p_ext_rslt_id;
--
begin
--
  if g_debug then
    l_proc := g_package||'.check_all_threads_finished';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;
--
  if g_num_processes <> 0 then
  --
    while l_no_threads loop
    --
      l_no_threads := false;
      for l_count in 1..g_num_processes loop
      --
        open c_threads(g_processes_rec(l_count));
        fetch c_threads into l_dummy;
        if c_threads%found then
--
-- Slave is still running
--
            l_no_threads := true;
            close c_threads;
            exit;
        end if;
        close c_threads;
        --
      end loop;
      --
      -- To prevent over polling of fnd_concurrent_requests
      -- like all ben batch processes sleep for a while.
      --
      If (l_no_threads) then
        dbms_lock.sleep(5);
      End if;
      --
    end loop;
    --
  end if;
--
-- Log process information
-- This is master specific only
--
  if p_master_process_flag = 'Y' then
--
    open get_dtl_cnt;
    fetch get_dtl_cnt into g_dtl_cnt;
    close get_dtl_cnt;
--
    open get_hdr_cnt;
    fetch get_hdr_cnt into g_hdr_cnt;
    close get_hdr_cnt;
--
    open get_trl_cnt;
    fetch get_trl_cnt into g_trl_cnt;
    close get_trl_cnt;
--

    open get_subhdr_cnt;
    fetch get_subhdr_cnt into g_subhdr_cnt;
    close get_subhdr_cnt;
--
    open get_per_cnt;
    fetch get_per_cnt into g_per_cnt;
    close get_per_cnt;
--
    open get_err_cnt;
    fetch get_err_cnt into g_err_cnt;
    close get_err_cnt;
--
    g_rec_cnt := g_dtl_cnt + g_hdr_cnt + g_trl_cnt + g_subhdr_cnt ;
--
  End if;
--
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
--
end check_all_threads_finished;
--
--
-- =======================================================================
--                          <<do_multithread>>
-- -----------------------------------------------------------------------
-- This is the main batch procedure to be called from the concurrent manager
-- or interactively to start extract.
--
-- ========================================================================
procedure do_multithread
             (errbuf                  out nocopy    varchar2
             ,retcode                 out nocopy    number
             ,p_benefit_action_id     in     number
             ,p_ext_dfn_id            in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
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
             ,p_use_eff_dt_for_chgs_flag in varchar2
             ,p_master_process_flag   in varchar2
             ,p_eff_start_date        in     varchar2
             ,p_eff_end_date          in     varchar2
             ,p_act_start_date        in     varchar2
             ,p_act_end_date          in     varchar2
             ,p_penserv_mode          in     varchar2
             ) is
--
-- Local variable declaration
--
  l_proc                   varchar2(80);
  l_range_id               ben_batch_ranges.range_id%type;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_xrs_object_version_number number;
  l_line                      number := 0;
  l_threads                   number;
  l_chunk_size                number;
  l_effective_date            date;
  l_ext_strt_dt               date;
  l_ext_end_dt                date;
  l_use_eff_dt_for_chgs_flag  ben_ext_dfn.use_eff_dt_for_chgs_flag%TYPE; -- UTF8 varchar2(30);
  l_failure_in_other_thread   boolean := false;
--
-- Cursors declaration
--
  cursor c_range_thread is
  select ran.range_id
  ,ran.starting_person_action_id
  ,ran.ending_person_action_id
  from ben_batch_ranges ran
  where ran.range_status_cd = 'U'
  and ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID
  and rownum < 2
  for update of ran.range_status_cd;
--
  cursor c_range_err is
  select 1
  from ben_batch_ranges ran
  where ran.range_status_cd = 'E'
  and ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID;
--
  l_dummy                     number;
  l_dummy_c                   varchar2(1) ;
  l_status                    integer;
  -- l_value1                    varchar2(20);  Not Used
  -- l_value2                    varchar2(20);  Not Used
  l_commit                    number;
  --
  -- decide the change event source forevery thread
  -- Change event source type
  --
  cursor c_celt(p_type varchar2)  is
    select 'X'
    from   ben_ext_crit_typ xct
           ,ben_Ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.crit_typ_cd  = p_type
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id  ;
  --


Begin
--
   g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'.do_multithread';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;
  g_ext_dfn_id := p_ext_dfn_id;
  g_ext_rslt_id := p_ext_rslt_id;
--
  l_effective_date := to_date(p_effective_date, 'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');
--
--
  l_ext_strt_dt := to_date(p_ext_strt_dt, 'YYYY/MM/DD HH24:MI:SS');
  l_ext_strt_dt := to_date(to_char(trunc(l_ext_strt_dt), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');
--
  l_ext_end_dt := to_date(p_ext_end_dt, 'YYYY/MM/DD HH24:MI:SS');
  l_ext_end_dt := to_date(to_char(trunc(l_ext_end_dt), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');


  g_effective_start_date  := to_date(p_eff_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_effective_start_date  := to_date(to_char(trunc(g_effective_start_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

  g_effective_end_date  := to_date(p_eff_end_date, 'YYYY/MM/DD HH24:MI:SS');
  g_effective_end_date  := to_date(to_char(trunc(g_effective_end_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');



  g_actual_start_date  := to_date(p_act_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_actual_start_date  := to_date(to_char(trunc(g_actual_start_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

  g_actual_end_date  := to_date(p_act_end_date, 'YYYY/MM/DD HH24:MI:SS');
  g_actual_end_date  := to_date(to_char(trunc(g_actual_end_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');


--
-- load the fnd_session table in case a rule dbi needs it.
--
  dt_fndate.change_ses_date
    (p_ses_date => l_effective_date,
     p_commit => l_commit);
--
  l_line := 2;
--
  benutils.get_parameter
  (p_business_group_id => p_business_group_id
  ,p_batch_exe_cd => 'BENXTRCT'
  ,p_threads => l_threads
  ,p_chunk_size => l_chunk_size
  ,p_max_errors => g_max_errors_allowed);
--
  --
  -- MH moved call to thread level (ben_ext_thread.do_multithread)
  -- rather than chunk level to minimize
  -- memory consumption
  --
  -- Determine extract Levels
  --
  ben_extract.set_ext_lvls
    (p_ext_file_id         => p_ext_file_id
    ,p_business_group_id   => p_business_group_id
    );
  --
  -- Setup record and required level tables
  --
  ben_extract.setup_rcd_typ_lvl
    (p_ext_file_id => p_ext_file_id
    );

  --
  -- decide the source for the change event from the change event log
  g_chg_ext_from_ben      := 'N' ;
  g_chg_ext_from_pay      := 'N' ;

  if p_data_typ_cd = 'C' and p_ext_crit_prfl_id  is not null then
     open c_celt ('CPE') ;
     fetch c_celt into  l_dummy_c ;
     if c_celt%found then
        g_chg_ext_from_pay      := 'Y' ;
     else
        g_chg_ext_from_ben      := 'Y' ;
     end if ;
     close c_celt ;

     open c_celt ('CCE') ;
     fetch c_celt into  l_dummy_c ;
     if c_celt%found then
        g_chg_ext_from_ben      := 'Y' ;
     end if ;
     close c_celt ;

     hr_utility.set_location (' thread CELT ben/pay ' || g_chg_ext_from_ben || ' / ' || g_chg_ext_from_pay, 99 ) ;
  end if ;
  --

  --
  Loop
--
    open c_range_err;
    fetch c_range_err into l_dummy;
    if c_range_err%found then
      l_failure_in_other_thread    := TRUE;
      close c_range_err;
      exit;
    end if;
    close c_range_err;
--
    open c_range_thread;
    fetch c_range_thread
         into l_range_id,l_start_person_action_id,l_end_person_action_id;
    Exit when c_range_thread%notfound;
    --RCHASE 115.59 - move update within cursor context.
--
  l_line := 3;
--
      update ben_batch_ranges ran set ran.range_status_cd = 'P'
      where ran.range_id = l_range_id;
--
      commit;
--
    close c_range_thread;
--
  l_line := 4;
--
    ben_extract.Xtrct_skltn
   (p_ext_dfn_id => p_ext_dfn_id
   ,p_business_group_id => p_business_group_id
   ,p_effective_date => l_effective_date
   ,p_benefit_action_id => p_benefit_action_id
   ,p_range_id => l_range_id
   ,p_start_person_action_id => l_start_person_action_id
   ,p_end_person_action_id => l_end_person_action_id
   ,p_data_typ_cd        => p_data_typ_cd
   ,p_ext_typ_cd         => p_ext_typ_cd
   ,p_ext_crit_prfl_id   => p_ext_crit_prfl_id
   ,p_ext_rslt_id        => p_ext_rslt_id
   ,p_ext_file_id        => p_ext_file_id
   ,p_ext_strt_dt        => l_ext_strt_dt
   ,p_ext_end_dt         => l_ext_end_dt
   ,p_prmy_sort_cd       => p_prmy_sort_cd
   ,p_scnd_sort_cd       => p_scnd_sort_cd
   ,p_request_id         => p_request_id
   ,p_use_eff_dt_for_chgs_flag => p_use_eff_dt_for_chgs_flag
   ,p_penserv_mode       => p_penserv_mode              ---- vkodedal changes for penserver 30-Apr-2008
   );
--
  l_line := 5;
--
  End loop;
--
  l_line := 6;
--
 -- halt all other threads when job failure.
  if l_failure_in_other_thread then
     ben_ext_thread.g_err_num := 92184;
     ben_ext_thread.g_err_name := 'BEN_92184_THREAD_HALTED';
     raise g_job_failure_error;
  end if;
--
  l_line := 7;
--
  if fnd_global.conc_request_id <> -1 then
    fnd_message.set_name('BEN', 'BEN_92190_THREAD_LABEL');
    fnd_file.put_line(fnd_file.log, fnd_message.get || ' ' ||to_char(p_thread_id));
    fnd_file.put_line(fnd_file.log, ' ');
    if p_master_process_flag <> 'Y' then
      fnd_message.set_name('BEN', 'BEN_92185_THREAD_SUCCESS');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.put_line(fnd_file.log, ' ');
    end if;
  end if;
--
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
--
Exception
--
  when g_job_failure_error then
  --
  --  this will halt all other threads.
  update ben_batch_ranges
    set range_status_cd = 'E'
    where range_id = l_range_id;
  --
  --  write to the extract error table, so error will be reported
  --  on the error report and viewed on the extract result form.
  if ben_ext_thread.g_err_num <> 92184 then  --don't write if halt warning.
    write_error(p_err_num           => ben_ext_thread.g_err_num,
                p_err_name          => null , --ben_ext_thread.g_err_name,
                p_typ_cd            => 'F',
                p_person_id         => null,
                p_request_id        => p_request_id,
                p_ext_rslt_id       => p_ext_rslt_id,
                p_business_group_id => p_business_group_id
               );
    commit;
  end if;
  --
  if fnd_global.conc_request_id <> -1 then
    --
    --  write end of thread statistics which shows totals of what was
    --  processed
    fnd_message.set_name('BEN', 'BEN_92190_THREAD_LABEL');
    fnd_file.put_line(fnd_file.log, fnd_message.get || ' ' ||to_char(p_thread_id));
    --
    --  write the error message to the log file.
    --
    if ben_ext_thread.g_err_num <> 92184 then
      fnd_message.set_name('BEN', 'BEN_92186_THREAD_FAILURE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_file.put_line(fnd_file.log, ' ');
    end if;
    fnd_message.set_name('BEN', ben_ext_thread.g_err_name);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    --
    --  if slave process, we are done.  If master process, raise job failure in
    --  calling program (ben_ext_thread.process)
    --
  end if;
  --
  if p_master_process_flag = 'Y' then
    raise;
  else -- slave
    fnd_message.raise_error;
  end if;


  when others then
  --
  --  this will halt all other threads.
  --
    update ben_batch_ranges
    set range_status_cd = 'E'
    where range_id = l_range_id;
  --
    fnd_message.set_name('BEN', 'BEN_92190_THREAD_LABEL');
    fnd_file.put_line(fnd_file.log, fnd_message.get || ' ' ||to_char(p_thread_id));
  --  if slave process, we are done.  If master process, raise job failure in
  --  calling program (ben_ext_thread.process)
  --
    if p_master_process_flag = 'Y' then
      raise;
    else  -- slave
      write_error(p_err_num           => null,
                p_err_name          => substr(sqlerrm, 1, 200),
                p_typ_cd            => 'F',
                p_person_id         => null,
                p_request_id        => p_request_id,
                p_ext_rslt_id       => p_ext_rslt_id,
                p_business_group_id => p_business_group_id
               );
      --
      commit;
      --
      if fnd_global.conc_request_id <> -1 then
        fnd_message.set_name('BEN', 'BEN_92186_THREAD_FAILURE');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.put_line(fnd_file.log, ' ');
        fnd_message.set_name('PER', 'FFU10_GENERAL_ORACLE_ERROR');
        fnd_message.set_token('2', substr(sqlerrm, 1, 200));
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_message.raise_error;
      end if;
      --
    end if;
--
end do_multithread;
--
-- =======================================================================
--                          <<Procedure:Initialize_Globals>>
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- This is procedure initializes all globals in the pkh.
-- ========================================================================
--
procedure initialize_globals is
--
--
-- Local variable declaration
--
  l_proc                   varchar2(80);
--
begin
--
  if g_debug then
    l_proc := g_package||'.initialize_globals';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;
--
  for i in 1..g_processes_rec.count loop
    if g_processes_rec.exists(i) then
      g_processes_rec(i) := null;
    end if;
  end loop;
--
  g_max_errors_allowed := 0;
  g_num_processes := 0;
  g_err_name := null;
  g_err_num := null;
  g_ext_strt_dt := null;
  g_ext_end_dt := null;
  g_err_cnt := 0;
  g_per_cnt := 0;
  g_rec_cnt := 0;
  g_dtl_cnt := 0;
  g_hdr_cnt := 0;
  g_trl_cnt := 0;
  g_subhdr_cnt := 0;
  g_subtrl_cnt := 0;
--
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
--
end initialize_globals;
-- =======================================================================
--                          <<Procedure:Thread_Summary>>
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- This is procedure logs the status of all threads in the master's log file.
-- ========================================================================
--
procedure thread_summary is
--
  l_proc                   varchar2(80);
  l_text varchar2(70);
--
begin
--
  if g_debug then
    l_proc := g_package||'.thread_summary';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;
--
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_message.set_name('BEN', 'BEN_92191_ALL_THREAD_LABEL');
  fnd_file.put_line(fnd_file.log, fnd_message.get);
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_message.set_name('BEN', 'BEN_92192_EXT_STATS_LABEL');
  fnd_file.put_line(fnd_file.log, fnd_message.get);
  fnd_message.set_name('BEN', 'BEN_91956_EXT_TOT_REC');
  fnd_file.put_line(fnd_file.log, '  ' || fnd_message.get || ' ' || to_char(g_rec_cnt));
--
  fnd_message.set_name('BEN', 'BEN_91957_EXT_TOT_PER');
  fnd_file.put_line(fnd_file.log, '  ' || fnd_message.get || ' ' || to_char(g_per_cnt));
--
  fnd_message.set_name('BEN', 'BEN_91958_EXT_TOT_ERR');
  fnd_file.put_line(fnd_file.log, '  ' || fnd_message.get || '  ' || to_char(g_err_cnt));
--
  fnd_file.put_line(fnd_file.log, ' ');
--
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
--
end thread_summary;


----


Procedure build_adv_criteria(
                      p_ext_crit_prfl_id   in     number default null,
                      p_ext_dfn_id         in     number,
                      p_business_group_id  in     number,
                      p_effective_date     in     date,
                      p_source             in     varchar2 default 'BEN' ,
                      p_select_statement   in out nocopy long) is

 l_proc                   varchar2(80);
 l_text varchar2(70);
 --
 cursor c1 is
 select ecv.ext_crit_val_id
 from ben_ext_crit_typ ect, ben_ext_crit_val ecv
 where ect.crit_typ_cd = 'ADV'
 and ect.ext_crit_typ_id = ecv.ext_crit_typ_id
 and ect.ext_crit_prfl_id = p_ext_crit_prfl_id
 ;



 cursor c2 (p_ext_crit_val_id number) is
 select ecc.crit_typ_cd,
       ecc.oper_cd,
       ecc.val_1,
       ecc.val_2
 from ben_ext_crit_cmbn ecc
 where  ecc.ext_crit_val_id = p_ext_crit_val_id
 ;

 l_sql_string long  ;
 l_first_time varchar2(1) ;
 l_first_val  varchar2(1) ;
 l_prev_first_val   varchar2(1) ;
 l_from_date  date ;
 l_to_date    date ;

begin
--
  if g_debug then
    l_proc := g_package||'.build_adv_criteria';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;

  l_sql_string := ''  ;
  l_first_time := 'Y' ;
  l_first_val  := 'Y' ;
  l_prev_first_val  := 'Y' ;

  if  p_ext_crit_prfl_id is not null then
      -- curosr on combination criteria type
      for i in c1
      Loop

         l_first_val  := 'Y' ;
          -- curosr on combination criteria value  type
         for k in  c2(i.ext_crit_val_id)
         Loop
             -- whne we switch to different criteria type
             -- add ( or ) 'or' condition a
             if l_prev_first_val <> 'Y' and l_first_val = 'Y' then
                l_sql_string := l_sql_string || ') OR ( ' ;
             else
                --- starting for the valu set
                if l_first_val = 'Y' then
                   l_sql_string := l_sql_string || ' ( ' ;
                else
                   l_sql_string := l_sql_string || ' AND  ' ;
                end if ;

             end if;
             -- eof variable manpulation
             -- bof set the variable values
             l_first_val  := 'N' ;
             l_first_time := 'N' ;
             -- eof set the variable values


             -- bof get the values from
             if k.crit_typ_cd in ('CAD','CED') then
                if k.crit_typ_cd  = 'CAD' then
                   if p_source = 'PAY' then
                         l_sql_string := l_sql_string || 'xcl.CREATION_DATE ' ;
                   elsif p_source = 'BEN' then
                         l_sql_string := l_sql_string || 'xcl.CHG_ACTL_DT ' ;
                   end if ;
                elsif  k.crit_typ_cd  = 'CED' then
                   if p_source = 'PAY' then
                      l_sql_string := l_sql_string || 'xcl.EFFECTIVE_DATE ' ;
                   elsif p_source = 'BEN' then
                      l_sql_string := l_sql_string || ' xcl.CHG_EFF_DT ' ;
                   end if ;
                end if ;
                -- determne the from date
                l_from_date  := ben_ext_util.calc_ext_date
                                                (p_ext_date_cd => k.val_1,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);

                if k.oper_cd = 'EQ' then
                   if k.crit_typ_cd  = 'CED' then
                         l_sql_string := l_sql_string ||' =  to_date('''||
                                to_char(l_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')';

                   Else
                       l_sql_string := l_sql_string|| ' BETWEEN '
                                                   ||'to_date('''||to_char(l_from_date,'DD-MM-RRRR HH24:MI:SS')
                                                   ||''',''DD-MM-RRRR HH24:MI:SS'')'
                                                   ||' AND '
                                                   ||'to_date('''||to_char(l_from_date+0.99999,'DD-MM-RRRR HH24:MI:SS')
                                                   ||''',''DD-MM-RRRR HH24:MI:SS'')';
                   End if ;
                elsif k.oper_cd = 'NE' then
                   if k.crit_typ_cd  = 'CED' then
                         l_sql_string := l_sql_string ||'<>  to_date('''||
                                to_char(l_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')';

                   Else
                       l_sql_string := l_sql_string|| ' NOT BETWEEN '
                                                   ||'to_date('''||to_char(l_from_date,'DD-MM-RRRR HH24:MI:SS')
                                                   ||''',''DD-MM-RRRR'')'
                                                   ||' AND '
                                                   ||'to_date('''||to_char(l_from_date+0.99999,'DD-MM-RRRR HH24:MI:SS')
                                                   ||''',''DD-MM-RRRR HH24:MI:SS'')';
                   end if;

                elsif k.oper_cd = 'BE' then
                   l_to_date  := ben_ext_util.calc_ext_date
                                                (p_ext_date_cd => k.val_2,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);
                   if k.crit_typ_cd  = 'CAD' then

                       l_sql_string := l_sql_string|| ' BETWEEN '
                                                   ||'to_date('''||to_char(l_from_date,'DD-MM-RRRR HH24:MI:SS')
                                                   ||''',''DD-MM-RRRR HH24:MI:SS'')'
                                                   ||' AND '
                                                   ||'to_date('''||to_char(l_to_date+0.99999,'DD-MM-RRRR HH24:MI:SS')
                                                   ||''',''DD-MM-RRRR HH24:MI:SS'')';
                   else
                       l_sql_string := l_sql_string|| ' BETWEEN '
                                                   ||'to_date('''||to_char(l_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')'
                                                   ||' AND '
                                                   || 'to_date('''||to_char(l_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')';
                    end if ;

                 end if ;
             elsif  k.crit_typ_cd  = 'CCE' then
                      -- if this is ben change event get value else  so dont do anything
                 if p_source = 'BEN' then
                    l_sql_string := l_sql_string || ' xcl.chg_evt_cd ' ;
                    if k.oper_cd = 'EQ' then
                       l_sql_string := l_sql_string || ' = ''' || k.val_1 || '''' ;
                    elsif k.oper_cd = 'NE' then
                       l_sql_string := l_sql_string || ' <> '''|| k.val_1  ||'''' ;
                    end if ;
                 else
                    l_sql_string := l_sql_string || ' TRUE' ;
                 end if ;
             elsif  k.crit_typ_cd  = 'CPE' then
                      -- now we are not complicating the sql , this will be
                      -- taken care in evaluation part so do nothing
                      l_sql_string := l_sql_string || ' TRUE' ;
             end if ;

         end Loop ;

         -- set the previous value
         l_prev_first_val  := l_first_val ;


      end Loop ;

  end if ;


  if l_first_time = 'Y' then
     l_sql_string := null ;
  else
     l_sql_string := '( ' || l_sql_string || ' ) ) ' ;
  end if ;

  p_select_statement := l_sql_string ;

 if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;

end ;



Procedure chck_non_asg_pay_evt(
                      p_ext_crit_prfl_id    in  number ,
                      p_ext_dfn_id         in     number,
                      p_business_group_id  in     number,
                      p_effective_date     in     date,
                      p_effective_from_date in  date default null,
                      p_effective_to_date   in  date default null,
                      p_actual_from_date    in  date default null,
                      p_actual_to_date      in  date default null,
                      p_adv_crit_exist      in  varchar2 default null,
                      p_result              out nocopy  varchar2 ) is

 l_proc                   varchar2(80);
 l_text varchar2(70);


 cursor c_non_asg_crit is
 select 'X'
 from ben_ext_crit_typ ect
     ,ben_ext_crit_val ecv
     ,pay_datetracked_events pde
     ,pay_dated_tables pdt
  where ect.ext_crit_prfl_id = p_ext_crit_prfl_id
    and ect.crit_typ_cd = 'CPE'
    and ecv.ext_crit_typ_id = ect.ext_crit_typ_id
    and pde.event_group_id = to_number(ecv.val_1)
    and pde.dated_table_id = pdt.dated_table_id
    and pdt.TABLE_NAME in ( 'PAY_LINK_INPUT_VALUES_F'
                           ,'PAY_ELEMENT_LINKS_F'
                           ,'PAY_INPUT_VALUES_F'
                           ,'PAY_ALL_PAYROLLS_F'
                           ,'PAY_ELEMENT_TYPES_F'
                           ,'PAY_GRADE_RULES_F'
                           ,'PAY_USER_COLUMN_INSTANCES_F'
                           ,'FF_GLOBALS_F'
                           )
   ;



 cursor c_non_asg_tabel_id is
 select pde.dated_table_id,pde.business_group_id ,pde.LEGISLATION_CODE,pde.update_type
 from ben_ext_crit_typ ect
     ,ben_ext_crit_val ecv
     ,pay_datetracked_events pde
     ,pay_dated_tables pdt
  where ect.ext_crit_prfl_id = p_ext_crit_prfl_id
    and ect.crit_typ_cd = 'CPE'
    and ecv.ext_crit_typ_id = ect.ext_crit_typ_id
    and pde.event_group_id = to_number(ecv.val_1)
    and pde.dated_table_id = pdt.dated_table_id
    and pdt.TABLE_NAME in ( 'PAY_LINK_INPUT_VALUES_F'
                           ,'PAY_ELEMENT_LINKS_F'
                           ,'PAY_INPUT_VALUES_F'
                           ,'PAY_ALL_PAYROLLS_F'
                           ,'PAY_ELEMENT_TYPES_F'
                           ,'PAY_GRADE_RULES_F'
                           ,'PAY_USER_COLUMN_INSTANCES_F'
                           ,'FF_GLOBALS_F'
                           )
   ;

 l_result   varchar2(1) ;
 l_dummy    varchar2(1) ;
 l_dated_table_id pay_dated_tables.dated_table_id%type ;
 l_update_type varchar2(10) ;
 l_legislation_code varchar2(35) ;
 l_sql  varchar2(4000) ;
 l_adv_sql  varchar2(4000) ;
 l_column_name varchar2(35) ;


 TYPE nonasgevt is REF CURSOR;
  --
 c_nonasgevt     nonasgevt;


Begin


  --
  if g_debug then
    l_proc := g_package||'.chck_non_asg_pay_evt';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;


    hr_utility.set_location ('actual date  '||p_actual_from_date ,5);
    hr_utility.set_location ('actual date  '||p_actual_to_date  ,5);
    hr_utility.set_location ('effect date  '||p_effective_from_date ,5);
    hr_utility.set_location ('effect date  '||p_effective_to_date  ,5);
    hr_utility.set_location ('adv cond   '||p_adv_crit_exist  ,5);


  l_result  := 'N' ;
  p_result  := 'N' ;
  open c_non_asg_crit ;
  fetch c_non_asg_crit into l_dummy ;
  IF c_non_asg_crit%notfound then
    -- when there is criteria with non asg table
    -- do not process further
    close c_non_asg_crit ;
    hr_utility.set_location ('Exiting no criteria found '||l_proc,10);
    Return ;
  End if ;
  close c_non_asg_crit ;

  -- when there is a event group with non asg table
  -- check there is any event on that dates

  for i  in c_non_asg_tabel_id
  Loop

     l_sql :=  ' Select ''X''  From pay_event_updates peu ' ||
               ' where  peu.dated_table_id = '|| i.dated_table_id ||
               ' and peu.event_type  = '''|| i.update_type || '''' ;

     if p_business_group_id is not null then
        l_sql:=l_sql||' and (peu.business_group_id is null or peu.business_group_id ='||p_business_group_id ||')' ;
     end if ;

        if i.legislation_code is not null then
           l_sql := l_sql ||' and peu.legislation_code = ''' || i.legislation_code || ''''  ;
        end if ;

        l_sql := l_sql ||
               ' and  exists ( ' ||
               '  Select xcl.process_event_id from pay_process_events xcl' ||
               '  where  xcl.event_update_id = peu.event_update_id' ||
                  --- if the event created for a bg then validate the bg with  extract bg
               '    and (peu.business_group_id is null or xcl.business_group_id = peu.business_group_id)';

     -- if the event group define for a bg then validate the bg with event
     if i.business_group_id is not null then
        l_sql := l_sql ||  ' and xcl.business_group_id  = ' ||  i.business_group_id   ;
     else
        if p_business_group_id is not null then
          l_sql:=l_sql||'and  xcl.business_group_id ='||p_business_group_id ;
        end if ;
     end if ;

     if p_actual_to_date  is not  null then
        l_sql := l_sql || ' and xcl.creation_date between  to_date(''' ||
                  to_char(p_actual_from_date,'DD-MM-RRRR HH24:MI:SS')|| ''',''DD-MM-RRRR HH24:MI:SS'') and to_date('''||
                  to_char(p_actual_to_date+0.99999,'DD-MM-RRRR HH24:MI:SS')  || ''',''DD-MM-RRRR HH24:MI:SS'') ';
     end if ;

      if p_effective_to_date  is not  null then
        l_sql := l_sql || ' and xcl.effective_date between  to_date(''' ||
                  to_char(p_effective_from_date,'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
                  to_char(p_effective_to_date,'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
     end if ;

     if p_adv_crit_exist = 'Y' then


         build_adv_criteria(
                       p_ext_crit_prfl_id   => p_ext_crit_prfl_id ,
                       p_ext_dfn_id         => p_ext_dfn_id,
                       p_business_group_id  => p_business_group_id,
                       p_effective_date     => p_effective_date,
                       p_source             => 'PAY' ,
                       p_select_statement   => l_ADV_sql) ;
       if l_ADV_sql is not null then

          l_sql := l_sql || ' AND ' || l_adv_sql ;
       end if ;

    end if ;

    l_sql := l_sql || ' )  ' ;



    --- Process the cursor
    begin
      open c_nonasgevt for l_sql ;
    exception
    --
    when others then
           --
         fnd_file.put_line(fnd_file.log,'Error executing this dynamically build payroll event SQL Statement:');
    end;
    --
    fetch c_nonasgevt into l_dummy ;
    if  c_nonasgevt%found then
        close c_nonasgevt ;
        l_result := 'Y' ;
        exit ;
    end if ;
    close c_nonasgevt ;
         --

 End Loop ;

  hr_utility.set_location ('Non Asg Pay event found  '||l_result,15);
  p_result := l_result ;
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;


End chck_non_asg_pay_evt ;


----

Procedure get_ext_crit_string(p_ext_crit_prfl_id in number ,
                              p_ext_crit_typ     in varchar2,
                              p_ext_num_str      in varchar2 default 'N' ,
                              p_string           out nocopy varchar2 ) is


l_proc                   varchar2(80);
cursor c_crit_all is
    select xcv.val_1
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = p_ext_crit_typ;

  l_crit_all varchar2(4000) ;
  l_first_time varchar2(1) ;


Begin
   if g_debug then
    l_proc := g_package||'.get_ext_crit_string';
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;

  l_crit_all := '' ;
  l_first_time := 'Y' ;

  for i in  c_crit_all
  Loop

     if l_first_time = 'N' then
        l_crit_all := l_crit_all || ',' ;
     end if ;

     if p_ext_num_str = 'S' then
        l_crit_all := l_crit_all || '''' ;
     end if ;

     l_crit_all := l_crit_all || ltrim(rtrim(i.val_1))  ;
     if p_ext_num_str = 'S' then
        l_crit_all := l_crit_all || '''' ;
     end if ;

     l_first_time := 'N' ;

  End Loop ;

  if l_first_time = 'N'  then
     p_string :=  '(' || l_crit_all  || ')' ;
  end if ;

  hr_utility.set_location ('Exiting '||l_proc,15);
End get_ext_crit_string ;



-- =======================================================================
--                    <<Procedure:Build_Select_Statement>>
-- -----------------------------------------------------------------------
-- This procedure was added for performance improvements to filter as much
-- data as possible up front using the criteria profiles.  It probably can
-- be expanded to include more criteria such as state and zip code.  The
-- sql statement is build dynamically, and used in an open statement in the
-- calling program.
--
Procedure build_select_statement
                     (p_data_typ_cd        in     varchar2,
                      p_ext_crit_prfl_id   in     number default null,
                      p_ext_dfn_id         in     number,
                      p_business_group_id  in     number,
                      p_effective_date     in     date,
                      p_ext_rslt_id        in     number ,
                      p_ext_global_flag    in     varchar2 default null,
                      p_eff_start_date     in     date default null,
                      p_eff_end_date       in     date default null,
                      p_act_start_date     in     date default null,
                      p_act_end_date       in     date default null,
                      p_select_statement   in out nocopy long,
                      p_penserv_date       in     date default null) is
  --
  l_dynamic_sql long;
  l_dynamic_pay_sql long;
  l_dynamic_ben_sql long;
  l_dynamic_adv_sql long;
  l_pay_spl_process varchar2(1) ;


 -- For Pensrv

  l_pen_config_values pqp_utilities.t_config_values;

  l_pen_membership_col     VARCHAR2(20);
  l_pen_membership_context VARCHAR2(80);

  --
  -- Full Name/Person ID
  --
  cursor c_pid is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PID';
  --
  l_pid_exists varchar2(1) := 'N';
  l_pid_exclude varchar2(1);
  --
  -- Assignment Organization
  --
  cursor c_por is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'POR';
  --
  l_por_exists varchar2(1) := 'N';
  l_por_exclude varchar2(1);
  --
  -- Assignment Status
  --
  cursor c_pas is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PAS';
  --
  l_pas_exists varchar2(1) := 'N';
  l_pas_exclude varchar2(1);
  --

  -- Assignment Location
  --
  cursor c_plo is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PLO';
  --
  l_plo_exists varchar2(1) := 'N';
  l_plo_exclude varchar2(1);
  --
  -- Person Benefits Group
  --
  cursor c_pbg is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PBG';
  --
  l_pbg_exists varchar2(1) := 'N';
  l_pbg_exclude varchar2(1);
  --

   -- Person business_grp Group
  --
  cursor c_pbgr is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PBGR';
  --
  l_pbgr_exists varchar2(1) := 'N';
  l_pbgr_exclude varchar2(1);
  --

  -- person type usage

  cursor c_ppt is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PPT';
  --
  l_ppt_exists varchar2(1) := 'N';
  l_ppt_exclude varchar2(1);
  --



  l_Source_dummy varchar2(1) ;

  -- Change Event Name
  --
  cursor c_cce is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct
           ,ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'CCE';
  --
  l_cce_exists varchar2(1) := 'N';
  l_cce_exclude varchar2(1);


cursor c_cpe is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct
           ,ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'CPE';

  l_cpe_exists varchar2(1) := 'N';
  l_cpe_exclude varchar2(1);



  --
  -- Change Actual Date
  --
  cursor c_cad is
    Select 'Y',
           xct.excld_flag,
           xcv.val_1,
           xcv.val_2
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'CAD';

  l_cad_exists varchar2(1) := 'N';
  l_cad_exclude varchar2(1);
  l_cad_val1 ben_ext_crit_val.val_1%type ;
  l_cad_val2 ben_ext_crit_val.val_2%type ;
  l_cad_date_from date;
  l_cad_date_to date;
  --  person data link

   cursor c_pdl is
    Select 'Y',
           xct.excld_flag,
           xcv.val_1
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PDL';

  l_pdl_exists varchar2(1) := 'N';
  l_pdl_exclude varchar2(1);
  l_pdl_val1 ben_ext_crit_val.val_1%type ;

  --  CWB
   cursor c_wplr is
   select 'Y',
           xct.excld_flag ,
           xct.EXT_CRIT_TYP_ID
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'WPLPR';
  --
  l_wplr_exists   varchar2(1) := 'N';
  l_wplr_exclude  varchar2(1);
  l_wlpr_EXT_CRIT_TYP_ID  number ;


  -- person Assignment_set   PASGSET


   cursor c_pasgset  is
    Select 'Y',
           xct.excld_flag,
           xcv.val_1
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'PASGSET';

  l_pasgset_exists varchar2(1) := 'N';
  l_pasgset_exclude varchar2(1);
  l_pasgset_val1 ben_ext_crit_val.val_1%type ;





  --
  -- Change Effective Date
  --
  cursor c_ced is
    select 'Y',
           xct.excld_flag,
           xcv.val_1,
           xcv.val_2
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'CED';
  --
  l_ced_exists varchar2(1) := 'N';
  l_ced_exclude varchar2(1);
  l_ced_val1 ben_ext_crit_val.val_1%type;
  l_ced_val2 ben_ext_crit_val.val_2%type;
  l_ced_date_from date;
  l_ced_date_to date;
  --



  -- Communication Type
  --
  cursor c_mtp is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'MTP';
  --
  l_mtp_exists varchar2(1) := 'N';
  l_mtp_exclude varchar2(1);
  --
  -- Communication To Be Sent Date
  --
  cursor c_mtbsdt is
    select 'Y',
           xct.excld_flag,
           xcv.val_1,
           xcv.val_2
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'MTBSDT';
  --
  l_mtbsdt_exists varchar2(1) := 'N';
  l_mtbsdt_exclude varchar2(1);
  l_mtbsdt_val1 ben_ext_crit_val.val_1%type;
  l_mtbsdt_val2 ben_ext_crit_val.val_2%type;
  l_mtbsdt_date_from date;
  l_mtbsdt_date_to date;

  --
  cursor c_adv is
    Select 'Y'
    from   ben_ext_crit_typ xct
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.crit_typ_cd = 'ADV';
  --
  l_adv_exists varchar2(1) := 'N';

  -- Communication Sent Date
  --
  cursor c_msdt is
    Select 'Y',
           xct.excld_flag,
           xcv.val_1,
           xcv.val_2
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'MSDT';
  --
  l_msdt_exists varchar2(1) := 'N';
  l_msdt_exclude varchar2(1);
  l_msdt_val1 ben_ext_crit_val.val_1%type;
  l_msdt_val2 ben_ext_crit_val.val_2%type;
  l_msdt_date_from date;
  l_msdt_date_to date;

  -- Person payroll id
  cursor c_rrl is
    select 'Y',
           xct.excld_flag
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'RRL';
  --
  l_rrl_exists varchar2(1) := 'N';
  l_rrl_exclude varchar2(1);

  --For Penserver 115.70
  -- Cursor to check for PQP Earnings Extract
    cursor c_pen_ern is
    select bed.ext_dfn_id
      from ben_ext_dfn bed
     where bed.name = 'PQP GB PenServer Standard Interface - Earnings History';
  --
  l_pen_ext_dfn_id number;

  --
  l_pay_evt_non_asg   varchar2(1) ;
  l_crit_val_all  varchar2(4000) ;
  --
begin
  --
  open c_pid;
    fetch c_pid into l_pid_exists, l_pid_exclude;
  close c_pid;
  --
  open c_por;
    fetch c_por into l_por_exists, l_por_exclude;
  close c_por;
  --
  open c_pas;
    fetch c_pas into l_pas_exists, l_pas_exclude;
  close c_pas;
  --
  open c_plo;
    fetch c_plo into l_plo_exists, l_plo_exclude;
  close c_plo;
  --
  open c_pbg;
    fetch c_pbg into l_pbg_exists, l_pbg_exclude;
  close c_pbg;
  -- person business group
  open c_pbgr;
    fetch c_pbgr into l_pbgr_exists, l_pbgr_exclude;
  close c_pbgr;

  -- person type usage
  open c_ppt;
  fetch c_ppt into l_ppt_exists, l_ppt_exclude;
  close c_ppt;
  --
  open c_cpe;
  fetch c_cpe into l_cpe_exists, l_cpe_exclude;
  if c_cpe%found then
     g_chg_ext_from_pay := 'Y' ;
  else
     g_chg_ext_from_ben := 'Y' ;
  end if ;
  close c_cpe;


  open c_cce;
  fetch c_cce into l_cce_exists, l_cce_exclude;
  if c_cce%found then
      g_chg_ext_from_ben := 'Y' ;
  end if ;
  close c_cce;

  -- person payroll
  open c_rrl;
  fetch c_rrl into l_rrl_exists, l_rrl_exclude;
  close c_rrl;


  hr_utility.set_location( 'CELT exist ' || g_chg_ext_from_ben || ' / ' || g_chg_ext_from_pay , 99 ) ;

  -- cwb

  open c_wplr;
  fetch c_wplr into l_wplr_exists, l_wplr_exclude, l_wlpr_EXT_CRIT_TYP_ID ;
  close c_wplr;

  -- when the date param is passes used the data param
  if p_act_start_date is not null and p_act_end_date is not null then
     l_cad_exists  := 'Y'  ;
     l_cad_exclude := 'N' ;
     l_cad_val1    := to_char(p_act_start_date , 'MM/DD/RRRR') ;
     l_cad_val2    := to_char(p_act_end_date , 'MM/DD/RRRR') ;
  else
     open c_cad;
     fetch c_cad into l_cad_exists, l_cad_exclude, l_cad_val1, l_cad_val2;
     close c_cad;
  end if ;
  --
  open c_pdl;
  fetch c_pdl into l_pdl_exists, l_pdl_exclude, l_pdl_val1;
  close c_pdl;



  --- Assignment set
  open c_pasgset;
  fetch c_pasgset  into l_pasgset_exists, l_pasgset_exclude, l_pasgset_val1;
  close c_pasgset ;



  -- when the date param is passes used the data param
  if p_eff_start_date is not null and p_eff_end_date is not null then
     l_ced_exists  := 'Y'  ;
     l_ced_exclude := 'N' ;
     l_ced_val1    := to_char(p_eff_start_date , 'MM/DD/RRRR') ;
     l_ced_val2    := to_char(p_eff_end_date , 'MM/DD/RRRR') ;
  else
    open c_ced;
      fetch c_ced into l_ced_exists, l_ced_exclude, l_ced_val1, l_ced_val2;
    close c_ced;
 end if ;
 --


 if g_chg_ext_from_pay = 'Y' and  ( l_cpe_exclude = 'Y' or  l_cad_exclude = 'Y' or l_ced_exclude = 'Y' ) then
    -- with payroll cahnge event exclude criteria on Event groups or Effective date or Actaul date is not allowed

    ben_ext_thread.g_err_num := 94264;
    ben_ext_thread.g_err_name := 'BEN_94264_EXT_PAY_CHG_EXCLD';
    raise g_job_failure_error;
 end if ;





  open c_mtp;
    fetch c_mtp into l_mtp_exists, l_mtp_exclude;
  close c_mtp;
  --
  open c_mtbsdt;
    fetch c_mtbsdt into l_mtbsdt_exists, l_mtbsdt_exclude, l_mtbsdt_val1, l_mtbsdt_val2;
  close c_mtbsdt;
  --
  open c_msdt;
    fetch c_msdt into l_msdt_exists, l_msdt_exclude, l_msdt_val1, l_msdt_val2;
  close c_msdt;
   -- ADV
  open c_adv ;
  fetch c_adv into l_adv_exists ;
  close c_adv ;


  --
  if p_data_typ_cd in ('F') then
     -- For Penserver 115.70
     IF p_penserv_date is not null
     THEN
        -- check if the current processed extract is Earnings
	  OPEN c_pen_ern;
        FETCH c_pen_ern into l_pen_ext_dfn_id;
        CLOSE c_pen_ern;

        IF l_pen_ext_dfn_id = p_ext_dfn_id
        THEN
           l_dynamic_sql :=
            '  SELECT distinct(per.person_id)  person_id ' ||
            '    FROM per_all_assignments_f ben_asg ' ||
            '         ,per_periods_of_service ppos ' ||
            '         ,per_all_people_f per ' ||
            '   WHERE per.person_id =  ben_asg.person_id (+) ' ||
            '     AND ben_asg.period_of_service_id = ppos.period_of_service_id ' ||
            '     AND ((ppos.actual_termination_date is NULL) ' ||
            '           OR ' ||
            '           (ppos.actual_termination_date >= to_date('''||to_char((add_months(p_effective_date,-1) + 1) ,'DD/MM/YYYY') ||''',''DD/MM/YYYY''))' ||
            '           OR ' ||
            '           ((ppos.actual_termination_date < to_date('''||to_char((add_months(p_effective_date,-1) + 1) ,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') '||
            '             AND EXISTS (SELECT 1 ' ||
            '                           FROM pay_assignment_actions paa ' ||
            '                                ,pay_run_results prr ' ||
            '                                ,pay_payroll_actions ppa ' ||
            '                          WHERE paa.assignment_id = ben_asg.assignment_id ' ||
            '                            AND paa.assignment_action_id = prr.assignment_action_id ' ||
            '                            AND paa.payroll_action_id = ppa.payroll_action_id ' ||
            '                            AND ppa.effective_date between to_date('''||to_char((add_months(p_effective_date,-1) + 1) ,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') '||
            '                                                                and last_day(to_date(''' || to_char(p_effective_date,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')) '||
            '                         ) ' ||
            '             ) ' ||
            '           ) ' ||
            '         ) ' ||
            '     AND NVL(ppos.actual_termination_date, GREATEST(TO_DATE('''||to_char((add_months(p_effective_date,-1) + 1) ,'DD/MM/YYYY') ||''',''DD/MM/YYYY''),ppos.date_start)) ' ||
		'                                                                                                   BETWEEN ben_asg.effective_start_date AND ben_asg.effective_end_date ' ;
        ELSE
           l_dynamic_sql :=
            'select distinct(per.person_id)  person_id ' ||
            'from ' ||
            'per_all_people_f per, ' ||
            'per_all_assignments_f ben_asg ' ||
            'where ' ||
            'per.person_id = ben_asg.person_id (+)' ||
            ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') between per.effective_start_date and per.effective_end_date ' ||
            ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  || ''',''DD-MM-YYYY'') between ben_asg.effective_start_date (+) ' ||
            ' and ben_asg.effective_end_date (+)  ';
        END IF;
     ELSE
        l_dynamic_sql :=
            'select distinct(per.person_id)  person_id ' ||
            'from ' ||
            'per_all_people_f per, ' ||
            'per_all_assignments_f ben_asg ' ||
            'where ' ||
            'per.person_id = ben_asg.person_id (+)' ||
            ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') between per.effective_start_date and per.effective_end_date ' ||
            ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  || ''',''DD-MM-YYYY'') between ben_asg.effective_start_date (+) ' ||
            ' and ben_asg.effective_end_date (+)  ';
     END IF;

    -- For pensrv, Attribute check.Bug# 7341530
    IF (p_penserv_date is not null)
    THEN
       PQP_UTILITIES.get_config_type_values(
                    p_configuration_type   =>    'PQP_GB_PENSERVER_ELIGBLTY_CONF'
                   ,p_business_group_id    =>    p_business_group_id
                   ,p_legislation_code     =>    'GB' --g_legislation_code
                   ,p_tab_config_values    =>    l_pen_config_values
                   );

      IF l_pen_config_values.COUNT > 0
      THEN
         l_pen_membership_context  :=  l_pen_config_values(l_pen_config_values.FIRST).pcv_information1;
         l_pen_membership_col      :=  l_pen_config_values(l_pen_config_values.FIRST).pcv_information2;

	   IF l_pen_membership_col is not null
         THEN

		IF l_pen_membership_context = 'Global Data Elements'
            THEN
               l_dynamic_sql := l_dynamic_sql || ' and ben_asg.'||l_pen_membership_col||' IS NOT NULL';
            ELSE
               l_dynamic_sql := l_dynamic_sql || ' and ben_asg.'||l_pen_membership_col||' IS NOT NULL'
                                     || ' and ben_asg.ASS_ATTRIBUTE_CATEGORY = '||''''||l_pen_membership_context||'''';
            END IF;

         END IF;

	 END IF;
    END IF;

    if nvl(P_ext_global_flag,'N') <> 'Y'  then
      l_dynamic_sql := l_dynamic_sql||'  and   per.business_group_id = '||p_business_group_id||' ' ;
    end if ;



    if g_debug then
      hr_utility.set_location('DATE FORMAT 1 ', 470);
    end if;
  end if;

  -- intitialising
  l_pay_spl_process := 'N' ;
  l_pay_evt_non_asg := 'N';

  if p_data_typ_cd in ('C') then
     l_dynamic_sql := ' ' ;
     --- for system extract  change event
     -- when the celt criteria defined or not
     -- if the criterai value is null
     -- if the criteria value is not null and  BEN is defined in the critertia

     if g_chg_ext_from_ben = 'Y'  then
        l_dynamic_ben_sql :=
        'select distinct(xcl.person_id)  person_id ' ||
        'from ' ||
        'ben_ext_chg_evt_log xcl, ' ||
        'per_all_people_f per, ' ||
        'per_all_assignments_f ben_asg ' ||
        'where ' ||
        'xcl.person_id = per.person_id ' ||
        ' and xcl.person_id = ben_asg.person_id (+) ' ||
        ' and xcl.chg_eff_dt between per.effective_start_date and per.effective_end_date '  ||
        ' and xcl.chg_eff_dt between ben_asg.effective_start_date (+) ' ||
        ' and ben_asg.effective_end_date (+)  '
        ;

        if nvl(P_ext_global_flag, 'N' )  <>  'Y' then
           l_dynamic_ben_sql := l_dynamic_ben_sql ||
           ' and  per.business_group_id = ' ||p_business_group_id   ;
        end if ;


     end if ;
     -- for Payroll change event
     -- when the celt criteria defined and
     -- pay is part of the defintion
     hr_utility.set_location('g_chg_ext_from_pay   ' || g_chg_ext_from_pay , 470);


     if g_chg_ext_from_pay = 'Y'   then
        --- calcaulte the date for finding the non asg exisit in pay process events

        if p_data_typ_cd in ('C') then
           if l_cad_exists = 'Y'  then
              if l_cad_val1 in ('CHAD','CHED') then
                 l_cad_date_from   := hr_api.g_sot ;
                 l_cad_date_to     := hr_api.g_eot ;
              Else
                 l_cad_date_from := ben_ext_util.calc_ext_date (p_ext_date_cd => l_cad_val1,
                                                    p_abs_date    => p_effective_date,
                                                    p_ext_dfn_id => p_ext_dfn_id);
                 l_cad_date_to := ben_ext_util.calc_ext_date (p_ext_date_cd => l_cad_val2,
                                               p_abs_date    => p_effective_date,
                                               p_ext_dfn_id => p_ext_dfn_id);
              end if ;


              if l_ced_exists = 'Y'  then
                 if l_ced_val1 in ('CHAD','CHED') then
                    l_cad_date_from   := hr_api.g_sot ;
                    l_cad_date_to     := hr_api.g_eot ;
                 Else
                    l_ced_date_from := ben_ext_util.calc_ext_date (p_ext_date_cd => l_ced_val1,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);
                    l_ced_date_to := ben_ext_util.calc_ext_date (p_ext_date_cd => l_ced_val2,
                                               p_abs_date    => p_effective_date,
                                               p_ext_dfn_id => p_ext_dfn_id);
                 end if;
              end if ;

           End if ;
        End if ;

        ---- check the payroll non asg exist

        hr_utility.set_location('calling chck_non_asg_pay_evt   '  , 470);

        chck_non_asg_pay_evt(
                      p_ext_crit_prfl_id    =>  p_ext_crit_prfl_id ,
                      p_ext_dfn_id          =>  p_ext_dfn_id,
                      p_business_group_id   =>  p_business_group_id,
                      p_effective_date      =>  p_effective_date,
                      p_effective_from_date =>  l_ced_date_from,
                      p_effective_to_date   =>  l_ced_date_to,
                      p_actual_from_date    =>  l_cad_date_from,
                      p_actual_to_date      =>  l_cad_date_to,
                      p_adv_crit_exist      =>  l_adv_exists,
                      p_result              =>  l_pay_evt_non_asg ) ;


        -- if non asg pay evt found then select the all the employees in
        -- the database with  other person level criteria
        l_pay_spl_process  := 'N' ;


        if nvl(l_pay_evt_non_asg,'N') = 'Y'  then
           l_dynamic_pay_sql :=
             'select distinct(per.person_id)  person_id ' ||
             'from ' ||
             'per_all_people_f  per , ' ||
             'per_all_assignments_f ben_asg  ' ||
             'where ' ||
             '  ben_asg.person_id  = per.person_id  '  ||
             ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
             ''',''DD-MM-RRRR'') between per.effective_start_date and per.effective_end_date '
            ;

         Else
            l_dynamic_pay_sql :=
             'select distinct(ben_asg.person_id)  person_id ' ||
             'from ' ||
             'pay_process_events xcl, ' ||
             'per_all_assignments_f ben_asg  ' ||
             'where ' ||
             ' xcl.assignment_id  = ben_asg.assignment_id  ' ||
             ' and xcl.effective_date  between ben_Asg.effective_start_date and ben_Asg.effective_end_date '  ||
             ' and xcl.business_group_id = ben_Asg.business_group_id '
             ;

            l_pay_spl_process := 'Y' ;

        End if ;


        if nvl(P_ext_global_flag, 'N' )  <>  'Y' then
            if l_pay_spl_process = 'N' then
               l_dynamic_pay_sql := l_dynamic_pay_sql ||
              ' and  per.business_group_id = ' ||p_business_group_id   ;
            else
              l_dynamic_pay_sql := l_dynamic_pay_sql ||
              ' and  ben_Asg.business_group_id = ' ||p_business_group_id   ;
            end if ;
        end if ;

      end if ;

      -- End Update
      if g_debug then
        hr_utility.set_location('DATE FORMAT 2 ', 470);
      end if;
  end if;  -- 'C'

  if p_data_typ_cd in ('CM') then
     l_dynamic_sql :=
     'select distinct(pcm.person_id)  person_id ' ||
     'from ' ||
     'ben_per_cm_f pcm, ' ||
     'ben_per_cm_prvdd_f pcp, ' ||
     'per_all_people_f per, ' ||
     'per_all_assignments_f ben_asg ' ||
     'where ' ||
     'pcm.per_cm_id = pcp.per_cm_id ' ||
     ' and pcm.person_id = per.person_id ' ||
     ' and per.person_id = ben_asg.person_id (+) ' ||
     ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
     ''',''DD-MM-RRRR'') between per.effective_start_date and per.effective_end_date ' ||
     ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
     ''',''DD-MM-RRRR'') between pcm.effective_start_date and pcm.effective_end_date ' ||
     ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
     ''',''DD-MM-RRRR'') between pcp.effective_start_date and pcp.effective_end_date ' ||
     'and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
     ''',''DD-MM-RRRR'') between ben_asg.effective_start_date (+)  ' ||
     'and ben_asg.effective_end_date (+) ';

     if nvl(P_ext_global_flag,'N') <> 'Y'  then
       l_dynamic_sql := l_dynamic_sql||' and  pcm.business_group_id = '||p_business_group_id||' ' ;
     end if ;

     if g_debug then
       hr_utility.set_location('DATE FORMAT 3 ', 470);
     end if;
  end if;  -- 'CM'

  ---  CWB

  if p_data_typ_cd in ('CW') then
     l_dynamic_sql :=
     'select distinct(cpi.person_id)  person_id ' ||
     'from ' ||
     'ben_cwb_person_info  cpi, ' ||
     'per_all_people_f per, ' ||
     'per_all_assignments_f ben_asg ' ||
     'where ' ||
     'cpi.person_id = per.person_id ' ||
     ' and cpi.person_id = ben_asg.person_id (+) ' ||
      --  ' and cpi.business_group_id = ' || p_business_group_id ||
     ' and  cpi.effective_date  between per.effective_start_date and per.effective_end_date '  ||
     ' and cpi.effective_date  between ben_asg.effective_start_date (+) ' ||
     ' and ben_asg.effective_end_date (+)  '
     ;

     -- End Update
  end if;
  ---  CWB


  -- genral criteria
  if l_pid_exists = 'Y' then

     if l_pay_spl_process = 'N' then
        if l_pid_exclude = 'N' then
           l_dynamic_sql := l_dynamic_sql || ' and  ( per.person_id in ';
        else
           l_dynamic_sql := l_dynamic_sql || ' and  ( per.person_id not in ';
        end if;

        /*
        l_dynamic_sql := l_dynamic_sql ||
         '(select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1))
               from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
         ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
         ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
         'xct.crit_typ_cd = ''PID'') ';
        */


     Else
        if l_pid_exclude = 'N' then
           l_dynamic_sql := l_dynamic_sql || ' and  ( ben_asg.person_id in ';
        else
           l_dynamic_sql := l_dynamic_sql || ' and  ( ben_asg.person_id not in ';
        end if;
     End if ;

     --- get the unique id in variable
     l_crit_val_all := null ;
     get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                      p_ext_crit_typ      => 'PID' ,
                      p_string            => l_crit_val_all ) ;

     l_dynamic_sql := l_dynamic_sql || nvl(l_crit_val_all, '(-1)') || ')' ;


  end if;  -- eof PID
  --

  if l_pasgset_exists = 'Y' then

     if l_pasgset_exclude = 'N' then
          l_dynamic_sql := l_dynamic_sql || ' and   ( exists ';
     else
          l_dynamic_sql := l_dynamic_sql || ' and  ( not exists ';
     end if ;
      --- this logic is taken from the pkg  pyadcutl.pkb
      l_dynamic_sql := l_dynamic_sql ||
      '(  SELECT 1 FROM hr_assignment_sets aset , ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
      ' where xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
      ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
      ' xct.crit_typ_cd = ''PASGSET''  and  to_number(xcv.val_1) = aset.assignment_set_id  ' ||
      ' and (not exists (select 1  from hr_assignment_set_amendments hasa ' ||
      '                  where hasa.assignment_set_id = aset.assignment_set_id and hasa.include_or_exclude = ''I'') ' ||
      ' or exists (select 1 from hr_assignment_set_amendments hasa ' ||
      ' where hasa.assignment_set_id=aset.assignment_set_id  '||
      '       and hasa.assignment_id = ben_asg.assignment_id and hasa.include_or_exclude = ''I'' ) '||
      '  ) ' ||
      ' and not exists (select 1 from hr_assignment_set_amendments hasa  ' ||
      ' where hasa.assignment_set_id=aset.assignment_set_id'||
      '   and hasa.assignment_id =  ben_asg.assignment_id and hasa.include_or_exclude = ''E'')   )) ' ;

  end if ;  -- eof PASGSET

  if l_por_exists = 'Y' then
     if l_por_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql||' and (( ben_asg.organization_id  in ';
      else
        l_dynamic_sql := l_dynamic_sql ||' and ((ben_asg.organization_id is null) or (ben_asg.organization_id  not in ';
     end if;
     /*
     if l_pay_spl_process = 'N' then
        l_dynamic_sql := l_dynamic_sql ||
         '(select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1))
               from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
         ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
         ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
         'xct.crit_typ_cd = ''POR''))) ';

     Else
     */


     --- get the unique id in variable
     l_crit_val_all := null ;
     get_ext_crit_string(p_ext_crit_prfl_id     => p_ext_crit_prfl_id  ,
                              p_ext_crit_typ    => 'POR' ,
                              p_string          => l_crit_val_all ) ;

     l_dynamic_sql := l_dynamic_sql || nvl(l_crit_val_all, '(-1)') || '))' ;

  end if; -- eof POR
  --
  if l_pas_exists = 'Y' then
     if l_pas_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql||' and ( (ben_asg.assignment_status_type_id in ';
     else
        l_dynamic_sql := l_dynamic_sql || ' and ((ben_asg.assignment_status_type_id is null) or
                     (ben_asg.assignment_status_type_id not in ';
     end if;

     --- get the unique id in variable
     l_crit_val_all := null ;
     get_ext_crit_string(p_ext_crit_prfl_id        => p_ext_crit_prfl_id  ,
                              p_ext_crit_typ    => 'PAS' ,
                              p_string          => l_crit_val_all ) ;

     l_dynamic_sql := l_dynamic_sql || nvl(l_crit_val_all, '(-1)') || '))' ;

     /*
     l_dynamic_sql := l_dynamic_sql ||
     '(select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1))  |
     ' from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
     ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
     ' and   ben_asg.assignment_status_type_id  = to_number(xcv.val_1)  '||
     ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id  '||
     ' and  xct.crit_typ_cd = ''PAS''))) ';
     */

  end if;  -- eof PAS
  --
  if l_plo_exists = 'Y' then
    if l_plo_exclude = 'N' then
      l_dynamic_sql := l_dynamic_sql || ' and ( (ben_asg.location_id in ';
    else
      l_dynamic_sql := l_dynamic_sql || ' and ((ben_asg.location_id is null)  or (ben_asg.location_id not in ';
    end if;
    /*
    l_dynamic_sql := l_dynamic_sql ||
    '(select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1)) ' ||
    '  from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
    ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
    ' and   ben_asg.location_id  = to_number(xcv.val_1)  '||
    ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
    'xct.crit_typ_cd = ''PLO''))) ';
    */

    --- get the unique id in variable
    l_crit_val_all := null ;
    get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                      p_ext_crit_typ      => 'PLO' ,
                      p_string            => l_crit_val_all ) ;

    l_dynamic_sql := l_dynamic_sql || nvl(l_crit_val_all, '(-1)') || '))' ;


  end if;  -- eof PLO

  -- person payroll id
  if l_rrl_exists = 'Y' then
     if l_rrl_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql || ' and ( (ben_asg.payroll_id in ';
     else
       l_dynamic_sql := l_dynamic_sql || ' and ((ben_asg.payroll_id is null)  or (ben_asg.payroll_id not in ';
     end if;
     l_crit_val_all := null ;
     get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                      p_ext_crit_typ      => 'RRL' ,
                      p_string            => l_crit_val_all ) ;

     l_dynamic_sql := l_dynamic_sql || nvl(l_crit_val_all, '(-1)') || '))' ;

  end if;  -- eof RRL



  if l_pbg_exists = 'Y' then
     if l_pay_spl_process = 'N' then
        if l_pbg_exclude = 'N' then
           l_dynamic_sql := l_dynamic_sql || ' and ( (per.benefit_group_id  in ';
        else
           l_dynamic_sql := l_dynamic_sql || ' and ((per.benefit_group_id is null) or (per.benefit_group_id  not in ';
        end if;
           l_dynamic_sql := l_dynamic_sql ||
           '(select  to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1))
                 from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
           ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
           ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
           'xct.crit_typ_cd = ''PBG''))) ';
     else

         if l_pbg_exclude = 'N' then
            l_dynamic_sql := l_dynamic_sql || ' and ( ( exists  ';
          else
            l_dynamic_sql := l_dynamic_sql || ' and ( ( not exists ';
          end if;

          l_dynamic_sql := l_dynamic_sql ||
          '(select ''x''  from per_all_people_f per , ben_ext_crit_typ xct, ben_ext_crit_val xcv  where ' ||
          ' per.person_id = ben_asg.person_id   ' ||
          ' and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
          ''',''DD-MM-RRRR'') between per.effective_start_date and per.effective_end_date ' ||
          ' and per.benefit_group_id  = to_number(xcv.val_1) '||
          ' and xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
          ' and xct.ext_crit_typ_id = xcv.ext_crit_typ_id  '||
          ' and xct.crit_typ_cd = ''PBG'') )) ';

     end if ;

  end if;  -- eof PBG

  -- Person business group id
  if l_pbgr_exists = 'Y' then
     if l_pay_spl_process = 'N' then
        if l_pbgr_exclude = 'N' then
          l_dynamic_sql := l_dynamic_sql || ' and  ( per.business_group_id  in ';
        else
          l_dynamic_sql := l_dynamic_sql || ' and  ( per.business_group_id not in ';
        end if;
     else
         if l_pbgr_exclude = 'N' then
            l_dynamic_sql := l_dynamic_sql || ' and  ( ben_asg.business_group_id  in ';
         else
            l_dynamic_sql := l_dynamic_sql || ' and  ( ben_asg.business_group_id not in ';
         end if;
     end if ;

     --- Tilak  get the unique id in variable
     l_crit_val_all := null ;
     get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                       p_ext_crit_typ      => 'PBGR' ,
                       p_string            => l_crit_val_all ) ;
     l_dynamic_sql := l_dynamic_sql || nvl(l_crit_val_all, '(-1)') || ')' ;

     /*
     l_dynamic_sql := l_dynamic_sql ||
     '(select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1))
             from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
     ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
     ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
     'xct.crit_typ_cd = ''PBGR'') ';
    */

  end if; -- eof PBGR

  -- person type usage
  if l_ppt_exists = 'Y' then

     hr_utility.set_location('PPT excluded ' || l_ppt_exclude, 99 ) ;
     if l_pay_spl_process = 'N' then
        if l_ppt_exclude = 'N' then
           l_dynamic_sql := l_dynamic_sql || ' and per.person_id  in ';
        else
           l_dynamic_sql := l_dynamic_sql || ' and per.person_id not in ';
        end if;
     else
        if l_ppt_exclude = 'N' then
           l_dynamic_sql := l_dynamic_sql || ' and ben_asg.person_id  in ';
        else
           l_dynamic_sql := l_dynamic_sql || ' and ben_asg.person_id not in ';
        end if;

     end if ;

     -- 6642051
     if nvl(P_ext_global_flag,'N') = 'Y'  then

        l_dynamic_sql := l_dynamic_sql ||
        ' (select  ptu.person_id  from  per_person_type_usages_f ptu  ' ;
        if l_pay_spl_process = 'N' then
           l_dynamic_sql := l_dynamic_sql ||
           ' where ptu.person_id = per.person_id ' ;
        else
           l_dynamic_sql := l_dynamic_sql ||
          ' where ptu.person_id = ben_asg.person_id ' ;
        end if ;

        l_dynamic_sql := l_dynamic_sql ||
        '   and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
        ''',''DD-MM-RRRR'') between ptu.effective_start_date and ptu.effective_end_date ' ||
        ' and ptu.person_type_id in '||
        '    (select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1)) ' ||
        '   from ben_ext_crit_typ xct , ben_ext_crit_val xcv ' ||
        '    where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
        '    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
        '    xct.crit_typ_cd = ''PPT'')) ';

     else

        --- get the unique id in variable
        l_crit_val_all := null ;
        get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                       p_ext_crit_typ      => 'PPT' ,
                       p_string            => l_crit_val_all ) ;


        if l_pay_spl_process = 'N' then
           l_dynamic_sql := l_dynamic_sql ||
           ' (select  ptu.person_id  from  per_person_type_usages_f ptu  where ptu.person_id = per.person_id ' ;
        else
           l_dynamic_sql := l_dynamic_sql ||
           ' (select  ptu.person_id  from  per_person_type_usages_f ptu  where ptu.person_id = ben_Asg.person_id ' ;
        end if ;

        l_dynamic_sql := l_dynamic_sql ||
        '   and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
        ''',''DD-MM-RRRR'') between ptu.effective_start_date and ptu.effective_end_date ' ||
        ' and ptu.person_type_id in '|| nvl(l_crit_val_all, '(-1)') || ')' ;

     end if ;


     /*
      '    (select to_number(decode(ltrim (xcv.val_1,''0123456789''),NULL,xcv.val_1,-1))
               from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
      '    where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
      '    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id  '||
      '    and   ptu.person_type_id = to_number(xcv.val_1) and '||
      '    xct.crit_typ_cd = ''PPT'')) ';
     */

  end if;

  if l_cce_exists = 'Y' and p_data_typ_cd in ('C') then

     if l_dynamic_BEN_sql is not null then
        if l_cce_exclude = 'N' then
           l_dynamic_BEN_sql  :=  l_dynamic_BEN_sql || ' and  ( xcl.chg_evt_cd in ';
        else
           l_dynamic_BEN_sql := l_dynamic_BEN_sql || ' and  ( xcl.chg_evt_cd not in ';
        end if;


        l_crit_val_all := null ;
        get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                              p_ext_crit_typ    => 'CCE' ,
                              p_ext_num_str     => 'S' ,
                              p_string          => l_crit_val_all ) ;

         l_dynamic_BEN_sql := l_dynamic_BEN_sql || nvl(l_crit_val_all, '(''-1'')') || ')' ;

         /*

         l_dynamic_BEN_sql :=  l_dynamic_BEN_sql ||
        '(select xcv.val_1 from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
        ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
        ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id  '||
        ' and xct.crit_typ_cd = ''CCE'') ';
        */

     end if ;
  end if ; -- eof CCE

  if l_cpe_exists = 'Y' and p_data_typ_cd in ('C') then

     -- if any issue with following sql , pls contact PQP
     if l_dynamic_PAY_sql is not null then

        if nvl(l_pay_evt_non_asg,'N') = 'N'  then

           ---get the unique id in variable
           l_crit_val_all := null ;
           get_ext_crit_string(p_ext_crit_prfl_id  => p_ext_crit_prfl_id  ,
                              p_ext_crit_typ    => 'CPE' ,
                              p_string          => l_crit_val_all ) ;


           if l_cpe_exclude = 'N' then
              l_dynamic_PAY_Sql  :=  l_dynamic_PAY_Sql || ' and exists ';
           else
              l_dynamic_PAY_Sql := l_dynamic_PAY_Sql || ' and not exists ';
           end if;
           /* Added for Penserver Performance (check elements in elements sets if table_name is PAY_ELEMENT_ENTRIES_F */
	      -- BEGIN for Pensrv
	      if(p_penserv_date is not null)
            then
		-- END for Pensrv
               -- as per the babu sql
               l_dynamic_PAY_sql := l_dynamic_PAY_sql ||
               ' (select pde.event_group_id ' ||
               ' from  pay_datetracked_events pde, ' ||
               '  pay_event_updates peu ' ||
		    -- BEGIN for Pensrv
               ' ,pay_dated_tables pdt '||
               -- END for Pensrv
               ' where  ' ||
               --' and (pde.business_group_id = bg.organization_id OR  (pde.business_group_id IS NULL ' ||
               --' and (pde.legislation_code is null or pde.legislation_code = bg.org_information9) ) ) ' ||
               --' and xct.crit_typ_cd = ''CPE'' and xct.ext_crit_prfl_id = ' ||  p_ext_crit_prfl_id ||
               --' and xct.ext_crit_typ_id = xcv.ext_crit_typ_id ' ||
               --' and pde.event_group_id =  to_number(xcv.val_1) ' ||
               '  pde.event_group_id in   ' || l_crit_val_all  ||
               ' and xcl.event_update_id = peu.event_update_id ' ||
               ' and peu.dated_table_id = pde.dated_table_id ' ||
               --' and (pde.column_name is null or pde.column_name = peu.column_name) ' ||
               --' and (peu.business_group_id = pde.business_group_id OR (peu.business_group_id is null ' ||
               --' and (peu.legislation_code is null or peu.legislation_code = pde.legislation_code)))' ||
		   -- BEGIN for Pensrv
		   --  Modified the below sql to cater for purge events more efficiently
               ' AND    pde.dated_table_id  = pdt.dated_table_id ' ||
               ' AND    ((pdt.table_name = '||'''PAY_ELEMENT_ENTRIES_F'''||
               '          AND (EXISTS (SELECT 1 '  ||
               '                      FROM  pay_event_group_usages pegu ' ||
               '                            ,pay_element_type_rules petr ' ||
               '                            ,pay_element_entries_f  peef ' ||
               '                       WHERE pegu.event_group_id = pde.event_group_id ' ||
               '                       AND   ((xcl.noted_value IS NOT NULL ' ||
               '                               AND xcl.noted_value = petr.element_type_id ' ||
               '                               AND petr.element_set_id = pegu.element_set_id ' ||
               '                              ) ' ||
               '                              OR ' ||
               '                              (xcl.surrogate_key = peef.element_entry_id ' ||
               '                               AND peef.assignment_id = ben_asg.assignment_id ' ||
               '                               AND peef.element_type_id = petr.element_type_id ' ||
               '                               AND petr.element_set_id = pegu.element_set_id ' ||
               '                              ) ' ||
               '                             ) ' ||
               '                      ) ' ||
               '              ) ' ||
               '        ) ' ||
               '        OR  ' ||
               '        (pdt.table_name = '||'''PAY_ELEMENT_ENTRY_VALUES_F'''||
               '          AND (EXISTS (SELECT 1 '  ||
               '                      FROM  pay_event_group_usages pegu ' ||
               '                            ,pay_element_type_rules petr ' ||
               '                            ,pay_element_entries_f  peef ' ||
               '                            ,pay_element_entry_values_f  peevf ' ||
               '                      WHERE  peef.assignment_id = ben_asg.assignment_id ' ||
               '                      AND    peef.element_type_id = petr.element_type_id ' ||
               '                      AND    petr.element_set_id = pegu.element_set_id ' ||
               '                      AND    pegu.event_group_id = pde.event_group_id ' ||
               '                      AND    peef.element_entry_id = peevf.element_entry_id ' ||
               '                      AND    xcl.surrogate_key = peevf.element_entry_value_id ' ||
               '                      ) ' ||
               '              ) ' ||
               '        ) ' ||
               '        OR  ' ||
               '        (pdt.table_name not in (' || '''PAY_ELEMENT_ENTRIES_F''' ||','|| '''PAY_ELEMENT_ENTRY_VALUES_F''' ||
               '        )) ' ||
               '        ) ' ||
               -- End for pensrv
               ' ) ' ;
		 else
               -- as per the babu sql
               l_dynamic_PAY_sql := l_dynamic_PAY_sql ||
               ' (select pde.event_group_id ' ||
               ' from  pay_datetracked_events pde, ' ||
               '  pay_event_updates peu ' ||
               ' where  ' ||
               --' and (pde.business_group_id = bg.organization_id OR  (pde.business_group_id IS NULL ' ||
               --' and (pde.legislation_code is null or pde.legislation_code = bg.org_information9) ) ) ' ||
               --' and xct.crit_typ_cd = ''CPE'' and xct.ext_crit_prfl_id = ' ||  p_ext_crit_prfl_id ||
               --' and xct.ext_crit_typ_id = xcv.ext_crit_typ_id ' ||
               --' and pde.event_group_id =  to_number(xcv.val_1) ' ||
               '  pde.event_group_id in   ' || l_crit_val_all  ||
               ' and xcl.event_update_id = peu.event_update_id ' ||
               ' and peu.dated_table_id = pde.dated_table_id ' ||
               --' and (pde.column_name is null or pde.column_name = peu.column_name) ' ||
               --' and (peu.business_group_id = pde.business_group_id OR (peu.business_group_id is null ' ||
               --' and (peu.legislation_code is null or peu.legislation_code = pde.legislation_code)))' ||
               ' ) ' ;
		 end if;
        end if ;
     end if ;
  end if;  -- CPE
  -- change event actual date
  if l_cad_exists = 'Y' and p_data_typ_cd in ('C') then
     if g_debug then
        hr_utility.set_location(' called from benxthrd  1  '|| l_cad_val1 ,514);
     end if;
     if l_cad_val1 in ('CHAD','CHED') then
         l_cad_date_from   := hr_api.g_sot ;
         l_cad_date_to     := hr_api.g_eot ;
     Else
        l_cad_date_from := ben_ext_util.calc_ext_date (p_ext_date_cd => l_cad_val1,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);
        l_cad_date_to := ben_ext_util.calc_ext_date (p_ext_date_cd => l_cad_val2,
                                               p_abs_date    => p_effective_date,
                                               p_ext_dfn_id => p_ext_dfn_id);
     end if ;

     if l_dynamic_BEN_sql is not null then

        if l_cad_exclude = 'N' then
           l_dynamic_BEN_sql :=  l_dynamic_BEN_sql ||   ' and xcl.chg_actl_dt  between to_date(''' ||
           to_char(nvl(l_cad_date_from,hr_api.g_sot),'DD-MM-RRRR HH24:MI:SS')||
                            ''',''DD-MM-RRRR HH24:MI:SS'') and to_date(''' ||
           to_char(nvl(l_cad_date_to+0.99999,hr_api.g_eot),'DD-MM-RRRR HH24:MI:SS') || ''',''DD-MM-RRRR HH24:MI:SS'') ';
        else
           l_dynamic_BEN_sql :=  l_dynamic_BEN_sql ||
           ' and xcl.chg_actl_dt  not between to_date(''' ||
           to_char(nvl(l_cad_date_from,hr_api.g_sot),'DD-MM-RRRR HH24:MI:SS')  ||
                               ''',''DD-MM-RRRR HH24:MI:SS'') and to_date(''' ||
            to_char(nvl(l_cad_date_to+0.99999,hr_api.g_eot),'DD-MM-RRRR HH24:MI:SS') ||''',''DD-MM-RRRR HH24:MI:SS'') ';
        end if;
     end if ;

     if l_dynamic_PAY_sql is not null then
        if nvl(l_pay_evt_non_asg,'N') = 'N'  then
           if l_cad_exclude = 'N' then
              l_dynamic_PAY_sql :=  l_dynamic_PAY_sql ||  ' and xcl.CREATION_DATE  between to_date(''' ||
              to_char(nvl(l_cad_date_from,hr_api.g_sot),'DD-MM-RRRR HH24:MI:SS')  ||
                                ''',''DD-MM-RRRR HH24:MI:SS'') and to_date(''' ||
              to_char(nvl(l_cad_date_to+0.99999,hr_api.g_eot),'DD-MM-RRRR HH24:MI:SS')||''',''DD-MM-RRRR HH24:MI:SS'')';
           else
              l_dynamic_PAY_sql := l_dynamic_PAY_sql ||
              ' and xcl.CREATION_DATE not between to_date(''' ||
              to_char(nvl(l_cad_date_from,hr_api.g_sot),'DD-MM-RRRR HH24:MI:SS')  ||
                                ''',''DD-MM-RRRR HH24:MI:SS'') and to_date(''' ||
             to_char(nvl(l_cad_date_to+0.99999,hr_api.g_eot),'DD-MM-YYYY HH24:MI:SS')||''',''DD-MM-RRRR HH24:MI:SS'') ';
           end if;
        end if ;
     end if ;
  end if;  -- CAD
  -- chage event Effective date
  if l_ced_exists = 'Y' and p_data_typ_cd in ('C') then
     if g_debug then
        hr_utility.set_location(' called from benxthrd  2  '|| l_ced_val1 ,514);
     end if;
     if l_ced_val1 in ('CHAD','CHED') then
        l_cad_date_from   := hr_api.g_sot ;
        l_cad_date_to     := hr_api.g_eot ;
     Else
        l_ced_date_from := ben_ext_util.calc_ext_date (p_ext_date_cd => l_ced_val1,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);
        l_ced_date_to := ben_ext_util.calc_ext_date (p_ext_date_cd => l_ced_val2,
                                               p_abs_date    => p_effective_date,
                                               p_ext_dfn_id => p_ext_dfn_id);

     End if ;

     if l_dynamic_BEN_sql is not null then

        if l_ced_exclude = 'N' then
           l_dynamic_BEN_sql := l_dynamic_BEN_sql || ' and xcl.chg_eff_dt between to_date(''' ||
           to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
           to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
        else
           l_dynamic_BEN_sql := l_dynamic_BEN_sql ||
           ' and xcl.chg_eff_dt not between to_date(''' ||
           to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
           to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
        end if;
     end if ;

/*
     if l_dynamic_PAY_sql is not null then
        if nvl(l_pay_evt_non_asg,'N') = 'N'  then
           if l_ced_exclude = 'N' then
             l_dynamic_PAY_sql := l_dynamic_PAY_sql || ' and xcl.EFFECTIVE_DATE between to_date(''' ||
             to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
           else
             l_dynamic_PAY_sql := l_dynamic_PAY_sql ||
             ' and xcl.EFFECTIVE_DATE not between to_date(''' ||
             to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
           end if;
        end if ;
     end if ;
  end if;
*/
 if l_dynamic_PAY_sql is not null then
        if nvl(l_pay_evt_non_asg,'N') = 'N'  then
           if l_ced_exclude = 'N' then
            -- penserver performance fix - vkodedal
             if(p_penserv_date is not null)
             then

             	l_dynamic_PAY_sql := l_dynamic_PAY_sql || ' and ( ( xcl.EFFECTIVE_DATE between to_date(''' ||
             	to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             	to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') '
				 || ' and xcl.CREATION_DATE between to_date(''' ||
             	to_char(nvl(p_penserv_date,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             	to_char(nvl(l_ced_date_to + 1,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') )'
             			 || ' or ( xcl.CREATION_DATE between to_date(''' ||
             	to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             	to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') '
             			 || ' and  xcl.EFFECTIVE_DATE between to_date(''' ||
             	to_char(nvl(p_penserv_date,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             	to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ))';

			-- For pensrv, Attribute check.Bug# 7341530

			PQP_UTILITIES.get_config_type_values(
                    p_configuration_type   =>    'PQP_GB_PENSERVER_ELIGBLTY_CONF'
                   ,p_business_group_id    =>    p_business_group_id
                   ,p_legislation_code     =>    'GB' --g_legislation_code
                   ,p_tab_config_values    =>    l_pen_config_values
                   );

			 IF l_pen_config_values.COUNT > 0
                   THEN
                     l_pen_membership_context  :=  l_pen_config_values(l_pen_config_values.FIRST).pcv_information1;
                     l_pen_membership_col      :=  l_pen_config_values(l_pen_config_values.FIRST).pcv_information2;

			   IF l_pen_membership_col is not null
                     THEN

				IF l_pen_membership_context = 'Global Data Elements'
                        THEN
                           l_dynamic_PAY_sql := l_dynamic_PAY_sql || ' and ben_asg.'||l_pen_membership_col||' IS NOT NULL';
                        ELSE
                           l_dynamic_PAY_sql := l_dynamic_PAY_sql || ' and ben_asg.'||l_pen_membership_col||' IS NOT NULL'
                                             || ' and ben_asg.ASS_ATTRIBUTE_CATEGORY = '||''''||l_pen_membership_context||'''';
                        END IF;

			   END IF;

			 END IF;

             else ----- vkodedal
             	l_dynamic_PAY_sql := l_dynamic_PAY_sql || ' and xcl.EFFECTIVE_DATE between to_date(''' ||
             	to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             	to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
             end if;
           else
             l_dynamic_PAY_sql := l_dynamic_PAY_sql ||
             ' and xcl.EFFECTIVE_DATE not between to_date(''' ||
             to_char(nvl(l_ced_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
             to_char(nvl(l_ced_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
           end if;
        end if ;
     end if ;
  end if;
  --
  -- advance criteria

  if l_adv_exists = 'Y' and  p_data_typ_cd in ('C') then

     if l_dynamic_PAY_sql is not null then
        if nvl(l_pay_evt_non_asg,'N') = 'N'  then
           build_adv_criteria(
                    p_ext_crit_prfl_id   => p_ext_crit_prfl_id ,
                    p_ext_dfn_id         => p_ext_dfn_id,
                    p_business_group_id  => p_business_group_id,
                    p_effective_date     => p_effective_date,
                    p_source             => 'PAY' ,
                    p_select_statement   => l_dynamic_ADV_sql) ;

           if l_dynamic_ADV_sql is not null then
              l_dynamic_PAY_sql := l_dynamic_PAY_sql || ' AND ' || l_dynamic_ADV_sql ;
           end if ;
        end if ;
     end if ;

     if l_dynamic_BEN_sql is not null then

        build_adv_criteria(
                    p_ext_crit_prfl_id   => p_ext_crit_prfl_id ,
                    p_ext_dfn_id         => p_ext_dfn_id,
                    p_business_group_id  => p_business_group_id,
                    p_effective_date     => p_effective_date,
                    p_source             => 'BEN' ,
                    p_select_statement   => l_dynamic_ADV_sql) ;

        if l_dynamic_BEN_sql is not null then
           l_dynamic_BEN_sql := l_dynamic_BEN_sql || ' AND ' || l_dynamic_ADV_sql ;
        end if ;

     end if ;
  end if ;

  -- communication type
  if l_mtp_exists = 'Y' and p_data_typ_cd in ('CM') then
     if l_mtp_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql || ' and to_char(pcm.cm_typ_id) in ';
     else
        l_dynamic_sql := l_dynamic_sql || ' and to_char(pcm.cm_typ_id) not in ';
    end if;
    l_dynamic_sql := l_dynamic_sql ||
    '(select xcv.val_1 from ben_ext_crit_typ xct ,ben_ext_crit_val xcv ' ||
    ' where  xct.ext_crit_prfl_id = ' || p_ext_crit_prfl_id ||
    ' and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id and '||
    'xct.crit_typ_cd = ''MTP'') ';
  end if;
  -- communication tobe send date
  if l_mtbsdt_exists = 'Y' and p_data_typ_cd in ('CM') then
     l_mtbsdt_date_from := ben_ext_util.calc_ext_date (p_ext_date_cd => l_mtbsdt_val1,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);
     l_mtbsdt_date_to := ben_ext_util.calc_ext_date (p_ext_date_cd => l_mtbsdt_val2,
                                               p_abs_date    => p_effective_date,
                                               p_ext_dfn_id => p_ext_dfn_id);
     if l_mtbsdt_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql || ' and pcp.to_be_sent_dt between to_date(''' ||
        to_char(nvl(l_mtbsdt_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
        to_char(nvl(l_mtbsdt_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') ';
     else
        l_dynamic_sql := l_dynamic_sql ||
        ' and (pcp.to_be_sent_dt is null or pcp.to_be_sent_dt not between to_date(''' ||
        to_char(nvl(l_mtbsdt_date_from,hr_api.g_sot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'') and to_date(''' ||
        to_char(nvl(l_mtbsdt_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'')) ';
     end if;
  end if;
  -- communication send date
  if l_msdt_exists = 'Y' and p_data_typ_cd in ('CM') then
     l_msdt_date_from := ben_ext_util.calc_ext_date (p_ext_date_cd => l_msdt_val1,
                                                 p_abs_date    => p_effective_date,
                                                 p_ext_dfn_id => p_ext_dfn_id);
     l_msdt_date_to := ben_ext_util.calc_ext_date (p_ext_date_cd => l_msdt_val2,
                                               p_abs_date    => p_effective_date,
                                               p_ext_dfn_id => p_ext_dfn_id);
     if l_msdt_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql || ' and pcp.sent_dt between to_date(''' ||
        to_char(nvl(l_msdt_date_from,hr_api.g_sot),'DD-MM-YYYY')  || ''',''DD-MM-RRRR'') and to_date(''' ||
        to_char(nvl(l_msdt_date_to,hr_api.g_eot),'DD-MM-RRRR')  || ''',''DD-MM-RRRR'')';
     else
        l_dynamic_sql := l_dynamic_sql ||
        ' and (pcp.sent_dt is null or pcp.sent_dt not between to_date(''' ||
        to_char(nvl(l_msdt_date_from,hr_api.g_sot),'DD-MM-RRRR') || ''',''DD-MM-RRRR'') and to_date(''' ||
        to_char(nvl(l_msdt_date_to,hr_api.g_eot),'DD-MM-RRRR') || ''',''DD-MM-RRRR'')) ';
     end if;
  end if;


  -- person data link
  if l_pdl_exists = 'Y' then
     hr_utility.set_location('pdl excluded ' || l_pdl_exclude, 99 ) ;
     if l_pdl_exclude = 'N' then
        l_dynamic_sql := l_dynamic_sql || ' and EXISTS  ';
     else
        l_dynamic_sql := l_dynamic_sql || ' and  not EXISTS  ';
     end if ;
     if l_pdl_val1  = 'PDLJOB' then
        l_dynamic_sql := l_dynamic_sql ||
                  '  (select 1 from   per_jobs job  where job.job_id = ben_asg.job_id  and ' ||
                  '    exists ( select group_val_01 from  ben_ext_rslt_dtl erd  where  ' ||
                  '   erd.ext_rslt_id = ' || p_ext_rslt_id  ||
                  '   and group_val_01 is not null  and group_val_01 = job.name  ) )   '  ;
     elsif l_pdl_val1  = 'PDLPOS' then
           l_dynamic_sql := l_dynamic_sql ||
                  '  (select 1 from   HR_ALL_POSITIONS_F pos where pos.position_id = ben_asg.position_id and '||
                  '    to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
                  ''',''DD-MM-RRRR'') between pos.effective_start_date and pos.effective_end_date and  ' ||
                  '   exists ( select group_val_01 from  ben_ext_rslt_dtl erd  where  ' ||
                  '   erd.ext_rslt_id = ' || p_ext_rslt_id  ||
                  '   and group_val_01 is not null and group_val_01 = pos.name ))  '  ;

     elsif l_pdl_val1  = 'PDLPAY' then
                l_dynamic_sql := l_dynamic_sql ||
                  '  (select 1 from   pay_payrolls  pay  where pay.payroll_id  = ben_asg.payroll_id   and ' ||
                  '   exists ( select group_val_01 from  ben_ext_rslt_dtl erd  where  ' ||
                  '   erd.ext_rslt_id = ' || p_ext_rslt_id  ||
                  '   and  group_val_01 is not null and group_val_01 = pay.payroll_name   ))  '  ;
     elsif l_pdl_val1  = 'PDLLOC' then
                   l_dynamic_sql := l_dynamic_sql ||
                  '  (select 1 from   hr_locations_all  loc  where loc.location_id = ben_asg.location_id  ' ||
                  '   and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
                  ''',''DD-MM-RRRR'') between loc.effective_start_date and loc.effective_end_date ' ||
                  '  and  exists ( select group_val_01 from  ben_ext_rslt_dtl erd  where  ' ||
                  '   erd.ext_rslt_id = ' || p_ext_rslt_id  ||
                  '   and  group_val_01 is not null and group_val_01 = loc.location_code )) '  ;
     elsif  l_pdl_val1  = 'PDLEAPP' then
          l_dynamic_sql := l_dynamic_sql ||
          '  ( select 1 from per_time_periods tim  where   ben_asg.payroll_id  = tim.payroll_id  ' ||
          '   and to_date(''' || to_char(p_effective_date,'DD-MM-RRRR')  ||
          ''',''DD-MM-RRRR'') between   tim.start_date and tim.end_date   ' ||
          '  and  ben_asg.effective_start_date<=tim.end_date and ben_asg.effective_end_date>= tim.start_date) ';


     elsif l_pdl_val1  = 'PDLGRD' then
                   l_dynamic_sql := l_dynamic_sql ||
                  '  (select 1 from   per_grades  grd  where grd.grade_id = ben_asg.grade_id  ' ||
                  '  and  exists ( select group_val_01 from  ben_ext_rslt_dtl erd  where  ' ||
                  '   erd.ext_rslt_id = ' || p_ext_rslt_id  ||
                  '   and  group_val_01 is not null and group_val_01 = grd.name )) '  ;

      end if;

   end if;

   hr_utility.set_location(   p_data_typ_cd  || '   '|| l_wplr_exists , 99 ) ;

   if l_wplr_exists = 'Y' and p_data_typ_cd in ('CW') then
      if l_wplr_exclude = 'N' then
         l_dynamic_sql := l_dynamic_sql || ' and exists  '  ;
      else
         l_dynamic_sql := l_dynamic_sql || ' and not exists  '  ;
      end if ;
      l_dynamic_sql := l_dynamic_sql ||
        '   ( select 1  from ben_ext_crit_val cvl , ben_enrt_perd enp   , ben_per_in_ler pil' ||
        '   where cpi.group_per_in_ler_id = pil.per_in_ler_id and pil.group_pl_id =   cvl.val_2 '   ||
        '   and  cvl.EXT_CRIT_TYP_ID = ' ||  l_wlpr_EXT_CRIT_TYP_ID  ||
        '   and  enp.enrt_perd_id   =  cvl.val_1   and  pil.lf_evt_ocrd_dt =  enp.ASND_LF_EVT_DT   ) ' ;
   end if;

   if p_data_typ_cd =  'C'  then

      if  l_dynamic_BEN_sql is not null then
          l_dynamic_BEN_sql := l_dynamic_BEN_sql || '  ' ||  nvl(l_dynamic_sql, ' ' )  ;
      end if ;
      if l_dynamic_PAY_sql is not null then
          l_dynamic_PAY_sql := l_dynamic_PAY_sql || '  ' ||  nvl(l_dynamic_sql, ' ' )  ;
      end if ;

      l_dynamic_sql  :=   l_dynamic_BEN_sql ;
      if l_dynamic_sql  is not null  then
         hr_utility.set_location(' first  l_dynamic_sql not null ' , 99 );

         if l_dynamic_PAY_sql is not null then
            hr_utility.set_location(' first  l_dynamic_pay sql not null ' , 99 );
            l_dynamic_sql  :=   l_dynamic_sql || '   UNION ' ||
                             l_dynamic_PAY_sql ;
         end if ;
     else
         hr_utility.set_location(' first  l_dynamic_pay sql  null ' , 99 );
         if l_dynamic_PAY_sql is not null then
            l_dynamic_sql  :=   l_dynamic_PAY_sql  ;
         end if ;
     end if ;

  end if ;

  hr_utility.set_location(' build completed  ' , 99 );
  p_select_statement := l_dynamic_sql;

  --ptilak(p_select_statement) ;


end build_select_statement;






Function  check_asg_security
          (p_person_id          in number
          ,p_effective_date     in date
          ,p_business_group_id  in number )
          return boolean as

 l_proc                   varchar2(80) := g_package||'.check_asg_security';

 cursor c_asg is
 select asg.ASSIGNMENT_TYPE ,asg.assignment_id,asg.business_group_id
   from per_all_assignments_f asg
   where asg.person_id = p_person_id
     and asg.primary_flag =  'Y'
     and p_effective_date between asg.effective_start_date
         and asg.effective_end_date
  ;


  cursor c_sec_asg (p_assignment_id number) is
  select 'x'
   from per_all_assignments_f asg
   where asg.assignment_id = p_assignment_id
     and p_effective_date between asg.effective_start_date
         and asg.effective_end_date  ;



 l_ASSIGNMENT_TYPE     per_all_assignments_f.ASSIGNMENT_TYPE%type ;
 l_assignment_id       per_all_assignments_f.assignment_id%type ;
 l_business_group_id   per_all_assignments_f.business_group_id%type ;
 l_return  boolean ;
 l_temp     varchar2(1) ;
begin

 l_return  := true ;
-- if g_debug then
--    hr_utility.set_location ('Entering '||l_proc,5);
--    hr_utility.set_location ('person  '||p_person_id ,5);
-- end if;

 if  HR_SECURITY.VIEW_ALL  = 'Y'  and hr_general.get_xbg_profile = 'Y'  then
--     hr_utility.set_location ('Exiting '||l_proc,5);
     return l_return ;
 end if ;

/* moved down
  -- this is common validation for  asg and person
 if hr_general.get_xbg_profile <> 'Y'
    and hr_general.get_business_group_id is not null
    and hr_general.get_business_group_id <>  p_business_group_id   then
--    hr_utility.set_location ('Exiting  false'||l_proc,8);
    Return false ;
 end if ;

*/


 open  c_asg ;
 fetch c_asg into l_ASSIGNMENT_TYPE,l_assignment_id, l_business_group_id  ;
 if c_asg%notfound then
    -- if there is no assignmnet, allow the security , it could be dpnt
 --       hr_utility.set_location ('assignment not exist dependent  ',5);
    close c_asg ;
    return l_return ;
 end if ;
 close c_asg ;



  -- this is common validation for  asg and person
 if hr_general.get_xbg_profile <> 'Y'
    and hr_general.get_business_group_id is not null
    and hr_general.get_business_group_id <>  l_business_group_id   then
--    hr_utility.set_location ('Exiting  false'||l_proc,8);
    Return false ;
 end if ;


 -- if the assignment type is  E or C validate against the sec view
 if l_ASSIGNMENT_TYPE in ('E','C') then

    if HR_SECURITY.VIEW_ALL  <> 'Y' and
       HR_SECURITY.SHOW_RECORD('PER_ALL_ASSIGNMENTS_F', L_ASSIGNMENT_ID, P_PERSON_ID, L_ASSIGNMENT_TYPE) <> 'TRUE'  then
  --     hr_utility.set_location ('Exiting  false'||l_proc,9);
       return false ;
    end if ;
 end if ;


-- if g_debug then
--    hr_utility.set_location ('Exiting '||l_proc,15);
-- end if;
 return l_return ;

end  check_asg_security ;

procedure init_sub_lvl  is
  l_proc                   varchar2(80) := g_package||'.init_sub_lvl';
begin

 if g_debug then
    hr_utility.set_location ('Entering '||l_proc,5);
 end if;
 ben_ext_person.g_location_id              := null;
 ben_ext_person.g_location_code            := null;
 ben_ext_person.g_location_addr1           := null;
 ben_ext_person.g_location_addr2           := null;
 ben_ext_person.g_location_addr3           := null;
 ben_ext_person.g_location_city            := null;
 ben_ext_person.g_location_country         := null;
 ben_ext_person.g_location_zip             := null;
 ben_ext_person.g_location_region1         := null;
 ben_ext_person.g_location_region2         := null;
 ben_ext_person.g_location_region3         := null;
 ben_ext_person.g_alc_flex_01              := null;
 ben_ext_person.g_alc_flex_02              := null;
 ben_ext_person.g_alc_flex_03              := null;
 ben_ext_person.g_alc_flex_04              := null;
 ben_ext_person.g_alc_flex_05              := null;
 ben_ext_person.g_alc_flex_06              := null;
 ben_ext_person.g_alc_flex_07              := null;
 ben_ext_person.g_alc_flex_08              := null;
 ben_ext_person.g_alc_flex_09              := null;
 ben_ext_person.g_alc_flex_10              := null;
 ben_ext_person.g_position_id              := null;
 ben_ext_person.g_position                 := null;
 ben_ext_person.g_pos_flex_01              := null;
 ben_ext_person.g_pos_flex_02          := null;
 ben_ext_person.g_pos_flex_03          := null;
 ben_ext_person.g_pos_flex_04          := null;
 ben_ext_person.g_pos_flex_05          := null;
 ben_ext_person.g_pos_flex_06          := null;
 ben_ext_person.g_pos_flex_07          := null;
 ben_ext_person.g_pos_flex_08          := null;
 ben_ext_person.g_pos_flex_09          := null;
 ben_ext_person.g_pos_flex_10          := null;
 ben_ext_person.g_job_id               := null;
 ben_ext_person.g_job                  := null;
 ben_ext_person.g_job_flex_01          := null;
 ben_ext_person.g_job_flex_02          := null;
 ben_ext_person.g_job_flex_03          := null;
 ben_ext_person.g_job_flex_04          := null;
 ben_ext_person.g_job_flex_05          := null;
 ben_ext_person.g_job_flex_06          := null;
 ben_ext_person.g_job_flex_07          := null;
 ben_ext_person.g_job_flex_08          := null;
 ben_ext_person.g_job_flex_09          := null;
 ben_ext_person.g_job_flex_10          := null;
 ben_ext_person.g_payroll              := null;
 ben_ext_person.g_payroll_period_type  := null ;
 ben_ext_person.g_prl_flex_01          := null ;
 ben_ext_person.g_prl_flex_02          := null ;
 ben_ext_person.g_prl_flex_03          := null ;
 ben_ext_person.g_prl_flex_04          := null ;
 ben_ext_person.g_prl_flex_05          := null ;
 ben_ext_person.g_prl_flex_06          := null ;
 ben_ext_person.g_prl_flex_07          := null ;
 ben_ext_person.g_prl_flex_08          := null ;
 ben_ext_person.g_prl_flex_09          := null ;
 ben_ext_person.g_prl_flex_10          := null ;
 ben_ext_person.g_payroll_period_number:= null ;
 ben_ext_person.g_payroll_period_strtdt:= null ;
 ben_ext_person.g_payroll_period_enddt := null ;
 ben_ext_person.g_payroll_costing      := null ;
 ben_ext_person.g_payroll_costing_id   := null ;
 ben_ext_person.g_payroll_consolidation_set    := null ;
 ben_ext_person.g_payroll_consolidation_set_id := null ;
 ben_ext_person.g_group_elmt_value1             := null ;
 ben_ext_person.g_group_elmt_value2             := null ;
 --
 ben_ext_person.g_employee_grade_id    := null;
 ben_ext_person.g_employee_grade       := null;
 ben_ext_person.g_grd_flex_01          := null;
 ben_ext_person.g_grd_flex_02          := null;
 ben_ext_person.g_grd_flex_03          := null;
 ben_ext_person.g_grd_flex_04          := null;
 ben_ext_person.g_grd_flex_05          := null;
 ben_ext_person.g_grd_flex_06          := null;
 ben_ext_person.g_grd_flex_07          := null;
 ben_ext_person.g_grd_flex_08          := null;
 ben_ext_person.g_grd_flex_09          := null;
 ben_ext_person.g_grd_flex_10          := null;


 if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
 end if;
end init_sub_lvl ;


procedure  process_subheader(p_ext_file_id        in number
                             ,p_ext_dfn_id         in number
                             ,p_ext_rslt_id        in number
                             ,p_data_typ_cd        in varchar2
                             ,p_ext_typ_cd         in varchar2
                             ,p_effective_date     in date
                             ,p_ext_crit_prfl_id   in number
                             ,p_ext_global_flag    in varchar2
                             ,p_business_group_id  in number
                             ,p_subhdr_ghr_from_dt in date default null
                             ,p_subhdr_ghr_to_dt   in date default null
                             ) is

  l_proc                   varchar2(80) := g_package||'.process_subheader';

  cursor c_pos(p_org_id number,
               p_bg_id  number ) is
  select  pos.position_id,pos.job_id
    from  HR_ALL_POSITIONS_F  pos
    where pos.business_group_id =  p_bg_id
      and pos.organization_id   = p_org_id
      and p_effective_date between pos.EFFECTIVE_START_DATE
          and  nvl(pos.EFFECTIVE_END_DATE ,p_effective_date)
   ;

  cursor c_job (p_bg_id  number )   is
  select  job.job_id
    from  per_jobs_vl job
    where job.business_group_id = p_bg_id
    and   p_effective_date between job.date_from and nvl(job.date_to,p_effective_date)
    ;


  cursor c_loc(p_bg_id  number ) is
  select loc.location_id
    from hr_locations_all loc
   where loc.business_group_id = p_bg_id
         or loc.business_group_id is null    -- for global location
   ;


  cursor c_org (p_bg_id  number ) is
  select org.organization_id
         ,org.name
    from hr_all_organization_units_vl org
   where org.business_group_id = p_bg_id
   and   p_effective_date between org.date_from and nvl(org.date_to,p_effective_date) ;


  cursor c_pay (p_bg_id  number )  is
  select payroll_id
  from   pay_payrolls_f  pay
   where pay.business_group_id = p_bg_id
    -- and pay.organization_id   = p_org_id
     and p_effective_date between pay.EFFECTIVE_START_DATE  and  pay.EFFECTIVE_END_DATE
     ;


  cursor c_grade (p_bg_id  number )  is
  select grade_id
  from   per_grades_vl  grd
   where grd.business_group_id = p_bg_id
   and   p_effective_date between grd.date_from and nvl(grd.date_to,p_effective_date)
  ;

  cursor c_pos2(p_org_id number,
                p_bg_id  number ,
                p_subhdr_ghr_from_dt  date ,
                p_subhdr_ghr_to_dt   date
               ) is
  select
         distinct pos.position_id position_id
   from  ghr_pa_history  gph  ,
         HR_ALL_POSITIONS_F pos
  where  (   (gph.table_name = 'HR_ALL_POSITIONS_F'
              and pos.POSITION_ID = gph.information1 )
          or (gph.table_name = 'PER_POSITION_EXTRA_INFO'
              and pos.position_id = gph.information4 --  info4 is position_id
              and gph.information5 in ('GHR_US_POS_GRP1','GHR_US_POS_GRP2' ,'GHR_US_POS_VALID_GRADE','GHR_US_POS_GRP3',
                                       'GHR_US_POS_OBLIG', 'GHR_US_POS_MASS_ACTIONS', 'GHR_US_POSITION_LANGUAGE',
                                       'GHR_US_POSITION_INTERDISC', 'GHR_US_POSITION_DESCRIPTION' )
             )
         )
     and pos.business_group_id = p_bg_id
     and pos.organization_id   = p_org_id
     and gph.effective_date between pos.EFFECTIVE_START_DATE
         and  pos.EFFECTIVE_END_DATE
     and ( p_subhdr_ghr_from_dt is null
          or (
               trunc(gph.effective_date) between p_subhdr_ghr_from_dt and nvl(p_subhdr_ghr_to_dt, p_subhdr_ghr_from_dt)
                or
               ( trunc(gph.process_date) between   p_subhdr_ghr_from_dt and nvl(p_subhdr_ghr_to_dt, p_subhdr_ghr_from_dt)
                 and   trunc(gph.effective_date) <=  nvl(p_subhdr_ghr_to_dt, p_subhdr_ghr_from_dt)
               )
             )
         )
   ;


   cursor c_ced is
    select
           xct.excld_flag,
           xcv.val_1,
           xcv.val_2
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'CED';


   cursor c_cad is
    Select
           xct.excld_flag,
           xcv.val_1,
           xcv.val_2
    from   ben_ext_crit_typ xct,
           ben_ext_crit_val xcv
    where  xct.ext_crit_prfl_id = p_ext_crit_prfl_id
    and    xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and    xct.crit_typ_cd = 'CAD';



   cursor c_bg is
   select business_group_id , name
   from per_business_groups
   where  p_ext_global_flag = 'Y'
     or   business_group_id =  p_business_group_id
   ;

   cursor c_pbg is
   select business_group_id , name
   from per_business_groups
   where business_group_id =  p_business_group_id
  ;


  l_include                 varchar2(1)   ;
  l_person_id               number ;
  l_business_group_id       number ;
  l_proc_business_group_id  number ;
  l_proc_business_group_name per_business_groups.name%type ;

  p_chg_actl_dt_from  date ;
  p_chg_actl_dt_to    date ;
  p_chg_eff_dt_from   date ;
  p_chg_eff_dt_to     date ;
  l_actl_exclude_flag      varchar2(1) ;
  l_eff_exclude_flag      varchar2(1) ;
  l_val1   ben_ext_crit_val.val_1%type ;
  l_val2   ben_ext_crit_val.val_1%type ;


Begin

 l_person_id := 0   ;
 l_include   := 'Y' ;
 if g_debug then
    hr_utility.set_location ('Entering '||l_proc,5);
 end if;
  --
  ben_extract.set_ext_lvls
    (p_ext_file_id         => p_ext_file_id
    ,p_business_group_id   => p_business_group_id
    );

  if nvl(ben_extract.g_subhead_dfn,'N') <> 'Y' then
    if g_debug then
       hr_utility.set_location ('Exiting  no definition found '||l_proc,10);
    end if;
    return ;
  end if ;
  --
   IF p_ext_crit_prfl_id is not null THEN
    --
      ben_ext_person.g_effective_date := p_effective_date  ;
      ben_ext_evaluate_inclusion.Determine_Incl_Crit_To_Check(p_ext_crit_prfl_id);
    --
   END IF;


  -- Setup record and required level tables
  --
  ben_extract.setup_rcd_typ_lvl
    (p_ext_file_id => p_ext_file_id
    );
  --
  g_ext_dfn_id := p_ext_dfn_id;
  g_ext_rslt_id := p_ext_rslt_id;

  hr_utility.set_location ( ' org ' || ben_extract.g_org_lvl || '  pos  '|| ben_extract.g_pos_lvl ||
                             '  pay ' ||  ben_extract.g_pay_lvl || '  bg ' || ben_extract.g_bg_csr  , 99 ) ;
  --- get the processing bg
  --if  ben_extract.g_bg_csr = 'Y' then
      open c_pbg ;
      fetch c_pbg into
            ben_extract.g_proc_business_group_id ,
            ben_extract.g_proc_business_group_name;
      close c_pbg ;
      hr_utility.set_location ( ' proc bg ' || ben_extract.g_proc_business_group_name , 99 ) ;
  --end if ;


  for l_bg  in c_bg  Loop

      if p_ext_crit_prfl_id is not null then
         ben_ext_evaluate_inclusion.Evaluate_subhead_incl
         (
          p_business_group_id  => l_bg.business_group_id,
          p_include            => l_include,
          p_effective_date     => p_effective_date );
      end if ;


      if p_ext_crit_prfl_id is not null then
          ben_ext_evaluate_inclusion.Evaluate_subhead_incl
             (p_business_group_id  => l_bg.business_group_id    ,
              p_include            => l_include,
              p_effective_date     =>  p_effective_date );
      end if ;


      if l_include = 'Y'  then

         if  ben_extract.g_bg_csr = 'Y' then

             ben_ext_person.g_business_group_id  := l_bg.business_group_id ;
             ben_extract.g_business_group_name   := l_bg.name  ;
         end if ;

         --- extract organization and postion level
         if ben_extract.g_org_lvl = 'Y' or ben_extract.g_pos_lvl = 'Y'   then
              for i in c_org(l_bg.business_group_id)  loop

                  hr_utility.set_location ('_organization '||i.name,10);
                  if ben_extract.g_org_lvl = 'Y'  then

                     if p_ext_crit_prfl_id is not null then
                        ben_ext_evaluate_inclusion.Evaluate_subhead_incl
                            (p_organization_id     => i.organization_id  ,
                             p_business_group_id  => l_bg.business_group_id     ,
                             p_include            => l_include,
                             p_effective_date     =>  p_effective_date );
                     end if ;

                     if l_include = 'Y' then
                        ben_ext_person.g_employee_organization_id := i.organization_id ;
                        ben_ext_person.g_employee_organization    := i.name ;
                        ben_ext_fmt.process_ext_recs(p_ext_rslt_id     => p_ext_rslt_id,
                                             p_ext_file_id       => p_ext_file_id,
                                             p_data_typ_cd       => p_data_typ_cd,
                                             p_ext_typ_cd        => p_ext_typ_cd,
                                             p_rcd_typ_cd        => 'S',
                                             p_low_lvl_cd        => 'OR',
                                             p_person_id         => l_person_id,
                                             p_chg_evt_cd        => null,
                                             p_business_group_id => p_business_group_id,
                                             p_ext_per_bg_id    => l_bg.business_group_id,
                                             p_effective_date    => p_effective_date
                                             );
                      end if ;  -- include
                  end if ; -- ben_extract.g_org_lvl

                  --- position

                  if ben_extract.g_pos_lvl = 'Y'  then

                      hr_utility.set_location( 'spl flag ' || g_subhdr_chg_log , 99 );

                       if  g_subhdr_chg_log = 'Y'  then

                           ---
                           for j in c_pos2 (i.organization_id
                                     ,l_bg.business_group_id
                                     ,p_subhdr_ghr_from_dt
                                     ,p_subhdr_ghr_to_dt
                                    )  Loop

                            init_sub_lvl ;
                            l_include := 'Y' ;
                            -- call inclusion criteris
                            if p_ext_crit_prfl_id is not null then
                               ben_ext_evaluate_inclusion.Evaluate_subhead_incl
                               (p_organization_id    => i.organization_id  ,
                                p_position_id        => j.position_id  ,
                                p_business_group_id  => l_bg.business_group_id     ,
                                p_include            => l_include,
                                p_effective_date     => p_effective_date
                               );

                                hr_utility.set_location( ' include  ' || l_include , 99 );

                            end if ;

                           -- call the function from per_person_extract
                           if  l_include = 'Y' then
                               ben_ext_person.g_employee_organization_id := i.organization_id ;
                               ben_ext_person.g_employee_organization    := i.name ;
                               ben_ext_person.g_position_id              := j.position_id ;

                               ben_ext_person.get_pos_info(p_position_id    =>  j.position_id,
                                                           p_effective_date =>  p_effective_date) ;

                               hr_utility.set_location ('position '||j.position_id,10);
                               ben_ext_fmt.process_ext_recs(
                                                p_ext_rslt_id       => p_ext_rslt_id,
                                                p_ext_file_id       => p_ext_file_id,
                                                p_data_typ_cd       => p_data_typ_cd,
                                                p_ext_typ_cd        => p_ext_typ_cd,
                                                p_rcd_typ_cd        => 'S',
                                                p_low_lvl_cd        => 'PO',
                                                p_person_id         => l_person_id,
                                                p_chg_evt_cd        => null,
                                                p_business_group_id => p_business_group_id,
                                                p_ext_per_bg_id    => l_bg.business_group_id,
                                                p_effective_date    => p_effective_date
                                                );
                           end if ;
                        end loop ;


                    else
                        for j in c_pos (i.organization_id
                                    ,l_bg.business_group_id)  Loop
                            init_sub_lvl ;
                            l_include := 'Y' ;
                            -- call inclusion criteris
                            if p_ext_crit_prfl_id is not null then
                               ben_ext_evaluate_inclusion.Evaluate_subhead_incl
                                  (p_organization_id     => i.organization_id  ,
                                   p_position_id         => j.position_id  ,
                                   p_business_group_id  => l_bg.business_group_id     ,
                                   p_include            => l_include,
                                   p_effective_date     =>  p_effective_date );
                            end if ;

                            -- call the function from per_person_extract
                            if l_include = 'Y' then
                               ben_ext_person.g_employee_organization_id := i.organization_id ;
                               ben_ext_person.g_employee_organization    := i.name ;
                               ben_ext_person.g_position_id              := j.position_id ;
                               ben_ext_person.get_pos_info(p_position_id     =>  j.position_id,
                                                        p_effective_date =>  p_effective_date ) ;

                               hr_utility.set_location ('position '||j.position_id,10);
                               ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                                p_ext_file_id       => p_ext_file_id,
                                                p_data_typ_cd       => p_data_typ_cd,
                                                p_ext_typ_cd        => p_ext_typ_cd,
                                                p_rcd_typ_cd        => 'S',
                                                p_low_lvl_cd        => 'PO',
                                                p_person_id         => l_person_id,
                                                p_chg_evt_cd        => null,
                                                p_business_group_id => p_business_group_id,
                                                p_ext_per_bg_id    => l_bg.business_group_id,
                                                p_effective_date    => p_effective_date
                                                );
                           end if ;
                       end loop ;
                    end if ; --- g_subhdr_chg_log
                  end if ;
           end loop ;
         end if ;


         --- payroll


         if ben_extract.g_pay_lvl = 'Y'  then
            for j in c_pay (l_bg.business_group_id )   Loop
                init_sub_lvl ;
                l_include := 'Y' ;
                -- call inclusion criteris
                if p_ext_crit_prfl_id is not null then
                   ben_ext_evaluate_inclusion.Evaluate_subhead_incl
                            (
                             p_payroll_id          => j.payroll_id  ,
                             p_business_group_id  => l_bg.business_group_id     ,
                             p_include            => l_include,
                            p_effective_date     =>  p_effective_date );
                end if ;
                 --
                -- call the function from per_person_extract
                if  l_include = 'Y' then
                     ben_ext_person.get_payroll_info(p_payroll_id     =>  j.payroll_id,
                                                  p_effective_date =>  p_effective_date ) ;

                     hr_utility.set_location ('payroll id  '||j.payroll_id,10);
                     ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                             p_ext_file_id       => p_ext_file_id,
                                             p_data_typ_cd       => p_data_typ_cd,
                                             p_ext_typ_cd        => p_ext_typ_cd,
                                             p_rcd_typ_cd        => 'S',
                                             p_low_lvl_cd        => 'PY',
                                             p_person_id         => l_person_id,
                                             p_chg_evt_cd        => null,
                                             p_business_group_id => p_business_group_id,
                                             p_ext_per_bg_id    => l_bg.business_group_id,
                                             p_effective_date    => p_effective_date
                                             );
                end if ;
            end loop ;
         end if ;




         --- extract  job level

         if ben_extract.g_job_lvl = 'Y'  then
            for i in c_job (l_bg.business_group_id)  loop
               init_sub_lvl ;
               l_include := 'Y' ;
               -- call inclusion criteris
               if p_ext_crit_prfl_id is not null then
                  ben_ext_evaluate_inclusion.Evaluate_subhead_incl(
                             p_job_id              =>  i.job_id  ,
                             p_business_group_id  => l_bg.business_group_id     ,
                             p_include            => l_include,
                             p_effective_date     =>  p_effective_date );
               end if ;
               --
               -- call the function from per_person_extract
               if  l_include = 'Y' then
                   ben_ext_person.g_job_id              := i.job_id ;
                   ben_ext_person.get_job_info(p_job_id     =>  i.job_id,
                                            p_effective_date =>  p_effective_date ) ;

                   hr_utility.set_location ('job id  '||i.job_id,10);
                   ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                             p_ext_file_id       => p_ext_file_id,
                                             p_data_typ_cd       => p_data_typ_cd,
                                             p_ext_typ_cd        => p_ext_typ_cd,
                                             p_rcd_typ_cd        => 'S',
                                             p_low_lvl_cd        => 'JB',
                                             p_person_id         => l_person_id,
                                             p_chg_evt_cd        => null,
                                             p_business_group_id => p_business_group_id,
                                             p_ext_per_bg_id    => l_bg.business_group_id,
                                             p_effective_date    => p_effective_date
                                             );
               end if ;

            end loop;
         end if ;
         --- extractr location level

         if ben_extract.g_loc_lvl = 'Y'  then
            for i in c_loc (l_bg.business_group_id)  loop
                init_sub_lvl ;
                 l_include := 'Y' ;
               -- call inclusion criteris
               if p_ext_crit_prfl_id is not null then
                  ben_ext_evaluate_inclusion.Evaluate_subhead_incl(
                                p_location_id        => i.location_id  ,
                                p_business_group_id  => l_bg.business_group_id ,
                                p_include            => l_include,
                                p_effective_date     =>  p_effective_date );
               end if ;
               --
               -- call the function from per_person_extract
               if  l_include = 'Y' then
                   ben_ext_person.g_location_id              := i.location_id ;
                   ben_ext_person.get_loc_info(p_location_id     =>  i.location_id,
                                               p_effective_date =>  p_effective_date ) ;

                   hr_utility.set_location ('payroll id  '||i.location_id,10);
                   ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                                p_ext_file_id       => p_ext_file_id,
                                                p_data_typ_cd       => p_data_typ_cd,
                                                p_ext_typ_cd        => p_ext_typ_cd,
                                                p_rcd_typ_cd        => 'S',
                                                p_low_lvl_cd        => 'LO',
                                                p_person_id         => l_person_id,
                                                p_chg_evt_cd        => null,
                                                p_business_group_id => p_business_group_id,
                                                p_ext_per_bg_id    => l_bg.business_group_id,
                                                p_effective_date    => p_effective_date
                                                );
               end if ;
            end loop;
         end if ;

         -- extract grade informations
        if ben_extract.g_grd_lvl = 'Y'  then
            for i in c_grade (l_bg.business_group_id)  loop
                init_sub_lvl ;
                 l_include := 'Y' ;
               -- call inclusion criteris
               if p_ext_crit_prfl_id is not null then
                  ben_ext_evaluate_inclusion.Evaluate_subhead_incl(
                                p_grade_id        => i.grade_id  ,
                                p_business_group_id  => l_bg.business_group_id ,
                                p_include            => l_include,
                                p_effective_date     =>  p_effective_date );
               end if ;
               --
               -- call the function from per_person_extract
               if  l_include = 'Y' then
                   ben_ext_person.g_employee_grade_id := i.grade_id ;
                   ben_ext_person.get_grade_info(p_grade_id     =>  i.grade_id,
                                               p_effective_date =>  p_effective_date ) ;

                   hr_utility.set_location ('grade id  '||i.grade_id,10);
                   ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                                p_ext_file_id       => p_ext_file_id,
                                                p_data_typ_cd       => p_data_typ_cd,
                                                p_ext_typ_cd        => p_ext_typ_cd,
                                                p_rcd_typ_cd        => 'S',
                                                p_low_lvl_cd        => 'GR',
                                                p_person_id         => l_person_id,
                                                p_chg_evt_cd        => null,
                                                p_business_group_id => p_business_group_id,
                                                p_ext_per_bg_id    => l_bg.business_group_id,
                                                p_effective_date    => p_effective_date
                                                );
               end if ;
            end loop;
         end if ;


      end if ;  -- bg include
  end Loop ;   -- bg level
  --reintialize all the variable before person is extracted
  init_sub_lvl ;
 if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
 end if;

End ;




-- =======================================================================
--                          <<Procedure:Process>>
-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------
-- This is the main batch procedure to be called from the concurrent manager
-- or interactively to start extract.
-- ========================================================================
--
procedure process
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy varchar2
  ,p_benefit_action_id    in  number
  ,p_ext_dfn_id           in  number
  ,p_effective_date       in  varchar2
  ,p_business_group_id    in  number
  ---
  ,p_output_type          in  varchar2 default null
  ,p_out_dummy            in  varchar2  default null
  ,p_xdo_template_id      in  number default null
  ,p_eff_start_date       in  varchar2   default null
  ,p_eff_end_date         in  varchar2   default null
  ,p_act_start_date       in  varchar2   default null
  ,p_act_end_date         in  varchar2   default null
  ---for restart
  ,p_ext_rslt_id          in  number default null
  -- for PQP subheader
  ,p_subhdr_chg_log       in  varchar2  default null
  ,p_penserv_date         in  date      default null    -- vkodedal changes for penserver
  ,p_penserv_mode         in  varchar2  default 'N'     ---      ''       ''
) is
  --
  -- if directory not specified, then grab the first
  -- in the utl_file_dir path
  --
  /* cursor c_get_dflt_dir is
    select substr(value,1,instr(value,',')-1)
    from gv$system_parameter
    where name = 'utl_file_dir'
    and value is not null ; */
  -- bug 3187407
  -- to handle situations where only 1 directory specified in utl_file_dir.
  --
  cursor c_get_dflt_dir is
  select decode (instr(ltrim(value),','), 0 ,
         ltrim(value),
         substrb(value,1,instr(ltrim(value),',')-1) )
  from v$parameter where name = 'utl_file_dir';
  --
  l_proc                   varchar2(80) := g_package||'.process';
  --
  -- Update by RChase 01-MAR-2000
  --
  l_current_loc NUMBER:=0;
  -- End Update
  l_request_id             number;
  l_benefit_action_id      ben_benefit_actions.benefit_action_id%type;
  l_person_id              l_number_type := l_number_type();
  l_person_action_id       l_number_type := l_number_type();
  l_range_id               ben_batch_ranges.range_id%type;
  l_object_version_number  ben_batch_ranges.object_version_number%type;
  l_chunk_size             number(5) := 20;
  l_threads                number(5) := 1;
  l_max_errors_allowed     number(5) := 20;
  l_start_person_action_id number := 0;
  l_end_person_action_id   number := 0;
  l_prev_person_id         number := 0;
  l_person_cnt             number := 0;
  l_step                   number := 0;
  l_num_range              number := 0;
  l_dump_num               number(15);
  l_count                  number;
  l_data_typ_cd            hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(30);
  l_ext_typ_cd             hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(30);
  l_ext_crit_prfl_id       number(15);
  l_ext_file_id            number(15);
  l_ext_rslt_id            number(15);
  l_ext_strt_dt_cd         hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(30);
  l_ext_end_dt_cd          hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(30);
  l_ext_strt_dt            date;
  l_ext_end_dt             date;
  l_prmy_sort_cd           hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(30);
  l_scnd_sort_cd           hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(30);
  l_output_name            ben_ext_rslt.output_name%type ;
  l_drctry_name            ben_ext_rslt.drctry_name%type ;
  l_apnd_rqst_id_flag      ben_ext_dfn.apnd_rqst_id_flag%TYPE;  -- UTF8 varchar2(40);
  l_kickoff_wrt_prc_flag   ben_ext_dfn.kickoff_wrt_prc_flag%TYPE;  -- UTF8 varchar2(40);
  l_use_eff_dt_for_chgs_flag  ben_ext_dfn.use_eff_dt_for_chgs_flag%TYPE ; -- UTF8 varchar2(40);
  l_ext_post_prcs_rl       number;
  l_xrs_object_version_number number;
  l_error_cd               hr_lookups.lookup_code%TYPE ; -- UTF8 varchar2(80);
  l_line                   number := 0;
  l_effective_date         date;
  l_conc_request_id        number;
  l_select_statement       varchar2(32000);
  l_num_rows               number := 0;
  l_ext_global_flag        varchar2(30) ;
  l_cm_display_flag        varchar2(30) ;
  l_ext_stat_cd            varchar2(30) ;
  l_dummy                  varchar2(30) ;
  --

  cursor c_rslt is
    select object_version_number
    from ben_ext_rslt
    where ext_rslt_id = p_ext_rslt_id ;

  -- check the defintion of detail levle
   cursor chk_D_lvl(p_ext_file_id number) is
     select 'Y'
     from ben_ext_rcd         a,
          ben_ext_rcd_in_file  b
     where a.ext_rcd_id  = b.ext_rcd_id
       and b.ext_file_id = p_ext_file_id
       and a.rcd_type_cd = 'D'
     ;
  --
  cursor c_Ext_err_only (c_ext_rslt_id  number) is
  select 'x'  from
  ben_Ext_rslt_err
  where typ_cd  = 'E'
  and  ext_rslt_id = c_ext_rslt_id
  ;
  --
  l_outputs  ff_exec.outputs_t;
  --
  TYPE PersonCurType is REF CURSOR;
  --
  PersonCur     PersonCurType;
  --
  TYPE PersonRec is RECORD
  (person_id   number(15));
  --
  l_rec         PersonRec;
  l_status      integer;
  l_chg_actl_strt_dt date;
  l_chg_actl_end_dt date;
  l_chg_eff_strt_dt date;
  l_chg_eff_end_dt date;
  l_to_be_sent_strt_dt date;
  l_to_be_sent_end_dt date;
  l_commit number;
  l_output_type  varchar2(30) ;
  l_output_code  varchar2(30) ;
  l_xdo_template_id  number ;
  l_eff_start_date   date  ;
  l_eff_end_date     date  ;
  l_act_start_date   date  ;
  l_act_end_date     date  ;
  l_D_lvl_found varchar2(1) ;
  --

  cursor c_xdoi (c_xdo_id  number)  is
  select application_short_name ,
         template_code ,
         default_language,
         default_territory
  from xdo_templates_b
 where template_id = c_xdo_id  ;

 l_application_short_name  xdo_templates_b.application_short_name%type ;
 l_template_code           xdo_templates_b.template_code%type ;
 l_default_language        xdo_templates_b.default_language%type ;
 l_default_territory       xdo_templates_b.default_territory%type ;
 l_fnd_out                 boolean ;

Begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location ('Entering '||l_proc,5);
  end if;
  --

  l_conc_request_id := fnd_global.conc_request_id;
  g_subhdr_chg_log  := nvl(p_subhdr_chg_log, 'N') ;
  --
  initialize_globals;
  --
  l_effective_date := to_date(p_effective_date, 'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');


  if p_eff_start_date is not null then

     l_eff_start_date := to_date(p_eff_start_date, 'YYYY/MM/DD HH24:MI:SS');
     l_eff_start_date := to_date(to_char(trunc(l_eff_start_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

     l_eff_end_date := to_date(p_eff_end_date, 'YYYY/MM/DD HH24:MI:SS');
     l_eff_end_date := to_date(to_char(trunc(l_eff_end_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

  end if ;

  if p_act_start_date is not null then
     l_act_start_date := to_date(p_act_start_date, 'YYYY/MM/DD HH24:MI:SS');
     l_act_start_date := to_date(to_char(trunc(l_act_start_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');

     l_act_end_date := to_date(p_act_end_date, 'YYYY/MM/DD HH24:MI:SS');
     l_act_end_date := to_date(to_char(trunc(l_act_end_date), 'DD/MM/RRRR'),
                      'DD/MM/RRRR');


  end if ;

  -- if customer pass one parameter errro
  if ( p_eff_start_date is not null and p_eff_end_date is null )
     or (  p_act_start_date is not null and p_act_end_date is null )
     then
    ben_ext_thread.g_err_num := 91919;
    ben_ext_thread.g_err_name := 'BEN_91919_EXT_END_DT_NULL';
    raise g_job_failure_error;

  end if ;


  l_line := 1;
  --
  -- load the fnd_session table in case a rule dbi needs it.
  --
  dt_fndate.change_ses_date
    (p_ses_date => l_effective_date,
     p_commit => l_commit);
  --
  if p_ext_dfn_id is null then
    --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                              ,p_argument       => 'p_ext_dfn_id'
                              ,p_argument_value => p_ext_dfn_id);
    --
  elsif p_effective_date is null then
    --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                              ,p_argument       => 'p_effective_date'
                              ,p_argument_value => p_effective_date);
    --
  elsif p_business_group_id is null then
    --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                              ,p_argument       => 'p_business_group_id'
                              ,p_argument_value => p_business_group_id);
    --
  end if;
  --
  l_line := 2;
  --
  get_ext_prmtrs
    (p_ext_dfn_id               =>  p_ext_dfn_id,
     p_business_group_id        =>  p_business_group_id,
     p_data_typ_cd              =>  l_data_typ_cd,
     p_ext_typ_cd               =>  l_ext_typ_cd,
     p_ext_crit_prfl_id         =>  l_ext_crit_prfl_id,
     p_ext_file_id              =>  l_ext_file_id,
     p_ext_strt_dt              =>  l_ext_strt_dt_cd,
     p_ext_end_dt               =>  l_ext_end_dt_cd,
     p_prmy_sort_cd             =>  l_prmy_sort_cd,
     p_scnd_sort_cd             =>  l_scnd_sort_cd,
     p_output_name              =>  l_output_name,
     p_drctry_name              =>  l_drctry_name,
     p_apnd_rqst_id_flag        =>  l_apnd_rqst_id_flag,
     p_kickoff_wrt_prc_flag     =>  l_kickoff_wrt_prc_flag,
     p_use_eff_dt_for_chgs_flag => l_use_eff_dt_for_chgs_flag,
     p_ext_post_prcs_rl         => l_ext_post_prcs_rl,
     p_ext_global_flag          => l_ext_global_flag ,
     p_cm_display_flag          => l_cm_display_flag ,
     p_output_type              =>  l_output_type,
     p_xdo_template_id          =>  l_xdo_template_id
    );
  --
  if l_ext_file_id is null then
    --
    ben_ext_thread.g_err_num := 91917;
    ben_ext_thread.g_err_name := 'BEN_91917_EXT_FILE_NULL';
    raise g_job_failure_error;
    --
  end if;

  l_D_lvl_found := 'N' ;
  open chk_D_lvl(l_ext_file_id) ;
  fetch chk_D_lvl into l_D_lvl_found ;
  close chk_D_lvl ;

 if p_output_type is not null then
    l_output_type := p_output_type ;
    l_xdo_template_id := nvl(p_xdo_template_id, l_xdo_template_id) ;
    -- in case ext dfn for pdf and  parameter is file then
    -- nullify the template if
    if p_output_type in  ('F','X') and l_xdo_template_id is not null then
       l_xdo_template_id := null ;
    end if ;
 end if ;


  --
  -- Determine output file name
  --
  IF l_output_name is not null and l_apnd_rqst_id_flag = 'Y' THEN
    --
    l_output_name := l_output_name || '.' ||
                     to_char(l_conc_request_id);
    --
  END IF;
  --
  l_line := 3;
  --  Calculate actual extract dates
  --
  /*
  l_ext_strt_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_ext_strt_dt_cd,
                    p_abs_date    => l_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
  g_ext_strt_dt := l_ext_strt_dt;
  --
  IF l_data_typ_cd = 'F' THEN
    --
    l_ext_end_dt := l_ext_strt_dt;
    --
  ELSE
    --
    l_ext_end_dt := ben_ext_util.calc_ext_date
                    (p_ext_date_cd => l_ext_end_dt_cd,
                     p_abs_date    => l_effective_date,
                     p_ext_dfn_id => p_ext_dfn_id
                     );
    --
  END IF;
  --
  if l_ext_end_dt < l_ext_strt_dt then
    ben_ext_thread.g_err_num := 92080;
    ben_ext_thread.g_err_name := 'BEN_92080_EXT_STRT_END_DT';
    raise g_job_failure_error;
  end if;
  --
  g_ext_end_dt := l_ext_end_dt;
  --
  if l_ext_strt_dt is null then
    ben_ext_thread.g_err_num := 91918;
    ben_ext_thread.g_err_name := 'BEN_91918_EXT_STRT_DT_NULL';
    raise g_job_failure_error;
  end if;
  --
  if l_ext_end_dt is null then
    ben_ext_thread.g_err_num := 91919;
    ben_ext_thread.g_err_name := 'BEN_91919_EXT_END_DT_NULL';
    raise g_job_failure_error;
  end if;
  --
  */
  --
  l_line := 4;
  --
  if l_output_name is null then
    l_output_name := 'outfile';
  end if;
  --
  if l_drctry_name is null then
    --
    open c_get_dflt_dir;
      --
      fetch c_get_dflt_dir into l_drctry_name;
      --
    close c_get_dflt_dir;
    --
  end if;
  --


  if l_cm_display_flag = 'Y' then
     l_output_name := null ;
     l_drctry_name := null ;
  end if ;


  if p_benefit_action_id is not null and p_ext_rslt_id is not null then

     l_ext_rslt_id := p_ext_rslt_id ;
     open c_rslt ;
     fetch c_rslt into  l_xrs_object_version_number ;
     close c_rslt ;


     if l_xrs_object_version_number is  null then
         ben_ext_rslt_api.create_ext_rslt
           (p_validate                => FALSE
          ,p_ext_rslt_id             => l_ext_rslt_id
          ,p_run_strt_dt             => sysdate
          ,p_run_end_dt              => null
          ,p_ext_stat_cd             => 'X'
          ,p_eff_dt                  => l_effective_date
          ,p_ext_strt_dt             => l_ext_strt_dt
          ,p_ext_end_dt              => l_ext_end_dt
          ,p_output_name             => l_output_name
         ,p_drctry_name             => l_drctry_name
         ,p_ext_dfn_id              => p_ext_dfn_id
         ,p_business_group_id       => p_business_group_id
         ,p_program_application_id  => fnd_global.prog_appl_id
         ,p_program_id              => fnd_global.conc_program_id
         ,p_program_update_date     => sysdate
         ,p_request_id              => l_conc_request_id
         ,p_output_type             => l_output_type
         ,p_xdo_template_id         => l_xdo_template_id
         ,p_object_version_number   => l_xrs_object_version_number
         ,p_effective_date          => l_effective_date);

        commit;
     end if ;
  else
     ben_ext_rslt_api.create_ext_rslt
       (p_validate                => FALSE
       ,p_ext_rslt_id             => l_ext_rslt_id
       ,p_run_strt_dt             => sysdate
       ,p_run_end_dt              => null
       ,p_ext_stat_cd             => 'X'
       ,p_eff_dt                  => l_effective_date
       ,p_ext_strt_dt             => l_ext_strt_dt
       ,p_ext_end_dt              => l_ext_end_dt
       ,p_output_name             => l_output_name
       ,p_drctry_name             => l_drctry_name
       ,p_ext_dfn_id              => p_ext_dfn_id
       ,p_business_group_id       => p_business_group_id
       ,p_program_application_id  => fnd_global.prog_appl_id
       ,p_program_id              => fnd_global.conc_program_id
       ,p_program_update_date     => sysdate
       ,p_request_id              => l_conc_request_id
       ,p_output_type             => l_output_type
       ,p_xdo_template_id         => l_xdo_template_id
       ,p_object_version_number   => l_xrs_object_version_number
       ,p_effective_date          => l_effective_date);
     --
     commit;
     --
 end if ;

  if g_debug then
    hr_utility.set_location(' resilt_id ' || l_ext_rslt_id,177 ) ;
  end if;
  benutils.get_parameter
    (p_business_group_id => p_business_group_id
    ,p_batch_exe_cd => 'BENXTRCT'
    ,p_threads => l_threads
    ,p_chunk_size => l_chunk_size
    ,p_max_errors => l_max_errors_allowed);
  --
  l_line := 5;
  --
  if p_benefit_action_id is null then



    --
    ben_benefit_actions_api.create_perf_benefit_actions
      (p_validate               => FALSE
      ,p_benefit_action_id      => l_benefit_action_id
      ,p_process_date           => l_effective_date
      ,p_uneai_effective_date   => NULL
      ,p_mode_cd                => 'S'
      ,p_derivable_factors_flag => 'N'
      ,p_close_uneai_flag       => 'N'
      ,p_validate_flag          => 'N'
      ,p_person_id              => NULL
      ,p_person_type_id         => NULL
      ,p_pgm_id                 => p_ext_dfn_id
      ,p_business_group_id      => p_business_group_id
      ,p_pl_id                  => l_ext_rslt_id
      ,p_popl_enrt_typ_cycl_id  => NULL
      ,p_no_programs_flag       => 'N'
      ,p_no_plans_flag          => 'N'
      ,p_comp_selection_rl      => NULL
      ,p_person_selection_rl    => NULL
      ,p_ler_id                 => NULL
      ,p_organization_id        => NULL
      ,p_benfts_grp_id          => NULL
      ,p_location_id            => NULL
      ,p_pstl_zip_rng_id        => NULL
      ,p_rptg_grp_id            => NULL
      ,p_pl_typ_id              => NULL
      ,p_opt_id                 => NULL
      ,p_eligy_prfl_id          => NULL
      ,p_vrbl_rt_prfl_id        => NULL
      ,p_legal_entity_id        => NULL
      ,p_payroll_id             => NULL
      ,p_request_id             => nvl(l_conc_request_id, fnd_global.conc_request_id )
      ,p_inelg_action_cd        => 'X' --Unique for extract benefit action recs
      ,p_debug_messages_flag    => 'N'
      ,p_object_version_number  => l_object_version_number
      ,p_effective_date         => l_effective_date);
    --
    commit;
    --
    l_line := 6;
    --
    l_line := 7;
    --
    benutils.g_benefit_action_id := l_benefit_action_id;
    benutils.g_thread_id         := 99;
    --
    l_line := 8;

    -- process the subheader

    process_subheader(p_ext_file_id        => l_ext_file_id
                      ,p_ext_dfn_id         => p_ext_dfn_id
                      ,p_ext_rslt_id        => l_ext_rslt_id
                      ,p_data_typ_cd        => l_data_typ_cd
                      ,p_ext_typ_cd         => l_ext_typ_cd
                      ,p_effective_date     => l_effective_date
                      ,p_ext_crit_prfl_id   => l_ext_crit_prfl_id
                      ,p_ext_global_flag    => nvl(l_ext_global_flag, 'N')
                      ,p_business_group_id  => p_business_group_id
                      ,p_subhdr_ghr_from_dt => l_eff_start_date
                      ,p_subhdr_ghr_to_dt   => l_eff_end_date
                      ) ;


    --
    l_person_cnt := 0;

    --
    --- dont build the person information when there is no detail defintion
    --- after intoridction of subheader , there could be setup with subheader alone
    if l_D_lvl_found = 'Y' then
       build_select_statement
         (p_data_typ_cd          => l_data_typ_cd,
          p_ext_crit_prfl_id     => l_ext_crit_prfl_id,
          p_ext_dfn_id           => p_ext_dfn_id,
          p_business_group_id    => p_business_group_id,
          p_effective_date       => l_effective_date,
          p_ext_rslt_id          => l_ext_rslt_id ,
          p_ext_global_flag      => nvl(l_ext_global_flag, 'N') ,
          p_eff_start_date       => l_eff_start_date,
          p_eff_end_date         => l_eff_end_date,
          p_act_start_date       => l_act_start_date,
          p_act_end_date         => l_act_end_date,
          p_select_statement     => l_select_statement, --out
          p_penserv_date         => p_penserv_date);
       --

       begin
         --
         open PersonCur for l_select_statement;

         --
       exception
         --
         when others then
           --
           fnd_file.put_line(fnd_file.log,'Error executing this dynamically build SQL Statement: ');
           -- Update by RChase, 01-MAR-2000
           -- fnd_file.put_line(fnd_file.log, '  ' ||l_select_statement);
           FOR i in 1..LENGTH(l_select_statement) LOOP
             --
             IF mod(i,80)=0 OR i=LENGTH(l_select_statement) THEN
               --
               fnd_file.put_line(fnd_file.log,'  ' ||substr(l_select_statement,l_current_loc+1,i-l_current_loc));
               l_current_loc:=i;
               --
              END IF;
              --
            END LOOP;
            --
            raise;
            --
       end;
       --
       l_line := 10;
       --
       loop
         --
         fetch personcur into l_rec;
         exit when personcur%notfound;
         --

         if check_asg_security (p_person_id      => l_rec.person_id
                               ,p_effective_date => l_effective_date
                               ,p_business_group_id => p_business_group_id ) then

             l_person_cnt := l_person_cnt + 1;
             l_num_rows := l_num_rows + 1;
             --
             l_person_action_id.extend(1);
            --
             select ben_person_actions_s.nextval
             into   l_person_action_id(l_num_rows)
             from   sys.dual;
             --
             l_person_id.extend(1);
             l_person_id(l_num_rows) := l_rec.person_id;
             --
             If l_num_rows = l_chunk_size then
               --
               forall l_count in 1..l_num_rows
                 --
                 insert into ben_person_actions
                     (person_action_id,
                      person_id,
                      ler_id,
                      benefit_action_id,
                      action_status_cd,
                      object_version_number)
                   values
                     (l_person_action_id(l_count),
                      l_person_id(l_count),
                      null,
                      l_benefit_action_id,
                      'U',
                      1);
               --
               select ben_batch_ranges_s.nextval
               into   l_range_id
               from   sys.dual;
               --
               l_start_person_action_id := l_person_action_id(1);
               l_end_person_action_id := l_person_action_id(l_num_rows);
               --
               insert into ben_batch_ranges
                 (range_id,
                  benefit_action_id,
                  range_status_cd,
                  starting_person_action_id,
                  ending_person_action_id,
                  object_version_number)
               values
                 (l_range_id,
                  l_benefit_action_id,
                  'U',
                  l_start_person_action_id,
                  l_end_person_action_id,
                  1);
               --
               -- Dispose of varray
               --
               l_person_action_id.delete;
               l_person_id.delete;
               --
               l_num_rows := 0;
               l_num_range := l_num_range + 1;
               --
             End if;
             --
          End if ;
       End loop;
       close personcur ;

       -- Create a range of data to be multithreaded for the rest of
       -- person_action_id which are left over.
       --
       l_line := 12;
       --
       If l_num_rows > 0 then
         --
         forall l_count in 1..l_num_rows
           --
           -- Bulk bind in person actions
           --
           insert into ben_person_actions
             (person_action_id,
              person_id,
              ler_id,
              benefit_action_id,
              action_status_cd,
              object_version_number)
           values
             (l_person_action_id(l_count),
              l_person_id(l_count),
              null,
              l_benefit_action_id,
              'U',
              1);
         --
         l_num_range := l_num_range + 1;
         --
         -- Get next sequence for the range
         --
         select ben_batch_ranges_s.nextval
         into   l_range_id
         from   sys.dual;
         --
         l_start_person_action_id := l_person_action_id(1);
         l_end_person_action_id := l_person_action_id(l_num_rows);
         --
         insert into ben_batch_ranges
           (range_id,
            benefit_action_id,
            range_status_cd,
            starting_person_action_id,
            ending_person_action_id,
            object_version_number)
         values
              (l_range_id,
            l_benefit_action_id,
            'U',
            l_start_person_action_id,
            l_end_person_action_id,
            1);
         --
         l_num_rows := 0;
         --
         -- Dispose of data in varrays
         --
         l_person_action_id.delete;
         l_person_id.delete;
         --
       End if;
     end if ; -- only when the detail level found
       --
   Else -- benefit_action_id is null
      select count(*)
      into   l_person_cnt
      from ben_person_actions
      where  benefit_action_id = p_benefit_action_id
      and    ACTION_STATUS_CD='U';
--vkodedal 30-Mar-2009    Bug#8335771 -Restart process not spawning threads
    select count(*)
      into   l_num_range
      from ben_batch_ranges
      where  benefit_action_id = p_benefit_action_id
      and    range_status_cd='U';
      ---
      l_benefit_action_id := p_benefit_action_id ;
     ---
   End if; -- End of if benefit_action_id is null;
   --
   -- Now to multithread the code.
   -- We can't multithread unless we are commiting data as we need to
   -- reset the status of the processed ranges and force a commit.
   --
   l_line := 15;
   --
   commit;
   --
   fnd_file.put_line(fnd_file.log, 'Total People Scanned:  ' || l_person_cnt);
   fnd_file.put_line(fnd_file.log, 'l_num_range:  '          || l_num_range);
   fnd_file.put_line(fnd_file.log, 'l_threads:  '            || l_threads);
   --
   l_count := 0;
   --
   If l_person_cnt > 0 and l_conc_request_id <> -1 then
     --
     For l_count in 1..least(l_threads,l_num_range) - 1 loop
       --
       l_request_id := fnd_request.submit_request
       (application => 'BEN'
       ,program     => 'BENXTHRD'
       ,description => 'Thread '||to_char(l_count+1)
       ,sub_request => FALSE
       ,argument1   => l_benefit_action_id
       ,argument2   => p_ext_dfn_id
       ,argument3   => l_count+1 -- so that we start on 2, because master is 1.
       ,argument4   => p_effective_date
       ,argument5   => p_business_group_id
       ,argument6   => l_data_typ_cd
       ,argument7   => l_ext_typ_cd
       ,argument8   => l_ext_crit_prfl_id
       ,argument9   => l_ext_rslt_id
       ,argument10  => l_ext_file_id
       ,argument11  => to_char(l_ext_strt_dt, 'YYYY/MM/DD HH24:MI:SS')
       ,argument12  => to_char(l_ext_end_dt, 'YYYY/MM/DD HH24:MI:SS')
       ,argument13  => l_prmy_sort_cd
       ,argument14  => l_scnd_sort_cd
       ,argument15  => l_output_name
       ,argument16  => l_apnd_rqst_id_flag
       ,argument17  => l_conc_request_id
       ,argument18  => l_use_eff_dt_for_chgs_flag
       ,argument19  => 'N'
       ,argument20  => p_eff_start_date
       ,argument21  => p_eff_end_date
       ,argument22  => p_act_start_date
       ,argument23  => p_act_end_date
       ,argument24  => p_penserv_mode       --------vkodedal changes for penserver
     );
       --
       g_num_processes := g_num_processes + 1;
       g_processes_rec(g_num_processes) := l_request_id;
       --
     End loop;
     --
   End if;
   --
   l_line := 16;
   --
   do_multithread
     (errbuf                     => errbuf
     ,retcode                    => retcode
     ,p_benefit_action_id        => l_benefit_action_id
     ,p_ext_dfn_id               => p_ext_dfn_id
     ,p_thread_id                => 1
     ,p_effective_date           => p_effective_date
     ,p_business_group_id        => p_business_group_id
     ,p_data_typ_cd              => l_data_typ_cd
     ,p_ext_typ_cd               => l_ext_typ_cd
     ,p_ext_crit_prfl_id         => l_ext_crit_prfl_id
     ,p_ext_rslt_id              => l_ext_rslt_id
     ,p_ext_file_id              => l_ext_file_id
     ,p_ext_strt_dt              => to_char(l_ext_strt_dt, 'YYYY/MM/DD HH24:MI:SS')
     ,p_ext_end_dt               => to_char(l_ext_end_dt, 'YYYY/MM/DD HH24:MI:SS')
     ,p_prmy_sort_cd             => l_prmy_sort_cd
     ,p_scnd_sort_cd             => l_scnd_sort_cd
     ,p_output_name              => l_output_name
     ,p_apnd_rqst_id_flag        => l_apnd_rqst_id_flag
     ,p_request_id               => l_conc_request_id
     ,p_use_eff_dt_for_chgs_flag => l_use_eff_dt_for_chgs_flag
     ,p_master_process_flag      => 'Y'
     ,p_eff_start_date           => p_eff_start_date
     ,p_eff_end_date             => p_eff_end_date
     ,p_act_start_date           => p_act_start_date
     ,p_act_end_date             => p_act_end_date
     ,p_penserv_mode             => p_penserv_mode
     );
   --
   l_line := 116;
   --
   check_all_threads_finished
     (p_effective_date      => l_effective_date
     ,p_business_group_id   => p_business_group_id
     ,p_data_typ_cd         => l_data_typ_cd
     ,p_ext_typ_cd          => l_ext_typ_cd
     ,p_ext_crit_prfl_id    => l_ext_crit_prfl_id
     ,p_ext_rslt_id         => l_ext_rslt_id
     ,p_request_id          => l_conc_request_id
     ,p_ext_file_id         => l_ext_file_id
     ,p_ext_strt_dt         => l_ext_strt_dt
     ,p_ext_end_dt          => l_ext_end_dt
     ,p_master_process_flag => 'Y');
   --

  --  Process sub trailer
  --
  process_subtrailer
    (p_ext_rslt_id       => l_ext_rslt_id,
     p_ext_file_id       => l_ext_file_id,
     p_ext_typ_cd        => l_ext_typ_cd,
     p_rcd_typ_cd        => 'L',
     p_business_group_id => p_business_group_id,
     p_effective_date    => l_effective_date,
     p_request_id        => l_conc_request_id,
     p_ext_group_elmt1   =>  ben_ext_thread.g_ext_group_elmt1,
     p_ext_group_elmt2   =>  ben_ext_thread.g_ext_group_elmt2,
     p_ext_crit_prfl_id  => l_ext_crit_prfl_id);
  --
  --  Process Footer Records



  --  Process Header Records
  --
  process_ext_ht_recs
    (p_ext_rslt_id       => l_ext_rslt_id,
     p_ext_file_id       => l_ext_file_id,
     p_ext_typ_cd        => l_ext_typ_cd,
     p_rcd_typ_cd        => 'H',
     p_business_group_id => p_business_group_id,
     p_effective_date    => l_effective_date,
     p_request_id        => l_conc_request_id,
     p_ext_crit_prfl_id  => l_ext_crit_prfl_id);
  --
  --  Process Footer Records
  --
  process_ext_ht_recs
    (p_ext_rslt_id       => l_ext_rslt_id,
     p_ext_file_id       => l_ext_file_id,
     p_ext_typ_cd        => l_ext_typ_cd,
     p_rcd_typ_cd        => 'T',
     p_business_group_id => p_business_group_id,
     p_effective_date    => l_effective_date,
     p_request_id        => l_conc_request_id,
     p_ext_crit_prfl_id  => l_ext_crit_prfl_id );
  --
  -- Call Extract Post Processing Rule.  This rule is a
  -- catch all, that can call a function to do additional
  -- iserting or deleting of records, changing sort order,
  -- updating fields, or anything.  Since this rule is used
  -- with formula function, it returns nothing.  l_output
  -- will not be used here.
  --
  if l_ext_post_prcs_rl is not null then
    --
    l_outputs := benutils.formula
      (p_formula_id        =>  l_ext_post_prcs_rl,
       p_effective_date    => l_effective_date,
       p_business_group_id => p_business_group_id,
       p_param1            => 'EXT_RSLT_ID',
       p_param1_value      => to_char(l_ext_rslt_id)
       --RChase pass extract definition id as input value
      ,p_param2             => 'EXT_DFN_ID'
      ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1)));
    --
  end if;
  --
  commit;  -- anything that the formula did.
  --
  if g_err_cnt > 0 then
    --
    -- Call update API to update Extract Run Rslts row here
    -- Extract status - Completed with Errors
    --
    l_line := 126;
    l_ext_stat_cd  := 'E'  ;
    --
    if l_ext_rslt_id is not null then
      --
       open c_Ext_err_only( l_ext_rslt_id) ;
       fetch c_Ext_err_only into l_dummy ;
       if c_Ext_err_only%notfound then
          l_ext_stat_cd  := 'W'  ;
       end if ;
       close c_Ext_err_only ;


      ben_ext_rslt_api.update_ext_rslt
        (p_validate                       => false
        ,p_ext_rslt_id                    => l_ext_rslt_id
        ,p_run_end_dt                     => sysdate
        ,p_ext_stat_cd                    => l_ext_stat_cd
        ,p_tot_rec_num                    => g_rec_cnt
        ,p_tot_per_num                    => g_per_cnt
        ,p_tot_err_num                    => g_err_cnt
        ,p_program_application_id         => fnd_global.prog_appl_id
        ,p_program_id                     => fnd_global.conc_program_id
        ,p_program_update_date            => sysdate
        ,p_request_id                     => l_conc_request_id
        ,p_object_version_number          => l_xrs_object_version_number
        ,p_effective_date                 => l_effective_date);
      --
    end if;
    --
  else
    --
    if l_ext_rslt_id is not null then
      --
      ben_ext_rslt_api.update_ext_rslt
        (p_validate                       => false
        ,p_ext_rslt_id                    => l_ext_rslt_id
        ,p_run_end_dt                     => sysdate
        ,p_ext_stat_cd                    => 'S'
        ,p_tot_rec_num                    => g_rec_cnt
        ,p_tot_per_num                    => g_per_cnt
        ,p_tot_err_num                    => g_err_cnt
        ,p_program_application_id         => fnd_global.prog_appl_id
        ,p_program_id                     => fnd_global.conc_program_id
        ,p_program_update_date            => sysdate
        ,p_request_id                     => l_conc_request_id
        ,p_object_version_number          => l_xrs_object_version_number
        ,p_effective_date                 => l_effective_date);
      --
    end if;
    --
  end if;
  --
  -- Bug fix 1801219
  update_ht_strt_end_dt(l_ext_rslt_id);
  -- End fix 1801219
  commit;
  --
  if l_conc_request_id <> -1 then
    --
    fnd_message.set_name('BEN', 'BEN_92185_THREAD_SUCCESS');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.put_line(fnd_file.log, ' ');
    --
    l_line := 127;
    --
    thread_summary;
    --
    l_request_id := fnd_request.submit_request
                    (application => 'BEN',
                     program     => 'BENXERRO',
                     description => NULL,
                     sub_request => FALSE,
                     argument1   => l_conc_request_id
                     );
    --
    if l_ext_rslt_id is not null then
      --
      l_request_id := fnd_request.submit_request
                    (application => 'BEN',
                     program     => 'BENXSMRY',
                     description => NULL,
                     sub_request => FALSE,
                     argument1   => l_ext_rslt_id);
      --
    end if;
    --
    if l_kickoff_wrt_prc_flag = 'Y' then
       --
       if l_ext_rslt_id is not null then
          -- when the output is XDO type and display on call different process
          if l_cm_display_flag = 'Y' and l_xdo_template_id is not null then

             open  c_xdoi (l_xdo_template_id ) ;
             fetch c_xdoi  into
                 l_application_short_name ,
                 l_template_code ,
                 l_default_language,
                 l_default_territory ;
             close  c_xdoi ;

             if l_output_type = 'H'  then
                l_output_code := 'HTML' ;
             elsif  l_output_type = 'R'  then
                l_output_code := 'RTF' ;
             elsif  l_output_type = 'P'  then
                l_output_code := 'PDF' ;
             elsif  l_output_type = 'E'  then
                l_output_code := 'EXCEL' ;
             else
                l_output_code := 'PDF' ;
             end if ;

             --- popilate the variable for post poroccing of cm - templates

             l_fnd_out := fnd_request.add_layout
                            (template_appl_name => l_application_short_name,
                             template_code      => l_template_code,
                             template_language  => l_default_language,
                             template_territory => l_default_territory,
                             output_format      => l_output_code
                            ) ;

             --- call the concurrent manager with  XML output


             l_request_id := fnd_request.submit_request
                    (application => 'BEN',
                     program     => 'BENXMLWRIT',
                     description => NULL,
                     sub_request => FALSE,
                     argument1   => l_ext_rslt_id,
                     argument2   => l_output_type ,
		     argument3   => p_out_dummy ,
                     argument4   => null,
                     argument5   => 'BENXMLWRIT'
                   );

          Else

             l_request_id := fnd_request.submit_request
                    (application => 'BEN',
                     program     => 'BENXWRIT',
                     description => NULL,
                     sub_request => FALSE,
                     argument1   => l_ext_rslt_id,
                     argument2   => l_output_type ,
		     argument3   => p_out_dummy ,
                     argument4   => l_xdo_template_id,
                     argument5   => 'BENXWRIT'
                   );
          end if ;
        --
      end if;
      --
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location ('Exiting '||l_proc,15);
  end if;
  --
exception
  --
  when g_job_failure_error then
    --
    if l_conc_request_id <> -1 then
      --
      check_all_threads_finished
        (p_effective_date      => l_effective_date
        ,p_business_group_id   => p_business_group_id
        ,p_data_typ_cd         => l_data_typ_cd
        ,p_ext_typ_cd          => l_ext_typ_cd
        ,p_ext_crit_prfl_id    => l_ext_crit_prfl_id
        ,p_ext_rslt_id         => l_ext_rslt_id
        ,p_request_id          => l_conc_request_id
        ,p_ext_file_id         => l_ext_file_id
        ,p_ext_strt_dt         => l_ext_strt_dt
        ,p_ext_end_dt          => l_ext_end_dt
        ,p_master_process_flag => 'Y');
      --
    end if;
    --
    if l_ext_rslt_id is not null then
      --
      ben_ext_rslt_api.update_ext_rslt
        (p_validate                => false
        ,p_ext_rslt_id             => l_ext_rslt_id
        ,p_run_end_dt              => sysdate
        ,p_ext_stat_cd             => 'F'
        ,p_tot_rec_num             => g_rec_cnt
        ,p_tot_per_num             => g_per_cnt
        ,p_tot_err_num             => g_err_cnt
        ,p_program_application_id  => fnd_global.prog_appl_id
        ,p_program_id              => fnd_global.conc_program_id
        ,p_program_update_date     => sysdate
        ,p_request_id              => l_conc_request_id
        ,p_object_version_number   => l_xrs_object_version_number
        ,p_effective_date          => l_effective_date);
      --
      commit;
      --
    end if;
    --
    if l_conc_request_id <> -1 then
      --
      l_request_id := fnd_request.submit_request
                    (application => 'BEN',
                     program     => 'BENXERRO',
                     description => NULL,
                     sub_request => FALSE,
                     argument1   => l_conc_request_id);
      --
      thread_summary;
      fnd_message.set_name('BEN',g_err_name);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_message.raise_error;
      --
    end if;
    --
  when others then
    --
    -- Call update API to update Extract Run Rslts row here
    -- Extract status - Job Failure
    --
    --
    if l_conc_request_id <> -1 then
      --
      check_all_threads_finished
        (p_effective_date      => l_effective_date
        ,p_business_group_id   => p_business_group_id
        ,p_data_typ_cd         => l_data_typ_cd
        ,p_ext_typ_cd          => l_ext_typ_cd
        ,p_ext_crit_prfl_id    => l_ext_crit_prfl_id
        ,p_ext_rslt_id         => l_ext_rslt_id
        ,p_request_id          => l_conc_request_id
        ,p_ext_file_id         => l_ext_file_id
        ,p_ext_strt_dt         => l_ext_strt_dt
        ,p_ext_end_dt          => l_ext_end_dt
        ,p_master_process_flag => 'Y');
      --
    end if;
    --
    if l_ext_rslt_id is not null then
      --
      ben_ext_rslt_api.update_ext_rslt
        (p_validate               => false
        ,p_ext_rslt_id            => l_ext_rslt_id
        ,p_run_end_dt             => sysdate
        ,p_ext_stat_cd            => 'F'
        ,p_tot_rec_num            => g_rec_cnt
        ,p_tot_per_num            => g_per_cnt
        ,p_tot_err_num            => g_err_cnt
        ,p_program_application_id => fnd_global.prog_appl_id
        ,p_program_id             => fnd_global.conc_program_id
        ,p_program_update_date    => sysdate
        ,p_request_id             => l_conc_request_id
        ,p_object_version_number  => l_xrs_object_version_number
        ,p_effective_date         => l_effective_date);
      --
      write_error(p_err_num           => null,
                  p_err_name          => substr(sqlerrm, 1, 200),
                  p_typ_cd            => 'F',
                  p_person_id         => null,
                  p_request_id        => l_conc_request_id,
                  p_ext_rslt_id       => l_ext_rslt_id,
                  p_business_group_id => p_business_group_id);
      commit;
      --
    end if;
    --
    if l_conc_request_id <> -1 then
      --
      l_request_id := fnd_request.submit_request
                    (application => 'BEN',
                     program     => 'BENXERRO',
                     description => NULL,
                     sub_request => FALSE,
                     argument1   => l_conc_request_id);
      --
      thread_summary;
      fnd_message.set_name('PER', 'FFU10_GENERAL_ORACLE_ERROR');
      fnd_message.set_token('2', substr(sqlerrm, 1, 200));
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_message.raise_error;
      --
    end if;
    --
End process;



procedure  ext_restart_clear(
            p_benefit_action_id      in number
           ,p_ext_rslt_id            in number
           ,p_start_person_action_id in number
           ,p_end_person_action_id   in number
           ,p_effective_date         in date
          ) is

  l_package        varchar2(80);

  cursor per_cursor is
   select person_id
   from   ben_person_actions act
   where act.person_action_id between p_start_person_action_id
                              and     p_end_person_action_id
     and act.benefit_action_id = p_benefit_action_id
     and action_status_cd <> 'P'  ;

   cursor c_xrdt (c_person_id number) is
   select ext_rslt_dtl_id,
          object_version_number
   from ben_ext_rslt_dtl
   where  person_id = c_person_id
     and  ext_rslt_id = p_ext_rslt_id ;


   cursor c_xrer (c_person_id number) is
   select ext_rslt_err_id,
          object_version_number
   from ben_ext_rslt_err
   where  person_id = c_person_id
     and  ext_rslt_id = p_ext_rslt_id ;

   ---

   l_object_version_number number ;

begin
   if g_debug then
     l_package := g_package||'.ext_restart_clear';
     hr_utility.set_location ('Entering '||l_package,10);
     hr_utility.set_location ('result_id  '||p_ext_rslt_id,10);
   end if;

   for pact in per_cursor
   loop

      if g_debug then
        hr_utility.set_location ('person '||pact.person_id,10);
      end if;
     ---delete extract results for the person proccessed
     ---  and in the error range
     for xrdt in c_xrdt(pact.person_id)
     loop

         if g_debug then
           hr_utility.set_location ('deleting '|| pact.person_id, 177);
         end if;

         l_object_version_number := xrdt.object_version_number ;
         ben_EXT_RSLT_DTL_api.delete_EXT_RSLT_DTL
               (p_ext_rslt_dtl_id       => xrdt.ext_rslt_dtl_id
               ,p_object_version_number => l_object_version_number
               );
     end loop ;

     ---delete all the error created for the persopns
     for xrer in c_xrer(pact.person_id)
     loop

         if g_debug then
           hr_utility.set_location ('deleting error'||pact.person_id, 177);
         end if;

         l_object_version_number := xrer.object_version_number ;
         ben_EXT_RSLT_ERR_api.delete_EXT_RSLT_ERR
               (p_ext_rslt_err_id       => xrer.ext_rslt_err_id
               ,p_object_version_number => l_object_version_number
               ,p_effective_date        => p_effective_date
               );
     end loop ;

   end loop ;
   if g_debug then
     hr_utility.set_location ('Leaving '||l_package,10);
   end if;
end  ext_restart_clear ;
--
--old proc. Not used
--
/*procedure restart(errbuf                    out nocopy    varchar2
                 ,retcode                   out nocopy    varchar2
                 ,p_benefit_action_id       in     number
                 ,p_ext_rslt_id             in     number  default null) is
--
l_package        varchar2(80);

cursor c_parameters is
select pgm_id
       ,pl_id
       ,business_group_id
       ,process_date
from   ben_benefit_actions ben
where  ben.benefit_action_id = p_benefit_action_id;


cursor c_range_err is
  select *
  from ben_batch_ranges ran
  where ran.range_status_cd = 'E'
  and ran.BENEFIT_ACTION_ID  = P_BENEFIT_ACTION_ID;


--
  l_parameters c_parameters%rowtype;
  l_errbuf       varchar2(80);
  l_retcode      number;
  l_ext_rslt_id number ;
--
begin
   g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.restart';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
    --
    fetch c_parameters into l_parameters;
    if c_parameters%notfound then
      --
      fnd_message.set_name('BEN','BEN_91666_BENMNGLE_NO_RESTART');
      fnd_message.raise_error;
      --
    end if;
    --
  close c_parameters;

  l_ext_rslt_id :=  l_parameters.pl_id ;
  if l_ext_rslt_id is null  then
     l_ext_rslt_id := p_ext_rslt_id ;
     if l_ext_rslt_id is null  then
       --- create new error for this
       fnd_message.set_name('BEN','BEN_91666_RSLT_ID_NOT_FOUND');
       fnd_message.raise_error;
     end if ;
  end if ;



  --- Clearup all detail of the person processed
  --- and the action_status not updated
  --- changes the errored status of the ranges to
  --- unprocessed
  if l_ext_rslt_id is not null then
     for rng in  c_range_err
     Loop
        if g_debug then
          hr_utility.set_location ('range id  '||rng.starting_person_action_id,10);
        end if;
        ext_restart_clear(
            p_benefit_action_id => p_benefit_action_id
           ,p_ext_rslt_id       => l_ext_rslt_id
           ,p_start_person_action_id => rng.starting_person_action_id
           ,p_end_person_action_id   => rng.ending_person_action_id
           ,p_effective_date         => l_parameters.process_date
          ) ;
        ---- range_id is updated
        update ben_batch_ranges
          set range_Status_cd = 'U'
          where  range_id = rng.range_id ;
     end loop ;
  end if ;



  process(l_errbuf
          ,l_retcode
          ,p_benefit_action_id
          ,l_parameters.pgm_id -- cover for ext_id
          ,fnd_date.date_to_canonical(l_parameters.process_date)
          ,l_parameters.business_group_id
          ,l_ext_rslt_id);

  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;
end; */
--
--new proc
--
-- =============================================================================
-- ~ Chk_PQP_Extract:
-- =============================================================================
PROCEDURE Chk_PQP_Extract
         (p_ext_dfn_id        IN NUMBER
         ,p_ext_rslt_id       IN NUMBER
         ,p_business_group_id IN NUMBER
         ,p_conc_req_id       IN NUMBER
          ) AS
   -- Cursor to check if the extract is PQP extract.
   CURSOR check_pqp_extract (c_ext_dfn_id        IN NUMBER,
                             c_business_group_id IN NUMBER) IS
   SELECT  ea.ext_dfn_type
     FROM  ben_ext_dfn ed,
           per_business_groups bg,
           pqp_extract_attributes ea
    WHERE ((bg.business_group_id = ed.business_group_id)OR
          (bg.legislation_code  = ed.legislation_code) OR
          (ed.business_group_id IS NULL AND
           ed.legislation_code  IS NULL)
          )
      AND bg.business_group_id = c_business_group_id
      AND ed.ext_dfn_id        = ea.ext_dfn_id
      AND ed.ext_dfn_id        = c_ext_dfn_id
      AND ea.ext_dfn_type in
        ('PEN_FPR', 'PEN_CHG', 'FID_PTC','FID_CAC',
         'FID_ERC', 'FID_LPY', 'FID_ATE','FID_CHG',
         'GBL_FPR', 'GBL_CHG', 'GBL_MUL_CHG');
   --
   CURSOR csr_org_req (c_ext_dfn_id IN NUMBER
                      ,c_ext_rslt_id IN NUMBER
                      ,c_business_group_id IN NUMBER) IS
   SELECT bba.pgm_id
         ,bba.pl_id
         ,bba.benefit_action_id
         ,bba.business_group_id
         ,bba.process_date
         ,bba.request_id
     FROM ben_benefit_actions bba
    WHERE bba.pl_id  = c_ext_rslt_id
      AND bba.pgm_id = c_ext_dfn_id
      AND bba.business_group_id = c_business_group_id;
   l_org_req            csr_org_req%ROWTYPE;

   -- Cursor to get the extract parameters of the last req.
   CURSOR csr_req_params ( c_req_id IN NUMBER) IS
   SELECT *
     FROM fnd_concurrent_requests
    WHERE request_id = c_req_id;

   l_conc_params        csr_req_params%ROWTYPE;
   l_pqp_extract        BOOLEAN;
   l_ext_type           VARCHAR2(50);
   l_session_id         NUMBER;
   l_conc_request_id    NUMBER;
   l_proc_name          VARCHAR2(150);

BEGIN
  IF g_debug THEN
     l_proc_name := g_package||'.Chk_PQP_Extract';
     Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  END IF;

   OPEN check_pqp_extract (p_ext_dfn_id,
                          p_business_group_id);
  FETCH check_pqp_extract INTO l_ext_type;
  l_pqp_extract := check_pqp_extract%FOUND;
  CLOSE check_pqp_extract;
  --
  -- Return if not a PQP seeded/copied extract.
  --
  IF NOT l_pqp_extract THEN
    RETURN;
  END IF;
  --
  -- Delete the existing completed extracts for the extract def. within
  -- this business group.
  --
  DELETE FROM  pay_us_rpt_totals
  WHERE tax_unit_id        = p_conc_req_id
    AND attribute5         = 'EXTRACT_COMPLETED'
    AND business_group_id  = p_business_group_id
    AND organization_id    = p_business_group_id
    AND location_id        = p_ext_dfn_id;

  OPEN csr_org_req (c_ext_dfn_id        => p_ext_dfn_id
                   ,c_ext_rslt_id       => p_ext_rslt_id
                   ,c_business_group_id => p_business_group_id);
  FETCH csr_org_req INTO l_org_req;
  CLOSE csr_org_req;
  --
  -- Get the old paramters used by the extract, based on the concurrent
  -- request id passed.
  --
   OPEN csr_req_params(l_org_req.request_id);
  FETCH csr_req_params INTO l_conc_params;
  CLOSE csr_req_params;
  --
  -- Get session id and the concurrent req. id
  --
  l_session_id      :=  Userenv('SESSIONID');
  l_conc_request_id :=   Fnd_Global.conc_request_id;
  --
  IF l_ext_type IN
     ('PEN_FPR', 'PEN_CHG', 'FID_PTC','FID_CAC',
      'FID_ERC', 'FID_LPY', 'FID_ATE','FID_CHG') THEN

    INSERT INTO pay_us_rpt_totals
    (session_id         -- session id
    ,organization_name  -- Conc. Program Name
    ,business_group_id  -- business group id
    ,organization_id    -- -do-
    ,location_id        -- Ext Def Id
    ,tax_unit_id        -- concurrent request id
    ,value1             -- extract def. id
    ,value2             -- element set id
    ,value3             -- element type id
    ,value4             -- Payroll Id
    ,value5             -- GRE Org Id
    ,value6             -- Consolidation set id
    ,attribute1         -- Selection Criteria
    ,attribute2         -- Reporting dimension
    ,attribute3         -- Extract Start Date
    ,attribute4         -- Extract End Date
    ,attribute5         -- Status
    )
    VALUES
    (l_session_id
    ,'US Pension Extracts'
    ,p_business_group_id      -- p_business_group_id
    ,p_business_group_id      -- Org Id
    ,p_ext_dfn_id             -- location id for key
    ,l_conc_request_id        -- New Conc Req Id.
    ,l_conc_params.argument2  -- p_ext_dfn_id
    ,l_conc_params.argument9  -- p_element_set_id
    ,l_conc_params.argument12 -- p_element_type_id
    ,l_conc_params.argument17 -- p_payroll_id
    ,l_conc_params.argument16 -- p_gre_id
    ,l_conc_params.argument20 -- p_con_set
    ,l_conc_params.argument7  -- p_selection_criteria
    ,l_conc_params.argument5  -- p_reporting_dimension
    ,l_conc_params.argument14 -- p_start_date
    ,l_conc_params.argument15 -- p_end_date
    ,'EXTRACT_RUNNING'        -- Status
    );
    ELSIF l_ext_type IN
        ('GBL_FPR', 'GBL_CHG', 'GBL_MUL_CHG')   THEN

    INSERT INTO pay_us_rpt_totals
    (session_id         -- session id
    ,organization_name  -- Conc. Program Name
    ,business_group_id  -- business group id
    ,organization_id    -- -do-
    ,location_id        -- Ext Def Id
    ,tax_unit_id        -- concurrent request id
    ,value1             -- extract def. id
    ,value2             -- element set id
    ,value3             -- element type id
    ,value4             -- Payroll Id
    ,value5             -- GRE Org Id
    ,value6             -- Consolidation set id
    ,attribute1         -- Selection Criteria
    ,attribute2         -- Reporting dimension
    ,attribute3         -- Extract Start Date
    ,attribute4         -- Extract End Date
    ,attribute5         -- Organization Name
    ,attribute6         -- Person Type
    ,attribute7         -- Location
    )
    VALUES
    (l_session_id               -- session id
    ,'Global Pension Extracts'
    ,p_business_group_id        -- p_business_group_id
    ,p_business_group_id        -- Org Id
    ,p_ext_dfn_id               -- ext dfn id for key purpose
    ,l_conc_request_id          -- New Conc Req Id.
    ,l_conc_params.argument2    -- p_ext_dfn_id
    ,l_conc_params.argument8    -- p_element_set_id
    ,l_conc_params.argument10   -- p_element_type_id
    ,l_conc_params.argument15   -- p_payroll_id
    ,l_conc_params.argument14   -- p_gre_id
    ,l_conc_params.argument18   -- p_con_set
    ,l_conc_params.argument6    -- p_selection_criteria
    ,l_conc_params.argument4    -- p_reporting_dimension
    ,l_conc_params.argument12   -- p_start_date
    ,l_conc_params.argument13   -- p_end_date
    ,l_conc_params.argument20   -- p_org_id
    ,l_conc_params.argument21   -- p_person_type_id
    ,l_conc_params.argument22   -- p_location_id
    );

  END IF;
  IF g_debug THEN
     Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  END IF;
END Chk_PQP_Extract;

-- =============================================================================
-- ~ Restart:
-- =============================================================================
procedure Restart(errbuf                    out nocopy  varchar2
                 ,retcode                   out nocopy  varchar2
                 ,p_ext_dfn_id              in  number
                 ,p_concurrent_request_id   in  number) is


  l_errbuf            varchar2(80);
  l_retcode           number;
  l_ext_rslt_id       number ;
  l_benefit_action_id number;
  l_business_group_id number;
  l_session_id        number;
  l_request_id        number;
  l_pqp_extract       boolean;
  l_dummy             varchar2(1);
  l_package           varchar2(80);

  cursor c_parameters is
  select pgm_id
        ,pl_id
        ,benefit_action_id
        ,business_group_id
        ,process_date
    from ben_benefit_actions ben
   where ben.request_id = p_concurrent_request_id;
  l_parameters        c_parameters%rowtype;

  cursor c_range_err is
   select *
     from ben_batch_ranges ran
    where ran.range_status_cd  in ( 'E', 'W')
      and ran.benefit_action_id  = l_benefit_action_id;


BEGIN

  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_package := g_package||'.restart';
    hr_utility.set_location ('Entering '||l_package,10);
  end if;
  --
  -- get the parameters for a previous run and do a restart
  --
  open c_parameters;
    --
    fetch c_parameters into l_parameters;
    if c_parameters%notfound then
      --
      fnd_message.set_name('BEN','BEN_91666_BENMNGLE_NO_RESTART');
      fnd_message.raise_error;
      --
    end if;
    --
  close c_parameters;

  l_ext_rslt_id       :=  l_parameters.pl_id ;
  l_benefit_action_id := l_parameters.benefit_action_id;
  l_business_group_id := l_parameters.business_group_id;

  if l_ext_rslt_id is null  then
     -- create new error for this
     fnd_message.set_name('BEN','BEN_91666_RSLT_ID_NOT_FOUND');
     fnd_message.raise_error;
  end if ;
  --
  -- Check to see if the extract being re-started is a PQP US/Global seeded
  -- or copied extract, if yes then the following procedure insert the values
  -- of the extract parameters of the failed run into table pay_us_rpt_totals.
  --
  Chk_PQP_Extract
  (p_ext_dfn_id        => p_ext_dfn_id
  ,p_ext_rslt_id       => l_ext_rslt_id
  ,p_business_group_id => l_business_group_id
  ,p_conc_req_id       => p_concurrent_request_id
   );
  --
  -- Clearup all detail of the person processed and the action_status
  -- not updated changes the errored status of the ranges to unprocessed
  --
  if l_ext_rslt_id is not null then
     for rng in  c_range_err
     Loop
        if g_debug then
          hr_utility.set_location ('range id  '||rng.starting_person_action_id,10);
        end if;
        ext_restart_clear
        (p_benefit_action_id      => l_benefit_action_id
        ,p_ext_rslt_id            => l_ext_rslt_id
        ,p_start_person_action_id => rng.starting_person_action_id
        ,p_end_person_action_id   => rng.ending_person_action_id
        ,p_effective_date         => l_parameters.process_date
         ) ;
        -- range_id is updated
        update ben_batch_ranges
           set range_status_cd = 'U'
         where range_id        = rng.range_id;
     end loop;
  end if ;
  -- Re-process the failed records.

  process(errbuf               =>  l_errbuf
         ,retcode              =>  l_retcode
         ,p_benefit_action_id  =>  l_benefit_action_id
         ,p_ext_dfn_id         =>  l_parameters.pgm_id -- cover for ext_id
         ,p_effective_date     =>  fnd_date.date_to_canonical(l_parameters.process_date)
         ,p_business_group_id  =>  l_parameters.business_group_id
         ,p_ext_rslt_id        =>  l_ext_rslt_id);

  /*
  process(l_errbuf
         ,l_retcode
         ,l_benefit_action_id
         ,l_parameters.pgm_id -- cover for ext_id
         ,fnd_date.date_to_canonical(l_parameters.process_date)
         ,l_parameters.business_group_id
         ,l_ext_rslt_id);

  */

  if g_debug then
    hr_utility.set_location ('Leaving '||l_package,10);
  end if;

end Restart;

-- =============================================================================
-- ~ Load_Extract:
-- =============================================================================
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
       ) is


   l_proc                       varchar2(72) := g_package||'Load_extract';


   --
   cursor c_threads(p_request_id number) is
   select null
   from   fnd_concurrent_requests fnd
   where  /*fnd.phase_code <> 'C' and */
         fnd.request_id = p_request_id;
   --
   cursor c_bg_name is
   select name
     from per_business_groups  bg
     where  business_group_id = p_business_group_id ;

   cursor c_ext is
   select name,business_group_id
     from ben_ext_file
    where ext_file_id  = p_extract_file_id ;

   l_business_goup_name    per_business_groups.name%Type  ;
   l_request_id            number ;
   l_business_group_name   varchar2(2000) ;
   l_business_group_id     number ;
   l_view_name             varchar2(2000) ;
   l_loader_file           varchar2(2000) := p_loader_file ;
   l_ext_file_name         varchar2(2000) ;
   l_seeded                varchar2(2000) := p_seeded     ;
   l_dummy                 varchar2(1) ;
   l_validate              varchar2(2000) ;
   l_override              varchar2(2000) ;
begin
  --
  fnd_msg_pub.initialize;
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
       hr_utility.set_location('p_mode    '||  p_mode ,10) ;
       hr_utility.set_location('p_seeded    '||  p_seeded ,10) ;
       hr_utility.set_location('p_loader_file '|| p_loader_file,10) ;
       hr_utility.set_location('p_file_name  '||  p_file_name ,10) ;
       hr_utility.set_location('p_view_name '||   p_view_name,10) ;
       hr_utility.set_location('p_extract_file_id'||p_extract_file_id ,10) ;
       hr_utility.set_location('p_business_group_id'||p_business_group_id ,10) ;
       hr_utility.set_location('p_validate  '|| p_validate ,10) ;
  --
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint SUBMIT_COPY_REQUEST;
  --
  hr_utility.set_location(l_proc, 20);

   open c_bg_name ;
   fetch c_bg_name into  l_business_goup_name ;
   if  c_bg_name%notfound  then
       close c_bg_name ;
       fnd_message.set_name('BEN','BEN_91000_INVALID_BUS_GROUP');
       fnd_message.raise_error;
   end if ;
   close c_bg_name ;

  -- decide whether it is  seede or not for when the process is export
  if p_mode = 'EXP' then
     -- get the extract name and validate
     open c_ext  ;
     fetch c_ext into l_ext_file_name,l_business_group_id ;
     close c_ext ;
     --
     if  l_ext_file_name is  null then
         fnd_message.set_name('BEN','BEN_91000_INVALID_EXT_NAME');
         fnd_message.raise_error;
     end if ;
     --
     if l_business_group_id is not null then
        l_seeded := 'N' ;
        l_business_group_name := 'BUSINESS_GROUP='|| l_business_goup_name ;
     else
        l_seeded := 'Y' ;
     end if ;

     l_ext_file_name := 'FILE_NAME='|| l_ext_file_name ;
  else
    --- import to system
    -- the upload only suppport business group base uploads
    -- seeded should be uploaded from hrglobals
    l_business_group_name := 'UPLOAD_BUSINESS_GROUP='|| l_business_goup_name ;
    l_view_name  := 'LEG_VIEW=' || 'BEN_PL_V' ;

    -- if validate mode then set the variable
    if p_validate = 'Y' then
       l_validate  := 'VALIDATE_MODE='|| p_validate ;
    end if ;

    if p_allow_override = 'Y' then
        l_override  :=  'EXT_OVERRIDE='||p_allow_override ;
    end if ;
  end if ;


  hr_utility.set_location('Bg Name ' || l_business_group_name , 20);


  if p_file_name is null then
     fnd_message.set_name('BEN','BEN_91000_INVALID_FILE_NAME');
     fnd_message.raise_error;
  end if ;

  if l_loader_file is null then
     l_loader_file :=   '@ben:/patch/115/import/benextse.lct';
  end if ;

  --

  if p_mode  = 'EXP' then
     l_request_id := fnd_request.submit_request
                  (application => 'BEN'
                  ,program     => 'BENXUPLDR'
                  ,description => NULL
                  ,sub_request => FALSE
                  ,argument1   => 'DOWNLOAD'
                  ,argument2   => l_loader_file
                  ,argument3   => p_file_name
                  ,argument4   => 'EXTRACT'
                  ,argument5   => l_ext_file_name
                  ,argument6   => 'CM_DOWNLOAD=Y'
                  ,argument7   => l_business_group_name
                 );
  else
     l_request_id := fnd_request.submit_request
                  (application => 'BEN'
                  ,program     => 'BENXDNLDR'
                  ,description => NULL
                  ,sub_request => FALSE
                  ,argument1   => 'UPLOAD_PARTIAL'
                  ,argument2   => l_loader_file
                  ,argument3   => p_file_name
                  ,argument4   => 'EXTRACT'
                  ,argument5   => l_view_name
                  ,argument6   => l_business_group_name
                  ,argument7   => l_validate
                  ,argument8   => l_override
                 );
  end if ;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when app_exception.application_exception then

    fnd_msg_pub.add;

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO SUBMIT_COPY_REQUEST;
    raise;
    --
end Load_extract;


--
End ben_ext_thread;

/
