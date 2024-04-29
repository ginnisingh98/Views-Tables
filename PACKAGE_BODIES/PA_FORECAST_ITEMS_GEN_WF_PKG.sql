--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_ITEMS_GEN_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_ITEMS_GEN_WF_PKG" AS
/* $Header: PARFIWFB.pls 120.1 2005/08/19 16:51:56 mwasowic noship $ */
	l_cannot_acquire_lock		EXCEPTION;
------------------------------------------------------------------------------------------------------------------
-- This procedure will launch the work flow for forecast item generation.
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_assignment_id              NUMBER            YES       It store the assignment id
-- p_resource_id                NUMBER            YES       It store the resource id
-- p_asgmt_start_date           DATE              YES       It store the assignment start date
-- p_asgmt_end_date             DATE              YES       It store the assignment end date
-- p_action_mode                VARCHAR2          YES       It store the action mode i.e. MODIFY OR DELETE
--
-- Out parameters
--
--------------------------------------------------------------------------------------------------------------------
PROCEDURE Launch_WorkFlow_Fi_Gen          ( p_assignment_id     IN     NUMBER,
                                            p_resource_id       IN     NUMBER,
                                            p_start_date        IN     DATE,
                                            p_end_date          IN     DATE,
                                            p_process_mode      IN     VARCHAR2,
                                            x_return_status     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count         OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                            x_msg_data          OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS

   l_item_type VARCHAR2(8):='PARFIGEN';
   l_item_key  VARCHAR2(10);
   l_result    VARCHAR2(10);
   l_x_return_status               VARCHAR2(50);
   l_lock_for                      VARCHAR2(5);
   l_x_msg_count                   NUMBER;
   l_x_msg_data                    VARCHAR2(50);
   l_name                          pa_organizations_expend_v.name%TYPE;
   l_save_thresh                   NUMBER ;
   l_project_id                    NUMBER;
   l_wf_type_code                  VARCHAR2(30);
   l_err_code                NUMBER := 0;
   l_err_stage               VARCHAR2(2000);
   l_err_stack               VARCHAR2(2000);

BEGIN
   x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- User lock for the given assignment id
/*    l_lock_for  := 'ASGMT';                   Fixed bug#1612856
  IF ( NVL(p_assignment_id,0) <> 0 ) THEN
   IF (PA_FORECAST_ITEMS_UTILS.Set_User_Lock (p_assignment_id,l_lock_for) <> 0) THEN
      RAISE l_cannot_acquire_lock;
   END IF;
 END IF; */



   -- Taking unique id for the work flow
   SELECT  'FI-' || TO_CHAR(wf_forecast_item_gen_s.NEXTVAL)
   INTO  l_item_key
   FROM DUAL;


   l_wf_type_code := 'FORECAST_GENERATION';

   IF  NVL(p_assignment_id,0) <> 0 THEN

   	BEGIN

       		SELECT 	project_id INTO l_project_id
       		FROM 	pa_project_assignments
       		WHERE 	assignment_id = p_assignment_id;


   	EXCEPTION

       WHEN no_data_found THEN
       	-- In delete assignment the assignment will not exist
       	-- in pa_project_assignments
           l_project_id := null;
           l_wf_type_code := 'FORECAST_DELETION';
           null;
   	END;

   END IF;

   -- Setting thresold value to run the process in background
   l_save_thresh      := wf_engine.threshold ;

   IF wf_engine.threshold < 0 THEN
      wf_engine.threshold := l_save_thresh ;
   END IF;
   wf_engine.threshold := -1 ;
  IF p_assignment_id IS NOT NULL AND p_resource_id IS NULL THEN
  	-- Selecting orgnization name to initialize the work flow attribute

   	BEGIN

/*  Bug remmed out for bug 1777250 due to perf team request

     	SELECT 	name
     	INTO 	l_name
     	FROM 	pa_organizations_expend_v
     	WHERE 	organization_id = ( select expenditure_organization_id
                               FROM pa_project_assignments
                               WHERE assignment_id = p_assignment_id);

    and instead used the select statement below note that also called the org_name
    translation function.
*/

        select pa_expenditures_utils.GetOrgTlName(expenditure_organization_id)
        into l_name
        from pa_project_assignments
        where assignment_id = p_assignment_id;

  	EXCEPTION

     		WHEN NO_DATA_FOUND THEN
      		null;
  	END;

  ELSIF p_resource_id IS NOT NULL THEN

  	IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN

		BEGIN

                SELECT pa_expenditures_utils.GetOrgTlName(resource_organization_id)
                INTO l_name
                from pa_resources_denorm
                WHERE resource_Id = p_resource_id
                AND rownum = 1
                AND ((trunc(p_start_date) BETWEEN
                              trunc(resource_effective_start_date) AND
                           NVL(resource_effective_end_date,SYSDATE+1))
                       OR (trunc( p_end_date) BETWEEN
                            trunc(resource_effective_start_date) AND
                            NVL(resource_effective_end_date,SYSDATE+1))
                       OR ( trunc(p_start_date) <
                              trunc(resource_effective_start_date) AND
                             trunc(p_end_date)  >
                                NVL(resource_effective_end_date,SYSDATE+1)))
                ORDER BY resource_effective_start_date;


  		EXCEPTION

     		WHEN NO_DATA_FOUND THEN
			NULL;
		END;

        ELSIF p_start_date IS NOT NULL THEN

		BEGIN

		SELECT pa_expenditures_utils.GetOrgTlName(resource_organization_id)
		INTO   l_name
		FROM   pa_resources_denorm
		WHERE  resource_Id = p_resource_id
		AND    rownum = 1
		AND    trunc(p_start_date) BETWEEN trunc(resource_effective_start_date)
		 			       AND NVL(resource_effective_end_date,SYSDATE+1)
                ORDER BY resource_effective_start_date;

  		EXCEPTION

     		WHEN NO_DATA_FOUND THEN
			NULL;

		END;

	END IF;

  END IF;

   -- dbms_output.put_line('Create the process ');

   -- Creating the work flow process
   WF_ENGINE.CreateProcess( itemtype => l_item_type,
                            itemkey  => l_item_key,
                            process  => 'PA_FORECAST_ITEM_GEN') ;

   --  dbms_output.put_line('Set the attribute 1');

   -- Setting the attribute value for assignment id
   WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type,
                                itemkey  => l_item_key,
                                aname    => 'ASSIGNMENT_ID',
                                avalue   => p_assignment_id);

   -- Setting the attribute value for resource id
   -- dbms_output.put_line('Set the attribute 2');
   WF_ENGINE.SetItemAttrNumber( itemtype => l_item_type,
                                itemkey  => l_item_key,
                                aname    => 'RESOURCE_ID',
                                avalue   => p_resource_id);

   -- Setting the attribute value for asignment start date
   -- dbms_output.put_line('Set the attribute 3');
   WF_ENGINE.SetItemAttrDate( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'ASGMT_START_DATE',
                              avalue   => p_start_date);

   -- Setting the attribute value for assignment end date
   -- dbms_output.put_line('Set the attribute 4');
   WF_ENGINE.SetItemAttrDate( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'ASGMT_END_DATE',
                              avalue   => p_end_date);

   -- Setting the attribute value for process mode
   -- dbms_output.put_line('Set the attribute 5');
   WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'PROCESS_MODE',
                              avalue   => p_process_mode);

   -- Setting the attribute value for orgnization name
   -- dbms_output.put_line('Set the attribute 6');
   WF_ENGINE.SetItemAttrText( itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'ORGANIZATION_NAME',
                              avalue   => l_name );

   -- Setting the attribute value for Project Resource Administrator
   -- dbms_output.put_line('Set the attribute 7');
        WF_ENGINE.SetItemAttrText (     itemtype        => l_item_type,
                                        itemkey         => l_item_key,
                                        aname           => 'PROJECT_RESOURCE_ADMINISTRATOR',
                                        avalue          => 'PASYSADMIN');

   -- dbms_output.put_line('Start the process ');

   -- Starting the work flow process and calling work flow api internaly
   --  dbms_output.put_line('Set the attribute 8');
   WF_ENGINE.StartProcess( itemtype => l_item_type,
                           itemkey  => l_item_key);


  IF p_assignment_id IS NOT NULL THEN

   	PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => l_wf_type_code
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(l_project_id)
                ,p_entity_key2         => to_char(p_assignment_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );
  ELSE

   	PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => l_wf_type_code
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(-99)
                ,p_entity_key2         => to_char(p_resource_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

  END IF;
   --Setting the original value
   wf_engine.threshold := l_save_thresh;
EXCEPTION
   WHEN l_cannot_acquire_lock THEN
       PA_FORECAST_ITEMS_UTILS.log_message('Unable to set lock for ' || to_char(p_assignment_id));
       x_return_status    := FND_API.G_RET_STS_ERROR;

-- COMMIT;
END Launch_WorkFlow_Fi_Gen;



------------------------------------------------------------------------------------------------------------------
-- This procedure will start the work flow processing.
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_item_type                  VARCHAR2          YES       It will be used to pass the parameter to work flow
-- p_item_key                   VARCHAR2          YES       It will be used to pass the parameter to work flow
-- p_actid                      NUMBER            YES       It will be used to pass the parameter to work flow
-- p_fucmode                    VARCHAR2          YES       It store the function mode i.e. RUN OR CANCEL
--
-- Out parameters
-- p_result                     VARCHAR2          YES       It store the result i.e. commit for work flow
--
--------------------------------------------------------------------------------------------------------------------
PROCEDURE Start_Forecast_WF( p_item_type	IN 	VARCHAR2,
                             p_item_key	        IN 	VARCHAR2,
                             p_actid	        IN 	NUMBER,
                             p_funcmode	        IN 	VARCHAR2,
                             p_result	        OUT 	NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

	l_assignment_id	        	NUMBER;
	l_resource_id	        	NUMBER;
	l_asgmt_start_date	       	DATE;
	l_asgmt_end_date	       	DATE;
	l_process_mode	        	VARCHAR2(30);
	l_orgz_name	        	pa_organizations_expend_v.name%TYPE;
	l_lock_for	        	VARCHAR2(5);
	li_lock_status          	NUMBER;
        l_x_return_status       	VARCHAR2(50);
        l_x_msg_count           	NUMBER;
        l_x_msg_data            	VARCHAR2(50);
BEGIN
      --  DBMS_OUTPUT.PUT_LINE('3');
      -- assigning just to differentiate b/w resource record and assignment record
      l_lock_for   := 'ASGMT';

  IF ( p_funcmode = 'RUN' ) THEN

        BEGIN
           l_assignment_id    := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                                                      		p_item_key,
                                                		'ASSIGNMENT_ID');

           l_resource_id      := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                                                      		p_item_key,
                                                		'RESOURCE_ID');

           l_asgmt_start_date := WF_ENGINE.GetItemAttrDate  (	p_item_type,
                                                      		p_item_key,
                                                		'ASGMT_START_DATE');

           l_asgmt_end_date   := WF_ENGINE.GetItemAttrDate  (	p_item_type,
                                                      		p_item_key,
                                                		'ASGMT_END_DATE');

           l_process_mode      := WF_ENGINE.GetItemAttrText  (	p_item_type,
                                                      		p_item_key,
                                                		'PROCESS_MODE');

           l_orgz_name         := WF_ENGINE.GetItemAttrText  (	p_item_type,
                                                      		p_item_key,
                                                		'ORGANIZATION_NAME');

        -- User lock for the given assignment id

        --  DBMS_OUTPUT.PUT_LINE('4');

        IF ( NVL(l_assignment_id,0) <> 0 ) THEN
           IF (PA_FORECAST_ITEMS_UTILS.Set_User_Lock (l_assignment_id,l_lock_for) <> 0) THEN
   	         RAISE l_cannot_acquire_lock;
           END IF;

          SAVEPOINT l_forecast_item_gen;
          IF (l_process_mode = 'DELETE') THEN
 	       -- Call the Forecast Deletion API.
               PA_FORECASTITEM_PVT.Delete_Forecast_Item(p_assignment_id  => l_assignment_id,
                                                        p_resource_id    => l_resource_id,
                                                        p_start_date     => l_asgmt_start_date,
                                                        p_end_date       => l_asgmt_end_date,
                                                        x_return_status  => l_x_return_status,
                                                        x_msg_count      => l_x_msg_count,
                                                        x_msg_data       => l_x_msg_data );
          ELSE
 	    -- Call the Forecast Generation API.
            -- DBMS_OUTPUT.PUT_LINE('4');

            PA_FORECASTITEM_PVT.Create_Forecast_Item(p_assignment_id  => l_assignment_id,
                                                     p_start_date     => l_asgmt_start_date,
                                                     p_end_date       => l_asgmt_end_date,
                                                     p_process_mode   => l_process_mode,
                                                     x_return_status  => l_x_return_status,
                                                     x_msg_count      => l_x_msg_count,
                                                     x_msg_data       => l_x_msg_data );
          END IF;
        ELSE
            PA_FORECASTITEM_PVT.Create_Forecast_Item(p_resource_id    => l_resource_id,
                                                     p_start_date     => l_asgmt_start_date,
                                                     p_end_date       => l_asgmt_end_date,
                                                     p_process_mode   => l_process_mode,
                                                     x_return_status  => l_x_return_status,
                                                     x_msg_count      => l_x_msg_count,
                                                     x_msg_data       => l_x_msg_data );
        END IF;

        IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
          p_result := 'COMPLETE:S';
        ELSIF (l_x_return_status = FND_API.G_RET_STS_ERROR ) THEN
          ROLLBACK to l_forecast_item_gen ;
          WF_ENGINE.SetItemAttrText
                               ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_MSG'
                               , avalue => l_x_msg_data
                               );

          p_result := 'COMPLETE:F';
        ELSIF (l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             ROLLBACK to l_forecast_item_gen ;
             WF_ENGINE.SetItemAttrText
                               ( itemtype => p_item_type
                               , itemkey  =>  p_item_key
                               , aname    => 'ERROR_MSG'
                               , avalue   => l_x_msg_data
                               );
             p_result := 'COMPLETE:F';
        END IF;
          -- COMMIT;
          -- p_result := 'COMPLETE:S';

        EXCEPTION
           WHEN l_cannot_acquire_lock THEN
             PA_FORECAST_ITEMS_UTILS.log_message('Unable to set lock for ' || to_char(l_assignment_id));
        END;

  ELSIF ( p_funcmode = 'CANCEL' ) THEN

    NULL;

  END IF;
-- p_result := 'COMPLETE:F';

  RETURN;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      -- Setting the attribute value for Error
      WF_ENGINE.SetItemAttrText
                               ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_MSG'
                               , avalue => SQLCODE||SQLERRM
                               );
      p_result := 'COMPLETE:F';
--      RAISE;
    WHEN OTHERS THEN
      -- Setting the attribute value for Error
      WF_ENGINE.SetItemAttrText
                               ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_MSG'
                               , avalue => SQLCODE||SQLERRM
                               );
      p_result := 'COMPLETE:F';
 /*     RAISE;  */
 END Start_Forecast_WF;

END PA_FORECAST_ITEMS_GEN_WF_PKG;

/
