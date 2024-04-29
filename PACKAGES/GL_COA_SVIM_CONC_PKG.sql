--------------------------------------------------------
--  DDL for Package GL_COA_SVIM_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_COA_SVIM_CONC_PKG" AUTHID CURRENT_USER AS
/* $Header: GLSVICOS.pls 120.0.12010000.1 2009/12/16 11:51:38 sommukhe noship $ */
PROCEDURE gl_coa_svim_process(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_batch_number IN VARCHAR2
  );

END gl_coa_svim_conc_pkg;

/
