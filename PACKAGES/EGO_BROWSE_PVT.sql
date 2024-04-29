--------------------------------------------------------
--  DDL for Package EGO_BROWSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_BROWSE_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVBRWS.pls 120.1 2006/02/14 01:58 lkapoor noship $ */

 PROCEDURE Reload_ICG_Denorm_Hier_Table
    (x_return_status    OUT     NOCOPY VARCHAR2);

  PROCEDURE Sync_ICG_Denorm_Hier_Table (
	             p_catalog_group_id         IN NUMBER,
	             p_old_parent_id            IN NUMBER DEFAULT NULL,
                     x_return_status    OUT     NOCOPY VARCHAR2
                     );

END EGO_BROWSE_PVT;

 

/
