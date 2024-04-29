--------------------------------------------------------
--  DDL for Package FV_FACTS_GL_PKG_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS_GL_PKG_EXT" AUTHID CURRENT_USER AS
/* $Header: FVFCVCUS.pls 120.1 2005/09/28 16:33:56 abhjoshi noship $*/
  PROCEDURE main
  (
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY NUMBER,
    p_ledger_id         IN  NUMBER,
    p_vendor_or_cust_id IN  NUMBER,
    p_from_period       IN  VARCHAR2,
    p_to_period         IN  VARCHAR2,
    p_vendor_or_cust    IN  VARCHAR2
  );
END fv_facts_gl_pkg_ext;

 

/
