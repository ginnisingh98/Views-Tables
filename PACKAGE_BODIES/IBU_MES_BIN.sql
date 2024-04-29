--------------------------------------------------------
--  DDL for Package Body IBU_MES_BIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_MES_BIN" as
/* $Header: ibuhmesb.pls 115.23 2002/11/05 20:23:21 ktma ship $ */

-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBU_MES_BIN';

type FilterData IS RECORD (
           name  VARCHAR2(60) := '',
           value VARCHAR2(300) := ''
);
type FilterDataList is table of FilterData;

-- ---------------------------------------------------------
-- Define private functions/procedures
-- ---------------------------------------------------------

procedure get_mes_filter (app_Id           NUMBER,
                          filter_list out NOCOPY FilterDataList)
         as
	        l_return_status    	    VARCHAR2(240);
	        l_api_version		    NUMBER;
    	        l_init_msg_list	         VARCHAR2(240);
    	        l_commit		         VARCHAR2(240);

    	        l_msg_count		         NUMBER;
    	        l_msg_data		         VARCHAR2(2000);
    	        l_err_msg		         VARCHAR2(240);

	        l_profile_id		    NUMBER;
	        l_profile_name		    VARCHAR2(60);
	        l_profile_type		    VARCHAR2(30);
	        l_profile_attrib_tbl JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;

	        l_application_id	         NUMBER;

	        l_perz_data_id		    NUMBER;
	        l_perz_data_name          VARCHAR2(60);
	        l_perz_data_type	         VARCHAR2(30);
	        l_perz_data_desc	         VARCHAR2(240);
	        l_data_attrib_tbl	    JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE ;
	        l_data_out_tbl	         JTF_PERZ_DATA_PUB.DATA_OUT_TBL_TYPE;

	        out_perz_data_id	         NUMBER;

	        out_perz_data_name        VARCHAR2(60);
	        out_perz_data_type	    VARCHAR2(30);
	        out_perz_data_desc	    VARCHAR2(240);

             data                      FilterData;
	        ind                       NUMBER := 1;
	    begin

	       l_api_version	:= 1.0;
    	       l_init_msg_list	:= FND_API.G_TRUE;
	       l_application_id	:= app_Id;
	       l_perz_data_name	:= 'IBU_A_CATEGORY';
	       l_profile_name	:= 'IBU_A_PROFILE00';

            JTF_PERZ_DATA_PVT.Get_Perz_Data
            (
	            p_api_version_number	=>	l_api_version,
  	            p_init_msg_list		=>	l_init_msg_list,
	            p_application_id       =>   l_application_id,
	            p_profile_id           => 	l_profile_id,
	            p_profile_name         => 	l_profile_name,
	            p_perz_data_id		=>	l_perz_data_id,
	            p_perz_data_name	     =>	l_perz_data_name,
	            p_perz_data_type	     =>	l_perz_data_type,

    	            x_perz_data_id         =>	out_perz_data_id,
	            x_perz_data_name       =>	out_perz_data_name,
	            x_perz_data_type	     =>	out_perz_data_type,
	            x_perz_data_desc	     =>	out_perz_data_desc,
	            x_data_attrib_tbl	     =>	l_data_attrib_tbl,

	            x_return_status		=>	l_return_status,
	            x_msg_count		     =>	l_msg_count,
	            x_msg_data		     =>	l_msg_data
            );


	       filter_list         := FilterDataList ();
            FOR f_curr_row IN 1..l_data_attrib_tbl.count
            LOOP
	         data.name  := l_data_attrib_tbl (f_curr_row).ATTRIBUTE_NAME;
		    /* dbms_output.put_line ('NAme=' || data.name); */
	         data.value := l_data_attrib_tbl (f_curr_row).ATTRIBUTE_VALUE;

	         filter_list.extend ();
	         filter_list (ind) := data;
              ind := ind + 1;
            END LOOP;
end get_mes_filter;

-----------------------------------------------------------
-- Return the close url
-- ---------------------------------------------------------
procedure get_close_url (bin_id NUMBER, url  out NOCOPY varchar2)
   as
     close_jsp    VARCHAR2(100);
   begin
     close_jsp := 'ibuhpage.jsp?close_binid=' || to_char(bin_id);
     url := close_jsp;
   end;


-----------------------------------------------------------
-- Define procedure for rendering name.
-- ---------------------------------------------------------
procedure  get_bin_name (p_api_version_number     IN   NUMBER,
                 p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                 p_commit       IN VARCHAR          := FND_API.G_FALSE,
			  p_bin_id       IN NUMBER,
                 x_return_status          OUT  NOCOPY VARCHAR2,
                 x_msg_count         OUT  NOCOPY NUMBER,
                 x_msg_data          OUT  NOCOPY VARCHAR2,
                 x_bin_name out NOCOPY VARCHAR2)
as
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Get_Bin_Name';
    l_bin_info     IBU_Home_Page_PVT.Bin_Data_Type;
    l_cat_id       NUMBER := null;
begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_bin_name := '';

    -- get the bin info
  IBU_Home_Page_PVT.get_bin_info(p_api_version_number => p_api_version_number,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_bin_id   => p_bin_id,
               x_bin_info => l_bin_info);

  IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      raise NO_DATA_FOUND;
  END IF;

  l_cat_id := l_bin_info.MES_cat_ID;
  if l_cat_id  is not null then
    -- get the bin name from the view
    SELECT channel_category_name
    INTO   x_bin_name
    FROM   amv_c_categories_vl
    WHERE  channel_category_id=l_cat_id;
  end if;

EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );
          raise;

end get_bin_name;

-----------------------------------------------------------
-- Define procedure for email text.
-- ---------------------------------------------------------
procedure get_email_text(p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
                     p_user_id      IN NUMBER,
                     p_lang_code    IN VARCHAR2,
                     p_bin_id            IN   NUMBER,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count         OUT  NOCOPY NUMBER,
                     x_msg_data          OUT  NOCOPY VARCHAR2,
                     x_clob      out NOCOPY CLOB)
as
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Get_Email_Text';
    l_api_version  CONSTANT       NUMBER         := 1.0;

    l_user_id NUMBER := IBU_Home_Page_PVT.get_user_id;
    l_lang VARCHAR2(5) := IBU_Home_Page_PVT.get_lang_code;

    l_bin_name           VARCHAR2(80);
    l_bin_info           IBU_Home_Page_PVT.Bin_Data_Type;
    l_data               IBU_Home_Page_PVT.Filter_Data_Type;
    l_filter_list        IBU_Home_Page_PVT.Filter_Data_List_Type;
    l_filter_string      VARCHAR2(500);

    res_clob                      CLOB;
    tmp_str                       VARCHAR(400);
    res_str        VARCHAR2(1000);
    amt            binary_integer;
    location       integer;
    batch_size     NUMBER := 5;
    channel_title  VARCHAR2(500);
    items_title    VARCHAR2(500);

    item_request_obj   AMV_CHANNEL_PVT.AMV_REQUEST_OBJ_TYPE;
    item_return_obj    AMV_CHANNEL_PVT.AMV_RETURN_OBJ_TYPE;
    items_array        AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE;

    cats_array         AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE;
    channels_array     AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE;

    item_object        AMV_ITEM_PUB.AMV_ITEM_OBJ_TYPE;
    item_file_array    AMV_ITEM_PUB.AMV_NUMBER_VARRAY_TYPE;
    item_persp_array   AMV_ITEM_PUB.AMV_NAMEID_VARRAY_TYPE;
    item_author_array  AMV_ITEM_PUB.AMV_CHAR_VARRAY_TYPE;
    item_keyword_array AMV_ITEM_PUB.AMV_CHAR_VARRAY_TYPE;

    data               FilterData;
    category_id        NUMBER := NULL;
    s_filter_list      FilterDataList;
    filter_list        FilterDataList;
    newln              VARCHAR2(2) := fnd_global.newline();
    no_items_fnd       VARCHAR2(1000);

begin

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API Body

     -- do validation
     IF p_bin_id is NULL OR p_user_id is null THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;

     -- Get the bin name
     get_bin_name(p_api_version_number => l_api_version,
               p_init_msg_list => p_init_msg_list,
               p_bin_id        => p_bin_id,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_bin_name => l_bin_name);
     /* dbms_output.put_line ('bin_name=' || l_bin_name); */

     IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
         FND_MESSAGE.SET_NAME('IBU','IBU_HOM_BINNAME_ERROR');
         FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
     END IF;

     IBU_Home_Page_PVT.get_bin_info(p_api_version_number => l_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_bin_id   => p_bin_id,
               x_bin_info => l_bin_info);

     IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
         FND_MESSAGE.SET_NAME('IBU','IBU_HOM_BININFO_ERROR');
         FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
     END IF;

      category_id := l_bin_info.MES_cat_ID;
   IF (category_id is NULL)
   THEN
         /* dbms_output.put_line('No Categories found='); */
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IBU', 'IBU_HOM_NO_CAT_FOR_CNEWS');
        FND_MSG_PUB.Add;
	   RAISE FND_API.G_EXC_ERROR;
    END IF;

    IBU_Home_Page_PVT.get_filter_list(p_api_version => l_api_version,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_user_id  => l_user_id,
                  p_bin_id  => p_bin_id,
                  x_filter_list => l_filter_list,
                  x_filter_string => l_filter_string);

    IF (NOT (x_return_status = FND_API.G_RET_STS_SUCCESS))
        OR l_filter_string is null THEN
    -- no filter criteria exist, so use hard coded default
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_filter_string := 'end=3';
    ELSE
      FOR l_curr_row IN 1..l_filter_list.count()
      LOOP
          l_data.name  := l_filter_list (l_curr_row).name;
          l_data.value := l_filter_list (l_curr_row).value;

          if l_data.name IS NOT NULL AND l_data.name like 'end' then
            batch_size := to_number(l_data.value);
            exit;
          end if;
      END LOOP;
    END IF;


    -- get the channels per category

    AMV_CATEGORY_GRP.Get_CatChildrenHierarchy(p_api_version => 1.0,
                                              p_init_msg_list => 'T',
                                              x_return_status => x_return_status,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data,
                                              p_check_login_user => 'F',
                                              p_category_id => category_id,
                                              x_category_hierarchy => cats_array);

    if (x_return_status = 'F')
    THEN
         /* dbms_output.put_line('No Items Found='); */
         fnd_message.set_name('IBU', 'IBU_HOM_ITEMS_ERROR');
         fnd_msg_pub.Add;
	    RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------------------------------------------------------------
    channel_title := IBU_HOME_PAGE_PVT.GET_AK_BIN_PROMPT('IBU_HOM_CNEWS_CHANNEL');
    items_title := IBU_HOME_PAGE_PVT.GET_AK_BIN_PROMPT('IBU_HOM_CNEWS_ITEMS');

    dbms_lob.createtemporary(res_clob, TRUE, DBMS_LOB.SESSION);

    location := 1;

    -- now fill in the actual bin contents to clob
    dbms_lob.createtemporary(res_clob, TRUE, DBMS_LOB.SESSION);

    tmp_str := l_bin_name;
    dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
    dbms_lob.writeappend(res_clob, length(newln), newln);

    for j IN 1 .. cats_array.count LOOP

    if ( cats_array(j).ID <> category_id)
        THEN
            -- get items per channel
            AMV_CATEGORY_GRP.Get_ChannelsPerCategory(p_api_version => 1.0,
                                                     p_init_msg_list => 'T',
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_check_login_user => 'F',
                                                     p_category_id => cats_array(j).ID,
                                                     x_content_chan_array => channels_array);

            if (x_return_status = 'F')
            THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                dbms_lob.writeappend(res_clob,length(newln), newln);
                tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
                dbms_lob.writeappend(res_clob,length(newln), newln);
                exit;
            END IF;

            item_request_obj.records_requested := batch_size;
            item_request_obj.start_record_position := 1;
            item_request_obj.return_total_count_flag := 'T';

            for k IN 1 .. channels_array.count LOOP

                  -- get items per channel
                  dbms_lob.writeappend(res_clob, length(newln), newln);

                  /* dbms_output.put_line(channels_array(k).ID); */
                  dbms_lob.writeappend(res_clob,length(channel_title),channel_title);
                  dbms_lob.writeappend(res_clob, 2,': ');
                  dbms_lob.writeappend(res_clob,length(channels_array(k).NAME),channels_array(k).NAME);
                  dbms_lob.writeappend(res_clob, length(newln), newln);
                  dbms_lob.writeappend(res_clob,length(items_title),items_title);
                  dbms_lob.writeappend(res_clob,2,': ');

                  AMV_CHANNEL_GRP.Get_ItemsPerChannel(p_api_version => 1.0,
                                                      p_init_msg_list => 'T',
                                                      x_return_status => x_return_status,
                                                      x_msg_count => x_msg_count,
                                                      x_msg_data => x_msg_data,
                                                      p_check_login_user => 'F',
                                                      p_channel_id => channels_array(k).ID,
                                                      p_subset_request_rec => item_request_obj,
                                                      x_subset_return_rec => item_return_obj,
                                                      x_document_id_array => items_array);

                  if (x_return_status = 'F')
                  THEN
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     dbms_lob.writeappend(res_clob,length(newln), newln);
                     tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                     dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
                     dbms_lob.writeappend(res_clob,length(newln), newln);
                     exit;
                  END IF;

                  for m IN 1 .. items_array.COUNT LOOP

                      AMV_ITEM_PUB.get_item(p_api_version => 1.0,
                                            p_init_msg_list => 'T',
                                            x_return_status => x_return_status,
                                            x_msg_count => x_msg_count,
                                            x_msg_data => x_msg_data,
                                            p_check_login_user => 'F',
                                            p_item_id => items_array(m),
                                            x_item_obj => item_object,
                                            x_file_array => item_file_array,
                                            x_persp_array => item_persp_array,
                                            x_author_array => item_author_array,
                                            x_keyword_array => item_keyword_array);

                       if (x_return_status = 'F')

                       THEN
                          x_return_status := FND_API.G_RET_STS_SUCCESS;
                          dbms_lob.writeappend(res_clob,length(newln), newln);
                          tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                          dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
                          dbms_lob.writeappend(res_clob,length(newln), newln);
                          exit;
                       END IF;

                       /* dbms_output.put_line(item_object.item_name); */
                       dbms_lob.writeappend(res_clob, length (item_object.item_name), item_object.item_name);
                       dbms_lob.writeappend(res_clob, 2, ', ');

                   end loop;

                   dbms_lob.writeappend(res_clob, length(newln), newln);
            end loop;

        END IF;

    end loop;
    x_clob := res_clob;
    dbms_lob.freetemporary(res_clob);
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );

     WHEN OTHERS THEN
          -- ROLLBACK TO Get_Filter;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );

end get_email_text;

-----------------------------------------------------------
-- Define procedure for rendering html.
-- ---------------------------------------------------------
procedure get_html (p_api_version_number     IN   NUMBER,
                     p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
                     p_commit                IN   VARCHAR  := FND_API.G_FALSE,
                     p_bin_id                IN   NUMBER,
                     p_cookie_url            IN   VARCHAR2,
                     x_return_status         OUT  NOCOPY VARCHAR2,
                     x_msg_count             OUT  NOCOPY NUMBER,
                     x_msg_data              OUT  NOCOPY VARCHAR2,
                     x_clob                  out NOCOPY CLOB)
as
    l_api_name     CONSTANT       VARCHAR2(30)   := 'Get_HTML';
    l_api_version  CONSTANT       NUMBER         := 1.0;

    l_user_id NUMBER := IBU_Home_Page_PVT.get_user_id;
    l_lang VARCHAR2(5) := IBU_Home_Page_PVT.get_lang_code;

    l_bin_name           VARCHAR2(80);
    l_bin_info           IBU_Home_Page_PVT.Bin_Data_Type;
    header_format        VARCHAR2(30) := 'tableSubHeaderCell';
    cell_format          VARCHAR2(20) := 'tableDataCell';
    tmp_str              VARCHAR2 (5000);
    header_str		 VARCHAR2 (13000);
    res_clob             CLOB;
    newln                VARCHAR2(2) := fnd_global.newline ();
    s_all_header_prompts IBU_HOME_PAGE_PVT.IBU_STR_ARR;

    l_data             IBU_Home_Page_PVT.Filter_Data_Type;
    l_filter_list      IBU_Home_Page_PVT.Filter_Data_List_Type;
    l_filter_string    VARCHAR2(500);

    l_edit_url    VARCHAR2(5000);
    l_close_url   VARCHAR2(5000);
    l_detail_url  VARCHAR2(5000);
    l_more_url    VARCHAR2(1000);
    l_go_url      VARCHAR2(1000);

    res_str        VARCHAR2(1000);
    amt            binary_integer;
    location       integer;
    batch_size     NUMBER := 3;
    channel_title  VARCHAR2(500);
    urlformat_channel_name VARCHAR2(500):='';
    channel_name   VARCHAR2 (500);
    items_title    VARCHAR2(500);

    item_request_obj   AMV_CHANNEL_PVT.AMV_REQUEST_OBJ_TYPE;
    item_return_obj    AMV_CHANNEL_PVT.AMV_RETURN_OBJ_TYPE;
    items_array        AMV_CHANNEL_PVT.AMV_NUMBER_VARRAY_TYPE;

    cats_array         AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE;
    channels_array     AMV_CATEGORY_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE;

    item_object        AMV_ITEM_PUB.AMV_ITEM_OBJ_TYPE;
    item_file_array    AMV_ITEM_PUB.AMV_NUMBER_VARRAY_TYPE;
    item_persp_array   AMV_ITEM_PUB.AMV_NAMEID_VARRAY_TYPE;
    item_author_array  AMV_ITEM_PUB.AMV_CHAR_VARRAY_TYPE;
    item_keyword_array AMV_ITEM_PUB.AMV_CHAR_VARRAY_TYPE;

    category_id        NUMBER := NULL;
    no_items_fnd       VARCHAR2(1000);
    DETAIL_URL         VARCHAR2(5000) := 'ibukmipc.jsp';
    url                VARCHAR2(5000);

    no_items_exist     VARCHAR2(100) := FND_API.G_TRUE;
begin
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API Body

     -- do validation
     IF p_bin_id is NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('IBU','IBU_HOM_BIN_ID_MISSING');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  -- Get the bin name, the mandatory flag

  get_bin_name(p_api_version_number => l_api_version,
               p_init_msg_list => p_init_msg_list,
               p_bin_id        => p_bin_id,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               x_bin_name => l_bin_name);

  IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.SET_NAME('IBU','IBU_HOM_BINNAME_ERROR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IBU_Home_Page_PVT.get_bin_info(p_api_version_number => l_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_bin_id   => p_bin_id,
               x_bin_info => l_bin_info);

  IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.SET_NAME('IBU','IBU_HOM_BININFO_ERROR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

   category_id := l_bin_info.MES_cat_ID;
   IF (category_id is NULL)
   THEN
         /* dbms_output.put_line('No Categories found=');*/
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IBU', 'IBU_HOM_NO_CAT_FOR_CNEWS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  IBU_Home_Page_PVT.get_filter_list(p_api_version => l_api_version,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_user_id  => l_user_id,
                  p_bin_id  => p_bin_id,
                  x_filter_list => l_filter_list,
                  x_filter_string => l_filter_string);

  IF (NOT (x_return_status = FND_API.G_RET_STS_SUCCESS))
        OR l_filter_string is null THEN
    -- no filter criteria exist, so use hard coded default
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_filter_string := 'end=3';
  ELSE
    FOR l_curr_row IN 1..l_filter_list.count()
    LOOP
          l_data.name  := l_filter_list (l_curr_row).name;
          l_data.value := l_filter_list (l_curr_row).value;

          if l_data.name IS NOT NULL AND l_data.name like 'end' then
            batch_size := to_number(l_data.value);
            exit;
          end if;
    END LOOP;
  END IF;

  l_edit_url := IBU_Home_Page_PVT.get_edit_bin_url(p_bin_id, 'ibuhmesc.jsp', l_filter_string, p_cookie_url);

  if l_bin_info.mandatory_flag = FND_API.G_FALSE then
    l_close_url := IBU_Home_Page_PVT.get_close_bin_url(p_bin_id, p_cookie_url);
  else
    l_close_url := null;
  end if;

  -- now create the clob and store the bin html in
  dbms_lob.createtemporary(res_clob, TRUE, DBMS_LOB.SESSION);

  -- store the bin header in clob, including bin name, edit and close button
  tmp_str := '<table width="100%" border="0" cellspacing="0" cellpadding="0">';
  dbms_lob.writeappend(res_clob, length(tmp_str),tmp_str);
  dbms_lob.writeappend(res_clob,4,'<tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);
  dbms_lob.writeappend(res_clob,4,'<td>');
  dbms_lob.writeappend(res_clob,length(newln), newln);
  header_str := IBU_Home_Page_PVT.get_bin_header_html (l_bin_name, null, l_edit_url, l_close_url);

  dbms_lob.writeappend(res_clob,length(header_str),header_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);
  dbms_lob.writeappend(res_clob,5,'</tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);
  dbms_lob.writeappend(res_clob,5,'</td>');
  dbms_lob.writeappend(res_clob,length(newln), newln);

    -- get the channels per category

    AMV_CATEGORY_GRP.Get_CatChildrenHierarchy(p_api_version => 1.0,
                                              p_init_msg_list => 'T',
                                              x_return_status => x_return_status,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data,
                                              p_check_login_user => 'F',
                                              p_category_id => category_id,
                                              x_category_hierarchy => cats_array);

    if (x_return_status = 'F')
    THEN
         /* dbms_output.put_line('No Items Found='); */
         fnd_message.set_name('IBU', 'IBU_HOM_ITEMS_ERROR');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------------------------------------------------------------
    channel_title := IBU_HOME_PAGE_PVT.GET_AK_BIN_PROMPT('IBU_HOM_CNEWS_CHANNEL');
    items_title := IBU_HOME_PAGE_PVT.GET_AK_BIN_PROMPT('IBU_HOM_CNEWS_ITEMS');

    /*  dbms_output.put_line('title=' || channel_title); */
    /*  dbms_output.put_line('ititle=' || items_title);  */
    -- dbms_lob.createtemporary(res_clob, TRUE, DBMS_LOB.SESSION);

    dbms_lob.writeappend(res_clob,length(newln), newln);
    for j IN 1 .. cats_array.count LOOP

    if (cats_array(j).ID <> category_id)
        THEN
            -- get items per channel

            AMV_CATEGORY_GRP.Get_ChannelsPerCategory(p_api_version => 1.0,
                                                     p_init_msg_list => 'T',
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_check_login_user => 'F',
                                                     p_category_id => cats_array(j).ID,
                                                     x_content_chan_array => channels_array);

            if (x_return_status = 'F')
            THEN
                /* dbms_output.put_line(' Items Error=');  */
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                dbms_lob.writeappend(res_clob,6, '  <tr>');
                dbms_lob.writeappend(res_clob,length(newln), newln);
                dbms_lob.writeappend(res_clob,length(newln), newln);
                tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                res_str := '    <td' || ' align="center" class="'
                || cell_format || '">'
                ||  tmp_str || ' </td>';
                dbms_lob.writeappend(res_clob,length(res_str), res_str);
                dbms_lob.writeappend(res_clob,length(newln), newln);
                dbms_lob.writeappend(res_clob,length(newln), newln);

                dbms_lob.writeappend(res_clob,7, '  </tr>');
                dbms_lob.writeappend(res_clob, length(newln), newln);
                exit;
            END IF;

            item_request_obj.records_requested := batch_size;
            item_request_obj.start_record_position := 1;
            item_request_obj.return_total_count_flag := 'T';

            for k IN 1 .. channels_array.count LOOP
                 /* dbms_output.put_line('channel name=' || channels_array(k).NAME); */
                 dbms_lob.writeappend(res_clob,4,'<tr>');
                 tmp_str := '<td class="tableDataCell" colspan="3">';
                 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);

              -- ujagarla - If there is no content, then we need to show a message
              no_items_exist  := FND_API.G_FALSE;

			  -- Start converting channel name to URL format
			  urlformat_channel_name := '';
			  channel_name:= channels_array(k).NAME;
			  for p in  1..LENGTH(channel_name) loop
				if (substr (channel_name, p, 1) = ' ') then
					urlformat_channel_name := urlformat_channel_name || '+';
				else
					urlformat_channel_name := urlformat_channel_name || substr (channel_name, p, 1);
				end if;
			  end loop;

                 url := 'ibukmipc.jsp?channelId=' ||channels_array(k).ID
||'&' || 'channelName=' || urlformat_channel_name || '&' || p_cookie_url;
                 tmp_str := '<a href=' || url || '>' || channels_array(k).NAME || '</a>';
                 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
                 dbms_lob.writeappend(res_clob,length(newln),newln);
                 tmp_str := '</td> </tr> <tr> </tr>';
                 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
                 dbms_lob.writeappend(res_clob,length(newln),newln);

                 /* dbms_output.put_line('items in channel' || channels_array(k).NAME); */
                  -- get items per channel

                  AMV_CHANNEL_GRP.Get_ItemsPerChannel(p_api_version => 1.0,
                                                  p_init_msg_list => 'T',
                                                      x_return_status => x_return_status,
                                                      x_msg_count => x_msg_count,
                                                      x_msg_data => x_msg_data,
                                                      p_check_login_user => 'F',
                                                      p_channel_id => channels_array(k).ID,
                                                      p_subset_request_rec => item_request_obj,
                                                      x_subset_return_rec => item_return_obj,
                                                      x_document_id_array => items_array);

                  if (x_return_status = 'F')
                  THEN
                     /* dbms_output.put_line('No  Items for this chanel='); */
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     dbms_lob.writeappend(res_clob,6, '  <tr>');
                     dbms_lob.writeappend(res_clob,length(newln), newln);
                     tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                     res_str := '    <td' || ' align="center" class="'
                      || cell_format || '">'
                      ||  tmp_str || ' </td>';
                     dbms_lob.writeappend(res_clob,length(res_str), res_str);
                     dbms_lob.writeappend(res_clob,length(newln), newln);

                     dbms_lob.writeappend(res_clob,7, '  </tr>');
                     dbms_lob.writeappend(res_clob, length(newln), newln);
                     exit;
                  END IF;

                  for m IN 1 .. items_array.COUNT LOOP

                      AMV_ITEM_PUB.get_item(p_api_version => 1.0,
                                            p_init_msg_list => 'T',
                                            x_return_status => x_return_status,
                                            x_msg_count => x_msg_count,
                                            x_msg_data => x_msg_data,
                                            p_check_login_user => 'F',
                                            p_item_id => items_array(m),
                                            x_item_obj => item_object,
                                            x_file_array => item_file_array,
                                            x_persp_array => item_persp_array,
                                            x_author_array => item_author_array,
                                            x_keyword_array => item_keyword_array);

                       if (x_return_status = 'F')
                       THEN
                           /* dbms_output.put_line('No  Items for this chanel=');*/
                           x_return_status := FND_API.G_RET_STS_SUCCESS;
                           dbms_lob.writeappend(res_clob,6, '  <tr>');
                           dbms_lob.writeappend(res_clob,length(newln), newln);
                           tmp_str := FND_MESSAGE.GET_STRING('IBU','IBU_HOM_ITEMS_ERROR');
                           res_str := '    <td' || ' align="center" class="'
                            || cell_format || '">'
                            ||  tmp_str || ' </td>';
                           dbms_lob.writeappend(res_clob,length(res_str), res_str);
                           dbms_lob.writeappend(res_clob,length(newln), newln);
                           dbms_lob.writeappend(res_clob,length(newln), newln);

                           dbms_lob.writeappend(res_clob,7, '  </tr>');
                           dbms_lob.writeappend(res_clob, length(newln), newln);
                           exit;
                       END IF;

                       dbms_lob.writeappend(res_clob, 4,'<tr>');
                       dbms_lob.writeappend(res_clob, length(newln),newln);

                       if (item_object.item_type like 'URL_ITEM') then
                             -- tmp_str := '<td  class="binContentCell"><li><a href="http://' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                             if ( instr(item_object.url_string,'http://') =0  ) then
                               tmp_str := '<td  class="binContentCell"><li><a href="http://' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                             else
                               tmp_str := '<td  class="binContentCell"><li><a href="' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                             end if;

                             dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                             dbms_lob.writeappend(res_clob, length(newln), newln);

                       elsif item_object.item_type like 'FILE_ITEM' then
                             tmp_str := '<td  class="binContentCell"><li><a href="ibuzbot.jsp?itemid=' || item_object.item_id || '" >' || item_object.item_name || '</a> </td>';
                             dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                             dbms_lob.writeappend(res_clob, length(newln), newln);

                       else --MESSAGE_ITEM
                             tmp_str := '<td  class="binContentCell"><li><a href="ibuzbot.jsp?itemid=' || item_object.item_id || '">' || item_object.item_name || '</a> </td>';
                             dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                             dbms_lob.writeappend(res_clob, length(newln), newln);

                       end if;
				   tmp_str := '</tr> <tr> </tr>';
                       dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                   end loop;
            end loop;
        END IF;

  end loop;

  --- ujagarla - begin==========================================================================================

            -- get items per channel - for top level category (bug fix : 2243802).
            -- Channels that are attached to top level category are not retrieved.

            AMV_CATEGORY_GRP.Get_ChannelsPerCategory(p_api_version => 1.0,
                                                     p_init_msg_list => 'T',
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_check_login_user => 'F',
                                                     p_category_id => category_id,
                                                     p_include_subcats => FND_API.G_FALSE,
                                                     x_content_chan_array => channels_array);

            if (x_return_status = 'F')
            THEN
                /* dbms_output.put_line(' Items Error=');  */
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                dbms_lob.writeappend(res_clob,6, '  <tr>');
                dbms_lob.writeappend(res_clob,length(newln), newln);
                dbms_lob.writeappend(res_clob,length(newln), newln);
                tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                res_str := '    <td' || ' align="center" class="'
                || cell_format || '">'
                ||  tmp_str || ' </td>';
                dbms_lob.writeappend(res_clob,length(res_str), res_str);
                dbms_lob.writeappend(res_clob,length(newln), newln);
                dbms_lob.writeappend(res_clob,length(newln), newln);

                dbms_lob.writeappend(res_clob,7, '  </tr>');
                dbms_lob.writeappend(res_clob, length(newln), newln);
            END IF;

            item_request_obj.records_requested := batch_size;
            item_request_obj.start_record_position := 1;
            item_request_obj.return_total_count_flag := 'T';

            for k IN 1 .. channels_array.count LOOP
                 /* dbms_output.put_line('channel name=' || channels_array(k).NAME); */
                 dbms_lob.writeappend(res_clob,4,'<tr>');
                 tmp_str := '<td class="tableDataCell" colspan="3">';
                 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);

              -- ujagarla - If there is no content, then we need to show a message
              no_items_exist  := FND_API.G_FALSE;

			  -- Start converting channel name to URL format
			  urlformat_channel_name := '';
			  channel_name:= channels_array(k).NAME;
			  for p in  1..LENGTH(channel_name) loop
				if (substr (channel_name, p, 1) = ' ') then
					urlformat_channel_name := urlformat_channel_name || '+';
				else
					urlformat_channel_name := urlformat_channel_name || substr (channel_name, p, 1);
				end if;
			  end loop;

                 url := 'ibukmipc.jsp?channelId=' ||channels_array(k).ID
||'&' || 'channelName=' || urlformat_channel_name || '&' || p_cookie_url;
                 tmp_str := '<a href=' || url || '>' || channels_array(k).NAME || '</a>';
                 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
                 dbms_lob.writeappend(res_clob,length(newln),newln);
                 tmp_str := '</td> </tr> <tr> </tr>';
                 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
                 dbms_lob.writeappend(res_clob,length(newln),newln);

                 /* dbms_output.put_line('items in channel' || channels_array(k).NAME); */
                  -- get items per channel

                  AMV_CHANNEL_GRP.Get_ItemsPerChannel(p_api_version => 1.0,
                                                  p_init_msg_list => 'T',
                                                      x_return_status => x_return_status,
                                                      x_msg_count => x_msg_count,
                                                      x_msg_data => x_msg_data,
                                                      p_check_login_user => 'F',
                                                      p_channel_id => channels_array(k).ID,
                                                      p_subset_request_rec => item_request_obj,
                                                      x_subset_return_rec => item_return_obj,
                                                      x_document_id_array => items_array);

                  if (x_return_status = 'F')
                  THEN
                     /* dbms_output.put_line('No  Items for this chanel='); */
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                     dbms_lob.writeappend(res_clob,6, '  <tr>');
                     dbms_lob.writeappend(res_clob,length(newln), newln);
                     tmp_str := FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR');
                     res_str := '    <td' || ' align="center" class="'
                      || cell_format || '">'
                      ||  tmp_str || ' </td>';
                     dbms_lob.writeappend(res_clob,length(res_str), res_str);
                     dbms_lob.writeappend(res_clob,length(newln), newln);

                     dbms_lob.writeappend(res_clob,7, '  </tr>');
                     dbms_lob.writeappend(res_clob, length(newln), newln);
                     exit;
                  END IF;

                  for m IN 1 .. items_array.COUNT LOOP

                      AMV_ITEM_PUB.get_item(p_api_version => 1.0,
                                            p_init_msg_list => 'T',
                                            x_return_status => x_return_status,
                                            x_msg_count => x_msg_count,
                                            x_msg_data => x_msg_data,
                                            p_check_login_user => 'F',
                                            p_item_id => items_array(m),
                                            x_item_obj => item_object,
                                            x_file_array => item_file_array,
                                            x_persp_array => item_persp_array,
                                            x_author_array => item_author_array,
                                            x_keyword_array => item_keyword_array);

                       if (x_return_status = 'F')
                       THEN
                           /* dbms_output.put_line('No  Items for this chanel=');*/
                           x_return_status := FND_API.G_RET_STS_SUCCESS;
                           dbms_lob.writeappend(res_clob,6, '  <tr>');
                           dbms_lob.writeappend(res_clob,length(newln), newln);
                           tmp_str := FND_MESSAGE.GET_STRING('IBU','IBU_HOM_ITEMS_ERROR');
                           res_str := '    <td' || ' align="center" class="'
                            || cell_format || '">'
                            ||  tmp_str || ' </td>';
                           dbms_lob.writeappend(res_clob,length(res_str), res_str);
                           dbms_lob.writeappend(res_clob,length(newln), newln);
                           dbms_lob.writeappend(res_clob,length(newln), newln);

                           dbms_lob.writeappend(res_clob,7, '  </tr>');
                           dbms_lob.writeappend(res_clob, length(newln), newln);
                           exit;
                       END IF;

                       dbms_lob.writeappend(res_clob, 4,'<tr>');
                       dbms_lob.writeappend(res_clob, length(newln),newln);

                       if (item_object.item_type like 'URL_ITEM') then
                             -- tmp_str := '<td  class="binContentCell"><li><a href="http://' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                             if ( instr(item_object.url_string,'http://') =0  ) then
                               tmp_str := '<td  class="binContentCell"><li><a href="http://' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                             else
                               tmp_str := '<td  class="binContentCell"><li><a href="' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                             end if;

                             dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                             dbms_lob.writeappend(res_clob, length(newln), newln);

                       elsif item_object.item_type like 'FILE_ITEM' then
                             tmp_str := '<td  class="binContentCell"><li><a href="ibuzbot.jsp?itemid=' || item_object.item_id || '" >' || item_object.item_name || '</a> </td>';
                             dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                             dbms_lob.writeappend(res_clob, length(newln), newln);

                       else --MESSAGE_ITEM
                             tmp_str := '<td  class="binContentCell"><li><a href="ibuzbot.jsp?itemid=' || item_object.item_id || '">' || item_object.item_name || '</a> </td>';
                             dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                             dbms_lob.writeappend(res_clob, length(newln), newln);

                       end if;
				   tmp_str := '</tr> <tr> </tr>';
                       dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                   end loop; -- for m IN 1 .. items_array.COUNT LOOP
            end loop; -- for k IN 1 .. channels_array.count LOOP

  -- ujagarla - end=============================================================================================

    -- ujagarla - If no content exist, show message to the user.
      IF ( no_items_exist = FND_API.G_TRUE )THEN
        tmp_str := '<tr><td class="binContentCell">'
		    || FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_NO_ITEMS_FOUND')
			|| '</td></tr>';
        dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
        dbms_lob.writeappend(res_clob,length(newln), newln);
      End If;

     -- Bin footer
     dbms_lob.writeappend(res_clob, 5, '</td>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 5, '</tr>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 8, '</table>');
     dbms_lob.writeappend(res_clob,length(newln), newln);


     /*dbms_lob.writeappend(res_clob, 8, '</table>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 5, '</td>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 5, '</tr>');
     dbms_lob.writeappend(res_clob,length(newln), newln);

     dbms_lob.writeappend(res_clob, 4, '<tr>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     -- chr(38) is special char for 'and'
     tmp_str := '<td colspan="3" height="15">' || CHR(38) || 'nbsp;</td>';
     dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 5, '</tr>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     */
  x_clob := res_clob;
  dbms_lob.freetemporary(res_clob);

  -- End of API Body
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count ,
           p_data => x_msg_data
          );
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          FND_MSG_PUB.Count_And_Get
                  (p_count => x_msg_count ,
                   p_data => x_msg_data
                  );
     WHEN OTHERS THEN
          -- ROLLBACK TO Get_Filter;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
               (p_count => x_msg_count ,
                p_data => x_msg_data
               );
          raise;

  end get_html;

end ibu_mes_bin;

/
