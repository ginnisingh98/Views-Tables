--------------------------------------------------------
--  DDL for Package Body AST_WEBASSIST_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_WEBASSIST_VUHK" AS
/* $Header: astvwavb.pls 115.3 2002/02/06 11:21:22 pkm ship      $ */

  PROCEDURE Create_WebAssist_PRE(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS

  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for pre processing */
    null;
  END;

  PROCEDURE Create_WebAssist_POST(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS

  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;

  PROCEDURE Lock_WebAssist_PRE(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS
  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;

  PROCEDURE Lock_WebAssist_POST(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS
  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;

  PROCEDURE Update_WebAssist_PRE(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS

  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;

  PROCEDURE Update_WebAssist_POST(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS

  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;

  PROCEDURE Delete_WebAssist_PRE(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS

  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;

  PROCEDURE Delete_WebAssist_POST(
            p_api_version                 IN  NUMBER,
            p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level            IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
            x_return_status               OUT VARCHAR2,
            x_msg_count                   OUT NUMBER,
            x_msg_data                    OUT VARCHAR2,
            p_assist_rec                  IN  ast_WebAssist_PVT.assist_rec_type,
            p_web_assist_rec              IN  ast_WebAssist_PVT.web_assist_rec_type,
            p_web_search_rec              IN  ast_WebAssist_PVT.web_search_rec_type,
            p_query_string_rec            IN  ast_WebAssist_PVT.query_string_rec_type
            )
  AS

  BEGIN
    /* Vertical to add the customization PROCEDUREs here - for post processing */
    null;
  END;


END ast_WebAssist_VUHK;

/
