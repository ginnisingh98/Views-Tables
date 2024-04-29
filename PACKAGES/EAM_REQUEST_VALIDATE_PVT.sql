--------------------------------------------------------
--  DDL for Package EAM_REQUEST_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REQUEST_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVRQVS.pls 120.0 2005/06/08 02:43:46 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRQVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_REQUEST_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE CHECK_REQUIRED  (
         p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
       , x_return_status           OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);

PROCEDURE CHECK_ATTRIBUTES (
          p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
        , x_return_status           OUT NOCOPY  VARCHAR2
        , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
);


END EAM_REQUEST_VALIDATE_PVT;

 

/
