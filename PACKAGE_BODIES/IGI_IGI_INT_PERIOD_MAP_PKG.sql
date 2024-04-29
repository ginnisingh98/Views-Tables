--------------------------------------------------------
--  DDL for Package Body IGI_IGI_INT_PERIOD_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGI_INT_PERIOD_MAP_PKG" as
-- $Header: igiintab.pls 120.4.12000000.1 2007/09/12 09:37:26 mbremkum ship $
--
  Function CHECK_DUP_PERIOD(
                            X_Period      varchar2
                           ,X_SOB_ID      number
                           ,X_Source_Name varchar2
                           ) return boolean is

  Cursor C_PERIOD(
                p_period      varchar2
               ,p_sob_id      number
               ,p_source_name varchar2
               ) is
  select SOURCE_PERIOD_NAME
  from   IGI_INT_PERIOD_MAP
  where SET_OF_BOOKS_ID = P_SOB_ID
    and SOURCE_PERIOD_NAME = P_PERIOD
    and JE_SOURCE_NAME = P_SOURCE_NAME;
  period_rec C_PERIOD%ROWTYPE;

  l_return_val boolean;
  data_found exception;

  BEGIN
  open C_PERIOD( X_PERIOD, X_SOB_ID, X_SOURCE_NAME) ;
  fetch C_PERIOD into period_rec;
  IF (C_PERIOD%NOTFOUND) THEN
    raise no_data_found;
  ELSE
    raise data_found;
  END IF;


  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     CLOSE C_PERIOD;
     l_return_val := false;
     RETURN(l_return_val);

  WHEN DATA_FOUND THEN
    CLOSE C_PERIOD;
    l_return_val := true;
    RETURN(l_return_val);

  WHEN OTHERS THEN
    CLOSE C_PERIOD;

    -- Generic error handler
    null;

  END Check_Dup_Period;

END IGI_IGI_INT_PERIOD_MAP_PKG;

/
