--------------------------------------------------------
--  DDL for Package CSM_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_USER_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuusrs.pls 120.0 2006/05/25 11:47:59 saradhak noship $ */


PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_USER_PKG; -- Package spec

 

/
