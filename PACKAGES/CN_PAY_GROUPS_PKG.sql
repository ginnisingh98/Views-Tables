--------------------------------------------------------
--  DDL for Package CN_PAY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_GROUPS_PKG" AUTHID CURRENT_USER as
-- $Header: cnpgrpts.pls 120.3 2005/07/26 02:36:29 sjustina ship $

/*-------------------------------------------------------------------------*
 |
 | Procedure Begin Record
 |
 *-------------------------------------------------------------------------*/
 PROCEDURE Begin_Record(
                      x_Operation		                 VARCHAR2
		               ,x_Rowid                   IN OUT NOCOPY VARCHAR2
               	       ,x_pay_group_id         	  IN OUT NOCOPY NUMBER
                       ,x_name              		     VARCHAR2
		               ,x_period_set_name		         VARCHAR2
                       ,x_period_type                    VARCHAR2
                       ,x_start_date		             DATE
                       ,x_end_date	                     DATE
                       ,x_pay_group_description          VARCHAR2
	                   ,x_period_set_id                  NUMBER
		               ,x_period_type_id                 NUMBER
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
                       ,x_Program_Type			         VARCHAR2
                       ,x_object_version_number    OUT   NOCOPY NUMBER
                       ,x_org_id                         NUMBER
               );

END CN_PAY_GROUPS_PKG;
 

/
