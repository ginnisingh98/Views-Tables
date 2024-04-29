--------------------------------------------------------
--  DDL for Package AS_CUSTOM_HOOKS_UHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_CUSTOM_HOOKS_UHK" AUTHID CURRENT_USER as
/* $Header: asxcuhks.pls 120.0 2005/08/05 01:08 subabu noship $ */
PROCEDURE Lead_TOTTAP_Owner_Assignment(
        p_request_id                    IN      NUMBER,
        p_worker_id                     IN      NUMBER,
        x_return_status                 IN OUT  NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2);

PROCEDURE Oppty_TOTTAP_Owner_Assignment(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    p_request_id            IN      NUMBER,
    p_worker_id             IN      NUMBER,
    x_return_status         OUT  NOCOPY   VARCHAR2,
    x_msg_count             OUT  NOCOPY   NUMBER,
    x_msg_data              OUT  NOCOPY   VARCHAR2);

/*** Need to verify from PMs. This is now redundant given the additional where clauses allowed in TAP ***/
/**
PROCEDURE ATA_Pre(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    p_param1                IN      VARCHAR2,
    p_param2                IN      VARCHAR2,
    p_param3                IN      VARCHAR2,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);

PROCEDURE ATA_Post(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    p_param1                IN      VARCHAR2,
    p_param2                IN      VARCHAR2,
    p_param3                IN      VARCHAR2,
    p_request_id            IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);
**/
END AS_CUSTOM_HOOKS_UHK;

 

/
