--------------------------------------------------------
--  DDL for Package Body ONT_ICP_GET_USER_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_ICP_GET_USER_DETAILS" as
/*$Header: OEXONTHB.pls 120.1 2005/07/29 13:04:07 jvicenti noship $ */
  procedure get_user_customer(in_user          IN NUMBER,
out_name OUT NOCOPY VARCHAR2,

out_customer OUT NOCOPY VARCHAR2,

out_customer_id OUT NOCOPY NUMBER,

out_contact_id OUT NOCOPY NUMBER,

out_status OUT NOCOPY VARCHAR2

					    ) IS

    CURSOR c_fnd_user IS
      SELECT employee_id,customer_id
      FROM fnd_user
      WHERE user_id = in_user;


    CURSOR c_party(in_customer_id IN NUMBER) IS
	 SELECT party_name,party_type,party_id
	  FROM  hz_parties
      WHERE  party_id = in_customer_id;

    CURSOR c_customer(in_party_id IN VARCHAR2) IS
	 SELECT cust_account_id,
		   party_name
        FROM hz_parties h,hz_cust_accounts c
       WHERE c.party_id = h.party_id
	    AND h.party_id = ( SELECT object_id
						FROM hz_relationships r
                             WHERE r.party_id = in_party_id
 AND   r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   r.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   r.DIRECTIONAL_FLAG = 'F'
                          );

    CURSOR c_user(in_party_id IN VARCHAR2) IS
	 SELECT cust_account_role_id,party_name
	   FROM hz_parties h,hz_cust_account_roles c
       WHERE c.party_id = h.party_id
	    AND h.party_id = ( SELECT subject_id
						FROM hz_relationships r
                             WHERE r.party_id = in_party_id
 AND   r.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   r.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND   r.DIRECTIONAL_FLAG = 'F'                          );


    CURSOR c_employee(in_employee IN NUMBER) IS
      SELECT full_name
      FROM per_all_people_f
      WHERE person_id = in_employee;

    vc_party_name hz_parties.party_name%TYPE;
    vn_party_id   hz_parties.party_id%TYPE;
    vc_party_type hz_parties.party_type%TYPE;
    e_invalid_party_type EXCEPTION;

    vn_customer_id fnd_user.customer_id%TYPE;
    vn_emp_id      fnd_user.employee_id%TYPE;
    vc_last        VARCHAR2(50);
    vc_first       VARCHAR2(40);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  BEGIN

    --==========================================================
    -- Getting the attached employee and customer to the fnd user
    --==========================================================
    OPEN  c_fnd_user;
    FETCH c_fnd_user
    INTO vn_emp_id,
         vn_customer_id;
    CLOSE c_fnd_user;

     --==========================================================
     -- if the employee is attached to the fnd_user than we
     -- select employee first and last name
     --==========================================================
    IF vn_emp_id IS NOT NULL THEN

       OPEN c_employee(vn_emp_id);
	  FETCH c_employee
	   INTO out_name;
       CLOSE c_employee;

	  out_customer := NULL;
	  out_contact_id := NULL;
	  out_customer_id := NULL;

    --==========================================================
    -- if the employee is not attached to the fnd_user than we
    -- select the customer and contact details
    --==========================================================
    ELSE


      --==========================================================
      -- Getting the attached party to the Fnd User
      --==========================================================
      OPEN  c_party(vn_customer_id);
      FETCH c_party
      INTO vc_party_name,
	      vc_party_type,
           vn_party_id;
      CLOSE c_party;

      --==========================================================
      -- if the party is of type 'PERSON' than it is an internal
      -- person
      --==========================================================
      IF vc_party_type = 'PERSON' THEN

         out_name := vc_party_name;
	    out_customer := NULL;
	    out_contact_id := NULL;
	    out_customer_id := NULL;

       --==========================================================
       -- if the party attached is of type 'party_relationship' then
	  -- we find the Customer and the Contact in this relationship
       --==========================================================
       ELSIF vc_party_type = 'PARTY_RELATIONSHIP' THEN

	    OPEN c_customer(vn_party_id);
	    FETCH c_customer
	     INTO out_customer_id,
	    	     out_customer;
         CLOSE c_customer;

	    OPEN c_user(vn_party_id);
	    FETCH c_user
	     INTO out_contact_id,
	    	     out_name;
         CLOSE c_user;
         -- hard coded for test purposes
	    --out_customer_id := 1006;

       ELSE
	    RAISE e_invalid_party_type;

       END IF; /* if party_type */

    END IF; /* if the person is employee */

	out_status := 'TRUE';

     --dbms_output.put_line('user name='||out_name);
     --dbms_output.put_line('customer='||out_customer);

  EXCEPTION

    WHEN OTHERS THEN
	IF c_party%ISOPEN THEN
	  CLOSE c_party;
     END IF;
	IF c_fnd_user%ISOPEN THEN
	  CLOSE c_fnd_user;
     END IF;
	IF c_employee%ISOPEN THEN
	  CLOSE c_employee;
     END IF;
	IF c_user%ISOPEN THEN
	  CLOSE c_user;
     END IF;
	IF c_customer%ISOPEN THEN
	  CLOSE c_customer;
     END IF;

     IF sqlerrm IS NOT NULL THEN
         --fnd_message.set_string(sqlerrm);
         --fnd_message.error;
	    out_status := 'FALSE';
	    NULL;
     END IF;


  END get_user_customer; /* end of procedure*/

end ONT_icp_get_user_details; /* end of package body */

/
