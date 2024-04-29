--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_HEADERS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_HEADERS_CUHK" AUTHID CURRENT_USER AS
  /* $Header: cspcrqhs.pls 115.4 2002/11/26 08:01:53 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

 G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_HEADERS_CUHK';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspcrqhs.pls';
  PROCEDURE Create_requirement_header_Pre
  ( px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;


  PROCEDURE  Create_requirement_header_post
  (
    px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;


  PROCEDURE  Update_requirement_header_pre
  (
    px_requirement_header    IN OUT NOCOPY  CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

  PROCEDURE  Update_requirement_header_post
  (
    px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_header_pre
  (
    p_header_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_header_post
  (
    p_header_id              IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
END csp_requirement_headers_cuhk;

 

/
