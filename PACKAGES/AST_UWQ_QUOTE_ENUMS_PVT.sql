--------------------------------------------------------
--  DDL for Package AST_UWQ_QUOTE_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_QUOTE_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: ASTENQUS.pls 115.4 2002/06/07 21:32:41 pkm ship      $ */


PROCEDURE ENUMERATE_QUOTE_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );


end AST_UWQ_QUOTE_ENUMS_PVT;

 

/
