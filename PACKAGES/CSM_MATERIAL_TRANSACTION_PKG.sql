--------------------------------------------------------
--  DDL for Package CSM_MATERIAL_TRANSACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MATERIAL_TRANSACTION_PKG" AUTHID CURRENT_USER AS
/* $Header: csmvmmts.pls 120.0 2006/02/16 04:23:35 utekumal noship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_MATERIAL_TRANSACTION_PKG;

 

/
