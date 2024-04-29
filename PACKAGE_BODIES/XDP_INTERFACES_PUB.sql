--------------------------------------------------------
--  DDL for Package Body XDP_INTERFACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_INTERFACES_PUB" AS
/* $Header: XDPINPBB.pls 120.1 2005/06/15 23:16:12 appldev  $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'XDP_INTERFACES_PUB';

PROCEDURE Process_Order(
	p_api_version 	IN 	NUMBER,
	p_init_msg_list	IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER :=
							FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
 	P_ORDER_HEADER 		IN  XDP_TYPES.ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN  XDP_TYPES.ORDER_PARAMETER_LIST,
 	P_ORDER_LINE_LIST 	IN  XDP_TYPES.ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN  XDP_TYPES.LINE_PARAM_LIST,
	x_SDP_ORDER_ID		   OUT NOCOPY NUMBER)
IS
   l_api_name CONSTANT VARCHAR2(30) := 'PROCESS_ORDER';
   l_api_version	CONSTANT NUMBER := 11.5;
   lv_ret number;
   lv_str varchar2(800);
 	lv_ORDER_HEADER 		XDP_TYPES.ORDER_HEADER;
 	lv_ORDER_PARAMETER 	XDP_TYPES.ORDER_PARAMETER_LIST;
 	lv_ORDER_LINE_LIST 	XDP_TYPES.ORDER_LINE_LIST;
 	lv_LINE_PARAMETER_LIST 	XDP_TYPES.LINE_PARAM_LIST;
   lv_index binary_integer;
   lv_count number;
   lv_done varchar2(1);
   lv_proc varchar2(80);
	l_return_code		varchar2(1);
	l_data			Varchar2(100);
	l_count			Number;
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

	lv_ORDER_HEADER := P_ORDER_HEADER;
	lv_ORDER_PARAMETER := P_ORDER_PARAMETER;
	lv_ORDER_LINE_LIST := P_ORDER_LINE_LIST;
	lv_LINE_PARAMETER_LIST := P_LINE_PARAMETER_LIST;
	l_sdp_order_id := x_SDP_ORDER_ID;

	if JTF_USR_HKS.Ok_to_Execute(
					'XDP_INTERFACES_PO_CUHK',
					'PROCESS_ORDER_PRE',
					'B',
					'C' )
	then

		XDP_INTERFACES_PO_CUHK.Process_order_Pre(
				p_order_header => lv_ORDER_HEADER,
				p_order_parameter => lv_ORDER_PARAMETER,
				p_order_line_list => lv_ORDER_LINE_LIST,
				p_line_parameter_list => lv_LINE_PARAMETER_LIST,
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

	if JTF_USR_HKS.Ok_to_Execute(
					'XDP_INTERFACES_PO_VUHK',
					'PROCESS_ORDER_PRE',
					'B',
					'V' )
	then
		XDP_INTERFACES_PO_VUHK.Process_order_Pre(
				p_order_header => lv_ORDER_HEADER,
				p_order_parameter => lv_ORDER_PARAMETER,
				p_order_line_list => lv_ORDER_LINE_LIST,
				p_line_parameter_list => lv_LINE_PARAMETER_LIST,
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

        XDP_INTERFACES.Process_Order(
 	                            P_ORDER_HEADER => P_ORDER_HEADER,
 	                            P_ORDER_PARAMETER => P_ORDER_PARAMETER,
 	                            P_ORDER_LINE_LIST => P_ORDER_LINE_LIST,
 	                            P_LINE_PARAMETER_LIST => P_LINE_PARAMETER_LIST,
	                            SDP_ORDER_ID => x_SDP_ORDER_ID,
 	                            RETURN_CODE => lv_ret,
 	                            ERROR_DESCRIPTION => lv_str);

	   if lv_ret <> 0 then
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_PROCESS_FAIL');
		FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
		FND_MSG_PUB.Add;
		FND_MSG_PUB.COUNT_AND_GET
		 (  p_count => x_msg_count,
			p_data => x_msg_data
		 );
		return;
	   end if;


     /******* End of API Body *******/


    /******* Post Processing call *******/

	l_sdp_order_id := x_SDP_ORDER_ID;

	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_INTERFACES_PO_CUHK',
					'PROCESS_ORDER_POST',
					'A',
					'C' )
	then
		XDP_INTERFACES_PO_CUHK.Process_order_Post(
				p_order_header => lv_ORDER_HEADER,
				p_order_parameter => lv_ORDER_PARAMETER,
				p_order_line_list => lv_ORDER_LINE_LIST,
				p_line_parameter_list => lv_LINE_PARAMETER_LIST,
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
					'XDP_INTERFACES_PO_VUHK',
					'PROCESS_ORDER_POST',
					'A',
					'V' )
	then
		XDP_INTERFACES_PO_VUHK.Process_order_Post(
				p_order_header => lv_ORDER_HEADER,
				p_order_parameter => lv_ORDER_PARAMETER,
				p_order_line_list => lv_ORDER_LINE_LIST,
				p_line_parameter_list => lv_LINE_PARAMETER_LIST,
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

      if JTF_USR_HKS.Ok_to_Execute('XDP_INTERFACES_PO_CUHK',
                                   'Ok_to_Generate_msg',
                                   'M',
                                   'M'
                                   ) then

        if (XDP_INTERFACES_PO_CUHK.Ok_to_Generate_msg(
                     p_order_header => lv_ORDER_HEADER,
				     p_order_parameter => lv_ORDER_PARAMETER,
				     p_order_line_list => lv_ORDER_LINE_LIST,
				     p_line_parameter_list => lv_LINE_PARAMETER_LIST,
				     p_sdp_order_id => l_sdp_order_id
				      ))  then

	   -- XMLGEN.clearBindValues;
	   -- XMLGEN.setBindValue('ORDER_ID', l_sdp_order_id);
		  l_bind_data_id := JTF_USR_HKS.get_bind_data_id;
	   	  JTF_USR_HKS.Load_Bind_Data(
					l_bind_data_id,
					'ORDER_ID',
					TO_CHAR(l_sdp_order_id),
					'S',
					'NUMBER');

	       JTF_USR_HKS.generate_message(
						p_prod_code => 'XDP',
	                    p_bus_obj_code => 'PO',
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

 END Process_Order;

    /************* End of Process Order ****************/


PROCEDURE Cancel_Order(
	p_api_version 	IN 	NUMBER,
	p_init_msg_list	IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER :=
							FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_caller_name 		IN VARCHAR2 )
IS

   l_api_name CONSTANT VARCHAR2(30) := 'CANCEL_ORDER';
   l_api_version	CONSTANT NUMBER := 11.5;
   lv_ret number;
   lv_str varchar2(800);
   lv_index binary_integer;
   lv_count number;
   lv_done varchar2(1);
   lv_proc varchar2(80);
        l_caller_name           varchar2(100);
	l_return_code		varchar2(1);
	l_data			Varchar2(100);
	l_count			Number;
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

	l_caller_name := p_caller_name;
	l_sdp_order_id := P_SDP_ORDER_ID;

	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_INTERFACES_CO_CUHK',
					'CANCEL_ORDER_PRE',
					'B',
					'C' )
	then
		XDP_INTERFACES_CO_CUHK.Cancel_order_Pre(
				p_caller_name => l_caller_name,
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
					'XDP_INTERFACES_CO_VUHK',
					'CANCEL_ORDER_PRE',
					'B',
					'V' )
	then
		XDP_INTERFACES_CO_VUHK.Cancel_order_Pre(
				p_caller_name => l_caller_name,
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

        XDP_INTERFACES.Cancel_Order(
	                            P_SDP_ORDER_ID => P_SDP_ORDER_ID,
	                            p_caller_name => p_caller_name,
 	                            RETURN_CODE => lv_ret,
 	                            ERROR_DESCRIPTION => lv_str);

	   if lv_ret <> 0 then
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_CANCEL_FAIL');
		FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
		FND_MSG_PUB.Add;
		FND_MSG_PUB.COUNT_AND_GET
		 (  p_count => x_msg_count,
			p_data => x_msg_data
		 );
		return;
	   end if;


     /******* End of API Body *******/


    /******* Post Processing call *******/

	l_sdp_order_id := P_SDP_ORDER_ID;

	if   JTF_USR_HKS.Ok_to_Execute(
					'XDP_INTERFACES_CO_CUHK',
					'CANCEL_ORDER_POST',
					'A',
					'C' )
	then
		XDP_INTERFACES_CO_CUHK.Cancel_order_Post(
				p_caller_name => l_caller_name,
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
					'XDP_INTERFACES_CO_VUHK',
					'CANCEL_ORDER_POST',
					'A',
					'V' )
	then
		XDP_INTERFACES_CO_VUHK.Cancel_order_Post(
				p_caller_name => l_caller_name,
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

      if JTF_USR_HKS.Ok_to_Execute('XDP_INTERFACES_CO_CUHK',
                                   'Ok_to_Generate_msg',
                                   'M',
                                   'M'
                                   ) then

        if (XDP_INTERFACES_CO_CUHK.Ok_to_Generate_msg(
                                 p_caller_name => l_caller_name,
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
	                    p_bus_obj_code => 'CO',
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

END Cancel_Order;

PROCEDURE Get_Order_Parameter_Value(
	p_api_version 	IN 	NUMBER,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_RETURN_MSG		OUT NOCOPY VARCHAR2,
	x_ORDER_PARAM_VALUE	OUT NOCOPY VARCHAR2,
 	P_SDP_ORDER_ID 		IN NUMBER,
 	P_ORDER_PARAM_NAME	IN VARCHAR2,
	p_CALLER_NAME 		IN VARCHAR2 ) IS
l_api_name CONSTANT VARCHAR2(30) := 'GET_ORDER_PARAMETER_VALUE';
l_api_version	CONSTANT NUMBER := 11.5;
l_ret_code NUMBER := 0;
l_ret_desc VARCHAR2(2000);
BEGIN
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    /******* Start of API Body *******/
        XDP_INTERFACES.Get_Order_Param_Value(
	                           	P_ORDER_ID => P_SDP_ORDER_ID,
	                           	p_parameter_name => P_ORDER_PARAM_NAME,
	                           	x_parameter_value => x_ORDER_PARAM_VALUE,
 	                            x_RETURN_CODE => l_ret_code,
 	                            x_ERROR_DESCRIPTION => l_ret_desc);
 	    IF l_ret_code = 0 THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			x_RETURN_MSG := '';
		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_RETURN_MSG := l_ret_desc;
		END IF;

     /******* End of API Body *******/
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Get_Order_Parameter_Value;

PROCEDURE Get_Order_Parameter_List(
	p_api_version 	IN 	NUMBER,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_RETURN_MSG		OUT NOCOPY VARCHAR2,
	x_ORDER_PARAM_LIST	OUT NOCOPY XDP_ENGINE.PARAMETER_LIST,
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_CALLER_NAME 		IN VARCHAR2) IS
l_api_name CONSTANT VARCHAR2(30) := 'GET_ORDER_PARAMETER_LIST';
l_api_version	CONSTANT NUMBER := 11.5;
l_ret_code NUMBER := 0;
l_ret_desc VARCHAR2(2000);
BEGIN
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    /******* Start of API Body *******/

        x_ORDER_PARAM_LIST := XDP_INTERFACES.Get_Order_Param_List(
	                           	P_ORDER_ID => P_SDP_ORDER_ID,
 	                            x_RETURN_CODE => L_ret_code,
 	                            x_ERROR_DESCRIPTION => l_ret_desc);
 	    IF l_ret_code = 0 THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			x_RETURN_MSG := '';
		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_RETURN_MSG := l_ret_desc;
		END IF;

     /******* End of API Body *******/
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Get_Order_Parameter_List;

PROCEDURE Get_Line_Parameter_Value(
	p_api_version 	IN 	NUMBER,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_RETURN_MSG		OUT NOCOPY VARCHAR2,
	x_LINE_PARAM_VALUE	OUT NOCOPY VARCHAR2,
 	P_SDP_ORDER_ID 		IN NUMBER,
 	P_LINE_NUMBER 		IN NUMBER,
 	P_LINE_PARAM_NAME	IN VARCHAR2,
	p_CALLER_NAME 		IN VARCHAR2 ) IS
l_api_name CONSTANT VARCHAR2(30) := 'GET_LINE_PARAMETER_VALUE';
l_api_version	CONSTANT NUMBER := 11.5;
l_ret_code NUMBER := 0;
l_ret_desc VARCHAR2(2000);
BEGIN
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    /******* Start of API Body *******/
        XDP_INTERFACES.Get_Line_Param_Value(
	                           	P_ORDER_ID => P_SDP_ORDER_ID,
	                           	p_LINE_NUMBER => P_LINE_NUMBER,
	                           	p_parameter_name => p_LINE_PARAM_NAME,
	                           	x_parameter_value => x_LINE_PARAM_VALUE,
 	                            x_RETURN_CODE => l_ret_code,
 	                            x_ERROR_DESCRIPTION => l_ret_desc);
 	    IF l_ret_code = 0 THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			x_RETURN_MSG := '';
		ELSE
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_RETURN_MSG := l_ret_desc;
		END IF;

     /******* End of API Body *******/
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Get_Line_Parameter_Value;


/*
 Open interface new APIs.

 The following private procedures null all the gmiss fields
 for their respective data structures.
*/

PROCEDURE TO_NULL(p_order_header IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER);
PROCEDURE TO_NULL(p_order_param_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST);
PROCEDURE TO_NULL(p_order_line_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST);
PROCEDURE TO_NULL(p_line_param_list IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST);


-- Process Order

PROCEDURE Process_Order(
    p_api_version 	    IN  NUMBER,
    p_init_msg_list	    IN  VARCHAR2 :=	FND_API.G_FALSE,
    p_commit	        IN  VARCHAR2 :=	FND_API.G_FALSE,
    p_validation_level  IN  NUMBER 	 :=	FND_API.G_VALID_LEVEL_FULL,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count	        OUT NOCOPY NUMBER,
    x_msg_data	        OUT NOCOPY VARCHAR2,
    x_error_code	    OUT NOCOPY VARCHAR2,
    p_order_header 	    IN  XDP_TYPES.SERVICE_ORDER_HEADER:= XDP_TYPES.G_MISS_SERVICE_ORDER_HEADER,
    p_order_param_list  IN  XDP_TYPES.SERVICE_ORDER_PARAM_LIST:= XDP_TYPES.G_MISS_ORDER_PARAM_LIST,
    p_order_line_list   IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST:= XDP_TYPES.G_MISS_SERVICE_ORDER_LINE_LIST,
    p_line_param_list   IN  XDP_TYPES.SERVICE_LINE_PARAM_LIST:= XDP_TYPES.G_MISS_LINE_PARAM_LIST,
    x_order_id	  OUT NOCOPY NUMBER
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'PROCESS_ORDER';
    l_api_version	CONSTANT NUMBER := 11.5;

    lv_ret          NUMBER;
    lv_str          VARCHAR2(800);
    lv_index        BINARY_INTEGER;
    lv_count        NUMBER;
    lv_done         VARCHAR2(1);
    lv_proc         VARCHAR2(80);

	l_return_code	VARCHAR2(1);
	l_data			VARCHAR2(100);
	l_count			NUMBER;
	l_order_id		NUMBER;
	l_OAI_array		JTF_USR_HKS.OAI_data_array_type ;
	l_bind_data_id  NUMBER;

 	lv_order_header 	    XDP_TYPES.SERVICE_ORDER_HEADER;
 	lv_order_param_list 	XDP_TYPES.SERVICE_ORDER_PARAM_LIST;
 	lv_order_line_list	    XDP_TYPES.SERVICE_ORDER_LINE_LIST;
 	lv_line_param_list 	    XDP_TYPES.SERVICE_LINE_PARAM_LIST;

BEGIN
	-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME
    )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

-- Converting G_Miss variables
    x_error_code := 0;
 	lv_order_header 	    := p_order_header;
 	lv_order_param_list	    := p_order_param_list;
 	lv_order_line_list 	    := p_order_line_list;
 	lv_line_param_list 	    := p_line_param_list;

-- Converting G_Miss variables to null before calling any internal pl/sql procedures

    TO_NULL(lv_order_header);
    TO_NULL(lv_order_param_list);
    TO_NULL(lv_order_line_list);
    TO_NULL(lv_line_param_list);

    IF JTF_USR_HKS.Ok_to_Execute(
	    'XDP_INTERFACES_SO_CUHK',
        'PROCESS_ORDER_PRE',
        'B','C' )
	THEN
		XDP_INTERFACES_SO_CUHK.Process_Order_Pre(
				p_order_header => lv_order_header,
				p_order_param_list => lv_order_param_list,
				p_order_line_list => lv_order_line_list,
				p_line_param_list => lv_line_param_list,
				p_order_id => l_order_id,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF  (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_SO_VUHK',
		'PROCESS_ORDER_PRE',
		'B','V')
	THEN
		XDP_INTERFACES_SO_VUHK.Process_Order_Pre(
				p_order_header => lv_order_header,
				p_order_param_list => lv_order_param_list,
				p_order_line_list => lv_order_line_list,
				p_line_param_list => lv_line_param_list,
				p_order_id => l_order_id,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

    /******* Start of API Body *******/

    XDP_ORDER.Process_Order(
		lv_order_header,
		lv_order_param_list,
		lv_order_line_list,
		lv_line_param_list,
        l_order_id,
        lv_ret,
        lv_str
    );

    IF lv_ret <> 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_error_code := lv_ret;
	    FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_PROCESS_FAIL');
		FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
    	FND_MSG_PUB.Add;
	    FND_MSG_PUB.COUNT_AND_GET(
            p_count => x_msg_count,
    		p_data => x_msg_data
        );
--
--      We do not wrap the error message as FND_MSG does for UI messages
--      This will return the error message only
--
        x_msg_data := lv_str;
		RETURN;
    END IF;

    /******* End of API Body *******/


    /******* Post Processing call *******/
	x_order_id := l_order_id;

	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_SO_CUHK',
		'PROCESS_ORDER_POST',
		'A','C' )
	THEN
		XDP_INTERFACES_SO_CUHK.Process_Order_Post(
			p_order_header => lv_order_header,
			p_order_param_list => lv_order_param_list,
			p_order_line_list => lv_order_line_list,
			p_line_param_list => lv_line_param_list,
            p_order_id => l_order_id,
			x_data => l_data,
			x_count => l_count,
			x_return_code => l_return_code );
		IF (  l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
	  	'XDP_INTERFACES_SO_VUHK',
	  	'PROCESS_ORDER_POST',
	  	'A','V' )
	THEN
		XDP_INTERFACES_SO_VUHK.Process_Order_Post(
			p_order_header => lv_order_header,
			p_order_param_list => lv_order_param_list,
			p_order_line_list => lv_order_line_list,
			p_line_param_list => lv_line_param_list,
            p_order_id => l_order_id,
			x_data => l_data,
			x_count => l_count,
		  	x_return_code => l_return_code );
		IF (  l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

    /******* Message Generation Section ********/

    IF JTF_USR_HKS.Ok_to_Execute(
        'XDP_INTERFACES_SO_CUHK',
        'Ok_to_Generate_msg',
        'M','M')
    THEN
        IF (XDP_INTERFACES_SO_CUHK.Ok_to_Generate_msg(
			p_order_header => lv_order_header,
			p_order_param_list => lv_order_param_list,
			p_order_line_list => lv_order_line_list,
			p_line_param_list => lv_line_param_list,
            p_order_id => l_order_id))  THEN

	   -- XMLGEN.clearBindValues;
	   -- XMLGEN.setBindValue('ORDER_ID', l_sdp_order_id);

    		  l_bind_data_id := JTF_USR_HKS.get_bind_data_id;
	       	  JTF_USR_HKS.Load_Bind_Data(
					l_bind_data_id,
					'ORDER_ID',
					TO_CHAR(l_order_id),
					'S',
					'NUMBER');

	           JTF_USR_HKS.generate_message(
						p_prod_code => 'XDP',
	                    p_bus_obj_code => 'PO',
	                    p_action_code => 'I',
	                    p_correlation => NULL,
	                    p_bind_data_id => l_bind_data_id,
	                    x_return_code => l_return_code
	            );

                IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
          END IF;
    END IF;

    /******* End of Message Generation Section ********/

	x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_error_code := 0;

-- Standard check of p_commit.

	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard call to get message count and if count is 1, get message info.

	FND_MSG_PUB.Count_And_Get (
		p_count	=> x_msg_count,
		p_data 	=> x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_ERROR ;
        	x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count ,
			p_data 	=>   x_msg_data
		);
		x_msg_data := SQLERRM;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        	x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count,
			p_data 	=>   x_msg_data
		);
		x_msg_data := SQLERRM;
	WHEN OTHERS THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       		x_error_code := SQLCODE;
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
		x_msg_data := SQLERRM;
END Process_Order;


PROCEDURE Cancel_Order(
    p_api_version 	    IN  NUMBER,
    p_init_msg_list	    IN  VARCHAR2	:= 	FND_API.G_FALSE,
    p_commit	        IN  VARCHAR2	:= 	FND_API.G_FALSE,
    p_validation_level  IN  NUMBER 	    := 	FND_API.G_VALID_LEVEL_FULL,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count	        OUT NOCOPY NUMBER,
    x_msg_data	        OUT NOCOPY VARCHAR2,
    p_order_number  	IN  VARCHAR2,
    p_order_version	    IN  VARCHAR2,
    p_order_id 	        IN  NUMBER,
    x_error_code	    OUT NOCOPY VARCHAR2,
	p_caller_name 		IN VARCHAR2
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CANCEL_ORDER';
    l_api_version	CONSTANT NUMBER := 11.5;

    l_order_id  NUMBER;
    l_order_number VARCHAR2(40);
    l_order_version VARCHAR2(40);

    lv_ret          NUMBER;
    lv_str          VARCHAR2(800);
    lv_index        BINARY_INTEGER;
    lv_count        NUMBER;
    lv_done         VARCHAR2(1);
    lv_proc         VARCHAR2(80);

	l_return_code	VARCHAR2(1);
	l_data			Varchar2(100);
	l_count			Number;
    l_caller_name     VARCHAR2(100);

BEGIN

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

    l_caller_name := p_caller_name;

    l_order_id := p_order_id;
    l_order_number := p_order_number;
    l_order_version := p_order_version;

	IF   JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_CS_CUHK',
		'CANCEL_ORDER_PRE',
		'B','C' )
	THEN
		XDP_INTERFACES_CS_CUHK.Cancel_Order_Pre(
				p_caller_name => l_caller_name,
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	 END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
        'XDP_INTERFACES_CS_VUHK',
		'CANCEL_ORDER_PRE',
		'B','V' )
	THEN
		XDP_INTERFACES_CS_VUHK.Cancel_Order_Pre(
				p_caller_name => l_caller_name,
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;


    /******* Start of API Body *******/

/*
    This one will go through XDP_INTERFACES as the detail implementation
    for cancelling an order is in XDP_INTERFACES. However, it will
    be moved to XDP_ORDER, then these calls should point to the respective
    Internal APIs.
*/

        IF p_order_id is NOT NULL THEN
            XDP_INTERFACES.Cancel_Order(
                p_sdp_order_id => p_order_id,
                p_caller_name => p_caller_name,
                RETURN_CODE => lv_ret,
                ERROR_DESCRIPTION => lv_str);
        ELSE
            XDP_INTERFACES.Cancel_Order(
                p_order_number => p_order_number,
                p_order_version => p_order_version,
                p_caller_name => p_caller_name,
                RETURN_CODE => lv_ret,
                ERROR_DESCRIPTION => lv_str);
        END IF;


	    IF lv_ret <> 0 THEN
            x_error_code := lv_ret;
		    x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_CANCEL_FAIL');
	    	FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
		    FND_MSG_PUB.Add;
    		FND_MSG_PUB.COUNT_AND_GET
	    	 (  p_count => x_msg_count,
		    	p_data => x_msg_data
    		 );
--
--      We do not wrap the error message as FND_MSG does for UI messages
--      This will return the error message only
--
            x_msg_data := lv_str;
	    	RETURN;
	    END IF;


    /******* End of API Body *******/

    /******* Post Processing call *******/


	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_CS_CUHK',
		'CANCEL_ORDER_POST',
		'A','C' )
	THEN
		XDP_INTERFACES_CS_CUHK.Cancel_Order_Post(
				p_caller_name => l_caller_name,
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
	  	'XDP_INTERFACES_CS_VUHK',
	  	'CANCEL_ORDER_POST',
	  	'A','V' )
	THEN
		XDP_INTERFACES_CS_VUHK.Cancel_Order_Post(
				p_caller_name => l_caller_name,
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

    /******* Message Generation Section ********/

    IF JTF_USR_HKS.Ok_to_Execute(
        'XDP_INTERFACES_CS_CUHK',
        'Ok_to_Generate_msg',
        'M','M')
    THEN
         lv_ret := 0;
    END IF;

    /******* End of Message Generation Section ********/

	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Standard check of p_commit.

	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard call to get message count and if count is 1, get message info.

	FND_MSG_PUB.Count_And_Get (
		p_count	=> x_msg_count,
		p_data 	=> x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_ERROR ;
        	x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count ,
			p_data 	=>   x_msg_data
		);
		x_msg_data := SQLERRM;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        	x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count,
			p_data 	=>   x_msg_data
		);
		x_msg_data := SQLERRM;
	WHEN OTHERS THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        	x_error_code := SQLCODE;
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
		x_msg_data := SQLERRM;
END Cancel_Order;


PROCEDURE Get_Order_Details(
    p_api_version 		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    p_commit		    IN  VARCHAR2,
    p_validation_level	IN  NUMBER,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count		    OUT NOCOPY NUMBER,
    x_msg_data		    OUT NOCOPY VARCHAR2,
    x_error_code		OUT NOCOPY VARCHAR2,
    p_order_number  	IN  VARCHAR2,
    p_order_version	  	IN  VARCHAR2,
    p_order_id 		    IN  NUMBER,
    x_order_header		OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
    x_order_param_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    x_line_item_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    x_line_param_list	OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GET_ORDER_DETAILS';
    l_api_version	CONSTANT NUMBER := 11.5;
    lv_ret          NUMBER;
    lv_str          VARCHAR2(800);
    lv_index        BINARY_INTEGER;
    lv_count        NUMBER;
    lv_done         VARCHAR2(1);
    lv_proc         VARCHAR2(80);

	l_return_code	VARCHAR2(1);
	l_data			Varchar2(100);
	l_count			Number;

    l_order_id  NUMBER;
    l_order_number VARCHAR2(40);
    l_order_version VARCHAR2(40);

BEGIN

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

    l_order_id := p_order_id;
    l_order_number := p_order_number;
    l_order_version := p_order_version;

    IF JTF_USR_HKS.Ok_to_Execute(
	    'XDP_INTERFACES_OD_CUHK',
		'GET_ORDER_DETAILS_PRE',
        'B','C' )
	THEN
		XDP_INTERFACES_OD_CUHK.GET_ORDER_DETAILS_PRE(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_header	=>x_order_header,
                x_order_param_list	=>x_order_param_list,
                x_line_item_list	=>x_line_item_list,
                x_line_param_list	=>x_line_param_list,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_OD_VUHK',
		'GET_ORDER_DETAILS_PRE',
		'B',
		'V' )
	THEN
		XDP_INTERFACES_OD_VUHK.GET_ORDER_DETAILS_PRE(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_header	=>x_order_header,
                x_order_param_list	=>x_order_param_list,
                x_line_item_list	=>x_line_item_list,
                x_line_param_list	=>x_line_param_list,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;


    /******* Start of API Body *******/

    XDP_INTERFACES.Get_Order_Details(
        p_order_id,
        p_order_number,
        p_order_version,
        x_order_header,
        x_order_param_list,
        x_line_item_list,
        x_line_param_list,
        lv_ret,
        lv_str
    );

    IF lv_ret <> 0 THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
        x_error_code := lv_ret;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_DETAILS_FAIL');
 	    FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
   		FND_MSG_PUB.Add;
     	FND_MSG_PUB.COUNT_AND_GET
 	     (  p_count => x_msg_count,
   			p_data => x_msg_data
     	 );
--
--      We do not wrap the error message as FND_MSG does for UI messages
--      This will return the error message only
--
        x_msg_data := lv_str;
 	    RETURN;
    END IF;
    /******* End of API Body *******/


    /******* Post Processing call *******/

	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_OD_CUHK',
		'GET_ORDER_DETAILS_POST',
		'A','C' )
	THEN
		XDP_INTERFACES_OD_CUHK.GET_ORDER_DETAILS_POST(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_header	=>x_order_header,
                x_order_param_list	=>x_order_param_list,
                x_line_item_list	=>x_line_item_list,
                x_line_param_list	=>x_line_param_list,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
	  	'XDP_INTERFACES_OD_VUHK',
		'GET_ORDER_DETAILS_POST',
	  	'A','V' )
	THEN
		XDP_INTERFACES_OD_VUHK.GET_ORDER_DETAILS_POST(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_header	=>x_order_header,
                x_order_param_list	=>x_order_param_list,
                x_line_item_list	=>x_line_item_list,
                x_line_param_list	=>x_line_param_list,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Standard check of p_commit. DO NOT NEED TO

--	IF FND_API.To_Boolean(p_commit) THEN
--		COMMIT WORK;
--	END IF;

-- Standard call to get message count and if count is 1, get message info.

	FND_MSG_PUB.Count_And_Get (
		p_count	=> x_msg_count,
		p_data 	=> x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_ERROR ;
        	x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count ,
			p_data 	=>   x_msg_data
		);
		x_msg_data := SQLERRM;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        	x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count,
			p_data 	=>   x_msg_data
		);
		x_msg_data := SQLERRM;
	WHEN OTHERS THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        	x_error_code := SQLCODE;
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
		x_msg_data := SQLERRM;
END Get_Order_Details;

--
-- To retrieve order status as defined by XDP_TYPES.SERVICE_ORDER_STATUS
--
PROCEDURE Get_Order_Status(
    p_api_version 		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    p_commit		    IN  VARCHAR2,
    p_validation_level	IN  NUMBER,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count		    OUT NOCOPY NUMBER,
    x_msg_data		    OUT NOCOPY VARCHAR2,
    x_error_code		OUT NOCOPY VARCHAR2,
    p_order_number  	IN  VARCHAR2,
    p_order_version		IN  VARCHAR2,
    p_order_id 		    IN  NUMBER,
    x_order_status		OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'GET_ORDER_STATUS';
    l_api_version	CONSTANT NUMBER := 11.5;
    lv_ret          NUMBER;
    lv_str          VARCHAR2(800);
    lv_index        BINARY_INTEGER;
    lv_count        NUMBER;
    lv_done         VARCHAR2(1);
    lv_proc         VARCHAR2(80);

	l_return_code	VARCHAR2(1);
	l_data			Varchar2(100);
	l_count			Number;

    l_order_id  NUMBER;
    l_order_number VARCHAR2(40);
    l_order_version VARCHAR2(40);

BEGIN

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

    l_order_id := p_order_id;
    l_order_number := p_order_number;
    l_order_version := p_order_version;

    IF JTF_USR_HKS.Ok_to_Execute(
	    'XDP_INTERFACES_OS_CUHK',
        'GET_ORDER_STATUS_PRE',
        'B','C' )
	THEN
		XDP_INTERFACES_OS_CUHK.GET_ORDER_STATUS_PRE(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_status	=>x_order_status,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_OS_VUHK',
        'GET_ORDER_STATUS_PRE',
		'B',
		'V' )
	THEN
		XDP_INTERFACES_OS_VUHK.GET_ORDER_STATUS_PRE(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_status	=>x_order_status,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;


    /******* Start of API Body *******/
    XDP_INTERFACES.Get_Order_Status(
        p_order_id,
        p_order_number,
        p_order_version,
        x_order_status,
        lv_ret,
        lv_str
    );
    IF lv_ret <> 0 THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
        x_error_code := lv_ret;
     	FND_MESSAGE.SET_NAME('XDP', 'XDP_INTFACE_STATUS_FAIL');
 	    FND_MESSAGE.SET_TOKEN('ERROR_MSG',lv_str);
   		FND_MSG_PUB.Add;
     	FND_MSG_PUB.COUNT_AND_GET
 	     (  p_count => x_msg_count,
   			p_data => x_msg_data
     	 );
--
--      We do not wrap the error message as FND_MSG does for UI messages
--      This will return the error message only
--
        x_msg_data := lv_str;
 	    RETURN;
    END IF;
    /******* End of API Body *******/


    /******* Post Processing call *******/

	IF JTF_USR_HKS.Ok_to_Execute(
		'XDP_INTERFACES_OS_CUHK',
		'GET_ORDER_STATUS_POST',
		'A','C' )
	THEN
		XDP_INTERFACES_OS_CUHK.GET_ORDER_STATUS_POST(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_status	=>x_order_status,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
    END IF;

	IF JTF_USR_HKS.Ok_to_Execute(
	  	'XDP_INTERFACES_OS_VUHK',
		'GET_ORDER_STATUS_POST',
	  	'A','V' )
	THEN
		XDP_INTERFACES_OS_VUHK.GET_ORDER_STATUS_POST(
				p_order_id => l_order_id,
				p_order_number => l_order_number,
				p_order_version => l_order_version,
                x_order_status	=>x_order_status,
				x_data => l_data,
				x_count => l_count,
			  	x_return_code => l_return_code );
		IF (l_return_code = FND_API.G_RET_STS_ERROR )  THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Standard check of p_commit. DO NOT NEED TO

--	IF FND_API.To_Boolean(p_commit) THEN
--		COMMIT WORK;
--	END IF;

-- Standard call to get message count and if count is 1, get message info.

	FND_MSG_PUB.Count_And_Get (
		p_count	=> x_msg_count,
		p_data 	=> x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_ERROR ;
        x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count ,
			p_data 	=>   x_msg_data
		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_error_code := SQLCODE;
		FND_MSG_PUB.Count_And_Get
		(  	p_count	=>   x_msg_count,
			p_data 	=>   x_msg_data
		);
	WHEN OTHERS THEN
		-- ROLLBACK TO l_order_tag;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_error_code := SQLCODE;
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
END Get_Order_Status;


--PRIVATE PROCEDURE , CONVERTING G_MISSES TO NULL

PROCEDURE TO_NULL(p_order_header IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER)
IS
BEGIN
    IF p_order_header.order_number = FND_API.G_MISS_CHAR THEN
        p_order_header.order_number := NULL;
    END IF;
    IF p_order_header.account_number = FND_API.G_MISS_CHAR THEN
        p_order_header.account_number := NULL;
    END IF;
    IF p_order_header.cust_account_id = FND_API.G_MISS_NUM THEN
        p_order_header.cust_account_id := NULL;
    END IF;
    IF p_order_header.due_date = FND_API.G_MISS_DATE THEN
        p_order_header.due_date := NULL;
    END IF;

    IF p_order_header.customer_required_date = FND_API.G_MISS_DATE THEN
        p_order_header.customer_required_date := NULL;
    END IF;

    IF p_order_header.customer_name = FND_API.G_MISS_CHAR THEN
        p_order_header.customer_name := NULL;
    END IF;
    IF p_order_header.customer_id = FND_API.G_MISS_NUM THEN
        p_order_header.customer_id := NULL;
    END IF;
    IF p_order_header.telephone_number = FND_API.G_MISS_CHAR THEN
        p_order_header.telephone_number := NULL;
    END IF;

    IF p_order_header.order_type = FND_API.G_MISS_CHAR THEN
        p_order_header.order_type := NULL;
    END IF;

    IF p_order_header.order_source = FND_API.G_MISS_CHAR THEN
        p_order_header.order_source := NULL;
    END IF;

    IF p_order_header.org_id = FND_API.G_MISS_NUM THEN
        p_order_header.org_id := NULL;
    END IF;

    IF p_order_header.related_order_id = FND_API.G_MISS_NUM THEN
        p_order_header.related_order_id := NULL;
    END IF;

    IF p_order_header.previous_order_id = FND_API.G_MISS_NUM THEN
        p_order_header.previous_order_id := NULL;
    END IF;

    IF p_order_header.next_order_id = FND_API.G_MISS_NUM THEN
        p_order_header.next_order_id := NULL;
    END IF;

    IF p_order_header.order_ref_name = FND_API.G_MISS_CHAR THEN
        p_order_header.order_ref_name := NULL;
    END IF;

    IF p_order_header.order_ref_value = FND_API.G_MISS_CHAR THEN
        p_order_header.order_ref_value := NULL;
    END IF;
    IF p_order_header.order_comments = FND_API.G_MISS_CHAR THEN
        p_order_header.order_comments := NULL;
    END IF;
    IF p_order_header.order_ref_name = FND_API.G_MISS_CHAR THEN
        p_order_header.order_ref_name := NULL;
    END IF;

    IF p_order_header.order_id = FND_API.G_MISS_NUM THEN
        p_order_header.order_id := NULL;
    END IF;

    IF p_order_header.order_status = FND_API.G_MISS_CHAR THEN
        p_order_header.order_status := NULL;
    END IF;
    IF p_order_header.fulfillment_status = FND_API.G_MISS_CHAR THEN
        p_order_header.fulfillment_status := NULL;
    END IF;
    IF p_order_header.fulfillment_result = FND_API.G_MISS_CHAR THEN
        p_order_header.fulfillment_result := NULL;
    END IF;
    IF p_order_header.completion_date = FND_API.G_MISS_DATE THEN
        p_order_header.completion_date := NULL;
    END IF;
    IF p_order_header.actual_fulfillment_date = FND_API.G_MISS_DATE THEN
        p_order_header.actual_fulfillment_date := NULL;
    END IF;

    IF p_order_header.attribute_category = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute_category := NULL;
    END IF;

    IF p_order_header.attribute1 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute1 := NULL;
    END IF;
    IF p_order_header.attribute2 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute2 := NULL;
    END IF;
    IF p_order_header.attribute3 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute3 := NULL;
    END IF;
    IF p_order_header.attribute4 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute4 := NULL;
    END IF;
    IF p_order_header.attribute5 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute5 := NULL;
    END IF;
    IF p_order_header.attribute6 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute6 := NULL;
    END IF;
    IF p_order_header.attribute7 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute7 := NULL;
    END IF;
    IF p_order_header.attribute8 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute8 := NULL;
    END IF;
    IF p_order_header.attribute9 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute9 := NULL;
    END IF;
    IF p_order_header.attribute10 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute10 := NULL;
    END IF;
    IF p_order_header.attribute11 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute11 := NULL;
    END IF;
    IF p_order_header.attribute12 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute12 := NULL;
    END IF;
    IF p_order_header.attribute13 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute13 := NULL;
    END IF;
    IF p_order_header.attribute14 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute14 := NULL;
    END IF;
    IF p_order_header.attribute15 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute15 := NULL;
    END IF;
    IF p_order_header.attribute16 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute16 := NULL;
    END IF;
    IF p_order_header.attribute17 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute17 := NULL;
    END IF;
    IF p_order_header.attribute18 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute18 := NULL;
    END IF;
    IF p_order_header.attribute19 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute19 := NULL;
    END IF;
    IF p_order_header.attribute20 = FND_API.G_MISS_CHAR THEN
        p_order_header.attribute20 := NULL;
    END IF;

    IF p_order_header.order_version IS NULL THEN
       p_order_header.order_version := 1;
    END IF;
    IF p_order_header.required_fulfillment_date IS NULL THEN
       p_order_header.required_fulfillment_date := SYSDATE;
    END IF;
    IF p_order_header.priority IS NULL THEN
       p_order_header.priority := 100;
    END IF;

    IF p_order_header.jeopardy_enabled_flag IS NULL THEN
       p_order_header.jeopardy_enabled_flag := 'Y';
    END IF;

    IF p_order_header.execution_mode IS NULL THEN
       p_order_header.execution_mode := 'ASYNC';
    END IF;
END;

PROCEDURE TO_NULL(p_order_param_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST)
IS
    lv_param_index  BINARY_INTEGER;
BEGIN
    IF p_order_param_list.COUNT > 0 THEN
        lv_param_index := p_order_param_list.first;
        LOOP

            IF p_order_param_list(lv_param_index).parameter_name = FND_API.G_MISS_CHAR
            THEN
                p_order_param_list(lv_param_index).parameter_name := NULL;
            END IF;
            IF p_order_param_list(lv_param_index).parameter_value = FND_API.G_MISS_CHAR
            THEN
                p_order_param_list(lv_param_index).parameter_value := NULL;
            END IF;

            EXIT WHEN lv_param_index = p_order_param_list.last;
            lv_param_index := p_order_param_list.next(lv_param_index);
        END LOOP;
   END IF;
END;

PROCEDURE TO_NULL(p_order_line_item IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_ITEM)
IS
BEGIN
    IF p_order_line_item.line_number = FND_API.G_MISS_NUM THEN
       p_order_line_item.line_number := NULL;
    END IF;
    IF p_order_line_item.line_source = FND_API.G_MISS_CHAR THEN
       p_order_line_item.line_source := NULL;
    END IF;

    IF p_order_line_item.inventory_item_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.inventory_item_id := NULL;
    END IF;

    IF p_order_line_item.service_item_name = FND_API.G_MISS_CHAR THEN
       p_order_line_item.service_item_name := NULL;
    END IF;

    IF p_order_line_item.workitem_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.workitem_id := NULL;
    END IF;

    IF p_order_line_item.version = FND_API.G_MISS_CHAR THEN
       p_order_line_item.version := NULL;
    END IF;

    IF p_order_line_item.action_code = FND_API.G_MISS_CHAR THEN
       p_order_line_item.action_code := NULL;
    END IF;

    IF p_order_line_item.organization_code = FND_API.G_MISS_CHAR THEN
       p_order_line_item.organization_code := NULL;
    END IF;

    IF p_order_line_item.organization_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.organization_id := NULL;
    END IF;
    IF p_order_line_item.site_use_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.site_use_id := NULL;
    END IF;
    IF p_order_line_item.ib_source_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.ib_source_id := NULL;
    END IF;


    IF p_order_line_item.required_fulfillment_date = FND_API.G_MISS_DATE THEN
       p_order_line_item.required_fulfillment_date := NULL;
    END IF;
    IF p_order_line_item.bundle_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.bundle_id := NULL;
    END IF;
    IF p_order_line_item.bundle_sequence = FND_API.G_MISS_NUM THEN
       p_order_line_item.bundle_sequence := NULL;
    END IF;

    IF p_order_line_item.due_date = FND_API.G_MISS_DATE THEN
       p_order_line_item.due_date := NULL;
    END IF;
    IF p_order_line_item.customer_required_date = FND_API.G_MISS_DATE THEN
       p_order_line_item.customer_required_date := NULL;
    END IF;

    IF p_order_line_item.starting_number = FND_API.G_MISS_NUM THEN
       p_order_line_item.starting_number := NULL;
    END IF;
    IF p_order_line_item.ending_number = FND_API.G_MISS_NUM THEN
       p_order_line_item.ending_number := NULL;
    END IF;

    IF p_order_line_item.line_item_id = FND_API.G_MISS_NUM THEN
       p_order_line_item.line_item_id := NULL;
    END IF;

    IF p_order_line_item.line_status = FND_API.G_MISS_CHAR THEN
       p_order_line_item.line_status := NULL;
    END IF;

    IF p_order_line_item.completion_date = FND_API.G_MISS_DATE THEN
       p_order_line_item.completion_date := NULL;
    END IF;

    IF p_order_line_item.actual_fulfillment_date = FND_API.G_MISS_DATE THEN
       p_order_line_item.actual_fulfillment_date := NULL;
    END IF;

    IF p_order_line_item.parent_line_number = FND_API.G_MISS_NUM THEN
       p_order_line_item.parent_line_number := NULL;
    END IF;

    IF p_order_line_item.attribute_category = FND_API.G_MISS_CHAR THEN
        p_order_line_item.attribute_category := NULL;
    END IF;

    IF p_order_line_item.attribute1 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute1 := NULL;
    END IF;
    IF p_order_line_item.attribute2 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute2 := NULL;
    END IF;
    IF p_order_line_item.attribute3 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute3 := NULL;
    END IF;
    IF p_order_line_item.attribute4 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute4 := NULL;
    END IF;
    IF p_order_line_item.attribute5 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute5 := NULL;
    END IF;
    IF p_order_line_item.attribute6 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute6 := NULL;
    END IF;
    IF p_order_line_item.attribute7 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute7 := NULL;
    END IF;
    IF p_order_line_item.attribute8 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute8 := NULL;
    END IF;
    IF p_order_line_item.attribute9 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute9 := NULL;
    END IF;
    IF p_order_line_item.attribute10 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute10 := NULL;
    END IF;
    IF p_order_line_item.attribute11 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute11 := NULL;
    END IF;
    IF p_order_line_item.attribute12 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute12 := NULL;
    END IF;
    IF p_order_line_item.attribute13 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute13 := NULL;
    END IF;
    IF p_order_line_item.attribute14 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute14 := NULL;
    END IF;
    IF p_order_line_item.attribute15 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute15 := NULL;
    END IF;
    IF p_order_line_item.attribute16 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute16 := NULL;
    END IF;
    IF p_order_line_item.attribute17 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute17 := NULL;
    END IF;
    IF p_order_line_item.attribute18 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute18 := NULL;
    END IF;
    IF p_order_line_item.attribute19 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute19 := NULL;
    END IF;
    IF p_order_line_item.attribute20 = FND_API.G_MISS_CHAR THEN
       p_order_line_item.attribute20 := NULL;
    END IF;

    IF p_order_line_item.ib_source IS NULL THEN
       p_order_line_item.ib_source := 'NONE';
    END IF;

   IF p_order_line_item.fulfillment_required_flag IS NULL THEN
      p_order_line_item.fulfillment_required_flag := 'Y';
   END IF;

   IF p_order_line_item.is_package_flag IS NULL THEN
      p_order_line_item.is_package_flag := 'N';
   END IF;

   IF p_order_line_item.fulfillment_sequence IS NULL THEN
      p_order_line_item.fulfillment_sequence := 0;
   END IF;

   IF p_order_line_item.jeopardy_enabled_flag IS NULL THEN
      p_order_line_item.jeopardy_enabled_flag := 'N';
   END IF;

   IF p_order_line_item.is_virtual_line_flag IS NULL THEN
      p_order_line_item.is_virtual_line_flag := 'N';
   END IF;
END;

PROCEDURE TO_NULL(p_order_line_list IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST)
IS
    lv_param_index  BINARY_INTEGER;
BEGIN
    IF p_order_line_list.COUNT > 0 THEN
        lv_param_index := p_order_line_list.first;
        LOOP
            TO_NULL(p_order_line_list(lv_param_index));
            EXIT WHEN lv_param_index = p_order_line_list.last;
            lv_param_index := p_order_line_list.next(lv_param_index);
        END LOOP;
    END IF;
END;

PROCEDURE TO_NULL(p_line_param_list IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST)
IS
    lv_param_index  BINARY_INTEGER;
BEGIN
    IF p_line_param_list.COUNT > 0 THEN
        lv_param_index := p_line_param_list.first;
        LOOP
            IF p_line_param_list(lv_param_index).line_number = FND_API.G_MISS_NUM
            THEN
                p_line_param_list(lv_param_index).line_number := NULL;
            END IF;

            IF p_line_param_list(lv_param_index).parameter_name = FND_API.G_MISS_CHAR
            THEN
                p_line_param_list(lv_param_index).parameter_name := NULL;
            END IF;
            IF p_line_param_list(lv_param_index).parameter_value = FND_API.G_MISS_CHAR
            THEN
                p_line_param_list(lv_param_index).parameter_value := NULL;
            END IF;
            IF p_line_param_list(lv_param_index).parameter_ref_value = FND_API.G_MISS_CHAR
            THEN
                p_line_param_list(lv_param_index).parameter_ref_value := NULL;
            END IF;

            EXIT WHEN lv_param_index = p_line_param_list.last;
            lv_param_index := p_line_param_list.next(lv_param_index);
        END LOOP;
   END IF;
END;


END XDP_INTERFACES_PUB;

/
