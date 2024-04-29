--------------------------------------------------------
--  DDL for Package Body HR_DE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_GENERAL" AS
/* $Header: pedegenr.pkb 115.17 2003/02/24 16:02:03 rmakhija noship $ */
--
FUNCTION get_three_digit_code(p_legislation_code in varchar2)
RETURN varchar2 is
        cursor csr_three_digit_code (l_legislation_code in varchar2) is
        select uci.value
        from pay_user_column_instances_f uci, pay_user_rows_f ur,
        pay_user_tables ut
        where ut.user_table_name = 'HR_DE_COUNTRY_CODE'
        and ur.row_low_range_or_name = l_legislation_code
        and ur.user_table_id = ut.user_table_id
        and ur.user_row_id = uci.user_row_id;

        l_three_digit_code pay_user_column_instances_f.value%type;
BEGIN
        open csr_three_digit_code(p_legislation_code);
        fetch csr_three_digit_code into l_three_digit_code;
        if csr_three_digit_code%found then
        return (l_three_digit_code);
	else
	return null;
        end if;
        close csr_three_digit_code;
--
EXCEPTION
	when no_data_found then
	null;
END get_three_digit_code;
--
PROCEDURE get_social_insurance_globals(
					p_business_group_id              in  number
				       ,p_effective_date                in  date
				       ,o_hlth_ins_contrib_insig_pct    out nocopy number
				       ,o_pens_ins_contrib_insig_pct    out nocopy number
				       ,o_spcl_care_ins_pct             out nocopy number
                                       ,o_pens_ins_pect                 out nocopy number
                                       ,o_unemp_ins_pect                out nocopy number
                                       ,o_hlth_ins_mon_gross_contrib    out nocopy number
                                       ,o_pens_ins_mon_gross_contrib_w  out nocopy number
                                       ,o_pens_ins_mon_gross_contrib_e  out nocopy number
                                       ,o_minr_ins_mon_gross_contrib_w  out nocopy number
                                       ,o_minr_ins_mon_gross_contrib_e  out nocopy number
                                       ,o_hlth_ins_contrib_insigph_pct  out nocopy number
                                       ,o_pens_ins_contrib_insigph_pct  out nocopy number
                                       ,o_tax_contrib_insig_pct         out nocopy number
                                       ,o_tax_contrib_insigph_pct       out nocopy number
                                       ,o_pvt_hlth_ins_min_mon_gross    out nocopy number
										)
is

Begin

	Begin
	       o_hlth_ins_contrib_insig_pct  := hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'HI_C_INSIG_P'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_hlth_ins_contrib_insig_pct := null;
	End;

	Begin

	       o_pens_ins_contrib_insig_pct  :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'PI_C_INSIG_P'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_pens_ins_contrib_insig_pct := null;
	End;


	Begin
               o_spcl_care_ins_pct           :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'SCI_P'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_pens_ins_contrib_insig_pct := null;
	End;



	Begin
               o_pens_ins_pect               :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'PI_P'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_pens_ins_pect := null;
	End;


	Begin
               o_unemp_ins_pect              :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'UI_P'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_pens_ins_pect := null;
	End;


	Begin
	       o_hlth_ins_mon_gross_contrib  :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'HI_MG_L'
									,p_effective_date => p_effective_date);

         Exception
		When NO_DATA_FOUND THEN
		o_hlth_ins_mon_gross_contrib := null;
	End;

	Begin
               o_pens_ins_mon_gross_contrib_w  :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'PI_MG_L_W'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_hlth_ins_mon_gross_contrib := null;
	End;


        Begin
		o_pens_ins_mon_gross_contrib_e  :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'PI_MG_L_E'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_pens_ins_mon_gross_contrib_e := null;
	End;

	Begin
	       o_minr_ins_mon_gross_contrib_w  :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'MI_MG_L_W'
									,p_effective_date => p_effective_date);
	Exception
		When NO_DATA_FOUND THEN
		o_minr_ins_mon_gross_contrib_w := null;
	End;


	Begin
               o_minr_ins_mon_gross_contrib_e  :=  hruserdt.get_table_value(
									 p_bus_group_id => p_business_group_id
									,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
									,p_col_name     => 'Value'
									,p_row_value     => 'MI_MG_L_E'
									,p_effective_date => p_effective_date);

        Exception
		When NO_DATA_FOUND THEN
		o_minr_ins_mon_gross_contrib_e := null;
	End;
        --

      Begin
             o_hlth_ins_contrib_insigph_pct  := hruserdt.get_table_value(
                                                                       p_bus_group_id => p_business_group_id
                                                                      ,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
                                                                      ,p_col_name     => 'Value'
                                                                      ,p_row_value     => 'HI_C_INSIGPH_P'
                                                                      ,p_effective_date => p_effective_date);
      Exception
              When NO_DATA_FOUND THEN
              o_hlth_ins_contrib_insigph_pct := null;
      End;

      Begin
             o_pens_ins_contrib_insigph_pct  := hruserdt.get_table_value(
                                                                       p_bus_group_id => p_business_group_id
                                                                      ,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
                                                                      ,p_col_name     => 'Value'
                                                                      ,p_row_value     => 'PI_C_INSIGPH_P'
                                                                      ,p_effective_date => p_effective_date);
      Exception
              When NO_DATA_FOUND THEN
              o_pens_ins_contrib_insigph_pct := null;
      End;

      Begin
             o_tax_contrib_insig_pct         := hruserdt.get_table_value(
                                                                       p_bus_group_id => p_business_group_id
                                                                      ,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
                                                                      ,p_col_name     => 'Value'
                                                                      ,p_row_value     => 'TAX_C_INSIG_P'
                                                                      ,p_effective_date => p_effective_date);
      Exception
              When NO_DATA_FOUND THEN
              o_tax_contrib_insig_pct        := null;
      End;

      Begin
             o_tax_contrib_insigph_pct       := hruserdt.get_table_value(
                                                                       p_bus_group_id => p_business_group_id
                                                                      ,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
                                                                      ,p_col_name     => 'Value'
                                                                    ,p_row_value     => 'TAX_C_INSIGPH_P'
                                                                      ,p_effective_date => p_effective_date);
      Exception
              When NO_DATA_FOUND THEN
              o_tax_contrib_insigph_pct      := null;
      End;

      Begin
             o_pvt_hlth_ins_min_mon_gross    := hruserdt.get_table_value(
                                                                       p_bus_group_id => p_business_group_id
                                                                      ,p_table_name   => 'HR_DE_SOC_INS_CONSTANTS'
                                                                      ,p_col_name     => 'Value'
                                                                      ,p_row_value     => 'PI_ELIG_MG_MIN'
                                                                      ,p_effective_date => p_effective_date);
      Exception
              When NO_DATA_FOUND THEN
              o_pvt_hlth_ins_min_mon_gross   := null;
      End;


      Exception
        	WHEN OTHERS THEN
 			o_hlth_ins_contrib_insig_pct   := null;
		        o_pens_ins_contrib_insig_pct   := null;
		        o_spcl_care_ins_pct            := null;
                        o_pens_ins_pect                := null;
                        o_unemp_ins_pect               := null;
                        o_hlth_ins_mon_gross_contrib   := null;
                        o_pens_ins_mon_gross_contrib_w := null;
                        o_pens_ins_mon_gross_contrib_e := null;
                        o_minr_ins_mon_gross_contrib_w := null;
                        o_minr_ins_mon_gross_contrib_e := null;
                        o_hlth_ins_contrib_insigph_pct := null;
                        o_pens_ins_contrib_insigph_pct := null;
                        o_tax_contrib_insig_pct        := null;
                        o_tax_contrib_insigph_pct      := null;
                        o_pvt_hlth_ins_min_mon_gross   := null;

End  get_social_insurance_globals;

Function business_group_currency
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type is

    v_currency_code  fnd_currencies.currency_code%type;

    cursor currency_code
      (c_business_group_id  hr_organization_units.business_group_id%type) is
    select fcu.currency_code
    from   hr_organization_information hoi,
           hr_organization_units hou,
           fnd_currencies fcu
    where  hou.business_group_id       = c_business_group_id
    and    hou.organization_id         = hoi.organization_id
    and    hoi.org_information_context = 'Business Group Information'
    and    fcu.issuing_territory_code  = hoi.org_information9;

begin
  open currency_code (p_business_group_id);
  fetch currency_code into v_currency_code;
  close currency_code;

  return v_currency_code;
end business_group_currency;

--
--
function get_tax_office_details (p_organization_id in integer) return varchar2 is

tax_office_number varchar2(4);
tax_office_name   varchar2(240);

BEGIN
-- no checks on date_from and to are required as we want to retieve the name of the tax office even
-- if it is no longer in use.

  If p_organization_id is null THEN
     return null;
  END IF;

  select tax_info.org_information1,
	 org.name
    into tax_office_number,
	 tax_office_name
  from   hr_organization_information tax_info ,
	 hr_organization_units org
  where  tax_info.organization_id = org.organization_id
    and  tax_info.organization_id = p_organization_id
    and  TAX_INFO.org_information_context = 'DE_TAX_OFFICE_INFO';

  Return tax_office_number || tax_office_name;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    return null;
END;
 --
 --
 -- Function to return a value from a user table i.e. a user column instance.
 --
 FUNCTION get_uci
 (p_effective_date   DATE
 ,p_user_table_id    NUMBER
 ,p_user_row_id      NUMBER
 ,p_user_column_name VARCHAR2) RETURN VARCHAR2 IS
   --
   CURSOR c_uci_value
     (p_effective_date   DATE
     ,p_user_table_id    NUMBER
     ,p_user_row_id      NUMBER
     ,p_user_column_name VARCHAR2) IS
     SELECT value
     FROM   pay_user_column_instances_f uci
           ,pay_user_columns            uc
     WHERE  uc.user_table_id    = p_user_table_id
       AND  uc.user_column_name = p_user_column_name
       AND  uci.user_row_id     = p_user_row_id
       AND  uci.user_column_id  = uc.user_column_id
       AND  p_effective_date    BETWEEN uci.effective_start_date
                                    AND uci.effective_end_date;
   --
   l_uci_value pay_user_column_instances_f.value%TYPE := NULL;
 BEGIN
   --
   OPEN c_uci_value
     (p_effective_date   => p_effective_date
     ,p_user_table_id    => p_user_table_id
     ,p_user_row_id      => p_user_row_id
     ,p_user_column_name => p_user_column_name);
   FETCH c_uci_value INTO l_uci_value;
   CLOSE c_uci_value;
   --
   RETURN l_uci_value;
 END get_uci;

function get_org_name (p_org_id in number)  return varchar2  is
p_org_name_out varchar2(240);
begin

  select name into p_org_name_out
  from hr_all_organization_units
  where organization_id = p_org_id;

  return p_org_name_out;

  EXCEPTION
  When no_data_found then return
     null;

end get_org_name;

function max_tax_info_date (p_element_entry_id in varchar2) return date is
l_max_effective_start_date date;

begin

  IF p_element_entry_id is null THEN
     return null;
  END IF;

  select max(effective_start_date)
  into l_max_effective_start_date
  from pay_element_entries_f
  where element_entry_id = p_element_entry_id;

  return  l_max_effective_start_date;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    return null;

end max_tax_info_date;
--
FUNCTION get_end_reason_no(p_end_reason_id in number)
RETURN number is
CURSOR c1(p_end_reason_id in number) IS
SELECT end_reason_number FROM pqh_de_ins_end_reasons
WHERE ins_end_reason_id = p_end_reason_id;
l_end_reason_no PQH_DE_INS_END_REASONS.END_REASON_NUMBER%TYPE;
--
BEGIN
  OPEN c1(p_end_reason_id);
  FETCH c1 INTO l_end_reason_no ;
  IF c1%FOUND THEN
     return (l_end_reason_no);
     else return(null);
  End if;
  Close c1;
--
END get_end_reason_no;
--
--
FUNCTION get_end_reason_desc(p_end_reason_id in number)
RETURN varchar2 is
CURSOR c1(p_end_reason_id in number) IS
SELECT end_reason_description FROM pqh_de_ins_end_reasons
WHERE ins_end_reason_id = p_end_reason_id;
l_end_reason_desc PQH_DE_INS_END_REASONS.END_REASON_DESCRIPTION%TYPE;
--
BEGIN
   OPEN c1(p_end_reason_id);
   FETCH c1 INTO l_end_reason_desc;
   IF c1%FOUND then
        return (l_end_reason_desc);
        else return(null);
   End IF;
   Close c1;
--
END get_end_reason_desc;
--

END hr_de_general;

/
