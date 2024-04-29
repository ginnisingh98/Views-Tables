--------------------------------------------------------
--  DDL for Package Body PQH_RANKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RANKING" AS
/* $Header: pqrnkpkg.pkb 120.8 2006/01/23 10:57:25 nsanghal noship $ */
--
--
 g_package constant varchar2(20) := ' pqh_ranking.';

 PGI_SETUP_NOT_FOUND EXCEPTION;

 -- ---------------------------------------------------------------------------
 -- --------------------- <write_log> -----------------------------------------
 -- ---------------------------------------------------------------------------
PROCEDURE write_log (p_write_log in varchar2, p_log_text in varchar2) IS
Begin
  If (p_write_log = 'Y') then
   --
        fnd_file.put_line (
           which => fnd_file.log,
           buff  => p_log_text);
   --
  end if;
End write_log;
 --
 -- ---------------------------------------------------------------------------
 -- ------------- <Handle_Error> ----------------------------------------------
 -- ---------------------------------------------------------------------------
 PROCEDURE handle_error ( p_error_code in varchar2) IS
 l_proc constant varchar2(72):= g_package||'handle_error';
 BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
    IF (p_error_code = 'PGI_SETUP_NOT_FOUND') THEN
       raise PGI_SETUP_NOT_FOUND;
    END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN PGI_SETUP_NOT_FOUND THEN
        raise;

 END;
--
--
 -- ---------------------------------------------------------------------------
 -- ------------- <get_emp_count_on_pgm> --------------------------------------
 -- ---------------------------------------------------------------------------
FUNCTION   get_emp_count_on_pgm (p_benefit_action_id in number, p_pgm_id in number)
           RETURN number is
 l_count number;
 l_proc constant varchar2(72):= g_package||'get_emp_count_on_pgm';
BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
   SELECT count(1)
   INTO   l_count
   FROM   pqh_rank_processes
   WHERE  pgm_id            = p_pgm_id
   AND    (p_benefit_action_id IS NULL or benefit_action_id = p_benefit_action_id);

   RETURN l_count;

    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
END  get_emp_count_on_pgm ;
--
 -- ---------------------------------------------------------------------------
 -- ------------- <create_update_rank_approvals> ------------------------------
 -- ---------------------------------------------------------------------------
PROCEDURE  create_update_rank_approvals (
                 p_rank_process_id  in NUMBER,
                 p_rank             in number,
                 p_population_count in number) IS

           Cursor csr_ranks is
             Select rank_process_approval_id,object_version_number
               From pqh_rank_process_approvals
              Where rank_process_id  = p_rank_process_id;
--
l_rank_process_approval_id number;
l_ovn  number;
isFound boolean ;
--
BEGIN
  isFound := false;
  For rec_ranks in csr_ranks Loop
    pqh_rank_process_approval_api.update_rank_process_approval (
       p_effective_date                => sysdate
      ,p_rank_process_approval_id      => rec_ranks.rank_process_approval_id
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => sysdate
      ,p_system_rank                   => p_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_rank
      ,p_object_version_number         => rec_ranks.object_version_number );
    isFound := true;
  End Loop;

  if NOT(isFound) then
     select pqh_rank_process_approvals_s.nextval
     into l_rank_process_approval_id from dual;
     -- Create Ranks
     pqh_rank_process_approval_api.create_rank_process_approval (
       p_effective_date                => sysdate
      ,p_rank_process_approval_id      => l_rank_process_approval_id
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => sysdate
      ,p_system_rank                   => p_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_rank
      ,p_object_version_number         => l_ovn );
 END IF; -- Rank Exists
           --
END create_update_rank_approvals;

 -- ---------------------------------------------------------------------------
 -- ------------- <is_workflow_enabled> ---------------------------------------
 -- ---------------------------------------------------------------------------
 FUNCTION  is_workflow_enabled ( p_pgm_id in number) return varchar2 IS
 l_rank_enabled varchar2(10);
 l_handle_dup   varchar2(10);
 l_group_score  varchar2(10);
 l_wf_enabled   varchar2(10);
 l_result       varchar2(240);
 l_proc constant varchar2(72):= g_package||'is_workflow_enabled';
 BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
     get_pgi_info (
       p_pgm_id               => p_pgm_id
      ,p_workflow_enabled    => l_wf_enabled
      ,p_rank_enabled        => l_rank_enabled
      ,p_handle_duplicate    => l_handle_dup
      ,p_group_score         => l_group_score
      ,p_result              => l_result );

  return  l_wf_enabled;

    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
 END;
--
 -- ---------------------------------------------------------------------------
 -- ------------- <Get_Pgi_Info> ----------------------------------------------
 -- ---------------------------------------------------------------------------
 PROCEDURE get_pgi_info (
           p_pgm_id in number
           ,p_workflow_enabled out nocopy varchar2
           ,p_rank_enabled     out nocopy varchar2
           ,p_handle_duplicate out nocopy varchar2
           ,p_group_score      out nocopy varchar2
           ,p_result           out nocopy varchar2)   IS
 Cursor csr_pgi IS
 SELECT pgi_information1  wf_enabled,
        pgi_information2  rank_enabled,
        NVL(pgi_information4,'SUM')  duplicate_handling,
        pgi_information3  group_score
 FROM   ben_pgm_extra_info
 WHERE  pgm_id     = p_pgm_id
 AND    information_type = 'PQH_GSP_EXTRA_INFO';

 l_proc constant varchar2(72):= g_package||'get_pgi_info';
 BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
   open   csr_pgi;
   FETCH  csr_pgi INTO p_workflow_enabled, p_rank_enabled, p_handle_duplicate, p_group_score;
     IF (csr_pgi%NOTFOUND ) THEN
     --
        p_result := 'PGI_SETUP_NOT_FOUND';
     --
     END IF;
   CLOSE  csr_pgi;

    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
 END;

 -- ---------------------------------------------------------------------------
 -- ------------- <Compute_Rank_For_GSP> --------------------------------------
 -- ---------------------------------------------------------------------------
PROCEDURE compute_rank_for_GSP (
          errbuf              out nocopy VARCHAR2,
          retcode             out nocopy NUMBER,
          p_business_group_id in NUMBER,
          p_pgm_id            in NUMBER,
          p_pl_id             in NUMBER,
          p_process_dt_start  in VARCHAR2,
          p_process_dt_end    in VARCHAR2,
          p_benefit_action_id in NUMBER,
          p_audit_log         in VARCHAR2,
          p_commit_data       in VARCHAR2,
          p_rank_wf_pending   in VARCHAR2
           ) IS
/**
 * Cursor to find grade ladders for a given
 * benefit action
 */
CURSOR csr_pgm IS
SELECT distinct pgm_id
FROM   pqh_rank_processes
WHERE  benefit_action_id = p_benefit_action_id;

/*
 * Cursor to find grade ladders within a given time
 * period and/or the grade
 */
Cursor csr_pgm_no_ba  (c_dt_start in date, c_dt_end date) is
select distinct rnk.pgm_id
FROM   pqh_rank_processes rnk,
       ben_per_in_ler         pil
where  (p_pl_id is null OR rnk.pl_id = p_pl_id)
and  rnk.per_in_ler_id = pil.per_in_ler_id
and  pil.business_group_id   = p_business_group_id
and  pil.per_in_ler_stat_cd = 'STRTD'
and  pil.strtd_dt between c_dt_start and c_dt_end ;

/*
 * Cursor to find grade and population cound for a given grade ladder
 * and benefit action
 */
CURSOR csr_gr (c_pgm_id in number) IS
SELECT pl_id, count(1) emp_cnt
FROM   pqh_rank_processes
WHERE  (p_benefit_action_id is null or benefit_action_id = p_benefit_action_id)
AND    pgm_id            = c_pgm_id
GROUP BY pl_id;

/*
 * Cursor to find grade and population cound for a given grade ladder
 * when benefit action is not specified
 */
cursor csr_gr_no_ba (c_pgm_id in number, c_pl_id in number,
                     c_dt_start in date, c_dt_end in date ) is
select rnk.pl_id, count(1) emp_cnt
FROM   pqh_rank_processes rnk,
       ben_per_in_ler  pil
where rnk.pgm_id      = c_pgm_id
and   (c_pl_id is null OR rnk.pl_id = c_pl_id)
and   rnk.per_in_ler_id = pil.per_in_ler_id
and   pil.business_group_id  = p_business_group_id
and   pil.per_in_ler_stat_cd = 'STRTD'
and   pil.strtd_dt between c_dt_start and c_dt_end
group by pl_id;

/*
 * Cursor to find records to be ranked for the given grade ladder
 * and benefit action
 */
          Cursor csr_rnk_pgm (c_pgm_id in number) Is
             SELECT rank_process_id, total_score
             FROM   pqh_rank_processes
             WHERE  benefit_action_id = p_benefit_action_id
             AND    pgm_id    = c_pgm_id
             ORDER  BY total_score DESC;

/*
 * Cursor to find records to be ranked for the given grade ladder
 * when benefit action is not specified
 */
          Cursor csr_rnk_pgm_no_ba (c_pgm_id in number,
                                    c_dt_start in date, c_dt_end in date) Is
             SELECT rnk.rank_process_id,rnk.total_score
             FROM   pqh_rank_processes rnk,
                    ben_per_in_ler     pil,
                    ben_elig_per_elctbl_chc epec
             WHERE  rnk.pgm_id         = c_pgm_id
              AND   rnk.per_in_ler_id  = pil.per_in_ler_id
              AND   per_in_ler_stat_cd = 'STRTD'
              AND   pil.business_group_id  = p_business_group_id
              AND   epec.per_in_ler_id     = pil.per_in_ler_id
              AND   epec.business_group_id = pil.business_group_id
              AND   epec.pgm_id            = c_pgm_id
              AND   epec.dflt_flag         = 'Y'
              AND   approval_status_cd IS NULL
              AND   ( nvl(p_rank_wf_pending,'N') = 'Y' OR
                         in_pndg_wkflow_flag <> 'Y')
              AND    pil.strtd_dt between c_dt_start and c_dt_end
             ORDER  BY total_score DESC;
/*
 * Cursor to find records to be ranked for a given grade,
 * grade ladder and benefit action
 */
          Cursor csr_rnk_pl( c_pgm_id in number, c_pl_id in number ) Is
             SELECT rank_process_id, total_score
             FROM   pqh_rank_processes
             WHERE  benefit_action_id = p_benefit_action_id
             AND    pgm_id    = c_pgm_id
             AND    pl_id     = c_pl_id
             ORDER  BY  total_score DESC;

/*
 * Cursor to find records to be ranked for a given grade,
 * grade ladder when benefit action is not specified
 */
          Cursor csr_rnk_pl_no_ba( c_pgm_id in number, c_pl_id in number ,
                                   c_dt_start in date, c_dt_end in date ) Is
             SELECT rnk.rank_process_id,rnk.total_score
             FROM   pqh_rank_processes rnk,
                    ben_per_in_ler pil,
                    ben_elig_per_elctbl_chc epec
             WHERE  rnk.pgm_id    = c_pgm_id
             AND    rnk.pl_id     = c_pl_id
             AND    rnk.per_in_ler_id = pil.per_in_ler_id
             AND    per_in_ler_stat_cd = 'STRTD'
             AND    pil.business_group_id  = p_business_group_id
             AND    epec.per_in_ler_id     = pil.per_in_ler_id
             AND    epec.business_group_id = pil.business_group_id
             AND    epec.pgm_id            = c_pgm_id
             AND    epec.pl_id             = c_pl_id
             AND    epec.dflt_flag         = 'Y'
             AND    approval_status_cd IS NULL
             AND    ( nvl(p_rank_wf_pending,'N') = 'Y' OR
                          in_pndg_wkflow_flag <> 'Y')
             and    pil.strtd_dt between c_dt_start and c_dt_end
             ORDER  BY  total_score DESC;

--
l_cnt         NUMBER  := 0;
--
l_rank_enabled     varchar2(30);
l_wf_enabled       varchar2(10);
l_handle_duplicate varchar2(30);
l_group_score      varchar2(30);
l_result           varchar2(30);
l_pgm_id           number;
--
l_ovn              number(15);
l_proc constant    varchar2(72):= g_package||'compute_rank_for_gsp';
--
l_rank        number;
l_prev_score  number;
l_dummy       number;
--
l_dt_start   date;
l_dt_end     date;
BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);
    l_dt_start  := trunc(fnd_date.canonical_to_date(p_process_dt_start));
    l_dt_end    := trunc(fnd_date.canonical_to_date(p_process_dt_end  ));

    l_dt_end    := nvl(l_dt_end  , hr_general.end_of_time );
    l_dt_start  := nvl(l_dt_start, hr_general.start_of_time);

    write_log(p_audit_log, 'BEGIN RANKING PROCESS');
    write_log(p_audit_log, 'Parameter List');
    write_log(p_audit_log, '------------------------------');
    write_log(p_audit_log, 'Benefit Action Id: '||p_benefit_action_id);
    write_log(p_audit_log, 'Grade Ladder Id: '||p_pgm_id);
    write_log(p_audit_log, 'Grade Id: '||p_pl_id);
    write_log(p_audit_log, 'Process Start Date: '||l_dt_start);
    write_log(p_audit_log, 'Process End Date: '||l_dt_end);

  --
 /**
  * CASE 1: BENEFIT_ACTION_ID is specified.
  * ignore all other parameters, except audit_log and pending wf
  */
  IF (p_benefit_action_id IS NOT NULL) THEN
    write_log(p_audit_log, 'Benefit Action Id: ' || p_benefit_action_id);
    FOR rec_pgm in csr_pgm
      Loop
       write_log(p_audit_log, '-------------------------------------------------------');
       write_log(p_audit_log, 'Ranking For Grade Ladder Id: ' || rec_pgm.pgm_id);
         -- Get Grade ladder setup options
         get_pgi_info (
           p_pgm_id           => rec_pgm.pgm_id,
           p_workflow_enabled => l_wf_enabled,
           p_rank_enabled     => l_rank_enabled,
           p_handle_duplicate => l_handle_duplicate,
           p_group_score      => l_group_score,
           p_result           => l_result );

       -- If ranking is not enabled for the grade ladder
       -- then skip to the next grade ladder.
       IF ( l_rank_enabled <> 'Y') Then
           write_log(p_audit_log, 'Ranking NOT enabled, skipping to next Grade Ladder' );
           GOTO NEXT_RECORD_SET;
       END IF;
       --
       IF (l_group_score = 'GL') then
          write_log(p_audit_log, 'Ranking by Grade ladder');
          l_cnt := get_emp_count_on_pgm (p_benefit_action_id, rec_pgm.pgm_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade ladder: ' || l_cnt);
          -- Reset variables before starting
          l_rank       := 0;
          l_prev_score := 0;
          For rec_rnk In csr_rnk_pgm(rec_pgm.pgm_id) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , l_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
       ELSIF l_group_score = 'GRADE' then
        write_log(p_audit_log, 'Ranking by Grade');
          --
        for rec in csr_gr(rec_pgm.pgm_id) Loop
          write_log(p_audit_log, 'Ranking For Grade Id: ' || rec.pl_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade: ' || rec.emp_cnt);
          -- Reset variables for each grade before starting
          l_rank       := 0;
          l_prev_score := 0;
          For rec_rnk In csr_rnk_pl(rec_pgm.pgm_id, rec.pl_id) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , rec.emp_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
        End Loop;
       END IF;

      <<NEXT_RECORD_SET>>
      null;
    END LOOP; -- PGMs
   --
 /**
  * CASE 2: Grade Ladder (pgm_id) specified
  *
  */
  ELSIF p_pgm_id is not null then
       write_log(p_audit_log, 'Ranking For Grade Ladder Id: ' || p_pgm_id);
        get_pgi_info (
           p_pgm_id           => p_pgm_id,
           p_workflow_enabled => l_wf_enabled,
           p_rank_enabled     => l_rank_enabled,
           p_handle_duplicate => l_handle_duplicate,
           p_group_score      => l_group_score,
           p_result           => l_result );

       -- If ranking is not enabled for the grade ladder
       -- then return with no further processing
       IF ( l_rank_enabled <> 'Y') Then
           write_log(p_audit_log, 'Ranking NOT enabled, no records to rank');
           RETURN;
       END IF;
       --
       --
       IF (l_group_score = 'GL') then
          write_log(p_audit_log, 'Ranking by Grade ladder');
          l_cnt := get_emp_count_on_pgm (null, p_pgm_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade ladder:' || l_cnt);
           --
           -- Reset variables for each grade before starting
           l_rank       := 0;
           l_prev_score := 0;
           For rec_rnk In csr_rnk_pgm_no_ba(p_pgm_id, l_dt_start, l_dt_end ) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , l_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
       ELSIF l_group_score = 'GRADE' then
        --
        write_log(p_audit_log, 'Ranking by Grade');
        --
        if (p_pl_id is null) then -- Rank all grades
        for rec in csr_gr_no_ba(p_pgm_id,null, l_dt_start, l_dt_end ) Loop
          write_log(p_audit_log, 'Ranking For Grade Id: ' || rec.pl_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade: ' || rec.emp_cnt);
           -- Reset variables for each grade before starting
           l_rank       := 0;
           l_prev_score := 0;
          For rec_rnk In csr_rnk_pl_no_ba(p_pgm_id, rec.pl_id,
                            l_dt_start, l_dt_end ) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , rec.emp_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
        End Loop;
       else -- Rank specified grades
          write_log(p_audit_log, 'Ranking For Grade Id: ' || p_pl_id);
          open  csr_gr_no_ba(p_pgm_id, p_pl_id, l_dt_start, l_dt_end );
          fetch csr_gr_no_ba into l_dummy, l_cnt;
          close csr_gr_no_ba;
          write_log(p_audit_log, 'Number of employees to be ranked on the grade: ' || l_cnt);
           -- Reset variables for each grade before starting
           l_rank       := 0;
           l_prev_score := 0;
          For rec_rnk In csr_rnk_pl_no_ba(p_pgm_id, p_pl_id,
                                    l_dt_start, l_dt_end ) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , l_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
        end if;
       END IF;
 /**
  * CASE 3: Grade Ladder Not specified
  * Fetch All grade ladders first and then
  * do the ranking
  */
  ELSIF p_pgm_id is null then
   --
   For rec_pgm in csr_pgm_no_ba (l_dt_start, l_dt_end)  Loop
       write_log(p_audit_log, '-------------------------------------------------------');
       write_log(p_audit_log, 'Ranking For Grade Ladder Id: ' || rec_pgm.pgm_id);
         -- Get Grade ladder setup options
         get_pgi_info (
           p_pgm_id           => rec_pgm.pgm_id,
           p_workflow_enabled => l_wf_enabled,
           p_rank_enabled     => l_rank_enabled,
           p_handle_duplicate => l_handle_duplicate,
           p_group_score      => l_group_score,
           p_result           => l_result );

       -- If ranking is not enabled for the grade ladder
       -- then skip to the next grade ladder.
       IF ( l_rank_enabled <> 'Y') Then
           write_log(p_audit_log, 'Ranking NOT enabled, skipping to next Grade Ladder' );
           GOTO NEXT_RECORD_SET;
       END IF;
       --
       IF (l_group_score = 'GL') then
          write_log(p_audit_log, 'Ranking by Grade ladder');
          l_cnt        := get_emp_count_on_pgm (null, rec_pgm.pgm_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade ladder:' || l_cnt);
          -- Reset variables before starting
          l_rank       := 0;
          l_prev_score := 0;
          --
          For rec_rnk In csr_rnk_pgm_no_ba(rec_pgm.pgm_id , l_dt_start, l_dt_end ) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , l_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
       ELSIF l_group_score = 'GRADE' then
        --
        write_log(p_audit_log, 'Ranking by Grade');
        --
        if (p_pl_id is null) then -- Rank all grades
        for rec in csr_gr_no_ba(rec_pgm.pgm_id,null, l_dt_start, l_dt_end ) Loop
          --
          write_log(p_audit_log, 'Ranking For Grade Id: ' || rec.pl_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade: ' || rec.emp_cnt);
           -- Reset variables for each grade before starting
           l_rank       := 0;
           l_prev_score := 0;
          For rec_rnk In csr_rnk_pl_no_ba(rec_pgm.pgm_id, rec.pl_id,
                                          l_dt_start, l_dt_end ) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , rec.emp_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
        End Loop;
       else -- Rank specified grades
          open  csr_gr_no_ba(rec_pgm.pgm_id, p_pl_id, l_dt_start, l_dt_end );
          fetch csr_gr_no_ba into l_dummy, l_cnt;
          close csr_gr_no_ba;
          write_log(p_audit_log, 'Ranking For Grade Id: ' || p_pl_id);
          write_log(p_audit_log, 'Number of employees to be ranked on the grade: ' || l_cnt);
           -- Reset variables for each grade before starting
           l_rank       := 0;
           l_prev_score := 0;
          For rec_rnk In csr_rnk_pl_no_ba(rec_pgm.pgm_id, p_pl_id,
                                          l_dt_start, l_dt_end ) Loop
            --
            if ( l_prev_score <> rec_rnk.total_score) then
                 l_rank       := l_rank + 1;
                 l_prev_score := rec_rnk.total_score;
            end if;
            --
            create_update_rank_approvals(rec_rnk.rank_process_id
                                       , l_rank
                                       , l_cnt );
           --
          End Loop;
          --
          write_log(p_audit_log, 'Unique ranks assigned: ' || l_rank);
          --
        end if;
       END IF;

      <<NEXT_RECORD_SET>>
      null;
   End Loop;
   --
  END IF; -- Benefit action ID
  --
  write_log(p_audit_log, '-------------------------------------------------------');
  --
  -- This flag is changed to Validate, please read the opposite.
  -- So Validate = Y means do not commit likewise Validate=N
  -- means commit (not validating)
  if (p_commit_data = 'N') then
    --
     write_log(p_audit_log, 'Commiting the Changes');
     commit;
    --
  else
    --
     write_log(p_audit_log, 'Rolling back the Changes');
     rollback;
    --
  end if;
    --
    write_log(p_audit_log, 'RANKING PROCESS COMPLETE');
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
 Exception
    WHEN Others THEN
        raise;
END;
--
 -- ---------------------------------------------------------------------------
 -- ------------- <Compute_Score_For_GSP> -------------------------------------
 -- ---------------------------------------------------------------------------
  PROCEDURE compute_score_for_GSP (
       p_benefit_action_id in number
      ,p_per_in_ler_id     in number
      ,p_person_id         in number
      ,p_effective_date    in date
      ,p_pgm_id            in number
      ,p_handle_duplicate  in varchar2
      ,p_group_score       in varchar2 ) IS

  --
  l_proc constant varchar2(72):= g_package||'compute_score_for_gsp';
  --
    cursor per_asg_cur is
  select assignment_id
  from   per_all_assignments_f
  where  person_id = p_person_id
  And    primary_flag = 'Y'
  and    p_effective_date between effective_start_date and effective_end_date;

  l_assignment_id per_all_assignments_f.assignment_id%type;

  BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
    hr_utility.set_location('Grouping by: '||p_group_score,5);
    hr_utility.set_location('Duplicate Handling: '||p_handle_duplicate,5);
/*
    write_log('Y','$$$$$$$$$$$$$$$$ Begin Computing Total Score $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
    write_log('Y','Grouping by: '||p_group_score);
    write_log('Y','Duplicate Handling: '||p_handle_duplicate);
*/
     --
     IF ( p_group_score = 'GRADE') THEN
     --
        hr_utility.set_location('Grouping by Grade',5);
        IF ( p_handle_duplicate = 'SUM') THEN
        --
           --
           INSERT INTO pqh_rank_processes (
             rank_process_id, process_cd, pgm_id, pl_id,
             benefit_action_id, process_date, person_id,
             per_in_ler_id, total_score, object_version_number)
             Select pqh_rank_processes_s.nextval, 'GSP', p_pgm_id, pl_id,
                    p_benefit_action_id, lf_evt_ocrd_dt,
                    person_id, per_in_ler_id, total_score, 1
             FROM (
                  select  ec.pl_id, ec.per_in_ler_id,
                          ep.person_id, pil.lf_evt_ocrd_dt,
                          sum(sr.computed_score) total_score
                   from   ben_elig_per_elctbl_chc ec,
                          ben_elig_scre_wtg_f     sr,
                          ben_elig_per_f          ep,
                          ben_per_in_ler          pil
                    where ec. elig_flag        = 'Y'
                      and ec.dflt_flag         = 'Y'
                      and ec.pgm_id            = p_pgm_id
                      and ec.per_in_ler_id     = p_per_in_ler_id
                      --
                      and ep.per_in_ler_id     = ec.per_in_ler_id
                      and ep.pgm_id            = ec.pgm_id
                      and (ep.pl_id   is null or ep.pl_id   = ec.pl_id )
                      and (ep.plip_id is null or ep.plip_id = ec.plip_id )
                      --
                      and sr.elig_per_id       = ep.elig_per_id
                      --
                      and pil.per_in_ler_id    = ec.per_in_ler_id
                      and pil.per_in_ler_stat_cd = 'STRTD'
                    group by  ec.pl_id, ec.per_in_ler_id,ep.person_id,
                              pil.lf_evt_ocrd_dt
                   );
        --
        ELSE
        ---
           INSERT INTO pqh_rank_processes (
             rank_process_id, process_cd, pgm_id,pl_id,
              benefit_action_id,process_date, person_id,
             per_in_ler_id, total_score, object_version_number)
             Select pqh_rank_processes_s.nextval, 'GSP', p_pgm_id, pl_id,
                     p_benefit_action_id, lf_evt_ocrd_dt ,
                    person_id, per_in_ler_id, total_score,1
             FROM ( select pl_id, per_in_ler_id, person_id,
                           lf_evt_ocrd_dt, sum(GROUP_score) total_score
                    from (
                       select  ec.pl_id, ec.per_in_ler_id,  ep.person_id,
                               pil.lf_evt_ocrd_dt, crit_tab_short_name,
                               decode(p_handle_duplicate,'MAX', MAX(sr.computed_score)
						        ,'MIN', MIN(sr.computed_score)
						        ,'AVG', AVG(sr.computed_score) ) GROUP_score
                        from   ben_elig_per_elctbl_chc ec,
                               ben_elig_scre_wtg_f     sr,
                               ben_elig_per_f          ep,
                               ben_per_in_ler          pil
                         where ec. elig_flag        = 'Y'
                           and ec.dflt_flag         = 'Y'
                           and ec.pgm_id            = p_pgm_id
                           and ec.per_in_ler_id     = p_per_in_ler_id
                           --
                           and ep.per_in_ler_id     = ec.per_in_ler_id
                           and ep.pgm_id            = ec.pgm_id
                           and (ep.pl_id   is null or ep.pl_id     = ec.pl_id )
                           and (ep.plip_id is null or ep.plip_id = ec.plip_id )
                           --
                           and sr.elig_per_id       = ep.elig_per_id
                           --
                           and pil.per_in_ler_id    = ec.per_in_ler_id
                           and pil.per_in_ler_stat_cd = 'STRTD'
                         group by  ec.pl_id, ec.per_in_ler_id, ep.person_id ,
                                   pil.lf_evt_ocrd_dt, crit_tab_short_name
                         ) GRP
                    GROUP BY pl_id,  per_in_ler_id,  person_id , lf_evt_ocrd_dt
                   );
        --
        --
        END IF;
     --
     ELSIF (p_group_score = 'GL' ) THEN
     --
       IF ( p_handle_duplicate = 'SUM') THEN
        --
           INSERT INTO pqh_rank_processes (
             rank_process_id, process_cd, pgm_id,
             benefit_action_id, process_date, person_id,
             per_in_ler_id, total_score,object_version_number)
             Select pqh_rank_processes_s.nextval, 'GSP', pgm_id, p_benefit_action_id,
                    lf_evt_ocrd_dt,  person_id, per_in_ler_id, total_score,1
             FROM (
                  select  ec.pgm_id, ec.per_in_ler_id,  ep.person_id,
                          pil.lf_evt_ocrd_dt, sum(sr.computed_score) total_score
                   from   ben_elig_per_elctbl_chc ec,
                          ben_elig_scre_wtg_f     sr,
                          ben_elig_per_f          ep,
                          ben_per_in_ler          pil
                    where ec. elig_flag        = 'Y'
                      and ec.dflt_flag         = 'Y'
                      and ec.pgm_id            = p_pgm_id
                      --
                      and ec.per_in_ler_id     = p_per_in_ler_id
                      --
                      and ep.per_in_ler_id     = ec.per_in_ler_id
                      and ep.pgm_id            = ec.pgm_id
  -- NS: 05/12/2005: Don't need this join, for it to work when elpro is attached
  -- to the program
                      --and ep.pl_id             = ec.pl_id
                      --and ep.plip_id           = ec.plip_id
                      --
                      and sr.elig_per_id       = ep.elig_per_id
                      --
                      and pil.per_in_ler_id    = ec.per_in_ler_id
                      and pil.per_in_ler_stat_cd = 'STRTD'
                    group by  ec.pgm_id, ec.per_in_ler_id, ep.person_id,
                              pil.lf_evt_ocrd_dt
                   ) ;
        --
        ELSE
        ---
           INSERT INTO pqh_rank_processes (
             rank_process_id, process_cd, pgm_id,
             benefit_action_id, process_date, person_id,
             per_in_ler_id, total_score, object_version_number)
             Select pqh_rank_processes_s.nextval, 'GSP', pgm_id,p_benefit_action_id,
                     lf_evt_ocrd_dt,   person_id, per_in_ler_id, total_score,1
             FROM ( select pgm_id, per_in_ler_id, person_id, lf_evt_ocrd_dt,
                           sum(GROUP_score) total_score
                    from (
                       select  ec.pgm_id,  ec.per_in_ler_id, ep.person_id,
                               pil.lf_evt_ocrd_dt, crit_tab_short_name,
                               decode(p_handle_duplicate,'MAX', MAX(sr.computed_score)
						        ,'MIN', MIN(sr.computed_score)
						        ,'AVG', AVG(sr.computed_score) ) GROUP_score
                        from   ben_elig_per_elctbl_chc ec,
                               ben_elig_scre_wtg_f     sr,
                               ben_elig_per_f          ep,
                               ben_per_in_ler          pil
                         where ec. elig_flag        = 'Y'
                           and ec.dflt_flag         = 'Y'
                           and ec.pgm_id            = p_pgm_id
                           and ec.per_in_ler_id     = p_per_in_ler_id
                           --
                           and ep.per_in_ler_id     = ec.per_in_ler_id
                           and ep.pgm_id            = ec.pgm_id
                           --and ep.pl_id             = ec.pl_id
                          -- and ep.plip_id           = ec.plip_id
                           --
                           and sr.elig_per_id       = ep.elig_per_id
                           --
                           and pil.per_in_ler_id    = ec.per_in_ler_id
                           and pil.per_in_ler_stat_cd = 'STRTD'
                         group by  ec.pgm_id, ec.per_in_ler_id, ep.person_id ,
                                   pil.lf_evt_ocrd_dt, crit_tab_short_name
                         ) GRP
                    GROUP BY pgm_id, per_in_ler_id,  person_id, lf_evt_ocrd_dt
                   ) ;
        --
        END IF; -- duplicate handling
     --
     END IF; -- group score
     --
     for i in per_asg_cur loop

	update pqh_rank_processes
        set assignment_id = i.assignment_id
        where  person_id = p_person_id
        and    benefit_action_id = p_benefit_action_id
        and    pgm_id = p_pgm_id;

     end loop;

    hr_utility.set_location(' Leaving:'||l_proc, 10);
/*
        write_log('Y','LEAVING Compute Total Score ');
        write_log('Y','$$$$$$$$$$$$$$$$ End Computing Total Score $$$$$$$$$$$$$$$$$$$');
*/
 Exception
    WHEN Others THEN
        hr_utility.set_location(' Error in '||l_proc||' : '||sqlerrm, 10);
        write_log('Y','Error in '||l_proc||': '||sqlerrm);
/*
        write_log('Y','$$$$$$$$$$$$$$$$ End Computing Total Score $$$$$$$$$$$$$$$$$$$');
*/
        raise;
  END compute_score_for_GSP;

-- -----------------------------------------------------------------------
-- Compute Score For Compensation workbench
--
--
-- -----------------------------------------------------------------------

 -- ---------------------------------------------------------------------------
 -- ------------- <Compute_Score_for_CWB> -------------------------------------
 -- ---------------------------------------------------------------------------
PROCEDURE compute_score_for_CWB (
       p_benefit_action_id IN NUMBER) IS

--
--
 l_proc constant varchar2(72):= g_package||'compute_score_for_cwb';
BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);

--
--
/** NS: 04/26/2005: Commenting as CWB Ranking is not going in FP.K
    Will uncomment it when CWB is ready to ship system ranking
Insert into pqh_rank_processes (
    Rank_process_id, process_cd, pl_id, person_id, assignment_id,
    Process_date,  total_score)
    SELECT pqh_rank_processes_s.nextval,'CWB', group_pl_id, person_id, assignment_id,
           lf_evt_ocrd_dt,     total_score
    FROM (
    Select pr.group_pl_id, pr.person_id, pr.assignment_id,
           pr.lf_evt_ocrd_dt,    sum(sr.score) total_score
     From  ben_cwb_person_rates  pr,
           ben_benefit_actions   ba,
           ben_elig_per_opt_f    epo,
           ben_elig_per_f        ep,
           ben_elig_scre_wtg_f   sr
     Where ba.benefit_action_id = p_benefit_action_id
       And pr.group_pl_id       = ba.pl_id
       And pr.pl_id             = pr.group_pl_id
       --
       And ep.per_in_ler_id     = pr.group_per_in_ler_id
       And ep.request_id        = ba.request_id
       And ep.pl_id             = pr.group_pl_id
       And ep.person_id         = pr.person_id
       And pr.lf_evt_ocrd_dt between ep.effective_start_date and ep.effective_end_date
       --
       And epo.elig_per_id      = ep.elig_per_id
       And epo.request_id       = ba.request_id
       And pr.lf_evt_ocrd_dt between epo.effective_start_date and epo.effective_end_date
       --
       And sr.benefit_action_id = ba.benefit_action_id
       And sr.elig_per_opt_id   = epo.elig_per_opt_id
       And pr.lf_evt_ocrd_dt between sr.effective_start_date and sr.effective_end_date
       --
     Group by pr.group_pl_id,  pr.lf_evt_ocrd_dt,pr.person_id, pr.assignment_id);
--
    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
**/
  END compute_score_for_CWB;
--

 -- ---------------------------------------------------------------------------
 -- ------------- <Compute_Total_Score> ---------------------------------------
 -- ---------------------------------------------------------------------------
  PROCEDURE compute_total_score (
       p_benefit_action_id IN NUMBER,
       p_module            IN VARCHAR2,
       p_per_in_ler_id     IN NUMBER,
       p_person_id         IN NUMBER,
       p_effective_date    IN DATE ) IS

 l_proc constant varchar2(72):= g_package||'compute_total_score';
  BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
      --
      if (p_module = 'GSP') then
       --
       Declare
         CURSOR csr_pgm IS
           SELECT pgm_id
            FROM  ben_elig_per_elctbl_chc
           WHERE  per_in_ler_id  = p_per_in_ler_id
             AND  dflt_flag      = 'Y'
             AND  rownum         < 2;
        --
        l_rank_enabled     varchar2(30);
        l_wf_enabled       varchar2(10);
        l_handle_duplicate varchar2(30);
        l_group_score      varchar2(30);
        l_result           varchar2(30);
        l_pgm_id           number;
        --
       Begin
         OPEN  csr_pgm;
         FETCH csr_pgm INTO l_pgm_id;
         CLOSE csr_pgm;

         if ( l_pgm_id is null) then
            return;
         end if;

         -- Get Grade ladder setup options
         get_pgi_info (
           p_pgm_id           => l_pgm_id,
           p_workflow_enabled => l_wf_enabled,
           p_rank_enabled     => l_rank_enabled,
           p_handle_duplicate => l_handle_duplicate,
           p_group_score      => l_group_score,
           p_result           => l_result );
          --
          -- Error Handling
          --handle_error(l_result);
          --SR: 4626343.992, if grade created manually, or old grades, won't
          -- have extra information record, return without performaing any
          -- action in such cases.
          --
          -- No computing required if ranking is not enabled.
          IF ( l_result = 'PGI_SETUP_NOT_FOUND' OR l_rank_enabled <> 'Y') THEN
              Return;
          END IF;
         --
         compute_score_for_GSP(
                p_benefit_action_id => p_benefit_action_id
               ,p_per_in_ler_id     => p_per_in_ler_id
               ,p_person_id         => p_person_id
               ,p_effective_date    => p_effective_date
               ,p_pgm_id            => l_pgm_id
               ,p_handle_duplicate  => l_handle_duplicate
               ,p_group_score       => l_group_score
              );
         --
       End;

      end if;
      --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
  END compute_total_score;

--
Procedure assign_ranks_for_CWB (
        p_benefit_action_id IN NUMBER) IS
--
  CURSOR csr_rnk IS
  SELECT mgr_per_in_ler_id, pi.person_id supervisor_id
  FROM   ben_cwb_group_hrchy gh,
         ben_cwb_person_info pi
  WHERE  gh.lvl_num = 0
    AND  gh.mgr_per_in_ler_id = pi.group_per_in_ler_id;
--
 l_proc constant varchar2(72):= g_package||'assign_ranks_for_cwb';
BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
--
 FOR rec_rnk in csr_rnk
 LOOP
 --
  INSERT into pqh_rank_process_approvals (
      rank_process_approval_id, rank_process_id, supervisor_id,system_rank,
      proposed_rank )
  SELECT pqh_rank_process_approvals_s.NEXTVAL, rank_process_id, supervisor_id, system_rank,
         system_rank
  FROM (
      select rp.rank_process_id, rec_rnk.supervisor_id, rownum system_rank
      from   pqh_rank_processes rp,
             ben_cwb_group_hrchy gh,
             ben_cwb_person_rates pr
      where  gh.mgr_per_in_ler_id   = rec_rnk.mgr_per_in_ler_id
        and  gh.lvl_num             > 0  -- don't include self
        and  pr.group_per_in_ler_id = gh.emp_per_in_ler_id
        and  rp.benefit_action_id   = p_benefit_action_id
        and  rp.assignment_id       = pr.assignment_id
        and  rp.process_date        = pr.lf_evt_ocrd_dt
        and  rp.pl_id               = pr.group_pl_id
       order by rp.total_score desc);
 --
 END LOOP;
--
    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
END assign_ranks_for_CWB;
--
--
 -- ---------------------------------------------------------------------------
 -- ------------- <get_criteria_name> -----------------------------------------
 -- ---------------------------------------------------------------------------
FUNCTION get_criteria_name (p_tab_short_name in varchar2) RETURN VARCHAR2 IS
--
CURSOR csr_crit_nm IS
select trtl.display_name
 from pqh_table_route_tl trtl,
      pqh_table_route tr
where trtl.table_route_id = tr.table_route_id
  and from_clause    = 'OAB'
  and language       = userenv('lang')
  and tr.table_alias = p_tab_short_name;
--
 l_crit_name pqh_table_route_tl.display_name%Type;
--

 l_proc constant varchar2(72):= g_package||'get_criteria_name';
BEGIN

    hr_utility.set_location('Entering:'||l_proc, 5);
--
   OPEN csr_crit_nm;
   FETCH csr_crit_nm INTO l_crit_name;
   CLOSE csr_crit_nm;
--
  RETURN l_crit_name;
--
--
    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
    WHEN Others THEN
        raise;
END get_criteria_name;


END; -- Package Body PQH_RANKING

/
