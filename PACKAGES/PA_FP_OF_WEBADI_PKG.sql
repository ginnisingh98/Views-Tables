--------------------------------------------------------
--  DDL for Package PA_FP_OF_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_OF_WEBADI_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPOFWS.pls 120.1 2005/08/19 16:27:28 mwasowic noship $ */


PROCEDURE populate_interface_table
                 (  p_session_id           IN   NUMBER,
                    p_budget_version_id    IN   NUMBER,
                    p_amount_type_code     IN   VARCHAR2,
                    x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );
END pa_fp_of_webadi_pkg;


 

/
