--------------------------------------------------------
--  DDL for Package POS_TOOLBAR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_TOOLBAR_SV" AUTHID CURRENT_USER AS
/* $Header: POSTLBRS.pls 115.0 2001/10/30 16:28:07 pkm ship   $*/
/*
  PROCEDURE GetStyleSheet;
  PROCEDURE PaintToolbarEdge;
  PROCEDURE PaintCancel;
  PROCEDURE PaintTitle;
  PROCEDURE PaintDivider;
  PROCEDURE PaintSave;
  PROCEDURE PaintPrint;
  PROCEDURE PaintReload;
  PROCEDURE PaintStop;
  PROCEDURE PaintUserPref;
  PROCEDURE PaintHelp;
*/
  PROCEDURE PaintToolBar(p_title VARCHAR2);


END POS_TOOLBAR_SV;

 

/
