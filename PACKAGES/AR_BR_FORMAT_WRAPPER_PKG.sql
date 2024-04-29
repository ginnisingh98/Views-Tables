--------------------------------------------------------
--  DDL for Package AR_BR_FORMAT_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BR_FORMAT_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: ARBRFMTS.pls 115.2 2002/11/15 01:56:16 anukumar ship $*/


PROCEDURE SUBMIT_FORMATS(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  FORMAT   IN  VARCHAR2,
  BR   IN  NUMBER,
  AFROM     IN  NUMBER default NULL,
  ATO       IN  NUMBER default NULL,
  SOB	 IN NUMBER
);
end AR_BR_FORMAT_WRAPPER_PKG;

 

/
