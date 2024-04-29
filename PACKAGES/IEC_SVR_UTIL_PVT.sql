--------------------------------------------------------
--  DDL for Package IEC_SVR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_SVR_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVSVRS.pls 115.8 2003/08/22 20:43:04 hhuang ship $ */

-- Sub-Program Unit Declarations

PROCEDURE UPDATE_SVR_RT_INFO
  (P_SERVER_ID       IN            NUMBER
  ,P_COMP_DEF_ID     IN            NUMBER
  ,P_DNS_NAME        IN            VARCHAR2
  ,P_IP_ADDRESS      IN            VARCHAR2
  ,P_WIRE_PROTOCOL   IN            VARCHAR2
  ,P_PORT            IN            NUMBER
  ,P_EXTRA           IN            VARCHAR2
  ,X_RESULT          IN OUT NOCOPY NUMBER
  );

END IEC_SVR_UTIL_PVT;

 

/
