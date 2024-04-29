--------------------------------------------------------
--  DDL for Package GL_GLPPOS_ACCTSEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLPPOS_ACCTSEQ_PKG" AUTHID CURRENT_USER as
/* $Header: gluposqs.pls 120.1 2005/05/05 01:42:30 kvora ship $ */

PROCEDURE Batch_Init(
            p_request_id            IN  NUMBER,
            p_coa_id                IN  NUMBER,
            p_prun_id               IN  NUMBER,
            p_ledgers_locked       OUT  NOCOPY NUMBER);

END GL_GLPPOS_ACCTSEQ_PKG;

 

/
