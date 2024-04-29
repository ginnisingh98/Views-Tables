--------------------------------------------------------
--  DDL for Package Body JTF_UMUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UMUTIL" as
/* $Header: JTFUMLDB.pls 115.3 2002/02/14 12:09:36 pkm ship     $ */

  --
  -- PUBLIC
  --

 -----------------------------------------------------------------------------------
 /* Function to lookup usertype_id based on usertype_key and effective start date */
 -----------------------------------------------------------------------------------
 function usertype_lookup(
  utype_key IN varchar2,
  effective_date IN date)
  return number is
    utype_id number;
  begin

    select usertype_id
    into utype_id
    from jtf_um_usertypes_b
    where usertype_key = utype_key
    and effective_start_date = effective_date;

    return utype_id;

  exception
    when NO_DATA_FOUND then
      return NULL;

  end usertype_lookup;

 -------------------------------------------------------------------------------------------
 /* Function to lookup subscription_id based on subscription_key and effective start date */
 -------------------------------------------------------------------------------------------
 function subscription_lookup(
  subscr_key IN varchar2,
  effective_date IN date)
  return number is
    subscr_id number;
  begin

    select subscription_id
    into subscr_id
    from jtf_um_subscriptions_b
    where subscription_key = subscr_key
    and effective_start_date = effective_date;

    return subscr_id;

  exception
    when NO_DATA_FOUND then
      return NULL;

  end subscription_lookup;

 -----------------------------------------------------------------------------------
 /* Function to lookup template_id based on template_key and effective start date */
 -----------------------------------------------------------------------------------
 function template_lookup(
  tmpl_key IN varchar2,
  effective_date IN date)
  return number is
    tmpl_id number;
  begin

    select template_id
    into tmpl_id
    from jtf_um_templates_b
    where template_key = tmpl_key
    and effective_start_date = effective_date;

    return tmpl_id;

  exception
    when NO_DATA_FOUND then
      return NULL;

  end template_lookup;

 -----------------------------------------------------------------------------------
 /* Function to lookup approval_id based on approval_key and effective start date */
 -----------------------------------------------------------------------------------
 function approval_lookup(
  appr_key IN varchar2,
  effective_date IN date)
  return number is
    appr_id number;
  begin

    select approval_id
    into appr_id
    from jtf_um_approvals_b
    where approval_key = appr_key
    and effective_start_date = effective_date;

    return appr_id;

  exception
    when NO_DATA_FOUND then
      return NULL;

  end approval_lookup;

 -----------------------------------------------------------------------------------
 /* Function to lookup approval_id based on approval_key and effective start date */
 /* Here, if ID not found, throw exception                                        */
 -----------------------------------------------------------------------------------
 function approval_lookup_with_check(
  appr_key IN varchar2,
  effective_date IN date)
  return number is
    appr_id number;
  begin

    if( (appr_key is NULL) and (effective_date is null) )
    then
       return NULL;
    end if;

    select approval_id
    into appr_id
    from jtf_um_approvals_b
    where approval_key = appr_key
    and effective_start_date = effective_date;

    return appr_id;

  exception
    when NO_DATA_FOUND then
      -- raising exception here as approval_id does not exist
      fnd_message.set_name('JTF', 'APPROVAL_ID_NOT_FOUND');
      app_exception.raise_exception;

  end approval_lookup_with_check;

 -------------------------------------------------------------------------------------------
 /* Function to lookup subscription_id based on subscription_key and effective start date */
 /* Here, if ID not found, throw exception                                                */
 -------------------------------------------------------------------------------------------
 function subscription_lookup_with_check(
  subscr_key IN varchar2,
  effective_date IN date)
  return number is
    subscr_id number;
  begin

    if( (subscr_key is NULL) and (effective_date is null) )
    then
       return NULL;
    end if;

    select subscription_id
    into subscr_id
    from jtf_um_subscriptions_b
    where subscription_key = subscr_key
    and effective_start_date = effective_date;

    return subscr_id;

  exception
    when NO_DATA_FOUND then
      -- raising exception here as approval_id does not exist
      fnd_message.set_name('JTF', 'SUBSCRIPTION_ID_NOT_FOUND');
      app_exception.raise_exception;

  end subscription_lookup_with_check;

 -----------------------------------------------------------------------------------
 /* Function to lookup username based on user_id                                  */
 -----------------------------------------------------------------------------------
 function user_lookup(
  uname IN varchar2)
  return number is
    u_id number;
  begin

    select user_id
    into u_id
    from fnd_user
    where user_name = uname;

    return u_id;

  exception
    when NO_DATA_FOUND then
      return NULL;

  end user_lookup;


  function date_to_char(
   inDate IN date)
   return varchar2 is
     returnVal VARCHAR2(19);
   begin

     return to_char( inDate, 'YYYY/MM/DD HH24:MI:SS' );

   end date_to_char;
end JTF_UMUTIL;

/
