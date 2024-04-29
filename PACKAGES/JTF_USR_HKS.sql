--------------------------------------------------------
--  DDL for Package JTF_USR_HKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_USR_HKS" AUTHID CURRENT_USER as
/* $Header: JTFUHKSS.pls 120.2 2005/11/15 14:05:06 jdang ship $ */

----------------------------------------------------------------------------

 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_USR_HKS';


/*	Data type declaration                            */
Type OAI_data_array_type is Varray(10) of Varchar2(50);


Function	Ok_To_Execute(	p_Pkg_name		varchar2,
				p_API_name		varchar2,
				p_Process_type		varchar2,
				p_User_hook_type	varchar2
			      ) Return Boolean;


Procedure WrkflowLaunch( p_Wf_item_name			varchar2,
                         p_Wf_item_process_name  	varchar2,
                         p_Wf_item_key       		varchar2,
		  	 p_Bind_data_id			number,
                         x_return_code        Out nocopy 	varchar2
			);

Procedure GenMsgWrkflowLaunch(
		p_Wf_item_name		varchar2 := 'JTFMSGWF',
                p_Wf_item_process_name  varchar2 := 'JTFMSGWF_PROCESS1',
                p_Wf_item_key       	varchar2,
		p_prod_code     	varchar2,
	   	p_bus_obj_code  	varchar2,
                p_bus_obj_name  	varchar2 := FND_API.G_MISS_CHAR,
		p_action_code		varchar2,
		p_correlation           varchar2 := FND_API.G_MISS_CHAR,
          	p_bind_data_id		Number,
		p_OAI_param		varchar2 := FND_API.G_MISS_CHAR,
		p_OAI_array		JTF_USR_HKS.OAI_data_array_type
		 				:= JTF_USR_HKS.OAI_data_array_type(FND_API.G_MISS_CHAR),
                x_return_code      Out 	varchar2
			);

/*   For publishing messages  */
Procedure Generate_message(
	p_prod_code    	 	varchar2,
   	p_bus_obj_code   	varchar2,
        p_bus_obj_name   	varchar2 := FND_API.G_MISS_CHAR,
	p_action_code	 	varchar2,
	p_correlation           varchar2 := FND_API.G_MISS_CHAR,
	p_bind_data_id		number,
	p_OAI_param	 	varchar2 := FND_API.G_MISS_CHAR,
	p_OAI_array	 	JTF_USR_HKS.OAI_data_array_type :=
			  		JTF_USR_HKS.OAI_data_array_type(FND_API.G_MISS_CHAR),
	x_return_code   Out	varchar2
  			);

/* For sending reply */
Procedure Generate_message(
	p_prod_code    	 	varchar2,
   	p_bus_obj_code   	varchar2,
        p_bus_obj_name   	varchar2 := FND_API.G_MISS_CHAR,
	p_action_code	 	varchar2,
	p_correlation           varchar2 := FND_API.G_MISS_CHAR,
	p_bind_data_id		number,
	p_ref_sender		varchar2,
	p_ref_msg_id		number,
	p_OAI_param	 	varchar2 := FND_API.G_MISS_CHAR,
	p_OAI_array	 	JTF_USR_HKS.OAI_data_array_type :=
			  		JTF_USR_HKS.OAI_data_array_type(FND_API.G_MISS_CHAR),
	x_return_code   Out	varchar2
  			);

/* For Sync/Async Request/reply    */
Procedure Generate_message(
	p_prod_code    	 	varchar2,
   	p_bus_obj_code   	varchar2,
        p_bus_obj_name   	varchar2 := FND_API.G_MISS_CHAR,
	p_action_code	 	varchar2,
	p_correlation           varchar2 := FND_API.G_MISS_CHAR,
	p_bind_data_id		number,
	p_timeout		number,
	p_OAI_param	 	varchar2 := FND_API.G_MISS_CHAR,
	p_OAI_array	 	JTF_USR_HKS.OAI_data_array_type :=
			  		JTF_USR_HKS.OAI_data_array_type(FND_API.G_MISS_CHAR),
	x_msg_id        Out nocopy	number,
	x_reply_msg     Out nocopy	CLOB,
	x_return_code   Out nocopy	varchar2
  			);

/*   For sending pre-generate XML  messages  */
Procedure Generate_message(
	p_prod_code    	 	varchar2,
   	p_bus_obj_code   	varchar2,
        p_bus_obj_name   	varchar2 := FND_API.G_MISS_CHAR,
	p_correlation           varchar2 := FND_API.G_MISS_CHAR,
	p_timeout		number   := 0,  /* 0-Async, >0 Sync ,< 0 sync-infinite wait */
	p_message		CLOB,
	p_msg_type		varchar2 := 'P',  /* P - Publish  , R - Sync/Async Req/Reply*/
	x_msg_id        Out nocopy	number,
	x_reply_msg     Out nocopy	CLOB,
	x_return_code   Out nocopy	varchar2
  			);

Function  Get_Bind_Data_Id Return Number;

Procedure Load_Bind_Data(
		p_bind_data_id		Number,
		p_bind_name		varchar2,
		p_bind_value		varchar2,
		p_bind_type		varchar2,
		p_data_type		varchar2
			);

Procedure Purge_Bind_Data( p_Bind_Data_Id	Number,
			   p_bind_type		Varchar2 );

Function  Get_User_Hook_Id Return Number;

Function  Get_Bus_Obj_Id Return Number;

procedure Generate_Hdrxml(
                        p_prodcode        IN varchar2,
                        p_bo_code         IN varchar2,
                        p_noun            IN varchar2 := fnd_api.g_miss_char,
                        p_verb            IN varchar2 := fnd_api.g_miss_char,
                        p_type            IN varchar2 := 'PUBLISH',
			p_sender	  IN varchar2 := fnd_api.g_miss_char,
                        p_msg_id  	  IN varchar2 := fnd_api.g_miss_char,
                        x_hdrxml         OUT nocopy varchar2 );

Procedure  Publish_Message(
			p_prod_code      Varchar2  ,
                        p_bus_obj_code   Varchar2  ,
			p_bus_obj_name	 Varchar2 := fnd_api.g_miss_char,
                        p_action_code    Varchar2  ,
                        p_correlation    Varchar2 := fnd_api.g_miss_char ,
                        p_bind_data_id   Number    ,
			p_msg_type       Varchar2 := fnd_api.g_miss_char,
			p_ref_sender     Varchar2 := fnd_api.g_miss_char,
			p_ref_msg_id     Number   := fnd_api.g_miss_num,
			p_timeout        Number   := 0  );


Procedure  Stage_Message(
			p_prod_code      Varchar2  ,
                        p_bus_obj_code   Varchar2  ,
                        p_action_code    Varchar2  ,
                        p_correlation    Varchar2  ,
                        p_bind_data_id   Number      );

Procedure  Handle_msg_Excep(
				p_prod_code      Varchar2  ,
                        	p_bus_obj_code   Varchar2  ,
                        	p_action_code    Varchar2  ,
                        	p_correlation    Varchar2  ,
                        	p_bind_data_id   Number    ,
				p_msg_type	 Varchar2  ,
				p_err_msg	 Varchar2    );

END jtf_usr_hks;

 

/
