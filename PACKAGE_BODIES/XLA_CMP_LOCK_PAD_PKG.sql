--------------------------------------------------------
--  DDL for Package Body XLA_CMP_LOCK_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_LOCK_PAD_PKG" AS
/* $Header: xlacplok.pkb 120.13 2006/08/04 19:32:14 wychan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_lock_pad_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for                                                                    |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     06/25/2002      Kaouther Boussema       Created                        |
|     26-MAI-2003     K.Boussema    Added amb_context_code column            |
|     27-JUN-2003     K.Boussema    Renamed XLA_DESCRIPTION_PRIO and         |
|                                   XLA_EVENT_CLASSES_ATTR tables            |
|     02-JUL-2003 K.Boussema Updated error messages                          |
|     17-JUL-2003 K.Boussema    Reviewed the code                            |
|     27-SEP-2003 K.Boussema    Changed the event_class clauses using '_ALL' |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     24-MAY-2005 Ashish        Removed call to ax_exceptions_pkg and        |
|				replaced it with xla_exception_pkg. See      |
|				bug 4382783				     |
+===========================================================================*/
--+==========================================================================+
--|                                                                          |
--| Private global constant or variable declarations                         |
--|                                                                          |
--+==========================================================================+
--
--
g_product_rule_name        VARCHAR2(80);
g_product_rule_owner       VARCHAR2(30);
--
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_lock_pad_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
             (p_location   => 'xla_cmp_lock_pad_pkg.trace');
END trace;


--+==========================================================================+
--|                                                                          |
--| OVERVIEW of private procedures and functions                             |
--|                                                                          |
--+==========================================================================+
--
--
--
--+==========================================================================+
--| PUBLIC  procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowLineDesc                                                  |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowLineDesc
( p_application_id         IN NUMBER
, p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
)
IS
--
--
CURSOR Description_cur
IS
SELECT xdb.rowid
FROM   xla_aad_line_defn_assgns  xal
     , xla_line_defn_jlt_assgns  xld
     , xla_descriptions_b        xdb
     , xla_descriptions_tl       xdt
WHERE  xal.application_id             = p_application_id
  AND  xal.amb_context_code           = p_amb_context_code
  AND  xal.product_rule_code          = p_product_rule_code
  AND  xal.product_rule_type_code     = p_product_rule_type_code
  AND  xld.application_id             = xal.application_id
  AND  xld.amb_context_code           = xal.amb_context_code
  AND  xld.event_class_code           = xal.event_class_code
  AND  xld.event_type_code            = xal.event_type_code
  AND  xld.line_definition_code       = xal.line_definition_code
  AND  xld.line_definition_owner_code = xal.line_definition_owner_code
  AND  xdb.application_id             = xld.application_id
  AND  xdb.amb_context_code           = xld.amb_context_code
  AND  xdb.description_code           = xld.description_code
  AND  xdb.description_type_code      = xld.description_type_code
  AND  xdt.application_id             = xdb.application_id
  AND  xdt.amb_context_code           = xdb.amb_context_code
  AND  xdt.description_code           = xdb.description_code
  AND  xdt.description_type_code      = xdb.description_type_code
  AND  xdt.language                   = USERENV('LANG')
FOR UPDATE NOWAIT
;
CURSOR Description_prio_cur
IS
SELECT xdp.rowid
FROM   xla_aad_line_defn_assgns  xal
     , xla_line_defn_jlt_assgns  xld
     , xla_desc_priorities       xdp
     , xla_conditions            xco
WHERE  xal.application_id             = p_application_id
  AND  xal.amb_context_code           = p_amb_context_code
  AND  xal.product_rule_code          = p_product_rule_code
  AND  xal.product_rule_type_code     = p_product_rule_type_code
  AND  xld.application_id             = xal.application_id
  AND  xld.amb_context_code           = xal.amb_context_code
  AND  xld.event_class_code           = xal.event_class_code
  AND  xld.event_type_code            = xal.event_type_code
  AND  xld.line_definition_code       = xal.line_definition_code
  AND  xld.line_definition_owner_code = xal.line_definition_owner_code
  AND  xdp.application_id             = xld.application_id
  AND  xdp.amb_context_code           = xld.amb_context_code
  AND  xdp.description_code           = xld.description_code
  AND  xdp.description_type_code      = xld.description_type_code
  AND  xco.description_prio_id        = xdp.description_prio_id
FOR UPDATE NOWAIT
;

CURSOR Description_dtl_cur
IS
SELECT xdd.rowid
FROM   xla_aad_line_defn_assgns  xal
     , xla_line_defn_jlt_assgns  xld
     , xla_desc_priorities       xdp
     , xla_descript_details_b    xdd
     , xla_descript_details_tl   xdt
WHERE  xal.application_id             = p_application_id
  AND  xal.amb_context_code           = p_amb_context_code
  AND  xal.product_rule_code          = p_product_rule_code
  AND  xal.product_rule_type_code     = p_product_rule_type_code
  AND  xld.application_id             = xal.application_id
  AND  xld.amb_context_code           = xal.amb_context_code
  AND  xld.event_class_code           = xal.event_class_code
  AND  xld.event_type_code            = xal.event_type_code
  AND  xld.line_definition_code       = xal.line_definition_code
  AND  xld.line_definition_owner_code = xal.line_definition_owner_code
  AND  xdp.application_id             = xld.application_id
  AND  xdp.amb_context_code           = xld.amb_context_code
  AND  xdp.description_code           = xld.description_code
  AND  xdp.description_type_code      = xld.description_type_code
  AND  xdd.description_prio_id        = xdp.description_prio_id
  AND  xdt.description_detail_id      = xdd.description_detail_id
FOR UPDATE NOWAIT
;
--
l_rowid            ROWID;
l_log_module       VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowLineDesc';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowLineDesc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- Lock descriptions
OPEN  Description_cur;
FETCH Description_cur INTO l_rowid;
CLOSE Description_cur;
--
-- Lock description priorities and conditions
OPEN Description_prio_cur;
FETCH Description_prio_cur INTO l_rowid;
CLOSE Description_prio_cur;
--
-- Lock description details and conditions
OPEN Description_dtl_cur;
FETCH Description_dtl_cur INTO l_rowid;
CLOSE Description_dtl_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowLineDesc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF Description_cur%ISOPEN THEN
             CLOSE Description_cur;
          END IF;
          IF Description_prio_cur%ISOPEN THEN
             CLOSE Description_prio_cur;
          END IF;
          IF Description_dtl_cur%ISOPEN THEN
             CLOSE Description_dtl_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF Description_cur%ISOPEN THEN
             CLOSE Description_cur;
          END IF;
          IF Description_prio_cur%ISOPEN THEN
             CLOSE Description_prio_cur;
          END IF;
          IF Description_dtl_cur%ISOPEN THEN
             CLOSE Description_dtl_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );
      WHEN OTHERS    THEN
         IF Description_cur%ISOPEN THEN
                      CLOSE Description_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowLineDesc');
END LockRowLineDesc;


--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowHdrDesc                                               |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowHdrDesc
( p_application_id         IN NUMBER
, p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
)
IS
--
--
CURSOR Description_cur
IS
SELECT xdb.rowid
FROM   xla_prod_acct_headers     xpah
     , xla_descriptions_b        xdb
     , xla_descriptions_tl       xdt
WHERE  xpah.application_id         = p_application_id
  AND  xpah.amb_context_code       = p_amb_context_code
  AND  xpah.product_rule_code      = p_product_rule_code
  AND  xpah.product_rule_type_code = p_product_rule_type_code
  AND  xdb.application_id          = xpah.application_id
  AND  xdb.amb_context_code        = xpah.amb_context_code
  AND  xdb.description_code        = xpah.description_code
  AND  xdb.description_type_code   = xpah.description_type_code
  AND  xdt.application_id          = xdb.application_id
  AND  xdt.amb_context_code        = xdb.amb_context_code
  AND  xdt.description_code        = xdb.description_code
  AND  xdt.description_type_code   = xdb.description_type_code
  AND  xdt.language                = USERENV('LANG')
FOR UPDATE NOWAIT
;

CURSOR Description_prio_cur
IS
SELECT xdp.rowid
  FROM xla_prod_acct_headers     xpah
     , xla_desc_priorities       xdp
     , xla_conditions            xco
WHERE  xpah.application_id         = p_application_id
  AND  xpah.amb_context_code       = p_amb_context_code
  AND  xpah.product_rule_code      = p_product_rule_code
  AND  xpah.product_rule_type_code = p_product_rule_type_code
  AND  xdp.application_id          = xpah.application_id
  AND  xdp.amb_context_code        = xpah.amb_context_code
  AND  xdp.description_code        = xpah.description_code
  AND  xdp.description_type_code   = xpah.description_type_code
  AND  xco.description_prio_id     = xdp.description_prio_id
FOR UPDATE NOWAIT
;

CURSOR Description_dtl_cur
IS
SELECT xdd.rowid
  FROM xla_prod_acct_headers     xpah
     , xla_desc_priorities       xdp
     , xla_descript_details_b    xdd
     , xla_descript_details_tl   xdt
WHERE  xpah.application_id         = p_application_id
  AND  xpah.amb_context_code       = p_amb_context_code
  AND  xpah.product_rule_code      = p_product_rule_code
  AND  xpah.product_rule_type_code = p_product_rule_type_code
  AND  xdp.application_id          = xpah.application_id
  AND  xdp.amb_context_code        = xpah.amb_context_code
  AND  xdp.description_code        = xpah.description_code
  AND  xdp.description_type_code   = xpah.description_type_code
  AND  xdd.description_prio_id     = xdp.description_prio_id
  AND  xdt.description_detail_id   = xdd.description_detail_id
FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowHdrDesc';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowHdrDesc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- Lock descriptions
OPEN  Description_cur;
FETCH Description_cur INTO l_rowid;
CLOSE Description_cur;
--
-- Lock description priorities and conditions
OPEN Description_prio_cur;
FETCH Description_prio_cur INTO l_rowid;
CLOSE Description_prio_cur;
--
-- Lock description details and conditions
OPEN Description_dtl_cur;
FETCH Description_dtl_cur INTO l_rowid;
CLOSE Description_dtl_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowHdrDesc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF Description_cur%ISOPEN THEN
             CLOSE Description_cur;
          END IF;
          IF Description_prio_cur%ISOPEN THEN
             CLOSE Description_prio_cur;
          END IF;
          IF Description_dtl_cur%ISOPEN THEN
             CLOSE Description_dtl_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF Description_cur%ISOPEN THEN
             CLOSE Description_cur;
          END IF;
          IF Description_prio_cur%ISOPEN THEN
             CLOSE Description_prio_cur;
          END IF;
          IF Description_dtl_cur%ISOPEN THEN
             CLOSE Description_dtl_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );
      WHEN OTHERS    THEN
         IF Description_cur%ISOPEN THEN
                      CLOSE Description_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowHdrDesc');
END LockRowHdrDesc;
--
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowSourceAssignment                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowSourceAssignment
( p_application_id         IN NUMBER
, p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
)
IS
--
--
CURSOR SourceAssignment_cur
IS
SELECT xes.rowid
  FROM xla_prod_acct_headers   xpah
     , xla_event_sources xes
 WHERE xpah.application_id                 = p_application_id
   AND xpah.amb_context_code               = p_amb_context_code
   AND xpah.product_rule_code              = p_product_rule_code
   AND xpah.product_rule_type_code         = p_product_rule_type_code
   AND xpah.event_class_code               <> xpah.entity_code || '_ALL'
   AND xes.application_id                  = xpah.application_id
   AND xes.entity_code                     = xpah.entity_code
   AND (
        xes.event_class_code               = xpah.event_class_code
       OR
        xes.event_class_code               = xes.entity_code ||'_ALL'
       )

FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowSourceAssignment';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowSourceAssignment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
OPEN  SourceAssignment_cur;
FETCH SourceAssignment_cur INTO l_rowid;
CLOSE SourceAssignment_cur;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowSourceAssignment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF SourceAssignment_cur%ISOPEN THEN
             CLOSE SourceAssignment_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF SourceAssignment_cur%ISOPEN THEN
             CLOSE SourceAssignment_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );

      WHEN OTHERS    THEN
         IF SourceAssignment_cur%ISOPEN THEN
            CLOSE SourceAssignment_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowSourceAssignment');
END LockRowSourceAssignment;
--
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowExtractObject                                             |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowExtractObject
( p_application_id         IN NUMBER
, p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
)
IS
--
--
CURSOR ExtractObject_cur
IS
SELECT xeo.rowid
  FROM xla_prod_acct_headers        xpah
     , xla_extract_objects xeo
 WHERE xpah.application_id                 = p_application_id
   AND xpah.amb_context_code               = p_amb_context_code
   AND xpah.product_rule_code              = p_product_rule_code
   AND xpah.product_rule_type_code         = p_product_rule_type_code
   AND xpah.event_class_code               <> xpah.entity_code || '_ALL'
   AND xeo.application_id                  = xpah.application_id
   AND xeo.entity_code                     = xpah.entity_code
   AND (xeo.event_class_code                = xpah.event_class_code
       OR
        xeo.event_class_code                = xeo.entity_code  ||'_ALL'
       )
FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowExtractObject';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
OPEN  ExtractObject_cur;
FETCH ExtractObject_cur INTO l_rowid;
CLOSE ExtractObject_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF ExtractObject_cur%ISOPEN THEN
             CLOSE ExtractObject_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF ExtractObject_cur%ISOPEN THEN
             CLOSE ExtractObject_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );

      WHEN OTHERS    THEN
         IF ExtractObject_cur%ISOPEN THEN
            CLOSE ExtractObject_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowExtractObject');
END LockRowExtractObject;
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowEventType                                                 |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowEventType
( p_application_id         IN NUMBER
, p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
)
IS
--
--
CURSOR EventType_cur
IS
SELECT  xett.rowid
  FROM xla_prod_acct_headers xpah
     , xla_event_types_b     xetb
     , xla_event_types_tl    xett
 WHERE xpah.application_id                 = p_application_id
   AND xpah.amb_context_code               = p_amb_context_code
   AND xpah.product_rule_code              = p_product_rule_code
   AND xpah.product_rule_type_code         = p_product_rule_type_code
   AND xpah.event_class_code               <> xpah.entity_code || '_ALL'
   AND xetb.application_id                 = xpah.application_id
   AND xetb.entity_code                    = xpah.entity_code
   AND xetb.event_class_code               = xpah.event_class_code
   AND xetb.event_type_code                = xpah.event_type_code
   AND xetb.application_id                 = xett.application_id
   AND xetb.entity_code                    = xett.entity_code
   AND xetb.event_class_code               = xett.event_class_code
   AND xetb.event_type_code                = xett.event_type_code
   AND xett.language                       = USERENV('LANG')
FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowEventType';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowEventType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module );

END IF;
--
OPEN  EventType_cur;
FETCH EventType_cur INTO l_rowid;
CLOSE EventType_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowEventType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF EventType_cur%ISOPEN THEN
             CLOSE EventType_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF EventType_cur%ISOPEN THEN
             CLOSE EventType_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );

      WHEN OTHERS    THEN
         IF EventType_cur%ISOPEN THEN
                      CLOSE EventType_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowEventType');
END LockRowEventType;
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowEventClassGrp                                             |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowEventClassGrp(  p_application_id         IN NUMBER
                               , p_product_rule_code      IN VARCHAR2
                               , p_product_rule_type_code IN VARCHAR2
                               , p_amb_context_code       IN VARCHAR2
                          )
IS
--
--
CURSOR EventClassGrp_cur
IS
SELECT  xecgt.rowid
  FROM  xla_prod_acct_headers     xpah
      , xla_event_class_attrs     xeca
      , xla_event_class_grps_b    xecgb
      , xla_event_class_grps_tl   xecgt
 WHERE xpah.application_id                  = p_application_id
   AND xpah.amb_context_code                = p_amb_context_code
   AND xpah.product_rule_code               = p_product_rule_code
   AND xpah.product_rule_type_code          = p_product_rule_type_code
   AND xpah.event_class_code                <> xpah.entity_code || '_ALL'
   AND xeca.application_id                  = xpah.application_id
   AND xeca.entity_code                     = xpah.entity_code
   AND xeca.event_class_code                = xpah.event_class_code
   AND xeca.application_id                  = xecgb.application_id
   AND xeca.event_class_group_code          = xecgb.event_class_group_code
   AND xeca.application_id                  = xecgt.application_id
   AND xeca.event_class_group_code          = xecgt.event_class_group_code
   AND xecgt.language                       = USERENV('LANG')
   AND xeca.event_class_group_code          IS NOT NULL
FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowEventClassGrp';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowEventClassGrp'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
OPEN  EventClassGrp_cur;
FETCH EventClassGrp_cur INTO l_rowid;
CLOSE EventClassGrp_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowEventClassGrp'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF EventClassGrp_cur%ISOPEN THEN
             CLOSE EventClassGrp_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF EventClassGrp_cur%ISOPEN THEN
             CLOSE EventClassGrp_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );

      WHEN OTHERS    THEN
         IF EventClassGrp_cur%ISOPEN THEN
            CLOSE EventClassGrp_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowEventClassGrp');
END LockRowEventClassGrp;
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowEventClass                                                |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowEventClass(  p_application_id         IN NUMBER
                            , p_product_rule_code      IN VARCHAR2
                            , p_product_rule_type_code IN VARCHAR2
                            , p_amb_context_code       IN VARCHAR2
                    )
IS
--
--
CURSOR EventClass_cur
IS
SELECT  xect.rowid
  FROM  xla_prod_acct_headers  xpah
      , xla_event_classes_b    xecb
      , xla_event_classes_tl   xect
 WHERE xpah.application_id                  = p_application_id
   AND xpah.amb_context_code                = p_amb_context_code
   AND xpah.product_rule_code               = p_product_rule_code
   AND xpah.product_rule_type_code          = p_product_rule_type_code
   AND xpah.event_class_code                <> xpah.entity_code || '_ALL'
   AND xecb.application_id                  = xpah.application_id
   AND xecb.entity_code                     = xpah.entity_code
   AND xecb.event_class_code                = xpah.event_class_code
   AND xect.application_id                  = xecb.application_id
   AND xect.entity_code                     = xecb.entity_code
   AND xect.event_class_code                = xecb.event_class_code
   AND xect.language                        = USERENV('LANG')
FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowEventClass';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowEventClass'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

--
OPEN  EventClass_cur;
FETCH EventClass_cur INTO l_rowid;
CLOSE EventClass_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowEventClass'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF EventClass_cur%ISOPEN THEN
             CLOSE EventClass_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF EventClass_cur%ISOPEN THEN
             CLOSE EventClass_cur;
          END IF;
          -- SLA message
          IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     (p_msg      => 'ERROR: XLA_CMP_COMPONENTS_LOCKED'
                     ,p_level    => C_LEVEL_EXCEPTION
                     ,p_module   => l_log_module);
          END IF;
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );

      WHEN OTHERS    THEN
         IF EventClass_cur%ISOPEN THEN
                      CLOSE EventClass_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowEventClass');
END LockRowEventClass;
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowADR                                                       |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE LockRowADR(  p_application_id         IN NUMBER
                     , p_product_rule_code      IN VARCHAR2
                     , p_product_rule_type_code IN VARCHAR2
                     , p_amb_context_code       IN VARCHAR2
                    )
IS
--
CURSOR ADR_cur
IS
--
SELECT  xsrd.rowid
  FROM  xla_aad_line_defn_assgns        xald
      , xla_line_defn_adr_assgns        xlda
      , xla_seg_rule_details            xsrd
      , xla_seg_rules_b                 xsrb
      , xla_seg_rules_tl                xsrt
      , xla_conditions                  xco
 WHERE  xald.application_id             = p_application_id
   AND  xald.amb_context_code           = p_amb_context_code
   AND  xald.product_rule_type_code     = p_product_rule_type_code
   AND  xald.product_rule_code          = p_product_rule_code
   AND  xlda.application_id             = xald.application_id
   AND  xlda.amb_context_code           = xald.amb_context_code
   AND  xlda.event_class_code           = xald.event_class_code
   AND  xlda.event_type_code            = xald.event_type_code
   AND  xlda.line_definition_owner_code = xald.line_definition_owner_code
   AND  xlda.line_definition_code       = xald.line_definition_code
   AND  xsrd.application_id             = xlda.application_id
   AND  xsrd.amb_context_code           = xlda.amb_context_code
   AND  xsrd.segment_rule_code          = xlda.segment_rule_code
   AND  xsrd.segment_rule_type_code     = xlda.segment_rule_type_code
   AND  xsrb.application_id             = xlda.application_id
   AND  xsrb.amb_context_code           = xlda.amb_context_code
   AND  xsrb.segment_rule_code          = xlda.segment_rule_code
   AND  xsrb.segment_rule_type_code     = xlda.segment_rule_type_code
   AND  xsrt.application_id             = xlda.application_id
   AND  xsrt.amb_context_code           = xlda.amb_context_code
   AND  xsrt.segment_rule_code          = xlda.segment_rule_code
   AND  xsrt.segment_rule_type_code     = xlda.segment_rule_type_code
   AND  xsrt.language                   = USERENV('LANG')
   AND  xco.segment_rule_detail_id(+)   = xsrd.segment_rule_detail_id
FOR UPDATE NOWAIT
;
--
l_rowid        ROWID;
l_log_module   VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowADR';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowADR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
OPEN  ADR_cur;
FETCH ADR_cur INTO l_rowid;
CLOSE ADR_cur;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowADR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF ADR_cur%ISOPEN THEN
             CLOSE ADR_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF ADR_cur%ISOPEN THEN
             CLOSE ADR_cur;
          END IF;
           -- SLA message
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );
      WHEN OTHERS    THEN
         IF ADR_cur%ISOPEN THEN
         CLOSE ADR_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowADR');
END LockRowADR;
--
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowAcctgLines                                                |
--|                                                                          |
--+==========================================================================+
--
--
PROCEDURE LockRowAcctgLines(  p_application_id         IN NUMBER
                            , p_product_rule_code      IN VARCHAR2
                            , p_product_rule_type_code IN VARCHAR2
                            , p_amb_context_code       IN VARCHAR2
                    )
IS
--
CURSOR AcctgLines_cur
IS
--
SELECT xald.rowid
  FROM xla_aad_line_defn_assgns xald
     , xla_line_defn_jlt_assgns xldj
     , xla_line_definitions_b   xldb
     , xla_line_definitions_tl  xldt
     , xla_acct_line_types_b    xalb
     , xla_acct_line_types_tl   xalt
     , xla_conditions           xcon
     , xla_prod_acct_headers    xpah
 WHERE xpah.application_id                  = p_application_id
   AND xpah.amb_context_code                = p_amb_context_code
   AND xpah.product_rule_code               = p_product_rule_code
   AND xpah.product_rule_type_code          = p_product_rule_type_code
   AND xald.application_id                  = xpah.application_id
   AND xald.amb_context_code                = xpah.amb_context_code
   AND xald.event_class_code                = xpah.event_class_code
   AND xald.event_type_code                 = xpah.event_type_code
   AND xald.product_rule_code               = xpah.product_rule_code
   AND xald.product_rule_type_code          = xpah.product_rule_type_code
   AND xldj.application_id                  = xald.application_id
   AND xldj.amb_context_code                = xald.amb_context_code
   AND xldj.event_class_code                = xald.event_class_code
   AND xldj.event_type_code                 = xald.event_type_code
   AND xldj.line_definition_code            = xald.line_definition_code
   AND xldj.line_definition_owner_code      = xald.line_definition_owner_code
   AND xldb.application_id                  = xldj.application_id
   AND xldb.amb_context_code                = xldj.amb_context_code
   AND xldb.event_class_code                = xldj.event_class_code
   AND xldb.event_type_code                 = xldj.event_type_code
   AND xldb.line_definition_code            = xldj.line_definition_code
   AND xldb.line_definition_owner_code      = xldj.line_definition_owner_code
   AND xldt.application_id                  = xldb.application_id
   AND xldt.amb_context_code                = xldb.amb_context_code
   AND xldt.event_class_code                = xldb.event_class_code
   AND xldt.event_type_code                 = xldb.event_type_code
   AND xldt.line_definition_code            = xldb.line_definition_code
   AND xldt.line_definition_owner_code      = xldb.line_definition_owner_code
   AND xalb.application_id                  = xldj.application_id
   AND xalb.amb_context_code                = xldj.amb_context_code
   AND xalb.entity_code                     = xpah.entity_code
   AND xalb.event_class_code                = xldj.event_class_code
   AND xalb.accounting_line_type_code       = xldj.accounting_line_type_code
   AND xalb.accounting_line_code            = xldj.accounting_line_code
   AND xalt.application_id                  = xalb.application_id
   AND xalt.amb_context_code                = xalb.amb_context_code
   AND xalt.entity_code                     = xalb.entity_code
   AND xalt.event_class_code                = xalb.event_class_code
   AND xalt.accounting_line_type_code       = xalb.accounting_line_type_code
   AND xalt.accounting_line_code            = xalb.accounting_line_code
   AND xcon.application_id(+)               = xalb.application_id
   AND xcon.amb_context_code(+)             = xalb.amb_context_code
   AND xcon.entity_code(+)                  = xalb.entity_code
   AND xcon.event_class_code(+)             = xalb.event_class_code
   AND xcon.accounting_line_type_code(+)    = xalb.accounting_line_type_code
   AND xcon.accounting_line_code(+)         = xalb.accounting_line_code
FOR UPDATE NOWAIT
;
--
l_rowid            ROWID;
--
l_log_module       VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowAcctgLines';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowAcctgLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

--
OPEN  AcctgLines_cur;
FETCH AcctgLines_cur INTO l_rowid;
CLOSE AcctgLines_cur;
--
LockRowLineDesc( p_application_id         => p_application_id
               , p_product_rule_code      => p_product_rule_code
               , p_product_rule_type_code => p_product_rule_type_code
               , p_amb_context_code       => p_amb_context_code
               );
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowAcctgLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF AcctgLines_cur%ISOPEN THEN
             CLOSE AcctgLines_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF AcctgLines_cur%ISOPEN THEN
             CLOSE AcctgLines_cur;
          END IF;
           -- SLA message to define
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );
      WHEN OTHERS    THEN
         IF AcctgLines_cur%ISOPEN THEN
         CLOSE AcctgLines_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowAcctgLines');
END LockRowAcctgLines;
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowHeaders                                                   |
--|    lock header and Headers, event class , event type                     |
--+==========================================================================+
--
PROCEDURE LockRowHeaders(  p_application_id         IN NUMBER
                         , p_product_rule_code      IN VARCHAR2
                         , p_product_rule_type_code IN VARCHAR2
                         , p_amb_context_code       IN VARCHAR2
                    )
IS
--
CURSOR Headers_cur
IS
SELECT  xpah.rowid
  FROM  xla_prod_acct_headers  xpah
     ,  xla_entity_types_b     xetb
      , xla_entity_types_tl    xett
     ,  xla_event_classes_b    xecb
      , xla_event_classes_tl   xect
 WHERE xpah.application_id                  = p_application_id
   AND xpah.amb_context_code                = p_amb_context_code
   AND xpah.product_rule_code               = p_product_rule_code
   AND xpah.product_rule_type_code          = p_product_rule_type_code
   AND xetb.entity_code                     = xpah.entity_code
   AND xetb.application_id                  = xpah.application_id
   AND xetb.entity_code                     = xpah.entity_code
   AND xetb.application_id                  = xett.application_id
   AND xetb.entity_code                     = xett.entity_code
   AND xecb.application_id(+)               = xpah.application_id
   AND xecb.entity_code(+)                  = xpah.entity_code
   AND xecb.event_class_code(+)             = xpah.event_class_code
   AND xect.application_id(+)               = xecb.application_id
   AND xect.entity_code(+)                  = xecb.entity_code
   AND xect.event_class_code(+)             = xecb.event_class_code
FOR UPDATE NOWAIT
;
--
l_rowid              ROWID;
--
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowHeaders';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowHeaders'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
OPEN  Headers_cur;
FETCH Headers_cur INTO  l_rowid;
CLOSE Headers_cur;
--
LockRowEventClass( p_application_id         => p_application_id
                 , p_product_rule_code      => p_product_rule_code
                 , p_product_rule_type_code => p_product_rule_type_code
                 , p_amb_context_code       => p_amb_context_code
                 );
--
LockRowEventClassGrp( p_application_id         => p_application_id
                    , p_product_rule_code      => p_product_rule_code
                    , p_product_rule_type_code => p_product_rule_type_code
                    , p_amb_context_code       => p_amb_context_code
                    );
--
LockRowSourceAssignment( p_application_id         => p_application_id
                       , p_product_rule_code      => p_product_rule_code
                       , p_product_rule_type_code => p_product_rule_type_code
                       , p_amb_context_code       => p_amb_context_code
                       );
--
LockRowExtractObject( p_application_id         => p_application_id
                    , p_product_rule_code      => p_product_rule_code
                    , p_product_rule_type_code => p_product_rule_type_code
                    , p_amb_context_code       => p_amb_context_code
                    );
--
LockRowEventType( p_application_id         => p_application_id
                , p_product_rule_code      => p_product_rule_code
                , p_product_rule_type_code => p_product_rule_type_code
                , p_amb_context_code       => p_amb_context_code
                );
--
LockRowHdrDesc( p_application_id         => p_application_id
              , p_product_rule_code      => p_product_rule_code
              , p_product_rule_type_code => p_product_rule_type_code
              , p_amb_context_code       => p_amb_context_code
              );
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowHeaders'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF Headers_cur%ISOPEN THEN
             CLOSE Headers_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF Headers_cur%ISOPEN THEN
             CLOSE Headers_cur;
          END IF;
           -- SLA message to define
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );
      WHEN OTHERS    THEN
         IF Headers_cur%ISOPEN THEN
         CLOSE Headers_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowHeaders');
END LockRowHeaders;
--
--+==========================================================================+
--|                                                                          |
--| Private procedure                                                        |
--|         LockRowPAD : lock Product Accounting Defintition  tables         |
--|                                                                          |
--+==========================================================================+
--

PROCEDURE LockRowPAD(   p_application_id         IN NUMBER
                      , p_product_rule_code      IN VARCHAR2
                      , p_product_rule_type_code IN VARCHAR2
                      , p_amb_context_code       IN VARCHAR2
                  )
IS
--
CURSOR pad_cur
IS
SELECT xprb.rowid
     , xprt.name
  FROM xla_product_rules_b   xprb
     , xla_product_rules_tl  xprt
 WHERE xprb.application_id                  = p_application_id
   AND xprb.product_rule_code               = p_product_rule_code
   AND xprb.product_rule_type_code          = p_product_rule_type_code
   AND xprb.amb_context_code                = p_amb_context_code
   AND xprb.application_id                  = xprt.application_id
   AND xprb.product_rule_code               = xprt.product_rule_code
   AND xprb.product_rule_type_code          = xprt.product_rule_type_code
   AND xprb.amb_context_code                = xprt.amb_context_code
   AND xprt.language                        = USERENV('LANG')
FOR UPDATE NOWAIT
;
l_rowid              ROWID;
l_name               VARCHAR2(80);
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockRowPAD';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of LockRowPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
OPEN  pad_cur;
FETCH pad_cur INTO l_rowid,l_name;
CLOSE pad_cur;
--
-- lock Headers, entities, event classes, event types defintions against changes
--
      LockRowHeaders(   p_application_id         => p_application_id
                      , p_product_rule_code      => p_product_rule_code
                      , p_product_rule_type_code => p_product_rule_type_code
                      , p_amb_context_code       => p_amb_context_code
                    );
--
-- lock Accounting Lines , descriptions,  conditions
--
   LockRowAcctgLines(   p_application_id         => p_application_id
                      , p_product_rule_code      => p_product_rule_code
                      , p_product_rule_type_code => p_product_rule_type_code
                      , p_amb_context_code       => p_amb_context_code
                    );
--
-- lock account derivation rules, conditions
--

          LockRowADR(   p_application_id         => p_application_id
                      , p_product_rule_code      => p_product_rule_code
                      , p_product_rule_type_code => p_product_rule_type_code
                      , p_amb_context_code       => p_amb_context_code
                    );

--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of LockRowPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          IF pad_cur%ISOPEN THEN
             CLOSE pad_cur;
          END IF;
          RAISE;
      WHEN xla_exceptions_pkg.resource_busy         THEN
          IF pad_cur%ISOPEN THEN
             CLOSE pad_cur;
          END IF;
          -- SLA message
          xla_exceptions_pkg.raise_message
                      ( 'XLA'
                       ,'XLA_CMP_COMPONENTS_LOCKED'
                       ,'PAD_NAME'
                       , g_product_rule_name
                       ,'PAD_OWNER'
                       , g_product_rule_owner
                       );
      WHEN OTHERS    THEN
         IF pad_cur%ISOPEN THEN
                      CLOSE pad_cur;
         END IF;
          -- SLA message to define
          xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockRowPAD');
END LockRowPAD;
--
--+==========================================================================+
--| PUBLIC  procedures and functions                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--

FUNCTION LockPAD (  p_application_id         IN NUMBER
                  , p_product_rule_code      IN VARCHAR2
                  , p_product_rule_type_code IN VARCHAR2
                  , p_product_rule_name      IN VARCHAR2
                  , p_amb_context_code       IN VARCHAR2
                )
RETURN BOOLEAN
IS
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.LockPAD';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
g_product_rule_name  := nvl(p_product_rule_name,p_product_rule_code);
g_product_rule_owner := xla_lookups_pkg.get_meaning(
                               p_lookup_type    => 'XLA_OWNER_TYPE'
                             , p_lookup_code    => p_product_rule_type_code
                             ) ;

--
SAVEPOINT LockPADRows;
--
LockRowPAD(   p_application_id         => p_application_id
            , p_product_rule_code      => p_product_rule_code
            , p_product_rule_type_code => p_product_rule_type_code
            , p_amb_context_code       => p_amb_context_code
           );
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value = TRUE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of LockPAD'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN TRUE;
--
EXCEPTION
      WHEN xla_exceptions_pkg.application_exception   THEN
          --
          ROLLBACK TO LockPADRows;
          --
          IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

                trace
                   (p_msg      => 'return value = FALSE'
                   ,p_level    => C_LEVEL_PROCEDURE
                   ,p_module   => l_log_module);

                trace
                   (p_msg      => 'END of LockPAD'
                   ,p_level    => C_LEVEL_PROCEDURE
                   ,p_module   => l_log_module);

          END IF;
          --
          RETURN FALSE;
          --
      WHEN OTHERS    THEN
         --
         ROLLBACK TO LockPADRows;
         --
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_lock_pad_pkg.LockPAD');
END LockPAD;
--
--=============================================================================
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

BEGIN

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_cmp_lock_pad_pkg; -- end of package spec

/
