--------------------------------------------------------
--  DDL for Package AST_WEBSWITCH_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_WEBSWITCH_CUHK" AUTHID CURRENT_USER AS
/* $Header: astvwsus.pls 115.3 2002/02/06 11:21:35 pkm ship      $ */

  PROCEDURE Create_WebSwitch_Pre(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Create_WebSwitch_Post(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Update_WebSwitch_Pre(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Update_WebSwitch_Post(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Lock_WebSwitch_Pre(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Lock_WebSwitch_Post(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Delete_WebSwitch_Pre(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );

  PROCEDURE Delete_WebSwitch_Post(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit                   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_validation_level         IN NUMBER DEFAULT
                                                    FND_API.G_VALID_LEVEL_FULL,
                      x_return_status            OUT VARCHAR2,
                      x_msg_count                OUT NUMBER,
                      x_msg_data                 OUT VARCHAR2,
                      p_cgi_switch_rec           IN ast_WebSwitch_PVT.cgi_switch_rec_type,
                      p_switch_data_rec          IN ast_WebSwitch_PVT.switch_data_rec_type
                      );


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

END ast_WebSwitch_CUHK;

 

/
