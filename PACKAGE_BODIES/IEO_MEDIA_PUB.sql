--------------------------------------------------------
--  DDL for Package Body IEO_MEDIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_MEDIA_PUB" AS
/* $Header: ieopmedb.pls 115.2 2004/03/19 20:20:50 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'IEO_MEDIA_PUB';



PROCEDURE UPDATE_DEVICE_MAP
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
  	p_commit	    	IN  VARCHAR2,
    p_server_group_id           IN  NUMBER,
    p_media_type          IN  VARCHAR2,
    p_device_type		    IN	VARCHAR2,
    p_device_id    IN  VARCHAR2,
    p_is_device_available IN VARCHAR2,
    p_server_id       IN NUMBER,
  	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
    x_msg_data		OUT NOCOPY	VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'UPDATE_DEVICE_MAP';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
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
     --dbms_output.put_line('UPDATE_DEVICE_MAP: pre update data');
     update ieo_media_rt_device_map
     set server_id = p_server_id, device_available = p_is_device_available
     where server_group_id = p_server_group_id and
      media_type = p_media_type and
      device_type = p_device_type and
      device_id = p_device_id;

    if sql%notfound then raise NO_DATA_FOUND;
    end if;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
        WHEN NO_DATA_FOUND then
            -- insert row
            --dbms_output.put_line('UPDATE_DEVICE_MAP:no data found');
            insert into ieo_media_rt_device_map
            (
              server_group_id, media_type,
              device_type, device_id,
              device_available, server_id,
              device_map_id,
              created_by, creation_date,
              last_updated_by, last_update_date, last_update_login
            )
            values
            (
              p_server_group_id, p_media_type,
              p_device_type, p_device_id,
              p_is_device_available, p_server_id,
              ieo_media_rt_device_map_s1.nextval,
              1, sysdate, 1, sysdate, 1
            );

            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'UPDATE_DEVICE_MAP: IEO_EXC_ERROR'
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
            x_msg_data := 'UPDATE_DEVICE_MAP: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'UPDATE_DEVICE_MAP: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END UPDATE_DEVICE_MAP;



PROCEDURE GET_DEVICE_LOCATION
(
  p_api_version           	IN	NUMBER,
  p_init_msg_list			IN	VARCHAR2,
  p_commit	    	IN  VARCHAR2,
  p_server_group_name 		IN 	VARCHAR2,
  p_media_type            IN VARCHAR2,
  p_device_type           IN VARCHAR2,
  p_device_id             IN VARCHAR2,
  x_return_status		OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  x_server_id   OUT NOCOPY  VARCHAR2,
  x_device_map_id OUT NOCOPY NUMBER
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_DEVICE_LOCATION';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_server_group_id NUMBER;

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
    x_server_id := null;
    x_device_map_id := -1;
	-- API body
    --dbms_output.put_line('GET_DEVICE_LOCATION: server_group_name = ' ||  p_server_group_name
        --|| ' media_type = ' ||   p_media_type
        --|| ' device_type = ' || p_device_type
        --|| ' device_id =  '|| p_device_id );

    x_msg_data := 'GET_DEVICE_LOCATION: server_group '
      || p_server_group_name || ' not found';
    x_msg_count := 1;

    select server_group_id into l_server_group_id
      from ieo_svr_groups where group_name = p_server_group_name;

    x_msg_data := 'GET_DEVICE_LOCATION: device not found '
        || ' media_type = ' ||   p_media_type
        || ' device_type = ' || p_device_type
        || ' device_id =  '|| p_device_id;
    x_msg_count := 1;

    select server_id, device_map_id into x_server_id, x_device_map_id
      from ieo_media_rt_device_map
      where server_group_id = l_server_group_id and
        media_type = p_media_type and
        device_type = p_device_type and
        device_id = p_device_id;

    x_msg_data := null;
    x_msg_count :=0;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;


EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
            END IF;

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='UPDATE_ROUTE_RESULT: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

END GET_DEVICE_LOCATION;


PROCEDURE LOCATE_LEAST_LOADED_IN_GROUP
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
  	p_commit	    IN  VARCHAR2,
  	p_server_group_name IN VARCHAR2,
    p_server_type_uuid   IN VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_server_id   OUT NOCOPY  VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'LOCATE_LEAST_LOADED_IN_GROUP';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_server_group_id NUMBER;
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

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_data := 'LOCATE_LEAST_LOADED_IN_GROUP: server_group '
      || p_server_group_name || ' not found';
    x_msg_count := 1;
    x_server_id := null;

    select server_group_id into l_server_group_id
      from ieo_svr_groups where group_name = p_server_group_name;

    x_msg_data := 'IEO_SVR_UTIL_PVT.LOCATE_LEAST_LOADED_IN_GROUP failed';

    IEO_SVR_UTIL_PVT.LOCATE_LEAST_LOADED_IN_GROUP
    (
      P_GROUP_ID => l_server_group_id,
      P_SERVER_TYPE_UUID => p_server_type_uuid,
      P_EXCLUDE_SERVER_ID => null,
      X_SERVER_ID => x_server_id,
      P_TIMEOUT_TOLERANCE => 0
    );

    x_msg_count :=0;
    x_msg_data := null;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
--    	WHEN AGENT_NOT_FOUND THEN
    	WHEN NO_DATA_FOUND THEN
            -- return failure - agent not logged on.
            rollback;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_LEAST_LOADED_IN_GROUP:'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_LEAST_LOADED_IN_GROUP: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_LEAST_LOADED_IN_GROUP: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_LEAST_LOADED_IN_GROUP: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END LOCATE_LEAST_LOADED_IN_GROUP;





PROCEDURE LOCATE_BY_MINOR_LOAD
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
  	p_commit	    IN  VARCHAR2,
  	p_server_group_name IN VARCHAR2,
    p_server_type_uuid   IN VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_server_id   OUT NOCOPY  VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'LOCATE_LEAST_LOADED_IN_GROUP';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_server_group_id NUMBER;
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

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_data := 'LOCATE_BY_MINOR_LOAD: server_group '
      || p_server_group_name || ' not found';
    x_msg_count := 1;
    x_server_id := null;

    select server_group_id into l_server_group_id
      from ieo_svr_groups where group_name = p_server_group_name;

    x_msg_data := 'IEO_SVR_UTIL_PVT.LOCATE_BY_MINOR_LOAD failed';

    IEO_SVR_UTIL_PVT.LOCATE_BY_MINOR_LOAD
    (
      P_GROUP_ID => l_server_group_id,
      P_SERVER_TYPE_UUID => p_server_type_uuid,
      P_EXCLUDE_SERVER_ID => null,
      X_SERVER_ID => x_server_id,
      P_TIMEOUT_TOLERANCE => 0
    );

    x_msg_count :=0;
    x_msg_data := null;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
--    	WHEN AGENT_NOT_FOUND THEN
    	WHEN NO_DATA_FOUND THEN
            -- return failure - agent not logged on.
            rollback;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MINOR_LOAD:'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MINOR_LOAD: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MINOR_LOAD: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MINOR_LOAD: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END LOCATE_BY_MINOR_LOAD;



PROCEDURE LOCATE_BY_MAJOR_LOAD
(
    p_api_version   IN	NUMBER,
  	p_init_msg_list	IN	VARCHAR2,
  	p_commit	    IN  VARCHAR2,
  	p_server_group_name IN VARCHAR2,
    p_server_type_uuid   IN VARCHAR2,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_server_id   OUT NOCOPY  VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'LOCATE_LEAST_LOADED_IN_GROUP';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
l_server_group_id NUMBER;
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

    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_data := 'LOCATE_BY_MAJOR_LOAD: server_group '
      || p_server_group_name || ' not found';
    x_msg_count := 1;
    x_server_id := null;

    select server_group_id into l_server_group_id
      from ieo_svr_groups where group_name = p_server_group_name;

    x_msg_data := 'IEO_SVR_UTIL_PVT.LOCATE_BY_MAJOR_LOAD failed';

    IEO_SVR_UTIL_PVT.LOCATE_BY_MAJOR_LOAD
    (
      P_GROUP_ID => l_server_group_id,
      P_SERVER_TYPE_UUID => p_server_type_uuid,
      P_EXCLUDE_SERVER_ID => null,
      X_SERVER_ID => x_server_id,
      P_TIMEOUT_TOLERANCE => 0
    );

    x_msg_count :=0;
    x_msg_data := null;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
EXCEPTION
--    	WHEN AGENT_NOT_FOUND THEN
    	WHEN NO_DATA_FOUND THEN
            -- return failure - agent not logged on.
            rollback;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MAJOR_LOAD:'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MAJOR_LOAD: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MAJOR_LOAD: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data :='LOCATE_BY_MAJOR_LOAD: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END LOCATE_BY_MAJOR_LOAD;




END IEO_MEDIA_PUB;

/
