--------------------------------------------------------
--  DDL for Package CN_CALC_SUB_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUB_ENTRIES_PKG" AUTHID CURRENT_USER AS
/* $Header: cnsbbtes.pls 120.2 2005/08/08 10:04:53 ymao ship $ */

--
--
--
-- This Procedure is called to
-- 	1. Insert
-- 	2. Update
-- 	3. Delete
-- Records into Table cn_calc_submission_entries
--
--
--
Procedure Begin_Record ( P_OPERATION              VARCHAR2,
			 p_calc_sub_entry_id      NUMBER := NULL,
			 p_calc_sub_batch_id      NUMBER := NULL,
			 p_salesrep_id            NUMBER := NULL,
			 p_hierarchy_flag         VARCHAR2 := NULL,
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



  --+
  -- Procedure Name
  --  get_calc_sub_entry_id
  -- Scope
  --   public
  -- Purpose
  --   get the calculation type for this physical batch
  --   state.
  -- History
  --   10-JUL-98	Richard Jin		Created
  --+
  FUNCTION get_calc_sub_entry_id RETURN NUMBER;

--
--
--
END cn_calc_sub_entries_pkg;
 

/
