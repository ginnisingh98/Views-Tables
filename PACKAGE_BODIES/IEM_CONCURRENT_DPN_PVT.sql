--------------------------------------------------------
--  DDL for Package Body IEM_CONCURRENT_DPN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CONCURRENT_DPN_PVT" as
/* $Header: iemecdpb.pls 120.2 2005/09/12 22:07:06 liangxia noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_CONCURRENT_DPN_PVT ';

PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       RETCODE  OUT NOCOPY     		VARCHAR2,
                       p_period_to_wake_up  		NUMBER)
IS
    l_request_id              NUMBER;
    l_Error_Message           VARCHAR2(2000);
    l_call_status             BOOLEAN;
    x_return_status           VARCHAR2(2000);
    x_msg_count               NUMBER;
    x_msg_dat                 VARCHAR2(2000);

    MAIN_WORKER_NOT_SUBMITTED EXCEPTION;
    REPEAT_OPTIONS_NOT_SET    EXCEPTION;
    WORKER_NOT_SUBMITTED      EXCEPTION;

BEGIN

    fnd_file.put_line(fnd_file.log, 'p_period_to_wake_up = ' || to_char(p_period_to_wake_up));
    fnd_file.put_line(fnd_file.log, 'Starting Processing');



    l_call_status := fnd_request.set_repeat_options('',p_period_to_wake_up,'HOURS','END','');


    -- IEMECDPS is a wrapper for the call to the workflow notification API
    l_request_id := fnd_request.submit_request('IEM', 'IEMECDPS', '','',FALSE);


    if not l_call_status then
        rollback;
        raise REPEAT_OPTIONS_NOT_SET;
    end if;

    fnd_file.put_line(fnd_file.log, ' Request Id ' || to_char(l_request_id));

    if l_request_id = 0 then
        rollback;
        raise WORKER_NOT_SUBMITTED;
    else
        commit;
    end if;

    Commit work;
    fnd_file.put_line(fnd_file.log, 'Controller Exited');

EXCEPTION

        WHEN REPEAT_OPTIONS_NOT_SET THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_REPEAT_OPTIONS_NOT_SET');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN WORKER_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_WORKER_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_UNXP_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);
END StartProcess;

END IEM_CONCURRENT_DPN_PVT;

/
