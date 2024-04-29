--------------------------------------------------------
--  DDL for Package MRP_MRPRPPES_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_MRPRPPES_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: MRPRPPESS.pls 120.1 2007/12/31 15:04:51 dwkrishn noship $ */
  P_ORG_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END MRP_MRPRPPES_XMLP_PKG;



/
