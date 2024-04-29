--------------------------------------------------------
--  DDL for Package POS_ACK_WINDOW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ACK_WINDOW_UTIL" AUTHID CURRENT_USER AS
/* $Header: POSWNDUS.pls 115.1 2001/06/05 18:49:55 pkm ship   $ */
  PROCEDURE DialogBox(l_rows in varchar2 default null);

  PROCEDURE BuildButtons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2);

END POS_ACK_WINDOW_UTIL;

 

/
