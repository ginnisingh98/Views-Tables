--------------------------------------------------------
--  DDL for Package QPR_DELETE_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_DELETE_AW" AUTHID CURRENT_USER AS
/* $Header: QPRUDAWS.pls 120.0 2007/10/11 13:05:45 agbennet noship $ */

	PROCEDURE DELETE_AW (
				ERRBUF OUT NOCOPY VARCHAR2,
				RETCODE OUT NOCOPY VARCHAR2,
				P_PRICE_PLAN_ID IN NUMBER,
				P_DELETE_QPR_TABLES IN VARCHAR2);


	FUNCTION AW_EXISTS (
				P_AW_NAME1 VARCHAR2)
	RETURN BOOLEAN;



End;

/
