--------------------------------------------------------
--  DDL for Package Body PAY_GB_P6EDI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P6EDI_PKG" AS
/* $Header: pygbp6ei.pkb 120.4 2007/11/02 10:53:34 dchindar noship $ */
-- --------------- p6 upload process ---------------------
--
-- uploads p6 information from flat file into
-- pay_gb_tax_code_interface table
--
PROCEDURE upload_p6(errbuf OUT NOCOPY VARCHAR2,
                    retcode OUT NOCOPY NUMBER,
                    p_request_id in number default null,
                    p_filename IN VARCHAR2,
                    p_mode IN NUMBER,
                    p_effective_date IN varchar2,
                    p_business_group_id IN NUMBER,
                    --   p_authority  IN varchar2 default null, /*change for soy 08-09*/
		    p_validate_only IN varchar2 ) IS
  l_date_of_message        VARCHAR2(10) := null;
  l_form_type              VARCHAR2(10) := null;
  l_form_number            VARCHAR2(1) := null;
  l_district_number        VARCHAR2(3) := null;
  l_employer_reference     VARCHAR2(10) := null;
  l_ni_number              VARCHAR2(9) := null;
  l_works_number           VARCHAR2(20) := null;
  l_total_pay_prev_emp     VARCHAR2(35) := null;
  l_total_tax_prev_emp     VARCHAR2(35) := null;
  l_tax_code               VARCHAR2(10) := null;
  l_employee_name          VARCHAR2(28) := null;
  l_effective_date         VARCHAR2(20) := null;
  l_issue_date             VARCHAR2(10) := null;
  l_week1_month1_indicator VARCHAR2(1) := '';
  l_record_no              NUMBER := 0;
  l_present_line           VARCHAR2(250) := null;
  l_processing             BOOLEAN := true;
  l_line_number            NUMBER := 0;
  l_start_of_employer      BOOLEAN := false;
  l_file_handle            utl_file.file_type;
  l_qualifier              VARCHAR2(3);
  l_filename               VARCHAR2(100);
  l_location               VARCHAR2(2000);
  e_fatal_error            exception;
  l_record_name            varchar2(5);
  l_previous_record        varchar2(5);
  l_previous_qualifier     varchar2(3);
  l_lines_inserted         number := 0;
  l_pyudet_id              number;
  l_request_id             number;

begin
--
--  hr_utility.trace_on(null,'P6');
  hr_utility.set_location('PAY_GB_P6EDI.upload_p6',5);
--
  l_filename := p_filename;
--
-- Get I/O Directory
--
  fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_location);
--
-- Get request id
  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

  hr_utility.trace('directory: <'|| l_location || '>');
  if l_location is null then
    -- error : I/O directory not defined
    retcode := 2;
    errbuf := 'Input directory not defined. Set PER_DATA_EXCHANGE_DIR profile (HR: Data Exchange directory).';
    hr_utility.trace('Input directory not defined in PER_DATA_EXCHANGE_DIR profile.');
    raise e_fatal_error;
  end if;
--
-- Open flat file
--
  l_file_handle := utl_file.fopen(l_Location,l_filename,'r');
--
  utl_file.get_line(l_file_handle,l_present_line);
--
  hr_utility.set_location('PAY_GB_P6EDI.upload_p6',10);
  hr_utility.trace('line: '|| l_present_line);
--
  if l_present_line = null then
    l_processing := false;
-- the deletion is moved to the pyudet.run_process
--  else
    -- clean the interface table
--    delete from pay_gb_tax_code_interface;
--    commit;
  end if;
--
  while l_processing loop
    l_start_of_employer := false;
    l_record_name := rtrim(ltrim(substr(l_present_line,1,5)));
    l_qualifier := get_qualifier(l_present_line);
    hr_utility.trace('l_rec_name is <' || l_record_name || '>');
    hr_utility.trace('l_quali is <' || l_qualifier || '>');

    -- For Bug fix 4232473, resetting record count to Zero for each set of
    -- Employer Reference records.
    if l_record_name = '****0' then
        l_record_no := 0;
    end if;

    if l_record_name = 'BGM1' then -- get form type
      l_form_number := substr(l_present_line,7,1);
      if l_form_number not in ('1','2','3') then
        -- error, form type error.
        retcode := 2;
        errbuf := 'This process only accepts P6, P6B and P9.';
        --
        hr_utility.trace('Form Type is not one of these: P6, P6B or P9.');
        raise e_fatal_error;
      else
        if l_form_number = '1' then
          l_form_type := 'P6';
        elsif l_form_number = '2' then
          l_form_type := 'P6B';
        elsif l_form_number = '3' then
          l_form_type := 'P9';
        end if;
      end if;
    elsif l_record_name = 'NAD1A' and l_qualifier = 'BG' then
      -- employer's group starts here
      l_start_of_employer := true;
    elsif l_record_name = 'ATT1' then
      if l_qualifier = '7' then
        l_employer_reference := process_att(l_present_line, l_qualifier);
      elsif l_qualifier = '17' then
        l_district_number := process_att(l_present_line, l_qualifier);
      end if;
    elsif l_record_name = 'DTM1' and l_qualifier = '243' then
      l_date_of_message := process_date(l_present_line);
    elsif l_record_name = 'UNS1' then  --section separator
      l_record_no := 0;
    elsif l_record_name = 'LIN1' then  --new employee
      l_record_no := l_record_no + 1;
    elsif l_record_name = 'NAD2B' then
      hr_utility.trace('in NAD2B: l_prev_rec is <' || l_previous_record || '>');
      hr_utility.trace('in NAD2B: l_prev_qual is <' || l_previous_qualifier || '>');
      if l_previous_record = 'NAD2A' and l_previous_qualifier = 'BV' then
        l_employee_name := get_name(l_present_line);
--        l_employee_name := ltrim(rtrim(l_employee_name || ' ' || substr(l_present_line,43,1)));
        hr_utility.trace('employee name is (' || l_employee_name || ')');
      else
        -- error, file format error.
        retcode := 2;
        errbuf := 'The Input File does not follow the required format.';
        --
        hr_utility.trace('Format Error at line ' || to_char(l_line_number) || '.');
        hr_utility.trace('Employee name does not have a required NAD2A previous record.');
        raise e_fatal_error;
      end if;
    elsif l_record_name = 'ATT2' then
      if l_qualifier = '11' then
        l_ni_number := process_att(l_present_line, l_qualifier);
      elsif l_qualifier = '19' then
        l_works_number := process_att(l_present_line, l_qualifier);
      end if;
    elsif l_record_name = 'MOA1' then
      if l_previous_record = 'TAX1' then
        if l_previous_qualifier = '77' then
          l_total_pay_prev_emp := process_tax(l_present_line,1);
        elsif l_previous_qualifier = '81' then
          l_total_tax_prev_emp := process_tax(l_present_line,1);
        end if;
      else
        -- error, file format error.
        retcode := 2;
        errbuf := 'The Input File does not follow the required format.';
        --
        hr_utility.trace('Format Error at line ' || to_char(l_line_number) || '.');
        hr_utility.trace('Amount does not have a required TAX1 previous record.');
        raise e_fatal_error;
      end if;
    elsif l_record_name = 'DTM2' then
      if l_qualifier = '7' then
        l_effective_date := process_date(l_present_line);
      elsif l_qualifier = '182' then
        l_issue_date := process_date(l_present_line);
      end if;
    elsif l_record_name = 'ALC1' then
      l_tax_code := process_tax(l_present_line,2);
      l_week1_month1_indicator := '';   -- next line may have w1m1_indicator
    elsif l_record_name = 'ATT3' then
      if ((l_previous_record = 'ALC1') or (l_previous_record = 'ATT3')) then
        if l_qualifier = '1' then -- Scottish Variable Rate indicator found
          l_tax_code := 'S' || l_tax_code;
        elsif l_qualifier = '2' then
          l_week1_month1_indicator := 'Y';
        else
          -- error, file format error.
          retcode := 2;
          errbuf := 'The Input File does not follow the required format.';
          --
          hr_utility.trace('Format Error at line ' || to_char(l_line_number) || '.');
          hr_utility.trace('Week1/Month1 or SVR indicator does not have a required ALC1 previous record.');
          raise e_fatal_error;
        end if;
      end if;
    end if;
    --
    --
    l_previous_record := l_record_name;
    l_previous_qualifier := l_qualifier;
    l_line_number := l_line_number + 1;
    --
    --
    if mod(l_lines_inserted,20) = 0 then
      commit;
    end if;
    --
    --  new employee or employer found, so upload the record just processed
    --
    if (((l_record_name = 'LIN1' or
          (l_start_of_employer = true)) and (l_record_no > 1)) or
        (l_record_name = 'UNS2')) then

      write_to_database(l_date_of_message,
                       l_form_type,
                       l_district_number,
                       l_employer_reference,
                       l_ni_number,
                       l_works_number,
                       l_total_pay_prev_emp,
                       l_total_tax_prev_emp,
                       l_tax_code,
                       l_week1_month1_indicator,
                       l_employee_name,
                       l_effective_date,
                       l_issue_date,
                       l_request_id);

      l_lines_inserted := l_lines_inserted + 1;
      l_ni_number := null;
      l_works_number := null;
      l_total_pay_prev_emp := null;
      l_total_tax_prev_emp := null;
      l_tax_code := null;
      l_employee_name := null;
    end if;
--
--
--  read next line
--
--
      begin
        utl_file.get_line(l_file_handle,l_present_line);
        --
        hr_utility.set_location('PAY_GB_P6EDI.upload_p6',50);
        hr_utility.trace('line: '|| l_present_line);
        --
      exception
        when no_data_found then
          l_processing := false;
          EXIT;
      end;
--
--
  end loop;
--
--
  hr_utility.set_location('PAY_GB_P6EDI.upload_p6',60);
  hr_utility.trace('PAY_GB_P6EDI.upload_p6 - committing...');
  commit;
--
--
  utl_file.fclose(l_file_handle);
--
-- Call PYUDET mode 4
--
  l_pyudet_id := fnd_request.submit_request(application => 'PAY',
                                            program     => 'PYUDET',
                                            argument1   => p_request_id,
                                            argument2   => p_mode,
                                            argument3   => p_effective_date,
                                            argument4   => p_business_group_id,
                                            argument5   => null,
                                            argument6   => l_form_type,  --p_authority,
                                            argument7   => l_request_id,
					    argument8   => p_validate_only); --added soy 08-09*/
--
--
  hr_utility.trace('The pyudet request ID is '||to_char(l_pyudet_id));
  hr_utility.trace('Finished P6 UPLOAD PROCESS.');
--
--
  retcode := 0;
  errbuf := 'No errors - examine logfiles for detailed reports.';
--hr_utility.trace_off;
--
--
exception
  when e_fatal_error then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',100);
    rollback;
  when UTL_FILE.INVALID_OPERATION then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',110);
    retcode:=2;
    errbuf := 'Reading P6 File - Invalid Operation (file not found).';
  when UTL_FILE.INTERNAL_ERROR then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',120);
    retcode:=2;
    errbuf := 'Reading P6 File - Internal Error.';
  when UTL_FILE.INVALID_MODE then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',130);
    retcode:=2;
    errbuf := 'Reading P6 File - Invalid Mode.';
  when UTL_FILE.INVALID_PATH then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',140);
    retcode:=2;
    errbuf := 'Reading P6 File - Invalid Path.';
 when UTL_FILE.INVALID_FILEHANDLE then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',150);
    retcode:=2;
    errbuf := 'Reading P6 File - Invalid File Handle.';
 when UTL_FILE.READ_ERROR then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',160);
    retcode:=2;
    errbuf := 'Reading P6 File - Read Error.';
 when NO_DATA_FOUND then
    UTL_FILE.FCLOSE(l_file_handle);
    hr_utility.set_location('PAY_GB_P6EDI.upload_p6',170);
    retcode:=2;
    errbuf := 'No Data Found.';
end;


FUNCTION get_qualifier(line VARCHAR2)
  return VARCHAR2 is
  qualifier VARCHAR2(3);
begin
--
  qualifier := substr(line,7,3);
--
  hr_utility.set_location('PAY_GB_P6EDI.get_qualifier',70);
  hr_utility.trace('qualifier is: ' || qualifier);
--
  return ltrim(rtrim(qualifier));
end;

FUNCTION get_name(line VARCHAR2)
  return VARCHAR2 is
  name VARCHAR2(26);
begin
--
  name := substr(line,7,26);
--
  hr_utility.set_location('PAY_GB_P6EDI.get_name',75);
  hr_utility.trace('name is: <' || name || '>');
--
  return ltrim(rtrim(name));
end;


FUNCTION process_att(line VARCHAR2, qualifier VARCHAR2)
  return VARCHAR2 is
  string_to_return VARCHAR2(20);
begin
--
  if qualifier = '17' then -- returns district_number
    string_to_return := substr(line,11,3);
  elsif qualifier = '7' then -- returns employer reference
    string_to_return := substr(line,11,10);
  elsif qualifier = '11' then -- returns ni number
    string_to_return := substr(line,11,9);
  elsif qualifier = '19' then -- returns works number
    string_to_return := substr(line,11,20);
  end if;
--
  hr_utility.set_location('PAY_GB_P6EDI.process_att',80);
  hr_utility.trace('string is: ' || string_to_return);
--
  return ltrim(rtrim(string_to_return));
end;


FUNCTION process_date(line VARCHAR2)
  return VARCHAR2 is
  l_date_type      VARCHAR2(3) := null;
  string_to_return VARCHAR2(10) := null;
begin
--
  l_date_type := substr(line,47,3);
  if l_date_type = '102' then
    string_to_return := substr(line,11,4) || '/' ||
                        substr(line,15,2) || '/' ||
                        substr(line,17,2);
  end if;
--
  hr_utility.set_location('PAY_GB_P6EDI.process_date',85);
  hr_utility.trace('string is: ' || string_to_return);
--
  return ltrim(rtrim(string_to_return));
end;


FUNCTION process_tax(line VARCHAR2, process_type NUMBER)
  return VARCHAR2 is
  string_to_return VARCHAR2(35);
begin
--
  if process_type = 1 then  -- returns amount
    string_to_return := substr(line,7,35);
  elsif process_type = 2 then -- returns tax code
    string_to_return := substr(line,11,7);
  end if;
--
  hr_utility.set_location('PAY_GB_P6EDI.process_tax',90);
  hr_utility.trace('string is: ' || string_to_return);
--
  return ltrim(rtrim(string_to_return));
end;

PROCEDURE write_to_database(date_of_message_p VARCHAR2,
                           form_type_p VARCHAR2,
                           district_number_p VARCHAR2,
                           employer_reference_p VARCHAR2,
                           ni_number_p VARCHAR2,
                           works_number_p VARCHAR2,
                           total_pay_prev_emp_p VARCHAR2,
                           total_tax_prev_emp_p VARCHAR2,
                           tax_code_p VARCHAR2,
                           week1_month1_indicator_p VARCHAR2,
                           employee_name_p VARCHAR2,
                           effective_date_p VARCHAR2,
                           issue_date_p VARCHAR2,
                           request_id_p number default null) IS
begin
  hr_utility.set_location('PAY_GB_P6EDI.write_to_database',95);

  hr_utility.trace('tushar employee name is  '||employee_name_p);
  INSERT INTO pay_gb_tax_code_interface(
                           date_of_message,
                           effective_date,
                           issue_date,
                           form_type,
                           district_number,
                           employer_reference,
                           national_insurance_number,
                           tot_pay_prev_emp,
                           tot_tax_prev_emp,
                           tax_code,
                           non_cumulative_flag,
                           employee_name,
                           works_number,
                           processed_flag,
                           request_id)
                           VALUES (
                           fnd_date.canonical_to_date(date_of_message_p),
                           fnd_date.canonical_to_date(effective_date_p),
                           fnd_date.canonical_to_date(issue_date_p),
                           form_type_p,
                           to_number(district_number_p),
                           employer_reference_p,
                           ni_number_p,
                           total_pay_prev_emp_p,
                           total_tax_prev_emp_p,
                           tax_code_p,
                           week1_month1_indicator_p,
                           employee_name_p,
                           works_number_p,
                           '',
                           request_id_p);
end;

end pay_gb_p6edi_pkg;


/
