--------------------------------------------------------
--  DDL for Package PN_REC_EXP_EXTR_FROM_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_EXP_EXTR_FROM_GL_PKG" AUTHID CURRENT_USER AS
/* $Header: PNGLRECS.pls 115.2 2003/07/14 08:28:02 kkhegde noship $ */

PROCEDURE extract_expense_from_gl(
       errbuf                    OUT NOCOPY VARCHAR2,
       retcode                   OUT NOCOPY VARCHAR2,
       p_loc_acc_map_hdr_id      IN VARCHAR2,
       p_location_id             IN VARCHAR2,
       p_property_id             IN VARCHAR2,
       p_set_of_books_id         IN VARCHAR2,
       p_period_start            IN gl_period_statuses.period_name%TYPE,
       p_period_end              IN gl_period_statuses.period_name%TYPE,
       p_balance_type_code       IN gl_lookups.lookup_code%TYPE,
       p_balance_type_code_hide  IN gl_lookups.lookup_code%TYPE DEFAULT NULL,
       p_budget_name             IN gl_budgets.budget_name%TYPE,
       p_populate_rec            IN VARCHAR2,
       p_populate_rec_hide       IN VARCHAR2,
       p_as_of_date              IN VARCHAR2,
       p_period_start_date       IN VARCHAR2,
       p_period_end_date         IN VARCHAR2,
       p_populate_expcl_dtl      IN VARCHAR2,
       p_populate_arcl_dtl       IN VARCHAR2,
       p_override                IN VARCHAR2,
       p_rec_exp_num             IN VARCHAR2);

PROCEDURE Put_Log (p_String VarChar2);
PROCEDURE Put_Line(p_String VarChar2);

END PN_REC_EXP_EXTR_FROM_GL_PKG;

 

/
