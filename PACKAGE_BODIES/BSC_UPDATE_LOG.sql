--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_LOG" AS
/* $Header: BSCDLOGB.pls 120.1 2005/06/30 16:29:10 meastmon noship $ */
--
-- Package constants
--

-- Formats
c_fto_long_date_time CONSTANT VARCHAR2(30) := 'Month DD, YYYY HH24:MI:SS';
c_version CONSTANT VARCHAR2(5) := '5.3.0';

--
-- Package variables
--
g_log_file_dir VARCHAR2(60) := NULL;
g_log_file_name VARCHAR2(2000) := NULL;


/*===========================================================================+
| FUNCTION Init_Log_File
+============================================================================*/
FUNCTION Init_Log_File (
	x_log_file_name IN VARCHAR2
        ) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    e_no_log_file_dir EXCEPTION;

    h_log_file_dir VARCHAR2(60);
    h_log_file_handle UTL_FILE.FILE_TYPE;

    TYPE t_cursor IS REF CURSOR;

    c_utl_file_dir t_cursor; -- h_utlfiledir
    c_utl_file_dir_sql VARCHAR2(2000) := 'SELECT VP.value'||
                                         ' FROM v$parameter VP'||
                                         ' WHERE UPPER(VP.name) = :1';

    h_utlfiledir VARCHAR2(30) := 'UTL_FILE_DIR';
    h_utl_file_dir VARCHAR2(2000);

BEGIN
    OPEN c_utl_file_dir FOR c_utl_file_dir_sql USING h_utlfiledir;
    FETCH c_utl_file_dir INTO h_utl_file_dir;
    IF c_utl_file_dir%NOTFOUND THEN
        h_log_file_dir := NULL;
    ELSE
        IF h_utl_file_dir IS NULL THEN
            h_log_file_dir := NULL;
        ELSE
            IF INSTR(h_utl_file_dir, ',') > 0 THEN
                h_log_file_dir := SUBSTR(h_utl_file_dir, 1, INSTR(h_utl_file_dir, ',') - 1);
            ELSE
                h_log_file_dir := h_utl_file_dir;
            END IF;
        END IF;
    END IF;
    CLOSE c_utl_file_dir;

    IF h_log_file_dir IS NULL THEN
        RAISE e_no_log_file_dir;
    END IF;

    h_log_file_handle := UTL_FILE.FOPEN(h_log_file_dir, x_log_file_name, 'w');
    UTL_FILE.PUT_LINE(h_log_file_handle, '+---------------------------------------------------------------------------+');
    UTL_FILE.PUT_LINE(h_log_file_handle,'Oracle Balanced Scorecard: Version : '||c_version);
    UTL_FILE.PUT_LINE(h_log_file_handle, '');
    UTL_FILE.PUT_LINE(h_log_file_handle, 'Copyright (c) Oracle Corporation 1999. All rights reserved.');
    UTL_FILE.PUT_LINE(h_log_file_handle, '');
    UTL_FILE.PUT_LINE(h_log_file_handle, 'Module: BSC Loader');
    UTL_FILE.PUT_LINE(h_log_file_handle, '+---------------------------------------------------------------------------+');
    UTL_FILE.PUT_LINE(h_log_file_handle, 'Time: '||TO_CHAR(SYSDATE, c_fto_long_date_time));
    UTL_FILE.FCLOSE(h_log_file_handle);

    g_log_file_name := x_log_file_name;
    g_log_file_dir := h_log_file_dir;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_LOGFILE_CREATION_FAILED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN e_no_log_file_dir THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_LOGFILE_DIR_NOT_SPECIFIED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_PATH THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_LOGFILE_PATH_FAILED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_MODE THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_LOGFILE_MODE_FAILED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_OPERATION THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_LOGFILE_OPERATION_FAILED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_LOGFILE_HANDLE_FAILED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN UTL_FILE.WRITE_ERROR THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_WRITE_LOGFILE_FAILED'),
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_LOG.Init_Log_File');
        RETURN FALSE;

END Init_Log_File;


/*===========================================================================+
| FUNCTION Log_File_Dir
+============================================================================*/
FUNCTION Log_File_Dir RETURN VARCHAR2 IS
BEGIN
    RETURN g_log_file_dir;

END Log_File_Dir;


/*===========================================================================+
| FUNCTION Log_File_Name
+============================================================================*/
FUNCTION Log_File_Name RETURN VARCHAR2 IS
BEGIN
    RETURN g_log_file_name;

END Log_File_Name;


/*===========================================================================+
| PROCEDURE Write_Line_Log
+============================================================================*/
PROCEDURE Write_Line_Log (
	x_line IN VARCHAR2,
        x_which IN NUMBER
	) IS

    h_log_file_handle UTL_FILE.FILE_TYPE;
    h_which NUMBER;

    h_line VARCHAR2(32700);

BEGIN
    h_line := TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' '||x_line;

    IF BSC_APPS.APPS_ENV THEN
        -- APPS environment (concurrent program)

        -- Due to some issue, when there is an error in the program
        -- the output file is not saved, i am going to write out put to log
        -- file also.

        IF x_which = LOG THEN
            FND_FILE.Put_Line(FND_FILE.LOG, h_line);
        ELSE
            FND_FILE.Put_Line(FND_FILE.OUTPUT, h_line);
            FND_FILE.Put_Line(FND_FILE.LOG, h_line);
        END IF;

    ELSE
        -- Personal environment
        IF g_log_file_name IS NOT NULL THEN
            h_log_file_handle := UTL_FILE.FOPEN(g_log_file_dir, g_log_file_name, 'a');

            UTL_FILE.PUT_LINE(h_log_file_handle, h_line);
            UTL_FILE.FCLOSE(h_log_file_handle);
        END IF;
    END IF;

END Write_Line_Log;


/*===========================================================================+
| PROCEDURE Write_Errors_To_Log
+============================================================================*/
PROCEDURE Write_Errors_To_Log IS

    TYPE t_cursor IS REF CURSOR;

    c_messages t_cursor; -- h_sessionid
    c_messages_sql VARCHAR2(2000) := 'SELECT message'||
                                     ' FROM bsc_message_logs'||
                                     ' WHERE last_update_login = :1'||
                                     ' ORDER BY last_update_date';

    h_sessionid NUMBER := USERENV('SESSIONID');

    h_message bsc_message_logs.message%TYPE;


BEGIN
    OPEN c_messages FOR c_messages_sql USING h_sessionid;
    FETCH c_messages INTO h_message;

    WHILE c_messages%FOUND LOOP
        Write_Line_Log(h_message, BSC_UPDATE_LOG.LOG);
        FETCH c_messages INTO h_message;
    END LOOP;

    CLOSE c_messages;

END Write_Errors_To_Log;


END BSC_UPDATE_LOG;

/
