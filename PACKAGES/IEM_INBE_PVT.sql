--------------------------------------------------------
--  DDL for Package IEM_INBE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_INBE_PVT" AUTHID CURRENT_USER AS
/* $Header: ieminbvs.pls 120.0 2005/06/02 13:40:35 appldev noship $ */

PROCEDURE ENUMERATE_INBOUND_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

END IEM_INBE_PVT;

 

/
