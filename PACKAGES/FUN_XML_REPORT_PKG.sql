--------------------------------------------------------
--  DDL for Package FUN_XML_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_XML_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: FUNXRPTS.pls 120.0 2006/01/03 19:28:54 yyoon noship $ */


PROCEDURE proposed_netting_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_batch_id         in         varchar2);

PROCEDURE final_netting_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_batch_id         in         varchar2);

END FUN_XML_REPORT_PKG;

 

/
