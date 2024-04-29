--------------------------------------------------------
--  DDL for Package AS_JTF_RS_GROUP_MEM_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_JTF_RS_GROUP_MEM_TRG" AUTHID CURRENT_USER as
/* $Header: asxrstgs.pls 120.1 2005/11/24 18:34:41 sumani noship $ */
--
--
-- HISTORY
-- 11/17/00	ACNG     	Created

PROCEDURE Group_Mem_Trigger_Handler(
               x_group_member_id  NUMBER,
               x_new_group_id     NUMBER,
               x_old_group_id     NUMBER,
               x_new_resource_id  NUMBER,
               x_old_resource_id  NUMBER,
               Trigger_Mode       VARCHAR2 );

END AS_JTF_RS_GROUP_MEM_TRG;

 

/
