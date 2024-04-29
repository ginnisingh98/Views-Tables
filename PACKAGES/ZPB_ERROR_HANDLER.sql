--------------------------------------------------------
--  DDL for Package ZPB_ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_ERROR_HANDLER" AUTHID CURRENT_USER as
/* $Header: zpberrhandler.pls 120.0.12010.4 2006/08/03 13:36:33 appldev noship $ */


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
                            P_MESSAGE     in VARCHAR2 default NULL,
                            TOKEN_1_NAME  in VARCHAR2 default NULL,
                            TOKEN_1_VALUE in VARCHAR2 default NULL,
                            TOKEN_2_NAME  in VARCHAR2 default NULL,
                            TOKEN_2_VALUE in VARCHAR2 default NULL,
                            TOKEN_3_NAME  in VARCHAR2 default NULL,
                            TOKEN_3_VALUE in VARCHAR2 default NULL,
                            TOKEN_4_NAME  in VARCHAR2 default NULL,
                            TOKEN_4_VALUE in VARCHAR2 default NULL,
                            TOKEN_5_NAME  in VARCHAR2 default NULL,
                            TOKEN_5_VALUE in VARCHAR2 default NULL);

-------------------------------------------------------------------------------
-- INITIALIZE
--
-- Prcoedure that will initialize error handling.  This MUST be called ONCE
-- each time OA calls a PL/SQL procedure before any error handling methods
-- are called.
--
-------------------------------------------------------------------------------
procedure INITIALIZE;

-------------------------------------------------------------------------------
-- Merges the return status, keeping the more severe error
--
-- IN:
--   P_CURR_STATUS - The Current Status
--   P_MERGED_STATUS - The status to merge into the current status
-------------------------------------------------------------------------------
procedure MERGE_STATUS (x_curr_status   IN OUT NOCOPY VARCHAR2,
                        p_merge_status  IN            VARCHAR2);

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
                           P_MESSAGE     in VARCHAR2 default NULL,
                           TOKEN_1_NAME  in VARCHAR2 default NULL,
                           TOKEN_1_VALUE in VARCHAR2 default NULL,
                           TOKEN_2_NAME  in VARCHAR2 default NULL,
                           TOKEN_2_VALUE in VARCHAR2 default NULL,
                           TOKEN_3_NAME  in VARCHAR2 default NULL,
                           TOKEN_3_VALUE in VARCHAR2 default NULL,
                           TOKEN_4_NAME  in VARCHAR2 default NULL,
                           TOKEN_4_VALUE in VARCHAR2 default NULL,
                           TOKEN_5_NAME  in VARCHAR2 default NULL,
                           TOKEN_5_VALUE in VARCHAR2 default NULL);

-------------------------------------------------------------------------------
-- REGISTER_CONFIRMATION
--
-- Procedure to register a confirmation box.  Message will be logged at
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
                                 TOKEN_1_NAME  in VARCHAR2 default NULL,
                                 TOKEN_1_VALUE in VARCHAR2 default NULL,
                                 TOKEN_2_NAME  in VARCHAR2 default NULL,
                                 TOKEN_2_VALUE in VARCHAR2 default NULL,
                                 TOKEN_3_NAME  in VARCHAR2 default NULL,
                                 TOKEN_3_VALUE in VARCHAR2 default NULL,
                                 TOKEN_4_NAME  in VARCHAR2 default NULL,
                                 TOKEN_4_VALUE in VARCHAR2 default NULL,
                                 TOKEN_5_NAME  in VARCHAR2 default NULL,
                                 TOKEN_5_VALUE in VARCHAR2 default NULL);

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
                          TOKEN_1_NAME  in VARCHAR2 default NULL,
                          TOKEN_1_VALUE in VARCHAR2 default NULL,
                          TOKEN_2_NAME  in VARCHAR2 default NULL,
                          TOKEN_2_VALUE in VARCHAR2 default NULL,
                          TOKEN_3_NAME  in VARCHAR2 default NULL,
                          TOKEN_3_VALUE in VARCHAR2 default NULL,
                          TOKEN_4_NAME  in VARCHAR2 default NULL,
                          TOKEN_4_VALUE in VARCHAR2 default NULL,
                          TOKEN_5_NAME  in VARCHAR2 default NULL,
                          TOKEN_5_VALUE in VARCHAR2 default NULL);

-------------------------------------------------------------------------------
-- REGISTER_INFORMATION
--
-- Procedure to register an information box.  Message will be logged at
-- level 5 - ERROR and register it to be displayed by OA.  The process will
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
                                TOKEN_1_NAME  in VARCHAR2 default NULL,
                                TOKEN_1_VALUE in VARCHAR2 default NULL,
                                TOKEN_2_NAME  in VARCHAR2 default NULL,
                                TOKEN_2_VALUE in VARCHAR2 default NULL,
                                TOKEN_3_NAME  in VARCHAR2 default NULL,
                                TOKEN_3_VALUE in VARCHAR2 default NULL,
                                TOKEN_4_NAME  in VARCHAR2 default NULL,
                                TOKEN_4_VALUE in VARCHAR2 default NULL,
                                TOKEN_5_NAME  in VARCHAR2 default NULL,
                                TOKEN_5_VALUE in VARCHAR2 default NULL);

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
                            TOKEN_1_NAME  in VARCHAR2 default NULL,
                            TOKEN_1_VALUE in VARCHAR2 default NULL,
                            TOKEN_2_NAME  in VARCHAR2 default NULL,
                            TOKEN_2_VALUE in VARCHAR2 default NULL,
                            TOKEN_3_NAME  in VARCHAR2 default NULL,
                            TOKEN_3_VALUE in VARCHAR2 default NULL,
                            TOKEN_4_NAME  in VARCHAR2 default NULL,
                            TOKEN_4_VALUE in VARCHAR2 default NULL,
                            TOKEN_5_NAME  in VARCHAR2 default NULL,
                            TOKEN_5_VALUE in VARCHAR2 default NULL);

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
procedure SET_CONC_REQ_STATUS (P_STATUS in VARCHAR2);


-------------------------------------------------------------------------------
-- INIT_CONC_REQ_STATUS
--
-- Initializes pkg variables to support concurrent request warning:
-- pv_status is intialized to NULL
-------------------------------------------------------------------------------
--  A. Budnik 05/09/2006 b 5170327  retcode conc warnings from AW dml   |
procedure INIT_CONC_REQ_STATUS;


-------------------------------------------------------------------------------
-- GET_CONC_REQ_STATUS
--
-- This function returns status set by PUT_CONC_REQ_STATUS and converts it to the
-- retcode expected by a concurrent program.
-- IN:
--  l_conc_retcode can be:
--   SUCCESS: S = 0
--   WARNING: W = 1
--   ERROR: E = 2
-------------------------------------------------------------------------------
--  A. Budnik 05/09/2006 b 5170327  retcode conc warnings from AW dml   |

function GET_CONC_REQ_STATUS return varchar2;

end ZPB_ERROR_HANDLER;

 

/
