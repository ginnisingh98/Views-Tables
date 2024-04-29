--------------------------------------------------------
--  DDL for Package Body EAM_CREATEUPDATE_SAFETY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CREATEUPDATE_SAFETY_PVT" AS
/* $Header: EAMVSAWB.pls 120.0.12010000.2 2010/05/19 11:53:54 vboddapa noship $ */

--  Copyright (c) 2010 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSAWB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_CREATEUPDATE_SAFETY_PVT
--
--  NOTES
--
--  HISTORY

/************************************************************************************************************
Wrapper procedure on top of Public Permit API.This is used to create/update permit
This in turn will call  PROCESS_WORK_PERMIT in EAM_PROCESS_PERMIT_PUB
***********************************************************************************************************/
PROCEDURE  COPY_WORK_PERMIT
  (
          p_commit                        IN VARCHAR2
         , p_org_id         IN NUMBER
         , px_permit_id                IN  OUT NOCOPY   NUMBER
         , x_return_status                 OUT NOCOPY  VARCHAR2
  )
 IS
     l_msg_count  NUMBER;

 BEGIN

 SAVEPOINT COPY_WORK_PERMIT;

			  EAM_PROCESS_PERMIT_PUB.COPY_WORK_PERMIT
			  (  p_bo_identifier     =>'EAM'
				, p_api_version_number =>1.0
				, p_init_msg_list          => FALSE
				, p_commit                    => p_commit
				, p_org_id              => p_org_id
        , px_permit_id           => px_permit_id
        , x_return_status          => x_return_status
				, x_msg_count            => l_msg_count
				);

               IF(NVL(x_return_status,'U') <> 'S') THEN
		    ROLLBACK TO COPY_WORK_PERMIT;
		    RETURN;
		 END IF;

		IF(x_return_status = 'S' ) THEN
--	   		    x_wip_entity_name := l_eam_wo_rec.wip_entity_name;
--			    x_wip_entity_id := l_eam_wo_rec.wip_entity_id;
			    IF(p_commit = FND_API.G_TRUE) THEN
                        		    COMMIT;
			    END IF;
        	 END IF;

  EXCEPTION
   WHEN OTHERS THEN
       ROLLBACK TO COPY_WORK_PERMIT;
       x_return_status := 'U';
 END COPY_WORK_PERMIT;

/************************************************************************************************************
Wrapper procedure on top of Public Permit API.This is used to create/update permit
This in turn will call  PROCESS_WORK_PERMIT in EAM_PROCESS_PERMIT_PUB
***********************************************************************************************************/

PROCEDURE CREATE_UPDATE_PERMIT
          (    p_commit                          IN           VARCHAR2 := FND_API.G_FALSE
              , p_work_permit_header_rec         IN           EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
              , p_permit_wo_association_tbl      IN           EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
              , x_permit_id                      OUT NOCOPY   NUMBER
              , x_return_status                  OUT NOCOPY   VARCHAR2
              , x_msg_count                      OUT NOCOPY   NUMBER
          )IS
 BEGIN

        EAM_PROCESS_PERMIT_PUB.PROCESS_WORK_PERMIT
          (
            p_bo_identifier                => 'EAM'
            , p_api_version_number         => 1.0
            , p_init_msg_list              =>  FALSE
            , p_commit                     => p_commit
            , p_work_permit_header_rec    => p_work_permit_header_rec
            , p_permit_wo_association_tbl  => p_permit_wo_association_tbl
            , x_permit_id                  => x_permit_id
            , x_return_status              => x_return_status
            , x_msg_count                  => x_msg_count
          );

 EXCEPTION
   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_error;
END CREATE_UPDATE_PERMIT;

END EAM_CREATEUPDATE_SAFETY_PVT;

/
