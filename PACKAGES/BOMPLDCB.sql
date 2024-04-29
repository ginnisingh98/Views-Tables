--------------------------------------------------------
--  DDL for Package BOMPLDCB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPLDCB" AUTHID CURRENT_USER as
/* $Header: BOMLDCBS.pls 120.1 2005/06/21 00:05:00 appldev ship $ */
function bmlggpn_get_group_name
(       group_id        number,
        group_name      in out nocopy /* file.sql.39 change */ varchar2,
        err_buf         in out nocopy /* file.sql.39 change */ varchar2
)
return integer;

function bmlupid_update_item_desc
(
	item_id			NUMBER,
        org_id          	NUMBER,
        err_buf    in out nocopy /* file.sql.39 change */   VARCHAR2
)
return integer;

function bmldbrt_load_bom_rtg
(       inherit_check  in       number,
   	error_message  in out nocopy /* file.sql.39 change */      VARCHAR2,
        message_name   in out nocopy /* file.sql.39 change */      VARCHAR2,
        table_name     in out nocopy /* file.sql.39 change */      VARCHAR2)
return integer;
end BOMPLDCB;

 

/
