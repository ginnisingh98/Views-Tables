--------------------------------------------------------
--  DDL for Package HZ_MERGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARHMUTLS.pls 120.2 2005/10/30 04:20:38 appldev noship $ */

PROCEDURE insert_party_site_details (
	p_from_party_id	IN	NUMBER,
	p_to_party_id	IN	NUMBER,
	p_batch_party_id IN	NUMBER,
        p_CREATED_BY    NUMBER,
        p_CREATION_DATE    DATE,
        p_LAST_UPDATE_LOGIN    NUMBER,
        p_LAST_UPDATE_DATE    DATE,
        p_LAST_UPDATED_BY    NUMBER);


PROCEDURE insert_party_reln_details (
        p_from_party_id IN      NUMBER,
        p_to_party_id   IN      NUMBER,
        p_batch_party_id IN     NUMBER,
        p_CREATED_BY    IN NUMBER,
        p_CREATION_DATE   IN  DATE,
        p_LAST_UPDATE_LOGIN IN    NUMBER,
        p_LAST_UPDATE_DATE  IN   DATE,
        p_LAST_UPDATED_BY  IN   NUMBER);

FUNCTION get_party_site_description(
        p_party_site_id IN      NUMBER)
RETURN VARCHAR2;

FUNCTION get_party_reln_description(
        p_party_reln_id IN      NUMBER)
RETURN VARCHAR2;

FUNCTION get_org_contact_description(
        p_org_contact_id IN      NUMBER)
RETURN VARCHAR2;

FUNCTION get_org_contact_id(
        p_party_relationship_id  IN NUMBER)
RETURN NUMBER;

FUNCTION get_reln_party_id(
        p_party_relationship_id  IN NUMBER)
RETURN NUMBER;
END HZ_MERGE_UTIL;

 

/
