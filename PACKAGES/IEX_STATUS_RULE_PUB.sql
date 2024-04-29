--------------------------------------------------------
--  DDL for Package IEX_STATUS_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STATUS_RULE_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpcsts.pls 120.0 2004/01/24 03:19:17 appldev noship $ */

  TYPE STATUS_RULE_REC_TYPE IS RECORD(
    STATUS_RULE_ID         NUMBER,
    STATUS_RULE_NAME            VARCHAR2(50),
    STATUS_RULE_DESCRIPTION      VARCHAR2(150),
    START_DATE             DATE,
    END_DATE               DATE,
--    JTF_OBJECT_CODE       VARCHAR2(25),
    LAST_UPDATE_DATE       DATE,
    LAST_UPDATED_BY        NUMBER,
    CREATION_DATE          DATE,
    CREATED_BY             NUMBER,
    LAST_UPDATE_LOGIN      NUMBER,
    PROGRAM_ID             NUMBER(15),
    SECURITY_GROUP_ID      NUMBER,
    OBJECT_VERSION_NUMBER  NUMBER);



  TYPE STATUS_RULE_TBL_TYPE IS TABLE OF STATUS_RULE_REC_TYPE INDEX BY binary_integer;

  TYPE STATUS_rule_line_REC_TYPE IS RECORD (
    STATUS_RULE_LINE_ID      NUMBER,
    DELINQUENCY_STATUS     VARCHAR2(30),
    PRIORITY               NUMBER,
	ENABLED_FLAG           VARCHAR2(1),
    STATUS_RULE_ID         NUMBER,
    LAST_UPDATE_DATE       DATE,
    LAST_UPDATED_BY        NUMBER,
    CREATION_DATE          DATE,
    CREATED_BY             NUMBER,
    LAST_UPDATE_LOGIN      NUMBER,
    PROGRAM_ID             NUMBER(15),
    SECURITY_GROUP_ID      NUMBER,
    OBJECT_VERSION_NUMBER  NUMBER);

  TYPE STATUS_rule_line_TBL_TYPE IS TABLE OF STATUS_rule_line_REC_TYPE INDEX BY binary_integer;

  TYPE STATUS_RULE_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY binary_integer;

  TYPE STATUS_rule_line_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY binary_integer;


Procedure Create_Status_Rule
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := 'F',
            p_commit                  IN VARCHAR2 := 'F',
            P_STATUS_RULE_REC         IN IEX_STATUS_RULE_PUB.STATUS_RULE_REC_TYPE,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            X_STATUS_RULE_ID                OUT NOCOPY NUMBER);


Procedure Update_Status_Rule
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := 'F',
            p_commit                  IN VARCHAR2 := 'F',
            p_status_rule_tbl         IN IEX_STATUS_RULE_PUB.STATUS_RULE_TBL_TYPE,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);



Procedure Delete_Status_Rule
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 := 'F',
            p_commit                  IN VARCHAR2 := 'F',
            P_STATUS_RULE_ID_TBL      IN IEX_STATUS_RULE_PUB.STATUS_RULE_ID_TBL_type,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Create_Status_rule_line
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 := 'F',
              p_commit                  IN VARCHAR2 := 'F',
              p_status_rule_line_rec    IN iex_status_rule_pub.status_rule_line_rec_type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);


Procedure Update_Status_rule_line
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 := 'F',
              p_commit                  IN VARCHAR2 := 'F',
              p_Status_rule_line_Tbl      IN iex_status_rule_pub.status_rule_line_tbl_type,
              x_dup_status              OUT NOCOPY VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

Procedure Delete_Status_rule_line
	    ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 := 'F',
              p_commit                  IN VARCHAR2 := 'F',
			  p_status_rule_id          IN NUMBER,
              p_status_rule_line_id_tbl      IN iex_status_rule_pub.status_rule_line_id_tbl_type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);



END IEX_STATUS_RULE_PUB;

 

/
