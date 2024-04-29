--------------------------------------------------------
--  DDL for Package Body BIS_LOV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_LOV_PUB" as
/* $Header: BISPLOVB.pls 120.3.12010000.4 2015/11/23 06:37:14 saketi ship $ */
g_user_id integer;
g_session_id number;

-- *****************************************************
--        Main - entry point
-- ****************************************************
procedure main
( p_procname      in  varchar2 default NULL
, p_qrycnd        in  varchar2 default NULL
, p_jsfuncname    in  varchar2 default NULl
, p_startnum      in  pls_integer   default NULL
, p_rowcount      in  pls_integer   default NULL
, p_totalcount    in  pls_integer   default NULL
, p_search_str    in  varchar2 default NULL
, p_dim_level_id   in number default NULL
, p_sqlcount      in  varchar2 default NULL
, p_coldata       in  colinfo_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
, p_user_id        in pls_integer default NULL
, x_string        out nocopy VARCHAR2
)
IS
l_startnum              pls_integer;
l_pos1                  pls_integer;
l_titlename             varchar2(32000);
l_history               varchar2(240);
l_message               varchar2(240);
l_ccursor               pls_integer;
l_dummy1                pls_integer;
l_totalcount            pls_integer;
l_colstore              colstore_table;
l_totalpossible         pls_integer;
l_store1                varchar2(32000);
l_store2                varchar2(32000);
l_searchlink            varchar2(32000);
l_datalink              varchar2(32000);
l_buttonslink           varchar2(32000);
l_title                 varchar2(32000) := 'List Of Values: ';
l_head                  varchar2(32000);
l_value                 varchar2(32000);
l_link                  varchar2(32000);
l_disp                  varchar2(32000);
l_sql                   varchar2(32000);
l_search_str            varchar2(32000) := p_search_str;
l_rel_dim_lev_id        varchar2(32000);
l_rel_dim_lev_val_id    varchar2(32000);
l_rel_dim_lev_g_var     varchar2(32000);
l_Z                     varchar2(32000);

l_var number;
l_return_sts VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;
l_sob_id     NUMBER;
l_plug_id    pls_integer;
l_string                 VARCHAR(32000);
l_search_rstr            VARCHAR(32000);
l_data_rstr              VARCHAR(32000);
l_buttons_rstr           VARCHAR(32000);
l_head_tbl                 colstore_table;
l_value_tbl                colstore_table;
l_link_tbl                 colstore_table;
l_disp_tbl                 colstore_table;
l_test_count               NUMBER;
PSQLCOUNT_NOT_NULL_VALUE EXCEPTION;

begin

-- meastmon 09/07/2001 Fix bug#1980577. Workaround Do not encrypt plug_id
--l_plug_id := icx_call.decrypt2(Z);

l_plug_id := Z;
--if icx_sec.validateSession then
-- if ICX_SEC.validatePlugSession(l_plug_id) then

     /*if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
     then
         l_history := '';
     else
         l_history := 'opener.history.go(0);';
     end if;*/

     --commented as giving error

     l_history := ''; --WORKAROUND

  IF p_rel_dim_lev_val_id IS NOT NULL THEN
    setGlobalVar
    ( p_dim_lev_id      => p_rel_dim_lev_id
    , p_dim_lev_val_id  => p_rel_dim_lev_val_id
    , p_dim_lev_g_var   => p_rel_dim_lev_g_var
    , x_return_status   => l_return_sts
    );
  END IF;

  IF p_sqlcount is not null then
  BIS_COLLECTION_UTILITIES.put_line('p_sqlcount is not null and package bis_lov_pub is being used');
  raise  PSQLCOUNT_NOT_NULL_VALUE;
  end if;


    -- If this page is being called the first time
    -- parse the sqlcount to get totalcount
     l_ccursor := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(l_ccursor,p_sqlcount,DBMS_SQL.NATIVE);
     DBMS_SQL.DEFINE_COLUMN(l_ccursor,1,l_totalcount);
     l_dummy1 := DBMS_SQL.EXECUTE_AND_FETCH(l_ccursor);
     DBMS_SQL.COLUMN_VALUE(l_ccursor,1,l_totalcount);
     DBMS_SQL.CLOSE_CURSOR(l_ccursor);

    -- Set certain numbers and names
     l_totalpossible := NVL(p_totalcount,l_totalcount);
     for l_pos1 in p_coldata.FIRST .. p_coldata.COUNT loop
        if (p_coldata(l_pos1).link = FND_API.G_TRUE) then
          l_titlename := p_coldata(l_pos1).header;
          exit;
        end if;
      end loop;

    l_string:= l_string ||'<HEAD>';

    l_string:= l_string ||'<SCRIPT LANGUAGE="Javascript">';

    l_string:= l_string ||'function blank() {';
    l_string:= l_string ||'       return "<HTML><BODY BGCOLOR=#336699></BODY></HTML>"';
    l_string:= l_string ||'        }';

    --  Transfer the clicked URL's name and id to the parent window box
    l_string:= l_string ||'function transfer(name,id) {';
    --l_string := l_string||'alert("name "+name+"  id "+id);';
    l_string:= l_string ||'    parent.opener.parent.'||p_jsfuncname||'(name,id);';
    --l_string := l_string||'alert("before windowclose");';
    l_string:= l_string ||'     window.close();';
    l_string:= l_string ||'  }';

    -- Close the child window and clear all events on parent window
    l_string:= l_string ||'function closeMe() {';
    l_string:= l_string ||'    if (opener){';
    l_string:= l_string ||'       opener.unblockEvents();';
    l_string:= l_string ||'    }';
    l_string:= l_string ||'   window.close();';
    l_string:= l_string ||' }';

    l_string:= l_string ||'</SCRIPT>';
    l_string:= l_string ||'</HEAD>';

    -- Create the main form that communicates with the intermediate proc


    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_qrycnd.value='''||p_qrycnd||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_dim1_lbl.value='''||l_titlename||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_jsfuncname.value='''||p_jsfuncname||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_startnum.value='''||p_startnum||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_rowcount.value='''||p_rowcount||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_totalcount.value='''||p_totalcount||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_search_str.value='''||NVL(p_search_str,c_percent)||''';</SCRIPT>';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.Z.value='||Z||';</SCRIPT>';

    -- Replace the % sign in the sql string with an asterisk
    -- because it tends to dissappear from the URL string
    l_search_str := REPLACE(p_search_str,c_percent,c_asterisk);

    lov_search
    ( p_totalpossible => l_totalpossible
    , p_totalavailable => l_totalcount
    , p_titlename => bis_utilities_pub.encode(l_titlename)
    , p_startnum =>p_startnum
    , p_rowcount => p_rowcount
    , p_search_str => l_search_str
    ,x_string => l_search_rstr
    );

    l_string:= l_string || l_search_rstr;


    for i in p_coldata.FIRST .. p_coldata.COUNT loop
      l_head_tbl(i) := p_coldata(i).header;
      l_value_tbl(i) := p_coldata(i).value;
      l_link_tbl(i) := p_coldata(i).link;
      l_disp_tbl(i) := p_coldata(i).display;

    end loop;


    l_rel_dim_lev_id := l_rel_dim_lev_id ||c_amp
                      ||'p_rel_dim_lev_id='||p_rel_dim_lev_id;
    l_rel_dim_lev_val_id := l_rel_dim_lev_val_id ||c_amp
                          ||'p_rel_dim_lev_val_id='||p_rel_dim_lev_val_id;
    l_rel_dim_lev_g_var := l_rel_dim_lev_g_var ||c_amp
                         ||'p_rel_dim_lev_g_var='||p_rel_dim_lev_g_var;
    l_Z := l_Z||c_amp||'Z='||Z;


    lov_data
    ( p_startnum => p_startnum
    , p_rowcount => p_rowcount
    , p_totalavailable => l_totalcount
    , p_dim_level_id =>  p_dim_level_id
    , p_search_str => p_search_str
    , p_head  => l_head_tbl
    , p_value => l_value_tbl
    , p_link  => l_link_tbl
    , p_disp  => l_link_tbl
    , p_rel_dim_lev_id  => p_rel_dim_lev_id
    , p_rel_dim_lev_val_id  => p_rel_dim_lev_val_id
    , p_rel_dim_lev_g_var  => p_rel_dim_lev_g_var
    , Z  => Z
    , p_user_id => p_user_id
    , x_string => l_data_rstr
    );



    l_string:= l_string || l_data_rstr;

    lov_buttons
    ( p_startnum => p_startnum
    , p_rowcount => p_rowcount
    , p_totalavailable => l_totalcount
    , x_string => l_buttons_rstr
    );
     l_string:= l_string || l_buttons_rstr;

    x_string := l_string ;


-- end if; -- icx_validate session
--end if; -- icx_sec.validateSession
exception
when PSQLCOUNT_NOT_NULL_VALUE then
raise;
  when others then
    x_string := SQLERRM;

end main;

-- ***********************************************************
--     Frame that paints the  search box
-- ************************************************************
procedure lov_search
( p_totalpossible     in  pls_integer   default NULL
, p_totalavailable    in  pls_integer   default NULL
, p_titlename         in  varchar2      default NULL
, p_startnum          in  pls_integer   default NULL
, p_rowcount          in  pls_integer   default NULL
, p_search_str        in  varchar2      default NULL
, x_string            out nocopy VARCHAR2
)
is

l_to                     varchar2(15) := ' to ';
l_totalpossible          pls_integer := p_totalpossible;
l_totalcount             pls_integer := p_totalavailable;
l_titlename              varchar2(32000) := p_titlename;
l_possible               varchar2(30):= ' possible';
l_of                     varchar2(15):= ' of ';
l_values                 varchar2(15):= 'Values ';
l_endnum                 pls_integer;
l_startnum               pls_integer;
l_title                  varchar2(60) := 'List Of Values: ';
l_search_str             varchar2(200);
l_string                 VARCHAR2(32000);

-- meastmon 06/20/2001
-- Fix for ADA buttons
l_button_str             varchar2(32000);
l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
l_append_string          VARCHAR2(1000);
l_swan_enabled           BOOLEAN;
l_button_edge            VARCHAR2(100);

begin

--if icx_sec.validateSession then
  l_swan_enabled := BIS_UTILITIES_PVT.checkSWANEnabled();
  l_startnum := NVL(p_startnum,1);
  -- Replace the asterisk with the percent sign
  l_search_str := REPLACE(p_search_str,c_asterisk,c_percent);
  l_string := l_string || '<LINK HREF="/OA_HTML/bisportal.css" type="text/css" rel="stylesheet">';

  l_string := l_string || '<SCRIPT LANGUAGE="Javascript">';
  --  Check and send the text string for find criteria
  l_string := l_string ||'function chkString() {';
  l_string := l_string ||'    if (document.DefaultFormName.p_search_str1.value == "")';
  l_string := l_string ||'       alert("Please enter a search criteria");';
  l_string := l_string ||'    else {';
  l_string := l_string ||'       top.document.DefaultFormName.p_startnum.value ="";';
  l_string := l_string ||'       top.document.DefaultFormName.p_search_str.value = document.DefaultFormName.p_search_str1.value;';
  l_string := l_string ||'       top.document.DefaultFormName.submit();';
  l_string := l_string ||'       };';
  l_string := l_string ||'    }';

  l_string := l_string ||'</SCRIPT>';



  --l_string := l_string ||'<BODY BGCOLOR="'||c_fmbgcolor||'">';
  l_string := l_string ||'<BODY class="C_FMBGCOLOR">';
  l_string := l_string ||'<CENTER>';

  l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0 width=100%>';
  IF(NOT l_swan_enabled)THEN
   l_string := l_string ||'<TR class="C_FMBGCOLOR">';
   l_string := l_string ||'<td height=3></td>';
   l_string := l_string ||'</TR>';
   l_button_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
  ELSE
   l_button_edge :=BIS_UTILITIES_PVT.G_FLAT_EDGE;
  END IF;
  /*l_string := l_string ||'<TR BGCOLOR='||c_fmbgcolor||'>';
  l_string := l_string ||'<td height=3></td>';
  l_string := l_string ||'</TR>';*/

  --l_string := l_string ||'<BODY BGCOLOR="'||c_pgbgcolor||'">';
  l_string := l_string ||'<BODY class="C_PGBGCOLOR">';
  l_string := l_string ||'<TD><font size= -2><BR></font></TD>';
  l_string := l_string ||'</TR>';

  --l_string := l_string ||'<BODY BGCOLOR="'||c_pgbgcolor||'">';
  l_string := l_string ||'<BODY class="C_PGBGCOLOR">';

  l_string := l_string ||'<TD ALIGN="LEFT"><B>'||bis_utilities_pvt.escape_html(l_titlename)||' '||'('||bis_utilities_pvt.escape_html(l_totalpossible)||' '||bis_utilities_pvt.escape_html(c_possible)||')'||'</B></TD>';

  l_string := l_string ||'</TR>';

        -- table for input box and find button
  --l_string := l_string ||'<BODY BGCOLOR="'||c_pgbgcolor||'">';
  l_string := l_string ||'<BODY class="C_PGBGCOLOR">';

  l_string := l_string ||'<td align="CENTER">';
  l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0 width=100%>';
  l_string := l_string ||'<TR>';
  l_string := l_string ||'<TD ALIGN="LEFT"><INPUT TYPE="text" NAME="p_search_str1" SIZE="25" VALUE="'||bis_utilities_pvt.escape_html_input(NVL(l_search_str,c_percent))||'"></TD>';
  l_string := l_string ||'<td align="LEFT">';

 -- meastmon 06/20/2001. ICX Button is not ADA Complaint. ICX is not going to fix that.
 --icx_plug_utilities.buttonBoth(c_find,'javascript:chkString()');

  l_button_tbl(1).left_edge := l_button_edge;
  l_button_tbl(1).right_edge := l_button_edge;
  l_button_tbl(1).disabled := FND_API.G_FALSE;
  l_button_tbl(1).label := c_find;
  l_button_tbl(1).href := 'javascript:chkString()';
  BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
  l_string := l_string ||l_button_str;

  l_string := l_string ||'</td>';
  l_string := l_string ||'</TR>';
  l_string := l_string ||'</TABLE>';
  l_string := l_string ||'</td>';
  l_string := l_string ||'</TR>';


  --l_string := l_string ||'<TR BGCOLOR='||c_pgbgcolor||'>';
  l_string := l_string ||'<TR class="C_PGBGCOLOR">';
  l_string := l_string ||'<td height=1 bgcolor=#000000> <IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1></td>';
  l_string := l_string ||'</TR>';
  --l_string := l_string ||'<TR BGCOLOR='||c_pgbgcolor||'>';
  l_string := l_string ||'<TR class="C_PGBGCOLOR">';

  if (l_totalcount = 0) then
    -- if no values returned then print nothing
    l_string := l_string ||'<td><font size = -2><BR></font></td>';
  else
   -- if any values returned then print the range numbers
    l_string := l_string ||'<td align="RIGHT">';
    l_endnum := l_startnum+p_rowcount-1;
    if (l_endnum >= l_totalcount) then
      l_endnum := l_totalcount;
    end if;
    l_string := l_string ||c_values||' '||l_startnum||' '||c_to||' '||l_endnum||' '||c_of||' '||l_totalcount;
    l_string := l_string ||'</td>';
  end if;
  l_string := l_string ||'</TR>';
  --l_string := l_string ||'<TR BGCOLOR='||c_pgbgcolor||'>';
  l_string := l_string ||'<TR class="C_PGBGCOLOR">';
  l_string := l_string ||'<td><font size = -2><BR></font></td>';
  l_string := l_string ||'</TR>';
  --l_string := l_string ||'<TR BGCOLOR='||c_pgbgcolor||'>';
  l_string := l_string ||'<TR class="C_PGBGCOLOR">';
  l_string := l_string ||'<td><font size = -2><BR></font></td>';
  l_string := l_string ||'</TR>';
  l_string := l_string ||'</TABLE>';

  l_string := l_string ||'</CENTER>';

  --end if; --icx_sec.validateSession
  x_string := l_string;

exception
  when others then
    x_string := SQLERRM;
end lov_search;


-- ****************************************************
--      Frame that paints the LOVdata
-- ****************************************************
procedure lov_data
( p_startnum          in  pls_integer   default NULL
, p_rowcount          in  pls_integer   default NULL
, p_totalavailable    in  pls_integer   default NULL
, p_dim_level_id   in number default NULL
, p_search_str    in  varchar2 default NULL
, p_head              in  colstore_table
, p_value             in  colstore_table
, p_link              in  colstore_table
, p_disp              in  colstore_table
, p_rel_dim_lev_id         in varchar2 default NULL
, p_rel_dim_lev_val_id     in varchar2 default NULL
, p_rel_dim_lev_g_var      in varchar2 default NULL
, Z                        in pls_integer default NULL
, p_user_id           in pls_integer default NULL
, x_string            out nocopy VARCHAR2
)
is
l_startnum               pls_integer;
l_count                  pls_integer;
l_totalcount             pls_integer := p_totalavailable;
l_rcursor                pls_integer;
l_row                    pls_integer;
l_dummy2                 pls_integer;
l_dummy3                 pls_integer;
l_colstore               colstore_table;
l_pos1                   pls_integer;
l_pos2                   pls_integer;
l_col                    pls_integer;
l_linkvalue              varchar2(32000);
l_linktext               varchar2(32000);
l_string                 varchar2(32000);
l_sql                    varchar2(32000);
l_return_sts             VARCHAR2(100);
l_var VARCHAR2(100);
l_plug_id    pls_integer;
l_temp                   varchar2(32000);
l_search_str             varchar2(32000);
--l_user_id                pls_integer;

begin


-- meastmon 09/07/2001 Fix bug#1980577. Workaround Do not encrypt plug_id
  --l_plug_id := icx_call.decrypt2(Z);
  l_plug_id := Z;
  --if icx_sec.validateSession  then
 --if ICX_SEC.validatePlugSession(l_plug_id) then

  -- prepare SQl modified for enh#3559231
  -- Replace the asterisk with the percent sign
  --l_sql := REPLACE(p_sql,c_asterisk,c_percent);
  --l_user_id := ICX_SEC.getID(ICX_SEC.PV_USER_ID, '', icx_sec.g_session_id);
  l_search_str := concat_string(p_search_str);
  l_temp := BIS_INTERMEDIATE_LOV_PVT.getLOVSQL(p_dim_level_id, l_search_str, 'LOV',  p_user_id);
  l_sql := 'select distinct id, value from ('||l_temp||')';



   IF p_rel_dim_lev_val_id IS NOT NULL THEN
     setGlobalVar
     ( p_dim_lev_id      => p_rel_dim_lev_id
     , p_dim_lev_val_id  => p_rel_dim_lev_val_id
     , p_dim_lev_g_var   => p_rel_dim_lev_g_var
     , x_return_status   => l_return_sts
     );
   END IF;

   -- Now parse the actual query
   l_rcursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_rcursor,l_sql,DBMS_SQL.NATIVE);

   IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
     for l_pos1 in p_head.FIRST .. p_head.COUNT loop
       l_colstore(l_pos1) := '';
       DBMS_SQL.DEFINE_COLUMN(l_rcursor,l_pos1,l_colstore(l_pos1),32000);
     end loop;
     l_dummy2 := DBMS_SQL.EXECUTE(l_rcursor);
   ELSE
     DBMS_SQL.CLOSE_CURSOR(l_rcursor);
     COMMIT;
   END IF;
   l_startnum := NVL(p_startnum,1);


   --l_string := l_string || '<BODY BGCOLOR="'||c_pgbgcolor||'">';
   l_string := l_string || '<BODY class="C_PGBGCOLOR">';

   -- Set the set of books id for GL dimension levels
 --
   l_var := BIS_TARGET_PVT.G_SET_OF_BOOK_ID;

   l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">';

   --  Transfer the clicked URL's name and id to the parent function
   l_string := l_string ||'function transfer_value(name,id) {';
   l_string := l_string ||'      top.transfer(name,id);';
   l_string := l_string ||'   }';
   l_string := l_string ||'</SCRIPT>';

   l_string := l_string ||'<CENTER>';
   l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=2 width=95%>';
  -- l_string := l_string ||'<TR BGCOLOR='||c_tblsurnd||'>';
    l_string := l_string ||'<TR class="C_TBLSURND">';
   l_string := l_string ||'<td>';
   l_string := l_string ||'<table border=0 cellspacing=1 cellpadding=2 width=100%>';
   --l_string := l_string ||'<TR BGCOLOR='||c_rowHeader||'>';
   l_string := l_string ||'<TR class="C_ROWHEADER">';

   for l_col in p_disp.FIRST..p_disp.COUNT loop
     if (p_disp(l_col) = FND_API.G_TRUE) then
      -- l_string := l_string ||'<TH><font color='||c_rowcolor||'>'||p_head(l_col)||'</font></TH>';
       l_string := l_string ||'<TH><font class="C_FONT_COLOR">'||p_head(l_col)||'</font></TH>';
     end if;
   end loop;
   l_string := l_string ||'</TR>';
    --
    --    *******      Print LOV DATA       *********
    --
    l_count := 1;
    loop

    BEGIN
      -- Fetch the rows
      IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
       l_dummy3 := DBMS_SQL.FETCH_ROWS(l_rcursor);

        IF l_dummy3 > 0 THEN
          -- Store in local plsql table of variables
          for l_pos1 in p_head.FIRST .. p_head.COUNT loop
            DBMS_SQL.COLUMN_VALUE(l_rcursor,l_pos1,l_colstore(l_pos1));
          end loop;
        ELSE
          DBMS_SQL.CLOSE_CURSOR(l_rcursor);
          COMMIT;
        END IF;
      ELSE
        DBMS_SQL.CLOSE_CURSOR(l_rcursor);
        COMMIT;
      END IF;

      EXCEPTION
        when others then
        l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">';
        l_string := l_string ||'ERROR in LovData: '||SQLERRM;
        l_string := l_string ||'</SCRIPT>';
      END;

     -- Start painting only those rows in the range specified
     if (l_count >= l_startnum AND l_count < l_startnum + p_rowcount) then
        -- Start painting the column values
        for l_pos1 in p_head.FIRST .. p_head.COUNT loop
          if (p_link(l_pos1) = FND_API.G_TRUE) then
             l_linktext := bis_utilities_pvt.escape_html(l_colstore(l_pos1));
             for l_pos2 in p_head.FIRST..p_head.COUNT loop
               if (p_value(l_pos2) = FND_API.G_TRUE) then
                  l_linkvalue := bis_utilities_pvt.escape_html(l_colstore(l_pos2));
                  exit;
               end if;
              end loop;
             --l_string := l_string ||'<TR BGCOLOR='||c_rowcolor||'>';
               l_string := l_string ||'<TR class="C_ROWCOLOR">';
             --l_string := l_string ||'<TD NOWRAP HEIGHT=10><A HREF="Javascript:transfer_value('''||ICX_UTIL.replace_onMouseOver_quotes(l_linktext)||''','''||l_linkvalue||''')">'||l_linktext||'</A></TD>';
             l_string := l_string ||'<TD NOWRAP HEIGHT=10><A HREF="Javascript:transfer_value('''||REPLACE(REPLACE(REPLACE(l_linktext,'''','\'''),'"','`'||c_amp||'quot;'),'\\','\')||''','''||l_linkvalue||''')">'||l_linktext||'</A></TD>';

          elsif (p_disp(l_pos1) = FND_API.G_TRUE) AND
                (p_link(l_pos1) = FND_API.G_FALSE) then
             --l_string := l_string ||'<TR BGCOLOR='||c_rowcolor||'>';
             l_string := l_string ||'<TR class="C_ROWCOLOR">';
             l_string := l_string ||'<TD NOWRAP >'||bis_utilities_pvt.escape_html(l_colstore(l_pos1))||'</TD>';
          end if;   -- to check type of column
        end loop; --  p_coldata loop to determine the context of each col
       l_string := l_string ||'</TR>';

      end if;   -- if count of rows is between the start and end
      l_count := l_count + 1;
      exit when (l_count >= l_startnum + p_rowcount) OR
                (l_count > l_totalcount);

     end loop;

   -- Close the cursor
   IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
     DBMS_SQL.CLOSE_CURSOR(l_rcursor);
     COMMIT;
   END IF;
   l_string := l_string ||'</TABLE>';
   l_string := l_string ||'</td>';
   l_string := l_string ||'</TR>';
   l_string := l_string ||'</TABLE>';
   --l_string := l_string || '</FORM>';
   l_string := l_string || '</CENTER>';
-- end if; -- icx_validate session
--end if; --icx_sec.validateSession

x_string := l_string;

exception
  when others then
    x_string := SQLERRM;
    IF DBMS_SQL.IS_OPEN(l_rcursor) THEN
      DBMS_SQL.CLOSE_CURSOR(l_rcursor);
      COMMIT;
    END IF;
end lov_data;

-- ****************************************************
--      Frame that paints the Buttons
-- ****************************************************
procedure lov_buttons
( p_startnum          in  pls_integer   default NULL
, p_rowcount          in  pls_integer   default NULL
, p_totalavailable    in  pls_integer   default NULL
, x_string             out nocopy varchar
)
is
i                       pls_integer;
l_startnum              pls_integer;
l_endnum                pls_integer;
l_start                 pls_integer;
l_end                    pls_integer;
l_snext                  pls_integer;
l_enext                  pls_integer;
l_sprev                  pls_integer;
l_eprev                  pls_integer;
l_totalcount             pls_integer := p_totalavailable;
l_to                     varchar2(15):= ' to ';
l_previous               varchar2(30):= 'Previous';
l_next                   varchar2(30):= 'Next';
l_of                     varchar2(15) := ' of ';
l_values                 varchar2(15) := 'Values ';
l_string                 VARCHAR2(32000);

-- meastmon 06/20/2001
-- Fix for ADA buttons
l_button_str             varchar2(32000);
l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
l_append_string          VARCHAR2(1000);
l_swan_enabled           BOOLEAN;
l_button_edge            VARCHAR2(100);

begin

--if icx_sec.validateSession then
  l_swan_enabled := BIS_UTILITIES_PVT.checkSWANEnabled();
  l_startnum := NVL(p_startnum,1);

   -- Set the numbers for the buttons for next set of rows
  l_snext := l_startnum + p_rowcount;
  l_sprev := l_startnum - p_rowcount;

  l_string  := l_string  ||'<SCRIPT LANGUAGE="Javascript">';

  l_string  := l_string  ||'function doNothing() {';

  l_string  := l_string  ||'}';

  l_string  := l_string  ||'function get_nextNum() {';
  l_string  := l_string  ||'top.document.DefaultFormName.p_startnum.value ='||l_snext||';';
  l_string  := l_string  ||'top.document.DefaultFormName.submit();';
  l_string  := l_string  ||'}';

  l_string  := l_string  ||'function get_prevNum() {';
  l_string  := l_string  ||'top.document.DefaultFormName.p_startnum.value ='||l_sprev||';';
  l_string  := l_string  ||'top.document.DefaultFormName.submit();';
  l_string  := l_string  ||'}';

  l_string  := l_string  ||'function getRange() {';
  l_string  := l_string  ||'  var tmp = document.DefaultFormName.range.selectedIndex;';
  l_string  := l_string  ||'    top.document.DefaultFormName.p_startnum.value = document.DefaultFormName.range[tmp].value;';
  l_string  := l_string  ||'    top.document.DefaultFormName.submit();';
  l_string  := l_string  ||'  }';

  --  Propagate the cancel event upwards to the frameset section
  l_string  := l_string  ||'  function cancel() {';
  l_string  := l_string  ||'      top.closeMe();';
  l_string  := l_string  ||'    }';

  l_string  := l_string  ||'  </SCRIPT>';

 -- l_string  := l_string  ||'  <BODY BGCOLOR="'||c_fmbgcolor||'">';
   l_string  := l_string  ||'  <BODY class="C_FMBGCOLOR">';

  l_string  := l_string  ||'<CENTER>';

  l_string  := l_string  ||'<!-- Open table -->';
  l_string  := l_string  ||'<table border=0 cellspacing=0 cellpadding=0 width=100%>';

  IF(l_swan_enabled)THEN
   l_button_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
  ELSE
   l_button_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
  END IF;


     -- Check if the Buttons need to be painted
  if (l_totalcount > p_rowcount) then

    l_string  := l_string  ||'<!-- Open row because totalcount is more than rowcount -->';
    --l_string  := l_string  ||'<TR BGCOLOR='||c_pgbgcolor||'>';
    l_string  := l_string  ||'<TR class="C_PGBGCOLOR">';
    l_string  := l_string  ||'<td align="CENTER" nowrap="YES">';
    l_string  := l_string  ||'<!-- Open embedded table  -->';
    l_string  := l_string  ||'<table border=0 cellspacing=0 cellpadding=0 width=100%>';
    l_string  := l_string  ||'<!-- Open row inside embedded table containing prev-next buttons and range -->';
    l_string  := l_string  ||'<TR>';

    if (l_startnum < p_rowcount) then
      l_string  := l_string  ||'<td align="RIGHT" nowrap="YES">';

         --meastmon 06/20/2001. ICX Button is not ADA Complaint. ICX is not going to fix that.
         --icx_plug_utilities.buttonLeft(c_previous||' '
         --                            ||p_rowcount,'Javascript:doNothing()');
       l_button_tbl(1).left_edge := l_button_edge;
       l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
       l_button_tbl(1).disabled := FND_API.G_FALSE;
       l_button_tbl(1).label := c_previous||' '||p_rowcount;
       l_button_tbl(1).href := 'Javascript:doNothing()';
       BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
       l_string  := l_string  ||l_button_str;

       l_string  := l_string  ||'</td>';
     else
       l_string  := l_string  ||'<td align="RIGHT" nowrap="YES">';

         --meastmon 06/20/2001. ICX Button is not ADA Complaint. ICX is not going to fix that.
         --icx_plug_utilities.buttonLeft(c_previous||' '
         --                            ||p_rowcount,'Javascript:get_prevNum()');
       l_button_tbl(1).left_edge := l_button_edge;
       l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
       l_button_tbl(1).disabled := FND_API.G_FALSE;
       l_button_tbl(1).label := c_previous||' '||p_rowcount;
       l_button_tbl(1).href := 'Javascript:get_prevNum()';
       BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
       l_string  := l_string  ||l_button_str;

       l_string  := l_string  ||'</td>';
     end if;

       l_string  := l_string  ||'<td align="CENTER">';
       l_string  := l_string  ||'<SELECT NAME="range" onChange="getRange()">';
       i := 1;
       l_start := 1;
       l_end := 1;
       while (l_end <= l_totalcount) loop
         l_end := l_start + (p_rowcount -1);
         if (l_end >= l_totalcount) then
            l_end := l_totalcount;
            if l_start = l_startnum then
              l_string  := l_string  ||'<OPTION SELECTED VALUE='||l_start||'>'||l_start||l_to||l_end||l_of||l_totalcount;
            else
              l_string  := l_string  ||'<OPTION VALUE='||l_start||'>'||l_start||l_to||l_end||l_of||l_totalcount;
            end if;
            exit;
         end if;
         if l_start = l_startnum then
           l_string  := l_string  ||'<OPTION SELECTED VALUE='||l_start||'>'||l_start||l_to||l_end||l_of||l_totalcount;
         else
           l_string  := l_string  ||'<OPTION VALUE='||l_start||'>'||l_start||l_to||l_end||l_of||l_totalcount;
         end if;

         i := i + 1;
         l_start := l_start + p_rowcount;
       end loop;
       l_string  := l_string  ||'</SELECT>';
       l_string  := l_string  ||'</td>';

       if (l_startnum + p_rowcount >= l_totalcount) then
         l_string  := l_string  ||'<td align="LEFT" nowrap="YES">';

         --meastmon 06/20/2001. ICX Button is not ADA Complaint. ICX is not going to fix that.
         --icx_plug_utilities.buttonRight(c_next||' '
         --                  ||p_rowcount,'Javascript:doNothing()');
         l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
         l_button_tbl(1).right_edge := l_button_edge;
         l_button_tbl(1).disabled := FND_API.G_FALSE;
         l_button_tbl(1).label := c_next||' '||p_rowcount;
         l_button_tbl(1).href := 'Javascript:doNothing()';
         BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
         l_string  := l_string  ||l_button_str;

         l_string  := l_string  ||'</td>';
       else
         l_string  := l_string  ||'<td align="LEFT" nowrap="YES">';

         --meastmon 06/20/2001. ICX Button is not ADA Complaint. ICX is not going to fix that.
         --icx_plug_utilities.buttonRight(c_next||' '
         --                   ||p_rowcount,'Javascript:get_nextNum()');
         l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
         l_button_tbl(1).right_edge := l_button_edge;
         l_button_tbl(1).disabled := FND_API.G_FALSE;
         l_button_tbl(1).label := c_next||' '||p_rowcount;
         l_button_tbl(1).href := 'Javascript:get_nextNum()';
         BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
         l_string  := l_string  ||l_button_str;

         l_string  := l_string  ||'</td>';
       end if;

       l_string  := l_string  ||'<!-- Close row containing buttons and range poplist -->';
       l_string  := l_string  ||'</TR>';
       l_string  := l_string  ||'<!-- Close embedded table containing buttons and range poplist -->';
       l_string  := l_string  ||'</TABLE>';
       l_string  := l_string  ||'</td>';
       l_string  := l_string  ||'<!-- Close row containing embedded table buttons and range poplist -->';
       l_string  := l_string  ||'</TR>';

     else
       l_string  := l_string  ||'<!-- If totalcount is less than rowcount paint an extra stip of grey -->';
       --l_string  := l_string  ||'<TR BGCOLOR='||c_pgbgcolor||'>';
       l_string  := l_string  ||'<TR class="C_PGBGCOLOR">';
       l_string  := l_string  ||'<td><BR></td>';
       l_string  := l_string  ||'</TR>';

   end if;    -- to decide to even print the prev,next,range items

   l_string  := l_string  ||'<!-- Open row to paint an empty strip of framecolor -->';
   --l_string  := l_string  ||'<TR BGCOLOR='||c_fmbgcolor||'>';
   /*l_string  := l_string  ||'<TR style="background-image:url(/OA_HTML/cabo/images/footerBg.gif);background-repeat:repeat-x;height:41px" >';
   l_string  := l_string  ||'<td><font size = -2><BR></font></td>';
   l_string  := l_string  ||'<!-- Close row to paint an empty strip of framecolor -->';
   l_string  := l_string  ||'</TR>';*/
   l_string  := l_string  ||'<!-- Open row to paint the cancel button -->';

   --l_string  := l_string  ||'<TR BGCOLOR='||c_fmbgcolor||'>';
   IF(l_swan_enabled)THEN
    l_string  := l_string  ||'<TR style="background-image:url(/OA_HTML/cabo/images/footerBg.gif);background-repeat:repeat-x;height:41px" >';
   ELSE
    l_string  := l_string  ||'<TR class="C_FMBGCOLOR">';
   END IF;
   l_string  := l_string  ||'<td align="RIGHT">';
   l_string  := l_string  ||'<table border=0 cellspacing=0 cellpadding=0 width=20%>';
   l_string  := l_string  ||'<TR>';
   l_string  := l_string  ||'<td align="RIGHT" nowrap="YES">';

    --meastmon 06/20/2001. ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonBoth(c_cancel,'Javascript:cancel()');
    l_button_tbl(1).left_edge := l_button_edge;
    l_button_tbl(1).right_edge := l_button_edge;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := c_cancel;
    l_button_tbl(1).href := 'Javascript:cancel()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    l_string  := l_string  ||l_button_str;

    l_string  := l_string  ||'</td>';
    l_string  := l_string  ||'</TR>';
    l_string  := l_string  ||'</TABLE>';
    l_string  := l_string  ||'</td>';
    l_string  := l_string  ||'<!-- Close row to paint the cancel button -->';
    l_string  := l_string  ||'</TR>';
    l_string  := l_string  ||'<!-- Close main table -->';
    l_string  := l_string  ||'</TABLE>';
    l_string  := l_string  ||'</CENTER>';
    --l_string  := l_string  ||'</FORM>';

    x_string := l_string;

--end if; --icx_sec.validateSession

exception
  when others then --htp.p(SQLERRM);
    x_string := SQLERRM;
end lov_buttons;


-- ****************************************************
--     Function to return a string with attachments on
--               both sides
-- ****************************************************
function concat_string (p_search_str  varchar2 default NULL)
return
   varchar2 is
v_local_str   varchar2(200);

begin
   v_local_str := ''''||NVL(p_search_str,c_percent)||'''';

   return v_local_str;
end concat_string;

-- *****************************************************
--      Procedure to paint the Javascript for LOV window
-- *****************************************************
procedure lovjscript
(x_string out nocopy varchar2
)
is
l_string    VARCHAR2(32000);
begin
--if icx_sec.validateSession then
  l_string := l_string || '<SCRIPT LANGUAGE="JavaScript">';
      -- **************************
      --   BEGIN MODAL DIALOG CODE
      -- **************************
   -- Global for type of browser
  l_string := l_string ||'var Nav4 = ((navigator.appName == "Netscape") '||c_amp|| c_amp||' (parseInt(navigator.appVersion) == 4));';

   -- one object tracks the current modal dialog spawned from this window
  l_string := l_string ||'var modalWin = new Object();';

   -- Generate a modal window from any frame of the parent window
   -- Parameters:
   --  js_procname : plsql procedure that creates the sql query
   --  js_qrycnd   : query condition
   --  js_jsfuncname : name of the javascript function that will
   --  receive the returning value
  l_string := l_string ||' function getLOV(js_procname,js_qrycnd,js_jsfuncname,Z,js_dim1_lbl) {';
   --l_string := l_string ||'// Bug 1797465 if label has a space then replace it with +';
  l_string := l_string ||'out = " "; ';--// replace this
  l_string := l_string ||'add = "+";'; --// with this';
  l_string := l_string ||'temp = "" + js_dim1_lbl; ';--// temporary holder';

  l_string := l_string ||'while (temp.indexOf(out)>-1) {';
  l_string := l_string ||'pos= temp.indexOf(out);';
  l_string := l_string ||'temp = "" + (temp.substring(0, pos) + add +';
  l_string := l_string ||'temp.substring((pos + out.length), temp.length));';
  l_string := l_string ||'}';
  --l_string := l_string ||'// load up properties of the modal window object';
  --l_string := l_string ||'modalWin.url = js_procname + "p_qrycnd=" + js_qrycnd + "'||c_amp||'p_jsfuncname=" + js_jsfuncname + "'||c_amp||'Z=" + Z + "'||c_amp||'p_dim1_lbl=" + temp;';
  l_string := l_string ||'modalWin.url = "/OA_HTML/OA.jsp?page=/oracle/apps/bis/pmf/pmportlet/pages/BISPMFLOV'||c_amp||'p_qrycnd=" + js_qrycnd + "'||c_amp||'p_jsfuncname=" + js_jsfuncname + "'||c_amp||'Z=" + Z + "'||c_amp||'p_dim1_lbl=" + temp;';
  --l_string := l_string ||'//     alert("Window URL: "+modalWin.url);';
  l_string := l_string ||'modalWin.width = 400;';
  l_string := l_string ||'modalWin.height = 460;';
  --l_string := l_string ||'// keep name unique so Navigator does not overwrite an existing dialog';
  l_string := l_string ||'modalWin.name = (new Date()).getSeconds().toString();';
  l_string := l_string ||'if (Nav4) {';
  --l_string := l_string ||'// center on the main window';
  l_string := l_string ||'modalWin.left = window.screenX + ((window.outerWidth - modalWin.width) / 2);';
  l_string := l_string ||'modalWin.top = window.screenY + ((window.outerHeight - modalWin.height) / 2);';
  l_string := l_string ||'var attr = "screenX=" + modalWin.left + ",screenY=" + modalWin.top + ",resizable=no,dependent=yes,width=" + modalWin.width + ",height=" + modalWin.height;';
  l_string := l_string ||'   } else {';
  --l_string := l_string ||'// best we can do is center in screen';
  l_string := l_string ||'modalWin.left = (screen.width - modalWin.width) / 2;';
  l_string := l_string ||'modalWin.top = (screen.height - modalWin.height) / 2;';
  l_string := l_string ||'var attr = "left=" + modalWin.left + ",top=" + modalWin.top+ ",resizable=no,width=" + modalWin.width + ",height=" + modalWin.height;';
  l_string := l_string ||'}';
  --l_string := l_string ||'// generate the window and make sure it has focus';
  l_string := l_string ||'modalWin.win=window.open(modalWin.url, modalWin.name, attr);';
  l_string := l_string ||'modalWin.win.focus();';
  l_string := l_string ||'}';


  -- event handler to prevent any Navigator widget action when modal is active
  l_string := l_string ||'function deadend() {';
  l_string := l_string ||'if (modalWin.win '||c_amp || c_amp||' !modalWin.win.closed) {';
  l_string := l_string ||'modalWin.win.focus();';
  l_string := l_string ||'return false;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';

  -- preserve IE link onclick event handlers while they are disabled;
  -- restore when reenabling the main window
  l_string := l_string ||'var IELinkClicks;';

  -- disable form elements and links in all frames for IE
  l_string := l_string ||'function disableForms() {';
  l_string := l_string ||'IELinkClicks = new Array();';
  l_string := l_string ||'for (var h = 0; h < frames.length; h++) {';
  l_string := l_string ||'for (var i = 0; i < frames[h].document.forms.length; i++) {';
  l_string := l_string ||'for (var j=0; j<frames[h].document.forms[i].elements.length; j++) {';
  l_string := l_string ||'frames[h].document.forms[i].elements[j].disabled = true;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'IELinkClicks[h] = new Array();';
  l_string := l_string ||'for (i = 0; i < frames[h].document.links.length; i++) {';
  l_string := l_string ||'IELinkClicks[h][i] = frames[h].document.links[i].onclick;';
  l_string := l_string ||'frames[h].document.links[i].onclick = deadend;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'}';

  -- restore IE form elements and links to normal behavior
  l_string := l_string ||'function enableForms() {';
  l_string := l_string ||'for (var h = 0; h < frames.length; h++) {';
  l_string := l_string ||'for (var i = 0; i < frames[h].document.forms.length; i++) {';
  l_string := l_string ||'for (var j=0; j<frames[h].document.forms[i].elements.length; j++) {';
  l_string := l_string ||'frames[h].document.forms[i].elements[j].disabled = false;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'for (i = 0; i < frames[h].document.links.length; i++) {';
  l_string := l_string ||'frames[h].document.links[i].onclick = IELinkClicks[h][i];';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||' }';

  -- extra work for Navigator
  l_string := l_string ||'function blockEvents() {';
  l_string := l_string ||'if (Nav4) {';
  l_string := l_string ||'window.captureEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS);';
  l_string := l_string ||'window.onclick = deadend;';
  l_string := l_string ||'window.onfocus = checkModal;';
  l_string := l_string ||'} else {';
  l_string := l_string ||'disableForms();';
  l_string := l_string ||'}';
  l_string := l_string ||'}';

  l_string := l_string ||'function unblockEvents() {';
  l_string := l_string ||'if (Nav4) {';
  l_string := l_string ||'window.releaseEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS);';
  l_string := l_string ||'window.onclick = null;';
  l_string := l_string ||'window.onfocus = null;';
  l_string := l_string ||'} else {';
  l_string := l_string ||'enableForms();';
  l_string := l_string ||'}';
  l_string := l_string ||'}';

  -- invoked by onFocus event handler of EVERY frame document
  l_string := l_string ||'function checkModal() {';
  l_string := l_string ||'  if (modalWin.win '||c_amp || c_amp||' !modalWin.win.closed) {';
  l_string := l_string ||'modalWin.win.focus();';
  l_string := l_string ||'}';
  l_string := l_string ||'}';

  -- clear opener reference in a modal if dialog is showing;
  -- takes care of case when user closes main window while dialog is showing
  l_string := l_string ||'function cancelModal() {';
  l_string := l_string ||'if (modalWin.win '||c_amp || c_amp||' !modalWin.win.closed) {';
  l_string := l_string ||'modalWin.win.opener = null;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';



  l_string := l_string ||'function getdim0(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim0.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim0[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim0.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim0.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim0[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim0[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim0.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim0.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim0.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim0.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim1(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim1.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim1[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim1.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim1.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim1[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim1[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim1.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim1.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim1.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim1.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim2(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim2.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim2[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim2.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim2.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim2[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim2[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim2.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim2.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim2.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim2.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim3(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim3.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim3[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim3.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim3.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim3[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim3[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim3.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim3.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim3.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim3.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim4(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim4.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim4[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim4.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim4.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim4[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim4[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim4.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim4.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim4.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim4.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim5(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim5.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim5[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim5.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim5.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim5[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim5[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim5.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim5.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim5.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim5.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim6(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim6.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim6[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim6.options[end-1].value;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim6.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim6[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim6[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim6.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim6.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim6.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim6.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';

  l_string := l_string ||'function getdim7(name,id) {';
  l_string := l_string ||'var end = document.DefaultFormName.dim7.length;';
  l_string := l_string ||'var tempText = document.DefaultFormName.dim7[end-1].text;';
  l_string := l_string ||'var tempValue = document.DefaultFormName.dim7.options[end-1].value;';
  --l_string := l_string ||' // 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'var found = "false";';
  l_string := l_string ||'var ind = 0;';
  l_string := l_string ||'for (var i = 0; i < document.DefaultFormName.dim7.length; i++) {';
  l_string := l_string ||'if (document.DefaultFormName.dim7[i].text == name ){';
  l_string := l_string ||'found = "true";';
  l_string := l_string ||'ind = i;';
  l_string := l_string ||'}';
  l_string := l_string ||'}';
  l_string := l_string ||'if (found == "false"){';
  l_string := l_string ||'document.DefaultFormName.dim7[end-1].text = name;';
  l_string := l_string ||'document.DefaultFormName.dim7.options[end-1].value = id;';
  l_string := l_string ||'document.DefaultFormName.dim7.options[end] = new Option(tempText,tempValue);';
  l_string := l_string ||'document.DefaultFormName.dim7.selectedIndex = end-1;';
  l_string := l_string ||'}';
  l_string := l_string ||'else ';
  l_string := l_string ||'document.DefaultFormName.dim7.selectedIndex = ind;';
  --l_string := l_string ||'// 2309961 add to the poplist only when it is not already available';
  l_string := l_string ||'}';



  -- **************************
    --   END MODAL DIALOG CODE
  -- **************************
  l_string := l_string ||'</SCRIPT>';
--end if; --icx_sec.validateSession

x_string := l_string;
end lovjscript;

-- mdamle 01/15/2001 - Added the same lovjscript for the edit page
procedure editlovjscript
( x_string out nocopy varchar2
)
is
l_string VARCHAR2(32000);
begin
--if icx_sec.validateSession then
  l_string := l_string ||'<SCRIPT LANGUAGE="JavaScript">';
      -- **************************
      --   BEGIN MODAL DIALOG CODE
      -- **************************
   -- Global for type of browser
   l_string := l_string || 'var Nav4 = ((navigator.appName == "Netscape") '||c_amp|| c_amp||' (parseInt(navigator.appVersion) == 4));';

   -- one object tracks the current modal dialog spawned from this window
   l_string := l_string || 'var modalWin = new Object();';

   -- Generate a modal window from any frame of the parent window
   -- Parameters:
   --  js_procname : plsql procedure that creates the sql query
   --  js_qrycnd   : query condition
   --  js_jsfuncname : name of the javascript function that will
   --  receive the returning value
   l_string := l_string || ' function getLOV(js_procname,js_qrycnd,js_jsfuncname,Z) {';
   --l_string := l_string || '// load up properties of the modal window object';
   l_string := l_string || 'modalWin.url = js_procname + "p_qrycnd=" + js_qrycnd + "'||c_amp||'p_jsfuncname=" + js_jsfuncname + "'||c_amp||'Z=" + Z;';
   l_string := l_string ||'modalWin.url = "/OA_HTML/OA.jsp?page=/oracle/apps/bis/pmf/pmportlet/pages/BISPMFLOV'||c_amp||'p_qrycnd=" + js_qrycnd + "'||c_amp||'p_jsfuncname=" + js_jsfuncname + "'||c_amp||'Z=" + Z;'; --+ "'||c_amp||'p_dim1_lbl=" + temp;';

   --l_string := l_string ||' //alert("Window URL: "+modalWin.url);';

   l_string := l_string ||'modalWin.width = 400;';
   l_string := l_string ||'modalWin.height = 460;';
   --l_string := l_string ||'// keep name unique so Navigator does not overwrite an existing dialog';
   l_string := l_string ||'modalWin.name = (new Date()).getSeconds().toString();';
   l_string := l_string ||'if (Nav4) {';
   --l_string := l_string ||'// center on the main window';
   l_string := l_string ||'modalWin.left = window.screenX + ((window.outerWidth - modalWin.width) / 2);';
   l_string := l_string ||'modalWin.top = window.screenY + ((window.outerHeight - modalWin.height) / 2);';
   l_string := l_string ||'var attr = "screenX=" + modalWin.left + ",screenY=" + modalWin.top + ",resizable=no,dependent=yes,width=" + modalWin.width + ",height=" + modalWin.height;';
   l_string := l_string ||'} else {';
   --l_string := l_string ||'// best we can do is center in screen';
   l_string := l_string ||'modalWin.left = (screen.width - modalWin.width) / 2;';
   l_string := l_string ||'modalWin.top = (screen.height - modalWin.height) / 2;';
   l_string := l_string ||'var attr = "left=" + modalWin.left + ",top=" + modalWin.top+ ",resizable=no,width=" + modalWin.width + ",height=" + modalWin.height;';
   l_string := l_string ||'}';
   --l_string := l_string ||'// generate the window and make sure it has focus';
   l_string := l_string ||'modalWin.win=window.open(modalWin.url, modalWin.name, attr);';
   l_string := l_string ||'modalWin.win.focus();';
   l_string := l_string ||'}';

  -- event handler to prevent any Navigator widget action when modal is active
   l_string := l_string ||'function deadend() {';
   l_string := l_string ||'if (modalWin.win '||c_amp || c_amp||' !modalWin.win.closed) {';
   l_string := l_string ||'modalWin.win.focus();';
   l_string := l_string ||'return false;';
   l_string := l_string ||'}';
   l_string := l_string ||'}';

   -- preserve IE link onclick event handlers while they are disabled;
   -- restore when reenabling the main window
   l_string := l_string ||'var IELinkClicks;';

   -- disable form elements and links in all frames for IE
   l_string := l_string ||'function disableForms() {';
   l_string := l_string ||'  IELinkClicks = new Array();';
   l_string := l_string ||'  for (var h = 0; h < frames.length; h++) {';
   l_string := l_string ||'     for (var i = 0; i < frames[h].document.forms.length; i++) {';
   l_string := l_string ||'for (var j=0; j<frames[h].document.forms[i].elements.length; j++) {';
   l_string := l_string ||'frames[h].document.forms[i].elements[j].disabled = true;';
   l_string := l_string ||'}';
   l_string := l_string ||'}';
   l_string := l_string ||'IELinkClicks[h] = new Array();';
   l_string := l_string ||'for (i = 0; i < frames[h].document.links.length; i++) {';
   l_string := l_string ||'IELinkClicks[h][i] = frames[h].document.links[i].onclick;';
   l_string := l_string ||'frames[h].document.links[i].onclick = deadend;';
   l_string := l_string ||'}';
   l_string := l_string ||'}';
   l_string := l_string ||'}';

   -- restore IE form elements and links to normal behavior
   l_string := l_string ||'function enableForms() {';
   l_string := l_string ||'for (var h = 0; h < frames.length; h++) {';
   l_string := l_string ||'for (var i = 0; i < frames[h].document.forms.length; i++) {';
   l_string := l_string ||'for (var j=0; j<frames[h].document.forms[i].elements.length; j++) {';
   l_string := l_string ||'frames[h].document.forms[i].elements[j].disabled = false;';
   l_string := l_string ||'}';
   l_string := l_string ||'}';
   l_string := l_string ||'for (i = 0; i < frames[h].document.links.length; i++) {';
   l_string := l_string ||'frames[h].document.links[i].onclick = IELinkClicks[h][i];';
   l_string := l_string ||'}';
   l_string := l_string ||'}';
   l_string := l_string ||'}';

    -- extra work for Navigator
   l_string := l_string ||'function blockEvents() {';
   l_string := l_string ||'if (Nav4) {';
   l_string := l_string ||'window.captureEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS);';
   l_string := l_string ||'window.onclick = deadend;';
   l_string := l_string ||'window.onfocus = checkModal;';
   l_string := l_string ||'} else {';
   l_string := l_string ||'disableForms();';
   l_string := l_string ||'}';
   l_string := l_string ||'}';

   l_string := l_string ||'function unblockEvents() {';
   l_string := l_string ||'if (Nav4) {';
   l_string := l_string ||'window.releaseEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS);';
   l_string := l_string ||'window.onclick = null;';
   l_string := l_string ||'window.onfocus = null;';
   l_string := l_string ||'} else {';
   l_string := l_string ||'enableForms();';
   l_string := l_string ||'}';
   l_string := l_string ||'}';

   -- invoked by onFocus event handler of EVERY frame document
   l_string := l_string ||'function checkModal() {';
   l_string := l_string ||'if (modalWin.win '||c_amp || c_amp||' !modalWin.win.closed) {';
   l_string := l_string ||'modalWin.win.focus();';
   l_string := l_string ||'}';
   l_string := l_string ||'}';

    -- clear opener reference in a modal if dialog is showing;
    -- takes care of case when user closes main window while dialog is showing
   l_string := l_string ||'function cancelModal() {';
   l_string := l_string ||'if (modalWin.win '||c_amp || c_amp||' !modalWin.win.closed) {';
   l_string := l_string ||'modalWin.win.opener = null;';
   l_string := l_string ||'}';
   l_string := l_string ||'}';


   l_string := l_string ||'function getdim0(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim0.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim0[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim0.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim0[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim0.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim0.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim0.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim1(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim1.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim1[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim1.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim1[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim1.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim1.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim1.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim2(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim2.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim2[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim2.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim2[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim2.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim2.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim2.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim3(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim3.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim3[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim3.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim3[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim3.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim3.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim3.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim4(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim4.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim4[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim4.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim4[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim4.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim4.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim4.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim5(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim5.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim5[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim5.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim5[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim5.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim5.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim5.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim6(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim6.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim6[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim6.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim6[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim6.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim6.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim6.selectedIndex = end-1;';
   l_string := l_string ||'}';

   l_string := l_string ||'function getdim7(name,id) {';
   l_string := l_string ||'var end = document.editDimensions.dim7.length;';
   l_string := l_string ||'var tempText = document.editDimensions.dim7[end-1].text;';
   l_string := l_string ||'var tempValue = document.editDimensions.dim7.options[end-1].value;';
   l_string := l_string ||'document.editDimensions.dim7[end-1].text = name;';
   l_string := l_string ||'document.editDimensions.dim7.options[end-1].value = id;';
   l_string := l_string ||'document.editDimensions.dim7.options[end] = new Option(tempText,tempValue);';
   l_string := l_string ||'document.editDimensions.dim7.selectedIndex = end-1;';
   l_string := l_string ||'}';


  -- **************************
    --   END MODAL DIALOG CODE
  -- **************************
   l_string := l_string ||'</SCRIPT>';
--end if; --icx_sec.validateSession
   x_string := l_string ;
end editlovjscript;

PROCEDURE setGlobalVar
( p_dim_lev_id     in VARCHAR2
, p_dim_lev_val_id in VARCHAR2
, p_dim_lev_g_var  in VARCHAR2
, x_return_status  out NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BIS_TARGET_PVT.G_SET_OF_BOOK_ID := TO_NUMBER(p_dim_lev_val_id);

END setGlobalVar;

-- *******************************************************
end bis_lov_pub;

/
