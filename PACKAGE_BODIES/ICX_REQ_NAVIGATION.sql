--------------------------------------------------------
--  DDL for Package Body ICX_REQ_NAVIGATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_NAVIGATION" as
/* $Header: ICXREQSB.pls 115.2 99/07/17 03:22:07 porting ship $ */
/*----------------BEGIN Welcome Page--------------- */
/* Welcome page for Requisitions  */
------------------------------------------------------
procedure reqs_welcome_page is
------------------------------------------------------
    v_lang          varchar2(5);
    c_title         varchar2(80);
    c_prompts       icx_util.g_prompts_table;

    v_dcdName       varchar2(1000);

    v_message_caption    varchar2(200);
    v_message_text       varchar2(1000);

    v_0_encrypt		 varchar2(100);
begin

  -- Check if session is valid
  if (icx_sec.validatesession('ICX_REQS')) then

   -- get dcd name
   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

   -- set lang code
   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

   -- encrypt 0
   v_0_encrypt := icx_call.encrypt2('0');

  -- Create the Intro Page


  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_INTRO_TITLE');
  c_title := FND_MESSAGE.GET;

  htp.htmlOpen;
  htp.title(c_title);
  htp.bodyOpen;

  htp.headOpen;

  icx_util.copyright;

  js.scriptOpen;
  htp.p('function help_window(){
        help_win = window.open(''/OA_DOC/' || v_lang || '/awe' ||  '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250");
        help_win = window.open(''/OA_DOC/' || v_lang || '/awe' || '/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250")
}
');

  js.scriptClose;
  htp.headClose;
  -- htp.p('<BODY BACKGROUND="/OA_MEDIA/' || v_lang || '/ICXBCKGR.jpg">');


  -- TOOLBAR
  icx_admin_sig.toolbar(language_code => v_lang);

  htp.p('<table border=0 cellpadding=0><tr>');
  htp.p('<td width=2000 bgcolor=#0000ff height=4><img src=/OA_MEDIA/'||
        v_lang || '/FNDDBPX6.gif height=1 width=1></td></tr></table>');

     htp.p('<table cellspacing=8 cellpadding=0 border=0>');
     htp.p('<tr><td colspan=3>');
  -- The top intro line of the page
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_INTRO_TXT');
  htp.p(FND_MESSAGE.GET || '<p>');
  htp.p('</font></td></tr><tr><td colspan=3>');

  -- The First line of the intro
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_SELECT_ITEMS_TTL');
  v_message_caption := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_SELECT_ITEMS_TXT');
  v_message_text := FND_MESSAGE.GET;
  htp.p('<table border=0 cellpadding=0>');
  htp.p('<tr>');
  htp.p('<td rowspan=2><a href=' || v_dcdName ||
        '/ICX_REQ_NAVIGATION.ic_parent?cart_id=' || v_0_encrypt ||
	'>' || '<img src=/OA_MEDIA/' || v_lang ||
        '/FNDISEL.gif border=no height=75 width=75 align=absmiddle></a></td>');
  htp.p('<td colspan=2 height=4><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIBLBR.gif width=500 height=4></td></tr><tr>');
  htp.p('<td width=50 align=center valign=top><font size=7 color=#0000ff>' ||
        '<b>1</td>');
  htp.p('<td width=1000 valign=top><b><font size=+1 color=#0000ff>' ||
        v_message_caption || '</b></font><br>' || v_message_text ||
        '</td></td></tr></table>');

  -- Second line
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_CHK_ORDER_TTL');
  v_message_caption := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_CHK_ORDER_TXT');
  v_message_text := FND_MESSAGE.GET;
  htp.p('</td></tr><tr>');
  htp.p('<td rowspan=2><font size=7>&nbsp</td>');
  htp.p('<td colspan=2>');
  htp.p('<table border=0 cellpadding=0>');
  htp.p('<tr>');
  htp.p('<td rowspan=2><img src=/OA_MEDIA/' || v_lang ||
        '/FNDICKO.gif height=75 width=75 align = absmiddle></td>');
  htp.p('<td colspan=2 height=4><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIRDBR.gif width=500 height=4></td><tr>');
  htp.p('<td width=50 align=center valign=top><font size=7 color=#cc0000>' ||
        '<b>2</td>');
  htp.p('<td width=1000 valign=top><b><font size=+1 color="#CC0000">' ||
        v_message_caption || '</b></font><br>' || v_message_text || '</td>' ||
        '</tr></table>');

  -- Third line
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_PLACE_ORDER_TTL');
  v_message_caption := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_PLACE_ORDER_TXT');
  v_message_text := FND_MESSAGE.GET;
  htp.p('</td></tr><tr>');
  htp.p('<td rowspan=2><font size=7>&nbsp</td>');
  htp.p('<td colspan=1>');
  htp.p('<table border=0 cellpadding=0>');
  htp.p('<tr>');
  htp.p('<td rowspan=2><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIPLO.gif height=75 width=75 align = absmiddle></td>');
  htp.p('<td colspan=2 height=4><img src=/OA_MEDIA/' || v_lang ||
        '/FNDIGRBR.gif width=500 height=4></td><tr>');
  htp.p('<td width=50 align=center valign=top><font size=7 color=#006666>' ||
        '<b>3</td>');
  htp.p('<td width=1000 valign=top><b><font size=+1 color="#006666">' ||
        v_message_caption || '</b></font><br>' || v_message_text ||
        '<br></td>' || '</tr></table>');

  htp.p('</td></tr></table>');

  htp.p('<center>');
  htp.anchor(v_dcdName || '/ICX_REQ_NAVIGATION.ic_parent?cart_id=' ||
	     v_0_encrypt, htf.img('/OA_MEDIA/' || v_lang ||
	     '/FNDISELS.gif', cattributes => 'BORDER = NO align=absmiddle' ));
  FND_MESSAGE.SET_NAME('ICX', 'ICX_RQS_PROCEED_TTL');
  htp.p('<FONT SIZE=+1>');
  htp.anchor(v_dcdName || '/ICX_REQ_NAVIGATION.ic_parent?cart_id=' ||
	     v_0_encrypt, FND_MESSAGE.GET);
  htp.p('</FONT>');
  htp.p('</center>');

  htp.bodyClose;
  htp.htmlClose;

 end if;

end reqs_welcome_page;

/*----------------END Welcome Page--------------- */


------------------------------------------------------------------------
procedure chk_vendor_on(v_on OUT varchar2) is
------------------------------------------------------------------------

  v_vendor_on_flag varchar2(1);
begin

       v_on := 'N';
       v_vendor_on_flag := 'N';
       for i in ak_query_pkg.g_items_table.first .. ak_query_pkg.g_items_table.last loop
         if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' or
          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_CONTACT' or
          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_PHONE' or
          ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_SITE') and
          ak_query_pkg.g_items_table(i).node_display_flag = 'Y'  and
          ak_query_pkg.g_items_table(i).update_flag = 'Y' and
          ak_query_pkg.g_items_table(i).secured_column <> 'T' and
          ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' then

           v_vendor_on_flag := 'Y';
           exit;
         end if;
       end loop;

       v_on := v_vendor_on_flag;
end chk_vendor_on;
------------------------------------------------------------
procedure replaceQuotes is
------------------------------------------------------------
begin
--
-- Do not use split and join function because it is provided
-- only by Netscape Navigator at this time (12/96).
-- Microsoft IE does not provide that.
--
--
-- FIX THIS
--
-- Fixed by dchu at 1/8/97
        htp.p('function getFront(str,searchStr) {
               var str2 = "" + str;
               var offset = str2.indexOf(searchStr);
               if (offset == -1) {
                  return null;
                }
               return str2.substring(0,offset);
        }');

         htp.p('function getEnd(str,searchStr) {
                var str2 = "" + str;
                var offset = str2.indexOf(searchStr);
                if (offset == -1) {
                    return null;
                }
                return str2.substring(offset+searchStr.length,str2.length);
         }');

       htp.p('function replaceString(qstr,searchStr,repStr) {
               var newstr = qstr;
               var retstr = "";
               var frontStr = getFront(newstr,searchStr);
               var endStr = getEnd(newstr,searchStr);
               if (frontStr == null) {
                  return qstr;
               }
               if (endStr == null) {
                  return frontStr + repStr;
               }
               while (endStr <> null) {
                   retstr = retstr + frontStr + repStr;
                   newstr = endStr;
                   frontStr = getFront(newstr,searchStr);
                   endStr = getEnd(newstr,searchStr);
                   if (frontStr == null && newstr <> null) {
                      retstr = retstr + newstr;
                   }
               }
               return retstr;
        }');

        htp.p('function replaceQuotes(qstr) {

             var newstr = "" + qstr;
             newstr = replaceString(newstr,' || '"''"' || ',"*' || '");
             newstr = replaceString(newstr,''"'',''&quot;'');
             return newstr;

}');

end replaceQuotes;


------------------------------------------------------------
procedure shopper_info(v_shopper_id    IN  number,
                       v_shopper_name  OUT VARCHAR2,
                       v_location_id   OUT number,
                       v_location_code OUT VARCHAR2,
                       v_org_id        OUT NUMBER,
                       v_org_code      OUT VARCHAR2) is
------------------------------------------------------------

   cursor shopper(v_shop_id number) is
      select  hrev.full_name,
              hrl.location_id,
              hrl.location_code,
              ood.organization_id,
              ood.organization_code
      from    hr_locations hrl,
              hr_employees_current_v hrev,
              org_organization_definitions ood,
              financials_system_parameters fsp
      where   hrev.employee_id = v_shop_id
      and     hrev.location_id = hrl.location_id
      and     ood.organization_id = nvl(hrl.inventory_organization_id,
                                     fsp.inventory_organization_id)
      and     sysdate < nvl(hrl.inactive_date, sysdate + 1);

begin

     open shopper(v_shopper_id);
     fetch shopper into v_shopper_name, v_location_id, v_location_code, v_org_id
, v_org_code;
     close shopper;

end shopper_info;

--**********************************************************
-- BEGIN JS PROCEDURES RELATED TO MULTILEVEL HIERARCHY
--**********************************************************

------------------------------------------------------------
procedure create_multilevel_js_functions(v_lang varchar2) is
------------------------------------------------------------
  v_str_errors varchar2(1000);

begin

   FND_MESSAGE.SET_NAME('ICX','ICX_JS_STRING_ERROR');
   v_str_errors := FND_MESSAGE.GET;
   FND_MESSAGE.SET_NAME('ICX','ICX_CONTACT_WEBMASTER');
   v_str_errors := v_str_errors || FND_MESSAGE.GET;


htp.p('
// BEGIN JS PROCEDURES RELATED TO MULTILEVEL HIERARCHY

function node(nId, nName, nChildrenLoaded, nLink, p_where)
{
   this.nodeId = nId;
   this.nodeName = nName;
   this.nodeLink = nLink;
   this.node_p_where = p_where;
   this.children = new MakeArray(0);
   this.childrenLoaded = nChildrenLoaded;
   this.nodeOpen = false;

   // Setup myself in global array
   ALLNODES.length +=1;
   ALLNODES[ALLNODES.length] = this;
   this.arrayIndex = ALLNODES.length;

   // Object Methods
   this.drawNode = drawNode;
   this.addChild = addChild;
}

function addChild( node )
{
   this.children.length += 1;
   this.children[this.children.length] = node;
}

function addChildren( nodeId,field,fieldIndex )
{
  var str = "" + field.value;
  var nodeindex = "" + fieldIndex.value;
  var mySelf = findNode( nodeId,nodeindex );

  if (mySelf == null)
      return;

  while ( str <> "" )
  {
     var index;

     // node id
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return; }
     var nId = str.substring(0,index);
     str = str.substring(index+2,str.length);

     // node name
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return; }

     var nodeName = str.substring(0,index);
     str = str.substring(index+2,str.length);

     // No of children
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return; }

     var nChildren = eval(str.substring(0,index));
     var nChildrenLoaded = false;
     if ( nChildren < 1){
        nChildrenLoaded = true;
     }
     str = str.substring(index+2,str.length);

     // Link
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	 '"); return; }

     var nLink = str.substring(0,index);
     str = str.substring(index+2,str.length);


     // p_where
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return; }

     var p_where = str.substring(0,index);
     str = str.substring(index+2,str.length);

     mySelf.addChild( new node(nId, nodeName, nChildrenLoaded, nLink, p_where));
  }

  mySelf.nodeOpen = true;
  mySelf.childrenLoaded = true;
  field.value = "";
  redraw(); // Redraw the frame
}


function openTemplate( nodeId,field,fieldIndex )
{
  var str = "" + field.value;
  var nodeIndex = "" + fieldIndex.value;
  var mySelf = findNode( nodeId,nodeIndex );

  if (mySelf == null)
      return;

  while ( str <> "" )
  {
     var index;

     // node id
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return;}
     var nId = str.substring(0,index);
     str = str.substring(index+2,str.length);

     // node name
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return;}
     var nodeName = str.substring(0,index);
     str = str.substring(index+2,str.length);

     // No of children
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return;}
     var nChildren = eval(str.substring(0,index));
     var nChildrenLoaded = false;
     if ( nChildren < 1){
        nChildrenLoaded = true;
     }
     str = str.substring(index+2,str.length);

     // Link
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return;}
     var nLink = str.substring(0,index);
     str = str.substring(index+2,str.length);


     // p_where
     index = str.indexOf("~~");
     if (index == -1) {  alert ("' || icx_util.replace_quotes(v_str_errors) ||
	'"); return;}
     var p_where = str.substring(0,index);
     str = str.substring(index+2,str.length);

     mySelf.addChild( new node(nId, nodeName, nChildrenLoaded, nLink, p_where));
  }

  mySelf.nodeOpen = false;
  mySelf.childrenLoaded = true;
  field.value = "";
  redraw(); // Redraw the frame
}


function findNode(nId, nodeIndex){
       if (nodeIndex == "") {
          for (var i=1; i<= ALLNODES.length; i++){
             if ((""+nId) == ("" + ALLNODES[i].nodeId))
                return ALLNODES[i];
          }
       } else {
          for(var i=1; i<= ALLNODES.length; i++){
            if (((""+nId) == ("" + ALLNODES[i].nodeId)) && ((""+nodeIndex) == ("" + ALLNODES[i].arrayIndex)))
              return ALLNODES[i];
          }
       }
       return null;
}
function redraw() {
   top.frames["navigation"].frames["left_frame"].location.href =
   top.frames["navigation"].frames["left_frame"].location.href;

}


function open_node (arrayIndex) {
   if (ALLNODES[arrayIndex].childrenLoaded == false ) {

      // Load the children from the server.
      top.frames["navigation"].frames["dummy"].document.GetChildren.nodeId.value = ALLNODES[arrayIndex].nodeId;
      top.frames["navigation"].frames["dummy"].document.GetChildren.p_where.value = ALLNODES[arrayIndex].node_p_where;
      top.frames["navigation"].frames["dummy"].document.GetChildren.nodeIndex.value = arrayIndex;
      top.frames["navigation"].frames["dummy"].document.GetChildren.submit();
    ALLNODES[arrayIndex].nodeOpen = false;
   } else {
      ALLNODES[arrayIndex].nodeOpen = true;
   }
   redraw(); // Redraw the frame
}



function close_node (arrayIndex) {
   ALLNODES[arrayIndex].nodeOpen = false;
   redraw(); // Redraw the frame
}


function print(str) {
   top.frames["navigation"].frames["left_frame"].document.write(str);
}

function drawNode()
{

   var bold = false;

   var atext = "<nobr><A NAME =" + this.arrayIndex + " TARGET=\"right_frame\" HREF=" + this.nodeLink +
               " onClick=\"imClicked(''" + replaceQuotes(this.nodeId) + "'',''" + this.node_p_where + "'');\">" + replaceQuotes(this.nodeName) + "</A></nobr>";


   if ( "" + this.nodeId == "" + lastCatalog.node_id ||  "" + this.nodeId == "" + lastTemplate.node_id )
            bold = true;

   if ( bold ) {
        atext = "<B>" + atext + "</B>";
   }

   var str = "<dt NOWRAP>";
   if (this.nodeOpen) {
        if (this.children.length <> 0) {
           //Children
           str += "<A NAME =" + this.arrayIndex + " HREF=\"javascript:top.close_node(" + this.arrayIndex + ")\">";

           str += "<IMG SRC=\"/OA_MEDIA/' || v_lang || '/FNDIMNUS.gif\" HEIGHT = 18 WIDTH = 28 BORDER = 0></A>";

           str += atext;

           str += "<dl NOWRAP>";
           for(var i=1; i<=this.children.length; i++)
                  str += this.children[i].drawNode();
             str += "</dl>";
        } else {
           //No Children
           // Dummy image for alignment
           str += "<A><IMG SRC=\"/OA_MEDIA/' || v_lang || '/FNDSPACE.gif\" HEIGHT = 18 WIDTH = 28 BORDER = 0></A>";

           // display the name as a link
           str += atext;
        }
   } else {  // Node is closed
        if (this.childrenLoaded && this.children.length == 0) {
           //No Children  --  Dummy image for alignment
           str += "<A><IMG SRC=\"/OA_MEDIA/' || v_lang || '/FNDSPACE.gif\" HEIGHT = 18 WIDTH = 28 BORDER = 0></A>"

        } else {
          str += "<A NAME =" + this.arrayIndex + " HREF =\"javascript:top.open_node(" + this.arrayIndex + ")\">";
          str += "<IMG SRC=\"/OA_MEDIA/' || v_lang || '/FNDIPLUS.gif\" HEIGHT = 18 WIDTH = 28 BORDER = 0></A>";
        }


        str += atext;
   }
    str += "</dt>";
    return str;
}


function setparenttab(tabName)
{
  parent.tabSynch.tabName = tabName;
}

// Global variables.
ALLNODES = new MakeArray(0);
SELECTED_ARRAY_ID = 0;

// END JS PROCEDURES RELATED TO MULTILEVEL HIERARCHY

');

end create_multilevel_js_functions;



------------------------------------------------------------
procedure synchObject is
------------------------------------------------------------
begin
        htp.p('function synchObject(original_frame) {
        this.tabName = original_frame;
}

tabSynch = new synchObject("template");
');

end synchObject;

------------------------------------------------------------
procedure popWindow is
------------------------------------------------------------
begin
    htp.p('function popWindow(sourceURL) {
        win = window.open(sourceURL, "drillDown", "resizable=yes,scrollbars=yes,width=750,height=300");
        win = window.open(sourceURL, "drillDown", "resizable=yes,scrollbars=yes,width=750,height=300");
}
');

end popWindow;

------------------------------------------------------------
procedure spin_box is
------------------------------------------------------------
begin

   htp.p('function up(field) {
  var emptyCheck = "" + field.value;
 if (emptyCheck == "") {
    field.value = 1;
 } else {
    var numThere = parseFloat(field.value);
    numThere = eval(numThere + 1);
    field.value = numThere;
 }
}
');

   htp.p('function down(field) {


  var emptyCheck = "" + field.value;
 if (emptyCheck <> "") {
    var numThere = parseFloat(field.value);
    if (numThere <= 1) {
       field.value = "";
    } else {
      numThere = eval(numThere - 1);
      field.value = numThere;
    }
 }
}
');

end spin_box;

------------------------------------------------------------
procedure giveWarning is
------------------------------------------------------------
begin

        FND_MESSAGE.SET_NAME('ICX', 'ICX_CART_RMV_ALL');
        htp.p('function giveWarning() {
        if (confirm(''' || icx_util.replace_quotes(FND_MESSAGE.GET) || ''')) {
           return true;
        } else {
           return false;
        }
}
');

end giveWarning;
------------------------------------------------------------
function get_default_template( v_emergency varchar2 )
        return varchar2 is
------------------------------------------------------------

v_return_template  varchar2(25);
v_test             number;

begin

    -- get default template
    v_return_template := icx_sec.getID(icx_sec.PV_USER_REQ_TEMPLATE);

    v_test := 0;

    if v_emergency = 'YES' then
           select count(-1) into v_test
           from   po_reqexpress_headers
           where  express_name = v_return_template
           and    (reserve_po_number = 'YES' OR reserve_po_number = 'OPTIONAL');
    else
           select count(-1) into v_test
           from   po_reqexpress_headers
           where  express_name = v_return_template
           and    (reserve_po_number = 'NO' OR reserve_po_number = 'OPTIONAL' OR reserve_po_number is null);
    end if;

    if v_test = 0 then
          v_return_template := null;
    end if;

    return v_return_template;

end get_default_template;

------------------------------------------------------------
  procedure reqNavigator(v_org_id  number,
                         v_cart_id number   default -1,
                         emergency varchar2 default NULL,
                         v_dcdName varchar2,
                         v_lang    varchar2,
                         v_shopper_id number) is
------------------------------------------------------------

   v_template   varchar2(25);
   v_emergency  varchar2(10);

  begin
    if emergency is null then
        v_emergency := 'NO';
    else
	v_emergency := emergency;
    end if;

    htp.framesetOpen('106,*','','BORDER=0');

    if (v_cart_id = -1) then

	  -- get default template
	  v_template := get_default_template( emergency );
	  if (v_template is null) then
	      v_template := 'none';
	  end if;

          htp.frame(v_dcdName ||
	   '/ICX_REQ_NAVIGATION.top_frame?tab_name=template&emergency=' ||
	   v_emergency,'tabs','0','0','no','NORESIZE', 'FRAMEBORDER=NO');

           htp.frame(v_dcdName || '/ICX_REQ_TEMPLATES.templates?p_where=' ||
                icx_call.encrypt2( '(NEW)' ||
		icx_util.replace_quotes(v_template) || '*' || v_org_id ||
		'**]'), 'navigation','0','0','auto','NORESIZE','FRAMEBORDER=NO');

    else

         htp.frame(v_dcdName ||
		'/ICX_REQ_NAVIGATION.top_frame?tab_name=my_order&emergency=' ||
	        v_emergency,'tabs','0','0','no','NORESIZE', 'FRAMEBORDER=NO');
         htp.frame(v_dcdName || '/ICX_REQ_ORDER.my_order?n_org=' ||
		icx_call.encrypt2(v_org_id) || '&n_emergency=' ||
		icx_call.encrypt2(v_emergency) || '&n_cart_id=' ||
		icx_call.encrypt2(v_cart_id) ,'navigation', '0','0', 'auto',
		'NORESIZE', 'FRAMEBORDER=NO');

    end if;

    htp.framesetClose;

end reqNavigator;


------------------------------------------------------------
  procedure synch(v_org_id     number,
                  v_emergency  varchar2,
		  v_cart_id    number,
		  v_lang       varchar2,
		  v_shopper    number,
		  v_dcdName    varchar2) is
------------------------------------------------------------

    v_template varchar2(100);
    l_encrypt2_org_id number;

  begin

   -- now we need to have a way to store the last items list gone to
   -- to accomplish this, we will store the last place gone in a javascript
   -- object
   htp.p('function itemStorage(p_node_id, p_start_row, p_end_row, v_where){
     this.node_id = p_node_id;
     this.start_row = p_start_row;
     this.end_row   = p_end_row;
     this.p_where   = v_where;
}
');

   -- Now we declare one for the templates and the catalogs
   htp.p('lastCatalog = new itemStorage("", 1, -1,' ||
	 icx_call.encrypt2( '-1' || '*' || v_org_id || '**]') || ');' );


   -- See if there is a default Template
   v_template := get_default_template( v_emergency );
   if v_template is null then
      v_template := 'none';
   end if;
   htp.p('lastTemplate = new itemStorage("' || v_template || '",1,-1,' ||
	 icx_call.encrypt2( v_template || '*' || v_org_id || '**]') || ');');

   -- Now create a function to switch to the correct stuff
   l_encrypt2_org_id := icx_call.encrypt2(to_char(v_org_id));
   htp.p('function switchFrames(tabName) {
  var lastPlace = "";
  tabSynch.tabName = tabName;
  open("' || v_dcdName ||
	'/ICX_REQ_NAVIGATION.top_frame?tab_name="+ tabName+"&emergency=' ||
	v_emergency ||'", ''tabs'');

         if (tabName == "template" ) {
      lastPlace = "' || v_dcdName || '/ICX_REQ_TEMPLATES.templates?p_where=";
      lastPlace += lastTemplate.p_where;
      lastPlace += "&start_row=" + lastTemplate.start_row;
      if (lastTemplate.end_row <> -1)
        lastPlace += "&c_end_row=" + lastTemplate.end_row;
      open(lastPlace, ''navigation'');
  } else if (tabName == "catalog" ) {
      lastPlace = "' || v_dcdName || '/ICX_REQ_CATEGORIES.categories?p_where=";
      lastPlace += lastCatalog.p_where;
      lastPlace += "&start_row=" + lastCatalog.start_row;
      if (lastCatalog.end_row <> -1)
        lastPlace += "&c_end_row=" + lastCatalog.end_row;
      open(lastPlace, ''navigation'');
  } else if (tabName == "item_search" ) {
      open("' || v_dcdName || '/ICX_REQ_SEARCH.itemSearch?n_org='||
	   l_encrypt2_org_id || '", ''navigation'');
  } else if (tabName == "special_order" ) {
      open("' || v_dcdName || '/ICX_REQ_SPECIAL_ORD.special_order?n_org=' ||
   	   l_encrypt2_org_id || '", ''navigation'');

  } else if (tabName == "my_order" ) {
     if (account_dist == "Y") {

       open("' || v_dcdName || '/ICX_REQ_ORDER.my_order?n_org=' ||
        l_encrypt2_org_id || '&n_emergency=' ||
        icx_call.encrypt2(nvl(v_emergency, 'NO')) || '&n_cart_id=' ||
        icx_call.encrypt2(v_cart_id) || '&n_cart_line_id="+cartLineId+"&n_account_dist=Y' || '", ''navigation'');

     } else {

        open("' || v_dcdName || '/ICX_REQ_ORDER.my_order?n_org=' ||
	   l_encrypt2_org_id || '&n_emergency=' ||
	   icx_call.encrypt2(nvl(v_emergency, 'NO')) || '&n_cart_id=' ||
           icx_call.encrypt2(v_cart_id) ||'", ''navigation'');
     }
  }
}
');


    htp.p('function winOpen(locon, tabName) {
   if (parent.tabSynch.tabName <> tabName) {
      parent.tabSynch.tabName = tabName;
      if (locon == ''nav'') {
         open("' || v_dcdName ||
	      '/ICX_REQ_NAVIGATION.top_frame?tab_name="+ tabName+"&emergency='
	      || v_emergency ||'", ''tabs'');
      } else {
         switchFrames( tabName );
      }
   }
 }
');

  end synch;

------------------------------------------------------------
procedure sysadmin_error is
------------------------------------------------------------
    v_lang varchar2(5);

begin
    -- set lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

   htp.htmlOpen;
   htp.headOpen;
   icx_admin_sig.toolbar(language_code => v_lang);
   icx_util.copyright;
   js.scriptOpen;

      htp.p('function help_window() {
           help_win = window.open(''/OA_DOC/' || v_lang  || '/awe' ||
	'/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250"
);
            help_win = window.open(''/OA_DOC/' || v_lang || '/awe' ||
	'/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250"
)}
');
   js.scriptClose;


    htp.headClose;
    htp.bodyOpen('/OA_MEDIA/' || v_lang || '/ICXBCKGR.jpg');

    FND_MESSAGE.SET_NAME('ICX', 'ICX_DATA_INCORRECT');
    icx_util.add_error(FND_MESSAGE.GET);
    icx_util.error_page_print;


    htp.bodyClose;

end sysadmin_error ;

------------------------------------------------------------
procedure top_frame( tab_name    varchar2,
                     emergency   varchar2 default NULL) is
------------------------------------------------------------
   v_lang           varchar2(5);
   v_image_name     varchar2(32);
begin

  if (icx_sec.validatesession('ICX_REQS')) then

    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    htp.htmlOpen;
    htp.headOpen;

    js.scriptOpen;

htp.p('
function help_window(){
            help_win = window.open(''/OA_DOC/' || v_lang || '/awe' ||
	'/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250"
);
            help_win = window.open(''/OA_DOC/' || v_lang || '/awe' ||
	'/icxhlprq.htm'', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,height=250"
)}
');

    js.scriptClose;
    htp.headClose;


    htp.bodyOpen( icx_admin_sig.background(v_lang),
                  cattributes => 'onLoad="parent.winOpen(''tabs'', ''' ||
		  tab_name  || ''')"' );

    icx_admin_sig.toolbar (language_code => v_lang );

     htp.mapOpen('tabsi');

  if ((emergency is null) or (emergency = 'NO')) then
     if (tab_name = 'template' ) then
        v_image_name := '/FNDTREQ1.gif';
     else
        htp.area('17,3,133,20','rect',
		 'javascript:parent.switchFrames(''template'')');
     end if;

     if (tab_name = 'catalog' ) then
        v_image_name := '/FNDTREQ2.gif';
     else
        htp.area('141,3,256,20', 'rect',
		 'javascript:parent.switchFrames(''catalog'')');
     end if;

     if (tab_name = 'item_search' ) then
        v_image_name := '/FNDTREQ3.gif';
     else
        htp.area('264,3,380,20', 'rect',
		 'javascript:parent.switchFrames(''item_search'')');
     end if;

     if (tab_name = 'special_order' ) then
        v_image_name := '/FNDTREQ4.gif';
     else
        htp.area('388,3,504,20', 'rect',
		 'javascript:parent.switchFrames(''special_order'')');
     end if;

     if (tab_name = 'my_order' ) then
        v_image_name := '/FNDTREQ5.gif';
     else
        htp.area('512,3,628,20', 'rect',
		 'javascript:parent.switchFrames(''my_order'')');
     end if;
  else
     if (tab_name = 'template' ) then
        v_image_name := '/FNDTREQ6.gif';    -- New template image
     else
        htp.area('17,3,133,20','rect',
		 'javascript:parent.switchFrames(''template'')');
     end if;

     if (tab_name = 'my_order' ) then
        v_image_name := '/FNDTREQ7.gif';   -- New My order image
     else
        htp.area('141,3,256,20', 'rect',
		 'javascript:parent.switchFrames(''my_order'')');
     end if;
  end if;

     htp.mapClose;


     htp.img2('/OA_MEDIA/' || v_lang ||
	      v_image_name , cusemap=>  '#tabsi', cattributes=> 'BORDER=0' );

     htp.bodyClose;
     htp.htmlClose;

  end if;

end top_frame;


------------------------------------------------
procedure get_po is
------------------------------------------------
begin

      FND_MESSAGE.SET_NAME('ICX', 'ICX_ONE_PO_PER_REQUISITION');
        htp.p('//Reserve a po number.
function get_po(){
   open(top.dcd + "/ICX_REQ_NAVIGATION.get_emergency_po_num?n_org=" + top.org_id, ''navigation'');

}

');
end get_po;

------------------------------------------------------------
procedure ic_parent(cart_id   in varchar2,
                    emergency in varchar2  default NULL ) is
------------------------------------------------------------

   cursor DETERMINE_CART(v_cart_id number, v_shopper_id number) is
          select count(-1)
          from   icx_shopping_carts_v
          where  cart_id = v_cart_id
	  and    shopper_id = v_shopper_id;

--change by alex for attachment
--   cursor getCartId is
--	  select icx_shopping_Carts_s.nextval from sys.dual;
--new code:
      cursor getCartId is
	  select PO_REQUISITION_HEADERS_S.nextval from sys.dual;


   cursor getDate(increment number) is
        SELECT sysdate+increment from sys.dual;

   v_cart_id number;
   v_language varchar2(30);

   v_money_precision number;

   v_function_code varchar2(20) := 'ICX_REQS';

   c_title         varchar2(80);
   c_prompts       icx_util.g_prompts_table;

   v_dcdName varchar2(1000);

   v_emergency       varchar2(10);

   v_cart_there	     number;
   v_sysdate	     date;
   v_oo_id	     number;
   newCart	     Boolean := FALSE;
   v_dist_id	     number;
   shopper_id	     number;
   employee_id 	     number;
   shopper_name      varchar2(250);
   v_org_id 	     number;
   v_req_num	     number;
   v_location_id     number;
   v_need_by_date    date;
   v_location_code   varchar2(240);
   v_org_code	     varchar2(30);
   l_emer	     varchar2(1);

l_timer_begin number;
l_timer number;

Begin


-- Check if session is valid
if (icx_sec.validatesession(v_function_code)) then

   -- decrypt parameters
   begin
      v_cart_id := icx_call.decrypt2(cart_id);
      v_emergency := icx_call.decrypt2(emergency);
   exception
   when others then
        v_cart_id := -1;
   end;

   -- Get dcd
   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');
   -- get language
   v_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   -- get shopper id
   shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   -- get employee_id ( Internal Contect ID )
   employee_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);
   -- get org id
   v_oo_id := icx_sec.getId(icx_sec.PV_ORG_ID);

   if ((v_cart_id = -1)) then
      v_function_code := '-1';
   end if;

   if v_emergency = 'YES' then
        v_function_code := 'ICX_EMG_REQS';
   else
        v_function_code := 'ICX_REQS';
   end if;

   -- icx_util.getPrompts(178,'ICX_PARENT_TEMPLATE',c_title,c_prompts);
   icx_util.getPrompts(601,'ICX_PARENT_TEMPLATE',c_title,c_prompts);

   -- Get the org id from shopper_id
   ICX_REQ_NAVIGATION.shopper_info(employee_id, shopper_name, v_location_id, v_location_code, v_org_id, v_org_code);

   if ((employee_id is null) or (v_org_id is null))then
      sysadmin_error;
      return;
   end if;

   --
   -- Determined if the cart is saved cart
   OPEN DETERMINE_CART(v_cart_id, shopper_id);
      FETCH DETERMINE_CART INTO v_cart_there;
   CLOSE DETERMINE_CART;
   if v_cart_there = 0 then
      newCart := TRUE;
         -- the cart cart does not exist create it
      open getCartId;
      fetch getCartId into v_cart_id;
      close getCartId;

       -- get a requisition number

            SELECT to_char(current_max_unique_identifier +1),
		   sysdate,
		   icx_cart_distributions_s.nextval
            INTO   v_req_num, v_sysdate, v_dist_id
            FROM   po_unique_identifier_control
            WHERE  table_name = 'PO_REQUISITION_HEADERS'
            FOR UPDATE OF current_max_unique_identifier;

            UPDATE po_unique_identifier_control
            SET    current_max_unique_identifier =
                   current_max_unique_identifier+1
            WHERE  table_name = 'PO_REQUISITION_HEADERS';

	    commit;

            OPEN  getDate(nvl(icx_sec.getID(icx_sec.PV_USER_REQ_DAYS_NEEDED_BY), 0));
            FETCH getDate into v_need_by_date;
            CLOSE getDate;

            if v_emergency is null or v_emergency = 'NO' then
		l_emer := 'N';
	    else
	        l_emer := 'Y';
	    end if;

        insert into icx_shopping_carts (
        cart_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        shopper_id,
	saved_flag,
	approver_id,
	approver_name,
        deliver_to_requestor_id,
	deliver_to_requestor,
        need_by_date,
        destination_type_code,
        destination_organization_id,
        deliver_to_location_id,
	deliver_to_location,
        req_number_segment1,
	emergency_flag,
        org_id
        ) values (
	v_cart_id,
	v_sysdate,
	shopper_id,
	v_sysdate,
	shopper_id,
	shopper_id,
	1,
	NULL,
	NULL,
	employee_id,
	shopper_name,
	v_need_by_date,
	'EXPENSE',
	v_org_id,
	v_location_id,
	v_location_code,
	v_req_num,
	l_emer,
	v_oo_id);

        insert into icx_cart_distributions (
	cart_id,
	DISTRIBUTION_ID,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	ORG_ID) values (
	v_cart_id,
	v_dist_id,
	shopper_id,
	v_sysdate,
        shopper_id,
        v_sysdate,
        shopper_id,
	v_oo_id);

        -- Call user custum defualt for the head
	-- icx_req_custom.reqs_validate_head(v_emergency, v_cart_id);
        -- Validate changed to default. Sai 8/6/97
	icx_req_custom.reqs_default_head(v_emergency, v_cart_id);

   end if;

   htp.htmlOpen;
   htp.headOpen;
   icx_util.copyright;
   htp.title(c_title);



   js.scriptOpen;

   ICX_REQ_NAVIGATION.create_multilevel_js_functions(v_language);
   js.arrayCreate;
   replaceQuotes;

   htp.p('// GLOBALS
org_id = "' || icx_call.encrypt2(to_char(v_org_id)) || '";
');

   ICX_REQ_NAVIGATION.synchObject;
   js.checkNumber;
   js.checkValuePos;
   ICX_REQ_NAVIGATION.spin_box;
   ICX_REQ_NAVIGATION.giveWarning;
   ICX_REQ_NAVIGATION.popWindow;

   htp.p('cartId = "' || icx_call.encrypt2(to_char(v_cart_id)) || '";');
   htp.p('emergency = "' || icx_call.encrypt2(v_emergency) || '";');
   htp.p('account_dist= "";');
   htp.p('cartLineId = "";');

   ICX_REQ_NAVIGATION.synch(v_org_id,v_emergency,v_cart_id,v_language,shopper_id,v_dcdName);
   ICX_REQ_CATEGORIES.GetCategoryTop(v_org_id);
   ICX_REQ_TEMPLATES.GetTemplateTop(v_org_id, v_emergency);
   js.scriptClose;


   htp.headClose;

   if (newCart) then
       reqNavigator(v_org_id, emergency=> v_emergency, v_dcdName => v_dcdName, v_lang => v_language, v_shopper_id => shopper_id);
   else

       js.scriptOpen;
       htp.p('setparenttab("my_order");');
       js.scriptClose;
         reqNavigator(v_org_id, v_cart_id, emergency=> v_emergency, v_dcdName => v_dcdName, v_lang => v_language, v_shopper_id => shopper_id);
   end if;


   htp.htmlClose;

 end if;

exception
   when others then
        htp.p(SQLERRM);

end ic_parent;

------------------------------------------------------------
function addURL(URL          varchar2,
                display_text varchar2)
  return varchar2 is
------------------------------------------------------------
v_return   varchar2(2000);

begin
        if URL is null then
           v_return := display_text;
        else
        v_return := htf.anchor('javascript:top.popWindow(''' || URL || ''')', display_text);
        end if;

      return v_return;

end addURL;


------------------------------------------------------------
procedure Copy_Req_to_Cart(p_req_header_id varchar2) is
------------------------------------------------------------

   v_req_header_id number;
   v_req_num varchar2(50);
   v_dlvr_loc_id number;
   v_req_id number;
   v_dest_org_id number;
   v_dest_code varchar2(25);
   v_buyer_note varchar2(240);
   v_preparer_id number;
   v_req_status varchar2(30);
   v_web_user_id number;
   v_cart_id number;
   v_cart_line_id number;
   v_line_dist_id number;
   v_emergency varchar2(10);
   v_org_id number;
   v_dist_num number;

   cursor emergency_check(reqheader number) is
--     select header_attribute7
--     from po_requisitions_interface
--     where requisition_header_id = reqheader;
      select attribute7
      from po_requisition_headers
      where requisition_header_id = reqheader;

   cursor reqlines(reqheader number) is
      select requisition_line_id
      from po_requisition_lines
      where requisition_header_id = reqheader;

   cursor get_item_number(v_cart_id number,v_cart_line_id number) is
      select concatenated_segments
      from mtl_system_items_kfv a,
           icx_shopping_cart_lines b
      where a.inventory_item_id = b.item_id
      and a.organization_id = b.destination_organization_id
      and b.cart_line_id = v_cart_line_id
      and b.cart_id = v_cart_id;

  cursor reqdistributions(v_cart_id number, v_cart_line_id number) IS
     SELECT distribution_id, charge_account_id
     FROM icx_cart_line_distributions
     WHERE cart_id = v_cart_id
     AND   cart_line_id = v_cart_line_id;

   l_item_number varchar2(80);
   l_emer varchar(10);
   l_cart_line_number number;
   l_shopper_name varchar2(1000);
   l_location_id number;
   l_location_code varchar2(1000);
   l_org_id number;
   l_org_code varchar2(1000);
   l_dist_num number;
   v_activity_name varchar2(1000);

   cursor getactname(req_header_id varchar2) is
      select pa.instance_label
      from   wf_item_activity_statuses ias,
             wf_process_activities pa,
             wf_activities_vl ac,
             wf_activities_vl ap,
             wf_items i
      where   ias.item_type = 'POREQ'
      and     ias.item_key  = req_header_id
      and     ias.process_activity    = pa.instance_id
      and     pa.activity_name        = ac.name
      and     pa.activity_item_type   = ac.item_type
      and     pa.process_name         = ap.name
      and     pa.process_item_type    = ap.item_type
      and     pa.process_version      = ap.version
      and     i.item_type             = 'POREQ'
      and     i.item_key              = ias.item_key
      and     i.begin_date between ac.begin_date and nvl(ac.end_date, i.begin_date)
      and     ias.activity_status = 'NOTIFIED'
      order by ias.execution_time;


begin

  -- decrypt parameters
  v_req_header_id := icx_call.decrypt(p_req_header_id);

  v_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);

    -- get the preparer,
    select preparer_id, authorization_status
    into v_preparer_id, v_req_status
    from po_requisition_headers
    where requisition_header_id = v_req_header_id;

  ICX_REQ_NAVIGATION.shopper_info(v_preparer_id,l_shopper_name,l_location_id,l_location_code,l_org_id,l_org_code);

  if (v_req_status = 'CANCELLED') then
    icx_util.error_page_setup;
    fnd_message.set_name('ICX', 'ICX_REQ_PREV_CANCEL');
    icx_util.add_error(fnd_message.get);
    htp.htmlOpen;
    icx_util.error_page_print;
    htp.htmlClose;
  else
/* 812757
should add code to call  ICX_PO_REQS_CANCEL_SV.update_web_reqs_status
directly instead of  poreqwf.doCancel... will implement later..
    -- cancel the current req
     poreqwf.doCancel('POREQ', v_req_header_id);

     v_activity_name := NULL;

     for prec in getactname(v_req_header_id) loop
        v_activity_name := prec.instance_label;
     end loop;

     WF_ENGINE.COMPLETEACTIVITY(itemtype => 'POREQ',
                                 itemkey => to_char(v_req_header_id),
				 activity => v_activity_name,
                              --   activity => 'PO_REQ_NTF_REJECTED',
                              --   activity => '14',
                                 result => 'CANCEL');
*/
/* this only works in wkflow 2.0
    wf_engine.HandleError(itemtype => 'POREQ',
                          itemkey => to_char(v_req_header_id),
                          activity => 'PO_RAP',
                          command => 'SKIP',
                          result => 'CANCELLED');
*/

    -- get a new requisition number

    select to_char(current_max_unique_identifier +1)
    into   v_req_num
    from   po_unique_identifier_control
    WHERE  table_name = 'PO_REQUISITION_HEADERS'
    FOR UPDATE OF current_max_unique_identifier;

    UPDATE po_unique_identifier_control
    SET current_max_unique_identifier = current_max_unique_identifier+1
    WHERE table_name = 'PO_REQUISITION_HEADERS';

    commit;

    -- get some req line info
    -- get info for 1 record only, since current functionality has the
    --  same deliver to, dest type, etc. for all lines
    select deliver_to_location_id, destination_type_code,
                destination_organization_id, note_to_agent
        into v_dlvr_loc_id, v_dest_code, v_dest_org_id, v_buyer_note
        from po_requisition_lines
        where requisition_header_id = v_req_header_id
        and rownum = 1;

    -- get the web user based on who the preparer was
--USE ICX_SEC.getID API's here.
--    select web_user_id
--    into v_web_user_id
--    from icx_web_users
--    where internal_contact_id = v_preparer_id;

    v_web_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

   -- check if this is an emergency po
    open emergency_check(v_req_header_id);
    fetch emergency_check into v_emergency;
    close emergency_check;

    if v_emergency is NOT NULL then
       v_emergency := 'YES';
       l_emer := 'Y';
    else
       v_emergency := NULL;
       l_emer := 'N';
    end if;

--changed by alex for attachment
--    select icx_shopping_carts_s.nextval
--    into v_cart_id
--    from sys.dual;
--new code:
 	select PO_REQUISITION_HEADERS_S.nextval
	into v_cart_id
	from sys.dual;


    insert into icx_shopping_carts (
        cart_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        shopper_id,
        deliver_to_requestor_id,
        need_by_date,
        destination_type_code,
        destination_organization_id,
        deliver_to_location_id,
        note_to_approver,
        note_to_buyer,
        saved_flag,
        req_number_segment1,
--        approver_id,
--        approver_name,
        header_description,
        header_attribute_category,
        reserved_po_num,
        header_attribute1,
        header_attribute2,
        header_attribute3,
        header_attribute4,
        header_attribute5,
        header_attribute6,
        header_attribute7,
        header_attribute8,
        header_attribute9,
        header_attribute10,
        header_attribute11,
        header_attribute12,
        header_attribute13,
        header_attribute14,
        header_attribute15,
        emergency_flag,
        deliver_to_location,
	deliver_to_requestor,
        org_id
        ) select
        v_cart_id,
        sysdate,
        rh.last_updated_by,
        sysdate,
        rh.created_by,
        v_web_user_id,
        v_preparer_id,
        sysdate,
        v_dest_code,
        v_dest_org_id,
        v_dlvr_loc_id,
        rh.note_to_authorizer,
        v_buyer_note,
        3,
         v_req_num,
--        approver_id,
--        approver_name,
        description,
        attribute_category,
        attribute7,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        l_emer,
        l_location_code,
        l_shopper_name,
        v_org_id
    from po_requisition_headers rh
    where requisition_header_id = v_req_header_id;

--add by alex
--copy attachment for the header
    fnd_attached_documents2_pkg.copy_attachments('PO_REQUISITION_HEADERS',
						 v_req_header_id,
						 '',
						 '',
						 '',
						 '',
						 'PO_REQUISITION_HEADERS',
						 v_cart_id,
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '');

    -- insert a default req distribtuion line
    insert into icx_cart_distributions
    (cart_id,
     distribution_id,
     last_updated_by,
     last_update_date,
     last_update_login,
     creation_date,
     created_by,
     org_id)
    select
        v_cart_id,
        icx_cart_distributions_s.nextval,
        rh.last_updated_by,
        sysdate,
        rh.created_by,
        sysdate,
        rh.created_by,
        v_org_id
    from po_requisition_headers rh
    where requisition_header_id = v_req_header_id;


    -- for line_id, insert po_lines.po_line_id if possible; otherwise,
    --  insert -999 instead of inserting just null
    --
    l_cart_line_number := 0;
    l_dist_num := 0;
    for prec in reqlines(v_req_header_id) loop

    l_cart_line_number := l_cart_line_number + 1;

--changed by alex for attachment
--    select icx_shopping_cart_lines_s.nextval into v_cart_line_id from dual;
-- new code:
    select PO_REQUISITION_LINES_S.nextval into v_cart_line_id from dual;


    insert into icx_shopping_cart_lines (
        cart_line_id,
	cart_line_number,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        cart_id,
        item_id,
        item_revision,
        unit_of_measure,
        quantity,
        unit_price,
        suggested_vendor_item_num,
        category_id,
        line_type_id,
        item_description,
        suggested_vendor_name,
        suggested_vendor_site,
        destination_organization_id,
        deliver_to_location_id,
        autosource_doc_header_id,
        autosource_doc_line_num,
     --   status_flag,
     --   acct_id,
     --   acct_num,
        line_id,
        line_attribute_category,
        line_attribute1,
        line_attribute2,
        line_attribute3,
        line_attribute4,
        line_attribute5,
        line_attribute6,
        line_attribute7,
        line_attribute8,
        line_attribute9,
        line_attribute10,
        line_attribute11,
        line_attribute12,
        line_attribute13,
        line_attribute14,
        line_attribute15,
        custom_defaulted,
        deliver_to_location,
        org_id
        ) select
        v_cart_line_id,
        l_cart_line_number,
        sysdate,
        rl.last_updated_by,
        sysdate,
        rl.created_by,
        v_cart_id,
        rl.item_id,
        rl.item_revision,
        rl.unit_meas_lookup_code,
        rl.quantity,
        rl.unit_price,
        rl.suggested_vendor_product_code,
        rl.category_id,
        rl.line_type_id,
        rl.item_description,
        rl.suggested_vendor_name,
        rl.suggested_vendor_location,
        rl.destination_organization_id,
        rl.deliver_to_location_id,
        rl.blanket_po_header_id,
        rl.blanket_po_line_num,
--      decode(pl.po_line_id, null, -999, pl.po_line_id),
        -999,
        rl.attribute_category,
        rl.attribute1,
        rl.attribute2,
        rl.attribute3,
        rl.attribute4,
        rl.attribute5,
        rl.attribute6,
        rl.attribute7,
        rl.attribute8,
        rl.attribute9,
        rl.attribute10,
        rl.attribute11,
        rl.attribute12,
        rl.attribute13,
        rl.attribute14,
        rl.attribute15,
        'N',
        l_location_code,
        v_org_id
     from po_requisition_lines rl
     where rl.requisition_header_id = v_req_header_id
     and rl.requisition_line_id = prec.requisition_line_id;


--add by alex
--copy attachment for the header
    fnd_attached_documents2_pkg.copy_attachments('PO_REQUISITION_LINES',
						 v_req_header_id,
						 prec.requisition_line_id,
						 '',
						 '',
						 '',
						 'PO_REQUISITION_LINES',
						 v_cart_id,
						 v_cart_line_id,
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '',
						 '');


     l_item_number := NULL;
     open get_item_number(v_cart_id,v_cart_line_id);
     fetch get_item_number into l_item_number;
     close get_item_number;

     if l_item_number is not NULL then

       update icx_shopping_cart_lines
       set item_number = l_item_number
       where cart_id = v_cart_id
       and cart_line_id = v_cart_line_id;

    end if;

    select icx_cart_line_distributions_s.nextval into v_line_dist_id from dual;
    l_dist_num := l_dist_num + 1;

    insert into icx_cart_line_distributions
    (cart_line_id,
   cart_id,
   distribution_id,
   last_updated_by,
   last_update_date,
   last_update_login,
   creation_date,
   created_by,
   charge_account_id,
   accrual_account_id,
   variance_account_id,
   budget_account_id,
   distribution_num,
   allocation_type,
   allocation_value,
   org_id)
   select v_cart_line_id,
   v_cart_id,
   v_line_dist_id,
   rd.last_updated_by,
   sysdate,
   rd.last_update_login,
   sysdate,
   rd.created_by,
   rd.code_combination_id,
   rd.accrual_account_id,
   rd.variance_account_id,
   rd.budget_account_id,
   l_dist_num,
   rd.allocation_type,
   rd.allocation_value,
   v_org_id
   from po_req_distributions rd,
        po_requisition_lines rl
--        po_lines pl
--   where rd.requisition_line_id = rl.requisition_line_id
    where rd.requisition_line_id = prec.requisition_line_id
    and rl.requisition_header_id = v_req_header_id
--    and rl.blanket_po_header_id = pl.po_header_id(+)
    and rl.requisition_line_id = rd.requisition_line_id;
--    and rl.blanket_po_line_num = pl.line_num(+);

   -- call to update charge acount segments based on inserted account id
   icx_req_acct2.update_account_by_id(v_cart_id,v_cart_line_id,v_org_id,v_line_dist_id,l_dist_num);


      -- Update the distribution num column in distributions table.
      -- This is required as the view  of ICX_SHOPPING_CART_LINES_V has
      -- join condition as DISTRIBUTION_NUM = 1.
      -- The reqs from sources other than web reqs may not have populated
      -- the distribuion number.

      v_dist_num := 1;

      FOR distribution IN reqdistributions(v_cart_id, v_cart_line_id) LOOP

        UPDATE icx_cart_line_distributions
        SET distribution_num = v_dist_num
        WHERE cart_id = v_cart_id
        AND   cart_line_id = v_cart_line_id
        AND   distribution_id = distribution.distribution_id;

        -- Update the invidual segments from the account id.
        -- This need to done because the invidual segments are not
        -- available from po_req_distributions table.
        icx_req_acct2.update_account_by_id( v_cart_id => v_cart_id,
                                            v_cart_line_id => v_cart_line_id,
                                            v_oo_id => v_org_id,
                                            v_distribution_id => distribution.distribution_id,
                                            v_line_number => v_dist_num);

        v_dist_num := v_dist_num + 1;

      END LOOP; /* FOR distribution */

   end loop;

-- fill in cart id here.  I suggest using a new one
    -- Show the page, displaying this new shopping cart
    if v_emergency is NULL then
      ICX_REQ_NAVIGATION.ic_parent(icx_call.encrypt2(to_char(v_cart_id)));
    else
      ICX_REQ_NAVIGATION.ic_parent(icx_call.encrypt2(to_char(v_cart_id)),icx_call.encrypt2(v_emergency));
    end if;

  end if;  -- v_req_status

end Copy_Req_to_Cart;

------------------------------------------------------------
procedure get_currency(v_org        in  number,
                       v_currency   out varchar2,
                       v_precision  out number,
                       v_fmt_mask   out varchar2) is
------------------------------------------------------------
   cursor getCurrency is
   select gsob.CURRENCY_CODE,
          fc.PRECISION
   from   gl_sets_of_books gsob,
          FND_CURRENCIES fc,
          org_organization_definitions ood
   where  ood.ORGANIZATION_ID = v_org
   and    fc.CURRENCY_CODE = gsob.CURRENCY_CODE
   and    ood.SET_OF_BOOKS_ID = gsob.SET_OF_BOOKS_ID;

   i          number := 0;
   v_return   varchar2(32);
 begin

   open getCurrency;
   fetch getCurrency into v_currency, v_precision;
   close getCurrency;


  v_return := '999999999D';
  for i in 1 .. v_precision loop
     v_return := v_return || '9';
  end loop;
  v_fmt_mask := v_return;

 end get_currency;



end ICX_REQ_NAVIGATION;

/
