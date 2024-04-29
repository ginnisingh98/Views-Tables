--------------------------------------------------------
--  DDL for Package WIP_LOGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_LOGGER" AUTHID CURRENT_USER as
 /* $Header: wipflogs.pls 115.13 2003/05/29 01:13:52 kmreddy ship $ */

  --This package logs messages by using the fnd log package. It formats
  --the strings for consistency and ease of use.


  --These types are used to pass an arbitrarily long parameter list to
  --entryPoint.
  type param_rec_t is record(paramName VARCHAR2(255), paramValue VARCHAR2(255));
  type param_tbl_t is table of param_rec_t index by binary_integer;

  --log an arbitrary message.
  procedure log(p_msg           IN VARCHAR2,
                x_returnStatus out NOCOPY VARCHAR2);

  --Record an entrance to a procedure. This procedure will log the procedure name and
  --parameter values in an structured fashion. Every entryPoint() should have a matching
  --exitPoint(), even if an exception occurs. Messages are logged only if the message level
  --parameter is 1 or greater
  procedure entryPoint(p_procName      IN VARCHAR2,
                       p_params        IN param_tbl_t,
                       x_returnStatus out NOCOPY VARCHAR2);

  --Record an exit to a procedure. This procedure will log the procedure as being exited. It
  --should be used in conjunction with entryPoint(). Messages will only be logged if the message
  --level is 1 or greater.
  procedure exitPoint(p_procName          IN VARCHAR2,
                      p_procReturnStatus  IN VARCHAR2,
                      p_msg               IN VARCHAR2,
                      x_returnStatus     out NOCOPY VARCHAR2);

  --Resets package globals. Should be called after a flow is complete for formatting
  --purposes, but is not required.
  procedure cleanUp(x_returnStatus     out NOCOPY VARCHAR2);
end wip_logger;

 

/
