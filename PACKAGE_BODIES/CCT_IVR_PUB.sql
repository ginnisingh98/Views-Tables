--------------------------------------------------------
--  DDL for Package Body CCT_IVR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_IVR_PUB" AS
/* $Header: cctivrb.pls 120.0 2005/06/02 09:35:31 appldev noship $ */
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_IVR_PUB';


PROCEDURE parseAppData (
  p_app_data IN VARCHAR2,
  x_YYYY     out nocopy VARCHAR2,
  x_media_item out nocopy NUMBER,
  x_ZZZZ       out nocopy VARCHAR2,
  x_create_media_item out nocopy boolean
)
AS
  l_first NUMBER;
  l_second NUMBER;
  l_sub_string VARCHAR2 (128);
  l_search_for VARCHAR2 (4);
BEGIN
   -- Parse p_app_data
   -- if p_app_data is NULL then
   --    call create_media_item
   --    x_app_data = 'MI:IVR-123456';
   -- elsif p_app_data contains YYYYMI:123456;ZZZZ then
   --    x_app_data = 'YYYYMI:IVR-1234356;ZZZZ'
   -- elsif p_app_data contains YYYYMI:IVR-123456;ZZZZ then
   --    x_app_data = p_app_data
   -- elsif p_app_data does contain ZZZZ with no MI:123456; then
   --    call create_media_item
   --    x_App_data = 'MI:IVR-123456;ZZZZ'

   x_YYYY := NULL;
   x_ZZZZ := NULL;
   x_media_item := NULL;
   x_create_media_item := FALSE;

  -- look for the occurence of 'MI:' in p_app_data
  l_search_for := 'MI:';
  l_first := INSTR(p_app_data, l_search_for);

  if l_first = 0 then
     x_ZZZZ := p_app_data;
     x_create_media_item := TRUE;
     return;
  end if;

  -- get x_YYYY
  if l_first = 1 then x_YYYY := NULL;
  else x_YYYY := SUBSTR(p_app_data, 1, l_first - 1);
  end if;

  l_search_for := ';';
  l_second := INSTR(p_app_data, l_search_for, l_first);

  if l_second = 0 then raise fnd_api.g_exc_error;
  end if;

  -- get x_YYYY
  if l_second = LENGTH (p_app_data) then x_ZZZZ := NULL;
  else x_ZZZZ := SUBSTR(p_app_data, l_second + 1);
  end if;


  -- eg  p_app_data = MI:12345;abc=343;xyz=143;
  -- l_first = 1, l_second = 9
  -- l_sub_string := SUBSTR('MI:12345;abc=343;xyz=143;', 4, 5) := '12345'
  l_sub_string := SUBSTR(p_app_data, l_first + 3, l_second - l_first - 3);

  if l_sub_string IS NULL then raise  fnd_api.g_exc_error;
  end if;

  -- check if l_sub_string starts with IVR- and strip it out
  l_sub_string := LTRIM (l_sub_string, 'IVR-');

  -- convert from string to number
  x_media_item := TO_NUMBER (l_sub_string);

/*****
   dbms_output.put_line ('Input = ' || p_app_data);
   if (x_create_media_item) then
     dbms_output.put_line ('l_create_media_item = ' || 'TRUE');
   else
     dbms_output.put_line ('l_create_media_item = ' || 'FALSE');
   end if;
   dbms_output.put_line ('l_YYYY = ' || x_YYYY);
   dbms_output.put_line ('l_media_item  = ' || x_media_item);
   dbms_output.put_line ('l_ZZZZ = ' || x_ZZZZ);
****/


EXCEPTION
  WHEN OTHERS THEN
     raise  fnd_api.g_exc_error;
END parseAppData;

PROCEDURE create_IVR_Item
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		 out nocopy 	VARCHAR2,
	x_msg_count		 out nocopy 	NUMBER,
	x_msg_data		 out nocopy 	VARCHAR2,
	p_start_date_time	IN	DATE 		DEFAULT null,
	p_end_date_time		IN	DATE 		DEFAULT null,
	p_duration_in_secs	IN	NUMBER   	DEFAULT null,
	p_ivr_data		IN	VARCHAR2 	DEFAULT null,
	p_app_data		IN	VARCHAR2 	DEFAULT null,
	x_app_data		 out nocopy  	VARCHAR2
  ) AS
     l_api_name         CONSTANT VARCHAR2(30) := 'Create_IVR_Item';
     l_api_version      CONSTANT NUMBER       := 1.0;
     l_api_name_full    CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
     l_return_status    VARCHAR2(1);
     l_init_msg_list    VARCHAR2(1);
     l_commit		VARCHAR2(1);

     l_media_item_id	NUMBER := NULL;
     l_create_media_item BOOLEAN;

     l_YYYY		VARCHAR2 (128);
     l_ZZZZ		VARCHAR2 (128);

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT create_ivr_pub;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   x_app_data := NULL;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                      l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   if (p_init_msg_list <> FND_API.G_FALSE) AND
       (p_init_msg_list <> FND_API.G_TRUE)
   then l_init_msg_list := FND_API.G_FALSE;
   else l_init_msg_list := p_init_msg_list;
   end if;

   IF fnd_api.to_boolean(l_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   ----------------------------------------------------
   -- Validation checks for incoming parameters
   if ((p_commit <> FND_API.G_FALSE) AND
       (p_commit <> FND_API.G_TRUE))
   then l_commit := FND_API.G_FALSE;
   else l_commit := p_commit;
   end if;

   -- procedure to check p_ivr_data format ??

   -- by default do create media item
   l_create_media_item := TRUE;
   if (p_app_data <> fnd_api.g_miss_char) then

        parseAppData(
          p_app_data  => p_app_data,
          x_YYYY      => l_YYYY,
          x_media_item => l_media_item_id,
          x_ZZZZ      => l_ZZZZ,
          x_create_media_item => l_create_media_item
        ) ;

   end if;


   if (l_create_media_item) then
   ----------------------------------------------------
   -- Call JTF_IH_PUB.create_media_item

    JTF_IH_PUB_W.OPEN_MEDIAITEM (
	p_api_version	=> 1.0,
	p_init_msg_list	=> l_init_msg_list,
        p_commit	=> FND_API.G_FALSE,
	p_resp_appl_id	=> 1,
	p_resp_id	=> 1,
	p_user_id	=> -1,
	p_login_id	=> NULL,
	x_return_status	=> l_return_status,
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data,
        x_media_id	=> l_media_item_id,
	p10_a2		=> 'INBOUND',
	p10_a6		=> p_start_date_time,
	p10_a8		=> p_start_date_time,
	p10_a10		=> 'TELE_INB'

);

   end if;
   ----------------------------------------------------
   -- Call JTF_IH_PUB.Create_MediaLifecycle
   JTF_IH_PUB_W.CREATE_MEDIALIFECYCLE (
	p_api_version	=> '1.0',
	p_init_msg_list	=> p_init_msg_list,
        p_commit	=> FND_API.G_FALSE,
	p_resp_appl_id	=> 1,
	p_resp_id	=> 1,
	p_user_id	=> -1,
	p_login_id	=> NULL,
	x_return_status	=> l_return_status,
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data,
	p10_a0		=> p_start_date_time,
	p10_a3		=> p_duration_in_secs,
	p10_a4		=> p_end_date_time,
	p10_a6		=> 1,
	p10_a7		=> l_media_item_id
);
   ---------------------------------------------------------
   -- Insert into CCT_IVR_DATA table

   insert into CCT_IVR_DATA (
     MEDIA_ITEM_ID,
     IVR_DATA,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
   ) values (
     l_media_item_id,
     p_ivr_data,
     sysdate,
     -1,
     sysdate,
     -1,
     NULL
   );


   ---------------------------------------------------------
   -- Standard check of p_commit
   IF fnd_api.to_boolean(l_commit) THEN
      COMMIT WORK;
   END IF;

   -- return value
   x_app_data := l_YYYY || 'MI:IVR-' || TO_CHAR(l_media_item_id) || ';' || l_ZZZZ;


 /****
   dbms_output.put_line ('Input = ' || p_app_data);
   if (l_create_media_item) then
     dbms_output.put_line ('l_create_media_item = ' || 'TRUE');
   else
     dbms_output.put_line ('l_create_media_item = ' || 'FALSE');
   end if;
   dbms_output.put_line ('l_YYYY = ' || l_YYYY);
   dbms_output.put_line ('l_media_item  = ' || l_media_item_id);
   dbms_output.put_line ('l_ZZZZ = ' || l_ZZZZ);
   dbms_output.put_line ('Output = ' || x_app_data);

  ****/

   -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get
     ( p_count  => x_msg_count,
       p_data   => x_msg_data );


   ---------------------------------------------------------
  EXCEPTION
   WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO create_ivr_pub;
    x_return_status := fnd_api.g_ret_sts_error;

  END create_IVR_Item;

PROCEDURE  callIVRTEST (p_app_data VARCHAR2)
AS
     l_return_status    VARCHAR2(1);
     l_msg_count	NUMBER;
     l_msg_data		VARCHAR2(2000);
     l_app_data		VARCHAR2(256);
     l_ivr_data		VARCHAR2(20) := 'test data';
BEGIN

   CCT_IVR_PUB.create_ivr_item(
	p_api_version	 	=> '1.0',
	p_init_msg_list		=> FND_API.G_FALSE,
	p_commit		=> FND_API.G_FALSE,
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	p_start_date_time	=> sysdate,
	p_end_date_time		=> sysdate + 0.2,
	p_duration_in_secs	=> 20,
	p_ivr_data		=> l_ivr_data,
	p_app_data		=> p_app_data,
	x_app_data		=> l_app_data

   );

END callIVRTEST;



END CCT_IVR_PUB;

/
