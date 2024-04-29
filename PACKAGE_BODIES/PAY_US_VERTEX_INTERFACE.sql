--------------------------------------------------------
--  DDL for Package Body PAY_US_VERTEX_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_VERTEX_INTERFACE" as
/* $Header: payusvertexetusg.pkb 120.6 2007/12/06 21:32:24 tclewis noship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        :
    Filename	: payusvertexetusg.pkh
    Description : This Package contains Procedures and Funbction required for
                  managing lement_type_usages for VERTEX and US_TAX_VERTEX
                  elements
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    12-DEC-2004 ppanda          115.0           Initial Version
    02-FEB-2005 ppanda          115.2   4155064 Modified various procedure and
                                                function to support Business
                                                Group
    04-MAR-2005 saikrish        115.4   4220606 Added Workers Compensation
    30-DEC-2005 saurgupt        115.5   4896715 Modified the query in function
                                                payroll_run_exist to improve performance.
    24-MAY-2007 jdevasah        115.7   5937604 Modified select_tax_interface procedure
                                                and Current_Tax_Interface function for
						the new tax interface
						Enahced+wage Accumulation.
   05-DEC-2007 rnestor          115.8  6658836  PLS-00103 ERROR WHEN COMPILING
                                       Had a Select inside the decode
*/

  PROCEDURE create_ele_tp_usg ( p_element_type_id      in number
                               ,p_run_type_id          in number
                               ,p_element_name         in varchar2
                               ,p_run_type_name        in varchar2
                               ,p_inclusion_flag       in varchar2
                               ,p_effective_date       in date
                               ,p_legislation_code     in varchar2
                               ,p_business_group_id    in number
                              ) IS

    cursor c_check_ele_tp_usg ( cp_legislation_code     varchar2
                               ,cp_business_group_id    number
                               ,cp_element_type_id      number
                               ,cp_run_type_id          number
                               ,cp_effective_date       date ) is



    select 1
    from   pay_element_type_usages_f petu
    where  petu.element_type_id      = cp_element_type_id
    and    petu.run_type_id          = cp_run_type_id
    and    cp_effective_date between petu.effective_start_date
                                 and petu.effective_end_date
    and   ( cp_legislation_code is not null and
               petu.legislation_code = cp_legislation_code )
    and   ( cp_business_group_id is not null and
                petu.business_group_id    = cp_business_group_id );

    l_element_type_usage_id  number;
    l_object_version_number  number;
    l_effective_start_date   date;
    l_effective_end_date     date;
    ln_exists                number;
    lv_usage_type       pay_element_type_usages_f.usage_type%type     := NULL;



  BEGIN
  --{
     hr_utility.trace('3000 -> Start create_ele_tp_usg ');
     hr_utility.trace('3010 -> Parameter Values ');
     hr_utility.trace('        p_legislation_code  : '||p_legislation_code);
     hr_utility.trace('        p_business_group_id : '||p_business_group_id);
     hr_utility.trace('        p_element_type_id   : '||p_element_type_id);
     hr_utility.trace('        p_element_name      : '||p_element_name);
     hr_utility.trace('        run_type_id         : '||p_run_type_id);
     hr_utility.trace('        run_type_Name       : '||p_run_type_name);
     hr_utility.trace('        p_effective_date    : '||p_effective_date);

     ln_exists := 0;
     hr_utility.trace('3020 -> Checking for the existence of Element Type Usages ');
     open  c_check_ele_tp_usg( p_legislation_code
                              ,p_business_group_id
                              ,p_element_type_id
                              ,p_run_type_id
                              ,p_effective_date);
     fetch c_check_ele_tp_usg into ln_exists;
     close c_check_ele_tp_usg;
     hr_utility.trace('3030 Element Type Usages Exists Flag : '||ln_exists);
     if ln_exists = 0 then
     --{
     hr_utility.trace('3040 -> Creating Element_Type_USages for Element: '||
                     p_element_name ||' Run Type Type: '||p_run_type_name );
     --
     -- Calling API to create Element Type Usages
     --
        pay_element_type_usage_api.create_element_type_usage(
                 p_effective_date        => p_effective_date
                ,p_run_type_id           => p_run_type_id
                ,p_element_type_id       => p_element_type_id
                ,p_business_group_id     => p_business_group_id
                ,p_legislation_code      => p_legislation_code
                ,p_usage_type            => lv_usage_type
                ,p_inclusion_flag        => p_inclusion_flag
                ,p_element_type_usage_id => l_element_type_usage_id
                ,p_object_version_number => l_object_version_number
                ,p_effective_start_date  => l_effective_start_date
                ,p_effective_end_date    => l_effective_end_date);
     --
        hr_utility.trace('3050 -> API Calls to Create Element_Type_Usages Ended ');
        hr_utility.trace('3060 -> Successfully Element Type Usages created ');
     --}
     else
        hr_utility.trace('3040 -> Element Type Exist creation skipped ');
     end if;
     hr_utility.trace('3999 -> End create_ele_tp_usg ');
  --}
  END create_ele_tp_usg;


  PROCEDURE delete_ele_type_usages (p_element_name      in varchar2,
                                    p_business_group_id in number)
  IS
  BEGIN
--{
      hr_utility.trace('1010 -> Start delete_ele_type_usages ');
      delete from PAY_ELEMENT_TYPE_USAGES_F peu1
       where EXISTS
              (select 'x'
                 from PAY_ELEMENT_TYPE_USAGES_F peu2,
                      pay_run_types_f prt,
                      pay_element_types_F pet
                where pet.element_name           = p_element_name
                  and peu2.element_type_id       = pet.element_type_id
                  and peu2.run_type_id           = prt.run_type_id
                  and peu2.ELEMENT_TYPE_USAGE_ID = peu1.ELEMENT_TYPE_USAGE_ID
                  and peu2.legislation_code      IS NULL
                  and peu2.business_group_id     = p_business_group_id
               );
     hr_utility.trace('1020 -> End delete_ele_type_usages ');
--}
  EXCEPTION
  WHEN OTHERS THEN
     hr_utility.trace('1030 -> WARNING: in delete_ele_type_usages ');
     hr_utility.trace('1040 -> ETU for VERTEX Element <'||p_element_name ||
                                                           '> Does not exist ');
  END delete_ele_type_usages;

  FUNCTION payroll_run_exist (p_business_group_id in number
                             )Return varchar2
  IS
  l_payroll_exist    varchar2(10);
  BEGIN
  l_payroll_exist := 'N';
--{
      hr_utility.trace('1100 -> Start payroll_run_exist ');
      hr_utility.trace('1105 -> Fetching records from PAY_PAYROLL_ACTIONS ');
      select 'Y'
        into l_payroll_exist
	from dual
       where exists( select 1
                       from PAY_PAYROLL_ACTIONS PPA
                      where PPA.action_type IN ('R','Q')
                        and PPA.action_status = 'C'
                        and PPA.business_group_id = p_business_group_id);
/*
      select 'Y'
        into l_payroll_exist
        from PAY_PAYROLL_ACTIONS PPA
       where PPA.action_type IN ('R','Q')
         and PPA.action_status = 'C'
         and PPA.business_group_id = p_business_group_id;
*/
     hr_utility.trace('1110 -> End payroll_run_exist ');
     return l_payroll_exist;
--}
  EXCEPTION
  WHEN TOO_MANY_ROWS THEN
     l_payroll_exist := 'Y';
     hr_utility.trace('1130 -> TOO_MANY_ROWS_EXCEPTION In Function'||
                                                         ' payroll_run_exist ');
     hr_utility.trace('1120 -> Payroll RUN Exist in this instance');
     return l_payroll_exist;
  WHEN OTHERS THEN
     l_payroll_exist := 'N';
     hr_utility.trace('1130 -> OTHER Exception payroll_run_exist ');
     hr_utility.trace('1140 -> Payroll RUN Does not exist in this instance');
     return l_payroll_exist;
  END payroll_run_exist;

  FUNCTION Current_Tax_Interface (p_lookup_code       in varchar2,
                                  p_business_group_id in number)
           Return varchar2
  IS
     l_current_tax_interface  varchar2(100);
     l_ret_value              varchar2(100);


     l_WAGEACCUM_parm                 varchar2(2);

    cursor c_parm_val_usg  is

    select parameter_value
    from  pay_action_parameters
     where parameter_name = 'WAGE_ACCUMULATION_ENABLED';

  BEGIN
--      hr_utility.trace_on(null, 'PPSELECTINTERFACE');
  l_current_tax_interface := 'VERTEX';
  l_ret_value             := ' ';
--{
      hr_utility.trace('1200 -> Start Current_Tax_Interface ');
      hr_utility.trace('1205 -> Default Tax Interface ' ||l_current_tax_interface );
      /* Bug#5937604: Need to set the status for the new tax interface WAGEACCUM.
                      Logic to calculate status of ENHACED interface is also modified */
      /* Bug 6658836 PLS-00103 ERROR WHEN COMPILING PAYUSVERTEXETUSG.PKB
      Had a select inside a decode statment RLN*/


    open  c_parm_val_usg;
    fetch c_parm_val_usg into l_WAGEACCUM_parm;
    if c_parm_val_usg%NOTFOUND THEN
       l_WAGEACCUM_parm := 'N';
    end if;
    close c_parm_val_usg;

      select --pet.element_name current_interface
             decode(p_lookup_code,
                        'STANDARD', decode(pet.element_name,
                                     'VERTEX','In Use','Not in Use'),
                        'ENHANCED', decode(pet.element_name,
                                     'US_TAX_VERTEX',decode(l_WAGEACCUM_parm
                                                  ,'N','In Use','Not In Use')
                                                  ,'Not in Use'),
                        'WAGEACCUM', decode(pet.element_name,
                                      'US_TAX_VERTEX',decode(l_WAGEACCUM_parm
                                              ,'Y','In Use','Not In Use')
                                              ,'Not in Use') ,' ')
        into l_ret_value
        from pay_element_types_f pet
       where pet.element_name      IN ('VERTEX',
                                       'US_TAX_VERTEX')
         and pet.legislation_code  = 'US'
         and pet.business_group_id IS NULL
         and NOT EXISTS
             ( select 'x'
                 from  pay_element_type_usages_f petu
                      ,pay_element_types_f  pet1
                      ,pay_run_types_f      prt
                where  petu.element_type_id  = pet1.element_type_id
                  and pet1.legislation_code  = 'US'
                  and pet1.business_group_id IS NULL
                  and prt.legislation_code   = 'US'
                  and prt.business_group_id  IS NULL
                  and petu.run_type_id       = prt.run_type_id
                  and petu.business_group_id = p_business_group_id --IS NULL
                  and petu.element_Type_id   = pet.element_type_id
                  --and petu.legislation_code  = 'US'
                  and petu.legislation_code  IS NULL
                  and pet1.business_group_id IS NULL
                  and pet1.legislation_code  = 'US'
                  and prt.legislation_code   = 'US'
                  and exists
                      ( select 'x' from pay_run_types_f  prt1
                         where prt1.run_type_name IN ('Regular Standard Run',
                                                      'Separate Payment Run',
                                                      'Tax Separate Run',
                                                   'Supplemental Standard Run',
                                                      'Regular',
                                                      'Supplemental')
                           and prt1.business_group_id IS NULL
                           and prt1.legislation_code = 'US'
                           and prt1.run_type_id = petu.run_type_id ));

     hr_utility.trace('1207 -> Return Value '||l_ret_value);
     hr_utility.trace('1210 -> End Current_Tax_Interface');
     return l_ret_value;
--}
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
--{
     select decode(p_lookup_code,
     	           'STANDARD', 'In Use','Not in Use')
       into l_ret_value
       from DUAL;
     hr_utility.trace('1215 -> Current Tax Interface element is VERTEX');
     hr_utility.trace('1220 -> Return Value '||l_ret_value);
     return l_ret_value;
--}
  WHEN OTHERS THEN
--{

     hr_utility.trace('1225 -> Other Exception'||substr(sqlerrm,1,30));
     hr_utility.trace('1226 -> '||substr(sqlerrm,31,40));
     hr_utility.trace('1230 -> Current Tax Interface element is VERTEX');
     select decode(p_lookup_code,
      	           'STANDARD', 'In Use','Not in Use')
       into l_ret_value
       from DUAL;
     hr_utility.trace('1240 -> Return Value '||l_ret_value);
     return l_ret_value;

--}
  END Current_Tax_Interface;


  FUNCTION vertex_eletype_usage_exist (p_element_name      varchar2,
                                       p_business_group_id number)
           Return varchar2
  IS
     l_element_type_usage_exist  varchar2(10);
  BEGIN
     l_element_type_usage_exist := 'N';
--{
      hr_utility.trace('1300 -> Entering vertex_eletype_usage_exist ');
     select  'Y'
     into l_element_type_usage_exist
     from pay_element_types_f pet
     where element_name = p_element_name
       and business_group_id IS NULL
       and legislation_code = 'US'
     and exists
         ( select  'x'
             from  pay_element_type_usages_f petu
                  ,pay_element_types_f  pet1
                  ,pay_run_types_f      prt
            where petu.element_type_id   = pet1.element_type_id
              and pet1.legislation_code  = 'US'
              and prt.legislation_code   = 'US'
              and petu.run_type_id       = prt.run_type_id
              and petu.business_group_id = p_business_group_id --IS NULL
              and petu.legislation_code  IS NULL               --= 'US'
              and petu.element_Type_id   = pet.element_type_id
              and exists
                  ( select 'x' from pay_run_types_f  prt1
                     where prt1.run_type_name IN ('Regular Standard Run',
                                                  'Separate Payment Run',
                                                  'Tax Separate Run',
                                                  'Supplemental Standard Run',
                                                  'Regular',
                                                  'Supplemental')
                      and prt1.business_group_id IS NULL
                      and prt1.legislation_code = 'US'
                      and prt1.run_type_id = petu.run_type_id ));
     hr_utility.trace('1310 -> Element Type Usage Exist for Element '|| p_element_name);
     hr_utility.trace('1320 -> Leaving vertex_eletype_usage_exist ');
     return l_element_type_usage_exist;
--}
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
--{
     l_element_type_usage_exist := 'N';
     hr_utility.trace('1330 -> Exception NO_DATA_FOUND ');
     hr_utility.trace('1340 -> Element Type Usages do not Exist for Element '|| p_element_name);
     hr_utility.trace('1350 -> Leaving vertex_eletype_usage_exist ');
     return l_element_type_usage_exist;
--}
  WHEN OTHERS THEN
--{
     l_element_type_usage_exist := 'N';
     hr_utility.trace('1330 -> Exception OTHERS ');
     hr_utility.trace('1340 -> Element Type Usages do not Exist for Element '|| p_element_name);
     hr_utility.trace('1350 -> Leaving vertex_eletype_usage_exist ');
     return l_element_type_usage_exist;
--}
  END vertex_eletype_usage_exist;




-- This procedure Excudes the TAX Element from processing depending on
-- customer selection
-- IF Customer selection is  STANDARD interface
--       New Tax Element US_TAX_VERTEX will be excluded
-- ELSIF Customer selection is ENHANCED interface
--       Old Tax Element VERTEX will be excluded
  PROCEDURE select_tax_interface(errbuf              OUT nocopy VARCHAR2,
                                 retcode             OUT nocopy NUMBER,
                                 p_business_group_id IN         NUMBER,
                                 p_vertex_interface  IN         VARCHAR2)
  IS
--
-- Run Types used for VERTEX or US_TAX_VERTEX Elements

--
  CURSOR c_run_type is
  select prt.* from pay_run_types_f  prt
   where prt.run_type_name IN ('Regular Standard Run',
                               'Separate Payment Run',
                               'Tax Separate Run',
                               'Supplemental Standard Run',
                               'Regular',
                               'Supplemental')
    and prt.business_group_id IS NULL
    and prt.legislation_code = 'US';
--
-- Element Type details
--
    cursor c_vertex_elements (c_element_name varchar2)
    is
       SELECT pet.ELEMENT_TYPE_ID,
              pet.element_name,
              pet.business_group_id,
              pet.legislation_code,
              pet.effective_start_date effective_date
         FROM PAY_ELEMENT_TYPES_F pet
        WHERE pet.ELEMENT_NAME      = c_element_name
          AND pet.LEGISLATION_CODE  = 'US'
          AND pet.business_group_id IS NULL
        ORDER by pet.element_name;
--
-- Element Type Usages Details
--
  ln_commit_counter          number;
  l_wage_exists              number;
  lv_exists                  varchar2(1);
  lv_interoperable_flag      varchar2(10);
  l_field_name               PAY_LEGISLATIVE_FIELD_INFO.field_name%type;
  l_payroll_exist            varchar2(10);
  l_vertex_etu_exist         varchar2(10);
  l_us_tax_vertex_etu_exist  varchar2(10);
  lv_inclusion_flag          pay_element_type_usages_f.inclusion_flag%type;
  l_null_legislation_code    pay_element_types_f.legislation_code%type;
  BEGIN
--     hr_utility.trace_on(null, 'PPSELTAX');

     hr_utility.trace('2000 -> Start payustaxinterface.sql ');
     hr_utility.trace('2005 -> Parameter Values ');
     hr_utility.trace('2006 -> Vertex_Interface Required  '||p_vertex_interface);
     hr_utility.trace('2006 -> setting for Business Group '||to_char(p_business_group_id));
     l_null_legislation_code := NULL;
--{
-- This section used to set the env for Running the Startup API
--
     hr_utility.trace('2010 -> Start Setting env for Running API ');
     hr_startup_data_api_support.enable_startup_mode('USER');
     hr_startup_data_api_support.create_owner_definition('PAY');
     BEGIN
       SELECT field_name
         INTO l_field_name
         FROM PAY_LEGISLATIVE_FIELD_INFO
        WHERE FIELD_NAME       = 'ET_USAGE'
          AND LEGISLATION_CODE = 'US';
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
           INSERT INTO PAY_LEGISLATIVE_FIELD_INFO
                 (FIELD_NAME,
                  LEGISLATION_CODE,
                  RULE_TYPE,
                  RULE_MODE)
           VALUES
                 ('ET_USAGE',
                  'US',
                  'ENABLE',
                  'Y');
     END;
     hr_utility.trace('2020 -> Setup completed for Running API ');

     IF p_vertex_interface  = 'STANDARD'
     THEN
        hr_utility.trace('2050 -> Payroll Run exist in this Instance');
        /*Bug#5937604: Disable WAGE_ACCUMULATION_ENABLED parameter */
	update pay_action_parameters
	     set parameter_value= 'N'
             where parameter_name='WAGE_ACCUMULATION_ENABLED';

        l_vertex_etu_exist :=
                   pay_us_vertex_interface.vertex_eletype_usage_exist('VERTEX',
                                                                      p_business_group_id);
        l_us_tax_vertex_etu_exist :=
            pay_us_vertex_interface.vertex_eletype_usage_exist('US_TAX_VERTEX',
                                                                      p_business_group_id);
        IF l_us_tax_vertex_etu_exist = 'N'
        THEN
        --{
             IF l_vertex_etu_exist = 'Y'
             THEN
               hr_utility.trace('2060 -> Deleting Element Type Usages ');
               pay_us_vertex_interface.delete_ele_type_usages('VERTEX', p_business_group_id);
	       /* 4220606*/
               pay_us_vertex_interface.delete_ele_type_usages('Workers Compensation', p_business_group_id);

             END IF;
        --
        -- This piece of code for creating Element_Type_Usages for
        --      Vertex Element US_TAX_VERTEX
               hr_utility.trace('2070 -> Tax Interface Script for creating');
               hr_utility.trace('2080 -> Element_Type_Usages for US_TAX_VERTEX');
               for earn in c_vertex_elements('US_TAX_VERTEX')
               loop
                 lv_inclusion_flag := 'N';
                 hr_utility.trace('2090 -> Inclusion Flag '||lv_inclusion_flag);
                 for run_type in c_run_type
                 loop
        --{
                    hr_utility.trace('2100 -> Element Type Name '||
                                                             earn.element_name);
                    hr_utility.trace('2110 -> Run Type Name '||
                                                        run_type.run_type_name);
                    hr_utility.trace('2120 -> Calling '
                               || 'pay_us_vertex_interface.create_ele_tp_usg ');
                    hr_utility.trace('2130 -> For creating element_type_usages '
                               || 'for '|| earn.element_name);
                    pay_us_vertex_interface.create_ele_tp_usg
                              ( p_element_type_id      => earn.element_type_id
                               ,p_run_type_id          => run_type.run_type_id
                               ,p_element_name         => earn.element_name
                               ,p_run_type_name        => run_type.run_type_name
                               ,p_inclusion_flag       => lv_inclusion_flag
                               ,p_effective_date       =>
                                                   run_type.effective_start_date
                               ,p_legislation_code     => l_null_legislation_code
                                                                --earn.legislation_code
                               ,p_business_group_id    => p_business_group_id);
--                                                        earn.business_group_id);
                    hr_utility.trace('2130 -> US_TAX_VERTEX element excluded');
        --}
                 end loop;
               end loop;
        ELSIF l_us_tax_vertex_etu_exist = 'Y'
        THEN
        --{
             IF l_vertex_etu_exist = 'Y'
             THEN
               hr_utility.trace('2060 -> Deleting Element Type Usages ');
               pay_us_vertex_interface.delete_ele_type_usages('VERTEX',p_business_group_id);
	       /* 4220606 */
               pay_us_vertex_interface.delete_ele_type_usages('Workers Compensation',p_business_group_id);
             END IF;
-- VERTEX Element is excluded and US_TAX_VERTEX is in use
             hr_utility.trace('2060 -> Tax Element US_TAX_VERTEX is Excluded');
             hr_utility.trace('2070 -> Tax element VERTEX is in use');
        END IF;
     ELSIF p_vertex_interface  = 'ENHANCED' or p_vertex_interface = 'WAGEACCUM'
     THEN
        hr_utility.trace('2050 -> Payroll Run exist in this Instance');

	IF p_vertex_interface  = 'ENHANCED' THEN
         /*Bug#5937604: update pay_action_paramters */
	    update pay_action_parameters
	     set parameter_value= 'N'
             where parameter_name='WAGE_ACCUMULATION_ENABLED';
	ELSIF p_vertex_interface = 'WAGEACCUM' then
          /*Bug#5937604: Insert on pay_action_paramters */
	  select count(*) into l_wage_exists from pay_action_parameters
	     where parameter_name='WAGE_ACCUMULATION_ENABLED';

	  if l_wage_exists = 0 then
	     insert into pay_action_parameters
	     (
	       parameter_name
	       ,parameter_value
	     )
	     values
	     (
	     'WAGE_ACCUMULATION_ENABLED'
	     ,'Y'
	     );

	  else
	    update pay_action_parameters
	     set parameter_value= 'Y'
             where parameter_name='WAGE_ACCUMULATION_ENABLED';
	  end if;

	END IF;

        l_vertex_etu_exist :=
                   pay_us_vertex_interface.vertex_eletype_usage_exist('VERTEX',
                                                                      p_business_group_id);
        l_us_tax_vertex_etu_exist :=
            pay_us_vertex_interface.vertex_eletype_usage_exist('US_TAX_VERTEX',
                                                                      p_business_group_id);
        IF l_vertex_etu_exist  = 'N'
        THEN
        --{
             IF l_us_tax_vertex_etu_exist = 'Y'
             THEN
               hr_utility.trace(
                          '2060 -> Deleting Element Type Usages US_TAX_VERTEX');
               pay_us_vertex_interface.delete_ele_type_usages('US_TAX_VERTEX',
                                                              p_business_group_id);
             END IF;
        --
        -- This piece of code for creating Element_Type_Usages for
        --      Vertex Element VERTEX
             hr_utility.trace('2070 -> Tax Interface Script for creating');
             hr_utility.trace('2080 -> Element_Type_Usages for VERTEX');
             for earn in c_vertex_elements('VERTEX')
             loop
                lv_inclusion_flag := 'N';
                hr_utility.trace('2090 -> Inclusion Flag '||lv_inclusion_flag);
                for run_type in c_run_type
                loop
        --{
                   hr_utility.trace('2100 -> Element Type Name '||
                                                             earn.element_name);
                   hr_utility.trace('2110 -> Run Type Name '||
                                                        run_type.run_type_name);
                   hr_utility.trace('2120 -> Calling '
                               || 'pay_us_vertex_interface.create_ele_tp_usg ');
                   hr_utility.trace('2130 -> For creating element_type_usages '
                               || 'for '|| earn.element_name);
                   pay_us_vertex_interface.create_ele_tp_usg
                              ( p_element_type_id      => earn.element_type_id
                               ,p_run_type_id          => run_type.run_type_id
                               ,p_element_name         => earn.element_name
                               ,p_run_type_name        => run_type.run_type_name
                               ,p_inclusion_flag       => lv_inclusion_flag
                               ,p_effective_date       =>
                                                   run_type.effective_start_date
                               ,p_legislation_code     => l_null_legislation_code
                                                                   --earn.legislation_code
                               ,p_business_group_id    => p_business_group_id);
--                                                        earn.business_group_id);
                    hr_utility.trace('2130 -> VERTEX element excluded');
        --}
                 end loop;
               end loop;

	       /* 4220606 */
	             --
        -- This piece of code for creating Element_Type_Usages for
        --      Workers Compensation
             hr_utility.trace('2070 -> Tax Interface Script for creating');
             hr_utility.trace('2080 -> Element_Type_Usages for Workers Compensation');
             for earn in c_vertex_elements('Workers Compensation')
             loop
                lv_inclusion_flag := 'N';
                hr_utility.trace('2090 -> Inclusion Flag '||lv_inclusion_flag);
                for run_type in c_run_type
                loop
        --{
                   hr_utility.trace('2100 -> Element Type Name '||
                                                             earn.element_name);
                   hr_utility.trace('2110 -> Run Type Name '||
                                                        run_type.run_type_name);
                   hr_utility.trace('2120 -> Calling '
                               || 'pay_us_vertex_interface.create_ele_tp_usg ');
                   hr_utility.trace('2130 -> For creating element_type_usages '
                               || 'for '|| earn.element_name);
                   pay_us_vertex_interface.create_ele_tp_usg
                              ( p_element_type_id      => earn.element_type_id
                               ,p_run_type_id          => run_type.run_type_id
                               ,p_element_name         => earn.element_name
                               ,p_run_type_name        => run_type.run_type_name
                               ,p_inclusion_flag       => lv_inclusion_flag
                               ,p_effective_date       =>
                                                   run_type.effective_start_date
                               ,p_legislation_code     => l_null_legislation_code
                                                                   --earn.legislation_code
                               ,p_business_group_id    => p_business_group_id);
--                                                        earn.business_group_id);
                    hr_utility.trace('2130 -> VERTEX element excluded');
        --}
                 end loop;
               end loop;
               /* 42206060 */
        ELSIF l_vertex_etu_exist = 'Y'
        THEN
        --{
             IF l_us_tax_vertex_etu_exist = 'Y'
             THEN
               hr_utility.trace('2060 -> Deleting Element Type Usages ');
               pay_us_vertex_interface.delete_ele_type_usages('US_TAX_VERTEX',
                                                              p_business_group_id);
             END IF;
-- VERTEX Element is excluded and US_TAX_VERTEX is in use
             hr_utility.trace('2060 -> Tax Element VERTEX is Excluded');
             hr_utility.trace('2070 -> Tax element US_TAX_VERTEX is in use');
        END IF;
     END IF;
--}
  END select_tax_interface;
END pay_us_vertex_interface;

/
