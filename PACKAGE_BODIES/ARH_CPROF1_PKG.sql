--------------------------------------------------------
--  DDL for Package Body ARH_CPROF1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CPROF1_PKG" as
/* $Header: ARHCPR1B.pls 120.3 2005/09/21 12:00:39 mantani ship $*/
--
--
--
 -- THIS PROCEDURE IS ADDED TO ENSURE THAT OE, AR AND PA ARE IN SYNC WITH
 -- EACH OTHER AS FAR AS PLACING AND RELEASING CUSTOMERS FROM HOLD.
 -- CALL TO API OE_HOLDS.HOLDS_API IS MADE
 --
 PROCEDURE check_credit_hold (
                               p_customer_id in number,
                               p_site_use_id in number,
                               p_credit_hold in varchar2
                             ) is
 --
 old_credit_hold varchar2(1);
 v_action        varchar2(10);
 v_entity_code   varchar2(1);
 v_entity_id     number(15);
 dummy_message   varchar2(50);
 --
 begin
 --
   if ( p_site_use_id is null ) then
 --
 -- TRANSLATING VALUES TO BE PASSED AS PARAMETERS TO OE_HOLDS.HOLDS_API
 -- WHEN CALLED FROM CUSTOMER PROFILE ZONE
 --
     v_entity_code := 'C';
     v_entity_id   := p_customer_id;
 --
 -- CHECK THE EXISTING VALUE OF CREDIT_HOLD IN THE DATABASE
 --
     declare
       cursor cust_hold is
         select credit_hold
         from   hz_customer_profiles
         where  cust_account_id =  p_customer_id
         and    site_use_id is null;
     begin
       for c in cust_hold
        loop
          old_credit_hold := c.credit_hold;
        end loop;
     end;
 --
  else /* IF NOT NULL */
 --
 -- TRANSLATING VALUES TO BE PASSED AS PARAMETERS TO OE_HOLDS.HOLDS_API
 -- WHEN CALLED FROM ADDRESS PROFILE ZONE
 --
     v_entity_code := 'S';
     v_entity_id   := p_site_use_id;
 --
 -- CHECK THE EXISTING VALUE OF CREDIT_HOLD IN THE DATABASE
 --
    declare
      cursor site_hold is
        select credit_hold
        from   hz_customer_profiles
        where  cust_account_id = p_customer_id
        and    site_use_id = p_site_use_id;
    begin
      for s in site_hold
      loop
        old_credit_hold := s.credit_hold;
      end loop;
    end;
 --
  end if;
 --
 -- IF THE VALUE OF THE DATABASE FIELD IS DIFFERENT THEN THE FORM FIELD THEN
 -- SET THE VALUES FOR THE PARAMETERS TO BE PASSED TO OE_HOLDS.HOLDS_API
 --
   if old_credit_hold is null or
      old_credit_hold <> p_credit_hold then
 --
 -- TRANSLATING VALUES TO BE PASSED AS PARAMETERS TO OE_HOLDS.HOLDS_API
 --
      if p_credit_hold = 'Y' then
        v_action := 'APPLY' ;
      else
        v_action := 'RELEASE';
      end if;
 --
 -- CALL OE API
 --
/* This is obsolete in R12, need to replace with th new signature later
      if OE_HOLDS.HOLDS_API (
                              v_action, 1, v_entity_code,
                              v_entity_id, 'AR_AUTOMATIC', null, dummy_message
                            ) > 0 then
 --
 -- RAISE FATAL EXCEPTION WHEN FUNCTION RETURNS ERROR_CODE
 --
        fnd_message.set_name('AR','AR_CUST_OE_ERROR');
        fnd_message.set_token ('PROCEDURE', 'OE_HOLDS.HOLDS_API');
        fnd_message.set_token ('ERROR_MSG', dummy_message);
        app_exception.raise_exception;

      end if;
*/
   end if;
 --
 END check_credit_hold;
 --
--
 PROCEDURE update_send_dunning_letters ( p_send_dunning_letters IN varchar2,
                                         p_customer_id          IN number,
                                         p_site_use_id          IN number
                                       ) is
  begin

    if p_site_use_id is not null then

    --
    -- UPDATE THE SITE LEVEL PROFILE
    --

      update hz_customer_profiles
      set    dunning_letters = p_send_dunning_letters
      where  cust_account_id     = p_customer_id
      and    site_use_id     = p_site_use_id;

      if SQL%NOTFOUND then
        update hz_customer_profiles
        set    dunning_letters = p_send_dunning_letters
        where  cust_account_id     = p_customer_id
        and    site_use_id     is null;
      end if;

    else

    --
    -- UPDATE THE CUSTOMER LEVEL PROFILE
    --

      update hz_customer_profiles
      set    dunning_letters = p_send_dunning_letters
      where  cust_account_id     = p_customer_id
      and    site_use_id     is null;

      if SQL%NOTFOUND then
        app_exception.invalid_argument('arp_cprof_pkg.update_send_dunning_letters',
                                       'p_customer_id', p_customer_id);

      end if;

    end if;

  end update_send_dunning_letters;
--
-- The following function is added so that the credit_hold can be updated by
-- OE product. The p_customer_id and p_credit_hold parameters are MANDATORY.
-- The function returns 0 or 1 and does not return any error messages.
--
FUNCTION update_credit_hold(p_customer_id IN number,
                            p_site_use_id IN number,
                            p_credit_hold IN varchar2) RETURN BOOLEAN AS

BEGIN
    if (p_site_use_id is null) then
        update hz_customer_profiles
           set credit_hold = p_credit_hold
         where cust_account_id = p_customer_id
           and site_use_id is null;
    else
        update hz_customer_profiles
           set credit_hold = p_credit_hold
         where cust_account_id = p_customer_id
           and site_use_id = p_site_use_id;
    end if;

    return(TRUE);

EXCEPTION
   when no_data_found then
   return(FALSE);

END update_credit_hold;
--
END arh_cprof1_pkg;

/
