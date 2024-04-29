--------------------------------------------------------
--  DDL for Package OKL_UWQ_CONTRACTS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UWQ_CONTRACTS_ENUMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSWQS.pls 115.1 2002/04/23 11:26:06 pkm ship       $ */


PROCEDURE ENUMERATE_CONTRACTS_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

END Okl_Uwq_Contracts_Enums_Pvt;

 

/
