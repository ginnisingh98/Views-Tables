--------------------------------------------------------
--  DDL for Package Body XLA_UPG_VERIFICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_UPG_VERIFICATION_PUB" AS
-- $Header: xlaugval.pkb 120.1 2006/03/29 16:44:20 ksvenkat noship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaugval.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    XLA_UPG_VERIFICATION_PUB                                                |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA package which contains verification scripts to            |
|    check the AX-SLA Upgrade.                                               |
|                                                                            |
| HISTORY                                                                    |
|    27-Mar-06 Koushik VS      Created                                       |
|                                                                            |
+===========================================================================*/
--=============================================================================
--           ****************  declarations  ********************
--=============================================================================


-------------------------------------------------------------------------------
-- declaring global variables
-------------------------------------------------------------------------------

   g_batch_id INTEGER ;
   g_batch_size INTEGER := 30000;
   g_source_application_id NUMBER ;
   g_application_id NUMBER;
   g_validate_complete xla_upg_batches.VALIDATE_COMPLETE_FLAG%TYPE;
   g_crsegvals_complete  xla_upg_batches.CRSEGVALS_COMPLETE_FLAG%TYPE;
-------------------------------------------------------------------------------
-- declaring global pl/sql types
-------------------------------------------------------------------------------

   TYPE t_entity_id IS TABLE OF
      xla_transaction_entities.entity_id%type
   INDEX BY BINARY_INTEGER;
   TYPE t_error_flag     IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   TYPE t_event_id IS TABLE OF
      xla_events.event_id%type
   INDEX BY BINARY_INTEGER;
   TYPE t_header_id IS TABLE OF
      xla_ae_headers.ae_header_id%type
   INDEX BY BINARY_INTEGER;
   TYPE t_line_num IS TABLE OF
      xla_ae_lines.ae_line_num%type
   INDEX BY BINARY_INTEGER;
   TYPE t_seg_value IS TABLE OF
      xla_ae_segment_values.segment_value%type
   INDEX BY BINARY_INTEGER;
   TYPE t_line_count IS TABLE OF
      xla_ae_segment_values.ae_lines_count%type
   INDEX BY BINARY_INTEGER;
   TYPE t_seg_type IS TABLE OF
      xla_ae_segment_values.segment_type_code%type
   INDEX BY BINARY_INTEGER;
   TYPE t_error_id IS TABLE OF
      xla_upg_errors.upg_error_id%type
   INDEX BY BINARY_INTEGER;
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-- The segment type code
C_BAL_SEGMENT                   CONSTANT VARCHAR2(1) := 'B';
C_MGT_SEGMENT                   CONSTANT VARCHAR2(1) := 'M';
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;

C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_UPG_VERIFICATION_PUB';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;


-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'XLA_UPG_VERIFICATION_PUB.trace');
END trace;
--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Entries                                                            |
|                                                                             |
| This routine is called to validate the upgrade.                             |
|                                                                             |
+============================================================================*/

PROCEDURE Validate_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER) IS

     l_log_module     VARCHAR2(240);
BEGIN


        g_application_id        := p_application_id;
        g_source_application_id := p_upgrading_application_id;

        IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
               (p_msg      => 'BEGIN of procedure Validate_Entries'
               ,p_level    => C_LEVEL_PROCEDURE
               ,p_module   =>l_log_module);
        END IF;

        IF g_log_enabled THEN
           l_log_module := C_DEFAULT_MODULE||'.Validate_Entries';
        END IF;

	-- Call to find entities that are not associated with
	-- any application.
	-- and stamp the invalids

	Validate_Application_Entries;

	-- Call to check if Entities are valid
	-- and stamp the invalids

	Validate_Entity_Entries(p_upgrading_application_id
	                       ,p_application_id);

	-- Call to check if Events are valid
	-- and stamp the invalids

	Validate_Event_Entries(p_upgrading_application_id
	                      ,p_application_id);

	-- Call to check if Headers are valid
	-- and stamp the invalids

	Validate_Header_Entries(p_upgrading_application_id
	                       ,p_application_id);

	-- Call to check if Lines are valid
	-- and stamp the invalids

	Validate_Line_Entries(p_upgrading_application_id
	                     ,p_application_id);

	-- Call to check if distribution links are valid
	-- and stamp the invalids

	Validate_Distribution_Entries(p_application_id);

     Populate_Segment_Values (p_application_id => g_application_id);

   COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Validate_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Entries');

END Validate_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Application_Entries                                                |
|                                                                             |
| This routine is called to find out all those entities that are attached     |
| to an application that is not registered with SLA.                          |
|                                                                             |
+============================================================================*/
PROCEDURE Validate_Application_Entries IS

   l_entity_id     t_entity_id;
   l_event_id      t_event_id;
   l_header_id     t_header_id;
   l_line_num      t_line_num;
   l_log_module    VARCHAR2(240);
   l_rowcount      number(15) := 0;

   CURSOR csr_application_exists IS
      select  distinct entity_id
        from  xla_upg_errors
       where  error_level = 'A'
         and application_id = 602
	 and upg_source_application_id = 602;

BEGIN

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Application_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Application_Entries';
   END IF;

   -- Deleting all xla_upg_errors from previous run

   delete from xla_upg_errors
    where application_id = 602
      and upg_source_application_id = 602
      and error_message_name IN ('XLA_UPG_APP_NOT_DEFINED'
                                 ,'XLA_APP_VERIFICATION_RECORD');


      INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
	 (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
	 (SELECT
	 xla_upg_errors_s.nextval
	 ,602
	 ,602
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'A'
	 ,'XLA_UPG_APP_NOT_DEFINED'
         ,entity_id from(select entity_id
                           from xla_transaction_entities_upg xen
                          where NOT EXISTS (SELECT 1
                                              FROM XLA_SUBLEDGERS XS
                               	             WHERE xen.application_id
					          = xs.application_id)));
   COMMIT;

   OPEN csr_application_exists;
   LOOP
      FETCH csr_application_exists
      BULK COLLECT INTO
           l_entity_id
      LIMIT g_batch_size;
      EXIT WHEN l_entity_id.count = 0;

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         UPDATE xla_transaction_entities_upg
	 set    upg_valid_flag = 'A'
	 where  entity_id = l_entity_id(i);

      -- finding out how many rows got inserted/updated.

         l_rowcount := l_rowcount + sql%rowcount;

      -- Updating as invalids all events that are associated with invalid entity.

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         UPDATE xla_events
            set upg_valid_flag = 'B'
	  where entity_id = l_entity_id(i);

      -- Cumilitive number of rows updated.

         l_rowcount := l_rowcount + sql%rowcount;

      -- Updating as invalids all headers that are associated with
      -- events that are associated with invalid entities.

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         UPDATE xla_ae_headers
            set upg_valid_flag = 'C'
	  where entity_id = l_entity_id(i);

      -- Cumilitive number of rows updated.

         l_rowcount := l_rowcount + sql%rowcount;

    COMMIT;
    END LOOP;
    CLOSE csr_application_exists;

      INSERT INTO XLA_UPG_ERRORS
       (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
        values(
	 xla_upg_errors_s.nextval
	 ,602
	 ,602
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_APP_VERIFICATION_RECORD'
         ,l_rowcount);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Validate_Application_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

    COMMIT;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Application_Entries');

END Validate_Application_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Entity_Entries                                                     |
|                                                                             |
| This routine is called to validate the entity entries in upgrade.           |
|                                                                             |
+============================================================================*/
PROCEDURE Validate_Entity_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER) IS

   l_entity_id t_entity_id;
   l_event_id t_event_id;
   l_header_id t_header_id;
   l_line_num t_line_num;
   l_entity_error1 t_error_flag;
   l_log_module VARCHAR2(240);
   l_rowcount   number(15) := 0;

   cursor csr_entity_errors is
          select distinct entity_id
	    from xla_upg_errors
	   where error_level = 'N'
	     and application_id = p_application_id
	     and upg_source_application_id = p_upgrading_application_id;

BEGIN

   g_application_id        := p_application_id;
   g_source_application_id := p_upgrading_application_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Entity_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Entity_Entries';
   END IF;

   -- Deleting all xla_upg_errors from previous run

   delete from xla_upg_errors
    where application_id = p_application_id
      and upg_source_application_id = p_upgrading_application_id
      and error_message_name in ('XLA_UPG_ENCODE_INVALID'
                                 ,'XLA_ENT_VERIFICATION_RECORD');

   INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
   (upg_error_id, application_id, upg_source_application_id,creation_date
   , created_by, last_update_date, last_updated_by, upg_batch_id
   , error_level, error_message_name,entity_id)
   (select xla_upg_errors_s.nextval
          ,g_application_id
          ,g_source_application_id
          ,sysdate
          ,-1
          ,sysdate
          ,-1
          ,-9999
          ,'N'
          ,'XLA_UPG_ENCODE_INVALID'
          ,entity_id
     from xla_transaction_entities_upg xen
    where not exists (select 1 from xla_entity_types_b xent
                       where xen.entity_code = xent.entity_code
                         and xen.application_id = xent.application_id)
      and xen.application_id = p_application_id
      and xen.upg_source_application_id = p_upgrading_application_id);

      -- Updating invalid entities.

   COMMIT;

   OPEN csr_entity_errors;
   LOOP
      FETCH csr_entity_errors
      BULK COLLECT INTO
           l_entity_id
      LIMIT g_batch_size;
      EXIT when l_entity_id.COUNT = 0;

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         UPDATE xla_transaction_entities_upg
	 set    upg_valid_flag = 'D'
	 where  entity_id = l_entity_id(i);

      -- finding out how many rows got inserted/updated.

         l_rowcount := sql%rowcount;

      -- Updating as invalids all events that are associated with invalid entity.

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         UPDATE xla_events
            set upg_valid_flag = 'E'
	  where entity_id = l_entity_id(i);

      -- Cumilitive number of rows updated.

         l_rowcount := l_rowcount + sql%rowcount;

      -- Updating as invalids all headers that are associated with
      -- events that are associated with invalid entities.

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         UPDATE xla_ae_headers
            set upg_valid_flag = 'F'
	  where entity_id = l_entity_id(i);

      -- Cumilitive number of rows updated.

         l_rowcount := l_rowcount + sql%rowcount;

   COMMIT;
   END LOOP;
   CLOSE csr_entity_errors;

   INSERT INTO XLA_UPG_ERRORS
    (upg_error_id, application_id, upg_source_application_id, creation_date
    ,created_by, last_update_date, last_updated_by, upg_batch_id
    ,error_level, error_message_name,entity_id)
    values(
    xla_upg_errors_s.nextval
    ,g_application_id
    ,g_source_application_id
    ,sysdate
    ,-1
    ,sysdate
    ,-1
    ,-9999
    , 'V'
    ,'XLA_ENT_VERIFICATION_RECORD'
    ,l_rowcount);

    COMMIT;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Validate_Entity_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Entity_Entries');

END Validate_Entity_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Event_Entries                                                      |
|                                                                             |
| This routine is called to validate the Event entries in upgrade.            |
|                                                                             |
+============================================================================*/

PROCEDURE Validate_Event_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER) IS

   l_event_id t_event_id;
   l_event_error1 t_error_flag;
   l_event_error2 t_error_flag;
   l_event_error3 t_error_flag;
   l_event_error4 t_error_flag;
   l_event_error5 t_error_flag;
   l_event_error6 t_error_flag;
   l_event_error7 t_error_flag;
   l_event_error8 t_error_flag;
   l_log_module   VARCHAR2(240);
   l_rowcount   number(15) := 0;

   CURSOR csr_event_errors IS
   select distinct event_id
     from xla_upg_errors
    where error_level = 'E'
      and application_id = p_application_id
      and upg_source_application_id = p_upgrading_application_id;

BEGIN

   g_application_id        := p_application_id;
   g_source_application_id := p_upgrading_application_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Event_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Event_Entries';
   END IF;

   -- Deleting all xla_upg_errors from previous run of this procedure

   delete from xla_upg_errors
    where application_id = p_application_id
      and upg_source_application_id = p_upgrading_application_id
      and error_message_name in ('XLA_UPG_EVT_NO_ENTITY'
                                 ,'XLA_UPG_EVT_INV_ENTITY'
                                 ,'XLA_UPG_EVTYP_INVALID'
                                 ,'XLA_UPG_EVSTCODE_INVALID'
                                 ,'XLA_UPG_PROCSTCODE_INVALID'
                                 ,'XLA_UPG_EVNO_INVALID'
				 ,'XLA_UPG_EVTCODE_INVALID'
				 ,'XLA_UPG_ACC_CLASS_INVALID'
				 ,'XLA_EVT_VERIFICATION_RECORD');

      -- Write Errors
         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
	 (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name, event_id)
         (select xla_upg_errors_s.nextval
          	 ,g_application_id
        	 ,g_source_application_id
        	 ,sysdate
        	 ,-1
        	 ,sysdate
        	 ,-1
        	 ,-9999
        	 , 'E'
        	 ,decode(grm.multiplier,1,'XLA_UPG_EVT_NO_ENTITY'
		                       ,2,'XLA_UPG_EVT_INV_ENTITY'
				       ,3,'XLA_UPG_EVTYP_INVALID'
				       ,4,'XLA_UPG_EVSTCODE_INVALID'
				       ,5,'XLA_UPG_PROCSTCODE_INVALID'
				       ,6,'XLA_UPG_EVNO_INVALID'
				       ,7,'XLA_UPG_EVTCODE_INVALID'
				       ,'XLA_UPG_ACC_CLASS_INVALID')
		 ,event_id
         from (select  distinct event_id
              ,CASE when xen.entity_code IS NULL THEN 'Y'
               ELSE 'N' END event_error1-- Event exists without entity
              ,CASE when xent.entity_code IS NULL THEN 'Y'
               ELSE 'N'  END event_error2 -- Event attached to invalid entity
              ,CASE when xevt.event_type_code IS NULL THEN 'Y'
	       ELSE 'N' END event_error3-- Event Type is Invalid
              ,CASE when xe.EVENT_STATUS_CODE NOT IN ('I','N','P','U') THEN 'Y'
               ELSE 'N' END event_error4-- Invalid event status Code.
              ,CASE when xe.PROCESS_STATUS_CODE NOT IN ('D','E','I','P','R','U')
                    THEN 'Y'
               ELSE 'N' END event_error5-- Invalid Process status code
              ,CASE when xe.event_number < 0 THEN 'Y'
               ELSE 'N' END event_error6-- Invalid Event Number
              ,CASE when xevt.event_class_code IS NULL THEN 'Y'
	       ELSE 'N' END event_error7-- Event Class Code is Invalid
              ,CASE when xalb.accounting_class_code IS NULL THEN 'Y'
	       ELSE 'N' END event_error8
               from xla_events xe
                   , xla_transaction_entities_upg xen
                   , xla_event_types_b xevt
	           , xla_acct_line_types_b xalb
	           , xla_entity_types_b xent
              where xen.entity_id(+) = xe.entity_id
                and xevt.event_type_code(+) = xe.event_type_code
                and xevt.application_id(+)  = xe.application_id
                and xalb.application_id     = xevt.application_id
                and xalb.entity_code        = xevt.entity_code
                and xalb.event_class_code   = xevt.event_class_code
                and xen.entity_code = xent.entity_code(+)
                and xen.application_id = xent.application_id(+)
                and (xen.entity_code IS NULL OR
                     xevt.event_type_code IS NULL OR
                     xe.EVENT_STATUS_CODE NOT IN ('I','N','P','U') OR
                     xe.PROCESS_STATUS_CODE NOT IN ('D','E','I','P','R','U') OR
                     xe.event_number < 0)
                and xe.application_id = p_application_id
                and xe.upg_source_Application_id = p_upgrading_application_id) xe
           ,gl_row_multipliers grm
      where grm.multiplier < 9
        and decode(grm.multiplier,
	           1,event_error1,
		   2,event_error2,
		   3,event_error3,
		   4,event_error4,
		   5,event_error5,
		   6,event_error6,
		   7,event_error7
		    ,event_error8) = 'Y');

   COMMIT;

   OPEN csr_event_errors;
   LOOP
      FETCH csr_event_errors
      BULK COLLECT INTO
           l_event_id
      LIMIT g_batch_size;
      EXIT WHEN l_event_id.COUNT = 0;

      -- Mark Event as having errors
      FORALL i IN l_event_id.FIRST..l_event_id.LAST
         UPDATE xla_events
            set upg_valid_flag = CASE upg_valid_flag
                                 WHEN 'E' THEN 'G'
                                 ELSE 'H'
				 END
	 where  event_id = l_event_id(i);

      -- finding out how many rows got inserted/updated.

         l_rowcount := sql%rowcount;

      -- Updating as invalids all headers that are associated with
      -- events that are associated with invalid entities.

      FORALL i IN l_event_id.FIRST..l_event_id.LAST

         UPDATE xla_ae_headers
            set upg_valid_flag = CASE upg_valid_flag
                               WHEN 'F' THEN 'I'
                               ELSE 'J'
                               END
	  where event_id = l_event_id(i);

      -- Cumilitive number of rows updated.

         l_rowcount := l_rowcount + sql%rowcount;

      --debug message to ensure that this validation took place
      --successfully.

   COMMIT;
   END LOOP;
   CLOSE csr_event_errors;

   INSERT INTO XLA_UPG_ERRORS
    (upg_error_id, application_id, upg_source_application_id, creation_date
     , created_by, last_update_date, last_updated_by, upg_batch_id
     , error_level, error_message_name,entity_id)
   values( xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_EVT_VERIFICATION_RECORD'
         ,l_rowcount);

    COMMIT;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Event_Entries');

END Validate_Event_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Header_Entries                                                     |
|                                                                             |
| This routine is called to validate the Header entries in upgrade.           |
|                                                                             |
+============================================================================*/

PROCEDURE Validate_Header_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER) IS

   l_entity_id t_entity_id;
   l_event_id t_event_id;
   l_header_id t_header_id;
   l_line_num t_line_num;
   l_header_error1 t_error_flag;
   l_header_error2 t_error_flag;
   l_header_error3 t_error_flag;
   l_header_error4 t_error_flag;
   l_header_error5 t_error_flag;
   l_log_module   VARCHAR2(240);
   l_rowcount   number(15) := 0;

   CURSOR csr_header_entries IS
   select distinct ae_header_id
     from xla_upg_errors
    where error_level = 'H'
      and application_id = p_application_id
      and upg_source_application_id = p_upgrading_application_id;

BEGIN

   g_application_id        := p_application_id;
   g_source_application_id := p_upgrading_application_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Header_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Header_Entries';
   END IF;

   -- Deleting all xla_upg_errors from previous run

   delete from xla_upg_errors
    where application_id = p_application_id
      and upg_source_application_id = p_upgrading_application_id
      and error_message_name IN ('XLA_UPG_LEDGER_INVALID'
                                 ,'XLA_UPG_NO_BUDGET_VER'
				 ,'XLA_UPG_NO_ENC_TYPE'
				 ,'XLA_UPG_BALTYP_INVALID'
				 ,'XLA_UPG_HDR_WO_EVT'
				 ,'XLA_UPG_UNBAL_ACCAMT'
				 ,'XLA_UPG_UNBAL_ENTRAMT'
				 ,'XLA_UPG_HDR_WO_LINES'
				 ,'XLA_HDR_VERIFICATION_RECORD');

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
	 (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name, ae_header_id)
	 (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'H'
         ,decode(grm.multiplier,1,'XLA_UPG_LEDGER_INVALID'
	                       ,2,'XLA_UPG_NO_BUDGET_VER'
			       ,3,'XLA_UPG_NO_ENC_TYPE'
			       ,4,'XLA_UPG_BALTYP_INVALID'
			         ,'XLA_UPG_HDR_WO_EVT')
	 ,ae_header_id
	 from ( select ae_header_id
                       ,CASE when gll.ledger_id IS NULL THEN 'Y'
                        ELSE 'N' END header_error1-- Ledger Id is Invalid
                       ,CASE when xah.BALANCE_TYPE_CODE = 'B'
                               and xah.BUDGET_VERSION_ID IS NULL THEN 'Y'
                        ELSE 'N' END header_error2-- No Budget Version
                       ,CASE when xah.BALANCE_TYPE_CODE = 'E'
                              and  xah.ENCUMBRANCE_TYPE_ID IS NULL THEN 'Y'
                        ELSE 'N' END header_error3-- No Enc Type
                       ,CASE when xah.BALANCE_TYPE_CODE NOT IN ('A','B','E')
		             THEN 'Y'
                        ELSE 'N' END header_error4-- Balance type code invalid
                      ,CASE when xe.event_id IS NULL THEN 'Y'
                       ELSE 'N' END header_error5-- Header without valid event
                  from xla_ae_headers xah
                      ,gl_ledgers gll
                      ,xla_events xe
                 where gll.ledger_id (+) = xah.ledger_id
                   and xe.event_id (+) = xah.event_id
                   and (gll.ledger_id IS NULL OR
                       (xah.BALANCE_TYPE_CODE = 'B' AND
                        xah.BUDGET_VERSION_ID IS NULL) OR
                       (xah.BALANCE_TYPE_CODE = 'E' AND
                        xah.ENCUMBRANCE_TYPE_ID IS NULL) OR
                       xah.BALANCE_TYPE_CODE NOT IN ('A','B','E') OR
                       xe.event_id IS NULL)
                   and xah.application_id = p_application_id
                   and xah.upg_source_application_id = p_upgrading_application_id) xah
              ,gl_row_multipliers grm
        where grm.multiplier < 6
          and decode(grm.multiplier,
	             1,header_error1,
		     2,header_error2,
		     3,header_error3,
		     4,header_error4,
		       header_error5) = 'Y');

    COMMIT;

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name, ae_header_id)
         (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'H'
         ,decode(grm.multiplier,1,'XLA_UPG_UNBAL_ACCAMT'
	                         ,'XLA_UPG_UNBAL_ENTRAMT')
	 ,ae_header_id
         from (select /*+ no_merge */ xal.ae_header_id,
                 case when nvl(sum(accounted_dr), 0) <> nvl(sum(accounted_cr), 0)
                 then 'Y' else 'N' end header_error1, -- amts not balanced,
                 case when nvl(sum(entered_dr), 0) <> nvl(sum(entered_cr), 0)
                 then 'Y' else 'N' end header_error2 -- entered amts not balanced
                 from xla_ae_lines xal
                where xal.application_id = p_application_id
                  and xal.currency_code <> 'STAT'
                  and xal.ledger_id in (select gll.ledger_id
                                          from gl_ledgers gll
                                         where gll.suspense_allowed_flag = 'N')
                                      group by xal.ae_header_id
                                        having nvl(sum(accounted_dr), 0)
					       <> nvl(sum(accounted_cr), 0)
                                            or nvl(sum(entered_dr), 0)
					       <> nvl(sum(entered_cr), 0)) xal,
              gl_row_multipliers grm
        where xal.ae_header_id in ( select /*+ use_hash(xah) swap_join_inputs(xah) */
                                          xah.ae_header_id
                                     from xla_ae_headers xah
                                    where xah.application_id = p_application_id
				      and xah.upg_source_application_id
				          = p_upgrading_application_id
                                      and xah.balance_type_code <> 'B')
         and grm.multiplier < 3
         and decode(grm.multiplier, 1, header_error1, header_error2) = 'Y');

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id,creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, ae_header_id, error_message_name)
	 (select xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'H'
         ,ae_header_id
         ,'XLA_UPG_HDR_WO_LINES'
	 from (select xah.ae_header_id
                 from  xla_ae_headers xah
                where NOT EXISTS (SELECT xal.ae_header_id
                                    from xla_ae_lines xal
                                   where xah.ae_header_id = xal.ae_header_id
                                     and xah.application_id = xal.application_id
                            	     and xal.application_id = p_application_id)
                  and application_id = p_application_id
                  and upg_source_application_id = p_upgrading_application_id));

    COMMIT;

  open csr_header_entries;
  LOOP
    FETCH csr_header_entries
     BULK COLLECT INTO
          l_header_id
    LIMIT g_batch_size;
    EXIT WHEN l_header_id.COUNT = 0;

      FORALL i IN l_header_id.FIRST..l_header_id.LAST
       UPDATE xla_ae_headers
          set upg_valid_flag = CASE upg_valid_flag
                               WHEN 'F' THEN 'L'
                               WHEN 'J' THEN 'M'
                               WHEN 'I' THEN 'N'
                               ELSE 'K'
			       END
        where  ae_header_id = l_header_id(i);

        l_rowcount := l_rowcount + sql%rowcount;

   COMMIT;
   END LOOP;
   CLOSE csr_header_entries;

     INSERT INTO XLA_UPG_ERRORS
       (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
        values(
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_HDR_VERIFICATION_RECORD'
         ,l_rowcount);

    COMMIT;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Header_Entries');

END Validate_Header_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Line_Entries                                                       |
|                                                                             |
| This routine is called to validate the Line entries in upgrade.             |
|                                                                             |
+============================================================================*/

PROCEDURE Validate_Line_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER) IS

   l_entity_id t_entity_id;
   l_event_id t_event_id;
   l_header_id t_header_id;
   l_line_num t_line_num;
   l_line_error1 t_error_flag;
   l_line_error2 t_error_flag;
   l_line_error3 t_error_flag;
   l_line_error4 t_error_flag;
   l_line_error5 t_error_flag;
   l_line_error6 t_error_flag;
   l_line_error7 t_error_flag;
   l_line_error8 t_error_flag;
   l_line_error9 t_error_flag;
   l_line_error10 t_error_flag;
   l_log_module   VARCHAR2(240);
   l_rowcount   number(15) := 0;

   CURSOR csr_line_errors IS
   select distinct ae_header_id
     from xla_upg_errors
    where error_level = 'L'
      and application_id = p_application_id
      and upg_Source_application_id = p_upgrading_application_id;
BEGIN

   g_application_id        := p_application_id;
   g_source_application_id := p_upgrading_application_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Line_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Line_Entries';
   END IF;

   -- Deleting all xla_upg_errors from previous run

   delete from xla_upg_errors
    where application_id = p_application_id
      and upg_source_application_id = p_upgrading_application_id
      and error_message_name IN ('XLA_UPG_CCID_INVALID'
                                ,'XLA_UPG_CCID_SUMACCT'
				,'XLA_UPG_CCID_NOBUDGET'
				,'XLA_UPG_PARTY_TYP_INVALID'
				,'XLA_UPG_DRCR_NULL'
				,'XLA_UPG_ENTAMT_DIFF_ACCAMT'
				,'XLA_UPG_LINE_NO_HDR'
				,'XLA_UPG_ENTAMT_ACCAMT_DIFFSIDE'
				,'XLA_UPG_PARTY_ID_INVALID'
				,'XLA_UPG_PARTY_SITE_INVALID'
				,'XLA_LINE_VERIFICATION_RECORD');

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, ae_header_id, ae_line_num,error_message_name)
         (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'L'
         ,ae_header_id
         ,ae_line_num
         ,decode(grm.multiplier,1,'XLA_UPG_CCID_INVALID'
	                       ,2,'XLA_UPG_CCID_SUMACCT'
			       ,3,'XLA_UPG_CCID_NOBUDGET'
			       ,4,'XLA_UPG_PARTY_TYP_INVALID'
			       ,5,'XLA_UPG_DRCR_NULL'
			       ,6,'XLA_UPG_ENTAMT_DIFF_ACCAMT'
			       ,7,'XLA_UPG_LINE_NO_HDR'
			       ,8,'XLA_UPG_ENTAMT_ACCAMT_DIFFSIDE'
			       ,9,'XLA_UPG_PARTY_ID_INVALID'
			       ,'XLA_UPG_PARTY_SITE_INVALID')
         from ( select  xal.ae_header_id
          , ae_line_num
          , CASE when glcc.CHART_OF_ACCOUNTS_ID IS NULL THEN 'Y'
                 ELSE 'N'  END line_error1-- Invalid Code Combination Id
          , CASE when glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL
                 and  glcc.SUMMARY_FLAG = 'Y' THEN 'Y'
   	         ELSE 'N'  END line_error2-- CCID not a Summary Account
          , CASE when glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL
                 and  xah.APPLICATION_ID IS NOT NULL
                 and  xah.BALANCE_TYPE_CODE = 'B'
                 and  glcc.DETAIL_BUDGETING_ALLOWED_FLAG  <> 'Y' THEN 'Y'
   	         ELSE 'N'  END line_error3-- Budgeting not allowed
          , CASE when xal.PARTY_TYPE_CODE IS NOT NULL
                 and  xal.PARTY_TYPE_CODE NOT IN ('C','S') THEN 'Y'
                 ELSE 'N'  END line_error4-- Invalid Party Type Code
          , CASE when (xal.accounted_dr is NULL AND xal.accounted_cr is NULL)
                 or   (xal.entered_dr is NULL AND xal.entered_cr is NULL)
                 or   (xal.accounted_dr is NOT NULL
		       AND xal.accounted_cr is NOT NULL)
                 or   (xal.entered_dr is NOT NULL
		       AND xal.entered_cr is NOT NULL)
   	         THEN 'Y'
   	         ELSE 'N'  END line_error5
          , CASE when gll.currency_code IS NOT NULL
                 and  xal.currency_code = gll.currency_code
   	         and  (nvl(xal.entered_dr,0) <> nvl(xal.accounted_dr,0)
   	         or    nvl(xal.entered_cr,0) <> nvl(xal.accounted_cr,0))
		 THEN 'Y'
   	         ELSE 'N'  END line_error6
          , CASE when xah.application_id IS NULL THEN 'Y'
                 ELSE 'N'  END line_error7-- Orphan Line.
          , CASE when (xal.accounted_dr is NOT NULL and
                       xal.entered_cr is NOT NULL) or
                      (xal.accounted_cr is NOT NULL and
                       xal.entered_dr is NOT NULL) THEN 'Y'
                 ELSE 'N'  END line_error8
          ,CASE when xal.party_id IS NULL THEN 'Y'
	         ELSE 'N' END line_error9
	  , CASE when xal.party_site_id IS NULL
	          and xal.party_id IS NULL then 'Y'
	         ELSE 'N' END line_error10
  FROM     xla_ae_headers         xah
          , xla_ae_lines           xal
          , gl_code_combinations   glcc
          , gl_ledgers             gll
	  , hz_parties             hz
	  , hz_party_sites         hps
   WHERE  glcc.code_combination_id(+) = xal.code_combination_id
   AND    xah.ae_header_id(+)         = xal.ae_header_id
   AND    gll.ledger_id(+)            = xah.ledger_id
   AND    xal.party_id(+)             = hz.party_id
   AND    xal.party_site_id           = hps.party_site_id
   AND    (glcc.CHART_OF_ACCOUNTS_ID IS NULL OR
           (glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL AND
            glcc.SUMMARY_FLAG = 'Y' ) OR
           (glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL AND
            xah.APPLICATION_ID IS NOT NULL AND
            xah.BALANCE_TYPE_CODE = 'B' AND
            glcc.DETAIL_BUDGETING_ALLOWED_FLAG  <> 'Y') OR
           (xal.PARTY_TYPE_CODE IS NOT NULL AND
            xal.PARTY_TYPE_CODE NOT IN ('C','S') ) OR
           (xal.accounted_dr is NULL AND xal.accounted_cr is NULL) OR
           (xal.entered_dr is NULL AND xal.entered_cr is NULL) OR
           (xal.accounted_dr is NOT NULL AND xal.accounted_cr is NOT NULL) OR
           (xal.entered_dr is NOT NULL AND xal.entered_cr is NOT NULL) OR
           (gll.currency_code IS NOT NULL AND
            xal.currency_code = gll.currency_code AND
            (nvl(xal.entered_dr,0) <> nvl(xal.accounted_dr,0) OR
             nvl(xal.entered_cr,0) <> nvl(xal.accounted_cr,0))) OR
           ((xal.accounted_dr is NOT NULL and xal.entered_cr is NOT NULL) OR
            (xal.accounted_cr is NOT NULL and xal.entered_dr is NOT NULL)) OR
           (xah.application_id IS NULL))
   and    xal.application_id = p_application_id
   and    xah.upg_source_application_id = p_upgrading_application_id) xal
   ,gl_row_multipliers grm
   where grm.multiplier < 11
   and decode (grm.multiplier,1,line_error1
                             ,2,line_error2
                             ,3,line_error3
                             ,4,line_error4
                             ,5,line_error5
                             ,6,line_error6
                             ,7,line_error7
                             ,8,line_error8
                             ,9,line_error9
                             ,line_error10) = 'Y');

   COMMIT;

   OPEN csr_line_errors;
   LOOP
      FETCH csr_line_errors
      BULK COLLECT INTO
           l_header_id
      LIMIT g_batch_size;
      EXIT WHEN l_header_id.COUNT = 0;

      -- Mark Header as having errors
      FORALL i IN l_header_id.FIRST..l_header_id.LAST
         UPDATE xla_ae_headers
            set upg_valid_flag = CASE upg_valid_flag
                               WHEN 'F' THEN 'P'
                               WHEN 'J' THEN 'Q'
                               WHEN 'I' THEN 'R'
                               WHEN 'L' THEN 'S'
                               WHEN 'M' THEN 'T'
                               WHEN 'N' THEN 'U'
                               ELSE 'O'
			       END
         where  ae_header_id = l_header_id(i)
	 and    application_id = p_application_id
	 and    UPG_SOURCE_APPLICATION_ID = p_upgrading_application_id;

      -- finding out how many rows got inserted/updated.

         l_rowcount := l_rowcount + sql%rowcount;

      --debug message to ensure that this validation took place
      --successfully.

   COMMIT;
   END LOOP;
   CLOSE csr_line_errors;

      INSERT INTO XLA_UPG_ERRORS
       (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
        values(
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,g_source_application_id
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_LINE_VERIFICATION_RECORD'
         ,l_rowcount);

    COMMIT;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Line_Entries');

END Validate_Line_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Distribution_Entries                                               |
|                                                                             |
| This routine is called to validate the distribution entries in upgrade.     |
|                                                                             |
+============================================================================*/

PROCEDURE Validate_Distribution_Entries (p_application_id IN NUMBER) IS

   l_entity_id        t_entity_id;
   l_event_id         t_event_id;
   l_header_id        t_header_id;
   l_line_num         t_line_num;
   l_temp_line_num    t_line_num;
   l_log_module       VARCHAR2(240);
   l_rowcount   number(10) := 0;

   CURSOR csr_distribution_errors IS
   select distinct ae_header_id
     from xla_upg_errors
    where  error_level = 'D'
      and application_id = p_application_id;

BEGIN

   g_application_id        := p_application_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Distribution_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Distribution_Entries';
   END IF;

   delete from xla_upg_errors
    where application_id = p_application_id
      and error_message_name IN ('XLA_UPG_LINK_NO_LINE'
                                 ,'XLA_DIST_VERIFICATION_RECORD');

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id,creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, ae_header_id, ae_line_num, temp_line_num
	 , error_message_name)
         (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,602
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'D'
         ,ae_header_id
         ,ae_line_num
         ,temp_line_num
         ,'XLA_UPG_LINK_NO_LINE'
	 from (select xdl.ae_header_id, xdl.ae_line_num,xdl.temp_line_num
                 from xla_distribution_links xdl
                where not exists (SELECT xal.ae_header_id, xal.ae_line_num
                                    from xla_ae_lines xal
                                   where xal.ae_header_id = xdl.ae_header_id
                                     and xal.ae_line_num  = xdl.ae_line_num
				     and xal.application_id = p_application_id)
                  and xdl.application_id = p_application_id));

      -- finding out how many rows got updated.

   COMMIT;

   OPEN csr_distribution_errors;
   LOOP
      FETCH csr_distribution_errors
      BULK COLLECT INTO
           l_header_id
      LIMIT g_batch_size;
      EXIT when l_header_id.COUNT = 0;

      FORALL i IN l_header_id.FIRST..l_header_id.LAST
         UPDATE xla_ae_headers
            set upg_valid_flag = CASE upg_valid_flag
                               WHEN 'P' THEN 'W'
                               WHEN 'Q' THEN 'X'
                               WHEN 'R' THEN 'Y'
                               WHEN 'F' THEN 'Z'
                               WHEN 'J' THEN '1'
                               WHEN 'I' THEN '2'
                               WHEN 'L' THEN '3'
                               WHEN 'M' THEN '4'
                               WHEN 'N' THEN '5'
                               WHEN 'S' THEN '6'
                               WHEN 'T' THEN '7'
                               WHEN 'U' THEN '8'
                               ELSE 'V'
			       END
         where  ae_header_id = l_header_id(i)
	 and    application_id = p_application_id;

         l_rowcount := l_rowcount + sql%rowcount;

   COMMIT;
   END LOOP;
   CLOSE csr_distribution_errors;

      INSERT INTO XLA_UPG_ERRORS
       (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
        values(
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,602
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_DIST_VERIFICATION_RECORD'
         ,l_rowcount);

    COMMIT;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Validate_Distribution_Entries');

END Validate_Distribution_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Populate_Segment_Values                                                     |
|                                                                             |
| This routine is called to populate segment values.                          |
|                                                                             |
+============================================================================*/
PROCEDURE Populate_Segment_Values (
          p_application_id IN NUMBER) IS

   L_LOG_MODULE  VARCHAR2(240);
   L_HEADER_ID   T_HEADER_ID;
   L_SEG_VALUE   T_SEG_VALUE;
   L_LINE_COUNT  T_LINE_COUNT;
   L_SEG_TYPE    T_SEG_TYPE;

   -- Cursor declarations
   Cursor csr_bal_segment_values IS
   select xal.ae_header_id,  decode(gll.bal_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL), count(*)
   from    xla_ae_lines         xal,
           xla_ae_headers       xah,
           gl_ledgers           gll,
           gl_code_combinations ccid
   where   gll.ledger_id      = xah.ledger_id
   and     xah.application_id = p_application_id
   and     xah.ae_header_id   = xal.ae_header_id
   and     xal.application_id = p_application_id
   and     ccid.code_combination_id = xal.code_combination_id
   GROUP BY  xal.ae_header_id, decode(gll.bal_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL);

   Cursor csr_mgt_segment_values IS
   select xal.ae_header_id,  decode(gll.mgt_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL), count(*)
   from    xla_ae_lines         xal,
           xla_ae_headers       xah,
           gl_ledgers           gll,
           gl_code_combinations ccid
   where   gll.ledger_id        = xah.ledger_id
   and     xah.application_id   = p_application_id
   and     xah.ae_header_id     = xal.ae_header_id
   and     xal.application_id   = p_application_id
   and     ccid.code_combination_id = xal.code_combination_id
   and     gll.mgt_seg_column_name IS NOT NULL
   GROUP BY  xal.ae_header_id, decode(gll.mgt_seg_column_name,
                                        'SEGMENT1', ccid.segment1,
                                        'SEGMENT2', ccid.segment2,
                                        'SEGMENT3', ccid.segment3,
                                        'SEGMENT4', ccid.segment4,
                                        'SEGMENT5', ccid.segment5,
                                        'SEGMENT6', ccid.segment6,
                                        'SEGMENT7', ccid.segment7,
                                        'SEGMENT8', ccid.segment8,
                                        'SEGMENT9', ccid.segment9,
                                        'SEGMENT10', ccid.segment10,
                                        'SEGMENT11', ccid.segment11,
                                        'SEGMENT12', ccid.segment12,
                                        'SEGMENT13', ccid.segment13,
                                        'SEGMENT14', ccid.segment14,
                                        'SEGMENT15', ccid.segment15,
                                        'SEGMENT16', ccid.segment16,
                                        'SEGMENT17', ccid.segment17,
                                        'SEGMENT18', ccid.segment18,
                                        'SEGMENT19', ccid.segment19,
                                        'SEGMENT20', ccid.segment20,
                                        'SEGMENT21', ccid.segment21,
                                        'SEGMENT22', ccid.segment22,
                                        'SEGMENT23', ccid.segment23,
                                        'SEGMENT24', ccid.segment24,
                                        'SEGMENT25', ccid.segment25,
                                        'SEGMENT26', ccid.segment26,
                                        'SEGMENT27', ccid.segment27,
                                        'SEGMENT28', ccid.segment28,
                                        'SEGMENT29', ccid.segment29,
                                        'SEGMENT30', ccid.segment30,
                                        NULL);
BEGIN
   g_application_id := p_application_id;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Populate_Segment_Values';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Populate_Segment_Values'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   OPEN csr_bal_segment_values;
   LOOP
      FETCH csr_bal_segment_values
      BULK COLLECT INTO
           l_header_id
         , l_seg_value
         , l_line_count
      LIMIT g_batch_size;
      EXIT when l_header_id.COUNT = 0;

      FORALL i IN l_header_id.FIRST..l_header_id.LAST
         INSERT INTO xla_ae_segment_values
         (ae_header_id, segment_type_code, segment_value, ae_lines_count,
	  upg_batch_id)
         values (
          l_header_id(i)
         ,C_BAL_SEGMENT
         ,l_seg_value(i)
         ,l_line_count(i)
	 ,-9999);
   COMMIT;
   END LOOP;
   CLOSE csr_bal_segment_values;

   OPEN csr_mgt_segment_values;
   LOOP
      FETCH csr_mgt_segment_values
      BULK COLLECT INTO
           l_header_id
         , l_seg_value
         , l_line_count
      LIMIT g_batch_size;
      EXIT when l_header_id.COUNT = 0;

      FORALL i IN l_header_id.FIRST..l_header_id.LAST
         INSERT INTO xla_ae_segment_values
         (ae_header_id, segment_type_code, segment_value, ae_lines_count,
	  upg_batch_id)
         values (
          l_header_id(i)
         ,C_MGT_SEGMENT
         ,l_seg_value(i)
         ,l_line_count(i)
	 ,-9999);
   COMMIT;
   END LOOP;
   CLOSE csr_mgt_segment_values;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Populate_Segment_Values'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPG_VERIFICATION_PUB.Populate_Segment_Values');
END Populate_Segment_Values;

BEGIN
      g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

      IF NOT g_log_enabled  THEN
         g_log_level := C_LEVEL_LOG_DISABLED;
      END IF;

END XLA_UPG_VERIFICATION_PUB;

/
