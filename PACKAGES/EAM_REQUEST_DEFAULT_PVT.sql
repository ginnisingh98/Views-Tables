--------------------------------------------------------
--  DDL for Package EAM_REQUEST_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REQUEST_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVRQDS.pls 120.0 2005/06/08 02:55:16 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRQDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_REQUEST_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

 PROCEDURE Attribute_Defaulting
(     p_eam_request_rec               IN  EAM_PROCESS_WO_PUB.eam_request_rec_type
    , x_eam_request_rec               OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_rec_type
    , x_return_status                 OUT NOCOPY  VARCHAR2
);

END EAM_REQUEST_DEFAULT_PVT;

 

/
