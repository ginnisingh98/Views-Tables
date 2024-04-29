--------------------------------------------------------
--  DDL for Package OEXBMCBK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXBMCBK" AUTHID CURRENT_USER AS
/* $Header: OEXBMCBS.pls 115.2 99/07/16 08:11:39 porting shi $ */

PROCEDURE get_config_delivery
(
	link_mode		IN NUMBER,
	dem_src_header 		IN NUMBER,
	dem_src_line 		IN NUMBER,
	dem_src_type 		IN NUMBER,
	config_item_id 		IN NUMBER,
	dem_src_delivery 	IN OUT NUMBER,
	msg_text 		IN OUT VARCHAR2,
	completion_status 		IN OUT NUMBER
);

END OEXBMCBK;

 

/
