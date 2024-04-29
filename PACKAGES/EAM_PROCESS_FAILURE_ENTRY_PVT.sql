--------------------------------------------------------
--  DDL for Package EAM_PROCESS_FAILURE_ENTRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_FAILURE_ENTRY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVFENS.pls 120.0.12010000.2 2012/03/09 14:01:12 vboddapa ship $ */

/**************************************************************************
-- Start of comments
--	API name 	: Process_Failure_Entry
--	Type		: Private.
--	Function	: Insert/ Update Failure Information corresponding
--	                  to a work order
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			  p_init_msg_list    IN VARCHAR2 Optional
--				 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional
--                               Default = FND_API.G_FALSE
--                        p_eam_failure_entry_record   IN
--                              Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
--                        p_eam_failure_codes_tbl      IN
--                              Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
--	OUT		: x_return_status    OUT NOCOPY  VARCHAR2(1)
--                        x_msg_count        OUT NOCOPY  NUMBER
--			  x_msg_data         OUT NOCOPY  VARCHAR2(2000)
--			  x_eam_failure_entry_record   OUT NOCOPY
--			         Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
--			  x_eam_failure_codes_tbl      OUT NOCOPY
--			         Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/

PROCEDURE Process_Failure_Entry
  (  p_api_version                IN  NUMBER   := 1.0
   , p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit                     IN  VARCHAR2 := FND_API.G_FALSE
   , p_eam_failure_entry_record   IN  Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
   , p_eam_failure_codes_tbl      IN  Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
   , x_return_status              OUT NOCOPY VARCHAR2
   , x_msg_count                  OUT NOCOPY NUMBER
   , x_msg_data                   OUT NOCOPY VARCHAR2
   , x_eam_failure_entry_record   OUT NOCOPY  Eam_Process_Failure_Entry_PUB.eam_failure_entry_record_typ
   , x_eam_failure_codes_tbl      OUT NOCOPY  Eam_Process_Failure_Entry_PUB.eam_failure_codes_tbl_typ
  );

/**************************************************************************
-- Start of comments
--	API name 	: Delete_Failure_Entry
--	Type		: Private.
--	Function	: Delete Failure Information corresponding
--	                  to a work order
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version      IN NUMBER   Required
--			    p_init_msg_list    IN VARCHAR2 Optional 			 Default = FND_API.G_FALSE
--	   		  p_commit           IN VARCHAR2 Optional      Default = FND_API.G_FALSE
--          p_source_id        IN  NUMBER
--          x_return_status    OUT NOCOPY VARCHAR2
--          x_msg_count        OUT NOCOPY  NUMBER
--			    x_msg_data         OUT NOCOPY  VARCHAR2(2000)

--	Version	: Current version	1.0.
--		  Initial version 	1.0
-- End of comments
***************************************************************************/

PROCEDURE Delete_Failure_Entry
 (  p_api_version                IN  NUMBER   := 1.0
  , p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE
  , p_commit                     IN  VARCHAR2 := FND_API.G_FALSE
  , p_source_id                  IN  NUMBER
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2
 );

END eam_process_failure_entry_pvt;

/
