--------------------------------------------------------
--  DDL for Package PA_EFC_BIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EFC_BIL" AUTHID CURRENT_USER AS
/* $Header: PAEFCBLS.pls 120.1 2005/08/16 15:00:02 hsiu noship $ */
PROCEDURE Get_B_Ub_Rev_Inv_Amts(p_project_id    IN      NUMBER,
                               p_task_id        IN      NUMBER,
                               p_agreement_id   IN      NUMBER,
                               p_baselined      IN OUT  NOCOPY NUMBER,
                               p_ubaselined     IN OUT  NOCOPY NUMBER,
                               p_billed         IN OUT  NOCOPY NUMBER,
                               p_accr_rev       IN OUT  NOCOPY NUMBER,
                               p_adjust_amt     OUT     NOCOPY NUMBER,
                               p_rev_limit_flag   IN      VARCHAR2);

PROCEDURE Update_Adjusted_Amount (p_project_id          IN      NUMBER,
                                  p_agreement_id        IN      NUMBER,
                                  p_task_id             IN      NUMBER,
                                  p_adjusted            IN      NUMBER);

FUNCTION sum_mc_cust_rdl_erdl( p_project_id                   IN   NUMBER,
                               p_draft_revenue_num            IN   NUMBER,
                               p_draft_revenue_item_line_num  IN   NUMBER,
                               p_set_of_books_id              IN   NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(sum_mc_cust_rdl_erdl, WNDS);



FUNCTION sum_mc_cust_rdl_erdl2( x_project_id                   IN   NUMBER,
                               x_draft_revenue_num            IN   NUMBER,
                               x_set_of_books_id              IN   NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(sum_mc_cust_rdl_erdl2, WNDS);


END pa_efc_bil;

 

/
