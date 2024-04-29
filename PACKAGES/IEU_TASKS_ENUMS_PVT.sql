--------------------------------------------------------
--  DDL for Package IEU_TASKS_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_TASKS_ENUMS_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUENTNS.pls 120.0 2005/06/02 15:41:42 appldev noship $ */

-- Sub-Program Units


PROCEDURE ENUMERATE_TASK_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

END IEU_TASKS_ENUMS_PVT;


 

/
