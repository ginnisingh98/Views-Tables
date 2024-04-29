--------------------------------------------------------
--  DDL for Package CN_SRP_PAYEE_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYEE_ASSIGNS_PKG" AUTHID CURRENT_USER as
-- $Header: cntspas.pls 120.1 2005/06/10 14:00:50 appldev  $
--
-- Package Name
-- CN_Srp_payee_assigns_PKG
-- Purpose
--  Table Handler for cn_srp_payee_assigns
--  FORM
--  BLOCK
--
-- History
-- 10-JUN-99 Kumar Sivasankaran  	Created

 PROCEDURE Insert_Record
     ( x_srp_payee_assign_id     IN OUT NOCOPY NUMBER
      ,p_srp_quota_assign_id            NUMBER
      ,p_org_id                         NUMBER
      ,p_payee_id		        NUMBER
      ,p_quota_id                       NUMBER
      ,p_salesrep_id	                NUMBER
      ,p_start_date			DATE
      ,p_end_date	                DATE
      ,p_Last_Update_Date               DATE
      ,p_Last_Updated_By                NUMBER
      ,p_Creation_Date                  DATE
      ,p_Created_By                     NUMBER
      ,p_Last_Update_Login              NUMBER);

PROCEDURE Update_Record(
                        p_srp_payee_assign_id            NUMBER
		       ,p_payee_id		         NUMBER
                       ,p_start_date			 DATE
		       ,p_end_date	                 DATE
                       ,p_Last_Update_Date               DATE
                       ,p_Last_Updated_By                NUMBER
                       ,p_Last_Update_Login              NUMBER);

PROCEDURE Delete_Record( p_srp_payee_assign_id           NUMBER );

PROCEDURE Delete_Record(
			 p_srp_quota_assign_id  	 NUMBER
			 ,p_quota_id	       		 NUMBER);

END CN_srp_payee_assigns_PKG;
 

/
