--------------------------------------------------------
--  DDL for Package Body XNP_NUMBER_SPLITS$
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_NUMBER_SPLITS$" as
/* $Header: XNPNUMSB.pls 120.0 2005/05/30 11:52:00 appldev noship $ */


--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$.Startup
--
-- Description: This procedure is the entry point for the 'xnp_number_splits$'
--              module (View Number Splits).
--
-- Parameters:  None
--
--------------------------------------------------------------------------------
   procedure Startup is
   begin

      XNP_WSGL.RegisterURL('xnp_number_splits$.startup');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;
      XNP_WSGL.StoreURLLink(0, 'View Number Splits');


      xnp_number_splits$number_split.startup(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits',
                             'BGCOLOR="CCCCCC"', 'xnp_number_splits$.Startup');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$.firstpage
--
-- Description: This procedure creates the first page for the 'xnp_number_splits$'
--              module (View Number Splits).
--
-- Parameters:  Z_DIRECT_CALL
--
--------------------------------------------------------------------------------
   procedure FirstPage(Z_DIRECT_CALL in boolean) is
   begin

      XNP_WSGL.OpenPageHead('View Number Splits');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPNUMSP_TITLE')));

      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, htf.italic(fnd_message.get_string('XNP','ABOUT_XNP')), 0, 'xnp_number_splits$.showabout');
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits',
                             'BGCOLOR="CCCCCC"', 'xnp_number_splits$.FirstPage');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$.showabout
--
-- Description: This procedure is used to display an 'About' page for the
--		'xnp_number_splits$' module (View Number Splits).
--
--------------------------------------------------------------------------------
   procedure showabout is
   begin

      XNP_WSGL.RegisterURL('xnp_number_splits$.showabout');
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(107,XNP_WSGLM.DSP107_ABOUT)||' View Number Splits');
      TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>'BGCOLOR="CCCCCC"');

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));

      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPNUMSP_TITLE')));


      htp.para;

      htp.p(XNP_WSGL.MsgGetText(108,XNP_WSGLM.DSP108_GENERATED_BY, 'WebServer Generator', '2.0.24.2.0'));
      htp.para;

      XNP_WSGL.Info(FALSE, 'XNP', 'XNPNUMSP');


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits',
                             'BGCOLOR="CCCCCC"', 'xnp_number_splits$.ShowAbout');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$.TemplateHeader
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits',
                             'BGCOLOR="CCCCCC"', 'xnp_number_splits$.TemplateHeader');
   end;
end;

/
