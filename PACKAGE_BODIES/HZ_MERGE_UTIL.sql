--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_UTIL" AS
/* $Header: ARHMUTLB.pls 120.17 2006/02/13 10:06:46 rarajend noship $ */

PROCEDURE insert_party_site_details (
	p_from_party_id	IN	NUMBER,
	p_to_party_id	IN	NUMBER,
	p_batch_party_id IN	NUMBER,
        p_CREATED_BY    NUMBER,
        p_CREATION_DATE    DATE,
        p_LAST_UPDATE_LOGIN    NUMBER,
        p_LAST_UPDATE_DATE    DATE,
        p_LAST_UPDATED_BY    NUMBER) IS

  CURSOR c_from_ps_loc IS
    SELECT party_site_id, location_id FROM HZ_PARTY_SITES
    WHERE party_id = p_from_party_id
    AND nvl(status, 'A') = 'A'
    AND actual_content_source <> 'DNB';

  CURSOR c_dup_to_ps(cp_loc_id NUMBER) IS
    SELECT party_site_id FROM HZ_PARTY_SITES
    WHERE party_id = p_to_party_id
    AND location_id = cp_loc_id
    AND nvl(status, 'A') = 'A';

l_ps_id NUMBER;
l_loc_id NUMBER;
l_dup_ps_id NUMBER;
l_sqerr VARCHAR2(2000);
BEGIN

  OPEN c_from_ps_loc;
  LOOP
    FETCH c_from_ps_loc INTO l_ps_id, l_loc_id;
    EXIT WHEN c_from_ps_loc%NOTFOUND;
    IF p_from_party_id <> p_to_party_id THEN
      OPEN c_dup_to_ps(l_loc_id);
      FETCH c_dup_to_ps INTO l_dup_ps_id;
      IF c_dup_to_ps%FOUND THEN
       HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
          p_batch_party_id,
  	  'HZ_PARTY_SITES',
	  l_ps_id,
	  l_dup_ps_id,
          'Y',
	  p_created_by,
	  p_creation_Date,
	  p_last_update_login,
	  p_last_update_date,
	  p_last_updated_by);
      ELSE
       HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
          p_batch_party_id,
          'HZ_PARTY_SITES',
          l_ps_id,
          l_ps_id,
          'N',
          p_created_by,
          p_creation_Date,
          p_last_update_login,
          p_last_update_date,
          p_last_updated_by);
      END IF;
      CLOSE c_dup_to_ps;
    END IF;
  END LOOP;
  CLOSE c_from_ps_loc;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR','HZ_FORM_DUP_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
    APP_EXCEPTION.RAISE_EXCEPTION;
END insert_party_site_details;

PROCEDURE insert_party_reln_details (
	p_from_party_id	IN	NUMBER,
	p_to_party_id	IN	NUMBER,
	p_batch_party_id IN	NUMBER,
        p_CREATED_BY    IN NUMBER,
        p_CREATION_DATE   IN  DATE,
        p_LAST_UPDATE_LOGIN IN    NUMBER,
        p_LAST_UPDATE_DATE  IN   DATE,
        p_LAST_UPDATED_BY  IN   NUMBER
) IS

   CURSOR c_from_reln(l_batch_id NUMBER) IS
    SELECT relationship_id, subject_id, object_id,
           relationship_code, actual_content_source, start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))
    FROM HZ_RELATIONSHIPS r
    WHERE (subject_id = p_from_party_id
           OR object_id = p_from_party_id)
    AND nvl(status, 'A') IN ('A','I')
    AND directional_flag = 'F'
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND actual_content_source <> 'DNB';

  CURSOR c_dup_sub_reln(
      cp_party_rel_code VARCHAR2, cp_obj_id NUMBER,
      cp_subj_id NUMBER, from_start_date date, from_end_date date,p_self_rel varchar2) --Bug No: 4609894
    IS
    SELECT relationship_id, start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))
    FROM HZ_RELATIONSHIPS
    WHERE ( (subject_id = cp_subj_id AND object_id = cp_obj_id)
            OR (p_self_rel ='Y' and ( (subject_id = cp_subj_id AND object_id = cp_subj_id)  -- (in case of P1-Supplier-P1 ,P2-Supplier-P2 and Merge P1 into P2)
	                              OR (object_id = cp_subj_id AND subject_id = cp_obj_id) -- (in case of P1-Supplier-P1(Forward) , P2-Customer-P1(Forward) and Merge P1 into P2)
				      OR (subject_id = cp_subj_id AND object_id = p_from_party_id ) -- (in case of P1-Supplier-P2 ,P2-Supplier-P1 and Merge P1 into P2)
				    )
	       ) --Bug No: 4609894
          )
    AND relationship_code = cp_party_rel_code
    --OR exists (select 1 from hz_relationship_types where relationship_type = cp_party_relationship_type
                 --and forward_code=backward_code))
    AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
    AND nvl(status, 'A') IN ('A','I')
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND actual_content_source <> 'DNB';

   --bug 4867151 start
    CURSOR c_self_reln(rel_id NUMBER, bat_id NUMBER, to_id NUMBER) IS
        select 'Y' from hz_relationships where relationship_id=rel_id
    and (subject_id IN (p_from_party_id,p_to_party_id))
    and (object_id IN (p_from_party_id,p_to_party_id))
    AND directional_flag='F';
   --bug 4867151 end


  /* Commented out for BugNo:2940087 */
  /*CURSOR c_dup_ob_reln(cp_party_relationship_type VARCHAR2, cp_subj_id NUMBER) IS
    SELECT relationship_id
    FROM HZ_RELATIONSHIPS
    WHERE object_id = p_to_party_id
    AND subject_id = cp_subj_id
    AND relationship_code = cp_party_relationship_type
    AND directional_flag = 'F'
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND nvl(status, 'A') = 'A';
  */

l_pr_id NUMBER;
l_dup_pr_id NUMBER;
l_dup_start_date HZ_RELATIONSHIPS.start_date%TYPE;
l_dup_end_date HZ_RELATIONSHIPS.end_date%TYPE;

l_subj_id NUMBER;
l_obj_id NUMBER;
l_reltype HZ_RELATIONSHIPS.relationship_code%TYPE;
l_relcode HZ_RELATIONSHIPS.relationship_code%TYPE;
l_contype HZ_RELATIONSHIPS.actual_content_source%TYPE;
l_start_date HZ_RELATIONSHIPS.start_date%TYPE;
l_end_date HZ_RELATIONSHIPS.end_date%TYPE;

l_batch_id NUMBER;
l_batch_party_id NUMBER;
l_mandatory_merge VARCHAR2(1);
l_self_rel varchar2(1); --Bug No: 4609894
l_temp_flag varchar2(1);--bug 4867151

BEGIN

  IF p_from_party_id <> p_to_party_id THEN
    SELECT batch_id INTO l_batch_id
    FROM HZ_MERGE_PARTIES
    WHERE batch_party_id = p_batch_party_id;

    OPEN c_from_reln(l_batch_id);
    LOOP
      l_dup_pr_id := -1;

      FETCH c_from_reln INTO l_pr_id, l_subj_id, l_obj_id, l_relcode,
            l_contype, l_start_date, l_end_date;
      EXIT WHEN c_from_reln%NOTFOUND;

    IF l_contype <> 'DNB' THEN
        l_self_rel := 'N'; --Bug No: 4609894
        --if the from party is the subject in reln.
        IF l_subj_id=p_from_party_id THEN
          --Start of Bug No: 4609894
	   if(l_subj_id = l_obj_id OR l_obj_id = p_to_party_id) then
	     l_self_rel := 'Y';
	   end if;
	  --End of Bug No: 4609894
          OPEN c_dup_sub_reln(l_relcode, l_obj_id, p_to_party_id, l_start_date, l_end_date,l_self_rel); --Bug No: 4609894
           FETCH c_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
           IF c_dup_sub_reln%NOTFOUND THEN
            l_dup_pr_id := -1;
          END IF;
          CLOSE c_dup_sub_reln;

        ELSIF l_obj_id=p_from_party_id THEN
	    -- Always pass 'N' for p_self as the l_subj_id and p_from_party_id will be same for self relationships.
          OPEN c_dup_sub_reln(l_relcode, p_to_party_id, l_subj_id, l_start_date, l_end_date,'N'); --Bug No: 4609894
           FETCH c_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
           IF c_dup_sub_reln%NOTFOUND THEN
           --Transfer
            l_dup_pr_id := -1;
           END IF;
          CLOSE c_dup_sub_reln;

        END IF;
    END IF;
     --bug 4867151 start
      l_temp_flag := 'N';
      OPEN c_self_reln(l_pr_id, l_batch_id, p_to_party_id);
      FETCH c_self_reln INTO l_temp_flag;
      CLOSE c_self_reln;
     --bug 4867151 end

    IF l_temp_flag<>'Y' THEN --bug 4867151

      IF l_dup_pr_id <> -1 THEN
        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
           p_batch_party_id,
     	   'HZ_PARTY_RELATIONSHIPS',
   	   l_pr_id,
	   l_dup_pr_id,
           'Y',
	   p_created_by,
	   p_creation_Date,
	   p_last_update_login,
	   p_last_update_date,
	   p_last_updated_by);
      ELSE
        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
           p_batch_party_id,
           'HZ_PARTY_RELATIONSHIPS',
           l_pr_id,
           l_pr_id,
           'N',
           p_created_by,
           p_creation_Date,
           p_last_update_login,
           p_last_update_date,
           p_last_updated_by);
      END IF;
    END IF;--l_temp_flag-- bug 4867151
    END LOOP;
    CLOSE c_from_reln;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   --APP_EXCEPTION.RAISE_EXCEPTION;
   RAISE;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR','HZ_FORM_DUP_PROC_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
    APP_EXCEPTION.RAISE_EXCEPTION;
END insert_party_reln_details;

FUNCTION get_party_site_description(
	p_party_site_id	IN	NUMBER)
RETURN VARCHAR2 IS

CURSOR c_get_desc IS
  SELECT nvl(ps.party_site_name, ps.party_site_number)  || '(Address: ' ||
         l.address1 || ',' ||l.address2||','||l.address3||','||l.address4||','|| l.city ||
         ',' || l.county || ','|| l.state || ', ' || l.province || ','||l.postal_code || ',' || l.country||')'
  FROM HZ_PARTY_SITES ps, HZ_LOCATIONS l
  WHERE ps.party_site_id = p_party_site_id
  AND ps.location_id = l.location_id;

l_ps_address VARCHAR2(2000);

BEGIN

  OPEN c_get_desc;
  FETCH c_get_desc INTO l_ps_address;
  IF c_get_desc%NOTFOUND THEN
    CLOSE c_get_desc;
    l_ps_address := to_char(p_party_site_id);
  END IF;
  CLOSE c_get_desc;

  RETURN l_ps_address;

EXCEPTION
  WHEN OTHERS THEN
    RETURN to_char(p_party_site_id);
END get_party_site_description;

FUNCTION get_party_reln_description(
	p_party_reln_id	IN	NUMBER)
RETURN VARCHAR2 IS

CURSOR c_get_desc IS
  SELECT '"'||p1.party_name || '"->"' || p2.party_name||'"'
  FROM HZ_RELATIONSHIPS pr, HZ_PARTIES p1, --4500011
       HZ_PARTIES p2
  WHERE p1.party_id = pr.object_id
  AND p2.party_id = pr.subject_id
  AND pr.relationship_id = p_party_reln_id
  AND pr.subject_table_name = 'HZ_PARTIES'
  AND pr.object_table_name = 'HZ_PARTIES'
  AND pr.directional_flag = 'F';

l_pr_desc VARCHAR2(2000);

BEGIN

  OPEN c_get_desc;
  FETCH c_get_desc INTO l_pr_desc;
  IF c_get_desc%NOTFOUND THEN
    CLOSE c_get_desc;
    l_pr_desc := to_char(p_party_reln_id);
  END IF;
  CLOSE c_get_desc;

  RETURN l_pr_desc;

EXCEPTION
  WHEN OTHERS THEN
    RETURN to_char(p_party_reln_id);
END get_party_reln_description;

FUNCTION get_org_contact_description(
	p_org_contact_id	IN	NUMBER)
RETURN VARCHAR2 IS

CURSOR c_get_desc IS
  SELECT p1.party_name
  FROM HZ_RELATIONSHIPS pr, HZ_ORG_CONTACTS oc,  --4500011
       HZ_PARTIES p1
  WHERE p1.party_id = pr.subject_id
  AND oc.party_relationship_id = pr.relationship_id
  AND oc.org_contact_id = p_org_contact_id
  AND pr.subject_table_name = 'HZ_PARTIES'
  AND pr.object_table_name = 'HZ_PARTIES'
  AND pr.directional_flag = 'F';

l_oc_desc VARCHAR2(2000);

BEGIN

  OPEN c_get_desc;
  FETCH c_get_desc INTO l_oc_desc;
  IF c_get_desc%NOTFOUND THEN
    CLOSE c_get_desc;
    l_oc_desc := to_char(p_org_contact_id);
  END IF;
  CLOSE c_get_desc;

  RETURN l_oc_desc;

EXCEPTION
  WHEN OTHERS THEN
    RETURN to_char(p_org_contact_id);
END get_org_contact_description;

FUNCTION get_org_contact_id(
        p_party_relationship_id  IN NUMBER)
RETURN NUMBER IS

  CURSOR org_cont IS
    SELECT org_contact_id
    FROM hz_org_contacts
    WHERE party_relationship_id = p_party_relationship_id;

  l_org_cont_id NUMBER;

BEGIN
  OPEN org_cont;
  FETCH org_cont INTO l_org_cont_id;
  IF org_cont%FOUND THEN
    CLOSE org_cont;
    RETURN l_org_cont_id;
  ELSE
    CLOSE org_cont;
    RETURN NULL;
  END IF;
END;

FUNCTION get_reln_party_id(
        p_party_relationship_id  IN NUMBER)
RETURN NUMBER IS

  CURSOR reln_party IS
    SELECT party_id
    FROM hz_relationships   --4500011
    WHERE relationship_id = p_party_relationship_id
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND directional_flag = 'F';

  l_party_id NUMBER;

BEGIN
  OPEN reln_party;
  FETCH reln_party INTO l_party_id;
  IF reln_party%FOUND THEN
    CLOSE reln_party;
    RETURN l_party_id;
  ELSE
    CLOSE reln_party;
    RETURN NULL;
  END IF;
END;
END HZ_MERGE_UTIL;

/
