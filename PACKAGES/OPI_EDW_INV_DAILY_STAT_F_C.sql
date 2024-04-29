--------------------------------------------------------
--  DDL for Package OPI_EDW_INV_DAILY_STAT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_INV_DAILY_STAT_F_C" AUTHID CURRENT_USER AS
/*$Header: OPIMIDSS.pls 120.1 2005/06/07 03:28:34 appldev  $*/
   Procedure Push(Errbuf       in OUT NOCOPY Varchar2,
                  Retcode       in OUT NOCOPY Varchar2,
                  p_from_date   IN  varchar2,
                  p_to_date     IN  varchar2,
		  p_org_code	IN  varchar2 DEFAULT Null);

End OPI_EDW_INV_DAILY_STAT_F_C;

 

/
