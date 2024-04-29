--------------------------------------------------------
--  DDL for Package Body CCT_QDE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_QDE_PUB" AS
/* $Header: cctpqdeb.pls 115.6 2003/10/20 20:12:21 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_QDE_PUB';



FUNCTION UPDATE_CLASSIFICATION_COUNT
(
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
    p_classification IN VARCHAR2,
    p_count         IN NUMBER
)
RETURN NUMBER IS
ENTRY_NOT_FOUND EXCEPTION;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_item_type number;
BEGIN
    --dbms_output.put_line('UPDATE_CLASSIFICATION_COUNT:'
        --|| ' agent_id = ' || p_agent_id
        --|| ' p_item_type = ' || p_item_type
        --|| ' p_classification = ' || p_classification
        --|| ' p_count = ' || p_count);

    l_item_type := CCT_MEDIA_TYPES_PUB.GET_UWQ_MEDIA_TYPE_ID(p_item_type);

    update cct_qde_agent_queues set count = p_count
    where agent_id = p_agent_id
        and item_type = l_item_type
        and ((p_classification is null and classification is null) or (p_classification is not null
        and classification = p_classification)) ;
    if sql%notfound
    then raise ENTRY_NOT_FOUND;
    else
        begin
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;
            return 0;
        end;
    end if;

EXCEPTION
    WHEN ENTRY_NOT_FOUND THEN
        insert into cct_qde_agent_queues
        (   agent_queue_id, agent_id, item_type, classification, count,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        values
        (
            cct_qde_agent_queues_s1.nextval, p_agent_id, l_item_type, p_classification, p_count,
            1, sysdate, 1, sysdate, 1
        );
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
        return 0;
    WHEN OTHERS THEN
        rollback;
        x_err_num := SQLCODE;
        x_err_msg := SUBSTR(SQLERRM, 1, 100);
        --dbms_output.put_line(x_err_num || x_err_msg);
        RETURN -1;
END UPDATE_CLASSIFICATION_COUNT;



-- return value = 0 => bit is set.
-- return value <> 0 => bit is not set.

FUNCTION IS_BIT_SET (agent_id IN RAW, route_result IN RAW) RETURN NUMBER IS
short_raw RAW(2000);
short_len number;
BEGIN
--dbms_output.put_line('IS_BIT_SET' || 'agent_id= '
    --|| agent_id || 'route_result = ' || route_result);
if utl_raw.length(agent_id) > utl_raw.length(route_result)
then
    -- truncate agent_id to size of route result.
    short_len :=  utl_raw.length(route_result);
    short_raw := utl_raw.substr(agent_id,-short_len,short_len);
    return utl_raw.compare(utl_raw.bit_and(short_raw, route_result), short_raw);
else
    -- truncate route_result to size of agent_id
    short_len :=  utl_raw.length(agent_id);
    short_raw := utl_raw.substr(route_result,-short_len,short_len);
    --dbms_output.put_line('resutl ' || utl_raw.compare(utl_raw.bit_and(short_raw, agent_id), agent_id));
    return utl_raw.compare(utl_raw.bit_and(short_raw, agent_id), agent_id);
end if;

END IS_BIT_SET;



PROCEDURE RECEIVE_ITEM
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  VARCHAR2,
    p_app_id            IN  NUMBER,
    p_item_id           IN  NUMBER,
    p_item_type		    IN	NUMBER,
    p_classification    IN  VARCHAR2,
    p_kvp               IN  cct_keyvalue_varr,
    p_delay             IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'RECEIVE_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_return_status varchar2(256);
l_msg_count number;
l_msg_data varchar2(256);
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

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
     --dbms_output.put_line('RECEIVE_ITEM: pre insert data');
     insert into cct_qde_data (item_id,
        item_kvp,
        created_by, creation_date,
        last_updated_by, last_update_date, last_update_login)
     values (p_item_id,
        p_kvp,
        1, sysdate, 1, sysdate, 1);
     --dbms_output.put_line('RECEIVE_ITEM: post insert data');
     --dbms_output.put_line('RECEIVE_ITEM: pre insert rr');
     insert into cct_qde_route_result (item_id,
        item_type, classification, route_result,
        is_route_to_all, is_reroute, is_routed, start_time,
        created_by, creation_date,
        last_updated_by, last_update_date, last_update_login)
     values (p_item_id,
        p_item_type, p_classification, null,
        'N', 'N', 'N', sysdate,
        1, sysdate, 1, sysdate, 1);
     --dbms_output.put_line('RECEIVE_ITEM: post insert rr');
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- with release 9i, if delay is present then enqueue item to AQ with delay.

    -- Routing.enqueue.item.

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'RECEIVE_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --dbms_output.put_line('Unexpected error');
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'RECEIVE_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'RECEIVE_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END RECEIVE_ITEM;



PROCEDURE UPDATE_ROUTE_RESULT
(
    p_api_version     IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2,
	  p_commit	    	  IN  VARCHAR2,
  	p_item_id 		    IN 	NUMBER,
    p_item_type       IN NUMBER,
    p_classification  IN VARCHAR2,
    p_route_result    IN VARCHAR2,
    p_is_route_to_all IN VARCHAR2,
    p_is_reroute      IN VARCHAR2,
    p_kvp             IN  cct_keyvalue_varr,
 	  x_return_status		OUT NOCOPY	VARCHAR2,
	  x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'UPDATE_ROUTE_RESULT';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_item_id NUMBER;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
AGENT_NOT_FOUND EXCEPTION;
RESULT_NOT_FOUND EXCEPTION;
BIT_NOT_SET EXCEPTION;
RESOURCE_NOT_LOCKED EXCEPTION;
l_route_result VARCHAR2(2000);
l_agent_id number;
l_kvp cct_keyvalue_varr;
enqueue_options		dbms_aq.enqueue_options_t;
message_properties	dbms_aq.message_properties_t;
message_handle		RAW(16);
message			SYSTEM.cct_qde_response;

PRAGMA EXCEPTION_INIT(RESOURCE_NOT_LOCKED, -54);

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
	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;

	-- API body
    --dbms_output.put_line('UPDATE_ROUTE_RESULT: item_id = ' ||  p_item_id
        --|| ' item_type = ' ||   p_item_type
        --|| ' classification = ' || p_classification
        --|| ' p_route_result = ' || p_route_result
        --|| ' p_is_route_to_all = '  || p_is_route_to_all
        --|| ' p_is_reroute = ' || p_is_reroute);

    l_route_result := p_route_result;
    if ((p_is_route_to_all = 'Y') or (p_route_result is null)) then
        l_route_result := '0000';
    end if;

    update cct_qde_route_result
    set classification = p_classification,
        route_result = l_route_result,
        is_route_to_all = p_is_route_to_all,
        is_reroute = p_is_reroute,
        is_routed = 'Y'
    where item_id = p_item_id;

    update cct_qde_data
    set item_kvp = p_kvp
    where item_id = p_item_id;

    commit;
--  check if agent is available to process media item.

    declare cursor r1 is
    select agent_id, raw_agent_index, item_type, classification
        from cct_qde_agent_vw
        where (item_type = p_item_type)
            and ((classification is null) or (classification is not null
            and classification = p_classification))
            and (is_get_work = 1)
            and ((p_is_route_to_all = 'Y') or
                 ((p_is_route_to_all = 'N') and (is_bit_set(raw_agent_index, l_route_result) = 0)));

    begin
    --dbms_output.put_line('UPDATE_ROUTE_RESULT: post declare cursor');
  	for r1_rec in r1 loop
    begin
        SAVEPOINT GET_NEXT_AGENT_SAVEPOINT_2;
        --dbms_output.put_line('agent_id = '  || r1_rec.agent_id
            --|| ' item_type = ' || r1_rec.item_type
            --|| ' classification = ' ||  r1_rec.classification);
        --dbms_output.put_line('UPDATE_ROUTE_RESULT: pre lock agent');
        begin

          select agent_id into l_agent_id
          from cct_qde_agent
          where agent_id = r1_rec.agent_id and is_get_work = 1
          for update nowait;
        --dbms_output.put_line('UPDATE_ROUTE_RESULT: post lock agent');
        exception
        when NO_DATA_FOUND then
          raise AGENT_NOT_FOUND ;
        when RESOURCE_NOT_LOCKED then
          raise AGENT_NOT_FOUND;

        end;

        begin
        --dbms_output.put_line('UPDATE_ROUTE_RESULT: pre lock route result');
          select item_id into l_item_id
          from cct_qde_route_result
          where item_id = p_item_id
          for update NOWAIT;
        --dbms_output.put_line('UPDATE_ROUTE_RESULT: post lock route result');
        exception
        when NO_DATA_FOUND then
          raise RESULT_NOT_FOUND ;
        when RESOURCE_NOT_LOCKED then
          raise RESULT_NOT_FOUND ;

        end;

        select item_kvp into l_kvp from cct_qde_data
        where item_id = p_item_id;

        -- enqueue result.

        --dbms_output.put_line('Match found...');
        --dbms_output.put_line('Matched item_id = ' || p_item_id || ' , agent_id = ' || r1_rec. agent_id);

        delete from cct_qde_route_result where item_id = p_item_id;
        --dbms_output.put_line('UPDATE_ROUTE_RESULT: post delete route result');


        delete from cct_qde_data where item_id = p_item_id;

        update cct_qde_agent
        set is_get_work = 0, item_type = null, classification = null
        where agent_id = r1_rec.agent_id;

        -- TODO Handle what happens if dequeue returns failure.
        -- routing.stop reroute.


        message := SYSTEM.cct_qde_response(r1_rec.agent_id, p_item_id, p_item_type, p_classification, 172, l_kvp);
        message_properties.correlation := r1_rec.agent_id;
        dbms_aq.enqueue(queue_name => CCT_QDE_QUEUE.queue_name,
          enqueue_options => enqueue_options,
          message_properties => message_properties,
          payload => message,
          msgid 	=> message_handle);

        --dbms_output.put_line('UPDATE_ROUTE_RESULT: post dequeue result');
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
        exit;
    exception
        WHEN BIT_NOT_SET then
            -- try to find match with other route result.
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;
        WHEN AGENT_NOT_FOUND then
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;
        WHEN RESULT_NOT_FOUND then
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;
            exit;
        WHEN NO_DATA_FOUND then
            -- possible that agent request is already processed.
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;
        WHEN OTHERS then
            rollback to GET_NEXT_AGENT_SAVEPOINT_2;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
    end;
    end loop;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    end;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END UPDATE_ROUTE_RESULT;


PROCEDURE GET_NEXT_ITEM
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	  p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
    p_classification IN VARCHAR2,
 	  x_return_status	OUT NOCOPY	VARCHAR2,
	  x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_app_id        OUT NOCOPY NUMBER,
    x_item_id OUT NOCOPY NUMBER,
    x_item_type	OUT NOCOPY	NUMBER,
    x_classification OUT NOCOPY  VARCHAR2,
    x_kvp     OUT NOCOPY cct_keyvalue_varr
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_NEXT_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
AGENT_NOT_FOUND  EXCEPTION;
RESULT_NOT_FOUND EXCEPTION;
BIT_NOT_SET EXCEPTION;
RESOURCE_NOT_LOCKED EXCEPTION;
l_raw_agent_index RAW(2000);
l_agent_id number;
l_return_status varchar2(256);
l_msg_count number;
l_msg_data varchar2(256);
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

PRAGMA EXCEPTION_INIT(RESOURCE_NOT_LOCKED, -54);


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
    SAVEPOINT GET_NEXT_ITEM_SAVEPOINT_1;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;
    x_item_id := -1;
    x_item_type := -1;
    x_classification := null;
    x_kvp := cct_keyvalue_varr();

  	-- API body

    --dbms_output.put_line('GET_NEXT_ITEM: agent_id = ' ||  p_agent_id
        --|| ' item_type = ' ||   p_item_type
        --|| ' classification = ' || p_classification);


    --dbms_output.put_line('GET_NEXT_ITEM: pre select raw_agent_id');

    select raw_agent_index into l_raw_agent_index from cct_qde_agent
    where agent_id = p_agent_id ;

    update cct_qde_agent
    set is_get_work = 1, item_type = p_item_type,
        classification = p_classification,
        gw_req_time = sysdate
    where agent_id = p_agent_id;

    commit;
    --dbms_output.put_line('GET_NEXT_ITEM: post select l_raw_agent_index= ' || l_raw_agent_index);
    -- $$$$ change no NO_DATA_FOUND
    declare cursor r1 is
    select item_id, item_type, classification, route_result, is_route_to_all
        from cct_qde_route_result_vw
        where (item_type = p_item_type)
            and ((p_classification is null) or (p_classification is not null
            and classification = p_classification))
            and ((is_route_to_all = 'Y') or
                 ((is_route_to_all = 'N') and (is_bit_set(l_raw_agent_index,route_result) = 0)));
    begin
    --dbms_output.put_line('GET_NEXT_ITEM: post declare cursor');
  	for r1_rec in r1 loop
    begin

        SAVEPOINT GET_NEXT_ITEM_SAVEPOINT_2;
        --dbms_output.put_line('item_id = '  || r1_rec.item_id
            --|| ' item_type = ' || r1_rec.item_type
            --|| ' classification = ' ||  r1_rec.classification
            --|| ' route_result = ' || r1_rec.route_result
            --|| ' is_route_to_all = ' || r1_rec.is_route_to_all);
        /*if r1_rec.is_route_to_all = 'N' then
            begin
                if is_bit_set(l_raw_agent_index,r1_rec.route_result) <> 0 then
                    raise BIT_NOT_SET;
                end if;
            end;
        end if;        */
        --dbms_output.put_line('GET_NEXT_ITEM: pre select route result');
        begin
          select agent_id into l_agent_id from cct_qde_agent
          where agent_id = p_agent_id
          for update nowait;
        exception
        when NO_DATA_FOUND then
          raise AGENT_NOT_FOUND ;
        when RESOURCE_NOT_LOCKED then
          raise AGENT_NOT_FOUND ;
        end;

        begin
          select item_id,item_type,classification
          into x_item_id, x_item_type, x_classification
          from cct_qde_route_result
          where item_id = r1_rec.item_id
          for update nowait;
        exception
        when NO_DATA_FOUND then
          raise RESULT_NOT_FOUND ;
        when RESOURCE_NOT_LOCKED
          then raise RESULT_NOT_FOUND ;
        end;

        --dbms_output.put_line('GET_NEXT_ITEM: post select route result');
        --- $$$$ change to N0_DATA_FOUND
        -- if sql%notfound then raise RESULT_NOT_FOUND;
        -- end if;
        --dbms_output.put_line('GET_NEXT_ITEM: pre delete route result');
        delete from cct_qde_route_result where item_id = r1_rec.item_id;
        --dbms_output.put_line('GET_NEXT_ITEM: post delete route result');
        select item_kvp into x_kvp from cct_qde_data
        where item_id = r1_rec.item_id;
        delete from cct_qde_data where item_id = r1_rec.item_id;

        update cct_qde_agent
        set is_get_work = 0, item_type = null, classification = null
        where agent_id = p_agent_id;

        -- TODO Handle what happens if dequeue returns failure.
        -- routing.stop reroute.
        --dbms_output.put_line('GET_NEXT_ITEM: post dequeue result');
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
        exit;
    exception
        WHEN BIT_NOT_SET then
            -- try to find match with other route result.
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;
        WHEN AGENT_NOT_FOUND then
            --possible that agent is assigned to some other media item as are result of a new route. exit.
            commit;
            exit;
        WHEN RESULT_NOT_FOUND then
            -- possible that route result was already assigned to an agent proceed to next media item.
            commit;
        WHEN OTHERS then
            rollback to GET_NEXT_ITEM_SAVEPOINT_2;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='GET_NEXT_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
    end;
    end loop;
    --dbms_output.put_line('GET_NEXT_ITEM: loop ended');
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    end;
EXCEPTION
    	WHEN NO_DATA_FOUND THEN
            -- return failure - agent not logged on.
            rollback to GET_NEXT_ITEM_SAVEPOINT_1;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='GET_NEXT_ITEM: CCT_NO_AGENT_FOUND'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            rollback to GET_NEXT_ITEM_SAVEPOINT_1;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='GET_NEXT_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            rollback to GET_NEXT_ITEM_SAVEPOINT_1;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='GET_NEXT_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback to GET_NEXT_ITEM_SAVEPOINT_1;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='GET_NEXT_ITEM: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END GET_NEXT_ITEM;



PROCEDURE UPDATE_AGENT_QUEUES
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    p_item_type    IN NUMBER,
 	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'UPDATE_AGENT_QUEUES';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
AGENT_NOT_FOUND  EXCEPTION;
BIT_NOT_SET EXCEPTION;
l_raw_agent_index RAW(2000);
l_curr_classification varchar2(1024);
l_prev_classification varchar2(1024);
l_prev_classification_count number;
l_any_classification_count number;
l_return_val number;
l_return_status varchar2(256);
l_msg_count number;
l_msg_data varchar2(256);
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
TYPE ClassifyArr IS VARRAY(9999) of VARCHAR2(2000);
l_clArr ClassifyArr := ClassifyArr();
l_found varchar2(256);
i number;

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

    SAVEPOINT UPDATE_QUEUE_COUNTS_SAVEPOINT;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;

	-- API body
    --dbms_output.put_line('UPDATE_AGENT_QUEUES: pre select raw_agent_id');
    select raw_agent_index into l_raw_agent_index from cct_qde_agent
    where agent_id = p_agent_id;
    --dbms_output.put_line('UPDATE_AGENT_QUEUES: post select raw_agent_id');
    --- $$$$
--    if sql%notfound then raise AGENT_NOT_FOUND;
--    end if;

    declare cursor r1 is
    select item_id, item_type, classification, route_result, is_route_to_all
        from cct_qde_route_result_vw
        where (item_type = p_item_type)
        order by classification;
    begin
    --dbms_output.put_line('UPDATE_AGENT_QUEUES: post declare cursor');
    l_curr_classification := null;
    l_prev_classification := null;
    l_prev_classification_count := 0;
    l_any_classification_count := 0;
  	for r1_rec in r1 loop
    begin
        --dbms_output.put_line('item_id = '  || r1_rec.item_id
                --|| ' item_type = ' || r1_rec.item_type
                --|| ' classification = ' ||  r1_rec.classification
                --|| ' route_result = ' || r1_rec.route_result
                --|| ' is_route_to_all = ' || r1_rec.is_route_to_all
                --|| ' l_any_classification_count = ' || l_any_classification_count);

        if r1_rec.is_route_to_all = 'N' then
            begin
                if is_bit_set(l_raw_agent_index,r1_rec.route_result) <> 0 then
                    raise BIT_NOT_SET;
                end if;
            end;
        end if;
        -- item routed to this agent.
        l_curr_classification := r1_rec.classification;
        if (l_prev_classification is null)
        then
            l_prev_classification := l_curr_classification;
        end if;
        if (l_curr_classification = l_prev_classification)
        then
            begin
                l_prev_classification_count := l_prev_classification_count + 1;
                l_any_classification_count := l_any_classification_count + 1;
            end;
        else
            -- new classification
            begin
            -- update prev classification and count to db.
            l_return_val := UPDATE_CLASSIFICATION_COUNT(FND_API.G_TRUE,
                p_agent_id, p_item_type, l_prev_classification, l_prev_classification_count);
            --dbms_output.put_line('update done');
            --dbms_output.put_line('update done');
            l_clArr.EXTEND;
            --dbms_output.put_line('update done');
            l_clArr(l_clArr.LAST) := l_prev_classification;
            --dbms_output.put_line('Added to classificationArray' || l_prev_classification);
            l_prev_classification_count :=0;
            l_prev_classification := l_curr_classification;
            l_prev_classification_count := l_prev_classification_count +1;
            l_any_classification_count := l_any_classification_count + 1;
            end;
        end if;
    exception
        WHEN BIT_NOT_SET then
            -- try to find match with other route result.
            null;
        WHEN OTHERS then
            rollback to UPDATE_QUEUE_COUNTS_SAVEPOINT;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            --dbms_output.put_line(x_err_num || x_err_msg);
    end;
    end loop;
    --dbms_output.put_line('UPDATE_AGENT_QUEUES: loop ended');
    --dbms_output.put_line(' l_prev_classification ' || l_prev_classification);
    --dbms_output.put_line(' l_prev_classification_count ' || l_prev_classification_count);
    --dbms_output.put_line(' l_any_classification_count ' || l_any_classification_count);
    if ((l_prev_classification is not null) and (l_prev_classification_count <> 0))
    then
        l_return_val := UPDATE_CLASSIFICATION_COUNT(FND_API.G_TRUE, p_agent_id,
            p_item_type,l_prev_classification, l_prev_classification_count);
        l_clArr.EXTEND;
        l_clArr(l_clArr.LAST) := l_prev_classification;
        --dbms_output.put_line('Added to classificationArray' || l_prev_classification);
    end if;
    --dbms_output.put_line('l_clArr.LAST = ' || l_clArr.LAST);
    l_return_val := UPDATE_CLASSIFICATION_COUNT(FND_API.G_TRUE, p_agent_id,
        p_item_type,null, l_any_classification_count);

-- remove old classifications that are no longer valid.


    declare cursor r2 is
    select agent_queue_id , classification
        from cct_qde_agent_queues
        where (item_type = CCT_MEDIA_TYPES_PUB.GET_UWQ_MEDIA_TYPE_ID(p_item_type))
        and classification is not null
        and agent_id = p_agent_id ;
    begin
        for r2_rec in r2 loop
        begin
            --dbms_output.put_line('Processing classification' || r2_rec.classification);
            l_found := 'false';
            if (l_clArr.FIRST is not null) and (l_clArr.LAST is not null)
            then
                FOR i IN l_clArr.FIRST..l_clArr.LAST LOOP
                begin
                    if r2_rec.classification = l_clArr(i)
                    then
                        l_found := 'true';
                        exit;
                    end if;
                end;
                end loop;
            end if;
            if l_found = 'false'
            then
            begin
                --dbms_output.put_line('Deleting classification' || r2_rec.classification);
                delete from cct_qde_agent_queues
                where agent_queue_id = r2_rec.agent_queue_id;
                IF FND_API.To_Boolean( p_commit ) THEN
                    COMMIT WORK;
                END IF;
            end;
            end if;
        end;
        end loop;
    end;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    end;
EXCEPTION
--    	WHEN AGENT_NOT_FOUND THEN
    	WHEN NO_DATA_FOUND THEN
            -- return failure - agent not logged on.

            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_AGENT_QUEUES: CCT_NO_AGENT_FOUND'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
            rollback to UPDATE_QUEUE_COUNTS_SAVEPOINT;
        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_AGENT_QUEUES: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
            rollback to UPDATE_QUEUE_COUNTS_SAVEPOINT;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_AGENT_QUEUES: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
            rollback to UPDATE_QUEUE_COUNTS_SAVEPOINT;
        WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_AGENT_QUEUES: CCT_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
            rollback to UPDATE_QUEUE_COUNTS_SAVEPOINT;
END UPDATE_AGENT_QUEUES;


PROCEDURE CREATE_AGENT_INDEX
(
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
    x_agent_index   OUT NOCOPY NUMBER,
    x_raw_agent_index OUT NOCOPY RAW
)
IS
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_max_agent_index number;
l_hex_agent_index varchar2(2000);
BEGIN
    --dbms_output.put_line('CREATE_AGENT_INDEX:'
        --|| ' agent_id = ' || p_agent_id);
    lock table cct_qde_agent_global_lock in exclusive mode;
    select max(agent_index) into l_max_agent_index
    from cct_qde_agent;
    if (l_max_agent_index is null) then
        l_max_agent_index := -1;
    end if;
    x_agent_index := l_max_agent_index + 1;
    --dbms_output.put_line('x_agent_index := ' || x_agent_index);
    l_hex_agent_index := CCT_HEX_UTIL_PUB.dec_to_hex(x_agent_index);
    --dbms_output.put_line('l_hex_agent_index := '||l_hex_agent_index );
    x_raw_agent_index := hextoraw(l_hex_agent_index);
    --dbms_output.put_line('x_raw_agent_index :=' || x_raw_agent_index);
    insert into cct_qde_agent
    (   agent_id, agent_index, raw_agent_index,
        created_by, creation_date,
        last_updated_by, last_update_date, last_update_login
    )
    values
    (
        p_agent_id, x_agent_index, x_raw_agent_index,
        1, sysdate, 1, sysdate, 1
    );
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        rollback;
        x_err_num := SQLCODE;
        x_err_msg := SUBSTR(SQLERRM, 1, 100);
        --dbms_output.put_line(x_err_num || x_err_msg);
END CREATE_AGENT_INDEX;


PROCEDURE GET_AGENT_INDEX
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
	p_commit	    IN  VARCHAR2,
  	p_agent_id 		IN 	NUMBER,
 	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_agent_index   OUT NOCOPY NUMBER,
    x_raw_agent_index OUT NOCOPY RAW
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_AGENT_INDEX';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_item_type number;
BEGIN
    --dbms_output.put_line('GET_AGENT_INDEX:'
        --|| ' agent_id = ' || p_agent_id);

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
    SAVEPOINT GET_AGENT_INDEX_SP;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;

    select agent_index, raw_agent_index
    into x_agent_index, x_raw_agent_index from cct_qde_agent
    where agent_id = p_agent_id;
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND then
        create_agent_index(p_commit,p_agent_id,x_agent_index,x_raw_agent_index);
    WHEN OTHERS THEN
        rollback;
        x_err_num := SQLCODE;
        x_err_msg := SUBSTR(SQLERRM, 1, 100);
        --dbms_output.put_line(x_err_num || x_err_msg);
END GET_AGENT_INDEX;




END CCT_QDE_PUB;

/
