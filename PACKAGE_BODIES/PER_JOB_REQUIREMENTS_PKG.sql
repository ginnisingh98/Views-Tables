--------------------------------------------------------
--  DDL for Package Body PER_JOB_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_REQUIREMENTS_PKG" as
/* $Header: pejbr01t.pkb 115.1 99/07/18 13:55:06 porting ship $ */
--
procedure get_next_sequence(p_job_requirement_id in out number) is
--
cursor c1 is select per_job_requirements_s.nextval
	     from sys.dual;
--
begin
  --
  -- Retrieve the next sequence number for job_requirement_id
  --
  if (p_job_requirement_id is null) then
    open c1;
    fetch c1 into p_job_requirement_id;
    if (C1%NOTFOUND) then
       CLOSE C1;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','get_next_sequence');
       hr_utility.set_message_token('STEP','1');
    end if;
    close c1;
  end if;
  --
  hr_utility.set_location('PER_JOB_REQUIREMENTS_PKG.get_next_sequence', 1);
  --
end get_next_sequence;
--
procedure check_unique_requirement(p_job_id                 in number,
				   p_analysis_criteria_id   in number,
				   p_rowid                  in varchar2) is
--
cursor csr_requirement is select null
		  from   per_job_requirements pjr
		  where  ((p_rowid is not null and
			  rowidtochar(rowid) <> p_rowid    )
		  or      p_rowid is null)
		  and    pjr.job_id = p_job_id
		  and    pjr.analysis_criteria_id = p_analysis_criteria_id;
--
g_dummy_number number;
v_not_unique boolean := FALSE;
--
begin
  --
  -- Check the requirement name is unique
  --
  open csr_requirement;
  fetch csr_requirement into g_dummy_number;
  v_not_unique := csr_requirement%FOUND;
  close csr_requirement;
  --
  if v_not_unique then
    hr_utility.set_message(801,'HR_6644_JOB_REQ_DUP');
    hr_utility.raise_error;
  end if;
--
hr_utility.set_location('PER_JOB_REQUIREMENTS_PKG.check_unique_requirement', 1);
--
end check_unique_requirement;
--
END PER_JOB_REQUIREMENTS_PKG;

/
