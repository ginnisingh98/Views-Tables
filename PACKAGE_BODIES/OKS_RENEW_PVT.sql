--------------------------------------------------------
--  DDL for Package Body OKS_RENEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENEW_PVT" AS
/* $Header: OKSRENWB.pls 120.3 2005/08/29 14:47:44 anjkumar ship $*/


PROCEDURE DEBUG_LOG(p_program_name        IN VARCHAR2,
                    p_perf_msg            IN VARCHAR2,
                    p_error_msg           IN VARCHAR2,
                    p_path                IN VARCHAR2) IS

              l_msg_data        VARCHAR2(2000);
              l_msg_count    NUMBER;
              l_return_status   VARCHAR2(1);

BEGIN

    Debug_Log(p_program_name,
              p_perf_msg,
              p_error_msg,
              p_path,
              l_msg_data,
              l_msg_count,
              l_return_status);

END DEBUG_LOG;

/*
 * This procedure will write the performace messages and/or error messages to a log file.
 * The location of the log file depends on the first path in the value field of v$parameter.
 * The name of the log file is ERM_l_session_id_FND_GLOBAL.user_id
*/
Procedure Debug_Log(p_program_name        IN VARCHAR2,
                    p_perf_msg            IN VARCHAR2,
                    p_error_msg           IN VARCHAR2,
                    p_path                IN VARCHAR2,
                    x_msg_data            OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_return_status       OUT NOCOPY VARCHAR2) IS

    l_file_name     VARCHAR2(200);
    l_file_loc      BFILE;
    l_file_type     utl_file.file_type;
    l_location      VARCHAR2(32000);
    l_comma_loc     NUMBER;
    l_session_id    NUMBER;
    l_perf_msg      VARCHAR2(32000) := p_program_name || ': ' || p_perf_msg;
    l_error_msg     VARCHAR2(32000) := p_error_msg;
    l_end_time          VARCHAR2(60);


    cursor get_dir is
    select value
    from v$parameter
    where name = 'utl_file_dir';

    Begin
        x_return_status  := OKC_API.G_RET_STS_SUCCESS;

        --anjkumar, for R12 nobody should use this procedure for loggin
        --but for old modules that are still using this, make sure that this also
        --writes to the standard fnd_log_messages table
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, nvl(p_program_name, 'oks.plsql.unknown'), p_perf_msg||' '||p_error_msg);
        END IF;

        l_end_time :=  to_char(sysdate, 'HH24:MI:SS AM');
        l_perf_msg := l_perf_msg || ' ' || l_end_time;

        If FND_PROFILE.VALUE('OKS_DEBUG') = 'Y' Then
            l_session_id := Sys_Context('USERENV', 'SESSIONID');

            --If l_perf_msg is null Then l_perf_msg := '';  End If;
            If l_error_msg is null Then l_error_msg := '';  End If;

            l_file_name := 'ERM_' || l_session_id  || '_'
                            || FND_GLOBAL.user_id || '.out';

            Open get_dir;
            Fetch get_dir into l_location;
            Close get_dir;

            If l_location is not null Then
                l_comma_loc := instr(l_location, ',');
                If l_comma_loc <> 0 Then
                    l_location := substr(l_location, 1, l_comma_loc - 1);
                End If;
            End If;

            If p_path is not null then
               l_location := p_path;
            End If;

            l_file_type := utl_file.fopen(location  => l_location,
                                          filename  => l_file_name,
                                          open_mode => 'a');

            utl_file.put_line(file    => l_file_type,
                              buffer  => l_perf_msg );

            utl_file.put_line(file    => l_file_type,
                              buffer  => l_error_msg );

            utl_file.fflush(file  => l_file_type);
            utl_file.fclose(l_file_type);
        End If;

     Exception
       when utl_file.INVALID_PATH then
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              x_msg_data := l_error_msg || ' Invalid Path';
              x_msg_count:= 1;
              OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               'Invalid path'
              );
       when utl_file.INVALID_OPERATION then
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             x_msg_data := l_error_msg || ' Invalid operation';
             x_msg_count:= 1;
             OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               'Invalid operation'
              );

       when others then
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := l_error_msg || ' ' || SQLERRM;
            x_msg_count:= 1;
            OKC_API.set_message
              (
               G_APP_NAME,
               G_UNEXPECTED_ERROR,
               G_SQLCODE_TOKEN,
               SQLCODE,
               G_SQLERRM_TOKEN,
               SQLERRM
              );

    End Debug_Log;



END OKS_RENEW_PVT;

/
