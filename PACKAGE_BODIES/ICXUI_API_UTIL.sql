--------------------------------------------------------
--  DDL for Package Body ICXUI_API_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICXUI_API_UTIL" as
/* $Header: ICXUIUTB.pls 115.0 99/10/28 23:26:48 porting ship    $ */

procedure draw_title
(
    p_title     in varchar2
)
is
begin

    --
    -- Draw the topmost title region with rounded corners.
    --
    htp.p ('<TD>'); --wwutl_htp.tableDataOpen;
    htp.tableOpen(cattributes => 'BORDER="0" CELLPADDING="0" CELLSPACING="0"');
    htp.tableRowOpen;
    htp.tableData(htf.img('/OA_MEDIA/uiwizrul.gif',
        cattributes => 'VALIGN="TOP"'));

    htp.tableData(htf.fontOpen(ccolor => '#E0E0E0',
                               cface => 'arial,helvetica', csize=> '-1')
            || htf.bold(p_title)
            || htf.fontClose,
            cattributes => 'WIDTH="98%" BGCOLOR="#000066" ROWSPAN="2"');

    htp.tableData(htf.img('/OA_MEDIA/uiwizrur.gif',
        cattributes => 'VALIGN="TOP"'));
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.tableData(htf.img('/OA_MEDIA/red.gif',
        cattributes => 'BGCOLOR="#000066"'));
    htp.tableData(htf.img('/OA_MEDIA/red.gif',
        cattributes => 'BGCOLOR="#000066"'));
    htp.tableRowClose;
    htp.tableClose;
    htp.p ('</TD>'); --wwutl_htp.tableDataClose;

end draw_title;

procedure draw_image
(
    p_image in varchar2
)
is
begin
    --
    -- Draw the image bit
    --
    htp.tableData(htf.img('/OA_MEDIA/' || p_image,
            cattributes=>'VALIGN="TOP" BORDER="0"'),
            cattributes => 'VALIGN="TOP"', crowspan => 2);
end draw_image;

procedure draw_footer
is
begin
    --
    -- Draw the Footer for the wizard
    --

    htp.p('<TD>'); --wwutl_htp.tableDataOpen;
    htp.tableOpen(cattributes => 'BORDER="0" CELLPADDING="0" CELLSPACING="0"');
    htp.tableRowOpen;
    htp.tableData(htf.img('/OA_MEDIA/uiwizrll.gif'));
    htp.tableData(htf.img('/OA_MEDIA/red.gif'),
        cattributes => 'WIDTH="98%" BGCOLOR="#000066"');
    htp.tableData(htf.img('/OA_MEDIA/uiwizrlr.gif'));
    htp.tableRowClose;
    htp.tableClose;
    htp.p('</TD>'); --wwutl_htp.tableDataClose;
end draw_footer;


procedure draw_subheader
(
    p_subheader_text in varchar2
)
is
begin
    --
    -- Draw the SubHeader Title
    --
    htp.tableData(htf.fontOpen(ccolor => '#6666CC',
                               cface => 'arial,helvetica', csize => '-1')
                  || htf.bold(p_subheader_text)
                  || htf.fontClose);
end draw_subheader;

procedure draw_helptext
(
    p_help_text in varchar2
)
is
begin
    --
    -- Draw the Help Text
    --
    htp.tableData(htf.fontOpen(cface => 'arial,helvetica', csize => '-1')
                  || p_help_text
                  || htf.fontClose);

end draw_helptext;

procedure draw_buttons
(
    p_buttons icxui_api_button_list
)
is
begin
    --
    -- Draw the Buttons
    --
    --wwutl_htp.tableDataOpen(calign => 'RIGHT', cattributes => 'VALIGN="TOP"');
    htp.p('<TD align="RIGHT" VALIGN="TOP">');
    htp.tableOpen(cattributes => 'BORDER="0" CELLPADDING="1" CELLSPACING="4"');
    htp.tableRowOpen;

    for i in 1..p_buttons.count loop
        htp.tableData(icxui_api_util.formButton('p_request',
           p_buttons(i).button_name,
           cattributes =>
                      'WIDTH="80" onClick="'||p_buttons(i).button_url||'"'),
         cattributes => 'BGCOLOR="#999999"');
    end loop;

    htp.tableRowClose;
    htp.tableClose;
    htp.p('<TD>'); --wwutl_htp.tableDataClose;

end draw_buttons;


function IFNOTNULL
    (
        str1 in varchar2,
        str2 in varchar2
    )
    return varchar2 is
    begin
        if (str1 is NULL) then
            return (NULL);
        else
            return (str2);
        end if;
end IFNOTNULL;

function formButton
(
cname in varchar2 DEFAULT NULL,
cvalue in varchar2 DEFAULT NULL,
cattributes in varchar2 DEFAULT NULL
)
return varchar2 is
begin
return('<INPUT TYPE="button" NAME="'||cname||'"'||
      IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
      IFNOTNULL(cattributes,' '||cattributes)||
     '>');
end formButton;


function get_text_style
(
    p_str in varchar2
)
return varchar2
is
begin
    --
    -- Set the font for the text
    --
     return  htf.fontOpen(ccolor => '#000000',
                          cface => 'arial,helvetica', csize => '-1')
             || htf.nobr(p_str)
             || htf.fontClose;

end get_text_style;

procedure draw_path_text
(
    p_path_text in varchar2
)
is

begin

    htp.tableData(htf.fontOpen(ccolor => '#666666',
                          cface => 'arial,helvetica', csize => '-2')
             || htf.nobr(htf.bold(p_path_text))
             || htf.fontClose,
             cattributes => 'ALIGN="LEFT"');

end draw_path_text;

end icxui_api_util;

/
