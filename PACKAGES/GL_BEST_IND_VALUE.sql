--------------------------------------------------------
--  DDL for Package GL_BEST_IND_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BEST_IND_VALUE" AUTHID CURRENT_USER AS
/* $Header: glubinds.pls 120.3 2005/05/25 23:27:55 vtreiger ship $ */
--  -------------------------------------------------
--  Functions
--  -------------------------------------------------

   FUNCTION find_ind_value
      (p_segment_num    IN NUMBER)
   RETURN VARCHAR2;

END gl_best_ind_value;

 

/
