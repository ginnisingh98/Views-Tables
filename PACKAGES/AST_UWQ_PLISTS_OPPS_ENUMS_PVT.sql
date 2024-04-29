--------------------------------------------------------
--  DDL for Package AST_UWQ_PLISTS_OPPS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_PLISTS_OPPS_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: ASTENPOS.pls 115.2 2003/10/29 23:27:08 jraj noship $ */


PROCEDURE ENUMERATE_PLISTS_OPPS_NODE
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

AST_UWQ_ORG_ID VARCHAR2(20);
AST_UWQ_OPP_ACCESS VARCHAR2(20);

end AST_UWQ_PLISTS_OPPS_ENUMS_PVT;

 

/