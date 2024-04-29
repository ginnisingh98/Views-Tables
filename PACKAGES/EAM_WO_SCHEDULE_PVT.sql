--------------------------------------------------------
--  DDL for Package EAM_WO_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVSCDS.pls 120.2 2005/08/08 07:49:39 cboppana noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSCDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_SCHEDULE_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

 TYPE  shift_date_rec IS RECORD
    ( shift_date                DATE,
      shift_num                 NUMBER,
      seq_num                   NUMBER,
      calendar_code          VARCHAR2(10));

    TYPE shift_date_tab IS TABLE OF shift_date_rec
           INDEX BY BINARY_INTEGER;
    shift_date_tbl  shift_date_tab;

    TYPE op_res_info_rec IS RECORD
      ( op_seq_num              NUMBER,
        op_seq_id               NUMBER,
        op_start_date           DATE,
        op_completion_date      DATE,
        op_completed            VARCHAR2(1),
        res_seq_num             NUMBER,
        res_sch_num             NUMBER,
        res_id                  NUMBER,
        res_start_date          DATE,
        res_completion_date     DATE,
        assigned_units          NUMBER,
        capacity_units          NUMBER,
        usage_rate              NUMBER,
        scheduled_flag          NUMBER,
        avail_24_hrs_flag       NUMBER
      );

    TYPE op_scd_seq_rec IS RECORD
     (  level                   NUMBER,
        op_seq_num              NUMBER,
        op_start_date           DATE,
        op_completion_date      DATE
     );

    TYPE op_res_sft_rec IS RECORD
      (op_seq_num               NUMBER,
       res_seq_num              NUMBER,
       shift_num                NUMBER,
       from_time                NUMBER,
       to_time                  NUMBER
      );

    TYPE op_res_info_tab IS TABLE OF op_res_info_rec
    INDEX BY BINARY_INTEGER;

    op_res_info_tbl op_res_info_tab;

    TYPE op_scd_seq_tab IS TABLE OF op_scd_seq_rec

    INDEX BY BINARY_INTEGER;

    op_scd_seq_tbl op_scd_seq_tab;

    TYPE dep_op_seq_num_tab is TABLE OF wip_operations.operation_seq_num%TYPE
    INDEX BY BINARY_INTEGER;

    dep_op_seq_num_tbl dep_op_seq_num_tab;

    TYPE op_res_sft_tab IS TABLE OF op_res_sft_rec
    INDEX BY BINARY_INTEGER;

    op_res_sft_tbl  op_res_sft_tab;

   TYPE res_sft_rec IS RECORD
      (shift_num           NUMBER,
       from_time           NUMBER,
       to_time             NUMBER
      );

  TYPE l_res_sft_tab IS TABLE OF res_sft_rec
           INDEX BY BINARY_INTEGER;
     l_res_sft_tbl  l_res_sft_tab;

/* procedure for identifying that current date is workday or not */
 PROCEDURE EAM_GET_SHIFT_WKDAYS
    ( p_curr_date         IN    DATE,
      p_calendar_code     IN    VARCHAR2,
      p_shift_num         IN    NUMBER,
      p_schedule_dir      IN    NUMBER,
      x_wkday_flag        OUT NOCOPY   NUMBER,
      x_error_message     OUT NOCOPY   VARCHAR2,
      x_return_status     OUT NOCOPY   VARCHAR2
    );

 /* Procedure SCHEDULE_OPERATIONS is for scheduling the operations cosidering the prior and next
 dependencies  for forward and backward schedule. */
 PROCEDURE SCHEDULE_OPERATIONS
    ( p_organization_id            IN    NUMBER,
      p_wip_entity_id     IN    NUMBER,
      p_start_date        IN OUT NOCOPY DATE,
      p_completion_date   IN OUT NOCOPY DATE,
      p_hour_conv         IN    NUMBER,
      p_calendar_code     IN    VARCHAR2,
      p_excetion_set_id   IN    NUMBER,
      p_validation_level  IN    NUMBER,
      p_res_usage_tbl     IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_commit            IN    VARCHAR2,
      x_error_message     OUT NOCOPY   VARCHAR2,
      x_return_status     OUT NOCOPY   VARCHAR2
    );

 PROCEDURE SCHEDULE_WO
    ( p_organization_id            IN    NUMBER,
      p_wip_entity_id     IN    NUMBER,
      p_start_date        IN OUT NOCOPY DATE,
      p_completion_date   IN OUT NOCOPY DATE,
      p_validation_level  IN    NUMBER DEFAULT 0,
      p_commit            IN    VARCHAR2 := FND_API.G_FALSE,
      x_error_message     OUT NOCOPY   VARCHAR2,
      x_return_status     OUT NOCOPY   VARCHAR2
    );

END EAM_WO_SCHEDULE_PVT;


 

/
