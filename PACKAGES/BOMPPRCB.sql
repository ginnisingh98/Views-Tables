--------------------------------------------------------
--  DDL for Package BOMPPRCB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPPRCB" AUTHID CURRENT_USER as
/* $Header: BOMPRCBS.pls 115.4 2002/02/12 00:45:06 skagarwa ship $ */
function bmprobm_process_bom
(	ato_flag   	in   	NUMBER,
        prg_appid  	in   	NUMBER,
        prg_id     	in  	NUMBER,
        req_id     	in   	NUMBER,
        user_id    	in   	NUMBER,
        login_id  	in   	NUMBER,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer;

function bmprort_process_rtg
(	ato_flag   	in   	NUMBER,
        perform_fc 	in   	NUMBER,
        prg_appid  	in   	NUMBER,
        prg_id     	in   	NUMBER,
        req_id     	in  	NUMBER,
        user_id    	in   	NUMBER,
        login_id   	in   	NUMBER,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer;

function bmproec_process_eco
(       ato_flag   	in   	NUMBER,
 	prg_appid  	in   	NUMBER,
        prg_id     	in   	NUMBER,
        req_id     	in   	NUMBER,
        user_id    	in   	NUMBER,
        login_id   	in   	NUMBER,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer;

function bmprobr_process_bom_rtg
(	ato_flag   	in out  NUMBER,
        perform_fc 	in      NUMBER,
        prg_appid  	in out  NUMBER,
        prg_id     	in out  NUMBER,
        req_id     	in out  NUMBER,
        user_id    	in out  NUMBER,
        login_id   	in out  NUMBER,
        error_message  	out     VARCHAR2,
        message_name   	out     VARCHAR2,
        table_name     	out     VARCHAR2)
return integer;

FUNCTION bmprbill_process_bill_data (
    prog_appid          NUMBER,
    prog_id             NUMBER,
    request_id          NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    error_message  OUT  VARCHAR2,
    message_name   OUT  VARCHAR2,
    table_name     OUT  VARCHAR2
)
    return INTEGER;

FUNCTION bmprrtg_process_rtg_data (
    prog_appid          NUMBER,
    prog_id             NUMBER,
    request_id          NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    error_message  OUT  VARCHAR2,
    message_name   OUT  VARCHAR2,
    table_name     OUT  VARCHAR2
)
    return INTEGER;

end BOMPPRCB;

 

/
