--------------------------------------------------------
--  DDL for Package ASO_CORE_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CORE_CONTRACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: asopokcs.pls 120.1 2005/06/29 12:37:03 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_CORE_CONTRACTS_PUB
-- Purpose          :
--
-- History          :
-- NOTE             :

-- End of Comments

--
-- Possible values of P_Rel_Type are,
-- CONTRACTISTERMSFORQUOTE: for iStore;
-- CONTRACTNEGOTIATESQUOTE: for Quoting.
--

  PROCEDURE create_contract (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_terms_agreed_flag         IN       VARCHAR2 := fnd_api.g_false,
    p_rel_type                  IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_subject       IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_body          IN       VARCHAR2 := fnd_api.g_miss_char,
    p_party_id                  IN       NUMBER := fnd_api.g_miss_num,
    p_resource_id               IN       NUMBER := fnd_api.g_miss_num,
    p_template_id               IN       NUMBER := fnd_api.g_miss_num,
    p_template_major_version    IN       NUMBER := fnd_api.g_miss_num,
    x_contract_id               OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_contract_number           OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );


-- this procedure is used to update a contract from a quote.

  PROCEDURE update_contract (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_contract_id               IN       NUMBER := fnd_api.g_miss_num,
    p_interaction_subject       IN       VARCHAR2 := fnd_api.g_miss_char,
    p_interaction_body          IN       VARCHAR2 := fnd_api.g_miss_char,
    p_party_id                  IN       NUMBER := fnd_api.g_miss_num,
    p_resource_id               IN       NUMBER := fnd_api.g_miss_num,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );


--
-- Notification type may contain following value,
-- 'CONTRACT_CREATED':  contract is created;
-- 'CONTRACT_UPDATED':  contract is requested to update;
-- 'CONTRACT_CANCELED': contract is canceled;
-- 'CONTRACT_APPROVED': contract is approved;
-- 'CONTRACT_REJECTED': contract is rejected.
--

  PROCEDURE notify_contract_change (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_quote_id                  IN       NUMBER,
    p_notification_type         IN       VARCHAR2,
    p_customer_comments         IN       VARCHAR2 := fnd_api.g_miss_char,
    p_salesrep_email_id         IN       VARCHAR2 := fnd_api.g_miss_char,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );


-- vtariker
  PROCEDURE Check_Customer_Accounts(
    p_init_msg_list     IN            VARCHAR2  := FND_API.G_FALSE,
    p_qte_header_id     IN            NUMBER,
    x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   );
-- vtariker

END aso_core_contracts_pub;

 

/
