--------------------------------------------------------
--  DDL for Package HZ_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TRANS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQTRS.pls 120.12 2006/10/05 18:59:40 nsinghai noship $ */
/*#
 * Provides seeded transformation procedures for Data Quality Management.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname DQM Transformations
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:category BUSINESS_ENTITY HZ_CONTACT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Data Quality Management Transformation APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
next_gen_dqm VARCHAR2(1) := 'N';
staging_context VARCHAR2(1) := 'N';
FUNCTION EXACT (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION RM_SPLCHAR (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)--bug 5128213
RETURN VARCHAR2;

FUNCTION RM_BLANKS (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION CLEANSE (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION CLUSTER_WORD (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION SOUNDX (
        p_original_value VARCHAR2,
        p_language VARCHAR2,
        p_attribute_name VARCHAR2,
        p_entity_name    VARCHAR2)
     RETURN VARCHAR2;

FUNCTION EXACT_PADDED (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION ACRONYM (
        p_original_value VARCHAR2,
        p_language VARCHAR2,
        p_attribute_name VARCHAR2,
        p_entity_name    VARCHAR2)
     RETURN VARCHAR2;

FUNCTION REVERSE_NAME (
               p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION EXACT_DATE(
        p_original_value        IN      DATE,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
     RETURN VARCHAR2;

FUNCTION EXACT_NUMBER(
        p_original_value        IN      NUMBER,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
     RETURN VARCHAR2;

FUNCTION EXACT_EMAIL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION CLEANSED_EMAIL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION EXACT_URL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION CLEANSED_URL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRPerson_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRPerson_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRPerson_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WROrg_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WROrg_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WROrg_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRNames_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRNames_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRNames_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION Reverse_WRNames_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Reverse_WRNames_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Reverse_WRPerson_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Reverse_WRPerson_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION WRAddress_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRAddress_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRState_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION WRState_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


FUNCTION Reverse_Phone_number(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 ;

FUNCTION RM_SPLCHAR_CTX (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION Basic_WRNames (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Basic_Cleanse_WRNames (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Basic_WRPerson (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Basic_Cleanse_WRPerson (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Basic_WRAddr (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION Basic_Cleanse_WRAddr (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;


-- Word Replace Functions

-- version of word_replace -- calling with dictionary name
/*#
 * Performs a word replacement in Data Quality Management. The function takes an input string,
 * tokenizes it using spaces, replaces each token based on the passed word replacement list,
 * and returns the concatenated replaced tokens.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Word Replacement
 * @rep:doccd 120hztig.pdf Data Quality Management Transformation APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
FUNCTION word_replace (
        p_input_str             IN      VARCHAR2,
        p_word_list_name        IN      VARCHAR2,
        p_language              IN      VARCHAR2)
     RETURN VARCHAR2;

-- version of word_replace -- calling with dictionary id
/*#
 * Performs a word replacement in Data Quality Management. The function takes an input string,
 * tokenizes it using spaces, replaces each token based on the passed word replacement list,
 * and returns the concatenated replaced tokens.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Word Replacement
 * @rep:doccd 120hztig.pdf Data Quality Management Transformation APIs,
 * Oracle Trading Community Architecture Technical Implementation Guide
 */
FUNCTION word_replace (
        p_input_str             IN      VARCHAR2,
        p_word_list_id          IN      NUMBER,
        p_language              IN      VARCHAR2)
     RETURN VARCHAR2;


PROCEDURE set_party_type (
     p_party_type VARCHAR2
);

PROCEDURE clear_globals;

PROCEDURE set_bulk_dup_id;
PROCEDURE set_staging_context (p_staging_context varchar2);
FUNCTION RM_SPLCHAR_BLANKS(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;
END;

 

/
