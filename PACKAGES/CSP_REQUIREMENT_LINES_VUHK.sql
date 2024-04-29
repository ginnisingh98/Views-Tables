--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_LINES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_LINES_VUHK" AUTHID CURRENT_USER AS
  /* $Header: cspyrqls.pls 115.4 2002/11/26 06:32:58 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_LINES_VUHK';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrqls.pls';



  PROCEDURE Create_requirement_line_Pre
  (
    px_requirement_line      IN OUT NOCOPY   CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;



  PROCEDURE  Create_requirement_line_post
  (
    px_requirement_line      IN OUT NOCOPY   CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;






  PROCEDURE  Update_requirement_line_pre
  (
    px_requirement_line      IN OUT NOCOPY  CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;



  PROCEDURE  Update_requirement_line_post
  (
    px_requirement_line      IN OUT NOCOPY   CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_line_pre
  (
    p_line_id                IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_line_post
  (
    p_line_id                IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
END csp_requirement_lines_vuhk;

 

/
