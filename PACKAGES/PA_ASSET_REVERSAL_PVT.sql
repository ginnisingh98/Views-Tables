--------------------------------------------------------
--  DDL for Package PA_ASSET_REVERSAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSET_REVERSAL_PVT" AUTHID CURRENT_USER AS
/* $Header: PACAREVS.pls 115.3 2003/08/18 14:29:48 ajdas noship $ */


TYPE project_assets_rec_type IS RECORD
(project_asset_id		     NUMBER			:= NULL,
processed_flag				 VARCHAR2(1)	:= 'N'
);

TYPE project_assets_tbl_type IS TABLE OF project_assets_rec_type
	INDEX BY BINARY_INTEGER;

--Global variable for indexing of PL/SQL Table
G_project_assets_tbl         project_assets_tbl_type;

--Global variable for Debug mode message control
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');




PROCEDURE CHECK_PROJECT_ASSET
	(p_project_asset_id     IN	    NUMBER,
    x_project_assets           OUT NOCOPY PA_ASSET_REVERSAL_PVT.project_assets_tbl_type,
    x_related_assets_exist     OUT NOCOPY BOOLEAN,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2);


PROCEDURE CHECK_ASSET_LINES
	(p_project_asset_id     IN	    NUMBER);


FUNCTION ASSET_IN_TBL
    (p_project_asset_id     IN	    NUMBER) RETURN BOOLEAN;


PROCEDURE Upd_RelAssets_RevFlag
	(x_project_assets       IN            PA_ASSET_REVERSAL_PVT.project_assets_tbl_type,
         x_update_count       OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2);


END PA_ASSET_REVERSAL_PVT;

 

/
