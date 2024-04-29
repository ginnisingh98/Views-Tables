--------------------------------------------------------
--  DDL for Package EAM_PROCESS_FAILURE_ENTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_FAILURE_ENTRY_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPFENS.pls 120.0.12000000.2 2007/04/19 15:05:31 amourya ship $ */

G_FE_CREATE        CONSTANT    NUMBER := 1;
G_FE_UPDATE        CONSTANT    NUMBER := 2;
G_FE_DELETE        CONSTANT    NUMBER := 3;
G_RECORD_FOUND      CONSTANT    VARCHAR2(1)  := 'S';
G_RECORD_NOT_FOUND  CONSTANT    VARCHAR2(1)  := 'F';

TYPE EAM_Failure_Entry_Record_Typ IS RECORD
   (
      failure_id                       NUMBER,
      failure_date 	               DATE,
      source_type	               NUMBER,
      source_id		               NUMBER,
      object_type                      NUMBER,
      object_id                        NUMBER,
      maint_organization_id            NUMBER,
      current_organization_id          NUMBER,
      department_id	               NUMBER,
      area_id                          NUMBER,
      transaction_type                 VARCHAR2(1),
      source_name                      VARCHAR2(240) /* Work Order Name for source_type =1 */
   );

TYPE Eam_Failure_Codes_Typ IS RECORD
   (
   /* source_id		               NUMBER,   Wip Entity Id for source_type =1
      source_type                      NUMBER,   1 for Work Order
      source_name                      VARCHAR2, Work Order Name for source_type =1 */
      failure_id                       NUMBER,
      failure_entry_id                 NUMBER,
      combination_id                   NUMBER,
      failure_code                     VARCHAR2(80), /* Changed size from 30 to 80 for BUG#5904859*/
      cause_code                       VARCHAR2(80), /* Changed size from 30 to 80 for BUG#5904859*/
      resolution_code                  VARCHAR2(80), /* Changed size from 30 to 80 for BUG#5904859*/
      comments                         VARCHAR2(240),
      transaction_type                 VARCHAR2(1)
   );

TYPE Eam_Failure_Codes_Tbl_Typ IS TABLE OF Eam_Failure_Codes_Typ
INDEX BY BINARY_INTEGER;

/**************************************************************************
-- Start of comments
--	API name 	: Process_Failure_Entry
--	Type		: Public.
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

END EAM_Process_Failure_Entry_PUB;

 

/
