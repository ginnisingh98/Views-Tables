--------------------------------------------------------
--  DDL for Package Body XDP_DQUTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_DQUTILS" AS
/* $Header: XDPDQUTB.pls 120.1 2005/06/14 08:11:38 appldev  $ */


/********  PROCEDURE ValidateDequeuer ***********/
/*
 * Author: V.Rajaram
 * Date Created: Feb-22-1999
 *
 * INPUT:  Queue Type
 * OUTPUT: Dequeue Procedure
 *
 *
 * This Procedure checks if the queue name is valid. If yes, inserts
 * the DQer instance entry in the DQer registration table and
 * returns the correct deque procedure to be executed by the DQer.
 * Else raises application error which is inturn trapped by the caller
 *
 *
 * Usage: General
 */

Procedure RegisterDQ (p_QueueName in varchar2,
                      p_DQPid in number,
                      p_QueueProc OUT NOCOPY varchar2)

is
 e_InvalidQueueException exception;
 ErrMsg varchar2(100);
 l_InternalQName varchar2(80);
 l_temp varchar2(100);
Begin

 /*
  * Get the CallBack Function to start the Dequeuer
  */

  BEGIN
   select DQ_PROC_NAME, INTERNAL_Q_NAME
   into p_QueueProc, l_InternalQName
   from  XDP_DQ_CONFIGURATION
   -- INTERNAL_Q_NAME is upper so no need to check
   -- where UPPER( INTERNAL_Q_NAME ) = upper( p_QueueName);
   -- skilaru 03/27/2001
   where INTERNAL_Q_NAME = upper(p_QueueName);


  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    Raise e_InvalidQueueException;
    ErrMsg := 'Queue Name: ' || p_QueueName || ' Not found';
  END;


 /* Every thing kewl insert into XDP_DQ_REGISTRATION with the Dequeuer */

  /* Get an Unique Queue Name */
  select to_char(XDP_DQER_NAME_S.NEXTVAL) into l_temp from dual;
  l_temp := p_QueueName || l_temp;

 insert into XDP_DQER_REGISTRATION (DQER_NAME,
                                    DQER_PROCESS_ID,
                                    INTERNAL_Q_NAME,
                                    MODULE_NAME,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login
                                    )
                            values (l_temp,
                                    p_DQPid,
                                    l_InternalQName,
                                    'DONTKNOW',
                                    FND_GLOBAL.USER_ID,
                                    sysdate,
                                    FND_GLOBAL.USER_ID,
                                    sysdate,
                                    FND_GLOBAL.LOGIN_ID);

EXCEPTION
WHEN e_InvalidQueueException then
 RAISE_APPLICATION_ERROR(-20540, ErrMsg);
END RegisterDQ;



/********  PROCEDURE ExecDQProc ***********/
/*
 * Author: V.Rajaram
 * Date Created: Feb-22-1999
 *
 * INPUT:  Dequeue Procedure
 * OUTPUT: ErrorCode and Error String
 *
 * This procedure Executes the input dequeue procedure
 * This can be used to launch and procedure also
 *
 * Usage: General
 */

Procedure ExecDQProc ( p_QueueProc in varchar2)

is
 l_ParamList XDP_UTILITIES.t_ParameterList;
Begin

--   dbms_output.put_line('Calling Procedure: ' || p_QueueProc);

   XDP_UTILITIES.RunProc(0, p_QueueProc, l_ParamList);

END ExecDQProc;

Procedure DeregisterDQ (p_DQPid in number)
is

begin

 delete from XDP_DQER_REGISTRATION
 where DQER_PROCESS_ID = p_DQPid;

end DeregisterDQ;

End XDP_DQUTILS;

/
