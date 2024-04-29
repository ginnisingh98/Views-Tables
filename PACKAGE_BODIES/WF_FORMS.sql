--------------------------------------------------------
--  DDL for Package Body WF_FORMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_FORMS" as
/* $Header: wffrmb.pls 120.3 2005/10/04 05:19:04 rtodi ship $ */

--
-- Applet
--   Generate the applet tag for WFForms
-- IN
--   fname - form function with format 'func1:PARAM1="&ID" PARAM2="&NAME"'
--   port - port listened by the socket listener
--   codebase - where the java classes can be located
--   code - name for the class
--   archive  - first looks for java classes at this archive
--
-- OUT
--   status - true if is permitted to launch, false otherwise
--
procedure Applet(fname    in  varchar2,
                 dispname in  varchar2 ,
                 port     in  varchar2 ,
                 codebase in  varchar2 ,
                 code     in  varchar2 ,
                 archive  in  varchar2 ,
                 status   out nocopy boolean)
is
  l_func  varchar2(240);
  l_colon pls_integer;
begin
  l_colon := instr(fname, ':');
  if (l_colon <> 0) then
    l_func := substr(fname, 1, l_colon - 1);
  else
    l_func := fname;
  end if;

  if (Fnd_Function.Test(l_func)) then
    htp.p('<A HREF="javascript:window.open(''wf_forms.AppletWindow?fname='
          ||wfa_html.conv_special_url_chars(fname)
          ||'&port='||port||'&codebase='||codebase||'&code='||code
          ||'&archive='||archive||''',''formapplet'','||
          '''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=250,height=100'''
          ||');window.history.go(0);" >'||
          '<IMG SRC="'||wfa_html.image_loc||'wffrmdoc.gif" ALT="'||
          dispname||'" BORDER=no></A>');
    status := TRUE;
  else
    htp.p('<IMG SRC="'||wfa_html.image_loc||'wfdc_off.gif" ALT="">');
    status := FALSE;
  end if;
exception
  when others then
    status := FALSE;
    wf_core.context('Wf_Forms', 'Applet', fname, port);
    raise;
end Applet;

--
-- AppletWindow
--   Generate the applet window to call up a form
-- IN
--   fname - form function with format 'func1:PARAM1="&ID" PARAM2="&NAME"'
--   port - port listened by the socket listener
--   codebase - where the java classes can be located
--   code - name for the class
--   archive  - first looks for java classes at this archive
--
procedure AppletWindow(fname    in  varchar2,
                       port     in  varchar2 ,
                       codebase in  varchar2 ,
                       code     in  varchar2,
                       archive  in  varchar2 )
is
  l_archive varchar2(2000) := Wf_Forms.java_loc||
                     'oracle/apps/fnd/jar/wffrm.jar,'||
                     Wf_Forms.java_loc||'oracle/apps/fnd/jar/fndewt.jar,'||
                     Wf_Forms.java_loc||'oracle/apps/fnd/jar/fndswing.jar,'||
                     Wf_Forms.java_loc||'oracle/apps/fnd/jar/fndbalishare.jar';
  l_func  varchar2(240);
  l_colon pls_integer;
  l_ie_plugin_ver varchar2(80);  -- IE version is delimited by ','
begin
  if (archive is not null) then
    l_archive := archive;
  end if;

  l_colon := instr(fname, ':');
  if (l_colon <> 0) then
    l_func := substr(fname, 1, l_colon - 1);
  else
    l_func := fname;
  end if;

  htp.p('<HTML><META HTTP-EQUIV="expires" CONTENT="0">');
  htp.p('<HEAD>');
  htp.p('<TITLE>'||wf_core.translate('WFFRM_LAUNCHING')||'</TITLE>');
  htp.p('</HEAD>');

  htp.p('<!-- debug info -->');
  htp.p('<!-- fname : '||fname||' -->');
  htp.p('<!-- l_func: '||l_func||' -->');

  htp.p('<BODY>');

  -- ### maybe we need to make the window closing time a configurable
  -- ### parameter in the future
  htp.p('<Script> dontclose = setTimeout("window.close()",30000) </Script>');
  htp.p('<NoScript><p>'||wf_core.translate('WFFRM_CLOSE_WINDOW')||'</NoScript>');
-- ### we cannot retest in this window, so commented it out.
--  if (Fnd_Function.Test(l_func)) then

  htp.p('<TABLE summary="" width=100% border=0><TR><TD>');

  l_ie_plugin_ver := replace(Wf_Core.translate('WF_PLUGIN_VERSION'),
                              '.', ',');

  if (instr(UPPER(owa_util.get_cgi_env('HTTP_USER_AGENT')), 'WIN') > 0) then
    htp.p('<OBJECT classid="clsid:'||Wf_Core.translate('WF_CLASSID')||'" '||
             'WIDTH="36" HEIGHT="40" '||
             'CODEBASE="'||Wf_Core.translate('WF_PLUGIN_DOWNLOAD')||
             '#Version='||l_ie_plugin_ver||'">'||
           '<PARAM NAME="jinit_appletcache" VALUE="off">'||
           '<PARAM NAME="CODE"     VALUE="'||code||'">'||
           '<PARAM NAME="CODEBASE" VALUE="'||codebase||'">'||
           '<PARAM NAME="ARCHIVE"  VALUE="'||l_archive||'">' ||
           '<PARAM NAME="type"     VALUE="'||
                        'application/x-jinit-applet;version='||
                        Wf_Core.translate('WF_PLUGIN_VERSION')||'">');
    if (port <> '0') then
      htp.p('<PARAM NAME="PORT"     VALUE="'||port||'">');
    end if;
    htp.p('<PARAM NAME="COMM"     VALUE='''||fname||'''>');
    htp.p('<COMMENT>'||
          '<EMBED type="application/x-jinit-applet;version='||
             Wf_Core.translate('WF_PLUGIN_VERSION')||'"'||
             ' WIDTH="36" HEIGHT="40"'||
             ' jinit_appletcache="off"'||
             ' java_CODE="'||code||'"'||
             ' java_CODEBASE="'||codebase||'"'||
             ' java_ARCHIVE="'||l_archive||'"');
    if (port <> '0') then
      htp.p(' Port='||port);
    end if;
    htp.p(   ' COMM='''||fname||''''||
             ' pluginurl="'||
             Wf_Core.translate('WF_PLUGIN_DOWNLOAD')||'">'||
           '<NOEMBED></COMMENT></NOEMBED></EMBED></OBJECT>');
  else
    -- Client is not Windows, so we don't want to call Jinitiator.
    htp.p('<applet code='||code||' codebase="'||codebase||'"');
    htp.p('archive="'||l_archive||'"');
    htp.p(' width="36" height="40">');
    if (port <> '0') then
      htp.p('<param name=Port value="'||port||'">');
    end if;
    htp.p('<PARAM NAME="COMM"     VALUE='''||fname||'''>');
    htp.p('</applet>');
  end if;

    htp.p('</TD>');
    htp.p('<TD>'||wf_core.translate('WFFRM_LOOK_IN_NAVIGATOR')||'</TD>');
    htp.p('</TR><TR><TD align=CENTER colspan=2>');
    htp.p('<FORM METHOD=POST ACTION="javascript:clearTimeout(dontclose);">');
    htp.p('<INPUT TYPE=SUBMIT VALUE="'||wf_core.translate('WFFRM_KEEP_WINDOW')
          ||'">');
    htp.p('</FORM>');
    htp.p('</TD>');
    htp.p('</TR></TABLE>');

--  else
    -- ADA: do not show anything here
--    htp.p('<IMG SRC="'||wfa_html.image_loc||'wfdc_off.gif" ALT="">');
--  end if;

  htp.p('</BODY>');
  htp.p('</HTML>');
exception
  when others then
    wf_core.context('Wf_Forms', 'AppletWindow', fname, port);
    raise;
end AppletWindow;

end WF_FORMS;

/
