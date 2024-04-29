--------------------------------------------------------
--  DDL for Package CN_PMT_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMT_PLANS_PKG" AUTHID CURRENT_USER as
-- $Header: cnpplnts.pls 120.2 2005/10/06 00:38:38 raramasa ship $

PROCEDURE Begin_Record(
		        x_Operation 	           VARCHAR2
		       ,x_Rowid              	   IN OUT NOCOPY VARCHAR2
                       ,x_org_id                    cn_pmt_plans.org_id%TYPE
               	       ,x_pmt_plan_id	           IN OUT NOCOPY NUMBER
                       ,x_name              	   cn_pmt_plans.name%TYPE
                       ,x_minimum_amount           cn_pmt_plans.minimum_amount%TYPE
                       ,x_maximum_amount	   cn_pmt_plans.maximum_amount%TYPE
                       ,x_min_rec_flag	           cn_pmt_plans.min_rec_flag%TYPE
                       ,x_max_rec_flag		   cn_pmt_plans.max_rec_flag%TYPE
		       ,x_max_recovery_amount	   cn_pmt_plans.max_recovery_amount%TYPE
		       ,x_credit_type_id	   cn_pmt_plans.credit_type_id%TYPE
		       ,x_pay_interval_type_id     cn_pmt_plans.pay_interval_type_id%TYPE
                       ,x_start_date		   cn_pmt_plans.start_date%TYPE
                       ,x_end_date		   cn_pmt_plans.end_date%TYPE
                       ,x_object_version_number    IN OUT NOCOPY cn_pmt_plans.object_version_number%TYPE
                       ,x_recoverable_interval_type_id cn_pmt_plans.recoverable_interval_type_id%TYPE := NULL
                       ,x_pay_against_commission   cn_pmt_plans.pay_against_commission%TYPE := NULL
                       ,x_attribute_category       cn_pmt_plans.attribute_category%TYPE
                       ,x_attribute1               cn_pmt_plans.attribute1%TYPE
                       ,x_attribute2               cn_pmt_plans.attribute2%TYPE
                       ,x_attribute3               cn_pmt_plans.attribute3%TYPE
                       ,x_attribute4               cn_pmt_plans.attribute4%TYPE
                       ,x_attribute5               cn_pmt_plans.attribute5%TYPE
                       ,x_attribute6               cn_pmt_plans.attribute6%TYPE
                       ,x_attribute7               cn_pmt_plans.attribute7%TYPE
                       ,x_attribute8               cn_pmt_plans.attribute8%TYPE
                       ,x_attribute9               cn_pmt_plans.attribute9%TYPE
                       ,x_attribute10              cn_pmt_plans.attribute10%TYPE
                       ,x_attribute11              cn_pmt_plans.attribute11%TYPE
                       ,x_attribute12              cn_pmt_plans.attribute12%TYPE
                       ,x_attribute13              cn_pmt_plans.attribute13%TYPE
                       ,x_attribute14              cn_pmt_plans.attribute14%TYPE
                       ,x_attribute15              cn_pmt_plans.attribute15%TYPE
                       ,x_Created_By               cn_pmt_plans.created_by%TYPE
                       ,x_Creation_Date            cn_pmt_plans.creation_date%TYPE
                       ,x_Last_Updated_By          cn_pmt_plans.last_updated_by%TYPE
                       ,x_Last_Update_Date         cn_pmt_plans.last_update_date%TYPE
                       ,x_Last_Update_Login        cn_pmt_plans.last_update_login%TYPE
                       ,x_Program_Type		   VARCHAR2
                       ,x_Payment_Group_Code       cn_pmt_plans.payment_group_code%TYPE
                        );


END CN_PMT_PLANS_PKG;
 

/
