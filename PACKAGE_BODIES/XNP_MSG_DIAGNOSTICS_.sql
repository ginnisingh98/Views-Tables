--------------------------------------------------------
--  DDL for Package Body XNP_MSG_DIAGNOSTICS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_MSG_DIAGNOSTICS$" as
/* $Header: XNPMSGDB.pls 120.1 2005/06/21 04:10:03 appldev ship $ */


--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$.Startup
--
-- Description: This procedure is the entry point for the 'xnp_msg_diagnostics$'
--              module (SFM iMessage Diagnostics).
--
-- Parameters:  None
--
--------------------------------------------------------------------------------
   procedure Startup is
   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$.startup');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;
      XNP_WSGL.StoreURLLink(0, 'SFM iMessage Diagnostics');


      xnp_msg_diagnostics$xnp_msgs.startup(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics',
                             'BGCOLOR="CCCCCC"', 'xnp_msg_diagnostics$.Startup');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$.firstpage
--
-- Description: This procedure creates the first page for the 'xnp_msg_diagnostics$'
--              module (SFM iMessage Diagnostics).
--
-- Parameters:  Z_DIRECT_CALL
--
--------------------------------------------------------------------------------
   procedure FirstPage(Z_DIRECT_CALL in boolean) is
   begin

      XNP_WSGL.OpenPageHead('SFM iMessage Diagnostics');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPMSGDG_TITLE')));

      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, htf.italic(fnd_message.get_string('XNP','ABOUT_XNP')), 0, 'xnp_msg_diagnostics$.showabout');
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics',
                             'BGCOLOR="CCCCCC"', 'xnp_msg_diagnostics$.FirstPage');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$.showabout
--
-- Description: This procedure is used to display an 'About' page for the
--		'xnp_msg_diagnostics$' module (SFM iMessage Diagnostics).
--
--------------------------------------------------------------------------------
   procedure showabout is
   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$.showabout');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(107,XNP_WSGLM.DSP107_ABOUT)||' SFM iMessage Diagnostics');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPMSGDG_TITLE')));


      htp.para;

      htp.p(XNP_WSGL.MsgGetText(108,XNP_WSGLM.DSP108_GENERATED_BY, 'WebServer Generator', '2.0.24.2.0'));
      htp.para;

      XNP_WSGL.Info(FALSE, 'XNP', 'XNPMSGDG');


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics',
                             'BGCOLOR="CCCCCC"', 'xnp_msg_diagnostics$.ShowAbout');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$.TemplateHeader
--
-- Description:
--
--------------------------------------------------------------------------------
   procedure TemplateHeader(Z_DIRECT_CALL in boolean,
                            Z_TEMPLATE_ID in number) is
   begin

      null;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics',
                             'BGCOLOR="CCCCCC"', 'xnp_msg_diagnostics$.TemplateHeader');
   end;
end;

/
