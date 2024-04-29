--------------------------------------------------------
--  DDL for Package HR_SALARY2_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY2_WEB" AUTHID CURRENT_USER AS
/* $Header: hrprsa2w.pkh 120.2 2005/09/25 09:08:44 svittal noship $*/

    gv_activity_name         wf_item_activity_statuses_v.activity_name%TYPE
                             :='HR_MAINTAIN_SALARY' ;
    gv_process_name          wf_process_activities.process_name%TYPE
                             := 'HR_SALARY_PRC' ;
    gv_package_name          VARCHAR2(30) := 'HR_SALARY2_WEB' ;

    /* ======================================================================
    || Function: get_precision
    ||----------------------------------------------------------------------
    || Description: validates assignment and existing proposal to determine
    ||
    ||
    || Pre Conditions: a valid assignment id
    ||
    ||
    || In Parameters: p_uom
    ||                p_currency_code
    ||                p_date
    ||
    ||
    || Out Parameters:
    ||
    ||
    || In Out Parameters:
    ||
    ||
    || Post Success:
    ||
    ||     processing continues
    ||
    || Post Failure:
    ||     Raises Error
    ||
    || Access Status:
    ||     Public.
    ||
    ||=================================================================== */

  FUNCTION  get_precision(
     p_uom           VARCHAR2 ,
     p_currency_code VARCHAR2 ,
     p_date          DATE )
  RETURN  NUMBER ;


    /* ======================================================================
    || Function: get_currency_symbol
    ||----------------------------------------------------------------------
    || Description: gets a currecy symbol for a given currency code
    ||
    ||
    || Pre Conditions: a valid currency code
    ||
    ||
    || In Parameters: p_currency_code
    ||                p_date
    ||
    || Out Parameters:
    ||
    ||
    || In Out Parameters:
    ||
    ||
    || Post Success:
    ||
    ||     returns currency code
    ||
    || Post Failure:
    ||     Raises Error
    ||
    || Access Status:
    ||     Public.
    ||
    ||=================================================================== */

  FUNCTION  get_currency_symbol(
     p_currency_code VARCHAR2 ,
     p_date          DATE )
  RETURN  VARCHAR2;


End ;

 

/
