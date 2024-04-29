--------------------------------------------------------
--  DDL for Package Body FND_OAM_USER_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_USER_INFO" AS
/* $Header: AFOAMUIB.pls 120.2 2005/10/10 21:46:24 fskinner noship $ */



  -- Name
  --   get_contact_info
  --
  -- Purpose
  --   Returns the contact information of a user
  --
  -- Input Arguments
  --   p_username - User name.
  --
  -- Output Arguments
  --   full_name - Full name of the person
  --   phone     - Phone number
  --   email     - Email address
  --   fax       - Fax number
  --
  --
  PROCEDURE get_contact_info
    (p_username IN VARCHAR2,
     full_name  OUT NOCOPY VARCHAR2,
     phone      OUT NOCOPY VARCHAR2,
     email      OUT NOCOPY VARCHAR2,
     fax        OUT NOCOPY VARCHAR2,
     user_guid  OUT NOCOPY VARCHAR2)
  IS
      v_user_id  NUMBER;
      v_employee_id NUMBER;
      v_customer_id NUMBER;
      v_supplier_id NUMBER;
      suffix varchar2(10);
      first_name varchar2(100);
      last_name varchar2(100);
  BEGIN

-- get user_id, employee_id, customer_id, and supplier_id

    begin
        select u.user_id, nvl(u.employee_id, -1),
               nvl(u.customer_id, -1), nvl(u.supplier_id, -1),
	       user_guid
            into v_user_id, v_employee_id, v_customer_id,
		 v_supplier_id, user_guid
            from fnd_user u
            where upper(user_name) = upper(p_username);
    exception
    when no_data_found then
        v_employee_id := -1;
        v_customer_id := -1;
        v_supplier_id := -1;
	user_guid := null;
    end;

    begin
        IF v_employee_id > 0
        THEN
            SELECT
                   per.full_name,
                   per.work_telephone,
                   per.email_address,
                   usr.fax
            INTO full_name, phone, email, fax
            FROM
                   fnd_user usr,
                   per_all_people_f per
            WHERE
                   trunc(SYSDATE) between per.effective_start_date
                                  and per.effective_end_date
                   and per.person_id = usr.employee_id
                   and usr.user_id = v_user_id;

        ELSIF v_customer_id > 0 OR v_supplier_id > 0
        THEN
            SELECT
                   hz.PERSON_NAME_SUFFIX,
                   hz.PERSON_FIRST_NAME,
                   hz.PERSON_LAST_NAME,
                   hz.email_address,
                   usr.fax
            INTO suffix, first_name, last_name, email, fax
            FROM
                   fnd_user usr,
                   hz_parties hz
            WHERE
                   (hz.party_id = usr.customer_id
                        OR hz.party_id = usr.supplier_id)
                   and usr.user_id = v_user_id;

            IF last_name is not null THEN
               last_name := CONCAT(last_name, ', ');
            END IF;

            IF suffix is not null THEN
               suffix := CONCAT(suffix, ' ');
            END IF;

            full_name := CONCAT(CONCAT(last_name, suffix), first_name);

--        ELSIF user_guid is not null
--        THEN
-- it indicates that the row is being synchronized with an external directory such as OID.
        END IF;

        EXCEPTION
         WHEN no_data_found THEN
                full_name := null;

     end;


  END get_contact_info;


  --
  -- Return PARTY_ID given EMPLOYEE_ID
  --
  function GET_PARTY_ID(P_EMPLOYEE_ID in number) return number
  is
    L_EMP_PERSON_PARTY_ID number;
  begin
    SELECT  party_id
      INTO  l_emp_person_party_id
      FROM  per_all_people_f
     WHERE  person_id = p_employee_id
       AND  trunc(sysdate) between effective_start_date and effective_end_date
     UNION
    SELECT  party_id
      FROM  per_all_people_f p
     WHERE  p.person_id = p_employee_id
       AND  p.effective_start_date = (SELECT min(p2.effective_start_date)
                                        FROM per_all_people_f p2
                                       WHERE p2.person_id = p.person_id)
       AND  p.effective_start_date > trunc(sysdate);
    return(L_EMP_PERSON_PARTY_ID);
  end GET_PARTY_ID;

  --
  -- Given PARTY_ID return PARTY_NAME, PARTY_TYPE
  --
  procedure HZ_PARTY_ID_TO_NAME(P_PARTY_ID in number,
                                P_PARTY_NAME out nocopy varchar2,
                                P_PARTY_TYPE out nocopy varchar2)
  is
  begin
    select PARTY_TYPE, PARTY_NAME
      into P_PARTY_TYPE, P_PARTY_NAME
      from HZ_PARTIES
     where PARTY_ID = P_PARTY_ID;
  end HZ_PARTY_ID_TO_NAME;

  --
  -- Given PARTY_NAME return PARTY_ID, PARTY_TYPE
  --
  procedure HZ_PARTY_NAME_TO_ID(P_PARTY_NAME in varchar2,
                                P_PARTY_ID out nocopy number,
                                P_PARTY_TYPE out nocopy varchar2)
  is
  begin
    select PARTY_TYPE, PARTY_ID
      into P_PARTY_TYPE, P_PARTY_ID
      from HZ_PARTIES
     where PARTY_NAME = P_PARTY_NAME;
  end HZ_PARTY_NAME_TO_ID;

  --
  -- Get organization party ID given customer party ID
  --
  function GET_ORGANIZATION_ID(P_CUSTOMER_ID in number) return number
  is
    L_CUST_PERSON_PARTY_ID number;
  begin
    select rel.subject_id
      into l_cust_person_party_id
      from hz_relationships rel
     where rel.party_id = p_customer_id
       and rel.subject_table_name = 'HZ_PARTIES'
       and rel.subject_type = 'PERSON'
       and rel.object_table_name = 'HZ_PARTIES'
       and rel.object_type = 'ORGANIZATION';

    return(L_CUST_PERSON_PARTY_ID);
  end GET_ORGANIZATION_ID;

END fnd_oam_user_info;



/
