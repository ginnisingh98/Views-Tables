--------------------------------------------------------
--  DDL for Package HZ_PARTY_ACQUIRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_ACQUIRE" AUTHID CURRENT_USER AS
/* $Header: ARHDQAQS.pls 115.5 2003/10/03 23:37:47 cvijayan noship $ */

FUNCTION get_party_rec (
        p_party_id      IN      NUMBER,
        p_party_type    IN      VARCHAR2
        ) RETURN HZ_PARTY_SEARCH.party_search_rec_type;

FUNCTION get_party_site_rec (
        p_party_site_id      IN      NUMBER
        ) RETURN HZ_PARTY_SEARCH.party_site_search_rec_type;

FUNCTION get_contact_rec (
        p_org_contact_id      IN      NUMBER
        ) RETURN HZ_PARTY_SEARCH.contact_search_rec_type;

FUNCTION get_contact_point_rec (
        p_contact_point_id      IN      NUMBER
        ) RETURN HZ_PARTY_SEARCH.contact_point_search_rec_type;

FUNCTION get_account_info(
        p_party_id      IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_known_as (
        p_party_id      IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context	IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_address (
        p_party_site_id IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_phone_number (
        p_contact_pt_id IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_contact_name (
        p_org_contact_id IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION get_ssm_mappings (
        p_record_id     IN      NUMBER,
        p_entity        IN      VARCHAR2,
        p_attribute     IN      VARCHAR2,
        p_context       IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;


END;



 

/
