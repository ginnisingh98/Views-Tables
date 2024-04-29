--------------------------------------------------------
--  DDL for Package CSP_REQ_LINE_DETAILS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQ_LINE_DETAILS_IUHK" AUTHID CURRENT_USER AS
/* $Header: cspirlds.pls 120.0 2005/05/30 05:27:02 appldev noship $ */
  /*****************************************************************************************
   This is the Internal Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
  G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQ_LINE_DETAILS_IUHK';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspirlds.pls';
  PROCEDURE Create_req_line_detail_Pre
 (
    x_return_status          out nocopy   VARCHAR2
  ) ;


  PROCEDURE  Create_req_line_detail_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Update_req_line_detail_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;

  PROCEDURE  Update_req_line_detail_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_req_line_detail_pre
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
  PROCEDURE  Delete_req_line_detail_post
  (
    x_return_status          out nocopy   VARCHAR2
  ) ;
END CSP_REQ_LINE_DETAILS_IUHK;

 

/
