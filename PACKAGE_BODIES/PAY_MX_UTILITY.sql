--------------------------------------------------------
--  DDL for Package Body PAY_MX_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_UTILITY" AS
/* $Header: pymxutil.pkb 120.6.12010000.4 2009/06/23 13:26:15 vvijayku ship $ */

--
-- Global Variables
--
   g_package_name  VARCHAR2(240);
   g_debug         BOOLEAN;


  /**********************************************************************
  **  Name      : get_days_bal_type_id
  **  Purpose   : This function returns Balance Type ID of Days Balance
  **              for Mexico.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID of Primary Balance
  **  Notes     :
  **********************************************************************/

  FUNCTION get_days_bal_type_id (p_balance_type_id IN NUMBER)
    RETURN NUMBER IS

    cursor c_days_bal_type_id (cp_balance_type_id NUMBER) is
      select pbt.balance_type_id, pbt.balance_uom
      from   pay_balance_types pbt,
             pay_defined_balances pdb,
             pay_balance_attributes pba,
             pay_bal_attribute_definitions pbad
      where  pbad.attribute_name      = 'Earnings Days'
      and    pbad.business_group_id is null
      and    pbad.legislation_code    = 'MX'
      and    pba.attribute_id         = pbad.attribute_id
      and    pdb.defined_balance_id   = pba.defined_balance_id
      and    pbt.balance_type_id      = pdb.balance_type_id
      and    pbt.base_balance_type_id = cp_balance_type_id;

     ln_days_bal_type_id NUMBER;
     lv_balance_uom      VARCHAR2(240);

     ln_found            NUMBER;
     ln_index            NUMBER;
  BEGIN

    --hr_utility.trace_on( NULL, 'BAL');

    ln_found := 0;

    hr_utility.trace( 'COUNT '|| pay_mx_utility.days_bal_tbl.count);

    if pay_mx_utility.days_bal_tbl.count > 0 then

       for i in pay_mx_utility.days_bal_tbl.first ..
                pay_mx_utility.days_bal_tbl.last
       loop

          if pay_mx_utility.days_bal_tbl(i).bal_type_id = p_balance_type_id then

             ln_days_bal_type_id :=
                     pay_mx_utility.days_bal_tbl(i).days_bal_type_id;
             lv_balance_uom := pay_mx_utility.days_bal_tbl(i).days_bal_uom;
             ln_found := 1;

          end if;

          hr_utility.trace( 'p_balance_type_id '||p_balance_type_id);
          hr_utility.trace( 'BAL TYPE ID  '||
                            pay_mx_utility.days_bal_tbl(i).days_bal_type_id);

       end loop;

    end if;

    if ln_found = 0 then

       open  c_days_bal_type_id(p_balance_type_id);
       fetch c_days_bal_type_id into ln_days_bal_type_id, lv_balance_uom;
       close c_days_bal_type_id;

       ln_index := pay_mx_utility.days_bal_tbl.count;

       pay_mx_utility.days_bal_tbl(ln_index).bal_type_id  := p_balance_type_id;
       pay_mx_utility.days_bal_tbl(ln_index).days_bal_type_id :=
                                                  ln_days_bal_type_id;
       pay_mx_utility.days_bal_tbl(ln_index).days_bal_uom := lv_balance_uom;

       hr_utility.trace( 'DAYS BAL TYPE ID '||ln_days_bal_type_id);
    end if;

    return ln_days_bal_type_id;

  END get_days_bal_type_id;

  /**********************************************************************
  **  Name      : get_hours_bal_type_id
  **  Purpose   : This function returns Balance Type ID of Hours Balance
  **              for Mexico.
  **  Arguments : IN Parameters
  **              p_balance_type_id -> Balance Type ID of Primary Balance
  **  Notes     :
  **********************************************************************/

  FUNCTION get_hours_bal_type_id (p_balance_type_id IN NUMBER)
    RETURN NUMBER IS

    cursor c_hours_bal_type_id (cp_balance_type_id NUMBER) is
      select pbt.balance_type_id, pbt.balance_uom
      from   pay_balance_types pbt,
             pay_defined_balances pdb,
             pay_balance_attributes pba,
             pay_bal_attribute_definitions pbad
      where  pbad.attribute_name      = 'Earnings Hours'
      and    pbad.business_group_id is null
      and    pbad.legislation_code    = 'MX'
      and    pba.attribute_id         = pbad.attribute_id
      and    pdb.defined_balance_id   = pba.defined_balance_id
      and    pbt.balance_type_id      = pdb.balance_type_id
      and    pbt.base_balance_type_id = cp_balance_type_id;

     ln_hours_bal_type_id NUMBER;
     lv_balance_uom       VARCHAR2(240);

     ln_found            NUMBER;
     ln_index            NUMBER;
  BEGIN

    --hr_utility.trace_on( NULL, 'BAL');

    ln_found := 0;

    hr_utility.trace( 'COUNT '|| pay_mx_utility.hours_bal_tbl.count);

/*
    if pay_mx_utility.hours_bal_tbl.count > 0 then

       for i in pay_mx_utility.hours_bal_tbl.first ..
                pay_mx_utility.hours_bal_tbl.last
       loop

          if pay_mx_utility.hours_bal_tbl(i).bal_type_id = p_balance_type_id
          then

             ln_hours_bal_type_id :=
                     pay_mx_utility.hours_bal_tbl(i).hours_bal_type_id;
             lv_balance_uom := pay_mx_utility.hours_bal_tbl(i).hours_bal_uom;
             ln_found := 1;

          end if;

          hr_utility.trace( 'p_balance_type_id '||p_balance_type_id);
          hr_utility.trace( 'BAL TYPE ID  '||
                            pay_mx_utility.hours_bal_tbl(i).hours_bal_type_id);

       end loop;

    end if;
*/

    IF (pay_mx_utility.hours_bal_tbl.EXISTS(p_balance_type_id) = FALSE) THEN


       open  c_hours_bal_type_id(p_balance_type_id);
       fetch c_hours_bal_type_id into ln_hours_bal_type_id, lv_balance_uom;
       close c_hours_bal_type_id;

       ln_index := pay_mx_utility.hours_bal_tbl.count;

       pay_mx_utility.hours_bal_tbl(p_balance_type_id).bal_type_id  :=
                                                              p_balance_type_id;
       pay_mx_utility.hours_bal_tbl(p_balance_type_id).hours_bal_type_id :=
                                                           ln_hours_bal_type_id;
       pay_mx_utility.hours_bal_tbl(p_balance_type_id).hours_bal_uom :=
                                                                 lv_balance_uom;

       hr_utility.trace( 'HOURS BAL TYPE ID '||ln_hours_bal_type_id);

    END IF;

    ln_hours_bal_type_id :=
              pay_mx_utility.hours_bal_tbl(p_balance_type_id).hours_bal_type_id;
    lv_balance_uom :=
              pay_mx_utility.hours_bal_tbl(p_balance_type_id).hours_bal_uom;

    return ln_hours_bal_type_id;

  END get_hours_bal_type_id;


  /**********************************************************************
  **  Type      : Procedure
  **  Name      : get_days_yr_for_pay_period
  **  Purpose   : This procedure populates payroll_period_type PL/SQL table
  **              for the period type of the payroll and its number of
  **              days. (PL/SQL table structure mentioned above)
  **
  **  Arguments : IN Parameters
  **              p_payroll_id -> Payroll ID
  **
  **              OUT Parameters
  **              p_period_type -> Period Type of the payroll
  **              p_days_year   -> No. of Days in Year for the payroll
  **
  **  Notes     :
  **********************************************************************/

  PROCEDURE get_days_yr_for_pay_period( p_payroll_id   IN NUMBER
                                       ,p_period_type  OUT NOCOPY VARCHAR2
                                       ,p_days_year    OUT NOCOPY NUMBER)
  IS

    CURSOR c_period_type IS
      SELECT period_type, legislation_info2
      FROM   per_time_period_types ptpt,
             pay_mx_legislation_info_f pmli
      WHERE  legislation_info_type = 'MX Annualization Factor'
      AND    instr(period_type,legislation_info1) > 0;

    CURSOR c_pay_prd_type(cp_payroll_id NUMBER) IS
      SELECT period_type
      FROM   pay_payrolls_f
      WHERE  payroll_id = cp_payroll_id;

    lv_name    varchar2(150);
    ln_nod     number;
    i          number;

    lv_prd_type    varchar2(150);
    lv_proc        VARCHAR2(240);
  BEGIN

    i := 0;

    lv_proc := g_package_name || 'get_days_yr_for_pay_period';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;

    IF py_prd_tp.count = 0 THEN

       OPEN  c_period_type;
       LOOP

         FETCH c_period_type INTO lv_name, ln_nod;
         EXIT WHEN c_period_type%NOTFOUND;

         py_prd_tp(i).name   := lv_name;
         py_prd_tp(i).days   := ln_nod;

         i := i + 1;

       END LOOP;

       CLOSE c_period_type;

    END IF;

    OPEN  c_pay_prd_type(p_payroll_id);
    FETCH c_pay_prd_type INTO lv_prd_type;
    CLOSE c_pay_prd_type;

    IF py_prd_tp.count <> 0 THEN

       FOR i in py_prd_tp.FIRST..py_prd_tp.LAST
       LOOP

-- Bug 4348355 - Modified condition since MX Annualization Factor
-- can only be 'Week' or 'Month'
--
--       IF py_prd_tp(i).name = lv_prd_type THEN

         IF INSTR(lv_prd_type, py_prd_tp(i).name) > 0 THEN

            p_period_type := py_prd_tp(i).name;
            p_days_year   := py_prd_tp(i).days;

         END IF;

       END LOOP;

    END IF;

    IF (g_debug) THEN
        hr_utility.trace('Leaving '||lv_proc);
    END IF;

  END get_days_yr_for_pay_period;


  /**********************************************************************
  **  Type      : Procedure
  **  Name      : get_no_of_days_for_org
  **  Purpose   : This procedure popuate number_of_days PL/SQL table
  **              for the Month and the Year for GRE or Legal Employer.
  **              (PL/SQL table structure mentioned above)
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **
  **              OUT Parameters
  **              p_days_month -> No. of Days in Month
  **              p_days_year  -> No. of Days in Year
  **
  **  Notes     :
  **********************************************************************/

  PROCEDURE get_no_of_days_for_org( p_business_group_id IN NUMBER
                                   ,p_org_id            IN NUMBER
                                   ,p_gre_or_le         IN VARCHAR2
                                   ,p_days_month        OUT NOCOPY NUMBER
                                   ,p_days_year         OUT NOCOPY NUMBER)
  IS

    CURSOR  c_gre_days( cp_organization_id number ) IS
      SELECT fnd_number.canonical_to_number(nvl(org_information8,'-999')),
             fnd_number.canonical_to_number(nvl(org_information9,'-999'))
      FROM   hr_organization_information
      WHERE  organization_id         = cp_organization_id
      AND    org_information_context = 'MX_SOC_SEC_DETAILS';

    CURSOR  c_le_days( cp_organization_id number ) IS
      SELECT fnd_number.canonical_to_number(nvl(org_information4,'-999')),
             fnd_number.canonical_to_number(nvl(org_information5,'-999'))
      FROM   hr_organization_information
      WHERE  organization_id         = cp_organization_id
      AND    org_information_context = 'MX_TAX_REGISTRATION';

    ln_leg_emplyr number;
    ln_nod_month  number;
    ln_nod_year   number;

    lv_proc       VARCHAR2(240);

  BEGIN

    p_days_month := 0;
    p_days_year  := 0;

    lv_proc := g_package_name || 'get_no_of_days_for_org';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;

    IF (p_gre_or_le = 'GRE') THEN

       IF (gre_no_of_days.EXISTS(p_org_id) = FALSE) THEN

          OPEN  c_gre_days(p_org_id);
          FETCH c_gre_days INTO ln_nod_month, ln_nod_year;

          IF (c_gre_days%FOUND AND ln_nod_month <> -999 AND ln_nod_year <> -999)
          THEN

             gre_no_of_days(p_org_id).days_month := ln_nod_month;
             gre_no_of_days(p_org_id).days_year  := ln_nod_year;

          END IF;

          CLOSE c_gre_days;

       END IF;

       p_days_month := gre_no_of_days(p_org_id).days_month;
       p_days_year  := gre_no_of_days(p_org_id).days_year;

    ELSE

       IF (le_no_of_days.EXISTS(p_org_id) = FALSE) THEN

         OPEN  c_le_days(p_org_id);
         FETCH c_le_days INTO ln_nod_month, ln_nod_year;

         IF (c_le_days%FOUND AND ln_nod_month <> -999 AND ln_nod_year <> -999)
         THEN

            le_no_of_days(p_org_id).days_month := ln_nod_month;
            le_no_of_days(p_org_id).days_year  := ln_nod_year;

         /* Bug 4348355*/
         ELSIF (c_le_days%FOUND AND ln_nod_month = -999 AND ln_nod_year <> -999)
         THEN

            le_no_of_days(p_org_id).days_year  := ln_nod_year;

         ELSIF (c_le_days%FOUND AND ln_nod_month <> -999 AND ln_nod_year = -999)
         THEN

            le_no_of_days(p_org_id).days_month := ln_nod_month;

         END IF;

         CLOSE c_le_days;

       END IF;

       p_days_month := le_no_of_days(p_org_id).days_month;
       p_days_year  := le_no_of_days(p_org_id).days_year;

    END IF;

    IF (g_debug) THEN
       hr_utility.trace('Leaving '||lv_proc);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
     p_days_month := NULL;
     p_days_year  := NULL;
  END get_no_of_days_for_org;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_month_year
  **  Purpose   : This function returns number of days based on p_mode.
  **              If p_mode is 'MONTH', this function returns no of days
  **              in month and if it is 'YEAR', this function return
  **              returns no of days in year.
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **              p_mode              -> 'MONTH' or 'YEAR'
  **
  **  Notes     :
  **********************************************************************/

  FUNCTION  get_days_month_year( p_business_group_id IN NUMBER
                                ,p_tax_unit_id       IN NUMBER
                                ,p_payroll_id        IN NUMBER
                                ,p_mode              IN VARCHAR2 )
  RETURN NUMBER IS

    ln_days_month NUMBER;
    ln_days_year  NUMBER;
    ln_le_id      hr_all_organization_units.organization_id%TYPE;

    ln_days_month_year  NUMBER;
    lv_period_type      VARCHAR2(150);
    lv_proc             VARCHAR2(240);

    CURSOR  c_actual_days_of_month IS
    SELECT TO_NUMBER(TO_CHAR(LAST_DAY(effective_date),'DD'))
    FROM fnd_sessions
    WHERE session_id = USERENV('SESSIONID') ;

  BEGIN

    ln_days_month := NULL;
    ln_days_year  := NULL;

    lv_proc := g_package_name || 'get_days_month_year';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;


    get_no_of_days_for_org( p_business_group_id => p_business_group_id
                           ,p_org_id            => p_tax_unit_id
                           ,p_gre_or_le         => 'GRE'
                           ,p_days_month        => ln_days_month
                           ,p_days_year         => ln_days_year);


    IF (p_mode = 'MONTH' AND ln_days_month IS NULL) OR
       (p_mode = 'YEAR' AND ln_days_year IS NULL) THEN

       ln_le_id := hr_mx_utility.get_legal_employer(
                                  p_business_group_id => p_business_group_id
                                 ,p_tax_unit_id       => p_tax_unit_id);

       get_no_of_days_for_org( p_business_group_id => p_business_group_id
                              ,p_org_id            => ln_le_id
                              ,p_gre_or_le         => 'LE'
                              ,p_days_month        => ln_days_month
                              ,p_days_year         => ln_days_year);

    END IF;

    IF (p_mode = 'YEAR' AND ln_days_year IS NULL) THEN

       get_days_yr_for_pay_period( p_payroll_id   => p_payroll_id
                                  ,p_period_type  => lv_period_type
                                  ,p_days_year    => ln_days_year);

    ELSIF (p_mode = 'MONTH' AND ln_days_month IS NULL) THEN

      -- Changed the logic to get the actual number of days of the month
      -- actual number of days is taken from the effective date of fnd_sessions
      -- as payroll being processed the effective_date will be inserted in the
      -- fnd_sessions table

      OPEN  c_actual_days_of_month ;
      FETCH c_actual_days_of_month INTO ln_days_month ;
      -- some reason it gets null then defaulting it to 30 average number of days
      IF ln_days_month IS NULL THEN
         ln_days_month := 30 ;
      END IF;
      CLOSE c_actual_days_of_month;

    END IF;

    IF p_mode = 'YEAR' THEN

       ln_days_month_year := ln_days_year;

    ELSE

       ln_days_month_year := ln_days_month;

    END IF;

    IF (g_debug) THEN
       hr_utility.trace('Leaving '||lv_proc);
    END IF;

    RETURN ln_days_month_year;

  END get_days_month_year;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_year
  **  Purpose   : This function returns number of days based in year.
  **              This function calls get_days_month_year function
  **              with p_mode 'YEAR'.
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **
  **  Notes     :
  **********************************************************************/

  FUNCTION  get_days_in_year( p_business_group_id IN NUMBER
                             ,p_tax_unit_id       IN NUMBER
                             ,p_payroll_id        IN NUMBER)
  RETURN NUMBER IS

    ln_days NUMBER;
    lv_proc VARCHAR2(240);

  BEGIN

    lv_proc := g_package_name || 'get_days_in_year';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;

    ln_days := get_days_month_year(
                              p_business_group_id => p_business_group_id
                             ,p_tax_unit_id       => p_tax_unit_id
                             ,p_payroll_id        => p_payroll_id
                             ,p_mode              => 'YEAR' );

    IF (g_debug) THEN
       hr_utility.trace('Leaving '||lv_proc);
    END IF;

    RETURN ln_days;

  END get_days_in_year;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_month
  **  Purpose   : This function returns number of days based in month.
  **              This function calls get_days_month_year function
  **              with p_mode 'MONTH'.
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **
  **  Notes     :
  **********************************************************************/

  FUNCTION  get_days_in_month( p_business_group_id IN NUMBER
                              ,p_tax_unit_id       IN NUMBER
                              ,p_payroll_id        IN NUMBER)
  RETURN NUMBER IS

    ln_days    NUMBER;
    lv_proc    VARCHAR2(240);

  BEGIN

    lv_proc := g_package_name || 'get_days_in_month';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;

    ln_days := get_days_month_year(
                              p_business_group_id => p_business_group_id
                             ,p_tax_unit_id       => p_tax_unit_id
                             ,p_payroll_id        => p_payroll_id
                             ,p_mode              => 'MONTH' );

    IF (g_debug) THEN
       hr_utility.trace('Leaving '||lv_proc);
    END IF;

    RETURN ln_days;

  END get_days_in_month;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_pay_period
  **  Purpose   : This function returns number of days based on payroll
  **              frequency.
  **              Week       -> 7 Days
  **              Bi-Week    -> 14 Days
  **              Month      -> Getting no of days using get_days_in_month
  **              Semi-Month -> Month Days (above) / 2
  **
  **  Arguments : IN Parameters
  **              p_business_group_id -> Business Group ID
  **              p_tax_unit_id       -> Tax Unit ID
  **              p_payroll_id        -> Payroll ID
  **
  **  Notes     :
  **********************************************************************/

  FUNCTION  get_days_in_pay_period( p_business_group_id IN NUMBER
                                   ,p_tax_unit_id       IN NUMBER
                                   ,p_payroll_id        IN NUMBER)
  RETURN NUMBER IS


    CURSOR c_pay_prd_type(cp_payroll_id NUMBER) IS
      SELECT period_type
      FROM   pay_payrolls_f
      WHERE  payroll_id = cp_payroll_id;

   CURSOR c_get_days_total IS
      SELECT to_number(to_char(effective_date,'DD')),
             to_number(to_char(last_day(effective_date),'DD'))
      from fnd_sessions
      where session_id = USERENV('sessionid') ;


    lv_prd_type    VARCHAR2(150);
    ln_month_days  NUMBER;
    ln_days        NUMBER;

    ln_days_mth         NUMBER;
    ln_total_days_mth   NUMBER ;

    lv_proc        VARCHAR2(240);

  BEGIN

    lv_proc := g_package_name || 'get_days_in_pay_period';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;

    OPEN  c_pay_prd_type(p_payroll_id);
    FETCH c_pay_prd_type INTO lv_prd_type;
    CLOSE c_pay_prd_type;

    IF instr(lv_prd_type,'Month') > 0 THEN

       ln_month_days := get_days_in_month(
                              p_business_group_id => p_business_group_id
                             ,p_tax_unit_id       => p_tax_unit_id
                             ,p_payroll_id        => p_payroll_id);


    END IF;

    IF lv_prd_type = 'Week' THEN

       ln_days := 7;

   ELSIF lv_prd_type = 'Ten Days' THEN

       ln_days := 10;

    ELSIF lv_prd_type = 'Bi-Week' THEN

       ln_days := 14;

    ELSIF lv_prd_type = 'Calendar Month' THEN

       ln_days := ln_month_days;

    ELSIF lv_prd_type = 'Semi-Month' THEN
      --
      -- ln_days := ln_month_days / 2;
      --
      -- Changed the logic to return 15 if date earned is less than or equal to 15
      -- else it is the difference from total no of days in the month
      -- ie payroll is processing on 15th of the month then return 15
      -- else return the difference from total no of days in the month
      -- ie if 15-Jan-2005 then 15
      --    if 31-Jan-2005 then 31-15=16 days
      --    if 28-Feb-2005 then 28-15=13 days
      -- This should be considered only when ln_month_days equal to 30

      OPEN c_get_days_total ;
      fetch c_get_days_total into ln_days_mth, ln_total_days_mth ;
      close C_get_days_total ;

      if (ln_days_mth > 15 AND ln_total_days_mth <> 30) then
         ln_days := ln_total_days_mth - 15 ;
      else
         ln_days := 15 ;
      end if;


    END IF;

    IF (g_debug) THEN
       hr_utility.trace('Leaving '||lv_proc);
    END IF;

    RETURN ln_days;

  END get_days_in_pay_period;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_days_in_bimonth
  **  Purpose   : This function returns number of days for current and
  **              previous month.
  **              If payroll processsing is on 15-APR-2005 then this function
  **              will return 30 (for april 2005) + 31 (for mar 2005) = 61
  **              days.
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_days_in_bimonth
  RETURN NUMBER IS

    ln_days    NUMBER;
    lv_proc    VARCHAR2(240);

    CURSOR c_get_days_in_bimonth IS
       SELECT  to_number(to_char(last_day(ADD_MONTHS(effective_date,-1)),'DD')) +
               to_number(to_char(last_day(effective_date),'DD'))
       from fnd_sessions
       where session_id = USERENV('sessionid') ;

  BEGIN

    lv_proc := g_package_name || 'get_days_in_bimonth';

    IF (g_debug) THEN
       hr_utility.trace('Entering '||lv_proc);
    END IF;

    open c_get_days_in_bimonth ;
    fetch c_get_days_in_bimonth into ln_days ;
    close c_get_days_in_bimonth ;

    IF (g_debug) THEN
       hr_utility.trace('Leaving '||lv_proc);
    END IF;

    RETURN ln_days;

  END get_days_in_bimonth;



  /**********************************************************************
  **  Type      : Function
  **  Name      : get_classification_id
  **  Purpose   : This function returns classification_id for Mexico.
  **
  **  Arguments : IN Parameters
  **              p_classification_name -> Classification Name.
  **  Notes     :
  **********************************************************************/
  FUNCTION  get_classification_id( p_classification_name IN VARCHAR2 )
  RETURN NUMBER IS

    CURSOR get_class_id( cp_classification_name VARCHAR2 ) IS
      SELECT classification_id
      FROM   pay_element_classifications
      WHERE  legislation_code     = 'MX'
      AND    classification_name  = cp_classification_name;

    l_classification_id NUMBER;

  BEGIN -- get_classification_id

    OPEN  get_class_id( p_classification_name );
    FETCH get_class_id  INTO l_classification_id;
    CLOSE get_class_id;

    RETURN l_classification_id;

  END get_classification_id;

  /**********************************************************************
  **  Type      : Procedure
  **  Name      : create_ele_tmplt_class_usg
  **  Purpose   : This procedure creates records for
  **              PAY_ELE_TMPLT_CLASS_USAGES table.
  **
  **  Arguments : IN Parameters
  **              p_classification_id    -> Classification ID
  **              p_template_id          -> Template ID
  **              p_display_process_mode -> Display Process Mode
  **              p_display_arrearage    -> Display Arrearage
  **  Notes     :
  **********************************************************************/
  PROCEDURE  create_ele_tmplt_class_usg( p_classification_id    IN NUMBER
                                        ,p_template_id          IN NUMBER
                                        ,p_display_process_mode IN VARCHAR2
                                        ,p_display_arrearage    IN VARCHAR2 )
  IS

    ln_exists               NUMBER;
    ln_ele_tmplt_class_id   NUMBER;

  BEGIN --create_ele_tmplt_class_usg

    SELECT COUNT(*)
    INTO   ln_exists
    FROM   pay_ele_tmplt_class_usages
    WHERE  classification_id = p_classification_id
    AND    template_id       = p_template_id;

    hr_utility.trace('ln_exists ' ||ln_exists);

    IF ln_exists = 0 THEN

       SELECT pay_ele_tmplt_class_usg_s.nextval
       INTO   ln_ele_tmplt_class_id
       FROM   dual;

       hr_utility.trace('ln_ele_tmplt_class_id ' ||ln_ele_tmplt_class_id);

       INSERT INTO pay_ele_tmplt_class_usages
                 ( ele_template_classification_id
                  ,classification_id
                  ,template_id
                  ,display_process_mode
                  ,display_arrearage )
        VALUES   ( ln_ele_tmplt_class_id
                  ,p_classification_id
                  ,p_template_id
                  ,p_display_process_mode
                  ,p_display_arrearage );

    END IF;

  END create_ele_tmplt_class_usg;

  /**********************************************************************
  **  Type      : Procedure
  **  Name      : create_template_classification
  **  Purpose   : This procedure is getting called from the template
  **              with Template ID and Classification Type and will
  **              decides how many record to be created for
  **              PAY_ELE_TMPLT_CLASS_USAGES table.
  **
  **  Arguments : IN Parameters
  **              p_template_id          -> Template ID
  **              p_classification_type  -> Display Process Mode
  **  Notes     :
  **********************************************************************/
  PROCEDURE  create_template_classification( p_template_id         IN NUMBER
                                            ,p_classification_type IN VARCHAR2)
  IS
    TYPE char_tabtype IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    l_classification_name char_tabtype;
    l_display_proc_mode   char_tabtype;
    l_display_arrearage   char_tabtype;

    l_classification_id   NUMBER;

  BEGIN --create_template_classification

    IF p_classification_type = 'Earnings' THEN

       l_classification_name(1) := 'Earnings';
       l_display_proc_mode(1)   := 'Y';
       l_display_arrearage(1)   := NULL;

       l_classification_name(2) := 'Supplemental Earnings';
       l_display_proc_mode(2)   := 'Y';
       l_display_arrearage(2)   := NULL;

       l_classification_name(3) := 'Imputed Earnings';
       l_display_proc_mode(3)   := 'Y';
       l_display_arrearage(3)   := NULL;

       l_classification_name(4) := 'Amends';
       l_display_proc_mode(4)   := 'Y';
       l_display_arrearage(4)   := NULL;

  /*     l_classification_name(5) := 'Employer Liabilities';
       l_display_proc_mode(5)   := 'Y';
       l_display_arrearage(5)   := NULL;
  */
    ELSIF p_classification_type = 'Deductions' THEN

       l_classification_name(1) := 'Voluntary Deductions';
       l_display_proc_mode(1)   := NULL;
       l_display_arrearage(1)   := 'Y';

       l_classification_name(2) := 'Pre-Tax Deductions';
       l_display_proc_mode(2)   := NULL;
       l_display_arrearage(2)   := 'Y';

       l_classification_name(3) := 'Involuntary Deductions';
       l_display_proc_mode(3)   := NULL;
       l_display_arrearage(3)   := 'Y';

    END IF;

    --hr_utility.trace_on(null,'ETCU');

    FOR i IN l_classification_name.FIRST..l_classification_name.LAST
    LOOP

       l_classification_id := get_classification_id( l_classification_name(i) );

       hr_utility.trace('------------------------------------------------');
       hr_utility.trace('i '|| i );
       hr_utility.trace('l_classification_name '|| l_classification_name(i));
       hr_utility.trace('l_classification_id '|| l_classification_id);
       hr_utility.trace('p_template_id '|| p_template_id);
       hr_utility.trace('l_display_proc_mode '|| l_display_proc_mode(i));
       hr_utility.trace('l_display_arrearage '|| l_display_arrearage(i));


       create_ele_tmplt_class_usg(
                  p_classification_id    => l_classification_id
                 ,p_template_id          => p_template_id
                 ,p_display_process_mode => l_display_proc_mode(i)
                 ,p_display_arrearage    => l_display_arrearage(i) );

    END LOOP;

  END create_template_classification;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_default_imp_date
  **  Purpose   : This function is returning Implementation Date.
  **              Using in Social Security Archiver.
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
   FUNCTION get_default_imp_date
   RETURN VARCHAR2 IS

     CURSOR c_get_def_imp_date IS
       SELECT fnd_date.canonical_to_date(legislation_info1)
       FROM   pay_mx_legislation_info_f
       WHERE  legislation_info_type = 'MX Social Security Reporting' ;

     ld_def_date        date ;

   BEGIN

     OPEN  c_get_def_imp_date;
     FETCH c_get_def_imp_date INTO ld_def_date;
     CLOSE c_get_def_imp_date;

     RETURN fnd_date.date_to_canonical(ld_def_date) ;

   END get_default_imp_date;

  /**********************************************************************
  **  Type      : Function
  **  Name      : get_parameter
  **  Purpose   : This function gets Paramter Value from
  **              legislation_parameters column of pay_payroll_actions
  **              WHENEVER TWO PARAMETERS ARE SEPARATED BY A SPACE
  **
  **  WARNING   : IF THERE IS A PIPE (OTHER THAN A SPACE)IN THE VALUE
  **              THEN DONOT USE THIS FUNCTION
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_parameter(name           IN VARCHAR2,
                         parameter_list IN VARCHAR2)
  RETURN VARCHAR2 IS

    par_value pay_payroll_actions.legislative_parameters%type;

  BEGIN

    par_value := get_legi_param_val(name
                                   ,parameter_list
                                   ,' ');

    RETURN par_value;

  END get_parameter;


  /**********************************************************************
  **  Type      : Function
  **  Name      : get_legi_param_val
  **  Purpose   : This function gets Paramter Value from
  **              legislation_parameters column of pay_payroll_actions
  **              WHENEVER TWO PARAMETERS ARE SEPARATED BY A PIPE (|)
  **
  **  WARNING   : IF THERE IS A SPACE IN THE VALUE
  **              THEN DONOT USE THIS FUNCTION
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_legi_param_val(name           IN VARCHAR2,
                              parameter_list IN VARCHAR2)
  RETURN VARCHAR2 IS

    par_value pay_payroll_actions.legislative_parameters%type;

  BEGIN

    par_value := get_legi_param_val(name
                                   ,parameter_list
                                   ,'|');

    RETURN par_value;

  END get_legi_param_val;

  /*************************************************************************
  **  Type      : Function
  **  Name      : get_legi_param_val
  **  Purpose   : This is an overloaded function that gets paramter Value
  **              from legislation_parameters column of pay_payroll_actions
  **              WHENEVER TWO PARAMETERS ARE SEPARATED BY EITHER A PIPE (|)
  **              OR A SPACE.
  **
  **  Arguments :
  **  Notes     :
  **********************************************************************/
  FUNCTION get_legi_param_val(name           IN VARCHAR2,
                              parameter_list IN VARCHAR2,
                              tag            IN VARCHAR2)
  RETURN VARCHAR2 IS

    start_ptr number;
    end_ptr   number;
    token_val pay_payroll_actions.legislative_parameters%type;
    par_value pay_payroll_actions.legislative_parameters%type;

  BEGIN

     token_val := name||'=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr   := instr(parameter_list, tag ,start_ptr);

     /* if there is no spaces use then length of the string */

     IF end_ptr = 0 THEN
        end_ptr := length(parameter_list)+1;
     END IF;

     /* Did we find the token */

     IF INSTR(parameter_list, token_val) = 0 THEN
       par_value := NULL;
     ELSE
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     END IF;

     RETURN par_value;

  END get_legi_param_val;



  /**********************************************************************
  **  Type      : Function
  **  Name      : get_process_parameters
  **  Purpose   : Returns Legislative parameters for specified payroll
  **              action
  **********************************************************************/
  FUNCTION get_process_parameters(p_cntx_payroll_action_id           IN NUMBER,
                                  p_parameter_name                   IN VARCHAR2)
  RETURN VARCHAR2 IS


      l_legislation_parameters  pay_payroll_actions.legislative_parameters%type;
      par_value                 pay_payroll_actions.legislative_parameters%type;

       CURSOR c_get_parameter_value IS
       SELECT legislative_parameters
       FROM   pay_payroll_actions
       WHERE  payroll_action_id = p_cntx_payroll_action_id;

  BEGIN

       hr_utility.trace('Entering ..get_process_parameters');
       OPEN c_get_parameter_value;
       FETCH c_get_parameter_value INTO l_legislation_parameters;
       CLOSE c_get_parameter_value;

       par_value := get_legi_param_val(p_parameter_name,l_legislation_parameters);

       hr_utility.trace('Parameter Name : '||p_parameter_name||' Value : '||par_value);
       hr_utility.trace('Leaving ..get_process_parameters');
      RETURN par_value;

  END get_process_parameters;


  /****************************************************************************
    Name        : GET_MX_ECON_ZONE
    Description : This function returns Economy Zone('A', 'B', 'C') for the
		  given tax_unit_id
  *****************************************************************************/


FUNCTION GET_MX_ECON_ZONE
(
    P_CTX_TAX_UNIT_ID           number,
    P_CTX_DATE_EARNED		DATE
) RETURN varchar2 AS

CURSOR get_econ_zone
       IS
        SELECT hoi.org_information7
          FROM hr_organization_units hou,
               hr_organization_information hoi
         WHERE hou.organization_id = hoi.organization_id
           AND hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
           AND hou.organization_id = P_CTX_TAX_UNIT_ID
           AND P_CTX_DATE_EARNED BETWEEN hou.date_from
                                    AND NVL(hou.date_to, hr_general.end_of_time);

l_econ_zone varchar2(2);

BEGIN


       OPEN get_econ_zone;
       FETCH get_econ_zone INTO l_econ_zone;
       CLOSE get_econ_zone;

       RETURN (l_econ_zone);
END GET_MX_ECON_ZONE;


  /****************************************************************************
    Name        : GET_MIN_WAGE
    Description : This function returns Minimum Wage for the Economy Zone
  *****************************************************************************/

FUNCTION GET_MIN_WAGE
(
    P_CTX_DATE_EARNED		DATE,
    P_TAX_BASIS     		varchar2,
    P_ECON_ZONE			varchar2

) RETURN varchar2 AS

CURSOR get_min_wage
	IS
	SELECT  fnd_number.canonical_to_number(legislation_info2)  FROM PAY_MX_LEGISLATION_INFO_F WHERE
    legislation_info1=
    DECODE(P_ECON_ZONE,'NONE','GMW','MW'||P_ECON_ZONE) AND
    legislation_info_type = 'MX Minimum Wage Information'
    AND P_CTX_DATE_EARNED BETWEEN  effective_start_date AND effective_end_date;

l_min_wage  number;

BEGIN

       hr_utility.trace('Economy Zone '||P_ECON_ZONE);
       OPEN get_min_wage;
       FETCH get_min_wage INTO l_min_wage;
       CLOSE get_min_wage;


       RETURN (l_min_wage);

END GET_MIN_WAGE;



BEGIN

  g_package_name := 'pay_mx_utility.';
  g_debug        := hr_utility.debug_enabled;

END pay_mx_utility;

/
