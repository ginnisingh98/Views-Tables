--------------------------------------------------------
--  DDL for Package ENG_WORKFLOW_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_WORKFLOW_EXT" AUTHID CURRENT_USER AS
/* $Header: ENGXWKFS.pls 115.4 2004/05/27 22:52:43 mkimizuk ship $ */


--  API name   : StartCustomWorkflow
--  Type       : Extenstion
--  Pre-reqs   : None.
--  Function   : Place folder where users can add their own custom logic
--               for customized workflows  while starting Workflow Process.
--               This procedure called from Eng_Workflow_Util.StartWorkflow
--               after creating process and before starting the process
--
--
--  Parameters :
--          IN :
--               p_validation_level  IN  NUMBER       Optional
--                                       Identifies validation Level
--                                       e.g. FND_API.G_VALID_LEVEL_FULL
--               x_item_type         IN  VARCHAR2     Required
--                                       Identifies workflow item type
--               p_process_name      IN  VARCHAR2     Required
--                                       Identifies workflow process name
--               p_change_id         IN  NUMBER       Optional
--                                       Identifies Change  Object
--               p_change_line_id    IN  NUMBER       Optional
--                                       Identifies Change  Object
--               p_wf_user_id        IN  NUMBER       Required
--                                       Identifies Workflow Owner
--               p_host_url          IN  VARCHAR2     Required
--                                       Identifies Host URL for OA Page
--               p_action_id         IN  NUMBER       Optional
--                                       Identifies Action for Workflow
--               p_adhoc_party_list  IN  VARCHAR2     Optional
--                                       Identifies paties being assigned to a task for Workflow
--                                       e.g Comment Request wf process will send request ntf to them
--               p_route_id          IN  NUMBER       Optional
--                                       Identifies Workflow Routing for Approval Routing
--               p_route_step_id     IN  NUMBER       Optional
--                                       Identifies Workflow Routing Step for Approval Routing
--               p_object_name       IN  VARCHAR2     Required
--                                       Identifies Object Name
--               p_object_id1        IN  NUMBER       Required
--                                       Identifies Object
--               p_object_id2        IN  NUMBER       Optional
--                                       Identifies Object
--               p_object_id3        IN  NUMBER       Optional
--                                       Identifies Object
--               p_object_id4        IN  NUMBER       Optional
--                                       Identifies Object
--               p_object_id5        IN  NUMBER       Optional
--                                       Identifies Object
--               p_parent_object_name IN  VARCHAR2    Optional
--                                       Identifies Parent Object Name
--               p_parent_object_id1  IN  NUMBER      Optional
--                                       Identifies Parent Object
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      IN OUT :
--               x_item_key          IN OUT NOCOPY  VARCHAR2
--                                       Identifies workflow item key
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text
PROCEDURE StartCustomWorkflow
(   p_validation_level  IN  NUMBER    := NULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  x_item_key          IN OUT NOCOPY VARCHAR2
 ,  p_process_name      IN  VARCHAR2
 ,  p_change_id         IN  NUMBER    := NULL
 ,  p_change_line_id    IN  NUMBER    := NULL
 ,  p_wf_user_id        IN  NUMBER    -- User Id
 ,  p_host_url          IN  VARCHAR2
 ,  p_action_id         IN  NUMBER    := NULL
 ,  p_adhoc_party_list  IN  VARCHAR2  := NULL
 ,  p_route_id          IN  NUMBER    := NULL
 ,  p_route_step_id     IN  NUMBER    := NULL
 ,  p_parent_item_type  IN  VARCHAR2  := NULL
 ,  p_parent_item_key   IN  VARCHAR2  := NULL
 ,  p_object_name        IN  VARCHAR2 := NULL
 ,  p_object_id1         IN  NUMBER   := NULL
 ,  p_object_id2         IN  NUMBER   := NULL
 ,  p_object_id3         IN  NUMBER   := NULL
 ,  p_object_id4         IN  NUMBER   := NULL
 ,  p_object_id5         IN  NUMBER   := NULL
 ,  p_parent_object_name IN  VARCHAR2 := NULL
 ,  p_parent_object_id1  IN  NUMBER   := NULL
) ;


--  API name   : AbortCustomWorkflow
--  Type       : Extenstion
--  Pre-reqs   : None.
--  Function   : Place folder where users can add their own custom logic
--               for customized workflows while abortting Workflow Process.
--               This procedure called from Eng_Workflow_Util.AbortWorkflow
--               before aborting the process or releasing 'BLOCK_ABORT' activity
--
--  Parameters :
--          IN :
--               p_validation_level  IN  NUMBER       Optional
--                                       Identifies validation Level
--                                       e.g. FND_API.G_VALID_LEVEL_FULL
--               p_item_type         IN  VARCHAR2     Required
--                                       Identifies workflow item type
--               p_item_key          IN  VARCHAR2     Required
--                                       Identifies workflow item key
--               p_process_name      IN  VARCHAR2     Optional
--                                       Identifies workflow process name
--               p_wf_user_id        IN  NUMBER       Required
--                                       Identifies Workflow Owner
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text
PROCEDURE AbortCustomWorkflow
(   p_validation_level  IN  NUMBER   := NULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2 := NULL
 ,  p_wf_user_id        IN  NUMBER    -- User Id
) ;


--  API name   : GetCustomMessageSubject
--  Type       : Extenstion
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL Document API to get ntf custom message subject.
--               Place folder where users can add their own custom logic
--               for customized message while Workflow getting ntf information.
--               This procedure called from Eng_Workflow_NTF_Util.GetMessageSubject
--
--               Return your message if you want to put your custom ntf message subject
--
--  Parameters : Please refer to workflow guide
--               p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
PROCEDURE GetCustomMessageSubject
(  document_id    IN     VARCHAR2
 , display_type   IN     VARCHAR2
 , document       IN OUT NOCOPY  VARCHAR2
 , document_type  IN OUT NOCOPY  VARCHAR2
) ;


--  API name   : GetCustomMessageBody
--  Type       : Extenstion
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf custom message body.
--               Place folder where users can add their own custom logic
--               for customized message while Workflow getting ntf information.
--               This procedure called from Eng_Workflow_NTF_Util.GetMessageTextBody
--               or GetMessageHTMLBody
--
--               Return your message body if you want to put your custom ntf message body
--
--  Parameters : Please refer to workflow guide
--               p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
--
PROCEDURE GetCustomMessageBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
) ;


--  API name   : RespondToNtf
--  Type       : Extenstion
--  Pre-reqs   : None.
--  Function   : Place folder where users can add their own custom logic
--               to be executed while responding seeded ToDo notifications.
--               This procedure called from Eng_Workflow_Pub notification call-back
--               procedures.
--
--  Parameters :
--          IN
--               itemtype  - type of the current item
--               itemkey   - key of the current item
--               actid     - process activity instance id
--               funcmode  - function execution mode. this is set by the engine
--                           as 'RUN', 'RESPOND'. . .
--               result
--
--
PROCEDURE RespondToNtf
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_actid             IN  NUMBER
 ,  p_func_mode         IN  VARCHAR2
 ,  p_result            IN  VARCHAR2
) ;

END Eng_Workflow_Ext ;

 

/
