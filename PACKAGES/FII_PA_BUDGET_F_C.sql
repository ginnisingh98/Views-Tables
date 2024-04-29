--------------------------------------------------------
--  DDL for Package FII_PA_BUDGET_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PA_BUDGET_F_C" AUTHID CURRENT_USER AS
/* $Header: FIIPA13S.pls 120.1 2002/11/22 20:19:53 svermett ship $ */

   Procedure Push(Errbuf        		in out nocopy 	Varchar2,
                  Retcode       		in out nocopy 	Varchar2,
                  p_from_date   		IN      	Varchar2,
                  p_to_date     		IN      	Varchar2,
		  p_currency_conversion_date	IN      	Varchar2
		);

End FII_PA_BUDGET_F_C;

 

/
