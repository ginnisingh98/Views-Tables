--------------------------------------------------------
--  DDL for Package IEX_UWQ_STRAT_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_UWQ_STRAT_ENUMS_PVT" AUTHID CURRENT_USER as
/* $Header: iexensts.pls 120.0 2004/01/24 03:18:43 appldev noship $ */


PROCEDURE ENUMERATE_STRAT_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );


end IEX_UWQ_STRAT_ENUMS_PVT;

 

/
