--------------------------------------------------------
--  DDL for Package PA_COPY_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COPY_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: PACCPYAS.pls 115.2 2003/08/18 14:30:19 ajdas noship $ */


PROCEDURE COPY_ASSET
	(p_cur_project_asset_id IN	    NUMBER,
    p_asset_name            IN	    VARCHAR2,
    p_asset_description     IN      VARCHAR2,
    p_project_asset_type    IN      VARCHAR2,
    p_asset_units           IN      NUMBER DEFAULT NULL,
    p_est_asset_units       IN      NUMBER DEFAULT NULL,
    p_asset_dpis            IN      DATE DEFAULT NULL,
    p_est_asset_dpis        IN      DATE DEFAULT NULL,
    p_asset_number          IN      VARCHAR2 DEFAULT NULL,
    p_copy_assignments      IN      VARCHAR2,
    x_new_project_asset_id     OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2);



END PA_COPY_ASSET_PVT;

 

/
