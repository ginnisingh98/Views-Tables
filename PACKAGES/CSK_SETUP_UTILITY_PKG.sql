--------------------------------------------------------
--  DDL for Package CSK_SETUP_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSK_SETUP_UTILITY_PKG" 
  /* $Header: csktsus.pls 120.0 2005/06/01 12:38:45 appldev noship $ */
AUTHID CURRENT_USER AS
  CAT_GROUP_API_TEST_DEFAULT  	CONSTANT    NUMBER  	:= -1;
  CAT_GROUP_API_TEST_CG1        CONSTANT    NUMBER  	:= -2;
  CAT_GROUP_API_TEST_CG2        CONSTANT    NUMBER  	:= -3;

  SOLN_TYPE_FAQ_API_TEST        CONSTANT    NUMBER  	:= -1;

  STMT_TYPE_FAQ_API_TEST        CONSTANT    NUMBER  	:= -1;

  VISIBILITY_RESTRICTED_API_TEST    CONSTANT    NUMBER  	:= -1;
  VISIBILITY_INTERNAL_API_TEST      CONSTANT    NUMBER  	:= -2;
  VISIBILITY_LIMITED_API_TEST       CONSTANT    NUMBER  	:= -3;
  VISIBILITY_EXTERNAL_API_TEST      CONSTANT    NUMBER  	:= -4;

  FLOW_API_TEST_FLOW CONSTANT    NUMBER  	:= -1;

  TYPE Soln_rec_type IS RECORD (
    set_id             NUMBER,
    Set_Number         VARCHAR2(30),
    set_type_id        NUMBER,
    name               VARCHAR2(500)  ,
--    status             VARCHAR2(30),
    visibility_id      VARCHAR2(150)
   );

  TYPE Stmt_rec_type IS RECORD (
    element_id        NUMBER,
    element_number    VARCHAR2(30),
    element_type_id   NUMBER(15) ,
    access_level      NUMBER,
    name              VARCHAR2(2000),
    --description       VARCHAR2(2000) ,
    content_type      VARCHAR2(30)
   );

  --TYPE Cat_rec_type IS RECORD (
  --  category_id        NUMBER
  -- );

  TYPE Stmt_tbl_type IS TABLE OF Stmt_rec_type;
  --TYPE Cat_tbl_type  IS TABLE OF Cat_rec_type;

  TYPE Cat_tbl_type IS TABLE OF number(15);


  PROCEDURE Validate_Seeded_Setups(
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2);

  PROCEDURE Create_Category (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_PARENT_CATEGORY_ID IN NUMBER,
    P_CATEGORY_ID        IN NUMBER,
    P_CATEGORY_NAME      IN VARCHAR2,
    P_VISIBILITY_ID      IN NUMBER);

  PROCEDURE Delete_Category (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_CATEGORY_ID        IN NUMBER);

  PROCEDURE Create_Solution (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_SOLN_REC    IN Soln_rec_type,
    P_STMT_TBL    IN Stmt_tbl_type,
    P_CAT_TBL     IN Cat_tbl_type,
    P_PUBLISH     IN Boolean );

  PROCEDURE Delete_Solution (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_SET_ID        IN NUMBER);

  PROCEDURE Obsolete_Solution (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    P_SET_ID        IN NUMBER);

  FUNCTION Get_Next_Set_ID RETURN NUMBER;

  FUNCTION Get_Next_Set_Number RETURN NUMBER;

  FUNCTION Get_Next_Element_ID RETURN NUMBER;

  FUNCTION Get_Next_Element_Number RETURN NUMBER;

  FUNCTION Get_Next_Category_ID RETURN NUMBER;

  FUNCTION Calculate_Set_Index_Content (P_SET_ID IN NUMBER) RETURN VARCHAR2;

END CSK_SETUP_UTILITY_PKG;

 

/
