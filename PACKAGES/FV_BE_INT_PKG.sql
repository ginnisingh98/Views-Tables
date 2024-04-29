--------------------------------------------------------
--  DDL for Package FV_BE_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BE_INT_PKG" AUTHID CURRENT_USER AS
--$Header: FVBEINTS.pls 120.5 2005/10/07 23:01:08 spala ship $

PROCEDURE MAIN
(
  errbuf     OUT NOCOPY VARCHAR2,
  retcode    OUT NOCOPY NUMBER,
  source     IN  VARCHAR2,
  group_id   IN  NUMBER,
  validation IN  VARCHAR2 DEFAULT 'O',
  ledger_id  IN  NUMBER
);
END fv_be_int_pkg;

 

/
