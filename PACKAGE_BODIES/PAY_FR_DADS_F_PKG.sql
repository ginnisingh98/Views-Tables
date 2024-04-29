--------------------------------------------------------
--  DDL for Package Body PAY_FR_DADS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_DADS_F_PKG" as
/* $Header: pyfrdadf.pkb 120.0 2005/05/29 04:59 appldev noship $ */
-------------------------------------------------------------------------------
-- PROCEDURE PROCESS (Main procedure)
-------------------------------------------------------------------------------
Procedure PROCESS(errbuf                   OUT NOCOPY VARCHAR2,
                  retcode                  OUT NOCOPY NUMBER,
                  P_BUSINESS_GROUP_ID       IN NUMBER,
                  P_ISSUING_ESTABLISHMENT   IN NUMBER,
                  P_DADS_REFERENCE          IN VARCHAR2,
                  P_REPORT_TYPE             IN VARCHAR2,
                  P_DUMMY                   IN VARCHAR2, --Added for enabling/disabling P_SUBMISSION_TYPE
                  P_DECLARATION_NATURE      IN VARCHAR2,
                  P_DECLARATION_TYPE        IN VARCHAR2,
                  P_REPORT_INCLUSIONS       IN VARCHAR2,
                  P_SORT_ORDER_1            IN VARCHAR2,
                  P_SORT_ORDER_2            IN VARCHAR2,
                  P_SUBMISSION_TYPE         IN VARCHAR2) is
begin
   --
   Fnd_file.put_line(FND_FILE.OUTPUT,'OUTPUT');
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_business_group_id '|| p_business_group_id);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_issuing_establishment '|| p_issuing_establishment);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_dads_reference '|| p_dads_reference);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_report_type '|| p_report_type);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_declaration_nature '|| p_declaration_nature);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_declaration_type '|| p_declaration_type);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_report_inclusions '|| p_report_inclusions);
   --#3553620 printing the sort_order meaning instead of sort_order code
   IF p_sort_order_1 IS NULL THEN
      fnd_file.put_line(FND_FILE.OUTPUT, 'p_sort_order_1 '|| p_sort_order_1);
   ELSE
      fnd_file.put_line(FND_FILE.OUTPUT, 'p_sort_order_1 '||hr_general.decode_lookup
                               ('FR_DADS_SORT_ORDER',p_sort_order_1));
   END IF;
   IF p_sort_order_2 IS NULL THEN
      fnd_file.put_line(FND_FILE.OUTPUT, 'p_sort_order_2 '|| p_sort_order_2);
   ELSE
      fnd_file.put_line(FND_FILE.OUTPUT, 'p_sort_order_2 '||hr_general.decode_lookup
                               ('FR_DADS_SORT_ORDER',p_sort_order_2));
   END IF;
--   fnd_file.put_line(FND_FILE.OUTPUT, 'p_sort_order_1 '|| p_sort_order_1);
--   fnd_file.put_line(FND_FILE.OUTPUT, 'p_sort_order_2 '|| p_sort_order_2);
   fnd_file.put_line(FND_FILE.OUTPUT, 'p_submission_type '|| p_submission_type);
   --
   IF p_report_type ='F' OR p_report_type = 'R' THEN
      write_user_file_report(P_BUSINESS_GROUP_ID     => P_BUSINESS_GROUP_ID ,
        		     P_ISSUING_ESTABLISHMENT => P_ISSUING_ESTABLISHMENT,
        		     P_DADS_REFERENCE        => P_DADS_REFERENCE ,
        		     P_REPORT_TYPE           => P_REPORT_TYPE,
        		     P_DECLARATION_NATURE    => P_DECLARATION_NATURE,
        		     P_DECLARATION_TYPE      => P_DECLARATION_TYPE,
        		     P_REPORT_INCLUSIONS     => P_REPORT_INCLUSIONS ,
        		     P_SORT_ORDER_1          => P_SORT_ORDER_1,
        		     P_SORT_ORDER_2          => P_SORT_ORDER_2 ,
                             P_SUBMISSION_TYPE       => P_SUBMISSION_TYPE);
   ELSIF p_report_type = 'E' THEN
      control_proc (P_BUSINESS_GROUP_ID,
                        P_ISSUING_ESTABLISHMENT,
                        P_DADS_REFERENCE,
                        P_REPORT_TYPE,
                        P_DECLARATION_NATURE,
                        P_DECLARATION_TYPE,
                        P_REPORT_INCLUSIONS,
                        P_SORT_ORDER_1,
                        P_SORT_ORDER_2);
   END IF;
   --
   retcode := 0;
   --
   EXCEPTION
      WHEN OTHERS THEN raise;
   --
end PROCESS;
--
-------------------------------------------------------------------------------
-- PROCEDURE WRITE_USER_FILE_DATA (to write user or file report)
-------------------------------------------------------------------------------
--
PROCEDURE write_user_file_report(P_BUSINESS_GROUP_ID       IN NUMBER,
                                 P_ISSUING_ESTABLISHMENT   IN NUMBER,
                                 P_DADS_REFERENCE          IN VARCHAR2,
                                 P_REPORT_TYPE             IN VARCHAR2,
                                 P_DECLARATION_NATURE      IN VARCHAR2,
                                 P_DECLARATION_TYPE        IN VARCHAR2,
                                 P_REPORT_INCLUSIONS       IN VARCHAR2,
                                 P_SORT_ORDER_1            IN VARCHAR2,
                                 P_SORT_ORDER_2            IN VARCHAR2,
                                 P_SUBMISSION_TYPE         IN VARCHAR2)
  IS
  --
  TYPE ref_cursor_type IS REF CURSOR;
  ref_csr_asg_action ref_cursor_type;
  l_asg_action_id number;
  --
  l_payroll_action_id  number;
  l_sort_rubric1       varchar2(30);
  l_sort_rubric2       varchar2(30);
  l_s30_select         varchar2(1000);
  l_s30_where          varchar2(1000);
  l_s30_cond_from      varchar2(1000);
  l_s30_cond_where     varchar2(1000);
  l_s30_order_by       varchar2(100);
  l_s30_cond_order_by  varchar2(100);
  --
  l_header_issue_estab varchar2(50);
  l_cre_estab_text     hr_lookups.meaning%type;
  l_s10_cre_estab      varchar2(50);
  l_s10_heading_text   hr_lookups.meaning%type;
  l_issuing_estab_text hr_lookups.meaning%type;
  --
  l_s20_heading_text   hr_lookups.meaning%type;
  l_comp_text          hr_lookups.meaning%type;
  l_hq_text            hr_lookups.meaning%type;
  l_fisc_text          hr_lookups.meaning%type;
  l_comp_name          varchar2(100);
  l_hq_name            varchar2(100);
  l_fisc_name          varchar2(100);
  l_s20_cre_estab      varchar2(50);
  --
  l_s30_heading_text   hr_lookups.meaning%type;
  l_header_emp_number  varchar2(50);
  l_header_emp_title   varchar2(50);
  l_header_first_name  varchar2(100);
  l_header_last_name   varchar2(100);
  l_emp_name_text      hr_lookups.meaning%type;
  l_emp_number_text    hr_lookups.meaning%type;
  --
  l_s41_heading_text      hr_lookups.meaning%type;
  l_emp_estab_text        hr_lookups.meaning%type;
  l_start_date_text       hr_lookups.meaning%type;
  l_end_date_text         hr_lookups.meaning%type;
  l_emp_header_estab_name varchar2(100);
  l_header_start_period   varchar2(50);
  l_header_end_period     varchar2(50);
  --
  l_s80_heading_text      hr_lookups.meaning%type;
  l_s80_header_estab_name varchar2(100);
  l_s80_estab_text        hr_lookups.meaning%type;
  --
  l_s90_heading_text      hr_lookups.meaning%type;

  -- Cursor for fetching the payroll action
  Cursor csr_payroll_action is
    Select action_context_id
      from pay_action_information
     where action_context_type = 'PA'
       and action_information_category = 'FR_DADS_FILE_DATA'
       and action_information1 = 'S10.G01.00.004'
       and action_information4 = p_dads_reference;
  --
  -- Cursor for fetching S10 values
  Cursor csr_get_S10_rec(c_payroll_action_id number) IS
  Select action_information1 rubric_code,
         hr_general.decode_lookup ('FR_DADS_RUBRICS',action_information1) rubric_meaning,
         action_information4 file_value,
         action_information5 user_value,
         action_information9 usage
    from pay_action_information
   where action_context_id = c_payroll_action_id
     and action_context_type = 'PA'
     and action_information_category = 'FR_DADS_FILE_DATA'
     and action_information1 like 'S10%'
     and action_information3 = p_issuing_establishment
   order by action_information1;
  --
  -- Cursor for fetching the number of S20 records
  -- sorted alphabetically by company name
  Cursor csr_count_comp(c_payroll_action_id number) is
    Select distinct action_information3 company_id,
           action_information4          comp_name
      from pay_action_information
     where action_information1 = 'S20.G01.00.002'
       and action_context_id = c_payroll_action_id
       and action_information_category = 'FR_DADS_FILE_DATA'
       and action_context_type = 'PA'
       order by action_information4;
  --
  -- Cursor for fetching S20 records
  Cursor csr_get_S20_data(c_payroll_action_id number,
                          c_company_id number)is
  Select action_information1 rubric_code,
         hr_general.decode_lookup ('FR_DADS_RUBRICS',action_information1) rubric_meaning,
         action_information4 file_value,
         action_information5 user_value,
         action_information7 extra_info,
         action_information9 usage
  from pay_action_information
  where action_context_id = c_payroll_action_id
  and action_context_type = 'PA'
  and action_information_category = 'FR_DADS_FILE_DATA'
  and action_information1 like 'S20%'
  and action_information3 = c_company_id
  order by action_information1;
  --
  -- Cursor for fetching S30 records
  Cursor csr_get_s30_data(c_asg_action_id number,
                          c_company_id number)is
    Select action_information1 rubric_code,
           hr_general.decode_lookup ('FR_DADS_RUBRICS',action_information1) rubric_meaning,
           action_information4 file_value,
           action_information5 user_value,
           action_information9 usage
      from pay_action_information
     where action_context_id = c_asg_action_id
       and action_context_type = 'AAP'
       and action_information_category = 'FR_DADS_FILE_DATA'
       and action_information1 like 'S30%'
       and action_information3 = c_company_id
    order by action_information1;
  --
  -- Cursor for fetching number of S41 records
  -- for each S30 record
  Cursor csr_count_s41(c_asg_action_id number,
                       c_company_id number) is
    Select distinct action_information8 ID2
      from pay_action_information
     where action_context_id = c_asg_action_id
       and action_context_type = 'AAP'
       and action_information_category = 'FR_DADS_FILE_DATA'
       and action_information1 like 'S41%'
       and action_information3 = c_company_id
       order by action_information8;
  --
  -- Cursor for fetching s41 records
  Cursor csr_get_s41_data(c_asg_action_id number,
                          c_company_id number,
                          c_s41_id2 number) is
    Select action_information1 rubric_code,
           hr_general.decode_lookup ('FR_DADS_RUBRICS',action_information1) rubric_meaning,
           action_information4 file_value,
           action_information5 user_value,
           action_information9 usage
      from pay_action_information
     where action_context_id = c_asg_action_id
       and action_context_type = 'AAP'
       and action_information_category = 'FR_DADS_FILE_DATA'
       and action_information1 like 'S41%'
       and action_information3 = c_company_id
       and action_information8 = c_s41_id2
    order by action_information1;
  --
  -- Cursor to fetch number of INSEE establishments
  Cursor csr_count_s80(c_payroll_action_id number) is
  select distinct action_information3 estab_id
    from pay_action_information
   where action_context_id = c_payroll_action_id
     and action_context_type = 'PA'
     and action_information_category = 'FR_DADS_FILE_DATA'
     and action_information1 like 'S80%';
  --
  -- Cursor to get S80 data
  Cursor csr_get_s80_data(c_payroll_action_id number,
                          c_estab_id number)is
    Select action_information1 rubric_code,
           hr_general.decode_lookup ('FR_DADS_RUBRICS',action_information1) rubric_meaning,
           action_information4 file_value,
           action_information5 user_value,
           action_information9 usage
      from pay_action_information
     where action_context_id = c_payroll_action_id
       and action_context_type = 'PA'
       and action_information_category = 'FR_DADS_FILE_DATA'
       and action_information1 like 'S80%'
       and action_information3 = c_estab_id
    order by action_information1;
  --
  -- Cursor to get S90 data
    Cursor csr_get_s90_data(c_payroll_action_id number)is
      Select action_information1 rubric_code,
             hr_general.decode_lookup ('FR_DADS_RUBRICS',action_information1) rubric_meaning,
             action_information4 file_value,
             action_information5 user_value,
             action_information9 usage
        from pay_action_information
       where action_context_id = c_payroll_action_id
         and action_context_type = 'PA'
         and action_information_category = 'FR_DADS_FILE_DATA'
         and action_information1 like 'S90%'
       order by action_information1;
  --
  -- Cursor for S10 header
  Cursor csr_s10_header_data(c_payroll_action_id number) is
    Select issue.action_information4 issue_estab,
           cre.action_information5   cre_estab_name
      from pay_action_information issue,
           pay_action_information cre
     where issue.action_context_id = c_payroll_action_id
       and issue.action_context_type = 'PA'
       and issue.action_information_category = 'FR_DADS_FILE_DATA'
       and issue.action_information1 = 'S10.G01.00.002'
       --
       and cre.action_context_id(+) = issue.action_context_id
       and cre.action_context_type(+) = 'PA'
       and cre.action_information_category(+) = 'FR_DADS_REPORT_DATA'
       and cre.action_information1(+) = 'S10'
       and cre.action_information3(+) = P_ISSUING_ESTABLISHMENT;
  --
  -- Cursor for S20 header
  Cursor csr_s20_header_data(c_payroll_action_id number,
                             c_company_id number) is
  Select comp.action_information4 comp_name,
         nvl(cre_s20.action_information5,null) cre_name,
         nvl(hq.action_information7,null)   hq_name,
         nvl(fisc.action_information4,null) fisc_name
  from pay_action_information comp,
       pay_action_information cre_s20,
       pay_action_information hq,
       pay_action_information fisc
  where comp.action_context_id = c_payroll_action_id
    and comp.action_context_type = 'PA'
    and comp.action_information_category = 'FR_DADS_FILE_DATA'
    and comp.action_information1 = 'S20.G01.00.002'
    and comp.action_information3 = c_company_id
    --
    and cre_s20.action_context_id(+) = comp.action_context_id
    and cre_s20.action_context_type(+) = 'PA'
    and cre_s20.action_information_category(+) = 'FR_DADS_REPORT_DATA'
    and cre_s20.action_information1 (+)= 'S20'
    and cre_s20.action_information3(+) = comp.action_information3
    --
    and hq.action_context_id(+) = comp.action_context_id
    and hq.action_context_type(+) = 'PA'
    and hq.action_information_category(+) = 'FR_DADS_FILE_DATA'
    and hq.action_information1 (+)= 'S20.G01.00.008'
    and hq.action_information3(+) = comp.action_information3
    --
    and fisc.action_context_id(+) = comp.action_context_id
    and fisc.action_context_type(+) = 'PA'
    and fisc.action_information_category(+) = 'FR_DADS_FILE_DATA'
    and fisc.action_information1(+)='S20.G01.00.011'
    and fisc.action_information3(+) = comp.action_information3;
  --
  -- Cursor for S30 header
  Cursor csr_s30_header_data(c_asg_action_id number,
                             c_company_id number) is
  Select nvl(title.action_information5,null)      emp_title,
         nvl(title.action_information8 ,null)     emp_number,
         nvl(first_name.action_information4,null) emp_first,
         nvl(last_name.action_information4,null)  emp_last
  from pay_action_information title,
       pay_action_information first_name,
       pay_action_information last_name
  where title.action_context_id = c_asg_action_id
    and title.action_context_type = 'AAP'
    and title.action_information_category = 'FR_DADS_FILE_DATA'
    and title.action_information1 = 'S30.G01.00.007'
    and title.action_information3 = c_company_id
    --
    and first_name.action_context_id = c_asg_action_id
    and first_name.action_context_type = 'AAP'
    and first_name.action_information_category = 'FR_DADS_FILE_DATA'
    and first_name.action_information1 = 'S30.G01.00.003'
    and first_name.action_information3 = c_company_id
    --
    and last_name.action_context_id = c_asg_action_id
    and last_name.action_context_type = 'AAP'
    and last_name.action_information_category = 'FR_DADS_FILE_DATA'
    and last_name.action_information1 = 'S30.G01.00.004'
    and last_name.action_information3 = c_company_id;
  --
  -- Cursor for S41 header
  cursor csr_s41_header_data(c_asg_action_id number,
                             c_company_id number,
                             c_s41_id2 number) is
  Select hou_tl_estab.name         emp_estab,
         start_period.action_information4 period_start,
         end_period.action_information4   period_end
  from pay_action_information estab,
       pay_action_information start_period,
       pay_action_information end_period,
       hr_all_organization_units_tl hou_tl_estab
  where estab.action_context_id = c_asg_action_id
    and estab.action_context_type = 'AAP'
    and estab.action_information_category = 'FR_DADS_FILE_DATA'
    and estab.action_information1 = 'S41.G01.00.005'
    and estab.action_information3 = c_company_id
    and estab.action_information8 = c_s41_id2
    and hou_tl_estab.organization_id(+) = estab.action_information7
    and hou_tl_estab.language(+) = userenv('LANG')
    --
    and start_period.action_context_id = c_asg_action_id
    and start_period.action_context_type = 'AAP'
    and start_period.action_information_category = 'FR_DADS_FILE_DATA'
    and start_period.action_information1 = 'S41.G01.00.001'
    and start_period.action_information3 = c_company_id
    and start_period.action_information8 = c_s41_id2
    --
    and end_period.action_context_id = c_asg_action_id
    and end_period.action_context_type = 'AAP'
    and end_period.action_information_category = 'FR_DADS_FILE_DATA'
    and end_period.action_information1 = 'S41.G01.00.003'
    and end_period.action_information3 = c_company_id
    and end_period.action_information8 = c_s41_id2;
  --
  -- Cursor for S80 header
  Cursor csr_s80_header_data(c_payroll_action_id number,
                             c_estab_id number)is
  Select action_information4 estab_name
  from pay_action_information
  where action_context_id = c_payroll_action_id
    and action_context_type = 'PA'
    and action_information_category = 'FR_DADS_FILE_DATA'
    and action_information1 = 'S80.G01.00.002'
    and action_information3 = c_estab_id;
  --
   -- Procedure for writing into files
    PROCEDURE write_into_file (p_report_type varchar2,
                               p_rubric_code varchar2,
                               p_rubric_desc varchar2,
                               p_file_value varchar2,
                               p_user_value varchar2) is
    --
    BEGIN
    --
    fnd_file.put(fnd_file.output, p_rubric_code);
    IF p_report_type = 'F' THEN
       -- write the file value
       fnd_file.put(fnd_file.output, ' '||p_file_value);
    ELSIF p_report_type ='R' THEN
       -- put the rubric description
       fnd_file.put(fnd_file.output, ' '||p_rubric_desc);
       --Bug 3756137
       if p_rubric_code <> 'S41.G01.00.026' or p_file_value <> '99999' then
          -- write the file value
          fnd_file.put(fnd_file.output, ' '||p_file_value);
       end if;
       --Bug 3756137
       IF p_user_value IS NOT NULL THEN
          -- write the user value
          fnd_file.put(fnd_file.output, ' '||p_user_value);
       END IF;
    END IF;
    -- insert a line after each rubric
    fnd_file.new_line(fnd_file.output, 1);
    --
    --
    EXCEPTION
      WHEN OTHERS THEN raise;
    --
    END write_into_file;
    --
    -- Function for returning sort rubrics
    FUNCTION get_sort_rubrics(p_sort_order VARCHAR2) return varchar2
    IS
    BEGIN
    --
    IF p_sort_order = '31' THEN
       -- return rubric for zip code
       RETURN 'S30.G01.00.008.010';
    ELSIF p_sort_order = '32' THEN
       -- return rubric for name
       RETURN 'S30.G01.00.004';
    ELSIF p_sort_order = '33' THEN
       -- return rubric for ss number
       RETURN 'S30.G01.00.001';
    ELSIF p_sort_order = '34' THEN
       -- return rubric for ss number
       -- to pick up the id2 col for emp number
       RETURN 'S30.G01.00.001';
    END IF;
    --
    --
    EXCEPTION
          WHEN OTHERS THEN raise;
    --
    END get_sort_rubrics;
  --
  BEGIN
    -- fetch the sort order rubrics
    l_sort_rubric1 := get_sort_rubrics(p_sort_order_1);
    -- As p_sort_order_2 is not a mandatory parameter
    IF p_sort_order_2 IS NOT NULL THEN
       l_sort_rubric2 := get_sort_rubrics(p_sort_order_2);
    END IF;
    -- fetch the payroll action
    OPEN csr_payroll_action;
    FETCH csr_payroll_action INTO l_payroll_action_id;
    CLOSE csr_payroll_action;
    -- Check for report inclusions
    IF P_REPORT_INCLUSIONS ='ORG' OR P_REPORT_INCLUSIONS='ALL' THEN
       -- WRITE S10 DATA
       -- print header for S10
       OPEN csr_s10_header_data(l_payroll_action_id);
       FETCH csr_s10_header_data INTO l_header_issue_estab, l_s10_cre_estab;
       CLOSE csr_s10_header_data;
       -- get lookup meanings
       l_s10_heading_text :=hr_general.decode_lookup('FR_DADS_HEADINGS','S10_ISSUE_ESTAB_INFO');
       l_issuing_estab_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S10_ISSUE_ESTAB_NAME');
       l_cre_estab_text:= hr_general.decode_lookup('FR_DADS_HEADINGS','S10_CRE_ESTAB_NAME');
       --
       fnd_file.new_line(fnd_file.output,2);
       fnd_file.put_line(fnd_file.output,l_s10_heading_text);
       fnd_file.put_line(fnd_file.output,l_issuing_estab_text ||' : '||l_header_issue_estab);
       fnd_file.put_line(fnd_file.output,l_cre_estab_text||' : '||l_s10_cre_estab);
       fnd_file.new_line(fnd_file.output, 1);
       --
       -- fetch the values for s10
       FOR get_s10_rec IN csr_get_S10_rec(l_payroll_action_id) LOOP
          -- print only mandatory or non-null non-mandatory fields
          IF get_s10_rec.usage ='M'
             OR (get_s10_rec.usage <>'M' AND get_s10_rec.file_value IS NOT NULL)
          THEN
          -- Choose the correct archived send code
            IF get_s10_rec.rubric_code <> 'S10.G01.00.010'
              OR (get_s10_rec.rubric_code = 'S10.G01.00.010'
              AND substr(get_s10_rec.file_value,1,4) = substr(P_SUBMISSION_TYPE,1,4)) THEN
              -- write the values of S10
              write_into_file (p_report_type => p_report_type,
                             p_rubric_code => get_s10_rec.rubric_code,
                             p_rubric_desc => get_s10_rec.rubric_meaning,
                             p_file_value  => get_s10_rec.file_value,
                             p_user_value  => get_s10_rec.user_value);
              --
            END IF;
            -- end of check for usage
          END IF;
       END LOOP;
       -- END OF WRITING S10 DATA
    END IF; --end of check for report inclusions
    -- fetch the number of companies archived for the issuing estab
    FOR comp_rec IN csr_count_comp(l_payroll_action_id) LOOP
       -- Check for report inclusions
       IF P_REPORT_INCLUSIONS ='ORG' OR P_REPORT_INCLUSIONS='ALL' THEN
          -- WRITE S20 DATA
          -- print header for S20
          -- get lookup meanings
          l_s20_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_COMP_INFO');
          l_comp_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_COMP_NAME');
          l_hq_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_HQ_ESTAB_NAME');
          l_fisc_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_FISC_ESTAB_NAME');
          l_cre_estab_text:= hr_general.decode_lookup('FR_DADS_HEADINGS','S10_CRE_ESTAB_NAME');
          -- get cursor values
          OPEN csr_s20_header_data(l_payroll_action_id,comp_rec.company_id);
          FETCH csr_s20_header_data INTO l_comp_name, l_s20_cre_estab, l_hq_name, l_fisc_name;
          CLOSE csr_s20_header_data;
          -- write the header into the file
          fnd_file.new_line(fnd_file.output,2);
          fnd_file.put_line(fnd_file.output,l_s20_heading_text);
          fnd_file.put_line(fnd_file.output,l_comp_text||' : '||l_comp_name);
          fnd_file.put_line(fnd_file.output,l_hq_text||' : '||l_hq_name);
          fnd_file.put_line(fnd_file.output,l_fisc_text||' : '||l_fisc_name);
          fnd_file.put_line(fnd_file.output,l_cre_estab_text||' : '||l_s20_cre_estab);
          fnd_file.new_line(fnd_file.output,1);
          --
          -- Fetch S20 data
          FOR S20_data_rec IN csr_get_S20_data(l_payroll_action_id,
                                               comp_rec.company_id) LOOP
            -- print only mandatory or non-null non-mandatory fields
	    IF S20_data_rec.usage ='M'
	       OR (S20_data_rec.usage <>'M' AND S20_data_rec.file_value IS NOT NULL)
            THEN
               -- Choose the correct periodicity code
               IF S20_data_rec.rubric_code = 'S20.G01.00.018' THEN
                  --
                  IF substr(S20_data_rec.extra_info,1,4) = substr(P_SUBMISSION_TYPE,1,4) THEN
                   --
                   -- Write S20 data to the report
		   write_into_file (p_report_type => p_report_type,
			         p_rubric_code => S20_data_rec.rubric_code,
			         p_rubric_desc => S20_data_rec.rubric_meaning,
			         p_file_value  => S20_data_rec.file_value,
			         p_user_value  => S20_data_rec.user_value);
                    --
                  END IF;
                  --
               ELSIF S20_data_rec.rubric_code = 'S20.G01.00.004.001' THEN
                  -- Write the value as obtained from report parameter
                  write_into_file (p_report_type => p_report_type,
	     	                p_rubric_code => S20_data_rec.rubric_code,
	     	                p_rubric_desc => S20_data_rec.rubric_meaning,
	     	                p_file_value  => p_declaration_nature,
	                        p_user_value  => hr_general.decode_lookup('FR_DADS_DECL_NATURE_CODE',p_declaration_nature));
                  --
               ELSIF S20_data_rec.rubric_code = 'S20.G01.00.004.002' THEN
                  -- Write the value as obtained from report parameter
                  write_into_file (p_report_type => p_report_type,
	         	        p_rubric_code => S20_data_rec.rubric_code,
	     	                p_rubric_desc => S20_data_rec.rubric_meaning,
	     	                p_file_value  => p_declaration_type,
	                        p_user_value  => hr_general.decode_lookup('FR_DADS_DECL_TYPE_CODE',p_declaration_type));
                  --
               ELSIF S20_data_rec.rubric_code = 'S20.G01.00.006' THEN
                  -- check the declaration type
                  IF p_declaration_type = 53 THEN -- if the type is 'correction'
                     -- Write the calendar year to which salaries are attached
		     write_into_file (p_report_type => p_report_type,
		   	            p_rubric_code => S20_data_rec.rubric_code,
		   	            p_rubric_desc => S20_data_rec.rubric_meaning,
		   	            p_file_value  => S20_data_rec.file_value,
		   	            p_user_value  => S20_data_rec.user_value);
                     --
                  END IF;
                  --
               ELSE
                  -- Write S20 data to the report
                  write_into_file (p_report_type => p_report_type,
	                        p_rubric_code => S20_data_rec.rubric_code,
	                        p_rubric_desc => S20_data_rec.rubric_meaning,
	                        p_file_value  => S20_data_rec.file_value,
	                        p_user_value  => S20_data_rec.user_value);
                  --
               END IF;
               --
            END IF;
            -- end of check for usage
          END LOOP;
      END IF;
      -- Exclude S30 and S41 if declaration nature code is '05'
      IF p_declaration_nature <> '05'
        -- check for report inclusions
        AND (P_REPORT_INCLUSIONS= 'EMP' OR P_REPORT_INCLUSIONS= 'ALL') THEN
         -- build up the query conditionally
         l_s30_select := 'Select pasac.assignment_action_id
	                 from pay_assignment_actions pasac,
	                      pay_action_information pacinfo_1';
	 l_s30_where :=' where pasac.payroll_action_id = '||l_payroll_action_id||'
	                  and pacinfo_1.action_context_id = pasac.assignment_action_id
	                  and pacinfo_1.action_context_type =''AAP''
	                  and pacinfo_1.action_information1 = '|| '''' ||l_sort_rubric1|| ''''||'
	                  and pacinfo_1.action_information3 = '||comp_rec.company_id||'';
	 -- As p_sort_order_2 is not a mandatory parameter
	 IF p_sort_order_2 IS NOT NULL THEN
	    l_s30_cond_from  := ' ,pay_action_information pacinfo_2';
	    l_s30_cond_where := 'and pacinfo_2.action_context_id = pasac.assignment_action_id
	                         and pacinfo_2.action_context_type =''AAP''
	                         and pacinfo_2.action_information1 = '|| '''' ||l_sort_rubric2|| ''''||'
	                         and pacinfo_2.action_information3 = '||comp_rec.company_id||'';
	    IF p_sort_order_2 = '34' THEN
	       l_s30_cond_order_by := ',pacinfo_2.action_information8';
	    ELSE
	       l_s30_cond_order_by := ',pacinfo_2.action_information4';
	    END IF;
	 ELSE
	    l_s30_cond_from  := '';
	    l_s30_cond_where := '';
	    l_s30_cond_order_by := '';
	 END IF;
	 IF  p_sort_order_1 = '34' THEN
	    l_s30_order_by := ' order by pacinfo_1.action_information8';
	 ELSE
	    l_s30_order_by := ' order by pacinfo_1.action_information4';
         END IF;
         -- fetch assignment action ids for this payroll action ids and loop
         OPEN ref_csr_asg_action FOR l_s30_select||l_s30_cond_from||l_s30_where||l_s30_cond_where||l_s30_order_by||l_s30_cond_order_by;
         LOOP
           FETCH ref_csr_asg_action INTO l_asg_action_id;
           EXIT WHEN ref_csr_asg_action%NOTFOUND;
           -- WRITE S30 DATA
           -- print header for S30
           -- get  the lookup values
           l_s30_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S30_EMP_INFO');
           l_emp_name_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S30_EMP_NAME');
           l_emp_number_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S30_EMP_NUMBER');
           -- fetch the header values
           OPEN csr_s30_header_data(l_asg_action_id,
                                    comp_rec.company_id);
           FETCH csr_s30_header_data INTO l_header_emp_title,
                                          l_header_emp_number,
                                          l_header_first_name,
                                          l_header_last_name;
           CLOSE csr_s30_header_data;
           -- write the header lines for s30
           fnd_file.new_line(fnd_file.output,2);
           fnd_file.put_line(fnd_file.output,l_s30_heading_text);
           fnd_file.put_line(fnd_file.output,l_emp_name_text||' : '||l_header_emp_title||' '||l_header_first_name||' '||l_header_last_name);
           fnd_file.put_line(fnd_file.output,l_emp_number_text||' : '||l_header_emp_number);
           fnd_file.new_line(fnd_file.output, 1);
           --
           -- fetch s30 data archived for this company and assignment action
           FOR S30_data_rec IN csr_get_S30_data(l_asg_action_id,
                                                comp_rec.company_id) LOOP
	     -- print only mandatory or non-null non-mandatory fields
	     IF S30_data_rec.usage ='M'
	     	OR (S30_data_rec.usage <>'M' AND S30_data_rec.file_value IS NOT NULL)
             THEN
	        -- Write S30 data to the report
	        write_into_file (p_report_type => p_report_type,
	   	              p_rubric_code => S30_data_rec.rubric_code,
	   	              p_rubric_desc => S30_data_rec.rubric_meaning,
	   	              p_file_value  => S30_data_rec.file_value,
	   	              p_user_value  => S30_data_rec.user_value);

                --
             END IF;
             -- end of check for usage
           END LOOP;
           -- fetch the number of s41 records archived for each s30
           FOR count_s41_rec IN csr_count_s41(l_asg_action_id,
                                             comp_rec.company_id) LOOP
             -- WRITE S41 DATA
             -- print header for S41
             -- get lookup values
             l_s41_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_FISCAL_INFO');
             l_emp_estab_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_EMP_ESTAB');
             l_start_date_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_START_DATE');
             l_end_date_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_END_DATE');
             -- fetch header values
             OPEN csr_s41_header_data(l_asg_action_id,
                                      comp_rec.company_id,
                                    count_s41_rec.id2);
             FETCH csr_s41_header_data INTO l_emp_header_estab_name,
                                            l_header_start_period,
                                            l_header_end_period;
             CLOSE csr_s41_header_data;
             -- Write the header lines
             fnd_file.new_line(fnd_file.output,2);
             fnd_file.put_line(fnd_file.output,l_s41_heading_text);
             fnd_file.put_line(fnd_file.output,l_emp_name_text||' : '||l_header_emp_title||' '||l_header_first_name||' '||l_header_last_name);
             fnd_file.put_line(fnd_file.output,l_emp_number_text||' : '||l_header_emp_number);
             fnd_file.put_line(fnd_file.output,l_emp_estab_text||' : '||l_emp_header_estab_name);
             fnd_file.put_line(fnd_file.output,l_start_date_text||' : '||l_header_start_period);
             fnd_file.put_line(fnd_file.output,l_end_date_text||' : '||l_header_end_period);
             fnd_file.new_line(fnd_file.output, 1);
             --
             -- fetch S41 records
             FOR s41_data_rec IN csr_get_s41_data(l_asg_action_id,
                                                  comp_rec.company_id,
                                                  count_s41_rec.id2) LOOP
                 -- print only mandatory or non-null non-mandatory fields
		 IF S41_data_rec.usage ='M'
		    OR (S41_data_rec.usage <>'M' AND S41_data_rec.file_value IS NOT NULL)
                 THEN
                    -- Exclude rubrics selectively for decl code '02'
                    IF p_declaration_nature <>2 OR
                      (p_declaration_nature = '02' AND
                       substr(S41_data_rec.rubric_code,13,2)
                          NOT IN (29,30,32,33,35,37,42,44,49,52,66)) THEN
                          -- Write S41 data into report
                          write_into_file (p_report_type => p_report_type,
	       	                        p_rubric_code => S41_data_rec.rubric_code,
	       	                        p_rubric_desc => S41_data_rec.rubric_meaning,
	       	                        p_file_value  => S41_data_rec.file_value,
	       	                        p_user_value  => S41_data_rec.user_value);
                       --
                    END IF;
                    --
                 END IF;
                 -- End of check for usage
             END LOOP;
           -- END OF WRITING S41 DATA
           -- end loop for number of s41 records
           END LOOP;
        -- END OF WRITING S30 DATA
        -- end loop for assignment actions
        END LOOP;
      -- end of exclusion for '05' decl nature code
      END IF;
   -- END OF WRITING S20 DATA
   -- end loop for companies archived
   END LOOP;
   --
   -- Get number of INSEE establishments archived
   FOR count_s80_rec IN csr_count_s80(l_payroll_action_id) LOOP
      -- Check for report inclusions
      IF P_REPORT_INCLUSIONS= 'ALL' THEN
         -- WRITE S80 DATA
         -- print header for S80
         -- get lookup values
         l_s80_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S80_ESTAB_INFO');
         l_s80_estab_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S80_ESTAB_NAME');
         -- fetch header data
         OPEN csr_s80_header_data(l_payroll_action_id,count_s80_rec.estab_id);
         FETCH csr_s80_header_data INTO l_s80_header_estab_name;
         CLOSE csr_s80_header_data;
         -- write header lines for s80
         fnd_file.new_line(fnd_file.output,2);
         fnd_file.put_line(fnd_file.output,l_s80_heading_text);
         fnd_file.put_line(fnd_file.output,l_s80_estab_text||' : '||l_s80_header_estab_name);
         fnd_file.new_line(fnd_file.output, 1);
         --
         -- Get S80 data
         FOR s80_data_rec IN csr_get_s80_data(l_payroll_action_id,
                                              count_s80_rec.estab_id)LOOP
            -- print only mandatory or non-null non-mandatory fields
	    IF S80_data_rec.usage ='M'
	       OR (S80_data_rec.usage <>'M' AND S80_data_rec.file_value IS NOT NULL)
            THEN
               -- write s80 data
               write_into_file (p_report_type => p_report_type,
	    	             p_rubric_code => S80_data_rec.rubric_code,
	    	             p_rubric_desc => S80_data_rec.rubric_meaning,
	    	             p_file_value  => S80_data_rec.file_value,
	  	             p_user_value  => S80_data_rec.user_value);
               --
            END IF;
            -- end of check for usage
         END LOOP;
         --
      END IF;
    -- END OF WRITING S80 DATA
    END LOOP;
    -- WRITE S90 DATA
    -- print header for S90
    l_s90_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S90_TOTALS');
    fnd_file.new_line(fnd_file.output,2);
    fnd_file.put_line(fnd_file.output,l_s90_heading_text);
    fnd_file.new_line(fnd_file.output, 1);
    --
    -- Get s90 data
    FOR s90_data_rec IN csr_get_s90_data(l_payroll_action_id) LOOP
       IF p_declaration_nature = '02' THEN
          -- Check for report inclusions
          IF P_REPORT_INCLUSIONS= 'ALL' THEN
             -- print rubric data selectively
             IF S90_data_rec.rubric_code <> 'S90.G01.00.009' THEN
                -- print only mandatory or non-null non-mandatory fields
		IF S90_data_rec.usage ='M'
	           OR (S90_data_rec.usage <>'M' AND S90_data_rec.file_value IS NOT NULL)
                THEN
                   -- Write S90 data into report
                   write_into_file (p_report_type => p_report_type,
       	                         p_rubric_code => S90_data_rec.rubric_code,
       	                         p_rubric_desc => S90_data_rec.rubric_meaning,
       	                         p_file_value  => S90_data_rec.file_value,
       	                         p_user_value  => S90_data_rec.user_value);
                END IF;
                -- end of check for usage
             END IF;
             --
          END IF;
          --
       END IF;
       --
    END LOOP;
    -- END OF WRITING S90 DATA
  --
  EXCEPTION
     WHEN OTHERS THEN raise;
  --
END write_user_file_report;
-------------------------------------------------------------------------------
--Exceptions Report Procedure
------------------------------------------------------------------------------
Procedure control_proc (P_BUSINESS_GROUP_ID       IN NUMBER,
                        P_ISSUING_ESTABLISHMENT   IN NUMBER,
                        P_DADS_REFERENCE          IN VARCHAR2,
                        P_REPORT_TYPE             IN VARCHAR2,
                        P_DECLARATION_NATURE      IN VARCHAR2,
                        P_DECLARATION_TYPE        IN VARCHAR2,
                        P_REPORT_INCLUSIONS       IN VARCHAR2,
                        P_SORT_ORDER_1            IN VARCHAR2,
                        P_SORT_ORDER_2            IN VARCHAR2)
IS
--
TYPE ref_cursor_type IS REF CURSOR;
ref_csr_asg_action ref_cursor_type;
l_asg_action_id number;
--
l_payroll_action_id     number;
l_sort_rubric1          varchar2(30);
l_sort_rubric2          varchar2(30);
l_s30_select            varchar2(1000);
l_s30_where             varchar2(1000);
l_s30_cond_from         varchar2(1000);
l_s30_cond_where        varchar2(1000);
l_s30_order_by          varchar2(100);
l_s30_cond_order_by     varchar2(100);
--
l_header_issue_estab    varchar2(50);
l_cre_estab_text        hr_lookups.meaning%type;
l_s10_cre_estab         varchar2(50);
l_s10_heading_text      hr_lookups.meaning%type;
l_issuing_estab_text    hr_lookups.meaning%type;
--
l_s20_heading_text      hr_lookups.meaning%type;
l_comp_text             hr_lookups.meaning%type;
l_hq_text               hr_lookups.meaning%type;
l_fisc_text             hr_lookups.meaning%type;
l_comp_name             varchar2(100);
l_hq_name               varchar2(100);
l_fisc_name             varchar2(100);
l_s20_cre_estab         varchar2(50);
--
l_s30_heading_text      hr_lookups.meaning%type;
l_header_emp_number     varchar2(50);
l_header_emp_title      varchar2(50);
l_header_first_name     varchar2(100);
l_header_last_name      varchar2(100);
l_emp_name_text         hr_lookups.meaning%type;
l_emp_number_text       hr_lookups.meaning%type;
--
l_s41_heading_text      hr_lookups.meaning%type;
l_emp_estab_text        hr_lookups.meaning%type;
l_start_date_text       hr_lookups.meaning%type;
l_end_date_text         hr_lookups.meaning%type;
l_emp_header_estab_name varchar2(100);
l_header_start_period   varchar2(50);
l_header_end_period     varchar2(50);
--
l_s80_heading_text      hr_lookups.meaning%type;
l_s80_header_estab_name varchar2(100);
l_s80_estab_text        hr_lookups.meaning%type;
--
l_s90_heading_text      hr_lookups.meaning%type;
--
-- To store the number of employees and companies in an establishment
l_total_employees       number;
l_total_companies       number;

l_value                 fnd_new_messages.message_text%type;
--
-- Cursor for fetching the payroll action
Cursor csr_payroll_action is
  Select action_context_id
    from pay_action_information
   where action_context_type = 'PA'
     and action_information_category = 'FR_DADS_FILE_DATA'
     and action_information1 = 'S10.G01.00.004'
     and action_information4 = p_dads_reference;
--
  -- Cursor for fetching S10 values
  Cursor csr_get_S10_rec(c_payroll_action_id number) IS
   Select action_information1 rubric_code,
	  action_information2 error_warning,
	  action_information6 error_warning_message
    from pay_action_information
    where action_context_id = c_payroll_action_id
      and action_context_type = 'PA'
      and action_information_category = 'FR_DADS_FILE_DATA'
      and action_information1 like 'S10%'
      and action_information3 = p_issuing_establishment
      and action_information6 is not null
   order by action_information1;
  --
-- Cursor for fetching the number of S20 records
-- sorted alphabetically by company name
Cursor csr_count_comp(c_payroll_action_id number) is
    Select distinct action_information3 company_id,
           action_information4          comp_name
   from  pay_action_information
   where action_information1 = 'S20.G01.00.002'
     and action_context_id = c_payroll_action_id
     and action_information_category = 'FR_DADS_FILE_DATA'
     and action_context_type = 'PA'
     order by action_information4;
--
  -- Cursor for fetching S20 records
  Cursor csr_get_S20_data(c_payroll_action_id number,
                          c_company_id number)is
                                   Select action_information1 rubric_code,
		        		  action_information2 error_warning,
			        	  action_information6 error_warning_message
			           from pay_action_information
                	           where action_context_id = c_payroll_action_id
	                           and action_context_type = 'PA'
	                           and action_information_category = 'FR_DADS_FILE_DATA'
	                           and action_information1 like 'S20%'
                                   and action_information3 = c_company_id
		 	           and action_information6 is not null
                                 order by action_information1;
  --
  -- Cursor for fetching S30 records
  Cursor csr_get_s30_data(c_asg_action_id number,
                          c_company_id number)is
                                         Select action_information1 rubric_code,
	                  		        action_information2 error_warning,
			        	        action_information6 error_warning_message
              			         from pay_action_information
                	                 where action_context_id = c_asg_action_id
	                                 and action_context_type = 'AAP'
	                                 and action_information_category = 'FR_DADS_FILE_DATA'
	                                 and action_information1 like 'S30%'
	                                 and action_information3 = c_company_id
		 	                 and action_information6 is not null
                                       order by action_information1;
  --
-- Cursor for fetching number of S41 records
-- for each S30 record
Cursor csr_count_s41(c_asg_action_id number,
                     c_company_id number) is
  Select distinct action_information8 ID2
    from pay_action_information
   where action_context_id = c_asg_action_id
     and action_context_type = 'AAP'
     and action_information_category = 'FR_DADS_FILE_DATA'
     and action_information1 like 'S41%'
     and action_information3 = c_company_id
     order by action_information8;
--
  -- Cursor for fetching s41 records
  Cursor csr_get_s41_data(c_asg_action_id number,
                          c_company_id number,
                          c_s41_id2 number) is
                                            Select action_information1 rubric_code,
	                       		           action_information2 error_warning,
			        	           action_information6 error_warning_message
              			            from pay_action_information
                	                    where action_context_id = c_asg_action_id
	                                    and action_context_type = 'AAP'
	                                    and action_information_category = 'FR_DADS_FILE_DATA'
	                                    and action_information1 like 'S41%'
	                                    and action_information3 = c_company_id
					    and action_information8 = c_s41_id2
		 	                    and action_information6 is not null
                                           order by action_information1;
-- Cursor to fetch number of INSEE establishments
Cursor csr_count_s80(c_payroll_action_id number) is
select distinct action_information3 estab_id
  from pay_action_information
 where action_context_id = c_payroll_action_id
   and action_context_type = 'PA'
   and action_information_category = 'FR_DADS_FILE_DATA'
   and action_information1 like 'S80%';
--
  -- Cursor to get S80 data
  Cursor csr_get_s80_data(c_payroll_action_id number,
                          c_estab_id number)is
                                  Select action_information1 rubric_code,
                    		         action_information2 error_warning,
		        	         action_information6 error_warning_message
      			          from pay_action_information
        	                  where action_context_id = c_payroll_action_id
                                  and action_context_type = 'PA'
                                  and action_information_category = 'FR_DADS_FILE_DATA'
                                  and action_information1 like 'S80%'
                                  and action_information3 = c_estab_id
	 	                  and action_information6 is not null
                                 order by action_information1;
  --
  -- Cursor to get S90 data
    Cursor csr_get_s90_data(c_payroll_action_id number)is
                            Select action_information1 rubric_code,
             		           action_information2 error_warning,
		        	   action_information6 error_warning_message
      			    from pay_action_information
        	            where action_context_id = c_payroll_action_id
                            and action_context_type = 'PA'
                            and action_information_category = 'FR_DADS_FILE_DATA'
                            and action_information1 like 'S90%'
	 	            and action_information6 is not null
                         order by action_information1;
  --
-- Cursor for S10 header
Cursor csr_s10_header_data(c_payroll_action_id number) is
  Select issue.action_information4 issue_estab,
         cre.action_information5   cre_estab_name
    from pay_action_information issue,
         pay_action_information cre
   where issue.action_context_id = c_payroll_action_id
     and issue.action_context_type = 'PA'
     and issue.action_information_category = 'FR_DADS_FILE_DATA'
     and issue.action_information1 = 'S10.G01.00.002'
     --
     and cre.action_context_id(+) = issue.action_context_id
     and cre.action_context_type(+) = 'PA'
     and cre.action_information_category(+) = 'FR_DADS_REPORT_DATA'
     and cre.action_information1(+) = 'S10'
     and cre.action_information3(+) = P_ISSUING_ESTABLISHMENT;
  --
  -- Cursor for S20 header
  Cursor csr_s20_header_data(c_payroll_action_id number,
                             c_company_id number) is
  Select comp.action_information4 comp_name,
         nvl(cre_s20.action_information5,null) cre_name,
         nvl(hq.action_information7,null)   hq_name,
         nvl(fisc.action_information4,null) fisc_name
  from pay_action_information comp,
       pay_action_information cre_s20,
       pay_action_information hq,
       pay_action_information fisc
  where comp.action_context_id = c_payroll_action_id
    and comp.action_context_type = 'PA'
    and comp.action_information_category = 'FR_DADS_FILE_DATA'
    and comp.action_information1 = 'S20.G01.00.002'
    and comp.action_information3 = c_company_id
    --
    and cre_s20.action_context_id(+) = comp.action_context_id
    and cre_s20.action_context_type(+) = 'PA'
    and cre_s20.action_information_category(+) = 'FR_DADS_REPORT_DATA'
    and cre_s20.action_information1 (+)= 'S20'
    and cre_s20.action_information3(+) = comp.action_information3
    --
    and hq.action_context_id(+) = comp.action_context_id
    and hq.action_context_type(+) = 'PA'
    and hq.action_information_category(+) = 'FR_DADS_FILE_DATA'
    and hq.action_information1 (+)= 'S20.G01.00.008'
    and hq.action_information3(+) = comp.action_information3
    --
    and fisc.action_context_id(+) = comp.action_context_id
    and fisc.action_context_type(+) = 'PA'
    and fisc.action_information_category(+) = 'FR_DADS_FILE_DATA'
    and fisc.action_information1(+)='S20.G01.00.011'
    and fisc.action_information3(+) = comp.action_information3;
  --
  -- Cursor for S30 header
  Cursor csr_s30_header_data(c_asg_action_id number,
                             c_company_id number) is
  Select nvl(title.action_information5,null)      emp_title,
         nvl(title.action_information8 ,null)     emp_number,
         nvl(first_name.action_information4,null) emp_first,
         nvl(last_name.action_information4,null)  emp_last
  from pay_action_information title,
       pay_action_information first_name,
       pay_action_information last_name
  where title.action_context_id = c_asg_action_id
    and title.action_context_type = 'AAP'
    and title.action_information_category = 'FR_DADS_FILE_DATA'
    and title.action_information1 = 'S30.G01.00.007'
    and title.action_information3 = c_company_id
    --
    and first_name.action_context_id = c_asg_action_id
    and first_name.action_context_type = 'AAP'
    and first_name.action_information_category = 'FR_DADS_FILE_DATA'
    and first_name.action_information1 = 'S30.G01.00.003'
    and first_name.action_information3 = c_company_id
    --
    and last_name.action_context_id = c_asg_action_id
    and last_name.action_context_type = 'AAP'
    and last_name.action_information_category = 'FR_DADS_FILE_DATA'
    and last_name.action_information1 = 'S30.G01.00.004'
    and last_name.action_information3 = c_company_id;
  --
-- Cursor for S41 header
cursor csr_s41_header_data(c_asg_action_id number,
                           c_company_id number,
                           c_s41_id2 number) is
Select hou_tl_estab.name         emp_estab,
       start_period.action_information4 period_start,
       end_period.action_information4   period_end
from pay_action_information estab,
     pay_action_information start_period,
     pay_action_information end_period,
     hr_all_organization_units_tl hou_tl_estab
where estab.action_context_id = c_asg_action_id
  and estab.action_context_type = 'AAP'
  and estab.action_information_category = 'FR_DADS_FILE_DATA'
  and estab.action_information1 = 'S41.G01.00.005'
  and estab.action_information3 = c_company_id
  and estab.action_information8 = c_s41_id2
  and hou_tl_estab.organization_id(+) = estab.action_information7
  and hou_tl_estab.language(+) = userenv('LANG')
  --
  and start_period.action_context_id = c_asg_action_id
  and start_period.action_context_type = 'AAP'
  and start_period.action_information_category = 'FR_DADS_FILE_DATA'
  and start_period.action_information1 = 'S41.G01.00.001'
  and start_period.action_information3 = c_company_id
  and start_period.action_information8 = c_s41_id2
  --
  and end_period.action_context_id = c_asg_action_id
  and end_period.action_context_type = 'AAP'
  and end_period.action_information_category = 'FR_DADS_FILE_DATA'
  and end_period.action_information1 = 'S41.G01.00.003'
  and end_period.action_information3 = c_company_id
  and end_period.action_information8 = c_s41_id2;
--
-- Cursor for S80 header
Cursor csr_s80_header_data(c_payroll_action_id number,
                           c_estab_id number)is
Select action_information4 estab_name
from pay_action_information
where action_context_id = c_payroll_action_id
  and action_context_type = 'PA'
  and action_information_category = 'FR_DADS_FILE_DATA'
  and action_information1 = 'S80.G01.00.002'
  and action_information3 = c_estab_id;
--
   -- Procedure for writing into files
    PROCEDURE write_into_file (p_rubric_code            varchar2,
                               p_error_warning          varchar2,
                               p_error_warning_message  varchar2) is
    --
    BEGIN
    --
    hr_utility.set_location('Entering the procedure Write into file',1);

    -- Print the error message
    fnd_file.put_line(fnd_file.output,p_error_warning||':'||p_rubric_code||':'||p_error_warning_message);
    -- insert a line after each rubric
    fnd_file.new_line(fnd_file.output, 1);

    hr_utility.set_location('leaving write into file',3);

    END write_into_file;
    --

  -- Function for returning sort rubrics
  FUNCTION get_sort_rubrics(p_sort_order VARCHAR2) return varchar2
  IS
  BEGIN
  --
  IF p_sort_order = '31' THEN
     -- return rubric for zip code
     RETURN 'S30.G01.00.008.010';
  ELSIF p_sort_order = '32' THEN
     -- return rubric for name
     RETURN 'S30.G01.00.004';
  ELSIF p_sort_order = '33' THEN
     -- return rubric for ss number
     RETURN 'S30.G01.00.001';
  ELSIF p_sort_order = '34' THEN
     -- return rubric for ss number
     -- to pick up the id2 col for emp number
     RETURN 'S30.G01.00.001';
  END IF;
  return null;
  --
  END get_sort_rubrics;
--
BEGIN
-- fetch the sort order rubrics
--hr_utility.trace_on (null, 'AY_FOR_TRACE');
hr_utility.set_location('Entered the procedure control_proc',1);
  l_sort_rubric1 := get_sort_rubrics(p_sort_order_1);
-- As p_sort_order_2 is not a mandatory parameter
IF p_sort_order_2 IS NOT NULL THEN
  l_sort_rubric2 := get_sort_rubrics(p_sort_order_2);
END IF;

-- Retreive the error message for Declaration Type Code
   IF (P_DECLARATION_NATURE = '02' OR P_DECLARATION_NATURE = '01') AND
           P_DECLARATION_TYPE = '55' THEN
       l_value := pay_fr_general.get_payroll_message('PAY_75191_INCOMPAT_DATA',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.001'),
         'VALUE2:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.002'), null);
    ELSIF P_DECLARATION_NATURE = '05' AND P_DECLARATION_TYPE <> '55' THEN
       l_value := pay_fr_general.get_payroll_message('PAY_75191_INCOMPAT_DATA',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.001'),
         'VALUE2:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.002'), null);
    ELSE
         l_value := null;
    END IF;

  -- fetch the payroll action
hr_utility.set_location('Retreived Sort Orders ',2);
  OPEN csr_payroll_action;
  FETCH csr_payroll_action INTO l_payroll_action_id;
  CLOSE csr_payroll_action;
  -- Check for report inclusions
  IF P_REPORT_INCLUSIONS ='ORG' OR P_REPORT_INCLUSIONS='ALL' THEN
hr_utility.set_location('Entering S10 ',3);
     -- WRITE S10 DATA
     -- print header for S10
     OPEN csr_s10_header_data(l_payroll_action_id);
     FETCH csr_s10_header_data INTO l_header_issue_estab, l_s10_cre_estab;
     CLOSE csr_s10_header_data;
     -- get lookup meanings
     l_s10_heading_text :=hr_general.decode_lookup('FR_DADS_HEADINGS','S10_ISSUE_ESTAB_INFO');
     l_issuing_estab_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S10_ISSUE_ESTAB_NAME');
     l_cre_estab_text:= hr_general.decode_lookup('FR_DADS_HEADINGS','S10_CRE_ESTAB_NAME');
     --
     fnd_file.new_line(fnd_file.output,2);
     fnd_file.put_line(fnd_file.output,l_s10_heading_text);
     fnd_file.put_line(fnd_file.output,l_issuing_estab_text ||' : '||l_header_issue_estab);
     fnd_file.put_line(fnd_file.output,l_cre_estab_text||' : '||l_s10_cre_estab);
     fnd_file.new_line(fnd_file.output,1);
hr_utility.set_location('Printing the header ',4);
       -- fetch the values for s10
       FOR get_s10_rec IN csr_get_S10_rec(l_payroll_action_id) LOOP
            -- write the values of S10
            write_into_file (get_s10_rec.rubric_code,
                             get_s10_rec.error_warning,
                             get_s10_rec.error_warning_message);
            --
       END LOOP;
       -- END OF WRITING S10 DATA
     --
  END IF; --end of check for report inclusions
  -- Initialize the total number of employees and total number of companies to zero
  l_total_employees := 0;
  l_total_companies := 0;
  -- fetch the number of companies archived for the issuing estab
  FOR comp_rec IN csr_count_comp(l_payroll_action_id) LOOP
     --#3300005 Incrementing the number of companies by 1
     l_total_companies := l_total_companies + 1;
     -- Check for report inclusions
     IF P_REPORT_INCLUSIONS ='ORG' OR P_REPORT_INCLUSIONS='ALL' THEN
hr_utility.set_location('Entered into the company procedure ',5);
        -- WRITE S20 DATA
        -- print header for S20
        -- get lookup meanings
        l_s20_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_COMP_INFO');
        l_comp_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_COMP_NAME');
        l_hq_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_HQ_ESTAB_NAME');
        l_fisc_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S20_FISC_ESTAB_NAME');
        l_cre_estab_text:= hr_general.decode_lookup('FR_DADS_HEADINGS','S10_CRE_ESTAB_NAME');
        -- get cursor values
        OPEN csr_s20_header_data(l_payroll_action_id,comp_rec.company_id);
        FETCH csr_s20_header_data INTO l_comp_name, l_s20_cre_estab, l_hq_name, l_fisc_name;
        CLOSE csr_s20_header_data;
hr_utility.set_location('Printing the S20 header values',6);
        -- write the header into the file
        fnd_file.new_line(fnd_file.output,2);
        fnd_file.put_line(fnd_file.output,l_s20_heading_text);
        fnd_file.put_line(fnd_file.output,l_comp_text||' : '||l_comp_name);
        fnd_file.put_line(fnd_file.output,l_hq_text||' : '||l_hq_name);
        fnd_file.put_line(fnd_file.output,l_fisc_text||' : '||l_fisc_name);
        fnd_file.put_line(fnd_file.output,l_cre_estab_text||' : '||l_s20_cre_estab);
        fnd_file.new_line(fnd_file.output,1);
        --
hr_utility.set_location('Printing the S20 error values',7);
          -- Fetch S20 data
          FOR S20_data_rec IN csr_get_S20_data(l_payroll_action_id,
                                               comp_rec.company_id) LOOP
            IF S20_data_rec.rubric_code = 'S20.G01.00.004.002' and l_value is not null THEN
               write_into_file (S20_data_rec.rubric_code,
                                S20_data_rec.error_warning,
                                l_value);
	    ELSIF S20_data_rec.rubric_code = 'S20.G01.00.006' THEN
                -- check the declaration type
                IF p_declaration_type = 53 THEN -- if the type is 'correction'
                   -- Write the calendar year to which salaries are attached
               write_into_file (S20_data_rec.rubric_code,
                                S20_data_rec.error_warning,
                                S20_data_rec.error_warning_message);
                   --
                END IF;
                --  The Declaration Type Code must not be printed in the Exceptions Report
            ELSIF S20_data_rec.rubric_code <> 'S20.G01.00.004.002' THEN
               -- Write S20 data to the report
               write_into_file (S20_data_rec.rubric_code,
                                S20_data_rec.error_warning,
                                S20_data_rec.error_warning_message);
                 --
            END IF;
          END LOOP;
    END IF;
    -- Exclude S30 and S41 if declaration nature code is '05'
    IF p_declaration_nature <> '05'
      -- check for report inclusions
      AND (P_REPORT_INCLUSIONS= 'EMP' OR P_REPORT_INCLUSIONS= 'ALL') THEN
      -- build up the query conditionally
      l_s30_select := 'Select pasac.assignment_action_id
      	               from pay_assignment_actions pasac,
      	                    pay_action_information pacinfo_1';
      l_s30_where :=' where pasac.payroll_action_id = '||l_payroll_action_id||'
      	                and pacinfo_1.action_context_id = pasac.assignment_action_id
      	                and pacinfo_1.action_context_type =''AAP''
      	                and pacinfo_1.action_information1 = '|| '''' ||l_sort_rubric1|| ''''||'
      	                and pacinfo_1.action_information3 = '||comp_rec.company_id||'';
      -- As p_sort_order_2 is not a mandatory parameter
      IF p_sort_order_2 IS NOT NULL THEN
      	 l_s30_cond_from  := ' ,pay_action_information pacinfo_2';
      	 l_s30_cond_where := 'and pacinfo_2.action_context_id = pasac.assignment_action_id
      	                      and pacinfo_2.action_context_type =''AAP''
      	                      and pacinfo_2.action_information1 = '|| '''' ||l_sort_rubric2|| ''''||'
                              and pacinfo_2.action_information3 = '||comp_rec.company_id||'';
         IF p_sort_order_2 = '34' THEN
            l_s30_cond_order_by := ',pacinfo_2.action_information8';
         ELSE
            l_s30_cond_order_by := ',pacinfo_2.action_information4';
         END IF;
      ELSE
      	 l_s30_cond_from  := '';
      	 l_s30_cond_where := '';
      	 l_s30_cond_order_by := '';
      END IF;
      IF  p_sort_order_1 = '34' THEN
      	  l_s30_order_by := ' order by pacinfo_1.action_information8';
      ELSE
      	  l_s30_order_by := ' order by pacinfo_1.action_information4';
      END IF;
      -- fetch assignment action ids for this payroll action ids and loop
      OPEN ref_csr_asg_action FOR l_s30_select||l_s30_cond_from||l_s30_where||l_s30_cond_where||l_s30_order_by||l_s30_cond_order_by;
      LOOP
         FETCH ref_csr_asg_action INTO l_asg_action_id;
         EXIT WHEN ref_csr_asg_action%NOTFOUND;
	 -- Increment the number of employee by one
         l_total_employees := l_total_employees + 1;
         -- WRITE S30 DATA
         -- print header for S30
         -- get  the lookup values
         l_s30_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S30_EMP_INFO');
         l_emp_name_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S30_EMP_NAME');
         l_emp_number_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S30_EMP_NUMBER');
         -- fetch the header values
         OPEN csr_s30_header_data(l_asg_action_id,
                                  comp_rec.company_id);
         FETCH csr_s30_header_data INTO l_header_emp_title,
                                        l_header_emp_number,
                                        l_header_first_name,
                                        l_header_last_name;
         CLOSE csr_s30_header_data;
         -- write the header lines for s30
         fnd_file.new_line(fnd_file.output,2);
         fnd_file.put_line(fnd_file.output,l_s30_heading_text);
         fnd_file.put_line(fnd_file.output,l_emp_name_text||' : '||l_header_emp_title||' '||l_header_first_name||' '||l_header_last_name);
         fnd_file.put_line(fnd_file.output,l_emp_number_text||' : '||l_header_emp_number);
         fnd_file.new_line(fnd_file.output,1);
         --
           -- fetch s30 data archived for this company and assignment action
           FOR S30_data_rec IN csr_get_S30_data(l_asg_action_id,
                                                comp_rec.company_id) LOOP
	     -- Write S30 data to the report
               write_into_file (S30_data_rec.rubric_code,
                                S30_data_rec.error_warning,
                                S30_data_rec.error_warning_message);
             --
           END LOOP;
         -- fetch the number of s41 records archived for each s30
         FOR count_s41_rec IN csr_count_s41(l_asg_action_id,
                                           comp_rec.company_id) LOOP
           -- WRITE S41 DATA
           -- print header for S41
           -- get lookup values
           l_s41_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_FISCAL_INFO');
           l_emp_estab_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_EMP_ESTAB');
           l_start_date_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_START_DATE');
           l_end_date_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S41_END_DATE');
           -- fetch header values
           OPEN csr_s41_header_data(l_asg_action_id,
                                    comp_rec.company_id,
                                  count_s41_rec.id2);
           FETCH csr_s41_header_data INTO l_emp_header_estab_name,
                                          l_header_start_period,
                                          l_header_end_period;
           CLOSE csr_s41_header_data;
           -- Write the header lines
           fnd_file.new_line(fnd_file.output,2);
           fnd_file.put_line(fnd_file.output,l_s41_heading_text);
           fnd_file.put_line(fnd_file.output,l_emp_name_text||' : '||l_header_emp_title||' '||l_header_first_name||' '||l_header_last_name);
           fnd_file.put_line(fnd_file.output,l_emp_number_text||' : '||l_header_emp_number);
           fnd_file.put_line(fnd_file.output,l_emp_estab_text||' : '||l_emp_header_estab_name);
           fnd_file.put_line(fnd_file.output,l_start_date_text||' : '||l_header_start_period);
           fnd_file.put_line(fnd_file.output,l_end_date_text||' : '||l_header_end_period);
           fnd_file.new_line(fnd_file.output, 1);
           --
             -- fetch S41 records
             FOR s41_data_rec IN csr_get_s41_data(l_asg_action_id,
                                                  comp_rec.company_id,
                                                  count_s41_rec.id2) LOOP
                 -- Exclude rubrics selectively for decl code '02'
                 -- Exclude rubrics selectively for decl code '02'
                 IF p_declaration_nature <>2 OR
                   (p_declaration_nature = '02' AND
                    substr(S41_data_rec.rubric_code,13,2)
                       NOT IN (29,30,32,33,35,37,42,44,49,52,66)) THEN
                       -- Write S41 data into report
                      write_into_file (S41_data_rec.rubric_code,
                                S41_data_rec.error_warning,
                                S41_data_rec.error_warning_message);
                    --
                 END IF;
                 --
             END LOOP;
           -- END OF WRITING S41 DATA
         -- end loop for number of s41 records
         END LOOP;
      -- END OF WRITING S30 DATA
      -- end loop for assignment actions
      END LOOP;
      -- #3300005 Printing the warning message, when there are no employees for the given company
      IF l_total_employees = 0 THEN
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, pay_fr_general.get_payroll_message('PAY_75195_DADS', 'VALUE1:'||l_comp_name));
      ELSE
         l_total_employees := 0;
      END IF;
    -- end of exclusion for '05' decl nature code
    END IF;
 -- END OF WRITING S20 DATA
 -- end loop for companies archived
 END LOOP;
 --
 -- #3300005 Printing the warning message when there are no companies in the establishment
 IF l_total_companies = 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, pay_fr_general.get_payroll_message('PAY_75198_DADS_NO_COMPANY','VALUE1:'||l_header_issue_estab));
 END IF;
 -- Get number of INSEE establishments archived
 FOR count_s80_rec IN csr_count_s80(l_payroll_action_id) LOOP
    -- Check for report inclusions
    IF P_REPORT_INCLUSIONS= 'ALL' THEN
       -- WRITE S80 DATA
       -- print header for S80
       -- get lookup values
       l_s80_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S80_ESTAB_INFO');
       l_s80_estab_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S80_ESTAB_NAME');
       -- fetch header data
       OPEN csr_s80_header_data(l_payroll_action_id,count_s80_rec.estab_id);
       FETCH csr_s80_header_data INTO l_s80_header_estab_name;
       CLOSE csr_s80_header_data;
       -- write header lines for s80
       fnd_file.new_line(fnd_file.output,2);
       fnd_file.put_line(fnd_file.output,l_s80_heading_text);
       fnd_file.put_line(fnd_file.output,l_s80_estab_text||' : '||l_s80_header_estab_name);
       fnd_file.new_line(fnd_file.output, 1);
       --
         -- Get S80 data
         FOR s80_data_rec IN csr_get_s80_data(l_payroll_action_id,
                                              count_s80_rec.estab_id)LOOP
            -- write s80 data
               write_into_file (S80_data_rec.rubric_code,
                                S80_data_rec.error_warning,
                                S80_data_rec.error_warning_message);
            --
         END LOOP;
       --
    END IF;
  -- END OF WRITING S80 DATA
  END LOOP;
  -- WRITE S90 DATA
  -- print header for S90
  l_s90_heading_text := hr_general.decode_lookup('FR_DADS_HEADINGS','S90_TOTALS');
  fnd_file.new_line(fnd_file.output,2);
  fnd_file.put_line(fnd_file.output,l_s90_heading_text);
  fnd_file.new_line(fnd_file.output,1);
  --
      -- Get s90 data
    FOR s90_data_rec IN csr_get_s90_data(l_payroll_action_id) LOOP
       IF p_declaration_nature = '02' THEN
          -- Check for report inclusions
          IF P_REPORT_INCLUSIONS= 'ALL' THEN
             -- print rubric data selectively
             IF S90_data_rec.rubric_code <> 'S90.G01.00.009' THEN
                -- Write S90 data into report
               write_into_file (S90_data_rec.rubric_code,
                                S90_data_rec.error_warning,
                                S90_data_rec.error_warning_message);
             END IF;
             --
          END IF;
          --
       END IF;
       --
    END LOOP;
    -- END OF WRITING S90 DATA
  --
  EXCEPTION
     WHEN OTHERS THEN raise;
  --
END control_proc;
--
end pay_fr_dads_f_pkg;

/
