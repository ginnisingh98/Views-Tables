--------------------------------------------------------
--  DDL for Package Body HR_VIEW_ALERT_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_VIEW_ALERT_MESSAGES" AS
/* $Header: pervamsg.pkb 115.4 2003/05/16 14:23:13 akmistry noship $ */
msg varchar2(2000);

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 10  */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_token5     in varchar2
                           ,p_token6     in varchar2
                           ,p_token7    in varchar2
                           ,p_token8     in varchar2
                           ,p_token9     in varchar2
                           ,p_tokena     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokena);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 9   */
/* tokens                                             */
/*----------------------------------------------------*/


FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_token5     in varchar2
                           ,p_token6     in varchar2
                           ,p_token7    in varchar2
                           ,p_token8     in varchar2
                           ,p_token9     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 8   */
/* tokens                                             */
/*----------------------------------------------------*/


FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_token5     in varchar2
                           ,p_token6     in varchar2
                           ,p_token7    in varchar2
                           ,p_token8     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;


/*----------------------------------------------------*/
/* Business Group Version  overloaded version with 7  */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_token5     in varchar2
                           ,p_token6     in varchar2
                           ,p_token7    in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 6  */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_token5     in varchar2
                           ,p_token6     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 5   */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_token5     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 4   */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_token4     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 3   */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 2   */
/* tokens                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 1   */
/* token                                             */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Business Group Version 0 tokens                    */
/*                                                    */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_business_group in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_business_group);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN(msg);
END GET_MESSAGE_LNG_BG;

/*----------------------------------------------------*/
/* Supervisor Version
/* 12 TOKENS
/*----------------------------------------------------*/
FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA     in varchar2
                            ,p_tokenB     in varchar2
                            ,p_tokenC     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  HR_BPL_MESSAGE.set_token('TOKENC',p_tokenC);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version
/* 11 TOKENS
/*----------------------------------------------------*/
FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA     in varchar2
                            ,p_tokenB     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version
/* 10 TOKENS
/*----------------------------------------------------*/
FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 9 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 8 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 7 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 6 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 5 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 4 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 3 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 2 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 1 token
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 0 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_SUP('PER',p_message,p_assignment_id);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_SUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_token4     in varchar2
                             ,p_token5     in varchar2
                             ,p_token6     in varchar2
                             ,p_token7     in varchar2
                             ,p_token8     in varchar2
                             ,p_token9     in varchar2
                             ,p_tokenA     in varchar2
                             ,p_tokenB     in varchar2
                             ,p_tokenC     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  HR_BPL_MESSAGE.set_token('TOKENC',p_tokenC);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_token4     in varchar2
                             ,p_token5     in varchar2
                             ,p_token6     in varchar2
                             ,p_token7     in varchar2
                             ,p_token8     in varchar2
                             ,p_token9     in varchar2
                             ,p_tokenA     in varchar2
                             ,p_tokenB     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version
/* TEN TOKENS
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_token4     in varchar2
                             ,p_token5     in varchar2
                             ,p_token6     in varchar2
                             ,p_token7     in varchar2
                             ,p_token8     in varchar2
                             ,p_token9     in varchar2
                             ,p_tokenA     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 9 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_token4     in varchar2
                             ,p_token5     in varchar2
                             ,p_token6     in varchar2
                             ,p_token7     in varchar2
                             ,p_token8     in varchar2
                             ,p_token9     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 8 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_token4     in varchar2
                             ,p_token5     in varchar2
                             ,p_token6     in varchar2
                             ,p_token7     in varchar2
                             ,p_token8     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 7 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_token4     in varchar2
                             ,p_token5     in varchar2
                             ,p_token6     in varchar2
                             ,p_token7     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 6 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 5 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;


/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 4 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 3 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_token3     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 2 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_token2     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 1 token
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;

/*----------------------------------------------------*/
/* Primary Supervisor Version overloaded with 0 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_assignment_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSUP('PER',p_message,p_assignment_id);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END GET_MESSAGE_LNG_PSUP;


/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* ELEVEN TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA    in varchar2
                            ,p_tokenB    in varchar2
                            ,p_tokenC    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  HR_BPL_MESSAGE.set_token('TOKENC',p_tokenC);
  --

  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;



/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* ELEVEN TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA    in varchar2
                            ,p_tokenB    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;


/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* TEN TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* NINE TOKENS                                        */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 8 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 7 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 6 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 5 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 4 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 3 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 2 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 1 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN with     */
/* 0 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN('PER',p_message,p_person_id);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_psn;
--


/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN          */
/* ELEVEN TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA    in varchar2
                            ,p_tokenB    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  HR_BPL_MESSAGE.set_token('TOKENB',p_tokenB);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;


/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN          */
/* TEN TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_tokenA    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  HR_BPL_MESSAGE.set_token('TOKENA',p_tokenA);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN          */
/* NINE TOKENS                                        */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_token9     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  HR_BPL_MESSAGE.set_token('TOKEN9',p_token9);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 8 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_token8     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  HR_BPL_MESSAGE.set_token('TOKEN8',p_token8);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 7 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  HR_BPL_MESSAGE.set_token('TOKEN7',p_token7);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 6 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  HR_BPL_MESSAGE.set_token('TOKEN6',p_token6);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 5 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  HR_BPL_MESSAGE.set_token('TOKEN5',p_token5);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 4 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  HR_BPL_MESSAGE.set_token('TOKEN4',p_token4);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 3 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  HR_BPL_MESSAGE.set_token('TOKEN3',p_token3);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 2 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  HR_BPL_MESSAGE.set_token('TOKEN2',p_token2);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 1 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  HR_BPL_MESSAGE.set_token('TOKEN1',p_token1);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_SUP_PSN with     */
/* 0 TOKENS                                           */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2 IS
--
BEGIN
--
  HR_BPL_MESSAGE.SET_NAME_PSN_PSUP('PER',p_message,p_person_id);
  --
  msg := HR_BPL_MESSAGE.get;
  --
  RETURN  (msg);
--
END get_message_lng_sup_psn;
--
END HR_VIEW_ALERT_MESSAGES;

/
