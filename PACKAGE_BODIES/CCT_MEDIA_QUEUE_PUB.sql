--------------------------------------------------------
--  DDL for Package Body CCT_MEDIA_QUEUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_MEDIA_QUEUE_PUB" AS
/* $Header: cctpmqb.pls 115.7 2002/12/06 01:06:44 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_MEDIA_QUEUE_PUB';



PROCEDURE UPDATE_DEQUEUE_COUNT
( 	p_api_version           IN	NUMBER ,
  	p_init_msg_list		IN	VARCHAR2 ,
	p_commit	    	IN  	VARCHAR2 ,
	p_root_svr_group_id IN NUMBER,
	p_media_type	IN 	NUMBER,
	p_dequeue_count IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count		OUT NOCOPY	NUMBER				,
	x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'UPDATE_DEQUEUE_COUNT';
l_api_version           	CONSTANT NUMBER 		:= 1.0;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	UPDATE_DEQUEUE_COUNT_PUB;
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


    update cct_media_type_dequeue_count
    set dequeue_count = p_dequeue_count
    where server_group_id = p_root_svr_group_id and media_type = p_media_type;

    IF sql%notfound THEN raise NO_DATA_FOUND;
  	END IF;


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

	WHEN NO_DATA_FOUND THEN

    insert into cct_media_type_dequeue_count
    ( media_type, dequeue_count, server_group_id, created_by, creation_date, last_updated_by, last_update_date, last_update_login )
    values (p_media_type, p_dequeue_count, p_root_svr_group_id, 1, sysdate, 1, sysdate, 1);

    IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;


    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_DEQUEUE_COUNT_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_DEQUEUE_COUNT_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_DEQUEUE_COUNT_PUB;
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
END UPDATE_DEQUEUE_COUNT;


PROCEDURE GET_MEDIA_QUEUE_DETAILS
(
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2 ,
    p_commit IN   VARCHAR2 ,
    p_media_item_id IN NUMBER ,  -- Required
    p_server_group_name IN VARCHAR2,   -- Required
    x_abs_pos_media_type OUT NOCOPY NUMBER,  -- absolute position of media item in the media type queue
    x_relative_pos_media_type OUT NOCOPY NUMBER, -- absolute position by media type / no of agents logged in for media type
    x_abs_pos_all_media_types OUT NOCOPY NUMBER, -- absolute position of media item for all media types
    x_relative_pos_all_media_types OUT NOCOPY NUMBER, -- absolute position of all media types / total # of agents logged in
    x_return_status OUT NOCOPY VARCHAR2 ,
    x_msg_count OUT NOCOPY NUMBER ,
    x_msg_data  OUT NOCOPY VARCHAR2
)

IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_MEDIA_QUEUE_DETAILS';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_media_type_any    CONSTANT NUMBER := 4 ;
l_root_server_group_id NUMBER;
l_root_server_group_name VARCHAR2(256);
MEDIA_ITEM_NOT_FOUND EXCEPTION;
l_queue_position_undefined EXCEPTION;
l_queue_seq_num_undefined EXCEPTION;
l_agents_media_type NUMBER := 0;
l_agents_any_media_type NUMBER := 0;
l_agents_all_media_types NUMBER :=0 ;
l_queue_position NUMBER := 0;
l_queue_seq_num NUMBER := 0;
l_dequeue_count NUMBER := 0;
l_dequeue_count_all_types NUMBER := 0;
l_media_type NUMBER := -1;

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	GET_MEDIA_QUEUE_DETAILS_PUB;
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


	CCT_AQ_PUB.get_root_group_name (
        p_api_version => 1.0,
        p_server_group_name => p_server_group_name,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        x_root_server_group_name => l_root_server_group_name
    );

	select server_group_id into l_root_server_group_id
	from ieo_svr_groups where group_name = l_root_server_group_name;

	-- determine media type for media item.

	select media_type into l_media_type
	from cct_media_items where media_item_id = p_media_item_id;

	IF sql%notfound THEN raise MEDIA_ITEM_NOT_FOUND;
  	END IF;


	x_abs_pos_media_type := 0;
	x_relative_pos_media_type := 0;
	x_abs_pos_all_media_types := 0;
	x_relative_pos_all_media_types := 0;

-- x_abs_pos_media_type = dequeue_count - queue_position

    select queue_position into l_queue_position from cct_media_items
    where media_item_id = p_media_item_id;

    IF (l_queue_position = 0) THEN
	    raise l_queue_position_undefined;
    END IF;


    select dequeue_count into l_dequeue_count from cct_media_type_dequeue_count
    where media_type = l_media_type  and server_group_id = l_root_server_group_id;

   IF ((l_queue_position - l_dequeue_count) > 0) THEN
    x_abs_pos_media_type := l_queue_position - l_dequeue_count;
   END IF;


   -- x_relative_pos_media_type ==  x_abs_pos_media_type / l_agents_media_type

   -- no of agents logged in for that media type

    select count(*) into l_agents_media_type
    from cct_agent_rt_stats where attribute11 = l_root_server_group_id
    and  attribute1 = 'T' and media_type = l_media_type ;

    select count(*) into l_agents_any_media_type
    from cct_agent_rt_stats where attribute11 = l_root_server_group_id
    and attribute1 = 'T' and media_type = l_media_type_any;


   IF (x_abs_pos_media_type > 0) THEN
        IF (l_agents_media_type > 0)  THEN
            x_relative_pos_media_type := CEIL (x_abs_pos_media_type / ((l_agents_any_media_type * 0.3333333) + l_agents_media_type));

        ELSE
            x_relative_pos_media_type := x_abs_pos_media_type;
        END IF;
   END IF;

-- x_abs_pos_all_media_types  = dequeue_count_all_media_types - queue_seq_num

   select queue_seq_num into l_queue_seq_num from cct_media_items
   where media_item_id = p_media_item_id;

   IF (l_queue_seq_num = 0) THEN
	    raise l_queue_seq_num_undefined;
   END IF;


   select sum(dequeue_count) into l_dequeue_count_all_types
   from cct_media_type_dequeue_count where server_group_id = l_root_server_group_id;

    IF ((l_queue_seq_num - l_dequeue_count_all_types) > 0 ) THEN
        x_abs_pos_all_media_types := l_queue_seq_num - l_dequeue_count_all_types;
    END IF;

-- x_relative_pos_all_media_types = x_abs_pos_all_media_types / l_agents_all_media_types

    select count(*) into l_agents_all_media_types from cct_agent_rt_stats
    where attribute1 = 'T' and attribute11= l_root_server_group_id;

    IF (x_abs_pos_all_media_types > 0) THEN
        IF (l_agents_all_media_types > 0) THEN
            x_relative_pos_all_media_types := CEIL (x_abs_pos_all_media_types / l_agents_all_media_types);
        ELSE
            x_relative_pos_all_media_types := x_abs_pos_all_media_types;
        END IF;
    END IF;


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

    WHEN MEDIA_ITEM_NOT_FOUND THEN
        ROLLBACK TO GET_MEDIA_QUEUE_DETAILS_PUB;
		FND_MESSAGE.SET_NAME('CCT','CCT_MEDIA_ITEM_NOT_FOUND');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;

    WHEN l_queue_position_undefined THEN
        ROLLBACK TO GET_MEDIA_QUEUE_DETAILS_PUB;
		FND_MESSAGE.SET_NAME('CCT','CCT_QUEUE_POSITION_UNDEFINED');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;


    WHEN l_queue_seq_num_undefined THEN
        ROLLBACK TO GET_MEDIA_QUEUE_DETAILS_PUB;
		FND_MESSAGE.SET_NAME('CCT','CCT_QUEUE_SEQ_NUM_UNDEFINED');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;


    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO GET_MEDIA_QUEUE_DETAILS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO GET_MEDIA_QUEUE_DETAILS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        			p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO GET_MEDIA_QUEUE_DETAILS_PUB;
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
END GET_MEDIA_QUEUE_DETAILS ;

END CCT_MEDIA_QUEUE_PUB;

/
