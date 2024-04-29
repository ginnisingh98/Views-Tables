--------------------------------------------------------
--  DDL for Package Body OE_DEALS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEALS_UTIL" as
/* $Header: OEXUDLSB.pls 120.10.12010000.2 2008/10/30 14:03:30 sgoli ship $ */

FUNCTION get_notified_activity(p_item_key varchar2 , p_item_type varchar2)
RETURN varchar2 IS
l_activity varchar2(30);
BEGIN

SELECT  WPA.activity_name INTO l_activity
		FROM WF_ITEM_ACTIVITY_STATUSES WIAS
			, WF_PROCESS_ACTIVITIES WPA
		WHERE WIAS.item_type 	= p_item_type
		  AND WIAS.item_key 	= p_item_key
		  AND WIAS.activity_status = 'NOTIFIED'
		  AND WPA.instance_id 	   = WIAS.process_activity;

return l_activity;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_activity := NULL;
END;


FUNCTION IS_WF_Activity(p_header_id IN NUMBER)
RETURN BOOLEAN  IS
l_root_activity VARCHAR2(30);
l_activity_present BOOLEAN;
l_item_type 		VARCHAR2(8);
l_TRANSACTION_PHASE_CODE	varchar2(1);
BEGIN

        select TRANSACTION_PHASE_CODE  into l_TRANSACTION_PHASE_CODE  FROM
		OE_ORDER_HEADERS_ALL where header_id = p_header_id;

	IF NVL(l_TRANSACTION_PHASE_CODE,'F')  = 'F' THEN
		l_item_type := 'OEOH';
	ELSE
	        l_item_type := 'OENH';
	END IF;

select ROOT_ACTIVITY INTO l_root_activity from wf_items where
   item_type=l_item_type and item_key=to_char(p_header_id);

l_activity_present := OE_VALIDATE_WF.HAS_ACTIVITY
                    ( P_process                => l_root_activity
                    , P_process_item_type      => l_item_type
                    , P_activity               => 'SUBMITTED_DEAL_WB'
                    , P_activity_item_type     => OE_GLOBALS.G_WFI_HDR
                    );
RETURN l_activity_present;
EXCEPTION
	WHEN OTHERS THEN
	RETURN FALSE;
END;

Function Validate_config (p_header_id IN NUMBER)
RETURN boolean IS

p_deleted_options_tbl  OE_Order_PUB.request_tbl_type;
p_updated_options_tbl  OE_Order_PUB.request_tbl_type;
l_return_status       VARCHAR2(1);
l_valid_config        VARCHAR2(10);
l_complete_config     VARCHAR2(10);
l_top_model_line_id   NUMBER;
l_continue            BOOLEAN := TRUE;
l_Config_header_id      NUMBER;
l_Config_rev_nbr        NUMBER;
l_Configuration_id      NUMBER;


cursor config_lines is  select  line_id, Config_header_id, Config_rev_nbr, Configuration_id
FROM OE_ORDER_LINES_ALL where header_id = p_header_id  AND
line_id= top_model_line_id  and open_flag='Y' and nvl(cancelled_flag,'N') ='N';

BEGIN
l_return_status   := FND_API.G_RET_STS_SUCCESS;
l_valid_config      :=  'TRUE';
l_complete_config   := 'TRUE';


OPEN config_lines;
LOOP
  FETCH  config_lines into  l_top_model_line_id, l_Config_header_id, l_Config_rev_nbr, l_Configuration_id ;
  EXIT WHEN config_lines%NOTFOUND OR  NOT l_continue;

  -- if the Config is NOT selected-- DONT progress, also DONT call validation
  IF(l_Config_header_id is NULL AND l_Config_rev_nbr is NULL AND l_Configuration_id is NULL ) THEN
     l_continue := FALSE;
  ELSE

    oe_config_util.Validate_Configuration
       	(p_model_line_id       => l_top_model_line_id,
         p_deleted_options_tbl => p_deleted_options_tbl,
      	 p_updated_options_tbl => p_updated_options_tbl,
         p_validate_flag       => 'Y',
       	 p_complete_flag       => 'N',
         x_valid_config        => l_valid_config,
       	 x_complete_config     => l_complete_config,
         x_return_status       => l_return_status);

     IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       IF (l_valid_config = 'TRUE' AND l_complete_config = 'TRUE' ) THEN
          l_continue := TRUE;
       ELSE
          l_continue := FALSE;
       END IF;
     ELSE
       l_continue := FALSE;
     END IF;
   END IF;
END LOOP;

CLOSE config_lines;
return  l_continue;

EXCEPTION
   WHEN OTHERS THEN
         IF config_lines%ISOPEN THEN
          CLOSE config_lines;
         END IF;
	 l_continue := FALSE;
  	 return  l_continue;
END;


--Bug 6870738 STARTS
FUNCTION HAS_SAVED_REQUEST( p_header_id IN NUMBER
                          , p_instance_id IN NUMBER
                          )
RETURN VARCHAR2
IS
   l_db_link               VARCHAR2(240);
   l_non_sim_deal_exists   VARCHAR2(1) := 'N';--BOOLEAN := FALSE;
   l_package 	           VARCHAR2(30) := 'QPR_PRICE_NEGOTIATION_PUB';
   l_function	           VARCHAR2(30) := 'HAS_SAVED_REQUESTS';
   l_quote_origin          NUMBER := 660;
   l_dynamicSqlString      VARCHAR2(2000);
BEGIN

   l_db_link	:= FND_PROFILE.VALUE('QPR_PN_DBLINK') ;

   IF l_db_link IS NOT NULL
   THEN
      l_db_link := '@' || l_db_link;
   END IF;


   l_dynamicSqlString := 'begin :l_non_sim_deal_exists := ';
	 l_dynamicSqlString := l_dynamicSqlString || l_package ||'.';
	 l_dynamicSqlString := l_dynamicSqlString || l_function || l_db_link ;
	 l_dynamicSqlString := l_dynamicSqlString || '(';
	 l_dynamicSqlString := l_dynamicSqlString || ':p_qoute_origin,';
	 l_dynamicSqlString := l_dynamicSqlString || ':p_qoute_header_id,';
	 l_dynamicSqlString := l_dynamicSqlString || ':p_instance_id); ';
	 l_dynamicSqlString := l_dynamicSqlString || ' end;';

   EXECUTE IMMEDIATE l_dynamicSqlString
                     USING  OUT l_non_sim_deal_exists,
                            IN l_quote_origin,
  			    IN p_header_id,
			    IN p_instance_id;

   RETURN l_non_sim_deal_exists;
EXCEPTION
WHEN OTHERS
THEN
   l_non_sim_deal_exists := 'E';
   RETURN l_non_sim_deal_exists;
END;
--Bug 6870738 ends

PROCEDURE CALL_DEALS_API(
	    p_header_id 	in NUMBER,
	    p_updatable_flag 	IN varchar2,
	    x_redirect_function out nocopy varchar2,
	    x_is_deal_compliant out nocopy varchar2,
	    x_rules_desc 	out nocopy varchar2,
	    x_return_status 	out nocopy varchar2,
	    x_msg_data 		out nocopy varchar2)

	IS
	l_package 		VARCHAR2(30) := 'QPR_PRICE_NEGOTIATION_PUB';
	l_procedure		VARCHAR2(30) := 'INITIATE_DEAL';
	l_instance_id		NUMBER;
	l_db_link		 varchar2(240);
	l_dynamicSqlString	VARCHAR2(2000);
	l_quote_origin NUMBER := 660;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

	BEGIN

	  	l_instance_id	:= FND_PROFILE.VALUE('QPR_CURRENT_INSTANCE') ;
                --If Instance ID is NULL, QPR API will fail so DONT call.
		IF l_instance_id is NULL THEN
			FND_MESSAGE.SET_NAME('ONT','OE_PROFILE_INCORRECT');
			FND_MESSAGE.SET_TOKEN('PROFILE_NAME', 'QPR_CURRENT_INSTANCE');
			OE_MSG_PUB.ADD;
			x_return_status :='E';
			x_is_deal_compliant := 'N';
		ELSE

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'CALL DEAL API' || l_procedure ) ;
			END IF;
			l_db_link	:= FND_PROFILE.VALUE('QPR_PN_DBLINK') ;

			IF l_db_link is NOT NULL THEN
				l_db_link := '@' || l_db_link;
			END IF;


			l_dynamicSqlString := ' begin ';
				 l_dynamicSqlString := l_dynamicSqlString || l_package ||'.';
				 l_dynamicSqlString := l_dynamicSqlString || l_procedure || l_db_link ;
				 l_dynamicSqlString := l_dynamicSqlString || '( ';
				 l_dynamicSqlString := l_dynamicSqlString || ':source_id, ';
		 		 l_dynamicSqlString := l_dynamicSqlString || ':source_ref_id,';
				 l_dynamicSqlString := l_dynamicSqlString || ':instance_id, ';
				 l_dynamicSqlString := l_dynamicSqlString || ':updatable, ';
				  -- OUT Parameters
				 l_dynamicSqlString := l_dynamicSqlString || ':redirect_function, ';
				 l_dynamicSqlString := l_dynamicSqlString || ':p_is_deal_compliant, ';
				 l_dynamicSqlString := l_dynamicSqlString || ':p_rules_desc, ';
				 l_dynamicSqlString := l_dynamicSqlString || ':x_return_status , ';
				 l_dynamicSqlString := l_dynamicSqlString || ':x_mesg_data ); ';
				 l_dynamicSqlString := l_dynamicSqlString || ' end; ';

			EXECUTE IMMEDIATE l_dynamicSqlString USING
							    IN l_quote_origin,
							    IN p_header_id,
							    IN l_instance_id,
							    IN p_updatable_flag,
							    OUT x_redirect_function,
							    OUT x_is_deal_compliant,
							    OUT x_rules_desc,
							    OUT x_return_status,
							    OUT x_msg_data;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS FROM l_is_deal_compliant: '||x_is_deal_compliant ) ;
	    oe_debug_pub.add(  'RETURN STATUS FROM l_deal_return_stat: '||x_return_status ) ;
	    oe_debug_pub.add(  'RETURN STATUS FROM QUERY: '||l_dynamicSqlString ) ;
	    oe_debug_pub.add(  'RETURN STATUS FROM x_msg_data: '|| x_msg_data ) ;
	END IF;


EXCEPTION
	  when others then
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'Raise Error in CALL_DEALs_API' ) ;
		END IF;
	  	x_return_status :='E';
		x_is_deal_compliant := 'N';
END CALL_DEALS_API;


/*
NAME-	COMPLIANCE_CHECK
DESC-	This procedure is called from the WF activity COMPLIANCE_CHECK
	Create the Deal.
	If Deal is Approved, complete with Result=Y, Update Order status to PRICING APPROVED
	If Deal is NOT Approved OR NOT created, complete with Result=N, Update Order status to PENDING PRICING APPROVAL
*/

PROCEDURE COMPLIANCE_CHECK(
	    itemtype  in varchar2,
	    itemkey   in varchar2,
	    actid     in number,
	    funcmode  in varchar2,
	    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
	IS
	l_header_id		NUMBER;
	L_ORDER_NUMBER   NUMBER;
	L_QUOTE_NUMBER   NUMBER;
	L_VERSION_NUMBER NUMBER;
	L_ORDER_TYPE_ID  NUMBER;
	L_ORG_ID         NUMBER;
	l_response_id    NUMBER;
	l_is_deal_compliant VARCHAR2(1);
	l_order_type_name   VARCHAR2(30);
	l_redirect_function VARCHAR2(240);
	l_deal_return_stat  VARCHAR2(1);
	l_deal_msg_data     VARCHAR2(2000);


	x_errbuf                 VARCHAR2(2000);
	l_rules_desc		  VARCHAR2(240);
	l_instance_id		NUMBER;

	l_dynamicSqlString	VARCHAR2(2000);
	l_updateable		VARCHAR2(1) := 'N';

        --Bug 6870738
        l_non_sim_deal_exists   VARCHAR2(1) := 'N';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	BEGIN
	  if (funcmode = 'RUN') then

	        l_header_id	:= to_number(itemkey);
		OE_STANDARD_WF.Set_Msg_Context(actid);
		select
			ORDER_NUMBER , QUOTE_NUMBER, VERSION_NUMBER, ORDER_TYPE_ID , ORG_ID
		INTO
		  	L_ORDER_NUMBER , L_QUOTE_NUMBER, L_VERSION_NUMBER, L_ORDER_TYPE_ID , L_ORG_ID
		FROM
			oe_order_headers_all where header_id= l_header_id;

	  	L_ORDER_NUMBER := nvl(L_ORDER_NUMBER, L_QUOTE_NUMBER);

	  	l_instance_id	:= FND_PROFILE.VALUE('QPR_CURRENT_INSTANCE') ;
                --If Instance ID is NULL, QPR API will fail so DONT call.
		IF l_instance_id is NULL THEN
			FND_MESSAGE.SET_NAME('ONT','OE_PROFILE_INCORRECT');
			FND_MESSAGE.SET_TOKEN('PROFILE_NAME', 'QPR_CURRENT_INSTANCE');
			OE_MSG_PUB.ADD;
			l_deal_return_stat :='E';
		ELSE

                        --Bug 6870738 starts
                        /*
                        Checking if a deal exists in NON SIMULATE mode.
                        In such case should not continue compliance check
                        */
                        l_non_sim_deal_exists := HAS_SAVED_REQUEST(l_header_id, l_instance_id);

                        IF l_non_sim_deal_exists = 'Y'
                        THEN
	        	   resultout := 'COMPLETE:N';
	        	   OE_STANDARD_WF.Save_Messages;
	        	   OE_STANDARD_WF.Clear_Msg_Context;
	        	   FND_MESSAGE.SET_NAME('ONT', 'OE_COMPLIANCE_ERROR_DEAL_EXIST');
	        	   OE_MSG_PUB.ADD;

                           RETURN;
                        END IF;
                        --Bug 6870738 ends

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'CALL DEAL API' ) ;
			END IF;

			CALL_DEALS_API(
				    p_header_id 	=> l_header_id,
				    p_updatable_flag 	=> 'Y',
				    x_redirect_function => l_redirect_function,
				    x_is_deal_compliant => l_is_deal_compliant,
				    x_rules_desc 	=> l_rules_desc,
				    x_return_status 	=> l_deal_return_stat,
	    			    x_msg_data 		=> l_deal_msg_data);

		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETURN STATUS FROM l_is_deal_compliant: '||l_is_deal_compliant ) ;
		    oe_debug_pub.add(  'RETURN STATUS FROM l_response_id: '||l_response_id ) ;
		    oe_debug_pub.add(  'RETURN STATUS FROM l_deal_return_stat: '||l_deal_return_stat ) ;
		    oe_debug_pub.add(  'RETURN STATUS FROM QUERY: '||l_dynamicSqlString ) ;
		END IF;

		IF nvl(l_deal_return_stat,'S') = 'E' OR nvl(l_is_deal_compliant,'N') = 'N' THEN
	        	resultout := 'COMPLETE:N';
			OE_STANDARD_WF.Save_Messages;
			OE_STANDARD_WF.Clear_Msg_Context;
			FND_MESSAGE.SET_NAME('ONT', 'OE_ORDER_COMPLIANCE_FAILED');
			FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', L_ORDER_NUMBER);
		        OE_MSG_PUB.ADD;
			IF (l_rules_desc is NOT NULL) THEN
				FND_MESSAGE.SET_NAME('ONT', 'OE_WF_EXCEPTION');
				FND_MESSAGE.SET_TOKEN('EXCEPTION', 'Rules Violated are: ' || l_rules_desc);
			        OE_MSG_PUB.ADD;
			END IF;
			return;
		ELSE
			UPDATE oe_order_headers_all      SET
		  	      flow_status_code = 'PRICING_APPROVED'
		  	WHERE header_id = l_header_id;

                        --Bug 7322917
                        --This is temporary. We need to update the flag using process order API.
                        --Even the above update statement has to be included in the call.
                        UPDATE OE_ORDER_LINES_ALL
                           SET CALCULATE_PRICE_FLAG = 'P'
                         WHERE header_id = l_header_id
                           AND open_flag='Y'
                           AND cancelled_flag='N';

			resultout := 'COMPLETE:Y';
			OE_STANDARD_WF.Save_Messages;
			OE_STANDARD_WF.Clear_Msg_Context;
			FND_MESSAGE.SET_NAME('ONT','OE_ORDER_COMPLIANCE_PASSED');
			FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', L_ORDER_NUMBER);
			OE_MSG_PUB.ADD;
			return;
		END IF;
	  END IF; -- End for 'RUN' mode

	  IF (funcmode = 'CANCEL') then
		resultout := 'COMPLETE';
		return;
	  END IF;
EXCEPTION
	  when others then
	    wf_core.context('OE_DEALS_UTIL', 'COMPLIANCE_CHECK',
	                    itemtype, itemkey, to_char(actid), funcmode);
	    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
	                                          p_itemtype => itemtype,
	                                          p_itemkey => itemkey);
	    OE_STANDARD_WF.Save_Messages;
	    OE_STANDARD_WF.Clear_Msg_Context;
	    raise;
END COMPLIANCE_CHECK;









/*
NAME-	Complete_Compliance_Eligible
DESC-	This procedure is called when user selects Action -CHECK_COMPLIANCE (p_accept = Y)
	OR Action-INVOKE_DEAL_WB (p_accept=N)
	Check if the WF is eligible for Pricing Approval, If NOT, throw error msg.
	If p-accept=y
		just complete the WF activity-Pricing eligible with result =Y
		The next WF activty COMPLIANCE_CHECK will create the DEAL.
	If p-accept=N
		Create the Deal
		Update the Order Status to PENDING_PRICING_APPROVAL ( NO longer DEAL_SUBMITTED)
		complete the WF activity-Pricing eligible with Result=N
*/

PROCEDURE Complete_Compliance_Eligible
			( p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE
			, p_header_id			IN 	NUMBER
			, p_accept			IN VARCHAR2
			, p_item_type 			IN VARCHAR2
			, x_return_status OUT NOCOPY VARCHAR2
			, x_msg_count OUT NOCOPY NUMBER
			, x_msg_data OUT NOCOPY VARCHAR2
			)  IS

	l_api_name              CONSTANT VARCHAR2(30) := 'COMPLETE_Compliance_eligible';
	l_api_version_number    CONSTANT NUMBER := 1.0;
	l_itemkey		VARCHAR2(30);
	l_Compliance_eligible	VARCHAR2(1);
	l_Compliance_errored_flag   VARCHAR2(1);
	l_order_source_id           NUMBER;
	l_orig_sys_document_ref     VARCHAR2(50);
	l_change_sequence           VARCHAR2(50);
	l_source_document_type_id   NUMBER;
	l_source_document_id        NUMBER;

	L_ORDER_NUMBER   NUMBER;
	l_quote_number   NUMBER;
	L_VERSION_NUMBER NUMBER;
	L_ORDER_TYPE_ID  NUMBER;
	L_ORG_ID         NUMBER;
	l_is_deal_compliant 	VARCHAR2(1);
	l_order_type_name   	VARCHAR2(30);
	x_errbuf            	VARCHAR2(2000);
	x_retcode           	NUMBER := 0;
	l_rules_desc		VARCHAR2(240);
	l_instance_id		NUMBER;

	l_quote_origin 		NUMBER := 660;
	l_dynamicSqlString	VARCHAR2(2000);
	l_package 		VARCHAR2(30) := 'QPR_PRICE_NEGOTIATION_PUB';
	l_procedure		VARCHAR2(30) := 'CREATE_PN_REQUEST';
	l_db_link		VARCHAR2(240);
	l_simulation		VARCHAR2(1) := 'N'; --For Submit to deals, simulation should be N
        l_result  varchar2(10);

	CURSOR Compliance_eligible IS
		SELECT 'Y'
		FROM WF_ITEM_ACTIVITY_STATUSES WIAS
			, WF_PROCESS_ACTIVITIES WPA
		WHERE WIAS.item_type 	= p_item_type
		  AND WIAS.item_key 	= l_itemkey
		  AND WIAS.activity_status = 'NOTIFIED'
		  AND WPA.activity_name    = 'PRICING_APPROVAL_ELIGIBLE'
		  AND WPA.instance_id 	   = WIAS.process_activity;

	CURSOR Compliance_errored IS
	       SELECT 'Y'
	       FROM WF_ITEM_ACTIVITY_STATUSES WIAS
			, WF_PROCESS_ACTIVITIES WPA
	       WHERE WIAS.item_type 	= p_item_type
	       AND WIAS.item_key 	= l_itemkey
	       AND WIAS.activity_status = 'ERROR'
	       AND WPA.activity_name 	= 'PRICING_APPROVAL_ELIGIBLE'
	       AND WPA.instance_id 	= WIAS.process_activity;

	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

	BEGIN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER OE_DEALS_UTIL.COMPLETE_COMPLIANCE_ELIGIBLE' , 1 ) ;
		END IF;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	    	--  Initialize message list.
		IF FND_API.to_Boolean(p_init_msg_list) THEN
        		OE_MSG_PUB.initialize;
		END IF;

		SELECT order_source_id, orig_sys_document_ref, change_sequence, source_document_type_id, source_document_id,
		     ORDER_NUMBER , quote_number, VERSION_NUMBER, ORDER_TYPE_ID , ORG_ID
		INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence, l_source_document_type_id, l_source_document_id,
		     L_ORDER_NUMBER , l_quote_number, L_VERSION_NUMBER, L_ORDER_TYPE_ID , L_ORG_ID
		FROM OE_ORDER_HEADERS_ALL
	 	WHERE HEADER_ID = p_header_id;

		L_ORDER_NUMBER := nvl(L_ORDER_NUMBER, L_QUOTE_NUMBER); --For Quote Order No is NULL

		OE_MSG_PUB.set_msg_context(
		      p_entity_code           => 'HEADER'
		     ,p_entity_id                  => p_header_id
		     ,p_header_id                  => p_header_id
		     ,p_line_id                    => null
		     ,p_order_source_id            => l_order_source_id
		     ,p_orig_sys_document_ref 	=> l_orig_sys_document_ref
		     ,p_orig_sys_document_line_ref => null
		     ,p_change_sequence            => l_change_sequence
		     ,p_source_document_type_id    => l_source_document_type_id
		     ,p_source_document_id         => l_source_document_id
		     ,p_source_document_line_id    => null );

		l_itemkey := to_char(p_header_id);

		OPEN Compliance_eligible;
		FETCH Compliance_eligible INTO l_Compliance_eligible;

		IF (Compliance_eligible%NOTFOUND) THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'Compliance Check NOT ELIGIBLE' ) ;
			END IF;
			OPEN Compliance_errored;
			FETCH Compliance_errored INTO l_Compliance_errored_flag;
	                IF (Compliance_errored%FOUND) THEN
			    FND_MESSAGE.SET_NAME('ONT','OE_ORDER_COMP_CHECK_ERRORED');
			    OE_MSG_PUB.ADD;
			    RAISE FND_API.G_EXC_ERROR;
	             	ELSE
			    FND_MESSAGE.SET_NAME('ONT','OE_ORDER_COMP_NOT_ELIGIBLE');
			    OE_MSG_PUB.ADD;
			    RAISE FND_API.G_EXC_ERROR;
		        END IF;
	        	CLOSE Compliance_errored;
		END IF;

		CLOSE Compliance_eligible;

		   OE_ORDER_UTIL.Lock_Order_Object
				(p_header_id	=> p_header_id
				,x_return_status	=> x_return_status
				);
		   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;

		OE_Standard_WF.OEOH_SELECTOR
		   (p_itemtype => p_item_type
		   ,p_itemkey => l_itemkey
		   ,p_actid => 12345
		   ,p_funcmode => 'SET_CTX'
		   ,p_result => l_result
		   );

		   WF_ENGINE.CompleteActivityInternalName
			( itemtype		=> p_item_type
			, itemkey		=> l_itemkey
			, activity		=> 'PRICING_APPROVAL_ELIGIBLE'
			, result		=> p_accept
			);
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'AFTER CALLING WF_ENGINE' ) ;
		  END IF;

	OE_MSG_PUB.set_msg_context(
	      p_entity_code           => 'HEADER'
	     ,p_entity_id                  => p_header_id
	     ,p_header_id                  => p_header_id
	     ,p_line_id                    => null
	     ,p_order_source_id            => l_order_source_id
	     ,p_orig_sys_document_ref 	=> l_orig_sys_document_ref
	     ,p_orig_sys_document_line_ref => null
	     ,p_change_sequence            => l_change_sequence
	     ,p_source_document_type_id    => l_source_document_type_id
	     ,p_source_document_id         => l_source_document_id
	     ,p_source_document_line_id    => null );


	OE_MSG_PUB.Count_And_Get
		(   p_count     =>      x_msg_count
		,   p_data      =>      x_msg_data
		);

	OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_DEALS_UTIL.COMPLETE_Compliance_eligible' , 1 ) ;
	END IF;

   EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXC ERROR OE_DEALS_UTIL.COMPLETE_Compliance_eligible' , 1 ) ;
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF (Compliance_eligible%ISOPEN) THEN
			CLOSE Compliance_eligible;
	   	END IF;
	   	IF (Compliance_errored%ISOPEN) THEN
			CLOSE Compliance_errored;
	   	END IF;
		OE_MSG_PUB.Count_And_Get
	                (   p_count     =>      x_msg_count
	                ,   p_data      =>      x_msg_data
			);
		OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXC UNEXPECTED ERROR OE_DEALS_UTIL.COMPLETE_Compliance_eligible' , 1 ) ;
		END IF;
	     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF (Compliance_eligible%ISOPEN) THEN
			CLOSE Compliance_eligible;
	   	END IF;
	   	IF (Compliance_errored%ISOPEN) THEN
			CLOSE Compliance_errored;
	   	END IF;
		OE_MSG_PUB.Count_And_Get
	                (   p_count     =>      x_msg_count
	                ,   p_data      =>      x_msg_data
	                );
		OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');

	WHEN OTHERS THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'OTHER ERROR OE_DEALS_UTIL.COMPLETE_Compliance_eligible' , 1 ) ;
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF (Compliance_eligible%ISOPEN) THEN
			CLOSE Compliance_eligible;
	   	END IF;
		IF (Compliance_errored%ISOPEN) THEN
			CLOSE Compliance_errored;
	   	END IF;
		IF      OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			   OE_MSG_PUB.Add_Exc_Msg
					( 'OE_DEALS_UTIL'
					, 'Complete_Compliance_Eligible'
					);
	     	END IF;
		OE_MSG_PUB.Count_And_Get
	                (   p_count     =>      x_msg_count
	                ,   p_data      =>      x_msg_data
			);
		OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');
END Complete_Compliance_Eligible;


--DEALS CALLING
Procedure Update_OM_with_deal(
        source_id in number,
        source_ref_id in number,
        event in varchar2,
        x_return_status out NOCOPY varchar2,
        x_message_name out NOCOPY varchar2)

IS
l_header_id NUMBER;
l_return_status		VARCHAR2(30);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_item_type 		VARCHAR2(8);
l_TRANSACTION_PHASE_CODE	varchar2(1);
l_status	varchar2(30);
l_new_status	varchar2(30);
l_init_msg_list        VARCHAR2(30) ;
l_result  varchar2(10);
l_notified_activity varchar2(30);
--l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_debug_level CONSTANT NUMBER := 5;

l_file_val  VARCHAR2(100);
BEGIN
     l_header_id := source_ref_id;

     --Comment this code to stop debugging
     oe_debug_pub.debug_on;
     oe_debug_pub.initialize;
     l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
     oe_Debug_pub.setdebuglevel(5);
     oe_debug_pub.add(  'deals called OM with-event' || EVENT || '-Header-' || l_header_id) ;

	select TRANSACTION_PHASE_CODE , flow_status_code into l_TRANSACTION_PHASE_CODE , l_status FROM
		OE_ORDER_HEADERS_ALL where header_id = l_header_id;

	IF NVL(l_TRANSACTION_PHASE_CODE,'F')  = 'F' THEN
		l_item_type := 'OEOH';
	ELSE
	        l_item_type := 'OENH';
	END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'Deals called OM with-event' || EVENT || '-Header-' || l_header_id) ;
	END IF;

	OE_ORDER_UTIL.Lock_Order_Object
			(p_header_id	=> l_header_id
			,x_return_status	=> l_return_status
			);
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		x_message_name := 'OE_LOCK_ROW_ALREADY_LOCKED';
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		x_message_name := 'OE_LOCK_ROW_ALREADY_LOCKED';
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	OE_STANDARD_WF.OEOH_SELECTOR(
		p_itemtype => l_item_type,
		p_itemkey => to_char(l_header_id),
		p_actid   => 12345,
		p_funcmode   => 'SET_CTX',
		p_result => l_result);

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_message_name := NULL;

	--No acionable when deal is created
	IF (event = 'CREATED') then
		NULL;
	END IF;

	--when deal is submitted take WF to route 2, change status to Pending Pricing Approval
	IF (event = 'SUBMITTED') THEN

	    IF OE_DEALS_UTIL.Validate_Config(p_header_id =>l_header_id) then

		OE_DEALS_UTIL.Complete_Compliance_Eligible
			(  p_init_msg_list		=> l_init_msg_list
			, p_header_id			=> l_header_id
			, p_accept			=> 'N'
			, p_item_type			=> l_item_type
			, x_return_status		=> x_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data);
		IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			UPDATE oe_order_headers_all      SET
				flow_status_code = 'PENDING_PRICING_APPROVAL'
				WHERE header_id = l_header_id;
		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_message_name := 'OE_ORDER_COMP_CHECK_ERRORED';
		END IF;
	     ELSE
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_message_name := 'OE_DEAL_CONFIG_FAIL';
	     END IF;
	END IF;


	--when deal is Approved just change status to Approved in deals, No wf change
	IF (event = 'APPROVED') THEN
		UPDATE oe_order_headers_all      SET
			flow_status_code = 'DEAL_APPROVED'
			WHERE header_id = l_header_id;
	END IF;

	--when deal is Accepted, change status to Pricing Approved, update order with deal,
	-- Progress WF, there can be 2 cases--direct accept 		--Pricing eligible->Pricing Approved
					    --Submit n Approve n accept --Submit Deal WB->Pricing Approved
	IF (event = 'ACCEPTED') THEN
		IF OE_DEALS_UTIL.Validate_Config(p_header_id =>l_header_id) then

			OE_DEALS_UTIL.Update_Order_with_Deal
  			( p_header_id			=> l_header_id
  			, p_item_type			=> l_item_type
  			, x_return_status		=> x_return_status
  			, x_msg_count			=> l_msg_count
  			, x_msg_data			=> l_msg_data);
			IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
				x_message_name := 'OE_DEAL_UPDATE_FAILED';
			END IF;

		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_message_name := 'OE_DEAL_CONFIG_FAIL';
		END IF;

	END IF;

	--when deal is CancElled, change status to entered/Draft,  wf moves to pricing eligible
	IF (event = 'CANCELED') THEN

		if (l_status <> 'ENTERED') THEN
			if(l_item_type='OEOH') then
				l_new_status:= 'ENTERED';
			else
				l_new_status:= 'DRAFT';
			end if;
			UPDATE oe_order_headers_all      SET
				flow_status_code = l_new_status
				WHERE header_id = l_header_id;
			l_notified_activity := get_notified_activity(to_char(l_header_id) , l_item_type);
			if( nvl(l_notified_activity,'!@#$@#$') = 'SUBMITTED_DEAL_WB') THEN
			    WF_ENGINE.CompleteActivityInternalName
				( itemtype		=> l_item_type
				, itemkey		=> to_char(l_header_id)
				, activity		=> l_notified_activity
				, result		=> 'REJECTED'
				);
			END IF;
		END IF;
	END IF;

        --Bug 7039864
        --Deal management requires message text and not the code
        IF x_message_name IS NOT NULL
        THEN
           FND_MESSAGE.SET_NAME('ONT',x_message_name);
           x_message_name := FND_MESSAGE.GET;
        END IF;
        oe_debug_pub.add('x_message_name: '||x_message_name);

EXCEPTION
WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
        --Bug 7039864
        IF x_message_name IS NOT NULL
        THEN
           FND_MESSAGE.SET_NAME('ONT',x_message_name);
           x_message_name := FND_MESSAGE.GET;
        END IF;
        oe_debug_pub.add('x_message_name: '||x_message_name);
END;


/*
NAME- 	Call_Process_Order
DESC-	Calls the Process Order API to Update the Order
	Update the Flow status Code of the Header.
	Query the view QPR_INT_DEAL_V to get the new values for all lines in the Header.
	Build the Line adjustment Info using the Modifier value from the Profile.
	Check if the Modifier is already applied to the Line.
        If modifier is applied then Operation is Update Else operation is Create
	Call Process Order API
*/

PROCEDURE Call_Process_Order (
    p_header_id IN NUMBER
    ,x_return_status OUT  NOCOPY varchar2
) IS
	x_msg_count			NUMBER;
	x_msg_data			VARCHAR2(2000);

   l_init_msg_list        VARCHAR2(30) ;
   l_line_tbl            Oe_Order_Pub.Line_Tbl_Type;
   l_line_adj_tbl        Oe_Order_Pub.Line_Adj_Tbl_Type;
   x_action_request_tbl  Oe_Order_Pub.Request_Tbl_Type;
   l_api_version_number   NUMBER := 1.0 ;
   x_msg_details         VARCHAR2(3000) ;
   x_msg_summary         VARCHAR2(3000) ;

   l_header_rec               Oe_Order_Pub.Header_Rec_Type;
   x_header_rec               Oe_Order_Pub.Header_Rec_Type;
   x_header_val_rec           Oe_Order_Pub.Header_Val_Rec_Type;
   x_Header_Adj_tbl           Oe_Order_Pub.Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl       Oe_Order_Pub.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl     Oe_Order_Pub.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl       Oe_Order_Pub.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl     Oe_Order_Pub.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl       Oe_Order_Pub.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl   Oe_Order_Pub.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                 Oe_Order_Pub.Line_Tbl_Type;
   x_line_val_tbl             Oe_Order_Pub.Line_Val_Tbl_Type;
   x_Line_Adj_tbl             Oe_Order_Pub.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl         Oe_Order_Pub.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl       Oe_Order_Pub.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl         Oe_Order_Pub.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl       Oe_Order_Pub.Line_Adj_Assoc_Tbl_Type;
   x_Line_Scredit_tbl         Oe_Order_Pub.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl     Oe_Order_Pub.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl           Oe_Order_Pub.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl       Oe_Order_Pub.Lot_Serial_Val_Tbl_Type;

   l_uom_code varchar2(30);
   l_currency_code varchar2(30);
   l_ordered_qty NUMBER;
   l_price NUMBER;
   l_payment_term_id NUMBER;
   l_ship_method_code varchar2(30);
   l_list_line_id	NUMBER;
   l_list_line_profile varchar2(30);

   l_list_header_id	NUMBER;

   l_sqlstmt            varchar2(1000);
   l_status		 varchar2(10) :='ACCEPT';
   l_db_link		 varchar2(240);
   l_continue varchar2(1);
   i number :=0;
   l_price_adj_id NUMBER ;
   l_adjusted_amount NUMBER;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   cursor lines_cursor is select line_id, unit_selling_price from oe_order_lines_all where header_id=p_header_id
   and open_flag='Y' and cancelled_flag='N';

BEGIN

    IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'call Process Order API ' , 1 ) ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := NULL ;
    x_msg_data      := NULL ;

    l_list_line_profile	:= FND_PROFILE.VALUE('QPR_DEAL_DIFF_MODIFIER') ;
    l_list_line_id := to_number(l_list_line_profile);
    l_db_link	:= FND_PROFILE.VALUE('QPR_PN_DBLINK') ;

    IF l_db_link is NOT NULL THEN
	l_db_link := '@' || l_db_link;
    END IF;

    IF l_list_line_id is NULL THEN
	FND_MESSAGE.SET_NAME('ONT','OE_PROFILE_INCORRECT');
	FND_MESSAGE.SET_TOKEN('PROFILE_NAME', 'QPR_DEAL_DIFF_MODIFIER');
	OE_MSG_PUB.ADD;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'Profile is NULL ' , 1 ) ;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'In call Process Order API-Modifier ' || l_list_line_id , 1 ) ;
    END IF;

    select list_header_id INTO l_list_header_id from qp_list_lines where list_line_id=l_list_line_id;
    --Update the Header,
    l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_header_rec.header_id := p_header_id;
    l_header_rec.operation  := OE_GLOBALS.G_OPR_UPDATE;
    l_header_rec.flow_status_code := 'PRICING_APPROVED';
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'In call Process Order API before Loop' , 1 ) ;
	END IF;

    for l_lines in  lines_cursor LOOP
   	l_continue:='Y';
        l_sqlstmt :=' SELECT  UOM_CODE ,CURRENCY_CODE ,ORDERED_QTY ,PRICE ,PAYMENT_TERM_ID ,SHIP_METHOD_CODE ' ||
     		  ' FROM QPR_INT_DEAL_V' || l_db_link ||
		  ' WHERE  SOURCE = 660 AND STATUS= ' || '''ACCEPT'''  ||
		  ' AND CHANGED = ' || '''Y''' ||
		  ' AND SOURCE_REF_HEADER_ID =  :p_header_id ' ||
		  ' AND SOURCE_REF_LINE_ID = :l_line_id ' ;

        IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'In call Process Order API before execute immediate' || l_lines.line_id , 1 ) ;
	    oe_debug_pub.add(  'In call Process Order API before execute immediate' || l_sqlstmt , 1 ) ;
	    oe_debug_pub.add(  'In call Process Order API before execute immediate' || p_header_id || '-' || l_status , 1 ) ;
	END IF;

	BEGIN
      		EXECUTE IMMEDIATE l_sqlstmt INTO
    		l_uom_code ,l_currency_code ,l_ordered_qty ,l_price ,l_payment_term_id ,l_ship_method_code
			   USING p_header_id, l_lines.line_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
	   	l_continue:='N';
	        oe_debug_pub.add(  'Exec immediate NO data found-Dont update this Line'  , 1 ) ;
	END;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'In call Process Order API execute immediate-' || l_continue, 1 ) ;
	END IF;

  IF (l_continue='Y') then
      i := i+1;
      --Order Line Information
      l_line_tbl(i) := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_tbl(i).header_id  := p_header_id;
      l_line_tbl(i).line_id  := l_lines.line_id;
      l_line_tbl(i).unit_selling_price   := l_price;
      l_line_tbl(i).operation  := OE_GLOBALS.G_OPR_UPDATE;
      l_line_tbl(i).calculate_price_flag := 'P';
      l_line_tbl(i).shipping_method_code := l_ship_method_code;
      l_line_tbl(i).order_quantity_uom := l_uom_code;
      l_line_tbl(i).ordered_quantity := l_ordered_qty;
      l_line_tbl(i).payment_term_id  := l_payment_term_id;

      BEGIN
	select price_adjustment_id, operand into l_price_adj_id, l_adjusted_amount from oe_price_adjustments where
                 header_id=p_header_id AND
		 line_id =l_lines.line_id  AND
		 list_line_id =l_list_line_id and list_header_id = l_list_header_id
	 	 and applied_flag='Y' and rownum <2;
      EXCEPTION
	WHEN OTHERS THEN --Modifier is NOT APPLIED
	l_price_adj_id := NULL;
      END;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'In call Process Order API Adjustment' , 1 ) ;
	END IF;

      --Order Line Adjustment Information
      l_line_adj_tbl(i) := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;
      l_line_adj_tbl(i).line_index  := i;  --adjustment for the line above
      l_line_adj_tbl(i).list_header_id  := l_list_header_id;  --oe_price_adjustments
      l_line_adj_tbl(i).list_line_id  := l_list_line_id;
      l_line_adj_tbl(i).arithmetic_operator  := 'AMT';
      l_line_adj_tbl(i).change_reason_code  := 'DEALS';
      l_line_adj_tbl(i).updated_flag  := 'Y';
      l_line_adj_tbl(i).applied_flag  := 'Y';
      IF  l_price_adj_id is NULL THEN
   	l_line_adj_tbl(i).operation  := OE_GLOBALS.G_OPR_CREATE;
   	l_line_adj_tbl(i).operand  :=  l_lines.unit_selling_price - l_price ;
   	l_line_adj_tbl(i).adjusted_amount  := l_lines.unit_selling_price - l_price ;
      ELSE
   	l_line_adj_tbl(i).operation  := OE_GLOBALS.G_OPR_UPDATE;
   	l_line_adj_tbl(i).price_adjustment_id :=   l_price_adj_id;
   	l_line_adj_tbl(i).operand  :=  l_lines.unit_selling_price - l_price + l_adjusted_amount;
   	l_line_adj_tbl(i).adjusted_amount  := l_lines.unit_selling_price - l_price + l_adjusted_amount;
      END IF;
   ELSE
      --Bug 7322917
      i := i+1;
      --Order Line Information
      l_line_tbl(i) := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_tbl(i).header_id  := p_header_id;
      l_line_tbl(i).line_id  := l_lines.line_id;
      l_line_tbl(i).operation  := OE_GLOBALS.G_OPR_UPDATE;
      l_line_tbl(i).calculate_price_flag := 'P';
   END IF;
  END LOOP;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'Status Before  PO API call ' || l_line_tbl.count, 1 ) ;
  END IF;

        Oe_Order_Pvt.Process_Order(
    		p_api_version_number    => '1.0'
		,   p_init_msg_list         => FND_API.G_FALSE
		,   x_return_status         => x_return_status
		,   x_msg_count             => x_msg_count
		,   x_msg_data              => x_msg_data
		   --IN PARAMETERS
		, p_x_header_rec		    => l_header_rec
		, p_x_line_tbl                => l_line_tbl
	    	, p_x_line_adj_tbl            => l_line_adj_tbl
	   , p_x_Header_Adj_tbl          => x_Header_Adj_tbl
	   , p_x_Header_price_Att_tbl    => x_Header_price_Att_tbl
	   , p_x_Header_Adj_Att_tbl      => x_Header_Adj_Att_tbl
	   , p_x_Header_Adj_Assoc_tbl    => x_Header_Adj_Assoc_tbl
	   , p_x_Header_Scredit_tbl      => x_Header_Scredit_tbl
	   , p_x_Line_price_Att_tbl      => x_Line_price_Att_tbl
	   , p_x_Line_Adj_Att_tbl        => x_Line_Adj_Att_tbl
	   , p_x_Line_Adj_Assoc_tbl      => x_Line_Adj_Assoc_tbl
	   , p_x_Line_Scredit_tbl        => x_Line_Scredit_tbl
	   , p_x_Lot_Serial_tbl          => x_Lot_Serial_tbl
	   , p_x_action_request_tbl      => x_action_request_tbl
	   );


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'Status after PO API call from deals ' || x_return_status, 1 ) ;
	END IF;
   	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'Raising Error', 1 ) ;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	FOR k IN 1 .. x_msg_count LOOP
    	  x_msg_data := oe_msg_pub.get( p_msg_index => k,p_encoded => 'F');
	END LOOP;

  WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'Status other ' || sqlerrm, 1 ) ;
	END IF;

END Call_Process_Order;

/*
NAME-Get_Deal_Info
Desc -	Calls the QPR API to get the Deal ID of the Deal created for an Order.
	The Deal_id and deal_status will be NULL if deal is NOT created
	The deal_status will be Y if deal is APPROVED
	The deal_status will be N if deal is created but NOT APPROVED
*/

PROCEDURE Get_Deal_Info
			( p_header_id	IN 	NUMBER
			, x_deal_status OUT NOCOPY VARCHAR2
			, x_deal_id 	OUT NOCOPY NUMBER
			)  IS

	x_errbuf                 VARCHAR2(2000);
	x_retcode                NUMBER;

	l_quote_origin 		NUMBER := 660;
	l_dynamicSqlString	VARCHAR2(2000);
	l_package 		VARCHAR2(30) := 'QPR_PRICE_NEGOTIATION_PUB';
	l_procedure		VARCHAR2(30) := 'get_pn_approval_status';
	l_db_link		 varchar2(240);
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

	BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTER OE_DEALS_UTIL.get_Deal' , 1 ) ;
	END IF;
	x_deal_id := NULL;
	x_deal_status := NULL;

	l_db_link	:= FND_PROFILE.VALUE('QPR_PN_DBLINK') ;

	IF l_db_link is NOT NULL THEN
		l_db_link := '@' || l_db_link;
	END IF;

   	 l_dynamicSqlString := ' begin ';
         l_dynamicSqlString := l_dynamicSqlString || l_package ||'.';
         l_dynamicSqlString := l_dynamicSqlString || l_procedure || l_db_link ;
         l_dynamicSqlString := l_dynamicSqlString || '( ';
         l_dynamicSqlString := l_dynamicSqlString || ':errbuf, ';
	 l_dynamicSqlString := l_dynamicSqlString || ':retcode, ';
         l_dynamicSqlString := l_dynamicSqlString || ':p_quote_origin, ';
         l_dynamicSqlString := l_dynamicSqlString || ':p_quote_header_id, ';
         l_dynamicSqlString := l_dynamicSqlString || ':o_deal_id, ';
         l_dynamicSqlString := l_dynamicSqlString || ':o_status );';
         l_dynamicSqlString := l_dynamicSqlString || ' end; ';

         -- EXECUTE THE DYNAMIC SQL
          EXECUTE IMMEDIATE l_dynamicSqlString USING
                                    OUT x_errbuf,
	                            OUT x_retcode,
   	  		            IN l_quote_origin,
   	                            IN p_header_id,
   	                            OUT x_deal_id,
                                    OUT x_deal_status;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'Exit OE_DEALS_UTIL.get_Deal QUERY-' || l_dynamicSqlString, 1 ) ;
	    oe_debug_pub.add(  'Exit OE_DEALS_UTIL.get_Deal' || x_deal_id || x_deal_status, 1 ) ;
	END IF;
EXCEPTION
WHEN OTHERS THEN
		x_deal_id := NULL;
		x_deal_status := NULL;
END Get_Deal_Info;


/*
NAME-Update_Order_with_Deal
Desc -Update the Order with the Approved Deal.
      Get the deal Info.
      If deal is NOT create or NOT approved,
	show message
      If deal is approved,
	call Process Order to Update the Order.
	Progress the WF
*/

PROCEDURE Update_Order_with_Deal
			( p_header_id			IN 	NUMBER
			, p_item_type IN VARCHAR2
			, x_return_status OUT NOCOPY VARCHAR2
			, x_msg_count OUT NOCOPY NUMBER
			, x_msg_data OUT NOCOPY VARCHAR2
			)  IS
	l_order_source_id           NUMBER;
	l_orig_sys_document_ref     VARCHAR2(50);
	l_change_sequence           VARCHAR2(50);
	l_source_document_type_id   NUMBER;
	l_source_document_id        NUMBER;

	l_deal_id		NUMBER;
	l_deal_status 		VARCHAR2(30);
	l_wf_activity 		VARCHAR2(30);
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	l_wf_count NUMBER;

	BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTER OE_DEALS_UTIL.Update_Order_with_Deal' , 1 ) ;
	END IF;

	SELECT order_source_id, orig_sys_document_ref, change_sequence, source_document_type_id, source_document_id
		INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence, l_source_document_type_id, l_source_document_id
		FROM OE_ORDER_HEADERS_ALL
	 	WHERE HEADER_ID = p_header_id;

	OE_MSG_PUB.set_msg_context(
			      p_entity_code           => 'HEADER'
			     ,p_entity_id                  => p_header_id
			     ,p_header_id                  => p_header_id
			     ,p_line_id                    => null
			     ,p_order_source_id            => l_order_source_id
			     ,p_orig_sys_document_ref 	=> l_orig_sys_document_ref
			     ,p_orig_sys_document_line_ref => null
			     ,p_change_sequence            => l_change_sequence
			     ,p_source_document_type_id    => l_source_document_type_id
			     ,p_source_document_id         => l_source_document_id
			     ,p_source_document_line_id    => null );

	l_deal_id := NULL;
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'Deal Info - ' || l_deal_id || l_deal_status , 1 ) ;
	END IF;

	  -- Approved Deal, Call  PO API update the Order
		Call_Process_Order (p_header_id => p_header_id
				    ,x_return_status  => x_return_status);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'After PO API from Deal - ' || x_return_status , 1 ) ;
	END IF;

		IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

		--there can be 2 cases--Direct approve without submit-- so progress both activity
				      --and submit-approve - progress only submit WF activity
		BEGIN
		select   WPA.activity_name  INTO l_wf_activity
		  		FROM WF_ITEM_ACTIVITY_STATUSES WIAS
		  			, WF_PROCESS_ACTIVITIES WPA
		  		WHERE WIAS.item_type = p_item_type
		  		  AND WIAS.item_key = to_char(p_header_id)
		  		  AND WIAS.activity_status = 'NOTIFIED'
		  		  AND WPA.activity_name in ( 'SUBMITTED_DEAL_WB', 'PRICING_APPROVAL_ELIGIBLE')
  		  AND WPA.instance_id = WIAS.process_activity;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				l_wf_count := 0;
				l_wf_activity := NULL;
			WHEN OTHERS THEN
				l_wf_count := 0;
				l_wf_activity := NULL;

		END;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'After PO API from Deal - ' || l_wf_activity , 1 ) ;
	END IF;

		if l_wf_activity is NULL then
			NULL ;
		ELSE
    		   if l_wf_activity = 'PRICING_APPROVAL_ELIGIBLE' then
			WF_ENGINE.CompleteActivityInternalName
				( itemtype		=> p_item_type
				, itemkey		=> to_char(p_header_id)
				, activity		=> l_wf_activity
				, result		=> 'N'
				);

		   END IF;
    		   WF_ENGINE.CompleteActivityInternalName
				( itemtype		=> p_item_type
				, itemkey		=> to_char(p_header_id)
				, activity		=> 'SUBMITTED_DEAL_WB'
				, result		=> 'APPROVED'
				);

		   IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'After WF Engine call - ' || l_wf_count , 1 ) ;
			END IF;


			FND_MESSAGE.SET_NAME('ONT','OE_ORDER_DEAL_UPDATED');
			OE_MSG_PUB.ADD;
		END IF;
	    ELSE
			FND_MESSAGE.SET_NAME('ONT','OE_DEAL_UPDATE_FAILED');
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
	    END IF;
	OE_MSG_PUB.set_msg_context(
	      p_entity_code           => 'HEADER'
	     ,p_entity_id                  => p_header_id
	     ,p_header_id                  => p_header_id
	     ,p_line_id                    => null
	     ,p_order_source_id            => l_order_source_id
	     ,p_orig_sys_document_ref 	=> l_orig_sys_document_ref
	     ,p_orig_sys_document_line_ref => null
	     ,p_change_sequence            => l_change_sequence
	     ,p_source_document_type_id    => l_source_document_type_id
	     ,p_source_document_id         => l_source_document_id
	     ,p_source_document_line_id    => null );
	OE_MSG_PUB.Count_And_Get
				(   p_count     =>      x_msg_count
				,   p_data      =>      x_msg_data
				);

	OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');
EXCEPTION
WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF      OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			   OE_MSG_PUB.Add_Exc_Msg
					( 'OE_DEALS_UTIL'
					, 'Update_Order_with_Deal'
					);
	     	END IF;
		OE_MSG_PUB.Count_And_Get
	                (   p_count     =>      x_msg_count
	                ,   p_data      =>      x_msg_data
			);
		OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');
END Update_Order_with_Deal;

END OE_DEALS_UTIL;

/
