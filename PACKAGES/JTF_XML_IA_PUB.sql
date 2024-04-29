--------------------------------------------------------
--  DDL for Package JTF_XML_IA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_XML_IA_PUB" AUTHID CURRENT_USER as
/* $Header: jtfxmlias.pls 115.5 2001/04/10 09:57:34 pkm ship       $ */

PROCEDURE CREATE_AUTH (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_URL			IN	VARCHAR2,
  p_AUTH_NAME		IN	VARCHAR2,
  p_AUTH_TYPE		IN	VARCHAR2,
  p_AUTH_INFO		IN	VARCHAR2,

  p_AUTH_ID 		OUT 	NUMBER,
  p_OBJECT_VERSION	OUT	NUMBER,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
);

procedure REMOVE_AUTH (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_AUTH_ID		IN 	NUMBER,
  p_OBJ_VER_NUMBER 	IN OUT	NUMBER,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
);

procedure GET_OBJECT_VERSION (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_AUTH_ID		IN	NUMBER,
  x_OBJ_VER_NUMBER	OUT	NUMBER,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
);

procedure UPDATE_AUTH (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_AUTH_ID	 	IN 	NUMBER,
  p_OBJ_VER_NUMBER 	IN OUT	NUMBER,
  p_URL			IN	VARCHAR2,
  p_AUTH_NAME		IN	VARCHAR2,
  p_AUTH_TYPE		IN	VARCHAR2,
  p_AUTH_INFO		IN 	VARCHAR2,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
);

procedure REMOVE_URL (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_URL			IN 	VARCHAR2,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
);

procedure UPDATE_URL (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_URL			IN 	VARCHAR2,
  p_NEW_URL		IN	VARCHAR2,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
);

END JTF_XML_IA_PUB;

 

/
