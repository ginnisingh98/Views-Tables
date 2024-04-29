--------------------------------------------------------
--  DDL for Package Body MSC_WS_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_PROCESS" AS
/* $Header: MSCWPROB.pls 120.4 2007/10/25 19:40:31 rolar noship $ */



  FUNCTION CHECK_PROC_STATUS( processId          IN         NUMBER) RETURN VARCHAR2 IS
                              status  VARCHAR2(30);

    /*


    function return values are:

    concurrent prog phase_status          function return value

     Running_<any status code>              RUNNING
     Pending_<any status code>              PENDING
     Inactive_no_manager                    INACTIVE_NO_MANAGER
     Inactive_<any other status codes>      INACTIVE
     Completed_Normal                       COMPLETED_NORMAL
     Completed_Error                        COMPLETED_ERROR
     Completed_Warning                      COMPLETED_WARNING
     Completed_Terminated                   COMPLETED_TERMINATED
     Completed_<any other status codes>     COMPLETED


      Concurrent phase codes
    I			       Inactive
    P			       Pending
    R			       Running
    C			       Completed
      Status Codes
    A			       Waiting
    B			       Resuming
    C			       Normal
    D			       Cancelled
    E			       Error
    G			       Warning
    H			       On Hold
    I				Normal
    M			       No Manager
    P			       Scheduled
    Q			       Standby
    R				 Normal
    S			       Suspended
    T			       Terminating
    U			       Disabled
    W			       Paused
    X			       Terminated
    Z				Waiting
    */


l_phase varchar2(80);
l_status varchar2(80);
l_child_request_id number;
l_request_id number ;
temp_status VARCHAR2(20);

cursor c_child_req (l_request_id number) is
       select  request_id, phase_code, status_code
       from fnd_concurrent_requests
       connect by prior request_id = parent_request_id
       start with request_id = processId;


begin
  status := 'INVALID_PROCESS_ID';
   open c_child_req(processId);
   loop
    fetch c_child_req into l_child_request_id , l_phase, l_status;

    exit when c_child_req%NOTFOUND;


     if (l_phase = 'R' ) then
            close c_child_req;
            return 'RUNNING';
       elsif (l_phase ='P')  then
        close c_child_req;
             return 'PENDING';
       elsif (l_phase = 'I' ) then
        close c_child_req;
            return 'INACTIVE';
       elsif (l_phase='C')   then
              status := 'COMPLETED';
             if (l_status ='E')  then
              close c_child_req;
                return 'COMPLETED_ERROR';
             elsif (l_status='X') then
               return 'COMPLETED_TERMINATED';
             elsif (l_status ='N') then
               if ( temp_status = 'COMPLETED_WARNING') then
                     status :='COMPLETED_WARNING';
              else
                     status :='COMPLETED_NORMAL';
             end if;
             elsif (l_status='G') then
               status :='COMPLETED_WARNING';

             end if;
       end if;
  end loop;
  close c_child_req;
    return(status) ;

     EXCEPTION
      WHEN others THEN
      close c_child_req;
         status := 'ERROR_UNEXPECTED_1000';
         return(status);
  END CHECK_PROC_STATUS;

END MSC_WS_PROCESS;

/
