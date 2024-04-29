--------------------------------------------------------
--  DDL for Package Body PA_PURGE_PROJECTS_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_PROJECTS_GEN_PKG" as
/* $Header: PAXPRGNB.pls 120.1 2005/08/19 17:17:26 mwasowic noship $ */
 G_purge_project_id        NUMBER(15);

 procedure gen_projects ( x_purge_batch_id                 in NUMBER,
                          x_active_closed_flag             in VARCHAR2,
                          x_closed_thru_date               in DATE,
                          x_organization_id                in NUMBER,
                          x_project_type                   in VARCHAR2,
                          x_project_status_code            in VARCHAR2,
                          x_purge_summary_flag             in VARCHAR2,
                          x_archive_summary_flag           in VARCHAR2,
                          x_purge_budgets_flag             in VARCHAR2,
                          x_archive_budgets_flag           in VARCHAR2,
                          x_purge_capital_flag             in VARCHAR2,
                          x_archive_capital_flag           in VARCHAR2,
                          x_purge_actuals_flag             in VARCHAR2,
                          x_archive_actuals_flag           in VARCHAR2,
                          x_admin_proj_flag                in VARCHAR2,
                          x_txn_to_date                    in DATE,
                          x_next_pp_project_status_code    in VARCHAR2,
                          x_next_p_project_status_code     in VARCHAR2,
                          x_user_id                        in NUMBER,
                          x_no_recs    			   in OUT NOCOPY NUMBER) is --File.Sql.39 bug 4440895


      cursor GenProjects is
            select  gp.project_id,
                    gp.project_status_code
              from  pa_projects_all  gp
             where (gp.carrying_out_organization_id = x_organization_id
                or  x_organization_id is null )
               and (gp.project_type = x_project_type
                or  x_project_type is null )
               and (trunc(gp.closed_date) <= trunc(x_closed_thru_date)
                or  x_closed_thru_date is null )
               and (gp.project_status_code = x_project_status_code
                or ((x_active_closed_flag = 'A'
               and  gp.project_type in ( select project_type
                                           from pa_project_types
                                          where project_type_class_code = 'INDIRECT')
               and  gp.project_status_code not in ('PARTIALLY_PURGED',
                                                   'PURGED',
                                                   'CLOSED'))
                or ( x_active_closed_flag = 'C'
               and gp.project_status_code in ('PARTIALLY_PURGED',
                                              'CLOSED')))) ;
     l_project_id             NUMBER ;
     l_project_status_code    VARCHAR2(30);
     l_active_closed_flag     VARCHAR2(1) := x_active_closed_flag;
     l_txn_to_date            DATE ;
     l_purge_actuals_flag     VARCHAR2(1) ;
     l_purge_budgets_flag     VARCHAR2(1) ;
     l_purge_capital_flag     VARCHAR2(1) ;
     l_purge_summary_flag     VARCHAR2(1) ;

     l_select_clause          VARCHAR2(2000);
     l_where_clause           VARCHAR2(2000);
     v_cursor_gen_id          INTEGER ;
     v_open_cursor            INTEGER ;
 BEGIN
     v_cursor_gen_id     := dbms_sql.open_cursor ;
     l_select_clause     := 'select  p.project_id, p.project_status_code ' ||
                             ' from  pa_projects p ' ;
     l_where_clause      := ' where pa_security.allow_update(p.project_id) = ''Y'' '||
                            '   and p.template_flag != ''Y'' ';

     if x_organization_id is not null then
        l_where_clause := l_where_clause ||' and p.carrying_out_organization_id = :organization_id ';
     end if;

     if x_closed_thru_date is not null then
        l_where_clause := l_where_clause ||' and trunc(p.closed_date) <= trunc(:closed_thru_date) ';
     end if;

     if x_project_type is not null then
        l_where_clause := l_where_clause ||' and p.project_type = :project_type ';
     end if;
     if x_project_status_code is not null then

        l_where_clause := l_where_clause ||' and p.project_status_code = :project_status_code ';

     end if;

     if x_active_closed_flag = 'A' then
        if x_project_status_code is null then
	/* Bug#2389976: Removed the trailing spaces for CLOSED and PARTIALLY_PURGED   */
           l_where_clause := l_where_clause ||' and p.project_status_code not  in '||
                                                   '(SELECT ps.project_status_code '||
                                                    ' from pa_project_statuses ps'||
                                                   ' where project_system_status_code in '||
                                                  ' (''PARTIALLY_PURGED'' , ' ||
                                                   '''PURGED'' , ' ||
                                                   '''PENDING_PURGE'' , ' ||
                                             '''CLOSED'' )' ||  ')' ;
        end if;
        if x_project_type is null then
            l_where_clause := l_where_clause ||' and  p.project_type in '||
                                               ' ( select pt.project_type ' ||
                                               ' from pa_project_types pt ' ||
                                               ' where pt.project_type_class_code = ''INDIRECT'') ' ;
        end if;
     elsif x_active_closed_flag = 'C' then
        if x_project_status_code is null then
	/* Bug#2389976: Removed the trailing spaces for PARTIALLY_PURGED   */
            l_where_clause := l_where_clause ||' and p.project_status_code in ' ||
                                                  '(  SELECT ps.project_status_code  '||
                                                  '  from pa_project_statuses ps'||
                                                  ' where ps.project_system_status_code in ' ||
                                                   '( ''CLOSED'' , ' ||
                                                    '''PARTIALLY_PURGED'' )' ||  ')';

        end if;
     end if;
/* code added for the bug#2464149, starts here */
     if x_admin_proj_flag = 'Y' then
        l_where_clause := l_where_clause ||' and pa_project_utils.Is_Admin_Project(p.project_id) = ''Y'' ';
     else
        l_where_clause := l_where_clause ||' and pa_project_utils.Is_Admin_Project(p.project_id) <> ''Y'' ';
     end if;
/* code added for the bug#2464149, ends here */


     dbms_sql.parse(v_cursor_gen_id, l_select_clause ||
                                     l_where_clause,
                                     dbms_sql.v7);

       if x_organization_id is not NULL then
         dbms_sql.bind_variable(v_cursor_gen_id, ':organization_id', x_organization_id) ;
     end if;

     if x_closed_thru_date is not NULL then
         dbms_sql.bind_variable(v_cursor_gen_id, ':closed_thru_date', x_closed_thru_date) ;
     end if;

     if x_project_type is not NULL then
         dbms_sql.bind_variable(v_cursor_gen_id, ':project_type', x_project_type) ;
     end if;

     if x_project_status_code is not NULL then
         dbms_sql.bind_variable(v_cursor_gen_id, ':project_status_code', x_project_status_code) ;
     end if;

     dbms_sql.define_column(v_cursor_gen_id, 1, l_project_id);
     dbms_sql.define_column(v_cursor_gen_id, 2, l_project_status_code, 30);

     x_no_recs := 0 ;
     -- open GenProjects ;
     v_open_cursor := dbms_sql.execute(v_cursor_gen_id);

     LOOP
        -- fetch GenProjects into l_project_id,
        --                        l_project_status_code ;

        If dbms_sql.fetch_rows(v_cursor_gen_id) = 0 then
            exit ;
        end if ;

        dbms_sql.column_value(v_cursor_gen_id, 1, l_project_id);
        dbms_sql.column_value(v_cursor_gen_id, 2, l_project_status_code);

        -- if GenProjects%notfound then
        --      exit ;
        -- end if ;

        l_txn_to_date            := x_txn_to_date;
        l_purge_actuals_flag     := x_purge_actuals_flag;
        l_purge_budgets_flag     := x_purge_budgets_flag;
        l_purge_capital_flag     := x_purge_capital_flag;
        l_purge_summary_flag     := x_purge_summary_flag;

        Get_Purge_Options(p_project_id         => l_project_id,
                          p_active_closed_flag => l_active_closed_flag,
                          x_txn_to_date        => l_txn_to_date,
                          x_purge_actuals_flag => l_purge_actuals_flag,
                          x_purge_budgets_flag => l_purge_budgets_flag,
                          x_purge_capital_flag => l_purge_capital_flag,
                          x_purge_summary_flag => l_purge_summary_flag);

        insert into pa_purge_projects
                  ( Purge_batch_Id,
                    Project_Id,
                    Last_Project_Status_Code,
                    txn_to_date ,
                    Purge_Actuals_Flag,
                    Archive_Actuals_Flag,
                    Purge_Budgets_Flag,
                    Archive_Budgets_Flag,
                    Purge_Capital_Flag,
                    Archive_Capital_Flag,
                    Purge_Summary_Flag,
                    Archive_Summary_Flag,
                    Next_PP_Project_Status_Code,
                    Next_P_Project_Status_Code,
                    Purged_Date,
                    Purge_Project_Status_Code,
                    Created_By,
                    Last_Update_date,
                    Last_Updated_By,
                    Creation_Date  )
            select x_purge_batch_id,
                   l_project_id,
                   l_project_status_code,
                   x_txn_to_date ,
                   l_purge_actuals_flag,
                   decode(l_purge_actuals_flag, 'N','N',x_archive_actuals_flag),
                   l_purge_budgets_flag,
                   decode(l_purge_budgets_flag, 'N','N',x_archive_budgets_flag),
                   l_purge_capital_flag,
                   decode(l_purge_capital_flag, 'N','N',x_archive_capital_flag),
                   l_purge_summary_flag,
                   decode(l_purge_summary_flag, 'N','N',x_archive_summary_flag),
                   x_Next_PP_Project_Status_Code,
                   x_Next_P_Project_Status_Code,
                   NULL,
                   'N',
                   x_user_id,
                   sysdate,
                   x_user_id,
                   sysdate
             from  dual
             where ( x_active_closed_flag = 'C'
               and ( l_purge_actuals_flag = 'Y'
                or   l_purge_budgets_flag = 'Y'
                or   l_purge_capital_flag = 'Y'
                or   l_purge_summary_flag = 'Y'))
                or ( l_txn_to_date is not null
               and  sign(x_txn_to_date - l_txn_to_date) = 1) ;

         x_no_recs  := nvl(x_no_recs, 0) + SQL%ROWCOUNT ;
     END LOOP ;

     -- close GenProjects ;
     dbms_sql.close_cursor(v_cursor_gen_id)  ;

 exception
   when others then
     raise ;

 END gen_projects;

 Procedure Get_Purge_Options(p_project_id                IN NUMBER,
                             p_active_closed_flag        IN VARCHAR2,
                             x_txn_to_date           IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                             x_purge_actuals_flag    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_purge_budgets_flag    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_purge_capital_flag    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_purge_summary_flag    IN OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

   l_txn_to_date           DATE ;
   l_purge_actuals_flag    VARCHAR2(1);
   l_purge_budgets_flag    VARCHAR2(1);
   l_purge_capital_flag    VARCHAR2(1);
   l_purge_summary_flag    VARCHAR2(1);

 begin

       Select NVL(MAX(decode(pp.txn_to_date, NULL, pp.purge_actuals_flag, 'N')), 'N'),
              MAX(pp.txn_to_date),
              NVL(MAX(pp.purge_capital_flag), 'N'),
              NVL(MAX(pp.purge_budgets_flag), 'N'),
              NVL(MAX(pp.purge_summary_flag), 'N')
         Into l_purge_actuals_flag,
              l_txn_to_date,
              l_purge_capital_flag,
              l_purge_budgets_flag,
              l_purge_summary_flag
         From pa_purge_projects pp
        Where pp.project_id = p_project_id ;

        if p_active_closed_flag = 'A' then
           x_purge_actuals_flag  := 'Y' ;
           x_purge_budgets_flag  := 'N' ;
           x_purge_capital_flag  := 'N' ;
           x_purge_summary_flag  := 'N' ;
           if l_txn_to_date is null then
               x_txn_to_date := x_txn_to_date - 1 ;
           else
              x_txn_to_date := l_txn_to_date ;
           end if ;
        else
           if l_purge_actuals_flag = 'Y' then
               x_purge_actuals_flag  := 'N' ;
           else
               x_purge_actuals_flag  := 'Y' ;
           end if;

           if l_purge_budgets_flag = 'Y' then
               x_purge_budgets_flag := 'N' ;
           end if ;

           if l_purge_capital_flag = 'Y' then
               x_purge_capital_flag := 'N' ;
           end if ;

           if l_purge_summary_flag = 'Y' then
               x_purge_summary_flag := 'N' ;
           end if ;
        end if ;

 EXCEPTION
   When others then
         NULL ;

 END Get_Purge_Options ;

END ;

/
