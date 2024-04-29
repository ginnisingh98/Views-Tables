--------------------------------------------------------
--  DDL for Package IEU_NEXT_WORK_IEUSCPOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_NEXT_WORK_IEUSCPOP" AUTHID CURRENT_USER AS
/* $Header: IEUGNWDS.pls 115.3 2003/12/31 20:15:29 fsuthar noship $ */

TYPE IEU_WR_ITEM_DATA_REC is RECORD
(
   WORK_ITEM_ID              NUMBER(15),
   WORKITEM_OBJ_CODE         VARCHAR2(30),
   WORKITEM_PK_ID            NUMBER(15),
   PRIORITY_LEVEL            NUMBER(3),
   DUE_DATE                  DATE,
   OWNER_ID                  NUMBER,
   OWNER_TYPE                VARCHAR2(25),
   ASSIGNEE_ID               NUMBER,
   ASSIGNEE_TYPE             VARCHAR2(25),
   SOURCE_OBJECT_TYPE_CODE   VARCHAR2(30),
   RESCHEDULE_TIME           DATE,
   WS_ID                     NUMBER,
   DISTRIBUTION_STATUS_ID    NUMBER,
   WORK_ITEM_NUMBER          VARCHAR2(64)
);

TYPE IEU_WR_ITEM_DATA IS
TABLE OF IEU_WR_ITEM_DATA_REC INDEX BY BINARY_INTEGER;

TYPE l_get_work IS REF CURSOR;

PROCEDURE EXECUTE_NEXT_WORK_PROC
(  p_resource_id  IN  number,
   p_ws_id_str    IN  VARCHAR2,
   p_disp_cnt     IN  number,
   x_wr_item_data_list IN OUT nocopy IEU_NEXT_WORK_IEUSCPOP.IEU_WR_ITEM_DATA
);

procedure WORK_SOURCE_PROFILE_ENABLED
(p_name IN varchar2,
p_user_id IN number,
p_responsibility_id IN number,
p_application_id IN number,
x_enabled_flag out nocopy varchar2);

END IEU_NEXT_WORK_IEUSCPOP;

 

/
