--------------------------------------------------------
--  DDL for Package MSC_E1APS_DSMCOLL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_E1APS_DSMCOLL" AUTHID CURRENT_USER AS
--# $Header: MSCE1DSS.pls 120.0.12010000.3 2009/04/15 04:29:32 sravinoo noship $
	PROCEDURE MSC_DSM_COLLECTIONS(ERRBUF OUT NOCOPY VARCHAR2,
								RETCODE OUT NOCOPY VARCHAR2,
								parInstanceID IN VARCHAR2,
								parLoadPayCnf IN NUMBER,
								parLoadDed in NUMBER);

	END MSC_E1APS_DSMCOLL;


/
