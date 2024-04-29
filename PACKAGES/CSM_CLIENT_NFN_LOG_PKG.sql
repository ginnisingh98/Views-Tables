--------------------------------------------------------
--  DDL for Package CSM_CLIENT_NFN_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CLIENT_NFN_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: csmucnls.pls 120.0.12010000.1 2009/08/03 06:35:56 appldev noship $ */

-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- HBEERAM     29-APR-2009          Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


PROCEDURE INSERT_CLIENT_NFN_LOG_ACC (p_notification_id IN wf_notifications.notification_id%TYPE,
                                    p_user_id   IN fnd_user.user_id%TYPE);
PROCEDURE CLIENT_NFN_LOG_ACC_PROCESSOR(p_user_id IN fnd_user.user_id%TYPE);

PROCEDURE APPLY_CLIENT_CHANGES
         (p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );


END CSM_CLIENT_NFN_LOG_PKG; -- Package spec



/
