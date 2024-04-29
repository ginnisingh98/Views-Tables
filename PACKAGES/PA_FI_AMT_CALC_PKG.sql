--------------------------------------------------------
--  DDL for Package PA_FI_AMT_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FI_AMT_CALC_PKG" AUTHID CURRENT_USER as
/* $Header: PAFICALS.pls 120.1 2005/08/19 16:23:07 mwasowic noship $ */
PROCEDURE Calculate_Fcst_Amounts_wrap
                   (
                            errbuff OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_run_mode              IN  VARCHAR2 default 'I',
                            p_select_criteria       IN  VARCHAR2 default '00',
                            p_project_flag          IN  VARCHAR2 default NULL,
                            p_project_id            IN  NUMBER default NULL,
                            p_assignment_id         IN  NUMBER default NULL,
                            P_ORGANIZATION_FLAG     IN  VARCHAR2 default NULL,
                            p_organization_id       IN  NUMBER default NULL,
                            P_Start_Organization_Flag IN  VARCHAR2 default NULL,
                            p_start_organization_id IN  NUMBER default NULL,
                            p_debug_mode            IN VARCHAR2 default 'N',
                            p_gen_report_flag       IN VARCHAR2 default 'N'
                    );
PROCEDURE Calculate_Fcst_Amounts
                   (
                            errbuff OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_run_mode              IN  VARCHAR2 default 'I',
                            p_select_criteria       IN  VARCHAR2 default '00',
                            p_project_id            IN  NUMBER default NULL,
                            p_assignment_id         IN  NUMBER default NULL,
                            p_organization_id       IN  NUMBER default NULL,
                            p_debug_mode            IN VARCHAR2 default 'N'
                    );
END Pa_Fi_Amt_Calc_Pkg;

 

/
