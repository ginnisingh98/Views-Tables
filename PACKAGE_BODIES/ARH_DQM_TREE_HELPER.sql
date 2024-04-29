--------------------------------------------------------
--  DDL for Package Body ARH_DQM_TREE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_DQM_TREE_HELPER" AS
/*$Header: ARHDQMBB.pls 120.1 2005/06/16 21:10:54 jhuang noship $*/

FUNCTION ctxmax
RETURN NUMBER
IS
 CURSOR c1 IS
 SELECT MAX(search_context_id)
   FROM hz_matched_parties_gt;
 lret  NUMBER;
BEGIN
 OPEN c1;
  FETCH c1 INTO lret;
  IF c1%NOTFOUND THEN
    lret := 0;
  END IF;
 CLOSE c1;
 RETURN lret;
END;

PROCEDURE insert_add_party_site
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER,
 p_ps_id   IN NUMBER)
IS
BEGIN
  IF party_site_in_match (p_party_id , p_ctx_id , p_ps_id) = 'N' THEN
    INSERT INTO hz_matched_party_sites_gt
    (PARTY_ID  ,PARTY_SITE_ID,SEARCH_CONTEXT_ID ,SCORE)  VALUES
    (p_party_id,p_ps_id      ,p_ctx_id, 0);
  END IF;
END;

PROCEDURE insert_add_contact
(p_party_id   IN NUMBER,
 p_ctx_id     IN NUMBER,
 p_contact_id IN NUMBER)
IS
BEGIN
  IF contact_in_match (p_party_id , p_ctx_id , p_contact_id) = 'N' THEN
    INSERT INTO hz_matched_contacts_gt
    (PARTY_ID  , ORG_CONTACT_ID, SEARCH_CONTEXT_ID, SCORE )  VALUES
    (p_party_id, p_contact_id  ,p_ctx_id, 0);
  END IF;
END;

PROCEDURE insert_add_cpt
(p_party_id   IN NUMBER,
 p_ctx_id     IN NUMBER,
 p_cpt_id     IN NUMBER)
IS
BEGIN
  IF cpt_in_match (p_party_id , p_ctx_id , p_cpt_id) = 'N' THEN
    INSERT INTO hz_matched_cpts_gt
    (PARTY_ID  , CONTACT_POINT_ID, SEARCH_CONTEXT_ID , SCORE)  VALUES
    (p_party_id, p_cpt_id        , p_ctx_id, 0);
  END IF;
END;

FUNCTION is_pty_object_of_rel
(p_party_id IN NUMBER,
 p_rel_id   IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_relationships
   WHERE relationship_id   = p_rel_id
     AND object_table_name = 'HZ_PARTIES'
     AND object_id         = p_party_id
     AND directional_flag  = 'F';
  ret VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;

FUNCTION is_site_of_pty
(p_party_id IN NUMBER,
 p_ps_id    IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c1 IS
  SELECT 'Y'
    FROM hz_party_sites
   WHERE party_site_id  = p_ps_id
     AND party_id       = p_party_id;
  ret VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO ret;
  IF c1%NOTFOUND THEN
    ret := 'N';
  END IF;
  CLOSE c1;
  RETURN ret;
END;


FUNCTION cpt_in_match
---------------------------------------------------
-- Return Y if p_cpt_id found in HZ_MATCHED_CPTS_GT
--        N otherwise
---------------------------------------------------
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER,
 p_cpt_id   IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_exist IS
  SELECT 'Y'
    FROM hz_matched_cpts_gt
   WHERE party_id          = p_party_id
     AND search_context_id = p_ctx_id
     AND contact_point_id  = p_cpt_id;
  ret   VARCHAR2(1) := 'N';
BEGIN
  OPEN c_exist;
    FETCH c_exist INTO ret;
    IF c_exist%NOTFOUND THEN
      ret := 'N';
    END IF;
  CLOSE c_exist;
  RETURN ret;
END;

FUNCTION contact_in_match
-------------------------------------------------------
-- Return Y if p_cpt_id found in HZ_MATCHED_CONTACTS_GT
--        N otherwise
-------------------------------------------------------
(p_party_id   IN NUMBER,
 p_ctx_id     IN NUMBER,
 p_contact_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_exist IS
  SELECT 'Y'
    FROM hz_matched_contacts_gt
   WHERE party_id          = p_party_id
     AND search_context_id = p_ctx_id
     AND org_contact_id    = p_contact_id;
  ret   VARCHAR2(1) := 'N';
BEGIN
  OPEN c_exist;
    FETCH c_exist INTO ret;
    IF c_exist%NOTFOUND THEN
      ret := 'N';
    END IF;
  CLOSE c_exist;
  RETURN ret;
END;

FUNCTION party_site_in_match
----------------------------------------------------------
-- Return Y if p_cpt_id found in HZ_MATCHED_PARTY_SITES_GT
--        N otherwise
----------------------------------------------------------
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER,
 p_ps_id    IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_exist IS
  SELECT 'Y'
    FROM hz_matched_party_sites_gt
   WHERE party_id          = p_party_id
     AND search_context_id = p_ctx_id
     AND party_site_id     = p_ps_id;
  ret   VARCHAR2(1) := 'N';
BEGIN
  OPEN c_exist;
    FETCH c_exist INTO ret;
    IF c_exist%NOTFOUND THEN
      ret := 'N';
    END IF;
  CLOSE c_exist;
  RETURN ret;
END;


FUNCTION party_in_match
--------------------------------------------------------
-- Return Y if p_party_id found in HZ_MATCHED_PARTIES_GT
--        N otherwise
--------------------------------------------------------
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_exist IS
  SELECT 'Y'
    FROM hz_matched_parties_gt
   WHERE party_id          = p_party_id
     AND search_context_id = p_ctx_id;
  ret   VARCHAR2(1) := 'N';
BEGIN
  OPEN c_exist;
    FETCH c_exist INTO ret;
    IF c_exist%NOTFOUND THEN
      ret := 'N';
    END IF;
  CLOSE c_exist;
  RETURN ret;
END;

FUNCTION contact_id_from_rel_id
-------------------------------------------------------
-- RETURN org_contact_id from a relationship_id
--      + x_party_site_id will return the site_id if the contact is at the site level
--      I x_party_site_id = -9999 otherwise
-- RETURN -9999 if the org_contact_id coud not be found
-------------------------------------------------------
( p_rel_id   IN NUMBER     ,
  x_ps_id    IN OUT NOCOPY NUMBER )
RETURN NUMBER
IS
  CURSOR c_org_contact IS
  SELECT org_contact_id,
         party_site_id
    FROM hz_org_contacts
   WHERE party_relationship_id = p_rel_id;
  ret NUMBER;
BEGIN
  OPEN c_org_contact;
  FETCH c_org_contact INTO ret, x_ps_id;
  IF    c_org_contact%NOTFOUND THEN
     ret     := -9999;
     x_ps_id := -9999;
  ELSIF x_ps_id IS NULL THEN
     x_ps_id := -9999;
  END IF;
  CLOSE c_org_contact;
  RETURN ret;
END;

FUNCTION rel_id_betw_per_to_org
----------------------------------------------------------------------
-- RETURN Relationship_id if the per_id is in relation with a party_id
--      + x_rel_code contains REL_CODE
-- RETURN -9999 otherwise
----------------------------------------------------------------------
( p_party_id  IN NUMBER,
  p_pers_id   IN NUMBER,
  x_rel_code  IN OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
  CURSOR c_exist IS
  SELECT relationship_id,
         relationship_code
    FROM hz_relationships
   WHERE subject_type      = 'PERSON'
     AND subject_table_name= 'HZ_PARTIES'
     AND subject_id        = p_pers_id
     AND object_type       = 'ORGANIZATION'
     AND object_table_name = 'HZ_PARTIES'
     AND object_id         = p_party_id
     AND directional_flag  = 'F';
  ret NUMBER := -9999;
BEGIN
  OPEN c_exist;
  FETCH c_exist INTO ret, x_rel_code;
  IF c_exist%NOTFOUND THEN
    ret := -9999;
  END IF;
  CLOSE c_exist;
  RETURN ret;
END;

FUNCTION party_type
(p_party_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR c_type IS
  SELECT party_type
    FROM hz_parties
   WHERE party_id = p_party_id;
  ret VARCHAR2(30);
BEGIN
  OPEN c_type;
    FETCH c_type INTO ret;
  CLOSE c_type;
  RETURN ret;
END;

FUNCTION party_or_site_from_cpt
---------------------------------------------------------------------------------------
-- RETURN party_site_id if contact_point at PS
--      + flag x_type to 'HZ_PARTY_SITES'
-- RETURN party_id if contact_point at HZ_PARTIES
--      + flag x_type to 'ORGANIZATION' if the party is type 'ORGANIZATION'
--        flag x_type to 'PARTY_RELATIONSHIP' if the party is type 'PARTY_RELATIONSHIP'
-- RETURN -9999 if contact_point not found
---------------------------------------------------------------------------------------
(p_contact_point_id  IN NUMBER,
 x_type              IN OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
  CURSOR c_contact_point IS
  SELECT owner_table_name,
         owner_table_id
    FROM hz_contact_points
   WHERE contact_point_id = p_contact_point_id;
  ret NUMBER;
BEGIN
  OPEN c_contact_point;
    FETCH c_contact_point INTO x_type, ret;
    IF c_contact_point%NOTFOUND THEN
      ret := -9999;
      IF x_type = 'HZ_PARTIES' THEN
         x_type := party_type(ret);
      END IF;
    END IF;
  CLOSE c_contact_point;
  RETURN ret;
END;

PROCEDURE relationship_treatment
(p_rel_id         IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2)
IS
  l_org_contact_id   NUMBER;
  l_ps_id            NUMBER;
  pty_out_rel        EXCEPTION;
  no_contact_for_rel EXCEPTION;
BEGIN
  IF is_pty_object_of_rel(p_pty_id, p_rel_id) = 'N' THEN
    RAISE pty_out_rel;
  END IF;
  l_org_contact_id  := contact_id_from_rel_id( p_rel_id   => p_rel_id,
                                               x_ps_id    => l_ps_id );
  IF l_org_contact_id = -9999 THEN
    RAISE no_contact_for_rel;
  END IF;

  insert_add_contact(p_party_id  => p_pty_id,
                     p_ctx_id    => p_ctx_id,
                     p_contact_id=> l_org_contact_id);

  IF l_ps_id <> -9999 THEN
    insert_add_party_site(p_party_id => p_pty_id,
                          p_ctx_id   => p_ctx_id,
                          p_ps_id    => l_ps_id);
  END IF;
EXCEPTION
  WHEN  pty_out_rel        THEN
      fnd_message.set_name('AR', 'HZ_API_ERROR_PTY_OUT_REL');
      fnd_message.set_token('PARTY_ID',TO_CHAR(p_pty_id));
      fnd_message.set_token('RELATIONSHIP_ID',TO_CHAR(p_rel_id));
      fnd_msg_pub.add;
      x_return_status := fnd_api.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
  WHEN  no_contact_for_rel THEN
      fnd_message.set_name('AR', 'HZ_API_ERROR_NO_CT_REL');
      fnd_message.set_token('RELATIONSHIP_ID',TO_CHAR(p_rel_id));
      fnd_msg_pub.add;
      x_return_status := fnd_api.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
END;

PROCEDURE treatment_party_site
(p_ps_id          IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2)
IS
  site_not_for_pty  EXCEPTION;
BEGIN
  IF is_site_of_pty (p_pty_id , p_ps_id ) = 'N' THEN
    RAISE site_not_for_pty;
  END IF;
  insert_add_party_site(p_party_id => p_pty_id,
                        p_ctx_id   => p_ctx_id,
                        p_ps_id    => p_ps_id);
EXCEPTION
  WHEN site_not_for_pty THEN
      fnd_message.set_name('AR', 'HZ_API_ERROR_SITE_NOT_PTY');
      fnd_message.set_token('PARTY_ID',TO_CHAR(p_pty_id));
      fnd_message.set_token('PARTY_SITE_ID',TO_CHAR(p_ps_id));
      fnd_msg_pub.add;
      x_return_status := fnd_api.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
END;

PROCEDURE cpt_treatment
(p_cpt_id         IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2)
IS
  l_id       NUMBER;
  l_rel_id   NUMBER;
  l_rel_code VARCHAR2(30);
  l_type     VARCHAR2(30);
  cpt_pb     EXCEPTION;
  rel_pb     EXCEPTION;
BEGIN
  l_id := party_or_site_from_cpt(p_contact_point_id => p_cpt_id,
                                 x_type             => l_type);
  IF l_id = -9999 THEN
    RAISE cpt_pb;
  END IF;

  IF l_type IN ('PERSON', 'ORGANIZATION') THEN

    IF l_id = p_pty_id THEN
      NULL;
    ELSE
      l_rel_id := rel_id_betw_per_to_org( p_party_id  => p_pty_id,
                                          p_pers_id   => l_id,
                                          x_rel_code  => l_rel_code);
      IF l_rel_id = -9999 THEN
        RAISE rel_pb;
      END IF;
        relationship_treatment(p_rel_id   => l_rel_id,
                               p_pty_id   => p_pty_id,
                               p_ctx_id   => p_ctx_id,
                               x_return_status=> x_return_status,
                               x_msg_count=> x_msg_count,
                               x_msg_data => x_msg_data);

    END IF;

  ELSIF  l_type = 'PARTY_RELATIONSHIP'    THEN
    relationship_treatment(p_rel_id   => l_rel_id,
                           p_pty_id   => p_pty_id,
                           p_ctx_id   => p_ctx_id,
                           x_return_status=> x_return_status,
                           x_msg_count=> x_msg_count,
                           x_msg_data => x_msg_data);

  ELSIF l_type  = 'HZ_PARTY_SITES' THEN
    treatment_party_site(p_ps_id    => l_id,
                         p_pty_id   => p_pty_id,
                         p_ctx_id   => p_ctx_id,
                         x_return_status=> x_return_status,
                         x_msg_count=> x_msg_count,
                         x_msg_data => x_msg_data);

  END IF;
EXCEPTION
  WHEN cpt_pb THEN
      fnd_message.set_name('AR', 'HZ_API_ERROR_CPT');
      fnd_message.set_token('CONTACT_POINT_ID',TO_CHAR(p_cpt_id));
      fnd_msg_pub.add;
      x_return_status := fnd_api.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
  WHEN rel_pb THEN
      fnd_message.set_name('AR', 'HZ_API_ERROR_REL');
      fnd_message.set_token('PARTY_ID',TO_CHAR(p_pty_id));
      fnd_message.set_token('PARTY2_ID', TO_CHAR(l_id));
      fnd_msg_pub.add;
      x_return_status := fnd_api.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
END;

PROCEDURE contact_treatment
(p_contact_id     IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2)
IS
  CURSOR c1 IS
  SELECT NVL(party_site_id,-9999)
    FROM hz_org_contacts
   WHERE org_contact_id = p_contact_id;
  l_ps_id NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 INTO l_ps_id;
  IF c1%FOUND THEN
    IF l_ps_id <> -9999 THEN
      treatment_party_site(p_ps_id         => l_ps_id,
                           p_pty_id        => p_pty_id,
                           p_ctx_id        => p_ctx_id,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);

    END IF;
  END IF;
  CLOSE c1;
END;

END;

/
