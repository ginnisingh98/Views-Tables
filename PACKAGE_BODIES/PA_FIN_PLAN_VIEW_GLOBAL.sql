--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_VIEW_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_VIEW_GLOBAL" as
/* $Header: PARFPSVB.pls 120.4 2006/03/09 20:11:28 nkumbi noship $ */

PROCEDURE pa_fp_get_budget_status_code(
                                        p_budget_version_id   IN  NUMBER,
                                        x_budget_status_code      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count         OUT NOCOPY NUMBER,  --File.Sql.39 bug 4440895
                                        x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    )

IS

BEGIN
             select budget_status_code
              into  x_budget_status_code
              from pa_budget_versions
             where budget_version_id = p_budget_version_id;


END pa_fp_get_budget_status_code;

PROCEDURE pa_fp_set_orgfcst_version_id(
                               		p_orgfcst_version_id  IN  NUMBER,
                                        p_period_start_date   IN  VARCHAR2,
                               		x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               		x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               		x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
IS
l_start_date DATE;
ll_plan_start_date DATE;
ll_plan_end_date DATE;
ll_plan_period_type VARCHAR2(30);
l_return_status  VARCHAR2(2);
l_msg_count  NUMBER;
l_msg_data  VARCHAR2(80);
l_num_of_periods NUMBER;
l_project_id NUMBER;
l_org_id NUMBER;

BEGIN

x_return_status    := FND_API.G_RET_STS_SUCCESS;

pa_fin_plan_view_global.G_FP_VIEW_VERSION_ID := p_orgfcst_version_id;

        select project_id
         into  l_project_id
         from  pa_budget_versions
        where  budget_version_id = p_orgfcst_version_id;

       select nvl(org_id,-99)
         into l_org_id
         from pa_projects_all
        where project_id = l_project_id;

         pa_fin_plan_view_global.G_FP_ORG_ID := l_org_id;

        select fin_plan_start_date, fin_plan_end_date
         into  ll_plan_start_date,ll_plan_end_date
         from  pa_proj_fp_options
        where  fin_plan_version_id = p_orgfcst_version_id;


        select pp.plan_period_type
        into   ll_plan_period_type
        from   pa_proj_period_profiles pp,
               pa_budget_versions pbv
        where  pbv.budget_version_id = p_orgfcst_version_id
         and   pp.period_profile_id = pbv.period_profile_id;

	pa_fin_plan_view_global.G_FP_PLAN_START_DATE := ll_plan_start_date;
	pa_fin_plan_view_global.G_FP_PLAN_END_DATE := ll_plan_end_date;
	pa_fin_plan_view_global.G_FP_PERIOD_TYPE := ll_plan_period_type;

        if ll_plan_period_type = 'GL' THEN
        l_num_of_periods := 6;
        else
        l_num_of_periods := 13;
        end if;

	if p_period_start_date = 'N' Then

        l_start_date :=  to_char(ll_plan_start_date);

        elsif p_period_start_date = 'L' Then

         pa_fin_plan_view_global.G_FP_VIEW_START_DATE1:=ll_plan_end_date;
         pa_fin_plan_view_global.pa_fp_set_periods_nav (
                                  p_direction      => 'BACKWARD',
                                  p_num_of_periods => l_num_of_periods,
                                  p_period_type    => ll_plan_period_type,
                                  x_start_date     => l_start_date,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data);


        else
             l_start_date := p_period_start_date;


        end if;

        pa_fin_plan_view_global.pa_fp_set_periods (
                                       p_period_start_date => l_start_date,
                                       p_period_type       => ll_plan_period_type,
                                       x_return_status     => l_return_status,
                                       x_msg_count         => l_msg_count,
                                       x_msg_data          => l_msg_data
                            );



EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_VIEW_GLOBAL',
                               p_procedure_name   => 'pa_fp_set_orgfcst_version_id');

END pa_fp_set_orgfcst_version_id;

PROCEDURE pa_fp_set_Adj_Reason_Code(
                                        p_adj_reason_code   IN  VARCHAR2,
                                        x_adj_comments      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    )
IS

BEGIN
           x_return_status:=  FND_API.G_RET_STS_SUCCESS;
           pa_fin_plan_view_global.G_FP_ADJ_REASON_CODE := p_adj_reason_code;

   begin
           select pe.adjustment_comments
           into   x_adj_comments
           from  pa_fp_adj_elements pe,
                 pa_resource_assignments pra
           where pra.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
             and resource_assignment_type = 'OWN'
             and pe.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
             and pe.resource_assignment_id = pra.resource_assignment_id
             and pe.ADJUSTMENT_REASON_CODE = pa_fin_plan_view_global.Get_Adj_Reason_Code();

  exception
      when no_data_found then
        --   x_return_status := FND_API.G_RET_STS_ERROR;
           x_adj_comments := null;
  end;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_VIEW_GLOBAL',
                               p_procedure_name   => 'pa_fp_viewby_set_globals');


END pa_fp_set_Adj_Reason_Code;


PROCEDURE pa_fp_viewby_set_globals(    p_amount_type_code       IN   VARCHAR2,
                                       p_resource_assignment_id IN   NUMBER,
				       p_budget_version_id      IN   NUMBER,
                                       p_start_period           IN   VARCHAR2,
                                       x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count              OUT  NOCOPY NUMBER,  --File.Sql.39 bug 4440895
                                       x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
IS

l_budget_version_id NUMBER;
l_return_status  VARCHAR2(2);
l_msg_count  NUMBER;
l_msg_data  VARCHAR2(80);
l_start_date VARCHAR2(30);

BEGIN

x_return_status    := FND_API.G_RET_STS_SUCCESS;

pa_fin_plan_view_global.G_FP_AMOUNT_TYPE_CODE := p_amount_type_code;
           pa_fin_plan_view_global.G_FP_RA_ID := p_resource_assignment_id;
                       l_budget_version_id    := p_budget_version_id;

 				l_start_date  := p_start_period;

pa_fin_plan_view_global.pa_fp_set_orgfcst_version_id(
                                        p_orgfcst_version_id => l_budget_version_id,
					p_period_start_date => l_start_date,
                                        x_return_status => l_return_status,
                                        x_msg_count    => l_msg_count,
                                        x_msg_data   => l_msg_data
                                   );




EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_VIEW_GLOBAL',
                               p_procedure_name   => 'pa_fp_viewby_set_globals');
END pa_fp_viewby_set_globals;



PROCEDURE pa_fp_set_periods (
                                       p_period_start_date      IN   VARCHAR2,
				       p_period_type		IN   VARCHAR2,
                                       x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

                            )

IS

l_start_date		DATE;
v_start_date_tab	PA_FORECAST_GLOB.DateTabTyp;
v_end_date_tab          PA_FORECAST_GLOB.DateTabTyp;
i			NUMBER;
l_rownum		NUMBER;

CURSOR C1(l_start_date IN DATE, l_rownum IN NUMBER) IS
  SELECT * FROM(
      SELECT start_date,end_date
      FROM pa_orgfcst_periods_tmp_v
     WHERE start_date  >= l_start_date
       order by start_date
           )
  where rownum <= l_rownum;

--Bug 4947912
l_format_mask           nls_session_parameters.value%TYPE;

BEGIN

	x_return_status    := FND_API.G_RET_STS_SUCCESS;

        /* Bug Fix 4373890
           As a part of GSCC error fixes, modified the following statement
           by adding the format mask
        */

        --Bug 4947912
         SELECT  value
           INTO    l_format_mask
           FROM    nls_session_parameters
           WHERE   parameter='NLS_DATE_FORMAT';
           l_start_date := to_date(p_period_start_date,l_format_mask);

        i := 0;

   if p_period_type = 'GL' THEN

      l_rownum := 6;

   elsif p_period_type = 'PA' THEN

      l_rownum := 13;

   end if;


      OPEN C1(l_start_date,l_rownum);

    LOOP

          FETCH C1 INTO v_start_date_tab(i),v_end_date_tab(i);

--     dbms_output.put_line('i: '||i);
          i := i+1;

          EXIT WHEN C1%NOTFOUND;

    END LOOP;

       CLOSE C1;

   pa_fin_plan_view_global.G_FP_VIEW_START_DATE1 :=  v_start_date_tab(0);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE2 :=  v_start_date_tab(1);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE3 :=  v_start_date_tab(2);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE4 :=  v_start_date_tab(3);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE5 :=  v_start_date_tab(4);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE6 :=  v_start_date_tab(5);

   pa_fin_plan_view_global.G_FP_VIEW_END_DATE1 :=  v_end_date_tab(0);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE2 :=  v_end_date_tab(1);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE3 :=  v_end_date_tab(2);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE4 :=  v_end_date_tab(3);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE5 :=  v_end_date_tab(4);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE6 :=  v_end_date_tab(5);
/*
dbms_output.put_line('global start date 1: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE1);
dbms_output.put_line('global start date 2: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE2);
dbms_output.put_line('global start date 3: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE3);
dbms_output.put_line('global start date 4: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE4);
dbms_output.put_line('global start date 5: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE5);
dbms_output.put_line('global start date 6: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE6);

dbms_output.put_line('global end date 1: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE1);
dbms_output.put_line('global end date 2: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE2);
dbms_output.put_line('global end date 3: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE3);
dbms_output.put_line('global end date 4: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE4);
dbms_output.put_line('global end date 5: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE5);
dbms_output.put_line('global end date 6: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE6);
*/


   if p_period_type = 'PA' THEN

   pa_fin_plan_view_global.G_FP_VIEW_START_DATE7 :=  v_start_date_tab(6);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE8 :=  v_start_date_tab(7);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE9 :=  v_start_date_tab(8);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE10 :=  v_start_date_tab(9);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE11 :=  v_start_date_tab(10);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE12 :=  v_start_date_tab(11);
   pa_fin_plan_view_global.G_FP_VIEW_START_DATE13 :=  v_start_date_tab(12);

   pa_fin_plan_view_global.G_FP_VIEW_END_DATE7 :=  v_end_date_tab(6);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE8 :=  v_end_date_tab(7);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE9 :=  v_end_date_tab(8);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE10 :=  v_end_date_tab(9);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE11 :=  v_end_date_tab(10);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE12 :=  v_end_date_tab(11);
   pa_fin_plan_view_global.G_FP_VIEW_END_DATE13 :=  v_end_date_tab(12);
/*
dbms_output.put_line('global start date 7: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE7);
dbms_output.put_line('global start date 8: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE8);
dbms_output.put_line('global start date 9: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE9);
dbms_output.put_line('global start date 10: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE10);
dbms_output.put_line('global start date 11: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE11);
dbms_output.put_line('global start date 12: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE12);
dbms_output.put_line('global start date 13: '||pa_fin_plan_view_global.G_FP_VIEW_START_DATE13);

dbms_output.put_line('global end date 7: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE7);
dbms_output.put_line('global end date 8: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE8);
dbms_output.put_line('global end date 9: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE9);
dbms_output.put_line('global end date 10: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE10);
dbms_output.put_line('global end date 11: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE11);
dbms_output.put_line('global end date 12: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE12);
dbms_output.put_line('global end date 13: '||pa_fin_plan_view_global.G_FP_VIEW_END_DATE13);
*/
   end if;


END pa_fp_set_periods;

PROCEDURE pa_fp_set_periods_nav ( p_direction	     	  IN 	VARCHAR2,
                                  p_num_of_periods   	  IN 	NUMBER,
                                  p_period_type		  IN    VARCHAR2,
                                  x_start_date            OUT   NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
                                  x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count             OUT   NOCOPY NUMBER,   --File.Sql.39 bug 4440895
                                  x_msg_data              OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_start_date	 DATE;
ll_start_date	 DATE;
l_period_type	 VARCHAR2(2);
l_rownum         NUMBER;
l_return_status  VARCHAR2(2);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(80);


CURSOR C_forward(l_start_date IN DATE) IS

      SELECT start_date
      FROM pa_orgfcst_periods_tmp_v
     WHERE start_date  > l_start_date
       order by start_date;


CURSOR C_backward(l_start_date IN DATE) IS

      SELECT start_date
      FROM pa_orgfcst_periods_tmp_v
     WHERE start_date < l_start_date
       order by start_date desc;

BEGIN

	l_rownum := p_num_of_periods;
        l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE1;
        l_period_type := p_period_type;

 IF p_direction = 'FORWARD' THEN

    OPEN C_forward(l_start_date);

  LOOP

     FETCH C_forward INTO ll_start_date;

     EXIT WHEN C_forward%NOTFOUND;
     EXIT WHEN C_forward%ROWCOUNT = l_rownum;

  END LOOP;

   CLOSE C_forward;



 ELSIF p_direction = 'BACKWARD' THEN

       OPEN C_backward(l_start_date);

  LOOP

     FETCH C_backward INTO ll_start_date;

     EXIT WHEN C_backward%NOTFOUND;
     EXIT WHEN C_backward%ROWCOUNT = l_rownum;

  END LOOP;

  CLOSE C_backward;

END IF;

--  dbms_output.put_line('The New Global start date is: '||ll_start_date);

 x_start_date := to_char(ll_start_date);

/*
 pa_fin_plan_view_global.pa_fp_set_periods (
                                       p_period_start_date =>ll_start_date,
                                       p_period_type       =>l_period_type,
                                       x_return_status     =>l_return_status,
                                       x_msg_count         =>l_msg_count,
                                       x_msg_data           =>l_msg_data
                            );
*/


END pa_fp_set_periods_nav;

PROCEDURE pa_fp_update_tables(  p_amount_type_code      IN      VARCHAR2,
                                p_amount_subtype_code   IN      VARCHAR2,
                                p_adj_reason_code       IN      VARCHAR2,
                                p_adj_comments          IN      VARCHAR2,
                                p_currency_code         IN      VARCHAR2,
				p_project_id            IN      NUMBER,
                                p_period1               IN      NUMBER,
                                p_period2               IN      NUMBER,
                                p_period3               IN      NUMBER,
                                p_period4               IN      NUMBER,
                                p_period5               IN      NUMBER,
                                p_period6               IN      NUMBER,
                                p_period7               IN      NUMBER,
                                p_period8               IN      NUMBER,
                                p_period9               IN      NUMBER,
                                p_period10              IN      NUMBER,
                                p_period11              IN      NUMBER,
                                p_period12              IN      NUMBER,
                                p_period13              IN      NUMBER,
                                p_period_type           IN      VARCHAR2,
                                p_budget_version_id     IN      NUMBER,
                                x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT     NOCOPY VARCHAR2  ) --File.Sql.39 bug 4440895
IS
l_msg_count		NUMBER;
l_msg_data              VARCHAR2(80);
l_project_id		NUMBER;
l_budget_version_id 	NUMBER;
l_budget_line_id	NUMBER;
l_amount_type_code  	VARCHAR2(30);
l_amount_subtype_code 	VARCHAR2(30);
l_period_amount	    	NUMBER;
l_period_name	    	VARCHAR2(30);
l_start_date		DATE;
l_end_date		DATE;
l_adj_rev_amount        NUMBER;
l_adj_cost_amount	NUMBER;
l_adj_util_amount	NUMBER;
l_adj_hc_amount		NUMBER;
l_ra_id_pl		NUMBER;
l_ra_id_tl		NUMBER;
l_task_id_pl		NUMBER;
l_task_id_tl		NUMBER;
l_adj_reason_code   	VARCHAR2(30);
l_adj_comments		VARCHAR2(240);
l_adj_element_id_pl     NUMBER;
l_adj_element_id_tl	NUMBER;
l_fin_plan_adj_line_id1  NUMBER;
l_fin_plan_adj_line_id2  NUMBER;
l_fin_plan_adj_line_id3  NUMBER;
l_fin_plan_adj_line_id4  NUMBER;
l_fin_plan_adj_line_id5  NUMBER;
l_fin_plan_adj_line_id6  NUMBER;
l_fin_plan_adj_line_id7  NUMBER;
l_fin_plan_adj_line_id8  NUMBER;
l_fin_plan_adj_line_id9  NUMBER;
l_fin_plan_adj_line_id10  NUMBER;
l_fin_plan_adj_line_id11  NUMBER;
l_fin_plan_adj_line_id12  NUMBER;
l_fin_plan_adj_line_id13  NUMBER;
l_return_status		VARCHAR2(2);
l_temp_id		NUMBER;
l_row_id		ROWID;
l_period_name1		VARCHAR2(30);
l_period_name2		VARCHAR2(30);
l_period_name3		VARCHAR2(30);
l_period_name4		VARCHAR2(30);
l_period_name5		VARCHAR2(30);
l_period_name6		VARCHAR2(30);
l_period_name7		VARCHAR2(30);
l_period_name8		VARCHAR2(30);
l_period_name9		VARCHAR2(30);
l_period_name10		VARCHAR2(30);
l_period_name11		VARCHAR2(30);
l_period_name12		VARCHAR2(30);
l_period_name13		VARCHAR2(30);
l_record_version_number NUMBER;
l_valid_flag		VARCHAR2(2);
l_err_msg_code		VARCHAR2(80);
l_period_profile_id     NUMBER;
l_currency_code		VARCHAR2(15);
l_currency_type         VARCHAR2(30);
l_amount_type_id        NUMBER;
l_amount_subtype_id     NUMBER;

l_element_id_pl 	NUMBER;
l_element_id_tl		NUMBER;
l_element_code		VARCHAR2(15);
ll_ra_id_pl		NUMBER;
ll_ra_id_tl		NUMBER;
l_res_code		VARCHAR2(15);

cursor_id integer;
l_stmt varchar2(10000);

colname1 varchar2(30);
colname2 varchar2(30);
colname3 varchar2(30);
colname4 varchar2(30);
colname5 varchar2(30);
colname6 varchar2(30);
colname7 varchar2(30);
colname8 varchar2(30);
colname9 varchar2(30);
colname10 varchar2(30);
colname11 varchar2(30);
colname12 varchar2(30);
colname13 varchar2(30);

col1 number := p_period1;
col2 number := p_period2;
col3 number := p_period3;
col4 number := p_period4;
col5 number := p_period5;
col6 number := p_period6;
col7 number := p_period7;
col8 number := p_period8;
col9 number := p_period9;
col10 number := p_period10;
col11 number := p_period11;
col12 number := p_period12;
col13 number := p_period13;

l_rows_upd number;

l_denorm_amount1_tl	NUMBER;
l_denorm_amount2_tl	NUMBER;
l_denorm_amount3_tl	NUMBER;
l_denorm_amount4_tl     NUMBER;
l_denorm_amount5_tl     NUMBER;
l_denorm_amount6_tl 	NUMBER;
l_denorm_amount7_tl     NUMBER;
l_denorm_amount8_tl     NUMBER;
l_denorm_amount9_tl     NUMBER;
l_denorm_amount10_tl     NUMBER;
l_denorm_amount11_tl     NUMBER;
l_denorm_amount12_tl     NUMBER;
l_denorm_amount13_tl     NUMBER;

l_denorm_amount1_pl     NUMBER;
l_denorm_amount2_pl     NUMBER;
l_denorm_amount3_pl     NUMBER;
l_denorm_amount4_pl     NUMBER;
l_denorm_amount5_pl     NUMBER;
l_denorm_amount6_pl     NUMBER;
l_denorm_amount7_pl     NUMBER;
l_denorm_amount8_pl     NUMBER;
l_denorm_amount9_pl     NUMBER;
l_denorm_amount10_pl     NUMBER;
l_denorm_amount11_pl     NUMBER;
l_denorm_amount12_pl     NUMBER;
l_denorm_amount13_pl     NUMBER;

l_rev1_pl 		NUMBER;
l_rev2_pl               NUMBER;
l_rev3_pl               NUMBER;
l_rev4_pl               NUMBER;
l_rev5_pl               NUMBER;
l_rev6_pl               NUMBER;
l_rev7_pl               NUMBER;
l_rev8_pl               NUMBER;
l_rev9_pl               NUMBER;
l_rev10_pl               NUMBER;
l_rev11_pl               NUMBER;
l_rev12_pl               NUMBER;
l_rev13_pl               NUMBER;

l_rev1_tl               NUMBER;
l_rev2_tl               NUMBER;
l_rev3_tl               NUMBER;
l_rev4_tl               NUMBER;
l_rev5_tl               NUMBER;
l_rev6_tl               NUMBER;
l_rev7_tl               NUMBER;
l_rev8_tl               NUMBER;
l_rev9_tl               NUMBER;
l_rev10_tl               NUMBER;
l_rev11_tl               NUMBER;
l_rev12_tl               NUMBER;
l_rev13_tl               NUMBER;


l_cost1_pl	        NUMBER;
l_cost2_pl              NUMBER;
l_cost3_pl              NUMBER;
l_cost4_pl              NUMBER;
l_cost5_pl              NUMBER;
l_cost6_pl              NUMBER;
l_cost7_pl              NUMBER;
l_cost8_pl              NUMBER;
l_cost9_pl              NUMBER;
l_cost10_pl              NUMBER;
l_cost11_pl              NUMBER;
l_cost12_pl              NUMBER;
l_cost13_pl              NUMBER;

l_cost1_tl              NUMBER;
l_cost2_tl              NUMBER;
l_cost3_tl              NUMBER;
l_cost4_tl              NUMBER;
l_cost5_tl              NUMBER;
l_cost6_tl              NUMBER;
l_cost7_tl              NUMBER;
l_cost8_tl              NUMBER;
l_cost9_tl              NUMBER;
l_cost10_tl              NUMBER;
l_cost11_tl              NUMBER;
l_cost12_tl              NUMBER;
l_cost13_tl              NUMBER;


l_mgn_per1_pl		NUMBER;
l_mgn_per2_pl           NUMBER;
l_mgn_per3_pl           NUMBER;
l_mgn_per4_pl           NUMBER;
l_mgn_per5_pl           NUMBER;
l_mgn_per6_pl           NUMBER;
l_mgn_per7_pl           NUMBER;
l_mgn_per8_pl           NUMBER;
l_mgn_per9_pl           NUMBER;
l_mgn_per10_pl           NUMBER;
l_mgn_per11_pl           NUMBER;
l_mgn_per12_pl           NUMBER;
l_mgn_per13_pl           NUMBER;

l_mgn_per1_tl           NUMBER;
l_mgn_per2_tl           NUMBER;
l_mgn_per3_tl           NUMBER;
l_mgn_per4_tl           NUMBER;
l_mgn_per5_tl           NUMBER;
l_mgn_per6_tl           NUMBER;
l_mgn_per7_tl           NUMBER;
l_mgn_per8_tl           NUMBER;
l_mgn_per9_tl           NUMBER;
l_mgn_per10_tl           NUMBER;
l_mgn_per11_tl           NUMBER;
l_mgn_per12_tl           NUMBER;
l_mgn_per13_tl           NUMBER;

l_number_of_periods     NUMBER;

BEGIN

x_return_status    := FND_API.G_RET_STS_SUCCESS;





pa_fin_plan_view_global.G_FP_ADJ_REASON_CODE := p_adj_reason_code;

l_budget_version_id := p_budget_version_id;
l_project_id := p_project_id;
l_adj_reason_code := p_adj_reason_code;
l_adj_comments := p_adj_comments;

/*
pa_fin_plan_view_global.pa_fp_set_orgfcst_version_id(
                                        p_orgfcst_version_id => l_budget_version_id,
                                        x_return_status => l_return_status,
                                        x_msg_count    => l_msg_count,
                                        x_msg_data   => l_msg_data
                                   );
*/

/* populate the glob temp table */
/*
	insert into PA_FP_ADJ_GLOB_TMP
			(AMOUNT_TYPE_CODE,
			 AMOUNT_SUBTYPE_CODE,
			 ADJUSTMENT_COMMENTS,
			 CURRENCY_CODE,
			 ADJUSTMENT_REASON_CODE,
			 BUDGET_VERSION_ID,
			 PROJECT_ID,
			 PERIOD1_AMOUNT,
			 PERIOD1_NAME,
			 PERIOD2_AMOUNT,
			 PERIOD2_NAME   ,
			 PERIOD3_AMOUNT,
			 PERIOD3_NAME   ,
			 PERIOD4_AMOUNT ,
			 PERIOD4_NAME  ,
                         PERIOD5_AMOUNT ,
                         PERIOD5_NAME   ,
                         PERIOD6_AMOUNT ,
                         PERIOD6_NAME   ,
			 PERIOD7_AMOUNT ,
			 PERIOD7_NAME   ,
 			 PERIOD8_AMOUNT ,
			 PERIOD8_NAME,
			 PERIOD9_AMOUNT,
			 PERIOD9_NAME   ,
			 PERIOD10_AMOUNT,
			 PERIOD10_NAME   ,
			 PERIOD11_AMOUNT ,
			 PERIOD11_NAME,
			 PERIOD12_AMOUNT,
			 PERIOD12_NAME   ,
			 PERIOD13_AMOUNT ,
 			 PERIOD13_NAME)
	select  p_amount_type_code,
		p_amount_subtype_code,
		p_adj_comments,
		p_currency_code,
		p_adj_reason_code,
		l_budget_version_id,
		p_project_id,
		p_period1,
		pn.period_name1,
                p_period2,
                pn.period_name2,
                p_period3,
                pn.period_name3,
                p_period4,
                pn.period_name4,
                p_period5,
                pn.period_name5,
                p_period6,
                pn.period_name6,
                p_period7,
                pn.period_name7,
                p_period8,
                pn.period_name8,
                p_period9,
                pn.period_name9,
                p_period10,
                pn.period_name10,
                p_period11,
                pn.period_name11,
                p_period12,
                pn.period_name12,
                p_period13,
                pn.period_name13
	from pa_fp_period_names_v pn;

*/

		select  period_name1,
			period_name2,
			period_name3,
			period_name4,
			period_name5,
			period_name6,
			period_name7,
                        period_name8,
                        period_name9,
                        period_name10,
                        period_name11,
                        period_name12,
			period_name13
		into	l_period_name1,
                        l_period_name2,
                        l_period_name3,
                        l_period_name4,
                        l_period_name5,
                        l_period_name6,
                        l_period_name7,
                        l_period_name8,
                        l_period_name9,
                        l_period_name10,
                        l_period_name11,
                        l_period_name12,
                        l_period_name13
		from pa_fp_period_names_v;

                select pp.number_of_periods
                  into l_number_of_periods
                 from  pa_proj_period_profiles pp,
                       pa_budget_versions pbv
                 where pbv.budget_version_id = l_budget_version_id
                   and pp.period_profile_id = pbv.period_profile_id;


		select  resource_assignment_id,task_id
                  into  l_ra_id_pl,l_task_id_pl
                  from  pa_resource_assignments
		where  	budget_version_id = l_budget_version_id
		and 	resource_assignment_type = 'PROJECT';

		select  resource_assignment_id,task_id
                  into  l_ra_id_tl,l_task_id_tl
                  from  pa_resource_assignments
                where    budget_version_id = l_budget_version_id
                  and     resource_assignment_type = 'OWN';

--	IF p_period_type = 'GL' Then
		    l_amount_type_code := p_amount_type_code;
		    l_amount_subtype_code:= p_amount_subtype_code;

/****************************************************************************************/
/*Update pa_fp_adj_elements*/
/***************************************************************************************/
begin
   	select adj_element_id
	into   l_adj_element_id_pl
	from   pa_fp_adj_elements
	where  resource_assignment_id = l_ra_id_pl
	and    adjustment_reason_code = l_adj_reason_code;

	pa_fp_adj_elements_pkg.
	  update_row(p_adj_element_id => l_adj_element_id_pl,
		     p_adjustment_comments => l_adj_comments,
		     x_return_status => l_return_status );

exception

        WHEN NO_DATA_FOUND THEN

	pa_fp_adj_elements_pkg.
	  insert_row(px_adj_element_id => l_adj_element_id_pl,
		     p_resource_assignment_id => l_ra_id_pl,
		     p_budget_version_id => l_budget_version_id,
		     p_project_id	=> l_project_id,
		     p_task_id		=> l_task_id_pl,
		     p_adjustment_reason_code =>l_adj_reason_code,
		     p_adjustment_comments => l_adj_comments,
		     x_row_id  => l_row_id,
		     x_return_status =>l_return_status );

end;

begin
        select adj_element_id
        into   l_adj_element_id_tl
        from   pa_fp_adj_elements
        where  resource_assignment_id = l_ra_id_tl
        and    adjustment_reason_code = l_adj_reason_code;

        pa_fp_adj_elements_pkg.
          update_row(p_adj_element_id => l_adj_element_id_tl,
                     p_adjustment_comments => l_adj_comments,
                     x_return_status => l_return_status );

exception

        WHEN NO_DATA_FOUND THEN

        pa_fp_adj_elements_pkg.
          insert_row(px_adj_element_id => l_adj_element_id_tl,
                     p_resource_assignment_id => l_ra_id_tl,
                     p_budget_version_id => l_budget_version_id,
                     p_project_id       => l_project_id,
                     p_task_id          => l_task_id_tl,
                     p_adjustment_reason_code =>l_adj_reason_code,
                     p_adjustment_comments => l_adj_comments,
                     x_row_id  => l_row_id,
                     x_return_status =>l_return_status );

end;


/****************************************************************************************/
/*End of Update pa_fp_adj_elements*/
/***************************************************************************************/


/****************************************************************************************/
/*Update pa_fin_plan_adj_lines*/
/***************************************************************************************/


	/*for period 1*/

    if l_period_name1 is not null then

    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE1;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE1;
        l_period_amount := p_period1;
        l_period_name := l_period_name1;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id1
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
        and    adj_element_id = l_adj_element_id_tl;

	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 1*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
			   p_project_id => l_project_id,
                           p_adj_element_id => l_adj_element_id_tl,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;


      END;

     end if;

        /*end begin for period 1*/


	/*for period 2*/
    if l_period_name2 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE2;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE2;
        l_period_amount := p_period2;
        l_period_name := l_period_name2;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id2
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;

	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 1*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;

   end if;
        /*end begin for period 2*/


	/*for period 3*/
    if l_period_name3 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE3;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE3;
        l_period_amount := p_period3;
        l_period_name := l_period_name3;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id3
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;

	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 3*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
			   p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 3*/
      end if;


	/*for period 4*/
    if l_period_name4 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE4;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE4;
        l_period_amount := p_period4;
        l_period_name := l_period_name4;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id4
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
        and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 4*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 4*/

     end if;
	/*for period 5*/
    if l_period_name5 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE5;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE5;
        l_period_amount := p_period5;
        l_period_name := l_period_name5;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id5
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
        and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 5*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 5*/
      end if;

	/*for period 6*/
    if l_period_name6 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE6;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE6;
        l_period_amount := p_period6;
        l_period_name := l_period_name6;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id6
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 6*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



     END;
        /*end begin for period 6*/
     end if;

 IF p_period_type = 'PA' THEN

   /*for period 7*/
    if l_period_name7 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE7;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE7;
        l_period_amount := p_period7;
        l_period_name := l_period_name7;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id7
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
        and    adj_element_id = l_adj_element_id_tl;

	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 7*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
			   p_project_id => l_project_id,
                           p_adj_element_id => l_adj_element_id_tl,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 7*/
      end if;

	/*for period 8*/
    if l_period_name8 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE8;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE8;
        l_period_amount := p_period8;
        l_period_name := l_period_name8;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id8
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;

	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 8*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 8*/
      end if;

	/*for period 9*/
    if l_period_name9 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE9;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE9;
        l_period_amount := p_period9;
        l_period_name := l_period_name9;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id9
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;

	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 9*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
			   p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 9*/
      end if;


	/*for period 10*/
    if l_period_name10 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE10;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE10;
        l_period_amount := p_period10;
        l_period_name := l_period_name10;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id10
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
        and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 10*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 10*/
      end if;


	/*for period 11*/
    if l_period_name11 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE11;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE11;
        l_period_amount := p_period11;
        l_period_name := l_period_name11;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id11
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
        and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 11*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 11*/
      end if;

	/*for period 12*/
    if l_period_name12 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE12;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE12;
        l_period_amount := p_period12;
        l_period_name := l_period_name12;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id12
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 12*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



     END;
        /*end begin for period 12*/
     end if;

     	/*for period 13*/
    if l_period_name13 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE13;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE13;
        l_period_amount := p_period13;
        l_period_name := l_period_name13;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id13
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_tl
	and    adj_element_id = l_adj_element_id_tl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN

	/*for task level res asg ID*/

	/* for period 13*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_tl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_tl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_tl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_tl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_tl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



     END;
        /*end begin for period 13*/

     end if;

 END IF;
 /* END IF PA*/






/*For Project Level Res Asg Id*/

/*refresh the local variables*/
l_fin_plan_adj_line_id1 := null;
l_fin_plan_adj_line_id2 := null;
l_fin_plan_adj_line_id3 := null;
l_fin_plan_adj_line_id4 := null;
l_fin_plan_adj_line_id5 := null;
l_fin_plan_adj_line_id6 := null;
l_fin_plan_adj_line_id7 := null;
l_fin_plan_adj_line_id8 := null;
l_fin_plan_adj_line_id9 := null;
l_fin_plan_adj_line_id10 := null;
l_fin_plan_adj_line_id11 := null;
l_fin_plan_adj_line_id12 := null;
l_fin_plan_adj_line_id13 := null;



	/*for period 1*/

    if l_period_name1 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE1;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE1;
        l_period_amount := p_period1;
        l_period_name := l_period_name1;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id1
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 1*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id1,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 1*/
      end if;

	/*for period 2*/
    if l_period_name2 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE2;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE2;
        l_period_amount := p_period2;
        l_period_name := l_period_name2;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id2
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then


        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 1*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id2,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 2*/
      end if;

	/*for period 3*/
    if l_period_name3 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE3;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE3;
        l_period_amount := p_period3;
        l_period_name := l_period_name3;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id3
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 3*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id3,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 3*/
    end if;


	/*for period 4*/
    if l_period_name4 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE4;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE4;
        l_period_amount := p_period4;
        l_period_name := l_period_name4;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id4
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 4*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id4,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;

   end if;
        /*end begin for period 4*/


	/*for period 5*/
    if l_period_name5 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE5;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE5;
        l_period_amount := p_period5;
        l_period_name := l_period_name5;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id5
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 5*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id5,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;

    end if;
        /*end begin for period 5*/


	/*for period 6*/
    if l_period_name6 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE6;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE6;
        l_period_amount := p_period6;
        l_period_name := l_period_name6;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id6
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
	and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 6*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id6,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



     END;
        /*end begin for period 6*/
  end if;

  IF p_period_type = 'PA' THEN

  	/*for period 7*/
    if l_period_name7 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE7;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE7;
        l_period_amount := p_period7;
        l_period_name := l_period_name7;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id7
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 7*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id7,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 7*/
   end if;

	/*for period 8*/
    if l_period_name8 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE8;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE8;
        l_period_amount := p_period8;
        l_period_name := l_period_name8;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id8
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then


        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 8*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id8,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 8*/
    end if;

	/*for period 9*/
    if l_period_name9 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE9;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE9;
        l_period_amount := p_period9;
        l_period_name := l_period_name9;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id9
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 9*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id9,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 9*/
    end if;


	/*for period 10*/
    if l_period_name10 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE10;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE10;
        l_period_amount := p_period10;
        l_period_name := l_period_name10;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id10
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 10*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id10,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 10*/
    end if;

	/*for period 11*/
    if l_period_name11 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE11;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE11;
        l_period_amount := p_period11;
        l_period_name := l_period_name11;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id11
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
        and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 11*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id11,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



      END;
        /*end begin for period 11*/
    end if;

	/*for period 12*/
    if l_period_name12 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE12;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE12;
        l_period_amount := p_period12;
        l_period_name := l_period_name12;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id12
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
	and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 12*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id12,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



     END;
        /*end begin for period 12*/
    end if;

	/*for period 13*/
    if l_period_name13 is not null then
    begin

	l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE13;
        l_end_date := pa_fin_plan_view_global.G_FP_VIEW_END_DATE13;
        l_period_amount := p_period13;
        l_period_name := l_period_name13;

        select FIN_PLAN_ADJ_LINE_ID
        into   l_fin_plan_adj_line_id13
        from   pa_fin_plan_adj_lines
        where  budget_version_id = l_budget_version_id
	and    period_name=l_period_name
	and    resource_assignment_id = l_ra_id_pl
	and    adj_element_id = l_adj_element_id_pl;


	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_revenue_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;


	 IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_utilization_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                update_row(p_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_head_count_adjustment => l_period_amount,
                           x_return_status  => l_return_status);

          END IF;




    exception
  	WHEN NO_DATA_FOUND THEN


	/* for period 13*/



	 IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then



	PA_FP_FIN_PLAN_ADJ_LINES_PKG.
		insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
			   p_task_id => l_task_id_pl,
		           p_budget_version_id => l_budget_version_id,
			   p_resource_assignment_id => l_ra_id_pl,
			   p_period_name => l_period_name,
			   p_start_date => l_start_date,
			   p_end_date  =>  l_end_date,
			   p_revenue_adjustment => l_period_amount,
			   x_row_id      => l_row_id,
			   x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_burdened_cost_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_utilization_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;

	 IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then



        PA_FP_FIN_PLAN_ADJ_LINES_PKG.
                insert_row(px_fin_plan_adj_line_id => l_fin_plan_adj_line_id13,
                           p_adj_element_id => l_adj_element_id_pl,
			   p_project_id => l_project_id,
                           p_task_id => l_task_id_pl,
                           p_budget_version_id => l_budget_version_id,
                           p_resource_assignment_id => l_ra_id_pl,
                           p_period_name => l_period_name,
                           p_start_date => l_start_date,
                           p_end_date  =>  l_end_date,
                           p_head_count_adjustment => l_period_amount,
                           x_row_id      => l_row_id,
                           x_return_status  => l_return_status);

          END IF;



     END;
        /*end begin for period 13*/
  end if;


  END IF;

  /* END IF 'PA'*/



/****************************************************************************************/
/*End of update pa_fin_plan_adj_lines*/
/***************************************************************************************/




/********************************************************************************************/
/* update pa_budget_lines */
/********************************************************************************************/

---->Bug 4947912. In the code below that updates pa_budget_lines did the following changes
---->Handled the no_data_found exception on the Selects on pa_budget_lines
---->Call to pa_fp_budget_lines_pkg.Update_Row is made only if the budget line exists.



       /*  for period1  */

            if l_period_name1 is not null then
	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE1;
/* Bug fix 2891111*/
/* April 07, 2003*/
--Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
               Exception
               When NO_DATA_FOUND Then
                 l_budget_line_id := NULL;
               End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
               --Bug 4947912
               IF  l_budget_line_id IS NOT NULL THEN
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
               End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
                --Bug 4947912
                IF  l_budget_line_id IS NOT NULL THEN
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
                --Bug 4947912
                IF  l_budget_line_id IS NOT NULL THEN
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
                --Bug 4947912
                IF  l_budget_line_id IS NOT NULL THEN
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;

                End IF;


                         l_denorm_amount1_pl:=l_period_amount;
           end if;

          /* for period 2 */


              if l_period_name2 is not null then
	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE2;

/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
              When NO_DATA_FOUND then
              l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

          If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
          End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;


                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;

                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;


                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;

                End IF;

               l_denorm_amount2_pl:=l_period_amount;

           end if;

		 /* for period 3 */

	    if l_period_name3 is not null then
               l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE3;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
              When NO_DATA_FOUND then
               l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;

                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;

                End IF;

               l_denorm_amount3_pl:=l_period_amount;

	end if;
		/* for Period 4 */


        if l_period_name4 is not null then
		 l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE4;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                    --Bug 4947912
                    If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                    End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                    --Bug 4947912
                    If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                    End if;

                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                    --Bug 4947912
                    If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                    End if;

                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                    --Bug 4947912
                    If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                    End if;

                End IF;


               l_denorm_amount4_pl:=l_period_amount;

	end if;
	      /* for period 5 */

	if l_period_name5 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE5;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND Then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                   --Bug 4947912
                   If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                   End If;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                   --Bug 4947912
                   If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                   End If;

                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                   --Bug 4947912
                   If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                    End if;

                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                   --Bug 4947912
                   If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                   End if;
                End IF;

               l_denorm_amount5_pl:=l_period_amount;

	end if;
		      /* for period 6 */

	if l_period_name6 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE6;
/* Bug fix 2891111*/
/* April 07, 2003*/
             --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
               Exception
                When NO_DATA_FOUND then
                 l_budget_line_id := NULL;
               End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

               --Bug 4947912
               If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
               End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

               --Bug 4947912
               If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
               End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

               --Bug 4947912
               If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
               End if;

                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

               --Bug 4947912
               If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
               End if;
                End IF;

               l_denorm_amount6_pl:=l_period_amount;
	end if;

       IF p_period_type = 'PA' THEN

               /*  for period 7  */
	if l_period_name7 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE7;
/* Bug fix 2891111*/
/* April 07, 2003*/
             --Bug 4947912
             Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
             Exception
              When NO_DATA_FOUND then
               l_budget_line_id := NULL;
             End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

             --Bug 4947912
             If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
             End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
             --Bug 4947912
             If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
             End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
             --Bug 4947912
             If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
             End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
             --Bug 4947912
             If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
             End if;
                End IF;


                         l_denorm_amount7_pl:=l_period_amount;

	   end if;
          /* for period 8 */

	if l_period_name8 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE8;
/* Bug fix 2891111*/
/* April 07, 2003*/
            --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND Then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

            --Bug 4947912
             If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
             End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

            --Bug 4947912
             If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
             End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

            --Bug 4947912
             If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
              End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

            --Bug 4947912
             If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
             End if;
                End IF;

               l_denorm_amount8_pl:=l_period_amount;

	end if;
		 /* for period 9 */

	if l_period_name9 is not null then
               l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE9;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND Then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

               l_denorm_amount9_pl:=l_period_amount;

	end if;
		/* for Period 10 */

	if l_period_name10 is not null then

		 l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE10;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;


               l_denorm_amount10_pl:=l_period_amount;

	end if;
	      /* for period 11 */

	if l_period_name11 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE11;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
               Exception
                When NO_DATA_FOUND Then
                 l_budget_line_id := NULL;
               End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;
                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

               l_denorm_amount11_pl:=l_period_amount;

	end if;
		      /* for period 12 */

	if l_period_name12 is not null then

             /*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE12;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

               l_denorm_amount12_pl:=l_period_amount;
	end if;
     /* for period 13*/

	if l_period_name13 is not null then

      /*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE13;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_pl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_pl
                      and start_date = l_start_date;

                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

               l_denorm_amount13_pl:=l_period_amount;

 	end if;
       END IF;
       /* END IF 'PA'*/




	/*for l_ra_id_tl own_task level resource_assignment_id*/

       /*  for period1  */

	 if l_period_name1 is not null then

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE1;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
                --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
                --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

               l_denorm_amount1_tl:=l_period_amount;
	end if;
          /* for period 2 */

	if l_period_name2 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE2;
/* Bug fix 2891111*/
/* April 07, 2003*/
            --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		l_denorm_amount2_tl:=l_period_amount;
	end if;
		 /* for period 3 */

	if l_period_name3 is not null then

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE3;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                l_denorm_amount3_tl:=l_period_amount;
	end if;
		/* for Period 4 */

	if l_period_name4 is not null then

		 l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE4;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
                When NO_DATA_FOUND then
                  l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                  select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                l_denorm_amount4_tl:=l_period_amount;
	end if;
		      /* for period 5 */

	if l_period_name5 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE5;

/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                  select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                l_denorm_amount5_tl:=l_period_amount;
	end if;
		      /* for period 6 */

	if l_period_name6 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE6;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
                When NO_DATA_FOUND then
                  l_budget_line_id := NULL;
               End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                  select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                                l_denorm_amount6_tl:=l_period_amount;
	end if;
          IF p_period_type = 'PA' THEN


           /*  for period 7  */

        if l_period_name7 is not null then
              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE7;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND Then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

               l_denorm_amount7_tl:=l_period_amount;
	end if;
          /* for period 8 */

	if l_period_name8 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE8;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
                When NO_DATA_FOUND then
                  l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		l_denorm_amount8_tl:=l_period_amount;
	end if;
		 /* for period 9 */

	if l_period_name9 is not null then

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE9;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/

		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                l_denorm_amount9_tl:=l_period_amount;
	end if;
		/* for Period 10 */

	if l_period_name10 is not null then

		 l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE10;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                  select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                l_denorm_amount10_tl:=l_period_amount;
	end if;
		      /* for period 11 */

	if l_period_name11 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE11;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND THEN
                l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                  select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;


		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                   select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                l_denorm_amount11_tl:=l_period_amount;
	end if;
		      /* for period 12 */

	if l_period_name12 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE12;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                 l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                  select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                                l_denorm_amount12_tl:=l_period_amount;
	end if;
	      /* for period 13 */

	if l_period_name13 is not null then

	/*for l_ra_id_pl project level resource_assignment_id*/

              l_start_date := pa_fin_plan_view_global.G_FP_VIEW_START_DATE13;
/* Bug fix 2891111*/
/* April 07, 2003*/
              --Bug 4947912
              Begin
              select budget_line_id
                into l_budget_line_id
                from pa_budget_lines
               where resource_assignment_id = l_ra_id_tl
                 and start_date = l_start_date
                 and txn_currency_code = p_currency_code;
              Exception
               When NO_DATA_FOUND then
                 l_budget_line_id := NULL;
              End;
/* Bug fix 2891111*/
/* April 07, 2003*/


		IF l_amount_subtype_code = 'REVENUE_ADJUSTMENTS' then

                   select sum(nvl(revenue_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
			 Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_revenue_adj => l_period_amount,
				    x_return_status =>l_return_status);
                End if;

		End IF;

		IF l_amount_subtype_code = 'COST_ADJUSTMENTS' then

                   select sum(nvl(burdened_cost_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
                pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_cost_adj => l_period_amount,
			            x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' then

                  select sum(nvl(head_count_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_head_count_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

		IF l_amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' then

                   select sum(nvl(utilization_adjustment,0))
                     into l_period_amount
                     from pa_fin_plan_adj_lines
                    where resource_assignment_id = l_ra_id_tl
                      and start_date = l_start_date;
              --Bug 4947912
                If l_budget_line_id is not null then
		pa_fp_budget_lines_pkg.
                        Update_Row(p_budget_line_id =>l_budget_line_id,
                                    p_utilization_adj => l_period_amount,
                                    x_return_status =>l_return_status);
                End if;
                End IF;

                                l_denorm_amount13_tl:=l_period_amount;
		end if;
        END IF;
        /* END IF 'PA'*/



/****************************************************************************************/
/*End of update pa_budget_lines*/
/***************************************************************************************/



--        End IF;
/*End IF 'GL'*/


/****************************************************************************************/
/*Begin of update pa_resource_assignments*/
/***************************************************************************************/



begin
         /*for task level resource_assignment_id*/

         select sum(nvl(REVENUE_ADJ,0)),    sum(nvl(COST_ADJ,0)),
		sum(nvl(UTILIZATION_ADJ,0)),
		round(sum(nvl(HEAD_COUNT_ADJ,0)),0)
         into   l_adj_rev_amount,l_adj_cost_amount,
                l_adj_util_amount,l_adj_hc_amount
         from   pa_budget_lines
         where resource_assignment_id = l_ra_id_tl;


        PA_FP_RESOURCE_ASSIGNMENTS_PKG.
                update_row(
                           p_resource_assignment_id => l_ra_id_tl,
                           p_total_revenue_adj => l_adj_rev_amount,
                           p_total_cost_adj => l_adj_cost_amount,
                           p_total_utilization_adj => l_adj_util_amount,
                           p_total_head_count_adj => l_adj_hc_amount,
                           x_return_status  => l_return_status);


     /*for project level resource_assignment_id*/

         select sum(nvl(REVENUE_ADJ,0)),    sum(nvl(COST_ADJ,0)),
		sum(nvl(UTILIZATION_ADJ,0)),
		round(sum(nvl(HEAD_COUNT_ADJ,0)),0)
         into   l_adj_rev_amount,l_adj_cost_amount,
                l_adj_util_amount,l_adj_hc_amount
         from   pa_budget_lines
         where resource_assignment_id = l_ra_id_pl;


        PA_FP_RESOURCE_ASSIGNMENTS_PKG.
                update_row(
                           p_resource_assignment_id => l_ra_id_pl,
                           p_total_revenue_adj => l_adj_rev_amount,
                           p_total_cost_adj => l_adj_cost_amount,
                           p_total_utilization_adj => l_adj_util_amount,
                           p_total_head_count_adj => l_adj_hc_amount,
                           x_return_status  => l_return_status);




end;


/****************************************************************************************/
/*End of update pa_resource_assignments*/
/***************************************************************************************/



/****************************************************************************************/
/*Begin of update pa_budget_versions*/
/***************************************************************************************/



begin
         l_record_version_number := pa_fin_plan_utils.
                                       Retrieve_Record_Version_Number(l_budget_version_id);

         pa_fin_plan_utils.Check_Record_Version_Number
    		(p_unique_index             => l_budget_version_id,
     		 p_record_version_number    => l_record_version_number,
     		 x_valid_flag               => l_valid_flag,
     		 x_return_status            => l_return_status,
     		 x_error_msg_code           => l_err_msg_code);



      if l_valid_flag = 'Y' then

         select sum(nvl(REVENUE_ADJ,0)),    sum(nvl(COST_ADJ,0)),
                sum(nvl(UTILIZATION_ADJ,0))/l_number_of_periods,
                round(sum(nvl(HEAD_COUNT_ADJ,0))/l_number_of_periods,0)
         into   l_adj_rev_amount,l_adj_cost_amount,
                l_adj_util_amount,l_adj_hc_amount
         from   pa_budget_lines
         where resource_assignment_id = l_ra_id_pl;


        PA_FP_BUDGET_VERSIONS_PKG.
                update_row(
                           p_budget_version_id => l_budget_version_id,
                           p_total_revenue_adj => l_adj_rev_amount,
                           p_total_cost_adj => l_adj_cost_amount,
                           p_total_utilization_adj => l_adj_util_amount,
                           p_total_head_count_adj => l_adj_hc_amount,
                           x_return_status  => l_return_status
                          );

      else

         PA_UTILS.Add_message ( p_app_short_name => 'PA',
                                p_msg_name => l_err_msg_code);
       x_return_status := FND_API.G_RET_STS_ERROR;


      end if;


end;





/****************************************************************************************/
/*End of update pa_budget_versions*/
/***************************************************************************************/









/****************************************************************************************/
/*Begin of update pa_proj_periods_denorm*/
/***************************************************************************************/

BEGIN


   select nvl(period_col_name1,'period_amount40'),
          nvl(period_col_name2,'period_amount41'),
          nvl(period_col_name3,'period_amount42'),
          nvl(period_col_name4,'period_amount43'),
          nvl(period_col_name5,'period_amount44'),
          nvl(period_col_name6,'period_amount45'),
          nvl(period_col_name7,'period_amount46'),
          nvl(period_col_name8,'period_amount47'),
          nvl(period_col_name9,'period_amount48'),
          nvl(period_col_name10,'period_amount49'),
          nvl(period_col_name11,'period_amount50'),
          nvl(period_col_name12,'period_amount51'),
          nvl(period_col_name13,'period_amount52')
    into colname1,colname2,colname3,colname4,colname5,colname6,
         colname7,colname8,colname9,colname10,colname11,colname12,colname13
   from   pa_fp_period_col_names_v;


   select period_profile_id
   into  l_period_profile_id
   from  pa_budget_versions
   where budget_version_id = l_budget_version_id;

   select amount_type_id
   into   l_amount_type_id
   from   pa_amount_types_vl
   where  amount_type_code = l_amount_type_code;

   select amount_type_id
   into   l_amount_subtype_id
   from   pa_amount_types_vl
   where  amount_type_code = l_amount_subtype_code;

   l_currency_code := p_currency_code;
   l_currency_type := 'PROJ_FUNCTIONAL';
   l_element_code := 'ADJ_ELEMENTS';
   l_res_code     := 'RES_ASSIGNMENT';

if p_period_type = 'GL' THEN

/* for project level res id */

  begin

    select object_id
     into  l_element_id_pl
     from  pa_proj_periods_denorm
    where  object_type_code = 'ADJ_ELEMENTS'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = -1
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_adj_element_id_pl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-1);
   dbms_sql.bind_variable(cursor_id,':elementId',l_element_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-1);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_adj_element_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


   /* for task level res id */

    begin

    select object_id
     into  l_element_id_tl
     from  pa_proj_periods_denorm
    where  object_type_code = 'ADJ_ELEMENTS'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = -2
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_adj_element_id_tl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-2);
   dbms_sql.bind_variable(cursor_id,':elementId',l_element_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-2);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_adj_element_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


/*update denorm from budget_lines and resource assignment*/

/* for project level res id */

  begin

    select object_id
     into  ll_ra_id_pl
     from  pa_proj_periods_denorm
    where  object_type_code = 'RES_ASSIGNMENT'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = l_ra_id_pl
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_ra_id_pl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                 and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_pl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_pl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_pl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_pl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_pl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_pl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',ll_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);

   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_pl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_pl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_pl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_pl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_pl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_pl);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


   /* for task level res id */

    begin

    select object_id
     into  ll_ra_id_tl
     from  pa_proj_periods_denorm
    where  object_type_code = 'RES_ASSIGNMENT'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = l_ra_id_tl
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_ra_id_tl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_tl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_tl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_tl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_tl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_tl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_tl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',ll_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);

   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_tl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_tl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_tl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_tl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_tl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_tl);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


/* Need to update the Margin and Margin% Also*/


/* for project level res id */

 /* Get Revenue */

  begin

		select period1,period2,period3,period4,period5,period6
		into   l_rev1_pl,l_rev2_pl,l_rev3_pl,l_rev4_pl,l_rev5_pl,l_rev6_pl
		from   pa_fp_sum_pv_v
		where  resource_assignment_id = l_ra_id_pl
		and    AMOUNT_TYPE_CODE = 'REVENUE';

/*
   l_stmt := 'select sum(nvl('||colname1||',0)),'||
                    'sum(nvl('||colname2||',0)),'||
                    'sum(nvl('||colname3||',0)),'||
                    'sum(nvl('||colname4||',0)),'||
                    'sum(nvl('||colname5||',0)),'||
                    'sum(nvl('||colname6||',0))'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);


   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','REVENUE');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);

   dbms_sql.define_column(cursor_id,1,l_rev1_pl);
   dbms_sql.define_column(cursor_id,2,l_rev2_pl);
   dbms_sql.define_column(cursor_id,3,l_rev3_pl);
   dbms_sql.define_column(cursor_id,4,l_rev4_pl);
   dbms_sql.define_column(cursor_id,5,l_rev5_pl);
   dbms_sql.define_column(cursor_id,6,l_rev6_pl);


    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;

   dbms_sql.column_value(cursor_id,1,l_rev1_pl);
   dbms_sql.column_value(cursor_id,2,l_rev2_pl);
   dbms_sql.column_value(cursor_id,3,l_rev3_pl);
   dbms_sql.column_value(cursor_id,4,l_rev4_pl);
   dbms_sql.column_value(cursor_id,5,l_rev5_pl);
   dbms_sql.column_value(cursor_id,6,l_rev6_pl);


END LOOP;

   dbms_sql.close_cursor(cursor_id);

*/
  end;

 /* Get Cost */

    begin


                select period1,period2,period3,period4,period5,period6
                into   l_cost1_pl,l_cost2_pl,l_cost3_pl,l_cost4_pl,l_cost5_pl,l_cost6_pl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'COST';

/*
   l_stmt := 'select sum(nvl('||colname1||',0)),'||
                    'sum(nvl('||colname2||',0)),'||
                    'sum(nvl('||colname3||',0)),'||
                    'sum(nvl('||colname4||',0)),'||
                    'sum(nvl('||colname5||',0)),'||
                    'sum(nvl('||colname6||',0))'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','COST');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);



   dbms_sql.define_column(cursor_id,1,l_cost1_pl);
   dbms_sql.define_column(cursor_id,2,l_cost2_pl);
   dbms_sql.define_column(cursor_id,3,l_cost3_pl);
   dbms_sql.define_column(cursor_id,4,l_cost4_pl);
   dbms_sql.define_column(cursor_id,5,l_cost5_pl);
   dbms_sql.define_column(cursor_id,6,l_cost6_pl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;

   dbms_sql.column_value(cursor_id,1,l_cost1_pl);
   dbms_sql.column_value(cursor_id,2,l_cost2_pl);
   dbms_sql.column_value(cursor_id,3,l_cost3_pl);
   dbms_sql.column_value(cursor_id,4,l_cost4_pl);
   dbms_sql.column_value(cursor_id,5,l_cost5_pl);
   dbms_sql.column_value(cursor_id,6,l_cost6_pl);


END LOOP;

   dbms_sql.close_cursor(cursor_id);
*/

  end;



/* Now populate MARGIN */

  begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6'||'
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',(l_rev1_pl-l_cost1_pl));
   dbms_sql.bind_variable(cursor_id,':n2',(l_rev2_pl-l_cost2_pl));
   dbms_sql.bind_variable(cursor_id,':n3',(l_rev3_pl-l_cost3_pl));
   dbms_sql.bind_variable(cursor_id,':n4',(l_rev4_pl-l_cost4_pl));
   dbms_sql.bind_variable(cursor_id,':n5',(l_rev5_pl-l_cost5_pl));
   dbms_sql.bind_variable(cursor_id,':n6',(l_rev6_pl-l_cost6_pl));

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;

/* Now populate the MARGIN% */

    begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6'||'
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;


   if l_rev1_pl = 0 then
      l_mgn_per1_pl := 0;
   else
      l_mgn_per1_pl := 100*(l_rev1_pl-l_cost1_pl)/l_rev1_pl;
   end if;

   if l_rev2_pl = 0 then
      l_mgn_per2_pl := 0;
   else
      l_mgn_per2_pl := 100*(l_rev2_pl-l_cost2_pl)/l_rev2_pl;
   end if;

   if l_rev3_pl = 0 then
      l_mgn_per3_pl := 0;
   else
      l_mgn_per3_pl := 100*(l_rev3_pl-l_cost3_pl)/l_rev3_pl;
   end if;

   if l_rev4_pl = 0 then
      l_mgn_per4_pl := 0;
   else
      l_mgn_per4_pl := 100*(l_rev4_pl-l_cost4_pl)/l_rev4_pl;
   end if;

   if l_rev5_pl = 0 then
      l_mgn_per5_pl := 0;
   else
      l_mgn_per5_pl := 100*(l_rev5_pl-l_cost5_pl)/l_rev5_pl;
   end if;

   if l_rev6_pl = 0 then
      l_mgn_per6_pl := 0;
   else
      l_mgn_per6_pl := 100*(l_rev6_pl-l_cost6_pl)/l_rev6_pl;
   end if;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_mgn_per1_pl);
   dbms_sql.bind_variable(cursor_id,':n2',l_mgn_per2_pl);
   dbms_sql.bind_variable(cursor_id,':n3',l_mgn_per3_pl);
   dbms_sql.bind_variable(cursor_id,':n4',l_mgn_per4_pl);
   dbms_sql.bind_variable(cursor_id,':n5',l_mgn_per5_pl);
   dbms_sql.bind_variable(cursor_id,':n6',l_mgn_per6_pl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;

/* for task level res id */

 /* Get Revenue */
  begin

                select period1,period2,period3,period4,period5,period6
                into   l_rev1_tl,l_rev2_tl,l_rev3_tl,l_rev4_tl,l_rev5_tl,l_rev6_tl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'REVENUE';

/*
   l_stmt := 'select sum('||colname1||'),'||
                    'sum('||colname2||'),'||
                    'sum('||colname3||'),'||
                    'sum('||colname4||'),'||
                    'sum('||colname5||'),'||
                    'sum('||colname6||')'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','REVENUE');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);



   dbms_sql.define_column(cursor_id,1,l_rev1_tl);
   dbms_sql.define_column(cursor_id,2,l_rev2_tl);
   dbms_sql.define_column(cursor_id,3,l_rev3_tl);
   dbms_sql.define_column(cursor_id,4,l_rev4_tl);
   dbms_sql.define_column(cursor_id,5,l_rev5_tl);
   dbms_sql.define_column(cursor_id,6,l_rev6_tl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;


   dbms_sql.column_value(cursor_id,1,l_rev1_tl);
   dbms_sql.column_value(cursor_id,2,l_rev2_tl);
   dbms_sql.column_value(cursor_id,3,l_rev3_tl);
   dbms_sql.column_value(cursor_id,4,l_rev4_tl);
   dbms_sql.column_value(cursor_id,5,l_rev5_tl);
   dbms_sql.column_value(cursor_id,6,l_rev6_tl);




END LOOP;

   dbms_sql.close_cursor(cursor_id);
*/

  end;

 /* Get Cost */

    begin

                select period1,period2,period3,period4,period5,period6
                into   l_cost1_tl,l_cost2_tl,l_cost3_tl,l_cost4_tl,l_cost5_tl,l_cost6_tl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'COST';

/*
   l_stmt := 'select sum('||colname1||'),'||
                    'sum('||colname2||'),'||
                    'sum('||colname3||'),'||
                    'sum('||colname4||'),'||
                    'sum('||colname5||'),'||
                    'sum('||colname6||')'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','COST');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


   dbms_sql.define_column(cursor_id,1,l_cost1_tl);
   dbms_sql.define_column(cursor_id,2,l_cost2_tl);
   dbms_sql.define_column(cursor_id,3,l_cost3_tl);
   dbms_sql.define_column(cursor_id,4,l_cost4_tl);
   dbms_sql.define_column(cursor_id,5,l_cost5_tl);
   dbms_sql.define_column(cursor_id,6,l_cost6_tl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;

   dbms_sql.column_value(cursor_id,1,l_cost1_tl);
   dbms_sql.column_value(cursor_id,2,l_cost2_tl);
   dbms_sql.column_value(cursor_id,3,l_cost3_tl);
   dbms_sql.column_value(cursor_id,4,l_cost4_tl);
   dbms_sql.column_value(cursor_id,5,l_cost5_tl);
   dbms_sql.column_value(cursor_id,6,l_cost6_tl);


END LOOP;
   dbms_sql.close_cursor(cursor_id);

*/
  end;



/* Now populate MARGIN */

  begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6'||'
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',(l_rev1_tl-l_cost1_tl));
   dbms_sql.bind_variable(cursor_id,':n2',(l_rev2_tl-l_cost2_tl));
   dbms_sql.bind_variable(cursor_id,':n3',(l_rev3_tl-l_cost3_tl));
   dbms_sql.bind_variable(cursor_id,':n4',(l_rev4_tl-l_cost4_tl));
   dbms_sql.bind_variable(cursor_id,':n5',(l_rev5_tl-l_cost5_tl));
   dbms_sql.bind_variable(cursor_id,':n6',(l_rev6_tl-l_cost6_tl));

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;

/* Now populate the MARGIN% */

    begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6'||'
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;


   if l_rev1_tl = 0 then
      l_mgn_per1_tl := 0;
   else
      l_mgn_per1_tl := 100*(l_rev1_tl-l_cost1_tl)/l_rev1_tl;
   end if;

   if l_rev2_tl = 0 then
      l_mgn_per2_tl := 0;
   else
      l_mgn_per2_tl := 100*(l_rev2_tl-l_cost2_tl)/l_rev2_tl;
   end if;

   if l_rev3_tl = 0 then
      l_mgn_per3_tl := 0;
   else
      l_mgn_per3_tl := 100*(l_rev3_tl-l_cost3_tl)/l_rev3_tl;
   end if;

   if l_rev4_tl = 0 then
      l_mgn_per4_tl := 0;
   else
      l_mgn_per4_tl := 100*(l_rev4_tl-l_cost4_tl)/l_rev4_tl;
   end if;

   if l_rev5_tl = 0 then
      l_mgn_per5_tl := 0;
   else
      l_mgn_per5_tl := 100*(l_rev5_tl-l_cost5_tl)/l_rev5_tl;
   end if;

   if l_rev6_tl = 0 then
      l_mgn_per6_tl := 0;
   else
      l_mgn_per6_tl := 100*(l_rev6_tl-l_cost6_tl)/l_rev6_tl;
   end if;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_mgn_per1_tl);
   dbms_sql.bind_variable(cursor_id,':n2',l_mgn_per2_tl);
   dbms_sql.bind_variable(cursor_id,':n3',l_mgn_per3_tl);
   dbms_sql.bind_variable(cursor_id,':n4',l_mgn_per4_tl);
   dbms_sql.bind_variable(cursor_id,':n5',l_mgn_per5_tl);
   dbms_sql.bind_variable(cursor_id,':n6',l_mgn_per6_tl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;


 end if;
/*end if 'GL'*/


if p_period_type = 'PA' THEN

/* for project level res id */

  begin

    select object_id
     into  l_element_id_pl
     from  pa_proj_periods_denorm
    where  object_type_code = 'ADJ_ELEMENTS'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = -1
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_adj_element_id_pl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);
   dbms_sql.bind_variable(cursor_id,':n7',col7);
   dbms_sql.bind_variable(cursor_id,':n8',col8);
   dbms_sql.bind_variable(cursor_id,':n9',col9);
   dbms_sql.bind_variable(cursor_id,':n10',col10);
   dbms_sql.bind_variable(cursor_id,':n11',col11);
   dbms_sql.bind_variable(cursor_id,':n12',col12);
   dbms_sql.bind_variable(cursor_id,':n13',col13);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-1);
   dbms_sql.bind_variable(cursor_id,':elementId',l_element_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||','||
                   colname7||','||
                   colname8||','||
                   colname9||','||
                   colname10||','||
                   colname11||','||
                   colname12||','||
                   colname13||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6,
                        :n7,
                        :n8,
                        :n9,
                        :n10,
                        :n11,
                        :n12,
                        :n13 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-1);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_adj_element_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);
   dbms_sql.bind_variable(cursor_id,':n7',col7);
   dbms_sql.bind_variable(cursor_id,':n8',col8);
   dbms_sql.bind_variable(cursor_id,':n9',col9);
   dbms_sql.bind_variable(cursor_id,':n10',col10);
   dbms_sql.bind_variable(cursor_id,':n11',col11);
   dbms_sql.bind_variable(cursor_id,':n12',col12);
   dbms_sql.bind_variable(cursor_id,':n13',col13);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


   /* for task level res id */

    begin

    select object_id
     into  l_element_id_tl
     from  pa_proj_periods_denorm
    where  object_type_code = 'ADJ_ELEMENTS'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = -2
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_adj_element_id_tl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);
   dbms_sql.bind_variable(cursor_id,':n7',col7);
   dbms_sql.bind_variable(cursor_id,':n8',col8);
   dbms_sql.bind_variable(cursor_id,':n9',col9);
   dbms_sql.bind_variable(cursor_id,':n10',col10);
   dbms_sql.bind_variable(cursor_id,':n11',col11);
   dbms_sql.bind_variable(cursor_id,':n12',col12);
   dbms_sql.bind_variable(cursor_id,':n13',col13);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-2);
   dbms_sql.bind_variable(cursor_id,':elementId',l_element_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||','||
                   colname7||','||
                   colname8||','||
                   colname9||','||
                   colname10||','||
                   colname11||','||
                   colname12||','||
                   colname13||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6,
                        :n7,
                        :n8,
                        :n9,
                        :n10,
                        :n11,
                        :n12,
                        :n13 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',-2);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_adj_element_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_element_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);
   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',col1);
   dbms_sql.bind_variable(cursor_id,':n2',col2);
   dbms_sql.bind_variable(cursor_id,':n3',col3);
   dbms_sql.bind_variable(cursor_id,':n4',col4);
   dbms_sql.bind_variable(cursor_id,':n5',col5);
   dbms_sql.bind_variable(cursor_id,':n6',col6);
   dbms_sql.bind_variable(cursor_id,':n7',col7);
   dbms_sql.bind_variable(cursor_id,':n8',col8);
   dbms_sql.bind_variable(cursor_id,':n9',col9);
   dbms_sql.bind_variable(cursor_id,':n10',col10);
   dbms_sql.bind_variable(cursor_id,':n11',col11);
   dbms_sql.bind_variable(cursor_id,':n12',col12);
   dbms_sql.bind_variable(cursor_id,':n13',col13);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


/*update denorm from budget_lines and resource assignment*/

/* for project level res id */

  begin

    select object_id
     into  ll_ra_id_pl
     from  pa_proj_periods_denorm
    where  object_type_code = 'RES_ASSIGNMENT'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = l_ra_id_pl
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_ra_id_pl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                 and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_pl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_pl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_pl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_pl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_pl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_pl);
   dbms_sql.bind_variable(cursor_id,':n7',l_denorm_amount7_pl);
   dbms_sql.bind_variable(cursor_id,':n8',l_denorm_amount8_pl);
   dbms_sql.bind_variable(cursor_id,':n9',l_denorm_amount9_pl);
   dbms_sql.bind_variable(cursor_id,':n10',l_denorm_amount10_pl);
   dbms_sql.bind_variable(cursor_id,':n11',l_denorm_amount11_pl);
   dbms_sql.bind_variable(cursor_id,':n12',l_denorm_amount12_pl);
   dbms_sql.bind_variable(cursor_id,':n13',l_denorm_amount13_pl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',ll_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||','||
                   colname7||','||
                   colname8||','||
                   colname9||','||
                   colname10||','||
                   colname11||','||
                   colname12||','||
                   colname13||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6,
                        :n7,
                        :n8,
                        :n9,
                        :n10,
                        :n11,
                        :n12,
                        :n13 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);

   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_pl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_pl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_pl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_pl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_pl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_pl);
   dbms_sql.bind_variable(cursor_id,':n7',l_denorm_amount7_pl);
   dbms_sql.bind_variable(cursor_id,':n8',l_denorm_amount8_pl);
   dbms_sql.bind_variable(cursor_id,':n9',l_denorm_amount9_pl);
   dbms_sql.bind_variable(cursor_id,':n10',l_denorm_amount10_pl);
   dbms_sql.bind_variable(cursor_id,':n11',l_denorm_amount11_pl);
   dbms_sql.bind_variable(cursor_id,':n12',l_denorm_amount12_pl);
   dbms_sql.bind_variable(cursor_id,':n13',l_denorm_amount13_pl);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


   /* for task level res id */

    begin

    select object_id
     into  ll_ra_id_tl
     from  pa_proj_periods_denorm
    where  object_type_code = 'RES_ASSIGNMENT'
      and  amount_type_code = l_amount_type_code
      and  amount_subtype_code = l_amount_subtype_code
      and  budget_version_id = l_budget_version_id
      and  resource_assignment_id = l_ra_id_tl
      and  currency_code = l_currency_code
      and  currency_type = l_currency_type
      and  object_id = l_ra_id_tl;

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_tl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_tl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_tl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_tl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_tl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_tl);
   dbms_sql.bind_variable(cursor_id,':n7',l_denorm_amount7_pl);
   dbms_sql.bind_variable(cursor_id,':n8',l_denorm_amount8_pl);
   dbms_sql.bind_variable(cursor_id,':n9',l_denorm_amount9_pl);
   dbms_sql.bind_variable(cursor_id,':n10',l_denorm_amount10_pl);
   dbms_sql.bind_variable(cursor_id,':n11',l_denorm_amount11_pl);
   dbms_sql.bind_variable(cursor_id,':n12',l_denorm_amount12_pl);
   dbms_sql.bind_variable(cursor_id,':n13',l_denorm_amount13_pl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',ll_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

   exception
     WHEN NO_DATA_FOUND THEN

     l_stmt := 'insert into pa_proj_periods_denorm
                 ( CREATION_DATE,
		   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   budget_version_id,
                   project_id,
                   resource_assignment_id,
                   object_id,
                   object_type_code,
                   period_profile_id,
                   amount_type_code,
                   amount_subtype_code,
                   amount_type_id,
                   amount_subtype_id,
                   currency_type,
		   currency_code,'||
                   colname1||','||
                   colname2||','||
                   colname3||','||
                   colname4||','||
                   colname5||','||
                   colname6||','||
                   colname7||','||
                   colname8||','||
                   colname9||','||
                   colname10||','||
                   colname11||','||
                   colname12||','||
                   colname13||')
                values( :creationDate,
                        :createdBy,
                        :lastUpdateLogin,
                        :lastUpdatedBy,
                        :lastUpdatedDate,
			:versionId,
                        :projectId,
                        :resId,
                        :elementId,
                        :elementCode,
                        :profileId,
                        :amountTypeCode,
                        :amountSubtypeCode,
                        :amountTypeId,
                        :amountSubTypeId,
                        :currencyType,
                        :currencyCode,
                        :n1,
                        :n2,
                        :n3,
                        :n4,
                        :n5,
                        :n6,
                        :n7,
                        :n8,
                        :n9,
                        :n10,
                        :n11,
                        :n12,
                        :n13 )';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':creationDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':createdBy',fnd_global.user_id);

   dbms_sql.bind_variable(cursor_id,':lastUpdateLogin',fnd_global.login_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedBy',fnd_global.user_id);
   dbms_sql.bind_variable(cursor_id,':lastUpdatedDate',sysdate);
   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':projectId',l_project_id);
   dbms_sql.bind_variable(cursor_id,':profileId',l_period_profile_id);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode',l_res_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeCode',l_amount_type_code);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode',l_amount_subtype_code);
   dbms_sql.bind_variable(cursor_id,':amountTypeId',l_amount_type_id);

   dbms_sql.bind_variable(cursor_id,':amountSubtypeId',l_amount_subtype_id);
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);
   dbms_sql.bind_variable(cursor_id,':n1',l_denorm_amount1_tl);
   dbms_sql.bind_variable(cursor_id,':n2',l_denorm_amount2_tl);
   dbms_sql.bind_variable(cursor_id,':n3',l_denorm_amount3_tl);
   dbms_sql.bind_variable(cursor_id,':n4',l_denorm_amount4_tl);
   dbms_sql.bind_variable(cursor_id,':n5',l_denorm_amount5_tl);
   dbms_sql.bind_variable(cursor_id,':n6',l_denorm_amount6_tl);
   dbms_sql.bind_variable(cursor_id,':n7',l_denorm_amount7_pl);
   dbms_sql.bind_variable(cursor_id,':n8',l_denorm_amount8_pl);
   dbms_sql.bind_variable(cursor_id,':n9',l_denorm_amount9_pl);
   dbms_sql.bind_variable(cursor_id,':n10',l_denorm_amount10_pl);
   dbms_sql.bind_variable(cursor_id,':n11',l_denorm_amount11_pl);
   dbms_sql.bind_variable(cursor_id,':n12',l_denorm_amount12_pl);
   dbms_sql.bind_variable(cursor_id,':n13',l_denorm_amount13_pl);


   l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);



   end;


/* Need to update the Margin and Margin% Also*/


/* for project level res id */

 /* Get Revenue */
  begin

                select period1,period2,period3,period4,period5,period6,period7,
		       period8,period9,period10,period11,period12,period13
                into   l_rev1_pl,l_rev2_pl,l_rev3_pl,l_rev4_pl,l_rev5_pl,l_rev6_pl,
		       l_rev7_pl,l_rev8_pl,l_rev9_pl,l_rev10_pl,l_rev11_pl,l_rev12_pl,l_rev13_pl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'REVENUE';

/*
   l_stmt := 'select sum(nvl('||colname1||',0)),'||
                    'sum(nvl('||colname2||',0)),'||
                    'sum(nvl('||colname3||',0)),'||
                    'sum(nvl('||colname4||',0)),'||
                    'sum(nvl('||colname5||',0)),'||
                    'sum(nvl('||colname6||',0)),'||
                    'sum(nvl('||colname7||',0)),'||
                    'sum(nvl('||colname8||',0)),'||
                    'sum(nvl('||colname9||',0)),'||
                    'sum(nvl('||colname10||',0)),'||
                    'sum(nvl('||colname11||',0)),'||
                    'sum(nvl('||colname12||',0)),'||
                    'sum(nvl('||colname13||',0))'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);


   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','REVENUE');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);

   dbms_sql.define_column(cursor_id,1,l_rev1_pl);
   dbms_sql.define_column(cursor_id,2,l_rev2_pl);
   dbms_sql.define_column(cursor_id,3,l_rev3_pl);
   dbms_sql.define_column(cursor_id,4,l_rev4_pl);
   dbms_sql.define_column(cursor_id,5,l_rev5_pl);
   dbms_sql.define_column(cursor_id,6,l_rev6_pl);
   dbms_sql.define_column(cursor_id,7,l_rev7_pl);
   dbms_sql.define_column(cursor_id,8,l_rev8_pl);
   dbms_sql.define_column(cursor_id,9,l_rev9_pl);
   dbms_sql.define_column(cursor_id,10,l_rev10_pl);
   dbms_sql.define_column(cursor_id,11,l_rev11_pl);
   dbms_sql.define_column(cursor_id,12,l_rev12_pl);
   dbms_sql.define_column(cursor_id,13,l_rev13_pl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;

   dbms_sql.column_value(cursor_id,1,l_rev1_pl);
   dbms_sql.column_value(cursor_id,2,l_rev2_pl);
   dbms_sql.column_value(cursor_id,3,l_rev3_pl);
   dbms_sql.column_value(cursor_id,4,l_rev4_pl);
   dbms_sql.column_value(cursor_id,5,l_rev5_pl);
   dbms_sql.column_value(cursor_id,6,l_rev6_pl);
   dbms_sql.column_value(cursor_id,7,l_rev7_pl);
   dbms_sql.column_value(cursor_id,8,l_rev8_pl);
   dbms_sql.column_value(cursor_id,9,l_rev9_pl);
   dbms_sql.column_value(cursor_id,10,l_rev10_pl);
   dbms_sql.column_value(cursor_id,11,l_rev11_pl);
   dbms_sql.column_value(cursor_id,12,l_rev12_pl);
   dbms_sql.column_value(cursor_id,13,l_rev13_pl);





END LOOP;

   dbms_sql.close_cursor(cursor_id);
*/

  end;

 /* Get Cost */

    begin

                select period1,period2,period3,period4,period5,period6,period7,
                       period8,period9,period10,period11,period12,period13
                into   l_cost1_pl,l_cost2_pl,l_cost3_pl,l_cost4_pl,l_cost5_pl,l_cost6_pl,
                       l_cost7_pl,l_cost8_pl,l_cost9_pl,l_cost10_pl,l_cost11_pl,l_cost12_pl,l_cost13_pl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'COST';

/*

   l_stmt := 'select sum(nvl('||colname1||',0)),'||
                    'sum(nvl('||colname2||',0)),'||
                    'sum(nvl('||colname3||',0)),'||
                    'sum(nvl('||colname4||',0)),'||
                    'sum(nvl('||colname5||',0)),'||
                    'sum(nvl('||colname6||',0)),'||
                    'sum(nvl('||colname7||',0)),'||
                    'sum(nvl('||colname8||',0)),'||
                    'sum(nvl('||colname9||',0)),'||
                    'sum(nvl('||colname10||',0)),'||
                    'sum(nvl('||colname11||',0)),'||
                    'sum(nvl('||colname12||',0)),'||
                    'sum(nvl('||colname13||',0))'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','COST');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);



   dbms_sql.define_column(cursor_id,1,l_cost1_pl);
   dbms_sql.define_column(cursor_id,2,l_cost2_pl);
   dbms_sql.define_column(cursor_id,3,l_cost3_pl);
   dbms_sql.define_column(cursor_id,4,l_cost4_pl);
   dbms_sql.define_column(cursor_id,5,l_cost5_pl);
   dbms_sql.define_column(cursor_id,6,l_cost6_pl);
   dbms_sql.define_column(cursor_id,7,l_cost7_pl);
   dbms_sql.define_column(cursor_id,8,l_cost8_pl);
   dbms_sql.define_column(cursor_id,9,l_cost9_pl);
   dbms_sql.define_column(cursor_id,10,l_cost10_pl);
   dbms_sql.define_column(cursor_id,11,l_cost11_pl);
   dbms_sql.define_column(cursor_id,12,l_cost12_pl);
   dbms_sql.define_column(cursor_id,13,l_cost13_pl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;

   dbms_sql.column_value(cursor_id,1,l_cost1_pl);
   dbms_sql.column_value(cursor_id,2,l_cost2_pl);
   dbms_sql.column_value(cursor_id,3,l_cost3_pl);
   dbms_sql.column_value(cursor_id,4,l_cost4_pl);
   dbms_sql.column_value(cursor_id,5,l_cost5_pl);
   dbms_sql.column_value(cursor_id,6,l_cost6_pl);
   dbms_sql.column_value(cursor_id,7,l_cost7_pl);
   dbms_sql.column_value(cursor_id,8,l_cost8_pl);
   dbms_sql.column_value(cursor_id,9,l_cost9_pl);
   dbms_sql.column_value(cursor_id,10,l_cost10_pl);
   dbms_sql.column_value(cursor_id,11,l_cost11_pl);
   dbms_sql.column_value(cursor_id,12,l_cost12_pl);
   dbms_sql.column_value(cursor_id,13,l_cost13_pl);






END LOOP;

   dbms_sql.close_cursor(cursor_id);
*/

  end;



/* Now populate MARGIN */

  begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',(l_rev1_pl-l_cost1_pl));
   dbms_sql.bind_variable(cursor_id,':n2',(l_rev2_pl-l_cost2_pl));
   dbms_sql.bind_variable(cursor_id,':n3',(l_rev3_pl-l_cost3_pl));
   dbms_sql.bind_variable(cursor_id,':n4',(l_rev4_pl-l_cost4_pl));
   dbms_sql.bind_variable(cursor_id,':n5',(l_rev5_pl-l_cost5_pl));
   dbms_sql.bind_variable(cursor_id,':n6',(l_rev6_pl-l_cost6_pl));
   dbms_sql.bind_variable(cursor_id,':n7',(l_rev7_pl-l_cost7_pl));
   dbms_sql.bind_variable(cursor_id,':n8',(l_rev8_pl-l_cost8_pl));
   dbms_sql.bind_variable(cursor_id,':n9',(l_rev9_pl-l_cost9_pl));
   dbms_sql.bind_variable(cursor_id,':n10',(l_rev10_pl-l_cost10_pl));
   dbms_sql.bind_variable(cursor_id,':n11',(l_rev11_pl-l_cost11_pl));
   dbms_sql.bind_variable(cursor_id,':n12',(l_rev12_pl-l_cost12_pl));
   dbms_sql.bind_variable(cursor_id,':n13',(l_rev13_pl-l_cost13_pl));

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;

/* Now populate the MARGIN% */

    begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;


   if l_rev1_pl = 0 then
      l_mgn_per1_pl := 0;
   else
      l_mgn_per1_pl := 100*(l_rev1_pl-l_cost1_pl)/l_rev1_pl;
   end if;

   if l_rev2_pl = 0 then
      l_mgn_per2_pl := 0;
   else
      l_mgn_per2_pl := 100*(l_rev2_pl-l_cost2_pl)/l_rev2_pl;
   end if;

   if l_rev3_pl = 0 then
      l_mgn_per3_pl := 0;
   else
      l_mgn_per3_pl := 100*(l_rev3_pl-l_cost3_pl)/l_rev3_pl;
   end if;

   if l_rev4_pl = 0 then
      l_mgn_per4_pl := 0;
   else
      l_mgn_per4_pl := 100*(l_rev4_pl-l_cost4_pl)/l_rev4_pl;
   end if;

   if l_rev5_pl = 0 then
      l_mgn_per5_pl := 0;
   else
      l_mgn_per5_pl := 100*(l_rev5_pl-l_cost5_pl)/l_rev5_pl;
   end if;

   if l_rev6_pl = 0 then
      l_mgn_per6_pl := 0;
   else
      l_mgn_per6_pl := 100*(l_rev6_pl-l_cost6_pl)/l_rev6_pl;
   end if;

   if l_rev7_pl = 0 then
      l_mgn_per7_pl := 0;
   else
      l_mgn_per7_pl := 100*(l_rev7_pl-l_cost7_pl)/l_rev7_pl;
   end if;

   if l_rev8_pl = 0 then
      l_mgn_per8_pl := 0;
   else
      l_mgn_per8_pl := 100*(l_rev8_pl-l_cost8_pl)/l_rev8_pl;
   end if;

      if l_rev9_pl = 0 then
      l_mgn_per9_pl := 0;
   else
      l_mgn_per9_pl := 100*(l_rev9_pl-l_cost9_pl)/l_rev9_pl;
   end if;

   if l_rev10_pl = 0 then
      l_mgn_per10_pl := 0;
   else
      l_mgn_per10_pl := 100*(l_rev10_pl-l_cost10_pl)/l_rev10_pl;
   end if;

   if l_rev11_pl = 0 then
      l_mgn_per11_pl := 0;
   else
      l_mgn_per11_pl := 100*(l_rev11_pl-l_cost11_pl)/l_rev11_pl;
   end if;

   if l_rev12_pl = 0 then
      l_mgn_per12_pl := 0;
   else
      l_mgn_per12_pl := 100*(l_rev12_pl-l_cost12_pl)/l_rev12_pl;
   end if;

  if l_rev13_pl = 0 then
      l_mgn_per13_pl := 0;
   else
      l_mgn_per13_pl := 100*(l_rev13_pl-l_cost13_pl)/l_rev13_pl;
   end if;



   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_mgn_per1_pl);
   dbms_sql.bind_variable(cursor_id,':n2',l_mgn_per2_pl);
   dbms_sql.bind_variable(cursor_id,':n3',l_mgn_per3_pl);
   dbms_sql.bind_variable(cursor_id,':n4',l_mgn_per4_pl);
   dbms_sql.bind_variable(cursor_id,':n5',l_mgn_per5_pl);
   dbms_sql.bind_variable(cursor_id,':n6',l_mgn_per6_pl);
   dbms_sql.bind_variable(cursor_id,':n7',l_mgn_per7_pl);
   dbms_sql.bind_variable(cursor_id,':n8',l_mgn_per8_pl);
   dbms_sql.bind_variable(cursor_id,':n9',l_mgn_per9_pl);
   dbms_sql.bind_variable(cursor_id,':n10',l_mgn_per10_pl);
   dbms_sql.bind_variable(cursor_id,':n11',l_mgn_per11_pl);
   dbms_sql.bind_variable(cursor_id,':n12',l_mgn_per12_pl);
   dbms_sql.bind_variable(cursor_id,':n13',l_mgn_per13_pl);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_pl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;

/* for task level res id */

 /* Get Revenue */
  begin

                select period1,period2,period3,period4,period5,period6,period7,
                       period8,period9,period10,period11,period12,period13
                into   l_rev1_tl,l_rev2_tl,l_rev3_tl,l_rev4_tl,l_rev5_tl,l_rev6_tl,
                       l_rev7_tl,l_rev8_tl,l_rev9_tl,l_rev10_tl,l_rev11_tl,l_rev12_tl,l_rev13_tl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'REVENUE';

/*
   l_stmt := 'select sum(nvl('||colname1||',0)),'||
                    'sum(nvl('||colname2||',0)),'||
                    'sum(nvl('||colname3||',0)),'||
                    'sum(nvl('||colname4||',0)),'||
                    'sum(nvl('||colname5||',0)),'||
                    'sum(nvl('||colname6||',0)),'||
                    'sum(nvl('||colname7||',0)),'||
                    'sum(nvl('||colname8||',0)),'||
                    'sum(nvl('||colname9||',0)),'||
                    'sum(nvl('||colname10||',0)),'||
                    'sum(nvl('||colname11||',0)),'||
                    'sum(nvl('||colname12||',0)),'||
                    'sum(nvl('||colname13||',0))'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','REVENUE');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);



   dbms_sql.define_column(cursor_id,1,l_rev1_tl);
   dbms_sql.define_column(cursor_id,2,l_rev2_tl);
   dbms_sql.define_column(cursor_id,3,l_rev3_tl);
   dbms_sql.define_column(cursor_id,4,l_rev4_tl);
   dbms_sql.define_column(cursor_id,5,l_rev5_tl);
   dbms_sql.define_column(cursor_id,6,l_rev6_tl);
   dbms_sql.define_column(cursor_id,7,l_rev7_tl);
   dbms_sql.define_column(cursor_id,8,l_rev8_tl);
   dbms_sql.define_column(cursor_id,9,l_rev9_tl);
   dbms_sql.define_column(cursor_id,10,l_rev10_tl);
   dbms_sql.define_column(cursor_id,11,l_rev11_tl);
   dbms_sql.define_column(cursor_id,12,l_rev12_tl);
   dbms_sql.define_column(cursor_id,13,l_rev13_tl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;


   dbms_sql.column_value(cursor_id,1,l_rev1_tl);
   dbms_sql.column_value(cursor_id,2,l_rev2_tl);
   dbms_sql.column_value(cursor_id,3,l_rev3_tl);
   dbms_sql.column_value(cursor_id,4,l_rev4_tl);
   dbms_sql.column_value(cursor_id,5,l_rev5_tl);
   dbms_sql.column_value(cursor_id,6,l_rev6_tl);
   dbms_sql.column_value(cursor_id,7,l_rev7_tl);
   dbms_sql.column_value(cursor_id,8,l_rev8_tl);
   dbms_sql.column_value(cursor_id,9,l_rev9_tl);
   dbms_sql.column_value(cursor_id,10,l_rev10_tl);
   dbms_sql.column_value(cursor_id,11,l_rev11_tl);
   dbms_sql.column_value(cursor_id,12,l_rev12_tl);
   dbms_sql.column_value(cursor_id,13,l_rev13_tl);






END LOOP;

   dbms_sql.close_cursor(cursor_id);
*/

  end;

 /* Get Cost */

    begin

                select period1,period2,period3,period4,period5,period6,period7,
                       period8,period9,period10,period11,period12,period13
                into   l_cost1_tl,l_cost2_tl,l_cost3_tl,l_cost4_tl,l_cost5_tl,l_cost6_tl,
                       l_cost7_tl,l_cost8_tl,l_cost9_tl,l_cost10_tl,l_cost11_tl,l_cost12_tl,l_cost13_tl
                from   pa_fp_sum_pv_v
                where  resource_assignment_id = l_ra_id_pl
                and    AMOUNT_TYPE_CODE = 'COST';

/*
   l_stmt := 'select sum(nvl('||colname1||',0)),'||
                    'sum(nvl('||colname2||',0)),'||
                    'sum(nvl('||colname3||',0)),'||
                    'sum(nvl('||colname4||',0)),'||
                    'sum(nvl('||colname5||',0)),'||
                    'sum(nvl('||colname6||',0)),'||
                    'sum(nvl('||colname7||',0)),'||
                    'sum(nvl('||colname8||',0)),'||
                    'sum(nvl('||colname9||',0)),'||
                    'sum(nvl('||colname10||',0)),'||
                    'sum(nvl('||colname11||',0)),'||
                    'sum(nvl('||colname12||',0)),'||
                    'sum(nvl('||colname13||',0))'||'
     from  pa_proj_periods_denorm
     where budget_version_id = :versionId
       and resource_assignment_id = :resId
       and object_id = :elementId
       and object_type_code = :elementCode
       and amount_type_code = :amountTypeCode
       and currency_type = :currencyType
       and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','COST');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


   dbms_sql.define_column(cursor_id,1,l_cost1_tl);
   dbms_sql.define_column(cursor_id,2,l_cost2_tl);
   dbms_sql.define_column(cursor_id,3,l_cost3_tl);
   dbms_sql.define_column(cursor_id,4,l_cost4_tl);
   dbms_sql.define_column(cursor_id,5,l_cost5_tl);
   dbms_sql.define_column(cursor_id,6,l_cost6_tl);
   dbms_sql.define_column(cursor_id,7,l_cost7_tl);
   dbms_sql.define_column(cursor_id,8,l_cost8_tl);
   dbms_sql.define_column(cursor_id,9,l_cost9_tl);
   dbms_sql.define_column(cursor_id,10,l_cost10_tl);
   dbms_sql.define_column(cursor_id,11,l_cost11_tl);
   dbms_sql.define_column(cursor_id,12,l_cost12_tl);
   dbms_sql.define_column(cursor_id,13,l_cost13_tl);

    l_rows_upd := dbms_sql.execute(cursor_id);

LOOP
   IF DBMS_SQL.FETCH_ROWS(cursor_id) = 0 THEN
   EXIT;
   END IF;

   dbms_sql.column_value(cursor_id,1,l_cost1_tl);
   dbms_sql.column_value(cursor_id,2,l_cost2_tl);
   dbms_sql.column_value(cursor_id,3,l_cost3_tl);
   dbms_sql.column_value(cursor_id,4,l_cost4_tl);
   dbms_sql.column_value(cursor_id,5,l_cost5_tl);
   dbms_sql.column_value(cursor_id,6,l_cost6_tl);
   dbms_sql.column_value(cursor_id,7,l_cost7_tl);
   dbms_sql.column_value(cursor_id,8,l_cost8_tl);
   dbms_sql.column_value(cursor_id,9,l_cost9_tl);
   dbms_sql.column_value(cursor_id,10,l_cost10_tl);
   dbms_sql.column_value(cursor_id,11,l_cost11_tl);
   dbms_sql.column_value(cursor_id,12,l_cost12_tl);
   dbms_sql.column_value(cursor_id,13,l_cost13_tl);




END LOOP;
   dbms_sql.close_cursor(cursor_id);
*/

  end;



/* Now populate MARGIN */

  begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;

   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',(l_rev1_tl-l_cost1_tl));
   dbms_sql.bind_variable(cursor_id,':n2',(l_rev2_tl-l_cost2_tl));
   dbms_sql.bind_variable(cursor_id,':n3',(l_rev3_tl-l_cost3_tl));
   dbms_sql.bind_variable(cursor_id,':n4',(l_rev4_tl-l_cost4_tl));
   dbms_sql.bind_variable(cursor_id,':n5',(l_rev5_tl-l_cost5_tl));
   dbms_sql.bind_variable(cursor_id,':n6',(l_rev6_tl-l_cost6_tl));
   dbms_sql.bind_variable(cursor_id,':n7',(l_rev7_tl-l_cost7_tl));
   dbms_sql.bind_variable(cursor_id,':n8',(l_rev8_tl-l_cost8_tl));
   dbms_sql.bind_variable(cursor_id,':n9',(l_rev9_tl-l_cost9_tl));
   dbms_sql.bind_variable(cursor_id,':n10',(l_rev10_tl-l_cost10_tl));
   dbms_sql.bind_variable(cursor_id,':n11',(l_rev11_tl-l_cost11_tl));
   dbms_sql.bind_variable(cursor_id,':n12',(l_rev12_tl-l_cost12_tl));
   dbms_sql.bind_variable(cursor_id,':n13',(l_rev13_tl-l_cost13_tl));

   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;

/* Now populate the MARGIN% */

    begin

   l_stmt := 'update pa_proj_periods_denorm
                 set '|| colname1|| '= :n1,'||
                         colname2|| '= :n2,'||
                         colname3|| '= :n3,'||
                         colname4|| '= :n4,'||
                         colname5|| '= :n5,'||
                         colname6|| '= :n6,'||
                         colname7|| '= :n7,'||
                         colname8|| '= :n8,'||
                         colname9|| '= :n9,'||
                         colname10|| '= :n10,'||
                         colname11|| '= :n11,'||
                         colname12|| '= :n12,'||
                         colname13|| '= :n13
              where budget_version_id = :versionId
                and resource_assignment_id = :resId
                and object_id = :elementId
                and object_type_code = :elementCode
                and amount_type_code = :amountTypeCode
                and amount_subtype_code = :amountSubtypeCode
                and currency_type = :currencyType
                and currency_code = :currencyCode';

   cursor_id  := dbms_sql.open_cursor;


   if l_rev1_tl = 0 then
      l_mgn_per1_tl := 0;
   else
      l_mgn_per1_tl := 100*(l_rev1_tl-l_cost1_tl)/l_rev1_tl;
   end if;

   if l_rev2_tl = 0 then
      l_mgn_per2_tl := 0;
   else
      l_mgn_per2_tl := 100*(l_rev2_tl-l_cost2_tl)/l_rev2_tl;
   end if;

   if l_rev3_tl = 0 then
      l_mgn_per3_tl := 0;
   else
      l_mgn_per3_tl := 100*(l_rev3_tl-l_cost3_tl)/l_rev3_tl;
   end if;

   if l_rev4_tl = 0 then
      l_mgn_per4_tl := 0;
   else
      l_mgn_per4_tl := 100*(l_rev4_tl-l_cost4_tl)/l_rev4_tl;
   end if;

   if l_rev5_tl = 0 then
      l_mgn_per5_tl := 0;
   else
      l_mgn_per5_tl := 100*(l_rev5_tl-l_cost5_tl)/l_rev5_tl;
   end if;

   if l_rev6_tl = 0 then
      l_mgn_per6_tl := 0;
   else
      l_mgn_per6_tl := 100*(l_rev6_tl-l_cost6_tl)/l_rev6_tl;
   end if;

   if l_rev7_tl = 0 then
      l_mgn_per7_tl := 0;
   else
      l_mgn_per7_tl := 100*(l_rev7_tl-l_cost7_tl)/l_rev7_tl;
   end if;

   if l_rev8_tl = 0 then
      l_mgn_per8_tl := 0;
   else
      l_mgn_per8_tl := 100*(l_rev8_tl-l_cost8_tl)/l_rev8_tl;
   end if;

   if l_rev9_tl = 0 then
      l_mgn_per9_tl := 0;
   else
      l_mgn_per9_tl := 100*(l_rev9_tl-l_cost9_tl)/l_rev9_tl;
   end if;

   if l_rev10_tl = 0 then
      l_mgn_per10_tl := 0;
   else
      l_mgn_per10_tl := 100*(l_rev10_tl-l_cost10_tl)/l_rev10_tl;
   end if;

  if l_rev11_tl = 0 then
      l_mgn_per11_tl := 0;
   else
      l_mgn_per11_tl := 100*(l_rev11_tl-l_cost11_tl)/l_rev11_tl;
   end if;

   if l_rev12_tl = 0 then
      l_mgn_per12_tl := 0;
   else
      l_mgn_per12_tl := 100*(l_rev12_tl-l_cost12_tl)/l_rev12_tl;
   end if;

   if l_rev13_tl = 0 then
      l_mgn_per13_tl := 0;
   else
      l_mgn_per13_tl := 100*(l_rev13_tl-l_cost13_tl)/l_rev13_tl;
   end if;


   dbms_sql.parse(cursor_id,l_stmt,dbms_sql.native);
   dbms_sql.bind_variable(cursor_id,':n1',l_mgn_per1_tl);
   dbms_sql.bind_variable(cursor_id,':n2',l_mgn_per2_tl);
   dbms_sql.bind_variable(cursor_id,':n3',l_mgn_per3_tl);
   dbms_sql.bind_variable(cursor_id,':n4',l_mgn_per4_tl);
   dbms_sql.bind_variable(cursor_id,':n5',l_mgn_per5_tl);
   dbms_sql.bind_variable(cursor_id,':n6',l_mgn_per6_tl);
   dbms_sql.bind_variable(cursor_id,':n7',l_mgn_per7_tl);
   dbms_sql.bind_variable(cursor_id,':n8',l_mgn_per8_tl);
   dbms_sql.bind_variable(cursor_id,':n9',l_mgn_per9_tl);
   dbms_sql.bind_variable(cursor_id,':n10',l_mgn_per10_tl);
   dbms_sql.bind_variable(cursor_id,':n11',l_mgn_per11_tl);
   dbms_sql.bind_variable(cursor_id,':n12',l_mgn_per12_tl);
   dbms_sql.bind_variable(cursor_id,':n13',l_mgn_per13_tl);


   dbms_sql.bind_variable(cursor_id,':versionId',l_budget_version_id);
   dbms_sql.bind_variable(cursor_id,':resId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementId',l_ra_id_tl);
   dbms_sql.bind_variable(cursor_id,':elementCode','RES_ASSIGNMENT');
   dbms_sql.bind_variable(cursor_id,':amountTypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':amountSubtypeCode','MARGIN_PERCENT');
   dbms_sql.bind_variable(cursor_id,':currencyType',l_currency_type);
   dbms_sql.bind_variable(cursor_id,':currencyCode',l_currency_code);


    l_rows_upd := dbms_sql.execute(cursor_id);

   dbms_sql.close_cursor(cursor_id);

  end;


 end if;
/*end if 'PA'*/


END;

/*End update denorm table*/

/****************************************************************************************/
/*End of update pa_proj_periods_denorm*/
/***************************************************************************************/





END pa_fp_update_tables;




FUNCTION Get_Version_ID return NUMBER is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_VERSION_ID;
END Get_Version_ID;

FUNCTION Get_Org_ID return NUMBER is
BEGIN
   return pa_fin_plan_view_global.G_FP_ORG_ID;
END Get_Org_ID;

FUNCTION Get_Plan_Type_ID return NUMBER is
BEGIN
   return pa_fin_plan_view_global.G_FP_PLAN_TYPE_ID;
END Get_Plan_Type_ID;

FUNCTION Get_Resource_assignment_ID return NUMBER is
BEGIN
   return pa_fin_plan_view_global.G_FP_RA_ID;
END Get_Resource_assignment_ID;

FUNCTION Get_Amount_Type_code return VARCHAR2 is
BEGIN
   return pa_fin_plan_view_global.G_FP_AMOUNT_TYPE_CODE;
END Get_Amount_Type_code;

FUNCTION Get_Adj_Reason_Code return VARCHAR2 is
BEGIN
   return pa_fin_plan_view_global.G_FP_ADJ_REASON_CODE;
END Get_Adj_Reason_Code;

FUNCTION Get_Period_Start_Date1 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE1;
END Get_Period_Start_Date1;

FUNCTION Get_Period_Start_Date2 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE2;
END Get_Period_Start_Date2;

FUNCTION Get_Period_Start_Date3 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE3;
END Get_Period_Start_Date3;

FUNCTION Get_Period_Start_Date4 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE4;
END Get_Period_Start_Date4;

FUNCTION Get_Period_Start_Date5 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE5;
END Get_Period_Start_Date5;

FUNCTION Get_Period_Start_Date6 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE6;
END Get_Period_Start_Date6;

FUNCTION Get_Period_Start_Date7 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE7;
END Get_Period_Start_Date7;

FUNCTION Get_Period_Start_Date8 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE8;
END Get_Period_Start_Date8;

FUNCTION Get_Period_Start_Date9 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE9;
END Get_Period_Start_Date9;

FUNCTION Get_Period_Start_Date10 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE10;
END Get_Period_Start_Date10;

FUNCTION Get_Period_Start_Date11 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE11;
END Get_Period_Start_Date11;

FUNCTION Get_Period_Start_Date12 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE12;
END Get_Period_Start_Date12;


FUNCTION Get_Period_Start_Date13 return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_VIEW_START_DATE13;
END Get_Period_Start_Date13;

FUNCTION Get_Plan_Start_Date return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_PLAN_START_DATE;
END Get_Plan_Start_Date;

FUNCTION Get_Plan_End_Date return Date is
BEGIN
   return pa_fin_plan_view_global.G_FP_PLAN_END_DATE;
END Get_Plan_End_Date;

FUNCTION Get_Currency_Code return VARCHAR2 is
BEGIN
   return pa_fin_plan_view_global.G_FP_CURRENCY_CODE;
END Get_Currency_Code;

FUNCTION Get_Currency_Type return VARCHAR2 is
BEGIN
   return pa_fin_plan_view_global.G_FP_CURRENCY_TYPE;
END Get_Currency_Type;




END pa_fin_plan_view_global;

/
