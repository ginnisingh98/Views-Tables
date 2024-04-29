--------------------------------------------------------
--  DDL for Package QPR_CREATE_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_CREATE_AW" AUTHID CURRENT_USER AS
/* $Header: QPRUCAWS.pls 120.0 2007/10/11 13:05:17 agbennet noship $ */

PROCEDURE CREATE_AW ( errbuf OUT nocopy VARCHAR2, retcode OUT nocopy varchar2,
	P_PRICE_PLAN_ID IN NUMBER);

PROCEDURE CREATE_AWXML ( errbuf OUT nocopy VARCHAR2, retcode OUT nocopy varchar2,
	P_PRICE_PLAN_ID IN NUMBER);

FUNCTION AW_EXISTS ( P_AW_NAME2 VARCHAR2) RETURN BOOLEAN;

PROCEDURE CREATE_MODEL (p_price_plan_id number, p_cube_code varchar2);

PROCEDURE SUBMIT_REQUEST_SET(P_PRICE_PLAN_ID IN NUMBER, P_REQUEST_ID OUT NOCOPY NUMBER,P_STMT_NUM OUT NOCOPY NUMBER,
			ERRBUF OUT NOCOPY VARCHAR2,RETCODE OUT NOCOPY VARCHAR2);

End;

/
