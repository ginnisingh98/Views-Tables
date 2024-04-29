--------------------------------------------------------
--  DDL for Package Body IGW_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_SECURITY" AS
--$Header: igwcoseb.pls 115.11 2002/04/23 23:09:57 pkm ship      $

   -----------------------------------------------------------------------------

   FUNCTION allow_create(p_function_name    IN varchar2,
                         p_proposal_id IN number,
                         p_user_id     IN number)
   RETURN varchar2 IS
   BEGIN

      RETURN allow_modify(p_function_name,p_proposal_id,p_user_id);

   END allow_create;

   -----------------------------------------------------------------------------

   FUNCTION allow_modify( p_function_name    IN varchar2,
                          p_proposal_id IN number,
                          p_user_id     IN number)
   RETURN varchar2 IS

      CURSOR cur_status IS
      SELECT proposal_status
      FROM   igw_proposals_all
      WHERE  proposal_id = p_proposal_id;

      l_proposal_status   varchar2(1);

      l_dummy             varchar2(1);

   BEGIN

       -- return 'Y' if current user is a proposal super user

      IF fnd_profile.value_wnps('IGW_PROPOSAL_SUPER_USER') = 'Y' THEN

         RETURN 'Y';

      END IF;

      OPEN  cur_status;
      FETCH cur_status INTO l_proposal_status;
      CLOSE cur_status;

      IF p_function_name = 'GENERAL' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_GENERAL');

         IF l_proposal_status IN ('P','R') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'BUDGET' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_BUDGET');

         IF l_proposal_status IN ('P','R') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'NARRATIVE' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_NARRATIVE');

         IF l_proposal_status IN ('P','R','I') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'CHECKLIST' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_CHECKLIST');

         IF l_proposal_status IN ('P','R','I') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'APPROVAL' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_APPROVAL');

         IF l_proposal_status IN ('P','R') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'SPONSOR_ACTION' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_SPONSOR_ACTION');

         IF l_proposal_status IN ('A') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'AWARD' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('MODIFY_AWARD');

         IF l_proposal_status IN ('A') THEN

            RETURN 'Y';

         END IF;

      ELSIF p_function_name = 'PRINT_PROPOSAL' THEN

         SELECT distinct 'X'
         INTO   l_dummy
         FROM   igw_prop_user_roles ur,
                igw_role_rights     rr
         WHERE  ur.proposal_id = p_proposal_id
         AND    ur.user_id = p_user_id
         AND    rr.role_id = ur.role_id
         AND    rr.right_code in ('PRINT_PROPOSAL');

         RETURN 'Y';

      END IF;

      RETURN 'N';

   EXCEPTION

      WHEN no_data_found THEN
         RETURN 'N';

      WHEN others THEN
         RETURN 'E';

   END allow_modify;

   -----------------------------------------------------------------------------

   function allow_query( p_function_name   IN   VARCHAR2,
                         p_proposal_id     IN   NUMBER,
                         p_user_id         IN   NUMBER)
return varchar2 is
  l_dummy varchar2(1);
begin

   -- return 'Y' if current user is a proposal super user

   IF fnd_profile.value_wnps('IGW_PROPOSAL_SUPER_USER') = 'Y' THEN

      RETURN 'Y';

   END IF;

-- The assumption is that the user who has create or modify rights
-- gets the query right by default

  if p_function_name = 'PROPOSAL' then

    select distinct 'X'
    into l_dummy
    from igw_prop_user_roles ppur,
         igw_role_rights     prr
    where  ppur.role_id = prr.role_id
    and    ppur.proposal_id = p_proposal_id
    and    ppur.user_id = p_user_id
    and    prr.right_code in
           ('VIEW_PROPOSAL','MODIFY_GENERAL','MODIFY_BUDGET',
            'MODIFY_NARRATIVE','MODIFY_CHECKLIST','MODIFY_APPROVAL',
            'MODIFY_SPONSOR_ACTION','MODIFY_AWARD');

  end if;

  return 'Y';

exception

   when no_data_found then
      return 'N';

   when others then
      return 'E';

end allow_query;




---------- function gms_enabled ----------------------------------
-----------------------------------------------------
-- Function to check the implementation status of OGM
-- for an Organization
-- Returns
--     Y if OGM is implemented for the
--          Login Responsibility .
--     N if OGM is not implemented for the
--          Login Responsibility .
---------------------------------
function gms_enabled return varchar2 is
begin

  if gms_install.enabled then
    return 'Y';
  end if;

  RETURN 'N';

end gms_enabled ;



end igw_security;

/
