--------------------------------------------------------
--  DDL for Package EAM_WO_COMP_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_COMP_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWCVS.pls 120.1 2005/06/21 23:28:45 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWCVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_COMP_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Check_Required (
	p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_return_status         OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);


PROCEDURE Check_Attributes (
	 p_eam_wo_comp_rec      IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_eam_wo_comp_rec     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
       	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE Check_Attributes_b4_Defaulting
        (  p_eam_wo_comp_rec         IN EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
);

END EAM_WO_COMP_VALIDATE_PVT;

 

/
