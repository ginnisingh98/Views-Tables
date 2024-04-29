--------------------------------------------------------
--  DDL for Package EAM_PROCESS_PERMIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_PERMIT_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPWPTS.pls 120.0.12010000.2 2010/05/19 12:45:58 vboddapa noship $ */

/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME: EAMPWPTS.pls
--
--  DESCRIPTION: Spec of package EAM_PROCESS_PERMIT_PUB
--
--  NOTES
--
--  HISTORY
--
--  25-JAN-2009   Madhuri Shah     Initial Creation
***************************************************************************/

-- g_debug_flag            VARCHAR2(1) := 'N';

Type eam_wp_header_rec_type is record
  (
        HEADER_ID         	          NUMBER          :=NULL,
        BATCH_ID		                  NUMBER          :=NULL,
        ROW_ID		                    NUMBER          :=NULL,
        TRANSACTION_TYPE              NUMBER          :=NULL,
        PERMIT_ID 	                  NUMBER          :=NULL,
        PERMIT_NAME	                  VARCHAR2(240)   :=NULL,
        PERMIT_TYPE                   NUMBER          :=NULL,
        DESCRIPTION		                VARCHAR2(240)   :=NULL,
        ORGANIZATION_ID               NUMBER          :=NULL,
        STATUS_TYPE        	          NUMBER          :=NULL,  --lookup
        VALID_FROM                    DATE            :=NULL,
        VALID_TO                      DATE            :=NULL,
        PENDING_FLAG	                VARCHAR2(1)     :=NULL,
        COMPLETION_DATE               DATE            :=NULL,
        USER_DEFINED_STATUS_ID	      NUMBER          :=NULL,
        ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=NULL,
        ATTRIBUTE1                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE2                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE3                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE4                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE5                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE6                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE7                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE8                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE9                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE10                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE11                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE12                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE13                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE14                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE15                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE16	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE17	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE18	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE19	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE20	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE21	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE22	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE23	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE24	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE25	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE26	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE27	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE28	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE29	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE30	                  VARCHAR2(240)   :=NULL,
        APPROVED_BY      	            NUMBER          :=NULL,
        CREATED_BY                    NUMBER          :=NULL,
        CREATION_DATE                 DATE            :=NULL,
        USER_ID                       NUMBER          :=NULL,
        RESPONSIBILITY_ID             NUMBER          :=NULL
  );

Type eam_wp_association_rec_type is record
(
        HEADER_ID         				    NUMBER          :=NULL,
        BATCH_ID					            NUMBER          :=NULL,
        ROW_ID					              NUMBER          :=NULL,
        TRANSACTION_TYPE              NUMBER          :=NULL,
        SAFETY_ASSOCIATION_ID 	      NUMBER          :=NULL,
        SOURCE_ID      				        NUMBER          :=NULL, -- wip_entity_id
        TARGET_REF_ID 				        NUMBER          :=NULL,
        ASSOCIATION_TYPE              NUMBER          :=NULL,
        ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=NULL,
        ATTRIBUTE1                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE2                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE3                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE4                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE5                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE6                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE7                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE8                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE9                    VARCHAR2(240)   :=NULL,
        ATTRIBUTE10                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE11                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE12                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE13                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE14                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE15                   VARCHAR2(240)   :=NULL,
        ATTRIBUTE16	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE17	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE18	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE19	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE20	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE21	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE22	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE23	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE24	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE25	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE26	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE27	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE28	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE29	                  VARCHAR2(240)   :=NULL,
        ATTRIBUTE30	                  VARCHAR2(240)   :=NULL,
        CREATED_BY                    NUMBER          :=NULL,
        CREATION_DATE                 DATE            :=NULL
  );


Type eam_wp_tbl_type is table of eam_wp_header_rec_type
INDEX BY BINARY_INTEGER;

Type eam_wp_association_tbl_type is table of eam_wp_association_rec_type
INDEX BY BINARY_INTEGER;



/**************************************************************************
* Procedure:     PROCESS_WORK_PERMIT
* Purpose:        Procedure to process work permit record.
*                 This procedure will call private the procedure PROCESS_WORK_PERMIT
*                 in the EAM_PROCES_PERMIT_PVT API.
***************************************************************************/


PROCEDURE  PROCESS_WORK_PERMIT
        (  p_bo_identifier             IN  VARCHAR2 := 'EAM'
         , p_api_version_number        IN  NUMBER   := 1.0
         , p_init_msg_list             IN  BOOLEAN  := FALSE
         , p_commit                    IN  VARCHAR2 := 'N'
         , p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
         , p_permit_wo_association_tbl IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
         , p_debug                     IN  VARCHAR2 := 'N'
         , p_output_dir                IN  VARCHAR2 := NULL
         , p_debug_filename            IN  VARCHAR2 := 'EAM_SAFETY_DEBUG.log'
         , p_debug_file_mode           IN  VARCHAR2 := 'w'
         , x_permit_id                 OUT NOCOPY   NUMBER
         , x_return_status             OUT NOCOPY VARCHAR2
         , x_msg_count                 OUT NOCOPY NUMBER
         );


/**************************************************************************
* Procedure:     COPY_WORK_PERMIT
* Purpose:        Procedure to copy work permit record.
*                 This procedure will call private the procedure PROCESS_WORK_PERMIT
*                 in the EAM_PROCES_PERMIT_PVT API.
***************************************************************************/

PROCEDURE COPY_WORK_PERMIT(
          p_bo_identifier             IN  VARCHAR2 := 'EAM'
         , p_api_version_number        IN  NUMBER   := 1.0
         , p_init_msg_list             IN  BOOLEAN  := FALSE
         , p_commit                    IN  VARCHAR2 := 'N'
         , p_debug                     IN  VARCHAR2 := 'N'
         , p_output_dir                IN  VARCHAR2 := NULL
         , p_debug_filename            IN  VARCHAR2 := 'EAM_SAFETY_DEBUG.log'
         , p_debug_file_mode           IN  VARCHAR2 := 'w'
         , p_org_id                    IN  NUMBER
         , px_permit_id                IN  OUT NOCOPY   NUMBER
         , x_return_status             OUT NOCOPY VARCHAR2
         , x_msg_count                 OUT NOCOPY NUMBER
);

END EAM_PROCESS_PERMIT_PUB;


/
