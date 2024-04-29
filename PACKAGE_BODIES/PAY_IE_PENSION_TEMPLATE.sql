--------------------------------------------------------
--  DDL for Package Body PAY_IE_PENSION_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PENSION_TEMPLATE" As
/* $Header: pyiepend.pkb 120.2.12000000.2 2007/09/17 07:03:50 rrajaman noship $ */

  g_proc_name         varchar2(80) := '  pay_ie_pension_template.';

-- ---------------------------------------------------------------------
-- |-----------------------< Compile_Formula >--------------------------|
-- ---------------------------------------------------------------------
procedure Compile_Formula
            (p_element_type_id       in number
            ,p_effective_start_date  in date
            ,p_scheme_prefix         in varchar2
            ,p_business_group_id     in number
            ,p_request_id            out nocopy number
           ) is
  -- --------------------------------------------------------
  -- Cursor to get the formula details necessary to compile
  -- --------------------------------------------------------
  cursor csr_fra(c_element_type_id number) is
    select
           fra.formula_id,
           fra.formula_name,
           fty.formula_type_id,
           fty.formula_type_name
      from ff_formulas_f                 fra,
           ff_formula_types              fty,
           pay_status_processing_rules_f spr
     where fty.formula_type_id = fra.formula_type_id
       and fra.formula_id      = spr.formula_id
       and spr.assignment_status_type_id is null
       and spr.element_type_id = c_element_type_id
       and p_effective_start_date between fra.effective_start_date
                                      and fra.effective_end_date
       and p_effective_start_date between spr.effective_start_date
                                      and spr.effective_end_date;

   l_request_id      number;
   l_er_request_id   number;
   l_proc_name       Varchar2(80) := g_proc_name || 'compile_formula';
   l_user_id         number;
   l_resp_id         number;
begin
  hr_utility.set_location('Entering: '||l_proc_name, 10);
  -- ------------------------------------------------------------
  -- Query formula info (ie. the formula attached to this
  -- element's Standard status proc rule.
  -- ------------------------------------------------------------
  for fra_rec in csr_fra (c_element_type_id => p_element_type_id)
  loop
    hr_utility.set_location('..FF Name :'||fra_rec.formula_name,15);
    hr_utility.set_location('..FF Type Name :'||fra_rec.formula_type_name,20);
    -- ----------------------------------------------
    -- Submit the request to compile the formula
    -- ----------------------------------------------
	--fnd_profile.get('USER_ID', l_user_id);
	--fnd_profile.get('RESP_ID', l_resp_id);
    --hr_utility.set_location('..User Id :'||l_user_id, 25);
	--hr_utility.set_location('..Responsibility Id :'||l_resp_id, 25);
	--fnd_global.apps_initialize(l_user_id,l_resp_id,800);
    l_request_id := fnd_request.submit_request
                     (application => 'FF'
                     ,program     => 'SINGLECOMPILE'
                     ,argument1   => fra_rec.formula_type_name --Oracle Payroll
                     ,argument2   => fra_rec.formula_name);    --formula name
    p_request_id := l_request_id;
    hr_utility.set_location('..Request Id :'||p_request_id, 25);
  end loop;
  hr_utility.set_location('Leaving: '||l_proc_name, 30);
exception
    when others then
       hr_utility.set_location('..Entering exception when others ', 80);
       hr_utility.set_location('Leaving: '||l_proc_name, 90);
       p_request_id := null; raise;
end Compile_Formula;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_scheme_prefix >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_scheme_prefix
  (p_scheme_prefix_in              in varchar2
  ) IS

element_name varchar2(100) := p_scheme_prefix_in;
l_output     varchar2(100);
l_rgeflg     varchar2(100);

begin

   hr_chkfmt.checkformat
   (
      value   => element_name,
      format  => 'PAY_NAME',
      output  => l_output,
      minimum => NULL,
      maximum => NULL,
      nullok  => 'N',
      rgeflg  => l_rgeflg,
      curcode => NULL
   );

EXCEPTION

WHEN OTHERS THEN
  fnd_message.set_name('PQP', 'PQP_230923_SCHEME_PREFIX_ERR');
  fnd_message.raise_error;

END chk_scheme_prefix;

 -- ---------------------------------------------------------------------
   -- |------------------------< Get_Object_ID >--------------------------|
   -- ---------------------------------------------------------------------
   function Get_Object_ID (p_object_type   in Varchar2,
                           p_object_name   in Varchar2,
			   p_business_group_id in Number,
			   p_template_id in Number)
   return Number is
     --
     l_object_id  Number          := null;
     l_proc_name  Varchar2(72)    := g_proc_name || 'get_object_id';
     --
     cursor c2 (c_object_name varchar2) is
           select element_type_id
             from pay_element_types_f
            where element_name      = c_object_name
              and business_group_id = p_business_group_id;
     --
     cursor c3 (c_object_name in Varchar2) is
          select ptco.core_object_id
            from  pay_shadow_balance_types psbt,
                  pay_template_core_objects ptco
           where  psbt.template_id      = p_template_id
             and  psbt.balance_name     = c_object_name
             and  ptco.template_id      = psbt.template_id
             and  ptco.shadow_object_id = psbt.balance_type_id;
     --
   begin
      hr_utility.set_location('Entering: '||l_proc_name, 10);
      --
      if p_object_type = 'ELE' then
         for c2_rec in c2 (p_object_name) loop
            l_object_id := c2_rec.element_type_id;  -- element id
         end loop;
      elsif p_object_type = 'BAL' then
         for c3_rec in c3 (p_object_name) loop
            l_object_id := c3_rec.core_object_id;   -- balance id
         end loop;
      end if;
      --
      hr_utility.set_location('Leaving: '||l_proc_name, 20);
      --
      return l_object_id;
   end Get_Object_ID;

    -- ---------------------------------------------------------------------
   -- |------------------------< Get_Formula_Id >--------------------------|
   -- ---------------------------------------------------------------------
   function Get_Formula_Id (p_formula_name      IN VARCHAR2
                           ,p_business_group_id IN NUMBER)
   return Number is

    cursor  csr_get_formula_id is
     select formula_id
       from pay_shadow_formulas
      where formula_name  = p_formula_name
        and business_group_id = p_business_group_id
        and template_type = 'U';

    l_proc_name         Varchar2(72) := g_proc_name || 'get_formula_id';
    l_formula_id        Number;
   begin
    --
    hr_utility.set_location ('Entering '||l_proc_name, 10);
    --
    open csr_get_formula_id;
    fetch csr_get_formula_id into l_formula_id;
    close csr_get_formula_id;
    --
    hr_utility.set_location ('Leaving '||l_proc_name, 20);
    --
    return l_formula_id;
   end Get_Formula_ID;

   -- ---------------------------------------------------------------------
   -- |---------------------< Create_Formula_Results >--------------------|
   -- ---------------------------------------------------------------------
   PROCEDURE Create_Formula_Results (p_scheme_prefix         IN VARCHAR2
                                    ,p_pension_category      IN VARCHAR2
                                    ,p_business_group_id     IN NUMBER
									,p_scheme_start_date     IN DATE
									,p_scheme_end_date       IN DATE)
   IS
     --This procedure creates the formula result rules for the
	 --Employer Contribution element in the case of PRSA and RAC Contributions
	 --for feeding the seeded BIK balances.

    l_er_formula_id NUMBER;
	l_rowid ROWID;
    l_er_status_proc_rule_id NUMBER;
	l_bik_er_ele_id NUMBER;
	l_er_ele_id     NUMBER;
	l_bik_er_iv NUMBER;
	l_formula_result_rule_id NUMBER;

	CURSOR c_formula_id (c_name IN VARCHAR2)
	IS
	SELECT formula_id
	FROM ff_formulas_f
	WHERE formula_name=upper(c_name)
	AND business_group_id=p_business_group_id
	AND trunc(p_scheme_start_date) BETWEEN
	    effective_start_date AND effective_end_date;


    CURSOR c_ele_id (c_name IN VARCHAR2)
	IS
	SELECT element_type_id
	FROM pay_element_types_f
	WHERE element_name = c_name
	AND trunc(p_scheme_start_date) BETWEEN
	    effective_start_date AND effective_end_date;

	CURSOR c_ip_val
     ( c_element_type_id IN NUMBER
      ,c_name            IN VARCHAR2) IS
    SELECT input_value_id
    FROM pay_input_values_f
    WHERE element_type_id = c_element_type_id
      AND trunc(p_scheme_start_date) BETWEEN
            effective_start_date AND effective_end_date
      AND name = c_name;

	CURSOR c_status_proc_id
	( c_element_type_id IN NUMBER
	  ,c_formula_id IN NUMBER	) IS
	SELECT status_processing_rule_id
    FROM pay_status_processing_rules_f
    WHERE element_type_id = c_element_type_id
	  AND formula_id = c_formula_id
      AND trunc(p_scheme_start_date) BETWEEN
            effective_start_date AND effective_end_date;

   BEGIN

     hr_utility.set_location('..In Create_Formula_Results', 51);

 	  OPEN c_formula_id (replace(p_scheme_prefix,' ','_')||'_ER_CONTRIBUTION');
  	  FETCH c_formula_id INTO l_er_formula_id;
      IF c_formula_id%NOTFOUND THEN
	   	  CLOSE c_formula_id;
		  fnd_message.raise_error;
	  ELSE
	      CLOSE c_formula_id;
      END IF;
     hr_utility.set_location('..Fetched Formula ID', 51);
 	  OPEN c_ele_id (p_scheme_prefix||' ER Contribution');
  	  FETCH c_ele_id INTO l_er_ele_id;
      IF c_ele_id%NOTFOUND THEN
	   	  CLOSE c_ele_id;
		  fnd_message.raise_error;
	  ELSE
	      CLOSE c_ele_id;
      END IF;
     hr_utility.set_location('..Fetched Element ID', 51);
	  OPEN c_status_proc_id (l_er_ele_id, l_er_formula_id);
  	  FETCH c_status_proc_id INTO l_er_status_proc_rule_id;
      IF c_status_proc_id%NOTFOUND THEN
	   	  CLOSE c_status_proc_id;
		  fnd_message.raise_error;
	  ELSE
	      CLOSE c_status_proc_id;
      END IF;

       hr_utility.set_location('..Creating Formula Result Rules for BIK', 51);
	   IF p_pension_category='PRSA' THEN
		   OPEN c_ele_id ('IE BIK PRSA ER Contribution');
  		   FETCH c_ele_id INTO l_bik_er_ele_id;
    	   IF c_ele_id%NOTFOUND THEN
		   	  CLOSE c_ele_id;
			  fnd_message.raise_error;
	       ELSE
	          CLOSE c_ele_id;
       	   END IF;

    	   OPEN c_ip_val (l_bik_er_ele_id, 'Contribution Amount');
     	   FETCH c_ip_val INTO l_bik_er_iv;
	       IF c_ip_val%NOTFOUND THEN
	         CLOSE c_ip_val;
		     fnd_message.raise_error;
	       ELSE
	         CLOSE c_ip_val;
	       END IF;

		SELECT pay_formula_result_rules_s.nextval
        INTO l_formula_result_rule_id
        FROM dual;
	     pay_formula_result_rules_pkg.insert_row
         (p_rowid                     => l_rowid
         ,p_formula_result_rule_id    => l_formula_result_rule_id
         ,p_effective_start_date      => trunc(p_scheme_start_date)
         ,p_effective_end_date        => trunc(p_scheme_end_date)
         ,p_business_group_id         => p_business_group_id
         ,p_legislation_code          => NULL
         ,p_element_type_id           => l_bik_er_ele_id
         ,p_status_processing_rule_id => l_er_status_proc_rule_id
         ,p_result_name               => 'DEDUCTION_AMT'
         ,p_result_rule_type          => 'I'
         ,p_legislation_subgroup      => NULL
         ,p_severity_level            => NULL
         ,p_input_value_id            => l_bik_er_iv
         ,p_session_date              => p_scheme_start_date
         ,p_created_by                => -1
         );
		 END IF;

		 IF p_pension_category='RAC' THEN
		 OPEN c_ele_id ('IE BIK RAC ER Contribution');
  		   FETCH c_ele_id INTO l_bik_er_ele_id;
    	   IF c_ele_id%NOTFOUND THEN
		   	  CLOSE c_ele_id;
			  fnd_message.raise_error;
	       ELSE
	          CLOSE c_ele_id;
       	   END IF;
		   OPEN c_ip_val (l_bik_er_ele_id, 'Contribution Amount');
     	   FETCH c_ip_val INTO l_bik_er_iv;
	       IF c_ip_val%NOTFOUND THEN
	         CLOSE c_ip_val;
		     fnd_message.raise_error;
	       ELSE
	         CLOSE c_ip_val;
	       END IF;

		SELECT pay_formula_result_rules_s.nextval
        INTO l_formula_result_rule_id
        FROM dual;
	     pay_formula_result_rules_pkg.insert_row
         (p_rowid                     => l_rowid
         ,p_formula_result_rule_id    => l_formula_result_rule_id
         ,p_effective_start_date      => trunc(p_scheme_start_date)
         ,p_effective_end_date        => trunc(p_scheme_end_date)
         ,p_business_group_id         => p_business_group_id
         ,p_legislation_code          => NULL
         ,p_element_type_id           => l_bik_er_ele_id
         ,p_status_processing_rule_id => l_er_status_proc_rule_id
         ,p_result_name               => 'DEDUCTION_AMT'
         ,p_result_rule_type          => 'I'
         ,p_legislation_subgroup      => NULL
         ,p_severity_level            => NULL
         ,p_input_value_id            => l_bik_er_iv
         ,p_session_date              => p_scheme_start_date
         ,p_created_by                => -1
         );
		 END IF;

   END Create_Formula_Results;

   -- ---------------------------------------------------------------------
   -- |---------------------< Update_Ipval_Defval >------------------------|
   -- ---------------------------------------------------------------------
   procedure Update_Ipval_Defval(p_ele_name  in Varchar2
                                ,p_ip_name   in Varchar2
                                ,p_def_value in Varchar2
				,p_business_group_id IN Number
				)
   is

     cursor csr_getinput(c_ele_name varchar2
                        ,c_iv_name  varchar2) is
     select input_value_id
           ,piv.name
           ,piv.element_type_id
       from pay_input_values_f  piv
           ,pay_element_types_f pet
     where  element_name           = c_ele_name
       and  piv.element_type_id    = pet.element_type_id
       and  (piv.business_group_id = p_business_group_id or
             piv.business_group_id is null)
       and  piv.name               = c_iv_name
       and  (piv.legislation_code  = 'IE' or
             piv.legislation_code is null);

     cursor csr_updinput(c_ip_id           number
                        ,c_element_type_id number) is
     select rowid
       from pay_input_values_f
      where input_value_id  = c_ip_id
        and element_type_id = c_element_type_id
     for update nowait;

     csr_getinput_rec          csr_getinput%rowtype;
     csr_updinput_rec          csr_updinput%rowtype;

     l_proc_name               Varchar2(72) := g_proc_name ||
                                'update_ipval_defval';
   --
   begin
     --
     hr_utility.set_location ('Entering '||l_proc_name, 10);
     --
     open csr_getinput(p_ele_name ,p_ip_name);
     loop
       fetch csr_getinput into csr_getinput_rec;
       exit when csr_getinput%notfound;
        --
        hr_utility.set_location (l_proc_name, 20);
        --
        open csr_updinput(csr_getinput_rec.input_value_id
                         ,csr_getinput_rec.element_type_id);
        loop
          fetch csr_updinput into csr_updinput_rec;
          exit when csr_updinput%notfound;
            --
            hr_utility.set_location (l_proc_name, 30);
            --
            update pay_input_values_f
              set default_value = p_def_value
            where rowid = csr_updinput_rec.rowid;
        end loop;
        close csr_updinput;
     end loop;
     close csr_getinput;
     --
     hr_utility.set_location ('Leaving '||l_proc_name, 40);
     --
   end Update_Ipval_Defval;

-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template >------------------------|
-- ---------------------------------------------------------------------
function Create_User_Template (
            p_pension_provider_id           In Number
           ,p_pension_type_id               In Number
           ,p_scheme_prefix                 In Varchar2
           ,p_reporting_name                In Varchar2
		   ,p_prsa2_certificate             In Varchar2
		   ,p_third_party                   In Varchar2
           ,p_termination_rule              In Varchar2
           ,p_effective_start_date          In Date      Default Null
           ,p_effective_end_date            In Date      Default Null
           ,p_security_group_id             In Number    Default Null
           ,p_business_group_id             In Number
           )
   return Number is
   --
   l_template_id                 pay_shadow_element_types.template_id%type;
   l_base_element_type_id        pay_template_core_objects.core_object_id%type;
   l_setup_element_type_id       pay_template_core_objects.core_object_id%type;
   l_er_base_element_type_id     pay_template_core_objects.core_object_id%type;
   l_ee_tax_element_type_id     pay_template_core_objects.core_object_id%type;
   l_source_template_id          pay_element_templates.template_id%type;
   l_object_version_number       pay_element_types_f.object_version_number%type;
   l_proc_name                   Varchar2(80) := g_proc_name || 'create_user_template';
   l_element_type_id             Number;
   l_balance_type_id             Number;
   l_eei_element_type_id         Number;
   l_ele_obj_ver_number          Number;
   l_bal_obj_ver_number          Number;
   i                             Number;
   l_eei_info_id                 Number;
   l_ovn_eei                     Number;
   l_formula_name                pay_shadow_formulas.formula_name%type;
   l_formula_id                  Number;
   l_formula_id1                 Number;
   y                             Number := 0;
   l_exists                      Varchar2(1);
   l_count                       Number := 0;
   l_shad_formula_id             Number;
   l_shad_formula_id1            Number;
   l_prem_replace_string         varchar2(5000) := ' ' ;
   l_std_link_flag               varchar2(10) := 'N';
   l_scheme_prefix               varchar2(50) := p_scheme_prefix;
   l_pension_category            varchar2(30);
   l_seed_ee_bal_type_id            Number;
   l_seed_er_bal_type_id            Number;
   l_seed_ee_tax_bal_type_id        Number;
   l_seed_arrear_type_id            Number;
   l_bal_name1                     varchar2(80);
   l_bal_name2                     varchar2(80);
   l_bal_name3                     varchar2(80);
   l_bal_name4                     varchar2(80);
   l_configuration_information1    Varchar2(10) := 'N';

   type shadow_ele_rec is record
         (element_type_id        pay_shadow_element_types.element_type_id%type
         ,object_version_number  pay_shadow_element_types.object_version_number%type
         ,reporting_name         pay_shadow_element_types.reporting_name%type
         ,description            pay_shadow_element_types.description%type
		 ,priority               pay_shadow_element_types.relative_processing_priority%type
		 ,third_party_pay_only_flag      pay_shadow_element_types.third_party_pay_only_flag%type
		 ,classification_name    pay_shadow_element_types.classification_name%type
         );
   type t_shadow_ele_info is table of shadow_ele_rec
   index by Binary_Integer;
   l_shadow_element              t_shadow_ele_info;

   type t_ele_name is table of pay_element_types_f.element_name%type
   index by BINARY_INTEGER;
   l_ele_name                    t_ele_name;
   l_ele_new_name                t_ele_name;
   l_main_ele_name               t_ele_name;
   l_retro_ele_name              t_ele_name;

   type t_bal_name is table of pay_balance_types.balance_name%type
   index by BINARY_INTEGER;
   l_bal_name                    t_bal_name;
   l_bal_new_name                t_bal_name;

   type t_ele_reporting_name is table of pay_element_types_f.reporting_name%type
   index by BINARY_INTEGER;
   l_ele_reporting_name          t_ele_reporting_name;

   type t_ele_description is table of pay_element_types_f.description%type
   index by BINARY_INTEGER;
   l_ele_description             t_ele_description;

   type t_ele_pp is table of pay_element_types_f.processing_priority%type
   index by BINARY_INTEGER;
   l_ele_pp                      t_ele_pp;

   type t_eei_info is table of pay_element_type_extra_info.eei_information1%type
   index by BINARY_INTEGER;
   l_main_eei_info1             t_eei_info;
   l_retro_eei_info1            t_eei_info;

   l_ele_core_id                 pay_template_core_objects.core_object_id%type:= -1;

   -- Extra Information variables
   l_eei_information1           pay_element_type_extra_info.eei_information1%type;
   l_eei_information2           pay_element_type_extra_info.eei_information2%type;
   l_ee_contribution_bal_type_id pqp_pension_types_f.ee_contribution_bal_type_id%type;
   l_er_contribution_bal_type_id pqp_pension_types_f.er_contribution_bal_type_id%type;
   l_balance_feed_Id             pay_balance_feeds_f.balance_feed_id%type;
   l_row_id                      rowid;
   l_request_id                  Number;
   l_er_request_id               Number;
   l_dbi_user_name               ff_database_items.user_name%TYPE;
   l_balance_name                pay_balance_types.balance_name%TYPE;
   l_balance_dbi_name            ff_database_items.user_name%TYPE;

   --
   cursor csr_get_category (c_pen_type_id number,
                            c_effective_date date) is
   select pension_category
   from pqp_pension_types_f
   where pension_type_id = c_pen_type_id
   and c_effective_date between effective_start_date and effective_end_date;

   cursor  csr_get_ee_bal_info  (c_bal_name varchar2) is
   select  balance_type_id
     from  pay_balance_types
    where  balance_name = c_bal_name
	and legislation_code='IE'
	and business_group_id is null;

   cursor  csr_get_ele_info (c_ele_name varchar2) is
   select  element_type_id
          ,object_version_number
     from  pay_shadow_element_types
    where  template_id    = l_template_id
      and  element_name   = c_ele_name;
   --
   cursor  csr_get_bal_info (c_bal_name varchar2) is
   select  balance_type_id
          ,object_version_number
     from  pay_shadow_balance_types
    where  template_id  = l_template_id
      and  balance_name = c_bal_name;
   --
   cursor csr_shd_ele (c_shd_elename varchar2) is
   select element_type_id, object_version_number, relative_processing_priority, third_party_pay_only_flag, classification_name
     from pay_shadow_element_types
    where template_id    = l_template_id
      and element_name   = c_shd_elename;
   --
   cursor csr_ipv  (c_ele_typeid     number
                   ,c_effective_date date) is
   select input_value_id
     from pay_input_values_f
    where element_type_id   = c_ele_typeid
      and business_group_id = p_business_group_id
      and name              = 'Pay Value'
      and c_effective_date between effective_start_date
                               and effective_end_date;
   --
   cursor csr_ipv1  (c_ele_typeid     number
                   ,c_ipv_name  varchar2
                   ,c_effective_date date) is
   select input_value_id
     from pay_input_values_f
    where element_type_id   = c_ele_typeid
      and business_group_id = p_business_group_id
      and name              = c_ipv_name
      and c_effective_date between effective_start_date
                               and effective_end_date;
   --
   cursor csr_pty  (c_pension_type_id     number
                   ,c_effective_date date) is
   select ee_contribution_bal_type_id
     from pqp_pension_types_f
    where pension_type_id   = c_pension_type_id
      and business_group_id = p_business_group_id
      and c_effective_date between effective_start_date
                               and effective_end_date;

   cursor csr_pty1  (c_pension_type_id     number
                   ,c_effective_date date) is
   select *
     from pqp_pension_types_f
    where pension_type_id   = c_pension_type_id
      and business_group_id = p_business_group_id
      and c_effective_date between effective_start_date
                               and effective_end_date;

   cursor csr_pty2  (c_pension_type_id     number
                   ,c_effective_date date) is
   select er_contribution_bal_type_id
     from pqp_pension_types_f
    where pension_type_id   = c_pension_type_id
      and business_group_id = p_business_group_id
      and c_effective_date between effective_start_date
                               and effective_end_date;

   r_pty_rec pqp_pension_types_f%ROWTYPE;


     l_scheme_dummy varchar2(10);
   -- ---------------------------------------------------------------------
   -- |------------------------< Get_Template_ID >-------------------------|
   -- ---------------------------------------------------------------------
   function Get_Template_ID (p_legislation_code in Varchar2)
     return Number is
     --
     l_template_name Varchar2(80);
     l_proc_name     Varchar2(72) := g_proc_name || 'get_template_id';
     --
     cursor csr_get_temp_id  is
     select template_id
       from pay_element_templates
      where template_name     = l_template_name
        and legislation_code  = p_legislation_code
        and template_type     = 'T'
        and business_group_id is null;

     --
   begin
      --
      hr_utility.set_location('Entering: '||l_proc_name, 10);
      --
      l_template_name  := 'Ireland Pension Deduction';
      --
      hr_utility.set_location(l_proc_name, 20);
      --
      for csr_get_temp_id_rec in csr_get_temp_id loop
         l_template_id   := csr_get_temp_id_rec.template_id;
      end loop;
      --
      hr_utility.set_location('Leaving: '||l_proc_name, 30);
      hr_utility.set_location('Template_id: '||l_template_id   , 30);
      --
      return l_template_id;
      --
   end Get_Template_ID;

  begin
  --hr_utility.trace_on('Y', 'PENSIONIE');
  -- ---------------------------------------------------------------------
  -- |-------------< Main Function : Create_User_Template Body >----------|
  -- ---------------------------------------------------------------------
   hr_utility.set_location('Entering : '||l_proc_name, 10);

   chk_scheme_prefix(p_scheme_prefix);

    -- ---------------------------------------------------------------------
   -- Set session date
   -- ---------------------------------------------------------------------
   pay_db_pay_setup.set_session_date(nvl(p_effective_start_date, sysdate));
   --
   hr_utility.set_location('..Setting the Session Date', 15);
   -- ---------------------------------------------------------------------
   -- Get Source Template ID
   -- ---------------------------------------------------------------------
   l_source_template_id := get_template_id
                            (p_legislation_code  => g_template_leg_code);
   OPEN csr_get_category (p_pension_type_id, p_effective_start_date);
   FETCH csr_get_category INTO l_pension_category;
   IF csr_get_category%NOTFOUND THEN
     fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
     fnd_message.raise_error;
   END IF;
   CLOSE csr_get_category;
   -- ---------------------------------------------------------------------
   -- Exclusion rules
   -- ---------------------------------------------------------------------
   hr_utility.set_location('..Checking all the Exclusion Rules', 20);

   -- Define the exclusion_rule for Employer Component
 IF l_pension_category <> 'RBSAVC' AND l_pension_category <> 'PRSAAVC' THEN
     l_configuration_information1 := 'Y';
  ELSE
     l_configuration_information1 := 'N';
   END IF;

   OPEN csr_pty1 (c_pension_type_id => p_pension_type_id
                 ,c_effective_date  => p_effective_start_date);
   FETCH csr_pty1 INTO r_pty_rec;

      IF csr_pty1%notfound THEN
        fnd_message.set_name('PQP', 'PQP_230805_INV_PENSIONID');
        fnd_message.raise_error;
        CLOSE csr_pty1;
      ELSE

   -- ---------------------------------------------------------------------
   -- Create user structure from the template
   -- ---------------------------------------------------------------------
   hr_utility.set_location('..Creating template User structure', 25);
   pay_element_template_api.create_user_structure
    (p_validate                      => false
    ,p_effective_date                => p_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_source_template_id            => l_source_template_id
    ,p_base_name                     => p_scheme_prefix
	,p_configuration_information1    => l_configuration_information1
    ,p_template_id                   => l_template_id
    ,p_object_version_number         => l_object_version_number
    );
   hr_utility.set_location('..Created template User structure', 25);
   -- ---------------------------------------------------------------------
   -- |-------------------< Update Shadow Structure >----------------------|
   -- ---------------------------------------------------------------------
   -- Get Element Type id and update user-specified Classification,
   -- Category, Processing Type and Standard Link on Base Element
   -- as well as other element created for the Scheme
   -- ---------------------------------------------------------------------
   -- 1. <BASE NAME> Pension Deduction
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Pension Deduction')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix||' Pension Deduction');
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Pension Deduction';
    l_shadow_element(l_count).third_party_pay_only_flag := p_third_party;
    l_shadow_element(l_count).classification_name  := csr_rec.classification_name;
    if l_pension_category = 'RBS' then
	  l_shadow_element(l_count).priority := 8300;
	end if;
    if l_pension_category = 'RBSAVC' then
	  l_shadow_element(l_count).priority := 8301;
	end if;
    if l_pension_category = 'PRSA' then
	  l_shadow_element(l_count).priority := 8302;
	end if;
    if l_pension_category = 'PRSAAVC' then
	  l_shadow_element(l_count).priority := 8303;
	end if;
    if l_pension_category = 'RAC' then
	  l_shadow_element(l_count).priority := 8304;
	end if;
   end loop;

   IF l_configuration_information1 = 'Y' THEN
   -- 2. <BASE NAME> Employer Contribution
   for csr_rec in csr_shd_ele (p_scheme_prefix||' ER Contribution')
   loop
    l_count := l_count + 1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix || ' Employer Contribution');
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Employer Contribution';
   if l_pension_category <> 'PRSA' and l_pension_category <> 'RAC' then
	l_shadow_element(l_count).classification_name := csr_rec.classification_name;
    l_shadow_element(l_count).priority              := csr_rec.relative_processing_priority;
   else
   	l_shadow_element(l_count).classification_name := 'Information';
    l_shadow_element(l_count).priority              := 500;
   end if;
    l_shadow_element(l_count).third_party_pay_only_flag := p_third_party;
   end loop;
   END IF;
   -- 3. <BASE NAME> EE Taxable Contribution
   for csr_rec in csr_shd_ele (p_scheme_prefix||' EE Taxable Contribution')
   loop
    l_count := l_count +1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix || ' EE Taxable Contribution');
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' EE Taxable Contribution';
    l_shadow_element(l_count).priority              := csr_rec.relative_processing_priority;
    l_shadow_element(l_count).third_party_pay_only_flag := p_third_party;
	l_shadow_element(l_count).classification_name := csr_rec.classification_name;
   end loop;
   -- 4. <BASE NAME> Setup
   for csr_rec in csr_shd_ele (p_scheme_prefix||' Setup')
   loop
    l_count := l_count +1;
    l_shadow_element(l_count).element_type_id       := csr_rec.element_type_id;
    l_shadow_element(l_count).object_version_number := csr_rec.object_version_number;
    l_shadow_element(l_count).reporting_name        := nvl(p_reporting_name,p_scheme_prefix || ' Setup');
    l_shadow_element(l_count).description           := 'Element for '||p_scheme_prefix
                                                       ||' Setup';
    l_shadow_element(l_count).priority              := csr_rec.relative_processing_priority;
    l_shadow_element(l_count).third_party_pay_only_flag := csr_rec.third_party_pay_only_flag;
	l_shadow_element(l_count).classification_name := csr_rec.classification_name;
   end loop;
   hr_utility.set_location('..Updating the scheme shadow elements', 30);
   for i in 1..l_count
   loop
     pay_shadow_element_api.update_shadow_element
       (p_validate               => false
       ,p_effective_date         => p_effective_start_date
       ,p_element_type_id        => l_shadow_element(i).element_type_id
       ,p_description            => l_shadow_element(i).description
       ,p_reporting_name         => l_shadow_element(i).reporting_name
       ,p_post_termination_rule  => p_termination_rule
       ,p_standard_link_flag     => l_std_link_flag
	   ,p_relative_processing_priority => l_shadow_element(i).priority
       ,p_object_version_number  => l_shadow_element(i).object_version_number
	   ,p_third_party_pay_only_flag => l_shadow_element(i).third_party_pay_only_flag
	   ,p_classification_name    => l_shadow_element(i).classification_name
       );
   end loop;
   hr_utility.set_location('..After Updating the scheme shadow elements', 50);

   -- Replace the spaces in the prefix with underscores. The formula name
   -- has underscores if the prefix name has spaces in it .
   l_scheme_prefix := upper(replace(l_scheme_prefix,' ','_'));


   hr_utility.set_location('..Updated Shadow element', 25);

   -- ---------------------------------------------------------------------
   -- |-------------------< Generate Core Objects >------------------------|
   -- ---------------------------------------------------------------------
   pay_element_template_api.generate_part1
    (p_validate         => false
    ,p_effective_date   => p_effective_start_date
    ,p_hr_only          => false
    ,p_hr_to_payroll    => false
    ,p_template_id      => l_template_id);
   --
   hr_utility.set_location('After Generating Core objects : Part - 1', 50);
   --
   pay_element_template_api.generate_part2
    (p_validate         => false
    ,p_effective_date   => p_effective_start_date
    ,p_template_id      => l_template_id);
   --
   hr_utility.set_location('After Generating Core objects : Part - 2', 50);

   -- Update some of the input values on the main element

   Update_Ipval_Defval(  p_scheme_prefix||' Pension Deduction'
                       ,'Pension Category'
                       ,l_pension_category
		       ,p_business_group_id);


   Update_Ipval_Defval(  p_scheme_prefix||' Pension Deduction'
                       ,'PRSA2 Certificate'
                       ,p_prsa2_certificate
		       ,p_business_group_id);

   Update_Ipval_Defval(  p_scheme_prefix||' Pension Deduction'
                       ,'Pension Type ID'
                       ,p_pension_type_id
		       ,p_business_group_id);

   Update_Ipval_Defval(  p_scheme_prefix||' EE Taxable Contribution'
                          ,'Contribution Amount'
                          ,fnd_number.number_to_canonical(0)
			  ,p_business_group_id);
   Update_Ipval_Defval(  p_scheme_prefix||' EE Taxable Contribution'
                          ,'Excess Contribution Amount'
                          ,fnd_number.number_to_canonical(0)
			  ,p_business_group_id);
   Update_Ipval_Defval(  p_scheme_prefix||' Setup'
                          ,'EE Pension Deduction'
                          ,fnd_number.number_to_canonical(0)
			  ,p_business_group_id);
   IF l_configuration_information1 = 'Y' THEN
     Update_Ipval_Defval(  p_scheme_prefix||' ER Contribution'
                          ,'Pension Type ID'
                          ,p_pension_type_id
			  ,p_business_group_id);
     Update_Ipval_Defval(  p_scheme_prefix||' Setup'
                          ,'ER Contribution'
                          ,fnd_number.number_to_canonical(0)
			  ,p_business_group_id);
   END IF;
   Update_Ipval_Defval(  p_scheme_prefix||' Setup'
                          ,'EE Taxable Contribution'
                          ,fnd_number.number_to_canonical(0)
			  ,p_business_group_id);
   Update_Ipval_Defval(  p_scheme_prefix||' Setup'
                          ,'EE Arrears'
                          ,fnd_number.number_to_canonical(0)
			  ,p_business_group_id);

   -- ------------------------------------------------------------------------
   -- Create a row in pay_element_extra_info with all the element information
   -- ------------------------------------------------------------------------
   l_base_element_type_id := get_object_id ('ELE',
                                             p_scheme_prefix||' Pension Deduction',
					     p_business_group_id,
					     l_template_id);
   IF l_configuration_information1 = 'Y' THEN
   l_er_base_element_type_id := get_object_id ('ELE',
                                                p_scheme_prefix||' ER Contribution',
						p_business_group_id,
						l_template_id);
   END IF;
    l_ee_tax_element_type_id   :=  get_object_id ('ELE',
                                                p_scheme_prefix||' EE Taxable Contribution',
						p_business_group_id,
						l_template_id);
     l_setup_element_type_id   :=  get_object_id ('ELE',
                                                p_scheme_prefix||' Setup',
						p_business_group_id,
						l_template_id);
   pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id          => l_base_element_type_id
     ,p_information_type         => 'IE_PENSION_SCHEME_INFO'
     ,p_eei_information_category => 'IE_PENSION_SCHEME_INFO'
     ,p_eei_information1         => to_char(p_pension_type_id)
     ,p_eei_information2         => to_char(p_pension_provider_id)
	 ,p_eei_information3         => p_scheme_prefix
     ,p_eei_information4         => p_reporting_name
     ,p_eei_information5         => fnd_date.date_to_canonical(p_effective_start_date)
     ,p_eei_information6         => p_prsa2_certificate
     ,p_eei_information7         => p_termination_rule
     ,p_eei_information8         => p_third_party
     ,p_eei_information9         => null
     ,p_eei_information10        => null
     ,p_eei_information11        => null
     ,p_eei_information12        => null
     ,p_eei_information13        => null
     ,p_eei_information14        => null
     ,p_eei_information15        => null
     ,p_eei_information16        => null
     ,p_eei_information17        => null
     ,p_eei_information18        => null
     ,p_eei_information19        => null
     ,p_eei_information20        => null
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_number      => l_ovn_eei);
   IF l_configuration_information1 = 'Y' THEN
	  pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id          => l_er_base_element_type_id
     ,p_information_type         => 'IE_PENSION_SCHEME_INFO'
     ,p_eei_information_category => 'IE_PENSION_SCHEME_INFO'
     ,p_eei_information1         => to_char(p_pension_type_id)
     ,p_eei_information2         => to_char(p_pension_provider_id)
	 ,p_eei_information3         => p_scheme_prefix
     ,p_eei_information4         => p_reporting_name
     ,p_eei_information5         => fnd_date.date_to_canonical(p_effective_start_date)
     ,p_eei_information6         => p_prsa2_certificate
     ,p_eei_information7         => p_termination_rule
     ,p_eei_information8         => p_third_party
     ,p_eei_information9         => null
     ,p_eei_information10        => null
     ,p_eei_information11        => null
     ,p_eei_information12        => null
     ,p_eei_information13        => null
     ,p_eei_information14        => null
     ,p_eei_information15        => null
     ,p_eei_information16        => null
     ,p_eei_information17        => null
     ,p_eei_information18        => null
     ,p_eei_information19        => null
     ,p_eei_information20        => null
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_number      => l_ovn_eei);
   END IF;
	  pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id          => l_ee_tax_element_type_id
     ,p_information_type         => 'IE_PENSION_SCHEME_INFO'
     ,p_eei_information_category => 'IE_PENSION_SCHEME_INFO'
     ,p_eei_information1         => to_char(p_pension_type_id)
     ,p_eei_information2         => to_char(p_pension_provider_id)
     ,p_eei_information3         => p_scheme_prefix
     ,p_eei_information4         => p_reporting_name
     ,p_eei_information5         => fnd_date.date_to_canonical(p_effective_start_date)
     ,p_eei_information6         => p_prsa2_certificate
     ,p_eei_information7         => p_termination_rule
     ,p_eei_information8         => p_third_party
     ,p_eei_information9         => null
     ,p_eei_information10        => null
     ,p_eei_information11        => null
     ,p_eei_information12        => null
     ,p_eei_information13        => null
     ,p_eei_information14        => null
     ,p_eei_information15        => null
     ,p_eei_information16        => null
     ,p_eei_information17        => null
     ,p_eei_information18        => null
     ,p_eei_information19        => null
     ,p_eei_information20        => null
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_number      => l_ovn_eei);

   hr_utility.set_location('..After Creating element extra information', 50);

   -- ---------------------------------------------------------------------
   -- The base element's Pay Value should feed the EE Contribution balance
   -- for the pension scheme created.
   -- ---------------------------------------------------------------------
   IF l_pension_category='RBS' THEN
     l_bal_name1 := 'IE RBS EE Contribution';
	 l_bal_name2 := 'IE RBS ER Contribution';
   END IF;
   IF l_pension_category='PRSA' THEN
     l_bal_name1 := 'IE PRSA EE Contribution';
	 l_bal_name2 := 'IE PRSA ER Contribution';
   END IF;
   IF l_pension_category='RAC' THEN
     l_bal_name1 := 'IE RAC EE Contribution';
	 l_bal_name2 := 'IE RAC ER Contribution';
   END IF;
   IF l_pension_category='RBSAVC' THEN
     l_bal_name1 := 'IE RBS EE AVC Contribution';
	 l_bal_name2 := ' ';
  END IF;
   IF l_pension_category='PRSAAVC' THEN
     l_bal_name1 := 'IE PRSA EE AVC Contribution';
	 l_bal_name2 := ' ';
   END IF;

   OPEN csr_get_ee_bal_info  (l_bal_name1);
   FETCH csr_get_ee_bal_info INTO l_seed_ee_bal_type_id;
   IF csr_get_ee_bal_info%NOTFOUND THEN
      fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
      fnd_message.raise_error;
	  CLOSE csr_get_ee_bal_info;
   END IF;
   CLOSE csr_get_ee_bal_info;
   IF l_pension_category <> 'RBSAVC' AND l_pension_category <> 'PRSAAVC' THEN
     OPEN csr_get_ee_bal_info  (l_bal_name2);
     FETCH csr_get_ee_bal_info INTO l_seed_er_bal_type_id;
     IF csr_get_ee_bal_info%NOTFOUND THEN
      fnd_message.set_name('PQP', 'PQP_230805_BAL_NOTFOUND');
      fnd_message.raise_error;
	  CLOSE csr_get_ee_bal_info;
     END IF;
     CLOSE csr_get_ee_bal_info;
   END IF;

   for ipv_rec in csr_ipv
                   (c_ele_typeid     => l_base_element_type_id
                   ,c_effective_date => p_effective_start_date )
   loop

         Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => null,
          X_Balance_Type_Id      => l_seed_ee_bal_type_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := null;
          l_row_id          := null;

   end loop;
   for ipv_rec in csr_ipv1
                   (c_ele_typeid     => l_setup_element_type_id
				   ,c_ipv_name       => 'EE Pension Deduction'
                   ,c_effective_date => p_effective_start_date )
   loop

         Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => null,
          X_Balance_Type_Id      => l_seed_ee_bal_type_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := null;
          l_row_id          := null;

   end loop;

   hr_utility.set_location('..After creating the balance feed for the base, Pay Value', 50);

   -- ---------------------------------------------------------------------
   -- The ER base element's Pay Value should feed the ER Contribution balance
   -- for the pension scheme created.
   -- ---------------------------------------------------------------------
   IF l_pension_category <> 'RBSAVC' AND l_pension_category <> 'PRSAAVC' THEN
   for ipv_rec in csr_ipv
                   (c_ele_typeid     => l_er_base_element_type_id
                   ,c_effective_date => p_effective_start_date )
   loop
         Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => null,
          X_Balance_Type_Id      => l_seed_er_bal_type_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := null;
          l_row_id          := null;
   end loop;

   for ipv_rec in csr_ipv1
                   (c_ele_typeid     => l_setup_element_type_id
   				   ,c_ipv_name       => 'ER Contribution'
                   ,c_effective_date => p_effective_start_date )
   loop
         Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_start_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => null,
          X_Balance_Type_Id      => l_seed_er_bal_type_id,
          X_Input_Value_Id       => ipv_rec.input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := null;
          l_row_id          := null;
   end loop;
   END IF;
  hr_utility.set_location('..After creating the balance feed for the ER base, Pay Value', 51);

   -- ---------------------------------------------------------------------
   -- Compile the base element's standard formula
   -- ---------------------------------------------------------------------

      Compile_Formula
        (p_element_type_id       => l_base_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_request_id
         );
     Compile_Formula
        (p_element_type_id       => l_ee_tax_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_request_id
         );

   IF l_pension_category <> 'RBSAVC' AND l_pension_category <> 'PRSAAVC' THEN

      Compile_Formula
        (p_element_type_id       => l_er_base_element_type_id
        ,p_effective_start_date  => p_effective_start_date
        ,p_scheme_prefix         => l_scheme_prefix
        ,p_business_group_id     => p_business_group_id
        ,p_request_id            => l_er_request_id
         );

   END IF;

  IF l_pension_category='PRSA' OR l_pension_category='RAC' THEN
   Create_Formula_Results (p_scheme_prefix
                          ,l_pension_category
                          ,p_business_group_id
   						  ,p_effective_start_date
  						  ,p_effective_end_date);
  END IF;

 hr_utility.set_location('..After creating the formula result rules', 51);
END IF;


 return l_base_element_type_id;

end Create_User_Template;


-- ---------------------------------------------------------------------
-- |--------------------< Create_User_Template_Swi >------------------------|
-- ---------------------------------------------------------------------

function Create_User_Template_Swi
           (p_pension_provider_id           In Number
           ,p_pension_type_id               In Number
           ,p_scheme_prefix                 In Varchar2
           ,p_reporting_name                In Varchar2
    	   ,p_prsa2_certificate             In Varchar2
	       ,p_third_party                   In Varchar2
           ,p_termination_rule              In Varchar2
           ,p_effective_start_date          In Date      Default Null
           ,p_effective_end_date            In Date      Default Null
           ,p_security_group_id             In Number    Default Null
           ,p_business_group_id             In Number
           )
   return Number is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_element_type_id      number;
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'Create_User_Template_Swi';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  l_element_type_id    :=    -1;
  --
  -- Issue a savepoint
  --
  savepoint Create_User_Template_Swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
   l_element_type_id   :=  Create_User_Template
           (p_pension_provider_id           =>p_pension_provider_id
           ,p_pension_type_id               =>p_pension_type_id
           ,p_scheme_prefix                 =>p_scheme_prefix
           ,p_reporting_name                =>p_reporting_name
	       ,p_prsa2_certificate             =>p_prsa2_certificate
	       ,p_third_party                   =>p_third_party
           ,p_termination_rule              =>p_termination_rule
           ,p_effective_start_date          =>p_effective_start_date
           ,p_effective_end_date            =>p_effective_end_date
           ,p_security_group_id             =>p_security_group_id
           ,p_business_group_id             =>p_business_group_id
           );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  return l_element_type_id;

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to Create_User_Template_Swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    return l_element_type_id;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to Create_User_Template_Swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    return l_element_type_id;
    hr_utility.set_location(' Leaving:' || l_proc,50);


END create_user_template_swi;


-- ---------------------------------------------------------------------
-- |--------------------< Delete_User_Template >------------------------|
-- ---------------------------------------------------------------------
procedure Delete_User_Template
            (p_business_group_id            In Number
           ,p_pension_dedn_ele_name        In Varchar2
           ,p_pension_dedn_ele_type_id     In Number
           ,p_security_group_id            In Number
           ,p_effective_date               In Date
           ) is
  --
  cursor c1 is
   select template_id
     from pay_element_templates
    where base_name||' Pension Deduction'  = p_pension_dedn_ele_name
      and business_group_id = p_business_group_id
      and template_type     = 'U';

    CURSOR csr_ele_extra_info IS
    SELECT element_type_extra_info_id
          ,object_version_number
      FROM pay_element_type_extra_info
     WHERE eei_information_category = 'IE_PENSION_SCHEME_INFO'
       AND element_type_id = p_pension_dedn_ele_type_id;

  l_template_id   Number(9);
  l_proc          Varchar2(60) := g_proc_name||'Delete_User_Template';

begin
   hr_utility.set_location('Entering :'||l_proc, 10);
   --
   for c1_rec in c1 loop
       l_template_id := c1_rec.template_id;
   end loop;
   --
   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   --
   -- Delete the rows in pay_element_type_extra_info
   --

   FOR temp_rec IN csr_ele_extra_info
     LOOP
       pay_element_extra_info_api.delete_element_extra_info
       (p_element_type_extra_info_id => temp_rec.element_type_extra_info_id
       ,p_object_version_number      => temp_rec.object_version_number);
     END LOOP;

   hr_utility.set_location('Leaving :'||l_proc, 50);

end Delete_User_Template;
--

-- ---------------------------------------------------------------------
-- |------------------< Delete_User_Template_Swi >----------------------|
-- ---------------------------------------------------------------------

procedure Delete_User_Template_Swi
            (p_business_group_id            In Number
           ,p_pension_dedn_ele_name        In Varchar2
           ,p_pension_dedn_ele_type_id     In Number
           ,p_security_group_id            In Number
           ,p_effective_date               In Date
           ) is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'Delete_User_Template_Swi';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint Delete_User_Template_Swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
   Delete_User_Template
           (p_business_group_id         =>   p_business_group_id
           ,p_pension_dedn_ele_name     =>   p_pension_dedn_ele_name
           ,p_pension_dedn_ele_type_id  =>   p_pension_dedn_ele_type_id
           ,p_security_group_id         =>   p_security_group_id
           ,p_effective_date            =>   p_effective_date
           );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to Delete_User_Template_Swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to Delete_User_Template_Swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END delete_user_template_swi;

--

end pay_ie_pension_template;

/
