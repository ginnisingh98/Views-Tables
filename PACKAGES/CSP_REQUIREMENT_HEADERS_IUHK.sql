--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_HEADERS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_HEADERS_IUHK" AUTHID CURRENT_USER AS
 /* $Header: cspirqhs.pls 115.4 2002/11/26 05:43:48 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Internal Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_HEADERS_IUHK';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspirqhs.pls';
   PROCEDURE Create_requirement_header_Pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Create_requirement_header_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Update_requirement_header_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Update_requirement_header_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_header_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_header_post
 (
    x_return_status          out nocopy   VARCHAR2
  ) ;
END csp_requirement_headers_iuhk;

 

/
