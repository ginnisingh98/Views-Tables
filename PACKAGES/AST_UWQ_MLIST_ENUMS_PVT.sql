--------------------------------------------------------
--  DDL for Package AST_UWQ_MLIST_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_MLIST_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: ASTENMLS.pls 115.4 2002/12/04 23:11:50 gkeshava ship $ */


PROCEDURE ENUMERATE_MLIST_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

end AST_UWQ_MLIST_ENUMS_PVT;



 

/
