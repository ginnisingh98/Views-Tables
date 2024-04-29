--------------------------------------------------------
--  DDL for Package CSM_COUNTER_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_COUNTER_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmecnts.pls 120.1 2005/07/22 08:59:23 trajasek noship $ */

--
-- Purpose: Encapsulate various operations on counter.
--          Methods willbe called by workflow engine
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Jayan       05MAy02 Initial Revision
-----------------------------------------------------------
PROCEDURE COUNTER_MDIRTY_D(p_counter_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE COUNTER_MDIRTY_D(p_counter_id IN NUMBER,
                           p_user_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE COUNTER_VALS_MAKE_DIRTY_D_GRP (p_counter_id IN NUMBER,
                                         p_instance_id IN NUMBER,
                                         p_user_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE CTR_MAKE_DIRTY_U_FOREACHUSER(p_counter_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE CTR_MAKE_DIRTY_I_FOREACHUSER(p_counter_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE CTR_VAL_MAKE_DIRTY_FOREACHUSER(p_ctr_grp_log_id cs_counter_grp_log.counter_grp_log_id%type,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE CTR_VAL_MDIRTY_U_FOREACHUSER(p_ctr_grp_log_id cs_counter_grp_log.counter_grp_log_id%type,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE COUNTER_MDIRTY_I(p_counter_id IN NUMBER,
                           p_user_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE COUNTER_VALS_MAKE_DIRTY_I_GRP(p_counter_id IN NUMBER,
                                        p_instance_id IN NUMBER,
                                        p_user_id IN NUMBER,
                                        p_error_msg     OUT NOCOPY    VARCHAR2,
                                        x_return_status IN OUT NOCOPY VARCHAR2);

  END CSM_COUNTER_EVENT_PKG; -- Package spec of CSM_COUNTER_EVENT_PKG

 

/
