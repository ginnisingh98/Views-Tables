--------------------------------------------------------
--  DDL for Package POS_WINDOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_WINDOW" AUTHID CURRENT_USER AS
/* $Header: POSASLWS.pls 115.0 99/08/20 11:08:01 porting sh $ */
  PROCEDURE BuildButtons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2);

  PROCEDURE dialogbox;

--  PROCEDURE ModalWindow;


END POS_WINDOW;

 

/
