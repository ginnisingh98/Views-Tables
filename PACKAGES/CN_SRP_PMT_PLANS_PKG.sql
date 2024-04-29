--------------------------------------------------------
--  DDL for Package CN_SRP_PMT_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PMT_PLANS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntspps.pls 120.1 2005/06/16 15:07:11 appldev  $ */
--
-- Package Name
-- CN_SRP_PMT_PLANS_PKG
-- Purpose
--  Table Handler for CN_SRP_PMT_PLANS
--  FORM 	CNSRMT
--  BLOCK	SRP_PMT_PLAN
--
-- History
-- 26-May-99	Angela Chung	Created
-- 01-AUG-01    Kumar Sivankaran Added Object Version Number
--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
-- *-------------------------------------------------------------------------*/
PROCEDURE insert_row
   (x_srp_pmt_plan_id           IN OUT NOCOPY NUMBER
    ,x_pmt_plan_id              IN NUMBER
    ,x_salesrep_id              IN NUMBER
    ,x_org_id                   IN NUMBER
    ,x_role_id                  IN NUMBER
    ,x_credit_type_id           IN NUMBER
    ,x_start_date	        DATE
    ,x_end_date	                DATE
    ,x_minimum_amount           IN NUMBER
    ,x_maximum_amount           IN NUMBER
    ,x_max_recovery_amount      IN NUMBER
    ,x_attribute_category       VARCHAR2	:= NULL
    ,x_attribute1               VARCHAR2	:= NULL
    ,x_attribute2               VARCHAR2	:= NULL
    ,x_attribute3               VARCHAR2	:= NULL
    ,x_attribute4               VARCHAR2	:= NULL
    ,x_attribute5               VARCHAR2	:= NULL
    ,x_attribute6               VARCHAR2	:= NULL
    ,x_attribute7               VARCHAR2	:= NULL
    ,x_attribute8               VARCHAR2        := NULL
    ,x_attribute9               VARCHAR2	:= NULL
    ,x_attribute10              VARCHAR2	:= NULL
    ,x_attribute11              VARCHAR2	:= NULL
    ,x_attribute12              VARCHAR2	:= NULL
    ,x_attribute13              VARCHAR2	:= NULL
    ,x_attribute14              VARCHAR2	:= NULL
    ,x_attribute15              VARCHAR2	:= NULL
    ,x_Created_By               NUMBER
    ,x_Creation_Date            DATE
    ,x_Last_Updated_By          NUMBER
    ,x_Last_Update_Date         DATE
    ,x_Last_Update_Login        NUMBER
    ,x_srp_role_id              NUMBER          := NULL
    ,x_role_pmt_plan_id         NUMBER          := NULL
    ,x_lock_flag                VARCHAR2        := NULL
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--	Lock_row
-- Purpose
--    Lock db row after form record is changed
-- Notes
--    Only called from the form
-- *-------------------------------------------------------------------------*/
PROCEDURE lock_row
   ( x_srp_pmt_plan_id          NUMBER
     ,x_pmt_plan_id             NUMBER
     ,x_salesrep_id             NUMBER
     ,x_org_id                  NUMBER
     ,x_role_id                 NUMBER
     ,x_credit_type_id          NUMBER
     ,x_start_date		DATE
     ,x_end_date		DATE
     ,x_minimum_amount           NUMBER
     ,x_maximum_amount           NUMBER
     ,x_max_recovery_amount      NUMBER
     ,x_attribute_category       VARCHAR2	:= NULL
     ,x_attribute1               VARCHAR2	:= NULL
     ,x_attribute2               VARCHAR2	:= NULL
     ,x_attribute3               VARCHAR2	:= NULL
     ,x_attribute4               VARCHAR2	:= NULL
     ,x_attribute5               VARCHAR2	:= NULL
     ,x_attribute6               VARCHAR2	:= NULL
     ,x_attribute7               VARCHAR2	:= NULL
     ,x_attribute8               VARCHAR2       := NULL
     ,x_attribute9               VARCHAR2	:= NULL
     ,x_attribute10              VARCHAR2	:= NULL
     ,x_attribute11              VARCHAR2	:= NULL
     ,x_attribute12              VARCHAR2	:= NULL
     ,x_attribute13              VARCHAR2	:= NULL
     ,x_attribute14              VARCHAR2	:= NULL
     ,x_attribute15              VARCHAR2	:= NULL
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--   Update Record
-- Purpose
--   To Update the Srp Payment Plan Assign
--
-- *-------------------------------------------------------------------------*/
PROCEDURE update_row (
    x_srp_pmt_plan_id        	NUMBER
    ,x_pmt_plan_id              NUMBER   	:= fnd_api.g_miss_num
    ,x_salesrep_id              NUMBER   	:= fnd_api.g_miss_num
    ,x_org_id                   NUMBER   	:= fnd_api.g_miss_num
    ,x_role_id                  NUMBER   	:= fnd_api.g_miss_num
    ,x_credit_type_id           NUMBER  	:= fnd_api.g_miss_num
    ,x_start_date		DATE		:= fnd_api.g_miss_date
    ,x_end_date		        DATE		:= fnd_api.g_miss_date
    ,x_minimum_amount           NUMBER   	:= fnd_api.g_miss_num
    ,x_maximum_amount           NUMBER   	:= fnd_api.g_miss_num
    ,x_max_recovery_amount      NUMBER   	:= fnd_api.g_miss_num
    ,x_attribute_category       VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute1               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute2               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute3               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute4               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute5               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute6               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute7               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute8               VARCHAR2       	:= fnd_api.g_miss_char
    ,x_attribute9               VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute10              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute11              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute12              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute13              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute14              VARCHAR2	:= fnd_api.g_miss_char
    ,x_attribute15              VARCHAR2	:= fnd_api.g_miss_char
    ,x_Last_Updated_By          NUMBER
    ,x_Last_Update_Date         DATE
    ,x_Last_Update_Login        NUMBER
    ,x_object_version_number	NUMBER
    ,x_lock_flag                VARCHAR2        := fnd_api.g_miss_char);

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Delete_row
-- Purpose
--    Delete the Srp Payment Plan Assign
--*-------------------------------------------------------------------------*/
PROCEDURE Delete_row( x_srp_pmt_plan_id     NUMBER );

END CN_SRP_PMT_PLANS_PKG;
 

/
