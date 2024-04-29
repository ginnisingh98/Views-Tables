--------------------------------------------------------
--  DDL for Package HR_VIEW_ALERT_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_VIEW_ALERT_MESSAGES" AUTHID CURRENT_USER AS
/* $Header: pervamsg.pkh 115.4 2003/05/16 14:22:14 akmistry noship $ */

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
                           ,p_token7     in varchar2
                           ,p_token8     in varchar2
                           ,p_token9     in varchar2
                           ,p_tokena     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

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
                           ,p_token7     in varchar2
                           ,p_token8     in varchar2
                           ,p_token9     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

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
                           ,p_token7     in varchar2
                           ,p_token8     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

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
                           ,p_token7     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

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
RETURN  varchar2;

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
RETURN  varchar2;

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
RETURN  varchar2;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 3   */
/* tokens                                             */
/*----------------------------------------------------*/


FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_token3     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 2   */
/* tokens                                             */
/*----------------------------------------------------*/


FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_token2     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

/*----------------------------------------------------*/
/* Business Group Version overloaded version with 1   */
/* token                                             */
/*----------------------------------------------------*/


FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_token1     in varchar2
                           ,p_business_group in number)
RETURN  varchar2;

/*----------------------------------------------------*/
/* Business Group Version 0 tokens                    */
/*                                                    */
/*----------------------------------------------------*/


FUNCTION GET_MESSAGE_LNG_BG(p_message    in varchar2
                           ,p_business_group in number)
RETURN  varchar2;


/*----------------------------------------------------*/
/*Supervisor Version overloaded version with 12 tokens*/
/*                                                    */
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
  RETURN  VARCHAR2;

/*----------------------------------------------------*/
/*Supervisor Version overloaded version with 11 tokens*/
/*                                                    */
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
  RETURN  VARCHAR2;

/*----------------------------------------------------*/
/*Supervisor Version overloaded version with 10 tokens*/
/*                                                    */
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
                            ,p_tokenA    in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 9 tokens*/
/*                                                    */
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
  RETURN varchar2;

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
  RETURN varchar2;

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
  RETURN varchar2;

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
  RETURN varchar2;

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
  RETURN varchar2;

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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 3 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 2 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 1 token
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Supervisor Version overloaded version with 0 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_SUP(p_message    in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version with 12 tokens
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version with 11 tokens
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
                            ,p_tokenA    in varchar2
                            ,p_tokenB    in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version with 10 tokens
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
                            ,p_tokenA    in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 9 tokens
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 8 tokens
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 7 tokens
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 6 tokens
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 5 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 4 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 3 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 2 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 1 token
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_token1     in varchar2
                             ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Primary Supervisor Version overload with 0 tokens
/*
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSUP(p_message    in varchar2
                             ,p_assignment_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* TWELVE TOKENS                                      */
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
                            ,p_tokenA     in varchar2
                            ,p_tokenB     in varchar2
                            ,p_tokenC     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* ELEVEN TOKENS                                      */
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
  RETURN varchar2;

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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* NINE TOKENS                                         */
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 8 TOKENS                                         */
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 7 TOKENS                                         */
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
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 6 TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 5 TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 4 TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 3 TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 2 TOKENS                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 1 TOKEN                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* Overloaded Version of GET_MESSAGE_LNG_PSN          */
/* 0 TOKENs                                         */
/*----------------------------------------------------*/

FUNCTION GET_MESSAGE_LNG_PSN(p_message    in varchar2
                            ,p_person_id  in number)
  RETURN varchar2;

/*----------------------------------------------------*/
/* GET_MESSAGE_LNG_SUP_PSN  overloaded functions      */
/*                                                    */
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
  RETURN  VARCHAR2;

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
  RETURN  VARCHAR2;

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
  RETURN  VARCHAR2;

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
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_token7     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_token6     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_token5     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_token4     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_token3     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_token2     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_token1     in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

FUNCTION GET_MESSAGE_LNG_SUP_PSN(p_message    in varchar2
                            ,p_person_id  in number)
  RETURN  VARCHAR2;

END HR_VIEW_ALERT_MESSAGES; -- Package spec


 

/
