--------------------------------------------------------
--  DDL for Package AST_UWQ_FORECASTS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_FORECASTS_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: ASTENFRS.pls 115.3 2002/02/06 12:32:35 pkm ship     $ */


PROCEDURE ENUMERATE_FORECASTS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

end AST_UWQ_FORECASTS_ENUMS_PVT;

 

/
