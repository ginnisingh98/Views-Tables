--------------------------------------------------------
--  DDL for Package CSL_DEBRIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_DEBRIEF_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvdbls.pls 115.8 2002/11/08 14:00:43 asiegers ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSL_DEBRIEF_PKG;

 

/
