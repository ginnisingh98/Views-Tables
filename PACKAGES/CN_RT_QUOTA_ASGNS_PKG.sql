--------------------------------------------------------
--  DDL for Package CN_RT_QUOTA_ASGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RT_QUOTA_ASGNS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnplirqas.pls 120.2 2005/07/11 19:59:58 appldev ship $
--
-- Package Name
-- CN_rt_quota_asgns_pkg
-- Purpose
--  Table Handler for cn_rt_quota_asgns
--  FORM
--  BLOCK
--
-- History
-- 10-MAR-99 Kumar Sivasankaran     Created

   /*-------------------------------------------------------------------------*
   |
   | Procedure Begin Record
   |
   *-------------------------------------------------------------------------*/
   PROCEDURE begin_record (
      x_org_id                            NUMBER,
      x_operation                         VARCHAR2,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_rt_quota_asgn_id         IN OUT NOCOPY NUMBER,
      x_calc_formula_id                   NUMBER,
      x_quota_id                          NUMBER,
      x_start_date                        DATE,
      x_end_date                          DATE,
      x_rate_schedule_id                  NUMBER,
      x_attribute_category                VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_program_type                      VARCHAR2,
      x_object_version_number    IN OUT NOCOPY NUMBER
   );

/*-------------------------------------------------------------------------*
 |
 | Procedure Insert_record
 |
 *-------------------------------------------------------------------------*/
   PROCEDURE INSERT_RECORD (
      x_calc_formula_id          IN       NUMBER,
      x_quota_id                 IN       NUMBER
   );

/*-------------------------------------------------------------------------*
 |
 | Procedure Insert_node_record
 |
 *-------------------------------------------------------------------------*/
   PROCEDURE insert_node_record (
      x_calc_formula_id          IN       NUMBER,
      x_quota_id                 IN       NUMBER
   );

/*-------------------------------------------------------------------------*
 |
 | Procedure Delete Record
 |
 *-------------------------------------------------------------------------*/
   PROCEDURE DELETE_RECORD (
      x_quota_id                 IN       NUMBER,
      x_calc_formula_id          IN       NUMBER,
      x_rt_quota_asgn_id         IN       NUMBER
   );
END cn_rt_quota_asgns_pkg;
 

/
