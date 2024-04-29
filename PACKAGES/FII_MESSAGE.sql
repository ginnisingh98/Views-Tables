--------------------------------------------------------
--  DDL for Package FII_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_MESSAGE" AUTHID CURRENT_USER as
/*$Header: FIIUMSGS.pls 115.1 2003/12/26 22:01:42 juding noship $*/
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
--   FII_MESSAGE.Write_Buffer('SHRD0117',2,''NUM','10','TABLE','GL_BALANCES')
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
--   FII_MESSAGE.Write_Log('SHRD0117',2,''NUM','10','TABLE','GL_BALANCES')
--


   PROCEDURE Write_Log	(msg_name VARCHAR2,
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
--   FII_MESSAGE.Func_succ('Fii_Message')
--

   PROCEDURE Func_Succ(func_name VARCHAR2);

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
--   FII_MESSAGE.Func_Fail('Fii_Message')


   PROCEDURE Func_Fail(func_name VARCHAR2);

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
--   FII_MESSAGE.Func_Ent('Fii_Message')
--

   PROCEDURE Func_Ent(func_name VARCHAR2);

-- ******************************************************************


-- Procedure
--   Write_Output
-- Purpose
--   This prodcedure  is similar to Write_Log () but used to write
--   meesage name and actual message (with token values)  to a Output file.
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
--   FII_MESSAGE.Write_Output('SHRD0117',2,''NUM','10','TABLE','GL_BALANCES')
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

  END Fii_Message;


 

/
