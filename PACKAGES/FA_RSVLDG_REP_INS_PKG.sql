--------------------------------------------------------
--  DDL for Package FA_RSVLDG_REP_INS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RSVLDG_REP_INS_PKG" AUTHID CURRENT_USER AS
/*$Header: farsvins.pls 120.0.12010000.4 2009/12/23 05:26:43 anujain noship $*/
PROCEDURE RSVLDG (book in  varchar2,
                  period in  varchar2,
                  errbuf  out NOCOPY varchar2,
		  retcode out NOCOPY number,
                  operation out NOCOPY varchar2,
		  request_id in number
		  );
END FA_RSVLDG_REP_INS_PKG;

/
