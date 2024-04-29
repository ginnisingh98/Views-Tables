--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_HEADERS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_HEADERS_CUHK" AUTHID CURRENT_USER AS
  /* $Header: csfcdbhs.pls 115.5 2002/11/21 00:29:16 ibalint noship $ */

  /*****************************************************************************************
   This is the Customer Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  G_PKG_NAME varchar2(200) := 'CSF_DEBRIEF_HEADERS_CUHK' ;
  PROCEDURE Create_debrief_header_Pre
  ( px_debrief_header    IN OUT NOCOPY   CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;



  PROCEDURE  Create_debrief_header_post
  (
    px_debrief_header    IN OUT NOCOPY   CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Update_debrief_header_pre
  (
    px_debrief_header    IN OUT NOCOPY  CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Update_debrief_header_post
  (
    px_debrief_header    IN OUT NOCOPY   CSF_DEBRIEF_PUB.DEBRIEF_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_debrief_header_pre
  (
    p_header_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_debrief_header_post
  (
    p_header_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
END csf_debrief_headers_cuhk;

 

/
