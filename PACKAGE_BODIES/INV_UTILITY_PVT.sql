--------------------------------------------------------
--  DDL for Package Body INV_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UTILITY_PVT" AS
  -- $Header: INVFUTLB.pls 115.1 2002/12/30 09:27:23 jsugumar noship $

  g_pkg_name CONSTANT VARCHAR2(30)       := 'INV_UTILITY_PVT';
  pg_file_name        VARCHAR2(100)      := NULL;
  pg_path_name        VARCHAR2(100)      := NULL;
  pg_fp               UTL_FILE.file_type;

  /*=======================================================
    API name    : get_log_dir
    Type        : Private
    Function    : Get path name defined from utl_file_dir
  ========================================================*/
  PROCEDURE get_log_dir(
    x_return_status OUT NOCOPY VARCHAR2
  , x_msg_count     OUT NOCOPY NUMBER
  , x_msg_data      OUT NOCOPY VARCHAR2
  , x_log_dir       OUT NOCOPY VARCHAR2
  ) IS
    invalid_dir EXCEPTION;
    l_write_dir VARCHAR2(2000) := NULL;
    l_msg       VARCHAR2(2000);

    CURSOR get_filedebugdir IS
      SELECT RTRIM(LTRIM(VALUE))
        FROM v$parameter
       WHERE UPPER(NAME) = 'UTL_FILE_DIR';

  BEGIN
    OPEN get_filedebugdir;
    FETCH get_filedebugdir INTO l_write_dir;

    IF (l_write_dir IS NULL) THEN
      RAISE invalid_dir;
    END IF;

    CLOSE get_filedebugdir;

    IF (INSTR(l_write_dir, ',') > 0) THEN
      l_write_dir  := SUBSTR(l_write_dir, 1, INSTR(l_write_dir, ',') - 1);
    END IF;

    x_log_dir  := l_write_dir;
  EXCEPTION
    WHEN invalid_dir THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END get_log_dir;

  /*=======================================================
    API name    : write_debug_file
    Type        : Private
    Function    : Write message to logfile.
  =======================================================*/

  PROCEDURE write_debug_file(line IN VARCHAR2) IS
  BEGIN
    IF (pg_file_name IS NOT NULL) THEN
      UTL_FILE.put_line(pg_fp, line);
      UTL_FILE.fflush(pg_fp);
    END IF;
  END write_debug_file;

  /*=======================================================
   API name    : open_debug_file
   Type        : Private
   Function    : Open the logfile for writing log message.
  =======================================================*/
  PROCEDURE open_debug_file(
    p_path_name     IN            VARCHAR2
  , p_file_name     IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
  BEGIN
    pg_fp         := UTL_FILE.fopen(p_path_name, p_file_name, 'a');
    pg_file_name  := p_file_name;
    pg_path_name  := p_path_name;
  EXCEPTION
    WHEN UTL_FILE.invalid_path THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN UTL_FILE.invalid_mode THEN
      x_return_status  := fnd_api.g_ret_sts_error;
  END open_debug_file;

  /*=======================================================
   API name    : close_debug_file
   Type        : Private
   Function    : Close the logfile
  =======================================================*/

  PROCEDURE close_debug_file IS
  BEGIN
    IF (pg_file_name IS NOT NULL) THEN
      UTL_FILE.fclose(pg_fp);
    END IF;
  END close_debug_file;
END inv_utility_pvt;

/
