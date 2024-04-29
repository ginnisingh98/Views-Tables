--------------------------------------------------------
--  DDL for Package IEU_WORKLIST_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WORKLIST_ENUMS_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUENWLS.pls 120.0 2005/06/02 15:50:14 appldev noship $ */

PROCEDURE ENUMERATE_WORKLIST_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

PROCEDURE REFRESH_WORKLIST_NODES( P_RESOURCE_ID IN NUMBER,
 P_NODE_ID IN NUMBER, X_COUNT OUT NOCOPY NUMBER);

PROCEDURE REFRESH_IND_OWN_WL_NODES(P_RESOURCE_ID IN NUMBER, X_IND_OWN_COUNT OUT NOCOPY NUMBER);

PROCEDURE REFRESH_GRP_OWN_WL_NODES(P_RESOURCE_ID IN NUMBER, X_GRP_OWN_COUNT OUT NOCOPY NUMBER);

PROCEDURE REFRESH_IND_ASG_WL_NODES(P_RESOURCE_ID IN NUMBER, X_IND_ASG_COUNT OUT NOCOPY NUMBER);

PROCEDURE REFRESH_GRP_ASG_WL_NODES(P_RESOURCE_ID IN NUMBER, X_GRP_ASG_COUNT OUT NOCOPY NUMBER);


END IEU_WORKLIST_ENUMS_PVT;

 

/