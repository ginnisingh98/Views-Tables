--------------------------------------------------------
--  DDL for Package Body BEN_BENMNGLE_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENMNGLE_PURGE" as
/* $Header: benpurge.pkb 120.0.12000000.4 2007/06/25 10:12:05 nhunur noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
	Purge BENMNGLE related tables
Purpose
        This package is used to purge BENMNGLE related data from tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        10-AUG-98        GPERRY     110.0      Created.
        06-JAN-99        GPERRY     115.2      Corrected to use concurrent
                                               request id.
        24-FEB-99        GPERRY     115.3      Fixed dates for canonical
        22-MAR-99        TMATHERS   115.5      Changed -MON- to /MM/
        20-JUL-99        Gperry     115.6      genutils -> benutils package
                                               rename.
        04-APR-00        mmogel     115.7      Added tokens to messages to make
                                               them more meaningful to the user
        28-APR-00        gperry     115.8      Converted API calls to base
                                               tables for performance.
        18-SEP-02        hmani      115.9      Bug# 2573240 modified
        				                   delete_reporting_rows procedure.
        26-DEC-02        rpillay    115.11     NOCOPY changes
        02-Aug-04        nhunur     115.12     3805304 - Added code to handle null request_id
                                               rows in ben_benefit_actions.
        03-Dec-04        ikasire    115.13     Bug 4046914
        28-Dec-07        nhunur     115.14     Bug 6075014 - perf changes
*/
--------------------------------------------------------------------------------
--
g_package varchar2(80) := 'ben_benmngle_purge';
--
procedure write_params(p_concurrent_request_id in number,
                       p_business_group_id     in number,
                       p_effective_date        in date) is
  --
  l_package        varchar2(80) := g_package||'.write_params';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Runtime Parameters');
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => benutils.g_banner_minus);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Concurrent Request ID : '||p_concurrent_request_id);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Business Group ID : '||p_business_group_id);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Effective Date    : '||to_char(p_effective_date,'DD/MM/YYYY'));
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when others then
    --
    fnd_message.set_name('BEN','BEN_91663_BENMNGLE_LOGGING');
    fnd_message.set_token('PROC',l_package);
    fnd_message.raise_error;
    --
end write_params;
--
procedure write_logfile(p_benefit_action_id    in number,
                        p_benefit_action_rows  in number,
                        p_batch_range_rows     in number,
                        p_person_action_rows   in number,
                        p_reporting_rows       in number,
                        p_dpnt_rows            in number,
                        p_elctbl_chc_rows      in number,
                        p_elig_rows            in number,
                        p_proc_rows            in number,
                        p_rate_rows            in number,
                        p_ler_rows             in number) is
  --
  l_package        varchar2(80) := g_package||'.write_logfile';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => benutils.g_banner_minus);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Benefit Action ID Deleted   = '||p_benefit_action_id);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Benefit Action Rows Deleted = '||p_benefit_action_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Batch Range Rows Deleted    = '||p_batch_range_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Person Action Rows Deleted  = '||p_person_action_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Dependent Information Rows Deleted  = '||p_dpnt_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Electable Choice Information Rows Deleted  = '||p_elctbl_chc_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Eligibility Rows Deleted  = '||p_elig_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Process Information Rows Deleted  = '||p_proc_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Rate Information Rows Deleted  = '||p_rate_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Life Event Information Rows Deleted  = '||p_ler_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => 'Reporting Rows Deleted      = '||p_reporting_rows);
  --
  fnd_file.put_line
    (which => fnd_file.log,
     buff  => benutils.g_banner_minus);
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
exception
  --
  when others then
    --
    fnd_message.set_name('BEN','BEN_91663_BENMNGLE_LOGGING');
    fnd_message.set_token('PROC',l_package);
    fnd_message.raise_error;
    --
end write_logfile;
--
procedure delete_reporting_rows(p_benefit_action_id in  number,
                                p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_reporting_rows';
  l_records_to_be_deleted number := 5000; /* Deleting 5000 records at a time */

  -- Procedure slightly modified for Bug# 2573240 to delete 5000
  -- records at a time
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows :=0;
  loop
  	delete from ben_reporting
  	where  benefit_action_id = p_benefit_action_id
  	and rownum <=l_records_to_be_deleted;
	--
	p_rows := p_rows + sql%rowcount;
	--
  	exit when sql%rowcount=0;
        commit;
  end loop;
  --
  commit;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_reporting_rows;
--
procedure delete_batch_range_rows(p_benefit_action_id in  number,
                                  p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_range_rows';
  l_records_to_be_deleted number := 5000;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows :=0;
  loop
    delete from ben_batch_ranges
    where  benefit_action_id = p_benefit_action_id
    and rownum <=l_records_to_be_deleted;
  --
    p_rows := p_rows + sql%rowcount;
  --
    exit when sql%rowcount=0;
    commit;
  end loop;
  --
  commit;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_range_rows;
--
procedure delete_batch_ler_rows(p_benefit_action_id in  number,
                                p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_ler_rows';
  --
  l_records_to_be_deleted number := 5000;
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows :=0;
  loop
    delete from ben_batch_ler_info
    where  benefit_action_id = p_benefit_action_id
    and rownum <=l_records_to_be_deleted;
    --
    p_rows := p_rows + sql%rowcount;
    --
    exit when sql%rowcount=0;
    commit;
  end loop;
  --
  commit;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_ler_rows;
--
procedure delete_batch_dpnt_rows(p_benefit_action_id in  number,
                                 p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_dpnt_rows';
  --
  l_records_to_be_deleted number := 5000;
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows :=0;
  loop
    delete from ben_batch_dpnt_info
    where  benefit_action_id = p_benefit_action_id
    and rownum <=l_records_to_be_deleted;
  --
    p_rows := p_rows + sql%rowcount;
  --
    commit;
    exit when sql%rowcount=0;
  end loop;
  --
  commit;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_dpnt_rows;
--
procedure delete_batch_elctbl_rows(p_benefit_action_id in  number,
                                   p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_elctbl_rows';
  l_records_to_be_deleted number := 5000;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows :=0;
  loop
    delete from ben_batch_elctbl_chc_info
    where  benefit_action_id = p_benefit_action_id
    and rownum <=  l_records_to_be_deleted ;
  --
    p_rows := p_rows + sql%rowcount;
  --
    commit;
    exit when sql%rowcount=0;
  end loop;
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_elctbl_rows;
--
procedure delete_batch_elig_rows(p_benefit_action_id in  number,
                                 p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_elig_rows';
  --
  l_records_to_be_deleted number := 5000;
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows := 0 ;
  loop
     delete from ben_batch_elig_info
     where  benefit_action_id = p_benefit_action_id
     and rownum <=  l_records_to_be_deleted ;
     --
     p_rows := p_rows + sql%rowcount;
     --
     exit when sql%rowcount=0;
     commit;
  end loop;
  --
  commit;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_elig_rows;
--
procedure delete_batch_proc_rows(p_benefit_action_id in  number,
                                 p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_proc_rows';
  l_records_to_be_deleted number := 5000;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows := 0 ;
  loop
    delete from ben_batch_proc_info
    where  benefit_action_id = p_benefit_action_id
    and rownum <=  l_records_to_be_deleted ;
  --
    p_rows := p_rows + sql%rowcount;
  --
    commit;
    exit when sql%rowcount=0;
  end loop;
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_proc_rows;
--
procedure delete_batch_rate_rows(p_benefit_action_id in  number,
                                 p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_batch_rate_rows';
  --
  l_records_to_be_deleted number := 5000;
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows := 0 ;
  loop
    delete from ben_batch_rate_info
    where  benefit_action_id = p_benefit_action_id
    and rownum <=  l_records_to_be_deleted ;
  --
    p_rows := p_rows + sql%rowcount;
  --
    commit;
    exit when sql%rowcount=0;
  end loop;
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_batch_rate_rows;
--
procedure delete_person_action_rows(p_benefit_action_id in  number,
                                    p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_person_action_rows';
  --
  l_records_to_be_deleted number := 5000;
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  p_rows :=0;
  loop
    delete from ben_person_actions
    where  benefit_action_id = p_benefit_action_id
    and rownum <= l_records_to_be_deleted;
  --
    p_rows := p_rows + sql%rowcount;
  --
    exit when sql%rowcount=0;
    commit;
  end loop;
  --
  commit;
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_person_action_rows;
--
procedure delete_benefit_action_rows(p_benefit_action_id in  number,
                                     p_rows              out nocopy number) is
  --
  l_package varchar2(80) := g_package||'.delete_benefit_action_rows';
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  delete from ben_benefit_actions
  where  benefit_action_id = p_benefit_action_id;
  --
  p_rows := sql%rowcount;
  --
  commit;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end delete_benefit_action_rows;
--
procedure purge_single(p_benefit_action_id in number) is
  --
  l_package varchar2(80) := g_package||'.purge_single';
  --
  -- Variables to store rows being deleted
  --
  l_reporting_rows number := 0;
  l_batch_range_rows number := 0;
  l_person_action_rows number := 0;
  l_dpnt_rows number := 0;
  l_elctbl_chc_rows number := 0;
  l_elig_rows number := 0;
  l_proc_rows number := 0;
  l_rate_rows number := 0;
  l_ler_rows number := 0;
  l_benefit_action_rows number := 0;
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Delete in the order
  --
  -- 1) Reporting Rows
  -- 2) Batch Range Rows
  -- 3) Person Action Rows
  -- 4) Dependent Information Rows
  -- 5) Electable Choice Information Rows
  -- 6) Eligibility Information Rows
  -- 7) Process Information Rows
  -- 8) Rate Information Rows
  -- 9) Life Event Information Rows
  -- 10) Benefit Action Rows
  --
  delete_reporting_rows(p_benefit_action_id => p_benefit_action_id,
                        p_rows              => l_reporting_rows);
  delete_batch_range_rows(p_benefit_action_id => p_benefit_action_id,
                          p_rows              => l_batch_range_rows);
  delete_person_action_rows(p_benefit_action_id => p_benefit_action_id,
                            p_rows              => l_person_action_rows);
  delete_batch_dpnt_rows(p_benefit_action_id => p_benefit_action_id,
                         p_rows              => l_dpnt_rows);
  delete_batch_elctbl_rows(p_benefit_action_id => p_benefit_action_id,
                           p_rows              => l_elctbl_chc_rows);
  delete_batch_elig_rows(p_benefit_action_id => p_benefit_action_id,
                         p_rows              => l_elig_rows);
  delete_batch_proc_rows(p_benefit_action_id => p_benefit_action_id,
                         p_rows              => l_proc_rows);
  delete_batch_rate_rows(p_benefit_action_id => p_benefit_action_id,
                         p_rows              => l_rate_rows);
  delete_batch_ler_rows(p_benefit_action_id => p_benefit_action_id,
                        p_rows              => l_ler_rows);
  delete_benefit_action_rows(p_benefit_action_id => p_benefit_action_id,
                             p_rows              => l_benefit_action_rows);
  --
  write_logfile(p_benefit_action_id    => p_benefit_action_id,
                p_benefit_action_rows  => l_benefit_action_rows,
                p_batch_range_rows     => l_batch_range_rows,
                p_person_action_rows   => l_person_action_rows,
                p_reporting_rows       => l_reporting_rows,
                p_dpnt_rows            => l_dpnt_rows,
                p_elctbl_chc_rows      => l_elctbl_chc_rows,
                p_elig_rows            => l_elig_rows,
                p_proc_rows            => l_proc_rows,
                p_rate_rows            => l_rate_rows,
                p_ler_rows             => l_ler_rows);
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end purge_single;
--
procedure purge_all(errbuf                  out nocopy varchar2,
                    retcode                 out nocopy number,
                    p_concurrent_request_id in number default null,
                    p_business_group_id     in number default null,
                    p_effective_date        in varchar2 default null) is
  --
  l_package varchar2(80) := g_package||'.purge_all';
  l_effective_date date;
  --
  cursor c_benefit_actions is
    select bft.benefit_action_id
    from   ben_benefit_actions bft,
           fnd_concurrent_requests fnd
    where  bft.business_group_id = nvl(p_business_group_id,bft.business_group_id)
    and    nvl(bft.request_id,-1) = nvl(p_concurrent_request_id,nvl(bft.request_id,-1))
    and    bft.process_date      = nvl(l_effective_date,bft.process_date)
    /* Outer join to provide backwards compatability, for all cases where request id is blank */
    and    fnd.request_id(+) = bft.request_id
    and    nvl(fnd.phase_code,'C') = 'C';
  --
  -- l_benefit_actions c_benefit_actions%rowtype;
  l_errbuf          varchar2(2000);
  l_retcode         number;
  --
  type benactionTable is table of c_benefit_actions%rowtype;
  l_benefit_actions benactionTable;

begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Convert date from canonical to regular date
  --
  -- Convert varchar2 dates to real dates
  -- 1) First remove time component
  -- 2) Next convert format
  /*
  l_effective_date := to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
  l_effective_date := to_date(to_char(trunc(l_effective_date),'DD/MM/RRRR'),'DD/MM/RRRR');
  */
  l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
  --
  -- Sanity check that at least one field has been entered
  --
  if p_concurrent_request_id is null and
     p_business_group_id is null and
     p_effective_date is null then
    --
    fnd_message.set_name('BEN','BEN_91752_BENPURGE_PARAMS');
    fnd_message.set_token('PROC',l_package);
    fnd_message.raise_error;
    --
  end if;
  --
  -- Log runtime parameters
  --
  write_params(p_concurrent_request_id => p_concurrent_request_id,
               p_business_group_id     => p_business_group_id,
               p_effective_date        => l_effective_date);
  --
  -- Open cursor and purge single benefit action
  --
  open c_benefit_actions;
  fetch c_benefit_actions BULK COLLECT INTO l_benefit_actions;
  close c_benefit_actions;
  --
  FOR i IN 1..l_benefit_actions.COUNT
  loop
      purge_single(p_benefit_action_id => l_benefit_actions(i).benefit_action_id);
  end loop;
  --
  hr_utility.set_location ('Leaving '||l_package,10);
  --
end purge_all;
--
end ben_benmngle_purge;

/
