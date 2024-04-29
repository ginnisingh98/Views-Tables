--------------------------------------------------------
--  DDL for Package Body JTF_TASK_UWQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_UWQ_PVT" AS
/* $Header: jtfvtkqb.pls 115.6 2002/10/31 23:44:06 cjang ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|   jtfvtkqs.pls                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|   This package is used by JTF_TASK_UWQ_MYOWN_V                        |
|                                                                       |
| Date          Developer    Change                                     |
| -----------   -----------  ---------------------------------------    |
| 10-Apr-2002   cjang        Created                                    |
| 12-Apr-2002   cjang        If phone is not found in jtf_task_phone,   |
|                             then select contact's primary phone       |
|                                      from hz_contact_points           |
| 01-Oct-2002  Sanjeev K.    use hz_relationships in place of           |
|                            hz_party_relationships                     |
|                            hz_party_relationships is obsoleted.       |
| 15-Oct-2002   cjang        Fixed bug 2467845:                         |
|                            Modified the cursor c_phone_hz             |
|                             to get the phone from relationship,       |
|                              not from subject_id.                     |
| 30-Oct-2002  Chanik Jang   Modified get_primary_email()               |
|                              removed hz_relationships from cursor     |
*=======================================================================*/
    FUNCTION get_primary_phone (p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_phone (b_task_id NUMBER) IS
        SELECT decode(hcp.phone_country_code, NULL, NULL, '+'||hcp.phone_country_code||' ')||
               '('||hcp.phone_area_code||') '||
               hcp.phone_number||
               decode(hcp.phone_extension, NULL, NULL, ' <'||hcp.phone_extension||'>') phone_number
          FROM jtf_task_contacts jtc
             , jtf_task_phones jtp
             , hz_contact_points hcp
         WHERE jtc.task_id = b_task_id
           AND jtc.primary_flag = 'Y'
           AND jtp.task_contact_id = jtc.task_contact_id
           AND jtp.owner_table_name = 'JTF_TASK_CONTACTS'
           AND jtp.primary_flag = 'Y'
           AND hcp.contact_point_id = jtp.phone_id
           AND hcp.contact_point_type = 'PHONE';

        -- Fixed bug 2467845:
        --   Removed the hz_relationships from FROM clause
        --   not to get the phone from subject_id.
        --   The phone must be retrieved from relationship party_id (= jtf_task_contacts.contact_id)
        CURSOR c_phone_hz (b_task_id NUMBER) IS
        SELECT decode(hcp.phone_country_code, NULL, NULL, '+'||hcp.phone_country_code||' ')||
               '('||hcp.phone_area_code||') '||
               hcp.phone_number||
               decode(hcp.phone_extension, NULL, NULL, ' <'||hcp.phone_extension||'>') phone_number
          FROM jtf_task_contacts jtc
             , hz_contact_points hcp
         WHERE jtc.task_id = b_task_id
           AND jtc.primary_flag = 'Y'
           AND hcp.owner_table_id = jtc.contact_id
           AND hcp.owner_table_name = 'HZ_PARTIES'
           AND hcp.contact_point_type = 'PHONE'
           AND hcp.primary_flag = 'Y';

        l_phone  jtf_task_uwq_myown_v.primary_phone%TYPE;
    BEGIN
        OPEN c_phone (b_task_id => p_task_id);
        FETCH c_phone INTO l_phone;

        IF c_phone%NOTFOUND
        THEN
            OPEN c_phone_hz (b_task_id => p_task_id);
            FETCH c_phone_hz INTO l_phone;
            CLOSE c_phone_hz;
        END IF;
        CLOSE c_phone;

        RETURN l_phone;

    END get_primary_phone;

    FUNCTION get_primary_email (p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_email (b_task_id NUMBER) IS
        SELECT hcp.email_address
          FROM jtf_task_contacts jtc
             , hz_contact_points hcp
         WHERE jtc.task_id = b_task_id
           AND jtc.primary_flag = 'Y'
           AND hcp.owner_table_id = jtc.contact_id
           AND hcp.owner_table_name = 'HZ_PARTIES'
           AND hcp.contact_point_type = 'EMAIL'
           AND hcp.primary_flag = 'Y';

        rec_email  c_email%ROWTYPE;
    BEGIN
        OPEN c_email (b_task_id => p_task_id);
        FETCH c_email INTO rec_email;

        IF c_email%NOTFOUND
        THEN
            CLOSE c_email;
            RETURN NULL;
        END IF;
        CLOSE c_email;

        RETURN rec_email.email_address;
    END get_primary_email;

END jtf_task_uwq_pvt;

/
