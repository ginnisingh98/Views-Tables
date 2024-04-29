--------------------------------------------------------
--  DDL for Package ASO_IBY_FINANCE_CALLBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_IBY_FINANCE_CALLBACK" AUTHID CURRENT_USER AS
/* $Header: asopibys.pls 120.1 2005/06/29 12:36:50 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_IBY_FINANCE_CALLBACK
-- Purpose          :
--
-- History          :
-- NOTE             :

-- End of Comments


--
-- p_tangible_id:         quote header id;
-- p_credit_app_id:       primary Key for the credit application/financing request;
-- p_new_status_category: category of new financing status;
-- p_new_status:          new financing status;
--

  PROCEDURE update_status (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN       NUMBER   := fnd_api.g_miss_num,
    p_tangible_id               IN       NUMBER,
    p_credit_app_id             IN       NUMBER,
    p_new_status_category       IN       VARCHAR2,
    p_new_status                IN       VARCHAR2,
    p_last_update_date          IN       DATE     := fnd_api.g_miss_date,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  );
END aso_iby_finance_callback;

 

/
