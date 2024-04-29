--------------------------------------------------------
--  DDL for Package FV_DUE_DATE_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_DUE_DATE_CALCULATION" AUTHID CURRENT_USER AS
/* $Header: FVXFODDS.pls 120.2 2002/11/11 20:09:10 ksriniva ship $ */

procedure  main(errbuf     OUT NOCOPY varchar2,
                retcode    OUT NOCOPY varchar2,
		x_run_mode in  varchar2);
 procedure cleanup;

 End ;

 

/
