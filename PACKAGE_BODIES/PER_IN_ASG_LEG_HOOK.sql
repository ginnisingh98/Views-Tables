--------------------------------------------------------
--  DDL for Package Body PER_IN_ASG_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_ASG_LEG_HOOK" AS
/* $Header: peinlhas.pkb 120.2 2006/04/27 00:04 vgsriniv noship $ */

   g_package        CONSTANT VARCHAR2(100) :='per_in_asg_leg_hook.';
   g_debug          BOOLEAN;
   g_procedure_name VARCHAR2(100);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ASG                                           --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the assignment.                                  --
--                  This procedure is the internal procedure to be used --
--                  as common point to code for INS and UPD             --
-- Parameters     :                                                     --
--             IN :  p_dt_mode                   IN VARCHAR2            --
--                   p_pt_org_id                 IN VARCHAR2            --
--                   p_effective_date            IN DATE                --
--                   p_assignment_id             IN NUMBER DEFAULT null --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   06-Sep-04  statkar   3768210 - created                         --
-- 1.1   04-Dec-04  statkar   4029400 - added 2 new procs for ESI/PF    --
-- 1.2   18-Jan-05  rpalli    4114216 - Corrected code for support for  --
--                                      ESI/PF                          --
-- 1.3   02-Feb-05  rpalli    4158566 - Modified message_name to        --
--                                      'SUCCESS'                       --
-- 1.4   10-Apr-05  abhjain   4270513 - Removed call to check_pt_update --
--                                      and check_esi_update            --
-- 1.5   02-Sep-05  aaagarwa  4589599 - Added p_gre parameter.          --
--------------------------------------------------------------------------
PROCEDURE check_asg (p_dt_mode        IN VARCHAR2
                    ,p_effective_date IN DATE
                    ,p_assignment_id  IN NUMBER
                    ,p_gre_id         IN VARCHAR2
                    ,p_pf_org_id      IN VARCHAR2
                    ,p_pt_org_id      IN VARCHAR2
                    ,p_esi_org_id     IN VARCHAR2
                    ,p_factory_id     IN VARCHAR2
                    ,p_estab_id       IN VARCHAR2
                    ,p_pga_flag       IN VARCHAR2
                    ,p_subint_flag    IN VARCHAR2
                    ,p_director       IN VARCHAR2
                    ,p_specified      IN VARCHAR2
                    )
IS
     CURSOR c_org_name (p_org_id IN NUMBER) IS
       SELECT name
       FROM   hr_all_organization_units_tl
       WHERE  organization_id = p_org_id
       AND    language        = userenv('LANG');

     l_pf_org   hr_all_organization_units_tl.name%TYPE;
     l_gre_org   hr_all_organization_units_tl.name%TYPE;
     l_esi_org   hr_all_organization_units_tl.name%TYPE;
     l_message  VARCHAR2(255);
     l_procedure  VARCHAR2(100);

BEGIN

    g_debug := hr_utility.debug_enabled ;
    l_procedure := g_package ||'check_asg';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
       hr_utility.trace ('IN Legislation not installed. Not performing the validations');
       pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
       RETURN;
    END IF;

    pay_in_utils.set_location(g_debug,l_procedure,30);
--
-- Code for PF Information
--
   l_message := 'SUCCESS';

    OPEN c_org_name(p_gre_id);
    FETCH c_org_name
    INTO  l_gre_org;
    IF c_org_name%NOTFOUND THEN
       pay_in_utils.set_location(g_debug,l_procedure,40);
       l_gre_org := NULL;
    END IF;
    CLOSE c_org_name;

    OPEN c_org_name(p_pf_org_id);
    FETCH c_org_name
    INTO  l_pf_org;
    IF c_org_name%NOTFOUND THEN
       pay_in_utils.set_location(g_debug,l_procedure,40);
       l_pf_org := NULL;
    END IF;
    CLOSE c_org_name;

    OPEN c_org_name(p_esi_org_id);
    FETCH c_org_name
    INTO  l_esi_org;
    IF c_org_name%NOTFOUND THEN
       pay_in_utils.set_location(g_debug,l_procedure,40);
       l_esi_org := NULL;
    END IF;
    CLOSE c_org_name;

    pay_in_utils.set_location(g_debug,l_procedure,50);

    pay_in_ff_pkg.check_pf_update
         (p_effective_date   => p_effective_date
         ,p_dt_mode          => p_dt_mode
         ,p_assignment_id    => p_assignment_id
	 ,p_gre_org          => l_gre_org
         ,p_pf_org           => l_pf_org
	 ,p_esi_org          => l_esi_org
         ,p_message          => l_message
         ,p_gre              => NULL
	 ,p_pf               => NULL
         ,p_esi              => NULL
         );

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

EXCEPTION
  WHEN OTHERS THEN
      IF c_org_name%ISOPEN THEN close c_org_name; END IF;
      hr_utility.set_message(800, 'PER_IN_ORACLE_GENERIC_ERROR');
      hr_utility.set_message_token('FUNCTION',l_procedure);
      hr_utility.set_message_token('SQLERRMC',sqlerrm);
      hr_utility.raise_error;
END check_asg;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ASG_UPDATE                                    --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the assignment.                                  --
--                  This procedure is the hook procedure for update     --
--                  employee assignment.                                --
-- Parameters     :                                                     --
--             IN :  p_datetrack_update_mode   VARCHAR2                 --
--                   p_effective_date          DATE                     --
--                   p_assignment_id           NUMBER                   --
--                   p_segment1                VARCHAR2                 --
--                   p_segment2                VARCHAR2                 --
--                   p_segment3                VARCHAR2                 --
--                   p_segment4                VARCHAR2                 --
--                   p_segment5                VARCHAR2                 --
--                   p_segment6                VARCHAR2                 --
--                   p_segment8                VARCHAR2                 --
--                   p_segment9                VARCHAR2                 --
--                   p_segment10               VARCHAR2                 --
--                   p_segment11               VARCHAR2                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   06-Sep-04  statkar   3768210 - created                         --
-- 1.1   04-Dec-04  statkar   4029400 - added PF/ESI support            --
-- 1.2   09-Feb-05  rpalli    4158566 - Commented out call for          --
--                                      validations for assignment api  --
--------------------------------------------------------------------------
PROCEDURE check_asg_update (p_datetrack_update_mode   IN VARCHAR2
                           ,p_effective_date           IN DATE
                           ,p_assignment_id            IN NUMBER
                           ,p_segment1                 IN VARCHAR2 -- tax unit
                           ,p_segment2                 IN VARCHAR2 -- pf_org
                           ,p_segment3                 IN VARCHAR2 -- pt_org
                           ,p_segment4                 IN VARCHAR2 -- esi_org
                           ,p_segment5                 IN VARCHAR2 -- factory
                           ,p_segment6                 IN VARCHAR2 -- estb
                           ,p_segment8                 IN VARCHAR2 -- PGA flag
                           ,p_segment9                 IN VARCHAR2 -- Sub Interest
                           ,p_segment10                IN VARCHAR2 -- Director
                           ,p_segment11                IN VARCHAR2 -- Specified
                           )
IS
l_procedure  VARCHAR2(100);
BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure := g_package ||'check_asg_update';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
          --

/*    check_asg
       (p_dt_mode             => p_datetrack_update_mode
       ,p_effective_date      => p_effective_date
       ,p_assignment_id       => p_assignment_id
       ,p_gre_id              => p_segment1
       ,p_pf_org_id           => p_segment2
       ,p_pt_org_id           => p_segment3
       ,p_esi_org_id          => p_segment4
       ,p_factory_id          => p_segment5
       ,p_estab_id            => p_segment6
       ,p_pga_flag            => p_segment8
       ,p_subint_flag         => p_segment9
       ,p_director            => p_segment10
       ,p_specified           => p_segment11
       );

    pay_in_utils.set_location(g_debug,'Leaving: '||g_procedure_name,20);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(800, 'PER_IN_ORACLE_GENERIC_ERROR');
      hr_utility.set_message_token('FUNCTION',g_procedure_name);
      hr_utility.set_message_token('SQLERRMC',sqlerrm);
      hr_utility.raise_error; */

pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
END check_asg_update;


END  per_in_asg_leg_hook;

/
