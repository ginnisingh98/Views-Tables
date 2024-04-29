--------------------------------------------------------
--  DDL for Package Body CCT_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_IH_PUB" AS
/* $Header: cctpihb.pls 115.1 2003/02/19 02:29:40 svinamda noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_IH_PUB';


PROCEDURE OPEN_MEDIA_ITEM
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2,
	p_commit	    	IN  	VARCHAR2,
    p_app_id    IN  NUMBER,
    p_user_id           IN NUMBER,
    p_direction         IN VARCHAR2,
    p_start_date_time   IN DATE,
    p_source_item_create_date_time  IN DATE,
    p_media_item_type   IN VARCHAR2,
    p_server_group_id   IN NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
    x_media_id      OUT NOCOPY NUMBER

)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'OPEN_MEDIA_ITEM';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	OPEN_MEDIA_ITEM_PUB;
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
        x_msg_count := 0;
	-- API body
    JTF_IH_PUB_W.OPEN_MEDIAITEM
    	(p_api_version=> p_api_version,
    	p_init_msg_list=> p_init_msg_list,
    	p_commit=>p_commit,
    	p_resp_appl_id=>1,
    	p_resp_id=>1,
    	p_user_id=> p_user_id,
    	p_login_id=> null ,
    	p10_a2=> p_direction,
    	p10_a6=> p_start_date_time,
    	p10_a8=> p_source_item_create_date_time,
    	p10_a10=> p_media_item_type,
    	p10_a14=> p_server_group_id,
    	x_return_status=> x_return_status ,
    	x_msg_count=> x_msg_count,
    	x_msg_data=> x_msg_data,
    	x_media_id=> x_media_id );

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO OPEN_MEDIA_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_count := 1;
        x_err_num := SQLCODE;
        x_err_msg := SUBSTR(SQLERRM, 1, 100);
        x_msg_data := 'CCT_IH_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
        --dbms_output.put_line(x_msg_data);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO OPEN_MEDIA_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_count := 1;
        x_err_num := SQLCODE;
        x_err_msg := SUBSTR(SQLERRM, 1, 100);
        x_msg_data := 'CCT_IH_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
        --dbms_output.put_line(x_msg_data);
	WHEN OTHERS THEN
		ROLLBACK TO OPEN_MEDIA_ITEM_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_count := 1;
        x_err_num := SQLCODE;
        x_err_msg := SUBSTR(SQLERRM, 1, 100);
        x_msg_data := 'CCT_IH_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
        --dbms_output.put_line(x_msg_data);
END OPEN_MEDIA_ITEM;

END CCT_IH_PUB;

/
