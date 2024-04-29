--------------------------------------------------------
--  DDL for Package Body GL_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MESSAGE" AS
/* $Header: gluplmgb.pls 120.2 2004/10/27 19:07:05 xiwu noship $ */

  FUNCTION Get_Message ( msg_name VARCHAR2,
                        show_num VARCHAR2 ) RETURN VARCHAR2 IS
      msg_number NUMBER;
      msg_text   VARCHAR2(2000);

   BEGIN
        FND_MESSAGE.Set_Name('SQLGL', msg_name);

        RETURN (SUBSTRB(FND_MESSAGE.Get, 1, 132));

   END;
-- **************************************************************

  FUNCTION Msg_Tkn_Expand(msg VARCHAR2,
                          t1  VARCHAR2,
                          v1  VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      NULL;
   END;

-- *************************************************************

  FUNCTION Get_Message(msg_name VARCHAR2,
                       show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
        FND_MESSAGE.Set_Name('SQLGL', msg_name);

        FND_MESSAGE.Set_Token(t1, v1);

        RETURN(SUBSTRB(FND_MESSAGE.Get, 1, 132));

   END;

-- *************************************************************

  FUNCTION Get_Message (msg_name VARCHAR2,
                       show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2,
                       t2       VARCHAR2,
                       v2       VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
        FND_MESSAGE.Set_Name('SQLGL', msg_name);

        FND_MESSAGE.Set_Token(t1, v1);

        FND_MESSAGE.Set_Token(t2, v2);

        RETURN(SUBSTRB(FND_MESSAGE.Get, 1, 132));

   END;

-- ************************************************************

  FUNCTION Get_Message(msg_name VARCHAR2,
                       show_num VARCHAR2,
                       t1       VARCHAR2,
                       v1       VARCHAR2,
                       t2       VARCHAR2,
                       v2       VARCHAR2,
                       t3       VARCHAR2,
                       v3       VARCHAR2) RETURN VARCHAR2 IS

  BEGIN
       FND_MESSAGE.Set_Name('SQLGL', msg_name);

       FND_MESSAGE.Set_Token(t1, v1);

       FND_MESSAGE.Set_Token(t2, v2);

       FND_MESSAGE.Set_Token(t3, v3);

       RETURN(SUBSTRB(FND_MESSAGE.Get, 1, 132));

    END;

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
                       v4       VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
        FND_MESSAGE.Set_Name('SQLGL', msg_name);

        FND_MESSAGE.Set_Token(t1, v1);

        FND_MESSAGE.Set_Token(t2, v2);

        FND_MESSAGE.Set_Token(t3, v3);

        FND_MESSAGE.Set_Token(t4, v4);

        RETURN(SUBSTRB(FND_MESSAGE.Get, 1, 132));

   END;

-- ******************************************************************

  FUNCTION Write_Buffer(msg_name  VARCHAR2,
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
                        v5        VARCHAR2 DEFAULT NULL)
			RETURN VARCHAR2  IS

        msgbuf VARCHAR2(2000);

   BEGIN

      FND_MESSAGE.Set_Name('SQLGL',msg_name);

       IF (token_num = 1)THEN

        FND_MESSAGE.Set_Token(t1,v1);

       ElSIF (token_num = 2) THEN

        FND_MESSAGE.Set_Token(t1,v1);

	FND_MESSAGE.Set_Token(t2,v2);

       ELSIF (token_num = 3) THEN

	FND_MESSAGE.Set_Token(t1,v1);

	FND_MESSAGE.Set_Token(t2,v2);

	FND_MESSAGE.Set_Token(t3,v3);

       ELSIF (token_num = 4)THEN

	FND_MESSAGE.Set_Token(t1,v1);

	FND_MESSAGE.Set_Token(t2,v2);

       ELSIF (token_num = 3) THEN

	FND_MESSAGE.Set_Token(t1,v1);

	FND_MESSAGE.Set_Token(t2,v2);

	FND_MESSAGE.Set_Token(t3,v3);

       ELSIF (token_num = 4)THEN

	FND_MESSAGE.Set_Token(t1,v1);

	FND_MESSAGE.Set_Token(t2,v2);

	FND_MESSAGE.Set_Token(t3,v3);

	FND_MESSAGE.Set_Token(t4,v4);

       ELSIF (token_num = 5) THEN

        FND_MESSAGE.Set_Token(t1,v1);

        FND_MESSAGE.Set_Token(t2,v2);

        FND_MESSAGE.Set_Token(t3,v3);

        FND_MESSAGE.Set_Token(t4,v4);

        FND_MESSAGE.Set_Token(t5,v5);

      END IF;

     msgbuf := msg_name||': '||FND_MESSAGE.Get;

     RETURN (msgbuf);

   END Write_Buffer;

-- ******************************************************************


   PROCEDURE Set_Language ( lang_id NUMBER ) IS

    BEGIN

      NULL;

    END;


-- *****************************************************************


  PROCEDURE Write_Log  (msg_name  VARCHAR2,
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
                        module    VARCHAR2 DEFAULT NULL) IS

	textbuf VARCHAR2(2000);

   BEGIN

      FND_MESSAGE.Set_Name('SQLGL',msg_name);

       IF (token_num = 1)THEN

         FND_MESSAGE.Set_Token(t1,v1);

       ElSIF (token_num = 2) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

       ELSIF (token_num = 3) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

       ELSIF (token_num = 4)THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

         FND_MESSAGE.Set_Token(t4,v4);

       ELSIF (token_num = 5) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

         FND_MESSAGE.Set_Token(t4,v4);

         FND_MESSAGE.Set_Token(t5,v5);

       END IF;

     textbuf := msg_name||': '||FND_MESSAGE.get;

     FND_FILE.Put_Line(FND_FILE.Log,textbuf);

     IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.String(log_level, module, textbuf);
     END IF;
  END Write_Log;

-- *******************************************************************

  PROCEDURE Func_Succ(func_name VARCHAR2,
                      log_level NUMBER   DEFAULT 0,
                      module    VARCHAR2 DEFAULT NULL) IS
        textsuc VARCHAR2(2000);

   BEGIN

      SELECT ('<< '||func_name||'() '||TO_CHAR(SYSDATE)||' '||
              TO_CHAR(SYSDATE,'HH24:MI:SS'))
      INTO textsuc
      FROM Dual;

      FND_FILE.Put_Line(FND_FILE.Log,textsuc);

      IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.String(log_level, module, textsuc);
      END IF;
   END Func_Succ;
-- ******************************************************************

  PROCEDURE Func_Fail(func_name VARCHAR2,
                      log_level NUMBER   DEFAULT 0,
                      module    VARCHAR2 DEFAULT NULL) IS
        textfail VARCHAR2(2000);

   BEGIN

     SELECT ('<x '||func_name||'() '||TO_CHAR(SYSDATE)||' '||
             TO_CHAR(SYSDATE,'HH24:MI:SS'))
     INTO textfail
     FROM Dual;

     FND_FILE.Put_Line(FND_FILE.Log,textfail);

     IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.String(log_level, module, textfail);
     END IF;
   END Func_Fail;

-- *****************************************************************

  PROCEDURE Func_Ent(func_name VARCHAR2,
                      log_level NUMBER   DEFAULT 0,
                      module    VARCHAR2 DEFAULT NULL) IS
        textent VARCHAR2(2000);

   BEGIN

     SELECT ('>> '||func_name||'() '||TO_CHAR(SYSDATE)||' '||
             TO_CHAR(SYSDATE,'HH24:MI:SS'))
     INTO textent
     FROM Dual;

     FND_FILE.Put_Line(FND_FILE.Log,textent);

     IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.String(log_level, module, textent);
     END IF;

  END Func_Ent;


-- *****************************************************************


  PROCEDURE Write_Output(msg_name  VARCHAR2,
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
                        v5        VARCHAR2 DEFAULT NULL) IS

	textbuf VARCHAR2(2000);

   BEGIN

      FND_MESSAGE.Set_Name('SQLGL',msg_name);

       IF (token_num = 1)THEN

         FND_MESSAGE.Set_Token(t1,v1);

       ElSIF (token_num = 2) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

       ELSIF (token_num = 3) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

       ELSIF (token_num = 4)THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

         FND_MESSAGE.Set_Token(t4,v4);

       ELSIF (token_num = 5) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

         FND_MESSAGE.Set_Token(t4,v4);

         FND_MESSAGE.Set_Token(t5,v5);

       END IF;
     textbuf := msg_name||': '||FND_MESSAGE.get;

     FND_FILE.Put_Line(FND_FILE.Output, textbuf);

  END Write_Output;

-- ******************************************************************

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
                        module    VARCHAR2) IS

	textbuf VARCHAR2(2000);

   BEGIN

      FND_MESSAGE.Set_Name('SQLGL',msg_name);

       IF (token_num = 1)THEN

         FND_MESSAGE.Set_Token(t1,v1);

       ElSIF (token_num = 2) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

       ELSIF (token_num = 3) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

       ELSIF (token_num = 4)THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

         FND_MESSAGE.Set_Token(t4,v4);

       ELSIF (token_num = 5) THEN

         FND_MESSAGE.Set_Token(t1,v1);

         FND_MESSAGE.Set_Token(t2,v2);

         FND_MESSAGE.Set_Token(t3,v3);

         FND_MESSAGE.Set_Token(t4,v4);

         FND_MESSAGE.Set_Token(t5,v5);

       END IF;

     textbuf := msg_name||': '||FND_MESSAGE.get;

     IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(log_level, module, textbuf);
     END IF;

  END Write_Fndlog_Msg;

-- *****************************************************************
  PROCEDURE Write_Fndlog_String  (log_level NUMBER,
                                  module    VARCHAR2,
                                  message   VARCHAR2) IS

  BEGIN
    IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(log_level, module, message);
    END IF;

  END Write_Fndlog_String;
-- *****************************************************************
 END GL_MESSAGE;


/
