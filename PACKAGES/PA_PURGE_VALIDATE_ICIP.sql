--------------------------------------------------------
--  DDL for Package PA_PURGE_VALIDATE_ICIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_VALIDATE_ICIP" AUTHID CURRENT_USER as
/* $Header: PAICIPVS.pls 120.1 2005/08/19 16:34:30 mwasowic noship $ */

    g_insert_errors_no_duplicate  VARCHAR2(1); /* Bug#2431705 */

--  FUNCTION
--              Is_InterPrj_Provider_Project
--  PURPOSE
--              This function returns 'Y'
--              if the given project is a provider project for inter project billing.

 FUNCTION Is_InterPrj_Provider_Project ( p_project_id        in NUMBER )
 Return VARCHAR2;

 pragma RESTRICT_REFERENCES (Is_InterPrj_Provider_Project, WNDS, WNPS);


--  FUNCTION
--              Is_InterPrj_Receiver_Project
--  PURPOSE
--              This function returns 'Y'
--              if the given project is a receiver project for inter project billing.

 FUNCTION Is_InterPrj_Receiver_Project ( p_project_id         in NUMBER )
 Return VARCHAR2;

 pragma RESTRICT_REFERENCES (Is_InterPrj_Receiver_Project, WNDS, WNPS);


 procedure Validate_IC ( p_project_id                     in NUMBER,
                         p_txn_to_date                    in DATE,
                         p_active_flag                    in VARCHAR2,
                         x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


 procedure Validate_IP_Prvdr ( p_project_id                     in NUMBER,
			       p_txn_to_date                    in DATE,
			       p_active_flag                    in VARCHAR2,
			       x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			       x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			       x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


 procedure Validate_IP_Rcvr ( p_project_id                     in NUMBER,
                              x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


 procedure Validate_IC_IP ( p_project_id                     in NUMBER,
                            p_txn_to_date                    in DATE,
                            p_active_flag                    in VARCHAR2,
                            x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

END ;
 

/
