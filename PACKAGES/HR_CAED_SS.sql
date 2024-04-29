--------------------------------------------------------
--  DDL for Package HR_CAED_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAED_SS" AUTHID CURRENT_USER as
/* $Header: hrcaedw.pkh 115.7 2002/12/04 15:25:19 hjonnala noship $*/

PROCEDURE  Create_transaction(
     p_item_type IN WF_ITEMS.ITEM_TYPE%TYPE ,
     p_item_key  	IN WF_ITEMS.ITEM_KEY%TYPE ,
     p_act_id    	IN NUMBER ,
     p_transaction_id   IN OUT NOCOPY NUMBER ,
     p_transaction_step_id IN OUT NOCOPY NUMBER,
     p_login_person_id     IN  NUMBER  ) ;

Procedure process_api (
    p_transaction_step_id IN
      hr_api_transaction_steps.transaction_step_id%type,
    p_validate BOOLEAN default FALSE ) ;

PROCEDURE write_transaction (
   p_transaction_step_id NUMBER ,
   p_login_person_id     NUMBER ,
   p_emp_person_id       NUMBER ,
   p_action              VARCHAR2 ,
   p_granted_emp_name    VARCHAR2 DEFAULT NULL ,
   p_granted_emp_id      NUMBER   DEFAULT NULL ,
   p_granted_user_id     NUMBER   DEFAULT NULL ,
   p_deleted_emp_name    VARCHAR2 DEFAULT NULL,
   p_deleted_emp_id      NUMBER   DEFAULT NULL,
   p_deleted_emp_user_id NUMBER   DEFAULT NULL ,
   p_review_proc_call    varchar2 DEFAULT NULL) ;

  PROCEDURE  get_transaction_step(
    p_transaction_id       in NUMBER ,
    p_item_type            in varchar2,
    p_item_key             in varchar2,
    p_transaction_step_id  out nocopy  NUMBER )  ;

  PROCEDURE grant_access (
    p_validate              in   number default 1
   ,p_item_type             in   varchar2
   ,p_item_key              in   varchar2
   ,p_actid                 in   number
   ,p_emp_person_id         in   number
   ,p_login_person_id       in   number
   ,p_action_type           in   varchar2
   ,p_granted_emp_name      in   varchar2  default null
   ,p_granted_emp_id        in   number default null
   ,p_granted_user_id       in   number default null
   ,p_review_proc_call      in   varchar2 default null
   ,p_transaction_id        out nocopy  number
   ,p_transaction_step_id   out nocopy  number);


  PROCEDURE revoke_access (
    p_validate              in   number default 1
   ,p_item_type             in   varchar2
   ,p_item_key              in   varchar2
   ,p_actid                 in   number
   ,p_emp_person_id         in   number
   ,p_login_person_id       in   number
   ,p_action_type           in   varchar2
   ,p_granted_user_id       in   number
   ,p_deleted_emp_name      in   varchar2  default null
   ,p_deleted_emp_id        in   number default null
   ,p_deleted_emp_user_id   in   number default null
   ,p_review_proc_call      in   varchar2 default null
   ,p_transaction_id        out nocopy  number
   ,p_transaction_step_id   out nocopy  number);


END hr_caed_ss;

 

/
