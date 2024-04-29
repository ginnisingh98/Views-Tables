--------------------------------------------------------
--  DDL for Package Body BIS_LOV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_LOV_PVT" AS
/* $Header: BISVLOVB.pls 115.25 2002/12/16 10:25:56 rchandra ship $ */
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--      BISVLOVB.pls
--
--  DESCRIPTION
--      Body of list of values utilities package
--
--  HISTORY
--
--  MAR-2000 irchen created
--  Sep-2000 JPRABHUD Changed the Get_List method to show LOV
--

-- Global Variables
--
G_DEFAULT_SIZE CONSTANT VARCHAR2(100) := '20';
G_NBSP         CONSTANT VARCHAR2(100) := '&'||'nbsp';

Procedure null_alert
is
begin
  htp.p('
    function null_alert(value, alert_text) {
      if (value == "") {
        alert(alert_text);
        return true;
      } else { return false;}
    }
    ');
end null_alert;

Procedure Dependent_LOVFunction
( p_lov_func_name       in varchar2
, p_attribute_app_id    in NUMBER
, p_attribute_code      in varchar2
, p_region_app_id       in number
, p_region_code         in varchar2
, p_form_name           in varchar2
, p_frame_name          in varchar2 default null
, p_where_clause        in varchar2 default null
, p_null_variable       in varchar2 default null
, p_null_alert_text     in varchar2 default null
)
IS
begin

  htp.p('
    function '||p_lov_func_name||'{
      if (!null_alert('||p_null_variable||','||p_null_alert_text||')){
        var l_where_clause;

        l_where_clause = '||p_where_clause||';
        //alert(l_where_clause);
        LOV("'|| p_attribute_app_id
              || '","'
              || p_attribute_code
              || '","'
              || p_region_app_id
              || '","'
              || p_region_code
              || '","'
              || p_form_name
              || '","","",'
              || 'l_where_clause'
              || ');
      }
    }
    ');
end Dependent_LOVFunction;

Procedure get_List
( p_attributes        IN  varchar2 default null
, p_name              IN  varchar2 default null
, p_selected_value    IN  varchar2 default null
, p_no_selection_flag IN  varchar2 default FND_API.G_FALSE
, p_list              IN  value_id_table
, x_list_str          OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS
l_choice_list varchar2(32000);
l_selected    varchar2(320);
l_list        value_id_table;
l_count       number;

BEGIN

  IF(p_no_selection_flag = FND_API.G_TRUE) THEN
      l_list(1).id :=  DSP_NO_SELECTION_STRING;
      l_list(1).value :=  DSP_NO_SELECTION_STRING;
  END IF;

  FOR i IN 1..p_list.COUNT LOOP
    l_count := l_list.COUNT + 1;
    l_list(l_count) := p_list(i);
  END LOOP;

  l_choice_list := htf.formSelectOpen( cname       => p_name
  	           		     , cattributes => p_attributes
  		   		     );
  x_list_str(x_list_str.count + 1) := l_choice_list;

  FOR l_ind in 1 .. l_list.count LOOP
    l_selected := NULL;
    if(p_selected_value is not null and p_selected_value= l_list(l_ind).id)then
      l_selected := 'NOTNULL';
    end if;
    l_choice_list := htf.formSelectOption
           	     ( cvalue  	 => l_list(l_ind).value
           	     , cselected   => l_selected
           	     , cattributes => 'VALUE="' || l_list(l_ind).id|| '"'
                     );
    x_list_str(x_list_str.count + 1) := l_choice_list;
  END LOOP;

  l_choice_list := htf.formSelectClose;

  x_list_str(x_list_str.count + 1) := l_choice_list;
End get_List;

Procedure get_List
( p_attributes        IN  varchar2 default null
, p_name              IN  varchar2 default null
, p_selected_value    IN  varchar2 default null
, p_no_selection_flag IN  varchar2 default FND_API.G_FALSE
, p_list              IN  value_id_table
, p_label             IN  varchar2
, x_list_str          OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS
l_choice_list varchar2(32000);
l_selected    varchar2(320);
l_list_str    BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
BEGIN

  x_list_str(x_list_str.count + 1) := htf.tableOpen;
  x_list_str(x_list_str.count + 1) := htf.tableRowOpen;
  x_list_str(x_list_str.count + 1) := htf.tableData( cvalue => p_label
                                                   , calign => 'RIGHT'
                                                   );

  get_List( p_attributes        => p_attributes
  	  , p_name              => p_name
  	  , p_selected_value    => p_selected_value
          , p_no_selection_flag => p_no_selection_flag
  	  , p_list              => p_list
  	  , x_list_str          => l_list_str
          );

  x_list_str(x_list_str.count + 1) := '<TD>';
  for i in 1 .. l_list_str.count loop
    x_list_str(x_list_str.count + 1) := l_list_str(i);
  end loop;
  x_list_str(x_list_str.count + 1) := '</TD>';

  x_list_str(x_list_str.count + 1) := htf.tableRowClose;
  x_list_str(x_list_str.count + 1) := htf.tableClose;

End get_List;
--
procedure Get_List
( p_attribute_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute_code      IN VARCHAR2
, p_attribute_name      IN VARCHAR2
, p_region_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region_code         IN VARCHAR2
, p_form_name           IN VARCHAR2
, p_where_clause        IN VARCHAR2  := NULL
, p_selected_value      IN  BIS_LOV_PVT.value_id_record
, p_func                IN  VARCHAR2 := NULL
, p_size                IN  NUMBER   := 20
, x_list_str            OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS
  l_br       VARCHAR2(10) := '<BR>';
  l_list_str VARCHAR2(32000);
  l_lov_str VARCHAR2(32000);
  l_title    VARCHAR2(32000);
  l_prompts  icx_util.g_prompts_table;
BEGIN

/*
  htp.p('In get list no label'||l_br);
  htp.p('p_attribute_app_id   :'||p_attribute_app_id||l_br);
  htp.p('p_attribute_name     :'||p_attribute_name||l_br);
  htp.p('p_attribute_code     :'||p_attribute_code||l_br);
  htp.p('p_region_app_id      :'||p_region_app_id||l_br);
  htp.p('p_region_code        :'||p_region_code||l_br);
  htp.p('p_form_name          :'||p_form_name||l_br);
  htp.p('p_frame_name         :'||p_frame_name||l_br);
  htp.p('p_where_clause       :'||p_where_clause||l_br||l_br);
*/

  l_list_str := htf.tableOpen;--(cattributes=> 'BORDER="0"');
  x_list_str(x_list_str.count + 1) := l_list_str;
  --changing the curl parameter--------------
  l_lov_str := 'javascript:LOV(' || '''' || p_attribute_app_id || '''' ||
                              ','|| '''' || p_attribute_name ||  '''' ||
                              ','|| ''''|| p_region_app_id || '''' ||
                              ',' || '''' || p_region_code ||   '''' ||
                              ',' || '''' ||p_form_name || '''' ||
                              ',' ||
                              '''''' ||
                              ',' || '''' ||  p_where_clause ||'''' ||
                              ',' ||
                              ''''''
                              || ')';
    l_list_str := htf.formOpen
                ( curl        => l_lov_str
                , cattributes => 'NAME="'||p_form_name||'"'
                );

  ------------
  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.tableRowOpen;
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Create form
  --
  -- Text Area for user entry
  --
  l_list_str := htf.tableData
              ( cvalue => htf.formText
                        ( cname       => p_attribute_name
                        , cattributes => 'class=normal'
                        , csize       => p_size
                        , cvalue      => p_selected_value.value
                        )
--              , ccolspan => '1'
--              , calign   => 'LEFT'
              );
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Hidden value to hold ID
  --
  l_list_str := htf.formHidden( cname  => p_attribute_code
                              , cvalue => p_selected_value.id
                              );
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Button to invoke LOV
  --
  if (p_func is not null) then
    icx_util.getPrompts(601,'ICX_LOV',l_title,l_prompts);
    l_list_str := htf.anchor
                  ( p_func
                  , htf.img( '/OA_MEDIA/FNDILOV.gif'
                           , 'CENTER'
                           , icx_util.replace_alt_quotes( l_title)
                           , ''
                           , 'BORDER=0 WIDTH=23 HEIGHT=21'
                           )
                  , ''
                  , 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_title)||''';return true"'
                  );

    l_list_str := htf.tableData( cvalue => l_list_str);
  else
    l_list_str := htf.tableData
                          ( cvalue =>
                               ICX_UTIL.LOVbutton
                             ( c_attribute_app_id  => p_attribute_app_id
                             , c_attribute_code    => p_attribute_name
                             , c_region_app_id     => p_region_app_id
                             , c_region_code       => p_region_code
                             , c_form_name         => p_form_name
                             , c_where_clause      => p_where_clause
                             )

--                          , ccolspan => '1'
--                          , calign   => 'LEFT'
                          );
  end if;

  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.tableRowClose;
  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.formClose;
  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.tableClose;
  x_list_str(x_list_str.count + 1) := l_list_str;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Get_List Exception: '||SQLERRM);

END Get_List;

procedure Get_List
( p_attribute_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute_code      IN VARCHAR2
, p_attribute_name      IN VARCHAR2
, p_region_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region_code         IN VARCHAR2
, p_form_name           IN VARCHAR2
, p_label               IN VARCHAR2
, p_where_clause        IN VARCHAR2  := NULL
, p_selected_value      IN  BIS_LOV_PVT.value_id_record
, p_func                IN  VARCHAR2 := NULL
, p_size                IN  NUMBER   := 20
, x_list_str            OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS
  l_br             VARCHAR2(10) := '<BR>';
  l_list_str       VARCHAR2(32000);
  l_list_str2      BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

BEGIN

/*
  htp.p('In get list with label'||l_br);
  htp.p('p_label              :'||p_label||l_br);
  htp.p('p_attribute_app_id   :'||p_attribute_app_id||l_br);
  htp.p('p_attribute_name     :'||p_attribute_name||l_br);
  htp.p('p_attribute_code     :'||p_attribute_code||l_br);
  htp.p('p_region_app_id      :'||p_region_app_id||l_br);
  htp.p('p_region_code        :'||p_region_code||l_br);
  htp.p('p_form_name          :'||p_form_name||l_br);
  htp.p('p_frame_name         :'||p_frame_name||l_br);
  htp.p('p_where_clause       :'||p_where_clause||l_br||l_br);
*/

  l_list_str := htf.tableOpen;--( cattributes => 'BORDER="0"');
  x_list_str(x_list_str.count + 1) := l_list_str;
  l_list_str := htf.tableRowOpen;
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Put label
  --
  l_list_str := htf.tableData
                ( cvalue => p_label
--                , ccolspan => '1'
                , calign   => 'RIGHT'
                , cnowrap => 'YES'
                , cattributes => 'class=normal'
                );
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Build List
  --
  l_list_str := '<TD ALIGN="LEFT">';
  x_list_str(x_list_str.count + 1) := l_list_str;
  BIS_LOV_PVT.Get_List
  ( p_attribute_app_id  => p_attribute_app_id
  , p_attribute_code    => p_attribute_code
  , p_attribute_name    => p_attribute_name
  , p_region_app_id     => p_region_app_id
  , p_region_code       => p_region_code
  , p_form_name         => p_form_name
  , p_where_clause      => p_where_clause
  , p_selected_value    => p_selected_value
  , p_func              => p_func
  , p_size              => p_size
  , x_list_str          => l_list_str2
  );
  for i in 1 .. l_list_str2.count loop
    x_list_str(x_list_str.count + 1) := l_list_str2(i);
  end loop;
  l_list_str := '</TD>';
  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.tableRowClose;
  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.tableClose;
  x_list_str(x_list_str.count + 1) := l_list_str;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Get_List Exception: '||SQLERRM);

END Get_List;

procedure Get_List
( p_attribute1_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute1_code      IN VARCHAR2
, p_attribute1_name      IN VARCHAR2
, p_region1_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region1_code         IN VARCHAR2
, p_form1_name           IN VARCHAR2
, p_where_clause1        IN VARCHAR2  := NULL
, p_selected_value1      IN  BIS_LOV_PVT.value_id_record
, p_func1                IN  VARCHAR2 := NULL
, p_size1                IN  NUMBER   := 20
, p_attribute2_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute2_code      IN VARCHAR2
, p_attribute2_name      IN VARCHAR2
, p_region2_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region2_code         IN VARCHAR2
, p_form2_name           IN VARCHAR2
, p_where_clause2        IN VARCHAR2  := NULL
, p_selected_value2      IN  BIS_LOV_PVT.value_id_record
, p_func2                IN  VARCHAR2 := NULL
, p_size2                IN  NUMBER   := 20
, p_label                IN VARCHAR2  := NULL
, p_separator            IN VARCHAR2  := BIS_UTILITIES_PVT.G_BIS_SEPARATOR
, x_list_str             OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
)
IS
  l_br             VARCHAR2(10) := '<BR>';
  l_list_str       VARCHAR2(32000);
  l_list_str2      BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_nbsp           VARCHAR2(10) := '&'||'nbsp';

BEGIN

/*
  htp.p('In get list 2 with label'||l_br);
  htp.p('p_label              :'||p_label||l_br);
  htp.p('p_attribute1_app_id   :'||p_attribute_app_id||l_br);
  htp.p('p_attribute1_name     :'||p_attribute_name||l_br);
  htp.p('p_attribute1_code     :'||p_attribute_code||l_br);
  htp.p('p_region1_app_id      :'||p_region_app_id||l_br);
  htp.p('p_region1_code        :'||p_region_code||l_br);
  htp.p('p_form1_name          :'||p_form_name||l_br);
  htp.p('p_where_clause1       :'||p_where_clause||l_br||l_br);
  htp.p('p_attribute2_app_id   :'||p_attribute_app_id||l_br);
  htp.p('p_attribute2_name     :'||p_attribute_name||l_br);
  htp.p('p_attribute2_code     :'||p_attribute_code||l_br);
  htp.p('p_region2_app_id      :'||p_region_app_id||l_br);
  htp.p('p_region2_code        :'||p_region_code||l_br);
  htp.p('p_form2_name          :'||p_form_name||l_br);
  htp.p('p_where_clause2       :'||p_where_clause||l_br||l_br);
*/

  l_list_str := htf.tableOpen;
--               ( calign      => 'CENTER'
--               ( cattributes => 'BORDER="1"');
  x_list_str(x_list_str.count + 1) := l_list_str;
  l_list_str := htf.tableRowOpen;
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Left list with label
  --
  l_list_str := '<TD ALIGN="LEFT">';
  x_list_str(x_list_str.count + 1) := l_list_str;

  IF p_label IS NOT NULL THEN

  BIS_LOV_PVT.Get_List
  ( p_attribute_app_id  => p_attribute1_app_id
  , p_attribute_code    => p_attribute1_code
  , p_attribute_name    => p_attribute1_name
  , p_region_app_id     => p_region1_app_id
  , p_region_code       => p_region1_code
  , p_form_name         => p_form1_name
  , p_label             => p_label
  , p_selected_value    => p_selected_value1
  , p_where_clause      => p_where_clause1
  , p_func              => p_func1
  , p_size              => p_size1
  , x_list_str          => l_list_str2
  );
  ELSE

  BIS_LOV_PVT.Get_List
  ( p_attribute_app_id  => p_attribute1_app_id
  , p_attribute_code    => p_attribute1_code
  , p_attribute_name    => p_attribute1_name
  , p_region_app_id     => p_region1_app_id
  , p_region_code       => p_region1_code
  , p_form_name         => p_form1_name
  , p_where_clause      => p_where_clause1
  , p_selected_value    => p_selected_value1
  , p_func              => p_func1
  , p_size              => p_size1
  , x_list_str          => l_list_str2
  );
  END IF;

  for i in 1 .. l_list_str2.count loop
    x_list_str(x_list_str.count + 1) := l_list_str2(i);
  end loop;
  l_list_str := '</TD>';
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Separator
  --
  l_list_str := htf.tableData
                ( cvalue => p_separator
                , ccolspan => '1'
                , calign   => 'CENTER'
                , cattributes => 'class=normal'
                );
  x_list_str(x_list_str.count + 1) := l_list_str;

  -- Right list without label
  --
  l_list_str := '<TD>';
  x_list_str(x_list_str.count + 1) := l_list_str;
  l_list_str2.delete;
  BIS_LOV_PVT.Get_List
  ( p_attribute_app_id  => p_attribute2_app_id
  , p_attribute_code    => p_attribute2_code
  , p_attribute_name    => p_attribute2_name
  , p_region_app_id     => p_region2_app_id
  , p_region_code       => p_region2_code
  , p_form_name         => p_form2_name
  , p_where_clause      => p_where_clause2
  , p_selected_value    => p_selected_value2
  , p_func              => p_func2
  , p_size              => p_size2
  , x_list_str          => l_list_str2
  );
  for i in 1 .. l_list_str2.count loop
    x_list_str(x_list_str.count + 1) := l_list_str2(i);
  end loop;
  l_list_str := '</TD>';
  x_list_str(x_list_str.count + 1) := l_list_str;

  l_list_str := htf.tableRowClose;
  x_list_str(x_list_str.count + 1) := l_list_str;
  l_list_str := htf.tableClose;
  x_list_str(x_list_str.count + 1) := l_list_str;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Get_List Exception: '||SQLERRM);

END Get_List;

--
--
END BIS_LOV_PVT;

/
