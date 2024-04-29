--------------------------------------------------------
--  DDL for Package Body PER_JOB_EVALUATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_EVALUATIONS_PKG" as
/* $Header: pejbe01t.pkb 115.1 99/07/18 13:54:54 porting ship $ */
--
procedure system_measured_name(p_system_name      in out varchar2,
			       p_system           in     varchar2,
			       p_measured_in_name in out varchar2,
			       p_measured_in      in     varchar2) is
--
cursor csr_system is select meaning
		     from   hr_lookups
		     where  lookup_type = 'EVAL_SYSTEM'
		     and    lookup_code = p_system;
--
cursor csr_measured is select meaning
   		       from   hr_lookups
		       where  lookup_type = 'EVAL_SYSTEM_MEAS'
		       and    lookup_code = p_measured_in;
--
begin
  --
  -- Retrieve the system name
  --
    open csr_system;
    fetch csr_system into p_system_name;
    if (CSR_SYSTEM%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','system_measured_name');
       hr_utility.set_message_token('STEP','1');
    end if;
    close csr_system;
    --
    -- Retrieve the measured in name
    --
    open csr_measured;
    fetch csr_measured into p_measured_in_name;
    if (CSR_MEASURED%NOTFOUND) then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','system_measured_name');
       hr_utility.set_message_token('STEP','1');
    end if;
    close csr_measured;
    --
    hr_utility.set_location('PER_JOB_EVALUATIONS_PKG.system_measured_name', 1);
    --
end system_measured_name;
--
procedure get_next_sequence(p_job_evaluation_id in out number) is
--
cursor csr_id is select per_job_evaluations_s.nextval
	  from sys.dual;
--
begin
  --
  -- Get the next sequence number for job_avaluation_id
  --
  if (p_job_evaluation_id is null) then
    --
    open csr_id;
    fetch csr_id into p_job_evaluation_id;
    --
    if (csr_id%NOTFOUND) then
       CLOSE csr_id;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','get_next_sequence');
       hr_utility.set_message_token('STEP','1');
    end if;
    --
    close csr_id;
    --
  end if;
  --
  hr_utility.set_location('PER_JOB_EVALUATIONS_PKG.get_next_sequence', 1);
  --
end get_next_sequence;
--
procedure check_evaluation_exists (p_job_id             in     number,
                                   p_position_id        in     number,
                                   p_job_evaluation_id  in     number,
				   p_system             in     varchar2,
				   p_date_evaluated     in     date,
				   p_rowid              in     varchar2,
				   p_evaluation_exists  in out boolean) is
--
cursor csr_evaluation is select null
		 from   per_job_evaluations je
		 where (job_evaluation_id      <> p_job_evaluation_id
	         	or  p_job_evaluation_id is null)
		 and (je.job_id                   = p_job_id or p_job_id is null)
                 and (je.position_id              = p_position_id
                 or  p_position_id is null)
		 and nvl(je.system, 'NO SYSTEM')  = nvl(p_system, 'NO SYSTEM')
                 and je.date_evaluated            = p_date_evaluated;
--
g_dummy_number number;
--
begin
  --
  -- Check there is a duplcate evaluation record
  --
  open csr_evaluation;
  fetch csr_evaluation into g_dummy_number;
  p_evaluation_exists := csr_evaluation%FOUND;
  close csr_evaluation;
  --
  --
  hr_utility.set_location('PER_JOB_EVALUATIONS_PKG.check_evaluation_exists', 1);
  --
end check_evaluation_exists;
--
END PER_JOB_EVALUATIONS_PKG;

/
