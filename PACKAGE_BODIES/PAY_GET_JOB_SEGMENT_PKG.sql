--------------------------------------------------------
--  DDL for Package Body PAY_GET_JOB_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GET_JOB_SEGMENT_PKG" as
/* $Header: pygbjseg.pkb 115.2 2003/01/03 11:21:41 nsugavan noship $ */
--
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +============================================================================
 Name
    PAY_GET_JOB_SEGMENT_PKG
  Purpose
    Function to pass on the value of the job segment selected in Tax Details
    References DFF or blank if no segment is selected. Function is moved here
    to a seperate package to facilitate call to the function in oracle 8.0
    as functions defined in the same package cannot be called in R8.0
--
REM Change List
REM -----------
REM Name          Date        Version Bug     Text
REM ------------- ----------- ------- ------- --------------------------
REM nsugavan      12/24/2002    115.0 2657976 Initial Version
REM nsugavan      12/24/2002    115.1 2657976 Increased l_proc length
REM nsugavan      01/03/2003    115.2 2657976 Modifed Logic to use WNDS
					      and WNDS pragma restrictions
============================================================================*/
--
--
--
-- Globals
--
g_package                CONSTANT VARCHAR2(30) := 'PAY_GET_JOB_SEGMENT_PKG';
--
FUNCTION  get_job_segment(p_organization_id         in hr_organization_information.organization_id%type
                         ,p_job_definition_id       in number
                         ,p_payroll_action_id       in number)
                         return varchar2
IS
--
  l_column_name                 varchar2(30);
  l_segment_count               integer;
  l_enabled_segment_count       integer;
  l_job_name                    varchar2(60);
  l_payroll_action_id           number;
  l_tax_ref                     varchar2(20);
  l_proc                        CONSTANT VARCHAR2(60):= g_package||'get_job_segment';
 --
  cursor CSR_GET_TAX_REF(pactid NUMBER) IS
    select
    substr(pact.legislative_parameters, instr(pact.legislative_parameters,'TAX_REF=')+8, instr(pact.legislative_parameters||' ',' ',instr(pact.legislative_parameters,'TAX_REF=')+8) - instr(pact.legislative_parameters,'TAX_REF=')-8)
    from  pay_payroll_actions pact
    where pact.payroll_action_id = pactid;

 --
  cursor csr_col_name(l_tax_ref VARCHAR2) is
     select upper(job.APPLICATION_COLUMN_NAME)
     from   hr_organization_information tax
        ,(select seg.APPLICATION_COLUMN_NAME
               ,bus.organization_id
               ,seg.segment_name
         from   fnd_id_flex_segments        seg
               ,fnd_id_flex_structures      str
               ,hr_organization_information bus
         where  seg.id_flex_code   = 'JOB'
         and    seg.application_id = 800
         and    seg.enabled_flag   = 'Y'
         and    seg.display_flag   = 'Y'
         and    seg.id_flex_num    = bus.org_information6
         and    seg.id_flex_num    = str.id_flex_num
         and    seg.id_flex_code   = str.id_flex_code
         and    upper(bus.org_information_context) = 'BUSINESS GROUP INFORMATION'
         and    bus.organization_id = p_organization_id ) job
     where  tax.organization_id = job.organization_id
     and    tax.org_information12 = job.segment_name
     and    upper(tax.org_information_context) = 'TAX DETAILS REFERENCES'
     and    tax.org_information1 = l_tax_ref;
  --
  --
  --
  cursor csr_enabled_segment_count is
  select count(seg.segment_name)
  from   fnd_id_flex_segments        seg
        ,fnd_id_flex_structures      str
        ,hr_organization_information bus
  where  seg.id_flex_code   = 'JOB'
  and    seg.application_id = 800
  and    seg.enabled_flag   = 'Y'
  and    seg.display_flag   = 'Y'
  and    seg.id_flex_num    = bus.org_information6
  and    seg.id_flex_num    = str.id_flex_num
  and    seg.id_flex_code   = str.id_flex_code
  and    upper(bus.org_information_context) = 'BUSINESS GROUP INFORMATION'
  and    bus.organization_id = p_organization_id;
  --
  cursor csr_col_value(l_column_name VARCHAR2) IS
         select decode(l_column_name ,
                        'SEGMENT1'  , pjd.SEGMENT1,
                        'SEGMENT2'  , pjd.SEGMENT2,
                        'SEGMENT3'  , pjd.SEGMENT3,
                        'SEGMENT4'  , pjd.SEGMENT4,
                        'SEGMENT5'  , pjd.SEGMENT5,
                        'SEGMENT6'  , pjd.SEGMENT6,
                        'SEGMENT7'  , pjd.SEGMENT7,
                        'SEGMENT8'  , pjd.SEGMENT8,
                        'SEGMENT9'  , pjd.SEGMENT9,
                        'SEGMENT10' , pjd.SEGMENT10,
                        'SEGMENT11' , pjd.SEGMENT11,
                        'SEGMENT12' , pjd.SEGMENT12,
                        'SEGMENT13' , pjd.SEGMENT13,
                        'SEGMENT14' , pjd.SEGMENT14,
                        'SEGMENT15' , pjd.SEGMENT15,
                        'SEGMENT16' , pjd.SEGMENT16,
                        'SEGMENT17' , pjd.SEGMENT17,
                        'SEGMENT18' , pjd.SEGMENT18,
                        'SEGMENT19' , pjd.SEGMENT19,
                        'SEGMENT20' , pjd.SEGMENT20,
                        'SEGMENT21' , pjd.SEGMENT21,
                        'SEGMENT22' , pjd.SEGMENT22,
                        'SEGMENT23' , pjd.SEGMENT23,
                        'SEGMENT24' , pjd.SEGMENT24,
                        'SEGMENT25' , pjd.SEGMENT25,
                        'SEGMENT26' , pjd.SEGMENT26,
                        'SEGMENT27' , pjd.SEGMENT27,
                        'SEGMENT28' , pjd.SEGMENT28,
                        'SEGMENT29' , pjd.SEGMENT29,
                        'SEGMENT30' , pjd.SEGMENT30)
                from
                   per_job_definitions pjd
                where
                   pjd.job_definition_id = p_job_definition_id;
--
 CURSOR csr_single_seg is
     select upper(seg.APPLICATION_COLUMN_NAME)
         from   fnd_id_flex_segments        seg
               ,fnd_id_flex_structures      str
               ,hr_organization_information bus
         where  seg.id_flex_code   = 'JOB'
         and    seg.application_id = 800
         and    seg.enabled_flag   = 'Y'
         and    seg.display_flag   = 'Y'
         and    seg.id_flex_num    = bus.org_information6
         and    seg.id_flex_num    = str.id_flex_num
         and    seg.id_flex_code   = str.id_flex_code
         and    upper(bus.org_information_context) = 'BUSINESS GROUP INFORMATION'
         and    bus.organization_id = p_organization_id;
 --
BEGIN
 --
  l_payroll_action_id :=  p_payroll_action_id ;
  --
  OPEN csr_get_tax_ref(l_payroll_action_id);
     FETCH csr_get_tax_ref into l_tax_ref;
  close csr_get_tax_ref;
  --
  OPEN   csr_enabled_segment_count;
  LOOP
     FETCH  csr_enabled_segment_count INTO l_segment_count;
     EXIT WHEN csr_enabled_segment_count%NOTFOUND;
  END LOOP;
  close  csr_enabled_segment_count;
  --
  if l_segment_count > 1 then
  --

    OPEN  csr_col_name(l_tax_ref);
         FETCH  csr_col_name INTO l_column_name;
         IF csr_col_name%FOUND then
     --
            open csr_col_value(l_column_name);
               fetch csr_col_value into l_job_name;
            close csr_col_value;
--
  -- When there are more than one segment enabled display the Segment selected in
  -- EDI Job Filed Segemnt(Tax Details Ref DFF) for Job name.
  --
           return upper(l_job_name);
   --
         ELSE
         -- When there are more than one segment enabled and nothing selected in
         -- EDI Job Filed Segemnt(Tax Details Ref DFF)
          -- display just a blank space for Job name
  --
            l_job_name := (' ');
            return l_job_name;
         END IF;
    CLOSE csr_col_name;
 else
   -- If there is just one segment enabled for Job KFF, display that
   open csr_single_seg;
        fetch csr_single_seg into l_column_name;
   close csr_single_seg;
   open csr_col_value(l_column_name);
        fetch csr_col_value into l_job_name;
   close csr_col_value;
  return upper(l_job_name);
--
end if;
--
EXCEPTION
  when others then
      raise;
END get_job_segment;
--
-- EDI MES Bug 2657976
--
end pay_get_job_segment_pkg;

/
