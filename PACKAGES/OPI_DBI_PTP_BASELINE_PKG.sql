--------------------------------------------------------
--  DDL for Package OPI_DBI_PTP_BASELINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PTP_BASELINE_PKG" AUTHID CURRENT_USER as
/* $Header: OPIDPTPETLS.pls 115.0 2003/06/30 19:10:50 weizhou noship $ */

PROCEDURE Extract_Baseline (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
);

PROCEDURE REFRESH(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

END OPI_DBI_PTP_BASELINE_PKG;

 

/
