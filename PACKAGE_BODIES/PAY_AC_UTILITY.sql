--------------------------------------------------------
--  DDL for Package Body PAY_AC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AC_UTILITY" as
/* $Header: pyacutil.pkb 120.2 2005/12/01 08:45 sdahiya noship $ */

  /*********************************************************************
  **  Name      : get_defined_balance_id
  **  Purpose   : This function returns the defined_balance_id for a
  **              given Balance Name and Dimension for Mexico.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **              p_balance_name    -> Balance Name
  **              p_dimension_name  -> Dimension Name or
  **                                   database_item_suffix
  **              p_bus_grp_id      -> Business Group ID
  **              p_legislation_cd  -> Legislation Code
  **
  **  Notes     : The combination of Business Group ID and
  **              Legislation Code would be 'Not NULL / NULL' or
  **              'NULL / Not NULL'.
  **
  **              When first character of p_dimension_name is
  **              underscore, then it is considered as
  **              database_item_suffix.
  *********************************************************************/

  FUNCTION get_defined_balance_id (p_balance_type_id IN NUMBER
                                  ,p_dimension_name  IN VARCHAR2
                                  ,p_bus_grp_id      IN NUMBER
                                  ,p_legislation_cd  IN VARCHAR2)
    RETURN NUMBER IS

    cursor get_legislation (cp_bus_grp_id NUMBER) is
      select org_information9
      from   hr_organization_information
      where  org_information_context = 'Business Group Information'
      and    organization_id = cp_bus_grp_id;

    cursor get_bal_dim_id (cp_dimension_name VARCHAR2
                          ,cp_legislation_cd VARCHAR2) IS
      select balance_dimension_id
      from   pay_balance_dimensions
      where  legislation_code = cp_legislation_cd
      and    dimension_name   = cp_dimension_name;

    cursor get_baldim_id (cp_database_item_suffix VARCHAR2
                         ,cp_legislation_cd       VARCHAR2) IS
      select balance_dimension_id
      from   pay_balance_dimensions
      where  legislation_code       = cp_legislation_cd
      and    database_item_suffix   = cp_database_item_suffix;

    cursor get_def_bal_id (cp_bal_typ_id NUMBER
                          ,cp_bal_dim_id NUMBER) IS
      select defined_balance_id
      from   pay_defined_balances
      where  balance_type_id       = cp_bal_typ_id
      and    balance_dimension_id  = cp_bal_dim_id;

      ln_legislation_cd     VARCHAR2(240);
      ln_bal_dim_id         NUMBER;
      ln_defined_balance_id NUMBER;
  BEGIN

    if p_bus_grp_id is not null and p_legislation_cd is null then
       open  get_legislation(p_bus_grp_id);
       fetch get_legislation into ln_legislation_cd;
       close get_legislation;
    else
       ln_legislation_cd := p_legislation_cd;
    end if;

    if substr(p_dimension_name, 1, 1) = '_' then
       open  get_baldim_id(p_dimension_name, ln_legislation_cd);
       fetch get_baldim_id into ln_bal_dim_id;
       close get_baldim_id;
    else
       open  get_bal_dim_id(p_dimension_name, ln_legislation_cd);
       fetch get_bal_dim_id into ln_bal_dim_id;
       close get_bal_dim_id;
    end if;

    ln_defined_balance_id := 0;

    open  get_def_bal_id(p_balance_type_id, ln_bal_dim_id);
    fetch get_def_bal_id into ln_defined_balance_id;
    close get_def_bal_id;

    return (ln_defined_balance_id);
  END get_defined_balance_id;

  FUNCTION get_defined_balance_id (p_balance_name    IN VARCHAR2
                                  ,p_dimension_name  IN VARCHAR2
                                  ,p_bus_grp_id      IN NUMBER
                                  ,p_legislation_cd  IN VARCHAR2)
    RETURN NUMBER IS

    ln_balance_type_id    NUMBER;
    ln_defined_balance_id NUMBER;

  BEGIN

    ln_balance_type_id := get_balance_type_id ( p_balance_name
                                              , p_bus_grp_id
                                              , p_legislation_cd);

    ln_defined_balance_id := get_defined_balance_id (ln_balance_type_id
                                                    ,p_dimension_name
                                                    ,p_bus_grp_id
                                                    ,p_legislation_cd);

    return (ln_defined_balance_id);

  END get_defined_balance_id;

  /**********************************************************************
  **  Name      : get_balance_type_id
  **  Purpose   : This function returns balance type ID of given Balance
  **              Name, Business Group ID and Legislation Code.
  **  Arguments : IN Parameters
  **              p_balance_name    -> Balance Name
  **              p_bus_grp_id      -> Business Group ID
  **              p_legislation_cd  -> Legislation Code
  **  Notes     :
  **********************************************************************/

  FUNCTION get_balance_type_id ( p_balance_name   IN VARCHAR2
                               , p_bus_grp_id     IN NUMBER
                               , p_legislation_cd IN VARCHAR2)
    RETURN NUMBER IS

    cursor get_bal_tp_id ( cp_balance_name   VARCHAR2
                         , cp_bus_grp_id     NUMBER
                         , cp_legislation_cd VARCHAR2 )is
      select balance_type_id
      from   pay_balance_types
      where  balance_name     = p_balance_name
      and    (( business_group_id = cp_bus_grp_id and
                cp_legislation_cd is null ) or
              ( legislation_code = cp_legislation_cd and
                cp_bus_grp_id is null ) );

    ln_balance_type_id  NUMBER;

  BEGIN

    open   get_bal_tp_id ( p_balance_name
                         , p_bus_grp_id
                         , p_legislation_cd);
    fetch  get_bal_tp_id into ln_balance_type_id;
    close  get_bal_tp_id;

    return ln_balance_type_id;

  END get_balance_type_id;

  /*********************************************************************
  **  Name      : get_bal_or_rep_name
  **  Purpose   : This function returns translated value of either the
  **              balance name or reporting name of the balance based
  **              on p_desc_type. The p_desc_type could be either 'B'
  **              for Balance or 'R' for Reporting name.
  **
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **              p_desc_type       -> 'B' or 'R'
  **  Notes     :
  *********************************************************************/

  FUNCTION get_bal_or_rep_name (p_balance_type_id IN NUMBER
                               ,p_desc_type       IN VARCHAR2)
    RETURN VARCHAR2 IS

    cursor csr_balance (cp_balance_type_id number) is
      select balance_name, reporting_name
      from   pay_balance_types_tl pbt
      where  balance_type_id      = cp_balance_type_id
      and    language             = USERENV('LANG') ;
  --
    lv_balance_name     VARCHAR2(240);
    lv_reporting_name   VARCHAR2(240);
  --
    ln_found            NUMBER;
    ln_index            NUMBER;
  BEGIN

    ln_found := 0;

    if pay_ac_utility.bal_tbl.count > 0 then

       for i in pay_ac_utility.bal_tbl.first .. pay_ac_utility.bal_tbl.last
       loop

          if pay_ac_utility.bal_tbl(i).bal_type_id = p_balance_type_id then

             lv_balance_name := pay_ac_utility.bal_tbl(i).bal_name;
             lv_reporting_name := pay_ac_utility.bal_tbl(i).bal_rep_name;
             ln_found := 1;

          end if;

       end loop;

    end if;

    if ln_found = 0 then

       open  csr_balance(p_balance_type_id);
       fetch csr_balance into lv_balance_name, lv_reporting_name;
       close csr_balance;

       ln_index := pay_ac_utility.bal_tbl.count;

       pay_ac_utility.bal_tbl(ln_index).bal_type_id  := p_balance_type_id;
       pay_ac_utility.bal_tbl(ln_index).bal_name     := lv_balance_name;
       pay_ac_utility.bal_tbl(ln_index).bal_rep_name := lv_reporting_name;

    end if;

    if p_desc_type = 'R' then
       return lv_reporting_name;
    else
       return lv_balance_name;
    end if;

  END get_bal_or_rep_name;

  /*********************************************************************
  **  Name      : get_balance_name
  **  Purpose   : This function returns translated value of the balance
  **              name.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **  Notes     :
  *********************************************************************/

  FUNCTION get_balance_name (p_balance_type_id IN NUMBER)
    RETURN VARCHAR2 IS
  BEGIN
    return get_bal_or_rep_name(p_balance_type_id,'B');
  END get_balance_name;

  /**********************************************************************
  **  Name      : get_bal_reporting_name
  **  Purpose   : This function returns translated value of reporting
  **              name of the balance.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **  Notes     :
  **********************************************************************/

  FUNCTION get_bal_reporting_name (p_balance_type_id IN NUMBER)
    RETURN VARCHAR2 IS
  BEGIN
    return get_bal_or_rep_name(p_balance_type_id,'R');
  END get_bal_reporting_name;

  /**********************************************************************
  **  Name      : get_value
  **  Purpose   : This function returns balance value
  **
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID
  **              p_dimension_name  -> Dimension Name or
  **                                   database_item_suffix
  **              p_bus_grp_id      -> Business Group ID
  **              p_legislation_cd  -> Legislation Code
  **              p_asg_act_id      -> Assignment Action ID
  **              p_tax_unit_id     -> Tax Unit ID
  **              p_date_paid       -> Date Paid
  **  Notes     :
  **********************************************************************/

  FUNCTION get_value (p_balance_type_id IN NUMBER
                     ,p_dimension_name  IN VARCHAR2
                     ,p_bus_grp_id      IN NUMBER
                     ,p_legislation_cd  IN VARCHAR2
                     ,p_asg_act_id      IN NUMBER
                     ,p_tax_unit_id     IN NUMBER
                     ,p_date_paid       IN DATE)
    RETURN NUMBER IS

    ln_defined_balance_id NUMBER;
    ln_value              NUMBER;

  BEGIN

    hr_utility.trace('Entering pay_ac_utility.get_value with Bal Type ID');
    hr_utility.trace('p_balance_type_id: '||p_balance_type_id);
    hr_utility.trace('p_dimension_name: '||p_dimension_name);
    hr_utility.trace('p_bus_grp_id: '||p_bus_grp_id);
    hr_utility.trace('p_legislation_cd: '||p_legislation_cd);
    hr_utility.trace('p_tax_unit_id: '||p_tax_unit_id);
    hr_utility.trace('p_date_paid: '||p_date_paid);

    ln_defined_balance_id := get_defined_balance_id (p_balance_type_id
                                                    ,p_dimension_name
                                                    ,p_bus_grp_id
                                                    ,p_legislation_cd);

    hr_utility.trace('ln_defined_balance_id: '||ln_defined_balance_id);

    if ln_defined_balance_id <> 0 then
       ln_value := pay_balance_pkg.get_value
                   (p_defined_balance_id   => ln_defined_balance_id
                   ,p_assignment_action_id => p_asg_act_id
                   ,p_tax_unit_id          => p_tax_unit_id
                   ,p_jurisdiction_code    => NULL
                   ,p_source_id            => NULL
                   ,p_tax_group            => NULL
                   ,p_date_earned          => p_date_paid);
    else
       ln_value := NULL;
    end if;

    hr_utility.trace('ln_value: '||ln_value);
    hr_utility.trace('Leaving pay_ac_utility.get_value with Bal Type ID');

    return ln_value;

  END get_value;

  FUNCTION get_value (p_balance_name    IN VARCHAR2
                     ,p_dimension_name  IN VARCHAR2
                     ,p_bus_grp_id      IN NUMBER
                     ,p_legislation_cd  IN VARCHAR2
                     ,p_asg_act_id      IN NUMBER
                     ,p_tax_unit_id     IN NUMBER
                     ,p_date_paid       IN DATE)
    RETURN NUMBER IS

    ln_balance_type_id NUMBER;
    ln_value           NUMBER;
  BEGIN

    hr_utility.trace('Entering pay_ac_utility.get_value with Bal Type Name');
    hr_utility.trace('p_balance_name: '||p_balance_name);
    hr_utility.trace('p_dimension_name: '||p_dimension_name);
    hr_utility.trace('p_bus_grp_id: '||p_bus_grp_id);
    hr_utility.trace('p_legislation_cd: '||p_legislation_cd);
    hr_utility.trace('p_tax_unit_id: '||p_tax_unit_id);
    hr_utility.trace('p_date_paid: '||p_date_paid);

    ln_balance_type_id := get_balance_type_id ( p_balance_name
                                              , p_bus_grp_id
                                              , p_legislation_cd);

    hr_utility.trace('ln_balance_type_id: '||ln_balance_type_id);

    ln_value := get_value(p_balance_type_id => ln_balance_type_id
                         ,p_dimension_name  => p_dimension_name
                         ,p_bus_grp_id      => p_bus_grp_id
                         ,p_legislation_cd  => p_legislation_cd
                         ,p_asg_act_id      => p_asg_act_id
                         ,p_tax_unit_id     => p_tax_unit_id
                         ,p_date_paid       => p_date_paid);

    hr_utility.trace('ln_value: '||ln_value);
    hr_utility.trace('Leaving pay_ac_utility.get_value with Bal Type Name');

    return ln_value;

  END get_value;

  /**************************************************************************
  ** Function : range_person_on
  ** Arguments: p_report_type
  **            p_report_format
  **            p_report_qualifier
  **            p_report_category
  ** Returns  : Returns true if the range_person performance enhancement is
  **            enabled for the process.
  **************************************************************************/
  FUNCTION range_person_on(p_report_type      in varchar2
                          ,p_report_format    in varchar2
                          ,p_report_qualifier in varchar2
                          ,p_report_category  in varchar2) RETURN BOOLEAN
  IS

     CURSOR csr_action_parameter is
       select parameter_value
       from pay_action_parameters
       where parameter_name = 'RANGE_PERSON_ID';

     CURSOR csr_range_format_param is
       select par.parameter_value
         from pay_report_format_parameters par,
              pay_report_format_mappings_f map
        where map.report_format_mapping_id = par.report_format_mapping_id
          and map.report_type = p_report_type
          and map.report_format = p_report_format
          and map.report_qualifier = p_report_qualifier
          and map.report_category = p_report_category
          and par.parameter_name = 'RANGE_PERSON_ID';

     lb_return boolean;
     lv_action_param_val varchar2(30);
     lv_report_param_val varchar2(30);

  BEGIN
    hr_utility.set_location('range_person_on',10);

    open csr_action_parameter;
    fetch csr_action_parameter into lv_action_param_val;
    close csr_action_parameter;

    hr_utility.set_location('range_person_on',20);
    open csr_range_format_param;
    fetch csr_range_format_param into lv_report_param_val;
    close csr_range_format_param;

    hr_utility.set_location('range_person_on',30);

    IF nvl(lv_action_param_val,'N') = 'Y' AND
       nvl(lv_report_param_val,'N') = 'Y' THEN
       lb_return := TRUE;
       hr_utility.trace('Range Person = True');
    ELSE
       lb_return := FALSE;
    END IF;

    RETURN lb_return;

  END range_person_on;

  /**************************************************************************
  ** Function : get_geocode
  ** Arguments: p_state_abbrev
  **            p_county_name
  **            p_city_name
  **            p_zip_code
  ** Returns  : Returns Vertex geocode. The function will currently return
  **            00-000-0000 for Canadian Cities
  **************************************************************************/
  FUNCTION get_geocode(p_state_abbrev in VARCHAR2
                      ,p_county_name  in VARCHAR2
                      ,p_city_name    in VARCHAR2
                      ,p_zip_code     in VARCHAR2)
  RETURN VARCHAR2
  IS
     cursor c_state_code(cp_state_abbrev in varchar2) is
       select state_code || '-000-0000'
         from pay_us_states
        where state_abbrev = cp_state_abbrev;

     cursor c_county_code(cp_state_abbrev in varchar2
                         ,cp_county_name  in varchar2) is
       select puc.state_code || '-' || puc.county_code || '-0000'
         from pay_us_states pus,
              pay_us_counties puc
        where pus.state_abbrev = cp_state_abbrev
          and puc.state_code = pus.state_code
          and puc.county_name = cp_county_name;

     lv_geocode     VARCHAR2(11);
     lv_sql_geocode VARCHAR2(11);
  BEGIN
     lv_geocode := '00-000-0000';

     if p_state_abbrev is not null and
        p_state_abbrev <> 'CN' and
        p_county_name is null and
        p_city_name is null and
        p_zip_code is null then
        open c_state_code(p_state_abbrev);
        fetch c_state_code into lv_sql_geocode;
        close c_state_code;

        lv_geocode := nvl(lv_sql_geocode, lv_geocode);

     elsif p_state_abbrev is not null and
           p_state_abbrev <> 'CN' and
           p_county_name is not null and
           p_city_name is null and
           p_zip_code is null then
        open c_county_code(p_state_abbrev
                          ,p_county_name);
        fetch c_county_code into lv_sql_geocode;
        close c_county_code;

        lv_geocode := nvl(lv_sql_geocode, lv_geocode);
     else
        lv_geocode := hr_us_ff_udfs.addr_val(p_state_abbrev => p_state_abbrev
                                            ,p_county_name  => p_county_name
                                            ,p_city_name    => p_city_name
                                            ,p_zip_code     => p_zip_code);

     end if;

    return (lv_geocode);
  END get_geocode;

  /****************************************************************************
    Name        : print_lob
    Description : This procedure prints contents of LOB passed as parameter.
  *****************************************************************************/

PROCEDURE print_lob(p_blob BLOB) IS
    ln_offset   number;
    ln_amount   number;
    lr_buf      RAW(2000);
BEGIN
    ln_offset := 1;
    ln_amount := 2000;
    hr_utility.trace('BLOB contents: -');
    LOOP
        dbms_lob.read(
            p_blob,
            ln_amount,
            ln_offset,
            lr_buf);
        ln_amount := 2000;
        ln_offset := ln_offset + ln_amount;
        hr_utility.trace(utl_raw.cast_to_varchar2(lr_buf));
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        hr_utility.trace('BLOB contents end.');
END print_lob;

end pay_ac_utility;

/
