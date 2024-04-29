--------------------------------------------------------
--  DDL for Package EAM_OP_COMP_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OP_COMP_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVOCVS.pls 120.0 2005/06/08 02:48:29 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOCVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_OP_COMP_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/


PROCEDURE Check_Required (
         p_eam_op_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
       , x_return_status           OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     );


PROCEDURE Check_Attributes (
        p_eam_op_comp_rec      IN  EAM_PROCESS_WO_PUB. eam_op_comp_rec_type
      , x_return_status        OUT NOCOPY  VARCHAR2
      , x_mesg_token_tbl       OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  );

END EAM_OP_COMP_VALIDATE_PVT;

 

/
