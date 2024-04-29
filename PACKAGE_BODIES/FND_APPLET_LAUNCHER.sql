--------------------------------------------------------
--  DDL for Package Body FND_APPLET_LAUNCHER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APPLET_LAUNCHER" as
/* $Header: AFAPPLTB.pls 120.1 2005/07/02 03:56:41 appldev ship $ */


-------------------------------------------------------------------------
-- launch
--   Construct the page to launch the specified applet.
-------------------------------------------------------------------------
procedure launch(
  applet_class       in varchar2,
  archive_list       in varchar2,
  user_args          in varchar2,
  title_msg          in varchar2  default null,
  title_app          in varchar2  default null,
  height             in number    default 300,
  width              in number    default 400,
  cache              in varchar2  default 'off',
  validate_session   in boolean   default TRUE)
is
  client_browser varchar2(40)   := null;
  title          varchar2(2000)  := null;
  fullargs       varchar2(2000) := null;
  url            varchar2(2000) := null;
  fail exception;
begin

  if (launch.validate_session = TRUE) then
    if (icx_sec.validateSession = FALSE) then
      return;
    end if;
  end if;

  -----------------------------------------
  -- Retrieve ICX_FORMS_LAUNCHER profile --
  -----------------------------------------
  url := fnd_profile.value('ICX_FORMS_LAUNCHER');

  if (url is null) then
    fnd_message.set_name('FND', 'PROFILES-CANNOT READ');
    fnd_message.set_token('OPTION', 'ICX_FORMS_LAUNCHER');
    fnd_message.set_token('ROUTINE', 'Fnd_Applet_Launcher.Launch');
    raise fail;
  end if;

  if (instr(url,'?') = 0)
    then url := url||'?';
  end if;

  ----------------------------------------
  -- Retrieve applet title if specified --
  ----------------------------------------
  title := '';
  if ((title_msg is not null) AND (title_app is not null)) then
    title := wfa_html.conv_special_url_chars(fnd_Message.get_string
        (title_app, title_msg));
  end if;

  fullargs := '&appletmode=nonforms&HTMLpageTitle='||title||
    '&HTMLpreApplet='||title||'&code='||
    launch.applet_class||'&width='||width||'&height='||height||
    '&archive='||launch.archive_list||
    '&gp14=jinit_appletcache&gv14='||launch.cache||
    'jinit_appletcache='||launch.cache||'';

  if (launch.validate_session = TRUE) then
    fullargs := fullargs||'&gp15=icx_ticket&gv15='||
      fnd_gfm.one_time_use_store(icx_sec.GetSessionCookie())||'';
  end if;

  fullargs := fullargs||launch.user_args;

  url := url||fullargs;

  owa_util.redirect_url(url);

end launch;

-------------------------------------------------------------------------
-- launch_application
--   Construct the page to launch the RunAppApplet applet
--   which launches the specified Windows application.
-------------------------------------------------------------------------
procedure launch_application(
  application_name   in varchar2,
  title_msg          in varchar2  default null,
  title_app          in varchar2  default null)
is
begin
  launch(applet_class => 'oracle/apps/fnd/util/RunAppApplet.class',
    archive_list => '/OA_JAVA/oracle/apps/fnd/jar/fndutil.jar',
    user_args => '&gp1=app&gv1='||application_name||
      '&gp2=dbc&gv2='||fnd_web_config.database_id||
      '&gp3=eul&gv3='||fnd_profile.value('ICX_DEFAULT_EUL'),
    title_msg => title_msg,
    title_app => title_app);

end launch_application;

end fnd_applet_launcher;

/
