--------------------------------------------------------
--  DDL for Package Body HR_CAED_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAED_SS" 
/* $Header: hrcaedw.pkb 120.1 2005/09/21 16:47:12 svittal noship $*/
AS

g_package varchar2(30) := 'HR_CAED_SS';

  PROCEDURE  Create_transaction(
     p_item_type IN WF_ITEMS.ITEM_TYPE%TYPE ,
     p_item_key  	IN WF_ITEMS.ITEM_KEY%TYPE ,
     p_act_id    	IN NUMBER ,
     p_transaction_id   IN OUT NOCOPY NUMBER ,
     p_transaction_step_id IN OUT NOCOPY NUMBER,
     p_login_person_id     IN  NUMBER  )  IS


  l_proc varchar2(200) := g_package || 'Create_transaction';
  ln_transaction_id      NUMBER ;
  ln_transaction_step_id NUMBER ;
  lv_result  VARCHAR2(100) ;
  ltt_trans_obj_vers_num  hr_util_web.g_varchar2_tab_type;
  lv_activity_name        wf_item_activity_statuses_v.activity_name%TYPE;
  lv_creator_person_id    per_all_people_f.person_id%TYPE;
  ln_ovn   NUMBER ;

  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    hr_util_misc_web.validate_session(p_person_id => lv_creator_person_id);

    ln_transaction_id := hr_transaction_ss.get_transaction_id
      (p_Item_Type => p_item_type
      ,p_Item_Key => p_item_key);


    IF ln_transaction_id IS NULL
    THEN

      hr_utility.set_location(l_proc,10);
      hr_transaction_ss.start_transaction
      (itemtype => p_item_type
       ,itemkey => p_item_key
       ,actid => p_act_id
       ,funmode => 'RUN'
       ,p_login_person_id=>p_login_person_id
       ,result => lv_result);

       ln_transaction_id := hr_transaction_ss.get_transaction_id
                              (p_item_type => p_item_type
                               ,p_item_key => p_item_key);

    END IF;     -- now we have a valid txn id , let's find out txn steps


    get_transaction_step(
      p_transaction_id=>ln_transaction_id ,
      p_Item_Type     => p_item_type,
      p_Item_Key      => p_item_key,
      p_transaction_step_id => ln_transaction_step_id ) ;


    IF ln_transaction_step_id  IS NULL THEN

	hr_utility.set_location(l_proc,15);

       --There is no transaction step for this transaction.
       --Create a step within this new transaction

       hr_transaction_api.create_transaction_step(
           p_validate               => false
  	   ,p_creator_person_id     => p_login_person_id
	   ,p_transaction_id        => ln_transaction_id
	   ,p_api_name              => 'HR_CAED_SS.PROCESS_API'
	   ,p_Item_Type             => p_item_type
	   ,p_Item_Key              => p_item_key
           ,p_activity_id           => p_act_id
	   ,p_transaction_step_id   => ln_transaction_step_id
           ,p_object_version_number =>ln_ovn ) ;

    END IF;

    -- write  activity name  to txn table
    hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_activity_name' ,
        p_value =>'HR_CAED' ) ;

     hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>ln_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'P_REVIEW_ACTID' ,
        p_value =>p_act_id ) ;



    p_transaction_id := ln_transaction_id ;
    p_transaction_step_id := ln_transaction_step_id ;


hr_utility.set_location(' Leaving:' || l_proc,20);

  EXCEPTION

   WHEN OTHERS THEN
     hr_utility.trace(' hr_caed.create_transaction: ' || SQLERRM);
     hr_utility.set_location(' Leaving:' || l_proc,555);

     raise ;
     return ;
     commit ;
  END create_transaction ;

  PROCEDURE write_transaction (
    p_transaction_step_id NUMBER ,
    p_login_person_id     NUMBER ,
    p_emp_person_id       NUMBER ,
    p_action              VARCHAR2,
    p_granted_emp_name    VARCHAR2 DEFAULT NULL ,
    p_granted_emp_id      NUMBER   DEFAULT NULL,
    p_granted_user_id     NUMBER   DEFAULT NULL,
    p_deleted_emp_name    VARCHAR2 DEFAULT NULL ,
    p_deleted_emp_id      NUMBER   DEFAULT NULL ,
    p_deleted_emp_user_id NUMBER   DEFAULT NULL ,
    p_review_proc_call    VARCHAR2 DEFAULT NULL ) IS

    l_proc varchar2(200) := g_package || 'write_transaction';
    lv_creator_person_id per_all_people_f.person_id%TYPE;

  BEGIN


    hr_utility.set_location(' Entering:' || l_proc,5);
    hr_util_misc_web.validate_session(p_person_id => lv_creator_person_id);



      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'P_REVIEW_PROC_CALL' ,
        p_value =>p_review_proc_call ) ;


      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_action_type' ,
        p_value =>p_action ) ;


      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_granted_emp_name' ,
        p_value =>p_granted_emp_name ) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_deleted_emp_name' ,
        p_value =>p_deleted_emp_name ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_granted_emp_id' ,
        p_value =>p_granted_emp_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_login_person_id' ,
        p_value =>p_login_person_id ) ;


      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_emp_person_id' ,
        p_value =>p_emp_person_id ) ;


      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_granted_user_id' ,
        p_value =>p_granted_user_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_deleted_emp_id' ,
        p_value =>p_deleted_emp_id ) ;

      hr_transaction_api.set_number_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'p_deleted_emp_user_id' ,
        p_value =>p_deleted_emp_user_id ) ;

      hr_transaction_api.set_varchar2_value (
        p_transaction_step_id =>p_transaction_step_id,
        p_person_id => lv_creator_person_id ,
        p_name => 'P_REVIEW_PROC_CALL' ,
        p_value =>p_review_proc_call ) ;


hr_utility.set_location(' Leaving:' || l_proc,10);

  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace(' HR_CAED_SS.write_transaction ' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,555);
    raise ;

  END WRITE_TRANSACTION ;

  PROCEDURE  get_transaction_step(
    p_transaction_id       in NUMBER ,
    p_item_type            in varchar2,
    p_item_key             in varchar2,
    p_transaction_step_id  out nocopy  NUMBER )  IS

    l_proc varchar2(200) := g_package || 'get_transaction_step';


    cursor c_txn_steps  is
        select hats.transaction_step_id
        from    hr_api_transaction_steps   hats
        where   hats.item_type = p_item_type
        and     hats.transaction_id = p_transaction_id
        and     hats.item_key = p_item_key ;

    ln_transaction_step_id NUMBER := NULL ;

    BEGIN

      hr_utility.set_location(' Entering:' || l_proc,5);
      open c_txn_steps ;
      fetch c_txn_steps into ln_transaction_step_id ;
      close c_txn_steps ;
      p_transaction_step_id := ln_transaction_step_id ;

-- Reset OUT parameters for nocopy.

hr_utility.set_location(' Leaving:' || l_proc,10);
  EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location(' Leaving:' || l_proc,555);
      p_transaction_step_id := null;
    RAISE;

    END get_transaction_step ;

  --***************************************************************************
  -- procedure wrapper to call grant access procedure
  --***************************************************************************
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
   ,p_transaction_step_id   out nocopy  number)
 IS

  l_proc varchar2(200) := g_package || 'grant_access';
  ln_transaction_id         number default null;
  ln_transaction_step_id    number default null;


  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    ---------------------------------------------------------------------------
    -- p_validate = 1 means validate mode, do not update to the database.
    -- p_validate = 0 means non-validate mode, update to the database.
    ---------------------------------------------------------------------------
    IF p_validate = 1 THEN
      hr_utility.set_location(l_proc,10);
      savepoint grant_access ;
    END IF ;

    hr_security_internal.grant_access_to_person (
      p_person_id=> p_emp_person_id,
      p_granted_user_id => p_granted_user_id ) ;

    IF p_validate = 1 THEN
      hr_utility.set_location(l_proc,15);
      ROLLBACK to grant_access ;
    END IF ;

    -- Successfully calling api in validate mode, now call create_transaction
    -- before saving data to transaction table.
    create_transaction (
       p_item_type            => p_item_type
      ,p_item_key             => p_item_key
      ,p_act_id               => p_actid
      ,p_login_person_id      => p_login_person_id
      ,p_transaction_id       => ln_transaction_id
      ,p_transaction_step_id  => ln_transaction_step_id
    );

    -- Now call write_transaction to save to the transaction table.
    write_transaction (
       p_transaction_step_id => ln_transaction_step_id
      ,p_login_person_id     => p_login_person_id
      ,p_emp_person_id       => p_emp_person_id
      ,p_action              => p_action_type
      ,p_granted_emp_name    => p_granted_emp_name
      ,p_granted_emp_id      => p_granted_emp_id
      ,p_granted_user_id     => p_granted_user_id
      ,p_review_proc_call    => p_review_proc_call
    );

   p_transaction_id := ln_transaction_id;
   p_transaction_step_id := ln_transaction_step_id;

hr_utility.set_location(' Leaving:' || l_proc,20);


  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location(' Leaving:' || l_proc,555);
    RAISE ;
  END grant_access ;


--*****************************************************************************
-- Revoke Access
--*****************************************************************************
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
   ,p_transaction_step_id   out nocopy  number)
 IS

  l_proc varchar2(200) := g_package || 'revoke_access';
  ln_transaction_id         number default null;
  ln_transaction_step_id    number default null;

 BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    ---------------------------------------------------------------------------
    -- p_validate = 1 means validate mode, do not update to the database.
    -- p_validate = 0 means non-validate mode, update to the database.
    ---------------------------------------------------------------------------
    IF p_validate = 1 THEN
      hr_utility.set_location(l_proc,10);
      savepoint revoke_access ;
    END IF ;

    hr_security_internal.revoke_access_from_person (
      p_person_id       => p_emp_person_id ,
      p_granted_user_id => p_granted_user_id ) ;

    IF p_validate = 1 THEN
      hr_utility.set_location(l_proc,15);
      ROLLBACK to revoke_access ;
    END IF ;

    -- Successfully calling api in validate mode, now call create_transaction
    -- before saving data to transaction table.
    create_transaction (
       p_item_type            => p_item_type
      ,p_item_key             => p_item_key
      ,p_act_id               => p_actid
      ,p_login_person_id      => p_login_person_id
      ,p_transaction_id       => ln_transaction_id
      ,p_transaction_step_id  => ln_transaction_step_id
    );

    -- Now call write_transaction to save to the transaction table.
    write_transaction (
       p_transaction_step_id => ln_transaction_step_id
      ,p_login_person_id     => p_login_person_id
      ,p_emp_person_id       => p_emp_person_id
      ,p_action              => p_action_type
      ,p_deleted_emp_name    => p_deleted_emp_name
      ,p_deleted_emp_id      => p_deleted_emp_id
      ,p_deleted_emp_user_id => p_deleted_emp_user_id
      ,p_review_proc_call    => p_review_proc_call
    );

   p_transaction_id := ln_transaction_id;
   p_transaction_step_id := ln_transaction_step_id;

hr_utility.set_location(' Leaving:' || l_proc,20);


 EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,555);
    RAISE ;
  END revoke_access ;


--****************************************************************************
-- Process_api is invoked after final approval in Workflow.
--****************************************************************************
  Procedure process_api (
    p_transaction_step_id IN
      hr_api_transaction_steps.transaction_step_id%type,
    p_validate BOOLEAN default FALSE ) IS

    l_proc varchar2(200) := g_package || 'process_api';
    lv_action_type     VARCHAR2(30) ;
    ln_granted_emp_id  NUMBER ;
    ln_emp_person_id   NUMBER ;
    ln_granted_user_id NUMBER ;
    ln_deleted_emp_id  NUMBER ;
    ln_deleted_emp_user_id NUMBER ;

  BEGIN

    hr_utility.set_location(' Entering:' || l_proc,5);
    lv_action_type :=  hr_transaction_api.get_varchar2_value(
                         p_transaction_step_id => p_transaction_step_id,
                         p_name =>'p_action_type');

    ln_granted_emp_id := hr_transaction_api.get_number_value(
                           p_transaction_step_id => p_transaction_step_id,
                           p_name =>'p_granted_emp_id');

    ln_emp_person_id :=  hr_transaction_api.get_number_value(
                           p_transaction_step_id => p_transaction_step_id,
                           p_name =>'p_emp_person_id');

    ln_granted_user_id := hr_transaction_api.get_number_value(
                            p_transaction_step_id => p_transaction_step_id,
                            p_name =>'p_granted_user_id');

    ln_deleted_emp_id := hr_transaction_api.get_number_value(
                           p_transaction_step_id => p_transaction_step_id,
                           p_name =>'p_deleted_emp_id');

    ln_deleted_emp_user_id :=  hr_transaction_api.get_number_value(
                                 p_transaction_step_id =>
                                   p_transaction_step_id,
                                 p_name =>'p_deleted_emp_user_id');


    -- now we have the values from transaction table , we need to call api

    IF lv_action_type = 'Insert'
    THEN
       IF p_validate
       THEN
          hr_utility.set_location(l_proc,10);
          savepoint grant_access ;
       END IF ;
       hr_utility.set_location(l_proc,15);
       hr_security_internal.grant_access_to_person (
             p_person_id       => ln_emp_person_id,
             p_granted_user_id => ln_granted_user_id ) ;

       IF p_validate
       THEN
          hr_utility.set_location(l_proc,20);
          ROLLBACK to grant_access ;
       END IF ;
    END IF;


    IF lv_action_type = 'Delete'
    THEN
       IF p_validate
       THEN
          hr_utility.set_location(l_proc,25);
          savepoint revoke_access ;
       END IF ;

       hr_utility.set_location(l_proc,30);
       hr_security_internal.revoke_access_from_person (
            p_person_id       => ln_emp_person_id,
            p_granted_user_id => ln_deleted_emp_user_id) ;

       IF p_validate
       THEN
          hr_utility.set_location(l_proc,35);
          ROLLBACK to revoke_access ;
       END IF ;
   END IF;


hr_utility.set_location(' Leaving:' || l_proc,40);

   EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(' Leaving:' || l_proc,555);
      RAISE ;

  END PROCESS_API;

END ;


/
