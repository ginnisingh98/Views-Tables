--------------------------------------------------------
--  DDL for Package CSM_AUTO_SYNC_NFN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_AUTO_SYNC_NFN_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuasns.pls 120.0.12010000.1 2009/08/03 06:32:40 appldev noship $ */

-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- HBEERAM     29-APR-2009          Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE INSERT_AUTO_SYNC_NFN_ACC (p_notification_id IN wf_notifications.notification_id%TYPE,
                                    p_user_id   IN fnd_user.user_id%TYPE);
PROCEDURE AUTO_SYNC_NFN_ACC_PROCESSOR(p_user_id IN fnd_user.user_id%TYPE);

PROCEDURE APPLY_CLIENT_CHANGES
         (p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );


END CSM_AUTO_SYNC_NFN_PKG; -- Package spec



/