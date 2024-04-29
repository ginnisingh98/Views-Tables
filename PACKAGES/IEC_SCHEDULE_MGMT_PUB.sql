--------------------------------------------------------
--  DDL for Package IEC_SCHEDULE_MGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_SCHEDULE_MGMT_PUB" AUTHID CURRENT_USER AS
/* $Header: IECSCHMS.pls 120.1 2006/03/28 09:29:47 hhuang noship $ */

PROCEDURE CopyScheduleEntries
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_src_schedule_id  IN NUMBER,
     p_dest_schedule_id IN NUMBER
   );

PROCEDURE MoveScheduleEntries
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_src_schedule_id  IN NUMBER,
     p_dest_schedule_id IN NUMBER
   );

PROCEDURE PurgeScheduleEntries
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_schedule_id  IN NUMBER
   );

PROCEDURE StopScheduleExecution
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_schedule_id  IN NUMBER
   );

END IEC_SCHEDULE_MGMT_PUB;

 

/
