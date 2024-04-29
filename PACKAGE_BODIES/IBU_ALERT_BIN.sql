--------------------------------------------------------
--  DDL for Package Body IBU_ALERT_BIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_ALERT_BIN" as
/* $Header: ibuhaltb.pls 115.18.1159.2 2003/07/01 23:26:37 lahuang ship $ */

-- ---------------------------------------------------------
-- Define global variables and types
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBU_ALERT_BIN';


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
begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_bin_name := ibu_home_page_pvt.get_ak_bin_prompt ('IBU_HOM_CAT_ALERT');

EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_bin_name := 'Alerts';

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
          (
               p_count => x_msg_count ,
               p_data => x_msg_data
          );

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
    res_clob                      CLOB;
    tmp_str                       VARCHAR(400);
    l_bin_name                    VARCHAR2(80);
    l_more          		      VARCHAR2(80);
    amt                           binary_integer;
    msg_count                     NUMBER;
    location                      integer;
    msg_data                      VARCHAR2(1000);
    batch_size                    NUMBER := 3;

    request_obj      AMV_MYCHANNEL_PVT.AMV_REQUEST_OBJ_TYPE;
    return_obj       AMV_MYCHANNEL_PVT.AMV_RETURN_OBJ_TYPE;
    items_array      AMV_MYCHANNEL_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE;
    resource_id      NUMBER;
    newln            VARCHAR2(2) := fnd_global.newline();
    no_items_fnd     VARCHAR2(1000);

    l_employee_id    fnd_user.employee_id%TYPE;
    l_customer_id    fnd_user.customer_id%TYPE;
    l_supplier_id    fnd_user.supplier_id%TYPE;

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
      FND_MESSAGE.SET_NAME('IBU','IBU_HOM_BIN_ID_MISSING');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
     END IF;

    request_obj.records_requested := batch_size;
    request_obj.start_record_position := 1;
    request_obj.return_total_count_flag := 'T';

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

	l_more := ibu_home_page_pvt.get_ak_bin_prompt ('IBU_HOM_CAT_MORE');
    IF l_more  is NULL OR l_more ='' THEN
      l_more := 'More';
    end if;


    begin
      -- to be patched
      select employee_id, customer_id, supplier_id
      into l_employee_id, l_customer_id, l_supplier_id
      from fnd_user
      Where user_id =  p_user_id;

      If (l_employee_id is not null ) Then
          select resource_id
          into resource_id
          from jtf_rs_resource_extns a, fnd_user b
          where a.source_id = b.employee_id
          and a.category = 'EMPLOYEE'
          and b.user_id = p_user_id
          and ( (a.end_date_active is null ) Or (a.end_date_active  > sysdate) );
      Elsif (l_customer_id is not null )Then
          select resource_id
          into resource_id
          from jtf_rs_resource_extns a, fnd_user b
          where a.source_id = b.customer_id
          and a.category = 'PARTY'
          and b.user_id = p_user_id
          and ( (a.end_date_active is null ) Or (a.end_date_active  > sysdate) );
      ElsIf (l_supplier_id is not null )Then
          select resource_id
          into resource_id
          from jtf_rs_resource_extns a, fnd_user b
          where a.source_id = b.supplier_id
          and a.category = 'SUPPLIER_CONTACT'
          and b.user_id = p_user_id
          and ( (a.end_date_active is null ) Or (a.end_date_active  > sysdate) );
      End If;
    exception
      when NO_DATA_FOUND then
        resource_id := NULL;
      when others then
        raise;
    end;

    dbms_lob.createtemporary(res_clob, TRUE, DBMS_LOB.SESSION);
    tmp_str := l_bin_name;
    dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
    dbms_lob.writeappend(res_clob, length(newln), newln);
    dbms_lob.writeappend(res_clob, length(newln), newln);

    IF (resource_id IS NULL)

    THEN
       --tmp_str := fnd_message.get_string('IBU', 'IBU_HOM_NO_RESOURCE_ID');
       tmp_str := fnd_message.get_string('IBU', 'IBU_HOM_NO_RESOURCE_ID_ALERTS');
       dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
       dbms_lob.writeappend(res_clob, length(newln), newln);
        --raise NO_DATA_FOUND;

    ELSE

       --dbms_output.put_line('Getting items for user ' || resource_id);
       AMV_MYCHANNEL_GRP.Get_ItemsPerUser(p_api_version => 1.0,
                                       p_init_msg_list => 'T',
                                       x_return_status => x_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       p_check_login_user => 'F',
                                       p_user_id => resource_id,
                                       p_request_obj => request_obj,
                                       x_return_obj => return_obj,
                                       x_items_array => items_array);

       /*dbms_output.put_line('return_status is ' || return_status); */

       if NOT (x_return_status = FND_API.G_RET_STS_SUCCESS)
       THEN
          tmp_str := fnd_message.get_string('IBU', 'IBU_HOM_ITEMS_ERROR');
          dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
          dbms_lob.writeappend(res_clob, length(newln), newln);
          --raise NO_DATA_FOUND;

       ELSIF (return_obj.TOTAL_RECORD_COUNT = 0)
       then

--        no_items_fnd := IBU_CATEGORY_MANAGER.IBU_GET_AK_DISPLAY_NAME('IBU_HOM_NO_ITEMS_FOUND');
--        dbms_lob.writeappend(res_clob,length(no_items_fnd),no_items_fnd);
          tmp_str := fnd_message.get_string('IBU', 'IBU_HOM_NO_ITEMS_FOUND');
          dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
          dbms_lob.writeappend(res_clob, length(newln), newln);

       ELSE

          for i IN 1 .. items_array.COUNT LOOP

            amt := length (items_array(i).NAME);
            dbms_lob.writeappend(res_clob, amt, items_array(i).NAME);
            dbms_lob.writeappend(res_clob, length(newln), newln);
          end loop;
	   END IF;
	END IF;

    dbms_lob.writeappend(res_clob, length(newln), newln);

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
    l_more		         VARCHAR2(80);
    l_bin_info           IBU_Home_Page_PVT.Bin_Data_Type;
    header_format        VARCHAR2(30) := 'tableSubHeaderCell';
    cell_format          VARCHAR2(20) := 'tableDataCell';
    tmp_str              VARCHAR2 (400);
    res_clob             CLOB;
    s_all_header_prompts IBU_HOME_PAGE_PVT.IBU_STR_ARR;

    l_data             IBU_Home_Page_PVT.Filter_Data_Type;
    l_filter_list      IBU_Home_Page_PVT.Filter_Data_List_Type;
    l_filter_string    VARCHAR2(500);

    l_edit_url    VARCHAR2(5000);
    l_close_url   VARCHAR2(5000);
    l_detail_url  VARCHAR2(5000);
    l_more_url    VARCHAR2(1000);
    l_edit_name   VARCHAR2(30);
    l_close_name  VARCHAR2(30);
    header_str    VARCHAR2(18000);

    l_msg_data      VARCHAR2(1000);
	l_msg_index		NUMBER;
    l_more_msg_data    BOOLEAN := FALSE;

    batch_size    NUMBER := 5;
    request_obj   AMV_MYCHANNEL_PVT.AMV_REQUEST_OBJ_TYPE;
    return_obj    AMV_MYCHANNEL_PVT.AMV_RETURN_OBJ_TYPE;
    items_array   AMV_MYCHANNEL_PVT.AMV_CAT_HIERARCHY_VARRAY_TYPE;
    resource_id   NUMBER;
    newln         VARCHAR2(2) := fnd_global.newline();
    no_items_fnd  VARCHAR2(1000);
    DETAIL_URL    VARCHAR2(100) := 'ibumis11.jsp';
    item_object        AMV_ITEM_PUB.AMV_ITEM_OBJ_TYPE;
    item_file_array    AMV_ITEM_PUB.AMV_NUMBER_VARRAY_TYPE;
    item_persp_array   AMV_ITEM_PUB.AMV_NAMEID_VARRAY_TYPE;
    item_author_array  AMV_ITEM_PUB.AMV_CHAR_VARRAY_TYPE;
    item_keyword_array AMV_ITEM_PUB.AMV_CHAR_VARRAY_TYPE;

    l_employee_id    fnd_user.employee_id%TYPE;
    l_customer_id    fnd_user.customer_id%TYPE;
    l_supplier_id    fnd_user.supplier_id%TYPE;

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

	l_more := ibu_home_page_pvt.get_ak_bin_prompt ('IBU_HOM_CAT_MORE');
    IF l_more  is NULL OR l_more ='' THEN
      l_more := 'More';
    end if;

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

  if l_bin_info.row_number > -1 then
    batch_size := l_bin_info.row_number ;
  end if;

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
    l_filter_string := 'end=5';
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

  l_edit_url := IBU_Home_Page_PVT.get_edit_bin_url(p_bin_id, 'ibuhalrt.jsp', l_filter_string, p_cookie_url);
  if l_bin_info.mandatory_flag = FND_API.G_FALSE then
     l_close_url := IBU_Home_Page_PVT.get_close_bin_url(p_bin_id, p_cookie_url);
  else
     l_close_url := null;
  end if;
  l_detail_url := DETAIL_URL || '?' || p_cookie_url;

  -- now create the clob and store the bin html in
  dbms_lob.createtemporary(res_clob, TRUE, DBMS_LOB.SESSION);

  -- store the bin header in clob, including bin name, edit and close button
  -- render_bin_header
  dbms_lob.writeappend(res_clob,length(newln), newln);
  tmp_str := '<table border="0" width="100%" cellspacing="0" cellpadding="0">';
  dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);

  dbms_lob.writeappend(res_clob,6,'  <tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);

  tmp_str := '    <th id="h1">';
  dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);

  dbms_lob.writeappend(res_clob,7,'  </tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);

  dbms_lob.writeappend(res_clob,6,'  <tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);

  tmp_str := '    <td headers="h1">';
  dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);


  header_str := IBU_Home_Page_PVT.get_bin_header_html(l_bin_name,
                                                   '',
                                                   l_edit_url,
                                                   l_close_url);


  dbms_lob.writeappend(res_clob, length(header_str), header_str);

/*
  tmp_str := '<td><img height=21 src="/OA_MEDIA/ibuutl02.gif" width="7"></td>';
  dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);
  tmp_str := '<td align="center" nowrap width="100%" class="binHeaderCell">';
  dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);

  if l_bin_info.mandatory_flag = FND_API.G_FALSE then
      tmp_str := '<a href="' || l_close_url || '"><img align=right border=0 src="../media/jtfcrs0l.gif"></a>';
      dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
  end if;

  tmp_str := '<a href="' || l_edit_url || '"><img align=right border=0 src="../media/jtfedt0l.gif"></a>' || l_bin_name || '</td>';
  dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);

  tmp_str := '<td><img height=21 src="/OA_MEDIA/ibuutr02.gif" width="7"></td>';
  dbms_lob.writeappend(res_clob,length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);
*/
  dbms_lob.writeappend(res_clob,9,'    </td>');
  dbms_lob.writeappend(res_clob,length(newln), newln);
  dbms_lob.writeappend(res_clob,7,'  </tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);
  dbms_lob.writeappend(res_clob,6,'  <tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);
  tmp_str := '    <td headers=h1>';
  dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);
  tmp_str := '      <table border="0" width="100%" cellspacing="1" cellpadding="1">';
  dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);

  dbms_lob.writeappend(res_clob,12,'        <tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);

  tmp_str := '          <th id="h1">';
  dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
  dbms_lob.writeappend(res_clob,length(newln), newln);

  dbms_lob.writeappend(res_clob,13,'        </tr>');
  dbms_lob.writeappend(res_clob,length(newln), newln);



    request_obj.records_requested := batch_size;
    request_obj.start_record_position := 1;
    request_obj.return_total_count_flag := 'T';
    --dbms_output.put_line ('getting resource id');

    begin
    -- to be patched
      select employee_id, customer_id, supplier_id
      into l_employee_id, l_customer_id, l_supplier_id
      from fnd_user
      Where user_id =  l_user_id;

      If (l_employee_id is not null ) Then
          select resource_id
          into resource_id
          from jtf_rs_resource_extns a, fnd_user b
          where a.source_id = b.employee_id
          and a.category = 'EMPLOYEE'
          and b.user_id = l_user_id
          and ( (a.end_date_active is null ) Or (a.end_date_active  > sysdate) );
      Elsif (l_customer_id is not null )Then
          select resource_id
          into resource_id
          from jtf_rs_resource_extns a, fnd_user b
          where a.source_id = b.customer_id
          and a.category = 'PARTY'
          and b.user_id = l_user_id
          and ( (a.end_date_active is null ) Or (a.end_date_active  > sysdate) );
      ElsIf (l_supplier_id is not null )Then
          select resource_id
          into resource_id
          from jtf_rs_resource_extns a, fnd_user b
          where a.source_id = b.supplier_id
          and a.category = 'SUPPLIER_CONTACT'
          and b.user_id = l_user_id
          and ( (a.end_date_active is null ) Or (a.end_date_active  > sysdate) );
      End If;
    exception
      when NO_DATA_FOUND then
        resource_id := NULL;
      when others then
        raise;
    end;


    IF (resource_id IS NULL)
    THEN
        tmp_str := '<tr><td headers=h1 class="binContentCell">'
		    || FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_NO_RESOURCE_ID_ALERTS')
			|| '</td></tr>';
        dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
        dbms_lob.writeappend(res_clob,length(newln), newln);
    ELSE

        AMV_MYCHANNEL_GRP.Get_ItemsPerUser(p_api_version=>1.0,
                                       p_init_msg_list=>'T',
                                       x_return_status=>x_return_status,
                                       x_msg_count =>x_msg_count,
                                       x_msg_data => x_msg_data,
                                       p_check_login_user => 'F',
                                       p_user_id => resource_id,
                                       p_request_obj => request_obj,
                                       x_return_obj => return_obj,
                                       x_items_array => items_array);

        --dbms_output.put_line ('got items for user' || resource_id);
        if NOT (x_return_status = FND_API.G_RET_STS_SUCCESS)
        THEN
		   x_return_status := FND_API.G_RET_STS_SUCCESS;
           tmp_str := '<tr><td headers=h1 class="binContentCell">'
		    || FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR')
			|| '</td></tr>';
          dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
          dbms_lob.writeappend(res_clob,length(newln), newln);
		  l_more_msg_data := TRUE;

        ELSIF (return_obj.TOTAL_RECORD_COUNT = 0)
        then
          no_items_fnd := '<tr><td headers=h1 class="binContentCell">'
		    || FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_NO_ITEMS_FOUND')
			|| '</td></tr>';
          dbms_lob.writeappend(res_clob,length(no_items_fnd),no_items_fnd);
          dbms_lob.writeappend(res_clob,length(newln), newln);

        ELSE
          --dbms_output.put_line('No of items'||items_array.count);

          for i IN 1 .. items_array.COUNT LOOP
             AMV_ITEM_PUB.get_item(p_api_version => 1.0,
                          p_init_msg_list => 'T',
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_check_login_user => 'F',
                          p_item_id => items_array(i).id,
                          x_item_obj => item_object,
                          x_file_array => item_file_array,
                          x_persp_array => item_persp_array,
                          x_author_array => item_author_array,
                          x_keyword_array => item_keyword_array);

              if NOT (x_return_status = FND_API.G_RET_STS_SUCCESS)
              THEN
			     x_return_status := FND_API.G_RET_STS_SUCCESS;
                 --dbms_output.put_line('Error while getting Item for this user');
                 tmp_str := '<tr><td headers=h1 class="binContentCell">'
		            || FND_MESSAGE.GET_STRING('IBU', 'IBU_HOM_ITEMS_ERROR')
			        || '</td></tr>';
				 dbms_lob.writeappend(res_clob,length(tmp_str),tmp_str);
				 dbms_lob.writeappend(res_clob,length(newln), newln);
				 l_more_msg_data := TRUE;
              ELSE

                 --dbms_output.put_line('Item name='||items_array(i).name);
                 --dbms_output.put_line('Item id='||items_array(i).id);
          --dbms_output.put_line('Item type='||items_array(i).type);

                 dbms_lob.writeappend(res_clob, 4,'<tr>');
                 dbms_lob.writeappend(res_clob, length(newln),newln);

                 if (item_object.item_type like 'URL_ITEM') then
                   -- tmp_str := '<td  class="binContentCell"> <li><a href="http://' ||item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                   if ( instr(item_object.url_string,'http://') =0  ) then
                     tmp_str := '<td  headers=h1 class="binContentCell"><li><a href="http://' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                   else
                     tmp_str := '<td  headers=h1 class="binContentCell"><li><a href="' || item_object.url_string|| '" target="new">' || item_object.item_name || '</a> </td>';
                   end if;

                   dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                   dbms_lob.writeappend(res_clob, length(newln), newln);

                 elsif item_object.item_type like 'FILE_ITEM' then
                   tmp_str := '<td  headers=h1 class="binContentCell"><li><a href="ibuzbot.jsp?itemid=' || item_object.item_id || '" >' || item_object.item_name || '</a> </td>';

                   /* tmp_str := '<td  class="binContentCell"> <li><a href="http://' ||DETAIL_URL||'?itemid=' || item_object.item_id || '" target="new">' || item_object.item_name || '</a> </td>'; */
                   dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                   dbms_lob.writeappend(res_clob, length(newln), newln);

                 else
                   tmp_str := '<td  class="binContentCell"><li><a href="ibuzbot.jsp?itemid=' || item_object.item_id || '">' || item_object.item_name || '</a> </td>';

                   /* tmp_str := '<td  class="binContentCell"> <li><a href="http://' ||DETAIL_URL|| '?itemid=' || item_object.item_id || '" target="new">' || item_object.item_name || '</a> </td>'; */
                   dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
                   dbms_lob.writeappend(res_clob, length(newln), newln);
	             end if;
                 dbms_lob.writeappend(res_clob,5,'</tr>');
				 dbms_lob.writeappend(res_clob, length(newln), newln);

			  END IF;
          end loop;

          -- more link
          if  return_obj.TOTAL_RECORD_COUNT > batch_size then
            dbms_lob.writeappend(res_clob,4,'<tr>');
		    dbms_lob.writeappend(res_clob, length(newln), newln);
            tmp_str := '  <td  headers=h1 class="binContentCell" headers="c1" align=right><a href="' || l_detail_url || '">' || l_more || '</a> </td>';
            dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
	    	dbms_lob.writeappend(res_clob, length(newln), newln);
            dbms_lob.writeappend(res_clob,5,'</tr>');
		    dbms_lob.writeappend(res_clob, length(newln), newln);
		  end if;

	   END IF;  -- if NOT (x_return_status = FND_API.G_RET_STS_SUCCESS)

     END IF ;   --  IF (resource_id IS NULL)

	 if l_more_msg_data = TRUE then
	    -- need to add more error messages to clob
		l_msg_index := 1;
		WHILE x_msg_count > 0 LOOP
		    l_msg_data := FND_MSG_PUB.GET(
						l_msg_index,
						FND_API.G_FALSE
						);
			tmp_str := '<tr><td headers=h1 class="binContentCell">' || l_msg_data || '</td></tr>';
		    dbms_lob.writeappend(res_clob, length(tmp_str), tmp_str);
			dbms_lob.writeappend(res_clob, length(newln), newln);
		    l_msg_index := l_msg_index + 1;
		    x_msg_count := x_msg_count - 1;
		END LOOP;
	 end if;

     -- Bin Content footer
     dbms_lob.writeappend(res_clob, 8, '</table>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 5, '</td>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 5, '</tr>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
     dbms_lob.writeappend(res_clob, 8, '</table>');
     dbms_lob.writeappend(res_clob,length(newln), newln);
/*
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
   end get_html;
end ibu_alert_bin;


/
