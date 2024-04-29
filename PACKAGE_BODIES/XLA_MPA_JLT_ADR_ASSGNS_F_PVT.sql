--------------------------------------------------------
--  DDL for Package Body XLA_MPA_JLT_ADR_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MPA_JLT_ADR_ASSGNS_F_PVT" AS
/* $Header: xlathmad.pkb 120.0 2005/06/24 01:30:05 eklau noship $ */

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_MPA_JLT_ADR_ASSGNS_F_PVT';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ----------------------------------------------------------------------------
  -- Following is for FND log.
  ----------------------------------------------------------------------------
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
      (p_location   => 'XLA_MPA_JLT_ADR_ASSGNS_F_PVT.trace');
END trace;


PROCEDURE Insert_Row (
    x_rowid				IN OUT NOCOPY VARCHAR2,
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_class_code			IN VARCHAR2,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2,
    x_segment_rule_appl_id		IN NUMBER,
    x_segment_rule_type_code		IN VARCHAR2,
    x_segment_rule_code			IN VARCHAR2,
    x_inherit_adr_flag			IN VARCHAR2,
    x_creation_date			IN DATE,
    x_created_by			IN NUMBER,
    x_last_update_date			IN DATE,
    x_last_updated_by			IN NUMBER,
    x_last_update_login			IN NUMBER
) IS

   Cursor C is
   Select rowid
     from xla_mpa_jlt_adr_assgns
    where amb_context_code		= x_amb_context_code
      and application_id		= x_application_id
      and event_type_code		= x_event_type_code
      and line_definition_owner_code	= x_line_definition_owner_code
      and line_definition_code		= x_line_definition_code
      and accounting_line_type_code	= x_accounting_line_type_code
      and accounting_line_code		= x_accounting_line_code
      and mpa_accounting_line_type_code	= x_mpa_accounting_line_type_co
      and mpa_accounting_line_code	= x_mpa_accounting_line_code
      and flexfield_segment_code	= x_flexfield_segment_code;

   l_log_module                    VARCHAR2(240);

BEGIN
   If (g_log_enabled) then
      l_log_module := C_DEFAULT_MODULE||'.insert_row';
   End If;

   If (C_LEVEL_PROCEDURE >= g_log_level) then
      trace(p_msg    => 'BEGIN of procedure insert_row',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
   End If;

   INSERT INTO XLA_MPA_JLT_ADR_ASSGNS (
       AMB_CONTEXT_CODE,
       APPLICATION_ID,
       EVENT_CLASS_CODE,
       EVENT_TYPE_CODE,
       LINE_DEFINITION_OWNER_CODE,
       LINE_DEFINITION_CODE,
       ACCOUNTING_LINE_TYPE_CODE,
       ACCOUNTING_LINE_CODE,
       MPA_ACCOUNTING_LINE_TYPE_CODE,
       MPA_ACCOUNTING_LINE_CODE,
       FLEXFIELD_SEGMENT_CODE,
       SEGMENT_RULE_APPL_ID,
       SEGMENT_RULE_TYPE_CODE,
       SEGMENT_RULE_CODE,
       INHERIT_ADR_FLAG,
       OBJECT_VERSION_NUMBER,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN
    )
    VALUES (
       X_AMB_CONTEXT_CODE,
       X_APPLICATION_ID,
       X_EVENT_CLASS_CODE,
       X_EVENT_TYPE_CODE,
       X_LINE_DEFINITION_OWNER_CODE,
       X_LINE_DEFINITION_CODE,
       X_ACCOUNTING_LINE_TYPE_CODE,
       X_ACCOUNTING_LINE_CODE,
       X_MPA_ACCOUNTING_LINE_TYPE_CO,
       X_MPA_ACCOUNTING_LINE_CODE,
       X_FLEXFIELD_SEGMENT_CODE,
       X_SEGMENT_RULE_APPL_ID,
       X_SEGMENT_RULE_TYPE_CODE,
       X_SEGMENT_RULE_CODE,
       X_INHERIT_ADR_FLAG,
       1,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);

   Open  C;
   Fetch C into x_rowid;

   If (C%NOTFOUND) then
      Close C;
      Raise NO_DATA_FOUND;
   End If;
   Close C;

   If (C_LEVEL_PROCEDURE >= g_log_level) then
      trace(p_msg    => 'END of procedure insert_row',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
   End If;

END Insert_Row;


PROCEDURE Update_Row (
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2,
    x_segment_rule_appl_id		IN NUMBER,
    x_segment_rule_type_code		IN VARCHAR2,
    x_segment_rule_code			IN VARCHAR2,
    x_inherit_adr_flag			IN VARCHAR2,
    x_last_update_date			IN DATE,
    x_last_updated_by			IN NUMBER,
    x_last_update_login			IN NUMBER
) IS

   l_log_module		varchar2(240);

BEGIN

   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.update_row';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'BEGIN of procedure update_row',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
   END IF;

   UPDATE XLA_MPA_JLT_ADR_ASSGNS
      SET segment_rule_appl_id		= x_segment_rule_appl_id,
          segment_rule_type_code	= x_segment_rule_type_code,
          segment_rule_code		= x_segment_rule_code,
	  inherit_adr_flag		= x_inherit_adr_flag,
	  last_update_date		= x_last_update_date,
	  object_version_number		= object_version_number + 1,
	  last_updated_by		= x_last_updated_by,
	  last_update_login		= x_last_update_login
    WHERE amb_context_code		= x_amb_context_code
      and application_id		= x_application_id
      and event_type_code		= x_event_type_code
      and line_definition_owner_code	= x_line_definition_owner_code
      and line_definition_code		= x_line_definition_code
      and accounting_line_type_code	= x_accounting_line_type_code
      and accounting_line_code		= x_accounting_line_code
      and mpa_accounting_line_type_code	= x_mpa_accounting_line_type_co
      and mpa_accounting_line_code	= x_mpa_accounting_line_code
      and flexfield_segment_code	= x_flexfield_segment_code;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure update_row',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

END Update_Row;


PROCEDURE Lock_Row (
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2,
    x_segment_rule_appl_id		IN NUMBER,
    x_segment_rule_type_code		IN VARCHAR2,
    x_segment_rule_code			IN VARCHAR2,
    x_inherit_adr_flag			IN VARCHAR2
) IS

   Cursor C is
   Select *
     from xla_mpa_jlt_adr_assgns
    where amb_context_code			= x_amb_context_code
      and application_id			= x_application_id
      and event_type_code			= x_event_type_code
      and line_definition_owner_code		= x_line_definition_owner_code
      and line_definition_code			= x_line_definition_code
      and accounting_line_type_code		= x_accounting_line_type_code
      and accounting_line_code			= x_accounting_line_code
      and mpa_accounting_line_type_code		= x_mpa_accounting_line_type_co
      and mpa_accounting_line_code		= x_mpa_accounting_line_code
      and flexfield_segment_code		= x_flexfield_segment_code
      for update of event_class_code nowait;

   l_rec		C%ROWTYPE;
   l_log_module		varchar2(240);

BEGIN
   If g_log_enabled then
      l_log_module := C_DEFAULT_MODULE||'.lock_row';
   End If;

   If (C_LEVEL_PROCEDURE >= g_log_level) then
      trace(p_msg    => 'BEGIN of procedure lock_row',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
   End If;

   Open  C;
   Fetch C into l_rec;
   If (C%NOTFOUND) then
      Close C;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   End If;
   Close C;

   IF (nvl(l_rec.inherit_adr_flag,'@') = nvl(x_inherit_adr_flag,'@') AND
       nvl(l_rec.segment_rule_appl_id,1) = nvl(x_segment_rule_appl_id,1) AND
       nvl(l_rec.segment_rule_type_code,'@') = nvl(x_segment_rule_type_code,'@') AND
       nvl(l_rec.segment_rule_code,'@') = nvl(x_segment_rule_code,'@')) then
      NULL;
   ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg    => 'END of procedure lock_row',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
   END IF;
END Lock_Row;



PROCEDURE Delete_Row (
    x_amb_context_code			IN VARCHAR2,
    x_application_id			IN NUMBER,
    x_event_type_code			IN VARCHAR2,
    x_line_definition_owner_code	IN VARCHAR2,
    x_line_definition_code		IN VARCHAR2,
    x_accounting_line_type_code		IN VARCHAR2,
    x_accounting_line_code		IN VARCHAR2,
    x_mpa_accounting_line_type_co	IN VARCHAR2,
    x_mpa_accounting_line_code		IN VARCHAR2,
    x_flexfield_segment_code		IN VARCHAR2
) IS

   l_log_module       VARCHAR2(240);

BEGIN
   If g_log_enabled then
      l_log_module := C_DEFAULT_MODULE||'.delete_row';
   End If;

   If (C_LEVEL_PROCEDURE >= g_log_level) then
      trace(p_msg    => 'BEGIN of procedure delete_row',
            p_module => l_log_module,
            p_level  => C_LEVEL_PROCEDURE);
   End If;


   DELETE XLA_MPA_JLT_ADR_ASSGNS
    where amb_context_code		= x_amb_context_code
      and application_id		= x_application_id
      and event_type_code		= x_event_type_code
      and line_definition_owner_code	= x_line_definition_owner_code
      and line_definition_code		= x_line_definition_code
      and accounting_line_type_code	= x_accounting_line_type_code
      and accounting_line_code		= x_accounting_line_code
      and mpa_accounting_line_type_code	= x_mpa_accounting_line_type_co
      and mpa_accounting_line_code	= x_mpa_accounting_line_code
      and flexfield_segment_code	= x_flexfield_segment_code;


    If ( SQL%NOTFOUND ) then
       Raise NO_DATA_FOUND;
    End If;

    If (C_LEVEL_PROCEDURE >= g_log_level) then
       trace(p_msg    => 'END of procedure delete_row',
             p_module => l_log_module,
             p_level  => C_LEVEL_PROCEDURE);
    End If;

END Delete_Row;


END XLA_MPA_JLT_ADR_ASSGNS_F_PVT;

/
