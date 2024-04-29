--------------------------------------------------------
--  DDL for Package Body FUN_TCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TCA_PKG" AS
/* $Header: FUNSTCAB.pls 120.17.12010000.2 2008/08/06 07:43:30 makansal ship $*/


 /* This Procedure returns the potential duplicates for the party_name that is
* passed. This is wrapper to call the TCA DQM API */

PROCEDURE find_party(p_party_name IN VARCHAR2   , p_party_type IN VARCHAR2    , p_dqm_context OUT NOCOPY NUMBER   , p_dqm_count OUT NOCOPY NUMBER)
IS
p_party_search_rec_type 	hz_party_search.party_search_rec_type;
p_party_site_list 		hz_party_search.party_site_list;
p_contact_list 			hz_party_search.contact_list;
p_contact_point_list 		hz_party_search.contact_point_list;
p_x_search_ctx_id    		NUMBER;
p_x_num_matches     		NUMBER;
p_x_return_status      		VARCHAR2(4000);
p_x_msg_count         		NUMBER;
p_x_msg_data        		VARCHAR2(10000);
	p_x_rule_id 		NUMBER;
	p_p_restrict_sql        VARCHAR2(100);
	p_p_match_type 		VARCHAR2(10);
	p_p_search_merged       VARCHAR2(10);
BEGIN
-- Added the select statement for bug 3169934
select match_rule_id into p_x_rule_id from hz_match_rules_vl where rule_name='IC_PARTY_SEARCH';
p_party_search_rec_type.PARTY_NAME := p_party_name;
p_party_search_rec_type.PARTY_TYPE := P_PARTY_TYPE;
p_p_restrict_sql          :=  null;
p_p_search_merged         := 'Y';
p_p_match_type		  := 'AND';
hz_party_search.find_parties(
      p_init_msg_list         => FND_API.G_TRUE,
      x_rule_id               => p_x_rule_id,
      p_party_search_rec      => p_party_search_rec_type,
      p_party_site_list       => p_party_site_list,
      p_contact_list          => p_contact_list,
      p_contact_point_list    => p_contact_point_list,
      p_restrict_sql          => p_p_restrict_sql,
      p_search_merged         => p_p_search_merged,
      x_search_ctx_id         => p_x_search_ctx_id,
      x_num_matches           => p_x_num_matches,
      x_return_status         => p_x_return_status,
      x_msg_count             => p_x_msg_count,
      x_msg_data              => p_x_msg_data
	);
p_dqm_context := p_x_search_ctx_id;
p_dqm_count := p_x_num_matches;
EXCEPTION
	WHEN OTHERS THEN
   raise_application_error(-20001, SQLERRM);
END find_party;



/* This function returns the Legal Entity Id associated with the
* party that is passed. This Legal Entity should have a valid
* "Intercompany Legal Entity" relationship with the party thats is passed*/

FUNCTION get_le_id (p_party_id IN NUMBER   , p_as_date IN DATE ) RETURN NUMBER is
l_count_le NUMBER ;
l_le_id NUMBER;
BEGIN
 SELECT count(1)
 INTO l_count_le
 FROM  xle_firstparty_information_v FAL
 WHERE  FAL.party_id = p_party_id;
 IF(l_count_le>0) THEN
     RETURN p_party_id;
 ELSE
         -- hzr has time component in start and end dates
	 SELECT   hzr.object_id
	     INTO    l_le_id
	     FROM    hz_relationships hzr
	     WHERE   HZR.subject_id=p_party_id
		     AND     hzr.subject_table_name='HZ_PARTIES'
		     AND     hzr.object_table_name='HZ_PARTIES'
		     AND     hzr.relationship_code='INTERCOMPANY_ORGANIZATION_OF'
		     AND     hzr.relationship_type='INTERCOMPANY_LEGAL_ENTITY'
		     AND     hzr.directional_flag='F'
		     AND     hzr.status='A'
		     AND     TRUNC(start_date) <= nvl(p_as_date  ,sysdate)
		     AND     (TRUNC(end_date) >= nvl(p_as_date,sysdate) OR end_date IS NULL);
  RETURN l_le_id;
  END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
         RETURN NULL;
END get_le_id;



/* This function returns the Operating unit Id thats has a valid
*  "Intercompany Operating Unit" relation with the party that is passed*/

FUNCTION get_ou_id (p_party_id IN NUMBER  , p_as_date IN DATE )
RETURN NUMBER is
	l_ou_id NUMBER;
BEGIN
 SELECT   hzr.subject_id into l_ou_id
	 FROM	    hz_relationships hzr
	 WHERE   HZR.object_id=p_party_id
	    AND     hzr.subject_table_name='HR_ALL_ORGANIZATION_UNITS'
	    AND     hzr.object_table_name='HZ_PARTIES'
 	    AND     hzr.relationship_type='INTERCOMPANY_OPERATING_UNIT'
	    AND	    hzr.relationship_code='OPERATING_UNIT_OF'
	    AND     hzr.directional_flag='B'
	    AND     hzr.status='A'
	    AND     TRUNC(start_date) <=nvl(p_as_date  ,sysdate)
	    AND     (TRUNC(end_date) >= nvl(p_as_date  ,sysdate) OR end_date IS NULL);
	RETURN l_ou_id;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
	RETURN NULL;
 WHEN TOO_MANY_ROWS THEN
	RETURN NULL;
END get_ou_id;




/* This function returns the System Reference for the party that is passed
* This function will undergo further changes after input from
* the Source System Management Team -- open issue 2 --*/

FUNCTION get_system_reference(p_party_id NUMBER)
RETURN VARCHAR2 is
	l_sys_ref VARCHAR2(240);
BEGIN
	SELECT orig_system_reference
	INTO l_sys_ref
	FROM hz_parties
	WHERE party_id = p_party_id;
	RETURN l_sys_ref;
EXCEPTION
WHEN OTHERS THEN
raise_application_error(20001, SQLERRM);
END get_system_reference;




/* This function returns "Y" or "N" depending on the Org thats passed
* has a intercompany classification or not*/

FUNCTION is_intercompany_org (p_party_id NUMBER)
RETURN VARCHAR2 is
l_status VARCHAR2(10);
BEGIN
	SELECT status
	INTO l_status
	FROM hz_parties
	WHERE party_id=p_party_id;
	IF(l_status <>'A') THEN RETURN 'N';
	END IF;

	SELECT status_flag
      INTO l_status
	FROM 	  hz_party_usg_assignments hua
	WHERE   hua.party_id = p_party_id
	AND     hua.party_usage_code = 'INTERCOMPANY_ORG';
/*
	SELECT          status
		INTO l_status
	 		FROM 	  HZ_CODE_ASSIGNMENTS hca
			WHERE  	  hca.owner_table_id=p_party_id
			AND	  hca.class_category='INTERCOMPANY'
			AND	  hca.class_code ='INTERCOMPANY'
			AND	  hca.owner_table_name='HZ_PARTIES' ;
*/
	IF(l_status = 'A') THEN RETURN 'Y';
	ELSE RETURN 'N';
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    RETURN 'N';
END is_intercompany_org;


/* This function returns "Y" or "N" depending on the Org thats passed
* is a valid intercompany or not*/

FUNCTION is_intercompany_org_valid (p_party_id NUMBER  	, p_as_date DATE )
RETURN VARCHAR2 is
l_status VARCHAR2(10);
BEGIN
	SELECT status
	INTO l_status
	FROM hz_parties
	WHERE party_id=p_party_id;
	IF(l_status <>'A') THEN RETURN 'N';
	END IF;

	SELECT status_flag
      INTO l_status
	FROM 	  hz_party_usg_assignments hua
	WHERE   hua.party_id = p_party_id
	AND     hua.party_usage_code = 'INTERCOMPANY_ORG'
	AND     hua.effective_start_date <= NVL(p_as_date, sysdate)
      AND     (hua.effective_end_date >= NVL(p_as_date, sysdate) OR effective_end_date IS NULL);

/*	SELECT          status
		INTO l_status
	 		FROM 	  HZ_CODE_ASSIGNMENTS hca
			WHERE  	  hca.owner_table_id=p_party_id
			AND	  hca.class_category='INTERCOMPANY'
			AND	  hca.class_code ='INTERCOMPANY'
			AND	  hca.owner_table_name='HZ_PARTIES'
			AND 	  start_date_active<=nvl(p_as_date  ,sysdate)
			AND 	  (end_date_active >= nvl(p_as_date  ,sysdate) OR end_date_active IS NULL);
*/
	IF(l_status = 'A') THEN RETURN 'Y';
	ELSE RETURN 'N';
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    RETURN 'N';
END is_intercompany_org_valid;

/**This procedure will return the Efffective Start Date and Effective End Date for the Orgnazition id passed
*/

PROCEDURE get_ic_org_valid_dates (p_party_id IN NUMBER, effective_start_date OUT NOCOPY DATE, effective_end_date OUT NOCOPY DATE)
 is
 CURSOR ic_valid_dates IS
SELECT hua.effective_start_date, hua.effective_end_date
	FROM 	  hz_party_usg_assignments hua
	WHERE   hua.party_id = p_party_id
    AND hua.party_usage_code = 'INTERCOMPANY_ORG'
    AND hua.effective_start_date = (
				SELECT max(effective_start_date)
                FROM hz_party_usg_assignments
				WHERE   party_id = p_party_id
                AND party_usage_code = 'INTERCOMPANY_ORG'
                );
BEGIN

  OPEN ic_valid_dates;
    FETCH ic_valid_dates INTO effective_start_date, effective_end_date;
  CLOSE ic_valid_dates;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	effective_start_date := NULL;
	effective_end_date := NULL;
END get_ic_org_valid_dates;

FUNCTION CF_TRANSACTING_ENTITY_FLAG(p_party_id in NUMBER, p_date DATE ) RETURN VARCHAR2
IS
--l_code_assignment_rec      hz_classification_v2pub.code_assignment_rec_type;
l_party_usg_assignment_rec HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
l_return_status            varchar2(2000);
l_msg_count                number;
l_msg_data         varchar2(2000);
--l_code_assignment_id       number;

BEGIN

 --- Classifying Legal Entity as Intercompany
/*
 l_code_assignment_rec.owner_table_name    := 'HZ_PARTIES';
 l_code_assignment_rec.owner_table_id      := p_party_id;
 l_code_assignment_rec.class_category      := 'INTERCOMPANY';
 l_code_assignment_rec.class_code          := 'INTERCOMPANY';
 l_code_assignment_rec.primary_flag        := 'Y';
 l_code_assignment_rec.content_source_type := 'USER_ENTERED';
 l_code_assignment_rec.start_date_active   := nvl(p_date,sysdate);
 l_code_assignment_rec.created_by_module   := 'FUN_AGIS';
 l_code_assignment_rec.application_id      := 435;

HZ_CLASSIFICATION_V2PUB.create_Code_Assignment(
	p_init_msg_list            => 'F',
	p_code_assignment_rec      => l_code_assignment_rec,
	x_return_status            => l_return_status,
	x_msg_count                => l_msg_count,
	x_msg_data                 => l_msg_data,
	x_code_assignment_id       => l_code_assignment_id
);
*/
 l_party_usg_assignment_rec.party_id         := p_party_id;
 l_party_usg_assignment_rec.party_usage_code := 'INTERCOMPANY_ORG';
 l_party_usg_assignment_rec.created_by_module := 'FUN_AGIS';

HZ_PARTY_USG_ASSIGNMENT_PUB.assign_party_usage(
	p_init_msg_list            => 'F',
	p_party_usg_assignment_rec => l_party_usg_assignment_rec,
	x_return_status            => l_return_status,
	x_msg_count                => l_msg_count,
	x_msg_data                 => l_msg_data
);

/* BUG NO: 6001688
  The function was exiting without returning a value.
  Changes are made for the function to return l_return_status
*/

return l_return_status;

END CF_TRANSACTING_ENTITY_FLAG;

/*
Bug No: 6146773. Check for the existence of the given party name.
*/
PROCEDURE is_party_exist (l_party_name in VARCHAR2, flag out NOCOPY VARCHAR2)
IS

CURSOR chk_party IS
SELECT 'Y'
	FROM hz_parties h, hz_party_usg_assignments hua
	WHERE h.party_name = l_party_name
    AND hua.party_id = h.party_id
    AND hua.party_usage_code = 'INTERCOMPANY_ORG';
BEGIN

OPEN chk_party;

FETCH chk_party INTO flag;

if (chk_party%found) then

flag := 'Y';
else

flag := 'N';
end if;

CLOSE chk_party;
END is_party_exist;

END FUN_TCA_PKG;

/
