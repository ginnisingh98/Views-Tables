--------------------------------------------------------
--  DDL for Package CN_TRX_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TRX_FACTORS_PKG" AUTHID CURRENT_USER AS
/* $Header: cnplitfs.pls 120.0 2005/07/11 19:42:48 fmburu noship $ */

   /*
Date      Name          Description
----------------------------------------------------------------------------+
15-FEB-95 P Cook  Unit tested
18-APR-95 P Cook  Removed trx_type_id paramater due to replacement of
         cn_trx_types with cn_lookup_codes

Name

Purpose

Notes


*/

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE begin_record(
      x_operation                         VARCHAR2,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_trx_factor_id            IN OUT NOCOPY NUMBER,
      x_object_version_number    IN OUT NOCOPY NUMBER,
      x_event_factor                      NUMBER,
      x_event_factor_old                  NUMBER,
      x_revenue_class_id                  NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_trx_type                          VARCHAR2,
      x_trx_type_name                     VARCHAR2,
      x_program_type                      VARCHAR2,
      x_status_code                       VARCHAR2,
      x_org_id                            NUMBER
      );

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --
   --
   PROCEDURE end_record(
      x_rowid                             VARCHAR2,
      x_trx_factor_id                     NUMBER,
      x_event_factor                      NUMBER,
      x_revenue_class_id                  NUMBER,
      x_quota_id                          NUMBER,
      x_quota_rule_id                     NUMBER,
      x_trx_type_name                     VARCHAR2,
      x_program_type                      VARCHAR2);

   PROCEDURE INSERT_RECORD(x_quota_id NUMBER, x_quota_rule_id NUMBER, x_revenue_class_id NUMBER);

   -- Name
   --
   -- Purpose
   --
   -- Notes
   --  Called on rev class deletion
   --
   PROCEDURE DELETE_RECORD(x_trx_factor_id NUMBER, x_quota_rule_id NUMBER, x_quota_id NUMBER);
END cn_trx_factors_pkg;
 

/
