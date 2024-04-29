--------------------------------------------------------
--  DDL for Package Body JTF_FM_PROCESS_REQUEST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_PROCESS_REQUEST_WF" AS
/* $Header: jtffmwfb.pls 120.0 2005/05/11 08:14:28 appldev ship $   $*/
/*PROCEDURE start_fulfillment_request(item_type   	IN 	VARCHAR2,
																		item_key	 		IN	VARCHAR2,
																		content_xml	IN	VARCHAR2,
																		item_user_key 		IN 	VARCHAR2,
																		content_id	IN	NUMBER,
																		Request_id	IN 	NUMBER,
																		msg_count		IN	VARCHAR2,
																		msg_data		IN	VARCHAR2,
																		user_id			IN 	VARCHAR2,
																		Result			IN OUT VARCHAR2,
																		status			OUT	VARCHAR2) is
																		x_return_status varchar2(10);*/
PROCEDURE start_fulfillment_request(item_type   						IN 			VARCHAR2,
																		item_key	 							IN			VARCHAR2,
																		item_user_key 					IN 			VARCHAR2,
																		p_content_xml						IN			VARCHAR2,
																		p_content_id						IN			NUMBER,
																		p_Request_id						IN 			NUMBER,
																		p_template_id         	IN  		NUMBER ,
																		p_subject             	IN  		VARCHAR2,
																		p_party_id 			   			IN  		NUMBER ,
																		p_party_name 			   		IN  		VARCHAR2 ,
																		p_user_id								IN 			VARCHAR2,
																		p_priority              IN  		NUMBER ,
																		p_source_code_id        IN			NUMBER,
																		p_source_code						IN			VARCHAR2,
																		p_object_type			   		IN  		VARCHAR2 ,
																		p_object_id 			   		IN  		NUMBER ,
																		p_order_id			   			IN  		NUMBER ,
																		p_doc_id				   			IN  		NUMBER ,
																		p_doc_ref 			   			IN  		VARCHAR2 ,
																		p_server_id			   			IN  		NUMBER ,
																		p_queue_response		  	IN  		VARCHAR2,
																		p_extended_header		  	IN  		VARCHAR2 ,
																		p_api_version 					IN 			NUMBER,
																		p_init_msg_list 				IN 			VARCHAR2,
																		p_commit								IN 			VARCHAR2,
																		p_validation_level   		IN  		NUMBER ,
																		x_Result								IN OUT NOCOPY	VARCHAR2,
																		x_msg_count							IN OUT NOCOPY	VARCHAR2,
																		x_msg_data							IN OUT NOCOPY	VARCHAR2,
																		x_return_status					IN OUT NOCOPY	VARCHAR2)	is
begin
	--intialise the workflow attributes
wf_engine.SetItemUserKey ( ItemType	=> Item_Type,
			   ItemKey	=> Item_Key,
 			   UserKey	=> Item_User_Key);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'CONTENT_XML',
			    avalue	=>  p_content_xml);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'API_VERSION',
			    avalue	=>  p_api_version);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'INIT_MSG_LIST',
			    avalue	=>  p_init_msg_list);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'COMMIT',
			    avalue	=>  p_commit);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'VALIDATION_LEVEL',
			    avalue	=>  p_validation_level);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'TEMPLATE_ID',
			    avalue	=>  p_template_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'SUBJECT',
			    avalue	=>  p_subject);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'PARTY_ID',
			    avalue	=>  p_party_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'PARTY_NAME',
			    avalue	=>  p_party_name);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'PRIORITY',
			    avalue	=>  p_priority);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'SOURCE_CODE_ID',
			    avalue	=>  p_source_code_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'SOURCE_CODE',
			    avalue	=>  p_source_code);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'OBJECT_TYPE',
			    avalue	=>  p_object_type);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'OBJECT_ID',
			    avalue	=>  p_object_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'ORDER_ID',
			    avalue	=>  p_order_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'DOC_ID',
			    avalue	=>  p_doc_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'DOC_REF',
			    avalue	=>  p_doc_ref);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'SERVER_ID',
			    avalue	=>  p_server_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'QUEUE_RESPONSE',
			    avalue	=>  p_queue_response);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'EXTENDED_HEADER',
			    avalue	=>  p_extended_header);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'CONTENT_ID',
			    avalue	=>  p_content_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'REQUEST_ID',
			    avalue	=>  p_request_id);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'RESULT',
			    avalue	=>  x_result);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'MSG_COUNT',
			    avalue	=>  x_msg_count);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'MSG_DATA',
			    avalue	=>  x_msg_data);
wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'USER_ID',
			    avalue	=>  p_user_id);
/*wf_engine.SetItemAttrText ( itemtype 	=> Item_Type,
	      		    itemkey  	=> Item_Key,
  	      		    aname 	=> 'RETURN_STATUS',
			    avalue	=>  x_return_status);*/
wf_engine.StartProcess    (	itemtype => Item_Type,
      				itemkey	 => Item_Key	 );
wf_engine.ItemStatus      (itemtype 	=> Item_Type,
	      		   itemkey	=> Item_Key,
	      		   status  	=> x_return_status,
	      		   result  	=> x_result);
--dbms_output.put_line('after item status   status '||x_return_status||' '||'result->'||x_result);
If x_result = 'SUCCESS'  and x_return_status ='COMPLETE' then
	--or x_result ='SUCCESS' and x_return_status='ACTIVE' then
	x_return_status := 'S' ;
else
	x_return_status := 'F';
end if ;
--dbms_output.put_line('about to leave start_fulfillment_request Item Status->'||' '||x_return_status||'item status result->'||' '||x_result);
end start_fulfillment_request;
PROCEDURE 	submit_fulfillment_request (itemtype	in VARCHAR2,
		  			    itemkey 	in VARCHAR2,
					    actid 	in NUMBER,
					    funcmode	in VARCHAR2,
					    resultout 	out nocopy VARCHAR2 ) is
l_init_msg_list	varchar2(100);
l_subject varchar2(100);
l_api_version number :=1.0;
l_commit  VARCHAR2(5) := FND_API.G_TRUE;
l_msg_data	varchar2(1000);
l_msg_count	number;
l_request_id	number;
l_validation_level number;
l_template_id number;
l_party_id	number;
l_party_name varchar2(100);
l_priority	number;
l_source_code_id	number;
l_source_code		number;
l_content_xml	varchar2(1000);
l_return_status varchar2(10);
l_object_type	varchar2(100);
l_object_id number;
l_order_id number;
l_doc_id number;
l_doc_ref varchar2(100);
l_extended_header varchar2(100);
l_server_id number;
result varchar2(10);
l_result varchar2(300);
l_user_id varchar2(30);
l_msg_index_out number;
begin
	 IF 	funcmode = 'RUN' then
 		--dbms_output.put_line('Submit_fulfillment_request(JTFFMWF1) ' || itemkey);
 	 l_api_version  			:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'API_VERSION' );
 	 l_init_msg_list			:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'INIT_MSG_LIST' );
 	 l_commit							:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'COMMIT' );
 	 l_validation_level 	:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'VALIDATION_LEVEL' );
	 l_subject  	 				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'SUBJECT' );
	 l_template_id  			:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'TEMPLATE_ID' );
	 l_party_id  					:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'PARTY_ID' );
	 l_party_name  				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'PARTY_NAME' );
	 l_priority  					:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'PRIORITY' );
	 l_source_code_id  		:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'SOURCE_CODE_ID' );
	 l_source_code 				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'SOURCE_CODE' );
	 l_object_type  			:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'OBJECT_TYPE' );
	 l_object_id  				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'OBJECT_ID' );
	 l_order_id  					:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'ORDER_ID' );
	 l_doc_id  						:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'DOC_ID' );
	 l_doc_ref  					:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'DOC_REF' );
	 l_server_id  				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'SERVER_ID' );
	 l_request_id  				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'QUEUE_RESPONSE' );
	 l_extended_header  	:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'EXTENDED_HEADER' );
	 l_request_id  				:= wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'REQUEST_ID' );
	 l_content_xml				:=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'CONTENT_XML' );
	 l_msg_count					:=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'MSG_COUNT' );
	 l_msg_data 					:=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'MSG_DATA' );
	 l_user_id 						:=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'USER_ID' );
 l_result 						:=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'RESULT' );
 --l_return_status				:=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'RETURN_STATUS' );
--dbms_output.put_line('before Submitting request'||'Result'||l_result|| 'return status '||l_return_status);
--if l_return_status ='S' and l_result = 'SUCCESS' then
	if  l_result = 'SUCCESS' then
	--dbms_output.put_line('entering submit request api');
  	JTF_FM_REQUEST_GRP.Submit_Request
    		( 	p_api_version 	=> l_api_version,
			p_commit 	=> l_commit,
			x_return_status => l_return_status,
			x_msg_count 	=> l_msg_count,
			x_msg_data 	=> l_msg_data,
			p_subject 	=> l_subject,
			p_user_id 	=> l_user_id,
	  		p_content_xml 	=> l_content_xml,
	  		p_request_id 	=> l_request_id
    						);
    	---------------------------------------------
    	IF (l_msg_count >= 1) and l_return_status <>'S' THEN
  FOR j in  1..l_msg_count LOOP
    FND_MSG_PUB.Get (   p_msg_index    => j,
                        p_encoded => FND_API.G_FALSE,
                                p_data        => l_msg_data ,
                        p_msg_index_out => l_msg_index_out);
         --DBMS_OUTPUT.PUT_LINE(l_msg_data);
   END LOOP;
 end if ;
    	------------------------------------------------
    --dbms_output.put_line('return status after submit request api is->'||' '||l_return_status);
    IF l_return_status = 'S' THEN
       resultout := 'COMPLETE:SUCCESS';
    ELSE
       resultout := 'COMPLETE:FAIL';
    END IF;
	end if ;
	 wf_engine.SetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'RESULT',avalue => resultout );
	 	--dbms_output.put_line('Result out from submit_fulfill_request->'||resultout);
end if;
	exception
		when others then
			--
		wf_core.context('JTFFMWF','Submit_fulfillment_request',itemtype, itemkey, to_char(actid), funcmode);
		raise;
	end submit_fulfillment_request;
PROCEDURE 	Check_request_result (itemtype	in VARCHAR2,
		  			    itemkey 	in VARCHAR2,
					    actid 	in NUMBER,
					    funcmode	in VARCHAR2,
					    resultout 	out nocopy VARCHAR2 ) is
l_result varchar2(100);
begin
 IF 	funcmode = 'RUN' then
  --dbms_output.put_line('Entered into check result node');
  l_result :=wf_engine.GetItemAttrText( itemtype => itemtype, itemkey => itemkey, aname  => 'RESULT' );
  --dbms_output.put_line(l_result);
if l_result = 'COMPLETE:SUCCESS' then
resultout :='COMPLETE:SUCCESS';
else
 resultout :='COMPLETE:FAIL';
end if;
--dbms_output.put_line('Result in check result-> '||' '||resultout);
end if;
end check_request_result;
---------------------------
PROCEDURE schedule_Callback 		 (itemtype		in VARCHAR2,
		  				   	  							itemkey 		in VARCHAR2,
						  	  								actid 		in NUMBER,
							  									funcmode		in VARCHAR2,
							  									result 	out nocopy VARCHAR2 ) is
Begin
-- dbms_output.put_line('Schedule Callback (JTFFMWF) ' || itemkey); --FOR TEST ONLY
If funcmode = 'RUN' then
	result := 'COMPLETE:';
--dbms_output.put_line('in schedule callback');
end if ;
exception
	when others then
		--
	wf_core.context('JTFFMWF','Schedule Callback',itemtype, itemkey, to_char(actid), funcmode);
	raise;
end schedule_Callback;
----------------------------
PROCEDURE check_if_Callback_required 		 (itemtype		in VARCHAR2,
		  				   	  							itemkey 		in VARCHAR2,
						  	  								actid 		in NUMBER,
							  									funcmode		in VARCHAR2,
							  									result 	out nocopy VARCHAR2 ) is
Begin
-- dbms_output.put_line('schedule Callback (JTFFMWF) ' || itemkey); --FOR TEST ONLY
If funcmode = 'RUN' then
	result := 'COMPLETE:YES';
	--dbms_output.put_line('in check if callback required');
end if ;
exception
	when others then
		--
	wf_core.context('JTFFMWF','Check if callback required',itemtype, itemkey, to_char(actid), funcmode);
	raise;
end check_if_callback_required;
--------------------------
PROCEDURE verify_external 		 (itemtype		in VARCHAR2,
		  				   	  							itemkey 		in VARCHAR2,
						  	  								actid 		in NUMBER,
							  									funcmode		in VARCHAR2,
							  									result 	out nocopy VARCHAR2 ) is
Begin
-- dbms_output.put_line('schedule Callback (JTFFMWF) ' || itemkey); --FOR TEST ONLY
If funcmode = 'RUN' then
	result := 'COMPLETE:TRUE';
	--dbms_output.put_line('in verify external'||result);
end if ;
exception
	when others then
		--
	wf_core.context('JTFFMWF','verify external',itemtype, itemkey, to_char(actid), funcmode);
	raise;
end verify_external;
--------------------------------
PROCEDURE verification_failed 		 (itemtype		in VARCHAR2,
		  				   	  							itemkey 		in VARCHAR2,
						  	  								actid 		in NUMBER,
							  									funcmode		in VARCHAR2,
							  									result 	out nocopy VARCHAR2 ) is
Begin
-- dbms_output.put_line('schedule Callback (JTFFMWF) ' || itemkey); --FOR TEST ONLY
If funcmode = 'RUN' then
	result := 'ERROR:';
	--dbms_output.put_line('in verification failed');
end if ;
exception
	when others then
		--
	wf_core.context('JTFFMWF','verification failed',itemtype, itemkey, to_char(actid), funcmode);
	raise;
end verification_failed;
end jtf_fm_process_request_wf;


/
