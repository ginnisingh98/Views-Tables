--------------------------------------------------------
--  DDL for Package Body CUG_LAUNCH_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_LAUNCH_WORKFLOW_PVT" AS
/* $Header: CUGWFLNB.pls 120.2 2007/12/06 05:09:06 gasankar noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'cug_launch_workflow_pvt';


  PROCEDURE launch_workflow 	  (
    				   p_api_version        IN      NUMBER                                      ,
    				   p_init_msg_list      IN      VARCHAR2  DEFAULT FND_API.G_FALSE              ,
    				   p_commit             IN      VARCHAR2  DEFAULT FND_API.G_FALSE              ,
    				   p_validation_level   IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL   ,
    				   x_return_status      OUT     NOCOPY VARCHAR2                                    ,
    				   x_msg_count          OUT     NOCOPY NUMBER                                      ,
    				   x_msg_data           OUT     NOCOPY VARCHAR2                                    ,
    				   p_incident_id        IN      NUMBER                                      ,
                       p_source             IN      VARCHAR2 DEFAULT NULL                       ,
                       p_incident_status_id IN      NUMBER                                      ,
                       p_initiator_user_id  IN      NUMBER DEFAULT NULL                         ,
                       p_initiator_resp_id  IN      NUMBER DEFAULT NULL                         ,
                       p_initiator_resp_appl_id IN  NUMBER DEFAULT NULL
    				   )


  IS

    l_api_name	     CONSTANT 	   VARCHAR2(30)  := 'launch_workflow' ;
    l_api_version   CONSTANT 	   NUMBER   	  := 2.0  		   ;

    l_itemkey VARCHAR2(240);
    l_wf_process_id NUMBER;
    l_initiator_role VARCHAR2(100);
    l_initiator_display_name VARCHAR2(240);

    CURSOR l_servereq_csr IS
    SELECT CSI.incident_number,CSI.workflow_process_id,CSI.incident_type_id,CST.name,CST.workflow,
    CST.autolaunch_workflow_flag
    FROM cs_incidents_all_b CSI, cs_incident_types_vl CST
    WHERE CSI.incident_id = p_incident_id
    AND CST.incident_type_id = CSI.incident_type_id
    FOR UPDATE OF workflow_process_id NOWAIT;

    l_servereq_csr_rec l_servereq_csr%ROWTYPE;

  BEGIN
    -- Standard start of API savepoint
--    SAVEPOINT launch_workflow_pvt;


      -- Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(
                                      l_api_version ,
                                      p_api_version ,
                                      l_api_name    ,
                                      G_PKG_NAME    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message listif p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

      -- The workflow is to be launched only after the
      -- service request has been commited
      -- (make sure the current record is commited before launching the workflow.
      -- This is necessary because the workflow process needs to obtain a lock on the record) and
      -- the status of the service request should be OPEN



      IF (p_incident_id IS NOT NULL AND p_incident_status_id IS NOT NULL) THEN

        OPEN l_servereq_csr;
--        LOOP
        FETCH l_servereq_csr INTO l_servereq_csr_rec;
--        EXIT WHEN l_servereq_csr%NOTFOUND;

        -- Construct the unique item key
        SELECT cs_wf_process_id_s.NEXTVAL INTO l_wf_process_id FROM DUAL;
        l_itemkey := l_servereq_csr_rec.incident_number || '-' || to_char(l_wf_process_id);

        -- Update the workflow process ID of the request
        IF TO_NUMBER(FND_PROFILE.VALUE('USER_ID')) IS NOT NULL THEN
          UPDATE CS_INCIDENTS_ALL_B
          SET workflow_process_id = l_wf_process_id,
          last_updated_by = TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
          last_update_date = sysdate
          WHERE CURRENT OF l_ServeReq_csr;
        ELSE
          UPDATE CS_INCIDENTS_ALL_B
          SET workflow_process_id = l_wf_process_id,
          last_update_date = sysdate
          WHERE CURRENT OF l_ServeReq_csr;
        END IF;

COMMIT ; --GASANKAR

        -- Create and launch the Workflow process if the status of the SR is OPEN
        IF (p_source = 'FORM') THEN
--        AND (l_servereq_csr_rec.autolaunch_workflow_flag = 'Y') THEN

          wf_engine.CreateProcess (Itemtype => 'SERVEREQ',
                                   Itemkey  => l_itemkey,
                                   process  => l_servereq_csr_rec.workflow);

          wf_engine.startprocess (itemtype => 'SERVEREQ',
                                  itemkey  => l_itemkey);

	   -- Launch the workflow to get customer approval if the package is being called from workflow
        ELSIF (p_source IS NULL) THEN

          wf_engine.CreateProcess (Itemtype => 'SERVEREQ',
                                   Itemkey  => l_itemkey,
                                   process  => 'CUG_GENERIC_WORKFLOW');

          wf_engine.startprocess (itemtype => 'SERVEREQ',
                                  itemkey  => l_itemkey);

        END IF;



 COMMIT;
--        END LOOP;
--        CLOSE l_ServeReq_csr;

      END IF;

	-- Endof API body.

    -- Standard check for p_commit.

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;


    -- Standard call to get messgage count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_get (
                              p_count   => x_msg_count,
                              p_data    => x_msg_data
                              );


    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        IF (l_servereq_csr%ISOPEN) THEN
          CLOSE l_servereq_csr;
        END IF;
--        ROLLBACK TO launch_workflow_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
                                (
                                p_count     => x_msg_count,
                                p_data      => x_msg_data
                                );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_servereq_csr%ISOPEN) THEN
          CLOSE l_servereq_csr;
        END IF;
--        ROLLBACK TO launch_workflow_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
                                (
                                p_count     => x_msg_count,
                                p_data      => x_msg_data
                                );

      WHEN OTHERS THEN
        IF (l_servereq_csr%ISOPEN) THEN
          CLOSE l_servereq_csr;
        END IF;
--        ROLLBACK TO launch_workflow_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level
          ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg
                                (
                                G_PKG_NAME,
                                l_api_name
                                );
        END IF;
        FND_MSG_PUB.Count_And_Get
                                (
                                p_count => x_msg_count,
                                p_data => x_msg_data
                                );

  END launch_workflow;

END;

/
