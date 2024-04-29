--------------------------------------------------------
--  DDL for Package Body PER_GENERIC_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GENERIC_REPORT_PKG" AS
/* $Header: pergenrp.pkb 120.0 2005/05/31 17:56:59 appldev noship $ */
/*===========================================================================+
|		Copyright (C) 1995 Oracle Corporation                        |
|		         All rights reserved 				     |
|									     |
+===========================================================================*/
--
 /*
   Name
     PER_GENERIC_REPORT_PKG
   Purpose
    Contains all the procedures to support the generation of customisable
    candidate list reports.

    Notes:

    History
      18-Sep-1995  fshojaas		70.0		Date Created.
		   gperry
      24-Jul-1997  teyres               70.1            Changed as to is on create or replace line
      25-Jun-97    teyres               110.1/70.2      110.1 and 70.2 are the same
      04-aug-97    mstewart             110.2           Changed statements using
							per_people_f_secv to
							use per_people_f instead
							(R11 security model
							change)
      19-jun-01    gperry               110.3           WWBUG 1833930. Since
                                                        this is sample code I
                                                        converted it to use
                                                        sysdate so the index is
                                                        for the DT tables are
                                                        being used. Also got
                                                        rid of the distinct
                                                        code.
      17-SEP-01    gperry               115.2           Fixed WWBUG 1997980.
                                                        Inserts into tables
                                                        use by column name.

============================================================================*/

  --
  --                               Private Global Definition
  ----------------------------------------------------------------------------
  --
  -- Global package name
  --
  g_package varchar2(50):= 'per_generic_report_pkg.';
  --
  --
  -- *************************************************************************
  --
  -- Name            : example1
  -- Parameters      : p_param_1
  --                   (This is the value of the first parameter that is
  --                   displayed on the screen, in this example it refers to a
  --                   vacancy).
  -- Values Returned : none
  -- Description     : This procedure is used as an example to show how a
  --                   one parameter report can be used to populate a generic
  --                   table with custom formatting.
  --
  -- *************************************************************************
  procedure example1(p_param_1 varchar2
                    ) is
    --
    -- Declare local variables, these are used for storing values that will be
    -- inserted into the generic table.
    --
    l_recs_inserted       number := 1;
    l_full_name           per_people_f.full_name%type;
    l_sex                 per_people_f.sex%type;
    --
    -- The l_proc variable is used for handling errors that may occur during
    -- program execution.
    --
    l_proc                varchar(72) := g_package || 'generate_report';
    --
    -- This cursor selects the full_name and sex of people who have applied
    -- for a particular vacancy. This vacancy is dependant on the value of
    -- p_param_1.
    --
    cursor c1 is
      select          a.full_name, a.sex
      from            per_all_people_f a,
                      per_all_assignments_f b,
                      per_vacancies c
      where           a.business_group_id = b.business_group_id
      and             a.person_id         = b.person_id
      and             trunc(sysdate)
                      between a.effective_start_date
                      and     a.effective_end_date
      and             b.vacancy_id        = c.vacancy_id
      and             trunc(sysdate)
                      between b.effective_start_date
                      and     b.effective_end_date
      and             c.name              = p_param_1;
  begin
    --
    -- This example has one parameter only. The statements below insert
    -- data with custom formatting into a table. This example using lpad
    -- to demonstrate the sort of custom formatting that can be applied
    -- to the resultant data.
    --
    open c1;
      loop
        fetch c1 into l_full_name, l_sex;
        exit when c1%notfound;
        --
        -- Insert values into body of table with some example formatting.
        -- In this case we insert the full_name and the sex which we
        -- align using an lpad statement.
        --
        insert into per_generic_report_output
        (line_type,line_number,line_content)
        values ('B',l_recs_inserted,l_full_name||
        lpad(l_sex,50-length(l_full_name),' '));
        l_recs_inserted := l_recs_inserted + 1;
        hr_utility.set_location(l_proc,20);
      end loop;
    close c1;
  end example1;
  -- *************************************************************************
  --
  -- Name            : example2
  -- Parameters      : p_param_1
  --                   (This is the value of the first parameter that is
  --                   displayed on the screen, in this example it refers to a
  --                   vacancy).
  --                   p_param_2
  --                   (This is the value of the second parameter that is
  --                   displayed on the screen, in this example it refers to
  --                   the sex of people applying for a vacancy).
  -- Values Returned : none
  -- Description     : This procedure is used as an example to show how a
  --                   two parameter report can be used to populate a generic
  --                   table with custom formatting.
  --
  -- *************************************************************************
  procedure example2(p_param_1 varchar2,
                     p_param_2 varchar2
                    ) is
    --
    -- Declare local variables, these are used for storing values that will be
    -- inserted into the generic table.
    --
    l_recs_inserted       number := 1;
    l_full_name           per_people_f.full_name%type;
    --
    -- The l_proc variable is used for handling errors that may occur during
    -- program execution.
    --
    l_proc                varchar(72) := g_package || 'generate_report';
    --
    -- This cursor selects the full_name of people who have applied for
    -- a particular vacancy. This vacancy is dependant on the value of
    -- p_param_1 and the sex of people who will be selected is dependant
    -- on the value of p_param_2.
    --
    cursor c2 is
      select          a.full_name
      from            per_all_people_f a,
                      per_all_assignments_f b,
                      per_vacancies c
      where           a.business_group_id = b.business_group_id
      and             a.person_id         = b.person_id
      and             trunc(sysdate)
                      between a.effective_start_date
                      and     a.effective_end_date
      and             b.vacancy_id        = c.vacancy_id
      and             trunc(sysdate)
                      between b.effective_start_date
                      and     b.effective_end_date
      and             c.name              = p_param_1
      and             a.sex               = p_param_2;
  begin
    --
    -- This example has two parameters. The statements below insert the
    -- full_name of people applying for a particular vacancy into a table
    -- with certain custom formatting. This example uses upper to convert
    -- the applicant's full_name to upper case in order to demonstrate
    -- the sort of custom formatting that can be applied to the resultant
    -- data.
    --
    open c2;
      loop
        fetch c2 into l_full_name;
        exit when c2%notfound;
        --
        -- Insert values into body of table with some example formatting.
        -- In this case we insert some spaces and full_name in upper case.
        --
        insert into per_generic_report_output
        (line_type,line_number,line_content)
        values ('B',l_recs_inserted,'     '||upper(l_full_name));
        l_recs_inserted := l_recs_inserted + 1;
        hr_utility.set_location(l_proc,25);
      end loop;
    close c2;
  end example2;
  -- *************************************************************************
  --
  -- Name            : example3
  -- Parameters      : p_param_1
  --                   (This is the value of the first parameter that is
  --                   displayed on the screen, in this example it refers to a
  --                   vacancy).
  --                   p_param_2
  --                   (This is the value of the second parameter that is
  --                   displayed on the screen, in this example it refers to
  --                   the marital status of people applying for a vacancy).
  --                   p_param_3
  --                   (This is the value of the second parameter that is
  --                   displayed on the screen, in this example it refers to
  --                   the sex of people applying for a vacancy).
  -- Values Returned : none
  -- Description     : This procedure is used as an example to show how a
  --                   three parameter report can be used to populate a
  --                   generic table with custom formatting.
  --
  -- *************************************************************************
  procedure example3(p_param_1 varchar2,
                     p_param_2 varchar2,
                     p_param_3 varchar2
                     ) is
    --
    -- Declare local variables, these are used for storing values that will be
    -- inserted into the generic table.
    --
    l_recs_inserted       number := 1;
    l_full_name           per_people_f.full_name%type;
    l_sex                 per_people_f.sex%type;
    --
    -- The l_proc variable is used for handling errors that may occur during
    -- program execution.
    --
    l_proc                varchar(72) := g_package || 'generate_report';
    --
    -- This cursor selects the full_name, marital status and sex of people
    -- who have applied for a particular vacancy. This vacancy is dependant
    -- on the value of p_param_1, the marital status is dependant on the
    -- value of p_param_2 and the sex of people who will be selected is
    -- dependant on the value of p_param_3.
    --
    cursor c3 is
      select a.full_name, a.sex
      from            per_all_people_f a,
                      per_all_assignments_f b,
                      per_vacancies c
      where           a.business_group_id = b.business_group_id
      and             a.person_id         = b.person_id
      and             trunc(sysdate)
                      between a.effective_start_date
                      and     a.effective_end_date
      and             b.vacancy_id        = c.vacancy_id
      and             trunc(sysdate)
                      between b.effective_start_date
                      and     b.effective_end_date
      and             b.primary_flag      = 'Y'
      and             c.name              = p_param_1
      and             a.marital_status    = p_param_2
      and             a.sex               = p_param_3;
  begin
    --
    -- This example has three parameters. The statements below insert the
    -- full_name and sex of people applying for a particular vacancy into
    -- a table with certain custom formatting. This example uses initcap
    -- to convert the applicant's full_name to initial caps in order to
    -- demonstrate the sort of custom formatting that can be applied to
    -- the resultant data.
    --
    open c3;
      loop
        fetch c3 into l_full_name, l_sex;
        exit when c3%notfound;
        --
        -- Insert values into body of table with some example formatting.
        -- In this case we insert the sex and then some spaces followed
        -- by the full_name in initcaps.
        --
        insert into per_generic_report_output
        (line_type,line_number,line_content)
        values ('B',l_recs_inserted,l_sex||'  '||initcap(l_full_name));
        l_recs_inserted := l_recs_inserted + 1;
        hr_utility.set_location(l_proc,30);
      end loop;
    close c3;
  end example3;
  -- *************************************************************************
  --
  -- Name            : generate_report
  -- Parameters      : p_report_name varchar2
  --                   (This is the report name selected from the LOV)
  --                   p_param_1
  --                   (This is the value of the first parameter on the
  --                   screen).
  --                   p_param_2
  --                   (This is the value of the second parameter on the
  --                   screen).
  --                   p_param_3
  --                   (This is the value of the third parameter on the
  --                   screen).
  --                   p_param_4
  --                   (This is the value of the fourth parameter on the
  --                   screen).
  --                   p_param_5
  --                   (This is the value of the fifth parameter on the
  --                   screen).
  --                   p_param_6
  --                   (This is the value of the sixth parameter on the
  --                   screen).
  --                   p_param_7
  --                   (This is the value of the seventh parameter on the
  --                   screen).
  --                   p_param_8
  --                   (This is the value of the eighth parameter on the
  --                   screen).
  --                   p_param_9
  --                   (This is the value of the nineth parameter on the
  --                   screen).
  --                   p_param_10
  --                   (This is the value of the tenth parameter on the
  --                   screen).
  --                   p_param_11
  --                   (This is the value of the eleventh parameter on the
  --                   screen).
  --                   p_param_12
  --                   (This is the value of the twelvth parameter on the
  --                   screen).
  -- Values Returned : none
  -- Description     : This procedure calls procedures which populate
  --                   the per_generic_report_output table with the
  --                   formatting required by the customer.
  --
  -- *************************************************************************
  procedure generate_report(p_report_name varchar2,
                            p_param_1     varchar2,
			    p_param_2     varchar2,
                            p_param_3     varchar2,
                            p_param_4     varchar2,
                            p_param_5     varchar2,
                            p_param_6     varchar2,
                            p_param_7     varchar2,
                            p_param_8     varchar2,
                            p_param_9     varchar2,
                            p_param_10    varchar2,
                            p_param_11    varchar2,
                            p_param_12    varchar2
                            ) is
    --
    -- The l_proc variable is used for handling errors that may occur during
    -- program execution.
    --
    l_proc varchar(72) := g_package || 'generate_report';
  begin
    hr_utility.set_location('Entering: ' ||l_proc,5);
    --
    -- Delete existing data from per_generic_report_output
    --
    delete from per_generic_report_output;
    --
    -- Table per_generic_report_output has the following fields
    -- Line Type T = Title, H = Header, B = Body, F = Footer
    -- field type = varchar2(1)
    -- Line Number field type = number(9)
    -- Line Text field type = long
    --
    -- Insert header information into table
    -- This will be displayed as the header for the report
    --
    -- NOTE: The user may insert their own header into the next line instead of
    -- the 'Example Title - Oracle Corporation UK Ltd'
    --
    insert into per_generic_report_output
    (line_type,line_number,line_content)
    values ('H',1,'Example Title - Oracle Corporation UK Ltd');
    --
    -- Insert footer information into table
    -- This will be displayed as the footer for the report
    --
    -- NOTE: The user may insert their own footer into the next line instead
    -- of the 'Example Footer - Oracle Corporation UK Ltd'.
    --
    insert into per_generic_report_output
    (line_type,line_number,line_content)
    values ('F',1,'Example Footer - Oracle Corporation UK Ltd');
    --
    -- Insert title information into table, in this case p_report_name
    -- This will be displayed as the title for the report
    --
    insert into per_generic_report_output
    (line_type,line_number,line_content)
    values ('T',1,p_report_name);
    --
    -- Depending on the report name run different procedures
    --
    if p_report_name = 'Custom Report 1' then
      example1(p_param_1);
    elsif p_report_name = 'Custom Report 2' then
      example2(p_param_1,p_param_2);
    elsif p_report_name = 'Custom Report 3' then
      example3(p_param_1,p_param_2,p_param_3);
    end if;
  end generate_report;
  -- *************************************************************************
  --
  -- Name            : launch_report
  -- Parameters      : p_report_name
  --                   (This is the report name selected from the LOV)
  --                   p_param_1
  --                   (This is the value of the first parameter on the
  --                   screen).
  --                   p_param_2
  --                   (This is the value of the second parameter on the
  --                   screen).
  --                   p_param_3
  --                   (This is the value of the third parameter on the
  --                   screen).
  --                   p_param_4
  --                   (This is the value of the fourth parameter on the
  --                   screen).
  --                   p_param_5
  --                   (This is the value of the fifth parameter on the
  --                   screen).
  --                   p_param_6
  --                   (This is the value of the sixth parameter on the
  --                   screen).
  --                   p_param_7
  --                   (This is the value of the seventh parameter on the
  --                   screen).
  --                   p_param_8
  --                   (This is the value of the eighth parameter on the
  --                   screen).
  --                   p_param_9
  --                   (This is the value of the nineth parameter on the
  --                   screen).
  --                   p_param_10
  --                   (This is the value of the tenth parameter on the
  --                   screen).
  --                   p_param_11
  --                   (This is the value of the eleventh parameter on the
  --                   screen).
  --                   p_param_12
  --                   (This is the value of the twelvth parameter on the
  --                   screen).
  -- Values Returned : boolean (depending on whether validation check
  --                   succeeded, in this case we check if a vacancy exists).
  -- Description     : This procedure is used as an initial validation check
  --                   before attemptng to submit the report to the
  --                   concurrent program manager.
  --
  -- *************************************************************************
  function launch_report(p_report_name varchar2,
                         p_param_1     varchar2,
                         p_param_2     varchar2,
                         p_param_3     varchar2,
                         p_param_4     varchar2,
                         p_param_5     varchar2,
                         p_param_6     varchar2,
                         p_param_7     varchar2,
                         p_param_8     varchar2,
                         p_param_9     varchar2,
                         p_param_10    varchar2,
                         p_param_11    varchar2,
                         p_param_12    varchar2)
			 return boolean is
    --
    -- Declare local variables
    --
    l_success       boolean := FALSE;
    l_vacancy_name  per_vacancies.name%type;
    l_report_number number;
    --
    -- The l_proc variable is used for handling errors that may occur during
    -- program execution.
    --
    l_proc          varchar2(72) := g_package || 'launch_report';
    --
    -- This cursor is used as an example to show what sort or prior
    -- to submitting validation checks a customer could do. In this
    -- case a cursor is used to check if a vacancy exists.
    --
    cursor c1 is
      select name
      from   per_vacancies
      where  name = p_param_1;
  begin
    hr_utility.set_location('Entering:' || l_proc,5);
    --
    -- This cursor checks whether a fetch was successful, in other words
    -- does a vacancy exist. If not then a variable is set and an
    -- appropriate error message will be displayed.
    --
    open c1;
      fetch c1 into l_vacancy_name;
      --
      -- Check if vacancy exists by seeing if fetch succeeded
      --
      if c1%found then
        --
        -- Vacancy found
        --
        l_success := true;
      else
        --
        -- Vacancy not found
        --
        l_success := false;
      end if;
      --
      -- Close cursor c1
      --
      hr_utility.set_location(l_proc,15);
    close c1;
    --
    -- Return control back to the form if vacancy has not been found.
    -- Display error message if vacancy not found.
    --
    if not l_success then
      --
      hr_utility.set_message(801,'HR_51001_THE_VAC_NOT_FOUND');
      hr_utility.raise_error;
    end if;
    --
    -- ***********************************************************************
    -- DO NOT REMOVE THE NEXT LINE :  l_report_number := ........
    -- ***********************************************************************
    --
    -- Make a request to the concurrent program manager. This returns a
    -- number depending on whether a successful request or unsuccessful
    -- request was made. The number 0 indicates an unsuccessful request.
    --
    l_report_number := fnd_request.submit_request('PER',
                                                  'PERGENRP',
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  p_report_name,
                                                  p_param_1,
                                                  p_param_2,
                                                  p_param_3,
                                                  p_param_4,
                                                  p_param_5,
                                                  p_param_6,
                                                  p_param_7,
                                                  p_param_8,
                                                  p_param_9,
                                                  p_param_10,
                                                  p_param_11,
                                                  p_param_12
                                                 );
    -- ***********************************************************************
    -- DO NOT REMOVE THE NEXT IF..END IF STATEMENT :  if l_report_number ...
    -- ***********************************************************************
    --
    -- Check to see if the request was successful otherwise display an error
    -- message.
    --
    if l_report_number = 0 then
      hr_utility.set_location(l_proc,35);
      hr_utility.set_message(801,'HR_51002_REPORT_CANT_SUBMITTED');
      hr_utility.raise_error;
    end if;
    --
    -- return true if all checks have been successful
    --
    return true;
  end launch_report;
END PER_GENERIC_REPORT_PKG;

/
