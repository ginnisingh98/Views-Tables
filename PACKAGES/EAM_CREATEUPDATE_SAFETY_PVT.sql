--------------------------------------------------------
--  DDL for Package EAM_CREATEUPDATE_SAFETY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CREATEUPDATE_SAFETY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVSAWS.pls 120.0.12010000.2 2010/05/19 11:50:49 vboddapa noship $ */

--  Copyright (c) 2010 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSAWS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_CREATEUPDATE_SAFETY_PVT
--
--  NOTES
--
--  HISTORY

/************************************************************************************************************
Wrapper procedure on top of Public Permit API.This is used to copy permit
This in turn will call  COPY_WORK_PERMIT in EAM_PROCESS_PERMIT_PUB
***********************************************************************************************************/

PROCEDURE COPY_WORK_PERMIT(
          p_commit                    IN  VARCHAR2
         , p_org_id                    IN  NUMBER
         , px_permit_id                IN  OUT NOCOPY   NUMBER
         , x_return_status             OUT NOCOPY VARCHAR2
);

/************************************************************************************************************
Wrapper procedure on top of Public Permit API.This is used to create/update permit
This in turn will call  PROCESS_WORK_PERMIT in EAM_PROCESS_PERMIT_PUB
***********************************************************************************************************/

PROCEDURE CREATE_UPDATE_PERMIT
          (
              p_commit                           IN           VARCHAR2 := FND_API.G_FALSE
              , p_work_permit_header_rec         IN           EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
              , p_permit_wo_association_tbl      IN           EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
              , x_permit_id                      OUT NOCOPY   NUMBER
              , x_return_status                  OUT NOCOPY   VARCHAR2
              , x_msg_count                      OUT NOCOPY   NUMBER
          );



END EAM_CREATEUPDATE_SAFETY_PVT;

/
