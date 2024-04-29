--------------------------------------------------------
--  DDL for Package Body OE_EXPORT_COMPLIANCE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_EXPORT_COMPLIANCE_WF" as
/* $Header: OEXWECSB.pls 120.3.12010000.4 2010/06/25 23:01:03 shrgupta ship $ */

PROCEDURE ECS_Request(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
l_header_id		NUMBER;
l_return_status		VARCHAR2(30);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_line_rec              OE_Order_PUB.Line_Rec_Type;
l_old_line_rec          OE_Order_PUB.Line_Rec_Type;
p_line_rec		OE_Order_PUB.Line_Rec_Type;
l_call_appl_id		NUMBER;
l_org_id		NUMBER;
l_organization_id	NUMBER;
l_result_out		VARCHAR2(100);
l_top_model_line_id	NUMBER;
l_dummy			VARCHAR2(2);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => to_number(itemkey)
          ,p_line_id                    => to_number(itemkey));

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'WITHIN DENIED PARTY WORKFLOW COVER ' ) ;
	END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ITEM KEY IS ' || ITEMKEY ) ;
        END IF;
	OE_STANDARD_WF.Set_Msg_Context(actid);

	SAVEPOINT Before_Lock;

	select top_model_line_id into l_top_model_line_id
	from oe_order_lines_all where
	line_id = to_number(itemkey);

        -- bug 4503620
        BEGIN
          IF l_top_model_line_id is not null then
	    select '1' into l_dummy
	    from  oe_order_lines_all
	    where line_id = l_top_model_line_id
	    for update; --commented for bug 6415831 -- nowait;
	  END IF;
        EXCEPTION
          WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add('OEXWECSB.pls: unable to lock the line:'||l_top_model_line_id,1);
             END IF;
           resultout := 'COMPLETE:INCOMPLETE';
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
              fnd_message.set_name('ONT', 'OE_LINE_LOCKED');
              OE_MSG_PUB.Add;
           END IF;
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           return;
        END; -- bug 4503620 ends

        OE_Line_Util.Lock_Row
            (p_line_id	        => to_number(itemkey),
             p_x_line_rec	=> l_line_rec,
	     x_return_status    => l_return_status);

    	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOCK ROW RETURNED WITH ERROR' , 1 ) ;
          END IF;
          resultout := 'COMPLETE:INCOMPLETE';
          OE_STANDARD_WF.Save_Messages;
          OE_STANDARD_WF.Clear_Msg_Context;
          return;
    	END IF;

        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => l_line_rec.line_id
          ,p_header_id                  => l_line_rec.header_id
          ,p_line_id                    => l_line_rec.line_id
          ,p_order_source_id            => l_line_rec.order_source_id
          ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
          ,p_change_sequence            => l_line_rec.change_sequence
          ,p_source_document_type_id    => l_line_rec.source_document_type_id
          ,p_source_document_id         => l_line_rec.source_document_id
          ,p_source_document_line_id    => l_line_rec.source_document_line_id );

/*	Here we call the procedure to populate the data into the interface  tables.
	After populating the interface tables we need to check invoke the Clearcross
	Adapter which processes the data in the interface table.
	If there is no data in the Response table then it means that the
	Clearcross Adapter has not got the result.
	This may be due to any reason like:
	(a) Technicall Error:
	This may be due to any technical error which has come up and this may include
	problems like Network Error,Server not responding and so on.
	(b) Functional Error:
		This may be due to error in the Clearcross adapter.

*/

-- 	This is the procedure which calls the Procedure for populating
--	the data into the Transaction tables.

--      This is the procedure which calls the Procedure for populating the data
--	into the Transaction tables.

        ONT_ITM_PKG.Process_ITM_REQUEST(
		p_line_rec 	  => l_line_rec
		,x_return_status  => l_return_status
		,x_result_out     => l_result_out);


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AFTER PROCESSING THE REQUEST :'||L_RETURN_STATUS ) ;
	END IF;


-- 	If error is generated by the Insert Procedure then we need to
--	capture the that error and do not allow the Workflow to process
--	further.
--
	 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF l_result_out = OE_GLOBALS.G_WFR_COMPLETE THEN
                resultout := 'NOTIFIED';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		RETURN;
	    END IF;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		resultout := 'COMPLETE:INCOMPLETE';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		RETURN;
        ELSE
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        RETURN;

  END IF; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --

  --  This is an event point called with the effect of the activity
--  be undone, for example when a process is reset to an earlier point
  --  due to a loop back.
  --

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_EXPORT_COMPLIANCE_WF', 'ECS_Request',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END ECS_Request;

/*
NAME :
       update_screening_results
BRIEF DESCRIPTION  :
       This API is called when OM receives a response from ITM for the
       export compliance screening results. It is responsible for updating
       the order line with the screening response. Introduced as a part of
       bug fix 8762350.
CALLER :
       1. Called from the workflow activity UPDATE_SCREENING_RESULTS.
RELEASE LEVEL :
       12.1.2 and higher.
PARAMETERS :
       standard WF activity parameters
*/

PROCEDURE Update_Screening_Results (
			       itemtype IN VARCHAR2,
			       itemkey IN VARCHAR2,
			       actid IN NUMBER,
			       funcmode IN VARCHAR2,
			       resultout IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
CURSOR C_Resp_Lines(cp_response_header_id NUMBER) IS
    SELECT wl.Error_Text, wl.denied_party_flag, wp.Party_name
    FROM wsh_itm_response_lines wl,
    wsh_itm_parties wp
    WHERE wl.Response_header_id = cp_response_header_id
    AND wp.party_id = wl.party_id;

CURSOR C_Get_Responses(cp_request_control_id NUMBER,
		       cp_request_set_id NUMBER)
    IS
    SELECT request_control_id, response_header_id, organization_id,
    nvl(original_system_line_reference, 0) line_id,
    nvl(original_system_reference, 0) header_id --bug 4503620
    FROM wsh_itm_request_control wrc
    WHERE request_control_id = nvl(cp_request_control_id, 0)
    AND wrc.application_id = 660
    UNION
    SELECT request_control_id, response_header_id, organization_id,
    nvl(original_system_line_reference, 0) line_id,
    nvl(original_system_reference, 0) header_id --bug 4503620
    FROM wsh_itm_request_control wrc
    WHERE request_set_id = nvl(cp_request_set_id, 0)
    AND wrc.application_id = 660;

l_api_name CONSTANT VARCHAR2(30) := 'Update_Screening_Results';
l_request_control_id NUMBER;
l_request_set_id NUMBER;
l_process_flag NUMBER;
l_response_header_id NUMBER;
l_denied_party_flag VARCHAR2(1);
l_line_id NUMBER;
l_header_id NUMBER; -- bug 4503620
l_top_model_line_id NUMBER;
l_activity_id NUMBER; -- 8762350
l_line_rec OE_ORDER_PUB.line_rec_type;
l_services WSH_ITM_RESPONSE_PKG.SrvTabTyp;
l_hold_source_rec OE_Holds_PVT.Hold_Source_REC_type;
l_return_status VARCHAR2(35);
l_data_error VARCHAR2(1);
l_system_error VARCHAR2(1);
l_activity_complete VARCHAR2(1);
l_hold_applied VARCHAR2(1);
l_dp_hold_flag VARCHAR2(1);
l_gen_hold_flag VARCHAR2(1);
l_interpreted_value VARCHAR2(30);
p_return_status VARCHAR2(30);
l_result_out VARCHAR2(30);
l_msg_count NUMBER := 0;
l_msg_data VARCHAR2(2000);
l_error_text VARCHAR2(2000);
l_dummy VARCHAR2(10);
l_org_id NUMBER;
l_serv INTEGER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

            OE_MSG_PUB.set_msg_context(
             p_entity_code           => 'LINE'
            ,p_entity_id             => to_number(itemkey)
            ,p_line_id               => to_number(itemkey));

	    OE_DEBUG_PUB.Add('Entering Update_screening_results...');

	    SAVEPOINT UPDATE_API;

	    -- MOAC change DBMS_APPLICATION_INFO.Set_Client_Info(l_org_id);

	    SELECT org_id
	    INTO   l_org_id
	    FROM   oe_order_lines_all
	    WHERE  line_id = to_number(itemkey);

	    mo_global.set_policy_context('S', l_org_id);

	    OE_LINE_UTIL.Query_Row ( p_line_id  => to_number(itemkey),
				     x_line_rec => l_line_rec);

	    l_line_id := l_line_rec.line_id;
            l_header_id := l_line_rec.header_id;

	    Oe_debug_pub.add('Calling shipping API to get request status...');

	    wsh_itm_util.get_compliance_status (
				    p_appliciation_id => 660,
				    p_original_sys_reference => l_line_rec.header_id,
				    p_original_sys_line_reference => l_line_rec.line_id,
				    x_process_flag => l_process_flag,
				    x_request_control_id => l_request_control_id,
				    x_request_set_id => l_request_set_id,
				    x_return_status => l_return_status
	                                        );

	    Oe_debug_pub.add('request_control_id : ' || l_request_control_id);
	    Oe_debug_pub.add('request_set_id : ' || l_request_set_id);
	    Oe_debug_pub.add('process_flag : ' || l_process_flag);
	    Oe_debug_pub.add('return status : ' || l_return_status);

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		Oe_debug_pub.add('get_compliance_status API returned error.!');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

            -- This select statement is used to lock the Top Model Line.
	    -- After the Top Model Line is Locked we go ahead the Lock the
	    -- individual Line.

	    SELECT top_model_line_id
	    INTO l_top_model_line_id
	    FROM oe_order_lines
	    WHERE line_id = l_line_id;

            BEGIN --bug 4503620
	     /*
		 Commenting the following block for 9273310
                 Locking the top model is not needed as no processing is done
                 on it, and it can potentially cause a locking issue.

		 IF l_top_model_line_id IS NOT NULL THEN
		    SELECT '1'
		    INTO l_dummy
		    FROM oe_order_lines_all
		    WHERE line_id = l_top_model_line_id
		    FOR UPDATE
		    --Commented for bug 6415831
		    NOWAIT; -- Uncommented for 8762350
		END IF;

                End of 9273310
	    */

		-- Wait until the lock on the row is released and then
		-- lock the row

		SELECT '1'
		INTO l_dummy
		FROM oe_order_lines_all
		WHERE line_id = l_line_id
		FOR UPDATE
		--Commented for bug 6415831
		NOWAIT; -- Uncommented for 8762350

		Oe_debug_pub.ADD('Lock on lines taken.');

                BEGIN  --9853045

  		   SELECT 'Y'
		   INTO l_dummy
		   FROM ONT_DBI_CHANGE_LOG
		   WHERE line_id = l_line_id
		   FOR UPDATE NOWAIT;

                EXCEPTION  -- Exception added as part of 9853045
	           WHEN NO_DATA_FOUND THEN
	            Oe_debug_pub.ADD('SKIPPING NO DATA FOUND from DBI Table Query');
                    NULL;
                   WHEN TOO_MANY_ROWS THEN
	            Oe_debug_pub.ADD('SKIPPING TOO MANY ROWS  from DBI Table Query');
                    NULL;
                END;  --9853045



		Oe_debug_pub.ADD('Lock on dbi taken.');

	    EXCEPTION
		WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
		    IF l_debug_level > 0 THEN
			oe_debug_pub.add('OEXWECSB.pls: unable to lock the line', 1);
		    END IF;
		    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
			OE_MSG_PUB.set_msg_context(
						   p_entity_code => 'LINE'
						   , p_entity_id => l_line_id
						   , p_header_id => l_header_id
						   , p_line_id => l_line_id);

			fnd_message.set_name('ONT', 'OE_LINE_LOCKED');
			OE_MSG_PUB.Add;
			OE_MSG_PUB.Save_API_Messages;
		    END IF;

		    ROLLBACK TO UPDATE_API;

		    resultout := 'COMPLETE:INCOMPLETE';

		    -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    RETURN;
	    END; --bug 4503620 ends

	    -- Check whether the Line is cancelled

	    IF l_line_rec.cancelled_flag = 'Y' THEN
		IF l_debug_level > 0 THEN
		    oe_debug_pub.add('The line ' || to_char(l_line_id) || 'is already cancelled.', 1);
		END IF;
		RETURN;
	    END IF;

	    OE_MSG_PUB.set_msg_context(
				       p_entity_code => 'LINE'
				       , p_entity_id => l_line_rec.line_id
				       , p_header_id => l_line_rec.header_id
				       , p_line_id => l_line_rec.line_id
				       , p_order_source_id => l_line_rec.order_source_id
				       , p_orig_sys_document_ref => l_line_rec.orig_sys_document_ref
				       , p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
				       , p_orig_sys_shipment_ref => l_line_rec.orig_sys_shipment_ref
				       , p_change_sequence => l_line_rec.change_sequence
				       , p_source_document_type_id => l_line_rec.source_document_type_id
				       , p_source_document_id => l_line_rec.source_document_id
				       , p_source_document_line_id => l_line_rec.source_document_line_id
				       );


	    -- If the user has choosen to override Screening

	    IF l_process_flag = 3 THEN

		IF l_debug_level > 0 THEN
		    oe_debug_pub.add('Override screening for line id:' || l_line_id, 3);
		END IF;

		-- Update Work flow Status Code

		OE_ORDER_WF_UTIL.Update_Flow_Status_Code (
							  p_line_id => l_line_id,
							  p_flow_status_code => 'EXPORT_SCREENING_COMPLETED',
							  x_return_status => l_return_status
							  );


		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    OE_STANDARD_WF.Save_Messages;
		    OE_STANDARD_WF.Clear_Msg_Context;
		    APP_EXCEPTION.Raise_Exception;
		END IF;

		resultout := 'COMPLETE:OVERRIDE';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;

		RETURN;
	    END IF;

	    -- Calling Response Analyser

	    FOR c_responses IN C_Get_Responses(l_request_control_id, l_request_set_id)
		LOOP
		BEGIN

		    l_request_control_id := c_responses.request_control_id;
		    l_response_header_id := c_responses.response_header_id;

		    WSH_ITM_RESPONSE_PKG.ONT_RESPONSE_ANALYSER (
								p_request_control_id => l_request_control_id,
								x_interpreted_value => l_interpreted_value,
								x_SrvTab => l_services,
								x_return_status => l_return_status
								);



		    IF l_debug_level > 0 THEN
			OE_DEBUG_PUB.Add('Response analyser return status :' || l_return_status, 1);
		    END IF;

		    -- Check for System or Data errors.

		    IF l_interpreted_value = 'SYSTEM' OR l_interpreted_value = 'DATA' THEN

			--  Check for errors in Response Headers.

			SELECT error_text
			INTO l_error_text
			FROM wsh_itm_response_headers
			WHERE response_header_id = l_response_header_id;

			IF l_interpreted_value = 'DATA' THEN
			    l_data_error := 'Y';
			    FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_DATA_ERROR');
			ELSE
			    l_system_error := 'Y';
			    FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_SYSTEM_ERROR');
			END IF;

			FND_MESSAGE.SET_TOKEN('ERRORTEXT', l_error_text);
			OE_MSG_PUB.Add;


			-- Check for errors in Response lines

			FOR c_error IN c_resp_lines(l_response_header_id)
			    LOOP
			    BEGIN
				l_error_text := c_error.error_text;

				IF l_interpreted_value = 'DATA' THEN
				    FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_DATA_ERROR');
				ELSE
				    FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_SYSTEM_ERROR');
				END IF;

				FND_MESSAGE.SET_TOKEN('ERRORTEXT', l_error_text);
				OE_MSG_PUB.Add;
			    END;
			END LOOP;
		    END IF; --Check for System or Data Errors

		    -- Get the Parties Denied.

		    FOR c_resplines IN c_resp_lines(l_response_header_id)
			LOOP
			BEGIN
			    IF c_resplines.denied_party_flag = 'Y' THEN
				FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_DENIED_PARTY');
				FND_MESSAGE.SET_TOKEN('DENIEDPARTY',
						      c_resplines.party_name);
				OE_MSG_PUB.Add;
				IF l_debug_level > 0 THEN
				    OE_DEBUG_PUB.Add('Party Name:' || c_resplines.party_name || ',denied');
				END IF;
			    END IF;
			END;
		    END LOOP;

		    -- Check for Denied Party Service


		    FOR l_serv IN 1..l_services.COUNT
			LOOP
			IF l_debug_level > 0 THEN
			    OE_DEBUG_PUB.Add('Service Result' || l_services(l_serv).Service_Result, 1);
			END IF;

			IF l_services(l_serv).Service_Type = 'DP' THEN
			    l_dp_hold_flag := l_services(l_serv).Service_Result;
			END IF;
			IF l_services(l_serv).Service_Type = 'OM_EXPORT_COMPLIANCE' AND
			    OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
			    l_gen_hold_flag := l_services(l_serv).Service_Result;
			END IF;
		    END LOOP;

		    l_hold_applied := l_dp_hold_flag;

		    IF l_interpreted_value = 'SUCCESS' THEN
			l_activity_complete := 'Y';
		    END IF;
		END;
	    END LOOP;

	    -- Progress Work Flow to Next Stage

	    IF l_debug_level > 0 THEN
		oe_debug_pub.add('Progress Work Flow to Next Stage...', 1);
	    END IF;


	    -- If one response has system error and other has data error we
	    -- consider that line has system error. If both the responses has
	    -- data error we consider thata line has data error.

	    IF l_system_error = 'Y' THEN
		-- we will never come here.
		NULL;

	    ELSIF l_data_error = 'Y' THEN

		OE_ORDER_WF_UTIL.Update_Flow_Status_Code
		(p_line_id => l_line_id,
		 p_flow_status_code => 'EXPORT_SCREENING_DATA_ERROR',
		 x_return_status => l_return_status
		 );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    resultout := 'COMPLETE:INCOMPLETE';
		    OE_STANDARD_WF.Save_Messages;
		    OE_STANDARD_WF.Clear_Msg_Context;
		    APP_EXCEPTION.Raise_Exception;
		END IF;

		resultout := 'COMPLETE:SCREENING_ERROR';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;

	    ELSIF l_gen_hold_flag = 'Y' AND
		OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

		OE_DEBUG_PUB.Add('Generic Hold!!!');

		-- The Hold_Id of the Generic Hold has been
		-- seeded as 23.


		l_hold_source_rec.hold_entity_code := 'O';
		l_hold_source_rec.hold_id          := 23;
		l_hold_source_rec.hold_entity_id   := l_line_rec.header_id;
		l_hold_source_rec.line_id          := l_line_rec.line_id;

		OE_HOLDS_PUB.Apply_Holds
		( p_api_version => 1.0
		  , p_validation_level => FND_API.G_VALID_LEVEL_NONE
		  , p_hold_source_rec => l_hold_source_rec
		  , x_return_status => l_return_status
		  , x_msg_count => l_msg_count
		  , x_msg_data => l_msg_data
		  );

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		    IF l_debug_level > 0 THEN
			oe_debug_pub.add('Applied Generic hold on line:' || l_line_rec.line_id, 1);
		    END IF;
		END IF;

		OE_Order_WF_Util.Update_Flow_Status_Code
		(p_line_id => l_line_id,
		 p_flow_status_code => 'EXPORT_SCREENING_COMPLETED',
		 x_return_status => l_return_status
		 );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    resultout := 'COMPLETE:INCOMPLETE';
		    OE_STANDARD_WF.Save_Messages;
		    OE_STANDARD_WF.Clear_Msg_Context;
		    APP_EXCEPTION.Raise_Exception;
		END IF;

		resultout := 'COMPLETE:HOLD_APPLIED';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;

	    ELSIF l_hold_applied = 'Y' THEN

		-- Check whether Denied party hold needs to be applied

		-- The Hold_Id of the Denied Party Hold has been
		-- seeded as 21.


		l_hold_source_rec.hold_entity_code := 'O';
		l_hold_source_rec.hold_id          := 21;
		l_hold_source_rec.hold_entity_id   := l_line_rec.header_id;
		l_hold_source_rec.line_id          := l_line_rec.line_id;

		OE_HOLDS_PUB.Apply_Holds
		( p_api_version => 1.0
		  , p_validation_level => FND_API.G_VALID_LEVEL_NONE
		  , p_hold_source_rec => l_hold_source_rec
		  , x_return_status => l_return_status
		  , x_msg_count => l_msg_count
		  , x_msg_data => l_msg_data
		  );

		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		    IF l_debug_level > 0 THEN
			oe_debug_pub.add('Applied denied party hold on line:' || l_line_rec.line_id, 1);
		    END IF;
		END IF;

		OE_Order_WF_Util.Update_Flow_Status_Code
		(p_line_id => l_line_id,
		 p_flow_status_code => 'EXPORT_SCREENING_COMPLETED',
		 x_return_status => l_return_status
		 );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    resultout := 'COMPLETE:INCOMPLETE';
		    OE_STANDARD_WF.Save_Messages;
		    OE_STANDARD_WF.Clear_Msg_Context;
		    APP_EXCEPTION.Raise_Exception;
		END IF;

		resultout := 'COMPLETE:HOLD_APPLIED';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;

	    ELSIF l_activity_complete = 'Y' THEN

		OE_ORDER_WF_UTIL.Update_Flow_Status_Code
		(p_line_id => l_line_id,
		 p_flow_status_code => 'EXPORT_SCREENING_COMPLETED',
		 x_return_status => l_return_status
		 );

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    resultout := 'COMPLETE:INCOMPLETE';
		    OE_STANDARD_WF.Save_Messages;
		    OE_STANDARD_WF.Clear_Msg_Context;
		    APP_EXCEPTION.Raise_Exception;
		END IF;

		resultout := 'COMPLETE:COMPLETE';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;

	    END IF;


	    OE_MSG_PUB.SAVE_MESSAGES(l_line_rec.line_id);

	    IF l_debug_level > 0 THEN
		oe_debug_pub.add('Exiting response api', 1);
	    END IF;
  END IF;

  -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --

  --  This is an event point called with the effect of the activity
  --  be undone, for example when a process is reset to an earlier point
  --  due to a loop back.
  --

  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  --  resultout := '';
  --  return;

EXCEPTION
    WHEN OTHERS THEN
	-- The line below records this function call in the error system
	-- in the case of an exception.
	wf_core.context('OE_EXPORT_COMPLIANCE_WF', 'Update_Screening_Results',
			itemtype, itemkey, to_char(actid), funcmode);
	-- start data fix project
	OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
					      p_itemtype => itemtype,
					      p_itemkey => itemkey);
        OE_STANDARD_WF.Save_Messages;
	OE_STANDARD_WF.Clear_Msg_Context;
	-- end data fix project

	ROLLBACK TO UPDATE_API;

	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg
	    ('OE_EXPORT_COMPLIANCE_WF',
	     'Update_Screening_Results'
	     );
	END IF;

	RAISE;

END Update_screening_results;

END OE_EXPORT_COMPLIANCE_WF;

/
