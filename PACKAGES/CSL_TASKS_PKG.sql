--------------------------------------------------------
--  DDL for Package CSL_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_TASKS_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvtsks.pls 115.11 2002/11/08 13:59:59 asiegers ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSL_TASKS_PKG;

 

/
