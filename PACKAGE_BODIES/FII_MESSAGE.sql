--------------------------------------------------------
--  DDL for Package Body FII_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_MESSAGE" AS
/*$Header: FIIUMSGB.pls 115.3 2004/05/18 21:13:01 phu noship $*/

  FUNCTION Get_Message ( msg_name VARCHAR2,
                        show_num VARCHAR2 ) RETURN VARCHAR2 IS
      msg_number NUMBER;
      msg_text   VARCHAR2(2000);

   BEGIN
        FND_MESSAGE.Set_Name('FII', msg_name);

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
        FND_MESSAGE.Set_Name('FII', msg_name);

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
        FND_MESSAGE.Set_Name('FII', msg_name);

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
       FND_MESSAGE.Set_Name('FII', msg_name);

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
        FND_MESSAGE.Set_Name('FII', msg_name);

        FND_MESSAGE.Set_Token(t1, v1);

        FND_MESSAGE.Set_Token(t2, v2);

        FND_MESSAGE.Set_Token(t3, v3);

        FND_MESSAGE.Set_Token(t4, v4);

        RETURN(SUBSTRB(FND_MESSAGE.Get, 1, 132));

   END;

-- ******************************************************************

  FUNCTION Write_Buffer(msg_name  VARCHAR2,
                        token_num NUMBER,
                        t1        VARCHAR2,
                        v1        VARCHAR2,
                        t2        VARCHAR2,
                        v2        VARCHAR2,
                        t3        VARCHAR2,
                        v3        VARCHAR2,
                        t4        VARCHAR2,
                        v4        VARCHAR2,
                        t5        VARCHAR2,
                        v5        VARCHAR2)
			RETURN VARCHAR2  IS

        msgbuf VARCHAR2(5000);

   BEGIN

      FND_MESSAGE.Set_Name('FII',msg_name);

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
                        token_num NUMBER,
                        t1        VARCHAR2,
                        v1        VARCHAR2,
                        t2        VARCHAR2,
                        v2        VARCHAR2,
                        t3        VARCHAR2,
                        v3        VARCHAR2,
                        t4        VARCHAR2,
                        v4        VARCHAR2,
                        t5        VARCHAR2,
                        v5        VARCHAR2) IS

	textbuf VARCHAR2(5000);

   BEGIN

      FND_MESSAGE.Set_Name('FII',msg_name);

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

    -- textbuf := msg_name||': '||FND_MESSAGE.get;
     textbuf := FND_MESSAGE.get;

     FND_FILE.Put_Line(FND_FILE.Log,textbuf);

  END Write_Log;

-- *******************************************************************

  PROCEDURE Func_Succ(func_name VARCHAR2) IS

        textsuc VARCHAR2(2000);

   BEGIN

      SELECT ('<< '||func_name||'() '||TO_CHAR(SYSDATE)||' '||
              TO_CHAR(SYSDATE,'HH24:MI:SS'))
      INTO textsuc
      FROM Dual;

      FND_FILE.Put_Line(FND_FILE.Log,textsuc);

   END Func_Succ;
-- ******************************************************************

  PROCEDURE Func_Fail(func_name VARCHAR2) IS

        textfail VARCHAR2(2000);

   BEGIN

     SELECT ('<x '||func_name||'() '||TO_CHAR(SYSDATE)||' '||
             TO_CHAR(SYSDATE,'HH24:MI:SS'))
     INTO textfail
     FROM Dual;

     FND_FILE.Put_Line(FND_FILE.Log,textfail);

   END Func_Fail;

-- *****************************************************************

  PROCEDURE Func_Ent(func_name VARCHAR2) IS

        textent VARCHAR2(2000);

   BEGIN

     SELECT ('>> '||func_name||'() '||TO_CHAR(SYSDATE)||' '||
             TO_CHAR(SYSDATE,'HH24:MI:SS'))
     INTO textent
     FROM Dual;

     FND_FILE.Put_Line(FND_FILE.Log,textent);

  END Func_Ent;


-- *****************************************************************


  PROCEDURE Write_Output(msg_name  VARCHAR2,
                        token_num NUMBER,
                        t1        VARCHAR2,
                        v1        VARCHAR2,
                        t2        VARCHAR2,
                        v2        VARCHAR2,
                        t3        VARCHAR2,
                        v3        VARCHAR2,
                        t4        VARCHAR2,
                        v4        VARCHAR2,
                        t5        VARCHAR2,
                        v5        VARCHAR2) IS

	textbuf VARCHAR2(5000);

   BEGIN

      FND_MESSAGE.Set_Name('FII',msg_name);

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

     FND_FILE.Put_Line(FND_FILE.Output, FND_MESSAGE.get);

  END Write_Output;

-- ******************************************************************

 END FII_MESSAGE;


/
