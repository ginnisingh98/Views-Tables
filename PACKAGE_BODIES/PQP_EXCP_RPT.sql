--------------------------------------------------------
--  DDL for Package Body PQP_EXCP_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EXCP_RPT" AS
/* $Header: pqpexrcp.pkb 120.0 2005/05/29 01:56:54 appldev noship $ */

procedure PQP_EXR_CSV_FORMAT (errbuf OUT NOCOPY VARCHAR2
                    ,retcode OUT NOCOPY NUMBER
                    ,p_ppa_finder IN VARCHAR2
                    ,p_report_date IN VARCHAR2
                    ,p_business_group_id IN NUMBER
                    ,p_report_name IN VARCHAR2
                    ,p_group_name IN VARCHAR2
                    ,p_override_variance_type IN VARCHAR2
                    ,p_override_variance_value IN NUMBER
                    )
IS

  --
  -- Cursor to get the row from the pay_us_rpt_totals table
  --
  CURSOR c_exception_report_data IS
  SELECT
  fnd_number.canonical_to_number(purt.business_group_id) business_group_id,
  fnd_number.canonical_to_number(purt.tax_unit_id)    payroll_action_id,
  fnd_number.canonical_to_number(purt.value1)         current_balance,
  fnd_number.canonical_to_number(purt.value2)         previous_balance,
  fnd_number.canonical_to_number(purt.attribute1)     balance_type_id,
  fnd_number.canonical_to_number(purt.attribute2)     report_id,
  fnd_number.canonical_to_number(purt.attribute3)     group_id,
  fnd_number.canonical_to_number(purt.attribute4)     consolidation_set_id,
  fnd_number.canonical_to_number(purt.attribute5)     payroll_id,
  fnd_number.canonical_to_number(purt.attribute6)     assignment_id,
  purt.attribute14                                    full_name,
  purt.attribute7                                     last_name,
  purt.attribute8                                     first_name,
  purt.attribute10                                    middle_name,
  purt.attribute9                                     national_id,
  purt.attribute11                                    effective_date,
  purt.attribute13                                    assignment_number
  FROM      pay_us_rpt_totals purt
  WHERE    organization_id=p_ppa_finder
    AND    purt.attribute12 = p_ppa_finder
  ORDER BY purt.attribute7;
  -- End of Cursor

  --
  -- Cursor to get the payroll name
  --
  CURSOR c_get_payroll_name(
         p_payroll_id pay_payrolls_f.payroll_id%TYPE,
         p_consolidation_set_id pay_payrolls_f.consolidation_set_id%TYPE,
         p_business_group_id pay_payrolls_f.business_group_id%TYPE,
         p_date DATE
  )
  IS
  SELECT payroll_name
    FROM  pay_payrolls_f
   WHERE  payroll_id=p_payroll_id
     AND  consolidation_set_id=p_consolidation_set_id
     AND  (business_group_id = p_business_group_id
      OR    business_group_id IS NULL)
     AND  trunc(p_date) between effective_start_date and effective_end_date;
  -- End of cursor

  --
  -- Cursor to get the consolidation set name
  --
  CURSOR c_get_consolidation_set_name(
  p_consolidation_set_id pay_consolidation_sets.consolidation_set_id%TYPE,
  p_business_group_id pay_consolidation_sets.business_group_id%TYPE
  )
  IS
  SELECT consolidation_set_name
    from pay_consolidation_sets
   WHERE consolidation_set_id=p_consolidation_set_id
     AND (business_group_id =p_business_group_id
      OR business_group_id IS NULL);
  -- End of cursor

  --
  -- Cursor to get the balance name
  --
  CURSOR c_get_balance_name(
  p_balance_type_id pay_balance_types.balance_type_id%TYPE
  )
  IS
  SELECT DISTINCT balance_name
       FROM  pay_balance_types
      WHERE  balance_type_id=p_balance_type_id;

  --
  -- Cursor to get the leg_code and the currency code
  --
  CURSOR c_get_codes(
  p_business_group_id per_business_groups.business_group_id%TYPE
  )
  IS
  SELECT Distinct legislation_code,currency_code
    FROM per_business_groups
   WHERE business_group_id      =p_business_group_id;
  -- End of cursor


  --
  -- Cursor to get the values for variance value, comparison value,
  -- report name and output format
  --
  CURSOR c_get_values(
  p_report_id pqp_exception_reports.exception_report_id%TYPE,
  p_business_group_id pqp_exception_reports.business_group_id%TYPE,
  p_legislation_code pqp_exception_reports.legislation_code%TYPE
  )
  IS
  SELECT   variance_value
          ,comparison_value
	  ,exception_report_name
	  ,output_format
	  ,balance_dimension_id
     FROM   pqp_exception_reports
     WHERE  exception_report_id=p_report_id
       AND  (business_group_id IS NULL
        OR   business_group_id=p_business_group_id)
       AND  (legislation_code IS NULL
        OR    legislation_code=p_legislation_code) ;
  -- End of cursor


  --
  -- Cursor to get the comparison type from look up
  --
  CURSOR c_get_comparison_type(
  p_report_id pqp_exception_reports.exception_report_id%TYPE,
  p_business_group_id pqp_exception_reports.business_group_id%TYPE,
  p_legislation_code pqp_exception_reports.legislation_code%TYPE
  )
  IS
  SELECT meaning
    FROM  hr_lookups
   WHERE  lookup_type='PQP_COMPARISON_TYPE'
     AND   lookup_code=(
    SELECT   comparison_type
      FROM   pqp_exception_reports
     WHERE  exception_report_id=p_report_id
       AND  (business_group_id IS NULL
        OR   business_group_id=p_business_group_id)
       AND  (legislation_code IS NULL
        OR    legislation_code=p_legislation_code)) ;
  -- End of cursor

  --
  -- Cursor to get the variance type from the lookup
  --
  CURSOR c_get_variance_type(
  p_report_id pqp_exception_reports.exception_report_id%TYPE,
  p_business_group_id pqp_exception_reports.business_group_id%TYPE,
  p_legislation_code pqp_exception_reports.legislation_code%TYPE
  )
  IS
  SELECT  distinct hrl.meaning
    FROM   pqp_exception_reports per,
           hr_lookups hrl
   WHERE  per.exception_report_id=p_report_id
     AND  (per.business_group_id IS NULL
      OR   per.business_group_id=p_business_group_id)
     AND  (per.legislation_code IS NULL
      OR    per.legislation_code=p_legislation_code)
     AND  hrl.lookup_type = 'PQP_VARIANCE_TYPES'
     AND  hrl.lookup_code = per.variance_type;
  -- End of cursor

  --
  -- Cursor to get the variance operator from the look up
  --
  CURSOR c_get_variance_operator(
  p_report_id pqp_exception_reports.exception_report_id%TYPE,
  p_business_group_id pqp_exception_reports.business_group_id%TYPE,
  p_legislation_code pqp_exception_reports.legislation_code%TYPE
  )
  IS
  SELECT  meaning
    FROM  HR_LOOKUPS HRL
   WHERE  HRL.LOOKUP_TYPE = 'PQP_OPERATOR_TYPES'
     AND  HRL.ENABLED_FLAG = 'Y'
     AND  LOOKUP_CODE =(
     SELECT  distinct variance_operator
       FROM   pqp_exception_reports
      WHERE  exception_report_id=p_report_id
        AND  (business_group_id IS NULL
         OR   business_group_id=p_business_group_id)
        AND  (legislation_code IS NULL
         OR    legislation_code=p_legislation_code));
  -- End of cursor

  --
  -- Cursor to get the exception report group name
  --
  CURSOR c_get_exception_group_name(
  p_group_id pqp_exception_report_groups.exception_group_id%TYPE
  )
  IS
  SELECT EXCEPTION_GROUP_NAME
    FROM pqp_exception_report_groups
   WHERE EXCEPTION_GROUP_ID = p_group_id;
  -- End of cursor

  --
  -- Cursor to get the dimension name
  --
  CURSOR c_get_dimension_name(
  p_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE
  )
  IS
  select pbd.dimension_name dimension_name
    from pay_balance_dimensions pbd,
         pay_defined_balances pdb,
         pqp_exception_report_suffix ers
   where pbd.database_item_suffix = ers.database_item_suffix
     and ers.legislation_code = userenv('LANG')
     and pbd.balance_dimension_id = pdb.balance_dimension_id
     and pdb.balance_dimension_id = p_dimension_id;
  -- End of cursor

  --
  -- Cursor to get the output format
  --
  CURSOR c_get_output_format
  IS
  SELECT output_format
    FROM pqp_exception_reports
   WHERE exception_report_name = p_report_name
     AND (business_group_id= p_business_group_id
          OR business_group_id IS NULL)
  UNION
  SELECT DISTINCT output_format
    FROM pqp_exception_report_groups
   WHERE exception_group_name = p_group_name
     AND (business_group_id= p_business_group_id
          OR business_group_id IS NULL);
  -- End of cursor


--
-- Variables used to keep backup (old/Previous) values
--
l_payroll_id_old             pay_payrolls_f.payroll_id%TYPE;
l_consolidation_set_id_old   pay_consolidation_sets.consolidation_set_id%TYPE;
l_balance_type_id_old        pay_balance_types.balance_type_id%TYPE;
l_business_group_id_old      pqp_exception_reports.business_group_id%TYPE;
l_report_id_old              pqp_exception_reports.exception_report_id%TYPE;

--
-- Local Variables
--
l_payroll_name             pay_payrolls_f.payroll_name%TYPE;
l_consolidation_set_name   pay_consolidation_sets.consolidation_set_name%TYPE;
l_balance_name             pay_balance_types.balance_name%TYPE;
l_dimension_id             pqp_exception_reports.balance_dimension_id%TYPE;
l_dimension_name           pay_balance_dimensions.dimension_name%TYPE;
l_legislation_code         per_business_groups.legislation_code%TYPE;
l_currency_code            per_business_groups.currency_code%TYPE;
l_currency_format          varchar2(40);
l_variance_value           pqp_exception_reports.variance_value%TYPE;
l_comparison_value         pqp_exception_reports.comparison_value%TYPE;
l_exception_report_name    pqp_exception_reports.exception_report_name%TYPE;
l_exception_group_name pqp_exception_report_groups.exception_group_name%TYPE;
l_output_format            pqp_exception_reports.output_format%TYPE;
l_comparison_type          varchar2(80);
l_variance_type            pqp_exception_reports.variance_type%TYPE;
l_variance_operator        varchar2(80);
l_business_group_name      varchar2(80);
l_variance                 varchar2(100);
l_full_name                per_all_people_f.full_name%TYPE;
l_difference               number(10,2);
l_header_printed           boolean;
i number;

begin
--  hr_utility.trace_on(NULL,'YYY');
  hr_utility.trace('Entering Procedure PQP_EXR_CSV_FORMAT....');
  hr_utility.trace('Fnd_log.output :'||fnd_file.output);
  hr_utility.trace('Fnd_log.Log    :'||fnd_file.log);
  hr_utility.trace('ppa_finder     :'||p_ppa_finder);
  hr_utility.trace('report_date    :'||p_report_date);

  --
  -- Get the output format
  --
  OPEN c_get_output_format;
  FETCH c_get_output_format INTO l_output_format;
  CLOSE c_get_output_format;
  -- Close the cursor
  --
  -- If the output Format type is TXT then exit
  --
  IF l_output_format = 'TXT' THEN
     hr_utility.trace('Exited the Conc. Proc. when OutputFormat = TXT');
     RAISE NO_DATA_FOUND;
  END IF;



  --
  -- Initialize all the Backup Variables to -1 before Looping
  --
  l_payroll_id_old           := -1;
  l_consolidation_set_id_old := -1;
  l_balance_type_id_old      := -1;
  l_business_group_id_old    := -1;
  l_report_id_old            := -1;
  l_header_printed           := FALSE;

  --
  -- Loop for all the rows found in the pay_us_rpt_totals table
  --
  FOR r_excp_rpt_data IN c_exception_report_data
  LOOP


    hr_utility.trace('report_id    :'|| r_excp_rpt_data.report_id);
    hr_utility.trace('group_id    :'|| r_excp_rpt_data.group_id);
    hr_utility.trace('Payroll id : ' || r_excp_rpt_data.payroll_id);
    hr_utility.trace('Con Set id : ' || r_excp_rpt_data.consolidation_set_id);
    hr_utility.trace('Bg ID : ' || r_excp_rpt_data.business_group_id);


    IF r_excp_rpt_data.payroll_id <> l_payroll_id_old THEN
      --
      -- Get the Payroll Name
      --
      OPEN c_get_payroll_name(r_excp_rpt_data.payroll_id
                ,r_excp_rpt_data.consolidation_set_id
                ,r_excp_rpt_data.business_group_id
                ,fnd_date.canonical_to_date(p_report_date)
                );
      FETCH c_get_payroll_name INTO l_payroll_name;
      CLOSE c_get_payroll_name;
      -- Close cursor

      hr_utility.trace('Payroll Name : ' || l_payroll_name);
      l_payroll_id_old := r_excp_rpt_data.payroll_id;
    END IF;


    IF r_excp_rpt_data.consolidation_set_id <> l_consolidation_set_id_old THEN
      --
      -- Get the consolidation set name
      --
      OPEN c_get_consolidation_set_name(r_excp_rpt_data.consolidation_set_id
                                   ,r_excp_rpt_data.business_group_id);
      FETCH c_get_consolidation_set_name INTO l_consolidation_set_name;
      CLOSE c_get_consolidation_set_name;
      -- Close the cursor
      l_consolidation_set_id_old := r_excp_rpt_data.consolidation_set_id;
    END IF;


    IF r_excp_rpt_data.balance_type_id <> l_balance_type_id_old THEN
      --
      -- Get the balance name
      --
      OPEN c_get_balance_name(r_excp_rpt_data.balance_type_id);
      FETCH c_get_balance_name INTO l_balance_name;
      CLOSE c_get_balance_name;
      l_balance_type_id_old := r_excp_rpt_data.balance_type_id;

    END IF;

    IF r_excp_rpt_data.business_group_id <> l_business_group_id_old THEN
      --
      -- Get the leg_code and the currency code
      --
      OPEN c_get_codes(r_excp_rpt_data.business_group_id);
      FETCH c_get_codes INTO l_legislation_code,l_currency_code;
      CLOSE c_get_codes;
      -- Close the cursor
      --
      -- Get the business group name
      --
      l_business_group_name := hr_reports.get_business_group(
                               r_excp_rpt_data.business_group_id);

      l_business_group_id_old := r_excp_rpt_data.business_group_id;
    END IF;


    IF r_excp_rpt_data.report_id <> l_report_id_old THEN
      --
      -- Get the variance value, comparison value, report name, output format
      --
      OPEN c_get_values(r_excp_rpt_data.report_id
                     ,r_excp_rpt_data.business_group_id
                     ,l_legislation_code);
      FETCH c_get_values INTO l_variance_value,
                              l_comparison_value,
                              l_exception_report_name,
                              l_output_format,
                              l_dimension_id;
      CLOSE c_get_values;
      -- Close the cursor

      --
      -- Get the dimension name
      --
      OPEN c_get_dimension_name(l_dimension_id);
      FETCH c_get_dimension_name INTO l_dimension_name;
      CLOSE c_get_dimension_name;

      --
      -- Get the comparison type
      --
      OPEN c_get_comparison_type(r_excp_rpt_data.report_id
                                ,r_excp_rpt_data.business_group_id
                                ,l_legislation_code);
      FETCH c_get_comparison_type INTO l_comparison_type;
      CLOSE c_get_comparison_type;

      --
      -- get the variance type
      --
      OPEN c_get_variance_type(r_excp_rpt_data.report_id
                              ,r_excp_rpt_data.business_group_id
                              ,l_legislation_code);
      FETCH c_get_variance_type INTO l_variance_type;
      CLOSE c_get_variance_type;

      --
      -- Check if there is override Variance Type/Value
      --
      IF p_override_variance_type IS NOT NULL THEN
        l_variance_type := p_override_variance_type;
      END IF;

      IF p_override_variance_value IS NOT NULL THEN
        l_variance_value := p_override_variance_value;
      END IF;

      --
      -- Get the variance operator
      --
      OPEN c_get_variance_operator(r_excp_rpt_data.report_id
                                ,r_excp_rpt_data.business_group_id
                                ,l_legislation_code);
      FETCH c_get_variance_operator INTO l_variance_operator;
      CLOSE c_get_variance_operator;

      l_report_id_old := r_excp_rpt_data.report_id;

    END IF;

-- Code below is not being used and hence commented
    --
    -- Setup the Variance string
    --
    --IF l_variance_type = 'A' or l_variance_type = 'Amount' THEN
    --  l_variance := l_currency_code || ' ';
    --END IF;
    --l_variance := l_variance || l_variance_value;

    --IF l_variance_type = 'P' or l_variance_type = 'Period' THEN
    --  l_variance := l_variance || ' %';
    --END IF;
    --l_variance := l_variance || ' (' || l_variance_operator || ')';
-- Code comment ends

    --
    -- Calculate the difference in the previoue balance and
    -- the current balance.
    -- skutteti - changed previous minus current to current minus previous
    --            to be consistent with the text format report

    l_difference := r_excp_rpt_data.current_balance -
                    r_excp_rpt_data.previous_balance;

    --
    -- Print the header if not printed already
    --
    IF NOT l_header_printed THEN
      fnd_file.put(fnd_file.output,'"Effective Date","');
      -- BUG #3008584, changed from Payroll date to report parameter date.
      fnd_file.put_line(fnd_file.output,fnd_date.canonical_to_date(p_report_date) || '"');

      fnd_file.put(fnd_file.output,'"Business Group Name","');
      fnd_file.put_line(fnd_file.output,l_business_group_name||'"');

      fnd_file.put(fnd_file.output,'"Consolidation Set Name","');
      fnd_file.put_line(fnd_file.output,l_consolidation_set_name||'"');

      --
      -- If its a exception report group,
      -- then print the group name in the header
      --
      IF r_excp_rpt_data.group_id IS NOT NULL THEN
        --
        -- Get the group name from group id
        --
        OPEN c_get_exception_group_name(r_excp_rpt_data.group_id);
        FETCH c_get_exception_group_name INTO l_exception_group_name;
        CLOSE c_get_exception_group_name;
        -- Close the cursor

        -- Print the group name
        fnd_file.put(fnd_file.output,'"Exception Group Name","');
	fnd_file.put_line(fnd_file.output, l_exception_group_name ||'"');
      END IF;

      --
      -- Print a Blank row between the heading and the main report body.
      --
      fnd_file.put_line(fnd_file.output,' ');

      --
      -- Printing the SpreadSheet Table Labels
      --
      fnd_file.put(fnd_file.output,'"Exception Report Name",');
      fnd_file.put(fnd_file.output,'"Payroll Name",');
      fnd_file.put(fnd_file.output,'"Employee Full Name",');
      fnd_file.put(fnd_file.output,'"Assignment Number","Balance Name",');
      fnd_file.put(fnd_file.output,'"Balance Dimension Name",');
      fnd_file.put(fnd_file.output,'"Comparison Type",');
      fnd_file.put(fnd_file.output,'"Comparison Value",');
      fnd_file.put(fnd_file.output,'"Variance Type",');
      fnd_file.put(fnd_file.output,'"Variance Operator",');
      fnd_file.put(fnd_file.output,'"Variance Value",');
      fnd_file.put(fnd_file.output,'"Previous Balance","Current Balance",');
      fnd_file.put(fnd_file.output,'"Difference",');
      fnd_file.put(fnd_file.output,'"Employee Last Name",');
      fnd_file.put(fnd_file.output,'"Employee First Name",');
      fnd_file.put_line(fnd_file.output,'"Employee Middle Name"');
      l_header_printed := TRUE;
    END IF;

    --
    -- Check if the Legislation Code is US/GB,
    -- Change the fullname format to 'Last_name,First_Name'
    --
    IF l_legislation_code = 'US' OR l_legislation_code = 'GB' THEN
      hr_utility.trace('Changing the Name Format.....');
      l_full_name := r_excp_rpt_data.last_name || ',' ||
         r_excp_rpt_data.first_name || ' ' || r_excp_rpt_data.middle_name;
    ELSE
      l_full_name := r_excp_rpt_data.full_name;
    END IF;

    -- Get the Currency format code
    l_currency_format := fnd_currency.get_format_mask(l_currency_code, 30);

    fnd_file.put(fnd_file.output,'"' || l_exception_report_name|| '","');
    fnd_file.put(fnd_file.output,l_payroll_name || '","');
    fnd_file.put(fnd_file.output,l_full_name || '","');
    fnd_file.put(fnd_file.output,r_excp_rpt_data.assignment_number || '","');
    fnd_file.put(fnd_file.output,l_balance_name || '","');
    fnd_file.put(fnd_file.output,l_dimension_name ||'","');
    fnd_file.put(fnd_file.output,l_comparison_type || '","');
    fnd_file.put(fnd_file.output,l_comparison_value || '","');
    fnd_file.put(fnd_file.output,l_variance_type || '","');
    fnd_file.put(fnd_file.output,l_variance_operator || '","');
    fnd_file.put(fnd_file.output,l_variance_value || '","');
    fnd_file.put(fnd_file.output,TO_CHAR(r_excp_rpt_data.previous_balance, l_currency_format) || '","' );
    fnd_file.put(fnd_file.output,TO_CHAR(r_excp_rpt_data.current_balance, l_currency_format) || '","' );
    fnd_file.put(fnd_file.output,TO_CHAR(l_difference, l_currency_format)||'","');
    fnd_file.put(fnd_file.output,r_excp_rpt_data.last_name||'","');
    fnd_file.put(fnd_file.output,r_excp_rpt_data.first_name||'","');
    fnd_file.put_line(fnd_file.output,r_excp_rpt_data.middle_name||'"');

  END LOOP;
  -- Loop Ends here
  IF l_output_format = 'CSV' THEN
    DELETE FROM pay_us_rpt_totals
     WHERE organization_id =p_ppa_finder
       AND attribute12 = p_ppa_finder;
    commit;
    hr_utility.trace('Deleted the rows from the pay_us_rpt_totals');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.trace('Final Exit!');
    null;
  hr_utility.trace('Leaving Procedure PQP_EXR_CSV_FORMAT....');
--  hr_utility.trace_off;

-- Added by tmehra for nocopy changes Feb'03

  WHEN OTHERS THEN
       hr_utility.trace('Entering exception when others:');
       retcode := null;
       raise;


End PQP_EXR_CSV_FORMAT;

End PQP_EXCP_RPT;

/
