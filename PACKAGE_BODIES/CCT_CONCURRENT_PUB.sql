--------------------------------------------------------
--  DDL for Package Body CCT_CONCURRENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CONCURRENT_PUB" as
/* $Header: cctpconb.pls 115.22 2004/05/26 17:57:22 svinamda noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='CCT_CONCURRENT_PUB';


PROCEDURE START_PROCESS(
                       ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_close_interval IN NUMBER

                       )
IS
    l_submit_request_id         NUMBER;
    l_is_repeat_options_set     BOOLEAN;
    error_msg		      VARCHAR2(256);
    l_return_value	      BOOLEAN;
    REPEAT_OPTIONS_NOT_SET    EXCEPTION;
    REQUEST_NOT_SUBMITTED      EXCEPTION;

BEGIN

    -- fnd_file.put_line(fnd_file.log, 'Starting Processing');
    -- fnd_file.put_line(fnd_file.log, 'p_close_interval = ' || to_char(p_close_interval));
    l_is_repeat_options_set := fnd_request.set_repeat_options(
    					repeat_interval => p_close_interval,
    					repeat_unit => 'MINUTES',
    					repeat_type => 'START');
    if not l_is_repeat_options_set then
    	rollback;
        raise REPEAT_OPTIONS_NOT_SET;
    end if;

    l_submit_request_id := fnd_request.submit_request(
    			application=>'CCT',
    			program => 'CCT_CLOSE_MEDIA_ITEMS',
    			description => 'Concurrent program to close IH media items');

    -- fnd_file.put_line(fnd_file.log, 'Request Id ' || to_char(l_submit_request_id));

    if l_submit_request_id = 0 then
    	rollback;
        raise REQUEST_NOT_SUBMITTED;
    else
    	commit;
    end if;
    -- fnd_file.put_line(fnd_file.log, 'Controller Exited');

EXCEPTION
        WHEN REPEAT_OPTIONS_NOT_SET THEN
        FND_MESSAGE.SET_NAME('CCT','CCT_IH_REPEAT_OPTIONS_NOT_SET');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);

        WHEN REQUEST_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('CCT','CCT_IH_REQUEST_NOT_SUBMITTED');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);

        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('CCT','CCT_UNEXPECTED');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);
END START_PROCESS;



PROCEDURE CLOSE_MEDIA_ITEMS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'CLOSE_MEDIA_ITEMS';
l_api_version           	CONSTANT NUMBER := 1.0;

l_return_status VARCHAR2(256);
l_msg_count NUMBER;
l_msg_data VARCHAR2(256);
l_duration NUMBER;
l_milcs_duration NUMBER;
l_unclosed_wa_lc_segs NUMBER;
l_total_wa_lc_segs NUMBER;
l_end_date_time DATE;
l_start_date_time DATE Default null;
l_in_queue_start_date_time DATE Default null;
media_item_at_route_point_ex EXCEPTION;
no_data_found_ex EXCEPTION;
p_api_version NUMBER;
p_init_msg_list VARCHAR2(256);
p_commit VARCHAR2(256);

 BEGIN
	-- Standard Start of API savepoint

	-- fnd_file.put_line(fnd_file.log, 'Worker Program Started 1');
    p_api_version := 1.0;
    p_init_msg_list := FND_API.G_FALSE;
    p_commit := FND_API.G_TRUE;


    SAVEPOINT	CLOSE_MEDIA_ITEMS_PUB;
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
    	RETCODE := FND_API.G_RET_STS_SUCCESS;
	-- API body


	-- fnd_file.put_line(fnd_file.log, 'Worker Program Started 2');
	-- dbms_output.put_line('Worker Program Started 2');

	declare cursor c1 is
	select a.media_item_id, a.last_update_date, a.status, a.classification, a.attribute1, a.attribute2, b.start_date_time
	from cct_media_items a, jtf_ih_media_items b
	where a.media_type <> 1 and a.media_item_id = b.media_id and b.active = 'Y';

	begin
	-- fnd_file.put_line(fnd_file.log,'Cursor declared');
    -- dbms_output.put_line('Cursor declared');
	for c1_rec in c1 loop

		begin
		-- fnd_file.put_line(fnd_file.log,'Processing media item id ' || c1_rec.media_item_id);
	  -- dbms_output.put_line('Processing media item id ' || c1_rec.media_item_id);
		if c1_rec.attribute2 = 'Y' then
    begin
      -- call was abandoned.
      -- if routing milcs segment exists and is open close it.
      -- if inqueue milcs segment exists and is open close it.
      l_end_date_time := c1_rec.last_update_date;
      -- fnd_file.put_line(fnd_file.log,'Media item id is abandoned ' || c1_rec.media_item_id);
      -- dbms_output.put_line('Media item id is abandoned ' || c1_rec.media_item_id);
      declare cursor c2 is
      select milcs_id, start_date_time from jtf_ih_media_item_lc_segs where active = 'Y'
        and media_id = c1_rec.media_item_id;
      begin
      for c2_rec in c2 loop
      begin
    	l_milcs_duration := l_end_date_time - c2_rec.start_date_time;

        JTF_IH_PUB_W.Update_MediaLifecycle
        (p_api_version=>1.0
        ,p_init_msg_list=>FND_API.G_FALSE
        ,p_commit=>FND_API.G_TRUE
        ,p_resp_appl_id=>1 	-- IN  RESP APPL ID
        ,p_resp_id=>1  		-- IN  RESP ID
        ,p_user_id=>FND_GLOBAL.USER_ID -- IN  USER ID
        ,p_login_id=>NULL	-- IN  LOGIN ID
        ,p10_a3=>l_milcs_duration	-- IN duration
        ,p10_a4=>l_end_date_time		-- IN end date time
        ,p10_a5=>c2_rec.milcs_id		-- IN milcs id
        ,p10_a7=>c1_rec.media_item_id	-- IN media id
        ,p10_a8=>CCT_IH_PUB.G_IH_CCT_HANDLER_ID		-- IN handler id
        ,x_return_status=>l_return_status
        ,x_msg_count=>l_msg_count
        ,x_msg_data=>l_msg_data );

        exception
        when others then
        begin
          null;
          -- fnd_file.put_line(fnd_file.log,'Others exception for abandoned media item ');
        end;
      end ;
      end loop;
      end;
    end;
		else
    begin
     -- dbms_output.put_line('Media item id is NOT abandoned ' || c1_rec.media_item_id);

      select count(*) into l_unclosed_wa_lc_segs from jtf_ih_media_item_lc_segs c
        where c.end_date_time is null
        and c.media_id = c1_rec.media_item_id
        and c.milcs_type_id = CCT_IH_PUB.G_IH_LCS_TYPE_WITH_AGENT;

      select count(*) into l_total_wa_lc_segs from jtf_ih_media_item_lc_segs c
        where c.media_id = c1_rec.media_item_id
        and c.milcs_type_id = CCT_IH_PUB.G_IH_LCS_TYPE_WITH_AGENT;

      if ((l_unclosed_wa_lc_segs > 0 ) or (l_total_wa_lc_segs = 0)) then raise no_data_found_ex;
      end if;

      select max(c.end_date_time) into l_end_date_time from jtf_ih_media_item_lc_segs c
      where c.media_id = c1_rec.media_item_id and c.milcs_type_id = CCT_IH_PUB.G_IH_LCS_TYPE_WITH_AGENT;

--      if sql%notfound then raise no_data_found_ex;
--      end if;
      if l_end_date_time is null then raise no_data_found_ex;
      end if;

      select max(c.start_date_time) into l_start_date_time from jtf_ih_media_item_lc_segs c
      where c.media_id = c1_rec.media_item_id and c.milcs_type_id = CCT_IH_PUB.G_IH_LCS_TYPE_WITH_AGENT;

      l_in_queue_start_date_time := null;

      select max(c.start_date_time) into l_in_queue_start_date_time from jtf_ih_media_item_lc_segs c
      where c.media_id = c1_rec.media_item_id and c.milcs_type_id = CCT_IH_PUB.G_IH_LCS_TYPE_IN_QUEUE;

--      if sql%notfound then null;
--      end if;
      if (l_in_queue_start_date_time is not null) and
        (l_start_date_time is not null) and
        (l_start_date_time < l_in_queue_start_date_time)
      then raise media_item_at_route_point_ex;
       -- dbms_output.put_line('media item id transferred');
      end if;

    end;
    end if;
		-- fnd_file.put_line(fnd_file.log,'l_end_date_time' || to_char(l_end_date_time));
		-- dbms_output.put_line('l_end_date_time' || to_char(l_end_date_time));

		l_duration := l_end_date_time - c1_rec.start_date_time;
        l_duration := round(24*60*60*l_duration);

		-- fnd_file.put_line(fnd_file.log,'l_duration' || to_char(l_duration));
		-- dbms_output.put_line('l_duration' || to_char(l_duration));


		JTF_IH_PUB_W.CLOSE_MEDIAITEM
    	 	(p_api_version=>1.0         -- IN  api version
    	 	,p_init_msg_list=>p_init_msg_list       -- IN  init msg list
    	 	,p_commit=>p_commit              -- IN commit
    	 	,p_resp_appl_id=>1          -- IN resp appl id
    	 	,p_resp_id=>1               -- IN resp id
    	 	,p_user_id=>FND_GLOBAL.USER_ID      -- IN user id
    	 	,p_login_id=>NULL         --  IN login id
    	 	,p10_a0=>c1_rec.media_item_id              -- IN media_id
    	 	,p10_a3=>l_duration           -- IN duration
    	 	,p10_a4=>l_end_date_time              -- IN end_date_time
    	 	,p10_a17=>c1_rec.classification		 -- IN Classification
    	 	,p10_a12=>c1_rec.attribute2          -- IN media_abandon_flag
    	    ,p10_a13=>c1_rec.attribute1          -- IN media_transferred_flag
    	 	,x_return_status=>l_return_status
    	 	,x_msg_count=>l_msg_count
    	 	,x_msg_data=>l_msg_data );

    	-- fnd_file.put_line(fnd_file.log,'Closed mi');
    	-- dbms_output.put_line('Closed mi');

    	delete from cct_media_items where media_item_id = c1_rec.media_item_id;

        -- fnd_file.put_line(fnd_file.log,'deleted mi');
        -- dbms_output.put_line('deleted mi');
        exception
            when media_item_at_route_point_ex then
                begin
                  null;
                    -- fnd_file.put_line(fnd_file.log,'media item is at route point, cannot close.');
                    -- dbms_output.put_line('media item is at route point, cannot close.');
                end;
            when no_data_found_ex then
                begin
                  null;
                    -- fnd_file.put_line(fnd_file.log,'no data found for media item ');
                    -- dbms_output.put_line('no data found for media item ');
                end;
            when others then
                begin
                  null;
                    -- fnd_file.put_line(fnd_file.log,'Others exception for media item ');
                    -- dbms_output.put_line('Others exception for media item ');
                end;
        end;
	end loop;


    end;

	-- fnd_file.put_line(fnd_file.log, 'Worker Program Ended ');
	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    	);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CLOSE_MEDIA_ITEMS_PUB;
		RETCODE := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CLOSE_MEDIA_ITEMS_PUB;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN OTHERS THEN
		ROLLBACK TO CLOSE_MEDIA_ITEMS_PUB;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);

END CLOSE_MEDIA_ITEMS;




PROCEDURE TIMEOUT_PROCESS(
                       ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_timeout_interval IN NUMBER,
                       p_check_timeout_interval IN NUMBER
                       )
IS
    l_submit_request_id         NUMBER;
    l_is_repeat_options_set     BOOLEAN;
    error_msg		      VARCHAR2(256);
    l_return_value	      BOOLEAN;
    REPEAT_OPTIONS_NOT_SET    EXCEPTION;
    REQUEST_NOT_SUBMITTED      EXCEPTION;

BEGIN

    -- fnd_file.put_line(fnd_file.log, 'Starting TIMEOUT Processing');
    -- fnd_file.put_line(fnd_file.log, 'p_timeout_interval = ' || to_char(p_timeout_interval));
    -- fnd_file.put_line(fnd_file.log, 'p_check_timeout_interval = ' || to_char(p_check_timeout_interval));
    l_is_repeat_options_set := fnd_request.set_repeat_options(
    					repeat_interval => p_check_timeout_interval,
    					repeat_unit => 'HOURS',
    					repeat_type => 'START');
    if not l_is_repeat_options_set then
    	rollback;
        raise REPEAT_OPTIONS_NOT_SET;
    end if;

    l_submit_request_id := fnd_request.submit_request(
    			application=>'CCT',
    			program => 'CCT_TIMEOUT_MEDIA_ITEMS',
    			description => 'Concurrent program to timeout IH media items',
    			argument1 => '1.0',
    			argument2 => FND_API.G_FALSE,
    			argument3 => FND_API.G_TRUE,
    			argument4 => p_timeout_interval);

    -- fnd_file.put_line(fnd_file.log, 'Request Id ' || to_char(l_submit_request_id));

    if l_submit_request_id = 0 then
    	rollback;
        raise REQUEST_NOT_SUBMITTED;
    else
    	commit;
    end if;
    -- fnd_file.put_line(fnd_file.log, 'Timeout Controller Exited');

EXCEPTION
        WHEN REPEAT_OPTIONS_NOT_SET THEN
        FND_MESSAGE.SET_NAME('CCT','CCT_IH_REPEAT_OPTIONS_NOT_SET');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);

        WHEN REQUEST_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('CCT','CCT_IH_REQUEST_NOT_SUBMITTED');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);

        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('CCT','CCT_UNEXPTECTED');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);
END TIMEOUT_PROCESS;


PROCEDURE TIMEOUT_MEDIA_ITEMS_RS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2,
	p_timeout_in_hrs    IN NUMBER
)
IS
l_api_version           	CONSTANT NUMBER 		:= 1.0;
BEGIN
  TIMEOUT_MEDIA_ITEMS(
    ERRBUF,
    RETCODE,
    l_api_version,
    FND_API.G_FALSE,
    FND_API.G_FALSE,
    p_timeout_in_hrs
  );
END TIMEOUT_MEDIA_ITEMS_RS;


PROCEDURE TIMEOUT_MEDIA_ITEMS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2,
	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
	p_timeout_in_hrs    IN NUMBER
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'TIMEOUT_MEDIA_ITEMS';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_return_status VARCHAR2(256);
l_msg_count NUMBER;
l_msg_data VARCHAR2(256);
l_duration NUMBER;
l_milcs_duration NUMBER;
l_timeout_in_minutes NUMBER;
l_end_date_time DATE ;
l_max_milcs_end_date_time DATE;
l_max_milcs_start_date_time DATE;
l_classification VARCHAR2(256);
l_attribute1 VARCHAR2(150);
l_attribute2 VARCHAR2(150);

 BEGIN
	-- Standard Start of API savepoint

	-- fnd_file.put_line(fnd_file.log, 'Worker Program Started 1');

    SAVEPOINT	TIMEOUT_MEDIA_ITEMS_PUB;
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
    	RETCODE := FND_API.G_RET_STS_SUCCESS;
	-- API body


	-- fnd_file.put_line(fnd_file.log, 'Timeout Worker Program Started 2');
	---- dbms_output.put_line('Timeout Worker Program Started 2');

	l_timeout_in_minutes := 60*p_timeout_in_hrs;

	declare cursor c1 is
	select media_id, start_date_time from jtf_ih_media_items where active = 'Y' and media_id in
	(select media_item_id from cct_media_items where media_type <> 1 and status NOT IN (1,2))
	and start_date_time <= (sysdate - (l_timeout_in_minutes/1440));

	begin
	-- fnd_file.put_line(fnd_file.log,'Cursor declared');
    -- dbms_output.put_line('Cursor declared');
	for c1_rec in c1 loop

		begin
		-- fnd_file.put_line(fnd_file.log,'Processing media item id ' || c1_rec.media_id);
		-- dbms_output.put_line('Processing media item id ' || c1_rec.media_id);

        l_duration := 0;
        l_end_date_time := c1_rec.start_date_time;

		select max(c.end_date_time) into l_max_milcs_end_date_time from jtf_ih_media_item_lc_segs c
		where c.media_id = c1_rec.media_id;
        select max(c.start_date_time) into l_max_milcs_start_date_time from jtf_ih_media_item_lc_segs c
        where c.media_id = c1_rec.media_id;

        if (l_max_milcs_end_date_time is not null) then
            -- dbms_output.put_line('there is at least 1 lcs segment for this media item');
            if (l_max_milcs_end_date_time > l_max_milcs_start_date_time) then
                l_end_date_time := l_max_milcs_end_date_time;
            else
                -- dbms_output.put_line('more than 1 lcs segment, last lcs segement was never ended.');
                l_end_date_time := l_max_milcs_start_date_time;
            end if;

        else
            -- dbms_output.put_line(' no ended segment, check if there is unended lcs segment');
            if (l_max_milcs_start_date_time is not null) then
            -- dbms_output.put_line('at least 1 unended lcs segment.');
                l_end_date_time := l_max_milcs_start_date_time;
            end if;
        end if;

        -- fnd_file.put_line(fnd_file.log,'l_end_date_time' || to_char(l_end_date_time));

        -- dbms_output.put_line('l_end_date_time' || to_char(l_end_date_time));

        l_duration := l_end_date_time - c1_rec.start_date_time;
        l_duration := round(24*60*60*l_duration);

		-- dbms_output.put_line('Before classify');
		l_classification := 'unClassified';

		select classification, attribute1, attribute2 into l_classification, l_attribute1, l_attribute2 from cct_media_items where media_item_id = c1_rec.media_id;


		-- dbms_output.put_line('After classify');

		-- fnd_file.put_line(fnd_file.log,'l_duration' || to_char(l_duration));
		-- dbms_output.put_line('l_duration' || to_char(l_duration));
        declare cursor c2 is
            select milcs_id, start_date_time from jtf_ih_media_item_lc_segs where active = 'Y'
            and media_id = c1_rec.media_id;
        begin
            for c2_rec in c2 loop
            begin

                l_milcs_duration := l_end_date_time - c2_rec.start_date_time;
           		-- dbms_output.put_line('l_milcs_duration' || to_char(l_milcs_duration));
                JTF_IH_PUB_W.Update_MediaLifecycle
                (p_api_version=>1.0
                ,p_init_msg_list=>FND_API.G_FALSE
                ,p_commit=>FND_API.G_TRUE
                ,p_resp_appl_id=>1 	-- IN  RESP APPL ID
                ,p_resp_id=>1  		-- IN  RESP ID
                ,p_user_id=>FND_GLOBAL.USER_ID -- IN  USER ID
                ,p_login_id=>NULL	-- IN  LOGIN ID
                ,p10_a3=>l_milcs_duration	-- IN duration
                ,p10_a4=>l_end_date_time		-- IN end date time
                ,p10_a5=>c2_rec.milcs_id		-- IN milcs id
                ,p10_a7=>c1_rec.media_id	-- IN media id
                ,p10_a8=>CCT_IH_PUB.G_IH_CCT_HANDLER_ID		-- IN handler id
                ,x_return_status=>l_return_status
                ,x_msg_count=>l_msg_count
                ,x_msg_data=>l_msg_data );

            exception
                when others then
                begin
                  null;
                  -- fnd_file.put_line(fnd_file.log,'Others exception for abandoned media item ');
                end;
            end ;
            end loop;
        end;

		JTF_IH_PUB_W.CLOSE_MEDIAITEM
    	 	(p_api_version=>1.0         -- IN  api version
    	 	,p_init_msg_list=>p_init_msg_list       -- IN  init msg list
    	 	,p_commit=>p_commit              -- IN commit
    	 	,p_resp_appl_id=>1          -- IN resp appl id
    	 	,p_resp_id=>1               -- IN resp id
    	 	,p_user_id=>FND_GLOBAL.USER_ID      -- IN user id
    	 	,p_login_id=>NULL         --  IN login id
    	 	,p10_a0=>c1_rec.media_id              -- IN media_id
    	 	,p10_a3=>l_duration           -- IN duration
    	 	,p10_a4=>l_end_date_time              -- IN end_date_time
    	 	,p10_a17=>l_classification		 -- IN Classification
    	 	,p10_a12=>l_attribute2          -- IN media_abandon_flag
    	    ,p10_a13=>l_attribute1          -- IN media_transferred_flag
    	 	,x_return_status=>l_return_status
    	 	,x_msg_count=>l_msg_count
    	 	,x_msg_data=>l_msg_data );

    	-- fnd_file.put_line(fnd_file.log,'Closed mi');
    	-- dbms_output.put_line('Closed mi');
        delete from cct_media_items where media_item_id = c1_rec.media_id;
        -- fnd_file.put_line(fnd_file.log,'deleted mi');
        -- dbms_output.put_line('deleted mi');

        exception
            when others then
                begin
                  null;
                    -- fnd_file.put_line(fnd_file.log,'Others exception for media item ');
                    -- dbms_output.put_line('Others exception for media item ');
                end;
        end;
	end loop;

    -- force delete remainder media items that are in cct_media_items but are inactive in jtf_ih_media_items.

    delete from CCT_MEDIA_ITEMS where
    media_type <> 1 and status NOT IN (1,2) and creation_date <=  (sysdate - (l_timeout_in_minutes/1440)) ;

    end;

	-- fnd_file.put_line(fnd_file.log, 'Worker Program Ended ');
	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    	);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO TIMEOUT_MEDIA_ITEMS_PUB;
		RETCODE := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO TIMEOUT_MEDIA_ITEMS_PUB;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN OTHERS THEN
		ROLLBACK TO TIMEOUT_MEDIA_ITEMS_PUB;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);

END TIMEOUT_MEDIA_ITEMS;

END CCT_CONCURRENT_PUB;


/
