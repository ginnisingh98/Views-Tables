--------------------------------------------------------
--  DDL for Package GMD_LCF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_LCF_ENGINE" AUTHID CURRENT_USER AS
/* $Header: GMDLCFPS.pls 120.1 2006/02/09 13:04:39 txdaniel noship $ */
  TYPE row IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE char_row IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

  TYPE matrix IS TABLE OF row INDEX BY BINARY_INTEGER;
  TYPE char_matrix IS TABLE OF char_row INDEX BY BINARY_INTEGER;

  TYPE solved_rec IS RECORD
  ( item VARCHAR2(2000),
    qty NUMBER);

  TYPE solved_tab IS TABLE OF solved_rec INDEX BY BINARY_INTEGER;

  PROCEDURE evaluate (P_spec_id IN NUMBER,
                      P_constraints IN NUMBER,
                      P_variables IN NUMBER,
                      P_matrix IN matrix,
                      p_rhs_matrix IN char_matrix,
                      p_var_row IN char_row,
                      X_solved_tab OUT NOCOPY solved_tab,
                      X_return OUT NOCOPY NUMBER);


  PROCEDURE read_table(P_constraints IN NUMBER,
                       P_variables IN NUMBER,
                       P_matrix IN matrix,
                       P_rhs_matrix IN char_matrix,
                       p_var IN char_row,
                       X_matrix OUT NOCOPY matrix,
                       X_basic OUT NOCOPY row,
                       X_reenter OUT NOCOPY row,
                       X_variables OUT NOCOPY NUMBER,
                       X_con OUT NOCOPY char_row,
                       X_var OUT NOCOPY char_row,
                       X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE solve_lgp (P_constraints IN NUMBER,
                       P_variables IN NUMBER,
                       P_matrix IN matrix,
                       P_reenter IN row,
                       P_basic IN row,
                       X_matrix OUT NOCOPY matrix,
                       X_basic OUT NOCOPY row,
                       X_return OUT NOCOPY NUMBER);

END GMD_LCF_ENGINE;

 

/
