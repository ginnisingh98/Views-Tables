--------------------------------------------------------
--  DDL for Package PA_FAXFACE_RET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FAXFACE_RET_PVT" AUTHID CURRENT_USER AS
/* $Header: PACXFRCS.pls 115.2 2003/08/18 14:31:42 ajdas noship $ */


PROCEDURE INTERFACE_RET_COST_ADJ_LINE
	   (x_project_asset_line_id IN      NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_err_stage             IN OUT NOCOPY VARCHAR2,
		x_err_code              IN OUT NOCOPY NUMBER);

END PA_FAXFACE_RET_PVT;

 

/
