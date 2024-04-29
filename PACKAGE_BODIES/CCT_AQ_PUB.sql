--------------------------------------------------------
--  DDL for Package Body CCT_AQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_AQ_PUB" AS
/* $Header: cctpaqb.pls 115.40 2004/02/04 23:56:39 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_AQ_PUB';

-- return value = 0 => server is up
-- return value <> 0 => server is down.

FUNCTION IS_SERVER_UP (l_server_id IN NUMBER) RETURN NUMBER IS
l_serverStatus NUMBER;
l_serverLastUpdateDate DATE;
l_refreshRate CONSTANT NUMBER := 60000; -- refresh rate is 1 minute for all cct servers.

BEGIN

--dbms_output.put_line ('Begin function is_server_up, server_id= ' || l_server_id);
SELECT STATUS, LAST_UPDATE_DATE into l_serverStatus, l_serverLastUpdateDate
FROM IEO_SVR_RT_INFO
WHERE SERVER_ID = l_server_id;
 -- status 4 = started and ready
IF ((l_serverStatus >= 4) and
    ((( sysdate - l_serverLastUpdateDate )*24*60*60*1000) < l_refreshRate)) THEN
        --dbms_output.put_line ('End is_server_up, returning 0');
        return 0;
END IF;
 --dbms_output.put_line ('End is_server_up, returning 1');
return 1;
END IS_SERVER_UP;






PROCEDURE ENQUEUE_ITEM
( 	p_api_version       IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2,
	p_commit	    	IN  	VARCHAR2 ,
	p_server_group_name	IN 	VARCHAR2 ,
	p_app_id		IN   	NUMBER,
 	p_xml_data1		IN   	VARCHAR2 ,
	p_media_type	IN	NUMBER ,
    p_delay         IN NUMBER ,
	x_return_status	OUT NOCOPY VARCHAR2		  	,
	x_msg_count		OUT NOCOPY NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'ENQUEUE_ITEM';
l_api_version       CONSTANT NUMBER 		:= 1.0;
enqueue_options		dbms_aq.enqueue_options_t;
message_properties	dbms_aq.message_properties_t;
message_handle		RAW(16);
message			SYSTEM.cct_ibmedia_type;
final_xml_data1 VARCHAR2(2048);
server_group_name_null        EXCEPTION;
server_group_id_null	      EXCEPTION;
xml_data1_null EXCEPTION;
p_server_group_id NUMBER;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	ENQUEUE_ITEM_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_AQ_SUCCESS';
        x_msg_count := 0;
	-- API body
IF p_server_group_name IS NULL then
        raise server_group_name_null;
END IF;

IF p_xml_data1 IS NULL then
        raise xml_data1_null;
END IF;


-- Assemble Data into Object


select server_group_id into p_server_group_id from ieo_svr_groups
  where group_name = p_server_group_name;


IF p_server_group_id IS NULL then
        raise server_group_id_null;
END IF;

--dbms_output.put_line ('ENQUEUE_ITEM: ServerGroupId = ' ||  p_server_group_id);
--dbms_output.put_line ('ENQUEUE_ITEM: Xmldata1 = ' ||  p_xml_data1);

message_properties.correlation := p_server_group_id;

IF (p_delay > 0) THEN
    message_properties.delay := p_delay;
END IF;

final_xml_data1 := p_xml_data1 || ';UUID:' || p_media_type;

message := SYSTEM.cct_ibmedia_type(SYSDATE,p_server_group_id,p_app_id,final_xml_data1);

--dbms_output.put_line ('ENQUEUE_ITEM: MessageCreated');

dbms_aq.enqueue(queue_name => CCT_QUEUE.queue_name,
			enqueue_options => enqueue_options,
			message_properties => message_properties,
			payload => message,
			msgid 	=> message_handle);

--dbms_output.put_line ('ENQUEUE_ITEM: Enqueue done');

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

EXCEPTION

   WHEN server_group_id_null THEN
	ROLLBACK TO ENQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_SERVER_GROUP_ID_NULL' ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

   WHEN server_group_name_null THEN
   	ROLLBACK TO ENQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_SERVER_GROUP_NAME_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

   WHEN xml_data1_null THEN
        ROLLBACK TO ENQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_XML_DATA1_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ENQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ENQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN OTHERS THEN
		ROLLBACK TO ENQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

END ENQUEUE_ITEM;

PROCEDURE GET_ROOT_GROUP_NAME
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list			IN	VARCHAR2 ,
  	p_server_group_name 		IN 	VARCHAR2,
 	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_root_server_group_name	OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_ROOT_GROUP_NAME';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
curr_group_group_id NUMBER;
curr_server_group_name VARCHAR2(256);
server_group_name_null EXCEPTION;

BEGIN

    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
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
	--  Initialize API return status to success
	--  Initialize API return status to succes
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_AQ_SUCCESS';
        x_msg_count := 0;

	-- API body
IF p_server_group_name IS NULL then
        raise server_group_name_null;
END IF;
curr_server_group_name := p_server_group_name;
select group_group_id into curr_group_group_id from ieo_svr_groups where group_name = curr_server_group_name;
WHILE (true)
LOOP
	select group_name ,
	group_group_id into  curr_server_group_name,curr_group_group_id
    from ieo_svr_groups
	where server_group_id = curr_group_group_id;

END LOOP;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		x_root_server_group_name := curr_server_group_name;

   	WHEN server_group_name_null THEN
		x_msg_data := 'CCT_AQ_SERVER_GROUP_ID_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

  	WHEN FND_API.G_EXC_ERROR THEN
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN OTHERS THEN
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

END GET_ROOT_GROUP_NAME;

PROCEDURE DEQUEUE_ITEM
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2,
	p_commit	    	IN  	VARCHAR2,
	p_server_group_id	IN	NUMBER				,
	x_return_status		OUT	NOCOPY VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_server_group_name	OUT NOCOPY 	VARCHAR2 ,
 	x_xml_data1		OUT NOCOPY   	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'DEQUEUE_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
dequeue_options		dbms_aq.dequeue_options_t;
message_properties	dbms_aq.message_properties_t;
message_handle		RAW(16);
message			SYSTEM.cct_ibmedia_type;
server_group_id_null        EXCEPTION;
no_messages         exception;
pragma exception_init  (no_messages, -25228);

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	DEQUEUE_ITEM_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
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
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_AQ_SUCCESS';
        x_msg_count := 0;

	-- API body

	dequeue_options.correlation := p_server_group_id;
    dequeue_options.wait := 15 ;
    dequeue_options.visibility := DBMS_AQ.IMMEDIATE;
    dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE ;


  --dbms_output.put_line('DEQUEUE_ITEM: dequeue correlation ' || p_server_group_id);

	dbms_aq.dequeue(
		queue_name => CCT_QUEUE.queue_name,
		dequeue_options => dequeue_options,
		message_properties => message_properties,
		payload => message,
		msgid => message_handle);
  --dbms_output.put_line('DEQUEUE_ITEM: Dequeue done');
	x_xml_data1 := message.xml_data1;
	select group_name into x_server_group_name from ieo_svr_groups where
	server_group_id = message.server_group_id;
  --dbms_output.put_line('DEQUEUE_ITEM: Select done');

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
    WHEN no_messages THEN
        x_return_status := G_TIMEOUT ;
    WHEN server_group_id_null THEN
       	ROLLBACK TO DEQUEUE_ITEM_PUB;
   		x_msg_data := 'CCT_AQ_SERVER_GROUP_ID_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
   	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO DEQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --dbms_output.put_line('Unexpected error');
		ROLLBACK TO DEQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN OTHERS THEN
		ROLLBACK TO DEQUEUE_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

END DEQUEUE_ITEM;




PROCEDURE ENQUEUE_WEB_CALLBACK_ITEM
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  	VARCHAR2,
	p_server_group_name	IN 	VARCHAR2,
	p_app_id		IN   	NUMBER,
	p_country_code		IN 	NUMBER,
	p_area_code		IN	NUMBER,
	p_phone_number		IN	NUMBER,
	p_delay			IN 	NUMBER,
	p_key1			IN 	VARCHAR2,
	p_value1		IN 	VARCHAR2,
	p_key2			IN 	VARCHAR2,
	p_value2		IN 	VARCHAR2,
	p_key3			IN 	VARCHAR2,
	p_value3		IN 	VARCHAR2,
	p_key4 			IN 	VARCHAR2,
	p_value4		IN 	VARCHAR2,
	p_key5			IN 	VARCHAR2,
	p_value5		IN 	VARCHAR2,
	p_key6			IN 	VARCHAR2,
	p_value6		IN 	VARCHAR2,
	p_key7			IN 	VARCHAR2,
	p_value7		IN 	VARCHAR2,
	p_key8 			IN 	VARCHAR2,
	p_value8		IN 	VARCHAR2,
	p_key9			IN 	VARCHAR2,
	p_value9		IN 	VARCHAR2,
	p_key10			IN 	VARCHAR2,
	p_value10		IN 	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'ENQUEUE_WEB_CALLBACK_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_xml_data1 			VARCHAR2(2048) DEFAULT NULL;
l_iqdServerId       NUMBER;
l_isWebCallback     VARCHAR2(6) Default 'false';
l_return_status varchar2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(256);

l_key_country_code CONSTANT VARCHAR2(30) := G_KEY_COUNTRY_CODE;
l_key_area_code CONSTANT VARCHAR2(30) := G_KEY_AREA_CODE;
l_key_phone_number CONSTANT VARCHAR2(30) := G_KEY_PHONE_NUMBER;
l_key_local_server_group_name CONSTANT VARCHAR2(30) := G_KEY_LOCAL_SERVER_GROUP_NAME;
l_key_root_server_group_name CONSTANT VARCHAR2(30) := G_KEY_SUPER_SERVER_GROUP_NAME;
l_root_server_group_name VARCHAR2(256);
l_server_group_id NUMBER;
l_item_id NUMBER;
l_kvp cct_keyvalue_varr := cct_keyvalue_varr();
l_put_result varchar2(256);

server_group_name_null  EXCEPTION;
country_code_null		EXCEPTION;
area_code_null			EXCEPTION;
phone_number_null		EXCEPTION;
web_callback_false      EXCEPTION;
server_down             EXCEPTION;


BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	ENQUEUE_WEB_CALLBACK_ITEM_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_AQ_SUCCESS';
        x_msg_count := 0;
	-- API body

IF p_server_group_name IS NULL then
        raise server_group_name_null;
END IF;

    cct_aq_pub.get_root_group_name (
    p_api_version => 1.0,
    p_server_group_name => p_server_group_name,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    x_root_server_group_name => l_root_server_group_name
    );

IF p_server_group_name <> G_BASIC_SDK_GROUP_NAME THEN

BEGIN

    select server_id into l_iqdServerId from ieo_svr_servers
    where member_svr_group_id =
    (select server_group_id from ieo_svr_groups where group_name = l_root_server_group_name)
    and type_id = 10110 ;

   --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: IQD Server id =' || l_iqdServerId );
    begin
    select value into l_isWebCallback from ieo_svr_values
    where param_id = (select param_id from ieo_svr_params
        where type_id = 10110 and param_name = 'IS_WEB_CALLBACK')
    and server_id = l_iqdServerId;

    if sql%notfound then
        l_isWebCallback := 'false';
    end if;
    exception when others then null;
    end;

   --dbms_output.put_line('l_isWebCallback = ' || l_isWebCallback);

    IF UPPER(l_isWebCallback) <> UPPER('true') then
        raise web_callback_false;
    END IF;

END;
END IF;



IF p_phone_number IS NULL then
        raise phone_number_null;
END IF;


-- Assemble Data into Object

l_xml_data1 := l_key_phone_number || ':' || p_phone_number ;
l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,l_key_phone_number, p_phone_number );

l_xml_data1 := l_xml_data1 || ';' || l_key_local_server_group_name || ':' || p_server_group_name;
l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,l_key_local_server_group_name, p_server_group_name);

l_xml_data1 := l_xml_data1 || ';' || l_key_root_server_group_name || ':' || l_root_server_group_name;
l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,l_key_root_server_group_name, l_root_server_group_name);


IF (p_country_code IS NOT NULL) THEN

	l_xml_data1 := l_xml_data1 || ';' || l_key_country_code || ':' || p_country_code ;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,l_key_country_code, p_country_code);
END IF;

IF (p_area_code IS NOT NULL) THEN

	l_xml_data1 := l_xml_data1 || ';' || l_key_area_code || ':' || p_area_code ;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,l_key_area_code, p_area_code);

END IF;

IF ((p_key1 IS NOT NULL) AND (p_value1 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key1 || ':' || p_value1;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key1, p_value1);
END IF;
IF ((p_key2 IS NOT NULL) AND (p_value2 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key2 || ':' || p_value2;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key2, p_value2);
END IF;
IF ((p_key3 IS NOT NULL) AND (p_value3 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key3 || ':' || p_value3;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key3, p_value3);
END IF;
IF ((p_key4 IS NOT NULL) AND (p_value4 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key4 || ':' || p_value4;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key4, p_value4);
END IF;
IF ((p_key5 IS NOT NULL) AND (p_value5 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key5 || ':' || p_value5;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key5, p_value5);
END IF;
IF ((p_key6 IS NOT NULL) AND (p_value6 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key6 || ':' || p_value6;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key6, p_value6);
END IF;
IF ((p_key7 IS NOT NULL) AND (p_value7 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key7 || ':' || p_value7;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key7, p_value7);
END IF;
IF ((p_key8 IS NOT NULL) AND (p_value8 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key8 || ':' || p_value8;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key8, p_value8);
END IF;
IF ((p_key9 IS NOT NULL) AND (p_value9 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key9 || ':' || p_value9;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key9, p_value9);
END IF;
IF ((p_key10 IS NOT NULL) AND (p_value10 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key10 || ':' || p_value10;
    l_put_result:=CCT_COLLECTION_UTIL_PUB.PUT(l_kvp,p_key10, p_value10);
END IF;


IF p_server_group_name <> G_BASIC_SDK_GROUP_NAME THEN

BEGIN

   --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: xml_data1= ' || l_xml_data1);

    enqueue_item (
    p_api_version => p_api_version,
    p_init_msg_list	=> p_init_msg_list,
    p_commit => p_commit,
    p_server_group_name => l_root_server_group_name,
    p_app_id => p_app_id,
    p_xml_data1 => l_xml_data1,
    p_media_type => CCT_MEDIA_TYPES_PUB.G_WEB_CALLBACK,
    p_delay => p_delay,
    x_return_status => x_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
    );

   --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: Enqueue done!');
   --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: ' || x_return_status);
   --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: ' || l_msg_count);
   --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: ' || l_msg_data);
    -- End of API body.
    -- Standard check of p_commit.

    -- web callback is true, now check if server is up do this at the end, otherwise ,
    -- values of x_msg_data will get over-written by the enqueue call.
    if (is_server_up(l_iqdServerId) <> 0) then
        x_msg_count := 1;
        x_msg_data := 'CCT_AQ_IQD_SERVER_DOWN';
    end if;

END;

ELSE

BEGIN


  --dbms_output.put_line('CCT_AQ_PUB - printing kvp');
  --FOR i IN l_kvp.FIRST..l_kvp.LAST
  --LOOP
       --dbms_output.put_line(l_kvp(i));
  --END LOOP;


    CCT_MQD_PUB.RECEIVE_MEDIA_ITEM
       (p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_commit => p_commit,
        p_app_id => 172,
        p_item_type => CCT_MEDIA_TYPES_PUB.G_BASIC_WEB_CALLBACK,
        p_classification => 'unClassified',
        p_kvp => l_kvp,
        p_server_group_name => G_BASIC_SDK_GROUP_NAME,
        p_direction => CCT_IH_PUB.G_IH_DIRECTION_INBOUND,
        p_ih_item_type => CCT_IH_PUB.G_IH_TELE_WEB_CALLBACK,
        x_return_status	=> l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        x_media_id => l_item_id);

    --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: post CCT_AQ_PUB.RECEIVE_MEDIA_ITEM ');

    CCT_QDE_PUB.UPDATE_ROUTE_RESULT
       (p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_commit => p_commit,
        p_item_id => l_item_id,
        p_item_type => CCT_MEDIA_TYPES_PUB.G_BASIC_WEB_CALLBACK,
        p_classification => 'unClassified',
        p_route_result => null,
        p_is_route_to_all => 'Y',
        p_is_reroute => 'N',
        p_kvp => l_kvp,
        x_return_status	=> x_return_status,
        x_msg_count	=> x_msg_count,
        x_msg_data	=> x_msg_data);

    --dbms_output.put_line('ENQUEUE_WEB_CALLBACK_ITEM: post CCT_QDE_MEDIA_PUB.UPDATE_ROUTE_RESULT ');

END;
END IF;


IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
END IF;


EXCEPTION

   WHEN web_callback_false THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_WEB_CALLBACK_FALSE';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
   WHEN server_group_name_null THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_SERVER_GROUP_NAME_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
   WHEN country_code_null THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_COUNTRY_CODE_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
   WHEN area_code_null THEN
       	ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_AREA_CODE_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
   WHEN phone_number_null THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_PHONE_NUMBER_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_ERROR' || SQLCODE || SUBSTR(SQLERRM, 1, 100);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_ERROR' || SQLCODE || SUBSTR(SQLERRM, 1, 100);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
	WHEN OTHERS THEN
        ROLLBACK TO ENQUEUE_WEB_CALLBACK_ITEM_PUB;
        x_msg_data := 'CCT_AQ_ERROR' || SQLCODE || SUBSTR(SQLERRM, 1, 100);
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;
END ENQUEUE_WEB_CALLBACK_ITEM;


PROCEDURE ENQUEUE_WEB_COLLAB_ITEM
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2,
	p_commit	    	IN  VARCHAR2,
    p_server_group_id   IN  NUMBER,
    p_server_group_name IN  VARCHAR2,
    p_app_id            IN NUMBER,
    p_meeting_url       IN  VARCHAR2 ,
    p_with_callback     IN  VARCHAR2,
    p_ih_media_item_id  IN NUMBER,
	p_country_code		IN 	NUMBER,
	p_area_code		    IN	NUMBER,
	p_phone_number		IN	NUMBER,
	p_key1			IN 	VARCHAR2,
	p_value1		IN 	VARCHAR2,
	p_key2			IN 	VARCHAR2,
	p_value2		IN 	VARCHAR2,
	p_key3			IN 	VARCHAR2,
	p_value3		IN 	VARCHAR2,
	p_key4 			IN 	VARCHAR2,
	p_value4		IN 	VARCHAR2,
	p_key5			IN 	VARCHAR2,
	p_value5		IN 	VARCHAR2,
	p_key6			IN 	VARCHAR2,
	p_value6		IN 	VARCHAR2,
	p_key7			IN 	VARCHAR2,
	p_value7		IN 	VARCHAR2,
	p_key8 			IN 	VARCHAR2,
	p_value8		IN 	VARCHAR2,
	p_key9			IN 	VARCHAR2,
	p_value9		IN 	VARCHAR2,
	p_key10			IN 	VARCHAR2,
	p_value10		IN 	VARCHAR2,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'ENQUEUE_WEB_COLLAB_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_xml_data1 			VARCHAR2(2048) DEFAULT NULL;


l_key_country_code CONSTANT VARCHAR2(30) := G_KEY_COUNTRY_CODE;
l_key_area_code CONSTANT VARCHAR2(30) := G_KEY_AREA_CODE;
l_key_phone_number CONSTANT VARCHAR2(30) := G_KEY_PHONE_NUMBER;
l_key_local_server_group_name CONSTANT VARCHAR2(30) := G_KEY_LOCAL_SERVER_GROUP_NAME;
l_key_root_server_group_name CONSTANT VARCHAR2(30) := G_KEY_SUPER_SERVER_GROUP_NAME;
l_local_server_group_name VARCHAR2(256) DEFAULT NULL;
l_root_server_group_name VARCHAR2(256);

l_key_meeting_url CONSTANT VARCHAR2(30) := G_KEY_MEETING_URL;
l_key_with_callback CONSTANT VARCHAR2(30) := G_KEY_WITH_CALLBACK;
l_key_ih_media_item_id CONSTANT VARCHAR2(30) := G_KEY_MEDIA_ITEM_ID;

server_group_undefined          EXCEPTION;
meeting_url_null		EXCEPTION;
ih_media_item_id_null		EXCEPTION;
phone_number_null 		EXCEPTION;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	ENQUEUE_WEB_COLLAB_ITEM_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success

    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_AQ_SUCCESS';
        x_msg_count := 0;

	-- API body

IF ((p_server_group_name IS NULL) and (p_server_group_id IS NULL)) THEN
        raise server_group_undefined;
END IF;

IF (p_meeting_url IS NULL) THEN
	raise meeting_url_null;
END IF;

IF (p_ih_media_item_id = -1) THEN
	raise ih_media_item_id_null;
END IF;

IF (p_with_callback = FND_API.G_TRUE) THEN
	IF (p_phone_number IS NULL) THEN
		raise phone_number_null;
	END IF;
END IF;

-- Assemble Data into Object

IF (p_server_group_id IS NOT NULL) THEN
	select group_name into l_local_server_group_name from ieo_svr_groups where server_group_id = p_server_group_id;
	IF (l_local_server_group_name IS NULL) THEN
		raise server_group_undefined;
	END IF;
	l_xml_data1 := l_key_local_server_group_name || ':' || l_local_server_group_name;
ELSE
	IF (p_server_group_name IS NULL) THEN
		raise server_group_undefined;
	END IF;
 	l_xml_data1 := l_key_local_server_group_name || ':' || p_server_group_name;
END IF;

IF (p_meeting_url IS NOT NULL) THEN
	l_xml_data1 := l_xml_data1 || ';' || l_key_meeting_url || ':' || p_meeting_url ;
END IF;

IF (p_with_callback IS NOT NULL) THEN
	l_xml_data1 := l_xml_data1 || ';' || l_key_with_callback || ':' || p_with_callback ;
END IF;

IF (p_ih_media_item_id IS NOT NULL) THEN
	l_xml_data1 := l_xml_data1 || ';' || l_key_ih_media_item_id || ':' || p_ih_media_item_id ;
END IF;

IF (p_country_code IS NOT NULL) THEN
	l_xml_data1 := l_xml_data1 || ';' || l_key_country_code || ':' || p_country_code ;
END IF;

IF (p_area_code IS NOT NULL) THEN
	l_xml_data1 := l_xml_data1 || ';' || l_key_area_code || ':' || p_area_code ;
END IF;

IF (p_phone_number IS NOT NULL) THEN
	l_xml_data1 := l_xml_data1 || ';' || l_key_phone_number || ':' || p_phone_number ;
END IF;


IF ((p_key1 IS NOT NULL) AND (p_value1 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key1 || ':' || p_value1;
END IF;
IF ((p_key2 IS NOT NULL) AND (p_value2 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key2 || ':' || p_value2;
END IF;
IF ((p_key3 IS NOT NULL) AND (p_value3 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key3 || ':' || p_value3;
END IF;
IF ((p_key4 IS NOT NULL) AND (p_value4 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key4 || ':' || p_value4;
END IF;
IF ((p_key5 IS NOT NULL) AND (p_value5 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key5 || ':' || p_value5;
END IF;
IF ((p_key6 IS NOT NULL) AND (p_value6 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key6 || ':' || p_value6;
END IF;
IF ((p_key7 IS NOT NULL) AND (p_value7 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key7 || ':' || p_value7;
END IF;
IF ((p_key8 IS NOT NULL) AND (p_value8 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key8 || ':' || p_value8;
END IF;
IF ((p_key9 IS NOT NULL) AND (p_value9 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key9 || ':' || p_value9;
END IF;
IF ((p_key10 IS NOT NULL) AND (p_value10 IS NOT NULL)) THEN
	l_xml_data1 := l_xml_data1 || ';' || p_key10 || ':' || p_value10;
END IF;

get_root_group_name (
p_api_version => 1.0,
p_server_group_name => p_server_group_name,
x_return_status => x_return_status,
x_msg_count => x_msg_count,
x_msg_data => x_msg_data,
x_root_server_group_name => l_root_server_group_name
);

--dbms_output.put_line('ENQUEUE_WEB_COLLAB_ITEM: xml_data1= ' || l_xml_data1);

l_xml_data1 := l_xml_data1 || ';' || l_key_root_server_group_name || ':' || l_root_server_group_name;

enqueue_item (
p_api_version => p_api_version,
p_init_msg_list	=> p_init_msg_list,
p_commit => p_commit,
p_server_group_name => l_root_server_group_name,
p_app_id => p_app_id,
p_xml_data1 => l_xml_data1,
p_media_type => CCT_MEDIA_TYPES_PUB.G_WEB_COLLAB,
x_return_status => x_return_status,
x_msg_count => x_msg_count,
x_msg_data => x_msg_data
);


    --dbms_output.put_line('ENQUEUE_WEB_COLLAB_ITEM: Enqueue done!');
	--End of API body.
	--Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

EXCEPTION

   WHEN server_group_undefined THEN
   	ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_SERVER_GROUP_NAME_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

   WHEN meeting_url_null THEN
   	ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_MEETING_URL_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

   WHEN ih_media_item_id_null THEN
   	ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_IH_MEDIA_ITEM_ID_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

   WHEN phone_number_null THEN
   	ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_PHONE_NUMBER_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN OTHERS THEN
		ROLLBACK TO ENQUEUE_WEB_COLLAB_ITEM_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

END ENQUEUE_WEB_COLLAB_ITEM;


PROCEDURE ABANDON_MEDIA
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2,
	p_commit	    	IN  	VARCHAR2,
	p_server_group_name	IN 	VARCHAR2,
	p_app_id		IN   	NUMBER,
    p_media_item_id IN NUMBER ,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'ABANDON_MEDIA';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_xml_data1 			VARCHAR2(2048) DEFAULT NULL;
-- l_key_server_group CONSTANT VARCHAR2(30) := 'ServerGroup';
l_key_media_item_id CONSTANT VARCHAR2(30) := 'MediaItemId';

l_root_server_group_name VARCHAR2(256);

server_group_name_null          EXCEPTION;
BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	ABANDON_MEDIA_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_AQ_SUCCESS';
        x_msg_count := 0;

	-- API body
IF p_server_group_name IS NULL then
        raise server_group_name_null;
END IF;

-- Assemble Data into Object

get_root_group_name (
p_api_version => 1.0,
p_server_group_name => p_server_group_name,
x_return_status => x_return_status,
x_msg_count => x_msg_count,
x_msg_data => x_msg_data,
x_root_server_group_name => l_root_server_group_name
);

-- l_xml_data1 := l_key_server_group || ':' || p_server_group_name ;

l_xml_data1 := l_key_media_item_id || ':' || p_media_item_id ;

--dbms_output.put_line('ABANDON_MEDIA: xml_data1= ' || l_xml_data1);

enqueue_item (
p_api_version => p_api_version,
p_init_msg_list	=> p_init_msg_list,
p_commit => p_commit,
p_server_group_name => l_root_server_group_name,
p_app_id => p_app_id,
p_xml_data1 => l_xml_data1,
p_media_type => G_ABANDON_MEDIA,
x_return_status => x_return_status,
x_msg_count => x_msg_count,
x_msg_data => x_msg_data
);


    --dbms_output.put_line('ABANDON_MEDIA: Enqueue done!');
	--End of API body.
	--Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

EXCEPTION

   WHEN server_group_name_null THEN
   	ROLLBACK TO ABANDON_MEDIA_PUB;
        x_msg_data := 'CCT_AQ_SERVER_GROUP_NAME_NULL';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ABANDON_MEDIA_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ABANDON_MEDIA_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

	WHEN OTHERS THEN
		ROLLBACK TO ABANDON_MEDIA_PUB;
		x_msg_data := 'CCT_AQ_ERROR';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := 1;

END ABANDON_MEDIA;



END CCT_AQ_PUB;

/
