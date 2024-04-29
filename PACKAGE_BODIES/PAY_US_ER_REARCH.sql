--------------------------------------------------------
--  DDL for Package Body PAY_US_ER_REARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ER_REARCH" AS
/* $Header: pyuserre.pkb 120.2 2006/08/30 00:03:38 sodhingr noship $*/

gv_package_name VARCHAR2(50) := 'pay_us_er_rearch';
l_gre_name  varchar2(100);
l_year      varchar2(30);
gc_csv_delimiter       VARCHAR2(1) := ',';
gc_csv_data_delimiter  VARCHAR2(1) := '"';


FUNCTION formated_data_string
             (p_input_string     in varchar2
              ,p_bold            in varchar2
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(32000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);

    if p_output_file_type = 'CSV' then


       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);

       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;

    end if;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 60);

    return lv_format;

  END formated_data_string;
  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns.
  *****************************************************************/

  FUNCTION employer_rearch_header(
              p_output_file_type  in varchar2
             )
 RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
              lv_format1 :=
              formated_data_string (p_input_string => 'Year'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Name of the GRE'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Federal/State Level'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Name of the field'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Previous Value'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string =>  'Updated Value'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

RETURN (lv_format1);
  END;


  FUNCTION employer_rearch_data (
                   p_year                      in varchar2
                  ,p_tax_unit_name             in varchar2
                  ,p_st_fed                    in varchar2
                  ,p_name                      in varchar2
                  ,p_old_value                 in varchar2
                  ,p_new_value                 in varchar2
                  ,p_output_file_type          in varchar2)

  RETURN VARCHAR2
  IS

lv_format1 VARCHAR2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_year
                                    ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_tax_unit_name
                                   ,p_bold      => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_st_fed
                                   ,p_bold      => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_name
                                   ,p_bold      => 'N'
                                   ,p_output_file_type => p_output_file_type)||
              formated_data_string (p_input_string => p_old_value
                                   ,p_bold      => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_new_value
                                   ,p_bold      => 'N'
                                   ,p_output_file_type => p_output_file_type);


      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);


      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

      return (lv_format1);
  END;

PROCEDURE insert_er_rearch_data(errbuf                OUT  nocopy  VARCHAR2,
                                retcode               OUT  nocopy   NUMBER,
                                p_year                IN      VARCHAR2,
                                p_tax_unit_id         IN      NUMBER,
                                p_fed_state           IN      VARCHAR2,
                                p_is_state            IN      VARCHAR2,
                                p_state_code          IN      VARCHAR2 default null)
IS

CURSOR c_yrend_pactid is
SELECT payroll_action_id
FROM   pay_payroll_actions
WHERE report_type = 'YREND'
AND action_status in ('E','C')
AND legislative_parameters like to_char(p_tax_unit_id)||'%'
AND to_char(effective_date,'YYYY') = substr(p_year,1,4);


CURSOR c_gre_name is
SELECT NAME
FROM hr_organization_units
where organization_id = p_tax_unit_id;

l_pactid pay_payroll_actions.payroll_action_id%TYPE;
l_eff_date Date;

BEGIN

   --hr_utility.trace_on(null,'erre');
   hr_utility.trace('PROCEDURE insert_er_rearch_data');
   hr_utility.trace('p_tax_unit_id '||to_char(p_tax_unit_id));
   hr_utility.trace('p_fed_state ' ||p_fed_state);
   hr_utility.trace('p_state_code '||p_state_code);
   hr_utility.trace('p_year '||substr(p_year,1,4));


   OPEN c_yrend_pactid;
   FETCH c_yrend_pactid INTO l_pactid;

   IF c_yrend_pactid%NOTFOUND THEN

      hr_utility.trace('Pactid not found for GRE id '||to_char(p_tax_unit_id)||' for year' ||p_year);

   ELSE

      hr_utility.trace('Pactid found '||to_char(l_pactid));

      OPEN c_gre_name;
      FETCH c_gre_name INTO l_gre_name;
      CLOSE c_gre_name;

      hr_utility.trace(' l_gre_name = '||l_gre_name);

      l_year := substr(p_year,1,4);

      fnd_file.put_line(fnd_file.output,employer_rearch_header('CSV'));

      IF p_fed_state = 'Federal' THEN

         hr_utility.trace('Federal. p_fed_state = '||p_fed_state);

         hr_utility.trace('Going to call eoy_archive_gre_data for Fed');
         pay_us_archive.eoy_archive_gre_data
                                (l_pactid,
                                 p_tax_unit_id,
                                 'FED W2 REPORTING RULES REARCH',
                                 'ALL');

         pay_us_archive.eoy_archive_gre_data
                                (l_pactid,
                                 p_tax_unit_id,
                                 'FED TAX UNIT INFORMATION REARCH',
                                 'ALL');

         pay_us_archive.eoy_archive_gre_data
                                (l_pactid,
                                 p_tax_unit_id,
                                 'FEDERAL TAX RULES REARCH',
                                 'ALL');

         pay_us_archive.eoy_archive_gre_data
                                (l_pactid,
                                 p_tax_unit_id,
                                 'FED 1099R MAGNETIC REPORT RULES REARCH',
                                 'ALL');

      ELSIF p_fed_state = 'State' THEN

         hr_utility.trace('Going to call eoy_archive_gre_data for State');
         pay_us_archive.eoy_archive_gre_data
                       (l_pactid,
                        p_tax_unit_id,
                       'STATE TAX RULES REARCH',
                        p_state_code);

      ELSIF p_fed_state = 'View Online W2 Profile' THEN

         hr_utility.trace('Going to call eoy_archive_gre_data for View Online W2 Profile');
         pay_us_archive.eoy_archive_gre_data
                       (l_pactid,
                        p_tax_unit_id,
                       'View Online W2 Profile',
                        'ALL');


      END IF;

   END IF;

   CLOSE c_yrend_pactid;
   commit;
END;

PROCEDURE print_er_rearch_data(p_user_entity_id   IN NUMBER,
                               p_federal_state    IN VARCHAR2,
                               p_old_value        IN VARCHAR2,
                               p_new_value        IN VARCHAR2)

IS

CURSOR c_usr_entity_name
IS
SELECT user_entity_name
FROM   ff_user_entities
WHERE user_entity_id = p_user_entity_id;

CURSOR c_gre_name(c_tax_unit_id VARCHAR2) is
SELECT NAME
FROM hr_organization_units
where organization_id = to_number(c_tax_unit_id);

CURSOR c_per_name(c_person_id VARCHAR2) is
SELECT FULL_NAME
FROM   PER_PEOPLE_F
WHERE  person_id = to_number(c_person_id);

CURSOR c_lookup_meaning(c_lookup_type fnd_common_lookups.lookup_type%TYPE,
                        c_lookup_code fnd_common_lookups.lookup_code%TYPE)
IS
SELECT meaning
FROM fnd_common_lookups
WHERE lookup_type = c_lookup_type
AND lookup_code = c_lookup_code;

CURSOR c_state_code(c_fips_code pay_state_rules.fips_code%TYPE)
IS
SELECT fips_code||' - ('||state_code||')'
FROM pay_state_rules
WHERe fips_code =  c_fips_code;




p_item_name ff_user_entities.user_entity_name%TYPE;
l_item_name ff_user_entities.user_entity_name%TYPE;
l_old_value  VARCHAR2(100);
l_new_value  VARCHAR2(100);


BEGIN

    hr_utility.trace('PROCEDURE print_er_rearch_data');
    hr_utility.trace('p_federal_state = '||p_federal_state);
    hr_utility.trace('p_old_value = '||p_old_value);
    hr_utility.trace('p_new_value = '||p_new_value);

   OPEN c_usr_entity_name;
   FETCH c_usr_entity_name INTO l_item_name;

   IF c_usr_entity_name%NOTFOUND THEN

      l_item_name:= null;
      hr_utility.trace('user_entity_name not found for user_entity_id = '
                        ||to_char(p_user_entity_id));

   END IF;

   CLOSE c_usr_entity_name;

   p_item_name := l_item_name;

   IF p_federal_state = 'Federal' THEN

      l_item_name:= replace(substr(l_item_name,6),'_',' ');

  ELSIF p_federal_state = 'State' THEN

       l_item_name:= replace(substr(l_item_name,3),'_',' ');

  END IF;

  IF p_item_name = 'A_TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER' THEN

     l_item_name:= replace(substr(p_item_name,3),'_',' ');

  END IF;


  hr_utility.trace('l_item_name = '||l_item_name);
  l_old_value := p_old_value;
  l_new_value := p_new_value;

  IF l_item_name = 'W2 REPORTING RULES ORG COMPANY NAME' THEN

     IF p_old_value IS NOT Null THEN

        OPEN c_gre_name(p_old_value);
        FETCH c_gre_name INTO l_old_value;

        IF c_gre_name%NOTFOUND THEN

           l_old_value := null;
           hr_utility.trace('Gre Name not found for tax_unit_id '||p_old_value);

       END IF;

       CLOSE c_gre_name;

    END IF;

    IF p_new_value IS NOT NULL THEN

       OPEN c_gre_name(p_new_value);
       FETCH c_gre_name INTO l_new_value;

       IF c_gre_name%NOTFOUND THEN

           l_new_value := null;
           hr_utility.trace('Gre Name not found for tax_unit_id '||p_new_value);

       END IF;

       CLOSE c_gre_name;

    END IF;

  ELSIF l_item_name ='W2 REPORTING RULES ORG CONTACT NAME' THEN

     IF p_old_value IS NOT Null THEN

       OPEN c_per_name(p_old_value);
       FETCH c_per_name INTO l_old_value;

       IF c_per_name%NOTFOUND THEN

          l_old_value := null;
          hr_utility.trace('Person Name not found for person_id '||p_old_value);

       END IF;

       CLOSE c_per_name;

    END IF;

    IF p_new_value IS NOT NULL THEN

       OPEN c_per_name(p_new_value);
        FETCH c_per_name INTO l_new_value;

        IF c_per_name%NOTFOUND THEN

           l_new_value := null;
           hr_utility.trace('Person Name not found for person_id '||p_new_value);

        END IF;

        CLOSE c_per_name;

    END IF;

  ELSIF l_item_name ='W2 REPORTING RULES ORG PREPARER' THEN

       IF p_old_value IS NOT NULL THEN

          OPEN c_lookup_meaning('MMREF_PREPARER_CODE',p_old_value);
          FETCH c_lookup_meaning INTO l_old_value;
          CLOSE c_lookup_meaning;
          hr_utility.trace('c_lookup_meaning = '||l_old_value);

       END IF;

       IF p_new_value IS NOT NULL THEN

          OPEN c_lookup_meaning('MMREF_PREPARER_CODE',p_new_value);
          FETCH c_lookup_meaning INTO l_new_value;
          CLOSE c_lookup_meaning;
          hr_utility.trace('c_lookup_meaning = '||l_new_value);

       END IF;


  ELSIF l_item_name ='W2 REPORTING RULES ORG NOTIFICATION METHOD' THEN

     IF p_old_value IS NOT NULL THEN

          OPEN c_lookup_meaning('MMREF_PROBLEM_NOTIFICATON_MTHD',p_old_value);
          FETCH c_lookup_meaning INTO l_old_value;
          CLOSE c_lookup_meaning;
          hr_utility.trace('c_lookup_meaning = '||l_old_value);

       END IF;

       IF p_new_value IS NOT NULL THEN

          OPEN c_lookup_meaning('MMREF_PROBLEM_NOTIFICATON_MTHD',p_new_value);
          FETCH c_lookup_meaning INTO l_new_value;
          CLOSE c_lookup_meaning;
          hr_utility.trace('c_lookup_meaning = '||l_new_value);

       END IF;

  ELSIF l_item_name ='W2 REPORTING RULES ORG TAX JURISDICTION' THEN

     IF p_old_value IS NOT NULL THEN

        OPEN c_lookup_meaning('MMREF_TAX_JURISDICTION',p_old_value);
        FETCH c_lookup_meaning INTO l_old_value;
        CLOSE c_lookup_meaning;
        hr_utility.trace('c_lookup_meaning = '||l_old_value);

     END IF;

     IF p_new_value IS NOT NULL THEN

        OPEN c_lookup_meaning('MMREF_TAX_JURISDICTION',p_new_value);
        FETCH c_lookup_meaning INTO l_new_value;
        CLOSE c_lookup_meaning;
        hr_utility.trace('c_lookup_meaning = '||l_new_value);

     END IF;

  ELSIF l_item_name = 'FEDERAL TAX RULES ORG TYPE OF EMPLOYMENT' THEN

     IF p_old_value IS NOT NULL THEN

        OPEN c_lookup_meaning('US_EMPLOYMENT_TYPE',p_old_value);
        FETCH c_lookup_meaning INTO l_old_value;
        CLOSE c_lookup_meaning;
        hr_utility.trace('c_lookup_meaning = '||l_old_value);

     END IF;

     IF p_new_value IS NOT NULL THEN

        OPEN c_lookup_meaning('US_EMPLOYMENT_TYPE',p_new_value);
        FETCH c_lookup_meaning INTO l_new_value;
        CLOSE c_lookup_meaning;
        hr_utility.trace('c_lookup_meaning = '||l_new_value);

     END IF;

  ELSIF l_item_name = 'FIPS CODE JD' THEN


        OPEN c_state_code(l_new_value);
        FETCH c_state_code INTO l_new_value;
        CLOSE c_state_code;

        hr_utility.trace('l_new_value ='||l_new_value);


  END IF;

   fnd_file.put_line(fnd_file.output,employer_rearch_data(
                                     l_year,
                                     l_gre_name,
                                     p_federal_state,
                                     l_item_name,
                                     l_old_value,
                                     l_new_value,
                                     'CSV'));



END;



END pay_us_er_rearch;

/
