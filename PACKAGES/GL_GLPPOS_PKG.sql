--------------------------------------------------------
--  DDL for Package GL_GLPPOS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLPPOS_PKG" AUTHID CURRENT_USER as
/* $Header: glupohks.pls 120.3 2005/05/05 01:42:16 kvora ship $ */

PROCEDURE glphk (posting_run_id IN NUMBER);

PROCEDURE after_final_journals_update (posting_run_id IN NUMBER);

END GL_GLPPOS_PKG;

 

/
