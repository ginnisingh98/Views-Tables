--------------------------------------------------------
--  DDL for Package PER_CN_ASG_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_ASG_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pecnlhas.pkh 120.0 2005/05/31 06:52:04 appldev noship $ */
--
  g_package  VARCHAR2(33);

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

   PROCEDURE check_emp_asg_update(p_segment1       IN VARCHAR2
                                 ,P_segment20      IN VARCHAR2
                                 ,p_segment21      IN VARCHAR2
                                 ,p_segment22      IN VARCHAR2
                                 ,p_segment23      IN VARCHAR2
                                 ,p_effective_date IN DATE
                                 ,p_assignment_id  IN NUMBER );



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
  PROCEDURE check_emp_asg_create(p_scl_segment1       IN VARCHAR2
                                ,P_scl_segment20      IN VARCHAR2
                                ,p_scl_segment21      IN VARCHAR2
                                ,p_scl_segment22      IN VARCHAR2
                                ,p_scl_segment23      IN VARCHAR2
                                ,p_effective_date     IN DATE
                                ,p_person_id          IN NUMBER );




END per_cn_asg_leg_hook;

 

/
