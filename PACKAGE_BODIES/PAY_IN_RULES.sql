--------------------------------------------------------
--  DDL for Package Body PAY_IN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_RULES" AS
/*   $Header: pyinrule.pkb 120.9 2008/02/26 06:46:52 pannapur noship $ */

   g_package     CONSTANT VARCHAR2(100) := 'pay_in_rules.';
   g_debug       BOOLEAN;

PROCEDURE get_default_run_type(p_asg_id   IN NUMBER,
                               p_ee_id    IN NUMBER,
                               p_effdate  IN DATE,
                               p_run_type OUT NOCOPY VARCHAR2)
   IS
  CURSOR c_run_type_id
  IS
    SELECT run_type_id
    FROM pay_run_types_f
    WHERE run_type_name = 'Cumulative Run'
    AND legislation_code='IN'
    AND p_effdate BETWEEN effective_start_date
                         AND effective_end_date;

  l_run_type_id NUMBER;
  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);

BEGIN
   l_procedure := g_package||'get_default_run_type';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_asg_id',p_asg_id);
      pay_in_utils.trace ('p_ee_id',p_ee_id);
      pay_in_utils.trace ('p_effdate',p_effdate);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   OPEN c_run_type_id;
   FETCH c_run_type_id INTO l_run_type_id;
   CLOSE c_run_type_id;
   p_run_type := to_char(l_run_type_id);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_run_type',p_run_type);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

END get_default_run_type;





PROCEDURE get_source_context(p_asg_act_id IN NUMBER,
                             p_ee_id      IN NUMBER,
                             p_source_id  IN OUT NOCOPY VARCHAR2)
IS

  l_element_name VARCHAR2(240);
  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);

--
-- Cursor for fetching the Element Name
 CURSOR csr_element_name IS
 SELECT pet.element_name
   FROM pay_element_entries_f pee
       ,pay_element_types_f pet
  WHERE pet.element_type_id = pee.element_type_id
    AND pee.element_entry_id = p_ee_id;
--
--Cursor for fetching PF Org Id
 CURSOR csr_get_pf_source IS
 SELECT hsc.segment2
   FROM pay_element_entries_f  target
       ,pay_assignment_actions paa
       ,pay_payroll_actions    ppa
       ,per_assignments_f      paf
       ,hr_soft_coding_keyflex hsc
  WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND target.element_entry_id = p_ee_id
    AND target.assignment_id = paa.assignment_id
    AND paa.assignment_action_id = p_asg_act_id
    AND paf.assignment_id = paa.assignment_id
    AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND ppa.effective_date BETWEEN target.effective_start_date
                               AND target.effective_end_date
    AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;
--
--Cursor for fetching PT Org Id
 CURSOR csr_get_pt_source is
 SELECT hsc.segment3
   FROM pay_element_entries_f  target
       ,pay_assignment_actions paa
       ,pay_payroll_actions    ppa
       ,per_assignments_f      paf
       ,hr_soft_coding_keyflex hsc
  WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND target.element_entry_id = p_ee_id
    AND target.assignment_id = paa.assignment_id
    AND paa.assignment_action_id = p_asg_act_id
    AND paf.assignment_id = paa.assignment_id
    AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND ppa.effective_date BETWEEN target.effective_start_date
                               AND target.effective_end_date
    AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;
--
--Cursor for fetching ESI Org Id
 CURSOR csr_get_esi_source IS
 SELECT hsc.segment4
   FROM pay_element_entries_f  target
       ,pay_assignment_actions paa
       ,pay_payroll_actions    ppa
       ,per_assignments_f      paf
       ,hr_soft_coding_keyflex hsc
  WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND target.element_entry_id = p_ee_id
    AND target.assignment_id = paa.assignment_id
    AND paa.assignment_action_id = p_asg_act_id
    AND paf.assignment_id = paa.assignment_id
    AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND ppa.effective_date BETWEEN target.effective_start_date
                               AND target.effective_end_date
    AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;

--Cursor for fetching fact/Establishment Org Id
 CURSOR csr_get_lwf_org is
 SELECT nvl(hsc.segment6,hsc.segment5)
   FROM pay_element_entries_f  target
       ,pay_assignment_actions paa
       ,pay_payroll_actions    ppa
       ,per_assignments_f      paf
       ,hr_soft_coding_keyflex hsc
  WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND target.element_entry_id = p_ee_id
    AND target.assignment_id = paa.assignment_id
    AND paa.assignment_action_id = p_asg_act_id
    AND paf.assignment_id = paa.assignment_id
    AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND ppa.effective_date BETWEEN target.effective_start_date
                               AND target.effective_end_date
    AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;
BEGIN
--
   l_procedure := g_package||'get_source_context';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_asg_act_id',p_asg_act_id);
      pay_in_utils.trace ('p_ee_id',p_ee_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   OPEN csr_element_name;
     FETCH csr_element_name INTO l_element_name;
   CLOSE csr_element_name;
--
    pay_in_utils.trace('l_element_name ',l_element_name);
    pay_in_utils.set_location(g_debug,l_procedure,20);

   IF l_element_name = 'PF Information' THEN
     OPEN csr_get_pf_source;
       FETCH csr_get_pf_source INTO p_source_id;
       p_source_id := nvl(p_source_id, '-1');
     CLOSE csr_get_pf_source;
   END IF;
--
   IF l_element_name = 'Professional Tax Information' THEN
     OPEN csr_get_pt_source;
       FETCH csr_get_pt_source into p_source_id;
       p_source_id := nvl(p_source_id, '-1');
     CLOSE csr_get_pt_source;
   END IF;
--
   IF l_element_name = 'ESI Information' THEN
     OPEN csr_get_esi_source;
       FETCH csr_get_esi_source into p_source_id;
       p_source_id := nvl(p_source_id, '-1');
     CLOSE csr_get_esi_source;
   END IF;
--
  IF l_element_name = 'LWF Information' THEN
   OPEN csr_get_lwf_org;
       FETCH csr_get_lwf_org into p_source_id;
       p_source_id := nvl(p_source_id, '-1');
     CLOSE csr_get_lwf_org;
   END IF;
   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_source_id',p_source_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END get_source_context;




PROCEDURE get_default_jurisdiction(p_asg_act_id   NUMBER,
                                   p_ee_id        NUMBER,
                                   p_jurisdiction IN OUT NOCOPY VARCHAR2) IS
--
l_element_name VARCHAR2(240);
l_org_id       VARCHAR2(240);
l_lwf_org_id       VARCHAR2(240);
l_procedure   VARCHAR(100);
l_message     VARCHAR2(250);

--
-- Cursor for fetching the Element Name
 CURSOR csr_element_name IS
 SELECT pet.element_name
   FROM pay_element_entries_f pee
       ,pay_element_types_f pet
  WHERE pet.element_type_id = pee.element_type_id
    AND pee.element_entry_id = p_ee_id;
--
--Cursor for fetching PT Org Id
 CURSOR csr_get_pt_org is
 SELECT hsc.segment3
   FROM pay_element_entries_f  target
       ,pay_assignment_actions paa
       ,pay_payroll_actions    ppa
       ,per_assignments_f      paf
       ,hr_soft_coding_keyflex hsc
  WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND target.element_entry_id = p_ee_id
    AND target.assignment_id = paa.assignment_id
    AND paa.assignment_action_id = p_asg_act_id
    AND paf.assignment_id = paa.assignment_id
    AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND ppa.effective_date BETWEEN target.effective_start_date
                               AND target.effective_end_date
    AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;

--Cursor for fetching fact/Establishment Org Id
 CURSOR csr_get_lwf_org is
 SELECT nvl(hsc.segment6,hsc.segment5)
   FROM pay_element_entries_f  target
       ,pay_assignment_actions paa
       ,pay_payroll_actions    ppa
       ,per_assignments_f      paf
       ,hr_soft_coding_keyflex hsc
  WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND target.element_entry_id = p_ee_id
    AND target.assignment_id = paa.assignment_id
    AND paa.assignment_action_id = p_asg_act_id
    AND paf.assignment_id = paa.assignment_id
    AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND ppa.effective_date BETWEEN target.effective_start_date
                               AND target.effective_end_date
    AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date;
--
BEGIN
--
   l_procedure := g_package||'get_default_jurisdiction';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_asg_act_id',p_asg_act_id);
      pay_in_utils.trace ('p_ee_id',p_ee_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;
--
   OPEN csr_element_name;
     FETCH csr_element_name INTO l_element_name;
   CLOSE csr_element_name;
--
    pay_in_utils.trace('l_element_name ',l_element_name);
    pay_in_utils.set_location(g_debug,l_procedure,20);
--
   IF l_element_name in('Income Information', 'Professional Tax Information') THEN
     OPEN csr_get_pt_org;
       FETCH csr_get_pt_org into l_org_id;
       l_org_id := nvl(l_org_id, '-1');
     CLOSE csr_get_pt_org;
       pay_in_utils.trace('l_org_id ',l_org_id);
       pay_in_utils.set_location(g_debug,l_procedure,30);
	 IF l_org_id = '-1' THEN
		p_jurisdiction := 'XX';
	ELSE
		 p_jurisdiction := nvl(pay_in_prof_tax_pkg.get_state(l_org_id), 'XX');
        END IF;

   ELSIF l_element_name = 'LWF Information' THEN
  pay_in_utils.trace('LWF information attached ',l_element_name);
   OPEN csr_get_lwf_org;
       FETCH csr_get_lwf_org into l_lwf_org_id;
       l_lwf_org_id := nvl(l_lwf_org_id, '-1');
     CLOSE csr_get_lwf_org;
   pay_in_utils.trace('l_lwf_org_id ',l_lwf_org_id);
    pay_in_utils.set_location(g_debug,l_procedure,40);
	  IF l_lwf_org_id = '-1' THEN
		  p_jurisdiction := 'XX';
	 ELSE
		  p_jurisdiction := nvl(pay_in_ff_pkg.get_lwf_state(l_lwf_org_id), 'XX');
	 END IF;
   END IF;

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_jurisdiction',p_jurisdiction);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END get_default_jurisdiction;
--



PROCEDURE get_source_text2_context(p_asg_act_id   NUMBER
                                  ,p_ee_id        NUMBER
                                  ,p_source_text2 IN OUT NOCOPY VARCHAR2)
IS

  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);

   CURSOR csr_context
   IS
      SELECT element_information1
      FROM   pay_element_types pet
            ,pay_element_links pel
            ,pay_element_entries pee
      WHERE  pet.element_type_id = pel.element_type_id
      AND    pel.element_link_id = pee.element_link_id
      AND    pee.element_entry_id = p_ee_id;

BEGIN

   l_procedure := g_package||'get_source_text2_context';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_asg_act_id',p_asg_act_id);
      pay_in_utils.trace ('p_ee_id',p_ee_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

    OPEN csr_context;
    FETCH csr_context
    INTO  p_source_text2;
    IF csr_context%NOTFOUND THEN
       p_source_text2 := 'Blank';
    END IF;
    CLOSE csr_context;

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_source_text2',p_source_text2);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

END get_source_text2_context;



FUNCTION  element_template_pre_process
          (p_template_obj    IN PAY_ELE_TMPLT_OBJ)
RETURN PAY_ELE_TMPLT_OBJ
IS
  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);
  l_template_obj PAY_ELE_TMPLT_OBJ;

BEGIN
   l_procedure := g_package||'element_template_pre_process';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_template_obj := p_template_obj;
   l_template_obj :=
      pay_in_element_template_pkg.element_template_pre_process
      (p_template_obj => p_template_obj);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   RETURN l_template_obj;

END element_template_pre_process;



PROCEDURE element_template_upd_user_stru
          (p_template_id    IN  NUMBER)
IS
  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);


BEGIN

   l_procedure := g_package||'element_template_upd_user_stru';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_template_id',p_template_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_element_template_pkg.element_template_upd_user_stru
          (p_template_id => p_template_id);

    pay_in_utils.trace('p_template_id ',p_template_id);
    pay_in_utils.set_location(g_debug,l_procedure,20);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END element_template_upd_user_stru;



PROCEDURE element_template_post_process
          (p_template_id    IN NUMBER)
IS
  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);


BEGIN

   l_procedure := g_package||'element_template_post_process';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_template_id',p_template_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug, l_procedure, 20);
   pay_in_element_template_pkg.element_template_post_process
      (p_template_id => p_template_id);

   pay_in_utils.trace('p_template_id ',p_template_id);
   pay_in_utils.set_location(g_debug,l_procedure,30);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END element_template_post_process;





PROCEDURE delete_pre_process
          (p_template_id    IN NUMBER)
IS
  l_procedure   VARCHAR(100);
  l_message     VARCHAR2(250);

BEGIN

   l_procedure := g_package||'get_source_text2_context';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_template_id',p_template_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_element_template_pkg.delete_pre_process
      (p_template_id => p_template_id);

    pay_in_utils.trace('p_template_id ',p_template_id);
    pay_in_utils.set_location(g_debug,l_procedure,20);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);


END delete_pre_process;

BEGIN
   g_debug := hr_utility.debug_enabled;
END pay_in_rules;

/
