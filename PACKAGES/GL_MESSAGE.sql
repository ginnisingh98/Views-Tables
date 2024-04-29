--------------------------------------------------------
--  DDL for Package GL_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MESSAGE" AUTHID CURRENT_USER as
/* $Header: gluplmgs.pls 120.1 2004/05/08 01:06:48 xiwu noship $ */

  FUNCTION Get_Message ( msg_name VARCHAR2,
                         show_num VARCHAR2 ) RETURN VARCHAR2;

-- **************************************************************

  FUNCTION Msg_Tkn_Expand(msg VARCHAR2,
                          t1  VARCHAR2,
                          v1  VARCHAR2) RETURN VARCHAR2;

-- *************************************************************

  FUNCTION Get_Message(msg_name VARCHAR2,
                       show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2) RETURN VARCHAR2;

-- **************************************************************

  FUNCTION Get_Message(msg_name VARCHAR2,
	               show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2,
                       t2       VARCHAR2,
                       v2       VARCHAR2) RETURN VARCHAR2;

-- **************************************************************

  FUNCTION Get_Message(msg_name VARCHAR2,
                       show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2,
                       t2       VARCHAR2,
                       v2       VARCHAR2,
                       t3       VARCHAR2,
                       v3       VARCHAR2) RETURN VARCHAR2;

-- ***************************************************************

  FUNCTION Get_Message(msg_name VARCHAR2,
	               show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2,
                       t2       VARCHAR2,
                       v2       VARCHAR2,
                       t3       VARCHAR2,
                       v3       VARCHAR2,
	               t4       VARCHAR2,
                       v4       VARCHAR2) RETURN VARCHAR2;

-- *****************************************************************
-- FUNCTION
--   Write_Buffer
-- Purpose
--   This Function used to write message name and actual message
--   (with token values) to buffer.
-- History
--   10-04-2001       Srini Pala    Created
-- Arguments
-- msg_name           Name of the message
-- token_num          Number of tokens exist  in the message
-- t1                 Name of the first token
-- v1                 Value of the first token
-- t2                 Name of the second token
-- v2                 Value of the second token
-- t3                 Name of the third  token
-- v3                 Value of the third token
-- t4                 Name of the fourth token
-- v4                 Value of the fourth token
-- t5                 Name of the fifth  token
-- v5                 Value of the fifth token

-- Example
--   GL_MESSAGE.Write_Buffer('SHRD0117',2,''NUM','10','TABLE','GL_BALANCES')
--

  FUNCTION  Write_Buffer(msg_name VARCHAR2,
			token_num NUMBER DEFAULT 0,
                        t1        VARCHAR2 DEFAULT NULL,
                        v1        VARCHAR2 DEFAULT NULL,
                        t2        VARCHAR2 DEFAULT NULL,
                        v2        VARCHAR2 DEFAULT NULL,
                        t3        VARCHAR2 DEFAULT NULL,
                        v3        VARCHAR2 DEFAULT NULL,
                        t4        VARCHAR2 DEFAULT NULL,
                        v4        VARCHAR2 DEFAULT NULL,
                        t5        VARCHAR2 DEFAULT NULL,
                        v5        VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- *******************************************************************

   PROCEDURE Set_Language ( lang_id NUMBER ) ;

-- ********************************************************************
-- Procedure
--   Write_Log
-- Purpose
--   This prodcedure  is similar to Write_Buffer () but used to write
--   meesage name and actual message (with token values)  to a Log file.
-- History
--   10-04-2001       Srini Pala    Created
--   02-27-2002       Srini Pala    Name changed to Write_Log
-- Arguments
--   msg_name           Name of the message
--   token_num          Number of tokens exist in the message
--   t1                 Name of the first token
--   v1                 Value of the first token
--   t2                 Name of the second token
--   v2                 Value of the second token
--   t3                 Name of the third  token
--   v3                 Value of the third token
--   t4                 Name of the fourth token
--   v4                 Value of the fourth token
--   t5                 Name of the fifth  token
--   v5                 Value of the fifth token

-- Example
--   GL_MESSAGE.Write_Log('SHRD0117',2,''NUM','10','TABLE','GL_BALANCES')
--


   PROCEDURE Write_Log (msg_name VARCHAR2,
                        token_num NUMBER DEFAULT 0,
			t1        VARCHAR2 DEFAULT NULL,
                        v1        VARCHAR2 DEFAULT NULL,
                        t2        VARCHAR2 DEFAULT NULL,
                        v2        VARCHAR2 DEFAULT NULL,
                        t3        VARCHAR2 DEFAULT NULL,
                        v3        VARCHAR2 DEFAULT NULL,
                        t4        VARCHAR2 DEFAULT NULL,
                        v4        VARCHAR2 DEFAULT NULL,
                        t5        VARCHAR2 DEFAULT NULL,
                        v5        VARCHAR2 DEFAULT NULL,
                        log_level NUMBER   DEFAULT 0,
                        module    VARCHAR2 DEFAULT NULL);
-- ******************************************************************
-- Procedure
--   Func_Succ
-- Purpose
--   This prodcedure  is used to write
--   the symbol '<< ' to indicate leaving function with successful completion
--   func_name (passed as parameter to the procedure)
--   system date and time ('HH24:MI:SS') to the Log file.
-- History
--   10-04-2001       Srini Pala    Created
-- Arguments
--   func_name        Name of the leaving function
-- Example
--   GL_MESSAGE.Func_succ('Gl_Message')
--

   PROCEDURE Func_Succ(func_name VARCHAR2,
                       log_level NUMBER   DEFAULT 0,
                       module    VARCHAR2 DEFAULT NULL);

-- ******************************************************************

-- Procedure
--   Func_Fail
-- Purpose
--   This prodcedure  is used to write
--   the symbol '<x ' to indicate leaving function wnen it fails
--   func_name ( passed as parameter to the procedure)
--   system date and time ('HH24:MI:SS') to the Log file.
-- History
--   10-04-2001       Srini Pala    Created
-- Arguments
--   func_name        Name of the leaving function
-- Example
--   GL_MESSAGE.Func_Fail('Gl_Message')


   PROCEDURE Func_Fail(func_name VARCHAR2,
                       log_level NUMBER   DEFAULT 0,
                       module    VARCHAR2 DEFAULT NULL);
-- ******************************************************************

-- Procedure
--   Func_Ent
-- Purpose
--   This prodcedure  is used to writes
--   the symbol '>> ' to indicate entering a function
--   func_name, passed as parameter to the procedure
--   system date and time ('HH24:MI:SS' ) to the Log file.
-- History
--   10-04-2001       Srini Pala    Created
-- Arguments
--   func_name        Name of the leaving function
-- Example
--   GL_MESSAGE.Func_Ent('Gl_Message')
--

   PROCEDURE Func_Ent(func_name VARCHAR2,
                       log_level NUMBER   DEFAULT 0,
                       module    VARCHAR2 DEFAULT NULL);

-- ******************************************************************


-- Procedure
--   Write_Output
-- Purpose
--   This prodcedure  is similar to Write_Log () but used to write
--   message name and actual message (with token values)  to a Output file.
-- History
--   02-27-2002         Srini Pala    Created
-- Arguments
--   msg_name           Name of the message
--   token_num          Number of tokens exist in the message
--   t1                 Name of the first token
--   v1                 Value of the first token
--   t2                 Name of the second token
--   v2                 Value of the second token
--   t3                 Name of the third  token
--   v3                 Value of the third token
--   t4                 Name of the fourth token
--   v4                 Value of the fourth token
--   t5                 Name of the fifth  token
--   v5                 Value of the fifth token

-- Example
--   GL_MESSAGE.Write_Output('SHRD0117',2,''NUM','10','TABLE','GL_BALANCES')
--


   PROCEDURE Write_Output(msg_name VARCHAR2,
                         token_num NUMBER DEFAULT 0,
			 t1        VARCHAR2 DEFAULT NULL,
                         v1        VARCHAR2 DEFAULT NULL,
                         t2        VARCHAR2 DEFAULT NULL,
                         v2        VARCHAR2 DEFAULT NULL,
                         t3        VARCHAR2 DEFAULT NULL,
                         v3        VARCHAR2 DEFAULT NULL,
                         t4        VARCHAR2 DEFAULT NULL,
                         v4        VARCHAR2 DEFAULT NULL,
                         t5        VARCHAR2 DEFAULT NULL,
                         v5        VARCHAR2 DEFAULT NULL);

-- ******************************************************************

-- Procedure
--   Write_Fndlog_Msg
-- Purpose
--   This prodcedure  is similar to Write_Log() but it will write to
--   fnd log only, it won't write to request log.
-- History
--   04-30-2004       Jennifer Wu    Created
-- Arguments
--   msg_name           Name of the message
--   token_num          Number of tokens exist in the message
--   t1                 Name of the first token
--   v1                 Value of the first token
--   t2                 Name of the second token
--   v2                 Value of the second token
--   t3                 Name of the third  token
--   v3                 Value of the third token
--   t4                 Name of the fourth token
--   v4                 Value of the fourth token
--   t5                 Name of the fifth  token
--   v5                 Value of the fifth token
--   log_level          Levels in FND_LOG...
--   module             Represents the source of the message
--   message            Message body.

-- Example
--   GL_MESSAGE.Write_Fndlog_Msg('SHRD0117',2,''NUM','10','TABLE',
--           'GL_BALANCES',FND_LOG.EVENT, 'ORACLE.APPS.GL.JAHE', )
--
  PROCEDURE Write_Fndlog_Msg  (msg_name  VARCHAR2,
                        token_num NUMBER DEFAULT 0,
                        t1        VARCHAR2 DEFAULT NULL,
                        v1        VARCHAR2 DEFAULT NULL,
                        t2        VARCHAR2 DEFAULT NULL,
                        v2        VARCHAR2 DEFAULT NULL,
                        t3        VARCHAR2 DEFAULT NULL,
                        v3        VARCHAR2 DEFAULT NULL,
                        t4        VARCHAR2 DEFAULT NULL,
                        v4        VARCHAR2 DEFAULT NULL,
                        t5        VARCHAR2 DEFAULT NULL,
                        v5        VARCHAR2 DEFAULT NULL,
                        log_level NUMBER,
                        module    VARCHAR2);

-- ******************************************************************
-- Procedure
--   Write_Fndlog_String
-- Purpose
--   This procedure writes the message to the log file for the
--   specified level and module if logging is enabled for this level
--   and module.
-- History
--   04-30-2004       Jennifer Wu    Created
-- Arguments
--   log_level          FND_LOG.LEVEL_UNEXPECTED  6
--                      FND_LOG.LEVEL_ERROR       5
--                      FND_LOG.LEVEL_EXCEPTION   4
--                      FND_LOG.LEVEL_EVENT       3
--                      FND_LOG.LEVEL_PROCEDURE   2
--                      FND_LOG.LEVEL_STATEMENT   1
--   module       Represents the source of the message
--   message      Message body.

-- Example
--   GL_MESSAGE.Write_Fndlog_String('SHRD0117',2,''NUM','10','TABLE',
--               'GL_BALANCES', FND_LOG.EVENT, 'ORACLE.APPS.GL.JAHE', )
--


  PROCEDURE Write_Fndlog_String  (log_level NUMBER,
                                  module    VARCHAR2,
                                  message   VARCHAR2);

-- ******************************************************************
  END Gl_Message;


 

/
