--------------------------------------------------------
--  DDL for Package AST_PHONE_ASSIST_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_PHONE_ASSIST_CUHK" AUTHID CURRENT_USER AS
/* $Header: astvpaus.pls 115.3 2002/02/06 11:44:11 pkm ship   $ */

	PROCEDURE Insert_Phone_Assist_PRE(
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit				IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status			OUT VARCHAR2,
		x_msg_count				OUT NUMBER,
		x_msg_data				OUT VARCHAR2,
		p_name					IN  VARCHAR2,
		p_description			IN  VARCHAR2,
		p_enabled_flag			IN  VARCHAR2,
		p_phone_country_code    IN  VARCHAR2,
		p_phone_area_code       IN  VARCHAR2,
		p_phone_number          IN  VARCHAR2,
		p_phone_extension       IN  VARCHAR2);

	PROCEDURE Insert_Phone_Assist_POST(
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit				IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status			OUT VARCHAR2,
		x_msg_count				OUT NUMBER,
		x_msg_data				OUT VARCHAR2,
		p_name					IN  VARCHAR2,
		p_description			IN  VARCHAR2,
		p_enabled_flag			IN  VARCHAR2,
		p_phone_country_code    IN  VARCHAR2,
		p_phone_area_code       IN  VARCHAR2,
		p_phone_number          IN  VARCHAR2,
		p_phone_extension       IN  VARCHAR2);

	PROCEDURE Update_Phone_Assist_PRE(
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit				IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status			OUT VARCHAR2,
		x_msg_count				OUT NUMBER,
		x_msg_data				OUT VARCHAR2,
		p_phone_assist_id		IN  NUMBER,
		p_contact_point_id		IN  NUMBER,
		p_name					IN  VARCHAR2,
		p_description			IN  VARCHAR2,
		p_enabled_flag			IN  VARCHAR2,
		p_phone_country_code    IN  VARCHAR2,
		p_phone_area_code       IN  VARCHAR2,
		p_phone_number          IN  VARCHAR2,
		p_phone_extension       IN  VARCHAR2);

	PROCEDURE Update_Phone_Assist_POST(
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit				IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status			OUT VARCHAR2,
		x_msg_count				OUT NUMBER,
		x_msg_data				OUT VARCHAR2,
		p_phone_assist_id		IN  NUMBER,
		p_contact_point_id		IN  NUMBER,
		p_name					IN  VARCHAR2,
		p_description			IN  VARCHAR2,
		p_enabled_flag			IN  VARCHAR2,
		p_phone_country_code    IN  VARCHAR2,
		p_phone_area_code       IN  VARCHAR2,
		p_phone_number          IN  VARCHAR2,
		p_phone_extension       IN  VARCHAR2);

	PROCEDURE Delete_Phone_Assist_PRE(
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit				IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status			OUT VARCHAR2,
		x_msg_count				OUT NUMBER,
		x_msg_data				OUT VARCHAR2,
		p_phone_assist_id		IN  NUMBER,
		p_contact_point_id		IN  NUMBER,
		p_party_id				IN  NUMBER,
		p_assist_id				IN  NUMBER);

	PROCEDURE Delete_Phone_Assist_POST(
		p_api_version			IN  NUMBER,
		p_init_msg_list			IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit				IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status			OUT VARCHAR2,
		x_msg_count				OUT NUMBER,
		x_msg_data				OUT VARCHAR2,
		p_phone_assist_id		IN  NUMBER,
		p_contact_point_id		IN  NUMBER,
		p_party_id				IN  NUMBER,
		p_assist_id				IN  NUMBER);

	FUNCTION OK_TO_LAUNCH_WORKFLOW(
        p_api_version IN NUMBER := 1.0,
        p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
        p_commit IN VARCHAR2 := FND_API.G_FALSE,
        p_validation_level IN NUMBER :=
        FND_API.G_VALID_LEVEL_FULL,
        x_return_status OUT VARCHAR2,
        x_msg_count OUT NUMBER,
        x_msg_data OUT VARCHAR2) RETURN BOOLEAN;


	FUNCTION OK_TO_GENERATE_MSG(
        p_api_version IN NUMBER := 1.0,
        p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
        p_commit IN VARCHAR2 := FND_API.G_FALSE,
        p_validation_level IN NUMBER :=
        FND_API.G_VALID_LEVEL_FULL,
        x_return_status OUT VARCHAR2,
        x_msg_count OUT NUMBER,
        x_msg_data OUT VARCHAR2) RETURN BOOLEAN;

END ast_PHONE_ASSIST_CUHK;

 

/
