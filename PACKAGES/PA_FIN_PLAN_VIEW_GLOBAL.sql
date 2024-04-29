--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_VIEW_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_VIEW_GLOBAL" AUTHID CURRENT_USER as
/* $Header: PARFPSVS.pls 120.1 2005/08/19 16:52:11 mwasowic noship $ */

G_FP_ORG_ID		number;
G_FP_VIEW_VERSION_ID	number;--:=1830;
G_FP_PLAN_TYPE_ID	number;
G_FP_RA_ID              number;--:=5301;
G_FP_AMOUNT_TYPE_CODE   VARCHAR2(30);--:='COST';
G_FP_ADJ_REASON_CODE    VARCHAR2(15);--:='REVENUE';
G_FP_CURRENCY_CODE	VARCHAR2(15);--:='USD';
G_FP_CURRENCY_TYPE      VARCHAR2(30):='PROJ_FUNCTIONAL';
G_FP_VIEW_START_DATE1   date;--:=to_date('01-Mar-02');
G_FP_VIEW_START_DATE2   date;--:=to_date('01-Apr_02');
G_FP_VIEW_START_DATE3   date;--:=to_date('01-May-02');
G_FP_VIEW_START_DATE4   date;--:=to_date('01-Jun-02');
G_FP_VIEW_START_DATE5   date;--:=to_date('01-Jul-02');
G_FP_VIEW_START_DATE6   date;--:=to_date('01-Aug-02');
G_FP_VIEW_START_DATE7   date;--:=to_date('01-Feb-03');
G_FP_VIEW_START_DATE8   date;--:=to_date('01-Mar-03');
G_FP_VIEW_START_DATE9   date;--:=to_date('01-Apr-03');
G_FP_VIEW_START_DATE10  date;--:=to_date('01-May-03');
G_FP_VIEW_START_DATE11  date;--:=to_date('01-Jun-03');
G_FP_VIEW_START_DATE12  date;--:=to_date('01-Jul-03');
G_FP_VIEW_START_DATE13  date;--:=to_date('01-Aug-03');
G_FP_VIEW_END_DATE1   date;--:=to_date('31-Mar-02');
G_FP_VIEW_END_DATE2   date;--:=to_date('30-Apr-02');
G_FP_VIEW_END_DATE3   date;--:=to_date('31-May-02');
G_FP_VIEW_END_DATE4   date;--:=to_date('30-Jun-02');
G_FP_VIEW_END_DATE5   date;--:=to_date('31-Jul-02');
G_FP_VIEW_END_DATE6   date;--:=to_date('31-Aug-02');
G_FP_VIEW_END_DATE7   date;--:=to_date('28-Feb-03');
G_FP_VIEW_END_DATE8   date;--:=to_date('31-Mar-03');
G_FP_VIEW_END_DATE9   date;--:=to_date('30-Apr-03');
G_FP_VIEW_END_DATE10  date;--:=to_date('31-May-03');
G_FP_VIEW_END_DATE11  date;--:=to_date('30-Jun-03');
G_FP_VIEW_END_DATE12  date;--:=to_date('31-Jul-03');
G_FP_VIEW_END_DATE13  date;--:=to_date('31-Aug-03');
G_FP_PERIOD_TYPE      VARCHAR2(30);
G_FP_PLAN_START_DATE  date;--:=to_date('01-Mar-02');
G_FP_PLAN_END_DATE    date;--:=to_date('31-Aug-02');

PROCEDURE pa_fp_get_budget_status_code(
                                        p_budget_version_id   IN  NUMBER,
                                        x_budget_status_code      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    );



PROCEDURE pa_fp_set_orgfcst_version_id(
                	               p_orgfcst_version_id  IN  NUMBER,
                        	       p_period_start_date   IN  VARCHAR2,
				       x_return_status       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              	       x_msg_count           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  	               x_msg_data            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );


PROCEDURE pa_fp_set_Adj_Reason_Code(
             			   	p_adj_reason_code   IN 	VARCHAR2,
           			        x_adj_comments      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              				x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              				x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
              				x_msg_data          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 				    );

PROCEDURE pa_fp_viewby_set_globals(
                                       p_amount_type_code       IN   VARCHAR2,
                                       p_resource_assignment_id IN   NUMBER,
                                       p_budget_version_id      IN   NUMBER,
                                       p_start_period           IN   VARCHAR2,
                                       x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );
PROCEDURE pa_fp_set_periods (
                                       p_period_start_date      IN   VARCHAR2,
                                       p_period_type            IN   VARCHAR2,
                                       x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

                            );
PROCEDURE pa_fp_set_periods_nav ( p_direction             IN    VARCHAR2,
                                  p_num_of_periods        IN    NUMBER,
                                  p_period_type           IN    VARCHAR2,
                                  x_start_date            OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			         );


PROCEDURE pa_fp_update_tables(  p_amount_type_code  	IN	VARCHAR2,
 				p_amount_subtype_code   IN	VARCHAR2,
				p_adj_reason_code	IN      VARCHAR2,
                                p_adj_comments          IN      VARCHAR2,
                                p_currency_code		IN	VARCHAR2,
				p_project_id 		IN	NUMBER,
 				p_period1		IN	NUMBER,
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
				p_period_type		IN	VARCHAR2,
                                p_budget_version_id     IN      NUMBER,
				x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT     NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895


FUNCTION Get_Version_ID return Number;
FUNCTION Get_Org_ID return Number;
FUNCTION Get_Plan_Type_ID return NUMBER;
FUNCTION Get_Resource_assignment_ID return NUMBER;
FUNCTION Get_Amount_Type_code return VARCHAR2;
FUNCTION Get_Adj_Reason_code return VARCHAR2;
FUNCTION Get_Currency_Code return VARCHAR2;
FUNCTION Get_Currency_Type return VARCHAR2;
FUNCTION Get_Period_Start_Date1 return Date;
FUNCTION Get_Period_Start_Date2 return Date;
FUNCTION Get_Period_Start_Date3 return Date;
FUNCTION Get_Period_Start_Date4 return Date;
FUNCTION Get_Period_Start_Date5 return Date;
FUNCTION Get_Period_Start_Date6 return Date;
FUNCTION Get_Period_Start_Date7 return Date;
FUNCTION Get_Period_Start_Date8 return Date;
FUNCTION Get_Period_Start_Date9 return Date;
FUNCTION Get_Period_Start_Date10 return Date;
FUNCTION Get_Period_Start_Date11 return Date;
FUNCTION Get_Period_Start_Date12 return Date;
FUNCTION Get_Period_Start_Date13 return Date;
FUNCTION Get_Plan_Start_Date return Date;
FUNCTION Get_Plan_End_Date return Date;



END pa_fin_plan_view_global;

 

/
