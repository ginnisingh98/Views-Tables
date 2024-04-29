--------------------------------------------------------
--  DDL for Package Body IGS_GE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_REPORT" AS
/* $Header: IGSGE12B.pls 120.0 2005/06/01 13:01:05 appldev noship $ */

PROCEDURE GET_INFO(
  p_request_id            IN  NUMBER,
  p_report_id             OUT NOCOPY NUMBER,
  p_report_set            OUT NOCOPY VARCHAR2,
  p_responsibility        OUT NOCOPY VARCHAR2,
  p_application           OUT NOCOPY VARCHAR2,
  p_request_time          OUT NOCOPY DATE,
  p_resub_interval        OUT NOCOPY VARCHAR2,
  p_run_time              OUT NOCOPY DATE,
  p_printer               OUT NOCOPY VARCHAR2,
  p_copies                OUT NOCOPY NUMBER,
  p_save_output           OUT NOCOPY VARCHAR2 )

AS
	v_report_id             NUMBER(15);
        v_responsibility        VARCHAR2(240);
        v_application           VARCHAR2(240);
        v_request_time          DATE;
        v_resub_interval        VARCHAR2(100);
        v_run_time              DATE;
        v_printer               VARCHAR2(30);
        v_copies                NUMBER(15);
        v_so_flag               VARCHAR2(1);
        v_save_output           VARCHAR2(10);
        v_parent_id             NUMBER(15);
        v_request_type          VARCHAR2(1);
        v_description           VARCHAR2(240);

	-- ssawhney:  program application_id is the app id through which this prog was run/reg
	-- resp application id is the app id of the resp through which the prog was run
	-- so for IGF cprogs, p-a-id = 8406 and r-app-id=8405.

        CURSOR c_get_info
	IS
	SELECT fcr.concurrent_program_id,
               fcr.parent_request_id,
               fr.description,
               fa.description,
               fcr.requested_start_date,
               TO_CHAR(fcr.RESUBMIT_INTERVAL)||' '||fcr.RESUBMIT_INTERVAL_UNIT_CODE,
               fcr.actual_start_date,
               fcr.printer,
               fcr.number_of_copies,
               fcr.save_output_flag
        FROM   FND_CONCURRENT_REQUESTS FCR,
               FND_APPLICATION_VL FA,
               FND_RESPONSIBILITY_VL FR
	WHERE  fcr.responsibility_id = fr.responsibility_id
	  AND  fcr.responsibility_application_id = fr.application_id  -- added by ssawhney 3690874
          AND  fcr.program_application_id = fa.application_id
          and  fcr.request_id = p_request_id;

       CURSOR c_get_rs (cp_parent_id 		fnd_concurrent_requests.parent_request_id%TYPE) IS
		SELECT	parent_request_id,
                        request_type,
                        description
		FROM	fnd_concurrent_requests
		WHERE	request_id = cp_parent_id;


BEGIN
        OPEN c_get_info;

        FETCH c_get_info
         INTO v_report_id,
              v_parent_id,
              v_responsibility,
              v_application,
              v_request_time,
              v_resub_interval,
              v_run_time,
              v_printer,
              v_copies,
              v_so_flag;


        CLOSE c_get_info;


       IF
           v_so_flag = 'Y'
       THEN
           v_save_output := 'YES';
       ELSE
           v_save_output  := 'NO';

       END IF;

       v_description  := '';
       v_request_type := '';

       IF  v_parent_id > 0
       THEN
           OPEN c_get_rs (v_parent_id);
           FETCH c_get_rs
             INTO v_parent_id,v_request_type,v_description;
           CLOSE c_get_rs;

           IF v_request_type = 'S'
           THEN
               OPEN c_get_rs (v_parent_id);
               FETCH c_get_rs
                 INTO  v_parent_id,v_request_type,v_description;
              CLOSE c_get_rs;
           END IF;

           IF v_request_type = 'M'
           THEN
              p_report_set    :=  v_description;
           END IF;
       END IF;

       p_report_id      :=  v_report_id;
       p_responsibility :=  v_responsibility;
       p_application    :=  v_application;
       p_request_time   :=  v_request_time;
       p_resub_interval :=  v_resub_interval;
       p_run_time       :=  v_run_time;
       p_printer        :=  v_printer;
       p_copies         :=  v_copies;
       p_save_output    :=  v_save_output;


EXCEPTION
       WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_GE_REPORT.GET_INFO');
	       IGS_GE_MSG_STACK.ADD;
       	       App_Exception.Raise_Exception;

END GET_INFO;

procedure IGS_PE_VALIDATE_ADDRESS(
  p_city		IN VARCHAR2 ,
  p_state		IN VARCHAR2 ,
  p_province		IN VARCHAR2 ,
  p_county		IN VARCHAR2 ,
  p_country		IN VARCHAR2 ,
  p_postcode		IN VARCHAR2 ,
  p_valid_address	OUT NOCOPY VARCHAR2 ,
  p_error_msg		OUT NOCOPY VARCHAR2 )

  AS
  BEGIN
  	--Validation Logic Implemented by user
  	--After Validation , if the user finds this address is valid , do the following :
  	--	P_VALID_ADDRESS := 'Y';
  	--	P_ERROR_MSG := NULL;
  	-- If address is not valid , then do the following :
  	--	P_VALID_ADDRESS := 'N';
  	--	P_ERROR_MSG := The parameter which is not valid(eg. P_CITY);

  	-- If the user does not have any logic implemented , the following is done :
  		P_VALID_ADDRESS := 'Y';
  		P_ERROR_MSG	:= NULL;


EXCEPTION
       WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       IGS_GE_MSG_STACK.ADD;
       	       App_Exception.Raise_Exception;

end IGS_PE_VALIDATE_ADDRESS;

END IGS_GE_REPORT;

/
