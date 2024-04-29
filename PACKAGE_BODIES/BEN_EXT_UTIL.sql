--------------------------------------------------------
--  DDL for Package Body BEN_EXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_UTIL" as
/* $Header: benxutil.pkb 120.13.12010000.2 2008/08/05 15:01:54 ubhat ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Utility.
Purpose:
    This is used for utility style processes for the Benefits Extract System.
History:
    Date             Who        Version    What?
    ----             ---        -------    -----
    24 Oct 98        Ty Hayden  115.0      Created.
    26 Oct 98        Ty Hayden  115.1      Added request_id as input.
    04 Feb 99        Pulak Das  115.2      Added procedure
                                           get_rec_nam_num,
                                           get_rec_statistics,
                                           get_per_statistics,
                                           get_err_warn_statitics.
    08 Feb 99        Pulak Das  115.3      Added procedure
                                           get_statistics_text
                                           Added function
                                           get_value (from benxsttl.pkb).
    10 Feb 99        Pulak Das  115.4      Modified procedure
                                           get_statistics_text
    10 Feb 99        Pulak Das  115.5      Modified procedure
                                           get_per_statistics
    15 Feb 99        Ty Hayden  115.6      Added ff function
                                           get_extract_value
    19 Feb 99        Pulak Das  115.7      Modified get_value procedure
    03 Mar 99        Siok Tee   115.8      Removed dbms_output.put_line.
    09 Mar 99        Ty Hayden  115.9      Removed CHR statements.
    13 May 99        I Sen      115.10     Added calc_ext_date function
                                           (earlier in benxthrd)
    16 Jun 99        I Sen      115.11     Added foreign key ref ext_rslt_id
    01 Jul 99        Ty Hayden  115.12     Added coverage amt to get_extract_value
    06 Aug 99        Asen       115.13     Added messages : Entering, Exiting.
    27 Aug 99        Ty Hayden  115.14     Changed get_extract_val substr nums.
    02 Sep 99        Ty Hayden  115.15     Added get_chg_dates.
    03 Sep 99        I Sen      115.16     Changed user entered date to MM/DD/YYYY
    13 Sep 99        Ty Hayden  115.17     Added get_cm_dates.
    10 Oct 99        Ty Hayden  115.18     Changed positions for get extract val.
    12 Oct 99        Ty Hayden  115.19     Changed positions for get extract val.
    i3 Nov 99        Ty Hayden  115.20     Added new comm and chg date codes.
    11 Nov 99        Ty Hayden  115.21     Added get_ext_dates.
    30 Dec 99        Ty Hayden  115.22     Remove get_extract_value.
    12 Feb 00        Ty Hayden  115.23     Added 18MA.
    24 Feb 00        Ty Hayden  115.24     Change default of person and benefits date
    01 Mar 00        P Clark    115.25     Changed line length of l_text in
                                           get_statistics_text. ref bug 1209782.
    06 Mar 00        P Clark    115.26     Changed procedure get_rec_nam_num
                                           to order by record number and return
                                           names with no rslt_dtl_id's.
                                           Ref bug 1219126.
    27 Sep 00        Ty Hayden  115.28     Change DAED and DARD logic.
    29 Sep 00        Tilak      115.29     New hr Lookup code addeed  bug 1409185
    02 oct 00        tilak      115.30     new hr lookup added - next-curr-prev 16th bug 1380732
    30 jan 01        tilak      115.31     1579767 error message changed
    09 mar 01        tilak      115.32     bug : 1550072  date codes added
    24 mar 01        tilak      115.33     error message substr for set_location
    14 jun 01        tilak      115.34     current swmi month satrt date and end date
                                           calcualtion added 1831651
    04 jul 01        tilak      115.53     PM15  - 15 of previous month date code added
    13 jul 01        tilak      115.54     CM15    Corrected
    23 jul 01        tilak      115.55     whne error log created , global person id is defaulted
    13 Mar 02        ikasire    115.38     UTF8 Changes for BEN
    14-mar-02        ikasire    115.39     dbdrv
    16-may-02        tjesumi    115.40    date override criteria TDRASG added for  full profile
                                           2376285
    28-Sug-02        tjesumic   115.41     ANSI Extract , form is not supporting more then
                                           2000 so get_statistics_text return only 2000 char
    24-Dec-02        bmanyam    115.42      NOCOPY Changes
    17-May-04        hmani      115.43     Added assignment_type = 'E' condition - Bug 3629576
    19-Oct-04        tjesumic   115.44     FDO2PM , LDO2PM added for dt calcaultion
    15-Dec-04        tjesumic   115.45     pl_pl_id added to calc_Ext_dates
    22-MAr-05        tjesumic   115.45     CWB (CW) date determination added
    20-Oct-2005      tjesumic   115.47     warning validates numer and message for the uniquness
                                           the same error with element name could appear for a person
                                           this fix dispalys all the warnings
    01-Feb-06        tjesumic   115.48    date override criteria TDPRASG added for  full profile
    06-Feb-06        tjesumic   115.47    messages uniqness validated for warnings , new extract status code
                                          'W' added
    31-Oct-06        tjesumic   115.48    for performance person_dt and benefit dt code are cached in benxtrct pkg
                                          pre-req  benxrct.pkh/pkb  32/57
                                          Entries_affected procedure moved from pqp to ben. Need pkh 115.15
    10-Nov-06        tjesumic   115.49    Performance fix for Entries_affected. the values are cached
    12-Feb-07        tjesumic   115.50    DBED and DBRD added for previous extract date
    02-Mar-07        tjesumic   115.53    Date code calcualtion chnaged. TDRASG and TDPRASG calcualted for all type
    15-Mar-07        tjesumic   115.55    the lenght is creating issue with japan customer so get_stat lengh changed
                                          to lengthb
    30-Apr-08        vkodedal   115.60    entries_affected - added one parameter for penserver
--------------------------------------------------------------------------------
*/
-- package locak globals
-- globals used for entries_affected
TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar2 IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

TYPE g_r_element_entries IS RECORD
                (
                element_entry_id    t_number
                ,datetracked_event_id t_number
                );

TYPE t_event_element IS table of varchar2(1) INDEX BY BINARY_INTEGER;
TYPE t_tab_of_collection IS TABLE OF t_number INDEX BY BINARY_INTEGER;

g_t_event_element       t_event_element ;
g_eg_has_purge_dte      t_number;
g_ele_set_ids_on_eg     t_tab_of_collection;
g_datetraced_event_ids  t_tab_of_collection;



---

PROCEDURE write_err
    (p_err_num                        in  number    default null,
     p_err_name                       in  varchar2  default null,
     p_typ_cd                         in  varchar2  default null,
     p_person_id                      in  number    default null,
     p_request_id                     in  number    default null,
     p_business_group_id              in  number    default null,
     p_ext_rslt_id                    in  number    default null)
    IS
   --
   l_ext_rslt_err_id number;
   l_object_version_number number;
   l_dummy varchar2(1);
   l_proc      varchar2(72) := g_package||'.write_err';
   --
   cursor c_xre is
     select 'x'
       from ben_ext_rslt_err xre
       where xre.ext_rslt_id = p_ext_rslt_id --xre.request_id = fnd_global.conc_request_id
             and xre.person_id = p_person_id
             and xre.err_num = p_err_num
             and ( /*p_typ_cd <> 'W'
                   or*/  p_err_name is null
                   or  p_err_name = xre.err_txt
                 ) ;

   --
   BEGIN
    --
      hr_utility.set_location('Entering'||l_proc, 5);
      --
      open c_xre;
      fetch c_xre into l_dummy;
      hr_utility.set_location('error msg '||substr(p_err_name,1,100), 99.96 );
      if c_xre%notfound then  -- only write once.
        ben_ext_rslt_err_api.create_ext_rslt_err
                    (p_validate              => FALSE,
                     p_ext_rslt_err_id       => l_ext_rslt_err_id,
                     p_err_num               => p_err_num,
                     p_err_txt               => p_err_name,
                     p_typ_cd                => p_typ_cd,
                     p_person_id             => nvl(p_person_id,ben_ext_person.g_person_id),
                     p_business_group_id     => p_business_group_id,
                     p_ext_rslt_id           => p_ext_rslt_id,
                     p_object_version_number => l_object_version_number,
                     p_request_id            => nvl(p_request_id,fnd_global.conc_request_id),
                     p_program_application_id => fnd_global.prog_appl_id,
                     p_program_id            => fnd_global.conc_program_id,
                     p_program_update_date   => sysdate,
                     p_effective_date        => sysdate
                    );
     end if;
    --
      hr_utility.set_location('Exiting'||l_proc, 15);
    --
   END WRITE_ERR;
--
--
-- This procedure will return a data structure containing the name and number
-- of all extracted records corresponding to a ext_rslt_id or request_id or both.
-- If no records are found then one record with value null, 0 will be returned.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then one record with value null, 0 will be returned.
--
Procedure get_rec_nam_num
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_rec_tab            out nocopy    g_rec_nam_num_tab_typ
          ) is
--
--Modified cursor version 115.26
  CURSOR csr_get_rec_tot_rslt IS
  SELECT r.name name,
         count(d.ext_rslt_dtl_id) count
  FROM   ben_ext_rslt_dtl d,
         ben_ext_rcd r,
         ben_ext_rcd_in_file f,
         ben_ext_rslt rs,
         ben_ext_dfn df
  WHERE  d.ext_rslt_id(+) = p_ext_rslt_id
  AND    f.ext_rcd_id  = r.ext_rcd_id
  AND    r.ext_rcd_id  = d.ext_rcd_id (+)
  AND    f.ext_file_id = df.ext_file_id
  AND    df.ext_dfn_id = rs.ext_dfn_id
  AND    rs.ext_rslt_id = p_ext_rslt_id
  GROUP BY r.name, f.seq_num, f.ext_rcd_id
  ORDER BY f.seq_num;
--
--Modified cursor version 115.26
  CURSOR csr_get_rec_tot_both IS
  SELECT r.name name,
         count(d.ext_rslt_dtl_id) count
  FROM   ben_ext_rslt_dtl d,
         ben_ext_rcd r,
         ben_ext_rcd_in_file f,
         ben_ext_rslt rs,
         ben_ext_dfn df
  WHERE  d.ext_rslt_id(+) = p_ext_rslt_id
  AND    d.request_id(+)  = p_request_id
  AND    f.ext_rcd_id  = r.ext_rcd_id
  AND    r.ext_rcd_id  = d.ext_rcd_id (+)
  AND    f.ext_file_id = df.ext_file_id
  AND    df.ext_dfn_id = rs.ext_dfn_id
  AND    rs.ext_rslt_id = p_ext_rslt_id
  GROUP BY r.name, f.seq_num, f.ext_rcd_id
  ORDER BY f.seq_num;
--
  cursor csr_get_rec_tot_req is
  SELECT b.name rec_name
        ,count(ext_rslt_dtl_id)
  FROM   ben_ext_rslt_dtl a
        ,ben_ext_rcd b
  WHERE  a.ext_rcd_id = b.ext_rcd_id
  AND    a.ext_rslt_id = p_ext_rslt_id  --a.request_id = p_request_id
  GROUP BY b.name
  ORDER BY upper(b.name);
--
--New cursor version 115.26
  CURSOR csr_get_count(p_name in varchar2)IS
  SELECT count(r.name) count
  FROM   ben_ext_rcd r,
         ben_ext_rcd_in_file f,
         ben_ext_rslt rs,
         ben_ext_dfn df
  WHERE  f.ext_rcd_id   = r.ext_rcd_id
  AND    f.ext_file_id  = df.ext_file_id
  AND    df.ext_dfn_id  = rs.ext_dfn_id
  AND    rs.ext_rslt_id = p_ext_rslt_id
  AND    r.name         = p_name
  GROUP BY r.name;
--
  l_counter        number := 0;
  l_count          number;
  l_name           ben_ext_rcd.name%type;
  l_num            number;
  l_proc      varchar2(72) := g_package||'.get_rec_nam_num';
--
begin
  --
    hr_utility.set_location('Entering'||l_proc, 5);
  --
  if p_ext_rslt_id is null and p_request_id is null then
    p_rec_tab(1).name := null;
    p_rec_tab(1).num := 0;
  elsif p_ext_rslt_id is not null and p_request_id is null then
    open csr_get_rec_tot_rslt;
    loop
      fetch csr_get_rec_tot_rslt into l_name, l_num;
      exit when csr_get_rec_tot_rslt%notfound;
      open csr_get_count(p_name => l_name);
      fetch csr_get_count into l_count;
      close csr_get_count;
      l_counter := l_counter + 1;
      p_rec_tab(l_counter).name := l_name;
      p_rec_tab(l_counter).num := l_num/l_count;
    end loop;
    close csr_get_rec_tot_rslt;
    if l_counter = 0  then
      p_rec_tab(1).name := null;
      p_rec_tab(1).num := 0;
    end if;
  elsif p_ext_rslt_id is null and p_request_id is not null then
    open csr_get_rec_tot_req;
    loop
      fetch csr_get_rec_tot_req into l_name, l_num;
      exit when csr_get_rec_tot_req%notfound;
      l_counter := l_counter + 1;
      p_rec_tab(l_counter).name := l_name;
      p_rec_tab(l_counter).num := l_num;
    end loop;
    close csr_get_rec_tot_req;
    if l_counter = 0  then
      p_rec_tab(1).name := null;
      p_rec_tab(1).num := 0;
    end if;
  elsif p_ext_rslt_id is not null and p_request_id is not null then
    open csr_get_rec_tot_both;
    loop
      fetch csr_get_rec_tot_both into l_name, l_num;
      exit when csr_get_rec_tot_both%notfound;
      open csr_get_count(p_name => l_name);
      fetch csr_get_count into l_count;
      close csr_get_count;
      l_counter := l_counter + 1;
      p_rec_tab(l_counter).name := l_name;
      p_rec_tab(l_counter).num := l_num/l_count;
    end loop;
    close csr_get_rec_tot_both;
    if l_counter = 0  then
      p_rec_tab(1).name := null;
      p_rec_tab(1).num := 0;
    end if;
  end if;
  --
    hr_utility.set_location('Exiting'||l_proc, 15);
  --
--
end get_rec_nam_num;
--
--
-- This procedure will return total header records, total detail records,
-- total trailer records corresponding to a ext_rslt_id or request_id or both.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then 0, 0, 0 will be returned.
--
procedure get_rec_statistics
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_header_rec         out nocopy    number
          ,p_detail_rec         out nocopy    number
          ,p_trailer_rec        out nocopy    number
          ) is
--
  l_proc      varchar2(72) := g_package||'.get_rec_statistics';
--
  cursor csr_get_rec_statistics_rslt is
  SELECT count(decode(b.rcd_type_cd, 'H', b.rcd_type_cd))
        ,count(decode(b.rcd_type_cd, 'D', b.rcd_type_cd))
        ,count(decode(b.rcd_type_cd, 'T', b.rcd_type_cd))
  FROM   ben_ext_rslt_dtl a
        ,ben_ext_rcd b
  WHERE  a.ext_rcd_id = b.ext_rcd_id
  AND    a.ext_rslt_id = p_ext_rslt_id;
--
  cursor csr_get_rec_statistics_req is
  SELECT count(decode(b.rcd_type_cd, 'H', b.rcd_type_cd))
        ,count(decode(b.rcd_type_cd, 'D', b.rcd_type_cd))
        ,count(decode(b.rcd_type_cd, 'T', b.rcd_type_cd))
  FROM   ben_ext_rslt_dtl a
        ,ben_ext_rcd b
  WHERE  a.ext_rcd_id = b.ext_rcd_id
  AND    a.ext_rslt_id = p_ext_rslt_id;  --a.request_id = p_request_id;
--
  cursor csr_get_rec_statistics_both is
  SELECT count(decode(b.rcd_type_cd, 'H', b.rcd_type_cd))
        ,count(decode(b.rcd_type_cd, 'D', b.rcd_type_cd))
        ,count(decode(b.rcd_type_cd, 'T', b.rcd_type_cd))
  FROM   ben_ext_rslt_dtl a
        ,ben_ext_rcd b
  WHERE  a.ext_rcd_id = b.ext_rcd_id
  AND    a.request_id = p_request_id
  AND    a.ext_rslt_id = p_ext_rslt_id;
--
begin
  --
    hr_utility.set_location('Entering'||l_proc, 5);
  --
  if p_ext_rslt_id is null and p_request_id is null then
    p_header_rec := 0;
    p_detail_rec := 0;
    p_trailer_rec := 0;
  elsif p_ext_rslt_id is not null and p_request_id is null then
    open csr_get_rec_statistics_rslt;
    fetch csr_get_rec_statistics_rslt into p_header_rec,
                                           p_detail_rec,
                                           p_trailer_rec;
    close csr_get_rec_statistics_rslt;
  elsif p_ext_rslt_id is null and p_request_id is not null then
    open csr_get_rec_statistics_req;
    fetch csr_get_rec_statistics_req into p_header_rec,
                                          p_detail_rec,
                                          p_trailer_rec;
    close csr_get_rec_statistics_req;
  elsif p_ext_rslt_id is not null and p_request_id is not null then
    open csr_get_rec_statistics_both;
    fetch csr_get_rec_statistics_both into p_header_rec,
                                           p_detail_rec,
                                           p_trailer_rec;
    close csr_get_rec_statistics_both;
  end if;
  --
    hr_utility.set_location('Exiting'||l_proc, 15);
  --
end get_rec_statistics;
--
--
-- This procedure will return total people extracted, total people not
-- extracted due to error corresponding to a ext_rslt_id or request_id or both.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then 0, 0, 0 will be returned.
--
procedure get_per_statistics
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_per_xtrctd         out nocopy    number
          ,p_per_not_xtrctd     out nocopy    number
          ) is
--
  l_request_id         number;
  l_proc      varchar2(72) := g_package||'.get_per_statistics';
--
  cursor csr_get_per_xtrctd_rslt is
  SELECT count(distinct person_id)
  FROM   ben_ext_rslt_dtl
  WHERE  ext_rslt_id = p_ext_rslt_id
  AND    person_id not in (0, 999999999999);

--
  cursor csr_get_per_xtrctd_req is
  SELECT count(distinct person_id)
  FROM   ben_ext_rslt_dtl
  WHERE  ext_rslt_id = p_ext_rslt_id  --request_id = p_request_id
  AND    person_id not in (0, 999999999999);
--
  cursor csr_get_per_not_xtrctd_req is
  SELECT count(distinct person_id)
  FROM   ben_ext_rslt_err
  WHERE  ext_rslt_id = p_ext_rslt_id  --request_id = l_request_id
  AND    person_id not in (0, 999999999999)
  AND    typ_cd <> 'W';
--
  cursor csr_get_req_id is
  SELECT request_id
  FROM   ben_ext_rslt
  WHERE  ext_rslt_id = p_ext_rslt_id;
--
begin
--
  --
    hr_utility.set_location('Entering'||l_proc, 5);
  --
  if p_ext_rslt_id is null and p_request_id is null then
    p_per_xtrctd := 0;
    p_per_not_xtrctd := 0;
  elsif p_ext_rslt_id is not null and p_request_id is null then
    open csr_get_per_xtrctd_rslt;
    fetch csr_get_per_xtrctd_rslt into p_per_xtrctd;
    close csr_get_per_xtrctd_rslt;
--
    open csr_get_req_id;
    fetch csr_get_req_id into l_request_id;
    close csr_get_req_id;
--
    if l_request_id is null then
      p_per_not_xtrctd := 0;
    else
      open csr_get_per_not_xtrctd_req;
      fetch csr_get_per_not_xtrctd_req into p_per_not_xtrctd;
      close csr_get_per_not_xtrctd_req;
    end if;
--
  elsif p_ext_rslt_id is null and p_request_id is not null then
    open csr_get_per_xtrctd_req;
    fetch csr_get_per_xtrctd_req into p_per_xtrctd;
    close csr_get_per_xtrctd_req;
--
    l_request_id := p_request_id;
    open csr_get_per_not_xtrctd_req;
    fetch csr_get_per_not_xtrctd_req into p_per_not_xtrctd;
    close csr_get_per_not_xtrctd_req;
--
  elsif p_ext_rslt_id is not null and p_request_id is not null then
    open csr_get_req_id;
    fetch csr_get_req_id into l_request_id;
    close csr_get_req_id;
--
    if l_request_id <> p_request_id then
      p_per_xtrctd := 0;
      p_per_not_xtrctd := 0;
    else
      open csr_get_per_xtrctd_req;
      fetch csr_get_per_xtrctd_req into p_per_xtrctd;
      close csr_get_per_xtrctd_req;
--
      open csr_get_per_not_xtrctd_req;
      fetch csr_get_per_not_xtrctd_req into p_per_not_xtrctd;
      close csr_get_per_not_xtrctd_req;
    end if;
--
  end if;
  --
    hr_utility.set_location('Exiting'||l_proc, 15);
  --
end get_per_statistics;
--
--
-- This procedure will return total job failures, total errors,
-- total warnings corresponding to a ext_rslt_id or request_id or both.
-- If both ext_rslt_id and request_id are passed and if they do not correspond
-- to each other then 0, 0, 0 will be returned.
--
procedure get_err_warn_statistics
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_job_failure        out nocopy    number
          ,p_error              out nocopy    number
          ,p_warning            out nocopy    number
          ) is
--
  l_request_id         number;
--
  cursor csr_get_err_warn_stat_req is
  SELECT count(decode(typ_cd, 'F', typ_cd))
        ,count(decode(typ_cd, 'E', typ_cd))
        ,count(decode(typ_cd, 'W', typ_cd))
  FROM   ben_ext_rslt_err
  WHERE  ext_rslt_id = p_ext_rslt_id;   --request_id = l_request_id;
--
  cursor csr_get_req_id is
  SELECT request_id
  FROM   ben_ext_rslt
  WHERE  ext_rslt_id = p_ext_rslt_id;
--
  l_proc      varchar2(72) := g_package||'.get_err_warn_statistics';
--
begin
--
  --
    hr_utility.set_location('Entering'||l_proc, 5);
  --
  if p_ext_rslt_id is null and p_request_id is null then
    p_job_failure := 0;
    p_error := 0;
    p_warning := 0;
  elsif p_ext_rslt_id is not null and p_request_id is null then
    open csr_get_req_id;
    fetch csr_get_req_id into l_request_id;
    close csr_get_req_id;
--
    if l_request_id is null then
      p_job_failure := 0;
      p_error := 0;
      p_warning := 0;
    else
      open csr_get_err_warn_stat_req;
      fetch csr_get_err_warn_stat_req into p_job_failure
                                                ,p_error
                                                ,p_warning;
      close csr_get_err_warn_stat_req;
    end if;
--
  elsif p_ext_rslt_id is null and p_request_id is not null then
--
    l_request_id := p_request_id;
    open csr_get_err_warn_stat_req;
    fetch csr_get_err_warn_stat_req into p_job_failure
                                              ,p_error
                                              ,p_warning;
    close csr_get_err_warn_stat_req;
  elsif p_ext_rslt_id is not null and p_request_id is not null then
    open csr_get_req_id;
    fetch csr_get_req_id into l_request_id;
    close csr_get_req_id;
--
    if l_request_id <> p_request_id then
      p_job_failure := 0;
      p_error := 0;
      p_warning := 0;
    else
      open csr_get_err_warn_stat_req;
      fetch csr_get_err_warn_stat_req into p_job_failure
                                                ,p_error
                                                ,p_warning;
      close csr_get_err_warn_stat_req;
    end if;
--
  end if;
  --
    hr_utility.set_location('Exiting'||l_proc, 15);
  --
end get_err_warn_statistics;
--
--
-- This procedure will return a text containing the statistics of the extract
-- run.
--
procedure get_statistics_text
          (p_ext_rslt_id        in     number default null
          ,p_request_id         in     number default null
          ,p_text               out nocopy    varchar2
          ) is
--
  l_proc      varchar2(72) := g_package||'.get_statistics_text';
--
-- One DB hit for two lookup_type
--
  cursor get_prompt is
  SELECT decode(lookup_type, 'BEN_EXT_ERR_TYP',
                '1' || lookup_code,
                'BEN_EXT_PROMPT',
                '2' || lookup_code) lookup_code,
         meaning
  FROM hr_lookups
  WHERE lookup_type in ('BEN_EXT_ERR_TYP', 'BEN_EXT_PROMPT');
--
  Type lookup_rec_typ is Record
  (lookup_code     hr_lookups.lookup_code%type
  ,meaning         hr_lookups.meaning%type
  );
--
  Type lookup_tab_typ is table
  of lookup_rec_typ
  Index By Binary_Integer;
--
  l_lookup_tab      lookup_tab_typ;
--
  l_lookup_code     hr_lookups.lookup_code%type;
  l_meaning         hr_lookups.meaning%type;
  l_counter         integer := 0;
  l_text            varchar2(4000) := NULL;
  l_rec_tab         g_rec_nam_num_tab_typ;
  l_tot_rec         number := 0;
  l_tot_per         number := 0;
  l_tot_err         number := 0;
  l_per_xtrctd      number := 0;
  l_per_not_xtrctd  number := 0;
  l_job_failure     number := 0;
  l_error           number := 0;
  l_warning         number := 0;
  l_lengthb         number := 3880;    -- 4000 - line of japan
--
-- Private function can be called from this procedure only
--
  function get_index
           (p_array    in    lookup_tab_typ
           ,p_key      in    hr_lookups.lookup_code%type
           ) return binary_integer is
  begin
--
    for i in 1..p_array.count
    loop
      if p_array(i).lookup_code = p_key then
        return i;
      end if;
    end loop;
--
    return 0;
  end;
--
begin
--
  --
    hr_utility.set_location('Entering'||l_proc, 5);
  --
  open get_prompt;
  loop
    fetch get_prompt into l_lookup_code, l_meaning;
    exit when get_prompt%notfound;
    l_counter := l_counter + 1;
    l_lookup_tab(l_counter).lookup_code := l_lookup_code;
    l_lookup_tab(l_counter).meaning := l_meaning;
  end loop;
  close get_prompt;
--

  hr_utility.set_location('p_ext_rslt_id'||p_ext_rslt_id, 5);
  hr_utility.set_location('p_request_id'||p_request_id, 5);
  get_rec_nam_num(p_ext_rslt_id => p_ext_rslt_id
                 ,p_request_id => p_request_id
                 ,p_rec_tab => l_rec_tab
                 );
--
  if l_rec_tab.first = l_rec_tab.last
     and l_rec_tab(1).name is null
     and l_rec_tab(1).num = 0 then
    l_text := rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                  ,p_key => '2E')).meaning, 34) || ' ' || lpad('0', 6) || '   ';
  else
    for i in 1..l_rec_tab.count
    loop
      hr_utility.set_location ( l_rec_tab(i).name || '       ' || l_rec_tab(i).num , 60);
      l_tot_rec := l_tot_rec + l_rec_tab(i).num;
    end loop;
--
    l_text := rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                  ,p_key => '2E')).meaning, 34)
              || ' ' || lpad(to_char(l_tot_rec), 6) || '   ';
--
    for i in 1..l_rec_tab.count
    loop
      -- validate the lenght before joining ;

      if  lengthb(l_text || '-' || rpad(nvl(l_rec_tab(i).name, 'No Name'), 33)
              || ' ' || lpad(to_char(l_rec_tab(i).num), 6) || '   ' ) < l_lengthb then

           l_text := l_text || '-' || rpad(nvl(l_rec_tab(i).name, 'No Name'), 33)
              || ' ' || lpad(to_char(l_rec_tab(i).num), 6) || '   ';
      end if ;

    end loop;
  end if;
--
  l_text := l_text || '-----------------------------------------';
--
  get_per_statistics(p_ext_rslt_id => p_ext_rslt_id
                    ,p_request_id => p_request_id
                    ,p_per_xtrctd => l_per_xtrctd
                    ,p_per_not_xtrctd => l_per_not_xtrctd
                    );
  l_tot_per := l_per_xtrctd + l_per_not_xtrctd;
  -- we validate 120 character to make sure the unicode
  if lengthb(l_text) < l_lengthb then
      l_text := l_text || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                               ,p_key => '2P')).meaning
            , 34) || ' ' || lpad(to_char(l_tot_per), 6) || '   ';
  end if ;
--
  if l_per_xtrctd <> 0 then
    if lengthb(l_text) < l_lengthb then
       l_text := l_text || '-' || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                                   ,p_key => '2PE')).meaning ,33)
              || ' ' || lpad(to_char(l_per_xtrctd), 6) || '   ';
    end if ;
  end if;
  if l_per_not_xtrctd <> 0 then
    if lengthb(l_text) < l_lengthb then
       l_text := l_text || '-' || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                         ,p_key => '2PNE')).meaning ,33)
              || ' ' || lpad(to_char(l_per_not_xtrctd), 6) || '   ';
    end if ;
  end if;
--
  l_text := l_text || '-----------------------------------------';
--
  get_err_warn_statistics(p_ext_rslt_id => p_ext_rslt_id
                         ,p_request_id => p_request_id
                         ,p_job_failure => l_job_failure
                         ,p_error => l_error
                         ,p_warning => l_warning
                         );
--
  l_tot_err := l_job_failure + l_error + l_warning;
--
  if lengthb(l_text) < l_lengthb then
      l_text := l_text || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                               ,p_key => '2EW')).meaning
            , 34) || ' ' || lpad(to_char(l_tot_err), 6) || '   ';
  end if ;
--
  if l_job_failure <> 0 then
    if lengthb(l_text) < l_lengthb then
       l_text := l_text || '-' || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                    ,p_key => '1F')).meaning ,33)
              || ' ' || lpad(to_char(l_job_failure), 6) || '   ';
    end if ;
  end if;
  if l_error <> 0 then
    if lengthb(l_text) < l_lengthb then
       l_text := l_text || '-' || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                                   ,p_key => '1E')).meaning ,33)
              || ' ' || lpad(to_char(l_error), 6) || '   ';
    end if;
  end if;
  if l_warning <> 0 then
     if lengthb(l_text) < l_lengthb then
         l_text := l_text || '-' || rpad(l_lookup_tab(get_index(p_array => l_lookup_tab
                                             ,p_key => '1W')).meaning ,33)
              || ' ' || lpad(to_char(l_warning), 6) || '   ';
     end if ;
  end if;
-- Currently theform si nopt supporting more then 2000 cahr
-- if the l_text_more then 2000 , truncate
  if lengthb(l_text) > 2000 then
     l_text := substrb(l_text,1,2000) ;
  end if ;
  p_text := l_text;
--
  --
    hr_utility.set_location('Exiting'||l_proc, 15);
  --
end get_statistics_text;
-----------------------------------------------------------------------------------
----------------------------< Get_Value >------------------------------------------
-----------------------------------------------------------------------------------
Function get_value(p_ext_rcd_id       number,
                   p_ext_rslt_dtl_id  number,
                   p_seq_num          number)
RETURN varchar2 IS
--
  l_char_seq_num  varchar2(3);
  l_cid           integer;
  l_res           integer;
  l_string        varchar2(2000);
  l_value         varchar2(200);
  l_proc      varchar2(72) := g_package||'.get_value';
--
BEGIN
--
  --
    hr_utility.set_location('Entering'||l_proc, 5);
  --
  if p_seq_num < 10 then
    l_char_seq_num := '0' || to_char(p_seq_num);
  else
    l_char_seq_num := to_char(p_seq_num);
  end if;
--
  l_string := 'SELECT val_' || l_char_seq_num ||
              ' FROM ben_ext_rslt_dtl ' ||
              'WHERE ext_rslt_dtl_id = ' ||
              to_char(p_ext_rslt_dtl_id);
--
  l_cid := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cid, l_string, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(l_cid, 1, l_value, 200);
  l_res := DBMS_SQL.EXECUTE(l_cid);
  l_res := DBMS_SQL.FETCH_ROWS(l_cid);
  DBMS_SQL.COLUMN_VALUE(l_cid, 1, l_value);
--
  DBMS_SQL.CLOSE_CURSOR(l_cid);
--
  --
    hr_utility.set_location('Exiting'||l_proc, 5);
  --
  return(l_value);
--
END get_value;
--
-----------------------------------------------------------------------------------
--------------------------------< Get_chg_dates >----------------------------------
-----------------------------------------------------------------------------------
--
procedure get_chg_dates
          (p_ext_dfn_id       in number,
           p_effective_date   in date,
           p_chg_actl_strt_dt out nocopy date,
           p_chg_actl_end_dt  out nocopy date,
           p_chg_eff_strt_dt  out nocopy date,
           p_chg_eff_end_dt   out nocopy date) is
--
  cursor c_chg_actl_dt(p_ext_dfn_id in number) is
    select xcv.val_1, xcv.val_2, xct.excld_flag
    from ben_ext_crit_val xcv,
         ben_ext_crit_typ xct,
         ben_ext_dfn xdf
    where xdf.ext_dfn_id = p_ext_dfn_id
    and   xdf.ext_crit_prfl_id = xct.ext_crit_prfl_id
    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and   xct.crit_typ_cd = 'CAD'; -- change actual date
  l_chg_actl_dt c_chg_actl_dt%rowtype;

--
  cursor c_chg_eff_dt(p_ext_dfn_id in number) is
    select xcv.val_1, xcv.val_2, xct.excld_flag
    from ben_ext_crit_val xcv,
         ben_ext_crit_typ xct,
         ben_ext_dfn xdf
    where xdf.ext_dfn_id = p_ext_dfn_id
    and   xdf.ext_crit_prfl_id = xct.ext_crit_prfl_id
    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and   xct.crit_typ_cd = 'CED'; -- change effective date
  l_chg_eff_dt c_chg_eff_dt%rowtype;
--
  l_proc      varchar2(72) := g_package||'.get_chg_dates';
--
Begin
--
    hr_utility.set_location('Entering'||l_proc, 5);
--
-- Note about this logic:  If the exclude flag is on for these ranges,
-- then we will set the range from bot to eot, and let the evaluate
-- inclusion program handle it.
--
     open c_chg_actl_dt(p_ext_dfn_id);
       fetch c_chg_actl_dt into l_chg_actl_dt;
     close c_chg_actl_dt;
--
     if nvl(l_chg_actl_dt.excld_flag,'N') = 'Y' or l_chg_actl_dt.val_1 is null or
        l_chg_actl_dt.val_1 in ('CHAD','CHED') then
       p_chg_actl_strt_dt := hr_api.g_sot;
     else
       p_chg_actl_strt_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_chg_actl_dt.val_1,
                    p_abs_date    => p_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
     end if;

--
     if nvl(l_chg_actl_dt.excld_flag,'N') = 'Y' or l_chg_actl_dt.val_2 is null or
        l_chg_actl_dt.val_2 in ('CHAD','CHED'/*,'CTBSD','CESD','CLEOD','CDBLEOD'*/ ) then
       p_chg_actl_end_dt := hr_api.g_eot;
     else
       p_chg_actl_end_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_chg_actl_dt.val_2,
                    p_abs_date    => p_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
     end if;
--
     open c_chg_eff_dt(p_ext_dfn_id);
       fetch c_chg_eff_dt into l_chg_eff_dt;
     close c_chg_eff_dt;
--
     if nvl(l_chg_eff_dt.excld_flag,'N') = 'Y' or l_chg_eff_dt.val_1 is null  or
        l_chg_actl_dt.val_2 in ('CHAD','CHED'/*,'CTBSD','CESD','CLEOD','CDBLEOD'*/ ) then
       p_chg_eff_strt_dt := hr_api.g_sot;
     else
       p_chg_eff_strt_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_chg_eff_dt.val_1,
                    p_abs_date    => p_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
     end if;
--
     if nvl(l_chg_eff_dt.excld_flag,'N') = 'Y' or l_chg_eff_dt.val_2 is null or
        l_chg_actl_dt.val_2 in ('CHAD','CHED'/*,'CTBSD','CESD','CLEOD','CDBLEOD'*/ ) then
       p_chg_eff_end_dt := hr_api.g_eot;
     else
       p_chg_eff_end_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_chg_eff_dt.val_2,
                    p_abs_date    => p_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
     end if;
--
    hr_utility.set_location('chg  start date ' || p_chg_eff_strt_dt , 9185);
    hr_utility.set_location('chg  End date ' ||  p_chg_eff_end_dt , 9185);
    hr_utility.set_location('Exiting'||l_proc, 5);
--
End get_chg_dates;
--
-----------------------------------------------------------------------------------
--------------------------------< Get_cm_dates >----------------------------------
-----------------------------------------------------------------------------------
--
procedure get_cm_dates
          (p_ext_dfn_id       in number,
           p_effective_date   in date,
           p_to_be_sent_strt_dt out nocopy date,
           p_to_be_sent_end_dt  out nocopy date) is
--
  cursor c_to_be_sent_dt(p_ext_dfn_id in number) is
    select xcv.val_1, xcv.val_2, xct.excld_flag
    from ben_ext_crit_val xcv,
         ben_ext_crit_typ xct,
         ben_ext_dfn xdf
    where xdf.ext_dfn_id = p_ext_dfn_id
    and   xdf.ext_crit_prfl_id = xct.ext_crit_prfl_id
    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and   xct.crit_typ_cd = 'MTBSDT'; -- comm to be sent date
  l_to_be_sent_dt c_to_be_sent_dt%rowtype;

  l_proc      varchar2(72) := g_package||'.get_cm_dates';
--
Begin
--
    hr_utility.set_location('Entering'||l_proc, 5);
--
-- Note about this logic:  If the exclude flag is on for these ranges,
-- then we will set the range from bot to eot, and let the evaluate
-- inclusion program handle it.
--
     open c_to_be_sent_dt(p_ext_dfn_id);
       fetch c_to_be_sent_dt into l_to_be_sent_dt;
     close c_to_be_sent_dt;
--
     if nvl(l_to_be_sent_dt.excld_flag,'N') = 'Y' or l_to_be_sent_dt.val_1 is null then
       p_to_be_sent_strt_dt := hr_api.g_sot;
     else

    hr_utility.set_location(' 514 error cm '  , 514);
       p_to_be_sent_strt_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_to_be_sent_dt.val_1,
                    p_abs_date    => p_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
     end if;
--
     if nvl(l_to_be_sent_dt.excld_flag,'N') = 'Y' or l_to_be_sent_dt.val_2 is null then
       p_to_be_sent_end_dt := hr_api.g_eot;
     else
        hr_utility.set_location(' 514 error cmm '   , 514);
       p_to_be_sent_end_dt := ben_ext_util.calc_ext_date
                   (p_ext_date_cd => l_to_be_sent_dt.val_2,
                    p_abs_date    => p_effective_date,
                    p_ext_dfn_id => p_ext_dfn_id
                   );
     end if;
--
    hr_utility.set_location('cm  start date ' || p_to_be_sent_strt_dt , 9185);
    hr_utility.set_location('cm  End date ' || p_to_be_sent_end_dt , 9185);

    hr_utility.set_location('Exiting'||l_proc, 5);
--
End get_cm_dates;
--
-----------------------------------------------------------------------------------
--------------------------------< get_ext_dates >----------------------------------
-----------------------------------------------------------------------------------
--
--  Full profile extracts always use the Extract Effective Date for extracting
--  Datetrack and dated fields.  This is the date passed in Conc Mgr at runtime.
--  Communication Extracts use the effective date passed in
--  unless overriden via the
--  criteria profile Datetrack Override options.  Changes Only Extracts use The
--  effective date passed in unless overriden
--  via the criteria profile Datetrack Override options.
--  Also it is worth mentioning here that the user can extract person related
--  data as of one date, and benefits related data as of another.
--
procedure get_ext_dates
          (p_ext_dfn_id       in number,
           p_data_typ_cd      in varchar2,
           p_effective_date   in date,
           p_person_ext_dt out nocopy date,
           p_benefits_ext_dt out nocopy date) is
--
  /*
  cursor c_person_dt_cd(p_ext_dfn_id in number) is
    select xcv.val_1
    from ben_ext_crit_val xcv,
         ben_ext_crit_typ xct,
         ben_ext_dfn xdf
    where xdf.ext_dfn_id = p_ext_dfn_id
    and   xdf.ext_crit_prfl_id = xct.ext_crit_prfl_id
    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and   xct.crit_typ_cd = 'PASOR'; -- person datetrack override date
  */
  l_person_dt_cd ben_ext_crit_val.val_1%TYPE; -- UTF8 varchar2(30);
  l_person_dt date;
--
  /*
  cursor c_benefits_dt_cd(p_ext_dfn_id in number) is
    select xcv.val_1
    from ben_ext_crit_val xcv,
         ben_ext_crit_typ xct,
         ben_ext_dfn xdf
    where xdf.ext_dfn_id = p_ext_dfn_id
    and   xdf.ext_crit_prfl_id = xct.ext_crit_prfl_id
    and   xct.ext_crit_typ_id = xcv.ext_crit_typ_id
    and   xct.crit_typ_cd = 'BDTOR'; -- benefits datetrack override date
  */

  l_dummy  varchar2(1) ;
  l_benefits_dt_cd  ben_ext_crit_val.val_1%TYPE; -- UTF8 varchar2(30);
  l_benefits_dt date;
---
  cursor c_asg_exist is
        select 'x' from
        per_all_assignments_f
        where person_id = ben_ext_person.g_person_id
          and primary_flag = 'Y'
          and p_effective_Date between effective_start_date
          and effective_end_date ;


   cursor c_e_asg_exist is
        select 'x' from
        per_all_assignments_f
        where person_id = ben_ext_person.g_person_id
          and primary_flag = 'Y'
          and assignment_type = 'E'  -- added by hmani bug 3629576
          and p_effective_Date between effective_start_date
          and effective_end_date ;


  cursor c_A_asg_exist is
        select 'x' from
        per_all_assignments_f
        where person_id = ben_ext_person.g_person_id
          and assignment_type = 'A'  -- applicatn does not have any primary
          and p_effective_Date between effective_start_date
          and effective_end_date ;


  cursor c_asg_term is
        select  effective_end_date from
        per_all_assignments_f
        where person_id = ben_ext_person.g_person_id
          and primary_flag = 'Y'
          and assignment_type = 'E'  -- added by hmani bug 3629576
          and effective_start_date < p_effective_Date
          order by  effective_end_Date desc ;


  l_proc      varchar2(72) := g_package||'.get_ext_dates';
--
Begin
--
    hr_utility.set_location('Entering'||l_proc, 5);

--
    if ben_extract.g_pasor_dt_cd is not null then
       l_person_dt_cd :=  ben_extract.g_pasor_dt_cd ;
    end if ;

    hr_utility.set_location('pasor_dt_cd '||l_person_dt_cd, 5);
    hr_utility.set_location('effective date '||p_effective_date, 5);

    if l_person_dt_cd in ( 'TDRASG','TDPRASG')  then
       l_person_dt := p_effective_date;
       l_benefits_dt := p_effective_date;

       -- if employee exist dont do anything, else check for criteria
       open c_e_asg_exist ;
       fetch c_e_asg_exist into l_dummy ;
       if c_e_asg_exist%notfound then
          --- if there is no employee assignment get the termianted employee assignment
          if l_person_dt_cd = 'TDRASG' then
             open c_asg_term   ;
             fetch c_asg_term into l_person_dt ;
             close c_asg_term ;
             l_benefits_dt := l_person_dt ;
             hr_utility.set_location('terminated asg eff date'||l_person_dt, 5);
          end if ;
           -- if employee assignment not there
           -- check for any other primary asg , if not
           -- check for any applicant assg , if not
           -- check for ex employee asg
          if l_person_dt_cd = 'TDPRASG' then
              --- if any primary assignment exist
              open c_asg_exist  ;
              fetch c_asg_exist into l_dummy ;
              if c_asg_exist%notfound then

                 hr_utility.set_location(' pr asg not found  '||l_person_dt_cd , 6);
                 -- get applicant assignment
                 open c_a_asg_exist  ;
                 fetch c_a_asg_exist into l_dummy ;
                 if c_a_asg_exist%notfound then
                    -- get terminated assignment
                    open c_asg_term   ;
                    fetch c_asg_term into l_person_dt ;
                    close c_asg_term ;
                    l_benefits_dt := l_person_dt ;
                    hr_utility.set_location('termianted asg eff date '||l_person_dt, 7) ;
                 end if ;
                 close c_a_asg_exist ;
              end if ;
              close  c_asg_exist  ;
          end if ;
       end if ;
       close c_e_asg_exist;
    end if ;
    --- Change and communication specifc
    if p_data_typ_cd in ( 'C', 'CM') then

       if ben_extract.g_pasor_dt_cd is not null then
          l_person_dt_cd :=  ben_extract.g_pasor_dt_cd ;


          if l_person_dt_cd = 'CLEOD' then  -- life event occured
            l_person_dt := ben_ext_person.g_cm_lf_evt_ocrd_dt;
          elsif l_person_dt_cd = 'CDBLEOD' then  -- day before life event occured
            l_person_dt := ben_ext_person.g_cm_lf_evt_ocrd_dt - 1;
          elsif l_person_dt_cd = 'CESD' then  -- per_cm_f effective start date
            l_person_dt := ben_ext_person.g_cm_eff_dt;
          elsif l_person_dt_cd = 'CTBSD' then -- communication to be sent date
            l_person_dt := ben_ext_person.g_cm_to_be_sent_dt;
          elsif l_person_dt_cd = 'CHAD' then -- change actual date
            l_person_dt := ben_ext_person.g_chg_actl_dt;
          elsif l_person_dt_cd = 'CHED' then -- change effective date
            l_person_dt := ben_ext_person.g_chg_eff_dt;
          elsif l_person_dt_cd = 'TD' then -- today (conc mgr effective dt)
            l_person_dt := p_effective_date;
          end if;
       end if;   --found
       --l_benefits_dt := null;
       -- Benefit override code setup
       if ben_extract.g_bdtor_dt_cd is not null then
          l_benefits_dt_cd :=  ben_extract.g_bdtor_dt_cd ;

          if l_benefits_dt_cd = 'CLEOD' then  -- life event occured
            l_benefits_dt := ben_ext_person.g_cm_lf_evt_ocrd_dt;
          elsif l_benefits_dt_cd = 'CDBLEOD' then  -- day before life event occured
            l_benefits_dt := ben_ext_person.g_cm_lf_evt_ocrd_dt - 1;
          elsif l_benefits_dt_cd = 'CESD' then  -- per_cm_f effective start date
            l_benefits_dt := ben_ext_person.g_cm_eff_dt;
          elsif l_benefits_dt_cd = 'CTBSD' then -- communication to be sent date
            l_benefits_dt := ben_ext_person.g_cm_to_be_sent_dt;
          elsif l_benefits_dt_cd = 'CHAD' then -- change actual date
            l_benefits_dt := ben_ext_person.g_chg_actl_dt;
          elsif l_benefits_dt_cd = 'CHED' then -- change effective date
            l_benefits_dt := ben_ext_person.g_chg_eff_dt;
          elsif l_benefits_dt_cd = 'TD' then -- today (conc mgr effective dt)
            l_benefits_dt := p_effective_date;
          end if;
       end if;  --found
       --
    elsif p_data_typ_cd = 'CW' then

        if ben_extract.g_pasor_dt_cd is not null then
           l_person_dt_cd :=  ben_extract.g_pasor_dt_cd ;

           if l_person_dt_cd = 'CWBEDT' then  -- effective date
              l_person_dt := ben_ext_person.g_CWB_LE_DT;
           elsif l_person_dt_cd = 'CWBFDT' then  -- life evt ocrd dt
              l_person_dt := ben_ext_person.g_CWB_EFFECTIVE_DATE ;
           elsif l_person_dt_cd = 'TD' then -- today (conc mgr effective dt)
              l_person_dt := p_effective_date;
           end if;
        end if;   --found
        --- close c_person_dt_cd;
        -- apply defaults when not null;
        if l_person_dt is null then
           l_person_dt := p_effective_date;
        end if;
    end if;  --data type

    p_person_ext_dt := nvl(l_person_dt ,  p_effective_date );
    p_benefits_ext_dt := nvl(l_benefits_dt, p_effective_date);
    --
    hr_utility.set_location('l_person_dt_cd '||l_person_dt_cd||' / '||p_person_ext_dt , 5);
    hr_utility.set_location('l_benefits_dt_cd '||l_benefits_dt_cd||' / '|| p_benefits_ext_dt ,5);
    hr_utility.set_location('Exiting'||l_proc, 5);
    --
End get_ext_dates;
--
Function calc_ext_date(p_ext_date_cd   in varchar2,
                       p_abs_date      in date,
                       p_ext_dfn_id    in number,
                       p_pl_id            in number default null )
                       Return Date Is
--
  l_proc      varchar2(72) := g_package||'.calc_ext_date';
  l_rslt_dt   date := null;
--
  l_run_dt      date;
  l_eff_dt      date;
--
  cursor prior_ext_run_c is
  SELECT max(run_end_dt)
  FROM   ben_ext_rslt
  WHERE  ext_dfn_id = p_ext_dfn_id
  AND    ext_stat_cd IN ('S', 'E', 'A','W');
--
  cursor prior_ext_eff_c is
  SELECT max(eff_dt)
  FROM   ben_ext_rslt
  WHERE  ext_dfn_id = p_ext_dfn_id
  AND    ext_stat_cd IN ('S', 'E', 'A','W');
--
  cursor c_pln_yr is
  select start_date , end_date
  from ben_popl_yr_perd cpy ,
       ben_yr_perd yrp
  where
     cpy.yr_perd_id = yrp.yr_perd_id
     and cpy.pl_id = p_pl_id
     and p_abs_date
       between yrp.start_date and yrp.end_date  ;


  l_yr_strt_date   date ;
  l_yr_end_date    date ;

--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('date '||p_abs_date, 5);
--
-- User entered date
--
  if substr(p_ext_date_cd, 3, 1) IN ('-', '/') then
--
    l_rslt_dt := to_date(p_ext_date_cd, 'MM/DD/YYYY');
--
-- Y - Yesterday
--
  elsif p_ext_date_cd = 'Y' then
--
    l_rslt_dt := p_abs_date - 1;
--
-- TD - Today
--
  elsif p_ext_date_cd = 'TD' then
--
    l_rslt_dt := p_abs_date;
--
-- TM - Tomorrow
--
  elsif p_ext_date_cd = 'TM' then
--
    l_rslt_dt := p_abs_date + 1;
--
-- FDOCM - First Day Of Current Month
--
  elsif p_ext_date_cd = 'FDOCM' then
--
    l_rslt_dt := trunc(p_abs_date, 'month');
--
-- LDOCM - Last Day Of Current Month
--
  elsif p_ext_date_cd = 'LDOCM' then
--
    l_rslt_dt := last_day(p_abs_date);
--
-- FDOCY - First Day Of Current Year
--
  elsif p_ext_date_cd = 'FDOCY' then
--
    l_rslt_dt := trunc(p_abs_date, 'YYYY');
--
-- LDOCY - Last Day Of Current Year
--
  elsif p_ext_date_cd = 'LDOCY' then
--
    l_rslt_dt := trunc(add_months(p_abs_date, 12), 'YYYY') - 1;
--
-- FDOCW - First Day Of Current Week
--
  elsif p_ext_date_cd = 'FDOCW' then
--
    l_rslt_dt := trunc(p_abs_date, 'DAY');
--
-- LDOCW - Last Day Of Current Week
--
  elsif p_ext_date_cd = 'LDOCW' then
--
    l_rslt_dt := trunc(p_abs_date + 7, 'DAY') - 1;
--
-- FDOCQ - First Day Of Current Quarter
--
  elsif p_ext_date_cd = 'FDOCQ' then
--
    l_rslt_dt := trunc(p_abs_date, 'Q');
--
-- LDOCQ - Last Day Of Current Quarter
--
  elsif p_ext_date_cd = 'LDOCQ' then
--
    l_rslt_dt := trunc(add_months(p_abs_date, 3), 'Q') - 1;
--
-- FDOPY - First Day Of Previous Year
--
  elsif p_ext_date_cd = 'FDOPY' then
--
    l_rslt_dt := trunc((trunc(p_abs_date, 'YYYY') - 1), 'YYYY');
--
-- LDOPY - Last Day Of Previous Year
--
  elsif p_ext_date_cd = 'LDOPY' then
--
    l_rslt_dt := trunc(p_abs_date, 'YYYY') - 1;
--
-- FDOPM - First Day Of Previous Month
--
  elsif p_ext_date_cd = 'FDOPM' then
--
    l_rslt_dt := trunc((trunc(p_abs_date, 'month') - 1), 'month');
--



-- LDOPM - Last Day Of Previous Month
--
  elsif p_ext_date_cd = 'LDOPM' then
--
    l_rslt_dt := trunc(p_abs_date, 'month') - 1;

-- FD2OPM - First Day Of two  Previous Month
--
  elsif p_ext_date_cd = 'FDO2PM' then
--
    l_rslt_dt := trunc( add_months(p_abs_date, -2) , 'Month');
--
-- LDO2PM - Last Day Of Previous Month
--
  elsif p_ext_date_cd = 'LDO2PM' then
--
    l_rslt_dt :=   trunc( add_months(p_abs_date, -1) , 'Month')  - 1;
--
-- FDOPQ - First Day Of Previous Quarter
--
  elsif p_ext_date_cd = 'FDOPQ' then
--
    l_rslt_dt := trunc((trunc(p_abs_date, 'Q') - 1), 'Q');
--
-- LDOPQ - Last Day Of Previous Quarter
--
  elsif p_ext_date_cd = 'LDOPQ' then
--
    l_rslt_dt := trunc(p_abs_date, 'Q') - 1;
--
-- FDOPW - First Day Of Previous Week
--
  elsif p_ext_date_cd = 'FDOPW' then
--
    l_rslt_dt := trunc((trunc(p_abs_date, 'DAY') - 1), 'DAY');
--
-- LDOPW - Last Day Of Previous Week
--
  elsif p_ext_date_cd = 'LDOPW' then
--
    l_rslt_dt := trunc(p_abs_date, 'DAY') - 1;
--
-- FDONM - First Day Of Next Month
--
  elsif p_ext_date_cd = 'FDONM' then
--
    l_rslt_dt := trunc(add_months(p_abs_date, 1), 'month');
--
-- LDONM - Last Day Of Next Month
--
  elsif p_ext_date_cd = 'LDONM' then
--
    l_rslt_dt := last_day(trunc(add_months(p_abs_date, 1), 'month'));
--
-- FDOMAN - First Day Of Month After Next
--
  elsif p_ext_date_cd = 'FDOMAN' then
--
    l_rslt_dt := trunc(add_months(p_abs_date, 2), 'month');
--
-- LDOMAN - Last Day Of Month After Next
--
  elsif p_ext_date_cd = 'LDOMAN' then
--
    l_rslt_dt := last_day(trunc(add_months(p_abs_date, 2), 'month'));
--
-- BOT - Begginning of Time
--
  elsif p_ext_date_cd = 'BOT' then
--
    l_rslt_dt := to_date('01/01/0001', 'DD/MM/YYYY');
--
-- EOT - End of Time
--
  elsif p_ext_date_cd = 'EOT' then
--
    l_rslt_dt := to_date('31/12/4712', 'DD/MM/YYYY');
--
  elsif p_ext_date_cd = '18MA' then
--
    l_rslt_dt := trunc(add_months(p_abs_date, -18));
--
  elsif p_ext_date_cd IN ('CTBSD','CESD','CLEOD','CDBLEOD') then
--
    if ben_ext_person.g_cm_type_id is null then
       hr_utility.set_location(' 514 error '||  p_ext_date_cd   , 514);

      ben_ext_thread.g_err_num := 92451;
      ben_ext_thread.g_err_name := 'BEN_92451_EXT_INV_CM_DT';
      raise ben_ext_thread.g_job_failure_error;

    end if;

    if p_ext_date_cd = 'CTBSD' then --communication to be sent date

      if ben_ext_person.g_cm_to_be_sent_dt is null then

        ben_ext_thread.g_err_num := 92454;
        ben_ext_thread.g_err_name := 'BEN_92454_EXT_INV_TO_BE_SNT_DT';
        raise ben_ext_person.detail_error;

      else

       l_rslt_dt := trunc(ben_ext_person.g_cm_to_be_sent_dt);

      end if;

    elsif p_ext_date_cd = 'CESD' then -- communication effective start date

     l_rslt_dt := trunc(ben_ext_person.g_cm_eff_dt);

    elsif p_ext_date_cd = 'CLEOD' then -- communication life event occurred date

      if ben_ext_person.g_cm_lf_evt_ocrd_dt is null then

        ben_ext_thread.g_err_num := 92450;
        ben_ext_thread.g_err_name := 'BEN_92450_EXT_INV_LER_DT';
        raise ben_ext_person.detail_error;

      else

       l_rslt_dt := trunc(ben_ext_person.g_cm_lf_evt_ocrd_dt);

      end if;

    else -- CDBLEOD communication day before life event occured date

      if ben_ext_person.g_cm_lf_evt_ocrd_dt is null then

        ben_ext_thread.g_err_num := 92450;
        ben_ext_thread.g_err_name := 'BEN_92450_EXT_INV_LER_DT';
        raise ben_ext_person.detail_error;

      else

       l_rslt_dt := trunc(ben_ext_person.g_cm_lf_evt_ocrd_dt) - 1;

      end if;

    end if;
--
  elsif p_ext_date_cd = 'CHAD' then

      if ben_ext_person.g_chg_actl_dt is null then
         hr_utility.set_location(' 514 error 1' , 514);
        ben_ext_thread.g_err_num := 92455;
        ben_ext_thread.g_err_name := 'BEN_92455_EXT_INV_CHG_DT';
        raise ben_ext_thread.g_job_failure_error;

      else

       l_rslt_dt := trunc(ben_ext_person.g_chg_actl_dt);

      end if;
--
  elsif p_ext_date_cd = 'CHED' then

      if ben_ext_person.g_chg_eff_dt is null then

         hr_utility.set_location(' 514 error 2' , 514);
        ben_ext_thread.g_err_num := 92455;
        ben_ext_thread.g_err_name := 'BEN_92455_EXT_INV_CHG_DT';
        raise ben_ext_thread.g_job_failure_error;

      else

       l_rslt_dt := trunc(ben_ext_person.g_chg_eff_dt);

      end if;
--
-- day after last run date, day of last run date
  elsif p_ext_date_cd IN ('DARD', 'DORD','DBRD') then
--
    l_run_dt := null;
    open prior_ext_run_c;
    fetch prior_ext_run_c into l_run_dt;
    close prior_ext_run_c;
--
    if nvl(to_char(l_run_dt),'x') = 'x' then  -- this extract has never been run before
--
      l_rslt_dt := to_date('01/01/0001', 'DD/MM/YYYY');
--
    elsif p_ext_date_cd = 'DARD' then
--
      l_rslt_dt := trunc(l_run_dt+1);
--
    elsif p_ext_date_cd = 'DORD' then
--
      l_rslt_dt := trunc(l_run_dt);
--
    elsif p_ext_date_cd = 'DBRD' then
--
      l_rslt_dt := trunc(l_run_dt-1);

--
    end if;
--
-- day of last effective date, day after last effective date.
  elsif p_ext_date_cd IN ('DAED','DOED','DBED') then
--
    l_eff_dt := null;
    open prior_ext_eff_c;
    fetch prior_ext_eff_c into l_eff_dt;
    close prior_ext_eff_c;
--
    if nvl(to_char(l_eff_dt),'x') = 'x' then --it has never been run
--
      l_rslt_dt := to_date('01/01/0001', 'DD/MM/YYYY');
--
    elsif p_ext_date_cd = 'DAED' then
--
      l_rslt_dt := trunc(l_eff_dt+1);
--
    elsif p_ext_date_cd = 'DOED' then
--
      l_rslt_dt := trunc(l_eff_dt);
--
    elsif p_ext_date_cd = 'DBED' then
--
      l_rslt_dt := trunc(l_eff_dt-1);

--
    end if;


--  for bug  1409185 the folowing date code are added
--  The curent date deducted by the day No of current date and the requred  day no (sun -1,sat-7)
--  so that will get the date of the day in the current  week
-- if return date is current date or more then a  week (7) deducted from that so it will retunr to last
-- week.  0.99 used to find the maximum because the current date will return 0 and that is to be decutedw--  with 7 so .99 is validated
--
  elsif  p_ext_date_cd = 'PM' then
--       Perivious Monday
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -2)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -2),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;

  elsif  p_ext_date_cd = 'PT' then
--       Perious Tuesday
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -3)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -3),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'PW' then
--       Perivious Wednesday
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -4)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -4),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;

  elsif  p_ext_date_cd = 'PTH' then
--       Perivious THURSDAY
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -5)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -5),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;

  elsif  p_ext_date_cd = 'PF' then
--       Perivious FRIDAY
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -6)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -6),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;

  elsif  p_ext_date_cd = 'PSA' then
--       Perivious SATURDAY
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -7)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -7),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;

  elsif  p_ext_date_cd = 'PSU' then
--       Perivious SUNDAY
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -8)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -8),0.99) ,0.99,7,0))
           into l_rslt_dt  from dual ;
 --RCHASE - Bug 1550072 - Add new date calc codes
  -- tilak changed the sysdate to p_abs_date
     --added Next day - NM, NT, NW, NTH, NF, NSA, NSU
     --added Day of next week - MONW, TONW, WONW, THONW, FONW, SAONW, SUONW
     --added Day of current week - MOCW, TOCW, WOCW, THOCW, FOCW, SAOCW, SUOCW
     --added LPSME15RL, FPSMS1R16
     --added  LCSME15RL, FCSMS1R16
  elsif  p_ext_date_cd = 'NM' then
--       Next Monday
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -2)
               +decode(greatest(2-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
  elsif  p_ext_date_cd = 'NT' then
--       Next Tuesday
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -3)
               +decode(greatest(3-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
  elsif  p_ext_date_cd = 'NW' then
--       Next Wednesday
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -4)
               +decode(greatest(4-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
  elsif  p_ext_date_cd = 'NTH' then
--       Next THURSDAY
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -5)
               +decode(greatest(5-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
  elsif  p_ext_date_cd = 'NF' then
--       Next FRIDAY
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -6)
               +decode(greatest(6-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
  elsif  p_ext_date_cd = 'NSA' then
--       Next SATURDAY
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -7)
               +decode(greatest(7-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
  elsif  p_ext_date_cd = 'NSU' then
--       Next SUNDAY
         select trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -1)
               +decode(greatest(1-(to_number(to_char(p_abs_date,'D'))),0.99) ,0.99,7,0))
                into l_rslt_dt from dual;
 elsif p_ext_date_cd = 'MONW' then
--      Monday of next week
     l_rslt_dt := trunc(p_abs_date+(2 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'TONW' then
--      Tuesday of next week
     l_rslt_dt := trunc(p_abs_date+(3 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'WONW' then
--      Wednesday of next week
     l_rslt_dt := trunc(p_abs_date+(4 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'THONW' then
--      Thursday of next week
     l_rslt_dt := trunc(p_abs_date+(5 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'FONW' then
--      Friday of next week
     l_rslt_dt := trunc(p_abs_date+(6 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'SAONW' then
--      Saturday of next week
     l_rslt_dt := trunc(p_abs_date+(7 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'SUONW' then
--      Sunday of next week
     l_rslt_dt := trunc(p_abs_date+(1 -to_number(to_char(p_abs_date,'D'))+7));
  elsif p_ext_date_cd = 'MOCW' then
--      Monday of Current Week
     l_rslt_dt := trunc(p_abs_date+(2-to_number(to_char(p_abs_date,'D'))));
  elsif p_ext_date_cd = 'TOCW' then
--      Tuesday of Current Week
     l_rslt_dt := trunc(p_abs_date+(3-to_number(to_char(p_abs_date,'D'))));
  elsif p_ext_date_cd = 'WOCW' then
--      Wednesday of Current Week
     l_rslt_dt := trunc(p_abs_date+(4-to_number(to_char(p_abs_date,'D'))));
  elsif p_ext_date_cd = 'THOCW' then
--      Thursday of Current Week
     l_rslt_dt := trunc(p_abs_date+(5-to_number(to_char(p_abs_date,'D'))));
  elsif p_ext_date_cd = 'FOCW' then
--      Friday of Current Week
     l_rslt_dt := trunc(p_abs_date+(6-to_number(to_char(p_abs_date,'D'))));
  elsif p_ext_date_cd = 'SAOCW' then
--      Saturday of Current Week
     l_rslt_dt := trunc(p_abs_date+(7-to_number(to_char(p_abs_date,'D'))));
  elsif p_ext_date_cd = 'SUOCW' then
--      Sunday of Current Week
     l_rslt_dt := trunc(p_abs_date+(1-to_number(to_char(p_abs_date,'D'))));
  elsif  p_ext_date_cd = 'CM15' then
--      15th of current month
       l_rslt_dt := trunc(p_abs_date,'MM')+14;
 elsif  p_ext_date_cd = 'PM15' then
-- 15 of Previous Month
        l_rslt_dt := trunc(add_months(p_abs_date,-1),'MM')+14;
  elsif  p_ext_date_cd = 'NM15' then
--      15th of next month
        l_rslt_dt := add_months(trunc(p_abs_date,'MM')+14,1);
  elsif p_ext_date_cd = 'FPSMS1R16' then
--      First of Prior Semi Month Starting 1st or 16th of Month (Previous 1st or 16th of Month)
--      Tilak :is should go to the previous semi period and pick up the firs date of the  period
--      for eg. if i ma in 1 of mar , the perious sem period is feb 16-29  so retunr feb 16
--      if i am on feb 29 the perious period is feb 1-  15       o return feb 1
     select trunc(trunc(p_abs_date-15,'MM')
              +decode(greatest(to_number(to_char(p_abs_date,'DD')),15.9) , 15.9 , 15,0 )
            )
       into l_rslt_dt from dual;

  elsif p_ext_date_cd = 'FCSMS1R16' then
--      First of current Semi Month Starting 1st or 16th of Month
--      Tilak :is should go to the current semi period and pick up the firs date of the  period
     select trunc(trunc(p_abs_date,'MM')
              +decode(greatest(to_number(to_char(p_abs_date,'DD')),15.9) , 15.9 , 0,15 )
            )
       into l_rslt_dt from dual;

   elsif p_ext_date_cd = 'LPSME15RL' then
--      Last of Prior Semi Month Ending 15th or Last of Month (Previous 15th or Last Day of Month)
--      like FPSMS1R16 it has to pikcup the last date of the previous semi month
     select trunc(p_abs_date,'MM')+decode(greatest(to_number(to_char(p_abs_date,'DD')),15),15, -1, 14)
       into l_rslt_dt from dual;

   elsif p_ext_date_cd = 'LCSME15RL' then
--      Last of current Semi Month Ending 15th or Last of Month
--      like FCSMS1R16 it has to pikcup the last date of the previous semi month
        select   decode(greatest(to_number(to_char(p_abs_date,'DD')),15),15,
           trunc(p_abs_date,'MM') +14 , trunc(add_months(p_abs_date,1),'MM') -1)
           into l_rslt_dt from dual;


  elsif  p_ext_date_cd = 'CM16' then
--      16th of current month
        l_rslt_dt := trunc(trunc(p_abs_date,'MM')+15);
  elsif  p_ext_date_cd = 'PM16' then
--      16th of previous month
        l_rslt_dt := trunc(add_months(trunc(p_abs_date,'MM')+15,-1));
  elsif  p_ext_date_cd = 'NM16' then
--      16th of next month
        l_rslt_dt := trunc(add_months(trunc(p_abs_date,'MM')+15,1));


  elsif  p_ext_date_cd = 'MOPW' then
--       Perivious monday previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -2)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -2),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'TOPW' then
--       Perivious TUE previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -3)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -3),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'WOPW' then
--       Perivious wednesday previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -4)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -4),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'THOPW' then
--       Perivious thursday of previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -5)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -5),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'FOPW' then
--       Perivious friday of previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -6)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -6),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'SAOPW' then
--       Perivious saturday of previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -7)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -7),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;
  elsif  p_ext_date_cd = 'SUOPW' then
--       Perivious sunday of previous
         select  trunc(p_abs_date-(to_number(to_char((p_abs_date),'D')) -1)
           -decode(greatest((to_number(to_char(p_abs_date,'D')) -1),0.99) ,0.99,14,7))
           into l_rslt_dt  from dual ;

  elsif  p_ext_date_cd = 'CM16' then
--      16th of current month
        l_rslt_dt := trunc(trunc(p_abs_date,'MM')+15);
  elsif  p_ext_date_cd = 'PM16' then
--      16th of previous month
        l_rslt_dt := trunc(add_months(trunc(p_abs_date,'MM')+15,-1));
  elsif  p_ext_date_cd = 'NM16' then
--      16th of next month
        l_rslt_dt := trunc(add_months(trunc(p_abs_date,'MM')+15,1));

  elsif  p_ext_date_cd = 'PYSCYSDT' then
-- 	Plan Year Start date or Calendar Year Start date
         open c_pln_yr ;
         fetch c_pln_yr into
               l_yr_strt_date,
               l_yr_end_date ;
         close  c_pln_yr ;

         if l_yr_strt_date is not null then
             l_rslt_dt := l_yr_strt_date;
             hr_utility.set_location ( ' plan year start date ' , 99 );
         else
            l_rslt_dt := trunc(p_abs_date, 'YYYY');
         end if ;

  elsif  p_ext_date_cd = 'PYECYEDT' then
 --      Plan Year End date or Calendar Year End date
         open  c_pln_yr ;
         fetch c_pln_yr into
               l_yr_strt_date,
               l_yr_end_date ;
         close  c_pln_yr ;

         if l_yr_end_date is not null then
             l_rslt_dt := l_yr_end_date;
             hr_utility.set_location ( ' plan year End  date ' , 99 );
         else
            l_rslt_dt := trunc(add_months(p_abs_date, 12), 'YYYY') - 1 ;
         end if ;


  else
--
      ben_ext_thread.g_err_num := 91628;
      ben_ext_thread.g_err_name := 'BEN_91628_LOOKUP_TYPE_GENERIC';
      raise ben_ext_thread.g_job_failure_error;
--
  end if;
--

  hr_utility.set_location(' ext_date : '||p_ext_date_cd ||l_rslt_dt, 185);
  hr_utility.set_location(' Exiting:'||l_proc, 15);

  return (l_rslt_dt);
--

--
--
End calc_ext_date;
--
  /*---------------------------------------------------------------/
    ==========================================================
    --- Descriptio: This function returns a collection of cartesian
    ---             product of element_entry_id and datetracked_event_id
    ---
    --- ***********Algorithm************************
    ---       procedure get_element_entries_for_eg
    ---
    ---       for each element_set_id attahced to the event group
    ---               fetch all the element_entry_id X dte_id combinations
    ---
    ---               IF there are any purge dte on eg
    ---                       fetch the ele_entry_id X dte_id
    ---                               (using noted_value which is
    ---                               element_type_id of deleted ele entries
    ---                               surrogate_key will be element_entry_id)
    ---               End if;
    ---
    ---               combine with the above creatd collection checking for uniqueness
    ---
    ---               return the collection
    ---       end loop;
    ---
    ==========================================================
 */

 FUNCTION get_element_entries_for_eg
          (p_event_group_id           IN      NUMBER
          ,p_assignment_id            IN      NUMBER
          ,p_start_date               IN      DATE
          ,p_end_date                 IN      DATE
          ,p_element_entries_tab     OUT NOCOPY  g_r_element_entries
         ) RETURN NUMBER -- number of element entries in the out param table
 IS
   l_proc  VARCHAR2(70)  :=  g_package||'.get_element_entries_for_eg';
   l_purge_dte_id        NUMBER;
   l_purge_ee_ids        t_number;
   l_dte_ids             t_number;
   l_next                NUMBER;
   l_element_entries_tab t_number;
   l_dte_ids_tab         t_number;
   l_global_env_collection g_r_element_entries;
   l_element_set_ids_tab t_number;
   l_index               NUMBER;
   l_match_exists        VARCHAR2(10);


   CURSOR csr_element_entries
          (p_element_set_id   IN      NUMBER
          ,p_event_group_id   IN      NUMBER
          ,p_assignment_id    IN      NUMBER
          ,p_start_date       IN      DATE
          ,p_end_date         IN      DATE
          )
   IS
   SELECT  distinct pee.element_entry_id
     FROM  pay_element_type_rules petr
          ,pay_element_entries_f pee
     WHERE petr.element_set_id = p_element_set_id
       AND pee.element_type_id = petr.element_type_id
       AND pee.assignment_id = p_assignment_id
       AND (
            pee.effective_start_date <= p_end_date
           AND
            pee.effective_end_date >= p_start_date
          );

   -- this is used to check for any datetracked events for purge events on
   --  element entries in the event group.
   CURSOR csr_get_purge_events_on_eg
   IS
   SELECT datetracked_event_id
     FROM pay_datetracked_events pde
         ,pay_dated_tables pdt
     WHERE event_group_id = p_event_group_id
       AND pde.dated_table_id = pdt.dated_table_id
       AND pde.update_type = 'P'
       AND pdt.table_name = 'PAY_ELEMENT_ENTRIES_F';


   -- this is used to fetch the element entry ids of the
   --  puged element entries.
   -- the element tntry ids are fetched by comparing the
   --   element type id in the element set attached to the
   --   event group and the element type id stored in the
   --   column 'NOTED_VALUE' of pay_process_events fro purged
   --   element entry events.
   CURSOR csr_get_purged_ee_ids (p_element_set_id IN NUMBER)
   IS
   SELECT  distinct ppe.surrogate_key
     FROM  pay_element_type_rules petr
          ,pay_process_events ppe
          ,pay_event_updates peu
     WHERE petr.element_set_id = p_element_set_id
       AND ppe.assignment_id    = p_assignment_id
       AND ppe.noted_value      = petr.element_type_id
       AND peu.event_update_id = ppe.event_update_id
       AND peu.event_type = 'ZAP'
       AND ppe.effective_date BETWEEN p_start_date AND p_end_date;


 BEGIN
   hr_utility.trace('Entering: '||l_proc);
   hr_utility.trace('Entered get_element_entries_for_eg: EG_Id:'||to_char(p_event_group_id));
   hr_utility.trace('Assignment Id:'||to_char(p_assignment_id));
   hr_utility.trace('Start Date:'||to_char(p_start_date, 'DD/MM/YYYY'));
   hr_utility.trace('End Date:'||to_char(p_end_date, 'DD/MM/YYYY'));

   p_element_entries_tab.element_entry_id.DELETE;
   p_element_entries_tab.datetracked_event_id.DELETE;

   --- get the ids from cache
   IF g_eg_has_purge_dte.EXISTS(p_event_group_id) THEN
      hr_utility.trace('Obtained the value from cache: '||g_eg_has_purge_dte(p_event_group_id));
      l_purge_dte_id  :=  g_eg_has_purge_dte(p_event_group_id);
   END IF;


   -- get the element set ids attached to the event group
   IF g_ele_set_ids_on_eg.EXISTS(p_event_group_id) THEN
      -- found ion the cache
      hr_utility.trace('Obtained element set ids from cache');
      l_element_set_ids_tab :=  g_ele_set_ids_on_eg(p_event_group_id);
   END IF;

   -- get the dte ids of the current event group
   IF g_datetraced_event_ids.EXISTS(p_event_group_id) THEN
      -- found ion the cache
      hr_utility.trace('Obtained element set ids from cache');
      l_dte_ids_tab :=  g_datetraced_event_ids(p_event_group_id);
   END IF;
   ---

   FOR i IN 1..l_element_set_ids_tab.COUNT LOOP
       OPEN csr_element_entries
                 (p_element_set_id   => l_element_set_ids_tab(i)
                  ,p_event_group_id   => p_event_group_id
                  ,p_assignment_id    => p_assignment_id
                  ,p_start_date       => p_start_date
                  ,p_end_date         => p_end_date
                  );
       -- nullify the collection
       l_element_entries_tab.delete ;
       --
       FETCH csr_element_entries BULK COLLECT INTO l_element_entries_tab;
       CLOSE csr_element_entries;
       hr_utility.trace('Count:'||to_char(l_element_entries_tab.COUNT));

       -- prepare l_global_env_collection with the ee_ids and dte_ids collections
       FOR i IN 1 .. l_dte_ids_tab.count
       LOOP

          FOR j IN 1 ..l_element_entries_tab.count
          LOOP

              l_next  :=  nvl(l_global_env_collection.element_entry_id.LAST,0) + 1;

              l_global_env_collection.element_entry_id(l_next)
                       :=  l_element_entries_tab(j);
              l_global_env_collection.datetracked_event_id(l_next)
                       :=  l_dte_ids_tab(i);

          END LOOP; -- end j loop

       END LOOP; -- end i loop



       IF nvl(l_purge_dte_id,-1) <> -1 THEN
          -- if there are purge events in the event group
          hr_utility.trace('There are puge events on element entries table in the eg.');
          OPEN csr_get_purged_ee_ids(l_element_set_ids_tab(i));
          FETCH csr_get_purged_ee_ids BULK COLLECT INTO l_purge_ee_ids;
          CLOSE csr_get_purged_ee_ids;

          hr_utility.trace('Fill the values in the element entries collection.');
          FOR i IN 1..l_purge_ee_ids.COUNT
          LOOP
              hr_utility.trace('l_purge_ee_ids(i): '||l_purge_ee_ids(i));
              -- bug fix 5368066. nvl is added for this bug fix.
              l_next  :=  nvl(l_global_env_collection.element_entry_id.LAST,0) + 1;
              l_global_env_collection.element_entry_id(l_next)  :=  fnd_number.canonical_to_number(l_purge_ee_ids(i));
              l_global_env_collection.datetracked_event_id(l_next)  :=  l_purge_dte_id;
          END LOOP;
       END IF;

       FOR i IN 1..l_global_env_collection.element_entry_id.COUNT LOOP
           IF p_element_entries_tab.element_entry_id.COUNT = 0 THEN
              p_element_entries_tab := l_global_env_collection;
              EXIT;
           ELSE -- count is non zero
              l_index := p_element_entries_tab.element_entry_id.LAST;
              l_match_exists := 'N';
              FOR j IN 1..p_element_entries_tab.element_entry_id.COUNT LOOP
                  IF p_element_entries_tab.element_entry_id(j) = l_global_env_collection.element_entry_id(i) AND
                     p_element_entries_tab.datetracked_event_id(j) = l_global_env_collection.datetracked_event_id(i)
                  THEN
                    -- Combination exist so do nothing
                    l_match_exists := 'Y';
                    EXIT;
                  END IF; -- End if of match exists check ...
              END LOOP; -- j loop
              IF l_match_exists = 'N' THEN
                 -- store the information
                 l_index := l_index + 1;
                 p_element_entries_tab.element_entry_id(l_index) := l_global_env_collection.element_entry_id(i);
                 p_element_entries_tab.datetracked_event_id(l_index) := l_global_env_collection.datetracked_event_id(i);
              END IF; -- End if of match does not exist ...
           END IF; -- End if of return collection count is zero check ...
        END LOOP; -- i loop

    END LOOP; -- element set loop ...

    hr_utility.trace('Count:'||to_char(p_element_entries_tab.element_entry_id.COUNT));

    hr_utility.trace('Leaving: '||l_proc);
    RETURN p_element_entries_tab.element_entry_id.COUNT;

 EXCEPTION
   WHEN OTHERS THEN
     -- NOCOPY
     p_element_entries_tab.element_entry_id.DELETE;
     p_element_entries_tab.datetracked_event_id.DELETE;
     RAISE;
 END get_element_entries_for_eg;


 /*
    ==========================================================
    --- Description: This procedure is used to
    ---     1. Check if there are any element entry related
    ---         datetracekd events on the event group.
    ---     2. If there any such datetracked events
    ---         a) set a flag in the global g_t_event_element
    ---            and return the value.
    ---         b) set the event group level globals:
    ---               . g_ele_set_ids_on_eg
    ---               . g_datetraced_event_ids
    ---               . g_eg_has_purge_dte
    ==========================================================
 */
 Function event_element_exists(p_event_group_id IN  NUMBER
                              ) return varchar2 is
   l_return varchar2(1) ;
   l_proc    VARCHAR2(70);

   CURSOR csr_chk_eg_for_ee_tab IS
   SELECT 'Y'
   FROM pay_datetracked_events pde
     ,pay_dated_tables pdt
   WHERE event_group_id = p_event_group_id
     AND pde.dated_table_id = pdt.dated_table_id
     AND (pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
        OR
        pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
       )
     AND ROWNUM < 2;


    CURSOR csr_get_element_set IS
    SELECT element_set_id
    FROM pay_event_group_usages
    WHERE event_group_id = p_event_group_id;

    CURSOR csr_get_dte_ids IS
    SELECT datetracked_event_id
    FROM pay_datetracked_events pde
    WHERE pde.event_group_id = p_event_group_id;


    CURSOR csr_get_purge_events_ids IS
    SELECT datetracked_event_id
    FROM pay_datetracked_events pde
        ,pay_dated_tables pdt
    WHERE event_group_id = p_event_group_id
      AND pde.dated_table_id = pdt.dated_table_id
      AND pde.update_type = 'P'
      AND pdt.table_name = 'PAY_ELEMENT_ENTRIES_F';



    l_element_set_ids_tab t_number;
    l_dte_ids_tab         t_number;
    l_purge_dte_id        number;

 Begin
   l_proc   :=  g_package||'.event_element_exists';
   l_return := 'N' ;
   hr_utility.set_location('Entering'||l_proc, 5);

   -- for every person the event are executed
   -- instead of getting the value from cursor
   -- the values are cached so one event executes once for a theread

   if g_t_event_element.EXISTS(p_event_group_id)  then
      l_return := g_t_event_element(p_event_group_id) ;
   else
      open csr_chk_eg_for_ee_tab ;
      fetch csr_chk_eg_for_ee_tab into l_return ;
      if csr_chk_eg_for_ee_tab%notfound  then
         l_return := 'N' ;
      end if ;
      close csr_chk_eg_for_ee_tab ;
      g_t_event_element(p_event_group_id) := l_return ;

      -- when the element exists
      if l_return = 'Y' then

         hr_utility.trace('element set ids in cache');
         OPEN csr_get_element_set ;
         FETCH csr_get_element_set BULK COLLECT INTO l_element_set_ids_tab;
         CLOSE csr_get_element_set;

         --put the element set ids in the cache

         g_ele_set_ids_on_eg(p_event_group_id) :=  l_element_set_ids_tab;
         hr_utility.trace('Count:'||to_char(l_element_set_ids_tab.COUNT));

         hr_utility.trace('date treac event ids in cache');
         OPEN csr_get_dte_ids ;
         FETCH csr_get_dte_ids BULK COLLECT INTO l_dte_ids_tab;
         CLOSE csr_get_dte_ids;
         --put the element set ids in the cache
         g_datetraced_event_ids(p_event_group_id) :=  l_dte_ids_tab;


         hr_utility.trace('date treack purge event ids in cache');
         OPEN csr_get_purge_events_ids;
         FETCH csr_get_purge_events_ids into l_purge_dte_id;
         CLOSE csr_get_purge_events_ids;
         g_eg_has_purge_dte(p_event_group_id)  :=  nvl(l_purge_dte_id,-1);


      end if ;
   end if ;

   hr_utility.set_location('Exiting '|| l_return ||l_proc, 10);
   Return l_return ;

 End event_element_exists ;

 /*
    ==========================================================
    --- Description: This is a wrapper procedure on pay_interpreter_pkg.entries_affected
    ---     pay_interpreter_pkg.entry_affected.
    ---   Depending upon the elements entries on the assignment
    ---     which are of type of elements which are attached to
    ---     the element set which are attached to the event group
    ---     usages, this procedure calls entries_affected or entry_affected
    ---     and returns the table of events for the event group during the
    ---     date range specified
    ---
    --- ***********Algorithm************************
    --- procedure entries_affected
    ---
    --- Check the event group for datetracked events on element entries
    ---
    --- IF there are DTE on element entries THEN
    ---         get ee_id X de_id from get_element_entries_for_eg;
    ---         populate global_env using the above collection
    ---         call entreis_affected using global_env
    --- ELSE
    ---         call entry_affected (normal procedure)
    --- END;
    ---
    ==========================================================
 */
 PROCEDURE entries_affected
                      (p_assignment_id          IN  NUMBER DEFAULT NULL
                      ,p_event_group_id         IN  NUMBER DEFAULT NULL
                      ,p_mode                   IN  VARCHAR2 DEFAULT NULL
                      ,p_start_date             IN  DATE  DEFAULT hr_api.g_sot
                      ,p_end_date               IN  DATE  DEFAULT hr_api.g_eot
                      ,p_business_group_id      IN  NUMBER
                      ,p_detailed_output        OUT NOCOPY  pay_interpreter_pkg.t_detailed_output_table_type
                      ,p_process_mode           IN  VARCHAR2 DEFAULT 'ENTRY_CREATION_DATE'
                      ,p_penserv_mode           IN  VARCHAR2 DEFAULT 'N'    --vkodedal changes for penserver - 30-apr-2008
                      )
 IS

   l_proc                VARCHAR2(70)  :=  g_package||'.entries_affected';
   l_datetrack_ee_tab    g_r_element_entries;
   l_count               NUMBER := 0;
   l_global_env          pay_interpreter_pkg.t_global_env_rec;
   l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
   l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
   l_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;
   l_eg_has_ee_tab       VARCHAR2(1);


 BEGIN --entries_effected
    hr_utility.trace('Entering: '||l_proc);
    hr_utility.trace('Get the element entries for the assignment id');

    -- Bugfix 4739067: Performance enhancement
    -- Checking if the event group has element entries or
    -- element entry values table before trying to fetch events
    -- If the EG does not have EE tables, we use the entry_affected call
    -- further the cursor cached to get a better performance

    IF event_element_exists(p_event_group_id)  = 'Y' THEN
       l_count   :=  get_element_entries_for_eg
                          (p_event_group_id          =>   p_event_group_id
                          ,p_assignment_id           =>   p_assignment_id
                          ,p_start_date              =>   p_start_date
                          ,p_end_date                =>   p_end_date
                          ,p_element_entries_tab     =>   l_datetrack_ee_tab
                          );
    ELSE
       l_count := 0;
    END IF;

    -----
    -- This line can be removed after fix from pay for missing events on mix of calls to
    --    entry_affected and entries_affected - kkarri
    pay_interpreter_pkg.t_distinct_tab   :=  pay_interpreter_pkg.glo_monitored_events;
    -----
    IF l_count > 0 THEN
       hr_utility.trace('Our procedure');
       hr_utility.trace('Setup the global area');
       pay_interpreter_pkg.initialise_global(l_global_env);
       pay_interpreter_pkg.event_group_tables
                             (p_event_group_id =>  p_event_group_id
                             ,p_distinct_tab  =>  pay_interpreter_pkg.glo_monitored_events
                             );
       --The start and end pointers can be just for the event group.
       --    So, commenting out these lines. - kkarri
       /*l_global_env.monitor_start_ptr    := 1;
       l_global_env.monitor_end_ptr      := pay_interpreter_pkg.glo_monitored_events.count;*/
       l_global_env.monitor_start_ptr
                    := pay_interpreter_pkg.t_proration_group_tab(p_event_group_id).range_start;
       l_global_env.monitor_end_ptr
                    := pay_interpreter_pkg.t_proration_group_tab(p_event_group_id).range_end;
       ---
       l_global_env.datetrack_ee_tab_use := TRUE;
       l_global_env.validate_run_actions := FALSE;
       hr_utility.trace(' call add_datetrack_event_to_entry for collection ');

       FOR i IN l_datetrack_ee_tab.element_entry_id.FIRST..l_datetrack_ee_tab.element_entry_id.LAST
       LOOP
           hr_utility.trace('----------------------------------');
           hr_utility.trace('i: '||i);
           hr_utility.trace('datetracked_event_id: '||l_datetrack_ee_tab.datetracked_event_id(i));
           hr_utility.trace('element_entry_id: '||l_datetrack_ee_tab.element_entry_id(i));
           pay_interpreter_pkg.add_datetrack_event_to_entry
                         (p_datetracked_evt_id  =>   l_datetrack_ee_tab.datetracked_event_id(i)
                          ,p_element_entry_id   =>   l_datetrack_ee_tab.element_entry_id(i)
                          ,p_global_env         =>   l_global_env
                          );
      END LOOP;
      hr_utility.trace('Entered all the dte_id X ee_ids');

      BEGIN
         --call entries_effected
         hr_utility.trace('element call to entries_effected');
         pay_interpreter_pkg.entries_affected
                                  (p_assignment_id         =>   p_assignment_id
                                  ,p_mode                  =>   p_mode
                                  ,p_start_date            =>   p_start_date
                                  ,p_end_date              =>   p_end_date
                                  ,p_business_group_id     =>   p_business_group_id
                                  ,p_global_env            =>   l_global_env
                                  ,t_detailed_output       =>   p_detailed_output
                                  ,p_process_mode          =>   p_process_mode
                                  ,p_penserv_mode           =>   p_penserv_mode    --vkodedal changes for penserver - 30-apr-2008
                                  );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           hr_utility.trace('No payroll run for the assignment');
           hr_utility.set_message(8303,'BEN_94629_NO_ASG_ACTION_ID');
           hr_utility.raise_error;
      END;
      -- reset l_global_env
      pay_interpreter_pkg.clear_dt_event_for_entry
              (p_global_env         => l_global_env);
   ELSE
      hr_utility.trace('Normal call to entries_effected');
      --call entry_affected
      pay_interpreter_pkg.entry_affected(
                             p_element_entry_id      => NULL
                            ,p_assignment_action_id  => NULL
                            ,p_assignment_id         => p_assignment_id
                            ,p_mode                  => p_mode
                            ,p_process               => NULL -- 'U' --
                            ,p_event_group_id        => p_event_group_id
                            ,p_process_mode          => p_process_mode
                            ,p_start_date            => p_start_date
                            ,p_end_date              => p_end_date
                            ,t_detailed_output       => p_detailed_output  -- OUT
                            ,t_proration_dates       => l_proration_dates  -- OUT
                            ,t_proration_change_type => l_proration_changes  -- OUT
                            ,t_proration_type        => l_pro_type_tab -- OUT
                            ,p_penserv_mode          =>   p_penserv_mode    --vkodedal changes for penserver - 30-apr-2008
                            );
   END IF;
   hr_utility.trace('Leaving: '||l_proc);
 END entries_affected;

--
END BEN_EXT_UTIL;

/
