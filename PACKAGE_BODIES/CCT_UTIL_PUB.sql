--------------------------------------------------------
--  DDL for Package Body CCT_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_UTIL_PUB" AS
/* $Header: cctpub.pls 120.0 2005/06/02 09:20:42 appldev noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_UTIL_PUB';



PROCEDURE GET_MIDDLEWARE_ID
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  	VARCHAR2 ,
	p_agent_id IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2			,
	x_middleware_id OUT NOCOPY NUMBER
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_MIDDLEWARE_ID';
l_api_version           	CONSTANT NUMBER 		:= 1.0;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	GET_MIDDLEWARE_ID_PUB;
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
	-- API body

	x_middleware_id := -1;

    select middleware_id into x_middleware_id from cct_telesets where teleset_id =
    (select client_id from cct_agent_rt_stats where attribute1='T' and agent_id = p_agent_id);

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    	);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO GET_MIDDLEWARE_ID_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO GET_MIDDLEWARE_ID_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO GET_MIDDLEWARE_ID_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
END GET_MIDDLEWARE_ID;



PROCEDURE CLOSE_MILCS
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  	VARCHAR2,
	p_milcs_type_id IN NUMBER,
    p_media_item_id IN NUMBER,
    p_end_date_time IN DATE,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'CLOSE_MILCS';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_milcs_id NUMBER := -1;
l_start_date_time DATE ;
l_milcs_duration NUMBER;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	CLOSE_MILCS_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

   	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

	select milcs_id, start_date_time into l_milcs_id, l_start_date_time
    from jtf_ih_media_item_lc_segs
    where media_id = p_media_item_id and milcs_type_id = p_milcs_type_id
    and end_date_time is null;

	if sql%notfound then raise NO_DATA_FOUND;
  	end if;

    l_milcs_duration := p_end_date_time - l_start_date_time;
    l_milcs_duration := round(24*60*60*l_milcs_duration);

        JTF_IH_PUB_W.Update_MediaLifecycle
        (p_api_version=>1.0
        ,p_init_msg_list=>FND_API.G_FALSE
        ,p_commit=>FND_API.G_TRUE
        ,p_resp_appl_id=>1 	-- IN  RESP APPL ID
        ,p_resp_id=>1  		-- IN  RESP ID
        ,p_user_id=>FND_GLOBAL.USER_ID -- IN  USER ID
        ,p_login_id=>NULL	-- IN  LOGIN ID
        ,p10_a3=>l_milcs_duration	-- IN duration
        ,p10_a4=>p_end_date_time		-- IN end date time
        ,p10_a5=>l_milcs_id		-- IN milcs id
        ,p10_a7=>p_media_item_id	-- IN media id
        ,p10_a8=>CCT_IH_PUB.G_IH_CCT_HANDLER_ID		-- IN handler id
        ,x_return_status=>x_return_status
        ,x_msg_count=>x_msg_count
        ,x_msg_data=>x_msg_data );


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
      	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_NO_DATA_FOUND';
        x_msg_count := 1;
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CLOSE_MILCS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'CCT_UNEXPECTED_ERROR';
        x_msg_count := 1;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CLOSE_MILCS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'CCT_UNEXPECTED_ERROR';
        x_msg_count := 1;
    WHEN OTHERS THEN
		ROLLBACK TO CLOSE_MILCS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'CCT_UNEXPECTED_ERROR';
        x_msg_count := 1;
END CLOSE_MILCS;


-- return value = 0 => media item can be closed.
-- return value = 1 => media item cannot be closed.

PROCEDURE CAN_CLOSE_MEDIA_ITEM
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  	VARCHAR2,
    p_media_item_id IN NUMBER,
    x_can_close_media_item OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'CAN_CLOSE_MEDIA_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
IH_MILCS_TYPE_WITH_AGENT	CONSTANT NUMBER := 5;
IH_MILCS_TYPE_IN_QUEUE      CONSTANT NUMBER := 3;
l_end_date_time DATE;
l_start_date_time DATE Default null;
l_in_queue_start_date_time DATE Default null;
l_nwa_count NUMBER ;
media_item_at_route_point_ex EXCEPTION;
no_data_found_ex EXCEPTION;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	CAN_CLOSE_MEDIA_ITEM_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- API body

   	  -- dbms_output.put_line('Processing media item id ' || p_media_item_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_can_close_media_item := 1; -- initialize to cannot close.

      select max(c.end_date_time) into l_end_date_time from jtf_ih_media_item_lc_segs c
      where c.media_id = p_media_item_id and c.milcs_type_id = IH_MILCS_TYPE_WITH_AGENT;

    if l_end_date_time is null then raise NO_DATA_FOUND;
      end if;

      select count(*) into l_nwa_count from jtf_ih_media_item_lc_segs c
	 where c.media_id = p_media_item_id and c.milcs_type_id = IH_MILCS_TYPE_WITH_AGENT
	 and c.end_date_time IS NULL ;

    if ( l_nwa_count > 0 ) then raise NO_DATA_FOUND ;
	 end if;

      select max(c.start_date_time) into l_start_date_time from jtf_ih_media_item_lc_segs c
      where c.media_id = p_media_item_id and c.milcs_type_id = IH_MILCS_TYPE_WITH_AGENT;
      l_in_queue_start_date_time := null;
      select max(c.start_date_time) into l_in_queue_start_date_time from jtf_ih_media_item_lc_segs c
      where c.media_id = p_media_item_id and c.milcs_type_id = IH_MILCS_TYPE_IN_QUEUE;

      if (l_in_queue_start_date_time is not null) and
        (l_start_date_time is not null) and
        (l_start_date_time < l_in_queue_start_date_time)
      then raise media_item_at_route_point_ex;
       -- dbms_output.put_line('media item id transferred');
      end if;

      -- dbms_output.put_line('media item is a candidate for closure');
      x_can_close_media_item := 0;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
    WHEN media_item_at_route_point_ex then
        begin
            fnd_file.put_line(fnd_file.log,'media item is at route point, cannot close.');
            -- dbms_output.put_line('media item is at route point, cannot close.');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_MEDIA_ITEM_AT_ROUTE_POINT';
        x_msg_count := 1;
        end;
	WHEN NO_DATA_FOUND THEN
      	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 'CCT_NO_DATA_FOUND';
        x_msg_count := 1;
    WHEN OTHERS THEN
		ROLLBACK TO CAN_CLOSE_MEDIA_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'CCT_UNEXPECTED_ERROR';
        x_msg_count := 1;
END CAN_CLOSE_MEDIA_ITEM;



END CCT_UTIL_PUB;

/
