--------------------------------------------------------
--  DDL for Package CSM_GROUP_DOWNLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_GROUP_DOWNLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: csmegrps.pls 120.1 2008/01/25 23:42:43 rsripada noship $ */

PROCEDURE INSERT_MY_GROUP (p_user_id NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_MY_GROUP (p_user_id NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_GROUP_ACC (p_user_id NUMBER
                          , p_group_id NUMBER
                          , p_owner_id NUMBER
                          , p_group_type VARCHAR2
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_GROUP_ACC (p_user_id NUMBER
                          , p_group_id NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_error_message OUT NOCOPY VARCHAR2);

END CSM_GROUP_DOWNLOAD_PVT;

/
