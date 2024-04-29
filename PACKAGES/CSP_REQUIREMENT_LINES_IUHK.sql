--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_LINES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_LINES_IUHK" AUTHID CURRENT_USER AS
  /* $Header: cspirqls.pls 115.5 2002/11/26 05:44:19 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Internal Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
  G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_LINES_IUHK';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspirqls.pls';
  PROCEDURE Create_requirement_line_Pre
 (
    x_return_status          out nocopy   VARCHAR2
  ) ;


  PROCEDURE  Create_requirement_line_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Update_requirement_line_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Update_requirement_line_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_line_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_line_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
END csp_requirement_lines_iuhk;

 

/
