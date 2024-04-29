--------------------------------------------------------
--  DDL for Package IEM_MSG_STAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MSG_STAT_PUB" AUTHID CURRENT_USER as
/* $Header: iemmsgstats.pls 115.1 2003/03/20 15:19:41 gohu noship $*/

PROCEDURE createMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE sendMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    p_autoReplied           IN   VARCHAR2,
    p_agentID               IN   NUMBER,
    p_outBoundMethod        IN   NUMBER,
    p_accountID             IN   NUMBER,
    p_customerID            IN   NUMBER,
    p_contactID             IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE deleteMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE cancelMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE saveMSGStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outBoundMediaID       IN   NUMBER,
    p_inBoundMediaID        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE insertDocUsageStat(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_rt_mediaID            IN   NUMBER,
    p_reply_y_n             IN   VARCHAR2,
    p_kb_doc_ID             IN   NUMBER,
    p_template_y_n          IN   VARCHAR2,
    p_repository            IN   VARCHAR2,
    p_mes_category_ID       IN   NUMBER,
    p_inserted_y_n          IN   VARCHAR2,
    p_top_ranked_intent     IN   VARCHAR2,
    p_top_ranked_intent_ID  IN   NUMBER,
    p_suggested_y_n         IN   VARCHAR2,
    p_in_top_intent_y_n     IN   VARCHAR2,
    p_intent                IN   VARCHAR2,
    p_intent_ID             IN   NUMBER,
    p_intent_score          IN   NUMBER,
    p_intent_rank           IN   NUMBER,
    p_document_rank         IN   NUMBER,
    p_document_score        IN   NUMBER,
    p_email_account_ID      IN   NUMBER,
    p_auto_insert_y_n       IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

END IEM_MSG_STAT_PUB;

 

/
