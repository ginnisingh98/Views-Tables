--------------------------------------------------------
--  DDL for Package Body POS_ENTERPRISE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ENTERPRISE_UTIL_PKG" as
--$Header: POSENTRB.pls 120.2 2005/07/21 01:44:08 bitang noship $

PROCEDURE get_enterprise_information
  (x_party_id      OUT NOCOPY NUMBER,
   x_party_name    OUT NOCOPY VARCHAR2,
   x_exception_msg OUT NOCOPY VARCHAR2,
   x_status        OUT NOCOPY VARCHAR2
   )
IS
   CURSOR l_cur IS
      SELECT hp.party_id, hp.party_name
	FROM hz_parties hp, hz_code_assignments hca
    	WHERE hca.owner_table_id = hp.party_id
    	  AND hca.owner_table_name = 'HZ_PARTIES'
    	  AND hca.class_category = 'POS_PARTICIPANT_TYPE'
    	  AND hca.class_code = 'ENTERPRISE'
    	  AND hca.status= 'A'
    	  AND hp.status= 'A'
    	  AND ( hca.end_date_active > sysdate or hca.end_date_active is null );

   l_rec1 l_cur%ROWTYPE;
   l_rec2 l_cur%ROWTYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec1;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_status := 'E';
      x_exception_msg := 'enterprise party not found';
      RETURN;
   END IF;

   FETCH l_cur INTO l_rec2;
   IF l_cur%found THEN
      CLOSE l_cur;
      x_status := 'E';
      x_exception_msg := 'found more than 1 enterprise party';
      RETURN;
   END IF;

   CLOSE l_cur;

   x_party_id      := l_rec1.party_id;
   x_party_name    := l_rec1.party_name;
   x_status        := 'S';
   x_exception_msg := NULL;

END get_enterprise_information;

PROCEDURE get_enterprise_party_name
  ( x_party_name    OUT NOCOPY VARCHAR2,
    x_exception_msg OUT NOCOPY VARCHAR2,
    x_status        OUT NOCOPY VARCHAR2
    )
IS
   l_party_id NUMBER;
BEGIN
   get_enterprise_information(l_party_id, x_party_name, x_exception_msg, x_status);
END get_enterprise_party_name;

PROCEDURE get_enterprise_partyid
  (x_party_id      OUT NOCOPY NUMBER,
   x_exception_msg OUT NOCOPY VARCHAR2,
   x_status        OUT NOCOPY VARCHAR2
   )
  IS
     l_party_name hz_parties.party_name%TYPE;
BEGIN
   get_enterprise_information(x_party_id, l_party_name, x_exception_msg, x_status);
END get_enterprise_partyid;

PROCEDURE create_enterprise_party
  (  x_status        OUT NOCOPY VARCHAR2
   , x_exception_msg OUT NOCOPY VARCHAR2
     )
IS
   CURSOR l_cur IS
      SELECT hp.party_id, hp.party_name
	FROM hz_parties hp, hz_code_assignments hca
    	WHERE hca.owner_table_id = hp.party_id
    	  AND hca.owner_table_name = 'HZ_PARTIES'
    	  AND hca.class_category = 'POS_PARTICIPANT_TYPE'
    	  AND hca.class_code = 'ENTERPRISE'
    	  AND hca.status= 'A'
    	  AND hp.status= 'A'
	  AND ( hca.end_date_active > sysdate or hca.end_date_active is null );

   l_party_id      NUMBER;
   l_party_name    hz_parties.party_name%TYPE;
   l_party_number  hz_parties.party_number%TYPE;
   l_profile_id    NUMBER;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_party_id, l_party_name;
   IF l_cur%found THEN
      CLOSE l_cur;
      x_status := 'E';
      x_exception_msg := 'enterprise party already exists';
      raise_application_error(-20001,x_exception_msg,TRUE);
   END IF;
   CLOSE l_cur;

   pos_party_management_pkg.classify_party
     (l_party_id,
      'POS_CLASSIFICATION',
      'PROCUREMENT_ORGANIZATION',
      x_status,
      x_exception_msg
      );

    IF (x_status <> 'S') THEN
       x_exception_msg	:= 'Error when classifying enterprise party as PROCUREMENT_ORGANIZATION '
	 || l_party_id ||' '|| x_exception_msg;
       raise_application_error(-20002,x_exception_msg,TRUE);
    END IF;

    pos_party_management_pkg.classify_party
      (l_party_id,
       'POS_PARTICIPANT_TYPE',
       'ENTERPRISE',
       x_status,
       x_exception_msg
       );

    IF (x_status <> 'S') THEN
       x_exception_msg	:= 'Error when classifying enterprise party as ENTERPRISE '
	 || l_party_id ||' '|| x_exception_msg;
       raise_application_error(-20002,x_exception_msg,TRUE);
    END IF;

END create_enterprise_party;

PROCEDURE pos_create_enterprise_user
  (p_username        IN  VARCHAR2, -- must
   p_firstname       IN  VARCHAR2, -- must
   p_lastname        IN  VARCHAR2, -- must
   p_emailaddress    IN  VARCHAR2 DEFAULT NULL,
   x_party_id        OUT NOCOPY NUMBER, -- party id of the user
   x_relationship_id OUT NOCOPY NUMBER, -- relationship_id of the user with the company
   x_exception_msg   OUT NOCOPY VARCHAR2,
   x_status          OUT NOCOPY VARCHAR2
   )
IS
    l_org_partyId       NUMBER;
    l_party_name        hz_parties.party_name%TYPE;
    l_emp_records       NUMBER;
    l_user_id           NUMBER;
BEGIN

    select user_id
    into l_user_id
    from fnd_user
    where user_name = p_username;

    l_emp_records := pos_party_management_pkg.get_emp_or_ctgt_wrkr_pty_id(l_user_id);
    if ( l_emp_records <= 0 ) then
        x_status := 'E';
        x_exception_msg := 'User: '||p_username ||' does not have employee id set.';
        raise_application_error(-20001, x_exception_msg, true);
    end if;

    -- Get the Enterprise party_id
    get_enterprise_information
      (l_org_partyId,
       l_party_name,
       x_exception_msg,
       x_status
       );

    IF (x_status <> 'S') THEN
        raise_application_error(-20001, x_exception_msg, true);
    END IF;

    pos_party_management_pkg.pos_create_user
      (p_username,
       p_firstname,
       p_lastname,
       p_emailaddress,
       x_party_id,
       x_exception_msg,
       x_status
       );

    IF (x_status <> 'S') THEN
        raise_application_error(-20001, x_exception_msg, true);
    END IF;

    pos_party_management_pkg.classify_party
      (x_party_id,
       'POS_PARTICIPANT_TYPE',
       'ENTERPRISE_USER',
       x_status,
       x_exception_msg
       );

    IF (x_status <> 'S') THEN
        raise_application_error(-20001, x_exception_msg, true);
    END IF;

    pos_hz_relationships_pkg.pos_create_relationship
      (x_party_id,
       l_org_partyId,
       'POS_EMPLOYMENT',
       'EMPLOYEE_OF',
       x_relationship_id,
       x_status,
       x_exception_msg
       );

    IF (x_status <> 'S') THEN
        raise_application_error(-20001, x_exception_msg, true);
    END IF;

END pos_create_enterprise_user;

END POS_ENTERPRISE_UTIL_PKG;

/
