--------------------------------------------------------
--  DDL for Package Body PER_CN_ASG_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_ASG_LEG_HOOK" AS
/* $Header: pecnlhas.pkb 120.2 2006/06/05 07:42:37 rpalli noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EMP_ASG                                       --
-- Type           : Procedure                                           --
-- Access         : Private                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the assignment.                                  --
--                  This procedure is the hook procedure for the        --
--                  employee assignment.                                --
-- Parameters     :                                                     --
--             IN :  p_employer_id               IN VARCHAR2            --
--                   p_tax_area_code             IN VARCHAR2            --
--                   p_sic_area_code             IN VARCHAR2            --
--                   p_salary_payout_location    IN VARCHAR2            --
--                   p_special_tax_exmp_category IN VARCHAR2            --
--                   p_effective_date            IN DATE                --
--                   p_person_id                 IN NUMBER DEFAULT null --
--                   p_assignment_id             IN NUMBER DEFAULT null --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19/12/02   Vikram.N  Created this procedure                    --
-- 1.1   16/01/03   statkar   Bug 2749867 changes                       --
-- 1.2   31/01/03   statkar   Added code to prevent the validation for  --
--                            default values. Bug 2676440               --
-- 1.3   19/09/03   statkar   Added the hr_utility.chk_product_install  --
--                            check for installed CN leg (3145322)      --
-- 1.4   18/08/04   snekkala  Added code to check the Salary Payout     --
--                            Location and Special Tax Exemption        --
--                            Category
-- 1.5   27/04/06   vjayacha  Added code to disable validations in case --
--                            default values are passed for employer_id --
-- 1.6   05/06/06   rpalli    Bug#5241993.Removed code for mandatory    --
--                            checks for parameters p_tax_area_code,    --
--                            p_employer_id and p_sic_area_code as they --
--                            are handled automatically.                --
--------------------------------------------------------------------------
PROCEDURE check_emp_asg(p_employer_id    IN VARCHAR2
                       ,p_tax_area_code  IN VARCHAR2
                       ,p_sic_area_code  IN VARCHAR2
                       ,p_salary_payout_locn IN VARCHAR2 DEFAULT NULL
                       ,p_special_tax_exmp_category IN VARCHAR2 DEFAULT NULL
                       ,p_effective_date IN DATE
                       ,p_person_id      IN NUMBER   DEFAULT null
                       ,p_assignment_id  IN NUMBER   DEFAULT null) AS

    l_proc                  VARCHAR2(72);
    l_business_group_id     per_all_people_f.business_group_id%TYPE;
    l_trunc_effective_date  DATE;

    CURSOR   csr_business_group_per(p_person_id NUMBER,p_effective_date DATE) IS
      SELECT business_group_id
      FROM   per_all_people_f
      WHERE  person_id = p_person_id
      AND    p_effective_date BETWEEN effective_start_date
             AND effective_end_date;

    CURSOR   csr_business_group_ass(p_assignment_id NUMBER,p_effective_date DATE) IS
      SELECT business_group_id
      FROM   per_all_assignments_f
      WHERE  assignment_id = p_assignment_id
      AND    p_effective_date BETWEEN effective_start_date
             AND effective_end_date;

    g_trace boolean;

BEGIN

  g_trace := hr_cn_assignment_api.g_trace;
  l_proc  := g_package||'check_emp_asg';
  --
  hr_cn_api.set_location(g_trace,'Entering: '||l_proc, 10);

--
-- Bug 3145322 Check the leg-specific validations only if the legislation
--             is installed
--
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'CN') THEN
       hr_utility.trace ('CN Legislation not installed. Not performing the validations');
       hr_cn_api.set_location(g_trace,'Leaving: '||l_proc, 15);
       RETURN;
  END IF;
--
-- Check for the mandatory arguments
--
    g_trace := TRUE;
    hr_cn_api.set_location(g_trace,l_proc,20);

--
-- Check for valid lookups
--
  hr_cn_api.set_location(g_trace,l_proc,40);
  IF p_tax_area_code <> hr_api.g_varchar2 THEN
     hr_cn_api.check_lookup (
            p_lookup_type     => 'CN_TAX_AREA',
            p_argument        => 'P_TAX_AREA_CODE',
            p_argument_value  => p_tax_area_code
           );
  END IF;
  --
--
-- Bug 2955433 SIC Area Code now is made mandatory
--
  hr_cn_api.set_location(g_trace,l_proc,50);
  IF p_sic_area_code <> hr_api.g_varchar2
  THEN
     hr_cn_api.check_lookup (
            p_lookup_type     => 'CN_SIC_AREA',
            p_argument        => 'P_SIC_AREA_CODE',
            p_argument_value  => p_sic_area_code
           );
  END IF;

--
-- Bug 3828396 Added code to check Salary Payout Location and Special Tax Exemption category
--
  hr_cn_api.set_location(g_trace,l_proc,60);
  IF p_salary_payout_locn <> hr_api.g_varchar2
  THEN
     hr_cn_api.check_lookup (
            p_lookup_type     => 'CN_PAYOUT_LOCATION',
            p_argument        => 'P_SALARY_PAYOUT_LOCN',
            p_argument_value  => p_salary_payout_locn
           );
  END IF;

  hr_cn_api.set_location(g_trace,l_proc,70);
  IF p_special_tax_exmp_category <> hr_api.g_varchar2
  THEN
   hr_cn_api.check_lookup (
            p_lookup_type     => 'CN_SPL_TAX_EXMP_CATEGORY',
            p_argument        => 'P_SPECIAL_TAX_EXMP_CATEGORY',
            p_argument_value  => p_special_tax_exmp_category
           );
  END IF;
--
-- Bug 3828396 changes end
--
  --
  --Trunc of date will return date without the time part.
  --
  hr_cn_api.set_location(g_trace,l_proc,80);
  l_trunc_effective_date := TRUNC(p_effective_date);

    IF p_assignment_id IS null THEN

      hr_cn_api.check_person(p_person_id, 'CN', l_trunc_effective_date);

      OPEN csr_business_group_per(p_person_id,l_trunc_effective_date);
         FETCH csr_business_group_per INTO l_business_group_id;
      CLOSE csr_business_group_per;

    ELSIF p_person_id IS null THEN

      hr_cn_api.check_assignment(p_assignment_id, 'CN', l_trunc_effective_date);

      OPEN csr_business_group_ass(p_assignment_id,l_trunc_effective_date);
        FETCH csr_business_group_ass INTO l_business_group_id;
      CLOSE csr_business_group_ass;

   END IF;

   IF p_employer_id <> hr_api.g_varchar2
   THEN

     hr_cn_api.check_organization
                (p_organization_id   => p_employer_id
                ,p_business_group_id => l_business_group_id
                ,p_legislation_code  => 'CN'
		,p_effective_date    => l_trunc_effective_date
                ) ;

     hr_cn_api.check_org_class
    		(p_organization_id   => p_employer_id
                ,p_classification    => 'PER_EMPLOYER_INFO_CN'
		) ;

     hr_cn_api.check_org_type
                (p_organization_id   => p_employer_id
		,p_type              => 'HR_LEGAL'
		);
   END IF;

    hr_cn_api.set_location(g_trace,l_proc,120);

EXCEPTION
  WHEN OTHERS THEN
     IF csr_business_group_per%ISOPEN OR csr_business_group_ass%ISOPEN THEN
        CLOSE csr_business_group_per;
        CLOSE csr_business_group_ass;
     END IF;
     RAISE;

END check_emp_asg;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EMP_ASG_UPDATE                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the assignment.                                  --
--                  This procedure is the hook procedure for update     --
--                  employee assignment.                                --
-- Parameters     :                                                     --
--             IN :  p_segment1       IN VARCHAR2                       --
--                   p_segment20      IN VARCHAR2                       --
--                   p_segment21      IN VARCHAR2                       --
--                   p_segment22      IN VARCHAR2                       --
--                   p_segment23      IN VARCHAR2                       --
--                   p_effective_date IN DATE                           --
--                   p_assignment_id  IN NUMBER                         --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19/12/02   Vikram.N  Created this procedure                    --
-- 1.1   18/08/04   snekkala  Added p_segment22 and p_segment23         --
--------------------------------------------------------------------------
PROCEDURE check_emp_asg_update   (p_segment1       IN VARCHAR2
                                 ,P_segment20      IN VARCHAR2
                                 ,p_segment21      IN VARCHAR2
                                 ,P_segment22      IN VARCHAR2
                                 ,p_segment23      IN VARCHAR2
                                 ,p_effective_date IN DATE
                                 ,p_assignment_id  IN NUMBER ) AS


     l_proc    VARCHAR2(72);

BEGIN

    l_proc := g_package || 'check_emp_asg_update';
          --
    hr_cn_api.set_location(hr_cn_assignment_api.g_trace,'Entering: '||l_proc,10);

    check_emp_asg
            (p_employer_id               => p_segment1
            ,p_tax_area_code             => p_segment20
            ,p_sic_area_code             => p_segment21
            ,p_salary_payout_locn        => p_segment22
            ,p_special_tax_exmp_category => p_segment23
            ,p_effective_date            => p_effective_date
            ,p_assignment_id             => p_assignment_id);


    hr_cn_api.set_location(hr_cn_assignment_api.g_trace,'Leaving: '||l_proc,20);

END check_emp_asg_update;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EMP_ASG_CREATE                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the assignment.                                  --
--                  This procedure is the hook procedure for create     --
--                  secondary employee assignment.                      --
-- Parameters     :                                                     --
--             IN :  p_scl_segment1   IN VARCHAR2                       --
--                   p_scl_segment20  IN VARCHAR2                       --
--                   p_scl_segment21  IN VARCHAR2                       --
--                   p_scl_segment22  IN VARCHAR2                       --
--                   p_scl_segment23  IN VARCHAR2                       --
--                   p_effective_date IN DATE                           --
--                   p_person_id      IN NUMBER                         --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19/12/02   Vikram.N  Created this procedure                    --
-- 1.1   18/08/04   snekkala  Added p_scl_segment22 and p_scl_segment23 --
--------------------------------------------------------------------------

PROCEDURE check_emp_asg_create (p_scl_segment1       IN VARCHAR2
                               ,P_scl_segment20      IN VARCHAR2
                               ,p_scl_segment21      IN VARCHAR2
                               ,P_scl_segment22      IN VARCHAR2
                               ,p_scl_segment23      IN VARCHAR2
                               ,p_effective_date     IN DATE
                               ,p_person_id          IN NUMBER ) AS


     l_proc     VARCHAR2(72);


BEGIN

    l_proc := g_package||'check_emp_asg_create';
    hr_cn_api.set_location(hr_cn_assignment_api.g_trace,'Entering: '||l_proc,10);

    check_emp_asg
            (p_employer_id                => p_scl_segment1
            ,p_tax_area_code              => p_scl_segment20
            ,p_sic_area_code              => p_scl_segment21
            ,p_salary_payout_locn         => p_scl_segment22
            ,p_special_tax_exmp_category  => p_scl_segment23
            ,p_effective_date             => p_effective_date
            ,p_person_id                  => p_person_id);


    hr_cn_api.set_location(hr_cn_assignment_api.g_trace,'Leaving: '||l_proc,20);

END check_emp_asg_create;

BEGIN

    g_package := 'per_cn_asg_leg_hook.';

END per_cn_asg_leg_hook;

/
