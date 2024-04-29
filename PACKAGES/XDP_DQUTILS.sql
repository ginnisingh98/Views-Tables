--------------------------------------------------------
--  DDL for Package XDP_DQUTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_DQUTILS" AUTHID CURRENT_USER AS
/* $Header: XDPDQUTS.pls 120.1 2005/06/15 22:51:36 appldev  $ */


/*
 * This Procedure checks if the queue name is valid. If yes, inserts
 * the DQer instance entry in the DQer registration table and
 * returns the correct deque procedure to be executed by the DQer.
 * Else raises application error which is inturn trapped by the caller
 */

Procedure RegisterDQ (p_QueueName in varchar2,
                      p_DQPid in number,
                      p_QueueProc OUT NOCOPY varchar2);


/*
 * This Procedure executes the Dequeue procedure
 * In the PRO*C Dequeuer this is called in an infinite loop
 */

Procedure ExecDQProc (p_QueueProc in varchar2);

/*
 * This procedure removes the DQ instance entry from the DQer
 * registration table
 */

Procedure DeregisterDQ (p_DQPid in number);

End XDP_DQUTILS;

 

/
