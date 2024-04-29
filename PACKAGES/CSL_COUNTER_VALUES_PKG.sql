--------------------------------------------------------
--  DDL for Package CSL_COUNTER_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_COUNTER_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvcvas.pls 115.5 2002/11/08 14:00:51 asiegers ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSL_COUNTER_VALUES_PKG;

 

/
