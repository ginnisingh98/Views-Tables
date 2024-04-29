--------------------------------------------------------
--  DDL for Package CSL_LOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_LOBS_PKG" AUTHID CURRENT_USER AS
/* $Header: cslvlobs.pls 120.0 2005/05/24 17:44:05 appldev noship $ */

PROCEDURE APPLY_CLIENT_CHANGES
        (
         p_user_name     IN VARCHAR2,
         p_tranid        IN NUMBER,
         p_debug_level   IN NUMBER,
         x_return_status IN OUT NOCOPY VARCHAR2
         );
END CSL_LOBS_PKG; -- Package spec


 

/
