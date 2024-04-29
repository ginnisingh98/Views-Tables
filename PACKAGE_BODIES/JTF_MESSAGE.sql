--------------------------------------------------------
--  DDL for Package Body JTF_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MESSAGE" as
/* $Header: JTFQMSGB.pls 115.6 2002/02/14 05:47:38 appldev ship $ */

-------------------------------------------------------------------
 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_Message';


Procedure get_prod_info( p_apps_short_name     varchar2,
                         x_schema        Out varchar2 ) IS
 l_schema  varchar2(30);
 l_status  varchar2(1);
 l_industry varchar2(1);
begin
    if ( FND_INSTALLATION.get_app_info(	p_apps_short_name, l_status, l_industry,
					l_schema  )  )  then
	x_schema := l_schema;
    else
	raise_application_error(-20000, 'Failed to get Info for Product'||
			         p_apps_short_name );
    end if;
end get_prod_info;


Procedure Queue_Message( p_prod_code		varchar2,
	    		 p_bus_obj_code		varchar2,
	    		 p_bus_obj_name		varchar2,
			 p_correlation		varchar2,
	    		 p_message		CLOB	) as

 l_message_obj	       SYSTEM.JTF_MSG_OBJ := SYSTEM.JTF_MSG_OBJ( empty_clob() );
 l_enqueue_options 	dbms_aq.enqueue_options_t;
 l_message_properties	dbms_aq.message_properties_t;
 l_bo_Qname		varchar2(55) := 'JTF_DEF_QUEUE';
 l_msg_id	 	RAW(16);
 l_schema               varchar2(30);

Begin
	Begin
		select  queue_name  into  l_bo_Qname
		from  JTF_MSG_OBJ_ROUTE
		where
			PRODUCT_CODE   =  p_prod_code  and
			BUS_OBJ_CODE   =  p_bus_obj_code and
			ACTIVE_FLAG    =  'Y'    and
                        QUEUE_TYPE     = 'O' ;
			Exception
			  When  NO_DATA_FOUND then
				begin
				select  queue_name  into  l_bo_Qname
				from  JTF_PROD_MSG_ROUTE
				where
				PRODUCT_CODE  =  p_prod_code  and
				ACTIVE_FLAG   =  'Y'   and
				QUEUE_TYPE    = 'O';
				exception
					When NO_DATA_FOUND then
					   l_bo_Qname := 'JTF_DEF_QUEUE';
					when OTHERS then
					   NULL;
				end;
			  When OTHERS then
				NULL;
        End;


    get_prod_info( 'JTF', l_schema);

    l_bo_Qname := l_schema||'.'||l_bo_Qname;
    l_message_obj.message := p_message;
    l_message_properties.correlation := p_correlation;

    dbms_aq.enqueue(    queue_name         => l_bo_Qname ,
   			enqueue_options    => l_enqueue_options ,
   			message_properties => l_message_properties ,
   			payload            => l_message_obj ,
   			msgid              => l_msg_id );



End Queue_Message;


END JTF_Message;

/
