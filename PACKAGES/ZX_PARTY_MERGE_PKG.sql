--------------------------------------------------------
--  DDL for Package ZX_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcptpms.pls 120.0.12010000.4 2009/10/29 14:24:32 ssohal ship $ */

  PROCEDURE ZX_MERGE (
    p_entity_name        in  hz_merge_dictionary.entity_name%type,
    p_from_id            in  oks_billing_profiles_b.id%type,
    x_to_id          in out  nocopy oks_billing_profiles_b.id%type,
    p_from_fk_id         in  hz_merge_parties.from_party_id%type,
    p_to_fk_id           in  hz_merge_parties.to_party_id%type,
    p_parent_entity_name in  hz_merge_dictionary.parent_entity_name%type,
    p_batch_id           in  hz_merge_batch.batch_id%type,
    p_batch_party_id     in  hz_merge_party_details.batch_party_id%type,
    x_return_status     out  nocopy varchar2);

  TYPE reg_attr_rec_type IS  RECORD ( REGISTRATION_TYPE_CODE  VARCHAR2(30),
                                      REGISTRATION_NUMBER VARCHAR2(50),
                                      ROUNDING_RULE_CODE  VARCHAR2(30),
                                      SELF_ASSESS_FLAG    VARCHAR2(1),
                                      INCLUSIVE_TAX_FLAG  VARCHAR2(1),
                                      TAX_REGIME_CODE     VARCHAR2(30),
                                      TAX                 VARCHAR2(30),
                                      REP_REGISTRATION_NUMBER VARCHAR2(50));

  TYPE reg_attr_tbl_type IS TABLE of reg_attr_rec_type index by VARCHAR2(100);

  TYPE reg_xle_rec_type IS  RECORD ( REGISTRATION_TYPE_CODE      VARCHAR2(30),
                                     REGISTRATION_NUMBER         VARCHAR2(50),
                                     ROUNDING_RULE_CODE          VARCHAR2(30),
                                     SELF_ASSESS_FLAG            VARCHAR2(1),
                                     INCLUSIVE_TAX_FLAG          VARCHAR2(1),
                                     REGISTRATION_STATUS_CODE    VARCHAR2(30),
                                     BANK_ACCOUNT_NUM            VARCHAR2(30),
                                     BANK_ID                     NUMBER,
                                     BANK_BRANCH_ID              NUMBER);

  TYPE  reg_xle_tbl_type IS TABLE of reg_xle_rec_type index by VARCHAR2(100);

  PROCEDURE MERGE_PTP_BULK
    (request_id    IN NUMBER,
     set_number    IN NUMBER,
     process_mode  IN VARCHAR2
    );

  PROCEDURE MERGE_PTP_SITES (
   p_entity_name        IN     VARCHAR2,
   p_from_id            IN     NUMBER,
   p_to_id              IN OUT NOCOPY NUMBER,
   p_from_fk_id         IN     NUMBER,
   p_to_fk_id           IN     NUMBER,
   p_parent_entity_name IN     VARCHAR2,
   p_batch_id           IN     VARCHAR2,
   p_batch_party_id     IN     VARCHAR2,
   x_return_status      IN OUT NOCOPY VARCHAR2);

END ZX_PARTY_MERGE_PKG;

/
