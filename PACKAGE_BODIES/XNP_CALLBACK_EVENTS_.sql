--------------------------------------------------------
--  DDL for Package Body XNP_CALLBACK_EVENTS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_CALLBACK_EVENTS$" as
/* $Header: XNPWEBCB.pls 120.0 2005/05/30 11:46:57 appldev noship $ */


--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$.Startup
--
-- Description: This procedure is the entry point for the 'xnp_callback_events$'
--              module (Callback Events).
--
-- Parameters:  None
--
--------------------------------------------------------------------------------
   procedure Startup is
   begin

      XNP_WSGL.RegisterURL('xnp_callback_events$.startup');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;
      XNP_WSGL.StoreURLLink(0, 'Callback Events');


      xnp_callback_events$xnp_callba.startup(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events',
                             'BGCOLOR="CCCCCC"', 'xnp_callback_events$.Startup');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$.firstpage
--
-- Description: This procedure creates the first page for the 'xnp_callback_events$'
--              module (Callback Events).
--
-- Parameters:  Z_DIRECT_CALL
--
--------------------------------------------------------------------------------
   procedure FirstPage(Z_DIRECT_CALL in boolean) is
   begin

      XNP_WSGL.OpenPageHead('Callback Events');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      --htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPCALLBACK_EVENTS_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','Callback Event Diagnostics')));

      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, htf.italic(fnd_message.get_string('XNP','ABOUT_XNP')), 0, 'xnp_callback_events$.showabout');
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events',
                             'BGCOLOR="CCCCCC"', 'xnp_callback_events$.FirstPage');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$.showabout
--
-- Description: This procedure is used to display an 'About' page for the
--		'xnp_callback_events$' module (Callback Events).
--
--------------------------------------------------------------------------------
   procedure showabout is
   begin

      XNP_WSGL.RegisterURL('xnp_callback_events$.showabout');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(107,XNP_WSGLM.DSP107_ABOUT)||' Callback Events');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));

      --htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPCALLBACK_EVENTS_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','Callback Event Diagnostics')));


      htp.para;

      htp.p(XNP_WSGL.MsgGetText(108,XNP_WSGLM.DSP108_GENERATED_BY, 'WebServer Generator', '2.0.24.0.0'));
      htp.para;

      XNP_WSGL.Info(FALSE, 'XNP', 'XNPCBEVT');


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events',
                             'BGCOLOR="CCCCCC"', 'xnp_callback_events$.ShowAbout');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$.TemplateHeader
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events',
                             'BGCOLOR="CCCCCC"', 'xnp_callback_events$.TemplateHeader');
   end;
end;

/
