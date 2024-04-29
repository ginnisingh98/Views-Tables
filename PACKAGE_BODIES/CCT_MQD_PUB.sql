--------------------------------------------------------
--  DDL for Package Body CCT_MQD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_MQD_PUB" AS
/* $Header: cctpmqdb.pls 115.7 2003/10/18 00:01:28 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_MQD_PUB';


PROCEDURE RECEIVE_MEDIA_ITEM
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  VARCHAR2,
    p_app_id            IN  NUMBER,
    p_item_type		    IN	NUMBER,
    p_classification    IN  VARCHAR2,
    p_kvp               IN  cct_keyvalue_varr,
    p_server_group_name IN VARCHAR2,
    p_direction         IN VARCHAR2,
    p_ih_item_type      IN VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
	x_msg_data		OUT NOCOPY	VARCHAR2,
    x_media_id      OUT NOCOPY NUMBER
)

IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'RECEIVE_MEDIA_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_return_status varchar2(256);
l_msg_count number;
l_msg_data varchar2(256);
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_server_group_id number;


BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			        l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to failure

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;

	-- API body

    select server_group_id into l_server_group_id
    from ieo_svr_groups where group_name = p_server_group_name;

    --dbms_output.put_line('RECEIVE_MEDIA_ITEM: pre CCT_IH_PUB.OPEN_MEDIA_ITEM ');

    --dbms_output.put_line('CCT_MQD_PUB - printing kvp');
    --FOR i IN p_kvp.FIRST..p_kvp.LAST
    --LOOP
        --dbms_output.put_line(p_kvp(i));
    --END LOOP;

    CCT_IH_PUB.OPEN_MEDIA_ITEM
    (p_api_version => 1.0,
    p_init_msg_list	=> p_init_msg_list,
    p_commit	=> p_commit,
    p_app_id => p_app_id,
    p_user_id => FND_GLOBAL.USER_ID,
    p_direction => p_direction,
    p_start_date_time => sysdate,
    p_source_item_create_date_time => sysdate,
    p_media_item_type => p_ih_item_type,
    p_server_group_id => l_server_group_id,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data,
    x_media_id => x_media_id);

    if (l_return_status <> 'S') then
        raise_application_error(1000, 'CCT_MQD_PUB:RECEIVE_MEDIA_ITEM: '
        || 'OPEN_MEDIA_ITEM FAILED: ' || l_msg_data );
    end if;
    --dbms_output.put_line('RECEIVE_MEDIA_ITEM: post CCT_IH_PUB.OPEN_MEDIA_ITEM ');

    CCT_QDE_PUB.RECEIVE_ITEM
    (p_api_version => 1.0,
    p_init_msg_list	=> p_init_msg_list,
    p_commit	=> p_commit,
    p_app_id => p_app_id,
    p_item_id => x_media_id,
    p_item_type => p_item_type,
    p_classification => p_classification,
    p_kvp => p_kvp,
    p_delay => 0,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data);

    if (l_return_status <> 'S') then
        raise_application_error(1000, 'CCT_MQD_PUB:RECEIVE_MEDIA_ITEM: '
        || 'RECEIVE_ITEM FAILED: ' || l_msg_data );
    end if;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;


EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'RECEIVE_MEDIA_ITEM: CCT_ERROR '
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'RECEIVE_MEDIA_ITEM: CCT_ERROR '
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;

            --dbms_output.put_line(x_msg_data);

        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            --dbms_output.put_line('Unexpected error in others');
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'RECEIVE_MEDIA_ITEM: CCT_ERROR '
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;

            --dbms_output.put_line(x_msg_data);

END RECEIVE_MEDIA_ITEM;


PROCEDURE GET_NEXT_MEDIA_ITEM
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	  p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
    p_classification IN VARCHAR2,
    p_polling       IN VARCHAR2,
 	  x_return_status	OUT NOCOPY	VARCHAR2,
	  x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_app_id        OUT NOCOPY NUMBER,
    x_item_id OUT NOCOPY NUMBER,
    x_item_type	OUT NOCOPY	NUMBER,
    x_classification OUT NOCOPY  VARCHAR2,
    x_kvp     OUT NOCOPY VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_NEXT_MEDIA_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_return_status varchar2(256);
l_msg_count number;
l_msg_data varchar2(256);
l_classification varchar2(1024);
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_kvp cct_keyvalue_varr := cct_keyvalue_varr();
dequeue_options		dbms_aq.dequeue_options_t;
message_properties	dbms_aq.message_properties_t;
message_handle		RAW(16);
message			SYSTEM.cct_qde_response;
no_messages         exception;
pragma exception_init  (no_messages, -25228);


BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			        l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to failure
   	-- API body
    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;
    x_item_id := -1;
    x_item_type := -1;
    x_classification := null;
    x_kvp := null;

    l_classification := p_classification;
    if (l_classification = '<ANY>')
    then l_classification := null;
    end if;

    begin
      dequeue_options.correlation := p_agent_id;
      dequeue_options.wait := 0 ;
      dequeue_options.visibility := DBMS_AQ.IMMEDIATE;
      dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE ;
      dbms_aq.dequeue(
        queue_name => CCT_QDE_QUEUE.queue_name,
        dequeue_options => dequeue_options,
        message_properties => message_properties,
        payload => message,
        msgid => message_handle);
      x_app_id := 172;
      x_item_id := message.item_id;
      x_item_type := message.item_type;
      x_classification := message.classification;
      x_kvp := CCT_COLLECTION_UTIL_PUB.CCT_KeyValue_Varr_ToString(message.kvp);
    exception
    when no_messages then
      x_item_id := -1;
      x_item_type := -1;
      x_classification := null;
      x_kvp := null;
    when others then
      x_item_id := -1;
      x_item_type := -1;
      x_classification := null;
      x_kvp := null;
    end;

    if ((p_polling <> 'Y') and (x_item_id = -1)) then
    begin
      CCT_QDE_PUB.GET_NEXT_ITEM (p_api_version => 1.0,
      p_init_msg_list	=> p_init_msg_list,
      p_commit	=> p_commit,
      p_agent_id => p_agent_id,
      p_item_type => p_item_type,
      p_classification => l_classification,
      x_return_status	=> x_return_status,
      x_msg_count	=> x_msg_count,
      x_msg_data => x_msg_data,
      x_app_id => x_app_id,
      x_item_id  => x_item_id,
      x_item_type	=> x_item_type,
      x_classification => x_classification,
      x_kvp => l_kvp);
      x_kvp := CCT_COLLECTION_UTIL_PUB.CCT_KeyValue_Varr_ToString(l_kvp);
    end;
    end if;

    --dbms_output.put_line('CCT_MQD_PUB.GET_NEXT_MEDIA_ITEM '
                            --|| x_return_status || ' '
                            --|| x_msg_count || ' '
                            --|| x_msg_data || ' '
                            --|| x_app_id || ' '
                            --|| x_item_id || ' '
                            --|| x_item_type || ' '
                            --|| x_classification || ' '
                            --|| x_kvp);

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_NEXT_MEDIA_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_NEXT_MEDIA_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_NEXT_MEDIA_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END GET_NEXT_MEDIA_ITEM;


END CCT_MQD_PUB;

/
