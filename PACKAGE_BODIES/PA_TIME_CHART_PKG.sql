--------------------------------------------------------
--  DDL for Package Body PA_TIME_CHART_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TIME_CHART_PKG" as
/* $Header: PARLPKGB.pls 120.1 2005/08/19 16:55:29 mwasowic noship $ */

/*
PROCEDURE insert_row  (p_time_chart_tab    IN   PA_TIMELINE_GLOB.TimeChartTabTyp,
                       x_return_status              OUT  VARCHAR2,
                       x_msg_count                  OUT  NUMBER,
                       x_msg_data                   OUT  VARCHAR2 )
IS
        l_time_chart_record_type     PA_PLSQL_DATATYPES.Char30TabTyp;
        l_assignment_id               PA_PLSQL_DATATYPES.IdTabTyp;
        l_resource_id                 PA_PLSQL_DATATYPES.IdTabTyp;
        l_start_date                  PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                    PA_PLSQL_DATATYPES.DateTabTyp;
        l_scale_type                  PA_PLSQL_DATATYPES.Char30TabTyp;
        l_help_text                   PA_PLSQL_DATATYPES.Char150TabTyp;
        l_color_pattern               PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN

IF (p_time_chart_tab.count = 0) then
    return;
END IF;

FOR J IN p_time_chart_tab.first..p_time_chart_tab.last
LOOP

        l_time_chart_record_type(J) := p_time_chart_tab(J).time_chart_record_type;
        l_assignment_id(J)   :=   p_time_chart_tab(J).assignment_id;
        l_resource_id(J)     :=   p_time_chart_tab(J).resource_id;
        l_start_date(J)      :=   p_time_chart_tab(J).start_date;
        l_end_date(J)        :=   p_time_chart_tab(J).end_date;
        l_scale_type(J)      :=   p_time_chart_tab(J).scale_type;
        l_help_text(J)       :=   p_time_chart_tab(J).help_text;
        l_color_pattern(J)   :=   p_time_chart_tab(J).color_pattern;

END LOOP;


FORALL J IN  p_time_chart_tab.first ..p_time_chart_tab.last
 INSERT INTO PA_TIME_CHART_TEMP
      (
        time_chart_record_type     ,
        assignment_id              ,
        resource_id                ,
        start_date                 ,
        end_date                   ,
        scale_type                 ,
        help_text                  ,
        color_pattern              ,
        creation_date              ,
        created_by                 ,
        last_update_date           ,
        last_updated_by            ,
        last_update_login          )
 VALUES
     (
        l_time_chart_record_type(J),
        l_assignment_id(J)         ,
        l_resource_id(J)           ,
        trunc(l_start_date(J))     ,
        trunc(l_end_date(J))       ,
        l_scale_type(J)            ,
        l_help_text(J)             ,
        l_color_pattern(J)         ,
        sysdate                    ,
        fnd_global.user_id         ,
        sysdate                    ,
        fnd_global.user_id         ,
        fnd_global.login_id        );


EXCEPTION
 WHEN OTHERS THEN
  Raise;
END insert_row;
*/

PROCEDURE delete_row ( x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

DELETE FROM pa_time_chart_temp;


EXCEPTION
 WHEN OTHERS THEN
  Raise;
END delete_row;


END PA_TIME_CHART_PKG;

/
