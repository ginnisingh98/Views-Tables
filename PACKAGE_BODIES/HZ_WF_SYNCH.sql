--------------------------------------------------------
--  DDL for Package Body HZ_WF_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WF_SYNCH" AS
/* $Header: ARHWFSNB.pls 120.15.12010000.2 2009/06/22 09:35:12 rgokavar ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |              propogate_user_role 					     |
 |									     |
 | DESCRIPTION								     |
 |              Propogates user information to WF API's			     |
 |									     |
 | SCOPE - Public							     |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED				     |
 |              NONE							     |
 |									     |
 | ARGUMENTS  : IN:							     |
 |               p_subscription_guid      in raw,			     |
 |									     |
 |              OUT:							     |
 |									     |
 |          IN/ OUT:							     |
 |               p_event                  in out NOCOPY wf_event_t 	     |
 |									     |
 |									     |
 |									     |
 | RETURNS    : VARCHAR2						     |
 |									     |
 | NOTES								     |
 |              The create or update relationship should call    	     |
 |              SynchGroupWFUserRole procedure, which in turn synchs the     |
 |              work flow tables.                                            |
 |									     |
 | MODIFICATION HISTORY							     |
 |									     |
 |   03-Jan-2003      Porkodi Chinnandar     Bug 2627161: Modified the code  |
 |					     to populate proper values before|
 |					     calling WFSYNCH procedures      |
 |									     |
 +===========================================================================*/

FUNCTION propagate_user_role(
                       p_subscription_guid      IN RAW,
                       p_event                  IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2
IS
  l_key                   VARCHAR2(240) := p_event.GetEventKey();
  l_user_orig_system      VARCHAR2(100) := 'HZ_PARTY';
  l_user_orig_system_id   NUMBER;
  l_role_orig_system      VARCHAR2(100) := 'HZ_PARTY';
  l_role_orig_system_id   NUMBER;
  l_start_date            DATE DEFAULT NULL;
  l_expiration_date       DATE DEFAULT NULL;
  l_relationship_id       NUMBER;
  l_match_string          VARCHAR2(240) := NULL;
  id                      NUMBER;
  l_debug_prefix	    VARCHAR2(30) := '';
BEGIN
  SAVEPOINT propagate_user_role;

  -- Check if API is called in debug mode. If yes, enable debug.
  --enable_debug;

  --Checks for the event and synchs data with the workflow table
  --by calling propagate_user_role
  IF (l_key like 'oracle.apps.ar.hz.Relationship.create%')  OR
     (l_key like 'oracle.apps.ar.hz.Relationship.update%') THEN
    id := p_event.getValueForParameter('RELATIONSHIP_ID');
    SynchGroupWFUserRole(id);
	 -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After calling the propagate_user_role for the relationship_id '||id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
  END IF; -- chk for Relationship Create or Update Events
  RETURN 'SUCCESS';
 EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     WF_CORE.CONTEXT('HZ_WF_SYNCH',
          'propagate_user_role',
          p_event.getEventName(),
          p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
    ROLLBACK TO propagate_user_role;
    RETURN 'ERROR';
END; -- propagate_user_role()


/*===========================================================================+
 | PROCEDURE								     |
 |              propogate_role						     |
 |									     |
 | DESCRIPTION								     |
 |              Propogates user information to WF API's			     |
 |									     |
 | SCOPE - Public							     |
 |									     |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED				     |
 |		WF_LOCAL_SYNCH						     |
 |									     |
 | ARGUMENTS  : IN:							     |
 |             p_subscription_guid      in raw,				     |
 |									     |
 |              OUT:							     |
 |									     |
 |          IN/ OUT:							     |
 |             p_event                  in out NOCOPY wf_event_t |	     |
 |									     |
 |									     |
 |									     |
 | RETURNS    : NONE							     |
 |									     |
 | NOTES								     |
 |              The create or update of Person/PersonLanguage/OrgContact/    |
 |              Group/ContactPoint events should call any of the             |
 |              SynchPersonWFRole/SynchContactWFRole/SynchGroupWFRole or all |
 |              of them to synch with workflow tables.            	     |
 |									     |
 | MODIFICATION HISTORY							     |
 |									     |
 |   03-Jan-2003      Porkodi Chinnandar     Bug 2627161: Modified the code  |
 |					     to populate proper values before|
 |					     calling WFSYNCH procedures      |
 |									     |
 +===========================================================================*/

FUNCTION propagate_role(
   p_subscription_guid      IN RAW,
   p_event                  IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2
IS
  l_key              		VARCHAR2(240) := p_event.GetEventKey();
  l_orig_system      		VARCHAR2(100) := 'HZ_PARTY';
  l_orig_system_id   		NUMBER;
  l_attributes       		wf_parameter_list_t;
  l_start_date       		DATE DEFAULT NULL;
  l_expiration_date  		DATE DEFAULT NULL;
  l_match_string     		VARCHAR2(240) := null;
  l_primary_lang_indicator 	VARCHAR2(10) := 'N';
  l_temp_party_id    		NUMBER;
  wf_party_id        		NUMBER;
  wf_lang_user_ref_id 	NUMBER;
  wf_party_type               VARCHAR2(30);
  wf_party_relationship_id    NUMBER;
  wf_owner_table_id           NUMBER;
  l_debug_prefix		    VARCHAR2(30) := '';

  Cursor find_contacts is
  select party_id
  from   hz_relationships rel,
           hz_org_contacts org
  where  rel.relationship_id=org.party_relationship_id and
   Subject_table_name = 'HZ_PARTIES' and
   Object_table_name  = 'HZ_PARTIES' and
   Directional_flag = 'F' and
   subject_id = wf_party_id;

 	Cursor org_update is
     select party_id
     from   hz_relationships rel,
            hz_org_contacts org
     where  rel.relationship_id=org.party_relationship_id and
            Subject_table_name = 'HZ_PARTIES' and
            Object_table_name  = 'HZ_PARTIES' and
            Directional_flag = 'F' and
            object_id = l_match_string;

BEGIN
  SAVEPOINT propagate_role;

  -- Check if API is called in debug mode. If yes, enable debug.
  --enable_debug;

  IF (l_key LIKE 'oracle.apps.ar.hz.Person.create%')   THEN

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

    wf_party_id := p_event.getValueForParameter('PARTY_ID');
    SynchPersonWFRole(wf_party_id);

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

  ELSIF (l_key LIKE 'oracle.apps.ar.hz.Person.update%')   THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

    wf_party_id := p_event.getValueForParameter('PARTY_ID');
    SynchPersonWFRole(wf_party_id,TRUE,TRUE);

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

   --While updating the person details, his details in contact should
   --also be updated in workflow tables
     For Contact in find_contacts  Loop
        SynchContactWFRole(Contact.party_id,TRUE,TRUE);
     End Loop;

     -- Debug info.
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		 hz_utility_v2pub.debug(
          p_message=>'After updating the contact details in WF for subject partyid: '||wf_party_id,
          p_prefix =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
	    END IF;

  ELSIF (l_key LIKE 'oracle.apps.ar.hz.PersonLanguage.create%')    THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

    wf_lang_user_ref_id := p_event.getValueForParameter('LANGUAGE_USE_REFERENCE_ID');

    -- anonymous block to find the person corresponding to language
    BEGIN
     select p.party_id,  party_type
     into   wf_party_id, wf_party_type
     from   hz_parties p, hz_person_language l
     where  p.party_id= l.party_id and
            primary_language_indicator='Y' and
            l.status ='A' and
            language_use_reference_id = wf_lang_user_ref_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      		hz_utility_v2pub.debug(
            p_message=>'No person found for language_use_reference_id: '||wf_lang_user_ref_id,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
      		hz_utility_v2pub.debug(
            p_message=>'No person party_id found for event '||l_key,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
        END IF;
    END; -- end of anonymous block to find the person corresponding to language

    --For personLanguage create event it tries to synch all the
    --personLanguage related details in workflow table
    IF (wf_party_type = 'PERSON') THEN
      -- sync person
      SynchPersonWFRole(wf_party_id);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    		hz_utility_v2pub.debug(
          p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
    			p_prefix =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
      END IF;

      -- sync all the contacts
      For Contact in find_contacts
      Loop
         SynchContactWFRole(Contact.party_id);
      End Loop;
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After updating the contact details in WF for subject partyid: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;

    ELSIF (wf_party_type = 'GROUP') THEN
    -- sync group
      SynchGroupWFRole(wf_party_id);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    		hz_utility_v2pub.debug(
          p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
    			p_prefix =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    --For personLanguage update event it tries to synch all the
    --personLanguage related details in workflow table

  ELSIF (l_key LIKE 'oracle.apps.ar.hz.PersonLanguage.update%') THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    -- read the lang ref id from param
    wf_lang_user_ref_id := p_event.getValueForParameter('LANGUAGE_USE_REFERENCE_ID');
    -- anonymous block to find the person corresponding to language
    BEGIN
    select p.party_id,   party_type
    into   wf_party_id,  wf_party_type
    from   hz_parties p, hz_person_language l
    where  p.party_id= l.party_id and
--    primary_language_indicator='Y' and
--    l.status ='A' and
    language_use_reference_id = wf_lang_user_ref_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      		hz_utility_v2pub.debug(
            p_message=>'No person found for language_use_reference_id: '||wf_lang_user_ref_id,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
      		hz_utility_v2pub.debug(
            p_message=>'No person party_id found for event '||l_key,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
        END IF;
    END; -- end of anonymous block to find the person corresponding to language

    IF (wf_party_type = 'PERSON') THEN
      -- sync person
      SynchPersonWFRole(wf_party_id,TRUE,TRUE);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
        p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
      -- sync all the contacts
      For Contact in find_contacts  Loop
        SynchContactWFRole(Contact.party_id,TRUE,TRUE);
      End Loop;
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After updating the contact details in WF for subject partyid: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSIF (wf_party_type = 'GROUP') THEN
    -- sync group
       SynchGroupWFRole(wf_party_id,TRUE,TRUE);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    		hz_utility_v2pub.debug(
          p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
    			p_prefix =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF; -- check for party type ends in personLang.update event

  --On creation of OrgContact this code synchs this details with
  --work flow table
  ELSIF (l_key LIKE 'oracle.apps.ar.hz.OrgContact.create%')   THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    l_match_string := p_event.getValueForParameter('ORG_CONTACT_ID');

    -- given an orgContactId, get the relParty (Contact) that must be synced
    -- anonymous block to find the orgContact
    BEGIN
      select party_id
      into   wf_party_id
      from hz_org_contacts org, hz_relationships rel
      where org.party_relationship_id=rel.relationship_id and
      Subject_table_name = 'HZ_PARTIES' and
      Object_table_name  = 'HZ_PARTIES' and
      Directional_flag = 'F' and
      org.org_contact_id=l_match_string;

      SynchContactWFRole(wf_party_id);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After updating the contact details in WF for partyid: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      		hz_utility_v2pub.debug(
            p_message=>'No orgContact found for orgContactId: '||l_match_string,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
      		hz_utility_v2pub.debug(
            p_message=>'No rel party_id found for event '||l_key,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
        END IF;
    END; -- end of anonymous block to find the orgContact

    --On updation of OrgContact this code synchs this details with
    --work flow table
    ELSIF (l_key like 'oracle.apps.ar.hz.OrgContact.update%')  THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    		hz_utility_v2pub.debug(
          p_message=>l_key,
    			p_prefix =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
      END IF;
     l_match_string := p_event.getValueForParameter('ORG_CONTACT_ID');
    -- given an orgContactId, get the relParty (Contact) that must be synced
    -- anonymous block to find the orgContact
    BEGIN
      select party_id
      into   wf_party_id
      from hz_org_contacts org, hz_relationships rel
      where org.party_relationship_id=rel.relationship_id and
      Subject_table_name = 'HZ_PARTIES' and
      Object_table_name  = 'HZ_PARTIES' and
      Directional_flag = 'F' and
      org.org_contact_id=l_match_string;
      -- sync contact
      SynchContactWFRole(wf_party_id,TRUE,TRUE);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After updating the contact details in WF for partyid: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      		hz_utility_v2pub.debug(
            p_message=>'No orgContact found for orgContactId: '||l_match_string,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
      		hz_utility_v2pub.debug(
            p_message=>'No rel party_id found for event '||l_key,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
        END IF;
    END; -- end of anonymous block to find the orgContact

  --On creation of Group party this code synchs this details with
  --work flow table
  ELSIF (l_key LIKE 'oracle.apps.ar.hz.Group.create%')  THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    l_match_string := p_event.getValueForParameter('PARTY_ID');
    SynchGroupWFRole(l_match_string);
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>'After SynchGroupWFRole() for party_id: '||l_match_string,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
  --On updation of Group party this code synchs this details with
  --work flow table
  ELSIF (l_key like 'oracle.apps.ar.hz.Group.update%')  THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    l_match_string := p_event.getValueForParameter('PARTY_ID');
    SynchGroupWFRole(l_match_string,TRUE,TRUE);
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>'After SynchGroupWFRole() for party_id: '||l_match_string,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
  --On creation of ContactPoint this code synchs this details with
  --work flow table
  ELSIF (l_key LIKE 'oracle.apps.ar.hz.ContactPoint.create%')  THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    l_match_string := p_event.getValueForParameter('CONTACT_POINT_ID');
    -- anonymous block to find the party corresponding to CP
    BEGIN
      select owner_table_id, party_type
      into   wf_party_id, wf_party_type
      from   hz_contact_points pt, hz_parties
      where  pt.owner_table_id = party_id and
      pt.contact_point_type = 'EMAIL' and
      pt.status ='A' and
      pt.primary_flag='Y' and
      pt.owner_table_name ='HZ_PARTIES' and
      pt.contact_point_id = l_match_string;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      		hz_utility_v2pub.debug(
            p_message=>'No party_id found for contact point id: '||l_match_string,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
      		hz_utility_v2pub.debug(
            p_message=>'No party_id found for event '||l_key,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
        END IF;
    END; -- end of anonymous block to find the party corresponding to CP

    IF (wf_party_type = 'PERSON') THEN
      -- sync person
      SynchPersonWFRole(wf_party_id);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
        p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSIF (wf_party_type = 'PARTY_RELATIONSHIP') then
      -- sync Contact
      SynchContactWFRole(wf_party_id);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After updating the contact details in WF for subject partyid: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSIF (wf_party_type = 'GROUP')  THEN
      -- sync Group
      SynchGroupWFRole(wf_party_id);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After SynchGroupWFRole() for party_id: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF; -- check of partyType ends

  --On updation of ContactPoint this code synchs this details with
  --work flow table
  ELSIF (l_key like 'oracle.apps.ar.hz.ContactPoint.update%')  THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    l_match_string := p_event.getValueForParameter('CONTACT_POINT_ID');
    -- anonymous block to find the party corresponding to CP
    BEGIN
      select owner_table_id, party_type
      into   wf_party_id,  wf_party_type
      from   hz_contact_points pt,  hz_parties
      where  pt.owner_table_id = party_id and
      pt.contact_point_type = 'EMAIL' and
      pt.owner_table_name ='HZ_PARTIES' and
      pt.contact_point_id = l_match_string;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      		hz_utility_v2pub.debug(
            p_message=>'No party_id found for contact point id: '||l_match_string,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
      		hz_utility_v2pub.debug(
            p_message=>'No party_id found for event '||l_key,
      			p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
        END IF;
    END; -- end of anonymous block to find the party corresponding to CP

    IF (wf_party_type = 'PERSON') THEN
      -- sync person
      SynchPersonWFRole(wf_party_id,TRUE,TRUE);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
        p_message=>'After calling the SynchPersonWFRole for party '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSIF (wf_party_type = 'PARTY_RELATIONSHIP') then
      -- sync Contact
	    SynchContactWFRole(wf_party_id,TRUE,TRUE);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After updating the contact details in WF for subject partyid: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSIF (wf_party_type = 'GROUP')  THEN
      -- sync Group
      SynchGroupWFRole(wf_party_id,TRUE,TRUE);
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_message=>'After SynchGroupWFRole() for party_id: '||wf_party_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF; -- check of partyType ends

  --On updation of Organization this code synchs this details with
  --work flow table
  ELSIF (l_key like 'oracle.apps.ar.hz.Organization.update%') THEN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
  		hz_utility_v2pub.debug(
        p_message=>l_key,
  			p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;
    l_match_string := p_event.getValueForParameter('PARTY_ID');
    -- sync all orgContacts for the Org
    For orga_update in org_update  Loop
      SynchContactWFRole(orga_update.party_id,TRUE,TRUE);
    End Loop;
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'After updating the Contact details in WF for Org party_id: '||l_match_string,
    p_prefix =>l_debug_prefix,
    p_msg_level=>fnd_log.level_statement);
    END IF;

  END IF; -- end of event key check

  RETURN 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      WF_CORE.CONTEXT('HZ_WF_SYNCH',
              'propagate_user_role',
              p_event.getEventName(),
              p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
    ROLLBACK TO propagate_role;
    RETURN 'ERROR';
END; -- end of propagate_role()

-------------------------------------------------------------------------
/**
 * PROCEDURE SynchPersonWFRole
 *
 * DESCRIPTION
 *     This is a wrapper to call the WF_LOCAL_SYNCH.propagate_role method
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     WF_LOCAL_SYNCH.propagate_role
 *
 * ARGUMENTS
 *   IN:
 *     PartyId                       party_id for which the synch has
 *				     to be done
 *     p_update                      Update flag
 *     p_overwrite                   Overwrite flag
 *
 *   IN/OUT:
 *
 *   OUT:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-Jan-2003    Porkodi Chinnandar  o Created.
 *   13-Mar-2003    Leena Sampemane     o Person needs to be created as a
 *                                                     wf_user.
 *   07-JUN-2005  Srikanth o fixed bug4390816 for release 12
 *
 */
-------------------------------------------------------------------------

PROCEDURE SYNCHPERSONWFROLE (
  PartyId         IN Number,
  p_update 	IN Boolean Default False ,
  p_overwrite 	IN Boolean Default False )
IS
  List               wf_parameter_list_t;
  user_name	         VARCHAR2(25);
  display_name       VARCHAR2(360);
  description        VARCHAR2(360);
  notification_pref  VARCHAR2(30);
  language           VARCHAR2(30);
  territory          VARCHAR2(30);
  email_address      VARCHAR2(325);
  fax                VARCHAR2(80);
  status             VARCHAR2(8);
  expiration_date    DATE;
  start_date         DATE DEFAULT NULL;
  system             VARCHAR2(10) := 'HZ_PARTY';
  system_id          VARCHAR2(15);
  l_debug_prefix     VARCHAR2(30) := 'SYNCPERWFROLE';

BEGIN
  -- debug info
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.DEBUG
     (p_message=>'SYNCHPERSONWFROLE()+',
      p_prefix =>l_debug_prefix,
      p_msg_level=>fnd_log.level_statement);
  END IF;
  SAVEPOINT SynchPersonWFRole;
/*
As part of Bug 4390816, following changes were done to this procedure:
Select stmt changes:
1. email_format is no longer hardcoded to MAILTEXT when null
2. email format is truncated to 8 char
3. email address is truncated to 320 char

BUG 4957312 changes
1. email_format a.k.a Notification Preference defaulting was re-inroduced.

Details-
If the email is present and has a notification preference, then it was used.
If the notification preference was not present and the email was present,
 then MAILTEXT is deafulted. This is to be consistent with email defaulting
 in Public API Bug4359226.
If the email itself was not available, notification preference was defaulted
to Query.
*/

  BEGIN -- anonymous block to select the records from TCA Registry
    SELECT
      'HZ_PARTY:'||p.party_id,          --  Username
      p.party_name,	-- DisplayName
      p.party_name,	-- description
      nvl2(p.email_address, nvl(substrb(cp.email_format,1,8),'MAILTEXT'),'QUERY'),     -- notification_pref
      fl.nls_language,	-- preferredLanguage
      fl.nls_territory,	-- orclNLSTerritory
      substrb(p.email_address,1,320),	  -- mail
      NULL,	-- fax
      decode(p.status, 'A',  'ACTIVE', 'INACTIVE'),  -- orclIsEnabled
      NULL,	-- ExpirationDate
      p.party_id   -- System Id
    INTO
      user_name,
      display_name,
      description,
      notification_pref,
      language,
      territory,
      email_address,
      fax,
      status,
      expiration_date,
      system_id
    FROM
      HZ_PARTIES p,
      HZ_CONTACT_POINTS cp,
      HZ_PERSON_LANGUAGE pl,
      FND_LANGUAGES fl
    WHERE
      p.party_id = PartyId
      AND p.party_type = 'PERSON'
      AND cp.owner_table_name(+) = 'HZ_PARTIES'
      AND cp.owner_table_id (+) = p.party_id
      AND cp.contact_point_type(+) = 'EMAIL'
      AND cp.primary_flag(+) = 'Y'
      AND cp.status(+) = 'A'
      AND pl.party_id (+) = p.party_id
      AND pl.primary_language_indicator(+) = 'Y'
      AND pl.status(+) = 'A'
      AND pl.language_name = fl.language_code(+);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     -- Debug info.
     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'no data found to sync',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
     END IF;
   END; -- anonymous block to fetch the TCA Registry records ends

   IF (system_id IS NOT NULL) THEN
    -- if there is a valid record from TCA Registry to Sync
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.DEBUG
       (p_message=>'Orig system ID:'||system_id,
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

       -- Add the  TCA registry Data as parameters to wf_event
       -- This is needed as the WF API access the wf_event structure for
       -- the information passed.

    wf_event.AddParameterToList('User_Name', user_name, List);
    wf_event.AddParameterToList('DisplayName', display_name, List);
    wf_event.AddParameterToList('Description', description, List);
    wf_event.AddParameterToList('orclWorkFlowNotificationPref', notification_pref, List);
    wf_event.AddParameterToList('preferredLanguage', language, List);
    wf_event.AddParameterToList('OrclNLSTerritory', territory, List);
    wf_event.AddParameterToList('Mail', email_address, List);
    wf_event.AddParameterToList('FacsimileTelephoneNumber', fax, List);
    wf_event.AddParameterToList('orclisEnabled', status, List);
    wf_event.AddParameterToList('ExpirationDate', expiration_date, List);
    wf_event.AddParameterToList('orclWFOrigSystem',system, List);
    wf_event.AddParameterToList('orclWFOrigSystemID',system_id, List);

    if (p_update = TRUE) then
	wf_event.AddParameterToList('UpdateOnly', 'TRUE' , List);
    end if;

    if (p_overwrite = TRUE) then
       wf_event.AddParameterToList('WFSYNCH_OVERWRITE', 'TRUE', List);
    end if;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.DEBUG
	(p_message=>'bfr Calling WF_LOCAL_SYNCH.propagate_role API',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
    END IF;

       -- call WF API for Synchronization
    WF_LOCAL_SYNCH.propagate_user(
       system,
       system_id,
       List,
       start_date,
       expiration_date);
  END IF; -- check for valid TCA id ends

  -- debug info
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.DEBUG
     (p_message=>'SYNCHPERSONWFROLE()-',
     p_prefix =>l_debug_prefix,
     p_msg_level=>fnd_log.level_statement);
  END IF;

END SYNCHPERSONWFROLE;
-------------------------------------------------------------------------
/**
 * PROCEDURE SynchContactWFRole
 *
 * DESCRIPTION
 *     This is a wrapper to call the WF_LOCAL_SYNCH.propagate_role method
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     WF_LOCAL_SYNCH.propagate_role
 *
 * ARGUMENTS
 *   IN:
 *     PartyId                       party_id for which the synch has
 *				     to be done
 *     p_update                      Update flag
 *     p_overwrite                   overwrite flag
 *
 *   IN/OUT:
 *
 *   OUT:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-Jan-2003    Porkodi Chinnandar   o Created.
 *   11-Mar-2003    Leena Sampemane   - Contact needs to be created as a WF  User
 *   07-JUN-2005  Srikanth o fixed bug4390816 for release 12
 *
 *
 */
-------------------------------------------------------------------------
PROCEDURE SYNCHCONTACTWFROLE (
  PartyId         IN Number,
  p_update 	IN Boolean Default False ,
  p_overwrite 	IN Boolean Default False )
IS
  List         WF_PARAMETER_LIST_T;
  system       VARCHAR2(10) := 'HZ_PARTY';
  l_tbl        SYNC_TBL_TYPE;
  l_rec_count  NUMBER := 0;
  l_debug_prefix VARCHAR2(30) := 'SYNCCNTWFROLE';

/*
As part of Bug 4390816, following changes were done to this procedure:

Select stmt changes:
1. Email_format is no longer hardcoded to MAILTEXT when null
2. Email format is truncated to 8 char
3. Email address is truncated to 320 char
4. StartDate, ExpirationDate are populated from relationship table
5. Unnecessary joining for 'object' to hz_parties removed
6. Removed directional flag filtering. This would mean that there
   are relationship records that must sync up (unlike the previous
   design). Hence need to re-write the SQL as a cursor.

Param changes:
1, Added wf_event.AddParameterToList('StartDate', start_date, List);

BUG 4957312 changes
1. email_format a.k.a Notification Preference defaulting was re-inroduced.

Details-
If the email is present and has a notification preference, then it was used.
If the notification preference was not present and the email was present,
 then MAILTEXT is deafulted. This is to be consistent with email defaulting
 in Public API Bug4359226.
If the email itself was not available, notification preference was defaulted
to Query.

2. Notification Preference selected must belong to the Email chosen.
In case of email of a contact, the notification preference must belong
to the same email (of that contact).

3. Incase of person to person rel, directional flag was re-intorduced.

Details-
This was to avoid selecting two rows in case of Person-Person relationships.

4. Person-Group relationships are no longer considered in SyncContactWFRole().
*/

  CURSOR c_rel (c_p_rel_party_id IN NUMBER) IS
  SELECT
   'HZ_PARTY:'||to_char(pr.party_id) -- Username
    ,per.party_name -- DisplayName
    ,prp.party_name -- description
    ,nvl2(prp.email_address, nvl(substrb(cp.email_format,1,8),'MAILTEXT'),'QUERY') -- notification_pref
    ,fl.nls_language                   -- language
    ,fl.nls_territory                  -- territory
    ,substrb(prp.email_address,1,320)  -- email_address
    ,NULL -- fax
    ,DECODE(prp.status,'A','ACTIVE','INACTIVE') -- status
    ,pr.start_date        -- startDate
    ,DECODE(pr.status, 'A', pr.end_date,  'I',
     (CASE
       WHEN MONTHS_BETWEEN(NVL(pr.end_date, SYSDATE), SYSDATE) < 0 THEN pr.end_date
       WHEN MONTHS_BETWEEN(NVL(pr.end_date, SYSDATE), SYSDATE) > 0 THEN SYSDATE
       ELSE SYSDATE
     END),  SYSDATE) -- ExpirationDate --Bug#5209709 fix
    ,pr.party_id  -- system_id
  FROM
	hz_relationships pr
	,hz_org_contacts oc
	,hz_parties prp -- party relationship party
	,hz_parties per
	,hz_contact_points cp
	,hz_person_language pl
	,fnd_languages fl
  WHERE
    pr.party_id = c_p_rel_party_id
    AND pr.subject_table_name = 'HZ_PARTIES'
    AND pr.object_table_name  = 'HZ_PARTIES'
    AND pr.subject_id = per.party_id
    AND per.party_type = 'PERSON'
    AND ((pr.object_type = 'PERSON' AND pr.directional_flag = 'F')
	OR pr.object_type = 'ORGANIZATION')
    AND pr.relationship_id = oc.party_relationship_id
    AND prp.party_id = pr.party_id
    AND prp.party_type = 'PARTY_RELATIONSHIP'
    AND cp.owner_table_name(+) = 'HZ_PARTIES'
    AND cp.owner_table_id (+) = prp.party_id
    AND cp.contact_point_type(+) = 'EMAIL'
    AND cp.email_address(+) = prp.email_address
    AND cp.primary_flag(+) = 'Y'
    AND cp.status(+) = 'A'
    AND per.party_id = pl.party_id(+)
    AND pl.primary_language_indicator(+) = 'Y'
    AND pl.status(+) = 'A'
    AND pl.language_name = fl.language_code(+);

BEGIN
  SAVEPOINT SynchContactWFRole;
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.DEBUG
	(p_message=>'SynchContactWFRole()+',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
    END IF;

  OPEN c_rel(PartyId);
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.DEBUG
     (p_message=>'OPENED THE CURSOR',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
  END IF;
  FETCH c_rel  BULK COLLECT INTO l_tbl; -- select records from TCA Registry
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.DEBUG
     (p_message=>'Bulk collected the data',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
  END IF;
  CLOSE c_rel;

  l_rec_count := l_tbl.COUNT;
--Bug#8587352
--When there are no records l_tbl.FIRST and l_tbl.LAST
--returns NULL value and its raising an error message.
--OTHERS is added at Exception block.
IF l_rec_count > 0 THEN
  FOR i IN l_tbl.FIRST..l_tbl.LAST
  LOOP
    -- for each of the selected record from TCA Registry
    -- perform WF Synchronization.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'At '||i||' Rec',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
    END IF;

    IF (l_tbl(i).system_id IS NOT NULL) THEN
       -- for each of the valid record with a partyId

       List  := WF_PARAMETER_LIST_T();
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	  hz_utility_v2pub.DEBUG
	  (p_message=>'Orig system ID: '||l_tbl(i).system_id,
	   p_prefix =>l_debug_prefix,
	   p_msg_level=>fnd_log.level_statement);
       END IF;

       -- Add the  TCA registry Data as parameters to wf_event
       -- This is needed as the WF API access the wf_event structure for
       -- the information passed.

       wf_event.AddParameterToList('User_Name', l_tbl(i).user_name, List);
       wf_event.AddParameterToList('DisplayName', l_tbl(i).display_name, List);
       wf_event.AddParameterToList('Description', l_tbl(i).description, List);
       wf_event.AddParameterToList('orclWorkFlowNotificationPref', l_tbl(i).notification_pref, List);
       wf_event.AddParameterToList('preferredLanguage', l_tbl(i).language, List);
       wf_event.AddParameterToList('OrclNLSTerritory', l_tbl(i).territory, List);
       wf_event.AddParameterToList('Mail', l_tbl(i).email_address, List);
       wf_event.AddParameterToList('FacsimileTelephoneNumber', l_tbl(i).fax, List);
       wf_event.AddParameterToList('orclisEnabled', l_tbl(i).status, List);
       wf_event.AddParameterToList('StartDate', l_tbl(i).start_date, List);
       wf_event.AddParameterToList('ExpirationDate', l_tbl(i).expiration_date, List);
       wf_event.AddParameterToList('orclWFOrigSystem',system, List);
       wf_event.AddParameterToList('orclWFOrigSystemID',l_tbl(i).system_id, List);

       IF (p_update = TRUE) then
	   wf_event.AddParameterToList('UpdateOnly', 'TRUE', List);
       END IF;

       IF (p_overwrite = TRUE) THEN
           wf_event.AddParameterToList('WFSYNCH_OVERWRITE', 'TRUE', List);
       END IF;

       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'Before WF API Call',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
       END IF;

       -- call WF API for Synchronization

       WF_LOCAL_SYNCH.propagate_user(
          system,
          l_tbl(i).system_id,
          List,
          l_tbl(i).start_date,
          l_tbl(i).expiration_date);
     END IF; -- check for valid TCA id ends
   END LOOP; -- looping through all selected record ends
ELSE
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.DEBUG
       (p_message=>'No record found at c_rel cursor. ',
       p_prefix =>l_debug_prefix,
       p_msg_level=>fnd_log.level_statement);
    END IF;

END IF; -- For l_rec_count check.
   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.DEBUG
      (p_message=>'SynchContactWFRole()-',
      p_prefix =>l_debug_prefix,
      p_msg_level=>fnd_log.level_statement);
   END IF;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'No data found excep:'||sqlerrm,
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
     END IF;
     -- no error is raised as not finding any record to sync is not an error.
 WHEN OTHERS THEN
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.DEBUG
         (p_message=>'Error raised :'||sqlerrm,
         p_prefix =>l_debug_prefix,
         p_msg_level=>fnd_log.level_statement);
      END IF;
END SynchContactWFRole;

-------------------------------------------------------------------------
/**
 * PROCEDURE SynchGroupWFRole
 *
 * DESCRIPTION
 *     This is a wrapper to call the WF_LOCAL_SYNCH.propagate_role method
 *     When the party type is group.
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     WF_LOCAL_SYNCH.propagate_role
 *
 * ARGUMENTS
 *   IN:
 *     PartyId                       party_id for which the synch has
 *				     to be done
 *     p_update                      Update flag
 *     p_overwrite                   Overwrite flag
 *
 *   IN/OUT:
 *
 *   OUT:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-Jan-2003    Porkodi Chinnandar               o Created.
 *   07-JUN-2005  Srikanth o fixed bug4390816 for release 12
 *
 */

-------------------------------------------------------------------------
PROCEDURE SYNCHGROUPWFROLE (
	PartyId         IN Number,
	p_update 	IN Boolean Default False ,
	p_overwrite 	IN Boolean Default False )

IS
	List               wf_parameter_list_t;
	user_name	   varchar2(25);
	display_name       varchar2(360);
	description        varchar2(360);
	notification_pref  varchar2(30);
	language           varchar2(30);
	territory          varchar2(30);
	email_address      varchar2(325);
	fax                varchar2(80);
	status             varchar2(8);
	expiration_date    Date;
	start_date         Date DEFAULT NULL;
	system             varchar2(10) := 'HZ_GROUP';
	system_id          varchar2(15);
	l_debug_prefix VARCHAR2(30) := 'SYNCGRWFROLE';

BEGIN
  SAVEPOINT SynchGroupWFRole;
  -- Debug info.
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.DEBUG
	(p_message=>'SynchGroupWFRole()+',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
  END IF;

  -- As part of Bug 4390816, following changes were done to this procedure:
  -- select stmt changes
     -- 1. email_format is no longer hardcoded to MAILTEXT when null
     -- 2. email format is truncated to 8 char
     -- 3. email address is truncated to 320 char
     -- 4. mission statement is truncated to 1000 chars

  BEGIN -- anonymous block to select the TCA Registry
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'Bfr Selecting the data',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
    END IF;
/*
BUG 4957312 changes
1. email_format a.k.a Notification Preference defaulting was re-inroduced.

Details-
If the email is present and has a notification preference, then it was used.
If the notification preference was not present and the email was present,
 then MAILTEXT is deafulted. This is to be consistent with email defaulting
 in Public API Bug4359226.
If the email itself was not available, notification preference was defaulted
to Query.

2. Notification Preference selected must belong to the Email chosen.
In case of email of a contact, the notification preference must belong
to the same email (of that contact).
*/
     SELECT
       'HZ_GROUP:'||p.party_id, --  USER_NAME,  note the :
       p.party_name, -- DisplayName
       substrb(p.mission_statement,1,1000),   -- DESCRIPTION
       nvl2(p.email_address, nvl(substrb(cp.email_format,1,8),'MAILTEXT'),'QUERY'),     -- notification_pref
       fl.nls_language,	-- Language
       fl.nls_territory, -- Territory
       substrb(p.email_address,1,320),	-- email mail
       NULL,	-- fax
       decode(p.status, 'A',  'ACTIVE', 'INACTIVE'),  -- status
       NULL,	-- ExpirationDate
       p.party_id -- System Id
     INTO
	user_name,
	display_name,
	description,
	notification_pref,
	language,
	territory,
	email_address,
	fax,
	status,
	expiration_date,
	system_id
      FROM
	HZ_PARTIES p,
	HZ_CONTACT_POINTS cp,
	HZ_PERSON_LANGUAGE pl,
	FND_LANGUAGES fl
      WHERE
	p.party_id = PartyId
	AND p.party_type = 'GROUP'
	AND cp.owner_table_name(+) = 'HZ_PARTIES'
	AND cp.owner_table_id (+) = p.party_id
	AND cp.contact_point_type(+) = 'EMAIL'
	AND cp.primary_flag(+) = 'Y'
	AND cp.status(+) = 'A'
	AND pl.party_id (+) = p.party_id
	AND pl.primary_language_indicator(+) = 'Y'
	AND pl.status(+) = 'A'
	AND pl.language_name = fl.language_code(+);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     -- Debug info.
     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'no data found to sync',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
     END IF;
     -- no error is raised as not finding any record to sync is not an error.
   END; -- anonymous block to query the TCA Registry ends

   IF (system_id IS NOT NULL) THEN

     -- if there any record to be synchonized with WF
     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'Orig system ID:'||system_id,
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
     END IF;

     -- Add the  TCA registry Data as parameters to wf_event
     -- This is needed as the WF API access the wf_event structure for
     -- the information passed.

     wf_event.AddParameterToList('User_Name', user_name, List);
     wf_event.AddParameterToList('DisplayName', display_name, List);
     wf_event.AddParameterToList('Description', description, List);
     wf_event.AddParameterToList('orclWorkFlowNotificationPref', notification_pref, List);
     wf_event.AddParameterToList('preferredLanguage', language, List);
     wf_event.AddParameterToList('OrclNLSTerritory', territory, List);
     wf_event.AddParameterToList('Mail', email_address, List);
     wf_event.AddParameterToList('FacsimileTelephoneNumber', fax, List);
     wf_event.AddParameterToList('orclisEnabled', status, List);
     wf_event.AddParameterToList('ExpirationDate', expiration_date, List);
     wf_event.AddParameterToList('orclWFOrigSystem',system, List);
     wf_event.AddParameterToList('orclWFOrigSystemID',system_id, List);

     IF (p_update = TRUE) then
	wf_event.AddParameterToList('UpdateOnly', 'TRUE', List);
     END IF;

     IF (p_overwrite = TRUE) then
	wf_event.AddParameterToList('WFSYNCH_OVERWRITE', 'TRUE', List);
     END IF;

     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'bfr Calling WF_LOCAL_SYNCH.propagate_role API',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
     END IF;

     -- calling the WF API to propagate role
     WF_LOCAL_SYNCH.propagate_role(
	system,
	system_id,
	List,
	start_date,
	expiration_date);
    END IF; -- if there is any TCA Registry record to sync, check ends

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.DEBUG
	(p_message=>'SynchGroupWFRole()-',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
    END IF;
END SYNCHGROUPWFROLE;

-------------------------------------------------------------------------
/**
 * PROCEDURE SynchGroupWFUserRole
 *
 * DESCRIPTION
 *     This is a wrapper to call the WF_LOCAL_SYNCH.propagate_user_role method
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     WF_LOCAL_SYNCH.propagate_user_role
 *
 * ARGUMENTS
 *   IN:
 *     PartyId                       party_id for which the synch has
 *				     to be done
 *
 *   IN/OUT:
 *
 *   OUT:
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-Jan-2003    Porkodi Chinnandar               o Created.
 *   07-JUN-2005  Srikanth o fixed bug4390816 for release 12
 *
 */
-------------------------------------------------------------------------

PROCEDURE SYNCHGROUPWFUSERROLE (RelationshipId  IN NUMBER )
IS
    expiration_date    Date DEFAULT NULL;
    start_date         Date DEFAULT NULL;
    user_system        varchar2(10);
    user_system_id     Number;
    role_system        varchar2(10);
    role_system_id     Number;
    l_debug_prefix VARCHAR2(30) := 'SYNCGRPWFUR';

BEGIN
  -- debug info
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.DEBUG
	(p_message=>'SYNCHGROUPWFUSERROLE()+',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
  END IF;

  SAVEPOINT SynchGroupWFUserRole;
  -- changes done because of Bug#4390816 is
  -- removed the filtering based on directional flag from the select stmt

  BEGIN
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.DEBUG
	(p_message=>'Bfr Selecting the data',
	p_prefix =>l_debug_prefix,
	p_msg_level=>fnd_log.level_statement);
    END IF;

    SELECT
      'HZ_PARTY'       --    USER_ORIG_SYSTEM
      ,sp.party_id     --    USER_ORIG_SYSTEM_ID
      ,'HZ_GROUP'      --    ROLE_ORIG_SYSTEM
      ,op.party_id     --    ROLE_ORIG_SYSTEM_ID
      ,pr.start_date   --    START_DATE
    ,DECODE(pr.status, 'A', pr.end_date,  'I',
     (CASE
       WHEN MONTHS_BETWEEN(NVL(pr.end_date, SYSDATE), SYSDATE) < 0 THEN pr.end_date
       WHEN MONTHS_BETWEEN(NVL(pr.end_date, SYSDATE), SYSDATE) > 0 THEN SYSDATE
       ELSE SYSDATE
     END),  SYSDATE) -- EndDate --Bug#5209709 fix
    INTO
       user_system,
       user_system_id,
       role_system,
       role_system_id,
       start_date,
       expiration_date
     FROM
       hz_relationships pr
       ,hz_parties sp
       ,hz_parties op
     WHERE
       pr.relationship_id = RelationshipId
       and    pr.subject_table_name = 'HZ_PARTIES'
       and    pr.object_table_name  = 'HZ_PARTIES'
       and    sp.party_id = pr.subject_id
       and    sp.party_type = 'PERSON'
       and    op.party_id = pr.object_id
       and    op.party_type = 'GROUP';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	-- Debug info.
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.DEBUG
	    (p_message=>'no data found to sync',
	     p_prefix =>l_debug_prefix,
	     p_msg_level=>fnd_log.level_statement);
	END IF;
        -- no error is raised as not finding any record to sync is not an error.
        -- return the control to the caller as no action is necessary.
        RETURN;
     END; -- anonymous block for selecting the person-group relationships end

     BEGIN
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	  hz_utility_v2pub.DEBUG
	   (p_message=>'User Sys:'||user_system||' USER sysID:'||user_system_id,
	        p_prefix =>l_debug_prefix,
		p_msg_level=>fnd_log.level_statement);
       END IF;
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	  hz_utility_v2pub.DEBUG
	   (p_message=>'Role Sys:'||role_system||' Role sysID:'||role_system_id,
	    p_prefix =>l_debug_prefix,
	    p_msg_level=>fnd_log.level_statement);
       END IF;

       WF_LOCAL_SYNCH.propagate_user_role(
	     user_system,
	     user_system_id,
	     role_system,
	     role_system_id,
	     start_date,
	     expiration_date);

      EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.DEBUG
		(p_message=>'No data found to propagate_user_role',
		p_prefix =>l_debug_prefix,
		p_msg_level=>fnd_log.level_statement);
	     END IF;
	    -- as there is no data to sync as user role, first sync person and
	     -- then group. After syncing person and group as roles, then sync
	     -- person-Group as user role.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	       hz_utility_v2pub.DEBUG
	       (p_message=>'Bfr SynchPersonWFRole to propagate per:'||user_system_id,
	        p_prefix =>l_debug_prefix,
		p_msg_level=>fnd_log.level_statement);
	    END IF;

	    SynchPersonWFRole(user_system_id);

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.DEBUG
		(p_message=>'Bfr SynchGroupWFRole to propagate grp:'||role_system_id,
		p_prefix =>l_debug_prefix,
		p_msg_level=>fnd_log.level_statement);
	    END IF;

	    SynchGroupWFRole(role_system_id);

	    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	       hz_utility_v2pub.DEBUG
	       (p_message=>'Bfr WF_LOCAL_SYNCH.propagate_user_role()',
		p_prefix =>l_debug_prefix,
		p_msg_level=>fnd_log.level_statement);
	    END IF;

	    WF_LOCAL_SYNCH.propagate_user_role(
		user_system,
		user_system_id,
		role_system,
		role_system_id,
		start_date,
		expiration_date);
      END; -- anonymous block to propagate the wf tables end.
	-- debug info
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.DEBUG
		(p_message=>'SYNCHGROUPWFUSERROLE()-',
		p_prefix =>l_debug_prefix,
		p_msg_level=>fnd_log.level_statement);
	END IF;
END SYNCHGROUPWFUSERROLE;
-------------------------------------------------------------------------
-------------------------------------------------------------------------
END HZ_WF_SYNCH;

/
