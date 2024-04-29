--------------------------------------------------------
--  DDL for Package HZ_MERGE_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_BATCH_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHMGBTS.pls 115.2 2002/11/21 19:56:00 sponnamb noship $ */

PROCEDURE create_merge_batch (
    p_api_version                       IN  NUMBER,
    p_init_msg_list                     IN  VARCHAR2:= FND_API.G_FALSE,
    p_commit                            IN  VARCHAR2:= FND_API.G_FALSE,
    p_batch_name                        IN  VARCHAR2,
    p_batch_commit                      IN VARCHAR2,
    p_batch_delete                      IN VARCHAR2,
    p_merge_reason_code                 IN VARCHAR2,
    x_return_status                    OUT NOCOPY  VARCHAR2,
    x_msg_count                        OUT NOCOPY  NUMBER,
    x_msg_data                         OUT NOCOPY  VARCHAR2,
    x_batch_id                         OUT NOCOPY  NUMBER,
    p_validation_level                  IN  NUMBER:= FND_API.G_VALID_LEVEL_FULL
);


END HZ_MERGE_BATCH_PUB;

 

/
