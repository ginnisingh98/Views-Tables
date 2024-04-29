--------------------------------------------------------
--  DDL for Package GMO_OC_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_OC_TRANS_PKG" AUTHID CURRENT_USER  AS
/*  $Header: GMOOCTRS.pls 120.1 2007/06/21 06:11:33 rvsingh noship $  */
PROCEDURE GENERATE_OC_TRANS_XML(ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                Plant        IN         NUMBER,
                                Object_type IN         NUMBER DEFAULT NULL,
                                Object_id        IN         NUMBER DEFAULT NULL,
                                Operator_id      IN        NUMBER DEFAULT NULL,
                                FromDate     IN         VARCHAR2,
                                ToDate       IN         VARCHAR2);
END GMO_OC_TRANS_PKG;

/
