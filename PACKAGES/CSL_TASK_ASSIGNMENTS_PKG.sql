--------------------------------------------------------
--  DDL for Package CSL_TASK_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_TASK_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvtass.pls 115.7 2003/08/28 05:05:07 vekrishn ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2;

END CSL_TASK_ASSIGNMENTS_PKG;

 

/
