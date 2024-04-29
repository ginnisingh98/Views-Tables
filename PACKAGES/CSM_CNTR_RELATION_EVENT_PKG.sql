--------------------------------------------------------
--  DDL for Package CSM_CNTR_RELATION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CNTR_RELATION_EVENT_PKG" 
/* $Header: csmecrls.pls 120.0 2005/11/23 06:35:12 trajasek noship $*/
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

PROCEDURE COUNTER_RELATION_INS(p_counter_id NUMBER,
                                       p_user_id NUMBER);
--update not yet implemented
--PROCEDURE COUNTER_RELATION_UPD(p_counter_id NUMBER,p_user_id NUMBER);
PROCEDURE COUNTER_RELATION_DEL(p_counter_id NUMBER,
                                       p_user_id NUMBER);

END CSM_CNTR_RELATION_EVENT_PKG; -- Package spec

 

/
