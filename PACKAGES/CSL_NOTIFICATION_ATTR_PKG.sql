--------------------------------------------------------
--  DDL for Package CSL_NOTIFICATION_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_NOTIFICATION_ATTR_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvnoas.pls 115.2 2002/11/08 14:00:25 asiegers ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSL_NOTIFICATION_ATTR_PKG;

 

/
