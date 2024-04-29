--------------------------------------------------------
--  DDL for Package Body EAM_API_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_API_LOG_PVT" AS
/* $Header: EAMVLOGB.pls 115.1 2003/01/06 21:36:44 chrng noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_API_Log_PVT';

PROCEDURE Open_Log_Session(
	p_log_file_dir	IN	VARCHAR2,
	p_log_file_name	IN	VARCHAR2,

	x_is_logged	IN OUT NOCOPY	NUMBER,
	x_log_file	IN OUT NOCOPY	UTL_FILE.FILE_TYPE
)
IS
BEGIN
	IF x_is_logged = g_YES
	THEN
		IF utl_file.is_open(x_log_file)
		THEN
			-- file already opened, nothing more to do
			NULL;
		ELSE
			x_log_file := utl_file.fopen(p_log_file_dir,
							p_log_file_name,
							'w');
			utl_file.put_line(x_log_file, 'Created ' || TO_CHAR(sysdate, 'DD MON YYYY HH12:MI:SS AM') ||
						'; Log file dir=' || p_log_file_dir ||
						'; Log file name=' || p_log_file_name
						);
			utl_file.fflush(x_log_file);
		END IF;
	END IF;

EXCEPTION
	WHEN OTHERS THEN

		x_is_logged := g_NO;

		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_CANNOT_CREATE_LOG_FILE');
			FND_MSG_PUB.ADD;
		END IF;
END Open_Log_Session;


PROCEDURE Write_Log(
	x_is_logged	IN OUT NOCOPY NUMBER,
	p_log_file	IN	UTL_FILE.FILE_TYPE,
	p_log_message	IN	VARCHAR2
)
IS
BEGIN
	IF x_is_logged = g_YES
	THEN
		IF utl_file.is_open(p_log_file)
		THEN
			utl_file.put_line(p_log_file, '> ' || p_log_message);
			utl_file.fflush(p_log_file);
		END IF;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		x_is_logged := g_NO;

		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.SET_NAME('EAM', 'EAM_ABO_ERROR_WRITING_TO_LOG');
			FND_MSG_PUB.ADD;
		END IF;
END Write_Log;

PROCEDURE Close_Log_Session(
	p_log_file	IN OUT NOCOPY	UTL_FILE.FILE_TYPE
)
IS
BEGIN
	IF utl_file.is_open(p_log_file)
	THEN
		utl_file.fclose(p_log_file);
	END IF;
END Close_Log_Session;

END EAM_API_Log_PVT;

/
