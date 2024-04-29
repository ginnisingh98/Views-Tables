--------------------------------------------------------
--  DDL for Package PA_PRJ_PROGRESS_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PRJ_PROGRESS_REPORTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAPJXPRS.pls 120.1 2005/08/19 16:41:30 mwasowic noship $ */
/*  APIs for Project exchange progress table */
/* Public  API               */
/**
 PROCEDURE update_progress_report(
       P_USER_ID                   IN NUMBER
      ,P_COMMIT_FLAG               IN VARCHAR2 default 'N'
      ,P_DEBUG_MODE                IN VARCHAR2 default 'N'
      ,P_PROJECT_ID_OLD            NUMBER  := null
      ,P_TASK_ID_OLD               NUMBER := null
      ,P_PROGRESS_STATUS_CODE_OLD  VARCHAR2 := null
      ,P_SHORT_DESCRIPTION_OLD     VARCHAR2 := null
      ,P_PROGRESS_ASOF_DATE_OLD    VARCHAR2 := null
      ,P_LONG_DESCRIPTION_OLD      VARCHAR2 := null
      ,P_ISSUES_OLD                VARCHAR2 := null
      ,P_ESTIMATED_START_DATE_OLD   VARCHAR2 := null
      ,P_ESTIMATED_END_DATE_OLD     VARCHAR2 := null
      ,P_ACTUAL_START_DATE_OLD      VARCHAR2 := null
      ,P_ACTUAL_END_DATE_OLD        VARCHAR2 := null
      ,P_PERCENT_COMPLETE_OLD       NUMBER := null
      ,P_ESTIMATE_TO_COMPLETE_OLD   NUMBER := null
      ,P_UNIT_TYPE_OLD              VARCHAR2 := null
      ,p_wf_status_code_old         VARCHAR2 := null
      ,p_wf_item_type_old           VARCHAR2 := null
      ,p_wf_item_key_old            NUMBER := NULL
      ,p_wf_process_old             VARCHAR2 := null
      ,P_PROJECT_ID_NEW              NUMBER := null
      ,P_TASK_ID_NEW                 NUMBER := null
      ,P_PROGRESS_STATUS_CODE_NEW    VARCHAR2 := null
      ,P_SHORT_DESCRIPTION_NEW       VARCHAR2 := null
      ,P_PROGRESS_ASOF_DATE_NEW      VARCHAR2 := null
      ,P_LONG_DESCRIPTION_NEW        VARCHAR2 := null
      ,P_ISSUES_NEW                  VARCHAR2 := null
      ,P_ESTIMATED_START_DATE_NEW     VARCHAR2 := null
      ,P_ESTIMATED_END_DATE_NEW       VARCHAR2 := null
      ,P_ACTUAL_START_DATE_NEW        VARCHAR2 := null
      ,P_ACTUAL_END_DATE_NEW          VARCHAR2 := null
      ,P_PERCENT_COMPLETE_NEW         NUMBER := null
      ,P_ESTIMATE_TO_COMPLETE_NEW     NUMBER := null
      ,P_UNIT_TYPE_NEW                VARCHAR2 := null
      ,p_wf_status_code_new             VARCHAR2 := null
      ,p_wf_item_type_new               VARCHAR2 := null
      ,p_wf_item_key_new                NUMBER := null
      ,p_wf_process_new               VARCHAR2 := null
      ,p_create_item_key_flag    VARCHAR2 := 'N'
      ,x_item_key             OUT number
      ,X_RETURN_STATUS        OUT VARCHAR2
      ,X_MSG_COUNT            IN OUT NUMBER
      ,X_MSG_DATA             IN OUT pa_vc_1000_2000
   );
   ***/

/* Private APIs               */
  PROCEDURE Insert_Row(
            -- P_ROWID       IN OUT   VARCHAR2
             P_PROGRESS_REPORT_ID   IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,P_RECORD_VERSION_NUMBER NUMBER DEFAULT 1
		    ,P_PROJECT_ID           NUMBER
			,P_TASK_ID              NUMBER default 0
			,P_PROGRESS_STATUS_CODE VARCHAR2 default 'ON_TRACK'
			,P_SHORT_DESCRIPTION    VARCHAR2 default null
			,P_PROGRESS_ASOF_DATE   DATE default sysdate
			,P_LONG_DESCRIPTION     VARCHAR2 default null
			,P_ISSUES               VARCHAR2 default null
            ,P_ESTIMATED_START_DATE DATE default null
            ,P_ESTIMATED_END_DATE   DATE default null
            ,P_ACTUAL_START_DATE    DATE default null
            ,P_ACTUAL_END_DATE      DATE default null
            ,P_PERCENT_COMPLETE     NUMBER default null
            ,P_ESTIMATE_TO_COMPLETE NUMBER default null
            ,P_UNIT_TYPE            VARCHAR2 default null
            ,P_PLANNED_ACTIVITIES   VARCHAR2 DEFAULT NULL
            ,P_REPORT_STATUS        VARCHAR2 DEFAULT 'WIP'
            ,P_CREATED_BY           NUMBER default -1
			,P_CREATION_DATE        DATE default sysdate
			,P_LAST_UPDATED_BY      NUMBER default -1
			,P_LAST_UPDATE_DATE     DATE default sysdate
			,P_LAST_UPDATE_LOGIN    NUMBER default -1
            ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count              OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data               OUT    NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895
PROCEDURE Update_Row(
                         P_PROGRESS_REPORT_ID   NUMBER
                        ,P_RECORD_VERSION_NUMBER NUMBER
		                ,P_PROJECT_ID           NUMBER
                        ,P_TASK_ID              NUMBER
                        ,P_PROGRESS_STATUS_CODE VARCHAR2
                        ,P_SHORT_DESCRIPTION    VARCHAR2
                        ,P_PROGRESS_ASOF_DATE   DATE
                        ,P_LONG_DESCRIPTION     VARCHAR2
                        ,P_ISSUES               VARCHAR2
		                ,P_ESTIMATED_START_DATE     DATE default trunc(to_date('01/01/1851','DD/MM/YYYY'))
                        ,P_ESTIMATED_END_DATE       DATE default trunc(to_date('01/01/1851','DD/MM/YYYY'))
                        ,P_ACTUAL_START_DATE        DATE default trunc(to_date('01/01/1851','DD/MM/YYYY'))
                      ,P_ACTUAL_END_DATE          DATE default trunc(to_date('01/011851','DD/MM/YYYY'))
                      ,P_PERCENT_COMPLETE         NUMBER default -9999
                      ,P_ESTIMATE_TO_COMPLETE     NUMBER default -9999
                      ,P_UNIT_TYPE                VARCHAR2 default '####'
                      ,P_PLANNED_ACTIVITIES   VARCHAR2 default '####'
                     ,P_REPORT_STATUS        VARCHAR2 default '####'
		             ,p_wf_status_code          VARCHAR2 default '####'
		             ,p_wf_item_type            VARCHAR2 default '####'
   		             ,p_wf_item_key             NUMBER  default -9999
		             ,p_wf_process            VARCHAR2 default '####'
                    ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ,x_msg_count              OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                    ,x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

  PROCEDURE Delete_Row(  P_PROGRESS_REPORT_ID   NUMBER
   ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
PROCEDURE Copy_lastpublished_report(
		    P_PROJECT_ID           NUMBER
     );

END PA_PRJ_PROGRESS_REPORTS_PKG;

 

/
