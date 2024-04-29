--------------------------------------------------------
--  DDL for Package FEM_INTG_EXTENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_EXTENSION_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_intg_ext.pls 120.0 2008/02/07 21:39:11 rguerrer ship $ */
 PROCEDURE update_mapping_table(p_ccid_list IN FEM_INTG_NEW_DIM_MEMBER_PKG.ccid_list_type);
END fem_intg_extension_pkg;

/
