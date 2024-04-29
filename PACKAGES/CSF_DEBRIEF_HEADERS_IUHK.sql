--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_HEADERS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_HEADERS_IUHK" AUTHID CURRENT_USER AS
  /* $Header: csfidbhs.pls 115.5 2002/11/21 00:31:55 ibalint noship $ */

  /*****************************************************************************************
   This is the Interanl User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  PROCEDURE Create_debrief_header_Pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Create_debrief_header_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Update_debrief_header_pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Update_debrief_header_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_debrief_header_pre
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_debrief_header_post
  (
    x_return_status          OUT NOCOPY   VARCHAR2
  ) ;
END csf_debrief_headers_iuhk;

 

/
