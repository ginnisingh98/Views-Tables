--------------------------------------------------------
--  DDL for Package EAM_REQUEST_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REQUEST_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVRQUS.pls 120.0 2005/06/08 02:56:25 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRQUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_REQUEST_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

 PROCEDURE INSERT_ROW
(  p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
   , x_return_status           OUT NOCOPY  VARCHAR2
   , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 );

 PROCEDURE DELETE_ROW
  (  p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
     , x_return_status         OUT NOCOPY  VARCHAR2
     , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  );

END EAM_REQUEST_UTILITY_PVT;

 

/
