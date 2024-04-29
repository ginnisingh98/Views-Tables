--------------------------------------------------------
--  DDL for Package CSM_COUNTER_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_COUNTER_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: csmucvs.pls 120.1 2005/07/25 01:10:54 trajasek noship $ */

-- Generated 6/13/2002 8:09:29 PM from APPS@MOBSVC01.US.ORACLE.COM


PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_COUNTER_VALUES_PKG;



 

/
