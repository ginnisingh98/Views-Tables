--------------------------------------------------------
--  DDL for Package HZ_MERGE_PARTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_PARTIES_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHMRGPS.pls 120.1 2005/06/16 21:12:50 jhuang noship $ */

procedure create_merge_party (
    p_api_version                IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2:= FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2:= FND_API.G_FALSE,
    p_batch_id                   IN  NUMBER,
    p_merge_type                 IN VARCHAR2,
    p_from_party_id              IN NUMBER,
    p_to_party_id                IN NUMBER,
    p_merge_reason_code          IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2,
    x_batch_party_id             OUT    NOCOPY NUMBER,
    p_validation_level           IN    NUMBER:= FND_API.G_VALID_LEVEL_FULL);



END HZ_MERGE_PARTIES_PUB;

 

/
