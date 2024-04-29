--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_LINES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_LINES_IUHK" AUTHID CURRENT_USER AS
  /* $Header: csfidbls.pls 115.5 2002/11/21 00:32:17 ibalint noship $ */

  /*****************************************************************************************
   This is the Internal  User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/


  PROCEDURE Create_debrief_line_Pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Create_debrief_line_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Update_debrief_line_pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Update_debrief_line_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Delete_debrief_line_pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Delete_debrief_line_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;
END csf_debrief_lines_iuhk;

 

/
