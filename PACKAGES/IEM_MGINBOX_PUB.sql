--------------------------------------------------------
--  DDL for Package IEM_MGINBOX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MGINBOX_PUB" AUTHID CURRENT_USER as
/* $Header: iemmginboxs.pls 120.3 2005/09/30 13:12 txliu noship $*/
PROCEDURE runInbox (p_api_version_number    IN   NUMBER,
                    p_init_msg_list         IN   VARCHAR2,
                    p_commit                IN   VARCHAR2,
                    p_email_account_id      IN   NUMBER,
                    p_agent_Account_id      IN   NUMBER,
                    p_inb_migration_id      IN   NUMBER,
                    p_outb_migration_id     IN   NUMBER,
				            p_type                  IN   VARCHAR2, --'I' or 'O'
				            p_rerun                 IN   VARCHAR2, --'Y'/'N'
                    x_return_status         OUT NOCOPY  VARCHAR2,
                    x_msg_count             OUT NOCOPY  NUMBER,
                    x_msg_data              OUT NOCOPY  VARCHAR2
                   );

End IEM_MGINBOX_PUB;

 

/
