--------------------------------------------------------
--  DDL for Package AMS_UWQ_LIST_ENUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_UWQ_LIST_ENUM_PVT" AUTHID CURRENT_USER as
/* $Header: amsenmls.pls 115.2 2002/11/22 08:53:36 jieli ship $ */


PROCEDURE ENUMERATE_LIST_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  ) ;

end AMS_UWQ_LIST_ENUM_PVT  ;



 

/
