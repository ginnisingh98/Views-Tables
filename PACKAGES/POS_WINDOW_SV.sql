--------------------------------------------------------
--  DDL for Package POS_WINDOW_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_WINDOW_SV" AUTHID CURRENT_USER AS
/* $Header: POSWNDWS.pls 115.1 1999/11/30 12:19:48 pkm ship   $ */
  PROCEDURE DialogBox;

  PROCEDURE BuildButtons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2);

  PROCEDURE ModalWindow(p_asn_line_id VARCHAR2,
                        p_asn_line_split_id VARCHAR2,
                        p_quantity VARCHAR2,
                        p_unit_of_measure VARCHAR2);

END POS_WINDOW_SV;

 

/
