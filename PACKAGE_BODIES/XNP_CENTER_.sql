--------------------------------------------------------
--  DDL for Package Body XNP_CENTER$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_CENTER$" as
/* $Header: XNPCENTB.pls 120.1 2005/06/21 04:04:24 appldev ship $ */


--------------------------------------------------------------------------------
-- Name:        xnp_center$.Startup
--
-- Description: This procedure is the entry point for the 'xnp_center$'
--              module (NP Center).
--
-- Parameters:  None
--
--------------------------------------------------------------------------------
   procedure Startup is
   begin

      XNP_WSGL.RegisterURL('xnp_center$.startup');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;
      XNP_WSGL.StoreURLLink(0, 'NP Center');


      FirstPage(TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'NP Center',
                             'BGCOLOR="CCCCCC"', 'xnp_center$.Startup');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_center$.firstpage
--
-- Description: This procedure creates the first page for the 'xnp_center$'
--              module (NP Center).
--
-- Parameters:  Z_DIRECT_CALL
--
--------------------------------------------------------------------------------
   procedure FirstPage(Z_DIRECT_CALL in boolean) is
   begin

      XNP_WSGL.OpenPageHead('NP Center');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPCENTR_TITLE')));

      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'Monitor Ordering Subscriptions', 0, 'xnp_sv_orders$.startup');
      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'Monitor Network Subscriptions', 0, 'xnp_sv_network$.startup');
      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'View Number Splits', 0, 'xnp_number_splits$.startup');
      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'SFM iMessage Diagnostics', 0, 'xnp_msg_diagnostics$.startup');
      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, htf.italic(fnd_message.get_string('XNP','ABOUT_XNP')), 0, 'xnp_center$.showabout');
      XNP_WSGL.NavLinks;


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'NP Center',
                             'BGCOLOR="CCCCCC"', 'xnp_center$.FirstPage');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_center$.showabout
--
-- Description: This procedure is used to display an 'About' page for the
--		'xnp_center$' module (NP Center).
--
--------------------------------------------------------------------------------
   procedure showabout is
   begin

      XNP_WSGL.RegisterURL('xnp_center$.showabout');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(107,XNP_WSGLM.DSP107_ABOUT)||' NP Center');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPCENTR_TITLE')));


      htp.para;

      htp.p(XNP_WSGL.MsgGetText(108,XNP_WSGLM.DSP108_GENERATED_BY, 'WebServer Generator', '2.0.24.2.0'));
      htp.para;

      XNP_WSGL.Info(FALSE, 'XNP', 'XNPCENTR');


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'NP Center',
                             'BGCOLOR="CCCCCC"', 'xnp_center$.ShowAbout');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_center$.TemplateHeader
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'NP Center',
                             'BGCOLOR="CCCCCC"', 'xnp_center$.TemplateHeader');
   end;
end;

/
