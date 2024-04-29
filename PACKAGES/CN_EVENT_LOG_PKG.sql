--------------------------------------------------------
--  DDL for Package CN_EVENT_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_EVENT_LOG_PKG" AUTHID CURRENT_USER AS
-- $Header: cnsyevls.pls 115.4 2002/11/27 23:58:19 fting ship $


--
-- Public Procedures
--

--
-- Procedure Name
--   event_log
-- Purpose
--   Insert a new record in the cn_event_log table.
-- History
--   03-28-95           Amy Erickson            Created
--


  PROCEDURE Event_Log (
            X_event_log_id   IN OUT NOCOPY  number,
            X_event_name     IN      varchar2,
            X_form_name      IN      varchar2,
            X_object_id      IN      number,
            X_object_type    IN      varchar2,
            X_object_name    IN      varchar2,
            X_delete_ndays   IN      number)  ;


--
-- Procedure Name
--   notify_log
-- Purpose
--   Insert a new record in the cn_notify_log table.
-- History
--   03-28-95           Amy Erickson            Created
--


  PROCEDURE Notify_Log (
            X_event_log_id     IN   number,
            X_notify_name      IN   varchar2,
            X_notify_action    IN   varchar2,
            X_object_owner_id  IN   number,
            X_object_id        IN   number,
            X_object_type      IN   varchar2,
            X_object_name      IN   varchar2,
            X_status           IN   varchar2,
            X_priority         IN   number,
            X_delete_ndays     IN   number)  ;


--
-- Procedure Name
--   Comp_Plan_Event
-- Purpose
--   Log a Comp Plan event and the associated Notify records.
-- History
--   04-05-95           Amy Erickson            Created
--

  PROCEDURE Comp_Plan_Event( X_comp_plan_id  IN  number)  ;



END cn_event_log_pkg;

 

/
