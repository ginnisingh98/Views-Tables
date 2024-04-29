--------------------------------------------------------
--  DDL for Package CSL_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_REQUIREMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvreqs.pls 115.9 2002/11/08 14:00:10 asiegers ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSL_REQUIREMENTS_PKG;

 

/
