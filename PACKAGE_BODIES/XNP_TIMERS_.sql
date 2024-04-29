--------------------------------------------------------
--  DDL for Package Body XNP_TIMERS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TIMERS$" as
/* $Header: XNPWEBTB.pls 120.0 2005/05/30 11:50:23 appldev noship $ */


--------------------------------------------------------------------------------
-- Name:        xnp_timers$.Startup
--
-- Description: This procedure is the entry point for the 'xnp_timers$'
--              module (Timer Registry).
--
-- Parameters:  None
--
--------------------------------------------------------------------------------
   procedure Startup is
   begin

      XNP_WSGL.RegisterURL('xnp_timers$.startup');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;
      XNP_WSGL.StoreURLLink(0, 'Timer Registry');


      xnp_timers$xnp_timer_registry.startup(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry',
                             'BGCOLOR="CCCCCC"', 'xnp_timers$.Startup');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$.firstpage
--
-- Description: This procedure creates the first page for the 'xnp_timers$'
--              module (Timer Registry).
--
-- Parameters:  Z_DIRECT_CALL
--
--------------------------------------------------------------------------------
   procedure FirstPage(Z_DIRECT_CALL in boolean) is
   begin

      XNP_WSGL.OpenPageHead('Timer Registry');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPTIMER_TITLE')));

      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, htf.italic(fnd_message.get_string('XNP','ABOUT_XNP')), 0, 'xnp_timers$.showabout');
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry',
                             'BGCOLOR="CCCCCC"', 'xnp_timers$.FirstPage');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$.showabout
--
-- Description: This procedure is used to display an 'About' page for the
--		'xnp_timers$' module (Timer Registry).
--
--------------------------------------------------------------------------------
   procedure showabout is
   begin

      XNP_WSGL.RegisterURL('xnp_timers$.showabout');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(107,XNP_WSGLM.DSP107_ABOUT)||' Timer Registry');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPTIMER_TITLE')));


      htp.para;

      htp.p(XNP_WSGL.MsgGetText(108,XNP_WSGLM.DSP108_GENERATED_BY, 'WebServer Generator', '2.0.24.0.0'));
      htp.para;

      XNP_WSGL.Info(FALSE, 'XNP', 'XNPTIMER');


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry',
                             'BGCOLOR="CCCCCC"', 'xnp_timers$.ShowAbout');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$.TemplateHeader
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry',
                             'BGCOLOR="CCCCCC"', 'xnp_timers$.TemplateHeader');
   end;
end;

/
