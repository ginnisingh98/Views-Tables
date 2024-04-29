--------------------------------------------------------
--  DDL for Package CSM_COUNTER_READING_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_COUNTER_READING_EVENT_PKG" 
/* $Header: csmecrds.pls 120.0 2006/06/30 12:41:26 trajasek noship $*/
AUTHID CURRENT_USER AS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);

PROCEDURE COUNTER_VALUE_ACC_INS(p_counter_value_id IN NUMBER,p_counter_id IN NUMBER, p_error_msg OUT NOCOPY VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE COUNTER_VALUE_ACC_UPD(p_counter_value_id IN NUMBER,p_counter_id IN NUMBER, p_error_msg OUT NOCOPY VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2);

END CSM_COUNTER_READING_EVENT_PKG; -- Package spec

 

/
