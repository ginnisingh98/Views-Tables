--------------------------------------------------------
--  DDL for Package Body MSD_SSWA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SSWA" AS
/* $Header: msddsplb.pls 120.1 2005/10/28 06:27:28 ziahmed noship $ */

procedure display_plans is
begin
  null;
end display_plans;


/**
  * This procedure will render the header for the page, including
  * product branding and user prompt.
 */
procedure render_header is
begin
   -- show copyright in source
   icx_util.copyright;
   htp.headOpen;
   htp.title(fnd_message.get_string('MSD','APPLICATION.TITLE'));

   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('<!-- Hide from old browsers');
   icx_admin_sig.help_win_script('about',null,'MSD');

   -- define window launching javascript function
   htp.p('function startPlan(_url)
         {
                var _browser_name = navigator.appName;
                var _browser_ver = navigator.appVersion.substring(0, 3);
		var _screen_height = screen.availHeight - 50;
		var _screen_width  = screen.availWidth - 15;

           winParms="height="+screen.availHeight-50+",width="+screen.availWidth-15+",toolbar=no,status=yes,location=no,menubar=no,resizable=yes,scrollbars=yes,top=0,left=0,screenX=0,screenY=0";
           _url = _url + "BRWS=" + _browser_name + "/BRWS_VER=" + _browser_ver + "/SCR_HT=" + _screen_height + "/SCR_WD=" + _screen_width  + "/DUMMY="+Math.random();
           window.open(_url,"ODPwindow",winParms);
          }');
   htp.p('// -->');
   htp.p('</SCRIPT>');
   htp.headClose;

   htp.bodyOpen( cattributes => 'BGCOLOR=white');
   htp.p(get_branding_html('Y'));

  -- display demand plan prompt
  htp.p('<table cellpadding="0" cellspacing="0" border="0" width="100%">
           <tr><td width="100%" class="OraHeaderSub">'||
           fnd_message.get_string('MSD','MSD_DP_SELECTPLAN') ||
          '</td></tr>
           <tr><td class="OraBGAccentDark"></td></tr>
         </table><br>');

end render_header;


/**
  * This function will return HTML for the standard Oracle BLAF top-level page header,
  * with product branding. If the p_show_buttons parameter is Y, then standard action
  * buttons (Return, Menu, Help) are also displayed.
  *
  * Called internally from render_header and from the DML procedure SW.GETJAVATB.
 */
function get_branding_html(p_show_buttons varchar2 default 'N') return varchar2 is
  v_ret varchar2(4000);
  v_return varchar2(4000) := fnd_message.get_string('ICX','ICX_POR_TAB_MAIN_MENU');
  v_help   varchar2(4000) := fnd_message.get_string('FND','HELP');
  v_menu   varchar2(4000) := fnd_message.get_string('FND','MENU');

begin
  v_ret := '<link rel="stylesheet" type="text/css" href="/OA_HTML/cabo/styles/blaf.css">
    <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr><td rowspan=2 valign=bottom width=371>
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr align=left><td height=30><img src=/OA_MEDIA/bisorcl.gif border=no height=23 width=141></a></td>
     <tr align=left> <td valign=bottom>
       <table cellpadding="0" cellspacing="0" border="0" width="340" height="70"
              background="/OA_MEDIA/biscollg.gif">
         <tr>
            <td width="30"></td>
            <td valign="top" class="p_OraProductBrandingText">Demand Planning</td>
         </tr>
       </table>
     </td></td></tr>
     </table>
     </td>';

     -- display buttons
     if (p_show_buttons = 'Y') then
       v_ret := v_ret || '<td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href=Oraclemypage.home><img alt="'||v_return||'" src=/OA_MEDIA/bisrtrnp.gif width=32 border=0 height="32"></a></td>
          <td width=60 align=center><a href=OracleNavigate.Responsibility><img alt="'||v_menu||'" src=/OA_MEDIA/bisnmenu.gif width="32" border=0 height=32></a></td>
          <td width=60 align=center valign=bottom><a href="javascript:help_window()"><img alt="'||v_help||'" src=/OA_MEDIA/bisnhelp.gif border=0  width =32 height=32></a></td>
        </tr>
        <tr align=center valign=top>
          <td width=60><a href=Oraclemypage.home><span class="OraGlobalButtonText">'||v_return||'</span></a></td>
          <td width=60><a href=OracleNavigate.Responsibility><span class="OraGlobalButtonText">'||v_menu||'</span></a></td>
          <td width=60><a href="javascript:help_window()"><span class="OraGlobalButtonText">'||v_help||'</span></a></td>
        </tr></table>
    </td>';
    end if;

    v_ret := v_ret || '</tr></table>
  <table Border=0 cellpadding=0 cellspacing=0 width=100%>
  <tbody>
  <tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src=/OA_MEDIA/bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src=/OA_MEDIA/bisspace.gif width=1></td>
    <td bgcolor=#31659c height=21>&nbsp;</td>
    <td background=/OA_MEDIA/bisrhshd.gif height=21 width=5><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c height=16 width=9><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=9></td>
    <td bgcolor=#31659c height=16 width=5><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=5></td>
    <td background=/OA_MEDIA/bisbot.gif width=1000><img align=top height=16 src=/OA_MEDIA/bistopar.gif width=26></td>
    <td align=left valign=top width=5><img height=8 src=/OA_MEDIA/bisrend.gif width=8></td>
  </tr>
  <tr>
    <td align=left background=/OA_MEDIA/bisbot.gif height=8 valign=top width=9><img height=8 src=/OA_MEDIA/bislend.gif width=10></td>
    <td background=/OA_MEDIA/bisbot.gif height=8 width=5><img border=0 height=1 src=/OA_MEDIA/bisspace.gif width=1></td>
    <td align=left valign=top width=1000><img height=8 src=/OA_MEDIA/bisarchc.gif width=9></td>
    <td width=5></td>
  </tr>
  </tbody>
</table>';

  return v_ret;

end get_branding_html;


/**
 * This procedure will access the batch log for the given
 * demand plan, and display it through htp.p calls.
*/
procedure show_batch_log (p_path varchar2, p_id number) is
  input_file   utl_file.file_type;
  input_buffer varchar2(4000);
  v_filename varchar2(4000);

begin
  v_filename := 'MSD' || p_id || '_dpbatch.html';
  input_file := utl_file.fopen(p_path,v_filename, 'R');

  loop
    utl_file.get_line (input_file, input_buffer);
    htp.p(input_buffer);
  end loop;

  EXCEPTION
    WHEN OTHERS then
      utl_file.fclose_all;

end show_batch_log;


/**
 * This procedure will access the batch log for the given
 * demand plan, and display it through htp.p calls.
*/
function get_batch_log (p_id number) return clob is
  input_file   utl_file.file_type;
  input_buffer varchar2(4000);
  v_filename varchar2(4000);
  v_clob clob;

begin
  dbms_lob.createtemporary(v_clob,TRUE);
  v_filename := 'MSD' || p_id || '_dpbatch.html';
  input_file := utl_file.fopen(fnd_profile.value('MSD_DIR_ALIAS'),v_filename, 'R');

  loop
    utl_file.get_line(input_file, input_buffer);
    if (length(input_buffer) > 0) then
      dbms_lob.writeappend(v_clob,length(input_buffer),input_buffer);
      --dbms_output.put_line(substr(input_buffer,1,100));
    end if;
  end loop;
  return v_clob;

  EXCEPTION
    WHEN OTHERS then
      utl_file.fclose_all;
      --dbms_output.put_line(substr(sqlerrm,1,250));
      return v_clob;

end get_batch_log;


end MSD_SSWA;

/
