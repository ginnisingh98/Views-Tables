--------------------------------------------------------
--  DDL for Package Body JAI_ARRA_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_ARRA_TRG_PKG" AS
/* $Header: jai_arra_trg.plb 120.1.12000000.1 2007/07/24 06:55:42 rallamse noship $ */


/***************************************************************************************************
CREATED BY       : CSahoo
CREATED DATE     : 01-FEB-2007
ENHANCEMENT BUG  : 5631784
PURPOSE          : NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES

-- #
-- # Change History -


1.  01/02/2007   CSahoo for bug#5631784. File Version 120.0
								 Forward Porting of 11i BUG#4742259 (TAX COLLECTION AT SOURCE IN RECEIVABLES)

*******************************************************************************************************/

  /* Package levek variables used in debug package */
  lv_object_name      jai_cmn_debug_contexts.LOG_CONTEXT%TYPE DEFAULT 'TCS.JAI_ARRA_TRG_PKG';
  lv_member_name      jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;
  lv_context          jai_cmn_debug_contexts.LOG_CONTEXT%TYPE;

 PROCEDURE set_debug_context
 IS
 BEGIN
   lv_context  := rtrim(lv_object_name || '.'||lv_member_name,'.');
 END set_debug_context;


  PROCEDURE process_app      (    r_new               IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE    ,
                                  r_old               IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE    ,
                                  p_process_flag      OUT NOCOPY      VARCHAR2                                  ,
                                  p_process_message   OUT NOCOPY      VARCHAR2
                             )

  /***********************************************************************************
  || Created By    : Aiyer
  || Creation Date : 22-09-2006
  || Bug No        : 4742259
  || Purpose       : Trigger package for ar_receivable_applications_all
  || Called From   : Trigger jai_arra_ariud_trg
  ************************************************************************************/
  AS
    ln_reg_id           NUMBER;
    lv_process_flag           VARCHAR2(2)                       ;
    lv_process_message        VARCHAR2(4000)                    ;

  BEGIN
    /*########################################################################################################
    || VARIABLES INITIALIZATION - PART -1
    ########################################################################################################*/
    lv_member_name        := 'PROCESS_APP';
    set_debug_context;


    lv_process_flag         := jai_constants.successful   ;
    lv_process_message      := null                       ;

    p_process_flag          := lv_process_flag            ;
    p_process_message       := lv_process_message         ;

    /*########################################################################################################
    || CALL TCS REPOSITORY PROCESSING - PART -2
    ########################################################################################################*/


    jai_ar_tcs_rep_pkg.process_transactions ( p_event             => r_new.application_type   ,
                                              p_araa              => r_new                    ,
                                              p_process_flag      => lv_process_flag          ,
                                              p_process_message   => lv_process_message
                                            );


    IF lv_process_flag = jai_constants.expected_error    OR                      ---------A2
       lv_process_flag = jai_constants.unexpected_error  OR
       lv_process_flag = jai_constants.not_applicable
    THEN
      /*
      || As Returned status is an error hence:-
      || Set out variables p_process_flag and p_process_message accordingly
      */
      --call to debug package

      p_process_flag    := lv_process_flag    ;
      p_process_message := lv_process_message ;
      return;
    END IF;                                                                      ---------A2


  END process_app;

END jai_arra_trg_pkg;

/
