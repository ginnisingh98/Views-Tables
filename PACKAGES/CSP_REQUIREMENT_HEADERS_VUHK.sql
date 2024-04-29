--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_HEADERS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_HEADERS_VUHK" AUTHID CURRENT_USER AS
 /* $Header: cspyrqhs.pls 115.4 2002/11/26 07:29:01 hhaugeru noship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Vertical Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/
  G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_HEADERS_VUHK';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspvrqhs.pls';

  PROCEDURE Create_requirement_header_Pre
  (
    px_requirement_header    IN OUT NOCOPY   CSP_REQUIREMENT_HEADERS_PVT.Requirement_header_Rec_Type,
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
    p_header_id                IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
  PROCEDURE  Delete_requirement_header_post
  (
    p_header_id                IN   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

  END csp_requirement_headers_vuhk;

 

/
