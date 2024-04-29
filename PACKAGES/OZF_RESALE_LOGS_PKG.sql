--------------------------------------------------------
--  DDL for Package OZF_RESALE_LOGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_LOGS_PKG" AUTHID CURRENT_USER as
/* $Header: ozftrlgs.pls 120.1 2005/08/19 14:02:08 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_LOGS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


PROCEDURE Insert_Row(
          px_resale_log_id   IN OUT NOCOPY NUMBER,
          p_resale_id         NUMBER,
          p_resale_id_type    VARCHAR,
          p_error_code    VARCHAR2,
          p_error_message    VARCHAR2,
          p_column_name    VARCHAR2,
          p_column_value    VARCHAR2,
          px_org_id   IN OUT NOCOPY NUMBER);

PROCEDURE Update_Row(
          p_resale_log_id     NUMBER,
          p_resale_id         NUMBER,
          p_resale_id_type    VARCHAR,
          p_error_code    VARCHAR2,
          p_error_message    VARCHAR2,
          p_column_name    VARCHAR2,
          p_column_value    VARCHAR2,
          p_org_id    NUMBER);

PROCEDURE Delete_Row(
    p_RESALE_LOG_ID  NUMBER);
PROCEDURE Lock_Row(
          p_resale_log_id     NUMBER,
          p_resale_id         NUMBER,
          p_resale_id_type    VARCHAR,
          p_error_code    VARCHAR2,
          p_error_message    VARCHAR2,
          p_column_name    VARCHAR2,
          p_column_value    VARCHAR2,
          p_org_id    NUMBER);

END OZF_RESALE_LOGS_PKG;

 

/
