--------------------------------------------------------
--  DDL for Package PV_PRGM_BENEFITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_BENEFITS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtppbs.pls 115.8 2003/11/07 06:13:55 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_BENEFITS_PKG
-- Purpose
--
-- History
--         28-FEB-2002    Jessica.Lee         Created
--          1-APR-2002    Peter.Nixon         Modified
--                        Changed benefit_id NUMBER to benefit_code VARCHAR2
--         24-SEP-2003    Karen.Tsao          Modified for 11.5.10
--         02-OCT-2003    Karen.Tsao          Modified for new column responsibility_id
--         06-NOV-2003    Karen.Tsao          Took out column responsibility_id
-- NOTE
--
-- End of Comments
-- ===============================================================


PROCEDURE Insert_Row(
           px_program_benefits_id     IN OUT NOCOPY  NUMBER
          ,p_program_id                       NUMBER
          ,p_benefit_code                     VARCHAR2
          ,p_benefit_id                       NUMBER
          ,p_benefit_type_code                VARCHAR2
          ,p_delete_flag                      VARCHAR2
          ,p_last_update_login                NUMBER
          ,p_last_update_date                 DATE
          ,p_last_updated_by                  NUMBER
          ,p_created_by                       NUMBER
          ,p_creation_date                    DATE
          ,p_object_version_number            NUMBER
          );

PROCEDURE Update_Row(
           p_program_benefits_id              NUMBER
          ,p_program_id                       NUMBER
          ,p_benefit_code                     VARCHAR2
          ,p_benefit_id                       NUMBER
          ,p_benefit_type_code                VARCHAR2
          ,p_delete_flag                      VARCHAR2
          ,p_last_update_login                NUMBER
          ,p_object_version_number            NUMBER
          ,p_last_update_date                 DATE
          ,p_last_updated_by                  NUMBER
          );

PROCEDURE Delete_Row(
           p_program_benefits_id              NUMBER
          ,p_object_version_number            NUMBER
          );

PROCEDURE Lock_Row(
           px_program_benefits_id     IN OUT NOCOPY  NUMBER
          ,p_program_id                       NUMBER
          ,p_benefit_code                     VARCHAR2
          ,p_benefit_id                       NUMBER
          ,p_benefit_type_code                VARCHAR2
          ,p_delete_flag                      VARCHAR2
          ,p_last_update_login                NUMBER
          ,px_object_version_number   IN OUT NOCOPY  NUMBER
          ,p_last_update_date                 DATE
          ,p_last_updated_by                  NUMBER
          ,p_created_by                       NUMBER
          ,p_creation_date                    DATE
          );

END PV_PRGM_BENEFITS_PKG;

 

/
