--------------------------------------------------------
--  DDL for Package Body ENG_WORKFLOW_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_WORKFLOW_EXT" AS
/* $Header: ENGXWKFB.pls 115.4 2004/05/27 22:52:56 mkimizuk ship $ */


PROCEDURE StartCustomWorkflow
(   p_validation_level  IN  NUMBER   := NULL
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
)
IS
     /* Local Variables */
     l_validation_level NUMBER ;

BEGIN

     l_validation_level := p_validation_level ;
     IF l_validation_level IS NULL THEN
         l_validation_level := FND_API.G_VALID_LEVEL_FULL ;
     END IF ;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* You custom logic is here */

EXCEPTION

     WHEN OTHERS THEN
          x_msg_count := x_msg_count + 1;
          x_msg_data  := substr(SQLERRM,1,2000);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END StartCustomWorkflow ;


PROCEDURE AbortCustomWorkflow
(   p_validation_level  IN  NUMBER   := NULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_process_name      IN  VARCHAR2 := NULL
 ,  p_wf_user_id        IN  NUMBER    -- User Id
)
IS

     /* Local Variables */
     l_validation_level NUMBER ;

BEGIN

     l_validation_level := p_validation_level ;
     IF l_validation_level IS NULL THEN
         l_validation_level := FND_API.G_VALID_LEVEL_FULL ;
     END IF ;

     x_return_status := FND_API.G_RET_STS_SUCCESS;


     /* You custom logic is here */

EXCEPTION

     WHEN OTHERS THEN
          x_msg_count := x_msg_count + 1;
          x_msg_data  := substr(SQLERRM,1,2000);
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END AbortCustomWorkflow ;



PROCEDURE GetCustomMessageSubject
(  document_id    IN     VARCHAR2
 , display_type   IN     VARCHAR2
 , document       IN OUT NOCOPY  VARCHAR2
 , document_type  IN OUT NOCOPY  VARCHAR2
)
IS

BEGIN

NULL ;


END GetCustomMessageSubject ;


PROCEDURE GetCustomMessageBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
)
IS

BEGIN

NULL ;

END GetCustomMessageBody ;


PROCEDURE RespondToNtf
(   x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_item_type         IN  VARCHAR2
 ,  p_item_key          IN  VARCHAR2
 ,  p_actid             IN  NUMBER
 ,  p_func_mode         IN  VARCHAR2
 ,  p_result            IN  VARCHAR2
)
IS

BEGIN

NULL ;

END RespondToNtf ;


END Eng_Workflow_Ext ;

/
