--------------------------------------------------------
--  DDL for Package PV_PRGM_CONTRACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_CONTRACTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtppcs.pls 120.0 2005/05/27 16:24:34 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_CONTRACTS_PKG
-- Purpose
--
-- History
--         7-MAR-2002    Peter.Nixon         Created
--        30-APR-2002    Peter.Nixon         Modified
--        27-NOV-2002    Karen.Tsao          Replace of COPY with NOCOPY string.
--        28-AUG-2003    Karen.Tsao          Change membership_type to member_type_code.
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


PROCEDURE Insert_Row(
           px_program_contracts_id     IN OUT NOCOPY  NUMBER
          ,p_program_id                        NUMBER
          ,p_geo_hierarchy_id                  NUMBER
          ,p_contract_id                       NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_login                 NUMBER
          ,p_object_version_number             NUMBER
          ,p_member_type_code                  VARCHAR2
          );

PROCEDURE Update_Row(
           p_program_contracts_id              NUMBER
          ,p_program_id                        NUMBER
          ,p_geo_hierarchy_id                  NUMBER
          ,p_contract_id                       NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_last_update_login                 NUMBER
          ,p_object_version_number             NUMBER
          ,p_member_type_code                  VARCHAR2
          );

PROCEDURE Delete_Row(
           p_program_contracts_id              NUMBER
          ,p_object_version_number             NUMBER
          );

PROCEDURE Lock_Row(
           px_program_contracts_id     IN OUT NOCOPY  NUMBER
          ,p_program_id                        NUMBER
          ,p_geo_hierarchy_id                  NUMBER
          ,p_contract_id                       NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_login                 NUMBER
          ,p_member_type_code                  VARCHAR2
          ,px_object_version_number    IN OUT NOCOPY  NUMBER
          );

END PV_PRGM_CONTRACTS_PKG;

 

/
