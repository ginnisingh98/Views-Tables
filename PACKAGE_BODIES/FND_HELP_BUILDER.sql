--------------------------------------------------------
--  DDL for Package Body FND_HELP_BUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_HELP_BUILDER" as
/* $Header: AFMLHEPB.pls 115.26 2002/06/17 16:32:41 jvalenti ship $ */


-------------------------------------------------------------------------
-- Launch
--   The HTML page that loads the Help System Builder.
-------------------------------------------------------------------------

procedure Launch(
  custom_level             in number default 100,
  root_parent_application  in varchar2 default '',
  root_parent_key          in varchar2 default '',
  root_node_application    in varchar2 default '',
  root_node_key            in varchar2 default '')
is
begin
  fnd_applet_launcher.launch(
    applet_class       => 'oracle/apps/fnd/help/client/HelpTreeViewer.class',
    archive_list       => '/OA_JAVA/oracle/apps/fnd/jar/fndhelpc.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndaol.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndforms.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndctx.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndewt.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndbalishare.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndswing.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndutil.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndhier.jar,'||
                          '/OA_JAVA/oracle/apps/fnd/jar/fndtcf.jar',
    user_args          => '&gp1=apps_web_agent&gv1='||
                             fnd_gfm.construct_get_url(fnd_web_config.gfm_agent(null),'Fnd_Help.get','')||
                           '&gp2=web_server&gv2='||
                             fnd_web_config.web_server(null)||
                           '&gp3=dbc_file&gv3='||
                             fnd_web_config.database_id||
                           '&gp4=host&gv4='||
                             fnd_profile.value('TCF:HOST')||
                           '&gp5=port&gv5='||
                             fnd_profile.value('TCF:PORT')||
                           '&gp6=treedata&gv6='||
                             'oracle.apps.fnd.help.server.HelpServer'||
                           '&gp7=language&gv7='||
                             userenv('LANG')||
                           '&gp8=custom_level&gv8='||
                             custom_level||
                           '&gp9=root_parent_application&gv9='||
                             root_parent_application||
                           '&gp10=root_parent_key&gv10='||
                             root_parent_key||
                           '&gp11=root_node_application&gv11='||
                             root_node_application||
                           '&gp12=root_node_key&gv12='||
                             root_node_key||'',
  title_msg          => 'HE_HELP_LAUNCH_PAGE',
  title_app          => 'FND');

end Launch;
end Fnd_Help_Builder;

/
