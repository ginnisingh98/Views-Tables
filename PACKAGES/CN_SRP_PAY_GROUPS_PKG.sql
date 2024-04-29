--------------------------------------------------------
--  DDL for Package CN_SRP_PAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAY_GROUPS_PKG" AUTHID CURRENT_USER as
-- $Header: cnpgrats.pls 120.1 2005/08/25 02:16:03 sjustina noship $
--
-- Package Name
-- CN_srp_pay_groups_pkg
-- Purpose
--  Table Handler for cn_srp_pay_groups
--  FORM 	CNPGRP
--  BLOCK	srp_pay_groups
--
-- History
-- 11-May-99	Renu Chintalapati	Created
/*-------------------------------------------------------------------------*
 |
 | Procedure Begin Record
 |
 *-------------------------------------------------------------------------*/
 PROCEDURE Begin_Record(
		        x_Operation		         VARCHAR2
               	       ,x_srp_pay_group_id     	  IN OUT NOCOPY NUMBER
                       ,x_salesrep_id          		 NUMBER
		       ,x_pay_group_id 			 NUMBER
                       ,x_start_date		         VARCHAR2
                       ,x_end_date	                 VARCHAR2
                       ,x_lock_flag                      VARCHAR2
		       ,x_role_pay_group_id              NUMBER
		       ,x_org_id                         NUMBER
                       ,x_attribute_category             VARCHAR2
                       ,x_attribute1                     VARCHAR2
                       ,x_attribute2                     VARCHAR2
                       ,x_attribute3                     VARCHAR2
                       ,x_attribute4                     VARCHAR2
                       ,x_attribute5                     VARCHAR2
                       ,x_attribute6                     VARCHAR2
                       ,x_attribute7                     VARCHAR2
                       ,x_attribute8                     VARCHAR2
                       ,x_attribute9                     VARCHAR2
                       ,x_attribute10                    VARCHAR2
                       ,x_attribute11                    VARCHAR2
                       ,x_attribute12                    VARCHAR2
                       ,x_attribute13                    VARCHAR2
                       ,x_attribute14                    VARCHAR2
                       ,x_attribute15                    VARCHAR2
                       ,x_Created_By                     NUMBER
                       ,x_Creation_Date                  DATE
                       ,x_Last_Updated_By                NUMBER
                       ,x_Last_Update_Date               DATE
                       ,x_Last_Update_Login              NUMBER
                       ,x_object_version_number    IN OUT NOCOPY      NUMBER);

END CN_SRP_PAY_GROUPS_PKG;
 

/
