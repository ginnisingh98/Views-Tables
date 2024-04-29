--------------------------------------------------------
--  DDL for Package JE_GR_STATUTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_GR_STATUTORY" AUTHID CURRENT_USER as
/* $Header: jegrstas.pls 120.2 2006/05/06 08:15:02 anvijaya ship $ */

PROCEDURE gl_sequence (p_posting_run_id    IN     NUMBER,
                       p_retcode           IN OUT NOCOPY NUMBER,
                       p_errmsg            IN OUT NOCOPY VARCHAR2);

PROCEDURE gl_cutoff   (p_posting_run_id    IN     NUMBER,
                       p_retcode           IN OUT NOCOPY NUMBER,
                       p_errmsg            IN OUT NOCOPY VARCHAR2);

PROCEDURE check_cutoff(p_ledger_id    IN      NUMBER,
                       p_gldate             IN      DATE,
                       p_category_code      IN      VARCHAR2,
                       p_cat_application_id IN      NUMBER,
                       p_retcode            IN OUT NOCOPY  NUMBER,
                       p_errmsg             IN OUT NOCOPY  VARCHAR2);

TYPE g_cutoff_rules_rec is RECORD (
                        category_code               VARCHAR2(30),
                        cat_application_id          NUMBER,
                        ledger_id             NUMBER,
                        days                        NUMBER,
                        violation_response          VARCHAR2(10));

TYPE g_cutoff_rules_tab is TABLE of g_cutoff_rules_rec
                        INDEX BY BINARY_INTEGER;

g_cutoff_rules           g_cutoff_rules_tab;
g_idx                    BINARY_INTEGER := 0;

END JE_GR_STATUTORY;
 

/
