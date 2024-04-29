--------------------------------------------------------
--  DDL for Package Body QA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SECURITY_PKG" AS
/* $Header: qltsecb.plb 120.5 2006/08/02 07:52:40 ntungare noship $ */

    --
    -- R12 ER 2648803.  Rewritten to use TCA V2 APIs.
    -- A new constant is required to stand for created_by_module.
    -- This has been registered with TCA and they will validate
    -- all API calls are invoked by registered modules.
    -- bso Thu Jul 14 13:55:27 PDT 2005
    --

    c_module_name CONSTANT VARCHAR2(6) := 'QLTSEC';
    c_app_name    CONSTANT VARCHAR2(2) := 'QA';


/* There are three private procedures QA_GRANTS and QA_REVOKE
	CALL_GRANTS */
---------------------------------------------------------------
Procedure QA_GRANTS(p1_grantee_type     in   varchar2,
                      p1_grantee_key    in   varchar2,
                      p_plan_id         in   number,
                      p1_menu_name      in   varchar2,
                      x1_grant_guid     out  NOCOPY raw) IS
---------------------------------------------------------------

   result VARCHAR2(5);
   errorcode NUMBER;
begin
--test_mesg1('p1 grantee type :'||p1_grantee_type||' p_plan_id :'||to_char(p_plan_id));
--test_mesg1('p1_grantee_key :'||p1_grantee_key||' p1_menu_name :'||p1_menu_name);

    fnd_grants_pkg.grant_function(
       p_api_version => 1.0,
       p_menu_name => p1_menu_name,
       p_object_name => 'QA_PLANS',
       p_instance_type => 'INSTANCE',
       p_instance_pk1_value  => to_char(p_plan_id),
       p_grantee_type => p1_grantee_type,
       p_grantee_key => p1_grantee_key,
       p_start_date => sysdate,
       p_end_date => null,
       x_grant_guid => x1_grant_guid,
       x_success => result,
       x_errorcode => errorcode);

    IF (result = 'F') THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

--test_mesg1('grant_id: '||x1_grant_guid);
--test_mesg1('result : '||result);
--test_mesg1('errorcode: '||errorcode);

end qa_grants;


---------------------------------------------------------------
Procedure qa_revoke(x1_grant_guid in out NOCOPY raw) IS
---------------------------------------------------------------

   result VARCHAR2(5);
   errorcode NUMBER;
begin
--test_mesg1('Inside Revoke : '||x1_grant_guid);

    fnd_grants_pkg.revoke_grant(
       p_api_version => 1.0,
       p_grant_guid => x1_grant_guid,
       x_success => result,
       x_errorcode => errorcode);

    IF (result = 'F') THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

x1_grant_guid := null;
--test_mesg1('After Revoke : '||x1_grant_guid);

end qa_revoke;


------------------------------------------------------------------------
Procedure   CALL_GRANTS(p_event       in varchar2,
			p_menu_name   in varchar2,
                	p_grantee_id  in number,
			p_plan_id     in number,
                	p_flag        in varchar2,
			x_guid        in out NOCOPY raw) IS
------------------------------------------------------------------------
v_grantee_type  FND_GRANTS.GRANTEE_TYPE%TYPE;
v_grantee_key   FND_GRANTS.GRANTEE_KEY%TYPE;

Begin

     v_grantee_type := 'GROUP';
     v_grantee_key := 'HZ_GROUP:'||to_char(p_grantee_id);

If ((p_flag = 'Y') AND (p_event = 'ON-INSERT')) then
     qa_grants(v_grantee_type,  v_grantee_key, p_plan_id, p_menu_name, x_guid);

Elsif ((p_flag = 'Y') AND (p_event = 'ON-UPDATE') AND (x_guid IS NULL)) then
     qa_grants(v_grantee_type, v_grantee_key, p_plan_id, p_menu_name, x_guid);

Elsif ((p_flag <> 'Y') AND (p_event = 'ON-UPDATE') AND (x_guid IS NOT NULL)) then
     qa_revoke(x_guid);

Elsif ((x_guid IS NOT NULL) AND (p_event = 'ON-DELETE')) then
     qa_revoke(x_guid);

end if;

End Call_grants;

/* All the other procedures are public procedures and are mentioned in the
   specification */

----------------------------------------------------------------------------------
Procedure Create_Grant(EVENT   in varchar2,
                p_grantee_id   in number,       p_plan_id     in     number,
                p_setup_flag   in varchar2,     x_setup_guid  in out NOCOPY raw,
                p_enter_flag   in varchar2,     x_enter_guid  in out NOCOPY raw,
                p_view_flag    in varchar2,     x_view_guid   in out NOCOPY raw,
                p_update_flag  in varchar2,     x_update_guid in out NOCOPY raw,
                p_delete_flag  in varchar2,     x_delete_guid in out NOCOPY raw) IS
----------------------------------------------------------------------------------

begin

CALL_GRANTS(EVENT, 'QA_PLANS_SETUP_USER', p_grantee_id, p_plan_id,
            p_setup_flag, x_setup_guid);

CALL_GRANTS(EVENT, 'QA_RESULTS_ENTER_USER', p_grantee_id, p_plan_id,
            p_enter_flag, x_enter_guid);

CALL_GRANTS(EVENT, 'QA_RESULTS_VIEW_USER', p_grantee_id, p_plan_id,
            p_view_flag, x_view_guid);

CALL_GRANTS(EVENT, 'QA_RESULTS_UPDATE_USER', p_grantee_id, p_plan_id,
            p_update_flag, x_update_guid);

CALL_GRANTS(EVENT, 'QA_RESULTS_DELETE_USER', p_grantee_id, p_plan_id,
            p_delete_flag, x_delete_guid);

End Create_Grant;

-----------------------------------------------------------------------
PROCEDURE security_predicate(p1_function      in  varchar2,
                             p1_object_name   in  varchar2,
                             p1_user_name     in  varchar2,
                             x1_predicate     out NOCOPY varchar2,
                             x1_return_status out NOCOPY varchar2) IS
-----------------------------------------------------------------------
begin
--test_mesg1('Inside security predicate');

    -- Bug 4465241
    -- ATG Mandatory Fix: Deprecated API
    -- removing p_user_name
    -- saugupta Mon, 27 Jun 2005 06:03:12 -0700 PDT
    fnd_data_security.get_security_predicate(
       p_api_version => 1.0,
       p_function => p1_function,
       p_object_name => p1_object_name,
       x_predicate => x1_predicate,
       x_return_status => x1_return_status);

    -- Bug 2691739. get_security_predicate() returns a status 'F'
    -- along with a predicate '1=2', if no grants exists. This should
    -- not be treated as a error condition.
    -- This change in the FND API was made in AFSCDSCB.pls version 115.53
    -- abd corrected in 115.69. See the bug for more info. - kabalakr.

    IF (x1_return_status IN ('E','U','L')) THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

--test_mesg1('return_status: '|| v_return_status);
end;


-----------------------------------------------------------------------
Function child_security( p_function_name  IN VARCHAR2,
                         p_user           IN VARCHAR2,
                         x_child_plan_ids IN OUT NOCOPY VARCHAR2,
                         p_parent_plan_id IN NUMBER,
			 p_check_immediate IN BOOLEAN)
RETURN VARCHAR2 IS
-----------------------------------------------------------------------

   -- Added this function for Bug 2329413.
   -- This function can return three values.
   -- 'F' - If security not enabled OR If User have Full access to all IMMEADIATE
   --       child plans.
   -- 'P' - If User have partial access to IMMEADIATE child plans.
   -- 'N' - If user have No access to any of the IMMEADIATE child plans
   -- kabalakr 30 APR 2002.

   -- Bug 2379185. Changed the signature of the function
   -- p_check_immediate is true only in eqr->eqr case.
   -- For this  make a check for immediate plans
   -- If the user does not have access to any/some of
   -- immediate plans then child eqr form should not be opened only in eqr->eqr scanario.

   -- All the applicable child plan ids are passed in through x_child_plan_id
   -- Example x_child_plan_id will have 101,102,103,104. Out of which if
   -- child_plan_id 102 does not have security permission, then
   -- x_child_plan_id will have 101,103,104 when the function returns.
   -- rponnusa Thu May 16 19:25:20 PDT 2002

 -- Cursor to find whether the child plan is of type IMMEADIATE or not.

 CURSOR C_IMM(l_child_plan_id NUMBER) IS
  SELECT child_plan_id,data_entry_mode
  FROM qa_pc_plan_relationship
  WHERE parent_plan_id = p_parent_plan_id
  AND child_plan_id = l_child_plan_id;

 l_child_id_array       ChildPlanArray;
 l_child_plan_id 	NUMBER;
 l_partial 	 	NUMBER := 1;
 l_full 	 	NUMBER := 0;
 l_plan_id       	NUMBER;
 l_result 		VARCHAR2(10);

 -- Unable to call parse_list, hence ported the code for the same.

 value VARCHAR2(2000);
 c VARCHAR2(10);
 separator CONSTANT VARCHAR2(1) := ',';
 arr_index INTEGER := 1;
 p INTEGER := 1;
 n INTEGER;

 -- Bug 2379185. Variables declared
 sec_child_plan_ids VARCHAR2(10000) := null;   -- this will hold the child plan_ids
                                               -- which the user has access to
 l_append BOOLEAN := FALSE;
 l_data_entry_mode NUMBER;

BEGIN

   -- Unable to call parse_list, hence ported the code for the same.

   n := length(x_child_plan_ids);

   WHILE p <= n LOOP
     c := substr(x_child_plan_ids, p, 1);
     p := p + 1;
     IF (c = separator) THEN
         l_child_id_array(arr_index) := value;
         arr_index := arr_index + 1;
         value := '';
     ELSE
         value := value || c;
     END IF;

   END LOOP;

   l_child_id_array(arr_index) := value;

   FOR i IN 1..l_child_id_array.COUNT LOOP
      l_child_plan_id := l_child_id_array(i);

      OPEN C_IMM(l_child_plan_id);
      FETCH C_IMM INTO l_plan_id,l_data_entry_mode;

        -- Find whether the user have access to the child plan.
        -- Bug 4465241
        -- ATG Mandatory Fix: Deprecated API
        -- removing p_user_name
        -- saugupta Mon, 27 Jun 2005 06:04:34 -0700 PDT
        l_result := fnd_data_security.check_function(
			p_api_version => 1.0,
			p_function => p_function_name,
			p_object_name => 'QA_PLANS',
			p_instance_pk1_value => l_child_plan_id);
			-- p_user_name => p_user);

        IF (l_result = 'F') THEN
          -- User does not have acess. Set l_full flag and l_partial flag.
          IF(p_check_immediate AND l_data_entry_mode = 1) THEN

            l_full := l_full + 1;
            IF (l_partial = 1) THEN
              l_partial := 2;
            END IF;
          END IF;
       ELSE
	  -- Bug 2379185. We are here since child plan has access rights.
          -- Formulate string which contains only security priviliaged child plans
          IF(l_append) THEN
             sec_child_plan_ids := sec_child_plan_ids || separator;
          END IF;
          l_append := TRUE;
          sec_child_plan_ids := sec_child_plan_ids || l_child_plan_id;

      END IF; -- l_result
      CLOSE C_IMM;
   END LOOP;

   -- Bug 2379185. now we build child plans which are applicable for the
   -- current record and user has enough priviliage.

   x_child_plan_ids := sec_child_plan_ids;

   IF p_check_immediate THEN
     IF (l_full = l_child_id_array.COUNT) THEN
       RETURN 'N' ;
     ELSIF (l_partial = 2) THEN
       RETURN 'P' ;
     ELSIF ((l_full = 0) AND (l_partial = 1)) THEN
       RETURN 'F' ;
     END IF;
   ELSE
     -- Bug 2379185. Always return 'F' if this function is not called by eqr->eqr case.
     return 'F';
   END IF;


END child_security;


---------------------------------------------------------------
PROCEDURE Delete_Relationship(p_relationship_id in number) IS
---------------------------------------------------------------

begin
	--Put No Op
	NULL;

/*
     HZ_RELATIONSHIPS_PKG.Delete_Row(
			x_relationship_id => p_relationship_id);
*/

end Delete_Relationship;

---------------------------------------------------------------
PROCEDURE  Update_Person(p_fname            in varchar2,
                          p_lname           in varchar2,
                          p_party_id        in number,
                          p_date            in date,
                          x1_msg_data       out NOCOPY varchar2,
                          x1_return_status  out NOCOPY varchar2) IS
---------------------------------------------------------------
    --
    -- R12 ER 2648803.  Rewritten to use TCA V2 APIs.
    -- Parameter p_date is no longer used in V2.
    --
    -- bso Thu Jul 14 13:55:27 PDT 2005
    --
     v_object_version number;
     v_person 	      hz_party_v2pub.person_rec_type;
     v_profile_id     number;
     v_msg_count      number;

begin

    v_person.person_last_name := p_lname;
    v_person.person_first_name := p_fname;
    v_person.party_rec.party_id := p_party_id;

    SELECT object_version_number INTO v_object_version
    FROM   hz_parties
    WHERE  party_id = p_party_id;

    hz_party_v2pub.update_person (
        p_person_rec  => v_person,
        p_party_object_version_number => v_object_version,
        x_profile_id => v_profile_id,
        x_return_status => x1_return_status,
        x_msg_count => v_msg_count,
        x_msg_data => x1_msg_data);

end Update_Person;

---------------------------------------------------------------
PROCEDURE  Update_Group(p_group_name       in varchar2,
                         p_party_id        in number,
                         p_date            in date,
                         x1_msg_data       out NOCOPY varchar2,
                         x1_return_status  out NOCOPY varchar2) IS
---------------------------------------------------------------
    --
    -- R12 ER 2648803.  Rewritten to use TCA V2 APIs.
    -- Parameter p_date is no longer used in V2.
    --
    -- bso Thu Jul 14 13:55:27 PDT 2005
    --
     v_object_version number;
     v_grp hz_party_v2pub.group_rec_type;
     v_msg_count      number;

begin

    v_grp.group_name := p_group_name;
    v_grp.group_type := c_app_name;
    v_grp.party_rec.party_id := p_party_id;

    SELECT object_version_number INTO v_object_version
    FROM   hz_parties
    WHERE  party_id = p_party_id;

     hz_party_v2pub.update_group (
        p_group_rec => v_grp,
        p_party_object_version_number => v_object_version,
        x_return_status => x1_return_status,
        x_msg_count => v_msg_count,
        x_msg_data => x1_msg_data);

end Update_Group;

-----------------------------------------------------------------------
PROCEDURE    Create_Group(p_group_name     in  varchar2,
                          x1_msg_data      out NOCOPY varchar2,
                          x1_return_status out NOCOPY varchar2,
                          x1_party_id      out NOCOPY number) IS
-----------------------------------------------------------------------
    --
    -- R12 ER 2648803.  Rewritten to use TCA V2 APIs.
    -- bso Thu Jul 14 13:55:27 PDT 2005
    --
    v_grp hz_party_v2pub.group_rec_type;
    v_msg_count NUMBER;
    v_party_number HZ_PARTIES.PARTY_NUMBER%TYPE;

begin

    v_grp.group_name := p_group_name;
    v_grp.group_type := c_app_name;
    v_grp.created_by_module := c_module_name;

    hz_party_v2pub.create_group(
        p_group_rec => v_grp,
        x_return_status => x1_return_status,
        x_msg_count => v_msg_count,
        x_msg_data => x1_msg_data,
        x_party_id => x1_party_id,
        x_party_number => v_party_number);

end Create_Group;

---------------------------------------------------------------
PROCEDURE  Create_Person( p_fname          in  varchar2,
                          p_lname          in  varchar2,
                          x1_msg_data      out NOCOPY varchar2,
                          x1_return_status out NOCOPY varchar2,
                          x1_party_id      out NOCOPY number) IS
---------------------------------------------------------------
    --
    -- R12 ER 2648803.  Rewritten to use TCA V2 APIs.
    -- bso Thu Jul 14 13:55:27 PDT 2005
    --
    v_person hz_party_v2pub.person_rec_type;
    v_msg_count NUMBER;
    v_party_number HZ_PARTIES.PARTY_NUMBER%TYPE;
    v_profile_id NUMBER;
begin

    v_person.created_by_module := c_module_name;
    v_person.person_first_name := p_fname;
    v_person.person_last_name  := p_lname;

    hz_party_v2pub.create_person(
        p_person_rec => v_person,
        x_return_status => x1_return_status,
        x_msg_count => v_msg_count,
        x_msg_data => x1_msg_data,
        x_party_id => x1_party_id,
        x_party_number => v_party_number,
        x_profile_id => v_profile_id);

end Create_Person;

-----------------------------------------------------------------------
PROCEDURE Create_Relationship(  p_subject_id       in number,
                                p_object_id        in number,
                                x1_msg_data        out NOCOPY varchar2,
                                x1_return_status   out NOCOPY varchar2,
                                x1_party_id        out NOCOPY number,
                                x1_relationship_id out NOCOPY number) IS
-----------------------------------------------------------------------
    -- R12 ER 2648803/4614568.  Rewritten to use TCA V2 APIs.
    -- bso Fri Sep 16 13:33:01 PDT 2005
    v_rel hz_relationship_v2pub.relationship_rec_type;
    v_msg_count NUMBER;
    v_party_number HZ_PARTIES.PARTY_NUMBER%TYPE;
    v_profile_id NUMBER;
begin

    v_rel.subject_id := P_SUBJECT_ID;
    v_rel.subject_type := 'PERSON';
    v_rel.subject_table_name := 'HZ_PARTIES';
    v_rel.object_id := P_OBJECT_ID;
    v_rel.object_type := 'GROUP';
    v_rel.object_table_name := 'HZ_PARTIES';
    v_rel.relationship_code := 'MEMBER_OF';
    v_rel.relationship_type := 'MEMBERSHIP';
    v_rel.start_date := sysdate;
    v_rel.created_by_module := c_module_name;

    hz_relationship_v2pub.create_relationship(
        p_relationship_rec => v_rel,
        x_return_status => x1_return_status,
        x_msg_count => v_msg_count,
        x_msg_data => x1_msg_data,
        x_relationship_id => x1_relationship_id,
        x_party_id => x1_party_id,
        x_party_number => v_party_number);

end Create_Relationship;

-----------------------------------------------------------------------
PROCEDURE Update_Relationship(  p_relationship_id       in number,
				p_subject_id            in number,
				p_object_id		in number,
				p_party_id		in number,
				p_status		in varchar2,
				p_rel_date		in date,  -- Unused in V2
				p_party_date		in date,  -- Unused in V2
        			x1_return_status 	out NOCOPY varchar2,
        			x1_msg_data 		out NOCOPY varchar2) IS
-----------------------------------------------------------------------
    -- R12 ER 2648803/4614568.  Rewritten to use TCA V2 APIs.
    -- bso Fri Sep 16 13:37:14 PDT 2005
     l_rel_rec      		hz_relationship_v2pub.relationship_rec_type;
     return_status  		varchar2(10);
     x1_msg_count      		number;
     l_object_ver               number;
     l_dummy_party_object_ver   number;

begin
        l_rel_rec.RELATIONSHIP_ID := p_relationship_id;
        l_rel_rec.SUBJECT_ID := p_subject_id;
        l_rel_rec.OBJECT_ID := p_object_id;
        l_rel_rec.party_rec.PARTY_ID := p_party_id;
        l_rel_rec.STATUS := p_status;

     -- R12 ER 2648803/4614568.  Rewritten to use TCA V2 APIs.
     -- which don't use these variables any more.
     --
     --    l_rel_last_update_date := p_rel_date;
     --    l_party_last_update_date := p_party_date;

     -- Bug 4646910 Obsoleted hz_party_relationships
     -- Use qa_hz_party_relationships_v instead.
     -- bso Tue Oct  4 16:39:51 PDT 2005
     SELECT object_version_number
     INTO   l_object_ver
     FROM   qa_hz_party_relationships_v
     WHERE  party_relationship_id = p_relationship_id;

     --
     -- Bug 4057596
     -- Selecting the object version number
     -- from HZ_Parties table. It is used by
     -- the TCA procedure to detect locking issues
     -- ntungare Wed Aug  2 00:29:49 PDT 2006
     --
     SELECT object_version_number
     INTO l_dummy_party_object_ver
     FROM hz_parties
     WHERE party_id = p_party_id;

     hz_relationship_v2pub.update_relationship (
         p_relationship_rec => l_rel_rec,
         p_object_version_number => l_object_ver,
         p_party_object_version_number => l_dummy_party_object_ver,
         x_return_status => x1_return_status,
         x_msg_count => x1_msg_count,
         x_msg_data => x1_msg_data);

end Update_Relationship;


-- anagarwa Tue Aug  3 12:26:09 PDT 2004
-- bug 3695361: Slow performance when security is on
-- Following procedure takes in used id and returns user name
FUNCTION get_user_name (p_user_id in number)
    RETURN VARCHAR2 IS

  --
  -- Bug 4330282.  SSO change.  All customer_id references
  -- changed to person_party_id
  --
    l_user_name VARCHAR2(30);
    l_person_party_id NUMBER;

    CURSOR c (l_user_id NUMBER) IS
        SELECT NVL(person_party_id, -1)
        FROM fnd_user
        WHERE user_id = p_user_id;

BEGIN

   OPEN c(p_user_id);
   FETCH c INTO l_person_party_id;
   CLOSE c;

   l_user_name := 'HZ_PARTY:'||l_person_party_id;

   RETURN l_user_name;

END get_user_name;


-- anagarwa Tue Aug  3 12:26:09 PDT 2004
-- bug 3695361: Slow performance when security is on
-- Following procedure takes in used id instead of user name and
-- finds user name and then calls original security_predicate

PROCEDURE ssqr_security_predicate(p2_function      in  varchar2,
                             p2_object_name   in  varchar2,
                             p2_user_id     in  number,
                             x2_predicate     out NOCOPY varchar2,
                             x2_return_status out NOCOPY varchar2) IS
BEGIN

security_predicate (p1_function => p2_function,
                    p1_object_name => p2_object_name,
                    p1_user_name => get_user_name(p2_user_id),
                    x1_predicate => x2_predicate,
                    x1_return_status => x2_return_status);

END;



END QA_SECURITY_PKG;

/
