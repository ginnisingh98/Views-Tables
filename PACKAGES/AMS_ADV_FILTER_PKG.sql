--------------------------------------------------------
--  DDL for Package AMS_ADV_FILTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADV_FILTER_PKG" AUTHID CURRENT_USER AS
/* $Header: amstadfs.pls 120.1 2005/06/27 05:39:23 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ADV_FILTER_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Insert_Row(
          px_query_param_id  IN OUT NOCOPY    NUMBER,
          p_query_id                   NUMBER,
          p_parameter_name             VARCHAR2,
          p_parameter_type             VARCHAR2,
          p_parameter_value            VARCHAR2,
          p_parameter_condition        VARCHAR2,
          p_parameter_sequence         NUMBER,
          p_created_by                 NUMBER,
          p_last_updated_by            NUMBER,
          p_last_update_date           DATE,
          p_last_update_login          NUMBER,
          p_security_group_id          NUMBER
                     );

PROCEDURE Update_Row(
          px_query_param_id         NUMBER,
          p_query_id                NUMBER,
          p_parameter_name          VARCHAR2,
          p_parameter_type          VARCHAR2,
          p_parameter_value         VARCHAR2,
          p_parameter_condition     VARCHAR2,
          p_parameter_sequence      NUMBER,
          p_last_updated_by         NUMBER,
          p_last_update_date        DATE,
          p_last_update_login       NUMBER,
          p_security_group_id       NUMBER
                 );

PROCEDURE Delete_Row(
    p_query_param_id NUMBER);

END AMS_ADV_FILTER_PKG ;

 

/
