--------------------------------------------------------
--  DDL for Package AST_UWQ_PLISTS_CONTS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_PLISTS_CONTS_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: ASTENPCS.pls 115.2 2003/10/29 23:26:45 jraj noship $ */


PROCEDURE ENUMERATE_PLISTS_CONTACTS_NODE
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

end AST_UWQ_PLISTS_CONTS_ENUMS_PVT;

 

/
