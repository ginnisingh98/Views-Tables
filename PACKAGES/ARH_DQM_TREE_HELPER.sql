--------------------------------------------------------
--  DDL for Package ARH_DQM_TREE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_DQM_TREE_HELPER" AUTHID CURRENT_USER AS
/*$Header: ARHDQMBS.pls 120.1 2005/06/16 21:10:57 jhuang noship $*/

FUNCTION ctxmax
RETURN NUMBER ;

FUNCTION cpt_in_match
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER,
 p_cpt_id   IN NUMBER)
RETURN VARCHAR2;

FUNCTION contact_in_match
(p_party_id   IN NUMBER,
 p_ctx_id     IN NUMBER,
 p_contact_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION party_site_in_match
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER,
 p_ps_id    IN NUMBER)
RETURN VARCHAR2;

FUNCTION party_in_match
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER)
RETURN VARCHAR2;

--------------

PROCEDURE insert_add_party_site
(p_party_id IN NUMBER,
 p_ctx_id   IN NUMBER,
 p_ps_id   IN NUMBER);

PROCEDURE insert_add_contact
(p_party_id   IN NUMBER,
 p_ctx_id     IN NUMBER,
 p_contact_id IN NUMBER);

PROCEDURE insert_add_cpt
(p_party_id   IN NUMBER,
 p_ctx_id     IN NUMBER,
 p_cpt_id     IN NUMBER);

-----------------------------

FUNCTION contact_id_from_rel_id
-------------------------------------------------------
-- RETURN org_contact_id from a relationship_id
--      + x_party_site_id will return the site_id if the contact is at the site level
--      I x_party_site_id = -9999 otherwise
-- RETURN -9999 if the org_contact_id coud not be found
-------------------------------------------------------
( p_rel_id   IN NUMBER     ,
  x_ps_id    IN OUT NOCOPY NUMBER )
RETURN NUMBER;

FUNCTION party_or_site_from_cpt
---------------------------------------------------------------------------------------
-- RETURN party_site_id if contact_point at PS
--      + flag x_type to 'PARTY_SITE'
-- RETURN party_id if contact_point at PARTY
--      + flag x_type to 'ORGANIZATION' if the party is type 'ORGANIZATION'
--        flag x_type to 'PARTY_RELATIONSHIP' if the party is type 'PARTY_RELATIONSHIP'
-- RETURN -9999 if contact_point not found
---------------------------------------------------------------------------------------
(p_contact_point_id  IN NUMBER,
 x_type              IN OUT NOCOPY VARCHAR2)
RETURN NUMBER;

FUNCTION rel_id_betw_per_to_org
----------------------------------------------------------------------
-- RETURN Relationship_id if the per_id is in relation with a party_id
--      + x_rel_code contains REL_CODE
-- RETURN -9999 otherwise
----------------------------------------------------------------------
( p_party_id  IN NUMBER,
  p_pers_id   IN NUMBER,
  x_rel_code  IN OUT NOCOPY VARCHAR2)
RETURN NUMBER;

FUNCTION is_pty_object_of_rel
(p_party_id IN NUMBER,
 p_rel_id   IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_site_of_pty
(p_party_id IN NUMBER,
 p_ps_id    IN NUMBER)
RETURN VARCHAR2;

PROCEDURE relationship_treatment
(p_rel_id         IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE treatment_party_site
(p_ps_id          IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE cpt_treatment
(p_cpt_id         IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE contact_treatment
(p_contact_id     IN NUMBER,
 p_pty_id         IN NUMBER,
 p_ctx_id         IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2);

END;

 

/
