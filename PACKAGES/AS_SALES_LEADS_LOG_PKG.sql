--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: asxtslas.pls 115.8 2002/12/18 22:29:28 solin ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEADS_LOG_PVT
-- Purpose          : Sales activity log management
-- NOTE             :
-- History          : 07/07/2000 CDESANTI  Created.

PROCEDURE Insert_Row( px_log_id                  IN OUT NOCOPY NUMBER,
                      p_sales_lead_id                   NUMBER,
                      p_created_by                      NUMBER,
                      p_creation_date                   DATE,
                      p_last_updated_by                 NUMBER,
                      p_last_update_date                DATE,
                      p_last_update_login               NUMBER,
                      p_request_id                      NUMBER,
                      p_program_application_id          NUMBER,
                      p_program_id                      NUMBER,
                      p_program_update_date             DATE,
                      p_status_code                     VARCHAR2,
                      p_assign_to_person_id             NUMBER,
                      p_assign_to_salesforce_id         NUMBER,
                      p_reject_reason_code              VARCHAR2,
                      p_assign_sales_group_id           NUMBER,
                      p_lead_rank_id                    NUMBER,
                      p_qualified_flag                  VARCHAR2,
                      p_category			VARCHAR2,
                      p_manual_rank_flag		VARCHAR2 := NULL
                      );

PROCEDURE Lock_Row(   p_log_id                          NUMBER,
                      p_sales_lead_id                   NUMBER,
                      p_created_by                      NUMBER,
                      p_creation_date                   DATE,
                      p_last_updated_by                 NUMBER,
                      p_last_update_date                DATE,
                      p_last_update_login               NUMBER,
                      p_request_id                      NUMBER,
                      p_program_application_id          NUMBER,
                      p_program_id                      NUMBER,
                      p_program_update_date             DATE,
                      p_status_code                     VARCHAR2,
                      p_assign_to_person_id             NUMBER,
                      p_assign_to_salesforce_id         NUMBER,
                      p_reject_reason_code              VARCHAR2,
                      p_assign_sales_group_id           NUMBER,
                      p_lead_rank_id                    NUMBER,
                      p_qualified_flag                  VARCHAR2,
                      p_category			VARCHAR2,
                      p_manual_rank_flag		VARCHAR2
                      );


PROCEDURE Update_Row( p_log_id                          NUMBER,
                      p_sales_lead_id                   NUMBER,
                      p_created_by                      NUMBER,
                      p_creation_date                   DATE,
                      p_last_updated_by                 NUMBER,
                      p_last_update_date                DATE,
                      p_last_update_login               NUMBER,
                      p_request_id                      NUMBER,
                      p_program_application_id          NUMBER,
                      p_program_id                      NUMBER,
                      p_program_update_date             DATE,
                      p_status_code                     VARCHAR2,
                      p_assign_to_person_id             NUMBER,
                      p_assign_to_salesforce_id         NUMBER,
                      p_reject_reason_code              VARCHAR2,
                      p_assign_sales_group_id           NUMBER,
                      p_lead_rank_id                    NUMBER,
                      p_qualified_flag                  VARCHAR2,
                      p_category			VARCHAR2,
                      p_manual_rank_flag		VARCHAR2
                      );


PROCEDURE Delete_Row(p_log_id  NUMBER);


END AS_SALES_LEADS_LOG_PKG;

 

/
