--------------------------------------------------------
--  DDL for Package Body PA_TIMELINE_TIME_SCALE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TIMELINE_TIME_SCALE_PKG" as
/* $Header: PARLTSCB.pls 120.1 2005/08/19 16:56:02 mwasowic noship $ */


PROCEDURE insert_row ( p_timeline_time_scale_tab    IN   PA_TIMELINE_GLOB.TimeScaleTabTyp,
                       x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
        l_start_date                  PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                    PA_PLSQL_DATATYPES.DateTabTyp;
        l_scale_type                  PA_PLSQL_DATATYPES.Char30TabTyp;
        l_scale_row_type              PA_PLSQL_DATATYPES.Char30TabTyp;
        l_scale_marker_code           PA_PLSQL_DATATYPES.Char30TabTyp;
        l_scale_text                  PA_PLSQL_DATATYPES.Char30TabTyp;


BEGIN


IF (p_timeline_time_scale_tab.count = 0) then
    return;
END IF;


FOR J IN p_timeline_time_scale_tab.first..p_timeline_time_scale_tab.last
LOOP

        l_start_date(J)      :=   p_timeline_time_scale_tab(J).start_date;
        l_end_date(J)        :=   p_timeline_time_scale_tab(J).end_date;
        l_scale_type(J)      :=   p_timeline_time_scale_tab(J).scale_type;
        l_scale_row_type(J)  :=   p_timeline_time_scale_tab(J).scale_row_type;
        l_scale_marker_code(J) :=   p_timeline_time_scale_tab(J).scale_marker_code;
        l_scale_text(J)      :=   p_timeline_time_scale_tab(J).scale_text;

END LOOP;


FORALL J IN  p_timeline_time_scale_tab.first ..p_timeline_time_scale_tab.last
 INSERT INTO PA_TIMELINE_TIME_SCALE
      (
        start_date                 ,
        end_date                   ,
        scale_type                 ,
        scale_row_type             ,
        scale_marker_code          ,
        scale_text                 ,
        creation_date              ,
        created_by                 ,
        last_update_date           ,
        last_updated_by            ,
        last_update_login)
 VALUES
     (
        l_start_date(J)            ,
        l_end_date(J)              ,
        l_scale_type(J)            ,
        l_scale_row_type(J)        ,
        l_scale_marker_code(J)     ,
        l_scale_text(J)            ,
        sysdate                    ,
        fnd_global.user_id         ,
        sysdate                    ,
        fnd_global.user_id         ,
        fnd_global.login_id);



EXCEPTION
 WHEN OTHERS THEN
  Raise;
END insert_row;


PROCEDURE delete_row (
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                      )
IS

BEGIN

DELETE FROM pa_timeline_time_scale;



EXCEPTION
 WHEN OTHERS THEN
  Raise;
END delete_row;

END PA_TIMELINE_TIME_SCALE_PKG;

/
