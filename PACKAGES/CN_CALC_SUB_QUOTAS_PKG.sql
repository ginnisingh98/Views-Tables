--------------------------------------------------------
--  DDL for Package CN_CALC_SUB_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUB_QUOTAS_PKG" AUTHID CURRENT_USER as
/* $Header: cnsbpes.pls 120.1 2005/08/02 17:53:08 ymao noship $ */

--
--
--
-- This Procedure is called to
-- 	1. Insert
-- 	2. Update
-- 	3. Delete
-- Records into Table cn_calc_sub_quotas
--
--
--
Procedure Begin_Record ( P_OPERATION              VARCHAR2,
			 p_calc_sub_quota_id      NUMBER := NULL ,
			 p_calc_sub_batch_id      NUMBER := NULL,
			 p_quota_id               NUMBER := NULL,
			 p_org_id                 NUMBER,
                         P_ATTRIBUTE_CATEGORY     VARCHAR2 := NULL,
                         P_ATTRIBUTE1             VARCHAR2 := NULL,
                         P_ATTRIBUTE2             VARCHAR2 := NULL,
                         P_ATTRIBUTE3             VARCHAR2 := NULL,
                         P_ATTRIBUTE4             VARCHAR2 := NULL,
                         P_ATTRIBUTE5             VARCHAR2 := NULL,
                         P_ATTRIBUTE6             VARCHAR2 := NULL,
			 P_ATTRIBUTE7             VARCHAR2 := NULL,
                         P_ATTRIBUTE8             VARCHAR2 := NULL,
                         P_ATTRIBUTE9             VARCHAR2 := NULL,
                         P_ATTRIBUTE10            VARCHAR2 := NULL,
                         P_ATTRIBUTE11            VARCHAR2 := NULL,
                         P_ATTRIBUTE12            VARCHAR2 := NULL,
                         P_ATTRIBUTE13            VARCHAR2 := NULL,
                         P_ATTRIBUTE14            VARCHAR2 := NULL,
                         P_ATTRIBUTE15            VARCHAR2 := NULL,
                         P_CREATED_BY             NUMBER   := NULL,
                         P_CREATION_DATE          DATE     := NULL,
                         P_LAST_UPDATE_LOGIN      NUMBER   := NULL,
                         P_LAST_UPDATE_DATE       DATE     := NULL,
                         P_LAST_UPDATED_BY        NUMBER   := NULL
  );
end CN_CALC_SUB_QUOTAS_PKG;
 

/
