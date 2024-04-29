--------------------------------------------------------
--  DDL for Package CSL_WF_NOTIFICATION_AT_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_WF_NOTIFICATION_AT_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslwaacs.pls 115.3 2002/11/08 13:59:54 asiegers ship $ */

PROCEDURE INSERT_NOTIFICATION_ATTRIBUTE(
                 p_notification_id IN NUMBER,
	  p_name IN VARCHAR2
	  );

PROCEDURE Insert_All_ACC_Records(
                 p_resource_id     IN  NUMBER,
                 x_return_status   OUT NOCOPY VARCHAR2
                 );

PROCEDURE Delete_All_ACC_Records(
                 p_resource_id     IN  NUMBER,
                 x_return_status   OUT NOCOPY VARCHAR2
                 );

END CSL_WF_NOTIFICATION_AT_ACC_PKG;

 

/
