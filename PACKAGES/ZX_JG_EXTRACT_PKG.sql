--------------------------------------------------------
--  DDL for Package ZX_JG_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_JG_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxriextrajgppvts.pls 120.0 2005/05/25 04:19:23 hidekoji ship $ */

   PROCEDURE get_taxable(P_TRL_GLOBAL_VARIABLES_REC IN ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

END zx_jg_extract_pkg;

 

/
