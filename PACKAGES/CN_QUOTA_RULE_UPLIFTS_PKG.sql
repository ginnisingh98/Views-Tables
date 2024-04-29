--------------------------------------------------------
--  DDL for Package CN_QUOTA_RULE_UPLIFTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_RULE_UPLIFTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cnpliqrus.pls 120.1 2005/07/11 19:59:42 appldev ship $ */

   /*
   Date      Name          Description
   ----------------------------------------------------------------------------+
   15-FEB-95 S Kumar Unit tested

   Name

   Purpose

   Notes
             Created during 3i changes
   */
     -- Name
     --+
     -- Purpose
     --+
     -- Notes
     --+
     --+
   PROCEDURE begin_record (
      x_operation                         VARCHAR2,
      x_org_id                            NUMBER,
      x_quota_rule_uplift_id     IN OUT NOCOPY NUMBER,
      x_quota_rule_id                     NUMBER,
      x_quota_rule_id_old                 NUMBER,
      x_start_date                        DATE,
      x_start_date_old                    DATE,
      x_end_date                          DATE,
      x_end_date_old                      DATE,
      x_payment_factor                    NUMBER,
      x_payment_factor_old                NUMBER,
      x_quota_factor                      NUMBER,
      x_quota_factor_old                  NUMBER,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_last_update_date                  DATE,
      x_program_type                      VARCHAR2,
      x_status_code                       VARCHAR2,
      x_object_version_number OUT NOCOPY  NUMBER
   );

   -- Name
   --+
   -- Purpose
   --+
   -- Notes
   --+
   --+
   PROCEDURE DELETE_RECORD (
      x_quota_rule_uplift_id              NUMBER,
      x_quota_rule_id                     NUMBER,
      x_quota_id                          NUMBER
   );

   -- Name
   --+
   -- Purpose
   --+
   -- Notes
   --+
   --+
   PROCEDURE end_record (
      x_rowid                             VARCHAR2,
      x_quota_rule_uplift_id              NUMBER,
      x_quota_rule_id                     NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_payment_factor                    NUMBER,
      x_quota_factor                      NUMBER,
      x_program_type                      VARCHAR2
   );
-- Name
--+
-- Purpose
--+
-- Notes
--+
--+
END cn_quota_rule_uplifts_pkg;
 

/
