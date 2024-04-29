--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_LINES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_LINES_VUHK" AUTHID CURRENT_USER AS
  /* $Header: csfydbls.pls 115.5 2002/11/21 00:42:23 ibalint noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

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
END csf_debrief_lines_vuhk;

 

/
