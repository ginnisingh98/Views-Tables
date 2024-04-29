--------------------------------------------------------
--  DDL for Package EGO_ITEM_ORG_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_ORG_ASSIGN_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVIORS.pls 120.1 2006/02/15 03:30:17 swshukla noship $ */

   PROCEDURE  process_org_assignments(p_item_org_assign_tab IN OUT NOCOPY SYSTEM.EGO_ITEM_ORG_ASSIGN_TABLE
                                     ,p_commit              IN         VARCHAR2
				     ,p_context             IN         VARCHAR2 DEFAULT NULL
                                     ,x_return_status       OUT NOCOPY VARCHAR
                                     ,x_msg_count           OUT NOCOPY  NUMBER);
END EGO_ITEM_ORG_ASSIGN_PVT;


 

/
