--------------------------------------------------------
--  DDL for Package HZ_PARTY_INFO_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_INFO_VAL" AUTHID CURRENT_USER AS
/*$Header: ARHPTIVS.pls 120.1 2005/06/16 21:15:15 jhuang ship $ */

procedure validate_credit_ratings(
    p_credit_ratings_rec       IN  HZ_PARTY_INFO_PUB.credit_ratings_rec_type,
    p_create_update_flag       IN  VARCHAR2,
    x_return_status            IN OUT  NOCOPY VARCHAR2
    );

procedure validate_financial_profile(
    p_financial_profile_rec    IN  HZ_PARTY_INFO_PUB.financial_profile_rec_type,
    p_create_update_flag       IN  VARCHAR2,
    x_return_status            IN OUT  NOCOPY VARCHAR2
    );

END HZ_PARTY_INFO_VAL;

 

/
