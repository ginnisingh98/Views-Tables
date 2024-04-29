--------------------------------------------------------
--  DDL for Package AST_WEBASSIST_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_WEBASSIST_CUHK" AUTHID CURRENT_USER AS
/* $Header: astvwaus.pls 115.4 2002/02/06 11:21:20 pkm ship      $ */

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
            );

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
            );

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
            );

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
            );

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
            );

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
            );

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
            );

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
            );


  FUNCTION Ok_To_Launch_Workflow(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN;


  FUNCTION Ok_To_Generate_Msg(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN;

END ast_WebAssist_CUHK;

 

/
