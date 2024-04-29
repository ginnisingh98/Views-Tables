--------------------------------------------------------
--  DDL for Package Body PAY_US_USERRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_USERRA" as
/* $Header: pyususer.pkb 120.3.12010000.2 2009/02/18 11:41:48 asgugupt ship $*/

  /********* logging message cover for hr_utility  *********/

  PROCEDURE plog ( p_message IN varchar2 ) is

  /* output a message to the process log file */
  BEGIN
     hr_utility.trace(p_message);
  END plog;

  PROCEDURE insert_userra_balances(errbuf out nocopy varchar2,
                                   retcode out nocopy number,
                                   p_year  in varchar2,
                                   p_category in varchar2,
                                   p_balance in varchar2,
                                   p_business_group_id in number) is

  /************************************************************
  ** Local Package Variables
  ************************************************************/

      lv_lookup_code    fnd_common_lookups.lookup_code%TYPE := null;
      lv_lookup_type    fnd_common_lookups.lookup_type%TYPE := null;
      lv_enabled_flag   fnd_common_lookups.enabled_flag%TYPE := null;
      lv_balance        fnd_common_lookups.meaning%TYPE := null;
      lv_description    fnd_common_lookups.description%TYPE := null;
      ln_application_id fnd_common_lookups.application_id%TYPE := 0;
      lv_live_dbi       ff_database_items.user_name%TYPE := null;
      lv_archive_dbi    ff_database_items.user_name%TYPE := null;
      lv_year           varchar2(4);
      lv_short_year     varchar2(2) := null;
      ld_year           date;
      lv_business_group_name hr_organization_units.name%TYPE;

      lv_dimension      varchar2(60) := 'Person within Government Reporting Entity Year to Date';
      ln_bal_type_id    number:= 0;
      lv_legislation    varchar2(2)      := 'US';
      ld_eff_start_date date := to_date('01/01/0001', 'DD/MM/YYYY');
      ld_eff_end_date   date := to_date('31/12/4712', 'DD/MM/YYYY');
      ln_exists         number;
      ln_route_id       number;
      ln_count          number := 0;
      lv_exists         varchar2(1) := null ;
      ln_step           number := 0;
      lv_category       varchar2(20);

      /* Cursor to determine balance type id */

      CURSOR csr_balance_id(cp_balance_name VARCHAR2) IS
        ( SELECT balance_type_id
            FROM pay_balance_types
           WHERE balance_name = cp_balance_name
             AND   business_group_id = p_business_group_id);

      CURSOR c_get_lookup_code(cp_lookup_type in varchar2,
                               cp_lookup_code  in varchar2,
                               cp_application_id in number) is
      select 'x'
        from fnd_common_lookups
       where lookup_type = cp_lookup_type
         and lookup_code = cp_lookup_code
         and application_id = cp_application_id ;

     CURSOR c_get_archive_dbi(cp_archive_dbi in varchar2
                              )is
     select 'y'
       from ff_user_entities fue
      where user_entity_name = cp_archive_dbi;

     CURSOR c_get_business_group(cp_business_group_id in number)is
     select name from hr_organization_units
      where organization_id = cp_business_group_id;

  BEGIN

     --hr_utility.trace_on (null, 'USERRA');
     ln_step := 10;


     /* Initialize variables */

     lv_lookup_type := 'W2 BOX 12';
     ln_application_id := 801;
     lv_enabled_flag := 'Y';
     ld_year := fnd_date.canonical_to_date(p_year) ;
     lv_year := to_char(ld_year,'YYYY');
     lv_short_year  :=  substr(lv_year,3,2);
     lv_description := 'Creation of '||lv_year||' USERRA Balances for Box 12 of W2';
     --
     --
     if p_category = 'R401K' then
        lv_category := 'AA';
     elsif p_category = 'R403B' then
        lv_category := 'BB';
     end if;
     --
     --

     if p_category = 'D' then
        lv_balance := 'W2 USERRA 401K '||p_category||lv_short_year;
        lv_lookup_code := 'A_'||replace(lv_balance,' ','_');
        lv_live_dbi  := replace(lv_balance,' ','_')||'_PER_GRE_YTD';
        lv_archive_dbi  := 'A_'||lv_live_dbi ;
        ln_step := 20;
     elsif p_category = 'E' then
        lv_balance := 'W2 USERRA 403B '||p_category||lv_short_year;
        lv_lookup_code := 'A_'||replace(lv_balance,' ','_');
        lv_live_dbi  := replace(lv_balance,' ','_')||'_PER_GRE_YTD';
        lv_archive_dbi  := 'A_'||lv_live_dbi ;
        ln_step := 25;
     elsif p_category = 'G' then
        lv_balance := 'W2 USERRA 457 '||p_category||lv_short_year;
        lv_lookup_code := 'A_'||replace(lv_balance,' ','_');
        lv_live_dbi  := replace(lv_balance,' ','_')||'_PER_GRE_YTD';
        lv_archive_dbi  := 'A_'||lv_live_dbi ;
        ln_step := 30;
     elsif p_category = 'R401K' then
        lv_balance := 'W2 USERRA ROTH 401K '||lv_category||lv_short_year;
        lv_lookup_code := 'A_'||replace(lv_balance,' ','_');
        lv_live_dbi  := replace(lv_balance,' ','_')||'_PER_GRE_YTD';
        lv_archive_dbi  := 'A_'||lv_live_dbi ;
        ln_step := 35;
     elsif p_category = 'R403B' then
        lv_balance := 'W2 USERRA ROTH 403B '||lv_category||lv_short_year;
        lv_lookup_code := 'A_'||replace(lv_balance,' ','_');
        lv_live_dbi  := replace(lv_balance,' ','_')||'_PER_GRE_YTD';
        lv_archive_dbi  := 'A_'||lv_live_dbi ;
        ln_step := 40;
     end if;

     hr_utility.trace('lv_balance ='||lv_balance);
     hr_utility.trace('lv_lookup_code ='||lv_lookup_code);
     hr_utility.trace('lv_live_dbi ='||lv_live_dbi);
     hr_utility.trace('lv_archive_dbi ='||lv_archive_dbi);
     hr_utility.trace('lv_year ='||lv_year);
     hr_utility.trace('lv_short_year ='||lv_short_year);
     hr_utility.trace('ld_year ='||to_char(ld_year));
     hr_utility.trace('Checking existence of lookup_code');


    ln_step := 35;
     open c_get_business_group(p_business_group_id);

      fetch c_get_business_group INTO lv_business_group_name;

        if c_get_business_group%NOTFOUND THEN
          hr_utility.raise_error;
        end if;
      close c_get_business_group;

    ln_step := 40;


      hr_utility.trace('lv_business_group_name ='||lv_business_group_name);

      open c_get_lookup_code(lv_lookup_type,
                             lv_lookup_code,
                             ln_application_id);
      ln_step := 40;

      fetch c_get_lookup_code into lv_exists;

      hr_utility.trace('Fetched c_get_lookup_code ');

       if c_get_lookup_code%NOTFOUND then

       ln_step := 50;

       /************************************************************
        ** add lookup_type in fnd_lookup_values
        ************************************************************/
         insert into fnd_lookup_values(lookup_type,
                                       language,
                                       lookup_code,
                                       meaning,
                                       description,
                                       enabled_flag,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       source_lang,
                                       view_application_id,
                                       last_update_login)
                                 values(lv_lookup_type,
                                        lv_legislation,
                                        lv_lookup_code,
                                        lv_balance,
                                        lv_description,
                                        lv_enabled_flag,
                                        1,
                                        sysdate,
                                        2,
                                        sysdate,
                                        lv_legislation,
                                        3,
                                        0);


       end if ; /* lookup_code */

      close c_get_lookup_code;
      ln_step := 60;


      open csr_balance_id(lv_balance);

      fetch csr_balance_id INTO ln_bal_type_id;

        if csr_balance_id%NOTFOUND THEN
           ln_step := 70;

           /************************************************************
           ** create balances in pay_balance_type
           ************************************************************/

           ln_bal_type_id := Pay_DB_Pay_Setup.Create_Balance_type(
                p_balance_name         =>    lv_balance,
                p_uom                  =>    'Money',
                p_currency_code        =>    'USD',
                p_reporting_name       =>    lv_balance,
                p_business_group_name  =>    lv_business_group_name);

             plog('Creating Balance Type: '||lv_balance||' '||
                   to_char(ln_bal_type_id));
           else
             ln_step := 80;
             plog('Balance Type Already Created: '||lv_balance);
           end if;
      close csr_balance_id;

      /************************************************************
       ** Create Defined Balance Id
       ************************************************************/
       hr_utility.trace('ln_bal_type_id = '||to_char(ln_bal_type_id));
       hr_utility.trace('lv_dimension ='||lv_dimension);

        SELECT  count(0)
          INTO    ln_exists
          FROM    pay_defined_balances db,
                  pay_balance_dimensions dim
         WHERE   db.balance_type_id      = ln_bal_type_id
           AND     db.balance_dimension_id = dim.balance_dimension_id
           AND     dim.dimension_name      = lv_dimension;

        ln_step := 90;

         if ln_exists = 0 then

               ln_step := 100;
               pay_db_pay_setup.create_defined_balance(
                   p_balance_name          => lv_balance,
                   p_balance_dimension     => lv_dimension,
                   p_business_group_name   => lv_business_group_name);
--bug no 6886424 starts here
               ln_step := 105;
               lv_dimension  := 'Assignment within Government Reporting Entity Run';
               pay_db_pay_setup.create_defined_balance(
                   p_balance_name          => lv_balance,
                   p_balance_dimension     => lv_dimension,
                   p_business_group_name   => lv_business_group_name,
                   p_save_run_bal=>'Y');
--bug no 6886424 ends here
               plog('Balance: '||lv_balance||
                       ', with Suffix: '||lv_dimension||' created..');
          else
               ln_step := 110;
               plog('Balance: '||lv_balance||
                           ', with Suffix: '||lv_dimension||' already exists');
          end if;

            /* No balance feeds are created for this balance */

            /************************************************************
             ** Create archive database item
             ************************************************************/
               hr_utility.trace('Checking existence of archive_dbi');
               lv_exists := null;
               open c_get_archive_dbi(lv_archive_dbi);
               ln_step := 120;

               fetch c_get_archive_dbi into lv_exists;
                  if c_get_archive_dbi%NOTFOUND then
                     ln_step := 130;
                     hr_utility.trace('Archive dbi not found');
                     py_w2_dbitems.create_eoy_archive_dbi(lv_archive_dbi);

                     plog('Created Archive Database Item  '||lv_archive_dbi);

                  end if;
              close c_get_archive_dbi;
    commit;

    EXCEPTION
     when others then
      hr_utility.trace('Error in inserting USERRA data at step '
           ||to_char(ln_step)|| ' - '|| to_char(sqlcode));
      raise_application_error(-20001,'Error in create USERRA data at step '
            ||to_char(ln_step)||' - '||to_char(sqlcode) || '-' || sqlerrm);
  END; /*insert userra balances */

END pay_us_userra;

/
