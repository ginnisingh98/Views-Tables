--------------------------------------------------------
--  DDL for Package Body IGW_PROP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP" AS
--$Header: igwprcpb.pls 115.57 2002/11/14 18:49:26 vmedikon ship $

   -----------------------------------------------------------------------------

   PROCEDURE get_business_group(
                  o_business_group_id   out NOCOPY number,
                  o_business_group_name out NOCOPY varchar2 ) IS
   BEGIN

      SELECT imp.business_group_id,
             org.name
      INTO   o_business_group_id,
             o_business_group_name
      FROM   igw_implementations   imp,
             hr_organization_units org
      WHERE  org.organization_id = imp.business_group_id;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
         null;

   END get_business_group;

   -----------------------------------------------------------------------------

   PROCEDURE get_signing_official(
                i_organization_id       in  number,
                o_signing_official_id   out NOCOPY number,
                o_signing_official_name out NOCOPY varchar2 ) IS
   BEGIN

      SELECT o.signing_official_id,
             p.full_name
      INTO   o_signing_official_id,
             o_signing_official_name
      FROM   igw_org_details o,
             per_people_x    p
      WHERE  o.organization_id = i_organization_id
      AND    p.person_id = o.signing_official_id;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
         null;

   END get_signing_official;

   -----------------------------------------------------------------------------

   FUNCTION get_admin_official_id( i_organization_id number )
   RETURN number IS

      v_admin_official_id number(15);

      CURSOR cur_org_details IS
      SELECT admin_official_id
      FROM   igw_org_details
      WHERE  organization_id = i_organization_id;

   BEGIN

      OPEN  cur_org_details;
      FETCH cur_org_details INTO v_admin_official_id;
      CLOSE cur_org_details;

      RETURN v_admin_official_id;

   END get_admin_official_id;

   -----------------------------------------------------------------------------

   FUNCTION get_user_name( p_person_id number )
   RETURN varchar2 IS

      v_user_name    varchar2(100);

      CURSOR cur_user IS
      SELECT user_name
      FROM   fnd_user
      WHERE  employee_id = p_person_id
      ORDER BY user_id;

   BEGIN

      OPEN  cur_user;
      FETCH cur_user INTO v_user_name;
      CLOSE cur_user;

      RETURN v_user_name;

   END get_user_name;

   -----------------------------------------------------------------------------

   FUNCTION get_pi_full_name( p_proposal_id number )
   RETURN varchar2 IS

      v_pi_full_name   	per_all_people_f.FULL_NAME%TYPE;

   BEGIN

      SELECT full_name
      INTO   v_pi_full_name
      FROM   igw_prop_persons pp,
             per_people_x     per
      WHERE  pp.proposal_id = p_proposal_id
      AND    pp.pi_flag     = 'Y'
      AND    per.person_id = pp.person_id;

      RETURN v_pi_full_name;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
         RETURN null;

   END get_pi_full_name;

   -----------------------------------------------------------------------------
   FUNCTION get_pi_formatted_name( p_proposal_id number )
   RETURN varchar2 IS

      v_pi_full_name   varchar2(301);

   BEGIN

      SELECT last_name||','||first_name
      INTO   v_pi_full_name
      FROM   igw_prop_persons pp,
             per_people_x     per
      WHERE  pp.proposal_id = p_proposal_id
      AND    pp.pi_flag     = 'Y'
      AND    per.person_id = pp.person_id;

      RETURN v_pi_full_name;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
         RETURN null;

   END get_pi_formatted_name;

   -----------------------------------------------------------------------------

   FUNCTION get_lookup_meaning( p_lookup_type varchar2, p_lookup_code varchar2 )
   RETURN varchar2 IS

      v_lookup_meaning  fnd_lookups.meaning%TYPE;

   BEGIN

      SELECT meaning
      INTO   v_lookup_meaning
      FROM   fnd_lookups
      WHERE  lookup_type = p_lookup_type
      AND    lookup_code = p_lookup_code;

      RETURN v_lookup_meaning;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
         RETURN null;

   END get_lookup_meaning;

   -----------------------------------------------------------------------------

   FUNCTION get_narrative_status( p_proposal_id  number )
   RETURN varchar2 IS

      v_count_incomplete  number(3);
      v_count_complete    number(3);

      v_narrative_status  varchar2(1) := 'N';

   BEGIN

      SELECT count(*)
      INTO   v_count_incomplete
      FROM   igw_prop_narratives
      WHERE  proposal_id = p_proposal_id
      AND    module_status = 'I';

      SELECT count(*)
      INTO   v_count_complete
      FROM   igw_prop_narratives
      WHERE  proposal_id = p_proposal_id
      AND    module_status = 'C';

      IF v_count_incomplete = 0 and v_count_complete = 0 THEN
         v_narrative_status := 'N';
      ELSIF v_count_incomplete > 0 THEN
         v_narrative_status := 'I';
      ELSE
         v_narrative_status := 'C';
      END IF;

      RETURN v_narrative_status;

   END get_narrative_status;

   -----------------------------------------------------------------------------

   FUNCTION get_major_subdivision( p_organization_id number )
   RETURN varchar2 IS

      v_major_subdivision varchar2(80);

   BEGIN

      SELECT l.meaning
      INTO   v_major_subdivision
      FROM   fnd_lookups     l,
             igw_org_details o
      WHERE  o.organization_id = p_organization_id
      AND    l.lookup_type = 'IGW_NIH_MAJOR_SUBDIVISION'
      AND    l.lookup_code = o.nih_subdivision_code;

      return v_major_subdivision;

   EXCEPTION

      WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
         RETURN null;

   END;

   -----------------------------------------------------------------------------

   FUNCTION is_proposal_signing_official( p_proposal_id number, p_user_id number )
   RETURN varchar2 IS

      CURSOR cur_user_roles IS
      select 'Y'
      from   igw_prop_user_roles
      where  proposal_id = p_proposal_id
      and    user_id = p_user_id
      and    role_id = 3;

      v_temp   varchar2(1);

   BEGIN

      OPEN  cur_user_roles;
      FETCH cur_user_roles INTO v_temp;
      CLOSE cur_user_roles;

      if v_temp = 'Y' then
         return 'Y';
      end if;

      return 'N';

   END is_proposal_signing_official;

   -----------------------------------------------------------------------------

   FUNCTION get_top_parent_org_name( p_organization_id number )
   RETURN varchar2 IS

      v_curr_organization_id    number(15) := p_organization_id;
      v_parent_organization_id  number(15);

      v_top_parent_org_name     hr_all_organization_units.NAME%TYPE;

   BEGIN

      LOOP

         v_parent_organization_id := igw_proposal_approval.get_parent_org_id( v_curr_organization_id );

         IF v_parent_organization_id IS null THEN
            exit;
         END IF;

         v_curr_organization_id := v_parent_organization_id;

      END LOOP;

      BEGIN

         SELECT name
         INTO   v_top_parent_org_name
         FROM   hr_organization_units
         WHERE  organization_id = v_curr_organization_id;

      EXCEPTION
         WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
            null;

      END;

      RETURN v_top_parent_org_name;

   END get_top_parent_org_name;

   -----------------------------------------------------------------------------

   PROCEDURE ins_prop_user_role( p_proposal_id number,
                                 p_user_id     number,
                                 p_role_id     number ) IS
   BEGIN

      INSERT INTO igw_prop_users
      (
         proposal_id,
         user_id,
         start_date_active,
         end_date_active,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login
      )
      SELECT
         p_proposal_id,
         p_user_id,
         SYSDATE,
         null,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID
      FROM
         dual
      WHERE not exists
         ( SELECT 'X'
           FROM   igw_prop_users
           WHERE  proposal_id = p_proposal_id
           AND    user_id     = p_user_id );


      INSERT INTO igw_prop_user_roles
      (
         proposal_id,
         user_id,
         role_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login
      )
      SELECT
         p_proposal_id,
         p_user_id,
         p_role_id,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID
      FROM
         dual
      WHERE not exists
         ( SELECT 'X'
           FROM   igw_prop_user_roles
           WHERE  proposal_id = p_proposal_id
           AND    user_id     = p_user_id
           AND    role_id     = p_role_id );


   END ins_prop_user_role;

   -----------------------------------------------------------------------------

   PROCEDURE del_prop_user_role( p_proposal_id number,
                                 p_user_id     number,
                                 p_role_id     number ) IS
   BEGIN

      DELETE igw_prop_user_roles
      WHERE  proposal_id = p_proposal_id
      AND    user_id     = p_user_id
      AND    role_id     = p_role_id;

      DELETE igw_prop_users
      WHERE  proposal_id = p_proposal_id
      AND    user_id     = p_user_id
      AND    not exists (
               SELECT 'X'
               FROM   igw_prop_user_roles
               WHERE  proposal_id = p_proposal_id
               AND    user_id     = p_user_id );

   END del_prop_user_role;

   -----------------------------------------------------------------------------

   PROCEDURE copy_proposal_all(
                i_old_proposal_id      IN  number,
                i_new_proposal_id      IN  number,
                i_new_proposal_number  IN  varchar2,
                i_budget_copy_flag     IN  varchar2,
                i_budget_version_id    IN  number,
                i_narrative_copy_flag  IN  varchar2,
                o_error_message        OUT NOCOPY varchar2,
                o_return_status        OUT NOCOPY varchar2 ) IS


      PROCEDURE copy_proposal
      ( p_old_proposal_id number, p_new_proposal_id number, p_new_proposal_number varchar2 ) IS
      BEGIN
         INSERT INTO igw_proposals_all
         (
            sponsor_action_code,
            sponsor_action_date,
            award_amount,
            proposal_id,
            proposal_number,
            lead_organization_id,
            org_id,
            proposal_status,
            proposal_start_date,
            proposal_end_date,
            proposal_title,
            proposal_type_code,
            award_number,
            original_proposal_number,
            original_award_number,
            original_proposal_start_date,
            original_proposal_end_date,
            activity_type_code,
            sponsor_id,
            funding_sponsor_unit,
            original_sponsor_id,
            sponsor_proposal_number,
            notice_of_opportunity_code,
            program_number,
            program_title,
            program_url,
            submitting_organization_id,
            signing_official_id,
            admin_official_id,
            deadline_date,
            deadline_type,
            letter_of_intent_due_date,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15
         )
         SELECT
            null, /* sponsor_action_code */
            null, /* sponsor_action_date */
            null, /* award_amount */
            p_new_proposal_id,
            p_new_proposal_number,
            lead_organization_id,
            org_id,
            'P',
            proposal_start_date,
            proposal_end_date,
            proposal_title,
            proposal_type_code,
            null, /* award_number */
            original_proposal_number,
            original_award_number,
            original_proposal_start_date,
            original_proposal_end_date,
            activity_type_code,
            sponsor_id,
            funding_sponsor_unit,
            original_sponsor_id,
            null, /* sponsor_proposal_number */
            notice_of_opportunity_code,
            program_number,
            program_title,
            program_url,
            submitting_organization_id,
            signing_official_id,
            admin_official_id,
            deadline_date,
            deadline_type,
            letter_of_intent_due_date,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15
         FROM
            igw_proposals_all
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_PROPOSAL');
            raise;
      END;


      PROCEDURE copy_proposal_manager_role
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_users
         (
            proposal_id,
            user_id,
            start_date_active,
            end_date_active,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            user_id,
            SYSDATE,
            null,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_user_roles
         WHERE
            proposal_id = p_old_proposal_id and
            role_id = 0
         ;


         INSERT INTO igw_prop_user_roles
         (
            proposal_id,
            user_id,
            role_id,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            user_id,
            role_id,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_user_roles
         WHERE
            proposal_id = p_old_proposal_id and
            role_id = 0
         ;

      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_PROPOSAL_MANAGER_ROLE');
            raise;
      END;




      PROCEDURE copy_program_addresses
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_program_addresses
         (
            proposal_id,
            address_id,
            number_of_copies,
            mail_description,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            address_id,
            number_of_copies,
            mail_description,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_program_addresses
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_PROGRAM_ADDRESSES');
            raise;
      END;



      PROCEDURE copy_locations
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_locations
         (
            prop_location_id,
            proposal_id,
            performing_organization_id,
            party_id,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            igw_prop_locations_s.nextval,
            p_new_proposal_id,
            performing_organization_id,
            party_id,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_locations
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_LOCATIONS');
            raise;
      END;



      PROCEDURE copy_persons
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_persons
         (
            proposal_id,
            person_id,
            person_party_id,
            person_sequence,
            proposal_role_code,
            pi_flag,
            key_person_flag,
            percent_effort,
            person_organization_id,
            org_party_id,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            person_id,
            person_party_id,
            person_sequence,
            proposal_role_code,
            pi_flag,
            key_person_flag,
            percent_effort,
            person_organization_id,
            org_party_id,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_persons
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_PERSONS');
            raise;
      END;


      PROCEDURE copy_special_reviews
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_special_reviews
         (
            proposal_id,
            special_review_code,
            special_review_type,
            approval_type_code,
            protocol_number,
            application_date,
            approval_date,
            comments,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            special_review_code,
            special_review_type,
            approval_type_code,
            protocol_number,
            application_date,
            approval_date,
            comments,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_special_reviews
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_SPECIAL_REVIEWS');
            raise;
      END;




      PROCEDURE copy_science_codes
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_science_codes
         (
            proposal_id,
            science_code,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            science_code,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_science_codes
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_SCIENCE_CODES');
            raise;
      END;


      PROCEDURE copy_abstracts
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_abstracts
         (
            proposal_id,
            abstract_type,
            abstract_type_code,
            abstract,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15
         )
         SELECT
            p_new_proposal_id,
            abstract_type,
            abstract_type_code,
            abstract,
            1,
            decode(last_update_date,null,null,SYSDATE),
            decode(last_updated_by,null,null,FND_GLOBAL.USER_ID),
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15
         FROM
            igw_prop_abstracts
         WHERE
            proposal_id = p_old_proposal_id;
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_ABSTRACTS');
            raise;
      END;


      PROCEDURE copy_budgets
      ( p_old_proposal_id number, p_new_proposal_id number, p_budget_version_id number ) IS

            v_return_status     varchar2(80);
            v_error_message     varchar2(2000);
            v_msg_count         number(10);

            copy_budget_error   exception;

      BEGIN

         igw_budget_operations.copy_budget
         (
            p_old_proposal_id,
            p_new_proposal_id,
            p_budget_version_id,
            null,
            'P',
            'PROPOSAL_BUDGET',
            v_return_status,
            v_error_message,
            v_msg_count
         );

         IF v_return_status = 'E' or v_return_status = 'U' THEN
            raise copy_budget_error;
         END IF;

      EXCEPTION
         WHEN copy_budget_error THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_BUDGETS');
            raise;

         WHEN others THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_BUDGETS');
            raise;
      END;



      PROCEDURE copy_narratives
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         INSERT INTO igw_prop_narratives
         (
            proposal_id,
            module_id,
            comments,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            email_address,
            module_status,
            contact_name,
            phone_number,
            module_title
         )
         SELECT
            p_new_proposal_id,
            module_id,
            comments,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID,
            email_address,
            'I',
            contact_name,
            phone_number,
            module_title
         FROM
            igw_prop_narratives
         WHERE
            proposal_id = p_old_proposal_id;

         UPDATE igw_proposals_all
         SET    (narrative_type_code, narrative_submission_code) =
                ( SELECT narrative_type_code, narrative_submission_code
                  FROM   igw_proposals_all
                  WHERE  proposal_id = p_old_proposal_id )
         WHERE  proposal_id = p_new_proposal_id;

      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_NARRATIVES');
            raise;
      END;


      PROCEDURE copy_component_statuses
      ( p_old_proposal_id number, p_new_proposal_id number,
        p_budget_copy_flag varchar2, p_narrative_copy_flag varchar2 ) IS

         l_return_status VARCHAR2(1);

      BEGIN

         /*

         INSERT INTO igw_prop_checklist
         (
            proposal_id,
            document_type_code,
            checklist_order,
            complete,
            not_applicable,
            record_version_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
         )
         SELECT
            p_new_proposal_id,
            document_type_code,
            checklist_order,
            'N',
            not_applicable,
            1,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.LOGIN_ID
         FROM
            igw_prop_checklist
         WHERE
            proposal_id = p_old_proposal_id;

         */

         Igw_Prop_Checklist_Pvt.Populate_Checklist
         (
            p_proposal_id   => p_new_proposal_id,
            x_return_status => l_return_status
         );

      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_COMPONENT_STATUSES');
            raise;
      END;


      PROCEDURE copy_proposal_attachments
      ( p_old_proposal_id number, p_new_proposal_id number ) IS
      BEGIN
         fnd_attached_documents2_pkg.copy_attachments
         (
            x_from_entity_name         => 'IGW_PROPOSALS_ALL',
            x_from_pk1_value           => p_old_proposal_id,
            x_from_pk2_value           => null,
            x_from_pk3_value           => null,
            x_from_pk4_value           => null,
            x_from_pk5_value           => null,
            x_to_entity_name           => 'IGW_PROPOSALS_ALL',
            x_to_pk1_value             => p_new_proposal_id,
            x_to_pk2_value             => null,
            x_to_pk3_value             => null,
            x_to_pk4_value             => null,
            x_to_pk5_value             => null,
            x_created_by               => null,
            x_last_update_login        => null,
            x_program_application_id   => null,
            x_program_id               => null,
            x_request_id               => null
         );
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_PROPOSAL_ATTACHMENTS');
            raise;
      END;


      PROCEDURE copy_narrative_attachments
      ( p_old_proposal_id number, p_new_proposal_id number ) IS

         cursor cur_narr_attch is
            select distinct pk2_value
            from   fnd_attached_documents
            where  entity_name = 'IGW_PROP_NARRATIVES'
            and    pk1_value   = p_old_proposal_id;

      BEGIN

         for rec_narr_attch in cur_narr_attch loop

            fnd_attached_documents2_pkg.copy_attachments
            (
               x_from_entity_name         => 'IGW_PROP_NARRATIVES',
               x_from_pk1_value           => p_old_proposal_id,
               x_from_pk2_value           => rec_narr_attch.pk2_value,
               x_from_pk3_value           => null,
               x_from_pk4_value           => null,
               x_from_pk5_value           => null,
               x_to_entity_name           => 'IGW_PROP_NARRATIVES',
               x_to_pk1_value             => p_new_proposal_id,
               x_to_pk2_value             => rec_narr_attch.pk2_value,
               x_to_pk3_value             => null,
               x_to_pk4_value             => null,
               x_to_pk5_value             => null,
               x_created_by               => null,
               x_last_update_login        => null,
               x_program_application_id   => null,
               x_program_id               => null,
               x_request_id               => null
            );

         end loop;

      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_NARRATIVE_ATTACHMENTS');
            raise;
      END;


   begin

      savepoint a;

      copy_proposal( i_old_proposal_id, i_new_proposal_id, i_new_proposal_number );

      copy_proposal_manager_role( i_old_proposal_id, i_new_proposal_id );

      copy_program_addresses( i_old_proposal_id, i_new_proposal_id );

      copy_locations( i_old_proposal_id, i_new_proposal_id );

      copy_persons( i_old_proposal_id, i_new_proposal_id );

      copy_special_reviews( i_old_proposal_id, i_new_proposal_id );

      copy_science_codes( i_old_proposal_id, i_new_proposal_id );

      copy_abstracts( i_old_proposal_id, i_new_proposal_id );

      copy_proposal_attachments( i_old_proposal_id, i_new_proposal_id );

      copy_component_statuses( i_old_proposal_id, i_new_proposal_id, i_budget_copy_flag, i_narrative_copy_flag);

      if i_budget_copy_flag <> 'N' then

         copy_budgets( i_old_proposal_id, i_new_proposal_id, i_budget_version_id );

      end if;

      if i_narrative_copy_flag <> 'N' then

         copy_narratives( i_old_proposal_id, i_new_proposal_id );

         copy_narrative_attachments( i_old_proposal_id, i_new_proposal_id );

      end if;

      o_return_status := 'S';

   exception
      when others then
         rollback to a;
         fnd_msg_pub.add_exc_msg('IGW_PROP', 'COPY_PROPOSAL_ALL' );
         o_error_message := fnd_msg_pub.get( p_msg_index => FND_MSG_PUB.G_FIRST,
                                             p_encoded   => FND_API.G_TRUE );
         o_return_status := 'U';

   end;

   -----------------------------------------------------------------------------

   PROCEDURE set_component_status
                 ( i_component_name IN varchar2,
                   i_proposal_id    IN number,
                   i_value          IN varchar2 ) IS
   BEGIN

      IF i_component_name = 'BUDGET' THEN
         update igw_prop_checklist
         set    complete = decode(i_value,'C','Y','N'),
                not_applicable = decode(i_value,'N','Y','N'),
                last_update_date  = sysdate,
                last_updated_by   = fnd_global.user_id,
                last_update_login = fnd_global.login_id
         where  proposal_id = i_proposal_id
         and    document_type_code = 'BUDGETS';

      ELSIF i_component_name = 'NARRATIVE' THEN

         update igw_prop_checklist
         set    complete = decode(i_value,'C','Y','N'),
                not_applicable = decode(i_value,'N','Y','N'),
                last_update_date  = sysdate,
                last_updated_by   = fnd_global.user_id,
                last_update_login = fnd_global.login_id
         where  proposal_id = i_proposal_id
         and    document_type_code = 'NARRATIVES';

      END IF;

   END set_component_status;

   -----------------------------------------------------------------------------

END igw_prop;

/
