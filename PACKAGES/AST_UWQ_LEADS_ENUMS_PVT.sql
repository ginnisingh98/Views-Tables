--------------------------------------------------------
--  DDL for Package AST_UWQ_LEADS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_LEADS_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: ASTENLDS.pls 115.10 2002/12/04 23:07:18 gkeshava ship $ */


PROCEDURE ENUMERATE_LEADS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );


PROCEDURE ENUMERATE_TEAM_LEADS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

end AST_UWQ_LEADS_ENUMS_PVT;



 

/