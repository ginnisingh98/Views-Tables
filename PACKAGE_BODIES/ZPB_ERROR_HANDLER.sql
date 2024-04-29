--------------------------------------------------------
--  DDL for Package Body ZPB_ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_ERROR_HANDLER" as
/* $Header: zpberrhandler.plb 120.0.12010.4 2006/08/03 13:36:10 appldev noship $ */

/***********************************************************************
 *              PACKAGE Level VARIABLES                                *
 ***********************************************************************/

 pv_status                    varchar2(1);


procedure L_HANDLE_EXCEPTION (P_MODULE      in VARCHAR2,
                              P_PROCEDURE   in VARCHAR2,
                              P_MESSAGE     in VARCHAR2,
                              TOKEN_1_NAME  in VARCHAR2,
                              TOKEN_1_VALUE in VARCHAR2,
                              TOKEN_2_NAME  in VARCHAR2,
                              TOKEN_2_VALUE in VARCHAR2,
                              TOKEN_3_NAME  in VARCHAR2,
                              TOKEN_3_VALUE in VARCHAR2,
                              TOKEN_4_NAME  in VARCHAR2,
                              TOKEN_4_VALUE in VARCHAR2,
                              TOKEN_5_NAME  in VARCHAR2,
                              TOKEN_5_VALUE in VARCHAR2)
   is
begin
   if (P_MESSAGE is null) then
      ZPB_LOG.LOG_PLSQL_EXCEPTION (P_MODULE, P_PROCEDURE, FALSE);
    else
      ZPB_LOG.WRITE_EXCEPTION (P_MODULE,
                               P_MESSAGE,
                               TOKEN_1_NAME,
                               TOKEN_1_VALUE,
                               TOKEN_2_NAME,
                               TOKEN_2_VALUE,
                               TOKEN_3_NAME,
                               TOKEN_3_VALUE,
                               TOKEN_4_NAME,
                               TOKEN_4_VALUE,
                               TOKEN_5_NAME,
                               TOKEN_5_VALUE,
                               FALSE);
   end if;
end L_HANDLE_EXCEPTION;

-------------------------------------------------------------------------------
-- HANDLE_EXCEPTION
--
-- Procedure to handle an exception.  Will log the exception at level 4 -
-- EXCEPTION and register it to be displayed by OA.  The process will be
-- returned to your code.
--
-- IN:
--   P_MODULE       - The calling package
--   P_PROCEDURE    - The calling procedure
--   P_MESSAGE      - The Message name defined in FND_MESSAGES table.  If
--                    omitted, default message used and will pull message from
--                    SQLERRM (meaning an exception must have been thrown).
--   TOKEN_#        - Any tokens required in the message.  Tokens go as a
--                    a name/value.  Omit if not applicable or using default.
--
-------------------------------------------------------------------------------
procedure HANDLE_EXCEPTION (P_MODULE      in VARCHAR2,
                            P_PROCEDURE   in VARCHAR2,
                            P_MESSAGE     in VARCHAR2,
                            TOKEN_1_NAME  in VARCHAR2,
                            TOKEN_1_VALUE in VARCHAR2,
                            TOKEN_2_NAME  in VARCHAR2,
                            TOKEN_2_VALUE in VARCHAR2,
                            TOKEN_3_NAME  in VARCHAR2,
                            TOKEN_3_VALUE in VARCHAR2,
                            TOKEN_4_NAME  in VARCHAR2,
                            TOKEN_4_VALUE in VARCHAR2,
                            TOKEN_5_NAME  in VARCHAR2,
                            TOKEN_5_VALUE in VARCHAR2)
   is
begin
   L_HANDLE_EXCEPTION(P_MODULE,
                      P_PROCEDURE,
                      P_MESSAGE,
                      TOKEN_1_NAME,
                      TOKEN_1_VALUE,
                      TOKEN_2_NAME,
                      TOKEN_2_VALUE,
                      TOKEN_3_NAME,
                      TOKEN_3_VALUE,
                      TOKEN_4_NAME,
                      TOKEN_4_VALUE,
                      TOKEN_5_NAME,
                      TOKEN_5_VALUE);
  FND_MSG_PUB.ADD;
  FND_MESSAGE.CLEAR;
end HANDLE_EXCEPTION;

-------------------------------------------------------------------------------
-- INITIALIZE
--
-- Prcoedure that will initialize error handling.  This MUST be called ONCE
-- each time OA calls a PL/SQL procedure before any error handling methods
-- are called.
--
-------------------------------------------------------------------------------
procedure INITIALIZE
   is
begin
   FND_MSG_PUB.INITIALIZE;
end INITIALIZE;

-------------------------------------------------------------------------------
-- Merges the return status, keeping the more severe error
--
-- IN:
--   P_CURR_STATUS - The Current Status
--   P_MERGED_STATUS - The status to merge into the current status
-------------------------------------------------------------------------------
procedure MERGE_STATUS (x_curr_status   IN OUT NOCOPY VARCHAR2,
                        p_merge_status  IN            VARCHAR2)
   is
begin
   --
   -- Only 3 possible statuses, unexp error, error or success:
   --
   if (p_merge_status <> FND_API.G_RET_STS_SUCCESS and
       x_curr_status <> FND_API.G_RET_STS_UNEXP_ERROR) then
      x_curr_status := p_merge_status;
   end if;

end MERGE_STATUS;

-------------------------------------------------------------------------------
-- RAISE_EXCEPTION
--
-- Procedure to handle an exception.  Will log the exception at level 4 -
-- EXCEPTION and raise a new SQLException.  Processing will halt, and it is
-- up to the OA code to handle the SQLException properly.
--
-- IN:
--   P_MODULE       - The calling package
--   P_PROCEDURE    - The calling procedure
--   P_MESSAGE      - The Message name defined in FND_MESSAGES table.  If
--                    omitted, default message used and will pull message from
--                    SQLERRM (meaning an exception must have been thrown).
--   TOKEN_#        - Any tokens required in the message.  Tokens go as a
--                    a name/value.  Omit if not applicable or using default.
--
-------------------------------------------------------------------------------
procedure RAISE_EXCEPTION (P_MODULE      in VARCHAR2,
                           P_PROCEDURE   in VARCHAR2,
                           P_MESSAGE     in VARCHAR2,
                           TOKEN_1_NAME  in VARCHAR2,
                           TOKEN_1_VALUE in VARCHAR2,
                           TOKEN_2_NAME  in VARCHAR2,
                           TOKEN_2_VALUE in VARCHAR2,
                           TOKEN_3_NAME  in VARCHAR2,
                           TOKEN_3_VALUE in VARCHAR2,
                           TOKEN_4_NAME  in VARCHAR2,
                           TOKEN_4_VALUE in VARCHAR2,
                           TOKEN_5_NAME  in VARCHAR2,
                           TOKEN_5_VALUE in VARCHAR2)
   is
begin
   L_HANDLE_EXCEPTION(P_MODULE,
                      P_PROCEDURE,
                      P_MESSAGE,
                      TOKEN_1_NAME,
                      TOKEN_1_VALUE,
                      TOKEN_2_NAME,
                      TOKEN_2_VALUE,
                      TOKEN_3_NAME,
                      TOKEN_3_VALUE,
                      TOKEN_4_NAME,
                      TOKEN_4_VALUE,
                      TOKEN_5_NAME,
                      TOKEN_5_VALUE);
   APP_EXCEPTION.RAISE_EXCEPTION;
end RAISE_EXCEPTION;

-------------------------------------------------------------------------------
-- REGISTER_CONFIRMATION
--
-- Procedure to register an confirmation box.  Message will be logged at
-- level 3 - EVENT and register it to be displayed by OA.  The process will
-- be returned to your code.
--
-- IN:
--   P_MODULE       - The calling package
--   P_PROCEDURE    - The calling procedure
--   P_MESSAGE      - The Message name defined in FND_MESSAGES table.  If
--                    omitted, default message used and will pull message from
--                    SQLERRM (meaning an exception must have been thrown).
--   TOKEN_#        - Any tokens required in the message.  Tokens go as a
--                    a name/value.  Omit if not applicable or using default.
--
-------------------------------------------------------------------------------
procedure REGISTER_CONFIRMATION (P_MODULE      in VARCHAR2,
                                 P_PROCEDURE   in VARCHAR2,
                                 P_MESSAGE     in VARCHAR2,
                                 TOKEN_1_NAME  in VARCHAR2,
                                 TOKEN_1_VALUE in VARCHAR2,
                                 TOKEN_2_NAME  in VARCHAR2,
                                 TOKEN_2_VALUE in VARCHAR2,
                                 TOKEN_3_NAME  in VARCHAR2,
                                 TOKEN_3_VALUE in VARCHAR2,
                                 TOKEN_4_NAME  in VARCHAR2,
                                 TOKEN_4_VALUE in VARCHAR2,
                                 TOKEN_5_NAME  in VARCHAR2,
                                 TOKEN_5_VALUE in VARCHAR2)
   is
begin
   ZPB_LOG.WRITE_EVENT_TR (P_MODULE||'.'||P_PROCEDURE,
                           P_MESSAGE,
                           TOKEN_1_NAME,
                           TOKEN_1_VALUE,
                           TOKEN_2_NAME,
                           TOKEN_2_VALUE,
                           TOKEN_3_NAME,
                           TOKEN_3_VALUE,
                           TOKEN_4_NAME,
                           TOKEN_4_VALUE,
                           TOKEN_5_NAME,
                           TOKEN_5_VALUE,
                           FALSE);
   FND_MSG_PUB.ADD_DETAIL(P_MESSAGE_TYPE => FND_MSG_PUB.G_INFORMATION_MSG);
   FND_MESSAGE.CLEAR;
end REGISTER_CONFIRMATION;

-------------------------------------------------------------------------------
-- REGISTER_ERROR
--
-- Procedure to register an error.  Message will be logged at level 5 -
-- ERROR and register it to be displayed by OA.  The process will be
-- returned to your code.
--
-- IN:
--   P_MODULE       - The calling package
--   P_PROCEDURE    - The calling procedure
--   P_MESSAGE      - The Message name defined in FND_MESSAGES table.  If
--                    omitted, default message used and will pull message from
--                    SQLERRM (meaning an exception must have been thrown).
--   TOKEN_#        - Any tokens required in the message.  Tokens go as a
--                    a name/value.  Omit if not applicable or using default.
--
-------------------------------------------------------------------------------
procedure REGISTER_ERROR (P_MODULE      in VARCHAR2,
                          P_PROCEDURE   in VARCHAR2,
                          P_MESSAGE     in VARCHAR2,
                          TOKEN_1_NAME  in VARCHAR2,
                          TOKEN_1_VALUE in VARCHAR2,
                          TOKEN_2_NAME  in VARCHAR2,
                          TOKEN_2_VALUE in VARCHAR2,
                          TOKEN_3_NAME  in VARCHAR2,
                          TOKEN_3_VALUE in VARCHAR2,
                          TOKEN_4_NAME  in VARCHAR2,
                          TOKEN_4_VALUE in VARCHAR2,
                          TOKEN_5_NAME  in VARCHAR2,
                          TOKEN_5_VALUE in VARCHAR2)
   is
begin
   ZPB_LOG.WRITE_ERROR (P_MODULE||'.'||P_PROCEDURE,
                        P_MESSAGE,
                        TOKEN_1_NAME,
                        TOKEN_1_VALUE,
                        TOKEN_2_NAME,
                        TOKEN_2_VALUE,
                        TOKEN_3_NAME,
                        TOKEN_3_VALUE,
                        TOKEN_4_NAME,
                        TOKEN_4_VALUE,
                        TOKEN_5_NAME,
                        TOKEN_5_VALUE,
                        FALSE);
   FND_MSG_PUB.ADD;
   --FND_MSG_PUB.ADD_DETAIL(P_MESSAGE_TYPE => FND_MSG_PUB.G_ERROR_MSG);
   FND_MESSAGE.CLEAR;
end REGISTER_ERROR;

-------------------------------------------------------------------------------
-- REGISTER_INFORMATION
--
-- Procedure to register an information box.  Message will be logged at
-- level 3 - EVENT and register it to be displayed by OA.  The process will
-- be returned to your code.
--
-- IN:
--   P_MODULE       - The calling package
--   P_PROCEDURE    - The calling procedure
--   P_MESSAGE      - The Message name defined in FND_MESSAGES table.  If
--                    omitted, default message used and will pull message from
--                    SQLERRM (meaning an exception must have been thrown).
--   TOKEN_#        - Any tokens required in the message.  Tokens go as a
--                    a name/value.  Omit if not applicable or using default.
--
-------------------------------------------------------------------------------
procedure REGISTER_INFORMATION (P_MODULE      in VARCHAR2,
                                P_PROCEDURE   in VARCHAR2,
                                P_MESSAGE     in VARCHAR2,
                                TOKEN_1_NAME  in VARCHAR2,
                                TOKEN_1_VALUE in VARCHAR2,
                                TOKEN_2_NAME  in VARCHAR2,
                                TOKEN_2_VALUE in VARCHAR2,
                                TOKEN_3_NAME  in VARCHAR2,
                                TOKEN_3_VALUE in VARCHAR2,
                                TOKEN_4_NAME  in VARCHAR2,
                                TOKEN_4_VALUE in VARCHAR2,
                                TOKEN_5_NAME  in VARCHAR2,
                                TOKEN_5_VALUE in VARCHAR2)
   is
begin
   ZPB_LOG.WRITE_EVENT_TR (P_MODULE||'.'||P_PROCEDURE,
                           P_MESSAGE,
                           TOKEN_1_NAME,
                           TOKEN_1_VALUE,
                           TOKEN_2_NAME,
                           TOKEN_2_VALUE,
                           TOKEN_3_NAME,
                           TOKEN_3_VALUE,
                           TOKEN_4_NAME,
                           TOKEN_4_VALUE,
                           TOKEN_5_NAME,
                           TOKEN_5_VALUE,
                           FALSE);
   FND_MSG_PUB.ADD_DETAIL(P_MESSAGE_TYPE => FND_MSG_PUB.G_INFORMATION_MSG);
   FND_MESSAGE.CLEAR;
end REGISTER_INFORMATION;

-------------------------------------------------------------------------------
-- REGISTER_WARNING
--
-- Procedure to register a warning.  Message will be logged at level 5 -
-- ERROR and register it to be displayed by OA.  The process will be
-- returned to your code.
--
-- IN:
--   P_MODULE       - The calling package
--   P_PROCEDURE    - The calling procedure
--   P_MESSAGE      - The Message name defined in FND_MESSAGES table.  If
--                    omitted, default message used and will pull message from
--                    SQLERRM (meaning an exception must have been thrown).
--   TOKEN_#        - Any tokens required in the message.  Tokens go as a
--                    a name/value.  Omit if not applicable or using default.
--
-------------------------------------------------------------------------------
procedure REGISTER_WARNING (P_MODULE      in VARCHAR2,
                            P_PROCEDURE   in VARCHAR2,
                            P_MESSAGE     in VARCHAR2,
                            TOKEN_1_NAME  in VARCHAR2,
                            TOKEN_1_VALUE in VARCHAR2,
                            TOKEN_2_NAME  in VARCHAR2,
                            TOKEN_2_VALUE in VARCHAR2,
                            TOKEN_3_NAME  in VARCHAR2,
                            TOKEN_3_VALUE in VARCHAR2,
                            TOKEN_4_NAME  in VARCHAR2,
                            TOKEN_4_VALUE in VARCHAR2,
                            TOKEN_5_NAME  in VARCHAR2,
                            TOKEN_5_VALUE in VARCHAR2)
   is
begin
   ZPB_LOG.WRITE_ERROR (P_MODULE||'.'||P_PROCEDURE,
                        P_MESSAGE,
                        TOKEN_1_NAME,
                        TOKEN_1_VALUE,
                        TOKEN_2_NAME,
                        TOKEN_2_VALUE,
                        TOKEN_3_NAME,
                        TOKEN_3_VALUE,
                        TOKEN_4_NAME,
                        TOKEN_4_VALUE,
                        TOKEN_5_NAME,
                        TOKEN_5_VALUE,
                        FALSE);
   FND_MSG_PUB.ADD_DETAIL(P_MESSAGE_TYPE => FND_MSG_PUB.G_WARNING_MSG);
   FND_MESSAGE.CLEAR;
end REGISTER_WARNING;

-------------------------------------------------------------------------------
-- SET_CONC_REQ_STATUS
--
-- Sets the return status of a concurrent request:
--
-- IN:
--  P_STATUS - Can be one of:
--   S = SUCCESS
--   W = WARNING
--   E = ERROR
-------------------------------------------------------------------------------
--  A. Budnik 05/09/2006 b 5170327  retcode conc warnings from AW dml   |
procedure SET_CONC_REQ_STATUS (P_STATUS in VARCHAR2)
   is

 begin

   if (p_status = 'E') then
      -- DBMS_OUTPUT.PUT_LINE('E case p_status ' || p_status);
      pv_status := 'E';
      -- DBMS_OUTPUT.PUT_LINE('assinged pv_status ' || pv_status);

    elsif (p_status = 'W') then

       -- DBMS_OUTPUT.PUT_LINE('W case p_status ' || p_status);


        if pv_status = 'S'  or pv_status is NULL then
            pv_status := 'W';
          --  DBMS_OUTPUT.PUT_LINE('assinged pv_status ' || pv_status);
        end if;

        elsif  (p_status = 'S') then
            -- DBMS_OUTPUT.PUT_LINE('S p_status ' || p_status);

            if  pv_status = 'S' or pv_status is NULL then
                pv_status := 'S';

              --  DBMS_OUTPUT.PUT_LINE('assinged pv_status ' || pv_status);

            end if;

         else
           null;
           --  DBMS_OUTPUT.PUT_LINE('assinged pv_status ' || pv_status);
     end if;
end SET_CONC_REQ_STATUS;


-------------------------------------------------------------------------------
-- INIT_CONC_REQ_STATUS
--
-- Initializes pkg variables to support concurrent request warning:
--
-- IN:
--  pv_status is intialized to NULL
-------------------------------------------------------------------------------
--  A. Budnik 05/09/2006 b 5170327  retcode conc warnings from AW dml   |
procedure INIT_CONC_REQ_STATUS
   is

begin

   pv_status  := NULL;
  return;


end INIT_CONC_REQ_STATUS;


-------------------------------------------------------------------------------
-- GET_CONC_REQ_STATUS
--
-- This function returns status set by PUT_CONC_REQ_STATUS and converts it to the
-- retcode expected by a concurrent program.
-- IN:
--  l_conc_retcode can be:
--   SUCCESS: S = 0
--   WARNING: W = 1
--   ERROR:   E = 2
-------------------------------------------------------------------------------
--  A. Budnik 05/09/2006 b 5170327  retcode conc warnings from AW dml   |
function GET_CONC_REQ_STATUS return varchar2
  AS

   l_conc_retcode VARCHAR2(1);
begin

   if (pv_status = 'E') then
      l_conc_retcode := '2';
    elsif (pv_status = 'W') then
      l_conc_retcode := '1';
    else
      l_conc_retcode := '0';
   end if;

 return l_conc_retcode;

end GET_CONC_REQ_STATUS;



end ZPB_ERROR_HANDLER;

/
