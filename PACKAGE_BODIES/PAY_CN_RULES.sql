--------------------------------------------------------
--  DDL for Package Body PAY_CN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_RULES" AS
/* $Header: pycnrule.pkb 120.1 2006/10/03 07:49:54 rpalli noship $ */

g_debug              BOOLEAN ;
g_package_name       VARCHAR2(13);
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DEFAULT_JURISDICTION                            --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to get the default jurisdcition           --
--                  for China tax processing.                           --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_asg_act_id           NUMBER                       --
--                  p_ee_id                NUMBER                       --
--        IN/OUT  : p_jurisdiction         VARCHAR2                     --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-FEB-03  vinaraya  Created this Procedure                    --
-- 1.1   19-Mar-03  vinaraya  Changed the indentation as per review     --
--                            comments.                                 --
-- 1.2   13-May-03  statkar   Included code for PHF/SI Processing       --
--------------------------------------------------------------------------
PROCEDURE get_default_jurisdiction( p_asg_act_id                 NUMBER
                                  , p_ee_id                      NUMBER
                                  , p_jurisdiction IN OUT NOCOPY VARCHAR2
                                  )
IS
BEGIN
        NULL;

END get_default_jurisdiction;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_RETRO_COMPONENT_ID                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to get the default retro component id for --
--                  a particular element entry from Org DDF             --
--                                                                      --
-- Parameters     :                                                     --
--        IN      : p_ee_id                NUMBER                       --
--                : p_element_type_id      NUMBER                       --
--        IN/OUT  : p_retro_component_id   NUMBER                       --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01-Apr-04  statkar   Created this Procedure                    --
-- 2.0   14-Sep-04  statkar   Changed the signature                     --
-- 3.0   29-Sep-06  rpalli    Modified code to support Retropay to be   --
--                            handled for changes in PHFSI Info elements--
--------------------------------------------------------------------------
PROCEDURE get_retro_component_id ( p_ee_id               IN NUMBER
                                 , p_element_type_id     IN NUMBER
                                 , p_retro_component_id  IN OUT NOCOPY NUMBER
                                 )
IS

   l_procedure_name     VARCHAR2(255) ;

   CURSOR csr_et(p_effective_date IN DATE) IS
      SELECT pet.element_name, pee.creator_type
      FROM   pay_element_entries_f pee
            ,pay_element_links_f pel
            ,pay_element_types_f pet
      WHERE pee.element_link_id  = pel.element_link_id
      AND   pel.element_type_id  = pet.element_type_id
      AND   pee.element_entry_id = p_ee_id
      AND   p_effective_date BETWEEN pel.effective_start_date
                             AND     pel.effective_end_date
      AND   p_effective_date BETWEEN pet.effective_start_date
                             AND     pet.effective_end_date
      ORDER BY pee.effective_start_date desc;

   CURSOR csr_ename (p_effective_date IN DATE) IS
      SELECT element_name, 'F'
      FROM   pay_element_types_f
      WHERE  element_type_id = p_element_type_id
      AND    p_effective_date BETWEEN effective_start_date
                              AND     effective_end_date;

   CURSOR csr_tax_area (p_effective_date IN DATE) IS
      SELECT hsck.segment20, pa.business_group_id
      FROM   pay_element_entries_f pee
            ,per_assignments_f pa
            ,hr_soft_coding_keyflex hsck
      WHERE pee.assignment_id         = pa.assignment_id
      AND   pa.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
      AND   pee.element_entry_id = p_ee_id
      AND   p_effective_date BETWEEN pa.effective_start_date
                             AND     pa.effective_end_date
      ORDER BY pee.effective_start_date desc;

   CURSOR csr_rc_id (p_bg_id IN NUMBER, p_tax_area IN VARCHAR2, p_effective_date IN DATE)
   IS
      SELECT org_information2
      FROM   hr_organization_information
      WHERE  organization_id = p_bg_id
      AND    org_information_context = 'PER_CONT_AREA_RETRO_USAGE_CN'
      AND    org_information1        = p_tax_area
      AND    p_effective_date BETWEEN TO_DATE(org_information3,'YYYY/MM/DD HH24:MI:SS')
                              AND     TO_DATE(NVL(org_information4,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS');

   l_retro_component_id    pay_retro_components.retro_component_id%TYPE;
   l_element_name          pay_element_types_f.element_name%TYPE;
   l_tax_area              hr_soft_coding_keyflex.segment20%TYPE;
   l_bg_id                 per_all_assignments_f.business_group_id%TYPE;
   l_effective_date        DATE;
   l_creator_type          pay_element_entries_f.creator_type%TYPE;

BEGIN
   l_procedure_name     := g_package_name ||'get_retro_component_id';
   g_debug  := hr_utility.debug_enabled;
   hr_cn_api.set_location (g_debug,'Entering : '||l_procedure_name,10);

   l_retro_component_id := p_retro_component_id;
   l_effective_date := hr_general.effective_date;

   IF g_debug THEN
      hr_utility.trace ('====================================================');
      hr_utility.trace ('      Element Entry ID : '||p_ee_id);
      hr_utility.trace ('Old Retro Component ID : '||p_retro_component_id);
      hr_utility.trace ('        Effective Date : '||TO_CHAR(l_effective_date, 'DD/MM/YYYY'));
   END IF;

   OPEN csr_et(l_effective_date);
   FETCH csr_et INTO l_element_name, l_creator_type;
   IF csr_et%NOTFOUND THEN
      CLOSE csr_et;
      OPEN csr_ename(l_effective_date);
      FETCH csr_ename INTO  l_element_name, l_creator_type;
      IF csr_ename%NOTFOUND THEN
         hr_cn_api.set_location (g_debug,'Leaving : '||l_procedure_name, 20);
         CLOSE csr_ename;
         RETURN;
      ELSE
         CLOSE csr_ename;
      END IF;
   ELSE
      CLOSE csr_et;
   END IF;

   IF g_debug THEN
      hr_utility.trace ('          Element Name : '||l_element_name);
      hr_utility.trace ('          Creator Type : '||l_creator_type);
      hr_utility.trace ('====================================================');
   END IF;

   IF l_element_name NOT IN
                        ('Taxation Information')           -- Bug 5484589
   AND l_creator_type NOT IN ('EE', 'PR', 'R', 'RR','NR')  -- Bug 3619384
   THEN
       OPEN csr_tax_area(l_effective_date);
       FETCH csr_tax_area INTO l_tax_area, l_bg_id;
       CLOSE csr_tax_area;
       IF g_debug THEN
         hr_utility.trace ('              Tax Area : '||l_tax_area);
         hr_utility.trace ('     Business Group ID : '||l_bg_id);
       END IF;

       BEGIN
         OPEN csr_rc_id (l_bg_id, l_tax_area, l_effective_date);
         FETCH csr_rc_id INTO l_retro_component_id;
         CLOSE csr_rc_id;

         IF g_debug THEN
            hr_utility.trace ('New Retro Component ID : '||p_retro_component_id);
         END IF;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF csr_rc_id%ISOPEN THEN
               CLOSE csr_rc_id;
            END IF;
            p_retro_component_id := -1;
	    RAISE;
       END;

   END IF;
   p_retro_component_id := l_retro_component_id;
   hr_cn_api.set_location (g_debug,'Leaving : '||l_procedure_name,30);

EXCEPTION
   WHEN OTHERS THEN
      IF csr_et%ISOPEN THEN
         close csr_et;
      END IF;
      IF csr_tax_area%ISOPEN THEN
         close csr_tax_area;
      END IF;
      IF csr_rc_id%isopen THEN
         close csr_rc_id;
      END IF;
      IF csr_ename%ISOPEN THEN
         close csr_ename;
      END IF;
      p_retro_component_id := -1;
      hr_utility.trace(hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure_name, 'SQLERRMC:'||sqlerrm));
      hr_cn_api.set_location (g_debug,'Leaving : '||l_procedure_name,40);
      RAISE;

END get_retro_component_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : ELEMENT_TEMPLATE_POST_PROCESS                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Accepts the Template Name as input and return the   --
--                  Results Setup                                       --
--                                                                      --
-- Parameters     : None                                                --
--        IN      : p_template_id           NUMBER                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   17-Apr-05  snekkala  Created this Procedure                    --
--------------------------------------------------------------------------
PROCEDURE element_template_post_process
          (p_template_id    IN NUMBER)
IS
BEGIN

   pay_cn_element_template_pkg.element_template_post_process(p_template_id);

END element_template_post_process;

BEGIN

  g_package_name := 'pay_cn_rules.';

END pay_cn_rules;

/
