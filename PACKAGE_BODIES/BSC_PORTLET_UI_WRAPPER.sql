--------------------------------------------------------
--  DDL for Package Body BSC_PORTLET_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PORTLET_UI_WRAPPER" AS
/* $Header: BSCPORWB.pls 120.4 2007/02/08 14:31:26 ppandey ship $ */

G_PKG_NAME              varchar2(30) := 'BSC_PORTLET_UI_WRAPPER';

/************************************************************************************
************************************************************************************/

FUNCTION Encode_String(
  p_string IN VARCHAR2
 ,p_escape IN VARCHAR2 := '%'
 ,p_reserved IN VARCHAR2 := '%=&;'
 ,p_encoded IN VARCHAR2 := 'PEAS'
) RETURN VARCHAR2 IS
  l_string VARCHAR2(32000);
  l_char VARCHAR(5);
  l_offset INTEGER;
BEGIN
  IF p_string IS NULL THEN
    RETURN NULL;
  END IF;

  FOR i IN 1..length(p_string) LOOP
    l_char := substr(p_string, i, 1);
    l_offset := instr(p_reserved, l_char);

    IF l_offset > 0 THEN
      l_string := l_string || p_escape || substr(p_encoded, l_offset, 1);
    ELSE
      l_string := l_string || l_char;
    END IF;
  END LOOP;

  RETURN l_string;
END Encode_String;

/************************************************************************************
************************************************************************************/

FUNCTION Clean_String(
  p_string  IN VARCHAR2
) RETURN VARCHAR2 IS

  l_string  VARCHAR2(32700);

BEGIN
  -- Clean enclosing single quotes
  l_string := RTRIM(LTRIM(p_string, ''''), '''');

  RETURN l_string;

END Clean_String;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Page_Params(
  p_user_id     IN NUMBER
 ,p_page_id             IN VARCHAR2
 ,x_page_params     OUT NOCOPY VARCHAR2
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) IS

  l_page_session_rec    BIS_PMV_PARAMETERS_PUB.page_session_rec_type;
  l_page_param_tbl  BIS_PMV_PARAMETERS_PUB.parameter_tbl_type;
  i             NUMBER;

  TYPE CursorType IS REF CURSOR;
  l_cursor  CursorType;
  l_sql     VARCHAR2(32000);

  l_parameter_name  VARCHAR2(32000);
  l_parameter_value VARCHAR2(32000);
  l_parameter_description VARCHAR2(32000);

  l_dimension       VARCHAR2(100) := 'TIME_COMPARISON_TYPE';
  l_attribute_name  VARCHAR2(100) := 'AS_OF_DATE';

BEGIN

  FND_MSG_PUB.Initialize;

  l_page_session_rec.user_id := TO_CHAR(p_user_id);
  l_page_session_rec.page_id := p_page_id;

  BIS_PMV_PARAMETERS_PUB.RETRIEVE_PAGE_PARAMETERS(
    p_page_session_rec => l_page_session_rec
   ,x_page_param_tbl => l_page_param_tbl
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data);

  x_page_params := NULL;
  FOR i IN 1..l_page_param_tbl.COUNT LOOP
    IF x_page_params IS NOT NULL THEN
      x_page_params := x_page_params || '&';
    END IF;

    x_page_params := x_page_params ||
      Encode_String(l_page_param_tbl(i).parameter_name) || '=' ||
      Encode_String(Clean_String(l_page_param_tbl(i).parameter_value)) || ';' ||
      Encode_String(l_page_param_tbl(i).parameter_description);
  END LOOP;

  -- This is a workaround to get TIME_COMPARISON_PARAMETER. There is a open bug#2609475
  -- to PMV in order to include it in the BIS_PMV_PARAMETERS_PUB.RETRIEVE_PAGE_PARAMETERS
  l_sql := 'SELECT attribute_name, session_value, session_description'||
           ' FROM bis_user_attributes'||
           ' WHERE user_id = :1 AND page_id = :2 AND dimension = :3';
  OPEN l_cursor FOR l_sql USING p_user_id, p_page_id, l_dimension;
  FETCH l_cursor INTO l_parameter_name, l_parameter_value, l_parameter_description;
  IF l_cursor%FOUND THEN
    IF x_page_params IS NOT NULL THEN
      x_page_params := x_page_params || '&';
    END IF;

    x_page_params := x_page_params ||
      Encode_String(l_parameter_name) || '=' ||
      Encode_String(Clean_String(l_parameter_value)) || ';' ||
      Encode_String(l_parameter_description);

  END IF;
  CLOSE l_cursor;

  l_sql := 'SELECT attribute_name, session_value, session_description'||
           ' FROM bis_user_attributes'||
           ' WHERE user_id = :1 AND page_id = :2 AND attribute_name = :3';
  OPEN l_cursor FOR l_sql USING p_user_id, p_page_id, l_attribute_name;
  FETCH l_cursor INTO l_parameter_name, l_parameter_value, l_parameter_description;
  IF l_cursor%FOUND THEN
    IF x_page_params IS NOT NULL THEN
      x_page_params := x_page_params || '&';
    END IF;

    x_page_params := x_page_params ||
      Encode_String(l_parameter_name) || '=' ||
      Encode_String(Clean_String(l_parameter_value)) || ';' ||
      Encode_String(l_parameter_description);

  END IF;
  CLOSE l_cursor;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Get_Page_Params;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Ranking_Parameter (
 p_page_id            IN    VARCHAR2
,p_user_id        IN    NUMBER
,x_ranking_param      OUT NOCOPY   VARCHAR2
,x_return_status      OUT NOCOPY   VARCHAR2
,x_msg_count          OUT NOCOPY   NUMBER
,x_msg_data           OUT NOCOPY   VARCHAR2
) IS

BEGIN

  FND_MSG_PUB.Initialize;

  BIS_PMV_PORTAL_UTIL_PUB.GET_RANKING_PARAMETER(
    p_page_id => p_page_id,
        p_user_id => TO_CHAR(p_user_id)
    ,x_ranking_param => x_ranking_param
    ,x_return_Status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Get_Ranking_Parameter;

/************************************************************************************
************************************************************************************/

PROCEDURE Validate_Responsibility(
 p_user_id      IN NUMBER
,p_resp_id      IN NUMBER
,x_valid        OUT NOCOPY VARCHAR2
,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data         OUT NOCOPY VARCHAR2
) IS

    l_count NUMBER := 0;

BEGIN
    x_valid := 'Y';

    -- This part validates that the login user has access to the
    -- responsibility associated to the portlet

    SELECT
        count(*)
    INTO
        l_count
    FROM
    FND_USER_RESP_GROUPS fnd,
    FND_RESPONSIBILITY fr
    WHERE
    fnd.USER_ID = p_user_id AND
        fnd.RESPONSIBILITY_ID = p_resp_id AND
        fnd.RESPONSIBILITY_ID = fr.RESPONSIBILITY_ID AND
    SYSDATE BETWEEN fr.START_DATE AND NVL(fr.END_DATE, SYSDATE) AND
    SYSDATE BETWEEN fnd.START_DATE AND NVL(fnd.END_DATE, SYSDATE);

    IF (l_count = 0) THEN
        x_valid := 'N';
        RETURN;
    END IF;

    /* BUG 3579794 -- don't limit resp to AppId 271
    -- Now validate that the user/responsibility is still valid in BSC
    SELECT
        count(*)
    INTO
        l_count
    FROM
        BSC_USER_RESPONSIBILITY_V
    WHERE
        user_id = p_user_id AND
        responsibility_id = p_resp_id;

    IF (l_count = 0) THEN
        x_valid := 'N';
        RETURN;
    END IF; */


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
END Validate_Responsibility;

/************************************************************************************
************************************************************************************/

PROCEDURE Show_Info_Page(
 p_info_key IN VARCHAR2
) IS
    l_url       VARCHAR2(2000);
    l_session_id        VARCHAR2(80);
    l_transaction_id    NUMBER;
    l_dbc       VARCHAR2(2000);
    l_language_code VARCHAR2(2000);
BEGIN

    IF icx_sec.validateSession THEN

        l_session_id := ICX_SEC.g_session_id; --pass g_session_id
        l_transaction_id := icx_sec.createTransaction(l_session_id);
        l_dbc := FND_WEB_CONFIG.DATABASE_ID;
        l_language_code := icx_sec.g_language_code;

        l_url := RTRIM(LTRIM(fnd_profile.value('APPS_FRAMEWORK_AGENT')));
        IF SUBSTRB(l_url, -1, 1) <> '/' THEN
            l_url := l_url||'/';
        END IF;
        l_url := l_url||'OA_HTML/OA.jsp'||
                 '?akRegionCode=BSC_PORTLET_INFO_PGE'||'&'||'akRegionApplicationId=271'||
                 '&'||'dbc='||l_dbc||'&'||'transactionid='||l_transaction_id||'&'||'language_code='||l_language_code||
                 '&'||'retainAM=Y'||'&'||'infoKey='||bis_utilities_pvt.escape_html(p_info_key);

        htp.p('<html><body onload="window.location.replace('''||l_url|| ''');">' ||
              '</body></html>');

    END IF;

EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);

END Show_Info_Page;

/************************************************************************************
************************************************************************************/
PROCEDURE Show_Custom_View_Image(
 p_tab_code IN VARCHAR2,
 p_tab_view IN VARCHAR2,
 p_resp_id  IN VARCHAR2,
 p_mime_type IN VARCHAR2 := 'image/gif'
) IS
  doc   blob;
BEGIN
  IF icx_sec.validateSession THEN
    SELECT bsi.file_body
    INTO doc
    FROM bsc_sys_images bsi, bsc_sys_images_map_vl bsim, bsc_user_tab_access bta
    WHERE bsim.image_id = bsi.image_id AND bsim.source_type = 1
    AND bsim.source_code = p_tab_code AND bsim.type = p_tab_view
    AND bsim.source_code = bta.tab_id AND bta.responsibility_id = p_resp_id;

    owa_util.mime_header(p_mime_type, FALSE);
    htp.p('Content-length: ' || dbms_lob.getlength(doc));
    owa_util.http_header_close;
    wpg_docload.download_file(doc);
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Custom View Not Found');
    htp.headClose;
    htp.bodyOpen;
    htp.hr;
    htp.header(nsize=>1, cheader=>'Custom View Not Found');
    htp.hr;
    htp.bodyClose;
    htp.htmlClose;
END Show_Custom_View_Image;


/************************************************************************************
************************************************************************************/

PROCEDURE Apply_CustomView_Parameters (
  p_user_id IN VARCHAR2,
  p_reference_path IN VARCHAR2,
  p_resp_id IN VARCHAR2,
  p_tab_id IN VARCHAR2,
  p_view_id IN VARCHAR2,
  p_portlet_name IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
) IS

  l_count   NUMBER;
  l_parameters  VARCHAR2(2000);

  l_sql     VARCHAR2(32000);
  TYPE CursorType IS REF CURSOR;
  l_cursor  CursorType;

  l_plug_id NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;

  l_count := 0;

  -- Validate that all parameter are not null
  IF p_user_id IS NULL OR  p_reference_path IS NULL OR p_resp_id IS NULL OR
     p_tab_id IS NULL OR p_view_id IS NULL OR p_portlet_name IS NULL THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_CV_POR_CUST_INVALID_PARAMS');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get the plug_id. We need to continue using it because
  -- it is part of the key of the table.
  l_sql := 'SELECT plug_id FROM bsc_user_kpigraph_plugs'||
           ' WHERE reference_path = :1';
  OPEN l_cursor FOR l_sql USING p_reference_path;
  FETCH l_cursor INTO l_plug_id;
  IF l_cursor%NOTFOUND THEN
    SELECT ICX_PAGE_PLUGS_S.NEXTVAL
    INTO l_plug_id
    FROM sys.dual;
  END IF;
  CLOSE l_cursor;


  SELECT
      COUNT(*)
  INTO
      l_count
  FROM
      bsc_user_kpigraph_plugs
  WHERE
      -- user_id = p_user_id AND     -- BUG 4136961, user level customization is not supported.
      reference_path = p_reference_path;

  l_parameters := 'pTabId='||p_tab_id||'&'||'pViewId='||p_view_id;

  IF l_count > 0 THEN
      -- Update record
      UPDATE
          bsc_user_kpigraph_plugs
      SET
          responsibility_id = p_resp_id,
          parameter_string = l_parameters,
          last_update_date = SYSDATE,
          last_updated_by = p_user_id
      WHERE
          -- user_id = p_user_id AND     -- BUG 4136961, user level customization is not supported.
          reference_path = p_reference_path;
  ELSE
      -- Insert
      INSERT INTO bsc_user_kpigraph_plugs (
          user_id,
          plug_id,
          reference_path,
          responsibility_id,
          indicator,
          parameter_string,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
       ) VALUES (
          -1,                           -- BUG 4136961, user level customization is not supported.
          l_plug_id,
          p_reference_path,
          p_resp_id,
          0,
          l_parameters,
          SYSDATE,
          p_user_id,
          SYSDATE,
          p_user_id,
          p_user_id
       );
  END IF;

  -- Update display name
  UPDATE icx_portlet_customizations
  SET    title = p_portlet_name, caching_key = to_char(to_number(caching_key)+1)
  WHERE  reference_path = p_reference_path;

  COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
END Apply_CustomView_Parameters;

/************************************************************************************
************************************************************************************/



PROCEDURE Apply_Graph_Parameters (
  p_user_id IN VARCHAR2,
  p_reference_path IN VARCHAR2,
  p_resp_id IN VARCHAR2,
  p_tab_id IN VARCHAR2,
  p_kpi_code IN VARCHAR2,
  p_view_id IN VARCHAR2,
  p_portlet_name IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
) IS

  l_count   NUMBER;
  l_parameters  VARCHAR2(2000);

  l_sql     VARCHAR2(32000);
  TYPE CursorType IS REF CURSOR;
  l_cursor  CursorType;

  l_plug_id NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;

  l_count := 0;

  -- Validate that all parameter are not null
  IF p_user_id IS NULL OR  p_reference_path IS NULL OR p_resp_id IS NULL OR
     p_tab_id IS NULL OR p_kpi_code IS NULL OR p_portlet_name IS NULL THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_CV_POR_CUST_INVALID_PARAMS');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get the plug_id. We need to continue using it because
  -- it is part of the key of the table.
  l_sql := 'SELECT plug_id FROM bsc_user_kpigraph_plugs'||
           ' WHERE reference_path = :1';
  OPEN l_cursor FOR l_sql USING p_reference_path;
  FETCH l_cursor INTO l_plug_id;
  IF l_cursor%NOTFOUND THEN
    SELECT ICX_PAGE_PLUGS_S.NEXTVAL
    INTO l_plug_id
    FROM sys.dual;
  END IF;
  CLOSE l_cursor;


  SELECT
      COUNT(*)
  INTO
      l_count
  FROM
      bsc_user_kpigraph_plugs
  WHERE
      -- user_id = p_user_id AND     -- BUG 4136961, user level customization is not supported.
      reference_path = p_reference_path;

  l_parameters := 'pTabId='||p_tab_id;

  IF l_count > 0 THEN
      -- Update record
      UPDATE
          bsc_user_kpigraph_plugs
      SET
          responsibility_id = p_resp_id,
          indicator = p_kpi_code,
          parameter_string = l_parameters,
          last_update_date = SYSDATE,
          last_updated_by = p_user_id
      WHERE
          -- user_id = p_user_id AND     -- BUG 4136961, user level customization is not supported.
          reference_path = p_reference_path;
  ELSE
      -- Insert
      INSERT INTO bsc_user_kpigraph_plugs (
          user_id,
          plug_id,
          reference_path,
          responsibility_id,
          indicator,
          parameter_string,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
       ) VALUES (
          -1,               -- BUG 4136961, user level customization is not supported.
          l_plug_id,
          p_reference_path,
          p_resp_id,
          p_kpi_code,
          l_parameters,
          SYSDATE,
          p_user_id,
          SYSDATE,
          p_user_id,
          p_user_id
       );

       UPDATE icx_portlet_customizations
       SET plug_id = l_plug_id
       WHERE reference_path = p_reference_path;

  END IF;

  -- Update display name
  UPDATE icx_portlet_customizations
  SET    title = p_portlet_name, caching_key = to_char(to_number(caching_key)+1)
  WHERE  reference_path = p_reference_path;

  COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
END Apply_Graph_Parameters;

/************************************************************************************
************************************************************************************/

PROCEDURE Apply_Kpi_List_Parameters(
 p_user_id IN NUMBER,
 p_plug_id IN NUMBER,
 p_reference_path IN VARCHAR2,
 p_resp_id IN NUMBER,
 p_details_flag IN NUMBER,
 p_group_flag IN NUMBER,
 p_kpi_measure_details_flag IN NUMBER,
 p_createy_by IN NUMBER,
 p_last_updated_by IN NUMBER,
 p_porlet_name IN VARCHAR2,
 p_number_array IN BSC_NUM_LIST,
 p_o_ret_status OUT NOCOPY NUMBER,
 x_return_status OUT NOCOPY VARCHAR2,
 x_msg_count OUT NOCOPY NUMBER,
 x_msg_data OUT NOCOPY VARCHAR2
) IS

  l_count   NUMBER;

  l_sql     VARCHAR2(32000);
  TYPE CursorType IS REF CURSOR;
  l_cursor  CursorType;

  l_plug_id NUMBER;

  l_errmsg VARCHAR2(2000) := bsc_portlet_util.MSGTXT_SUCCESS;
BEGIN

  FND_MSG_PUB.Initialize;

  l_count := 0;

  -- Validate that all parameter are not null

  --DBMS_OUTPUT.PUT_LINE('Before null check');

  IF  p_user_id IS NULL OR  p_reference_path IS NULL OR  p_resp_id IS NULL OR
      p_details_flag IS NULL OR  p_group_flag IS NULL OR p_porlet_name IS NULL OR  p_number_array IS NULL
      THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_CV_POR_CUST_INVALID_PARAMS');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get the plug_id. We need to continue using it because
  -- it is part of the key of the table.
  l_sql := 'SELECT plug_id from bsc_user_kpilist_plugs'||
           ' WHERE reference_path = :1';

  l_plug_id := p_plug_id;

  OPEN l_cursor FOR l_sql USING p_reference_path;
  FETCH l_cursor INTO l_plug_id;
  IF l_cursor%NOTFOUND THEN
    SELECT ICX_PAGE_PLUGS_S.NEXTVAL
    INTO l_plug_id
    FROM sys.dual;
  END IF;
  CLOSE l_cursor;

  --DBMS_OUTPUT.PUT_LINE('l_plug_id-->'||l_plug_id);

  -- Temp error message
   l_errmsg := BSC_PORTLET_KPILISTCUST.set_customized_data_private_n(
   p_user_id , l_plug_id , p_reference_path , p_resp_id ,
   p_details_flag , p_group_flag , p_kpi_measure_details_flag, p_createy_by , p_last_updated_by ,
   p_porlet_name , p_number_array , p_o_ret_status );

  COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
END Apply_Kpi_List_Parameters;

/************************************************************************************
************************************************************************************/

PROCEDURE checkUpdateCustView(
  p_commit	IN	VARCHAR2,
  p_user_id	IN	VARCHAR2,
  p_reference_path IN	VARCHAR2,
  p_tab_id	IN	VARCHAR2,
  p_view_id	IN	VARCHAR2,
  p_resp_id 	IN 	VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
 ) IS

   last_update_date_from_designer DATE := null;
   last_update_date_from_portlet DATE := null;
   l_parameters  VARCHAR2(2000);
   l_commit VARCHAR2(10);

 BEGIN


  IF(p_commit IS NULL ) THEN
      l_commit := FND_API.G_FALSE;
   ELSE
      l_commit  := p_commit;
  END IF;


  SELECT
     last_update_date
  INTO
     last_update_date_from_designer
  FROM
     BSC_TAB_VIEWS_B
  WHERE
     tab_id = p_tab_id AND
     tab_view_id = p_view_id;


  SELECT
     last_update_date
  INTO
     last_update_date_from_portlet
  FROM
     bsc_user_kpigraph_plugs
  WHERE
     user_id = p_user_id AND
     reference_path = p_reference_path ;


 IF(last_update_date_from_designer IS NOT NULL AND last_update_date_from_portlet IS NOT NULL AND p_resp_id IS NOT NULL) THEN

   IF(last_update_date_from_designer > last_update_date_from_portlet) THEN

        l_parameters := 'pTabId='||p_tab_id||'&'||'pViewId='||p_view_id;

       --Update bsc_user_kpigraph_plugs
	UPDATE
		bsc_user_kpigraph_plugs
	    SET
		responsibility_id = p_resp_id,
		parameter_string = l_parameters,
		last_update_date = SYSDATE,
		last_updated_by = p_user_id
	    WHERE
		user_id = p_user_id AND
		reference_path = p_reference_path;


	--Upadte icx customizations
	UPDATE icx_portlet_customizations
	SET    caching_key = to_char(to_number(NVL(caching_key, 0))+1)
	WHERE  reference_path = p_reference_path;

      IF(l_commit = FND_API.G_TRUE) THEN
        COMMIT;
      END IF;

   END IF;
 END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       rollback;
       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       rollback;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END checkUpdateCustView;
/************************************************************************************
************************************************************************************/

FUNCTION Get_CustView_Measure_Name(
    p_region_code       IN          VARCHAR
    ,p_dataset_id        IN          NUMBER
) RETURN VARCHAR2 IS

  l_meas_disp_name AK_REGION_ITEMS_VL.attribute_label_long%TYPE;
  l_region_code VARCHAR2(200) := NULL;

BEGIN
  IF ( p_region_code = 'NULL' ) THEN
    l_region_code := NULL;
  ELSE
    l_region_code := p_region_code;
  END IF;
  BSC_CUSTOM_VIEW_UI_WRAPPER.Get_Measure_Display_Name(l_region_code, p_dataset_id, l_meas_disp_name);
  RETURN l_meas_disp_name;

EXCEPTION
WHEN OTHERS THEN
    RETURN 'NULL';
END Get_CustView_Measure_Name;

END BSC_PORTLET_UI_WRAPPER;

/
