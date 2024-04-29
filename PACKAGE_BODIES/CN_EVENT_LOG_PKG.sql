--------------------------------------------------------
--  DDL for Package Body CN_EVENT_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_EVENT_LOG_PKG" AS
-- $Header: cnsyevlb.pls 115.5 2002/11/21 21:08:28 hlchen ship $


--
-- Public Procedures
--


  PROCEDURE Event_Log (
            X_event_log_id   IN OUT NOCOPY  number,
            X_event_name     IN      varchar2,
            X_form_name      IN      varchar2,
            X_object_id      IN      number,
            X_object_type    IN      varchar2,
            X_object_name    IN      varchar2,
            X_delete_ndays   IN      number)  IS

     X_user_id  NUMBER(15) ;

  BEGIN

  -- Get Current FND User ID.
     X_user_id := FND_GLOBAL.USER_ID ;

  -- Get Next Event Log sequence number.
  -- This is returned to the caller for use in the Notify_Log call.
     SELECT cn_event_log_s.NEXTVAL
     INTO   X_event_log_id
     FROM   sys.dual;

  -- Update Event Log with event information
     INSERT INTO cn_event_log(
                 event_log_id,
                 event_log_date,
                 delete_date,
                 event_name,
                 form_name,
                 user_id,
                 object_id,
                 object_type,
                 object_name)

          VALUES(X_event_log_id,
                 SYSDATE,
                 (SYSDATE+X_delete_ndays),
                 X_event_name,
                 X_form_name,
                 X_user_id,
                 X_object_id,
                 X_object_type,
                 X_object_name) ;

  END Event_Log;



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
            X_delete_ndays     IN   number)  IS

  BEGIN

  -- Update Notify Log with notify information
     INSERT INTO cn_notify_log(
                 notify_log_id,
                 notify_log_date,
                 delete_date,

                 event_log_id,
                 notify_name,
                 notify_action,

                 object_owner_id,
                 object_id,
                 object_type,
                 object_name,

                 status,
                 priority)

          VALUES(cn_notify_log_s.NEXTVAL,
                 SYSDATE,
                 (SYSDATE+X_delete_ndays),

                 X_event_log_id,
                 X_notify_name,
                 X_notify_action,

                 X_object_owner_id,
                 X_object_id,
                 X_object_type,
                 X_object_name,

                 X_status,
                 X_priority) ;

  END Notify_Log;



  PROCEDURE Comp_Plan_Event( X_comp_plan_id   IN   number)  IS

     X_event_log_id    NUMBER(15)   ;
     X_plan_name       cn_comp_plans.name%TYPE;
     X_owner_id        cn_salesreps.assigned_to_user_id%TYPE;
     X_rep_id          cn_salesreps.salesrep_id%TYPE;
     X_rep_name        cn_salesreps.name%TYPE;


     CURSOR A1_cursor  IS
     SELECT sr.salesrep_id, sr.name, sr.assigned_to_user_id
       FROM cn_salesreps sr
      WHERE sr.salesrep_id  IN (SELECT pa.salesrep_id
                                  FROM cn_srp_plan_assigns pa
                                 WHERE pa.comp_plan_id = X_comp_plan_id) ;

  BEGIN

     BEGIN
  	-- Get Comp Plan Name.
     	SELECT name
     	INTO   X_plan_name
     	FROM   cn_comp_plans
     	WHERE  comp_plan_id = X_comp_plan_id ;

     EXCEPTION
	WHEN no_data_found THEN
	-- Prevents ora-err after when called after deletion of plan
	RETURN;
     END;


  -- Log the Event.
     Event_Log( X_event_log_id  =>  X_event_log_id,
                X_event_name    =>  'Comp Plan Changed',
                X_form_name     =>  'Comp Plans' ,
                X_object_id     =>  X_comp_plan_id,
                X_object_type   =>  'Comp Plan',
                X_object_name   =>  X_plan_name ,
                X_delete_ndays  =>  30 ) ;



  -- For each commissions analyst in the A1_cursor group
  -- Log the Notify event.

     OPEN A1_cursor ;
     LOOP
         FETCH A1_cursor
         INTO  X_rep_id, X_rep_name, X_owner_id  ;

         EXIT WHEN A1_cursor%NOTFOUND ;

      -- Log the Notify event.
         Notify_Log( X_event_log_id     =>  X_event_log_id,
                     X_notify_name      =>  'Comp Plan Changed',
                     X_notify_action    =>  'Recalc Salesrep',
                     X_object_owner_id  =>  X_owner_id,
                     X_object_id        =>  X_rep_id,
                     X_object_type      =>  'Salesrep',
                     X_object_name      =>  X_rep_name,
                     X_status           =>  'Incomplete',
                     X_priority         =>  1 ,
                     X_delete_ndays     =>  30 ) ;

     END LOOP ;
     CLOSE A1_cursor ;

  END Comp_Plan_Event ;



END cn_event_log_pkg;

/
