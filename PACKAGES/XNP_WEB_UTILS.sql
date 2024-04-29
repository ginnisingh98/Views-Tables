--------------------------------------------------------
--  DDL for Package XNP_WEB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WEB_UTILS" AUTHID CURRENT_USER AS
/* $Header: XNPWEBUS.pls 120.0 2005/05/30 11:45:23 appldev noship $ */



-- Constant for XML header.
C_XML_HEADER CONSTANT VARCHAR2(30) := '';


G_FORMAT     VARCHAR2(4) := 'HTML';

-- Prints output in XML format for browser rendering
PROCEDURE show_msg_body
	(p_msg_id NUMBER,
	 p_print_header VARCHAR2 DEFAULT 'Y');

--  Shows indicator item on the portal page
PROCEDURE show_indicator_item
  (p_itemname VARCHAR2,
   p_num NUMBER,
   p_afternum VARCHAR2);

-- Shows statistics item on the portal page
PROCEDURE show_statistics_item
  (p_itemname VARCHAR2,
   p_num NUMBER,
   p_afternum VARCHAR2);

-- Shows menu item on the portal page
PROCEDURE show_menu_item
  (p_itemname VARCHAR2,
   p_linkname VARCHAR2);

-- Shows alert item on the portal page
PROCEDURE show_alert_item1
  (p_itemname VARCHAR2,
   p_num     NUMBER,
   p_link VARCHAR2,
   p_imgname VARCHAR2);

--  Shows alert item on the portal page
PROCEDURE show_alert_item2
  (p_itemname VARCHAR2,
   p_name     VARCHAR2,
   p_link VARCHAR2,
   p_imgname VARCHAR2);

--  Shows indicator  on the portal page
PROCEDURE show_indicators;

--  Shows statistics  on the portal page
PROCEDURE show_statistics;

--  Shows menu on the portal page
PROCEDURE show_menu;

--  Shows alert on the portal page
PROCEDURE show_alerts;

END XNP_WEB_UTILS ;

 

/
