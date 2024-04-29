--------------------------------------------------------
--  DDL for Package OZF_CLAIM_AGING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_AGING_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcags.pls 115.0 2003/06/26 05:08:19 mchang noship $ */
--------------------------------------------------------------------------------
--    API name   : Populate_Aging
--    Type       : Private
--    Pre-reqs   : None
--    Function   :
--    Parameters :
--
--    IN         : p_bucket_id        IN  NUMBER    Optional
--
--    Version    : Current version     1.0
--
--------------------------------------------------------------------------------
PROCEDURE Populate_Aging (
    ERRBUF              OUT NOCOPY VARCHAR2,
    RETCODE             OUT NOCOPY NUMBER,
    p_bucket_id         IN NUMBER
);

END OZF_Claim_Aging_PVT;

 

/
