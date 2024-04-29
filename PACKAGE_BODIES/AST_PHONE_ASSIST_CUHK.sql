--------------------------------------------------------
--  DDL for Package Body AST_PHONE_ASSIST_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_PHONE_ASSIST_CUHK" AS
/* $Header: astvpaub.pls 115.3 2002/02/06 11:44:09 pkm ship   $ */

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
	p_phone_extension       IN  VARCHAR2)
AS

BEGIN
	/* Customer to add the customization procedures here - for pre processing */
	null;
END;

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
	p_phone_extension       IN  VARCHAR2)
AS

BEGIN
	/* Customer to add the customization procedures here - for post processing */
	null;
END;

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
	p_phone_extension       IN  VARCHAR2)
AS

BEGIN
	/* Customer to add the customization procedures here - for pre processing */
	null;
END;

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
	p_phone_extension       IN  VARCHAR2)
AS

BEGIN
	/* Customer to add the customization procedures here - for post processing */
	null;
END;

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
	p_assist_id				IN  NUMBER)
AS

BEGIN
	/* Customer to add the customization procedures here - for pre processing */
	null;
END;

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
	p_assist_id				IN  NUMBER)
AS

BEGIN
	/* Customer to add the customization procedures here - for post processing */
	null;
END;

FUNCTION OK_TO_LAUNCH_WORKFLOW(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN is
BEGIN
	/* logic to check if a workflow to be launched */
	null;
	return true;
END;


FUNCTION OK_TO_GENERATE_MSG(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN is
BEGIN
	/* customer/vertical industry to add the customization here */
	null;
	return true;
END;

END ast_PHONE_ASSIST_CUHK;

/
