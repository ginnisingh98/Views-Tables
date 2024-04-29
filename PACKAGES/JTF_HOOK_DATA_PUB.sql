--------------------------------------------------------
--  DDL for Package JTF_HOOK_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_HOOK_DATA_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpihds.pls 115.4 2000/11/21 09:28:07 pkm ship        $ */

TYPE HOOK_DATA_REC_TYPE IS RECORD (
 	p_ProductCode VARCHAR2(5),
  	p_PackageName VARCHAR2(50),
  	p_ApiName VARCHAR2(50),
  	p_ExecuteFlag VARCHAR2(1),
  	p_ProcessingType VARCHAR2(1),
  	p_HookType VARCHAR2(1),
  	p_HookPackage VARCHAR2(50),
  	p_HookApi VARCHAR2(50),
  	p_ExecutionOrder NUMBER := NULL
);


PROCEDURE JTF_HOOK_DATA_PUB_INSERT (
  p_api_version_number	IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 	:= FND_API.G_FALSE,
  p_commit		IN      VARCHAR		:= FND_API.G_FALSE,

  p_hook_data 		IN	HOOK_DATA_REC_TYPE,

  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2
);

END JTF_HOOK_DATA_PUB;

 

/
