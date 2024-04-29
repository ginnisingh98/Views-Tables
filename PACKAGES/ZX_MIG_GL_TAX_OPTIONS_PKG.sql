--------------------------------------------------------
--  DDL for Package ZX_MIG_GL_TAX_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MIG_GL_TAX_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxmiggltaxopts.pls 120.2.12010000.1 2008/07/28 13:34:21 appldev ship $ */

PROCEDURE zx_mig_gl_tax_options;
PROCEDURE zx_sync_gl_tax_options( P_Ledger_Id                          IN NUMBER,
 				  P_Org_id                             IN NUMBER,
                                  P_Account_Segment_Value              IN VARCHAR2,
                                  P_Tax_Type_Code                      IN VARCHAR2);

END zx_mig_gl_tax_options_pkg;

/
