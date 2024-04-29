--------------------------------------------------------
--  DDL for Package EAM_API_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_API_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVLOGS.pls 115.0 2002/12/14 00:29:34 chrng noship $ */

g_YES	CONSTANT	NUMBER := 1;
g_NO	CONSTANT	NUMBER := 2;

PROCEDURE Open_Log_Session(
	p_log_file_dir	IN	VARCHAR2,
	p_log_file_name	IN	VARCHAR2,

	x_is_logged	IN OUT NOCOPY	NUMBER,
	x_log_file	IN OUT NOCOPY	UTL_FILE.FILE_TYPE
);

PROCEDURE Write_Log(
	x_is_logged	IN OUT NOCOPY NUMBER,
	p_log_file	IN	UTL_FILE.FILE_TYPE,
	p_log_message	IN	VARCHAR2
);

PROCEDURE Close_Log_Session(
	p_log_file	IN OUT NOCOPY	UTL_FILE.FILE_TYPE
);

END EAM_API_Log_PVT;

 

/
