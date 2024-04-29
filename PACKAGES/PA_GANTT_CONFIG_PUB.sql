--------------------------------------------------------
--  DDL for Package PA_GANTT_CONFIG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GANTT_CONFIG_PUB" AUTHID CURRENT_USER as
/* $Header: PAGCGCPS.pls 120.1 2005/08/19 16:32:50 mwasowic noship $ */

procedure CREATE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2 := 'N',
  P_CALLING_MODULE            in VARCHAR2 := 'SELF_SERVICE',
  P_GANTT_VIEW_ID             in PA_GANTT_CONFIG_B.gantt_view_id%TYPE,
  P_GANTT_CONFIG_USAGE        in PA_GANTT_CONFIG_B.gantt_config_usage%TYPE,
  P_FILTER_CODE               in PA_GANTT_CONFIG_B.filter_code%TYPE,
  P_TIME_SCALE_CODE           in PA_GANTT_CONFIG_B.time_scale_code%TYPE,
  P_EXPAND_COLLAPSE_FLAG      in PA_GANTT_CONFIG_B.expand_collapse_flag%TYPE,
  P_NUMBER_OF_DISPLAYED_ROWS  in PA_GANTT_CONFIG_B.number_of_displayed_rows%TYPE,
  P_SHOW_ADDITIONAL_COL_FLAG  in PA_GANTT_CONFIG_B.show_additional_col_flag%TYPE,
  P_FOCUS_ENABLED_FLAG        in PA_GANTT_CONFIG_B.focus_enabled_flag%TYPE,
  P_SHOW_HEADER_UI_FLAG       in PA_GANTT_CONFIG_B.show_header_ui_flag%TYPE,
  P_NAME                      in PA_GANTT_CONFIG_TL.name%TYPE,
  P_DESCRIPTION               in PA_GANTT_CONFIG_TL.description%TYPE,
  PX_GANTT_CONFIG_ID          in OUT NOCOPY PA_GANTT_CONFIG_B.gantt_config_id%TYPE,              --File.Sql.39 bug 4440895
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


procedure UPDATE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2 := 'N',
  P_CALLING_MODULE            in VARCHAR2 := 'SELF_SERVICE',
  P_GANTT_CONFIG_ID           in PA_GANTT_CONFIG_B.gantt_config_id%TYPE,
  P_GANTT_VIEW_ID             in PA_GANTT_CONFIG_B.gantt_view_id%TYPE,
  P_GANTT_CONFIG_USAGE        in PA_GANTT_CONFIG_B.gantt_config_usage%TYPE,
  P_FILTER_CODE               in PA_GANTT_CONFIG_B.filter_code%TYPE,
  P_TIME_SCALE_CODE           in PA_GANTT_CONFIG_B.time_scale_code%TYPE,
  P_EXPAND_COLLAPSE_FLAG      in PA_GANTT_CONFIG_B.expand_collapse_flag%TYPE,
  P_NUMBER_OF_DISPLAYED_ROWS  in PA_GANTT_CONFIG_B.number_of_displayed_rows%TYPE,
  P_SHOW_ADDITIONAL_COL_FLAG  in PA_GANTT_CONFIG_B.show_additional_col_flag%TYPE,
  P_FOCUS_ENABLED_FLAG        in PA_GANTT_CONFIG_B.focus_enabled_flag%TYPE,
  P_SHOW_HEADER_UI_FLAG       in PA_GANTT_CONFIG_B.show_header_ui_flag%TYPE,
  P_RECORD_VERSION_NUMBER     in PA_GANTT_CONFIG_B.RECORD_VERSION_NUMBER%TYPE,
  P_NAME                      in PA_GANTT_CONFIG_TL.name%TYPE,
  P_DESCRIPTION               in PA_GANTT_CONFIG_TL.description%TYPE,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure DELETE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2 := 'N',
  P_CALLING_MODULE            in VARCHAR2 := 'SELF_SERVICE',
  P_GANTT_CONFIG_ID           in PA_GANTT_CONFIG_B.gantt_config_id%TYPE,
  P_RECORD_VERSION_NUMBER     in PA_GANTT_CONFIG_B.RECORD_VERSION_NUMBER%TYPE,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

end PA_GANTT_CONFIG_PUB;

 

/
