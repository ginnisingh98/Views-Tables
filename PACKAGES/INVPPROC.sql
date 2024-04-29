--------------------------------------------------------
--  DDL for Package INVPPROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPPROC" AUTHID CURRENT_USER as
/* $Header: INVPPROS.pls 120.0.12010000.2 2009/04/15 12:11:08 rmpartha ship $*/

function inproit_process_item
(       prg_appid  in   NUMBER,
        prg_id     in   NUMBER,
        req_id     in   NUMBER,
        user_id    in   NUMBER,
        login_id   in   NUMBER,
        error_message  out      NOCOPY VARCHAR2,
        message_name   out      NOCOPY VARCHAR2,
        table_name     out      NOCOPY VARCHAR2,
        xset_id    IN   NUMBER DEFAULT -999,
	p_commit   IN   NUMBER DEFAULT 1 ) /* Added to fix Bug#7422423*/

return integer;

END INVPPROC;

/
