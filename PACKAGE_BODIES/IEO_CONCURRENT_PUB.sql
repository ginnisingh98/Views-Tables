--------------------------------------------------------
--  DDL for Package Body IEO_CONCURRENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_CONCURRENT_PUB" as
/* $Header: ieopconb.pls 120.0 2005/06/02 10:55:14 appldev noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEO_CONCURRENT_PUB';


PROCEDURE START_PROCESS(
                       ERRBUF   OUT NOCOPY     VARCHAR2,
                       RETCODE  OUT NOCOPY     VARCHAR2,
                       p_repeat_interval IN NUMBER
                       )
IS
    l_submit_request_id         NUMBER;
    l_is_repeat_options_set     BOOLEAN;
    error_msg		      VARCHAR2(256);
    l_return_value	      BOOLEAN;
    REPEAT_OPTIONS_NOT_SET    EXCEPTION;
    REQUEST_NOT_SUBMITTED      EXCEPTION;

BEGIN

    -- dbms_output.put_line('Starting Processing');
    fnd_file.put_line(fnd_file.log, 'Starting Processing');
    fnd_file.put_line(fnd_file.log, 'p_repeat_interval = ' || to_char(p_repeat_interval));
    l_is_repeat_options_set := fnd_request.set_repeat_options(
    					repeat_interval => p_repeat_interval,
    					repeat_unit => 'MINUTES',
    					repeat_type => 'START');
    if not l_is_repeat_options_set then
    	rollback;
        raise REPEAT_OPTIONS_NOT_SET;
    end if;

    -- dbms_output.put_line('Repeat interval is set');

    l_submit_request_id := fnd_request.submit_request(
    			application=>'IEO',
    			program => 'IEO_CHECK_SERVERS',
    			description => 'Starts the Failover monitoring process');

    fnd_file.put_line(fnd_file.log, 'Request Id ' || to_char(l_submit_request_id));
    -- dbms_output.put_line('Request Id ' || to_char(l_submit_request_id));

    if l_submit_request_id = 0 then
    	rollback;
        raise REQUEST_NOT_SUBMITTED;
    else
    	commit;
    end if;
    fnd_file.put_line(fnd_file.log, 'Controller Exited');
    -- dbms_output.put_line('Controller Exited');

EXCEPTION
        WHEN REPEAT_OPTIONS_NOT_SET THEN
        FND_MESSAGE.SET_NAME('IEO','IEO_FO_REPEAT_OPTIONS_NOT_SET');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);

        WHEN REQUEST_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEO','IEO_FO_REQUEST_NOT_SUBMITTED');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);

        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IEO','IEO_FO_UNEXPECTED');
        error_msg := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, error_msg);
        l_return_value := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', error_msg);
END START_PROCESS;



PROCEDURE IEO_CHECK_RESTART_SERVERS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'IEO_CHECK_RESTART_SERVERS';
l_api_version           	CONSTANT NUMBER := 1.0;

l_server_id NUMBER;

l_msg_count NUMBER;
l_submit_request_id         NUMBER;
REQUEST_NOT_SUBMITTED      EXCEPTION;

error_msg		      VARCHAR2(256);
p_api_version NUMBER;
p_init_msg_list VARCHAR2(256);
p_commit VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint

	fnd_file.put_line(fnd_file.log, 'Check and Restart Worker Program Started 1');
    p_api_version := 1.0;
    p_init_msg_list := FND_API.G_FALSE;
    p_commit := FND_API.G_TRUE;


    SAVEPOINT	IEO_CHECK_RESTART_SERVERS_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 			        l_api_name,
		    	    	    	    	G_PKG_NAME)

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


	fnd_file.put_line(fnd_file.log, 'Worker Program Started 2');
	-- dbms_output.put_line('Worker Program Started 2');

	declare cursor c1 is
	select server_id, status, trunc((sysdate-last_update_date)*24*60*60) diff1
	from ieo_svr_rt_info
	where ABS(status) >= 4;

	begin
	fnd_file.put_line(fnd_file.log,'Cursor declared');
    -- dbms_output.put_line('Cursor declared');

	for c1_rec in c1 loop
    begin
		fnd_file.put_line(fnd_file.log,'Processing server id ' || c1_rec.server_id);
	    -- dbms_output.put_line('Processing server id ' || c1_rec.server_id);

		if c1_rec.diff1 > 70 then
        begin

          -- insert new fnd request here
          l_submit_request_id := fnd_request.submit_request(
        			application=>'IEO',
        			program => 'IEO_PING_AND_RESTART_SVR',
        			description => 'Ping and restart one IC Java Server',
        			argument1 => c1_rec.server_id);

          fnd_file.put_line(fnd_file.log, 'Request Id ' || to_char(l_submit_request_id));
	      -- dbms_output.put_line('Ping and check server, Request Id ' || to_char(l_submit_request_id));

          if l_submit_request_id = 0 then
          	  rollback;
              raise REQUEST_NOT_SUBMITTED;
          else
        	  commit;
          end if;

          fnd_file.put_line(fnd_file.log, 'Controller Exited');
          -- dbms_output.put_line('Controller Exited for server '||c1_rec.server_id);

        end;
        end if;
    end;
    end loop;
	end;

	fnd_file.put_line(fnd_file.log, 'Worker Program Ended ');
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
		ROLLBACK TO IEO_CHECK_RESTART_SERVERS_PUB;
		RETCODE := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO IEO_CHECK_RESTART_SERVERS_PUB;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
    WHEN REQUEST_NOT_SUBMITTED THEN
    FND_MESSAGE.SET_NAME('IEO','IEO_FO_REQUEST_NOT_SUBMITTED');
    error_msg := FND_MESSAGE.GET;
    fnd_file.put_line(fnd_file.log, error_msg);
	WHEN OTHERS THEN
		ROLLBACK TO IEO_CHECK_RESTART_SERVERS_PUB;
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

END IEO_CHECK_RESTART_SERVERS;


PROCEDURE IEO_PING_AND_RESTART_SERVER
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2,
 	SERVER_ID               IN               NUMBER
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'IEO_PING_AND_RESTART_SERVER';
l_api_version           	CONSTANT NUMBER := 1.0;

l_server_id NUMBER;
l_server_name VARCHAR2(256);
l_node_id NUMBER;
l_node_status NUMBER;

diff2 NUMBER;

l_result VARCHAR2 (256);
l_return_status VARCHAR2(256);
l_msg_count NUMBER;
l_msg_data VARCHAR2(256);
l_xml_data VARCHAR2(256);

p_api_version NUMBER;
p_init_msg_list VARCHAR2(256);
p_commit VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint

	fnd_file.put_line(fnd_file.log, 'PING and Restart Worker Program Started 1');
    p_api_version := 1.0;
    p_init_msg_list := FND_API.G_FALSE;
    p_commit := FND_API.G_TRUE;


    SAVEPOINT	IEO_PING_RESTART_SVR_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 			        l_api_name,
		    	    	    	    	G_PKG_NAME)

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

          -- heartbeat time is not updated
          -- send one command through AQ
          l_server_id := SERVER_ID;

   	      fnd_file.put_line(fnd_file.log, 'Execute Server Cmd:');
  	      -- dbms_output.put_line('Execute Server Cmd'||SERVER_ID);

          IEO_ICSM_CMD_PUB.EXECUTE_SERVER_CMD(
          p_api_version => 1.0 ,
          p_cmd => 'STATUS' ,
          p_server_id => l_server_id ,
          x_result => l_result ,
          x_return_status => l_return_status ,
          x_msg_count => l_msg_count ,
          x_msg_data => l_msg_data );

    	  fnd_file.put_line(fnd_file.log,'x_result is ' || l_result);
		  fnd_file.put_line(fnd_file.log,'x_return_status is ' || l_return_status);
		  fnd_file.put_line(fnd_file.log,'x_msg_count is ' || l_msg_count);
		  fnd_file.put_line(fnd_file.log,'x_msg_data is ' || l_msg_data);

    	  -- dbms_output.put_line('Done with EXECUTE_SERVER_CMD... here is the result:');
    	  -- dbms_output.put_line('x_result is ' || l_result);
		  -- dbms_output.put_line('x_return_status is ' || l_return_status);
		  -- dbms_output.put_line('x_msg_count is ' || l_msg_count);
		  -- dbms_output.put_line('x_msg_data is ' || l_msg_data);

          if l_return_status = 'TIMEOUT' then
          begin
            -- failed to contact server, need to restart
  		    -- dbms_output.put_line('Failed to contact server, try restart ... ');

            declare cursor c2 is
            select node_id, priority
            from ieo_svr_node_assignments
            where server_id = l_server_id
            order by priority;

            begin
          	  for c2_rec in c2 loop
    		  begin
    		    fnd_file.put_line(fnd_file.log,'Checking this node id ' || c2_rec.node_id);
  	            -- dbms_output.put_line('Checking this node id ' || c2_rec.node_id);

                l_node_id := c2_rec.node_id;

                select status into l_node_status
                from ieo_nodes
                where node_id = l_node_id;

    		    if (l_node_status = 1) then
    		    -- node is up
    		    begin
                  select trunc((sysdate-last_update_date)*24*60*60) into diff2
                  from ieo_nodes
                  where node_id = l_node_id;

     		      if (diff2<70) then
    		      -- node has heartbeat
    		      begin
    		        select server_name into l_server_name
    		        from ieo_svr_servers
    		        where server_id = l_server_id;

    		        -- invoke the start server command
  	                -- dbms_output.put_line('Send StartServer command to ICSM node'||l_node_id);
                      IEO_ICSM_CMD_PUB.START_SERVER(
                      p_api_version => 1.0 ,
                      p_server_name => l_server_name ,
                      p_node_id => l_node_id ,
                      x_return_status => l_return_status ,
                      x_msg_count => l_msg_count ,
                      x_msg_data => l_msg_data,
                      x_xml_data => l_xml_data);

                      return;
    		      end;
    		      end if;
    		    end;
		        end if;
    		  end;
              end loop;
            end;
          end;
          end if;

	fnd_file.put_line(fnd_file.log, 'Worker Program Ended ');
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
		ROLLBACK TO IEO_PING_RESTART_SVR_PUB;
		RETCODE := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO IEO_CHECK_RESTART_SERVERS_PUB;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      l_msg_count     	,
        		p_data          	=>      ERRBUF
    		);
	WHEN OTHERS THEN
		ROLLBACK TO IEO_CHECK_RESTART_SERVERS_PUB;
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

END IEO_PING_AND_RESTART_SERVER;



END IEO_CONCURRENT_PUB;


/
