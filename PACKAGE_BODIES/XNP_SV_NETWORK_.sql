--------------------------------------------------------
--  DDL for Package Body XNP_SV_NETWORK$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_SV_NETWORK$" as
/* $Header: XNPSVNWB.pls 120.0 2005/05/30 11:46:24 appldev noship $ */


--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$.Startup
--
-- Description: This procedure is the entry point for the 'xnp_sv_network$'
--              module (Monitor Network Subscriptions).
--
-- Parameters:  None
--
--------------------------------------------------------------------------------
   procedure Startup is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$.startup');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;
      XNP_WSGL.StoreURLLink(0, 'Monitor Network Subscriptions');


      xnp_sv_network$sms_sv.startup(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions',
                             'BGCOLOR="CCCCCC"', 'xnp_sv_network$.Startup');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$.firstpage
--
-- Description: This procedure creates the first page for the 'xnp_sv_network$'
--              module (Monitor Network Subscriptions).
--
-- Parameters:  Z_DIRECT_CALL
--
--------------------------------------------------------------------------------
   procedure FirstPage(Z_DIRECT_CALL in boolean) is
   begin

      XNP_WSGL.OpenPageHead('Monitor Network Subscriptions');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVNWK_TITLE')));

      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, htf.italic(fnd_message.get_string('XNP','ABOUT_XNP')), 0, 'xnp_sv_network$.showabout');
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions',
                             'BGCOLOR="CCCCCC"', 'xnp_sv_network$.FirstPage');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$.showabout
--
-- Description: This procedure is used to display an 'About' page for the
--		'xnp_sv_network$' module (Monitor Network Subscriptions).
--
--------------------------------------------------------------------------------
   procedure showabout is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$.showabout');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(107,XNP_WSGLM.DSP107_ABOUT)||' Monitor Network Subscriptions');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVNWK_TITLE')));


      htp.para;

      htp.p(XNP_WSGL.MsgGetText(108,XNP_WSGLM.DSP108_GENERATED_BY, 'WebServer Generator', '2.0.24.2.0'));
      htp.para;

      XNP_WSGL.Info(FALSE, 'XNP', 'XNPSVNWK');


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions',
                             'BGCOLOR="CCCCCC"', 'xnp_sv_network$.ShowAbout');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$.TemplateHeader
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions',
                             'BGCOLOR="CCCCCC"', 'xnp_sv_network$.TemplateHeader');
   end;
end;

/
