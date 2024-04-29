--------------------------------------------------------
--  DDL for Package CSL_MATERIAL_TRANSACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MATERIAL_TRANSACTION_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvmmts.pls 115.6 2002/11/08 14:00:30 asiegers ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSL_MATERIAL_TRANSACTION_PKG;

 

/
