--------------------------------------------------------
--  DDL for Package Body PA_PURGE_EXTN_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_EXTN_VALIDATE" as
/* $Header: PAXAPVXB.pls 120.1 2005/08/19 17:08:28 mwasowic noship $ */

 -- forward declarations

 procedure validate_extn ( p_project_id                     in NUMBER,
                           p_txn_through_date               in DATE,
                           p_active_flag                    in VARCHAR2,
                           x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_err_stage                      in OUT NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895


-- cursor <CURSOR_VALIDATE> is
--    select 'CURSOR VALID '
--      from dual
--     where exists ( select ei.expenditure_item_id
--                      from pa_expenditure_items_all ei,
--                           pa_project_types_all pt,
--                           pa_tasks t,
--                           pa_projects_all p
--                     where ei.task_id = t.task_id
--                       and t.project_id = p.project_id
--                       and t.project_id = p_project_id
--                       and p.project_type = pt.project_type
--                       and nvl(pt.org_id, -99) = nvl(p.org_id, -99)
--                       and pt.burden_cost_flag = 'Y'
--                       and ( p_active_flag != 'Y'
--                        or (trunc(ei.expenditure_item_date ) < trunc(p_txn_through_date  ) ))) ;
--
-- Note :  The parameter p_txn_through_date includes transactions through a
--         given date. However, the archive/purge code and tables refer to
--         this parameter as txn_to_date
--

      l_err_stack_old    VARCHAR2(2000);
      l_err_stack        VARCHAR2(2000);
      l_err_stage        VARCHAR2(500);
      l_err_code         NUMBER ;
      l_dummy            VARCHAR2(500);

 BEGIN
--   l_err_code  := 0 ;
--   l_err_stack_old := x_err_stack;


-- Check if total burden cost distribution is run for the costs

--   Open <CURSOR_VALIDATE> ;
--   Fetch <CURSOR_VALIDATE> into l_dummy ;
--   If l_dummy is not null then
--      fnd_message.set_name('PA', '<CURSOR_VALIDATE_ERROR>');
--      fnd_msg_pub.add;
--
--      x_err_stage := 'After cursor validate error check ' ;
--      x_err_stack := x_err_stack || ' ->After cursor validate error check ' ;
--      pa_debug.debug('    * Cursor validate error  for project '||to_char(x_project_id));
--   End If;
--   close <CURSOR_VALIDATE>;
--   l_dummy := NULL;
--
-- EXAMPLE:
--
-- Check if total burden cost distribution is run for the costs
--
--     Open IsBurdenDistributed ;
--     Fetch IsBurdenDistributed into l_dummy ;
--     If l_dummy is not null then
--        fnd_message.set_name('PA', 'PA_ARPR_NOT_BRDN_DIST');
--        fnd_msg_pub.add;
--        l_err_code   :=  10 ;
--
--        l_err_stage := 'After Burden Cost Dist. check ' ;
--        l_err_stack := l_err_stack || ' ->After Burden Cost Dist. check ' ;
--        pa_debug.debug('    * Not all costs are burden distributed for project '
--                       ||to_char(p_project_id));
--     End If;
--     close IsBurdenDistributed;
--     l_dummy := NULL;
--
--

     NULL ;

--   x_err_stage := l_err_stage ;
--   x_err_stack := l_err_stack_old ;

EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    pa_debug.debug('Error Procedure Name  := PA_PURGE_EXTN_VALIDATE.VALIDATE_EXTN' );
    pa_debug.debug('Error stage is '||x_err_stage );
    pa_debug.debug('Error stack is '||x_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END validate_extn ;

END pa_purge_extn_validate ;

/
