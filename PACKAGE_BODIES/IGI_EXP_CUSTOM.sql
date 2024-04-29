--------------------------------------------------------
--  DDL for Package Body IGI_EXP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_CUSTOM" AS
-- $Header: igicustb.pls 115.5 2002/12/02 15:11:07 rshergil ship $
--

 FUNCTION check_dus_validated(p_notification_id NUMBER)
 RETURN BOOLEAN
 IS
  l_valn_result NUMBER ;
  CURSOR c_check_du_valn(pv_notification_id NUMBER)
  IS
   SELECT COUNT(du.status)
   FROM   wf_notification_attributes WNA
   ,      wf_notifications WN
   ,      wf_message_attributes WMA
   ,      igi_exp_dial_unit_def DU
   ,      igi_exp_tran_unit_def TU
   WHERE  WNA.notification_id = pv_notification_id
   AND    WNA.name            = 'TRANS_UNIT_NUM'
   AND    WNA.notification_id = WN.notification_id
   AND    WN.message_type     = WMA.message_type
   AND    WN.message_name     = WMA.message_name
   AND    WMA.name            = WNA.name
   AND    WNA.text_value      = TU.trans_unit_num
   AND    DU.trans_unit_id    = TU.trans_unit_id
   AND    DU.status           IN ('TRA','HOL') ;
 BEGIN
   OPEN c_check_du_valn(p_notification_id) ;
   FETCH c_check_du_valn INTO l_valn_result ;
   CLOSE c_check_du_valn ;

   IF l_valn_result = 0 THEN
     RETURN(TRUE) ;
   ELSE
     RETURN(FALSE) ;
   END IF ;

 END check_dus_validated ;

END igi_exp_custom ;

/
