--------------------------------------------------------
--  DDL for Package HZ_PARTY_INFO_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_INFO_V2PVT" AUTHID CURRENT_USER AS
/*$Header: ARHPRI1S.pls 120.1 2005/06/16 21:14:33 jhuang noship $ */

-------------------------------------------------
-- declaration of Public procedures and functions
-------------------------------------------------

PROCEDURE v2_create_credit_rating (
    p_credit_rating_rec             IN     HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    x_credit_rating_id                 OUT NOCOPY NUMBER
);

PROCEDURE v2_update_credit_rating (
    p_credit_rating_rec           IN     HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE,
    p_last_update_date            IN OUT NOCOPY DATE,
    x_return_status               IN OUT NOCOPY VARCHAR2
);

END HZ_PARTY_INFO_V2PVT;

 

/
