--------------------------------------------------------
--  DDL for Package EAM_WO_COMP_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_COMP_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWCDS.pls 120.0 2005/06/08 02:43:39 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWCDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_COMP_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Populate_Null_Columns (
	 p_eam_wo_comp_rec      IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
       , x_eam_wo_comp_rec      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
       , x_return_status        OUT NOCOPY  VARCHAR2
);


END EAM_WO_COMP_DEFAULT_PVT;

 

/
