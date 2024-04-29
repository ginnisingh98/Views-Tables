--------------------------------------------------------
--  DDL for Package Body HR_RUNGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RUNGEN" as
/* $Header: pyrungen.pkb 115.12 2002/12/09 15:12:28 divicker ship $ */
--
  TYPE number_tbl IS TABLE OF NUMBER INDEX BY binary_integer;
--
  TYPE asg_sets_type IS RECORD
  (
    set_id                      number_tbl,
    sz                          INTEGER
  );
--
  g_sepcheck_asg_sets        asg_sets_type;
  g_taxsep_asg_sets        asg_sets_type;
--
PROCEDURE setup_taxsep_asg_sets(
                 p_process_name                  IN VARCHAR2,
                 p_primary_action_id             IN NUMBER,
                 p_payact_earned_date            IN VARCHAR2,
                 p_business_group_id             IN NUMBER,
                 p_payroll_id                    IN NUMBER
                )
IS
--
CURSOR  get_asg_ids (p_pyrll_action_id  NUMBER) IS
  SELECT        ASA.assignment_id
  FROM          pay_assignment_actions  ASA
  WHERE ASA.payroll_action_id   = p_pyrll_action_id
  AND           ASA.action_status       = 'C';
--
l_set_name        VARCHAR2(80);
l_master_set_name VARCHAR2(80);
l_taxsep_count    NUMBER;
l_dednproc_count  NUMBER;
l_dp_nots_count   NUMBER;
l_tsdp_count      NUMBER;
l_ts_counter      NUMBER;
l_ts_asg_set_id   NUMBER;
--
BEGIN
-- Initialise cache
  --
  g_taxsep_asg_sets.sz := 0;
  -- RUN or RETRY mode...
--  IF p_process_name = 'RUN' THEN
--
     l_master_set_name := 'Run Gen '||p_primary_action_id||'_TSDP ASG Set_';
--
     for asgrec in get_asg_ids(p_primary_action_id) loop
        --
        -- OK how many Additional Runs are needed?
        --
        -- G1188 (03-Aug-1994):
        -- Need to look for entries where 'Tax Separately' = 'Y' AND
        -- 'Separate Check' = 'N'.
        -- Aaaah, this is what G1529 needs.
        -- G1529 also needs to KNOW when a TaxSep = Y and SepCheck = N GTN is
        -- being submitted - in order to set RUN_TYPE = 'TAXSEP' for proper
        -- tax calculation by VERTEX; and also for proper setting of
        -- consolidation set on these GTNs and submission of Pre-Payments
        -- process for SepCheck GTNs only. See below.
        --
        SELECT      COUNT(ELE.element_entry_id)
        INTO        l_taxsep_count
        FROM        pay_element_entries_f           ELE,
                    pay_element_entry_values_f      EEV,
                    pay_input_values_f              IPV
        WHERE       ELE.assignment_id               = asgrec.assignment_id
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE.effective_start_date
                                                AND ELE.effective_end_date
        AND         EEV.element_entry_id            = ELE.element_entry_id
        AND         NVL(EEV.screen_entry_value,'N') = 'Y'
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV.effective_start_date
                                                AND EEV.effective_end_date
        AND         IPV.input_value_id              = EEV.input_value_id
        AND         UPPER(IPV.name)                 = 'TAX SEPARATELY'
        AND EXISTS (SELECT 'x'
                    FROM    pay_element_entries_f           ELE2,
                            pay_element_entry_values_f      EEV2,
                            pay_input_values_f              IPV2
                    WHERE   ELE2.assignment_id
                                      = asgrec.assignment_id
                    AND     ELE2.element_entry_id
                                         = ELE.element_entry_id
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE2.effective_start_date
                                                AND ELE2.effective_end_date
                    AND     EEV2.element_entry_id
                                         = ELE2.element_entry_id
                    AND     EEV2.screen_entry_value         = 'N'
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV2.effective_start_date
                                                AND EEV2.effective_end_date
                    AND     IPV2.input_value_id
                                         = EEV2.input_value_id
                    AND     UPPER(IPV2.name)
                                         = 'SEPARATE CHECK');
        --
        -- Also need to look for entries where 'Tax Separately' = 'N' AND
        -- 'Separate Check' = 'N' AND 'Deduction Processing' is other
        -- than 'A'll.
        --
        SELECT      COUNT(ELE.element_entry_id)
        INTO        l_dednproc_count
        FROM        pay_element_entries_f           ELE,
                    pay_element_entry_values_f      EEV,
                    pay_input_values_f              IPV
        WHERE       ELE.assignment_id               = asgrec.assignment_id
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE.effective_start_date
                                                AND ELE.effective_end_date
        AND         EEV.element_entry_id            = ELE.element_entry_id
        AND         EEV.screen_entry_value          <> 'A'
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV.effective_start_date
                                                AND EEV.effective_end_date
        AND         IPV.input_value_id              = EEV.input_value_id
        AND         UPPER(IPV.name)                 = 'DEDUCTION PROCESSING'
        AND EXISTS (SELECT 'x'
                    FROM    pay_element_entries_f           ELE2,
                            pay_element_entry_values_f      EEV2,
                            pay_input_values_f              IPV2
                    WHERE   ELE2.assignment_id              = asgrec.assignment_id
                    AND     ELE2.element_entry_id
                                     = ELE.element_entry_id
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE2.effective_start_date
                                                AND ELE2.effective_end_date
                    AND     EEV2.element_entry_id
                                     = ELE2.element_entry_id
                    AND     EEV2.screen_entry_value         = 'N'
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV2.effective_start_date
                                                AND EEV2.effective_end_date
                    AND     IPV2.input_value_id
                                     = EEV2.input_value_id
                    AND     UPPER(IPV2.name)                = 'SEPARATE CHECK')
        AND EXISTS (SELECT 'x'
                    FROM    pay_element_entries_f           ELE3,
                            pay_element_entry_values_f      EEV3,
                            pay_input_values_f              IPV3
                    WHERE   ELE3.assignment_id              = asgrec.assignment_id
                    AND     ELE3.element_entry_id
                                     = ELE.element_entry_id
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE3.effective_start_date
                                                AND ELE3.effective_end_date
                    AND     EEV3.element_entry_id
                                     = ELE3.element_entry_id
                    AND     EEV3.screen_entry_value         = 'N'
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV3.effective_start_date
                                                AND EEV3.effective_end_date
                    AND     IPV3.input_value_id
                                     = EEV3.input_value_id
                    AND     UPPER(IPV3.name)
                                     = 'TAX SEPARATELY');
        --
        -- Also need to look for entries where 'Tax Separately' does not exist
        -- (ie. for Regular "Earnings" elements, AND 'Separate Check' = 'N' AND
        -- 'Deduction Processing' is other than 'A'll.
        --
        SELECT      COUNT(ELE.element_entry_id)
        INTO        l_dp_nots_count
        FROM        pay_element_entries_f           ELE,
                    pay_element_entry_values_f      EEV,
                    pay_input_values_f              IPV
        WHERE       ELE.assignment_id               = asgrec.assignment_id
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE.effective_start_date
                                                AND ELE.effective_end_date
        AND         EEV.element_entry_id            = ELE.element_entry_id
        AND         EEV.screen_entry_value          <> 'A'
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV.effective_start_date
                                                AND EEV.effective_end_date
        AND         IPV.input_value_id              = EEV.input_value_id
        AND         UPPER(IPV.name)                 = 'DEDUCTION PROCESSING'
        AND EXISTS (SELECT 'x'
                    FROM    pay_element_entries_f           ELE2,
                            pay_element_entry_values_f      EEV2,
                            pay_input_values_f              IPV2
                    WHERE   ELE2.assignment_id              = asgrec.assignment_id
                    AND     ELE2.element_entry_id
                                   = ELE.element_entry_id
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE2.effective_start_date
                                                AND ELE2.effective_end_date
                    AND     EEV2.element_entry_id
                                   = ELE2.element_entry_id
                    AND     EEV2.screen_entry_value         = 'N'
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV2.effective_start_date
                                                AND EEV2.effective_end_date
                    AND     IPV2.input_value_id
                                   = EEV2.input_value_id
                    AND     UPPER(IPV2.name)                = 'SEPARATE CHECK')
        AND NOT EXISTS (SELECT 'x'
                    FROM    pay_element_entries_f           ELE3,
                            pay_element_links_f             ELI3,
                            pay_input_values_f              IPV3
                    WHERE   ELE3.assignment_id              = asgrec.assignment_id
                    AND     ELE3.element_entry_id
                                   = ELE.element_entry_id
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELE3.effective_start_date
                                                AND ELE3.effective_end_date
                    AND     ELI3.element_link_id
                                   = ELE3.element_link_id
                    AND     fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN ELI3.effective_start_date
                                                AND ELI3.effective_end_date
                    AND     IPV3.element_type_id
                                   = ELI3.element_type_id
                    AND     UPPER(IPV3.name)
                                   = 'TAX SEPARATELY');
--
        l_tsdp_count := l_taxsep_count + l_dednproc_count + l_dp_nots_count;
        --
        if (l_tsdp_count <> 0) then
           for l_ts_counter in 1..l_tsdp_count loop
              if l_ts_counter > g_taxsep_asg_sets.sz then
                --
                -- OK we need to insert a new assignment set.
                --
                l_set_name := l_master_set_name||l_ts_counter;
                --
                SELECT        hr_assignment_sets_s.nextval
                INTO          l_ts_asg_set_id
                FROM          sys.dual;
                --
                INSERT INTO   hr_assignment_sets (
                               ASSIGNMENT_SET_ID
                              ,BUSINESS_GROUP_ID
                              ,PAYROLL_ID
                              ,ASSIGNMENT_SET_NAME)
                VALUES (       l_ts_asg_set_id
                              ,p_business_group_id
                              ,p_payroll_id
                              ,l_set_name);
                --
                -- Set the entry in the Set cache
                g_taxsep_asg_sets.sz := l_ts_counter;
                g_taxsep_asg_sets.set_id(l_ts_counter)
                                                  := l_ts_asg_set_id;
              end if;
              --
              -- Now add this assignment to the appropreate set.
              --
              INSERT INTO hr_assignment_set_amendments
                                     (ASSIGNMENT_ID
                                     ,ASSIGNMENT_SET_ID
                                     ,INCLUDE_OR_EXCLUDE
                                     )
              VALUES
                    (     asgrec.assignment_id
                         ,g_taxsep_asg_sets.set_id(l_ts_counter)
                         ,'I'
                    );
           end loop;
        end if;
     end loop;
--  END IF;
--
END setup_taxsep_asg_sets;
--
PROCEDURE setup_sepcheck_asg_sets(
                 p_process_name                  IN VARCHAR2,
                 p_primary_action_id             IN NUMBER,
                 p_payact_earned_date            IN VARCHAR2,
                 p_business_group_id             IN NUMBER,
                 p_payroll_id                    IN NUMBER
                )
IS
--
CURSOR  get_asg_ids (p_pyrll_action_id  NUMBER) IS
  SELECT        ASA.assignment_id
  FROM          pay_assignment_actions  ASA
  WHERE ASA.payroll_action_id   = p_pyrll_action_id
  AND           ASA.action_status       = 'C';
--
l_set_name        VARCHAR2(80);
l_master_set_name VARCHAR2(80);
l_sc_count        NUMBER;
l_sc_counter      NUMBER;
l_sc_asg_set_id   NUMBER;
--
BEGIN
-- Initialise cache
  --
  g_sepcheck_asg_sets.sz := 0;
  -- RUN or RETRY mode...
--  IF p_process_name = 'RUN' THEN
--
     l_master_set_name := 'Run Gen '||p_primary_action_id||' SC ASG Set_';
--
     for asgrec in get_asg_ids(p_primary_action_id) loop
        --
        -- OK how many Separate Checks does this guy have?
        --
        --
        SELECT      COUNT(ELE.element_entry_id)
        INTO        l_sc_count
        FROM        pay_element_entries_f           ELE,
                    pay_element_entry_values_f      EEV,
                    pay_input_values_f              IPV
        WHERE       ELE.assignment_id               = asgrec.assignment_id
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                        BETWEEN ELE.effective_start_date
                                        AND ELE.effective_end_date
        AND         EEV.element_entry_id            = ELE.element_entry_id
        AND         NVL(EEV.screen_entry_value,'N') = 'Y'
        AND         fnd_date.canonical_to_date(p_payact_earned_date)
                                            BETWEEN EEV.effective_start_date
                                            AND EEV.effective_end_date
        AND         IPV.input_value_id              = EEV.input_value_id
        AND         UPPER(IPV.name)         = 'SEPARATE CHECK';
        --
        if (l_sc_count <> 0) then
           for l_sc_counter in 1..l_sc_count loop
              if l_sc_counter > g_sepcheck_asg_sets.sz then
                --
                -- OK we need to insert a new assignment set.
                --
                l_set_name := l_master_set_name||l_sc_counter;
                --
                SELECT        hr_assignment_sets_s.nextval
                INTO          l_sc_asg_set_id
                FROM          sys.dual;
                --
                INSERT INTO   hr_assignment_sets (
                               ASSIGNMENT_SET_ID
                              ,BUSINESS_GROUP_ID
                              ,PAYROLL_ID
                              ,ASSIGNMENT_SET_NAME)
                VALUES (       l_sc_asg_set_id
                              ,p_business_group_id
                              ,p_payroll_id
                              ,l_set_name);
                --
                -- Set the entry in the Set cache
                g_sepcheck_asg_sets.sz := l_sc_counter;
                g_sepcheck_asg_sets.set_id(l_sc_counter)
                                                  := l_sc_asg_set_id;
              end if;
              --
              -- Now add this assignment to the appropreate set.
              --
              INSERT INTO hr_assignment_set_amendments
                                     (ASSIGNMENT_ID
                                     ,ASSIGNMENT_SET_ID
                                     ,INCLUDE_OR_EXCLUDE
                                     )
              VALUES
                    (     asgrec.assignment_id
                         ,g_sepcheck_asg_sets.set_id(l_sc_counter)
                         ,'I'
                    );
           end loop;
        end if;
     end loop;
--  END IF;
--
END setup_sepcheck_asg_sets;
--
procedure perform_run (p_payroll_id            in number,
                       p_consolidation_set_id  in number,
                       p_earned_date           in varchar2,
                       p_date_paid           in varchar2,
                       p_ele_set_id            in number,
                       p_assignment_set_id     in number,
                       p_leg_params            in varchar2,
                       p_req_id            in out nocopy number,
                       p_success              out nocopy boolean,
                       errbuf                 out nocopy varchar2)
--
is
l_wait_outcome          BOOLEAN;
l_phase                 VARCHAR2(80);
l_status                VARCHAR2(80);
l_dev_phase             VARCHAR2(80);
l_dev_status            VARCHAR2(80);
l_message               VARCHAR2(80);
l_errbuf                VARCHAR2(240);
--
begin

  p_req_id := fnd_request.submit_request(
                            application    => 'PAY',
                            program        => 'PAYROLL_RUN_GENERIC',
                            argument1      => 'RUN',
                            argument2      => p_payroll_id,
                            argument3      => p_consolidation_set_id,
                            argument4      => p_earned_date,
                            argument5      => p_date_paid,
                            argument6      => p_ele_set_id,
                            argument7      => p_assignment_set_id,
                            argument8      => p_leg_params);

  IF p_req_id = 0 THEN
     p_success := FALSE;
     fnd_message.retrieve(l_errbuf);
     hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
     raise zero_req_id;
  ELSE
    --
    COMMIT;
    --
    l_wait_outcome := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                         request_id     => p_req_id,
                                         interval       => 2,
                                         phase          => l_phase,
                                         status         => l_status,
                                         dev_phase      => l_dev_phase,
                                         dev_status     => l_dev_status,
                                         message        => l_message);
--
    p_success := TRUE;
  END IF;

  errbuf := l_errbuf;

exception
  when zero_req_id then
    raise;
  when others then
    p_success := FALSE;
    l_errbuf := SQLERRM;
    errbuf := l_errbuf;
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);

end perform_run;
--
procedure perform_retry (p_payroll_act_id        in number,
                         p_req_id            in out nocopy number,
                         p_success              out nocopy boolean,
                         errbuf                 out nocopy varchar2)
--
is
l_wait_outcome          BOOLEAN;
l_phase                 VARCHAR2(80);
l_status                VARCHAR2(80);
l_dev_phase             VARCHAR2(80);
l_dev_status            VARCHAR2(80);
l_message               VARCHAR2(80);
l_errbuf                VARCHAR2(240);
--
begin
  declare
    dummy number;
  begin
--
    select 1
      into dummy
      from sys.dual
     where exists (select ''
                     from pay_assignment_actions
                    where payroll_action_id = p_payroll_act_id
                      and action_status <> 'C');
--
    p_req_id := fnd_request.submit_request(
                            application    => 'PAY',
                            program        => 'RETRY-RUN',
                            argument1      => 'RERUN',
                            argument2      => p_payroll_act_id
                           );
    IF p_req_id = 0 THEN
       p_success := FALSE;
       fnd_message.retrieve(l_errbuf);
       raise zero_req_id;
    ELSE
      --
      COMMIT;
      l_wait_outcome := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                           request_id     => p_req_id,
                                           interval       => 2,
                                           phase          => l_phase,
                                           status         => l_status,
                                           dev_phase      => l_dev_phase,
                                           dev_status     => l_dev_status,
                                           message        => l_message);
--
       p_success := TRUE;
    END IF;
--
    errbuf := l_errbuf;

 exception
    when no_data_found then
      hr_utility.trace('No non-completed assignment actions for this payroll action');
    when zero_req_id then
      raise;
    when others then
      p_success := FALSE;
      l_errbuf := SQLERRM;
      errbuf := l_errbuf;
      hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);
 end;

end perform_retry;
--
procedure perform_prepay (p_payroll_id            in number,
                       p_consolidation_set_id  in number,
                       p_date_paid           in varchar2,
                       p_req_id            in out nocopy number,
                       p_success              out nocopy boolean,
                       errbuf                 out nocopy varchar2)
--
is
l_wait_outcome          BOOLEAN;
l_phase                 VARCHAR2(80);
l_status                VARCHAR2(80);
l_dev_phase             VARCHAR2(80);
l_dev_status            VARCHAR2(80);
l_message               VARCHAR2(80);
l_errbuf                VARCHAR2(240);
--
begin
  p_req_id := fnd_request.submit_request(
                          application    => 'PAY',
                          program        => 'PREPAY',
                          argument1      => 'PREPAY',
                          argument2      => p_payroll_id,
                          argument3      => p_consolidation_set_id,
                          argument4      => p_date_paid,
                          argument5      => p_date_paid,
                          argument6      => NULL);
  IF p_req_id = 0 THEN
     p_success := FALSE;
     fnd_message.retrieve(l_errbuf);
     raise zero_req_id;
  ELSE
    --
    COMMIT;
    l_wait_outcome := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                         request_id     => p_req_id,
                                         interval       => 2,
                                         phase          => l_phase,
                                         status         => l_status,
                                         dev_phase      => l_dev_phase,
                                         dev_status     => l_dev_status,
                                         message        => l_message);
--
    p_success := TRUE;
  END IF;

  errbuf := l_errbuf;

exception
  when zero_req_id then
    raise;
  when others then
    p_success := FALSE;
    l_errbuf := SQLERRM;
    errbuf := l_errbuf;
    hr_utility.trace('Error when submitting request: ' || SQLERRM || ' ' || SQLCODE);

end perform_prepay;
--
procedure delete_sepcheck_asg_set
is
l_num_sepchecks number;
l_sc_counter    number;
begin
--
   l_num_sepchecks := g_sepcheck_asg_sets.sz;
--
   for l_sc_counter in 1..l_num_sepchecks loop
--
       delete from hr_assignment_set_amendments
        where ASSIGNMENT_SET_ID = g_sepcheck_asg_sets.set_id(l_sc_counter);
--
       delete from hr_assignment_sets
        where ASSIGNMENT_SET_ID = g_sepcheck_asg_sets.set_id(l_sc_counter);
--
   end loop;
end delete_sepcheck_asg_set;
--
procedure delete_taxsep_asg_set
is
l_num_taxsep number;
l_ts_counter    number;
begin
--
   l_num_taxsep := g_taxsep_asg_sets.sz;
--
   for l_ts_counter in 1..l_num_taxsep loop
--
       delete from hr_assignment_set_amendments
        where ASSIGNMENT_SET_ID = g_taxsep_asg_sets.set_id(l_ts_counter);
--
       delete from hr_assignment_sets
        where ASSIGNMENT_SET_ID = g_taxsep_asg_sets.set_id(l_ts_counter);
--
   end loop;
end delete_taxsep_asg_set;
--
procedure retry_taxsep(
                p_primary_action_id             IN NUMBER,
                p_payroll_id                    IN NUMBER,
                p_master_con_set_id             IN NUMBER,
                p_date_paid                     IN VARCHAR2,
                p_runs_reprocessed          IN OUT NOCOPY NUMBER
                        )
is

l_errbuf varchar2(240);
--
cursor retactions is
   select payroll_action_id
     from pay_payroll_actions
    where target_payroll_action_id = p_primary_action_id
      and payroll_id = p_payroll_id
      and action_type = 'R'
      and effective_date = fnd_date.canonical_to_date(p_date_paid)
      and legislative_parameters like '%SPECIALPROC%'
    order by action_sequence;
--
l_req_id                number;
l_success               boolean;
--
begin
--
    for actrec in retactions loop
--
       p_runs_reprocessed := p_runs_reprocessed + 1;
--
       perform_retry(actrec.payroll_action_id,
                     l_req_id,
                     l_success,
                     l_errbuf);
--
    end loop;
--
end retry_taxsep;
--
procedure retry_sepcheck(
                p_primary_action_id             IN NUMBER,
                p_payroll_id                    IN NUMBER,
                p_master_con_set_id             IN NUMBER,
                p_sc_con_set_id                 IN NUMBER,
                p_date_paid                     IN VARCHAR2,
                p_runs_reprocessed          IN OUT NOCOPY NUMBER
                        )
is
--
cursor retactions is
   select payroll_action_id
     from pay_payroll_actions
    where target_payroll_action_id = p_primary_action_id
      and payroll_id = p_payroll_id
      and action_type = 'R'
      and effective_date = fnd_date.canonical_to_date(p_date_paid)
      and legislative_parameters like '%SEPCHECK%'
    order by action_sequence;
--
l_req_id                number;
l_success               boolean;
l_prepay_id             number;
l_sc_preact_id          number;
l_errbuf                varchar2(240);
--
begin
--
    for actrec in retactions loop
--
       p_runs_reprocessed := p_runs_reprocessed + 1;
--
       perform_retry(actrec.payroll_action_id,
                     l_req_id,
                     l_success,
                     l_errbuf);
--
       -- OK now deal with the pre payment
       begin
--
         select distinct asg2.payroll_action_id
           into l_prepay_id
           from pay_assignment_actions asg2,
                pay_action_interlocks  pai,
                pay_payroll_actions    ppa,
                pay_assignment_actions asg1
          where asg1.payroll_action_id = actrec.payroll_action_id
            and asg1.assignment_action_id = pai.locked_action_id
            and asg2.assignment_action_id = pai.locking_action_id
            and ppa.payroll_action_id = asg2.payroll_action_id
            and ppa.action_type = 'P';
--
         perform_retry(l_prepay_id,
                       l_req_id,
                       l_success,
                       l_errbuf);
--
       exception
           when no_data_found then
--
--         Wow, the prepayment has been rolled back.
--
           update pay_payroll_actions
              set consolidation_set_id = p_sc_con_set_id
            where payroll_action_id = actrec.payroll_action_id;
--
           commit;
--
           perform_prepay (p_payroll_id,
                           p_sc_con_set_id,
                           p_date_paid,
                           l_req_id,
                           l_success,
                           l_errbuf);
--
           SELECT    payroll_action_id
           INTO      l_sc_preact_id
           FROM      pay_payroll_actions
           WHERE     request_id = l_req_id
             AND     payroll_id = p_payroll_id
             AND     action_type = 'P'
             AND     effective_date = fnd_date.canonical_to_date(p_date_paid);
--
           update pay_payroll_actions
              set consolidation_set_id = p_master_con_set_id
            where payroll_action_id = actrec.payroll_action_id;
--
           update pay_payroll_actions
              set consolidation_set_id = p_master_con_set_id,
                  target_payroll_action_id = p_primary_action_id
            where payroll_action_id = l_sc_preact_id;
--
           commit;
--
       end;
--
    end loop;
--
end retry_sepcheck;
--
PROCEDURE  do_sep_check(
                p_process_name                  IN VARCHAR2,
                p_primary_action_id             IN NUMBER,
                p_payroll_id                    IN NUMBER,
                p_consolidation_set_id          IN NUMBER,
                p_earned_date                   IN VARCHAR2,
                p_date_paid                     IN VARCHAR2,
                p_assignment_set_id             IN NUMBER,
                p_ele_set_id                    IN NUMBER,
                p_leg_params                    IN VARCHAR2,
                p_business_group_id             IN NUMBER,
                p_pay_advice_message            IN VARCHAR2)
IS
l_num_sepchecks         number;
l_sc_counter            number;
l_req_id                number;
l_success               boolean;
l_sc_consoset_name      VARCHAR2(60);
l_sc_consoset_id        number;
l_sc_payact_id          number;
l_sc_preact_id          number;
l_reprocessed_runs      number;
l_errbuf                varchar2(240);
BEGIN
   setup_sepcheck_asg_sets (
                 p_process_name,
                 p_primary_action_id,
                 p_earned_date,
                 p_business_group_id,
                 p_payroll_id
                );
--
   l_num_sepchecks := g_sepcheck_asg_sets.sz;
--
   if (l_num_sepchecks <> 0) then
--
     -- Create new consolidation set
--
      l_sc_consoset_name := 'Separate Check Consolidation';
--
      SELECT        pay_consolidation_sets_s.nextval
      INTO          l_sc_consoset_id
      FROM          sys.dual;
--
      INSERT INTO   pay_consolidation_sets (
                    CONSOLIDATION_SET_ID,
                    BUSINESS_GROUP_ID,
                    CONSOLIDATION_SET_NAME)
      VALUES (      l_sc_consoset_id,
                    p_business_group_id,
                    l_sc_consoset_name);
--
      commit;
      --
      -- RUN or RETRY mode...
      --
      l_reprocessed_runs := 1;
--
      if p_process_name = 'RERUN' then
--
          retry_sepcheck(
                p_primary_action_id,
                p_payroll_id,
                p_consolidation_set_id,
                l_sc_consoset_id,
                p_date_paid,
                l_reprocessed_runs
          );
--
      end if;
      --
      -- Now do the payroll runs
      --
      for l_sc_counter in l_reprocessed_runs..l_num_sepchecks loop
          perform_run (p_payroll_id,
                       l_sc_consoset_id,
                       p_earned_date,
                       p_date_paid,
                       p_ele_set_id,
                       g_sepcheck_asg_sets.set_id(l_sc_counter),
                       p_leg_params,
                       l_req_id,
                       l_success,
                       l_errbuf);
--
          SELECT    payroll_action_id
          INTO      l_sc_payact_id
          FROM      pay_payroll_actions
          WHERE     request_id = l_req_id
            AND     payroll_id = p_payroll_id
            AND     action_type = 'R'
            AND     effective_date = fnd_date.canonical_to_date(p_date_paid);
--
          perform_prepay (p_payroll_id,
                          l_sc_consoset_id,
                          p_date_paid,
                          l_req_id,
                          l_success,
                          l_errbuf);
--
          SELECT    payroll_action_id
          INTO      l_sc_preact_id
          FROM      pay_payroll_actions
          WHERE     request_id = l_req_id
            AND     payroll_id = p_payroll_id
            AND     action_type = 'P'
            AND     effective_date = fnd_date.canonical_to_date(p_date_paid);
--
         -- Update the actions with the new details.
         UPDATE   pay_payroll_actions
         SET      consolidation_set_id        = p_consolidation_set_id,
                  assignment_set_id           = NULL,
                  target_payroll_action_id    = p_primary_action_id
         WHERE    payroll_action_id           = l_sc_payact_id;
--
         UPDATE   pay_payroll_actions
         SET      consolidation_set_id        = p_consolidation_set_id,
                  target_payroll_action_id    = p_primary_action_id
         WHERE    payroll_action_id           = l_sc_preact_id;
--
         commit;
--
      end loop;
--
      DELETE from pay_consolidation_sets
       WHERE consolidation_set_id = l_sc_preact_id;
--
      delete_sepcheck_asg_set;
--
      COMMIT;
--
   end if;
END do_sep_check;
--
PROCEDURE  do_tax_sep(
                p_process_name                  IN VARCHAR2,
                p_primary_action_id             IN NUMBER,
                p_payroll_id                    IN NUMBER,
                p_consolidation_set_id          IN NUMBER,
                p_earned_date                   IN VARCHAR2,
                p_date_paid                     IN VARCHAR2,
                p_assignment_set_id             IN NUMBER,
                p_ele_set_id                    IN NUMBER,
                p_leg_params                    IN VARCHAR2,
                p_business_group_id             IN NUMBER,
                p_pay_advice_message            IN VARCHAR2)
IS
l_req_id                number;
l_success               boolean;
l_ts_payact_id          number;
l_num_taxsep            number;
l_reprocessed_runs      number;
l_errbuf                varchar2(240);
BEGIN
   setup_taxsep_asg_sets (
                 p_process_name,
                 p_primary_action_id,
                 p_earned_date,
                 p_business_group_id,
                 p_payroll_id
                );
--
   l_num_taxsep := g_taxsep_asg_sets.sz;
--
   commit;
--
   if (l_num_taxsep <> 0) then
--
      l_reprocessed_runs := 1;
--
      if p_process_name = 'RERUN' then
--
          retry_taxsep(
                p_primary_action_id,
                p_payroll_id,
                p_consolidation_set_id,
                p_date_paid,
                l_reprocessed_runs
          );
--
      end if;
      --
      -- Now do the payroll runs
      --
      for l_ts_counter in l_reprocessed_runs..l_num_taxsep loop
          perform_run (p_payroll_id,
                       p_consolidation_set_id,
                       p_earned_date,
                       p_date_paid,
                       p_ele_set_id,
                       g_taxsep_asg_sets.set_id(l_ts_counter),
                       p_leg_params,
                       l_req_id,
                       l_success,
                       l_errbuf);
--
--
          SELECT    payroll_action_id
          INTO      l_ts_payact_id
          FROM      pay_payroll_actions
          WHERE     request_id = l_req_id
            AND     payroll_id = p_payroll_id
            AND     action_type = 'R'
            AND     effective_date = fnd_date.canonical_to_date(p_date_paid);
--
         -- Update the actions with the new details.
         UPDATE   pay_payroll_actions
         SET      assignment_set_id           = NULL,
                  target_payroll_action_id    = p_primary_action_id
         WHERE    payroll_action_id           = l_ts_payact_id;
--
         commit;
--
      end loop;
--
      delete_taxsep_asg_set;
--
      COMMIT;
--
   end if;
END do_tax_sep;
--
PROCEDURE generate_runs (
                ERRBUF                          OUT NOCOPY VARCHAR2,
                RETCODE                         OUT NOCOPY NUMBER,
                p_process_name                  IN VARCHAR2     default 'RUN',
                p_pay_action_id                 IN NUMBER       default NULL,
                p_payroll_id                    IN NUMBER       default NULL,
                p_consolidation_set_id          IN NUMBER       default NULL,
                p_earned_date                   IN VARCHAR2     default NULL,
                p_date_paid                     IN VARCHAR2     default NULL,
                p_assignment_set_id             IN NUMBER       default NULL,
                p_ele_set_id                    IN NUMBER       default NULL,
                p_leg_params                    IN VARCHAR2     default 'R',
                p_pay_advice_message            IN VARCHAR2     default NULL)
IS
l_leg_params            VARCHAR2(240);
l_business_group_id     NUMBER;
l_payact_id             NUMBER;
l_req_id                NUMBER;
l_success               BOOLEAN;
l_primary_action        NUMBER;
l_payroll_id            NUMBER;
l_consolidation_set_id  NUMBER;
l_earned_date           VARCHAR2(20);
l_date_paid             VARCHAR2(20);
l_assignment_set_id     NUMBER;
l_ele_set_id            NUMBER;
l_errbuf                VARCHAR2(240);
--
BEGIN
--
  l_errbuf := '';
  fnd_message.set_name('PAY', 'HR_9999_ZERO_REQUEST_ID');

  -- RUN or RETRY mode...
  IF p_process_name = 'RUN' THEN
    --
    -- Get processing period dates for primary GTN:
    --
    IF p_leg_params IS NULL THEN
      l_leg_params := 'R';
    ELSE
      l_leg_params := substr(p_leg_params,1,1);
    END IF;
    --
    SELECT DISTINCT business_group_id
    INTO          l_business_group_id
    FROM          pay_payrolls_f
    WHERE         payroll_id = p_payroll_id;
    --
    -- Submit primary GTN:
    --
    hr_utility.set_location('hr_rungen - SUBMITTING PRIMARY GTN', 11);
    hr_utility.set_location('earned date = '||p_earned_date, 11);
    hr_utility.set_location('paid date = '||p_date_paid, 11);
    --
    perform_run (p_payroll_id,
                 p_consolidation_set_id,
                 p_earned_date,
                 p_date_paid,
                 p_ele_set_id,
                 p_assignment_set_id,
                 l_leg_params,
                 l_req_id,
                 l_success,
                 l_errbuf);
    --
    -- Need to get payroll_action_id of primary GTN just submitted.
    --
    SELECT        payroll_action_id
    INTO          l_payact_id
    FROM          pay_payroll_actions
    WHERE request_id = l_req_id
      AND payroll_id = p_payroll_id
      AND action_type = 'R'
      AND effective_date = fnd_date.canonical_to_date(p_date_paid);
--
    l_primary_action := l_payact_id;
--
    -- Update payroll action with pay advice message.
    IF p_pay_advice_message IS NOT NULL THEN
--
      UPDATE      pay_payroll_actions
      SET         pay_advice_message      = p_pay_advice_message
      WHERE       payroll_action_id       = l_payact_id;
--
    END IF;
--
    l_payroll_id := p_payroll_id;
    l_consolidation_set_id := p_consolidation_set_id;
    l_earned_date := p_earned_date;
    l_date_paid := p_date_paid;
    l_assignment_set_id := p_assignment_set_id;
    l_ele_set_id := p_ele_set_id;
--
  ELSE -- Retry
    l_primary_action := p_pay_action_id;
--
    select payroll_id,
           consolidation_set_id,
           fnd_date.canonical_to_date(date_earned),
           fnd_date.canonical_to_date(effective_date),
           assignment_set_id,
           element_set_id,
           business_group_id
      into l_payroll_id,
           l_consolidation_set_id,
           l_earned_date,
           l_date_paid,
           l_assignment_set_id,
           l_ele_set_id,
           l_business_group_id
      from pay_payroll_actions
     where payroll_action_id = l_primary_action;
--
    perform_retry(l_primary_action,
                  l_req_id,
                  l_success,
                  l_errbuf);

  END IF;
--
  l_leg_params := 'SEPCHECK';
--
  do_sep_check(
                p_process_name,
                l_primary_action,
                l_payroll_id,
                l_consolidation_set_id,
                l_earned_date,
                l_date_paid,
                l_assignment_set_id,
                l_ele_set_id,
                l_leg_params,
                l_business_group_id,
                p_pay_advice_message);
--
  l_leg_params := 'SPECIALPROC';
--
  do_tax_sep(
                p_process_name,
                l_primary_action,
                l_payroll_id,
                l_consolidation_set_id,
                l_earned_date,
                l_date_paid,
                l_assignment_set_id,
                l_ele_set_id,
                l_leg_params,
                l_business_group_id,
                p_pay_advice_message);

  errbuf := l_errbuf;

  EXCEPTION
    WHEN zero_req_id THEN
      hr_utility.set_location('hr_rungen - No req ID', 100);
      errbuf := l_errbuf;
      fnd_message.raise_error;
    WHEN OTHERS THEN
      NULL;
--
--
END generate_runs;
--
PROCEDURE Del_Asg_Amends (p_assignment_set_id   IN NUMBER) IS
--
BEGIN
--
  hr_utility.set_location('hr_rungen.Del_Asg_Amends', 7);
/*
  UPDATE        pay_payroll_actions
  SET           assignment_set_id = NULL
  WHERE         assignment_set_id = p_assignment_set_id;
*/
  --
  hr_utility.set_location('hr_rungen.Del_Asg_Amends', 11);
  DELETE FROM   hr_assignment_set_amendments
  WHERE         assignment_set_id       = p_assignment_set_id;
--
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
--
END Del_Asg_Amends;
--
END hr_rungen;

/
