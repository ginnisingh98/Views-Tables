--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_LINES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_LINES_CUHK" AUTHID CURRENT_USER AS
  /* $Header: csfcdbls.pls 115.5 2002/11/21 00:29:44 ibalint noship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  G_PKG_NAME VARCHAR2(30) := 'CSF_DEBRIEF_LINES_CUHK';
  PROCEDURE Create_debrief_line_Pre
  ( px_debrief_line    IN OUT NOCOPY   CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;


  PROCEDURE  Create_debrief_line_post
  (
    px_debrief_line    IN OUT NOCOPY   CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;


  PROCEDURE  Update_debrief_line_pre
  (
    px_debrief_line    IN OUT NOCOPY  CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Update_debrief_line_post
  (
    px_debrief_line    IN OUT NOCOPY   CSF_DEBRIEF_PUB.DEBRIEF_LINE_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Delete_debrief_line_pre
  (
    p_line_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_debrief_line_post
  (
    p_line_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
END csf_debrief_lines_cuhk;

 

/
