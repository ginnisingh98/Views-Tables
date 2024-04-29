--------------------------------------------------------
--  DDL for Package Body MSD_CONC_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CONC_LOG_UTIL" as
/* $Header: msdclutb.pls 115.4 2002/11/06 22:59:44 pinamati ship $ */
--
     --
    -- variables
    --
    g_last_msg_type varchar2(30);
    g_ret_code      number;
    g_result        varchar2(30);
    g_output_to     varchar2(30);
    --
    -- Local Procedure and Packages
    --
    Procedure calc_result ( p_msg_type in varchar2);
    --

Procedure calc_result ( p_msg_type in varchar2) is
Begin
    --
    if p_msg_type = C_FATAL_ERROR then
        g_ret_code := 4;
        g_result := C_FATAL_ERROR;
    elsif p_msg_type = C_ERROR then
        g_ret_code := 2;
        g_result   := p_msg_type;
    elsif p_msg_type = C_WARNING then
            g_ret_code := 1;
            g_result := p_msg_type;
    end if;
End;
--
Procedure show_message(p_text in varchar2) is
Begin
    --
    -- Output to FNDFILE or SERVER depending on the user settings
    --
--    if g_output_to = C_OUTPUT_TO_FNDFILE then
        fnd_file.put_line(fnd_file.log, p_text);
--    else
--        dbms_output.put_line(p_text);
--    end if;
end;
--
Procedure Initilize is
Begin
    --
    g_last_msg_type := null;
    g_ret_code      := null;
    g_result        := C_SUCCESS;
    g_output_to     := C_OUTPUT_TO_FNDFILE;
    --
End;
--
Procedure Initilize(p_output_to in varchar2) is
Begin
    --
    Initilize;
    --
    if p_output_to in (C_OUTPUT_TO_FNDFILE, C_OUTPUT_TO_SERVER) then
        g_output_to := p_output_to;
    end if;
End;
Procedure display_message(p_text varchar2, msg_type varchar2) is
    l_tab           varchar2(4):='    ';
    L_MAX_LENGTH    number:=90;
Begin
    if msg_type = C_SECTION then
        if nvl(g_last_msg_type, 'xx') <> C_SECTION then
            show_message('');
        end if;
        --
        show_message( substr(p_text, 1, L_MAX_LENGTH) );
        --
    elsif msg_type in (C_INFORMATION, C_HEADING) then
        show_message( l_tab || substr(p_text, 1, L_MAX_LENGTH));
    else
        show_message( l_tab || rpad(p_text, L_MAX_LENGTH) || ' ' || msg_type );
    end if;
    --
    if msg_type in (C_ERROR, C_WARNING, C_FATAL_ERROR) then
        calc_result (msg_type);
    end if;
    --
    if msg_type = C_FATAL_ERROR then
        show_message(' ');
        show_message( l_tab || 'Exiting Demand Plan validation process with FATAL ERROR');
        raise   EX_FATAL_ERROR;
    end if;
    --
    g_last_msg_type := msg_type;
End;
--
Function Result return varchar2 is
Begin
    return g_result;
End;
--
Function retcode return number is
Begin
    return g_ret_code;
End;

End;

/
