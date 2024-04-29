--------------------------------------------------------
--  DDL for Package PA_TIMELINE_TIME_SCALE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TIMELINE_TIME_SCALE_PKG" AUTHID CURRENT_USER as
/* $Header: PARLTSCS.pls 120.1 2005/08/19 16:56:06 mwasowic noship $   */


PROCEDURE insert_row ( p_timeline_time_scale_tab    IN   PA_TIMELINE_GLOB.TimeScaleTabTyp,
                       x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_msg_data                   OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                      );

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_TIMELINE_TIME_SCALE in
--                        array processing.


PROCEDURE delete_row
        (
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
        );

--
-- Procedure            : Delete_row
-- Purpose              : Delete Row from PA_TIMELINE_TIME_SCALE table


END PA_TIMELINE_TIME_SCALE_PKG;
 

/
