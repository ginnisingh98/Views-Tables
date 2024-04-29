--------------------------------------------------------
--  DDL for Package ORACLECONFIGURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLECONFIGURE" AUTHID CURRENT_USER as
/* $Header: ICXCNFGS.pls 120.0 2005/10/07 12:13:38 gjimenez noship $ */

DEFAULT_HEIGHT                  constant number := 0;
DEFAULT_WIDTH                   constant number := 0;
DISPLAY_PORTLETS                constant number := 0;
DISPLAY_PORTLETS_EDIT           constant number := 2;

BORDER_WIDTH                    constant number := 1;
BORDER_COLOR                    constant varchar2(10) := '"#000066"';
CELL_COLOR                      constant varchar2(10) := '"#ffffff"';
VERTICAL_SPACING                constant number := 6;
HORIZONTAL_SPACING              constant number := 6;
CELL_PADDING                    constant number := 4;


function  createPage(p_page_type        in varchar2,
                     p_page_name        in varchar2,
                     p_page_description in varchar2 default null,
                     p_validate_flag    in varchar2 default 'Y') return number;

function copyPage(p_page_id in number,
                  p_page_name in varchar2) return number;

procedure copyPagePrivate(p_from_main_region_id in number,
                          p_to_main_region_id   in number,
                          p_to_page_id          in number);

procedure renamePage (p_page_id   in number,
                      p_page_name in varchar2);

procedure deletePage (p_page_id   in number);

procedure Customize(p_page_id in      number default null);

procedure displayCustomize(p_page_id    in number);

procedure render(
	p_page_id    in number,
	p_region_id  in number default null,
	p_user       in number default null,
	p_regionid   in icx_api_region.array default icx_api_region.empty,
	p_portletid  in icx_api_region.array default icx_api_region.empty,
	p_mode       in number default DISPLAY_PORTLETS,
	p_height     in number default DEFAULT_HEIGHT,
	p_width      in number default DEFAULT_WIDTH);


procedure renderregion(
        p_region     in icx_api_region.region_record,
        p_page_id    in number,
        p_styleid    in number,
        p_user       in varchar2,
        p_regionid   in icx_api_region.array default icx_api_region.empty,
        p_portletid  in icx_api_region.array default icx_api_region.empty,
        p_mode       in number default DISPLAY_PORTLETS,
        p_height     in number default DEFAULT_HEIGHT,
        p_width      in number default DEFAULT_WIDTH);

procedure showconfigurelinks(
        p_region_id number default null
    ,   p_show number default 0
    ,   p_mode number default 0
    ,   p_page_id number default null
);

procedure draw_editregion(
        p_region_id         in number default null
    ,   p_action            in varchar2 default null
    ,   p_region_align      in varchar2 default null
    ,   p_region_width      in varchar2 default null
    ,   p_region_restrict   in varchar2 default null
    ,   p_region_flow       in varchar2 default null
    ,   p_page_id           in number default null
    );

procedure save_editregion
    (
        p_region_id         in number default null
    ,   p_action            in varchar2 default null
    ,   p_region_width      in varchar2 default null
    ,   p_region_restrict   in varchar2 default null
    ,   p_region_flow       in varchar2 default null
    ,   p_region_border     in varchar2 default null
    ,   p_page_id           in number default null
    );

procedure split_region (  p_region_id     in number
		      ,   p_split_mode    in number
		      ,   p_page_id       in number
		      );

procedure delete_region
    (
        p_region_id in number
    ,   p_page_id   in number
    );

procedure renamePlugDlg(p_plug_id   in number);

procedure renamePlug (p_request   in varchar2 default null,
                      p_plug_id   in number,
                      p_plug_name in varchar2);

procedure addPlugDlg(p_page_id   in number,
                     p_region_id in number);


procedure savepage(     p_page_id            in number   default null,
                        p_region_id          in number   default null,
                        p_selectedlist      in varchar2 default null
                   );

function  addPlug(  p_resp_appl_id      in number,
                    p_security_group_id in number,
                    p_responsibility_id in number,
                    p_menu_id           in number,
                    p_entry_sequence    in number,
                    p_function_id      in number,
                    p_page_id          in number,
                    p_region_id        in number,
                    p_display_sequence in number)
return number;

procedure updatePlugsequence(
                            p_instanceid       in number,
                            p_display_sequence in number);

procedure deletePlugInstance(p_instanceid    in number,
                             p_page_id       in number,
                             p_web_html_call in varchar2);


function csvtoarray( p_variables in varchar2 ) return icx_api_region.array;

function arraytocsv( p_array in icx_api_region.array ) return varchar2;

end OracleConfigure;

 

/
