--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_UTILS" as
/* $Header: benrptut.pkb 120.5.12010000.2 2008/08/05 14:52:56 ubhat ship $ */
/* ===========================================================================
 * Name:
 *   Batch_utils
 * Purpose:
 *   This package is provide all batch utility and data structure to simply
 *   batch process.
 * History:
 *   Date        Who       Version  What?
 *   ----------- --------- -------  -----------------------------------------
 *   20 Nov 1998 Hdang     115.0    Created.
 *   11 Dec 1998 Hdang     115.1    Add new functions (ret_str).
 *   15 Dec 1998 Hdang     115.2    Add text into error message, and call Graham
 *                                  new procedure to load proc info into table.
 *   18 Dec 1998 jcarpent  115.3    Change c_person cursor
 *   22 Dec 1998 Hdang     115.4    Add audit_log into print_paramater.
 *   23 Dec 1998 Hdang     115.5    Move person info into header.
 *   29 Dec 1998 Hdang     115.6    Remove ini_proc_info from ini.
 *   30 Dec 1998 Hdang     115.7    Add actn_cd in comp_cache.
 *   06-Jan-1999 Hdang     115.8    Added new procedure for generic reports.
 *   13-Jan-1999 Hdang     115.12   Set l_all = 'All'
 *   03-Mar-1999 Stee      115.13   Removed dbms_output.put_line.
 *   22-Mar-1999 TMathers  115.16   CHanged -MON- to /MM/
 *   18-May-1999 jcarpent  115.17   Use trunc not to_char for zero of time.
 *   20-JUL-1999 Gperry    115.18   genutils -> benutils package rename.
 *   27-JUL-1999 mhoyes    115.19 - Changed g_report_rec ref it ben_type.
 *   28-JUL-1999 mhoyes    115.20 - Made oipl_id hashing use > rather than <
 *   19-Oct-1999 maagrawa  115.21 - Modified procedure write_error_rec to
 *                                  get correct error code.
 *                                - Write the log information to the log file.
 *   03-Nov-1999 lmcdonal  115.22   Added non_person_cd to end_process,
 *                                  write_logfile, create_restart...
 *
 *   18-JAN-00   pbodla    115.23   Fixed bug 4146(WWBUG 1120687)
 *                                  p_business_group_id added to benutils.formula
 *                                  call.
 *   04-APR-00   mmogel    115.24   Added tokens to messages to make them
 *                                  more meaningful to the user
 *   11-APR-00   gperry    115.25   Added application id to get over FIDO
 *                                  dup rows issue.
 *   18-APR-00   shdas     115.26   changed c1 cursor(cache_comp_object) to
 *                                  outer join oipl with result so that rslts
 *                                  without oipls appear in the log and audit reports.(2641)
 *   12-Mar-01   pbodla    115.14   - Bug 1674123 : Modified print_parameters
 *                                  mode_cd is used close_cd for Close
 *                                  enrollment process.
 *   21-JAN-02  aprabhak   115.27   -added enrt_perd_id to print_parameters
 *   12-Mar-02  maagrawa   115.28   - Added missing dbdrv command.
 *   14-Mar-02  rpillay    115.28   - UTF8 Changes Bug 2254683
 *   08-Jun-02  pabodla    115.29     Do not select the contingent worker
 *                                    assignment when assignment data is
 *                                    fetched.
 *   18-Jun-02  ikasire    115.30   Bug 2394141 fixes
 *   26-Dec-02  rpillay    115.33   NOCOPY changes
 *   13-Feb-03  stee       115.34   HR MLS changes.
 *   14-Feb-03  tmathers   115.35   Added whenever oserror.
 *   02-Jun-03  glingapp   115.36   bug 2978945 Added function rows_exist. This is
 *                                  called to check for child records of derived
 *			  	    factors.
 *   30-Jun-03  vsethi     115.37   Changed reference for table ben_rptg_grp
 *			            MLS compliant view ben_rptg_grp_v
 *   12-Jan-04  vvprabhu   115.38   Changed the calls to dbms_describe.dbms_procedure
 *                                  to hr_general.describe_procedure in procedure
 *                                  get_rpt_header
 *   21-Jun-04  kmahendr   115.39   Corrected Prompt for legal Entity.
 *   20-Aug-04  nhunur     115.40   Added a procedure for person selection rule
 *                                  with proper error handling.
 *   02-Nov-04  abparekh   115.41   Bug 3517604  - Added p_date_From to procedure
 *                                  standard_header
 *   03-Nov-06  swjain     115.42   Bug 5331889 - passed person_id as input param
 *                                  in person_selection_rule and added input1 as
 *                                  additional param for future use
 *   16-aug-06  gsehgal    115.43   Bug: 5450842 -- now p_mode will not be printed when
 *				    passed as null
 *   12-Dec-06  nkkrishn   115.44   5643310 - Invalid Person Records in Person Seleciton
 *                                  Rule will now be logged instead of erroring out the
 *				    entire process
 *   22-Jun-07  nhunur     115.45   perf changes
 *   09-Aug-07  vvprabhu   115.23   Bug 5857493 - added g_audit_flag to
 *                                  control person selection rule error logging
 *   22-Feb-2008 rtagarra  115.24   Bug 6840074
 * ===========================================================================
 */
--
-- Global variables declaration.
--
g_package              varchar2(30) := 'ben_batch_utils.';
g_proc_info            g_process_information_rec;
g_cache_person_types   g_cache_person_types_rec;
g_pgm_tbl              g_pgm_table;
g_pl_tbl               g_pl_table;
g_pl_typ_tbl           g_pl_typ_table;
g_opt_tbl              g_opt_table;
--
-- ============================================================================
--                          <<Function: ret_str>>
-- ============================================================================
--
Function ret_str(p_str varchar2, p_len number default 30) return varchar2 is
Begin
  return(rpad(nvl(substr(p_str,1,p_len),' '),p_len));
End;
--
Function ret_str(p_num number, p_len number default 15) return varchar2 is
Begin
  return(rpad(nvl(to_char(p_num),' '),p_len));
End;
--
Function ret_str(p_date date, p_len number default 12) return varchar2 is
Begin
  return(rpad(nvl(to_char(p_date,'DD/MM/YYYY'),' '),p_len));
End;
--
-- ============================================================================
--                            <<Ini_person>>
-- ============================================================================
--
Procedure ini_person is
  L_proc        varchar2(80) := g_package||'.ini_person';
Begin
  hr_utility.set_location ('Entering '|| l_proc,5);
  g_cache_person := NULL;
  hr_utility.set_location ('Leaving ' || l_proc,10);
End ini_person;
--
-- ============================================================================
--                            <<Ini_Comp_obj>>
-- ============================================================================
--
Procedure ini_comp_obj is
  L_proc        varchar2(80) := g_package||'.ini_comp_obj';
Begin
  hr_utility.set_location ('Entering ' || l_proc, 5);
  g_cache_comp.delete;
  g_cache_comp_cnt := 0;
  hr_utility.set_location ('Leaving '  || l_proc, 10);
End ini_comp_obj ;
--
-- ============================================================================
--                            <<Cache_Comp_obj>>
-- ============================================================================
--
Procedure Cache_comp_obj(p_pgm_id            in number     Default NULL
                        ,p_pl_typ_id         in Number     Default NULL
                        ,p_pl_id             in Number     Default NULL
                        ,p_oipl_id           in Number     Default NULL
                        ,p_opt_id            in number     Default NULL
                        ,p_bnft_amt          in number     Default NULL
                        ,p_uom               in varchar2   Default NULL
                        ,p_cst_amt           in number     Default NULL
                        ,p_credit_amt        in number     Default NULL
                        ,p_cvg_strt_dt       in date       Default NULL
                        ,p_cvg_thru_dt       in date       Default hr_api.g_eot
                        ,p_prtt_enrt_rslt_id in number     default NULL
                        ,p_effective_date    in date
                        ,P_actn_cd           in varchar2
                        ,p_suspended         in varchar2   default 'N'
                        ) is
  Cursor c1 is
     Select a.pgm_id, a.pl_typ_id, a.pl_id, a.oipl_id, b.opt_id
           ,a.bnft_amt, a.uom
           ,a.enrt_cvg_strt_dt, a.enrt_cvg_thru_dt
       From ben_prtt_enrt_rslt_f a
           ,ben_oipl_f b
      Where a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and a.prtt_enrt_rslt_stat_cd is null
        and p_effective_date between
              a.effective_start_date and a.effective_end_date
        and a.oipl_id = b.oipl_id(+)
        and p_effective_date between
              nvl(b.effective_start_date,p_effective_date)
              and nvl(b.effective_end_date,p_effective_date)
           ;
  l_rec         c1%rowtype;
  l_cnt         Number(15) := g_cache_comp_cnt;
  L_proc        varchar2(80) := g_package||'.Cache_comp_obj';
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  l_cnt := l_cnt + 1;
  If (p_prtt_enrt_rslt_id is not NULL) then
    Open c1;
    fetch c1 into l_rec;
    close c1;
    g_cache_comp(l_cnt).pgm_id      := l_rec.pgm_id;
    g_cache_comp(l_cnt).pl_typ_id   := l_rec.pl_typ_id;
    g_cache_comp(l_cnt).pl_id       := l_rec.pl_id;
    g_cache_comp(l_cnt).oipl_id     := l_rec.oipl_id;
    g_cache_comp(l_cnt).opt_id      := l_rec.opt_id;
    g_cache_comp(l_cnt).bnft_amt    := l_rec.bnft_amt;
    g_cache_comp(l_cnt).uom         := l_rec.uom;
    g_cache_comp(l_cnt).cvg_strt_dt := l_rec.enrt_cvg_strt_dt;
    g_cache_comp(l_cnt).cvg_thru_dt := l_rec.enrt_cvg_thru_dt;
    g_cache_comp(l_cnt).prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
    g_cache_comp(l_cnt).actn_cd     := p_actn_cd;
  Else
    g_cache_comp(l_cnt).pgm_id      := p_pgm_id;
    g_cache_comp(l_cnt).pl_typ_id   := p_pl_typ_id;
    g_cache_comp(l_cnt).pl_id       := p_pl_id;
    g_cache_comp(l_cnt).oipl_id     := p_oipl_id;
    g_cache_comp(l_cnt).opt_id      := p_opt_id;
    g_cache_comp(l_cnt).bnft_amt    := p_bnft_amt;
    g_cache_comp(l_cnt).uom         := p_uom;
    g_cache_comp(l_cnt).cvg_strt_dt := p_cvg_strt_dt;
    g_cache_comp(l_cnt).cvg_thru_dt := p_cvg_thru_dt;
    g_cache_comp(l_cnt).prtt_enrt_rslt_id := NULL;
    g_cache_comp(l_cnt).actn_cd     := p_actn_cd;
  End if;
  If p_actn_cd = 'UPD' then
    g_cache_comp(l_cnt).upd_flag := TRUE;
  Elsif p_actn_cd = 'INS' then
    g_cache_comp(l_cnt).ins_flag := TRUE;
  Elsif p_actn_cd = 'DEL' then
    g_cache_comp(l_cnt).del_flag := TRUE;
  Elsif p_actn_cd = 'DEF' then
    g_cache_comp(l_cnt).def_flag := TRUE;
  End if;
  If (p_suspended = 'Y') then
    g_cache_comp(l_cnt).susp_flag := TRUE;
  End if;
  g_cache_comp_cnt := l_cnt;
  hr_utility.set_location ('Leaving '||l_proc,10);
End Cache_comp_obj;
--
-- ============================================================================
--                            <<get_actn_cd>>
-- ============================================================================
--
Function  get_actn_cd(p_def_flag   Boolean
                     ,p_upd_flag   Boolean
                     ,p_ins_flag   Boolean
                     ) return varchar2 is
  l_def	  varchar2(10);
  l_upd	  varchar2(10);
  l_ins	  varchar2(10);
Begin
  If (p_def_flag) then
     l_def := 'Defaulted ';
  End if;
  If (p_upd_flag) then
     l_upd := 'Updated ';
  End if;
  If (p_ins_flag) then
     l_ins := 'Inserted ';
  End if;
  return '(' || l_def || l_upd || l_ins || ')';
End;
--
-- ============================================================================
--                            <<Write_Comp>>
-- ============================================================================
--
Procedure write_comp (p_business_group_id in  number
                     ,p_effective_date    in  date
                     )is
  l_proc        varchar2(80) := g_package||'.write_comp';
  l_output      varchar2(3000); -- UTF8 Change Bug 2254683 varchar2(1000)
  l_first       Boolean := TRUE;
Begin
  hr_utility.set_location ('Entering '||l_proc,5 );
  For i in 1..g_cache_comp_cnt loop
    If (g_cache_comp(i).def_flag
        or g_cache_comp(i).ins_flag
        or g_cache_comp(i).upd_flag
       ) then
      If (l_first) then
        write(p_text => 'Default Election Information');
        write(p_text => '****************************');
        l_first := FALSE;
      End if;
      l_output := '>>  ' ||
        get_pgm_name
          (p_pgm_id => g_cache_comp(i).pgm_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  || ', ' ||
        get_pl_typ_name
          (p_pl_typ_id => g_cache_comp(i).pl_typ_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  ||	', ' ||
        get_pl_name
          (p_pl_id => g_cache_comp(i).pl_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  ||	', ' ||
        get_opt_name
          (p_oipl_id => g_cache_comp(i).oipl_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  ||
        ', Start:' || to_char(g_cache_comp(i).cvg_strt_dt, 'DD/MM/YYYY') ||
        ', End:'||to_char(g_cache_comp(i).cvg_thru_dt,'DD/MM/YYYY') ||
        get_actn_cd(p_def_flag => g_cache_comp(i).def_flag
                   ,p_upd_flag => g_cache_comp(i).upd_flag
                   ,p_ins_flag => g_cache_comp(i).ins_flag
                   )
        ;
      write(p_text => l_output);
    End if;
  End loop;
  l_first := TRUE;
  For i in 1..g_cache_comp_cnt loop
    If (g_cache_comp(i).del_flag) then
      If (l_first) then
        write(p_text => 'De-enrolled Election Information');
        write(p_text => '********************************');
      	l_first := FALSE;
      End if;
      l_output := '>>  ' ||
        get_pgm_name
          (p_pgm_id => g_cache_comp(i).pgm_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  || ', ' ||
        get_pl_typ_name
          (p_pl_typ_id => g_cache_comp(i).pl_typ_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  ||	', ' ||
        get_pl_name
          (p_pl_id => g_cache_comp(i).pl_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  ||	', ' ||
        get_opt_name
          (p_oipl_id => g_cache_comp(i).oipl_id
          ,p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date )  ||
        ', Start:' || to_char(g_cache_comp(i).cvg_strt_dt, 'DD/MM/YYYY') ||
        ', End:'||to_char(g_cache_comp(i).cvg_thru_dt,'DD/MM/YYYY') ;
      write(p_text => l_output);
    End if;
  End loop;
  hr_utility.set_location ('Leaving '||l_proc,10);
End write_comp;
--
-- ============================================================================
--                            <<Ini_Comp_obj_name>>
-- ============================================================================
--
Procedure ini_comp_obj_name is
  L_proc        varchar2(80) := g_package||'.ini_comp_obj_name';
Begin
    g_pgm_tbl.delete;
    g_pl_tbl.delete;
    g_pl_typ_tbl.delete;
    g_opt_tbl.delete;
End ini_comp_obj_name;
--
-- ============================================================================
--                            <<Ini_proc_info>>
-- ============================================================================
--
Procedure ini_proc_info is
  L_proc        varchar2(80) := g_package||'.ini_proc_info';
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  g_proc_info := NULL;
  g_proc_info.start_date := sysdate;
  g_proc_info.start_time_numeric := dbms_utility.get_time;
  g_proc_info.num_persons_selected       := 0;
  g_proc_info.num_persons_errored        := 0;
  g_proc_info.num_persons_unprocessed    := 0;
  g_proc_info.num_persons_processed_succ := 0;
  g_proc_info.num_persons_processed      := 0;
  g_num_processes  := 0;
  g_processes_tbl.delete;
  hr_utility.set_location ('Leaving '||l_proc,10);
End ini_proc_info;

--
-- ============================================================================
--                            <<Ini>>
-- ============================================================================
--
Procedure ini(p_actn_cd varchar2 default hr_api.g_varchar2) is
  L_proc        varchar2(80) := g_package||'.ini';
Begin
  hr_utility.set_location ('Entering '||l_proc,05);
  If(p_actn_cd = hr_api.g_varchar2) then
    ini_comp_obj;
    ini_person;
    ini_comp_obj_name;
  Elsif(upper(substr(p_actn_cd,1,6)) = 'PERSON' ) then
    ini_person;
  Elsif(upper(substr(p_actn_cd,1,8)) = 'COMP_OBJ' ) then
    ini_comp_obj;
  Elsif(upper(substr(p_actn_cd,1,9)) = 'COMP_NAME') then
    ini_comp_obj_name;
  Elsif(upper(substr(p_actn_cd,1,9)) = 'PROC_INFO') then
    ini_proc_info;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
End ini;
--
-- ============================================================================
--                            << Rpt_error >>
-- ============================================================================
--
procedure rpt_error (p_proc       in varchar2
                    ,p_last_actn  in varchar2
                    ,p_rpt_flag   in boolean default FALSE
                    ) is
  L_proc        varchar2(80) := g_package||'.rpt_error';
Begin
  If (p_rpt_flag ) then
    write(p_text => '<<<Fail in '||p_proc||' while '|| p_last_actn||'>>>');
  End if;
  hr_utility.set_location('>  Fail in '  || p_proc, 999 );
  hr_utility.set_location('>>    While ' || p_last_actn, 999);
End rpt_error;
--
-- ============================================================================
--                    << Function: get_pgm_name >>
-- ============================================================================
--
Function get_pgm_name(p_pgm_id             in number
                     ,p_business_group_id  in number
                     ,p_effective_date     in date
                     ,p_batch_flag         in boolean default FALSE
                     ) return varchar2 is
  cursor c1 is
    Select pgm_id, name
      From ben_pgm_f
     Where pgm_id = p_pgm_id
       And business_group_id = p_business_group_id
       And p_effective_date between
             effective_start_date and effective_end_date
           ;
  ret_str     varchar2(500); --UTF8 Change Bug 2254683 varchar2(80)
  l_proc      varchar2(80) := g_package || '.get_pgm_name';
  l_actn      varchar2(80);
  l_idx       binary_integer;
  l_fetch     Boolean := FALSE;
begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  l_actn := 'Retrieve program from cache or database...';
  --
  If (p_pgm_id is NULL) then
      ret_str := 'NO PROGRAM';
  Elsif (p_pgm_id > g_mx_binary_integer) then
    l_idx := -1 * mod(p_pgm_id, g_mx_binary_integer);
  Else
    l_idx := p_pgm_id;
  End if;
  If (g_pgm_tbl.exists(l_idx)) then
    ret_str := g_pgm_tbl(l_idx).name;
    If (g_pgm_tbl(l_idx).pgm_id <> p_pgm_id) then
      l_fetch := TRUE;
    End if;
  Else
    l_fetch := TRUE;
  End if;
  If (l_fetch) then
    --
    l_actn := 'Getting program from database...';
    --
    open c1;
    fetch c1 into g_pgm_tbl(l_idx);
    If c1%notfound then
      ret_str := 'PGM NOT FOUND';
    Else
      ret_str := g_pgm_tbl(l_idx).name;
    End if;
    close c1;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,70);
  return ret_str;
Exception
  when others then
      rpt_error(p_proc      => l_proc
               ,p_last_actn => l_actn
               ,p_rpt_flag  => p_batch_flag
               );
      fnd_message.raise_error;
End get_pgm_name;
--
-- ============================================================================
--                   << Function: get_pl_type_name >>
-- ============================================================================
--
Function get_pl_typ_name(p_pl_typ_id          in number
                        ,p_business_group_id  in number
                        ,p_effective_date     in Date
                        ,p_batch_flag         in boolean default FALSE
                        ) return varchar2 is
  Cursor c1 is
    Select pl_typ_id, name
      From ben_pl_typ_f
     Where pl_typ_id = p_pl_typ_id
       And business_group_id = p_business_group_id
       And p_effective_date between
             effective_start_date and effective_end_date
          ;
  ret_str    varchar2(500); --UTF8 Change Bug 2254683 varchar2(80)
  l_proc     varchar2(80) := g_package || '.get_pl_typ_name';
  l_actn     varchar2(80);
  l_idx      Binary_integer;
  l_fetch    Boolean := FALSE;
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  l_actn := 'Initializing...';
  If (p_pl_typ_id is NULL) then
    ret_str := 'NO PLAN TYPE';
  Elsif (p_pl_typ_id > g_mx_binary_integer) then
    l_idx := -1 * mod(p_pl_typ_id, g_mx_binary_integer);
  Else
    l_idx := p_pl_typ_id;
  End if;
  --
  l_actn := 'Getting plan type name from cache or database...';
  If g_pl_typ_tbl.exists(l_idx) then
  	ret_str := g_pl_typ_tbl(l_idx).name;
    If (p_pl_typ_id <> g_pl_typ_tbl(l_idx).pl_typ_id) then
      l_fetch := TRUE;
    End if;
  Else
      l_fetch := TRUE;
  End if;
  If (l_fetch) then
    open c1;
    fetch c1 into g_pl_typ_tbl(l_idx);
    If c1%notfound then
      ret_str := 'PLAN TYPE NOT FOUND';
    Else
      ret_str := g_pl_typ_tbl(l_idx).name;
    End if;
    close c1;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,70);
  return ret_str;
Exception
  When others then
    rpt_error(p_proc      => l_proc
             ,p_last_actn => l_actn
             ,p_rpt_flag  => p_batch_flag
             );
    fnd_message.raise_error;
End get_pl_typ_name;
--
-- ============================================================================
--                   << Function: get_pl_name >>
-- ============================================================================
--
Function get_pl_name(p_pl_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ,p_batch_flag         in boolean default FALSE
                    ) return varchar2 is
  Cursor c1 is
    Select pl_id, name
      From ben_pl_f
     Where pl_id = p_pl_id
        And business_group_id = p_business_group_id
        And p_effective_date between
              effective_start_date and effective_end_date
           ;
  ret_str    varchar2(500); --UTF8 Chnage Bug 2254683 varchar2(80)
  l_proc     varchar2(80) := g_package || '.get_pl_name';
  l_actn     varchar2(80);
  l_idx      binary_integer;
  l_fetch    Boolean := FALSE;
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  l_actn := 'Initializing...';
  --
  If (p_pl_id is NULL) then
    ret_str := 'NO PLAN';
  Elsif (p_pl_id > g_mx_binary_integer) then
    l_idx := -1 * mod(p_pl_id, g_mx_binary_integer);
  Else
    l_idx := p_pl_id;
  End if;
  --
  l_actn := 'Getting plan name from cache or database...';
  --
  If g_pl_tbl.exists(l_idx) then
    ret_str := g_pl_tbl(l_idx).name;
    If (p_pl_id <> g_pl_tbl(l_idx).pl_id) then
      l_fetch := TRUE;
    End if;
  Else
      l_fetch := TRUE;
  End if;
  If (l_fetch) then
    open c1;
    fetch c1 into g_pl_tbl(l_idx);
    If c1%notfound then
      ret_str := 'PLAN NOT FOUND';
    Else
      ret_str := g_pl_tbl(l_idx).name;
    End if;
    close c1;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,70);
  return ret_str;
Exception
    when others then
    rpt_error(p_proc      => l_proc
             ,p_last_actn => l_actn
             ,p_rpt_flag  => p_batch_flag
             );
    fnd_message.raise_error;
End get_pl_name;
--
-- ============================================================================
--                   << Procedure: get_opt_name >>
-- ============================================================================
--
Function get_opt_name(p_oipl_id            in number
                     ,p_business_group_id  in number
                     ,p_effective_date     in date
                     ,p_batch_flag         in boolean default FALSE
                     ) return varchar2 is
  cursor c1 is
    Select oipl.oipl_id, opt.opt_id, opt.name
      From ben_oipl_f oipl
          ,ben_opt_f opt
     Where oipl.oipl_id = p_oipl_id
       And oipl.opt_id = opt.opt_id
       And oipl.business_group_id = p_business_group_id
       And opt.business_group_id = p_business_group_id
       And p_effective_date between
             opt.effective_start_date and opt.effective_end_date
       And p_effective_date between
             oipl.effective_start_date and oipl.effective_end_date
          ;
  ret_str    varchar2(500); --UTF8 Change Bug 2254683 varchar2(80)
  l_proc     varchar2(80):= g_package || '.get_opt_name';
  l_actn     varchar2(80);
  l_idx      binary_integer;
  l_fetch    Boolean := FALSE;
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  l_actn := 'Initializing...';
  --
  If (p_oipl_id is NULL) then
    ret_str := 'NO OPTION';
  Elsif (p_oipl_id  > g_mx_binary_integer) then
    l_idx := -1 * mod(p_oipl_id, g_mx_binary_integer);
  Else
    l_idx := p_oipl_id;
  End if;
  --
  l_actn := 'Getting option name from cache or database...';
  --
  If g_opt_tbl.exists(l_idx) then
    ret_str := g_opt_tbl(l_idx).name;
    If (g_opt_tbl(l_idx).oipl_id <> p_oipl_id) then
      l_fetch := TRUE;
    End if;
  Else
      l_fetch := TRUE;
  End if;
  If (l_fetch) then
    open c1;
    fetch c1 into g_opt_tbl(l_idx);
    If c1%notfound then
      ret_str := 'OPTION NOT FOUND';
    Else
      ret_str := g_opt_tbl(l_idx).name;
    End if;
    close c1;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,70);
  return ret_str;
Exception
  when others then
    rpt_error(p_proc      => l_proc
             ,p_last_actn => l_actn
             ,p_rpt_flag  => p_batch_flag
             );
    fnd_message.raise_error;
End get_opt_name;
--
-- ============================================================================
--                            <<Write_logfile>>
-- ============================================================================
--
Procedure write_logfile (p_num_pers_processed in number
                        ,p_num_pers_errored   in number
                        ,p_non_person_cd      in varchar2 default null
                        ) is
  l_proc        varchar2(80) := g_package||'.write_logfile';
begin
  hr_utility.set_location ('Entering '||l_proc,10);
  write(p_text => benutils.g_banner_minus);
  write(p_text => 'Benefits Statistical Information');
  write(p_text => benutils.g_banner_minus);

  if p_non_person_cd is null then
     write(p_text => 'Success persons      ' || to_char(p_num_pers_processed));
     write(p_text => 'Errored persons       '|| to_char(p_num_pers_errored));
     write(p_text => 'Total persons Procd   '||
                  to_char(p_num_pers_processed+p_num_pers_errored));
  else   --  if p_non_person_cd = 'PREM'
     write(p_text => 'Success premiums      ' || to_char(p_num_pers_processed));
     write(p_text => 'Errored premiums       '|| to_char(p_num_pers_errored));
     write(p_text => 'Total premiums Procd   '||
                  to_char(p_num_pers_processed+p_num_pers_errored));
  end if;
  write(p_text => benutils.g_banner_minus);

  hr_utility.set_location ('Leaving '||l_proc,99);
Exception
  when others then
      fnd_message.set_name('BEN','BEN_91663_BENMNGLE_LOGGING');
      fnd_message.set_token('PROC',l_proc);
      write(fnd_message.get);
      fnd_message.raise_error;
end write_logfile;
--
-- ===========================================================================
--                   << Procedure: Write_rec >>
-- ===========================================================================
--
Procedure Write_rec(p_typ_cd in varchar2
                   ,p_text   in varchar2 default NULL
                   ,p_err_cd in varchar2 default NULL
                   ) is
  l_proc        varchar2(80) := g_package||'.write_rec';
  l_rec         ben_type.g_report_rec := g_rec;
Begin
  hr_utility.set_location ('Entering ' || l_proc,05);
  l_rec.rep_typ_cd := p_typ_cd;
  l_rec.text := p_text;
  l_rec.ERROR_MESSAGE_CODE := p_err_cd;
  benutils.write(p_rec => l_rec);
  hr_utility.set_location ('Leaving '  || l_proc,10);
End write_rec;
--
-- ============================================================================
--                            <<End_process>>
-- ============================================================================
--
Procedure End_process(p_benefit_action_id   in number
                     ,p_person_selected     in number
                     ,p_business_group_id   in number   default NULL
                     ,p_non_person_cd       in varchar2 default null
                     ) is
  cursor c_actions is
    Select count(*) amount,action_status_cd
      from ben_person_actions act
     where act.benefit_action_id = p_benefit_action_id
       and act.action_status_cd in ('P','E','U')
       and nvl(act.non_person_cd,'x') = nvl(p_non_person_cd,'x')
     group by action_status_cd
           ;
  l_actions               c_actions%rowtype;
  l_proc                  varchar2(80) := g_package||'.End_process';
  l_batch_proc_id         number;
  l_object_version_number number;
Begin
  hr_utility.set_location ('Entering ' || l_proc,05);
  --
  -- Get totals for unprocessed, processed successfully and errored
  --
  open c_actions;
  Loop
      hr_utility.set_location (l_proc,6);
      fetch c_actions into l_actions;
      exit when c_actions%notfound;
      If l_actions.action_status_cd = 'P' then
          g_proc_info.num_persons_processed_succ := l_actions.amount;
      Elsif l_actions.action_status_cd = 'E' then
          g_proc_info.num_persons_errored := l_actions.amount;
      Elsif l_actions.action_status_cd in ('U', 'T') then
          g_proc_info.num_persons_unprocessed := l_actions.amount;
      End if;
      hr_utility.set_location (l_proc,7);
  End loop;
  hr_utility.set_location (l_proc,8);
  close c_actions;
  g_proc_info.num_persons_selected := p_person_selected;
  hr_utility.set_location (l_proc,9);
  --
  -- Set value of number of persons processed
  --
  g_proc_info.num_persons_processed
                  := g_proc_info.num_persons_errored +
                     g_proc_info.num_persons_processed_succ;
  hr_utility.set_location (l_proc,10);
  hr_utility.set_location (l_proc||' start_date='||g_proc_info.start_date||'.',10);
  ben_batch_proc_info_api.create_batch_proc_info
    (P_VALIDATE             => FALSE
    ,P_BATCH_PROC_ID        => l_batch_proc_id
    ,P_BENEFIT_ACTION_ID    => p_benefit_action_id
    ,P_STRT_DT              => trunc(g_proc_info.start_date)
    ,P_END_DT               => trunc(sysdate)
    ,P_STRT_TM              => to_char(g_proc_info.start_date,'HH24:MI:SS')
    ,P_END_TM               => to_char(sysdate,'HH24:MI:SS')
    ,P_ELPSD_TM             => to_char((dbms_utility.get_time -
                               g_proc_info.start_time_numeric)/100)||' seconds'
    ,P_PER_SLCTD            => g_proc_info.num_persons_selected
    ,P_PER_PROC             => g_proc_info.num_persons_processed
    ,P_PER_UNPROC           => g_proc_info.num_persons_unprocessed
    ,P_PER_PROC_SUCC        => g_proc_info.num_persons_processed_succ
    ,P_PER_ERR              => g_proc_info.num_persons_errored
    ,P_BUSINESS_GROUP_ID    => p_business_group_id
    ,P_OBJECT_VERSION_NUMBER=> l_object_version_number
    );
  hr_utility.set_location (l_proc,11);
  benutils.write_table_and_file(p_table  =>  true,
                                p_file => true);
  hr_utility.set_location (l_proc,12);
  commit;
  hr_utility.set_location ('Leaving '  || l_proc,100);
End end_process;
--
-- ============================================================================
--                            <<Write>>
-- ============================================================================
--
Procedure write (p_text varchar2) is
  l_proc          varchar2(80) := g_package||'.Write';
Begin
--hr_utility.set_location ('Entering '||l_proc,05);
  If fnd_global.conc_request_id <> -1 then
      fnd_file.put_line(which=>fnd_file.log
                       ,buff => p_text);
  End if;
--hr_utility.set_location ('Leaving '||l_proc,99);
End write;
--
-- ============================================================================
--                       <<cache_person_information>>
-- ============================================================================
--
procedure cache_person_information
                (p_person_id            in number
                ,p_business_group_id    in number
                ,p_effective_date       in date
                ,p_cache_time_perd_flag in boolean default TRUE
                ,p_cache_pay_perd_flag  in boolean default TRUE
                ,p_cache_total_fte_flag in boolean default TRUE
                ) is
  --
  cursor c_person is
    select ppf.full_name
          ,ppf.date_of_birth
          ,ppf.date_of_death
          ,ppf.benefit_group_id
          ,bng.name
          ,pps.date_start
          ,pps.adjusted_svc_date
          ,pad.postal_code
          ,ppf.national_identifier
          ,hao.name
      From per_all_people_f ppf
          ,per_periods_of_service pps
          ,per_addresses pad
          ,hr_all_organization_units_vl hao
          ,ben_benfts_grp bng
     Where ppf.person_id = p_person_id
       And ppf.business_group_id  = p_business_group_id
       And ppf.business_group_id = hao.organization_id
       And pps.person_id (+) = ppf.person_id
       And nvl(pps.business_group_id(+),ppf.business_group_id)
           = ppf.business_group_id
       And pad.person_id (+) = ppf.person_id
       And nvl(pad.business_group_id(+),ppf.business_group_id)
           = ppf.business_group_id
       And nvl(pad.primary_flag,'Y') = 'Y'
       And p_effective_date between
               nvl(pad.date_from(+),p_effective_date)
               and nvl(pad.date_to(+),p_effective_date)
       And bng.benfts_grp_id (+) = ppf.benefit_group_id
       And nvl(bng.business_group_id(+),ppf.business_group_id)
           = ppf.business_group_id
       And p_effective_date between
           ppf.effective_start_date and ppf.effective_end_date
          ;
  --
  cursor c_assignment is
    select paf.assignment_id
          ,pbv.value
          ,pat.per_system_status
          ,paf.grade_id
          ,paf.job_id
          ,paf.pay_basis_id
          ,paf.payroll_id
          ,paf.location_id
          ,paf.organization_id
          ,paf.normal_hours
          ,paf.frequency
          ,paf.bargaining_unit_code
          ,paf.labour_union_member_flag
          ,paf.hourly_salaried_code
          ,paf.assignment_status_type_id
          ,paf.change_reason
          ,paf.employment_category
          ,ori.org_information1
          ,oru.organization_id
          ,oru.name
          ,loc.location_code
          ,ppf.payroll_name
      From per_all_assignments_f paf
          ,per_assignment_status_types pat
          ,hr_organization_information ori
          ,hr_all_organization_units_vl oru
          ,hr_locations loc
          ,pay_payrolls_f ppf
          ,per_assignment_budget_values_f pbv
     Where paf.person_id = p_person_id
       and paf.assignment_type <> 'C'
       and paf.primary_flag = 'Y'
       and paf.business_group_id = p_business_group_id
       and paf.location_id = loc.location_id (+)
       and oru.organization_id (+) = paf.organization_id
       and ori.organization_id (+) = oru.organization_id
       and ori.org_information1(+) = 'HR_LEGAL'
       and ppf.payroll_id (+) = paf.payroll_id
       and p_effective_date between
               nvl(ppf.effective_start_date,p_effective_date)
               and nvl(ppf.effective_end_date,p_effective_date)
       and pat.assignment_status_type_id (+) = paf.assignment_status_type_id
       and pbv.assignment_id(+) = paf.assignment_id
       and pbv.unit(+) = 'FTE'
       and p_effective_date between
               nvl(pbv.effective_start_date,p_effective_date)
               and nvl(pbv.effective_end_date,p_effective_date)
       and p_effective_date between
               paf.effective_start_date and paf.effective_end_date
          ;
  --
  cursor c_time_periods is
    select tpe.start_date
          ,tpe.end_date
      From per_time_periods tpe
          ,per_all_assignments_f paf
     Where paf.person_id = p_person_id
       and paf.primary_flag = 'Y'
       and paf.assignment_type <> 'C'
       and paf.business_group_id = p_business_group_id
       and p_effective_date between
               paf.effective_start_date and paf.effective_end_date
       and tpe.payroll_id (+) = paf.payroll_id
       and p_effective_date between
               nvl(tpe.start_date,p_effective_date)
               and nvl(tpe.end_date,p_effective_date)
          ;
  --
  cursor c_person_type is
    select per.person_type_id
          ,ppt.user_person_type
          ,ppt.system_person_type
      From per_person_type_usages_f per
          ,per_person_types ppt
     Where per.person_id = p_person_id
       and p_effective_date between
               per.effective_start_date and per.effective_end_date
      and per.person_type_id = ppt.person_type_id
    order by decode(ppt.system_person_type,'EMP',1,2)
          ;
  --
  cursor c_next_pay_period is
    select tpe.start_date
          ,tpe.end_date
      from per_time_periods tpe
          ,per_all_assignments_f asg
     where tpe.payroll_id = asg.payroll_id
       and asg.person_id = p_person_id
      and  asg.assignment_type <> 'C'
       and asg.primary_flag = 'Y'
       and p_effective_date between
               asg.effective_start_date and asg.effective_end_date
       and tpe.start_date > p_effective_date
    order by tpe.start_date
          ;
  --
  cursor c_total_fte is
    select sum(pab.value)
      from per_all_people_f ppf
          ,per_all_assignments_f paf
          ,per_assignment_budget_values_f pab
     where ppf.person_id = p_person_id
      and  paf.assignment_type <> 'C'
       and ppf.business_group_id  = p_business_group_id
       and p_effective_date between
               ppf.effective_start_date and ppf.effective_end_date
       and ppf.person_id = paf.person_id
       and paf.business_group_id  = ppf.business_group_id
       and p_effective_date between
               paf.effective_start_date and paf.effective_end_date
       and pab.business_group_id  = paf.business_group_id
       and pab.assignment_id = paf.assignment_id
       and pab.unit = 'FTE'
       and p_effective_date between
               pab.effective_start_date and pab.effective_end_date
          ;
  l_proc          varchar2(80) := g_package||'.cache_person_information';
  l_count         number(9) := 0;
  l_person_type   c_person_type%rowtype;
begin
  hr_utility.set_location ('Entering '||l_proc,05);
  open c_person;
  fetch c_person into g_cache_person.full_name
                     ,g_cache_person.date_of_birth
                     ,g_cache_person.date_of_death
                     ,g_cache_person.benefit_group_id
                     ,g_cache_person.benefit_group
                     ,g_cache_person.date_start
                     ,g_cache_person.adjusted_svc_date
                     ,g_cache_person.postal_code
                     ,g_cache_person.national_identifier
                     ,g_cache_person.bg_name
                     ;
  If c_person%notfound then
      close c_person;
      fnd_message.set_name('BEN','BEN_91661_BENMNGLE_PERSON_FIND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',to_char(p_person_id));
      fnd_message.raise_error;
  End if;
  close c_person;
  --
  -- Open cursor to see if the person holds emp person type status and store all
  -- of the person type belong to the person.
  --
  g_cache_person.person_has_type_emp := 'N';
  g_cache_person_types.delete;
  open c_person_type;
  Loop
    fetch c_person_type into l_person_type;
    exit when c_person_type%notfound;
    l_count := l_count + 1;
    If l_person_type.system_person_type = 'EMP' then
        g_cache_person.person_has_type_emp := 'Y';
    End if;
    g_cache_person_types(l_count).user_person_type
                                 := l_person_type.user_person_type;
    g_cache_person_types(l_count).system_person_type
                                 := l_person_type.system_person_type;
    g_cache_person_types(l_count).person_type_id
                                 := l_person_type.person_type_id;
  End loop;
  close c_person_type;
  --
  -- Default First element in array to NULL
  --
  If not g_cache_person_types.exists(1) then
    g_cache_person_types(1).user_person_type   := null;
    g_cache_person_types(1).system_person_type := null;
    g_cache_person_types(1).person_type_id     := null;
  End if;
  --
  -- We need to do the assignment stuff seperately as we can't outer join
  -- as we need assignments with primary flags and applicants have non
  -- primary flag assignments so the hack is to do the select in two
  -- statements, although a fix could be to do a union to get the value
  -- for the assignment id.
  --
  open c_assignment;
  fetch c_assignment into g_cache_person.assignment_id
                         ,g_cache_person.fte_value
                         ,g_cache_person.per_system_status
                         ,g_cache_person.grade_id
                         ,g_cache_person.job_id
                         ,g_cache_person.pay_basis_id
                         ,g_cache_person.payroll_id
                         ,g_cache_person.location_id
                         ,g_cache_person.organization_id
                         ,g_cache_person.normal_hours
                         ,g_cache_person.frequency
                         ,g_cache_person.bargaining_unit_code
                         ,g_cache_person.labour_union_member_flag
                         ,g_cache_person.hourly_salaried_code
                         ,g_cache_person.assignment_status_type_id
                         ,g_cache_person.change_reason
                         ,g_cache_person.employment_category
                         ,g_cache_person.org_information1
                         ,g_cache_person.org_id
                         ,g_cache_person.org_name
                         ,g_cache_person.address_line_1
                         ,g_cache_person.payroll_name
                         ;
  If c_assignment%notfound then
      g_cache_person.assignment_id := null;
      g_cache_person.fte_value := null;
      g_cache_person.per_system_status := null;
      g_cache_person.grade_id := null;
      g_cache_person.job_id := null;
      g_cache_person.pay_basis_id := null;
      g_cache_person.payroll_id := null;
      g_cache_person.location_id := null;
      g_cache_person.organization_id := null;
      g_cache_person.normal_hours := null;
      g_cache_person.frequency := null;
      g_cache_person.bargaining_unit_code := null;
      g_cache_person.labour_union_member_flag := null;
      g_cache_person.assignment_status_type_id := null;
      g_cache_person.change_reason := null;
      g_cache_person.employment_category := null;
      g_cache_person.org_information1 := null;
      g_cache_person.org_id := null;
      g_cache_person.org_name := null;
      g_cache_person.address_line_1 := null;
      g_cache_person.payroll_name := null;
  End if;
  close c_assignment;
  --
  -- Time period is optional.  Defaulted to TRUE
  --
  If ( p_cache_time_perd_flag) then
      open c_time_periods;
      fetch c_time_periods into g_cache_person.pay_period_start_date
                               ,g_cache_person.pay_period_end_date
                               ;
      If c_time_periods%notfound then
          g_cache_person.pay_period_start_date := null;
          g_cache_person.pay_period_end_date := null;
      End if;
      close c_time_periods;
  End if;
  --
  -- pay period cache is optional, defaulted to TRUE
  --
  If (p_cache_pay_perd_flag) then
      open c_next_pay_period;
      fetch c_next_pay_period into g_cache_person.pay_period_next_start_date
                                  ,g_cache_person.pay_period_next_end_date
                                  ;
      If c_next_pay_period%notfound then
          g_cache_person.pay_period_next_start_date := null;
          g_cache_person.pay_period_next_end_date := null;
      End if;
      close c_next_pay_period;
  End if;
  --
  -- cache budget value is optionsl, defaulted to TRUE
  --
  If (p_cache_total_fte_flag) then
      open c_total_fte;
      fetch c_total_fte into g_cache_person.total_fte_value;
      If c_total_fte%notfound then
          g_cache_person.total_fte_value := null;
      End if;
      close c_total_fte;
  End if;
  --
  -- Set the lf_evt_ocrd_dt to the effective date. If we are running in life
  -- event mode then this will be set later to the real life event date.
  --
  g_cache_person.lf_evt_ocrd_dt := p_effective_date;
  --
  -- Put person_id into g_rec cache
  --
  g_rec.person_id := p_person_id;
  g_rec.national_identifier := g_cache_person.national_identifier;
  hr_utility.set_location ('Leaving '||l_proc,10);
end cache_person_information;
--
-- ============================================================================
--                             <<Person_header>>
-- ============================================================================
--
Procedure person_header
    (p_person_id           in number default null
    ,p_business_group_id   in number
    ,p_effective_date      in date
    ) is
  --
  l_proc              varchar2(80) := g_package||'.person_header';
  l_output_string     varchar2(2000); -- UTF8 Change Bug 2254683 varchar2(100)
  --
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Cache person data
  --
  cache_person_information
    (p_person_id         => p_person_id
    ,p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    );
  --
  -- This should display something like this
  --
  -- *********************************************************************
  -- Name : John Smith (100) Type : Employee (1)  Grp : Benefits Group (1)
  -- BG   : Freds BG   (100) Org  : Freds Org(1)  GRE : Retiree
  -- Loc  : HQ         (100) Pst  : 86727         Pyr : Payroll 3B     (1)
  --
  write(p_text => benutils.g_banner_asterix);
  l_output_string := 'Name: '||
                     rpad(substr(g_cache_person.full_name,1,15),15,' ')||
                     rpad(benutils.id(p_person_id),8,' ')||
                     'Typ: '||
                     rpad(substr(g_cache_person_types(1).user_person_type,1,15)
                         ,15,' ') ||
                     rpad('',8,' ')|| ' Grp: '||
                     rpad(substr(g_cache_person.benefit_group,1,15),15,' ')||
                     rpad(benutils.id(g_cache_person.benefit_group_id),8,' ');
  write(p_text => l_output_string);
  --
  -- loop through the rest of the person_types
  --
  For l_count in 2..g_cache_person_types.last loop
      l_output_string := rpad(' ',25,' ');
      l_output_string := l_output_string ||
      rpad(substr(g_cache_person_types(l_count).user_person_type,1,20),20,' ');
      write(l_output_string);
  End loop;
  l_output_string := 'BG:   '||
                     rpad(substr(g_cache_person.bg_name,1,15),15,' ')||
                     rpad(benutils.id(p_business_group_id),8,' ')||
                     ' Org: '||
                     rpad(substr(g_cache_person.org_name,1,15),15,' ')||
                     rpad(benutils.id(g_cache_person.org_id),8,' ');
  --
  -- Need to add GRE
  --
  write(p_text => l_output_string);
  l_output_string := 'Loc:  '||
                     rpad(substr(g_cache_person.address_line_1,1,15),15,' ')||
                     rpad(benutils.id(g_cache_person.location_id),8,' ')||
                     ' Pst: '||
                     rpad(substr(g_cache_person.postal_code,1,15),15,' ')||
                     rpad('',8,' ')||
                     ' Pyr: '||
                     rpad(substr(g_cache_person.payroll_name,1,15),15,' ')||
                     rpad(benutils.id(g_cache_person.payroll_id),8,' ');
  write(p_text => l_output_string);
  hr_utility.set_location ('Leaving '||l_proc,10);
end person_header;
--
-- ============================================================================
--                             <<Print_parameters>>
-- ============================================================================
--
procedure print_parameters
            (p_thread_id                in number
            ,p_validate                 in varchar2
            ,p_benefit_action_id        in number
            ,p_effective_date           in date
            ,p_business_group_id        in number
            ,p_pgm_id                   in number	 default hr_api.g_number
            ,p_pl_id                    in number	 default hr_api.g_number
            ,p_popl_enrt_typ_cycl_id    in number	 default hr_api.g_number
            ,p_person_id                in number    default hr_api.g_number
            ,p_person_type_id           in number    default hr_api.g_number
            ,p_ler_id                   in number    default hr_api.g_number
            ,p_organization_id          in number  	 default hr_api.g_number
            ,p_benfts_grp_id            in number    default hr_api.g_number
            ,p_location_id              in number    default hr_api.g_number
            ,p_legal_entity_id          in number    default hr_api.g_number
            ,p_payroll_id               in number    default hr_api.g_number
            ,p_no_programs              in varchar2	 default hr_api.g_varchar2
            ,p_no_plans                 in varchar2	 default hr_api.g_varchar2
            ,p_rptg_grp_id              in number	 default hr_api.g_number
            ,p_pl_typ_id                in number	 default hr_api.g_number
            ,p_opt_id                   in number	 default hr_api.g_number
            ,p_eligy_prfl_id            in number	 default hr_api.g_number
            ,p_vrbl_rt_prfl_id          in number	 default hr_api.g_number
            ,p_mode                     in varchar2	 default hr_api.g_varchar2
            ,p_person_selection_rule_id in number	 default hr_api.g_number
            ,p_comp_selection_rule_id   in number	 default hr_api.g_number
            ,p_enrt_perd_id             in number        default hr_api.g_number
            ,p_derivable_factors        in varchar2	 default hr_api.g_varchar2
            ,p_audit_log                in varchar2	 default hr_api.g_varchar2
            ) is
  l_proc        varchar2(80) := g_package||'.print_parameters';
  l_string      varchar2(80);
  l_actn        varchar2(80);
begin
  hr_utility.set_location ('Entering '||l_proc,10);
  write(p_text => 'Runtime Parameters');
  write(p_text => '------------------');
  -- bug 5450842
  if p_mode is not null AND p_mode <> hr_api.g_varchar2
  then
         write(p_text => 'Run Mode                   :' ||
                  nvl(hr_general.decode_lookup('BEN_BENMNGLE_MD',p_mode),
                      hr_general.decode_lookup('BEN_BENCLENR_MD',p_mode))); -- 1674123
  end if;
  -- end 5450842
  write(p_text => 'Validation Mode            :' ||
                  hr_general.decode_lookup('YES_NO',p_validate));
  write(p_text => 'Benefit Action ID          :' ||
                  to_char(p_benefit_action_id));
  write(p_text => 'Effective Date             :' ||
                  to_char(p_effective_date,'DD/MM/YYYY'));
  write(p_text =>'Business Group ID          :' || p_business_group_id);
  if (nvl(p_enrt_perd_id, -1) <> hr_api.g_number) then
    write(p_text =>'Enrollment period Id       :' || p_enrt_perd_id);
  end if;
  --
  l_actn := 'printing p_derivable_factors';
  If (nvl(p_derivable_factors,'xxxx') <> hr_api.g_varchar2) then
      write(p_text =>'Derivable Factors          :'||
                     hr_general.decode_lookup('YES_NO',p_derivable_factors));
  End if;
  --
  l_actn := 'Printing p_pgm_id';
  If (nvl(p_pgm_id,-1) <> hr_api.g_number) then
      write(p_text => 'Program ID                 :'||
                      benutils.iftrue
                           (p_expression => p_pgm_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_pgm_id));
  End if;
  --
  l_actn := 'printing p_pl_id...';
  If (nvl(p_pl_id,-1) <> hr_api.g_number) then
      write(p_text => 'Plan ID                    :'||
                      benutils.iftrue
                           (p_expression => p_pl_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_pl_id));
  End if;
  --
  l_actn := 'Printing p_pl_typ_id...';
  If (nvl(p_pl_typ_id,-1) <> hr_api.g_number) then
      write(p_text => 'Plan Type ID               :'||
                      benutils.iftrue
                           (p_expression => p_pl_typ_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_pl_typ_id));
  End if;
  --
  l_actn := 'Printting p_opt_id... ';
  If (nvl(p_opt_id,-1) <> hr_api.g_number) then
      write(p_text => 'Option ID                  :'||
                      benutils.iftrue
                           (p_expression => p_opt_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_opt_id));
  End if;
  --
  l_actn := 'Printting p_popl_enrt_typ_cycl...';
  If (nvl(p_popl_enrt_typ_cycl_id,-1) <> hr_api.g_number) then
      write(p_text => 'Enrollment Type Cycle      :'||
                      benutils.iftrue
                           (p_expression => p_popl_enrt_typ_cycl_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_popl_enrt_typ_cycl_id));
  End if;
  --
  l_actn := 'Printting p_no_program...';
  If (nvl(p_no_programs,'xxxx') <> hr_api.g_varchar2) then
      write(p_text => 'Just Plans not in Programs :'||
                      hr_general.decode_lookup('YES_NO',p_no_programs));
  End if;
  --
  l_actn := 'Printting p_no_plans...';
  If (nvl(p_no_plans,'xxxx') <> hr_api.g_varchar2) then
      write(p_text => 'Just Programs              :'||
                      hr_general.decode_lookup('YES_NO',p_no_plans));
  End if;
  --
  l_actn := 'Printting p_rptg_grp_id...';
  If (nvl(p_rptg_grp_id,-1) <> hr_api.g_number) then
      write(p_text => 'Reporting Group            :'||
                      benutils.iftrue
                           (p_expression => p_rptg_grp_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_rptg_grp_id));
  End if;
  --
  l_actn := 'Printting p_eligy_prfl_id...';
  If (nvl(p_eligy_prfl_id,-1) <> hr_api.g_number) then
      write(p_text => 'Eligiblity Profile         :'||
                      benutils.iftrue
                           (p_expression => p_eligy_prfl_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_eligy_prfl_id));
  End if;
  --
  l_actn := 'Printting p_vrbl_rt_prfl_id...';
  If (nvl(p_vrbl_rt_prfl_id,-1) <> hr_api.g_number) then
      write(p_text => 'Variable Rate Profile      :'||
                      benutils.iftrue
                           (p_expression => p_vrbl_rt_prfl_id is null
                           ,p_true       => 'All'
                           ,p_false      => p_vrbl_rt_prfl_id));
  End if;
  --
  l_actn := 'Printting p_person_selection_rule_id...';
  If (nvl(p_person_selection_rule_id,-1) <> hr_api.g_number) then
      write(p_text => 'Person Selection Rule      :'||
                      benutils.iftrue
                           (p_expression => p_person_selection_rule_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_person_selection_rule_id));
  End if;
  --
  l_actn := 'Printting p_person_id...';
  If (nvl(p_person_id,-1) <> hr_api.g_number) then
      write(p_text => 'Person ID                  :'||
                      benutils.iftrue
                           (p_expression => p_person_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_person_id));
  End if;
  --
  l_actn := 'Printting p_person_type_id...';
  If (nvl(p_person_type_id,-1) <> hr_api.g_number) then
      write(p_text => 'Person Type ID             :'||
                      benutils.iftrue
                           (p_expression => p_person_type_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_person_type_id));
  End if;
  --
  l_actn := 'Printting p_ler_id...';
  If (nvl(p_ler_id,-1) <> hr_api.g_number) then
      write(p_text => 'Ler ID                     :'||
                      benutils.iftrue
                           (p_expression => p_ler_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_ler_id));
  End if;
  --
  l_actn := 'Printting p_organization_id...';
  If (nvl(p_organization_id,-1) <> hr_api.g_number) then
      write(p_text => 'Organization ID            :'||
                      benutils.iftrue
                           (p_expression => p_organization_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_organization_id));
  End if;
  --
  l_actn := 'Printting p_benfts_grp_id...';
  If (nvl(p_benfts_grp_id,-1) <> hr_api.g_number) then
      write(p_text => 'Benefits Group ID          :'||
                      benutils.iftrue
                           (p_expression => p_benfts_grp_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_benfts_grp_id));
  End if;
  --
  l_actn := 'Printting p_location_id...';
  If (nvl(p_location_id,-1) <> hr_api.g_number) then
      write(p_text => 'Location ID                :'||
                      benutils.iftrue
                           (p_expression => p_location_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_location_id));
  End if;
  --
  l_actn := 'Printting p_legal_entity_id...';
  If (nvl(p_legal_entity_id,-1) <> hr_api.g_number) then
      write(p_text => 'Legal Entity ID            :'||
                      benutils.iftrue
                           (p_expression => p_legal_entity_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_legal_entity_id));
  End if;
  --
  l_actn := 'Printting p_payroll_id...';
  If (nvl(p_payroll_id,-1) <> hr_api.g_number) then
      write(p_text => 'Payroll ID                 :'||
                      benutils.iftrue
                           (p_expression => p_payroll_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_payroll_id));
  End if;
  --
  l_actn := 'Printting p_comp_selection_rule_id...';
  If (nvl(p_comp_selection_rule_id,-1) <> hr_api.g_number) then
      write(p_text => 'Comp Object Selection Rule :'||
                      benutils.iftrue
                           (p_expression => p_comp_selection_rule_id is null
                           ,p_true       => 'None'
                           ,p_false      => p_comp_selection_rule_id));
  End if;
  --
  l_actn := 'Printting p_audit_log...';
  If (nvl(p_audit_log,'xxxx') <> hr_api.g_varchar2) then
      write(p_text => 'Audit log flag             :'||
                      hr_general.decode_lookup('YES_NO',p_audit_log));
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
exception
  when others then
    ben_batch_utils.rpt_error(p_proc      => l_proc
                             ,p_last_actn => l_actn );
    raise;
end print_parameters;
--
-- ============================================================================
--                     << Person_selection_Rule >>
-- ============================================================================
--
Function person_selection_rule
                 (p_person_id                in  Number
                 ,p_business_group_id        in  Number
                 ,p_person_selection_rule_id in  Number
                 ,p_effective_date           in  Date
                 ,p_batch_flag               in  Boolean default FALSE
                 ,p_input1                   in  varchar2 default null    -- Bug 5331889
                 ,p_input1_value             in  varchar2 default null
                 ) return char is
  Cursor c1 is
      Select assignment_id
        From per_assignments_f paf
       Where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         And paf.primary_flag = 'Y'
         And paf.business_group_id = p_business_group_id
         And p_effective_date between
                 paf.effective_start_date and paf.effective_end_date;
  --
  Cursor c2 is
      Select assignment_id
        From per_all_assignments_f paf
       Where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         And paf.primary_flag = 'Y'
         And paf.business_group_id = p_business_group_id
         And p_effective_date between
                 paf.effective_start_date and paf.effective_end_date;
  --
  l_proc   	   varchar2(80) := g_package||'.person_selection_rule';
  l_outputs   	   ff_exec.outputs_t;
  l_return  	   varchar2(30);
  l_assignment_id  number;
  l_actn           varchar2(80);
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Get assignment ID form per_assignments_f table.
  --
  l_actn := 'Opening Assignment cursor...';
  -- Perf changes
  if  hr_security.view_all =  'Y' and hr_general.get_xbg_profile = 'Y'
  then
     open c2;
     fetch c2 into l_assignment_id;
     If c2%notfound and g_audit_flag = true
     then
        --Log the person in log file and proceed with processing of other person records
        write(p_text => 'Warning : No Primary assignment found for this Person ID : '|| p_person_id); --5643310
      End if;
      close c2;
  else
     open c1;
     fetch c1 into l_assignment_id;
     If c1%notfound and g_audit_flag = true
     then
        --Log the person in log file and proceed with processing of other person records
        write(p_text => 'Warning : No Primary assignment found for this Person ID : '|| p_person_id); --5643310
      End if;
      close c1;
  end if;
  --
  -- Call formula initialise routine
  --
  l_actn := 'Calling benutils.formula procedure...';
  l_outputs := benutils.formula
                      (p_formula_id     => p_person_selection_rule_id
                      ,p_effective_date => p_effective_date
                      ,p_business_group_id => p_business_group_id
                      ,p_assignment_id  => l_assignment_id
                      ,p_param1         => 'BEN_IV_PERSON_ID'          -- Bug 5331889
                      ,p_param1_value   => to_char(p_person_id)
                      ,p_param2         => p_input1
                      ,p_param2_value   => p_input1_value);
  l_return := l_outputs(l_outputs.first).value;
  --
  l_actn := 'Evaluating benutils.formula return...';
  --
  If upper(l_return) not in ('Y', 'N')  then
      --
      -- Defensive coding for Non Y return
      --
      rpt_error(p_proc      => l_proc
               ,p_last_actn => l_actn
               ,p_rpt_flag  => p_batch_flag);
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL',
                 'person_selection_rule_id :'||p_person_selection_rule_id);
      fnd_message.set_token('PROC',l_proc);
      Raise ben_batch_utils.g_record_error;
  End if;
  return l_return;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When ben_batch_utils.g_record_error then
      raise;
  when others then
      rpt_error(p_proc => l_proc, p_last_actn => l_actn);
      raise;
End person_selection_rule;
--
-- ============================================================================
--                         <<Check_all_slaves_finished>>
-- ============================================================================
--
Procedure check_all_slaves_finished(p_rpt_flag  Boolean default FALSE) is
  --
  l_proc      varchar2(80) := g_package||'.check_all_slaves_finished';
  l_no_slaves boolean := true;
  l_dummy     varchar2(1);
  l_actn      varchar2(80);
  --
  Cursor c_slaves(p_request_id number) is
    Select null
      From fnd_concurrent_requests fnd
     Where fnd.phase_code <> 'C'
       And fnd.request_id = p_request_id;
Begin
  hr_utility.set_location ('Entering '||l_proc,5);
  If g_num_processes <> 0 then
    l_actn := 'Checking Slaves.....';
    While l_no_slaves loop
      l_no_slaves := false;
      For l_count in 1..g_num_processes loop
        open c_slaves(g_processes_tbl(l_count));
        fetch c_slaves into l_dummy;
        If c_slaves%found then
          l_no_slaves := true;
          close c_slaves;
          exit;
        End if;
        Close c_slaves;
      End loop;
      If (l_no_slaves) then
        dbms_lock.sleep(5);
      End if;
    End loop;
  End if;
  hr_utility.set_location ('Leavinging '||l_proc,5);
Exception
  when others then
    rpt_error(p_proc =>l_proc,p_last_actn=>l_actn,p_rpt_flag=>p_rpt_flag);
    raise;
End check_all_slaves_finished;
--
-- ============================================================================
--                     <<Create_restart_person_actions>>
-- ============================================================================
--
Procedure create_restart_person_actions
  (p_benefit_action_id  in  number
  ,p_effective_date     in  date
  ,p_chunk_size         in  number
  ,p_threads            in  number
  ,p_num_ranges         out nocopy number
  ,p_num_persons        out nocopy number
  ,p_commit_data        in  varchar2 default 'Y'
  ,p_non_person_cd      in  varchar2 default null
  ) is
  --
  cursor c_person_actions is
    Select act.person_action_id
          ,act.person_id
          ,act.ler_id
      From ben_person_actions act
     Where act.action_status_cd <> 'P'
       and nvl(act.non_person_cd,'x') = nvl(p_non_person_cd,'x')
       and act.benefit_action_id = p_benefit_action_id
          ;
  --
  l_proc            varchar2(80) := g_package||'.create_restart_person_actions';
  l_person_details         c_person_actions%rowtype;
  l_person_action_id       number;
  l_object_version_number  number;
  l_start_person_action_id number;
  l_end_person_action_id   number;
  l_num_rows               number := 0;
  l_rows                   number := 0;
  l_num_ranges             number := 0;
  l_num_persons            number := 0;
  l_range_id               number;
  l_actn                   varchar2(80);
Begin
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  -- Delete ranges from ben_batch_ranges table
  --
  l_actn := 'Calling ben_benmngle_purge.delete_batch_range_rows...';
  ben_benmngle_purge.delete_batch_range_rows
   (p_benefit_action_id => p_benefit_action_id,
    p_rows              => l_rows);
  --
  open c_person_actions;
  Loop
    --
    l_actn := 'Fetching c_person_action cursor...';
    --
    fetch c_person_actions into l_person_details;
    exit when c_person_actions%notfound;
    l_num_rows := l_num_rows + 1;
    l_num_persons := l_num_persons + 1;
    l_end_person_action_id := l_person_details.person_action_id;
    If l_num_rows = 1 then
      l_start_person_action_id := l_person_details.person_action_id;
    End if;
    If l_num_rows = p_chunk_size then
      --
      -- Create a range of data to be multithreaded.
      --
      l_actn := 'Calling Ben_batch_ranges_api.create_batch_ranges(in)...';
      Ben_batch_ranges_api.create_batch_ranges
        (p_validate                  => false
        ,p_benefit_action_id         => p_benefit_action_id
        ,p_range_id                  => l_range_id
        ,p_range_status_cd           => 'U'
        ,p_starting_person_action_id => l_start_person_action_id
        ,p_ending_person_action_id   => l_end_person_action_id
        ,p_object_version_number     => l_object_version_number
        ,p_effective_date            => p_effective_date
        );
      l_start_person_action_id := 0;
      l_end_person_action_id := 0;
      l_num_rows := 0;
      l_num_ranges := l_num_ranges + 1;
    End if;
  End loop;
  close c_person_actions;
  --
  -- Now create a range for any left over records that are less than
  -- the chunk size.
  --
  If l_num_rows <> 0 then
    --
    l_actn := 'Calling Ben_batch_ranges_api.create_batch_ranges(out)...';
    --
    ben_batch_ranges_api.create_batch_ranges
      (p_validate                  => false
      ,p_benefit_action_id         => p_benefit_action_id
      ,p_range_id                  => l_range_id
      ,p_range_status_cd           => 'U'
      ,p_starting_person_action_id => l_start_person_action_id
      ,p_ending_person_action_id   => l_end_person_action_id
      ,p_object_version_number     => l_object_version_number
      ,p_effective_date            => p_effective_date
      );
    l_num_ranges := l_num_ranges + 1;
  End if;
  If p_commit_data = 'Y' then
    commit;
  End if;
  p_num_ranges := l_num_ranges;
  p_num_persons := l_num_persons;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  when others then
    rpt_error(p_proc => l_proc, p_last_actn => l_actn);
    raise;
End create_restart_person_actions;
--
-- ============================================================================
--                        <<Batch_report>>
-- ============================================================================
--
Procedure batch_report
            (p_concurrent_request_id      in  number
            ,p_program_name               in  varchar2
            ,p_subtitle                   in  varchar2 default NULL
            ,p_request_id                 out nocopy number
            ) is
  l_proc         varchar2(80) := g_package||'.batch_reports';
  l_request_id   number;
Begin
  hr_utility.set_location('Entering :'||l_proc,10);
  If (p_subtitle is NULL) then
    l_request_id := fnd_request.submit_request
                      (application => 'BEN'
                      ,program     => p_program_name
                      ,description => NULL
                      ,sub_request => FALSE
                      ,argument1   => p_concurrent_request_id
                      );
  Else
    l_request_id := fnd_request.submit_request
                      (application => 'BEN'
                      ,program     => p_program_name
                      ,description => NULL
                      ,sub_request => FALSE
                      ,argument1   => p_concurrent_request_id
                      ,argument2   => p_subtitle
                      );
  End if;
  If l_request_id = 0 then
    raise ben_batch_utils.g_record_error;
  Else
    p_request_id := l_request_id;
  End if;
  hr_utility.set_location('Leaving :'||l_proc,10);
Exception
  when others then
    rpt_error(p_proc => l_proc, p_last_actn => 'Submitting ' || p_program_name);
    raise;
End batch_report;
--
-- ============================================================================
--                        <<Write_error_rec>>
-- ============================================================================
--
Procedure write_error_rec is
  l_msg_error_cd varchar2(80);
  l_actn         varchar2(80);
  l_proc         varchar2(80) := g_package||'.write_error_rec';
  l_msg          varchar2(2000);
begin
  --
  l_actn := 'getting error message..';
  --
  l_msg_error_cd := benutils.get_message_name;
  l_msg          := fnd_message.get;
  --
  write(p_text => l_msg);
  --
  if l_msg_error_cd is null then
    l_msg_error_cd := 'ERROR NOT SPECIFIED';
  End if;
  --
  l_actn := 'calling ben_batch_utils.write_rec....';
  ben_batch_utils.write_rec(p_typ_cd => 'ERROR'
                           ,p_err_cd => l_msg_error_cd
                           ,p_text   => l_msg
                           );
Exception
  when others then
    rpt_error(p_proc => l_proc, p_last_actn => l_actn);
    raise;
End write_error_rec;
--
-- ============================================================================
--                        <<summary_by_action>>
-- ============================================================================
--
procedure summary_by_action
            (p_concurrent_request_id in  number
            ,p_cd_1   in  varchar2, p_val_1  out nocopy number
            ,p_cd_2   in  varchar2, p_val_2  out nocopy number
            ,p_cd_3   in  varchar2, p_val_3  out nocopy number
            ,p_cd_4   in  varchar2, p_val_4  out nocopy number
            ,p_cd_5   in  varchar2, p_val_5  out nocopy number
            ,p_cd_6   in  varchar2, p_val_6  out nocopy number
            ,p_cd_7   in  varchar2, p_val_7  out nocopy number
            ,p_cd_8   in  varchar2, p_val_8  out nocopy number
            ,p_cd_9   in  varchar2, p_val_9  out nocopy number
            ,p_cd_10  in  varchar2, p_val_10 out nocopy number
            ) is
  l_proc       varchar2(80) := g_package||'.summary_by_action';
  Cursor c_reporting is
    Select count(*) amount, rep.rep_typ_cd
      from ben_reporting rep
          ,ben_benefit_actions bft
     where bft.benefit_action_id = rep.benefit_action_id
       and bft.request_id = p_concurrent_request_id
       and rep.rep_typ_cd in (p_cd_1, p_cd_2, p_cd_3, p_cd_4, p_cd_5
                             ,p_cd_6, p_cd_7, p_cd_8, p_cd_9, p_cd_10)
    group  by rep_typ_cd;
  --
  l_val_1      number :=0;
  l_val_2      number :=0;
  l_val_3      number :=0;
  l_val_4      number :=0;
  l_val_5      number :=0;
  l_val_6      number :=0;
  l_val_7      number :=0;
  l_val_8      number :=0;
  l_val_9      number :=0;
  l_val_10     number :=0;
  l_reporting  c_reporting%rowtype;
Begin
  hr_utility.set_location('Entering :'||l_proc,10);
  open c_reporting;
  loop
    fetch c_reporting into l_reporting;
    exit when c_reporting%notfound;
    If l_reporting.rep_typ_cd = p_cd_1 then
        p_val_1 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_2 then
        p_val_2 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_3 then
        p_val_3 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_4 then
        p_val_4 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_5 then
        p_val_5 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_6 then
        p_val_6 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_7 then
        p_val_7 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_8 then
        p_val_8 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_9 then
        p_val_9 := l_reporting.amount;
    Elsif l_reporting.rep_typ_cd = p_cd_10 then
        p_val_10 := l_reporting.amount;
    End if;
  End loop;
  close c_reporting;
  hr_utility.set_location('Leaving :'||l_proc,10);
End summary_by_action;
--
-- ============================================================================
--                     <<Procedure: *get_rpt_header*>>
-- ============================================================================
--
Procedure get_rpt_header
            (p_concurrent_request_id    in number
            ,p_cd_1                     out nocopy varchar2
            ,p_cd_2                     out nocopy varchar2
            ,p_cd_3                     out nocopy varchar2
            ,p_cd_4                     out nocopy varchar2
            ,p_cd_5                     out nocopy varchar2
            ,p_cd_6                     out nocopy varchar2
            ,p_cd_7                     out nocopy varchar2
            ,p_cd_8                     out nocopy varchar2
            ,p_cd_9                     out nocopy varchar2
            ,p_cd_10                    out nocopy varchar2
            ,p_cd_11                    out nocopy varchar2
            ,p_cd_12                    out nocopy varchar2
            ,p_cd_13                    out nocopy varchar2
            ,p_cd_14                    out nocopy varchar2
            ,p_cd_15                    out nocopy varchar2
            ,p_cd_16                    out nocopy varchar2
            ,p_cd_17                    out nocopy varchar2
            ,p_cd_18                    out nocopy varchar2
            ,p_cd_19                    out nocopy varchar2
            ,p_cd_20                    out nocopy varchar2
            ) is
  Cursor c1 is
    select upper(c.execution_file_name)
      from fnd_concurrent_requests a
          ,fnd_concurrent_programs b
          ,fnd_executables c
     where a.request_id = p_concurrent_request_id
       and a.concurrent_program_id = b.concurrent_program_id
       and b.application_id = 805
       and c.application_id = 805
       and b.executable_id = c.executable_id
          ;
  L_proc               varchar2(80) := g_package||'.get_rpt_header';
  l_exec               varchar2(80);
  l_argumentNameVar    dbms_describe.varchar2_table;
  l_OverLoadNum        dbms_describe.number_table;
  l_PosNum             dbms_describe.number_table;
  l_LevelNum           dbms_describe.number_table;
  l_DataTypeNum        dbms_describe.number_table;
  l_defaultValueNum    dbms_describe.number_table;
  l_InOutNum           dbms_describe.number_table;
  l_LengthNum          dbms_describe.number_table;
  l_PrecisionNum       dbms_describe.number_table;
  l_ScaleNum           dbms_describe.number_table;
  l_RadixNum           dbms_describe.number_table;
  l_SpareNum           dbms_describe.number_table;
  l_cnt                binary_integer := 1;
  lc                   binary_integer := 0;
  l_actn               varchar2(80);
Begin
  hr_utility.set_location('Entering :'||l_proc,05);
  l_actn := 'Openning C1 cursor...';
  open c1;
  fetch c1 into l_exec;
  If c1%found then
    l_actn := 'Calling hr_general.describe_procedure...'; -- Bug 1504327
    hr_general.describe_procedure --dbms_desbribe.dbms_procedure Bug 1504327
      (object_name   => l_exec
      ,reserved1     => NULL
      ,reserved2     => NULL
      ,overload      => l_OverLoadNum
      ,position      => l_PosNum
      ,level         => l_LevelNum
      ,argument_name => l_ArgumentNameVar
      ,datatype      => l_DataTypeNum
      ,default_value => l_DefaultValueNum
      ,in_out        => l_InOutNum
      ,length        => l_LengthNum
      ,precision     => l_precisionNum
      ,scale         => l_scaleNum
      ,radix         => l_RadixNum
      ,spare         => l_SpareNum
      );
    l_actn := 'Outside while loop...';
    Begin
      While l_datatypenum(l_cnt) <> 0 loop
        If (upper(l_ArgumentNameVar(l_cnt)) in
             ('ERRBUF', 'RETCODE', 'P_BENEFIT_ACTION_ID')) then
          Null;
        Else
          Lc := Lc +1;
          If lc = 1 then
            p_cd_1 := upper(l_ArgumentNameVar(l_cnt));
          Elsif lc = 2 then
            p_cd_2 := upper(l_ArgumentNameVar(l_cnt));
          Elsif lc = 3 then
            p_cd_3 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 4 then
            p_cd_4 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 5 then
            p_cd_5 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 6 then
            p_cd_6 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 7 then
            p_cd_7 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 8 then
            p_cd_8 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 9 then
            p_cd_9 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 10 then
            p_cd_10 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 11 then
            p_cd_11 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 12 then
            p_cd_12 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 13 then
            p_cd_13 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 14 then
            p_cd_14 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 15 then
            p_cd_15 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 16 then
            p_cd_16 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 17 then
            p_cd_17 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 18 then
            p_cd_18 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 19 then
            p_cd_19 := upper(l_ArgumentNameVar(l_cnt));
          Elsif Lc = 20 then
            p_cd_20 := upper(l_ArgumentNameVar(l_cnt));
          End if;
        End if;
        l_cnt := l_cnt + 1;
      End loop;
    Exception
      when no_data_found then
          null;
      when others then
          raise;
    End;
  Else
    l_cnt := 0;
  End if;
  close c1;
  hr_utility.set_location('Leaving :'||l_proc,10);
Exception
  When others then
    rpt_error(p_proc => l_proc, p_last_actn => l_actn);
    raise;
End get_rpt_header;
--
-- ============================================================================
--                     <<Procedure: *standard_header*>>
-- ============================================================================
--
Procedure standard_header
          (p_concurrent_request_id      in  number,
           p_concurrent_program_name    out nocopy varchar2,
           p_process_date               out nocopy date,
           p_mode                       out nocopy varchar2,
           p_derivable_factors          out nocopy varchar2,
           p_validate                   out nocopy varchar2,
           p_person                     out nocopy varchar2,
           p_person_type                out nocopy varchar2,
           p_program                    out nocopy varchar2,
           p_business_group             out nocopy varchar2,
           p_plan                       out nocopy varchar2,
           p_popl_enrt_typ_cycl         out nocopy varchar2,
           p_plans_not_in_programs      out nocopy varchar2,
           p_just_programs              out nocopy varchar2,
           p_comp_object_selection_rule out nocopy varchar2,
           p_person_selection_rule      out nocopy varchar2,
           p_life_event_reason          out nocopy varchar2,
           p_organization               out nocopy varchar2,
           p_postal_zip_range           out nocopy varchar2,
           p_reporting_group            out nocopy varchar2,
           p_plan_type                  out nocopy varchar2,
           p_option                     out nocopy varchar2,
           p_eligibility_profile        out nocopy varchar2,
           p_variable_rate_profile      out nocopy varchar2,
           p_legal_entity               out nocopy varchar2,
           p_payroll                    out nocopy varchar2,
           p_debug_message			 out nocopy varchar2,
           p_location                   out nocopy varchar2,
           p_audit_log                  out nocopy varchar2,
           p_benfts_group               out nocopy varchar2,
           p_date_from                  out nocopy date,         /* Bug 3517604 */
           p_status                     out nocopy varchar2) is
  --
  l_proc                    varchar2(80) := g_package||'.standard_header';
  l_all                     varchar2(80) := 'All';
  l_none                    varchar2(80) := 'None';
  --
  cursor c_benefit_actions is
    select bft.process_date,
           hr.meaning,
           hr1.meaning,
           hr2.meaning,
           nvl(ppf.full_name,l_all),
           nvl(ppt.user_person_type,l_all),
           nvl(pgm.name,l_all),
           pbg.name,
           nvl(pln.name,l_all),
           decode(hr5.meaning,
                  null,
                  l_all,
                  hr5.meaning||
                  ' '||
                  pln2.name||
                  ' '||
                  pgm2.name||
                  ' '||
                  epo.strt_dt||
                  ' '||
                  epo.end_dt),
           hr3.meaning,
           hr4.meaning,
           nvl(ff.formula_name,l_none),
           nvl(ff2.formula_name,l_none),
           nvl(ler.name,l_all),
           nvl(org.name,l_all),
           decode(rzr.from_value||'-'||rzr.to_value,
                  '-',
                  l_all,
                  rzr.from_value||'-'||rzr.to_value),
           nvl(bnr.name,l_all),
           nvl(ptp.name,l_all),
           nvl(opt.name,l_all),
           nvl(elp.name,l_all),
           nvl(vpf.name,l_all),
           nvl(tax.name,l_all),
           nvl(pay.payroll_name,l_all),
           decode(debug_messages_flag, 'Y', 'Yes', 'N', 'No', l_all) dg_msg,
           nvl(lc.location_code, l_all),
           decode(audit_log_flag, 'Y', 'Yes', 'N', 'No', l_all) audit_log,
           nvl(bnfg.name,l_all),
           conc.user_concurrent_program_name,
           fnd1.meaning,
           bft.date_from   /* Bug 3517604 */
    from   ben_benefit_actions bft,
           hr_lookups hr,
           hr_lookups hr1,
           hr_lookups hr2,
           hr_lookups hr3,
           hr_lookups hr4,
           hr_lookups hr5,
           fnd_lookups fnd1,
           per_people_f ppf,
           per_person_types ppt,
           ben_pgm_f pgm,
           per_business_groups pbg,
           ben_pl_f pln,
           ff_formulas_f ff,
           ff_formulas_f ff2,
           ben_ler_f ler,
           hr_all_organization_units_vl org,
           ben_rptg_grp_v bnr,
           ben_pl_typ_f ptp,
           ben_opt_f opt,
           ben_eligy_prfl_f elp,
           ben_vrbl_rt_prfl_f vpf,
           pay_payrolls_f pay,
           ben_pstl_zip_rng_f rzr,
           hr_tax_units_v tax,
           ben_popl_enrt_typ_cycl_f pop,
           ben_enrt_perd epo,
           ben_pl_f pln2,
           ben_pgm_f pgm2,
           fnd_concurrent_requests fnd,
           fnd_concurrent_programs_tl conc,
           hr_locations lc,
           ben_benfts_grp bnfg
    where  fnd.request_id = p_concurrent_request_id
    and    conc.concurrent_program_id = fnd.concurrent_program_id
    and    conc.application_id = 805
    and    conc.language = userenv('LANG')  --Bug 2394141
    and    bft.request_id = fnd.request_id
    and    hr.lookup_code = bft.mode_cd
    and    hr.lookup_type = 'BEN_BENMNGLE_MD'
    and    hr1.lookup_code = bft.derivable_factors_flag
    and    hr1.lookup_type = 'YES_NO'
    and    hr2.lookup_code = bft.validate_flag
    and    hr2.lookup_type = 'YES_NO'
    and    hr3.lookup_code = bft.no_programs_flag
    and    hr3.lookup_type = 'YES_NO'
    and    hr4.lookup_code = bft.no_plans_flag
    and    hr4.lookup_type = 'YES_NO'
    and    hr5.lookup_code(+) = pop.enrt_typ_cycl_cd
    and    hr5.lookup_type(+) = 'BEN_ENRT_TYP_CYCL'
    and    fnd.status_code = fnd1.lookup_code
    and    fnd1.lookup_type = 'CP_STATUS_CODE'
    and    pop.popl_enrt_typ_cycl_id(+) = epo.popl_enrt_typ_cycl_id
    and    bft.process_date
           between nvl(pop.effective_start_date,bft.process_date)
           and     nvl(pop.effective_end_date,bft.process_date)
    and    epo.enrt_perd_id(+) = bft.popl_enrt_typ_cycl_id
    and    pln2.pl_id(+) = pop.pl_id
    and    bft.process_date
           between nvl(pln2.effective_start_date,bft.process_date)
           and     nvl(pln2.effective_end_date,bft.process_date)
    and    pgm2.pgm_id(+) = pop.pgm_id
    and    bft.process_date
           between nvl(pgm2.effective_start_date,bft.process_date)
           and     nvl(pgm2.effective_end_date,bft.process_date)
    and    ppf.person_id(+) = bft.person_id
    and    bft.process_date
           between nvl(ppf.effective_start_date,bft.process_date)
           and     nvl(ppf.effective_end_date,bft.process_date)
    and    pay.payroll_id(+) = bft.payroll_id
    and    bft.process_date
           between nvl(pay.effective_start_date,bft.process_date)
           and     nvl(pay.effective_end_date,bft.process_date)
    and    ppt.person_type_id(+) = bft.person_type_id
    and    pgm.pgm_id(+) = bft.pgm_id
    and    bft.process_date
           between nvl(pgm.effective_start_date,bft.process_date)
           and     nvl(pgm.effective_end_date,bft.process_date)
    and    pbg.business_group_id = bft.business_group_id
    and    tax.tax_unit_id(+) = bft.legal_entity_id
    and    pln.pl_id(+) = bft.pl_id
    and    bft.process_date
           between nvl(pln.effective_start_date,bft.process_date)
           and     nvl(pln.effective_end_date,bft.process_date)
    and    ler.ler_id(+) = bft.ler_id
    and    bft.process_date
           between nvl(ler.effective_start_date,bft.process_date)
           and     nvl(ler.effective_end_date,bft.process_date)
    and    rzr.pstl_zip_rng_id(+) = bft.pstl_zip_rng_id
    and    bft.process_date
           between nvl(rzr.effective_start_date,bft.process_date)
           and     nvl(rzr.effective_end_date,bft.process_date)
    and    ptp.pl_typ_id(+) = bft.pl_typ_id
    and    bft.process_date
           between nvl(ptp.effective_start_date,bft.process_date)
           and     nvl(ptp.effective_end_date,bft.process_date)
    and    opt.opt_id(+) = bft.opt_id
    and    bft.process_date
           between nvl(opt.effective_start_date,bft.process_date)
           and     nvl(opt.effective_end_date,bft.process_date)
    and    ff.formula_id(+) = bft.comp_selection_rl
    and    bft.process_date between
             nvl(ff.effective_start_date,bft.process_date)
               and nvl(ff.effective_end_date,bft.process_date)
    and    ff2.formula_id(+) = bft.person_selection_rl
    and    bft.process_date between
             nvl(ff2.effective_start_date,bft.process_date)
               and nvl(ff2.effective_end_date,bft.process_date)
    and    bnr.rptg_grp_id(+) = bft.rptg_grp_id
    and    elp.eligy_prfl_id(+) = bft.eligy_prfl_id
    and    bft.process_date between
             nvl(elp.effective_start_date,bft.process_date)
               and nvl(elp.effective_end_date,bft.process_date)
    and    vpf.vrbl_rt_prfl_id(+) = bft.vrbl_rt_prfl_id
    and    bft.process_date between
             nvl(vpf.effective_start_date,bft.process_date)
               and nvl(vpf.effective_end_date,bft.process_date)
    and    org.organization_id(+) = bft.organization_id
    and    bft.process_date between
             nvl(org.date_from,bft.process_date)
               and nvl(org.date_to,bft.process_date)
    and    nvl(bft.location_id,-1) = lc.location_id (+)
    and    nvl(bft.benfts_grp_id,-1) = bnfg.benfts_grp_id (+)
         ;
  --
begin
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  -- Get parameter information from batch process run
  --
  open c_benefit_actions;
    --
    fetch c_benefit_actions into p_process_date,
                                 p_mode,
                                 p_derivable_factors,
                                 p_validate,
                                 p_person,
                                 p_person_type,
                                 p_program,
                                 p_business_group,
                                 p_plan,
                                 p_popl_enrt_typ_cycl,
                                 p_plans_not_in_programs,
                                 p_just_programs,
                                 p_comp_object_selection_rule,
                                 p_person_selection_rule,
                                 p_life_event_reason,
                                 p_organization,
                                 p_postal_zip_range,
                                 p_reporting_group,
                                 p_plan_type,
                                 p_option,
                                 p_eligibility_profile,
                                 p_variable_rate_profile,
                                 p_legal_entity,
                                 p_payroll,
                                 p_debug_message,
                                 p_location,
                                 p_audit_log,
                                 p_benfts_group,
                                 p_concurrent_program_name,
                                 p_status,
                                 p_date_from; /* Bug 3517604 */
    --
  close c_benefit_actions;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  --
end standard_header;
--
--Bug 2978945

FUNCTION rows_exist
         (p_base_table_name IN VARCHAR2,
          p_base_key_column IN VARCHAR2,
          p_base_key_value  IN NUMBER
         )
         RETURN BOOLEAN IS
--
  l_proc        VARCHAR2(72);
  l_ret_column  number(1);      -- Returning Sql Column
  g_dynamic_sql VARCHAR2(2000);
  g_debug       BOOLEAN;
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'rows_exist';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  IF (p_base_key_value IS NOT NULL) THEN
    IF p_base_table_name IS NULL OR
       p_base_key_column IS NULL THEN
      -- Mandatory arg checking
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_base_table_name',
         p_argument_value => p_base_table_name);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_base_key_column',
         p_argument_value => p_base_key_column);
      --
    END IF;
    -- Define dynamic sql text with substitution tokens
    g_dynamic_sql :=
      'SELECT NULL '||
      'FROM '||LOWER(p_base_table_name)||' t '||
      'WHERE t.'||LOWER(p_base_key_column)||' = :p_base_key_value ';

    EXECUTE IMMEDIATE g_dynamic_sql
    INTO  l_ret_column
    USING p_base_key_value;
    -- one row exists so return true
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 10);
    END IF;
    RETURN(TRUE);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 15);
    END IF;
    -- return false as no rows exist
    RETURN(FALSE);
  WHEN TOO_MANY_ROWS THEN
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 20);
    END IF;
    -- return TRUE because more than one row exists
    RETURN(TRUE);
  WHEN OTHERS THEN
    RAISE;
END rows_exist;

--Bug 2978945
--
-- ==================================================================================
--                        << Procedure: person_selection_rule >>
--   This procedure is added to report errors for a person while executing the selection rule
--   and prevent the conc process from failing .
-- ==================================================================================
procedure person_selection_rule
		 (p_person_id                in  Number
                 ,p_business_group_id        in  Number
                 ,p_person_selection_rule_id in  Number
                 ,p_effective_date           in  Date
                 ,p_input1                   in  varchar2 default null    -- Bug 5331889
                 ,p_input1_value             in  varchar2 default null
		 ,p_return                   in out nocopy varchar2
                 ,p_err_message              in out nocopy varchar2 ) as

  Cursor c1 is
      Select assignment_id
        From per_assignments_f paf
       Where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         And paf.primary_flag = 'Y'
         And paf.business_group_id = p_business_group_id
         And p_effective_date between paf.effective_start_date and paf.effective_end_date ;
  --
    Cursor c2 is
      Select assignment_id
        From per_all_assignments_f paf
       Where paf.person_id = p_person_id
         and paf.assignment_type <> 'C'
         And paf.primary_flag = 'Y'
         And paf.business_group_id = p_business_group_id
         And p_effective_date between paf.effective_start_date and paf.effective_end_date ;
  --
  l_proc   	       varchar2(80) := g_package||'.person_selection_rule';
  l_outputs   	   ff_exec.outputs_t;
  --l_return  	   varchar2(30);
  l_assignment_id  number;
  l_actn           varchar2(80);
  value_exception  exception ;
Begin
  hr_utility.set_location ('Entering '||l_proc,10);
  --
  -- Get assignment ID form per_assignments_f table.
  --
  l_actn := 'Opening Assignment cursor...';
  --
  if  hr_security.view_all =  'Y' and hr_general.get_xbg_profile = 'Y'
  then
     open c2;
     fetch c2 into l_assignment_id;
     If c2%notfound
     then
        write(p_text => 'Warning : No Primary assignment found for this Person ID : '|| p_person_id); --5643310
     End if;
     close c2;
  else
     open c1;
     fetch c1 into l_assignment_id;
     If c1%notfound
     then
        write(p_text => 'Warning : No Primary assignment found for this Person ID : '|| p_person_id); --5643310
     End if;
     close c1;
  end if;
  --
  -- Call formula initialise routine
  --
  l_actn := 'Calling benutils.formula procedure...';

  l_outputs := benutils.formula
                      (p_formula_id        => p_person_selection_rule_id
                      ,p_effective_date    => p_effective_date
                      ,p_business_group_id => p_business_group_id
                      ,p_assignment_id     => l_assignment_id
                      ,p_param1         => 'BEN_IV_PERSON_ID'          -- Bug 5331889
                      ,p_param1_value   => to_char(p_person_id)
                      ,p_param2         => p_input1
                      ,p_param2_value   => p_input1_value);
  p_return := l_outputs(l_outputs.first).value;
  --
  l_actn := 'Evaluating benutils.formula return...';
  --
  If upper(p_return) not in ('Y', 'N')  then
      Raise value_exception ;
  End if;
  hr_utility.set_location ('Leaving '||l_proc,10);
Exception
  When ben_batch_utils.g_record_error then
      p_return := 'N' ;
      fnd_message.set_name('BEN','BEN_91698_NO_ASSIGNMENT_FND');
      fnd_message.set_token('ID' ,to_char(p_person_id) );
      fnd_message.set_token('PROC',l_proc  ) ;
	  p_err_message := fnd_message.get ;

  When value_exception then
      p_return := 'N' ;
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.set_token('RL','person_selection_rule_id :'||p_person_selection_rule_id);
      fnd_message.set_token('PROC',l_proc  ) ;
	  p_err_message := fnd_message.get ;

  when others then
      p_return := 'N' ;
      p_err_message := 'Unhandled exception while processing Person : '||to_char(p_person_id)
                       ||' in package : '|| l_proc ||'.' || substr(sqlerrm,1,170);

End person_selection_rule;
--
end ben_batch_utils;

/
