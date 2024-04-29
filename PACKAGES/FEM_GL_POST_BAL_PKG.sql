--------------------------------------------------------
--  DDL for Package FEM_GL_POST_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_GL_POST_BAL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_gl_post_bal.pls 120.0 2005/06/06 21:25:54 appldev noship $  */

-- ------------------------
-- Public Procedures
-- ------------------------

FUNCTION Get_Next_Creation_Row_Seq RETURN NUMBER;

PROCEDURE Post_Fem_Balances
             (p_execution_mode     IN            VARCHAR2,
              p_process_slice      IN            VARCHAR2,
              x_rows_posted        IN OUT NOCOPY NUMBER,
              x_completion_code    IN OUT NOCOPY NUMBER);

PROCEDURE Post_Fem_Balances
             (p_execution_mode     IN            VARCHAR2,
              p_process_slice      IN            VARCHAR2,
              p_load_type          IN            VARCHAR2,
              p_maintain_qtd       IN            VARCHAR2,
              p_bsv_range_low      IN            VARCHAR2,
              p_bsv_range_high     IN            VARCHAR2,
              x_rows_posted        IN OUT NOCOPY NUMBER,
              x_completion_code    IN OUT NOCOPY NUMBER);

END FEM_GL_POST_BAL_PKG;

 

/
