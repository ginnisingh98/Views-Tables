--------------------------------------------------------
--  DDL for Package IEC_CUSTOM_RMI_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_CUSTOM_RMI_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVRMIS.pls 115.7 2003/08/22 20:42:53 hhuang ship $ */

-- Sub-Program Unit Declarations

PROCEDURE ADD_EMPTY_BLOB
  (P_SERVER_ID   IN            NUMBER
  ,P_COMP_DEF_ID IN            NUMBER
  ,X_RESULT        OUT NOCOPY NUMBER
  );

PROCEDURE BIND
  (P_SERVER_ID   IN            NUMBER
  ,P_COMP_DEF_ID IN            NUMBER
  ,P_OBJECT_REF  IN            BLOB
  ,X_RESULT         OUT NOCOPY NUMBER
  );

END IEC_CUSTOM_RMI_UTIL_PVT;

 

/
