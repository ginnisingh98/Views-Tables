--------------------------------------------------------
--  DDL for Package INVPPRCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPPRCI" AUTHID CURRENT_USER as
/* $Header: INVPRCIS.pls 120.1 2005/06/21 04:30:17 appldev ship $ */
function inproit_process_item
(	ato_flag   in	NUMBER,
        prg_appid  in   NUMBER,
        prg_id     in   NUMBER,
        req_id     in   NUMBER,
        user_id    in   NUMBER,
        login_id   in   NUMBER,
        error_message  out      NOCOPY VARCHAR2,
        message_name   out      NOCOPY VARCHAR2,
        table_name     out      NOCOPY VARCHAR2)
return integer;
end invpprci;

 

/
