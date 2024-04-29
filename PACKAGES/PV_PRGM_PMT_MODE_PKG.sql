--------------------------------------------------------
--  DDL for Package PV_PRGM_PMT_MODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_PMT_MODE_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtppms.pls 120.0 2005/05/27 16:00:02 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_PMT_MODE_PKG
-- Purpose
--
-- History
--         26-APR-2002    Peter.Nixon         Created
--         30-APR-2002    Peter.Nixon         Modified
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


PROCEDURE Insert_Row(
           px_program_payment_mode_id    IN OUT NOCOPY NUMBER
          ,p_program_id                         NUMBER
          ,p_geo_hierarchy_id                   NUMBER
          ,p_mode_of_payment                    VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
	  ,p_mode_type                    VARCHAR2
          );

PROCEDURE Update_Row(
           p_program_payment_mode_id            NUMBER
          ,p_program_id                         NUMBER
          ,p_geo_hierarchy_id                   NUMBER
          ,p_mode_of_payment                    VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
	  ,p_mode_type                    VARCHAR2
          );

PROCEDURE Delete_Row(
           p_program_payment_mode_id            NUMBER
          ,p_object_version_number              NUMBER
          );

PROCEDURE Lock_Row(
           px_program_payment_mode_id   IN OUT NOCOPY  NUMBER
          ,p_program_id                         NUMBER
          ,p_geo_hierarchy_id                   NUMBER
          ,p_mode_of_payment                    VARCHAR2
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,px_object_version_number     IN OUT NOCOPY  NUMBER
	  ,p_mode_type                    VARCHAR2
          );

END PV_PRGM_PMT_MODE_PKG;

 

/
