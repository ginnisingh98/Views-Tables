--------------------------------------------------------
--  DDL for Package Body PAY_NL_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_RULES" as
/* $Header: pynlrule.pkb 120.3.12000000.3 2007/07/26 04:58:45 grchandr noship $ */
--
g_package varchar2(30) := 'pay_nl_rules';

-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
--
---------------------------------------------------------------------------
-- Procedure: get_override_ctx_value
-- Procedure returns current system effective date in canonical format
---------------------------------------------------------------------------
PROCEDURE  get_override_ctx_value (p_retro_asg_action_id   IN     Number,
                                   p_run_asg_action_id     IN     Number,
                                   p_element_type_id       IN     Number,
                                   p_retro_component_id    IN     Number,
                                   p_override_date         IN OUT NOCOPY varchar2)

IS

Cursor c_date(p_retro_asg_action_id Number)
is
select fnd_date.DATE_TO_CANONICAL(ppa.effective_date)
from pay_payroll_actions ppa,
pay_assignment_actions paa
where paa.assignment_action_id=p_retro_asg_action_id
and ppa.payroll_action_id=paa.payroll_action_id ;

l_override_date varchar2(30);




Begin

Open c_date(p_retro_asg_action_id);
Fetch c_date into l_override_date ;
Close c_date;

p_override_date:=l_override_date;

End get_override_ctx_value;

PROCEDURE get_retro_component_id (p_ee_id IN Number,
                                  p_element_type_id IN Number default -1,
                                  p_retro_component_id IN OUT NOCOPY Number)

is
cursor c_standard_component(cp_element_type_id in number)
is
select prc.retro_component_id
from
pay_retro_components prc,
pay_retro_component_usages prcu
where
prcu.creator_id=cp_element_type_id
and prc.retro_component_id=prcu.retro_component_id
and prc.legislation_code='NL'
and prc.component_name in ('Correction','Adjustment')
and prcu.default_component = 'Y';

cursor c_replacement_component(cp_element_type_id in number)
is
select prc.retro_component_id
from
pay_retro_components prc,
pay_retro_component_usages prcu
where
prcu.creator_id=cp_element_type_id
and prc.retro_component_id=prcu.retro_component_id
and prc.legislation_code='NL'
and prc.component_name='Replacement';

Cursor c_retro_method(p_business_group_id in number)
is
    Select hoi.org_information2
    from    hr_organization_information hoi
    where  hoi.org_information_context = 'NL_BG_INFO'
    and     hoi.organization_id         = p_business_group_id;


cursor c_bg_id(p_ee_id in number)
is
select distinct paa.business_group_id
from per_all_assignments_f paa
,pay_element_entries_f pee
where  pee.element_entry_id=p_ee_id
and pee.assignment_id=paa.assignment_id;


l_return_date  date;
l_period_date date;
l_retro_method varchar2(10);
l_business_group_id number;

Begin

Open c_bg_id(p_ee_id);
Fetch c_bg_id into l_business_group_id;
Close c_bg_id;

Open c_retro_method(l_business_group_id);
Fetch c_retro_method  into l_retro_method;
Close c_retro_method;

if (l_retro_method ='Y')   /* or if the BG wants to override the replacement method to standard*/
then

  OPEN c_standard_component(p_element_type_id);
  FETCH c_standard_component into p_retro_component_id;
  CLOSE c_standard_component;

Else

  OPEN  c_replacement_component(p_element_type_id);
  FETCH c_replacement_component into p_retro_component_id;
  CLOSE c_replacement_component;


end if;

end get_retro_component_id;


---------------------------------------------------------------------------
-- Procedure : get_asg_process_group
-- This procedure gives the process group name for an assignment
---------------------------------------------------------------------------
Procedure get_asg_process_group(p_assignment_id		IN  Number,
                                p_effective_start_date	IN  Date,
                                p_effective_end_date	IN  Date,
                                p_process_group_name	OUT NOCOPY Varchar2) IS

    CURSOR csr_asg_process_group IS
    SELECT DECODE(pay_nl_rules.get_object_group_type
                 ,'EMPLOYER'
                 ,prl_information1
                 ,substr(pap.payroll_name,1,30))
    FROM   per_all_assignments_f    paa
          ,pay_all_payrolls_f       pap
    WHERE  paa.assignment_id        = p_assignment_id
    AND    paa.payroll_id           = pap.payroll_id
    AND    paa.effective_start_date <= p_effective_end_date
    AND    paa.effective_end_date   >= p_effective_start_date
    AND    pap.effective_start_date <= p_effective_end_date
    AND    pap.effective_end_date   >= p_effective_start_date
    ORDER BY paa.effective_end_date DESC ,pap.effective_end_date DESC;
    --
Begin
    --
    open  csr_asg_process_group;
    fetch csr_asg_process_group into p_process_group_name;
    close csr_asg_process_group;
    --
End  get_asg_process_group ;

---------------------------------------------------------------------------
-- Procedure : get_main_tax_unit_id
-- This procedure gives the tax unit id for an assignment
---------------------------------------------------------------------------
PROCEDURE get_main_tax_unit_id(p_assignment_id   IN     NUMBER,
                               p_effective_date  IN     DATE,
                               p_tax_unit_id     IN OUT NOCOPY NUMBER) IS
    --
CURSOR cur_tax_unit_id IS
	select NVL(asg.establishment_id,prl_information1) from
 	       per_all_assignments_f asg,
	       pay_all_payrolls_f pap
	where  assignment_id = p_assignment_id
	       and asg.payroll_id = pap.payroll_id
	       and p_effective_date between asg.effective_start_date and asg.effective_end_date
	       and p_effective_date between pap.effective_start_date and pap.effective_end_date;
    --
 BEGIN
    --
        open  cur_tax_unit_id;
        fetch cur_tax_unit_id into p_tax_unit_id;
        close cur_tax_unit_id;
    --
END get_main_tax_unit_id;
--
---------------------------------------------------------------------------
-- Function : get_object_group_type
-- This Function returns the type, the object group is based on
-- 'PAYROLL' if based on payroll_id
-- 'EMPLOYER' if based on HR Organization
---------------------------------------------------------------------------
FUNCTION get_object_group_type RETURN VARCHAR2 IS
--
    CURSOR get_type IS
    SELECT org_information6
    FROM  hr_organization_information
    WHERE organization_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
    AND   org_information_context = 'NL_BG_INFO';
    --
    l_type  VARCHAR2(20);
    --
BEGIN
    --
    OPEN get_type;
    FETCH get_type INTO l_type;
    CLOSE get_type;
    --
    RETURN NVL(l_type,'PAYROLL');
    --
    --RETURN 'PAYROLL' ;
    --RETURN 'EMPLOYER' ;
END get_object_group_type;

end PAY_NL_RULES;

/
