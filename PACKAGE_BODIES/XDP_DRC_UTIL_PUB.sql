--------------------------------------------------------
--  DDL for Package Body XDP_DRC_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_DRC_UTIL_PUB" AS
/* $Header: XDPDRCUB.pls 120.2 2005/07/07 02:15:41 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'XDP_DRC_UTIL_PUB';

 PROCEDURE Process_DRC_Order(
	p_api_version 	        IN 	NUMBER,
	p_init_msg_list	        IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY     VARCHAR2,
	x_msg_count		OUT NOCOPY     NUMBER,
	x_msg_data		OUT NOCOPY     VARCHAR2,
 	P_WORKITEM_ID 		IN      NUMBER,
 	P_TASK_PARAMETER 	IN      XDP_TYPES.ORDER_PARAMETER_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY     NUMBER)
  IS

   l_api_name CONSTANT VARCHAR2(30) := 'PROCESS_DRC_ORDER';
   l_api_version	CONSTANT NUMBER := 11.5;
   lv_ret number;
   lv_str varchar2(800);
   lv_line_id number;
   lv_wi_instance_id number;
   lv_index binary_integer;
   lv_count number;
   lv_done varchar2(1);
   lv_proc varchar2(80);
	l_return_code		varchar2(1);
	l_data			Varchar2(100);
	l_count			Number;
	l_workitem_id			number ;
 	l_task_parameter 	XDP_TYPES.ORDER_PARAMETER_LIST;
	l_sdp_order_id		number;
	l_OAI_array		JTF_USR_HKS.OAI_data_array_type ;
	l_bind_data_id number;
 BEGIN

	-- Standard Start of API savepoint
	-- SAVEPOINT	l_order_tag;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;


    /******* Prepare for going into pre processing *******/

	l_workitem_id :=  p_workitem_id;
	l_task_parameter := p_task_parameter;
	l_sdp_order_id := x_SDP_ORDER_ID;

	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_DRC_UTIL_CUHK',
					'PROCESS_DRC_ORDER_PRE',
					'B',
					'C' )
	then
		XDP_DRC_UTIL_CUHK.Process_DRC_order_Pre(
				p_workitem_id => l_workitem_id,
				p_task_parameter => l_task_parameter,
				p_sdp_order_id => l_sdp_order_id,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		if (  l_return_code = FND_API.G_RET_STS_ERROR )  then
			RAISE FND_API.G_EXC_ERROR;
		elsif (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
	 end if;

	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_DRC_UTIL_VUHK',
					'PROCESS_DRC_ORDER_PRE',
					'B',
					'V' )
	then
		XDP_DRC_UTIL_VUHK.Process_DRC_order_Pre(
				p_workitem_id => l_workitem_id,
				p_task_parameter => l_task_parameter,
				p_sdp_order_id => l_sdp_order_id,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		if (  l_return_code = FND_API.G_RET_STS_ERROR )  then
			RAISE FND_API.G_EXC_ERROR;
		elsif (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
	end if;


    /******* Start of API Body *******/

	XDP_INTERFACES.Process_DRC_Order(
		p_workitem_id => P_WORKITEM_ID,
		p_task_parameter => P_TASK_PARAMETER,
		x_order_id => x_SDP_ORDER_ID,
		x_return_code => lv_ret,
		x_error_description => lv_str);

	if lv_ret <> 0 then
        dbms_output.put_line('Error ' ||lv_str);
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME('XDP', 'XDP_DRC_ORDER_FAILURE');
		FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
		FND_MSG_PUB.Add;
		FND_MSG_PUB.COUNT_AND_GET
		 (  p_count => x_msg_count,
			p_data => x_msg_data
		 );
        x_msg_data := lv_str;
		return;
	end if;


     /******* End of API Body *******/


    /******* Post Processing call *******/

	l_sdp_order_id := x_sdp_order_id;

	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_DRC_UTIL_VUHK',
					'PROCESS_DRC_ORDER_POST',
					'A',
					'V' )
	then
		XDP_DRC_UTIL_VUHK.Process_DRC_order_Post(
				p_workitem_id => l_workitem_id,
				p_task_parameter => l_task_parameter,
				p_sdp_order_id => l_sdp_order_id,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		if (  l_return_code = FND_API.G_RET_STS_ERROR )  then
			RAISE FND_API.G_EXC_ERROR;
		elsif (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
	end if;
	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_DRC_UTIL_CUHK',
					'PROCESS_DRC_ORDER_POST',
					'A',
					'C' )
	then
		XDP_DRC_UTIL_CUHK.Process_DRC_order_Post(
				p_workitem_id => l_workitem_id,
				p_task_parameter => l_task_parameter,
				p_sdp_order_id => l_sdp_order_id,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		if (  l_return_code = FND_API.G_RET_STS_ERROR )  then
			RAISE FND_API.G_EXC_ERROR;
		elsif (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
	 end if;


      /******* Message Generation Section ********/

      if JTF_USR_HKS.Ok_to_Execute('XDP_DRC_UTIL_CUHK',
                                   'Ok_to_Generate_msg',
                                   'M',
                                   'M'
                                   ) then

        if (XDP_DRC_UTIL_CUHK.Ok_to_Generate_msg(
				p_workitem_id => l_workitem_id,
			    p_task_parameter => l_task_parameter,
			    p_sdp_order_id => l_sdp_order_id
				                ))  then

	    --XMLGEN.clearBindValues;
	    --XMLGEN.setBindValue('ORDER_ID', l_sdp_order_id);

		  l_bind_data_id := JTF_USR_HKS.get_bind_data_id;
	   	  JTF_USR_HKS.Load_Bind_Data(
					l_bind_data_id,
					'ORDER_ID',
					TO_CHAR(l_sdp_order_id),
					'S',
					'NUMBER');

	       JTF_USR_HKS.generate_message(
						p_prod_code => 'XDP',
	                    p_bus_obj_code => 'DO',
	                    p_action_code => 'I',
	                    p_correlation => NULL,
	                    p_bind_data_id => l_bind_data_id,
	                    x_return_code => l_return_code
	                         );

           if (l_return_code = FND_API.G_RET_STS_ERROR) then
               RAISE FND_API.G_EXC_ERROR;
           elsif (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) then
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
          end if;
        end if;

      /******* End of Message Generation Section ********/

	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT WORK;
	END IF;

-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get (
			p_count	=> x_msg_count,
			p_data 	=> x_msg_data      );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count ,
			p_data 	=>   x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count,
			p_data 	=>   x_msg_data
		);
	WHEN OTHERS THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
				(	G_PKG_NAME  	    ,
					l_api_name
				);
		END IF;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=> x_msg_count,
			p_data  => x_msg_data
		);

 END Process_DRC_Order;

 PROCEDURE Process_DRC_Order(
	p_api_version 	IN 	NUMBER,
	p_init_msg_list	IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER :=
        FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
 	P_WORKITEM_ID 		IN  NUMBER,
 	P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY NUMBER,
	x_sdp_Fulfillment_Status	OUT NOCOPY VARCHAR2,
	x_sdp_Fulfillment_Result	OUT NOCOPY VARCHAR2) AS
BEGIN
	Process_DRC_Order(	p_api_version ,
						p_init_msg_list,
						p_commit,
						p_validation_level,
 						x_RETURN_STATUS,
						x_msg_count,
						x_msg_data,
 						P_WORKITEM_ID,
 						P_TASK_PARAMETER,
						x_SDP_ORDER_ID
					);
--
--To retreive fulfillment status and result
-- when things going OK
--
-- Changes are made here to test if order id return from SFM is null, or the return status is success or not
-- Will not get order_fulfillment if these conditions are not satisfied.
-- 19/03/2000
--

	IF (X_SDP_ORDER_ID IS NOT NULL) AND (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		x_sdp_Fulfillment_Status := XDP_ENGINE.GET_ORDER_PARAM_VALUE(X_SDP_ORDER_ID,'FULFILLMENT_STATUS');
		x_sdp_Fulfillment_Result := XDP_ENGINE.GET_ORDER_PARAM_VALUE(X_SDP_ORDER_ID,'FULFILLMENT_RESULT');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		x_sdp_Fulfillment_Status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_sdp_Fulfillment_Result := SUBSTR(SQLERRM,1,256);

END Process_DRC_Order;

END XDP_DRC_UTIL_PUB;

/
