--------------------------------------------------------
--  DDL for Package ICX_PLUG_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PLUG_UTILITIES" AUTHID CURRENT_USER as
/* $Header: ICXPGUS.pls 120.1 2005/10/07 13:46:35 gjimenez noship $ */

function bgcolor return varchar2;

function plugbgcolor return varchar2;

function plugheadingcolor return varchar2;

function headingcolor return varchar2;

function plugbannercolor return varchar2;

function plugcolorscheme return varchar2;

function bannercolor return varchar2;

function toolbarcolor return varchar2;

function colorscheme return varchar2;

function getPLSQLagent return varchar2;

function getReportPLSQLAgent return varchar2;

function getReportURL return varchar2;

function getPlugTitle(p_plug_id in varchar2) return varchar2;

procedure gotoMainMenu;

function MainMenulink return varchar2;

procedure banner(p_text in varchar2 default NULL,
                 p_edit_URL in varchar2 default NULL,
                 p_icon in varchar2 default NULL,
                 p_text2 in varchar2 default NULL,
                 p_text3 in varchar2 default NULL,
                 p_text4 in varchar2 default NULL);

procedure plugbanner(p_text in varchar2 default NULL,
                 p_edit_URL in varchar2 default NULL,
                 p_icon in varchar2 default NULL,
                 p_text2 in varchar2 default NULL,
                 p_text3 in varchar2 default NULL,
                 p_text4 in varchar2 default NULL);

procedure sessionjavascript(p_javascript_tags in boolean default TRUE,
                            p_function in boolean default TRUE);

-- p_disp_mainmenu is home
procedure toolbar(p_text in varchar2 default NULL,
                  p_language_code in varchar2 default null,
                  p_disp_find     in varchar2 default null,
                  p_disp_mainmenu in varchar2 default 'Y',
                  p_disp_wizard   in varchar2 default 'N',
                  p_disp_help     in varchar2 default 'N',
                  p_disp_export   in varchar2 default null,
                  p_disp_exit     in varchar2 default 'N',
                  p_disp_menu     in varchar2 default 'Y');

procedure buttonLeft(p_text in varchar2,
                     p_url  in varchar2,
                     p_icon in varchar2 default NULL);

procedure buttonRight(p_text in varchar2,
                      p_url  in varchar2,
                      p_icon in varchar2 default NULL);

procedure buttonBoth(p_text in varchar2,
                     p_url  in varchar2,
                     p_icon in varchar2 default NULL);

end icx_plug_utilities;

 

/
