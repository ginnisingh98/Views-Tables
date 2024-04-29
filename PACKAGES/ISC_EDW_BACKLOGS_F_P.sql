--------------------------------------------------------
--  DDL for Package ISC_EDW_BACKLOGS_F_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_EDW_BACKLOGS_F_P" AUTHID CURRENT_USER AS
/*$Header: ISCF01PS.pls 115.2 2002/12/19 01:53:26 scheung ship $*/

Procedure DELETE_FACT(	Errbuf 		IN OUT NOCOPY	VARCHAR2,
			Retcode 	IN OUT NOCOPY	VARCHAR2,
			p_nb_days 	IN 	NUMBER,
			p_from_date	IN	VARCHAR2,
			p_to_date	IN	VARCHAR2);


END ISC_EDW_BACKLOGS_F_P;

 

/
