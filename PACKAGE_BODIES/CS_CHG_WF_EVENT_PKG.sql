--------------------------------------------------------
--  DDL for Package Body CS_CHG_WF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHG_WF_EVENT_PKG" AS
/* $Header: cswfchgb.pls 115.0 2003/08/25 22:53:42 cnemalik noship $ */


  PROCEDURE Raise_SubmitCharges_Event(
        p_api_version            IN    NUMBER,
        p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
        p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
        p_Event_Code             IN    VARCHAR2,
        p_estimate_detail_id     IN    VARCHAR2,
        p_USER_ID                IN    NUMBER  DEFAULT FND_GLOBAL.USER_ID,
        p_RESP_ID                IN    NUMBER,
        p_RESP_APPL_ID           IN    NUMBER,
        p_est_detail_rec         IN    CS_Charge_Details_PUB.Charges_Rec_Type,
        p_wf_process_id          IN    NUMBER,
        p_owner_id		 IN    NUMBER,
        p_wf_manual_launch	 IN    VARCHAR2 ,
        x_wf_process_id          OUT   NOCOPY NUMBER,
        x_return_status          OUT   NOCOPY VARCHAR2,
        x_msg_count              OUT   NOCOPY NUMBER,
        x_msg_data               OUT   NOCOPY VARCHAR2) IS

    l_dummy             	VARCHAR2(240);
    l_initiator_role    	VARCHAR2(100);
    l_param_list		wf_parameter_list_t;
    l_event_key			VARCHAR2(240);
    l_event_id     		NUMBER;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    out_wf_process_id           NUMBER;
    l_INVALID_EVENT_ARGS	EXCEPTION;
    l_INVALID_EVENT_CODE	EXCEPTION;
    l_API_ERROR			EXCEPTION;


    BEGIN


    -- Initialize return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( p_estimate_detail_id IS NULL) THEN

      RAISE l_INVALID_EVENT_ARGS;

    ELSIF (p_wf_process_id IS NOT NULL) THEN
      --Do NOTHING. WE DON't HAVE TO RAISE a business event since this
      --is just a recursive call to update
      --the workflow process id when a workflow is launched.
	null;

    ELSE

       --  Derive Role from User ID
      IF (p_USER_ID IS NOT NULL) THEN
        CS_WF_AUTO_NTFY_UPDATE_PKG.get_fnd_user_role
             ( p_fnd_user_id        => p_USER_ID,
               x_role_name          => l_initiator_role,
               x_role_display_name  => l_dummy );
      END IF;


      /******************************************************************
        This section sets the Event Parameter List. These parameters are
        converted to workflow item attributes.
      *******************************************************************/

      wf_event.AddParameterToList(p_name => 'ESTIMATE_DETAIL_ID',
    			      p_value => p_est_detail_rec.Estimate_Detail_Id,
    			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'INCIDENT_ID',
    			      p_value => p_est_detail_rec.Incident_ID,
    			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'USER_ID',
    			      p_value => p_USER_ID,
    			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'RESP_ID',
			      p_value => p_RESP_ID,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'RESP_APPL_ID',
			      p_value => p_RESP_APPL_ID,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'INITIATOR_ROLE',
			      p_value => l_initiator_role,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'MANUAL_LAUNCH',
			      p_value => p_wf_manual_launch,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'ORG_ID',
			      p_value => p_est_detail_rec.org_id,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'ORDER_HEADER_ID',
			      p_value => p_est_detail_rec.order_header_id,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'ORDER_LINE_ID',
			      p_value => p_est_detail_rec.order_line_id,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'ORDER_LINE_TYPE_ID',
			      p_value => p_est_detail_rec.line_type_id,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'ORIGINAL_SOURCE_CODE',
			      p_value => p_est_detail_rec.original_source_code,
			      p_parameterlist => l_param_list);

      wf_event.AddParameterToList(p_name => 'SOURCE_CODE',
                              p_value => p_est_detail_rec.source_code,
                              p_parameterlist => l_param_list);


      BEGIN

      wf_event.AddParameterToList(p_name => 'WF_ADMINISTRATOR',
			        p_value => l_initiator_role,
			        p_parameterlist => l_param_list);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END;

     END IF;


        IF (p_Event_Code = 'SUBMIT_CHARGES') THEN

          SELECT cs_wf_process_id_s.nextval
          INTO l_event_id
          FROM dual;
          -- Construct the unique event key
          l_event_key := p_Estimate_Detail_Id ||'-'||to_char(l_event_id) || '-EVT';

          --RAISE the WF Business event.

          wf_event.raise(p_event_name => 'oracle.apps.cs.chg.Charges.submitted',
                         p_event_key  => l_event_key,
                         p_parameters => l_param_list);
        l_param_list.DELETE;

        ELSE

        RAISE l_INVALID_EVENT_CODE;

      END IF;

      -- Standard check of p_commit
      IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

END Raise_SubmitCharges_Event;




END CS_CHG_WF_EVENT_PKG;

/
