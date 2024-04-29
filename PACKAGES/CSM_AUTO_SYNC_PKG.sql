--------------------------------------------------------
--  DDL for Package CSM_AUTO_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_AUTO_SYNC_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuass.pls 120.1.12010000.1 2009/08/03 06:30:29 appldev noship $ */

-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- HBEERAM     29-APR-2009          Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


PROCEDURE INSERT_AUTO_SYNC_ACC (p_id IN NUMBER, p_user_id   IN fnd_user.user_id%TYPE,p_auto_sync_num NUMBER);

PROCEDURE AUTO_SYNC_ACC_PROCESSOR(p_user_id IN fnd_user.user_id%TYPE);

PROCEDURE APPLY_CLIENT_CHANGES
         (p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );


END CSM_AUTO_SYNC_PKG; -- Package spec



/
