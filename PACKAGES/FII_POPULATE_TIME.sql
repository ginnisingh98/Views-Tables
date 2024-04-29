--------------------------------------------------------
--  DDL for Package FII_POPULATE_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_POPULATE_TIME" AUTHID CURRENT_USER AS
/*$Header: FIICMTIS.pls 120.2 2002/11/20 20:26:26 djanaswa ship $*/

 PROCEDURE PUSH(Errbuf out NOCOPY varchar2, retcode out NOCOPY Varchar2, rows_inserted out NOCOPY number,
		p_from_date date default trunc(sysdate-3700,'YYYY'),
		p_to_date date default trunc(sysdate+3700,'YYYY'));

END FII_POPULATE_TIME;

 

/
