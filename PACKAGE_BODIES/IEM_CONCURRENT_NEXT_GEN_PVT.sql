--------------------------------------------------------
--  DDL for Package Body IEM_CONCURRENT_NEXT_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CONCURRENT_NEXT_GEN_PVT" as
/* $Header: iemngcsb.pls 120.0 2005/06/02 14:11:42 appldev noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_CONCURRENT_NEXT_GEN_PVT ';

PROCEDURE StartProcess(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       RETCODE  OUT NOCOPY     		VARCHAR2,
		       p_delay_worker_start_time        VARCHAR2,
		       p_schedule_worker_stop_date VARCHAR2,
                       p_period_to_wake_up  		NUMBER,
                       p_number_of_threads  		NUMBER,
                       p_number_of_msgs     		NUMBER)
IS
    l_request_id              NUMBER;
    l_Error_Message           VARCHAR2(2000);
    l_call_status             BOOLEAN;
    l_time_to_sch	      VARCHAR2(25);

    MAIN_WORKER_NOT_SUBMITTED EXCEPTION;
    REPEAT_OPTIONS_NOT_SET    EXCEPTION;
    WORKER_NOT_SUBMITTED      EXCEPTION;
--    RETRY_NOT_SUBMITTED	      EXCEPTION;
    INVALID_HOUR	      EXCEPTION;
    INVALID_MINUTE	      EXCEPTION;
BEGIN
        UPDATE IEM_COMP_RT_STATS -- New table name
        set VALUE='T'
        WHERE TYPE='MAILPROC' and PARAM='RUNTIME STATUS';

    fnd_file.put_line(fnd_file.log, 'p_delay_worker_start_time = ' || p_delay_worker_start_time);
    fnd_file.put_line(fnd_file.log, 'p_schedule_worker_stop_date = ' || p_schedule_worker_stop_date);
    fnd_file.put_line(fnd_file.log, 'p_period_to_wake_up = ' || to_char(p_period_to_wake_up));
    fnd_file.put_line(fnd_file.log, 'p_number_of_threads = ' || to_char(p_number_of_threads));
    fnd_file.put_line(fnd_file.log, 'p_number_of_msgs = ' || to_char(p_number_of_msgs));

    fnd_file.put_line(fnd_file.log, 'Starting Processing');


   FOR i in 1..p_number_of_threads loop

		l_call_status := fnd_request.set_repeat_options('',p_period_to_wake_up,'MINUTES','END',p_schedule_worker_stop_date);


	 l_request_id := fnd_request.submit_request('IEM', 'IEMNGNWW', '',p_delay_worker_start_time,FALSE,1,'F','T','MAILPREPROC','IEM_MAIL','NO_WAIT',p_number_of_msgs);

        if not l_call_status then
            rollback;
            raise REPEAT_OPTIONS_NOT_SET;
        end if;

        fnd_file.put_line(fnd_file.log, 'Worker number ' || to_char(i) || ' Request Id ' || to_char(l_request_id));

        if l_request_id = 0 then
            rollback;
            raise WORKER_NOT_SUBMITTED;
        else
            commit;
        end if;

   end loop;

    Commit work;
    fnd_file.put_line(fnd_file.log, 'Controller Exited');

EXCEPTION
	WHEN INVALID_HOUR THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_INVALID_HOUR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN INVALID_MINUTE THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_INVALID_MINUTE');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN REPEAT_OPTIONS_NOT_SET THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_REPEAT_OPTIONS_NOT_SET');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN MAIN_WORKER_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_MAIN_WORKER_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

        WHEN WORKER_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_WORKER_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);

/*
        WHEN RETRY_NOT_SUBMITTED THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_RETRY_NOT_SUBMITTED');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);
*/
        WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_UNXP_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_Error_Message);
END StartProcess;

END IEM_CONCURRENT_NEXT_GEN_PVT;

/
