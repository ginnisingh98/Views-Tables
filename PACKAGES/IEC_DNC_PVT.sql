--------------------------------------------------------
--  DDL for Package IEC_DNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_DNC_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVDNCS.pls 115.9 2003/08/22 20:42:37 hhuang ship $ */


-- Sub-Program Unit Declarations

TYPE FETCH_CURSOR is REF CURSOR;

PROCEDURE IS_CALLABLE
  (P_SOURCE_ID        IN            NUMBER
  ,P_VIEW_NAME        IN            VARCHAR2
  ,P_LIST_ENTRY_ID    IN            NUMBER
  ,P_LIST_HEADER_ID   IN            NUMBER
  ,P_RETURNS_ID       IN            NUMBER
  ,X_CALLABLE_FLAG    IN OUT NOCOPY VARCHAR2
  );

END IEC_DNC_PVT;

 

/
