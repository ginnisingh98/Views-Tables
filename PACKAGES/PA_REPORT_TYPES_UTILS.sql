--------------------------------------------------------
--  DDL for Package PA_REPORT_TYPES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REPORT_TYPES_UTILS" AUTHID CURRENT_USER as
/* $Header: PARTYPUS.pls 120.1 2005/08/19 17:02:44 mwasowic noship $ */

PROCEDURE Get_Page_Id_From_Layout(p_init_msg_list IN VARCHAR2 := 'T',
                                  p_page_layout   IN VARCHAR2,
                                  x_page_id       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data      OUT NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

Procedure get_report_type_info( p_report_type_id   IN NUMBER,
                                x_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

Function page_used_by_report_type(p_page_id    IN NUMBER) return VARCHAR2;

END  PA_REPORT_TYPES_UTILS;


 

/
