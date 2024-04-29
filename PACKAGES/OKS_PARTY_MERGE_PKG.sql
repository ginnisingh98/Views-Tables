--------------------------------------------------------
--  DDL for Package OKS_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: OKSPYMGS.pls 120.0 2005/05/25 18:30:33 appldev noship $ */

/* Merge the records in OKS_BILLING_PROFILES_B */

PROCEDURE OKS_BILLING_PROFILES(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_billing_profiles_b.id%type,
  x_to_id          in out  nocopy oks_billing_profiles_b.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2);


/* Merge the records in OKS_K_DEFAULTS */

PROCEDURE OKS_DEFAULTS(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_k_defaults.id%type,
  x_to_id          in out  nocopy oks_k_defaults.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2);


/* Merge the records in OKS_SERV_AVAIL_EXCEPTS */

PROCEDURE OKS_SERVICE_EXCEPTS(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  oks_serv_avail_excepts.id%type,
  x_to_id          in out  nocopy oks_serv_avail_excepts.id%type,
  p_from_fk_id         in  hz_merge_parties.from_party_id%type,
  p_to_fk_id           in  hz_merge_parties.to_party_id%type,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2);

/* Merge the records in OKS_QUALIFIERS  */

PROCEDURE OKS_QUALIFIERS(
  p_entity_name        in  hz_merge_dictionary.entity_name%type,
  p_from_id            in  number,
  x_to_id          in out  nocopy number,
  p_from_fk_id         in  number,
  p_to_fk_id           in  number,
  p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
  p_batch_id           in  hz_merge_batch.batch_id%type,
  p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
  x_return_status     out  nocopy varchar2);


END OKS_PARTY_MERGE_PKG;

 

/
