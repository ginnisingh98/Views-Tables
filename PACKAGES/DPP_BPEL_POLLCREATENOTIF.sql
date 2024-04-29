--------------------------------------------------------
--  DDL for Package DPP_BPEL_POLLCREATENOTIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_BPEL_POLLCREATENOTIF" AUTHID CURRENT_USER AS
/* $Header: dppvbpns.pls 120.1 2008/04/08 10:14:03 sdasan noship $ */
   FUNCTION WAIT_FOR_REQUEST (P_REQUEST_ID NUMBER,
                                           P_INTERVAL NUMBER,
                                           P_MAX_WAIT NUMBER,
                                           X_PHASE OUT NOCOPY VARCHAR2,
                                           X_STATUS OUT NOCOPY VARCHAR2,
                                           X_DEV_PHASE OUT NOCOPY VARCHAR2,
                                           X_DEV_STATUS OUT NOCOPY VARCHAR2,
                                           X_MESSAGE OUT NOCOPY VARCHAR2,
                                           X_ERROR_MESSAGE OUT NOCOPY VARCHAR2)
   RETURN INTEGER;
END DPP_BPEL_POLLCREATENOTIF;

/
